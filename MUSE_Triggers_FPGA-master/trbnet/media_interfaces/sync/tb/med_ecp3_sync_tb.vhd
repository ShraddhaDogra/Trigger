
LIBRARY ieee  ; 
LIBRARY work  ; 
USE ieee.NUMERIC_STD.all  ; 
USE ieee.std_logic_1164.all  ; 
USE work.med_sync_define.all  ; 
USE work.trb_net_components.all  ; 
USE work.trb_net_std.all  ; 

entity med_ecp3_sfp_sync_tb  is 
end entity; 
 
architecture arch of med_ecp3_sfp_sync_tb is



component med_ecp3_sfp_sync is
  generic(
    SERDES_NUM : integer range 0 to 3 := 0
    );
  port(
    CLK                : in  std_logic; -- SerDes clock
    SYSCLK             : in  std_logic; -- fabric clock
    RESET              : in  std_logic; -- synchronous reset
    CLEAR              : in  std_logic; -- asynchronous reset
    CLK_EN             : in  std_logic;
    --Internal Connection
    MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
    MED_DATAREADY_IN   : in  std_logic;
    MED_READ_OUT       : out std_logic := '0';
    MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0) := (others => '0');
    MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0) := (others => '0');
    MED_DATAREADY_OUT  : out std_logic := '0';
    MED_READ_IN        : in  std_logic;
    CLK_RX_HALF_OUT    : out std_logic := '0';
    CLK_RX_FULL_OUT    : out std_logic := '0';
    
    IS_SLAVE           : in  std_logic := '0';
    RX_DLM             : out std_logic := '0';
    RX_DLM_WORD        : out std_logic_vector(7 downto 0) := x"00";
    TX_DLM             : in  std_logic := '0';
    TX_DLM_WORD        : in  std_logic_vector(7 downto 0) := x"00";
    --SFP Connection
    SD_RXD_P_IN        : in  std_logic;
    SD_RXD_N_IN        : in  std_logic;
    SD_TXD_P_OUT       : out std_logic;
    SD_TXD_N_OUT       : out std_logic;
    SD_REFCLK_P_IN     : in  std_logic;
    SD_REFCLK_N_IN     : in  std_logic;
    SD_PRSNT_N_IN      : in  std_logic;  -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
    SD_LOS_IN          : in  std_logic;  -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
    SD_TXDIS_OUT       : out  std_logic := '0'; -- SFP disable
    --Control Interface
    SCI_DATA_IN        : in  std_logic_vector(7 downto 0) := (others => '0');
    SCI_DATA_OUT       : out std_logic_vector(7 downto 0) := (others => '0');
    SCI_ADDR           : in  std_logic_vector(8 downto 0) := (others => '0');
    SCI_READ           : in  std_logic := '0';
    SCI_WRITE          : in  std_logic := '0';
    SCI_ACK            : out std_logic := '0';
    SCI_NACK           : out std_logic := '0';
    -- Status and control port
    STAT_OP            : out std_logic_vector (15 downto 0);
    CTRL_OP            : in  std_logic_vector (15 downto 0) := (others => '0');
    STAT_DEBUG         : out std_logic_vector (63 downto 0);
    CTRL_DEBUG         : in  std_logic_vector (63 downto 0) := (others => '0')
   );
end component;


signal clk_100_m, clk_100_s  : std_logic := '1';
signal clk_200_m, clk_200_s  : std_logic := '1';

signal reset_m               : std_logic := '1';
signal clear_m               : std_logic := '1';
signal reset_s               : std_logic := '1';
signal clear_s               : std_logic := '1';

signal med_data_in_m        : std_logic_vector(15 downto 0) := (others => '0');
signal med_packet_num_in_m  : std_logic_vector(2 downto 0) := (others => '0');
signal med_dataready_in_m   : std_logic := '0';
signal med_read_out_m       : std_logic := '0';
signal med_data_out_m       : std_logic_vector(15 downto 0) := (others => '0');
signal med_packet_num_out_m : std_logic_vector(2 downto 0) := (others => '0');
signal med_dataready_out_m  : std_logic := '0';
signal med_read_in_m        : std_logic := '0';

signal med_data_in_s        : std_logic_vector(15 downto 0) := (others => '0');
signal med_packet_num_in_s  : std_logic_vector(2 downto 0) := (others => '0');
signal med_dataready_in_s   : std_logic := '0';
signal med_read_out_s       : std_logic := '0';
signal med_data_out_s       : std_logic_vector(15 downto 0) := (others => '0');
signal med_packet_num_out_s : std_logic_vector(2 downto 0) := (others => '0');
signal med_dataready_out_s  : std_logic := '0';
signal med_read_in_s        : std_logic := '0';

signal tx_dlm_m             : std_logic := '0';
signal tx_dlm_word_m        : std_logic_vector(7 downto 0) := (others => '0');
signal rx_dlm_s             : std_logic := '0';
signal rx_dlm_word_s        : std_logic_vector(7 downto 0) := (others => '0');
signal tx_dlm_s             : std_logic := '0';
signal tx_dlm_word_s        : std_logic_vector(7 downto 0) := (others => '0');

signal RX_P, RX_N, TX_P, TX_N : std_logic;
signal RX_P_S, RX_N_S, TX_P_S, TX_N_S : std_logic;

signal clk_rxfull_s         : std_logic;
signal clk_rxhalf_s         : std_logic;

begin

reset_m <= '0' after 201 ns;
clear_m <= '0' after 51 ns;
reset_s <= '0' after 201 ns;
clear_s <= '0' after 51 ns;

RX_P_S <= transport TX_P   after 123 ns;
RX_N_S <= transport TX_N   after 123 ns;
RX_P   <= transport TX_P_S after 123 ns;
RX_N   <= transport TX_N_S after 123 ns;

