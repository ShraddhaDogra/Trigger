-- this is just a terminator, which auto-answers requests. Answer is a TRM only.
-- for a description see HADES wiki
-- http://hades-wiki.gsi.de/cgi-bin/view/DaqSlowControl/TrbNetTerm

-- can only be used in combination with term_ibuf -> no check for packet type!

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;


entity trb_net16_term is
  generic (
    USE_APL_PORT : integer range 0 to 1 := c_YES;
               --even when 0, ERROR_PACKET_IN is used for automatic replys
    SECURE_MODE  : integer range 0 to 1 := std_TERM_SECURE_MODE
               --if secure_mode is not used, apl must provide error pattern and dtype until
               --next trigger comes in. In secure mode these need to be available while relase_trg is high
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    INT_DATAREADY_OUT    : out std_logic;
    INT_DATA_OUT         : out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    INT_PACKET_NUM_OUT   : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    INT_READ_IN          : in  std_logic;

    INT_DATAREADY_IN     : in  std_logic;
    INT_DATA_IN          : in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    INT_PACKET_NUM_IN    : in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
    INT_READ_OUT         : out std_logic;
    APL_ERROR_PATTERN_IN : in std_logic_vector(31 downto 0)
    );
end entity;

architecture trb_net16_term_arch of trb_net16_term is

  signal saved_packet_type           : std_logic_vector(2 downto 0);

  signal transfer_counter                                 : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal send_trm, next_send_trm                          : std_logic;
  signal buf_INT_DATAREADY_OUT, next_INT_DATAREADY_OUT    : std_logic;
  signal buf_INT_DATA_OUT, next_INT_DATA_OUT              : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal reg_APL_GOT_TRM, next_APL_GOT_TRM : std_logic;
  signal reg_APL_SEQNR_OUT, next_APL_SEQNR_OUT : std_logic_vector(7 downto 0);

begin

  INT_READ_OUT <= '1'; --not send_trm;


    process(RESET, reg_APL_GOT_TRM, reg_APL_SEQNR_OUT, APL_ERROR_PATTERN_IN,
            INT_PACKET_NUM_IN, INT_DATA_IN, send_trm,
            transfer_counter, INT_READ_IN, saved_packet_type,
            buf_INT_DATA_OUT, buf_INT_DATAREADY_OUT)
      begin
        next_send_trm              <= '0';
        next_INT_DATAREADY_OUT     <= '0';
        next_INT_DATA_OUT          <= buf_INT_DATA_OUT;
        next_APL_GOT_TRM <= '0';
        next_APL_SEQNR_OUT         <= reg_APL_SEQNR_OUT;
        if saved_packet_type = TYPE_TRM then
          if INT_PACKET_NUM_IN = c_F3 then
            next_APL_SEQNR_OUT        <= INT_DATA_IN(11 downto 4);
            next_APL_GOT_TRM          <= '1';
          end if;
        end if;


        if (reg_APL_GOT_TRM = '1') or send_trm = '1' then
--        if (reg_APL_GOT_TRM = '1' and (APL_RELEASE_TRM = '1' )) or send_trm = '1'  or 0 = 0 then
                           --next_transfer_counter is used for transmission!
          if transfer_counter = c_F3_next and INT_READ_IN = '1' then
            next_send_trm <= '0';
          else
            next_send_trm <= '1';
          end if;
          next_INT_DATAREADY_OUT <= '1';
        end if;
        if buf_INT_DATAREADY_OUT = '1' and INT_READ_IN = '1' then
          if transfer_counter = c_F3_next then
            next_INT_DATA_OUT <= (others => '0');
            next_INT_DATA_OUT(2 downto 0) <= TYPE_TRM;
          elsif transfer_counter = c_F0_next then
            next_INT_DATA_OUT <= (others => '0');
          elsif transfer_counter = c_F1_next then
            next_INT_DATA_OUT <= APL_ERROR_PATTERN_IN(31 downto 16);
          elsif transfer_counter = c_F2_next then
            next_INT_DATA_OUT <= APL_ERROR_PATTERN_IN(15 downto 0);
          else
            next_INT_DATA_OUT <= (others => '0');
            next_INT_DATA_OUT(11 downto 4) <= reg_APL_SEQNR_OUT;
          end if;
        end if;
      end process;


  --count packets
    REG_TRANSFER_COUNTER : process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            transfer_counter <= (others => '0');
          elsif CLK_EN = '1' and buf_INT_DATAREADY_OUT = '1' and INT_READ_IN = '1' then
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
        if RESET = '1' or (INT_PACKET_NUM_IN = c_F3 and INT_DATAREADY_IN = '1') then --or
          saved_packet_type <= "111";
        elsif INT_PACKET_NUM_IN = c_H0 and INT_DATAREADY_IN = '1' then
          saved_packet_type <= INT_DATA_IN(2 downto 0);
        end if;
      end if;
    end process;

  REG_send_trm: process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        send_trm <= '0';
        reg_APL_GOT_TRM <= '0';
        reg_APL_SEQNR_OUT <= (others => '0');
      else
        send_trm <= next_send_trm;
        reg_APL_GOT_TRM <= next_APL_GOT_TRM;
        reg_APL_SEQNR_OUT <= next_APL_SEQNR_OUT;
      end if;
    end if;
  end process;

end architecture;
