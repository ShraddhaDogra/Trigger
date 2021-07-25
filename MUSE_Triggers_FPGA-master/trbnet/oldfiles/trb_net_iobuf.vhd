-- main working horse for the trbnet
-- for a description see HADES wiki
-- http://hades-wiki.gsi.de/cgi-bin/view/DaqSlowControl/TrbNetIOBUF

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;

--Entity decalaration for clock generator
entity trb_net_iobuf is

  generic (
      SWITCH_OFF_BUFFER_CHECK : integer := 0;
                      --switching off erroneous output buffer counter. MUST ONLY be 
                      --used for short transfers!!!!
      INIT_DEPTH : integer := 3;     -- Depth of the FIFO, 2^(n+1), if
                                          -- the initibuf
      REPLY_DEPTH : integer := 3);   -- or the replyibuf

  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    --  Media direction port
    MED_INIT_DATAREADY_OUT: out STD_LOGIC;  --Data word ready to be read out
                                       --by the media (via the TrbNetIOMultiplexer)
    MED_INIT_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    MED_INIT_READ_IN:       in  STD_LOGIC; -- Media is reading
    
    MED_INIT_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered by the Media
                                      -- (the IOBUF MUST read)
    MED_INIT_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    MED_INIT_READ_OUT:      out STD_LOGIC; -- buffer reads a word from media
    MED_INIT_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits

    MED_REPLY_DATAREADY_OUT: out STD_LOGIC;  --Data word ready to be read out
                                       --by the media (via the TrbNetIOMultiplexer)
    MED_REPLY_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    MED_REPLY_READ_IN:       in  STD_LOGIC; -- Media is reading
    
    MED_REPLY_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered by the Media
                                      -- (the IOBUF MUST read)
    MED_REPLY_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    MED_REPLY_READ_OUT:      out STD_LOGIC; -- buffer reads a word from media
    MED_REPLY_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    
    -- Internal direction port

    INT_INIT_DATAREADY_OUT: out STD_LOGIC;
    INT_INIT_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_INIT_READ_IN:       in  STD_LOGIC; 

    INT_INIT_DATAREADY_IN:  in  STD_LOGIC;
    INT_INIT_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_INIT_READ_OUT:      out STD_LOGIC; 

    
    INT_REPLY_HEADER_IN:     in  STD_LOGIC; -- Concentrator kindly asks to resend the last
                                      -- header (only for the reply path)
    INT_REPLY_DATAREADY_OUT: out STD_LOGIC;
    INT_REPLY_DATA_OUT:      out STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_REPLY_READ_IN:       in  STD_LOGIC; 

    INT_REPLY_DATAREADY_IN:  in  STD_LOGIC;
    INT_REPLY_DATA_IN:       in  STD_LOGIC_VECTOR (50 downto 0); -- Data word
    INT_REPLY_READ_OUT:      out STD_LOGIC; 

    -- Status and control port
    STAT_GEN:          out STD_LOGIC_VECTOR (31 downto 0); -- General Status
    STAT_LOCKED:       out STD_LOGIC_VECTOR (31 downto 0); -- Status of the handshake and buffer control
    STAT_INIT_BUFFER:  out STD_LOGIC_VECTOR (31 downto 0); -- Status of the handshake and buffer control
    STAT_REPLY_BUFFER: out STD_LOGIC_VECTOR (31 downto 0); -- General Status
    CTRL_GEN:          in  STD_LOGIC_VECTOR (31 downto 0); 
    CTRL_LOCKED:       in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_INIT_BUFFER:  in  STD_LOGIC_VECTOR (31 downto 0); 
    STAT_CTRL_REPLY_BUFFER: in  STD_LOGIC_VECTOR (31 downto 0)  
    );
END trb_net_iobuf;

