-- this is an apl, connecting the old trigger bus to the new system
-------------------------------------------------------------------------------
-- Title         : trb_net_old_to_new
-- Project       : HADES trigger new net 
-------------------------------------------------------------------------------
-- File          : trb_net_old_to_new.vhd
-- Author        : Tiago Perez (tiago.perez@uni-giessen.de)
-- Created       : 2007/01/12
-- Last modified : 2007/02/26 T. Perez
-------------------------------------------------------------------------------
-- Description   : Interace between "old" and "new" trigger nets
--                      
-------------------------------------------------------------------------------
-- Modification history :
-- 2007/01/12 : created
--              L12TrigBusInterface is driven only with the main clock. This
--              used to be 40MHz in "OLD" DTU but now is around 10 times faster.
--              I am not sure how "sharp" are the edges of T and TS in the
--              trigger bus, but now, samplig at ca. 400MHz we may sample T and
--              TS sereval times while falling and still not set. We should
--              chek the quality and "sharpness" of the Triggerbus with a scope
--              and eventually downscale the main clock to sample slower.
-- 2007/02/26:  T. Perez (tiago.perez@uni-giessen.de)
--              Change FSM so that all outouts are registered. OUTPUTS are
--              decoded from the next_state to avoid losing CLK cycles. There
--              is an external counter to do the sendig procedure.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity trb_net_old_to_new is
  generic (TRIGGER_LEVEL : integer := 1);  -- either 1 or 2

  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    -- APL Transmitter port
    APL_DATA_OUT           : out std_logic_vector (47 downto 0);  -- Data word "application to network"
    APL_WRITE_OUT          : out std_logic;  -- Data word is valid and should be transmitted
    APL_FIFO_FULL_IN       : in  std_logic;  -- Stop transfer, the fifo is full
    APL_SHORT_TRANSFER_OUT : out std_logic;  -- 
    APL_DTYPE_OUT          : out std_logic_vector (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL_ERROR_PATTERN_OUT  : out std_logic_vector (31 downto 0);  -- see NewTriggerBusNetworkDescr
    APL_SEND_OUT           : out std_logic;  -- Release sending of the data
    APL_TARGET_ADDRESS_OUT : out std_logic_vector (15 downto 0);  -- Address of
                                        -- the target (only for active APIs)

    -- Receiver port
    APL_DATA_IN      : in  std_logic_vector (47 downto 0);  -- Data word "network to application"
    APL_TYP_IN       : in  std_logic_vector (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
    APL_DATAREADY_IN : in  std_logic;   -- Data word is valid and might be read out
    APL_READ_OUT     : out std_logic;   -- Read data word

    -- APL Control port
    APL_RUN_IN   : in std_logic;        -- Data transfer is running
    APL_SEQNR_IN : in std_logic_vector (7 downto 0);

    -- the OLD trigger bus
    OLD_T  : in std_logic;              --    trigger signal
    --  used to strobe the trigger code
    OLD_TS : in std_logic;              --    trigger strobe
--                                      used to strobe the trigger tag and further
--                                      trigger data nibbles (e.g. trigger priority)

    OLD_TD : in  std_logic_vector (3 downto 0);  --        trigger data lines
--                                                              transmit the trigger data nibbles
    OLD_TB : out std_logic;                      --   trigger busy
--                                      wired-or signal, that indicates busy state of one or more DTUs
    OLD_TE : out std_logic                       --   trigger error
--                                      wired-or signal, that indicates error state of one or more DTUs
--Ts0..1        trigger spare lines
--free for future purposes
--not connected because useless


    );
end trb_net_old_to_new;

architecture behavioral of trb_net_old_to_new is

  -- reconstruct the LVL1 or LVL2 trigger
  -- for LVL1: Ignore the BEGRUN and ENDRUN triggers
  -- (please use the generic to check if we have LVL1 or 2)

  -- compare to the SEQNR, do not forget the offset by one for LVL1
  -- if a tigger tag mismatch occures, raise the error line

  -- feel free to add debug registers

  -- COMPONENTS
  -- OLD TRIGGER INTERFACE
  component L12TrigBusInterface
    port (
      TSTR             : in  std_logic;
      DSTR             : in  std_logic;
      DIN              : in  std_logic_vector(3 downto 0);
      BSY              : out std_logic;
      ERR              : out std_logic;
      RES              : in  std_logic;
      CLK              : in  std_logic;
      DVAL             : out std_logic;
      TRIGTAG          : out std_logic_vector(7 downto 0);
      TRIGCODE         : out std_logic_vector(3 downto 0);
      TRIGTAG_MISMATCH : in  std_logic;
      BUSY             : in  std_logic);
  end component;

  -- SIGNALS
  signal TRIGTAG_i, TRIGTAG_ii : std_logic_vector(7 downto 0);
  signal TRIGCODE_i            : std_logic_vector(3 downto 0);
  signal DVAL_i                : std_logic;
  signal TRIGTAG_MISMATCH_reg  : std_logic;

  type State_Type is (idle, check_code, compare, send, error_1);
  signal present_state, next_state : State_Type;
  signal do_send_cnt               : unsigned(2 downto 0);


begin
  APL_DATA_OUT(7 downto 0)  <= TRIGTAG_ii;              
  -----------------------------------------------------------------------------
  -- FIX NON USED OUTPUTS
  -----------------------------------------------------------------------------
  APL_DATA_OUT(47 downto 8) <= (others => '0');
  APL_WRITE_OUT             <= '0';

  APL_SHORT_TRANSFER_OUT <= '1';        -- short transfer TRUE
  APL_ERROR_PATTERN_OUT  <= (others => '0');
  APL_TARGET_ADDRESS_OUT <= (others => '0');

  -----------------------------------------------------------------------------
  -- COMPONENTS
  -----------------------------------------------------------------------------
  BusInterfaceOld : L12TrigBusInterface
    port map (
      TSTR             => OLD_T,
      DSTR             => OLD_TS,
      DIN              => OLD_TD,
      BSY              => OLD_TB,
      ERR              => OLD_TE,
      RES              => RESET,
      CLK              => CLK,
      DVAL             => DVAL_i,
      TRIGTAG          => TRIGTAG_i,
      TRIGCODE         => TRIGCODE_i,
      TRIGTAG_MISMATCH => TRIGTAG_MISMATCH_reg,
      BUSY             => APL_RUN_IN);

  -----------------------------------------------------------------------------
  -- DIFF LVL1/LVL2
  -----------------------------------------------------------------------------
  -- filter BEGRUN out
  -- CHANGE: TRIGTAG=TRIGTAG-1
  GEN_L1 : if TRIGGER_LEVEL = 1 generate
    process (CLK, RESET, CLK_EN, TRIGTAG_i)
    begin  -- process S
      if RESET = '1' then
        TRIGTAG_ii <= (others => '0');
      elsif CLK'event and CLK = '1' and CLK_EN = '1' then
        TRIGTAG_ii <= TRIGTAG_i - 1;
      end if;
    end process;
  end generate GEN_L1;

  -- Register TRIGTAG
  GEN_L2 : if TRIGGER_LEVEL = 2 generate
    process (CLK, RESET, CLK_EN, TRIGTAG_i)
    begin  -- process S
      if RESET = '1' then
        TRIGTAG_ii <= (others => '0');
      elsif CLK'event and CLK = '1' and CLK_EN = '1' then
        TRIGTAG_ii <= TRIGTAG_i;
      end if;
    end process;
  end generate GEN_L2;

  -----------------------------------------------------------------------------
  -- FSM
  -----------------------------------------------------------------------------
  -- purpose: Register the STATE of the FSM
  -- type   : Sequential
  -- inputs : CLK, RESET, next_state
  -- output : next_state
  state_clocked : process (CLK, RESET, CLK_EN)
  begin  -- process state_clocked
    if RESET = '1' then                 -- asynchronous reset (active high)
      present_state <= idle;
    elsif CLK'event and CLK = '1' and CLK_EN = '1' then  -- rising clock edge
      present_state <= next_state;
    end if;
  end process state_clocked;

  -- purpose: Calculates the next_state of the FSM. 
  -- type   : combinational
  -- inputs : present_state, DVAL_i, TRIGTAG_ii, APL_SEQNR_IN, APL_RUN_IN
  -- outputs: next_state
  FSM : process (present_state, DVAL_i, TRIGTAG_ii, APL_SEQNR_IN, TRIGCODE_i, do_send_cnt)
  begin  -- process FSM
    next_state       <= present_state;
    case present_state is
      when idle       =>
        if DVAL_i = '1' then
          next_state <= check_code;
        end if;
      when check_code =>
        -- Check for BEGIN_RUN 
        if TRIGCODE_i = x"d" then
          next_state <= idle;
        else
          next_state <= compare;
        end if;
      when compare    =>
        if TRIGTAG_ii = APL_SEQNR_IN then
          next_state <= send;
        else
          next_state <= error_1;
        end if;
      when send       =>
       if do_send_cnt = 5 then
       --if APL_RUN_IN = '1' then
          next_state <= idle;
        end if;
      when others     => null;
    end case;
  end process FSM;

  -- purpose: decode and register the output signals of FSM
  -- type   : sequentia
  -- inputs : next_state
  -- outputs: TRIGTAG
  decode_output : process (CLK, RESET, CLK_EN, next_state, do_send_cnt)
  begin  -- process decode_output
    if RESET = '1' then
      TRIGTAG_MISMATCH_reg <= '0';
      APL_SEND_OUT         <= '0';
      APL_READ_OUT         <= '0';

      APL_DTYPE_OUT        <= (others => '0');
    elsif CLK'event and CLK = '1' and CLK_EN = '1' then
      TRIGTAG_MISMATCH_reg <= '0';
      APL_SEND_OUT         <= '0';
      APL_READ_OUT         <= '0';

      APL_DTYPE_OUT        <= (others => '0');

      case next_state is
        when idle =>
          --when check_code =>

        when compare =>
          APL_DTYPE_OUT <= TRIGCODE_i;

        when send    =>
          APL_DTYPE_OUT        <= TRIGCODE_i;
          if do_send_cnt = 1 then
            APL_SEND_OUT       <= '1';
          end if;       
          if (do_send_cnt = 3) or (do_send_cnt = 4) then
            APL_READ_OUT       <= '1';
          end if;
        when error_1 =>
          TRIGTAG_MISMATCH_reg <= '1';
        when others  => null;
      end case;
    end if;
  end process decode_output;

  send_counter : process (CLK, RESET, present_state)
  begin  -- process send
    if RESET = '1' or present_state = idle then  -- asynchronous reset (active low)
      do_send_cnt <= (others => '0');
    elsif CLK'event and CLK = '1' and present_state = send then  -- rising clock edge
      do_send_cnt <= do_send_cnt+1;
    end if;
  end process send_counter;

end behavioral;

