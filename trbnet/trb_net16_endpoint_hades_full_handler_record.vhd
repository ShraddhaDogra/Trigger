-- the full endpoint for TRB3++: trg, data, unused, regio including data buffer & handling

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.config.all;


entity trb_net16_endpoint_hades_full_handler_record is
  generic (
    IBUF_DEPTH                   : channel_config_t              := (6,6,6,6);
    FIFO_TO_INT_DEPTH            : channel_config_t              := (6,6,6,6);
    FIFO_TO_APL_DEPTH            : channel_config_t              := (1,1,1,1);
    APL_WRITE_ALL_WORDS          : channel_config_t              := (c_NO,c_NO,c_NO,c_NO);
    ADDRESS_MASK                 : std_logic_vector(15 downto 0) := x"FFFF";
    BROADCAST_BITMASK            : std_logic_vector(7 downto 0)  := x"FF";
    REGIO_INIT_ENDPOINT_ID       : std_logic_vector(15 downto 0) := x"0001";
    REGIO_USE_VAR_ENDPOINT_ID    : integer range c_NO to c_YES   := c_NO;
    TIMING_TRIGGER_RAW           : integer range 0 to 1 := c_YES;
    --Configure data handler
    DATA_INTERFACE_NUMBER        : integer range 1 to 16         := 1;
    DATA_BUFFER_DEPTH            : integer range 9 to 14         := 9;
    DATA_BUFFER_WIDTH            : integer range 1 to 32         := 32;
    DATA_BUFFER_FULL_THRESH      : integer range 0 to 2**14-2    := 2**8;
    TRG_RELEASE_AFTER_DATA       : integer range 0 to 1          := c_YES;
    HEADER_BUFFER_DEPTH          : integer range 9 to 14         := 9;
    HEADER_BUFFER_FULL_THRESH    : integer range 2**8 to 2**14-2 := 2**8
    );

  port(
    --  Misc
    CLK                          : in  std_logic;
    RESET                        : in  std_logic;
    CLK_EN                       : in  std_logic := '1';

    --  Media direction port
    MEDIA_MED2INT                : in  MED2INT;
    MEDIA_INT2MED                : out INT2MED;
    
    --Timing trigger in
    TRG_TIMING_TRG_RECEIVED_IN   : in  std_logic;
    
    READOUT_RX                   : out READOUT_RX;
    READOUT_TX                   : in  readout_tx_array_t(0 to DATA_INTERFACE_NUMBER-1);

    --Slow Control Port
    --common registers
    REGIO_COMMON_STAT_REG_IN     : in  std_logic_vector(std_COMSTATREG*32-1 downto 0) := (others => '0');
    REGIO_COMMON_CTRL_REG_OUT    : out std_logic_vector(std_COMCTRLREG*32-1 downto 0);
    REGIO_COMMON_STAT_STROBE_OUT : out std_logic_vector(std_COMSTATREG-1 downto 0);
    REGIO_COMMON_CTRL_STROBE_OUT : out std_logic_vector(std_COMCTRLREG-1 downto 0);

    --internal data port
    BUS_RX                       : out CTRLBUS_RX;
    BUS_TX                       : in  CTRLBUS_TX;
    --Data port - external master (e.g. Flash or Debug)
    BUS_MASTER_IN                : out CTRLBUS_TX;
    BUS_MASTER_OUT               : in  CTRLBUS_RX := (data => (others => '0'), addr => (others => '0'), write => '0', read => '0', timeout => '0');
    BUS_MASTER_ACTIVE            : in  std_logic := '0';
    --Onewire
    ONEWIRE_INOUT                : inout std_logic;
    --Config endpoint id, if not statically assigned
    REGIO_VAR_ENDPOINT_ID        : in  std_logic_vector (15 downto 0) := (others => '0');
    TIMERS_OUT                   : out TIMERS;

    --Debugging & Status information
    STAT_DEBUG_IPU               : out std_logic_vector (31 downto 0);
    STAT_DEBUG_1                 : out std_logic_vector (31 downto 0);
    STAT_DEBUG_2                 : out std_logic_vector (31 downto 0);
    STAT_DEBUG_DATA_HANDLER_OUT  : out std_logic_vector (31 downto 0);
    STAT_DEBUG_IPU_HANDLER_OUT   : out std_logic_vector (31 downto 0);
    CTRL_MPLEX                   : in  std_logic_vector (31 downto 0) := (others => '0');
    IOBUF_CTRL_GEN               : in  std_logic_vector (4*32-1 downto 0) := (others => '0');
    STAT_ONEWIRE                 : out std_logic_vector (31 downto 0);
    STAT_ADDR_DEBUG              : out std_logic_vector (15 downto 0);
    STAT_TRIGGER_OUT             : out std_logic_vector (79 downto 0);
    DEBUG_LVL1_HANDLER_OUT       : out std_logic_vector (15 downto 0)
    );
