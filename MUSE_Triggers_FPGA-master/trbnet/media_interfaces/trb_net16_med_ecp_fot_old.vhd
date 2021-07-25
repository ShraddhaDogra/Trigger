LIBRARY ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net16_med_ecp_fot is
  port(
    CLK    : in std_logic;
    CLK_25 : in std_logic;
    CLK_EN : in std_logic;
    RESET  : in std_logic;
    CLEAR  : in std_logic;

    --Internal Connection
    MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
    MED_DATAREADY_IN   : in  std_logic;
    MED_READ_OUT       : out std_logic;
    MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
    MED_DATAREADY_OUT  : out std_logic;
    MED_READ_IN        : in  std_logic;

    --SFP Connection
    TXP : out std_logic;
    TXN : out std_logic;
    RXP : in  std_logic;
    RXN : in  std_logic;
    SD  : in  std_logic;

    -- Status and control port
    STAT_OP            : out  std_logic_vector (15 downto 0);
    CTRL_OP            : in  std_logic_vector (15 downto 0);
    STAT_DEBUG         : out  std_logic_vector (63 downto 0);
    CTRL_DEBUG         : in  std_logic_vector (15 downto 0)
    );
end entity;

architecture trb_net16_med_ecp_fot_arch of trb_net16_med_ecp_fot is

-- Placer Directives
attribute HGROUP : string;
-- for whole architecture
attribute HGROUP of trb_net16_med_ecp_fot_arch : architecture  is "GROUP_PCS";

  component serdes_fot_0 is
    generic (
      USER_CONFIG_FILE    :  String := "serdes_fot_0.txt"
      );
    port (
      core_txrefclk : in std_logic;
      core_rxrefclk : in std_logic;
      hdinp0 : in std_logic;
      hdinn0 : in std_logic;
      hdoutp0 : out std_logic;
      hdoutn0 : out std_logic;
      ff_rxiclk_ch0 : in std_logic;
      ff_txiclk_ch0 : in std_logic;
      ff_ebrd_clk_0 : in std_logic;
      ff_txdata_ch0 : in std_logic_vector (7 downto 0);
      ff_rxdata_ch0 : out std_logic_vector (7 downto 0);
      ff_tx_k_cntrl_ch0 : in std_logic;
      ff_rx_k_cntrl_ch0 : out std_logic;
      ff_rxfullclk_ch0 : out std_logic;
      ff_force_disp_ch0 : in std_logic;
      ff_disp_sel_ch0 : in std_logic;
      ff_correct_disp_ch0 : in std_logic;
      ff_disp_err_ch0, ff_cv_ch0 : out std_logic;
      ffc_rrst_ch0 : in std_logic;
      ffc_lane_tx_rst_ch0 : in std_logic;
      ffc_lane_rx_rst_ch0 : in std_logic;
      ffc_txpwdnb_ch0 : in std_logic;
      ffc_rxpwdnb_ch0 : in std_logic;
      ffs_rlos_lo_ch0 : out std_logic;
      ffs_ls_sync_status_ch0 : out std_logic;
      ffs_cc_underrun_ch0 : out std_logic;
      ffs_cc_overrun_ch0 : out std_logic;
      ffs_txfbfifo_error_ch0 : out std_logic;
      ffs_rxfbfifo_error_ch0 : out std_logic;
      ffs_rlol_ch0 : out std_logic;
      oob_out_ch0 : out std_logic;
      ffc_macro_rst : in std_logic;
      ffc_quad_rst : in std_logic;
      ffc_trst : in std_logic;
      ff_txfullclk : out std_logic;
      ff_txhalfclk : out std_logic;
      ffs_plol : out std_logic
      );
  end component;


