LIBRARY ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
entity link_test is
  
  port (
    CLK        : in  std_logic;
    RESET      : in  std_logic;
    DATA_IN    : in  std_logic_vector(15 downto 0);
    DATA_OUT   : out std_logic_vector(15 downto 0);
    VALID_IN   : in  std_logic;
    VALID_OUT  : out std_logic;
    LINK_DEBUG : out std_logic_vector(31 downto 0);
    LINK_INFO  : in  std_logic_vector(15 downto 0)
    );

end link_test;

architecture link_test of link_test is

  component up_down_counter
    generic (
      NUMBER_OF_BITS : positive);
    port (
      CLK       : in  std_logic;
      RESET     : in  std_logic;
      COUNT_OUT : out std_logic_vector(NUMBER_OF_BITS-1 downto 0);
      UP_IN     : in  std_logic;
      DOWN_IN   : in  std_logic);
  end component;

  component mdc_dc_lvl1_dpram_rand
    port (
      DataInA  : in  std_logic_vector(7 downto 0);
      DataInB  : in  std_logic_vector(7 downto 0);
      AddressA : in  std_logic_vector(8 downto 0);
      AddressB : in  std_logic_vector(8 downto 0);
      ClockA   : in  std_logic;
      ClockB   : in  std_logic;
      ClockEnA : in  std_logic;
      ClockEnB : in  std_logic;
      WrA      : in  std_logic;
      WrB      : in  std_logic;
      ResetA   : in  std_logic;
      ResetB   : in  std_logic;
      QA       : out std_logic_vector(7 downto 0);
      QB       : out std_logic_vector(7 downto 0));
  end component;

  component mdc_dc_lvl1_dpram_zero
    port (
      DataInA  : in  std_logic_vector(7 downto 0);
      DataInB  : in  std_logic_vector(7 downto 0);
      AddressA : in  std_logic_vector(8 downto 0);
      AddressB : in  std_logic_vector(8 downto 0);
      ClockA   : in  std_logic;
      ClockB   : in  std_logic;
      ClockEnA : in  std_logic;
      ClockEnB : in  std_logic;
      WrA      : in  std_logic;
      WrB      : in  std_logic;
      ResetA   : in  std_logic;
      ResetB   : in  std_logic;
      QA       : out std_logic_vector(7 downto 0);
      QB       : out std_logic_vector(7 downto 0));
  end component;
  type TEST_LINK_FSM is (IDLE, TEST1, TEST2, TEST3, TEST4, TRANSMITION_ERROR) ;
  signal TEST_LINK_FSM_current, TEST_LINK_FSM_next : TEST_LINK_FSM;
  signal wait_for_second_board_counter : std_logic_vector(31 downto 0);
  signal enable_sec_board_counter : std_logic;
  signal mem_diff : std_logic;
  signal mem_check_ok : std_logic;
  
  signal random_memory_address : std_logic_vector(8 downto 0);
  signal random_memory_send : std_logic;

  signal zero_memory_read_address : std_logic_vector(8 downto 0);
  signal zero_memory_write_address : std_logic_vector(8 downto 0);
  signal zero_memory_read : std_logic;
  
  signal zero_memory_data_out : std_logic_vector(7 downto 0);
  signal rand_memory_data_out : std_logic_vector(7 downto 0);

  signal counter_for_send_en : std_logic_vector(10 downto 0);

  signal rand_memory_data_out_synch : std_logic_vector(7 downto 0);
  signal rand_memory_data_out_synch_synch : std_logic_vector(7 downto 0);
  signal rand_memory_data_out_synch_synch_synch : std_logic_vector(7 downto 0);
  
  signal wait_for_data_counter : std_logic_vector(27 downto 0);
  signal wait_for_data_en : std_logic;

  signal link_debug_i : std_logic_vector(1 downto 0);
  signal wait_for_data_reset : std_logic;

  signal zero_memory_read_synch : std_logic;
  signal wait_for_second_board_reset : std_logic;

  
