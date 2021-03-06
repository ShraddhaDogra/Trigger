library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- synopsys translate_off
library ecp3;
   use ecp3.components.all;
-- synopsys translate_on   
library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb3_components.all;
use work.trb_net16_hub_func.all;
use work.version.all;
use work.tdc_components.TDC;
use work.tdc_version.all;
use work.trb_net_gbe_components.all;

use work.cbmnet_interface_pkg.all;

use work.cts_pkg.all;

--Configuration is done in this file:   
use work.config.all;
-- The description of hub ports is also there!

--Slow Control
--    0 -    7  Readout endpoint common status
--   80 -   AF  Hub status registers
--   C0 -   CF  Hub control registers
-- 4000 - 40FF  Hub status registers
-- 7000 - 72FF  Readout endpoint registers
-- 8100 - 83FF  GbE configuration & status
-- A000 - A7FF  CTS configuration & status
-- A800 - A9ff  CBMNet
-- C000 - CFFF  TDC configuration & status
-- D000 - D13F  Flash Programming

entity trb3_central is
  port(
    --Clocks
    CLK_EXT        : in std_logic_vector(4 downto 3);  --from RJ45
    CLK_GPLL_LEFT  : in std_logic;  --Clock Manager 2/9, 200 MHz  <-- MAIN CLOCK
    CLK_GPLL_RIGHT : in std_logic;  --Clock Manager 1/9, 125 MHz  <-- for GbE
    CLK_PCLK_LEFT  : in std_logic;      --Clock Fan-out, 200/400 MHz 
    CLK_PCLK_RIGHT : in std_logic;      --Clock Fan-out, 200/400 MHz 

    --Trigger
    TRIGGER_LEFT  : in  std_logic;      --left side trigger input from fan-out
    TRIGGER_RIGHT : in  std_logic;      --right side trigger input from fan-out
    TRIGGER_EXT_2 : in  std_logic;
    TRIGGER_EXT_3 : inout std_logic;  --trigger input of busy output
--     TRIGGER_EXT   : inout  std_logic_vector(4 downto 2);  --additional trigger from RJ45
    TRIGGER_OUT   : out std_logic;      --trigger to second input of fan-out
    TRIGGER_OUT2  : out std_logic;
    CLK_TEST_OUT  : out std_logic_vector(1 downto 0); --CLK_EXT_3/4 as output
    
    --Serdes
    CLK_SERDES_INT_LEFT  : in std_logic;  --Clock Manager 2/0, 200 MHz, only in case of problems
    CLK_SERDES_INT_RIGHT : in std_logic;  --Clock Manager 1/0, off, 125 MHz possible

    --SFP
    SFP_RX_P     : in    std_logic_vector(9 downto 1);
    SFP_RX_N     : in    std_logic_vector(9 downto 1);
    SFP_TX_P     : out   std_logic_vector(9 downto 1);
    SFP_TX_N     : out   std_logic_vector(9 downto 1);
    SFP_TX_FAULT : in    std_logic_vector(8 downto 1);  --TX broken
    SFP_RATE_SEL : out   std_logic_vector(8 downto 1);  --not supported by our SFP
    SFP_LOS      : in    std_logic_vector(8 downto 1);  --Loss of signal
    SFP_MOD0     : in    std_logic_vector(8 downto 1);  --SFP present
    SFP_MOD1     : out   std_logic_vector(8 downto 1);  --I2C interface
    SFP_MOD2     : inout std_logic_vector(8 downto 1);  --I2C interface
    SFP_TXDIS    : out   std_logic_vector(8 downto 1);  --disable TX

    --Clock and Trigger Control
    TRIGGER_SELECT : out   std_logic;  --trigger select for fan-out. 0: external, 1: signal from FPGA5
    CLOCK_SELECT   : out   std_logic;  --clock select for fan-out. 0: 200MHz, 1: external from RJ45
    CLK_MNGR1_USER : inout std_logic_vector(3 downto 0);  --I/O lines to clock manager 1
    CLK_MNGR2_USER : inout std_logic_vector(3 downto 0);  --I/O lines to clock manager 1

    --Inter-FPGA Communication
    FPGA1_COMM : inout std_logic_vector(11 downto 0);
    FPGA2_COMM : inout std_logic_vector(11 downto 0);
    FPGA3_COMM : inout std_logic_vector(11 downto 0);
    FPGA4_COMM : inout std_logic_vector(11 downto 0);
    -- on all FPGAn_COMM:  --Bit 0/1 output, serial link TX active
    --Bit 2/3 input, serial link RX active
    --others yet undefined
    FPGA1_TTL  : inout std_logic_vector(3 downto 0);
    FPGA2_TTL  : inout std_logic_vector(3 downto 0);
    FPGA3_TTL  : inout std_logic_vector(3 downto 0);
    FPGA4_TTL  : inout std_logic_vector(3 downto 0);
    --only for not timing-sensitive signals

    --Communication to small addons
    FPGA1_CONNECTOR : inout std_logic_vector(7 downto 0);  --Bit 2-3: LED for SFP3/4
    FPGA2_CONNECTOR : inout std_logic_vector(7 downto 0);  --Bit 2-3: LED for SFP7/8
    FPGA3_CONNECTOR : inout std_logic_vector(7 downto 0);  --Bit 0-1: LED for SFP5/6 
    FPGA4_CONNECTOR : inout std_logic_vector(7 downto 0);  --Bit 0-1: LED for SFP1/2
                                                           --Bit 0-3 connected to LED by default, two on each side

    --AddOn connector
    ECL_IN  : in std_logic_vector(3 downto 0);
    NIM_IN  : in std_logic_vector(1 downto 0);
    JIN1    : in std_logic_vector(3 downto 0);
    JIN2    : in std_logic_vector(3 downto 0);
    JINLVDS : in std_logic_vector(15 downto 0);  --No LVDS, just TTL!

    DISCRIMINATOR_IN : in  std_logic_vector(1 downto 0);
    PWM_OUT          : out std_logic_vector(1 downto 0);

    JOUT1            : out   std_logic_vector(3 downto 0);
    JOUT2            : out   std_logic_vector(3 downto 0);
    JOUTLVDS         : out   std_logic_vector(7 downto 0);
    JTTL             : inout std_logic_vector(15 downto 0);
    TRG_FANOUT_ADDON : out   std_logic;

    LED_BANK       : out std_logic_vector(7 downto 0);
    LED_RJ_GREEN   : out std_logic_vector(5 downto 0);
    LED_RJ_RED     : out std_logic_vector(5 downto 0);
    LED_FAN_GREEN  : out std_logic;
    LED_FAN_ORANGE : out std_logic;
    LED_FAN_RED    : out std_logic;
    LED_FAN_YELLOW : out std_logic;

    --Flash ROM & Reboot
    FLASH_CLK  : out std_logic;
    FLASH_CS   : out std_logic;
    FLASH_DIN  : out std_logic;
    FLASH_DOUT : in  std_logic;
    PROGRAMN   : out std_logic := '1';  --reboot FPGA

    --Misc
    ENPIRION_CLOCK    : out   std_logic;  --Clock for power supply, not necessary, floating
    TEMPSENS          : inout std_logic;  --Temperature Sensor
    LED_CLOCK_GREEN   : out   std_logic;
    LED_CLOCK_RED     : out   std_logic;
    LED_GREEN         : out   std_logic;
    LED_ORANGE        : out   std_logic;
    LED_RED           : out   std_logic;
    LED_TRIGGER_GREEN : out   std_logic;
    LED_TRIGGER_RED   : out   std_logic;
    LED_YELLOW        : out   std_logic;

    --Test Connectors
    TEST_LINE : inout std_logic_vector(31 downto 0)
    );


  attribute syn_useioff                      : boolean;
  --no IO-FF for LEDs relaxes timing constraints
  attribute syn_useioff of LED_CLOCK_GREEN   : signal is false;
  attribute syn_useioff of LED_CLOCK_RED     : signal is false;
  attribute syn_useioff of LED_TRIGGER_GREEN : signal is false;
  attribute syn_useioff of LED_TRIGGER_RED   : signal is false;
  attribute syn_useioff of LED_GREEN         : signal is false;
  attribute syn_useioff of LED_ORANGE        : signal is false;
  attribute syn_useioff of LED_RED           : signal is false;
  attribute syn_useioff of LED_YELLOW        : signal is false;
  attribute syn_useioff of LED_FAN_GREEN     : signal is false;
  attribute syn_useioff of LED_FAN_ORANGE    : signal is false;
  attribute syn_useioff of LED_FAN_RED       : signal is false;
  attribute syn_useioff of LED_FAN_YELLOW    : signal is false;
  attribute syn_useioff of LED_BANK          : signal is false;
  attribute syn_useioff of LED_RJ_GREEN      : signal is false;
  attribute syn_useioff of LED_RJ_RED        : signal is false;
  attribute syn_useioff of FPGA1_TTL         : signal is false;
  attribute syn_useioff of FPGA2_TTL         : signal is false;
  attribute syn_useioff of FPGA3_TTL         : signal is false;
  attribute syn_useioff of FPGA4_TTL         : signal is false;
  attribute syn_useioff of SFP_TXDIS         : signal is false;
  attribute syn_useioff of PROGRAMN          : signal is false;

  --important signals _with_ IO-FF
  attribute syn_useioff of FLASH_CLK      : signal is true;
  attribute syn_useioff of FLASH_CS       : signal is true;
  attribute syn_useioff of FLASH_DIN      : signal is true;
  attribute syn_useioff of FLASH_DOUT     : signal is true;
  attribute syn_useioff of FPGA1_COMM     : signal is true;
  attribute syn_useioff of FPGA2_COMM     : signal is true;
  attribute syn_useioff of FPGA3_COMM     : signal is true;
  attribute syn_useioff of FPGA4_COMM     : signal is true;
  attribute syn_useioff of CLK_MNGR1_USER : signal is false;
  attribute syn_useioff of CLK_MNGR2_USER : signal is false;
  attribute syn_useioff of TRIGGER_SELECT : signal is false;
  attribute syn_useioff of CLOCK_SELECT   : signal is false;

  attribute syn_useioff of CLK_EXT : signal is false;

  -- no FF for CTS addon ... relax timing
  attribute syn_useioff of ECL_IN           : signal is false;
  attribute syn_useioff of NIM_IN           : signal is false;
  attribute syn_useioff of JIN1             : signal is false;
  attribute syn_useioff of JIN2             : signal is false;
  attribute syn_useioff of JINLVDS          : signal is false;
  attribute syn_useioff of DISCRIMINATOR_IN : signal is false;
  attribute syn_useioff of PWM_OUT          : signal is false;
  attribute syn_useioff of JOUT1            : signal is false;
  attribute syn_useioff of JOUT2            : signal is false;
  attribute syn_useioff of JOUTLVDS         : signal is false;
  attribute syn_useioff of JTTL             : signal is false;
  attribute syn_useioff of TRG_FANOUT_ADDON : signal is false;
  attribute syn_useioff of LED_BANK         : signal is false;
  attribute syn_useioff of LED_RJ_GREEN     : signal is false;
  attribute syn_useioff of LED_RJ_RED       : signal is false;
  attribute syn_useioff of LED_FAN_GREEN    : signal is false;
  attribute syn_useioff of LED_FAN_ORANGE   : signal is false;
  attribute syn_useioff of LED_FAN_RED      : signal is false;
  attribute syn_useioff of LED_FAN_YELLOW   : signal is false;

  attribute syn_keep                         : boolean;
  attribute syn_keep of CLK_EXT              : signal is true;
  attribute syn_keep of CLK_GPLL_LEFT        : signal is true;
  attribute syn_keep of CLK_GPLL_RIGHT       : signal is true;
  attribute syn_keep of CLK_PCLK_LEFT        : signal is true;
  attribute syn_keep of CLK_PCLK_RIGHT       : signal is true;
  attribute syn_keep of TRIGGER_LEFT         : signal is true;
  attribute syn_keep of TRIGGER_RIGHT        : signal is true;
  attribute syn_keep of TRIGGER_OUT          : signal is true;
  attribute syn_keep of TRIGGER_OUT2         : signal is true;
  attribute syn_keep of CLK_SERDES_INT_LEFT  : signal is true;
  attribute syn_keep of CLK_SERDES_INT_RIGHT : signal is true;
  attribute syn_keep of SFP_RX_P             : signal is true;
  attribute syn_keep of SFP_RX_N             : signal is true;
  attribute syn_keep of SFP_TX_P             : signal is true;
  attribute syn_keep of SFP_TX_N             : signal is true;
  attribute syn_keep of SFP_TX_FAULT         : signal is true;
  attribute syn_keep of SFP_RATE_SEL         : signal is true;
  attribute syn_keep of SFP_LOS              : signal is true;
  attribute syn_keep of SFP_MOD0             : signal is true;
  attribute syn_keep of SFP_MOD1             : signal is true;
  attribute syn_keep of SFP_MOD2             : signal is true;
  attribute syn_keep of SFP_TXDIS            : signal is true;
  attribute syn_keep of TRIGGER_SELECT       : signal is true;
  attribute syn_keep of CLOCK_SELECT         : signal is true;
  attribute syn_keep of CLK_MNGR1_USER       : signal is true;
  attribute syn_keep of CLK_MNGR2_USER       : signal is true;
  attribute syn_keep of FPGA1_COMM           : signal is true;
  attribute syn_keep of FPGA2_COMM           : signal is true;
  attribute syn_keep of FPGA3_COMM           : signal is true;
  attribute syn_keep of FPGA4_COMM           : signal is true;
  attribute syn_keep of FPGA1_TTL            : signal is true;
  attribute syn_keep of FPGA2_TTL            : signal is true;
  attribute syn_keep of FPGA3_TTL            : signal is true;
  attribute syn_keep of FPGA4_TTL            : signal is true;
  attribute syn_keep of FPGA1_CONNECTOR      : signal is true;
  attribute syn_keep of FPGA2_CONNECTOR      : signal is true;
  attribute syn_keep of FPGA3_CONNECTOR      : signal is true;
  attribute syn_keep of FPGA4_CONNECTOR      : signal is true;
  attribute syn_keep of ECL_IN               : signal is true;
  attribute syn_keep of NIM_IN               : signal is true;
  attribute syn_keep of JIN1                 : signal is true;
  attribute syn_keep of JIN2                 : signal is true;
  attribute syn_keep of JINLVDS              : signal is true;
  attribute syn_keep of DISCRIMINATOR_IN     : signal is true;
  attribute syn_keep of PWM_OUT              : signal is true;
  attribute syn_keep of JOUT1                : signal is true;
  attribute syn_keep of JOUT2                : signal is true;
  attribute syn_keep of JOUTLVDS             : signal is true;
  attribute syn_keep of JTTL                 : signal is true;
  attribute syn_keep of TRG_FANOUT_ADDON     : signal is true;
  attribute syn_keep of LED_BANK             : signal is true;
  attribute syn_keep of LED_RJ_GREEN         : signal is true;
  attribute syn_keep of LED_RJ_RED           : signal is true;
  attribute syn_keep of LED_FAN_GREEN        : signal is true;
  attribute syn_keep of LED_FAN_ORANGE       : signal is true;
  attribute syn_keep of LED_FAN_RED          : signal is true;
  attribute syn_keep of LED_FAN_YELLOW       : signal is true;
  attribute syn_keep of FLASH_CLK            : signal is true;
  attribute syn_keep of FLASH_CS             : signal is true;
  attribute syn_keep of FLASH_DIN            : signal is true;
  attribute syn_keep of FLASH_DOUT           : signal is true;
  attribute syn_keep of PROGRAMN             : signal is true;
  attribute syn_keep of ENPIRION_CLOCK       : signal is true;
  attribute syn_keep of TEMPSENS             : signal is true;
  attribute syn_keep of LED_CLOCK_GREEN      : signal is true;
  attribute syn_keep of LED_CLOCK_RED        : signal is true;
  attribute syn_keep of LED_GREEN            : signal is true;
  attribute syn_keep of LED_ORANGE           : signal is true;
  attribute syn_keep of LED_RED              : signal is true;
  attribute syn_keep of LED_TRIGGER_GREEN    : signal is true;
  attribute syn_keep of LED_TRIGGER_RED      : signal is true;
  attribute syn_keep of LED_YELLOW           : signal is true;
  attribute syn_keep of TEST_LINE            : signal is true;
