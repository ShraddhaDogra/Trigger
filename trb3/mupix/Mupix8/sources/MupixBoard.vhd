-------------------------------------------------------------------------------
--MuPix Block for readout/controll of MuPix3 Sensorboard
--T. Weber, University Mainz
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb3_components.all;

use work.StdTypes.all;

entity MupixBoard is
  port(
    --Clock signal
    clk                  : in  std_logic;
    fast_clk             : in  std_logic;
    reset                : in  std_logic;
    
    --slow control signals
    testpulse           :  out std_logic; --generate injection pulse
    ctrl_din            :  out std_logic; --serial data to mupix
    ctrl_clk1           :  out std_logic; --slow control clk1
    ctrl_clk2           :  out std_logic; --slow control clk2
    ctrl_ld             :  out std_logic; --slow control load latched data
    ctrl_dout           :  in  std_logic; --serial data from mupix
    ctrl_rb             :  out std_logic; --slow control readback??
    spi_dout_adc        :  in  std_logic; --adc serial data from board
    spi_dout_dac        :  in  std_logic; --dac serial data from board
    dac4_dout           :  in  std_logic; --serial data in from threshold dac
    spi_clk             :  out std_logic; --serial clock
    spi_din             :  out std_logic; --serial data out
    spi_ld_tmp_dac      :  out std_logic; --load temperature dac 
    spi_cs_adc          :  out std_logic; --load adc 
    spi_ld_thres        :  out std_logic; --load threshold and injection dac
    --slow data signals
    hitbus              :  in  std_logic; --hitbus signal
    hit                 :  in  std_logic; --hit signal (replacement for priout?)
    ldcol               :  out std_logic; --load column
    rdcol               :  out std_logic; --read column
    pull_down           :  out std_logic; --pull down
    ldpix               :  out std_logic; --load pixel
    --fast data signals
    clkref              :  out  std_logic; --reference clock
    clkext              :  out  std_logic; --external clock (difference to first one?)
    syncres             :  out  std_logic; --sync something
    trigger             :   in  std_logic; --external trigger
    --data
    data1_P             :   in  std_logic; --data 1
    data1_N             :   in  std_logic;
    data2_P             :   in  std_logic; --data 2
    data2_N             :   in  std_logic;
    data3_P             :   in  std_logic; --data 3
    data3_N             :   in  std_logic;
    data4_P             :   in  std_logic; --this channel is muxed version of other three
    data4_N             :   in  std_logic;

    --resets
    timestampreset_in    : in std_logic;  --time stamp reset
    eventcounterreset_in : in std_logic;  --event number reset 
    
    --TRB trigger connections
    TIMING_TRG_IN              : in std_logic;
    LVL1_TRG_DATA_VALID_IN     : in std_logic;
    LVL1_VALID_TIMING_TRG_IN   : in std_logic;
    LVL1_VALID_NOTIMING_TRG_IN : in std_logic;
    LVL1_INVALID_TRG_IN        : in std_logic;
    LVL1_TRG_TYPE_IN           : in std_logic_vector(3 downto 0);
    LVL1_TRG_NUMBER_IN         : in std_logic_vector(15 downto 0);
    LVL1_TRG_CODE_IN           : in std_logic_vector(7 downto 0);
    LVL1_TRG_INFORMATION_IN    : in std_logic_vector(23 downto 0);
    LVL1_INT_TRG_NUMBER_IN     : in std_logic_vector(15 downto 0);

    --TRB data connections
    FEE_TRG_RELEASE_OUT     : out std_logic;
    FEE_TRG_STATUSBITS_OUT  : out std_logic_vector(31 downto 0);
    FEE_DATA_OUT            : out std_logic_vector(31 downto 0);
    FEE_DATA_WRITE_OUT      : out std_logic;
    FEE_DATA_FINISHED_OUT   : out std_logic;
    FEE_DATA_ALMOST_FULL_IN : in  std_logic;

	--TRB slow control connections
    REGIO_ADDR_IN          : in  std_logic_vector(15 downto 0);
    REGIO_DATA_IN          : in  std_logic_vector(31 downto 0);
    REGIO_DATA_OUT         : out std_logic_vector(31 downto 0);
    REGIO_READ_ENABLE_IN   : in  std_logic;
    REGIO_WRITE_ENABLE_IN  : in  std_logic;
    REGIO_TIMEOUT_IN       : in  std_logic;
    REGIO_DATAREADY_OUT    : out std_logic;
    REGIO_WRITE_ACK_OUT    : out std_logic;
    REGIO_NO_MORE_DATA_OUT : out std_logic;
    REGIO_UNKNOWN_ADDR_OUT : out std_logic
    );
