LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;


entity trb_net_base_api is

  generic (API_TYPE : integer := 0;              -- type of api: 0 passive, 1 active
           FIFO_TO_INT_DEPTH : integer := 0;     -- Depth of the FIFO, 2^(n+1),
                                                 -- for the direction to
                                                 -- internal world
           FIFO_TO_APL_DEPTH : integer := 0;     -- direction to application
           FIFO_TERM_BUFFER_DEPTH  : integer := 0);  -- fifo for auto-answering of
                                               -- the master path, if set to 0
                                               -- no buffer is used at all

  
  port(
    --  Misc
    CLK    : in std_logic;              
    RESET  : in std_logic;      
    CLK_EN : in std_logic;

    -- APL Transmitter port
    APL_DATA_IN:       in  STD_LOGIC_VECTOR (47 downto 0); -- Data word "application to network"
    APL_WRITE_IN:      in  STD_LOGIC; -- Data word is valid and should be transmitted
    APL_FIFO_FULL_OUT: out STD_LOGIC; -- Stop transfer, the fifo is full
    APL_SHORT_TRANSFER_IN: in  STD_LOGIC; -- 
    APL_DTYPE_IN:      in  STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL_ERROR_PATTERN_IN: in  STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
    APL_SEND_IN:       in  STD_LOGIC; -- Release sending of the data
    APL_TARGET_ADDRESS_IN: in  STD_LOGIC_VECTOR (15 downto 0); -- Address of
                                                               -- the target (only for active APIs)

    -- Receiver port
    APL_DATA_OUT:      out STD_LOGIC_VECTOR (47 downto 0); -- Data word "network to application"
    APL_TYP_OUT:       out STD_LOGIC_VECTOR (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
    APL_DATAREADY_OUT: out STD_LOGIC; -- Data word is valid and might be read out
    APL_READ_IN:       in  STD_LOGIC; -- Read data word
    
    -- APL Control port
    APL_RUN_OUT:       out STD_LOGIC; -- Data transfer is running
    APL_MY_ADDRESS_IN: in  STD_LOGIC_VECTOR (15 downto 0);  -- My own address (temporary solution!!!)
    APL_SEQNR_OUT:     out STD_LOGIC_VECTOR (7 downto 0);
    
    -- Internal direction port
    -- the ports with master or slave in their name are to be mapped by the active api
    -- to the init respectivly the reply path and vice versa in the passive api.
    -- lets define: the "master" path is the path that I send data on.
    INT_MASTER_DATAREADY_OUT: out STD_LOGIC;
    INT_MASTER_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_MASTER_READ_IN:       in  STD_LOGIC; 

    INT_MASTER_DATAREADY_IN:  in  STD_LOGIC;
    INT_MASTER_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_MASTER_READ_OUT:      out STD_LOGIC; 

    
    INT_SLAVE_HEADER_IN:     in  STD_LOGIC; -- Concentrator kindly asks to resend the last
                                      -- header (only for the reply path)
    INT_SLAVE_DATAREADY_OUT: out STD_LOGIC;
    INT_SLAVE_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_SLAVE_READ_IN:       in  STD_LOGIC; 

    INT_SLAVE_DATAREADY_IN:  in  STD_LOGIC;
    INT_SLAVE_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_SLAVE_READ_OUT:      out STD_LOGIC;

    -- Status and control port
    STAT_FIFO_TO_INT: out std_logic_vector(31 downto 0);
    STAT_FIFO_TO_APL: out std_logic_vector(31 downto 0)
    -- not needed now, but later

    );
end entity trb_net_base_api;



architecture trb_net_base_api_arch of trb_net_base_api is
  component trb_net_fifo is
    generic (
      WIDTH : integer := 8;        -- FIFO word width
      DEPTH : integer := 4);     -- Depth of the FIFO, 2^(n+1)
    port (
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      
      DATA_IN         : in  std_logic_vector(WIDTH - 1 downto 0);  -- Input data
      WRITE_ENABLE_IN : in  std_logic;
      DATA_OUT        : out std_logic_vector(WIDTH - 1 downto 0);  -- Output data
      READ_ENABLE_IN  : in  std_logic; 
      FULL_OUT        : out std_logic;        -- Full Flag
      EMPTY_OUT       : out std_logic;
      DEPTH_OUT       : out std_logic_vector(7 downto 0)
      );     
  end component;

  component trb_net_dummy_fifo is
    generic (WIDTH : integer := 8);     -- Depth of the FIFO, 2^(n+1)
    port (
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      DATA_IN         : in  std_logic_vector(WIDTH - 1 downto 0);  -- Input data
      WRITE_ENABLE_IN : in  std_logic;
      DATA_OUT        : out std_logic_vector(WIDTH - 1 downto 0);  -- Output data
      READ_ENABLE_IN  : in  std_logic; 
      FULL_OUT        : out std_logic;        -- Full Flag
      EMPTY_OUT       : out std_logic;
      DEPTH_OUT       : out std_logic_vector(7 downto 0)
      );
  end component;

  component trb_net_sbuf is
    generic (DATA_WIDTH : integer := 56;
            VERSION: integer := 1);
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      --  port to combinatorial logic
      COMB_DATAREADY_IN:  in  STD_LOGIC;  --comb logic provides data word
      COMB_next_READ_OUT: out STD_LOGIC;  --sbuf can read in NEXT cycle
      COMB_READ_IN:       in  STD_LOGIC;  --comb logic IS reading
      COMB_DATA_IN:       in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
      -- Port to synchronous output.
      SYN_DATAREADY_OUT:  out STD_LOGIC; 
      SYN_DATA_OUT:       out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
      SYN_READ_IN:        in  STD_LOGIC; 
      -- Status and control port
      STAT_BUFFER:        out STD_LOGIC
      );
  end component;



  component trb_net_term is
    generic (FIFO_TERM_BUFFER_DEPTH  : integer := 0);  -- fifo for auto-answering of the master
                                                -- path, if set to 0 no buffer is used at all 
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      -- Internal direction port
      -- This is just a clone from trb_net_iobuf 
      INT_DATAREADY_OUT: out STD_LOGIC;
      INT_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
      INT_READ_IN:       in  STD_LOGIC; 
      INT_DATAREADY_IN:  in  STD_LOGIC;
      INT_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
      INT_READ_OUT:      out STD_LOGIC;

      -- "mini" APL, just to see the triggers coming in
      APL_DTYPE_OUT:         out STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
      APL_ERROR_PATTERN_OUT: out STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
      APL_SEQNR_OUT:         out STD_LOGIC_VECTOR (7 downto 0);
      APL_GOT_TRM:           out STD_LOGIC;
      APL_HOLD_TRM:          in STD_LOGIC;
      APL_DTYPE_IN:          in STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
      APL_ERROR_PATTERN_IN:  in STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
      APL_MY_ADDRESS_IN: in  STD_LOGIC_VECTOR (15 downto 0)  -- My own address (temporary solution!!!)
      -- Status and control port
      -- not needed now, but later
      );
  end component;

  -- signals for the APL to INT fifo:
  signal fifo_to_int_data_in : std_logic_vector(47 downto 0);
  signal fifo_to_int_write : std_logic;
  signal fifo_to_int_data_out : std_logic_vector(47 downto 0);
  signal fifo_to_int_read : std_logic;
  signal fifo_to_int_full : std_logic;
  signal fifo_to_int_empty : std_logic;
  
  -- signals for the INT to APL:
  signal fifo_to_apl_data_in : std_logic_vector(50 downto 0);
  signal fifo_to_apl_write : std_logic;
  signal fifo_to_apl_data_out : std_logic_vector(50 downto 0);
  signal fifo_to_apl_read : std_logic;
  signal fifo_to_apl_full : std_logic;
  signal fifo_to_apl_empty : std_logic;
  
  -- signals for the test buffer
  signal fifo_term_buffer_data_in : std_logic_vector(50 downto 0);
  signal fifo_term_buffer_write : std_logic;
  signal fifo_term_buffer_data_out : std_logic_vector(50 downto 0);
  signal fifo_term_buffer_read : std_logic;
  signal fifo_term_buffer_full : std_logic;
  signal fifo_term_buffer_empty : std_logic;
  
  signal state_bits : std_logic_vector(2 downto 0);
  type API_STATE is (IDLE, SEND_HEADER, RUNNING, SHUTDOWN, SEND_SHORT, SEND_TRAILER, WAITING,MY_ERROR);
  type TERM_BUFFER_STATE is (IDLE, RUNNING, SEND_TRAILER, MY_ERROR);
  signal current_state, next_state : API_STATE;
  signal tb_current_state, tb_next_state : TERM_BUFFER_STATE;
  signal slave_running, next_slave_running : std_logic;
  
  signal combined_header: std_logic_vector(47 downto 0);                 --stored in sbuf
  --  , registered_header, next_registered_header: std_logic_vector(47 downto 0);
  --signal update_registered_header: std_logic;
  signal combined_trailer, registered_trailer, next_registered_trailer: std_logic_vector(47 downto 0);
  signal update_registered_trailer: std_logic;
  signal tb_registered_trailer, tb_next_registered_trailer: std_logic_vector(47 downto 0);
  signal tb_registered_target, tb_next_registered_target: std_logic_vector(15 downto 0);
  
  signal sequence_counter,next_sequence_counter : std_logic_vector(7 downto 0);
  signal next_INT_MASTER_DATA_OUT: std_logic_vector(50 downto 0);
  signal next_INT_MASTER_DATAREADY_OUT: std_logic;
  signal sbuf_free, sbuf_next_READ: std_logic;
  signal next_INT_SLAVE_READ_OUT, reg_INT_SLAVE_READ_OUT: std_logic;
  signal next_APL_DATAREADY_OUT, reg_APL_DATAREADY_OUT: std_logic;
  signal next_APL_DATA_OUT, reg_APL_DATA_OUT: std_logic_vector(47 downto 0);
  signal next_APL_TYP_OUT, reg_APL_TYP_OUT: std_logic_vector(2 downto 0);
  
  type OUTPUT_SELECT is (HDR, DAT, TRM, TRM_COMB);
  signal out_select: OUTPUT_SELECT;
  
