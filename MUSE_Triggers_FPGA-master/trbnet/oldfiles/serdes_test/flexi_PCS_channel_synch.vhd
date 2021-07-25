library IEEE;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--library UNISIM;
--use UNISIM.VCOMPONENTS.all;
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.trb_net_std.all;
use work.trb_net16_hub_func.all;

entity flexi_PCS_channel_synch is

  port (
    SYSTEM_CLK       : in  std_logic;
    TX_CLK           : in  std_logic;
    RX_CLK           : in  std_logic;
    RESET            : in  std_logic;
    RXD              : in  std_logic_vector(15 downto 0);
    RXD_SYNCH        : out  std_logic_vector(15 downto 0);
    RX_K             : in  std_logic_vector(1 downto 0);
    RX_RST           : out std_logic;
    CV               : in  std_logic_vector(1 downto 0);
    TXD              : in  std_logic_vector(15 downto 0);
    TXD_SYNCH        : out  std_logic_vector(15 downto 0);
    TX_K             : out std_logic_vector(1 downto 0);
    DATA_VALID_IN    : in  std_logic;
    DATA_VALID_OUT   : out std_logic;
    FLEXI_PCS_STATUS : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
    MED_ERROR_OUT    : out std_logic_vector(2 downto 0);
    MED_READ_IN      : in std_logic
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
      AlmostFull  : out std_logic);
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
      AlmostFull  : out std_logic);
  end component;
  
  component simpleupcounter_32bit
    port (
      QOUT : out std_logic_vector(31 downto 0);
      UP   : in  std_logic;
      CLK  : in  std_logic;
      CLR  : in  std_logic);
    end component;
  component simpleupcounter_16bit
    port (
      QOUT : out std_logic_vector(15 downto 0);
      UP   : in  std_logic;
      CLK  : in  std_logic;
      CLR  : in  std_logic);
    end component;
  component simpleupcounter_8bit
    port (
      QOUT : out std_logic_vector(15 downto 0);
      UP   : in  std_logic;
      CLK  : in  std_logic;
      CLR  : in  std_logic);
    end component;
  component edge_to_pulse
    port (
      CLOCK      : in  std_logic;
      EN_CLK     : in  std_logic;
      SIGNAL_IN  : in  std_logic;
      PULSE      : out std_logic);
  end component;
  type SYNCH_MACHINE is (IDLE, SYNCH_START, RESYNC1, RESYNC2, RESYNC3, WAIT_1, WAIT_2,  NORMAL_OPERATION_1, NORMAL_OPERATION_2);
  signal SYNCH_CURRENT, SYNCH_NEXT : SYNCH_MACHINE;
  signal fsm_debug_register : std_logic_vector(2 downto 0);
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
  signal fifo_rd_en_dv : std_logic;
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
  constant SYSTEM : Integer := 2;
begin
  SEND_ERROR: process (SYSTEM_CLK, RESET,SYNCH_CURRENT)
  begin
    if rising_edge(SYSTEM_CLK) then
      if RESET = '1' then
        MED_ERROR_OUT <= ERROR_NC;
      elsif SYNCH_CURRENT = NORMAL_OPERATION_1 or SYNCH_CURRENT = NORMAL_OPERATION_2 then
        MED_ERROR_OUT <= ERROR_OK;
      elsif SYNCH_CURRENT = WAIT_1 or SYNCH_CURRENT = WAIT_2 then
        MED_ERROR_OUT <= ERROR_WAIT;
      else
        MED_ERROR_OUT <= ERROR_NC;
      end if;
    end if;
  end process SEND_ERROR;
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
        FLEXI_PCS_STATUS(15 downto 0) <= (others => '0');
      else
        RX_RST          <= rx_rst_i;
        FLEXI_PCS_STATUS(2 downto 0) <= fsm_debug_register;
        FLEXI_PCS_STATUS(7 downto 3) <= fifo_empty & fifo_full & fifo_opt_empty & fifo_opt_full & DATA_VALID_IN;--fifo_almost_full &
        --'0';
        FLEXI_PCS_STATUS(15 downto 8) <= fifo_wr_cnt(3 downto 0) & fifo_rd_cnt(3 downto 0);--resync_counter(15 downto 8);--cv_counter(15 downto 12) & cv_counter(3 downto 0);
