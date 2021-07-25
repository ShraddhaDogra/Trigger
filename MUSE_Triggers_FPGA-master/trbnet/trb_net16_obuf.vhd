LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


entity trb_net16_obuf is
  generic (
    USE_ACKNOWLEDGE  : integer range 0 to 1 := std_USE_ACKNOWLEDGE;
    USE_CHECKSUM     : integer range 0 to 1 := c_YES;
    DATA_COUNT_WIDTH : integer range 1 to 7 := std_DATA_COUNT_WIDTH;
                           -- max used buffer size is 2**DATA_COUNT_WIDTH.
    SBUF_VERSION     : integer range 0 to 6 := std_SBUF_VERSION
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_OUT  : out std_logic;
    MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    MED_READ_IN        : in  std_logic;
    -- Internal direction port
    INT_DATAREADY_IN   : in  std_logic;
    INT_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    INT_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
    INT_READ_OUT       : out std_logic;
    -- Status and control port
    STAT_BUFFER       : out std_logic_vector (31 downto 0);
    CTRL_BUFFER       : in  std_logic_vector (31 downto 0);
    CTRL_SETTINGS     : in  std_logic_vector (15 downto 0);
    STAT_DEBUG        : out std_logic_vector (31 downto 0);
    TIMER_TICKS_IN    : in  std_logic_vector (1 downto 0)
    );
end entity;

architecture trb_net16_obuf_arch of trb_net16_obuf is

  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  --attribute HGROUP of trb_net16_obuf_arch : architecture  is "OBUF_group";
  attribute syn_hier : string;
  attribute syn_hier of trb_net16_obuf_arch : architecture is "flatten, firm";
  attribute syn_sharing : string;
  attribute syn_sharing of trb_net16_obuf_arch : architecture is "off";


  signal current_output_data_buffer      : std_logic_vector (c_DATA_WIDTH-1 downto 0);
  signal current_output_num_buffer       : std_logic_vector (c_NUM_WIDTH-1 downto 0);
  signal current_ACK_word                : std_logic_vector (15 downto 0);
  signal current_EOB_word                : std_logic_vector (15 downto 0);
  signal current_DATA_word               : std_logic_vector (15 downto 0);
  signal current_NOP_word                : std_logic_vector (15 downto 0);
  signal comb_dataready                  : std_logic;
  signal comb_next_read                  : std_logic;
  signal sbuf_free                       : std_logic;
  signal reg_INT_READ_OUT                : std_logic;
  signal next_INT_READ_OUT               : std_logic;
  signal next_SEND_ACK_IN                : std_logic;
  signal reg_SEND_ACK_IN                 : std_logic;
  signal send_ACK                        : std_logic;
  signal send_EOB                        : std_logic;
  signal send_DATA                       : std_logic;
  signal CURRENT_DATA_COUNT              : unsigned (DATA_COUNT_WIDTH-1  downto 0);
  signal max_DATA_COUNT_minus_one        : unsigned (DATA_COUNT_WIDTH-1 downto 0);
  signal TRANSMITTED_BUFFERS             : unsigned (1 downto 0);
  signal inc_TRANSMITTED_BUFFERS         : std_logic;
  signal decrease_TRANSMITTED_BUFFERS    : std_logic;

  signal SEND_BUFFER_SIZE_IN             : std_logic_vector (3 downto 0);
  signal REC_BUFFER_SIZE_IN              : std_logic_vector (3 downto 0);
  signal SEND_ACK_IN                     : std_logic;
  signal GOT_ACK_IN                      : std_logic;

  signal transfer_counter                : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal saved_packet_type               : std_logic_vector(2 downto 0);
  signal reg_SEND_ACK_IN_2               : std_logic;
  signal next_SEND_ACK_IN_2              : std_logic;

  type sending_state_t is (idle, sending_ack, sending_eob);
  signal next_sending_state              : sending_state_t;
  signal sending_state                   : sending_state_t;

  signal reset_DATA_COUNT                : std_logic;
  signal inc_DATA_COUNT                  : std_logic;

  signal CRC_RESET                       : std_logic;
  signal CRC_enable                      : std_logic;
  signal CRC                             : std_logic_vector(15 downto 0);
  signal buf_MED_DATAREADY_OUT           : std_logic;
  signal buf_MED_PACKET_NUM_OUT          : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal sbuf_status                     : std_logic;
  signal crc_match                       : std_logic;
  signal buffer_number                   : unsigned(15 downto 0);

  signal buf_INT_READ_OUT                : std_logic;
  signal int_dataready_in_i              : std_logic;
  signal int_data_in_i                   : std_logic_vector(15 downto 0);
  signal int_packet_num_in_i             : std_logic_vector(2 downto 0);
  signal last_buf_INT_READ_OUT           : std_logic;

  signal wait_for_ack_timeout            : std_logic;
  signal wait_for_ack_counter            : unsigned(8 downto 0);
  signal wait_for_ack_max_bit            : std_logic_vector(2 downto 0);
  signal timer_tick                      : std_logic;

  signal reset_transmitted_buffers       : std_logic;
  signal current_timeout_value           : unsigned(15 downto 0);

  attribute syn_preserve : boolean;
  attribute syn_keep     : boolean;
  attribute syn_preserve of wait_for_ack_timeout : signal is true;
  attribute syn_preserve of wait_for_ack_counter : signal is true;
  attribute syn_preserve of wait_for_ack_max_bit : signal is true;
  attribute syn_preserve of timer_tick           : signal is true;
  attribute syn_keep of wait_for_ack_timeout     : signal is true;
  attribute syn_keep of wait_for_ack_counter     : signal is true;
  attribute syn_keep of wait_for_ack_max_bit     : signal is true;
  attribute syn_keep of timer_tick               : signal is true;


