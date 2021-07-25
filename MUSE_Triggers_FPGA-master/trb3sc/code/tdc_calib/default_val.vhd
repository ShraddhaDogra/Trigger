library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dflt_val is
    Port (       
        CLK        : in  std_logic;
        read       : in  std_logic;
        FPGA_read  : in  std_logic_vector(3 downto 0);
        chnl_read  : in  std_logic_vector(6 downto 0);
        dflt_out   : out std_logic
    );
end dflt_val;

architecture Behavioral of dflt_val is

  type bit_2D is array (15 downto 0, 63 downto 0) of std_logic; --(channel)
  signal dflt_i   : bit_2D := (others => (others => '1'));
  signal start    : std_logic := '1';
  
begin
 dflt_cnt : process (CLK)
 begin
 if rising_edge(CLK) then
      if (read = '1') then --read
	  dflt_out  <= dflt_i(to_integer(unsigned(FPGA_read)),to_integer(unsigned(chnl_read)));
	  dflt_i(to_integer(unsigned(FPGA_read)),to_integer(unsigned(chnl_read))) <= '0';
      else
	  dflt_out  <= '0';
      end if;
 end if;
 end process;

end Behavioral;
