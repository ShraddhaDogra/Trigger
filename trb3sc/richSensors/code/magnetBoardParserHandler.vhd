library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity magnetBoardParserHandler is
    port(
        INPUT : in std_logic_vector(7 downto 0);
        CLK   : in std_logic;
        READY : in std_logic;
        
        SERIAL_NUMBER : out std_logic_vector(6 downto 0);
        -- S for sensor (4 sensons on each board; bit-coded)
        -- A for axis (Temperature, X, Y, Z; bit-coded)
        VALUE_S00_A00 : out std_logic_vector(30 downto 0);
        VALUE_S00_A01 : out std_logic_vector(30 downto 0);
        VALUE_S00_A10 : out std_logic_vector(30 downto 0);
        VALUE_S00_A11 : out std_logic_vector(30 downto 0);
        VALUE_S01_A00 : out std_logic_vector(30 downto 0);
        VALUE_S01_A01 : out std_logic_vector(30 downto 0);
        VALUE_S01_A10 : out std_logic_vector(30 downto 0);
        VALUE_S01_A11 : out std_logic_vector(30 downto 0);
        VALUE_S10_A00 : out std_logic_vector(30 downto 0);
        VALUE_S10_A01 : out std_logic_vector(30 downto 0);
        VALUE_S10_A10 : out std_logic_vector(30 downto 0);
        VALUE_S10_A11 : out std_logic_vector(30 downto 0);    
        VALUE_S11_A00 : out std_logic_vector(30 downto 0);
        VALUE_S11_A01 : out std_logic_vector(30 downto 0);
        VALUE_S11_A10 : out std_logic_vector(30 downto 0);
        VALUE_S11_A11 : out std_logic_vector(30 downto 0);
        ERROR_NO_DATA : out std_logic
    );
end entity;

architecture behavioral of magnetBoardParserHandler is
    -- signals for THE_MAGBOARD_PARSER
    signal serialNumber : std_logic_vector(6 downto 0) := "0000000";
    signal sensorNumber : std_logic_vector(1 downto 0) := "00";
    signal axis         : std_logic_vector(1 downto 0) := "00";
    signal value        : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    -- signals for output result from THE_MAGBOARD_PARSER
    -- sensor0
    signal value_00_00 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal value_00_01 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal value_00_10 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal value_00_11 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    -- sensor1
    signal value_01_00 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal value_01_01 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal value_01_10 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal value_01_11 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    -- sensor2
    signal value_10_00 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal value_10_01 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal value_10_10 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal value_10_11 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    -- sensor3
    signal value_11_00 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal value_11_01 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal value_11_10 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal value_11_11 : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";

    -- signals for PROC_CHECK_ERROR
    signal error       : std_logic := '0';
    signal counter     : unsigned(28 downto 0);

begin

-- do parsing in external file
THE_MAGBOARD_PARSER : entity work.magnetBoardParser
  port map(
    --in
    INPUT           => INPUT,
    CLK             => CLK,
    READY           => READY,
    --out
    SERIAL_NUMBER   => serialNumber,
    SENSOR_NUMBER   => sensorNumber,
    AXIS_NUMBER     => axis,
    VALUE           => value
  );
  
-- check if there is data to parse
PROC_CHECK_ERROR : process begin
  wait until rising_edge(CLK);
  if READY = '0' then
    counter <= counter + 1;
  else 
    error <= '0';
    counter <= (others => '0');
  end if;
  if counter = 200000000 then
    error   <= '1';
    counter <= (others => '0');
  end if;
end process;

--sort THE_MAGBOARD_PARSER values to signals, so they can be used in output
--sensor0
value_00_00 <= value when sensorNumber = "00" and axis = "00";
value_00_01 <= value when sensorNumber = "00" and axis = "01";
value_00_10 <= value when sensorNumber = "00" and axis = "10";
value_00_11 <= value when sensorNumber = "00" and axis = "11";
--sensor1
value_01_00 <= value when sensorNumber = "01" and axis = "00";
value_01_01 <= value when sensorNumber = "01" and axis = "01";
value_01_10 <= value when sensorNumber = "01" and axis = "10";
value_01_11 <= value when sensorNumber = "01" and axis = "11";
--sensor2
value_10_00 <= value when sensorNumber = "10" and axis = "00";
value_10_01 <= value when sensorNumber = "10" and axis = "01";
value_10_10 <= value when sensorNumber = "10" and axis = "10";
value_10_11 <= value when sensorNumber = "10" and axis = "11";
--sensor3
value_11_00 <= value when sensorNumber = "11" and axis = "00";
value_11_01 <= value when sensorNumber = "11" and axis = "01";
value_11_10 <= value when sensorNumber = "11" and axis = "10";
value_11_11 <= value when sensorNumber = "11" and axis = "11";


-- write signals to output pins.
SERIAL_NUMBER <= serialNumber;
VALUE_S00_A00 <= std_logic_vector(value_00_00);
VALUE_S00_A01 <= std_logic_vector(value_00_01);
VALUE_S00_A10 <= std_logic_vector(value_00_10);
VALUE_S00_A11 <= std_logic_vector(value_00_11);
VALUE_S01_A00 <= std_logic_vector(value_01_00);
VALUE_S01_A01 <= std_logic_vector(value_01_01);
VALUE_S01_A10 <= std_logic_vector(value_01_10);
VALUE_S01_A11 <= std_logic_vector(value_01_11);
VALUE_S10_A00 <= std_logic_vector(value_10_00);
VALUE_S10_A01 <= std_logic_vector(value_10_01);
VALUE_S10_A10 <= std_logic_vector(value_10_10);
VALUE_S10_A11 <= std_logic_vector(value_10_11);
VALUE_S11_A00 <= std_logic_vector(value_11_00);
VALUE_S11_A01 <= std_logic_vector(value_11_01);
VALUE_S11_A10 <= std_logic_vector(value_11_10);
VALUE_S11_A11 <= std_logic_vector(value_11_11);
ERROR_NO_DATA <= error;

end architecture behavioral;
