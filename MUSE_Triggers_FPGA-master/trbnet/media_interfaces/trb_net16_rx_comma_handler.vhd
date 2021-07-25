library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net16_rx_comma_handler is
port(
  SYSCLK_IN                      : in  std_logic;
  RESET_IN                       : in  std_logic;
  QUAD_RST_IN                    : in  std_logic;
  -- raw data from SerDes receive path
  CLK_IN                         : in  std_logic;
  RX_DATA_IN                     : in  std_logic_vector(7 downto 0);
  RX_K_IN                        : in  std_logic;
  RX_CV_IN                       : in  std_logic;
  RX_DISP_ERR_IN                 : in  std_logic;
  RX_ALLOW_IN                    : in  std_logic;
	-- FIFO interface
	FIFO_DATA_OUT                  : out std_logic_vector(15 downto 0);
	FIFO_WR_OUT                    : out std_logic;
	FIFO_INHIBIT_OUT               : out std_logic;
	-- Special comma actions
	LD_RX_POSITION_OUT             : out std_logic;   --change position in rx fifo
	RX_POSITION_OUT                : out std_logic_vector(7 downto 0);
	LD_START_POSITION_OUT          : out std_logic;   --restart sending from given position
	START_POSITION_OUT             : out std_logic_vector(7 downto 0);
  START_GONE_WRONG_IN            : in  std_logic;
  START_TIMEOUT_OUT              : out std_logic;  -- gk 05.10.10
  RX_RESET_IN                    : in  std_logic;
	-- Check
	COMMA_LOCKED_OUT               : out std_logic;
  -- reset handling
  SEND_RESET_WORDS_OUT           : out std_logic;
  MAKE_TRBNET_RESET_OUT          : out std_logic;
  ENABLE_CORRECTION_IN           : in  std_logic;
  -- Debugging
  STAT_REG_OUT                   : out std_logic_vector(39 downto 0);
  DEBUG_OUT                      : out std_logic_vector(15 downto 0)
);
end entity trb_net16_rx_comma_handler;

architecture arch of trb_net16_rx_comma_handler is

-- components

-- normal signals
signal buf_rx_data          : std_logic_vector(7 downto 0);
signal buf_rx_k             : std_logic;
signal buf_rx_cv            : std_logic;
signal buf_rx_disperr       : std_logic;
signal buf2_rx_data         : std_logic_vector(7 downto 0);
signal buf2_rx_k            : std_logic;
signal buf2_rx_cv           : std_logic;
signal buf2_rx_disperr      : std_logic;
signal buf_data             : std_logic_vector(15 downto 0);
signal buf2_data            : std_logic_vector(15 downto 0);
signal buf_k                : std_logic_vector(1 downto 0);
signal buf_cv               : std_logic_vector(1 downto 0);
signal buf_disperr          : std_logic_vector(1 downto 0);

signal data_valid_x         : std_logic;
signal data_valid           : std_logic;
signal comma_valid_x        : std_logic;

signal c_idle_x             : std_logic;
signal c_idle               : std_logic; -- 0xBC
signal c_reset_x            : std_logic;
signal c_reset              : std_logic; -- 0xFE
signal c_error_x            : std_logic;
signal c_error              : std_logic; -- 0xF7
signal c_stx_x              : std_logic;
signal c_stx                : std_logic; -- 0xFB
signal c_crc_x              : std_logic;
signal c_crc                : std_logic; -- 0xFD
signal c_invalid_k_x        : std_logic;

signal comma_idle           : std_logic; -- correct IDLE comma (/I1/ or /I2/) received
signal comma_idle_x         : std_logic;
signal comma_stx            : std_logic; -- correct StartOfTransmission comma received
signal comma_stx_x          : std_logic;
signal comma_error          : std_logic; -- correct ErrorDetected comma received
signal comma_error_x        : std_logic;
signal comma_crc            : std_logic; -- correct CRC comma received
signal comma_crc_x          : std_logic;
signal comma_crc_q          : std_logic;
signal comma_crc_qq         : std_logic;


signal comma_toggle         : std_logic;
signal rst_toggle           : std_logic;
signal ce_toggle            : std_logic;

