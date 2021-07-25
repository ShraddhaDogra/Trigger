LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.all;


library work;
use work.trb_net_std.all;


entity onewire_multi is
  generic(
    USE_TEMPERATURE_READOUT : integer range 0 to 1 := 1;
    PARASITIC_MODE : integer range 0 to 1 := c_NO;
    N_SENSORS  : integer := 10;  -- Number of connected sensors
    CLK_PERIOD : integer := 10;  --clk period in ns
    ROM_ADR_0  : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADR_1  : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADR_2  : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADR_3  : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADR_4  : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADR_5  : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADR_6  : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADR_7  : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADR_8  : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADR_9  : std_logic_vector(63 downto 0) := x"0000000000000000";
    ROM_ADR_10 : std_logic_vector(63 downto 0) := x"0000000000000000"

    );
  port(
    CLK      : in std_logic;
    RESET    : in std_logic;
    READOUT_ENABLE_IN : in std_logic := '1';
    --connection to 1-wire interface
    ONEWIRE  : inout std_logic;
    --connection to id ram, according to memory map in TrbNetRegIO
    DATA_OUT : out std_logic_vector(15 downto 0);
    --ADDR_OUT : out std_logic_vector(2 downto 0);
    --WRITE_OUT: out std_logic;
    TEMP_OUT   : out std_logic_vector(11 downto 0);
    TEMP_OUT_1 : out std_logic_vector(11 downto 0) := "111111111111";
    TEMP_OUT_2 : out std_logic_vector(11 downto 0) := "111111111111";
    TEMP_OUT_3 : out std_logic_vector(11 downto 0) := "111111111111";
    TEMP_OUT_4 : out std_logic_vector(11 downto 0) := "111111111111";
    TEMP_OUT_5 : out std_logic_vector(11 downto 0) := "111111111111";
    TEMP_OUT_6 : out std_logic_vector(11 downto 0) := "111111111111";
    TEMP_OUT_7 : out std_logic_vector(11 downto 0) := "111111111111";
    TEMP_OUT_8 : out std_logic_vector(11 downto 0) := "111111111111";
    TEMP_OUT_9 : out std_logic_vector(11 downto 0) := "111111111111";
    TEMP_OUT_10 : out std_logic_vector(11 downto 0) := "111111111111";
    ID_OUT   : out std_logic_vector(63 downto 0);
    STAT     : out std_logic_vector(31 downto 0);
    SENS_CNT : out std_logic_vector( 7 downto 0)
    );
end entity;


architecture onewire_multi_arch of onewire_multi is
  constant MAX_COUNTER : integer := 2**28-1;
  type state_t is (START, IDLE, SEND_RESET, WAIT_AFTER_RESET, SEND_ROM_COMMAND, READ_WAIT,
                   WRITE_START, WRITE_WAIT, READ_BIT, READ_READ_ROM, SEND_CONV_TEMP,
                   READ_CONV_TEMP, SEND_READ_TEMP, READ_READ_TEMP,SEND_CURR_ROM);
  signal state, next_state : state_t;
  signal reset_i : std_logic;
  signal state_bits : std_logic_vector(3 downto 0);
  signal timecounter : integer range 0 to MAX_COUNTER;
  signal bitcounter  : integer range 0 to 127;
  signal sensor_cnt  : integer range 0 to 15;
  signal inc_sensor_cnt : std_logic;
  signal bitcounter_vector : std_logic_vector(6 downto 0);
  signal inc_bitcounter, reset_bitcounter : std_logic;
  signal output, next_output      : std_logic;
  signal input       : std_logic;
  signal reset_timecounter : std_logic;
  signal send_bit, next_send_bit : std_logic;
  signal recv_bit,next_recv_bit : std_logic;
  signal recv_bit_ready, next_recv_bit_ready : std_logic;
  signal output_tmp, next_output_tmp : std_logic;
  signal word : std_logic_vector(15 downto 0);
  signal ram_addr : std_logic_vector(2 downto 0) := "000";
  signal ram_wr : std_logic;
  signal send_match_rom, next_send_match_rom : std_logic;
  signal conv_temp, next_conv_temp : std_logic;
  signal reading_temp, next_reading_temp : std_logic;
  signal skip_rom, next_skip_rom : std_logic;
  signal buf_TEMP_OUT : std_logic_vector(11 downto 0);
  signal buf_STAT : std_logic;
  signal strong_pullup, next_strong_pullup : std_logic;
  signal rom_addr : std_logic_vector(63 downto 0); --:= x"52031646cd5fff28";--530416523728FF28
  signal rom_addr_0 : std_logic_vector(63 downto 0) := ROM_ADR_0;--x"530416523728FF28";--530416523728FF28
  signal rom_addr_1 : std_logic_vector(63 downto 0) := ROM_ADR_1;--x"BB04165233BFFF28";
  signal rom_addr_2 : std_logic_vector(63 downto 0) := ROM_ADR_2;--x"52031646CD5FFF28";
  signal rom_addr_3 : std_logic_vector(63 downto 0) := ROM_ADR_3;--x"EC0416525116FF28";
  signal rom_addr_4 : std_logic_vector(63 downto 0) := ROM_ADR_4;--x"050416523379FF28";
  signal rom_addr_5 : std_logic_vector(63 downto 0) := ROM_ADR_5;--x"E2041651AEA5FF28";
  signal rom_addr_6 : std_logic_vector(63 downto 0) := ROM_ADR_6;--x"940000092C3B2F28";
  signal rom_addr_7 : std_logic_vector(63 downto 0) := ROM_ADR_7;--x"4B0000092D22BD28";
  signal rom_addr_8 : std_logic_vector(63 downto 0) := ROM_ADR_8;--x"C30000092B07EA28";
  signal rom_addr_9 : std_logic_vector(63 downto 0) := ROM_ADR_9;--x"780000092A277628";
  signal rom_addr_10 : std_logic_vector(63 downto 0) := ROM_ADR_10;

  signal sending_rom, next_sending_rom : std_logic;
