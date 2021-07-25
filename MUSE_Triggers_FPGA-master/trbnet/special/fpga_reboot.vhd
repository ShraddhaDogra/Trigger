library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fpga_reboot is
  port(
    CLK       : in std_logic;
    RESET     : in std_logic;
    DO_REBOOT : in std_logic;
    PROGRAMN  : out std_logic := '1'
    );
end entity;

architecture fpga_reboot_arch of fpga_reboot is


  signal delayed_restart_fpga : std_logic := '0';
  signal restart_fpga_counter : unsigned(11 downto 0);  

begin

PROC_REBOOT : process
  begin
    wait until rising_edge(CLK);
    if RESET = '1' then
      delayed_restart_fpga   <= '0';
      restart_fpga_counter   <= x"000";
    else
      delayed_restart_fpga     <= '0';
      if DO_REBOOT = '1' then
        restart_fpga_counter   <= x"001";
      elsif restart_fpga_counter /= x"000" then
        restart_fpga_counter   <= restart_fpga_counter + 1;
        if restart_fpga_counter >= x"F00" then
          delayed_restart_fpga <= '1';
        end if;
      end if;
    end if;
  end process;    

PROGRAMN                 <= not delayed_restart_fpga;    
    
end architecture;