
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;



entity trb_net16_endpoint_2_trg is
  generic (
      --channel numbers
    LVL1_CHANNEL_NUM : integer := 0;
    LVL2_CHANNEL_NUM : integer := 1;
      --register error_pattern_in?
    LVL1_SECURE_MODE : integer := std_TERM_SECURE_MODE;
    LVL2_SECURE_MODE : integer := std_TERM_SECURE_MODE
    );

  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    --  Media direction port
    MED_DATAREADY_OUT : out std_logic;
    MED_DATA_OUT      : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT: out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    MED_READ_IN       : in  std_logic;
    MED_DATAREADY_IN  : in  std_logic;
    MED_DATA_IN       : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT      : out std_logic;
    MED_ERROR_IN      : in  std_logic_vector (2 downto 0);
    MED_STAT_OP       : in  std_logic_vector (15 downto 0);
    MED_CTRL_OP       : out std_logic_vector (15 downto 0);

    -- LVL1 trigger APL
    LVL1_ERROR_PATTERN_OUT : out std_logic_vector(31 downto 0);
    LVL1_GOT_TRIGGER_OUT   : out std_logic;
    LVL1_DTYPE_OUT         : out std_logic_vector(3 downto 0);
    LVL1_SEQNR_OUT         : out std_logic_vector(7 downto 0);
    LVL1_ERROR_PATTERN_IN  : in  std_logic_vector(31 downto 0);
    LVL1_RELEASE_IN        : in  std_logic;

    -- LVL2 trigger APL
    LVL2_ERROR_PATTERN_OUT : out std_logic_vector(31 downto 0);
    LVL2_GOT_TRIGGER_OUT   : out std_logic;
    LVL2_DTYPE_OUT         : out std_logic_vector(3 downto 0);
    LVL2_SEQNR_OUT         : out std_logic_vector(7 downto 0);
    LVL2_ERROR_PATTERN_IN  : in  std_logic_vector(31 downto 0);
    LVL2_RELEASE_IN        : in  std_logic
    );
end entity;





