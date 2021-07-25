library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.StdTypes.all;
use work.TRBSimulationPkg.all;


entity PixCtrlTest is
end entity PixCtrlTest;

architecture simulation of PixCtrlTest is
	
	component PixCtr
		generic(
			fpga_clk_speed : integer := 1e8;
			spi_clk_speed  : integer := 1e4
		);
		port(
			clk                  : in  std_logic;
			reset                : in  std_logic;
			sout_c_from_mupix    : in  std_logic;
			sout_d_from_mupix    : in  std_logic;
			mupix_ctrl           : out MupixSlowControl;
			SLV_READ_IN          : in  std_logic;
			SLV_WRITE_IN         : in  std_logic;
			SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
			SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
			SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
			SLV_ACK_OUT          : out std_logic;
			SLV_NO_MORE_DATA_OUT : out std_logic;
			SLV_UNKNOWN_ADDR_OUT : out std_logic
		);
	end component PixCtr;
	
	component MupixShiftReg
		generic(
			pixeldac_shift_length : integer := 64;
			chipdac_shift_length  : integer := 16
		);
		port(
			ck_c   : in  std_logic;
			ck_d   : in  std_logic;
			sin    : in  std_logic;
			sout_c : out std_logic;
			sout_d : out std_logic
		);
	end component MupixShiftReg;
	
	signal clk : std_logic;
	signal reset : std_logic := '0';
	signal sout_c_from_mupix : std_logic := '0';
	signal sout_d_from_mupix : std_logic := '0';
	signal mupix_ctrl : MupixSlowControl;
	signal SLV_READ_IN : std_logic := '0';
	signal SLV_WRITE_IN : std_logic := '0';
	signal SLV_DATA_OUT : std_logic_vector(31 downto 0);
	signal SLV_DATA_IN : std_logic_vector(31 downto 0) := (others => '0');
	signal SLV_ADDR_IN : std_logic_vector(15 downto 0) := (others => '0');
	signal SLV_ACK_OUT : std_logic;
	signal SLV_NO_MORE_DATA_OUT : std_logic;
	signal SLV_UNKNOWN_ADDR_OUT : std_logic;
	
	constant clk_period : time := 10 ns;
	
begin
	
	dut : entity work.PixCtr
		generic map(
			fpga_clk_speed => 1e8,
			spi_clk_speed  => 5e7
		)
		port map(
			clk                  => clk,
			reset                => reset,
			sout_c_from_mupix    => sout_c_from_mupix,
			sout_d_from_mupix    => sout_d_from_mupix,
			mupix_ctrl           => mupix_ctrl,
			SLV_READ_IN          => SLV_READ_IN,
			SLV_WRITE_IN         => SLV_WRITE_IN,
			SLV_DATA_OUT         => SLV_DATA_OUT,
			SLV_DATA_IN          => SLV_DATA_IN,
			SLV_ADDR_IN          => SLV_ADDR_IN,
			SLV_ACK_OUT          => SLV_ACK_OUT,
			SLV_NO_MORE_DATA_OUT => SLV_NO_MORE_DATA_OUT,
			SLV_UNKNOWN_ADDR_OUT => SLV_UNKNOWN_ADDR_OUT
		);
		
		mupix : entity work.MupixShiftReg
			generic map(
				pixeldac_shift_length => 64,
				chipdac_shift_length  => 16
			)
			port map(
				ck_c   => mupix_ctrl.ck_c,
				ck_d   => mupix_ctrl.ck_d,
				sin    => mupix_ctrl.sin,
				sout_c => sout_c_from_mupix,
				sout_d => sout_d_from_mupix
			);
		
	clk_gen : process is
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process clk_gen;
	
	stimulus_gen : process is
	begin
		wait for 100 ns;
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"004F0000",x"0083");
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"BBBBBBBB",x"0080");
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"AAAAAAAA",x"0080");
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"CCCCCCCC",x"0080");
		wait;
	end process stimulus_gen;
	
	
end architecture simulation;
