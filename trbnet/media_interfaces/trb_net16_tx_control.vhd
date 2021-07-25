library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net16_tx_control is
port(
  TXCLK_IN                       : in  std_logic;
  RXCLK_IN                       : in  std_logic;
  SYSCLK_IN                      : in  std_logic;
  RESET_IN                       : in  std_logic;

  TX_DATA_IN                     : in  std_logic_vector(15 downto 0);
  TX_PACKET_NUMBER_IN            : in  std_logic_vector(2 downto 0);
  TX_WRITE_IN                    : in  std_logic;
  TX_READ_OUT                    : out std_logic;

  TX_DATA_OUT                    : out std_logic_vector( 7 downto 0);
  TX_K_OUT                       : out std_logic;

  REQUEST_RETRANSMIT_IN          : in  std_logic;
  REQUEST_POSITION_IN            : in  std_logic_vector( 7 downto 0);

  START_RETRANSMIT_IN            : in  std_logic;
  START_POSITION_IN              : in  std_logic_vector( 7 downto 0);

  SEND_LINK_RESET_IN             : in  std_logic;
  TX_ALLOW_IN                    : in  std_logic;

  DEBUG_OUT                      : out std_logic_vector(31 downto 0);
  STAT_REG_OUT                   : out std_logic_vector(31 downto 0)
  );
end entity;



architecture arch of trb_net16_tx_control is

-- gk 05.10.10
  component lattice_ecp2m_fifo_18x16_dualport
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

-- gk 05.10.10
component trb_net_CRC8 is
  port(
    CLK       : in  std_logic;
    RESET     : in  std_logic;
    CLK_EN    : in  std_logic;
    DATA_IN   : in  std_logic_vector(7 downto 0);
    CRC_OUT   : out std_logic_vector(7 downto 0);
    CRC_match : out std_logic
    );
end component;

  type state_t is (SLEEP, SEND_IDLE_L, SEND_IDLE_H, SEND_DATA_L, SEND_DATA_H,
                   SEND_START_L, SEND_START_H, SEND_REQUEST_L, SEND_REQUEST_H,
                   SEND_RESET, SEND_CHKSUM_L, SEND_CHKSUM_H);  -- gk 05.10.10
  signal current_state           : state_t;

  type ram_t is array(0 to 255) of std_logic_vector(17 downto 0);
  signal ram                     : ram_t;

  signal ram_write               : std_logic;
  signal ram_write_addr          : unsigned(7 downto 0);
  signal ram_read                : std_logic;
  signal ram_read_addr           : unsigned(7 downto 0);
  signal ram_dout                : std_logic_vector(17 downto 0);
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

  signal start_retransmit_i      : std_logic;
  signal request_retransmit_i    : std_logic;

  signal buf_tx_read_out         : std_logic;
  signal tx_data_25_i            : std_logic_vector(17 downto 0);
  signal tx_allow_qtx            : std_logic;
  signal tx_allow_q              : std_logic;
  signal send_link_reset_qtx     : std_logic;
  signal ct_fifo_empty           : std_logic;
  signal ct_fifo_write           : std_logic;
  signal ct_fifo_read            : std_logic;
  signal ct_fifo_full            : std_logic;
  signal ct_fifo_afull           : std_logic;
  signal ct_fifo_reset           : std_logic;

  -- gk 05.10.10
  signal save_sop                : std_logic;
  signal save_eop                : std_logic;
  signal load_sop                : std_logic;
  signal load_eop                : std_logic;
  signal crc_reset               : std_logic;
  signal crc_q                   : std_logic_vector(7 downto 0);
  signal crc_en                  : std_logic;
  signal crc_data                : std_logic_vector(7 downto 0);

begin