begin

---------------------------------------
-- termination for active api
---------------------------------------

--  gen_term: if API_TYPE = 1 generate
    TrbNetTerm: trb_net_term
      generic map(FIFO_TERM_BUFFER_DEPTH => 0)
      port map(
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        INT_DATAREADY_OUT => INT_SLAVE_DATAREADY_OUT,
        INT_DATA_OUT      => INT_SLAVE_DATA_OUT,
        INT_READ_IN       => INT_SLAVE_READ_IN, 
        INT_DATAREADY_IN  => INT_MASTER_DATAREADY_IN,
        INT_DATA_IN       => INT_MASTER_DATA_IN,
        INT_READ_OUT      => INT_MASTER_READ_OUT,
        APL_HOLD_TRM      => '0',
        APL_DTYPE_IN      => (others => '0'),
        APL_ERROR_PATTERN_IN => (others => '0'),
        APL_MY_ADDRESS_IN => APL_MY_ADDRESS_IN
        );
--  end generate;

--   gen_noterm: if API_TYPE = 0 generate
--     INT_SLAVE_READ_OUT <= '0';
--     
--   end generate;

---------------------------------------
-- fifo to internal
---------------------------------------

  CHECK_BUFFER3: if FIFO_TO_INT_DEPTH >0 generate
    FIFO_TO_INT: trb_net_fifo
      generic map (
        WIDTH => 48,
        DEPTH => FIFO_TO_INT_DEPTH)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        DATA_IN   => fifo_to_int_data_in,
        WRITE_ENABLE_IN => fifo_to_int_write,
        DATA_OUT  => fifo_to_int_data_out,
        READ_ENABLE_IN => fifo_to_int_read,
        FULL_OUT  => fifo_to_int_full,
        EMPTY_OUT => fifo_to_int_empty
        );
  end generate;
  
  CHECK_BUFFER4:   if FIFO_TO_INT_DEPTH =0 generate
    FIFO_TO_INT: trb_net_dummy_fifo
      generic map (
        WIDTH => 48)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        DATA_IN   => fifo_to_int_data_in,
        WRITE_ENABLE_IN => fifo_to_int_write,
        DATA_OUT  => fifo_to_int_data_out,
        READ_ENABLE_IN => fifo_to_int_read,
        FULL_OUT  => fifo_to_int_full,
        EMPTY_OUT => fifo_to_int_empty
        );
  end generate CHECK_BUFFER4;
  
  STAT_FIFO_TO_INT(2 downto 0)  <= fifo_to_int_data_in(2 downto 0);
  STAT_FIFO_TO_INT(3)           <= fifo_to_int_write;
  STAT_FIFO_TO_INT(10 downto 8) <= fifo_to_int_data_out(2 downto 0);
  STAT_FIFO_TO_INT(11)           <= fifo_to_int_read;
  STAT_FIFO_TO_INT(14)           <= fifo_to_int_full;
  STAT_FIFO_TO_INT(15)           <= fifo_to_int_empty;
  STAT_FIFO_TO_INT(7 downto 4)  <= (others => '0');
  STAT_FIFO_TO_INT(13 downto 12)  <= (others => '0');
  STAT_FIFO_TO_INT(28 downto 16) <= (others => '0');
  STAT_FIFO_TO_INT(31 downto 29) <= state_bits;