end entity;



architecture trb_net16_endpoint_hades_full_handler_record_arch of trb_net16_endpoint_hades_full_handler_record is

  signal lvl1_data_valid_i       : std_logic;
  signal lvl1_valid_i            : std_logic;
  signal lvl1_valid_timing_i     : std_logic;
  signal lvl1_valid_notiming_i   : std_logic;
  signal lvl1_invalid_i          : std_logic;
  signal lvl1_type_i             : std_logic_vector ( 3 downto 0);
  signal lvl1_number_i           : std_logic_vector (15 downto 0);
  signal lvl1_code_i             : std_logic_vector ( 7 downto 0);
  signal lvl1_information_i      : std_logic_vector (23 downto 0);
  signal lvl1_error_pattern_i    : std_logic_vector (31 downto 0);
  signal lvl1_release_i          : std_logic;
  signal lvl1_int_trg_number_i   : std_logic_vector (15 downto 0);

  signal ipu_number_i            : std_logic_vector (15 downto 0);
  signal ipu_readout_type_i      : std_logic_vector ( 3 downto 0);
  signal ipu_information_i       : std_logic_vector ( 7 downto 0);
  signal ipu_start_readout_i     : std_logic;
  signal ipu_data_i              : std_logic_vector (31 downto 0);
  signal ipu_dataready_i         : std_logic;
  signal ipu_readout_finished_i  : std_logic;
  signal ipu_read_i              : std_logic;
  signal ipu_length_i            : std_logic_vector (15 downto 0);
  signal ipu_error_pattern_i     : std_logic_vector (31 downto 0);
  signal reset_ipu_i             : std_logic;

  signal common_stat_reg_i       : std_logic_vector (std_COMSTATREG*32-1 downto 0);
  signal common_ctrl_reg_i       : std_logic_vector (std_COMCTRLREG*32-1 downto 0);
  signal common_stat_strobe_i    : std_logic_vector (std_COMSTATREG-1 downto 0);
  signal common_ctrl_strobe_i    : std_logic_vector (std_COMCTRLREG-1 downto 0);
--   signal stat_reg_i              : std_logic_vector (2**(REGIO_NUM_STAT_REGS)*32-1 downto 0);
--   signal ctrl_reg_i              : std_logic_vector (2**(REGIO_NUM_CTRL_REGS)*32-1 downto 0);
--   signal stat_strobe_i           : std_logic_vector (2**(REGIO_NUM_STAT_REGS)-1 downto 0);
--   signal ctrl_strobe_i           : std_logic_vector (2**(REGIO_NUM_CTRL_REGS)-1 downto 0);

  signal regio_rx, dbuf_rx, info_rx, stat_handler_rx, stat_buffer_rx, handlerbus_rx : CTRLBUS_RX;
  signal regio_tx, dbuf_tx, info_tx, stat_handler_tx, stat_buffer_tx : CTRLBUS_TX;

  signal time_global_i           : std_logic_vector (31 downto 0);
  signal time_local_i            : std_logic_vector ( 7 downto 0);
  signal time_since_last_trg_i   : std_logic_vector (31 downto 0);
  signal time_ticks_i            : std_logic_vector ( 1 downto 0);
  signal temperature_i           : std_logic_vector (11 downto 0);
  signal unique_id_i             : std_logic_vector (63 downto 0);
  
  signal buf_fee_data_almost_full_out : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal stat_handler_i          : std_logic_vector (127 downto 0);
  signal stat_data_buffer_level  : std_logic_vector (DATA_INTERFACE_NUMBER*32-1 downto 0);
  signal stat_header_buffer_level: std_logic_vector (31 downto 0);
  
  signal info_rd_nack    : std_logic;
  signal info_wr_nack    : std_logic;
  
  signal info_registers          : std_logic_vector_array_32(0 to 4);  
  signal stat_handler_registers  : std_logic_vector_array_32(0 to 2);  
  
  signal debug_data_handler_i    : std_logic_vector(31 downto 0);
  signal debug_ipu_handler_i     : std_logic_vector(31 downto 0);

  signal int_multiple_trg          : std_logic;
  signal int_lvl1_timeout_detected : std_logic;
  signal int_lvl1_spurious_trg     : std_logic;
  signal int_lvl1_missing_tmg_trg  : std_logic;
  signal int_spike_detected        : std_logic;
  signal int_lvl1_long_trg         : std_logic;
  signal tmg_trg_error_i           : std_logic;

  signal fee_data_finished_in : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal fee_data_write_in    : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal fee_trg_release_in   : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal fee_data_in           : std_logic_vector(32*DATA_INTERFACE_NUMBER-1 downto 0);
  signal fee_trg_statusbits_in : std_logic_vector(32*DATA_INTERFACE_NUMBER-1 downto 0);
  
  signal max_event_size            : std_logic_vector(15 downto 0);
  signal buffer_disable            : std_logic_vector(15 downto 0);  
  signal new_max_size              : std_logic_vector(15 downto 0);

