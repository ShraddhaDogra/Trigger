------------------------------------------------------------
--! @file
--! @brief Testbench for readout of Mupix 3-6
--! @author Tobias Weber
--! @date August 2017
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.TRBSimulationPkg.all;

entity HitbusHistogramTest is
end entity HitbusHistogramTest;
 
architecture simulation of HitbusHistogramTest is
	
	component HitbusHistogram
		generic(
			HistogramRange            : integer := 6;
			PostOscillationWaitCycles : integer := 5
		);
		port(
			clk                  : in  std_logic;
			hitbus               : in  std_logic;
			trigger              : in  std_logic;
			SLV_READ_IN          : in  std_logic;
			SLV_WRITE_IN         : in  std_logic;
			SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
			SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
			SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
			SLV_ACK_OUT          : out std_logic;
			SLV_NO_MORE_DATA_OUT : out std_logic;
			SLV_UNKNOWN_ADDR_OUT : out std_logic
		);
	end component HitbusHistogram;
	
	constant HistogramRange : integer := 6;
	constant PostOscillationWaitCycles : integer := 5;
	constant clk_period : time := 10 ns;
	
	signal clk          : std_logic := '0';
	signal hitbus       : std_logic := '0';
	signal trigger      : std_logic := '0';
	signal SLV_READ_IN  : std_logic := '0';
	signal SLV_WRITE_IN : std_logic := '0';
	signal SLV_DATA_IN  : std_logic_vector(31 downto 0) := (others => '0');
	signal SLV_ADDR_IN  : std_logic_vector(15 downto 0) := (others => '0');
	
	
	signal SLV_DATA_OUT         : std_logic_vector(31 downto 0);
	signal SLV_ACK_OUT          : std_logic;
	signal SLV_NO_MORE_DATA_OUT : std_logic;
	signal SLV_UNKNOWN_ADDR_OUT : std_logic;
	
	procedure HitbusEvent(signal hitbus, trigger : out std_logic;
		constant latency, tot1 : time;
		constant postoscillation, tot2 : time := 0 ns) is
	begin
		trigger <= '1';
		wait for latency;
		trigger <= '0';
		hitbus <= '1';
		wait for tot1;
		hitbus <= '0';
		if postoscillation > 0 ns then
			wait for postoscillation;
			hitbus <= '1';
			wait for tot2;
			hitbus <= '0';
		end if;
		wait for 200 ns;
	end procedure HitbusEvent;
	
	
begin
	
	HitbusHistogram_1 : entity work.HitbusHistogram
		generic map(
			HistogramRange            => HistogramRange,
			PostOscillationWaitCycles => PostOscillationWaitCycles
		)
		port map(
			clk                  => clk,
			hitbus               => hitbus,
			trigger              => trigger,
			SLV_READ_IN          => SLV_READ_IN,
			SLV_WRITE_IN         => SLV_WRITE_IN,
			SLV_DATA_OUT         => SLV_DATA_OUT,
			SLV_DATA_IN          => SLV_DATA_IN,
			SLV_ADDR_IN          => SLV_ADDR_IN,
			SLV_ACK_OUT          => SLV_ACK_OUT,
			SLV_NO_MORE_DATA_OUT => SLV_NO_MORE_DATA_OUT,
			SLV_UNKNOWN_ADDR_OUT => SLV_UNKNOWN_ADDR_OUT
		);
	
		clk_gen : process is
		begin
			clk <= '1';
			wait for clk_period/2;
			clk <= '0';
			wait for clk_period/2;
		end process clk_gen;
		
		stimulus : process is
		begin
			wait for 100 ns;
			TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"000000FF", x"0806");
			TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, std_logic_vector(to_unsigned(2, 32)), x"0800");
			for i in 0 to 5 loop
				HitbusEvent(hitbus, trigger, 50 ns, 100 ns);
			end loop;
			for i in 0 to 8 loop
				HitbusEvent(hitbus, trigger, 50 ns, 120 ns);
			end loop;
			HitbusEvent(hitbus, trigger, 50 ns, 100 ns, 20 ns, 30 ns);--test post-oscillation
			wait;
		end process stimulus;
		
	
end architecture simulation;
