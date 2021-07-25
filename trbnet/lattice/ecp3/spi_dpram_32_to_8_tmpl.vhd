-- VHDL module instantiation generated by SCUBA Diamond_1.3_Production (92)
-- Module  Version: 7.1
-- Mon Sep 12 17:36:12 2011

-- parameterized module component declaration
component spi_dpram_32_to_8
    port (DataInA: in  std_logic_vector(31 downto 0); 
        DataInB: in  std_logic_vector(7 downto 0); 
        AddressA: in  std_logic_vector(5 downto 0); 
        AddressB: in  std_logic_vector(7 downto 0); 
        ClockA: in  std_logic; ClockB: in  std_logic; 
        ClockEnA: in  std_logic; ClockEnB: in  std_logic; 
        WrA: in  std_logic; WrB: in  std_logic; ResetA: in  std_logic; 
        ResetB: in  std_logic; QA: out  std_logic_vector(31 downto 0); 
        QB: out  std_logic_vector(7 downto 0));
end component;

-- parameterized module component instance
__ : spi_dpram_32_to_8
    port map (DataInA(31 downto 0)=>__, DataInB(7 downto 0)=>__, 
        AddressA(5 downto 0)=>__, AddressB(7 downto 0)=>__, ClockA=>__, 
        ClockB=>__, ClockEnA=>__, ClockEnB=>__, WrA=>__, WrB=>__, ResetA=>__, 
        ResetB=>__, QA(31 downto 0)=>__, QB(7 downto 0)=>__);
