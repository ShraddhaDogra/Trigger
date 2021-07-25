library ieee;

use ieee.std_logic_1164.all;
USE ieee.std_logic_signed.ALL;
USE IEEE.numeric_std.ALL;
use work.trb_net_std.all;

entity trb_net16_fifo is
    generic (
      USE_VENDOR_CORES : integer range 0 to 1 := c_NO;
      use_data_count   : integer range 0 to 1 := c_NO;
      DEPTH      : integer := 6       -- Depth of the FIFO, 2^(n+1) 64Bit packets
      );
    port (
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      DATA_IN         : in  std_logic_vector(15 downto 0);  -- Input data
      PACKET_NUM_IN   : in  std_logic_vector(1 downto 0);  -- Input data
      WRITE_ENABLE_IN : in  std_logic;
      DATA_OUT        : out std_logic_vector(15 downto 0);  -- Output data
      PACKET_NUM_OUT  : out std_logic_vector(1 downto 0);  -- Input data
      DATA_COUNT_OUT  : out std_logic_vector(10 downto 0);
      READ_ENABLE_IN  : in  std_logic;
      FULL_OUT        : out std_logic;    -- Full Flag
      EMPTY_OUT       : out std_logic
      );
end entity;

architecture arch_trb_net16_fifo of trb_net16_fifo is
component lattice_ecp3_fifo_18x1k is
    port (
        Data: in  std_logic_vector(17 downto 0);
        Clock: in  std_logic;
        WrEn: in  std_logic;
        RdEn: in  std_logic;
        Reset: in  std_logic;
        Q: out  std_logic_vector(17 downto 0);
        Empty: out  std_logic;
        Full: out  std_logic);
end component;


--   component lattice_ecp2m_fifo_18x16 is
--     port (
--         Data: in  std_logic_vector(17 downto 0);
--         WrClock: in  std_logic;
--         RdClock: in  std_logic;
--         WrEn: in  std_logic;
--         RdEn: in  std_logic;
--         Reset: in  std_logic;
--         RPReset: in  std_logic;
--         Q: out  std_logic_vector(17 downto 0);
--         Empty: out  std_logic;
--         Full: out  std_logic);
--   end component;
--
--   component lattice_ecp2m_fifo_18x32 is
--     port (
--         Data: in  std_logic_vector(17 downto 0);
--         WrClock: in  std_logic;
--         RdClock: in  std_logic;
--         WrEn: in  std_logic;
--         RdEn: in  std_logic;
--         Reset: in  std_logic;
--         RPReset: in  std_logic;
--         Q: out  std_logic_vector(17 downto 0);
--         Empty: out  std_logic;
--         Full: out  std_logic);
--   end component;
--
--   component lattice_ecp2m_fifo_18x64 is
--     port (
--         Data: in  std_logic_vector(17 downto 0);
--         WrClock: in  std_logic;
--         RdClock: in  std_logic;
--         WrEn: in  std_logic;
--         RdEn: in  std_logic;
--         Reset: in  std_logic;
--         RPReset: in  std_logic;
--         Q: out  std_logic_vector(17 downto 0);
--         Empty: out  std_logic;
--         Full: out  std_logic);
--   end component;


  signal din, dout : std_logic_vector(c_DATA_WIDTH +1 downto 0);

begin
  din(c_DATA_WIDTH - 1 downto 0) <= DATA_IN;
  din(c_DATA_WIDTH + 1 downto c_DATA_WIDTH) <= PACKET_NUM_IN;
  DATA_OUT <= dout(c_DATA_WIDTH - 1 downto 0);
  PACKET_NUM_OUT <= dout(c_DATA_WIDTH + 1 downto c_DATA_WIDTH);
  DATA_COUNT_OUT <= (others => '0');

--  gen_FIFO6 : if DEPTH = 6  generate
    fifo:lattice_ecp3_fifo_18x1k
      port map (
        Data     => din,
        Clock    => CLK,
        WrEn     => WRITE_ENABLE_IN,
        RdEn     => READ_ENABLE_IN,
        Reset    => RESET,
        Q        => dout,
        Empty    => EMPTY_OUT,
        Full     => FULL_OUT
        );
--  end generate;


--     gen_FIFO1 : if DEPTH = 1  generate
--       fifo:lattice_ecp2m_fifo_18x16
--         port map (
--           Data     => din,
--           WrClock  => CLK,
--           RdClock  => CLK,
--           WrEn     => WRITE_ENABLE_IN,
--           RdEn     => READ_ENABLE_IN,
--           Reset    => RESET,
--           RPReset  => RESET,
--           Q        => dout,
--           Empty    => EMPTY_OUT,
--           Full     => FULL_OUT
--           );
--     end generate;
--
--     gen_FIFO2 : if DEPTH = 2  generate
--       fifo:lattice_ecp2m_fifo_18x32
--         port map (
--           Data     => din,
--           WrClock  => CLK,
--           RdClock  => CLK,
--           WrEn     => WRITE_ENABLE_IN,
--           RdEn     => READ_ENABLE_IN,
--           Reset    => RESET,
--           RPReset  => RESET,
--           Q        => dout,
--           Empty    => EMPTY_OUT,
--           Full     => FULL_OUT
--           );
--     end generate;
--
--
--     gen_FIFO3 : if DEPTH = 3  generate
--       fifo:lattice_ecp2m_fifo_18x64
--         port map (
--           Data     => din,
--           WrClock  => CLK,
--           RdClock  => CLK,
--           WrEn     => WRITE_ENABLE_IN,
--           RdEn     => READ_ENABLE_IN,
--           Reset    => RESET,
--           RPReset  => RESET,
--           Q        => dout,
--           Empty    => EMPTY_OUT,
--           Full     => FULL_OUT
--           );
--     end generate;


end architecture;



