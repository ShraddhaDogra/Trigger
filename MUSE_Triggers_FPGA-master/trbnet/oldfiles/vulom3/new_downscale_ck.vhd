--------------------------------------------------------------------------------
-- Company:  GSI
-- Engineer: Davide Leoni
--
-- Create Date:    7/3/07
-- Design Name:    vulom3
-- Module Name:    new_downscale_ck - Behavioral
-- Project Name:   triggerbox
-- Target Device:  XC4VLX25-10SF363
-- Tool versions:  
-- Description:	 Provides clock downscale, plus calibration and inhibit signals
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity new_downscale_ck is port (
	downscale_value : in std_logic_vector(3 downto 0);
	clk : in std_logic;
   downscaled : out std_logic;
	output_disable : in std_logic;
        global_inhibit : in std_logic;
	scaler_reset : out std_logic;
	cal_inhibit : out std_logic;
	cal_trigger : out std_logic);
end new_downscale_ck;

architecture Behavioral of new_downscale_ck is
signal accu_1 : std_logic_vector(21 downto 0);
signal accu_3 : std_logic_vector(15 downto 0);
signal accu_4 : std_logic_vector(15 downto 0);
signal count, count_d, clk_10kHz : std_logic;
signal accu_2 : std_logic_vector(15 downto 0);
signal delay_1, delay_2 : std_logic;


begin

  process(clk)																--pulser	
  begin
    if rising_edge(clk) then
      accu_1 <= accu_1 + 1;
      case downscale_value is
        when "0000" => count <= accu_1(6);										
        when "0001" => count <= accu_1(7);
        when "0010" => count <= accu_1(8);
        when "0011" => count <= accu_1(9);
        when "0100" => count <= accu_1(10);
        when "0101" => count <= accu_1(11);
        when "0110" => count <= accu_1(12);
        when "0111" => count <= accu_1(13);
        when "1000" => count <= accu_1(14);
        when "1001" => count <= accu_1(15);
        when "1010" => count <= accu_1(16);
        when "1011" => count <= accu_1(17);
        when "1100" => count <= accu_1(18);
        when "1101" => count <= accu_1(19);
        when "1110" => count <= accu_1(20);
        when "1111" => count <= accu_1(21);
        when others => count <= 'X';			
      end case;
      count_d <= count;
      downscaled <= (not count_d) and count;				
    end if;
  end process;				
  process(clk)																--10 kHz clock generator
  begin
    if rising_edge(clk) then
      if accu_2 = x"3a97" then 							
        accu_2 <= x"0000";
        clk_10kHz <= not clk_10kHz;
      else
        accu_2 <= accu_2 + 1;
      end if;
    end if;
  end process;				
  process(clk_10kHz)														--calibration pulse	
  begin
    if rising_edge(clk_10kHz) then			
      if accu_3 = x"0000" then
        scaler_reset <= '1';
        accu_3 <= accu_3 + 1;
      elsif accu_3 = x"0001"	then						
        scaler_reset <= '0';
        accu_3        <= accu_3 + 1;
      elsif accu_3 = x"0002" then
        scaler_reset  <= '0';
        accu_3        <= accu_3 + 1;
      elsif accu_3 = x"270f" then       --10e3
        scaler_reset  <= '0';
        accu_3        <= x"0000";
      else accu_3     <= accu_3 + 1;
      end if;
    end if;
  end process;
  process(clk_10kHz)                    --calibration pulse     
  begin
    if rising_edge(clk_10kHz) then
      if accu_4 = x"0000" and global_inhibit = '0' then
        cal_inhibit   <= not output_disable;
        cal_trigger   <= '0';
        accu_4        <= accu_4 + 1;
      elsif accu_4 = x"0000" and global_inhibit = '1' then
        cal_inhibit <= not output_disable;
        cal_trigger <= '0';
        accu_4      <= accu_4;
      elsif accu_4 = x"0001" then
        cal_inhibit <= not output_disable;
        cal_trigger <= not output_disable;
        accu_4      <= accu_4 + 1;
      elsif accu_4 = x"0002" then
        cal_inhibit <= '0';
        cal_trigger <= '0';
        accu_4      <= accu_4 + 1;
      elsif accu_4 = x"270f" then       --10e3
        cal_inhibit <= '0';
        cal_trigger <= '0';
        accu_4      <= x"0000";
      else accu_4   <= accu_4 + 1;
      end if;
    end if;
  end process;

end Behavioral;
