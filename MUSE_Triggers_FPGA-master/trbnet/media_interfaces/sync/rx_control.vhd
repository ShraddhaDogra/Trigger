library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.med_sync_define.all;

entity rx_control is
  port(
    CLK_200                        : in  std_logic;
    CLK_100                        : in  std_logic;
    RESET_IN                       : in  std_logic;

--clk_sys signals
    RX_DATA_OUT                    : out std_logic_vector(15 downto 0);
    RX_PACKET_NUMBER_OUT           : out std_logic_vector(2 downto 0);
    RX_WRITE_OUT                   : out std_logic;

-- clk_rx signals
    RX_DATA_IN                     : in  std_logic_vector( 7 downto 0);
    RX_K_IN                        : in  std_logic;

    REQUEST_RETRANSMIT_OUT         : out std_logic := '0';
    REQUEST_POSITION_OUT           : out std_logic_vector( 7 downto 0) := (others => '0');

    START_RETRANSMIT_OUT           : out std_logic := '0';
    START_POSITION_OUT             : out std_logic_vector( 7 downto 0) := (others => '0');

    --send_dlm: 200 MHz, 1 clock strobe, data valid until next DLM
    RX_DLM                         : out std_logic := '0';
    RX_DLM_WORD                    : out std_logic_vector( 7 downto 0) := (others => '0');
    
--other signals    
    SEND_LINK_RESET_OUT            : out std_logic := '0'; --clk_rx
    MAKE_RESET_OUT                 : out std_logic := '0'; --clk_rx
    RX_ALLOW_IN                    : in  std_logic := '0'; --clk_sys
    RX_RESET_FINISHED              : in  std_logic := '0'; --clk_rx
    GOT_LINK_READY                 : out std_logic := '0'; --clk_rx

    DEBUG_OUT                      : out std_logic_vector(31 downto 0);
    STAT_REG_OUT                   : out std_logic_vector(31 downto 0)
    );
end entity;


architecture rx_control_arch of rx_control is

type rx_state_t is (SLEEP, WAIT_1, FIRST, GET_DATA, GET_IDLE, GET_DLM, MAKE_RESET, START_RETR);
signal rx_state            : rx_state_t;
signal rx_state_bits       : std_logic_vector(3 downto 0);
signal rx_packet_num       : std_logic_vector(2 downto 0);
signal buf_rx_write_out    : std_logic := '0';

signal rx_data             : std_logic_vector(17 downto 0);
signal ct_fifo_write       : std_logic := '0';
signal ct_fifo_read        : std_logic := '0';
signal ct_fifo_reset       : std_logic := '0';
signal ct_fifo_data_out    : std_logic_vector(17 downto 0);
signal ct_fifo_empty       : std_logic;
signal ct_fifo_full        : std_logic;
signal ct_fifo_afull       : std_logic;
signal last_ct_fifo_empty  : std_logic;
signal last_ct_fifo_read   : std_logic;

signal idle_hist_i         : std_logic_vector(3 downto 0) := x"0";
signal got_link_ready_i    : std_logic := '0';
signal start_retr_i        : std_logic;
signal start_retr_pos_i    : std_logic_vector(7 downto 0);
signal rx_dlm_i            : std_logic;
signal rx_dlm_word_i       : std_logic_vector(7 downto 0);

signal send_link_reset_i   : std_logic;
signal make_reset_i        : std_logic;
signal next_sop            : std_logic;

signal reg_rx_data_in      : std_logic_vector(7 downto 0);
signal reg_rx_k_in         : std_logic;

signal reset_cnt           : unsigned(7 downto 0);

begin

----------------------------------------------------------------------
-- Data to Endpoint
----------------------------------------------------------------------


ct_fifo_read <= not ct_fifo_reset and not ct_fifo_empty; -- when rising_edge(CLK_100);
buf_rx_write_out <=  last_ct_fifo_read and not last_ct_fifo_empty  when rising_edge(CLK_100);

