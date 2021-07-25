LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity tbmux is
end entity;


architecture arch of tbmux is

  component trb_net16_io_multiplexer is
    port (
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      --  Media direction port
      MED_DATAREADY_IN   : in  STD_LOGIC;
      MED_DATA_IN        : in  STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
      MED_READ_OUT       : out STD_LOGIC;

      MED_DATAREADY_OUT  : out STD_LOGIC;
      MED_DATA_OUT       : out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
      MED_READ_IN        : in  STD_LOGIC;

      -- Internal direction port
      INT_DATA_OUT       : out STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_OUT : out STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
      INT_DATAREADY_OUT  : out STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)-1 downto 0);
      INT_READ_IN        : in  STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)-1 downto 0);

      INT_DATAREADY_IN   : in  STD_LOGIC_VECTOR (2**c_MUX_WIDTH-1 downto 0);
      INT_DATA_IN        : in  STD_LOGIC_VECTOR (2**c_MUX_WIDTH*c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_IN  : in  STD_LOGIC_VECTOR (2**c_MUX_WIDTH*c_NUM_WIDTH-1 downto 0);
      INT_READ_OUT       : out STD_LOGIC_VECTOR (2**c_MUX_WIDTH-1 downto 0);

      -- Status and control port
      CTRL               : in  STD_LOGIC_VECTOR (31 downto 0);
      STAT               : out STD_LOGIC_VECTOR (31 downto 0)
      );
  end component;

component trb_net16_obuf is
  generic (
    USE_ACKNOWLEDGE  : integer range 0 to 1 := c_NO;
    USE_CHECKSUM     : integer range 0 to 1 := c_YES;
    DATA_COUNT_WIDTH : integer range 1 to 7 := 7;
                           -- max used buffer size is 2**DATA_COUNT_WIDTH.
    SBUF_VERSION     : integer range 0 to 5 := 5
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_OUT  : out std_logic;
    MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    MED_READ_IN        : in  std_logic;
    -- Internal direction port
    INT_DATAREADY_IN   : in  std_logic;
    INT_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0); -- Data word
    INT_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1  downto 0);
    INT_READ_OUT       : out std_logic;
    -- Status and control port
    STAT_BUFFER       : out std_logic_vector (31 downto 0);
    CTRL_BUFFER       : in  std_logic_vector (31 downto 0);
    CTRL_SETTINGS     : in  std_logic_vector (15 downto 0);
    STAT_DEBUG        : out std_logic_vector (31 downto 0);
    TIMER_TICKS_IN    : in  std_logic_vector (1 downto 0)
    );
end component;

  signal CLK : std_logic := '1';
  signal RESET : std_logic := '1';

  signal MED_DATAREADY_IN     : STD_LOGIC;
  signal MED_DATA_IN          : STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
  signal MED_PACKET_NUM_IN    : STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
  signal MED_READ_OUT         : STD_LOGIC;
  signal MED_DATAREADY_OUT    : STD_LOGIC;
  signal MED_DATA_OUT         : STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
  signal MED_PACKET_NUM_OUT   : STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
  signal MED_READ_IN          : STD_LOGIC;
  signal INT_DATA_OUT         : STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
  signal INT_PACKET_NUM_OUT   : STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
  signal INT_DATAREADY_OUT    : STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)-1 downto 0);
  signal INT_READ_IN          : STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)-1 downto 0);
  signal INT_DATAREADY_IN     : STD_LOGIC_VECTOR (2**c_MUX_WIDTH-1 downto 0);
  signal INT_DATA_IN          : STD_LOGIC_VECTOR (2**c_MUX_WIDTH*c_DATA_WIDTH-1 downto 0);
  signal INT_PACKET_NUM_IN    : STD_LOGIC_VECTOR (2**c_MUX_WIDTH*c_NUM_WIDTH-1 downto 0);
  signal INT_READ_OUT         : STD_LOGIC_VECTOR (2**c_MUX_WIDTH-1 downto 0);

  signal ctrl_data         : std_logic_vector(15 downto 0);
  signal ctrl_packet_num   : std_logic_vector(2 downto 0);
  signal ctrl_dataready    : std_logic;
  signal ctrl_read         : std_logic;

  signal trg_data         : std_logic_vector(15 downto 0);
  signal trg_packet_num   : std_logic_vector(2 downto 0);
  signal trg_dataready    : std_logic;
  signal trg_read         : std_logic;

begin

  CLK <= not CLK after 5 ns;
  RESET <= '0' after 100 ns;
