library ieee;
use ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity tbfot is
end entity;

architecture arch of tbfot is

component trb_net16_rx_packets is
port(
  -- Resets
  RESET_IN              : in  std_logic;
  QUAD_RST_IN           : in  std_logic;
  -- data stream from SerDes
  CLK_IN                : in  std_logic; -- SerDes RX clock
  RX_ALLOW_IN           : in  std_logic;
  RX_DATA_IN            : in  std_logic_vector(7 downto 0);
  RX_K_IN               : in  std_logic;
  -- media interface
  SYSCLK_IN             : in  std_logic; -- 100MHz master clock
  MED_DATA_OUT          : out std_logic_vector(15 downto 0);
  MED_DATAREADY_OUT     : out std_logic;
  MED_READ_IN           : in  std_logic;
  MED_PACKET_NUM_OUT    : out std_logic_vector(2 downto 0);
  -- reset handling
  SEND_RESET_WORDS_OUT  : out std_logic;
  MAKE_TRBNET_RESET_OUT : out std_logic;
  -- Status signals
  PACKET_TIMEOUT_OUT    : out std_logic;
  -- Debug signals
  BSM_OUT               : out std_logic_vector(3 downto 0);
  DBG_OUT               : out std_logic_vector(15 downto 0)
);
end component;


  signal clk                     : std_logic := '1';
  signal clk25                   : std_logic := '1';
  signal reset                   : std_logic := '1';
  signal reset_async             : std_logic := '1';

  signal toggle1    : std_logic;
  signal counter1   : std_logic_vector(11 downto 0);
  signal read1      : std_logic;
  signal dataready1 : std_logic;
  signal number1    : std_logic_vector(2 downto 0);
  signal data1      : std_logic_vector(15 downto 0);

  signal toggle2    : std_logic;
  signal counter2   : std_logic_vector(11 downto 0);
  signal read2      : std_logic;
  signal dataready2 : std_logic;
  signal number2    : std_logic_vector(2 downto 0);
  signal data2      : std_logic_vector(15 downto 0);

  signal tx_data_in              : std_logic_vector(15 downto 0);
  signal tx_write_in             : std_logic;
  signal tx_read_out             : std_logic;

  signal tx_data_out             : std_logic_vector( 7 downto 0);
  signal tx_k_out                : std_logic;

  signal tx_allow_in             : std_logic;
  signal send_link_reset_in      : std_logic;

  signal dummy                   : std_logic_vector(31 downto 0);

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
      reset_async <= '1';
      wait for 40 ns;
      reset_async <= '0';
      wait for 105 ns;
      reset <= '0';
      wait;
    end process;

--control from LSM
  proc_lsm : process
    begin
      tx_allow_in          <= '0';
      send_link_reset_in   <= '0';
      wait for 350 ns;
      wait until rising_edge(clk); wait for 1 ns;
      tx_allow_in          <= '1';
      send_link_reset_in   <= '0';
      wait;
    end process;



  process(clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          number1 <= "100";
          dataready1 <= '0';
          toggle1    <= '0';
          counter1   <= (others => '0');
        else
          if ((counter1 < 19 and toggle1 = '1')  or (counter1 < 14 and toggle1 = '0')) or
             (((counter1 < 20 and toggle1 = '1')  or (counter1 < 15 and toggle1 = '0')) and read1 = '0') then
            dataready1 <= '1';
            if read1 = '1' and dataready1 = '1' then
              counter1 <= counter1 + 1;
            end if;
          else
            dataready1 <= '0';
            if counter1 = 2046 then
              counter1 <= (others => '0');
              toggle1  <= not toggle1;
            else
              counter1 <= counter1 + 1;
            end if;
          end if;
          if read1 = '1' and dataready1 = '1' then
            if number1 = "100" then
              number1 <= "000";
            else
              number1 <= number1 + 1;
            end if;
          end if;
        end if;
      end if;
    end process;

  data1 <= (counter1(7 downto 0)) & (counter1(7 downto 0));
  data2 <= (counter2(7 downto 0)) & (counter2(7 downto 0));

  process(clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          number2    <= "100";
          dataready2 <= '0';
          toggle2    <= '0';
          counter2   <= (others => '0');
        else
          if ((counter2 < 23 and toggle2 = '1') or (counter2 < 18 and toggle2 = '0')) or
             (((counter2 < 24 and toggle2 = '1') or (counter2 < 19 and toggle2 = '0')) and read2 = '0') or
             (counter2 = 30 and (dataready2 = '0' or read2 = '0')) then
            dataready2 <= '1';
            if read2 = '1' and dataready2 = '1' then
              counter2 <= counter2 + 1;
            end if;
          else
            dataready2 <= '0';
            if counter2 = 2047 then
              counter2 <= (others => '0');
              toggle2  <= not toggle2;
            else
              counter2 <= counter2 + 1;
            end if;
          end if;
          if read2 = '1' and dataready2 = '1' then
            if number2 = "100" then
              number2 <= "000";
            else
              number2 <= number2 + 1;
            end if;
          end if;
        end if;
      end if;
    end process;

  the_test_mux : trb_net16_io_multiplexer
    generic map (
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
      INT_DATAREADY_IN(0)           => dataready1,
      INT_DATAREADY_IN(1)           => '0',
      INT_DATAREADY_IN(2)           => dataready2,
      INT_DATAREADY_IN(7 downto 3)  => (others => '0'),
      INT_DATA_IN(15 downto 0)      => data1,
      INT_DATA_IN(31 downto 16)     => (others => '0'),
      INT_DATA_IN(47 downto 32)     => data2,
      INT_DATA_IN(127 downto 48)    => (others => '0'),
      INT_PACKET_NUM_IN(2 downto 0) => number1,
      INT_PACKET_NUM_IN(5 downto 3) => "000",
      INT_PACKET_NUM_IN(8 downto 6) => number2,
      INT_PACKET_NUM_IN(23 downto 9)=> (others => '0'),
      INT_READ_OUT(0)               => read1,
      INT_READ_OUT(1)               => dummy(0),
      INT_READ_OUT(2)               => read2,
      INT_READ_OUT(3)               => dummy(1),
      INT_READ_OUT(7 downto 4)      => dummy(6 downto 3),
      ctrl                          => (others => '0')
      );


  the_tx_control : trb_net16_tx_control
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

      REQUEST_RETRANSMIT_IN          => '0',
      REQUEST_POSITION_IN            => (others => '0'),

      START_RETRANSMIT_IN            => '0',
      START_POSITION_IN              => (others => '0'),

      SEND_LINK_RESET_IN             => '0',
      TX_ALLOW_IN                    => tx_allow_in,

      DEBUG_OUT                      => open
      );



  THE_RX_CONTROL : trb_net16_rx_packets
    port map(
      -- Resets
      RESET_IN              => reset,
      QUAD_RST_IN           => reset_async,
      -- data stream from SerDes
      CLK_IN                => clk25,
      RX_ALLOW_IN           => tx_allow_in,
      RX_DATA_IN            => tx_data_out(7 downto 0),
      RX_K_IN               => tx_k_out,
      -- media interface
      SYSCLK_IN             => clk,
      MED_DATA_OUT          => open,
      MED_DATAREADY_OUT     => open,
      MED_READ_IN           => '1',
      MED_PACKET_NUM_OUT    => open,
      -- reset handling
      SEND_RESET_WORDS_OUT  => open,
      MAKE_TRBNET_RESET_OUT => open,
      -- Status signals
      PACKET_TIMEOUT_OUT    => open,
      -- Debug signals
      BSM_OUT               => open,
      DBG_OUT               => open
    );




end architecture;