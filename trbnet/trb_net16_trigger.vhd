
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;


entity trb_net16_trigger is
  generic (
    USE_TRG_PORT : integer range 0 to 1 := c_YES;
               --even when NO, ERROR_PACKET_IN is used for automatic replys
    SECURE_MODE  : integer range 0 to 1 := std_TERM_SECURE_MODE
               --if secure_mode is not used, apl must provide error pattern and dtype until
               --next trigger comes in. In secure mode these need to be available while relase_trg is high only
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    INT_DATAREADY_OUT:     out std_logic;
    INT_DATA_OUT:          out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_PACKET_NUM_OUT:    out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    INT_READ_IN:           in  std_logic := '0';

    INT_DATAREADY_IN:      in  std_logic := '0';
    INT_DATA_IN:           in  std_logic_vector (c_DATA_WIDTH-1 downto 0) := (others => '0');
    INT_PACKET_NUM_IN:     in  std_logic_vector (c_NUM_WIDTH-1  downto 0) := (others => '0');
    INT_READ_OUT:          out std_logic;

    -- Trigger information output
    TRG_TYPE_OUT          : out std_logic_vector (3 downto 0);
    TRG_NUMBER_OUT        : out std_logic_vector (15 downto 0);
    TRG_CODE_OUT          : out std_logic_vector (7 downto 0);
    TRG_INFORMATION_OUT   : out std_logic_vector (23 downto 0);
    TRG_RECEIVED_OUT      : out std_logic;
    TRG_RELEASE_IN        : in  std_logic;
    TRG_ERROR_PATTERN_IN  : in  std_logic_vector (31 downto 0)
    );
end entity;

architecture trb_net16_trigger_arch of trb_net16_trigger is

  signal next_TRG_TYPE_OUT, reg_TRG_TYPE_OUT: std_logic_vector(3 downto 0) := (others => '0');
  signal next_TRG_NUMBER_OUT, reg_TRG_NUMBER_OUT: std_logic_vector(15 downto 0) := (others => '0');
  signal next_TRG_CODE_OUT, reg_TRG_CODE_OUT: std_logic_vector(7 downto 0) := (others => '0');
  signal next_TRG_INFORMATION_OUT, reg_TRG_INFORMATION_OUT: std_logic_vector(23 downto 0) := (others => '0');
  signal next_TRG_RECEIVED_OUT, reg_TRG_RECEIVED_OUT: std_logic := '0';
  signal buf_TRG_ERROR_PATTERN_IN: std_logic_vector(31 downto 0) := (others => '0');


  signal saved_packet_type           : std_logic_vector(2 downto 0) := (others => '0');

  signal transfer_counter                                 : std_logic_vector(c_NUM_WIDTH-1 downto 0) := (others => '0');
  signal send_trm, next_send_trm                          : std_logic := '0';
  signal buf_INT_DATAREADY_OUT, next_INT_DATAREADY_OUT    : std_logic := '0';
  signal buf_INT_DATA_OUT, next_INT_DATA_OUT              : std_logic_vector(c_DATA_WIDTH-1 downto 0)  := (others => '0');
  signal next_seqnr, seqnr                                : std_logic_vector(7 downto 0) := (others => '0');

