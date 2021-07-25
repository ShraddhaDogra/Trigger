-- ***********************************************************************************
-- ***********************************************************************************
--
--   FIFO storage cell
--   -----------------
--
--   Architecture independent
--        In order to assure architecture independence, set the ARCH constant
--        in devmon_config.vhd
--        The ARCH will be prepended to all FIFOs
--
-- -----------------------------------------------------------------------------------
--
--  TODO:
--  -----
--        Do fifo_reset only during 1 cycle and reset the cfg(0) to '0' after write
--        Clean the unused signals
--
-- ***********************************************************************************
-- ***********************************************************************************


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

library work;
use work.monitor_config.all;
use work.fifo_package.all;


entity FIFO_cell is
	generic(
    fifo_type : String;                   -- The FIFO cell identifier, e.g. "32x512" or "8x16"
    f_low     : integer range 0 to 255;   -- from 10 ns to 2560 ns, the automatic strobe signal
    f_high    : integer range 0 to 30;    -- 10*2**2**f_high ns if this is set, f_low is ignored
    t_res     : integer range 0 to 31;    -- from which bit on the timer will be taken
    t_size    : integer range 0 to 32;    -- size of the timestamp in the package
    d_size    : integer range 0 to 32;    -- size of data in the package
    i_size    : integer range 0 to 32    -- size of additional information from the external port in the package
	);
	port(
		CLK         : in std_logic;
		RESET       : in std_logic;
		CLK_EN      : in std_logic;

		DATA_IN     : in std_logic_vector(FIFO_BUS-1 downto 0);
		WRITE_IN    : in std_logic;
		READ_IN     : in std_logic;
    DATA_OUT    : out std_logic_vector(FIFO_BUS-1 downto 0) := (others => '0');
		VALID_OUT   : out std_logic := '0';
    STATUS_OUT  : out std_logic_vector(7 downto 0) := (others => '0');

		CFG_IN      : in std_logic_vector(7 downto 0);
		TIME_IN     : in std_logic_vector(31 downto 0);
		EXTERNAL_IN : in std_logic_vector(7 downto 0)
	);
end entity;

architecture basic of FIFO_cell is

signal fifo_data_in, next_fifo_data_in, fifo_data_out : std_logic_vector(31 downto 0) := (others => '0');
signal timestamp, next_timestamp : std_logic_vector(31 downto 0) := (others => '0');
signal next_fifo_read, fifo_read, fifo_reset, fifo_write, next_fifo_write, fifo_empty, fifo_full, fifo_valid : std_logic := '0';
signal t1, t2, next_t1, next_t2 : std_logic := '0';
signal next_reset : std_logic := '0';
signal stored : std_logic_vector(15 downto 0) := (others => '0');
signal check : std_logic := '0';

signal timer, next_timer : integer := 0;
signal stored_data, next_stored_data : std_logic_vector(FIFO_BUS-1 downto 0) := (others => '0');
signal buf_data_in, next_buf_data_in : std_logic_vector(FIFO_BUS-1 downto 0) := (others => '0');
signal autowrite, next_autowrite, write, next_write : std_logic := '0';
signal hw_trigger, next_hw_trigger   : std_logic := '0';
signal buf_val_in, next_buf_val_in   : std_logic := '0';
signal buf_info_in, next_buf_info_in : std_logic_vector(7 downto 0) := x"00";