--        FLEXI_PCS_STATUS(11 downto 8) <=  fifo_wr_cnt(4 downto 1);--resync_counter(15 downto 8);--cv_counter(15 downto 12) & cv_counter(3 downto 0);
      end if;
    end if;
  end process LINK_STATUS;
  -----------------------------------------------------------------------------
  -- data from hub to link
  -----------------------------------------------------------------------------
  data_opt_in <= "00" & TXD;
  SYSTEM_SCM_MEMa: if SYSTEM=1 generate
    CHANNEL_FIFO_TO_OPT: flexi_PCS_fifo_EBR
      port map (
        Data        => data_opt_in,
        WrClock     => SYSTEM_CLK,
        RdClock     => TX_CLK,
        WrEn        => DATA_VALID_IN,
        RdEn        => fifo_opt_not_empty,
        Reset       => fifo_rst,
        RPReset     => fifo_rst,
        Q           => txd_fifo_out,
        Empty       => fifo_opt_empty,
        Full        => fifo_opt_full,
        AlmostEmpty => fifo_opt_almost_empty,
        AlmostFull  => fifo_opt_almost_full
        );
  end generate SYSTEM_SCM_MEMa;

  SYSTEM_ECP2_MEMa: if SYSTEM=2 generate
    CHANNEL_FIFO_TO_OPT: ecp2m_link_fifo
      port map (
        Data        => data_opt_in,
        WrClock     => SYSTEM_CLK,
        RdClock     => TX_CLK,
        WrEn        => DATA_VALID_IN,
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

  
    DATA_SEND_TO_LINK: process (TX_CLK, RESET, DATA_VALID_IN,fifo_opt_empty_synch,fifo_opt_empty_synch_synch)
    begin
      if rising_edge(TX_CLK) then          --falling ???
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
  SYNCH_DATA: process (TX_CLK)
  begin
    if rising_edge(TX_CLK) then
      TXD_SYNCH <= txd_synch_i;
      TX_K(0) <= tx_k_i;
      TX_K(1) <= '0';
    end if;
  end process SYNCH_DATA;
--  TX_FORCE_DISP(1) <= '0';
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
  DATA_VALID_OUT <= data_valid_out_i;
  fifo_rd_en <= (fifo_rd_en_hub and (not fifo_empty)) or fifo_rd_pulse;
  RXD_SYNCH <= fifo_data_out(15 downto 0);
--  DATA_VALID_OUT <= fifo_data_out(16) and (not fifo_empty);
  VALID_DATA_SEND_TO_API: process (RX_CLK, RESET)
  begin
    if rising_edge(RX_CLK) then
      if RESET = '1' then
        rxd_synch_i <= (others => '0');
        rxd_synch_synch_i <= rxd_synch_i;
        rx_k_synch_i <= "00";
        rx_k_synch_synch_i <= rx_k_synch_i;
      else-- RX_K(0) = '1' then
        rxd_synch_i <= RXD;
        rxd_synch_synch_i <= rxd_synch_i;
        rx_k_synch_i <= RX_K;
        rx_k_synch_synch_i <= rx_k_synch_i;
      end if;
    end if;
  end process VALID_DATA_SEND_TO_API;
  SHIFT_OR_NOT_DATA_IN: process (RX_CLK, RESET, SYNCH_CURRENT)
  begin
    if rising_edge(RX_CLK) then
      if RESET = '1' then
        fifo_data_in <= (others => '0');
      elsif SYNCH_CURRENT = NORMAL_OPERATION_2 then
        fifo_data_in <= '0' & (not RX_K(0)) & RXD;
      elsif SYNCH_CURRENT = NORMAL_OPERATION_1 then
        fifo_data_in <= '0' & (not RX_K(1)) & rxd_synch_i(7 downto 0) & RXD(15 downto 8);
      else
        fifo_data_in <= (others => '0');
      end if;
    end if;
  end process SHIFT_OR_NOT_DATA_IN;

--  SYNCH_CLOCK   : process (RX_CLK, RESET)
  SYNCH_CLOCK   : process (SYSTEM_CLK, RESET)
  begin
    if rising_edge (SYSTEM_CLK) then
      if RESET = '1' then
        SYNCH_CURRENT <= IDLE; --no_sim--
--sim--        SYNCH_CURRENT <= NORMAL_OPERATION_2;
        cv_i <= (others => '0');
      else
        SYNCH_CURRENT <= SYNCH_NEXT;
        cv_i <= CV;
      end if;
    end if;
  end process SYNCH_CLOCK;
  SYNCH_FSM : process( SYNCH_CURRENT, rxd_synch_i, resync_counter, cv_i,RX_K, MED_READ_IN ,fifo_rd_pulse, fifo_rd_en_hub,rx_k_synch_i)
  begin
    case (SYNCH_CURRENT) is
      when IDLE    =>
        fifo_rst <= '1';
        fifo_wr_en <= '0';
        fsm_debug_register(2 downto 0) <= "001";
        rx_rst_i       <= '0';
        resync_counter_up <= '0';
        resync_counter_clr <= '1';
--          if rxd_synch_i = x"bc50" then
--           SYNCH_NEXT <= WAIT_1;--NORMAL_OPERATION_1;--WAIT_1;
        --els
        if rxd_synch_i = x"50bc" or rxd_synch_i = x"c5bc" then
          SYNCH_NEXT <= WAIT_2;--NORMAL_OPERATION_2;  --WAIT_2;
        else
          SYNCH_NEXT <= RESYNC1;
        end if;
      when RESYNC1 =>
        fifo_rst <= '0';
        fifo_wr_en <= '0';
        fsm_debug_register(2 downto 0) <= "010";
        rx_rst_i       <= '1';
        resync_counter_up <= '1';
        resync_counter_clr <= '0';
        if resync_counter(8) = '1' then
          SYNCH_NEXT <= RESYNC2;
        else
          SYNCH_NEXT <= RESYNC1;
        end if;
       when RESYNC2 =>
         fifo_rst <= '0';
         fifo_wr_en <= '0';
         fsm_debug_register(2 downto 0) <= "010";
         rx_rst_i       <= '0';
         resync_counter_up <= '1';
         resync_counter_clr <= '0';
       if resync_counter(16) = '1' then  --at least 400us
         SYNCH_NEXT <= RESYNC3;
       else
         SYNCH_NEXT <= RESYNC2;
       end if;

       when RESYNC3 =>
         fifo_rst <= '0';
         fifo_wr_en <= '0';
         fsm_debug_register(2 downto 0) <= "010";
         rx_rst_i       <= '0';
         resync_counter_up <= '0';
         resync_counter_clr <= '1';
--          if rxd_synch_i = x"bc50" and rx_k_synch_i(1) = '1' then
--            SYNCH_NEXT <= WAIT_1;--NORMAL_OPERATION_1;
         --els
         if (rxd_synch_i = x"50bc" or rxd_synch_i = x"c5bc") and rx_k_synch_i(0) = '1' then
           SYNCH_NEXT <= WAIT_2;--no_sim--
--sim--           SYNCH_NEXT <= NORMAL_OPERATION_2;
         else
           SYNCH_NEXT <= IDLE;
         end if;
      when WAIT_1 =>
        fifo_rst <= '0';
        rx_rst_i   <= '0';
        fifo_wr_en <= '0';
        fsm_debug_register(2 downto 0) <= "011";
        resync_counter_up <= '1';
        resync_counter_clr <= '0';
        if resync_counter(27) = '1' and (rxd_synch_i = x"bc50" or rxd_synch_i = x"bcc5") and rx_k_synch_i(1) = '1' then
          SYNCH_NEXT <= NORMAL_OPERATION_1;
        elsif resync_counter(26) = '1' and (rxd_synch_i /= x"bc50" or rx_k_synch_i(1) = '0')  then
          SYNCH_NEXT <= RESYNC1;
        else
          SYNCH_NEXT <= WAIT_1;
        end if;
      when WAIT_2 =>
        fifo_rst <= '0';
        fifo_wr_en <= '0';
        rx_rst_i       <= '0';
        fsm_debug_register(2 downto 0) <= "011";
        resync_counter_up <= '1';
        resync_counter_clr <= '0';
        if resync_counter(27) = '1' and (rxd_synch_i = x"50bc" or rxd_synch_i = x"c5bc") and rx_k_synch_i(0) = '1' then
          SYNCH_NEXT <= NORMAL_OPERATION_2;
        elsif resync_counter(26) = '1' and (rxd_synch_i(7 downto 0) /= x"bc" or rx_k_synch_i(0) = '0') then
          SYNCH_NEXT <= RESYNC1;
        else
          SYNCH_NEXT <= WAIT_2;
        end if;
      when NORMAL_OPERATION_1 =>
         fifo_rst <= '0';
         fifo_wr_en <= not rx_k_synch_i(1);
         fsm_debug_register(2 downto 0) <= "110";
         rx_rst_i       <= '0';
         resync_counter_up <= '0';
         resync_counter_clr <= '0';
         if cv_i(0) = '1' or cv_i(1) = '1' then
           SYNCH_NEXT <= IDLE;
         else
           SYNCH_NEXT <= NORMAL_OPERATION_1;
         end if;
      when NORMAL_OPERATION_2 =>
         fifo_rst <='0';--no_sim--
--sim--         fifo_rst <=RESET;
         fifo_wr_en <= not rx_k_synch_i(0);              
         fsm_debug_register(2 downto 0) <= "111";
         rx_rst_i       <= '0';
         resync_counter_up <= '0';
         resync_counter_clr <= '0';
         if cv_i(0) = '1' or cv_i(1) = '1' then
           SYNCH_NEXT <= IDLE;
         else
           SYNCH_NEXT <= NORMAL_OPERATION_2;
         end if;
      when others =>
        fifo_rst <= '0';
        fifo_wr_en <= '0';
        resync_counter_up <= '0';
        resync_counter_clr <= '0';
        fsm_debug_register(2 downto 0) <= "000";
        rx_rst_i     <= '0';
        SYNCH_NEXT <= IDLE;
    end case;
  end process SYNCH_FSM;

  RESYNC_COUNTER_INST : simpleupcounter_32bit
    port map (
        QOUT => resync_counter,
        UP   => resync_counter_up,
        CLK  => SYSTEM_CLK,
        CLR  => resync_counter_clr);
  cv_or <= cv_i(0) or cv_i(1);
  CV_COUNTER_INST: simpleupcounter_16bit
    port map (
      QOUT => cv_counter,
      UP   => cv_or,
      CLK  => RX_CLK,
      CLR  => RESET);
   WR_COUNTER_INST: simpleupcounter_16bit
    port map (
      QOUT => fifo_wr_cnt,
      UP   => fifo_wr_en,
      CLK  => SYSTEM_CLK,
      CLR  => RESET);
  fifo_rd_en_dv <= fifo_rd_en and fifo_data_out(16) and fifo_empty;
    RD_COUNTER_INST: simpleupcounter_16bit
    port map (
      QOUT => fifo_rd_cnt,
      UP   => DATA_VALID_IN,--fifo_rd_en_dv,--fifo_rd_en,
      CLK  => SYSTEM_CLK,
      CLR  => RESET);
end flexi_PCS_channel_synch;
--reciving idle for 1ms and start e11o until recive e11o and idle
--write to fifo when rx_k is 1 ?
--  wait for reset
--  wait for pll locked
--  send idles
--  wait 650ms (counter(27) = 1)
--  enable rx
--  wait  650ms (counter(27) = 1)
--  enable tx
--  ready
