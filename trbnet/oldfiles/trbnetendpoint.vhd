--------------------------------------------------------------------------------
-- The standard endpoint for all devices, like DTU, MU etc.
-- The idea is to be independent from the "user"
--
-- The endpoint works like a RAM
-- Memory Map:
--
-- 0x000 - 0x0FF global registers
--
-- 0x100 - 0x1FF 16 sender ENDOBUFs (each 16 addresses)
--
-- 0x200 - 0x2FF 16 receiver ENDIBUFs (each 16 addresses)
--
-- for each ENDBUF, Adress 0x0 is the FIFO itself
--                         0x1 is the status register
--                         0x2 is the control register
---------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

--Entity decalaration for clock generator
entity TRBNETENDPOINT is port(
	RESET : in std_logic;
	clk: in std_logic;
--pin connections -------------------------------------------------------
	RD: in STD_LOGIC;	 -- Read strobe
        WR: in STD_LOGIC;	 -- Write strobe
        -- for a single transfer, the strobes MUST NOT be longer
        -- then one cycle (already sync signals)
 	DATA_OUT: out STD_LOGIC_VECTOR (31 downto 0) ; -- I/O Bus
        DATA_IN : in  STD_LOGIC_VECTOR (31 downto 0) ; -- I/O Bus
        ADDRESS: in STD_LOGIC_VECTOR (11 downto 0)  -- Adress lines for the
                                                    -- given space
        );
END TRBNETENDPOINT;

architecture arch_TRBNETENDPOINT of TRBNETENDPOINT is

  component FIFO is
    generic (WIDTH : integer := 8;  	-- FIFO word width
	     DEPTH : integer := 8);     -- Depth of the FIFO

    port (DATA_IN  : in std_logic_vector(WIDTH - 1 downto 0);  -- Input data
	  DATA_OUT : out std_logic_vector(WIDTH - 1 downto 0);  -- Out put data
	  CLK : in std_logic;  		-- System Clock
	  RESET : in std_logic;  	-- System global Reset
	  RE : in std_logic;  		-- Read Enable
	  WE : in std_logic;  		-- Write Enable
	  FULL : buffer std_logic;  	-- Full Flag
	  EMPTY : buffer std_logic); 	-- Empty Flag
  end component;

  signal DATA_FIFO1 : STD_LOGIC_VECTOR(31 downto 0);
  signal DATA_FIFO2 : STD_LOGIC_VECTOR(31 downto 0);

  signal WE1 : STD_LOGIC;
  signal WE2 : STD_LOGIC;
  
begin  -- arch_TRBNETENRPOINT

  FIFO1: FIFO
    generic map (
      WIDTH => 32,
      DEPTH => 8
      )
    port map (
      Data_in => DATA_IN,
      Data_out => DATA_FIFO1,
      clk => clk,
      Reset =>  RESET,
      WE => WE1,
      RE => '0'
      );

  FIFO2: FIFO
    generic map (
      WIDTH => 32,
      DEPTH => 8
      )
    port map (
      Data_in => DATA_IN,
      Data_out => DATA_FIFO2,
      clk => clk,
      Reset =>  RESET,
      WE => WE2,
      RE => '0'
      );
  

process (CLK)
begin  -- process
  if CLK'event and CLK = '1' then  -- rising clock edge
    if RD = '1' and ADDRESS(2) = '1' then
      DATA_OUT <= DATA_FIFO1;
      --DATA_OUT <= x"affeaffe";
    end if;
    if RD = '1' and ADDRESS(2) = '0' then
      --DATA_OUT <= x"deadface";
      DATA_OUT <= DATA_FIFO2;
    end if;
    if WR = '1' and ADDRESS(2) = '1' then
      WE1 <= '1';
    else
      WE1 <= '0';     
    end if;
    if WR = '1' and ADDRESS(2) = '0' then
      WE2 <= '1';
    else
      WE2 <= '0';    
    end if;
  end if;
end process;
  
end arch_TRBNETENDPOINT;
