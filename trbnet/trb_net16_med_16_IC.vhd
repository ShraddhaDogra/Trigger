LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net16_med_16_IC is
  generic(
	DATA_CLK_OUT_PHASE : std_logic := '1'
  );
  port(
    CLK    : in std_logic;
    CLK_EN : in std_logic;
    RESET  : in std_logic;

    --Internal Connection
    MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
    MED_DATAREADY_IN   : in  std_logic;
    MED_READ_OUT       : out std_logic;
    MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
    MED_DATAREADY_OUT  : out std_logic;
    MED_READ_IN        : in  std_logic;

    DATA_OUT           : out std_logic_vector(15 downto 0);
    DATA_VALID_OUT     : out std_logic;
    DATA_CTRL_OUT      : out std_logic;
    DATA_CLK_OUT       : out std_logic;
    DATA_IN            : in  std_logic_vector(15 downto 0);
    DATA_VALID_IN      : in  std_logic;
    DATA_CTRL_IN       : in  std_logic;
    DATA_CLK_IN        : in  std_logic;

    STAT_OP            : out std_logic_vector(15 downto 0);
    CTRL_OP            : in  std_logic_vector(15 downto 0);
    STAT_DEBUG         : out std_logic_vector(63 downto 0)
    );
end entity;



architecture trb_net16_med_16_IC_arch of trb_net16_med_16_IC is
  signal buf_DATA_IN        : std_logic_vector(15 downto 0);
  signal buf_DATA_VALID_IN  : std_logic;
  signal buf_DATA_CTRL_IN   : std_logic;
  signal reg_DATA_IN        : std_logic_vector(15 downto 0);
  signal reg_DATA_VALID_IN  : std_logic;
  signal reg_DATA_CTRL_IN   : std_logic;

  signal rx_allow_qrx       : std_logic;
  signal rx_fifo_read       : std_logic;
  signal rx_fifo_write      : std_logic;
  signal rx_fifo_reset      : std_logic;
  signal rx_fifo_full       : std_logic;
  signal rx_fifo_empty      : std_logic;
  signal rx_fifo_valid_read : std_logic;
  signal rx_fifo_dout       : std_logic_vector(17 downto 0);

  signal rx_allow           : std_logic;
  signal tx_allow           : std_logic;

  signal rx_counter         : unsigned(2 downto 0);

  signal buf_MED_DATAREADY_OUT : std_logic;
  signal buf_MED_DATA_OUT      : std_logic_vector(15 downto 0);
  signal buf_MED_READ_OUT      : std_logic;

  signal buf_DATA_VALID_OUT    : std_logic;
  signal buf_DATA_CTRL_OUT     : std_logic;
  signal buf_DATA_OUT          : std_logic_vector(15 downto 0);

  signal reg0_DATA_VALID_IN    : std_logic;
  signal reg0_DATA_CTRL_IN     : std_logic;
  signal reg0_DATA_IN          : std_logic_vector(15 downto 0);

  signal med_error : std_logic_vector(2 downto 0);
  signal link_led  : std_logic;
  signal link_running  : std_logic;
  signal tx_led    : std_logic;
  signal rx_led    : std_logic;
  signal make_reset      : std_logic;
  signal not_connected   : std_logic;
  signal resync_received : std_logic;
  signal led_counter     : unsigned(18 downto 0);

  signal state_bits : std_logic_vector(2 downto 0);
  type   link_state_t is (STARTUP, WAITING, WORKING, RESYNC_WAIT);
  signal link_state   : link_state_t;
  signal pattern_detected_q : std_logic;

  signal pattern_counter   : unsigned(11 downto 0);
  signal pattern_detected  : std_logic;
  signal last_DATA_CTRL_IN : std_logic;
  signal present_sig       : std_logic;


  signal rx_idle_pattern     : std_logic;
  signal rx_idle_pattern_q   : std_logic;
  signal rx_resync_pattern   : std_logic;
  signal rx_resync_pattern_q : std_logic;
  signal pattern_valid       : std_logic;
  signal pattern_valid_q     : std_logic;

  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  attribute HGROUP of trb_net16_med_16_IC_arch : architecture  is "media_interface_group";

