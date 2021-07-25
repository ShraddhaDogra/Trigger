--media interface with 16 data lines, single data rate and oversampling of RX input
--oversampling running at 250 MHz



LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net16_med_16_SDR_OS is
  generic(
    TRANSMISSION_CLOCK_DIV: integer range 1 to 10 := 1
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    INT_DATAREADY_OUT  : out std_logic;
    INT_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    INT_READ_IN        : in  std_logic;

    INT_DATAREADY_IN   : in  std_logic;
    INT_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
    INT_READ_OUT       : out std_logic;

    --  Media direction port
    TX_DATA_OUT        : out std_logic_vector (15 downto 0);
    TX_CLK_OUT         : out std_logic;
    TX_CTRL_OUT        : out std_logic_vector (3 downto 0);
    RX_DATA_IN         : in  std_logic_vector (15 downto 0);
    RX_CLK_IN          : in  std_logic;
    RX_CTRL_IN         : in  std_logic_vector (3 downto 0);

    -- Status and control port
    STAT_OP: out std_logic_vector (15 downto 0);
    CTRL_OP: in  std_logic_vector (15 downto 0);

    STAT: out std_logic_vector (31 downto 0);
    CTRL: in  std_logic_vector (31 downto 0)
    );
end entity;

architecture trb_net16_med_16_SDR_OS_arch of trb_net16_med_16_SDR_OS is
  component trb_net_clock_generator is
    generic(
      FREQUENCY_IN  : real;
      FREQUENCY_OUT : real;
      CLOCK_MULT    : integer range 1 to 32;
      CLOCK_DIV     : integer range 1 to 32;
      CLKIN_DIVIDE_BY_2 : boolean;
      CLKIN_PERIOD  : real
      );
    port(
      RESET    : in  std_logic;
      CLK_IN   : in  std_logic;
      CLK_OUT  : out std_logic;
      LOCKED   : out std_logic
      );
  end component;

  component trb_net_fifo_16bit_bram_dualport is
    generic(
      USE_STATUS_FLAGS : integer  := c_YES
      );
    port (
      read_clock_in:   IN  std_logic;
      write_clock_in:  IN  std_logic;
      read_enable_in:  IN  std_logic;
      write_enable_in: IN  std_logic;
      fifo_gsr_in:     IN  std_logic;
      write_data_in:   IN  std_logic_vector(17 downto 0);
      read_data_out:   OUT std_logic_vector(17 downto 0);
      full_out:        OUT std_logic;
      empty_out:       OUT std_logic;
      fifostatus_out:  OUT std_logic_vector(3 downto 0);
      valid_read_out:  OUT std_logic;
      almost_empty_out:OUT std_logic;
      almost_full_out :OUT std_logic
      );
  end component;

  component dualdatarate_flipflop is
  --1 clock, no CE, PRE for Lattice SCM
    generic(
      WIDTH : integer := 1
      );
    port(
      C0 : in std_logic;
      C1 : in std_logic;
      CE : in std_logic;
      CLR : in std_logic;
      D0 : in std_logic_vector(WIDTH-1 downto 0);
      D1 : in std_logic_vector(WIDTH-1 downto 0);
      PRE : in std_logic;
      Q : out std_logic_vector(WIDTH-1 downto 0)
      );
  end component;

  signal RECV_CLK, recv_clk_locked : std_logic;
  signal reg_RX_CLK, buf_RX_CLK, last_RX_CLK   : std_logic;
  signal reg_RX_CTRL, buf_RX_CTRL : std_logic_vector(3 downto 0);
  signal reg_RX_DATA, buf_RX_DATA : std_logic_vector(15 downto 0);

  signal rx_datavalid    : std_logic;
  signal rx_first_packet : std_logic;
  signal rx_reset        : std_logic;
  signal rx_parity       : std_logic;
  signal rx_parity_match : std_logic;

  signal rx_fifo_read_enable : std_logic;
  signal rx_fifo_write_enable, next_rx_fifo_write_enable: std_logic;
  signal rx_fifo_data_in, next_rx_fifo_data_in     : std_logic_vector(17 downto 0);
  signal rx_fifo_data_out    : std_logic_vector(17 downto 0);
  signal rx_fifo_full        : std_logic;
  signal rx_fifo_empty       : std_logic;
  signal rx_fifostatus_out : std_logic_vector(3 downto 0);
  signal rx_valid_read_out : std_logic;
  signal rx_almost_empty_out : std_logic;
  signal rx_almost_full_out  : std_logic;


  signal buf_INT_DATAREADY_OUT  : std_logic;

  signal rx_packet_counter      : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal wait_for_startup       : std_logic;
  signal wait_for_startup_slow  : std_logic;
  signal rx_CLK_counter         : std_logic_vector(4 downto 0);
  signal rx_clock_detect        : std_logic;

  signal med_reset : std_logic;

  signal tx_datavalid, tx_first_packet, tx_reset, tx_parity : std_logic;
  signal buf_INT_DATA_IN  : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal buf_INT_READ_OUT : std_logic;
  signal tx_clock_enable  : std_logic;
  signal next_tx_reset    : std_logic;
  signal buf_tx_reset     : std_logic;
  signal buf_tx_clk       : std_logic;
  signal recv_clk_real_locked : std_logic;
  signal locked_counter : std_logic_vector(19 downto 0);

  signal led_counter : std_logic_vector(18 downto 0);
  signal send_resync_counter : std_logic_vector(11 downto 0);
  signal send_resync         : std_logic;
  signal rx_led, tx_led, link_led : std_logic;
  signal med_error        : std_logic_vector(2 downto 0);
  signal trbnet_reset : std_logic;
