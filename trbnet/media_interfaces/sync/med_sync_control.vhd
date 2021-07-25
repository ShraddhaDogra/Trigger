LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.med_sync_define.all;

entity med_sync_control is
  generic(
    IS_SYNC_SLAVE : integer := 1;
    IS_TX_RESET   : integer := 1
    );
  port(
    CLK_SYS     : in  std_logic;
    CLK_RXI     : in  std_logic;
    CLK_RXHALF  : in  std_logic;
    CLK_TXI     : in  std_logic;
    CLK_REF     : in  std_logic;
    RESET       : in  std_logic;
    CLEAR       : in  std_logic;
    
    SFP_LOS     : in  std_logic;
    TX_LOL      : in  std_logic;
    RX_CDR_LOL  : in  std_logic;
    RX_LOS      : in  std_logic;
    WA_POSITION : in  std_logic_vector(3 downto 0);
    
    RX_SERDES_RST : out std_logic;
    RX_PCS_RST    : out std_logic;
    QUAD_RST      : out std_logic;
    TX_PCS_RST    : out std_logic;

    MEDIA_MED2INT : out MED2INT;
    MEDIA_INT2MED : in  INT2MED;
    
    TX_DATA       : out std_logic_vector(7 downto 0);
    TX_K          : out std_logic;
    TX_CD         : out std_logic;
    RX_DATA       : in  std_logic_vector(7 downto 0);
    RX_K          : in  std_logic;
    
    TX_DLM_WORD   : in  std_logic_vector(7 downto 0);
    TX_DLM        : in  std_logic;
    RX_DLM_WORD   : out std_logic_vector(7 downto 0);
    RX_DLM        : out std_logic;
    
    SERDES_RX_READY_IN : in std_logic := '1';
    SERDES_TX_READY_IN : in std_logic := '1';
    
    STAT_TX_CONTROL  : out std_logic_vector(31 downto 0);
    STAT_RX_CONTROL  : out std_logic_vector(31 downto 0);
    DEBUG_TX_CONTROL : out std_logic_vector(31 downto 0);
    DEBUG_RX_CONTROL : out std_logic_vector(31 downto 0);
    STAT_RESET       : out std_logic_vector(31 downto 0);
    DEBUG_OUT        : out std_logic_vector(31 downto 0)
    );
end entity;


architecture med_sync_control_arch of med_sync_control is

signal rx_fsm_state : std_logic_vector(3 downto 0);
signal tx_fsm_state : std_logic_vector(3 downto 0);
signal wa_position_rx : std_logic_vector(3 downto 0);
signal start_timer       : unsigned(21 downto 0) := (others => '0');

signal request_retr_i     : std_logic;
signal start_retr_i       : std_logic;
signal request_retr_position_i  : std_logic_vector(7 downto 0);
signal start_retr_position_i    : std_logic_vector(7 downto 0);
signal rx_dlm_i           : std_logic;

signal led_ok                 : std_logic;
signal led_dlm, last_led_dlm  : std_logic;
signal led_rx, last_led_rx    : std_logic;
signal led_tx, last_led_tx    : std_logic;
signal timer                  : unsigned(20 downto 0);
signal sd_los_i               : std_logic;

signal rx_allow               : std_logic;
signal tx_allow               : std_logic;
signal got_link_ready_i       : std_logic;
signal make_link_reset_i      : std_logic;
signal send_link_reset_i      : std_logic;
signal make_link_reset_real_i : std_logic := '0';
signal make_link_reset_sys_i  : std_logic := '0';
signal send_link_reset_real_i : std_logic := '0';

signal reset_i, rst_n, rst_n_tx : std_logic;
signal media_med2int_i        : MED2INT;
signal finished_reset_rx, finished_reset_rx_q : std_logic;
signal finished_reset_tx, finished_reset_tx_q : std_logic;

begin

rst_n_tx  <=       not (CLEAR or sd_los_i or make_link_reset_real_i) when (IS_SYNC_SLAVE = 1 and IS_TX_RESET = 1)
              else not (CLEAR or make_link_reset_real_i);



rst_n     <= not (CLEAR or sd_los_i or make_link_reset_real_i);
reset_i   <=     (RESET or sd_los_i or make_link_reset_real_i);


media_med2int_i.clk_half <= CLK_RXHALF;
media_med2int_i.clk_full <= CLK_RXI;

-------------------------------------------------      
-- Reset FSM & Link states
-------------------------------------------------      
THE_RX_FSM : rx_reset_fsm
  port map(
    RST_N                => rst_n,
    RX_REFCLK            => CLK_REF,
    TX_PLL_LOL_QD_S      => TX_LOL,
    RX_SERDES_RST_CH_C   => RX_SERDES_RST,
    RX_CDR_LOL_CH_S      => RX_CDR_LOL,
    RX_LOS_LOW_CH_S      => RX_LOS,
    RX_PCS_RST_CH_C      => RX_PCS_RST,
    WA_POSITION          => wa_position_rx,
    NORMAL_OPERATION_OUT => finished_reset_rx,
    STATE_OUT            => rx_fsm_state
    );
    
