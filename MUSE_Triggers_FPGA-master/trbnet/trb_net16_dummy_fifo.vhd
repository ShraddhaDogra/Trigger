-- http://hades-wiki.gsi.de/cgi-bin/view/DaqSlowControl/TrbNetFifo

library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_signed.ALL;
USE ieee.std_logic_arith.ALL;

library work;
use work.trb_net_std.all;

entity trb_net16_dummy_fifo is
    port (
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      DATA_IN         : in  std_logic_vector(c_DATA_WIDTH - 1 downto 0);
      PACKET_NUM_IN   : in  std_logic_vector(1 downto 0);
      WRITE_ENABLE_IN : in  std_logic;
      DATA_OUT        : out std_logic_vector(c_DATA_WIDTH - 1 downto 0);
      PACKET_NUM_OUT  : out std_logic_vector(1 downto 0);
      READ_ENABLE_IN  : in  std_logic;
      FULL_OUT        : out std_logic;
      EMPTY_OUT       : out std_logic
      );
end entity;


architecture arch_trb_net16_dummy_fifo of trb_net16_dummy_fifo is

  component trb_net_dummy_fifo is
    generic (
      WIDTH : integer := c_DATA_WIDTH + 2);
    port (
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      DATA_IN         : in  std_logic_vector(WIDTH - 1 downto 0);  -- Input data
      WRITE_ENABLE_IN : in  std_logic;
      DATA_OUT        : out std_logic_vector(WIDTH - 1 downto 0);  -- Output data
      READ_ENABLE_IN  : in  std_logic;
      FULL_OUT        : out std_logic;    -- Full Flag
      EMPTY_OUT       : out std_logic
      );
  end component;

  signal din, dout : std_logic_vector(c_DATA_WIDTH + 2 -1 downto 0);

begin
  din(c_DATA_WIDTH - 1 downto 0) <= DATA_IN;
  din(c_DATA_WIDTH + 2 -1 downto c_DATA_WIDTH) <= PACKET_NUM_IN;
  DATA_OUT <= dout(c_DATA_WIDTH - 1 downto 0);
  PACKET_NUM_OUT <= dout(c_DATA_WIDTH + 2 - 1 downto c_DATA_WIDTH);

  fifo : trb_net_dummy_fifo
    port map(
      CLK    => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      DATA_IN         => din,
      WRITE_ENABLE_IN => WRITE_ENABLE_IN,
      DATA_OUT        => dout,
      READ_ENABLE_IN  => READ_ENABLE_IN,
      FULL_OUT        => FULL_OUT,
      EMPTY_OUT       => EMPTY_OUT
      );

end architecture;