begin


--Transmitter (full speed only)
-------------------------
  INT_READ_OUT <= buf_INT_READ_OUT;
  buf_INT_READ_OUT <= not wait_for_startup_slow and not buf_tx_reset;

  TX_DATA_OUT     <= buf_INT_DATA_IN;
  TX_CTRL_OUT(0)  <= tx_datavalid;
  TX_CTRL_OUT(1)  <= tx_first_packet;
  TX_CTRL_OUT(2)  <= tx_reset;
  TX_CTRL_OUT(3)  <= tx_parity;

  tx_clock_enable <= not RESET;

  next_tx_reset <= CTRL_OP(15) or (recv_clk_real_locked and wait_for_startup_slow);


  process(CLK)
    begin
      if rising_edge(CLK) then
        TX_CLK_OUT <= buf_tx_clk;
      end if;
    end process;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if med_reset = '1' then
          tx_datavalid <= '0';
          tx_reset <= '1';
          buf_tx_reset <= '1';
          buf_INT_DATA_IN <= (others => '0');
          tx_first_packet <= '0';
          tx_parity <= '0';
          buf_tx_clk <= '0';
        else
          buf_INT_DATA_IN <= INT_DATA_IN;
          tx_datavalid    <= INT_DATAREADY_IN and buf_INT_READ_OUT;
          if INT_PACKET_NUM_IN = c_H0 then
            tx_first_packet <= '1';
          else
            tx_first_packet <= '0';
          end if;
          tx_reset        <= buf_tx_reset;
          buf_tx_reset    <= next_tx_reset;
          tx_parity       <= xor_all(INT_DATA_IN);
          buf_tx_clk      <= not buf_tx_clk;
        end if;
      end if;
    end process;



--Receiver
-------------------------
  RECV_CLOCK_GEN : trb_net_clock_generator
    generic map(
      FREQUENCY_IN  => 100.0,
      FREQUENCY_OUT => 200.0,
      CLOCK_MULT    => 2,
      CLOCK_DIV     => 1,
      CLKIN_DIVIDE_BY_2 => false,
      CLKIN_PERIOD  => 10.0
      )
    port map(
      RESET   => RESET,
      CLK_IN  => CLK,
      CLK_OUT => RECV_CLK,
      LOCKED  => recv_clk_locked
      );

