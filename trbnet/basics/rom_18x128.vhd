LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity rom_18x128 is
  generic(
    DATA_MEM_SIZE : integer := 16*128;
    DATA : std_logic_vector(16*128-1 downto 0) := 
              x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000"
            & x"0000_0000_0000_0000";

    PARITY_BIT0 : std_logic_vector(127 downto 0) := x"00100000000000000000000000000000";     
    PARITY_BIT1 : std_logic_vector(127 downto 0) := x"00100000000000000000000000000000"
    );
  port(
    CLK      : in  std_logic;
    ADDR_IN  : in  std_logic_vector(6 downto 0);
    READ_IN  : in  std_logic;
    DATA_OUT : out std_logic_vector(17 downto 0)
    );
end entity;

architecture rom_18x128_arch of rom_18x128 is
    type memory_cell is array(0 to 127) of std_logic_vector(17 downto 0);
    signal memory : memory_cell;

begin

MAPPING: process(CLK)
  variable place : integer;  -- place is between 0 and 127 pointing at the cell in memory
  begin
  for row in DATA_MEM_SIZE/64 downto 1 loop
    for cell in 1 to 4 loop
      place := (row*4)-cell;
--			if ( cell = 4 ) then
				memory( place ) <= PARITY_BIT1(place)
												 & PARITY_BIT0(place)
												 & DATA( ((place+1)*16)-1  downto  place*16 );
--		  else
--		  	memory( place ) <= "00" & INPUT( ((place+1)*16)-1  downto  place*16 );
-- 			end if;                  
	  end loop;
	end loop;
  end process;


  process(CLK)
    begin
      if rising_edge(CLK) then
        if (READ_IN='1') then
          DATA_OUT <= memory(conv_integer(ADDR_IN));
        end if;
      end if;
    end process;

end architecture;