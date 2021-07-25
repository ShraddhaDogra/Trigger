library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

-- Missing:
-- Missing event check
-- wrong length of words in fifo check
-- speed-up? 2 cycles instead of 3


entity handler_ipu is
  generic(
    DATA_INTERFACE_NUMBER        : integer range 1 to 16        := 1
    );
  port(
    CLOCK                        : in  std_logic;
    RESET                        : in  std_logic;

    --From Data Handler
    DAT_DATA_IN                  : in  std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
    DAT_DATA_READ_OUT            : out std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
    DAT_DATA_EMPTY_IN            : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
    DAT_DATA_LENGTH_IN           : in  std_logic_vector(DATA_INTERFACE_NUMBER*16-1 downto 0);
    DAT_DATA_FLAGS_IN            : in  std_logic_vector(DATA_INTERFACE_NUMBER*4-1 downto 0);
    DAT_HDR_DATA_IN              : in  std_logic_vector(31 downto 0);
    DAT_HDR_DATA_READ_OUT        : out std_logic;
    DAT_HDR_DATA_EMPTY_IN        : in  std_logic;

    --To IPU Channel
    IPU_NUMBER_IN                : in  std_logic_vector (15 downto 0);
    IPU_INFORMATION_IN           : in  std_logic_vector (7  downto 0);
    IPU_READOUT_TYPE_IN          : in  std_logic_vector (3  downto 0);
    IPU_START_READOUT_IN         : in  std_logic;
    IPU_DATA_OUT                 : out std_logic_vector (31 downto 0);
    IPU_DATAREADY_OUT            : out std_logic;
    IPU_READOUT_FINISHED_OUT     : out std_logic;
    IPU_READ_IN                  : in  std_logic;
    IPU_LENGTH_OUT               : out std_logic_vector (15 downto 0);
    IPU_ERROR_PATTERN_OUT        : out std_logic_vector (31 downto 0);

    --Debug
    STATUS_OUT                   : out std_logic_vector(31 downto 0)
    );

end entity;

architecture handler_ipu_arch of handler_ipu is

  type cnt10_DAT_t is array (DATA_INTERFACE_NUMBER-1 downto 0) of unsigned(15 downto 0);
  type fsm_state_t is (IDLE, WAIT_FOR_LENGTH, SEND_DHDR, READ_DATA, END_READOUT, SEND_FAIL);
  signal current_state,          next_state                    : fsm_state_t;
  signal state_bits                                            : std_logic_vector(3 downto 0);

  signal error_not_found,        next_error_not_found          : std_logic;
  signal error_lvl1,             next_error_lvl1               : std_logic;
  signal error_sync                                            : std_logic;
  signal error_missing,          next_error_missing            : std_logic;
  signal error_not_configured                                  : std_logic;

  signal hdr_fifo_read,          next_hdr_fifo_read            : std_logic;
  signal hdr_fifo_valid_read,    next_hdr_fifo_valid_read      : std_logic;
  signal last_hdr_fifo_valid_read                              : std_logic;
  signal first_fifo_read,        next_first_fifo_read          : std_logic;
  signal hdr_data_waiting,       next_hdr_data_waiting         : std_logic;

  signal dat_fifo_read                                         : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal dat_fifo_select,        next_dat_fifo_select          : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal dat_fifo_finished                                     : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal dat_fifo_read_length                                  : cnt10_DAT_t := (others => (others => '0'));
  signal dat_fifo_valid_read,    next_dat_fifo_valid_read      : std_logic;

  signal ipu_dataready_i,        next_ipu_dataready_i          : std_logic;
  signal ipu_data_i,             next_ipu_data_i               : std_logic_vector(31 downto 0);
  signal ipu_finished_i,         next_ipu_finished_i           : std_logic;
  signal ipu_error_pattern_i                                   : std_logic_vector(31 downto 0);
  signal ipu_length_i                                          : std_logic_vector(15 downto 0);

  signal total_length,           next_total_length             : unsigned(15 downto 0);

  signal dat_fifo_number,        next_dat_fifo_number          : integer range 0 to DATA_INTERFACE_NUMBER-1;
  signal suppress_output,        next_suppress_output          : std_logic;

