-- only to be used on unused channels - every transfer is terminated asap.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;


entity trb_net16_term_buf is
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    MED_INIT_DATAREADY_OUT   : out std_logic;
    MED_INIT_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    MED_INIT_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    MED_INIT_READ_IN         : in  std_logic;

    MED_REPLY_DATAREADY_OUT  : out std_logic;
    MED_REPLY_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    MED_REPLY_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    MED_REPLY_READ_IN        : in  std_logic;

    MED_DATAREADY_IN         : in  std_logic;
    MED_DATA_IN              : in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    MED_PACKET_NUM_IN        : in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
    MED_READ_OUT             : out std_logic
    );
end entity;

architecture trb_net16_term_buf_arch of trb_net16_term_buf is

  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  attribute HGROUP of trb_net16_term_buf_arch : architecture  is "TRMBUF_group";

  attribute syn_hier : string;
  attribute syn_hier of trb_net16_term_buf_arch : architecture is "flatten, firm";
  attribute syn_sharing : string;
  attribute syn_sharing of trb_net16_term_buf_arch : architecture is "off";

  signal INIT_SEQNR, next_INIT_SEQNR   : std_logic_vector(7 downto 0);
  signal saved_packet_type   : std_logic_vector(3 downto 0);
  signal INIT_transfer_counter          : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal buf_MED_INIT_DATAREADY_OUT, next_MED_INIT_DATAREADY_OUT    : std_logic;
  signal buf_MED_INIT_DATA_OUT, next_MED_INIT_DATA_OUT              : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal send_INIT_ack : std_logic;
  signal next_send_INIT_ack : std_logic;

  signal REPLY_transfer_counter          : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal buf_MED_REPLY_DATAREADY_OUT, next_MED_REPLY_DATAREADY_OUT    : std_logic;
  signal buf_MED_REPLY_DATA_OUT, next_MED_REPLY_DATA_OUT              : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal send_REPLY_trm : std_logic;
  signal next_send_REPLY_trm : std_logic;
  signal init_real_reading : std_logic;
  signal reply_real_reading : std_logic;

  attribute syn_preserve : boolean;
  attribute syn_keep : boolean;
  attribute syn_preserve of saved_packet_type : signal is true;
  attribute syn_keep of saved_packet_type : signal is true;
  attribute syn_preserve of init_real_reading : signal is true;
  attribute syn_keep of init_real_reading : signal is true;
  attribute syn_preserve of reply_real_reading : signal is true;
  attribute syn_keep of reply_real_reading : signal is true;

begin
    MED_READ_OUT <= '1';

  process(MED_DATAREADY_IN, MED_PACKET_NUM_IN, MED_DATA_IN, REPLY_transfer_counter,
          send_INIT_ack, send_REPLY_trm, MED_INIT_READ_IN,
          INIT_SEQNR, INIT_transfer_counter, saved_packet_type, MED_REPLY_READ_IN,
          buf_MED_INIT_DATA_OUT, buf_MED_REPLY_DATA_OUT, buf_MED_INIT_DATAREADY_OUT,
          buf_MED_REPLY_DATAREADY_OUT)
    begin
      next_send_INIT_ack <= send_INIT_ack;
      next_send_REPLY_trm <= send_REPLY_trm;
      next_MED_INIT_DATA_OUT <= buf_MED_INIT_DATA_OUT;
      next_MED_INIT_DATAREADY_OUT <= '0';
      next_MED_REPLY_DATA_OUT <= buf_MED_REPLY_DATA_OUT;
      next_MED_REPLY_DATAREADY_OUT <= '0';
      next_INIT_SEQNR <= INIT_SEQNR;

  --output INIT data
      if send_INIT_ack = '1' then
        next_MED_INIT_DATAREADY_OUT <= '1';
        if buf_MED_INIT_DATAREADY_OUT = '1' and MED_INIT_READ_IN = '1' then
          next_MED_INIT_DATA_OUT <= (others => '0');
          if INIT_transfer_counter = c_H0_next then
            next_MED_INIT_DATA_OUT(2 downto 0) <= TYPE_ACK;
          elsif INIT_transfer_counter = c_F1_next then
            next_MED_INIT_DATA_OUT(3 downto 0) <= "0111";
          end if;
          if INIT_transfer_counter = c_F3_next then
            next_send_INIT_ack <= '0';
          end if;
        end if;
      end if;
      if send_REPLY_trm = '1' then
        next_MED_REPLY_DATAREADY_OUT <= '1';
        if buf_MED_REPLY_DATAREADY_OUT = '1' and MED_REPLY_READ_IN = '1' then
          next_MED_REPLY_DATA_OUT <= (others => '0');
          if REPLY_transfer_counter = c_H0_next then
            next_MED_REPLY_DATA_OUT(2 downto 0) <= TYPE_TRM;
          elsif REPLY_transfer_counter = c_F3_next then
            next_MED_REPLY_DATA_OUT(11 downto 4) <= INIT_SEQNR;
            next_send_REPLY_trm <= '0';
          end if;
        end if;
      end if;

  -- input data
      if MED_DATAREADY_IN = '1' then
        if MED_PACKET_NUM_IN = c_F3 then
          if saved_packet_type = '0' & TYPE_EOB then
            next_send_INIT_ack <= '1';
            next_MED_INIT_DATAREADY_OUT <= '1';
            next_MED_INIT_DATA_OUT(2 downto 0) <= TYPE_ACK;
          end if;
          if saved_packet_type = '0' & TYPE_TRM then
            next_send_INIT_ack <= '1';
            next_MED_INIT_DATAREADY_OUT <= '1';
            next_MED_INIT_DATA_OUT(2 downto 0) <= TYPE_ACK;
            next_send_REPLY_trm <= '1';
            next_MED_REPLY_DATA_OUT(2 downto 0) <= TYPE_TRM;
            next_MED_REPLY_DATAREADY_OUT <= '1';
            next_INIT_SEQNR <= MED_DATA_IN(11 downto 4);
          end if;
        end if;
      end if;

    end process;

