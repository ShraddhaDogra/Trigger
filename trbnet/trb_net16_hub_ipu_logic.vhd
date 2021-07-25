LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


entity trb_net16_hub_ipu_logic is
  generic (
  --media interfaces
    POINT_NUMBER        : integer range 1 to 17 := 16
    );
  port (
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    --Internal interfaces to IOBufs
    INIT_DATAREADY_IN     : in  std_logic_vector (POINT_NUMBER-1 downto 0);
    INIT_DATA_IN          : in  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
    INIT_PACKET_NUM_IN    : in  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
    INIT_READ_OUT         : out std_logic_vector (POINT_NUMBER-1 downto 0);

    INIT_DATAREADY_OUT    : out std_logic_vector (POINT_NUMBER-1 downto 0);
    INIT_DATA_OUT         : out std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
    INIT_PACKET_NUM_OUT   : out std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
    INIT_READ_IN          : in  std_logic_vector (POINT_NUMBER-1 downto 0);

    REPLY_DATAREADY_IN    : in  std_logic_vector (POINT_NUMBER-1 downto 0);
    REPLY_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
    REPLY_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
    REPLY_READ_OUT        : out std_logic_vector (POINT_NUMBER-1 downto 0);

    REPLY_DATAREADY_OUT   : out std_logic_vector (POINT_NUMBER-1 downto 0);
    REPLY_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
    REPLY_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
    REPLY_READ_IN         : in  std_logic_vector (POINT_NUMBER-1 downto 0);

    MY_ADDRESS_IN         : in  std_logic_vector (15 downto 0);
    --Status ports
    STAT_DEBUG         : out std_logic_vector (31 downto 0);
    STAT_locked        : out std_logic;
    STAT_POINTS_locked : out std_logic_vector (31 downto 0);
    STAT_TIMEOUT       : out std_logic_vector (31 downto 0);
    STAT_ERRORBITS     : out std_logic_vector (31 downto 0);
    STAT_ALL_ERRORBITS : out std_logic_vector (16*32-1 downto 0);
    STAT_FSM           : out std_logic_vector (31 downto 0);
    STAT_MISMATCH      : out std_logic_vector (31 downto 0);
    CTRL_TIMEOUT_TIME  : in  std_logic_vector (15 downto 0);
    CTRL_activepoints  : in  std_logic_vector (31 downto 0) := (others => '1');
    CTRL_DISABLED_PORTS   : in  std_logic_vector (31 downto 0) := (others => '0');
    CTRL_TIMER_TICK    : in  std_logic_vector (1 downto 0)
    );
end entity;

architecture trb_net16_hub_ipu_logic_arch of trb_net16_hub_ipu_logic is
  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  attribute HGROUP of trb_net16_hub_ipu_logic_arch : architecture  is "HUBIPULOGIC_group";

  constant DISABLE_PACKING : integer := 0;

--signals init_pool
  signal INIT_POOL_DATAREADY                 : std_logic;
  signal INIT_POOL_READ                      : std_logic;
  signal INIT_POOL_DATA                      : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal INIT_POOL_PACKET_NUM                : std_logic_vector(c_NUM_WIDTH-1  downto 0);
  signal init_has_read_from_pool             : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal saved_INIT_TYPE, current_INIT_TYPE  : std_logic_vector(2 downto 0);

  signal buf_INIT_READ_OUT                     : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal buf_REPLY_READ_OUT                    : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal REPLY_POOL_DATAREADY                  : std_logic;
  signal REPLY_POOL_READ                       : std_logic;
  signal REPLY_POOL_DATA                       : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal REPLY_POOL_PACKET_NUM                 : std_logic_vector(c_NUM_WIDTH-1  downto 0);

  signal current_reply_packet_type : std_logic_vector(POINT_NUMBER*3-1 downto 0);
  signal saved_reply_packet_type   : std_logic_vector(POINT_NUMBER*3-1 downto 0);
  signal last_reply_packet_type    : std_logic_vector(POINT_NUMBER*3-1 downto 0);
  signal last_reply_packet_number  : std_logic_vector(POINT_NUMBER*3-1 downto 0);
  signal reply_reading_H0          : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal reply_reading_F0          : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal reply_reading_F1          : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal reply_reading_F2          : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal reply_reading_F3          : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal reply_combined_trm_F1     : std_logic_vector(c_DATA_WIDTH-1  downto 0);
  signal reply_combined_trm_F2     : std_logic_vector(c_DATA_WIDTH-1  downto 0);
  signal reply_combined_trm_F3     : std_logic_vector(c_DATA_WIDTH-1  downto 0);
  signal real_activepoints         : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal hdrram_write_enable       : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal hdrram_address            : std_logic_vector(3*POINT_NUMBER-1 downto 0);
--   signal current_waiting_for_reply : std_logic_vector(POINT_NUMBER-1 downto 0);
--   signal next_current_waiting_for_reply : std_logic_vector(POINT_NUMBER-1 downto 0);

  signal current_reply_reading_trm             : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal current_reply_reading_DHDR            : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal current_REPLY_reading_hdr             : std_logic_vector(POINT_NUMBER-1  downto 0);
--   signal current_muxed_reading_DAT             : std_logic;

  signal reg_current_reply_reading_trm         : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal reg_current_REPLY_reading_hdr         : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal reg_current_reply_reading_DHDR        : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal reg_current_reply_auto_reading_DHDR   : std_logic_vector(POINT_NUMBER-1  downto 0);
--general signals
  signal locked, next_locked                 : std_logic;
  signal get_locked, release_locked          : std_logic;
  signal got_trm                             : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal locking_point, next_locking_point   : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal send_reply_trm                      : std_logic;

  signal init_locked, next_init_locked       : std_logic;
  signal get_init_locked, release_init_locked: std_logic;

  signal REPLY_MUX_reading                   : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal reply_arbiter_result                : std_logic_vector(POINT_NUMBER-1 downto 0);

  type state_type is (IDLE, WAIT_FOR_REPLY, CHECK_EVENT_INFO, WAIT_FOR_HDR_DATA, GEN_LENGTH,
                      CHECK_DHDR, SENDING_DATA, SENDING_REPLY_TRM, SEND_PADDING,
                      WAITING_FOR_INIT, WAIT_FOR_END_OF_DHDR, ARBITER_ACTIVE);
  signal current_state, next_state           : state_type;
  signal packet_counter                      : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal reply_data_counter                  : unsigned(15 downto 0);
  signal reply_data_counter_reset            : std_logic;
  signal next_reply_data_counter_reset       : std_logic;
  signal comb_REPLY_POOL_DATAREADY           : std_logic;
  signal comb_REPLY_POOL_DATA                : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal comb_REPLY_POOL_PACKET_NUM          : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal REPLY_POOL_next_read                : std_logic;
  signal comb_REPLY_POOL_next_read           : std_logic;

  signal evt_random_code : std_logic_vector(7 downto 0);
  signal evt_number      : std_logic_vector(15 downto 0);
  signal evt_dtype       : std_logic_vector(3 downto 0);
  signal evt_seqnr       : std_logic_vector(7 downto 0);

  signal comb_REPLY_muxed_DATAREADY           : std_logic;
  signal comb_REPLY_muxed_DATA                : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal comb_REPLY_muxed_PACKET_NUM          : std_logic_vector(c_NUM_WIDTH-1 downto 0);

  signal init_arbiter_CLK_EN                  : std_logic;
  signal init_arbiter_ENABLE                  : std_logic;
  signal init_arbiter_read_out                : std_logic_vector(POINT_NUMBER-1 downto 0);

  signal reply_arbiter_input                  : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal reply_arbiter_enable                 : std_logic;
  signal reply_arbiter_CLK_EN                 : std_logic;
  signal reply_arbiter_reset                  : std_logic;

  signal INIT_muxed_DATAREADY            : std_logic;
  signal INIT_muxed_DATA                 : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal INIT_muxed_PACKET_NUM           : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal INIT_muxed_READ                 : std_logic;
  signal comb_INIT_next_read             : std_logic;
  signal reply_fsm_state                 : std_logic_vector(7 downto 0);

