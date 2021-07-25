library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity simpleupcounter_16bit is
    Port ( QOUT : out std_logic_vector(15 downto 0);
           UP : in std_logic;
           CLK : in std_logic;
           CLR : in std_logic);
end simpleupcounter_16bit;

architecture simpleupcounter_16bit of simpleupcounter_16bit is

signal counter: std_logic_vector (15 downto 0);

begin

  process (CLR, UP, CLK)

  begin
    if CLR = '1' then
      counter   <= "0000000000000000";
    elsif clk'event and clk = '1' then
     if  UP = '1' then
       counter <= counter + 1;
     else
       counter     <= counter;
  end if;
end if;
end process;

QOUT <= counter;

end simpleupcounter_16bit;