begin

-------------------------------------------
-- RX Input
-------------------------------------------

  THE_INPUT_FF : process(DATA_CLK_IN)
    begin
      if falling_edge(DATA_CLK_IN) then
        buf_DATA_IN <= DATA_IN;
        buf_DATA_VALID_IN <= DATA_VALID_IN;
        buf_DATA_CTRL_IN  <= DATA_CTRL_IN;
      end if;
    end process;


  THE_INPUT_SYNC : process(DATA_CLK_IN)
    begin
      if falling_edge(DATA_CLK_IN) then
        reg0_DATA_IN       <= buf_DATA_IN;
        reg0_DATA_VALID_IN <= buf_DATA_VALID_IN;
        reg0_DATA_CTRL_IN  <= buf_DATA_CTRL_IN;
      end if;
    end process;
  THE_INPUT_SYNC_2 : process(DATA_CLK_IN)
    begin
      if rising_edge(DATA_CLK_IN) then
        reg_DATA_IN       <= reg0_DATA_IN;
        reg_DATA_VALID_IN <= reg0_DATA_VALID_IN;
        reg_DATA_CTRL_IN  <= reg0_DATA_CTRL_IN;
      end if;
    end process;

--   THE_INPUT_SYNC : signal_sync
--     generic map(
--       DEPTH => 1,
--       WIDTH => 18
--       )
--     port map(
--       RESET    => RESET,
--       D_IN(15 downto 0)  => buf_DATA_IN,
--       D_IN(16)           => buf_DATA_VALID_IN,
--       D_IN(17)           => buf_DATA_CTRL_IN,
--       CLK0     => DATA_CLK_IN,
--       CLK1     => DATA_CLK_IN,
--       D_OUT(15 downto 0) => reg_DATA_IN,
--       D_OUT(16)          => reg_DATA_VALID_IN,
--       D_OUT(17)          => reg_DATA_CTRL_IN
--       );

-------------------------------------------
-- RX Fifo
-------------------------------------------

  THE_RX_FIFO : trb_net_fifo_16bit_bram_dualport
    port map(
      read_clock_in    => CLK,
      write_clock_in   => DATA_CLK_IN,
      read_enable_in   => rx_fifo_read,
      write_enable_in  => rx_fifo_write,
      fifo_gsr_in      => rx_fifo_reset,
      write_data_in(15 downto 0) => reg_DATA_IN,
      write_data_in(16)          => reg_DATA_VALID_IN,
      write_data_in(17)          => reg_DATA_CTRL_IN,
      read_data_out    => rx_fifo_dout,
      full_out         => rx_fifo_full,
      empty_out        => rx_fifo_empty,
      fifostatus_out   => open,
      valid_read_out   => open,
      almost_empty_out => open,
      almost_full_out  => open
      );

  rx_fifo_write <= reg_DATA_VALID_IN and rx_allow_qrx;
  rx_fifo_reset <= RESET or not rx_allow_qrx;
  rx_fifo_read  <= rx_allow;


-------------------------------------------
-- RX Output
-------------------------------------------

  PROC_RX_COUNTER : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          rx_counter <= unsigned(c_H0);
        elsif buf_MED_DATAREADY_OUT = '1' and CLK_EN = '1' then
          if rx_counter = unsigned(c_max_word_number) then
            rx_counter <= (others => '0');
          else
            rx_counter <= rx_counter + 1;
          end if;
        end if;
      end if;
    end process;

  PROC_RX_READ : process(CLK)
    begin
      if rising_edge(CLK) then
        rx_fifo_valid_read <= rx_fifo_read and not rx_fifo_empty;
        buf_MED_DATAREADY_OUT <= rx_fifo_valid_read;
        buf_MED_DATA_OUT      <= rx_fifo_dout(15 downto 0);
      end if;
    end process;


  MED_DATA_OUT       <= buf_MED_DATA_OUT;
  MED_DATAREADY_OUT  <= buf_MED_DATAREADY_OUT;
  MED_PACKET_NUM_OUT <= std_logic_vector(rx_counter);


