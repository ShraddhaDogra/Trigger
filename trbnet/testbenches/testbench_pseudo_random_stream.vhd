LIBRARY ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net16_hub_func.all;


entity testbench is
end entity testbench;

architecture testbench_arch of testbench is

  component pseudo_random_stream_checker is
    generic(
      WIDTH  : integer := 16
      );
    port(
      CLK    : in  std_logic;
      RESET  : in  std_logic;
      CLK_EN : in  std_logic;
      D_IN   : in  std_logic_vector(15 downto 0);
      D_EN   : in  std_logic;
      D_RST  : in  std_logic;
      FAIL   : out std_logic;
      MY_CRC_OUT: out std_logic_vector(15 downto 0)
      );
  end component;

  component pseudo_random_stream_generator is
    port(
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      D_OUT  : out std_logic_vector(15 downto 0);
      D_EN   : out std_logic;
      D_RST  : out std_logic
      );
  end component;

  component trb_net16_med_16_CC is
    port(
      CLK    : in std_logic;
      CLK_EN : in std_logic;
      RESET  : in std_logic;

      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic;
      MED_READ_OUT       : out std_logic;
      MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic;
      MED_READ_IN        : in  std_logic;

      DATA_OUT           : out std_logic_vector(15 downto 0);
      DATA_VALID_OUT     : out std_logic;
      DATA_CTRL_OUT      : out std_logic;
      DATA_IN            : in  std_logic_vector(15 downto 0);
      DATA_VALID_IN      : in  std_logic;
      DATA_CTRL_IN       : in  std_logic;

      STAT_OP            : out std_logic_vector(15 downto 0);
      CTRL_OP            : in  std_logic_vector(15 downto 0);
      STAT_DEBUG         : out std_logic_vector(63 downto 0)
      );
  end component;

  signal CLK : std_logic := '1';
  signal RESET : std_logic := '1';
  signal CLK_EN : std_logic := '1';

  signal MED_DATAREADY_IN   : std_logic;
  signal MED_READ_IN        : std_logic;
  signal MED_DATAREADY_OUT  : std_logic;
  signal MED_READ_OUT       : std_logic;
  signal MED_PACKET_NUM_OUT : std_logic_vector(2 downto 0);
  signal MED_PACKET_NUM_IN  : std_logic_vector(2 downto 0);
  signal MED_DATA_IN        : std_logic_vector(15 downto 0);
  signal MED_DATA_OUT       : std_logic_vector(15 downto 0);
  signal MED_R_DATAREADY_IN   : std_logic;
  signal MED_R_READ_IN        : std_logic;
  signal MED_R_DATAREADY_OUT  : std_logic;
  signal MED_R_READ_OUT       : std_logic;
  signal MED_R_PACKET_NUM_OUT : std_logic_vector(2 downto 0);
  signal MED_R_PACKET_NUM_IN  : std_logic_vector(2 downto 0);
  signal MED_R_DATA_IN        : std_logic_vector(15 downto 0);
  signal MED_R_DATA_OUT       : std_logic_vector(15 downto 0);
  signal MED_STAT_OP     : std_logic_vector(31 downto 0);
  signal MED_CTRL_OP    : std_logic_vector(31 downto 0);



  signal DATA_LINK1 : std_logic_vector(17 downto 0);
  signal DATA_LINK2 : std_logic_vector(17 downto 0);
  signal gen_RESET  : std_logic;

begin
  CLK <= not CLK after 5 ns;
  RESET <= '0' after 50 ns;
  CLK_EN <= '1';


--Sender
-----------------------
  THE_GENERATOR : pseudo_random_stream_generator
    port map(
      CLK    => CLK,
      RESET  => gen_RESET,
      CLK_EN => CLK_EN,
      D_OUT  => MED_DATA_OUT,
      D_EN   => MED_DATAREADY_OUT,
      D_RST  => open
      );
  MED_PACKET_NUM_OUT <= "000";

  gen_RESET <= RESET or (not MED_READ_IN);

--Connecting both parts
-----------------------


  THE_SENDER_MED : trb_net16_med_16_CC
    port map(
      CLK    => CLK,
      CLK_EN => CLK_EN,
      RESET  => RESET,

      --Internal Connection
      MED_DATA_IN        => MED_DATA_OUT,
      MED_PACKET_NUM_IN  => MED_PACKET_NUM_OUT,
      MED_DATAREADY_IN   => MED_DATAREADY_OUT,
      MED_READ_OUT       => MED_READ_IN,
      MED_DATA_OUT       => MED_DATA_IN,
      MED_PACKET_NUM_OUT => MED_PACKET_NUM_IN,
      MED_DATAREADY_OUT  => MED_DATAREADY_IN,
      MED_READ_IN        => MED_READ_OUT,

      DATA_OUT           => DATA_LINK1(15 downto 0),
      DATA_VALID_OUT     => DATA_LINK1(16),
      DATA_CTRL_OUT      => DATA_LINK1(17),
      DATA_IN            => DATA_LINK2(15 downto 0),
      DATA_VALID_IN      => DATA_LINK2(16),
      DATA_CTRL_IN       => DATA_LINK2(17),

      STAT_OP            => MED_STAT_OP(15 downto 0),
      CTRL_OP            => MED_CTRL_OP(15 downto 0),
      STAT_DEBUG         => open
      );

  THE_RECEIVER_MED : trb_net16_med_16_CC
    port map(
      CLK    => CLK,
      CLK_EN => CLK_EN,
      RESET  => RESET,

      --Internal Connection
      MED_DATA_IN        => MED_R_DATA_OUT,
      MED_PACKET_NUM_IN  => MED_R_PACKET_NUM_OUT,
      MED_DATAREADY_IN   => MED_R_DATAREADY_OUT,
      MED_READ_OUT       => MED_R_READ_IN,
      MED_DATA_OUT       => MED_R_DATA_IN,
      MED_PACKET_NUM_OUT => MED_R_PACKET_NUM_IN,
      MED_DATAREADY_OUT  => MED_R_DATAREADY_IN,
      MED_READ_IN        => MED_R_READ_OUT,

      DATA_OUT           => DATA_LINK2(15 downto 0),
      DATA_VALID_OUT     => DATA_LINK2(16),
      DATA_CTRL_OUT      => DATA_LINK2(17),
      DATA_IN            => DATA_LINK1(15 downto 0),
      DATA_VALID_IN      => DATA_LINK1(16),
      DATA_CTRL_IN       => DATA_LINK1(17),

      STAT_OP            => MED_STAT_OP(31 downto 16),
      CTRL_OP            => MED_CTRL_OP(31 downto 16),
      STAT_DEBUG         => open
      );
MED_CTRL_OP <= MED_STAT_OP;

--Receiver
-----------------------

  THE_CHECKER : pseudo_random_stream_checker
    port map(
      CLK    => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      D_IN   => MED_R_DATA_IN,
      D_EN   => MED_R_DATAREADY_IN,
      D_RST  => '0',
      FAIL   => open,
      MY_CRC_OUT => open
      );


end architecture;