signal comma_ctr            : unsigned(3 downto 0);
signal comma_locked_x       : std_logic;
signal comma_locked         : std_logic;

signal fifo_wr_x            : std_logic;
signal fifo_wr              : std_logic;
signal buf_fifo_wr          : std_logic;

signal ld_rx_position       : std_logic;
signal rx_position          : std_logic_vector(7 downto 0);
signal ld_start_position    : std_logic;
signal start_position       : std_logic_vector(7 downto 0);

signal fifo_inhibit         : std_logic;

signal debug                : std_logic_vector(15 downto 0);

signal send_reset_words     : std_logic;
signal make_trbnet_reset    : std_logic;
signal reset_word_cnt       : unsigned(4 downto 0);

signal crc_enable           : std_logic;
signal crc_active           : std_logic;
signal crc_match            : std_logic;
signal crc_reset            : std_logic;

-- gk 05.10.10
signal start_toc            : unsigned(7 downto 0);
signal start_toc_c          : std_logic;

-- gk 06.10.10
signal crc_comma_position   : unsigned(3 downto 0);
signal crc_comma_pos_wrong  : std_logic;

signal counter_crc_mismatch : unsigned(7 downto 0);
signal counter_crc_wrong_pos: unsigned(7 downto 0);
signal counter_cv           : unsigned(7 downto 0);
signal counter_invalid_k    : unsigned(7 downto 0);

signal inc_counter_crc_mismatch : std_logic;
signal inc_counter_crc_wrong_pos: std_logic;
signal inc_counter_cv           : std_logic;
signal inc_counter_invalid_k    : std_logic;
signal crc_wrong_pulse          : std_logic;
signal invalid_k_pulse          : std_logic;
signal cv_pulse                 : std_logic;

begin

----------------------------------------------------------------------
-- TRBnet reset handling (handles 0xFE comma)
----------------------------------------------------------------------
THE_CNT_RESET_PROC: process( CLK_IN )
begin
  if( rising_edge(CLK_IN) ) then
    if( RESET_IN = '1' ) then
      send_reset_words  <= '0';
      make_trbnet_reset <= '0';
      reset_word_cnt    <= (others => '0');
    else
      send_reset_words  <= '0';
      make_trbnet_reset <= '0';
      if( c_reset = '1' ) then
        if( reset_word_cnt(4) = '0' ) then
          reset_word_cnt <= reset_word_cnt + 1;
        else
          send_reset_words <= '1';
        end if;
      else
        reset_word_cnt    <= (others => '0');
        make_trbnet_reset <= reset_word_cnt(4);
      end if;
    end if;
  end if;
end process THE_CNT_RESET_PROC;

----------------------------------------------------------------------
-- sync the incoming data, check for commas
----------------------------------------------------------------------
THE_SYNC_PROC: process( CLK_IN )
begin
	if( rising_edge(CLK_IN) ) then
		buf2_rx_data      <= buf_rx_data; buf_rx_data <= RX_DATA_IN;
		buf2_rx_k         <= buf_rx_k;    buf_rx_k    <= RX_K_IN;
		buf2_rx_cv        <= buf_rx_cv;   buf_rx_cv   <= RX_CV_IN;
    buf2_rx_disperr   <= buf_rx_disperr; buf_rx_disperr   <= RX_DISP_ERR_IN;
		buf_data          <= buf2_rx_data & buf_rx_data;
		buf_k             <= buf2_rx_k    & buf_rx_k;
		buf_cv            <= buf2_rx_cv   & buf_rx_cv;
    buf_disperr       <= buf2_rx_disperr   & buf_rx_disperr;
		c_idle            <= c_idle_x;
		c_reset           <= c_reset_x;
		c_error           <= c_error_x;
		c_stx             <= c_stx_x;
    c_crc             <= c_crc_x;
		comma_idle        <= comma_idle_x;
		comma_stx         <= comma_stx_x;
		comma_error       <= comma_error_x;
		comma_locked      <= comma_locked_x;
    comma_crc         <= comma_crc_x;
    comma_crc_q       <= comma_crc;
    data_valid        <= data_valid_x;
		fifo_wr           <= fifo_wr_x;
    buf_fifo_wr       <= fifo_wr;
		ld_rx_position    <= comma_stx;
		ld_start_position <= comma_error;
		if( comma_toggle = '1' ) then
			buf2_data <= buf_data(7 downto 0) & buf_data(15 downto 8);
		end if;
		if( comma_stx = '1' ) then
			rx_position <= buf_data(7 downto 0);
		end if;
		if( comma_error = '1' ) then
			start_position <= buf_data(7 downto 0);
		end if;

    if RESET_IN = '1' then
      crc_active   <= '0';
    elsif( comma_crc = '1') then
      crc_active   <= '1';
    end if;
	end if;
