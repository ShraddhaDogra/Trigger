-- ***********************************************************************************
-- ***********************************************************************************
--
--   Borislav Milanovic
--
--   Version: 4.0
--   -------------
--
-- ***********************************************************************************
-- ***********************************************************************************


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

library work;
use work.monitor_config.all;



entity monitor is
  port(
    CLK       : in std_logic;
    RESET     : in std_logic;
    CLK_EN    : in std_logic;

    ADDR_IN   : in std_logic_vector(9 downto 0); -- ADDR> bit 9,8 for selection, bits 7 - 0 for the cell address
    READ_IN   : in std_logic;                    -- READ a cell
    WRITE_IN  : in std_logic;                    -- WRITE CFG (FIFO control register)
    DATA_IN   : in std_logic_vector(7 downto 0); -- CFG data

    DATA_OUT  : out std_logic_vector(EXT_BUS-1 downto 0) := (others => '0'); -- Monitoring cell contents
    VALID_OUT : out std_logic := '0';                                        -- Valid signal

    STATUS_OUT : out std_logic_vector(7 downto 0) := "00000000";              -- Bits: 0-Unknown_Address, 1-EMPTY, 2-ACK,   5-Wrong_Address_Scope

    -- DATA Connections
    FIFO_DATA_IN    : in std_logic_vector( (FIFO_BUS*FIFO_NUM)-1 downto 0 );  -- combined FIFO data
    FIFO_WRITE_IN   : in std_logic_vector( FIFO_NUM-1 downto 0 );             -- combined FIFO valid
    REG_DATA_IN     : in std_logic_vector( (REG_BUS*REG_NUM)-1 downto 0 );    -- combined RED data

    -- TIMERS
    TIMER0_IN       : in std_logic_vector(31 downto 0);
    TIMER1_IN       : in std_logic_vector( 7 downto 0);
    TIMER2_IN       : in std_logic_vector(31 downto 0);

    EXTERNAL_STAMP_IN : in std_logic_vector(7 downto 0);  -- additional data marker (in addition to timestamp)

    DEBUG_OUT : out std_logic_vector(31 downto 0)  -- Status, tests, etc
  );
end entity;



architecture basic of monitor is

	component REG_cell is
	generic(
		width : integer range 1 to 32 := 32
	);
	port(
	  CLK       : in  std_logic;
	  RESET     : in  std_logic;
	  CLK_EN    : in  std_logic;

		DATA_IN   : in  std_logic_vector(REG_BUS-1 downto 0);
		DATA_OUT  : out std_logic_vector(REG_BUS-1 downto 0)
	);
	end component;

	component FIFO_cell is
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
  end component;

	component CFG_cell is
	generic(
		init  : std_logic_vector(7 downto 0)
	);
	port(
	  CLK       : in std_logic;
	  RESET     : in std_logic;
	  CLK_EN    : in std_logic;

		DATA_IN   : in std_logic_vector(7 downto 0);
		WRITE_IN  : in std_logic;
		DATA_OUT  : out std_logic_vector(7 downto 0)
	);
	end component;

  component rom_32x113 is
	port(
    CLK: IN std_logic;
    ADDR_IN: IN std_logic_VECTOR(8 downto 0);
    DATA_OUT: OUT std_logic_VECTOR(31 downto 0)
	);
	end component;

	component reg_mux is
  port(
    CLK       : in std_logic;
    RESET     : in std_logic;
    CLK_EN    : in std_logic;

    READ_IN : in std_logic;
    ADDR_IN : in std_logic_vector(7 downto 0);

    DATA_OUT      : out std_logic_vector(REG_BUS-1 downto 0);
    VALID_OUT     : out std_logic;
    STATUS_OUT    : out std_logic_vector(7 downto 0) := "00000000";

    DATA_IN       : in std_logic_vector( (REG_NUM*REG_BUS)-1 downto 0)
  );
	end component;

	component cfg_mux is
  port(
    CLK        : in std_logic;
    RESET      : in std_logic;
    CLK_EN     : in std_logic;

    WRITE_IN   : in std_logic;
    DATA_IN    : in std_logic_vector(7 downto 0);
    ADDR_IN    : in std_logic_vector(7 downto 0);

    DATA_OUT   : out std_logic_vector(8*FIFO_NUM-1 downto 0);
    WRITE_OUT  : out std_logic_vector(  FIFO_NUM-1 downto 0);

    STATUS_OUT : out std_logic_vector(7 downto 0) := "00000000"
  );
	end component;

	component fifo_mux is
  port(
    CLK        : in std_logic;
    RESET      : in std_logic;
    CLK_EN     : in std_logic;

    READ_IN    : in std_logic;                    -- Slow Control READ
    ADDR_IN    : in std_logic_vector(7 downto 0); -- Slow Control ADDR

    READ_OUT   : out std_logic_vector(FIFO_NUM-1 downto 0);         -- MUX-to-FIFO READ

    DATA_IN    : in std_logic_vector(FIFO_NUM*FIFO_BUS-1 downto 0); -- FIFO data
    VALID_IN   : in std_logic_vector(FIFO_NUM-1 downto 0);          -- FIFO valid
    STATUS_IN  : in std_logic_vector(8*FIFO_NUM-1 downto 0);        -- FIFO stats

    DATA_OUT   : out std_logic_vector(FIFO_BUS-1 downto 0);      -- MUX Data as received from the FIFO
    VALID_OUT  : out std_logic;                                  -- MUX Valid
    STATUS_OUT : out std_logic_vector(7 downto 0) := "00000000" -- MUX status bits
  );
	end component;

  component etrax_controls is
  port(

    CLK     : in std_logic;
    RESET   : in std_logic;
    CLK_EN  : in std_logic;

    MODE_IN   : in std_logic; -- either store all 7 subsequent outputs on trigger (repeater mode), or only when trigger occurs (trigger mode)
    DATA_IN   : in std_logic_vector(31 downto 0); -- the data that should be written to etrax registers 0-7

    CTRL_IN   : in std_logic_vector(31 downto 0); -- specific trigger pattern to trigger at
    ETRAX_OUT : out std_logic_vector(8*32-1 downto 0) -- the output is written to ETRAX Regs

  );
  end component;