begin

---------------------------------------------------------------------
-- read signal to internal logic
---------------------------------------------------------------------
  buf_INT_READ_OUT <= not int_dataready_in_i or reg_INT_READ_OUT;

---------------------------------------------------------------------
-- I/O
---------------------------------------------------------------------
  INT_READ_OUT       <= buf_INT_READ_OUT;
  MED_PACKET_NUM_OUT <= buf_MED_PACKET_NUM_OUT;
  MED_DATAREADY_OUT  <= buf_MED_DATAREADY_OUT;

---------------------------------------------------------------------
-- Register inputs from internal logic
---------------------------------------------------------------------

  SYNC_INT_DATA_INPUTS : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          int_dataready_in_i <= '0';
        elsif buf_INT_READ_OUT = '1' then --reply_dataready_in_i(i) = '0' or buf_REPLY_READ_OUT(i) = '1' then
          int_dataready_in_i  <= INT_DATAREADY_IN;
          int_data_in_i       <= INT_DATA_IN;
          int_packet_num_in_i <= INT_PACKET_NUM_IN;
        end if;
      end if;
    end process;

  proc_SAVE_INT_READ_OUT : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          last_buf_INT_READ_OUT <= '0';
        else
          last_buf_INT_READ_OUT <= buf_INT_READ_OUT;
        end if;
      end if;
    end process;

---------------------------------------------------------------------
-- The SBUF to buffer data to the multiplexer
---------------------------------------------------------------------
  THE_SBUF : trb_net16_sbuf
    generic map (
      VERSION => SBUF_VERSION
      )
    port map (
      CLK   => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      COMB_DATAREADY_IN => comb_dataready,
      COMB_next_READ_OUT => comb_next_read,
      COMB_READ_IN => '1',
      COMB_DATA_IN => current_output_data_buffer,
      COMB_PACKET_NUM_IN => current_output_num_buffer,
      SYN_DATAREADY_OUT => buf_MED_DATAREADY_OUT,
      SYN_DATA_OUT => MED_DATA_OUT,
      SYN_PACKET_NUM_OUT => buf_MED_PACKET_NUM_OUT,
      SYN_READ_IN => MED_READ_IN,
      DEBUG_OUT   => STAT_DEBUG(15 downto 0),
      STAT_BUFFER => sbuf_status
      );

   proc_delay_sbuf_free : process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            sbuf_free <= '0';
          else
            sbuf_free <= comb_next_read;
          end if;
        end if;
      end process;

