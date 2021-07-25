-------------------------------------------------------------------------------
-- Title         : trb_net_old_to_new_testbench
-- Project       : HADES trigger new net 
-------------------------------------------------------------------------------
-- File          : trb_net_old_to_new_testbench.vhd
-- Author        : Tiago Perez (tiago.perez@uni-giessen.de)
-- Created       : 2007/02/26 T. Perez
-- Last modified : 2007/02/27 T. Perez
-------------------------------------------------------------------------------
-- Description   : Testbench for the "trb_net_old_to_new" and the "OLD" trigger
-- bus in general 
--                      
-------------------------------------------------------------------------------
-- Modification history :
-- 2007/02/26 : created
-- 2007/02/27 : T. Perez
--              Removed intermidiate dudu.vhd file. Now trb_net_old_to_new
--              instatiated twice (LVL1 + LVL2). The .tcl and .tcl.sv were also
--              modified because they were still pointing to old directories.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;

use work.p_trb_net_old_to_new_testbench.all;  -- package holds procedures defining commads

entity trb_net_old_to_new_testbench is
end trb_net_old_to_new_testbench;

architecture TEST of trb_net_old_to_new_testbench is
-------------------------------------------------------------------------------
-- signals declaration
-------------------------------------------------------------------------------
  signal SIM_END                     :     boolean                       := false;
  signal CLK                         :     std_logic                     := '0';
  signal CLK_EN                      :     std_logic                     := '1';
  signal RESET                       :     std_logic;
  signal APL_DATA_OUT_LVL1           :     std_logic_vector (47 downto 0);
  signal APL_WRITE_OUT_LVL1          :     std_logic;
  signal APL_FIFO_FULL_IN_LVL1       :     std_logic;
  signal APL_SHORT_TRANSFER_OUT_LVL1 :     std_logic;
  signal APL_DTYPE_OUT_LVL1          :     std_logic_vector (3 downto 0);
  signal APL_ERROR_PATTERN_OUT_LVL1  :     std_logic_vector (31 downto 0);
  signal APL_SEND_OUT_LVL1           :     std_logic;
  signal APL_TARGET_ADDRESS_OUT_LVL1 :     std_logic_vector (15 downto 0);
  signal APL_DATA_IN_LVL1            :     std_logic_vector (47 downto 0);
  signal APL_TYP_IN_LVL1             :     std_logic_vector (2 downto 0);
  signal APL_DATAREADY_IN_LVL1       :     std_logic;
  signal APL_READ_OUT_LVL1           :     std_logic;
  signal APL_RUN_IN_LVL1             :     std_logic                     := '0';
  signal APL_SEQNR_IN_LVL1           :     std_logic_vector (7 downto 0) := (others => '0');
  signal OLD_T_LVL1                  :     std_logic;
  signal OLD_TS_LVL1                 :     std_logic;
  signal OLD_TD_LVL1                 :     std_logic_vector (3 downto 0);
  signal OLD_TB_LVL1                 :     std_logic;
  signal OLD_TE_LVL1                 :     std_logic;
  --
  signal APL_DATA_OUT_LVL2           :     std_logic_vector (47 downto 0);
  signal APL_WRITE_OUT_LVL2          :     std_logic;
  signal APL_SHORT_TRANSFER_OUT_LVL2 :     std_logic;
  signal APL_DTYPE_OUT_LVL2          :     std_logic_vector (3 downto 0);
  signal APL_ERROR_PATTERN_OUT_LVL2  :     std_logic_vector (31 downto 0);
  signal APL_SEND_OUT_LVL2           :     std_logic;
  signal APL_TARGET_ADDRESS_OUT_LVL2 :     std_logic_vector (15 downto 0);
  signal APL_DATA_IN_LVL2            :     std_logic_vector (47 downto 0);
  signal APL_DATAREADY_IN_LVL2       :     std_logic;
  signal APL_READ_OUT_LVL2           :     std_logic;
  signal APL_RUN_IN_LVL2             :     std_logic;
  signal APL_SEQNR_IN_LVL2           :     std_logic_vector (7 downto 0);
  signal OLD_T_LVL2                  :     std_logic;
  signal OLD_TS_LVL2                 :     std_logic;
  signal OLD_TD_LVL2                 :     std_logic_vector (3 downto 0);
  signal OLD_TB_LVL2                 :     std_logic;
  signal OLD_TE_LVL2                 :     std_logic;

  -----------------------------------------------------------------------------
  -- componet to test
  -----------------------------------------------------------------------------
  component trb_net_old_to_new
    generic (
      TRIGGER_LEVEL : integer);
    port (
      CLK                    : in  std_logic;
      RESET                  : in  std_logic;
      CLK_EN                 : in  std_logic;
      APL_DATA_OUT           : out std_logic_vector (47 downto 0);
      APL_WRITE_OUT          : out std_logic;
      APL_FIFO_FULL_IN       : in  std_logic;
      APL_SHORT_TRANSFER_OUT : out std_logic;
      APL_DTYPE_OUT          : out std_logic_vector (3 downto 0);
      APL_ERROR_PATTERN_OUT  : out std_logic_vector (31 downto 0);
      APL_SEND_OUT           : out std_logic;
      APL_TARGET_ADDRESS_OUT : out std_logic_vector (15 downto 0);
      APL_DATA_IN            : in  std_logic_vector (47 downto 0);
      APL_TYP_IN             : in  std_logic_vector (2 downto 0);
      APL_DATAREADY_IN       : in  std_logic;
      APL_READ_OUT           : out std_logic;
      APL_RUN_IN             : in  std_logic;
      APL_SEQNR_IN           : in  std_logic_vector (7 downto 0);
      OLD_T                  : in  std_logic;
      OLD_TS                 : in  std_logic;
      OLD_TD                 : in  std_logic_vector (3 downto 0);
      OLD_TB                 : out std_logic;
      OLD_TE                 : out std_logic);
  end component;
  
  -----------------------------------------------------------------------------
  -- auxiliar component for simulations
  -----------------------------------------------------------------------------  
  component trb_reply
    port (
      SEND_OUT : in  std_logic;
      READ_OUT : in  std_logic;
      RUN_IN   : out std_logic;
      SEQNR_IN : out std_logic_vector(7 downto 0));
  end component;

