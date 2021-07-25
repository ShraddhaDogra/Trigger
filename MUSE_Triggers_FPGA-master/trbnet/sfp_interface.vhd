library IEEE;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity Sfp_Interface is
  generic (
    I2C_SPEED         :       std_logic_vector(15 downto 0) := x"0200"
------------------------------------------------------------------------------------
--  I2C_SPEED = 100 MHz / working frequency                                        |
--  max working frequency 400 kHz                                                  |
--  Example: for 400 kHz working frequency => I2C_SPEED = FPGA freq / Working freq |
--                                            I2C_SPEED = 100MHz / 400kHz          |
--                                            I2C_SPEED = 250 = x"FA"              |
------------------------------------------------------------------------------------
    );
  port(
    CLK_IN            : in    std_logic;                        -- System clock
    RST_IN            : in    std_logic;                        -- System reset
-- host side
    START_PULSE       : in    std_logic;                        -- System start pulse
    DEVICE_ADDRESS    : in    std_logic_vector(7 downto 0) :=x"06";     -- Device address input: x"06" for SFP_Interface
    DATA_OUT          : out   std_logic_vector(15 downto 0);    -- Data output from optical transmitter
    READ_DONE         : out   std_logic;                        -- Reading process done
    SFP_ADDRESS       : in    std_logic_vector(7 downto 0);     -- SFP address
---------------------------------------------------------------
-- SFP_ADDRESS values:                                        |
--------------------------------------------------------------|
-- x"60" => Internally measured module temperature            |
-- x"66" => Measured TX optical output power                  |
-- x"68" => Measured RX optical input power                   |
---------------------------------------------------------------
-- optical transceiver side
    SCL               : out std_logic_vector(15 downto 0);                          -- I2C Serial clock I/O
    SDA               : inout std_logic_vector(15 downto 0);                          -- I2C Serial data I/O
    DEBUG             : out   std_logic_vector(31 downto 0)
    );

end Sfp_Interface;
-------------------------------------------------------------------------------

architecture behavioral of Sfp_Interface is
-------------------------------------------------------------------------------
-- Internal Lines
-------------------------------------------------------------------------------
  signal scl_int          : std_logic                     := '1';
  signal sda_int          : std_logic                     := '1';
  signal sda_int_mem      : std_logic                     := '1';
  signal byte_2_send      : std_logic_vector(7 downto 0)  := x"00";
  signal byte_2_send_mem  : std_logic_vector(7 downto 0)  := x"00";
  signal byte_2_read      : std_logic_vector(15 downto 0) := x"0000";
  signal data_out_int     : std_logic_vector(15 downto 0) := x"0000";
  signal data_out_int_mem : std_logic_vector(15 downto 0) := x"0000";
  signal bit_read         : std_logic                     := '0';
  signal bit_read_mem     : std_logic                     := '0';
  signal read_done_int    : std_logic                     := '0';
--
  signal en_reset_cnt     : std_logic                     := '0';
  signal stop_reset_cnt   : std_logic                     := '0';
  signal rst_reset_cnt    : std_logic                     := '0';
  signal reset_cnt        : std_logic_vector(3 downto 0)  := "0001";
  signal reset_done       : std_logic                     := '0';
  signal reset_done_mem   : std_logic                     := '0';
--
  signal en_bit_cnt       : std_logic                     := '0';
  signal stop_bit_cnt     : std_logic                     := '0';
  signal rst_bit_cnt      : std_logic                     := '0';
  signal bit_cnt          : std_logic_vector(5 downto 0)  := "000000";
--
  signal stop_fre_cnt     : std_logic                     := '0';
  signal rst_fre_cnt      : std_logic                     := '0';
  signal fre_cnt          : std_logic_vector(15 downto 0) := x"0000";
--
  signal en_shift_reg     : std_logic                     := '0';
  signal en_FSM           : std_logic                     := '0';
  signal sfp_address_i    : std_logic_vector(7 downto 0)  := x"00";
  signal device_address_i : std_logic_vector(7 downto 0)  := x"06";
  signal start_pulse_i    : std_logic                     := '0';