begin

  g1: if USE_TRG_PORT = c_YES generate
    TRG_TYPE_OUT <= reg_TRG_TYPE_OUT;
    TRG_CODE_OUT <= reg_TRG_CODE_OUT;
    TRG_NUMBER_OUT <= reg_TRG_NUMBER_OUT;
    TRG_CODE_OUT <= reg_TRG_CODE_OUT;
    TRG_INFORMATION_OUT <= reg_TRG_INFORMATION_OUT;
    TRG_RECEIVED_OUT <= reg_TRG_RECEIVED_OUT;
    INT_READ_OUT <= '1'; --not send_trm and not reg_APL_GOT_TRM;
  end generate;

  g1n: if USE_TRG_PORT = c_NO generate
    TRG_TYPE_OUT <= (others => '0');
    TRG_CODE_OUT <= (others => '0');
    TRG_NUMBER_OUT <= (others => '0');
    TRG_CODE_OUT <= (others => '0');
    TRG_INFORMATION_OUT <= (others => '0');
    TRG_RECEIVED_OUT <= '0';
    INT_READ_OUT <= '1'; --not send_trm;
  end generate;


    process(transfer_counter, INT_READ_IN, saved_packet_type, buf_TRG_ERROR_PATTERN_IN,
            reg_TRG_TYPE_OUT, reg_TRG_CODE_OUT, reg_TRG_NUMBER_OUT, int_dataready_in,
            reg_TRG_INFORMATION_OUT, reg_TRG_RECEIVED_OUT, INT_PACKET_NUM_IN, INT_DATA_IN,
            buf_INT_DATA_OUT, TRG_RELEASE_IN, send_trm, buf_INT_DATAREADY_OUT, seqnr)
      begin
        if USE_TRG_PORT = 1 then
          next_TRG_TYPE_OUT <= reg_TRG_TYPE_OUT;
          next_TRG_CODE_OUT <= reg_TRG_CODE_OUT;
          next_TRG_NUMBER_OUT <= reg_TRG_NUMBER_OUT;
          next_TRG_CODE_OUT <= reg_TRG_CODE_OUT;
          next_TRG_INFORMATION_OUT <= reg_TRG_INFORMATION_OUT;
          next_TRG_RECEIVED_OUT <= reg_TRG_RECEIVED_OUT;
          next_seqnr <= seqnr;
          if saved_packet_type = TYPE_TRM and INT_DATAREADY_IN = '1' then
            if INT_PACKET_NUM_IN = c_F0 then
              next_TRG_INFORMATION_OUT(23 downto 8) <= INT_DATA_IN(15 downto 0);
            elsif INT_PACKET_NUM_IN = c_F1 then
              next_TRG_INFORMATION_OUT(7 downto 0)  <= INT_DATA_IN(15 downto 8);
              next_TRG_CODE_OUT                <= INT_DATA_IN(7 downto 0);
            elsif INT_PACKET_NUM_IN = c_F2 then
              next_TRG_NUMBER_OUT              <= INT_DATA_IN(15 downto 0);
            elsif INT_PACKET_NUM_IN = c_F3 then
              next_TRG_TYPE_OUT                <= INT_DATA_IN(3 downto 0);
              next_seqnr                       <= INT_DATA_IN(11 downto 4);
              next_TRG_RECEIVED_OUT            <= '1';
            end if;
          end if;
        end if;
        next_send_trm              <= '0';
        next_INT_DATAREADY_OUT     <= '0';
        next_INT_DATA_OUT          <= buf_INT_DATA_OUT;

        if (reg_TRG_RECEIVED_OUT = '1' and (TRG_RELEASE_IN = '1'  or USE_TRG_PORT = c_NO)) or send_trm = '1' then
                           --next_transfer_counter is used for transmission!
          if transfer_counter = c_F3_next and INT_READ_IN = '1' then
            next_send_trm <= '0';
          else
            next_send_trm <= '1';
          end if;
          next_INT_DATAREADY_OUT <= '1';
        end if;
        if buf_INT_DATAREADY_OUT = '1' and INT_READ_IN = '1' then
          if transfer_counter = c_H0_next then
            next_INT_DATA_OUT <= (others => '0');
            next_INT_DATA_OUT(2 downto 0) <= TYPE_TRM;
          elsif transfer_counter = c_F0_next then
            next_INT_DATA_OUT <= (others => '0');
          elsif transfer_counter = c_F1_next then
            next_INT_DATA_OUT <= buf_TRG_ERROR_PATTERN_IN(31 downto 16);
          elsif transfer_counter = c_F2_next then
            next_INT_DATA_OUT <= buf_TRG_ERROR_PATTERN_IN(15 downto 1) & '1';
          else
            next_INT_DATA_OUT <= (others => '0');
            next_INT_DATA_OUT(11 downto 4) <= seqnr;
          end if;
        end if;
        if (TRG_RELEASE_IN = '1' and reg_TRG_RECEIVED_OUT = '1') or USE_TRG_PORT = c_NO then
          next_TRG_RECEIVED_OUT <= '0';
        end if;
      end process;

  CLK_REG2: process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          buf_TRG_ERROR_PATTERN_IN <= (others => '0');
        elsif TRG_RELEASE_IN = '1' then
          buf_TRG_ERROR_PATTERN_IN <= TRG_ERROR_PATTERN_IN;
        end if;
      end if;
    end process;



--count packets
  REG_TRANSFER_COUNTER : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          transfer_counter <= c_H0;
        elsif buf_INT_DATAREADY_OUT = '1' and INT_READ_IN = '1' then
          if transfer_counter = c_max_word_number then
            transfer_counter <= (others => '0');
          else
            transfer_counter <= transfer_counter + 1;
          end if;
        end if;
      end if;
    end process;

  INT_DATAREADY_OUT <= buf_INT_DATAREADY_OUT;
  INT_DATA_OUT      <= buf_INT_DATA_OUT;
  INT_PACKET_NUM_OUT <= transfer_counter;

  INT_OUT_REG: process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          buf_INT_DATA_OUT <= "0000000000000" & TYPE_TRM;
          buf_INT_DATAREADY_OUT <= '0';
        else
          buf_INT_DATA_OUT <= next_INT_DATA_OUT;
          buf_INT_DATAREADY_OUT <= next_INT_DATAREADY_OUT;
        end if;
      end if;
    end process;

  --this holds the current packet type
  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then --or
          saved_packet_type <= "111";
        elsif INT_PACKET_NUM_IN = c_H0 then
          saved_packet_type <= INT_DATA_IN(2 downto 0);
        end if;
      end if;
    end process;

  REG_send_trm: process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          send_trm <= '0';
          reg_TRG_RECEIVED_OUT <= '0';
          reg_TRG_NUMBER_OUT <= (others => '0');
        else
          send_trm <= next_send_trm;
          reg_TRG_RECEIVED_OUT <= next_TRG_RECEIVED_OUT;
          reg_TRG_NUMBER_OUT <= next_TRG_NUMBER_OUT;
        end if;
      end if;
    end process;

  g2: if USE_TRG_PORT = 1 generate
    CLK_REG: process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            reg_TRG_TYPE_OUT <= (others => '0');
            reg_TRG_CODE_OUT <= (others => '0');
            reg_TRG_INFORMATION_OUT <= (others => '0');
          else
            reg_TRG_TYPE_OUT <= next_TRG_TYPE_OUT;
            reg_TRG_CODE_OUT <= next_TRG_CODE_OUT;
            reg_TRG_INFORMATION_OUT <= next_TRG_INFORMATION_OUT;
            seqnr <= next_seqnr;
          end if;
        end if;
      end process;
  end generate;

end architecture;
