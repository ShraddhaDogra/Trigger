-------------------------------------------------------------------------------
--Histogramming of Hitbus for Time over Threshold and Latency Measurement
--Readout by TRB Slave Bus
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity HitbusHistogram is
  generic (
    HistogramRange : integer := 8;
    PostOscillationWaitCycles : integer := 5);
  port (
    clk                  : in  std_logic;
    hitbus               : in  std_logic;
    trigger              : in std_logic;  --Trigger from Laser or scintillator
    SLV_READ_IN          : in  std_logic;
    SLV_WRITE_IN         : in  std_logic;
    SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
    SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
    SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
    SLV_ACK_OUT          : out std_logic;
    SLV_NO_MORE_DATA_OUT : out std_logic;
    SLV_UNKNOWN_ADDR_OUT : out std_logic
    );
end HitbusHistogram;

architecture Behavioral of HitbusHistogram is

  component Histogram
    generic (
      HistogramHeight : integer;
      HistogramRange  : integer);
    port (
      clk       : in  std_logic;
      reset     : in  std_logic;
      StartRun  : in  std_logic;
      StartRd   : in  std_logic;
      ReadAddr  : in  std_logic_vector(HistogramRange - 1 downto 0);
      Wr        : in  std_logic;
      BinSelect : in  std_logic_vector(HistogramRange - 1 downto 0);
      DataValid : out std_logic;
      BinHeight : out std_logic_vector(HistogramHeight - 1 downto 0));
  end component;

  component SignalDelay is
    generic (
      Width : integer;
      Delay : integer);
    port (
      clk_in   : in  std_logic;
      write_en_in : in std_logic;
      delay_in : in  std_logic_vector(Delay - 1 downto 0);
      sig_in   : in  std_logic_vector(Width - 1 downto 0);
      sig_out  : out std_logic_vector(Width - 1 downto 0));
  end component SignalDelay;

  signal hitbus_i : std_logic_vector(1 downto 0);
  signal trigger_i : std_logic_vector(1 downto 0);

  --ToT Histogram
  type   hithisto_fsm_type is (idle, hitbus_high, wait_for_postOscillation);
  signal hithisto_fsm       : hithisto_fsm_type := idle;
  signal hitbus_counter     : unsigned(HistogramRange - 1 downto 0);  --duration of hitbus high
  signal postOscillationCounter : unsigned(HistogramRange - 1 downto 0);
  signal hitbus_HistoWrAddr : std_logic_vector(HistogramRange - 1 downto 0);
  signal hitbus_WriteBin    : std_logic;
  signal hitbus_BinValue    : std_logic_vector(15 downto 0);


  --Latency Histogram
  type   latency_fsm_type is (idle, waitforhitbus);
  signal latency_fsm         : latency_fsm_type      := idle;
  signal latency_counter     : unsigned(HistogramRange - 1 downto 0);  --duration of hitbus high
  signal latency_HistoWrAddr : std_logic_vector(HistogramRange - 1 downto 0);
  signal latency_WriteBin    : std_logic;
  signal latency_BinValue    : std_logic_vector(15 downto 0);


  --Histogram Ctrl
  signal histo_ctrl        : std_logic_vector(31 downto 0)         := (others => '0');
  signal histvalue         : std_logic_vector(31 downto 0);
  signal histvalue_valid   : std_logic;
  signal ReadAddr_i        : std_logic_vector(HistogramRange - 1 downto 0);
  signal ReadHisto         : std_logic                             := '0';
  signal reading_histo_mem : std_logic                             := '0';  --read in progress
  signal readcounter       : unsigned(HistogramRange - 1 downto 0) := (others => '0');
  signal hitbus_wait       : unsigned(HistogramRange - 1 downto 0) := (others => '0'); 
  
  signal hitbus_delayed : std_logic;
    
    
