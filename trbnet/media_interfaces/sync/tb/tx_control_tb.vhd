LIBRARY ieee  ; 
LIBRARY work  ; 
USE ieee.NUMERIC_STD.all  ; 
USE ieee.std_logic_1164.all  ; 
USE work.med_sync_define.all  ; 
USE work.trb_net_components.all  ; 
USE work.trb_net_std.all  ; 

entity tx_control_tb  is 
end entity; 
 
architecture tx_control_tb_arch of tx_control_tb is
  signal start_position_in   :  std_logic_vector (7 downto 0) := (others => '0')  ; 
  signal clk_100   :  std_logic  := '1'; 
  signal clk_200   :  std_logic  := '1'; 
  signal request_position_in   :  std_logic_vector (7 downto 0) := (others => '0')  ; 
  signal tx_k_out   :  std_logic  ; 
  signal send_dlm   :  std_logic := '0'  ; 
  signal tx_read_out   :  std_logic  ; 
  signal tx_allow_in   :  std_logic := '1'  ; 
  signal send_dlm_word   :  std_logic_vector (7 downto 0) := (others => '0')  ; 
  signal reset_in   :  std_logic  := '0' ; 
  signal tx_packet_number_in   :  std_logic_vector (2 downto 0)  ; 
  signal tx_data_in   :  std_logic_vector (15 downto 0) := (others => '0') ; 
  signal tx_write_in   :  std_logic  := '0'; 
  signal tx_data_out   :  std_logic_vector (7 downto 0)  ; 
  signal start_retransmit_in   :  std_logic := '0'  ; 
  signal send_link_reset_in   :  std_logic := '0'  ; 
  signal request_retransmit_in   :  std_logic := '0'  ; 
  
  signal send_link_reset_out   :  std_logic := '0'  ; 
  signal request_retransmit_out   :  std_logic := '0'  ; 
  signal rx_dlm_word   :  std_logic_vector (7 downto 0) := (others => '0')  ; 
  signal got_link_ready   :  std_logic := '0'  ; 
  signal rx_write_out   :  std_logic  ; 
  signal rx_read_in   :  std_logic  ; 
  signal request_position_out   :  std_logic_vector (7 downto 0) := (others => '0')  ; 
  signal start_retransmit_out   :  std_logic := '0'  ; 
  signal rx_allow_in   :  std_logic := '0'  ; 
  signal rx_packet_number_out   :  std_logic_vector (2 downto 0)  ; 
  signal start_position_out   :  std_logic_vector (7 downto 0) := (others => '0')  ; 
  signal rx_data_in   :  std_logic_vector (7 downto 0)  ; 
  signal rx_data_out   :  std_logic_vector (15 downto 0)  ; 
  signal rx_k_in   :  std_logic  ; 
  signal rx_dlm   :  std_logic := '0'  ; 
  signal make_reset_out   :  std_logic := '0'  ;  
  
  
  component tx_control  
    port ( 
      STAT_REG_OUT  : out std_logic_vector (31 downto 0) ; 
      START_POSITION_IN  : in std_logic_vector (7 downto 0) ; 
      CLK_100  : in STD_LOGIC ; 
      CLK_200  : in STD_LOGIC ; 
      REQUEST_POSITION_IN  : in std_logic_vector (7 downto 0) ; 
      TX_K_OUT  : out STD_LOGIC ; 
      SEND_DLM  : in STD_LOGIC ; 
      TX_READ_OUT  : out STD_LOGIC ; 
      TX_ALLOW_IN  : in STD_LOGIC ; 
      SEND_DLM_WORD  : in std_logic_vector (7 downto 0) ; 
      RESET_IN  : in STD_LOGIC ; 
      TX_PACKET_NUMBER_IN  : in std_logic_vector (2 downto 0) ; 
      TX_DATA_IN  : in std_logic_vector (15 downto 0) ; 
      TX_WRITE_IN  : in STD_LOGIC ; 
      TX_DATA_OUT  : out std_logic_vector (7 downto 0) ; 
      START_RETRANSMIT_IN  : in STD_LOGIC ; 
      DEBUG_OUT  : out std_logic_vector (31 downto 0) ; 
      SEND_LINK_RESET_IN  : in STD_LOGIC ; 
      REQUEST_RETRANSMIT_IN  : in STD_LOGIC ); 
  end component ; 
  
component rx_control is
  port(
    CLK_200                        : in  std_logic;
    CLK_100                        : in  std_logic;
    RESET_IN                       : in  std_logic;

    RX_DATA_OUT                    : out std_logic_vector(15 downto 0);
    RX_PACKET_NUMBER_OUT           : out std_logic_vector(2 downto 0);
    RX_WRITE_OUT                   : out std_logic;
    RX_READ_IN                     : in  std_logic;

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
    GOT_LINK_READY                 : out std_logic := '0';

    DEBUG_OUT                      : out std_logic_vector(31 downto 0);
    STAT_REG_OUT                   : out std_logic_vector(31 downto 0)
    );
