LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
LIBRARY unisim;
USE UNISIM.VComponents.all;
library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


entity trb_net16_med_tlk is
  port (
    RESET               : in  std_logic;
    CLK                 : in  std_logic;
    TLK_CLK             : in  std_logic;
    TLK_ENABLE          : out std_logic;
    TLK_LCKREFN         : out std_logic;
    TLK_LOOPEN          : out std_logic;
    TLK_PRBSEN          : out std_logic;
    TLK_RXD             : in  std_logic_vector(15 downto 0);
    TLK_RX_CLK          : in  std_logic;
    TLK_RX_DV           : in  std_logic;
    TLK_RX_ER           : in  std_logic;
    TLK_TXD             : out std_logic_vector(15 downto 0);
    TLK_TX_EN           : out std_logic;
    TLK_TX_ER           : out std_logic;
    SFP_LOS             : in  std_logic;
    SFP_TX_DIS          : out std_logic;
    MED_DATAREADY_IN    : in  std_logic;
    MED_READ_IN         : in  std_logic;
    MED_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    MED_DATAREADY_OUT   : out std_logic;
    MED_READ_OUT        : out std_logic;
    MED_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    STAT                : out std_logic_vector (63 downto 0);
    STAT_MONITOR        : out std_logic_vector ( 100 downto 0);
    STAT_OP             : out std_logic_vector (15 downto 0);
    CTRL_OP             : in  std_logic_vector (15 downto 0)
                        --connect STAT(0) to LED
    );
end trb_net16_med_tlk;

architecture trb_net16_med_tlk_arch of trb_net16_med_tlk is

  signal fifo_din_a   : std_logic_vector(17 downto 0);
  signal fifo_dout_a  : std_logic_vector(17 downto 0);
  signal fifo_wr_en_a : std_logic;
  signal fifo_rd_en_a : std_logic;
  signal fifo_empty_a : std_logic;
  signal fifo_full_a  : std_logic;
  signal fifo_din_m   : std_logic_vector(17 downto 0);
  signal fifo_dout_m  : std_logic_vector(17 downto 0);
  signal fifo_rd_en_m : std_logic;
  signal fifo_wr_en_m : std_logic;
  signal fifo_empty_m : std_logic;
  signal fifo_full_m  : std_logic;
  signal fifo_valid_read_m, fifo_valid_read_a : std_logic;
  signal fifo_almost_full_m, fifo_almost_full_a : std_logic;
  signal fifo_almost_empty_m, fifo_almost_empty_a : std_logic;


  signal fifo_reset    : std_logic;
  signal fifo_status_a : std_logic_vector(3 downto 0);
  signal fifo_status_m : std_logic_vector(3 downto 0);
  signal buf_MED_PACKET_NUM_OUT : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal buf_MED_READ_OUT : std_logic;
  signal buf_MED_DATAREADY_OUT : std_logic;
  signal rx_allow : std_logic;
  signal tx_allow  : std_logic;
  signal internal_reset  : std_logic;


  signal reg_RXD   : std_logic_vector(15 downto 0);
  signal reg_RX_DV : std_logic;
  signal reg_RX_ER : std_logic;
  signal reg_TXD   : std_logic_vector(15 downto 0);
  signal reg_TX_EN : std_logic;
  signal reg_TX_ER : std_logic;

  signal TLK_CLK_neg : std_logic;
  signal CLK_FB_Out, FB_CLK : std_logic;

  type tlk_state_t is (RESETTING, WAIT_FOR_RX_LOCK, WAIT_FOR_TX_ALLOW, WORKING);
  signal current_state, next_state : tlk_state_t;
  signal next_tx_allow, next_rx_allow : std_logic:='1';
  signal counter, next_counter : std_logic_vector(28 downto 0);
  signal next_internal_reset : std_logic;
  signal buf_MED_ERROR_OUT, next_MED_ERROR_OUT : std_logic_vector(2 downto 0);
  signal state_bits : std_logic_vector(2 downto 0);
  signal counter_reset : std_logic;

  signal reg_SFP_LOS : std_logic;

  signal send_reset : std_logic;
  signal make_reset : std_logic;
  signal send_reset_counter : std_logic_vector(6 downto 0);
  signal send_reset_q : std_logic;
  signal make_reset_q : std_logic;
  signal sending_reset: std_logic;

  signal buf_RESET_TRBNET_OUT : std_logic;

  signal led_counter : std_logic_vector(18 downto 0);
  signal rx_led, tx_led, link_led : std_logic;

  signal comb_fifo_wr_en_a : std_logic;
  signal comb_fifo_din_a   : std_logic_vector(17 downto 0);

