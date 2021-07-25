-------------------------------------------------------------------------------
-- Title         : trb_net_old_to_new_testbench
-- Project       : HADES trigger new net 
-------------------------------------------------------------------------------
-- File          : trb_net_old_to_new_testbench.vhd
-- Author        : Tiago Perez (tiago.perez@uni-giessen.de)
-- Created       : 2007/02/26 T. Perez
-- Last modified : 
-------------------------------------------------------------------------------
-- Description   : Testbench for the "trb_net_old_to_new" and the "OLD" trigger
-- bus in general. PACKAGE 
--                      
-------------------------------------------------------------------------------
-- Modification history :
-- 2007/02/26 : created
--              I change ARITH for UNSIGNED. Some funtions are nicer defined
--              there, adn this is anyhow only for sim. 
-------------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use std.textio.all;
--use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

------------------------------------------------------------------------
-- Package Declaration
------------------------------------------------------------------------

package p_trb_net_old_to_new_testbench is

-- Constant for the clock period we will use
  constant PERIOD     : time := 100 ns;  -- 10 MHz
  constant PERIOD_TRB : time := 10 ns;   -- 100 MHz

-- This function converts std_logic to character so the standard
-- write routine for character can be used

  function STDU2CHAR (LOGIC : std_logic) return character;