end component;  
  
begin

CLK_100 <= not CLK_100 after 5 ns;
CLK_200 <= not CLK_200 after 2.5 ns;

TX_ALLOW_IN <= '0', '1' after 50 ns;
RX_ALLOW_IN <= '0', '1' after 40 ns;

  DUTTX  : tx_control  
    port map ( 
      STAT_REG_OUT   => open  ,
      START_POSITION_IN   => START_POSITION_IN  ,
      CLK_100   => CLK_100  ,
      CLK_200   => CLK_200  ,
      REQUEST_POSITION_IN   => REQUEST_POSITION_IN  ,
      TX_K_OUT   => TX_K_OUT  ,
      SEND_DLM   => SEND_DLM  ,
      TX_READ_OUT   => TX_READ_OUT  ,
      TX_ALLOW_IN   => TX_ALLOW_IN  ,
      SEND_DLM_WORD   => SEND_DLM_WORD  ,
      RESET_IN   => RESET_IN  ,
      TX_PACKET_NUMBER_IN   => TX_PACKET_NUMBER_IN  ,
      TX_DATA_IN   => TX_DATA_IN  ,
      TX_WRITE_IN   => TX_WRITE_IN  ,
      TX_DATA_OUT   => TX_DATA_OUT  ,
      START_RETRANSMIT_IN   => START_RETRANSMIT_IN  ,
      DEBUG_OUT   => open  ,
      SEND_LINK_RESET_IN   => SEND_LINK_RESET_IN  ,
      REQUEST_RETRANSMIT_IN   => REQUEST_RETRANSMIT_IN   
      ); 
      


  DUTRX  : rx_control  
    port map ( 
      STAT_REG_OUT   => open  ,
      SEND_LINK_RESET_OUT   => SEND_LINK_RESET_OUT  ,
      REQUEST_RETRANSMIT_OUT   => REQUEST_RETRANSMIT_OUT  ,
      RX_DLM_WORD   => RX_DLM_WORD  ,
      CLK_100   => CLK_100  ,
      GOT_LINK_READY   => GOT_LINK_READY  ,
      CLK_200   => CLK_200  ,
      RX_WRITE_OUT   => RX_WRITE_OUT  ,
      RX_READ_IN   => RX_READ_IN  ,
      REQUEST_POSITION_OUT   => REQUEST_POSITION_OUT  ,
      START_RETRANSMIT_OUT   => START_RETRANSMIT_OUT  ,
      RX_ALLOW_IN   => RX_ALLOW_IN  ,
      RX_PACKET_NUMBER_OUT   => RX_PACKET_NUMBER_OUT  ,
      START_POSITION_OUT   => START_POSITION_OUT  ,
      RESET_IN   => RESET_IN  ,
      RX_DATA_IN   => RX_DATA_IN  ,
      RX_DATA_OUT   => RX_DATA_OUT  ,
      RX_K_IN   => RX_K_IN  ,
      DEBUG_OUT   => open  ,
      RX_DLM   => RX_DLM  ,
      MAKE_RESET_OUT   => MAKE_RESET_OUT   
      ); 

      
RX_K_IN <= TX_K_OUT;
RX_DATA_IN <= TX_DATA_OUT;

process begin
  wait for 100 ns;
  wait until rising_edge(clk_100); wait for 1 ns;
  TX_DATA_IN <= x"0038";  TX_PACKET_NUMBER_IN <= "100"; TX_WRITE_IN <= '1';  
  wait until rising_edge(clk_100); wait for 1 ns;
  TX_DATA_IN <= x"2211";  TX_PACKET_NUMBER_IN <= "000"; TX_WRITE_IN <= '1';  
  wait until rising_edge(clk_100); wait for 1 ns;
  TX_DATA_IN <= x"4433";  TX_PACKET_NUMBER_IN <= "001"; TX_WRITE_IN <= '1';  
  wait until rising_edge(clk_100); wait for 1 ns;
  TX_DATA_IN <= x"6655";  TX_PACKET_NUMBER_IN <= "010"; TX_WRITE_IN <= '1';  
  wait until rising_edge(clk_100); wait for 1 ns;
  TX_DATA_IN <= x"8877";  TX_PACKET_NUMBER_IN <= "011"; TX_WRITE_IN <= '1';  
  wait until rising_edge(clk_100); wait for 1 ns;
  TX_DATA_IN <= x"0000";  TX_PACKET_NUMBER_IN <= "100"; TX_WRITE_IN <= '0';  
end process;


process begin
  wait for 120 ns;
  wait until rising_edge(clk_200); wait for 1 ns;  
  SEND_DLM_WORD <= x"85"; SEND_DLM <= '1';
  wait until rising_edge(clk_200); wait for 1 ns;  
  SEND_DLM_WORD <= x"85"; SEND_DLM <= '0';
  wait for 15 ns;
end process;


end architecture; 

