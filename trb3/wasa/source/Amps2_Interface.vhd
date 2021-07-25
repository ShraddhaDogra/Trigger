library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Amps2_Interface is
  generic(
    clk_frequency : integer := 133_000_000;
    i2c_frequency : integer := 100_000
  );
  port(
    --System clock.
    clk         : in    std_logic;
    reset       : in    std_logic :='0';
    temperature : out   std_logic_vector(11 downto 0);
    ID_OUT      : out   std_logic_vector(31 downto 0);
    --I2C signals.
    sda         : inout std_logic;
    scl         : inout std_logic
  );
end Amps2_Interface;

architecture Behavioral of Amps2_Interface is

constant addr_temp_sensor : std_logic_vector := "1001000";  
constant addr_UID         : std_logic_vector := "1010000";  
  --Signals for data exchange with the core I2C controller.

--I2C commands .
constant temp_register_pointer	      : std_logic_vector := "00000000";
constant UID_pointer			      : std_logic_vector := "11111100";

  --Signals for data exchange with the core I2C controller.
  signal address: std_logic_vector(6 downto 0);
  signal data_to_write, last_read_data : std_logic_vector(7 downto 0);
  signal reading, transaction_active, controller_in_use : std_logic;
signal temp_data_MSB: std_logic_vector(7 downto 0);
signal temp_data_LSB : std_logic_vector(7 downto 0);
  --Rising edge detect for the "controller in use" signal.
  --A rising edge of this signal indicates that the I2C controller has accepted our data.
  signal controller_was_in_use    : std_logic;
  signal controller_accepted_data, new_data_available : std_logic;

  --I2C read/write constants.
  constant write : std_logic := '0';
  constant read  : std_logic := '1';

  --Core state machine logic.
  type state_type is (STARTUP, SEND_POWER_COMMAND, TURN_POWER_ON,
                      WAIT_BEFORE_READING, SEND_READ_COMMAND, START_READ, FINISH_READ_AND_CONTINUE, FINISH_READ_AND_RESTART,
                     UID_send_adress,UID_WAIT_BEFORE_READING,UID_START_READ,UID_FINISH_READ_AND_CONTINUE,UID_FINISH_READ_AND_RESTART,UID_FINISH
                     );
  signal state : state_type := STARTUP;

  type byte_buffer is array(natural range <>) of std_logic_vector(7 downto 0);
  signal read_buffer : byte_buffer(1 downto 0);

  signal current_byte_number      : integer range 2 downto 0   := 0;
           
 --Create a simple read buffer for each of the sequential bytes.
  type UID_byte_buffer is array(natural range <>) of std_logic_vector(7 downto 0);
  signal UID_read_buffer : byte_buffer(4 downto 0);

  signal UID_current_byte_number      : integer range 4 downto 0   := 0;                 
                                
begin

  I2C_CONTROLLER: entity i2c_master 
  generic map(
    input_clk => clk_frequency, 
    bus_clk   => i2c_frequency
  )  
  port map(
        clk       => clk,
        reset_n   => not reset,
        ena       => transaction_active,
        addr      => address,
        rw        => reading,
        data_wr   => data_to_write,
        busy      => controller_in_use,
        data_rd   => last_read_data,
        ack_error => open,
        sda       => sda,
        scl       => scl
    );

  controller_was_in_use    <= controller_in_use when rising_edge(clk);
  controller_accepted_data <= controller_in_use and not controller_was_in_use;

  process(clk)
  begin
    if reset = '1' then
      state <= state_type'left;

    elsif rising_edge(clk) then
      data_to_write      <= (others => '0');
      case state is
                                
        when STARTUP =>
          if controller_in_use = '0' then
            state <= WAIT_BEFORE_READING;
          end if;

        when WAIT_BEFORE_READING =>

          transaction_active  <= '0';
          current_byte_number <= 0;
          if controller_in_use = '0' then
            state <= START_READ;
          end if;

        when START_READ =>
          transaction_active      <= '1';
          reading                 <= read;
          address                 <= addr_temp_sensor;
          if controller_accepted_data = '1' then
            if current_byte_number = read_buffer'high then
              state <= FINISH_READ_AND_RESTART;
            else
              state <= FINISH_READ_AND_CONTINUE;
            end if;
          end if;
                                
        when FINISH_READ_AND_CONTINUE =>
          if controller_in_use = '0' then
            read_buffer(current_byte_number) <= last_read_data;
            current_byte_number <= current_byte_number + 1;
            state <= START_READ;
          end if;
                                
        when FINISH_READ_AND_RESTART =>
          transaction_active <= '0';
          if controller_in_use = '0' then
            read_buffer(current_byte_number) <= last_read_data;
            state <= UID_send_adress;
          end if;
 -----------------------------------------------------------------------------------------         
-----------------------------------------------------------------------------------------
    when UID_send_adress =>
          transaction_active <= '1';
          reading            <= write;
          data_to_write      <= UID_pointer;
          address            <= addr_UID;
          --UID_current_byte_number <= 0;
          if controller_accepted_data = '1' then
            state <= UID_START_READ;
          end if;

    when UID_WAIT_BEFORE_READING =>
         transaction_active  <= '0';
         UID_current_byte_number <= 0;
         if controller_in_use = '0' then
          state <= UID_START_READ;
         end if;      

        when UID_START_READ =>
          transaction_active      <= '1';
          reading                 <= read;
          if controller_accepted_data = '1' then
            if UID_current_byte_number = UID_read_buffer'high then
              state <= UID_FINISH_READ_AND_RESTART;
            else
              state <= UID_FINISH_READ_AND_CONTINUE;
            end if;
          end if;

        when UID_FINISH_READ_AND_CONTINUE =>

          if controller_in_use = '0' then
            UID_read_buffer(UID_current_byte_number) <= last_read_data;
            UID_current_byte_number <= UID_current_byte_number + 1;
            state <= UID_START_READ;
          end if;
                                
        when UID_FINISH_READ_AND_RESTART =>
          transaction_active <= '0';
          if controller_in_use = '0' then
            UID_read_buffer(UID_current_byte_number) <= last_read_data;
            state <= UID_FINISH;
          end if;
                                
        when UID_FINISH =>
        end case; 
      end if;
    end process;
temp_data_LSB <= read_buffer(1);
temp_data_MSB <= read_buffer(0);
temperature(11 downto 4) <=temp_data_MSB;
temperature(3 downto 0)  <=temp_data_LSB(7 downto 4);
                             
ID_OUT(31 downto 24) <=UID_read_buffer(0);
ID_OUT(23 downto 16) <=UID_read_buffer(1);                                
ID_OUT(15 downto 8) <=UID_read_buffer(2);                                
ID_OUT(7 downto 0) <=UID_read_buffer(3);      
                                
end Behavioral;
