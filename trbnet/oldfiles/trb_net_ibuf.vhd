-- for a description see HADES wiki
-- http://hades-wiki.gsi.de/cgi-bin/view/DaqSlowControl/TrbNetIBUF

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;

--Entity decalaration for clock generator
entity trb_net_ibuf is

  generic (DEPTH : integer := 3);     -- Depth of the FIFO, 2^(n+1)

  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered by the Media (the IOBUF MUST read)
    MED_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    MED_READ_OUT:      out STD_LOGIC; -- buffer reads a word from media
    MED_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    -- Internal direction port
    INT_HEADER_IN:     in  STD_LOGIC; -- Concentrator kindly asks to resend the last header
    INT_DATAREADY_OUT: out STD_LOGIC;
    INT_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_READ_IN:       in  STD_LOGIC; 
    INT_ERROR_OUT:     out STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    -- Status and control port
    STAT_LOCKED:       out STD_LOGIC_VECTOR (15 downto 0);
    CTRL_LOCKED:       in  STD_LOGIC_VECTOR (15 downto 0);
    STAT_BUFFER:       out STD_LOGIC_VECTOR (31 downto 0)
    );
end trb_net_ibuf;

architecture trb_net_ibuf_arch of trb_net_ibuf is

component trb_net_fifo is
  
  generic (WIDTH : integer := 8;  	-- FIFO word width
           DEPTH : integer := 4);     -- Depth of the FIFO, 2^(n+1)

  port (CLK    : in std_logic;  		
        RESET  : in std_logic;  	
        CLK_EN : in std_logic;
        
        DATA_IN         : in  std_logic_vector(WIDTH - 1 downto 0);  -- Input data
        WRITE_ENABLE_IN : in  std_logic;  		
        DATA_OUT        : out std_logic_vector(WIDTH - 1 downto 0);  -- Output data
        READ_ENABLE_IN  : in  std_logic; 
        FULL_OUT        : out std_logic;  	-- Full Flag
        EMPTY_OUT       : out std_logic;
        DEPTH_OUT       : out std_logic_vector(7 downto 0)
        );     

end component;

  component trb_net_sbuf is

  generic (DATA_WIDTH : integer := 56;
           VERSION: integer := 0);

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
    STAT_BUFFER:       out STD_LOGIC
    );
  end component;

signal fifo_data_in : std_logic_vector(50 downto 0);
signal fifo_data_out : std_logic_vector(50 downto 0);
signal fifo_write, fifo_read : std_logic;
signal fifo_full, fifo_empty : std_logic;
signal fifo_depth : std_logic_vector(7 downto 0);

signal next_read_out, reg_read_out : std_logic;

signal got_ack_internal, reg_ack_internal : std_logic;    --should be raised for 1 cycle when ack
                                        --arrived
signal is_locked, got_locked,release_locked : std_logic;
signal got_eob_out, reg_eob_out: std_logic;
signal sbuf_free, comb_next_read: std_logic;
signal tmp_INT_DATAREADY_OUT: std_logic;
signal tmp_INT_DATA_OUT: std_logic_vector(50 downto 0);
signal current_last_header, next_last_header : std_logic_vector(50 downto 0);

type ERROR_STATE is (IDLE, GOT_OVERFLOW_ERROR, GOT_LOCKED_ERROR, GOT_UNDEFINED_ERROR);
signal current_error_state, next_error_state : ERROR_STATE;

signal next_rec_buffer_size_out, current_rec_buffer_size_out
  : std_logic_vector(3 downto 0);       -- buffer size control

  begin

    FIFO: trb_net_fifo
      generic map (
        WIDTH => 51,
        DEPTH => DEPTH)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        DATA_IN   => fifo_data_in,
        WRITE_ENABLE_IN => fifo_write,
        DATA_OUT  => fifo_data_out,
        READ_ENABLE_IN => fifo_read,
        FULL_OUT  => fifo_full,
        EMPTY_OUT => fifo_empty,
        DEPTH_OUT => fifo_depth
        );

    fifo_data_in <= MED_DATA_IN;
    
