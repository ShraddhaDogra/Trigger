library IEEE;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.trb_net_std.all;
use work.trb_net16_hub_func.all;

entity flexi_PCS_channel_synch is
   generic (
     SYSTEM :     positive);
  port (
    RESET              : in  std_logic;
    SYSTEM_CLK         : in  std_logic;
    --to and from media
    TX_CLK             : in  std_logic;
    RX_CLK             : in  std_logic;
    RXD                : in  std_logic_vector(15 downto 0);
    RX_K               : in  std_logic_vector(1 downto 0);
    RX_RST             : out std_logic;
    CV                 : in  std_logic_vector(1 downto 0);
    TXD                : out std_logic_vector(15 downto 0);
    TX_K               : out std_logic_vector(1 downto 0);
    MEDIA_STATUS       : in  std_logic_vector(15 downto 0);
    MEDIA_CONTROL      : out std_logic_vector(15 downto 0);
    --to and from trbnet
    --to media
    MED_DATAREADY_IN   : in  std_logic;
    MED_DATA_IN        : in  std_logic_vector(15 downto 0);
    MED_READ_OUT       : out std_logic;
    --from media
    MED_DATA_OUT       : out std_logic_vector(15 downto 0);
    MED_DATAREADY_OUT  : out std_logic;
    MED_READ_IN        : in  std_logic;
    --trbnet control and status
    MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
    MED_STAT_OP        : out std_logic_vector(15 downto 0);
    MED_CTRL_OP        : in  std_logic_vector(15 downto 0);  --debug
    LINK_DEBUG         : out std_logic_vector(31 downto 0)
    );
end flexi_PCS_channel_synch;

architecture flexi_PCS_channel_synch of flexi_PCS_channel_synch is
  
  component flexi_PCS_fifo_EBR
    port (
      Data        : in  std_logic_vector(17 downto 0);
      WrClock     : in  std_logic;
      RdClock     : in  std_logic;
      WrEn        : in  std_logic;
      RdEn        : in  std_logic;
      Reset       : in  std_logic;
      RPReset     : in  std_logic;
      Q           : out std_logic_vector(17 downto 0);
      Empty       : out std_logic;
      Full        : out std_logic;
      AlmostEmpty : out std_logic;
      AlmostFull  : out std_logic
      );
  end component;
  
  component ecp2m_link_fifo
    port (
      Data        : in  std_logic_vector(17 downto 0);
      WrClock     : in  std_logic;
      RdClock     : in  std_logic;
      WrEn        : in  std_logic;
      RdEn        : in  std_logic;
      Reset       : in  std_logic;
      RPReset     : in  std_logic;
      Q           : out std_logic_vector(17 downto 0);
      Empty       : out std_logic;
      Full        : out std_logic;
      AlmostEmpty : out std_logic;
      AlmostFull  : out std_logic
      );
  end component;
  --keep fifos as small as possible, remember but low prioriority 
  --disable transmition during synch
  component up_down_counter
    generic (
      NUMBER_OF_BITS : positive);
    port (
      CLK       : in  std_logic;
      RESET     : in  std_logic;
      COUNT_OUT : out std_logic_vector(NUMBER_OF_BITS-1 downto 0);
      UP_IN     : in  std_logic;
      DOWN_IN   : in  std_logic);
  end component;
  
  component edge_to_pulse
    port (
      CLOCK      : in  std_logic;
      EN_CLK     : in  std_logic;
      SIGNAL_IN  : in  std_logic;
      PULSE      : out std_logic);
  end component;
  
  component cross_clk
    port (
      WrAddress : in  std_logic_vector(2 downto 0);
      Data      : in  std_logic_vector(31 downto 0);
      WrClock   : in  std_logic;
      WE        : in  std_logic;
      WrClockEn : in  std_logic;
      RdAddress : in  std_logic_vector(2 downto 0);
      RdClock   : in  std_logic;
      RdClockEn : in  std_logic;
      Reset     : in  std_logic;
      Q         : out std_logic_vector(31 downto 0));
  end component;

  component trbv2_cross_clk
    port (
      addra : in  std_logic_vector(2 downto 0);
      addrb : in  std_logic_vector(2 downto 0);
      clka  : in  std_logic;
      clkb  : in  std_logic;
      dina  : in  std_logic_vector(31 downto 0);
      dinb  : in  std_logic_vector(31 downto 0);
      douta : out std_logic_vector(31 downto 0);
      doutb : out std_logic_vector(31 downto 0);
      wea   : in  std_logic;
      web   : in  std_logic);
  end component;

  component trbv2_link_fifo
    port (
      din          : IN  std_logic_VECTOR(17 downto 0);
      rd_clk       : IN  std_logic;
      rd_en        : IN  std_logic;
      rst          : IN  std_logic;
      wr_clk       : IN  std_logic;
      wr_en        : IN  std_logic;
      almost_empty : OUT std_logic;
      almost_full  : OUT std_logic;
      dout         : OUT std_logic_VECTOR(17 downto 0);
      empty        : OUT std_logic;
      full         : OUT std_logic);
  end component;
  
  type SYNC_MACHINE is (FIRST_DUMMY_STATE, START_COUNTER, RESYNC0, RESYNC1, RESYNC2, RESYNC3, WAIT_1, WAIT_2, WAIT_3,  NORMAL_OPERATION_1, NORMAL_OPERATION_2);
  signal SYNC_CURRENT, SYNC_NEXT : SYNC_MACHINE;