begin							

  ONEWIRE <= '0' when output = '0' else '1' when strong_pullup = '1' else 'Z';
  input <= ONEWIRE;
  reset_i <= RESET when rising_edge(CLK);

  bitcounter_vector <= conv_std_logic_vector(bitcounter,7);

  process(state, timecounter, bitcounter_vector, input, readout_enable_in,
          send_bit, output_tmp, skip_rom, recv_bit, conv_temp, reading_temp)
    begin
      next_state <= state;
      next_output <= '1';
      reset_timecounter <= '0';
      reset_bitcounter <= '0';
      next_output_tmp <= output_tmp;
      inc_bitcounter <= '0';
      inc_sensor_cnt <= '0';
      next_send_bit <= send_bit;
      next_recv_bit_ready <= '0';
      next_send_match_rom <= send_match_rom;
      next_conv_temp <= conv_temp;
      next_reading_temp <= reading_temp;
      next_recv_bit <= recv_bit;
      next_skip_rom <= skip_rom;
      next_sending_rom <= sending_rom;
      next_strong_pullup <= '0';
      case state is
--reset / presence
        when START =>
          if READOUT_ENABLE_IN = '1' then
            next_state <= IDLE;
            reset_timecounter <= '1';
          end if;
        when IDLE =>
          if is_time_reached(timecounter,640000,CLK_PERIOD) = '1' then
            next_state <= SEND_RESET;
            reset_timecounter <= '1';
          end if;
        when SEND_RESET =>
          next_output <= '0';
          if is_time_reached(timecounter,640000,CLK_PERIOD) = '1' then
            reset_timecounter <= '1';
            next_state <= WAIT_AFTER_RESET;
          end if;
        when WAIT_AFTER_RESET =>
          if is_time_reached(timecounter,640000,CLK_PERIOD) = '1' then --1200
            reset_timecounter <= '1';
            next_state <= SEND_ROM_COMMAND;
          end if;
          --presence is not checked
--sending rom commands
        when SEND_ROM_COMMAND =>
          next_skip_rom <= not send_match_rom and not bitcounter_vector(3);
          inc_bitcounter <= '1';
          next_state <= WRITE_START;

          if send_match_rom = '1' then
            next_send_bit <= not bitcounter_vector(0); --this is x55, lsb first
          else
            next_send_bit <= bitcounter_vector(1);     --this is xCC, lsb first
          end if;

          if bitcounter_vector(3) = '1' then  --send 8 bit
            if send_match_rom = '1' then
              next_sending_rom <= '1';
              next_state <= SEND_CURR_ROM; --jump to send of current ROM Address
            elsif conv_temp = '1' then
              next_state <= SEND_CONV_TEMP;
            else
              next_state <= SEND_READ_TEMP;
            end if;
            reset_bitcounter <= '1';
          end if;

