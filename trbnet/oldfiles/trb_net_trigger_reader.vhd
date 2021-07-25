------------------------------------------------------------------------------
--
-- This is a trigger reading application with interrupt signal generation
-- 
--
------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.trb_net_std.all;


entity trb_net_trigger_reader is
  port(
    --  Misc
    CLK    : in std_logic;              
    RESET  : in std_logic;      
    CLK_EN : in std_logic;

    -- APL Transmitter port
    APL_DATA_OUT:       out STD_LOGIC_VECTOR (47 downto 0); -- Data word "application to network"
    APL_WRITE_OUT:      out STD_LOGIC; -- Data word is valid and should be transmitted
    APL_FIFO_FULL_IN:   in  STD_LOGIC; -- Stop transfer, the fifo is full
    APL_SHORT_TRANSFER_OUT: out STD_LOGIC; -- 
    APL_DTYPE_OUT:      out STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL_ERROR_PATTERN_OUT: out STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
    APL_SEND_OUT:       out STD_LOGIC; -- Release sending of the data
    APL_TARGET_ADDRESS_OUT: out STD_LOGIC_VECTOR (15 downto 0); -- Address of
                                                               -- the target (only for active APIs)
    -- Receiver port
    APL_DATA_IN:      in  STD_LOGIC_VECTOR (47 downto 0); -- Data word "network to application"
    APL_TYP_IN:       in  STD_LOGIC_VECTOR (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
    APL_DATAREADY_IN: in  STD_LOGIC; -- Data word is valid and might be read out
    APL_READ_OUT:     out STD_LOGIC; -- Read data word
    -- APL Control port
    APL_RUN_IN:       in STD_LOGIC; -- Data transfer is running
    --APL_MY_ADDRESS_OUT: out  STD_LOGIC_VECTOR (15 downto 0);  -- My own address (temporary solution!!!)
    APL_SEQNR_IN:     in STD_LOGIC_VECTOR (7 downto 0);

    INTERNAL_TIME_OUT: out std_logic_vector(31 downto 0);

    TRB_INTERRUPT_OUT: out std_logic_vector(7 downto 0);
    TRB_TRIGGER_NUM_OUT: out std_logic_vector(7 downto 0);
    TRB_TRIGGER_TIME_OUT: out std_logic_vector(31 downto 0);
    TRB_TRIGGER_DATAREADY: out std_logic;
    TRB_TRIGGER_NUM_READ: in std_logic;
    TRB_TRIGGER_TIME_READ: in std_logic;
    TRB_TRIGGER_READ_ERROR: out std_logic;
    
    STAT_TRIGGER_READER: out std_logic_vector(31 downto 0)
    );
end entity;



architecture trb_net_trigger_reader_arch of trb_net_trigger_reader is


  component trb_net_fifo is
    generic (
      WIDTH : integer := 48;       -- FIFO word width
      DEPTH : integer := 3);     -- Depth of the FIFO, 2^(n+1)
    port (
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      DATA_IN         : in  std_logic_vector(WIDTH - 1 downto 0);  -- Input data
      WRITE_ENABLE_IN : in  std_logic;
      DATA_OUT        : out std_logic_vector(WIDTH - 1 downto 0);  -- Output data
      READ_ENABLE_IN  : in  std_logic;
      FULL_OUT        : out std_logic;        -- Full Flag
      EMPTY_OUT       : out std_logic;
      DEPTH_OUT       : out std_logic_vector(7 downto 0)
      );
  end component;
  
  signal buf_APL_READ_OUT : std_logic;
  signal buf_APL_DATA_OUT : std_logic_vector(47 downto 0);
  signal buf_APL_WRITE_OUT: std_logic;
  signal buf_APL_SEND_OUT, next_APL_SEND_OUT: std_logic;
  signal buf_APL_ERROR_PATTERN_OUT, next_APL_ERROR_PATTERN_OUT: std_logic_vector(31 downto 0);
  signal count_fifo: std_logic;
  
  signal fifo_data_in, next_fifo_data_in, fifo_data_out  : std_logic_vector(39 downto 0);
  signal fifo_write_enable_in, next_fifo_write_enable_in : std_logic;
  signal fifo_read, next_fifo_read : std_logic;
  signal fifo_empty_out      : std_logic;
  
  signal buf_TRB_TRIGGER_NUM_OUT : std_logic_vector(7 downto 0);
  signal buf_TRB_TRIGGER_TIME_OUT: std_logic_vector(31 downto 0);

  signal last_TRB_TRIGGER_NUM_READ, last_TRB_TRIGGER_TIME_READ : std_logic;
  signal trigger_num_is_read, next_trigger_num_is_read: std_logic;
  signal trigger_time_is_read, next_trigger_time_is_read: std_logic;
  signal buf_TRB_TRIGGER_READ_ERROR, next_TRB_TRIGGER_READ_ERROR: std_logic;
  
  signal next_STAT_TRIGGER_READER, buf_STAT_TRIGGER_READER : std_logic_vector(31 downto 0);
  signal timecounter, next_timecounter : std_logic_vector(31 downto 0);
  signal clkcounter, next_clkcounter : std_logic_vector(6 downto 0);
                                  --counter for us-timer
  begin



-----------------------------------------
-- fifo for trigger data
-----------------------------------------
  TRB_TRIGGER_DATAREADY <= not fifo_empty_out;

  trigger_fifo : trb_net_fifo
    generic map(
      WIDTH => 40,
      DEPTH => 3
      )
    port map(
      CLK => CLK,
      CLK_EN => CLK_EN,
      RESET => RESET,
      DATA_IN         => fifo_data_in,
      WRITE_ENABLE_IN => fifo_write_enable_in,
      DATA_OUT        => fifo_data_out,
      READ_ENABLE_IN  => fifo_read,
      FULL_OUT        => open,
      EMPTY_OUT       => fifo_empty_out,
      DEPTH_OUT       => open
      );


-----------------------------------------
-- detect and answer triggers
-----------------------------------------
  process(APL_DATA_IN, APL_TYP_IN, APL_DATAREADY_IN, buf_APL_READ_OUT, timecounter, APL_SEQNR_IN)
    begin
      next_fifo_write_enable_in <= '0';
      next_fifo_data_in <= (others => '0');
      next_APL_SEND_OUT <= '0';
      if APL_TYP_IN = TYPE_TRM and APL_DATAREADY_IN = '1' and buf_APL_READ_OUT = '1' then
        next_fifo_data_in(7 downto 0) <= APL_SEQNR_IN;
        next_fifo_data_in(39 downto 8)<= timecounter;
        next_fifo_write_enable_in <= '1';
        next_APL_SEND_OUT <= '1';
        next_APL_ERROR_PATTERN_OUT <= x"00000000";
      end if;
    end process;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          fifo_data_in <= (others => '0');
          fifo_write_enable_in <= '0';
          buf_APL_SEND_OUT <= next_APL_SEND_OUT;
          buf_APL_ERROR_PATTERN_OUT <= (others => '0');
          --buf_STAT_TRIGGER_READER <= (others => '0');
        else
          fifo_data_in <= next_fifo_data_in;
          fifo_write_enable_in <= next_fifo_write_enable_in;
          buf_APL_SEND_OUT <= next_APL_SEND_OUT;
          buf_APL_ERROR_PATTERN_OUT <= next_APL_ERROR_PATTERN_OUT;
          --buf_STAT_TRIGGER_READER <= next_STAT_TRIGGER_READER;
        end if;
      end if;
    end process;

buf_STAT_TRIGGER_READER(1) <= fifo_write_enable_in;
buf_STAT_TRIGGER_READER(2) <= fifo_read;

STAT_TRIGGER_READER <= buf_STAT_TRIGGER_READER;

---------------------------------------
-- prepare trigger fifodata for readout
---------------------------------------

  buf_TRB_TRIGGER_NUM_OUT  <= fifo_data_out(7 downto 0);
  buf_TRB_TRIGGER_TIME_OUT <= fifo_data_out(39 downto 8);


  process(TRB_TRIGGER_NUM_READ, TRB_TRIGGER_TIME_READ, trigger_num_is_read, 
          trigger_time_is_read, buf_TRB_TRIGGER_READ_ERROR, last_TRB_TRIGGER_NUM_READ, 
          last_TRB_TRIGGER_TIME_READ, fifo_empty_out)
    begin
      next_trigger_num_is_read <= trigger_num_is_read;
      next_trigger_time_is_read <= trigger_time_is_read;
      fifo_read <= '0';
      next_TRB_TRIGGER_READ_ERROR <= '0';

      if trigger_num_is_read = '1' and trigger_time_is_read = '1' then
        next_trigger_num_is_read <= '0';
        next_trigger_time_is_read <= '0';
        fifo_read <= '1';
        next_TRB_TRIGGER_READ_ERROR <= buf_TRB_TRIGGER_READ_ERROR;
      end if;

      if TRB_TRIGGER_NUM_READ = '1' then
        next_TRB_TRIGGER_READ_ERROR <= '0';
        if trigger_num_is_read = '1' then
          next_TRB_TRIGGER_READ_ERROR <= '1';
        end if;
        next_trigger_num_is_read <= '1';
      end if;

      if TRB_TRIGGER_TIME_READ = '1' then
        next_TRB_TRIGGER_READ_ERROR <= '0';
        if trigger_time_is_read = '1' then
          next_TRB_TRIGGER_READ_ERROR <= '1';
        end if;
        next_trigger_time_is_read <= '1';
      end if;

      if fifo_empty_out = '1' then
        next_TRB_TRIGGER_READ_ERROR <= '1';
      end if;
    end process;



  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
--           last_TRB_TRIGGER_NUM_READ <= '0';
--           last_TRB_TRIGGER_TIME_READ <= '0';
          buf_TRB_TRIGGER_READ_ERROR <= '0';
          trigger_num_is_read <= '0';
          trigger_time_is_read <= '0';
--          fifo_read <= '0';
        else
--           last_TRB_TRIGGER_NUM_READ <= TRB_TRIGGER_NUM_READ;
--           last_TRB_TRIGGER_TIME_READ <= TRB_TRIGGER_TIME_READ;
          buf_TRB_TRIGGER_READ_ERROR <= next_TRB_TRIGGER_READ_ERROR;
          trigger_num_is_read <= next_trigger_num_is_read;
          trigger_time_is_read <= next_trigger_time_is_read;
--          fifo_read <= next_fifo_read;
        end if;
      end if;
    end process;


-----------------------------------------
-- Generate internal 32Bit timer @ 1 MHz
-----------------------------------------

  process(clkcounter, timecounter)
    begin
      next_clkcounter <= clkcounter + 1;
      next_timecounter <= timecounter;
      if(clkcounter = 98) then
        next_clkcounter <= (others => '0');
        next_timecounter <= timecounter + 1;
      end if;
    end process;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          clkcounter <= (others => '0');
          timecounter <= (others => '0');
        else
          clkcounter <= next_clkcounter;
          timecounter <= next_timecounter;
        end if;
      end if;
    end process;




-----------------------------------------
-- Output generation
-----------------------------------------
  APL_DATA_OUT <= (others => '0');
  APL_READ_OUT <= buf_APL_READ_OUT;
  APL_WRITE_OUT <= '0';
  APL_SEND_OUT <= buf_APL_SEND_OUT;
  APL_ERROR_PATTERN_OUT <= buf_APL_ERROR_PATTERN_OUT;
  APL_TARGET_ADDRESS_OUT <= x"0001";
  APL_DTYPE_OUT <= "0000";
  APL_SHORT_TRANSFER_OUT <= '1';
  buf_APL_READ_OUT <= '1';

  TRB_TRIGGER_NUM_OUT <= buf_TRB_TRIGGER_NUM_OUT;
  TRB_TRIGGER_TIME_OUT <= buf_TRB_TRIGGER_TIME_OUT;
  TRB_TRIGGER_READ_ERROR <= buf_TRB_TRIGGER_READ_ERROR;
  
  INTERNAL_TIME_OUT <= timecounter;

end architecture;
