-------------------------------------------------------------------------------
--Control of MuPix DACs and Pixel Tune DACs
--T. Weber, Mainz Univesity
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.StdTypes.all;

entity PixelControl is
  generic(
  	fpga_clk_speed : integer := 1e8;
  	spi_clk_speed : integer := 1e4
  );
  port (
    clk                  : in  std_logic; --clock
    reset                : in  std_logic; --reset
    mupixslctrl          : out MupixSlowControl;
    ctrl_dout            : in std_logic; --serial data from mupix
    --TRB slow control
    SLV_READ_IN          : in  std_logic;
    SLV_WRITE_IN         : in  std_logic;
    SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
    SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
    SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
    SLV_ACK_OUT          : out std_logic;
    SLV_NO_MORE_DATA_OUT : out std_logic;
    SLV_UNKNOWN_ADDR_OUT : out std_logic);
end PixelControl;

architecture Behavioral of PixelControl is
	
	constant c_fifo_word_width : integer :=  32;
	constant c_clk_div_max : integer := fpga_clk_speed/spi_clk_speed - 1;
	signal clk_div_cnt : integer range 0 to c_clk_div_max - 1 := 0;
	
	signal bitcounter : unsigned(15 downto 0) := (others => '0');--number of transmitted configuration bits
	signal bitstosend : unsigned(15 downto 0) := (others => '0');--number of bits which need to be send
	signal bitcouner_word : integer range 0 to c_fifo_word_width - 1 := c_fifo_word_width - 1; --index to current bit in word from fifo
	
	--fifos storage of configuration bits
	component STD_FIFO
		generic(
			DATA_WIDTH : positive := 8;
			FIFO_DEPTH : positive := 256
		);
		port(
			CLK     : in  std_logic;
			RST     : in  std_logic;
			WriteEn : in  std_logic;
			DataIn  : in  std_logic_vector(c_fifo_word_width - 1 downto 0);
			ReadEn  : in  std_logic;
			DataOut : out std_logic_vector(c_fifo_word_width - 1 downto 0);
			Empty   : out std_logic;
			Full    : out std_logic
		);
	end component STD_FIFO;
	
	component CRC
		generic(
	  		detect_enable_edge : boolean := false
		);
		port(
			clk     : in  std_logic;
			rst     : in  std_logic;
			enable  : in  std_logic;
			data_in : in  std_logic;
			crc_out : out std_logic_vector(4 downto 0)
		);
	end component CRC;

	signal WriteEn : std_logic;
	signal DataIn : std_logic_vector (c_fifo_word_width - 1 downto 0);
	signal ReadEn : std_logic;
	signal DataOut : std_logic_vector (c_fifo_word_width - 1 downto 0);
	signal Empty : std_logic;
	signal Full : std_logic;
	
	--send single configuration bit
	signal start_send, sending : std_logic; 
	signal reset_bitcounter : std_logic;
	type t_send_bits_fsm is (idle, sendbit1, sendbit2, done);
	signal send_bits_fsm : t_send_bits_fsm := idle; 
	

	--configuration state machine
	type t_config_fsm is (idle, config, readfifo, waitfifo, load);
	signal config_fsm : t_config_fsm := idle;
	
	--check sum for data integrity
	signal crc_correct : std_logic;
	signal enable_crc_to_mupix : std_logic;
	signal data_in_crc_to_mupix : std_logic;
	signal crc_out_crc_to_mupix : std_logic_vector(4 downto 0);
	signal reset_crc_to_mupix,  reset_crc_to_mupix_ext: std_logic;
	signal enable_crc_from_mupix : std_logic;
	signal data_in_crc_from_mupix : std_logic;
	signal crc_out_crc_from_mupix : std_logic_vector(4 downto 0);
	signal reset_crc_from_mupix,  reset_crc_from_mupix_ext : std_logic;
	
	--control signals to mupix
	signal mupix_ctrcl_select : std_logic;
	signal mupix_ctrl_i, mupix_ctrl_ext, mupix_ctrl_sel, mupix_ctrl_reg : MupixSlowControl := c_mupix_slctrl_init;
	
	