--   attribute syn_enum_encoding : string;
--   attribute syn_enum_encoding of SYNC_MACHINE : type is "safe";
--   attribute syn_enum_encoding of SYNC_MACHINE : type is "sequential";

  signal fsm_debug_register : std_logic_vector(3 downto 0);
  signal resync_counter_up :std_logic;
  signal resync_counter_clr :std_logic;
  signal resync_counter : std_logic_vector(31 downto 0);
  signal cv_i : std_logic_vector(1 downto 0);
  signal cv_or : std_logic;
  signal cv_counter : std_logic_vector(15 downto 0);
  signal rx_rst_i : std_logic;
  signal rxd_synch_i : std_logic_vector(15 downto 0);
  signal rxd_synch_synch_i : std_logic_vector(15 downto 0);
  signal rx_k_synch_i : std_logic_vector(1 downto 0);
  signal rx_k_synch_synch_i : std_logic_vector(1 downto 0);
  signal fifo_data_in : std_logic_vector(17 downto 0);
  signal fifo_data_out : std_logic_vector(17 downto 0);
  signal fifo_wr_en : std_logic;
  signal fifo_rd_en : std_logic;
  signal fifo_rst : std_logic;
  signal fifo_full : std_logic;
  signal fifo_almost_full : std_logic;
  signal fifo_empty : std_logic;
  signal fifo_almost_empty : std_logic;
  signal packet_number : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal start_counter_1 : std_logic_vector(31 downto 0);
  signal start_counter_2 : std_logic_vector(31 downto 0);
  signal fifo_rd_pulse : std_logic;
  signal fifo_rd_cnt : std_logic_vector(15 downto 0);
  signal fifo_wr_cnt : std_logic_vector(15 downto 0);
  signal not_fifo_empty : std_logic;

  -----------------------------------------------------------------------------
  -- fifo to optical link
  -----------------------------------------------------------------------------
  signal data_valid_out_i : std_logic;
  signal fifo_opt_not_empty : std_logic;
  signal fifo_opt_empty : std_logic;
  signal fifo_opt_empty_synch : std_logic;
  signal data_opt_in : std_logic_vector(17 downto 0);
  signal txd_fifo_out : std_logic_vector(17 downto 0);
  signal fifo_opt_full : std_logic;
  signal fifo_opt_almost_empty : std_logic;
  signal fifo_opt_almost_full : std_logic;
  signal not_clk : std_logic;
  signal txd_synch_i : std_logic_vector(15 downto 0);
  signal tx_k_i : std_logic;
  signal fifo_opt_empty_synch_synch : std_logic;
  signal fifo_rd_en_hub : std_logic;
--  constant SYSTEM : Integer := 1;
  signal wait_for_write_up : std_logic;
  signal wait_for_write_counter : std_logic_vector(28 downto 0);
  signal link_reset_counter : std_logic_vector(2 downto 0);
  signal link_reset_counter_clr : std_logic;
  signal link_reset_counter_up  : std_logic;
  signal link_reset_out : std_logic;
  signal med_error_out_i : std_logic_vector(2 downto 0);
  signal fifo_rst_fsm : std_logic;
  signal fsm_debug_register_fsm: std_logic_vector(3 downto 0);
  signal rx_rst_fsm : std_logic;           
  signal resync_counter_up_fsm : std_logic;
  signal resync_counter_clr_fsm : std_logic;
  signal wait_for_write_up_fsm : std_logic; 
  signal MED_READ_OUT_fsm : std_logic; 
  signal diod_counter : std_logic_vector(28 downto 0);
  signal cv_counter_reset : std_logic;
  signal rx_comma : std_logic_vector(1 downto 0);
  signal rx_comma_synch : std_logic_vector(1 downto 0);

  --crossing clk memory
  signal cross_wraddress_i : std_logic_vector(2 downto 0);
  signal cross_data_i      : std_logic_vector(31 downto 0);
  signal cross_rdaddress_i : std_logic_vector(2 downto 0);
  signal cross_q_i         : std_logic_vector(31 downto 0);
  signal rx_comma_synch_err : std_logic;
  signal lost_connection_count : std_logic_vector(15 downto 0);
  
