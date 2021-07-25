library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
--use work.trb_net_components.all;

entity trb_net16_rx_checker is
port(
  -- Resets & clocks
  SYSCLK_IN             : in  std_logic;
  RESET_IN              : in  std_logic;
	-- error detection and status signals
	PKT_TOC_IN            : in  std_logic; -- full packet RX timeout
	RX_IC_IN              : in  std_logic; -- illegal comma or CodeViolation on RX
	STX_FND_IN            : in  std_logic; -- StartOfTransmission found on RX
  STX_TOC_IN            : in  std_logic; -- timeout waiting for StartOfTransmission
	PKT_IN_TRANS_IN       : in  std_logic; -- paket in transmission to media interface
	-- control signals
	FIFO_RST_OUT          : out std_logic; -- clear RX FIFO
	RESUME_OUT            : out std_logic; -- full packet RX resume signal
	REQ_RETRANS_OUT       : out std_logic; -- request retransmission
  -- Debug signals
  STAT_REG_OUT          : out std_logic_vector(15 downto 0);
  DBG_OUT               : out std_logic_vector(15 downto 0)
);
end entity trb_net16_rx_checker;


architecture behavioral of trb_net16_rx_checker is

-- state declarations
type STATES is (IDLE, CHK_PKT, RX_FAIL, WAIT_STX, DONE);
signal current_state, next_state: STATES;

signal bsm_x                : std_logic_vector(3 downto 0);
signal bsm                  : std_logic_vector(3 downto 0);

signal fifo_rst_x           : std_logic;
signal fifo_rst             : std_logic;
signal resume_x             : std_logic;
signal resume               : std_logic;
signal request_x            : std_logic;
signal request              : std_logic;

signal debug                : std_logic_vector(15 downto 0);

begin

----------------------------------------------------------------------
--
----------------------------------------------------------------------

----------------------------------------------------------------------
-- error checker state machine
----------------------------------------------------------------------
-- state registers
STATE_MEM: process( SYSCLK_IN )
begin
  if( rising_edge(SYSCLK_IN) ) then
    if( RESET_IN = '1' ) then
      current_state <= IDLE;
			fifo_rst      <= '0';
			resume        <= '0';
			request       <= '0';
      bsm           <= (others => '0');
    else
      current_state <= next_state;
			fifo_rst      <= fifo_rst_x;
			resume        <= resume_x;
			request       <= request_x;
      bsm           <= bsm_x;
    end if;
  end if;
end process STATE_MEM;

-- state transitions
STATE_TRANSFORM: process( current_state, PKT_TOC_IN, RX_IC_IN, STX_FND_IN, PKT_IN_TRANS_IN, STX_TOC_IN )
begin
  next_state      <= IDLE; -- avoid latches
	fifo_rst_x      <= '0';
	resume_x        <= '0';
	request_x       <= '0';
  case current_state is
    when IDLE     =>
            if   ( PKT_TOC_IN = '1' ) then
							next_state <= RX_FAIL;
							fifo_rst_x <= '1';
            elsif( RX_IC_IN = '1' ) then
							next_state <= CHK_PKT;
						else
							next_state <= IDLE;
            end if;
		when CHK_PKT  =>
						if( PKT_IN_TRANS_IN = '1' ) then
							next_state <= CHK_PKT;
						else
							next_state <= RX_FAIL;
							fifo_rst_x <= '1';
						end if;
		when RX_FAIL  =>
						next_state <= WAIT_STX;
						fifo_rst_x <= '1';
						request_x  <= '1';
		when WAIT_STX =>
						if( STX_FND_IN = '1' ) then
							next_state <= DONE;
							resume_x   <= '1';
            elsif STX_TOC_IN = '1' then
              next_state <= RX_FAIL;
						else
							next_state <= WAIT_STX;
							fifo_rst_x <= '1';
						end if;
		when DONE   =>
						if( PKT_TOC_IN = '0' ) then
							next_state <= IDLE;
						else
							next_state <= DONE;
						end if;
    when others =>
            next_state <= IDLE;
  end case;
end process STATE_TRANSFORM;

-- just for debugging
THE_DECODE_PROC: process( next_state )
begin
  case next_state is
    when IDLE     => bsm_x <= x"0";
    when CHK_PKT  => bsm_x <= x"1";
    when RX_FAIL  => bsm_x <= x"2";
    when WAIT_STX => bsm_x <= x"3";
		when DONE     => bsm_x <= x"4";
    when others   => bsm_x <= x"f";
  end case;
end process THE_DECODE_PROC;

----------------------------------------------------------------------
-- Debug signals
----------------------------------------------------------------------
debug(15 downto 12)  <= bsm;
debug(11 downto 0)   <= (others => '0');

----------------------------------------------------------------------
-- Output signals
----------------------------------------------------------------------
FIFO_RST_OUT          <= fifo_rst;
RESUME_OUT            <= resume;
REQ_RETRANS_OUT       <= request;

STAT_REG_OUT(3 downto 0)  <= bsm;
STAT_REG_OUT(4)           <= fifo_rst;
STAT_REG_OUT(5)           <= request;
STAT_REG_OUT(6)           <= resume;
STAT_REG_OUT(15 downto 7) <= (others => '0');

DBG_OUT               <= debug;

end behavioral;