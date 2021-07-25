
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net16_ibuf is
  generic (
    DEPTH            : integer range 0 to 7 := c_FIFO_BRAM;
    USE_VENDOR_CORES : integer range 0 to 1 := c_YES;
    USE_ACKNOWLEDGE  : integer range 0 to 1 := std_USE_ACKNOWLEDGE;
    USE_CHECKSUM     : integer range 0 to 1 := c_YES;
    SBUF_VERSION     : integer range 0 to 1 := std_SBUF_VERSION;
    INIT_CAN_RECEIVE_DATA  : integer range 0 to 1 := c_YES;
    REPLY_CAN_RECEIVE_DATA : integer range 0 to 1 := c_YES
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_IN        : in  std_logic;
    MED_DATA_IN             : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN       : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT            : out std_logic;
    MED_ERROR_IN            : in  std_logic_vector (2 downto 0);
    -- Internal direction port
    INT_INIT_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_INIT_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    INT_INIT_DATAREADY_OUT  : out std_logic;
    INT_INIT_READ_IN        : in  std_logic;
    INT_REPLY_DATA_OUT      : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    INT_REPLY_PACKET_NUM_OUT: out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    INT_REPLY_DATAREADY_OUT : out std_logic;
    INT_REPLY_READ_IN       : in  std_logic;
    INT_ERROR_OUT           : out std_logic_vector (2 downto 0);
    -- Status and control port
    STAT_BUFFER_COUNTER     : out std_logic_vector (31 downto 0);
    STAT_DATA_COUNTER       : out std_logic_vector (31 downto 0);
    STAT_BUFFER             : out std_logic_vector (31 downto 0);
    CTRL_STAT               : in  std_logic_vector (15 downto 0)
    );
end entity;

architecture trb_net16_ibuf_arch of trb_net16_ibuf is
  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  --attribute HGROUP of trb_net16_ibuf_arch : architecture  is "IBUF_group";

  signal fifo_data_in          : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal fifo_data_out         : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal fifo_packet_num_in    : std_logic_vector(1 downto 0);
  signal fifo_write, fifo_read : std_logic;
  signal fifo_full, fifo_empty : std_logic;

  signal saved_packet_type     : std_logic_vector(3 downto 0);
  signal current_fifo_packet_type   : std_logic_vector(3 downto 0);
  signal saved_fifo_packet_type     : std_logic_vector(3 downto 0);
  signal comb_fifo_data_out    : std_logic_vector(15 downto 0);
  signal comb_fifo_packet_num_out : std_logic_vector(1 downto 0);

  signal next_read_out, reg_read_out : std_logic;
  signal got_ack_init_internal, reg_ack_init_internal : std_logic;
  signal got_ack_reply_internal, reg_ack_reply_internal : std_logic;
  signal reg_eob_init_out, reg_eob_reply_out : std_logic;
  signal tmp_INT_INIT_DATAREADY_OUT: std_logic;
  signal tmp_INT_REPLY_DATAREADY_OUT: std_logic;
  signal tmp_INT_DATA_OUT: std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal tmp_INT_PACKET_NUM_OUT: std_logic_vector(c_NUM_WIDTH-1 downto 0);

  type ERROR_STATE is (IDLE, GOT_OVERFLOW_ERROR, GOT_UNDEFINED_ERROR);
  signal current_error_state, next_error_state : ERROR_STATE;
  signal next_rec_buffer_size_out, current_rec_buffer_size_out: std_logic_vector(3 downto 0);
  signal fifo_long_packet_num_out : std_logic_vector(c_NUM_WIDTH-1 downto 0);

  signal CRC_RESET, CRC_enable : std_logic;
  signal CRC_match : std_logic;
  signal crc_out   : std_logic_vector(15 downto 0);
  signal crc_active: std_logic; --crc active in this transfer, i.e. no short transfer
  signal crc_data_in : std_logic_vector(15 downto 0);

  signal fifo_data_valid : std_logic;
  signal stat_sbufs : std_logic_vector(1 downto 0);
  signal counter_match : std_logic;
  signal init_buffer_number : std_logic_vector(15 downto 0);
  signal reply_buffer_number : std_logic_vector(15 downto 0);

  signal reg_med_data_in : std_logic_vector(15 downto 0);
  signal reg_med_dataready_in : std_logic;
  signal reg_med_packet_num_in : std_logic_vector(2 downto 0);


  signal is_h0 : std_logic;

  signal fifo_data_waiting   : std_logic := '0';
  signal output_reg_empty    : std_logic := '0';
  signal output_reg_enable   : std_logic := '0';
  signal buf_DATA_OUT        : std_logic_vector(15 downto 0);
  signal buf_PACKET_NUM_OUT  : std_logic_vector(2 downto 0);
  signal buf_INIT_DATAREADY_OUT   : std_logic := '0';
  signal buf_REPLY_DATAREADY_OUT   : std_logic := '0';


  signal fifo_reg_empty    : std_logic;
  signal fifo_output_valid : std_logic;
  signal fifo_reg_enable   : std_logic;
  signal fifo_reg_valid    : std_logic;


  attribute syn_preserve : boolean;
  attribute syn_keep : boolean;
  attribute syn_sharing : string;

  attribute syn_preserve of fifo_data_in : signal is true;
  attribute syn_preserve of fifo_packet_num_in : signal is true;
  attribute syn_keep of fifo_data_in : signal is true;
  attribute syn_keep of fifo_packet_num_in : signal is true;
  attribute syn_sharing of trb_net16_ibuf_arch : architecture is "off";
  attribute syn_keep of reg_med_data_in : signal is true;
  attribute syn_keep of reg_med_dataready_in : signal is true;
  attribute syn_keep of reg_med_packet_num_in : signal is true;
  attribute syn_keep of saved_packet_type : signal is true;
  attribute syn_keep of is_h0 : signal is true;
  attribute syn_preserve of reg_med_data_in : signal is true;
  attribute syn_preserve of reg_med_dataready_in : signal is true;
  attribute syn_preserve of reg_med_packet_num_in : signal is true;
  attribute syn_preserve of saved_packet_type : signal is true;
  attribute syn_preserve of is_h0 : signal is true;



