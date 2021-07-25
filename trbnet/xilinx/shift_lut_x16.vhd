-- taken from xapp256 and changed to be more
-- flexible (Ingo)

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity shift_lut_x16 is
  generic (
    ADDRESS_WIDTH : integer := 0
    );
  port (
         D    : in std_logic;
        CE   : in std_logic; 
        CLK  : in std_logic;
        A    : in std_logic_vector (ADDRESS_WIDTH+3 downto 0);
        Q    : out std_logic
       ); 
end shift_lut_x16;
--
architecture shift_lut_x16_arch of shift_lut_x16 is
--
-- Components Declarations:
component SRLC16E 
  port (
  	D    : in std_logic;
        CE   : in std_logic;
        CLK  : in std_logic;
        A0   : in std_logic;
        A1   : in std_logic;
        A2   : in std_logic;
        A3   : in std_logic;
        Q    : out std_logic;
        Q15  : out std_logic
	); 
end component;
--attribute BOX_TYPE of SRLC16E : component is "BLACK_BOX";
--
-- signal declarations
signal SHIFT_CHAIN : std_logic_vector ((2**ADDRESS_WIDTH) downto 0);
signal SHIFT_OUT : std_logic_vector ((2**ADDRESS_WIDTH)-1 downto 0);
--
begin
--
  SHIFT_CHAIN(0) <= D;


    U_SRLC16E_INST: for i in 0 to ((2**(ADDRESS_WIDTH))-1) generate
      U_SRLC16E: SRLC16E
        port map (
        D      => SHIFT_CHAIN(i),
        CE     => CE,
        CLK    => CLK,
        A0     => A(0),
        A1     => A(1),
        A2     => A(2),
        A3     => A(3),
        Q      => SHIFT_OUT(i),
        Q15    => SHIFT_CHAIN (i+1)
        );
    end generate;

  CHECK_WIDTH1: if ADDRESS_WIDTH>0 generate
    Q <= SHIFT_OUT(conv_integer(A(ADDRESS_WIDTH+3 downto 4)));
  end generate;
  CHECK_WIDTH2: if ADDRESS_WIDTH=0 generate
    Q <= SHIFT_OUT(0);
  end generate;

end shift_lut_x16_arch;
------------------------------------------------------------------------------------------------