end entity;

architecture trb3_central_arch of trb3_central is
   attribute syn_keep : boolean;
   attribute syn_preserve : boolean;

   signal clk_100_i   : std_logic; --clock for main logic, 100 MHz, via Clock Manager and internal PLL
   signal clk_200_i   : std_logic; --clock for logic at 200 MHz, via Clock Manager and bypassed PLL
   signal clk_125_i   : std_logic; --125 MHz, via Clock Manager and bypassed PLL
   signal osc_int     : std_logic;  -- clock for calibrating the tdc, 2.5 MHz, via internal osscilator
   signal pll_lock    : std_logic; --Internal PLL locked. E.g. used to reset all internal logic.
   signal clear_i     : std_logic;
   signal reset_i     : std_logic;
   signal GSR_N       : std_logic;
   attribute syn_keep of GSR_N : signal is true;
   attribute syn_preserve of GSR_N : signal is true;

   --FPGA Test
   signal time_counter, time_counter2 : unsigned(31 downto 0);

   --Media Interface
   signal med_stat_op             : std_logic_vector (INTERFACE_NUM*16-1  downto 0);
   signal med_ctrl_op             : std_logic_vector (INTERFACE_NUM*16-1  downto 0);
   signal med_stat_debug          : std_logic_vector (INTERFACE_NUM*64-1  downto 0);
   signal med_ctrl_debug          : std_logic_vector (INTERFACE_NUM*64-1  downto 0);
   signal med_data_out            : std_logic_vector (INTERFACE_NUM*16-1  downto 0);
   signal med_packet_num_out      : std_logic_vector (INTERFACE_NUM*3-1   downto 0);
   signal med_dataready_out       : std_logic_vector (INTERFACE_NUM*1-1   downto 0);
   signal med_read_out            : std_logic_vector (INTERFACE_NUM*1-1   downto 0);
   signal med_data_in             : std_logic_vector (INTERFACE_NUM*16-1  downto 0);
   signal med_packet_num_in       : std_logic_vector (INTERFACE_NUM*3-1   downto 0);
   signal med_dataready_in        : std_logic_vector (INTERFACE_NUM*1-1   downto 0);
   signal med_read_in             : std_logic_vector (INTERFACE_NUM*1-1   downto 0);

   --Hub
   signal common_stat_regs        : std_logic_vector (std_COMSTATREG*32-1 downto 0);
   signal common_ctrl_regs        : std_logic_vector (std_COMCTRLREG*32-1 downto 0);
   signal my_address              : std_logic_vector (16-1 downto 0);
   signal regio_addr_out          : std_logic_vector (16-1 downto 0);
   signal regio_read_enable_out   : std_logic;
   signal regio_write_enable_out  : std_logic;
   signal regio_data_out          : std_logic_vector (32-1 downto 0);
   signal regio_data_in           : std_logic_vector (32-1 downto 0);
   signal regio_dataready_in      : std_logic;
   signal regio_no_more_data_in   : std_logic;
   signal regio_write_ack_in      : std_logic;
   signal regio_unknown_addr_in   : std_logic;
   signal regio_timeout_out       : std_logic;
   
   signal bus_debug_tx_in         : CTRLBUS_TX;
   signal bus_debug_rx_out        : CTRLBUS_RX;
   signal debug_active            : std_logic;
   signal handler_addr            : std_logic_vector(15 downto 0);
   signal handler_data_out        : std_logic_vector(31 downto 0);
   signal handler_read            : std_logic;
   signal handler_write           : std_logic;
   signal handler_timeout         : std_logic;


   signal spictrl_read_en         : std_logic;
   signal spictrl_write_en        : std_logic;
   signal spictrl_data_in         : std_logic_vector(31 downto 0);
   signal spictrl_addr            : std_logic;
   signal spictrl_data_out        : std_logic_vector(31 downto 0);
   signal spictrl_ack             : std_logic;
   signal spictrl_busy            : std_logic;
   signal spimem_read_en          : std_logic;
   signal spimem_write_en         : std_logic;
   signal spimem_data_in          : std_logic_vector(31 downto 0);
   signal spimem_addr             : std_logic_vector(5 downto 0);
   signal spimem_data_out         : std_logic_vector(31 downto 0);
   signal spimem_ack              : std_logic;

   signal spi_bram_addr           : std_logic_vector(7 downto 0);
   signal spi_bram_wr_d           : std_logic_vector(7 downto 0);
   signal spi_bram_rd_d           : std_logic_vector(7 downto 0);
   signal spi_bram_we             : std_logic;

   signal hub_cts_number                   : std_logic_vector(15 downto 0);
   signal hub_cts_code                     : std_logic_vector(7 downto 0);
   signal hub_cts_information              : std_logic_vector(7 downto 0);
   signal hub_cts_start_readout            : std_logic;
   signal hub_cts_readout_type             : std_logic_vector(3 downto 0);
   signal hub_cts_readout_finished         : std_logic;
   signal hub_cts_status_bits              : std_logic_vector(31 downto 0);
   signal hub_fee_data                     : std_logic_vector(15 downto 0);
   signal hub_fee_dataready                : std_logic;
   signal hub_fee_read                     : std_logic;
   signal hub_fee_status_bits              : std_logic_vector(31 downto 0);
   signal hub_fee_busy                     : std_logic;

   signal gbe_cts_number                   : std_logic_vector(15 downto 0);
   signal gbe_cts_code                     : std_logic_vector(7 downto 0);
   signal gbe_cts_information              : std_logic_vector(7 downto 0);
   signal gbe_cts_start_readout            : std_logic;
   signal gbe_cts_readout_type             : std_logic_vector(3 downto 0);
   signal gbe_cts_readout_finished         : std_logic;
   signal gbe_cts_status_bits              : std_logic_vector(31 downto 0);
   signal gbe_fee_data                     : std_logic_vector(15 downto 0);
   signal gbe_fee_dataready                : std_logic;
   signal gbe_fee_read                     : std_logic;
   signal gbe_fee_status_bits              : std_logic_vector(31 downto 0);
   signal gbe_fee_busy                     : std_logic;  

   signal stage_stat_regs              : std_logic_vector (31 downto 0);
   signal stage_ctrl_regs              : std_logic_vector (31 downto 0) := (others => '0');

   signal mb_stat_reg_data_wr          : std_logic_vector(31 downto 0);
   signal mb_stat_reg_data_rd          : std_logic_vector(31 downto 0);
   signal mb_stat_reg_read             : std_logic;
   signal mb_stat_reg_write            : std_logic;
   signal mb_stat_reg_ack              : std_logic;
   signal mb_ip_mem_addr               : std_logic_vector(15 downto 0); -- only [7:0] in used
   signal mb_ip_mem_data_wr            : std_logic_vector(31 downto 0);
   signal mb_ip_mem_data_rd            : std_logic_vector(31 downto 0);
   signal mb_ip_mem_read               : std_logic;
   signal mb_ip_mem_write              : std_logic;
   signal mb_ip_mem_ack                : std_logic;
   signal ip_cfg_mem_clk        : std_logic;
   signal ip_cfg_mem_addr        : std_logic_vector(7 downto 0);
   signal ip_cfg_mem_data        : std_logic_vector(31 downto 0) := (others => '0');
   signal ctrl_reg_addr                : std_logic_vector(15 downto 0);
   signal gbe_stp_reg_addr             : std_logic_vector(15 downto 0);
   signal gbe_stp_data                 : std_logic_vector(31 downto 0);
   signal gbe_stp_reg_ack              : std_logic;
   signal gbe_stp_reg_data_wr          : std_logic_vector(31 downto 0);
   signal gbe_stp_reg_read             : std_logic;
   signal gbe_stp_reg_write            : std_logic;
   signal gbe_stp_reg_data_rd          : std_logic_vector(31 downto 0);

   signal debug : std_logic_vector(63 downto 0);

   signal next_reset, make_reset_via_network_q : std_logic;
   signal reset_counter : std_logic_vector(11 downto 0);
   signal link_ok : std_logic;

   signal gsc_init_data, gsc_reply_data : std_logic_vector(15 downto 0);
   signal gsc_init_read, gsc_reply_read : std_logic;
   signal gsc_init_dataready, gsc_reply_dataready : std_logic;
   signal gsc_init_packet_num, gsc_reply_packet_num : std_logic_vector(2 downto 0);
   signal gsc_busy : std_logic;
   signal mc_unique_id  : std_logic_vector(63 downto 0);
   signal trb_reset_in  : std_logic;
   signal reset_via_gbe : std_logic;
   signal reset_via_gbe_delayed : std_logic_vector(2 downto 0);
   signal reset_i_temp  : std_logic;

   signal cts_rdo_trigger             : std_logic;
   signal cts_rdo_trg_data_valid      : std_logic;
   signal cts_rdo_valid_timing_trg    : std_logic;
   signal cts_rdo_valid_notiming_trg  : std_logic;
   signal cts_rdo_invalid_trg         : std_logic;

   signal cts_rdo_trg_status_bits,
      cts_rdo_trg_status_bits_cts      : std_logic_vector(31 downto 0) := (others => '0');
   signal cts_rdo_data                : std_logic_vector(31 downto 0);
   signal cts_rdo_write               : std_logic;
   signal cts_rdo_finished            : std_logic;

   signal cts_ext_trigger             : std_logic;
   signal cts_ext_status              : std_logic_vector(31 downto 0) := (others => '0');
   signal cts_ext_control             : std_logic_vector(31 downto 0);
   signal cts_ext_debug               : std_logic_vector(31 downto 0);
   signal cts_ext_header              : std_logic_vector(1 downto 0);

   signal cts_rdo_additional_data            : std_logic_vector(32*cts_rdo_additional_ports-1 downto 0);
   signal cts_rdo_additional_write           : std_logic_vector(cts_rdo_additional_ports-1 downto 0) := (others => '0');
   signal cts_rdo_additional_finished        : std_logic_vector(cts_rdo_additional_ports-1 downto 0) := (others => '1');
   signal cts_rdo_trg_status_bits_additional : std_logic_vector(32*cts_rdo_additional_ports-1 downto 0) := (others => '0');
   
   signal cts_rdo_additional : readout_tx_array_t(0 to cts_rdo_additional_ports-1);
      
   signal cts_rdo_trg_type                   : std_logic_vector(3 downto 0);
   signal cts_rdo_trg_code                   : std_logic_vector(7 downto 0);
   signal cts_rdo_trg_information            : std_logic_vector(23 downto 0);
   signal cts_rdo_trg_number                 : std_logic_vector(15 downto 0);
      
   constant CTS_ADDON_LINE_COUNT      : integer := 38;
   constant CTS_OUTPUT_MULTIPLEXERS   : integer :=  8;
   constant CTS_OUTPUT_INPUTS         : integer := 16;

   signal cts_addon_triggers_in       : std_logic_vector(CTS_ADDON_LINE_COUNT-1 downto 0);
   signal cts_addon_activity_i,
         cts_addon_selected_i        : std_logic_vector(6 downto 0);
         
   signal cts_periph_trigger_i        : std_logic_vector(19 downto 0);
   signal cts_output_multiplexers_i   : std_logic_vector(CTS_OUTPUT_MULTIPLEXERS - 1 downto 0);

   signal cts_periph_lines_i   : std_logic_vector(CTS_OUTPUT_INPUTS - 1 downto 0);

   signal cts_trg_send                : std_logic;
   signal cts_trg_type                : std_logic_vector(3 downto 0);
   signal cts_trg_number              : std_logic_vector(15 downto 0);
   signal cts_trg_information         : std_logic_vector(23 downto 0);
   signal cts_trg_code                : std_logic_vector(7 downto 0);
   signal cts_trg_status_bits         : std_logic_vector(31 downto 0);
   signal cts_trg_busy                : std_logic;

   signal cts_ipu_send                : std_logic;
   signal cts_ipu_type                : std_logic_vector(3 downto 0);
   signal cts_ipu_number              : std_logic_vector(15 downto 0);
   signal cts_ipu_information         : std_logic_vector(7 downto 0);
   signal cts_ipu_code                : std_logic_vector(7 downto 0);
   signal cts_ipu_status_bits         : std_logic_vector(31 downto 0);
   signal cts_ipu_busy                : std_logic;

   signal cts_regio_addr              : std_logic_vector(15 downto 0);
   signal cts_regio_read              : std_logic;
   signal cts_regio_write             : std_logic;
   signal cts_regio_data_out          : std_logic_vector(31 downto 0);
   signal cts_regio_data_in           : std_logic_vector(31 downto 0);
   signal cts_regio_dataready         : std_logic;
   signal cts_regio_no_more_data      : std_logic;
   signal cts_regio_write_ack         : std_logic;
   signal cts_regio_unknown_addr      : std_logic;

   signal cts_trigger_out             : std_logic;
   signal external_send_reset         : std_logic;
   --bit 1 ms-tick, 0 us-tick
   signal timer_ticks                 : std_logic_vector(1 downto 0);

   signal trigger_busy_i              : std_logic;
   signal tdc_inputs                  : std_logic_vector(TDC_CHANNEL_NUMBER-1 downto 1);

   signal select_tc_i                 : std_logic_vector(31 downto 0);
   signal select_tc_reset_i           : std_logic;


   signal hitreg_read_en    : std_logic;
   signal hitreg_write_en   : std_logic;
   signal hitreg_data_in    : std_logic_vector(31 downto 0);
   signal hitreg_addr       : std_logic_vector(6 downto 0);
   signal hitreg_data_out   : std_logic_vector(31 downto 0) := (others => '0');
   signal hitreg_data_ready : std_logic;
   signal hitreg_invalid    : std_logic;

   signal srb_read_en    : std_logic;
   signal srb_write_en   : std_logic;
   signal srb_data_in    : std_logic_vector(31 downto 0);
   signal srb_addr       : std_logic_vector(6 downto 0);
   signal srb_data_out   : std_logic_vector(31 downto 0) := (others => '0');
   signal srb_data_ready : std_logic;
   signal srb_invalid    : std_logic;

   signal esb_read_en    : std_logic;
   signal esb_write_en   : std_logic;
   signal esb_data_in    : std_logic_vector(31 downto 0);
   signal esb_addr       : std_logic_vector(6 downto 0);
   signal esb_data_out   : std_logic_vector(31 downto 0) := (others => '0');
   signal esb_data_ready : std_logic;
   signal esb_invalid    : std_logic;

   signal fwb_read_en    : std_logic;
   signal fwb_write_en   : std_logic;
   signal fwb_data_in    : std_logic_vector(31 downto 0);
   signal fwb_addr       : std_logic_vector(6 downto 0);
   signal fwb_data_out   : std_logic_vector(31 downto 0) := (others => '0');
   signal fwb_data_ready : std_logic;
   signal fwb_invalid    : std_logic;

   signal tdc_ctrl_read      : std_logic;
   signal last_tdc_ctrl_read : std_logic;
   signal tdc_ctrl_write     : std_logic;
   signal tdc_ctrl_addr      : std_logic_vector(2 downto 0);
   signal tdc_ctrl_data_in   : std_logic_vector(31 downto 0);
   signal tdc_ctrl_data_out  : std_logic_vector(31 downto 0) := (others => '0');
   signal tdc_ctrl_reg   : std_logic_vector(8*32-1 downto 0);
   signal tdc_debug      : std_logic_vector(15 downto 0);  

   signal sfp_ddm_ctrl_read      : std_logic;
   signal last_sfp_ddm_ctrl_read : std_logic;
   signal sfp_ddm_ctrl_write     : std_logic;
   signal sfp_ddm_ctrl_addr      : std_logic_vector(1 downto 0);
   signal sfp_ddm_ctrl_data_in   : std_logic_vector(31 downto 0);
   signal sfp_ddm_ctrl_data_out  : std_logic_vector(31 downto 0) := (others => '0');
   signal sfp_ddm_ctrl_reg       : std_logic_vector(4*32-1 downto 0);

   signal led_time_ref_i : std_logic;

   signal do_reboot_i         : std_logic;
   signal killswitch_reboot_i : std_logic;

   signal cts_ext_bufferwarning : std_logic := '0';  
   signal cts_ext_discard       : std_logic := '0'; 
   signal cts_ext_force_trigger_info : std_logic_vector(23 downto 0) := (others => '0');
   signal last_cts_trg_busy     : std_logic;

   signal mbs_clock_i, mbs_data_i : std_logic;  
   
   -- cbmnet  
   signal cbm_clk_i           : std_logic;
   signal cbm_reset_i         : std_logic;
   signal cbm_etm_trigger_i   : std_logic;

   signal cbm_phy_led_rx_i      : std_logic;
   signal cbm_phy_led_tx_i      : std_logic;
   signal cbm_phy_led_ok_i      : std_logic;
   
   signal cbm_link_active_i : std_logic;
   signal cbm_sync_dlm_sensed_i : std_logic;
   signal cbm_sync_pulser_i : std_logic;
   signal cbm_sync_timing_trigger_i : std_logic;

   signal cbm_regio_rx, bustc_rx, busgbeip_rx, busgbereg_rx : CTRLBUS_RX;
   signal cbm_regio_tx, bustc_tx, busgbeip_tx, busgbereg_tx : CTRLBUS_TX;

   signal reboot_from_gbe : std_logic;

   signal fwd_data : std_logic_vector(4 * 8 - 1 downto 0);
   signal fwd_dv, fwd_sop, fwd_eop, fwd_ready, fwd_full : std_logic_vector(3 downto 0);
   signal fwd_mac : std_logic_vector(4 * 48 - 1 downto 0);
   signal fwd_ip : std_logic_vector(4 * 32 - 1 downto 0);
   signal fwd_udp : std_logic_vector(4 * 16 - 1 downto 0);

   component OSCF is
      port (
         OSC : out std_logic
         );
   end component;      

