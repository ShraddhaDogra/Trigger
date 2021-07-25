library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;

package lattice_ecp2m_fifo is


component fifo_19x16 is
    port (
        Data: in  std_logic_vector(18 downto 0); 
        Clock: in  std_logic; 
        WrEn: in  std_logic; 
        RdEn: in  std_logic; 
        Reset: in  std_logic; 
        Q: out  std_logic_vector(18 downto 0); 
        WCNT: out  std_logic_vector(4 downto 0); 
        Empty: out  std_logic; 
        Full: out  std_logic; 
        AlmostFull: out  std_logic);
end component;

  component fifo_var_oreg is
    generic(
      FIFO_WIDTH                   : integer range 1 to 64 := 36;
      FIFO_DEPTH                   : integer range 1 to 16 := 8
      );
    port(
      Data                         : in  std_logic_vector(FIFO_WIDTH-1 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(FIFO_DEPTH-1 downto 0);
      Q                            : out std_logic_vector(FIFO_WIDTH-1 downto 0);
      WCNT                         : out std_logic_vector(FIFO_DEPTH downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;

  component fifo_36x256_oreg
    port (
      Data                         : in  std_logic_vector(35 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(7 downto 0);
      Q                            : out std_logic_vector(35 downto 0);
      WCNT                         : out std_logic_vector(8 downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;



  component fifo_36x512_oreg
    port (
      Data                         : in  std_logic_vector(35 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(8 downto 0);
      Q                            : out std_logic_vector(35 downto 0);
      WCNT                         : out std_logic_vector(9 downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;



  component fifo_36x1k_oreg
    port (
      Data                         : in  std_logic_vector(35 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(9 downto 0);
      Q                            : out std_logic_vector(35 downto 0);
      WCNT                         : out std_logic_vector(10 downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;



  component fifo_36x2k_oreg
    port (
      Data                         : in  std_logic_vector(35 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(10 downto 0);
      Q                            : out std_logic_vector(35 downto 0);
      WCNT                         : out std_logic_vector(11 downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;



  component fifo_36x4k_oreg
    port (
      Data                         : in  std_logic_vector(35 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(11 downto 0);
      Q                            : out std_logic_vector(35 downto 0);
      WCNT                         : out std_logic_vector(12 downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;



  component fifo_36x8k_oreg
    port (
      Data                         : in  std_logic_vector(35 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(12 downto 0);
      Q                            : out std_logic_vector(35 downto 0);
      WCNT                         : out std_logic_vector(13 downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;



  component fifo_36x16k_oreg
    port (
      Data                         : in  std_logic_vector(35 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(13 downto 0);
      Q                            : out std_logic_vector(35 downto 0);
      WCNT                         : out std_logic_vector(14 downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;


  component fifo_36x32k_oreg
    port (
      Data                         : in  std_logic_vector(35 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(14 downto 0);
      Q                            : out std_logic_vector(35 downto 0);
      WCNT                         : out std_logic_vector(14 downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;


  component fifo_18x256_oreg
    port (
      Data                         : in  std_logic_vector(17 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(7 downto 0);
      Q                            : out std_logic_vector(17 downto 0);
      WCNT                         : out std_logic_vector(8 downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;



  component fifo_18x512_oreg
    port (
      Data                         : in  std_logic_vector(17 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(8 downto 0);
      Q                            : out std_logic_vector(17 downto 0);
      WCNT                         : out std_logic_vector(9 downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;



  component fifo_18x1k_oreg
    port (
      Data                         : in  std_logic_vector(17 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(9 downto 0);
      Q                            : out std_logic_vector(17 downto 0);
      WCNT                         : out std_logic_vector(10 downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;



  component fifo_18x2k_oreg
    port (
      Data                         : in  std_logic_vector(17 downto 0);
      Clock                        : in  std_logic;
      WrEn                         : in  std_logic;
      RdEn                         : in  std_logic;
      Reset                        : in  std_logic;
      AmFullThresh                 : in  std_logic_vector(10 downto 0);
      Q                            : out std_logic_vector(17 downto 0);
      WCNT                         : out std_logic_vector(11 downto 0);
      Empty                        : out std_logic;
      Full                         : out std_logic;
      AlmostFull                   : out std_logic
      );
  end component;



  component fifo_18x16_media_interface is
    port (
      Data: in  std_logic_vector(17 downto 0);
      Clock: in  std_logic;
      WrEn: in  std_logic;
      RdEn: in  std_logic;
      Reset: in  std_logic;
      Q: out  std_logic_vector(17 downto 0);
      WCNT: out  std_logic_vector(4 downto 0);
      Empty: out  std_logic;
      Full: out  std_logic;
      AlmostEmpty: out  std_logic
      );
  end component;

  component fifo_19x16_obuf is
      port (
          Data: in  std_logic_vector(18 downto 0);
          Clock: in  std_logic;
          WrEn: in  std_logic;
          RdEn: in  std_logic;
          Reset: in  std_logic;
          AmEmptyThresh: in  std_logic_vector(3 downto 0);
          AmFullThresh: in  std_logic_vector(3 downto 0);
          Q: out  std_logic_vector(18 downto 0);
          Empty: out  std_logic;
          Full: out  std_logic;
          AlmostEmpty: out  std_logic;
          AlmostFull: out  std_logic);
  end component;



end package;