--
--   uut : trb_net16_io_multiplexer
--     port map(
--       CLK => CLK,
--       RESET => RESET,
--       CLK_EN => '1',
--       MED_DATAREADY_IN   =>MED_DATAREADY_IN   ,
--       MED_DATA_IN        =>MED_DATA_IN        ,
--       MED_PACKET_NUM_IN  =>MED_PACKET_NUM_IN  ,
--       MED_READ_OUT       =>MED_READ_OUT       ,
--       MED_DATAREADY_OUT  =>MED_DATAREADY_OUT  ,
--       MED_DATA_OUT       =>MED_DATA_OUT       ,
--       MED_PACKET_NUM_OUT =>MED_PACKET_NUM_OUT ,
--       MED_READ_IN        =>MED_READ_IN        ,
--       INT_DATA_OUT       =>INT_DATA_OUT       ,
--       INT_PACKET_NUM_OUT =>INT_PACKET_NUM_OUT ,
--       INT_DATAREADY_OUT  =>INT_DATAREADY_OUT  ,
--       INT_READ_IN        =>INT_READ_IN        ,
--       INT_DATAREADY_IN   =>INT_DATAREADY_IN   ,
--       INT_DATA_IN        =>INT_DATA_IN        ,
--       INT_PACKET_NUM_IN  =>INT_PACKET_NUM_IN  ,
--       INT_READ_OUT       =>INT_READ_OUT       ,
--       CTRL               => (others => '0'),
--       STAT               =>open
--       );

  INT_READ_IN                  <= (others => '1');



  obuf3 : trb_net16_obuf
  generic map(
    SBUF_VERSION => 5
    )
  port map(
    CLK    => CLK,
    RESET  => RESET,
    CLK_EN => '1',
    --  Media direction port
    MED_DATAREADY_OUT  => INT_DATAREADY_IN(6),
    MED_DATA_OUT       => INT_DATA_IN(111 downto 96),
    MED_PACKET_NUM_OUT => INT_PACKET_NUM_IN(20 downto 18),
    MED_READ_IN        => INT_READ_OUT(6),
    -- Internal direction port
    INT_DATAREADY_IN   => ctrl_dataready,
    INT_DATA_IN        => ctrl_data,
    INT_PACKET_NUM_IN  => ctrl_packet_num,
    INT_READ_OUT       => ctrl_read,
    -- Status and control port
    STAT_BUFFER        => open,
    CTRL_BUFFER        => (others => '0'),
    CTRL_SETTINGS      => (others => '0'),
    STAT_DEBUG         => open,
    TIMER_TICKS_IN     => "00"
    );

--   obuf0 : trb_net16_obuf
--   generic map(
--     SBUF_VERSION => 5
--     )
--   port map(
--     CLK    => CLK,
--     RESET  => RESET,
--     CLK_EN => '1',
--     --  Media direction port
--     MED_DATAREADY_OUT  => INT_DATAREADY_IN(0),
--     MED_DATA_OUT       => INT_DATA_IN(15 downto 0),
--     MED_PACKET_NUM_OUT => INT_PACKET_NUM_IN(2 downto 0),
--     MED_READ_IN        => INT_READ_OUT(0),
--     -- Internal direction port
--     INT_DATAREADY_IN   => trg_dataready,
--     INT_DATA_IN        => trg_data,
--     INT_PACKET_NUM_IN  => trg_packet_num,
--     INT_READ_OUT       => trg_read,
--     -- Status and control port
--     STAT_BUFFER        => open,
--     CTRL_BUFFER        => (others => '0'),
--     CTRL_SETTINGS      => (others => '0'),
--     STAT_DEBUG         => open,
--     TIMER_TICKS_IN     => "00"
--     );


--   INT_DATAREADY_IN(1)             <= '0';
--   INT_DATA_IN(31 downto 16)       <= (others => '0');
--   INT_PACKET_NUM_IN(5 downto 3)   <= (others => '0');
--
--   INT_DATAREADY_IN(2)             <= '0';
--   INT_DATA_IN(47 downto 32)       <= (others => '0');
--   INT_PACKET_NUM_IN(8 downto 6)   <= (others => '0');
--
--   INT_DATAREADY_IN(3)             <= '0';
--   INT_DATA_IN(63 downto 48)       <= (others => '0');
--   INT_PACKET_NUM_IN(11 downto 9)  <= (others => '0');
--
--   INT_DATAREADY_IN(4)             <= '0';
--   INT_DATA_IN(79 downto 64)       <= (others => '0');
--   INT_PACKET_NUM_IN(14 downto 12) <= (others => '0');
--
--   INT_DATAREADY_IN(5)             <= '0';
--   INT_DATA_IN(95 downto 80)       <= (others => '0');
--   INT_PACKET_NUM_IN(17 downto 15) <= (others => '0');
--
--   INT_DATAREADY_IN(7)             <= '0';
--   INT_DATA_IN(127 downto 112)     <= (others => '0');
--   INT_PACKET_NUM_IN(23 downto 21) <= (others => '0');

