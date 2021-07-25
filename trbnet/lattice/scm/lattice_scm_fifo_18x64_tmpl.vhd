-- VHDL module instantiation generated by SCUBA ispLever_v70_Prod_Build (55)
-- Module  Version: 4.2
-- Fri Feb  8 13:40:40 2008

-- parameterized module component declaration
component lattice_scm_fifo_18x64
    port (Data: in  std_logic_vector(17 downto 0); 
        WrClock: in  std_logic; RdClock: in  std_logic; 
        WrEn: in  std_logic; RdEn: in  std_logic; Reset: in  std_logic; 
        RPReset: in  std_logic; Q: out  std_logic_vector(17 downto 0); 
        Empty: out  std_logic; Full: out  std_logic);
end component;

-- parameterized module component instance
__ : lattice_scm_fifo_18x64
    port map (Data(17 downto 0)=>__, WrClock=>__, RdClock=>__, WrEn=>__, 
        RdEn=>__, Reset=>__, RPReset=>__, Q(17 downto 0)=>__, Empty=>__, 
        Full=>__);
