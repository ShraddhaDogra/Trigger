LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


-------------------------------------------------------------------------------
-- Single buffer with one more buffer to keep the speed of the datalink
-- The sbuf can be connected to a combinatorial logic (as an output buffer)
-- to provide the synchronous logic
--
-- 6 versions are provided
-- VERSION=0 standard sbuf, 2 stages, read is combinatorial
-- VERSION=2 8 words deep fifo
-- VERSION=3 3 register stages, no combinatorial path
-- VERSION=4 1 stage, combinatorial read, uses different port logic!
-- VERSION=5 fifo that forwards only complete packets - Lattice only!
-- VERSION=6 for hub: dummy sbuf simple route-through
--
-- This is a wrapper for the normal sbuf that provides two data ports sharing
-- the same logic.
-------------------------------------------------------------------------------


entity trb_net16_sbuf is
  generic (
    VERSION    : integer := 0
    );
  port(
    --  Misc
    CLK               : in std_logic;
    RESET             : in std_logic;
    CLK_EN            : in std_logic;
    --  port to combinatorial logic
    COMB_DATAREADY_IN : in  STD_LOGIC;  --comb logic provides data word
    COMB_next_READ_OUT: out STD_LOGIC;  --sbuf can read in NEXT cycle
    COMB_READ_IN      : in  STD_LOGIC;  --comb logic IS reading
    COMB_DATA_IN      : in  STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0); -- Data word
    COMB_PACKET_NUM_IN: in  STD_LOGIC_VECTOR (c_NUM_WIDTH-1  downto 0);
    -- Port to synchronous output.
    SYN_DATAREADY_OUT : out STD_LOGIC;
    SYN_DATA_OUT      : out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0); -- Data word
    SYN_PACKET_NUM_OUT: out STD_LOGIC_VECTOR (c_NUM_WIDTH-1  downto 0);
    SYN_READ_IN       : in  STD_LOGIC;
    -- Status and control port
    DEBUG_OUT         : out std_logic_vector(15 downto 0);
    STAT_BUFFER       : out STD_LOGIC
    );
end entity;

architecture trb_net16_sbuf_arch of trb_net16_sbuf is

signal comb_in, syn_out : std_logic_vector (c_DATA_WIDTH + c_NUM_WIDTH - 1 downto 0);
signal tmp : std_logic;

begin
  comb_in(c_DATA_WIDTH - 1 downto 0) <= COMB_DATA_IN;
  comb_in(c_DATA_WIDTH + c_NUM_WIDTH -1 downto c_DATA_WIDTH) <= COMB_PACKET_NUM_IN;
  SYN_DATA_OUT <= syn_out(c_DATA_WIDTH - 1 downto 0);
  SYN_PACKET_NUM_OUT <= syn_out(c_DATA_WIDTH + c_NUM_WIDTH - 1 downto c_DATA_WIDTH);


  gen_version_0 : if VERSION = 0 generate
    sbuf: trb_net_sbuf
      generic map(
        DATA_WIDTH => 19
        )
      port map(
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN  => COMB_DATAREADY_IN,
        COMB_next_READ_OUT => COMB_next_READ_OUT,
        COMB_READ_IN       => COMB_READ_IN,
        COMB_DATA_IN       => comb_in,
        SYN_DATAREADY_OUT  => SYN_DATAREADY_OUT,
        SYN_DATA_OUT       => syn_out,
        SYN_READ_IN        => SYN_READ_IN,
        STAT_BUFFER        => STAT_BUFFER
        );
    DEBUG_OUT <= (others => '0');
  end generate;

  gen_version_2 : if VERSION = 2 generate
    sbuf: trb_net_sbuf2
      generic map(
        DATA_WIDTH => 19
        )
      port map(
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN  => COMB_DATAREADY_IN,
        COMB_next_READ_OUT => COMB_next_READ_OUT,
        COMB_READ_IN       => COMB_READ_IN,
        COMB_DATA_IN       => comb_in,
        SYN_DATAREADY_OUT  => SYN_DATAREADY_OUT,
        SYN_DATA_OUT       => syn_out,
        SYN_READ_IN        => SYN_READ_IN,
        STAT_BUFFER        => STAT_BUFFER
        );
    DEBUG_OUT <= (others => '0');
  end generate;

  gen_version_3 : if VERSION = 3 generate
    sbuf: trb_net_sbuf3
      generic map(
        DATA_WIDTH => 19
        )
      port map(
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN  => COMB_DATAREADY_IN,
        COMB_next_READ_OUT => COMB_next_READ_OUT,
        COMB_READ_IN       => COMB_READ_IN,
        COMB_DATA_IN       => comb_in,
        SYN_DATAREADY_OUT  => SYN_DATAREADY_OUT,
        SYN_DATA_OUT       => syn_out,
        SYN_READ_IN        => SYN_READ_IN,
        STAT_BUFFER        => STAT_BUFFER
        );
    DEBUG_OUT <= (others => '0');
  end generate;

  gen_version_4 : if VERSION = 4 generate
    sbuf: trb_net_sbuf4
      generic map(
        DATA_WIDTH => 19
        )
      port map(
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN  => COMB_DATAREADY_IN,
        COMB_next_READ_OUT => COMB_next_READ_OUT,
        COMB_READ_IN       => COMB_READ_IN,
        COMB_DATA_IN       => comb_in,
        SYN_DATAREADY_OUT  => SYN_DATAREADY_OUT,
        SYN_DATA_OUT       => syn_out,
        SYN_READ_IN        => SYN_READ_IN,
        STAT_BUFFER        => STAT_BUFFER
        );
    DEBUG_OUT <= (others => '0');
  end generate;

  gen_version_5 : if VERSION = 5 generate
    sbuf: trb_net_sbuf5
      port map(
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN  => COMB_DATAREADY_IN,
        COMB_next_READ_OUT => COMB_next_READ_OUT,
        COMB_DATA_IN       => comb_in,
        SYN_DATAREADY_OUT  => SYN_DATAREADY_OUT,
        SYN_DATA_OUT       => syn_out,
        SYN_READ_IN        => SYN_READ_IN,
        DEBUG(6 downto 0)  => DEBUG_OUT(6 downto 0),
        DEBUG(7)           => tmp,
        DEBUG_WCNT         => DEBUG_OUT(11 downto 7),
        DEBUG_BSM          => DEBUG_OUT(15 downto 12),
        STAT_BUFFER        => STAT_BUFFER
        );
  end generate;

  gen_version_6 : if VERSION = 6 generate
    sbuf: trb_net_sbuf6
      port map(
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN  => COMB_DATAREADY_IN,
        COMB_next_READ_OUT => COMB_next_READ_OUT,
        COMB_DATA_IN       => comb_in,
        SYN_DATAREADY_OUT  => SYN_DATAREADY_OUT,
        SYN_DATA_OUT       => syn_out,
        SYN_READ_IN        => SYN_READ_IN,
        DEBUG(6 downto 0)  => DEBUG_OUT(6 downto 0),
        DEBUG(7)           => tmp,
        DEBUG_WCNT         => DEBUG_OUT(11 downto 7),
        DEBUG_BSM          => DEBUG_OUT(15 downto 12),
        STAT_BUFFER        => STAT_BUFFER
        );
  end generate;

end architecture;

