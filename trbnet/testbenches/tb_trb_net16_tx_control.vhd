library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity txtb is
end entity;

architecture arch of txtb is

  component trb_net16_tx_control is
    port(
      TXCLK_IN                       : in  std_logic;
      RXCLK_IN                       : in  std_logic;
      SYSCLK_IN                      : in  std_logic;
      RESET_IN                       : in  std_logic;

      TX_DATA_IN                     : in  std_logic_vector(15 downto 0);
      TX_WRITE_IN                    : in  std_logic;
      TX_READ_OUT                    : out std_logic;

      TX_DATA_OUT                    : out std_logic_vector( 7 downto 0);
      TX_K_OUT                       : out std_logic;

      REQUEST_RETRANSMIT_IN          : in  std_logic;
      REQUEST_POSITION_IN            : in  std_logic_vector( 7 downto 0);

      START_RETRANSMIT_IN            : in  std_logic;
      START_POSITION_IN              : in  std_logic_vector( 7 downto 0);

      SEND_LINK_RESET_IN             : in  std_logic;
      TX_ALLOW_IN                    : in  std_logic;

      DEBUG_OUT                      : out std_logic_vector(31 downto 0)
      );
  end component;

  signal clk                     : std_logic := '1';
  signal clk25                   : std_logic := '1';
  signal reset                   : std_logic := '1';

  signal tx_data_in              : std_logic_vector(15 downto 0);
  signal tx_write_in             : std_logic;
  signal tx_read_out             : std_logic;

  signal tx_data_out             : std_logic_vector( 7 downto 0);
  signal tx_k_out                : std_logic;
  signal request_retransmit_in   : std_logic;
  signal request_position_in     : std_logic_vector( 7 downto 0);
  signal start_retransmit_in     : std_logic;
  signal start_position_in       : std_logic_vector( 7 downto 0);
  signal send_link_reset_in      : std_logic;
  signal tx_allow_in             : std_logic;


--   signal INT_DATA_OUT            : STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
--   signal INT_PACKET_NUM_OUT      : STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
--   signal INT_DATAREADY_OUT       : STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)-1 downto 0);
--   signal INT_READ_IN             : STD_LOGIC_VECTOR (2**(c_MUX_WIDTH-1)-1 downto 0);

  signal INT_DATAREADY           : STD_LOGIC_VECTOR (2**c_MUX_WIDTH-1 downto 0);
  signal INT_DATA                : STD_LOGIC_VECTOR (2**c_MUX_WIDTH*c_DATA_WIDTH-1 downto 0);
  signal INT_PACKET_NUM          : STD_LOGIC_VECTOR (2**c_MUX_WIDTH*c_NUM_WIDTH-1 downto 0);
  signal INT_READ                : STD_LOGIC_VECTOR (2**c_MUX_WIDTH-1 downto 0);

begin

  proc_clk25 : process
    begin
      wait for 20 ns;
      clk25 <= not clk25;
    end process;


  proc_clk : process
    begin
      wait for 5 ns;
      clk <= not clk;
    end process;

  proc_reset : process
    begin
      reset <= '1';
      wait for 105 ns;
      reset <= '0';
      wait;
    end process;

  uut : trb_net16_tx_control
    port map(
      TXCLK_IN                       => clk25,
      RXCLK_IN                       => clk25,
      SYSCLK_IN                      => clk,
      RESET_IN                       => reset,

      TX_DATA_IN                     => tx_data_in,
      TX_WRITE_IN                    => tx_write_in,
      TX_READ_OUT                    => tx_read_out,

      TX_DATA_OUT                    => tx_data_out,
      TX_K_OUT                       => tx_k_out,

      REQUEST_RETRANSMIT_IN          => request_retransmit_in,
      REQUEST_POSITION_IN            => request_position_in,

      START_RETRANSMIT_IN            => start_retransmit_in,
      START_POSITION_IN              => start_position_in,

      SEND_LINK_RESET_IN             => send_link_reset_in,
      TX_ALLOW_IN                    => tx_allow_in,

      DEBUG_OUT                      => open
      );


  the_mux: trb_net16_io_multiplexer
    generic map(
      USE_INPUT_SBUF => (others => c_NO)
      )
    port map(
      --  Misc
      CLK    => clk,
      RESET  => reset,
      CLK_EN => '1',

      --  Media direction port
      MED_DATAREADY_IN   => '0',
      MED_DATA_IN        => (others => '0'),
      MED_PACKET_NUM_IN  => (others => '0'),
      MED_READ_OUT       => open,

      MED_DATAREADY_OUT  => tx_write_in,
      MED_DATA_OUT       => tx_data_in,
      MED_PACKET_NUM_OUT => open,
      MED_READ_IN        => tx_read_out,

      -- Internal direction port
      INT_DATA_OUT       => open,
      INT_PACKET_NUM_OUT => open,
      INT_DATAREADY_OUT  => open,
      INT_READ_IN        => (others => '1'),

      INT_DATAREADY_IN   => int_dataready,
      INT_DATA_IN        => int_data,
      INT_PACKET_NUM_IN  => int_packet_num,
      INT_READ_OUT       => int_read,

      -- Status and control port
      CTRL               => (others => '0'),
      STAT               => open
      );