---------------------------------------
-- fifo to apl
---------------------------------------

  CHECK_BUFFER5:   if FIFO_TO_APL_DEPTH >0 generate
    FIFO_TO_APL: trb_net_fifo
      generic map (
        WIDTH => 51,
        DEPTH => FIFO_TO_APL_DEPTH)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        DATA_IN   => fifo_to_apl_data_in,
        WRITE_ENABLE_IN => fifo_to_apl_write,
        DATA_OUT  => fifo_to_apl_data_out,
        READ_ENABLE_IN => fifo_to_apl_read,
        FULL_OUT  => fifo_to_apl_full,
        EMPTY_OUT => fifo_to_apl_empty
        );
  end generate CHECK_BUFFER5;
  
  CHECK_BUFFER6:   if FIFO_TO_APL_DEPTH =0 generate
    FIFO_TO_APL: trb_net_dummy_fifo
      generic map (
        WIDTH => 51)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        DATA_IN   => fifo_to_apl_data_in,
        WRITE_ENABLE_IN => fifo_to_apl_write,
        DATA_OUT  => fifo_to_apl_data_out,
        READ_ENABLE_IN => fifo_to_apl_read,
        FULL_OUT  => fifo_to_apl_full,
        EMPTY_OUT => fifo_to_apl_empty
        );
  end generate CHECK_BUFFER6;

  STAT_FIFO_TO_APL(2 downto 0)   <= fifo_to_apl_data_in(2 downto 0);
  STAT_FIFO_TO_APL(3)            <= fifo_to_apl_write;
  STAT_FIFO_TO_APL(9 downto 8)   <= fifo_to_apl_data_out(1 downto 0);
  STAT_FIFO_TO_APL(11)           <= fifo_to_apl_read;
  STAT_FIFO_TO_APL(14)           <= fifo_to_apl_full;
  STAT_FIFO_TO_APL(15)           <= fifo_to_apl_empty;
  STAT_FIFO_TO_APL(7 downto 4)   <= (others => '0');
  --STAT_FIFO_TO_APL(13 downto 12) <= (others => '0');
  STAT_FIFO_TO_APL(31 downto 16) <= (others => '0');
  STAT_FIFO_TO_APL(13) <= reg_INT_SLAVE_READ_OUT;
  STAT_FIFO_TO_APL(12) <= INT_SLAVE_DATAREADY_IN;
  STAT_FIFO_TO_APL(10)           <= reg_APL_DATAREADY_OUT;
  