process(CLK)
  begin
    if rising_edge(CLK) then
      if recv_clk_locked = '0' then
        locked_counter <= (others => '0');
        recv_clk_real_locked <= '0';
      else
        if locked_counter /= x"0000F" then
          locked_counter <= locked_counter + 1;
        else
          recv_clk_real_locked <= '1';
        end if;
      end if;
    end if;
  end process;

  RX_INPUT_REG : process(RECV_CLK)
    begin
      if rising_edge(RECV_CLK) then
        reg_RX_CLK  <= RX_CLK_IN;
        reg_RX_CTRL <= RX_CTRL_IN;
        reg_RX_DATA <= RX_DATA_IN;
      end if;
    end process;

  RX_REG : process(RECV_CLK, recv_clk_real_locked)
    begin
      if rising_edge(RECV_CLK) then
        if recv_clk_real_locked = '0' then
          buf_RX_CTRL <= (others => '0');
          buf_RX_CLK  <= '0';
          last_RX_CLK <= '0';
          buf_RX_DATA <= (others => '0');
        else
          buf_RX_CLK  <= reg_RX_CLK;
          buf_RX_DATA <= reg_RX_DATA;
          buf_RX_CTRL <= reg_RX_CTRL;
          last_RX_CLK <= buf_RX_CLK;
        end if;
      end if;
    end process;

  rx_datavalid    <= buf_RX_CTRL(0);
  rx_first_packet <= buf_RX_CTRL(1);
  rx_reset        <= buf_RX_CTRL(2);
  rx_parity       <= buf_RX_CTRL(3);

  rx_parity_match      <= '1' when rx_parity = xor_all(buf_RX_DATA) else '0';
  next_rx_fifo_write_enable <= (buf_RX_CLK xor last_RX_CLK) and rx_datavalid;
  next_rx_fifo_data_in      <= rx_first_packet & rx_parity_match & buf_RX_DATA;

  reg_fifo_in : process(RECV_CLK)
    begin
      if rising_edge(RECV_CLK) then
        rx_fifo_write_enable <= next_rx_fifo_write_enable;
        rx_fifo_data_in      <= next_rx_fifo_data_in;
      end if;
    end process;

  RX_FIFO : trb_net_fifo_16bit_bram_dualport
    port map(
      read_clock_in => CLK,
      write_clock_in => RECV_CLK,
      read_enable_in => rx_fifo_read_enable,
      write_enable_in => rx_fifo_write_enable,
      fifo_gsr_in => med_reset,
      write_data_in => rx_fifo_data_in,
      read_data_out => rx_fifo_data_out,
      full_out => rx_fifo_full,
      empty_out => rx_fifo_empty,
      fifostatus_out => rx_fifostatus_out,
      valid_read_out => rx_valid_read_out,
      almost_empty_out => rx_almost_empty_out,
      almost_full_out => rx_almost_full_out
      );

  rx_fifo_read_enable <= INT_READ_IN;

  INT_DATA_OUT <= rx_fifo_data_out(15 downto 0);
  INT_PACKET_NUM_OUT <= rx_packet_counter;
  INT_DATAREADY_OUT <= buf_INT_DATAREADY_OUT;

  packet_counter_p : process(CLK)
    begin
      if rising_edge(CLK) then
        if med_reset = '1' then
          rx_packet_counter <= "100";
        elsif buf_INT_DATAREADY_OUT = '1' then
          if rx_packet_counter = c_max_word_number then
            rx_packet_counter <= (others => '0');
          else
            rx_packet_counter <= rx_packet_counter + 1;
          end if;
        end if;
      end if;
    end process;


  rx_dataready_p : process(CLK)
    begin
      if rising_edge(CLK) then
        if med_reset = '1' then
          buf_INT_DATAREADY_OUT <= '0';
        else
          buf_INT_DATAREADY_OUT <= rx_fifo_read_enable and not rx_fifo_empty;
        end if;
      end if;
    end process;