-- General drivers
signal combined_fifo_read    : std_logic_vector(FIFO_NUM-1 downto 0)   := (others => '0');
signal combined_fifo_data    : std_logic_vector(FIFO_NUM*FIFO_BUS-1 downto 0) := (others => '0');
signal combined_fifo_val     : std_logic_vector(FIFO_NUM-1 downto 0)   := (others => '0');
signal combined_fifo_status  : std_logic_vector(8*FIFO_NUM-1 downto 0) := (others => '0');
signal combined_reg_data     : std_logic_vector(REG_NUM*REG_BUS-1 downto 0) := (others => '0');
signal combined_cfg_data_in, combined_cfg_data_out : std_logic_vector(8*FIFO_NUM-1 downto 0) := (others => '0');
signal combined_cfg_write    : std_logic_vector (FIFO_NUM-1 downto 0) := (others => '0');
signal fifo_timer_bus        : std_logic_vector(FIFO_NUM*32-1 downto 0 ) := (others => '0');
signal main_status, next_main_status, cfg_status, reg_status, fifo_status : std_logic_vector (7 downto 0) := "00000000";
signal s_cfg, s_fifo, s_reg, s_rom : std_logic := '0';
signal reg_data, fifo_data   : std_logic_vector(EXT_BUS-1 downto 0) := (others => '0');
signal reg_valid, fifo_valid : std_logic := '0';

-- TODO (fix these)
-- handle correct ROM access
-- signal rom_read, rom_dataready : std_logic := '0';
-- signal rom_addr : std_logic_vector(8 downto 0);
-- signal rom_data : std_logic_vector(31 downto 0);
-- -- The multiplexer signals (CFG,FIFO,REG)
-- signal mux_read_2,mux_read_3, mux_write_1, mux_timeout_2, mux_dataready_2, mux_dataready_3, mux_ack_1, mux_nomore_2, mux_unknown_1, mux_unknown_2, mux_unknown_3 : std_logic := '0';
-- signal mux_data_out_2,mux_data_out_3  : std_logic_vector(31 downto 0);
-- signal mux_addr_1,mux_addr_2,mux_addr_3 : std_logic_vector(15 downto 0);
-- signal mux_data_in_1 : std_logic_vector(CFG_WIDTH-1 downto 0);
-- --DUMMY
-- signal dummy_cfg  : std_logic_vector(32-CFG_WIDTH-1 downto 0) := (others => '0');
-- signal dummy_input_bit, rom_dummy_bit, bus_timeout_dummy, fifo_write_dummy : std_logic := '0';
-- signal dummy_input_vector, bus_data_dummy, reg_data_dummy, cfg_data_dummy, fifo_data_dummy, dummy_stats : std_logic_vector(31 downto 0) := (others => '0');
-- signal bus_addr_dummy : std_logic_vector(6 downto 0) := (others => '0');
-- signal reg_write_dummy, reg_ack_dummy, reg_nomore_dummy, reg_timeout_dummy : std_logic := '0';
-- signal cfg_read_dummy, cfg_timeout_dummy, cfg_rdy_dummy, cfg_nomore_dummy : std_logic := '0';
-- signal dummy24 : std_logic_vector(23 downto 0) := (others => '0');
--signal test_bus : std_logic_vector(32*(SIGNAL_NUM+1)-1 downto 0);


