-- for a description see HADES wiki
-- http://hades-wiki.gsi.de/cgi-bin/view/DaqSlowControl/TrbNetOBUF

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;

--Entity decalaration for clock generator
entity trb_net_obuf is
  generic (
    DATA_COUNT_WIDTH : integer := 4;
    SWITCH_OFF_BUFFER_CHECK : integer := 0
                      --switching off erroneous output buffer counter. MUST ONLY be 
                      --used for short transfers!!!!
    );
  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_OUT: out STD_LOGIC;
    MED_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    MED_READ_IN:       in  STD_LOGIC; 
    -- Internal direction port
    INT_DATAREADY_IN:  in  STD_LOGIC; 
    INT_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_READ_OUT:      out STD_LOGIC; 
    -- Status and control port
    STAT_LOCKED:       out STD_LOGIC_VECTOR (15 downto 0);
    CTRL_LOCKED:       in  STD_LOGIC_VECTOR (15 downto 0);
    STAT_BUFFER:       out STD_LOGIC_VECTOR (31 downto 0);
    CTRL_BUFFER:       in  STD_LOGIC_VECTOR (31 downto 0)
    );
end trb_net_obuf;

architecture trb_net_obuf_arch of trb_net_obuf is

  component trb_net_sbuf is
  generic (DATA_WIDTH : integer := 56;
            VERSION : integer := 0);

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
  
  signal current_output_buffer : STD_LOGIC_VECTOR (50 downto 0);
  signal current_ACK_word, current_EOB_word, current_DATA_word, current_NOP_word :
    STD_LOGIC_VECTOR (50 downto 0);
  signal comb_dataready, comb_next_read, comb_read ,sbuf_free: STD_LOGIC;
  signal reg_INT_READ_OUT , next_INT_READ_OUT:STD_LOGIC;
  
  signal next_SEND_ACK_IN, reg_SEND_ACK_IN : STD_LOGIC;
  signal sent_ACK, sent_EOB, sent_DATA : STD_LOGIC;

  signal CURRENT_DATA_COUNT, next_DATA_COUNT : STD_LOGIC_VECTOR (DATA_COUNT_WIDTH-1  downto 0);
--  signal max_DATA_COUNT, next_max_DATA_COUNT : STD_LOGIC_VECTOR (15 downto 0);
  signal max_DATA_COUNT_minus_one, next_max_DATA_COUNT_minus_one : STD_LOGIC_VECTOR (DATA_COUNT_WIDTH-1 downto 0);
  signal max_DATA_COUNT_minus_two, next_max_DATA_COUNT_minus_two : STD_LOGIC_VECTOR (DATA_COUNT_WIDTH-1 downto 0);
  signal tmp_next_max_DATA_COUNT_minus_one : STD_LOGIC_VECTOR (15 downto 0);
  signal tmp_next_max_DATA_COUNT_minus_two : STD_LOGIC_VECTOR (15 downto 0);  
  signal TRANSMITTED_BUFFERS, next_TRANSMITTED_BUFFERS : STD_LOGIC_VECTOR (1 downto 0);
  signal increase_TRANSMITTED_BUFFERS, decrease_TRANSMITTED_BUFFERS : STD_LOGIC;

  signal SEND_BUFFER_SIZE_IN : STD_LOGIC_VECTOR (3 downto 0);
  signal REC_BUFFER_SIZE_IN  : STD_LOGIC_VECTOR (3 downto 0);
  signal SEND_ACK_IN         : STD_LOGIC;
  signal GOT_ACK_IN          : STD_LOGIC;
  
  signal is_locked, got_locked,release_locked : std_logic;        
  
  -- type BUFFER_STATE is (BUFFER_IDLE, BUFFER_SEND_ACK, BUFFER_SEND_EOB, BUFFER_SEND_DATA, BUFFER_BLOCKED);

  
  begin

    SBUF: trb_net_sbuf
        generic map (DATA_WIDTH => 51, VERSION => 0)
        port map (
          CLK   => CLK,
          RESET  => RESET,
          CLK_EN => CLK_EN,
          COMB_DATAREADY_IN => comb_dataready,
          COMB_next_READ_OUT => comb_next_read,
          COMB_READ_IN => comb_read,
          COMB_DATA_IN => current_output_buffer,
          SYN_DATAREADY_OUT => MED_DATAREADY_OUT,
          SYN_DATA_OUT => MED_DATA_OUT,
          SYN_READ_IN => MED_READ_IN
          );
    
    decrease_TRANSMITTED_BUFFERS <= GOT_ACK_IN;
    comb_read <= '1';
    INT_READ_OUT <= reg_INT_READ_OUT;
