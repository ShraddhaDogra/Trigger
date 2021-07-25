LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
library work;
use work.trb_net_std.all;


entity trb_net16_ipudata is
  generic(
    DO_CHECKS : integer range c_NO to c_YES := c_YES
    );
  port(
  --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
  -- Port to API
    API_DATA_OUT           : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    API_PACKET_NUM_OUT     : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    API_DATAREADY_OUT      : out std_logic;
    API_READ_IN            : in  std_logic;
    API_SHORT_TRANSFER_OUT : out std_logic;
    API_DTYPE_OUT          : out std_logic_vector (3 downto 0);
    API_ERROR_PATTERN_OUT  : out std_logic_vector (31 downto 0);
    API_SEND_OUT           : out std_logic;
    -- Receiver port
    API_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    API_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
    API_TYP_IN          : in  std_logic_vector (2 downto 0);
    API_DATAREADY_IN    : in  std_logic;
    API_READ_OUT        : out std_logic;
    -- APL Control port
    API_RUN_IN          : in  std_logic;
    API_SEQNR_IN        : in  std_logic_vector (7  downto 0);
    API_LENGTH_OUT      : out std_logic_vector (15 downto 0);
    MY_ADDRESS_IN       : in  std_logic_vector (15 downto 0);

    --Information received with request
    IPU_NUMBER_OUT       : out std_logic_vector (15 downto 0);
    IPU_INFORMATION_OUT  : out std_logic_vector (7  downto 0);
    IPU_READOUT_TYPE_OUT : out std_logic_vector (3  downto 0);
    IPU_CODE_OUT         : out std_logic_vector (7  downto 0);
    --start strobe
    IPU_START_READOUT_OUT: out std_logic;
    --detector data, equipped with DHDR
    IPU_DATA_IN          : in  std_logic_vector (31 downto 0);
    IPU_DATAREADY_IN     : in  std_logic;
    --no more data, end transfer, send TRM
    IPU_READOUT_FINISHED_IN : in  std_logic;
    --will be low every second cycle due to 32bit -> 16bit conversion
    IPU_READ_OUT         : out std_logic;
    IPU_LENGTH_IN        : in  std_logic_vector (15 downto 0);
    IPU_ERROR_PATTERN_IN : in  std_logic_vector (31 downto 0);

    STAT_DEBUG          : out std_logic_vector(31 downto 0)
    );
end entity;

architecture trb_net16_ipudata_arch of trb_net16_ipudata is

  signal buf_IPU_ERROR_PATTERN_IN : std_logic_vector(31 downto 0);
  signal buf_IPU_LENGTH_IN        : std_logic_vector(15 downto 0);
  signal update_buffer_length     : std_logic;
  signal update_buffer_error      : std_logic;
  signal buf_API_READ_OUT         : std_logic;
  signal buf_API_DATAREADY_OUT    : std_logic;
  signal buf_API_DATA_OUT         : std_logic_vector (c_DATA_WIDTH-1 downto 0);
  type state_t is (START, WAITING, MAKE_DHDR, READING);
  signal state : state_t;
  signal buf_NUMBER      : std_logic_vector (15 downto 0);
  signal buf_RND_CODE    : std_logic_vector (7 downto 0);
  signal buf_INFORMATION : std_logic_vector (7 downto 0);
  signal buf_TYPE        : std_logic_vector (3 downto 0);
  signal buf_START_READOUT   : std_logic;
  signal buf_IPU_READ        : std_logic;
  signal buf_API_SEND_OUT    : std_logic;
  signal waiting_word        : std_logic;
  signal packet_number       : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal reg_IPU_DATA        : std_logic_vector (15 downto 0);
  signal reg_IPU_DATA_high   : std_logic_vector (15 downto 0);
  signal saved_IPU_READOUT_FINISHED_IN : std_logic;
  signal state_bits     : std_logic_vector(2 downto 0);
  signal dhdr_counter   : std_logic_vector(1 downto 0);
  signal first_ipu_read : std_logic;
  signal ipu_read_before : std_logic := '0';
  signal second_word_waiting : std_logic;
  signal last_second_word_waiting : std_logic;
  signal make_compare : std_logic;
  signal evt_number_mismatch : std_logic;
  signal evt_code_mismatch   : std_logic;