end process THE_SYNC_PROC;

-- Comma recognition part I: K part of comma
c_idle_x      <= '1' when ( (buf_rx_k = '1') and (buf_rx_data = x"bc") ) else '0';
c_reset_x     <= '1' when ( (buf_rx_k = '1') and (buf_rx_data = x"fe") ) else '0';
c_error_x     <= '1' when ( (buf_rx_k = '1') and (buf_rx_data = x"f7") ) else '0';
c_stx_x       <= '1' when ( (buf_rx_k = '1') and (buf_rx_data = x"fb") ) else '0';
c_crc_x       <= '1' when ( (buf_rx_k = '1') and (buf_rx_data = x"fd") ) else '0';

c_invalid_k_x <= '1' when buf_rx_k = '1' and
                     (c_idle_x = '0' and c_reset_x = '0' and c_error_x = '0' and c_stx_x = '0' and c_crc_x = '0') else '0';

-- Comma recognition part II: data part of comma
-- IDLE is allowed any time
comma_idle_x  <= '1' when ( (c_idle = '1')  and (buf_rx_k = '0') and ((buf_rx_data = x"50") or (buf_rx_data = x"c5")) )
										 else '0';

-- StartOfTransmission is only accepted in LOCKED state
comma_stx_x   <= '1' when ( (c_stx = '1')   and (buf_rx_k = '0') and (comma_locked_x = '1') ) else '0';

-- ErrorDetected is only accepted in LOCKED state
comma_error_x <= '1' when ( (c_error = '1') and (buf_rx_k = '0') and (comma_locked_x = '1') ) else '0';

-- CRC found is only accepted in LOCKED state
comma_crc_x   <= '1' when ( (c_crc = '1')   and (buf_rx_k = '0') and (comma_locked_x = '1') ) else '0';


-- reset toggle bit in case of mismatch during locking phase
rst_toggle <= '1' when ( ((comma_idle = '1') and (comma_toggle = '0') and (comma_locked_x = '0')) or
												 ((comma_idle = '0') and (comma_toggle = '1') and (comma_locked_x = '0')) or
												 (RX_ALLOW_IN = '0') )
									else '0';

-- count correctly received IDLE commas
ce_toggle  <= '1' when ( (comma_idle = '1') and (comma_toggle = '1') and (comma_locked_x = '0') ) else '0';

-- gk 06.10.10
CRC_COMMA_POSITION_PROC : process( CLK_IN )
begin
	if rising_edge(CLK_IN) then
		if (RESET_IN = '1') or (crc_active = '0') or (c_crc_x = '1') or fifo_inhibit = '1' then
			crc_comma_position <= (others => '0');
		elsif (data_valid_x = '1') then
			crc_comma_position <= crc_comma_position + to_unsigned(1, 1);
		end if;
	end if;
end process CRC_COMMA_POSITION_PROC;

-- gk 06.10.10
crc_comma_pos_wrong <= '1' after 1 ns when (crc_comma_position = to_unsigned(9, 4)) and ((c_crc_x = '0') or (buf_rx_cv = '1'))  else '0';

-- reference toggle bit for 16bit reconstruction
THE_COMMA_TOGGLE_PROC: process( CLK_IN )
begin
	if( rising_edge(CLK_IN) ) then
		if( (RESET_IN = '1') or (rst_toggle = '1') ) then
			comma_toggle <= '0';
		else
			comma_toggle <= not comma_toggle;
		end if;
	end if;
end process THE_COMMA_TOGGLE_PROC;

