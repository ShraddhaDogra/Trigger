library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library lattice;
use lattice.components.all;

entity Amps2_TempSensor_UID is
  port(
    clk   : in std_logic;
    temperature: out std_logic_vector(11 downto 0);
    ID_OUT: out std_logic_vector(31 downto 0);
    --I2C signals.
    sda : inout std_logic;
    scl : inout std_logic
  );
end Amps2_TempSensor_UID;

architecture Behavioral of Amps2_TempSensor_UID is
   signal reset :   std_logic;
   signal count :   integer range 0 to 133_000_000 := 0;
   signal temporal: std_logic;

begin

-- temperature <= "1111" & x"AB";
  SENSOR_INTERFACE: entity Amps2_Interface
  generic map(
    clk_frequency => 133_000_000,
    i2c_frequency => 100_000
  )
  port map(
    clk             => clk,
    reset           => reset,
    temperature     => temperature,
    ID_OUT          => ID_OUT,
    sda             => sda,
    scl             => scl
  );

process begin
  wait until rising_edge(clk);
  count <= count + 1;
  if (count=133_000_000) then
    temporal <= NOT(temporal);
    count<=0;
  end if;
end process;  
reset <= temporal;



end Behavioral;
