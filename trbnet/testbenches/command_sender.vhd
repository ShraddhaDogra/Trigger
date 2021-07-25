LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;


entity command_sender is
  port(
    CLK        : in std_logic;
    DATA       : out std_logic_vector(15 downto 0);
    DATAREADY  : out std_logic;
    PACKET_NUM : out std_logic_vector(2 downto 0)
    );
end entity;
  

architecture x of command_sender is


type cmd_arr is array (0 to 14) of std_logic_vector(15 downto 0);
type num_arr is array (0 to 4) of std_logic_vector(2 downto 0);

constant commands : cmd_arr := (x"0031",x"FFFF",x"FFFF",x"FFFF",x"0008",
                               x"0030",x"0000",x"a0c0",x"affe",x"dead",
                               x"0033",x"0000",x"0000",x"0000",x"0008");
                               
                               
constant packetnums : num_arr := ("100","000","001","010","011"); 
begin

process begin
  dataready  <= '0';
  data       <= (others => '0');
  packet_num <= "100";

  wait for 1 us;
  wait until rising_edge(CLK); wait for 1 ns;


  send_cmd : for i in 0 to commands'length-1 loop
    dataready  <= '1';
    data       <= commands(i);
    packet_num <= packetnums(i mod 5);
    wait until rising_edge(CLK); wait for 1 ns;
    dataready  <= '0';
  end loop;
  
  wait;
end process;


end architecture;
