----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.01.2017 14:31:03
-- Design Name: 
-- Module Name: sim_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.trb_net_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sim_tb is
end sim_tb;

architecture Behavioral of sim_tb is
signal CLK ,Flag_Lim, Flag_LUT: std_logic := '0';
signal DIN_i, DOUT_i : READOUT_TX;
signal DIN_out_end: std_logic_vector(31 downto 0) := (others => '0');
signal Fine, Delta, min_Cal : std_logic_vector(9 downto 0);
signal DIN_out_Lim, DIN_out_LUT : std_logic_vector(31 downto 0);
signal cal_cntread_compare_old : unsigned(19 downto 0);
signal min_curr_dbg, max_curr_dbg, min_next_dbg, max_next_dbg : std_logic_vector(9 downto 0);
signal read_next_dbg,write_next_dbg,Default_val_dbg,write_curr_dbg : std_logic;
signal FPGA_dbg : std_logic_vector(3 downto 0);
signal wrt_cal_cnt_dbg,write_dflt_cnt_dbg : std_logic;
signal cal_cnt : unsigned(19 downto 0);
--signal cal_cng_dbg, Dflt_cnt_dbg : std_logic;

constant CLK_PERIOD : time := 20 ns;

signal BUS_RX : CTRLBUS_RX;

begin
--Input : entity work.input_env
--    port map(
--        CLK => CLK,
--        DOUT => DIN_i
--    ); 

   Calibration : entity work.Calibration
    port map(
        CLK  => CLK,
        DIN  => DIN_i,
        DOUT => DOUT_i,
        BUS_RX  => BUS_RX,
        BUS_TX  => open
        --Temp => temp,
--         Fine => Fine,
--         Delta => Delta,
--         Min_Cal => min_Cal,
--         Flag_Lim => Flag_Lim,
--         Flag_LUT => Flag_LUT,
--         DIN_out_Lim => DIN_out_Lim,
--         DIN_out_LUT => DIN_out_LUT,
--         cal_cnt_dbug => cal_cnt,
--         min_next_dbg => min_next_dbg,
--         max_next_dbg => max_next_dbg,
--         min_curr_dbg => min_curr_dbg,
--         max_curr_dbg => max_curr_dbg,
--         --cal_cng_dbg => cal_cng_dbg,
--         read_next_dbg => read_next_dbg,
--         write_next_dbg => write_next_dbg,
--         FPGA_dbg => FPGA_dbg,
--         DIN_out_end => DIN_out_end,
--         --Dflt_cnt_dbg => Dflt_cnt_dbg,
--         Default_val_dbg => Default_val_dbg,
--         write_curr_dbg => write_curr_dbg,
--         wrt_cal_cnt_dbg => wrt_cal_cnt_dbg,
--         write_dflt_cnt_dbg => write_dflt_cnt_dbg
    ); 
    
    write : entity work.file_output
       port map(
            CLK => CLK,
            x1 => DIN_out_end,
            x2 => DOUT_i.data
       ); 
    

  CLK_PROC : process is
  begin
     CLK <= '1';
     wait for CLK_PERIOD / 2;
     CLK <= '0';
     wait for CLK_PERIOD / 2;
  end process;
  
  
  proc_Cal : process is
    begin
      wait for 5 ns;
      DIN_i.statusbits <= "00000000000000000000000000000001";
      DIN_i.data <= "00000000000000000000000000000001";
      DIN_i.data_write    <= '1';
      DIN_i.data_finished <= '0';
      DIN_i.busy_release  <= '1';
      wait for 20 ns;
      DIN_i.data <= "10000000000000100001000000000000"; --33
      --wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000010";
      wait for 20 ns;
      DIN_i.data <= "10000000000000100111000000000001"; --39
      --wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000001";
      wait for 20 ns;
      DIN_i.data <= "10000000000001000010000000000010"; --66
      --wait for 20 ns;
      --DIN_i <= "00000000000000000000000000000000";
      --wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000010";
      wait for 20 ns;
      DIN_i.data <= "10000001100000000011000000000011"; --3
      wait for 20 ns;

      --DIN_i.data <= "00000000000000000000000000000001";
      --wait for 20 ns;
      DIN_i.data <= "10000000001000001100000000000001"; --70
      wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000010";
      --wait for 20 ns;
      DIN_i.data <= "10000001100000000100000000000100";--4
      wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000001";
      --wait for 20 ns;
      --DIN_i.data <= "10000000000111000000000000000000";
      --wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000001";
      --wait for 20 ns;
      DIN_i.data <= "10000001100000000001000000000001";--1
      wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000001";
      --wait for 20 ns;
      DIN_i.data <= "10000001100000000010000000000010";--2
      wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000001";
      --wait for 20 ns;
      DIN_i.data <= "10000001101000001010000000000011";--3
      wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000001";
      --wait for 20 ns;
      DIN_i.data <= "10000001100000001010000000000100";--4
      wait for 20 ns;
      DIN_i.data <= "10000001100000001110000000000101";--5
      wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000001";
      --wait for 20 ns;
      DIN_i.data <= "10000000000000000110000000000110";--6
      wait for 20 ns;
      DIN_i.data <= "10000000000000000111000000000111";--7
      wait for 20 ns;
      DIN_i.data <= "10000000000000001000000000000111";--8
      wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000010";
      --wait for 20 ns;
      DIN_i.data <= "10000001100000001001000000000111";--9
      wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000001";
      --wait for 20 ns;
      DIN_i.data <= "10000000000000001010000000000111";--10
      wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000010";
      --wait for 20 ns;
      DIN_i.data <= "10000001100000001011000000000111";--11
      wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000001";
      --wait for 20 ns;
      DIN_i.data <= "10000000000000001100000000000111";--12
      wait for 20 ns;
      --DIN_i.data <= "00000000000000000000000000000010";
      --wait for 20 ns;
      DIN_i.data <= "10000001100000001101000000000111";--13
      wait for 20 ns;
    end process;


end Behavioral;