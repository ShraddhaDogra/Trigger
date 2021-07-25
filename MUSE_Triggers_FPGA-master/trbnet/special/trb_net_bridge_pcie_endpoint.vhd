LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net_bridge_pcie_endpoint is
  generic(
    USE_CHANNELS : channel_config_t := (c_YES,c_YES,c_NO,c_YES)
    );
  port(
    RESET :   in std_logic;
    CLK:      in std_logic;

    BUS_ADDR_IN      : in  std_logic_vector(31 downto 0);
    BUS_WDAT_IN      : in  std_logic_vector(31 downto 0);
    BUS_RDAT_OUT     : out std_logic_vector(31 downto 0);
    BUS_SEL_IN       : in  std_logic_vector(3 downto 0);
    BUS_WE_IN        : in  std_logic;
    BUS_CYC_IN       : in  std_logic;
    BUS_STB_IN       : in  std_logic;
    BUS_LOCK_IN      : in  std_logic;
    BUS_ACK_OUT      : out std_logic;

    MED_DATAREADY_IN   : in  STD_LOGIC;
    MED_DATA_IN        : in  STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN  : in  STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT       : out STD_LOGIC;

    MED_DATAREADY_OUT  : out STD_LOGIC;
    MED_DATA_OUT       : out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
    MED_READ_IN        : in  STD_LOGIC;

    MED_ERROR_IN       : in std_logic_vector(2 downto 0);
    SEND_RESET_OUT     : out std_logic;
    STAT               : out std_logic_vector(31 downto 0);
    STAT_ENDP          : out std_logic_vector(31 downto 0);
    STAT_API1          : out std_logic_vector(31 downto 0)
    );
end entity;