begin


  PROC_STATE_MACHINE : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          state             <= START;
          buf_API_READ_OUT  <= '0';
          buf_START_READOUT <= '0';
          waiting_word      <= '0';
          buf_API_DATAREADY_OUT <= '0';
          first_ipu_read    <= '0';
        else
          buf_API_READ_OUT <= '1';
          first_ipu_read   <= '0';
          make_compare     <= '0';
          case state is
            when START =>
              buf_API_SEND_OUT  <= '0';
              buf_START_READOUT <= '0';
              if API_DATAREADY_IN = '1' and buf_API_READ_OUT = '1' and API_TYP_IN = TYPE_TRM then
                case API_PACKET_NUM_IN is
                  when c_F0 =>  null;  --crc field, ignore
                  when c_F1 =>  buf_RND_CODE    <= API_DATA_IN(7 downto 0);
                                buf_INFORMATION <= API_DATA_IN(15 downto 8);
                  when c_F2 =>  buf_NUMBER      <= API_DATA_IN;
                  when c_F3 =>  buf_TYPE        <= API_DATA_IN(3 downto 0);
                                buf_START_READOUT   <= '1';
                                state               <= WAITING;
                  when others => null;
                end case;
              end if;

            when WAITING =>
              if IPU_DATAREADY_IN = '1' and API_READ_IN = '1' then
                first_ipu_read <= '1'; -- read signal for DHDR
                state          <= MAKE_DHDR;
                dhdr_counter   <= (others => '0');
                make_compare   <= '1';
                buf_API_DATA_OUT  <= IPU_DATA_IN(31 downto 16);
              end if;

            when MAKE_DHDR => -- send DHDR packet
              buf_API_SEND_OUT <= '1';
              buf_API_DATAREADY_OUT <= '1';
              if buf_API_DATAREADY_OUT = '1' and API_READ_IN = '1' then
                dhdr_counter <= dhdr_counter + 1;
                case dhdr_counter is
                  when "00" =>  --1st dhdr from apl
                    buf_API_DATA_OUT  <= reg_IPU_DATA;
                  when "01" =>  --2nd dhdr from apl
                    buf_API_DATA_OUT <= buf_IPU_LENGTH_IN;
                  when "10" =>  --dhdr length
                    buf_API_DATA_OUT <= MY_ADDRESS_IN;
                  when "11" =>  --dhdr source address
                    state <= READING;
                    buf_API_DATAREADY_OUT <= '0';
                  when others =>
                    null; --turn into a black hole
                end case;
              end if;

            when READING =>

              buf_API_DATAREADY_OUT <= IPU_DATAREADY_IN or waiting_word or ipu_read_before or second_word_waiting;

              if API_READ_IN = '1' then
                ipu_read_before <= '0';
              end if;

              if buf_API_DATAREADY_OUT = '1' and API_READ_IN = '1' then
                waiting_word <= '0';
              end if;

              if IPU_DATAREADY_IN = '1' and waiting_word = '0' and buf_IPU_READ = '1' then
                buf_API_DATA_OUT <= IPU_DATA_IN(31 downto 16);
                waiting_word <= '1';
                ipu_read_before <= '1';
              elsif ipu_read_before = '1' and API_READ_IN = '0' then
                buf_API_DATA_OUT <= reg_IPU_DATA_high;
              else
                buf_API_DATA_OUT <= reg_IPU_DATA;
              end if;

              if saved_IPU_READOUT_FINISHED_IN = '1' and waiting_word = '0' and IPU_DATAREADY_IN = '0' and buf_API_DATAREADY_OUT = '0' then
                state <= START;
              end if;

            when others =>
              state <= START;
          end case;
        end if;
      end if;
    end process;

  buf_IPU_READ <= '1' when API_READ_IN = '1'  and waiting_word = '0' and second_word_waiting = '0' and (state = READING or first_ipu_read = '1') else '0';

  update_buffer_length <= '1' when (state = WAITING and IPU_DATAREADY_IN = '1' and API_READ_IN = '1') else '0';
  update_buffer_error  <= '1' when (state = READING and IPU_READOUT_FINISHED_IN = '1') else '0';

---------------------------------------------------------------------
--second half of 32bit word has to be sent
---------------------------------------------------------------------

  PROC_second_word : process(waiting_word, buf_API_DATAREADY_OUT, API_READ_IN, last_second_word_waiting, RESET)
    begin
      if RESET = '1' then
        second_word_waiting <= '0';
      elsif waiting_word = '1' then
        second_word_waiting <= '1';
      elsif buf_API_DATAREADY_OUT = '1' and API_READ_IN = '1' then
        second_word_waiting <= '0';
      else
        second_word_waiting <= last_second_word_waiting;
      end if;
    end process;

  PROC_last_second_word : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          last_second_word_waiting <= '0';
        else
          last_second_word_waiting <= second_word_waiting;
        end if;
      end if;
    end process;