-- this process controls the writing of the media into the fifo
  FILTER_DATAREADY_IN : process(MED_DATA_IN, MED_DATAREADY_IN, MED_ERROR_IN,
                                  fifo_full, is_locked, current_rec_buffer_size_out,
                                  current_error_state, reg_read_out)
    begin  -- process
      got_ack_internal <=   '0';
      next_read_out <=  '0';
      fifo_write <=  '0';
      next_rec_buffer_size_out <= current_rec_buffer_size_out;
      next_error_state <= current_error_state;
      
      if MED_DATAREADY_IN = '1' and reg_read_out= '1' then
        if MED_DATA_IN(TYPE_POSITION) = TYPE_ACK then
          -- BUGBUG: this causes trouble if the IBUF is full -> ack sent even if buffer overflow
          got_ack_internal <=   '1';
          if MED_DATA_IN(F1_POSITION) = F1_CHECK_ACK then
            next_rec_buffer_size_out <= MED_DATA_IN(BUFFER_SIZE_POSITION);
          end if;
        -- elsif fifo_full = '0' and is_locked = '0' then
        elsif fifo_full = '0' then    -- still ACKs may come even when locked
          fifo_write <=  '1';
          next_read_out <=  '1';
        elsif fifo_full = '1' then
          next_error_state <= GOT_OVERFLOW_ERROR;
        elsif is_locked = '1' then
          next_error_state <= GOT_LOCKED_ERROR;
        end if;                         -- end TYPE
      end if;                           -- end MED_DATAREADY_IN
      if fifo_full = '0' then -- and is_locked = '0' then
        next_read_out <=  '1';
      end if;
    end process;

  MED_READ_OUT <= reg_read_out; 

  reg_buffer: process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        current_rec_buffer_size_out <= (others => '0');
        reg_ack_internal    <= '0';
        reg_read_out        <= '0';
        current_error_state <= IDLE;
      elsif CLK_EN = '1' then
        current_rec_buffer_size_out <= next_rec_buffer_size_out;
        reg_ack_internal    <= got_ack_internal;
        reg_read_out        <= next_read_out;
        current_error_state <= next_error_state;
      else
        current_rec_buffer_size_out <= current_rec_buffer_size_out;
        reg_ack_internal    <= reg_ack_internal;
        reg_read_out        <= reg_read_out;
        current_error_state <= current_error_state;
      end if;
    end if;
  end process;



  SBUF: trb_net_sbuf
    generic map (DATA_WIDTH => 51, Version => 0)
    port map (
      CLK   => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      COMB_DATAREADY_IN => tmp_INT_DATAREADY_OUT,
      COMB_next_READ_OUT => comb_next_read,
      COMB_READ_IN => '1',
      COMB_DATA_IN => tmp_INT_DATA_OUT,
      SYN_DATAREADY_OUT => INT_DATAREADY_OUT,
      SYN_DATA_OUT => INT_DATA_OUT,
      SYN_READ_IN => INT_READ_IN
      );
  
  sbuf_free <= comb_next_read or INT_READ_IN;  --sbuf killed
  
-- this process controls what will be forwarded to the internal point
  DATA_OUT : process (INT_HEADER_IN, fifo_data_out,
                      current_last_header, INT_READ_IN,
                      release_locked, is_locked, sbuf_free, fifo_empty)
  begin
    -- tmp_INT_DATA_OUT <= (others => '1');
    tmp_INT_DATA_OUT <= fifo_data_out;
    tmp_INT_DATAREADY_OUT <= '0';
    got_eob_out <= '0';
    fifo_read   <= '0';
    got_locked  <= is_locked;
    next_last_header <= current_last_header;

    if fifo_empty = '0' then
      if sbuf_free  = '1' and fifo_data_out(TYPE_POSITION) = TYPE_DAT then
        -- next data word can be registered
        tmp_INT_DATAREADY_OUT <= '1';
        fifo_read   <= '1';
      elsif  sbuf_free  = '1' and fifo_data_out(TYPE_POSITION) = TYPE_TRM then
        got_eob_out <= '1';           --exactly when buffer is killed
        tmp_INT_DATAREADY_OUT <= '1';
        if release_locked = '0' then
          got_locked  <= '1';
        end if;
        fifo_read   <= '1';
      elsif  sbuf_free  = '1' and fifo_data_out(TYPE_POSITION) = TYPE_HDR then
        next_last_header <= fifo_data_out;
        tmp_INT_DATAREADY_OUT <= '1';
        fifo_read   <= '1';
      elsif fifo_data_out(TYPE_POSITION) = TYPE_EOB then
        fifo_read   <= '1';
        got_eob_out <= '1';
        tmp_INT_DATAREADY_OUT <= '0';
        -- this should happen only one CLK cycle
      end if;
    else
      tmp_INT_DATAREADY_OUT <= '0';
    end if;    
  end process;

--BUGBUG HDR retransmit needed

release_locked <= CTRL_LOCKED(0);
STAT_LOCKED(0) <= is_locked;
STAT_LOCKED(15 downto 1) <= (others => '0');

reg_locked: process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        is_locked <= '0';
        reg_eob_out <= '0';
        current_last_header <= (others => '0');
      elsif CLK_EN = '1' then
        if release_locked = '1' then
          is_locked <= '0';
        else
          is_locked <= got_locked;
        end if;
        reg_eob_out <= got_eob_out;
        current_last_header <= next_last_header;
      else
        is_locked <= is_locked;
        reg_eob_out <= reg_eob_out;
        current_last_header <= current_last_header;
      end if;
    end if;
  end process;


  
-- make STAT_BUFFER
  STAT_BUFFER(3 downto 0) <= (fifo_depth(3 downto 0)-1);  --divide by 2, since 2
                                                      --buffers have to be stored
  STAT_BUFFER(7 downto 4) <= current_rec_buffer_size_out;
  STAT_BUFFER(8) <= reg_eob_out;
  STAT_BUFFER(9) <= reg_ack_internal;

  MAKE_ERROR_BITS : process(current_error_state)
    begin
      if current_error_state = IDLE then
        STAT_BUFFER(11 downto 10) <= "00";
      elsif current_error_state = GOT_OVERFLOW_ERROR then
        STAT_BUFFER(11 downto 10) <= "01";
      elsif current_error_state = GOT_LOCKED_ERROR then
        STAT_BUFFER(11 downto 10) <= "10";
      else
        STAT_BUFFER(11 downto 10) <= "11";
      end if;
    end process;

  STAT_BUFFER(31 downto 12) <= (others => '0');
  
end trb_net_ibuf_arch;
  