--  signal waiting_for_init_finish, next_waiting_for_init_finish : std_logic;

  signal waiting_for_DHDR_word           : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal next_waiting_for_DHDR_word      : std_logic_vector(POINT_NUMBER-1  downto 0);

  signal reply_adder_input        : std_logic_vector(17*16-1 downto 0);
  signal reply_adder_start        : std_logic;
  signal reg_reply_adder_start    : std_logic;
  signal reply_adder_overflow     : std_logic;
  signal reply_adder_ready        : std_logic;
  signal reply_adder_val_enable   : std_logic_vector(17-1 downto 0);
  signal reply_adder_result       : std_logic_vector(15 downto 0);
  signal next_reply_adder_start   : std_logic;
  signal next_reply_compare_start : std_logic;

  signal reply_compare_start      : std_logic;
  signal reg_reply_compare_start  : std_logic;
  signal reply_compare_finished   : std_logic;
  --signal reply_compare_result     : std_logic_vector(17-1 downto 0);
  --signal reply_compare_flag       : std_logic;
  --signal reply_compare_input      : std_logic_vector(17-1 downto 0);

  signal dhdr_addr        : std_logic_vector(2 downto 0);
  signal dhdr_data        : std_logic_vector(16*POINT_NUMBER-1 downto 0);
  signal next_dhdr_data   : std_logic_vector(16*POINT_NUMBER-1 downto 0);

  signal current_point_length  : unsigned(15 downto 0);
  signal start_read_padding    : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal saved_reading_padding : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal reading_padding       : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal got_all_DHDR          : std_logic;
--   signal got_all_reply_starts  : std_logic;
  signal not_reading_HDR       : std_logic;
  signal number_of_replies     : unsigned(4 downto 0);
  signal expected_replies      : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal reply_adder_final_result : std_logic_vector(15 downto 0);
  signal next_reply_adder_final_result : std_logic_vector(15 downto 0);
  signal last_reply_adder_ready: std_logic;

  signal enable_reply_data_counter : std_logic;
  signal evt_code_mismatch   : std_logic;
  signal evt_number_mismatch : std_logic;
  signal enable_packing      : std_logic;


  type timeout_counter_t is array (POINT_NUMBER-1 downto 0) of unsigned(15 downto 0);
  signal timeout_counter : timeout_counter_t;
--   signal timeout_counter_reset : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal connection_timed_out  : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal timeout_found   : std_logic;
  signal reg_CTRL_TIMEOUT_TIME : unsigned(15 downto 0);

  signal timer_us_tick : std_logic;
  signal timer_ms_tick : std_logic;

  signal saved_auto_reading_DHDR      : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal last_REPLY_PACKET_NUM_IN     : std_logic_vector(POINT_NUMBER*3-1 downto 0);

  signal reply_fsm_statebits          : std_logic_vector(3 downto 0);
  signal last_locked                  : std_logic;
  signal mismatch_pattern             : std_logic_vector(31 downto 0);
begin

----------------------------------
--Arbiter choosing init point
----------------------------------

  INIT_ARBITER: trb_net_priority_arbiter
    generic map (WIDTH => POINT_NUMBER)
    port map (
      CLK   => CLK,
      RESET  => RESET,
      CLK_EN  => init_arbiter_CLK_EN,
      INPUT_IN  => INIT_DATAREADY_IN,
      RESULT_OUT => init_arbiter_read_out,
      ENABLE  => init_arbiter_ENABLE,
      CTRL => (others => '0')
      );
  init_arbiter_CLK_EN <= not locked;
  init_arbiter_ENABLE <= not init_locked;

----------------------------------
--Datapool for Init-Channel
----------------------------------
  INIT_muxed_DATAREADY <= or_all(INIT_DATAREADY_IN and buf_INIT_READ_OUT) and not init_locked and INIT_muxed_READ;
  INIT_POOL_READ <= and_all(INIT_READ_IN or init_has_read_from_pool or locking_point or not real_activepoints);
  INIT_READ_OUT <= buf_INIT_READ_OUT;

  gen_iro : for i in 0 to POINT_NUMBER-1 generate
    buf_INIT_READ_OUT(i) <= init_arbiter_read_out(i) and not init_locked and INIT_muxed_READ;
  end generate;

  gen_init_pool_data0: for i in 0 to c_DATA_WIDTH-1 generate
    process(INIT_DATA_IN, buf_INIT_READ_OUT)
      variable VAR_INIT_POOL_DATA : std_logic;
      begin
        VAR_INIT_POOL_DATA := '0';
        gen_init_pool_data1 : for j in 0 to POINT_NUMBER-1 loop
          VAR_INIT_POOL_DATA := VAR_INIT_POOL_DATA or (INIT_DATA_IN(j*c_DATA_WIDTH+i) and buf_INIT_READ_OUT(j));
        end loop;
        INIT_muxed_DATA(i) <= VAR_INIT_POOL_DATA;
      end process;
  end generate;

  gen_init_pool_data2: for i in 0 to c_NUM_WIDTH-1 generate
    process(INIT_PACKET_NUM_IN, buf_INIT_READ_OUT)
      variable VAR_INIT_POOL_PACKET_NUM : std_logic;
      begin
        VAR_INIT_POOL_PACKET_NUM := '0';
        gen_init_pool_data3 : for j in 0 to POINT_NUMBER-1 loop
          VAR_INIT_POOL_PACKET_NUM := VAR_INIT_POOL_PACKET_NUM or (INIT_PACKET_NUM_IN(j*c_NUM_WIDTH+i) and buf_INIT_READ_OUT(j));
        end loop;
        INIT_muxed_PACKET_NUM(i) <= VAR_INIT_POOL_PACKET_NUM;
      end process;
  end generate;


----------------------------------
--Data Pool on Init Channel
----------------------------------
  INIT_POOL_SBUF: trb_net16_sbuf
    generic map (
      Version => std_SBUF_VERSION
      )
    port map (
      CLK   => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      COMB_DATAREADY_IN => INIT_muxed_DATAREADY,
      COMB_next_READ_OUT => comb_INIT_next_read,
      COMB_READ_IN => INIT_muxed_READ,
      COMB_DATA_IN => INIT_muxed_DATA,
      COMB_PACKET_NUM_IN => INIT_muxed_PACKET_NUM,
      SYN_DATAREADY_OUT => INIT_POOL_DATAREADY,
      SYN_DATA_OUT => INIT_POOL_DATA,
      SYN_PACKET_NUM_OUT => INIT_POOL_PACKET_NUM,
      SYN_READ_IN => INIT_POOL_READ
      );

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          INIT_muxed_READ <= '0';
        else
          INIT_muxed_READ <= comb_INIT_next_read;
        end if;
      end if;
    end process;