architecture trb_net_iobuf_arch of trb_net_iobuf is

  component trb_net_ibuf is

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
  END component;

  component trb_net_term_ibuf is

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
  END component;
  
  component trb_net_obuf is
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
  END component;

  -- internal signals for the INITIBUF
  signal  INITIBUF_error:    STD_LOGIC_VECTOR (2 downto 0);  -- error watch needed!
  signal  INITIBUF_stat_locked, INITIBUF_ctrl_locked: STD_LOGIC_VECTOR (15 downto 0);
  signal  INITIBUF_stat_buffer  :  STD_LOGIC_VECTOR (31 downto 0);

  -- internal signals for the REPLYIBUF
  signal  REPLYIBUF_error:    STD_LOGIC_VECTOR (2 downto 0); -- error watch needed!
  signal  REPLYIBUF_stat_locked, REPLYIBUF_ctrl_locked: STD_LOGIC_VECTOR (15 downto 0);
  signal  REPLYIBUF_stat_buffer  :  STD_LOGIC_VECTOR (31 downto 0);

  -- internal signals for the INITOBUF
  signal  INITOBUF_stat_locked, INITOBUF_ctrl_locked: STD_LOGIC_VECTOR (15 downto 0);
  signal  INITOBUF_stat_buffer, INITOBUF_ctrl_buffer:  STD_LOGIC_VECTOR (31 downto 0);

  -- internal signals for the REPLYOBUF
  signal  REPLYOBUF_stat_locked, REPLYOBUF_ctrl_locked: STD_LOGIC_VECTOR (15 downto 0);
  signal  REPLYOBUF_stat_buffer, REPLYOBUF_ctrl_buffer:  STD_LOGIC_VECTOR (31 downto 0);

