-- VHDL module instantiation generated by SCUBA Diamond_1.3_Production (92)
-- Module  Version: 4.8
-- Mon Sep 12 17:44:27 2011

-- parameterized module component declaration
component fifo_36x512_oreg
    port (Data: in  std_logic_vector(35 downto 0); Clock: in  std_logic; 
        WrEn: in  std_logic; RdEn: in  std_logic; Reset: in  std_logic; 
        AmFullThresh: in  std_logic_vector(8 downto 0); 
        Q: out  std_logic_vector(35 downto 0); 
        WCNT: out  std_logic_vector(9 downto 0); Empty: out  std_logic; 
        Full: out  std_logic; AlmostFull: out  std_logic);
end component;

-- parameterized module component instance
__ : fifo_36x512_oreg
    port map (Data(35 downto 0)=>__, Clock=>__, WrEn=>__, RdEn=>__, 
        Reset=>__, AmFullThresh(8 downto 0)=>__, Q(35 downto 0)=>__, 
        WCNT(9 downto 0)=>__, Empty=>__, Full=>__, AlmostFull=>__);