---------------------------------------
-- a sbuf on the active channel
---------------------------------------

    ACTIVE_SBUF: trb_net_sbuf
      generic map (
        DATA_WIDTH => 51,
        VERSION => 0)
      port map (
        CLK   => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN => next_INT_MASTER_DATAREADY_OUT,
        COMB_next_READ_OUT => sbuf_next_READ,
        COMB_READ_IN => '1',
        COMB_DATA_IN => next_INT_MASTER_DATA_OUT,
        SYN_DATAREADY_OUT => INT_MASTER_DATAREADY_OUT,
        SYN_DATA_OUT => INT_MASTER_DATA_OUT,
        SYN_READ_IN => INT_MASTER_READ_IN
        );



  --sbuf_free <= sbuf_next_READ or INT_INIT_READ_IN;  --sbuf killed in next cycle
  sbuf_free <= sbuf_next_READ;
  next_registered_trailer <= combined_trailer;
  --next_registered_header <= combined_header;
  next_APL_DATA_OUT <= fifo_to_apl_data_out(DWORD_POSITION);
  next_APL_TYP_OUT <= fifo_to_apl_data_out(TYPE_POSITION);


---------------------------------------
-- select data for int direction
---------------------------------------
  process (out_select, combined_header, registered_trailer,
          fifo_to_int_data_out, combined_trailer)
  begin
    if out_select = HDR then
      next_INT_MASTER_DATA_OUT(TYPE_POSITION) <= TYPE_HDR;
      next_INT_MASTER_DATA_OUT(DWORD_POSITION) <= combined_header;
    elsif out_select = TRM then
      next_INT_MASTER_DATA_OUT(TYPE_POSITION) <= TYPE_TRM;
      next_INT_MASTER_DATA_OUT(DWORD_POSITION) <= registered_trailer;
    elsif out_select = TRM_COMB then
      next_INT_MASTER_DATA_OUT(TYPE_POSITION) <= TYPE_TRM;
      next_INT_MASTER_DATA_OUT(DWORD_POSITION) <= combined_trailer;
    else
      next_INT_MASTER_DATA_OUT(TYPE_POSITION) <= TYPE_DAT;
      next_INT_MASTER_DATA_OUT(DWORD_POSITION) <= fifo_to_int_data_out;
    end if;
  end process;