-- locking control
  signal  INIT_IS_LOCKED,  REPLY_IS_LOCKED: STD_LOGIC;
  signal  next_INIT_IS_LOCKED,  next_REPLY_IS_LOCKED: STD_LOGIC;
  
  begin

    GEN_IBUF: if INIT_DEPTH>0 generate
    
    INITIBUF : trb_net_ibuf
      generic map (
        DEPTH => INIT_DEPTH)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        MED_DATAREADY_IN => MED_INIT_DATAREADY_IN,
        MED_DATA_IN => MED_INIT_DATA_IN,
        MED_READ_OUT => MED_INIT_READ_OUT,
        MED_ERROR_IN => MED_INIT_ERROR_IN,
        INT_HEADER_IN => '0',
        INT_DATAREADY_OUT => INT_INIT_DATAREADY_OUT,
        INT_DATA_OUT => INT_INIT_DATA_OUT,
        INT_READ_IN => INT_INIT_READ_IN,
        INT_ERROR_OUT => INITIBUF_error,
        STAT_LOCKED(15 downto 0) => INITIBUF_stat_locked,
        CTRL_LOCKED(15 downto 0) => INITIBUF_ctrl_locked,
        STAT_BUFFER(31 downto 0) => INITIBUF_stat_buffer
        );

    REPLYIBUF : trb_net_ibuf
      generic map (
        DEPTH => REPLY_DEPTH)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        MED_DATAREADY_IN => MED_REPLY_DATAREADY_IN,
        MED_DATA_IN => MED_REPLY_DATA_IN,
        MED_READ_OUT => MED_REPLY_READ_OUT,
        MED_ERROR_IN => MED_REPLY_ERROR_IN,
        INT_HEADER_IN => INT_REPLY_HEADER_IN,
        INT_DATAREADY_OUT => INT_REPLY_DATAREADY_OUT,
        INT_DATA_OUT => INT_REPLY_DATA_OUT,
        INT_READ_IN => INT_REPLY_READ_IN,
        INT_ERROR_OUT => REPLYIBUF_error,
        STAT_LOCKED(15 downto 0) => REPLYIBUF_stat_locked,
        CTRL_LOCKED(15 downto 0) => REPLYIBUF_ctrl_locked,
        STAT_BUFFER(31 downto 0) => REPLYIBUF_stat_buffer
        );

    end generate;

    GEN_TERM_IBUF: if INIT_DEPTH=0 generate
    
    INITIBUF : trb_net_term_ibuf
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        MED_DATAREADY_IN => MED_INIT_DATAREADY_IN,
        MED_DATA_IN => MED_INIT_DATA_IN,
        MED_READ_OUT => MED_INIT_READ_OUT,
        MED_ERROR_IN => MED_INIT_ERROR_IN,
        INT_HEADER_IN => '0',
        INT_DATAREADY_OUT => INT_INIT_DATAREADY_OUT,
        INT_DATA_OUT => INT_INIT_DATA_OUT,
        INT_READ_IN => INT_INIT_READ_IN,
        INT_ERROR_OUT => INITIBUF_error,
        STAT_LOCKED(15 downto 0) => INITIBUF_stat_locked,
        CTRL_LOCKED(15 downto 0) => INITIBUF_ctrl_locked,
        STAT_BUFFER(31 downto 0) => INITIBUF_stat_buffer
        );

    REPLYIBUF : trb_net_term_ibuf
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        MED_DATAREADY_IN => MED_REPLY_DATAREADY_IN,
        MED_DATA_IN => MED_REPLY_DATA_IN,
        MED_READ_OUT => MED_REPLY_READ_OUT,
        MED_ERROR_IN => MED_REPLY_ERROR_IN,
        INT_HEADER_IN => INT_REPLY_HEADER_IN,
        INT_DATAREADY_OUT => INT_REPLY_DATAREADY_OUT,
        INT_DATA_OUT => INT_REPLY_DATA_OUT,
        INT_READ_IN => INT_REPLY_READ_IN,
        INT_ERROR_OUT => REPLYIBUF_error,
        STAT_LOCKED(15 downto 0) => REPLYIBUF_stat_locked,
        CTRL_LOCKED(15 downto 0) => REPLYIBUF_ctrl_locked,
        STAT_BUFFER(31 downto 0) => REPLYIBUF_stat_buffer
        );

    end generate;
    
    INITOBUF : trb_net_obuf
      generic map (
        DATA_COUNT_WIDTH => 16,
        SWITCH_OFF_BUFFER_CHECK => SWITCH_OFF_BUFFER_CHECK
                      --switching off erroneous output buffer counter. MUST ONLY be 
                      --used for short transfers!!!!
        )
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        MED_DATAREADY_OUT => MED_INIT_DATAREADY_OUT,
        MED_DATA_OUT => MED_INIT_DATA_OUT,
        MED_READ_IN => MED_INIT_READ_IN,
        INT_DATAREADY_IN => INT_INIT_DATAREADY_IN,
        INT_DATA_IN => INT_INIT_DATA_IN,
        INT_READ_OUT => INT_INIT_READ_OUT,
        STAT_LOCKED(15 downto 0) => INITOBUF_stat_locked,
        CTRL_LOCKED(15 downto 0) => INITOBUF_ctrl_locked,
        STAT_BUFFER(31 downto 0) => INITOBUF_stat_buffer,
        CTRL_BUFFER(31 downto 0) => INITOBUF_ctrl_buffer
        );

    REPLYOBUF : trb_net_obuf
      generic map (
        DATA_COUNT_WIDTH => 16,
        SWITCH_OFF_BUFFER_CHECK => SWITCH_OFF_BUFFER_CHECK
                      --switching off erroneous output buffer counter. MUST ONLY be 
                      --used for short transfers!!!!
      )
      port map (
        CLK       => CLK,
        RESET     => RESET,
        CLK_EN    => CLK_EN,
        MED_DATAREADY_OUT => MED_REPLY_DATAREADY_OUT,
        MED_DATA_OUT => MED_REPLY_DATA_OUT,
        MED_READ_IN => MED_REPLY_READ_IN,
        INT_DATAREADY_IN => INT_REPLY_DATAREADY_IN,
        INT_DATA_IN => INT_REPLY_DATA_IN,
        INT_READ_OUT => INT_REPLY_READ_OUT,
        STAT_LOCKED(15 downto 0) => REPLYOBUF_stat_locked,
        CTRL_LOCKED(15 downto 0) => REPLYOBUF_ctrl_locked,
        STAT_BUFFER(31 downto 0) => REPLYOBUF_stat_buffer,
        CTRL_BUFFER(31 downto 0) => REPLYOBUF_ctrl_buffer
        );

-- build the registers according to the wiki page
    STAT_INIT_BUFFER(11 downto 0) <= INITIBUF_stat_buffer(11 downto 0);
    STAT_INIT_BUFFER(15 downto 14) <= INITOBUF_stat_buffer(1 downto 0);
    STAT_INIT_BUFFER(31 downto 16) <= INITOBUF_stat_buffer(31 downto 16);
    STAT_REPLY_BUFFER(11 downto 0) <= REPLYIBUF_stat_buffer(11 downto 0);
    STAT_REPLY_BUFFER(15 downto 14) <= REPLYOBUF_stat_buffer(1 downto 0);
    STAT_REPLY_BUFFER(31 downto 16) <= REPLYOBUF_stat_buffer(31 downto 16);

