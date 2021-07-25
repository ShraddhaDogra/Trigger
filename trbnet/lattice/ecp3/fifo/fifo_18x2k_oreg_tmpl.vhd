-- VHDL module instantiation generated by SCUBA Diamond_1.3_Production (92)
-- Module  Version: 4.8
-- Mon Sep 12 17:41:47 2011

-- parameterized module component declaration
component fifo_18x2k_oreg
    port (Data: in  std_logic_vector(17 downto 0); Clock: in  std_logic; 
        WrEn: in  std_logic; RdEn: in  std_logic; Reset: in  std_logic; 
        AmFullThresh: in  std_logic_vector(10 downto 0); 
        Q: out  std_logic_vector(17 downto 0); 
        WCNT: out  std_logic_vector(11 downto 0); Empty: out  std_logic; 
        Full: out  std_logic; AlmostFull: out  std_logic);
end component;

-- parameterized module component instance
__ : fifo_18x2k_oreg
    port map (Data(17 downto 0)=>__, Clock=>__, WrEn=>__, RdEn=>__, 
        Reset=>__, AmFullThresh(10 downto 0)=>__, Q(17 downto 0)=>__, 
        WCNT(11 downto 0)=>__, Empty=>__, Full=>__, AlmostFull=>__);