--init_has_read signal
  gen_hasread: for i in 0 to POINT_NUMBER-1 generate
    process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' or INIT_POOL_READ = '1' then
            init_has_read_from_pool(i) <= '0';
          elsif INIT_POOL_DATAREADY = '1' and INIT_READ_IN(i) = '1' then
            init_has_read_from_pool(i) <= '1';
          end if;
        end if;
      end process;
  end generate;

----------------------------------
--Data Output to init Obufs
----------------------------------
  gen_init_data_out: for i in 0 to POINT_NUMBER-1 generate
    INIT_DATAREADY_OUT(i) <= INIT_POOL_DATAREADY and not init_has_read_from_pool(i) and real_activepoints(i) and not locking_point(i);
    INIT_DATA_OUT((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= INIT_POOL_DATA;
    INIT_PACKET_NUM_OUT((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= INIT_POOL_PACKET_NUM;
  end generate;


----------------------------------
--Hub Locks - locked while a transfer is running, init_locked after trm on init has been received
----------------------------------

  get_locked     <= INIT_muxed_DATAREADY;
  next_locked    <= (get_locked or locked) and not release_locked;
  next_locking_point <= (INIT_DATAREADY_IN) when (locked = '0' and REPLY_POOL_DATAREADY = '0') else locking_point;
                       --buf_INIT_READ_OUT and

  get_init_locked     <= '1' when saved_INIT_TYPE = TYPE_TRM and INIT_muxed_PACKET_NUM = c_F3 else '0';
  release_init_locked <= release_locked;
  next_init_locked    <= (get_init_locked or init_locked) and not release_init_locked;


  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          locked <= '0';
          locking_point <= (others => '0');
          init_locked <= '0';
        else
          locked <= next_locked;
          locking_point <= next_locking_point;
          init_locked <= next_init_locked;
        end if;
      end if;
    end process;

----------------------------------
--Save current packet type on init channel
----------------------------------

  save_INIT_TYPE : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1'  or (INIT_muxed_DATAREADY = '1' and INIT_muxed_PACKET_NUM = c_F3) then
          saved_INIT_TYPE <= TYPE_ILLEGAL;
        elsif INIT_muxed_DATAREADY = '1' and INIT_muxed_PACKET_NUM = c_H0 then
          saved_INIT_TYPE <= INIT_muxed_DATA(2 downto 0);
        end if;
      end if;
    end process;
  current_INIT_TYPE <= INIT_muxed_DATA(2 downto 0) when INIT_muxed_DATAREADY = '1' and INIT_muxed_PACKET_NUM = c_H0
                       else saved_INIT_TYPE;


----------------------------------
--save event information
----------------------------------

  save_INIT_PACKET : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
        elsif INIT_POOL_DATAREADY = '1' then
          case INIT_POOL_PACKET_NUM is
            when c_F0 => null;
            when c_F1 => evt_random_code <= INIT_POOL_DATA(7 downto 0);
            when c_F2 => evt_number <= INIT_POOL_DATA;
            when c_F3 => evt_dtype <= INIT_POOL_DATA(3 downto 0);
                         evt_seqnr <= INIT_POOL_DATA(11 downto 4);
            when others => null;
          end case;
        end if;
      end if;
    end process;
















------------------------------
--REPLY-----------------------
------------------------------

  gen_read_out : for i in 0 to POINT_NUMBER-1 generate
    buf_REPLY_READ_OUT(i) <= reg_current_reply_reading_TRM(i) --current_reply_reading_TRM(i)
                          or reg_current_reply_reading_HDR(i) --current_reply_reading_HDR(i)
                          or reg_current_reply_auto_reading_DHDR(i)
                          or saved_reading_padding(i)
                          or (reply_mux_reading(i) and REPLY_POOL_next_read and not packet_counter(2))
                          or not locked;
--                           or (reply_fsm_state(4) and reply_reading_H0(i));


  end generate;
  REPLY_READ_OUT <= buf_REPLY_READ_OUT;






----------------------------------
--save current packet type & set markers for special words
----------------------------------------------------------

  gen_reading_Fn : for i in 0 to POINT_NUMBER-1 generate
    reply_reading_H0(i) <= not REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+1) and not REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH)
                     and REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+2) and REPLY_DATAREADY_IN(i);
    reply_reading_F0(i) <= not REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+1) and not REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH)
                     and not REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+2) and REPLY_DATAREADY_IN(i);
    reply_reading_F1(i) <= not REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+1) and REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH)
                     and not REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+2) and REPLY_DATAREADY_IN(i);
    reply_reading_F2(i) <= REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+1) and not REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH)
                     and not REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+2) and REPLY_DATAREADY_IN(i);
    reply_reading_F3(i) <= REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+1) and REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH)
                     and not REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+2) and REPLY_DATAREADY_IN(i);

    process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            saved_reply_packet_type((i+1)*3-1 downto i*3) <= TYPE_ILLEGAL;
            last_reply_packet_type ((i+1)*3-1 downto i*3)  <= TYPE_ILLEGAL;
            last_reply_packet_number((i+1)*3-1 downto i*3)  <= c_F3;
          elsif REPLY_DATAREADY_IN(i) = '1' then
            last_reply_packet_number((i+1)*3-1 downto i*3) <= REPLY_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH);
            if REPLY_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) = c_H0 then
              saved_reply_packet_type((i+1)*3-1 downto i*3)  <= REPLY_DATA_IN(i*c_DATA_WIDTH+2 downto i*c_DATA_WIDTH);
              if last_reply_packet_number((i+1)*3-1 downto i*3) /= c_H0 then
                last_reply_packet_type ((i+1)*3-1 downto i*3)  <= saved_reply_packet_type((i+1)*3-1 downto i*3);
              end if;
            end if;
          end if;
        end if;
      end process;

    current_reply_packet_type((i+1)*3-1 downto i*3) <= REPLY_DATA_IN(i*c_DATA_WIDTH+2 downto i*c_DATA_WIDTH)
                  when (REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+2 downto i*c_NUM_WIDTH) = c_H0 and REPLY_DATAREADY_IN(i) = '1')
                  else saved_reply_packet_type((i+1)*3-1 downto i*3);

    current_reply_reading_HDR(i)  <= '1' when current_reply_packet_type((i+1)*3-1 downto i*3) = TYPE_HDR else '0';
    current_reply_reading_DHDR(i) <= '1' when current_reply_packet_type((i+1)*3-1 downto i*3) = TYPE_DAT
                                             and last_reply_packet_type((i+1)*3-1 downto i*3) = TYPE_HDR else '0';
    current_reply_reading_TRM(i)  <= '1' when current_reply_packet_type((i+1)*3-1 downto i*3) = TYPE_TRM else '0';


    PROC_reading_signals : process(CLK)
      begin
        if rising_edge(CLK) then
          reg_current_reply_reading_TRM(i)  <= current_reply_reading_TRM(i);
          reg_current_reply_reading_HDR(i)  <= current_reply_reading_HDR(i);
          reg_current_reply_reading_DHDR(i) <= current_reply_reading_DHDR(i);
        end if;
      end process;



    PROC_last_reply_packet_num : process(CLK)
      begin
        if rising_edge(CLK) then
          if REPLY_DATAREADY_IN(i) = '1' and buf_REPLY_READ_OUT(i) = '1' then
            last_REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+2 downto i*c_NUM_WIDTH) <= REPLY_PACKET_NUM_IN(i*c_NUM_WIDTH+2 downto i*c_NUM_WIDTH);
          end if;
        end if;
      end process;


    PROC_save_auto_reading_DHDR : process(CLK)
      begin
        if rising_edge(CLK) then
          saved_auto_reading_DHDR(i) <= reg_current_reply_auto_reading_DHDR(i);
        end if;
      end process;


    PROC_auto_read_DHDR : process(reg_current_reply_reading_HDR, enable_packing,
                                  last_REPLY_PACKET_NUM_IN,reg_current_reply_reading_dhdr)
      begin
        reg_current_reply_auto_reading_DHDR(i) <= '0';
        if reg_current_reply_reading_HDR(i) = '1' then
          reg_current_reply_auto_reading_DHDR(i) <= '1';
        elsif reg_current_reply_reading_DHDR(i) = '1' then
          if enable_packing = '0' or DISABLE_PACKING = 1 then
            if    last_REPLY_PACKET_NUM_IN(i*3+2 downto i*3) = c_F1
               or last_REPLY_PACKET_NUM_IN(i*3+2 downto i*3) = c_F2
               or last_REPLY_PACKET_NUM_IN(i*3+2 downto i*3) = c_F3 then
              reg_current_reply_auto_reading_DHDR(i) <= '0';
            else
              reg_current_reply_auto_reading_DHDR(i) <= '1';
            end if;
          else
            if last_REPLY_PACKET_NUM_IN(i*3+2 downto i*3) = c_F3 then
              reg_current_reply_auto_reading_DHDR(i) <= '0';
            else
              reg_current_reply_auto_reading_DHDR(i) <= '1';
            end if;
          end if;
        end if;
      end process;

  end generate;


  reg_timer_ticks : process(CLK)
    begin
      if rising_edge(CLK) then
        timer_us_tick <= CTRL_TIMER_TICK(0);
        timer_ms_tick <= CTRL_TIMER_TICK(1);
      end if;
    end process;

