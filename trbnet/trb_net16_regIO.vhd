LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.version.all;




entity trb_net16_regIO is
  generic (
    NUM_STAT_REGS      : integer range 0 to 6 := 3; --log2 of number of status registers
    NUM_CTRL_REGS      : integer range 0 to 6 := 3; --log2 of number of ctrl registers
    --standard values for output registers
    INIT_CTRL_REGS     : std_logic_vector(2**(4)*32-1 downto 0) := (others => '0');
    --set to 0 for unused ctrl registers to save resources
    USED_CTRL_REGS     : std_logic_vector(2**(4)-1 downto 0)   := (others => '1');
    --set to 0 for each unused bit in a register
    USED_CTRL_BITMASK  : std_logic_vector(2**(4)*32-1 downto 0) := (others => '1');
    USE_DAT_PORT       : integer range 0 to 1 := c_YES;  --internal data port
    INIT_ADDRESS       : std_logic_vector(15 downto 0) := x"FFFF";
    INIT_UNIQUE_ID     : std_logic_vector(63 downto 0) := x"1000_2000_3654_4876";
    INIT_BOARD_INFO    : std_logic_vector(31 downto 0) := x"1111_2222";
    INIT_ENDPOINT_ID   : std_logic_vector(15 downto 0)  := x"0001";
    COMPILE_TIME       : std_logic_vector(31 downto 0) := x"00000000";  --not used any more!
    INCLUDED_FEATURES  : std_logic_vector(63 downto 0) := (others => '0');
    HARDWARE_VERSION   : std_logic_vector(31 downto 0) := x"12345678";
    CLOCK_FREQ         : integer range 1 to 200 := 100 --MHz
    );
  port(
  --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
  -- Port to API
    API_DATA_OUT           : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    API_PACKET_NUM_OUT     : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    API_DATAREADY_OUT      : out std_logic;
    API_READ_IN            : in  std_logic;
    API_SHORT_TRANSFER_OUT : out std_logic;
    API_DTYPE_OUT          : out std_logic_vector (3 downto 0);
    API_ERROR_PATTERN_OUT  : out std_logic_vector (31 downto 0);
    API_SEND_OUT           : out std_logic;
    -- Receiver port
    API_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    API_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
    API_TYP_IN          : in  std_logic_vector (2 downto 0);
    API_DATAREADY_IN    : in  std_logic;
    API_READ_OUT        : out std_logic;
    -- APL Control port
    API_RUN_IN          : in  std_logic;
    API_SEQNR_IN        : in  std_logic_vector (7 downto 0);

    --Port to write Unique ID (-> 1-wire)
    IDRAM_DATA_IN       : in  std_logic_vector(15 downto 0);
    IDRAM_DATA_OUT      : out std_logic_vector(15 downto 0);
    IDRAM_ADDR_IN       : in  std_logic_vector(2 downto 0);
    IDRAM_WR_IN         : in  std_logic;

    --Informations
    MY_ADDRESS_OUT      : out std_logic_vector(15 downto 0);
    TRIGGER_MONITOR     : in  std_logic;  --strobe when timing trigger received
    GLOBAL_TIME         : out std_logic_vector(31 downto 0); --global time, microseconds
    LOCAL_TIME          : out std_logic_vector(7 downto 0);  --local time running with chip frequency
    TIME_SINCE_LAST_TRG : out std_logic_vector(31 downto 0); --local time, resetted with each trigger
    TIMER_US_TICK       : out std_logic;  --1 tick every microsecond
    TIMER_MS_TICK       : out std_logic;  --1 tick every 1024 microseconds

  --Common Register in / out
    COMMON_STAT_REG_IN  : in  std_logic_vector(std_COMSTATREG*c_REGIO_REG_WIDTH-1 downto 0);
    COMMON_CTRL_REG_OUT : out std_logic_vector(std_COMCTRLREG*c_REGIO_REG_WIDTH-1 downto 0);
  --Custom Register in / out
    REGISTERS_IN        : in  std_logic_vector(c_REGIO_REG_WIDTH*2**(NUM_STAT_REGS)-1 downto 0);
    REGISTERS_OUT       : out std_logic_vector(c_REGIO_REG_WIDTH*2**(NUM_CTRL_REGS)-1 downto 0);
  --strobes for r/w operations on regio registers
    COMMON_STAT_REG_STROBE : out std_logic_vector((std_COMSTATREG)-1 downto 0);
    COMMON_CTRL_REG_STROBE : out std_logic_vector((std_COMCTRLREG)-1 downto 0);
    STAT_REG_STROBE        : out std_logic_vector(2**(NUM_STAT_REGS)-1 downto 0);
    CTRL_REG_STROBE        : out std_logic_vector(2**(NUM_CTRL_REGS)-1 downto 0);
  --Internal Data Port
    DAT_ADDR_OUT        : out std_logic_vector(c_REGIO_ADDRESS_WIDTH-1 downto 0);
    DAT_READ_ENABLE_OUT : out std_logic;
    DAT_WRITE_ENABLE_OUT: out std_logic;
    DAT_DATA_OUT        : out std_logic_vector(c_REGIO_REG_WIDTH-1 downto 0);
    DAT_DATA_IN         : in  std_logic_vector(c_REGIO_REG_WIDTH-1 downto 0);
    DAT_DATAREADY_IN    : in  std_logic;
    DAT_NO_MORE_DATA_IN : in  std_logic;
    DAT_WRITE_ACK_IN    : in  std_logic;
    DAT_UNKNOWN_ADDR_IN : in  std_logic;
    DAT_TIMEOUT_OUT     : out std_logic;

  --Additional write access to ctrl registers
    STAT                : out std_logic_vector(31 downto 0);
    STAT_ADDR_DEBUG     : out std_logic_vector(15 downto 0)
    );
end entity;

architecture trb_net16_regIO_arch of trb_net16_regIO is

  -- Placer Directives
--   attribute HGROUP : string;
  -- for whole architecture
--   attribute HGROUP of trb_net16_regIO_arch : architecture  is "RegIO_group";

  constant COMPILE_TIME_LIB : std_logic_vector(31 downto 0) := conv_std_logic_vector(VERSION_NUMBER_TIME,32);

  type fsm_state_t is (IDLE, HEADER_RECV, REG_READ, REG_WRITE, ONE_READ, ONE_WRITE, SEND_REPLY_SHORT_TRANSFER, MEM_START_WRITE,
                       MEM_READ, MEM_WRITE, DAT_START_READ, DAT_READ, SEND_REPLY_DATA_finish, ADDRESS_ACK, ADDRESS_RECV,
                       MEM_START_READ, SEND_RW_ERROR, MEM_WRITE_2, WAIT_AFTER_REG_WRITE);
  signal current_state, next_state             : fsm_state_t;