begin
---------------------------------------------------------------------------
-- TrbNet Endpoint
---------------------------------------------------------------------------

  THE_ENDPOINT: trb_net16_endpoint_hades_full
    generic map(
      IBUF_DEPTH                 => IBUF_DEPTH,
      FIFO_TO_INT_DEPTH          => FIFO_TO_INT_DEPTH,
      FIFO_TO_APL_DEPTH          => FIFO_TO_APL_DEPTH,
      APL_WRITE_ALL_WORDS        => APL_WRITE_ALL_WORDS,
      ADDRESS_MASK               => ADDRESS_MASK,
      BROADCAST_BITMASK          => BROADCAST_BITMASK,
      BROADCAST_SPECIAL_ADDR     => BROADCAST_SPECIAL_ADDR,
      REGIO_NUM_STAT_REGS        => 1,
      REGIO_NUM_CTRL_REGS        => 1,
      REGIO_INIT_CTRL_REGS       => (others => '0'),
      REGIO_INIT_ADDRESS         => INIT_ADDRESS,
      REGIO_INIT_BOARD_INFO      => HARDWARE_INFO,
      REGIO_INIT_ENDPOINT_ID     => REGIO_INIT_ENDPOINT_ID,
      REGIO_COMPILE_TIME         => (others => '0'),
      REGIO_INCLUDED_FEATURES    => INCLUDED_FEATURES,
      REGIO_HARDWARE_VERSION     => HARDWARE_INFO,
      REGIO_USE_1WIRE_INTERFACE  => c_YES,
      REGIO_USE_VAR_ENDPOINT_ID  => REGIO_USE_VAR_ENDPOINT_ID,
      TIMING_TRIGGER_RAW         => TIMING_TRIGGER_RAW,
      CLOCK_FREQUENCY            => CLOCK_FREQUENCY
      )
    port map(
      CLK                        => CLK,
      RESET                      => RESET,
      CLK_EN                     => CLK_EN,

      MED_DATAREADY_OUT          => MEDIA_INT2MED.dataready,
      MED_DATA_OUT               => MEDIA_INT2MED.data,
      MED_PACKET_NUM_OUT         => MEDIA_INT2MED.packet_num,
      MED_READ_IN                => MEDIA_MED2INT.tx_read,
      MED_DATAREADY_IN           => MEDIA_MED2INT.dataready,
      MED_DATA_IN                => MEDIA_MED2INT.data,
      MED_PACKET_NUM_IN          => MEDIA_MED2INT.packet_num,
      MED_READ_OUT               => open,
      MED_STAT_OP_IN             => MEDIA_MED2INT.stat_op,
      MED_CTRL_OP_OUT            => MEDIA_INT2MED.ctrl_op,

      -- LVL1 trigger APL
      TRG_TIMING_TRG_RECEIVED_IN => TRG_TIMING_TRG_RECEIVED_IN,
      LVL1_TRG_DATA_VALID_OUT    => lvl1_data_valid_i,
      LVL1_TRG_VALID_TIMING_OUT  => lvl1_valid_timing_i,
      LVL1_TRG_VALID_NOTIMING_OUT=> lvl1_valid_notiming_i,
      LVL1_TRG_INVALID_OUT       => lvl1_invalid_i,
      LVL1_TRG_TYPE_OUT          => lvl1_type_i,
      LVL1_TRG_NUMBER_OUT        => lvl1_number_i,
      LVL1_TRG_CODE_OUT          => lvl1_code_i,
      LVL1_TRG_INFORMATION_OUT   => lvl1_information_i,
      LVL1_ERROR_PATTERN_IN      => lvl1_error_pattern_i,
      LVL1_TRG_RELEASE_IN        => lvl1_release_i,
      LVL1_INT_TRG_NUMBER_OUT    => lvl1_int_trg_number_i,

      --Information about trigger handler errors
      TRG_SPIKE_DETECTED_OUT     => int_spike_detected,
      TRG_SPURIOUS_TRG_OUT       => int_lvl1_spurious_trg,
      TRG_TIMEOUT_DETECTED_OUT   => int_lvl1_timeout_detected,
      TRG_MULTIPLE_TRG_OUT       => int_multiple_trg,
      TRG_MISSING_TMG_TRG_OUT    => int_lvl1_missing_tmg_trg,
      TRG_LONG_TRG_OUT           => int_lvl1_long_trg,
      --Data Port
      IPU_NUMBER_OUT             => ipu_number_i,
      IPU_READOUT_TYPE_OUT       => ipu_readout_type_i,
      IPU_INFORMATION_OUT        => ipu_information_i,
      IPU_START_READOUT_OUT      => ipu_start_readout_i,
      IPU_DATA_IN                => ipu_data_i,
      IPU_DATAREADY_IN           => ipu_dataready_i,
      IPU_READOUT_FINISHED_IN    => ipu_readout_finished_i,
      IPU_READ_OUT               => ipu_read_i,
      IPU_LENGTH_IN              => ipu_length_i,
      IPU_ERROR_PATTERN_IN       => ipu_error_pattern_i,

      -- Slow Control Data Port
      REGIO_COMMON_STAT_REG_IN   => REGIO_COMMON_STAT_REG_IN,
      REGIO_COMMON_CTRL_REG_OUT  => common_ctrl_reg_i,
      REGIO_REGISTERS_IN         => (others => '0'),
      REGIO_REGISTERS_OUT        => open,
      COMMON_STAT_REG_STROBE     => common_stat_strobe_i,
      COMMON_CTRL_REG_STROBE     => common_ctrl_strobe_i,
      STAT_REG_STROBE            => open,
      CTRL_REG_STROBE            => open,
      
      REGIO_ADDR_OUT         =>  regio_rx.addr, 
      REGIO_READ_ENABLE_OUT  =>  regio_rx.read, 
      REGIO_WRITE_ENABLE_OUT =>  regio_rx.write,
      REGIO_DATA_OUT         =>  regio_rx.data, 
      REGIO_DATA_IN          =>  regio_tx.data, 
      REGIO_DATAREADY_IN     =>  regio_tx.ack,
      REGIO_NO_MORE_DATA_IN  =>  regio_tx.nack, 
      REGIO_WRITE_ACK_IN     =>  regio_tx.ack,
      REGIO_UNKNOWN_ADDR_IN  =>  regio_tx.unknown,
      REGIO_TIMEOUT_OUT      =>  regio_rx.timeout,

      REGIO_ONEWIRE_INOUT        => ONEWIRE_INOUT,
      REGIO_ONEWIRE_MONITOR_IN   => '0',
      REGIO_ONEWIRE_MONITOR_OUT  => open,
      REGIO_VAR_ENDPOINT_ID      => REGIO_VAR_ENDPOINT_ID,
      MY_ADDRESS_OUT             => TIMERS_OUT.network_address,

      GLOBAL_TIME_OUT            => time_global_i,
      LOCAL_TIME_OUT             => time_local_i,
      TIME_SINCE_LAST_TRG_OUT    => time_since_last_trg_i,
      TIMER_TICKS_OUT            => time_ticks_i,
      TEMPERATURE_OUT            => temperature_i,
      UNIQUE_ID_OUT              => unique_id_i,

      STAT_DEBUG_IPU             => open,
      STAT_DEBUG_1               => open,
      STAT_DEBUG_2               => open,
      MED_STAT_OP                => open,
      CTRL_MPLEX                 => (others => '0'),
      IOBUF_CTRL_GEN             => (others => '0'),
      STAT_ONEWIRE               => open,
      STAT_ADDR_DEBUG            => open,
      STAT_TRIGGER_OUT           => STAT_TRIGGER_OUT,      
      DEBUG_LVL1_HANDLER_OUT     => DEBUG_LVL1_HANDLER_OUT
      );

