library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.lattice_ecp2m_fifo.all;

entity handler_data is
  generic(
    DATA_INTERFACE_NUMBER        : integer range 1 to 16         := 1;
    DATA_BUFFER_DEPTH            : integer range 8 to 15         := 12;
    DATA_BUFFER_WIDTH            : integer range 1 to 32         := 32;
    DATA_BUFFER_FULL_THRESH      : integer range 0 to 2**15-1    := 2**12-256;
    TRG_RELEASE_AFTER_DATA       : integer range 0 to 1          := c_YES;
    HEADER_BUFFER_DEPTH          : integer range 8 to 15         := 9;
    HEADER_BUFFER_FULL_THRESH    : integer range 0 to 2**15-1    := 2**9-128
    );
  port(
    CLOCK                        : in  std_logic;
    RESET                        : in  std_logic;

    --LVL1 Handler
    LVL1_VALID_TRIGGER_IN        : in  std_logic;                     --received valid trigger, readout starts
    LVL1_TRG_DATA_VALID_IN       : in  std_logic;                     --TRG Info valid & FEE busy
    LVL1_TRG_TYPE_IN             : in  std_logic_vector(3  downto 0); --trigger type
    LVL1_TRG_INFO_IN             : in  std_logic_vector(23 downto 0); --further trigger details
    LVL1_TRG_CODE_IN             : in  std_logic_vector(7 downto 0);
    LVL1_TRG_NUMBER_IN           : in  std_logic_vector(15 downto 0); --trigger number
    LVL1_STATUSBITS_OUT          : out std_logic_vector(31 downto 0);
    LVL1_TRG_RELEASE_OUT         : out std_logic;

    --FEE
    FEE_DATA_IN                  : in  std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
    FEE_DATA_WRITE_IN            : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
    FEE_DATA_FINISHED_IN         : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
    FEE_DATA_ALMOST_FULL_OUT     : out std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);

    --IPU Handler
    IPU_DATA_OUT                 : out std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
    IPU_DATA_READ_IN             : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
    IPU_DATA_EMPTY_OUT           : out std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
    IPU_DATA_LENGTH_OUT          : out std_logic_vector(DATA_INTERFACE_NUMBER*16-1 downto 0);
    IPU_DATA_FLAGS_OUT           : out std_logic_vector(DATA_INTERFACE_NUMBER*4-1 downto 0);

    IPU_HDR_DATA_OUT             : out std_logic_vector(31 downto 0);
    IPU_HDR_DATA_READ_IN         : in  std_logic;
    IPU_HDR_DATA_EMPTY_OUT       : out std_logic;

    TMG_TRG_ERROR_IN             : in  std_logic;
    MAX_EVENT_SIZE_IN            : in  std_logic_vector(15 downto 0) := x"FFFF";
    BUFFER_DISABLE_IN            : in  std_logic_vector(15 downto 0) := x"0000";
    --Status
    STAT_DATA_BUFFER_LEVEL       : out std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
    STAT_HEADER_BUFFER_LEVEL     : out std_logic_vector(31 downto 0);
    --Debug
    DEBUG_OUT                    : out std_logic_vector(31 downto 0)
    );

end entity;

---------------------------------------------------------------------------
-- LVL1 Info FiFo
-- 15 -  0 : trigger number
-- 23 - 16 : trigger code
-- 27 - 24 : trigger type
-- 28      : suppress data
-- 29      : timing trigger error
-- Fifo has an internal output register.
-- Output is valid two clock cycles after read

-- Data FiFo
-- 31 -  0 : FEE data
-- 35 - 32 : trigger number 3..0
-- Fifo has an internal output register.
-- Output is valid two clock cycles after read

-- Status Buffer Level
-- 15 - 0  : fill level
-- 16      : fifo empty
-- 17      : fifo almost full
-- 18      : fifo full
-- 19      : fifo write
-- 20      : buffer idle
-- 21      : buffer busy
-- 22      : buffer waiting
-- 23      :
-- 24      : length fifo empty
-- 25      : length fifo almost full
-- 26      : length fifo full
-- 27      : length fifo write

---------------------------------------------------------------------------