begin
---------------------------------------------------------------------------
-- State Machine
---------------------------------------------------------------------------
  THE_FSM_REG : process(CLOCK)
    begin
      if rising_edge(CLOCK) then
        if RESET = '1' then
          current_state          <= IDLE;
          hdr_fifo_read          <= '0';
          hdr_data_waiting       <= '0';
        else
          current_state          <= next_state;
          error_not_found        <= next_error_not_found;
          error_missing          <= next_error_missing;
          error_lvl1             <= next_error_lvl1;
          hdr_fifo_read          <= next_hdr_fifo_read;
          ipu_finished_i         <= next_ipu_finished_i;
          ipu_dataready_i        <= next_ipu_dataready_i;
          ipu_data_i             <= next_ipu_data_i;
          dat_fifo_select        <= next_dat_fifo_select;
          first_fifo_read        <= next_first_fifo_read;
          dat_fifo_number        <= next_dat_fifo_number;
          suppress_output        <= next_suppress_output;
          hdr_data_waiting       <= next_hdr_data_waiting;
        end if;
      end if;
    end process;


  THE_FSM : process(current_state, error_not_found, IPU_START_READOUT_IN, DAT_HDR_DATA_EMPTY_IN,
                    DAT_HDR_DATA_IN, last_hdr_fifo_valid_read, ipu_dataready_i, IPU_READ_IN,
                    error_missing, dat_fifo_valid_read, next_dat_fifo_number, error_lvl1,
                    dat_fifo_finished, dat_fifo_number, DAT_DATA_IN, suppress_output, hdr_data_waiting)
    begin
      next_state                 <= current_state;
      next_error_not_found       <= error_not_found;
      next_error_missing         <= error_missing;
      next_error_lvl1            <= error_lvl1;
      next_hdr_fifo_read         <= '0';
      next_ipu_data_i            <= (others => '0');
      next_ipu_dataready_i       <= '0';
      next_ipu_finished_i        <= '0';
      next_first_fifo_read       <= '0';
      next_dat_fifo_number       <= dat_fifo_number;
      next_suppress_output       <= suppress_output;
      next_hdr_data_waiting      <= hdr_data_waiting;

      case current_state is
        when IDLE =>
          if IPU_START_READOUT_IN = '1' then
            if DAT_HDR_DATA_EMPTY_IN = '0' and hdr_data_waiting = '0' then
              next_state           <= WAIT_FOR_LENGTH;
              next_hdr_fifo_read   <= '1';
            elsif hdr_data_waiting = '1' then
              next_state           <= WAIT_FOR_LENGTH;            
            end if;
            next_error_not_found <= '0';
            next_error_missing   <= '0';
            next_error_lvl1      <= '0';
            next_dat_fifo_number <=  0;
          end if;

        when WAIT_FOR_LENGTH =>
          if last_hdr_fifo_valid_read = '1' or hdr_data_waiting = '1' then
            if DAT_HDR_DATA_IN(15 downto 0) = IPU_NUMBER_IN then
              next_state <= SEND_DHDR;
              next_suppress_output <= DAT_HDR_DATA_IN(28);
              next_error_lvl1      <= DAT_HDR_DATA_IN(29);
              next_error_missing   <= DAT_HDR_DATA_IN(30);
              next_hdr_data_waiting<= '0';
            else
              next_state <= SEND_FAIL;
              next_error_not_found  <= '1';
              next_hdr_data_waiting <= '1';
            end if;
          end if;  

        when SEND_DHDR =>
          next_ipu_data_i      <= x"0" & DAT_HDR_DATA_IN(27 downto 0);
          next_ipu_dataready_i <= '1';
          if ipu_dataready_i = '1' and IPU_READ_IN = '1' then
            next_state              <= READ_DATA;
            next_dat_fifo_number    <=  0;
            next_first_fifo_read    <= not dat_fifo_finished(0);
            next_ipu_dataready_i    <= '0';
          end if;

        when READ_DATA =>
          if dat_fifo_finished(dat_fifo_number) = '1' and IPU_READ_IN = '1' then
            if dat_fifo_number = DATA_INTERFACE_NUMBER-1 then
              next_state <= END_READOUT;
            else
              next_dat_fifo_number  <= dat_fifo_number + 1;
              next_first_fifo_read  <= not dat_fifo_finished(next_dat_fifo_number);
            end if;
          end if;
          next_ipu_dataready_i <= (dat_fifo_valid_read or (ipu_dataready_i and not IPU_READ_IN));
          next_ipu_data_i      <= DAT_DATA_IN(dat_fifo_number*32+31 downto dat_fifo_number*32);

        when SEND_FAIL => 
          next_ipu_dataready_i <= '1';
          next_ipu_data_i      <= x"0" & DAT_HDR_DATA_IN(27 downto 0);
          if ipu_dataready_i = '1' and IPU_READ_IN = '1' then
            next_ipu_dataready_i <= '0';
            next_state           <= END_READOUT;
          end if;  
          
        when END_READOUT =>
          next_ipu_finished_i <= '1';
          if IPU_START_READOUT_IN = '0' then
            next_state        <= IDLE;
          end if;

      end case;
    end process;

  PROC_DAT_FIFO_SELECT : process(next_dat_fifo_number, next_state)
    begin
      next_dat_fifo_select <= (others => '0');
      if next_state = READ_DATA then
        next_dat_fifo_select(next_dat_fifo_number) <= '1';
      end if;
    end process;

