library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


library work;
use work.trb_net_std.all;

entity tb is
end entity;


architecture tb_arch of tb is

component trb_net_onewire is
  generic(
    USE_TEMPERATURE_READOUT : integer range 0 to 1 := 1;
    PARASITIC_MODE : integer range 0 to 1 := c_NO;
    CLK_PERIOD : integer := 10  --clk period in ns
    );
  port(
    CLK      : in std_logic;
    RESET    : in std_logic;
    READOUT_ENABLE_IN : in std_logic := '1';
    --connection to 1-wire interface
    ONEWIRE  : inout std_logic;
    MONITOR_OUT : out std_logic;
    --connection to id ram, according to memory map in TrbNetRegIO
    DATA_OUT : out std_logic_vector(15 downto 0);
    ADDR_OUT : out std_logic_vector(2 downto 0);
    WRITE_OUT: out std_logic;
    TEMP_OUT : out std_logic_vector(11 downto 0);
    ID_OUT   : out std_logic_vector(63 downto 0);
    STAT     : out std_logic_vector(31 downto 0)
    );
end component;


signal clk:   std_logic := '1';
signal reset: std_logic := '1';
signal onewire: std_logic;

begin

clk   <= not clk after 5 ns;
reset <= '0' after 103 ns;

onewire <= 'H';

THE_ONEWIRE : trb_net_onewire
  port map(
    CLK => clk,
    RESET => reset,
    ONEWIRE => onewire
    );


end architecture;