-------------------------------------------
-- TX
-------------------------------------------


  buf_MED_READ_OUT <= tx_allow;
  MED_READ_OUT     <= buf_MED_READ_OUT;


  PROC_SEND_DATA : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          buf_DATA_VALID_OUT <= '0';
          buf_DATA_CTRL_OUT  <= '0';
          buf_DATA_OUT       <= (others => '0');
          present_sig        <= '0';
        elsif CTRL_OP(15) = '1' then
          buf_DATA_VALID_OUT <= '0';
          buf_DATA_CTRL_OUT  <= not buf_DATA_CTRL_OUT;
          buf_DATA_OUT       <= x"FEFE";
        elsif MED_DATAREADY_IN = '1' and buf_MED_READ_OUT = '1' then
          buf_DATA_VALID_OUT <= '1';
          buf_DATA_OUT       <= MED_DATA_IN;
          if MED_PACKET_NUM_IN = c_H0 then
            buf_DATA_CTRL_OUT <= '1';
          else
            buf_DATA_CTRL_OUT <= '0';
          end if;
        else
          buf_DATA_OUT       <= x"AAAA";
          buf_DATA_CTRL_OUT  <= present_sig;
          buf_DATA_VALID_OUT <= '0';
          present_sig        <= not present_sig;
        end if;
      end if;
    end process;


  THE_CLK_OUT : ddr_off
    port map(
      Clk   => CLK,
      Data(0)  => not DATA_CLK_OUT_PHASE,
      Data(1)  => DATA_CLK_OUT_PHASE,
      Q(0)  => DATA_CLK_OUT
      );


  PROC_DATA_OUTPUT : process(CLK)
    begin
      if rising_edge(CLK) then
        DATA_VALID_OUT <= buf_DATA_VALID_OUT;
        DATA_CTRL_OUT  <= buf_DATA_CTRL_OUT;
        DATA_OUT       <= buf_DATA_OUT;
      end if;
    end process;


-------------------------------------------
-- Link Control
-------------------------------------------

  PROC_SIGNAL_DETECT_PREPARE : process(DATA_CLK_IN)
    begin
      if rising_edge(DATA_CLK_IN) then
        if RESET = '1' then
          last_DATA_CTRL_IN <= '0';
          pattern_detected  <= '0';
          pattern_valid     <= '0';
        elsif reg_DATA_VALID_IN = '0' then
          last_DATA_CTRL_IN <= reg_DATA_CTRL_IN;
          pattern_detected  <= last_DATA_CTRL_IN xor reg_DATA_CTRL_IN;
          pattern_valid     <= pattern_detected and not reg_DATA_VALID_IN;
        end if;
      end if;
    end process;


  PROC_FSM : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          link_state      <= STARTUP;
          link_running    <= '0';
          resync_received <= '0';
          not_connected   <= '1';
          make_reset      <= '0';
          rx_allow        <= '0';
          tx_allow        <= '0';
        else
          case link_state is
            when STARTUP =>
              med_error       <= ERROR_NC;
              link_running    <= '0';
              not_connected   <= '1';
              resync_received <= '0';
              rx_allow        <= '0';
              tx_allow        <= '0';
              if pattern_detected_q = '1' then
                not_connected    <= '0';
                link_state      <= WAITING;
                pattern_counter <= x"040";
              end if;

            when WAITING =>
              med_error <= ERROR_WAIT;
              if pattern_valid_q = '1' then
                pattern_counter <= pattern_counter + "1";
              elsif pattern_detected_q = '0' then
                pattern_counter <= pattern_counter - x"39";
              end if;
              if pattern_counter < x"040" then
                link_state <= STARTUP;
              elsif pattern_counter = x"DFF" then
                rx_allow <= '1';
              elsif pattern_counter = x"FFF" then
                link_state <= WORKING;
                tx_allow <= '1';
              end if;

            when WORKING =>
              med_error <= ERROR_OK;
              link_running <= '1';
              if rx_resync_pattern_q = '1' then
                resync_received <= '1';
              else
                resync_received <= '0';
                make_reset <= resync_received;
              end if;

              if pattern_detected_q = '0' then
                link_running  <= '0';
                link_state    <= STARTUP;
              end if;

            when RESYNC_WAIT =>
              med_error <= ERROR_WAIT;
              if rx_idle_pattern_q = '1' then
                link_state <= WAITING;
                pattern_counter <= x"040";
              elsif pattern_detected_q = '0' then
                link_state <= STARTUP;
              end if;

            when others =>
              link_state <= STARTUP;
          end case;
        end if;
      end if;
    end process;

  state_bits <= "000" when link_state = STARTUP else
                "001" when link_state = WAITING else
                "011" when link_state = RESYNC_WAIT else
                "100" when link_state = WORKING else "111";