----------------------------------------------------------------------
-- Clock Domain Transfer
----------------------------------------------------------------------
-- gk 05.10.10
  THE_CT_FIFO : lattice_ecp2m_fifo_18x16_dualport
    port map(
      Data(15 downto 0) => TX_DATA_IN,
      Data(16)          => save_sop,
      Data(17)          => save_eop,
      WrClock           => SYSCLK_IN,
      RdClock           => TXCLK_IN,
      WrEn              => ct_fifo_write,
      RdEn              => ct_fifo_read,
      Reset             => ct_fifo_reset,
      RPReset           => ct_fifo_reset,
      Q(17 downto 0)    => tx_data_25_i,
      Empty             => ct_fifo_empty,
      Full              => ct_fifo_full,
      AlmostFull        => ct_fifo_afull
      );

  THE_RD_PROC : process(SYSCLK_IN)
    begin
      if rising_edge(SYSCLK_IN) then
        buf_tx_read_out  <= tx_allow_q  and not ct_fifo_afull ;
      end if;
    end process;

  ct_fifo_reset <= not tx_allow_qtx;
  TX_READ_OUT   <= buf_tx_read_out;

  ct_fifo_write <= buf_tx_read_out and TX_WRITE_IN;
  ct_fifo_read  <= tx_allow_qtx and not ram_afull and not ct_fifo_empty;

  -- gk 05.10.10
  save_sop <= '1' when (TX_PACKET_NUMBER_IN = c_H0) else '0';
  save_eop <= '1' when (TX_PACKET_NUMBER_IN = c_F3) else '0';

----------------------------------------------------------------------
-- RAM
----------------------------------------------------------------------


  THE_RAM_WR_PROC : process(TXCLK_IN, RESET_IN)
    begin
      if RESET_IN = '1' then
        ram_write <= '0';
      elsif rising_edge(TXCLK_IN) then
        ram_write   <= ct_fifo_read;
      end if;
    end process;

--RAM
  THE_RAM_PROC : process(TXCLK_IN)
    begin
      if rising_edge(TXCLK_IN) then
        if ram_write = '1' then
          ram((to_integer(ram_write_addr))) <= tx_data_25_i;
        end if;
        ram_dout <= ram(to_integer(ram_read_addr));
      end if;
    end process;

--RAM read pointer
  THE_READ_CNT : process(TXCLK_IN, RESET_IN)
    begin
      if RESET_IN = '1' then
        ram_read_addr <= (others => '0');
      elsif rising_edge(TXCLK_IN) then
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
  THE_WRITE_CNT : process(TXCLK_IN, RESET_IN)
    begin
      if RESET_IN = '1' then
        ram_write_addr <= (others => '0');
      elsif rising_edge(TXCLK_IN) then
        if tx_allow_qtx = '0' then
          ram_write_addr <= (others => '0');
        elsif ram_write = '1' then
          ram_write_addr <= ram_write_addr + to_unsigned(1,1);
        end if;
      end if;
    end process;


--RAM fill level counter
  THE_FILL_CNT : process(TXCLK_IN, RESET_IN)
    begin
      if RESET_IN = '1' then
        ram_fill_level <= (others => '0');
      elsif rising_edge(TXCLK_IN) then
        if tx_allow_qtx = '0' then
          ram_fill_level <= (others => '0');
        else
          ram_fill_level <= ram_write_addr - ram_read_addr;
        end if;
      end if;
    end process;


--RAM empty
--   ram_empty <= not or_all(std_logic_vector(ram_write_addr) xor std_logic_vector(ram_read_addr)) and not RESET_IN;
  ram_empty <= '1' when (ram_write_addr = ram_read_addr) or RESET_IN = '1' else '0';
  ram_afull <= '1' when ram_fill_level >= 4 else '0';



