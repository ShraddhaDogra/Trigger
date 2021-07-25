-- this is just a terminator, which auto-answers requests
-- for a description see HADES wiki
-- http://hades-wiki.gsi.de/cgi-bin/view/DaqSlowControl/TrbNetTerm

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;


entity trb_net_term is

  generic (FIFO_TERM_BUFFER_DEPTH  : integer := 0);  -- fifo for auto-answering of
                                               -- the master path, if set to 0
                                               -- no buffer is used at all 
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
END trb_net_term;

architecture trb_net_term_arch of trb_net_term is

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

-- signals for the test buffer
signal next_APL_DTYPE_OUT, reg_APL_DTYPE_OUT: std_logic_vector(3 downto 0);
signal next_APL_ERROR_PATTERN_OUT, reg_APL_ERROR_PATTERN_OUT: std_logic_vector(31 downto 0);
signal next_APL_SEQNR_OUT, reg_APL_SEQNR_OUT: std_logic_vector(7 downto 0);
signal next_APL_GOT_TRM, reg_APL_GOT_TRM: std_logic;

signal fifo_term_buffer_data_in : std_logic_vector(50 downto 0);
signal fifo_term_buffer_write : std_logic;
signal fifo_term_buffer_data_out : std_logic_vector(50 downto 0);
signal fifo_term_buffer_read : std_logic;
signal fifo_term_buffer_full : std_logic;
signal fifo_term_buffer_empty : std_logic;

type TERM_BUFFER_STATE is (IDLE, RUNNING, SEND_TRAILER, MY_ERROR);
signal tb_current_state, tb_next_state : TERM_BUFFER_STATE;

-- signal combined_header, registered_header, next_registered_header: std_logic_vector(47 downto 0);
-- signal combined_trailer, registered_trailer, next_registered_trailer: std_logic_vector(47 downto 0);
 signal tb_registered_trailer, tb_next_registered_trailer: std_logic_vector(47 downto 0);
 signal tb_registered_target, tb_next_registered_target: std_logic_vector(15 downto 0);

-- signal sequence_counter,next_sequence_counter : std_logic_vector(7 downto 0);
-- signal next_INT_INIT_DATA_OUT: std_logic_vector(50 downto 0);
-- signal next_INT_INIT_DATAREADY_OUT: std_logic;
-- signal sbuf_free, sbuf_next_READ: std_logic;
 signal next_INT_REPLY_READ_OUT, reg_INT_REPLY_READ_OUT: std_logic;
-- signal next_APL_DATAREADY_OUT, reg_APL_DATAREADY_OUT: std_logic;
-- signal next_APL_DATA_OUT, reg_APL_DATA_OUT: std_logic_vector(47 downto 0);
-- signal next_APL_TYP_OUT, reg_APL_TYP_OUT: std_logic_vector(2 downto 0);

begin


CHECK_BUFFER1:   if FIFO_TERM_BUFFER_DEPTH >0 generate
    FIFO_TERM_BUFFER: trb_net_fifo
    generic map (
      WIDTH => 51,
      DEPTH => FIFO_TERM_BUFFER_DEPTH)
    port map (
      CLK       => CLK,
      RESET     => RESET,
      CLK_EN    => CLK_EN,
      DATA_IN   => fifo_term_buffer_data_in,
      WRITE_ENABLE_IN => fifo_term_buffer_write,
      DATA_OUT  => fifo_term_buffer_data_out,
      READ_ENABLE_IN => fifo_term_buffer_read,
      FULL_OUT  => fifo_term_buffer_full,
      EMPTY_OUT => fifo_term_buffer_empty
      );
end generate CHECK_BUFFER1;
CHECK_BUFFER2:   if FIFO_TERM_BUFFER_DEPTH =0 generate
  fifo_term_buffer_empty <= '1';
  fifo_term_buffer_full  <= '0';
  fifo_term_buffer_data_out <= (others => '0');
  
end generate CHECK_BUFFER2;

   APL_DTYPE_OUT <= reg_APL_DTYPE_OUT;
   APL_ERROR_PATTERN_OUT <= reg_APL_ERROR_PATTERN_OUT;
   APL_SEQNR_OUT <= reg_APL_SEQNR_OUT;
   APL_GOT_TRM <= reg_APL_GOT_TRM;      


    FIFO_TERM_BUFFER_CTRL: process (tb_current_state, INT_DATA_IN,
                                    INT_DATAREADY_IN, tb_next_registered_trailer,
                                    tb_registered_trailer,
                                    fifo_term_buffer_empty, fifo_term_buffer_data_out,
                                    INT_READ_IN, tb_registered_target,
                                    reg_APL_DTYPE_OUT, reg_APL_ERROR_PATTERN_OUT,
                                    reg_APL_SEQNR_OUT, reg_APL_GOT_TRM,APL_MY_ADDRESS_IN, 
                                    APL_HOLD_TRM, APL_DTYPE_IN, APL_ERROR_PATTERN_IN)
    begin  -- process
      INT_READ_OUT <= '0';
      fifo_term_buffer_data_in(TYPE_POSITION) <= TYPE_ILLEGAL;
      fifo_term_buffer_data_in(DWORD_POSITION) <= (others => '0');
      fifo_term_buffer_write <= '0';
      tb_next_state <= MY_ERROR;
      tb_next_registered_trailer <= tb_registered_trailer;
      tb_next_registered_target <= tb_registered_target;
      fifo_term_buffer_read<= '0';
      INT_DATAREADY_OUT <= '0';
      INT_DATA_OUT(DWORD_POSITION) <= (others => '0');
      INT_DATA_OUT(TYPE_POSITION) <= TYPE_ILLEGAL;
      next_APL_DTYPE_OUT <= reg_APL_DTYPE_OUT;
      next_APL_ERROR_PATTERN_OUT <= reg_APL_ERROR_PATTERN_OUT;
      next_APL_SEQNR_OUT <= reg_APL_SEQNR_OUT;
      next_APL_GOT_TRM <= reg_APL_GOT_TRM;
