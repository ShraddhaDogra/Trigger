-------------------------------------------------------------------------------
--Control of MuPix DACs and Pixel Tune DACs
--T. Weber, Mainz Univesity
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.StdTypes.all;

entity PixCtr is
  generic(
  	fpga_clk_speed : integer := 1e8;
  	spi_clk_speed : integer := 1e4
  );
  port (
    clk                  : in  std_logic;
    reset                : in  std_logic;
    sout_c_from_mupix    : in  std_logic;
    sout_d_from_mupix    : in  std_logic;
    mupix_ctrl           : out MupixSlowControl;
    SLV_READ_IN          : in  std_logic;
    SLV_WRITE_IN         : in  std_logic;
    SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
    SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
    SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
    SLV_ACK_OUT          : out std_logic;
    SLV_NO_MORE_DATA_OUT : out std_logic;
    SLV_UNKNOWN_ADDR_OUT : out std_logic);
end PixCtr;

architecture Behavioral of PixCtr is
	
	constant fifo_word_width : integer :=  32;
	
	signal bitcounter : unsigned(15 downto 0) := (others => '0');--number of transmitted configuration bits
	signal bitstosend : unsigned(15 downto 0) := (others => '0');--number of bits which need to be send
	signal bitcouner_word : integer range 0 to fifo_word_width - 1 := 0; --index to current bit in word from fifo
	signal controlConfig : std_logic_vector(15 downto 0) := (others => '0');--configuration control
	
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
			DataIn  : in  std_logic_vector(fifo_word_width - 1 downto 0);
			ReadEn  : in  std_logic;
			DataOut : out std_logic_vector(fifo_word_width - 1 downto 0);
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
	signal DataIn : std_logic_vector (fifo_word_width - 1 downto 0);
	signal ReadEn : std_logic;
	signal DataOut : std_logic_vector (fifo_word_width - 1 downto 0);
	signal Empty : std_logic;
	signal Full : std_logic;
	
	--clock enable signals
	signal clk_enable : std_logic := '0';
	constant clk_div_max : integer := fpga_clk_speed/spi_clk_speed - 1;
	signal clk_div_counter : integer range 0 to clk_div_max := clk_div_max;
	
	--send single configuration bit
	type bit_send_fsm_type is (idle, sendbit1, sendbit2, sendbit3);
	signal bit_send_fsm : bit_send_fsm_type := idle;
	signal start_send, sending : std_logic; 
	
	--configuration state machine
	type config_fsm_type is (idle, config, readfifo, waitfifo, load);
	signal config_fsm : config_fsm_type := idle;
	
	--check sum for data integrity
	signal crc_correct : std_logic;
	signal enable_crc_to_mupix : std_logic;
	signal data_in_crc_to_mupix : std_logic;
	signal crc_out_crc_to_mupix : std_logic_vector(4 downto 0);
	signal reset_crc_to_mupix : std_logic;
	signal enable_crc_from_mupix : std_logic;
	signal data_in_crc_from_mupix : std_logic;
	signal crc_out_crc_from_mupix : std_logic_vector(4 downto 0);
	signal reset_crc_from_mupix : std_logic;
	
	--control signals to mupix
	signal mupix_ctrl_i, mupix_ctrl_reg : MupixSlowControl := MuPixSlowControlInit;
	
	
