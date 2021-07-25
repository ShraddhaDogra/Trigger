library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  

entity double_edge_detection is
end entity;



architecture arch of double_edge_detection is
  constant CHANNELS :integer := 1;

  signal CLK : std_logic := '1';
  
  signal found_double    : std_logic := '0';


  signal reg_INP, INP, INP_b, reg2_INP, reg3_INP, INP_long        : std_logic := '0';
  signal INP_low, reg_INP_low, reg2_INP_low   : std_logic := '0';
  signal INP_low_long, reg_INP_low_long       : std_logic := '0';
  signal reset_found : std_logic := '0';
  

begin

CLK <= not CLK after 5 ns;

PROC_STIM : process begin
  INP <= '0';  wait for 105.3 ns;
  INP <= '1';  wait for 1 ns;
  INP <= '0';  wait for 1 ns;
  INP <= '1';  wait for 1 ns;
  INP <= '0';
  wait for 101 ns;

end process;
  
-- THE_DETECT : process begin
--   wait until rising_edge(CLK);
--     if (reg_INP = '1') and reg_INP_low_long = '1' then
--       found_double <= '1';
--     else
--       found_double <= '0';
--     end if;  
-- end process;
-- 
-- 
-- 
-- INP_b    <= (INP or INP_b) and not reg_INP;
-- reg_INP  <= INP_b      when rising_edge(CLK);
-- reg2_INP <= reg_INP    when rising_edge(CLK);
-- -- reg3_INP_b <= reg2_INP_b when rising_edge(CLK);
-- -- INP_long   <= reg3_INP_b or reg2_INP_b or reg_INP_b or INP_b;
-- 
-- INP_low      <= (not INP and reg_INP) or (INP_low  and not reg_INP_low);
-- 
-- reg_INP_low  <= INP_low     when rising_edge(CLK);
-- reg2_INP_low <= reg_INP_low when rising_edge(CLK);
-- INP_low_long <= INP_low or reg_INP_low or reg2_INP_low;
-- reg_INP_low_long <= INP_low_long when rising_edge(CLK);
-- 

INP_b    <= (INP or INP_b) and not reg_INP;
reg_INP  <= INP_b      when rising_edge(CLK);
reg2_INP <= reg_INP    when rising_edge(CLK);
reg3_INP <= reg2_INP when rising_edge(CLK);
INP_long   <= reg3_INP or reg2_INP or reg_INP or INP_b;

THE_DETECT : process(reset_found, INP) begin
  if reset_found = '1' then
    found_double <= '0';
  elsif rising_edge(INP) and INP_long = '1' then
    found_double <= '1';
  end if;  
end process;

reset_found <= found_double when rising_edge(CLK);

end architecture;