RX_DATA_OUT   <= ct_fifo_data_out(15 downto 0) ;
RX_WRITE_OUT  <= buf_rx_write_out;
RX_PACKET_NUMBER_OUT <= rx_packet_num;

last_ct_fifo_read  <= ct_fifo_read  when rising_edge(CLK_100);
last_ct_fifo_empty <= ct_fifo_empty when rising_edge(CLK_100);

process begin
  wait until rising_edge(CLK_100);
  if RX_ALLOW_IN = '0' then
    rx_packet_num <= "100";
  elsif buf_rx_write_out = '1' then
    if rx_packet_num = "100" then
      rx_packet_num <= "000";
    else
      rx_packet_num <= std_logic_vector(unsigned(rx_packet_num)+1);
    end if;  
  end if;
end process;

----------------------------------------------------------------------
-- Clock Domain Transfer
----------------------------------------------------------------------
THE_CT_FIFO : entity work.lattice_ecp3_fifo_18x16_dualport_oreg
  port map(
    Data              => rx_data,
    WrClock           => CLK_200,
    RdClock           => CLK_100,
    WrEn              => ct_fifo_write,
    RdEn              => ct_fifo_read,
    Reset             => ct_fifo_reset,
    RPReset           => ct_fifo_reset,
    Q(17 downto 0)    => ct_fifo_data_out,
    Empty             => ct_fifo_empty,
    Full              => ct_fifo_full,
    AlmostFull        => ct_fifo_afull
    );

ct_fifo_reset <= not RX_ALLOW_IN when rising_edge(CLK_200);    


----------------------------------------------------------------------
-- Read incoming data
----------------------------------------------------------------------
PROC_RX_FSM : process begin
  wait until rising_edge(CLK_200);
  ct_fifo_write        <= '0';
  start_retr_i         <= '0';
  rx_dlm_i             <= '0';
  idle_hist_i(3 downto 1) <= idle_hist_i(2 downto 0);
  idle_hist_i(0)       <= got_link_ready_i;
  
  case rx_state is
    when SLEEP =>
      rx_state_bits         <= x"1";
      got_link_ready_i      <= '0';
      make_reset_i          <= '0';
      rx_data(7 downto 0)   <= reg_rx_data_in;
      if reg_rx_k_in = '1' and reg_rx_data_in = x"BC" then
        rx_state            <= wAIT_1;
      end if;
    
    when WAIT_1 =>
      rx_state <= FIRST;
    
    when FIRST =>
      rx_state_bits         <= x"2";
      rx_data(7 downto 0) <= reg_rx_data_in;
      if reg_rx_k_in = '1' then
        case reg_rx_data_in is
          when K_IDLE =>
            rx_state        <= GET_IDLE;
          when K_RST =>
            rx_state        <= MAKE_RESET;
            reset_cnt <= x"00";
          when K_DLM =>
            rx_state        <= GET_DLM;
          when K_REQ =>
            rx_state        <= START_RETR;
          when others => null;
        end case;
      else
        rx_state            <= GET_DATA;
      end if;
      
    when GET_IDLE =>
      rx_state_bits         <= x"3";
      rx_state              <= FIRST;
      next_sop              <= '1';
      if  reg_rx_k_in = '0' and reg_rx_data_in = D_IDLE1 then
        idle_hist_i(0)      <= '1';
        got_link_ready_i    <= got_link_ready_i or (idle_hist_i(1) and idle_hist_i(3));
      elsif  reg_rx_k_in = '1' then
        rx_state <= SLEEP;
      end if;
      
    when GET_DATA =>
      rx_state_bits         <= x"4";
      if reg_rx_k_in = '0' then
        next_sop            <= '0';
        rx_data(15 downto 8)<= reg_rx_data_in;
        rx_data(16)         <= next_sop;
        rx_data(17)         <= '0';
        ct_fifo_write       <= '1';
        rx_state            <= FIRST;
      else
        rx_state <= SLEEP;        
      end if;
     
    when GET_DLM =>
      rx_state_bits         <= x"5";
      rx_dlm_i              <= '1';
      rx_dlm_word_i         <= reg_rx_data_in;
      rx_state              <= FIRST;
    
    when START_RETR =>
      rx_state_bits         <= x"6";
      start_retr_i          <= '1';
      start_retr_pos_i      <= reg_rx_data_in;
      rx_state              <= FIRST;
     
    when MAKE_RESET =>
      rx_state_bits         <= x"F";
      if reg_rx_k_in = '1' and reg_rx_data_in = K_RST then
        send_link_reset_i   <= '1';
        make_reset_i        <= '0';
        got_link_ready_i    <= '0';
        if reset_cnt < x"c0" then
          reset_cnt           <= reset_cnt + 1;
        else
          make_reset_i      <= '1';
        end if;  
      elsif reset_cnt >= x"c0" or reset_cnt < x"80" then
        send_link_reset_i   <= '0';
        make_reset_i        <= '1';
        rx_state            <= SLEEP;
      else
        reset_cnt <= reset_cnt + 1;
        send_link_reset_i   <= '1';
      end if;
      
  end case;
  
  if RESET_IN = '1' or RX_RESET_FINISHED = '0' then
    rx_state <= SLEEP;
    make_reset_i      <= '0';
    send_link_reset_i <= '0';
  end if;