begin

  TLK_ENABLE  <= not RESET;
  TLK_LCKREFN <= '1';
  TLK_PRBSEN  <= '0';
  TLK_LOOPEN  <= '0';
  SFP_TX_DIS  <= RESET;




---------------------------------------------
--Receiver FIFO
---------------------------------------------

  FIFO_OPT_TO_MED: trb_net_fifo_16bit_bram_dualport
    generic map(
      USE_STATUS_FLAGS => c_NO
      )
    port map(
      read_clock_in   => CLK,
      write_clock_in  => TLK_RX_CLK,
      read_enable_in  => fifo_rd_en_a,
      write_enable_in => fifo_wr_en_a,
      fifo_gsr_in     => fifo_reset,
      write_data_in   => fifo_din_a,
      read_data_out   => fifo_dout_a,
      full_out        => fifo_full_a,
      empty_out       => fifo_empty_a,
      fifostatus_out  => fifo_status_a,
      valid_read_out  => fifo_valid_read_a,
      almost_empty_out=> fifo_almost_empty_a,
      almost_full_out => fifo_almost_full_a
      );

  fifo_rd_en_a <=   rx_allow;
  fifo_reset <= internal_reset;


  buf_MED_READ_OUT <= tx_allow;
  buf_MED_DATAREADY_OUT <= fifo_valid_read_a and fifo_dout_a(16) and not fifo_dout_a(17) and rx_allow;


  PROC_PACKET_COUNTER : process(CLK)
    begin
      if rising_edge(CLK) then
        if internal_reset = '1' or buf_RESET_TRBNET_OUT = '1' then
          buf_MED_PACKET_NUM_OUT <= c_H0;
        elsif buf_MED_DATAREADY_OUT = '1' then
          if buf_MED_PACKET_NUM_OUT = c_max_word_number then
            buf_MED_PACKET_NUM_OUT <= (others => '0');
          else
            buf_MED_PACKET_NUM_OUT <= buf_MED_PACKET_NUM_OUT + 1;
          end if;
        end if;
      end if;
    end process;

  REG_MED_OUTPUTS : process(CLK)
    begin
      if rising_edge(CLK) then
        MED_PACKET_NUM_OUT <= buf_MED_PACKET_NUM_OUT;
        MED_DATAREADY_OUT  <= buf_MED_DATAREADY_OUT;
        MED_DATA_OUT       <= fifo_dout_a(15 downto 0);
        MED_READ_OUT       <= buf_MED_READ_OUT;
      end if;
    end process;



  REG_RX_FIFO_INPUTS : process(TLK_RX_CLK)
    begin
      if rising_edge(TLK_RX_CLK) then
        fifo_wr_en_a <= (reg_RX_DV and not reg_RX_ER) and rx_allow;
        fifo_din_a   <= reg_RX_ER & reg_RX_DV & reg_RXD;
      end if;
    end process;

  SYNC_TLK_RX_INPUT : process(TLK_RX_CLK)
    begin
      if rising_edge(TLK_RX_CLK) then
        reg_RXD   <= TLK_RXD;
        reg_RX_DV <= TLK_RX_DV;
        reg_RX_ER <= TLK_RX_ER;
      end if;
    end process;



