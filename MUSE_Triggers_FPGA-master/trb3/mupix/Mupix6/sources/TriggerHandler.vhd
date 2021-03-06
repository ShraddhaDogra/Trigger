-----------------------------------------------------------------------------
-- Trigger Handler for TRBnet
-- Tobias Weber, University Mainz
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
--use work.trb_net_std.all;
--use work.trb_net_components.all;
--use work.trb3_components.all;

entity TriggerHandler is
  port (
    CLK_IN                     : in  std_logic;
    RESET_IN                   : in  std_logic;
    
    --Input Triggers          
    TIMING_TRIGGER_IN          : in std_logic; -- The raw timing Trigger Signal 
    LVL1_TRG_DATA_VALID_IN     : in std_logic; -- Data Trigger is valid
    LVL1_VALID_TIMING_TRG_IN   : in std_logic; -- Timin Trigger is valid
    LVL1_VALID_NOTIMING_TRG_IN : in std_logic; -- calib trigger w/o ref time
    LVL1_INVALID_TRG_IN        : in std_logic; 

    LVL1_TRG_TYPE_IN           : in std_logic_vector(3 downto 0);
    LVL1_TRG_NUMBER_IN         : in std_logic_vector(15 downto 0);
    LVL1_TRG_CODE_IN           : in std_logic_vector(7 downto 0);
    LVL1_TRG_INFORMATION_IN    : in std_logic_vector(23 downto 0);
    LVL1_INT_TRG_NUMBER_IN     : in std_logic_vector(15 downto 0);

    --Response from FEE
    FEE_DATA_OUT               : out std_logic_vector(31 downto 0);
    FEE_DATA_WRITE_OUT         : out std_logic;
    FEE_DATA_FINISHED_OUT      : out std_logic;
    FEE_TRG_RELEASE_OUT        : out std_logic;
    FEE_TRG_STATUSBITS_OUT     : out std_logic_vector(31 downto 0);

    FEE_DATA_0_IN              : in  std_logic_vector(31 downto 0);
    FEE_DATA_WRITE_0_IN        : in  std_logic;
    
    -- Trigger FeedBack
    TRIGGER_BUSY_MUPIX_READ_IN  : in  std_logic;
    TRIGGER_BUSY_FIFO_READ_IN   : in  std_logic;
    
    -- OUT
    VALID_TRIGGER_OUT          : out std_logic;
    TRIGGER_TIMING_OUT         : out std_logic;
    TRIGGER_STATUS_OUT         : out std_logic;
    FAST_CLEAR_OUT             : out std_logic;--clear event buffer
    FLUSH_BUFFER_OUT           : out std_logic;
    
    -- Slave bus               
    SLV_READ_IN                : in  std_logic;
    SLV_WRITE_IN               : in  std_logic;
    SLV_DATA_OUT               : out std_logic_vector(31 downto 0);
    SLV_DATA_IN                : in  std_logic_vector(31 downto 0);
    SLV_ADDR_IN                : in  std_logic_vector(15 downto 0);
    SLV_ACK_OUT                : out std_logic;
    SLV_NO_MORE_DATA_OUT       : out std_logic;
    SLV_UNKNOWN_ADDR_OUT       : out std_logic);

end entity TriggerHandler;


architecture behavioral of TriggerHandler is

--trigger
  signal bypass_trigger          : std_logic := '0';
  signal reset_trigger_state     : std_logic                     := '0';
  signal reset_trigger_state_edge : std_logic_vector(1 downto 0) := "00";
  signal valid_trigger_int       : std_logic                     := '0';
  signal timing_trigger_int      : std_logic                     := '0';
  signal timing_trigger_edge     : std_logic_vector(1 downto 0)  := "00";
  signal status_trigger_int      : std_logic                     := '0';
  signal fast_clear_int          : std_logic                     := '0';
  signal flush_buffer_int        : std_logic                     := '0';
  signal trigger_busy_int        : std_logic                     := '0';
  signal mupix_readout_end_int   : std_logic_vector(1 downto 0)  := "00";
  signal fifo_readout_end_int    : std_logic_vector(1 downto 0)  := "00";
--fee
  signal fee_data_int            : std_logic_vector(31 downto 0) := (others => '0');
  signal fee_data_write_int      : std_logic                      := '0';
  signal fee_data_finished_int   : std_logic                     := '0';
  signal fee_trg_release_int     : std_logic                     := '0';
  signal fee_trg_statusbit_int   : std_logic_vector(31 downto 0) := (others => '0');
--event buffer