--
--   process
--     begin
--       trg_dataready             <= '0';
--       trg_data        <= (others => '0');
--       trg_packet_num   <= (others => '0');
--       wait for 400 ns;
--       wait until rising_edge(CLK);
--       trg_dataready             <= '0';
--       trg_data        <= (others => '0');
--       trg_packet_num   <= (others => '0');
--       wait until rising_edge(CLK);
--       wait until rising_edge(CLK);
--       wait until rising_edge(CLK);
--       wait until rising_edge(CLK);
--       for i in 0 to 20 loop
--         trg_dataready             <= '1';
--         trg_data        <= x"0013";
--         trg_packet_num   <= c_H0;
--         wait for 1 ns; if trg_read = '0' then wait until trg_read = '1'; end if;
--         wait until rising_edge(CLK);
--         trg_dataready             <= '1';
--         trg_data        <= x"1111";
--         trg_packet_num   <= c_F0;
--         wait for 1 ns; if trg_read = '0' then wait until trg_read = '1'; end if;
--         wait until rising_edge(CLK);
--         trg_dataready             <= '1';
--         trg_data        <= x"2222";
--         trg_packet_num   <= c_F1;
--         wait for 1 ns; if trg_read = '0' then wait until trg_read = '1'; end if;
--         wait until rising_edge(CLK);
--         trg_dataready             <= '1';
--         trg_data        <= x"3333";
--         trg_packet_num   <= c_F2;
--         wait for 1 ns; if trg_read = '0' then wait until trg_read = '1'; end if;
--         wait until rising_edge(CLK);
--         trg_dataready             <= '1';
--         trg_data        <= x"4444";
--         trg_packet_num   <= c_F3;
--         wait for 1 ns; if trg_read = '0' then wait until trg_read = '1'; end if;
--         wait until rising_edge(CLK);
--       end loop;
--       trg_dataready             <= '0';
--       trg_data        <= x"0000";
--       trg_packet_num   <= "000";
--       wait;
--     end process;

  process
    begin
      INT_READ_OUT <= (others => '0');
      wait for 601 ns;
      for i in 0 to 30 loop
        INT_READ_OUT <= (others => '1'); wait until rising_edge(CLK);
        INT_READ_OUT <= (others => '0'); wait until rising_edge(CLK);
        INT_READ_OUT <= (others => '1'); wait until rising_edge(CLK);
        INT_READ_OUT <= (others => '1'); wait until rising_edge(CLK);
        INT_READ_OUT <= (others => '1'); wait until rising_edge(CLK);
        INT_READ_OUT <= (others => '1'); wait until rising_edge(CLK);
        INT_READ_OUT <= (others => '1'); wait until rising_edge(CLK);
        INT_READ_OUT <= (others => '0'); wait until rising_edge(CLK);
        INT_READ_OUT <= (others => '0'); wait until rising_edge(CLK);
        INT_READ_OUT <= (others => '0'); wait until rising_edge(CLK);
        INT_READ_OUT <= (others => '1'); wait until rising_edge(CLK);
        INT_READ_OUT <= (others => '1'); wait until rising_edge(CLK);
        INT_READ_OUT <= (others => '1'); wait until rising_edge(CLK);
      end loop;
    end process;

  process
    begin
      ctrl_dataready             <= '0';
      ctrl_data      <= (others => '0');
      ctrl_packet_num <= (others => '0');
      wait for 400 ns;
      ctrl_dataready             <= '1';
      ctrl_data      <= x"0031";
      ctrl_packet_num <= c_H0;
      wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
      wait until rising_edge(CLK);
      ctrl_dataready             <= '1';
      ctrl_data      <= x"AAAA";
      ctrl_packet_num <= c_F0;
      wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
      wait until rising_edge(CLK);
      ctrl_dataready             <= '1';
      ctrl_data      <= x"BBBB";
      ctrl_packet_num <= c_F1;
      wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
      wait until rising_edge(CLK);
      ctrl_dataready             <= '0';
      wait until rising_edge(CLK);
      ctrl_dataready             <= '1';
      ctrl_data      <= x"CCCC";
      ctrl_packet_num <= c_F2;
      wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
      wait until rising_edge(CLK);
      ctrl_dataready             <= '1';
      ctrl_data      <= x"DDDD";
      ctrl_packet_num <= c_F3;
      wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
      wait until rising_edge(CLK);
      ctrl_dataready             <= '0';
      wait until rising_edge(CLK);
 --second packet
      ctrl_dataready             <= '1';
      ctrl_data      <= x"0031";
      ctrl_packet_num <= c_H0;
      wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
      wait until rising_edge(CLK);
      ctrl_dataready             <= '1';
      ctrl_data      <= x"AAAA";
      ctrl_packet_num <= c_F0;
      wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
      wait until rising_edge(CLK);
      ctrl_dataready             <= '1';
      ctrl_data      <= x"BBBB";
      ctrl_packet_num <= c_F1;
      wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
      wait until rising_edge(CLK);
      ctrl_dataready             <= '0';
      wait until rising_edge(CLK);
      ctrl_dataready             <= '1';
      ctrl_data      <= x"CCCC";
      ctrl_packet_num <= c_F2;
      wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
      wait until rising_edge(CLK);
      ctrl_dataready             <= '1';
      ctrl_data      <= x"DDDD";
      ctrl_packet_num <= c_F3;
      wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
      wait until rising_edge(CLK);
      ctrl_dataready             <= '0';
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      for i in 0 to 20 loop
        ctrl_dataready             <= '1';
        ctrl_data      <= x"0031";
        ctrl_packet_num <= c_H0;
        wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
        wait until rising_edge(CLK);
        ctrl_dataready             <= '1';
        ctrl_data      <= x"AAAA";
        ctrl_packet_num <= c_F0;
        wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
        wait until rising_edge(CLK);
        ctrl_dataready             <= '1';
        ctrl_data      <= x"BBBB";
        ctrl_packet_num <= c_F1;
        wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
        wait until rising_edge(CLK);
        ctrl_dataready             <= '1';
        ctrl_data      <= x"CCCC";
        ctrl_packet_num <= c_F2;
        wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
        wait until rising_edge(CLK);
        ctrl_dataready             <= '1';
        ctrl_data      <= x"DDDD";
        ctrl_packet_num <= c_F3;
        wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
        wait until rising_edge(CLK);
      end loop;
      ctrl_dataready             <= '1';
      ctrl_data      <= x"0031";
      ctrl_packet_num <= c_H0;
      wait for 1 ns; if ctrl_read = '0' then wait until ctrl_read = '1'; end if;
      wait until rising_edge(CLK);

      ctrl_dataready             <= '0';
      ctrl_data      <= (others => '0');
      ctrl_packet_num <= (others => '0');
      wait;
    end process;

  process
    begin

      MED_DATAREADY_IN  <= '0';
      MED_DATA_IN       <= x"0000";
      MED_PACKET_NUM_IN <= "100";
      MED_READ_IN       <= '1';


      wait for 100 ns;
      wait until rising_edge(CLK);
      MED_DATA_IN       <= x"0031";
      MED_PACKET_NUM_IN <= c_H0;
      MED_DATAREADY_IN  <= '1';
      wait until rising_edge(CLK);
      MED_DATA_IN       <= x"AAAA";
      MED_PACKET_NUM_IN <= c_F0;
      MED_DATAREADY_IN  <= '1';
      wait until rising_edge(CLK);
      MED_DATA_IN       <= x"BBBB";
      MED_PACKET_NUM_IN <= c_F1;
      MED_DATAREADY_IN  <= '1';
      wait until rising_edge(CLK);
      MED_DATA_IN       <= x"CCCC";
      MED_PACKET_NUM_IN <= c_F2;
      MED_DATAREADY_IN  <= '1';
      wait until rising_edge(CLK);
      MED_DATA_IN       <= x"DDDD";
      MED_PACKET_NUM_IN <= c_F3;
      MED_DATAREADY_IN  <= '1';

      wait until rising_edge(CLK);
      MED_DATA_IN       <= x"0013";
      MED_PACKET_NUM_IN <= c_H0;
      MED_DATAREADY_IN  <= '1';
      wait until rising_edge(CLK);
      MED_DATA_IN       <= x"1111";
      MED_PACKET_NUM_IN <= c_F0;
      MED_DATAREADY_IN  <= '1';
      wait until rising_edge(CLK);
      MED_DATA_IN       <= x"2222";
      MED_PACKET_NUM_IN <= c_F1;
      MED_DATAREADY_IN  <= '1';
      wait until rising_edge(CLK);
      MED_DATA_IN       <= x"3333";
      MED_PACKET_NUM_IN <= c_F2;
      MED_DATAREADY_IN  <= '1';
      wait until rising_edge(CLK);
      MED_DATA_IN       <= x"4444";
      MED_PACKET_NUM_IN <= c_F3;
      MED_DATAREADY_IN  <= '1';

      wait until rising_edge(CLK);
      MED_DATA_IN       <= (others => '0');
      MED_PACKET_NUM_IN <= c_H0;
      MED_DATAREADY_IN  <= '0';
      wait;


    end process;


end architecture;

