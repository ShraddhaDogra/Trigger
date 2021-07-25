library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bus_handler_oepb is
  generic(
    AMOUNT_OF_SLAVES : integer := 17
    );
  port(
    CLK_IN               : in  std_logic;
    CLEAR_IN             : in  std_logic;
    RESET_IN             : in  std_logic;
    DAT_ADDR_IN          : in  std_logic_vector(15 downto 0); -- address bus
    DAT_DATA_IN          : in  std_logic_vector(31 downto 0); -- data from TRB endpoint
    DAT_DATA_OUT         : out  std_logic_vector(31 downto 0); -- data to TRB endpoint
    DAT_READ_ENABLE_IN   : in  std_logic; -- read pulse
    DAT_WRITE_ENABLE_IN  : in  std_logic; -- write pulse
    DAT_TIMEOUT_IN       : in  std_logic; -- access timed out
    DAT_DATAREADY_OUT    : out  std_logic; -- your data, master, as requested
    DAT_WRITE_ACK_OUT    : out  std_logic; -- data accepted
    DAT_NO_MORE_DATA_OUT : out  std_logic; -- don't disturb me now
    DAT_UNKNOWN_ADDR_OUT : out  std_logic; -- noone here to answer your request
    SLV_SELECT_OUT       : out  std_logic_vector(AMOUNT_OF_SLAVES-1 downto 0); -- select signal for slave entities
    SLV_READ_OUT         : out  std_logic; -- read signal for slave entities
    SLV_WRITE_OUT        : out  std_logic; -- write signal for slave entities
    SLV_BUSY_IN          : in  std_logic; -- wired OR busy from slave entities
    SLV_ACK_IN           : in  std_logic; -- slave has accepted access
    SLV_DATA_IN          : in  std_logic_vector(31 downto 0); -- read data from slaves
    SLV_DATA_OUT         : out  std_logic_vector(31 downto 0); -- write data to slaves
    STAT                 : out  std_logic_vector(31 downto 0)
    );
end entity;

architecture Behavioral of bus_handler_oepb is

-- Signals
  type STATES is (SLEEP,RACC,WACC,RFAIL,WFAIL,ROK,WOK,STATW,STATS,STATD,NOONE,DONE);
  signal CURRENT_STATE, NEXT_STATE: STATES;

  signal bsm            : std_logic_vector(3 downto 0);

  signal rst_strb_x        : std_logic;
  signal rst_strb          : std_logic;
  signal buf_dat_write_ack_x    : std_logic;
  signal buf_dat_write_ack    : std_logic;
  signal buf_dat_dataready_x    : std_logic;
  signal buf_dat_dataready    : std_logic;
  signal buf_dat_no_more_data_x  : std_logic;
  signal buf_dat_no_more_data    : std_logic;
  signal buf_dat_unknown_addr_x  : std_logic;
  signal buf_dat_unknown_addr    : std_logic;

  signal buf_slv_select_x      : std_logic_vector(AMOUNT_OF_SLAVES-1 downto 0);
  signal buf_slv_select      : std_logic_vector(AMOUNT_OF_SLAVES-1 downto 0);
  signal buf_slv_read        : std_logic;
  signal buf_slv_write      : std_logic;
  signal no_slave_reg_x      : std_logic;
  signal no_slave_mem_x      : std_logic;
  signal no_slave          : std_logic;
  signal slave_busy        : std_logic;
  signal slave_ack        : std_logic;

begin

-- Memory map:
-- full range: 8000 - FFFF
-- 8000 - 80FF  ADC                     (17)
-- 9000 - 9FFF  SPI
-- A000 - A7FF  Threshold Bytes         (16)
-- F000 - F00F  Test readout addresses  (15-0)


-- 80xx => single registers
-- axxx => pedestal memory APV[15:0]
-- bxxx => threshold memory APV[15:0]

------------------------------------------------------------------------------
-- This part is crucial, as ACK and BSY are tristate signals!
------------------------------------------------------------------------------

THE_ADDRESS_DEC_REG_PROC: process( dat_addr_in )
  begin
    buf_slv_select_x <= (others => '0');
    no_slave_reg_x   <= '0';
    if dat_addr_in(15 downto 4) = x"F00" then
      buf_slv_select_x(to_integer(unsigned(dat_addr_in(3 downto 0)))) <= '1';
    elsif dat_addr_in(15 downto 11) = x"A" & '0' then
      buf_slv_select_x(16) <= '1';
    elsif dat_addr_in(15 downto 8) = x"80" then
      buf_slv_select_x(17) <= '1';
    else
      no_slave_reg_x <= '1';
    end if;
  end process;




-- synchronize signals
THE_SYNC_PROC: process( clk_in )
begin
  if( rising_edge(clk_in) ) then
    buf_slv_select   <= buf_slv_select_x;
    no_slave         <= no_slave_reg_x and no_slave_mem_x;
  end if;
end process THE_SYNC_PROC;


-- Slave response lines
slave_ack    <= slv_ack_in  when ( no_slave = '0' ) else '0';
slave_busy   <= slv_busy_in when ( no_slave = '0' ) else '0';
dat_data_out <= slv_data_in when ( no_slave = '0' ) else (others => '0');

-- Data tunneling to slave entities
slv_data_out <= dat_data_in;

