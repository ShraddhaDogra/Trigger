library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
library work;
  use work.trb_net_components.all;
  use work.trb_net_std.all;
  use work.trb3_components.all;
  use work.config.all;

entity clock_reset_handler is
  port (
    INT_CLK_IN      : in  std_logic;  -- oscillator
    EXT_CLK_IN      : in  std_logic;  -- external clock input
    NET_CLK_FULL_IN : in  std_logic;  -- recovered clock
    NET_CLK_HALF_IN : in  std_logic;
    RESET_FROM_NET  : in  std_logic := '0';
    SEND_RESET_IN   : in  std_logic := '0';
    
    BUS_RX          : in  CTRLBUS_RX;
    BUS_TX          : out CTRLBUS_TX;

    RESET_OUT       : out std_logic;
    CLEAR_OUT       : out std_logic;
    GSR_OUT         : out std_logic;
    
    FULL_CLK_OUT    : out std_logic;  -- 200/240 MHz for FPGA fabric
    SYS_CLK_OUT     : out std_logic;  -- 100/120 MHz for FPGA fabric
    REF_CLK_OUT     : out std_logic;  -- 200/240 internal reference clock
    
    ENPIRION_CLOCK  : out std_logic;
    LED_RED_OUT     : out std_logic_vector( 1 downto 0);
    LED_GREEN_OUT   : out std_logic_vector( 1 downto 0);
    DEBUG_OUT       : out std_logic_vector(31 downto 0)
    );
end entity;

architecture clock_reset_handler_arch of clock_reset_handler is

attribute syn_keep     : boolean;
attribute syn_preserve : boolean;

signal clk_int_full, clk_int_half : std_logic;
signal clk_ext_full, clk_ext_half : std_logic;
signal clk_selected_full, clk_selected_half, clk_selected_ref : std_logic;

signal pll_int_lock, pll_ext_lock : std_logic;
signal wait_for_lock : std_logic := '1';
signal clock_select  : std_logic := '0';

signal timer   : unsigned(27 downto 0) := (others => '0');
signal clear_n_i : std_logic := '0';
signal reset_i   : std_logic;
signal debug_reset_handler : std_logic_vector(15 downto 0);
signal send_reset_detect, trb_reset_i : std_logic := '0';

attribute syn_keep of clear_n_i     : signal is true;
attribute syn_preserve of clear_n_i : signal is true;

begin

assert not (USE_RXCLOCK = c_YES and USE_200MHZOSCILLATOR = c_YES)     report "RX Clock and 200 MHz oscillator not implemented" severity error;
assert not (USE_120_MHZ = c_YES and USE_200MHZOSCILLATOR = c_YES)     report "120 MHz with 200 MHz oscillator not implemented" severity error;

SYS_CLK_OUT  <= clk_selected_half;
FULL_CLK_OUT <= clk_selected_full;
REF_CLK_OUT  <= clk_selected_ref;

LED_RED_OUT(0)   <= '0' when USE_RXCLOCK = c_YES else '1';
LED_GREEN_OUT(0) <= '0' when USE_RXCLOCK = c_NO  else '1';

LED_GREEN_OUT(1) <= '0';
LED_RED_OUT(1)   <= clock_select;

GSR_OUT     <= not pll_int_lock or clear_n_i;

---------------------------------------------------------------------------
-- if RX clock is used, just forward what is provided, adjust internal as reference
---------------------------------------------------------------------------
gen_recov_clock : if USE_RXCLOCK = c_YES generate
  clk_selected_full <= NET_CLK_FULL_IN;
  clk_selected_half <= NET_CLK_HALF_IN;
  
  timer <= (others => '1');
  
  gen_200rec : if USE_120_MHZ = c_NO generate
    THE_INT_PLL : entity work.pll_in240_out200
      port map(
        CLK    => INT_CLK_IN,
        CLKOP  => clk_int_full,
        CLKOK  => clk_int_half,
        LOCK   => pll_int_lock
        );  
    clk_selected_ref <= clk_int_full;    
  end generate;
  
  gen_240rec : if USE_120_MHZ = c_YES generate
    clk_selected_ref <= INT_CLK_IN;
    pll_int_lock <= '1';
  end generate;  
end generate;