--monitor link
-------------------------
  process(CLK)
    begin
      if rising_edge(CLK) then
        wait_for_startup_slow <= wait_for_startup;
      end if;
    end process;

  process(RECV_CLK, recv_clk_real_locked,med_reset)
    begin
      if rising_edge(RECV_CLK) then
        if recv_clk_real_locked = '0' or med_reset = '1' or rx_clock_detect = '0' then
          wait_for_startup <= '1';
        elsif rx_reset = '1' and recv_clk_locked = '1' then
          wait_for_startup <= '0';
        end if;
      end if;
    end process;


  ERROR_OUT_gen : process(CLK)
    begin
      if rising_edge(CLK) then
        if recv_clk_real_locked = '0' or rx_clock_detect = '0' then
          med_error <= ERROR_NC;
        elsif (buf_INT_DATAREADY_OUT = '1' and rx_fifo_data_out(16) = '0')  then --Parity error
          med_error <= ERROR_ENCOD;
        elsif (rx_packet_counter /= "100" and buf_INT_DATAREADY_OUT = '1' and rx_fifo_data_out(17) = '1') then
          med_error <= ERROR_FATAL;                                          --Counter error
        else
          med_error <= ERROR_OK;
        end if;
      end if;
    end process;


  rx_clk_detect_counter: process (RECV_CLK, recv_clk_real_locked)
    begin
      if rising_edge(RECV_CLK) then
        if recv_clk_real_locked = '0'  then
          rx_CLK_counter <= (others => '0');
          rx_clock_detect <= '0';
        elsif buf_RX_CLK = '1' and last_RX_CLK = '0' then
          rx_CLK_counter <= (others => '0');
          rx_clock_detect <= '1';
        elsif rx_CLK_counter /= 31 then
          rx_CLK_counter <= rx_CLK_counter + 1;
        elsif rx_CLK_counter = 31 then
          rx_clock_detect <= '0';
        end if;
      end if;
    end process;


--STAT & CTRL Ports
-------------------------

--LED
  link_led <= rx_clock_detect and not wait_for_startup_slow;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if led_counter(18) = '1' then
          led_counter <= (others => '0');
        else
          led_counter <= led_counter + 1;
        end if;
        if rx_fifo_empty = '0' then
          rx_led <= '1';
        elsif led_counter(18) = '1' then
          rx_led <= '0';
        end if;
        if tx_datavalid = '1' then
          tx_led <= '1';
        elsif led_counter(18) = '1' then
          tx_led <= '0';
        end if;
      end if;
    end process;


  STAT_OP(2 downto 0) <= med_error;
  STAT_OP(8 downto 3) <= (others => '0');
  STAT_OP(9)  <= link_led;
  STAT_OP(10) <= rx_led;
  STAT_OP(11) <= tx_led;
  STAT_OP(12) <= '0';
  STAT_OP(13) <= trbnet_reset;
  STAT_OP(14) <= rx_clock_detect;
  STAT_OP(15) <= '1' when rx_reset = '1' and wait_for_startup_slow = '0' else '0';

  STAT(12) <= rx_parity_match;
  STAT(11) <= RECV_CLK;
  STAT(10) <= recv_clk_real_locked;
  STAT(9) <= rx_reset;
  STAT(8) <= buf_RX_CLK xor last_RX_CLK;
  STAT(7) <= recv_clk_locked;
  STAT(6) <= wait_for_startup;
  STAT(5) <= rx_first_packet;
  STAT(4) <= buf_tx_clk; --not or_all(INT_PACKET_NUM_IN); --tx_first_packet;
  STAT(3) <= rx_datavalid;
  STAT(2) <= next_tx_reset;
  STAT(1) <= buf_RX_CLK;

  STAT(13) <= or_all(rx_fifostatus_out);
  STAT(14) <= rx_valid_read_out;
  STAT(15) <= rx_almost_empty_out;
  STAT(16) <= rx_almost_full_out;
  STAT(31 downto 17)    <= (others => '0');

  med_reset <= RESET or send_resync;
  trbnet_reset <= rx_reset or not recv_clk_real_locked;


--detect resync
  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          send_resync <= '0';
          send_resync_counter <= (others => '0');
        else
          if not (send_resync_counter = 0) then
            send_resync_counter <= send_resync_counter + 1;
          end if;
          if CTRL_OP(15) = '1' and send_resync_counter(11 downto 4) = 0 then
            send_resync <= '1';
            send_resync_counter <= send_resync_counter + 1;
          end if;
          if send_resync_counter = x"00F" then
            send_resync <= '0';
          end if;
        end if;
      end if;
    end process;

end architecture;