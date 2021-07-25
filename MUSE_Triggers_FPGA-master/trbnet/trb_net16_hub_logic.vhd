LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb_net16_hub_func.all;

entity trb_net16_hub_logic is
  generic (
  --media interfaces
    POINT_NUMBER        : integer range 1 to 32 := 17;
    MII_IS_UPLINK_ONLY  : hub_mii_config_t := (others => c_NO)
    );
  port (
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    --Internal interfaccs to IOBufs
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
    --Status ports (for debugging)
    STAT               : out std_logic_vector (15 downto 0);
    STAT_locked        : out std_logic;
    STAT_POINTS_locked : out std_logic_vector (31 downto 0);
    STAT_TIMEOUT       : out std_logic_vector (31 downto 0);
    STAT_ERRORBITS     : out std_logic_vector (31 downto 0);
    STAT_ALL_ERRORBITS : out std_logic_vector (16*32-1 downto 0);
    CTRL_TIMEOUT_TIME  : in  std_logic_vector (15 downto 0);
    CTRL_activepoints  : in  std_logic_vector (31 downto 0) := (others => '1');
    CTRL_DISABLED_PORTS: in  std_logic_vector (31 downto 0) := (others => '0');
    CTRL_TIMER_TICK    : in  std_logic_vector (1 downto 0)
    );
end entity;

architecture trb_net16_hub_logic_arch of trb_net16_hub_logic is


--signals init_pool
  signal INIT_POOL_DATAREADY                 : std_logic;
  signal INIT_POOL_READ                      : std_logic;
  signal INIT_POOL_DATA                      : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal INIT_POOL_PACKET_NUM                : std_logic_vector(c_NUM_WIDTH-1  downto 0);
  signal init_has_read_from_pool             : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal saved_INIT_TYPE, current_INIT_TYPE  : std_logic_vector(2 downto 0);
  signal buf_INIT_DATAREADY_OUT              : std_logic_vector (POINT_NUMBER-1 downto 0);

  signal buf_INIT_READ_OUT                   : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal buf_REPLY_READ_OUT                  : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal REPLY_POOL_DATAREADY                : std_logic;
  signal REPLY_POOL_READ                     : std_logic;
  signal REPLY_POOL_DATA                     : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal REPLY_POOL_PACKET_NUM               : std_logic_vector(c_NUM_WIDTH-1  downto 0);
  signal saved_REPLY_TYPE                    : std_logic_vector(2 downto 0);
  signal current_REPLY_TYPE                  : std_logic_vector(2 downto 0);
  signal REPLY_reading_trm                   : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal next_REPLY_reading_trm              : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal current_REPLY_reading_trm           : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal reading_trmF0                       : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal reading_trmF1                       : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal reading_trmF2                       : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal reading_trmF3                       : std_logic_vector(POINT_NUMBER-1  downto 0);
  signal REPLY_combined_trm_F0               : std_logic_vector(c_DATA_WIDTH-1  downto 0);
  signal REPLY_combined_trm_F1               : std_logic_vector(c_DATA_WIDTH-1  downto 0);
  signal REPLY_combined_trm_F2               : std_logic_vector(c_DATA_WIDTH-1  downto 0);
  signal REPLY_combined_trm_F3               : std_logic_vector(c_DATA_WIDTH-1  downto 0);
  signal REPLY_MUX_real_reading              : std_logic;
  signal real_activepoints                   : std_logic_vector(POINT_NUMBER-1 downto 0);

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

  type state_type is (SENDING_DATA, SENDING_REPLY_TRM);
  signal current_state, next_state           : state_type;
  signal packet_counter                      : unsigned(c_NUM_WIDTH-1 downto 0);
  signal data_counter                        : unsigned(7 downto 0);
  signal SEQ_NR                              : std_logic_vector(7 downto 0);
  signal comb_REPLY_POOL_DATAREADY           : std_logic;
  signal comb_REPLY_POOL_DATA                : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal comb_REPLY_POOL_PACKET_NUM          : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal REPLY_POOL_next_read                : std_logic;
  signal comb_REPLY_POOL_next_read           : std_logic;


  signal reply_point_lock, next_point_lock   : std_logic;

  signal comb_REPLY_muxed_DATAREADY          : std_logic;
  signal comb_REPLY_muxed_DATA               : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal comb_REPLY_muxed_PACKET_NUM         : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal reply_arbiter_CLK_EN                : std_logic;
  signal init_arbiter_CLK_EN                 : std_logic;
  signal init_arbiter_ENABLE                 : std_logic;
  signal init_arbiter_read_out               : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal init_arbiter_input                  : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal reply_arbiter_input                 : std_logic_vector(POINT_NUMBER-1 downto 0);

  signal INIT_muxed_DATAREADY                : std_logic;
  signal INIT_muxed_DATA                     : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal INIT_muxed_PACKET_NUM               : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal INIT_muxed_READ                     : std_logic;
  signal comb_INIT_next_read                 : std_logic;
  signal reply_fsm_state                     : std_logic;

  signal waiting_for_init_finish             : std_logic;
  signal next_waiting_for_init_finish        : std_logic;
  signal reset_i                             : std_logic;

  signal reply_dataready_in_i : std_logic_vector(POINT_NUMBER-1 downto 0) := (others => '0');
  signal reply_data_in_i      : std_logic_vector(c_DATA_WIDTH*POINT_NUMBER-1 downto 0) := (others => '0');
  signal reply_packet_num_in_i: std_logic_vector(c_NUM_WIDTH*POINT_NUMBER-1 downto 0) := (others => '0');
  signal register_buf_REPLY_READ_OUT : std_logic_vector(POINT_NUMBER-1 downto 0) := (others => '0');


  type timeout_counter_t is array (POINT_NUMBER-1 downto 0) of unsigned(15 downto 0);
  signal timeout_counter : timeout_counter_t;
  signal timeout_counter_reset : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal connection_timed_out  : std_logic_vector(POINT_NUMBER-1 downto 0);
  signal timeout_found         : std_logic;
  signal reg_CTRL_TIMEOUT_TIME : unsigned(15 downto 0);
  signal cnt_timeouts          : unsigned(15 downto 0);
  signal last_timeout_found    : std_logic;

  signal timer_us_tick : std_logic;
  signal timer_ms_tick : std_logic;
  signal last_locked : std_logic;

  attribute HGROUP : string;
  attribute syn_keep : boolean;

  attribute HGROUP of trb_net16_hub_logic_arch : architecture  is "HUBLOGIC_group";
  attribute syn_keep of reset_i : signal is true;