----------------------------------
--Check for Timeouts
----------------------------------

--   gen_timeout_counters : for i in 0 to POINT_NUMBER-1 generate
--     proc_timeout_counters : process (CLK)
--       begin
--         if rising_edge(CLK) then
--           connection_timed_out(i) <= '0';
--           reg_CTRL_TIMEOUT_TIME <= CTRL_TIMEOUT_TIME;
--           timeout_found <= or_all(connection_timed_out);
--           if REPLY_DATAREADY_IN(i) = '1' or real_activepoints(i) = '0' or locked = '0' or locking_point(i) = '1'  or reg_CTRL_TIMEOUT_TIME = x"F" then
--             timeout_counter(i) <= (others => '0');
--           elsif timeout_counter(i)(to_integer(unsigned(reg_CTRL_TIMEOUT_TIME(2 downto 0)&'1'))) = '1' then
--             connection_timed_out(i) <= '1';
--           elsif timer_ms_tick = '1' then
--             timeout_counter(i) <= timeout_counter(i) + to_unsigned(1,1);
--           end if;
--         end if;
--       end process;
--   end generate;


  proc_reg_setting : process (CLK)
    begin
      if rising_edge(CLK) then
        reg_CTRL_TIMEOUT_TIME   <= unsigned(CTRL_TIMEOUT_TIME);
        timeout_found           <= or_all(connection_timed_out);
      end if;
    end process;

  gen_timeout_counters : for i in 0 to POINT_NUMBER-1 generate
    proc_ack_timeout_counters : process (CLK)
      begin
        if rising_edge(CLK) then
          connection_timed_out(i) <= '0';
          if REPLY_DATAREADY_IN(i) = '1' or real_activepoints(i) = '0' or locked = '0' or got_trm(i) = '1'
                                            or locking_point(i) = '1'  or reg_CTRL_TIMEOUT_TIME = 0 then
            timeout_counter(i) <= (others => '0');
          elsif timeout_counter(i) = reg_CTRL_TIMEOUT_TIME then
            connection_timed_out(i) <= '1';
          elsif timer_ms_tick = '1' and  got_trm(i) = '0' then
            timeout_counter(i) <= timeout_counter(i) + to_unsigned(1,1);
          end if;
        end if;
      end process;
  end generate;