--    sbuf_free <= comb_next_read or MED_READ_IN;  --sbuf killed
    sbuf_free <= comb_next_read;
    
    COMB_NEXT_TRANSFER : process(current_NOP_word, MED_READ_IN, comb_next_read,
                                 CURRENT_DATA_COUNT,reg_SEND_ACK_IN,reg_INT_READ_OUT,
                                 INT_DATAREADY_IN, INT_DATA_IN, sent_ACK, sent_EOB,
                                 current_ACK_word,current_EOB_word, sbuf_free, sent_data,
                                 max_DATA_COUNT_minus_two,next_DATA_COUNT,
                                 next_TRANSMITTED_BUFFERS)
    begin  
      current_output_buffer <= current_NOP_word;
      next_INT_READ_OUT     <= '1';
      increase_TRANSMITTED_BUFFERS <= '0';
      next_DATA_COUNT    <= CURRENT_DATA_COUNT;
      next_SEND_ACK_IN   <= reg_SEND_ACK_IN;
      comb_dataready     <= '0';
-- The read of data words have highest priority if this was prepared
      if (reg_INT_READ_OUT = '1' and  INT_DATAREADY_IN = '1') then
        current_output_buffer <= INT_DATA_IN;
        comb_dataready <= '1';          --I hope sbuf can store
        if INT_DATA_IN(TYPE_POSITION) = TYPE_TRM then  --TRM means EOB
          next_DATA_COUNT <= (others => '0');
          increase_TRANSMITTED_BUFFERS <= '1';
        else
          next_DATA_COUNT <= CURRENT_DATA_COUNT +1;
        end if;
-- If we are not able to fill ACK or EOB now, we have to stop activity
        if (sent_ACK = '1'  or sent_EOB = '1' ) then
          next_INT_READ_OUT       <= '0';
          if sent_ACK = '1' then        --BUGBUG: next_SEND_ACK_IN should be a
                                        --counter (2 may arrive)
            next_SEND_ACK_IN   <= '1';
          end if;
        end if;
-- Otherwise we fill the gap
      elsif sent_ACK  = '1' and sbuf_free = '1' then
        current_output_buffer <= current_ACK_word;
        next_SEND_ACK_IN   <= '0';
        comb_dataready <= '1';
        next_INT_READ_OUT       <= '0';  --stop activity to be on the safe side
      elsif sent_ACK  = '1' and sbuf_free = '0' then
        next_SEND_ACK_IN   <= '1';
      elsif sent_EOB  = '1' and sbuf_free = '1' then
        current_output_buffer <= current_EOB_word;
        next_DATA_COUNT    <= (others => '0');
        increase_TRANSMITTED_BUFFERS <= '1';
        comb_dataready <= '1';
        next_INT_READ_OUT <= '0';  --stop activity to be on the safe side
      end if;

--finally, block data read if the rec buffer is full
      if sent_data = '0' or
        ((current_DATA_COUNT(DATA_COUNT_WIDTH-1 downto 0) = (max_DATA_COUNT_minus_two(DATA_COUNT_WIDTH-1 downto 0)))
          and reg_INT_READ_OUT = '1' and  INT_DATAREADY_IN = '1' ) --and INT_DATA_IN(TYPE_POSITION) = TYPE_TRM
                                                 --long version of (next_count = max_count-1)
        or (next_TRANSMITTED_BUFFERS(1) = '1' and SWITCH_OFF_BUFFER_CHECK = 0)
      then
        next_INT_READ_OUT       <= '0';
      end if;