begin
  assert not(USE_4_SFP = c_YES and INCLUDE_CBMNET = c_YES) report "CBMNET uses SFPs 1-4 and hence does not support USE_4_SFP" severity failure;
  assert not(INCLUDE_CBMNET = c_YES and INCLUDE_CTS = c_NO) report "CBMNET is supported only with CTS included" severity failure;
  assert not(INCLUDE_TDC = c_YES and INCLUDE_MBS_MASTER = c_YES) report "TDC and MBS Master can not be implemented" severity failure;
  assert not(INCLUDE_ETM = c_YES and ETM_CHOICE = ETM_CHOICE_MBS_VULOM and INCLUDE_MBS_MASTER = c_YES) report "This ETM and MBS Master can not be implemented" severity failure;
  assert not(INCLUDE_ETM = c_YES and ETM_CHOICE = ETM_CHOICE_MAINZ_A2 and INCLUDE_MBS_MASTER = c_YES) report "This ETM and MBS Master can not be implemented" severity failure;

-- MBS Module
  gen_mbs_vulom_as_etm : if ETM_CHOICE = ETM_CHOICE_MBS_VULOM and INCLUDE_CTS = c_YES and INCLUDE_ETM = c_YES generate
    THE_MBS : entity work.mbs_vulom_recv
      port map (
        CLK      => clk_100_i,
        RESET_IN => reset_i,

        MBS_IN  => CLK_EXT(3),
        CLK_200 => clk_200_i,

        TRG_ASYNC_OUT => tdc_inputs(1),
        TRG_SYNC_OUT  => cts_ext_trigger,

        TRIGGER_IN    => cts_rdo_trg_data_valid,
        TRG_NUMBER_IN => cts_trg_number,
        TRG_CODE_IN   => cts_trg_code,
        TIMING_TRG_IN => cts_trigger_out,
        
        DATA_OUT      => cts_rdo_additional(0).data,
        WRITE_OUT     => cts_rdo_additional(0).data_write,
        FINISHED_OUT  => cts_rdo_additional(0).data_finished,
        STATUSBIT_OUT => cts_rdo_additional(0).statusbits,

        CONTROL_REG_IN => cts_ext_control,
        STATUS_REG_OUT => cts_ext_status,
        HEADER_REG_OUT => cts_ext_header,

        DEBUG => cts_ext_debug
        );
  end generate;

-- Mainz A2 Module
  gen_mainz_a2_as_etm : if ETM_CHOICE = ETM_CHOICE_MAINZ_A2 and INCLUDE_CTS = c_YES and INCLUDE_ETM = c_YES generate
    mainz_a2_recv_1 : entity work.mainz_a2_recv
      port map (
        CLK               => clk_100_i,
        RESET_IN          => reset_i,
        TIMER_TICK_1US_IN => timer_ticks(0),
        SERIAL_IN         => CLK_EXT(3),
        EXT_TRG_IN        => CLK_EXT(4),
        TRG_SYNC_OUT      => cts_ext_trigger,
        TRIGGER_IN        => cts_rdo_trg_data_valid,

        DATA_OUT      => cts_rdo_additional(0).data,
        WRITE_OUT     => cts_rdo_additional(0).data_write,
        FINISHED_OUT  => cts_rdo_additional(0).data_finished,
        STATUSBIT_OUT => cts_rdo_additional(0).statusbits,

        CONTROL_REG_IN => cts_ext_control,
        STATUS_REG_OUT => cts_ext_status,
        HEADER_REG_OUT => cts_ext_header,

        DEBUG => cts_ext_debug
        );
  end generate;

-- Mimosa26 MVD ETM
   gen_m26_etm : if ETM_CHOICE = ETM_CHOICE_M26 and INCLUDE_CTS = c_YES and INCLUDE_ETM = c_YES generate
      m26_etm : entity work.m26_sensor_etm
         port map (
            CLK               => clk_100_i,
            RESET_IN          => reset_i,
            
            BUSY_IN           => trigger_busy_i,
            BUFFER_WARNING_IN => cts_ext_bufferwarning,
            TRIGGER_OUT       => cts_ext_trigger,
            DISCARD_OUT       => cts_ext_discard,
            
            TRIGGER_IN        => cts_rdo_trg_data_valid,
            DATA_OUT          => cts_rdo_additional(0).data,   
            WRITE_OUT         => cts_rdo_additional(0).data_write,   
            FINISHED_OUT      => cts_rdo_additional(0).data_finished,   
            STATUSBIT_OUT     => cts_rdo_additional(0).statusbits,   

            --Registers / Debug  
            CONTROL_REG_IN  => cts_ext_control,      
            STATUS_REG_OUT  => cts_ext_status,      
            DEBUG           => cts_ext_debug
         );
      cts_ext_header <= "10";   
      cts_ext_force_trigger_info(0) <= cts_ext_discard;
      cts_ext_force_trigger_info(23 downto 1) <= (others => '0');
      last_cts_trg_busy <= cts_trg_busy when rising_edge(clk_100_i);
      cts_ext_bufferwarning <= cts_trg_status_bits(20) when cts_trg_busy = '0' and last_cts_trg_busy = '1';
   end generate;
 

-- CBMNet ETM
  gen_cbmnet_etm : if (ETM_CHOICE = ETM_CHOICE_CBMNET and INCLUDE_CTS = c_YES) or (INCLUDE_ETM = c_NO and INCLUDE_MBS_MASTER = c_NO and INCLUDE_TIMESTAMP_GENERATOR = c_NO) generate
    cts_ext_trigger                     <= cbm_etm_trigger_i;
    cts_rdo_additional(0).data_finished <= '1';
    cts_ext_header                      <= "00";
    cts_ext_status                      <= x"deadc0de";
  end generate;

  GEN_CTS : if INCLUDE_CTS = c_YES generate
    THE_CTS : CTS
      generic map (
        EXTERNAL_TRIGGER_ID => ETM_ID,  -- fill in trigger logic enumeration id of external trigger logic

--         TRIGGER_COIN_COUNT   => TRIGGER_COIN_COUNT,
--         TRIGGER_PULSER_COUNT => TRIGGER_PULSER_COUNT,
--         TRIGGER_RAND_PULSER  => TRIGGER_RAND_PULSER,
-- 
--         TRIGGER_INPUT_COUNT => 0,  -- obsolete! now all inputs are routed via an input multiplexer!
--         TRIGGER_ADDON_COUNT => TRIGGER_ADDON_COUNT,
-- 
--         PERIPH_TRIGGER_COUNT => PERIPH_TRIGGER_COUNT,

        OUTPUT_MULTIPLEXERS => CTS_OUTPUT_MULTIPLEXERS,

--         ADDON_LINE_COUNT  => CTS_ADDON_LINE_COUNT,
        ADDON_GROUPS      => 7,
        ADDON_GROUP_UPPER => (3, 7, 11, 15, 16, 17, others => 0)
        )
      port map (
        CLK   => clk_100_i,
        RESET => reset_i,

        --TRIGGERS_IN => trigger_in_buf_i,
        TRIGGER_BUSY_OUT   => trigger_busy_i,
        TIME_REFERENCE_OUT => cts_trigger_out,

        ADDON_TRIGGERS_IN        => cts_addon_triggers_in,
        ADDON_GROUP_ACTIVITY_OUT => cts_addon_activity_i,
        ADDON_GROUP_SELECTED_OUT => cts_addon_selected_i,

        EXT_TRIGGER_IN     => cts_ext_trigger,
        EXT_STATUS_IN      => cts_ext_status,
        EXT_CONTROL_OUT    => cts_ext_control,
        EXT_HEADER_BITS_IN => cts_ext_header,
        EXT_FORCE_TRIGGER_INFO_IN => cts_ext_force_trigger_info,

        PERIPH_TRIGGER_IN => cts_periph_trigger_i,

        OUTPUT_MULTIPLEXERS_OUT => cts_output_multiplexers_i,

        CTS_TRG_SEND_OUT        => cts_trg_send,
        CTS_TRG_TYPE_OUT        => cts_trg_type,
        CTS_TRG_NUMBER_OUT      => cts_trg_number,
        CTS_TRG_INFORMATION_OUT => cts_trg_information,
        CTS_TRG_RND_CODE_OUT    => cts_trg_code,
        CTS_TRG_STATUS_BITS_IN  => cts_trg_status_bits,
        CTS_TRG_BUSY_IN         => cts_trg_busy,

        CTS_IPU_SEND_OUT        => cts_ipu_send,
        CTS_IPU_TYPE_OUT        => cts_ipu_type,
        CTS_IPU_NUMBER_OUT      => cts_ipu_number,
        CTS_IPU_INFORMATION_OUT => cts_ipu_information,
        CTS_IPU_RND_CODE_OUT    => cts_ipu_code,
        CTS_IPU_STATUS_BITS_IN  => cts_ipu_status_bits,
        CTS_IPU_BUSY_IN         => cts_ipu_busy,

        CTS_REGIO_ADDR_IN          => cts_regio_addr,
        CTS_REGIO_DATA_IN          => cts_regio_data_out,
        CTS_REGIO_READ_ENABLE_IN   => cts_regio_read,
        CTS_REGIO_WRITE_ENABLE_IN  => cts_regio_write,
        CTS_REGIO_DATA_OUT         => cts_regio_data_in,
        CTS_REGIO_DATAREADY_OUT    => cts_regio_dataready,
        CTS_REGIO_WRITE_ACK_OUT    => cts_regio_write_ack,
        CTS_REGIO_UNKNOWN_ADDR_OUT => cts_regio_unknown_addr,

        LVL1_TRG_DATA_VALID_IN     => cts_rdo_trg_data_valid,
        LVL1_VALID_TIMING_TRG_IN   => cts_rdo_valid_timing_trg,
        LVL1_VALID_NOTIMING_TRG_IN => cts_rdo_valid_notiming_trg,
        LVL1_INVALID_TRG_IN        => cts_rdo_invalid_trg,

        FEE_TRG_STATUSBITS_OUT => cts_rdo_trg_status_bits_cts,
        FEE_DATA_OUT           => cts_rdo_data,
        FEE_DATA_WRITE_OUT     => cts_rdo_write,
        FEE_DATA_FINISHED_OUT  => cts_rdo_finished
        );   

gen_trigger_in_nombsmaster : if INCLUDE_MBS_MASTER = c_NO generate      
    cts_addon_triggers_in(1 downto 0) <= CLK_EXT;  -- former trigger inputs
