
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net16_med_8_SDR_OS is
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
    TX_DATA_OUT        : out std_logic_vector (7 downto 0);
    TX_CLK_OUT         : out std_logic;
    TX_CTRL_OUT        : out std_logic_vector (1 downto 0);
    RX_DATA_IN         : in  std_logic_vector (7 downto 0);
    RX_CLK_IN          : in  std_logic;
    RX_CTRL_IN         : in  std_logic_vector (1 downto 0);

    -- Status and control port
    STAT_OP: out std_logic_vector (15 downto 0);
    CTRL_OP: in  std_logic_vector (15 downto 0);

    STAT: out std_logic_vector (31 downto 0);
    CTRL: in  std_logic_vector (31 downto 0)
    );
end entity;

architecture trb_net16_med_8_SDR_OS_arch of trb_net16_med_8_SDR_OS is

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

  component signal_sync is
    generic(
      WIDTH : integer := 1;     --
      DEPTH : integer := 3
      );
    port(
      RESET    : in  std_logic; --Reset is neceessary to avoid optimization to shift register
      CLK0     : in  std_logic;                          --clock for first FF
      CLK1     : in  std_logic;                          --Clock for other FF
      D_IN     : in  std_logic_vector(WIDTH-1 downto 0); --Data input
      D_OUT    : out std_logic_vector(WIDTH-1 downto 0)  --Data output
      );
  end component;

  signal reg_RX_CLK, buf_RX_CLK, last_RX_CLK   : std_logic;
  signal reg_RX_CTRL, buf_RX_CTRL : std_logic_vector(1 downto 0);
  signal reg_RX_DATA, buf_RX_DATA : std_logic_vector(7 downto 0);

  signal rx_datavalid    : std_logic;
  signal rx_reset        : std_logic;
  signal rx_fifo_read_enable : std_logic;
  signal rx_fifo_write_enable, next_rx_fifo_write_enable: std_logic;
  signal rx_fifo_data_in, next_rx_fifo_data_in     : std_logic_vector(17 downto 0);
  signal rx_fifo_data_out    : std_logic_vector(17 downto 0);
  signal rx_fifo_empty       : std_logic;
  signal rx_packet_counter      : std_logic_vector(3 downto 0);
  signal rx_CLK_counter         : std_logic_vector(4 downto 0);
  signal rx_clock_detect        : std_logic;


  signal saved_fifo_data_out : std_logic_vector(7 downto 0);

  signal med_reset : std_logic;

  signal tx_datavalid : std_logic;
  signal buf_INT_READ_OUT : std_logic;
  signal buf_INT_DATAREADY_OUT  : std_logic;
  signal buf_tx_reset     : std_logic;
  signal buf_tx_clk       : std_logic;

  signal led_counter : std_logic_vector(18 downto 0);
  signal rx_led, tx_led, link_led : std_logic;
  signal med_error        : std_logic_vector(2 downto 0);

  signal tx_data : std_logic_vector(7 downto 0);
  signal tx_word_waiting : std_logic;
  signal tx_data_buffer : std_logic_vector(7 downto 0);
  signal last_rx_fifo_read_enable : std_logic;
  signal last_rx_fifo_empty : std_logic;
  signal buf_tx_half_clk : std_logic;
  signal rx_active : std_logic;
  signal tx_active : std_logic;
  signal rx_fifo_reset : std_logic;
  signal active_counter : std_logic_vector(15 downto 0);

begin

  med_reset <= RESET;



--Transmitter
-------------------------
  INT_READ_OUT <= buf_INT_READ_OUT;



  process(CLK)
    begin
      if rising_edge(CLK) then
        TX_CLK_OUT      <= buf_tx_half_clk;
        TX_DATA_OUT     <= tx_data;
        TX_CTRL_OUT(0)  <= tx_datavalid;
        TX_CTRL_OUT(1)  <= buf_tx_reset;
      end if;
    end process;


  process(CLK)
    begin
      if rising_edge(CLK) then
        if med_reset = '1' then
          buf_tx_reset <= '1';
          buf_tx_clk <= '0';
          buf_tx_half_clk <= '0';
        else
          buf_tx_reset    <= not tx_active;
          buf_tx_clk      <= not buf_tx_clk;
          if buf_tx_clk = '1' then
            buf_tx_half_clk <= not buf_tx_half_clk;
          end if;
        end if;
      end if;
    end process;


  process(CLK)
    begin
      if rising_edge(CLK) then
        if med_reset = '1' or tx_active = '0' then
          tx_datavalid     <= '0';
          buf_INT_READ_OUT <= '0';
          tx_data          <= (others => '0');
          tx_word_waiting  <= '0';
        else
          buf_INT_READ_OUT <= '0';
          if buf_tx_half_clk = '0' and buf_tx_clk = '0' then
            if tx_word_waiting = '1' then
              tx_data          <= tx_data_buffer;
              tx_datavalid     <= '1';
              tx_word_waiting  <= '0';
            elsif INT_DATAREADY_IN = '1' and buf_INT_READ_OUT = '1' then
              tx_data          <= INT_DATA_IN(15 downto 8);
              tx_data_buffer   <= INT_DATA_IN(7 downto 0);
              tx_datavalid     <= '1';
              tx_word_waiting  <= '1';
            else
              tx_datavalid <= '0';
            end if;
          elsif buf_tx_half_clk = '1' and buf_tx_clk = '1' then
            buf_INT_READ_OUT <= not tx_word_waiting and tx_active;
          end if;
        end if;
      end if;
    end process;



