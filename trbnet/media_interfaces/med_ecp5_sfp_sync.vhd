--Media interface for Lattice ECP5 using PCS at 2GHz


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.config.all;
use work.trb_net_components.all;
use work.med_sync_define.all;

entity med_ecp5_sfp_sync is
  generic(
    SERDES_NUM : integer range 0 to 3 := 0;
    IS_SYNC_SLAVE   : integer := c_YES       --select slave mode
    );
  port(
    CLK_REF_FULL       : in  std_logic; -- 200 MHz reference clock
    CLK_INTERNAL_FULL  : in  std_logic; -- internal 200 MHz, always on
    SYSCLK             : in  std_logic; -- 100 MHz main clock net, synchronous to RX clock
    RESET              : in  std_logic; -- synchronous reset
    CLEAR              : in  std_logic; -- asynchronous reset
    --Internal Connection TX
    MEDIA_MED2INT      : out MED2INT;
    MEDIA_INT2MED      : in  INT2MED;
    
    --Sync operation
    RX_DLM             : out std_logic := '0';
    RX_DLM_WORD        : out std_logic_vector(7 downto 0) := x"00";
    TX_DLM             : in  std_logic := '0';
    TX_DLM_WORD        : in  std_logic_vector(7 downto 0) := x"00";
    
    --SFP Connection
    SD_PRSNT_N_IN      : in  std_logic;  -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
    SD_LOS_IN          : in  std_logic;  -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
    SD_TXDIS_OUT       : out  std_logic := '0'; -- SFP disable
    --Control Interface
    BUS_RX             : in  CTRLBUS_RX;
    BUS_TX             : out CTRLBUS_TX;

    -- Status and control port
    STAT_DEBUG         : out std_logic_vector (63 downto 0);
    CTRL_DEBUG         : in  std_logic_vector (63 downto 0) := (others => '0')
   );
end entity;


architecture med_ecp5_sfp_sync_arch of med_ecp5_sfp_sync is

  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  attribute HGROUP of med_ecp5_sfp_sync_arch : architecture  is "media_interface_group";
  attribute syn_sharing : string;
  attribute syn_sharing of med_ecp5_sfp_sync_arch : architecture is "off";
  attribute syn_hier : string;
  attribute syn_hier of med_ecp5_sfp_sync_arch : architecture is "hard";

-- signal clk_200_i         : std_logic;
signal clk_200_ref       : std_logic;
signal clk_rx_full : std_logic;
signal clk_tx_full : std_logic;

signal tx_data           : std_logic_vector(7 downto 0);
signal tx_k              : std_logic;
signal rx_data           : std_logic_vector(7 downto 0);
signal rx_k              : std_logic;
signal rx_error          : std_logic;

signal rst_n             : std_logic;
signal rx_serdes_rst     : std_logic;
signal tx_serdes_rst     : std_logic;
signal tx_pcs_rst        : std_logic;
signal rx_pcs_rst        : std_logic;
signal rst_qd            : std_logic;
signal serdes_rst_qd     : std_logic;

signal rx_los_low        : std_logic;
signal lsm_status        : std_logic;
signal rx_cdr_lol        : std_logic;
signal tx_pll_lol        : std_logic;

signal sci_ch_i          : std_logic_vector(4 downto 0);
signal sci_addr_i        : std_logic_vector(5 downto 0);
signal sci_data_in_i     : std_logic_vector(7 downto 0);
signal sci_data_out_i    : std_logic_vector(7 downto 0);
signal sci_read_i        : std_logic;
signal sci_write_i       : std_logic;

signal wa_position        : std_logic_vector(15 downto 0) := x"FFFF";
signal wa_position_sel    : std_logic_vector(3 downto 0);

signal stat_rx_control_i  : std_logic_vector(31 downto 0);
signal stat_tx_control_i  : std_logic_vector(31 downto 0);
signal debug_rx_control_i : std_logic_vector(31 downto 0);
signal debug_tx_control_i : std_logic_vector(31 downto 0);
signal stat_fsm_reset_i   : std_logic_vector(31 downto 0);
signal debug_med_sync_control_i : std_logic_vector(31 downto 0);
signal rx_ready, tx_ready : std_logic;
signal  hdinp, hdinn, hdoutp, hdoutn : std_logic;
attribute nopad : string;
attribute nopad of  hdinp, hdinn, hdoutp, hdoutn : signal is "true";

signal stat_med : std_logic_vector(31 downto 0);

begin