end generate;    
    cts_addon_triggers_in(3 downto 2) <= TRIGGER_EXT_3 & TRIGGER_EXT_2;  -- former trigger inputs

    cts_addon_triggers_in(7 downto 4)   <= ECL_IN;
    cts_addon_triggers_in(11 downto 8)  <= JIN1;
    cts_addon_triggers_in(15 downto 12) <= JIN2;
    cts_addon_triggers_in(17 downto 16) <= NIM_IN;

    cts_addon_triggers_in(18)           <= or_all(ECL_IN);
    cts_addon_triggers_in(19)           <= or_all(JIN1);
    cts_addon_triggers_in(20)           <= or_all(JIN2);
    cts_addon_triggers_in(21)           <= or_all(NIM_IN);
    cts_addon_triggers_in(37 downto 22) <= JTTL;

    LED_BANK(7 downto 6) <= cts_addon_activity_i(4 downto 3);
    LED_RJ_GREEN <= (
      0      => cts_addon_activity_i(2),
      1      => cts_addon_activity_i(3),
      5      => cts_addon_activity_i(1),
      others => '0'
      );

    LED_RJ_RED <= (
      0      => cts_addon_selected_i(2),
      1      => cts_addon_selected_i(3),
      5      => cts_addon_selected_i(1),
      others => '0'
      );

    cts_periph_trigger_i <= FPGA4_COMM(10 downto 6)
                            & FPGA3_COMM(10 downto 6)
                            & FPGA2_COMM(10 downto 6)
                            & FPGA1_COMM(10 downto 6);

    JOUT1    <= cts_output_multiplexers_i(3 downto 0);
    JOUT2    <= cts_output_multiplexers_i(7 downto 4);
    JOUTLVDS <= cts_output_multiplexers_i(7 downto 0);
  --LED_BANK <= cts_output_multiplexers_i(7 downto 0);
  end generate;

  GEN_NO_CTS : if INCLUDE_CTS = c_NO generate
    cts_rdo_trg_status_bits <= (others => '0');
    cts_rdo_finished        <= '1';
    cts_regio_unknown_addr  <= '1';

    cts_ipu_send    <= '0';
    cts_trg_send    <= '0';
    cts_trigger_out <= '0';
  end generate;

-- ---------------------------------------------------------------------------
-- -- CBMNET stack
-- ---------------------------------------------------------------------------   
--   GEN_CBMNET : if INCLUDE_CBMNET = c_YES generate
--     THE_CBM_BRIDGE : cbmnet_bridge
--       port map (
--         -- clock and reset
--         CLK125_IN      => clk_125_i,    -- in std_logic;
--         ASYNC_RESET_IN => clear_i,
--         TRB_CLK_IN     => clk_100_i,    -- in std_logic;
--         TRB_RESET_IN   => reset_i,      -- in std_logic;
-- 
--         CBM_CLK_OUT   => cbm_clk_i,     -- out std_logic;
--         CBM_RESET_OUT => cbm_reset_i,   -- out std_logic;
-- 
--         -- Media Interface
--         SD_RXD_P_IN  => SFP_RX_P(5),
--         SD_RXD_N_IN  => SFP_RX_N(5),
--         SD_TXD_P_OUT => SFP_TX_P(5),
--         SD_TXD_N_OUT => SFP_TX_N(5),
-- 
--         SD_PRSNT_N_IN => SFP_MOD0(1),
--         SD_LOS_IN     => SFP_LOS(1),
--         SD_TXDIS_OUT  => SFP_TXDIS(1),
-- 
--         LED_RX_OUT => cbm_phy_led_rx_i,
--         LED_TX_OUT => cbm_phy_led_tx_i,
--         LED_OK_OUT => cbm_phy_led_ok_i,
-- 
--         -- Status and strobes   
--         CBM_LINK_ACTIVE_OUT    => cbm_link_active_i,
--         CBM_DLM_OUT            => cbm_sync_dlm_sensed_i,      -- out std_logic;
--         CBM_TIMING_TRIGGER_OUT => cbm_sync_timing_trigger_i,  -- out std_logic;
--         CBM_SYNC_PULSER_OUT    => cbm_sync_pulser_i,          -- out std_logic;
-- 
--         -- TRBNet Terminal
--         TRB_TRIGGER_IN             => cts_trigger_out,
--         TRB_RDO_VALID_DATA_TRG_IN  => cts_rdo_trg_data_valid,  -- in  std_logic;
--         TRB_RDO_VALID_NO_TIMING_IN => cts_rdo_valid_notiming_trg,  -- in  std_logic;
--         TRB_RDO_DATA_OUT           => cts_rdo_additional(1).data,  --  out std_logic_vector(31 downto 0);
--         TRB_RDO_WRITE_OUT          => cts_rdo_additional(1).data_write,  --  out std_logic;
--         TRB_RDO_FINISHED_OUT       => cts_rdo_additional(1).data_finished,  --  out std_logic;
-- 
--         TRB_TRIGGER_OUT => cbm_etm_trigger_i,
-- 
--         -- connect to hub
--         HUB_CTS_NUMBER_IN            => hub_cts_number,  -- in  std_logic_vector (15 downto 0);
--         HUB_CTS_CODE_IN              => hub_cts_code,  -- in  std_logic_vector (7  downto 0);
--         HUB_CTS_INFORMATION_IN       => hub_cts_information,  -- in  std_logic_vector (7  downto 0);
--         HUB_CTS_READOUT_TYPE_IN      => hub_cts_readout_type,  -- in  std_logic_vector (3  downto 0);
--         HUB_CTS_START_READOUT_IN     => hub_cts_start_readout,  -- in  std_logic;
--         HUB_CTS_READOUT_FINISHED_OUT => hub_cts_readout_finished,  -- out std_logic;  --no more data, end transfer, send TRM
--         HUB_CTS_STATUS_BITS_OUT      => hub_cts_status_bits,  -- out std_logic_vector (31 downto 0);
--         HUB_FEE_DATA_IN              => hub_fee_data,  -- in  std_logic_vector (15 downto 0);
--         HUB_FEE_DATAREADY_IN         => hub_fee_dataready,    -- in  std_logic;
--         HUB_FEE_READ_OUT             => hub_fee_read,  -- out std_logic;  --must be high when idle, otherwise you will never get a dataready
--         HUB_FEE_STATUS_BITS_IN       => hub_fee_status_bits,  -- in  std_logic_vector (31 downto 0);
--         HUB_FEE_BUSY_IN              => hub_fee_busy,  -- in  std_logic;   
-- 
--         -- connect to GbE
--         GBE_CTS_NUMBER_OUT          => gbe_cts_number,  -- out std_logic_vector (15 downto 0);
--         GBE_CTS_CODE_OUT            => gbe_cts_code,  -- out std_logic_vector (7  downto 0);
--         GBE_CTS_INFORMATION_OUT     => gbe_cts_information,  -- out std_logic_vector (7  downto 0);
--         GBE_CTS_READOUT_TYPE_OUT    => gbe_cts_readout_type,  -- out std_logic_vector (3  downto 0);
--         GBE_CTS_START_READOUT_OUT   => gbe_cts_start_readout,  -- out std_logic;
--         GBE_CTS_READOUT_FINISHED_IN => gbe_cts_readout_finished,  -- in  std_logic;      --no more data, end transfer, send TRM
--         GBE_CTS_STATUS_BITS_IN      => gbe_cts_status_bits,  -- in  std_logic_vector (31 downto 0);
--         GBE_FEE_DATA_OUT            => gbe_fee_data,  -- out std_logic_vector (15 downto 0);
--         GBE_FEE_DATAREADY_OUT       => gbe_fee_dataready,    -- out std_logic;
--         GBE_FEE_READ_IN             => gbe_fee_read,  -- in  std_logic;  --must be high when idle, otherwise you will never get a dataready
--         GBE_FEE_STATUS_BITS_OUT     => gbe_fee_status_bits,  -- out std_logic_vector (31 downto 0);
--         GBE_FEE_BUSY_OUT            => gbe_fee_busy,  -- out std_logic;
-- 
--         -- reg io
--         --REGIO_IN              => cbm_regio_rx,
--         --REGIO_OUT             => cbm_regio_tx
--         REGIO_ADDR_IN         => cbm_regio_rx.addr,
--         REGIO_DATA_IN         => cbm_regio_rx.data,
--         REGIO_TIMEOUT_IN      => cbm_regio_rx.timeout,
--         REGIO_READ_ENABLE_IN  => cbm_regio_rx.read,
--         REGIO_WRITE_ENABLE_IN => cbm_regio_rx.write,
-- 
--         REGIO_DATA_OUT         => cbm_regio_tx.data,
--         REGIO_DATAREADY_OUT    => cbm_regio_tx.rack,
--         REGIO_WRITE_ACK_OUT    => cbm_regio_tx.wack,
--         REGIO_NO_MORE_DATA_OUT => cbm_regio_tx.nack,
--         REGIO_UNKNOWN_ADDR_OUT => cbm_regio_tx.unknown
--         );
-- 
--     cbm_regio_tx.ack <= cbm_regio_tx.rack or cbm_regio_tx.wack;
-- 
--     SFP_RATE_SEL(1)   <= '1';  -- not supported by SFP, but in general, this should be the correct setting
--     LED_TRIGGER_GREEN <= not cbm_link_active_i;
--     LED_TRIGGER_RED   <= '0';
-- 
--     --Internal Connection
--     med_read_in(4)                  <= '0';
--     med_data_in(79 downto 64)       <= (others => '0');
--     med_packet_num_in(14 downto 12) <= (others => '0');
--     med_dataready_in(4)             <= '0';
--     med_stat_op(79 downto 64) <= (
--       64+2 downto 64 => '1',            -- ERROR_NC
--       64 + 14        => '1',            -- indicate "no signal"
--       others         => '0');
--     med_stat_debug(4*64+63 downto 4*64) <= (others => '0');
-- 
--     SFP_TXDIS(4 downto 2) <= (others => '1');
-- 
--   end generate;

  GEN_NO_CBMNET : if INCLUDE_CBMNET = c_NO generate
    gbe_cts_number        <= hub_cts_number;
    gbe_cts_code          <= hub_cts_code;
    gbe_cts_information   <= hub_cts_information;
    gbe_cts_readout_type  <= hub_cts_readout_type;
    gbe_cts_start_readout <= hub_cts_start_readout;
    gbe_fee_data          <= hub_fee_data;
    gbe_fee_dataready     <= hub_fee_dataready;
    gbe_fee_status_bits   <= hub_fee_status_bits;
    gbe_fee_busy          <= hub_fee_busy;

    hub_cts_status_bits      <= gbe_cts_status_bits;
    hub_cts_readout_finished <= gbe_cts_readout_finished;
    hub_fee_read             <= gbe_fee_read;

    LED_TRIGGER_GREEN <= not med_stat_op(4*16+9);
    LED_TRIGGER_RED   <= not (med_stat_op(4*16+11) or med_stat_op(4*16+10));

    cbm_etm_trigger_i <= '0';

    cbm_regio_tx.nack    <= cbm_regio_rx.read or cbm_regio_rx.write when rising_edge(clk_100_i);
    cbm_regio_tx.unknown <= cbm_regio_rx.read or cbm_regio_rx.write when rising_edge(clk_100_i);
  end generate;


---------------------------------------------------------------------------
-- Reset Generation
---------------------------------------------------------------------------
  GSR_N <= pll_lock;

  THE_RESET_HANDLER : trb_net_reset_handler
    generic map(
      RESET_DELAY => x"FEEE"
      )
    port map(
      CLEAR_IN      => select_tc_reset_i,  -- reset input (high active, async)
      CLEAR_N_IN    => '1',             -- reset input (low active, async)
      CLK_IN        => clk_200_i,       -- raw master clock, NOT from PLL/DLL!
      SYSCLK_IN     => clk_100_i,       -- PLL/DLL remastered clock
      PLL_LOCKED_IN => pll_lock,        -- master PLL lock signal (async)
      RESET_IN      => '0',             -- general reset signal (SYSCLK)
      TRB_RESET_IN  => trb_reset_in,    -- TRBnet reset signal (SYSCLK)
      CLEAR_OUT     => clear_i,         -- async reset out, USE WITH CARE!
      RESET_OUT     => reset_i_temp,    -- synchronous reset out (SYSCLK)
      DEBUG_OUT     => open
      );

  trb_reset_in <= reset_via_gbe or MED_STAT_OP(4*16+13);  --_delayed(2)
  reset_i      <= reset_i_temp;                           -- or trb_reset_in;

---------------------------------------------------------------------------
-- Clock Handling
---------------------------------------------------------------------------
THE_MAIN_PLL : pll_in200_out100
  port map (
    CLK    => CLK_GPLL_LEFT,
    RESET  => '0',
    CLKOP  => clk_100_i,
    CLKOK  => clk_200_i,
    LOCK   => pll_lock
    );

   clk_125_i <= CLK_GPLL_RIGHT;      

---------------------------------------------------------------------------
-- The TrbNet media interface (SFP)
---------------------------------------------------------------------------
  gen_single_sfp : if USE_4_SFP = c_NO and INCLUDE_CBMNET = c_NO generate
    THE_MEDIA_UPLINK : trb_net16_med_ecp3_sfp
      generic map(
        SERDES_NUM  => 0,               --number of serdes in quad
        EXT_CLOCK   => c_NO,            --use internal clock
        USE_200_MHZ => c_YES,           --run on 200 MHz clock
        USE_CTC     => c_YES,
        USE_SLAVE   => c_NO
        )
      port map(
        CLK                => clk_200_i,
        SYSCLK             => clk_100_i,
        RESET              => reset_i,
        CLEAR              => clear_i,
        CLK_EN             => '1',
        --Internal Connection
        MED_DATA_IN        => med_data_out(79 downto 64),
        MED_PACKET_NUM_IN  => med_packet_num_out(14 downto 12),
        MED_DATAREADY_IN   => med_dataready_out(4),
        MED_READ_OUT       => med_read_in(4),
        MED_DATA_OUT       => med_data_in(79 downto 64),
        MED_PACKET_NUM_OUT => med_packet_num_in(14 downto 12),
        MED_DATAREADY_OUT  => med_dataready_in(4),
        MED_READ_IN        => med_read_out(4),
        REFCLK2CORE_OUT    => open,
        --SFP Connection
        SD_RXD_P_IN        => SFP_RX_P(5),
        SD_RXD_N_IN        => SFP_RX_N(5),
        SD_TXD_P_OUT       => SFP_TX_P(5),
        SD_TXD_N_OUT       => SFP_TX_N(5),
        SD_REFCLK_P_IN     => open,
        SD_REFCLK_N_IN     => open,
        SD_PRSNT_N_IN      => SFP_MOD0(1),
        SD_LOS_IN          => SFP_LOS(1),
        SD_TXDIS_OUT       => SFP_TXDIS(1),
        -- Status and control port
        STAT_OP            => med_stat_op(79 downto 64),
        CTRL_OP            => med_ctrl_op(79 downto 64),
        STAT_DEBUG         => med_stat_debug(4*64+63 downto 4*64),
        CTRL_DEBUG         => (others => '0')
        );
    SFP_TXDIS(4 downto 2) <= (others => '1');
  end generate;

  gen_four_sfp : if USE_4_SFP = c_YES and INCLUDE_CBMNET = c_NO generate
    THE_MEDIA_UPLINK : trb_net16_med_ecp3_sfp_4
      generic map(
        REVERSE_ORDER => c_NO,          --order of ports
        FREQUENCY     => 200            --run on 200 MHz clock
        )
      port map(
        CLK                => clk_200_i,
        SYSCLK             => clk_100_i,
        RESET              => reset_i,
        CLEAR              => clear_i,
        CLK_EN             => '1',
        --Internal Connection
        MED_DATA_IN        => med_data_out(127 downto 64),
        MED_PACKET_NUM_IN  => med_packet_num_out(23 downto 12),
        MED_DATAREADY_IN   => med_dataready_out(7 downto 4),
        MED_READ_OUT       => med_read_in(7 downto 4),
        MED_DATA_OUT       => med_data_in(127 downto 64),
        MED_PACKET_NUM_OUT => med_packet_num_in(23 downto 12),
        MED_DATAREADY_OUT  => med_dataready_in(7 downto 4),
        MED_READ_IN        => med_read_out(7 downto 4),

        REFCLK2CORE_OUT => open,
        --SFP Connection
        SD_RXD_P_IN     => SFP_RX_P(8 downto 5),
        SD_RXD_N_IN     => SFP_RX_N(8 downto 5),
        SD_TXD_P_OUT    => SFP_TX_P(8 downto 5),
        SD_TXD_N_OUT    => SFP_TX_N(8 downto 5),
        SD_REFCLK_P_IN  => open,
        SD_REFCLK_N_IN  => open,
        SD_PRSNT_N_IN   => SFP_MOD0(4 downto 1),
        SD_LOS_IN       => SFP_LOS(4 downto 1),
        SD_TXDIS_OUT    => SFP_TXDIS(4 downto 1),

        --       SCI_DATA_IN       => sci1_data_in,
        --       SCI_DATA_OUT      => sci1_data_out,
        --       SCI_ADDR          => sci1_addr,
        --       SCI_READ          => sci1_read,
        --       SCI_WRITE         => sci1_write,
        --       SCI_ACK           => sci1_ack,
        -- Status and control port

        STAT_OP => med_stat_op(7*16+15 downto 4*16),
        CTRL_OP => med_ctrl_op(7*16+15 downto 4*16),

        STAT_DEBUG => open,
        CTRL_DEBUG => (others => '0')
        );
    SFP_TXDIS(4 downto 5) <= (others => '1');
  end generate;