-- build the CTRL register of the OBUFs
    INITOBUF_ctrl_buffer(9 downto 0) <= INITIBUF_stat_buffer(9 downto 0);
    INITOBUF_ctrl_buffer(31 downto 10) <= (others => '0');
    REPLYOBUF_ctrl_buffer(9 downto 0) <= REPLYIBUF_stat_buffer(9 downto 0);
    REPLYOBUF_ctrl_buffer(31 downto 10) <= (others => '0');

    STAT_LOCKED(0) <= INIT_IS_LOCKED;
    STAT_LOCKED(1) <= REPLY_IS_LOCKED;
    STAT_LOCKED(31 downto 2) <= (others => '0');

    REPLYOBUF_ctrl_locked(15 downto 2) <= (others => '0');
    REPLYIBUF_ctrl_locked(15 downto 2) <= (others => '0');
    INITOBUF_ctrl_locked(15 downto 2) <= (others => '0');
    INITIBUF_ctrl_locked(15 downto 2) <= (others => '0');
    
    -- comb part of the locking control
comb_locked : process (INIT_IS_LOCKED, REPLY_IS_LOCKED, INITIBUF_stat_locked,
                       REPLYOBUF_stat_locked, REPLYIBUF_stat_locked,
                       INITOBUF_stat_locked,  CTRL_LOCKED)
    
  begin  -- process
    next_INIT_IS_LOCKED <= INIT_IS_LOCKED;
    next_REPLY_IS_LOCKED <= REPLY_IS_LOCKED;
    REPLYOBUF_ctrl_locked(1 downto 0) <= (others => '0');
    REPLYIBUF_ctrl_locked(1 downto 0) <= (others => '0');
    INITOBUF_ctrl_locked(1 downto 0) <= (others => '0');
    INITIBUF_ctrl_locked(1 downto 0) <= (others => '0');

    if REPLY_IS_LOCKED = '1' then
      -- listen to INITOBUF
      if INITOBUF_stat_locked(0) = '1' or CTRL_LOCKED(1) = '1' then
        next_REPLY_IS_LOCKED <= '0';
        REPLYIBUF_ctrl_locked(0) <= '1';
      else
        next_REPLY_IS_LOCKED <= '1';
      end if;
    else
      -- listen to REPLYIBUF itself
      if REPLYIBUF_stat_locked(0) = '1' then
        next_REPLY_IS_LOCKED <= '1';
        INITOBUF_ctrl_locked(0) <= '1';        
      else
        next_REPLY_IS_LOCKED <= '0';
      end if;
    end if;   
    
    if INIT_IS_LOCKED = '1' then
      -- listen to REPLYOBUF
      if REPLYOBUF_stat_locked(0) = '1' or CTRL_LOCKED(0) = '1' then
        next_INIT_IS_LOCKED <= '0';
        INITIBUF_ctrl_locked(0) <= '1';
      else
        next_INIT_IS_LOCKED <= '1';
      end if;
    else
      -- listen to INITIBUF itself
      if INITIBUF_stat_locked(0) = '1' then
        next_INIT_IS_LOCKED <= '1';
        REPLYOBUF_ctrl_locked(0) <= '1';        
      else
        next_INIT_IS_LOCKED <= '0';

      end if;
    end if;  

  end process;

    reg_locked: process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        INIT_IS_LOCKED <= '0';
        REPLY_IS_LOCKED <= '1';
      elsif CLK_EN = '1' then
        INIT_IS_LOCKED <= next_INIT_IS_LOCKED;
        REPLY_IS_LOCKED <= next_REPLY_IS_LOCKED;
      else
        INIT_IS_LOCKED <= INIT_IS_LOCKED;
        REPLY_IS_LOCKED <= REPLY_IS_LOCKED;
      end if;
    end if;
  end process;



  
end trb_net_iobuf_arch;
  