--  signal HDR_F1, HDR_F2, HDR_F3, HDR_F0        : std_logic_vector(c_DATA_WIDTH-1 downto 0);
--  signal next_HDR_F1, next_HDR_F2, next_HDR_F3, next_HDR_F0 : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal next_Reg_high, saved_Reg_high         : std_logic_vector(15 downto 0);
  signal next_Reg_low, saved_Reg_low           : std_logic_vector(15 downto 0);
  signal next_address, address                 : std_logic_vector(15 downto 0) := x"0000";
  signal next_operation, saved_operation       : std_logic_vector(3  downto 0);

  signal buf_API_READ_OUT                                    : std_logic;
  signal buf_API_SEND_OUT, next_API_SEND_OUT                 : std_logic;
  signal buf_API_PACKET_NUM_OUT     : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal buf_API_DATA_OUT, next_API_DATA_OUT                 : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal buf_API_SHORT_TRANSFER_OUT, next_API_SHORT_TRANSFER_OUT : std_logic;
  signal buf_API_DATAREADY_OUT, next_API_DATAREADY_OUT       : std_logic;

  signal buf_DAT_DATA_OUT                 : std_logic_vector(c_REGIO_REG_WIDTH-1 downto 0);
  signal buf_DAT_DATA_IN                  : std_logic_vector(c_REGIO_REG_WIDTH-1 downto 0);

  signal buf_DAT_READ_ENABLE_OUT, next_DAT_READ_ENABLE_OUT   : std_logic;
  signal buf_DAT_WRITE_ENABLE_OUT, next_DAT_WRITE_ENABLE_OUT : std_logic;
  signal buf_DAT_ADDR_OUT                 : std_logic_vector(c_REGIO_ADDRESS_WIDTH-1 downto 0);

  signal buf_REGISTERS_OUT                     : std_logic_vector(c_REGIO_REG_WIDTH*2**(NUM_CTRL_REGS)-1 downto 0);
  signal REGISTERS_OUT_write_enable            : std_logic_vector(2**(NUM_CTRL_REGS)-1 downto 0);
  signal next_REGISTERS_OUT_write_enable       : std_logic_vector(2**(NUM_CTRL_REGS)-1 downto 0);
  signal reg_enable_pattern                    : std_logic_vector(63 downto 0);

  signal next_COMMON_REGISTERS_OUT_write_enable: std_logic_vector(std_COMCTRLREG - 1 downto 0);
  signal COMMON_REGISTERS_OUT_write_enable     : std_logic_vector(std_COMCTRLREG - 1 downto 0);
  signal buf_COMMON_CTRL_REG_OUT               : std_logic_vector(c_REGIO_REG_WIDTH*std_COMCTRLREG-1 downto 0);
  signal state_bits                            : std_logic_vector(3 downto 0);

  signal ADR_SEND_OUT : std_logic;
  signal ADR_DATAREADY_IN : std_logic;
  signal ADR_READ_OUT : std_logic;
  signal ADR_DATA_OUT : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal ADR_READ_IN  : std_logic;
  signal ADR_DATAREADY_OUT : std_logic;
  signal ADR_PACKET_NUM_OUT : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal ADR_REJECTED : std_logic;
  signal ADR_DONT_UNDERSTAND : std_logic;
  signal buf_API_ERROR_PATTERN_OUT  : std_logic_vector(31 downto 0);
  signal rom_read_addr,buf_rom_read_addr : std_logic_vector(2 downto 0);
  signal rom_read_dout : std_logic_vector(15 downto 0);
  signal length, next_length : std_logic_vector(15 downto 0);
  signal dont_understand, next_dont_understand : std_logic;
  signal packet_counter : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal next_packet_counter : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal addr_counter_enable, next_addr_counter_enable : std_logic;
  signal timeout_counter      : std_logic_vector(c_regio_timeout_bit downto 0);
  signal next_timeout_counter : std_logic_vector(c_regio_timeout_bit downto 0);
  signal timeout              : std_logic;
  signal next_timeout         : std_logic;
  signal unknown              : std_logic;
  signal next_unknown         : std_logic;
  signal next_API_READ_OUT    : std_logic;
  signal next_nomoredata      : std_logic;
  signal nomoredata           : std_logic;
  signal DAT_DATAREADY_IN_before : std_logic;
  signal combined_API_READ_OUT   : std_logic;
  signal dat_data_counter      : std_logic_vector(15 downto 0);
  signal next_dat_data_counter : std_logic_vector(15 downto 0);
  signal combined_API_SEND_OUT : std_logic;
  signal combined_API_DATA_OUT : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal combined_API_DATAREADY_OUT : std_logic;
  signal combined_API_PACKET_NUM_OUT: std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal buf_STAT_ADDR_DEBUG   : std_logic_vector(15 downto 0);


  signal global_time_i : std_logic_vector(31 downto 0) := (others => '0');
  signal time_since_last_trg_i  : std_logic_vector(31 downto 0) := (others => '0');
  signal local_time_i  : std_logic_vector(7 downto 0) := (others => '0');
  signal us_tick_i     : std_logic := '0';
  signal global_time_write, next_global_time_write : std_logic;
  signal next_COMMON_STAT_REG_STROBE :  std_logic_vector((std_COMSTATREG)-1 downto 0);
  signal next_COMMON_CTRL_REG_STROBE :  std_logic_vector((std_COMCTRLREG)-1 downto 0);
  signal next_next_COMMON_CTRL_REG_STROBE :  std_logic_vector((std_COMCTRLREG)-1 downto 0);
  signal next_STAT_REG_STROBE        :  std_logic_vector(2**(NUM_STAT_REGS)-1 downto 0);
  signal next_CTRL_REG_STROBE        :  std_logic_vector(2**(NUM_CTRL_REGS)-1 downto 0);
  signal next_next_CTRL_REG_STROBE   :  std_logic_vector(2**(NUM_CTRL_REGS)-1 downto 0);

begin

---------------------------------------------------------------------
--5bit address decoder for registers
---------------------------------------------------------------------
  pattern_gen_inst : trb_net_pattern_gen
    generic map(
      WIDTH => 5
      )
    port map(
      INPUT_IN   => address(4 downto 0),
      RESULT_OUT => reg_enable_pattern(31 downto 0)
      );
  reg_enable_pattern(63 downto 32) <= (others => '0');