---------------------------------------------------------------------------
-- The TrbNet media interface (to other FPGA)
---------------------------------------------------------------------------
  THE_MEDIA_ONBOARD : trb_net16_med_ecp3_sfp_4_onboard
    port map (
      CLK                => clk_200_i,
      SYSCLK             => clk_100_i,
      RESET              => reset_i,
      CLEAR              => clear_i,
      CLK_EN             => '1',
      --Internal Connection
      MED_DATA_IN        => med_data_out(63 downto 0),
      MED_PACKET_NUM_IN  => med_packet_num_out(11 downto 0),
      MED_DATAREADY_IN   => med_dataready_out(3 downto 0),
      MED_READ_OUT       => med_read_in(3 downto 0),
      MED_DATA_OUT       => med_data_in(63 downto 0),
      MED_PACKET_NUM_OUT => med_packet_num_in(11 downto 0),
      MED_DATAREADY_OUT  => med_dataready_in(3 downto 0),
      MED_READ_IN        => med_read_out(3 downto 0),
      REFCLK2CORE_OUT    => open,
      --SFP Connection
      SD_RXD_P_IN        => SFP_RX_P(4 downto 1),
      SD_RXD_N_IN        => SFP_RX_N(4 downto 1),
      SD_TXD_P_OUT       => SFP_TX_P(4 downto 1),
      SD_TXD_N_OUT       => SFP_TX_N(4 downto 1),
      SD_REFCLK_P_IN     => open,
      SD_REFCLK_N_IN     => open,
      SD_PRSNT_N_IN(0)   => FPGA1_COMM(2),
      SD_PRSNT_N_IN(1)   => FPGA2_COMM(2),
      SD_PRSNT_N_IN(2)   => FPGA3_COMM(2),
      SD_PRSNT_N_IN(3)   => FPGA4_COMM(2),
      SD_LOS_IN(0)       => FPGA1_COMM(2),
      SD_LOS_IN(1)       => FPGA2_COMM(2),
      SD_LOS_IN(2)       => FPGA3_COMM(2),
      SD_LOS_IN(3)       => FPGA4_COMM(2),
      SD_TXDIS_OUT(0)    => FPGA1_COMM(0),
      SD_TXDIS_OUT(1)    => FPGA2_COMM(0),
      SD_TXDIS_OUT(2)    => FPGA3_COMM(0),
      SD_TXDIS_OUT(3)    => FPGA4_COMM(0),
      -- Status and control port
      STAT_OP            => med_stat_op(63 downto 0),
      CTRL_OP            => med_ctrl_op(63 downto 0),
      STAT_DEBUG         => med_stat_debug(3*64+63 downto 0*64),
      CTRL_DEBUG         => (others => '0')
      );

---------------------------------------------------------------------------
-- The TrbNet Hub
---------------------------------------------------------------------------
  THE_HUB : trb_net16_hub_streaming_port_sctrl_cts
    generic map(
      INIT_ADDRESS                  => x"F3C0",
      MII_NUMBER                    => INTERFACE_NUM,
      MII_IS_UPLINK                 => IS_UPLINK,
      MII_IS_DOWNLINK               => IS_DOWNLINK,
      MII_IS_UPLINK_ONLY            => IS_UPLINK_ONLY,
      HARDWARE_VERSION              => HARDWARE_INFO,
      INIT_ENDPOINT_ID              => x"0005",
      BROADCAST_BITMASK             => x"7E",
      CLOCK_FREQUENCY               => 100,
      USE_ONEWIRE                   => c_YES,
      BROADCAST_SPECIAL_ADDR        => x"35",
      RDO_ADDITIONAL_PORT           => cts_rdo_additional_ports,
      RDO_DATA_BUFFER_DEPTH         => 9,
      RDO_DATA_BUFFER_FULL_THRESH   => 2**9-128,
      RDO_HEADER_BUFFER_DEPTH       => 9,
      RDO_HEADER_BUFFER_FULL_THRESH => 2**9-16
      )
    port map (
      CLK    => clk_100_i,
      RESET  => reset_i,
      CLK_EN => '1',

      -- Media interfacces ---------------------------------------------------------------
      MED_DATAREADY_OUT(INTERFACE_NUM*1-1 downto 0)  => med_dataready_out,
      MED_DATA_OUT(INTERFACE_NUM*16-1 downto 0)      => med_data_out,
      MED_PACKET_NUM_OUT(INTERFACE_NUM*3-1 downto 0) => med_packet_num_out,
      MED_READ_IN(INTERFACE_NUM*1-1 downto 0)        => med_read_in,
      MED_DATAREADY_IN(INTERFACE_NUM*1-1 downto 0)   => med_dataready_in,
      MED_DATA_IN(INTERFACE_NUM*16-1 downto 0)       => med_data_in,
      MED_PACKET_NUM_IN(INTERFACE_NUM*3-1 downto 0)  => med_packet_num_in,
      MED_READ_OUT(INTERFACE_NUM*1-1 downto 0)       => med_read_out,
      MED_STAT_OP(INTERFACE_NUM*16-1 downto 0)       => med_stat_op,
      MED_CTRL_OP(INTERFACE_NUM*16-1 downto 0)       => med_ctrl_op,

      -- Gbe Read-out Path ---------------------------------------------------------------
      --Event information coming from CTS for GbE
      GBE_CTS_NUMBER_OUT          => hub_cts_number,
      GBE_CTS_CODE_OUT            => hub_cts_code,
      GBE_CTS_INFORMATION_OUT     => hub_cts_information,
      GBE_CTS_READOUT_TYPE_OUT    => hub_cts_readout_type,
      GBE_CTS_START_READOUT_OUT   => hub_cts_start_readout,
      --Information sent to CTS
      GBE_CTS_READOUT_FINISHED_IN => hub_cts_readout_finished,
      GBE_CTS_STATUS_BITS_IN      => hub_cts_status_bits,
      -- Data from Frontends
      GBE_FEE_DATA_OUT            => hub_fee_data,
      GBE_FEE_DATAREADY_OUT       => hub_fee_dataready,
      GBE_FEE_READ_IN             => hub_fee_read,
      GBE_FEE_STATUS_BITS_OUT     => hub_fee_status_bits,
      GBE_FEE_BUSY_OUT            => hub_fee_busy,

      -- CTS Request Sending -------------------------------------------------------------
      --LVL1 trigger
      CTS_TRG_SEND_IN         => cts_trg_send,
      CTS_TRG_TYPE_IN         => cts_trg_type,
      CTS_TRG_NUMBER_IN       => cts_trg_number,
      CTS_TRG_INFORMATION_IN  => cts_trg_information,
      CTS_TRG_RND_CODE_IN     => cts_trg_code,
      CTS_TRG_STATUS_BITS_OUT => cts_trg_status_bits,
      CTS_TRG_BUSY_OUT        => cts_trg_busy,
      --IPU Channel
      CTS_IPU_SEND_IN         => cts_ipu_send,
      CTS_IPU_TYPE_IN         => cts_ipu_type,
      CTS_IPU_NUMBER_IN       => cts_ipu_number,
      CTS_IPU_INFORMATION_IN  => cts_ipu_information,
      CTS_IPU_RND_CODE_IN     => cts_ipu_code,
      -- Receiver port
      CTS_IPU_STATUS_BITS_OUT => cts_ipu_status_bits,
      CTS_IPU_BUSY_OUT        => cts_ipu_busy,

      -- CTS Data Readout ----------------------------------------------------------------
      --Trigger to CTS out
      RDO_TRIGGER_IN             => cts_rdo_trigger,
      RDO_TRG_DATA_VALID_OUT     => cts_rdo_trg_data_valid,
      RDO_VALID_TIMING_TRG_OUT   => cts_rdo_valid_timing_trg,
      RDO_VALID_NOTIMING_TRG_OUT => cts_rdo_valid_notiming_trg,
      RDO_INVALID_TRG_OUT        => cts_rdo_invalid_trg,
      RDO_TRG_TYPE_OUT           => cts_rdo_trg_type,
      RDO_TRG_CODE_OUT           => cts_rdo_trg_code,
      RDO_TRG_INFORMATION_OUT    => cts_rdo_trg_information,
      RDO_TRG_NUMBER_OUT         => cts_rdo_trg_number,

      --Data from CTS in
      RDO_TRG_STATUSBITS_IN        => cts_rdo_trg_status_bits_cts,
      RDO_DATA_IN                  => cts_rdo_data,
      RDO_DATA_WRITE_IN            => cts_rdo_write,
      RDO_DATA_FINISHED_IN         => cts_rdo_finished,
      --Data from additional modules
      RDO_ADDITIONAL_STATUSBITS_IN => cts_rdo_trg_status_bits_additional,
      RDO_ADDITIONAL_DATA          => cts_rdo_additional_data,
      RDO_ADDITIONAL_WRITE         => cts_rdo_additional_write,
      RDO_ADDITIONAL_FINISHED      => cts_rdo_additional_finished,

      -- Slow Control --------------------------------------------------------------------
      COMMON_STAT_REGS    => common_stat_regs,  --open,
      COMMON_CTRL_REGS    => common_ctrl_regs,  --open,
      ONEWIRE             => TEMPSENS,
      ONEWIRE_MONITOR_IN  => open,
      MY_ADDRESS_OUT      => my_address,
      UNIQUE_ID_OUT       => mc_unique_id,
      TIMER_TICKS_OUT     => timer_ticks,
      EXTERNAL_SEND_RESET => reset_via_gbe,

      REGIO_ADDR_OUT         => regio_addr_out,
      REGIO_READ_ENABLE_OUT  => regio_read_enable_out,
      REGIO_WRITE_ENABLE_OUT => regio_write_enable_out,
      REGIO_DATA_OUT         => regio_data_out,
      REGIO_DATA_IN          => regio_data_in,
      REGIO_DATAREADY_IN     => regio_dataready_in,
      REGIO_NO_MORE_DATA_IN  => regio_no_more_data_in,
      REGIO_WRITE_ACK_IN     => regio_write_ack_in,
      REGIO_UNKNOWN_ADDR_IN  => regio_unknown_addr_in,
      REGIO_TIMEOUT_OUT      => regio_timeout_out,

      --Gbe Sctrl Input
      GSC_INIT_DATAREADY_IN    => gsc_init_dataready,
      GSC_INIT_DATA_IN         => gsc_init_data,
      GSC_INIT_PACKET_NUM_IN   => gsc_init_packet_num,
      GSC_INIT_READ_OUT        => gsc_init_read,
      GSC_REPLY_DATAREADY_OUT  => gsc_reply_dataready,
      GSC_REPLY_DATA_OUT       => gsc_reply_data,
      GSC_REPLY_PACKET_NUM_OUT => gsc_reply_packet_num,
      GSC_REPLY_READ_IN        => gsc_reply_read,
      GSC_BUSY_OUT             => gsc_busy,

      --status and control ports
      HUB_STAT_CHANNEL => open,
      HUB_STAT_GEN     => open,
      MPLEX_CTRL       => (others => '0'),
      MPLEX_STAT       => open,
      STAT_REGS        => open,
      STAT_CTRL_REGS   => open,

      --Fixed status and control ports
      STAT_DEBUG => open,
      CTRL_DEBUG => (others => '0')
      );

  gen_addition_ports : for i in 0 to cts_rdo_additional_ports-1 generate
    cts_rdo_additional_data(31 + i*32 downto 32*i)            <= cts_rdo_additional(i).data;
    cts_rdo_trg_status_bits_additional(31 + i*32 downto 32*i) <= cts_rdo_additional(i).statusbits;
    cts_rdo_additional_write(i)                               <= cts_rdo_additional(i).data_write;
    cts_rdo_additional_finished(i)                            <= cts_rdo_additional(i).data_finished;
  end generate;

