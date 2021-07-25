library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity magnetBoardParser is
    port(
        INPUT : in std_logic_vector(7 downto 0);
        CLK : in std_logic;
        READY : in std_logic;
        
        SERIAL_NUMBER : out std_logic_vector(6 downto 0);
        SENSOR_NUMBER : out std_logic_vector(1 downto 0);
        AXIS_NUMBER :  out std_logic_vector(1 downto 0); -- coding: 0 = T, 1 = X, 2 = Y, 3 = Z
        VALUE : out unsigned(30 downto 0)
    );
end entity;

architecture behavioral of magnetBoardParser is
    type state_type is (idle, readInitSerialNumber, readSerialNumber, readSensorNumber, readAxis, readValue);
    signal currentState : state_type := idle;
    signal serialNumber : std_logic_vector(6 downto 0) := "0000000";
    signal serialNumber_tmp : std_logic_vector(13 downto 0) := "00000000000000";
    signal sensorNumber : std_logic_vector(1 downto 0) := "00";
    signal axis : std_logic_vector(1 downto 0) := "00"; -- 0 = T, 1 = X, 2 = Y, 3 = Z
    signal sign : std_logic := '0';
    signal valueIntern : unsigned(30 downto 0) := b"000_0000_0000_0000_0000_0000_0000_0000";
    signal valueIntern_tmp: unsigned(61 downto 0) := b"00_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000";
    signal output_ID : std_logic_vector(31 downto 0) := x"00000000";
    signal output_value : std_logic_vector(31 downto 0) := x"00000000";
begin

-- process incoming string. It has the form M_03_2_X 123.456\r
PROC_PARSER : process begin
  wait until rising_edge(CLK);
  serialNumber 	<= serialNumber_tmp(6 downto 0);  -- need temp value, because of size for multiplication
  valueIntern	<= valueIntern_tmp(30 downto 0);  -- need temp value, because of size for multiplication
  
  if READY = '1' then -- only read when READY == 1
    case currentState is 
        when idle =>
            -- set all values back to 0
            serialNumber <= (others=>'0');
            sensorNumber <= (others=>'0');
            axis  <= (others=>'0');
            valueIntern <= (others=>'0');
            sign  <= '0';
            serialNumber_tmp <= (others=>'0');
            valueIntern_tmp <= (others=>'0');
            if INPUT = x"4D" then
                -- Found char 'M'. Start parsing row and go to next state
                currentState <= readInitSerialNumber;
            end if;
        when readInitSerialNumber =>    
            if INPUT = x"5F" then
                -- Found char '_'.
                currentState <= readSerialNumber;
            else 
		currentState <= idle;
            end if;
        when readSerialNumber =>
            if INPUT = x"5F" then
                -- Found char '_'. Serial number is complete
                currentState <= readSensorNumber;
            elsif INPUT >= x"30" and INPUT <= x"39"  then
                -- Found figure (0-9). This is part of the serial number.
                serialNumber_tmp <= std_logic_vector(unsigned(serialNumber) * 10 + unsigned(INPUT(3 downto 0)));
            else
                -- all other chars are invalid. go back to idle
                currentState <= idle;
            end if;
         when readSensorNumber =>
            if INPUT = x"5F" then
                -- Found char "_". Sensor number is complete.
                currentState <= readAxis;
            elsif INPUT >= x"30" and INPUT <= x"39"  then
                -- Found figure (0-9). This is part of the serial number.
                sensorNumber <= INPUT(1 downto 0);
            else
                -- all other chars are invalid. go back to idle
                currentState <= idle;
            end if;
         when readAxis =>
            if INPUT = x"20" then
                -- Found char " ". Axis is complete.
                currentState <= readValue;
            elsif INPUT = x"54" then
                -- Found char "T".
                axis <= "00";
            elsif INPUT = x"58" then
                -- Found char "X".
                axis <= "01";
            elsif INPUT = x"59" then
                -- Found char "Y".
                axis <= "10";
            elsif INPUT = x"5A" then
                -- Found char "Z".
                axis <= "11";
            else
                -- all other chars are invalid. go back to idle
                currentState <= idle;
            end if;
         when readValue =>
            if INPUT = x"0D" or INPUT = x"0A" then
                -- Found char "\r" or "\n". Value and complete line are complete.
                currentState <= idle; -- back to idle
                -- build complete value from sensor number, axis and value
                output_value(31 downto 30) <= sensorNumber;
                output_value(29 downto 28) <= axis;
                output_value(27) <= sign;
                output_value(26 downto 0) <= std_logic_vector(valueIntern(26 downto 0));
                output_ID(26 downto 20) <= serialNumber;
                output_ID(9 downto 8) <= sensorNumber;
                output_ID(1 downto 0) <= axis;
            elsif INPUT >= x"30" and INPUT <= x"39"  then
                -- Found figure (0-9). This is part of the serial number.
                valueIntern_tmp <= valueIntern * 10 + unsigned(INPUT(3 downto 0));
            elsif INPUT = x"2E" then
                -- Found char "." ignore this char.
            elsif INPUT = x"2D" then
                -- Found char "-". save sign to variable
                sign <= '1';
            else
                -- all other chars are invalid. go back to idle.
                currentState <= idle;
            end if;
    end case;
  end if;
end process;

SERIAL_NUMBER <= output_ID(26 downto 20);
SENSOR_NUMBER <= output_ID(9 downto 8);
AXIS_NUMBER <= output_ID(1 downto 0);
VALUE(27 downto 0) <= output_value(27 downto 0);

end architecture behavioral;