begin

  --reset from link
  RESET_FROM_LINK: process (RX_CLK, RESET)
  begin 
    if rising_edge(RX_CLK) then
      if RESET = '1' then          
        link_reset_counter_up <= '0';
      elsif rxd_synch_i = x"ffff" and link_reset_counter < 5 then
        link_reset_counter_up <= '1';
      else
        link_reset_counter_up <= '0';
      end if;
    end if;
  end process RESET_FROM_LINK;

  SET_RESET: process (SYSTEM_CLK, RESET)
  begin  
    if rising_edge(SYSTEM_CLK) then
      if RESET = '1' then
        link_reset_out <= '0';
      elsif link_reset_counter = 5 then
        link_reset_out <= '1';
      else
        link_reset_out <= '0';
      end if;
    end if;
  end process SET_RESET;
  
  RESET_LINK_ERROR_COUNTER: process (RX_CLK, RESET)
  begin 
    if rising_edge(RX_CLK) then
      if RESET = '1' then  
        link_reset_counter_clr <= '0';
      elsif link_reset_counter = 3 then
        link_reset_counter_clr <= link_reset_out or RESET;
      elsif link_reset_counter < 3 and rxd_synch_i /= x"ffff" then
        link_reset_counter_clr <= '1';
      else
        link_reset_counter_clr <= '0';
      end if;
    end if;
  end process RESET_LINK_ERROR_COUNTER;
  
  LINK_RESET_COUNTER_INST: up_down_counter
    generic map (
      NUMBER_OF_BITS => 3)
    port map (
      CLK       => RX_CLK,
      RESET     => link_reset_counter_clr,
      COUNT_OUT => link_reset_counter,
      UP_IN     => link_reset_counter_up,
      DOWN_IN   => '0');

  --  STAT_OP(15) <= link_reset_out;
  --link
  
  MED_STAT_OP(2 downto 0) <= med_error_out_i;
  SEND_ERROR: process (SYSTEM_CLK, RESET,SYNC_CURRENT)
  begin
    if rising_edge(SYSTEM_CLK) then
      if RESET = '1' then
        med_error_out_i <= ERROR_NC;
      elsif SYNC_CURRENT = NORMAL_OPERATION_1 or SYNC_CURRENT = NORMAL_OPERATION_2 then
        med_error_out_i <= ERROR_OK;
      elsif SYNC_CURRENT = WAIT_1 or SYNC_CURRENT = WAIT_2 then
        med_error_out_i <= ERROR_WAIT;
      else
        med_error_out_i <= ERROR_NC;
      end if;
    end if;
  end process SEND_ERROR;
  MED_STAT_OP(15 downto 10) <= (others => '0');
  MED_STAT_OP(8 downto 3) <= (others => '0');
  
  PACKET_NUM: process (SYSTEM_CLK, RESET,fifo_rd_en)
  begin
    if rising_edge(SYSTEM_CLK) then
      if RESET = '1' then
        packet_number <= "011";
      elsif fifo_rd_en = '1'  then
        if packet_number = c_max_word_number then
          packet_number <= "000";
        else
          packet_number <= packet_number + 1;
        end if;
      end if;
    end if;
  end process PACKET_NUM;
  MED_PACKET_NUM_OUT <= packet_number;
  
  LINK_STATUS : process (SYSTEM_CLK,RESET)
  begin
    if rising_edge(SYSTEM_CLK) then
      if RESET = '1' then
        RX_RST          <= '0';
        LINK_DEBUG(15 downto 0) <= (others => '0');
      else
        RX_RST          <= rx_rst_i;
        LINK_DEBUG(3 downto 0) <= fsm_debug_register_fsm;
        LINK_DEBUG(7 downto 4) <= fifo_empty & fifo_full & fifo_opt_empty & fifo_opt_full;--fifo_almost_full &
        --'0';
        LINK_DEBUG(15 downto 8) <= fifo_wr_cnt(3 downto 0) & fifo_rd_cnt(3 downto 0);--resync_counter(15 downto 8);--cv_counter(15 downto 12) & cv_counter(3 downto 0); --        LINK_DEBUG(11 downto 8) <=  fifo_wr_cnt(4 downto 1);--resync_counter(15 downto 8);--cv_counter(15 downto 12) & cv_counter(3 downto 0);
        LINK_DEBUG(31 downto 16) <= fifo_data_out(3 downto 0) & lost_connection_count(7 downto 0) & '0' & rx_comma_synch & MEDIA_STATUS(0) ;
      end if;
    end if;
  end process LINK_STATUS;
 -- LINK_DEBUG(31 downto 16) <= fifo_data_in(15 downto 0);
  
  -----------------------------------------------------------------------------
  -- data from hub to link
  -----------------------------------------------------------------------------


    CROSS_WR_ADDRESS: process (RX_CLK, RESET)
    begin
      if rising_edge (RX_CLK) then
        if RESET = '1' then               
          cross_wraddress_i <= "000";
        else
          cross_wraddress_i <= cross_wraddress_i + 1;
        end if;
      end if;
    end process CROSS_WR_ADDRESS;
    
    CROSS_RD_ADDRESS: process (SYSTEM_CLK, RESET)
    begin
      if rising_edge (SYSTEM_CLK) then
        if RESET = '1' then               
          cross_rdaddress_i <= "000";
        else
          cross_rdaddress_i <= cross_rdaddress_i + 1;
        end if;
      end if;
    end process CROSS_RD_ADDRESS;
  
  cross_data_i <= x"0000000" & "00" & rx_comma;
  
  data_opt_in <= "00" & MED_DATA_IN;
  
  SYSTEM_SCM_MEMa: if SYSTEM=1 generate
    CHANNEL_FIFO_TO_OPT: flexi_PCS_fifo_EBR
      port map (
        Data        => data_opt_in,
        WrClock     => SYSTEM_CLK,
        RdClock     => TX_CLK,
        WrEn        => MED_DATAREADY_IN,
        RdEn        => fifo_opt_not_empty,
        Reset       => fifo_rst,
        RPReset     => fifo_rst,
        Q           => txd_fifo_out,
        Empty       => fifo_opt_empty,
        Full        => fifo_opt_full,
        AlmostEmpty => fifo_opt_almost_empty,
        AlmostFull  => fifo_opt_almost_full
        );
    
    CROSS_CLK_DPMEM: cross_clk
      port map (
          WrAddress => cross_wraddress_i,
          Data      => cross_data_i,
          WrClock   => RX_CLK,
          WE        => '1',
          WrClockEn => '1',
          RdAddress => cross_rdaddress_i,
          RdClock   => SYSTEM_CLK,
          RdClockEn => '1',
          Reset     => Reset,
          Q         => cross_q_i);
    
  end generate SYSTEM_SCM_MEMa;

  SYSTEM_ECP2_MEMa: if SYSTEM=2 generate
    CHANNEL_FIFO_TO_OPT: ecp2m_link_fifo
      port map (
        Data        => data_opt_in,
        WrClock     => SYSTEM_CLK,
        RdClock     => TX_CLK,
        WrEn        => MED_DATAREADY_IN,
        RdEn        => fifo_opt_not_empty,
        Reset       => fifo_rst,
        RPReset     => fifo_rst,
        Q           => txd_fifo_out,
        Empty       => fifo_opt_empty,
        Full        => fifo_opt_full,
        AlmostEmpty => fifo_opt_almost_empty,
        AlmostFull  => fifo_opt_almost_full
        );
  end generate SYSTEM_ECP2_MEMa;

  SYSTEMT_TRBv2_MEMa: if SYSTEM=6 generate

    CHANNEL_FIFO_TO_FPGA: trbv2_link_fifo
      port map (
          din          => data_opt_in,
          rd_clk       => TX_CLK,
          rd_en        => fifo_opt_not_empty,
          rst          => fifo_rst,
          wr_clk       => SYSTEM_CLK,
          wr_en        => MED_DATAREADY_IN,
          almost_empty => fifo_opt_almost_empty,
          almost_full  => fifo_opt_almost_full,
          dout         => txd_fifo_out,
          empty        => fifo_opt_empty,
          full         => fifo_opt_full);

    TRBv2_CROSS_CLK_INST: trbv2_cross_clk
      port map (
          addra => cross_wraddress_i,
          addrb => cross_rdaddress_i,
          clka  => RX_CLK,
          clkb  => SYSTEM_CLK,
          dina  => cross_data_i,
          dinb  => x"00000000",
          douta => open,
          doutb => cross_q_i,
          wea   => '1',
          web   => '0');
    
  end generate SYSTEMT_TRBv2_MEMa;
  
  DATA_SEND_TO_LINK: process (TX_CLK, RESET, MED_DATAREADY_IN,fifo_opt_empty_synch,fifo_opt_empty_synch_synch)
  begin
    if rising_edge(TX_CLK) then       
      if RESET = '1' then
        tx_k_i <= '0';
        txd_synch_i <= (others => '0');
        fifo_opt_empty_synch <= fifo_opt_empty;
        fifo_opt_empty_synch_synch <= fifo_opt_empty_synch;
        fifo_opt_not_empty <= not fifo_opt_empty;
      elsif fifo_opt_empty_synch = '0' and fifo_opt_empty_synch_synch ='0' then
        tx_k_i <= '0';
        txd_synch_i <= txd_fifo_out(15 downto 0);
        fifo_opt_empty_synch <= fifo_opt_empty;
        fifo_opt_empty_synch_synch <= fifo_opt_empty_synch;
        fifo_opt_not_empty <= not fifo_opt_empty;
      else
        tx_k_i <= '1';
        txd_synch_i <= x"c5bc";
        fifo_opt_empty_synch <= fifo_opt_empty;
        fifo_opt_empty_synch_synch <= fifo_opt_empty_synch;
        fifo_opt_not_empty <= not fifo_opt_empty;
      end if;
    end if;
  end process DATA_SEND_TO_LINK;
  
  SYNC_DATA : process (TX_CLK)
  begin
    if rising_edge(TX_CLK) then
      TXD     <= txd_synch_i;
      TX_K(0) <= tx_k_i;
      TX_K(1) <= '0';
    end if;
  end process SYNC_DATA;

  -----------------------------------------------------------------------------
  -- from link to hub
  -----------------------------------------------------------------------------
  SYSTEM_SCM_MEMb: if SYSTEM=1 generate
    CHANNEL_FIFO_TO_FPGA: flexi_PCS_fifo_EBR
      port map (
        Data        => fifo_data_in,
        WrClock     => RX_CLK,
        RdClock     => SYSTEM_CLK,
        WrEn        => fifo_wr_en,
        RdEn        => fifo_rd_en,
        Reset       => fifo_rst,
        RPReset     => fifo_rst,
        Q           => fifo_data_out,
        Empty       => fifo_empty,
        Full        => fifo_full,
        AlmostEmpty => fifo_almost_empty,
        AlmostFull  => fifo_almost_full
        );
  end generate SYSTEM_SCM_MEMb;

  SYSTEM_ECP2_MEMb: if SYSTEM=2 generate
    CHANNEL_FIFO_TO_FPGA: ecp2m_link_fifo
      port map (
        Data        => fifo_data_in,
        WrClock     => RX_CLK,
        RdClock     => SYSTEM_CLK,
        WrEn        => fifo_wr_en,
        RdEn        => fifo_rd_en,
        Reset       => fifo_rst,
        RPReset     => fifo_rst,
        Q           => fifo_data_out,
        Empty       => fifo_empty,
        Full        => fifo_full,
        AlmostEmpty => fifo_almost_empty,
        AlmostFull  => fifo_almost_full
        );
  end generate SYSTEM_ECP2_MEMb;

  SYSTEM_TRBv2: if SYSTEM=6 generate

    CHANNEL_FIFO_TO_FPGA: trbv2_link_fifo
      port map (
          din          => fifo_data_in,
          rd_clk       => SYSTEM_CLK,
          rd_en        => fifo_rd_en,
          rst          => fifo_rst,
          wr_clk       => RX_CLK,
          wr_en        => fifo_wr_en,
          almost_empty => fifo_almost_empty,
          almost_full  => fifo_almost_full,
          dout         => fifo_data_out,
          empty        => fifo_empty,
          full         => fifo_full);
    
  end generate SYSTEM_TRBv2;
  
  not_fifo_empty <= not fifo_empty;
  RD_FIFO_PULSE: edge_to_pulse
    port map (
      clock  => SYSTEM_CLK,
      en_clk => '1',
      signal_in => not_fifo_empty,
      pulse  => fifo_rd_pulse);
  
  READING_THE_FIFO: process (SYSTEM_CLK, RESET, fifo_rd_pulse,MED_READ_IN,fifo_empty,data_valid_out_i)
  begin
    if rising_edge(SYSTEM_CLK) then
      if RESET = '1' then
        data_valid_out_i <= '0';
        fifo_rd_en_hub <= '0';
      elsif fifo_rd_pulse = '1' then
        data_valid_out_i <= '1';
        fifo_rd_en_hub <= MED_READ_IN;
      elsif MED_READ_IN = '1' and fifo_empty = '1' and data_valid_out_i = '1' then
        data_valid_out_i <= '0';
        fifo_rd_en_hub <= '0';
      elsif data_valid_out_i = '1' and fifo_empty = '0' then
        data_valid_out_i <= '1';
        fifo_rd_en_hub <= MED_READ_IN;
      end if;
    end if;
  end process READING_THE_FIFO;
  
  MED_DATAREADY_OUT <= data_valid_out_i;
  fifo_rd_en <= (fifo_rd_en_hub and (not fifo_empty)) or fifo_rd_pulse;
  MED_DATA_OUT <= fifo_data_out(15 downto 0);
  
  VALID_DATA_SEND_TO_API: process (RX_CLK, RESET)
  begin
    if rising_edge(RX_CLK) then
      if RESET = '1' then
        rxd_synch_i <= (others => '0');
        rxd_synch_synch_i <= rxd_synch_i;
        rx_k_synch_i <= "00";
        rx_k_synch_synch_i <= rx_k_synch_i;
      else
        rxd_synch_i <= RXD;
        rxd_synch_synch_i <= rxd_synch_i;
        rx_k_synch_i <= RX_K;
        rx_k_synch_synch_i <= rx_k_synch_i;
      end if;
    end if;
  end process VALID_DATA_SEND_TO_API;


  
  SHIFT_OR_NOT_DATA_IN: process (RX_CLK, RESET, SYNC_CURRENT)
  begin
    if rising_edge(RX_CLK) then
      if RESET = '1' then
        fifo_data_in <= (others => '0');
      elsif SYNC_CURRENT = NORMAL_OPERATION_2 and CV="00" then
        fifo_data_in <= '0' & (not RX_K(0)) & RXD;
        fifo_wr_en <= not RX_K(0);
      elsif SYNC_CURRENT = NORMAL_OPERATION_1 and CV="00" then
        fifo_data_in <= '0' & (not RX_K(1)) & RXD(7 downto 0) & rxd_synch_i(15 downto 8);
        fifo_wr_en <= not rx_k_synch_i(1);
      else
        fifo_data_in <= (others => '0');
        fifo_wr_en <= '0';
      end if;
    end if;
  end process SHIFT_OR_NOT_DATA_IN;

  SAVE_COMA: process (RX_CLK, RESET)
  begin  
    if rising_edge(RX_CLK) then
      if RESET = '1' then                
        rx_comma <= "00";
      elsif (rxd_synch_i = x"50bc" or rxd_synch_i = x"c5bc") and rx_k_synch_i(0) = '1' and cv_i = "00" then
        rx_comma <= "01";
      elsif (rxd_synch_i = x"bc50" or rxd_synch_i = x"bcc5") and rx_k_synch_i(1) = '1' and cv_i = "00" then  
        rx_comma <= "10";
      elsif cv_i /= "00" then
        rx_comma <= "11";
      else
        rx_comma <= "00";
      end if;
    end if;
  end process SAVE_COMA;

  
  SYNC_CLOCK : process (SYSTEM_CLK, RESET)
  begin
    if rising_edge (SYSTEM_CLK) then
      if RESET = '1'  then
        SYNC_CURRENT      <= FIRST_DUMMY_STATE;--no_sim  --
