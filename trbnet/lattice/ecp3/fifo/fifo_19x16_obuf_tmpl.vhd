-- VHDL module instantiation generated by SCUBA Diamond_1.3_Production (92)
-- Module  Version: 4.8
-- Mon Sep 12 17:40:28 2011

-- parameterized module component declaration
component fifo_19x16_obuf
    port (Data: in  std_logic_vector(18 downto 0); Clock: in  std_logic; 
        WrEn: in  std_logic; RdEn: in  std_logic; Reset: in  std_logic; 
        AmFullThresh: in  std_logic_vector(3 downto 0); 
        Q: out  std_logic_vector(18 downto 0); 
        WCNT: out  std_logic_vector(4 downto 0); Empty: out  std_logic; 
        Full: out  std_logic; AlmostFull: out  std_logic);
end component;

-- parameterized module component instance
__ : fifo_19x16_obuf
    port map (Data(18 downto 0)=>__, Clock=>__, WrEn=>__, RdEn=>__, 
        Reset=>__, AmFullThresh(3 downto 0)=>__, Q(18 downto 0)=>__, 
        WCNT(4 downto 0)=>__, Empty=>__, Full=>__, AlmostFull=>__);