-- Lock counter: we require 16x correct IDLE commas to arrive in line.
-- After that we are locked till next reset starts the alignment again.
THE_LOCK_CTR_PROC: process( CLK_IN )
begin
	if( rising_edge(CLK_IN) ) then
		if( (RESET_IN = '1') or (rst_toggle = '1') ) then
			comma_ctr <= (others => '0');
		elsif( ce_toggle = '1' ) then
			comma_ctr <= comma_ctr + 1;
		end if;
	end if;
end process THE_LOCK_CTR_PROC;

comma_locked_x <= '1' when (comma_ctr = x"f") else '0';

----------------------------------------------------------------------
-- check for correct data / comma values
----------------------------------------------------------------------

comma_valid_x <= comma_locked and (comma_idle or comma_error or comma_stx or comma_crc)
                  and not buf_cv(1) and not buf_cv(0) ; --and not buf_disperr(0) and not buf_disperr(1);

data_valid_x  <= comma_locked and not buf_k(1) and not buf_k(0)
                  and not buf_cv(1) and not buf_cv(0) ; --and not buf_disperr(0) and not buf_disperr(1);

fifo_wr_x <= comma_toggle and data_valid_x and not fifo_inhibit;

THE_FIFO_INHIBIT_PROC: process( CLK_IN )
begin
  if( rising_edge(CLK_IN) ) then
		if   ( (RESET_IN = '1') or (comma_stx = '1') or (ENABLE_CORRECTION_IN = '0') )then  -- gk 05.10.10
			fifo_inhibit <= '0';
		elsif( (comma_locked = '1') and (comma_toggle = '1') and (comma_valid_x = '0') and (data_valid_x = '0') and c_reset_x = '0' )
          or ((crc_match = '0' or buf_rx_cv = '1') and comma_crc_x = '1' and crc_active = '1')
--           or c_invalid_k_x = '1'
          or (comma_locked = '1' and comma_toggle = '0' and buf_rx_k = '1')
          or START_GONE_WRONG_IN = '1'
          or RX_RESET_IN = '1'
          or crc_comma_pos_wrong = '1' then -- gk 06.10.10
		  fifo_inhibit <= '1';
		end if;
	end if;
end process THE_FIFO_INHIBIT_PROC;

-- gk 05.10.10
START_TOC_PROC : process(CLK_IN)
begin
	if rising_edge(CLK_IN) then
		if (RESET_IN = '1') or (fifo_inhibit = '0') or (start_toc_c = '1') then
			start_toc <= (others => '0');
		elsif (fifo_inhibit = '1') and (comma_stx = '0') then
			start_toc <= start_toc + to_unsigned(1,1);
  	end if;
	end if;
end process START_TOC_PROC;

-- gk 05.10.10
start_toc_c <= '1' when (start_toc >= to_unsigned(200,8)) else '0';

-- gk 05.10.10
START_TOC_OUT_PROC : process(CLK_IN)
begin
	if rising_edge(CLK_IN) then
		START_TIMEOUT_OUT <= start_toc_c;
	end if;
end process START_TOC_OUT_PROC;



----------------------------------------------------------------------
-- CRC
----------------------------------------------------------------------
THE_CRC : trb_net_CRC8
  port map(
    CLK       => CLK_IN,
    RESET     => crc_reset,
    CLK_EN    => crc_enable,
    DATA_IN   => buf_rx_data,
    CRC_OUT   => open,
    CRC_match => crc_match
    );

  crc_reset  <= RESET_IN or (fifo_inhibit and not comma_stx) or (not crc_active and not comma_crc);
  crc_enable <= ((not buf_rx_k and not (comma_idle_x or comma_error_x or comma_stx_x or comma_crc_x))  or comma_crc_x) and not buf_rx_cv;

----------------------------------------------------------------------
-- Statistics counters
----------------------------------------------------------------------
crc_wrong_pulse <= (not crc_match) and comma_crc_x and crc_active;
cv_pulse        <= buf_rx_cv and comma_locked;
invalid_k_pulse <= c_invalid_k_x and comma_locked;