begin 
  TEST_CLOCK         : process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        TEST_LINK_FSM_current <= IDLE;
      else
        TEST_LINK_FSM_current <= TEST_LINK_FSM_next;
      end if;
    end if;
  end process TEST_CLOCK;
    FSM_TO_TEST_LINK        : process (CLK)
  begin
    case TEST_LINK_FSM_current is
      when IDLE   =>
        link_debug_i <= "01";
        enable_sec_board_counter <= '0';
        mem_check_ok <= '0';
        random_memory_send <= '0';
        wait_for_data_reset <= '1';
        VALID_OUT <= '0';
        wait_for_second_board_reset <= '1';
        if LINK_INFO(0)='1' then
          TEST_LINK_FSM_next       <= TEST1;
        else
          TEST_LINK_FSM_next       <= IDLE;
        end if;
      when TEST1  =>
        link_debug_i <= "10";
        enable_sec_board_counter <= '1';
        mem_check_ok <= '0';
        random_memory_send <= '0';
        VALID_OUT <= '0';
        wait_for_data_reset <= '1';
        wait_for_second_board_reset <= '0';
        if wait_for_second_board_counter(27)='1' then
          TEST_LINK_FSM_next       <= TEST2;
        else
          TEST_LINK_FSM_next       <= TEST1;
        end if;
      when TEST2  =>
        link_debug_i <= "11";
        enable_sec_board_counter <= '0';
        mem_check_ok <= '1';
        random_memory_send <= '1';
        VALID_OUT <= counter_for_send_en(10);
        wait_for_data_reset <= '0';
        wait_for_second_board_reset <= '0';
        if (LINK_INFO(1)= '1'  or LINK_INFO(2)='1' or mem_diff = '1') and wait_for_data_en = '0' then
          TEST_LINK_FSM_next       <= IDLE;
        else
          TEST_LINK_FSM_next       <= TEST2;
        end if;
      when TRANSMITION_ERROR =>
        link_debug_i <= "00";
        enable_sec_board_counter <= '0';
        mem_check_ok <= '0';
        random_memory_send <= '0';
        wait_for_data_reset <= '1';
        wait_for_second_board_reset <= '0';
      when others =>
        link_debug_i <= "00";   
        enable_sec_board_counter <= '0';
        mem_check_ok <= '0';
        random_memory_send <= '0';
        wait_for_data_reset <= '1';
        wait_for_second_board_reset <= '0';
        TEST_LINK_FSM_next       <= IDLE;
    end case;
  end process FSM_TO_TEST_LINK;


  WAIT_FOR_SECOND_BOARD: up_down_counter
    generic map (
        NUMBER_OF_BITS => 32)
    port map (
        CLK       => CLK,
        RESET     => wait_for_second_board_reset,
        COUNT_OUT => wait_for_second_board_counter,
        UP_IN     => enable_sec_board_counter,
        DOWN_IN   => '0');
  wait_for_data_en <= random_memory_send and (not wait_for_data_counter(27));
  
  WAIT_FOR_DATA: up_down_counter
    generic map (
        NUMBER_OF_BITS => 28)
    port map (
        CLK       => CLK,
        RESET     => wait_for_data_reset,
        COUNT_OUT => wait_for_data_counter,
        UP_IN     => wait_for_data_en,
        DOWN_IN   => '0');

  
  WRITE_ZERO_MEM_ADDRESS: up_down_counter
    generic map (
        NUMBER_OF_BITS => 9)
    port map (
        CLK       => CLK,
        RESET     => wait_for_second_board_reset,--RESET,
        COUNT_OUT => zero_memory_write_address,
        UP_IN     => VALID_IN,
        DOWN_IN   => '0');
  
  READ_ZERO_MEM_ADDRESS: up_down_counter
    generic map (
        NUMBER_OF_BITS => 9)
    port map (
        CLK       => CLK,
        RESET     => wait_for_second_board_reset,--RESET,
        COUNT_OUT => zero_memory_read_address,
        UP_IN     => zero_memory_read,
        DOWN_IN   => '0');

 READ_RAND_MEM_ADDRESS: up_down_counter
    generic map (
        NUMBER_OF_BITS => 9)
    port map (
        CLK       => CLK,
        RESET     => wait_for_second_board_reset,--RESET,
        COUNT_OUT => random_memory_address,
        UP_IN     => random_memory_send,
        DOWN_IN   => '0');

 SEND_RAND_MEM_EN: up_down_counter
    generic map (
        NUMBER_OF_BITS => 11)
    port map (
        CLK       => CLK,
        RESET     => wait_for_second_board_reset,--RESET,
        COUNT_OUT => counter_for_send_en,
        UP_IN     => '1',
        DOWN_IN   => '0');
  
  MEM_RANDOM: mdc_dc_lvl1_dpram_rand
    port map (
        DataInA  => (others => '0'),
        DataInB  => (others => '0'),
        AddressA => random_memory_address,
        AddressB => (others => '0'),
        ClockA   => CLK,
        ClockB   => CLK,
        ClockEnA => '1',
        ClockEnB => '0',
        WrA      => '0',
        WrB      => '0',
        ResetA   => '0',
        ResetB   => '0',
        QA       => rand_memory_data_out,
        QB       => open);
    
  MEM_ZERO: mdc_dc_lvl1_dpram_zero
    port map (
        DataInA  => DATA_IN(7 downto 0),
        DataInB  => (others => '0'),
        AddressA => zero_memory_write_address,
        AddressB => zero_memory_read_address,
        ClockA   => CLK,
        ClockB   => CLK,
        ClockEnA => '1',
        ClockEnB => '1',
        WrA      => VALID_IN,
        WrB      => '0',
        ResetA   => '0',
        ResetB   => '0',
        QA       => open,
        QB       => zero_memory_data_out);
  START_COMPARISON: process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1'or  TEST_LINK_FSM_current = IDLE  then
        zero_memory_read <= '0';
      elsif rand_memory_data_out = zero_memory_data_out  then
        zero_memory_read <= '1';
      else