--sim--        SYNC_CURRENT <= NORMAL_OPERATION_2;
        cv_i               <= (others => '0');
        fifo_rst           <= '1';
        fsm_debug_register <= "1111";
        rx_rst_i           <= '0';
        resync_counter_up  <= '0';
        resync_counter_clr <= '1';
        wait_for_write_up  <= '0';
        MED_READ_OUT       <= '0';
        rx_comma_synch     <= "00";
      else
        SYNC_CURRENT      <= SYNC_NEXT;
        cv_i               <= CV;
        fifo_rst           <= fifo_rst_fsm;
        fsm_debug_register <= fsm_debug_register_fsm;
        rx_rst_i           <= rx_rst_fsm;
        resync_counter_up  <= resync_counter_up_fsm;
        resync_counter_clr <= resync_counter_clr_fsm;
        wait_for_write_up  <= wait_for_write_up_fsm;
        MED_READ_OUT       <= MED_READ_OUT_fsm;
        rx_comma_synch     <= cross_q_i(1 downto 0);
      end if;
    end if;
  end process SYNC_CLOCK;
  
  SYNC_FSM : process(SYNC_CURRENT)
  begin
    fifo_rst_fsm <= '0';
    fsm_debug_register_fsm <= "1111";
    rx_rst_fsm       <= '0';
    resync_counter_up_fsm <= '1';
    resync_counter_clr_fsm <= '0';
    wait_for_write_up_fsm <= '0';
    MED_READ_OUT_fsm <= '0';
    SYNC_NEXT <= RESYNC0;
    
    case (SYNC_CURRENT) is
      --check the sfp, pll lock and so on
      -- all counters are are only reset in state START_COUNTER
      
      when FIRST_DUMMY_STATE =>
        resync_counter_up_fsm <= '0';
        fsm_debug_register_fsm <= "0001";
        SYNC_NEXT <= START_COUNTER;
        
      when START_COUNTER    =>
        fsm_debug_register_fsm <= "0010";
        resync_counter_up_fsm <= '0';
        resync_counter_clr_fsm <= '1';
        fifo_rst_fsm <= '1';
        SYNC_NEXT <= RESYNC0;
        
      when RESYNC0    =>
        fsm_debug_register_fsm <= "0011";
        resync_counter_up_fsm <= '0';
        if MEDIA_STATUS(0) = '1' then
          SYNC_NEXT <= START_COUNTER;
        elsif rx_comma_synch = "01" or rx_comma_synch = "10" then
          SYNC_NEXT <= WAIT_1;
        else
          SYNC_NEXT <= RESYNC1;
        end if;
        --SYNC_NEXT <= RESYNC1;
        
      when RESYNC1 =>
        fsm_debug_register_fsm <= "0100";
        rx_rst_fsm       <= '1';
        if resync_counter(9) = '1' then
          SYNC_NEXT <= RESYNC2;
        else
          SYNC_NEXT <= RESYNC1;
        end if;
        
       when RESYNC2 =>                  -- just waiting
         fsm_debug_register_fsm <= "0101";
       if resync_counter(18) = '1' then  --at least 400us
         SYNC_NEXT <= RESYNC3;
       else
         SYNC_NEXT <= RESYNC2;
       end if;
         
      when RESYNC3 =>                   -- check for comma
         fsm_debug_register_fsm <= "0110";
         if    rx_comma_synch = "01" or rx_comma_synch = "10" then
           SYNC_NEXT <= WAIT_2;--no_sim--