---------------------------------------------
--Detect Reset (Error Propagation)
---------------------------------------------


  process(TLK_RX_CLK)
    begin
      if rising_edge(TLK_RX_CLK) then
        if RESET = '1' then
          send_reset_counter <= (others => '0');
          send_reset         <= '0';
          make_reset         <= '0';
        else
          if reg_RX_DV = '1' and reg_RX_ER = '1' and send_reset_counter(5) = '0' then
            send_reset_counter <= send_reset_counter + 1;
          elsif  reg_RX_ER = '0' then
            send_reset_counter <= (others => '0');
          end if;
          if send_reset = '1' and reg_RX_ER = '0' then  --do reset
            make_reset <= '1';
            send_reset <= '0';
          elsif send_reset_counter(5) = '1' and reg_RX_ER = '1' then  --send reset
            send_reset <= '1';
            make_reset <= '0';
          else
            send_reset <= '0';
            make_reset <= '0';
          end if;
        end if;
      end if;
    end process;

  SYNC_SEND_RESET : signal_sync
    generic map(
      WIDTH => 2,
      DEPTH => 2
      )
    port map(
      RESET  => RESET,
      CLK0   => CLK,
      CLK1   => CLK,
      D_IN(0)  => send_reset,
      D_IN(1)  => make_reset,
      D_OUT(0) => send_reset_q,
      D_OUT(1) => make_reset_q
      );

  SYNC_SENDING_RESET : signal_sync
    generic map(
      WIDTH => 1,
      DEPTH => 2
      )
    port map(
      RESET  => RESET,
      CLK0   => TLK_CLK_neg,
      CLK1   => TLK_CLK_neg,
      D_IN(0)  => CTRL_OP(15),
      D_OUT(0) => sending_reset
      );


  SYNC_SFP_LOS : signal_sync
    generic map(
      WIDTH => 1,
      DEPTH => 2
      )
    port map(
      RESET  => RESET,
      CLK0   => CLK,
      CLK1   => CLK,
      D_IN(0)  => SFP_LOS,
      D_OUT(0) => reg_SFP_LOS
      );

---------------------------------------------
--A DCM - not really used
---------------------------------------------

U_DCM_Transmitter: DCM --no_sim--
  generic map(         --no_sim--
      CLKIN_PERIOD => 10.00, -- 30.30ns--no_sim--
      STARTUP_WAIT => FALSE,--no_sim--
      PHASE_SHIFT => 0,--no_sim--
      DESKEW_ADJUST => "SOURCE_SYNCHRONOUS",--no_sim--
      CLKOUT_PHASE_SHIFT => "FIXED"--no_sim--
      )--no_sim--
  port map (--no_sim--
      CLKIN =>    TLK_CLK,--no_sim--
      CLKFB =>    FB_CLK,--no_sim--
      DSSEN =>    '0',--no_sim--
      PSINCDEC => '0',--no_sim--
      PSEN =>     '0',--no_sim--
      PSCLK =>    '0',--no_sim--
      RST =>      RESET,--no_sim--
      CLK0 =>     CLK_FB_Out, -- for feedback--no_sim--
      CLK90=>    open,--no_sim--
      LOCKED =>   open--no_sim--
     );--no_sim--
--
U0_BUFG: BUFG  port map (I => CLK_FB_Out, O => TLK_CLK_neg);--no_sim--
U1_BUFG: BUFG  port map (I => CLK_FB_Out, O => FB_CLK);--no_sim--
--sim--TLK_CLK_neg <= not TLK_CLK;



---------------------------------------------
--TX FIFO
---------------------------------------------

  FIFO_MED_TO_OPT: trb_net_fifo_16bit_bram_dualport
    generic map(
      USE_STATUS_FLAGS => c_NO
      )
    port map(
      read_clock_in   => TLK_CLK_neg,
      write_clock_in  => CLK,
      read_enable_in  => fifo_rd_en_m,
      write_enable_in => fifo_wr_en_m,
      fifo_gsr_in     => fifo_reset,
      write_data_in   => fifo_din_m,
      read_data_out   => fifo_dout_m,
      valid_read_out  => fifo_valid_read_m,
      full_out        => fifo_full_m,
      empty_out       => fifo_empty_m,
      fifostatus_out  => fifo_status_m,
      almost_empty_out=> fifo_almost_empty_m,
      almost_full_out => fifo_almost_full_m
      );



  REG_TLK_TX_OUT : process(TLK_CLK_neg)
    begin
      if rising_edge(TLK_CLK_neg) then
        TLK_TX_EN   <= reg_TX_EN;
        TLK_TX_ER   <= reg_TX_ER;
        TLK_TXD     <= reg_TXD;
      end if;
    end process;

  REG_TLK_TX_buffers : process(TLK_CLK_neg)
    begin
      if rising_edge(TLK_CLK_neg) then
        reg_TXD   <= fifo_dout_m(15 downto 0);
        reg_TX_ER <= sending_reset;
        reg_TX_EN <= (fifo_valid_read_m and fifo_dout_m(16)) or sending_reset;
      end if;
    end process;

  PROC_TX_FIFO_INPUT : process(CLK)
    begin
      if rising_edge(CLK) then
        fifo_wr_en_m  <= (MED_DATAREADY_IN and buf_MED_READ_OUT);
        fifo_din_m    <= MED_PACKET_NUM_IN(2) & (MED_DATAREADY_IN and buf_MED_READ_OUT) & MED_DATA_IN;
      end if;
    end process;

  fifo_rd_en_m <= tx_allow;





