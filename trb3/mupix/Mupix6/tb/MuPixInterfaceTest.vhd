------------------------------------------------------------
--! @file
--! @brief Testbench for readout of Mupix 3-6
--! @author Tobias Weber
--! @date August 2017
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.StdTypes.all;
use work.TRBSimulationPkg.all;

entity MuPixInterfaceTest is
end entity MuPixInterfaceTest;

architecture simulation of MuPixInterfaceTest is
	
	component mupix_interface
		port(
			rst                  : in  std_logic;
			clk                  : in  std_logic;
			mupixcontrol         : out MupixReadoutCtrl;
			mupixreadout         : in  MupixReadoutData;
			memdata              : out std_logic_vector(31 downto 0);
			memwren              : out std_logic;
			endofevent           : out std_logic;
			ro_busy              : out std_logic;
			trigger_ext          : in  std_logic;
			timestampreset_in    : in  std_logic;
			eventcounterreset_in : in  std_logic;
			SLV_READ_IN          : in  std_logic;
			SLV_WRITE_IN         : in  std_logic;
			SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
			SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
			SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
			SLV_ACK_OUT          : out std_logic;
			SLV_NO_MORE_DATA_OUT : out std_logic;
			SLV_UNKNOWN_ADDR_OUT : out std_logic
		);
	end component mupix_interface;
	
	constant clk_period : time := 10 ns;
	
	signal rst : std_logic := '0';
	signal clk : std_logic := '0';
	signal trigger_ext : std_logic := '0';
	signal timestampreset_in : std_logic := '0';
	signal eventcounterreset_in : std_logic := '0';
	signal SLV_READ_IN : std_logic := '0';
	signal SLV_WRITE_IN : std_logic := '0';
	signal SLV_DATA_IN : std_logic_vector(31 downto 0) := (others => '0');
	signal SLV_ADDR_IN : std_logic_vector(15 downto 0) := (others => '0');
	
	signal mupixcontrol : MupixReadoutCtrl;
	signal mupixreadout : MupixReadoutData;
	signal memdata : std_logic_vector(31 downto 0);
	signal memwren : std_logic;
	signal endofevent : std_logic;
	signal ro_busy : std_logic;
	signal SLV_DATA_OUT : std_logic_vector(31 downto 0);
	signal SLV_ACK_OUT : std_logic;
	signal SLV_NO_MORE_DATA_OUT : std_logic;
	signal SLV_UNKNOWN_ADDR_OUT : std_logic;
	