--Receiver
-------------------------

  RX_INPUT_REG : process(CLK)
    begin
      if rising_edge(CLK) then
        reg_RX_CLK  <= RX_CLK_IN;
        reg_RX_CTRL <= RX_CTRL_IN;
        reg_RX_DATA <= RX_DATA_IN;
      end if;
    end process;

  RX_REG : process(CLK)
    begin
      if rising_edge(CLK) then
        buf_RX_CLK  <= reg_RX_CLK;
        buf_RX_DATA <= reg_RX_DATA;
        buf_RX_CTRL <= reg_RX_CTRL;
        last_RX_CLK <= buf_RX_CLK;
      end if;
    end process;

  rx_datavalid    <= buf_RX_CTRL(0);
  rx_reset        <= buf_RX_CTRL(1);

  next_rx_fifo_write_enable <= (buf_RX_CLK and not last_RX_CLK) and rx_datavalid and rx_active;
  next_rx_fifo_data_in      <= x"00" & '0' & '0' & buf_RX_DATA;

  reg_fifo_in : process(CLK)
    begin
      if rising_edge(CLK) then
        rx_fifo_write_enable <= next_rx_fifo_write_enable;
        rx_fifo_data_in      <= next_rx_fifo_data_in;
      end if;
    end process;

  RX_FIFO : trb_net_fifo_16bit_bram_dualport
    port map(
      read_clock_in => CLK,
      write_clock_in => CLK,
      read_enable_in => rx_fifo_read_enable,
      write_enable_in => rx_fifo_write_enable,
      fifo_gsr_in => rx_fifo_reset,
      write_data_in => rx_fifo_data_in,
      read_data_out => rx_fifo_data_out,
      full_out => open,
      empty_out => rx_fifo_empty,
      fifostatus_out => open,
      valid_read_out => open,
      almost_empty_out => open,
      almost_full_out => open
      );

  rx_fifo_reset       <= med_reset or not rx_active;
  rx_fifo_read_enable <= INT_READ_IN;

  proc_rx_dataoutput : process(CLK)
    begin
      if rising_edge(CLK) then
        INT_DATA_OUT       <= saved_fifo_data_out(7 downto 0) & rx_fifo_data_out(7 downto 0);
        INT_PACKET_NUM_OUT <= rx_packet_counter(3 downto 1);
        INT_DATAREADY_OUT  <= buf_INT_DATAREADY_OUT;

        last_rx_fifo_read_enable <= rx_fifo_read_enable;
        last_rx_fifo_empty <= rx_fifo_empty;
      end if;
    end process;

  packet_counter_p : process(CLK)
    begin
      if rising_edge(CLK) then
        if med_reset = '1' then
          rx_packet_counter <= "0111";
        elsif rx_fifo_read_enable = '1' and rx_fifo_empty = '0' then
          if rx_packet_counter = c_max_word_number & '1' then
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
          saved_fifo_data_out <= (others => '0');
        else
          buf_INT_DATAREADY_OUT <= rx_fifo_read_enable and not rx_fifo_empty and not rx_packet_counter(0);
          if last_rx_fifo_read_enable = '1' and last_rx_fifo_empty = '0' and rx_packet_counter(0) = '0' then
            saved_fifo_data_out <= rx_fifo_data_out(7 downto 0);
          end if;
        end if;
      end if;
    end process;


--monitor link
-------------------------


  ERROR_OUT_gen : process(CLK)
    begin
      if rising_edge(CLK) then
        if rx_clock_detect = '0' or rx_active = '0' then
          med_error <= ERROR_NC;
        else
          med_error <= ERROR_OK;
        end if;
      end if;
    end process;


  rx_clk_detect_counter: process (CLK)
    begin
      if rising_edge(CLK) then
        if med_reset = '1'  then
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

  proc_active : process(CLK)
    begin
      if rising_edge(CLK) then
        if rx_clock_detect = '0' then
          active_counter <= (others => '0');
        elsif active_counter < x"FFFF" then
          active_counter <= active_counter + 1;
        end if;
        if active_counter > x"8000" then
          rx_active <= '1';
        else
          rx_active <= '0';
        end if;
        if active_counter = x"FFFF" then
          tx_active <= '1';
        else
          tx_active <= '0';
        end if;
      end if;
    end process;

--STAT & CTRL Ports
-------------------------

--LED
  link_led <= rx_clock_detect and rx_active and tx_active;

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
  STAT_OP(13) <= '0'; --trbnet_reset;
  STAT_OP(14) <= not rx_clock_detect;
  STAT_OP(15) <= not rx_active;


  STAT(7 downto 0) <= buf_RX_DATA;
  STAT(9 downto 8) <= buf_RX_CTRL;
  STAT(10)         <= buf_RX_CLK;
  STAT(11)         <= '0';
  STAT(12)         <= rx_fifo_empty;
  STAT(13)         <= rx_fifo_read_enable;
  STAT(14)         <= rx_fifo_write_enable;
  STAT(15)         <= rx_clock_detect;
  STAT(23 downto 16) <= tx_data;
  STAT(24)         <= tx_datavalid;
  STAT(31 downto 25)    <= (others => '0');



end architecture;