begin

counter_match <= '1';


------------------------
--check incoming data for ACK & fifo status check
------------------------

  is_h0 <= MED_PACKET_NUM_IN(2) and not MED_PACKET_NUM_IN(1) and not MED_PACKET_NUM_IN(0);
           --'1' when MED_PACKET_NUM_IN = c_H0 else '0';

  proc_store_input_packet_type : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          saved_packet_type <= '1' & TYPE_ILLEGAL;
        elsif is_h0 = '1' then
          saved_packet_type <= MED_DATA_IN(3 downto 0);
        end if;
      end if;
    end process;


  proc_filter_input_data : process(reg_MED_DATA_IN, reg_MED_DATAREADY_IN, reg_MED_PACKET_NUM_IN,
                           fifo_full, current_rec_buffer_size_out,
                           current_error_state, reg_read_out, saved_packet_type)
    begin  -- process
      got_ack_init_internal <=   '0';
      got_ack_reply_internal <=   '0';
      next_read_out <= '1';
      fifo_write <=  '0';
      next_rec_buffer_size_out <= current_rec_buffer_size_out;
      next_error_state <= current_error_state;
      if reg_MED_DATAREADY_IN = '1' and reg_read_out= '1' then
        if saved_packet_type(2 downto 0) = TYPE_ACK and USE_ACKNOWLEDGE = 1 then
          if reg_MED_PACKET_NUM_IN = c_H0 and current_error_state /= GOT_OVERFLOW_ERROR then
            got_ack_init_internal <= not saved_packet_type(3);
            got_ack_reply_internal <=    saved_packet_type(3);
          end if;
          if reg_MED_PACKET_NUM_IN = c_F1 then
            next_rec_buffer_size_out <= reg_MED_DATA_IN(3 downto 0);
          end if;
        elsif not (saved_packet_type(2 downto 0) = TYPE_ILLEGAL) then
          fifo_write <=  '1';
          if fifo_full = '1' then
            next_error_state <= GOT_OVERFLOW_ERROR;
          end if;
        end if;
      end if;
    end process;

  MED_READ_OUT <= reg_read_out;

  reg_buffer: process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        current_rec_buffer_size_out <= x"6";
        reg_ack_init_internal    <= '0';
        reg_ack_reply_internal   <= '0';
        reg_read_out             <= '0';
        current_error_state      <= IDLE;
      else
        current_rec_buffer_size_out <= next_rec_buffer_size_out;
        reg_ack_init_internal    <= got_ack_init_internal;
        reg_ack_reply_internal   <= got_ack_reply_internal;
        reg_read_out             <= next_read_out;
        current_error_state      <= next_error_state;
      end if;
    end if;
  end process;