--In any case: if sbuf not free, then we stop data taking
      if sbuf_free = '0' then
        next_INT_READ_OUT       <= '0';
      end if;
      
    end process;

    
    REG : process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        reg_SEND_ACK_IN       <= '0';
        CURRENT_DATA_COUNT    <= (others => '0');
        reg_INT_READ_OUT      <= '0';
      elsif CLK_EN = '1' then
        reg_SEND_ACK_IN       <= next_SEND_ACK_IN; 
        CURRENT_DATA_COUNT    <= next_DATA_COUNT;
        reg_INT_READ_OUT      <= next_INT_READ_OUT;
      else
        reg_SEND_ACK_IN       <= reg_SEND_ACK_IN;
        CURRENT_DATA_COUNT    <= CURRENT_DATA_COUNT;
        reg_INT_READ_OUT      <= reg_INT_READ_OUT;
      end if;
    end if;
  end process;

  -- buffer registers
  STAT_BUFFER(1 downto 0)   <= TRANSMITTED_BUFFERS;
  STAT_BUFFER(15 downto 2)  <= (others => '0');
  STAT_BUFFER(31 downto 16) <= CURRENT_DATA_COUNT;
  SEND_BUFFER_SIZE_IN       <= CTRL_BUFFER(3 downto 0);
  REC_BUFFER_SIZE_IN        <= CTRL_BUFFER(7 downto 4);
  SEND_ACK_IN               <= CTRL_BUFFER(8);
  GOT_ACK_IN                <= CTRL_BUFFER(9);

  -- build the words and the internal data readys
  current_ACK_word(TYPE_POSITION) <= TYPE_ACK;
  current_ACK_word(47 downto 20)  <= (others => '0');
  current_ACK_word(BUFFER_SIZE_POSITION) <= SEND_BUFFER_SIZE_IN;
  current_ACK_word(15 downto 0)   <= (others => '0');
  sent_ACK                   <= SEND_ACK_IN or reg_SEND_ACK_IN;

  current_EOB_word(TYPE_POSITION) <= TYPE_EOB;
  current_EOB_word(47 downto 0)   <= (others => '0');
  gen_sent_EOB : process (CURRENT_DATA_COUNT, max_DATA_COUNT_minus_one)
    begin
      if (CURRENT_DATA_COUNT = max_DATA_COUNT_minus_one) then
        sent_EOB <= '1';
      else
        sent_EOB <= '0';
      end if;
    end process;

  current_NOP_word(TYPE_POSITION) <= TYPE_ILLEGAL;
  current_NOP_word(47 downto 0)   <= (others => '0');
    
  current_DATA_word(50 downto 0)  <= INT_DATA_IN;
  sent_DATA                       <= '1' when (TRANSMITTED_BUFFERS(1) = '0' or SWITCH_OFF_BUFFER_CHECK = 1) else '0'; 