--
  signal debug_signal     : std_logic_vector(31 downto 0) := x"00000000";
  signal select_line      : integer range 0 to 15;
-------------------------------------------------------------------------------
  type STATES is (IDLE, RESET_A, RESET_B, RESET_C, RESET_D, START_A, START_B,
                  START_C, START_D, STOP_A, STOP_B, STOP_C, STOP_D, SEND_BYTE_A,
                  SEND_BYTE_B, SEND_BYTE_C, SEND_BYTE_D, READ_BYTE_A, READ_BYTE_B,
                  READ_BYTE_C, READ_BYTE_D, SEND_ACK_A, SEND_ACK_B, SEND_ACK_C,
                  SEND_ACK_D, READ_ACK_A, READ_ACK_B, READ_ACK_C, READ_ACK_D);
  signal STATE_CURRENT    : STATES;
  signal STATE_NEXT       : STATES;
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
begin
  stop_reset_cnt         <= rst_in or rst_reset_cnt;
  stop_bit_cnt           <= rst_in or rst_bit_cnt;
  stop_fre_cnt           <= rst_in or rst_fre_cnt;
  select_line            <= to_integer(unsigned(DEVICE_ADDRESS(3 downto 0)));
  
  proc_counters : process begin
    wait until rising_edge(CLK_IN);
    if stop_fre_cnt = '1' then
      fre_cnt <= x"0000";
    else
      fre_cnt <= std_logic_vector(unsigned(fre_cnt)+1);
    end if;
    
    if stop_bit_cnt = '1' then
      bit_cnt <= "000000";
    elsif en_bit_cnt = '1' then
      bit_cnt <= std_logic_vector(unsigned(bit_cnt)+1);
    end if;

    if stop_reset_cnt = '1' then
      reset_cnt <= "0000";
    elsif en_reset_cnt = '1' then
      reset_cnt <= std_logic_vector(unsigned(reset_cnt)+1);
    end if;
    
    
  end process;

  Frequency_Division : process (CLK_IN, RST_IN, fre_cnt)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        en_FSM           <= '0';
        rst_fre_cnt      <= '0';
      elsif fre_cnt = I2C_SPEED then
        en_FSM           <= '1';
        rst_fre_cnt      <= '1';
      else
        en_FSM           <= '0';
        rst_fre_cnt      <= '0';
      end if;
    end if;
  end process Frequency_Division;
-------------------------------------------------------------------------------
  Address_Assingment : process (CLK_IN, RST_IN, START_PULSE)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        sfp_address_i    <= x"00";
        device_address_i <= x"00";
        start_pulse_i    <= '0';
      elsif START_PULSE = '1' then
        sfp_address_i    <= SFP_ADDRESS;
        device_address_i <= DEVICE_ADDRESS;
        start_pulse_i    <= START_PULSE;
      else
        start_pulse_i    <= '0';
      end if;
    end if;
  end process Address_Assingment;
-------------------------------------------------------------------------------
  Syncronising       : process (CLK_IN, RST_IN)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        STATE_CURRENT    <= IDLE;
        DATA_OUT         <= x"0000";
        READ_DONE        <= '0';
        data_out_int_mem <= x"0000";
        byte_2_send_mem  <= x"00";
        reset_done_mem   <= '0';
        bit_read_mem     <= '0';
        SCL              <= (others => 'Z');
        SDA              <= (others => 'Z');
        sda_int_mem      <= '1';
        DEBUG            <= x"00000000";
      else
        STATE_CURRENT    <= STATE_NEXT;
        DATA_OUT         <= data_out_int;
        READ_DONE        <= read_done_int;
        data_out_int_mem <= data_out_int;
        byte_2_send_mem  <= byte_2_send;
        reset_done_mem   <= reset_done;
        sda_int_mem      <= sda_int;
        bit_read_mem     <= bit_read;
        SCL              <= (others => scl_int);
        SDA              <= (others => sda_int);
        DEBUG            <= debug_signal;
      end if;
    end if;
  end process Syncronising;
