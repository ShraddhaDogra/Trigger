----------------------------------------------------------------------------
-- SPI IF
-- Interface to the SPI bus controlling the three DACs on the mupix test board
--
-- Niklaus Berger, Heidelberg University
-- nberger@physi.uni-heidelberg.de
-- Changed to TRB3 readout by T. Weber, University Mainz
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mupix_components.all;

entity spi_if is
  port(
    clk                  : in  std_logic;
    reset                : in  std_logic;
    SLV_READ_IN          : in  std_logic;
    SLV_WRITE_IN         : in  std_logic;
    SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
    SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
    SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
    SLV_ACK_OUT          : out std_logic;
    SLV_NO_MORE_DATA_OUT : out std_logic;
    SLV_UNKNOWN_ADDR_OUT : out std_logic;
    spi_data             : out std_logic;
    spi_clk              : out std_logic;
    spi_ld               : out std_logic
    );          
end entity spi_if;



architecture rtl of spi_if is

  type   state_type is (waiting, writing, loading);
  signal state : state_type;

  signal shiftregister : std_logic_vector(47 downto 0);
  signal write_again   : std_logic;

  signal spi_data_i, spi_data_reg  : std_logic;
  signal spi_clk_i, spi_clk_reg    : std_logic;
  signal spi_ld_i, spi_ld_reg      : std_logic;	
  attribute syn_preserve : boolean;
  attribute syn_keep : boolean;
  attribute syn_keep of spi_data_reg, spi_clk_reg, spi_ld_reg : signal is true;
  attribute syn_preserve of spi_data_reg, spi_clk_reg, spi_ld_reg : signal is true;
  	

  signal ckdiv : unsigned(5 downto 0);

  signal injection2_reg : std_logic_vector(15 downto 0) := (others => '0');
  signal injection1_reg : std_logic_vector(15 downto 0) := (others => '0');
  signal threshold_reg  : std_logic_vector(15 downto 0) := (others => '0');
  signal wren           : std_logic;


  signal cyclecounter : unsigned(7 downto 0);

begin


  process(clk)
	begin
		if rising_edge(clk) then
			if (reset = '1') then
				ckdiv        <= (others => '0');
				cyclecounter <= (others => '0');
				spi_data_i     <= '0';
				spi_clk_i      <= '0';
				spi_ld_i       <= '0';
				state        <= waiting;
			else
				case state is
					when waiting =>
						ckdiv        <= (others => '0');
						cyclecounter <= (others => '0');
						spi_data_i     <= '0';
						spi_clk_i      <= '0';
						spi_ld_i       <= '0';
						state        <= waiting;
						if wren = '1' then
							shiftregister <= injection2_reg & injection1_reg & threshold_reg;
							state         <= writing;
							write_again   <= '0';
						end if;
					when writing =>
						ckdiv <= ckdiv + 1;
						if (ckdiv = "000000") then
							cyclecounter <= cyclecounter + 1;
							if (cyclecounter(0) = '0') then -- even cycles: push data, clock at '0'
								spi_data_i                   <= shiftregister(47);
								shiftregister(47 downto 1) <= shiftregister(46 downto 0);
								shiftregister(0)           <= '0';
								spi_clk_i                    <= '0';
							end if;
							if (cyclecounter(0) = '1') then --odd cycles: 
								spi_clk_i <= '1';
							end if;
							if (cyclecounter = "01100000") then -- we are done...
								state        <= loading;
								spi_clk_i      <= '1';
								cyclecounter <= "00000000";
							end if;
						end if;
					when loading =>
						ckdiv <= ckdiv + 1;
						if (ckdiv = "00000") then
							cyclecounter <= cyclecounter + 1;
							if (cyclecounter = "00000000") then
								spi_ld_i <= '1';
							elsif (cyclecounter = "00000001") then
								spi_clk_i <= '0';
							elsif (cyclecounter = "00000010") then
								spi_ld_i <= '0';
								state  <= waiting;
							end if;
						end if;
				end case;
			end if;
		end if;
	end process;

  -----------------------------------------------------------------------------
  --TRB slave bus
  --x0040: Threshold-DAC Register 16 bits
  --x0041: Injection-DACs Register 32 bits
   -----------------------------------------------------------------------------
  SLV_HANDLER : process(clk)
  begin  -- process SLV_HANDLER
    if rising_edge(clk) then
      SLV_DATA_OUT         <= (others => '0');
      SLV_UNKNOWN_ADDR_OUT <= '0';
      SLV_NO_MORE_DATA_OUT <= '0';
      SLV_ACK_OUT          <= '0';
      wren <= '0';

      if SLV_READ_IN = '1' then
        case SLV_ADDR_IN is
          when x"0040" =>
            SLV_DATA_OUT <= x"0000" & threshold_reg;
            SLV_ACK_OUT  <= '1';
          when x"0041" =>
            SLV_DATA_OUT <=  x"0000" & injection1_reg;
            SLV_ACK_OUT  <= '1';
          when x"0042" =>
            SLV_DATA_OUT <= x"0000" & injection2_reg;
            SLV_ACK_OUT  <= '1';
          when others =>
            SLV_UNKNOWN_ADDR_OUT <= '1';
        end case;
      end if;

      if SLV_WRITE_IN = '1' then
        case SLV_ADDR_IN is
          when x"0040" =>
            threshold_reg <= SLV_DATA_IN(15 downto 0);
            SLV_ACK_OUT   <= '1';
            wren <= '1';
          when x"0041" =>
            injection1_reg <= SLV_DATA_IN(15 downto 0);
            SLV_ACK_OUT    <= '1';
            wren <= '1';
          when x"0042" =>
            injection2_reg <= SLV_DATA_IN(15 downto 0);
            SLV_ACK_OUT    <= '1';
            wren <= '1';
          when others =>
            SLV_UNKNOWN_ADDR_OUT <= '1';
        end case;
      end if;
    end if;
  end process SLV_HANDLER;

  output_pipe : process (clk) is
  begin
  	if rising_edge(clk) then
  		if reset = '1' then
  			spi_data_reg <= '0';
  			spi_clk_reg  <= '0';
  			spi_ld_reg   <= '0';
  		else
  			spi_data_reg <= spi_data_i;
  			spi_clk_reg  <= spi_clk_i;
  			spi_ld_reg   <= spi_ld_i;
  		end if;
  	end if;
  end process output_pipe;
  

  spi_data <= spi_data_reg;
  spi_clk  <= spi_clk_reg;
  spi_ld   <= spi_ld_reg;

end rtl;