end MupixBoard;


architecture Behavioral of MupixBoard is

	component MupixBoardInterface
		port(
			clk_in            : in  std_logic;
			fast_clk_in       : in  std_logic;
			reset             : in  std_logic;
			--input signals from mupix sensorboard
			ctrl_dout         : in  std_logic; --serial data from mupix
			spi_dout_adc      : in  std_logic; --adc serial data from board
			spi_dout_dac      : in  std_logic; --dac serial data from board
			dac4_dout         : in  std_logic; --serial data in from dac 4??
			hitbus            : in  std_logic; --hitbus signal
			hit               : in  std_logic; --hit signal (replacement for priout?)
			trigger           : in  std_logic; --external trigger
			--synchronized signals to FPGA logic
			ctrl_dout_sync    : out std_logic;
			spi_dout_adc_sync : out std_logic;
			spi_dout_dac_sync : out std_logic;
			dac4_dout_sync    : out std_logic;
			hitbus_sync       : out std_logic;
			trigger_sync      : out std_logic;
			hitbus_sync_fast  : out std_logic; --sampled with 200 MHz clock
			trigger_sync_fast : out std_logic; --sampled with 200 MHz clock
			hit_sync          : out std_logic);
	end component MupixBoardInterface;

	signal ctrl_dout_sync    : std_logic;
	signal spi_dout_adc_sync : std_logic;
	signal spi_dout_dac_sync : std_logic;
	signal dac4_dout_sync    : std_logic;
	signal hitbus_sync       : std_logic;
	signal trigger_sync      : std_logic;
	signal hitbus_sync_fast  : std_logic; --sampled with 200 MHz clock
	signal trigger_sync_fast : std_logic; --sampled with 200 MHz clock
	signal hit_sync          : std_logic;
	
	component HitbusHistogram
		generic(
			HistogramRange            : integer; 
			PostOscillationWaitCycles : integer);
		port(
			clk                  : in  std_logic;
			hitbus               : in  std_logic;
			trigger              : in  std_logic; 
			SLV_READ_IN          : in  std_logic;
			SLV_WRITE_IN         : in  std_logic;
			SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
			SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
			SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
			SLV_ACK_OUT          : out std_logic;
			SLV_NO_MORE_DATA_OUT : out std_logic;
			SLV_UNKNOWN_ADDR_OUT : out std_logic
		);
	end component HitbusHistogram;
	
	component PixelControl
		generic(
			fpga_clk_speed : integer;
			spi_clk_speed  : integer
		);
		port(
			clk                  : in  std_logic; --clock
			reset                : in  std_logic; --reset
			--mupix control
			mupixslctrl          : out MupixSlowControl;
    		ctrl_dout            : in std_logic; --serial data from mupix
			--TRB slow control
			SLV_READ_IN          : in  std_logic;
			SLV_WRITE_IN         : in  std_logic;
			SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
			SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
			SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
			SLV_ACK_OUT          : out std_logic;
			SLV_NO_MORE_DATA_OUT : out std_logic;
			SLV_UNKNOWN_ADDR_OUT : out std_logic);
	end component PixelControl;
	
	constant fpga_clk_speed : integer  := 1e8; --100 MHz
	constant mupix_spi_clk_speed : integer := 5e4;--50 kHz
	signal   mupixslctrl_i : MupixSlowControl;
	
	component MupixBoardDAC is
		port(
			clk                  : in  std_logic; --clock
			reset                : in  std_logic; --reset
			--DAC signals
			spi_dout_dac         : in  std_logic; --dac serial data from board
			dac4_dout            : in  std_logic; --serial data in from threshold dac
			spi_dout_adc         : in  std_logic; --adc serial data from board
			spi_clk              : out std_logic; --serial clock
			spi_din              : out std_logic; --serial data out
			spi_ld_tmp_dac       : out std_logic; --load temperature dac 
			spi_ld_thres         : out std_logic; --load threshold and injection dac
			spi_cs_adc           : out std_logic; --load adc
			injection_pulse      : out std_logic; --injection pulse to board
			--TRB slow control
			SLV_READ_IN          : in  std_logic;
			SLV_WRITE_IN         : in  std_logic;
			SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
			SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
			SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
			SLV_ACK_OUT          : out std_logic;
			SLV_NO_MORE_DATA_OUT : out std_logic;
			SLV_UNKNOWN_ADDR_OUT : out std_logic);
	end component MupixBoardDAC;

