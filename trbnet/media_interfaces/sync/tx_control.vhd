library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.med_sync_define.all;

entity tx_control is
  port(
    CLK_200                        : in  std_logic;
    CLK_100                        : in  std_logic;
    RESET_IN                       : in  std_logic;

    TX_DATA_IN                     : in  std_logic_vector(15 downto 0);
    TX_PACKET_NUMBER_IN            : in  std_logic_vector(2 downto 0);
    TX_WRITE_IN                    : in  std_logic;
    TX_READ_OUT                    : out std_logic;

    TX_DATA_OUT                    : out std_logic_vector( 7 downto 0);
    TX_K_OUT                       : out std_logic;
    TX_CD_OUT                      : out std_logic;

    REQUEST_RETRANSMIT_IN          : in  std_logic := '0';
    REQUEST_POSITION_IN            : in  std_logic_vector( 7 downto 0) := (others => '0');

    START_RETRANSMIT_IN            : in  std_logic := '0';
    START_POSITION_IN              : in  std_logic_vector( 7 downto 0) := (others => '0');
    --send_dlm: 200 MHz, 1 clock strobe, data valid until next DLM
    SEND_DLM                       : in  std_logic := '0';
    SEND_DLM_WORD                  : in  std_logic_vector( 7 downto 0) := (others => '0');
    
    SEND_LINK_RESET_IN             : in  std_logic := '0';
    TX_ALLOW_IN                    : in  std_logic := '0';
    RX_ALLOW_IN                    : in  std_logic := '0';

    DEBUG_OUT                      : out std_logic_vector(31 downto 0);
    STAT_REG_OUT                   : out std_logic_vector(31 downto 0)
    );
end entity;



architecture arch of tx_control is


  type state_t is (SEND_IDLE_L, SEND_IDLE_H, SEND_DATA_L, SEND_DATA_H, SEND_DLM_L, SEND_DLM_H,
                   SEND_START_L, SEND_START_H, SEND_REQUEST_L, SEND_REQUEST_H,
                   SEND_RESET, SEND_CHKSUM_L, SEND_CHKSUM_H);  -- gk 05.10.10
  signal current_state           : state_t;
  signal state_bits              : std_logic_vector(3 downto 0);
  
  type ram_t is array(0 to 255) of std_logic_vector(17 downto 0);
  signal ram                     : ram_t;

  signal ram_write               : std_logic := '0';
  signal ram_write_addr          : unsigned(7 downto 0) := (others => '0');
  signal last_ram_write_addr     : unsigned(7 downto 0) := (others => '0');
  signal ram_read                : std_logic := '0';
  signal ram_read_addr           : unsigned(7 downto 0) := (others => '0');
  signal ram_dout                : std_logic_vector(17 downto 0);
  signal next_ram_dout           : std_logic_vector(17 downto 0);
  signal ram_fill_level          : unsigned(7 downto 0);
  signal ram_empty               : std_logic;
  signal ram_afull               : std_logic;

  signal request_position_q      : std_logic_vector( 7 downto 0);
  signal restart_position_q      : std_logic_vector( 7 downto 0);
  signal request_position_i      : std_logic_vector( 7 downto 0);
  signal restart_position_i      : std_logic_vector( 7 downto 0);
  signal make_request_i          : std_logic;
  signal make_restart_i          : std_logic;
  signal load_read_pointer_i     : std_logic;
  signal send_dlm_in_i           : std_logic;
  signal send_dlm_i              : std_logic;
  signal start_retransmit_i      : std_logic;
  signal request_retransmit_i    : std_logic;

  signal buf_tx_read_out         : std_logic;
  signal tx_data_200             : std_logic_vector(17 downto 0);
  signal tx_allow_qtx            : std_logic;
  signal rx_allow_qtx            : std_logic;
  signal tx_allow_q              : std_logic;
  signal send_link_reset_qtx     : std_logic;
  signal ct_fifo_empty           : std_logic;
  signal ct_fifo_write           : std_logic := '0';
  signal ct_fifo_read            : std_logic := '0';
  signal ct_fifo_full            : std_logic;
  signal ct_fifo_afull           : std_logic;
  signal ct_fifo_reset           : std_logic;
  signal last_ct_fifo_empty      : std_logic;
  signal last_ct_fifo_read       : std_logic;
  signal debug_sending_dlm       : std_logic;

  -- gk 05.10.10
  signal save_sop                : std_logic;
  signal save_eop                : std_logic;
  signal load_sop                : std_logic;
  signal load_eop                : std_logic;
  signal crc_reset               : std_logic;
  signal crc_q                   : std_logic_vector(7 downto 0);
  signal crc_en                  : std_logic;
  signal crc_data                : std_logic_vector(7 downto 0);
  signal first_idle              : std_logic;
  signal toggle_idle             : std_logic;