begin

  Histogram_1 : Histogram
    generic map (
      HistogramHeight => 16,  --change Max Height of Histogrambin here
      HistogramRange  => HistogramRange)
    port map (
      clk       => clk,
      reset     => histo_ctrl(2),
      StartRun  => histo_ctrl(1),
      StartRd   => ReadHisto,
      ReadAddr  => ReadAddr_i,
      Wr        => hitbus_WriteBin,
      BinSelect => hitbus_HistoWrAddr,
      DataValid => histvalue_valid,
      BinHeight => hitbus_BinValue);

  Histogram_2 : Histogram
    generic map (
      HistogramHeight => 16,
      HistogramRange  => HistogramRange)
    port map (
      clk       => clk,
      reset     => histo_ctrl(2),
      StartRun  => histo_ctrl(1),
      StartRd   => ReadHisto,
      ReadAddr  => ReadAddr_i,
      Wr        => latency_WriteBin,
      BinSelect => latency_HistoWrAddr,
      DataValid => open,
      BinHeight => latency_BinValue);
      
  SignalDelay_1: entity work.SignalDelay
    generic map (
      Width => 1,
      Delay => 5)
    port map (
      clk_in      => clk,
      write_en_in => '1',
      delay_in    => std_logic_vector(to_unsigned(5, 5)),
      sig_in(0)   => hitbus,
      sig_out(0)  => hitbus_delayed);    

  -- purpose: hitbus and trigger edge detect
  hitbus_edge_proc: process (clk) is
  begin  -- process hitbus_edge_proc
    if rising_edge(clk) then
      hitbus_i <= hitbus_i(0) & hitbus_delayed;
      trigger_i <= trigger_i(0) & trigger;
    end if;
  end process hitbus_edge_proc;
  
  -----------------------------------------------------------------------------
  --Time over Threshold histogram
  -----------------------------------------------------------------------------
  HitBusHisto : process(clk)
  begin  -- process HitBusHisto
    if rising_edge(clk) then
      hitbus_WriteBin <= '0';
      postOscillationCounter <= (others => '0');
      hitbus_HistoWrAddr <= (others => '0');
      case hithisto_fsm is
        when idle =>
		    hitbus_counter <= (others => '0'); 
		    hithisto_fsm <= idle;
          if hitbus_i = "01" then       --rising edge on hitbus
            hithisto_fsm   <= hitbus_high;
          end if;
        when hitbus_high =>
          hitbus_counter <= hitbus_counter + 1;
          hithisto_fsm <= hitbus_high;
          if hitbus_i = "10" then       --falling edge
            hithisto_fsm       <= wait_for_postOscillation;
          end if;
        when wait_for_postOscillation =>
            postOscillationCounter <= postOscillationCounter + 1;
            if(to_integer(postOscillationCounter) = PostOscillationWaitCycles) then --wait 5 clock cycles
              hitbus_WriteBin    <= '1';
              hitbus_HistoWrAddr <= std_logic_vector(hitbus_counter);
              hithisto_fsm <= idle;
            elsif(hitbus_i = "01") then --new rising edge, belongs to the same event
              hitbus_counter <= hitbus_counter + postOscillationCounter + 1;
              hithisto_fsm <= hitbus_high;
            else
          	  hithisto_fsm <= wait_for_postOscillation;
            end if;
      end case;
    end if;
  end process HitBusHisto;

  -----------------------------------------------------------------------------
  --Latency Histogram
  -----------------------------------------------------------------------------
  LatencyHisto : process(clk)
  begin  -- process LatencyHisto
  	if rising_edge(clk) then
  	  latency_histoWraddr  <= (others => '0');
      latency_WriteBin <= '0';
      case latency_fsm is
        when idle =>
          if trigger_i = "01" then
            latency_fsm  <= waitforhitbus;
            latency_counter <= latency_counter + 1;
          else
          	latency_fsm  <= idle;
            latency_counter  <= (others => '0');
          end if;
               
        when waitforhitbus =>
          latency_counter <= latency_counter + 1;
          if hitbus_i = "01" then
            latency_writebin    <= '1';
            latency_histoWraddr <= std_logic_vector(latency_counter);
            latency_fsm         <= idle;
          elsif latency_counter = hitbus_wait then
          	latency_fsm <= idle;
          else
          	latency_fsm <= waitforhitbus;
          end if;
      end case;
    end if;
  end process LatencyHisto;

  -----------------------------------------------------------------------------
  --TRB Slave Bus
  --0x0800: Histogram Ctrl
  --0x0801: Last ToT Value
  --0x0802: Last Latency Value
  --0x0803: Read Histograms
  --0x0804: ReadCounter
  --0x0805: snapshot of hitbus
  --0x0806: max wait time for hitbus event after latency trigger has been seen
  -----------------------------------------------------------------------------
  SLV_BUS_HANDLER : process(clk)
  begin  -- process SLV_BUS_HANDLER
    if rising_edge(clk) then
      SLV_DATA_OUT         <= (others => '0');
      SLV_ACK_OUT          <= '0';
      SLV_UNKNOWN_ADDR_OUT <= '0';
      SLV_NO_MORE_DATA_OUT <= '0';
      histvalue            <= latency_BinValue & hitbus_BinValue;
      
      if reading_histo_mem = '1' then
        ReadHisto <= '0';
        if histvalue_valid = '1' then
          SLV_DATA_OUT      <= histvalue;
          SLV_ACK_OUT       <= '1';
          reading_histo_mem <= '0';
          readcounter       <= readcounter + 1;
        else
          reading_histo_mem <= '1';
        end if;

      elsif SLV_READ_IN = '1' then
        case SLV_ADDR_IN is
          when x"0800" =>
            SLV_DATA_OUT <= histo_ctrl;
            SLV_ACK_OUT  <= '1';
          when x"0801" =>
            SLV_DATA_OUT(31 downto 16)                <= (others => '0');
            SLV_DATA_OUT(HistogramRange - 1 downto 0) <= hitbus_HistoWrAddr;
            SLV_ACK_OUT                               <= '1';
          when x"0802" =>
            SLV_DATA_OUT(31 downto 16)                <= (others => '0');
            SLV_DATA_OUT(HistogramRange - 1 downto 0) <= latency_histoWraddr;
            SLV_ACK_OUT                               <= '1';
          when x"0803" =>
            ReadHisto         <= '1';
            ReadAddr_i        <= std_logic_vector(readcounter);
            reading_histo_mem <= '1';
          when x"0804" =>
            SLV_DATA_OUT(HistogramRange - 1 downto 0) <= std_logic_vector(readcounter);
            SLV_ACK_OUT                               <= '1';
          when x"0805" =>
            SLV_DATA_OUT(0) <= hitbus;
            SLV_ACK_OUT <= '1';
        when x"0806" =>
        	SLV_DATA_OUT(HistogramRange - 1 downto 0) <= std_logic_vector(hitbus_wait);
        	SLV_ACK_OUT <= '1';
          when others =>
            SLV_UNKNOWN_ADDR_OUT <= '1';
        end case;

      elsif SLV_WRITE_IN = '1' then
        case SLV_ADDR_IN is
          when x"0800" =>
            histo_ctrl  <= SLV_DATA_IN;
            SLV_ACK_OUT <= '1';
          when x"0804" =>
            readcounter <= unsigned(SLV_DATA_IN(HistogramRange - 1 downto 0));
            SLV_ACK_OUT <= '1';
          when x"0806" => 
        	hitbus_wait <= unsigned(SLV_DATA_IN(HistogramRange - 1 downto 0));
        	SLV_ACK_OUT <= '1';	
          when others =>
            SLV_UNKNOWN_ADDR_OUT <= '1';
        end case;
       
      end if;
    end if;
    
  end process SLV_BUS_HANDLER;

  

end Behavioral;