begin  -- Behavioral
	
	fifo_1 : entity work.STD_FIFO
		generic map(
			DATA_WIDTH => fifo_word_width,
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
	
	--TODO: CRC checking logic
	crc_in : entity work.CRC
		generic map(detect_enable_edge => true)
		port map(
			clk     => clk,
			rst     => reset_crc_to_mupix,
			enable  => enable_crc_to_mupix,
			data_in => data_in_crc_to_mupix,
			crc_out => crc_out_crc_to_mupix
		);
		
	reset_crc_to_mupix <= reset or controlConfig(2);	
		
	crc_out : entity work.CRC
		generic map(detect_enable_edge => true)
		port map(
			clk     => clk,
			rst     => reset_crc_from_mupix,
			enable  => enable_crc_from_mupix,
			data_in => data_in_crc_from_mupix,
			crc_out => crc_out_crc_from_mupix
		);
	
	reset_crc_from_mupix <= reset or controlConfig(3);
	
	spi_clk_div_proc : process (clk) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				clk_enable <= '0';
				clk_div_counter <= clk_div_max;
			else
				if clk_div_counter = 0 then
					clk_div_counter <= clk_div_max;
					clk_enable <= '1';
				else	
					clk_div_counter <= clk_div_counter - 1;
					clk_enable <= '0';
				end if;
			end if;
		end if;
	end process spi_clk_div_proc;
	
	
	sendpixbit_proc : process (clk) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				mupix_ctrl_i.ck_c <= '0';
				mupix_ctrl_i.ck_d <= '0';
				mupix_ctrl_i.sin <= '0';
				sending <= '0';
				bit_send_fsm <= idle;
				bitcounter <= (others => '0');
				bitcouner_word <= fifo_word_width - 1;
			else
				if clk_enable = '1' then
					mupix_ctrl_i.ck_c <= '0';
					mupix_ctrl_i.ck_d <= '0';
					mupix_ctrl_i.sin <= '0';
					enable_crc_to_mupix <= '0';
					enable_crc_from_mupix <= '0';
					data_in_crc_from_mupix <= '0';
					data_in_crc_to_mupix <= '0';
					case bit_send_fsm is 
						when idle =>
							bitcouner_word <= fifo_word_width - 1;
							if start_send = '1' then
								bit_send_fsm <= sendbit1;
								sending <= '1';
							else
								bit_send_fsm <= idle;
								sending <= '0';
							end if;
						when sendbit1 =>
							mupix_ctrl_i.sin <= DataOut(bitcouner_word);
							sending <= '1';
							bit_send_fsm <= sendbit2;
						when sendbit2 => --rising clock edge
							mupix_ctrl_i.sin <= DataOut(bitcouner_word);
							if controlConfig(0) = '1' then
								mupix_ctrl_i.ck_d <= '1';
							else
								mupix_ctrl_i.ck_c <= '1';
							end if;
							enable_crc_to_mupix <= '1';
							data_in_crc_to_mupix <= DataOut(bitcouner_word);
							bit_send_fsm <= sendbit3;
							sending <= '1';
						when sendbit3 =>
							sending <= '1';
							mupix_ctrl_i.sin <= DataOut(bitcouner_word);
							enable_crc_from_mupix <= '1';
							if controlConfig(0) = '1' then
								data_in_crc_from_mupix <= sout_d_from_mupix;
							else
								data_in_crc_from_mupix <= sout_c_from_mupix;
							end if;
							bitcouner_word <= bitcouner_word - 1;
							bitcounter <= bitcounter + 1;
							if bitcouner_word = 0 or bitcounter = bitstosend then
								bit_send_fsm <= idle;
							else
								bit_send_fsm <= sendbit1;
							end if;
					end case;
				end if;
			end if;
		end if;
	end process sendpixbit_proc;
		
	
	configure_proc : process (clk) is
		variable hold_load_counter : integer range 0 to 7;
	begin
		if rising_edge(clk) then
			if reset = '1' then
				mupix_ctrl_i.ld_c <= '0';
				config_fsm <= idle;
				hold_load_counter := 0;
			else
				mupix_ctrl_i.ld_c <= '0';
				ReadEn <= '0';
				start_send <= '0';
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
							ReadEn <= '1';
							config_fsm <= waitfifo;
						else
							ReadEn <= '0';
							config_fsm <= readfifo;
						end if;
					when waitfifo =>
						config_fsm <= config;
						if sending = '0' then
							start_send <= '1';
							config_fsm <= waitfifo;
						else
							start_send <= '0';
							config_fsm <= config;
						end if;
					when config =>
						if sending = '1' then
							config_fsm <= config;
						else
							if bitcounter < bitstosend then
								config_fsm <= readfifo;
							else
								if controlConfig(1) = '0' then
									config_fsm <= load;
								else
									config_fsm <= idle;
								end if;
							end if;
						end if;	
					when load =>
						hold_load_counter := hold_load_counter + 1;
						mupix_ctrl_i.ld_c <= '1';
						if hold_load_counter = 7 then
							mupix_ctrl_i.ld_c <= '0';
							config_fsm <= idle;
						else
							config_fsm <= load;
						end if;
				end case;
			end if;
		end if;
	end process configure_proc;
	
	
  -----------------------------------------------------------------------------
  --x0080: input to fifo (write)/current fifo output (read)
  --x0081: current CRC check sum (read only)
  --x0082: data fifo is full (read only)
  --x0083: configure bit 0: configure chip dacs/pixel dacs, 
  --                 bit 1: readback bit 32-16 number of config bits 
  --                 bit 2: reset outgoing CRC sum
  --                 bit 3: reset incoming CRC sum
  -----------------------------------------------------------------------------
  SLV_BUS : process (clk)
  begin  -- process SLV_BUS
    if rising_edge(clk) then
      
      SLV_DATA_OUT         <= (others => '0');
      SLV_UNKNOWN_ADDR_OUT <= '0';
      SLV_NO_MORE_DATA_OUT <= '0';
      SLV_ACK_OUT          <= '0'; 
      DataIn  <= (others => '0');
      WriteEn <= '0'; 
      if SLV_WRITE_IN = '1' then
        case SLV_ADDR_IN is
          when x"0080" =>
          	DataIn  <= SLV_DATA_IN;
          	WriteEn <= '1';
          	SLV_ACK_OUT  <= '1';
          when x"0083" =>
          	controlConfig <= SLV_DATA_IN(15 downto 0);
          	bitstosend <= unsigned(SLV_DATA_IN(31 downto 16));
          	SLV_ACK_OUT  <= '1';
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
            SLV_ACK_OUT  <= '1';
          when x"0082" =>
        	SLV_DATA_OUT(1 downto 0) <= Empty & Full;
            SLV_ACK_OUT  <= '1';
          when x"0083" =>
        	SLV_DATA_OUT <= std_logic_vector(bitstosend) & controlConfig;
            SLV_ACK_OUT  <= '1';
          when others =>
            SLV_UNKNOWN_ADDR_OUT <= '1';
        end case;
      end if;
    end if;
  end process SLV_BUS;

  crc_correct <= '1' when crc_out_crc_from_mupix = crc_out_crc_to_mupix else '0';
	
  output_pipe : process (clk) is
  begin
  	if rising_edge(clk) then
  		if reset = '1' then
  			mupix_ctrl_reg <= MuPixSlowControlInit;
  		else
  			mupix_ctrl_reg <= mupix_ctrl_i;
  		end if;
  	end if;
  end process output_pipe;
  
  --matching to outputs	
  mupix_ctrl <= mupix_ctrl_reg;

end Behavioral;