begin



--   proc_rom_ctrl : process(CLK)
--   begin
--     if rising_edge(CLK) then
--       rom_dataready <= rom_read;
--     end if;
--   end process;


	gen_fifos : for i in 0 to FIFO_NUM-1 generate
    the_FIFO : FIFO_cell
    generic map(
      fifo_type => fifos(i).fifo_type,
      f_low     => fifos(i).f_low,
      f_high    => fifos(i).f_high,
      t_res     => fifos(i).t_res,
      t_size    => fifos(i).t_size,
      d_size    => fifos(i).d_size,
      i_size    => fifos(i).i_size
    )
    port map(
      CLK         => CLK,
      RESET       => RESET,
      CLK_EN      => CLK_EN,

      DATA_IN     => FIFO_DATA_IN(FIFO_BUS*(i+1)-1 downto FIFO_BUS*i),
      WRITE_IN    => FIFO_WRITE_IN(i),
      READ_IN     => combined_fifo_read(i),
      DATA_OUT    => combined_fifo_data(FIFO_BUS*(i+1)-1 downto FIFO_BUS*i),
      VALID_OUT   => combined_fifo_val(i),
      STATUS_OUT  => combined_fifo_status(8*(i+1)-1 downto 8*i),

      CFG_IN      => combined_cfg_data_out(8*(i+1)-1 downto 8*i),
      TIME_IN	    => fifo_timer_bus(32*(i+1)-1 downto 32*i),
      EXTERNAL_IN => EXTERNAL_STAMP_IN
    );
  end generate;

  gen_fifo_timer_bus : for i in 0 to FIFO_NUM-1 generate
    gen_ftimertype1 : if fifos(i).timer = 0 generate
      fifo_timer_bus(32*(i+1)-1 downto 32*i) <= TIMER0_IN;
    end generate;
    gen_ftimertype2 : if fifos(i).timer = 1 generate
      fifo_timer_bus(32*(i+1)-1 downto 32*i+8) <= (others => '0');
      fifo_timer_bus(32*(i)+7 downto 32*i)  <= TIMER1_IN;
    end generate;
    gen_ftimertype3 : if fifos(i).timer = 2 generate
      fifo_timer_bus(32*(i+1)-1 downto 32*i) <= TIMER2_IN;
    end generate;
  end generate;

  gen_registers : for i in 0 to REG_NUM-1 generate
    the_REG : REG_cell
    generic map(
      width => regs(i).width
    )
    port map(
      CLK       => CLK,
      RESET     => RESET,
      CLK_EN    => CLK_EN,

      DATA_IN   => REG_DATA_IN(REG_BUS*(i+1)-1 downto REG_BUS*i),
      DATA_OUT  => combined_reg_data(REG_BUS*(i+1)-1 downto REG_BUS*i)
    );
  end generate;

  gen_cfg_cells : for i in 0 to FIFO_NUM-1 generate
    the_CFG : CFG_cell
    generic map(
      init  => cfgs(i).init
    )
    port map(
      CLK       => CLK,
      RESET     => RESET,
      CLK_EN    => CLK_EN,

      DATA_IN   => combined_cfg_data_in(8*(i+1)-1 downto 8*i),
      WRITE_IN  => combined_cfg_write(i),
      DATA_OUT  => combined_cfg_data_out(8*(i+1)-1 downto 8*i)
    );
  end generate;