---------------------------------------------
--Link State Machine
---------------------------------------------

  medium_states : process(current_state, tx_allow, rx_allow, internal_reset, MED_READ_IN,
                          reg_RX_ER, reg_RX_DV, buf_MED_ERROR_OUT, counter, make_reset_q)
    begin
      next_state <= current_state;
      next_tx_allow   <= tx_allow;
      next_rx_allow   <= rx_allow;
      next_internal_reset <= internal_reset;
      next_counter <= counter + 1;
      counter_reset <= reg_RX_ER and not reg_RX_DV;
      next_MED_ERROR_OUT <= buf_MED_ERROR_OUT;

      case current_state is
        when RESETTING =>
          next_MED_ERROR_OUT <= ERROR_NC;
          next_internal_reset <= '1';
          next_rx_allow <= '0';
          next_tx_allow <= '0';
          counter_reset <= '0';
          if counter(16) = '1' then
            counter_reset <= '1';
            next_state <= WAIT_FOR_RX_LOCK;
            next_internal_reset <= '0';
          end if;
        when WAIT_FOR_RX_LOCK =>
          next_internal_reset <= '0';
          if counter(28) = '1' then
            counter_reset <= '1';
            next_rx_allow <= '1';
            next_state <= WAIT_FOR_TX_ALLOW;
          end if;
        when WAIT_FOR_TX_ALLOW =>
          next_MED_ERROR_OUT <= ERROR_WAIT;
          next_internal_reset <= '0';
          if counter(28) = '1' then
            next_tx_allow <= '1';
            next_state <= WORKING;
          end if;
        when WORKING =>
          next_MED_ERROR_OUT <= ERROR_OK;
          next_tx_allow <= '1';
          next_rx_allow <= '1';
          next_internal_reset <= '0';
      end case;
      if reg_RX_ER = '1' and reg_RX_DV = '0' and internal_reset = '0' then
        next_rx_allow <= '0';
        next_tx_allow <= '0';
        next_state <= WAIT_FOR_RX_LOCK;
        next_MED_ERROR_OUT <= ERROR_WAIT;
      end if;
      if MED_READ_IN = '0' then
        next_MED_ERROR_OUT <= ERROR_NC;
      end if;
      if make_reset_q = '1' or reg_SFP_LOS = '1' then
        next_state <= RESETTING;
        next_MED_ERROR_OUT <= ERROR_NC;
        counter_reset <= '1';
      end if;
    end process;

  process(current_state)
    begin
      case current_state is
        when RESETTING         => state_bits <= "000";
        when WAIT_FOR_RX_LOCK  => state_bits <= "001";
        when WAIT_FOR_TX_ALLOW     => state_bits <= "011";
        when WORKING   => state_bits <= "100";
        when others       => state_bits <= "111";
      end case;
    end process;



  states_reg : process(CLK)
    begin
      if rising_edge(CLK) then
        tx_allow <= next_tx_allow;
        rx_allow <= next_rx_allow;
      end if;
    end process;

  states_reg_counter : process(CLK)
    begin
      if rising_edge(CLK) then
        if counter_reset = '1' then
          counter <= (others => '0');
        else
          counter <= next_counter;
        end if;
      end if;
    end process;

  states_reg_2 : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_state <= RESETTING;--no_sim--
--sim--   current_state <= WORKING;
          internal_reset <= '1';
          buf_MED_ERROR_OUT <= ERROR_NC;
        else
          current_state <= next_state;
          internal_reset <= next_internal_reset;
          buf_MED_ERROR_OUT <= next_MED_ERROR_OUT;
        end if;
      end if;
    end process;