-------------------------------------------------------------------------------
  Shift_Register     : process (CLK_IN, RST_IN, en_shift_reg)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        byte_2_read      <= x"0000";
      elsif en_shift_reg = '1' then
        byte_2_read      <= byte_2_read(14 downto 0) & bit_read;
      end if;
    end if;
  end process Shift_Register;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- The State Machine
-------------------------------------------------------------------------------
  State_Decoder : process (start_pulse_i, device_address_i, STATE_CURRENT,
                           reset_cnt, reset_done, reset_done_mem, bit_cnt, SDA,
                           byte_2_send_mem, byte_2_read, data_out_int_mem,
                           en_FSM, sda_int_mem, sfp_address_i, bit_read_mem)
  begin
    en_reset_cnt           <= '0';
    rst_reset_cnt          <= '0';
    en_bit_cnt             <= '0';
    rst_bit_cnt            <= '0';
    en_shift_reg           <= '0';
    sda_int                <= 'Z';
    scl_int                <= 'Z';
    byte_2_send            <= byte_2_send_mem;
    data_out_int           <= data_out_int_mem;
    reset_done             <= reset_done_mem;
    bit_read               <= bit_read_mem;
    read_done_int          <= '0';
    STATE_NEXT             <= STATE_CURRENT;

    case (STATE_CURRENT) is
--IDLE
      when IDLE        =>
        if start_pulse_i = '1' and reset_done = '0' then
          STATE_NEXT    <= RESET_C;
        elsif start_pulse_i = '1' and reset_done = '1' then
          STATE_NEXT    <= START_A;
        else
          STATE_NEXT    <= IDLE;
        end if;
        debug_signal    <= x"00000001";
--RESET
      when RESET_A     =>
        scl_int         <= '0';
        sda_int         <= '1';
        if en_FSM = '1' then
          STATE_NEXT    <= RESET_B;
        end if;
        debug_signal    <= x"00000002";
--
      when RESET_B     =>
        scl_int         <= '0';
        sda_int         <= '1';
        if reset_cnt = "1000" and en_FSM = '1' then
          STATE_NEXT    <= START_C;
          rst_reset_cnt <= '1';
          reset_done    <= '1';
        elsif en_FSM = '1' then
          STATE_NEXT    <= RESET_C;
          en_reset_cnt  <= '1';
        end if;
        debug_signal    <= x"00000003";
--
      when RESET_C     =>
        scl_int         <= '1';
        sda_int         <= '1';
        if en_FSM = '1' then
          STATE_NEXT    <= RESET_D;
        end if;
        debug_signal    <= x"00000004";
--
      when RESET_D     =>
        scl_int         <= '1';
        sda_int         <= '1';
        if en_FSM = '1' then
          STATE_NEXT    <= RESET_A;
        end if;
        debug_signal    <= x"00000005";
--START
      when START_A     =>
        scl_int         <= '0';
        sda_int         <= '1';
        if en_FSM = '1' then
          STATE_NEXT    <= START_B;
        end if;
        debug_signal    <= x"00000006";
--
      when START_B     =>
        scl_int         <= '0';
        sda_int         <= '1';
        if en_FSM = '1' then
          STATE_NEXT    <= START_C;
        end if;
        debug_signal    <= x"00000007";
--
      when START_C     =>
        scl_int         <= '1';
        sda_int         <= '1';
        if en_FSM = '1' then
          STATE_NEXT    <= START_D;
        end if;
        debug_signal    <= x"00000008";
--
      when START_D     =>
        scl_int         <= '1';
        sda_int         <= '0';
        if bit_cnt = "010011" and en_FSM = '1' then
          byte_2_send   <= x"A3";
          STATE_NEXT    <= SEND_BYTE_A;
          en_bit_cnt    <= '1';
        elsif bit_cnt = "000000" and en_FSM = '1' then
          byte_2_send   <= x"A2";
          STATE_NEXT    <= SEND_BYTE_A;
          en_bit_cnt    <= '1';
        elsif en_FSM = '0' then
          STATE_NEXT    <= STATE_CURRENT;
        else
          byte_2_send   <= x"00";
          STATE_NEXT    <= IDLE;
        end if;
        debug_signal    <= x"00000009";
