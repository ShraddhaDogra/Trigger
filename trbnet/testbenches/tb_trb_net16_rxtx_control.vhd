library ieee;
use ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity rxtxtb is
end entity;

architecture arch of rxtxtb is

  component trb_net16_tx_control is
    port(
      TXCLK_IN                       : in  std_logic;
      RXCLK_IN                       : in  std_logic;
      SYSCLK_IN                      : in  std_logic;
      RESET_IN                       : in  std_logic;

      TX_DATA_IN                     : in  std_logic_vector(15 downto 0);
      TX_PACKET_NUMBER_IN            : in  std_logic_vector(2 downto 0);
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

  component trb_net16_rx_control is
    port(
      RESET_IN                       : in  std_logic;
      QUAD_RST_IN                    : in  std_logic;
      -- raw data from SerDes receive path
      CLK_IN                         : in  std_logic;
      RX_DATA_IN                     : in  std_logic_vector(7 downto 0);
      RX_K_IN                        : in  std_logic;
      RX_CV_IN                       : in  std_logic;
      RX_DISP_ERR_IN                 : in  std_logic;
      RX_ALLOW_IN                    : in  std_logic;
      -- media interface
      SYSCLK_IN                      : in  std_logic; -- 100MHz master clock
      MED_DATA_OUT                   : out std_logic_vector(15 downto 0);
      MED_DATAREADY_OUT              : out std_logic;
      MED_READ_IN                    : in  std_logic;
      MED_PACKET_NUM_OUT             : out std_logic_vector(2 downto 0);
      -- request retransmission in case of error while receiving
      REQUEST_RETRANSMIT_OUT         : out std_logic; -- one pulse
      REQUEST_POSITION_OUT           : out std_logic_vector( 7 downto 0);
      -- command decoding
      START_RETRANSMIT_OUT           : out std_logic;
      START_POSITION_OUT             : out std_logic_vector( 7 downto 0);
      -- reset handling
      SEND_RESET_WORDS_OUT           : out std_logic;
      MAKE_TRBNET_RESET_OUT          : out std_logic;
      -- Status signals
      PACKET_TIMEOUT_OUT             : out std_logic;
      ENABLE_CORRECTION_IN           : in  std_logic;
      -- Debugging
      DEBUG_OUT                      : out std_logic_vector(31 downto 0)
      );
  end component;


  component error_generator is
    port(
      RXCLK_IN             : in  std_logic;
      RESET_IN             : in  std_logic;

      RX1_DATA_IN          : in  std_logic_vector(7 downto 0);
      RX1_DATA_OUT         : out std_logic_vector(7 downto 0);

      RX2_DATA_IN          : in  std_logic_vector(7 downto 0);
      RX2_DATA_OUT         : out std_logic_vector(7 downto 0);

      RX1_K_IN             : in  std_logic;
      RX1_K_OUT            : out std_logic;

      RX2_K_IN             : in  std_logic;
      RX2_K_OUT            : out std_logic;

      RX1_CV_IN            : in  std_logic;
      RX1_CV_OUT           : out std_logic;

      RX2_CV_IN            : in  std_logic;
      RX2_CV_OUT           : out std_logic
      );
  end component;

  component error_check is
    port(
      RXCLK_IN             : in  std_logic;
      RESET_IN             : in  std_logic;

      DATA_TX_IN             : in  std_logic_vector(15 downto 0);
      DATA_TX_DATAREADY_IN   : in  std_logic;
      DATA_TX_READ_IN        : in  std_logic;
      DATA_RX_IN             : in  std_logic_vector(15 downto 0);
      DATA_RX_VALID_IN       : in  std_logic

      );
  end component;


  signal clk                     : std_logic := '1';
  signal clk251                  : std_logic := '1';
  signal clk252                  : std_logic := '1';
  signal reset                   : std_logic := '1';

  signal tx1_data_in             : std_logic_vector(15 downto 0) := (others => '0');
  signal tx1_write_in            : std_logic := '0';
  signal tx1_read_out            : std_logic := '0';
  signal tx2_data_in             : std_logic_vector(15 downto 0) := (others => '0');
  signal tx2_write_in            : std_logic := '0';
  signal tx2_read_out            : std_logic := '0';

  signal tx1_data_out            : std_logic_vector( 7 downto 0) := (others => '0');
  signal tx1_k_out               : std_logic := '0';
  signal tx2_data_out            : std_logic_vector( 7 downto 0) := (others => '0');
  signal tx2_k_out               : std_logic := '0';

  signal rx1_data_in             : std_logic_vector( 7 downto 0) := (others => '0');
  signal rx1_k_in                : std_logic := '0';
  signal rx1_cv_in               : std_logic := '0';
  signal rx1_allow_in            : std_logic := '0';
  signal rx2_data_in             : std_logic_vector( 7 downto 0) := (others => '0');
  signal rx2_k_in                : std_logic := '0';
  signal rx2_cv_in               : std_logic := '0';
  signal rx2_allow_in            : std_logic := '0';

  signal tx1_packet_num_in       : std_logic_vector(2 downto 0);
  signal tx2_packet_num_in       : std_logic_vector(2 downto 0);

  signal tx1_request_retransmit_in   : std_logic := '0';
  signal tx1_request_position_in     : std_logic_vector( 7 downto 0) := (others => '0');
  signal tx1_start_retransmit_in     : std_logic := '0';
  signal tx1_start_position_in       : std_logic_vector( 7 downto 0) := (others => '0');
  signal tx1_send_link_reset_in      : std_logic := '0';
  signal tx2_request_retransmit_in   : std_logic := '0';
  signal tx2_request_position_in     : std_logic_vector( 7 downto 0) := (others => '0');
  signal tx2_start_retransmit_in     : std_logic := '0';
  signal tx2_start_position_in       : std_logic_vector( 7 downto 0) := (others => '0');
  signal tx2_send_link_reset_in      : std_logic := '0';

  signal tx1_allow_in             : std_logic := '0';
  signal tx2_allow_in             : std_logic := '0';

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
  signal dummy                   : std_logic_vector(63 downto 0);

  signal rxdata1      : std_logic_vector(15 downto 0);
  signal rxdata2      : std_logic_vector(15 downto 0);
  signal rxdataready1 : std_logic;
  signal rxdataready2 : std_logic;

  signal rxdata2_in      : std_logic_vector(15 downto 0);
  signal rxdataready2_in : std_logic;
  signal rxpacketnum2_in : std_logic_vector(2 downto 0);
  signal rxread2_out     : std_logic;

  signal count1_retransmission : std_logic_vector(31 downto 0) := (others => '0');
  signal count2_retransmission : std_logic_vector(31 downto 0) := (others => '0');

begin

---------------------------------------------------------------------
--Clock & Reset
---------------------------------------------------------------------

  proc_clk251 : process
    begin
      wait for 20 ns;
      clk251 <= not clk251;
    end process;

  proc_clk252 : process
    begin
      wait for 5 ns;
      while 1 = 1 loop
        wait for 20 ns;
        clk252 <= not clk252;
      end loop;
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


---------------------------------------------------------------------
--control from LSM
---------------------------------------------------------------------
  process
    begin
      tx1_allow_in          <= '0';
      tx2_allow_in          <= '0';
      rx1_allow_in          <= '0';
      rx2_allow_in          <= '0';
      tx1_send_link_reset_in<= '0';
      wait for 200 ns;
      wait until rising_edge(clk); wait for 1 ns;
      rx1_allow_in          <= '1';
      rx2_allow_in          <= '1';
      wait for 3050 ns;
      wait until rising_edge(clk); wait for 1 ns;
      tx1_allow_in          <= '1';
      tx2_allow_in          <= '1';
      wait;
    end process;


---------------------------------------------------------------------
-- TX control
---------------------------------------------------------------------

  uut_tx1 : trb_net16_tx_control
    port map(
      TXCLK_IN                       => clk251,
      RXCLK_IN                       => clk252,
      SYSCLK_IN                      => clk,
      RESET_IN                       => reset,

      TX_DATA_IN                     => tx1_data_in,
      TX_PACKET_NUMBER_IN            => tx1_packet_num_in,
      TX_WRITE_IN                    => tx1_write_in,
      TX_READ_OUT                    => tx1_read_out,

      TX_DATA_OUT                    => tx1_data_out,
      TX_K_OUT                       => tx1_k_out,

      REQUEST_RETRANSMIT_IN          => tx1_request_retransmit_in,
      REQUEST_POSITION_IN            => tx1_request_position_in,

      START_RETRANSMIT_IN            => tx1_start_retransmit_in,
      START_POSITION_IN              => tx1_start_position_in,

      SEND_LINK_RESET_IN             => tx1_send_link_reset_in,
      TX_ALLOW_IN                    => tx1_allow_in,

      DEBUG_OUT                      => open
      );

  uut_tx2 : trb_net16_tx_control
    port map(
      TXCLK_IN                       => clk252,
      RXCLK_IN                       => clk251,
      SYSCLK_IN                      => clk,
      RESET_IN                       => reset,

      TX_DATA_IN                     => tx2_data_in,
      TX_PACKET_NUMBER_IN            => tx2_packet_num_in,
      TX_WRITE_IN                    => tx2_write_in,
      TX_READ_OUT                    => tx2_read_out,

      TX_DATA_OUT                    => tx2_data_out,
      TX_K_OUT                       => tx2_k_out,

      REQUEST_RETRANSMIT_IN          => tx2_request_retransmit_in,
      REQUEST_POSITION_IN            => tx2_request_position_in,

      START_RETRANSMIT_IN            => tx2_start_retransmit_in,
      START_POSITION_IN              => tx2_start_position_in,

      SEND_LINK_RESET_IN             => tx2_send_link_reset_in,
      TX_ALLOW_IN                    => tx2_allow_in,

      DEBUG_OUT                      => open
      );



---------------------------------------------------------------------
--RX control
---------------------------------------------------------------------
  uut_rx1 : trb_net16_rx_control
    port map(
      RESET_IN                       => reset,
      QUAD_RST_IN                    => reset,
      -- raw data from SerDes receive path
      CLK_IN                         => clk252,
      RX_DATA_IN                     => rx1_data_in,
      RX_K_IN                        => rx1_k_in,
      RX_CV_IN                       => rx1_cv_in,
      RX_DISP_ERR_IN                 => '0',
      RX_ALLOW_IN                    => rx1_allow_in,
      -- media interface
      SYSCLK_IN                      => clk,
      MED_DATA_OUT                   => open,
      MED_DATAREADY_OUT              => open,
      MED_READ_IN                    => '1',
      MED_PACKET_NUM_OUT             => open,
      -- request retransmission in case of error while receiving
      REQUEST_RETRANSMIT_OUT         => tx1_request_retransmit_in,
      REQUEST_POSITION_OUT           => tx1_request_position_in,
      -- command decoding
      START_RETRANSMIT_OUT           => tx1_start_retransmit_in,
      START_POSITION_OUT             => tx1_start_position_in,
      -- reset handling
      SEND_RESET_WORDS_OUT           => open,
      MAKE_TRBNET_RESET_OUT          => open,
      -- Status signals
      PACKET_TIMEOUT_OUT             => open,
      ENABLE_CORRECTION_IN           => '1',
      -- Debugging
      DEBUG_OUT                      => open
      );

  uut_rx2 : trb_net16_rx_control
    port map(
      RESET_IN                       => reset,
      QUAD_RST_IN                    => reset,
      -- raw data from SerDes receive path
      CLK_IN                         => clk251,
      RX_DATA_IN                     => rx2_data_in,
      RX_K_IN                        => rx2_k_in,
      RX_CV_IN                       => rx2_cv_in,
      RX_DISP_ERR_IN                 => '0',
      RX_ALLOW_IN                    => rx2_allow_in,
      -- media interface
      SYSCLK_IN                      => clk,
      MED_DATA_OUT                   => rxdata2_in,
      MED_DATAREADY_OUT              => rxdataready2_in,
      MED_READ_IN                    => rxread2_out,
      MED_PACKET_NUM_OUT             => rxpacketnum2_in,
      -- request retransmission in case of error while receiving
      REQUEST_RETRANSMIT_OUT         => tx2_request_retransmit_in,
      REQUEST_POSITION_OUT           => tx2_request_position_in,
      -- command decoding
      START_RETRANSMIT_OUT           => tx2_start_retransmit_in,
      START_POSITION_OUT             => tx2_start_position_in,
      -- reset handling
      SEND_RESET_WORDS_OUT           => open,
      MAKE_TRBNET_RESET_OUT          => open,
      -- Status signals
      PACKET_TIMEOUT_OUT             => open,
      ENABLE_CORRECTION_IN           => '1',
      -- Debugging
      DEBUG_OUT                      => open
      );

---------------------------------------------------------------------
--Media Simulation
---------------------------------------------------------------------

rx1_data_in <= transport tx2_data_out after 200 ns;
rx1_k_in    <= transport tx2_k_out after 200 ns;
rx1_cv_in   <= '0';

-- rx2_data_in <= transport tx1_data_out after 200 ns;
-- rx2_k_in    <= transport tx1_k_out after 200 ns;
-- rx2_cv_in   <= '0', '1' after 4400 ns, '0' after 4440 ns;

THE_ERROR : error_generator
    port map(
      RXCLK_IN     => clk251,
      RESET_IN     => reset,

      RX1_DATA_IN  => tx1_data_out,
      RX1_DATA_OUT => rx2_data_in,
      RX1_K_IN     => tx1_k_out,
      RX1_K_OUT    => rx2_k_in,
      RX1_CV_IN    => '0',
      RX1_CV_OUT   => rx2_cv_in,

      RX2_DATA_IN  => x"00",
      RX2_DATA_OUT => open,
      RX2_K_IN     => '0',
      RX2_K_OUT    => open,
      RX2_CV_IN    => '0',
      RX2_CV_OUT   => open
      );

process(clk)
  begin
    if rising_edge(clk) then
      if tx1_request_retransmit_in = '1' then
        count1_retransmission <= count1_retransmission + 1;
      end if;
      if tx2_request_retransmit_in = '1' then
        count2_retransmission <= count2_retransmission + 1;
      end if;
    end if;
  end process;

---------------------------------------------------------------------
--Data input 1
---------------------------------------------------------------------

  process(clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          number1 <= "100";
          dataready1 <= '0';
          toggle1    <= '0';
          counter1   <= (others => '0');
        else
          if ((counter1 < 199 and toggle1 = '1')  or (counter1 < 149 and toggle1 = '0')) or
             (((counter1 < 200 and toggle1 = '1')  or (counter1 < 150 and toggle1 = '0')) and read1 = '0') then
            dataready1 <= '1';
            if read1 = '1' and dataready1 = '1' then
              counter1 <= counter1 + 1;
            end if;
          else
            dataready1 <= '0';
            if counter1 = 1530 then
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

  data1 <= (counter1(7 downto 6) & "00" & counter1(3 downto 0) & counter1(7 downto 6) & "00" & counter1(3 downto 0));


---------------------------------------------------------------------
-- Data input 2
---------------------------------------------------------------------

  data2 <= (counter2(7 downto 6) & "00" & counter2(3 downto 0) & counter2(7 downto 6) & "00" & counter2(3 downto 0));

  process(clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          number2    <= "100";
          dataready2 <= '0';
          toggle2    <= '0';
          counter2   <= (others => '0');
        else
          if ((counter2 < 24 and toggle2 = '1') or (counter2 < 19 and toggle2 = '0')) or
             (((counter2 < 25 and toggle2 = '1') or (counter2 < 20 and toggle2 = '0')) and read2 = '0') then
            dataready2 <= '1';
            if read2 = '1' and dataready2 = '1' then
              counter2 <= counter2 + 1;
            end if;
          else
            dataready2 <= '0';
            if counter2 = 2000 then
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


---------------------------------------------------------------------
--Sender Multiplexer
---------------------------------------------------------------------

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
      MED_DATAREADY_OUT  => tx1_write_in,
      MED_DATA_OUT       => tx1_data_in,
      MED_PACKET_NUM_OUT => tx1_packet_num_in,
      MED_READ_IN        => tx1_read_out,
      -- Internal direction port
      INT_DATA_OUT       => open,
      INT_PACKET_NUM_OUT => open,
      INT_DATAREADY_OUT  => open,
      INT_READ_IN        => (others => '1'),
      INT_DATAREADY_IN(0)           => dataready2,
      INT_DATAREADY_IN(1)           => '0',
      INT_DATAREADY_IN(2)           => dataready1,
      INT_DATAREADY_IN(7 downto 3)  => (others => '0'),
      INT_DATA_IN(15 downto 0)      => data2,
      INT_DATA_IN(31 downto 16)     => (others => '0'),
      INT_DATA_IN(47 downto 32)     => data1,
      INT_DATA_IN(127 downto 48)    => (others => '0'),
      INT_PACKET_NUM_IN(2 downto 0) => number2,
      INT_PACKET_NUM_IN(5 downto 3) => "000",
      INT_PACKET_NUM_IN(8 downto 6) => number1,
      INT_PACKET_NUM_IN(23 downto 9)=> (others => '0'),
      INT_READ_OUT(0)               => read2,
      INT_READ_OUT(1)               => dummy(0),
      INT_READ_OUT(2)               => read1,
      INT_READ_OUT(3)               => dummy(1),
      INT_READ_OUT(7 downto 4)      => dummy(6 downto 3),
      ctrl                          => (others => '0')
      );

---------------------------------------------------------------------
--Receiver Multiplexer
---------------------------------------------------------------------

  the_test_rx_mux : trb_net16_io_multiplexer
    generic map (
      USE_INPUT_SBUF => (others => c_NO)
      )
    port map(
      --  Misc
      CLK    => clk,
      RESET  => reset,
      CLK_EN => '1',
      --  Media direction port
      MED_DATAREADY_IN   => rxdataready2_in,
      MED_DATA_IN        => rxdata2_in,
      MED_PACKET_NUM_IN  => rxpacketnum2_in,
      MED_READ_OUT       => rxread2_out,
      MED_DATAREADY_OUT  => open,
      MED_DATA_OUT       => open,
      MED_PACKET_NUM_OUT => tx2_packet_num_in,
      MED_READ_IN        => '1',
      -- Internal direction port
      INT_DATA_OUT(15 downto 0) => rxdata2,
      INT_DATA_OUT(31 downto 16)=> rxdata1,
      INT_DATA_OUT(63 downto 32)=> dummy(40 downto 9),
      INT_PACKET_NUM_OUT        => open,
      INT_DATAREADY_OUT(0)      => rxdataready2,
      INT_DATAREADY_OUT(1)      => rxdataready1,
      INT_DATAREADY_OUT(3 downto 2) => dummy(8 downto 7),
      INT_READ_IN        => (others => '1'),
      INT_DATAREADY_IN   => (others => '0'),
      INT_DATA_IN        => (others => '0'),
      INT_PACKET_NUM_IN  => (others => '0'),
      INT_READ_OUT       => open,
      ctrl               => (others => '0')
      );


err_check1 : error_check
port map(
	RXCLK_IN             => clk,
	RESET_IN             => reset,

	DATA_TX_IN            => data1,
	DATA_TX_DATAREADY_IN  => dataready1,
	DATA_TX_READ_IN       => read1,
	DATA_RX_IN            => rxdata1,
	DATA_RX_VALID_IN      => rxdataready1

  );

err_check2 : error_check
port map(
	RXCLK_IN             => clk,
	RESET_IN             => reset,

	DATA_TX_IN            => data2,
	DATA_TX_DATAREADY_IN  => dataready2,
	DATA_TX_READ_IN       => read2,
	DATA_RX_IN            => rxdata2,
	DATA_RX_VALID_IN      => rxdataready2

  );

-- --Data 1 input
--   process
--     begin
--       tx1_data_in <= (others => '0');
--       tx1_write_in <= '0';
--       wait for 2300 ns;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"1001";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"2002";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_write_in <= '0';
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"3003";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"4004";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_write_in <= '0';
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"5005";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"6006";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"7007";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"8008";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"9009";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"a00a";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_write_in <= '0';
--       wait for 1500 ns;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"b00b";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"c00c";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"d00d";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"e00e";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= x"f00f";
--       tx1_write_in <= '1';
--       if tx1_read_out = '0' then wait until tx1_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx1_data_in <= (others => '0');
--       tx1_write_in <= '0';
--       wait;
--     end process;
--
--
--   process
--     begin
--       tx2_data_in <= (others => '0');
--       tx2_write_in <= '0';
--       wait for 2300 ns;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx2_data_in <= x"1001";
--       tx2_write_in <= '1';
--       if tx2_read_out = '0' then wait until tx2_read_out = '1'; end if;
--       wait until rising_edge(clk); wait for 1 ns;
--       tx2_data_in <= (others => '0');
--       tx2_write_in <= '0';
--       wait;
--     end process;


end architecture;



