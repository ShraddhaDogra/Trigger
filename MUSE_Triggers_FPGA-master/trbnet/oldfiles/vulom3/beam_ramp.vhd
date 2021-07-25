--------------------------------------------------------------------------------
-- Company:  GSI
-- Engineer: Davide Leoni
--
-- Create Date:    26/6/07
-- Design Name:    vulom3
-- Module Name:    beam_ramp - Behavioral
-- Project Name:   triggerbox
-- Target Device:  XC4VLX25-10SF363
-- Tool versions:  
-- Description: 	 Programmable delayer and shaper for beam signal
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity beam_ramp is
	port	(	clk_300MHz : in std_logic;
				clk_50MHz : in std_logic;
				input	: in std_logic;
				output_inhibit	: out std_logic;
				output_external : out std_logic;
				delay_value : in std_logic_vector(7 downto 0);
				width_value_inhibit	: in std_logic_vector(7 downto 0);
				width_value_external	: in std_logic_vector(7 downto 0)
				);
end beam_ramp;

architecture Behavioral of beam_ramp is

signal count_ck : std_logic_vector(23 downto 0);
signal clk_10Hz : std_logic;
signal input_r, input_q, output_s_inhibit, output_s_external : std_logic;
signal count_delay, count_width_inhibit, count_width_external : std_logic_vector(7 downto 0);
type state_type is (reset, del, wid);
signal state : state_type;



begin

	ck: process(clk_50MHz)
	begin
		if rising_edge(clk_50MHz) then			
			if count_ck = x"2625a0" then									--2,5e6
				count_ck <= x"000000";
				clk_10Hz <= not clk_10Hz;
			else
				count_ck <= count_ck + 1;
			end if;

			output_inhibit <= output_s_inhibit;
			output_external <= output_s_external;

		end if;
	end process;
	
	latch: process(clk_300MHz)
	begin
		if rising_edge(clk_300MHz) then			
			if input_r = '1' then
				input_q <= '0';
			elsif input = '1' then
				input_q <= '1';
			end if;
			
		end if;
	end process;

	fsm : process(clk_10Hz)
	begin
		if rising_edge(clk_10Hz) then
			case (state) is

				when reset =>
					input_r <= '0';
					count_delay <=delay_value;
					count_width_inhibit <= width_value_inhibit;
					count_width_external <= width_value_external + width_value_inhibit;					
					if input_q = '0' then
						state <= reset;
					else
						state <= del;
					end if;

--				when reset =>
--					input_r <= '0';
--					count_delay <=delay_value;
--					count_width_inhibit <= width_value_inhibit + 1;
--					count_width_external <= width_value_external + 1;					
--					if input_q = '0' then
--						state <= reset;
--					else
--						state <= del;
--					end if;
					
				when del =>
					if count_delay = x"00" then
						state <= wid;
					else 
						count_delay <= count_delay - 1;
						state <= del;
					end if;
						
				when wid =>
					input_r <= '1';
					if (count_width_inhibit = x"00" and count_width_external = x"00") then
						output_s_inhibit <= '0';
						output_s_external <= '0';
						state <= reset;
					elsif count_width_external = x"00" then
						output_s_inhibit <= '1';
						output_s_external <= '0';
						count_width_inhibit <= count_width_inhibit - 1;	
						state <= wid;
					elsif count_width_inhibit = x"00" then
						output_s_inhibit <= '0';
						output_s_external <= '1';
						count_width_external <= count_width_external - 1;
						state <= wid;
					else
						output_s_inhibit <= '1';
						output_s_external <= '1';
						count_width_inhibit <= count_width_inhibit - 1;
						count_width_external <= count_width_external - 1;
						state <= wid;
					end if;
						
				when others =>
					state <= reset;
			
			end case;
		end if;
	end process;



end Behavioral;







--entity beam_ramp is
--	port	(	clk_300MHz : in std_logic;
--				clk_50MHz : in std_logic;
--				input	: in std_logic;
--				output_inhibit	: out std_logic;
--				output_external : out std_logic;
--				delay_value : in std_logic_vector(7 downto 0);
--				width_value_inhibit	: in std_logic_vector(7 downto 0);
--				width_value_external	: in std_logic_vector(7 downto 0)
--				);
--end beam_ramp;
--
--architecture Behavioral of beam_ramp is
--
--signal count_ck : std_logic_vector(24 downto 0);
--signal clk_10Hz : std_logic;
--signal input_r, input_q, output_s_inhibit, output_s_external : std_logic;
--signal count_delay, count_width_inhibit, count_width_external : std_logic_vector(7 downto 0);
--type state_type is (reset, del, wid);
--signal state : state_type;
--
--
--
--begin
--
--	ck: process(clk_50MHz)
--	begin
--		if rising_edge(clk_50MHz) then			
--			count_ck <= count_ck + 1;
--			clk_10Hz <= count_ck(22);
--
--			output_inhibit <= output_s_inhibit;
--			output_external <= output_s_external;
--
--		end if;
--	end process;
--	
--	latch: process(clk_300MHz)
--	begin
--		if rising_edge(clk_300MHz) then			
--			if input_r = '1' then
--				input_q <= '0';
--			elsif input = '1' then
--				input_q <= '1';
--			end if;
--			
--		end if;
--	end process;
--
--	fsm : process(clk_10Hz)
--	begin
--		if rising_edge(clk_10Hz) then
--			case (state) is
--
--				when reset =>
--					input_r <= '0';
--					count_delay <=delay_value;
--					count_width_inhibit <= width_value_inhibit + 1;
--					count_width_external <= width_value_external + 1;					
--					if input_q = '0' then
--						state <= reset;
--					else
--						state <= del;
--					end if;
--					
--				when del =>
--					if count_delay = x"00" then
--						state <= wid;
--					else 
--						count_delay <= count_delay - 1;
--						state <= del;
--					end if;
--						
--				when wid =>
--					input_r <= '1';
--					if (count_width_inhibit = x"00" and count_width_external = x"00") then
--						output_s_inhibit <= '0';
--						output_s_external <= '0';
--						state <= reset;
--					elsif count_width_external = x"00" then
--						output_s_inhibit <= '1';
--						output_s_external <= '0';
--						count_width_inhibit <= count_width_inhibit - 1;	
--						state <= wid;
--					elsif count_width_inhibit = x"00" then
--						output_s_inhibit <= '0';
--						output_s_external <= '1';
--						count_width_external <= count_width_external - 1;
--						state <= wid;
--					else
--						output_s_inhibit <= '1';
--						output_s_external <= '1';
--						count_width_inhibit <= count_width_inhibit - 1;
--						count_width_external <= count_width_external - 1;
--						state <= wid;
--					end if;
--						
--				when others =>
--					state <= reset;
--			
--			end case;
--		end if;
--	end process;
--
--
--
--end Behavioral;