---------------------------------------
-- the state machine
---------------------------------------
--  gen_active_fsm : if API_TYPE = 1 generate
  STATE_COMB : process(current_state, APL_SEND_IN, combined_header,
                        INT_MASTER_READ_IN, APL_WRITE_IN, fifo_to_int_empty,
                        fifo_to_int_data_out, combined_trailer, slave_running,
                        next_registered_trailer, fifo_to_int_data_out,
                        fifo_to_apl_empty, INT_SLAVE_DATAREADY_IN,
                        reg_INT_SLAVE_READ_OUT,fifo_to_apl_read,
                        reg_APL_DATAREADY_OUT, fifo_to_apl_data_out,
                        reg_APL_DATAREADY_OUT, APL_READ_IN, sbuf_free,
                        reg_APL_TYP_OUT, APL_SHORT_TRANSFER_IN, fifo_to_apl_full)
    begin  -- process
      next_state <=  MY_ERROR;
      next_INT_MASTER_DATAREADY_OUT <= '0';
      out_select <= DAT;
      update_registered_trailer <= '0';
      fifo_to_int_read <= '0';
      next_INT_SLAVE_READ_OUT <= '0';
      fifo_to_apl_write <= '0';
      next_APL_DATAREADY_OUT <= '0';
      fifo_to_apl_read <= '0';
      next_slave_running <= slave_running;
      next_sequence_counter <= sequence_counter;
    -------------------------------------------------------------------------------
    -- IDLE
    -------------------------------------------------------------------------------
      if current_state = IDLE then
        if APL_SEND_IN = '1' then
          if APL_SHORT_TRANSFER_IN = '1' and APL_WRITE_IN = '0' and fifo_to_int_empty = '1' then
            next_state <=  SEND_SHORT;  -- no next data word, waiting for falling edge of APL_SEND_IN
            next_INT_MASTER_DATAREADY_OUT <= '0';
            update_registered_trailer <= '1'; -- moved from SEND_SHORT
          else  -- normal transfer, prepare the header
            next_state <= SEND_HEADER;
            out_select <= HDR;
            next_INT_MASTER_DATAREADY_OUT <= '1';
          end if;                       -- next word will be a header
        else
          next_state <=  IDLE;
        end if;                         -- APL_SEND_IN
    -------------------------------------------------------------------------------
    -- SEND_SHORT
    -------------------------------------------------------------------------------
      elsif current_state = SEND_SHORT then 
        next_state <=  SEND_SHORT;
        if APL_SEND_IN = '0' then -- terminate the transfer
          next_state <= SEND_TRAILER;
          next_INT_MASTER_DATAREADY_OUT <= '1';
          out_select <= TRM;
        end if;
    -------------------------------------------------------------------------------
    -- SEND_HEADER
    -------------------------------------------------------------------------------
      elsif current_state = SEND_HEADER then
        if sbuf_free = '1' then  -- kill current header
          next_state <= RUNNING;
          if fifo_to_int_empty = '1' then
            next_INT_MASTER_DATAREADY_OUT <= '0';
          else
            next_INT_MASTER_DATAREADY_OUT <= '1';
            out_select <= DAT;
            fifo_to_int_read <= '1';
          end if;                       -- fifo_to_int_empty
        else
          next_state <= SEND_HEADER;
        end if;
    -------------------------------------------------------------------------------
    -- RUNNING
    -------------------------------------------------------------------------------
      elsif current_state = RUNNING then
        if APL_SEND_IN = '0' then       -- terminate the transfer
          if fifo_to_int_empty = '1' then  -- immediate stop
            next_state <= SEND_TRAILER;
            update_registered_trailer <= '1';
            next_INT_MASTER_DATAREADY_OUT <= '1';
            out_select <= TRM_COMB;
          else
            next_state <= SHUTDOWN;
            update_registered_trailer <= '1';
            if sbuf_free = '1' then
              -- data words have to be prepared
              next_INT_MASTER_DATAREADY_OUT <= '1';
              out_select <= DAT;
              fifo_to_int_read <= '1';
            end if;                     -- fifo_to_int_empty = '0'
          end if;
        else                         -- APL_SEND_IN: still running
          next_state <= RUNNING;
          if fifo_to_int_empty = '0' and sbuf_free = '1' then
          -- data words have to be prepared
            next_INT_MASTER_DATAREADY_OUT <= '1';
            out_select <= DAT; 
            fifo_to_int_read <= '1';
          end if;                       -- fifo_to_int_empty = '0'
        end if;
    -------------------------------------------------------------------------------
    -- SHUTDOWN: Empty the pipe
    -------------------------------------------------------------------------------
      elsif current_state = SHUTDOWN then
        next_state <= SHUTDOWN;
        if fifo_to_int_empty = '0' and sbuf_free = '1' then
          -- data words have to be prepared
            next_INT_MASTER_DATAREADY_OUT <= '1';
            out_select <= DAT; 
            fifo_to_int_read <= '1';
        elsif sbuf_free = '1'  then
          -- we are done
          next_state <= SEND_TRAILER;
          next_INT_MASTER_DATAREADY_OUT <= '1';
          out_select <= TRM; 
        end if;
    -------------------------------------------------------------------------------
    -- SEND_TRAILER
    -------------------------------------------------------------------------------
      elsif current_state = SEND_TRAILER then
        if sbuf_free = '1' then  -- kill current trailer
          next_state <= WAITING;
          out_select <= TRM; 
          next_INT_MASTER_DATAREADY_OUT <= '0';
          next_slave_running <= '0';
        else
          next_state <= SEND_TRAILER;
        end if;
    -------------------------------------------------------------------------------
    -- WAITING => for the answer or a request
    -------------------------------------------------------------------------------
      elsif current_state = WAITING then
        next_state <= WAITING;
        -- here we have to supply the receiver port
        -- part 1: connection to network        
        if fifo_to_apl_full = '0' or (fifo_to_apl_read = '1' and reg_APL_DATAREADY_OUT = '1') then
          next_INT_SLAVE_READ_OUT <= '1';
        end if;
        if reg_INT_SLAVE_READ_OUT = '1' and INT_SLAVE_DATAREADY_IN = '1' then
          fifo_to_apl_write <= '1';  -- use fifo as the pipe
        end if;

        -- part 2: connection to apl