----------------------------------------------------------------------
-- TX control state machine
----------------------------------------------------------------------

  THE_DATA_CONTROL_FSM : process(TXCLK_IN, RESET_IN)
    begin
      if rising_edge(TXCLK_IN) then
        ram_read               <= '0';

        case current_state is
          when SLEEP =>
            TX_DATA_OUT        <= x"BC";
            TX_K_OUT           <= '1';
            current_state      <= SEND_IDLE_L;

          when SEND_DATA_L =>
            TX_DATA_OUT        <= ram_dout(7 downto 0);
            load_sop           <= ram_dout(16);
            load_eop           <= ram_dout(17);
            TX_K_OUT           <= '0';
            current_state      <= SEND_DATA_H;

          when SEND_DATA_H =>
            TX_DATA_OUT        <= ram_dout(15 downto 8);
            TX_K_OUT           <= '0';
            --current_state    <= see below

	-- gk 05.10.10
          when SEND_CHKSUM_L =>
            TX_DATA_OUT        <= x"FD";
            TX_K_OUT           <= '1';
            load_sop           <= '0';
            load_eop           <= '0';
            current_state      <= SEND_CHKSUM_H;

	-- gk 05.10.10
          when SEND_CHKSUM_H =>
            TX_DATA_OUT        <= crc_q;
            TX_K_OUT           <= '0';
--             current_state      <= SEND_IDLE_L;

          when SEND_IDLE_L =>
            TX_DATA_OUT        <= x"BC";
            TX_K_OUT           <= '1';
            current_state      <= SEND_IDLE_H;

          when SEND_IDLE_H =>
            TX_DATA_OUT        <= x"50";
            TX_K_OUT           <= '0';
            --current_state    <= see below

          when SEND_START_L =>
            TX_DATA_OUT        <= x"FB";
            TX_K_OUT           <= '1';
            current_state      <= SEND_START_H;

          when SEND_START_H =>
            TX_DATA_OUT        <= std_logic_vector(ram_read_addr);
            TX_K_OUT           <= '0';
            --current_state    <= see below

          when SEND_REQUEST_L =>
            TX_DATA_OUT        <= x"F7";
            TX_K_OUT           <= '1';
            current_state      <= SEND_REQUEST_H;

          when SEND_REQUEST_H =>
            TX_DATA_OUT        <= request_position_i;
            TX_K_OUT           <= '0';
            --current_state    <= see below

          when SEND_RESET =>
            TX_DATA_OUT        <= x"FE";
            TX_K_OUT           <= '1';
            if send_link_reset_qtx = '0' then
              current_state    <= SEND_IDLE_L;
            end if;

          when others =>
            current_state      <= SEND_IDLE_L;
        end case;

        if current_state = SEND_START_H or
            current_state = SEND_IDLE_H  or
            current_state = SEND_DATA_H  or
            current_state = SEND_REQUEST_H or
            current_state = SEND_CHKSUM_H or
            current_state = SLEEP then
          if tx_allow_qtx = '0' then
            current_state    <= SEND_IDLE_L;
          elsif send_link_reset_qtx = '1' then
            current_state    <= SEND_RESET;
          elsif make_request_i = '1' then
            current_state    <= SEND_REQUEST_L;
          elsif make_restart_i = '1' then
            current_state    <= SEND_START_L;
          elsif (load_eop = '1') then
            current_state    <= SEND_CHKSUM_L;
          elsif ram_empty = '0' then
            ram_read         <= '1';
            current_state    <= SEND_DATA_L;
          else
            current_state    <= SEND_IDLE_L;
          end if;

        end if;
      end if;
      if RESET_IN = '1' then
        ram_read <= '0';
      end if;
    end process;