TIMERS_OUT.microsecond  <= time_global_i;
TIMERS_OUT.clock        <= time_local_i;
TIMERS_OUT.last_trigger <= time_since_last_trg_i;
TIMERS_OUT.tick_ms      <= time_ticks_i(1);
TIMERS_OUT.tick_us      <= time_ticks_i(0);
TIMERS_OUT.temperature  <= temperature_i;
TIMERS_OUT.uid          <= unique_id_i;      
---------------------------------------------------------------------------
-- RegIO Bus Handler
---------------------------------------------------------------------------

  handlerbus_rx <= regio_rx when BUS_MASTER_ACTIVE = '0' else BUS_MASTER_OUT;
  BUS_MASTER_IN <= regio_tx;

  THE_INTERNAL_BUS_HANDLER : entity work.trb_net16_regio_bus_handler_record
    generic map(
      PORT_NUMBER                => 5,
      PORT_ADDRESSES             => (0 => x"8000", 1 => x"7100", 2 => x"7110", 3 => x"7200", 4 => x"7300", others => x"0000"),
      PORT_ADDR_MASK             => (0 => 15,      1 => 4,       2 => 3,       3 => 2,       4 => 5,       others => 0)
      )
    port map(
      CLK         => CLK,
      RESET       => RESET,

      REGIO_RX    => handlerbus_rx,
      REGIO_TX    => regio_tx,

      BUS_RX(0)   => BUS_RX,
      BUS_RX(1)   => dbuf_rx,
      BUS_RX(2)   => info_rx,
      BUS_RX(3)   => stat_handler_rx,
      BUS_RX(4)   => stat_buffer_rx,
      
      BUS_TX(0)   => BUS_TX,
      BUS_TX(1)   => dbuf_tx,
      BUS_TX(2)   => info_tx,
      BUS_TX(3)   => stat_handler_tx,
      BUS_TX(4)   => stat_buffer_tx
      );