architecture handler_data_arch of handler_data is

  constant buffer_half_threshold   : integer := 2** (DATA_BUFFER_DEPTH-1);
  constant buffer_end_threshold    : integer := 2**DATA_BUFFER_DEPTH - 2*(2**DATA_BUFFER_DEPTH-DATA_BUFFER_FULL_THRESH);
                      --double set threshold to set flag in error pattern and register
  constant data_width              : integer := DATA_BUFFER_WIDTH + 4;
  type buffer_state_t     is (IDLE, BUSY, WAITING);
  type lvl1_state_t       is (IDLE, WAIT_BUSY, BUSY_RELEASE);
  type cnt16_DAT_t        is array (DATA_INTERFACE_NUMBER-1 downto 0) of unsigned(15 downto 0);
  type bits3_t            is array (DATA_INTERFACE_NUMBER-1 downto 0) of std_logic_vector(2 downto 0);
  type buffer_state_arr_t is array (DATA_INTERFACE_NUMBER-1 downto 0) of buffer_state_t;


  signal data_buffer_data_in       : std_logic_vector(DATA_INTERFACE_NUMBER*data_width-1 downto 0);
  signal data_buffer_data_out      : std_logic_vector(DATA_INTERFACE_NUMBER*data_width-1 downto 0);
  signal data_buffer_filllevel     : std_logic_vector(DATA_INTERFACE_NUMBER*(DATA_BUFFER_DEPTH+1)-1 downto 0);
  signal data_buffer_full          : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal data_buffer_empty         : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal data_buffer_almost_full   : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);

  signal header_buffer_data_in     : std_logic_vector(36-1 downto 0);
  signal header_buffer_data_out    : std_logic_vector(36-1 downto 0);
  signal header_buffer_filllevel   : std_logic_vector(HEADER_BUFFER_DEPTH downto 0);
  signal header_buffer_full        : std_logic;
  signal header_buffer_empty       : std_logic;
  signal header_buffer_almost_full : std_logic;
  signal header_buffer_write       : std_logic := '0';

  signal lvl1_busy_release_i       : std_logic;
  signal lvl1_statusbits_i         : std_logic_vector(31 downto 0);

  signal got_busy_release          : std_logic_vector(DATA_INTERFACE_NUMBER downto 0);
  signal data_buffer_write         : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal data_counter              : cnt16_DAT_t;
  signal buffer_state_bits         : bits3_t;
  signal lvl1_state_bits           : std_logic_vector(2 downto 0);

  signal current_buffer_state      : buffer_state_arr_t;
  signal current_lvl1_state        : lvl1_state_t;

  signal length_buffer_data_in     : std_logic_vector(DATA_INTERFACE_NUMBER*18-1 downto 0);
  signal length_buffer_data_out    : std_logic_vector(DATA_INTERFACE_NUMBER*18-1 downto 0);
  signal length_buffer_write       : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0) := (others => '0');
  signal length_buffer_empty       : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal length_buffer_full        : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal length_buffer_almost_full : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);

  signal flag_almost_full          : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal flag_half_full            : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
  signal flag_almost_full_combined : std_logic;
  signal flag_half_full_combined   : std_logic;

  signal tmg_trg_error_i           : std_logic;
  signal partially_missing_i       : std_logic;
  signal fee_write_overflow        : std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
begin

  assert DATA_BUFFER_FULL_THRESH >= (2**DATA_BUFFER_DEPTH)/2     report "Data buffer threshold too high" severity error;
  assert HEADER_BUFFER_FULL_THRESH < 2**HEADER_BUFFER_DEPTH-2 report "Header buffer threshold too high" severity error;

---------------------------------------------------------------------------
-- FEE & IPU I/O
---------------------------------------------------------------------------
  FEE_DATA_ALMOST_FULL_OUT       <= data_buffer_almost_full;

  IPU_HDR_DATA_EMPTY_OUT         <= header_buffer_empty;
  IPU_HDR_DATA_OUT               <= header_buffer_data_out(31 downto 0);
  IPU_DATA_EMPTY_OUT             <= data_buffer_empty;

  LVL1_TRG_RELEASE_OUT           <= lvl1_busy_release_i;