---------------------------------------------------------------------------
-- Data Fifo Handling
---------------------------------------------------------------------------
  gen_fifo_read : for i in 0 to DATA_INTERFACE_NUMBER-1 generate

    --Read signal for data fifos
    dat_fifo_read(i) <= dat_fifo_select(i) and ((IPU_READ_IN and (ipu_dataready_i)) or first_fifo_read) and not dat_fifo_finished(i);


    --Count words read from data fifos
    PROC_DAT_FIFO_COUNT : process(CLOCK)
      begin
        if rising_edge(CLOCK) then
          if hdr_fifo_valid_read = '1' then
            dat_fifo_read_length(i) <= unsigned(DAT_DATA_LENGTH_IN(i*16+15 downto i*16));
          elsif next_dat_fifo_valid_read = '1' and dat_fifo_select(i) = '1' then --dat_fifo_read
            dat_fifo_read_length(i) <= dat_fifo_read_length(i) - to_unsigned(1,1);
          end if;
        end if;
      end process;


    --Compare counter to read value from hdr_fifo and set finished signal
    PROC_DAT_FIFO_FINISHED : process(CLOCK)
      begin
        if rising_edge(CLOCK) then
          if hdr_fifo_valid_read = '1' then
            dat_fifo_finished(i) <= '0';
          elsif   -- (dat_fifo_read_length(i) = to_unsigned(1,10) and dat_fifo_read(i) = '1') or
                 dat_fifo_read_length(i) = 0  then
            dat_fifo_finished(i) <= '1';
          end if;
        end if;
      end process;

  end generate;

  PROC_DAT_FIFO_VALID_READ : process(CLOCK)
    begin
      if rising_edge(CLOCK) then
        next_dat_fifo_valid_read <= or_all(dat_fifo_read and dat_fifo_select) and not or_all(DAT_DATA_EMPTY_IN and dat_fifo_select);
        dat_fifo_valid_read      <= next_dat_fifo_valid_read;
      end if;
    end process;


---------------------------------------------------------------------------
-- Header fifo read
---------------------------------------------------------------------------
  PROC_HDR_FIFO_VALID_READ : process(CLOCK)
    begin
      if rising_edge(CLOCK) then
        next_hdr_fifo_valid_read <= hdr_fifo_read and not DAT_HDR_DATA_EMPTY_IN;
        hdr_fifo_valid_read      <= next_hdr_fifo_valid_read;
        last_hdr_fifo_valid_read <= hdr_fifo_valid_read;
        if next_hdr_data_waiting = '1' then
          total_length <= (others => '0');
        elsif last_hdr_fifo_valid_read = '1' then
          total_length           <= next_total_length;
        end if;
      end if;
    end process;

