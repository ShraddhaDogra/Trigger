--Ievgen Lavrukhin: -------------------------------------------------------------
--Delay Signal for  number of clock cycles x 2 ----------------------------------
-- This is a copy of signal delay entity from TRB3 libraries:                  --
-- trb3/mupix/Mupix8/sources/SignalDelay.vhd								   --
-- except that it icrement delay cycle counter for both rising and faulign edge--
-- of clocks. That allows us to inclrement delay by 10 ns using 100MHz clocks   --
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity signalDelay is
  generic(
    Width : integer := 1;
    Delay : integer := 5  -- 2**Delay-1
    );
  port(
    clk_in   : in  std_logic;
    write_en_in : in  std_logic;
    delay_in : in  std_logic_vector(Delay - 1 downto 0);
    sig_in   : in  std_logic_vector(Width - 1 downto 0);
    sig_out  : out std_logic_vector(Width - 1 downto 0));
end entity;

architecture arch of signalDelay is

  signal writecounter : unsigned(Delay - 1 downto 0) := (others => '0');
  signal readcounter  : unsigned(Delay - 1 downto 0) := (others => '0');
  
  type memory_t is array((2**Delay) - 1 downto 0) of std_logic_vector(Width - 1 downto 0);
  signal memory       : memory_t;
  
begin

  DelayProc : process(clk_in)
  begin
    if (rising_edge(clk_in)) then
     if write_en_in = '1' then
       memory(to_integer(writecounter)) <= sig_in; 
       writecounter                     <= writecounter + 1;
       readcounter                      <= writecounter - unsigned(delay_in) + 2;
 --      readcounter                      <= writecounter - unsigned(delay_in);
     end if;
      sig_out                           <= memory(to_integer(readcounter));
    end if;
  end process DelayProc;

end architecture;