---------------------------------------------------------------------
-- Make control and status signals based on if ack. is used or not
---------------------------------------------------------------------
  gen1 : if USE_ACKNOWLEDGE = 1 generate
    decrease_TRANSMITTED_BUFFERS <= GOT_ACK_IN;
    send_ACK                     <= SEND_ACK_IN or reg_SEND_ACK_IN or reg_SEND_ACK_IN_2;
    next_SEND_ACK_IN_2           <= (reg_SEND_ACK_IN_2 or SEND_ACK_IN) and reg_SEND_ACK_IN;
    send_DATA                    <= not TRANSMITTED_BUFFERS(1);
    send_EOB                     <= '1' when (CURRENT_DATA_COUNT = max_DATA_COUNT_minus_one and saved_packet_type /= TYPE_TRM) else '0';
    -- buffer registers
    STAT_BUFFER(1 downto 0)      <= std_logic_vector(TRANSMITTED_BUFFERS);
    STAT_BUFFER(14 downto 2)     <= (others => '0');
    STAT_BUFFER(15)              <= send_DATA;
    STAT_BUFFER(20 downto 16)    <= std_logic_vector(CURRENT_DATA_COUNT(4 downto 0));
    STAT_BUFFER(31 downto 21)    <= (others => '0');
    SEND_BUFFER_SIZE_IN          <= CTRL_BUFFER(3 downto 0);
    REC_BUFFER_SIZE_IN           <= CTRL_BUFFER(7 downto 4);
    SEND_ACK_IN                  <= CTRL_BUFFER(8);
    GOT_ACK_IN                   <= CTRL_BUFFER(9);
  end generate;

  gen1a : if USE_ACKNOWLEDGE = 0 generate
    send_EOB                     <= '0';
    send_ACK                     <= '0';
    reg_SEND_ACK_IN              <= '0';
    reg_SEND_ACK_IN_2            <= '0';
    send_DATA                    <= '1';
    CURRENT_DATA_COUNT           <= (others => '0');
    max_DATA_COUNT_minus_one     <= (others => '0');
  end generate;


---------------------------------------------------------------------
-- Builds the three different packet types the Obuf can send: ACK, EOB, DATA
---------------------------------------------------------------------
  GENERATE_WORDS : process (transfer_counter, saved_packet_type, int_data_in_i, CRC, buffer_number,
                            CTRL_BUFFER, send_buffer_size_in, current_data_count)
    begin
      current_NOP_word  <= (others => '0');
      current_ACK_word  <= (others => '0');
      current_EOB_word  <= (others => '0');
      current_DATA_word <= int_data_in_i;
      if transfer_counter = c_F0 then
        current_EOB_word <= CRC;
        if saved_packet_type = TYPE_TRM and USE_CHECKSUM = c_YES then
          current_DATA_word <= CRC;
        end if;
      elsif transfer_counter = c_F1 then
        current_ACK_word(3 downto 0) <= SEND_BUFFER_SIZE_IN;
      elsif transfer_counter = c_F2 then
        current_EOB_word(DATA_COUNT_WIDTH-1 downto 0) <= std_logic_vector(CURRENT_DATA_COUNT);
      elsif transfer_counter = c_F3 then
        current_EOB_word(15 downto 0) <= std_logic_vector(buffer_number);
        current_ACK_word(15 downto 0) <= CTRL_BUFFER(31 downto 16);
      elsif transfer_counter = c_H0 then
        current_NOP_word(2 downto 0) <= TYPE_ILLEGAL;
        current_ACK_word(2 downto 0) <= TYPE_ACK;
        current_EOB_word(2 downto 0) <= TYPE_EOB;
     end if;
    end process;