begin
  -- Generate CLK
  --    CLK <= not CLK after PERIOD/8 when SIM_END = false else '0';
  CLK <= not CLK after 5 ns;            -- 100 MHz

  -- Instantiate the block under test
  uut_lvl1: trb_net_old_to_new
    generic map (
        TRIGGER_LEVEL => 1)
    port map (
        CLK                    => CLK,
        RESET                  => RESET,
        CLK_EN                 => CLK_EN,
        APL_DATA_OUT           => APL_DATA_OUT_LVL1,
        APL_WRITE_OUT          => APL_WRITE_OUT_LVL1,
        APL_FIFO_FULL_IN       => APL_FIFO_FULL_IN_LVL1,
        APL_SHORT_TRANSFER_OUT => APL_SHORT_TRANSFER_OUT_LVL1,
        APL_DTYPE_OUT          => APL_DTYPE_OUT_LVL1,
        APL_ERROR_PATTERN_OUT  => APL_ERROR_PATTERN_OUT_LVL1,
        APL_SEND_OUT           => APL_SEND_OUT_LVL1,
        APL_TARGET_ADDRESS_OUT => APL_TARGET_ADDRESS_OUT_LVL1,
        APL_DATA_IN            => APL_DATA_IN_LVL1,
        APL_TYP_IN             => APL_TYP_IN_LVL1,
        APL_DATAREADY_IN       => APL_DATAREADY_IN_LVL1,
        APL_READ_OUT           => APL_READ_OUT_LVL1,
        APL_RUN_IN             => APL_RUN_IN_LVL1,
        APL_SEQNR_IN           => APL_SEQNR_IN_LVL1,
        OLD_T                  => OLD_T_LVL1,
        OLD_TS                 => OLD_TS_LVL1,
        OLD_TD                 => OLD_TD_LVL1,
        OLD_TB                 => OLD_TB_LVL1,
        OLD_TE                 => OLD_TE_LVL1);

  uut_lvl2: trb_net_old_to_new
    generic map (
        TRIGGER_LEVEL => 2)
    port map (
        CLK                    => CLK,
        RESET                  => RESET,
        CLK_EN                 => CLK_EN,
        APL_DATA_OUT           => APL_DATA_OUT_LVL2,
        APL_WRITE_OUT          => APL_WRITE_OUT_LVL2,
        APL_FIFO_FULL_IN       => '0', 
        APL_SHORT_TRANSFER_OUT => APL_SHORT_TRANSFER_OUT_LVL2,
        APL_DTYPE_OUT          => APL_DTYPE_OUT_LVL2,
        APL_ERROR_PATTERN_OUT  => APL_ERROR_PATTERN_OUT_LVL2,
        APL_SEND_OUT           => APL_SEND_OUT_LVL2,
        APL_TARGET_ADDRESS_OUT => APL_TARGET_ADDRESS_OUT_LVL2,
        APL_DATA_IN            => (others => '0'),
        APL_TYP_IN             => (others => '0'), 
        APL_DATAREADY_IN       => APL_DATAREADY_IN_LVL2,
        APL_READ_OUT           => APL_READ_OUT_LVL2,
        APL_RUN_IN             => APL_RUN_IN_LVL2,
        APL_SEQNR_IN           => APL_SEQNR_IN_LVL2,
        OLD_T                  => OLD_T_LVL2,
        OLD_TS                 => OLD_TS_LVL2,
        OLD_TD                 => OLD_TD_LVL2,
        OLD_TB                 => OLD_TB_LVL2,
        OLD_TE                 => OLD_TE_LVL2);

  trb_LVL1                     : trb_reply
    port map (
      SEND_OUT                    => APL_SEND_OUT_LVL1,
      READ_OUT                    => APL_READ_OUT_LVL1,
      RUN_IN                      => APL_RUN_IN_LVL1,
      SEQNR_IN                    => APL_SEQNR_IN_LVL1);

  trb_LVL2                     : trb_reply
    port map (
      SEND_OUT                    => APL_SEND_OUT_LVL2,
      READ_OUT                    => APL_READ_OUT_LVL2,
      RUN_IN                      => APL_RUN_IN_LVL2,
      SEQNR_IN                    => APL_SEQNR_IN_LVL2);