--
--   component lattice_ecp2m_fifo_8x8_dualport
--     port (
--       Data: in  std_logic_vector(7 downto 0);
--       WrClock: in  std_logic;
--       RdClock: in  std_logic;
--       WrEn: in  std_logic;
--       RdEn: in  std_logic;
--       Reset: in  std_logic;
--       RPReset: in  std_logic;
--       Q: out  std_logic_vector(7 downto 0);
--       Empty: out  std_logic;
--       Full: out  std_logic
--       );
--   end component;
--
--   component lattice_ecp2m_fifo_16x8_dualport
--     port (
--       Data: in  std_logic_vector(15 downto 0);
--       WrClock: in  std_logic;
--       RdClock: in  std_logic;
--       WrEn: in  std_logic;
--       RdEn: in  std_logic;
--       Reset: in  std_logic;
--       RPReset: in  std_logic;
--       Q: out  std_logic_vector(15 downto 0);
--       Empty: out  std_logic;
--       Full: out  std_logic
--       );
--   end component;

  signal link_error : std_logic_vector(7 downto 0);
  signal link_error_q: std_logic_vector(7 downto 0);
  signal reg_link_error : std_logic_vector(7 downto 0);
  signal ffs_plol        : std_logic;
  signal link_ok         : std_logic;
  signal link_ok_q       : std_logic;
  signal tx_data         : std_logic_vector(8-1 downto 0);
  signal rx_data         : std_logic_vector(8-1 downto 0);
  signal ff_rxfullclk    : std_logic;
  signal ff_txfullclk    : std_logic;
  signal rx_k            : std_logic;
  signal tx_k            : std_logic;
  signal lane_rst        : std_logic;
  signal lane_rst_qtx    : std_logic;
  signal quad_rst        : std_logic;
  signal quad_rst_qtx    : std_logic;

  signal byte_waiting         : std_logic;
  signal byte_buffer          : std_logic_vector(8-1 downto 0);
  signal fifo_reset           : std_logic;
  signal tx_fifo_dout         : std_logic_vector(16-1 downto 0);
  signal tx_fifo_data_in      : std_logic_vector(16-1 downto 0);
  signal tx_fifo_read_en      : std_logic;
  signal tx_fifo_write_en     : std_logic;
  signal tx_fifo_empty        : std_logic;
  signal tx_fifo_full         : std_logic;

  signal tx_fifo_valid_read   : std_logic;
  signal tx_allow             : std_logic;
  signal tx_allow_del         : std_logic;
  signal tx_allow_qtx         : std_logic;

  signal rx_data_reg      : std_logic_vector(8-1 downto 0);
  signal buf_rx_data_reg  : std_logic_vector(8-1 downto 0);
  signal buf_rx_data      : std_logic_vector(8-1 downto 0);
  signal buf_rx_k         : std_logic;
  signal rx_fifo_write_en : std_logic;
  signal rx_fifo_read_en  : std_logic;
  signal rx_fifo_empty    : std_logic;
  signal rx_fifo_full     : std_logic;
  signal rx_fifo_dout     : std_logic_vector(8-1 downto 0);
  signal is_idle_word     : std_logic;
  signal rx_starting      : std_logic;
  signal rx_allow         : std_logic;
  signal rx_allow_del     : std_logic;
  signal rx_allow_qrx     : std_logic;
  signal sd_q             : std_logic;
  signal last_rx_fifo_read_en : std_logic;
  signal last_rx_fifo_empty   : std_logic;
  signal last_last_rx_fifo_read_en : std_logic;
  signal last_last_rx_fifo_empty   : std_logic;
  signal last_rx_fifo_dout : std_logic_vector(7 downto 0);
  signal tx_fifo_valid_read_q : std_logic;

  signal buf_med_dataready_out  : std_logic;
  signal buf_med_read_out    : std_logic;
  signal buf_med_data_out    : std_logic_vector(16-1 downto 0);
  signal byte_select         : std_logic;
  signal rx_counter          : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal sfp_los             : std_logic;

  signal led_counter    : std_logic_vector(13 downto 0);
  signal rx_led        : std_logic;
  signal tx_led        : std_logic;

  signal FSM_STAT_OP    : std_logic_vector(16-1 downto 0);
  signal FSM_STAT_DEBUG : std_logic_vector(64-1 downto 0);
  signal FSM_CTRL_OP    : std_logic_vector(16-1 downto 0);

  signal send_reset_q       : std_logic;
  signal reset_word_cnt     : std_logic_vector(4 downto 0);
  signal send_reset_words   : std_logic;
  signal send_reset_words_q : std_logic;
  signal make_trbnet_reset  : std_logic;
  signal make_trbnet_reset_q: std_logic;

