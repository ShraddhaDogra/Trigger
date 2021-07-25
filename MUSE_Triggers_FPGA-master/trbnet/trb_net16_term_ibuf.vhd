-- term_ibuf can be used instead of ibuf, if only short transfers are received.
-- it keeps only the TRM words
-- EOB are killed
-- ACK are recognized
-- reply channel is killed
-- all other words (HDR, DAT) are not stored

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;


entity trb_net16_term_ibuf is
  generic(
    SECURE_MODE   : integer range 0 to 1 := std_TERM_SECURE_MODE;
    SBUF_VERSION  : integer range 0 to 1 := std_SBUF_VERSION
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_IN:  in  std_logic;
    MED_DATA_IN:       in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN :in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT:      out std_logic;
    MED_ERROR_IN:      in  std_logic_vector (2 downto 0);
    -- Internal direction port
    INT_DATAREADY_OUT: out std_logic;
    INT_DATA_OUT:      out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_PACKET_NUM_OUT:out std_logic_vector(c_NUM_WIDTH-1 downto 0);
    INT_READ_IN:       in  std_logic;
    INT_ERROR_OUT:     out std_logic_vector (2 downto 0);
    -- Status and control port
    STAT_BUFFER:       out std_logic_vector (31 downto 0)
    );
end entity;

architecture trb_net16_term_ibuf_arch of trb_net16_term_ibuf is

  component trb_net16_sbuf is
    generic (
      VERSION    : integer := SBUF_VERSION
      );
    port(
      --  Misc
      CLK               : in std_logic;
      RESET             : in std_logic;
      CLK_EN            : in std_logic;
      --  port to combinatorial logic
      COMB_DATAREADY_IN : in  STD_LOGIC;  --comb logic provides data word
      COMB_next_READ_OUT: out STD_LOGIC;  --sbuf can read in NEXT cycle
      COMB_READ_IN      : in  STD_LOGIC;  --comb logic IS reading
      COMB_DATA_IN      : in  STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      COMB_PACKET_NUM_IN: in  STD_LOGIC_VECTOR (c_NUM_WIDTH-1  downto 0);
      -- Port to synchronous output.
      SYN_DATAREADY_OUT : out STD_LOGIC;
      SYN_DATA_OUT      : out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      SYN_PACKET_NUM_OUT: out STD_LOGIC_VECTOR (c_NUM_WIDTH-1  downto 0);
      SYN_READ_IN       : in  STD_LOGIC;
      -- Status and control port
      STAT_BUFFER       : out STD_LOGIC
      );
  end component;

  signal got_ack_internal, reg_ack_internal : std_logic; --should be raised for 1 cycle when ack
  signal got_eob_out, reg_eob_out: std_logic;
  signal sbuf_free, comb_next_read: std_logic;
  signal tmp_INT_DATAREADY_OUT: std_logic;
  signal tmp_INT_DATA_OUT: std_logic_vector(c_DATA_WIDTH-1 downto 0) := (others => '0');
  signal tmp_INT_PACKET_NUM_OUT: std_logic_vector(c_NUM_WIDTH-1 downto 0) := (others => '0');
  type ERROR_STATE is (IDLE, GOT_OVERFLOW_ERROR, GOT_LOCKED_ERROR, GOT_UNDEFINED_ERROR);
  signal current_error_state, next_error_state : ERROR_STATE;
  signal next_rec_buffer_size_out, current_rec_buffer_size_out  : std_logic_vector(3 downto 0);
  signal current_packet_type, saved_packet_type : std_logic_vector(3 downto 0);
  signal buf_MED_READ_OUT : std_logic;

                                      -- buffer size control