------------------------------------------------------------------------
-- The following procedures perform the actions required of the commands
-- DO_RESET, DO_BE_RU (DO begin run), DO_SE_TR (DO send Trigger), DO_EN_RU (DO
-- end run
------------------------------------------------------------------------

  procedure DO_RESET(signal RESET : out std_logic);

  procedure DO_VME_RE(signal T_VME_ADDRESS : out std_logic_vector(7 downto 1);
                      signal T_VME_DATA    : out std_logic_vector(7 downto 0);
                      signal T_VME_DLY1    : out std_logic;
                      signal T_VME_WRT     : out std_logic;
                      signal T_VME_BSEL1   : out std_logic;
                      SETTING              : in  string(1 to 3));

  procedure DO_BE_RU(signal T_TRIGBUS_TSTR : out std_logic;
                     signal T_TRIGBUS_DSTR : out std_logic;
                     signal T_TRIGBUS_DIN  : out std_logic_vector(3 downto 0);
                     signal T_TRIGBUS_BUSY : in  std_logic);

  procedure DO_SE_TR_LVL1(SETTING               : in  string(1 to 3);
                          signal T_TRIGBUS_TSTR : out std_logic;
                          signal T_TRIGBUS_DSTR : out std_logic;
                          signal T_TRIGBUS_DIN  : out std_logic_vector(3 downto 0);
                          signal T_TRIGBUS_BUSY : in  std_logic);

  procedure DO_SE_TR_LVL2(SETTING               : in  string(1 to 3);
                          signal T_TRIGBUS_TSTR : out std_logic;
                          signal T_TRIGBUS_DSTR : out std_logic;
                          signal T_TRIGBUS_DIN  : out std_logic_vector(3 downto 0);
                          signal T_TRIGBUS_BUSY : in  std_logic);

  procedure DO_EN_RU(signal T_TRIGBUS_TSTR : out std_logic;
                     signal T_TRIGBUS_DSTR : out std_logic;
                     signal T_TRIGBUS_DIN  : out std_logic_vector(3 downto 0);
                     signal T_TRIGBUS_BUSY : in  std_logic);

  procedure DO_SE_CY(signal     T_TRIGBUS_TSTR   : out std_logic;
                     signal     T_TRIGBUS_DSTR   : out std_logic;
                     signal     T_TRIGBUS_DIN    : out std_logic_vector(3 downto 0);
                     signal     T_TRIGBUS_BUSY   : in  std_logic);
  procedure DO_SE_CY_ALL(signal T_TRIGBUS_TSTR_1 : out std_logic;
                         signal T_TRIGBUS_DSTR_1 : out std_logic;
                         signal T_TRIGBUS_DIN_1  : out std_logic_vector(3 downto 0);
                         signal T_TRIGBUS_BUSY_1 : in  std_logic;
                         signal T_TRIGBUS_TSTR_2 : out std_logic;
                         signal T_TRIGBUS_DSTR_2 : out std_logic;
                         signal T_TRIGBUS_DIN_2  : out std_logic_vector(3 downto 0);
                         signal T_TRIGBUS_BUSY_2 : in  std_logic
                         );

  procedure DO_WAIT;

end p_trb_net_old_to_new_testbench;


------------------------------------------------------------------------
-- Package Body Declaration
------------------------------------------------------------------------
package body p_trb_net_old_to_new_testbench is
------------------------------------------------------------------------

------------------------------------------------------------------------
-- STDU2CHAR type conversion function
------------------------------------------------------------------------
  function STDU2CHAR (LOGIC : std_logic) return character is
    variable CHAR           : character;
  begin
    case LOGIC is
      when '1'    => CHAR := '1';
      when '0'    => CHAR := '0';
      when others => CHAR := '-';
    end case;
    return CHAR;
  end STDU2CHAR;

  function CHAR2INT (CHAR : character) return integer is
    variable INT          : integer;
  begin
    case CHAR is
      when '0'    => INT := 0;
      when '1'    => INT := 1;
      when '2'    => INT := 2;
      when '3'    => INT := 3;
      when '4'    => INT := 4;
      when '5'    => INT := 5;
      when '6'    => INT := 6;
      when '7'    => INT := 7;
      when '8'    => INT := 8;
      when '9'    => INT := 9;
      when others =>
    end case;
    return INT;
  end CHAR2INT;

  function INT2CHAR (INT : integer) return character is
    variable temp        : character;
  begin
    case INT is
      --when 0 => temp := character('0');
      when 0      => temp := '0';
      when 1      => temp := '1';
      when 2      => temp := '2';
      when 3      => temp := '3';
      when 4      => temp := '4';
      when 5      => temp := '5';
      when 6      => temp := '6';
      when 7      => temp := '7';
      when 8      => temp := '8';
      when 9      => temp := '9';
      when others => temp := '-';
    end case;
    return temp;
  end INT2CHAR;

------------------------------------------------------------------------
-- DO_RESET command
------------------------------------------------------------------------
  procedure DO_RESET(signal RESET : out std_logic) is
  begin
    RESET <= '0';
    wait for 2*PERIOD;
    RESET <= '1';
    wait for 1 us;
    RESET <= '0';
  end DO_RESET;

------------------------------------------------------------------------
-- DO_VME_RE command
------------------------------------------------------------------------
  procedure DO_VME_RE(signal T_VME_ADDRESS : out std_logic_vector(7 downto 1);
                      signal T_VME_DATA    : out std_logic_vector(7 downto 0);
                      signal T_VME_DLY1    : out std_logic;
                      signal T_VME_WRT     : out std_logic;
                      signal T_VME_BSEL1   : out std_logic;
                      SETTING              : in  string(1 to 3)) is

    variable TTAG       : integer;
    variable STTAG_TEMP : unsigned(7 downto 0);
    variable STTAG      : unsigned(6 downto 0);
  begin
    T_VME_DATA <= "ZZZZZZZZ";
    TTAG              := CHAR2INT(SETTING(1))*100;
    TTAG              := TTAG + CHAR2INT(SETTING(2))*10;
    TTAG              := TTAG + CHAR2INT(SETTING(3));
    STTAG_TEMP        := to_unsigned(TTAG, 8);
    STTAG(6 downto 0) := STTAG_TEMP(7 downto 1);

    T_VME_ADDRESS <= std_logic_vector(STTAG);
    T_VME_DLY1    <= '1';
    T_VME_BSEL1   <= '0';
    T_VME_WRT     <= '1';
    wait for 2*PERIOD;
    wait for 2*PERIOD;
    T_VME_ADDRESS <= "0000000";
    T_VME_DLY1    <= '0';
    T_VME_BSEL1   <= '1';
    T_VME_WRT     <= '1';
    wait for 2*PERIOD;
  end DO_VME_RE;

------------------------------------------------------------------------
-- DO Begin RUN command
------------------------------------------------------------------------
  procedure DO_BE_RU(signal T_TRIGBUS_TSTR : out std_logic;
                     signal T_TRIGBUS_DSTR : out std_logic;
                     signal T_TRIGBUS_DIN  : out std_logic_vector(3 downto 0);
                     signal T_TRIGBUS_BUSY : in  std_logic)
  is
  begin
    assert false report "DO_BE_RU called" severity note;
    --wait until T_TRIGBUS_BUSY='0';
    wait for 0.4*PERIOD;
    T_TRIGBUS_TSTR   <= '1';
    T_TRIGBUS_DSTR   <= '0';
    T_TRIGBUS_DIN    <= "1101";         -- check if this is now the correct code
    wait for 0.6*PERIOD;                -- the ctu does seem to send this and not
    wait for PERIOD;                    -- "0010"
    T_TRIGBUS_TSTR   <= '0';
    wait for 0.8*PERIOD;
    T_TRIGBUS_DIN    <= "1111";
    wait for 0.2*PERIOD;
    for k in 0 to 2 loop
      T_TRIGBUS_DIN  <= "0000";
-- wait for PERIOD;
      T_TRIGBUS_DSTR <= '1';
      wait for period;
      T_TRIGBUS_DSTR <= '0';
      wait for period;
    end loop;  -- k

  end DO_BE_RU;

------------------------------------------------------------------------
-- DO Send Trigger command
------------------------------------------------------------------------
  procedure DO_SE_TR_LVL1(SETTING               : in  string(1 to 3);
                          signal T_TRIGBUS_TSTR : out std_logic;
                          signal T_TRIGBUS_DSTR : out std_logic;
                          signal T_TRIGBUS_DIN  : out std_logic_vector(3 downto 0);
                          signal T_TRIGBUS_BUSY : in  std_logic)
  is
    variable                     TTAG           :     integer;
    variable                     STTAG          :     unsigned(7 downto 0);
    variable                     debug_string   :     string(1 to 3) := "000";
    variable                     OUTBLA         :     string(1 to 20);

  begin
    assert false report "DO_SE_TR_LVL1 called" severity note;
    assert false report "SETTING" severity note;
    assert false report SETTING severity note;
    -- debug                            ------------------------------------------------------------------
    --assert false report "waiting for T_TRIGBUS_BUSY = '0'" severity NOTE;
    assert false report "Set T_TRIGBUS_DIN 0000-1111-0000" severity note;
    T_TRIGBUS_DIN <= "0000";
    wait for PERIOD;
    T_TRIGBUS_DIN <= "1111";
    wait for PERIOD;
    T_TRIGBUS_DIN <= "0000";
    ---------------------------------------------------------------------------
    --assert not T_TRIGBUS_BUSY='0' report "bla" severity NOTE;

    --report time'image(NOW);
    --report std_logic'image(T_TRIGBUS_BUSY);
    if T_TRIGBUS_BUSY = '1' then
      wait until T_TRIGBUS_BUSY = '0';
    end if;

    assert false report "T_TRIGBUS_BUSY = 0" severity note;
    TTAG            := CHAR2INT(SETTING(1))*100;
    debug_string(1) := INT2CHAR(integer(TTAG / 100));
    TTAG            := TTAG + CHAR2INT(SETTING(2))*10;
    debug_string(2) := INT2CHAR(integer((TTAG mod 100)/10));
    TTAG            := TTAG + CHAR2INT(SETTING(3));
    debug_string(3) := INT2CHAR(TTAG mod 10);
    STTAG           := to_unsigned(TTAG, 8);
    assert false report "debug String = " severity note;
    assert false report debug_string severity note;
    --assert false report "TTAG = " severity note;
    --report integer'image(TTAG);
    wait for 0.4*PERIOD;
    T_TRIGBUS_TSTR <= '1';
    T_TRIGBUS_DSTR <= '0';
    T_TRIGBUS_DIN  <= "0001";           -- triger code 
    wait for 0.6*PERIOD;
    wait for PERIOD;
    T_TRIGBUS_TSTR <= '0';
    wait for 0.8*PERIOD;
    T_TRIGBUS_DIN  <= "1111";           -- <- Why that?
    wait for 0.2*PERIOD;
    T_TRIGBUS_DIN  <= std_logic_vector(STTAG(3 downto 0));
-- wait for PERIOD;                     -- the ctu should wait but DOES NOT!!!
    T_TRIGBUS_DSTR <= '1';
    wait for period;
    T_TRIGBUS_DSTR <= '0';
    wait for period;
    T_TRIGBUS_DIN  <= std_logic_vector(STTAG(7 downto 4));
-- wait for PERIOD;
    T_TRIGBUS_DSTR <= '1';
    wait for period;
    T_TRIGBUS_DSTR <= '0';
    wait for period;
    T_TRIGBUS_DIN  <= "0000";
-- wait for PERIOD;
    T_TRIGBUS_DSTR <= '1';
    wait for period;
    T_TRIGBUS_DSTR <= '0';
    wait for period;

  end DO_SE_TR_LVL1;

-------------------------------------------------------------------------------
-- SEND LVL2 TRIGER
-------------------------------------------------------------------------------
  procedure DO_SE_TR_LVL2(SETTING               : in  string(1 to 3);
                          signal T_TRIGBUS_TSTR : out std_logic;
                          signal T_TRIGBUS_DSTR : out std_logic;
                          signal T_TRIGBUS_DIN  : out std_logic_vector(3 downto 0);
                          signal T_TRIGBUS_BUSY : in  std_logic)
  is
    variable                     TTAG           :     integer;
    variable                     STTAG          :     unsigned(7 downto 0);
    variable                     debug_string   :     string(1 to 3) := "000";
  begin
    assert false report "DO_SE_TR_LVL2 called" severity note;
    assert false report "SETTING" severity note;
    assert false report SETTING severity note;

    ---------------------------------------------------------------------------
    -- CHECK BUSY COND
    ---------------------------------------------------------------------------
    --wait for 150 ns;
    if T_TRIGBUS_BUSY = '1' then
      wait until T_TRIGBUS_BUSY = '0';
    end if;

    TTAG            := CHAR2INT(SETTING(1))*100;
    debug_string(1) := INT2CHAR(integer(TTAG / 100));
    TTAG            := TTAG + CHAR2INT(SETTING(2))*10;
    debug_string(2) := INT2CHAR(integer((TTAG mod 100)/10));
    TTAG            := TTAG + CHAR2INT(SETTING(3));
    debug_string(3) := INT2CHAR(TTAG mod 10);
    STTAG           := to_unsigned(TTAG, 8);
    assert false report debug_string severity note;
    wait for 0.4*PERIOD;
    T_TRIGBUS_TSTR <= '1';
    T_TRIGBUS_DSTR <= '0';
    T_TRIGBUS_DIN  <= "0001";
    wait for 0.6*PERIOD;
    wait for PERIOD;
    T_TRIGBUS_TSTR <= '0';
    wait for 0.8*PERIOD;
    T_TRIGBUS_DIN  <= "1111";
    wait for 0.2*PERIOD;
    T_TRIGBUS_DIN  <= std_logic_vector(STTAG(3 downto 0));
-- wait for PERIOD;                     -- the ctu should wait but DOES NOT!!!
    T_TRIGBUS_DSTR <= '1';
    wait for period;
    T_TRIGBUS_DSTR <= '0';
    wait for period;
    T_TRIGBUS_DIN  <= std_logic_vector(STTAG(7 downto 4));
-- wait for PERIOD;
    T_TRIGBUS_DSTR <= '1';
    wait for period;
    T_TRIGBUS_DSTR <= '0';
    wait for period;
    T_TRIGBUS_DIN  <= "0000";
-- wait for PERIOD;
    T_TRIGBUS_DSTR <= '1';
    wait for period;
    T_TRIGBUS_DSTR <= '0';
    wait for period;

  end DO_SE_TR_LVL2;


  procedure DO_SE_TR2_LVL1(TTAG                  : in  natural;
                           signal T_TRIGBUS_TSTR : out std_logic;
                           signal T_TRIGBUS_DSTR : out std_logic;
                           signal T_TRIGBUS_DIN  : out std_logic_vector(3 downto 0);
                           signal T_TRIGBUS_BUSY : in  std_logic )
  is
    variable                      STTAG          :     unsigned(7 downto 0);
  begin
    wait until T_TRIGBUS_BUSY = '0';
    STTAG := to_unsigned(TTAG, 8);
    wait for 0.4*PERIOD;
    T_TRIGBUS_TSTR <= '1';
    T_TRIGBUS_DSTR <= '0';
    T_TRIGBUS_DIN  <= "0001";
    wait for 0.6*PERIOD;
    wait for PERIOD;
    T_TRIGBUS_TSTR <= '0';
    wait for 0.8*PERIOD;
    T_TRIGBUS_DIN  <= "1111";
    wait for 0.2*PERIOD;
    T_TRIGBUS_DIN  <= std_logic_vector(STTAG(3 downto 0));
-- wait for PERIOD;
    T_TRIGBUS_DSTR <= '1';
    wait for period;
    T_TRIGBUS_DSTR <= '0';
    wait for period;
    T_TRIGBUS_DIN  <= std_logic_vector(STTAG(7 downto 4));
-- wait for PERIOD;
    T_TRIGBUS_DSTR <= '1';
    wait for period;
    T_TRIGBUS_DSTR <= '0';
    wait for period;
    T_TRIGBUS_DIN  <= "0000";
    --  wait for PERIOD;
    T_TRIGBUS_DSTR <= '1';
    wait for period;
    T_TRIGBUS_DSTR <= '0';
    wait for period;
  end DO_SE_TR2_LVL1;


  procedure DO_SE_TR2_LVL2(TTAG                  : in  natural;
                           signal T_TRIGBUS_TSTR : out std_logic;
                           signal T_TRIGBUS_DSTR : out std_logic;
                           signal T_TRIGBUS_DIN  : out std_logic_vector(3 downto 0);
                           signal T_TRIGBUS_BUSY : in  std_logic )
  is
    variable                      STTAG          :     unsigned(7 downto 0);
  begin
    wait until T_TRIGBUS_BUSY = '0';
    STTAG := to_unsigned(TTAG, 8);
    wait for 0.4*PERIOD;
    T_TRIGBUS_TSTR <= '1';
    T_TRIGBUS_DSTR <= '0';
    T_TRIGBUS_DIN  <= "0001";
    wait for 0.6*PERIOD;
    wait for PERIOD;
    T_TRIGBUS_TSTR <= '0';
    wait for 0.8*PERIOD;
    T_TRIGBUS_DIN  <= "1111";
    wait for 0.2*PERIOD;
    T_TRIGBUS_DIN  <= std_logic_vector(STTAG(3 downto 0));
-- wait for PERIOD;
    T_TRIGBUS_DSTR <= '1';
    wait for period;
    T_TRIGBUS_DSTR <= '0';
    wait for period;
    T_TRIGBUS_DIN  <= std_logic_vector(STTAG(7 downto 4));
-- wait for PERIOD;
    T_TRIGBUS_DSTR <= '1';
    wait for period;
    T_TRIGBUS_DSTR <= '0';
    wait for period;
    T_TRIGBUS_DIN  <= "0000";
    --  wait for PERIOD;
    T_TRIGBUS_DSTR <= '1';
    wait for period;
    T_TRIGBUS_DSTR <= '0';
    wait for period;
  end DO_SE_TR2_LVL2;



------------------------------------------------------------------------
-- DO End Run command
------------------------------------------------------------------------
  procedure DO_EN_RU(signal T_TRIGBUS_TSTR : out std_logic;
                     signal T_TRIGBUS_DSTR : out std_logic;
                     signal T_TRIGBUS_DIN  : out std_logic_vector(3 downto 0);
                     signal T_TRIGBUS_BUSY : in  std_logic)
  is
  begin
    wait until T_TRIGBUS_BUSY = '0';
    wait for 0.4*PERIOD;
    T_TRIGBUS_TSTR   <= '1';
    T_TRIGBUS_DSTR   <= '0';
    T_TRIGBUS_DIN    <= "0011";
    wait for 0.6*PERIOD;
    wait for PERIOD;
    T_TRIGBUS_TSTR   <= '0';
    wait for 0.8*PERIOD;
    T_TRIGBUS_DIN    <= "1111";
    wait for 0.2*PERIOD;
    for k in 0 to 2 loop
      T_TRIGBUS_DIN  <= "0000";
-- wait for PERIOD;
      T_TRIGBUS_DSTR <= '1';
      wait for period;
      T_TRIGBUS_DSTR <= '0';
      wait for period;
    end loop;  -- k

  end DO_EN_RU;

  procedure DO_SE_CY(signal T_TRIGBUS_TSTR : out std_logic;
                     signal T_TRIGBUS_DSTR : out std_logic;
                     signal T_TRIGBUS_DIN  : out std_logic_vector(3 downto 0);
                     signal T_TRIGBUS_BUSY : in  std_logic
                     )
  is
  begin

    for k in 0 to 255 loop
      DO_SE_TR2_LVL1(k, T_TRIGBUS_TSTR, T_TRIGBUS_DSTR, T_TRIGBUS_DIN, T_TRIGBUS_BUSY);
    end loop;  -- k

  end DO_SE_CY;

  procedure DO_SE_CY_ALL(signal T_TRIGBUS_TSTR_1 : out std_logic;
                         signal T_TRIGBUS_DSTR_1 : out std_logic;
                         signal T_TRIGBUS_DIN_1  : out std_logic_vector(3 downto 0);
                         signal T_TRIGBUS_BUSY_1 : in  std_logic;
                         signal T_TRIGBUS_TSTR_2 : out std_logic;
                         signal T_TRIGBUS_DSTR_2 : out std_logic;
                         signal T_TRIGBUS_DIN_2  : out std_logic_vector(3 downto 0);
                         signal T_TRIGBUS_BUSY_2 : in  std_logic
                         )
  is
  begin

    for k in 0 to 255 loop
      DO_SE_TR2_LVL1(k, T_TRIGBUS_TSTR_1, T_TRIGBUS_DSTR_1, T_TRIGBUS_DIN_1, T_TRIGBUS_BUSY_1);
      DO_SE_TR2_LVL2(k, T_TRIGBUS_TSTR_2, T_TRIGBUS_DSTR_2, T_TRIGBUS_DIN_2, T_TRIGBUS_BUSY_2);
    end loop;  -- k

  end DO_SE_CY_ALL;

  procedure DO_WAIT
  is
  begin
    wait for 75*PERIOD;
  end DO_WAIT;

end p_trb_net_old_to_new_testbench;