--        if fifo_to_apl_empty = '0' then
        if fifo_to_apl_empty = '0' and not (reg_APL_DATAREADY_OUT = '1' and APL_READ_IN = '1') then      --is this really correct????
          next_APL_DATAREADY_OUT <= '1';  
        end if;                         -- read/no read

        if reg_APL_DATAREADY_OUT = '1' and APL_READ_IN = '1' then
          -- valid read
          fifo_to_apl_read <= '1';
          if (reg_APL_TYP_OUT = TYPE_TRM or reg_APL_TYP_OUT = TYPE_HDR)  then
            next_slave_running <= '1';
          end if;
          if reg_APL_TYP_OUT = TYPE_TRM and (APL_READ_IN = '1' and reg_APL_DATAREADY_OUT = '1') then  --fifo_to_apl_read = '1'
            next_state <= IDLE;
            next_sequence_counter <= sequence_counter +1;
          end if;
        end if;
        -- MISSING: SEQNR check
        -- OPEN QUESTION: Address matching? makes sense for a reply transfer?
      end if;                           -- end state switch      
    end process;
--  end generate;



---------------------------------------
--                                     
---------------------------------------

  -- combine the next header
  combined_header(F1_POSITION) <= APL_MY_ADDRESS_IN;
  combined_header(F2_POSITION) <= APL_TARGET_ADDRESS_IN;
  combined_header(15 downto 14) <= (others => '0');  -- LAY
  combined_header(13 downto 12) <= (others => '0');  -- VERS
  combined_header(11 downto 4)  <= sequence_counter;  -- SEQNR
  combined_header(3 downto 0)   <= APL_DTYPE_IN;
  combined_trailer(F1_POSITION) <= APL_ERROR_PATTERN_IN(31 downto 16);
  combined_trailer(F2_POSITION) <= APL_ERROR_PATTERN_IN(15 downto 0);
  combined_trailer(15 downto 14) <= (others => '0');  -- res.
  combined_trailer(13 downto 12) <= (others => '0');  -- VERS
  combined_trailer(11 downto 4)  <= sequence_counter;  -- SEQNR
  combined_trailer(3 downto 0)   <= APL_DTYPE_IN;
  -- this is not very consequent, find a better solution the be independent
  -- with the range

  -- connect Transmitter port
  fifo_to_int_data_in <= APL_DATA_IN;
  fifo_to_int_write <= (APL_WRITE_IN and not fifo_to_int_full) when (current_state = IDLE or
                                                                      current_state = SEND_HEADER or
                                                                      current_state = RUNNING)

                        else '0';


  APL_FIFO_FULL_OUT <= fifo_to_int_full;  -- APL has to stop writing


  INT_SLAVE_READ_OUT <= reg_INT_SLAVE_READ_OUT;

  process(CLK)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        reg_APL_DATAREADY_OUT <= '0';
        reg_APL_DATA_OUT <= (others => '0');
        reg_APL_TYP_OUT <= (others => '0');
      else
        reg_APL_DATAREADY_OUT <= next_APL_DATAREADY_OUT;
        reg_APL_DATA_OUT <= next_APL_DATA_OUT;
        reg_APL_TYP_OUT <= next_APL_TYP_OUT;
      end if;
    end if;
  end process;


  -- connect receiver
  fifo_to_apl_data_in <= INT_SLAVE_DATA_IN;
  