-------------------------------------------
-- Transfer RX status to sys clock domain
-------------------------------------------

  rx_idle_pattern   <= '1' when reg_DATA_IN = x"AAAA" and reg_DATA_VALID_IN = '0' else '0';
  rx_resync_pattern <= '1' when reg_DATA_IN = x"FEFE" and reg_DATA_VALID_IN = '0' else '0';


  THE_SYNC_TO_SYS : signal_sync
    generic map(
      DEPTH => 3,
      WIDTH => 4
      )
    port map(
      RESET             => RESET,
      D_IN(0)           => pattern_detected,
      D_IN(1)           => rx_idle_pattern,
      D_IN(2)           => rx_resync_pattern,
      D_IN(3)           => pattern_valid,
      CLK0              => DATA_CLK_IN,
      CLK1              => CLK,
      D_OUT(0)          => pattern_detected_q,
      D_OUT(1)          => rx_idle_pattern_q,
      D_OUT(2)          => rx_resync_pattern_q,
      D_OUT(3)          => pattern_valid_q
      );

  THE_SYNC_TO_RX : signal_sync
    generic map(
      DEPTH => 3,
      WIDTH => 1
      )
    port map(
      RESET             => RESET,
      D_IN(0)           => rx_allow,
      CLK0              => CLK,
      CLK1              => DATA_CLK_IN,
      D_OUT(0)          => rx_allow_qrx
      );





-------------------------------------------
-- Link Status Information
-------------------------------------------

  PROC_LED : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' or not_connected = '1' then
          led_counter <= (others => '0');
          rx_led      <= '0';
          tx_led      <= '0';
          link_led    <= '0';
        else
          led_counter <= led_counter + 1;
          link_led    <= link_running;
          if led_counter(18) = '1' then
            led_counter <= (others => '0');
            rx_led    <= '0';
            tx_led    <= '0';
          end if;
          if buf_MED_DATAREADY_OUT = '1' then
            rx_led    <= '1';
          end if;
          if MED_DATAREADY_IN = '1' and buf_MED_READ_OUT = '1' then
            tx_led    <= '1';
          end if;
        end if;
      end if;
    end process;


  STAT_OP(2 downto 0) <= med_error;
  STAT_OP(8 downto 3) <= (others => '0');
  STAT_OP(9)  <= link_led;
  STAT_OP(10) <= rx_led;
  STAT_OP(11) <= tx_led;
  STAT_OP(12) <= '0';
  STAT_OP(13) <= make_reset;
  STAT_OP(14) <= not_connected;
  STAT_OP(15) <= resync_received;


-------------------------------------------
-- Debug
-------------------------------------------
  STAT_DEBUG(0)            <= reg_DATA_VALID_IN;
  STAT_DEBUG(1)            <= reg_DATA_CTRL_IN;
  STAT_DEBUG(2)            <= make_reset;
  STAT_DEBUG(3)            <= MED_DATAREADY_IN;
  STAT_DEBUG(4)            <= last_DATA_CTRL_IN;
  STAT_DEBUG(5)            <= buf_DATA_VALID_OUT;
  STAT_DEBUG(6)            <= buf_MED_READ_OUT;
  STAT_DEBUG(7)            <= resync_received;
  STAT_DEBUG(15 downto 8)  <= reg_DATA_IN(7 downto 0);
  STAT_DEBUG(18 downto 16) <= state_bits;
  STAT_DEBUG(31 downto 19) <= buf_DATA_OUT(12 downto 0);

  STAT_DEBUG(63 downto 32) <= (others => '0');

end architecture;