---------------------------------------------------------------------------
-- Generate Fifo I/O
---------------------------------------------------------------------------
  gen_fifo_io : for i in 0 to DATA_INTERFACE_NUMBER-1 generate

    data_buffer_data_in((i+1)*data_width-1 downto i*data_width)
                                 <= LVL1_TRG_NUMBER_IN(3 downto 0) & FEE_DATA_IN((i+1)*DATA_BUFFER_WIDTH-1 downto i*DATA_BUFFER_WIDTH);

    IPU_DATA_OUT((i+1)*DATA_BUFFER_WIDTH-1 downto i*DATA_BUFFER_WIDTH)
                                 <= data_buffer_data_out(i*data_width+DATA_BUFFER_WIDTH-1 downto i*data_width);

    IPU_DATA_FLAGS_OUT(i*4+3 downto i*4)
                                 <= data_buffer_data_out((i+1)*data_width-1 downto (i+1)*data_width-4);

  end generate;

  header_buffer_data_in          <= x"0" & "0" & partially_missing_i & tmg_trg_error_i & LVL1_TRG_INFO_IN(0) 
                                    & LVL1_TRG_TYPE_IN & LVL1_TRG_CODE_IN & LVL1_TRG_NUMBER_IN;

  process(CLOCK)
    begin
      if rising_edge(CLOCK) then
        tmg_trg_error_i <= (TMG_TRG_ERROR_IN or tmg_trg_error_i) and not header_buffer_write;
      end if;
    end process;

  partially_missing_i <= or_all(fee_write_overflow);


---------------------------------------------------------------------------
-- Data Fifo(s)
---------------------------------------------------------------------------
  gen_fifos : for i in 0 to DATA_INTERFACE_NUMBER-1 generate

    data_buffer_write(i)         <= FEE_DATA_WRITE_IN(i) and not fee_write_overflow(i) and not BUFFER_DISABLE_IN(i) when current_buffer_state(i) = BUSY else '0';

    THE_DAT_FIFO : fifo_var_oreg
      generic map(
        FIFO_WIDTH               => DATA_BUFFER_WIDTH+4,
        FIFO_DEPTH               => DATA_BUFFER_DEPTH
        )
      port map(
        Data                     => data_buffer_data_in(i*36+35 downto i*36),
        Clock                    => CLOCK,
        WrEn                     => data_buffer_write(i),
        RdEn                     => IPU_DATA_READ_IN(i),
        Reset                    => RESET,
        AmFullThresh             => std_logic_vector(to_unsigned(DATA_BUFFER_FULL_THRESH, DATA_BUFFER_DEPTH)),
        Q                        => data_buffer_data_out(i*36+35 downto i*36),
        WCNT                     => data_buffer_filllevel(i*(DATA_BUFFER_DEPTH+1)+DATA_BUFFER_DEPTH downto i*(DATA_BUFFER_DEPTH+1)),
        Empty                    => data_buffer_empty(i),
        Full                     => data_buffer_full(i),
        AlmostFull               => data_buffer_almost_full(i)
        );
    
    process begin
      wait until rising_edge(CLOCK);
      if(data_counter(i) >= unsigned(MAX_EVENT_SIZE_IN)) then
        fee_write_overflow(i)  <= '1';
      else
        fee_write_overflow(i)  <= '0';
      end if;
    end process;
        
  end generate;


---------------------------------------------------------------------------
-- Header Fifo
---------------------------------------------------------------------------
  THE_HDR_FIFO : fifo_var_oreg
    generic map(
      FIFO_WIDTH                 => 36,
      FIFO_DEPTH                 => HEADER_BUFFER_DEPTH
      )
    port map(
      Data                       => header_buffer_data_in,
      Clock                      => CLOCK,
      WrEn                       => header_buffer_write,
      RdEn                       => IPU_HDR_DATA_READ_IN,
      Reset                      => RESET,
      AmFullThresh               => std_logic_vector(to_unsigned(HEADER_BUFFER_FULL_THRESH, HEADER_BUFFER_DEPTH)),
      Q                          => header_buffer_data_out,
      WCNT                       => header_buffer_filllevel,
      Empty                      => header_buffer_empty,
      Full                       => header_buffer_full,
      AlmostFull                 => header_buffer_almost_full
      );




---------------------------------------------------------------------------
-- Length FIFO
---------------------------------------------------------------------------
  gen_length_fifo : for i in 0 to DATA_INTERFACE_NUMBER-1 generate
    THE_LENGTH_FIFO : fifo_var_oreg
      generic map(
        FIFO_WIDTH               => 18,
        FIFO_DEPTH               => HEADER_BUFFER_DEPTH
        )
      port map(
        Data                     => length_buffer_data_in(i*18+17 downto i*18),
        Clock                    => CLOCK,
        WrEn                     => header_buffer_write, --length_buffer_write(i),
        RdEn                     => IPU_HDR_DATA_READ_IN,
        Reset                    => RESET,
        AmFullThresh             => std_logic_vector(to_unsigned(HEADER_BUFFER_FULL_THRESH, HEADER_BUFFER_DEPTH)),
        Q                        => length_buffer_data_out(i*18+17 downto i*18),
        WCNT                     => open,
        Empty                    => length_buffer_empty(i),
        Full                     => length_buffer_full(i),
        AlmostFull               => length_buffer_almost_full(i)
        );

    IPU_DATA_LENGTH_OUT(i*16+15 downto i*16)  <= length_buffer_data_out(i*18+15 downto i*18);

  end generate;


