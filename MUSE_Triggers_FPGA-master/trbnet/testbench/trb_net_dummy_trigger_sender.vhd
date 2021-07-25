-- this is a dummy apl, just sending data into an active api


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;


entity trb_net_dummy_trigger_sender is
    generic (TARGET_ADDRESS : STD_LOGIC_VECTOR (15 downto 0) := x"ffff";
             PREFILL_LENGTH  : integer := 3;
             TRANSFER_LENGTH  : integer := 6);  -- length of dummy data
                                    -- might not work with transfer_length > api_fifo
                                    -- because of incorrect handling of fifo_full_in!
  
    port(
    --  Misc
    CLK    : in std_logic;  		
    RESET  : in std_logic;  	
    CLK_EN : in std_logic;

    -- APL Transmitter port
    APL_DATA_OUT:       out STD_LOGIC_VECTOR (47 downto 0); -- Data word "application to network"
    APL_WRITE_OUT:      out STD_LOGIC; -- Data word is valid and should be transmitted
    APL_FIFO_FULL_IN:   in  STD_LOGIC; -- Stop transfer, the fifo is full
    APL_SHORT_TRANSFER_OUT: out STD_LOGIC; -- 
    APL_DTYPE_OUT:      out STD_LOGIC_VECTOR (3 downto 0);  -- see NewTriggerBusNetworkDescr
    APL_ERROR_PATTERN_OUT: out STD_LOGIC_VECTOR (31 downto 0); -- see NewTriggerBusNetworkDescr
    APL_SEND_OUT:       out STD_LOGIC; -- Release sending of the data
    APL_TARGET_ADDRESS_OUT: out STD_LOGIC_VECTOR (15 downto 0); -- Address of
                                                               -- the target (only for active APIs)

    -- Receiver port
    APL_DATA_IN:      in  STD_LOGIC_VECTOR (47 downto 0); -- Data word "network to application"
    APL_TYP_IN:       in  STD_LOGIC_VECTOR (2 downto 0);  -- Which kind of data word: DAT, HDR or TRM
    APL_DATAREADY_IN: in  STD_LOGIC; -- Data word is valid and might be read out
    APL_READ_OUT:     out STD_LOGIC; -- Read data word
    
    -- APL Control port
    APL_RUN_IN:       in STD_LOGIC; -- Data transfer is running
--    APL_MY_ADDRESS_OUT: in  STD_LOGIC_VECTOR (15 downto 0);  -- My own address (temporary solution!!!)
    APL_SEQNR_IN:     in STD_LOGIC_VECTOR (7 downto 0)

    );
end trb_net_dummy_trigger_sender;

architecture trb_net_dummy_trigger_sender_arch of trb_net_dummy_trigger_sender is

  type SENDER_STATE is (IDLE, RUNNING, WAITING, MY_ERROR);
  signal current_state, next_state : SENDER_STATE;
  signal next_counter, reg_counter  : std_logic_vector(23 downto 0);
  signal buf_APL_DATA_OUT, next_APL_DATA_OUT : std_logic_vector(23 downto 0);
  signal buf_APL_WRITE_OUT, next_APL_WRITE_OUT : std_logic;
  signal buf_APL_SEND_OUT, next_APL_SEND_OUT : std_logic;

  begin

  APL_READ_OUT <= '1';                  --just read, do not check
  APL_DTYPE_OUT <= x"1";
  APL_ERROR_PATTERN_OUT <= x"12345678";
  APL_TARGET_ADDRESS_OUT <= TARGET_ADDRESS;
  --APL_DATA_OUT <= reg_counter;

  CHECK_1:if TRANSFER_LENGTH >0 generate  
    APL_SHORT_TRANSFER_OUT <= '0';
  end generate;
  CHECK_2:if TRANSFER_LENGTH =0 generate  
    APL_SHORT_TRANSFER_OUT <= '1';
  end generate;

    
  SENDER_CTRL: process (current_state, APL_FIFO_FULL_IN, reg_counter, APL_RUN_IN, RESET)
    begin  -- process
      next_APL_SEND_OUT <=  '0';
      next_state <=  MY_ERROR;
      next_counter <=  reg_counter;
      next_APL_WRITE_OUT <=  '0';
-------------------------------------------------------------------------
-- IDLE
-------------------------------------------------------------------------
      if current_state = IDLE then
        if APL_FIFO_FULL_IN = '1' or reg_counter = PREFILL_LENGTH then
          next_state <=  RUNNING;
        else
          next_state <=  IDLE;
          next_counter <=  reg_counter +1;
          next_APL_WRITE_OUT <=  '1';
        end if;
-----------------------------------------------------------------------
-- RUNNING
-----------------------------------------------------------------------
      elsif current_state = RUNNING then
        next_APL_SEND_OUT <=  '1';
        if reg_counter = TRANSFER_LENGTH then
          next_state <=  WAITING;
        else
          next_state <=  RUNNING;
          if APL_FIFO_FULL_IN = '0' then 
            next_counter <=  reg_counter +1;
            next_APL_WRITE_OUT <=  '1';
          end if;
        end if;
-----------------------------------------------------------------------
-- WAITING
-----------------------------------------------------------------------
      elsif current_state = WAITING then
        if APL_RUN_IN = '1' then
          next_state <=  WAITING;
        else
          next_state <=  IDLE;
          next_counter <=  (others => '0');
        end if;
      end if;                           -- end state switch
    if RESET = '1' then
      next_APL_WRITE_OUT <=  '0';
    end if;
    end process;

APL_DATA_OUT(47 downto 24) <= (others => '0');
APL_DATA_OUT(23 downto 0) <= buf_APL_DATA_OUT;
APL_WRITE_OUT <= buf_APL_WRITE_OUT;
APL_SEND_OUT <= buf_APL_SEND_OUT;

    CLK_REG: process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        current_state  <= IDLE;
        reg_counter <= (others => '0');
        buf_APL_DATA_OUT <= (others => '0');
        buf_APL_WRITE_OUT <= '0';
        buf_APL_SEND_OUT <= '0';

      elsif CLK_EN = '1' then
        reg_counter <= next_counter;
        current_state  <= next_state;
        buf_APL_DATA_OUT <= reg_counter;
        buf_APL_WRITE_OUT <= next_APL_WRITE_OUT;
        buf_APL_SEND_OUT <= next_APL_SEND_OUT;
      else
        reg_counter <= reg_counter;
        current_state  <= current_state;
        buf_APL_DATA_OUT <= buf_APL_DATA_OUT;
        buf_APL_WRITE_OUT <= buf_APL_WRITE_OUT;
        buf_APL_SEND_OUT <= buf_APL_SEND_OUT;
      end if;
    end if;
  end process;
    
end trb_net_dummy_trigger_sender_arch;