---------------------------------------------------------------------
-- makes the packet number
---------------------------------------------------------------------
  REG_TRANSFER_COUNTER : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          transfer_counter <= c_H0;
        elsif comb_dataready = '1' then
          if transfer_counter = c_max_word_number then
            transfer_counter <= (others => '0');
          else
            transfer_counter <= std_logic_vector(unsigned(transfer_counter) + to_unsigned(1,1));
          end if;
        end if;
      end if;
    end process;

---------------------------------------------------------------------
-- save which packet type is currently be sent
---------------------------------------------------------------------
  SAVE_PACKET_TYPE : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          saved_packet_type <= TYPE_ILLEGAL;
        elsif transfer_counter = c_H0 and comb_dataready = '1' then
          saved_packet_type <= current_output_data_buffer(2 downto 0);
        end if;
      end if;
    end process;


---------------------------------------------------------------------
-- CRC generator
---------------------------------------------------------------------
  GEN_CRC : if USE_CHECKSUM = 1 generate
    CRC_gen : trb_net_CRC
      port map(
        CLK     => CLK,
        RESET   => CRC_RESET,
        CLK_EN  => CRC_enable,
        DATA_IN => int_data_in_i,
        CRC_OUT => CRC,
        CRC_match => crc_match
        );
  end generate;

  GEN_NO_CRC : if USE_CHECKSUM = 0 generate
    CRC <= (others => '0');
  end generate;


---------------------------------------------------------------------
-- The main control process (combinatorial part)
---------------------------------------------------------------------
  --since we count only 64Bit packets, each counter is updated on the last packet
  --the EOB and ACK flags must be available when the last packet is sent.
  --full buffers (despite the sbuf) can only occur on the last packet.
  COMB_NEXT_TRANSFER : process(transfer_counter, current_NOP_word,
                               int_dataready_in_i, reg_INT_READ_OUT,
                               saved_packet_type, sending_state,
                               current_DATA_word, send_ACK, send_EOB, sbuf_free, RESET,
                               current_ACK_word, current_EOB_word, int_packet_num_in_i,
                               TRANSMITTED_BUFFERS, send_DATA, comb_next_read)
    begin
      current_output_data_buffer <= current_NOP_word;
      current_output_num_buffer  <= std_logic_vector(transfer_counter);
      next_INT_READ_OUT          <= '1';
      inc_TRANSMITTED_BUFFERS    <= '0';
      inc_DATA_COUNT             <= '0';
      reset_DATA_COUNT           <= '0';
      next_SEND_ACK_IN           <= send_ACK;
      comb_dataready             <= '0';
      next_sending_state         <= sending_state;
      CRC_enable                 <= '0';
      CRC_RESET                  <= RESET;

-- if data is read from INT  --can only happen if idle or sending_data
      if (reg_INT_READ_OUT = '1' and  int_dataready_in_i = '1')  then
        current_output_data_buffer <= current_DATA_word;

        --CRC is only used for data payload
        if int_packet_num_in_i(2) = '0' and saved_packet_type /= TYPE_TRM then
          CRC_enable <= '1';
        else
          CRC_enable <= '0';
        end if;

        comb_dataready        <= '1';
        if transfer_counter = c_F3_next then
          inc_DATA_COUNT <= '1'; --transfer_counter(1) and not transfer_counter(0);
        end if;
--end of current packet reached, determine next state
        if transfer_counter = c_F3 then
          if saved_packet_type = TYPE_TRM then
            reset_DATA_COUNT <= '1';
            CRC_RESET <= '1';
            inc_TRANSMITTED_BUFFERS <= '1';
            if TRANSMITTED_BUFFERS(0) = '1' then
              next_INT_READ_OUT <= '0';
            end if;
          end if;
          if send_EOB = '1' then
              next_INT_READ_OUT       <= '0';
              next_sending_state <= sending_eob;
          end if;
          if send_ACK = '1' then
              next_INT_READ_OUT       <= '0';
              next_sending_state <= sending_ack;
          end if;
        end if;
      end if;