---------------------------------------------------------------------
-- trbnet addresses
---------------------------------------------------------------------

  the_addresses : trb_net16_addresses
    generic map(
      INIT_ADDRESS   => INIT_ADDRESS,
      INIT_UNIQUE_ID => INIT_UNIQUE_ID,
      INIT_BOARD_INFO=> INIT_BOARD_INFO,
      INIT_ENDPOINT_ID => INIT_ENDPOINT_ID
      )
    port map(
      CLK    => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      API_DATA_IN       => API_DATA_IN,
      API_PACKET_NUM_IN => API_PACKET_NUM_IN,
      API_DATAREADY_IN  => ADR_DATAREADY_IN,
      API_READ_OUT      => ADR_READ_OUT,
      API_DATA_OUT      => ADR_DATA_OUT,
      API_DATAREADY_OUT => ADR_DATAREADY_OUT,
      API_PACKET_NUM_OUT=> ADR_PACKET_NUM_OUT,
      API_READ_IN       => ADR_READ_IN,
      API_SEND_OUT      => ADR_SEND_OUT,
      RAM_DATA_IN       => IDRAM_DATA_IN,
      RAM_DATA_OUT      => IDRAM_DATA_OUT,
      RAM_ADDR_IN       => IDRAM_ADDR_IN,
      RAM_WR_IN         => IDRAM_WR_IN,
      ADDRESS_REJECTED  => ADR_REJECTED,
      DONT_UNDERSTAND_OUT => ADR_DONT_UNDERSTAND,
      ADDRESS_OUT       => MY_ADDRESS_OUT,
      STAT_DEBUG        => buf_STAT_ADDR_DEBUG
      );