architecture trb_net16_endpoint_2_trg_arch of trb_net16_endpoint_2_trg is



  component trb_net16_iobuf is
    generic (
      IBUF_DEPTH            : integer range 0 to 6 := c_FIFO_BRAM;--std_FIFO_DEPTH;
      IBUF_SECURE_MODE      : integer range 0 to 1 := c_NO;--std_IBUF_SECURE_MODE;
      SBUF_VERSION          : integer range 0 to 1 := std_SBUF_VERSION;
      OBUF_DATA_COUNT_WIDTH : integer range 2 to 7 := std_DATA_COUNT_WIDTH;
      USE_ACKNOWLEDGE       : integer range 0 to 1 := std_USE_ACKNOWLEDGE;
      USE_CHECKSUM          : integer range 0 to 1 := c_YES;
      USE_VENDOR_CORES      : integer range 0 to 1 := c_YES;
      INIT_CAN_SEND_DATA    : integer range 0 to 1 := c_YES;
      REPLY_CAN_SEND_DATA   : integer range 0 to 1 := c_YES
      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      --  Media direction port
      MED_INIT_DATAREADY_OUT: out std_logic;
      MED_INIT_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_INIT_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_INIT_READ_IN:       in  std_logic;

      MED_REPLY_DATAREADY_OUT: out std_logic;
      MED_REPLY_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_REPLY_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_REPLY_READ_IN:       in  std_logic;


      MED_DATAREADY_IN:  in  std_logic; -- Data word is offered by the Media(the IOBUF MUST read)
      MED_DATA_IN:       in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN: in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_READ_OUT:      out std_logic;
      MED_ERROR_IN:      in  std_logic_vector (2 downto 0);



      -- Internal direction port

      INT_INIT_DATAREADY_OUT: out std_logic;
      INT_INIT_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_INIT_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      INT_INIT_READ_IN:       in  std_logic;

      INT_INIT_DATAREADY_IN:  in  std_logic;
      INT_INIT_DATA_IN:       in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_INIT_PACKET_NUM_IN: in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
      INT_INIT_READ_OUT:      out std_logic;

      INT_REPLY_DATAREADY_OUT: out std_logic;
      INT_REPLY_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_REPLY_PACKET_NUM_OUT:out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      INT_REPLY_READ_IN:       in  std_logic;

      INT_REPLY_DATAREADY_IN:  in  std_logic;
      INT_REPLY_DATA_IN:       in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_REPLY_PACKET_NUM_IN :in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_REPLY_READ_OUT:      out std_logic;

      -- Status and control port
      STAT_GEN:               out std_logic_vector (31 downto 0);
      STAT_IBUF_BUFFER:       out std_logic_vector (31 downto 0);
      CTRL_GEN:               in  std_logic_vector (31 downto 0);
      STAT_CTRL_IBUF_BUFFER:  in  std_logic_vector (31 downto 0)
      );
  end component;



  component trb_net16_io_multiplexer is
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      --  Media direction port
      MED_DATAREADY_IN:  in  STD_LOGIC;
      MED_DATA_IN:       in  STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN:  in  STD_LOGIC_VECTOR (1 downto 0);
      MED_READ_OUT:      out STD_LOGIC;

      MED_DATAREADY_OUT: out STD_LOGIC;
      MED_DATA_OUT:      out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT: out STD_LOGIC_VECTOR (1 downto 0);
      MED_READ_IN:       in  STD_LOGIC;

      -- Internal direction port
      INT_DATA_OUT:      out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_OUT: out STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
      INT_DATAREADY_OUT: out STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)-1 downto 0);
      INT_READ_IN:       in  STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)-1 downto 0);

      INT_DATAREADY_IN:  in  STD_LOGIC_VECTOR (2**c_MUX_WIDTH-1 downto 0);
      INT_DATA_IN:       in  STD_LOGIC_VECTOR ((c_DATA_WIDTH)*(2**c_MUX_WIDTH)-1 downto 0);
      INT_PACKET_NUM_IN:  in  STD_LOGIC_VECTOR (2*(2**c_MUX_WIDTH)-1 downto 0);
      INT_READ_OUT:      out STD_LOGIC_VECTOR (2**c_MUX_WIDTH-1 downto 0);

      -- Status and control port
      CTRL:              in  STD_LOGIC_VECTOR (31 downto 0);
      STAT:              out STD_LOGIC_VECTOR (31 downto 0)
      );
  end component;

  component trb_net16_term_buf is
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      MED_INIT_DATAREADY_OUT:     out std_logic;
      MED_INIT_DATA_OUT:          out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      MED_INIT_PACKET_NUM_OUT:    out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_INIT_READ_IN:           in  std_logic;

      MED_REPLY_DATAREADY_OUT:     out std_logic;
      MED_REPLY_DATA_OUT:          out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      MED_REPLY_PACKET_NUM_OUT:    out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_REPLY_READ_IN:           in  std_logic;

      MED_DATAREADY_IN:      in  std_logic;
      MED_DATA_IN:           in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      MED_PACKET_NUM_IN:     in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
      MED_READ_OUT:          out std_logic
      );
  end component;
  component trb_net16_term is
    generic (
      USE_APL_PORT : integer range 0 to 1 := 0;
      SECURE_MODE  : integer range 0 to 1 := std_TERM_SECURE_MODE
      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      INT_DATAREADY_OUT:     out std_logic;
      INT_DATA_OUT:          out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_PACKET_NUM_OUT:    out std_logic_vector (c_NUM_WIDTH-1  downto 0);
      INT_READ_IN:           in  std_logic;

      INT_DATAREADY_IN:      in  std_logic;
      INT_DATA_IN:           in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
      INT_PACKET_NUM_IN:     in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
      INT_READ_OUT:          out std_logic;

      -- "mini" APL, just to see the triggers coming in
      APL_DTYPE_OUT:         out std_logic_vector (3 downto 0);  -- see NewTriggerBusNetworkDescr
      APL_ERROR_PATTERN_OUT: out std_logic_vector (31 downto 0); -- see NewTriggerBusNetworkDescr
      APL_SEQNR_OUT:         out std_logic_vector (7 downto 0);
      APL_GOT_TRM:           out std_logic;
      APL_RELEASE_TRM:       in std_logic;
      APL_ERROR_PATTERN_IN:  in std_logic_vector (31 downto 0) -- see NewTriggerBusNetworkDescr
      -- Status and control port
      );
  end component;
  constant channels : integer := 2**(c_MUX_WIDTH-1);
