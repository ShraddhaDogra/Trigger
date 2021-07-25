library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.lattice_ecp2m_fifo.all;

entity fifo_var_oreg is
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
end entity;

architecture fifo_var_oreg_arch of fifo_var_oreg is

begin

  assert    (FIFO_DEPTH >= 8 and FIFO_DEPTH <= 15 and FIFO_WIDTH = 36)
         or (FIFO_DEPTH >= 8 and FIFO_DEPTH <= 11 and FIFO_WIDTH = 18)
         report "Selected data buffer size not implemented: depth - "&integer'image(FIFO_DEPTH)& ", width + 4 : " &integer'image(FIFO_WIDTH) severity error;

  gen_36_256 : if FIFO_WIDTH = 36 and FIFO_DEPTH = 8  generate
    THE_FIFO :  fifo_36x256_oreg
      port map(
        Data                   =>  Data,
        Clock                  =>  Clock,
        WrEn                   =>  WrEn,
        RdEn                   =>  RdEn,
        Reset                  =>  Reset,
        AmFullThresh           =>  AmFullThresh,
        Q                      =>  Q,
        WCNT                   =>  WCNT,
        Empty                  =>  Empty,
        Full                   =>  Full,
        AlmostFull             =>  AlmostFull
        );
  end generate;

  gen_36_512 : if FIFO_WIDTH = 36 and FIFO_DEPTH = 9  generate
    THE_FIFO :  fifo_36x512_oreg
      port map(
        Data                   =>  Data,
        Clock                  =>  Clock,
        WrEn                   =>  WrEn,
        RdEn                   =>  RdEn,
        Reset                  =>  Reset,
        AmFullThresh           =>  AmFullThresh,
        Q                      =>  Q,
        WCNT                   =>  WCNT,
        Empty                  =>  Empty,
        Full                   =>  Full,
        AlmostFull             =>  AlmostFull
        );
  end generate;


  gen_36_1k : if FIFO_WIDTH = 36 and FIFO_DEPTH = 10  generate
    THE_FIFO :  fifo_36x1k_oreg
      port map(
        Data                   =>  Data,
        Clock                  =>  Clock,
        WrEn                   =>  WrEn,
        RdEn                   =>  RdEn,
        Reset                  =>  Reset,
        AmFullThresh           =>  AmFullThresh,
        Q                      =>  Q,
        WCNT                   =>  WCNT,
        Empty                  =>  Empty,
        Full                   =>  Full,
        AlmostFull             =>  AlmostFull
        );
  end generate;


  gen_36_2k : if FIFO_WIDTH = 36 and FIFO_DEPTH = 11  generate
    THE_FIFO :  fifo_36x2k_oreg
      port map(
        Data                   =>  Data,
        Clock                  =>  Clock,
        WrEn                   =>  WrEn,
        RdEn                   =>  RdEn,
        Reset                  =>  Reset,
        AmFullThresh           =>  AmFullThresh,
        Q                      =>  Q,
        WCNT                   =>  WCNT,
        Empty                  =>  Empty,
        Full                   =>  Full,
        AlmostFull             =>  AlmostFull
        );
  end generate;


  gen_36_4k : if FIFO_WIDTH = 36 and FIFO_DEPTH = 12  generate
    THE_FIFO :  fifo_36x4k_oreg
      port map(
        Data                   =>  Data,
        Clock                  =>  Clock,
        WrEn                   =>  WrEn,
        RdEn                   =>  RdEn,
        Reset                  =>  Reset,
        AmFullThresh           =>  AmFullThresh,
        Q                      =>  Q,
        WCNT                   =>  WCNT,
        Empty                  =>  Empty,
        Full                   =>  Full,
        AlmostFull             =>  AlmostFull
        );
  end generate;


  gen_36_8k : if FIFO_WIDTH = 36 and FIFO_DEPTH = 13  generate
    THE_FIFO :  fifo_36x8k_oreg
      port map(
        Data                   =>  Data,
        Clock                  =>  Clock,
        WrEn                   =>  WrEn,
        RdEn                   =>  RdEn,
        Reset                  =>  Reset,
        AmFullThresh           =>  AmFullThresh,
        Q                      =>  Q,
        WCNT                   =>  WCNT,
        Empty                  =>  Empty,
        Full                   =>  Full,
        AlmostFull             =>  AlmostFull
        );
  end generate;


  gen_36_16k : if FIFO_WIDTH = 36 and FIFO_DEPTH = 14  generate
    THE_FIFO :  fifo_36x16k_oreg
      port map(
        Data                   =>  Data,
        Clock                  =>  Clock,
        WrEn                   =>  WrEn,
        RdEn                   =>  RdEn,
        Reset                  =>  Reset,
        AmFullThresh           =>  AmFullThresh,
        Q                      =>  Q,
        WCNT                   =>  WCNT,
        Empty                  =>  Empty,
        Full                   =>  Full,
        AlmostFull             =>  AlmostFull
        );
  end generate;


  gen_36_32k : if FIFO_WIDTH = 36 and FIFO_DEPTH = 15  generate
    THE_FIFO :  fifo_36x32k_oreg
      port map(
        Data                   =>  Data,
        Clock                  =>  Clock,
        WrEn                   =>  WrEn,
        RdEn                   =>  RdEn,
        Reset                  =>  Reset,
        AmFullThresh           =>  AmFullThresh,
        Q                      =>  Q,
        WCNT                   =>  WCNT,
        Empty                  =>  Empty,
        Full                   =>  Full,
        AlmostFull             =>  AlmostFull
        );
  end generate;




  gen_18_256 : if FIFO_WIDTH = 18 and FIFO_DEPTH = 8  generate
    THE_FIFO :  fifo_18x256_oreg
      port map(
        Data                   =>  Data,
        Clock                  =>  Clock,
        WrEn                   =>  WrEn,
        RdEn                   =>  RdEn,
        Reset                  =>  Reset,
        AmFullThresh           =>  AmFullThresh,
        Q                      =>  Q,
        WCNT                   =>  WCNT,
        Empty                  =>  Empty,
        Full                   =>  Full,
        AlmostFull             =>  AlmostFull
        );
  end generate;

  gen_18_512 : if FIFO_WIDTH = 18 and FIFO_DEPTH = 9  generate
    THE_FIFO :  fifo_18x512_oreg
      port map(
        Data                   =>  Data,
        Clock                  =>  Clock,
        WrEn                   =>  WrEn,
        RdEn                   =>  RdEn,
        Reset                  =>  Reset,
        AmFullThresh           =>  AmFullThresh,
        Q                      =>  Q,
        WCNT                   =>  WCNT,
        Empty                  =>  Empty,
        Full                   =>  Full,
        AlmostFull             =>  AlmostFull
        );
  end generate;


  gen_18_1k : if FIFO_WIDTH = 18 and FIFO_DEPTH = 10  generate
    THE_FIFO :  fifo_18x1k_oreg
      port map(
        Data                   =>  Data,
        Clock                  =>  Clock,
        WrEn                   =>  WrEn,
        RdEn                   =>  RdEn,
        Reset                  =>  Reset,
        AmFullThresh           =>  AmFullThresh,
        Q                      =>  Q,
        WCNT                   =>  WCNT,
        Empty                  =>  Empty,
        Full                   =>  Full,
        AlmostFull             =>  AlmostFull
        );
  end generate;


  gen_18_2k : if FIFO_WIDTH = 18 and FIFO_DEPTH = 11  generate
    THE_FIFO :  fifo_18x2k_oreg
      port map(
        Data                   =>  Data,
        Clock                  =>  Clock,
        WrEn                   =>  WrEn,
        RdEn                   =>  RdEn,
        Reset                  =>  Reset,
        AmFullThresh           =>  AmFullThresh,
        Q                      =>  Q,
        WCNT                   =>  WCNT,
        Empty                  =>  Empty,
        Full                   =>  Full,
        AlmostFull             =>  AlmostFull
        );
  end generate;





end architecture;