--state:  sending EOB word
      if sending_state = sending_eob  then
        next_INT_READ_OUT <= '0';
        current_output_data_buffer <= current_EOB_word;
        if sbuf_free = '1' then
          comb_dataready <= '1';
          if (transfer_counter = c_F3) then
            next_sending_state <= idle;
            CRC_RESET <= '1';
            reset_DATA_COUNT <= '1';
            inc_TRANSMITTED_BUFFERS <= '1';
          end if;
        end if;
      end if;

--state:  sending ACK word
      if sending_state = sending_ack  then
        next_INT_READ_OUT <= '0';
        current_output_data_buffer <= current_ACK_word;
        if sbuf_free = '1' then
          comb_dataready <= '1';
          if (transfer_counter = c_F3) then
            next_SEND_ACK_IN <= '0';
            next_sending_state <= idle;
          end if;
        end if;
      end if;

--switch to EOB / ACK sending in case of idle
      if send_EOB = '1' and transfer_counter = c_H0 and (reg_INT_READ_OUT and int_dataready_in_i) = '0' then
        next_sending_state <= sending_eob;
        next_INT_READ_OUT <= '0';
      end if;
      if send_ACK = '1' and transfer_counter = c_H0 and (reg_INT_READ_OUT and int_dataready_in_i) = '0' then
        next_sending_state <= sending_ack;
        next_INT_READ_OUT <= '0';
      end if;

      if comb_next_read = '0' or send_DATA = '0' then
        next_INT_READ_OUT <= '0';
      end if;
    end process;


---------------------------------------------------------------------
-- Register control process signals
---------------------------------------------------------------------
  REG1 : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          reg_INT_READ_OUT       <= '0';
          sending_state          <= idle;
        elsif CLK_EN = '1' then
          reg_INT_READ_OUT       <= next_INT_READ_OUT;
          sending_state          <= next_sending_state;
        end if;
      end if;
    end process;

  gen3 : if USE_ACKNOWLEDGE = 0 generate
    STAT_BUFFER         <= (others => '0');
    TRANSMITTED_BUFFERS <= (others => '0');
  end generate;

  GEN2 : if USE_ACKNOWLEDGE = 1 generate

--count sent data words
    REG_DATA_COUNT : process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' or reset_DATA_COUNT = '1' then
            CURRENT_DATA_COUNT    <= (others => '0');
          elsif CLK_EN = '1' and inc_DATA_COUNT = '1' then
            CURRENT_DATA_COUNT    <= CURRENT_DATA_COUNT + 1;
          end if;
        end if;
      end process;

    REG : process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            reg_SEND_ACK_IN       <= '0';
            reg_SEND_ACK_IN_2     <= '0';
          elsif CLK_EN = '1' then
            reg_SEND_ACK_IN       <= next_SEND_ACK_IN;
            reg_SEND_ACK_IN_2     <= next_SEND_ACK_IN_2;
          end if;
        end if;
      end process;

-- decode maximum buffer size
      process(CLK)
        begin
         if rising_edge(CLK) then
            case REC_BUFFER_SIZE_IN(2 downto 0) is
              when "010" => max_DATA_COUNT_minus_one <= to_unsigned(2, DATA_COUNT_WIDTH);
              when "011" => max_DATA_COUNT_minus_one <= to_unsigned(4, DATA_COUNT_WIDTH);
              when "110" => max_DATA_COUNT_minus_one <= to_unsigned(100, DATA_COUNT_WIDTH);
              when "111" => max_DATA_COUNT_minus_one <= to_unsigned(100, DATA_COUNT_WIDTH);
              when others => max_DATA_COUNT_minus_one <= to_unsigned(1, DATA_COUNT_WIDTH);
            end case;
         end if;
        end process;

