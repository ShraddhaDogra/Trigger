library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.trb_net_std.all;

entity trb_net_fifo_16bit_16bit_bram_dualport is
port(
	READ_CLOCK_IN    : in  std_logic;
	WRITE_CLOCK_IN   : in  std_logic;
	READ_ENABLE_IN   : in  std_logic;
	WRITE_ENABLE_IN  : in  std_logic;
	FIFO_GSR_IN      : in  std_logic;
	WRITE_DATA_IN    : in  std_logic_vector(15 downto 0);
	READ_DATA_OUT    : out std_logic_vector(15 downto 0);
	FULL_OUT         : out std_logic;
	EMPTY_OUT        : out std_logic;
	WCNT_OUT         : out std_logic_vector(9 downto 0);
	RCNT_OUT         : out std_logic_vector(9 downto 0)
);
end entity trb_net_fifo_16bit_16bit_bram_dualport;

architecture trb_net_fifo_16bit_16bit_bram_dualport_arch of trb_net_fifo_16bit_16bit_bram_dualport is

component lattice_ecp2m_fifo_16b_16b_dualport is
port(
	Data      : in  std_logic_vector(15 downto 0); 
	WrClock   : in  std_logic; 
	RdClock   : in  std_logic; 
	WrEn      : in  std_logic; 
	RdEn      : in  std_logic; 
	Reset     : in  std_logic; 
	RPReset   : in  std_logic; 
	Q         : out std_logic_vector(15 downto 0); 
	WCNT      : out std_logic_vector(9 downto 0); 
	RCNT      : out std_logic_vector(9 downto 0); 
	Empty     : out std_logic; 
	Full      : out std_logic
);
end component lattice_ecp2m_fifo_16b_16b_dualport;

begin

FIFO_DP_BRAM: lattice_ecp2m_fifo_16b_16b_dualport
port map (
	Data     => WRITE_DATA_IN,
	WrClock  => WRITE_CLOCK_IN,
	RdClock  => READ_CLOCK_IN,
	WrEn     => WRITE_ENABLE_IN,
	RdEn     => READ_ENABLE_IN,
	Reset    => FIFO_GSR_IN,
	RPReset  => '0',
	Q        => READ_DATA_OUT,
	WCNT     => WCNT_OUT,
	RCNT     => RCNT_OUT,
	Empty    => EMPTY_OUT,
	Full     => FULL_OUT
);

end architecture trb_net_fifo_16bit_16bit_bram_dualport_arch;