--Data input
  process
    begin
      int_data(31 downto 16) <= (others => '0');
      int_packet_num(5 downto 3) <= "100";
      int_dataready(1) <= '0';
      wait for 300 ns;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0101";
      int_packet_num(5 downto 3) <= "100";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0202";
      int_packet_num(5 downto 3) <= "000";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_dataready(1) <= '0';
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0303";
      int_packet_num(5 downto 3) <= "001";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0404";
      int_packet_num(5 downto 3) <= "010";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_dataready(1) <= '0';
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0505";
      int_packet_num(5 downto 3) <= "011";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_dataready(1) <= '0';
      wait for 1 us;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0606";
      int_packet_num(5 downto 3) <= "100";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0707";
      int_packet_num(5 downto 3) <= "000";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0808";
      int_packet_num(5 downto 3) <= "001";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0909";
      int_packet_num(5 downto 3) <= "010";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0a0a";
      int_packet_num(5 downto 3) <= "011";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0b0b";
      int_packet_num(5 downto 3) <= "100";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0c0c";
      int_packet_num(5 downto 3) <= "000";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0d0d";
      int_packet_num(5 downto 3) <= "001";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0e0e";
      int_packet_num(5 downto 3) <= "010";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"0f0f";
      int_packet_num(5 downto 3) <= "011";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"1010";
      int_packet_num(5 downto 3) <= "100";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"2020";
      int_packet_num(5 downto 3) <= "000";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"3030";
      int_packet_num(5 downto 3) <= "001";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"4040";
      int_packet_num(5 downto 3) <= "010";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"5050";
      int_packet_num(5 downto 3) <= "011";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"6060";
      int_packet_num(5 downto 3) <= "100";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"7070";
      int_packet_num(5 downto 3) <= "000";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"8080";
      int_packet_num(5 downto 3) <= "001";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"9090";
      int_packet_num(5 downto 3) <= "010";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= x"a0a0";
      int_packet_num(5 downto 3) <= "011";
      int_dataready(1) <= '1';
      if int_read(1) = '0' then wait until int_read(1) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(31 downto 16) <= (others => '0');
      int_dataready(1) <= '0';
      wait for 970 ns;
    end process;


--Data input
  process
    begin
      int_data(15 downto 0) <= (others => '0');
      int_packet_num(2 downto 0) <= "100";
      int_dataready(0) <= '0';
      wait;
      wait for 300 ns;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(15 downto 0) <= x"1111";
      int_packet_num(2 downto 0) <= "100";
      int_dataready(0) <= '1';
      if int_read(0) = '0' then wait until int_read(0) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(15 downto 0) <= x"2222";
      int_packet_num(2 downto 0) <= "000";
      int_dataready(0) <= '1';
      if int_read(0) = '0' then wait until int_read(0) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_dataready(0) <= '0';
      wait until rising_edge(clk); wait for 1 ns;
      int_data(15 downto 0) <= x"3333";
      int_packet_num(2 downto 0) <= "001";
      int_dataready(0) <= '1';
      if int_read(0) = '0' then wait until int_read(0) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_data(15 downto 0) <= x"4444";
      int_packet_num(2 downto 0) <= "010";
      int_dataready(0) <= '1';
      if int_read(0) = '0' then wait until int_read(0) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_dataready(0) <= '0';
      wait until rising_edge(clk); wait for 1 ns;
      int_data(15 downto 0) <= x"5555";
      int_packet_num(2 downto 0) <= "011";
      int_dataready(0) <= '1';
      if int_read(0) = '0' then wait until int_read(0) = '1'; end if;
      wait until rising_edge(clk); wait for 1 ns;
      int_dataready(0) <= '0';
      wait for 700 ns;
    end process;


--request from RX
  process
    begin
      request_retransmit_in <= '0';
      request_position_in   <= (others => '0');
      wait for 300 ns;
      wait until rising_edge(clk); wait for 1 ns;
      request_retransmit_in <= '0';
      request_position_in   <= (others => '0');
      wait;
    end process;


--restart from RX
  process
    begin
      start_retransmit_in <= '0';
      start_position_in   <= (others => '0');
      wait for 630 ns;
      wait until rising_edge(clk); wait for 1 ns;
      start_retransmit_in <= '0';
      start_position_in   <= std_logic_vector(to_unsigned(5,8));
      wait until rising_edge(clk); wait for 1 ns;
      start_retransmit_in <= '0';
      start_position_in   <= (others => '0');
      wait for 1050 ns;
      wait until rising_edge(clk); wait for 1 ns;
      start_retransmit_in <= '0';
      start_position_in   <= std_logic_vector(to_unsigned(15,8));
      wait until rising_edge(clk); wait for 1 ns;
      start_retransmit_in <= '0';
      start_position_in   <= (others => '0');
      wait;
    end process;

--control from LSM
  process
    begin
      tx_allow_in          <= '0';
      send_link_reset_in   <= '0';
      wait for 350 ns;
      wait until rising_edge(clk); wait for 1 ns;
      tx_allow_in          <= '1';
      send_link_reset_in   <= '0';
      wait;
    end process;


end architecture;