---------------------------------------------------------------------------
-- Some hand-written adders (gives a bit better results...)
---------------------------------------------------------------------------
  gen_add_1 : if DATA_INTERFACE_NUMBER = 1 generate
    next_total_length <= (dat_fifo_read_length(0));
  end generate;
  gen_add_2 : if DATA_INTERFACE_NUMBER = 2 generate
    next_total_length <= ((dat_fifo_read_length(0)) + (dat_fifo_read_length(1)));
  end generate;
  gen_add_3 : if DATA_INTERFACE_NUMBER = 3 generate
    next_total_length <= ((dat_fifo_read_length(0)) + (dat_fifo_read_length(1))) +
                          (dat_fifo_read_length(2));
  end generate;
  gen_add_4 : if DATA_INTERFACE_NUMBER = 4 generate
    next_total_length <= ((dat_fifo_read_length(0)) + (dat_fifo_read_length(1))) +
                         ((dat_fifo_read_length(2)) + (dat_fifo_read_length(3)));
  end generate;
  gen_add_5 : if DATA_INTERFACE_NUMBER = 5 generate
    next_total_length <= ((dat_fifo_read_length(0)) + (dat_fifo_read_length(1))) +
                         ((dat_fifo_read_length(2)) + (dat_fifo_read_length(3))) +
                         ((dat_fifo_read_length(4)));
  end generate;
  gen_add_6 : if DATA_INTERFACE_NUMBER = 6 generate
    next_total_length <= ((dat_fifo_read_length(0)) + (dat_fifo_read_length(1))) +
                         ((dat_fifo_read_length(2)) + (dat_fifo_read_length(3))) +
                         ((dat_fifo_read_length(4)) + (dat_fifo_read_length(5)));
  end generate;
  gen_add_7 : if DATA_INTERFACE_NUMBER = 7 generate
    next_total_length <= (((dat_fifo_read_length(0)) + (dat_fifo_read_length(1))) +
                          ((dat_fifo_read_length(2)) + (dat_fifo_read_length(3)))) +
                         (((dat_fifo_read_length(4)) + (dat_fifo_read_length(5))) +
                          ((dat_fifo_read_length(6))));
  end generate;
  gen_add_12 : if DATA_INTERFACE_NUMBER = 12 generate
    next_total_length <= (((dat_fifo_read_length(0)) + (dat_fifo_read_length(1))) +
                          ((dat_fifo_read_length(2)) + (dat_fifo_read_length(3)))) +
                         (((dat_fifo_read_length(4)) + (dat_fifo_read_length(5))) +
                          ((dat_fifo_read_length(6)) + (dat_fifo_read_length(7)))) + 
                         (((dat_fifo_read_length(8)) + (dat_fifo_read_length(9))) +
                          ((dat_fifo_read_length(10)) + (dat_fifo_read_length(11))));
  end generate;
  
  gen_add_13 : if DATA_INTERFACE_NUMBER = 13 generate
    next_total_length <= (((dat_fifo_read_length(0)) + (dat_fifo_read_length(1))) +
                          ((dat_fifo_read_length(2)) + (dat_fifo_read_length(3)))) +
                         (((dat_fifo_read_length(4)) + (dat_fifo_read_length(5))) +
                          ((dat_fifo_read_length(6)) + (dat_fifo_read_length(7)))) + 
                         (((dat_fifo_read_length(8)) + (dat_fifo_read_length(9))) +
                          ((dat_fifo_read_length(10)) + (dat_fifo_read_length(11)))) +
                         (((dat_fifo_read_length(12)))) 
                          ;
  end generate;
  
  gen_add_14 : if DATA_INTERFACE_NUMBER = 14 generate
    next_total_length <= (((dat_fifo_read_length(0)) + (dat_fifo_read_length(1))) +
                          ((dat_fifo_read_length(2)) + (dat_fifo_read_length(3)))) +
                         (((dat_fifo_read_length(4)) + (dat_fifo_read_length(5))) +
                          ((dat_fifo_read_length(6)) + (dat_fifo_read_length(7)))) + 
                         (((dat_fifo_read_length(8)) + (dat_fifo_read_length(9))) +
                          ((dat_fifo_read_length(10)) + (dat_fifo_read_length(11)))) +
                         (((dat_fifo_read_length(12)) + (dat_fifo_read_length(13)))) 
                          ;
  end generate;

assert    (
  DATA_INTERFACE_NUMBER <= 7 
  or DATA_INTERFACE_NUMBER = 12 
  or DATA_INTERFACE_NUMBER = 13 
  or DATA_INTERFACE_NUMBER = 14
)
         report "The number of data interfaces must be lower than 8 or equal 12, 13 or 14." severity error;
  
  
---------------------------------------------------------------------------
-- Compare Event Information
---------------------------------------------------------------------------