----------------------------------
--saving (D)HDR
----------------------------------
  gen_saving_dhdr : for i in 0 to POINT_NUMBER-1 generate
    hdrram_write_enable(i) <= (reg_current_reply_reading_HDR(i) or reg_current_reply_reading_DHDR(i)) and not reply_reading_H0(i) and REPLY_DATAREADY_IN(i);
    hdrram_address(i*3+1 downto i*3) <= REPLY_PACKET_NUM_IN((i)*c_NUM_WIDTH+1 downto i*c_NUM_WIDTH);
    hdrram_address(i*3+2) <= '1' when current_reply_reading_DHDR(i)='1' else '0';

    the_last_HDR_RAM : ram_dp_rw
      generic map(
        depth => 3,
        width => 16
        )
      port map(
        CLK     => CLK,
        wr1     => hdrram_write_enable(i),
        a1      => hdrram_address(i*3+2 downto i*3),
        din1    => REPLY_DATA_IN((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH),
        a2      => dhdr_addr,
        dout2   => next_dhdr_data((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH)
        );
  end generate;


  PROC_dhdr_data_reg : process(CLK)
    begin
      if rising_edge(CLK) then
        dhdr_data <= next_dhdr_data;
        if RESET = '1' then
          reply_adder_start   <= '0';
          reply_compare_start <= '0';
        else
          reg_reply_adder_start   <= next_reply_adder_start;
          reg_reply_compare_start <= next_reply_compare_start;
          reply_adder_start       <= reg_reply_adder_start;
          reply_compare_start     <= reg_reply_compare_start;
        end if;
      end if;
    end process;

  the_ram_output_adder : wide_adder_17x16
    generic map(
      SIZE => 16,
      WORDS => 17
      )
    port map(
      CLK          => CLK,
      CLK_EN       => CLK_EN,
      RESET        => RESET,
      INPUT_IN     => reply_adder_input,
      VAL_ENABLE_IN=> reply_adder_val_enable,
      START_IN     => reply_adder_start,
      RESULT_OUT   => reply_adder_result,
      OVERFLOW_OUT => reply_adder_overflow,
      READY_OUT    => reply_adder_ready
      );

      reply_adder_val_enable(POINT_NUMBER-1 downto 0) <= (not locking_point and real_activepoints);
      gen_other_bits : if POINT_NUMBER < 17 generate
        reply_adder_val_enable(reply_adder_val_enable'left downto POINT_NUMBER) <= (others => '0');
      end generate;

  reply_adder_input(POINT_NUMBER*16-1 downto 0) <= dhdr_data;
  gen_spare_bits : if POINT_NUMBER < 17 generate
    reply_adder_input(reply_adder_input'left downto POINT_NUMBER*16) <= (others => '0');
  end generate;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_point_length <= (others => '0');
        else
          gen_current_length : for i in 0 to POINT_NUMBER-1 loop
            if reply_arbiter_result(i) = '1' then
              current_point_length <= unsigned(dhdr_data((i)*c_DATA_WIDTH+c_DATA_WIDTH-1 downto i*c_DATA_WIDTH));
            end if;
          end loop;
        end if;
      end if;
    end process;



----------------------------------
--reading and merging TRM
----------------------------------
  gen_combining_trm : for j in 0 to c_DATA_WIDTH-1 generate
    process(CLK)
      variable tmpF1, tmpF2, tmpF3 : std_logic;
      begin
        if rising_edge(CLK) then
          if RESET = '1' or locked = '0' then
            reply_combined_trm_F1(j) <= '0';
            reply_combined_trm_F2(j) <= '0';
            reply_combined_trm_F3(j) <= '0';
          else
            tmpF1 := '0';
            tmpF2 := '0';
            tmpF3 := '0';
            for i in 0 to POINT_NUMBER-1 loop
              tmpF1 := tmpF1 or (REPLY_DATA_IN(i*c_DATA_WIDTH+j) and reply_reading_F1(i) and reg_current_reply_reading_TRM(i));
              tmpF2 := tmpF2 or (REPLY_DATA_IN(i*c_DATA_WIDTH+j) and reply_reading_F2(i) and reg_current_reply_reading_TRM(i));
              tmpF3 := tmpF3 or (REPLY_DATA_IN(i*c_DATA_WIDTH+j) and reply_reading_F3(i) and reg_current_reply_reading_TRM(i));
            end loop;
            if j = 3 then
              reply_combined_trm_F1(j) <= reply_combined_trm_F1(j) or tmpF1 or timeout_found;
            else
              reply_combined_trm_F1(j) <= reply_combined_trm_F1(j) or tmpF1;
            end if;

            reply_combined_trm_F2(j) <= reply_combined_trm_F2(j) or tmpF2;
            reply_combined_trm_F3(j) <= reply_combined_trm_F3(j) or tmpF3;
          end if;
        end if;
      end process;
  end generate;

  gen_monitoring_errorbits : process(CLK)
    begin
      if rising_edge(CLK) then
        for i in 0 to POINT_NUMBER-1 loop
          if (reply_reading_F1(i) and reg_current_reply_reading_TRM(i)) = '1' then
            STAT_ALL_ERRORBITS(i*32+31 downto i*32+16) <= REPLY_DATA_IN(i*16+15 downto i*16);
          end if;
          if (reply_reading_F2(i) and reg_current_reply_reading_TRM(i)) = '1' then
            STAT_ALL_ERRORBITS(i*32+15 downto i*32+0) <= REPLY_DATA_IN(i*16+15 downto i*16);
          end if;
        end loop;
      end if;
    end process;

  gen_other_errorbits : for i in POINT_NUMBER to 15 generate
    STAT_ALL_ERRORBITS(i*32+31 downto i*32) <= (others => '0');
  end generate;

----------------------------------
--read overhead data
----------------------------------

  process(reg_current_reply_reading_trm, reply_reading_f0, start_read_padding,
          saved_reading_padding)
    begin
        for i in 0 to POINT_NUMBER-1 loop
          if reply_reading_F0(i) = '1' and reg_current_reply_reading_TRM(i) = '1' then
          --REPLY_DATAREADY_IN(i) = '1' and REPLY_PACKET_NUM_IN(i*3+2 downto i*3) = c_H0 and REPLY_DATA_IN(i*16+2 downto i*16) = TYPE_TRM then
            reading_padding(i) <= '0';
          elsif start_read_padding(i) = '1' then
            reading_padding(i) <= '1';
          else
            reading_padding(i) <= saved_reading_padding(i);
          end if;
        end loop;
    end process;

  gen_saved_padding : process (CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' or send_reply_trm = '1' or locked = '0' then
          saved_reading_padding <= (others => '0');
        else
          saved_reading_padding <= reading_padding;
        end if;
      end if;
    end process;



----------------------------------
--real_activepoints can be set between transfers only, but can be cleared at any time
----------------------------------
  gen_real_activepoints : process (CLK)
    begin
      if rising_edge(CLK) then
        if locked = '0' then
          real_activepoints <= CTRL_activepoints(POINT_NUMBER-1 downto 0) and not CTRL_DISABLED_PORTS(POINT_NUMBER-1 downto 0);
        else
          real_activepoints <= real_activepoints and CTRL_activepoints(POINT_NUMBER-1 downto 0) 
                                and not connection_timed_out and not CTRL_DISABLED_PORTS(POINT_NUMBER-1 downto 0);
        end if;
      end if;
    end process;


----------------------------------
--count received TRM
----------------------------------
  gen_got_trm : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' or locked = '0' then
          got_trm <= (others => '0');
        else
          got_trm <= got_trm or locking_point or (reply_reading_F3 and reg_current_reply_reading_TRM)
                             or not real_activepoints or connection_timed_out;
        end if;
      end if;
    end process;

  send_reply_trm <= and_all(got_trm);


  gen_got_dhdr : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' or locked = '0' then
          got_all_DHDR <= '0';
        else
          got_all_DHDR <= not or_all(waiting_for_DHDR_word);
        end if;
      end if;
    end process;


----------------------------------
--REPLY Counters
----------------------------------
--counter for 16bit words
  gen_packet_counter : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' or locked = '0' then
          packet_counter <= c_H0;
        elsif comb_REPLY_POOL_DATAREADY = '1' then
          if packet_counter = c_max_word_number then
            packet_counter <= (others => '0');
          else
            packet_counter <= std_logic_vector(to_unsigned(to_integer(unsigned(packet_counter)) + 1 ,packet_counter'length ));
          end if;
        end if;
      end if;
    end process;

--counts 32bit data words
  gen_data_counter : process(CLK)
    begin
      if rising_edge(CLK) then
        if reply_data_counter_reset = '1' then
          if enable_packing = '0' or DISABLE_PACKING = 1 then
            reply_data_counter <= (others => '0');
          else
            reply_data_counter <= (0 => '1', others => '0');
          end if;
        elsif enable_reply_data_counter = '1'  then
          reply_data_counter <= reply_data_counter + 1;
        end if;
      end if;
    end process;

  PROC_REG_COMB_DATAREADY : process(CLK)
    begin
      if rising_edge(CLK) then
        enable_reply_data_counter <= comb_REPLY_POOL_DATAREADY and packet_counter(0); --F1 or F3
        reply_data_counter_reset  <= next_reply_data_counter_reset or RESET;
      end if;
    end process;

----------------------------------
--REPLY select input
----------------------------------
  REPLY_ARBITER: trb_net_priority_arbiter
    generic map (
      WIDTH => POINT_NUMBER
      )
    port map (
      CLK   => CLK,
      RESET  => reply_arbiter_reset,
      CLK_EN  => reply_arbiter_CLK_EN,
      INPUT_IN  => reply_arbiter_input,
      RESULT_OUT => reply_arbiter_result,
      ENABLE  => reply_arbiter_enable,  --switched off during DHDR
      CTRL => (others => '0')
      );

  reply_arbiter_reset  <= RESET or not locked;
  reply_arbiter_input  <= REPLY_DATAREADY_IN and not current_reply_reading_TRM and not saved_reading_padding;
  --and current_reply_reading_DHDR
--  reply_arbiter_CLK_EN <= not next_point_lock;
  REPLY_MUX_reading <= reply_arbiter_result;



----------------------------------
--Muxing Reply data
----------------------------------
  gen_reply_mux1 : for i in 0 to c_DATA_WIDTH-1 generate
    data_mux : process(REPLY_DATA_IN, REPLY_MUX_reading)
      variable tmp_data : std_logic;
      begin
        tmp_data := '0';
        gen_data_mux : for j in 0 to POINT_NUMBER-1 loop
          tmp_data := tmp_data or (REPLY_DATA_IN(j*c_DATA_WIDTH+i) and REPLY_MUX_reading(j));
        end loop;
        comb_REPLY_muxed_DATA(i) <= tmp_data;
      end process;
  end generate;

  gen_reply_mux2 : for i in 0 to c_NUM_WIDTH-1 generate
    packet_num_mux : process(REPLY_PACKET_NUM_IN, REPLY_MUX_reading)
      variable tmp_pm : std_logic;
      begin
        tmp_pm := '0';
        gen_pm_mux : for j in 0 to POINT_NUMBER-1 loop
          tmp_pm := tmp_pm or (REPLY_PACKET_NUM_IN(j*c_NUM_WIDTH+i) and REPLY_MUX_reading(j));
        end loop;
        comb_REPLY_muxed_PACKET_NUM(i) <= tmp_pm;
      end process;
  end generate;


--Muxed data is ready, when the selected port has data, and this is neither padding, H0, padding nor termination.
--
  comb_REPLY_muxed_DATAREADY <= or_all(reply_arbiter_result and REPLY_DATAREADY_IN and not reg_current_reply_reading_trm
                                       and not reply_reading_H0 and not saved_reading_padding)
                                  and REPLY_POOL_next_read;



----------------------------------
--Compare Event Information
----------------------------------


  PROC_COMPARE : process(CLK)
    variable tmp_code, tmp_number, tmp_pack : std_logic;
    begin
      if rising_edge(CLK) then
        reply_compare_finished <= reply_compare_finished and not REPLY_POOL_next_read;
        tmp_code   := '0';
        tmp_pack   := '1';
        tmp_number := '0';
        if reply_compare_start = '1' then
          if dhdr_addr = "100" then --upper part
            mismatch_pattern(31 downto 16) <= (others => '0');
            for i in 0 to POINT_NUMBER-1 loop
              if dhdr_data(i*16+12) = '0' and reply_adder_val_enable(i) = '1' then
                tmp_pack := '0';
              end if;
              if dhdr_data(i*16+7 downto i*16) /= evt_random_code and reply_adder_val_enable(i) = '1' then
                tmp_code := '1';
                mismatch_pattern(i+16) <= '1';
              end if;
            end loop;
            enable_packing    <= tmp_pack;
            evt_code_mismatch <= tmp_code;
            reply_compare_finished <= '1';
          elsif dhdr_addr = "101" then
            mismatch_pattern(15 downto 0) <= (others => '0');
            for i in 0 to POINT_NUMBER-1 loop
              if dhdr_data(i*16+15 downto i*16) /= evt_number and reply_adder_val_enable(i) = '1' then
                tmp_number := '1';
                mismatch_pattern(i) <= '1';
              end if;
            end loop;
            evt_number_mismatch <= tmp_number;
            reply_compare_finished <= '1';
          end if;
        elsif locked = '0' then
          evt_code_mismatch   <= '0';
          enable_packing      <= '0';
          evt_number_mismatch <= '0';
        end if;
      end if;
    end process;

----------------------------------
--REPLY POOL state machine
----------------------------------
  reply_state_machine : process(REPLY_POOL_next_READ, current_state, packet_counter, timeout_found,
                                send_reply_trm, REPLY_combined_trm_F1, REPLY_combined_trm_F2, got_all_DHDR,
                                comb_REPLY_muxed_DATAREADY, comb_REPLY_muxed_DATA, init_locked,
                                waiting_for_DHDR_word, locking_point, last_reply_adder_ready,
                                real_activepoints, locked, MY_ADDRESS_IN, reply_adder_result, evt_code_mismatch,
                                reply_combined_trm_F3, reply_compare_finished, reg_current_reply_auto_reading_dhdr,
                                reply_adder_final_result, reg_current_reply_reading_dhdr, evt_number_mismatch,
                                evt_seqnr, evt_dtype, evt_random_code, evt_number, number_of_replies,
                                reply_data_counter, current_point_length, enable_packing, reply_arbiter_input,
                                reply_arbiter_result, reply_reading_f2,current_reply_reading_trm)
    begin
      release_locked <= '0';
      next_state <= current_state;
      comb_REPLY_POOL_DATAREADY <= '0';
      comb_REPLY_POOL_PACKET_NUM <= packet_counter;
      comb_REPLY_POOL_DATA <= (others => '0');
      next_waiting_for_DHDR_word <= waiting_for_DHDR_word and real_activepoints
                                        and not (reg_current_reply_reading_DHDR and reply_reading_F2);
      dhdr_addr <= "000";
--       next_current_waiting_for_reply <= current_waiting_for_reply and not reg_current_reply_reading_HDR  and real_activepoints;
      next_reply_adder_start <= '0';
      reply_arbiter_enable <= '0';
      next_reply_compare_start <= '0';
      reply_arbiter_CLK_EN <= '0';
      next_reply_data_counter_reset <= '0';
      start_read_padding <= (others => '0');
      next_reply_adder_final_result <= reply_adder_final_result;

      case current_state is
        when IDLE =>  --wait for init transfer
          next_waiting_for_DHDR_word <= not (locking_point or not real_activepoints);
--           next_current_waiting_for_reply <= not (locking_point or not real_activepoints);
          if locked = '1' then
            next_state <= WAIT_FOR_REPLY;
          end if;

        when WAIT_FOR_REPLY =>
          if got_all_DHDR = '1'  then  --got_all_reply_starts = '1'
            next_state <= WAIT_FOR_HDR_DATA;
          end if;

        when WAIT_FOR_HDR_DATA =>  --start writing HDR when first reply is received, stop waiting for length
          dhdr_addr <= "100";
          case packet_counter is
            when c_H0 =>
              comb_REPLY_POOL_DATA <= (others => '0');
              comb_REPLY_POOL_DATA(2 downto 0) <= TYPE_HDR;
              comb_REPLY_POOL_DATAREADY <= REPLY_POOL_next_read;
            when c_F0 =>
              comb_REPLY_POOL_DATA <= MY_ADDRESS_IN;
              comb_REPLY_POOL_DATAREADY <= REPLY_POOL_next_read;
            when c_F1 =>
              comb_REPLY_POOL_DATA <= x"FFFF";
              comb_REPLY_POOL_DATAREADY <= REPLY_POOL_next_read;
            when c_F2 =>
              comb_REPLY_POOL_DATAREADY <= '0';
              next_reply_compare_start <= '1';
--              if not_reading_HDR = '1' and got_all_DHDR = '1' then --implicit not waiting_for_reply
              next_state <= CHECK_EVENT_INFO;
--              end if;
            when others => null;
          end case;

        when CHECK_EVENT_INFO =>
          dhdr_addr <= "100";
          if reply_compare_finished = '1' then
            dhdr_addr <= "010";
            next_state <= GEN_LENGTH;
          end if;


        when GEN_LENGTH =>  --now, all HDR are stored, calc sum of HDR lengths
          next_reply_adder_start <= '1';
          dhdr_addr <= "010";
          if enable_packing = '0' or DISABLE_PACKING = 1 then
            next_reply_adder_final_result <= std_logic_vector(unsigned(reply_adder_result) - number_of_replies + 2);
          else
            next_reply_adder_final_result <= std_logic_vector(unsigned(reply_adder_result) - number_of_replies - number_of_replies + 2);
          end if;

          case packet_counter is
            when c_F2 =>
              comb_REPLY_POOL_DATA <= reply_adder_final_result;
              comb_REPLY_POOL_DATAREADY <= REPLY_POOL_next_read and last_reply_adder_ready;
            when c_F3 =>
              dhdr_addr <= "100";
              comb_REPLY_POOL_DATA <= "0000" & evt_seqnr & evt_dtype;
              if REPLY_POOL_next_read = '1' then
                comb_REPLY_POOL_DATAREADY <= '1';
                next_state <= WAIT_FOR_END_OF_DHDR;
              end if;
            when others => null;
          end case;

        when WAIT_FOR_END_OF_DHDR =>
          if or_all(reg_current_reply_auto_reading_DHDR) = '0' then
            next_state <= CHECK_DHDR;
          end if;

        when CHECK_DHDR =>
          comb_REPLY_POOL_DATAREADY <= '0';
          case packet_counter is
            when c_H0 =>
              comb_REPLY_POOL_DATAREADY <= REPLY_POOL_next_read;
              comb_REPLY_POOL_DATA(2 downto 0) <= TYPE_DAT;
              comb_REPLY_POOL_DATA(c_DATA_WIDTH-1 downto 3) <= (others => '0');
              dhdr_addr <= "100";
              --next_reply_compare_start <= REPLY_POOL_next_read and got_all_DHDR;
            when c_F0 =>
              dhdr_addr <= "100";
              comb_REPLY_POOL_DATA <= "0001" & evt_dtype & evt_random_code;
              --if reply_compare_finished = '1' then
                next_reply_compare_start <= REPLY_POOL_next_read;
                comb_REPLY_POOL_DATAREADY <= REPLY_POOL_next_read;
                dhdr_addr <= "101";
              --end if;
            when c_F1 =>
              dhdr_addr <= "101";
              comb_REPLY_POOL_DATA <= evt_number;
              if reply_compare_finished = '1' then
                comb_REPLY_POOL_DATAREADY <= REPLY_POOL_next_read;
                next_reply_adder_start <= REPLY_POOL_next_read;
                dhdr_addr <= "110";
              end if;
            when c_F2 =>
              dhdr_addr <= "110";
              if enable_packing = '0' or DISABLE_PACKING = 1 then
                next_reply_adder_final_result <= std_logic_vector(unsigned(reply_adder_result) + number_of_replies);
              else
                next_reply_adder_final_result <= std_logic_vector(unsigned(reply_adder_result));
              end if;
              if last_reply_adder_ready = '1' then
                comb_REPLY_POOL_DATA <= reply_adder_final_result;
                comb_REPLY_POOL_DATAREADY <= REPLY_POOL_next_read;
              end if;
            when others => --c_F3
              comb_REPLY_POOL_DATA <= MY_ADDRESS_IN;
              comb_REPLY_POOL_DATAREADY <= REPLY_POOL_next_read;
              if REPLY_POOL_next_read = '1' then -- and or_all(reply_arbiter_input) = '1'
                if or_all(reply_arbiter_input) = '1' then
                  next_state <= SENDING_DATA;
                else
                  next_state <= ARBITER_ACTIVE;
                end if;
                reply_arbiter_CLK_EN <= '1';
                reply_arbiter_enable <= '1';
                dhdr_addr <= "110";
                next_reply_data_counter_reset <= '1';
              end if;
          end case;

        when ARBITER_ACTIVE =>
          reply_arbiter_CLK_EN <= '1';
          reply_arbiter_enable <= '1';
          dhdr_addr <= "110";
          if or_all(reply_arbiter_input) = '1' then
            next_state <= SENDING_DATA;
          elsif send_reply_trm = '1'  then
            if packet_counter /= c_H0 then
              next_state <= SEND_PADDING;
            else
              next_state <= SENDING_REPLY_TRM;
            end if;
          end if;

        when SENDING_DATA =>
          reply_arbiter_enable <= '1';
          dhdr_addr <= "110"; --length

          if packet_counter = c_H0 then --sending new H0 without checking for reading_DAT seems to be fine
            comb_REPLY_POOL_DATAREADY         <= REPLY_POOL_next_read;
            comb_REPLY_POOL_DATA(2 downto 0)  <= TYPE_DAT;
            comb_REPLY_POOL_DATA(15 downto 3) <= (others => '0');
            comb_REPLY_POOL_PACKET_NUM        <= packet_counter;
          else
            comb_REPLY_POOL_DATAREADY  <= comb_REPLY_muxed_DATAREADY;
            comb_REPLY_POOL_DATA       <= comb_REPLY_muxed_DATA;
            comb_REPLY_POOL_PACKET_NUM <= packet_counter;
          end if;

          --if number of announced words is reached and F1 or F3 is written, then care about padding
          if (reply_data_counter = current_point_length and packet_counter(0) = '1' and comb_REPLY_muxed_DATAREADY = '1')
              or or_all(current_reply_reading_TRM and reply_arbiter_result) = '1' then
            next_reply_data_counter_reset <= '1';
            --either padding or trm follows. So: start reading in any case.
            start_read_padding <= reply_arbiter_result;
            next_state <= ARBITER_ACTIVE;
          end if;

          if send_reply_trm = '1'  then
            if packet_counter /= c_H0 then
              next_state <= SEND_PADDING;
            else
              comb_REPLY_POOL_DATAREADY <= '0';
              next_state <= SENDING_REPLY_TRM;
            end if;
          end if;

        when SEND_PADDING =>
          comb_REPLY_POOL_DATAREADY <= REPLY_POOL_next_read;
          comb_REPLY_POOL_DATA <= (1 => '1', others => '0');
          if packet_counter = c_F3 and REPLY_POOL_next_read = '1' then
            next_state <= SENDING_REPLY_TRM;
          end if;

        when SENDING_REPLY_TRM =>
          comb_REPLY_POOL_DATAREADY <= REPLY_POOL_next_read;
          case packet_counter is
            when c_F0 =>
              comb_REPLY_POOL_DATA <= (others => '0');
            when c_F1 =>
              comb_REPLY_POOL_DATA <= REPLY_combined_trm_F1;
              comb_REPLY_POOL_DATA(0) <= REPLY_combined_trm_F1(0) or evt_number_mismatch;
              comb_REPLY_POOL_DATA(1) <= REPLY_combined_trm_F1(1) or evt_code_mismatch;
            when c_F2 =>
              comb_REPLY_POOL_DATA    <= REPLY_combined_trm_F2;
              comb_REPLY_POOL_DATA(6) <= REPLY_combined_trm_F2(6) or timeout_found;
            when c_F3 =>
              comb_REPLY_POOL_DATA <= REPLY_combined_trm_F3;
              if REPLY_POOL_next_read = '1' and (init_locked = '1') then
                release_locked <= '1';  --release only when init has finished too
                next_state <= IDLE;
              elsif REPLY_POOL_next_read = '1' and init_locked = '0' then
                next_state <= WAITING_FOR_INIT;
              end if;
            when others => -- | c_H0 =>
              comb_REPLY_POOL_DATA <= (others => '0');
              comb_REPLY_POOL_DATA(2 downto 0) <= TYPE_TRM;
            end case;
        when WAITING_FOR_INIT =>
          comb_REPLY_POOL_DATAREADY <= '0';
          if init_locked = '1' then
            release_locked <= '1';  --release only when init has finished too
            next_state <= IDLE;
          end if;
      end case;
    end process;

  reply_fsm_state(0) <= '1' when current_state = IDLE else '0';
  reply_fsm_state(1) <= '1' when current_state = WAIT_FOR_HDR_DATA else '0';
  reply_fsm_state(2) <= '1' when current_state = GEN_LENGTH else '0';
  reply_fsm_state(3) <= '1' when current_state = CHECK_DHDR else '0';
  reply_fsm_state(4) <= '1' when current_state = SENDING_DATA else '0';
  reply_fsm_state(5) <= '1' when current_state = SEND_PADDING else '0';
  reply_fsm_state(6) <= '1' when current_state = SENDING_REPLY_TRM else '0';
  reply_fsm_state(7) <= '1' when current_state = WAITING_FOR_INIT else '0';

  reply_fsm_statebits <= x"0" when current_state = IDLE else
                         x"1" when current_state = WAIT_FOR_REPLY else
                         x"2" when current_state = WAIT_FOR_HDR_DATA else
                         x"3" when current_state = CHECK_EVENT_INFO else
                         x"4" when current_state = GEN_LENGTH else
                         x"5" when current_state = WAIT_FOR_END_OF_DHDR else
                         x"6" when current_state = CHECK_DHDR else
                         x"7" when current_state = SENDING_DATA else
                         x"8" when current_state = ARBITER_ACTIVE else
                         x"9" when current_state = SEND_PADDING else
                         x"A" when current_state = SENDING_REPLY_TRM else
                         x"B" when current_state = WAITING_FOR_INIT else
--                          x"C" when current_state = WAIT_FOR_REPLY else
--                          x"D" when current_state = WAIT_FOR_REPLY else
--                          x"E" when current_state = WAIT_FOR_REPLY else
                         x"F";


  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_state <= IDLE;
          REPLY_POOL_next_read <= '0';
          waiting_for_DHDR_word <= (others => '1');
--           current_waiting_for_reply <= (others => '1');
--           got_all_reply_starts <= '0';
          reply_adder_final_result <= (others => '0');
          last_reply_adder_ready <= '0';
        else
          current_state <= next_state;
          REPLY_POOL_next_read <= comb_REPLY_POOL_next_read;
          waiting_for_DHDR_word <= next_waiting_for_DHDR_word;
--           current_waiting_for_reply <= next_current_waiting_for_reply;
--           got_all_reply_starts <= not or_all(current_waiting_for_reply);
          not_reading_HDR <= not or_all(current_reply_reading_HDR);
          number_of_replies <= to_unsigned(count_ones(expected_replies),5);
          expected_replies <= real_activepoints and not locking_point;
          reply_adder_final_result <= next_reply_adder_final_result;
          last_reply_adder_ready <= reply_adder_ready or (last_reply_adder_ready and not REPLY_POOL_next_read);
        end if;
      end if;
    end process;


----------------------------------
--REPLY sbuf
----------------------------------

  REPLY_POOL_SBUF: trb_net16_sbuf
    generic map (
      Version => 0
      )
    port map (
      CLK   => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      COMB_DATAREADY_IN => comb_REPLY_POOL_DATAREADY,
      COMB_next_READ_OUT => comb_REPLY_POOL_next_read,
      COMB_READ_IN => REPLY_POOL_next_read,
      COMB_DATA_IN => comb_REPLY_POOL_DATA,
      COMB_PACKET_NUM_IN => comb_REPLY_POOL_PACKET_NUM,
      SYN_DATAREADY_OUT => REPLY_POOL_DATAREADY,
      SYN_DATA_OUT => REPLY_POOL_DATA,
      SYN_PACKET_NUM_OUT => REPLY_POOL_PACKET_NUM,
      SYN_READ_IN => REPLY_POOL_READ
      );

----------------------------------
--REPLY output
----------------------------------

  gen_reply_data_out: for i in 0 to POINT_NUMBER-1 generate
    REPLY_DATAREADY_OUT(i) <= REPLY_POOL_DATAREADY and locking_point(i);
    REPLY_DATA_OUT((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= REPLY_POOL_DATA;
    REPLY_PACKET_NUM_OUT((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= REPLY_POOL_PACKET_NUM;
  end generate;
  REPLY_POOL_READ <= or_all(REPLY_READ_IN and locking_point);




----------------------------------
--Debugging
----------------------------------


  STAT_TIMEOUT(POINT_NUMBER-1 downto 0) <= connection_timed_out;
  STAT_TIMEOUT(31 downto POINT_NUMBER)  <= (others => '0');


  STAT_DEBUG(0) <= got_trm(0);
  STAT_DEBUG(1) <= got_trm(1);
  STAT_DEBUG(2) <= REPLY_POOL_DATAREADY;
  STAT_DEBUG(3) <= REPLY_DATAREADY_IN(0);
  STAT_DEBUG(4) <= buf_REPLY_READ_OUT(0);
  STAT_DEBUG(5) <= comb_REPLY_muxed_DATA(14);

  STAT_DEBUG(6) <= REPLY_DATA_IN(14);
  STAT_DEBUG(7) <= REPLY_DATA_IN(30);
  STAT_DEBUG(8) <= got_all_DHDR; --REPLY_DATA_IN(46);
  STAT_DEBUG(9) <= locked;
  STAT_DEBUG(10) <= '0';
  STAT_DEBUG(11) <= REPLY_POOL_next_read;
  STAT_DEBUG(15 downto 12) <= reply_fsm_statebits(3 downto 0);

  STAT_DEBUG(19 downto 16) <= REPLY_DATA_IN(19 downto 16);
  STAT_DEBUG(20)           <= REPLY_DATAREADY_IN(1);
  STAT_DEBUG(23 downto 21) <= REPLY_PACKET_NUM_IN(5 downto 3);
  STAT_DEBUG(24)           <= reg_current_reply_auto_reading_DHDR(1);
  STAT_DEBUG(25)           <= reg_current_reply_reading_DHDR(1);
  STAT_DEBUG(26)           <= reg_current_reply_reading_HDR(1);
  STAT_DEBUG(27)           <= got_all_DHDR;
  STAT_DEBUG(28)           <= '0'; --got_all_reply_starts;
  STAT_DEBUG(31 downto 29) <= last_REPLY_PACKET_NUM_IN(5 downto 3);

  --STAT(15 downto 8) <= data_counter;

  proc_stat_errorbits : process(CLK)
    begin
      if rising_edge(CLK) then
        last_locked <= locked;
        if locked = '1' then
          STAT_POINTS_locked(POINT_NUMBER-1 downto 0) <= not got_trm;
        else
          STAT_POINTS_locked(POINT_NUMBER-1 downto 0) <= (others => '0');
        end if;
        if current_state = SENDING_REPLY_TRM and packet_counter = c_F1 then
          STAT_ERRORBITS(31 downto 16) <= comb_REPLY_POOL_DATA;
        elsif  current_state = SENDING_REPLY_TRM and packet_counter = c_F2 then
          STAT_ERRORBITS(15 downto 0) <= comb_REPLY_POOL_DATA;
        end if;
      end if;
    end process;

  STAT_POINTS_locked(31 downto POINT_NUMBER)  <= (others => '0');


  STAT_FSM(3 downto 0)  <= reply_fsm_statebits;
  STAT_FSM(7 downto 4)  <= x"0";
  STAT_FSM(8)           <= reply_adder_start;
  STAT_FSM(9)           <= reply_compare_start;
  STAT_FSM(12 downto 10)<= packet_counter;
  STAT_FSM(15 downto 13)<= dhdr_addr;
  STAT_FSM(31 downto 16)<= (others => '0');

  STAT_locked <= locked;
  STAT_MISMATCH <= mismatch_pattern;

end architecture;