---------------------------------------------------------------------
-- The GbE machine for blasting out data from TRBnet
---------------------------------------------------------------------

  GBE : entity work.gbe_wrapper
    generic map(
      DO_SIMULATION             => 0,
      INCLUDE_DEBUG             => 0,
      USE_INTERNAL_TRBNET_DUMMY => 0,
      USE_EXTERNAL_TRBNET_DUMMY => 0,
      RX_PATH_ENABLE            => 1,
      FIXED_SIZE_MODE           => 1,
      INCREMENTAL_MODE          => 1,
      FIXED_SIZE                => 100,
      FIXED_DELAY_MODE          => 1,
      UP_DOWN_MODE              => 0,
      UP_DOWN_LIMIT             => 100,
      FIXED_DELAY               => 100,

      NUMBER_OF_GBE_LINKS       => 4,
      LINKS_ACTIVE              => "1000",

      LINK_HAS_READOUT  => "1000",
      LINK_HAS_SLOWCTRL => "1000",
      LINK_HAS_DHCP     => "1000",
      LINK_HAS_ARP      => "1000",
      LINK_HAS_PING     => "1000",
      LINK_HAS_FWD      => "1000"
      
      )
    port map(
      CLK_SYS_IN               => clk_100_i,
      CLK_125_IN               => clk_125_i,
      RESET                    => reset_i,
      GSR_N                    => gsr_n,

      TRIGGER_IN => cts_rdo_trg_data_valid,
      
      SD_PRSNT_N_IN            => SFP_MOD0(8 downto 5),
      SD_LOS_IN                => SFP_LOS(8 downto 5),
      SD_TXDIS_OUT             => SFP_TXDIS(8 downto 5),
           
      CTS_NUMBER_IN            => gbe_cts_number,          
      CTS_CODE_IN              => gbe_cts_code,            
      CTS_INFORMATION_IN       => gbe_cts_information,     
      CTS_READOUT_TYPE_IN      => gbe_cts_readout_type,    
      CTS_START_READOUT_IN     => gbe_cts_start_readout,   
      CTS_DATA_OUT             => open,                    
      CTS_DATAREADY_OUT        => open,                    
      CTS_READOUT_FINISHED_OUT => gbe_cts_readout_finished,
      CTS_READ_IN              => '1',                     
      CTS_LENGTH_OUT           => open,                    
      CTS_ERROR_PATTERN_OUT    => gbe_cts_status_bits,     
      
      FEE_DATA_IN              => gbe_fee_data,       
      FEE_DATAREADY_IN         => gbe_fee_dataready,  
      FEE_READ_OUT             => gbe_fee_read,       
      FEE_STATUS_BITS_IN       => gbe_fee_status_bits,
      FEE_BUSY_IN              => gbe_fee_busy,       
      
      MC_UNIQUE_ID_IN          => mc_unique_id,  
      MY_TRBNET_ADDRESS_IN => my_address,
      ISSUE_REBOOT_OUT => reboot_from_gbe,
      
      GSC_CLK_IN               => clk_100_i,            
      GSC_INIT_DATAREADY_OUT   => gsc_init_dataready,   
      GSC_INIT_DATA_OUT        => gsc_init_data,        
      GSC_INIT_PACKET_NUM_OUT  => gsc_init_packet_num,  
      GSC_INIT_READ_IN         => gsc_init_read,        
      GSC_REPLY_DATAREADY_IN   => gsc_reply_dataready,  
      GSC_REPLY_DATA_IN        => gsc_reply_data,       
      GSC_REPLY_PACKET_NUM_IN  => gsc_reply_packet_num, 
      GSC_REPLY_READ_OUT       => gsc_reply_read,       
      GSC_BUSY_IN              => gsc_busy,
      
      BUS_IP_RX  => busgbeip_rx,
      BUS_IP_TX  => busgbeip_tx,
      BUS_REG_RX => busgbereg_rx,
      BUS_REG_TX => busgbereg_tx,

--       FWD_DST_MAC_IN => fwd_mac,
--       FWD_DST_IP_IN => fwd_ip,
--       FWD_DST_UDP_IN => fwd_udp,
--       FWD_DATA_IN => fwd_data,
--       FWD_DATA_VALID_IN => fwd_dv,
--       FWD_SOP_IN => fwd_sop,
--       FWD_EOP_IN => fwd_eop,
--       FWD_READY_OUT => fwd_ready,
--       FWD_FULL_OUT => fwd_full,
      
      MAKE_RESET_OUT           => reset_via_gbe,

      DEBUG_OUT                => open
      ); 



-- process(clk_100_i)
-- begin
--    if rising_edge(clk_100_i) then
--       if (reset_i = '1') then
--          fwd_data <= (others => '0');
--       else
--          fwd_data <= fwd_data + x"1";
--       end if;
--    end if;
-- end process;
-- 
-- process(clk_100_i)
-- begin
--    if rising_edge(clk_100_i) then
--       if (fwd_data(23 downto 0) = x"100000") then
--          fwd_sop <= x"f";
--          fwd_eop <= x"0";
--          fwd_dv <= x"f";
--       elsif (fwd_data(23 downto 0) > x"100000" and fwd_data(23 downto 0) < x"100064") then
--          fwd_sop <= x"0";
--          fwd_eop <= x"0";
--          fwd_dv <= x"f";
--       elsif (fwd_data(23 downto 0) = x"100064") then
--          fwd_sop <= x"0";
--          fwd_eop <= x"f";
--          fwd_dv <= x"f";
--       else
--          fwd_sop <= x"0";
--          fwd_eop <= x"0";
--          fwd_dv <= x"0";
--       end if;
--    end if;
-- end process;


-- 
--   GBE : trb_net16_gbe_buf
--     generic map (
--       DO_SIMULATION     => c_NO,
--       USE_125MHZ_EXTCLK => c_NO
--       )
--     port map (
--       CLK                      => clk_100_i,
--       TEST_CLK                 => '0',
--       CLK_125_IN               => clk_125_i,
--       RESET                    => reset_i,
--       GSR_N                    => gsr_n,
--       --Debug
--       STAGE_STAT_REGS_OUT      => open,  --stage_stat_regs, -- should be come STATUS or similar
--       STAGE_CTRL_REGS_IN       => stage_ctrl_regs,      -- OBSELETE!
--       ----gk 22.04.10 not used any more, ip_configurator moved inside
--       ---configuration interface
--       IP_CFG_START_IN          => stage_ctrl_regs(15),
--       IP_CFG_BANK_SEL_IN       => stage_ctrl_regs(11 downto 8),
--       IP_CFG_DONE_OUT          => open,
--       IP_CFG_MEM_ADDR_OUT      => ip_cfg_mem_addr,
--       IP_CFG_MEM_DATA_IN       => ip_cfg_mem_data,
--       IP_CFG_MEM_CLK_OUT       => ip_cfg_mem_clk,
--       MR_RESET_IN              => stage_ctrl_regs(3),
--       MR_MODE_IN               => stage_ctrl_regs(1),
--       MR_RESTART_IN            => stage_ctrl_regs(0),
--       ---gk 29.03.10
--       --interface to ip_configurator memory
--       SLV_ADDR_IN              => mb_ip_mem_addr(7 downto 0),
--       SLV_READ_IN              => mb_ip_mem_read,
--       SLV_WRITE_IN             => mb_ip_mem_write,
--       SLV_BUSY_OUT             => open,
--       SLV_ACK_OUT              => mb_ip_mem_ack,
--       SLV_DATA_IN              => mb_ip_mem_data_wr,
--       SLV_DATA_OUT             => mb_ip_mem_data_rd,
--       --gk 26.04.10
--       ---gk 22.04.10
--       ---registers setup interface
--       BUS_ADDR_IN              => gbe_stp_reg_addr(7 downto 0),  --ctrl_reg_addr(7 downto 0),
--       BUS_DATA_IN              => gbe_stp_reg_data_wr,  --stage_ctrl_regs,
--       BUS_DATA_OUT             => gbe_stp_reg_data_rd,
--       BUS_WRITE_EN_IN          => gbe_stp_reg_write,
--       BUS_READ_EN_IN           => gbe_stp_reg_read,
--       BUS_ACK_OUT              => gbe_stp_reg_ack,
--       --gk 23.04.10
--       LED_PACKET_SENT_OUT      => open,        --buf_SFP_LED_ORANGE(17),
--       LED_AN_DONE_N_OUT        => link_ok,     --buf_SFP_LED_GREEN(17),
--       --CTS interface
--       CTS_NUMBER_IN            => gbe_cts_number,
--       CTS_CODE_IN              => gbe_cts_code,
--       CTS_INFORMATION_IN       => gbe_cts_information,
--       CTS_READOUT_TYPE_IN      => gbe_cts_readout_type,
--       CTS_START_READOUT_IN     => gbe_cts_start_readout,
--       CTS_DATA_OUT             => open,
--       CTS_DATAREADY_OUT        => open,
--       CTS_READOUT_FINISHED_OUT => gbe_cts_readout_finished,
--       CTS_READ_IN              => '1',
--       CTS_LENGTH_OUT           => open,
--       CTS_ERROR_PATTERN_OUT    => gbe_cts_status_bits,
--       --Data payload interface
--       FEE_DATA_IN              => gbe_fee_data,
--       FEE_DATAREADY_IN         => gbe_fee_dataready,
--       FEE_READ_OUT             => gbe_fee_read,
--       FEE_STATUS_BITS_IN       => gbe_fee_status_bits,
--       FEE_BUSY_IN              => gbe_fee_busy,
--       --SFP   Connection
--       SFP_RXD_P_IN             => SFP_RX_P(9),  --these ports are don't care
--       SFP_RXD_N_IN             => SFP_RX_N(9),
--       SFP_TXD_P_OUT            => SFP_TX_P(9),
--       SFP_TXD_N_OUT            => SFP_TX_N(9),
--       SFP_REFCLK_P_IN          => open,        --SFP_REFCLKP(2),
--       SFP_REFCLK_N_IN          => open,        --SFP_REFCLKN(2),
--       SFP_PRSNT_N_IN           => SFP_MOD0(8),  -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
--       SFP_LOS_IN               => SFP_LOS(8),  -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
--       SFP_TXDIS_OUT            => SFP_TXDIS(8),         -- SFP disable
-- 
--       -- interface between main_controller and hub logic
--       MC_UNIQUE_ID_IN         => mc_unique_id,
--       GSC_CLK_IN              => clk_100_i,
--       GSC_INIT_DATAREADY_OUT  => gsc_init_dataready,
--       GSC_INIT_DATA_OUT       => gsc_init_data,
--       GSC_INIT_PACKET_NUM_OUT => gsc_init_packet_num,
--       GSC_INIT_READ_IN        => gsc_init_read,
--       GSC_REPLY_DATAREADY_IN  => gsc_reply_dataready,
--       GSC_REPLY_DATA_IN       => gsc_reply_data,
--       GSC_REPLY_PACKET_NUM_IN => gsc_reply_packet_num,
--       GSC_REPLY_READ_OUT      => gsc_reply_read,
--       GSC_BUSY_IN             => gsc_busy,
-- 
--       MAKE_RESET_OUT => reset_via_gbe,
-- 
--       --for simulation of receiving part only
--       MAC_RX_EOF_IN => '0',
--       MAC_RXD_IN    => "00000000",
--       MAC_RX_EN_IN  => '0',
-- 
--       ANALYZER_DEBUG_OUT => debug
--       );


