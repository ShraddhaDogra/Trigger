library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.StdTypes.all;
use work.TRBSimulationPkg.all;


entity PixCtrlTest is
end entity PixCtrlTest;

architecture simulation of PixCtrlTest is
	
	component PixelControl
		generic(
			fpga_clk_speed : integer := 1e8;
			spi_clk_speed  : integer := 1e4
		);
		port(
			clk                  : in  std_logic; --clock
			reset                : in  std_logic; --reset
			mupixslctrl          : out MupixSlowControl;
			ctrl_dout            : in  std_logic; --serial data from mupix
			SLV_READ_IN          : in  std_logic;
			SLV_WRITE_IN         : in  std_logic;
			SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
			SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
			SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
			SLV_ACK_OUT          : out std_logic;
			SLV_NO_MORE_DATA_OUT : out std_logic;
			SLV_UNKNOWN_ADDR_OUT : out std_logic
		);
	end component PixelControl;
	
	component MupixShiftReg
		generic(
			pixeldac_shift_length : integer := 64
		);
		port(
			clk1 : in  std_logic;
			clk2 : in  std_logic;
			sin  : in  std_logic;
			sout : out std_logic);
	end component MupixShiftReg;
	
	signal clk : std_logic;
	signal reset : std_logic := '0';
	signal sout : std_logic := '0';
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
	constant c_shiftregister_length : integer := 80;
	constant c_time_per_word : time := 32*clk_period*1e8/1e7;
	
begin
	
	dut : entity work.PixelControl
		generic map(
			fpga_clk_speed => 1e8,
			spi_clk_speed  => 1e7
		)
		port map(
			clk                  => clk,
			reset                => reset,
			ctrl_dout            => sout,
			mupixslctrl          => mupix_ctrl,
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
				pixeldac_shift_length => c_shiftregister_length
			)
			port map(
				clk1 => mupix_ctrl.clk1,
				clk2 => mupix_ctrl.clk2,
				sin  => mupix_ctrl.sin,
				sout => sout
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
		--test control through trb slow control
--		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"00000011",x"0083");
--		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"00000013",x"0083");
--		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"00000014",x"0083");
--		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"00000000",x"0083");
		--test programming with data from FIFO via FPGA state machine
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, std_logic_vector(to_unsigned(c_shiftregister_length, 16)) & x"0000", x"0083");
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"AAAAAAAA",x"0080");
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"BBBBBBBB",x"0080");
		wait for 3*c_time_per_word;
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"CCCC0000",x"0080");
		--test of crc checksum computation
		wait for 1.5*c_time_per_word;
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, std_logic_vector(to_unsigned(c_shiftregister_length, 16)) & x"0060", x"0083");
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, std_logic_vector(to_unsigned(c_shiftregister_length, 16)) & x"0000", x"0083");
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"AAAAAAAA",x"0080");
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"BBBBBBBB",x"0080");
		TRBRegisterWrite(SLV_WRITE_IN, SLV_DATA_IN, SLV_ADDR_IN, x"CCCC0000",x"0080");
		
		wait;
	end process stimulus_gen;
	
	
end architecture simulation;