---------------------------------------------------------------------
-- Main State Machine
---------------------------------------------------------------------

  fsm : process(API_DATA_IN, API_PACKET_NUM_IN, API_TYP_IN, API_DATAREADY_IN, API_READ_IN,
                address, saved_Reg_high, saved_Reg_low, saved_operation, current_state,
                buf_API_SEND_OUT, next_packet_counter, buf_API_DATA_OUT, buf_API_SHORT_TRANSFER_OUT,
                REGISTERS_IN, buf_REGISTERS_OUT, reg_enable_pattern, DAT_NO_MORE_DATA_IN,
                DAT_DATAREADY_IN, buf_DAT_DATA_IN, ADR_REJECTED, timeout_counter, nomoredata,
                ADR_DATAREADY_OUT, length, dont_understand,
                buf_rom_read_addr, ADR_SEND_OUT, rom_read_dout, COMMON_STAT_REG_IN, buf_COMMON_CTRL_REG_OUT,
                timeout, unknown, addr_counter_enable, DAT_UNKNOWN_ADDR_IN, dat_data_counter,
                DAT_WRITE_ACK_IN, DAT_DATAREADY_IN_before, ADR_DONT_UNDERSTAND,
                global_time_i, time_since_last_trg_i
                )
    variable regnum_STAT : integer range 0 to 2**NUM_STAT_REGS-1;
    variable regnum_CTRL : integer range 0 to 2**NUM_CTRL_REGS-1;
    variable regnum_cSTAT : integer range 0 to 15; --std_COMSTATREG-1;
    variable regnum_cCTRL : integer range 0 to 2**std_COMneededwidth-1; --std_COMCTRLREG-1;
   begin
      next_state  <= current_state;
      next_address  <= address;
      next_Reg_high <= saved_Reg_high;
      next_Reg_low  <= saved_Reg_low;
      ADR_DATAREADY_IN <= '0';
      ADR_READ_IN <= '0';
      next_API_SEND_OUT <= buf_API_SEND_OUT;
      next_API_DATAREADY_OUT <= '0';
      next_API_DATA_OUT <= buf_API_DATA_OUT;
      next_API_SHORT_TRANSFER_OUT <= buf_API_SHORT_TRANSFER_OUT;
      next_operation <= saved_operation;
      next_REGISTERS_OUT_write_enable <= (others => '0');
      next_COMMON_REGISTERS_OUT_write_enable <= (others => '0');
      next_DAT_READ_ENABLE_OUT  <= '0';
      next_DAT_WRITE_ENABLE_OUT <= '0';
      rom_read_addr <= buf_rom_read_addr;
      next_length <= length;
      regnum_STAT := conv_integer(address(NUM_STAT_REGS-1 downto 0));
      regnum_CTRL := conv_integer(address(NUM_CTRL_REGS-1 downto 0));
      regnum_cSTAT := conv_integer(address(std_COMneededwidth-1 downto 0));
      regnum_cCTRL := conv_integer(address(std_COMneededwidth-1 downto 0));
      next_dont_understand <= dont_understand;
      next_timeout <= timeout;
      next_unknown <= unknown;
      next_nomoredata <= nomoredata;
      next_timeout_counter <= (others => '0');
      next_addr_counter_enable <= addr_counter_enable;
      next_API_READ_OUT <= '1';
      next_dat_data_counter <= dat_data_counter;
      next_global_time_write <= '0';
      next_COMMON_STAT_REG_STROBE <= (others => '0');
      next_next_COMMON_CTRL_REG_STROBE <= (others => '0');
      next_STAT_REG_STROBE <= (others => '0');
      next_next_CTRL_REG_STROBE <= (others => '0');

      case current_state is
        when IDLE =>
          next_API_SEND_OUT <= '0';
          next_API_SHORT_TRANSFER_OUT <= '0';
          next_dat_data_counter <= (others => '0');
          if API_TYP_IN = TYPE_HDR then
            next_dont_understand <= '0';
            next_state <= HEADER_RECV;
            next_unknown <= '0';
            next_timeout <= '0';
            next_nomoredata <= '0';
          end if;

        when HEADER_RECV =>        --read HDR
          if API_DATAREADY_IN = '1' then
            case API_PACKET_NUM_IN is
              when c_F3 =>
                case API_DATA_IN(3 downto 0) is
                  when c_read_register_type   => next_state <= ONE_READ;
                  when c_write_register_type  => next_state <= ONE_WRITE;
                  when c_read_multiple_type   => next_state <= MEM_START_READ;
                  when c_write_multiple_type  => next_state <= MEM_START_WRITE;
                  when c_network_control_type => next_state <= ADDRESS_RECV;
                  when others =>
                    next_state <= SEND_REPLY_SHORT_TRANSFER;
                    next_dont_understand <= '1';
                end case;
                next_operation <= API_DATA_IN(3 downto 0);
              when others => null;
            end case;
          end if;

        when ADDRESS_RECV =>
          ADR_DATAREADY_IN <= API_DATAREADY_IN;
          ADR_READ_IN <= API_READ_IN;
          if ADR_REJECTED = '1' then
            next_state <= SEND_REPLY_SHORT_TRANSFER;
          elsif ADR_DONT_UNDERSTAND = '1' then
            next_state <= SEND_REPLY_SHORT_TRANSFER;
            next_dont_understand <= '1';
          elsif ADR_DATAREADY_OUT = '1' and ADR_SEND_OUT = '1' then
            next_state <= ADDRESS_ACK;
          end if;

        when ADDRESS_ACK =>
          ADR_DATAREADY_IN <= API_DATAREADY_IN;
          ADR_READ_IN <= API_READ_IN;
          if ADR_SEND_OUT = '0' then
            next_state <= SEND_REPLY_DATA_finish;
          end if;


        when ONE_READ =>   --wait for register address
          if API_TYP_IN = TYPE_DAT and API_PACKET_NUM_IN = c_F0 and API_DATAREADY_IN = '1' then
            next_address <= API_DATA_IN;
            rom_read_addr <= API_DATA_IN(1 downto 0) & '1';
            if or_all(API_DATA_IN(c_REGIO_ADDRESS_WIDTH-1 downto 8)) = '1' then  --data port address
              if USE_DAT_PORT = c_YES then
                next_DAT_READ_ENABLE_OUT <= '1';
                next_state <= DAT_START_READ;
              else
                next_state <= SEND_REPLY_SHORT_TRANSFER;
                next_dont_understand <= '1';
              end if;
            else
              next_state <= REG_READ;
            end if;
          end if;

        when ONE_WRITE =>  --wait for register address
          if API_TYP_IN = TYPE_DAT and API_PACKET_NUM_IN = c_F0 and API_DATAREADY_IN = '1' then
            next_address <= API_DATA_IN;
            if or_all(API_DATA_IN(15 downto 8)) = '1' then  --data port address
              if USE_DAT_PORT = c_YES then
                next_state <= REG_WRITE;
              else
                next_state <= SEND_REPLY_SHORT_TRANSFER;
                next_dont_understand <= '1';
              end if;
            else
               next_state <= REG_WRITE;    --ctrl register
            end if;
          end if;

        when SEND_REPLY_DATA_finish =>
          next_API_SEND_OUT <= '0';
          next_API_SHORT_TRANSFER_OUT <= '0';
          next_state <= IDLE;

        when SEND_REPLY_SHORT_TRANSFER =>
          next_API_SHORT_TRANSFER_OUT <= '1';
          next_API_SEND_OUT <= '1';
          next_state <= SEND_REPLY_DATA_finish;

        when REG_WRITE =>
          if API_DATAREADY_IN = '1' then
            case API_PACKET_NUM_IN is
              when c_F1 =>
                next_Reg_high <= API_DATA_IN;
              when c_F2 =>
                next_Reg_low <= API_DATA_IN;
                if or_all(address(15 downto 8)) = '0' then
                  case address(7 downto 4) is
                    when x"C" | x"D" | x"E" | x"F" =>
                      next_REGISTERS_OUT_write_enable <= reg_enable_pattern(2**NUM_CTRL_REGS-1 downto 0);
                      next_next_CTRL_REG_STROBE(regnum_CTRL) <= API_READ_IN;
                    when x"2" | x"3" =>
                      next_COMMON_REGISTERS_OUT_write_enable <= reg_enable_pattern(std_COMCTRLREG-1 downto 0);
                      next_next_COMMON_CTRL_REG_STROBE(regnum_cCTRL) <= API_READ_IN;
                    when x"5" =>
                      if address(3 downto 0) = x"0" then
                        next_global_time_write <= '1';
                      else
                        next_unknown <= '1';
                      end if;
                    when others =>
                      next_unknown <= '1';
                  end case;
                  next_state   <= SEND_REPLY_SHORT_TRANSFER; --REG_READ;
                else
                  next_DAT_WRITE_ENABLE_OUT <= '1';
                  next_state   <= WAIT_AFTER_REG_WRITE;
                end if;
              when others => null;
            end case;
          end if;

        when WAIT_AFTER_REG_WRITE =>
          next_timeout_counter <= timeout_counter + 1;
          if DAT_WRITE_ACK_IN = '1' then
            next_state      <= SEND_REPLY_SHORT_TRANSFER;
          elsif DAT_NO_MORE_DATA_IN = '1' or DAT_UNKNOWN_ADDR_IN = '1' or timeout_counter(c_regio_timeout_bit) = '1' then
            next_state      <= SEND_RW_ERROR;
            next_timeout    <= timeout_counter(c_regio_timeout_bit);
            next_unknown    <= DAT_UNKNOWN_ADDR_IN;
            next_nomoredata <= DAT_NO_MORE_DATA_IN;
          end if;

        when REG_READ =>
          next_API_SEND_OUT <= '1';
          next_API_DATAREADY_OUT <= '1';
          case next_packet_counter is
            when c_F0 =>
              next_API_DATA_OUT <= address;
            when c_F1 =>
              case address(7 downto 4) is
                when x"0" | x"1" =>
                  next_API_DATA_OUT <= COMMON_STAT_REG_IN(regnum_cSTAT*c_REGIO_REG_WIDTH+31 downto regnum_cSTAT*c_REGIO_REG_WIDTH+16);
                when x"2" | x"3" =>
                  next_API_DATA_OUT <= buf_COMMON_CTRL_REG_OUT(regnum_cCTRL*c_REGIO_REG_WIDTH+31 downto regnum_cCTRL*c_REGIO_REG_WIDTH+16);
                when x"4" =>
                  next_API_DATA_OUT <= rom_read_dout;
                  rom_read_addr <= address(1 downto 0) & '0';
                when x"5" =>
                  case address(0) is
                    when '0' =>
                      next_API_DATA_OUT <= global_time_i(31 downto 16);
                    when others => --'1' =>
                      next_API_DATA_OUT <= time_since_last_trg_i(31 downto 16);
                  end case;
                when x"8" | x"9" | x"A" | x"B" =>
                  next_API_DATA_OUT <= REGISTERS_IN(regnum_STAT*c_REGIO_REG_WIDTH+31 downto regnum_STAT*c_REGIO_REG_WIDTH+16);
                when x"C" | x"D" | x"E" | x"F" =>
                  next_API_DATA_OUT <= buf_REGISTERS_OUT(regnum_CTRL*c_REGIO_REG_WIDTH+31 downto regnum_CTRL*c_REGIO_REG_WIDTH+16);
                when others =>
                  next_API_DATA_OUT <= (others => '0');
              end case;

            when c_F2 =>
              case address(7 downto 4) is
                when x"0" | x"1" =>
                  next_API_DATA_OUT <= COMMON_STAT_REG_IN(regnum_cSTAT*c_REGIO_REG_WIDTH+15 downto regnum_cSTAT*c_REGIO_REG_WIDTH);
                  next_COMMON_STAT_REG_STROBE(regnum_cSTAT) <= API_READ_IN;
                when x"2" | x"3" =>
                  next_API_DATA_OUT <= buf_COMMON_CTRL_REG_OUT(regnum_cCTRL*c_REGIO_REG_WIDTH+15 downto regnum_cCTRL*c_REGIO_REG_WIDTH);
                when x"4" =>
                  next_API_DATA_OUT <= rom_read_dout;
                when x"5" =>
                  case address(0) is
                    when '0' =>
                      next_API_DATA_OUT <= global_time_i(15 downto 0);
                    when others => --'1' =>
                      next_API_DATA_OUT <= time_since_last_trg_i(15 downto 0);
                  end case;
                when x"8" | x"9" | x"A" | x"B" =>
                  next_API_DATA_OUT <= REGISTERS_IN(regnum_STAT*c_REGIO_REG_WIDTH+15 downto regnum_STAT*c_REGIO_REG_WIDTH);
                  next_STAT_REG_STROBE(regnum_STAT) <= API_READ_IN;
                when x"C" | x"D" | x"E" | x"F" =>
                  next_API_DATA_OUT <= buf_REGISTERS_OUT(regnum_CTRL*c_REGIO_REG_WIDTH+15 downto regnum_CTRL*c_REGIO_REG_WIDTH);
                when others =>
                  next_API_DATA_OUT <= (others => '0');
              end case;

            when c_F3 =>
              next_API_DATA_OUT <= global_time_i(19 downto 4);
              if API_READ_IN = '1' then
                next_state <= SEND_REPLY_DATA_finish;
              end if;
            when others =>
              next_API_DATAREADY_OUT <= '0';
          end case;

        when MEM_START_READ =>
          if USE_DAT_PORT = c_NO then
            next_state <= SEND_REPLY_SHORT_TRANSFER;
            next_dont_understand <= '1';
          else
            if API_TYP_IN = TYPE_DAT  and API_DATAREADY_IN = '1' then
              if API_PACKET_NUM_IN = c_F1 then
                next_length <= '0' & API_DATA_IN(14 downto 0);
                next_addr_counter_enable <= API_DATA_IN(15);
                next_DAT_READ_ENABLE_OUT <= '1';
