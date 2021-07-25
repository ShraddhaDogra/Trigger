library ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

use work.trb_net_std.all;

package med_sync_define is

constant K_IDLE   : std_logic_vector(7 downto 0) := x"BC";
constant D_IDLE0  : std_logic_vector(7 downto 0) := x"C5";
constant D_IDLE1  : std_logic_vector(7 downto 0) := x"50";
constant K_SOP    : std_logic_vector(7 downto 0) := x"FB";
constant K_EOP    : std_logic_vector(7 downto 0) := x"FD";
constant K_BGN    : std_logic_vector(7 downto 0) := x"1C";
constant K_REQ    : std_logic_vector(7 downto 0) := x"7C";
constant K_RST    : std_logic_vector(7 downto 0) := x"FE";
constant K_DLM    : std_logic_vector(7 downto 0) := x"DC";

component rx_control is
  port(
    CLK_200                        : in  std_logic;
    CLK_100                        : in  std_logic;
    RESET_IN                       : in  std_logic;

    RX_DATA_OUT                    : out std_logic_vector(15 downto 0);
    RX_PACKET_NUMBER_OUT           : out std_logic_vector(2 downto 0);
    RX_WRITE_OUT                   : out std_logic;

    RX_DATA_IN                     : in  std_logic_vector( 7 downto 0);
    RX_K_IN                        : in  std_logic;

    REQUEST_RETRANSMIT_OUT         : out std_logic := '0';
    REQUEST_POSITION_OUT           : out std_logic_vector( 7 downto 0) := (others => '0');

    START_RETRANSMIT_OUT           : out std_logic := '0';
    START_POSITION_OUT             : out std_logic_vector( 7 downto 0) := (others => '0');

    --send_dlm: 200 MHz, 1 clock strobe, data valid until next DLM
    RX_DLM                         : out std_logic := '0';
    RX_DLM_WORD                    : out std_logic_vector( 7 downto 0) := (others => '0');
    
    SEND_LINK_RESET_OUT            : out std_logic := '0';
    MAKE_RESET_OUT                 : out std_logic := '0';
    RX_ALLOW_IN                    : in  std_logic := '0';
    RX_RESET_FINISHED              : in  std_logic := '0';
    GOT_LINK_READY                 : out std_logic := '0';

    DEBUG_OUT                      : out std_logic_vector(31 downto 0);
    STAT_REG_OUT                   : out std_logic_vector(31 downto 0)
    );
end component;


component tx_control is
  port(
    CLK_200                        : in  std_logic;
    CLK_100                        : in  std_logic;
    RESET_IN                       : in  std_logic;

    TX_DATA_IN                     : in  std_logic_vector(15 downto 0);
    TX_PACKET_NUMBER_IN            : in  std_logic_vector( 2 downto 0);
    TX_WRITE_IN                    : in  std_logic;
    TX_READ_OUT                    : out std_logic;

    TX_DATA_OUT                    : out std_logic_vector( 7 downto 0);
    TX_K_OUT                       : out std_logic;
    TX_CD_OUT                      : out std_logic;

    REQUEST_RETRANSMIT_IN          : in  std_logic := '0';
    REQUEST_POSITION_IN            : in  std_logic_vector( 7 downto 0) := (others => '0');

    START_RETRANSMIT_IN            : in  std_logic := '0';
    START_POSITION_IN              : in  std_logic_vector( 7 downto 0) := (others => '0');

    SEND_DLM                       : in  std_logic := '0';
    SEND_DLM_WORD                  : in  std_logic_vector( 7 downto 0) := (others => '0');
    
    SEND_LINK_RESET_IN             : in  std_logic := '0';
    TX_ALLOW_IN                    : in  std_logic := '0';
    RX_ALLOW_IN                    : in  std_logic := '0';

    DEBUG_OUT                      : out std_logic_vector(31 downto 0);
    STAT_REG_OUT                   : out std_logic_vector(31 downto 0)
    );
