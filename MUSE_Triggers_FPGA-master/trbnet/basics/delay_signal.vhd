library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


library work;
use work.trb_net_std.all;

-- minimum allowed delay is 2
-- maximum delay will be 2**MAX_DELAY-1
-- actual delay is DELAY_IN * clock cycles
-- when changing DELAY_IN, output will be not valid for DELAY_IN+2 clock cycles


entity delay_signal is
  generic(
    INPUT_WIDTH : integer range 1 to 64 := 8;
    MAX_DELAY   : integer range 2 to 12 := 10
    );
  port(
    CLOCK_IN           : in  std_logic;
    CLOCK_EN_IN        : in  std_logic;
    INPUT_IN           : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    OUTPUT_OUT         : out std_logic_vector(INPUT_WIDTH-1 downto 0);
    DELAY_IN           : in  std_logic_vector(MAX_DELAY-1 downto 0)
    );
end entity;


architecture arch of delay_signal is

type ram_t is array((2**MAX_DELAY)-1 downto 0) of std_logic_vector(INPUT_WIDTH-1 downto 0);
signal ram         : ram_t;
signal wr_cnt      : unsigned(MAX_DELAY-1 downto 0) := (others => '0');
signal rd_cnt      : unsigned(MAX_DELAY-1 downto 0) := (others => '0');
signal delay_i     : unsigned(MAX_DELAY-1 downto 0) := (others => '0');


begin

 WR_PROC : process(CLOCK_IN)
   begin
     if rising_edge(CLOCK_IN) then
       if CLOCK_EN_IN = '1' then
         wr_cnt                  <= wr_cnt + to_unsigned(1,1);
         ram(to_integer(wr_cnt)) <= INPUT_IN;
         OUTPUT_OUT              <= ram(to_integer(rd_cnt));
         delay_i                 <= unsigned(DELAY_IN);
         rd_cnt                  <= wr_cnt - delay_i + to_unsigned(2,MAX_DELAY);
       end if;
     end if;
   end process;

end architecture;