signal apl_to_buf_INIT_DATAREADY: std_logic_vector(channels-1 downto 0);
signal apl_to_buf_INIT_DATA     : std_logic_vector (channels*c_DATA_WIDTH-1 downto 0);
signal apl_to_buf_INIT_PACKET_NUM:std_logic_vector (channels*c_NUM_WIDTH-1 downto 0);
signal apl_to_buf_INIT_READ     : std_logic_vector(channels-1 downto 0);

signal buf_to_apl_INIT_DATAREADY: std_logic_vector(channels-1 downto 0);
signal buf_to_apl_INIT_DATA     : std_logic_vector (channels*c_DATA_WIDTH-1 downto 0);
signal buf_to_apl_INIT_PACKET_NUM:std_logic_vector (channels*c_NUM_WIDTH-1 downto 0);
signal buf_to_apl_INIT_READ     : std_logic_vector(channels-1 downto 0);

signal apl_to_buf_REPLY_DATAREADY: std_logic_vector(channels-1 downto 0);
signal apl_to_buf_REPLY_DATA     : std_logic_vector (channels*c_DATA_WIDTH-1 downto 0);
signal apl_to_buf_REPLY_PACKET_NUM:std_logic_vector (channels*c_NUM_WIDTH-1 downto 0);
signal apl_to_buf_REPLY_READ     : std_logic_vector(channels-1 downto 0);

signal buf_to_apl_REPLY_DATAREADY: std_logic_vector(channels-1 downto 0);
signal buf_to_apl_REPLY_DATA     : std_logic_vector (channels*c_DATA_WIDTH-1 downto 0);
signal buf_to_apl_REPLY_PACKET_NUM:std_logic_vector (channels*c_NUM_WIDTH-1 downto 0);
signal buf_to_apl_REPLY_READ     : std_logic_vector(channels-1 downto 0);

-- for the connection to the multiplexer
signal MED_IO_DATAREADY_IN  : std_logic_vector(channels-1 downto 0);
signal MED_IO_DATA_IN       : std_logic_vector (c_DATA_WIDTH-1 downto 0);
signal MED_IO_PACKET_NUM_IN : std_logic_vector (c_NUM_WIDTH-1 downto 0);
signal MED_IO_READ_OUT      : std_logic_vector(channels-1 downto 0);

signal MED_IO_DATAREADY_OUT  : std_logic_vector(channels*2-1 downto 0);
signal MED_IO_DATA_OUT       : std_logic_vector (channels*2*c_DATA_WIDTH-1 downto 0);
signal MED_IO_PACKET_NUM_OUT : std_logic_vector (channels*2*c_NUM_WIDTH-1 downto 0);
signal MED_IO_READ_IN        : std_logic_vector(channels*2-1 downto 0);

signal MY_ADDRESS : std_logic_vector(15 downto 0);

signal buf_api_stat_fifo_to_apl, buf_api_stat_fifo_to_int : std_logic_vector (channels*32-1 downto 0);
signal buf_STAT_GEN : std_logic_vector(32*channels-1 downto 0);
signal buf_STAT_INIT_BUFFER : std_logic_vector(32*channels-1 downto 0);
signal buf_CTRL_GEN : std_logic_vector(32*channels-1 downto 0);
signal buf_STAT_CTRL_INIT_BUFFER : std_logic_vector(32*channels-1 downto 0);
signal SCTR_REGIO_STAT : std_logic_vector(31 downto 0);

signal buf_COMMON_STAT_REG_IN: std_logic_vector(std_COMSTATREG*32-1 downto 0);