--signal declarations
-- Bus Handler
  constant NUM_PORTS : integer := 3;

  signal slv_read         : std_logic_vector(NUM_PORTS-1 downto 0);
  signal slv_write        : std_logic_vector(NUM_PORTS-1 downto 0);
  signal slv_no_more_data : std_logic_vector(NUM_PORTS-1 downto 0);
  signal slv_ack          : std_logic_vector(NUM_PORTS-1 downto 0);
  signal slv_addr         : std_logic_vector(NUM_PORTS*16-1 downto 0);
  signal slv_data_rd      : std_logic_vector(NUM_PORTS*32-1 downto 0);
  signal slv_data_wr      : std_logic_vector(NUM_PORTS*32-1 downto 0);
  signal slv_unknown_addr : std_logic_vector(NUM_PORTS-1 downto 0);

  	

begin  -- Behavioral

-------------------------------------------------------------------------------
-- Port Maps
-------------------------------------------------------------------------------

  THE_BUS_HANDLER : trb_net16_regio_bus_handler
    generic map(
      PORT_NUMBER => NUM_PORTS,

      PORT_ADDRESSES => (
          0      => x"0070",            -- Hitbus Histograms       
          1      => x"0080",            -- Mupix DAC and Pixel Control
          2      => x"0090",            -- Board Control
          others => x"0000"),
	 PORT_ADDR_MASK => (
          0      => 4,                  -- HitBus Histograms        
          1      => 4,                  -- Mupix DAC and Pixel Control
          2      => 4,                  -- Board Control
          others => 0)
	--PORT_MASK_ENABLE => 1
      )
    port map(
      CLK   => CLK,
      RESET => RESET,

      DAT_ADDR_IN          => REGIO_ADDR_IN,
      DAT_DATA_IN          => REGIO_DATA_IN,
      DAT_DATA_OUT         => REGIO_DATA_OUT,
      DAT_READ_ENABLE_IN   => REGIO_READ_ENABLE_IN,
      DAT_WRITE_ENABLE_IN  => REGIO_WRITE_ENABLE_IN,
      DAT_TIMEOUT_IN       => REGIO_TIMEOUT_IN,
      DAT_DATAREADY_OUT    => REGIO_DATAREADY_OUT,
      DAT_WRITE_ACK_OUT    => REGIO_WRITE_ACK_OUT,
      DAT_NO_MORE_DATA_OUT => REGIO_NO_MORE_DATA_OUT,
      DAT_UNKNOWN_ADDR_OUT => REGIO_UNKNOWN_ADDR_OUT,

      -- Control Registers       
      BUS_READ_ENABLE_OUT  => slv_read,
      BUS_WRITE_ENABLE_OUT => slv_write,
      BUS_DATA_OUT         => slv_data_wr,
      BUS_DATA_IN          => slv_data_rd,
      BUS_ADDR_OUT         => slv_addr,
      BUS_TIMEOUT_OUT      => open,
      BUS_DATAREADY_IN     => slv_ack,
      BUS_WRITE_ACK_IN     => slv_ack,
      BUS_NO_MORE_DATA_IN  => slv_no_more_data,
      BUS_UNKNOWN_ADDR_IN  => slv_unknown_addr,

      -- DEBUG
      STAT_DEBUG => open
      );
 
  	mupixboardinterface_1 : component MupixBoardInterface
  		port map(
  			clk_in            => clk,
  			fast_clk_in       => fast_clk,
  			reset             => reset,
  			ctrl_dout         => ctrl_dout,
  			spi_dout_adc      => spi_dout_adc,
  			spi_dout_dac      => spi_dout_dac,
  			dac4_dout         => dac4_dout,
  			hitbus            => hitbus,
  			hit               => hit,
  			trigger           => trigger,
  			ctrl_dout_sync    => ctrl_dout_sync,
  			spi_dout_adc_sync => spi_dout_adc_sync,
  			spi_dout_dac_sync => spi_dout_dac_sync,
  			dac4_dout_sync    => dac4_dout_sync,
  			hitbus_sync       => hitbus_sync,
  			trigger_sync      => trigger_sync,
  			hitbus_sync_fast  => hitbus_sync_fast,
  			trigger_sync_fast => trigger_sync_fast,
  			hit_sync          => hit_sync
  		);
  		
  	hitbushistogram_1 : component HitbusHistogram
  		generic map(
  			HistogramRange            => 10,
  			PostOscillationWaitCycles => 5
  		)
  		port map(
  			clk                  => clk,
  			hitbus               => hitbus_sync,
  			trigger              => trigger_sync,
  			SLV_READ_IN          => slv_read(0),
  			SLV_WRITE_IN         => slv_write(0),
  			SLV_DATA_OUT         => slv_data_rd(0*32 + 31 downto 0*32),
  			SLV_DATA_IN          => slv_data_wr(0*32 + 31 downto 0*32),
  			SLV_ADDR_IN          => slv_addr(0*16 + 15 downto 0*16),
  			SLV_ACK_OUT          => slv_ack(0),
  			SLV_NO_MORE_DATA_OUT => slv_no_more_data(0),
  			SLV_UNKNOWN_ADDR_OUT => slv_unknown_addr(0)
  		);	
  		
  		pixelcontrol_1 : component PixelControl
  			generic map(
  				fpga_clk_speed => fpga_clk_speed,
  				spi_clk_speed  => mupix_spi_clk_speed
  			)
  			port map(
  				clk                  => clk,
  				reset                => reset,
  				mupixslctrl          => mupixslctrl_i,
  				ctrl_dout            => ctrl_dout_sync,
  				SLV_READ_IN          => slv_read(1),
  				SLV_WRITE_IN         => slv_write(1),
  				SLV_DATA_OUT         => slv_data_rd(1*32 + 31 downto 1*32),
  				SLV_DATA_IN          => slv_data_wr(1*32 + 31 downto 1*32),
  				SLV_ADDR_IN          => slv_addr(1*16 + 15 downto 1*16),
  				SLV_ACK_OUT          => slv_ack(1),
  				SLV_NO_MORE_DATA_OUT => slv_no_more_data(1),
  				SLV_UNKNOWN_ADDR_OUT => slv_unknown_addr(1)
  			);
  			
  			ctrl_din           <= mupixslctrl_i.sin;
    		ctrl_clk1          <= mupixslctrl_i.clk1;
   			ctrl_clk2          <= mupixslctrl_i.clk2;
    		ctrl_ld            <= mupixslctrl_i.load;
  			
  			
  			boardcontrol_1 : component MupixBoardDAC
  				port map(
  					clk                  => clk,
  					reset                => reset,
  					spi_dout_dac         => spi_dout_dac_sync,
  					dac4_dout            => dac4_dout_sync,
  					spi_dout_adc         => spi_dout_adc_sync,
  					spi_clk              => spi_clk,
  					spi_din              => spi_din,
  					spi_ld_tmp_dac       => spi_ld_tmp_dac,
  					spi_ld_thres         => spi_ld_thres,
  					spi_cs_adc           => spi_cs_adc,
  					injection_pulse      => testpulse,
  					SLV_READ_IN          => slv_read(2),
  					SLV_WRITE_IN         => slv_write(2),
					SLV_DATA_OUT         => slv_data_rd(2*32 + 31 downto 2*32),
					SLV_DATA_IN          => slv_data_wr(2*32 + 31 downto 2*32),
					SLV_ADDR_IN          => slv_addr(2*16 + 15 downto 2*16),
					SLV_ACK_OUT          => slv_ack(2),
					SLV_NO_MORE_DATA_OUT => slv_no_more_data(2),
					SLV_UNKNOWN_ADDR_OUT => slv_unknown_addr(2)
  				);

end Behavioral;