------------------------
--FIFO Input
------------------------

  PROC_REG_INPUT : process(CLK)
    begin
      if rising_edge(CLK) then
        reg_med_data_in <= MED_DATA_IN;
        reg_med_packet_num_in  <= MED_PACKET_NUM_IN;
        reg_med_dataready_in   <= MED_DATAREADY_IN;
      end if;
    end process;

 fifo_data_in <= reg_med_data_in;
 fifo_packet_num_in <= reg_med_packet_num_in(2) & reg_med_packet_num_in(0);


------------------------
--save the current packet type from fifo output (including init/reply channel)
------------------------

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          saved_fifo_packet_type <= '1' & TYPE_ILLEGAL;
        elsif fifo_long_packet_num_out = c_H0 and fifo_reg_valid = '1' then
          saved_fifo_packet_type <= fifo_data_out(3 downto 0);
        end if;
      end if;
    end process;

  current_fifo_packet_type <= fifo_data_out(3 downto 0) when (fifo_long_packet_num_out = c_H0 and fifo_reg_valid = '1')
                              else saved_fifo_packet_type;



------------------------
--CRC check
------------------------

  gen_crc : if USE_CHECKSUM = c_YES generate
    THE_CRC : trb_net_CRC
      port map(
        CLK     => CLK,
        RESET   => CRC_RESET,
        CLK_EN  => CRC_enable,
        DATA_IN => crc_data_in,
        CRC_OUT => crc_out,
        CRC_match => CRC_match
        );

    process(fifo_data_out, fifo_reg_valid, fifo_long_packet_num_out, current_fifo_packet_type)
      begin
        crc_data_in <= fifo_data_out;
        CRC_enable <= fifo_reg_valid and not fifo_long_packet_num_out(2);
        if (current_fifo_packet_type(2 downto 0) = TYPE_TRM or current_fifo_packet_type(2 downto 0) = TYPE_EOB)  and fifo_long_packet_num_out /= c_F0 then
          CRC_enable <= '0';
        end if;
      end process;

    PROC_SAVE_CRC_USED : process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' or (current_fifo_packet_type(2 downto 0) = TYPE_TRM and fifo_long_packet_num_out = c_F3) then
            CRC_active <= '0';
          elsif (CRC_enable = '1' and current_fifo_packet_type(2 downto 0) /= TYPE_TRM) then
            CRC_active <= '1';
          end if;
        end if;
      end process;

  end generate;

  gen_no_crc : if USE_CHECKSUM = c_NO generate
    CRC_match <= '1';
    CRC_active <= '0';
  end generate;

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
------------------------
--the input fifo
------------------------
  THE_FIFO: trb_net16_fifo
    generic map (
      DEPTH => DEPTH
      )
    port map (
      CLK       => CLK,
      RESET     => RESET,
      CLK_EN    => CLK_EN,
      DATA_IN   => fifo_data_in,
      PACKET_NUM_IN => fifo_packet_num_in,
      WRITE_ENABLE_IN => fifo_write,
      DATA_OUT  => comb_fifo_data_out,
      PACKET_NUM_OUT => comb_fifo_packet_num_out,
      READ_ENABLE_IN => fifo_read,
      FULL_OUT  => fifo_full,
      EMPTY_OUT => fifo_empty
      );


------------------------
--Register FIFO Output
------------------------

  --register fifo output
  PROC_SYNC_FIFO_OUTPUTS : process(CLK)
    begin
      if rising_edge(CLK) then
        fifo_output_valid <= (fifo_read and not fifo_empty) or (fifo_output_valid and not fifo_reg_enable);
        if fifo_reg_valid = '1' and output_reg_enable = '1' then
          fifo_reg_valid <= '0';
        end if;
        if fifo_reg_enable = '1' and fifo_output_valid = '1' then
          fifo_data_out <= comb_fifo_data_out;
          fifo_reg_valid <= '1';
        end if;
      end if;
    end process;

  fifo_read <= (INT_INIT_READ_IN and buf_INIT_DATAREADY_OUT) or (INT_REPLY_READ_IN and buf_REPLY_DATAREADY_OUT) or
               (output_reg_empty or fifo_reg_empty or not fifo_output_valid);