begin

  --this holds the current packet type
  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          saved_packet_type <= "0111";
        elsif MED_PACKET_NUM_IN = c_H0 then
          saved_packet_type <= MED_DATA_IN(3 downto 0);
        end if;
      end if;
    end process;
  --create comb. real packet type
  current_packet_type <= MED_DATA_IN(3 downto 0) when (MED_PACKET_NUM_IN = c_H0)
                         else saved_packet_type;

  -- this process controls the writing of the media into the fifo
  FILTER_DATAREADY_IN : process(MED_DATA_IN, MED_DATAREADY_IN, MED_ERROR_IN,
                                  current_rec_buffer_size_out, current_error_state,
                                  sbuf_free, MED_PACKET_NUM_IN, current_packet_type)
    begin
      got_ack_internal <=   '0';
      next_rec_buffer_size_out <= current_rec_buffer_size_out;
      next_error_state <= current_error_state;
      tmp_INT_DATA_OUT <= MED_DATA_IN;
      tmp_INT_PACKET_NUM_OUT <= MED_PACKET_NUM_IN;
      tmp_INT_DATAREADY_OUT <= '0';
      got_eob_out <= '0';

      if MED_DATAREADY_IN = '1' then
        if current_packet_type = '1' & TYPE_ACK then     --ACK in reply
          if MED_PACKET_NUM_IN = c_H0 then
            got_ack_internal <=   '1';
          elsif MED_PACKET_NUM_IN = c_F1 then
            next_rec_buffer_size_out <= MED_DATA_IN(3 downto 0);
          end if;
        elsif current_packet_type = '0' & TYPE_TRM then  --TRM in init
          if MED_PACKET_NUM_IN = c_F3 then
            got_eob_out <= '1';
          end if;
          tmp_INT_DATAREADY_OUT <= '1';
        elsif current_packet_type = '0' & TYPE_EOB then  --EOB in init
          if MED_PACKET_NUM_IN = c_F3 then
            got_eob_out <= '1';
          end if;
        end if;
        if sbuf_free = '0' then
          next_error_state <= GOT_OVERFLOW_ERROR;
        end if;
      end if;
    end process;


  INT_ERROR_OUT <= MED_ERROR_IN;
  MED_READ_OUT <= buf_MED_READ_OUT;
  buf_MED_READ_OUT <= '1';

  reg_buffer: process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_rec_buffer_size_out <= (others => '0');
          reg_ack_internal    <= '0';
          reg_eob_out <= '0';
          current_error_state <= IDLE;
        elsif CLK_EN = '1' then
          current_rec_buffer_size_out <= next_rec_buffer_size_out;
          reg_ack_internal    <= got_ack_internal;
          reg_eob_out <= got_eob_out;
          current_error_state <= next_error_state;
        end if;
      end if;
    end process;



  SBUF: trb_net16_sbuf
    generic map(
      VERSION            => SBUF_VERSION
      )
    port map (
      CLK                => CLK,
      RESET              => RESET,
      CLK_EN             => CLK_EN,
      COMB_DATAREADY_IN  => tmp_INT_DATAREADY_OUT,
      COMB_next_READ_OUT => comb_next_read,
      COMB_READ_IN       => '1',
      COMB_DATA_IN       => tmp_INT_DATA_OUT,
      COMB_PACKET_NUM_IN => tmp_INT_PACKET_NUM_OUT,
      SYN_DATAREADY_OUT  => INT_DATAREADY_OUT,
      SYN_DATA_OUT       => INT_DATA_OUT,
      SYN_PACKET_NUM_OUT => INT_PACKET_NUM_OUT,
      SYN_READ_IN        => INT_READ_IN
      );
  sbuf_free <= comb_next_read or INT_READ_IN;  --sbuf killed




-- make STAT_BUFFER
  STAT_BUFFER(3 downto 0) <= "0111";    --always "biggest fifo"
  STAT_BUFFER(7 downto 4) <= current_rec_buffer_size_out;
  STAT_BUFFER(8) <= reg_eob_out;
  STAT_BUFFER(9) <= '0';
  STAT_BUFFER(10) <= '0';
  STAT_BUFFER(11) <= reg_ack_internal;

  STAT_BUFFER(31 downto 12) <= (others => '0');

end architecture;