begin

  --ff_rxfullclk <= clk_25;
  --ff_rxfullclk <= ff_txfullclk;

  THE_SERDES: serdes_fot_0
    port map(
      core_txrefclk        => CLK_25,
      core_rxrefclk        => CLK_25,
      hdinp0               => RXP,
      hdinn0               => RXN,
      hdoutp0              => TXP,
      hdoutn0              => TXN,
      ff_rxiclk_ch0        => ff_rxfullclk,
      ff_txiclk_ch0        => ff_txfullclk,
      ff_ebrd_clk_0        => ff_rxfullclk,
      ff_txdata_ch0        => tx_data(7 downto 0),
      ff_rxdata_ch0        => rx_data(7 downto 0),
      ff_tx_k_cntrl_ch0    => tx_k,
      ff_rx_k_cntrl_ch0    => rx_k,
      ff_rxfullclk_ch0     => ff_rxfullclk,
      ff_force_disp_ch0    => '0',
      ff_disp_sel_ch0      => '0',
      ff_correct_disp_ch0  => '0',
      ff_disp_err_ch0      => link_error(0),
      ff_cv_ch0            => link_error(1),
      ffc_rrst_ch0         => '0',
      ffc_lane_tx_rst_ch0  => lane_rst_qtx, --lane_rst(0),
      ffc_lane_rx_rst_ch0  => lane_rst_qtx,
      ffc_txpwdnb_ch0      => '1',
      ffc_rxpwdnb_ch0      => '1',
      ffs_rlos_lo_ch0      => link_error(2),
      ffs_ls_sync_status_ch0 => link_ok,
      ffs_cc_underrun_ch0  => link_error(3),
      ffs_cc_overrun_ch0   => link_error(4),
      ffs_txfbfifo_error_ch0 => link_error(5),
      ffs_rxfbfifo_error_ch0 => link_error(6),
      ffs_rlol_ch0         => link_error(7),
      oob_out_ch0          => open,

      ffc_macro_rst        => '0',
      ffc_quad_rst         => quad_rst_qtx,
      ffc_trst             => '0',
      ff_txfullclk         => ff_txfullclk,
      ffs_plol             => ffs_plol
      );

--TX Control 25
---------------


    THE_TX_FIFO: trb_net_fifo_16bit_bram_dualport
      generic map(
        USE_STATUS_FLAGS => c_NO
        )
      port map(
        read_clock_in    => ff_txfullclk,
        write_clock_in  => CLK,
        read_enable_in  => tx_fifo_read_en,
        write_enable_in  => tx_fifo_write_en,
        fifo_gsr_in    => fifo_reset,
        write_data_in    => "00" & tx_fifo_data_in(15 downto 0),
        read_data_out(15 downto 0)    => tx_fifo_dout(15 downto 0),
        full_out      => tx_fifo_full,
        empty_out      => tx_fifo_empty
        );

