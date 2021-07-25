-- this is a dummy apl, just sending data into an active api

--THIS IS NOT WORKING correctly!!!!


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;


entity trb_net16_dummy_apl is
  generic (
    TARGET_ADDRESS : std_logic_vector (15 downto 0) := x"F001";
    PREFILL_LENGTH  : integer := 1;
    TRANSFER_LENGTH  : integer := 1  -- length of dummy data
                                  -- might not work with transfer_length > api_fifo
                                  -- because of incorrect handling of fifo_full_in!

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
    APL_SEQNR_IN:     in std_logic_vector (7 downto 0)
    );
end entity;

architecture trb_net16_dummy_apl_arch of trb_net16_dummy_apl is

  type SENDER_STATE is (IDLE, WRITING, WAITING);
  signal current_state, next_state : SENDER_STATE;
  signal next_counter, reg_counter  : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal buf_APL_DATA_OUT, next_APL_DATA_OUT : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal buf_APL_WRITE_OUT, next_APL_WRITE_OUT : std_logic;
  signal buf_APL_SEND_OUT, next_APL_SEND_OUT : std_logic;
  signal next_packet_counter, packet_counter : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal address, reghigh, reglow : std_logic_vector(15 downto 0);
  signal state_bits : std_logic_vector(2 downto 0);
  signal reg_F0, reg_F1, reg_F2, reg_F3 : std_logic_vector(15 downto 0);
begin

--   address <= x"0008";
--   reghigh <= x"DEAD";
--   reglow  <= x"AFFE";
  reg_F0 <= x"8023"; --x"0001";

  reg_F1 <= x"8000";
  reg_F2 <= x"0000";--xor_all(APL_DATA_IN) & "000000000000011";
  reg_F3 <= x"0000";
  APL_DTYPE_OUT <= x"9";
  APL_TARGET_ADDRESS_OUT <= TARGET_ADDRESS;

  process(current_state)
    begin
      case current_state is
        when IDLE         => state_bits <= "000";
        when WRITING      => state_bits <= "001";
        when WAITING      => state_bits <= "011";
        when others       => state_bits <= "111";
      end case;
    end process;

  APL_READ_OUT <= '1';                  --just read, do not check
  APL_ERROR_PATTERN_OUT <= x"12345678";
  --APL_DATA_OUT <= reg_counter;

  CHECK_1:if TRANSFER_LENGTH >0 generate
    APL_SHORT_TRANSFER_OUT <= '0';
    APL_SEND_OUT <= buf_APL_SEND_OUT;
  end generate;
  CHECK_2:if TRANSFER_LENGTH =0 generate
    APL_SHORT_TRANSFER_OUT <= '1';
    APL_SEND_OUT <= '1' when APL_RUN_IN = '0' else '0';
  end generate;


  SENDER_CTRL: process (current_state, APL_READ_IN, reg_counter, APL_RUN_IN, RESET, packet_counter, buf_APL_SEND_OUT)
    begin  -- process
      next_APL_SEND_OUT <=  buf_APL_SEND_OUT;
      next_state <=  IDLE;
      next_counter <=  reg_counter;
      next_APL_WRITE_OUT <=  '0';
      next_APL_DATA_OUT <= (others => '0');
      next_packet_counter <= packet_counter;
-------------------------------------------------------------------------
-- IDLE
-------------------------------------------------------------------------
      if current_state = IDLE then
        if reg_counter = TRANSFER_LENGTH then
          next_state <= WAITING;
        elsif APL_READ_IN = '0' then
          next_state <=  IDLE;
        else
          next_state <=  WRITING;
          next_APL_DATA_OUT <= reg_F0;
          next_APL_WRITE_OUT <=  '1';
          next_packet_counter <= c_F0;
          next_APL_SEND_OUT <=  '1';
      end if;
-------------------------------------------------------------------------
-- WRITING
-------------------------------------------------------------------------
      elsif current_state = WRITING then
        next_APL_SEND_OUT <=  '1';
        next_state <= WRITING;
        if packet_counter = c_F0 then
          next_APL_WRITE_OUT <=  '1';
          next_APL_DATA_OUT <= reg_F1;
          next_packet_counter <= c_F1;
        elsif packet_counter = c_F1 then
          next_APL_WRITE_OUT <=  '1';
          next_APL_DATA_OUT <= reg_F2;
          next_packet_counter <= c_F2;
        elsif packet_counter = c_F2 then
          next_APL_WRITE_OUT <=  '1';
          next_APL_DATA_OUT <= reg_F3;
          next_packet_counter <= c_F3;
        elsif packet_counter = c_F3 then
          next_state <= IDLE;
          next_counter <=  reg_counter +1;
        end if;
-----------------------------------------------------------------------
-- WAITING
-----------------------------------------------------------------------
      elsif current_state = WAITING then
        next_APL_SEND_OUT <= '0';
        if APL_RUN_IN = '1' or buf_APL_SEND_OUT = '1' then
          next_state <=  WAITING;
        else
          next_state <=  IDLE;
          next_counter <=  (others => '0');
        end if;
      end if;                           -- end state switch

    end process;

APL_DATA_OUT(15 downto 0) <= buf_APL_DATA_OUT;
APL_PACKET_NUM_OUT <= packet_counter;
APL_DATAREADY_OUT <= buf_APL_WRITE_OUT;


    CLK_REG: process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        current_state  <= IDLE;
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
