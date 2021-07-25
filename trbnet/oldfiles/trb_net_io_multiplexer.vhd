-- for a description see HADES wiki
-- http://hades-wiki.gsi.de/cgi-bin/view/DaqSlowControl/TrbNetIBUF

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;


entity trb_net_io_multiplexer is

--  generic (BUS_WIDTH : integer := 56;
--           MULT_WIDTH : integer := 5);
  generic (BUS_WIDTH : integer := 16;
           MULT_WIDTH : integer := 1);
  
  port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_IN:  in  STD_LOGIC; 
    MED_DATA_IN:       in  STD_LOGIC_VECTOR (BUS_WIDTH-1 downto 0);
                       -- highest bits are mult.
    MED_READ_OUT:      out STD_LOGIC;
    
    MED_DATAREADY_OUT: out  STD_LOGIC; 
    MED_DATA_OUT:      out  STD_LOGIC_VECTOR (BUS_WIDTH-1 downto 0);  
    MED_READ_IN:       in STD_LOGIC;
    
    -- Internal direction port
    INT_DATAREADY_OUT: out STD_LOGIC_VECTOR (2**MULT_WIDTH-1 downto 0);
    INT_DATA_OUT:      out STD_LOGIC_VECTOR ((BUS_WIDTH-MULT_WIDTH)*(2**MULT_WIDTH)-1 downto 0);  
    INT_READ_IN:       in  STD_LOGIC_VECTOR (2**MULT_WIDTH-1 downto 0);

    INT_DATAREADY_IN:  in STD_LOGIC_VECTOR (2**MULT_WIDTH-1 downto 0);
    INT_DATA_IN:       in STD_LOGIC_VECTOR ((BUS_WIDTH-MULT_WIDTH)*(2**MULT_WIDTH)-1 downto 0);  
    INT_READ_OUT:      out  STD_LOGIC_VECTOR (2**MULT_WIDTH-1 downto 0);
    
    -- Status and control port
    CTRL:              in  STD_LOGIC_VECTOR (31 downto 0);
    STAT:              out STD_LOGIC_VECTOR (31 downto 0)
    );
end trb_net_io_multiplexer;

architecture trb_net_io_multiplexer_arch of trb_net_io_multiplexer is

  component trb_net_pattern_gen is

  generic (MULT_WIDTH : integer := 3);     

  port(
    INPUT_IN  : in  STD_LOGIC_VECTOR (MULT_WIDTH-1 downto 0);
    RESULT_OUT: out STD_LOGIC_VECTOR (2**MULT_WIDTH-1 downto 0)
    );
  end component;

  component trb_net16_sbuf is
    generic (
      DATA_WIDTH : integer := 16;
      NUM_WIDTH  :  integer := 2;
      VERSION    : integer := 0
      );
    port(
      --  Misc
      CLK               : in std_logic;
      RESET             : in std_logic;
      CLK_EN            : in std_logic;
      --  port to combinatorial logic
      COMB_DATAREADY_IN : in  STD_LOGIC;  --comb logic provides data word
      COMB_next_READ_OUT: out STD_LOGIC;  --sbuf can read in NEXT cycle
      COMB_READ_IN      : in  STD_LOGIC;  --comb logic IS reading
      COMB_DATA_IN      : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
      COMB_PACKET_NUM_IN: in  STD_LOGIC_VECTOR(NUM_WIDTH-1 downto 0);
      -- Port to synchronous output.
      SYN_DATAREADY_OUT : out STD_LOGIC;
      SYN_DATA_OUT      : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
      SYN_PACKET_NUM_OUT: out STD_LOGIC_VECTOR(NUM_WIDTH-1 downto 0);
      SYN_READ_IN       : in  STD_LOGIC;
      -- Status and control port
      STAT_BUFFER       : out STD_LOGIC
      );
  end component;

  component trb_net_priority_arbiter is

  generic (WIDTH : integer := 16);     

  port(    
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;
    
    INPUT_IN  : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    RESULT_OUT: out STD_LOGIC_VECTOR (WIDTH-1 downto 0);

    ENABLE : in std_logic;  
    CTRL:  in  STD_LOGIC_VECTOR (31 downto 0)
    );
  end component;
  
  signal demux_next_READ, current_demux_READ : STD_LOGIC_VECTOR ((2**MULT_WIDTH)-1 downto 0);
  signal next_demux_dr, next_demux_dr_tmp: STD_LOGIC_VECTOR ((2**MULT_WIDTH)-1 downto 0);
--  signal demux_read: STD_LOGIC;         -- buffer is read out and killed
  signal current_MED_READ_OUT, next_MED_READ_OUT: STD_LOGIC; 
--  signal sbuf_stat: STD_LOGIC_VECTOR (2*(2**MULT_WIDTH)-1 downto 0);
  
  signal tmp_INT_READ_OUT: STD_LOGIC_VECTOR ((2**MULT_WIDTH)-1 downto 0);
  signal tmp_tmp_INT_READ_OUT: STD_LOGIC_VECTOR ((2**MULT_WIDTH)-1 downto 0);
  signal mux_read, mux_enable, mux_next_READ: STD_LOGIC;       
  signal current_mux_buffer: STD_LOGIC_VECTOR (BUS_WIDTH-1 downto 0);

  
  
  begin