---------------------------------------------------------------------------
-- No recovered clock
---------------------------------------------------------------------------
gen_norecov_clock : if USE_RXCLOCK = c_NO generate

  clk_selected_ref <= clk_selected_full; --clk_int_full; --
  
  ---------------------------------------------------------------------------
  -- Make internal clock 200 MHz if required
  ---------------------------------------------------------------------------
  gen_200 : if USE_120_MHZ = c_NO generate
    gen_osc240 : if USE_200MHZOSCILLATOR = c_NO generate
      THE_INT_PLL : entity work.pll_in240_out200
        port map(
          CLK    => INT_CLK_IN,
          CLKOP  => open,         --200
          CLKOS  => clk_int_full, --same as OP, but for DCS
          CLKOK  => clk_int_half, --100
          LOCK   => pll_int_lock
          );
    end generate;      
    gen_osc200 : if USE_200MHZOSCILLATOR = c_YES generate
      THE_INT_PLL : entity work.pll_in200_out200
        port map(
          CLK    => INT_CLK_IN,
          CLKOP  => open,         --200
          CLKOS  => clk_int_full, --same as OP, but for DCS
          CLKOK  => clk_int_half, --100
          LOCK   => pll_int_lock
          );
    end generate;
    
    gen_ext_pll : if USE_EXTERNAL_CLOCK = c_YES generate        
      THE_EXT_PLL : entity work.pll_in200_out100
        port map(
          CLK    => EXT_CLK_IN,
          RESET  => '0',
          CLKOP  => open,         --100
          CLKOS  => clk_ext_half, --same as OP, but for DCS
          CLKOK  => clk_ext_full, --200, bypassed
          LOCK   => pll_ext_lock
          );        
    end generate;      
  end generate;

  gen_240 : if USE_120_MHZ = c_YES generate
    THE_INT_PLL : entity work.pll_in240_out240
      port map(
        CLK    => INT_CLK_IN,
        CLKOP  => clk_int_half,
        CLKOK  => clk_int_full,
        LOCK   => pll_int_lock
        );

    gen_ext_pll : if USE_EXTERNAL_CLOCK = c_YES generate        
      THE_EXT_PLL : entity work.pll_in240_out240
        port map(
          CLK    => EXT_CLK_IN,
          CLKOP  => clk_ext_half,
          CLKOK  => clk_ext_full,
          LOCK   => pll_ext_lock
          );        
    end generate;      
  end generate;


  ---------------------------------------------------------------------------
  -- Select clocks
  ---------------------------------------------------------------------------  
  gen_switch_clock : if USE_EXTERNAL_CLOCK = c_YES generate
    THE_CLOCK_SWITCH_FULL: DCS
      port map(
        SEL    => clock_select,
        CLK0   => clk_int_full,
        CLK1   => clk_ext_full,
        DCSOUT => clk_selected_full
        );
    THE_CLOCK_SWITCH_HALF: DCS
      port map(
        SEL    => clock_select,
        CLK0   => clk_int_half,
        CLK1   => clk_ext_half,
        DCSOUT => clk_selected_half
        );
  end generate;
  gen_direct_clock : if USE_EXTERNAL_CLOCK = c_NO generate
    clk_selected_half <= clk_int_half;
    clk_selected_full <= clk_int_full;
  end generate;
      
      
  ---------------------------------------------------------------------------
  -- Clock switch logic
  ---------------------------------------------------------------------------          
  
  process begin
    wait until rising_edge(INT_CLK_IN);
    if timer(26-CLOCK_FAST_SELECT*11) = '0' and timer(27-CLOCK_FAST_SELECT*11) = '0' then
      clock_select <= '0';
    end if;
    if timer(26-CLOCK_FAST_SELECT*11) = '1' and timer(25-CLOCK_FAST_SELECT*11 downto 0) = 0 then  --after 135us or 8.8ms
      clock_select <= pll_ext_lock; 
    end if;
    
    if timer(27-CLOCK_FAST_SELECT*11) = '1' then  --after 135us or 8.8ms plus 1
      timer <= timer;
    else  
      timer <= timer + 1;
    end if;
  end process;
  
  
end generate;

clear_n_i <= timer(27-CLOCK_FAST_SELECT*11) when rising_edge(INT_CLK_IN);

---------------------------------------------------------------------------
-- Reset generation
---------------------------------------------------------------------------
THE_RESET_HANDLER : trb_net_reset_handler
  generic map(
    RESET_DELAY     => x"FEEE"
    )
  port map(
    CLEAR_IN        => '0',             -- reset input (high active, async)
    CLEAR_N_IN      => clear_n_i,       -- reset input (low active, async)
    CLK_IN          => INT_CLK_IN,      -- raw master clock, NOT from PLL/DLL!
    SYSCLK_IN       => clk_selected_half, -- PLL/DLL remastered clock
    PLL_LOCKED_IN   => pll_int_lock,      -- master PLL lock signal (async)
    RESET_IN        => '0',             -- general reset signal (SYSCLK)
    TRB_RESET_IN    => trb_reset_i,  -- TRBnet reset signal (SYSCLK)
    CLEAR_OUT       => CLEAR_OUT,       -- async reset out, USE WITH CARE!
    RESET_OUT       => reset_i,       -- synchronous reset out (SYSCLK)
    DEBUG_OUT       => debug_reset_handler
  );  

RESET_OUT <= reset_i;
send_reset_detect <= SEND_RESET_IN when rising_edge(INT_CLK_IN);
trb_reset_i <= RESET_FROM_NET or (send_reset_detect and not SEND_RESET_IN);
  
---------------------------------------------------------------------------
-- Slow clock for DCDC converters
---------------------------------------------------------------------------  
  PLL_ENPIRION : entity work.pll_200_4
    port map(
      CLK   => clk_selected_ref,
      RESET => reset_i,
      CLKOP => ENPIRION_CLOCK,
      LOCK  => open
      );  
  

DEBUG_OUT(0)  <= pll_int_lock;
DEBUG_OUT(1)  <= clear_n_i;
DEBUG_OUT(13 downto 2) <= debug_reset_handler(13 downto 2);
DEBUG_OUT(14)  <= pll_ext_lock;
DEBUG_OUT(15)  <= clock_select;
DEBUG_OUT(31 downto 16) <= (others => '0');

BUS_TX.data <= (others => '0');
BUS_TX.unknown <= '1';
BUS_TX.ack <= '0';
BUS_TX.nack <= '0';

  

end architecture;