-----------------------------------------------------------------------
-- IDLE
-----------------------------------------------------------------------      
      if tb_current_state = IDLE then
        INT_READ_OUT <= '1';       -- I always can read
        tb_next_state <=  IDLE;
        if INT_DATA_IN(TYPE_POSITION) = TYPE_HDR and INT_DATAREADY_IN = '1' then
                    -- switch source and target adress
          fifo_term_buffer_data_in(SOURCE_POSITION) <= INT_DATA_IN(TARGET_POSITION);
          fifo_term_buffer_data_in(TARGET_POSITION) <= INT_DATA_IN(SOURCE_POSITION);
          fifo_term_buffer_data_in(F3_POSITION) <= INT_DATA_IN(F3_POSITION);
          fifo_term_buffer_data_in(TYPE_POSITION) <= TYPE_HDR;
          tb_next_registered_target <= INT_DATA_IN(TARGET_POSITION);
          if fifo_term_buffer_full = '0' and (INT_DATA_IN(TARGET_POSITION) = APL_MY_ADDRESS_IN
                                              or INT_DATA_IN(TARGET_POSITION) = BROADCAST_ADRESS) then
            fifo_term_buffer_write <= '1';
          else
            fifo_term_buffer_write <= '0';
          end if;
        elsif INT_DATA_IN(TYPE_POSITION) = TYPE_DAT and INT_DATAREADY_IN = '1' then
          fifo_term_buffer_data_in <= INT_DATA_IN;
          if fifo_term_buffer_full = '0' and (tb_registered_target = APL_MY_ADDRESS_IN
                                               or tb_registered_target = BROADCAST_ADRESS) then
            fifo_term_buffer_write <= '1';
          else
            fifo_term_buffer_write <= '0';
          end if;
        elsif INT_DATA_IN(TYPE_POSITION) = TYPE_TRM and INT_DATAREADY_IN = '1' then
          --tb_next_registered_trailer <= INT_INIT_DATA_IN(DWORD_POSITION);  
                                        --keep trailer for later use
          -- in addition, write out some debug info
          next_APL_DTYPE_OUT <= INT_DATA_IN(DTYPE_POSITION);
          next_APL_ERROR_PATTERN_OUT <= INT_DATA_IN(ERRORPATTERN_POSITION);
          next_APL_SEQNR_OUT <= INT_DATA_IN(SEQNR_POSITION);
          next_APL_GOT_TRM <= '1';
          tb_next_state <=  RUNNING;
        end if;
-----------------------------------------------------------------------
-- RUNNING
-----------------------------------------------------------------------
      elsif tb_current_state = RUNNING then
        tb_next_state <=  RUNNING;
        if fifo_term_buffer_empty = '0' then  -- Have buffered stuff
          INT_DATAREADY_OUT <= '1';
          INT_DATA_OUT <= fifo_term_buffer_data_out;
          if (INT_READ_IN = '1') then
            fifo_term_buffer_read <= '1';
          end if;
        elsif APL_HOLD_TRM = '1' then
          tb_next_state <=  RUNNING;    --hold the line
        else 
          tb_next_state <=  SEND_TRAILER;
          tb_next_registered_trailer(DTYPE_POSITION) <= APL_DTYPE_IN;
          tb_next_registered_trailer(ERRORPATTERN_POSITION) <= APL_ERROR_PATTERN_IN;
          tb_next_registered_trailer(SEQNR_POSITION) <= reg_APL_SEQNR_OUT;
          tb_next_registered_trailer(15 downto 12) <= (others => '0');
        end if;                         -- Have buffered stuff
-----------------------------------------------------------------------
-- TRAILER
-----------------------------------------------------------------------
      elsif tb_current_state = SEND_TRAILER then
        tb_next_state <= SEND_TRAILER ;
        INT_DATAREADY_OUT <= '1';
        INT_DATA_OUT(DWORD_POSITION) <= tb_registered_trailer;
        INT_DATA_OUT(TYPE_POSITION) <= TYPE_TRM;
        if (INT_READ_IN = '1') then
          tb_next_state <=  IDLE;
          tb_next_registered_target <= ILLEGAL_ADRESS;
          next_APL_GOT_TRM <= '0';
        end if;
      end if;                           -- tb_current_state switch
    end process;

CLK_REG: process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        tb_current_state  <= IDLE;
        tb_registered_trailer <= (others => '0');
        tb_registered_target <= ILLEGAL_ADRESS;
        reg_APL_DTYPE_OUT <= (others => '0');
        reg_APL_ERROR_PATTERN_OUT <= (others => '0');
        reg_APL_SEQNR_OUT <= (others => '0');
        reg_APL_GOT_TRM <= '0';
      else
        tb_current_state  <= tb_next_state;
        tb_registered_trailer <= tb_next_registered_trailer;
        tb_registered_target <= tb_next_registered_target;
        reg_APL_DTYPE_OUT <= next_APL_DTYPE_OUT;
        reg_APL_ERROR_PATTERN_OUT <= next_APL_ERROR_PATTERN_OUT;
        reg_APL_SEQNR_OUT <= next_APL_SEQNR_OUT;
        reg_APL_GOT_TRM <= next_APL_GOT_TRM;
      end if;
    end if;
  end process;
    
end trb_net_term_arch;