--sending of current ROM Address
        when SEND_CURR_ROM =>
          if  bitcounter < 64 then 
	    next_send_bit <= rom_addr(bitcounter);
          else
	    next_send_bit <= '0';
          end if;
                               
          inc_bitcounter <= '1';
          if bitcounter_vector(6) = '1' then  --send 64 bit
            next_state <= SEND_READ_TEMP;
            reset_bitcounter <= '1';
            reset_timecounter <= '1';
            next_recv_bit <= '0';
            next_sending_rom <= '0';
            next_send_match_rom <= '0';  --could be erased
            next_conv_temp <= '0'; --could be erased
            next_reading_temp <= '1';
          else
            next_state <= WRITE_START;
          end if;

--sending sensor commands
        when SEND_CONV_TEMP =>
          next_send_bit <= bitcounter_vector(1) and not bitcounter_vector(0);
                                                     --this is x44, lsb first
          inc_bitcounter <= '1';
          if bitcounter_vector(3) = '1' then  --send 8 bit
            next_state <= READ_CONV_TEMP;
            reset_bitcounter <= '1';
            reset_timecounter <= '1';
            next_recv_bit <= '0';
          else
            next_state <= WRITE_START;
          end if;

        when SEND_READ_TEMP =>
          if bitcounter_vector(2 downto 0) = "000" or bitcounter_vector(2 downto 0) = "110" then
            next_send_bit <= '0';                   --this is xBE, lsb first
          else
            next_send_bit <= '1';
          end if;
          inc_bitcounter <= '1';
          if bitcounter_vector(3) = '1' then  --send 8 bit
            next_state <= READ_READ_TEMP;
            reset_bitcounter <= '1';
            next_recv_bit <= '0';
          else
            next_state <= WRITE_START;
          end if;

--reading rom answers
        when READ_READ_ROM =>
          inc_bitcounter <= '1';
          if bitcounter_vector(6) = '1' then --read 64 bit
            next_state <= IDLE;
            if USE_TEMPERATURE_READOUT = 1 then
              next_send_match_rom  <= '1';
              next_conv_temp <= '1';
            end if;
            reset_bitcounter <= '1';
          else
            next_state <= READ_BIT;
          end if;

--reading sensor answers
        when READ_CONV_TEMP => --waiting for end of conversion
            if PARASITIC_MODE = c_YES then
              next_strong_pullup <= '1';
            end if;
            if is_time_reached(timecounter,130000000,CLK_PERIOD) = '1' then
              next_state <= IDLE;
              if USE_TEMPERATURE_READOUT = 1 then
                next_conv_temp <= '0';
                --next_reading_temp <= '1';
                next_reading_temp <= '0';
                -- go to single sensor readout
                next_send_match_rom <= '1';
              end if;
            end if;


        when READ_READ_TEMP =>
          inc_bitcounter <= '1';
          if bitcounter_vector(3 downto 2) = "11" then --read 12 bit
            next_state <= START;-- when sensor_cnt = N_SENSORS else
                          --IDLE;
            inc_sensor_cnt <= '1';
            if USE_TEMPERATURE_READOUT = 1 then                        
              if sensor_cnt = (N_SENSORS-1) then 
		next_send_match_rom <= '0';
		next_conv_temp      <= '1';
	      else
		next_send_match_rom <= '1';
		next_conv_temp      <= '0';
              end if;
              next_reading_temp   <= '0';
            end if;
            reset_bitcounter <= '1';
          else
            next_state <= READ_BIT;
          end if;


--write cycle
        when WRITE_START =>
          next_output <= output_tmp;
          if is_time_reached(timecounter,1200,CLK_PERIOD) = '1' then
            next_output_tmp <= send_bit;
          end if;
          if is_time_reached(timecounter,80000,CLK_PERIOD) = '1' then
            next_state <= WRITE_WAIT;
            next_output_tmp <= '0';
            reset_timecounter <= '1';
          end if;
        when WRITE_WAIT =>
          if is_time_reached(timecounter,1200,CLK_PERIOD) = '1' then
            reset_timecounter <= '1';
            if sending_rom = '1' then 
              next_state <= SEND_CURR_ROM;
            elsif skip_rom = '1' or send_match_rom = '1' then
              next_state <= SEND_ROM_COMMAND;
            elsif conv_temp = '1' then
              next_state <= SEND_CONV_TEMP;
            elsif reading_temp = '1' then
              next_state <= SEND_READ_TEMP;
            end if;
          end if;