-- count how many EOB have been sent and how many ACK have been received. transmitted_buffers is the difference between both
    reg_TRANSMITTED_BUFFERS : process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' or reset_transmitted_buffers = '1' then
            TRANSMITTED_BUFFERS <= "00";
            buffer_number <= (others => '0');
          elsif CLK_EN = '1' then
            if (inc_TRANSMITTED_BUFFERS = '1' and decrease_TRANSMITTED_BUFFERS = '0') then
              TRANSMITTED_BUFFERS <= TRANSMITTED_BUFFERS +1;
            elsif (inc_TRANSMITTED_BUFFERS = '0' and decrease_TRANSMITTED_BUFFERS = '1') then
              TRANSMITTED_BUFFERS <= TRANSMITTED_BUFFERS -1;
            end if;
            if inc_TRANSMITTED_BUFFERS = '1' then
              buffer_number <= buffer_number + to_unsigned(1,1);
            end if;
          end if;
        end if;
      end process;
  end generate;

---------------------------------------------------------------------
-- measure time waiting for two ACK - if too long, set error flag
---------------------------------------------------------------------
--   proc_reg_setting : process (CLK)
--     begin
--       if rising_edge(CLK) then
--         wait_for_ack_max_bit <= CTRL_SETTINGS(2 downto 0);
--         timer_tick <= TIMER_TICKS_IN(1);
--       end if;
--     end process;

--   proc_ack_timeout_counters : process (CLK)
--     begin
--       if rising_edge(CLK) then
--         wait_for_ack_timeout <= '0';
--         reset_transmitted_buffers <= '0';
--         if TRANSMITTED_BUFFERS(1) = '0' or wait_for_ack_max_bit = "000" or wait_for_ack_max_bit = "111" then
--           wait_for_ack_counter <= (0 => '1', others => '0');
--         elsif wait_for_ack_counter(to_integer(unsigned(wait_for_ack_max_bit&'1'))) = '1' then
--           wait_for_ack_timeout <= '1';
--           reset_transmitted_buffers <= '1';
--         elsif timer_tick = '1' then
--           wait_for_ack_counter <= wait_for_ack_counter + to_unsigned(1,1);
--         end if;
--       end if;
--     end process;

  proc_reg_setting : process (CLK)
    begin
      if rising_edge(CLK) then
        current_timeout_value <= unsigned(CTRL_SETTINGS(15 downto 0));
        timer_tick <= TIMER_TICKS_IN(1);
      end if;
    end process;

  proc_ack_timeout_counters : process (CLK)
    begin
      if rising_edge(CLK) then
        wait_for_ack_timeout <= '0';
        reset_transmitted_buffers <= '0';
        if current_timeout_value = 0 then
          wait_for_ack_counter <= (others => '0');
        elsif TRANSMITTED_BUFFERS(1) = '0' then
          wait_for_ack_counter <= (0 => '1', others => '0');
        elsif wait_for_ack_counter = current_timeout_value then
          wait_for_ack_timeout <= '1';
          reset_transmitted_buffers <= '1';
        elsif timer_tick = '1' then
          wait_for_ack_counter <= wait_for_ack_counter + to_unsigned(1,1);
        end if;
      end if;
    end process;


---------------------------------------------------------------------
-- Debug output
---------------------------------------------------------------------

  STAT_DEBUG(17 downto 16) <= "00";
  STAT_DEBUG(19 downto 18) <= transfer_counter(1 downto 0);  --used in hub monitoring!
  STAT_DEBUG(20) <= wait_for_ack_timeout;                    --used in hub monitoring
  STAT_DEBUG(22 downto 21) <= std_logic_vector(TRANSMITTED_BUFFERS);
  STAT_DEBUG(25 downto 23) <= REC_BUFFER_SIZE_IN(2 downto 0);
  STAT_DEBUG(31 downto 26) <= (others => '0');
end architecture;