---------------------------------------------------------------------------
--  registers 0x7110 ff.  
---------------------------------------------------------------------------

THE_HANDLER_INFO_REGS : bus_register_handler
  generic map(
    BUS_LENGTH => 5
    )
  port map(
    RESET            => RESET,
    CLK              => CLK,
    DATA_IN          => info_registers,
    READ_EN_IN       => info_rx.read,
    WRITE_EN_IN      => '0',
    ADDR_IN(2 downto 0) => info_rx.addr(2 downto 0),
    ADDR_IN(6 downto 3) => "0000",
    DATA_OUT         => info_tx.data,
    DATAREADY_OUT    => info_tx.rack,
    UNKNOWN_ADDR_OUT => info_rd_nack
    );  

info_tx.unknown   <= info_rd_nack or info_wr_nack;    
info_registers(0) <= stat_header_buffer_level;
info_registers(1) <= std_logic_vector(to_unsigned((2**DATA_BUFFER_DEPTH-DATA_BUFFER_FULL_THRESH-1),16)) & max_event_size;
info_registers(2) <=   std_logic_vector(to_unsigned(DATA_BUFFER_FULL_THRESH,16))
                     & std_logic_vector(to_unsigned(DATA_BUFFER_DEPTH,8))
                     & std_logic_vector(to_unsigned(DATA_INTERFACE_NUMBER,8));
info_registers(3) <=   std_logic_vector(to_unsigned(TRG_RELEASE_AFTER_DATA,1))
                     & "0000000"
                     & std_logic_vector(to_unsigned(HEADER_BUFFER_FULL_THRESH,16)) 
                     & std_logic_vector(to_unsigned(HEADER_BUFFER_DEPTH,8));
