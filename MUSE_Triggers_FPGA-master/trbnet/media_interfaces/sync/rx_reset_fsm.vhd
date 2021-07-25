--Media interface RX state machine


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;


entity rx_reset_fsm is
  port (
    RST_N             : in std_logic;
    RX_REFCLK         : in std_logic;
    TX_PLL_LOL_QD_S   : in std_logic;
    RX_SERDES_RST_CH_C: out std_logic;
    RX_CDR_LOL_CH_S   : in std_logic;
    RX_LOS_LOW_CH_S   : in std_logic;
    RX_PCS_RST_CH_C   : out std_logic;
    --fix word alignment position to 0 for non-slave links!
    WA_POSITION       : in  std_logic_vector(3 downto 0) := x"0";
    NORMAL_OPERATION_OUT : out std_logic;
    STATE_OUT         : out std_logic_vector(3 downto 0)
    );
end entity ;
                                                                                              
architecture rx_reset_fsm_arch of rx_reset_fsm is
            
constant count_index : integer := 19;
type statetype is (WAIT_FOR_PLOL, RX_SERDES_RESET, WAIT_FOR_timer1, CHECK_LOL_LOS, WAIT_FOR_timer2, NORMAL);
                                                                                              
signal   cs:      statetype;  -- current state of lsm
signal   ns:      statetype;  -- next state of lsm
                                                                                              
signal   tx_pll_lol_qd_q: std_logic;
signal   rx_cdr_lol_ch_q:         std_logic;
signal   rx_los_low_ch_q:        std_logic;
signal   rx_lol_los  :  std_logic;
signal   rx_lol_los_int:      std_logic;
signal   rx_lol_los_del:      std_logic;
signal   rx_pcs_rst_ch_c_int: std_logic;
signal   rx_serdes_rst_ch_c_int: std_logic;
                                                                                              
signal   reset_timer1:  std_logic;
signal   reset_timer2:  std_logic;
                                                                                              
signal   counter1:   unsigned(1 downto 0);
signal   timer1:  std_logic;
                                                                                              
signal   counter2: unsigned(19 downto 0);
signal   timer2   : std_logic;
                                                                                              
begin
                                                                                              
rx_lol_los <= rx_cdr_lol_ch_q or rx_los_low_ch_q ;
                                                                                              
process(RX_REFCLK)
begin
  if rising_edge(RX_REFCLK) then
    if RST_N = '0' then
      cs <= WAIT_FOR_PLOL;
      rx_lol_los_int <= '1';
      rx_lol_los_del <= '1';
      RX_PCS_RST_CH_C <= '1';
      RX_SERDES_RST_CH_C <= '0';
    else
      cs <= ns;
      rx_lol_los_del <= rx_lol_los;
      rx_lol_los_int <= rx_lol_los_del;
      RX_PCS_RST_CH_C <= rx_pcs_rst_ch_c_int;
      RX_SERDES_RST_CH_C <= rx_serdes_rst_ch_c_int;
    end if;
  end if;
end process;
                                                                                              
  sync_sfp_sigs : entity work.signal_sync 
    generic map(WIDTH => 3)
    port map(RESET => '0',CLK0 => RX_REFCLK, CLK1 => RX_REFCLK,
             D_IN(0)  => TX_PLL_LOL_QD_S,
             D_IN(1)  => RX_CDR_LOL_CH_S,
             D_IN(2)  => RX_LOS_LOW_CH_S,
             D_OUT(0) => tx_pll_lol_qd_q,
             D_OUT(1) => rx_cdr_lol_ch_q,
             D_OUT(2) => rx_los_low_ch_q
             );

                                                                                              
--timer2 = 400,000 Refclk cycles or 200,000 REFCLKDIV2 cycles
--An 18 bit counter ([17:0]) counts 262144 cycles, so a 19 bit ([18:0]) counter will do if we set timer2 = bit[18]
  process begin
    wait until rising_edge(RX_REFCLK);
    if reset_timer2 = '1' then
      counter2 <= "00000000000000000000";
      timer2 <= '0';
    else
      if counter2(count_index) = '1' then
        timer2 <='1';
      else
        timer2 <='0';
        counter2 <= counter2 + 1 ;
      end if;
    end if;
  end process;
                                                                                              
                                                                                              
process(cs, tx_pll_lol_qd_q, rx_los_low_ch_q, timer1, rx_lol_los_int, timer2, wa_position, rx_lol_los_del)
begin
  reset_timer2 <= '0';
  STATE_OUT <= x"F";        
  NORMAL_OPERATION_OUT <= '0';
  
  case cs is
    when WAIT_FOR_PLOL =>
      rx_pcs_rst_ch_c_int <= '1';
      rx_serdes_rst_ch_c_int <= '0';
      if (tx_pll_lol_qd_q = '1' or rx_los_low_ch_q = '1') then  --Also make sure A Signal
          ns <= WAIT_FOR_PLOL;             --is Present prior to moving to the next
      else
          ns <= RX_SERDES_RESET;
      end if;
      STATE_OUT <= x"1";
                                                                                            
    when RX_SERDES_RESET =>
      rx_pcs_rst_ch_c_int <= '1';
      rx_serdes_rst_ch_c_int <= '1';
--       reset_timer1 <= '1';
      ns <= WAIT_FOR_timer1;
      STATE_OUT <= x"2";
                                                                                            
                                                                                            
    when WAIT_FOR_timer1 =>
      rx_pcs_rst_ch_c_int <= '1';
      rx_serdes_rst_ch_c_int <= '1';
      ns <= CHECK_LOL_LOS;
      STATE_OUT <= x"3";

    when CHECK_LOL_LOS =>
      rx_pcs_rst_ch_c_int <= '1';
      rx_serdes_rst_ch_c_int <= '0';
      reset_timer2 <= '1';
      ns <= WAIT_FOR_timer2;
      STATE_OUT <= x"4";

    when WAIT_FOR_timer2 =>
      rx_pcs_rst_ch_c_int <= '1';
      rx_serdes_rst_ch_c_int <= '0';
      if rx_lol_los_int = rx_lol_los_del then   --NO RISING OR FALLING EDGES
        if timer2 = '1' then
          if rx_lol_los_int = '1' or WA_POSITION /= x"0" then
            ns <= WAIT_FOR_PLOL;
          else
            ns <= NORMAL;
          end if;
        else
          ns <= WAIT_FOR_timer2;
        end if;
      else
        ns <= CHECK_LOL_LOS;    --RESET timer2
      end if;
      STATE_OUT <= x"5";

                                                                                            
    when NORMAL =>
      rx_pcs_rst_ch_c_int <= '0';
      rx_serdes_rst_ch_c_int <= '0';
      if rx_lol_los_int = '1' or WA_POSITION /= x"0" then
        ns <= WAIT_FOR_PLOL;
      else
        NORMAL_OPERATION_OUT <= '1';
        ns <= NORMAL;
      end if;
      STATE_OUT <= x"6";
                                                                                            
    when others =>
      ns <= WAIT_FOR_PLOL;
                                                                                            
  end case;
                                                                                              
end process;



                                                                                              
end architecture;