--registers
  signal reset_trigger_counters : std_logic := '0';
  signal reset_trigger_counters_edge : std_logic_vector(1 downto 0) := (others => '0');
  signal trigger_rate_acc : unsigned(31 downto 0) := (others => '0');
  signal trigger_rate_tot : unsigned(31 downto 0) := (others => '0');
  signal trigger_rate_time_counter : unsigned(31 downto 0) := (others => '0');
  signal invalid_trigger_counter : unsigned(31 downto 0) := (others => '0');
  signal valid_trigger_counter : unsigned(31 downto 0) := (others => '0');
  signal invalid_trigger_counter_t : unsigned(31 downto 0)  := (others => '0');
  signal valid_trigger_counter_t : unsigned(31 downto 0) := (others => '0');
  signal trigger_handler_state : std_logic_vector(7 downto 0) := (others => '0');
  
--trigger types
  constant trigger_physics_type : std_logic_vector(3 downto 0) := x"1";
  constant trigger_status_type  : std_logic_vector(3 downto 0) := x"e";

--trigger handler
  type trigger_handler_type is (idle,
                                timing_trigger,
                                no_timing_trigger,
                                check_trigger_type,
                                status_trigger,
                                write_data_to_eventbuffer,
                                write_data_to_ipu,
                                trigger_release_a,
                                trigger_release_b,
                                trigger_release_c,
                                wait_trigger_release,
                                ignore,
                                wait_trigger_data_valid_a,
                                wait_trigger_data_valid_b);
  
  type trigger_type_type is (t_timing,
                             t_physics,
                             t_status,
                             t_ignore,
                             t_unknown);

  signal trigger_handler_fsm : trigger_handler_type := idle;
  signal trigger_type        : trigger_type_type    := t_unknown;
  signal wr_header_int : std_logic := '0';
  signal wr_data_int : std_logic := '0';
  signal wr_status_int : std_logic := '0';
  signal wr_dummy_int : std_logic := '0';
  
