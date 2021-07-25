library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.math_real.all;

library work;

entity error_check is
port(
	RXCLK_IN             : in  std_logic;
	RESET_IN             : in  std_logic;

	DATA_TX_IN             : in  std_logic_vector(15 downto 0);
	DATA_TX_DATAREADY_IN   : in  std_logic;
	DATA_TX_READ_IN        : in  std_logic;
	DATA_RX_IN             : in  std_logic_vector(15 downto 0);
	DATA_RX_VALID_IN       : in  std_logic

  );
end entity;

architecture arch of error_check is

component fifo_18x2k_oreg is
    port (
        Data: in  std_logic_vector(17 downto 0);
        Clock: in  std_logic;
        WrEn: in  std_logic;
        RdEn: in  std_logic;
        Reset: in  std_logic;
        AmFullThresh: in  std_logic_vector(10 downto 0);
        Q: out  std_logic_vector(17 downto 0);
        WCNT: out  std_logic_vector(11 downto 0);
        Empty: out  std_logic;
        Full: out  std_logic;
        AlmostFull: out  std_logic);
end component;

signal fifo_wr_en    : std_logic;
signal fifo_q        : std_logic_vector(15 downto 0);
signal data_q        : std_logic_vector(15 downto 0);
signal data_qq       : std_logic_vector(15 downto 0);
signal check_q       : std_logic;
signal check_qq      : std_logic;
signal dummy         : std_logic_vector(1 downto 0);

begin

SYNC_PROC : process
begin
	wait until rising_edge(RXCLK_IN);
	data_q  <= data_qq;
	data_qq <= DATA_RX_IN;
	check_q <= check_qq;
	check_qq <= DATA_RX_VALID_IN;

end process;


fifo_wr_en <= '1' when DATA_TX_DATAREADY_IN = '1' and DATA_TX_READ_IN = '1' else '0';
fifo : fifo_18x2k_oreg
    port map(
        Data(15 downto 0)         => DATA_TX_IN,
	      data(17 downto 16)        => "00",
        Clock        => RXCLK_IN,
        WrEn         => fifo_wr_en,
        RdEn         => DATA_RX_VALID_IN,
        Reset        => RESET_IN,
        AmFullThresh => (others => '1'),
        Q(15 downto 0)            => fifo_q,
      	Q(17 downto 16)           => dummy(1 downto 0),
        WCNT         => open,
        Empty        => open,
        Full         => open,
        AlmostFull   => open
);

CHECK_PROC : process
begin
	wait until rising_edge(RXCLK_IN);

  if check_q = '1' then
    assert
      (fifo_q(15 downto 5) = data_q(15 downto 5)) and
      (fifo_q(3 downto 0) = data_q(3 downto 0))
    report "data invalid" severity error;
  end if;
end process;


end architecture;