THE_TX_FSM : tx_reset_fsm
  port map(
    RST_N                => rst_n_tx,
    TX_REFCLK            => CLK_REF,
    TX_PLL_LOL_QD_S      => TX_LOL,
    RST_QD_C             => QUAD_RST,
    TX_PCS_RST_CH_C      => TX_PCS_RST,
    NORMAL_OPERATION_OUT => finished_reset_tx,
    STATE_OUT            => tx_fsm_state
    );

    
SYNC_WA_POSITION : process begin
  wait until rising_edge(CLK_REF);
  if IS_SYNC_SLAVE = 1 then
    wa_position_rx <= WA_POSITION;
  else
    wa_position_rx <= x"0";
  end if;
end process;    
    
-------------------------------------------------      
-- RX & TX allow
-------------------------------------------------  
--Slave enables RX/TX when sync is done, Master waits additional time to make sure link is stable
PROC_ALLOW : process begin
  wait until rising_edge(CLK_SYS);
  if finished_reset_rx_q = '1'  --SERDES_RX_READY_IN= '1' --and 
            and (IS_SYNC_SLAVE = 1 or start_timer(start_timer'left) = '1') then
    rx_allow <= '1';
  else
    rx_allow <= '0';
  end if;
  if  --SERDES_RX_READY_IN = '1' and SERDES_TX_READY_IN = '1'  
        finished_reset_tx_q = '1' and finished_reset_rx_q = '1' 
            and (IS_SYNC_SLAVE = 1 or start_timer(start_timer'left) = '1') then
    tx_allow <= '1';
  else
    tx_allow <= '0';
  end if;
end process;


  link_reset_fin_tx  : signal_sync port map(RESET => '0',CLK0 => CLK_SYS, CLK1 => CLK_SYS,
                                          D_IN(0)  => finished_reset_tx, 
                                          D_OUT(0) => finished_reset_tx_q);
  link_reset_fin_rx  : signal_sync port map(RESET => '0',CLK0 => CLK_SYS, CLK1 => CLK_SYS,
                                          D_IN(0)  => finished_reset_rx, 
                                          D_OUT(0) => finished_reset_rx_q);


PROC_START_TIMER : process begin
  wait until rising_edge(CLK_SYS);
 -- if got_link_ready_i = '1' then
  if finished_reset_tx_q = '1' and finished_reset_rx_q = '1'  then
    if start_timer(start_timer'left) = '0' then
      start_timer <= start_timer + 1;
    end if;  
  else
    start_timer <= (others => '0');
  end if;
end process;
    
-------------------------------------------------      
-- TX Data
-------------------------------------------------         
THE_TX : tx_control
  port map(
    CLK_200                => CLK_TXI,
    CLK_100                => CLK_SYS,
    RESET_IN               => reset_i,

    TX_DATA_IN             => MEDIA_INT2MED.data,
    TX_PACKET_NUMBER_IN    => MEDIA_INT2MED.packet_num,
    TX_WRITE_IN            => MEDIA_INT2MED.dataready,
    TX_READ_OUT            => media_med2int_i.tx_read,

    TX_DATA_OUT            => TX_DATA,
    TX_K_OUT               => TX_K,
    TX_CD_OUT              => TX_CD,

    REQUEST_RETRANSMIT_IN  => request_retr_i,             --TODO
    REQUEST_POSITION_IN    => request_retr_position_i,    --TODO

    START_RETRANSMIT_IN    => start_retr_i,               --TODO
    START_POSITION_IN      => start_retr_position_i,      --TODO

    SEND_DLM               => TX_DLM,
    SEND_DLM_WORD          => TX_DLM_WORD,
    
    SEND_LINK_RESET_IN     => MEDIA_INT2MED.ctrl_op(15),
    TX_ALLOW_IN            => tx_allow,
    RX_ALLOW_IN            => rx_allow,

    DEBUG_OUT              => DEBUG_TX_CONTROL,
    STAT_REG_OUT           => STAT_TX_CONTROL
    );  


-------------------------------------------------      
-- RX Data
-------------------------------------------------             
THE_RX_CONTROL : rx_control
  port map(
    CLK_200                        => CLK_RXI,
    CLK_100                        => CLK_SYS,
    RESET_IN                       => reset_i,

    RX_DATA_OUT                    => media_med2int_i.data,
    RX_PACKET_NUMBER_OUT           => media_med2int_i.packet_num,
    RX_WRITE_OUT                   => media_med2int_i.dataready,
--     RX_READ_IN                     => '1',

    RX_DATA_IN                     => RX_DATA,
    RX_K_IN                        => RX_K,

    REQUEST_RETRANSMIT_OUT         => request_retr_i,
    REQUEST_POSITION_OUT           => request_retr_position_i,

    START_RETRANSMIT_OUT           => start_retr_i,
    START_POSITION_OUT             => start_retr_position_i,

    --send_dlm: 200 MHz, 1 clock strobe, data valid until next DLM
    RX_DLM                         => rx_dlm_i,
    RX_DLM_WORD                    => RX_DLM_WORD,
    
    SEND_LINK_RESET_OUT            => send_link_reset_i,
    MAKE_RESET_OUT                 => make_link_reset_i,
    RX_ALLOW_IN                    => rx_allow,
    RX_RESET_FINISHED              => finished_reset_rx,
    GOT_LINK_READY                 => got_link_ready_i,

    DEBUG_OUT                      => DEBUG_RX_CONTROL,
    STAT_REG_OUT                   => STAT_RX_CONTROL
    );   
        
RX_DLM <= rx_dlm_i;
MEDIA_MED2INT <= media_med2int_i;

-------------------------------------------------      
-- Generate LED signals
-------------------------------------------------   
led_ok <= rx_allow and tx_allow when rising_edge(CLK_SYS); 
led_rx <= (media_med2int_i.dataready or led_rx)  and not timer(20) when rising_edge(CLK_SYS);
-- led_tx <= '1' when DEBUG_TX_CONTROL(13 downto 10) = x"c" else '0'; --
led_tx <= (MEDIA_INT2MED.dataready or led_tx or sd_los_i)  and not timer(20) when rising_edge(CLK_SYS);
led_dlm <= (led_dlm or rx_dlm_i) and not timer(20) when rising_edge(CLK_SYS);
-- led_dlm <= '1' when DEBUG_RX_CONTROL(3 downto 0) = x"f" else '0';

ROC_TIMER : process begin
  wait until rising_edge(CLK_SYS);
  timer <= timer + 1 ;
  if timer(20) = '1' then
    timer <= (others => '0');
    last_led_rx <= led_rx ;
    last_led_tx <= led_tx;
    last_led_dlm <= led_dlm;
  end if;
end process;
        
-------------------------------------------------      
-- Status signals
-------------------------------------------------   

STAT_RESET(3 downto 0)   <= rx_fsm_state;
STAT_RESET(7 downto 4)   <= tx_fsm_state;
STAT_RESET(8)            <= tx_allow;
STAT_RESET(9)            <= rx_allow;
STAT_RESET(15 downto 10) <= (others => '0');
STAT_RESET(16)           <= RX_CDR_LOL;
STAT_RESET(17)           <= RX_LOS;
STAT_RESET(18)           <= '0'; --RX_PCS_RST;
STAT_RESET(19)           <= '0';
STAT_RESET(31 downto 20) <= start_timer(start_timer'left downto start_timer'left - 11);


gen_link_reset : if IS_SYNC_SLAVE = 1 generate
  link_reset_pulse : signal_sync port map(RESET => '0',CLK0 => CLK_RXI,CLK1 => CLK_SYS,
                                          D_IN(0)  => make_link_reset_i, 
                                          D_OUT(0) => make_link_reset_sys_i);
  link_reset_send  : signal_sync port map(RESET => '0',CLK0 => CLK_RXI,CLK1 => CLK_SYS,
                                          D_IN(0)  => send_link_reset_i, 
                                          D_OUT(0) => send_link_reset_real_i);
end generate;

make_link_reset_real_i <= make_link_reset_sys_i when IS_SYNC_SLAVE = 0 else
                          make_link_reset_sys_i or sd_los_i when IS_SYNC_SLAVE = 1;

sd_los_i <= SFP_LOS when rising_edge(CLK_SYS);

media_med2int_i.stat_op(15) <= send_link_reset_real_i when rising_edge(CLK_SYS);
media_med2int_i.stat_op(14) <= '0';
media_med2int_i.stat_op(13) <= make_link_reset_real_i when rising_edge(CLK_SYS); --make trbnet reset
media_med2int_i.stat_op(12) <= led_dlm  when rising_edge(CLK_SYS); -- or last_led_dlm;
media_med2int_i.stat_op(11) <= led_tx; -- or last_led_tx;
media_med2int_i.stat_op(10) <= led_rx or last_led_rx;
media_med2int_i.stat_op(9)  <= tx_allow; --led_ok
media_med2int_i.stat_op(8)  <= rx_allow;

media_med2int_i.stat_op(7 downto 4) <= (others => '0');
media_med2int_i.stat_op(3 downto 0) <= x"0" when rx_allow = '1' and tx_allow = '1' else x"7";

DEBUG_OUT(0) <= tx_allow;
DEBUG_OUT(1) <= rx_allow;
DEBUG_OUT(2) <= sd_los_i;
DEBUG_OUT(3) <= '0'; --DEBUG_RX_CONTROL(4);

end architecture;