--     THE_TX_FIFO: lattice_ecp2m_fifo_16x8_dualport
--       port map(
--         Data    => tx_fifo_data_in(16-1 downto 0),
--         WrClock => CLK,
--         RdClock => ff_txfullclk,
--         WrEn    => tx_fifo_write_en,
--         RdEn    => tx_fifo_read_en,
--         Reset   => fifo_reset,
--         RPReset => fifo_reset,
--         Q       => tx_fifo_dout(15 downto 0),
--         Empty   => tx_fifo_empty,
--         Full    => tx_fifo_full
--         );

    THE_READ_TX_FIFO_PROC: process( ff_txfullclk )
      begin
        if( rising_edge(ff_txfullclk) ) then
          if( reset = '1' ) then
            byte_waiting               <= '0';
            tx_fifo_read_en            <= '0';
            tx_k                       <= '1';
            tx_data(7 downto 0)        <= x"EE";
            tx_fifo_valid_read         <= '0';
          else
            tx_fifo_read_en      <= tx_allow_qtx;
            tx_fifo_valid_read   <= tx_fifo_read_en and not tx_fifo_empty;
            if( byte_waiting = '0' ) then
              if( (tx_fifo_valid_read = '1')) then
                byte_buffer(7 downto 0)        <= tx_fifo_dout(15 downto 8);
                byte_waiting                   <= '1';
                tx_k                           <= '0';
                tx_data(7 downto 0)            <= tx_fifo_dout(7 downto 0);
                tx_fifo_read_en                <= tx_allow_qtx;
              elsif send_reset_q = '1' then
                byte_buffer(7 downto 0)        <= x"FE";
                byte_waiting                   <= '1';
                tx_k                           <= '1';
                tx_data(7 downto 0)            <= x"FE";
                tx_fifo_read_en                <= '0';
              else
                byte_buffer(7 downto 0)        <= x"50";
                byte_waiting                   <= '1';
                tx_k                           <= '1';
                tx_data(7 downto 0)            <= x"BC";
                tx_fifo_read_en                <= tx_allow_qtx;
              end if;
            else --if byte_waiting = '1' then
              tx_data(7 downto 0)              <= byte_buffer(7 downto 0);
              tx_k                             <= '0';  --second byte is always data
              byte_waiting                     <= '0';
              tx_fifo_read_en                  <= '0';
            end if;
          end if;
        end if;
      end process;

    fifo_reset <= reset or quad_rst or not rx_allow;   --sync with SYSCLK

  --RX Control (25)
  ---------------------

    THE_FIFO_RX: trb_net_fifo_16bit_bram_dualport
      generic map(
        USE_STATUS_FLAGS => c_NO
        )
      port map(
        read_clock_in    => clk,
        write_clock_in  => ff_rxfullclk,
        read_enable_in  => rx_fifo_read_en,
        write_enable_in  => rx_fifo_write_en,
        fifo_gsr_in    => fifo_reset,
        write_data_in    => "00" & x"00" & rx_data_reg(7 downto 0),
        read_data_out(7 downto 0)    => rx_fifo_dout,
        full_out      => rx_fifo_full,
        empty_out      => rx_fifo_empty
        );


--     THE_RX_FIFO: lattice_ecp2m_fifo_8x8_dualport
--       port map(
--         Data    => rx_data_reg(7 downto 0),
--         WrClock => ff_rxfullclk,
--         RdClock => clk,
--         WrEn    => rx_fifo_write_en,
--         RdEn    => rx_fifo_read_en,
--         Reset   => fifo_reset,
--         RPReset => fifo_reset,
--         Q       => rx_fifo_dout(7 downto 0),
--         Empty   => rx_fifo_empty,
--         Full    => rx_fifo_full
--       );

    THE_WRITE_RX_FIFO_PROC: process( ff_rxfullclk )
      begin
        if( rising_edge(ff_rxfullclk) ) then
          buf_rx_data(7 downto 0) <= rx_data(7 downto 0);
          buf_rx_k <= rx_k;
          if( (reset = '1') or (rx_allow_qrx = '0') ) then
            rx_fifo_write_en <= '0';
            is_idle_word <= '1';
            rx_starting <= '1';
          else
            rx_data_reg(7 downto 0) <= buf_rx_data(7 downto 0);
            if( (buf_rx_k = '0') and (is_idle_word = '0') and (rx_starting = '0') ) then
              rx_fifo_write_en <= '1';
            else
              rx_fifo_write_en <= '0';
            end if;
            if   ( buf_rx_k = '1' ) then
              is_idle_word <= '1';
              rx_starting <= '0';
            elsif( (buf_rx_k = '0') and (is_idle_word = '1') ) then
              is_idle_word <= '0';
            end if;
          end if;
        end if;
      end process THE_WRITE_RX_FIFO_PROC;


    THE_CNT_RESET_PROC : process( ff_rxfullclk )
      begin
        if rising_edge(ff_rxfullclk) then
          if reset = '1' then
            send_reset_words  <= '0';
            make_trbnet_reset <= '0';
            reset_word_cnt(4 downto 0) <= (others => '0');
          else
            send_reset_words   <= '0';
            make_trbnet_reset  <= '0';
            if buf_rx_data(7 downto 0) = x"FE" and buf_rx_k = '1' then
              if reset_word_cnt(4) = '0' then
                reset_word_cnt(4 downto 0) <= reset_word_cnt(4 downto 0) + 1;
              else
                send_reset_words <= '1';
              end if;
            else
              reset_word_cnt(4 downto 0)    <= (others => '0');
              make_trbnet_reset <= reset_word_cnt(4);
            end if;
          end if;
        end if;
      end process;