---------------------------------------------------------------------
--store length and error pattern input
---------------------------------------------------------------------
  PROC_buffer_inputs : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          buf_IPU_LENGTH_IN <= (others => '1');
          buf_IPU_ERROR_PATTERN_IN <= (others => '0');
        else
          if update_buffer_length = '1' then
            buf_IPU_LENGTH_IN <= IPU_LENGTH_IN;
          elsif buf_IPU_READ = '1' and IPU_DATAREADY_IN = '1' and first_ipu_read = '0' then
            buf_IPU_LENGTH_IN <= buf_IPU_LENGTH_IN - 1;
          end if;
          if update_buffer_error = '1' then
            buf_IPU_ERROR_PATTERN_IN <= IPU_ERROR_PATTERN_IN;
            if DO_CHECKS = c_YES then
              buf_IPU_ERROR_PATTERN_IN(16) <= evt_number_mismatch;
              buf_IPU_ERROR_PATTERN_IN(17) <= evt_code_mismatch;
              buf_IPU_ERROR_PATTERN_IN(18) <= or_all(buf_IPU_LENGTH_IN);
            end if;
          end if;
        end if;
      end if;
    end process;

---------------------------------------------------------------------
--store ipu data
---------------------------------------------------------------------
  PROC_store_IPU_input : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          reg_IPU_DATA      <= (others => '0');
          reg_IPU_DATA_high <= (others => '0');
        elsif IPU_DATAREADY_IN = '1' and buf_IPU_READ = '1' then
          reg_IPU_DATA      <= IPU_DATA_IN(15 downto 0);
          reg_IPU_DATA_high <= IPU_DATA_IN(31 downto 16);
        end if;
      end if;
    end process;


---------------------------------------------------------------------
--Compare event information
---------------------------------------------------------------------
  gen_check : if DO_CHECKS = c_YES generate
    PROC_compare : process(CLK)
      begin
        if rising_edge(CLK) then
          if buf_START_READOUT = '0' then
            evt_number_mismatch <= '0';
            evt_code_mismatch   <= '0';
          elsif make_compare = '1' then
            if IPU_DATA_IN(15 downto 0) /= buf_NUMBER then     --was reg_
              evt_number_mismatch <= '1';
            end if;
            if IPU_DATA_IN(23 downto 16) /= buf_RND_CODE then  --was reg_
              evt_code_mismatch <= '1';
            end if;
          end if;
        end if;
      end process;
  end generate;

---------------------------------------------------------------------
--User finished readout yet?
---------------------------------------------------------------------
  PROC_get_end_of_data : process(CLK)
    begin
      if rising_edge(CLK) then
        if buf_START_READOUT = '0' then
          saved_IPU_READOUT_FINISHED_IN <= '0';
        elsif IPU_READOUT_FINISHED_IN = '1' then
          saved_IPU_READOUT_FINISHED_IN <= '1';
        end if;
      end if;
    end process;

---------------------------------------------------------------------
--Gen. Packet Number
---------------------------------------------------------------------
  PROC_packet_num : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          packet_number <= c_F0;
        elsif API_READ_IN = '1' and buf_API_DATAREADY_OUT = '1' then
          packet_number <= packet_number + 1;
          if packet_number = c_F3 then
            packet_number <= c_F0;
          end if;
        end if;
      end if;
    end process;

---------------------------------------------------------------------
--Connect Outputs
---------------------------------------------------------------------

  API_ERROR_PATTERN_OUT <= buf_IPU_ERROR_PATTERN_IN;
  API_LENGTH_OUT        <= buf_IPU_LENGTH_IN+2;
  API_READ_OUT          <= buf_API_READ_OUT;
  API_DATAREADY_OUT     <= buf_API_DATAREADY_OUT;
  API_DATA_OUT          <= buf_API_DATA_OUT;
  API_PACKET_NUM_OUT    <= packet_number;
  API_SEND_OUT          <= buf_API_SEND_OUT;
  API_SHORT_TRANSFER_OUT<= '0';
  API_DTYPE_OUT         <= buf_TYPE;

  IPU_NUMBER_OUT        <= buf_NUMBER;
  IPU_START_READOUT_OUT <= buf_START_READOUT;
  IPU_READ_OUT          <= buf_IPU_READ;
  IPU_INFORMATION_OUT   <= buf_INFORMATION;
  IPU_READOUT_TYPE_OUT  <= buf_TYPE;
  IPU_CODE_OUT          <= buf_RND_CODE;

---------------------------------------------------------------------
--Debugging
---------------------------------------------------------------------
  STAT_DEBUG(2 downto 0)  <= state_bits;
  STAT_DEBUG(31 downto 3) <= (others => '0');

  state_bits(0) <= '1' when state = START else '0';
  state_bits(1) <= '1' when state = WAITING else '0';
  state_bits(2) <= '1' when state = READING else '0';



end architecture;