---------------------------------------------
--STAT_OP & LED
---------------------------------------------
  process(CLK)
    begin
      if rising_edge(CLK) then
        if led_counter(18) = '1' then
          led_counter <= (others => '0');
        else
          led_counter <= led_counter + 1;
        end if;
        if buf_med_dataready_out = '1' then
          rx_led <= '1';
        elsif led_counter(18) = '1' then
          rx_led <= '0';
        end if;

        if MED_DATAREADY_IN = '1' then
          tx_led <= '1';
        elsif led_counter(18) = '1' then
          tx_led <= '0';
        end if;

      end if;
    end process;

  link_led <= (counter(24) or tx_allow) and not reg_sfp_los;

  stat_op(2 downto 0)  <= buf_MED_ERROR_OUT;
  stat_op(8 downto 3)  <= (others => '0'); -- unused
  stat_op(9)           <= link_led;
  stat_op(10)          <= rx_led; --rx led
  stat_op(11)          <= tx_led; --tx led
  stat_op(12)          <= '0'; -- unused
  stat_op(13)          <= make_reset_q;
  stat_op(14)          <= reg_SFP_LOS or make_reset_q; -- reset out
  stat_op(15)          <= send_reset_q; -- protocol error

---------------------------------------------
--Debugging
---------------------------------------------


  STAT(0) <= counter(24) or tx_allow;
  STAT(1) <= rx_allow;
  STAT(2) <= tx_allow;
  STAT(3) <= fifo_wr_en_a;
  STAT(4) <= fifo_rd_en_a;
  STAT(5) <= fifo_empty_a;
  STAT(6) <= fifo_rd_en_m;
  STAT(7) <= fifo_empty_m;
  STAT(8) <= fifo_full_a;
  STAT(9) <= fifo_full_m;
  STAT(10)<= fifo_dout_m(14);
  STAT(11)<= fifo_dout_a(14);
  STAT(12)<= fifo_din_a(14);
--  STAT(11)<= last_fifo_rd_en_a;
  STAT(13) <= internal_reset;
  STAT(14) <= reg_RX_DV;
  STAT(15) <= reg_RX_ER;
  STAT(31 downto 16) <= reg_RXD;
  STAT(32) <= fifo_valid_read_m;
  STAT(33) <= fifo_valid_read_a;
  STAT(36 downto 34) <= state_bits;
  STAT(40 downto 37) <= fifo_status_a;
  STAT(44 downto 41) <= fifo_status_m;
  STAT(48 downto 45) <= fifo_dout_m(3 downto 0);
  STAT(50 downto 49) <= fifo_dout_m(17 downto 16);
  STAT(54 downto 51) <= fifo_din_a(3 downto 0);
  STAT(56 downto 55) <= fifo_din_a(17 downto 16);
  STAT(57) <= make_reset;
  STAT(58) <= send_reset;
  STAT(59) <= TLK_CLK_neg;
  STAT(60) <= fifo_wr_en_m;
  STAT(63 downto 61) <= send_reset_counter(2 downto 0);
  --STAT(63 downto 57) <= (others => '0');

  STAT_MONITOR(17 downto 0) <= fifo_din_a;
  STAT_MONITOR(18) <= fifo_almost_full_m;
  STAT_MONITOR(19) <= fifo_almost_full_a;
  STAT_MONITOR(20) <= fifo_almost_empty_m;
  STAT_MONITOR(21) <= fifo_almost_empty_a;
  STAT_MONITOR(37 downto 22) <= CTRL_OP;
  STAT_MONITOR(45 downto 38) <= (others => '0');
  STAT_MONITOR(46)           <= reg_TX_ER;
  STAT_MONITOR(47)           <=  reg_TX_EN;
  STAT_MONITOR(63 downto 48) <=  reg_TXD;
  STAT_MONITOR(81 downto 64) <= fifo_din_a;  -- RX_ER & RX_DV & RX_DATA
  STAT_MONITOR(88 downto 82)   <= send_reset_counter;
  STAT_MONITOR(100 downto 89) <= (others => '0');




end architecture;