init_real_reading <= buf_MED_INIT_DATAREADY_OUT and MED_INIT_READ_IN;
reply_real_reading <= buf_MED_REPLY_DATAREADY_OUT and MED_REPLY_READ_IN;

  --count packets
    REG_INIT_TRANSFER_COUNTER : process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            INIT_transfer_counter <= c_H0;
          elsif init_real_reading = '1' then
            if INIT_transfer_counter = c_max_word_number then
              INIT_transfer_counter <= (others => '0');
            else
              INIT_transfer_counter <= INIT_transfer_counter + 1;
            end if;
          end if;
        end if;
      end process;

    REG_REPLY_TRANSFER_COUNTER : process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            REPLY_transfer_counter <= c_H0;
          elsif buf_MED_REPLY_DATAREADY_OUT = '1' and MED_REPLY_READ_IN = '1' then
            if REPLY_transfer_counter = c_max_word_number then
              REPLY_transfer_counter <= (others => '0');
            else
              REPLY_transfer_counter <= REPLY_transfer_counter + 1;
            end if;
          end if;
        end if;
      end process;

    MED_REPLY_DATAREADY_OUT <= buf_MED_REPLY_DATAREADY_OUT;
    MED_REPLY_DATA_OUT      <= buf_MED_REPLY_DATA_OUT;
    MED_REPLY_PACKET_NUM_OUT <= REPLY_transfer_counter;
    MED_INIT_DATAREADY_OUT <= buf_MED_INIT_DATAREADY_OUT;
    MED_INIT_DATA_OUT      <= buf_MED_INIT_DATA_OUT;
    MED_INIT_PACKET_NUM_OUT <= INIT_transfer_counter;

    MED_INIT_OUT_REG: process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            buf_MED_INIT_DATA_OUT <= (others => '0');
            buf_MED_INIT_DATAREADY_OUT <= '0';
          elsif CLK_EN = '1' then
            buf_MED_INIT_DATA_OUT <= next_MED_INIT_DATA_OUT;
            buf_MED_INIT_DATAREADY_OUT <= next_MED_INIT_DATAREADY_OUT;
          end if;
        end if;
      end process;

    MED_REPLY_OUT_REG: process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            buf_MED_REPLY_DATA_OUT <= (others => '0');
            buf_MED_REPLY_DATAREADY_OUT <= '0';
          elsif CLK_EN = '1' then
            buf_MED_REPLY_DATA_OUT <= next_MED_REPLY_DATA_OUT;
            buf_MED_REPLY_DATAREADY_OUT <= next_MED_REPLY_DATAREADY_OUT;
          end if;
        end if;
      end process;


    process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            send_REPLY_trm <= '0';
            send_INIT_ack <= '0';
            INIT_SEQNR <= (others => '0');
          elsif CLK_EN = '1' then
            send_REPLY_trm <= next_send_REPLY_trm;
            send_INIT_ack <= next_send_INIT_ack;
            INIT_SEQNR <= next_INIT_SEQNR;
          end if;
        end if;
      end process;

  --this holds the current packet type
  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          saved_packet_type <= "1111";
        elsif MED_PACKET_NUM_IN = c_H0 then
          saved_packet_type <= MED_DATA_IN(3 downto 0);
        end if;
      end if;
    end process;

end architecture;