begin

----------------------------------------------------------------------
-- Clock Domain Transfer
----------------------------------------------------------------------
-- gk 05.10.10
  THE_CT_FIFO : lattice_ecp3_fifo_18x16_dualport_oreg
    port map(
      Data(15 downto 0) => TX_DATA_IN,
      Data(16)          => save_sop,
      Data(17)          => save_eop,
      WrClock           => CLK_100,
      RdClock           => CLK_200,
      WrEn              => ct_fifo_write,
      RdEn              => ct_fifo_read,
      Reset             => ct_fifo_reset,
      RPReset           => ct_fifo_reset,
      Q(17 downto 0)    => tx_data_200,
      Empty             => ct_fifo_empty,
      Full              => ct_fifo_full,
      AlmostFull        => ct_fifo_afull
      );

  THE_RD_PROC : process(CLK_100)
    begin
      if rising_edge(CLK_100) then
        buf_tx_read_out  <= tx_allow_q  and not ct_fifo_afull ;
      end if;
    end process;

  ct_fifo_reset <= not tx_allow_qtx;
  TX_READ_OUT   <= buf_tx_read_out;

  ct_fifo_write <= buf_tx_read_out and TX_WRITE_IN;
  ct_fifo_read  <= tx_allow_qtx and not ram_afull and not ct_fifo_empty;
  
  last_ct_fifo_read   <= ct_fifo_read  when rising_edge(CLK_200);
  last_ct_fifo_empty  <= ct_fifo_empty when rising_edge(CLK_200);
  
  save_sop <= '1' when (TX_PACKET_NUMBER_IN = c_H0) else '0';
  save_eop <= '1' when (TX_PACKET_NUMBER_IN = c_F3) else '0';

----------------------------------------------------------------------
-- RAM
----------------------------------------------------------------------


  THE_RAM_WR_PROC : process(CLK_200)
    begin
--       if RESET_IN = '1' then
--         ram_write <= '0';
--       els
      if rising_edge(CLK_200) then
        ram_write   <= last_ct_fifo_read and not last_ct_fifo_empty;
      end if;
    end process;

--RAM
  THE_RAM_PROC : process(CLK_200)
    begin
      if rising_edge(CLK_200) then
        if ram_write = '1' then
          ram((to_integer(ram_write_addr))) <= tx_data_200;
        end if;
        next_ram_dout <= ram(to_integer(ram_read_addr));
        ram_dout <= next_ram_dout;
      end if;
    end process;

--RAM read pointer
  THE_READ_CNT : process(CLK_200)
    begin
--       if RESET_IN = '1' then
--         ram_read_addr <= (others => '0');
--       els
      if rising_edge(CLK_200) then
        if tx_allow_qtx = '0' then
          ram_read_addr <= (others => '0');
        elsif load_read_pointer_i = '1' then
          ram_read_addr <= unsigned(restart_position_i);
        elsif ram_read = '1' then
          ram_read_addr <= ram_read_addr + to_unsigned(1,1);
        end if;
      end if;
    end process;

--RAM write pointer
  THE_WRITE_CNT : process(CLK_200)
    begin
--       if RESET_IN = '1' then
--         ram_write_addr <= (others => '0');
--       els
      if rising_edge(CLK_200) then
        if tx_allow_qtx = '0' then
          ram_write_addr <= (others => '0');
        elsif ram_write = '1' then
          ram_write_addr <= ram_write_addr + to_unsigned(1,1);
        end if;
      end if;
    end process;


--RAM fill level counter
  THE_FILL_CNT : process(CLK_200)
    begin
--       if RESET_IN = '1' then
--         ram_fill_level <= (others => '0');
--       els
      if rising_edge(CLK_200) then
        if tx_allow_qtx = '0' then
          ram_fill_level <= (others => '0');
        else
          ram_fill_level <= last_ram_write_addr - ram_read_addr;
        end if;
      end if;
    end process;


--RAM empty
--   ram_empty <= not or_all(std_logic_vector(ram_write_addr) xor std_logic_vector(ram_read_addr)) and not RESET_IN;
  ram_empty <= '1' when (last_ram_write_addr = ram_read_addr) or RESET_IN = '1' else '0';
  ram_afull <= '1' when ram_fill_level >= 4 else '0';

  last_ram_write_addr <= ram_write_addr when rising_edge(CLK_200);

