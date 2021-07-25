-- this is a dummy apl, just sending data into an active api

-- THIS IS NOT WORKING correctly !!!!


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

use work.trb_net_std.all;


entity trb_net16_dummy_passive_apl is
  generic (
    TARGET_ADDRESS : std_logic_vector (15 downto 0) := x"ffff";
    PREFILL_LENGTH  : integer := 3;
    TRANSFER_LENGTH  : integer := 3  -- length of dummy data
                                  -- might not work with transfer_length > api_fifo
                                  -- because of incorrect handling of fifo_full_in!
                                  -- shorttransfer is not working too
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    -- APL Transmitter port
    APL_DATA_OUT:       out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    APL_PACKET_NUM_OUT: out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    APL_DATAREADY_OUT    : out std_logic;
    APL_READ_IN          : in std_logic;
    APL_SHORT_TRANSFER_OUT: out std_logic;
    APL_DTYPE_OUT:      out std_logic_vector (3 downto 0);
    APL_ERROR_PATTERN_OUT: out std_logic_vector (31 downto 0);
    APL_SEND_OUT:       out std_logic;
    APL_TARGET_ADDRESS_OUT: out std_logic_vector (15 downto 0);
    -- Receiver port
    APL_DATA_IN:      in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    APL_PACKET_NUM_IN:in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    APL_TYP_IN:       in  std_logic_vector (2 downto 0);
    APL_DATAREADY_IN: in  std_logic;
    APL_READ_OUT:     out std_logic;
    -- APL Control port
    APL_RUN_IN:       in std_logic;
    APL_SEQNR_IN:     in std_logic_vector (7 downto 0);
    STAT :            out std_logic_vector(31 downto 0)
    );
end entity;

architecture trb_net16_dummy_passive_apl_arch of trb_net16_dummy_passive_apl is

  type SENDER_STATE is (IDLE, WRITING, RUNNING, WAITING, MY_ERROR);
  signal current_state, next_state : SENDER_STATE;
  signal next_counter, reg_counter  : std_logic_vector(15 downto 0);
  signal buf_APL_DATA_OUT, next_APL_DATA_OUT : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal buf_APL_PACKET_NUM_OUT, next_APL_PACKET_NUM_OUT : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal buf_APL_WRITE_OUT, next_APL_WRITE_OUT : std_logic;
  signal buf_APL_SEND_OUT, next_APL_SEND_OUT : std_logic;
  signal next_packet_counter, packet_counter : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal state_bits : std_logic_vector(2 downto 0);
  signal current_TYPE_IN, saved_PACKET_TYPE_IN : std_logic_vector(2 downto 0);

begin
  APL_READ_OUT <= '1';                  --just read, do not check
  APL_DTYPE_OUT <= x"0";
  APL_ERROR_PATTERN_OUT <= x"00000000";
  APL_TARGET_ADDRESS_OUT <= TARGET_ADDRESS;
  --APL_DATA_OUT <= reg_counter;

  CHECK_1:if TRANSFER_LENGTH >0 generate
    APL_SHORT_TRANSFER_OUT <= '0';
  end generate;
  CHECK_2:if TRANSFER_LENGTH =0 generate
    APL_SHORT_TRANSFER_OUT <= '1';
  end generate;

  process(current_state)
    begin
      case current_state is
        when IDLE         => state_bits <= "000";
        when WRITING      => state_bits <= "001";
        when RUNNING      => state_bits <= "010";
        when WAITING      => state_bits <= "011";
        when MY_ERROR     => state_bits <= "100";
        when others       => state_bits <= "111";
      end case;
    end process;

  STAT(2 downto 0) <= state_bits;
  STAT(8) <= '1' when current_TYPE_IN = TYPE_TRM else '0';

  --this holds the current packet type from fifo_to_apl
  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          saved_PACKET_TYPE_IN <= TYPE_ILLEGAL;
        elsif APL_PACKET_NUM_IN = c_H0 then
          saved_PACKET_TYPE_IN <= APL_TYP_IN;
        end if;
      end if;
    end process;
  --create comb. real packet type
  current_TYPE_IN <= APL_TYP_IN when (APL_PACKET_NUM_IN = c_H0 and RESET = '0')
                         else saved_PACKET_TYPE_IN;

  SENDER_CTRL: process (current_state, APL_READ_IN, reg_counter, APL_RUN_IN, RESET, APL_TYP_IN,
                        packet_counter, buf_APL_SEND_OUT, current_TYPE_IN, APL_DATAREADY_IN, APL_PACKET_NUM_IN)
    begin  -- process
      next_APL_SEND_OUT <=  buf_APL_SEND_OUT;
      next_state <=  MY_ERROR;
      next_counter <=  reg_counter;
      next_APL_PACKET_NUM_OUT <= packet_counter;
      next_APL_WRITE_OUT <=  '0';
      next_APL_DATA_OUT <= (others => '0');
      next_packet_counter <= packet_counter;
