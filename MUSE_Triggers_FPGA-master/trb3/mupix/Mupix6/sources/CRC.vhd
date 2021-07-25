-------------------------------------------------------------------------------
--Computation of cyclic redundancy check
--We use the CRC5 polynomial f(x) = 1 + x^2 + x^ 5 used by the USB2.0 protocol
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CRC is
	generic(
	  detect_enable_edge : boolean := false
	);
	port(
		clk     : in  std_logic;
		rst     : in  std_logic;
		enable  : in  std_logic;
		data_in : in  std_logic;
		crc_out : out std_logic_vector(4 downto 0));
end entity CRC;

architecture rtl of CRC is
	signal lfsr : std_logic_vector(4 downto 0) := (others => '1');
	signal edge_detect : std_logic_vector(1 downto 0) := (others => '0');
begin
	
	normal_gen : if detect_enable_edge = false generate
		CRC_proc : process(clk) is
		begin
			if rising_edge(clk) then
				if rst = '1' then
					lfsr <= (others => '1');
				else
					lfsr <= lfsr;
					if enable = '1' then
						lfsr(0) <= lfsr(4) xor data_in;
						lfsr(1) <= lfsr(0);
						lfsr(2) <= (lfsr(4) xor data_in) xor lfsr(1);
						lfsr(3) <= lfsr(2);
						lfsr(4) <= lfsr(3);
					end if;
				end if;
			end if;
		end process CRC_proc;
	end generate;
	
	detect_enable_edge_gen : if detect_enable_edge = true generate
		CRC_edge_proc : process(clk) is
		begin
			if rising_edge(clk) then
				if rst = '1' then
					lfsr <= (others => '1');
					edge_detect <= (others => '0');
				else
					edge_detect <= edge_detect(0) & enable;
					lfsr <= lfsr;
					if edge_detect = "01" then
						lfsr(0) <= lfsr(4) xor data_in;
						lfsr(1) <= lfsr(0);
						lfsr(2) <= (lfsr(4) xor data_in) xor lfsr(1);
						lfsr(3) <= lfsr(2);
						lfsr(4) <= lfsr(3);
					end if;
				end if;
			end if;
		end process CRC_edge_proc;
	end generate;
	
	crc_out <= lfsr;
	
end architecture rtl;