---------------------------------------------------------------------------
-- Count Length
---------------------------------------------------------------------------
  gen_counter : for i in 0 to DATA_INTERFACE_NUMBER-1 generate
    proc_length_count : process (CLOCK)
      begin
        if rising_edge(CLOCK) then
          if RESET = '1' then
            current_buffer_state(i)        <= IDLE;
          else
            length_buffer_write(i)         <= '0';
            length_buffer_data_in(i*18+17 downto i*18) <= LVL1_TRG_NUMBER_IN(1 downto 0) & std_logic_vector(data_counter(i));

            case current_buffer_state(i) is
              when IDLE =>
                buffer_state_bits(i)       <= "001";
                data_counter(i)            <= to_unsigned(0,16);
                if LVL1_VALID_TRIGGER_IN = '1' then
                  current_buffer_state(i)  <= BUSY;
                end if;

              when BUSY =>
                buffer_state_bits(i)       <= "010";
                if FEE_DATA_WRITE_IN(i) = '1' and fee_write_overflow(i) = '0' and BUFFER_DISABLE_IN(i) = '0' then
                  data_counter(i)          <= data_counter(i) + to_unsigned(1,1);
                end if;
                if FEE_DATA_FINISHED_IN(i) = '1' then
                  current_buffer_state(i)  <= WAITING;
                  length_buffer_write(i)   <= '1';
                end if;

              when WAITING =>
                buffer_state_bits(i)       <= "100";
                if lvl1_busy_release_i = '1' then
                  current_buffer_state(i)  <= IDLE;
                end if;

            end case;
          end if;
        end if;
      end process;
  end generate;

---------------------------------------------------------------------------
-- Busy Logic
---------------------------------------------------------------------------
  proc_busy_logic : process(CLOCK)
    begin
      if rising_edge(CLOCK) then
        if RESET = '1' then
          current_lvl1_state   <= IDLE;
          header_buffer_write  <= '0';
          lvl1_busy_release_i  <= '0';
        else
          lvl1_busy_release_i              <= '0';
          header_buffer_write              <= '0';
          case current_lvl1_state is
            when IDLE =>
              lvl1_state_bits              <= "001";
              if LVL1_VALID_TRIGGER_IN = '1' then
                current_lvl1_state         <= WAIT_BUSY;
              end if;

            when WAIT_BUSY =>
              lvl1_state_bits              <= "010";
              if LVL1_TRG_DATA_VALID_IN = '1' and and_all(got_busy_release) = '1' then
                current_lvl1_state         <= BUSY_RELEASE;
              end if;

            when BUSY_RELEASE =>
              lvl1_state_bits              <= "100";
              lvl1_busy_release_i          <= '1';
              header_buffer_write          <= '1';
              current_lvl1_state           <= IDLE;

          end case;
        end if;
      end if;
    end process;


  proc_data_handler_busy : process(CLOCK)
    begin
      if rising_edge(CLOCK) then
        if RESET = '1' or current_lvl1_state = IDLE then
          got_busy_release <= (others => '0');
        else
          got_busy_release(DATA_INTERFACE_NUMBER-1 downto 0)
                                 <= got_busy_release(DATA_INTERFACE_NUMBER-1 downto 0) or FEE_DATA_FINISHED_IN;
          if TRG_RELEASE_AFTER_DATA = c_NO then
            got_busy_release(DATA_INTERFACE_NUMBER)
                                 <= not (or_all(data_buffer_almost_full) or or_all(length_buffer_almost_full)
                                                                         or header_buffer_almost_full);
          elsif or_all(got_busy_release(DATA_INTERFACE_NUMBER-1 downto 0)) = '1' and
                (or_all(data_buffer_almost_full) or or_all(length_buffer_almost_full) or header_buffer_almost_full) = '0' and LVL1_TRG_DATA_VALID_IN = '1' then
            got_busy_release(DATA_INTERFACE_NUMBER) <= '1';
          end if;
        end if;
      end if;
    end process;