--   PROC_COMPARE_NUMBER : process(CLOCK)
--     begin
--       if rising_edge(CLOCK) then
--         if current_state = IDLE then
--           error_sync <= '0';
--         elsif dat_fifo_valid_read = '1' then
--           if DAT_HDR_DATA_IN(3 downto 0) /= DAT_DATA_FLAGS_IN(dat_fifo_number*4+3 downto dat_fifo_number*4+0) then
--             error_sync <= '1';
--           end if;
--         end if;
--       end if;
--     end process;

  PROC_COMPARE_NUMBER : process
    begin
      wait until rising_edge(CLOCK);
      if current_state = IDLE then
        error_sync <= '0';
      elsif dat_fifo_valid_read = '1' and  (
          DAT_HDR_DATA_IN(0) /= DAT_DATA_FLAGS_IN(dat_fifo_number*4+0) or
          DAT_HDR_DATA_IN(1) /= DAT_DATA_FLAGS_IN(dat_fifo_number*4+1) or
          DAT_HDR_DATA_IN(2) /= DAT_DATA_FLAGS_IN(dat_fifo_number*4+2) or
          DAT_HDR_DATA_IN(3) /= DAT_DATA_FLAGS_IN(dat_fifo_number*4+3)
          ) then
        error_sync <= '1';
      end if;
    end process;

---------------------------------------------------------------------------
-- Connection to IPU Handler
---------------------------------------------------------------------------
  IPU_DATAREADY_OUT              <= ipu_dataready_i and not suppress_output when current_state /= SEND_DHDR else ipu_dataready_i;
  IPU_DATA_OUT                   <= ipu_data_i;
  IPU_LENGTH_OUT                 <= ipu_length_i;
  IPU_ERROR_PATTERN_OUT          <= ipu_error_pattern_i;
  IPU_READOUT_FINISHED_OUT       <= ipu_finished_i;

  ipu_length_i                   <= std_logic_vector(total_length) when suppress_output = '0' else (others => '0');

  DAT_HDR_DATA_READ_OUT          <= hdr_fifo_read;
  DAT_DATA_READ_OUT              <= dat_fifo_read;

---------------------------------------------------------------------------
-- Error and Status Bits
---------------------------------------------------------------------------
  ipu_error_pattern_i(19 downto 0)  <= (others => '0');
  ipu_error_pattern_i(20)           <= error_not_found;      --event not found
  ipu_error_pattern_i(21)           <= error_missing;        --part of data missing
  ipu_error_pattern_i(22)           <= error_sync;           --severe sync problem
  ipu_error_pattern_i(23)           <= error_not_configured; --FEE not configured
  ipu_error_pattern_i(26 downto 24) <= (others => '0');
  ipu_error_pattern_i(27)           <= error_lvl1;
  ipu_error_pattern_i(31 downto 28) <= (others => '0');


  error_not_configured              <= '0';


---------------------------------------------------------------------------
-- Debug
---------------------------------------------------------------------------
  state_bits <=     x"0" when current_state = IDLE
               else x"1" when current_state = WAIT_FOR_LENGTH
--                else x"2" when current_state = GOT_LENGTH
               else x"3" when current_state = SEND_DHDR
               else x"4" when current_state = READ_DATA
               else x"5" when current_state = END_READOUT
               else x"F";

  STATUS_OUT( 3 downto  0)        <= state_bits;
  STATUS_OUT( 4)                  <= dat_fifo_read(0);
  STATUS_OUT( 5)                  <= dat_fifo_valid_read;
  STATUS_OUT( 6)                  <= ipu_dataready_i;
  STATUS_OUT( 7)                  <= IPU_READ_IN;
  STATUS_OUT(11 downto  8)        <= DAT_DATA_FLAGS_IN(3 downto 0);
  STATUS_OUT(12)                  <= error_not_found;
  STATUS_OUT(13)                  <= error_missing;
  STATUS_OUT(14)                  <= error_sync;
  STATUS_OUT(15)                  <= error_not_configured;
  STATUS_OUT(23 downto 16)        <= DAT_HDR_DATA_IN(7 downto 0);
  STATUS_OUT(24)                  <= hdr_data_waiting;
  STATUS_OUT(31 downto 25)        <= (others => '0');


end architecture;
