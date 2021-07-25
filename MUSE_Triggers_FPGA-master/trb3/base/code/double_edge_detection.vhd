library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
library work;
  use work.trb_net_std.all;
  use work.config.all;

entity double_edge_detection is
  generic(
    CHANNELS : integer := 32
    );
  port(
    CLK         : in std_logic;
    RESET       : in std_logic;
    
    INP         : in std_logic_vector(CHANNELS-1 downto 0);
    
    --Slowcontrol
    BUS_RX     : in  CTRLBUS_RX;
    BUS_TX     : out CTRLBUS_TX;
    
    READOUT_RX : in  READOUT_RX;
    READOUT_TX : out READOUT_TX;
    
    DEBUG_OUT  : out std_logic_vector(7 downto 0)
    
    );
end entity;


architecture arch of double_edge_detection is

  signal maxage          : unsigned(15 downto 0);
  signal waitage         : unsigned(15 downto 0);
  signal window          : unsigned(3 downto 0);

  signal timer           : unsigned(27 downto 0);

  type storage_t is array (0 to CHANNELS) of std_logic_vector(31 downto 0);
  signal storage : storage_t;
  signal clear_storage : std_logic;

  signal data_counter : integer range 0 to 65535;

  type state_t is (IDLE, WAIT_AFTER, WRITE, FINISH, BUSYEND);
  signal state : state_t;

  signal found_double    : std_logic_vector(CHANNELS-1 downto 0);


--   signal reg_INP                              : std_logic_vector(CHANNELS-1 downto 0);
--   signal INP_low, reg_INP_low, reg2_INP_low   : std_logic_vector(CHANNELS-1 downto 0);
--   signal INP_low_long, reg_INP_low_long       : std_logic_vector(CHANNELS-1 downto 0);
  
  signal reg_INP, INP_b, reg2_INP, reg3_INP, INP_long        : std_logic_vector(CHANNELS-1 downto 0);
  signal INP_low, reg_INP_low, reg2_INP_low   : std_logic_vector(CHANNELS-1 downto 0);
  signal INP_low_long, reg_INP_low_long       : std_logic_vector(CHANNELS-1 downto 0);
  signal reset_found : std_logic_vector(CHANNELS-1 downto 0);
   
  
  
begin

PROC_REGS : process begin
  wait until rising_edge(CLK);
  BUS_TX.ack     <= '0';
  BUS_TX.nack    <= '0';
  BUS_TX.unknown <= '0';
  BUS_TX.data    <= (others => '0');
  
  if BUS_RX.write = '1' then
    BUS_TX.ack <= '1';
    case BUS_RX.addr(1 downto 0) is
--       when "00"   => maxage <= unsigned(BUS_RX.data(15 downto 0));  -- max age to include in data, not implemented yet
      when "01"   => waitage <= unsigned(BUS_RX.data(15 downto 0)); -- time after reference time
      when "10"   => window  <= unsigned(BUS_RX.data(3 downto 0));  --clock cycles between rising edges
      when others => BUS_TX.ack <= '0'; BUS_TX.unknown <= '1';
    end case;
  elsif BUS_RX.read = '1' then
    BUS_TX.ack <= '1';
    case BUS_RX.addr(1 downto 0) is
--       when "00"   => BUS_TX.data(15 downto 0) <= std_logic_vector(maxage);
      when "01"   => BUS_TX.data(15 downto 0) <= std_logic_vector(waitage);
      when "10"   => BUS_TX.data(3 downto 0)  <= std_logic_vector(window);
      when others => BUS_TX.ack <= '0'; BUS_TX.unknown <= '1';
    end case;
  end if;
end process;


THE_TIME : process begin
  wait until rising_edge(CLK);
  timer <= timer + 1;
end process;


THE_RDO : process begin
  wait until rising_edge(CLK);
  READOUT_TX.busy_release  <= '0';
  READOUT_TX.data_write    <= '0';
  READOUT_TX.data_finished <= '0';
  clear_storage <= '0';  
  
  case state is
    when IDLE => 
      if READOUT_RX.valid_timing_trg = '1' or READOUT_RX.valid_notiming_trg = '1' then
        state <= WAIT_AFTER;
      end if;
      if READOUT_RX.invalid_trg = '1' then
        state <= FINISH;
      end if;
      data_counter <= 0;
    when WAIT_AFTER =>
      data_counter <= data_counter + 1;
      if waitage = 0 or to_unsigned(data_counter,16) = waitage then
        state <= WRITE;
        data_counter <= 0;
      end if;  
    when WRITE =>
      READOUT_TX.data  <= storage(data_counter);
      READOUT_TX.data_write <= '1';
      data_counter <= data_counter + 1;
      if data_counter = CHANNELS then
        state <= FINISH;
      end if;
    when FINISH =>
      state <= BUSYEND;
      READOUT_TX.data_finished <= '1';
      clear_storage <= '1';
    when BUSYEND =>
      state <= IDLE;
      READOUT_TX.busy_release <= '1';
  end case;
end process;


THE_STORE : process begin
  wait until rising_edge(CLK);
  for i in 0 to CHANNELS-1 loop
    if found_double(i) = '1' then
      storage(i+1) <= "1000" & std_logic_vector(timer);
    elsif clear_storage = '1' then
      storage(i+1) <= (others => '0');
    end if;
  end loop;
  
  if READOUT_RX.valid_timing_trg = '1' then
    storage(0) <= "1000" & std_logic_vector(timer);
  elsif clear_storage = '1' then
    storage(0) <= (others => '0');
  end if;
end process;
  
  
-- THE_DETECT : process begin
--   wait until rising_edge(CLK);
--   for i in 0 to CHANNELS-1 loop
--     if reg_INP(i) = '1' and reg_INP_low_long(i) = '1' then
--       found_double(i) <= '1';
--     else
--       found_double(i) <= '0';
--     end if;  
--   end loop;
-- end process;
-- 
-- 
-- -- INP_b      <= INP or INP_b and not reg_INP_b;
-- reg_INP  <= INP      when rising_edge(CLK);
-- 
-- -- reg3_INP_b <= reg2_INP_b when rising_edge(CLK);
-- -- INP_long   <= reg3_INP_b or reg2_INP_b or reg_INP_b or INP_b;
-- 
-- INP_low      <= not INP and reg_INP;
-- 
-- reg_INP_low  <= INP_low     when rising_edge(CLK);
-- reg2_INP_low <= reg_INP_low when rising_edge(CLK);
-- INP_low_long <= INP_low or reg_INP_low or reg2_INP_low;
-- reg_INP_low_long <= INP_low_long when rising_edge(CLK);
-- 


INP_b    <= (INP or INP_b) and not reg_INP;
reg_INP  <= INP_b      when rising_edge(CLK);
reg2_INP <= reg_INP    when rising_edge(CLK);
reg3_INP <= reg2_INP when rising_edge(CLK);
INP_long   <= reg3_INP or reg2_INP or reg_INP or INP_b;

THE_DETECT : process(reset_found, INP) begin
  for i in 0 to CHANNELS-1 loop
    if reset_found(i) = '1' then
      found_double(i) <= '0';
    elsif rising_edge(INP(i)) and INP_long(i) = '1' then
      found_double(i) <= '1';
    end if;  
  end loop;  
end process;

reset_found <= found_double when rising_edge(CLK);




DEBUG_OUT <= "0000" & found_double(0) & INP_low_long(0) & INP_low(0) & INP(0);

end architecture;