info_registers(4) <= x"0000" & buffer_disable;                     

  proc_maxeventsize : process begin
    wait until rising_edge(CLK);
    info_tx.wack <= '0';
    info_wr_nack <= info_rx.write;
    if RESET = '1' then
      max_event_size <= std_logic_vector(to_unsigned((2**DATA_BUFFER_DEPTH-DATA_BUFFER_FULL_THRESH-1),16));
      buffer_disable <= (others => '0');
    elsif info_rx.write = '1' and info_rx.addr(2 downto 0) = "001" then
      max_event_size  <= info_rx.data(15 downto 0);
      info_tx.wack <= '1';
      info_wr_nack <= '0';
    elsif info_rx.write = '1' and info_rx.addr(2 downto 0) = "100" then
      buffer_disable  <= info_rx.data(15 downto 0);
      info_tx.wack <= '1';
      info_wr_nack <= '0';
    end if;
  end process;                     

---------------------------------------------------------------------------
--  registers 0x7200 ff.  
---------------------------------------------------------------------------  
THE_HANDLER_STATUS_REGS : bus_register_handler
  generic map(
    BUS_LENGTH => 3
    )
  port map(
    RESET            => RESET,
    CLK              => CLK,
    DATA_IN          => stat_handler_registers,
    READ_EN_IN       => stat_handler_rx.read,
    WRITE_EN_IN      => stat_handler_rx.write,
    ADDR_IN(2 downto 0) => stat_handler_rx.addr(2 downto 0),
    ADDR_IN(6 downto 3) => "0000",
    DATA_OUT         => stat_handler_tx.data,
    DATAREADY_OUT    => stat_handler_tx.ack,
    UNKNOWN_ADDR_OUT => stat_handler_tx.unknown
    );   
stat_handler_registers(0) <= stat_handler_i(31 downto 0);
stat_handler_registers(1) <= stat_handler_i(63 downto 32);
stat_handler_registers(2) <= stat_handler_i(95 downto 64);

---------------------------------------------------------------------------
-- Data and IPU Handler
---------------------------------------------------------------------------

  THE_HANDLER_TRIGGER_DATA : handler_trigger_and_data
    generic map(
      DATA_INTERFACE_NUMBER      => DATA_INTERFACE_NUMBER,
      DATA_BUFFER_DEPTH          => DATA_BUFFER_DEPTH,
      DATA_BUFFER_WIDTH          => DATA_BUFFER_WIDTH,
      DATA_BUFFER_FULL_THRESH    => DATA_BUFFER_FULL_THRESH,
      TRG_RELEASE_AFTER_DATA     => TRG_RELEASE_AFTER_DATA,
      HEADER_BUFFER_DEPTH        => HEADER_BUFFER_DEPTH,
      HEADER_BUFFER_FULL_THRESH  => HEADER_BUFFER_FULL_THRESH
      )
    port map(
      CLOCK                      => CLK,
      RESET                      => RESET,
      RESET_IPU                  => reset_ipu_i,
      --LVL1 channel
      LVL1_VALID_TRIGGER_IN      => lvl1_valid_i,
      LVL1_INT_TRG_NUMBER_IN     => lvl1_int_trg_number_i,
      LVL1_TRG_DATA_VALID_IN     => lvl1_data_valid_i,
      LVL1_TRG_TYPE_IN           => lvl1_type_i,
      LVL1_TRG_NUMBER_IN         => lvl1_number_i,
      LVL1_TRG_CODE_IN           => lvl1_code_i,
      LVL1_TRG_INFORMATION_IN    => lvl1_information_i,
      LVL1_ERROR_PATTERN_OUT     => lvl1_error_pattern_i,
      LVL1_TRG_RELEASE_OUT       => lvl1_release_i,

      --IPU channel
      IPU_NUMBER_IN              => ipu_number_i,
      IPU_INFORMATION_IN         => ipu_information_i,
      IPU_READOUT_TYPE_IN        => ipu_readout_type_i,
      IPU_START_READOUT_IN       => ipu_start_readout_i,
      IPU_DATA_OUT               => ipu_data_i,
      IPU_DATAREADY_OUT          => ipu_dataready_i,
      IPU_READOUT_FINISHED_OUT   => ipu_readout_finished_i,
      IPU_READ_IN                => ipu_read_i,
      IPU_LENGTH_OUT             => ipu_length_i,
      IPU_ERROR_PATTERN_OUT      => ipu_error_pattern_i,

      --FEE Input
      FEE_TRG_RELEASE_IN         => fee_trg_release_in,
      FEE_TRG_STATUSBITS_IN      => fee_trg_statusbits_in,
      FEE_DATA_IN                => fee_data_in,
      FEE_DATA_WRITE_IN          => fee_data_write_in,
      FEE_DATA_FINISHED_IN       => fee_data_finished_in,
      FEE_DATA_ALMOST_FULL_OUT   => buf_fee_data_almost_full_out,

      TMG_TRG_ERROR_IN           => tmg_trg_error_i,
      MAX_EVENT_SIZE_IN          => max_event_size,
      BUFFER_DISABLE_IN          => buffer_disable,      
      --Status Registers
      STAT_DATA_BUFFER_LEVEL     => stat_data_buffer_level,
      STAT_HEADER_BUFFER_LEVEL   => stat_header_buffer_level,
      STATUS_OUT                 => stat_handler_i,
      TIMER_TICKS_IN             => time_ticks_i,
      STATISTICS_DATA_OUT        => stat_buffer_tx.data,
      STATISTICS_UNKNOWN_OUT     => stat_buffer_tx.unknown,
      STATISTICS_READY_OUT       => stat_buffer_tx.ack,
      STATISTICS_READ_IN         => stat_buffer_rx.read,
      STATISTICS_ADDR_IN         => stat_buffer_rx.addr(4 downto 0),


      --Debug
      DEBUG_DATA_HANDLER_OUT     => debug_data_handler_i,
      DEBUG_IPU_HANDLER_OUT      => debug_ipu_handler_i

      );

  reset_ipu_i                  <= RESET or common_ctrl_reg_i(2);
  lvl1_valid_i                 <= lvl1_valid_timing_i or lvl1_valid_notiming_i or lvl1_invalid_i;
  STAT_DEBUG_IPU_HANDLER_OUT   <= debug_ipu_handler_i;
  STAT_DEBUG_DATA_HANDLER_OUT  <= debug_data_handler_i;
  tmg_trg_error_i              <= int_lvl1_missing_tmg_trg or int_lvl1_spurious_trg or int_lvl1_timeout_detected or int_multiple_trg
                                  or int_spike_detected or int_lvl1_long_trg;
 
 
