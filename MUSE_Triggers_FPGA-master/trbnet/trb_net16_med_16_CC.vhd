-- A 16bit data interface between two devices using a common clock, 32 data lines and 4 control lines


LIBRARY ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net16_med_16_CC is
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
    DATA_IN            : in  std_logic_vector(15 downto 0);
    DATA_VALID_IN      : in  std_logic;
    DATA_CTRL_IN       : in  std_logic;

    STAT_OP            : out std_logic_vector(15 downto 0);
    CTRL_OP            : in  std_logic_vector(15 downto 0);
    STAT_DEBUG         : out std_logic_vector(63 downto 0)
    );
  attribute syn_useioff : boolean;
  attribute syn_useioff of DATA_OUT : signal is true;
  attribute syn_useioff of DATA_VALID_OUT : signal is true;
  attribute syn_useioff of DATA_CTRL_OUT : signal is true;
  attribute syn_useioff of DATA_IN : signal is true;
  attribute syn_useioff of DATA_VALID_IN : signal is true;
  attribute syn_useioff of DATA_CTRL_IN : signal is true;

end entity;

architecture trb_net16_med_16_CC_arch of trb_net16_med_16_CC is

  component signal_sync is
    generic(
      WIDTH : integer := 18;
      DEPTH : integer := 3
      );
    port(
      RESET    : in  std_logic;
      CLK0     : in  std_logic;
      CLK1     : in  std_logic;
      D_IN     : in  std_logic_vector(WIDTH-1 downto 0);
      D_OUT    : out std_logic_vector(WIDTH-1 downto 0)
      );
  end component;

  signal buf_DATA_IN       : std_logic_vector(15 downto 0);
  signal buf_DATA_VALID_IN : std_logic;
  signal buf_DATA_CTRL_IN  : std_logic;

  signal reg_DATA_IN       : std_logic_vector(15 downto 0);
  signal reg_DATA_VALID_IN : std_logic;
  signal reg_DATA_CTRL_IN  : std_logic;

  signal last_DATA_CTRL_IN : std_logic;
  signal link_running      : std_logic;

  signal buf_DATA_VALID_OUT   : std_logic;
  signal buf_DATA_CTRL_OUT    : std_logic;
  signal buf_DATA_OUT         : std_logic_vector(15 downto 0);
  signal PRESENT_SIG          : std_logic;
  signal led_counter          : unsigned(18 downto 0);

  signal link_led             : std_logic;
  signal tx_led               : std_logic;
  signal rx_led               : std_logic;
  --signal resync               : std_logic;
  --signal resync_counter       : unsigned(4 downto 0);

  signal rx_counter           : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal buf_MED_READ_OUT     : std_logic;
  signal buf_MED_DATAREADY_OUT  : std_logic;
  signal buf_MED_PACKET_NUM_OUT : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal buf_MED_DATA_OUT       : std_logic_vector(c_DATA_WIDTH-1 downto 0);

  signal not_connected : std_logic;
  signal resync_received: std_logic;
  type   link_state_t is (STARTUP, WAITING, WORKING, RESYNCING, RESYNC_WAIT);
  signal link_state   : link_state_t;
  signal med_error    : std_logic_vector(2 downto 0);
  signal pattern_counter  : unsigned(11 downto 0);
  signal pattern_detected : std_logic;
  signal state_bits   : std_logic_vector(2 downto 0);
  signal make_reset   : std_logic;


begin

-----------------------
--Receiver
-----------------------

  PROC_RX_INPUT : process(CLK)
    begin
      if rising_edge(CLK) then
        buf_DATA_IN <= DATA_IN;
        buf_DATA_VALID_IN <= DATA_VALID_IN;
        buf_DATA_CTRL_IN  <= DATA_CTRL_IN;
      end if;
    end process;

  THE_RX_SIGNAL_SYNC: signal_sync
    generic map(
      DEPTH => 2,
      WIDTH => 18
      )
    port map(
      RESET    => RESET,
      D_IN(15 downto 0)  => buf_DATA_IN,
      D_IN(16)           => buf_DATA_VALID_IN,
      D_IN(17)           => buf_DATA_CTRL_IN,
      CLK0     => CLK,
      CLK1     => CLK,
      D_OUT(15 downto 0) => reg_DATA_IN,
      D_OUT(16)          => reg_DATA_VALID_IN,
      D_OUT(17)          => reg_DATA_CTRL_IN
      );


  PROC_RX_COUNTER : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          rx_counter <= c_H0;
        elsif buf_MED_DATAREADY_OUT = '1' and CLK_EN = '1' then
          if rx_counter = c_max_word_number then
            rx_counter <= (others => '0');
          else
            rx_counter <= rx_counter + 1;
          end if;
        end if;
      end if;
    end process;


  buf_MED_PACKET_NUM_OUT <= rx_counter;
  buf_MED_DATAREADY_OUT  <= reg_DATA_VALID_IN and link_running;
  buf_MED_DATA_OUT       <= reg_DATA_IN;
  buf_MED_READ_OUT       <= link_running;
  MED_READ_OUT           <= buf_MED_READ_OUT;

  PROC_REG_MED_OUT : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          MED_DATA_OUT      <= buf_MED_DATA_OUT;
          MED_DATAREADY_OUT <= '0';
          MED_PACKET_NUM_OUT<= buf_MED_PACKET_NUM_OUT;
        else
          MED_DATA_OUT      <= buf_MED_DATA_OUT;
          MED_DATAREADY_OUT <= buf_MED_DATAREADY_OUT;
          MED_PACKET_NUM_OUT<= buf_MED_PACKET_NUM_OUT;
        end if;
      end if;
    end process;


