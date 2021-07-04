library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_32bit is
port (input 		: in std_logic;
	  reset 		: in std_logic;
	  write_enable	: in std_logic;
      count 		: out std_logic_vector(31 downto 0)  --output of the design. 4 bit count value.
     );
end counter_32bit;

architecture behavioral of counter_32bit is

--initializing the count to zero.
signal c : unsigned(31 downto 0) :=(others => '0');  

begin

count <= std_logic_vector(c);

process(input,reset, write_enable)
begin
    if(reset = '1') then    --active high reset for the counter.
        c <= (others => '0');
    elsif(rising_edge(input)) then
    -- when count reaches its maximum reset it to 0
        if(write_enable = '1') then
            c <= c + 1;
        else    
            c <= (others => '0'); -- keep counter to be '0' if not write_enable 
        end if;
    end if; 
end process;

end behavioral;