-------------------------------------------------------------------------
-- IDLE
-------------------------------------------------------------------------
      if current_state = IDLE then
        if APL_READ_IN = '0' or reg_counter = PREFILL_LENGTH then
          next_state <=  RUNNING;
          next_APL_SEND_OUT <= '0';
        else
          next_APL_SEND_OUT <=  '1';
          next_state <=  WRITING;
          next_APL_DATA_OUT <= (1 => '1', others => '0');
          next_APL_WRITE_OUT <=  '1';
          next_packet_counter <= c_F0;
      end if;
-------------------------------------------------------------------------
-- WRITING
-------------------------------------------------------------------------
      elsif current_state = WRITING then
        next_state <= WRITING;
        if APL_READ_IN = '1' then
          if packet_counter = c_F0 then
            next_APL_WRITE_OUT <=  '1';
            next_APL_DATA_OUT <= x"1111";
            next_packet_counter <= c_F1;
          elsif packet_counter = c_F1 then
            next_APL_WRITE_OUT <=  '1';
            next_APL_DATA_OUT <= reg_counter(15 downto 0);
            next_packet_counter <= c_F2;
          elsif packet_counter = c_F2 then
            next_APL_WRITE_OUT <=  '1';
            next_APL_DATA_OUT <= x"0000" - reg_counter(15 downto 0);
            next_packet_counter <= c_F3;
          elsif packet_counter <=c_F3 then
            next_state <= IDLE;
            next_packet_counter <= c_F0;
            next_counter <=  reg_counter +1;
          end if;
        end if;
-----------------------------------------------------------------------
-- RUNNING
-----------------------------------------------------------------------
      elsif current_state = RUNNING then
        next_APL_SEND_OUT <=  '0';
        if reg_counter = TRANSFER_LENGTH then
          next_state <=  WAITING;
        else
          next_state <=  RUNNING;
          if APL_READ_IN = '1' then
            next_counter <=  reg_counter +1;
          end if;
        end if;
-----------------------------------------------------------------------
-- WAITING
-----------------------------------------------------------------------
      elsif current_state = WAITING then
        if (APL_TYP_IN = TYPE_TRM and APL_PACKET_NUM_IN = c_F3 and APL_DATAREADY_IN = '1') then
          next_state <=  IDLE;
          next_counter <=  (others => '0');
        else
          next_state <=  WAITING;
        end if;
      end if;                           -- end state switch
    if RESET = '1' then
      next_APL_WRITE_OUT <=  '0';
    end if;
    end process;

APL_DATA_OUT(15 downto 0) <= buf_APL_DATA_OUT;
APL_PACKET_NUM_OUT <= packet_counter;
APL_DATAREADY_OUT <= buf_APL_WRITE_OUT;
APL_SEND_OUT <= buf_APL_SEND_OUT;

    CLK_REG: process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        current_state  <= WAITING;
        reg_counter <= (others => '0');
        buf_APL_DATA_OUT <= (others => '0');
        buf_APL_WRITE_OUT <= '0';
        buf_APL_SEND_OUT <= '0';
      elsif CLK_EN = '1' then
        reg_counter <= next_counter;
        current_state  <= next_state;
        packet_counter <= next_packet_counter;
        buf_APL_DATA_OUT <= next_APL_DATA_OUT;
        buf_APL_WRITE_OUT <= next_APL_WRITE_OUT;
        buf_APL_SEND_OUT <= next_APL_SEND_OUT;
      end if;
    end if;
  end process;

end architecture;