--TX Control (100)
---------------------
    buf_med_read_out                  <= not tx_fifo_full and tx_allow_del;
    tx_fifo_write_en                  <= buf_med_read_out and med_dataready_in;
    tx_fifo_data_in(15 downto 0)      <= med_data_in(15 downto 0);
    med_read_out                      <= buf_med_read_out;

--RX Control (100)
---------------------
    process( clk )
      begin
        if( rising_edge(clk) ) then
          if( reset = '1' ) then
            buf_med_dataready_out <= '0';
            byte_select           <= '0';
            last_rx_fifo_read_en  <= '0';
          else
            last_rx_fifo_read_en  <= rx_fifo_read_en;
            last_rx_fifo_empty    <= rx_fifo_empty;
            last_last_rx_fifo_read_en  <= last_rx_fifo_read_en;
            last_last_rx_fifo_empty    <= last_rx_fifo_empty;
            last_rx_fifo_dout          <= rx_fifo_dout;
            buf_med_dataready_out <= '0';
            if( (last_last_rx_fifo_empty = '0') and (last_last_rx_fifo_read_en = '1') ) then
              if( byte_select = '1' ) then
                buf_MED_DATA_OUT(15 downto 0) <= last_rx_fifo_dout(7 downto 0)
                                                            & buf_MED_DATA_OUT(7 downto 0);
                buf_MED_DATAREADY_OUT <= '1';
              else
                buf_MED_DATA_OUT(15 downto 0)      <= x"00" & last_rx_fifo_dout(7 downto 0);
              end if;
              byte_select <= not byte_select;
            end if;
          end if;
        end if;
      end process;

    rx_fifo_read_en                  <= rx_allow_del and not rx_fifo_empty;
    MED_DATA_OUT(15 downto 0)        <= buf_MED_DATA_OUT(15 downto 0);
    MED_DATAREADY_OUT                <= buf_MED_DATAREADY_OUT;
    MED_PACKET_NUM_OUT               <= rx_counter;

--rx packet counter
---------------------
    THE_RX_PACKETS_PROC: process( clk )
      begin
        if( rising_edge(clk) ) then
          if( (reset = '1') or (rx_allow = '0') ) then
            rx_counter <= c_H0;
          else
            if( buf_med_dataready_out = '1' ) then
              if( rx_counter = c_max_word_number ) then
                rx_counter <= (others => '0');
              else
                rx_counter <= rx_counter + 1;
              end if;
            end if;
          end if;
        end if;
      end process;



--Link State machine
---------------------


    CLK_TO_TX_SYNC: signal_sync
      generic map(
        DEPTH => 2,
        WIDTH => 3
        )
      port map(
        RESET    => reset,
        D_IN(0)  => tx_allow,
        D_IN(1)  => lane_rst,
        D_IN(2)  => quad_rst,
        CLK0     => CLK,
        CLK1     => ff_txfullclk,
        D_OUT(0) => tx_allow_qtx,
        D_OUT(1) => lane_rst_qtx,
        D_OUT(2) => quad_rst_qtx
        );

    TX_TO_CLK_SYNC: signal_sync
      generic map(
        DEPTH => 2,
        WIDTH => 1
        )
      port map(
        RESET    => reset,
        D_IN(0)  => tx_fifo_valid_read,
        CLK0     => ff_txfullclk,
        CLK1     => CLK,
        D_OUT(0) => tx_fifo_valid_read_q
        );

    RX_TO_CLK_SYNC: signal_sync
      generic map(
        DEPTH => 2,
        WIDTH => 9
        )
      port map(
        RESET    => reset,
        D_IN(7 downto 0)  => link_error,
        D_IN(8)  => link_ok,
        CLK0     => ff_rxfullclk,
        CLK1     => CLK,
        D_OUT(7 downto 0) => link_error_q,
        D_OUT(8) => link_ok_q
        );

    SYNC_INPUT_TO_CLK : signal_sync
      generic map(
        DEPTH => 2,
        WIDTH => 3
        )
      port map(
        RESET    => reset,
        D_IN(0)  => sd,
        D_IN(1)  => tx_allow,
        D_IN(2)  => rx_allow,
        CLK0     => CLK,
        CLK1     => CLK,
        D_OUT(0) => sd_q,
        D_OUT(1) => tx_allow_del,
        D_OUT(2) => rx_allow_del
        );

    THE_SFP_STATUS_SYNC: signal_sync
      generic map(
        DEPTH => 2,
        WIDTH => 1
        )
      port map(
        RESET    => RESET,
        D_IN(0)  => rx_allow,
        CLK0     => CLK,
        CLK1     => ff_rxfullclk,
        D_OUT(0) => rx_allow_qrx
        );


    SYNC_RESET_DETECT_1 : signal_sync
      generic map(
        DEPTH => 2,
        WIDTH => 1
        )
      port map(
        RESET    => reset,
        D_IN(0)     => send_reset_words,
        CLK0     => CLK,
        CLK1     => CLK,
        D_OUT(0)    => send_reset_words_q
        );

    SYNC_RESET_DETECT_2 : signal_sync
      generic map(
        DEPTH => 2,
        WIDTH => 1
        )
      port map(
        RESET    => reset,
        D_IN(0)     => make_trbnet_reset,
        CLK0     => CLK,
        CLK1     => CLK,
        D_OUT(0)    => make_trbnet_reset_q
        );