begin

----------------------------------
--Sync input Signals
----------------------------------

  reset_i       <= RESET              when rising_edge(CLK);
  timer_us_tick <= CTRL_TIMER_TICK(0) when rising_edge(CLK);
  timer_ms_tick <= CTRL_TIMER_TICK(1) when rising_edge(CLK);


----------------------------------
--Register Input from IOBufs
----------------------------------

  register_buf_REPLY_READ_OUT <= not reply_dataready_in_i or buf_REPLY_READ_OUT;

  gen_reply_sync : for i in 0 to POINT_NUMBER-1 generate
    SYNC_REPLY_DATA_INPUTS : process(CLK)
      begin
        if rising_edge(CLK) then
          if reset_i = '1' then
            reply_dataready_in_i(i) <= '0';
          elsif register_buf_REPLY_READ_OUT(i) = '1' then --reply_dataready_in_i(i) = '0' or buf_REPLY_READ_OUT(i) = '1' then
            reply_dataready_in_i(i)  <= REPLY_DATAREADY_IN(i);
            reply_data_in_i((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH)     <= REPLY_DATA_IN((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH);
            reply_packet_num_in_i((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= REPLY_PACKET_NUM_IN((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH);
          end if;
        end if;
      end process;
  end generate;

----------------------------------
--SBuf for init output
----------------------------------

  INIT_POOL_SBUF: trb_net16_sbuf
    generic map (
      Version => std_SBUF_VERSION
      )
    port map (
      CLK   => CLK,
      RESET  => reset_i,
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

--   process(CLK)
--     begin
--       if rising_edge(CLK) then
--         if reset_i = '1' then
--           INIT_muxed_READ <= '0';
--         else
          INIT_muxed_READ <= comb_INIT_next_read and not reset_i      when rising_edge(CLK);
--         end if;
--       end if;
--     end process;

----------------------------------
--choosing init point
----------------------------------
  INIT_ARBITER: trb_net_priority_arbiter
    generic map (WIDTH => POINT_NUMBER)
    port map (
      CLK   => CLK,
      RESET  => reset_i,
      CLK_EN  => init_arbiter_CLK_EN,
      INPUT_IN  => init_arbiter_input,
      RESULT_OUT => init_arbiter_read_out,
      ENABLE  => init_arbiter_ENABLE,
      CTRL => (others => '0')
      );
  init_arbiter_CLK_EN <= not locked;
  init_arbiter_ENABLE <= not init_locked;
  init_arbiter_input  <= INIT_DATAREADY_IN and real_activepoints;

----------------------------------
--Merging Data from Init-Channel
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
        gen_init_pool_data1: for j in 0 to POINT_NUMBER-1 loop
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
        gen_init_pool_data3: for j in 0 to POINT_NUMBER-1 loop
          VAR_INIT_POOL_PACKET_NUM := VAR_INIT_POOL_PACKET_NUM or (INIT_PACKET_NUM_IN(j*c_NUM_WIDTH+i) and buf_INIT_READ_OUT(j));
        end loop;
        INIT_muxed_PACKET_NUM(i) <= VAR_INIT_POOL_PACKET_NUM;
      end process;
  end generate;

----------------------------------
--Which ports have read data from pool
----------------------------------
  gen_hasread: for i in 0 to POINT_NUMBER-1 generate
    process(CLK)
      begin
        if rising_edge(CLK) then
          if reset_i = '1' or INIT_POOL_READ = '1' then
            init_has_read_from_pool(i) <= '0';
          elsif (INIT_POOL_DATAREADY = '1' and INIT_READ_IN(i) = '1') or MII_IS_UPLINK_ONLY(i) = c_YES then
            init_has_read_from_pool(i) <= '1';
          end if;
        end if;
      end process;
  end generate;


----------------------------------
--Output init data to obufs
----------------------------------
  gen_init_data_out: for i in 0 to POINT_NUMBER-1 generate
    buf_INIT_DATAREADY_OUT(i) <= INIT_POOL_DATAREADY and not init_has_read_from_pool(i) and real_activepoints(i) and not locking_point(i);
    INIT_DATA_OUT((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= INIT_POOL_DATA;
    INIT_PACKET_NUM_OUT((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= INIT_POOL_PACKET_NUM;
  end generate;
INIT_DATAREADY_OUT <= buf_INIT_DATAREADY_OUT;

----------------------------------
--Locking of channels
----------------------------------
--locked signals
--locked: transfer is running
--init_locked: waiting for reply channel to finish
  --send_reply_trm <= '1' when and_all(got_trm) = '1' else '0';
  send_reply_trm <= and_all(got_trm);
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
        if reset_i = '1' then
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
--Connect to init OBufs
----------------------------------
  gen_reply_data_out: for i in 0 to POINT_NUMBER-1 generate
    REPLY_DATAREADY_OUT(i) <= REPLY_POOL_DATAREADY and locking_point(i);
    REPLY_DATA_OUT((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= REPLY_POOL_DATA;
    REPLY_PACKET_NUM_OUT((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) <= REPLY_POOL_PACKET_NUM;
  end generate;
  REPLY_POOL_READ <= or_all(REPLY_READ_IN and locking_point);

  buf_REPLY_READ_OUT <= REPLY_reading_trm or REPLY_MUX_reading when REPLY_POOL_next_read = '1' else
                    REPLY_reading_trm;
  REPLY_READ_OUT <= register_buf_REPLY_READ_OUT;

  REPLY_MUX_real_reading <=  REPLY_POOL_next_read; --or_all(REPLY_MUX_reading) and
                           --REPLY_MUX_reading always contains a 1 (?)

----------------------------------
--saving necessary data
----------------------------------
  save_INIT_TYPE : process(CLK)
    begin
      if rising_edge(CLK) then
        if reset_i = '1'  or (INIT_muxed_DATAREADY = '1' and INIT_muxed_PACKET_NUM = c_F3) then
          saved_INIT_TYPE <= TYPE_ILLEGAL;
        elsif INIT_muxed_DATAREADY = '1' and INIT_muxed_PACKET_NUM = c_H0 then
          saved_INIT_TYPE <= INIT_muxed_DATA(2 downto 0);
        end if;
      end if;
    end process;
--   current_INIT_TYPE <= INIT_muxed_DATA(2 downto 0) when INIT_muxed_DATAREADY = '1' and INIT_muxed_PACKET_NUM = c_H0
--                        else saved_INIT_TYPE;

--   save_REPLY_TYPE : process(CLK)
--     begin
--       if rising_edge(CLK) then
--         if reset_i = '1' or (REPLY_POOL_DATAREADY = '1' and REPLY_POOL_PACKET_NUM = c_F3) then
--           saved_REPLY_TYPE <= TYPE_ILLEGAL;
--         elsif REPLY_POOL_DATAREADY = '1' and REPLY_POOL_PACKET_NUM = c_H0 then
--           saved_REPLY_TYPE <= REPLY_POOL_DATA(2 downto 0);
--         end if;
--       end if;
--     end process;
--   current_REPLY_TYPE <= REPLY_POOL_DATA(2 downto 0) when REPLY_POOL_DATAREADY = '1' and REPLY_POOL_PACKET_NUM = c_H0
--                        else saved_REPLY_TYPE;

--   save_SEQ_NR : process(CLK)
--     begin
--       if rising_edge(CLK) then
--         if reset_i = '1' then
--           SEQ_NR <= (others => '0');
--         elsif INIT_POOL_PACKET_NUM = c_F3 and current_INIT_TYPE = TYPE_HDR then
--           SEQ_NR <= INIT_POOL_DATA(11 downto 4);
--         end if;
--       end if;
--     end process;

----------------------------------
--REPLY reading and merging TRM
----------------------------------
  gen_reading_trm : for i in 0 to POINT_NUMBER-1 generate
    process(REPLY_reading_trm, reply_packet_num_in_i, reply_data_in_i)
      begin
        next_REPLY_reading_trm(i) <= REPLY_reading_trm(i);
        if reply_packet_num_in_i((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) = c_F3 then
          next_REPLY_reading_trm(i) <= '0';
        elsif reply_data_in_i(i*c_DATA_WIDTH+2 downto i*c_DATA_WIDTH) = TYPE_TRM
            and reply_packet_num_in_i((i+1)*c_NUM_WIDTH-1 downto i*c_NUM_WIDTH) = c_H0 then
          next_REPLY_reading_trm(i) <= '1';
        end if;
      end process;
  end generate;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if  reset_i = '1' then
          REPLY_reading_trm <= (others => '0');
        else
          REPLY_reading_trm <= next_REPLY_reading_trm;
        end if;
      end if;
    end process;
  current_REPLY_reading_trm <= next_REPLY_reading_trm or REPLY_reading_trm;


  gen_reading_trmFn : for i in 0 to POINT_NUMBER-1 generate
    reading_trmF0(i) <= '1' when reply_packet_num_in_i(i*c_NUM_WIDTH+2 downto i*c_NUM_WIDTH) = c_F0
                                 and REPLY_reading_trm(i) = '1' and reply_dataready_in_i(i) = '1' else '0';
    reading_trmF1(i) <= '1' when reply_packet_num_in_i(i*c_NUM_WIDTH+2 downto i*c_NUM_WIDTH) = c_F1
                                 and REPLY_reading_trm(i) = '1' and reply_dataready_in_i(i) = '1' else '0';
    reading_trmF2(i) <= '1' when reply_packet_num_in_i(i*c_NUM_WIDTH+2 downto i*c_NUM_WIDTH) = c_F2
                                 and REPLY_reading_trm(i) = '1' and reply_dataready_in_i(i) = '1' else '0';
    reading_trmF3(i) <= '1' when reply_packet_num_in_i(i*c_NUM_WIDTH+2 downto i*c_NUM_WIDTH) = c_F3
                                 and REPLY_reading_trm(i) = '1' and reply_dataready_in_i(i) = '1' else '0';
  end generate;

  gen_combining_trm : for j in 0 to c_DATA_WIDTH-1 generate
    process(CLK)
      variable tmpF0,tmpF1, tmpF2, tmpF3 : std_logic;
      begin
        if rising_edge(CLK) then
          if reset_i = '1' or (locked = '0' and last_locked = '1') then
            REPLY_combined_trm_F0(j) <= '0';
            REPLY_combined_trm_F1(j) <= '0';
            REPLY_combined_trm_F2(j) <= '0';
            REPLY_combined_trm_F3(j) <= '0';
          else
            tmpF0 := '0';
            tmpF1 := '0';
            tmpF2 := '0';
            tmpF3 := '0';
            for i in 0 to POINT_NUMBER-1 loop
              tmpF0 := tmpF0 or (reply_data_in_i(i*c_DATA_WIDTH+j) and reading_trmF0(i));
              tmpF1 := tmpF1 or (reply_data_in_i(i*c_DATA_WIDTH+j) and reading_trmF1(i));
              tmpF2 := tmpF2 or (reply_data_in_i(i*c_DATA_WIDTH+j) and reading_trmF2(i));
              tmpF3 := tmpF3 or (reply_data_in_i(i*c_DATA_WIDTH+j) and reading_trmF3(i));
            end loop;
            REPLY_combined_trm_F0(j) <= REPLY_combined_trm_F0(j) or tmpF0;
            REPLY_combined_trm_F1(j) <= REPLY_combined_trm_F1(j) or tmpF1;
            if j = 6 then
              reply_combined_trm_F2(j) <= reply_combined_trm_F2(j) or tmpF2 or timeout_found;
            else
              reply_combined_trm_F2(j) <= reply_combined_trm_F2(j) or tmpF2;
            end if;
            REPLY_combined_trm_F3(j) <= REPLY_combined_trm_F3(j) or tmpF3;
          end if;
        end if;
      end process;
  end generate;

  gen_monitoring_errorbits : process(CLK)
    begin
      if rising_edge(CLK) then
        for i in 0 to POINT_NUMBER-1 loop
          if reading_trmF1(i) = '1' then
            STAT_ALL_ERRORBITS(i*32+31 downto i*32+16) <= reply_data_in_i(i*16+15 downto i*16);
          elsif reading_trmF2(i) = '1' then
            STAT_ALL_ERRORBITS(i*32+15 downto i*32+0) <= reply_data_in_i(i*16+15 downto i*16);
--           elsif locked = '1' and last_locked = '0' then
--             STAT_ALL_ERRORBITS(i*32+31 downto i*32) <= (others => '0');
          end if;
        end loop;
      end if;
    end process;

  gen_other_errorbits : for i in POINT_NUMBER to 15 generate
    STAT_ALL_ERRORBITS(i*32+31 downto i*32) <= (others => '0');
  end generate;

----------------------------------
--Check which of the available ports are active
----------------------------------
--real_activepoints can be set between transfers only, but can be cleared at any time
  gen_real_activepoints : process (CLK)
    begin
      if rising_edge(CLK) then
        if locked = '0' then
          real_activepoints <= CTRL_activepoints(POINT_NUMBER-1 downto 0);
        else
          real_activepoints <= real_activepoints and CTRL_activepoints(POINT_NUMBER-1 downto 0);
        end if;
      end if;
    end process;

----------------------------------
--count received TRM
----------------------------------
  gen_got_trm : process(CLK)
    begin
      if rising_edge(CLK) then
        if reset_i = '1' or send_reply_trm = '1' or locked = '0' then
          got_trm <= (others => '0');
        else
          for i in 0 to POINT_NUMBER-1 loop
            if MII_IS_UPLINK_ONLY(i) = c_NO then
              got_trm(i) <= got_trm(i) or locking_point(i) or reading_trmF2(i) or not real_activepoints(i) or connection_timed_out(i);
            else
              got_trm(i) <= '1';
            end if;
          end loop;
        end if;
      end if;
    end process;



----------------------------------
--Check for Timeouts
----------------------------------

  reg_CTRL_TIMEOUT_TIME   <= unsigned(CTRL_TIMEOUT_TIME)  when rising_edge(CLK);
  timeout_found           <= or_all(connection_timed_out) when rising_edge(CLK);


--     proc_timeout_counters : process (CLK)
--       begin
--         if rising_edge(CLK) then
--           reg_CTRL_TIMEOUT_TIME <= CTRL_TIMEOUT_TIME;
--           connection_timed_out(i) <= '0';
--           timeout_found <= or_all(connection_timed_out);
--           if REPLY_DATAREADY_IN(i) = '1' or real_activepoints(i) = '0' or locked = '0' or locking_point(i) = '1' or reg_CTRL_TIMEOUT_TIME = x"F" then
--             timeout_counter(i) <= (others => '0');
--           elsif timeout_counter(i)(to_integer(unsigned(reg_CTRL_TIMEOUT_TIME(3 downto 0)))+1) = '1' then
--             connection_timed_out(i) <= '1';
--           elsif timer_ms_tick = '1' and  got_trm(i) = '0' then
--             timeout_counter(i) <= timeout_counter(i) + to_unsigned(1,1);
--           end if;
--         end if;
--       end process;

  gen_timeout_counters : for i in 0 to POINT_NUMBER-1 generate
    proc_ack_timeout_counters : process (CLK)
      begin
        if rising_edge(CLK) then
          connection_timed_out(i) <= '0';
          if REPLY_DATAREADY_IN(i) = '1' or real_activepoints(i) = '0' or locked = '0' or got_trm(i) = '1'
               or init_has_read_from_pool(i) = '1' or reset_i = '1' or locking_point(i) = '1' or reg_CTRL_TIMEOUT_TIME = 0 then
            timeout_counter(i) <= (others => '0');
          elsif timeout_counter(i) = reg_CTRL_TIMEOUT_TIME then
            connection_timed_out(i) <= '1';
--           elsif timer_ms_tick = '1' and INIT_READ_IN(i) = '0' and INIT_DATAREADY_OUT(i) = '1' then
--             timeout_counter(i) <= timeout_counter(i) + to_unsigned(2,2);
          elsif timer_ms_tick = '1' and ((REPLY_POOL_next_read = '1') -- and got_trm(i) = '0'
                                       or (INIT_READ_IN(i) = '0' and buf_INIT_DATAREADY_OUT(i) = '1')) then
            timeout_counter(i) <= timeout_counter(i) + to_unsigned(1,1);
          end if;
        end if;
      end process;
  end generate;

  CNT_TIMEOUTS_PROC : process(CLK)
    begin
      if rising_edge(CLK) then
        last_timeout_found <= timeout_found;
        if timeout_found = '1' and last_timeout_found = '0' then
          cnt_timeouts <= cnt_timeouts + to_unsigned(1,1);
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
        if reset_i = '1' or locked = '0' then
          packet_counter <= unsigned(c_H0);
        elsif comb_REPLY_POOL_DATAREADY = '1' then
          if packet_counter = unsigned(c_max_word_number) then
            packet_counter <= (others => '0');
          else
            packet_counter <= packet_counter + to_unsigned(1,1);
          end if;
        end if;
      end if;
    end process;

  --counts data packets only
  gen_data_counter : process(CLK)
    begin
      if rising_edge(CLK) then
        if reset_i = '1' or reply_point_lock = '0' then
          data_counter <= (others => '0');
        elsif comb_REPLY_POOL_PACKET_NUM = c_H0 and comb_REPLY_POOL_DATAREADY = '1'
              and comb_REPLY_POOL_DATA(2 downto 0) = TYPE_DAT then
          data_counter <= data_counter + to_unsigned(1,1);
        end if;
      end if;
    end process;

----------------------------------
--REPLY mux select input
----------------------------------
  REPLY_ARBITER: trb_net_priority_arbiter
    generic map (
      WIDTH => POINT_NUMBER
      )
    port map (
      CLK   => CLK,
      RESET  => reset_i,
      CLK_EN  => reply_arbiter_CLK_EN,
      INPUT_IN  => reply_arbiter_input,
      RESULT_OUT => reply_arbiter_result,
      ENABLE  => '1',
      CTRL => (others => '0')
      );

  reply_arbiter_input <= reply_dataready_in_i and not REPLY_reading_trm and real_activepoints;

  -- we have to care to read multiples of four packets from every point
  -- release is currently done after first packet of TRM



  gen_reply_point_lock : process(reply_point_lock, comb_REPLY_muxed_PACKET_NUM,
                                 reply_arbiter_result, reply_dataready_in_i, comb_REPLY_muxed_DATA,
                                 REPLY_MUX_reading)
    begin
      next_point_lock <= reply_point_lock;
      REPLY_MUX_reading <= reply_arbiter_result;
      --release lock if TRM is read
      if comb_REPLY_muxed_PACKET_NUM = c_H0 and or_all(REPLY_MUX_reading and reply_dataready_in_i) = '1' then
        if comb_REPLY_muxed_DATA(2 downto 0) = TYPE_TRM then
          next_point_lock <= '0';
        else
          next_point_lock <= '1';
        end if;
      end if;
    end process;


  gen_point_lock : process(CLK)
    begin
      if rising_edge(CLK) then
        if reset_i = '1' then
          reply_point_lock <= '0';
        else
          reply_point_lock <=next_point_lock;
--          last_reply_arbiter_result <= reply_arbiter_result;
        end if;
      end if;
    end process;

  reply_arbiter_CLK_EN <= not next_point_lock;

----------------------------------
--REPLY mux
----------------------------------
  gen_reply_mux1 : for i in 0 to c_DATA_WIDTH-1 generate
    data_mux : process(reply_data_in_i, REPLY_MUX_reading)
      variable tmp_data : std_logic;
      begin
        tmp_data := '0';
        gen_data_mux : for j in 0 to POINT_NUMBER-1 loop
          tmp_data := tmp_data or (reply_data_in_i(j*c_DATA_WIDTH+i) and REPLY_MUX_reading(j));
        end loop;
        comb_REPLY_muxed_DATA(i) <= tmp_data;
      end process;
  end generate;

  gen_reply_mux2 : for i in 0 to c_NUM_WIDTH-1 generate
    packet_num_mux : process(reply_packet_num_in_i, REPLY_MUX_reading)
      variable tmp_pm : std_logic;
      begin
        tmp_pm := '0';
        gen_pm_mux : for j in 0 to POINT_NUMBER-1 loop
          tmp_pm := tmp_pm or (reply_packet_num_in_i(j*c_NUM_WIDTH+i) and REPLY_MUX_reading(j));
        end loop;
        comb_REPLY_muxed_PACKET_NUM(i) <= tmp_pm;
      end process;
  end generate;

  comb_REPLY_muxed_DATAREADY <= (or_all(REPLY_MUX_reading and reply_dataready_in_i and not current_REPLY_reading_trm)) and REPLY_MUX_real_reading;


----------------------------------
--REPLY POOL state machine
----------------------------------
  reply_state_machine : process(REPLY_POOL_next_READ, current_state, packet_counter, REPLY_combined_trm_F0,
                                send_reply_trm, REPLY_combined_trm_F1, REPLY_combined_trm_F2,connection_timed_out,
                                comb_REPLY_muxed_DATAREADY, comb_REPLY_muxed_DATA, init_locked,
                                comb_REPLY_muxed_PACKET_NUM, waiting_for_init_finish, REPLY_combined_trm_F3)
    begin
      release_locked <= '0';
      next_state <= current_state;
      comb_REPLY_POOL_DATAREADY <= '0';
      comb_REPLY_POOL_PACKET_NUM <= std_logic_vector(packet_counter);
      comb_REPLY_POOL_DATA <= (others => '0');
      next_waiting_for_init_finish <= waiting_for_init_finish;

      if current_state = SENDING_DATA then
        next_waiting_for_init_finish <= '0';
        comb_REPLY_POOL_DATAREADY  <= comb_REPLY_muxed_DATAREADY;
        comb_REPLY_POOL_DATA       <= comb_REPLY_muxed_DATA;
        comb_REPLY_POOL_PACKET_NUM <= comb_REPLY_muxed_PACKET_NUM;
        if send_reply_trm = '1' then
          next_state <= SENDING_REPLY_TRM;
        end if;
      end if;

      if current_state = SENDING_REPLY_TRM then
        comb_REPLY_POOL_DATAREADY <= REPLY_POOL_next_read and not waiting_for_init_finish;
        if waiting_for_init_finish = '1' and init_locked = '1' then
          release_locked <= '1';  --release only when init has finished too
          next_state <= SENDING_DATA;
          next_waiting_for_init_finish <= '0';
        end if;
        case std_logic_vector(packet_counter) is
          when c_F0 =>
            comb_REPLY_POOL_DATA <=REPLY_combined_trm_F0;
          when c_F1 =>
            comb_REPLY_POOL_DATA <= REPLY_combined_trm_F1;
          when c_F2 =>
            comb_REPLY_POOL_DATA    <= REPLY_combined_trm_F2;
            comb_REPLY_POOL_DATA(6) <= REPLY_combined_trm_F2(6) or or_all(connection_timed_out);
          when c_F3 =>
            comb_REPLY_POOL_DATA <= REPLY_combined_trm_F3;
            if REPLY_POOL_next_read = '1' and (init_locked = '1') then
              release_locked <= '1';  --release only when init has finished too
              next_state <= SENDING_DATA;
            elsif REPLY_POOL_next_read = '1' and init_locked = '0' then
              next_waiting_for_init_finish <= '1';
            end if;
          when others =>
            comb_REPLY_POOL_DATA <= (others => '0');
            comb_REPLY_POOL_DATA(2 downto 0) <= TYPE_TRM;
          end case;
      end if;
    end process;

  reply_fsm_state <= '1' when current_state= SENDING_REPLY_TRM else '0';


  process(CLK)
    begin
      if rising_edge(CLK) then
        if reset_i = '1' then
          current_state <= SENDING_DATA;
          REPLY_POOL_next_read <= '0';
          waiting_for_init_finish <= '0';
        else
          current_state <= next_state;
          REPLY_POOL_next_read <= comb_REPLY_POOL_next_read;
          waiting_for_init_finish <= next_waiting_for_init_finish;
        end if;
      end if;
    end process;


----------------------------------
--REPLY sbuf
----------------------------------
  THE_REPLY_POOL_SBUF: trb_net16_sbuf
    generic map (
      Version => std_SBUF_VERSION
      )
    port map (
      CLK   => CLK,
      RESET  => reset_i,
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

STAT_locked <= locked;

----------------------------------
--Debugging
----------------------------------

  STAT_TIMEOUT(POINT_NUMBER-1 downto 0) <= connection_timed_out;
  STAT_TIMEOUT(15 downto POINT_NUMBER)  <= (others => '0');
  STAT_TIMEOUT(31 downto 16)            <= std_logic_vector(cnt_timeouts);

  STAT(0) <= got_trm(0);
  STAT(1) <= got_trm(1);
  STAT(2) <= REPLY_POOL_DATAREADY;
  STAT(3) <= reply_dataready_in_i(0);
  STAT(4) <= buf_REPLY_READ_OUT(0);
  STAT(5) <= comb_REPLY_muxed_DATA(14);

  STAT(6) <= reply_data_in_i(14);
  STAT(7) <= reply_data_in_i(30);
  STAT(8) <= '0';--reply_data_in_i(46);
  STAT(9) <= locked;

  STAT(15  downto 10) <= (others => '0');
  --STAT(15 downto 8) <= data_counter;
  STAT_POINTS_locked(31 downto POINT_NUMBER)  <= (others => '0');

  proc_stat_errorbits : process(CLK)
    begin
      if rising_edge(CLK) then
        last_locked <= locked;
        if locked = '1' then
          STAT_POINTS_locked(POINT_NUMBER-1 downto 0) <= not got_trm;
        else
          STAT_POINTS_locked(POINT_NUMBER-1 downto 0) <= (others => '0');
        end if;
        if locked = '0' and last_locked = '1' and reset_i = '0' then
          STAT_ERRORBITS <= REPLY_combined_trm_F1 & REPLY_combined_trm_F2;
        end if;
      end if;
    end process;


end architecture;