-- Read / write strobe
THE_READ_WRITE_STROBE_PROC: process( clk_in, clear_in )
begin
  if( clear_in = '1' ) then
    buf_slv_read  <= '0';
    buf_slv_write <= '0';
  elsif( rising_edge(clk_in) ) then
    if( reset_in = '1' ) then
      buf_slv_read  <= '0';
      buf_slv_write <= '0';
    elsif( (dat_read_enable_in = '1') and (dat_write_enable_in = '0') ) then
      buf_slv_read  <= '1';
      buf_slv_write <= '0';
    elsif( (dat_read_enable_in = '0') and (dat_write_enable_in = '1') ) then
      buf_slv_read  <= '0';
      buf_slv_write <= '1';
    elsif( rst_strb = '1' ) then
      buf_slv_read  <= '0';
      buf_slv_write <= '0';
    end if;
  end if;
end process THE_READ_WRITE_STROBE_PROC;



-- The main state machine
-- State memory process
STATE_MEM: process( clk_in, clear_in )
begin
  if( clear_in = '1' ) then
    CURRENT_STATE <= SLEEP;
    rst_strb              <= '0';
    buf_dat_dataready     <= '0';
    buf_dat_no_more_data  <= '0';
    buf_dat_write_ack     <= '0';
    buf_dat_unknown_addr  <= '0';
  elsif( rising_edge(clk_in) ) then
    if( reset_in = '1' ) then
      CURRENT_STATE <= SLEEP;
      rst_strb              <= '0';
      buf_dat_dataready     <= '0';
      buf_dat_no_more_data  <= '0';
      buf_dat_write_ack     <= '0';
      buf_dat_unknown_addr  <= '0';
    else
      CURRENT_STATE <= NEXT_STATE;
      rst_strb              <= rst_strb_x;
      buf_dat_dataready     <= buf_dat_dataready_x;
      buf_dat_no_more_data  <= buf_dat_no_more_data_x;
      buf_dat_write_ack     <= buf_dat_write_ack_x;
      buf_dat_unknown_addr  <= buf_dat_unknown_addr_x;
    end if;
  end if;
end process STATE_MEM;

-- Transition matrix
TRANSFORM: process(CURRENT_STATE, no_slave, buf_slv_read, buf_slv_write, slave_ack, slave_busy, dat_timeout_in )
begin
  NEXT_STATE <= SLEEP;
  rst_strb_x <= '0';
  buf_dat_dataready_x    <= '0';
  buf_dat_no_more_data_x <= '0';
  buf_dat_write_ack_x    <= '0';
  buf_dat_unknown_addr_x <= '0';
  case CURRENT_STATE is
    when SLEEP    =>  if   ( (no_slave = '1') and ((buf_slv_read = '1') or (buf_slv_write = '1')) ) then
                NEXT_STATE <= NOONE;
                buf_dat_unknown_addr_x <= '1';
              elsif( (buf_slv_read = '1') and (buf_slv_write = '0') ) then
                NEXT_STATE <= RACC;
              elsif( (buf_slv_read = '0') and (buf_slv_write = '1') ) then
                NEXT_STATE <= WACC;
              else
                NEXT_STATE <= SLEEP;
              end if;
    when RACC    =>  if   ( dat_timeout_in = '1' ) then
                NEXT_STATE <= DONE;
                rst_strb_x <= '1';
              elsif( slave_busy = '1' ) then
                NEXT_STATE <= RFAIL;
                buf_dat_no_more_data_x <= '1';
              elsif( slave_ack = '1' ) then
                NEXT_STATE <= ROK;
                buf_dat_dataready_x <= '1';
              else
                NEXT_STATE <= RACC;
              end if;
    when RFAIL    =>  NEXT_STATE <= DONE;
              rst_strb_x <= '1';
    when ROK    =>  NEXT_STATE <= DONE;
              rst_strb_x <= '1';
    when WACC    =>  if   ( dat_timeout_in = '1' ) then
                NEXT_STATE <= DONE;
                rst_strb_x <= '1';
              elsif( slave_busy = '1' ) then
                NEXT_STATE <= WFAIL;
                buf_dat_no_more_data_x <= '1';
              elsif( slave_ack = '1' ) then
                NEXT_STATE <= WOK;
                buf_dat_write_ack_x <= '1';
              else
                NEXT_STATE <= WACC;
              end if;
    when WFAIL    =>  NEXT_STATE <= DONE;
              rst_strb_x <= '1';
    when WOK    =>  NEXT_STATE <= DONE;
              rst_strb_x <= '1';
    when NOONE    =>  NEXT_STATE <= DONE;
              rst_strb_x <= '1';
    when DONE    =>  NEXT_STATE <= SLEEP; -- ?????
        -- Just in case...
    when others   =>  NEXT_STATE <= SLEEP;
  end case;
end process TRANSFORM;

-- Output decoding
DECODE: process(CURRENT_STATE)
begin
  case CURRENT_STATE is
    when SLEEP    =>  bsm <= x"0";
    when RACC    =>  bsm <= x"1";
    when ROK    =>  bsm <= x"2";
    when RFAIL    =>  bsm <= x"3";
    when WACC    =>  bsm <= x"4";
    when WOK    =>  bsm <= x"5";
    when NOONE    =>  bsm <= x"6";
    when DONE    =>  bsm <= x"7";
    when others    =>  bsm <= x"f";
  end case;
end process DECODE;

-- Outputs
dat_dataready_out    <= buf_dat_dataready;
dat_no_more_data_out <= buf_dat_no_more_data;
dat_unknown_addr_out <= buf_dat_unknown_addr;
dat_write_ack_out    <= buf_dat_write_ack;

slv_select_out  <= buf_slv_select;
slv_read_out    <= buf_slv_read;
slv_write_out   <= buf_slv_write;

stat(31 downto 9)  <= (others => '0');
stat(8)            <= rst_strb;
stat(7 downto 4)   <= (others => '0');
stat(3 downto 0)   <= bsm;

end Behavioral;