begin  -- Behavioral
	
	fifo_1 : entity work.STD_FIFO
		generic map(
			DATA_WIDTH => c_fifo_word_width,
			FIFO_DEPTH => 32
		)
		port map(
			CLK     => CLK,
			RST     => reset,
			WriteEn => WriteEn,
			DataIn  => DataIn,
			ReadEn  => ReadEn,
			DataOut => DataOut,
			Empty   => Empty,
			Full    => Full
		);
	
	crc_in : entity work.CRC
		generic map(detect_enable_edge => true)
		port map(
			clk     => clk,
			rst     => reset_crc_to_mupix,
			enable  => enable_crc_to_mupix,
			data_in => data_in_crc_to_mupix,
			crc_out => crc_out_crc_to_mupix
		);
		
	reset_crc_to_mupix <= reset or reset_crc_to_mupix_ext;	
		
	crc_out : entity work.CRC
		generic map(detect_enable_edge => true)
		port map(
			clk     => clk,
			rst     => reset_crc_from_mupix,
			enable  => enable_crc_from_mupix,
			data_in => data_in_crc_from_mupix,
			crc_out => crc_out_crc_from_mupix
		);
	
	reset_crc_from_mupix <= reset or reset_crc_from_mupix_ext;
	
	
	sendpix_bits : process(clk) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				send_bits_fsm     <= idle;
				mupix_ctrl_i.clk1 <= '0';
				mupix_ctrl_i.clk2 <= '0';
				mupix_ctrl_i.sin  <= '0';
				sending           <= '0';
			else
				case send_bits_fsm is
					when idle =>
						bitcouner_word    <= 31;
						sending           <= '0';
						clk_div_cnt       <= 0;
						send_bits_fsm     <= idle;
						mupix_ctrl_i.clk1 <= '0';
						mupix_ctrl_i.clk2 <= '0';
						mupix_ctrl_i.sin  <= '0';
						if start_send = '1' then
							sending          <= '1';
							send_bits_fsm    <= sendbit1;
						end if;
						if reset_bitcounter = '1' then
							bitcounter <= (others => '0');
						end if;
					when sendbit1 =>
						clk_div_cnt            <= clk_div_cnt + 1;
						send_bits_fsm          <= sendbit1;
						mupix_ctrl_i.sin <= DataOut(bitcouner_word);
						enable_crc_from_mupix  <= '0';
						enable_crc_to_mupix    <= '0';
						data_in_crc_from_mupix <= '0';
						data_in_crc_to_mupix   <= ctrl_dout;
						if clk_div_cnt = (c_clk_div_max - 1)/2 then
							send_bits_fsm     <= sendbit2;
							mupix_ctrl_i.clk1 <= '1'; -- clocking
							mupix_ctrl_i.clk2 <= '0';
							data_in_crc_from_mupix <= ctrl_dout; --CRC checksum
							data_in_crc_to_mupix   <= DataOut(bitcouner_word);
							enable_crc_from_mupix  <= '1';
							enable_crc_to_mupix    <= '1';
							bitcounter             <= bitcounter + 1;
						end if;
					when sendbit2 =>
						clk_div_cnt            <= clk_div_cnt + 1;
						send_bits_fsm          <= sendbit2;
						if clk_div_cnt = c_clk_div_max - 1 then
							mupix_ctrl_i.clk1 <= '0';
							mupix_ctrl_i.clk2 <= '1';
							clk_div_cnt       <= 0;
							if bitcouner_word = 0 or bitcounter = bitstosend then
								send_bits_fsm          <= done;
							else
								send_bits_fsm          <= sendbit1;
								bitcouner_word         <= bitcouner_word -1;
							end if;
						end if;
					when done => -- 
						clk_div_cnt            <= clk_div_cnt + 1;
						send_bits_fsm          <= done;
						if clk_div_cnt = (c_clk_div_max - 1)/2 then
							send_bits_fsm          <= idle; -- just hold clk2 high long enough before going back to idle
						end if;
				end case;
			end if;
		end if;
	end process sendpix_bits;
	
		
	
	configure_proc : process(clk) is
		variable hold_load_counter : integer range 0 to 7;
	begin
		if rising_edge(clk) then
			if reset = '1' then
				mupix_ctrl_i.load <= '0';
				config_fsm        <= idle;
				hold_load_counter := 0;
			else
				mupix_ctrl_i.load <= '0';
				ReadEn            <= '0';
				start_send        <= '0';
				reset_bitcounter  <= '0';
				case config_fsm is
					when idle =>
						hold_load_counter := 0;
						if Empty = '0' then
							config_fsm <= readfifo;
						else
							config_fsm <= idle;
						end if;
					when readfifo =>
						if Empty = '0' then
							ReadEn     <= '1';
							start_send <= '1';
							config_fsm <= waitfifo;
						else
							ReadEn     <= '0';
							config_fsm <= readfifo; -- wait on next config word in fifo
						end if;
					when waitfifo =>    -- wait for fifo word to be valid
						config_fsm <= config;
					when config =>
						if sending = '1' then
							config_fsm <= config;
						else
							if bitcounter < bitstosend then -- everything send or read other fifo word
								config_fsm <= readfifo;
							else
								config_fsm <= load;
							end if;
						end if;
					when load =>        -- load from shift register
						hold_load_counter := hold_load_counter + 1;
						mupix_ctrl_i.load <= '1';
						config_fsm        <= load;
						if hold_load_counter = 7 then
							mupix_ctrl_i.load <= '0';
							reset_bitcounter  <= '1';
							config_fsm        <= idle;
						end if;
				end case;
			end if;
		end if;
	end process configure_proc;
	
	
  -----------------------------------------------------------------------------
  --x0080: input to fifo (write)/current fifo output (read)
  --x0081: current CRC check sum (read only)
  --x0082: data fifo is full (read only)
  --x0083: configure 
  --				 bit 0: sin
  --                 bit 1: clk1
  --                 bit 2: clk2
  --                 bit 3: load	
  --				 bit 4: select FPGA programming or software programming 
  --                 bit 5: reset outgoing CRC sum
  --                 bit 6: reset incoming CRC sum
  --                 bit 31-16: number of total bits for configuration
  -----------------------------------------------------------------------------
  SLV_BUS : process(clk)
	begin                               -- process SLV_BUS
		if rising_edge(clk) then
			SLV_DATA_OUT         <= (others => '0');
			SLV_UNKNOWN_ADDR_OUT <= '0';
			SLV_NO_MORE_DATA_OUT <= '0';
			SLV_ACK_OUT          <= '0';

			DataIn                   <= (others => '0');
			WriteEn                  <= '0';
			reset_crc_to_mupix_ext   <= '0';
			reset_crc_from_mupix_ext <= '0';

			if SLV_WRITE_IN = '1' then
				case SLV_ADDR_IN is
					when x"0080" =>
						DataIn      <= SLV_DATA_IN;
						WriteEn     <= '1';
						SLV_ACK_OUT <= '1';
					when x"0083" =>
						mupix_ctrl_ext.sin       <= SLV_DATA_IN(0);
						mupix_ctrl_ext.clk1      <= SLV_DATA_IN(1);
						mupix_ctrl_ext.clk2      <= SLV_DATA_IN(2);
						mupix_ctrl_ext.load      <= SLV_DATA_IN(3);
						mupix_ctrcl_select       <= SLV_DATA_IN(4);
						reset_crc_to_mupix_ext   <= SLV_DATA_IN(5);
						reset_crc_from_mupix_ext <= SLV_DATA_IN(6);
						bitstosend               <= unsigned(SLV_DATA_IN(31 downto 16));
						SLV_ACK_OUT              <= '1';
					when others =>
						SLV_UNKNOWN_ADDR_OUT <= '1';
				end case;

			elsif SLV_READ_IN = '1' then
				case SLV_ADDR_IN is
					when x"0080" =>
						SLV_DATA_OUT <= DataOut;
						SLV_ACK_OUT  <= '1';
					when x"0081" =>
						SLV_DATA_OUT(10 downto 0) <= crc_out_crc_from_mupix & crc_out_crc_to_mupix & crc_correct;
						SLV_ACK_OUT               <= '1';
					when x"0082" =>
						SLV_DATA_OUT(1 downto 0) <= Empty & Full;
						SLV_ACK_OUT              <= '1';
					when x"0083" =>
						SLV_DATA_OUT(0)            <= mupix_ctrl_ext.sin;
						SLV_DATA_OUT(1)            <= mupix_ctrl_ext.clk1;
						SLV_DATA_OUT(2)            <= mupix_ctrl_ext.clk2;
						SLV_DATA_OUT(3)            <= mupix_ctrl_ext.load;
						SLV_DATA_OUT(4)            <= mupix_ctrcl_select;
						SLV_DATA_OUT(5)            <= reset_crc_to_mupix_ext;
						SLV_DATA_OUT(6)            <= reset_crc_from_mupix_ext;
						SLV_DATA_OUT(31 downto 16) <= std_logic_vector(bitstosend);
						SLV_ACK_OUT                <= '1';
					when others =>
						SLV_UNKNOWN_ADDR_OUT <= '1';
				end case;
			end if;
		end if;
	end process SLV_BUS;

 	crc_correct <= '1' when crc_out_crc_from_mupix = crc_out_crc_to_mupix else '0';

	slow_control_mux : process(mupix_ctrcl_select, mupix_ctrl_ext, mupix_ctrl_i) is
	begin
		if mupix_ctrcl_select = '1' then
			mupix_ctrl_sel <= mupix_ctrl_ext;
		else
			mupix_ctrl_sel <= mupix_ctrl_i;
		end if;
	end process slow_control_mux;

	output_pipe : process(clk) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				mupix_ctrl_reg <= c_mupix_slctrl_init;
			else
				mupix_ctrl_reg <= mupix_ctrl_sel;
			end if;
		end if;
	end process output_pipe;

	--matching to outputs	
	mupixslctrl <= mupix_ctrl_reg;

end Behavioral;