clk_200_ref <= CLK_REF_FULL;

SD_TXDIS_OUT <= not rx_ready when IS_SYNC_SLAVE = 1 else '0';   --slave only switches on when RX is ready
-- SD_TXDIS_OUT <= RESET;

-- gen_slave_clock : if IS_SYNC_SLAVE = c_YES generate
--   clk_200_i        <= clk_rx_full;
-- end generate;
-- 
-- gen_master_clock : if IS_SYNC_SLAVE = c_NO generate
--   clk_200_i        <= clk_200_internal;
-- end generate;


-------------------------------------------------      
-- Serdes
-------------------------------------------------      
gen_pcs0 : if SERDES_NUM = 0 generate
  THE_SERDES : entity work.pcs 
    port map(
      serdes_sync_0_hdinp            => hdinp,
      serdes_sync_0_hdinn            => hdinn,
      serdes_sync_0_hdoutp           => hdoutp,
      serdes_sync_0_hdoutn           => hdoutn,
      serdes_sync_0_rxrefclk         => CLK_INTERNAL_FULL,
      serdes_sync_0_rx_pclk          => clk_rx_full,
      serdes_sync_0_tx_pclk          => clk_tx_full,
      
      serdes_sync_0_txdata           => tx_data,
      serdes_sync_0_tx_k(0)          => tx_k,
      serdes_sync_0_tx_force_disp(0) => '0',
      serdes_sync_0_tx_disp_sel(0)   => '0',
      serdes_sync_0_rxdata           => rx_data,
      serdes_sync_0_rx_k(0)          => rx_k,
      serdes_sync_0_rx_disp_err(0)   => open,
      serdes_sync_0_rx_cv_err(0)     => rx_error,
      
      serdes_sync_0_tx_idle_c        => '0',
      serdes_sync_0_signal_detect_c  => '0', --?force enable 
      serdes_sync_0_rx_los_low_s     => rx_los_low,
      serdes_sync_0_lsm_status_s     => lsm_status,
      serdes_sync_0_rx_cdr_lol_s     => rx_cdr_lol,
      serdes_sync_0_rx_pcs_rst_c     => rx_pcs_rst,
      serdes_sync_0_tx_pcs_rst_c     => tx_pcs_rst,
      serdes_sync_0_rx_serdes_rst_c  => rx_serdes_rst,


      serdes_sync_0_sci_wrdata           => sci_data_in_i,
      serdes_sync_0_sci_rddata           => sci_data_out_i,
      serdes_sync_0_sci_addr             => sci_addr_i,
      serdes_sync_0_sci_en_dual          => sci_ch_i(4), --?
      serdes_sync_0_sci_sel_dual         => sci_ch_i(4),
      serdes_sync_0_sci_en               => sci_ch_i(0), --?
      serdes_sync_0_sci_sel              => sci_ch_i(0),
      serdes_sync_0_sci_rd               => sci_read_i,
      serdes_sync_0_sci_wrn              => sci_write_i,
      serdes_sync_0_sci_int              => open,
      
      serdes_sync_0_cyawstn              => '0', --?
      serdes_sync_0_rst_dual_c           => rst_qd,
      serdes_sync_0_serdes_rst_dual_c    => '0',
      serdes_sync_0_tx_pwrup_c           => '1',
      serdes_sync_0_rx_pwrup_c           => '1',      
      serdes_sync_0_serdes_pdb           => '1', 
      serdes_sync_0_tx_serdes_rst_c      => tx_serdes_rst,

      serdes_sync_0_pll_refclki          => CLK_REF_FULL,
--       sli_rst              => '0',
      serdes_sync_0_pll_lol              => tx_pll_lol,
      serdes_sync_0_rsl_disable          => '1',
      serdes_sync_0_rsl_rst              => '0', --CLEAR,
      serdes_sync_0_rsl_rx_rdy           => rx_ready,
      serdes_sync_0_rsl_tx_rdy           => tx_ready
      );
end generate;

    tx_serdes_rst <= '0'; --SD_LOS_IN; --no function
    serdes_rst_qd <= '0'; --included in rst_qd
    wa_position_sel <= x"0";
--     wa_position_sel <= wa_position(3 downto 0)   when SERDES_NUM = 0 
--                   else wa_position(15 downto 12) when SERDES_NUM = 3;
    