-----------------------
--Link detection & Status & Control signals
-----------------------

  STAT_OP(2 downto 0) <= med_error;
  STAT_OP(8 downto 3) <= (others => '0');
  STAT_OP(9)  <= link_led;
  STAT_OP(10) <= rx_led;
  STAT_OP(11) <= tx_led;
  STAT_OP(12) <= '0';
  STAT_OP(13) <= make_reset;
  STAT_OP(14) <= not_connected;
  STAT_OP(15) <= resync_received;


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


  PROC_SIGNAL_DETECT_PREPARE : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          last_DATA_CTRL_IN <= '0';
          pattern_detected  <= '0';
        elsif reg_DATA_VALID_IN = '0' then
          last_DATA_CTRL_IN <= reg_DATA_CTRL_IN;
          pattern_detected  <= last_DATA_CTRL_IN xor reg_DATA_CTRL_IN;
        end if;
      end if;
    end process;

  PROC_FSM : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          link_state    <= STARTUP;
          link_running  <= '0';
          resync_received <= '0';
          not_connected  <= '1';
          make_reset     <= '0';
        else
          case link_state is
            when STARTUP =>
              med_error     <= ERROR_NC;
              link_running  <= '0';
              not_connected  <= '1';
              resync_received <= '0';
              if pattern_detected = '1' then
                not_connected    <= '0';
                link_state      <= WAITING;
                pattern_counter <= x"040";
              end if;

            when WAITING =>
              med_error <= ERROR_WAIT;
              if pattern_detected = '1' and reg_DATA_VALID_IN = '0' then
                pattern_counter <= pattern_counter + "1";
              elsif pattern_detected = '0' then
                pattern_counter <= pattern_counter - x"40";
              end if;
              if pattern_counter < x"040" then
                link_state <= STARTUP;
              elsif pattern_counter = x"FFF" then
                link_state <= WORKING;
              end if;

            when WORKING =>
              med_error <= ERROR_OK;
              link_running <= '1';
--               if CTRL_OP(15) = '1' then
--                 link_state     <= RESYNCING;
--                 resync_counter <= (others => '0');
--                 link_running   <= '0';
--               end if;
--               if (reg_DATA_VALID_IN = '1' and reg_DATA_CTRL_IN = '1' and rx_counter /= c_H0)
--                 or (reg_DATA_VALID_IN = '1' and reg_DATA_CTRL_IN = '0' and rx_counter = c_H0) then
--                 resync_needed <= '1';
--               else
--                 resync_needed <= '0';
--               end if;
              if reg_DATA_VALID_IN = '0' and reg_DATA_IN = x"FEFE" then
                resync_received <= '1';
              else
                resync_received <= '0';
                make_reset <= resync_received;
              end if;

              if pattern_detected = '0' then
                link_running  <= '0';
                link_state    <= STARTUP;
              end if;

--             when RESYNCING =>
--               med_error <= ERROR_WAIT;
--               resync <= '1';
--               if CTRL_OP(15) = '0' then
--                 resync     <= '0';
--                 link_state <= RESYNC_WAIT;
--               end if;

            when RESYNC_WAIT =>
              med_error <= ERROR_WAIT;
              if reg_DATA_VALID_IN = '0' and reg_DATA_IN = x"AAAA" then
                link_state <= WAITING;
                pattern_counter <= x"040";
              elsif pattern_detected = '0' then
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
                "010" when link_state = RESYNCING else
                "011" when link_state = RESYNC_WAIT else
                "100" when link_state = WORKING else "111";


-----------------------
--Sender
-----------------------


--Generate tx signals
  PROC_SEND_DATA : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          buf_DATA_VALID_OUT <= '0';
          buf_DATA_CTRL_OUT  <= '0';
          buf_DATA_OUT       <= (others => '0');
          PRESENT_SIG        <= '0';
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
          buf_DATA_CTRL_OUT  <= PRESENT_SIG;
          buf_DATA_VALID_OUT <= '0';
          PRESENT_SIG        <= not PRESENT_SIG;
        end if;
      end if;
    end process;

--Generate O-FF
  PROC_OUTPUT : process(CLK)
    begin
      if rising_edge(CLK) then
        DATA_VALID_OUT <= buf_DATA_VALID_OUT;
        DATA_CTRL_OUT  <= buf_DATA_CTRL_OUT;
        DATA_OUT       <= buf_DATA_OUT;
      end if;
    end process;



-----------------------
--Debug
-----------------------

STAT_DEBUG(15 downto 0) <= reg_DATA_IN;
STAT_DEBUG(16)          <= reg_DATA_VALID_IN;
STAT_DEBUG(17)          <= reg_DATA_CTRL_IN;
STAT_DEBUG(18)          <= resync_received;
STAT_DEBUG(22 downto 19)<= std_logic_vector(pattern_counter(3 downto 0));
STAT_DEBUG(23)          <= '0';
STAT_DEBUG(26 downto 24)<= state_bits;

STAT_DEBUG(63 downto 27) <= (others => '0');

end architecture;