----------------------------------------------------------------------
-- TX control state machine
----------------------------------------------------------------------

  THE_DATA_CONTROL_FSM : process(CLK_200, RESET_IN)
    begin
      if rising_edge(CLK_200) then
--         ram_read               <= '0';
        TX_K_OUT               <= '0';
        TX_CD_OUT              <= '0';
        debug_sending_dlm      <= '0';
        first_idle             <= '1';
        case current_state is
          when SEND_IDLE_L =>
            TX_DATA_OUT        <= K_IDLE;
            TX_K_OUT           <= '1';
            current_state      <= SEND_IDLE_H;
            first_idle         <= first_idle;

          when SEND_IDLE_H =>
            if rx_allow_qtx = '1' or toggle_idle = '1' then
              TX_DATA_OUT        <= D_IDLE1;
              toggle_idle        <= rx_allow_qtx;
            else
              TX_DATA_OUT        <= D_IDLE0;
              toggle_idle        <= '1';
            end if;
            TX_CD_OUT            <= first_idle;
            first_idle           <= '0';

          when SEND_DATA_L =>
            TX_DATA_OUT        <= ram_dout(7 downto 0);
            load_sop           <= ram_dout(16);
            load_eop           <= ram_dout(17);
            current_state      <= SEND_DATA_H;

          when SEND_DATA_H =>
            TX_DATA_OUT        <= ram_dout(15 downto 8);

          when SEND_CHKSUM_L =>
            TX_DATA_OUT        <= K_EOP;
            TX_K_OUT           <= '1';
            load_sop           <= '0';
            load_eop           <= '0';
            current_state      <= SEND_CHKSUM_H;

          when SEND_CHKSUM_H =>
            TX_DATA_OUT        <= crc_q;

          when SEND_START_L =>
            TX_DATA_OUT        <= K_BGN;
            TX_K_OUT           <= '1';
            current_state      <= SEND_START_H;

          when SEND_START_H =>
            TX_DATA_OUT        <= std_logic_vector(ram_read_addr);

          when SEND_REQUEST_L =>
            TX_DATA_OUT        <= K_REQ;
            TX_K_OUT           <= '1';
            current_state      <= SEND_REQUEST_H;

          when SEND_DLM_L =>
            TX_DATA_OUT        <= K_DLM;
            TX_K_OUT           <= '1';
            current_state      <= SEND_DLM_H;
            debug_sending_dlm  <= '1';
          
          when SEND_DLM_H =>
            TX_DATA_OUT        <= SEND_DLM_WORD;
            debug_sending_dlm  <= '1';
            
          when SEND_REQUEST_H =>
            TX_DATA_OUT        <= request_position_i;

          when SEND_RESET =>
            TX_DATA_OUT        <= K_RST;
            TX_K_OUT           <= '1';
            if send_link_reset_qtx = '0' then
              current_state    <= SEND_IDLE_L;
            end if;

          when others =>
            current_state      <= SEND_IDLE_L;
        end case;

        if  current_state = SEND_START_H or
            current_state = SEND_IDLE_H  or
            current_state = SEND_DATA_H  or
            current_state = SEND_DLM_H  or
            current_state = SEND_REQUEST_H or
            current_state = SEND_CHKSUM_H  then
          if tx_allow_qtx = '0' then
            current_state    <= SEND_IDLE_L;
          elsif send_link_reset_qtx = '1' then
            current_state    <= SEND_RESET;
          elsif make_request_i = '1' then
            current_state    <= SEND_REQUEST_L;
          elsif make_restart_i = '1' then
            current_state    <= SEND_START_L;
          elsif send_dlm_i = '1' then
            current_state    <= SEND_DLM_L;
--          elsif (load_eop = '1') then
--            current_state    <= SEND_CHKSUM_L;
          elsif ram_empty = '0' then
--             ram_read         <= '1';
            current_state    <= SEND_DATA_L;
          else
            current_state    <= SEND_IDLE_L;
          end if;

        end if;
      end if;
      --async because of oreg.
      if  (current_state = SEND_START_H or current_state = SEND_IDLE_H  or current_state = SEND_DATA_H  or
            current_state = SEND_DLM_H or current_state = SEND_REQUEST_H or current_state = SEND_CHKSUM_H) 
            and ram_empty = '0' and tx_allow_qtx = '1' and send_link_reset_qtx = '0' 
            and make_request_i = '0' and make_restart_i = '0' and send_dlm_i = '0' then  --TODO: Sync these 3 signals
        ram_read <= '1';
      else 
        ram_read <= '0';
      end if;
      if RESET_IN = '1' then
        ram_read <= '0';
      end if;
    end process;