begin

  MED_CTRL_OP(15) <= MED_STAT_OP(15);
  MED_CTRL_OP(14 downto 0) <= (others => '0');

  --Connections for data channel
    genbuffers : for i in 0 to 2**(c_MUX_WIDTH-1)-1 generate
      geniobuf: if i = LVL1_CHANNEL_NUM or i = LVL2_CHANNEL_NUM generate
        IOBUF: trb_net16_iobuf
          generic map (
            IBUF_DEPTH          => 0,
            IBUF_SECURE_MODE    => c_YES,
            SBUF_VERSION        => 0,
            USE_ACKNOWLEDGE     => c_NO,
            USE_VENDOR_CORES    => c_YES,
            USE_CHECKSUM        => c_NO,
            INIT_CAN_SEND_DATA  => c_NO,
            REPLY_CAN_SEND_DATA => c_YES
            )
          port map (
            --  Misc
            CLK     => CLK ,
            RESET   => RESET,
            CLK_EN  => CLK_EN,
            --  Media direction port
            MED_INIT_DATAREADY_OUT  => MED_IO_DATAREADY_OUT(i*2),
            MED_INIT_DATA_OUT       => MED_IO_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*2*c_DATA_WIDTH),
            MED_INIT_PACKET_NUM_OUT => MED_IO_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto i*2*c_NUM_WIDTH),
            MED_INIT_READ_IN        => MED_IO_READ_IN(i*2),

            MED_DATAREADY_IN   => MED_IO_DATAREADY_IN(i),
            MED_DATA_IN        => MED_IO_DATA_IN,
            MED_PACKET_NUM_IN  => MED_IO_PACKET_NUM_IN,
            MED_READ_OUT       => MED_IO_READ_OUT(i),
            MED_ERROR_IN       => MED_ERROR_IN,

            MED_REPLY_DATAREADY_OUT => MED_IO_DATAREADY_OUT(i*2+1),
            MED_REPLY_DATA_OUT      => MED_IO_DATA_OUT((i*2+2)*c_DATA_WIDTH-1 downto (i*2+1)*c_DATA_WIDTH),
            MED_REPLY_PACKET_NUM_OUT=> MED_IO_PACKET_NUM_OUT((i*2+2)*c_NUM_WIDTH-1 downto (i*2+1)*c_NUM_WIDTH),
            MED_REPLY_READ_IN       => MED_IO_READ_IN(i*2+1),

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
            STAT_GEN               => buf_STAT_GEN(32*(i+1)-1 downto i*32),
            STAT_IBUF_BUFFER       => buf_STAT_INIT_BUFFER(32*(i+1)-1 downto i*32),
            CTRL_GEN               => (others => '0'),
            STAT_CTRL_IBUF_BUFFER  => (others => '0')
            );


          genlvl1 : if i = LVL1_CHANNEL_NUM generate
            apl_to_buf_INIT_DATAREADY(i) <= '0';
            apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
            apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= "00";
            buf_to_apl_REPLY_READ(i) <= '1';
            trglvl1 : trb_net16_term
              generic map(
                USE_APL_PORT => c_YES,
                SECURE_MODE  => LVL1_SECURE_MODE
                )
              port map(
                --  Misc
                CLK    => CLK,
                RESET  => RESET,
                CLK_EN => CLK_EN,

                INT_DATAREADY_OUT => apl_to_buf_REPLY_DATAREADY(i),
                INT_DATA_OUT      => apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
                INT_PACKET_NUM_OUT=> apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
                INT_READ_IN       => apl_to_buf_REPLY_READ(i),

                INT_DATAREADY_IN => buf_to_apl_INIT_DATAREADY(i),
                INT_DATA_IN      => buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
                INT_PACKET_NUM_IN=> buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
                INT_READ_OUT     => buf_to_apl_INIT_READ(i),

                -- "mini" APL, just to see the triggers coming in
                APL_DTYPE_OUT         => LVL1_DTYPE_OUT,
                APL_ERROR_PATTERN_OUT => LVL1_ERROR_PATTERN_OUT,
                APL_SEQNR_OUT         => LVL1_SEQNR_OUT,
                APL_GOT_TRM           => LVL1_GOT_TRIGGER_OUT,
                APL_RELEASE_TRM       => LVL1_RELEASE_IN,
                APL_ERROR_PATTERN_IN  => LVL1_ERROR_PATTERN_IN
                );
          end generate;
          genlvl2 : if i = LVL2_CHANNEL_NUM generate
            apl_to_buf_INIT_DATAREADY(i) <= '0';
            apl_to_buf_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= (others => '0');
            apl_to_buf_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= "00";
            buf_to_apl_REPLY_READ(i) <= '1';
            trglvl1 : trb_net16_term
              generic map(
                USE_APL_PORT => c_YES,
                SECURE_MODE  => LVL2_SECURE_MODE
                )
              port map(
                --  Misc
                CLK    => CLK,
                RESET  => RESET,
                CLK_EN => CLK_EN,

                INT_DATAREADY_OUT => apl_to_buf_REPLY_DATAREADY(i),
                INT_DATA_OUT      => apl_to_buf_REPLY_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
                INT_PACKET_NUM_OUT=> apl_to_buf_REPLY_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
                INT_READ_IN       => apl_to_buf_REPLY_READ(i),

                INT_DATAREADY_IN => buf_to_apl_INIT_DATAREADY(i),
                INT_DATA_IN      => buf_to_apl_INIT_DATA((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
                INT_PACKET_NUM_IN=> buf_to_apl_INIT_PACKET_NUM((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH),
                INT_READ_OUT     => buf_to_apl_INIT_READ(i),

                -- "mini" APL, just to see the triggers coming in
                APL_DTYPE_OUT         => LVL2_DTYPE_OUT,
                APL_ERROR_PATTERN_OUT => LVL2_ERROR_PATTERN_OUT,
                APL_SEQNR_OUT         => LVL2_SEQNR_OUT,
                APL_GOT_TRM           => LVL2_GOT_TRIGGER_OUT,
                APL_RELEASE_TRM       => LVL2_RELEASE_IN,
                APL_ERROR_PATTERN_IN  => LVL2_ERROR_PATTERN_IN
                );
          end generate;
      end generate;
      gentermbuf: if i /= LVL1_CHANNEL_NUM and i /= LVL2_CHANNEL_NUM  generate
        termbuf: trb_net16_term_buf
          port map(
            CLK    => CLK,
            RESET  => RESET,
            CLK_EN => CLK_EN,
            MED_DATAREADY_IN       => MED_IO_DATAREADY_IN(i),
            MED_DATA_IN            => MED_IO_DATA_IN,
            MED_PACKET_NUM_IN      => MED_IO_PACKET_NUM_IN,
            MED_READ_OUT           => MED_IO_READ_OUT(i),

            MED_INIT_DATAREADY_OUT  => MED_IO_DATAREADY_OUT(i*2),
            MED_INIT_DATA_OUT       => MED_IO_DATA_OUT((i*2+1)*c_DATA_WIDTH-1 downto i*2*c_DATA_WIDTH),
            MED_INIT_PACKET_NUM_OUT => MED_IO_PACKET_NUM_OUT((i*2+1)*c_NUM_WIDTH-1 downto i*2*c_NUM_WIDTH),
            MED_INIT_READ_IN        => MED_IO_READ_IN(i*2),
            MED_REPLY_DATAREADY_OUT => MED_IO_DATAREADY_OUT(i*2+1),
            MED_REPLY_DATA_OUT      => MED_IO_DATA_OUT((i*2+2)*c_DATA_WIDTH-1 downto (i*2+1)*c_DATA_WIDTH),
            MED_REPLY_PACKET_NUM_OUT=> MED_IO_PACKET_NUM_OUT((i*2+2)*c_NUM_WIDTH-1 downto (i*2+1)*c_NUM_WIDTH),
            MED_REPLY_READ_IN       => MED_IO_READ_IN(i*2+1)
            );
      end generate;
    end generate;


  MPLEX: trb_net16_io_multiplexer
    port map (
      CLK      => CLK,
      RESET    => RESET,
      CLK_EN   => CLK_EN,
      MED_DATAREADY_IN   => MED_DATAREADY_IN,
      MED_DATA_IN        => MED_DATA_IN,
      MED_PACKET_NUM_IN  => MED_PACKET_NUM_IN,
      MED_READ_OUT       => MED_READ_OUT,
      MED_DATAREADY_OUT  => MED_DATAREADY_OUT,
      MED_DATA_OUT       => MED_DATA_OUT,
      MED_PACKET_NUM_OUT => MED_PACKET_NUM_OUT,
      MED_READ_IN        => MED_READ_IN,
      INT_DATAREADY_OUT  => MED_IO_DATAREADY_IN,
      INT_DATA_OUT       => MED_IO_DATA_IN,
      INT_PACKET_NUM_OUT => MED_IO_PACKET_NUM_IN,
      INT_READ_IN        => MED_IO_READ_OUT,
      INT_DATAREADY_IN   => MED_IO_DATAREADY_OUT,
      INT_DATA_IN        => MED_IO_DATA_OUT,
      INT_PACKET_NUM_IN  => MED_IO_PACKET_NUM_OUT,
      INT_READ_OUT       => MED_IO_READ_IN,
      CTRL               => (others => '0')
      );


end architecture;