end component;


  
component rx_reset_fsm is
  port (
    RST_N             : in std_logic;
    RX_REFCLK         : in std_logic;
    TX_PLL_LOL_QD_S   : in std_logic;
    RX_SERDES_RST_CH_C: out std_logic;
    RX_CDR_LOL_CH_S   : in std_logic;
    RX_LOS_LOW_CH_S   : in std_logic;
    RX_PCS_RST_CH_C   : out std_logic;
    --fix word alignment position to 0 for non-slave links!
    WA_POSITION       : in std_logic_vector(3 downto 0) := x"0";
    NORMAL_OPERATION_OUT : out std_logic;
    STATE_OUT         : out std_logic_vector(3 downto 0)
    );
end component;

component tx_reset_fsm is
  port (
    RST_N           : in std_logic;
    TX_REFCLK       : in std_logic;   
    TX_PLL_LOL_QD_S : in std_logic;
    RST_QD_C        : out std_logic;
    TX_PCS_RST_CH_C : out std_logic;
    NORMAL_OPERATION_OUT : out std_logic;
    STATE_OUT       : out std_logic_vector(3 downto 0)
    );
end component;


component lattice_ecp3_fifo_18x16_dualport_oreg
  port (
    Data: in  std_logic_vector(17 downto 0);
    WrClock: in  std_logic;
    RdClock: in  std_logic;
    WrEn: in  std_logic;
    RdEn: in  std_logic;
    Reset: in  std_logic;
    RPReset: in  std_logic;
    Q: out  std_logic_vector(17 downto 0);
    Empty: out  std_logic;
    Full: out  std_logic;
    AlmostFull: out std_logic
    );
end component;

component med_ecp3_sfp_sync is
  generic(
    SERDES_NUM : integer range 0 to 3 := 0;
--     MASTER_CLOCK_SWITCH : integer := c_NO;   --just for debugging, should be NO
    IS_SYNC_SLAVE   : integer := c_NO       --select slave mode
    );
  port(
    CLK                : in  std_logic; -- _internal_ 200 MHz reference clock
    SYSCLK             : in  std_logic; -- 100 MHz main clock net, synchronous to RX clock
    RESET              : in  std_logic; -- synchronous reset
    CLEAR              : in  std_logic; -- asynchronous reset
    --Internal Connection TX
    MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
    MED_DATAREADY_IN   : in  std_logic;
    MED_READ_OUT       : out std_logic := '0';
    --Internal Connection RX
    MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0) := (others => '0');
    MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0) := (others => '0');
    MED_DATAREADY_OUT  : out std_logic := '0';
    MED_READ_IN        : in  std_logic;
    CLK_RX_HALF_OUT    : out std_logic := '0';  --received 100 MHz
    CLK_RX_FULL_OUT    : out std_logic := '0';  --received 200 MHz
    
    --Sync operation
--     IS_SLAVE           : in  std_logic := '0';     --0 if generic is used
    RX_DLM             : out std_logic := '0';
    RX_DLM_WORD        : out std_logic_vector(7 downto 0) := x"00";
    TX_DLM             : in  std_logic := '0';
    TX_DLM_WORD        : in  std_logic_vector(7 downto 0) := x"00";
    
    --SFP Connection
    SD_RXD_P_IN        : in  std_logic;
    SD_RXD_N_IN        : in  std_logic;
    SD_TXD_P_OUT       : out std_logic;
    SD_TXD_N_OUT       : out std_logic;
    SD_REFCLK_P_IN     : in  std_logic;  --not used
    SD_REFCLK_N_IN     : in  std_logic;  --not used
    SD_PRSNT_N_IN      : in  std_logic;  -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
    SD_LOS_IN          : in  std_logic;  -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
    SD_TXDIS_OUT       : out  std_logic := '0'; -- SFP disable
    --Control Interface
    BUS_RX             : in  CTRLBUS_RX;
    BUS_TX             : out CTRLBUS_TX;
    -- Status and control port
    STAT_OP            : out std_logic_vector (15 downto 0);
    CTRL_OP            : in  std_logic_vector (15 downto 0) := (others => '0');
    STAT_DEBUG         : out std_logic_vector (63 downto 0);
    CTRL_DEBUG         : in  std_logic_vector (63 downto 0) := (others => '0')
   );
end component;



end package;