--read cycle
        when READ_BIT =>
          next_output <= output_tmp;
          if is_time_reached(timecounter,1200,CLK_PERIOD) = '1' then
            next_output_tmp <= '1';
          end if;
          if is_time_reached(timecounter,10000,CLK_PERIOD) = '1' then
            next_recv_bit <= input;
            next_recv_bit_ready <= '1';
            next_state <= READ_WAIT;
          end if;
        when READ_WAIT =>
          if is_time_reached(timecounter,80000,CLK_PERIOD) = '1' then
            reset_timecounter <= '1';
            next_output_tmp <= '0';
            --if send_rom = '1' then --todo
            --  next_state <= READ_READ_ROM;
            --els
            if conv_temp = '1' then
              next_state <= READ_CONV_TEMP;
            else
              next_state <= READ_READ_TEMP;
            end if;
          end if;

        when others =>
          next_state <= START;
      end case;
    end process;

--counting time and bits
  process(CLK)
    begin
      if rising_edge(CLK) then
        if reset_timecounter = '1' then
          timecounter <= 0;
        else
          timecounter <= timecounter + 1;
        end if;
      end if;
    end process;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if reset_bitcounter = '1' then
          bitcounter <= 0;
        elsif inc_bitcounter = '1' then
          bitcounter <= bitcounter + 1;
        end if;
      end if;
    end process;
    
    
  process(CLK)
    begin
      if rising_edge(CLK) then
        if inc_sensor_cnt = '1' then 
          if sensor_cnt >= (N_SENSORS-1) then
            sensor_cnt <= 0;
          else
            sensor_cnt <= sensor_cnt + 1;
          end if;  
        end if;  
        
        if sensor_cnt = 0 then
          rom_addr <= rom_addr_0;
        elsif sensor_cnt = 1 then
          rom_addr <= rom_addr_1;
	elsif sensor_cnt = 2 then
          rom_addr <= rom_addr_2;
        elsif sensor_cnt = 3 then
          rom_addr <= rom_addr_3;
        elsif sensor_cnt = 4 then
          rom_addr <= rom_addr_4;
        elsif sensor_cnt = 5 then
          rom_addr <= rom_addr_5;
        elsif sensor_cnt = 6 then
          rom_addr <= rom_addr_6;
        elsif sensor_cnt = 7 then
          rom_addr <= rom_addr_7;
        elsif sensor_cnt = 8 then
          rom_addr <= rom_addr_8;
        elsif sensor_cnt = 9 then
          rom_addr <= rom_addr_9;
        else 
         rom_addr <= x"0000000000000000";
        end if;
      end if;
    end process;

--registers for state machine
  process(CLK)
    begin
      if rising_edge(CLK) then
        if reset_i = '1' then
          send_bit <= '0';
          output_tmp <= '0';
          recv_bit <= '0';
          strong_pullup <= '0';
          state <= START;
          sending_rom <= '0';
        else
          recv_bit_ready <= next_recv_bit_ready;
          state <= next_state;
          send_bit <= next_send_bit;
          output <= next_output;
          output_tmp <= next_output_tmp;
          recv_bit <= next_recv_bit;
          strong_pullup <= next_strong_pullup;
          sending_rom <= next_sending_rom;
        end if;
      end if;
    end process;

--save current kind of operation
  gen_stat_sig : if USE_TEMPERATURE_READOUT = 1 generate
    process(CLK)
      begin
        if rising_edge(CLK) then
          if reset_i = '1' then
            send_match_rom <= '0';
            conv_temp <= '1';
            reading_temp <= '0';
            skip_rom <= '1';
          else
            send_match_rom <= next_send_match_rom;
            conv_temp <= next_conv_temp;
            reading_temp <= next_reading_temp;
            skip_rom <= next_skip_rom;
          end if;
        end if;
      end process;
  end generate;
  gen_stat_sig_1 : if USE_TEMPERATURE_READOUT = 0 generate
    send_match_rom <= '0';
    conv_temp <= '0';
    reading_temp <= '0';
    skip_rom <= '0';
  end generate;