gen_rdo_tx : for i in 0 to DATA_INTERFACE_NUMBER-1 generate
      fee_trg_release_in(i)                      <= READOUT_TX(i).busy_release;
      fee_trg_statusbits_in(i*32+31 downto i*32) <= READOUT_TX(i).statusbits;
      fee_data_in(i*32+31 downto i*32)           <= READOUT_TX(i).data;
      fee_data_write_in(i)                       <= READOUT_TX(i).data_write;
      fee_data_finished_in(i)                    <= READOUT_TX(i).data_finished;
end generate;

 
---------------------------------------------------------------------------
-- Connect Status Registers
---------------------------------------------------------------------------
  proc_buf_status : process(CLK)
    variable tmp : integer range 0 to 15;
    begin
      if rising_edge(CLK) then
        dbuf_tx.nack           <= '0';
        dbuf_tx.unknown        <= dbuf_rx.write;
        dbuf_tx.ack            <= '0';
        if dbuf_rx.read = '1' then
          tmp := to_integer(unsigned(dbuf_rx.addr(3 downto 0)));
          if tmp < DATA_INTERFACE_NUMBER then
            dbuf_tx.data        <= stat_data_buffer_level(tmp*32+31 downto tmp*32);
            dbuf_tx.ack         <= '1';
          else
            dbuf_tx.data        <= (others => '0');
            dbuf_tx.unknown     <= '1';
          end if;
        end if;
      end if;
    end process;



