LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb_net16_hub_func.all;

entity pcie_tb is
end entity;

architecture arch of pcie_tb is

component trb_net_bridge_pcie_endpoint_hub is
  generic(
    NUM_LINKS    : integer range 1 to 4 := 2;
    COMPILE_TIME : std_logic_vector(31 downto 0) := (others => '0')
    );
  port(
    RESET              : in  std_logic;
    CLK                : in  std_logic;

    BUS_ADDR_IN        : in  std_logic_vector(31 downto 0);
    BUS_WDAT_IN        : in  std_logic_vector(31 downto 0);
    BUS_RDAT_OUT       : out std_logic_vector(31 downto 0);
    BUS_SEL_IN         : in  std_logic_vector(3 downto 0);
    BUS_WE_IN          : in  std_logic;
    BUS_CYC_IN         : in  std_logic;
    BUS_STB_IN         : in  std_logic;
    BUS_LOCK_IN        : in  std_logic;
    BUS_ACK_OUT        : out std_logic;

    MED_DATAREADY_IN   : in  std_logic_vector (NUM_LINKS-1 downto 0);
    MED_DATA_IN        : in  std_logic_vector (16*NUM_LINKS-1 downto 0);
    MED_PACKET_NUM_IN  : in  std_logic_vector (3*NUM_LINKS-1 downto 0);
    MED_READ_OUT       : out std_logic_vector (NUM_LINKS-1 downto 0);

    MED_DATAREADY_OUT  : out std_logic_vector (NUM_LINKS-1 downto 0);
    MED_DATA_OUT       : out std_logic_vector (16*NUM_LINKS-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector (3*NUM_LINKS-1 downto 0);
    MED_READ_IN        : in  std_logic_vector (NUM_LINKS-1 downto 0);

    MED_STAT_OP_IN     : in  std_logic_vector (16*NUM_LINKS-1 downto 0);
    MED_CTRL_OP_OUT    : out std_logic_vector (16*NUM_LINKS-1 downto 0);

    SEND_RESET_OUT     : out std_logic;
    DEBUG_OUT          : out std_logic_vector (31 downto 0)
    );
end component;

  constant NUM_LINKS : integer := 2;

  signal CLK : std_logic := '1';
  signal RESET : std_logic := '1';

  signal BUS_ADDR_IN        : std_logic_vector(31 downto 0) := (others => '0');
  signal BUS_WDAT_IN        : std_logic_vector(31 downto 0) := (others => '0');
  signal BUS_RDAT_OUT       : std_logic_vector(31 downto 0) := (others => '0');
  signal BUS_SEL_IN         : std_logic_vector(3 downto 0) := (others => '0');
  signal BUS_WE_IN          : std_logic := '0';
  signal BUS_CYC_IN         : std_logic := '0';
  signal BUS_STB_IN         : std_logic := '0';
  signal BUS_LOCK_IN        : std_logic := '0';
  signal BUS_ACK_OUT        : std_logic := '0';

  signal MED_DATAREADY_IN   : std_logic_vector (NUM_LINKS-1 downto 0) := (others => '0');
  signal MED_DATA_IN        : std_logic_vector (16*NUM_LINKS-1 downto 0) := (others => '0');
  signal MED_PACKET_NUM_IN  : std_logic_vector (3*NUM_LINKS-1 downto 0) := (others => '0');
  signal MED_READ_OUT       : std_logic_vector (NUM_LINKS-1 downto 0) := (others => '0');

  signal MED_DATAREADY_OUT  : std_logic_vector (NUM_LINKS-1 downto 0) := (others => '0');
  signal MED_DATA_OUT       : std_logic_vector (16*NUM_LINKS-1 downto 0) := (others => '0');
  signal MED_PACKET_NUM_OUT : std_logic_vector (3*NUM_LINKS-1 downto 0) := (others => '0');
  signal MED_READ_IN        : std_logic_vector (NUM_LINKS-1 downto 0) := (others => '0');

  signal MED_STAT_OP_IN     : std_logic_vector (16*NUM_LINKS-1 downto 0) := (others => '0');
  signal MED_CTRL_OP_OUT    : std_logic_vector (16*NUM_LINKS-1 downto 0) := (others => '0');


begin

  CLK <= not CLK after 5 ns;
  RESET <= '0' after 100 ns;
  MED_STAT_OP_IN <= (others => '0');

 UT : trb_net_bridge_pcie_endpoint_hub
   port map(
    RESET                => RESET,
    CLK                  => CLK,

    BUS_ADDR_IN          => BUS_ADDR_IN,
    BUS_WDAT_IN          => BUS_WDAT_IN,
    BUS_RDAT_OUT         => BUS_RDAT_OUT,
    BUS_SEL_IN           => BUS_SEL_IN,
    BUS_WE_IN            => BUS_WE_IN,
    BUS_CYC_IN           => BUS_CYC_IN,
    BUS_STB_IN           => BUS_STB_IN,
    BUS_LOCK_IN          => BUS_LOCK_IN,
    BUS_ACK_OUT          => BUS_ACK_OUT,

    MED_DATAREADY_IN     => MED_DATAREADY_IN,
    MED_DATA_IN          => MED_DATA_IN,
    MED_PACKET_NUM_IN    => MED_PACKET_NUM_IN,
    MED_READ_OUT         => MED_READ_OUT,

    MED_DATAREADY_OUT    => MED_DATAREADY_OUT,
    MED_DATA_OUT         => MED_DATA_OUT,
    MED_PACKET_NUM_OUT   => MED_PACKET_NUM_OUT,
    MED_READ_IN          => MED_READ_IN,

    MED_STAT_OP_IN       => MED_STAT_OP_IN,
    MED_CTRL_OP_OUT      => MED_CTRL_OP_OUT,

    SEND_RESET_OUT       => open,
    DEBUG_OUT            => open
    );

  process
    begin
      BUS_SEL_IN <= x"F";
      BUS_WDAT_IN <= (others => '0');

      wait for 500 ns;
      wait until rising_edge(CLK);
      BUS_ADDR_IN <= x"00000174";
      BUS_WE_IN   <= '1';
      BUS_CYC_IN  <= '1';
      BUS_STB_IN  <= '1';
      BUS_LOCK_IN <= '1';
      wait until BUS_ACK_OUT <= '1';
      BUS_CYC_IN  <= '0';
      BUS_LOCK_IN <= '0';
      BUS_STB_IN  <= '0';
      wait until BUS_ACK_OUT <= '0';

      wait until rising_edge(CLK);
      BUS_ADDR_IN <= x"00000174";
      BUS_WE_IN   <= '1';
      BUS_CYC_IN  <= '1';
      BUS_STB_IN  <= '1';
      BUS_LOCK_IN <= '1';
      wait until BUS_ACK_OUT <= '1';
      BUS_CYC_IN  <= '0';
      BUS_LOCK_IN <= '0';
      BUS_STB_IN  <= '0';
      wait until BUS_ACK_OUT <= '0';

      wait until rising_edge(CLK);
      BUS_ADDR_IN <= x"00000174";
      BUS_WE_IN   <= '1';
      BUS_CYC_IN  <= '1';
      BUS_STB_IN  <= '1';
      BUS_LOCK_IN <= '1';
      wait until BUS_ACK_OUT <= '1';
      BUS_CYC_IN  <= '0';
      BUS_LOCK_IN <= '0';
      BUS_STB_IN  <= '0';
      wait until BUS_ACK_OUT <= '0';

      wait until rising_edge(CLK);
      BUS_ADDR_IN <= x"00000174";
      BUS_WE_IN   <= '1';
      BUS_CYC_IN  <= '1';
      BUS_STB_IN  <= '1';
      BUS_LOCK_IN <= '1';
      wait until BUS_ACK_OUT <= '1';
      BUS_CYC_IN  <= '0';
      BUS_LOCK_IN <= '0';
      BUS_STB_IN  <= '0';
      wait until BUS_ACK_OUT <= '0';


      wait until rising_edge(CLK);
      BUS_ADDR_IN <= x"00000170";
      BUS_WE_IN   <= '1';
      BUS_CYC_IN  <= '1';
      BUS_STB_IN  <= '1';
      BUS_LOCK_IN <= '1';
      wait until BUS_ACK_OUT <= '1';
      BUS_CYC_IN  <= '0';
      BUS_LOCK_IN <= '0';
      BUS_STB_IN  <= '0';
      wait until BUS_ACK_OUT <= '0';

      wait;
    end process;


end architecture;