--                 next_dat_data_counter <= dat_data_counter + 1;
                next_state <= MEM_READ;
              elsif API_PACKET_NUM_IN = c_F0 then
                next_address <= API_DATA_IN;
                if API_DATA_IN(15 downto 8) = 0 then
                  next_state <= SEND_REPLY_SHORT_TRANSFER;
                  next_dont_understand <= '1';
                end if;
              end if;
            end if;
          end if;

        when MEM_READ =>
          next_API_DATAREADY_OUT <= '0';
          next_API_SEND_OUT <= '1';
          case next_packet_counter is
            when c_F0 =>
              next_timeout_counter <= timeout_counter + 1;
              if length = 0 then
                next_state <= SEND_REPLY_DATA_finish;
              elsif DAT_NO_MORE_DATA_IN = '1' then
                next_state <= SEND_REPLY_DATA_finish;
                next_API_SHORT_TRANSFER_OUT <= '1';
                next_nomoredata <= '1';
              elsif DAT_UNKNOWN_ADDR_IN = '1' then
                next_state <= SEND_REPLY_DATA_finish;
                next_API_SHORT_TRANSFER_OUT <= '1';
                next_unknown <= '1';
              elsif DAT_DATAREADY_IN = '1' or DAT_DATAREADY_IN_before = '1' then
                next_API_DATAREADY_OUT <= '1';
                next_API_DATA_OUT <= address;
              elsif timeout_counter(c_regio_timeout_bit) = '1' then
                next_state <= SEND_REPLY_DATA_finish;
                next_API_SHORT_TRANSFER_OUT <= '1';
                next_timeout <= '1';
              end if;
            when c_F1 =>
              next_API_DATA_OUT <= buf_DAT_DATA_IN(31 downto 16);
              next_API_DATAREADY_OUT <= '1';
            when c_F2 =>
              next_API_DATA_OUT <= buf_DAT_DATA_IN(15 downto 0);
              next_API_DATAREADY_OUT <= '1';
            when c_F3 =>
              next_API_DATA_OUT <=  global_time_i(19 downto 4);--(others => '0');
              next_API_DATAREADY_OUT <= '1';
              if API_READ_IN = '1' then
                next_length <= length-1;
                if length > 1 then
                  next_DAT_READ_ENABLE_OUT <= '1';
                  if addr_counter_enable = '1' then
                    next_address <= address + 1;
                  end if;
                end if;
              end if;
            when others => null;
          end case;

        when MEM_START_WRITE =>
          if USE_DAT_PORT = c_NO then
            next_state <= SEND_REPLY_SHORT_TRANSFER;
            next_dont_understand <= '1';
          else
            if API_TYP_IN = TYPE_DAT and API_DATAREADY_IN = '1' then
              if API_PACKET_NUM_IN = c_F0 then
                next_address <= API_DATA_IN;
              elsif API_PACKET_NUM_IN = c_F1 then
                next_addr_counter_enable <= API_DATA_IN(15);
              elsif API_PACKET_NUM_IN = c_F3 then
                next_state <= MEM_WRITE;
              end if;
            end if;
          end if;

        when MEM_WRITE =>
          if API_DATAREADY_IN = '1' then
            case API_PACKET_NUM_IN is
              when c_F1 =>
                next_Reg_high         <= API_DATA_IN;
              when c_F2 =>
                next_Reg_low          <= API_DATA_IN;
                next_DAT_WRITE_ENABLE_OUT <= '1';
                next_dat_data_counter <= dat_data_counter + 1;
                next_API_READ_OUT     <= '0';
                next_state            <= MEM_WRITE_2;
              when c_F3 =>
                if addr_counter_enable = '1' then
                  next_address        <= address + 1;
                end if;
              when others => null;
            end case;
            if API_TYP_IN = TYPE_TRM then
              next_state <= SEND_REPLY_SHORT_TRANSFER;
            end if;
          end if;

        when MEM_WRITE_2 =>
          if DAT_WRITE_ACK_IN = '1' then
            next_API_READ_OUT <= '1';
            next_state        <= MEM_WRITE;
          elsif timeout_counter(c_regio_timeout_bit) = '1' or DAT_UNKNOWN_ADDR_IN = '1' or DAT_NO_MORE_DATA_IN = '1' then
            next_API_READ_OUT <= '1';
            next_state        <= SEND_RW_ERROR;
            next_timeout      <= timeout_counter(c_regio_timeout_bit);
            next_unknown      <= DAT_UNKNOWN_ADDR_IN;
            next_nomoredata   <= DAT_NO_MORE_DATA_IN;
          else
            next_timeout_counter <= timeout_counter + 1;
            next_API_READ_OUT <= '0';
          end if;

        when DAT_START_READ =>
          if DAT_DATAREADY_IN = '1' then
            next_state      <= DAT_READ;
          elsif DAT_NO_MORE_DATA_IN = '1' or DAT_UNKNOWN_ADDR_IN = '1' or timeout_counter(c_regio_timeout_bit) = '1' then
            next_state      <= SEND_REPLY_SHORT_TRANSFER;
            next_nomoredata <= DAT_NO_MORE_DATA_IN;
            next_unknown    <= DAT_UNKNOWN_ADDR_IN;
            next_timeout    <= timeout_counter(c_regio_timeout_bit);
          else
            next_timeout_counter <= timeout_counter + 1;
          end if;

        when DAT_READ =>
          next_API_SEND_OUT <= '1';
          next_API_DATAREADY_OUT <= '1';
          case next_packet_counter is
            when c_F0 =>  next_API_DATA_OUT <= address;
            when c_F1 =>  next_API_DATA_OUT <= buf_DAT_DATA_IN(31 downto 16);
            when c_F2 =>  next_API_DATA_OUT <= buf_DAT_DATA_IN(15 downto 0);
            when c_F3 =>  next_API_DATA_OUT <= global_time_i(19 downto 4);--(others => '0');
                          if API_READ_IN = '1' then
                            next_state <= SEND_REPLY_DATA_finish;
                          end if;
            when others => null;
          end case;

        when SEND_RW_ERROR =>
          next_API_SEND_OUT <= '1';
          next_API_DATAREADY_OUT <= '1';
          case next_packet_counter is
            when c_F0 => next_API_DATA_OUT <= address;
            when c_F1 => next_API_DATA_OUT <= dat_data_counter;
            when c_F2 => next_API_DATA_OUT <= (others => '0');
            when c_F3 => next_API_DATA_OUT <= global_time_i(19 downto 4);--(others => '0');
                         if API_READ_IN = '1' then
                           next_state <= SEND_REPLY_DATA_finish;
                         end if;
            when others => null;
          end case;
        when others =>
                  next_state <= IDLE;
     end case;
   end process;


  reg_fsm : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_state <= IDLE;
          buf_API_SEND_OUT <= '0';
          buf_DAT_READ_ENABLE_OUT  <= '0';
          buf_DAT_WRITE_ENABLE_OUT <= '0';
          saved_operation <= "0000";
          saved_Reg_high <= (others => '0');
          saved_Reg_low  <= (others => '0');
          buf_rom_read_addr <= "000";
          length <= (others => '0');
          dont_understand <= '0';
          addr_counter_enable <= '0';
          timeout_counter <= (others => '0');
          timeout <= '0';
          unknown <= '0';
          nomoredata <= '0';
          buf_API_READ_OUT <= '0';
          global_time_write <= '0';
        else
          current_state <= next_state;
          buf_API_SEND_OUT <= next_API_SEND_OUT;
          buf_API_SHORT_TRANSFER_OUT <= next_API_SHORT_TRANSFER_OUT;
          buf_API_READ_OUT <= next_API_READ_OUT;
          address <= next_address;
          saved_Reg_high <= next_Reg_high;
          saved_Reg_low  <= next_Reg_low;
          saved_operation <= next_operation;
          buf_DAT_READ_ENABLE_OUT  <= next_DAT_READ_ENABLE_OUT;
          buf_DAT_WRITE_ENABLE_OUT <= next_DAT_WRITE_ENABLE_OUT;
          REGISTERS_OUT_write_enable <= next_REGISTERS_OUT_write_enable;
          COMMON_REGISTERS_OUT_write_enable <= next_COMMON_REGISTERS_OUT_write_enable;
          buf_rom_read_addr <= rom_read_addr;
          length <= next_length;
          dont_understand <= next_dont_understand;
          addr_counter_enable <= next_addr_counter_enable;
          timeout_counter <= next_timeout_counter;
          timeout <= next_timeout;
          unknown <= next_unknown;
          nomoredata <= next_nomoredata;
          global_time_write <= next_global_time_write;
          dat_data_counter <= next_dat_data_counter;
        end if;
      end if;
    end process;