--sim--           SYNC_NEXT <= NORMAL_OPERATION_2;
         else
           SYNC_NEXT <= START_COUNTER;
         end if;
         
      when WAIT_1 =>                    -- wait for comma
        fsm_debug_register_fsm <= "0111";
        if resync_counter(28) = '1' then
          SYNC_NEXT <= WAIT_3;
        elsif resync_counter(27) = '1' and (rx_comma_synch = "00" or rx_comma_synch = "11") then
          SYNC_NEXT <= START_COUNTER;
        else
          SYNC_NEXT <= WAIT_1;
        end if;
        
      when WAIT_3 =>
        fsm_debug_register_fsm <= "1001";
        wait_for_write_up_fsm <= '1';
        if wait_for_write_counter(28)='1' and rx_comma_synch = "01" then
          SYNC_NEXT <= NORMAL_OPERATION_2;
        elsif wait_for_write_counter(28)='1' and rx_comma_synch = "10"  then
          SYNC_NEXT <= NORMAL_OPERATION_1;
        elsif rx_comma_synch = "11" then
          SYNC_NEXT <= START_COUNTER;
        else
          SYNC_NEXT <= WAIT_3;
        end if;
        
      when NORMAL_OPERATION_1 =>
--sim--         fifo_rst <=RESET;
         fsm_debug_register_fsm <= "1010";
         resync_counter_up_fsm <= '0';
         MED_READ_OUT_fsm <= '1';
         if rx_comma_synch = "11" then