--  	the_ROM : rom_32x113
-- 	port map(
-- 		CLK => CLK,
-- 		ADDR_IN => rom_addr,
-- 		DATA_OUT => rom_data
-- 	);

	the_cfg_mux : cfg_mux
	port map(
	  CLK        => CLK,
	  RESET      => RESET,
	  CLK_EN     => CLK_EN,

    WRITE_IN   => s_cfg,
    DATA_IN    => DATA_IN,
    ADDR_IN    => ADDR_IN(7 downto 0),

    DATA_OUT   => combined_cfg_data_in,
    WRITE_OUT  => combined_cfg_write,

    STATUS_OUT => cfg_status
	);

  the_reg_mux : reg_mux
  port map(
    CLK       => CLK,
    RESET     => RESET,
    CLK_EN    => CLK_EN,

    READ_IN    => s_reg,
    ADDR_IN    => ADDR_IN(7 downto 0),
    DATA_IN    => combined_reg_data,

    DATA_OUT   => reg_data,
    VALID_OUT  => reg_valid,

    STATUS_OUT => reg_status
  );

	the_fifo_mux : fifo_mux
	port map(
	  CLK        => CLK,
	  RESET      => RESET,
	  CLK_EN     => CLK_EN,

    READ_IN    => s_fifo,
    ADDR_IN    => ADDR_IN(7 downto 0),

    READ_OUT   => combined_fifo_read,

    DATA_IN    => combined_fifo_data,
    VALID_IN   => combined_fifo_val,
    STATUS_IN  => combined_fifo_status,

    DATA_OUT   => fifo_data,
    VALID_OUT  => fifo_valid,
    STATUS_OUT => fifo_status
	);

  p_MUX_RW:process(ADDR_IN, READ_IN, WRITE_IN)
  begin
  next_main_status(5) <= '0'; -- Wrong Address Range for the Read/Write
  if READ_IN = '1' then
    if ADDR_IN(9 downto 8) = "00" then
      s_rom  <= '1';
      s_cfg  <= '0';
      s_fifo <= '0';
      s_reg  <= '0';
    elsif ADDR_IN(9 downto 8) = "10" then
      s_rom  <= '0';
      s_cfg  <= '0';
      s_fifo <= '1';
      s_reg  <= '0';
    elsif ADDR_IN(9 downto 8) = "11" then
      s_rom  <= '0';
      s_cfg  <= '0';
      s_fifo <= '0';
      s_reg  <= '1';
    else
      s_rom  <= '0';
      s_cfg  <= '0';
      s_fifo <= '0';
      s_reg  <= '0';
      next_main_status(5) <= '1';
    end if;
  elsif WRITE_IN = '1' then
    if ADDR_IN(9 downto 8) = "01" then
      s_rom  <= '0';
      s_cfg  <= '1';
      s_fifo <= '0';
      s_reg  <= '0';
    else
      s_rom  <= '0';
      s_cfg  <= '0';
      s_fifo <= '0';
      s_reg  <= '0';
      next_main_status(5) <= '1';
    end if;
  else
    s_rom  <= '0';
    s_cfg  <= '0';
    s_fifo <= '0';
    s_reg  <= '0';
  end if;
  end process;

  p_register: process(CLK)
  begin
  if rising_edge(CLK) then
    main_status <= next_main_status;
  end if;
  end process;

  p_handle_data:process(reg_valid, fifo_valid, reg_data, fifo_data)
  begin
  VALID_OUT <= fifo_valid or reg_valid;
  DATA_OUT  <= (others => '0');
  if fifo_valid = '1' then
    DATA_OUT(FIFO_BUS-1 downto 0) <= fifo_data;
  elsif reg_valid = '1' then
    DATA_OUT(REG_BUS-1 downto 0)  <= reg_data;
  end if;
  end process;

  next_main_status(0) <= fifo_status(0) or reg_status(0) or cfg_status(0);  -- Unknown Cell Address
  next_main_status(1) <= fifo_status(1);                                    -- FIFO empty
  next_main_status(2) <= cfg_status(1);                                     -- ACK

  STATUS_OUT <= main_status;


  DEBUG_OUT(7 downto 0)  <= combined_fifo_status(7 downto 0);
  DEBUG_OUT(15 downto 8) <= combined_fifo_status(15 downto 8);
  DEBUG_OUT(23 downto 16) <= main_status;
  DEBUG_OUT(31 downto 24) <= "00" & combined_fifo_read(1) & combined_fifo_read(0) & s_rom & s_cfg & s_fifo & s_reg;

--  DEBUG_OUT(31 downto 0) <= (others => '0');
--  DEBUG_OUT(31 downto 0) <= FIFO_DATA_IN(31 downto 0);

end architecture;