-- this has to be registered!
--   reg_APL_DATAREADY_OUT <= next_APL_DATAREADY_OUT;
--   reg_APL_DATA_OUT <= next_APL_DATA_OUT;
--   reg_APL_TYP_OUT <= next_APL_TYP_OUT;

  APL_DATAREADY_OUT <= reg_APL_DATAREADY_OUT;
  APL_DATA_OUT <= reg_APL_DATA_OUT;
  APL_TYP_OUT <= reg_APL_TYP_OUT;
--  APL_RUN_OUT <= '0' when ((current_state = IDLE )) 
  APL_RUN_OUT <= '0' when ((current_state = IDLE and API_TYPE = 1)
                           or (slave_running = '0'  and API_TYPE = 0))
                 else '1';
  APL_SEQNR_OUT <= sequence_counter;

--removed and put into main state machine
-- generate the sequence counter
--     -- combinatorial part
--   SEQNR_COMB : process(sequence_counter, current_state, next_state)
--     begin
--       if current_state = WAITING and next_state = IDLE then
--         next_sequence_counter <=  sequence_counter+1;
--       else
--         next_sequence_counter <=  sequence_counter;
--       end if;
--     end process;



  CLK_REG: process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        sequence_counter <= (others => '0');
        reg_INT_SLAVE_READ_OUT <= '0';
        if API_TYPE = 1 then
          current_state  <= IDLE;
        else
          current_state  <= WAITING;
        end if;
        slave_running <= '0';
        tb_current_state  <= IDLE;
        tb_registered_trailer <= (others => '0');
        tb_registered_target <= ILLEGAL_ADRESS;
      elsif CLK_EN = '1' then
        sequence_counter <= next_sequence_counter;
        reg_INT_SLAVE_READ_OUT <= next_INT_SLAVE_READ_OUT;
        current_state  <= next_state;
        slave_running <= next_slave_running;
        tb_current_state  <= tb_next_state;
        tb_registered_trailer <= tb_next_registered_trailer;
        tb_registered_target <= tb_next_registered_target;
      else
        sequence_counter <= sequence_counter;
        reg_INT_SLAVE_READ_OUT <= reg_INT_SLAVE_READ_OUT;
        current_state  <= current_state;
        slave_running <= slave_running;
        tb_current_state  <= tb_current_state;
        tb_registered_trailer <= tb_registered_trailer;
        tb_registered_target <= tb_registered_target;
      end if;
    end if;
  end process;

  REG3 : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          registered_trailer <= (others => '0');
        elsif update_registered_trailer = '1' then
          registered_trailer <= next_registered_trailer;
        else
          registered_trailer <= registered_trailer;
        end if;
      end if;
    end process;

process(current_state)
  begin
    case current_state is
      when IDLE => state_bits <= "000";
      when SEND_HEADER => state_bits <= "001";
      when RUNNING => state_bits <= "010";
      when SHUTDOWN => state_bits <= "011";
      when SEND_SHORT => state_bits <= "100";
      when SEND_TRAILER => state_bits <= "101";
      when WAITING => state_bits <= "110";
      when others => state_bits <= "111";
    end case;
  end process;



end architecture trb_net_base_api_arch;



