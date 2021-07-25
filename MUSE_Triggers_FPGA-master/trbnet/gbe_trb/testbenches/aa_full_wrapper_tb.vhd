LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.math_real.all;
USE ieee.numeric_std.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb_net16_hub_func.all;

use work.trb_net_gbe_components.all;
use work.trb_net_gbe_protocols.all;

ENTITY aa_full_wrapper_tb IS
END aa_full_wrapper_tb;

ARCHITECTURE behavior OF aa_full_wrapper_tb IS
	signal clk_sys, clk_125, reset, gsr_n, trigger : std_logic := '0';
	signal busip0, busip1                          : CTRLBUS_RX;

	signal data : std_logic_vector(7 downto 0);
	signal dv, sop, eop, ready : std_logic;

	signal data_v : std_logic_vector(4 * 8 - 1 downto 0);
	signal dv_v, sop_v, eop_v, ready_v : std_logic_vector(3 downto 0);

begin
	uut : entity work.gbe_wrapper
		generic map(
			DO_SIMULATION             => 1,
			INCLUDE_DEBUG             => 0,
			USE_INTERNAL_TRBNET_DUMMY => 0,
			USE_EXTERNAL_TRBNET_DUMMY => 0,
			RX_PATH_ENABLE            => 1,
			FIXED_SIZE_MODE           => 1,
			INCREMENTAL_MODE          => 0,
			FIXED_SIZE                => 100, --13750,
			FIXED_DELAY_MODE          => 1,
			UP_DOWN_MODE              => 1,
			UP_DOWN_LIMIT             => 1000,
			FIXED_DELAY               => 10,
			NUMBER_OF_GBE_LINKS       => 4,
			LINKS_ACTIVE              => "1111",
			LINK_HAS_PING             => "1111",
			LINK_HAS_ARP              => "1111",
			LINK_HAS_DHCP             => "1111",
			LINK_HAS_READOUT          => "1100",
			LINK_HAS_SLOWCTRL         => "0000",
			LINK_HAS_FWD              => "1111"
		)
		port map(
			CLK_SYS_IN               => clk_sys,
			CLK_125_IN               => clk_125,
			RESET                    => reset,
			GSR_N                    => gsr_n,
			SD_PRSNT_N_IN            => (others => '0'),
			SD_LOS_IN                => (others => '0'),
			SD_TXDIS_OUT             => open,
			TRIGGER_IN               => trigger,
			CTS_NUMBER_IN            => (others => '0'),
			CTS_CODE_IN              => (others => '0'),
			CTS_INFORMATION_IN       => (others => '0'),
			CTS_READOUT_TYPE_IN      => (others => '0'),
			CTS_START_READOUT_IN     => '0',
			CTS_DATA_OUT             => open,
			CTS_DATAREADY_OUT        => open,
			CTS_READOUT_FINISHED_OUT => open,
			CTS_READ_IN              => '0',
			CTS_LENGTH_OUT           => open,
			CTS_ERROR_PATTERN_OUT    => open,
			FEE_DATA_IN              => (others => '0'),
			FEE_DATAREADY_IN         => '0',
			FEE_READ_OUT             => open,
			FEE_STATUS_BITS_IN       => (others => '0'),
			FEE_BUSY_IN              => '0',
			MY_TRBNET_ADDRESS_IN	 => x"e001",
			MC_UNIQUE_ID_IN          => (others => '0'),
			GSC_CLK_IN               => clk_sys,
			GSC_INIT_DATAREADY_OUT   => open,
			GSC_INIT_DATA_OUT        => open,
			GSC_INIT_PACKET_NUM_OUT  => open,
			GSC_INIT_READ_IN         => '1',
			GSC_REPLY_DATAREADY_IN   => '1',
			GSC_REPLY_DATA_IN        => x"abcd",
			GSC_REPLY_PACKET_NUM_IN  => "111",
			GSC_REPLY_READ_OUT       => open,
			GSC_BUSY_IN              => '0',

FWD_DATA_IN => data_v,
FWD_DATA_VALID_IN => dv_v,
FWD_SOP_IN => sop_v,
FWD_EOP_IN => eop_v,
FWD_READY_OUT => ready_v,
FWD_FULL_OUT => open,

			-- IP configuration
			BUS_IP_RX                => busip0,
			BUS_IP_TX                => open,
			-- Registers config
			BUS_REG_RX               => busip1,
			BUS_REG_TX               => open,
			MAKE_RESET_OUT           => open,
			DEBUG_OUT                => open
		);

	process
	begin
		clk_sys <= '1';
		wait for 5 ns;
		clk_sys <= '0';
		wait for 5 ns;
	end process;

	process
	begin
		clk_125 <= '1';
		wait for 4 ns;
		clk_125 <= '0';
		wait for 4 ns;
	end process;

	process
	begin
		reset <= '1';
		gsr_n <= '0';
		wait for 100 ns;
		reset <= '0';
		gsr_n <= '1';
		wait for 20 us;

		--trigger <= '1';

		--		for i in 0 to 10000 loop
		--			trigger <= '1';
		--			wait for 100 ns;
		--			trigger <= '0';
		--			wait for 10 us;
		--		end loop;

		wait;
	end process;



dv_v <= dv & dv & dv & dv;
sop_v <= sop & sop & sop & sop;
eop_v <= eop & eop & eop & eop;
data_v <= data & data & data & data;


process
begin
  data <= x"00";
  dv <= '0';
  sop <= '0';
  eop <= '0';

  wait for 20 us;
  wait until rising_edge(clk_sys);
  sop <= '1';
  dv <= '1';
  data <= x"11";
  wait until rising_edge(clk_sys);
  sop <= '0';
  for i in 0 to 9 loop
    data <= data + x"1";
    wait until rising_edge(clk_sys);
  end loop;
  data <= data + x"1";
  eop <= '1';
  wait until rising_edge(clk_sys);
  eop <= '0';
  dv <= '0';




  wait;
end process;



end; 