THE_CRC_MISM_PULSE_SYNC: pulse_sync
port map(
  CLK_A_IN        => CLK_IN,
  RESET_A_IN      => RESET_IN,
  PULSE_A_IN      => crc_wrong_pulse,
  CLK_B_IN        => SYSCLK_IN,
  RESET_B_IN      => RESET_IN,
  PULSE_B_OUT     => inc_counter_crc_mismatch
);
THE_CRC_POS_PULSE_SYNC: pulse_sync
port map(
  CLK_A_IN        => CLK_IN,
  RESET_A_IN      => RESET_IN,
  PULSE_A_IN      => crc_comma_pos_wrong,
  CLK_B_IN        => SYSCLK_IN,
  RESET_B_IN      => RESET_IN,
  PULSE_B_OUT     => inc_counter_crc_wrong_pos
);
THE_CV_PULSE_SYNC: pulse_sync
port map(
  CLK_A_IN        => CLK_IN,
  RESET_A_IN      => RESET_IN,
  PULSE_A_IN      => cv_pulse,
  CLK_B_IN        => SYSCLK_IN,
  RESET_B_IN      => RESET_IN,
  PULSE_B_OUT     => inc_counter_cv
);
THE_INV_K_PULSE_SYNC: pulse_sync
port map(
  CLK_A_IN        => CLK_IN,
  RESET_A_IN      => RESET_IN,
  PULSE_A_IN      => invalid_k_pulse,
  CLK_B_IN        => SYSCLK_IN,
  RESET_B_IN      => RESET_IN,
  PULSE_B_OUT     => inc_counter_invalid_k
);

PROC_STAT: process(SYSCLK_IN)
  begin
    if rising_edge(SYSCLK_IN) then
      if RESET_IN = '1' then
        counter_crc_mismatch  <= (others => '0');
        counter_crc_wrong_pos <= (others => '0');
        counter_cv            <= (others => '0');
        counter_invalid_k     <= (others => '0');
      else
        if inc_counter_crc_mismatch = '1' then
          counter_crc_mismatch  <= counter_crc_mismatch + to_unsigned(1,1);
        end if;
        if inc_counter_crc_wrong_pos = '1' then
          counter_crc_wrong_pos <= counter_crc_wrong_pos + to_unsigned(1,1);
        end if;
        if inc_counter_cv = '1' then
          counter_cv            <= counter_cv + to_unsigned(1,1);
        end if;
        if inc_counter_invalid_k = '1' then
          counter_invalid_k     <= counter_invalid_k + to_unsigned(1,1);
        end if;
      end if;
    end if;
  end process;


----------------------------------------------------------------------
-- Debug signals
----------------------------------------------------------------------
debug(15)            <= comma_valid_x;
debug(14)            <= data_valid_x;
debug(13)            <= fifo_inhibit;
debug(12)            <= c_reset;
debug(11)            <= reset_word_cnt(4);
debug(10 downto 0)   <= (others => '0');

STAT_REG_OUT(4 downto 0) <= std_logic_vector(reset_word_cnt);
STAT_REG_OUT(5)          <= fifo_inhibit;
STAT_REG_OUT(6)          <= comma_locked;
STAT_REG_OUT(7)          <= comma_crc;
STAT_REG_OUT(15 downto 8) <= std_logic_vector(counter_crc_mismatch);
STAT_REG_OUT(23 downto 16)<= std_logic_vector(counter_crc_wrong_pos);
STAT_REG_OUT(31 downto 24)<= std_logic_vector(counter_cv);
STAT_REG_OUT(39 downto 32)<= std_logic_vector(counter_invalid_k);

----------------------------------------------------------------------
-- Output signals
----------------------------------------------------------------------
FIFO_DATA_OUT         <= buf2_data;
FIFO_WR_OUT           <= buf_fifo_wr;
FIFO_INHIBIT_OUT      <= fifo_inhibit;

LD_START_POSITION_OUT <= ld_start_position;
START_POSITION_OUT    <= start_position;
LD_RX_POSITION_OUT    <= ld_rx_position;
RX_POSITION_OUT       <= rx_position;

COMMA_LOCKED_OUT      <= comma_locked;

SEND_RESET_WORDS_OUT  <= send_reset_words;
MAKE_TRBNET_RESET_OUT <= make_trbnet_reset;

DEBUG_OUT             <= debug;

end architecture;