----------------------------------------------------------------------
--
----------------------------------------------------------------------

  txallow_sync  : signal_sync port map(RESET => '0',CLK0 => CLK_200, CLK1 => CLK_200,
                                          D_IN(0)  => TX_ALLOW_IN, 
                                          D_OUT(0) => tx_allow_qtx);
  rxallow_sync  : signal_sync port map(RESET => '0',CLK0 => CLK_200, CLK1 => CLK_200,
                                          D_IN(0)  => RX_ALLOW_IN, 
                                          D_OUT(0) => rx_allow_qtx);
  sendres_sync  : signal_sync port map(RESET => '0',CLK0 => CLK_200, CLK1 => CLK_200,
                                          D_IN(0)  => SEND_LINK_RESET_IN, 
                                          D_OUT(0) => send_link_reset_qtx);
  txallow_sync2 : signal_sync port map(RESET => '0',CLK0 => CLK_100, CLK1 => CLK_100,
                                          D_IN(0)  => tx_allow_qtx, 
                                          D_OUT(0) => tx_allow_q);


  THE_RETRANSMIT_PULSE_SYNC_1 : pulse_sync
    port map(
      CLK_A_IN        => CLK_100,
      RESET_A_IN      => RESET_IN,
      PULSE_A_IN      => REQUEST_RETRANSMIT_IN,
      CLK_B_IN        => CLK_200,
      RESET_B_IN      => RESET_IN,
      PULSE_B_OUT     => request_retransmit_i
    );

  THE_RETRANSMIT_PULSE_SYNC_2 : pulse_sync
    port map(
      CLK_A_IN        => CLK_100,
      RESET_A_IN      => RESET_IN,
      PULSE_A_IN      => START_RETRANSMIT_IN,
      CLK_B_IN        => CLK_200,
      RESET_B_IN      => RESET_IN,
      PULSE_B_OUT     => start_retransmit_i
    );

--   THE_RETRANSMIT_PULSE_SYNC_3 : pulse_sync
--     port map(
--       CLK_A_IN        => CLK_100,
--       RESET_A_IN      => RESET_IN,
--       PULSE_A_IN      => SEND_DLM,
--       CLK_B_IN        => CLK_200,
--       RESET_B_IN      => RESET_IN,
--       PULSE_B_OUT     => send_dlm_in_i
--     );    
  send_dlm_in_i <= SEND_DLM;
    
  THE_POSITION_REG : process(CLK_100)
    begin
      if rising_edge(CLK_100) then
        if REQUEST_RETRANSMIT_IN = '1' then
          request_position_q <= REQUEST_POSITION_IN;
        end if;
        if START_RETRANSMIT_IN = '1' then
          restart_position_q <= START_POSITION_IN;
        end if;
      end if;
    end process;


--Store Request Retransmit position
  THE_STORE_REQUEST_PROC : process(CLK_200, RESET_IN)
    begin
      if RESET_IN = '1' then
        make_request_i <= '0';
        request_position_i <= (others => '0');
      elsif rising_edge(CLK_200) then
        if tx_allow_qtx = '0' then
          make_request_i     <= '0';
          request_position_i <= (others => '0');
        elsif request_retransmit_i = '1' then
          make_request_i     <= '1';
          request_position_i <= request_position_q;
        elsif current_state = SEND_REQUEST_L then
          make_request_i     <= '0';
        elsif current_state = SEND_REQUEST_H then
          request_position_i <= (others => '0');
        end if;
      end if;
    end process;


--Store Restart position
  THE_STORE_RESTART_PROC : process(CLK_200, RESET_IN)
    begin
      if RESET_IN = '1' then
        make_restart_i           <= '0';
        restart_position_i       <= (others => '0');
      elsif rising_edge(CLK_200) then
        if tx_allow_qtx = '0' then
          make_restart_i         <= '0';
          restart_position_i     <= (others => '0');
        elsif start_retransmit_i = '1' then
          make_restart_i         <= '1';
          restart_position_i     <= restart_position_q;
        elsif current_state = SEND_START_L then
          make_restart_i         <= '0';
        elsif current_state = SEND_START_H then
          restart_position_i     <= (others => '0');
        end if;
      end if;
    end process;