THE_MED_CONTROL : entity work.med_sync_control
  generic map(
    IS_SYNC_SLAVE => IS_SYNC_SLAVE,
    IS_TX_RESET   => 1
    )
  port map(
    CLK_SYS     => SYSCLK,
    CLK_RXI     => clk_rx_full, --clk_rx_full,
    CLK_RXHALF  => '0',
    CLK_TXI     => clk_tx_full, --clk_200_ref, --clk_200_internal, --clk_tx_full, JM150706
    CLK_REF     => CLK_INTERNAL_FULL,
    RESET       => RESET,
    CLEAR       => CLEAR,
    
    SFP_LOS     => SD_LOS_IN,
    TX_LOL      => tx_pll_lol,
    RX_CDR_LOL  => rx_cdr_lol,
    RX_LOS      => rx_los_low,
    WA_POSITION => wa_position_sel,
    
    RX_SERDES_RST => rx_serdes_rst,
    RX_PCS_RST    => rx_pcs_rst,
    QUAD_RST      => rst_qd,
    TX_PCS_RST    => tx_pcs_rst,

    MEDIA_MED2INT => MEDIA_MED2INT,
    MEDIA_INT2MED => MEDIA_INT2MED,
    
    TX_DATA       => tx_data,
    TX_K          => tx_k,
    RX_DATA       => rx_data,
    RX_K          => rx_k,
    
    TX_DLM_WORD   => TX_DLM_WORD,
    TX_DLM        => TX_DLM,
    RX_DLM_WORD   => RX_DLM_WORD,
    RX_DLM        => RX_DLM,
    
    SERDES_RX_READY_IN => rx_ready,
    SERDES_TX_READY_IN => tx_ready,
    
    STAT_TX_CONTROL  => stat_tx_control_i,
    STAT_RX_CONTROL  => stat_rx_control_i,
    DEBUG_TX_CONTROL => debug_tx_control_i,
    DEBUG_RX_CONTROL => debug_rx_control_i,
    STAT_RESET       => stat_fsm_reset_i,
    DEBUG_OUT        => debug_med_sync_control_i
    );

THE_SCI_READER : entity work.sci_reader
  port map(
    CLK        => SYSCLK,
    RESET      => RESET,
    
    --SCI
    SCI_WRDATA  => sci_data_in_i,
    SCI_RDDATA  => sci_data_out_i,
    SCI_ADDR    => sci_addr_i,
    SCI_SEL     => sci_ch_i,
    SCI_RD      => sci_read_i,
    SCI_WR      => sci_write_i,
    
    WA_POS_OUT  => wa_position,
    
    --Slowcontrol
    BUS_RX      => BUS_RX,
    BUS_TX      => BUS_TX,
    
    MEDIA_STATUS_REG_IN(31 downto 0)   => stat_rx_control_i,
    MEDIA_STATUS_REG_IN(63 downto 32)  => stat_tx_control_i,
    MEDIA_STATUS_REG_IN(95 downto 64)  => stat_fsm_reset_i,
    MEDIA_STATUS_REG_IN(127 downto 96) => stat_med,
    DEBUG_OUT   => open
    );

-- STAT_DEBUG(4 downto 0)   <= debug_rx_control_i(4 downto 0);
-- STAT_DEBUG(6 downto 5)   <= stat_fsm_reset_i(9 downto 8);
-- STAT_DEBUG(7)            <= '0';
-- STAT_DEBUG(15 downto 8)  <= stat_fsm_reset_i(7 downto 0);
-- STAT_DEBUG(15 downto 0) <= debug_tx_control_i(31 downto 16);
-- STAT_DEBUG(31 downto 0) <= debug_rx_control_i(31 downto 0);
 STAT_DEBUG(3 downto 0) <= debug_med_sync_control_i(3 downto 0);
 STAT_DEBUG(7 downto 4) <= rx_los_low & lsm_status & rx_cdr_lol & tx_pll_lol;
--  STAT_DEBUG(9)  <= CLK_REF_FULL;
--  STAT_DEBUG(10) <= clk_rx_full;
--  STAT_DEBUG(11) <= clk_tx_full;


stat_med(0) <= rst_qd; 
stat_med(1) <= rx_pcs_rst;
stat_med(2) <= tx_pcs_rst;
stat_med(3) <= rx_serdes_rst;
stat_med(4) <= tx_pll_lol;
stat_med(5) <= rx_cdr_lol;
stat_med(6) <= rx_los_low;
stat_med(7) <= rx_ready;
stat_med(8) <= tx_ready;
stat_med(9) <= lsm_status;
stat_med(31 downto 10) <= (others => '0');
 
 
end architecture;