----------------------------------------------------------------------
--
----------------------------------------------------------------------

  THE_SYS_TO_TX_SYNC : signal_sync
    generic map(
      WIDTH => 2,
      DEPTH => 2
      )
    port map(
      RESET    => '0',
      CLK0     => TXCLK_IN,
      CLK1     => TXCLK_IN,
      D_IN(0)  => TX_ALLOW_IN,
      D_IN(1)  => SEND_LINK_RESET_IN,
      D_OUT(0) => tx_allow_qtx,
      D_OUT(1) => send_link_reset_qtx
      );

  THE_TX_TO_SYS_SYNC : signal_sync
    generic map(
      WIDTH => 1,
      DEPTH => 2
      )
    port map(
      RESET    => '0',
      CLK0     => SYSCLK_IN,
      CLK1     => SYSCLK_IN,
      D_IN(0)  => tx_allow_qtx,
      D_OUT(0) => tx_allow_q
      );

  THE_RETRANSMIT_PULSE_SYNC_1 : pulse_sync
    port map(
      CLK_A_IN        => SYSCLK_IN,
      RESET_A_IN      => RESET_IN,
      PULSE_A_IN      => REQUEST_RETRANSMIT_IN,
      CLK_B_IN        => TXCLK_IN,
      RESET_B_IN      => RESET_IN,
      PULSE_B_OUT     => request_retransmit_i
    );

  THE_RETRANSMIT_PULSE_SYNC_2 : pulse_sync
    port map(
      CLK_A_IN        => SYSCLK_IN,
      RESET_A_IN      => RESET_IN,
      PULSE_A_IN      => START_RETRANSMIT_IN,
      CLK_B_IN        => TXCLK_IN,
      RESET_B_IN      => RESET_IN,
      PULSE_B_OUT     => start_retransmit_i
    );

  THE_POSITION_REG : process(SYSCLK_IN)
    begin
      if rising_edge(SYSCLK_IN) then
        if REQUEST_RETRANSMIT_IN = '1' then
          request_position_q <= REQUEST_POSITION_IN;
        end if;
        if START_RETRANSMIT_IN = '1' then
          restart_position_q <= START_POSITION_IN;
        end if;
      end if;
    end process;


--Store Request Retransmit position
  THE_STORE_REQUEST_PROC : process(TXCLK_IN, RESET_IN)
    begin
      if RESET_IN = '1' then
        make_request_i <= '0';
        request_position_i <= (others => '0');
      elsif rising_edge(TXCLK_IN) then
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
  THE_STORE_RESTART_PROC : process(TXCLK_IN, RESET_IN)
    begin
      if RESET_IN = '1' then
        make_restart_i           <= '0';
        restart_position_i       <= (others => '0');
      elsif rising_edge(TXCLK_IN) then
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

  load_read_pointer_i    <= '1' when current_state = SEND_START_L else '0';

  -- gk 05.10.10
  crc_reset <= '1' when ((RESET_IN = '1') or (current_state = SEND_CHKSUM_H) or (current_state = SEND_START_H)) else '0';
  crc_en    <= '1' when ((current_state = SEND_DATA_L) or (current_state = SEND_DATA_H)) else '0';
  crc_data  <= ram_dout(15 downto 8) when (current_state = SEND_DATA_H) else ram_dout(7 downto 0);

  -- gk 05.10.10
  CRC_CALC : trb_net_CRC8
    port map(
      CLK       => TXCLK_IN,
      RESET     => crc_reset,
      CLK_EN    => crc_en,
      DATA_IN   => crc_data,
      CRC_OUT   => crc_q,
      CRC_match => open
      );


----------------------------------------------------------------------
-- Debug
----------------------------------------------------------------------
  DEBUG_OUT(0) <= ram_read;
  DEBUG_OUT(1) <= ct_fifo_write;
  DEBUG_OUT(2) <= ct_fifo_read;
  DEBUG_OUT(3) <= tx_allow_qtx;
  DEBUG_OUT(4) <= ram_empty;
  DEBUG_OUT(5) <= ram_afull;


  process(SYSCLK_IN)
    begin
      if rising_edge(SYSCLK_IN) then
        STAT_REG_OUT(7 downto 0)   <= std_logic_vector(ram_fill_level);
        STAT_REG_OUT(15 downto 8)  <= std_logic_vector(ram_read_addr);
        STAT_REG_OUT(16)           <= ram_afull;
        STAT_REG_OUT(17)           <= ram_empty;
        STAT_REG_OUT(18)           <= tx_allow_qtx;
        STAT_REG_OUT(19)           <= TX_ALLOW_IN;
        STAT_REG_OUT(20)           <= make_restart_i;
        STAT_REG_OUT(21)           <= make_request_i;
        STAT_REG_OUT(22)           <= load_eop;
        STAT_REG_OUT(31 downto 23) <= (others => '0');
      end if;
    end process;




end architecture;