begin

  gen_virtex4: if ARCH="_virtex4" generate
    gen_16x1024: if fifo_type = "fifo_16x1024" generate
      the_16x1024_FIFO : virtex4_fifo_16x1024
      port map(
        clk    => CLK,
        din    => fifo_data_in(15 downto 0),
        rd_en  => fifo_read,
        rst    => fifo_reset,
        wr_en  => fifo_write,
        data_count => stored(9 downto 0),
        dout   => fifo_data_out(15 downto 0),
        empty  => fifo_empty,
        full   => fifo_full,
        valid  => fifo_valid
      );
    end generate;
    gen_32x512: if fifo_type = "fifo_32x512 " generate
      the_32x512_FIFO : virtex4_fifo_32x512
      port map(
        clk    => CLK,
        din    => fifo_data_in(31 downto 0),
        rd_en  => fifo_read,
        rst    => fifo_reset,
        wr_en  => fifo_write,
        data_count => stored(8 downto 0),
        dout   => fifo_data_out(31 downto 0),
        empty  => fifo_empty,
        full   => fifo_full,
        valid  => fifo_valid
      );
    end generate;
  end generate;

  gen_timestamp0: if t_size = 1 generate
    next_timestamp(0) <= TIME_IN(t_res);
  end generate;
  gen_timestamp1: if t_size > 1 generate
    next_timestamp(t_size-1 downto 0) <= TIME_IN(t_res + t_size - 1 downto t_res);
  end generate;
	proc_reg_timestamp: process(CLK)
	begin
  if rising_edge(CLK) then
	  timestamp  <= next_timestamp;
	end if;
	end process;

  gen_fifo_data_no_info: if i_size = 0 generate
    gen_timestamp_0: if t_size = 0 generate
      next_fifo_data_in(d_size-1 downto 0) <= buf_data_in(d_size-1 downto 0);
    end generate;
    gen_timestamp_1: if t_size = 1 generate
      next_fifo_data_in(d_size downto 0) <= timestamp(0) & buf_data_in(d_size-1 downto 0);
    end generate;
    gen_timestamp_others: if t_size > 1 generate
      next_fifo_data_in(d_size+t_size-1 downto 0) <= timestamp(t_size-1 downto 0) & buf_data_in(d_size-1 downto 0);
    end generate;
  end generate;
  gen_fifo_data_1_info: if i_size = 1 generate
    gen_timestamp_0: if t_size = 0 generate
      next_fifo_data_in(d_size downto 0) <= buf_info_in(0) & buf_data_in(d_size-1 downto 0);
    end generate;
    gen_timestamp_1: if t_size = 1 generate
      next_fifo_data_in(d_size+1 downto 0) <= buf_info_in(0) & timestamp(0) & buf_data_in(d_size-1 downto 0);
    end generate;
    gen_timestamp_others: if t_size > 1 generate
      next_fifo_data_in(d_size+t_size downto 0) <= buf_info_in(0) & timestamp(t_size-1 downto 0) & buf_data_in(d_size-1 downto 0);
    end generate;
  end generate;
  gen_fifo_data_info: if i_size > 1 generate
    gen_timestamp_0: if t_size = 0 generate
      next_fifo_data_in(d_size+i_size-1 downto 0) <= buf_info_in(i_size-1 downto 0) & buf_data_in(d_size-1 downto 0);
    end generate;
    gen_timestamp_1: if t_size = 1 generate
      next_fifo_data_in(d_size+i_size downto 0)   <= buf_info_in(i_size-1 downto 0) & timestamp(0) & buf_data_in(d_size-1 downto 0);
    end generate;
    gen_timestamp_others: if t_size > 1 generate
      next_fifo_data_in(d_size+t_size+i_size-1 downto 0) <= buf_info_in(i_size-1 downto 0) & timestamp(t_size-1 downto 0) & buf_data_in(d_size-1 downto 0);
    end generate;
  end generate;

  p_autowrite: process(timer, RESET)
  begin
  if f_high = 0 then
    if timer = f_low then
      next_timer     <= 0;
      next_autowrite <= '1';
    else
      next_timer <= timer + 1;
      next_autowrite <= '0';
    end if;
  else
    if timer = (2**f_high)-1 then
      next_timer     <= 0;
      next_autowrite <= '1';
    else
      next_timer     <= timer + 1;
      next_autowrite <= '0';
    end if;
  end if;

  if RESET = '1' then
    next_timer     <= 0;
    next_autowrite <= '0';
  end if;
  end process;

  next_buf_data_in <= DATA_IN;
  next_stored_data <= buf_data_in;
  next_hw_trigger  <= WRITE_IN;
  next_buf_info_in <= EXTERNAL_IN;
  proc_register_signals : process(CLK)
  begin
  if rising_edge(CLK) then
    write          <= next_write;
    autowrite      <= next_autowrite;
    fifo_write     <= next_fifo_write;
    timer          <= next_timer;
    stored_data    <= next_stored_data;
    hw_trigger     <= next_hw_trigger;
    buf_data_in    <= next_buf_data_in;
    buf_info_in    <= next_buf_info_in;
    fifo_data_in   <= next_fifo_data_in;
  end if;
  end process;

  next_fifo_write <= (autowrite  and CFG_IN(4) and CFG_IN(2) and (fifo_empty) and (not CFG_IN(3)) and (not RESET)) 
                  or (autowrite  and CFG_IN(4) and CFG_IN(2) and (not fifo_empty) and check and (not CFG_IN(3)) and (not RESET)) 
                  or (hw_trigger and (not CFG_IN(3)) and (not CFG_IN(2)) and (not RESET))
                  or (hw_trigger and (not CFG_IN(3)) and CFG_IN(2) and (not fifo_empty) and check and (not RESET))
                  or (hw_trigger and (not CFG_IN(3)) and CFG_IN(2) and fifo_empty and (not RESET))
                  or (autowrite  and CFG_IN(4) and (not CFG_IN(2)) and (not CFG_IN(3)) and (not RESET));


  check <= '0' when stored_data = buf_data_in else '1';