--        zero_memory_read <= '0';
        zero_memory_read <= zero_memory_read;
      end if;
    end if;
  end process START_COMPARISON;
  MAKE_COMPARISON: process (CLK, RESET)
  begin  
    if rising_edge(CLK) then
      if RESET = '1'or wait_for_second_board_reset = '1' then
        mem_diff <= '1';
      elsif rand_memory_data_out_synch_synch = zero_memory_data_out then
        mem_diff <= '0';
      elsif zero_memory_read_synch = '1' and rand_memory_data_out_synch_synch_synch /= zero_memory_data_out then
        mem_diff <= '1';
--        mem_diff <= '0';
      end if;
    end if;
  end process MAKE_COMPARISON;

  SYNCH_DATA: process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' or wait_for_second_board_reset = '1' then
        rand_memory_data_out_synch_synch_synch <= (others => '0');
        rand_memory_data_out_synch_synch <= (others => '0');
        rand_memory_data_out_synch <= (others => '0');
        zero_memory_read_synch <= '0';
      else
        rand_memory_data_out_synch_synch_synch<= rand_memory_data_out_synch_synch;
        rand_memory_data_out_synch_synch<= rand_memory_data_out_synch;
        rand_memory_data_out_synch <= rand_memory_data_out;
        zero_memory_read_synch <= zero_memory_read;
      end if;
    end if;
  end process SYNCH_DATA;

  
  LINK_DEBUG(3 downto 0) <= zero_memory_data_out(3 downto 0);
  LINK_DEBUG(7 downto 4) <= rand_memory_data_out_synch_synch_synch(3 downto 0);
  LINK_DEBUG(9 downto 8) <= link_debug_i;
  LINK_DEBUG(10) <= VALID_IN;
  LINK_DEBUG(11) <= random_memory_send;
  LINK_DEBUG(12) <= zero_memory_read;
  LINK_DEBUG(14 downto 13) <= LINK_INFO(2 downto 1);
  LINK_DEBUG(15) <= mem_diff;
  DATA_OUT <= rand_memory_data_out & rand_memory_data_out;
  
end link_test;
