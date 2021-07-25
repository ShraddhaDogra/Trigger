LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;


entity onewire_record is
  generic(
    N_SENSORS  : integer := 10;  -- Number of connected sensors
    ROM_ADDR_0 : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADDR_1 : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADDR_2 : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADDR_3 : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADDR_4 : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADDR_5 : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADDR_6 : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADDR_7 : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADDR_8 : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADDR_9 : std_logic_vector(63 downto 0) := x"0000000000000000"
    );
  port(
    CLK      : in std_logic;
    RESET    : in std_logic;
    READOUT_ENABLE_IN : in std_logic := '1';
    --connection to 1-wire interface
    ONEWIRE  : inout std_logic;
    --Interlock
    INTERLOCK_FLAG  : out std_logic :='0';
    INTERLOCK_LIMIT : in  std_logic_vector(31 downto 0) := x"000001F0";
    -- SLOW CONTROL
    BUS_RX     : in  CTRLBUS_RX;
    BUS_TX     : out CTRLBUS_TX
    );
end entity;


architecture onewire_record_arch of onewire_record is

signal data : std_logic_vector(15 downto 0);
signal temperature_0, temperature_1, temperature_2, temperature_3, temperature_4, temperature_5, temperature_6, temperature_7, temperature_8, temperature_9, temperature_10 : std_logic_vector(11 downto 0) := "111111111111";
signal ID_debug : std_logic_vector(63 downto 0);
signal statistic : std_logic_vector(31 downto 0);
signal sens_cnt : std_logic_vector(7 downto 0);

signal interlock_flag_or_i : std_logic := '0';
signal intlck_flag_i : std_logic_vector(10 downto 0) := b"00000000000";
begin


THE_ONEWIRE : entity work.onewire_multi
  generic map(
    USE_TEMPERATURE_READOUT => 1,
    PARASITIC_MODE => c_NO,
    N_SENSORS => N_SENSORS,
    CLK_PERIOD => 10,
    ROM_ADR_0 => ROM_ADDR_0,
    ROM_ADR_1 => ROM_ADDR_1,
    ROM_ADR_2 => ROM_ADDR_2,
    ROM_ADR_3 => ROM_ADDR_3,
    ROM_ADR_4 => ROM_ADDR_4,
    ROM_ADR_5 => ROM_ADDR_5,
    ROM_ADR_6 => ROM_ADDR_6,
    ROM_ADR_7 => ROM_ADDR_7,
    ROM_ADR_8 => ROM_ADDR_8,
    ROM_ADR_9 => ROM_ADDR_9
    )
  port map(
    CLK      	=> CLK,
    RESET    	=> RESET,
    READOUT_ENABLE_IN => '1',
    ONEWIRE  	=> ONEWIRE,
    DATA_OUT 	=> data,

    TEMP_OUT  	=> temperature_0,
    TEMP_OUT_1  => temperature_1,
    TEMP_OUT_2 	=> temperature_2,
    TEMP_OUT_3 	=> temperature_3,
    TEMP_OUT_4 	=> temperature_4,
    TEMP_OUT_5 	=> temperature_5,
    TEMP_OUT_6 	=> temperature_6,
    TEMP_OUT_7 	=> temperature_7,
    TEMP_OUT_8 	=> temperature_8,
    TEMP_OUT_9 	=> temperature_9,
    TEMP_OUT_10	=> open,
    ID_OUT   	=> ID_debug,
    STAT     	=> statistic,
    SENS_CNT 	=> sens_cnt
    );
    
--onewire_interface : entity work.trb_net_onewire
--  generic map(
--    USE_TEMPERATURE_READOUT => c_YES,
--    CLK_PERIOD => 10
--  )
--  port map(
--    CLK      => CLK,
--    RESET    => RESET,
--    --connection to 1-wire interface
--    ONEWIRE  => ONEWIRE,
--    MONITOR_OUT => open,
--    --connection to id ram, according to memory map in TrbNetRegIO
--    DATA_OUT => data,
--    ADDR_OUT => open,
--    WRITE_OUT=> open,
--    TEMP_OUT => temperature,
--    ID_OUT   => ID_debug,                
--    STAT     => statistic
--  );