---------------------------------------------------------------------
-- Packet Numbers
---------------------------------------------------------------------
  reg_packet_counter : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          packet_counter <= c_F0;
        else
          packet_counter <= next_packet_counter;
        end if;
      end if;
    end process;

  next_packet_counter_proc : process(API_READ_IN, buf_API_DATAREADY_OUT, packet_counter)
    begin
      if buf_API_DATAREADY_OUT = '1' and API_READ_IN = '1' then
        if packet_counter =  "011" then
          next_packet_counter <= "000";
        else
          next_packet_counter <= packet_counter + 1;
        end if;
      else
        next_packet_counter <= packet_counter;
      end if;
    end process;

---------------------------------------------------------------------
-- Generate output to API
---------------------------------------------------------------------
  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          buf_API_DATA_OUT <= (others => '0');
          buf_API_DATAREADY_OUT <= '0';
        else
          buf_API_DATAREADY_OUT <= next_API_DATAREADY_OUT;
          if current_state = ADDRESS_ACK then
            buf_API_PACKET_NUM_OUT <= ADR_PACKET_NUM_OUT;
          else
            buf_API_PACKET_NUM_OUT <= next_packet_counter;
          end if;
          buf_API_DATA_OUT <= next_API_DATA_OUT;
        end if;
      end if;
    end process;

  --combine signals from regio and addresses
  process(current_state, ADR_READ_OUT, buf_API_READ_OUT, ADR_SEND_OUT, ADR_DATA_OUT, ADR_DATAREADY_OUT,
          ADR_PACKET_NUM_OUT, buf_API_SEND_OUT, buf_API_DATA_OUT, buf_API_DATAREADY_OUT, buf_API_PACKET_NUM_OUT)
    begin
      if current_state = ADDRESS_RECV or current_state = ADDRESS_ACK then
        combined_API_READ_OUT <= ADR_READ_OUT;
        combined_API_SEND_OUT <= ADR_SEND_OUT;
        combined_API_DATA_OUT <= ADR_DATA_OUT;
        combined_API_DATAREADY_OUT <= ADR_DATAREADY_OUT;
        combined_API_PACKET_NUM_OUT <= ADR_PACKET_NUM_OUT;
      else
        combined_API_READ_OUT <= buf_API_READ_OUT;
        combined_API_SEND_OUT <= buf_API_SEND_OUT;
        combined_API_DATA_OUT <= buf_API_DATA_OUT;
        combined_API_DATAREADY_OUT <= buf_API_DATAREADY_OUT;
        combined_API_PACKET_NUM_OUT <= buf_API_PACKET_NUM_OUT;
      end if;
    end process;

  buf_API_ERROR_PATTERN_OUT(31 downto 19) <= (others => '0');
  buf_API_ERROR_PATTERN_OUT(18) <= nomoredata;
  buf_API_ERROR_PATTERN_OUT(17) <= timeout;
  buf_API_ERROR_PATTERN_OUT(16) <= unknown;
  buf_API_ERROR_PATTERN_OUT(15 downto 5) <= (others => '0');
  buf_API_ERROR_PATTERN_OUT(4) <= dont_understand;
  buf_API_ERROR_PATTERN_OUT(3 downto 0) <= (others => '0');