--STOP
      when STOP_A      =>
        scl_int         <= '0';
        sda_int         <= '0';
        if en_FSM = '1' then
          STATE_NEXT    <= STOP_B;
        end if;
        debug_signal    <= x"0000000a";
--
      when STOP_B      =>
        scl_int         <= '0';
        sda_int         <= '0';
        if en_FSM = '1' then
          STATE_NEXT    <= STOP_C;
        end if;
        debug_signal    <= x"0000000b";
--
      when STOP_C      =>
        scl_int         <= '1';
        sda_int         <= '0';
        if en_FSM = '1' then
          STATE_NEXT    <= STOP_D;
        end if;
        debug_signal    <= x"0000000c";
--
      when STOP_D      =>
        scl_int         <= '1';
        sda_int         <= '1';
        rst_bit_cnt     <= '1';
        if en_FSM = '1' then
          STATE_NEXT    <= IDLE;
        end if;
        debug_signal    <= x"0000000d";
--SEND_BYTE
      when SEND_BYTE_A =>
        scl_int         <= '0';
        sda_int         <= byte_2_send(7);
        if en_FSM = '1' then
          STATE_NEXT    <= SEND_BYTE_B;
        end if;
        debug_signal    <= x"0000000e";
--
      when SEND_BYTE_B =>
        scl_int         <= '0';
        sda_int         <= byte_2_send(7);
        if en_FSM = '1' then
          STATE_NEXT    <= SEND_BYTE_C;
        end if;
        debug_signal    <= x"0000000f";
--
      when SEND_BYTE_C =>
        scl_int         <= '1';
        sda_int         <= byte_2_send(7);
        if en_FSM = '1' then
          STATE_NEXT    <= SEND_BYTE_D;
        end if;
        debug_signal    <= x"00000010";
--
      when SEND_BYTE_D =>
        scl_int         <= '1';
        sda_int         <= byte_2_send(7);
        if (bit_cnt = "001000" or bit_cnt = "010001" or bit_cnt = "011011") and en_FSM = '1' then
          STATE_NEXT    <= READ_ACK_A;
          byte_2_send   <= byte_2_send_mem(6 downto 0) & byte_2_send_mem(7);
          en_bit_cnt    <= '1';
          en_shift_reg  <= '1';
        elsif en_FSM = '1' then
          STATE_NEXT    <= SEND_BYTE_A;
          byte_2_send   <= byte_2_send_mem(6 downto 0) & byte_2_send_mem(7);
          en_bit_cnt    <= '1';
          en_shift_reg  <= '1';
        else
          STATE_NEXT    <= STATE_CURRENT;
        end if;
        debug_signal    <= x"00000011";
--READ_BYTE
      when READ_BYTE_A =>
        scl_int         <= '0';
        if en_FSM = '1' then
          STATE_NEXT    <= READ_BYTE_B;
        end if;
        debug_signal    <= x"00000012";
--
      when READ_BYTE_B =>
        scl_int         <= '0';
        if en_FSM = '1' then
          STATE_NEXT    <= READ_BYTE_C;
        end if;
        debug_signal    <= x"00000013";
--
      when READ_BYTE_C =>
        scl_int         <= '1';
        bit_read        <= SDA(select_line);
        if en_FSM = '1' then
          STATE_NEXT    <= READ_BYTE_D;
        end if;
        debug_signal    <= x"00000014";
--
      when READ_BYTE_D =>
        scl_int         <= '1';
        if (bit_cnt = "100100" or bit_cnt = "101100") and en_FSM = '1' then
          STATE_NEXT    <= SEND_ACK_A;
          en_bit_cnt    <= '1';
          en_shift_reg  <= '1';
        elsif en_FSM = '1' then
          STATE_NEXT    <= READ_BYTE_A;
          en_bit_cnt    <= '1';
          en_shift_reg  <= '1';
        else
          STATE_NEXT    <= STATE_CURRENT;
        end if;
        debug_signal    <= x"00000015";
