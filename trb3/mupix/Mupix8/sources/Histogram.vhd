----------------------------------------------------------------------------
-- Histogram using block memory
-- Tobias Weber
-- Ruhr Unversitaet Bochum
-----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Histogram is
  generic (
    HistogramHeight : integer := 12;    -- Bin Height 2**HistogramHeight
    HistogramRange  : integer := 10);   -- Histogram Range 2**HistogramRange
  port (
    clk       : in  std_logic; --clock
    reset     : in  std_logic; --reset
    StartRun  : in  std_logic; --start acquiring data
    StartRd   : in  std_logic; --start reading the histogram
    ReadAddr  : in  std_logic_vector(HistogramRange - 1 downto 0); --read address
    Wr        : in  std_logic; --write enable
    BinSelect : in  std_logic_vector(HistogramRange - 1 downto 0); --select bin to write data
    DataValid : out std_logic; --output data is valid
    BinHeight : out std_logic_vector(HistogramHeight - 1 downto 0)); --value of bin at ReadAddr
end Histogram;

architecture Behavioral of Histogram is
	
  component BlockMemory
    generic (
      DataWidth    : integer;
      AddressWidth : integer);
    port (
      clk    : in  std_logic;
      WrEn   : in  std_logic;
      WrAddr : in  std_logic_vector(AddressWidth - 1 downto 0);
      Din    : in  std_logic_vector(DataWidth - 1 downto 0);
      ReAddr : in  std_logic_vector(AddressWidth - 1 downto 0);
      Dout   : out std_logic_vector(DataWidth - 1 downto 0));
  end component;

  type   Histo_fsm_type is (idle, WriteHisto, ReadHisto, WaitOnMem, Clear);
  signal Histo_fsm : Histo_fsm_type := idle;

  signal MemWrAddr : std_logic_vector(HistogramRange - 1 downto 0);
  signal MemRdAddr : std_logic_vector(HistogramRange - 1 downto 0);
  signal MemWrEn   : std_logic;
  signal MemDIn    : std_logic_vector(HistogramHeight - 1 downto 0);
  signal MemDOut   : std_logic_vector(HistogramHeight - 1 downto 0);

  signal bincounter : unsigned(HistogramRange - 1 downto 0);
  signal delcounter : integer range 0 to 1 := 0;
  signal Overflow   : std_logic            := '0';
  
begin

  BlockMemory_1 : BlockMemory
    generic map (
      DataWidth    => HistogramHeight,
      AddressWidth => HistogramRange)
    port map (
      clk    => clk,
      WrEn   => MemWrEn,
      WrAddr => MemWrAddr,
      Din    => MemDIn,
      ReAddr => MemRdAddr,
      Dout   => MemDOut);

  Histogram : process(clk)
  begin  -- process Histogram
    if rising_edge(clk) then
      case Histo_fsm is
        when idle =>
          bincounter <= (others => '0');
          MemRdAddr  <= (others => '0');
          MemWrAddr  <= (others => '0');
          MemDIn     <= (others => '0');
          MemWrEn    <= '0';
          DataValid  <= '0';
          if (Wr = '1' and StartRun = '1' and Overflow = '0') then
            Histo_fsm <= WriteHisto;
            MemRdAddr <= BinSelect;
          elsif StartRd = '1' then
            Histo_fsm <= WaitOnMem;
            MemRdAddr <= ReadAddr;
          elsif Reset = '1' then
            Histo_fsm <= Clear;
            Overflow  <= '0';
          else
        	Histo_fsm <= Idle;
          end if;
          
        when WriteHisto =>
          if delcounter = 1 then
            MemWrAddr  <= MemRdAddr;
            MemWrEn    <= '1';
            delcounter <= 0;
            Histo_fsm  <= idle;
            if to_integer(unsigned(MemDOut)) = 2**HistogramHeight - 1 then
              --Overflow detected stop writing histogram data
              MemDIn   <= MemDOut;
              Overflow <= '1';
            else
              MemDIn   <= std_logic_vector(unsigned(MemDOut) + 1);
              Overflow <= '0';
            end if;
          else
            delcounter <= delcounter + 1;  --one clk read delay of memory
          end if;

        when WaitOnMem =>
           Histo_fsm <= ReadHisto;
        	
        when ReadHisto =>
          BinHeight <= MemDOut;
          DataValid <= '1';
          Histo_fsm <= idle;
          
        when Clear =>
          bincounter <= bincounter + 1;
          MemWrAddr  <= std_logic_vector(bincounter);
          MemDIn     <= (others => '0');
          MemWrEn    <= '1';
          if to_integer(bincounter) = (2**HistogramRange - 1) then
            Histo_fsm <= idle;
          end if;
      end case;
    end if;
  end process Histogram;

end Behavioral;

