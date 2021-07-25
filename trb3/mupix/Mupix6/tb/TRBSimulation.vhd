------------------------------------------------------------
--! @file
--! @brief Function and Procedures useful for TRB Simulation
--! @author Tobias Weber
--! @date August 2017
------------------------------------------------------------ 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package TRBSimulationPkg is
	
	procedure TRBRegisterWrite(signal SLV_Write : out std_logic;
		signal SLV_Data : out std_logic_vector(31 downto 0);
		signal SLV_Addr : out std_logic_vector(15 downto 0);
		constant data : in std_logic_vector(31 downto 0);
		constant addr : in std_logic_vector(15 downto 0);
		constant clk_period : in time := 10 ns);
		
	procedure TRBRegisterRead(signal SLV_Read : out std_logic;
		signal SLV_Data : out std_logic_vector(31 downto 0);
		signal SLV_Addr : out std_logic_vector(15 downto 0);
		constant data : in std_logic_vector(31 downto 0);
		constant addr : in std_logic_vector(15 downto 0);
		constant clk_period : in time := 10 ns);	
		
end package TRBSimulationPkg;

package body TRBSimulationPkg is

	procedure TRBRegisterWrite(signal SLV_Write : out std_logic;
		signal SLV_Data : out std_logic_vector(31 downto 0);
		signal SLV_Addr : out std_logic_vector(15 downto 0);
		constant data : in std_logic_vector(31 downto 0);
		constant addr : in std_logic_vector(15 downto 0);
		constant clk_period : in time := 10 ns) is
	begin
		SLV_Write <= '1';
		SLV_Data <= data;
		SLV_Addr <= addr;
		wait for clk_period;
		SLV_Write <= '0';
		SLV_Data <= (others => '0');
		SLV_Addr <= (others => '0');
		wait for clk_period;
	end TRBRegisterWrite;
	
	procedure TRBRegisterRead(signal SLV_Read : out std_logic;
		signal SLV_Data : out std_logic_vector(31 downto 0);
		signal SLV_Addr : out std_logic_vector(15 downto 0);
		constant data : in std_logic_vector(31 downto 0);
		constant addr : in std_logic_vector(15 downto 0);
		constant clk_period : in time := 10 ns) is
	begin
		SLV_Read <= '1';
		SLV_Data <= data;
		SLV_Addr <= addr;
		wait for clk_period;
		SLV_Read <= '0';
		SLV_Data <= (others => '0');
		SLV_Addr <= (others => '0');
		wait for clk_period;
	end procedure TRBRegisterRead;
	

end TRBSimulationPkg;