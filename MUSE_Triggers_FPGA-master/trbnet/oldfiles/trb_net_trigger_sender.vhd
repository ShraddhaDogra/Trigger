-- this is a dummy apl, just sending short transfers / triggers


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.trb_net_std.all;


entity trb_net_trigger_sender is
    generic (TARGET_ADDRESS : STD_LOGIC_VECTOR (15 downto 0) := x"0002"
            );
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
end trb_net_trigger_sender;

architecture trb_net_trigger_sender_arch of trb_net_trigger_sender is

  type SENDER_STATE is (IDLE, RUNNING, MY_ERROR);
  signal current_state, next_state : SENDER_STATE;
  signal next_counter, counter  : std_logic_vector(23 downto 0);
  signal buf_APL_DATA_OUT, next_APL_DATA_OUT : std_logic_vector(23 downto 0);
  signal buf_APL_WRITE_OUT, next_APL_WRITE_OUT : std_logic;
  signal buf_APL_SEND_OUT, next_APL_SEND_OUT : std_logic;

  begin

  APL_READ_OUT <= '1';                  --just read, do not check
  APL_DTYPE_OUT <= x"1";
  APL_ERROR_PATTERN_OUT <= x"00000100";
  APL_TARGET_ADDRESS_OUT <= x"0000";
  --APL_DATA_OUT <= reg_counter;
  APL_SHORT_TRANSFER_OUT <= '1';
  APL_WRITE_OUT <=  '0';
  APL_DATA_OUT <= (others => '0');
    
  SENDER_CTRL: process (current_state, APL_FIFO_FULL_IN, counter, APL_RUN_IN, RESET)
    begin  -- process
      next_APL_SEND_OUT <=  '0';
      next_state <=  MY_ERROR;
      next_counter <=  counter + 1;
-------------------------------------------------------------------------
-- IDLE
-------------------------------------------------------------------------
      if current_state = IDLE then
        if APL_RUN_IN = '0' and counter(7 downto 0) = 0 then
          next_state <=  RUNNING;
          next_APL_SEND_OUT <= '1';
        else
          next_state <=  IDLE;
        end if;
-----------------------------------------------------------------------
-- RUNNING
-----------------------------------------------------------------------
      elsif current_state = RUNNING then
        next_state <= RUNNING;
        if APL_RUN_IN = '1' then 
          next_state <= IDLE;
        --else
        --  next_state <= RUNNING;
        end if;
      end if;                           -- end state switch
    end process;

APL_SEND_OUT <= buf_APL_SEND_OUT;

    CLK_REG: process(CLK)
    begin
    if rising_edge(CLK) then
      if RESET = '1' then
        current_state  <= IDLE;
        buf_APL_SEND_OUT <= '0';
        counter <= (others => '0');
      elsif CLK_EN = '1' then
        current_state  <= next_state;
        buf_APL_SEND_OUT <= next_APL_SEND_OUT;
        counter <= next_counter;
      else
        current_state  <= current_state;
        buf_APL_SEND_OUT <= buf_APL_SEND_OUT;
        counter <= counter;
      end if;
    end if;
  end process;

end trb_net_trigger_sender_arch;