------------------------------------------------------------------------
-- COMMAND INPUT process
-- This process reads command strings from the test file "command.txt"
-- and generates input stimulus to the block under test, depending upon
-- which command is read in. The commands are:
--
-- RESET                                -- reset the board
-- BE_RU                                -- send a begin_run trigger
-- SE_TR D DDD                          -- send normal trigger on LVL D with tag DDD
-- SEXCY                                -- send a complete 256 trigger cycle to
-- LVL X where X is 1,2 or A for all
-- EN_RU                                -- end the run
-- VME_R DD                             -- simulate a VME Read Cycle on address
--                                      -- DD
-- WAIT_                                -- waits 300*PERIOD
-- (D = integer ascii character in range 0-9)
------------------------------------------------------------------------
  COMMAND_INPUT                : process
    --file COMFILE               : text is in "command.txt"; '87
    file COMFILE               : text open read_mode is "command.txt";
    variable L                 : line;
    variable CMD               : string(1 to 5);
    variable SETTING           : string(1 to 3);
    variable LVL               : character;
    variable CYCLES, SEPARATOR : character;
  begin
    ---------------------------------------------------------------------------
    -- SET INITIAL VALUES
    ---------------------------------------------------------------------------
    -- set all to '0'
    ---------------------------------------------------------------------------
    -- TrigBus
    -- lvl1
    OLD_TS_LVL1 <= '0';
    -- lvl2
    OLD_T_LVL2  <= '0';
    OLD_TS_LVL2 <= '0';
    OLD_TD_LVL2 <= (others        => '0');

    ---------------------------------------------------------------------------
    -- READ COMMAND FILE
    ---------------------------------------------------------------------------
    -- if there are still lines to read in the text file ...
    while not ENDFILE(COMFILE) loop

      -- read in next line from text file, then read the first text string
      -- from the line and call this CMD.
      readline(COMFILE, L);
      read (L, CMD);

      -- Depending on what the command is, read in any extra information
      -- from the line read from the file and then "do" the command
      case CMD is
        when "RST__" => assert false report "Reset" severity note;
                        DO_RESET(RESET);

        when "BE_RU" => assert false report "Begin Trigger to be send..." severity note;
                        DO_BE_RU(OLD_T_LVL1, OLD_TS_LVL1, OLD_TD_LVL1, OLD_TB_LVL1);
        when "SE_TR" => read (L, SEPARATOR);
                        read (L, LVL);
                        if LVL = '1' then
                          read (L, SEPARATOR);
                          read (L, SETTING);
                          assert false report "Normal Trigger LVL 1 to be send..." severity note;
                          DO_SE_TR_LVL1(SETTING, OLD_T_LVL1, OLD_TS_LVL1, OLD_TD_LVL1, OLD_TB_LVL1);
                        end if;
                        if LVL = '2' then
                          read (L, SEPARATOR);
                          read (L, SETTING);
                          assert false report "Normal Trigger LVL 2 to be send..." severity note;
                          DO_SE_TR_LVL2(SETTING, OLD_T_LVL2, OLD_TS_LVL2, OLD_TD_LVL2, OLD_TB_LVL2);
                        end if;
-- when "SE1CY" => DO_SE_CY(T_TRIGBUS_TSTR_LVL1_i, T_TRIGBUS_DSTR_LVL1_i, T_TRIGBUS_DIN_LVL1_i, T_TRIGBUS_BUSY_LVL1_i);
-- when "SE2CY" => DO_SE_CY(T_TRIGBUS_TSTR_LVL2_i, T_TRIGBUS_DSTR_LVL2_i, T_TRIGBUS_DIN_LVL2_i, T_TRIGBUS_BUSY_LVL2_i);
-- when "SEACY" => DO_SE_CY_ALL(T_TRIGBUS_TSTR_LVL1_i, T_TRIGBUS_DSTR_LVL1_i, T_TRIGBUS_DIN_LVL1_i, T_TRIGBUS_BUSY_LVL1_i,
-- T_TRIGBUS_TSTR_LVL2_i, T_TRIGBUS_DSTR_LVL2_i, T_TRIGBUS_DIN_LVL2_i, T_TRIGBUS_BUSY_LVL2_i);
        when "EN_RU" => DO_EN_RU(OLD_T_LVL1, OLD_TS_LVL1, OLD_TD_LVL1, OLD_TB_LVL1);
        when "WAIT_" => assert false report "Wait" severity note;
                        DO_WAIT;
        when others  => assert false report "Unrecognised Instruction"
                          severity failure;
      end case;

    end loop;

    -- No new lines to read from file, so report simulation complete and
    -- stop clock generator with SIM_END signal
    assert false report "Simulation complete" severity note;
    SIM_END <= true;

    wait;

  end process COMMAND_INPUT;

end TEST;