---------------------------------------------------------------------------
-- Connect I/O Ports
---------------------------------------------------------------------------

  READOUT_RX.trg_spike     <= int_spike_detected;
  READOUT_RX.trg_spurious  <= int_lvl1_spurious_trg;
  READOUT_RX.trg_timeout   <= int_lvl1_timeout_detected;
  READOUT_RX.trg_multiple  <= int_multiple_trg;
  READOUT_RX.trg_missing   <= int_lvl1_missing_tmg_trg;
  READOUT_RX.buffer_almost_full  <= or_all(buf_fee_data_almost_full_out);

  READOUT_RX.data_valid          <= lvl1_data_valid_i;
  READOUT_RX.valid_timing_trg    <= lvl1_valid_timing_i;
  READOUT_RX.valid_notiming_trg  <= lvl1_valid_notiming_i;
  READOUT_RX.invalid_trg         <= lvl1_invalid_i;
  READOUT_RX.trg_type            <= lvl1_type_i;
  READOUT_RX.trg_number          <= lvl1_number_i;
  READOUT_RX.trg_code            <= lvl1_code_i;
  READOUT_RX.trg_information     <= lvl1_information_i;
  READOUT_RX.trg_int_number      <= lvl1_int_trg_number_i;

  REGIO_COMMON_CTRL_REG_OUT      <= common_ctrl_reg_i;
  REGIO_COMMON_STAT_STROBE_OUT   <= common_stat_strobe_i;
  REGIO_COMMON_CTRL_STROBE_OUT   <= common_ctrl_strobe_i;
--   REGIO_CTRL_REG_OUT             <= ctrl_reg_i;
--   REGIO_STAT_STROBE_OUT          <= stat_strobe_i;
--   REGIO_CTRL_STROBE_OUT          <= ctrl_strobe_i;

--   stat_reg_i                     <= REGIO_STAT_REG_IN;


  process(REGIO_COMMON_STAT_REG_IN, debug_ipu_handler_i,clk)
    begin
      common_stat_reg_i(8 downto 0) <= REGIO_COMMON_STAT_REG_IN(8 downto 0);
      common_stat_reg_i(47 downto 12) <= REGIO_COMMON_STAT_REG_IN(47 downto 12);
      common_stat_reg_i(6)       <= debug_ipu_handler_i(15) or REGIO_COMMON_STAT_REG_IN(6);

      if rising_edge(CLK) then
        if common_ctrl_reg_i(4) = '1' then 
          common_stat_reg_i(11 downto 9) <= "000";
        else 
          common_stat_reg_i(9)       <= debug_ipu_handler_i(12) or REGIO_COMMON_STAT_REG_IN(9) or common_stat_reg_i(9);
          common_stat_reg_i(10)      <= debug_ipu_handler_i(13) or REGIO_COMMON_STAT_REG_IN(10) or common_stat_reg_i(10);
          common_stat_reg_i(11)      <= debug_ipu_handler_i(14) or REGIO_COMMON_STAT_REG_IN(11) or common_stat_reg_i(11);      
        end if;
      end if;
      common_stat_reg_i(159 downto 64) <= REGIO_COMMON_STAT_REG_IN(159 downto 64);
    end process;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if ipu_start_readout_i = '1' then
          common_stat_reg_i(63 downto 48) <= ipu_number_i;
        end if;
      end if;
    end process;

end architecture;

-- 
--   type CTRLBUS_TX is record
--     data       : std_logic_vector(31 downto 0);
--     ack        : std_logic;
--     wack,rack  : std_logic; --for the old-fashioned guys
--     unknown    : std_logic;
--     nack       : std_logic;
--   end record;
-- 
--   type CTRLBUS_RX is record
--     data       : std_logic_vector(31 downto 0);
--     addr       : std_logic_vector(15 downto 0);
--     write      : std_logic;
--     read       : std_logic;
--     timeout    : std_logic;
--   end record; 
-- 
--   
--   type READOUT_RX is record 
--     data_valid         : std_logic;
--     valid_timing_trg   : std_logic;
--     valid_notiming_trg : std_logic;
--     invalid_trg        : std_logic;
--     --
--     trg_type           : std_logic_vector( 3 downto 0);
--     trg_number         : std_logic_vector(15 downto 0);
--     trg_code           : std_logic_vector( 7 downto 0);
--     trg_information    : std_logic_vector(23 downto 0);
--     trg_int_number     : std_logic_vector(15 downto 0);    
--     --
--     trg_multiple       : std_logic;
--     trg_timeout        : std_logic;
--     trg_spurious       : std_logic;
--     trg_missing        : std_logic;
--     trg_spike          : std_logic;
--     --
--     buffer_almost_full : std_logic;
--   end record; 
--   
--   
--   type READOUT_TX is record
--     busy_release  : std_logic;
--     statusbits    : std_logic_vector(31 downto 0);
--     data          : std_logic_vector(31 downto 0);
--     data_write    : std_logic;
--     data_finished : std_logic;
--   end record;