---------------------------------------------------------------------------
-- Bus Handler
---------------------------------------------------------------------------
  THE_BUS_HANDLER : trb_net16_regio_bus_handler
    generic map(
      PORT_NUMBER                         => 14,
      PORT_ADDRESSES                      => (0 => x"d000", 1 => x"d100", 2 => x"8100", 3 => x"8300", 4 => x"a000",
                                       5  => x"d300", 6 => x"c000", 7 => x"c100", 8 => x"c200", 9 => x"c300",
                                       10 => x"c800", 11 => x"a800", 12 => x"d200", others => x"0000"),
      PORT_ADDR_MASK                      => (0 => 1, 1 => 6, 2 => 8, 3 => 8, 4 => 11,
                                       5  => 2, 6 => 7, 7 => 5, 8 => 7, 9 => 7,
                                       10 => 3, 11 => 9, 12 => 2, others => 0)
      )
    port map(
      CLK   => clk_100_i,
      RESET => reset_i,

      DAT_ADDR_IN          => handler_addr,
      DAT_DATA_IN          => handler_data_out,
      DAT_DATA_OUT         => regio_data_in,
      DAT_READ_ENABLE_IN   => handler_read,
      DAT_WRITE_ENABLE_IN  => handler_write,
      DAT_TIMEOUT_IN       => regio_timeout_out,
      DAT_DATAREADY_OUT    => regio_dataready_in,
      DAT_WRITE_ACK_OUT    => regio_write_ack_in,
      DAT_NO_MORE_DATA_OUT => regio_no_more_data_in,
      DAT_UNKNOWN_ADDR_OUT => regio_unknown_addr_in,

      --Bus Handler (SPI CTRL)
      BUS_READ_ENABLE_OUT(0)              => spictrl_read_en,
      BUS_WRITE_ENABLE_OUT(0)             => spictrl_write_en,
      BUS_DATA_OUT(0*32+31 downto 0*32)   => spictrl_data_in,
      BUS_ADDR_OUT(0*16)                  => spictrl_addr,
      BUS_ADDR_OUT(0*16+15 downto 0*16+1) => open,
      BUS_TIMEOUT_OUT(0)                  => open,
      BUS_DATA_IN(0*32+31 downto 0*32)    => spictrl_data_out,
      BUS_DATAREADY_IN(0)                 => spictrl_ack,
      BUS_WRITE_ACK_IN(0)                 => spictrl_ack,
      BUS_NO_MORE_DATA_IN(0)              => spictrl_busy,
      BUS_UNKNOWN_ADDR_IN(0)              => '0',

      --Bus Handler (SPI Memory)
      BUS_READ_ENABLE_OUT(1)              => spimem_read_en,
      BUS_WRITE_ENABLE_OUT(1)             => spimem_write_en,
      BUS_DATA_OUT(1*32+31 downto 1*32)   => spimem_data_in,
      BUS_ADDR_OUT(1*16+5 downto 1*16)    => spimem_addr,
      BUS_ADDR_OUT(1*16+15 downto 1*16+6) => open,
      BUS_TIMEOUT_OUT(1)                  => open,
      BUS_DATA_IN(1*32+31 downto 1*32)    => spimem_data_out,
      BUS_DATAREADY_IN(1)                 => spimem_ack,
      BUS_WRITE_ACK_IN(1)                 => spimem_ack,
      BUS_NO_MORE_DATA_IN(1)              => '0',
      BUS_UNKNOWN_ADDR_IN(1)              => '0',

      -- third one - IP config memory
      BUS_ADDR_OUT(2*16+7 downto 2*16) => busgbeip_rx.addr(7 downto 0),
      BUS_DATA_OUT(3*32-1 downto 2*32) => busgbeip_rx.data,
      BUS_READ_ENABLE_OUT(2)           => busgbeip_rx.read,
      BUS_WRITE_ENABLE_OUT(2)          => busgbeip_rx.write,
      BUS_TIMEOUT_OUT(2)               => open,
      BUS_DATA_IN(3*32-1 downto 2*32)  => busgbeip_tx.data,
      BUS_DATAREADY_IN(2)              => busgbeip_tx.ack,
      BUS_WRITE_ACK_IN(2)              => busgbeip_tx.ack,
      BUS_NO_MORE_DATA_IN(2)           => busgbeip_tx.nack,
      BUS_UNKNOWN_ADDR_IN(2)           => busgbeip_tx.unknown,

      -- gk 22.04.10
      -- gbe setup
      BUS_ADDR_OUT(3*16+7 downto 3*16) => busgbereg_rx.addr(7 downto 0),
      BUS_DATA_OUT(4*32-1 downto 3*32) => busgbereg_rx.data,
      BUS_READ_ENABLE_OUT(3)           => busgbereg_rx.read,
      BUS_WRITE_ENABLE_OUT(3)          => busgbereg_rx.write,
      BUS_TIMEOUT_OUT(3)               => open,
      BUS_DATA_IN(4*32-1 downto 3*32)  => busgbereg_tx.data,
      BUS_DATAREADY_IN(3)              => busgbereg_tx.ack,
      BUS_WRITE_ACK_IN(3)              => busgbereg_tx.ack,
      BUS_NO_MORE_DATA_IN(3)           => busgbereg_tx.nack,
      BUS_UNKNOWN_ADDR_IN(3)           => busgbereg_tx.unknown,

      -- CTS
      BUS_ADDR_OUT(4*16+10 downto 4*16) => cts_regio_addr(10 downto 0),
      BUS_DATA_OUT(5*32-1 downto 4*32) => cts_regio_data_out,
      BUS_READ_ENABLE_OUT(4)           => cts_regio_read,
      BUS_WRITE_ENABLE_OUT(4)          => cts_regio_write,
      BUS_TIMEOUT_OUT(4)               => open,
      BUS_DATA_IN(5*32-1 downto 4*32)  => cts_regio_data_in,
      BUS_DATAREADY_IN(4)              => cts_regio_dataready,
      BUS_WRITE_ACK_IN(4)              => cts_regio_write_ack,
      BUS_NO_MORE_DATA_IN(4)           => '0',
      BUS_UNKNOWN_ADDR_IN(4)           => cts_regio_unknown_addr,

      -- Trigger and Clock Manager Settings
      BUS_ADDR_OUT(6*16-1 downto 5*16) => bustc_rx.addr,
      BUS_DATA_OUT(6*32-1 downto 5*32) => bustc_rx.data,
      BUS_READ_ENABLE_OUT(5)           => bustc_rx.read,
      BUS_WRITE_ENABLE_OUT(5)          => bustc_rx.write,
      BUS_TIMEOUT_OUT(5)               => open,
      BUS_DATA_IN(6*32-1 downto 5*32)  => bustc_tx.data,
      BUS_DATAREADY_IN(5)              => bustc_tx.ack,
      BUS_WRITE_ACK_IN(5)              => bustc_tx.ack,
      BUS_NO_MORE_DATA_IN(5)           => bustc_tx.nack,
      BUS_UNKNOWN_ADDR_IN(5)           => bustc_tx.unknown,   

      --HitRegisters
      BUS_READ_ENABLE_OUT(6)              => hitreg_read_en,
      BUS_WRITE_ENABLE_OUT(6)             => hitreg_write_en,
      BUS_DATA_OUT(6*32+31 downto 6*32)   => open,
      BUS_ADDR_OUT(6*16+6 downto 6*16)    => hitreg_addr,
      BUS_ADDR_OUT(6*16+15 downto 6*16+7) => open,
      BUS_TIMEOUT_OUT(6)                  => open,
      BUS_DATA_IN(6*32+31 downto 6*32)    => hitreg_data_out,
      BUS_DATAREADY_IN(6)                 => hitreg_data_ready,
      BUS_WRITE_ACK_IN(6)                 => '0',
      BUS_NO_MORE_DATA_IN(6)              => '0',
      BUS_UNKNOWN_ADDR_IN(6)              => hitreg_invalid,

      --Status Registers
      BUS_READ_ENABLE_OUT(7)              => srb_read_en,
      BUS_WRITE_ENABLE_OUT(7)             => srb_write_en,
      BUS_DATA_OUT(7*32+31 downto 7*32)   => open,
      BUS_ADDR_OUT(7*16+6 downto 7*16)    => srb_addr,
      BUS_ADDR_OUT(7*16+15 downto 7*16+7) => open,
      BUS_TIMEOUT_OUT(7)                  => open,
      BUS_DATA_IN(7*32+31 downto 7*32)    => srb_data_out,
      BUS_DATAREADY_IN(7)                 => srb_data_ready,
      BUS_WRITE_ACK_IN(7)                 => '0',
      BUS_NO_MORE_DATA_IN(7)              => '0',
      BUS_UNKNOWN_ADDR_IN(7)              => srb_invalid,

      --Encoder Start Registers
      BUS_READ_ENABLE_OUT(8)              => esb_read_en,
      BUS_WRITE_ENABLE_OUT(8)             => esb_write_en,
      BUS_DATA_OUT(8*32+31 downto 8*32)   => open,
      BUS_ADDR_OUT(8*16+6 downto 8*16)    => esb_addr,
      BUS_ADDR_OUT(8*16+15 downto 8*16+7) => open,
      BUS_TIMEOUT_OUT(8)                  => open,
      BUS_DATA_IN(8*32+31 downto 8*32)    => esb_data_out,
      BUS_DATAREADY_IN(8)                 => esb_data_ready,
      BUS_WRITE_ACK_IN(8)                 => '0',
      BUS_NO_MORE_DATA_IN(8)              => '0',
      BUS_UNKNOWN_ADDR_IN(8)              => esb_invalid,

      --Fifo Write Registers
      BUS_READ_ENABLE_OUT(9)              => fwb_read_en,
      BUS_WRITE_ENABLE_OUT(9)             => fwb_write_en,
      BUS_DATA_OUT(9*32+31 downto 9*32)   => open,
      BUS_ADDR_OUT(9*16+6 downto 9*16)    => fwb_addr,
      BUS_ADDR_OUT(9*16+15 downto 9*16+7) => open,
      BUS_TIMEOUT_OUT(9)                  => open,
      BUS_DATA_IN(9*32+31 downto 9*32)    => fwb_data_out,
      BUS_DATAREADY_IN(9)                 => fwb_data_ready,
      BUS_WRITE_ACK_IN(9)                 => '0',
      BUS_NO_MORE_DATA_IN(9)              => '0',
      BUS_UNKNOWN_ADDR_IN(9)              => fwb_invalid,

      --TDC config registers
      BUS_READ_ENABLE_OUT(10)               => tdc_ctrl_read,
      BUS_WRITE_ENABLE_OUT(10)              => tdc_ctrl_write,
      BUS_DATA_OUT(10*32+31 downto 10*32)   => tdc_ctrl_data_in,
      BUS_ADDR_OUT(10*16+2 downto 10*16)    => tdc_ctrl_addr,
      BUS_ADDR_OUT(10*16+15 downto 10*16+3) => open,
      BUS_TIMEOUT_OUT(10)                   => open,
      BUS_DATA_IN(10*32+31 downto 10*32)    => tdc_ctrl_data_out,
      BUS_DATAREADY_IN(10)                  => last_tdc_ctrl_read,
      BUS_WRITE_ACK_IN(10)                  => tdc_ctrl_write,
      BUS_NO_MORE_DATA_IN(10)               => '0',
      BUS_UNKNOWN_ADDR_IN(10)               => '0',

      BUS_READ_ENABLE_OUT(11)             => cbm_regio_rx.read,
      BUS_WRITE_ENABLE_OUT(11)            => cbm_regio_rx.write,
      BUS_DATA_OUT(11*32+31 downto 11*32) => cbm_regio_rx.data,
      BUS_ADDR_OUT(11*16+15 downto 11*16) => cbm_regio_rx.addr,
      BUS_TIMEOUT_OUT(11)                 => cbm_regio_rx.timeout,
      BUS_DATA_IN(11*32+31 downto 11*32)  => cbm_regio_tx.data,
      BUS_DATAREADY_IN(11)                => cbm_regio_tx.ack,
      BUS_WRITE_ACK_IN(11)                => cbm_regio_tx.ack,
      BUS_NO_MORE_DATA_IN(11)             => cbm_regio_tx.nack,
      BUS_UNKNOWN_ADDR_IN(11)             => cbm_regio_tx.unknown,

      --SFP DDM config registers
      BUS_READ_ENABLE_OUT(12)               => sfp_ddm_ctrl_read,
      BUS_WRITE_ENABLE_OUT(12)              => sfp_ddm_ctrl_write,
      BUS_DATA_OUT(12*32+31 downto 12*32)   => sfp_ddm_ctrl_data_in,
      BUS_ADDR_OUT(12*16+1 downto 12*16)    => sfp_ddm_ctrl_addr,
      BUS_ADDR_OUT(12*16+15 downto 12*16+3) => open,
      BUS_TIMEOUT_OUT(12)                   => open,
      BUS_DATA_IN(12*32+31 downto 12*32)    => sfp_ddm_ctrl_data_out,
      BUS_DATAREADY_IN(12)                  => last_sfp_ddm_ctrl_read,
      BUS_WRITE_ACK_IN(12)                  => sfp_ddm_ctrl_write,
      BUS_NO_MORE_DATA_IN(12)               => '0',
      BUS_UNKNOWN_ADDR_IN(12)               => '0',

      STAT_DEBUG => open
      );
cts_regio_addr(15 downto 11) <= (others => '0');

---------------------------------------------------------------------------
-- SPI / Flash
---------------------------------------------------------------------------
  THE_SPI_MASTER : spi_master
    port map(
      CLK_IN         => clk_100_i,
      RESET_IN       => reset_i,
      -- Slave bus
      BUS_READ_IN    => spictrl_read_en,
      BUS_WRITE_IN   => spictrl_write_en,
      BUS_BUSY_OUT   => spictrl_busy,
      BUS_ACK_OUT    => spictrl_ack,
      BUS_ADDR_IN(0) => spictrl_addr,
      BUS_DATA_IN    => spictrl_data_in,
      BUS_DATA_OUT   => spictrl_data_out,
      -- SPI connections
      SPI_CS_OUT     => FLASH_CS,
      SPI_SDI_IN     => FLASH_DOUT,
      SPI_SDO_OUT    => FLASH_DIN,
      SPI_SCK_OUT    => FLASH_CLK,
      -- BRAM for read/write data
      BRAM_A_OUT     => spi_bram_addr,
      BRAM_WR_D_IN   => spi_bram_wr_d,
      BRAM_RD_D_OUT  => spi_bram_rd_d,
      BRAM_WE_OUT    => spi_bram_we,
      -- Status lines
      STAT           => open
      );

  -- data memory for SPI accesses
  THE_SPI_MEMORY : spi_databus_memory
    port map(
      CLK_IN        => clk_100_i,
      RESET_IN      => reset_i,
      -- Slave bus
      BUS_ADDR_IN   => spimem_addr,
      BUS_READ_IN   => spimem_read_en,
      BUS_WRITE_IN  => spimem_write_en,
      BUS_ACK_OUT   => spimem_ack,
      BUS_DATA_IN   => spimem_data_in,
      BUS_DATA_OUT  => spimem_data_out,
      -- state machine connections
      BRAM_ADDR_IN  => spi_bram_addr,
      BRAM_WR_D_OUT => spi_bram_wr_d,
      BRAM_RD_D_IN  => spi_bram_rd_d,
      BRAM_WE_IN    => spi_bram_we,
      -- Status lines
      STAT          => open
      );

