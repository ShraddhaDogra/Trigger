LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.pcie_components.all;
use work.trb_net16_hub_func.all;

entity trb_net_bridge_pcie_endpoint_hub is
  generic(
    NUM_LINKS    : integer range 1 to 4 := 2;
    USE_CHANNELS : channel_config_t := (c_YES,c_YES,c_NO,c_YES);
    COMPILE_TIME : std_logic_vector(31 downto 0) := (others => '0')
    );
  port(
    RESET              : in  std_logic;
    RESET_TRBNET       : in  std_logic;
    CLK                : in  std_logic;
    CLK_125_IN         : in  std_logic;

    BUS_ADDR_IN        : in  std_logic_vector(31 downto 0);
    BUS_WDAT_IN        : in  std_logic_vector(31 downto 0);
    BUS_RDAT_OUT       : out std_logic_vector(31 downto 0);
    BUS_SEL_IN         : in  std_logic_vector(3 downto 0);
    BUS_WE_IN          : in  std_logic;
    BUS_CYC_IN         : in  std_logic;
    BUS_STB_IN         : in  std_logic;
    BUS_LOCK_IN        : in  std_logic;
    BUS_ACK_OUT        : out std_logic;

    SPI_CLK_OUT        : out std_logic;
    SPI_D_OUT          : out std_logic;
    SPI_D_IN           : in  std_logic;
    SPI_CE_OUT         : out std_logic;

    MED_DATAREADY_IN   : in  std_logic_vector (NUM_LINKS-1 downto 0);
    MED_DATA_IN        : in  std_logic_vector (16*NUM_LINKS-1 downto 0);
    MED_PACKET_NUM_IN  : in  std_logic_vector (3*NUM_LINKS-1 downto 0);
    MED_READ_OUT       : out std_logic_vector (NUM_LINKS-1 downto 0);

    MED_DATAREADY_OUT  : out std_logic_vector (NUM_LINKS-1 downto 0);
    MED_DATA_OUT       : out std_logic_vector (16*NUM_LINKS-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector (3*NUM_LINKS-1 downto 0);
    MED_READ_IN        : in  std_logic_vector (NUM_LINKS-1 downto 0);

    MED_STAT_OP_IN     : in  std_logic_vector (16*NUM_LINKS-1 downto 0);
    MED_CTRL_OP_OUT    : out std_logic_vector (16*NUM_LINKS-1 downto 0);

    REQUESTOR_ID_IN    : in  std_logic_vector(15 downto 0);
    TX_ST_OUT          : out std_logic;                     --tx first word
    TX_END_OUT         : out std_logic;                     --tx last word
    TX_DWEN_OUT        : out std_logic;                     --tx use only upper 32 bit
    TX_DATA_OUT        : out std_logic_vector(63 downto 0); --tx data out
    TX_REQ_OUT         : out std_logic;                     --tx request out
    TX_RDY_IN          : in  std_logic;                     --tx arbiter can read
    TX_VAL_IN          : in  std_logic;                     --tx data is valid
    TX_CA_PH_IN        : in  std_logic_vector(8 downto 0);  --header credit for write
    TX_CA_PD_IN        : in  std_logic_vector(12 downto 0); --data credits in 32 bit words
    TX_CA_NPH_IN       : in  std_logic_vector(8 downto 0);  --header credit for read

    RX_CR_CPLH_OUT     : out std_logic;
    RX_CR_CPLD_OUT     : out std_logic_vector(7 downto 0);
    UNEXP_CMPL_OUT     : out std_logic;
    RX_ST_IN           : in  std_logic;
    RX_END_IN          : in  std_logic;
    RX_DWEN_IN         : in  std_logic;
    RX_DATA_IN         : in  std_logic_vector(63 downto 0);

    PROGRMN_OUT        : out std_logic;
    SEND_RESET_OUT     : out std_logic;
    MAKE_RESET_OUT     : out std_logic;
    DEBUG_OUT          : out std_logic_vector (31 downto 0)
    );
end entity;

--address range is 100 to FFF
--  (c is channel number * 2 + 1 if active part)

--sending data. sending is released when 1c0 is written
--1c0 wr (3..0) Dtype (8) short transfer    sender_control    25bit used
--       (31..16) target address
--1c2 wr Errorbits                          sender_error      32bit used
--1c3 w  sender data fifo                   sender_data       16bit used
--1c5 wr Extended Trigger Information       sender_trigger_information 16bit
--1cF r  status (0)transfer running         sender_status      1bit used

--received data
--2c3 r  receiver data fifo, (20..18)type  receiver_data      16bit used
--2c4 r  receiver fifo status              (9..0 datacount, 16 full, 17 empty)


--3c0  (7..0) seq_num         apis_tatus


--7c0  DMA Address                  dma_address(31..0)
--7c1  DMA Buffer Size              dma_buffer(31..0)
--       write : size of available buffer in RAM (byte)
--       read :  remaining buffer size (i.e. how many bytes have been written)
--7c2  DMA Control/Status           dma_control
--       (0) write: enable DMA / read: '1' while DMA active, '0' after DMA finished

architecture trb_net_bridge_pcie_endpoint_hub_arch of trb_net_bridge_pcie_endpoint_hub is

  signal reset_trbnet_i : std_logic;
  signal clk_en  : std_logic;

  signal buf_med_ctrl_op : std_logic_vector(NUM_LINKS*16-1 downto 0);
  
  signal apl_to_buf_INIT_DATAREADY: std_logic_vector(3 downto 0);
  signal apl_to_buf_INIT_DATA     : std_logic_vector (3*c_DATA_WIDTH downto 0);
  signal tmp_apl_to_buf_INIT_DATA : std_logic_vector (3*c_DATA_WIDTH downto 0);
  signal apl_to_buf_INIT_PACKET_NUM:std_logic_vector (3*c_NUM_WIDTH downto 0);
  signal apl_to_buf_INIT_READ     : std_logic_vector(3 downto 0);

  signal buf_to_apl_INIT_DATAREADY: std_logic_vector(3 downto 0);
  signal buf_to_apl_INIT_DATA     : std_logic_vector (3*c_DATA_WIDTH downto 0);
  signal buf_to_apl_INIT_PACKET_NUM:std_logic_vector (3*c_NUM_WIDTH downto 0);
  signal buf_to_apl_INIT_READ     : std_logic_vector(3 downto 0);

  signal apl_to_buf_REPLY_DATAREADY: std_logic_vector(3 downto 0);
  signal apl_to_buf_REPLY_DATA     : std_logic_vector (3*c_DATA_WIDTH downto 0);
  signal apl_to_buf_REPLY_PACKET_NUM:std_logic_vector (3*c_NUM_WIDTH downto 0);
  signal apl_to_buf_REPLY_READ     : std_logic_vector(3 downto 0);

  signal buf_to_apl_REPLY_DATAREADY: std_logic_vector(3 downto 0);
  signal buf_to_apl_REPLY_DATA     : std_logic_vector (3*c_DATA_WIDTH downto 0);
  signal buf_to_apl_REPLY_PACKET_NUM:std_logic_vector (3*c_NUM_WIDTH downto 0);
  signal buf_to_apl_REPLY_READ     : std_logic_vector(3 downto 0);



  signal common_ctrl             : std_logic_vector(std_COMCTRLREG*32-1 downto 0);
  signal common_stat             : std_logic_vector(std_COMSTATREG*32-1 downto 0);
  signal my_address              : std_logic_vector(15 downto 0);
  signal timer_ticks             : std_logic_vector(1 downto 0);
  signal hub_ctrl_debug          : std_logic_vector(31 downto 0);
  signal hub_stat_debug          : std_logic_vector(31 downto 0);

  signal link_not_up             : std_logic;
  signal apl_stat                : std_logic_vector(31 downto 0);

  signal apl_data_in             : std_logic_vector(3*16-1 downto 0);
  signal apl_packet_num_in       : std_logic_vector(3*3-1 downto 0);
  signal apl_dataready_in        : std_logic_vector(3-1 downto 0);
  signal apl_read_out            : std_logic_vector(3-1 downto 0);
  signal apl_short_transfer_in   : std_logic_vector(3-1 downto 0);
  signal apl_dtype_in            : std_logic_vector(3*4-1 downto 0);
  signal apl_send_in             : std_logic_vector(3-1 downto 0);
  signal apl_data_out            : std_logic_vector(3*16-1 downto 0);
  signal apl_packet_num_out      : std_logic_vector(3*3-1 downto 0);
  signal apl_typ_out             : std_logic_vector(3*3-1 downto 0);
  signal apl_dataready_out       : std_logic_vector(3-1 downto 0);
  signal apl_read_in             : std_logic_vector(3-1 downto 0);
  signal apl_run_out             : std_logic_vector(3-1 downto 0);
  signal apl_seqnr_out           : std_logic_vector(3*8-1 downto 0);
  signal apl_target_address_out  : std_logic_vector(3*16-1 downto 0);
  signal apl_error_pattern_in    : std_logic_vector(3*32-1 downto 0);
  signal apl_target_address_in   : std_logic_vector(3*16-1 downto 0);
  signal apl_fifo_count_out      : std_logic_vector(3*11-1 downto 0);
  signal apl_my_address_in       : std_logic_vector(15 downto 0);
  signal next_apl_send_in        : std_logic_vector(2 downto 0);

  signal buf_api_stat_fifo_to_int : std_logic_vector(3*32-1 downto 0);
  signal buf_api_stat_fifo_to_apl : std_logic_vector(3*32-1 downto 0);
  signal reg_extended_trigger_information : std_logic_vector(15 downto 0);


  signal fifo_net_to_pci_read    : std_logic_vector(3 downto 0);
  signal fifo_net_to_pci_dout    : std_logic_vector(32*4-1 downto 0);
  signal fifo_net_to_pci_valid_read : std_logic_vector(3 downto 0);
  signal fifo_net_to_pci_empty   : std_logic_vector(3 downto 0);
  signal sender_control : std_logic_vector(32*4-1 downto 0);
  signal sender_target  : std_logic_vector(32*4-1 downto 0);
  signal sender_error   : std_logic_vector(32*4-1 downto 0);
  signal sender_status  : std_logic_vector(32*4-1 downto 0);
  signal api_status     : std_logic_vector(32*4-1 downto 0);

  signal channel_address : integer range 0 to 3;

  signal bus_ack_i        : std_logic := '0';
  signal bus_data_i       : std_logic_vector(31 downto 0) := (others => '0');
  signal bus_read_i       : std_logic := '0';
  signal bus_write_i      : std_logic := '0';
  signal bus_stb_rising   : std_logic := '0';
  signal bus_stb_last     : std_logic := '0';
  signal bus_write_last   : std_logic := '0';
  signal bus_read_last    : std_logic := '0';

  signal send_reset_counter : unsigned(10 downto 0);

  signal bus_spi_read_i   : std_logic;
  signal bus_spi_write_i  : std_logic;
  signal bus_spi_ack_i    : std_logic;
  signal bus_spi_data_i   : std_logic_vector(31 downto 0);

  signal spi_bram_addr           : std_logic_vector(7 downto 0);
  signal spi_bram_wr_d           : std_logic_vector(7 downto 0);
  signal spi_bram_rd_d           : std_logic_vector(7 downto 0);
  signal spi_bram_we             : std_logic;

  signal spictrl_read_en  : std_logic;
  signal spictrl_write_en : std_logic;
  signal spictrl_ack      : std_logic;
  signal spictrl_data_out : std_logic_vector(31 downto 0);
  signal spimem_read_en   : std_logic;
  signal spimem_write_en  : std_logic;
  signal spimem_ack       : std_logic;
  signal spimem_data_out  : std_logic_vector(31 downto 0);
  signal spi_fake_ack     : std_logic;

  signal dma_control_i       : std_logic_vector(31 downto 0);
  signal dma_status_i        : std_logic_vector(31 downto 0);
  signal dma_config_i        : std_logic_vector(31 downto 0);
  signal apl_read_dma        : std_logic;
  signal debug_dma_core      : std_logic_vector(31 downto 0);
  signal status_dma_core     : std_logic_vector(159 downto 0);
  signal bus_wdat_last       : std_logic_vector(31 downto 0);

  signal do_reprogram_i      : std_logic;
  signal reprogram_i         : std_logic;
  signal restart_fpga_counter: unsigned(11 downto 0);


  signal wren_addr_fifo      : std_logic;
  signal wren_length_fifo    : std_logic;
  signal df_data             : std_logic_vector(63 downto 0);
  signal df_empty            : std_logic_vector(1 downto 0);
  signal df_read             : std_logic_vector(1 downto 0);


  signal debugfifo_write   : std_logic;
  signal debugfifo_read    : std_logic;
  signal debugfifo_empty   : std_logic;
  signal debugfifo_full    : std_logic;
  signal debugfifo_out     : std_logic_vector(31 downto 0);          
  signal debugfifo_in      : std_logic_vector(31 downto 0);          
  
begin

  APL_MY_ADDRESS_IN <= x"FCCC";

  THE_HUB : trb_net16_hub_base
    generic map (
    --hub control
      INIT_ADDRESS               => x"FC00",
      COMPILE_TIME               => COMPILE_TIME,
      COMPILE_VERSION            => (others => '0'),
      HARDWARE_VERSION           => x"73000000",
      HUB_CTRL_BROADCAST_BITMASK => x"FF",
      HUB_USED_CHANNELS          => (c_NO,c_NO,c_NO,c_YES),
      CLOCK_FREQUENCY            => 150,
      USE_ONEWIRE                => c_NO,
      BROADCAST_SPECIAL_ADDR     => x"FF",
      MII_NUMBER                 => NUM_LINKS,
      MII_IS_UPLINK              => (others => c_YES), --NUM_LINKS => c_YES, NUM_LINKS+1 => c_YES,
      MII_IS_DOWNLINK            => (others => c_YES), --NUM_LINKS => c_YES, NUM_LINKS+1 => c_YES,
      MII_IS_UPLINK_ONLY         => (others => c_NO), --NUM_LINKS => c_YES,
      INIT_UNIQUE_ID             => x"1111222233334444",
      INIT_ENDPOINT_ID           => x"0001",
      INT_NUMBER                 => 3,
      INT_CHANNELS               => (0=>0,1=>1,2=>3,others=>0)
      )
    port map (
      CLK    => CLK,
      RESET  => reset_trbnet_i,
      CLK_EN => '1',

      --Media interfacces
      MED_DATAREADY_OUT => MED_DATAREADY_OUT,
      MED_DATA_OUT      => MED_DATA_OUT,
      MED_PACKET_NUM_OUT=> MED_PACKET_NUM_OUT,
      MED_READ_IN       => MED_READ_IN,
      MED_DATAREADY_IN  => MED_DATAREADY_IN,
      MED_DATA_IN       => MED_DATA_IN,
      MED_PACKET_NUM_IN => MED_PACKET_NUM_IN,
      MED_READ_OUT      => MED_READ_OUT,
      MED_STAT_OP       => MED_STAT_OP_IN,
      MED_CTRL_OP       => buf_med_ctrl_op,

      INT_INIT_DATAREADY_OUT    => buf_to_apl_INIT_DATAREADY,
      INT_INIT_DATA_OUT         => buf_to_apl_INIT_DATA,
      INT_INIT_PACKET_NUM_OUT   => buf_to_apl_INIT_PACKET_NUM,
      INT_INIT_READ_IN          => buf_to_apl_INIT_READ,
      INT_INIT_DATAREADY_IN     => apl_to_buf_INIT_DATAREADY,
      INT_INIT_DATA_IN          => apl_to_buf_INIT_DATA,
      INT_INIT_PACKET_NUM_IN    => apl_to_buf_INIT_PACKET_NUM,
      INT_INIT_READ_OUT         => apl_to_buf_INIT_READ,
      INT_REPLY_DATAREADY_OUT   => buf_to_apl_REPLY_DATAREADY,
      INT_REPLY_DATA_OUT        => buf_to_apl_REPLY_DATA,
      INT_REPLY_PACKET_NUM_OUT  => buf_to_apl_REPLY_PACKET_NUM,
      INT_REPLY_READ_IN         => buf_to_apl_REPLY_READ,
      INT_REPLY_DATAREADY_IN    => apl_to_buf_REPLY_DATAREADY,
      INT_REPLY_DATA_IN         => apl_to_buf_REPLY_DATA,
      INT_REPLY_PACKET_NUM_IN   => apl_to_buf_REPLY_PACKET_NUM,
      INT_REPLY_READ_OUT        => apl_to_buf_REPLY_READ,
      --REGIO INTERFACE
      REGIO_ADDR_OUT            => open,
      REGIO_READ_ENABLE_OUT     => open,
      REGIO_WRITE_ENABLE_OUT    => open,
      REGIO_DATA_OUT            => open,
      REGIO_DATA_IN             => (others => '0'),
      REGIO_DATAREADY_IN        => '0',
      REGIO_NO_MORE_DATA_IN     => '1',
      REGIO_WRITE_ACK_IN        => '0',
      REGIO_UNKNOWN_ADDR_IN     => '1',
      REGIO_TIMEOUT_OUT         => open,
      TIMER_TICKS_OUT           => timer_ticks,
      ONEWIRE            => open,
      ONEWIRE_MONITOR_IN => '0',
      ONEWIRE_MONITOR_OUT=> open,
      MY_ADDRESS_OUT     => my_address,
      COMMON_CTRL_REGS   => common_ctrl,
      COMMON_STAT_REGS   => common_stat,
      MPLEX_CTRL         => (others => '0'),
      CTRL_DEBUG         => hub_ctrl_debug,
      STAT_DEBUG         => hub_stat_debug
      );

  hub_ctrl_debug(2 downto 0)  <= not ERROR_OK;
  hub_ctrl_debug(31 downto 3) <= (others => '0');


  gen_pas_apis : for i in 0 to 2 generate
    DAT_ACTIVE_API: trb_net16_api_base
      generic map (
        API_TYPE          => c_API_ACTIVE,
        FIFO_TO_INT_DEPTH => c_FIFO_BRAM,
        FIFO_TO_APL_DEPTH => c_FIFO_BRAM,
        FORCE_REPLY       => cfg_FORCE_REPLY(i),
        SBUF_VERSION      => 0,
        USE_VENDOR_CORES    => c_YES,
        SECURE_MODE_TO_APL  => c_YES,
        SECURE_MODE_TO_INT  => c_YES,
        APL_WRITE_ALL_WORDS => c_YES,
        BROADCAST_BITMASK   => x"FF"
        )
      port map (
        --  Misc
        CLK    => CLK,
        RESET  => reset_trbnet_i,
        CLK_EN => '1',
        -- APL Transmitter port
        APL_DATA_IN           => APL_DATA_IN(i*16+15 downto i*16),
        APL_PACKET_NUM_IN     => APL_PACKET_NUM_IN(i*3+2 downto i*3),
        APL_DATAREADY_IN      => APL_DATAREADY_IN(i),
        APL_READ_OUT          => APL_READ_OUT(i),
        APL_SHORT_TRANSFER_IN => APL_SHORT_TRANSFER_IN(i),
        APL_DTYPE_IN          => APL_DTYPE_IN(i*4+3 downto i*4),
        APL_ERROR_PATTERN_IN  => APL_ERROR_PATTERN_IN(i*32+31 downto i*32),
        APL_SEND_IN           => APL_SEND_IN(i),
        APL_TARGET_ADDRESS_IN => APL_TARGET_ADDRESS_IN(i*16+15 downto i*16),
        -- Receiver port
        APL_DATA_OUT      => APL_DATA_OUT(i*16+15 downto i*16),
        APL_PACKET_NUM_OUT=> APL_PACKET_NUM_OUT(i*3+2 downto i*3),
        APL_TYP_OUT       => APL_TYP_OUT(i*3+2 downto i*3),
        APL_DATAREADY_OUT => APL_DATAREADY_OUT(i),
        APL_READ_IN       => APL_READ_IN(i),
        -- APL Control port
        APL_RUN_OUT       => APL_RUN_OUT(i),
        APL_MY_ADDRESS_IN => APL_MY_ADDRESS_IN,
        APL_LENGTH_IN     => x"FFFF",
        APL_SEQNR_OUT     => APL_SEQNR_OUT(i*8+7 downto i*8),
        APL_FIFO_COUNT_OUT => APL_FIFO_COUNT_OUT(i*11+10 downto i*11),
        -- Internal direction port
        INT_MASTER_DATAREADY_OUT => apl_to_buf_INIT_DATAREADY(i),
        INT_MASTER_DATA_OUT      => tmp_apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        INT_MASTER_PACKET_NUM_OUT=> apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        INT_MASTER_READ_IN       => apl_to_buf_INIT_READ(i),
        INT_MASTER_DATAREADY_IN  => buf_to_apl_INIT_DATAREADY(i),
        INT_MASTER_DATA_IN       => buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        INT_MASTER_PACKET_NUM_IN => buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        INT_MASTER_READ_OUT      => buf_to_apl_INIT_READ(i),
        INT_SLAVE_DATAREADY_OUT  => apl_to_buf_REPLY_DATAREADY(i),
        INT_SLAVE_DATA_OUT       => apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        INT_SLAVE_PACKET_NUM_OUT => apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        INT_SLAVE_READ_IN        => apl_to_buf_REPLY_READ(i),
        INT_SLAVE_DATAREADY_IN   => buf_to_apl_REPLY_DATAREADY(i),
        INT_SLAVE_DATA_IN        => buf_to_apl_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        INT_SLAVE_PACKET_NUM_IN  => buf_to_apl_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
        INT_SLAVE_READ_OUT       => buf_to_apl_REPLY_READ(i),
        CTRL_SEQNR_RESET         => '0',
        -- Status and control port
        STAT_FIFO_TO_INT => buf_api_stat_fifo_to_int(i*32+31 downto i*32),
        STAT_FIFO_TO_APL => buf_api_stat_fifo_to_apl(i*32+31 downto i*32)
        );

  end generate;

--Add additional word for trigger information
  apl_to_buf_INIT_DATA(apl_to_buf_INIT_DATA'left downto 16) <= tmp_apl_to_buf_INIT_DATA(apl_to_buf_INIT_DATA'left downto 16);

  proc_add_trigger_info : process(tmp_apl_to_buf_INIT_DATA, apl_to_buf_INIT_PACKET_NUM,reg_extended_trigger_information)
    begin
      if apl_to_buf_INIT_PACKET_NUM(2 downto 0) = c_F0 then
        apl_to_buf_INIT_DATA(15 downto 0) <= reg_extended_trigger_information;
      else
        apl_to_buf_INIT_DATA(15 downto 0) <= tmp_apl_to_buf_INIT_DATA(15 downto 0);
      end if;
    end process;

  apl_to_buf_INIT_DATAREADY(3)  <= '0';
  apl_to_buf_REPLY_DATAREADY(3) <= '0';
  apl_to_buf_INIT_READ(3)  <= '0';
  apl_to_buf_REPLY_READ(3) <= '0';

  tmp_apl_to_buf_INIT_DATA(48) <= '0';
  apl_to_buf_REPLY_DATA(48) <= '0';
  apl_to_buf_INIT_PACKET_NUM(9) <= '0';
  apl_to_buf_REPLY_PACKET_NUM(9) <= '0';


--------------------------------
-- r/w registers
--------------------------------

  process(CLK)
    begin
      if rising_edge(CLK) then
        bus_stb_last   <= BUS_STB_IN;
        bus_read_last  <= bus_read_i;
        bus_write_last <= bus_write_i;
        bus_wdat_last  <= BUS_WDAT_IN;
      end if;
    end process;

  bus_stb_rising <= BUS_STB_IN and not bus_stb_last;
  bus_read_i     <= not BUS_WE_IN and bus_stb_rising and not or_all(BUS_ADDR_IN(23 downto 16));
  bus_write_i    <=     BUS_WE_IN and bus_stb_rising and not or_all(BUS_ADDR_IN(23 downto 16));



  channel_address <= to_integer(unsigned(BUS_ADDR_IN(6 downto 5)));

  read_regs : process(sender_control, sender_target, sender_error, sender_status, apl_fifo_count_out,
          BUS_ADDR_IN, api_status, fifo_net_to_pci_empty, bus_data_i, channel_address, fifo_net_to_pci_dout)
    variable tmp : std_logic_vector(7 downto 0);
    begin
      bus_data_i <= (others => '0');
      tmp := BUS_ADDR_IN(11 downto 8) & BUS_ADDR_IN(3 downto 0);
        case tmp is      --middle nibble is dont care
          when x"10" =>
            bus_data_i <= sender_control(channel_address*32+31 downto channel_address*32);
          when x"12" =>
            bus_data_i <= sender_error(channel_address*32+31 downto channel_address*32);
          when x"15" =>
            if channel_address = 0 then
              bus_data_i <= x"0000" & reg_extended_trigger_information;
            else
              bus_data_i <= x"EE000000";
            end if;
          when x"1F" =>
            bus_data_i <= sender_status(channel_address*32+31 downto channel_address*32);
          when x"23" =>
            bus_data_i <= fifo_net_to_pci_dout(channel_address*32+31 downto channel_address*32);
          when x"24" =>
            bus_data_i <= x"000" & "00" & fifo_net_to_pci_empty(channel_address) & '0'
                                  & "00000" & apl_fifo_count_out(11*channel_address+10 downto 11*channel_address);
          when x"30" =>
            bus_data_i <= api_status(channel_address*32+31 downto channel_address*32);
          when x"72" =>
            bus_data_i <= dma_status_i;
          when x"73" =>
            bus_data_i <= dma_config_i;
          when x"74" =>
            bus_data_i <= status_dma_core(31 downto 0);
          when x"75" =>
            bus_data_i <= status_dma_core(63 downto 32);
          when x"76" =>
            bus_data_i <= status_dma_core(95 downto 64);
          when x"77" =>
            bus_data_i <= status_dma_core(127 downto 96);
          when x"78" =>
            bus_data_i <= status_dma_core(159 downto 128);
          when x"79" =>
            bus_data_i <= buf_api_stat_fifo_to_int(2*32+31 downto 2*32);
          when x"7a" =>
            bus_data_i <= buf_api_stat_fifo_to_apl(2*32+31 downto 2*32);
          when x"7b" =>
            bus_data_i <= hub_stat_debug;
          when x"E0" =>
            bus_data_i <= df_data(31 downto 0);
          when x"E1" =>
            bus_data_i <= df_data(63 downto 32);
          when x"EE" =>
            bus_data_i <= debugfifo_out;
          when others         =>
            bus_data_i <= x"EE000000"; --"1000000000000000000" & CTRL(31 downto 19);
        end case;
    end process;


  write_regs : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          sender_control <= (others => '0');
          sender_target  <= (others => '0');
          sender_error   <= (others => '0');
          dma_control_i  <= (others => '0');
          reg_extended_trigger_information  <= (others => '0');
          dma_config_i   <= x"00000020";
          wren_length_fifo <= '0';
          wren_addr_fifo <= '0';
        else
          dma_control_i  <= (others => '0');
          do_reprogram_i <= '0';
          wren_length_fifo <= '0';
          wren_addr_fifo <= '0';
          if bus_write_i = '1' and BUS_ADDR_IN(11 downto 8) = x"1" and USE_CHANNELS(channel_address) = c_YES then
            case BUS_ADDR_IN(3 downto 0) is
                            --middle nibble is dont care
              when x"0" =>
                sender_control(channel_address*32+31 downto channel_address*32) <= BUS_WDAT_IN(31 downto 0);
              when x"1" =>
                sender_target(channel_address*32+15 downto channel_address*32) <= BUS_WDAT_IN(15 downto 0);
              when x"2" =>
                sender_error(channel_address*32+31 downto channel_address*32) <= BUS_WDAT_IN(31 downto 0);
              when x"5" =>
                if channel_address = 0 then
                  reg_extended_trigger_information <= BUS_WDAT_IN(15 downto 0);
                end if;
              when others => null;
            end case;
          elsif bus_write_i = '1' and BUS_ADDR_IN(11 downto 8) = x"7" then
            case BUS_ADDR_IN(3 downto 0) is
              when x"0" =>
                wren_addr_fifo      <= '1';
              when x"1" =>
                wren_length_fifo    <= '1';
              when x"2" =>
                dma_control_i       <= BUS_WDAT_IN;  --pulses only!
              when x"3" =>
                dma_config_i        <= BUS_WDAT_IN;
              when others => null;
            end case;
          elsif bus_write_i = '1' and BUS_ADDR_IN(23 downto 0) = x"000020" then
            do_reprogram_i <= '1';
          end if;
        end if;
      end if;
    end process;

df_read(0) <= '1' when BUS_ADDR_IN(15 downto 0) = x"0e00" and bus_read_i = '1' else '0';
df_read(1) <= '1' when BUS_ADDR_IN(15 downto 0) = x"0e01" and bus_read_i = '1' else '0';


--------------------------------
-- Debug bus communication
--------------------------------

debugfifo_read <= '1' when (bus_read_i='1' and BUS_ADDR_IN(15 downto 0) = x"0e0e") or debugfifo_full = '1' else '0';
debugfifo_write <= '1' when (bus_read_last or bus_write_i) = '1' and BUS_ADDR_IN(11 downto 0) /= x"702" and BUS_ADDR_IN(11 downto 0) /= x"273" and BUS_ADDR_IN(11 downto 8) /= x"e" else '0';
debugfifo_in    <= bus_write_i & BUS_ADDR_IN(10 downto 8) & BUS_ADDR_IN(3 downto 0) & BUS_WDAT_IN(31 downto 28) &  BUS_WDAT_IN(19 downto 0) when bus_write_i = '1' 
              else bus_write_i & BUS_ADDR_IN(10 downto 8) & BUS_ADDR_IN(3 downto 0) & bus_data_i(31 downto 28) &  bus_data_i(19 downto 0);

DEBUG_FIFO : fifo_32x512
    port map(
        Data  => debugfifo_in,
        Clock => CLK,
        WrEn  => debugfifo_write,
        RdEn  => debugfifo_read, 
        Reset => RESET, 
        Q     => debugfifo_out,
        Empty => debugfifo_empty,
        Full  => debugfifo_full
        );

        
--------------------------------
-- connection to API
--------------------------------

  proc_api_connect : process(apl_seqnr_out, apl_run_out, BUS_ADDR_IN, bus_write_last, bus_write_i,
          sender_control, sender_error, fifo_net_to_pci_read, apl_dataready_out,
          fifo_net_to_pci_valid_read, apl_packet_num_out, sender_target)
    begin
      api_status         <= (others => '0');
      sender_status      <= (others => '0');
      next_apl_send_in   <= (others => '0');
      apl_dataready_in   <= (others => '0');
      api_status(0*32+7 downto 0*32)      <= apl_seqnr_out(0*8+7 downto 0*8);
      api_status(1*32+7 downto 1*32)      <= apl_seqnr_out(1*8+7 downto 1*8);
      api_status(3*32+7 downto 3*32)      <= apl_seqnr_out(2*8+7 downto 2*8);
      sender_status(0*32)                 <= apl_run_out(0);
      sender_status(1*32)                 <= apl_run_out(1);
      sender_status(3*32)                 <= apl_run_out(2);
      if BUS_ADDR_IN(11 downto 0) = x"110" and bus_write_last = '1' then
        next_apl_send_in(0) <= '1';
      end if;
      if BUS_ADDR_IN(11 downto 0) = x"130" and bus_write_last = '1' then
        next_apl_send_in(1) <= '1';
      end if;
      if BUS_ADDR_IN(11 downto 0) = x"170" and bus_write_last = '1' then
        next_apl_send_in(2) <= '1';
      end if;
      if BUS_ADDR_IN(11 downto 0) = x"113" and bus_write_i = '1' then
        apl_dataready_in(0) <= '1';
      end if;
      if BUS_ADDR_IN(11 downto 0) = x"133" and bus_write_i = '1' then
        apl_dataready_in(1) <= '1';
      end if;
      if BUS_ADDR_IN(11 downto 0) = x"173" and bus_write_i = '1' then
        apl_dataready_in(2) <= '1';
      end if;

      apl_data_in           <= BUS_WDAT_IN(15 downto 0) & BUS_WDAT_IN(15 downto 0) & BUS_WDAT_IN(15 downto 0);
      apl_packet_num_in     <= '0' & BUS_WDAT_IN(17 downto 16) & '0' & BUS_WDAT_IN(17 downto 16) & '0' & BUS_WDAT_IN(17 downto 16);
      apl_short_transfer_in <= sender_control(96+8) & sender_control(32+8) & sender_control(8);
      apl_error_pattern_in  <= sender_error(127 downto 96) & sender_error(63 downto 32) & sender_error(31 downto 0);
      apl_target_address_in <= sender_control(127 downto 112) & sender_control(63 downto 48) & sender_control(31 downto 16);
    --   apl_target_address_in <= sender_target(111 downto 96) & sender_target(47 downto 32) & sender_target(15 downto 0);
      apl_dtype_in          <= sender_control(99 downto 96) & sender_control(35 downto 32) & sender_control(3 downto 0);

      apl_read_in           <= (fifo_net_to_pci_read(3) or apl_read_dma) & fifo_net_to_pci_read(1) & fifo_net_to_pci_read(0);
      fifo_net_to_pci_empty  <= not (apl_dataready_out(2) & '0' & apl_dataready_out(1) & apl_dataready_out(0));
      fifo_net_to_pci_dout(31 downto 0)   <= "000000" & (APL_RUN_OUT(0) or link_not_up) & fifo_net_to_pci_valid_read(0) & "000000"
                                            & apl_packet_num_out(2) & apl_packet_num_out(0) & apl_data_out(15 downto 0);
      fifo_net_to_pci_dout(63 downto 32)  <= "000000" & (APL_RUN_OUT(1) or link_not_up) & fifo_net_to_pci_valid_read(1) & "000000"
                                            & apl_packet_num_out(5) & apl_packet_num_out(3) & apl_data_out(31 downto 16);
      fifo_net_to_pci_dout(95 downto 64)  <= (others => '0');
      fifo_net_to_pci_dout(127 downto 96) <= "000000" & (APL_RUN_OUT(2) or link_not_up) & fifo_net_to_pci_valid_read(3) & "000000"
                                            & apl_packet_num_out(8) & apl_packet_num_out(6) & apl_data_out(47 downto 32);
    end process;

  link_not_up <= '1' when MED_STAT_OP_IN(2 downto 0) /= ERROR_OK else '0';
		
  proc_fifo_readwrite : process(BUS_ADDR_IN, bus_read_i, channel_address, apl_dataready_out, fifo_net_to_pci_read)
    begin
      fifo_net_to_pci_valid_read(0) <= fifo_net_to_pci_read(0) and apl_dataready_out(0);
      fifo_net_to_pci_valid_read(1) <= fifo_net_to_pci_read(1) and apl_dataready_out(1);
      fifo_net_to_pci_valid_read(3) <= fifo_net_to_pci_read(3) and apl_dataready_out(2);
      fifo_net_to_pci_read <= (others => '0');
      if BUS_ADDR_IN(11 downto 8) & BUS_ADDR_IN(3 downto 0) = x"23" then
        fifo_net_to_pci_read(channel_address) <= bus_read_i;
      end if;
    end process;

  proc_register_cpu_output : process(CLK)
    begin
      if rising_edge(CLK) then
        apl_send_in <= next_apl_send_in;
        if spictrl_ack = '1' then
          BUS_RDAT_OUT <= spictrl_data_out;
        elsif spimem_ack = '1' then
          BUS_RDAT_OUT <= spimem_data_out;
        else
          BUS_RDAT_OUT <= bus_data_i(31 downto 0);
        end if;
        BUS_ACK_OUT  <= (bus_read_i or bus_write_i) or bus_spi_ack_i;
      end if;
    end process;


THE_DMA_CORE : dma_core
  port map(
    RESET_IN             => RESET,
    CLK_IN               => CLK,
    CLK_125_IN           => CLK_125_IN,

    DMA_DATA_IN          => bus_wdat_last,
    DMA_LENGTH_WR_IN     => wren_length_fifo,
    DMA_ADDR_WR_IN       => wren_addr_fifo,

    DMA_CONTROL_IN       => dma_control_i,
    DMA_STATUS_OUT       => dma_status_i,
    DMA_CONFIG_IN        => dma_config_i,

    API_RUNNING_IN       => apl_run_out(2),
    API_DATA_IN          => apl_data_out(47 downto 32),
    API_PACKET_NUM_IN    => apl_packet_num_out(8 downto 6),
    API_TYP_IN           => apl_typ_out(8 downto 6),
    API_DATAREADY_IN     => apl_dataready_out(2),
    API_READ_OUT         => apl_read_dma,

    REQUESTOR_ID_IN      => REQUESTOR_ID_IN,
    TX_ST_OUT            => TX_ST_OUT,
    TX_END_OUT           => TX_END_OUT,
    TX_DWEN_OUT          => TX_DWEN_OUT,
    TX_DATA_OUT          => TX_DATA_OUT,
    TX_REQ_OUT           => TX_REQ_OUT,
    TX_RDY_IN            => TX_RDY_IN,
    TX_VAL_IN            => TX_VAL_IN,
    TX_CA_PH_IN          => TX_CA_PH_IN,
    TX_CA_PD_IN          => TX_CA_PD_IN,
    TX_CA_NPH_IN         => TX_CA_NPH_IN,

    RX_CR_CPLH_OUT       => RX_CR_CPLH_OUT,
    RX_CR_CPLD_OUT       => RX_CR_CPLD_OUT,
    UNEXP_CMPL_OUT       => UNEXP_CMPL_OUT,
    RX_ST_IN             => RX_ST_IN,
    RX_END_IN            => RX_END_IN,
    RX_DWEN_IN           => RX_DWEN_IN,
    RX_DATA_IN           => RX_DATA_IN,

    DEBUG_FIFO_DATA_OUT  => df_data,
    DEBUG_FIFO_EMPTY_OUT => df_empty,
    DEBUG_FIFO_READ_IN   => df_read,
           
    STATUS_REG_OUT       => status_dma_core,
    DEBUG_OUT            => debug_dma_core

    );



--------------------------------
-- SPI Flash Programming
--------------------------------

  THE_SPI_MASTER: spi_master
    port map(
      CLK_IN         => CLK,
      RESET_IN       => RESET,
      -- Slave bus
      BUS_READ_IN    => spictrl_read_en,
      BUS_WRITE_IN   => spictrl_write_en,
      BUS_BUSY_OUT   => open, --spictrl_busy,
      BUS_ACK_OUT    => spictrl_ack,
      BUS_ADDR_IN(0) => BUS_ADDR_IN(0), --spictrl_addr,
      BUS_DATA_IN    => BUS_WDAT_IN, --spictrl_data_in,
      BUS_DATA_OUT   => spictrl_data_out,
      -- SPI connections
      SPI_CS_OUT     => SPI_CE_OUT,
      SPI_SDI_IN     => SPI_D_IN,
      SPI_SDO_OUT    => SPI_D_OUT,
      SPI_SCK_OUT    => SPI_CLK_OUT,
      -- BRAM for read/write data
      BRAM_A_OUT     => spi_bram_addr,
      BRAM_WR_D_IN   => spi_bram_wr_d,
      BRAM_RD_D_OUT  => spi_bram_rd_d,
      BRAM_WE_OUT    => spi_bram_we,
      -- Status lines
      STAT           => open
      );

  -- data memory for SPI accesses
  THE_SPI_MEMORY: spi_databus_memory
    port map(
      CLK_IN        => CLK,
      RESET_IN      => RESET,
      -- Slave bus
      BUS_READ_IN   => spimem_read_en,
      BUS_WRITE_IN  => spimem_write_en,
      BUS_ACK_OUT   => spimem_ack,
      BUS_ADDR_IN   => BUS_ADDR_IN(5 downto 0),
      BUS_DATA_IN   => BUS_WDAT_IN, --spimem_data_in,
      BUS_DATA_OUT  => spimem_data_out,
      -- state machine connections
      BRAM_ADDR_IN  => spi_bram_addr,
      BRAM_WR_D_OUT => spi_bram_wr_d,
      BRAM_RD_D_IN  => spi_bram_rd_d,
      BRAM_WE_IN    => spi_bram_we,
      -- Status lines
      STAT          => open
      );



  spictrl_read_en  <= '1' when BUS_WE_IN = '0' and bus_stb_rising = '1' and
                               BUS_ADDR_IN(23 downto 8) = x"01d0" else '0';
  spictrl_write_en <= '1' when BUS_WE_IN = '1' and bus_stb_rising = '1' and
                               BUS_ADDR_IN(23 downto 8) = x"01d0" else '0';

  spimem_read_en   <= '1' when BUS_WE_IN = '0' and bus_stb_rising = '1' and
                               BUS_ADDR_IN(23 downto 8) = x"01d1" else '0';
  spimem_write_en  <= '1' when BUS_WE_IN = '1' and bus_stb_rising = '1' and
                               BUS_ADDR_IN(23 downto 8) = x"01d1" else '0';


  bus_spi_ack_i <= spimem_ack or spictrl_ack or spi_fake_ack;
  spi_fake_ack <= '1' when (BUS_ADDR_IN(23 downto 16) = x"01" and bus_stb_rising = '1' and
                              (spictrl_read_en or spictrl_write_en or spimem_read_en or spimem_write_en) = '0')
                      else '0';


---------------------------------------------------------------------------
--Restart FPGA from Flash
---------------------------------------------------------------------------
  --delay restart command to finish trbnet transfer
  process (CLK)
    begin
      if rising_edge(CLK) then
        PROGRMN_OUT <= not reprogram_i;
        reprogram_i <= '0';
        if RESET = '1' then
          restart_fpga_counter <= to_unsigned(0,12);
        elsif do_reprogram_i = '1' then
          restart_fpga_counter <= to_unsigned(4095,12);
        elsif restart_fpga_counter /= to_unsigned(0,12) then
          restart_fpga_counter <= restart_fpga_counter - to_unsigned(1,1);
          if restart_fpga_counter <= to_unsigned(255,12) then
            reprogram_i <= '1';
          end if;
        end if;
      end if;
    end process;


--------------------------------
-- network reset
--------------------------------
  gen_med_ctrl : for i in 0 to NUM_LINKS-1 generate
    MED_CTRL_OP_OUT(i*16+14 downto i*16) <= buf_med_ctrl_op(i*16+14 downto i*16);
    MED_CTRL_OP_OUT(i*16+15)             <= buf_med_ctrl_op(i*16+15) or not send_reset_counter(10);
  end generate;

  SEND_RESET_OUT <= not send_reset_counter(10);
  MAKE_RESET_OUT <= '1' when and_all(std_logic_vector(send_reset_counter(9 downto 0))) = '1' or (BUS_ADDR_IN = x"00000011" and bus_write_i = '1') else '0';
  reset_trbnet_i <= '1' when RESET_TRBNET = '1' or (BUS_ADDR_IN = x"00000012" and bus_write_i = '1') else '0';
  
  
  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          send_reset_counter <= "10000000000";
        elsif BUS_ADDR_IN = x"00000010" and bus_write_i = '1' and BUS_WDAT_IN(15) = '1'  then
          send_reset_counter <= (others => '0');
        elsif send_reset_counter(10) = '0' then
          send_reset_counter <= send_reset_counter + to_unsigned(1,1);
        end if;
      end if;
    end process;

DEBUG_OUT <= debug_dma_core;

end architecture;