begin
	
	DUT:entity work.mupix_interface
		port map(
			rst                  => rst,
			clk                  => clk,
			mupixcontrol         => mupixcontrol,
			mupixreadout         => mupixreadout,
			memdata              => memdata,
			memwren              => memwren,
			endofevent           => endofevent,
			ro_busy              => ro_busy,
			trigger_ext          => trigger_ext,
			timestampreset_in    => timestampreset_in,
			eventcounterreset_in => eventcounterreset_in,
			SLV_READ_IN          => SLV_READ_IN,
			SLV_WRITE_IN         => SLV_WRITE_IN,
			SLV_DATA_OUT         => SLV_DATA_OUT,
			SLV_DATA_IN          => SLV_DATA_IN,
			SLV_ADDR_IN          => SLV_ADDR_IN,
			SLV_ACK_OUT          => SLV_ACK_OUT,
			SLV_NO_MORE_DATA_OUT => SLV_NO_MORE_DATA_OUT,
			SLV_UNKNOWN_ADDR_OUT => SLV_UNKNOWN_ADDR_OUT
		);
		
	clock_gen : process is
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process clock_gen;
			
	--TODO: test cases: generate hit, generate hits, generate triggered hits, reset event counter, 
	--read man mupix, read mupix triggered
	dut_stimulus : process is
	begin
		mupixreadout.hit_col <= (others => '0');
		mupixreadout.hit_row <= (others => '0');
		mupixreadout.hit_time <= (others => '0');
		mupixreadout.priout <= '0';
		wait for 100 ns;
		--generate hit
		TRBRegisterWrite(slv_write_in, slv_data_in, slv_addr_in, 
			std_logic_vector(to_unsigned(5, 16)) & std_logic_vector(to_unsigned(32, 16)), x"0500");
		if endofevent = '0' then
			wait until endofevent ='1';
			wait for 2*clk_period;
		end if;
		--generate hits: set wait time and start hit generation
		TRBRegisterWrite(slv_write_in, slv_data_in, slv_addr_in, 
			std_logic_vector(to_unsigned(10, 32)), x"0503");
		TRBRegisterWrite(slv_write_in, slv_data_in, slv_addr_in, 
			std_logic_vector(to_unsigned(5, 16)) & std_logic_vector(to_unsigned(64, 16)), x"0500");	
		--let it run for 600 ns and then stop generation
		wait for 600 ns;
		TRBRegisterWrite(slv_write_in, slv_data_in, slv_addr_in, 
			std_logic_vector(to_unsigned(5, 16)) & std_logic_vector(to_unsigned(0, 16)), x"0500");
		if endofevent = '0' then
			wait until endofevent ='1';
			wait for 2*clk_period;
		end if;
		--try hit generation after trigger
		wait for 2*clk_period;
		TRBRegisterWrite(slv_write_in, slv_data_in, slv_addr_in, 
			std_logic_vector(to_unsigned(5, 16)) & std_logic_vector(to_unsigned(257, 16)), x"0500");
		wait for 5*clk_period;
		trigger_ext <= '1';
		wait for 2*clk_period;
		trigger_ext <= '0';
		if endofevent = '0' then
			wait until endofevent ='1';
			wait for 2*clk_period;
		end if;
		--reset event counter before testing mupix readout state machine
		eventcounterreset_in <= '1';
		wait for clk_period;
		eventcounterreset_in <= '0';
		--setup chip readout (pause and delay registers)
		TRBRegisterWrite(slv_write_in, slv_data_in, slv_addr_in, 
			std_logic_vector(to_unsigned(5, 8)) & std_logic_vector(to_unsigned(5, 8)) 
			& std_logic_vector(to_unsigned(5, 8)) & std_logic_vector(to_unsigned(5, 8)), x"0504");
		TRBRegisterWrite(slv_write_in, slv_data_in, slv_addr_in, 
			std_logic_vector(to_unsigned(5, 8)) & std_logic_vector(to_unsigned(5, 8)) 
			& std_logic_vector(to_unsigned(5, 8)) & std_logic_vector(to_unsigned(5, 8)), x"0507");
		TRBRegisterWrite(slv_write_in, slv_data_in, slv_addr_in, 
						 x"00000006", x"0506");
		--read now
		TRBRegisterWrite(slv_write_in, slv_data_in, slv_addr_in, 
						 std_logic_vector(to_unsigned(5, 16)) & std_logic_vector(to_unsigned(4, 16)), x"0500");
		wait for 5*clk_period;
		--continous readout
		if endofevent = '0' then
			wait until endofevent ='1';
			wait for 2*clk_period;
		end if;
		wait for 5*clk_period;
		TRBRegisterWrite(slv_write_in, slv_data_in, slv_addr_in, 
						 std_logic_vector(to_unsigned(5, 16)) & std_logic_vector(to_unsigned(2, 16)), x"0500");
		wait for 600 ns;
		TRBRegisterWrite(slv_write_in, slv_data_in, slv_addr_in, 
						 std_logic_vector(to_unsigned(5, 16)) & std_logic_vector(to_unsigned(0, 16)), x"0500");
		--triggered readout test
		wait for 400 ns;
		TRBRegisterWrite(slv_write_in, slv_data_in, slv_addr_in, 
						 std_logic_vector(to_unsigned(5, 16)) & std_logic_vector(to_unsigned(1, 16)), x"0500");
		wait for 5*clk_period;
		trigger_ext <= '1';
		wait for clk_period;
		trigger_ext <= '0';
		wait;		
	end process dut_stimulus;
	
	
end architecture simulation;