---------------------------------------------------------------------------
-- Reboot FPGA
---------------------------------------------------------------------------
  THE_FPGA_REBOOT : fpga_reboot
    port map(
      CLK       => clk_100_i,
      RESET     => reset_i,
      DO_REBOOT => do_reboot_i,
      PROGRAMN  => PROGRAMN
      );

  do_reboot_i <= common_ctrl_regs(15) or reboot_from_gbe;  -- or killswitch_reboot_i;

  -- if jttl(15) is stabily high for 1.28us: issue reboot
  THE_KILLSWITCH_PROC : process
    variable stab_counter   : unsigned(7 downto 0);
    variable inp, inp_delay : std_logic := '0';
  begin
    wait until rising_edge(clk_100_i);

    if inp_delay = inp then
      stab_counter := stab_counter + 1;
    else
      stab_counter := 0;
    end if;

    inp_delay           := inp;
    inp                 := JTTL(15);
    killswitch_reboot_i <= stab_counter(stab_counter'high) and inp;
  end process;

-------------------------------------------------------------------------------
-- TDC
-------------------------------------------------------------------------------
   GEN_TDC : if INCLUDE_TDC = c_YES generate
   -- generates hits for calibration uncorrelated with tdc clk
   -- also used for the trigger and clock selection procoess
      OSCInst0 : OSCF  -- internal oscillator with frequency of 2.5MHz
      port map (
         OSC => osc_int
      );
   
      THE_TDC : TDC
      generic map (
        CHANNEL_NUMBER => TDC_CHANNEL_NUMBER,     -- Number of TDC channels
        STATUS_REG_NR  => 21,           -- Number of status regs
        CONTROL_REG_NR => 8,  -- Number of control regs - higher than 8 check tdc_ctrl_addr
        DEBUG          => c_NO
        )
      port map (
        RESET                 => reset_i,
        CLK_TDC               => CLK_PCLK_RIGHT,  -- Clock used for the time measurement
        CLK_READOUT           => clk_100_i,  -- Clock for the readout
        REFERENCE_TIME        => cts_trigger_out,   -- Reference time input
        HIT_IN                => tdc_inputs,      -- Channel start signals
        HIT_CAL_IN            => osc_int,  --clk_20_i,    -- Hits for calibrating the TDC
        TRG_WIN_PRE           => tdc_ctrl_reg(42 downto 32),  -- Pre-Trigger window width
        TRG_WIN_POST          => tdc_ctrl_reg(58 downto 48),  -- Post-Trigger window width
        --
        -- Trigger signals from handler
        TRG_DATA_VALID_IN     => cts_rdo_trg_data_valid,  -- trig data valid signal from trbnet
        VALID_TIMING_TRG_IN   => cts_rdo_valid_timing_trg,  -- valid timing trigger signal from trbnet
        VALID_NOTIMING_TRG_IN => cts_rdo_valid_notiming_trg,  -- valid notiming signal from trbnet
        INVALID_TRG_IN        => cts_rdo_invalid_trg,  -- invalid trigger signal from trbnet
        TMGTRG_TIMEOUT_IN     => '0',  -- timing trigger timeout signal from trbnet
        SPIKE_DETECTED_IN     => '0',
        MULTI_TMG_TRG_IN      => '0',
        SPURIOUS_TRG_IN       => '0',
        --
        TRG_NUMBER_IN         => cts_rdo_trg_number,  -- LVL1 trigger information package
        TRG_CODE_IN           => cts_rdo_trg_code,  --
        TRG_INFORMATION_IN    => cts_rdo_trg_information,   --
        TRG_TYPE_IN           => cts_rdo_trg_type,  -- LVL1 trigger information package
        --Response to handler
        --       TRG_RELEASE_OUT       => fee_trg_release_i,   -- trigger release signal
        TRG_RELEASE_OUT       => open,
        TRG_STATUSBIT_OUT     => cts_rdo_additional(1+INCLUDE_CBMNET).statusbits,
        DATA_OUT              => cts_rdo_additional(1+INCLUDE_CBMNET).data,
        DATA_WRITE_OUT        => cts_rdo_additional(1+INCLUDE_CBMNET).data_write,
        DATA_FINISHED_OUT     => cts_rdo_additional(1+INCLUDE_CBMNET).data_finished,
        --Hit Counter Bus
        HCB_READ_EN_IN        => hitreg_read_en,  -- bus read en strobe
        HCB_WRITE_EN_IN       => hitreg_write_en,   -- bus write en strobe
        HCB_ADDR_IN           => hitreg_addr,     -- bus address
        HCB_DATA_OUT          => hitreg_data_out,   -- bus data
        HCB_DATAREADY_OUT     => hitreg_data_ready,   -- bus data ready strobe
        HCB_UNKNOWN_ADDR_OUT  => hitreg_invalid,  -- bus invalid addr
        --Status Registers Bus
        SRB_READ_EN_IN        => srb_read_en,     -- bus read en strobe
        SRB_WRITE_EN_IN       => srb_write_en,    -- bus write en strobe
        SRB_ADDR_IN           => srb_addr,   -- bus address
        SRB_DATA_OUT          => srb_data_out,    -- bus data
        SRB_DATAREADY_OUT     => srb_data_ready,  -- bus data ready strobe
        SRB_UNKNOWN_ADDR_OUT  => srb_invalid,     -- bus invalid addr
        --Encoder Start Registers Bus
        ESB_READ_EN_IN        => esb_read_en,     -- bus read en strobe
        ESB_WRITE_EN_IN       => esb_write_en,    -- bus write en strobe
        ESB_ADDR_IN           => esb_addr,   -- bus address
        ESB_DATA_OUT          => esb_data_out,    -- bus data
        ESB_DATAREADY_OUT     => esb_data_ready,  -- bus data ready strobe
        ESB_UNKNOWN_ADDR_OUT  => esb_invalid,     -- bus invalid addr
        --Fifo Write Registers Bus
        EFB_READ_EN_IN        => fwb_read_en,     -- bus read en strobe
        EFB_WRITE_EN_IN       => fwb_write_en,    -- bus write en strobe
        EFB_ADDR_IN           => fwb_addr,   -- bus address
        EFB_DATA_OUT          => fwb_data_out,    -- bus data
        EFB_DATAREADY_OUT     => fwb_data_ready,  -- bus data ready strobe
        EFB_UNKNOWN_ADDR_OUT  => fwb_invalid,     -- bus invalid addr
        --Lost Hit Registers Bus
        LHB_READ_EN_IN        => '0',  -- lhb_read_en,   -- bus read en strobe
        LHB_WRITE_EN_IN       => '0',  -- lhb_write_en,  -- bus write en strobe
        LHB_ADDR_IN           => (others => '0'),  -- lhb_addr,    -- bus address
        LHB_DATA_OUT          => open,  -- lhb_data_out,  -- bus data
        LHB_DATAREADY_OUT     => open,  -- lhb_data_ready,    -- bus data ready strobe
        LHB_UNKNOWN_ADDR_OUT  => open,  -- lhb_invalid,   -- bus invalid addr
        -- Channel Debug
        CDB_READ_EN_IN        => '0',   -- in  std_logic;
        CDB_WRITE_EN_IN       => '1',   -- in  std_logic;
        CDB_ADDR_IN           => "0000000",  -- in  std_logic_vector(6 downto 0);
        CDB_DATA_OUT          => open,  -- out std_logic_vector(31 downto 0);
        CDB_DATAREADY_OUT     => open,  -- out std_logic;
        CDB_UNKNOWN_ADDR_OUT  => open,  -- out std_logic;
        --
        LOGIC_ANALYSER_OUT    => tdc_debug,
        CONTROL_REG_IN        => tdc_ctrl_reg
        );

    --tdc_inputs(1) used by CBM-MBS ETM
    tdc_inputs(2) <= cbm_sync_pulser_i;
    tdc_inputs(3) <= cbm_sync_timing_trigger_i;
    tdc_inputs(4) <= JINLVDS(0);        --NIM_IN(0);
    --JTTL(0 downto 15) <= (others => '0');


    PROC_TDC_CTRL_REG : process
      variable pos : integer;
    begin
      wait until rising_edge(clk_100_i);
      pos                := to_integer(unsigned(tdc_ctrl_addr))*32;
      tdc_ctrl_data_out  <= tdc_ctrl_reg(pos+31 downto pos);
      last_tdc_ctrl_read <= tdc_ctrl_read;
      if tdc_ctrl_write = '1' then
        tdc_ctrl_reg(pos+31 downto pos) <= tdc_ctrl_data_in;
      end if;
    end process;
  end generate;

  GEN_NO_TDC : if INCLUDE_TDC = c_NO generate
    srb_data_ready    <= '0';
    esb_data_ready    <= '0';
    fwb_data_ready    <= '0';
    hitreg_data_ready <= '0';
    process
    begin
      wait until rising_edge(clk_100_i);
      srb_invalid    <= srb_read_en or srb_write_en;
      esb_invalid    <= esb_read_en or esb_write_en;
      fwb_invalid    <= fwb_read_en or fwb_write_en;
      hitreg_invalid <= hitreg_read_en or hitreg_write_en;
    end process;

  end generate;

  GEN_MBS_MASTER : if INCLUDE_MBS_MASTER = c_YES generate
    THE_MBS_MASTER : entity work.mbs_master 
      port map(
        CLK               => clk_100_i,
        RESET_IN          => reset_i,
        
        MBS_CLOCK_OUT     => mbs_clock_i,
        MBS_DATA_OUT      => mbs_data_i,
      
        TRIGGER_IN        => cts_rdo_trg_data_valid,
        TRIGGER_NUMBER_IN => cts_rdo_trg_number,
        DATA_OUT          => cts_rdo_additional(INCLUDE_ETM).data,   
        WRITE_OUT         => cts_rdo_additional(INCLUDE_ETM).data_write,   
        FINISHED_OUT      => cts_rdo_additional(INCLUDE_ETM).data_finished,   
        STATUSBIT_OUT     => cts_rdo_additional(INCLUDE_ETM).statusbits 
        );
    CLK_TEST_OUT(0) <= mbs_data_i;
    CLK_TEST_OUT(1) <= mbs_clock_i;
  end generate;
  
--   GEN_TIMESTAMP : if INCLUDE_TIMESTAMP_GENERATOR = c_YES generate
--     THE_TIMESTAMP : entity work.timestamp_generator 
--       port map(
--         CLK               => clk_100_i,
--         RESET_IN          => reset_i,
--         
--         TIMER_CLOCK_IN    => CLK_EXT(3), 
--         TIMER_RESET_IN    => CLK_EXT(4), 
--         
--         BUSRDO_RX          => cts_rdo_rx,
--         BUSRDO_TX          => cts_rdo_additional(INCLUDE_ETM)
--         );
--   end generate;
assert (INCLUDE_TIMESTAMP_GENERATOR = c_NO) report "timestamp generator currently not available." severity error;
  
-------------------------------------------------------------------------------
-- SFP POWER Entity
-------------------------------------------------------------------------------
--   Generate_Sfp_DDM : if INCLUDE_SFP_DDM = c_YES generate
--     SFP_DDM_1 : entity work.SFP_DDM
--       port map (
--         CLK100       => clk_100_i,
--         SLOW_CTRL_IN => sfp_ddm_ctrl_reg(31 downto 0),
--         DATA_OUT     => sfp_ddm_ctrl_reg(32*4-1 downto 32),
--         SCL_EXT      => SFP_MOD1,
--         SDA_EXT      => SFP_MOD2
--         );
-- 
--     PROC_SFP_DDM_CTRL_REG : process
--       variable pos : integer;
--     begin
--       wait until rising_edge(clk_100_i);
--       pos                    := to_integer(unsigned(sfp_ddm_ctrl_addr))*32;
--       sfp_ddm_ctrl_data_out  <= sfp_ddm_ctrl_reg(pos+31 downto pos);
--       last_sfp_ddm_ctrl_read <= sfp_ddm_ctrl_read;
--       if sfp_ddm_ctrl_write = '1' and to_integer(unsigned(sfp_ddm_ctrl_addr)) = 0 then
--         --sfp_ddm_ctrl_reg(pos+31 downto pos) <= sfp_ddm_ctrl_data_in;
--         sfp_ddm_ctrl_reg(31 downto 0) <= sfp_ddm_ctrl_data_in;
--       end if;
--     end process;
-- 
-- 
--     
--   end generate Generate_Sfp_DDM;



---------------------------------------------------------------------------
-- Clock and Trigger Configuration
---------------------------------------------------------------------------
-- 
--    THE_TRIGGER_CLOCK_MGR: trigger_clock_manager
--    port map (
--       TRB_CLK_IN => clk_100_i, --  in std_logic;
--       INT_CLK_IN => osc_int, --  in std_logic;  -- dont care which clock, but not faster than TRB_CLK_IN
--       RESET_IN   => reset_i, --  in std_logic;
-- 
--       -- only single register, so no address
--       REGIO_ADDRESS_IN        => select_tc_address_i(1 downto 0),
--       REGIO_DATA_IN           => select_tc_control_data_i, --  in  std_logic_vector(31 downto 0);
--       REGIO_READ_ENABLE_IN    => select_tc_read_en_i, --  in  std_logic;
--       REGIO_WRITE_ENABLE_IN   => select_tc_write_en_i, --  in  std_logic;
--       REGIO_DATA_OUT          => select_tc_status_data_i, --  out std_logic_vector(31 downto 0);
--       REGIO_DATAREADY_OUT     => select_tc_read_ack_i, --  out std_logic;
--       REGIO_WRITE_ACK_OUT     => select_tc_write_ack_i, --  out std_logic;
--       REGIO_UNKNOWN_ADDRESS_OUT  => select_tc_unknown_addr_i,
--       
--       RESET_OUT               => select_tc_reset_i, --  out std_logic;
--       TC_SELECT_OUT           => select_tc_i --  out std_logic_vector(31 downto 0)
--    );

--    TRIGGER_SELECT <= '1';
--    CLOCK_SELECT   <= '1' when USE_EXTERNAL_CLOCK = c_YES else '0'; --use on-board oscillator
--    CLK_MNGR1_USER <= select_tc_i(19 downto 16);
--    CLK_MNGR2_USER <= select_tc_i(27 downto 24); 

   THE_CLOCK_SWITCH: entity work.clock_switch
   generic map(
      DEFAULT_INTERNAL_TRIGGER => c_YES
      )
   port map(
      INT_CLK_IN   => CLK_GPLL_RIGHT,
      SYS_CLK_IN   => clk_100_i,
      
      BUS_RX       => bustc_rx,
      BUS_TX       => bustc_tx,

      PLL_LOCK     => pll_lock,
      RESET_IN     => reset_i,
      RESET_OUT    => open,

      CLOCK_SELECT   => CLOCK_SELECT,
      TRIG_SELECT    => TRIGGER_SELECT,
      CLK_MNGR1_USER => CLK_MNGR1_USER,
      CLK_MNGR2_USER => CLK_MNGR2_USER,
      
      DEBUG_OUT      => open
      );



   cts_rdo_trigger <= cts_trigger_out;

   process is
   begin
      -- output time reference synchronously to the 200MHz clock
      -- in order to reduce jitter
      wait until rising_edge(clk_200_i);
      TRIGGER_OUT      <= cts_trigger_out;
      TRIGGER_OUT2     <= cts_trigger_out;
      TRG_FANOUT_ADDON <= cts_trigger_out;
   end process;

   process is
   begin
      wait until rising_edge(clk_100_i);
      if timer_ticks(0) = '1' then
         led_time_ref_i <= '0';
      else
         led_time_ref_i <= led_time_ref_i or cts_trigger_out;
      end if;
   end process;

---------------------------------------------------------------------------
-- FPGA communication
---------------------------------------------------------------------------
  --   FPGA1_COMM <= (others => 'Z');
  --   FPGA2_COMM <= (others => 'Z');
  --   FPGA3_COMM <= (others => 'Z');
  --   FPGA4_COMM <= (others => 'Z');

  FPGA1_TTL <= (others => 'Z');
  FPGA2_TTL <= (others => 'Z');
  FPGA3_TTL <= (others => 'Z');
  FPGA4_TTL <= (others => 'Z');

  FPGA1_CONNECTOR <= (others => 'Z');
  FPGA2_CONNECTOR <= (others => 'Z');
  FPGA3_CONNECTOR <= (others => 'Z');
  FPGA4_CONNECTOR <= (others => 'Z');

  gen_busy_out : if GEN_BUSY_OUTPUT = 1 generate
    TRIGGER_EXT_3 <= trigger_busy_i;
  end generate;  
  gen_no_busy_out : if GEN_BUSY_OUTPUT = 0 generate
    TRIGGER_EXT_3 <= 'Z';
  end generate;  
  
  
---------------------------------------------------------------------------
-- AddOn Connector
---------------------------------------------------------------------------
  PWM_OUT <= "00";

  --  JOUT1                          <= x"0";
  --  JOUT2                          <= x"0";
  --  JOUTLVDS                       <= x"00";
  JTTL <= (others => 'Z');

  LED_BANK(5 downto 0) <= (others => '0');
  LED_FAN_GREEN        <= led_time_ref_i;
  LED_FAN_ORANGE       <= '0';
  LED_FAN_RED          <= trigger_busy_i;
  LED_FAN_YELLOW       <= '0';


---------------------------------------------------------------------------
-- LED
---------------------------------------------------------------------------
  LED_CLOCK_GREEN <= not med_stat_op(15);
  LED_CLOCK_RED   <= not reset_via_gbe;
  --   LED_GREEN                      <= not med_stat_op(9);
  --   LED_YELLOW                     <= not med_stat_op(10);
  --   LED_ORANGE                     <= not med_stat_op(11); 
  --   LED_RED                        <= '1';


  LED_GREEN  <= debug(0);
  LED_ORANGE <= debug(1);
  LED_RED    <= debug(2) when INCLUDE_CBMNET = c_NO else cbm_link_active_i;
  LED_YELLOW <= link_ok;

  
---------------------------------------------------------------------------
-- Debugging UART
--------------------------------------------------------------------------- 
--  THE_DEBUG : entity work.debuguart
--    port map(
--      CLK => clk_100_i,
--      RESET => reset_i, 
      
--      RX_IN  => TEST_LINE(30),
--      TX_OUT => TEST_LINE(31),
      
--      DEBUG_ACTIVE  => debug_active,
    
--      BUS_DEBUG_TX  => bus_debug_tx_in,
--      BUS_DEBUG_RX  => bus_debug_rx_out,
      
--      STATUS => open
      
--      );  

  handler_addr     <= bus_debug_rx_out.addr  when debug_active = '1' else regio_addr_out;
  handler_data_out <= bus_debug_rx_out.data  when debug_active = '1' else regio_data_out;
  handler_read     <= bus_debug_rx_out.read  when debug_active = '1' else regio_read_enable_out;
  handler_write    <= bus_debug_rx_out.write when debug_active = '1' else regio_write_enable_out;

  bus_debug_tx_in.data    <= regio_data_in;
  bus_debug_tx_in.ack     <= regio_dataready_in or regio_write_ack_in ;
  bus_debug_tx_in.nack    <= regio_no_more_data_in;
  bus_debug_tx_in.unknown <= regio_unknown_addr_in;
 
 
      
---------------------------------------------------------------------------
-- Test Connector
---------------------------------------------------------------------------    
  TEST_LINE(29 downto 0) <= (others => '0');

end architecture;