--
-- (INT_INIT_READ_IN or init_output_reg_empty) and (INT_REPLY_READ_IN or reply_output_reg_empty)
--                and not (fifo_valid_read )
--                (init_output_reg_empty and reply_output_reg_empty and not fifo_valid_read);

  --generate full packet number
  proc_make_full_packet_number : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          fifo_long_packet_num_out <= (others => '0');
        elsif fifo_reg_enable = '1' and fifo_output_valid = '1' then
          fifo_long_packet_num_out(2) <= comb_fifo_packet_num_out(1);
          fifo_long_packet_num_out(0) <= comb_fifo_packet_num_out(0);
          if fifo_long_packet_num_out(2) = '0' and fifo_long_packet_num_out(0) = '1' then
            fifo_long_packet_num_out(1) <= not fifo_long_packet_num_out(1);
          else
            fifo_long_packet_num_out(1) <= fifo_long_packet_num_out(1);
          end if;
        end if;
      end if;
    end process;


------------------------
--Handle FiFo output
------------------------

  --copy fifo dout
  PROC_GEN_DATA_OUT : process(fifo_data_out, fifo_long_packet_num_out, current_fifo_packet_type,
                              CRC_match, counter_match, CRC_active)
    begin
      tmp_INT_DATA_OUT <= fifo_data_out;
      tmp_INT_PACKET_NUM_OUT <= fifo_long_packet_num_out;
      if USE_CHECKSUM = 1 then
        if current_fifo_packet_type(2 downto 0) = TYPE_TRM and fifo_long_packet_num_out = c_F2 and CRC_active = '1' then
          tmp_INT_DATA_OUT(3) <= fifo_data_out(3) or not CRC_match;
          tmp_INT_DATA_OUT(4) <= fifo_data_out(4) or not counter_match;
        end if;
      end if;
    end process;


  fifo_reg_enable   <= output_reg_enable or fifo_reg_empty;

  output_reg_enable <= (INT_INIT_READ_IN and buf_INIT_DATAREADY_OUT) or (INT_REPLY_READ_IN and buf_REPLY_DATAREADY_OUT) or output_reg_empty;

  output_reg_empty   <= not buf_INIT_DATAREADY_OUT and not buf_REPLY_DATAREADY_OUT;
  fifo_reg_empty     <= output_reg_enable and not fifo_reg_valid;


  --set dataready out
  PROC_MAKE_DATAREADY : process(fifo_reg_valid, fifo_data_waiting, current_fifo_packet_type, output_reg_enable)
    begin
      if ((fifo_reg_valid = '1' or fifo_data_waiting = '1') and (current_fifo_packet_type(2 downto 0) /= TYPE_EOB)) then
        tmp_INT_INIT_DATAREADY_OUT  <= output_reg_enable and not current_fifo_packet_type(3);
        tmp_INT_REPLY_DATAREADY_OUT <= output_reg_enable and     current_fifo_packet_type(3);
      else
        tmp_INT_INIT_DATAREADY_OUT <= '0';
        tmp_INT_REPLY_DATAREADY_OUT <= '0';
      end if;
    end process;

  proc_reg_waiting_data: process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          fifo_data_waiting <= '0';
        elsif ((fifo_reg_valid = '1' or fifo_data_waiting = '1') and (current_fifo_packet_type(2 downto 0) /= TYPE_EOB)) then
          fifo_data_waiting <= not output_reg_enable;
        end if;
      end if;
    end process;


  --reset CRC generator
  CRC_RESET <= '1' when current_fifo_packet_type(2 downto 0) = TYPE_TRM and fifo_long_packet_num_out = c_F3 else RESET;

  --Trigger sending ACK
  gen_ack1 : if USE_ACKNOWLEDGE = 1 generate
    proc_reg_eob_out: process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            reg_eob_init_out <= '0';
            reg_eob_reply_out <= '0';
          elsif fifo_reg_valid = '1' and USE_ACKNOWLEDGE = 1 then
            if (   current_fifo_packet_type(2 downto 0) = TYPE_EOB
                or current_fifo_packet_type(2 downto 0) = TYPE_TRM) and fifo_long_packet_num_out = c_F3 then
              reg_eob_init_out  <= not current_fifo_packet_type(3);
              reg_eob_reply_out <= current_fifo_packet_type(3);
            end if;
          else
            reg_eob_init_out <= '0';
            reg_eob_reply_out <= '0';
          end if;
        end if;
      end process;

  --Count received buffers
    proc_count_buffers : process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            init_buffer_number <= (others => '1');
            reply_buffer_number <= (others => '1');
          elsif CLK_EN = '1' then
            if reg_eob_init_out = '1' then
              init_buffer_number <= init_buffer_number + 1;
            end if;
            if reg_eob_reply_out = '1' then
              reply_buffer_number <= reply_buffer_number + 1;
            end if;
          end if;
        end if;
      end process;
  end generate;