---------------------------------------------------------------------------
-- Filllevel flags
---------------------------------------------------------------------------
  gen_filllevel_flags : for i in 0 to DATA_INTERFACE_NUMBER-1 generate
    proc_filllevel_flag : process(CLOCK)
      begin
        if rising_edge(CLOCK) then
          if unsigned(data_buffer_filllevel(i*(DATA_BUFFER_DEPTH+1)+DATA_BUFFER_DEPTH downto i*(DATA_BUFFER_DEPTH+1)))
                        >= buffer_half_threshold then
            flag_half_full(i) <= '1';
          else
            flag_half_full(i) <= '0';
          end if;
          if unsigned(data_buffer_filllevel(i*(DATA_BUFFER_DEPTH+1)+DATA_BUFFER_DEPTH downto i*(DATA_BUFFER_DEPTH+1)))
                        >= buffer_end_threshold then
            flag_almost_full(i) <= '1';
          else
            flag_almost_full(i) <= '0';
          end if;
        end if;
      end process;
  end generate;

  flag_half_full_combined        <= or_all(flag_half_full);
  flag_almost_full_combined      <= or_all(flag_almost_full);

---------------------------------------------------------------------------
-- Generate Statusbits
---------------------------------------------------------------------------
  LVL1_STATUSBITS_OUT(31 downto 22)        <= (others => '0');
  LVL1_STATUSBITS_OUT(21)                  <= flag_almost_full_combined;
  LVL1_STATUSBITS_OUT(20)                  <= flag_half_full_combined;
  LVL1_STATUSBITS_OUT(19 downto 0)         <= (others => '0');




---------------------------------------------------------------------------
-- Make Status Registers
---------------------------------------------------------------------------
  gen_buf_status : for i in 0 to DATA_INTERFACE_NUMBER-1 generate
    proc_data_buffer_stat : process(CLOCK)
      begin
        if rising_edge(CLOCK) then
          STAT_DATA_BUFFER_LEVEL(i*32+31 downto i*32)
                                 <= (others => '0');

          STAT_DATA_BUFFER_LEVEL(i*32+DATA_BUFFER_DEPTH downto i*32)
                                 <= data_buffer_filllevel((i+1)*(DATA_BUFFER_DEPTH+1)-1 downto i*(DATA_BUFFER_DEPTH+1));

          STAT_DATA_BUFFER_LEVEL(i*32+18 downto i*32+16)
                                 <= data_buffer_full(i) & data_buffer_almost_full(i) & data_buffer_empty(i);

          STAT_DATA_BUFFER_LEVEL(i*32+19)
                                 <= FEE_DATA_WRITE_IN(i);

          STAT_DATA_BUFFER_LEVEL(i*32+22 downto i*32+20)
                                 <= buffer_state_bits(i);

          STAT_DATA_BUFFER_LEVEL(i*32+26 downto i*32+24)
                                 <= length_buffer_full(i) & length_buffer_almost_full(i) & length_buffer_empty(i);

          STAT_DATA_BUFFER_LEVEL(i*32+27)
                                 <= length_buffer_write(i);


        end if;
      end process;
  end generate;

  proc_header_buffer_stat : process(CLOCK)
    begin
      if rising_edge(CLOCK) then
        STAT_HEADER_BUFFER_LEVEL(31 downto 0)
                                  <= (others => '0');

        STAT_HEADER_BUFFER_LEVEL(HEADER_BUFFER_DEPTH downto 0)
                                  <= header_buffer_filllevel;

        STAT_HEADER_BUFFER_LEVEL(18 downto 16)
                                  <= header_buffer_full & header_buffer_almost_full & header_buffer_empty;

        STAT_HEADER_BUFFER_LEVEL(19)
                                  <= header_buffer_write;

        STAT_HEADER_BUFFER_LEVEL(22 downto 20)
                                  <= lvl1_state_bits;
      end if;
    end process;

---------------------------------------------------------------------------
-- Debug
---------------------------------------------------------------------------
  DEBUG_OUT(0)            <= data_buffer_write(0);
  DEBUG_OUT(1)            <= IPU_DATA_READ_IN(0);
  DEBUG_OUT(3 downto 2)   <= "00";
  DEBUG_OUT(7 downto 4)   <= data_buffer_data_in(35 downto 32);
  DEBUG_OUT(10 downto 8)  <= lvl1_state_bits;
  DEBUG_OUT(11)           <= '0';
  DEBUG_OUT(14 downto 12) <= buffer_state_bits(0);
  DEBUG_OUT(31 downto 15) <= (others => '0');


end architecture;