-- generate max_DATA_COUNT, comb. operation which should be registered
--     next_max_DATA_COUNT <= "0000000000000100" when REC_BUFFER_SIZE_IN="0001" else
--                            "0000000000001000" when REC_BUFFER_SIZE_IN="0010" else
--                            "0000000000010000" when REC_BUFFER_SIZE_IN="0011" else
--                            "0000000000100000" when REC_BUFFER_SIZE_IN="0100" else
--                            "0000000000000010";
    tmp_next_max_DATA_COUNT_minus_one <= "0000000000000011" when REC_BUFFER_SIZE_IN="0001" else
                                         "0000000000000111" when REC_BUFFER_SIZE_IN="0010" else
                                         "0000000000001111" when REC_BUFFER_SIZE_IN="0011" else
                                         "0000000000011111" when REC_BUFFER_SIZE_IN="0100" else
                                         "0000000000000001";
    tmp_next_max_DATA_COUNT_minus_two <= "0000000000000010" when REC_BUFFER_SIZE_IN="0001" else
                                         "0000000000000110" when REC_BUFFER_SIZE_IN="0010" else
                                         "0000000000001110" when REC_BUFFER_SIZE_IN="0011" else
                                         "0000000000011110" when REC_BUFFER_SIZE_IN="0100" else
                                         "0000000000000000";
    next_max_DATA_COUNT_minus_one(DATA_COUNT_WIDTH-1 downto 0) <= tmp_next_max_DATA_COUNT_minus_one(DATA_COUNT_WIDTH-1 downto 0);
    next_max_DATA_COUNT_minus_two(DATA_COUNT_WIDTH-1 downto 0) <= tmp_next_max_DATA_COUNT_minus_two(DATA_COUNT_WIDTH-1 downto 0);
-- next_max_DATA_COUNT <= 2 ** (REC_BUFFER_SIZE_IN + 1);
    -- BUGBUG via pattern_gen

  reg_max_DATA_COUNT : process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        max_DATA_COUNT_minus_one(0) <= '1';
        max_DATA_COUNT_minus_one(DATA_COUNT_WIDTH-1 downto 1) <= (others => '0');
        max_DATA_COUNT_minus_two(DATA_COUNT_WIDTH-1 downto 0) <= (others => '0');
      else
        max_DATA_COUNT_minus_one <= next_max_DATA_COUNT_minus_one;
        max_DATA_COUNT_minus_two <= next_max_DATA_COUNT_minus_two;
      end if;
    end if;
  end process;

  
-- increase and decrease transmitted buffers
  comb_TRANSMITTED_BUFFERS : process (increase_TRANSMITTED_BUFFERS, decrease_TRANSMITTED_BUFFERS, TRANSMITTED_BUFFERS)
  begin
    if (increase_TRANSMITTED_BUFFERS = '1' and decrease_TRANSMITTED_BUFFERS = '0') then
      next_TRANSMITTED_BUFFERS <= TRANSMITTED_BUFFERS +1;
    elsif (increase_TRANSMITTED_BUFFERS = '0' and decrease_TRANSMITTED_BUFFERS = '1') then
      next_TRANSMITTED_BUFFERS <= TRANSMITTED_BUFFERS -1;
    else
      next_TRANSMITTED_BUFFERS <= TRANSMITTED_BUFFERS;
    end if;
  end process;    

  reg_TRANSMITTED_BUFFERS : process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        TRANSMITTED_BUFFERS <= "00";
      elsif CLK_EN = '1' then
        TRANSMITTED_BUFFERS <= next_TRANSMITTED_BUFFERS;
      else
        TRANSMITTED_BUFFERS <= TRANSMITTED_BUFFERS;
      end if;
    end if;
  end process;


  --locking control
  comb_locked : process (MED_READ_IN, current_output_buffer, release_locked, is_locked)
    
  begin  -- process
    got_locked  <= is_locked;
    
    if MED_READ_IN = '1' then
      if current_output_buffer(TYPE_POSITION) = TYPE_TRM and release_locked = '0' then
        got_locked  <= '1';
      elsif release_locked = '1' then
        got_locked <= '0';
      end if;      
    elsif release_locked = '1' then
      got_locked <= '0';
    end if;                           -- MED_READ_IN
  end process;

  release_locked <= CTRL_LOCKED(0);
  STAT_LOCKED(0) <= is_locked;
  STAT_LOCKED(15 downto 1) <= (others => '0');

  reg_locked: process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        is_locked <= '0';
      elsif CLK_EN = '1' then
        is_locked <= got_locked;
      else
        is_locked <= is_locked;
      end if;
    end if;
  end process;

  
end trb_net_obuf_arch;
  