--       if MEDIA_STATUS(0) = '1' then

           SYNC_NEXT <= START_COUNTER;
         else
           SYNC_NEXT <= NORMAL_OPERATION_1;
         end if;

      when NORMAL_OPERATION_2 =>
--sim--         fifo_rst <=RESET;
        fsm_debug_register_fsm <= "1011";
        resync_counter_up_fsm <= '0';
        MED_READ_OUT_fsm <= '1';
        if rx_comma_synch = "11" then
--           if MEDIA_STATUS(0) = '1' then        
          SYNC_NEXT <= START_COUNTER;
        else
          SYNC_NEXT <= NORMAL_OPERATION_2;
        end if;


      when others =>
        fsm_debug_register_fsm <= "0000";
        SYNC_NEXT <= START_COUNTER;
        
    end case;
  end process SYNC_FSM;

  LED_FOR_LINK: process (SYSTEM_CLK)
  begin 
    if rising_edge(SYSTEM_CLK) then
      if RESET = '1' then             
        MED_STAT_OP(9) <= '1';
      elsif fsm_debug_register < 9 and  fsm_debug_register > 3  then
        MED_STAT_OP(9) <= diod_counter(23);
      elsif fsm_debug_register = 9 then
        MED_STAT_OP(9) <= diod_counter(26);
      elsif fsm_debug_register > 9 then
        MED_STAT_OP(9) <= '0';
      else
        MED_STAT_OP(9) <= '1';
      end if;
    end if;
  end process LED_FOR_LINK;

  DIOD_COUNTER_INST: up_down_counter
    generic map (
        NUMBER_OF_BITS => 29)
    port map (
        CLK       => SYSTEM_CLK,
        RESET     => '0',
        COUNT_OUT => diod_counter,
        UP_IN     => '1',
        DOWN_IN   => '0');
  
  WAIT_FOR_SENDING: up_down_counter
    generic map (
        NUMBER_OF_BITS => 29)
    port map (
        CLK       => SYSTEM_CLK,
        RESET     => resync_counter_clr,
        COUNT_OUT => wait_for_write_counter,
        UP_IN     => wait_for_write_up,
        DOWN_IN   => '0');
  
  RESYNC_COUNTER_INST: up_down_counter
    generic map (
        NUMBER_OF_BITS => 32)
    port map (
        CLK       => SYSTEM_CLK,
        RESET     => resync_counter_clr,
        COUNT_OUT => resync_counter,
        UP_IN     => resync_counter_up,
        DOWN_IN   => '0');
  
  cv_or <= cv_i(0) or cv_i(1);
  
  CV_COUNTER_INST: up_down_counter
    generic map (
        NUMBER_OF_BITS => 16)
    port map (
        CLK       => RX_CLK,
        RESET     => RESET,
        COUNT_OUT => cv_counter,
        UP_IN     => cv_or,
        DOWN_IN   => '0');
  SYNCH_ERR_COUNT : process (SYSTEM_CLK, RESET)
  begin  
    if rising_edge(SYSTEM_CLK) then  
      if RESET = '1' then
        rx_comma_synch_err <= '0';
      elsif SYNC_CURRENT = NORMAL_OPERATION_1 or SYNC_CURRENT = NORMAL_OPERATION_2 then
        rx_comma_synch_err <= rx_comma_synch(1) and rx_comma_synch(0);
      else
        rx_comma_synch_err <= '0';
      end if;
    end if;
  end process SYNCH_ERR_COUNT;

  LINK_CONECTION_LOST_COUNTER: up_down_counter
    generic map (
        NUMBER_OF_BITS => 16)
    port map (
        CLK       => RX_CLK,
        RESET     => RESET,
        COUNT_OUT => lost_connection_count,
        UP_IN     => rx_comma_synch_err,
        DOWN_IN   => '0');
  
  WRITE_COUNTER: up_down_counter
    generic map (
        NUMBER_OF_BITS => 16)
    port map (
        CLK       => SYSTEM_CLK,
        RESET     => RESET,
        COUNT_OUT => fifo_wr_cnt,
        UP_IN     => fifo_wr_en,
        DOWN_IN   => '0');
  
  READ_COUNTER: up_down_counter
    generic map (
        NUMBER_OF_BITS => 16)
    port map (
        CLK       => SYSTEM_CLK,
        RESET     => RESET,
        COUNT_OUT => fifo_rd_cnt,
        UP_IN     => MED_DATAREADY_IN,
        DOWN_IN   => '0');

end flexi_PCS_channel_synch;