architecture trb_net_bridge_pcie_endpoint_arch of trb_net_bridge_pcie_endpoint is


  signal APL_STAT : std_logic_vector(31 downto 0);

  signal APL_DATA_IN            : std_logic_vector(4*16-1 downto 0);
  signal APL_PACKET_NUM_IN      : std_logic_vector(4*3-1 downto 0);
  signal APL_DATAREADY_IN       : std_logic_vector(4-1 downto 0);
  signal APL_READ_OUT           : std_logic_vector(4-1 downto 0);
  signal APL_SHORT_TRANSFER_IN  : std_logic_vector(4-1 downto 0);
  signal APL_DTYPE_IN           : std_logic_vector(4*4-1 downto 0);
  signal APL_SEND_IN            : std_logic_vector(4-1 downto 0);
  signal APL_DATA_OUT           : std_logic_vector(4*16-1 downto 0);
  signal APL_PACKET_NUM_OUT     : std_logic_vector(4*3-1 downto 0);
  signal APL_TYP_OUT            : std_logic_vector(4*3-1 downto 0);
  signal APL_DATAREADY_OUT      : std_logic_vector(4-1 downto 0);
  signal APL_READ_IN            : std_logic_vector(4-1 downto 0);
  signal APL_RUN_OUT            : std_logic_vector(4-1 downto 0);
  signal APL_SEQNR_OUT          : std_logic_vector(4*8-1 downto 0);
  signal APL_TARGET_ADDRESS_OUT : std_logic_vector(4*16-1 downto 0);
  signal APL_ERROR_PATTERN_IN   : std_logic_vector(4*32-1 downto 0);
  signal APL_TARGET_ADDRESS_IN  : std_logic_vector(4*16-1 downto 0);
  signal APL_FIFO_COUNT_OUT     : std_logic_vector(4*11-1 downto 0);
  signal APL_MY_ADDRESS_IN      : std_logic_vector(15 downto 0);

  signal buf_api_stat_fifo_to_int : std_logic_vector(4*32-1 downto 0);
  signal buf_api_stat_fifo_to_apl : std_logic_vector(4*32-1 downto 0);

  signal CLK_EN : std_logic;

  signal m_DATAREADY_OUT : std_logic_vector (2**c_MUX_WIDTH-1 downto 0);
  signal m_DATA_OUT      : std_logic_vector (c_DATA_WIDTH*2**c_MUX_WIDTH-1 downto 0);
  signal m_PACKET_NUM_OUT: std_logic_vector (c_NUM_WIDTH*2**c_MUX_WIDTH-1 downto 0);
  signal m_READ_IN       : std_logic_vector (2**c_MUX_WIDTH-1 downto 0);
  signal m_DATAREADY_IN  : std_logic_vector ((2**(c_MUX_WIDTH-1))-1 downto 0);
  signal m_DATA_IN       : std_logic_vector (4*c_DATA_WIDTH-1 downto 0);
  signal m_PACKET_NUM_IN : std_logic_vector (4*c_NUM_WIDTH-1 downto 0);
  signal m_READ_OUT      : std_logic_vector ((2**(c_MUX_WIDTH-1))-1 downto 0);
  signal MPLEX_CTRL      : std_logic_vector (31 downto 0);

  signal apl_to_buf_INIT_DATAREADY: std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);
  signal apl_to_buf_INIT_DATA     : std_logic_vector (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
  signal tmp_apl_to_buf_INIT_DATA : std_logic_vector (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
  signal apl_to_buf_INIT_PACKET_NUM:std_logic_vector (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
  signal apl_to_buf_INIT_READ     : std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);

  signal buf_to_apl_INIT_DATAREADY: std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);
  signal buf_to_apl_INIT_DATA     : std_logic_vector (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
  signal buf_to_apl_INIT_PACKET_NUM:std_logic_vector (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
  signal buf_to_apl_INIT_READ     : std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);

  signal apl_to_buf_REPLY_DATAREADY: std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);
  signal apl_to_buf_REPLY_DATA     : std_logic_vector (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
  signal apl_to_buf_REPLY_PACKET_NUM:std_logic_vector (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
  signal apl_to_buf_REPLY_READ     : std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);

  signal buf_to_apl_REPLY_DATAREADY: std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);
  signal buf_to_apl_REPLY_DATA     : std_logic_vector (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
  signal buf_to_apl_REPLY_PACKET_NUM:std_logic_vector (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
  signal buf_to_apl_REPLY_READ     : std_logic_vector(2**(c_MUX_WIDTH-1)-1 downto 0);


  signal STAT_GEN               : std_logic_vector(32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal STAT_INIT_BUFFER       : std_logic_vector(32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal CTRL_GEN               : std_logic_vector(32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal CTRL_LOCKED            : std_logic_vector(32*2**(c_MUX_WIDTH-1)-1 downto 0);
  signal RESET_i : std_logic;
  signal RESET_CNT : std_logic_vector(1 downto 0);
  signal counter : std_logic_vector(12 downto 0);
  signal buf_MED_DATAREADY_OUT : std_logic;

  signal reg_extended_trigger_information : std_logic_vector(15 downto 0);

begin
  CLK_EN <= '1';
  APL_MY_ADDRESS_IN <= x"F00C";
  RESET_i <= RESET;


  MED_DATAREADY_OUT <= buf_MED_DATAREADY_OUT;

  MPLEX_CTRL <= (others => '0');
  THE_MPLEX: trb_net16_io_multiplexer
    port map (
      CLK      => CLK,
      RESET    => RESET_i,
      CLK_EN   => CLK_EN,
      MED_DATAREADY_IN   => MED_DATAREADY_IN,
      MED_DATA_IN        => MED_DATA_IN,
      MED_PACKET_NUM_IN  => MED_PACKET_NUM_IN,
      MED_READ_OUT       => MED_READ_OUT,
      MED_DATAREADY_OUT  => buf_MED_DATAREADY_OUT,
      MED_DATA_OUT       => MED_DATA_OUT,
      MED_PACKET_NUM_OUT => MED_PACKET_NUM_OUT,
      MED_READ_IN        => MED_READ_IN,
      INT_DATAREADY_OUT  => m_DATAREADY_IN,
      INT_DATA_OUT       => m_DATA_IN,
      INT_PACKET_NUM_OUT => m_PACKET_NUM_IN,
      INT_READ_IN        => m_READ_OUT,
      INT_DATAREADY_IN   => m_DATAREADY_OUT,
      INT_DATA_IN        => m_DATA_OUT,
      INT_PACKET_NUM_IN  => m_PACKET_NUM_OUT,
      INT_READ_OUT       => m_READ_IN,
      CTRL               => MPLEX_CTRL
      );

  gen_iobufs : for i in 0 to 2**(c_MUX_WIDTH-1)-1 generate
    gen_used_channel : if USE_CHANNELS(i) = c_YES generate
      IOBUF: trb_net16_iobuf
        generic map (
          USE_CHECKSUM => cfg_USE_CHECKSUM(i),
          INIT_CAN_SEND_DATA     => c_YES,
          INIT_CAN_RECEIVE_DATA  => c_NO,
          REPLY_CAN_SEND_DATA    => c_NO,
          REPLY_CAN_RECEIVE_DATA => c_YES
          )
        port map (
          --  Misc
          CLK     => CLK ,
          RESET   => RESET_i,
          CLK_EN  => CLK_EN,
          --  Media direction port
          MED_INIT_DATAREADY_OUT  => m_DATAREADY_OUT(i*2),
          MED_INIT_DATA_OUT       => m_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH*2),
          MED_INIT_PACKET_NUM_OUT => m_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto i*2*c_NUM_WIDTH),
          MED_INIT_READ_IN        => m_READ_IN(i*2),
          MED_REPLY_DATAREADY_OUT => m_DATAREADY_OUT(i*2+1),
          MED_REPLY_DATA_OUT      => m_DATA_OUT((i*2+2)*c_DATA_WIDTH-1 downto (i*2+1)*c_DATA_WIDTH),
          MED_REPLY_PACKET_NUM_OUT=> m_PACKET_NUM_OUT((i*2+2)*c_NUM_WIDTH-1 downto (i*2+1)*c_NUM_WIDTH),
          MED_REPLY_READ_IN       => m_READ_IN(i*2+1),
          MED_DATAREADY_IN   => m_DATAREADY_IN(i),
          MED_DATA_IN        => m_DATA_IN(i*c_DATA_WIDTH+15 downto i*c_DATA_WIDTH),
          MED_PACKET_NUM_IN  => m_PACKET_NUM_IN(i*c_NUM_WIDTH+2 downto i*c_NUM_WIDTH),
          MED_READ_OUT       => m_READ_OUT(i),
          MED_ERROR_IN       => MED_ERROR_IN,
          -- Internal direction port
          INT_INIT_DATAREADY_OUT => buf_to_apl_INIT_DATAREADY(i),
          INT_INIT_DATA_OUT      => buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
          INT_INIT_PACKET_NUM_OUT=> buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
          INT_INIT_READ_IN       => buf_to_apl_INIT_READ(i),
          INT_INIT_DATAREADY_IN  => apl_to_buf_INIT_DATAREADY(i),
          INT_INIT_DATA_IN       => apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
          INT_INIT_PACKET_NUM_IN => apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
          INT_INIT_READ_OUT      => apl_to_buf_INIT_READ(i),
          INT_REPLY_DATAREADY_OUT => buf_to_apl_REPLY_DATAREADY(i),
          INT_REPLY_DATA_OUT      => buf_to_apl_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
          INT_REPLY_PACKET_NUM_OUT=> buf_to_apl_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
          INT_REPLY_READ_IN       => buf_to_apl_REPLY_READ(i),
          INT_REPLY_DATAREADY_IN  => apl_to_buf_REPLY_DATAREADY(i),
          INT_REPLY_DATA_IN       => apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
          INT_REPLY_PACKET_NUM_IN => apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
          INT_REPLY_READ_OUT      => apl_to_buf_REPLY_READ(i),
          -- Status and control port
          STAT_GEN               => STAT_GEN((i+1)*32-1 downto i*32),
          STAT_IBUF_BUFFER       => STAT_INIT_BUFFER((i+1)*32-1 downto i*32),
          CTRL_GEN               => CTRL_GEN((i+1)*32-1 downto i*32)
          );
    end generate;
    gen_not_used_channel : if USE_CHANNELS(i) = c_NO generate
        apl_to_buf_INIT_READ(i) <= '0';
        apl_to_buf_INIT_DATAREADY(i) <= '0';
        apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
        apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
        apl_to_buf_REPLY_DATAREADY(i) <= '0';
        apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
        apl_to_buf_REPLY_READ(i) <= '0';
        apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
        buf_to_apl_INIT_READ(i) <= '0';
        buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
        buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
        buf_to_apl_INIT_DATAREADY(i) <= '0';
        buf_to_apl_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= (others => '0');
        buf_to_apl_REPLY_DATAREADY(i) <= '0';
        buf_to_apl_REPLY_READ(i) <= '0';
        buf_to_apl_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
        CTRL_GEN((i+1)*32-1 downto i*32) <= (others => '0');
        STAT_GEN((i+1)*32-1 downto i*32) <= (others => '0');
        STAT_INIT_BUFFER((i+1)*32-1 downto i*32) <= (others => '0');

      termbuf: trb_net16_term_buf
        port map(
          CLK    => CLK,
          RESET  => RESET,
          CLK_EN => CLK_EN,
          MED_DATAREADY_IN       => m_DATAREADY_IN(i),
          MED_DATA_IN            => m_DATA_IN(i*16+15 downto i*16),
          MED_PACKET_NUM_IN      => m_PACKET_NUM_IN(i*3+2 downto i*3),
          MED_READ_OUT           => m_READ_OUT(i),

          MED_INIT_DATAREADY_OUT  => m_DATAREADY_OUT(i*2),
          MED_INIT_DATA_OUT       => m_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*2*c_DATA_WIDTH),
          MED_INIT_PACKET_NUM_OUT => m_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto i*2*c_NUM_WIDTH),
          MED_INIT_READ_IN        => m_READ_IN(i*2),
          MED_REPLY_DATAREADY_OUT => m_DATAREADY_OUT(i*2+1),
          MED_REPLY_DATA_OUT      => m_DATA_OUT((i*2+2)*c_DATA_WIDTH-1 downto (i*2+1)*c_DATA_WIDTH),
          MED_REPLY_PACKET_NUM_OUT=> m_PACKET_NUM_OUT((i*2+2)*c_NUM_WIDTH-1 downto (i*2+1)*c_NUM_WIDTH),
          MED_REPLY_READ_IN       => m_READ_IN(i*2+1)
          );
    end generate;
  end generate;

  CTRL_GEN <= (others => '0');

  gen_pas_apis : for i in 0 to 2**(c_MUX_WIDTH-1)-1 generate
    gen_used_api : if USE_CHANNELS(i) = c_YES generate
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
          RESET  => RESET_i,
          CLK_EN => CLK_EN,
          -- APL Transmitter port
          APL_DATA_IN           => APL_DATA_IN(i*16+15 downto i*16),
          APL_PACKET_NUM_IN     => APL_PACKET_NUM_IN(i*3+2 downto i*3),
          APL_DATAREADY_IN          => APL_DATAREADY_IN(i),
          APL_READ_OUT     => APL_READ_OUT(i),
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
    gen_no_api : if USE_CHANNELS(i) = c_NO generate
      APL_READ_OUT(i)   <= '1';
      APL_DATA_OUT(i*16+15 downto i*16) <= (others => '0');
      APL_PACKET_NUM_OUT(i*3+2 downto i*3) <= (others => '0');
      APL_TYP_OUT(i*3+2 downto i*3) <= (others => '0');
      APL_DATAREADY_OUT(i)   <= '0';
      APL_RUN_OUT(i)   <= '0';
      APL_SEQNR_OUT(i*8+7 downto i*8) <= (others => '0');
      buf_api_stat_fifo_to_int(i*32+31 downto i*32) <= (others => '0');
      buf_api_stat_fifo_to_apl(i*32+31 downto i*32) <= (others => '0');
      tmp_apl_to_buf_init_data(i*16+15 downto i*16) <= (others => '0');
      APL_FIFO_COUNT_OUT(i*11+10 downto i*11)       <= (others => '0');
    end generate;
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




  APL : trb_net_bridge_pcie_apl
    generic map(
      USE_CHANNELS => USE_CHANNELS
      )
    port map(
      CLK     => CLK,
      RESET   => RESET_i,
      CLK_EN  => CLK_EN,
      APL_DATA_OUT           => APL_DATA_IN,
      APL_PACKET_NUM_OUT     => APL_PACKET_NUM_IN,
      APL_DATAREADY_OUT      => APL_DATAREADY_IN,
      APL_READ_IN            => APL_READ_OUT,
      APL_SHORT_TRANSFER_OUT => APL_SHORT_TRANSFER_IN,
      APL_DTYPE_OUT          => APL_DTYPE_IN,
      APL_ERROR_PATTERN_OUT  => APL_ERROR_PATTERN_IN,
      APL_SEND_OUT           => APL_SEND_IN,
      APL_DATA_IN            => APL_DATA_OUT,
      APL_PACKET_NUM_IN      => APL_PACKET_NUM_OUT,
      APL_TYP_IN             => APL_TYP_OUT,
      APL_DATAREADY_IN       => APL_DATAREADY_OUT,
      APL_READ_OUT           => APL_READ_IN,
      APL_RUN_IN             => APL_RUN_OUT,
      APL_SEQNR_IN           => APL_SEQNR_OUT,
      APL_TARGET_ADDRESS_OUT => APL_TARGET_ADDRESS_IN,
      APL_FIFO_COUNT_IN      => APL_FIFO_COUNT_OUT,
      EXT_TRIGGER_INFO       => reg_extended_trigger_information,
      BUS_ADDR_IN            => BUS_ADDR_IN,
      BUS_WDAT_IN            => BUS_WDAT_IN,
      BUS_RDAT_OUT           => BUS_RDAT_OUT,
      BUS_SEL_IN             => BUS_SEL_IN,
      BUS_WE_IN              => BUS_WE_IN,
      BUS_CYC_IN             => BUS_CYC_IN,
      BUS_STB_IN             => BUS_STB_IN,
      BUS_LOCK_IN            => BUS_LOCK_IN,
      BUS_ACK_OUT            => BUS_ACK_OUT,
      SEND_RESET_OUT         => SEND_RESET_OUT,
      STAT                   => STAT,
      CTRL                   => (others => '0')
      );

STAT_ENDP(0) <= APL_SEND_IN(1);
STAT_ENDP(4 downto 1) <= BUS_ADDR_IN(3 downto 0);
STAT_ENDP(5) <= BUS_WE_IN;
STAT_ENDP(6) <= APL_READ_OUT(1);
STAT_ENDP(7) <= buf_MED_DATAREADY_OUT;
STAT_ENDP(11 downto 8) <= APL_DATA_OUT(51 downto 48);
STAT_ENDP(13 downto 12) <= APL_PACKET_NUM_OUT(4 downto 3);
STAT_ENDP(14) <= APL_DATAREADY_OUT(3);
STAT_ENDP(15) <= buf_to_apl_REPLY_DATAREADY(0);
STAT_ENDP(16) <= APL_READ_IN(3);

STAT_ENDP(17) <= '0';
STAT_ENDP(18) <= '0';

STAT_ENDP(21 downto 19) <= APL_PACKET_NUM_OUT(11 downto 9);
STAT_ENDP(22)           <= APL_DATAREADY_OUT(3);
STAT_ENDP(23)           <= APL_READ_IN(3);
STAT_ENDP(31 downto 24) <= APL_DATA_OUT(55 downto 48);


STAT_API1(3 downto 0)   <= apl_to_buf_REPLY_DATA(19 downto 16);
STAT_API1(7 downto 4)   <= apl_to_buf_REPLY_DATA(19 downto 16);

STAT_API1(11)           <= apl_to_buf_REPLY_READ(3);
STAT_API1(12)           <= buf_to_apl_REPLY_DATAREADY(3);
STAT_API1(13)           <= apl_to_buf_INIT_DATAREADY(3);
STAT_API1(14)           <= buf_to_apl_INIT_READ(3);
STAT_API1(31 downto 15) <= (others => '0');


--STAT_API1 <= buf_api_stat_fifo_to_int((2)*32-1 downto (1)*32);

end architecture;