---------------------------------------------------------------------
-- Read from DAT port
---------------------------------------------------------------------
--save Dataready_in in case API can not read immediately
  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1'  or current_state = IDLE then
          DAT_DATAREADY_IN_before <= '0';
        elsif DAT_DATAREADY_IN = '1' then
          DAT_DATAREADY_IN_before <= '1';
        elsif (API_READ_IN = '1' and buf_API_DATAREADY_OUT = '1')then
          DAT_DATAREADY_IN_before <= '0';
        end if;
      end if;
    end process;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if DAT_DATAREADY_IN = '1' then
          buf_DAT_DATA_IN <= DAT_DATA_IN;
        end if;
      end if;
    end process;

---------------------------------------------------------------------
-- User defined CTRL registers
---------------------------------------------------------------------
  gen_regout : for i in 0 to 2**(NUM_CTRL_REGS)-1 generate
    gen_regoutff1 : for j in i*c_REGIO_REG_WIDTH to (i+1)*c_REGIO_REG_WIDTH-1 generate
      gen_regoutff : if USED_CTRL_REGS(i) = '1' and USED_CTRL_BITMASK(j) = '1' generate
        process(CLK)
          variable tmp : std_logic_vector(c_REGIO_REG_WIDTH-1 downto 0);
          begin
            if rising_edge(CLK) then
              if RESET = '1' then
                buf_REGISTERS_OUT(j)  <= INIT_CTRL_REGS(j);
              elsif REGISTERS_OUT_write_enable(i) = '1' then
                tmp := saved_Reg_high & saved_Reg_low;
                buf_REGISTERS_OUT(j) <= tmp(j-i*c_REGIO_REG_WIDTH);
              end if;
            end if;
          end process;
      end generate;
      gen_regoutnull : if USED_CTRL_REGS(i) = '0' or USED_CTRL_BITMASK(j) = '0' generate
        buf_REGISTERS_OUT(j) <= INIT_CTRL_REGS(j);
      end generate;
    end generate;
  end generate;

---------------------------------------------------------------------
-- Common CTRL registers
---------------------------------------------------------------------
  gen_strobe_ctrl_regs : if std_COMCTRLREG >= 1 generate
    process(CLK)
      begin
        if rising_edge(CLK) then
          if COMMON_REGISTERS_OUT_write_enable(0) = '1' then
            buf_COMMON_CTRL_REG_OUT(31 downto 0) <= saved_Reg_high & saved_Reg_low;
          else
            buf_COMMON_CTRL_REG_OUT(31 downto 0) <= (others => '0');
          end if;
        end if;
      end process;
  end generate;

  gen_normal_ctrl_regs : if std_COMCTRLREG > 1 generate
    gen_cregout : for i in 1 to std_COMCTRLREG-1 generate
      gen_cregoutff1 : for j in i*c_REGIO_REG_WIDTH to (i+1)*c_REGIO_REG_WIDTH-1 generate
        process(CLK)
          variable tmp : std_logic_vector(c_REGIO_REG_WIDTH-1 downto 0);
          begin
            if rising_edge(CLK) then
              if RESET = '1' then
                buf_COMMON_CTRL_REG_OUT(j)  <= '0';
                if j = 95 then
                  buf_COMMON_CTRL_REG_OUT(j) <= '1';
                end if;
              elsif COMMON_REGISTERS_OUT_write_enable(i) = '1' then
                tmp := saved_Reg_high & saved_Reg_low;
                buf_COMMON_CTRL_REG_OUT(j) <= tmp(j-i*c_REGIO_REG_WIDTH);
              end if;
            end if;
          end process;
      end generate;
    end generate;
  end generate;

---------------------------------------------------------------------
-- Global Time Register
---------------------------------------------------------------------

  proc_global_time : process(CLK)
    begin
      if rising_edge(CLK) then
        TIMER_MS_TICK <= '0';
        if global_time_write = '1'  then
          global_time_i <= saved_Reg_high & saved_Reg_low;
        elsif us_tick_i = '1' then
          global_time_i <= global_time_i + 1;
          if global_time_i(9 downto 0) = "0000000000" then
            TIMER_MS_TICK <= '1';
          end if;
        end if;
      end if;
    end process;

  proc_us_tick : process(CLK)
    begin
      if rising_edge(CLK) then
        if local_time_i = conv_std_logic_vector(CLOCK_FREQ - 1,8) then
          local_time_i <= (others => '0');
          us_tick_i    <= '1';
        else
          local_time_i <= local_time_i + 1;
          us_tick_i    <= '0';
        end if;
      end if;
    end process;

  proc_time_since_trg : process(CLK)
    begin
      if rising_edge(CLK) then
        if TRIGGER_MONITOR = '1' then
          time_since_last_trg_i <= (others => '0');
        else
          time_since_last_trg_i <= time_since_last_trg_i + 1;
        end if;
      end if;
    end process;

  GLOBAL_TIME   <= global_time_i;
  LOCAL_TIME    <= local_time_i;
  TIMER_US_TICK <= us_tick_i;
  TIME_SINCE_LAST_TRG <= time_since_last_trg_i;

