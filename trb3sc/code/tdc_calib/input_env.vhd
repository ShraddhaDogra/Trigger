library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity input_env is
port (
    CLK : in std_logic;
   -- WEN : in std_logic;
   -- REN : in std_logic;
   -- WADD : in std_logic_vector(8 downto 0);
   -- RADD : in std_logic_vector(8 downto 0);
   -- DIN : in std_logic_vector(639 downto 0);
    DOUT : out std_logic_vector(31 downto 0)
);
end input_env;

architecture behavioral of input_env is
    type input_type is array (0 to 5) of std_logic_vector (31 downto 0);
    
    impure function init_input (data_file_name : in string) return
        input_type is
            file data_file : text is in data_file_name;
            variable data_line : line;
            variable bit_word : bit_vector(31 downto 0);
            variable input_i : input_type;
    begin
        for nline in input_type'range loop
            readline(data_file, data_line);
            read(data_line, bit_word);
            input_i(nline) := to_stdlogicvector(bit_word);
        end loop;
        return input_i;
    end function;

    signal input : input_type := init_input("C:\Users\adria\Desktop\TRB\bits.dat");
   
begin
    process (CLK)
    variable position : integer range 0 to 200 := 0;
    begin
      if (CLK'event and CLK = '1') then
        --if WEN = '1' then
        --   input(to_integer(unsigned(WADD))) <= DIN;
        --end if;
        --if REN = '1' then
        if position > 5 then
            DOUT <= "00000000000000000000000000000000";
        else 
            DOUT <= input(position);
        end if;
            position := position + 1;
        --end if;
      end if;
    end process;
end behavioral;