--SEND_ACK
      when SEND_ACK_A  =>
        scl_int         <= '0';
        if bit_cnt = "101101" then
          sda_int       <= '1';
        elsif bit_cnt = "100101" then
          sda_int       <= '0';
        else
          sda_int       <= 'X';
        end if;
        if en_FSM = '1' then
          STATE_NEXT    <= SEND_ACK_B;
        end if;
        debug_signal    <= x"00000016";
--
      when SEND_ACK_B  =>
        scl_int         <= '0';
        if bit_cnt = "101101" then
          sda_int       <= '1';
        elsif bit_cnt = "100101" then
          sda_int       <= '0';
        else
          sda_int       <= 'X';
        end if;
        if en_FSM = '1' then
          STATE_NEXT    <= SEND_ACK_C;
        end if;
        debug_signal    <= x"00000017";
--
      when SEND_ACK_C  =>
        scl_int         <= '1';
        if bit_cnt = "101101" then
          sda_int       <= '1';
        elsif bit_cnt = "100101" then
          sda_int       <= '0';
        else
          sda_int       <= 'X';
        end if;
        if en_FSM = '1' then
          STATE_NEXT    <= SEND_ACK_D;
        end if;
        debug_signal    <= x"00000018";
--
      when SEND_ACK_D  =>
        scl_int         <= '1';
        if bit_cnt = "101101" and en_FSM = '1' then
          sda_int       <= '1';
          STATE_NEXT    <= STOP_A;
          data_out_int  <= byte_2_read;
          read_done_int <= '1';
        elsif bit_cnt = "100101" and en_FSM = '1' then
          sda_int       <= '0';
          STATE_NEXT    <= READ_BYTE_A;
        elsif en_FSM = '0' then
          sda_int       <= sda_int_mem;
          STATE_NEXT    <= STATE_CURRENT;
        else
          sda_int       <= 'X';
          STATE_NEXT    <= IDLE;
        end if;
        debug_signal    <= x"00000019";
--READ_ACK
      when READ_ACK_A  =>
        scl_int         <= '0';
        if en_FSM = '1' then
          STATE_NEXT    <= READ_ACK_B;
        end if;
        debug_signal    <= x"0000001a";
--
      when READ_ACK_B  =>
        scl_int         <= '0';
        if en_FSM = '1' then
          STATE_NEXT    <= READ_ACK_C;
        end if;
        debug_signal    <= x"0000001b";
--
      when READ_ACK_C  =>
        scl_int         <= '1';
        bit_read        <= SDA(select_line);
        if en_FSM = '1' then
          STATE_NEXT    <= READ_ACK_D;
        end if;
        debug_signal    <= x"0000001c";
--
      when READ_ACK_D  =>
        scl_int         <= '1';
        if bit_read = '0' and bit_cnt = "001001" and en_FSM = '1' then
          STATE_NEXT    <= SEND_BYTE_A;
          byte_2_send   <= sfp_address_i(7 downto 0);
          en_bit_cnt    <= '1';
        elsif bit_read = '0' and bit_cnt = "010010" and en_FSM = '1' then
          STATE_NEXT    <= START_A;
          en_bit_cnt    <= '1';
        elsif bit_read = '0' and bit_cnt = "011100" and en_FSM = '1' then
          STATE_NEXT    <= READ_BYTE_A;
          en_bit_cnt    <= '1';
        elsif bit_read = '1' and en_FSM = '1' then
          STATE_NEXT    <= STOP_A;
          en_bit_cnt    <= '1';
        elsif en_FSM = '0' then
          STATE_NEXT    <= STATE_CURRENT;
        else
          STATE_NEXT    <= IDLE;
        end if;
        debug_signal    <= x"0000001d";
--OTHERS
      when others      =>
        scl_int         <= '1';
        sda_int         <= '1';
        byte_2_send     <= x"00";
        STATE_NEXT      <= IDLE;
        debug_signal    <= x"0000001e";

  end case;
end process State_Decoder;
-------------------------------------------------------------------------------

end behavioral;
