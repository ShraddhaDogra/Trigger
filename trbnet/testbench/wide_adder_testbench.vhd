LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;


entity testbench is
end entity;


architecture test_arch of testbench is

  component wide_adder is
    generic(
      WIDTH : integer := 16;
      WORDS : integer := 18;
      PARALLEL_ADDERS : integer := 3;
      PSEUDO_WORDS : integer := 16 --the smallest multiple of PARALLEL_ADDERS, greater or equal than WORDS
      );
    port(
      CLK    : in std_logic;
      CLK_EN : in std_logic;
      RESET  : in std_logic;
      INPUT_IN     : in  std_logic_vector(WIDTH*WORDS-1 downto 0);
      START_IN     : in  std_logic;
      VAL_ENABLE_IN: in  std_logic_vector(WORDS-1 downto 0);
      RESULT_OUT   : out std_logic_vector(WIDTH-1 downto 0);
      OVERFLOW_OUT : out std_logic;
      READY_OUT    : out std_logic
      );
  end component;


component wide_adder_17x16 is
   generic(
     SIZE : integer := 16;
     WORDS: integer := 17 --fixed
     );
   port(
    CLK    : in std_logic;
    CLK_EN : in std_logic;
    RESET  : in std_logic;
    INPUT_IN     : in  std_logic_vector(SIZE*WORDS-1 downto 0);
    START_IN     : in  std_logic;
    VAL_ENABLE_IN: in  std_logic_vector(WORDS-1 downto 0);
    RESULT_OUT   : out std_logic_vector(SIZE-1 downto 0);
    OVERFLOW_OUT : out std_logic;
    READY_OUT    : out std_logic
    );
end component;

signal CLK : std_logic := '1';
signal CLK_EN : std_logic := '1';
signal RESET : std_logic := '1';

signal start : std_logic := '0';
signal overflow : std_logic := '0';
signal ready : std_logic := '0';
signal result : std_logic_vector(15 downto 0);
signal input : std_logic_vector(255+16 downto 0);
signal enable : std_logic_vector(16 downto 0);

begin
RESET <= '0' after 100 ns;
CLK <= not CLK after 5 ns;

start <= '1' after 141 ns, '0' after 151 ns, '1' after 291 ns, '0' after 301 ns;
input <= x"0001_0800_4000_2000_1000_8000_0400_0200_0100_0010_0020_0040_0080_0001_0002_0004_0001";
enable <= "10111111111111111";

 the_adder : wide_adder_17x16
   generic map(
     SIZE => 16
--      WIDTH => 16,
--      WORDS => 16,
--      PARALLEL_ADDERS => 4,
--      PSEUDO_WORDS => 16
     )
   port map(
    CLK => CLK,
    CLK_EN => CLK_EN,
    RESET => RESET,
    INPUT_IN => input,
    START_IN => start,
    VAL_ENABLE_IN => enable,
    RESULT_OUT => result,
    OVERFLOW_OUT => overflow,
    READY_OUT => ready
    );

end architecture;