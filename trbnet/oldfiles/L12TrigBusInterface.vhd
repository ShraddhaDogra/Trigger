-------------------------------------------------------------------------------
-- Title         : Detector Trigger Unit 
-- Project       : HADES Second Level Trigger
-------------------------------------------------------------------------------
-- File          : L12TrugBusInterface.vhd
-- Author        : Markus Petri, Daniel Schaefer
-- Created       : 2002/03/27
-- Last modified : 2007/01/12 T. Perez
-------------------------------------------------------------------------------
-- Description   : Generic Interace for the Trigger Bus
--    
-------------------------------------------------------------------------------
-- Modification history :
-- 2002/03/27 : created
-- 2002/05/31 : corrected TrigBus sequence, implemented BSY;
-- 2007/01/12 : change in libraries to adapt to trbnet: numeric -> arith
--              CLK_10 removed. Now DTU code is much faster than TRIGGERBUS.
-- 2007/02/23 : DVAL is not being produced. ???
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity L12TrigBusInterface is
  port (
-- from Trigger bus
    TSTR             : in  std_logic;   -- trigger strobe 
    DSTR             : in  std_logic;   -- data strobe
    DIN              : in  std_logic_vector(3 downto 0);
-- to Trigger bus
    BSY              : out std_logic;
    ERR              : out std_logic;
-- general
    RES              : in  std_logic;
    CLK              : in  std_logic;   -- should be 40 MHz!!
--    CLK_10      : in  std_logic;      -- should be 10 MHz
-- to state engine (and others)
    DVAL             : out std_logic;   -- high for 2 clk cycles when TRIGTAG
                                        -- and TRIGCODE have been received
    TRIGTAG          : out std_logic_vector(7 downto 0);
    TRIGCODE         : out std_logic_vector(3 downto 0);
-- from state engine
    TRIGTAG_MISMATCH : in  std_logic;   -- this is high whenever the received
                                        -- TRIGTAG is not equal to the DTU's
                                        -- internal counter and is not starting
                                        -- with a 0 at begin
    BUSY             : in  std_logic    -- this should be controlled by the
                                        -- state engine and is passed directly
                                        -- to the trigger bus (where it is wired-
                                        -- or with all the other busy's from
                                        -- the DTU's, CTU)
    );
end L12TrigBusInterface;

architecture ARCH_L12TrigInterface of L12TrigBusInterface is
-------------------------------------------------------------------------------
  type ShiftReg is array (0 to 2) of
    std_logic_vector(3 downto 0);
-------------------------------------------------------------------------------
  signal NIBCNT                 : integer range 0 to 3;  -- # of current nibble
  signal TRIGBUFF               : ShiftReg;
  signal TSTR_REG, TSTR_REG_REG : std_logic;
  signal DSTR_REG, DSTR_REG_REG : std_logic;
-- signal DVAL_REG, DVAL_REG_LONG, DVAL_sync : std_logic;
  signal DVAL_REG, DVAL_REG_REG               : std_logic;
  signal DIN_REG                : std_logic_vector(3 downto 0);
-- signal counter_for_DVAL : integer range 0 to 3;

  signal TRIGCODE_i        : std_logic_vector(3 downto 0);
  signal BUSY_FAST, BUSY_i : std_logic;
-------------------------------------------------------------------------------

begin

  -- first we register all our inputs

  reg_DIN : process (CLK, RES)
  begin  -- process reg_DIN
    if RES = '1' then                   -- asynchronous reset (active high)
      DIN_REG <= (others => '0');
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      DIN_REG <= (DIN);
    end if;
  end process reg_DIN;

  reg_TSTR : process (CLK, RES)
  begin  -- process reg_NEW_TAG
    if RES = '1' then                   -- asynchronous reset (active high)
      TSTR_REG <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      TSTR_REG <= TSTR;
    end if;
  end process reg_TSTR;

  reg_reg_TSTR : process (CLK, RES)
  begin  -- process reg_NEW_TAG
    if RES = '1' then                   -- asynchronous reset (active high)
      TSTR_REG_REG <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      TSTR_REG_REG <= TSTR_REG;
    end if;
  end process reg_reg_TSTR;

  reg_DSTR : process (CLK, RES)
  begin  -- process reg_NEW_TAG
    if RES = '1' then                   -- asynchronous reset (active high)
      DSTR_REG <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      DSTR_REG <= DSTR;
    end if;
  end process reg_DSTR;

  reg_reg_DSTR : process (CLK, RES)
  begin  -- process reg_NEW_TAG
    if RES = '1' then                   -- asynchronous reset (active high)
      DSTR_REG_REG <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      DSTR_REG_REG <= DSTR_REG;
    end if;
  end process reg_reg_DSTR;

  CodeBuffering : process (CLK, RES)
  begin  -- process CodeBuffering
    if RES = '1' then
      TRIGCODE_i   <= (others => '0');
    elsif (CLK'event and CLK = '1') then
      if (TSTR_REG = '0') and (TSTR_REG_REG = '1') then
        -- falling edge of TSTR
        TRIGCODE_i <= DIN_REG;
        -- den registerten Wert
      end if;
    end if;
  end process CodeBuffering;

  TagBuffering : process (CLK, RES)
  begin  -- process TagBuffering
    if RES = '1' then                   -- asynchronous reset (active high)
      NIBCNT     <= 0;
      DVAL_REG   <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      DVAL_REG   <= '0';
      if NIBCNT >= 3 then
        NIBCNT   <= 0;
        DVAL_REG <= '1';
      elsif (DSTR_REG = '0') and (DSTR_REG_REG = '1') then
        NIBCNT   <= NIBCNT + 1;
      end if;
    end if;
  end process TagBuffering;

  Shift_Reg : process (CLK, RES)
  begin  -- process TagBuffering
    if RES = '1' then                   -- asynchronous reset (active high)
      TRIGBUFF(0)   <= (others => '0');
      TRIGBUFF(1)   <= (others => '0');
      TRIGBUFF(2)   <= (others => '0');
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if (DSTR_REG = '0') and (DSTR_REG_REG = '1') then  -- falling edge of DSTR
        TRIGBUFF(2) <= TRIGBUFF(1);
        TRIGBUFF(1) <= TRIGBUFF(0);
        TRIGBUFF(0) <= DIN_REG;         -- shift register
      end if;
    end if;
  end process Shift_Reg;

  -- purpose: register DVAL
  -- type   : sequential
  -- inputs : CLK, RES, DVAL
  -- outputs: DVAL_sync
  DVAL_OUT : process (CLK, RES, DVAL_REG)
  begin  -- process DVAL_reg
    if RES = '1' then                   -- asynchronous reset (active low)
      DVAL_REG_REG <= '0';
      DVAL <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      DVAL_REG_REG <= DVAL_REG;
      DVAL <= DVAL_REG or DVAL_REG_REG;
    end if;
  end process DVAL_OUT;
  

  SynchBSY : process(RES, CLK)
  begin
    if (RES = '1') then
      BSY         <= '0';
    elsif (CLK'event and CLK = '1') then
      BSY         <= BUSY_i;
    end if;
  end process SynchBSY;
-------------------------------------------------------------------------------
-- Combinatorial Signals
-------------------------------------------------------------------------------
  TRIGTAG         <= TRIGBUFF(1) & TRIGBUFF(2);
  TRIGCODE        <= TRIGCODE_i;
  ERR             <= TRIGTAG_MISMATCH;
-- DSTR_INV <= NOT(DSTR);
  -- purpose: Set a fast busy on TSTR
  -- type   : sequential
  -- inputs : CLK, RES, BUSY
  -- outputs: BUSY_FASt
  FastBusy : process (CLK, RES, BUSY)
  begin  -- process FastBusy
    if RES = '1' or BUSY = '1'then      -- asynchronous reset (active high)
      BUSY_FAST   <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if TSTR_REG = '1' then
        BUSY_FAST <= '1';
      end if;
    end if;
  end process FastBusy;
  BUSY_i          <= BUSY or BUSY_FAST;
end ARCH_L12TrigInterface;