------------------------
--Output logic
------------------------
  PROC_output_reg : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          buf_INIT_DATAREADY_OUT <= '0';
        elsif output_reg_enable = '1' then
          buf_DATA_OUT       <= tmp_INT_DATA_OUT;
          buf_PACKET_NUM_OUT <= tmp_INT_PACKET_NUM_OUT;
          buf_INIT_DATAREADY_OUT  <= tmp_INT_INIT_DATAREADY_OUT;
          buf_REPLY_DATAREADY_OUT <= tmp_INT_REPLY_DATAREADY_OUT;
        end if;
      end if;
    end process;


  gen_init_sbuf : if INIT_CAN_RECEIVE_DATA = c_YES generate
    INT_INIT_DATA_OUT       <= buf_DATA_OUT;
    INT_INIT_PACKET_NUM_OUT <= buf_PACKET_NUM_OUT;
    INT_INIT_DATAREADY_OUT  <= buf_INIT_DATAREADY_OUT;
  end generate;
  gen_no_init_sbuf : if INIT_CAN_RECEIVE_DATA = c_NO generate
    INT_INIT_DATA_OUT <= (others => '0');
    INT_INIT_PACKET_NUM_OUT <= (others => '0');
    INT_INIT_DATAREADY_OUT <= '0';
  end generate;

  gen_reply_sbuf : if REPLY_CAN_RECEIVE_DATA = c_YES generate
    INT_REPLY_DATA_OUT       <= buf_DATA_OUT;
    INT_REPLY_PACKET_NUM_OUT <= buf_PACKET_NUM_OUT;
    INT_REPLY_DATAREADY_OUT  <= buf_REPLY_DATAREADY_OUT;
  end generate;
  gen_no_reply_sbuf : if REPLY_CAN_RECEIVE_DATA = c_NO generate
    INT_REPLY_DATA_OUT <= (others => '0');
    INT_REPLY_PACKET_NUM_OUT <= (others => '0');
    INT_REPLY_DATAREADY_OUT <= '0';
  end generate;

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

------------------------
--Debugging Signals
------------------------

  STAT_BUFFER_COUNTER <= reply_buffer_number & init_buffer_number;
  stat_sbufs <= "00";
-- make STAT_BUFFER
  STAT_BUFFER(3 downto 0) <= std_logic_vector(to_unsigned(DEPTH,4));
  STAT_BUFFER(7 downto 4) <= current_rec_buffer_size_out;

  gen_ack2 : if USE_ACKNOWLEDGE = 1 generate
    STAT_BUFFER(8) <= reg_eob_init_out;
    STAT_BUFFER(9) <= reg_ack_init_internal;
    STAT_BUFFER(10) <= reg_eob_reply_out;
    STAT_BUFFER(11) <= reg_ack_reply_internal;
  end generate;
  gen_ack3 : if USE_ACKNOWLEDGE = 0 generate
    STAT_BUFFER(11 downto 8) <= (others => '0');
  end generate;

  process(current_error_state)
    begin
      case current_error_state is
        when IDLE               => STAT_BUFFER(13 downto 12) <= "00";
        when GOT_OVERFLOW_ERROR => STAT_BUFFER(13 downto 12) <= "01";
        when others             => STAT_BUFFER(13 downto 12) <= "11";
      end case;
    end process;

  STAT_BUFFER(14) <= fifo_write;
  STAT_BUFFER(17 downto 15) <= saved_packet_type(2 downto 0);
  STAT_BUFFER(18)           <= CRC_match;
  STAT_BUFFER(19)           <= CRC_enable;
  STAT_BUFFER(20)           <= CRC_RESET;
  STAT_BUFFER(31 downto 21) <= (others => '0');


  INT_ERROR_OUT <= MED_ERROR_IN;

end architecture;