--   p_compare:process(stored_data, buf_data_in)
--   begin
--   if stored_data = buf_data_in then
--     check <= '0';
--   else
--     check <= '1';
--   end if;
--   end process;

  proc_register_f : process(CLK)
  begin
  if rising_edge(CLK) then
    fifo_read  <= next_fifo_read;
    fifo_reset <= next_reset;
    t1 <= next_t1;
    t2 <= next_t2;
  end if;
  end process;

  proc_cell_logic : process(stored, t1, t2, READ_IN, fifo_read, CFG_IN, RESET)
  variable ALFULL : integer range 1 to 1024;
  begin
  if fifo_type = "fifo_32x512 " then
    ALFULL := 508;
  elsif fifo_type = "fifo_16x1024" then
    ALFULL := 1020;
  end if;

  next_reset <= CFG_IN(0) or RESET;

  -- RING BUFFER MODE
  if CFG_IN(1) = '1' then
    next_fifo_read <= '0';
    next_t1 <= t1;
    next_t2 <= t2;

    if READ_IN = '1' then
      next_fifo_read <= '1';  -- the real read
      next_t1 <= '0';         -- mark as real
    else
      if std_logic_vector(to_unsigned(ALFULL,16)) < stored  then  -- the fifo is 'almost' full
        next_fifo_read <= '1';  -- the fake read
        next_t1 <= '1';         -- mark as fake
      else
        next_t1 <= '0';   -- no real or fake read, so reset the marker
      end if;
    end if;

    if fifo_read = '1' then
      if t1 = '1' then
        next_t2 <= '1';    -- propagate the marker
      else
        next_t2 <= '0';    -- no fake read, so reset the second marker
      end if;
    end if;

  -- NORMAL MODE
  else
    next_t1 <= '0';
    next_t2 <= '0';

    next_fifo_read <= READ_IN;

  end if;

  if RESET = '1' then
    next_t1 <= '0';
    next_t2 <= '0';
    next_fifo_read <= '0';
  end if;
  end process;

  p_valid:process(fifo_valid, t2)
  begin
  if fifo_valid = '1' then
    VALID_OUT <= not t2;
  else
    VALID_OUT <= '0';
  end if;
  end process;

  DATA_OUT   <= fifo_data_out(FIFO_BUS-1 downto 0);

  STATUS_OUT(0) <= fifo_full;
  STATUS_OUT(1) <= fifo_empty;

  -- DEBUG
  STATUS_OUT(2) <= autowrite;
  STATUS_OUT(3) <= fifo_write;
  STATUS_OUT(4) <= fifo_read;
  STATUS_OUT(5) <= fifo_data_in(0);
  STATUS_OUT(6) <= fifo_data_in(1);
  STATUS_OUT(7) <= fifo_data_in(2);

end architecture;