begin
  
  Signal_Edge_Detect: process (CLK_IN) is
  begin  -- process Mupix_Readout_End_Detect
    if rising_edge(CLK_IN) then
      mupix_readout_end_int <= mupix_readout_end_int(0) & TRIGGER_BUSY_MUPIX_READ_IN;
      fifo_readout_end_int <= fifo_readout_end_int(0) & TRIGGER_BUSY_FIFO_READ_IN;
      timing_trigger_edge <= timing_trigger_edge(0) & TIMING_TRIGGER_IN;
      reset_trigger_state_edge <= reset_trigger_state_edge(1) & reset_trigger_state;
    end if;
  end process Signal_Edge_Detect;

  ------------------------------------------------------------
  --Handling of LVL1 triggers
  ------------------------------------------------------------
  trigger_handler_proc: process is
  begin  -- process trigger_handler_proc
    wait until rising_edge(clk_in);
    valid_trigger_int       <= '0';
    timing_trigger_int      <= '0';
    status_trigger_int      <= '0';
    flush_buffer_int        <= '0';
    fee_data_finished_int   <= '0';
    fee_trg_release_int     <= '0';
    fee_trg_statusbit_int   <= (others => '0');
    fast_clear_int          <= '0';
    trigger_busy_int        <= '1';
    fast_clear_int          <= '0';
    fee_trg_release_int     <= '0';
    wr_header_int           <= '0';
    wr_data_int             <= '0';
    wr_status_int           <= '0';
    wr_dummy_int            <= '0';
    if LVL1_INVALID_TRG_IN = '1' or reset_trigger_state_edge = "01" then
      fast_clear_int      <= '1';
      fee_trg_release_int <= '1';
      trigger_handler_fsm <= idle;
    else
      case trigger_handler_fsm is
        when idle =>
          trigger_busy_int        <= '0';
          trigger_handler_state <= x"01";
          if LVL1_VALID_TIMING_TRG_IN = '1' then
              wr_header_int <= '1';
              if bypass_trigger = '1' then
                trigger_type <= t_ignore;
                trigger_handler_fsm <= ignore;
              else
                trigger_type <= t_timing;
                trigger_handler_fsm <= timing_trigger;
              end if;
          elsif(LVL1_VALID_NOTIMING_TRG_IN = '1') then
            wr_header_int <= '1';
            if bypass_trigger = '1' then
              trigger_type <= t_ignore;
              trigger_handler_fsm <= ignore;
            else
              trigger_handler_fsm <= check_trigger_type;
            end if;
          end if;
          
        when check_trigger_type =>
          trigger_handler_state <= x"02";
          if(LVL1_TRG_DATA_VALID_IN = '1') then
            if(LVL1_TRG_TYPE_IN = trigger_status_type) then
              trigger_type        <= t_status;
              trigger_handler_fsm <= no_timing_trigger;
            elsif(LVL1_TRG_TYPE_IN = trigger_physics_type) then
              trigger_type        <= t_physics;
              trigger_handler_fsm <= no_timing_trigger;
            else
              --unknown trigger
              trigger_type        <= t_unknown;
              trigger_handler_fsm <= no_timing_trigger;
            end if;
          else
            trigger_handler_fsm <= check_trigger_type;
          end if;
          
        when timing_trigger =>--starts mupix readout fsm
          trigger_handler_state <= x"03";
          valid_trigger_int <= '1';
          timing_trigger_int <= '1';
          trigger_handler_fsm <= write_data_to_eventbuffer;

        when no_timing_trigger =>
          trigger_handler_state <= x"04";
          if trigger_type = t_physics then
            trigger_handler_fsm <= timing_trigger;
          elsif trigger_type = t_status then
            trigger_handler_fsm <= status_trigger;
          else
            trigger_handler_fsm <= ignore;
          end if;

        when ignore =>
          wr_dummy_int          <= '1'; --write a dummy value to identify
                                        --inactive FEE
          trigger_handler_state <= x"05";
          trigger_handler_fsm <= wait_trigger_data_valid_b;

        when status_trigger => --dummy implementation
          trigger_handler_state <= x"06";
          wr_status_int <= '1';
          trigger_handler_fsm <= wait_trigger_data_valid_b;
          
        when write_data_to_eventbuffer =>
          trigger_handler_state <= x"07";
          if mupix_readout_end_int = "10" then
            trigger_handler_fsm <= write_data_to_ipu;
            flush_buffer_int <= '1';
          else
            trigger_handler_fsm <= write_data_to_eventbuffer;
          end if;

        when write_data_to_ipu =>
          trigger_handler_state <= x"0A";
          wr_data_int <= '1';
          if fifo_readout_end_int = "10" then
            wr_data_int <= '0';
            trigger_handler_fsm <= wait_trigger_data_valid_a;
          else
            trigger_handler_fsm <= write_data_to_ipu;
          end if;

        when wait_trigger_data_valid_a =>
          trigger_handler_state <= x"0B";
          if LVL1_TRG_DATA_VALID_IN = '1' then
            trigger_handler_fsm <= wait_trigger_data_valid_b;
          end if;
          
        when wait_trigger_data_valid_b =>
          trigger_handler_state <= x"0C";
          trigger_handler_fsm <= trigger_release_a;
          
        when trigger_release_a =>
          trigger_handler_state <= x"0D";
          trigger_handler_fsm <= trigger_release_b;

        when trigger_release_b =>
          trigger_handler_state <= x"0E";
          fee_data_finished_int <= '1';
          trigger_handler_fsm <= trigger_release_c;
          
        when trigger_release_c =>
          trigger_handler_state <= x"0F";
          fee_trg_release_int <= '1';
          trigger_handler_fsm <= wait_trigger_release;

        when wait_trigger_release =>
          if(LVL1_TRG_DATA_VALID_IN = '1') then
            trigger_handler_fsm <= wait_trigger_release;
          else
            trigger_handler_fsm <= idle;
          end if;
      end case;
    end if;
  end process trigger_handler_proc;

  ------------------------------------------------------------
  --Data Output Mux
  ------------------------------------------------------------
  Data_Out_Mux: process (clk_in) is
  begin  -- process Data_Out_Mux
    if rising_edge(clk_in) then
      if wr_header_int = '1' then
        fee_data_write_int <= '1';--header see Hades DAQ user guide
        fee_data_int <= "001" & "0" & LVL1_TRG_TYPE_IN & LVL1_TRG_CODE_IN & LVL1_TRG_NUMBER_IN;
      elsif wr_data_int = '1' then
        fee_data_write_int <= FEE_DATA_WRITE_0_IN;
        fee_data_int <= FEE_DATA_0_IN;
      elsif wr_status_int = '1' then
         fee_data_int <= x"deadbeef";
         fee_data_write_int <= '1';
      elsif wr_dummy_int = '1' then
         fee_data_write_int <= '1' ;
         fee_data_int <= x"fff00000";
      else
        fee_data_write_int <= '0';
        fee_data_int <= (others => '1');
      end if;
    end if;
  end process Data_Out_Mux;

  
  ------------------------------------------------------------
  --Trigger statistics
  ------------------------------------------------------------
  Trigger_Statistics_Proc: process (clk_in) is
  begin  -- process Trigger_Statistics_Proc
    if rising_edge(CLK_IN) then
      reset_trigger_counters_edge <= reset_trigger_counters_edge(0) & reset_trigger_counters;
      if reset_trigger_counters_edge = "01" then
        trigger_rate_acc <= (others => '0');
        invalid_trigger_counter_t <= (others => '0');
        valid_trigger_counter_t  <= (others => '0');
        trigger_rate_time_counter <= (others => '0');
      end if;
      if trigger_rate_time_counter < x"5f5e100" then--1s at 10ns clock period
      --if trigger_rate_time_counter < x"000007e" then
        trigger_rate_time_counter <= trigger_rate_time_counter + 1;
        if valid_trigger_int = '1' then
          valid_trigger_counter_t <= valid_trigger_counter_t + 1;
        elsif LVL1_INVALID_TRG_IN = '1' or (trigger_busy_int = '1' and  timing_trigger_edge = "01") then
          invalid_trigger_counter_t <= invalid_trigger_counter_t + 1;
        end if;
      else
        valid_trigger_counter <= valid_trigger_counter + valid_trigger_counter_t;
        invalid_trigger_counter <= invalid_trigger_counter + invalid_trigger_counter_t;
        trigger_rate_acc <= valid_trigger_counter_t;
        trigger_rate_tot <= valid_trigger_counter_t + invalid_trigger_counter_t;
        trigger_rate_time_counter <= (others => '0');
        valid_trigger_counter_t <= (others => '0');
        invalid_trigger_counter_t <= (others => '0');
      end if;
    end if;
  end process Trigger_Statistics_Proc;
  
  ------------------------------------------------------------
  --TRB SLV-BUS Hanlder
  ------------------------------------------------------------
  --0x100: accepted trigger_rate
  --0x101: total trigger_rate
  --0x102: invalid triggers
  --0x103: valid triggers
  --0x104: trigger_handler_state
  --0x105: reset counters
  --0x106: reset trigger state machine
  --0x107: bypass trigger signals flag
 
  slv_bus_handler : process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      slv_data_out         <= (others => '0');
      slv_ack_out          <= '0';
      slv_no_more_data_out <= '0';
      slv_unknown_addr_out <= '0';
      
      if slv_write_in = '1' then
       case SLV_ADDR_IN is
         when x"0105" =>
           reset_trigger_counters <= SLV_DATA_IN(0);
           slv_ack_out  <= '1';
         when x"0106" =>
           reset_trigger_state <= SLV_DATA_IN(0);
           slv_ack_out  <= '1';
         when x"0107"=>
           bypass_trigger <= SLV_DATA_IN(0);
           slv_ack_out <= '1';
         when others =>
           slv_unknown_addr_out <= '1';
       end case;
       
      elsif slv_read_in = '1' then
        case slv_addr_in is
          when x"0100" =>
            slv_data_out <= std_logic_vector(trigger_rate_acc);
            slv_ack_out  <= '1';
          when x"0101" =>
            slv_data_out <= std_logic_vector(trigger_rate_tot);
            slv_ack_out  <= '1';
          when x"0102" =>
            slv_data_out <= std_logic_vector(invalid_trigger_counter);
            slv_ack_out               <= '1';
           when x"0103" =>
            slv_data_out <= std_logic_vector(valid_trigger_counter);
            slv_ack_out               <= '1';
          when x"0104" =>
            slv_data_out <= x"000000" & trigger_handler_state;
            slv_ack_out               <= '1';
          when x"0107" =>
            slv_data_out(0) <= bypass_trigger; 
            slv_ack_out <= '1';
          when others =>
            slv_unknown_addr_out <= '1';
        end case;

      end if;
    end if;
  end process slv_bus_handler;

  --map output signals
  valid_trigger_out     <= valid_trigger_int;
  trigger_timing_out    <= timing_trigger_int;
  trigger_status_out    <= status_trigger_int;
  fast_clear_out        <= fast_clear_int;
  flush_buffer_out      <= flush_buffer_int;
  fee_data_out          <= fee_data_int;
  fee_data_write_out    <= fee_data_write_int;
  fee_data_finished_out <= fee_data_finished_int;
  fee_trg_release_out   <= fee_trg_release_int;
  fee_trg_statusbits_out <= fee_trg_statusbit_int;

end architecture behavioral;