end process;

reg_rx_data_in <= RX_DATA_IN when rising_edge(CLK_200);
reg_rx_k_in    <= RX_K_IN    when rising_edge(CLK_200);


----------------------------------------------------------------------
-- Signals out
---------------------------------------------------------------------- 
GOT_LINK_READY <= got_link_ready_i;

START_RETRANSMIT_OUT <= start_retr_i when rising_edge(CLK_200);
START_POSITION_OUT   <= start_retr_pos_i when rising_edge(CLK_200);

RX_DLM       <= rx_dlm_i when rising_edge(CLK_200);
RX_DLM_WORD  <= rx_dlm_word_i when rising_edge(CLK_200);
 
REQUEST_RETRANSMIT_OUT <= '0';    --TODO: check incoming data
REQUEST_POSITION_OUT   <= x"00";  --TODO: check incoming data

SEND_LINK_RESET_OUT    <= send_link_reset_i when rising_edge(CLK_200);
MAKE_RESET_OUT         <= make_reset_i when rising_edge(CLK_200);

 
----------------------------------------------------------------------
-- Debug and Status
---------------------------------------------------------------------- 
STAT_REG_OUT(3 downto 0)   <= rx_state_bits;
STAT_REG_OUT(4)            <= got_link_ready_i;
STAT_REG_OUT(5)            <= ct_fifo_afull;
STAT_REG_OUT(6)            <= ct_fifo_empty;
STAT_REG_OUT(7)            <= ct_fifo_write;
STAT_REG_OUT(15 downto 8)  <= reg_rx_data_in when rising_edge(clk_100); --rx_data(7 downto 0);
STAT_REG_OUT(16)           <= rx_data(16);
STAT_REG_OUT(17)           <= '0';
STAT_REG_OUT(31 downto 18) <= (others => '0');


DEBUG_OUT(3 downto 0)   <= rx_state_bits;
DEBUG_OUT(4)            <= got_link_ready_i;
DEBUG_OUT(5)            <= ct_fifo_afull;
DEBUG_OUT(6)            <= ct_fifo_empty;
DEBUG_OUT(7)            <= ct_fifo_write;
DEBUG_OUT(15 downto 8)  <= rx_data(7 downto 0);
DEBUG_OUT(16)           <= reg_rx_k_in;
DEBUG_OUT(17)           <= make_reset_i;
DEBUG_OUT(18)           <= send_link_reset_i;
DEBUG_OUT(19)           <= '1' when rx_state_bits = x"f" else '0';
--DEBUG_OUT(16)           <= rx_data(16);
DEBUG_OUT(31 downto 20) <= (others => '0');
-- DEBUG_OUT(23 downto 16) <= rx_data(7 downto 0);
-- DEBUG_OUT(31 downto 24) <= ct_fifo_data_out(7 downto 0);



end architecture;
