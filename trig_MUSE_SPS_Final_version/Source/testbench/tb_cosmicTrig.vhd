library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity tb_cosmicTrig is  -- Name of tb entity
--  Port ( );
end tb_cosmicTrig;

architecture archDB of tb_cosmicTrig is  -- architechture name of tb entity.
--Component name and original_entity's name must be the same
--ports must be same 
component Cos_or_all is
--port(
  --   CLK_PCLK_RIGHT: in std_logic;
	-- INP : in std_logic_vector (47 downto 0);
	 --OutpA: out std_logic;
	-- OutpB :out std_logic;
--	 OutpC :out std_logic;
	-- LED_GREEN :out std_logic;
	  --LED_ORANGE :out std_logic;
	 -- LED_RED :out std_logic;
	 -- LED_YELLOW :out std_logic;
	 -- trig_mask :out std_logic;
	  --trig_out_OR :out std_logic;
	 -- trig_out_dir :out std_logic;
	 -- trig_out_lat :out std_logic;
	 --- trig_out_50ns_lat :out std_logic;
	 -- trig_out_150ns_lat:out std_logic);
	  port(
	  in_clk: in std_logic;
	  in_front_bars: in std_logic_vector (17 downto 0);
	  in_back_bars: in std_logic_vector (27 downto 0);
	  out_cos_or_all: out std_logic);
end component;

--inputs and outputs for itb_module the names are different from module I/p and O/p.
--signal tb_res: std_logic_vector(7 downto 0):=(others=> '0');

signal tb_In_front: std_logic_vector (17 downto 0):=(others=> '0');
signal tb_In_back: std_logic_vector (27 downto 0):=(others=> '0');

signal tb_clk: std_logic:='0';
signal tb_Out: std_logic:='0';


begin
-- we assign actual module I/P, O/P => tb_module I/P, O/P.
test_name: Cos_or_all PORT MAP(in_clk => tb_clk, in_front_bars => tb_In_front, in_back_bars =>tb_In_back,
                       out_cos_or_all=>tb_Out);
					   
tb_clk <= not tb_clk after 5ns;

stim_proc:process
begin

wait for 40ns;

tb_In_front(0) <='1';
wait for 10ns;

tb_In_front(0)<= '0';
wait for 80ns;

tb_In_back(2)<= '1';
wait for 50ns;

tb_In_back(2)<= '0';
wait for 50ns;

tb_In_front(2)<= '1';
wait for 10ns;

tb_In_front(2)<= '0';
wait for 83ns;

tb_In_front(0)<= '1';
wait for 13ns;

tb_In_front(0)<= '0';
wait for 50ns;

tb_In_front(0) <='1';
wait for 10ns;

tb_In_front(0)<= '0';
wait for 80ns;

tb_In_back(2)<= '1';
wait for 10ns;

tb_In_back(2)<= '0';
wait for 83ns;

tb_In_back(0)<= '1';
wait for 13ns;

tb_In_back(0)<= '0';
wait for 50ns;



--tb_In(0)<= '1';
--wait for 5ns;

--tb_In(5)<= '1';
--wait for 5ns;

--tb_In(5)<= '0';
--wait for 30ns;

--tb_In(5)<='0';
--wait for 30ns;

--tb_clk <='0';  --wait for 5ns; 

--tb_In(5) <='1';


end process;
end archDB;