---------------------------------------------------------------------
-- ROM with board information
---------------------------------------------------------------------
  board_rom : rom_16x8
    generic map(
      INIT0 => COMPILE_TIME_LIB(15 downto 0),
      INIT1 => COMPILE_TIME_LIB(31 downto 16),
      INIT2 => INCLUDED_FEATURES(15 downto 0),
      INIT3 => INCLUDED_FEATURES(31 downto 16),
      INIT4 => HARDWARE_VERSION(15 downto 0),
      INIT5 => HARDWARE_VERSION(31 downto 16),
      INIT6 => INCLUDED_FEATURES(47 downto 32),
      INIT7 => INCLUDED_FEATURES(63 downto 48)
      )
    port map(
      CLK     => CLK,
      a       => rom_read_addr,
      dout    => rom_read_dout
      );


---------------------------------------------------------------------
-- Assign signals to outputs
---------------------------------------------------------------------
  API_READ_OUT           <= combined_API_READ_OUT;
  API_SEND_OUT           <= combined_API_SEND_OUT;
  API_DATAREADY_OUT      <= combined_API_DATAREADY_OUT;
  API_PACKET_NUM_OUT     <= combined_API_PACKET_NUM_OUT;
  API_DATA_OUT           <= combined_API_DATA_OUT;
  API_SHORT_TRANSFER_OUT <= buf_API_SHORT_TRANSFER_OUT;
  API_DTYPE_OUT          <= saved_operation;
  API_ERROR_PATTERN_OUT  <= buf_API_ERROR_PATTERN_OUT;
  DAT_DATA_OUT           <= buf_DAT_DATA_OUT;
  DAT_READ_ENABLE_OUT    <= buf_DAT_READ_ENABLE_OUT;
  DAT_WRITE_ENABLE_OUT   <= buf_DAT_WRITE_ENABLE_OUT;
  DAT_ADDR_OUT           <= buf_DAT_ADDR_OUT;
  DAT_TIMEOUT_OUT        <= timeout;
  REGISTERS_OUT          <= buf_REGISTERS_OUT;
  COMMON_CTRL_REG_OUT    <= buf_COMMON_CTRL_REG_OUT;


  PROC_STROBES : process(CLK)
    begin
      if rising_edge(CLK) then
        COMMON_STAT_REG_STROBE <= next_COMMON_STAT_REG_STROBE;
        COMMON_CTRL_REG_STROBE <= next_COMMON_CTRL_REG_STROBE;
        STAT_REG_STROBE        <= next_STAT_REG_STROBE;
        CTRL_REG_STROBE        <= next_CTRL_REG_STROBE;
        next_COMMON_CTRL_REG_STROBE   <= next_next_COMMON_CTRL_REG_STROBE;
        next_CTRL_REG_STROBE   <= next_next_CTRL_REG_STROBE;
      end if;
    end process;



  buf_DAT_ADDR_OUT <= address;
  buf_DAT_DATA_OUT <= saved_Reg_high & saved_Reg_low;

---------------------------------------------------------------------
-- Debugging Signals
---------------------------------------------------------------------

  STAT(3 downto 0) <= state_bits;
  STAT(6 downto 4) <= buf_API_PACKET_NUM_OUT;
  STAT(7) <= next_API_DATAREADY_OUT;
  STAT(15 downto 8) <= next_API_DATA_OUT(7 downto 0);
  STAT(23 downto 16) <= x"00";--(7 downto 0);
  STAT(24) <= DAT_DATAREADY_IN;
  STAT(25) <= DAT_DATAREADY_IN_before;
  STAT(26) <= '0'; --DAT_READ_ENABLE_OUT;
  STAT(27) <= '0'; --DAT_WRITE_ENABLE_OUT;
  STAT(28) <= DAT_NO_MORE_DATA_IN;
  STAT(29) <= DAT_UNKNOWN_ADDR_IN;
  STAT(30) <= API_READ_IN;
  STAT(31) <= '0';

  process(current_state)
    begin
      case current_state is
        when IDLE         => state_bits <= "0000";
        when HEADER_RECV  => state_bits <= "0001";
        when REG_READ     => state_bits <= "0010";
        when REG_WRITE    => state_bits <= "0011";
        when SEND_REPLY_DATA_finish    => state_bits <= "0100";
        when SEND_REPLY_SHORT_TRANSFER => state_bits <= "0101";
        when ONE_READ        => state_bits <= "0110";
        when ONE_WRITE       => state_bits <= "0111";
        when MEM_START_WRITE => state_bits <= "1000";
        when MEM_READ        => state_bits <= "1001";
        when MEM_WRITE       => state_bits <= "1010";
        when DAT_START_READ  => state_bits <= "1011";
        when DAT_READ        => state_bits <= "1100";
        when ADDRESS_ACK     => state_bits <= "1101";
        when ADDRESS_RECV    => state_bits <= "1110";
        when others          => state_bits <= "1111";
      end case;
    end process;


  STAT_ADDR_DEBUG(2 downto 0)  <= state_bits(2 downto 0);
  STAT_ADDR_DEBUG(3)  <= ADR_DONT_UNDERSTAND;
  STAT_ADDR_DEBUG(4)  <= API_DATAREADY_IN;
  STAT_ADDR_DEBUG(5)  <= buf_API_SHORT_TRANSFER_OUT;
  STAT_ADDR_DEBUG(6)  <= combined_API_SEND_OUT;
  STAT_ADDR_DEBUG(11 downto 7) <= buf_STAT_ADDR_DEBUG(11 downto 7);
  STAT_ADDR_DEBUG(12) <= combined_API_DATAREADY_OUT;
  STAT_ADDR_DEBUG(13) <= ADR_REJECTED;
  STAT_ADDR_DEBUG(14) <= ADR_SEND_OUT;
  STAT_ADDR_DEBUG(15) <= ADR_DATAREADY_OUT;



end architecture;