--saving received data
  process(CLK)
    begin
      if rising_edge(CLK) then
        if reset_i = '1' then
          buf_TEMP_OUT <= (others => '0');
          ram_addr <= (others => '0');
          buf_STAT <= '0';
          word <= (others => '0');
        else
          -- debug
          ram_wr <= '0';
          -- END debug
          if (recv_bit_ready = '1') and (reading_temp = '1') then
            buf_STAT <= not buf_STAT;
            -- debug
            ram_addr(1 downto 0) <= (bitcounter_vector(5 downto 4))-1;
            ram_addr(2) <= '0';
            -- END debug
            word(14 downto 0) <= word(15 downto 1);
            word(15) <= recv_bit;
            -- debug
            if bitcounter_vector(3 downto 0) = "0000" and send_match_rom = '1' then
              ram_wr <= '1';
            end if;
            -- END debug
            if bitcounter_vector(3 downto 0) = "1100" and reading_temp = '1' then
              buf_TEMP_OUT <= recv_bit & word(15 downto 5); --todo
              if sensor_cnt = 0 then
		TEMP_OUT <= recv_bit & word(15 downto 5);
	      elsif sensor_cnt = 1 then
		TEMP_OUT_1 <= recv_bit & word(15 downto 5);
	      elsif sensor_cnt = 2 then
		TEMP_OUT_2 <= recv_bit & word(15 downto 5);
	      elsif sensor_cnt = 3 then
		TEMP_OUT_3 <= recv_bit & word(15 downto 5);
	      elsif sensor_cnt = 4 then
		TEMP_OUT_4 <= recv_bit & word(15 downto 5);
	      elsif sensor_cnt = 5 then
		TEMP_OUT_5 <= recv_bit & word(15 downto 5);
	      elsif sensor_cnt = 6 then
		TEMP_OUT_6 <= recv_bit & word(15 downto 5);
	      elsif sensor_cnt = 7 then
		TEMP_OUT_7 <= recv_bit & word(15 downto 5);
	      elsif sensor_cnt = 8 then
		TEMP_OUT_8 <= recv_bit & word(15 downto 5);
	      elsif sensor_cnt = 9 then
		TEMP_OUT_9 <= recv_bit & word(15 downto 5);
	      else
	        TEMP_OUT_10 <= recv_bit & word(15 downto 5);
	      end if;
	      
            end if;
          end if;
        end if;
      end if;
    end process;

  --ADDR_OUT <= ram_addr;
  DATA_OUT <= word;
  --WRITE_OUT <= ram_wr;

  THE_TMP_OUT : process begin
   wait until rising_edge(CLK);
    
  end process;
  
  PROC_STORE_ID : process begin
    wait until rising_edge(CLK);
    if ram_wr = '1' then
      case ram_addr is
        when "000" => ID_OUT(15 downto  0) <= word;
        when "001" => ID_OUT(31 downto 16) <= word;
        when "010" => ID_OUT(47 downto 32) <= word;
        when "011" => ID_OUT(63 downto 48) <= word;
        when others => null;
      end case;
    end if;
  end process;

  state_bits <= x"0" when state = START else
                x"1" when state = IDLE else
                x"2" when state = SEND_RESET else
                x"3" when state = WAIT_AFTER_RESET else
                x"4" when state = SEND_ROM_COMMAND else
                x"5" when state = READ_WAIT else
                x"6" when state = WRITE_START else
                x"7" when state = WRITE_WAIT else
                x"8" when state = READ_BIT else
                x"9" when state = SEND_CURR_ROM else
                x"a" when state = SEND_CONV_TEMP else
                x"b" when state = READ_CONV_TEMP else
                x"c" when state = SEND_READ_TEMP else
                x"d" when state = READ_READ_TEMP else
                x"F";


  STAT(0) <= '0';
  STAT(1) <= '0' when input = '0' else '1';
  STAT(2) <= output;
  STAT(3) <= send_match_rom;
  STAT(4) <= skip_rom;
  STAT(5) <= conv_temp;
  STAT(6) <= reading_temp;
  STAT(7) <= buf_STAT;
  STAT(11 downto 8) <= bitcounter_vector(3 downto 0);
  STAT(15 downto 12)<= state_bits;
  STAT(16)<= next_strong_pullup;
  STAT(31 downto 17) <= (others => '0');

  SENS_CNT <= std_logic_vector(to_unsigned(sensor_cnt,8));
end architecture;