clk_100_m <= not clk_100_m after 5 ns;
clk_200_m <= not clk_200_m after 2.5 ns;
clk_100_s <= clk_rxhalf_s;
clk_200_s <= not clk_200_s after 2.501 ns;



tx_dlm_word_m <= x"43";
tx_dlm_m <= '0', '1' after 4.00 ms, '0' after 4.00001 ms;


process begin
  wait for 3.98 ms; 
  wait until rising_edge(clk_100_m); wait for 1 ns;
  med_data_in_m <= x"1122";
  med_packet_num_in_m <= "100";
  med_dataready_in_m <= '1';
  wait until rising_edge(clk_100_m); wait for 1 ns;
  med_data_in_m <= x"3344";
  med_packet_num_in_m <= "000";
  med_dataready_in_m <= '1';
  wait until rising_edge(clk_100_m); wait for 1 ns;
  med_data_in_m <= x"5566";
  med_packet_num_in_m <= "001";
  med_dataready_in_m <= '1';
  wait until rising_edge(clk_100_m); wait for 1 ns;
  med_data_in_m <= x"7788";
  med_packet_num_in_m <= "010";
  med_dataready_in_m <= '1';
  wait until rising_edge(clk_100_m); wait for 1 ns;
  med_data_in_m <= x"9900";
  med_packet_num_in_m <= "011";
  med_dataready_in_m <= '1';
  wait until rising_edge(clk_100_m); wait for 1 ns;
  med_dataready_in_m <= '0';
  
end process;



THE_MASTER : med_ecp3_sfp_sync 
  port map(
    CLK                => clk_200_m,
    SYSCLK             => clk_100_m,
    RESET              => reset_m,
    CLEAR              => clear_m,
    CLK_EN             => '1',
    --Internal Connection
    MED_DATA_IN        => med_data_in_m,
    MED_PACKET_NUM_IN  => med_packet_num_in_m,
    MED_DATAREADY_IN   => med_dataready_in_m,
    MED_READ_OUT       => med_read_out_m,
    MED_DATA_OUT       => med_data_out_m,
    MED_PACKET_NUM_OUT => med_packet_num_out_m,
    MED_DATAREADY_OUT  => med_dataready_out_m,
    MED_READ_IN        => med_read_in_m,
    CLK_RX_HALF_OUT    => open,
    CLK_RX_FULL_OUT    => open,
    
    IS_SLAVE           => '0',
    RX_DLM             => open,
    RX_DLM_WORD        => open,
    TX_DLM             => tx_dlm_m,
    TX_DLM_WORD        => tx_dlm_word_m,
    --SFP Connection
    SD_RXD_P_IN        => RX_P,
    SD_RXD_N_IN        => RX_N,
    SD_TXD_P_OUT       => TX_P,
    SD_TXD_N_OUT       => TX_N,
    SD_REFCLK_P_IN     => '0',
    SD_REFCLK_N_IN     => '0',
    SD_PRSNT_N_IN      => '0',
    SD_LOS_IN          => '0',
    SD_TXDIS_OUT       => open,
    --Control Interface
    SCI_DATA_IN        => (others => '0'),
    SCI_DATA_OUT       => open,
    SCI_ADDR           => (others => '0'),
    SCI_READ           => '0',
    SCI_WRITE          => '0',
    SCI_ACK            => open,
    SCI_NACK           => open,
    -- Status and control port
    STAT_OP            => open,
    CTRL_OP            => (others => '0'),
    STAT_DEBUG         => open,
    CTRL_DEBUG         => (others => '0')
    );


THE_SLAVE : med_ecp3_sfp_sync 
  port map(
    CLK                => clk_200_s,
    SYSCLK             => clk_100_s,
    RESET              => reset_s,
    CLEAR              => clear_s,
    CLK_EN             => '1',
    --Internal Connection
    MED_DATA_IN        => med_data_in_s,
    MED_PACKET_NUM_IN  => med_packet_num_in_s,
    MED_DATAREADY_IN   => med_dataready_in_s,
    MED_READ_OUT       => med_read_out_s,
    MED_DATA_OUT       => med_data_out_s,
    MED_PACKET_NUM_OUT => med_packet_num_out_s,
    MED_DATAREADY_OUT  => med_dataready_out_s,
    MED_READ_IN        => med_read_in_s,
    CLK_RX_HALF_OUT    => clk_rxhalf_s,
    CLK_RX_FULL_OUT    => clk_rxfull_s,
    
    IS_SLAVE           => '1',
    RX_DLM             => rx_dlm_s,
    RX_DLM_WORD        => rx_dlm_word_s,
    TX_DLM             => tx_dlm_s,
    TX_DLM_WORD        => tx_dlm_word_s,
    --SFP Connection
    SD_RXD_P_IN        => RX_P_S,
    SD_RXD_N_IN        => RX_N_S,
    SD_TXD_P_OUT       => TX_P_S,
    SD_TXD_N_OUT       => TX_N_S,
    SD_REFCLK_P_IN     => '0',
    SD_REFCLK_N_IN     => '0',
    SD_PRSNT_N_IN      => '0',
    SD_LOS_IN          => '0',
    SD_TXDIS_OUT       => open,
    --Control Interface
    SCI_DATA_IN        => (others => '0'),
    SCI_DATA_OUT       => open,
    SCI_ADDR           => (others => '0'),
    SCI_READ           => '0',
    SCI_WRITE          => '0',
    SCI_ACK            => open,
    SCI_NACK           => open,
    -- Status and control port
    STAT_OP            => open,
    CTRL_OP            => (others => '0'),
    STAT_DEBUG         => open,
    CTRL_DEBUG         => (others => '0')
    );


end architecture;