THE_PROC_Handler : process begin

  wait until rising_edge(CLK);
  BUS_TX.unknown <= '0';
  BUS_TX.ack     <= '0';
  BUS_TX.nack    <= '0';
  BUS_TX.data    <= (others => '0');
    
  if BUS_RX.write = '1' then
    if BUS_RX.addr(3 downto 0) = x"0" then
      --clk_div     <= to_integer(unsigned(BUS_RX.data));
      BUS_TX.ack  <= '1';
    else
      BUS_TX.unknown <= '1';
    end if;
  elsif BUS_RX.read = '1' then
    if BUS_RX.addr(3 downto 0) = x"0" then
      BUS_TX.data(11 downto  0) <= temperature_0;
      BUS_TX.data(31 downto 12) <= (others => '0');
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"1" then
      BUS_TX.data(11 downto  0) <= temperature_1;
      BUS_TX.data(31 downto 12) <= (others => '0');
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"2" then
      BUS_TX.data(11 downto  0) <= temperature_2;
      BUS_TX.data(31 downto 12) <= (others => '0');
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"3" then
      BUS_TX.data(11 downto  0) <= temperature_3;
      BUS_TX.data(31 downto 12) <= (others => '0');
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"4" then
      BUS_TX.data(11 downto  0) <= temperature_4;
      BUS_TX.data(31 downto 12) <= (others => '0');
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"5" then
      BUS_TX.data(11 downto  0) <= temperature_5;
      BUS_TX.data(31 downto 12) <= (others => '0');
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"6" then
      BUS_TX.data(11 downto  0) <= temperature_6;
      BUS_TX.data(31 downto 12) <= (others => '0');
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"7" then
      BUS_TX.data(11 downto  0) <= temperature_7;
      BUS_TX.data(31 downto 12) <= (others => '0');
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"8" then
      BUS_TX.data(11 downto  0) <= temperature_8;
      BUS_TX.data(31 downto 12) <= (others => '0');
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"9" then
      BUS_TX.data(11 downto  0) <= temperature_9;
      BUS_TX.data(31 downto 12) <= (others => '0');
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"A" then
      BUS_TX.data <= ID_debug(63 downto 32);
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"B" then
      BUS_TX.data <= statistic;
      BUS_TX.ack  <= '1';
    elsif BUS_RX.addr(3 downto 0) = x"C" then
      BUS_TX.data(7 downto  0) <= sens_cnt;
      BUS_TX.data(31 downto 8) <= (others => '0');
      BUS_TX.ack  <= '1';
    else
      BUS_TX.unknown <= '1';
    end if;
  end if;
  
end process;

 THE_INTERLOCK_HANDLER: process begin

  wait until rising_edge(CLK);
  -- Interlock fires, if Sensor is connected, has power and is higher than the limit
  if ((temperature_0 >= INTERLOCK_LIMIT) and (temperature_0(11 downto 0) /= x"FFF") and (temperature_0(11 downto 0) /= x"000") and (N_SENSORS >= 1)) then
    intlck_flag_i(0) <= '1';
  else 
    intlck_flag_i(0) <= '0';
  end if;
  
  if ((temperature_1 >= INTERLOCK_LIMIT) and (temperature_1(11 downto 0) /= x"FFF") and (temperature_1(11 downto 0) /= x"000") and (N_SENSORS >= 2)) then
    intlck_flag_i(1) <= '1';
  else 
    intlck_flag_i(1) <= '0';
  end if;
  
  if ((temperature_2 >= INTERLOCK_LIMIT) and (temperature_2(11 downto 0) /= x"FFF") and (temperature_2(11 downto 0) /= x"000") and (N_SENSORS >= 3)) then
    intlck_flag_i(2) <= '1';
  else 
    intlck_flag_i(2) <= '0';
  end if;
  
  if ((temperature_3 >= INTERLOCK_LIMIT) and (temperature_3(11 downto 0) /= x"FFF") and (temperature_3(11 downto 0) /= x"000") and (N_SENSORS >= 4)) then
    intlck_flag_i(3) <= '1';
  else 
    intlck_flag_i(3) <= '0';
  end if;
  
  if ((temperature_4 >= INTERLOCK_LIMIT) and (temperature_4(11 downto 0) /= x"FFF") and (temperature_4(11 downto 0) /= x"000") and (N_SENSORS >= 5)) then
    intlck_flag_i(4) <= '1';
  else 
    intlck_flag_i(4) <= '0';
  end if;
  
  if ((temperature_5 >= INTERLOCK_LIMIT) and (temperature_5(11 downto 0) /= x"FFF") and (temperature_5(11 downto 0) /= x"000") and (N_SENSORS >= 6)) then
    intlck_flag_i(5) <= '1';
  else 
    intlck_flag_i(5) <= '0';
  end if;

  if ((temperature_6 >= INTERLOCK_LIMIT) and (temperature_6(11 downto 0) /= x"FFF") and (temperature_6(11 downto 0) /= x"000") and (N_SENSORS >= 7)) then
    intlck_flag_i(6) <= '1';
  else 
    intlck_flag_i(6) <= '0';
  end if;
  
  if ((temperature_7 >= INTERLOCK_LIMIT) and (temperature_7(11 downto 0) /= x"FFF") and (temperature_7(11 downto 0) /= x"000") and (N_SENSORS >= 8)) then
    intlck_flag_i(7) <= '1';
  else 
    intlck_flag_i(7) <= '0';
  end if;
  
  if ((temperature_8 >= INTERLOCK_LIMIT) and (temperature_8(11 downto 0) /= x"FFF") and (temperature_8(11 downto 0) /= x"000") and (N_SENSORS >= 9)) then
    intlck_flag_i(8) <= '1';
  else 
    intlck_flag_i(8) <= '0';
  end if;
  
  if ((temperature_9 >= INTERLOCK_LIMIT) and (temperature_9(11 downto 0) /= x"FFF") and (temperature_9(11 downto 0) /= x"000") and (N_SENSORS >= 10)) then
    intlck_flag_i(9) <= '1';
  else 
    intlck_flag_i(9) <= '0';
  end if;
  
  if ((temperature_10 >= INTERLOCK_LIMIT) and (temperature_10(11 downto 0) /= x"FFF") and (temperature_10(11 downto 0) /= x"000") and (N_SENSORS >= 11)) then
    intlck_flag_i(10) <= '1';
  else 
    intlck_flag_i(10) <= '0';
  end if;
  
  interlock_flag_or_i <= or_all(intlck_flag_i(N_SENSORS-1 downto 0));
  
  
end process;

  INTERLOCK_FLAG <= interlock_flag_or_i;  --high: INTERLOCK Active    low: INTERLOCK Unactive
end architecture;