--Store Restart position
  THE_STORE_DLM_PROC : process(CLK_200, RESET_IN)
    begin
      if RESET_IN = '1' then
        send_dlm_i           <= '0';
      elsif rising_edge(CLK_200) then
        if tx_allow_qtx = '0' then
          send_dlm_i         <= '0';
        elsif send_dlm_in_i = '1' then
          send_dlm_i         <= '1';
        elsif current_state = SEND_DLM_L then
          send_dlm_i         <= '0';
        end if;
      end if;
    end process;    
    
  load_read_pointer_i    <= '1' when current_state = SEND_START_L else '0';

  -- gk 05.10.10
  crc_reset <= '1' when ((RESET_IN = '1') or (current_state = SEND_CHKSUM_H) or (current_state = SEND_START_H)) else '0';
  crc_en    <= '1' when ((current_state = SEND_DATA_L) or (current_state = SEND_DATA_H)) else '0';
  crc_data  <= ram_dout(15 downto 8) when (current_state = SEND_DATA_H) else ram_dout(7 downto 0);

  -- gk 05.10.10
  CRC_CALC : trb_net_CRC8
    port map(
      CLK       => CLK_200,
      RESET     => crc_reset,
      CLK_EN    => crc_en,
      DATA_IN   => crc_data,
      CRC_OUT   => crc_q,
      CRC_match => open
      );


----------------------------------------------------------------------
-- Debug
----------------------------------------------------------------------
  DEBUG_OUT(0) <= ct_fifo_afull;
  DEBUG_OUT(1) <= ct_fifo_write;
  DEBUG_OUT(2) <= ct_fifo_read;
  DEBUG_OUT(3) <= tx_allow_qtx;
--   DEBUG_OUT(4) <= ram_empty;
  DEBUG_OUT(5) <= ram_afull;
  DEBUG_OUT(6) <= debug_sending_dlm when rising_edge(CLK_200);
  DEBUG_OUT(7) <= TX_WRITE_IN;
--   DEBUG_OUT(8) <= ram_read;
  DEBUG_OUT(9) <= ram_write;
  DEBUG_OUT(13 downto 10) <= state_bits;
  DEBUG_OUT(15 downto 14) <= "00";
  DEBUG_OUT(23 downto 16) <= tx_data_200(7 downto 0);
  DEBUG_OUT(31 downto 24) <= ram_dout(7 downto 0);

  process(CLK_100)
    begin
      if rising_edge(CLK_100) then
        STAT_REG_OUT <= (others => '0');
--         STAT_REG_OUT(7 downto 0)   <= std_logic_vector(ram_fill_level);
        STAT_REG_OUT(3 downto 0)   <= state_bits;
        
--         STAT_REG_OUT(7)   <= TX_K_OUT;
--         STAT_REG_OUT(15 downto 8) <= TX_DATA_OUT;
        STAT_REG_OUT(15 downto 8)  <= std_logic_vector(ram_read_addr);
--         STAT_REG_OUT(16)           <= ram_afull;
        STAT_REG_OUT(17)           <= ram_empty;
        STAT_REG_OUT(18)           <= tx_allow_qtx;
        STAT_REG_OUT(19)           <= TX_ALLOW_IN;
        STAT_REG_OUT(20)           <= make_restart_i;
        STAT_REG_OUT(21)           <= make_request_i;
        STAT_REG_OUT(22)           <= load_eop;
        STAT_REG_OUT(23)           <= send_dlm_i;
        STAT_REG_OUT(24)           <= make_restart_i;
        STAT_REG_OUT(25)           <= make_request_i;
        STAT_REG_OUT(26)           <= load_read_pointer_i;
        STAT_REG_OUT(27)           <= ct_fifo_afull;
        STAT_REG_OUT(28)           <= ct_fifo_read;
        STAT_REG_OUT(29)           <= ct_fifo_write;
        STAT_REG_OUT(30)           <= RESET_IN;
        STAT_REG_OUT(31)           <= '0';
--         STAT_REG_OUT(31 downto 27) <= (others => '0');
      end if;
    end process;

state_bits <= x"0" when current_state = SEND_IDLE_L else
              x"1" when current_state = SEND_IDLE_H else
              x"2" when current_state = SEND_DATA_L else
              x"3" when current_state = SEND_DATA_H else
              x"4" when current_state = SEND_DLM_L else
              x"5" when current_state = SEND_DLM_H else
              x"6" when current_state = SEND_START_L else
              x"7" when current_state = SEND_START_H else
              x"8" when current_state = SEND_REQUEST_L else
              x"9" when current_state = SEND_REQUEST_H else
              x"a" when current_state = SEND_CHKSUM_L else
              x"b" when current_state = SEND_CHKSUM_H else
              x"c" when current_state = SEND_RESET else
              x"F";

end architecture;