--LED Signals
---------------------
    THE_TX_RX_LED_PROC: process( clk )
      begin
        if( rising_edge(CLK) ) then
          led_counter <= led_counter + 1;
          if   ( buf_med_dataready_out = '1' ) then
            rx_led <= '1';
          elsif( led_counter = 0 ) then
            rx_led <= '0';
          end if;
          if( tx_fifo_valid_read_q = '1') then
            tx_led <= '1';
          elsif led_counter = 0 then
            tx_led <= '0';
          end if;
        end if;
      end process;


-----------------------------------------------------------
--Link State Machine
-----------------------------------------------------------

    THE_SFP_LSM: trb_net16_lsm_sfp
      port map(
        SYSCLK            => CLK,
        RESET             => reset,
        CLEAR             => clear,
        SFP_MISSING_IN    => '0',
        SFP_LOS_IN        => sfp_los,
        SD_LINK_OK_IN     => link_ok_q,
        SD_LOS_IN         => link_error_q(2),
        SD_TXCLK_BAD_IN   => ffs_plol,
        SD_RXCLK_BAD_IN   => link_error_q(7),
        SD_RETRY_IN       => '0', -- '0' = handle byte swapping in logic, '1' = simply restart link and hope
        SD_ALIGNMENT_IN   => "10",
        SD_CV_IN(0)       => link_error_q(1),
        SD_CV_IN(1)       => '0',
        FULL_RESET_OUT    => quad_rst,
        LANE_RESET_OUT    => lane_rst,
        TX_ALLOW_OUT      => tx_allow,
        RX_ALLOW_OUT      => rx_allow,
        SWAP_BYTES_OUT    => open,
        STAT_OP           => FSM_STAT_OP(15 downto 0),
        CTRL_OP           => FSM_CTRL_OP(15 downto 0),
        STAT_DEBUG        => FSM_STAT_DEBUG(31 downto 0)
        );


  sfp_los <= not sd_q;
  FSM_CTRL_OP <= CTRL_OP;


-----------------------------------------------------------
--Debugging
-----------------------------------------------------------


    STAT_OP(9 downto 0)   <= FSM_STAT_OP(9 downto 0);
    STAT_OP(10) <= rx_led;
    STAT_OP(11) <= tx_led;
    STAT_OP(12) <= link_error(1) and not send_reset_words_q and tx_allow;
    STAT_OP(13) <= make_trbnet_reset_q;
    STAT_OP(14) <= FSM_STAT_OP(14);
    STAT_OP(15) <= send_reset_words_q;

    STAT_DEBUG(31 downto 0) <= FSM_STAT_DEBUG(31 downto 0);
    STAT_DEBUG(39 downto 32) <= buf_rx_data_reg(7 downto 0);
    STAT_DEBUG(40)           <= rx_fifo_write_en;
    STAT_DEBUG(48 downto 41) <= last_rx_fifo_dout;
    STAT_DEBUG(63 downto 49) <= (others => '0');

  PROC_LED : process(ff_rxfullclk)
    begin
      if rising_edge(ff_rxfullclk) then
        buf_rx_data_reg <= rx_data_reg;
      end if;
    end process;


end architecture;