-------------------------------------------------------------------------------
-- DEMUX
------------------------------------------------------------------------------
    -- the simpler part is the demux

    G1: for i in  0 to 2**MULT_WIDTH-1 generate
      DEMUX_SBUF: trb_net16_sbuf
        generic map (DATA_WIDTH => BUS_WIDTH-MULT_WIDTH, VERSION => 0)
        port map (
          CLK   => CLK,
          RESET  => RESET,
          CLK_EN => CLK_EN,
          COMB_DATAREADY_IN => next_demux_dr(i),
          COMB_next_READ_OUT => demux_next_READ(i),
          COMB_READ_IN => current_demux_READ(i),
          COMB_DATA_IN => MED_DATA_IN (BUS_WIDTH-MULT_WIDTH-1 downto 0),
          SYN_DATAREADY_OUT => INT_DATAREADY_OUT(i),
          SYN_DATA_OUT => INT_DATA_OUT ((BUS_WIDTH-MULT_WIDTH)*(i+1)-1 downto (BUS_WIDTH-MULT_WIDTH)*(i)),
          SYN_READ_IN => INT_READ_IN(i)
          );
    end generate;

    STAT(2 downto 0) <= MED_DATA_IN(50 downto 48);

    MED_READ_OUT <= current_MED_READ_OUT;
    
    comb_demux : process (next_demux_dr_tmp, demux_next_READ, INT_READ_IN,
                          MED_DATAREADY_IN, current_MED_READ_OUT)
    begin  -- process
      next_demux_dr <= (others => '0');
      current_demux_READ <= (others => '0');
      -- generate the READ_OUT
      next_MED_READ_OUT <= and_all(demux_next_READ or INT_READ_IN);
      -- (follow instruction on sbuf)
      
      current_demux_READ <= (others => '0');
      if current_MED_READ_OUT = '1' then
        current_demux_READ <= (others => '1');
      end if;
      if current_MED_READ_OUT = '1' and MED_DATAREADY_IN = '1'  then
        next_demux_dr <= next_demux_dr_tmp;  --enable DR on the sbufs
      end if;
    end process;
    
-- define next DRx
    DEFDR: trb_net_pattern_gen
      generic map (MULT_WIDTH => MULT_WIDTH)     
      port map (
        INPUT_IN =>  MED_DATA_IN(BUS_WIDTH-1 downto (BUS_WIDTH-MULT_WIDTH)),
        RESULT_OUT => next_demux_dr_tmp  -- this will have a 1 in ANY case
    );  
    
    sync_demux : process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        current_MED_READ_OUT <= '0';
      elsif CLK_EN = '1' then
        current_MED_READ_OUT <= next_MED_READ_OUT;
      else
        current_MED_READ_OUT <= current_MED_READ_OUT;
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- MUX part with arbitration scheme
-------------------------------------------------------------------------------    
ARBITER: trb_net_priority_arbiter 
  generic map (WIDTH => 2**MULT_WIDTH)
  port map (    
    CLK   => CLK,
    RESET  => RESET,
    CLK_EN  => CLK_EN,
    INPUT_IN  => INT_DATAREADY_IN,
    RESULT_OUT => tmp_INT_READ_OUT,
    ENABLE  => mux_enable,              
    CTRL => CTRL
    );

--   process (tmp_tmp_INT_READ_OUT, mux_enable)
--     begin
--       if mux_enable = '1' then
--         tmp_INT_READ_OUT <= tmp_tmp_INT_READ_OUT;
--       else
--         tmp_INT_READ_OUT <= (others => '0');
--       end if;
--     end process;

--                   <= so I have to gate it once more
INT_READ_OUT <=  tmp_INT_READ_OUT;


  
  MUX_SBUF: trb_net_sbuf
    generic map (DATA_WIDTH => BUS_WIDTH, VERSION => 0)
    port map (
      CLK   => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      COMB_DATAREADY_IN => mux_read,
      COMB_next_READ_OUT => mux_next_READ,
      COMB_READ_IN => '1',
      COMB_DATA_IN => current_mux_buffer,
      SYN_DATAREADY_OUT => MED_DATAREADY_OUT,
      SYN_DATA_OUT => MED_DATA_OUT,
      SYN_READ_IN => MED_READ_IN
      );

process (tmp_INT_READ_OUT, INT_DATA_IN)
  begin
    current_mux_buffer <=  (others => '0');
    for i in 0 to 2**MULT_WIDTH-1 loop
      if tmp_INT_READ_OUT(i) = '1' then
        current_mux_buffer(BUS_WIDTH-MULT_WIDTH-1 downto 0)
          <=  INT_DATA_IN((BUS_WIDTH-MULT_WIDTH)*(i+1)-1 downto (BUS_WIDTH-MULT_WIDTH)*(i));
        current_mux_buffer(BUS_WIDTH-1 downto BUS_WIDTH-MULT_WIDTH) <= conv_std_logic_vector(i, MULT_WIDTH);
      end if;
    end loop;
  end process;
  
  mux_enable <= (mux_next_READ); -- or MED_READ_IN
  mux_read <= or_all(tmp_INT_READ_OUT and INT_DATAREADY_IN);
  
end trb_net_io_multiplexer_arch;
  
