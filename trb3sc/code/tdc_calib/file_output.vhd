        library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

entity file_output is
  generic (
           log_file:       string  := "res.log"
          );
  port(
       CLK              : in std_logic;
       x1               : in std_logic_vector(31 downto 0);
       x2               : in std_logic_vector(31 downto 0)
      );
end file_output;


architecture log_to_file of file_output is

      file l_file: TEXT open write_mode is log_file;

begin

write : process (CLK)
begin
   if rising_edge(CLK) then
print(l_file, str(x1)& " "& str(x2));
   end if;
end process;

end log_to_file;
