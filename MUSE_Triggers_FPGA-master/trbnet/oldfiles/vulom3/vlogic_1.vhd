--------------------------------------------------------------------------------
-- Company:  GSI
-- Engineer: Jan Hoffman, Davide Leoni
--
-- Create Date:    8/8/07
-- Design Name:    vulom3
-- Module Name:    vlogic_1 - Behavioral
-- Project Name:   triggerbox
-- Target Device:  XC4VLX25-10SF363
-- Tool versions:  
-- Description: Top module, DCM, display, LEDs, VME signals
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

entity vlogic_1 is
  port (
--............................. VME Signals ............................................
    AD     : inout std_logic_vector(31 downto 0);  -- VME Address-Data bus
    AMI    : in    std_logic_vector(5 downto 0);  -- VME Address modifier internal
    ASI    : in    std_logic;           -- Address strobe
    WRI    : in    std_logic;           -- write
    BERR   : in    std_logic;           -- bus error for chain block transfer
    BERRO  : out   std_logic;           -- bus error for chain block transfer
    DS0I   : in    std_logic;           -- data strobe
    DS1I   : in    std_logic;           -- data strobe
    IACKII : in    std_logic;           -- interrupt acknowledge        chain
    IACKOU : out   std_logic;           -- interrupt acknowledge        chain
    IRBLO  : out   std_logic;           -- interrupt 4 output to VME or BLACK output
--              MON       : in std_logic_vector(7 downto 0);  -- VME module number connected to hex. switch VN2 .. VN1
--............................. Buffer/Register Controll Signals ............................................
    CAIV   : out   std_logic;           --      Address buffer clock signal Int->VME
    OAIV   : out   std_logic;           --      Address  buffer OE                 Int->VME
--............................. Front panel Controll Signals ............................................
    ECO    : inout std_logic_vector(16 downto 1);  --signals to ECL output(1 is the lower connector of ECL OUT)
    EN     : out   std_logic_vector(4 downto 1);  -- ECL enable (EN1 for ch. 1-8, EN2 for ch. 9-16)
    ECL    : in    std_logic_vector(16 downto 1);  -- signals from ECL input (1 is at the lower connector of ECL IN)
    IOO    : in    std_logic_vector(16 downto 1);  -- signals ioo from ECL I/O (1 is at the lower connector)
    TIN    : inout std_logic_vector(16 downto 1);  -- output signals to ECL I/O (1 is at the lower connector)
    LEMIN  : in    std_logic_vector(2 downto 1);  --     signals from LEMO       upper
    LEMOU  : out   std_logic_vector(2 downto 1);  --    signals to LEMO lower             
--............................. SRAM Controll Signals ............................................
    SAD    : out   std_logic_vector(17 downto 0);  -- address 
    SDA    : inout std_logic_vector(15 downto 0);  -- data 
    SCS    : out   std_logic;
    SOE    : out   std_logic;
    SWE    : out   std_logic;
--............................. DISPLAY and LED Controll Signals ............................................
    DI     : inout std_logic_vector(6 downto 0);
    AI     : out   std_logic_vector(1 downto 0);  -- display address ( use 1 and 2 only, 0 and 3 can't be seen)
    WRDIS  : out   std_logic;           -- display write
    FLED   : out   std_logic_vector(6 downto 1);  -- Front panel LED
--............................. Euroball Readot Signals ............................................
--              PASSO     : over HPV or HPW
--              RENI      : over HPV or HPW
    BLTACK : in    std_logic;
--............................. System Signals ............................................
    PRES   : in    std_logic;           -- reset positive from reset IC 
--              SRESI     : in std_logic;  -- reset from VME
    RES    : in    std_logic_vector(2 downto 1);  -- reset from CPLD      
    CKFNL  : in    std_logic;           -- Diff 100 MHz ck neg 
    CKFPL  : in    std_logic;           -- Diff 100 MHz ck pos 
    CON    : inout std_logic_vector(15 downto 0);  --      Connection between PROG and vlogic_1
    HPV    : inout std_logic_vector(15 downto 0);  --      Logic analyzer signals 
    HPW    : inout std_logic_vector(15 downto 0)  -- 	Logic analyzer signals 
    );
end vlogic_1;
architecture rtl of vlogic_1 is
component clocking
port(
	CLKIN_IN : IN std_logic;          
	CLKDV_OUT : OUT std_logic;
	CLKFX_OUT : OUT std_logic;
	CLKIN_IBUFG_OUT : OUT std_logic;
	CLK0_OUT : OUT std_logic;
	LOCKED_OUT : OUT std_logic
	);
end component;
component ulogic port (
	RESET : in std_logic;
	CK50  : in std_logic;
	CK300 : in std_logic;
	CK100 : in std_logic;
	LEMOU	: out std_logic_vector(2 downto 1);
	LEMIN	: in std_logic_vector(2 downto 1);
	TIN   : out std_logic_vector(16 downto 1);
	ECO   : out std_logic_vector(16 downto 1);
	ECL   : in std_logic_vector(16 downto 1);
	IOO   : in std_logic_vector(16 downto 1);
	EN    : out std_logic_vector(4 downto 1);
	FLED_T: out std_logic_vector(6 downto 1);	-- to front panel LEDs
--............................. vme interface ....................
	U_AD_REG : in std_logic_vector(21 downto 2);
	U_DAT_IN : in std_logic_vector(31 downto 0);
	U_DATA_O : out std_logic_vector(31 downto 0);
	OECSR, CKCSR : in std_logic;
	HPV		: inout std_logic_vector(15 downto 0);
	HPW		: inout std_logic_vector(15 downto 0)
	);
end component;

component vmelogic port (
	ASIS	:in std_logic; -- 
	DSR	:in std_logic; --
	AD   :inout std_logic_vector(31 downto 0);
	AD_REG :inout std_logic_vector(31 downto 0);
	WRI   :in std_logic;
	AMI   :in std_logic_vector(5 downto 0);
	CKCSR	:out std_logic; -- clock data into csr
	OECSR	:out std_logic; -- output data from csr to VME
	CON   :inout std_logic_vector(15 downto 0);
	HPLB	:out std_logic_vector(15 downto 0);
	CK50   :in std_logic
	);
end component;
signal reset : std_logic;
signal count 	:	std_logic_vector (23 downto 0);
signal counth 	:	std_logic_vector (27 downto 0);
signal counf :	std_logic_vector (7 downto 0);
------------------------------------------------------------------------------------------------
signal tri_dat	: std_logic_vector (15 downto 0);  -- trigger bus level data
signal led_out	: std_logic_vector (4 downto 1);  -- 4 LEDs, on piggy 
signal lemo_dat	: std_logic_vector (15 downto 0);  -- 4 bit data from LEMO input 
signal enable, oecsr, ckcsr, asis, dsr		: std_logic;				-- enable internal data bus to outside of fpga
signal mres, sta_dis		: std_logic;				-- internal acknowledge
signal din, dadis		: std_logic_vector (31 downto 0);	 -- internal data bus, CSR
--------------------------------------------------------------------------------------------------
signal en_trcnt			: std_logic;
constant tr_cnt_dat		: std_logic_vector(7 downto 0)  := x"20";
signal tr_cnt 				: std_logic_vector(7 downto 0);	
signal u_ad_reg 			: std_logic_vector(21 downto 2);	
signal u_dat_in, u_data_o, ad_reg, pdone 			:std_logic_vector(31 downto 0);
signal dis_out	:std_logic_vector (1 downto 0);
signal fled_t : std_logic_vector(6 downto 1);	
--
signal hp	: std_logic_vector (3 downto 0);  	-- states of flash machine
signal hplb	: std_logic_vector (15 downto 0);  	-- 
signal prova, to_LED6, SOFT_RESET : std_logic;
----------------------------
signal rst, clk2x, clk0, ck50, ck300, ck100, locked		: std_logic;				-- internal acknowledge
-------------------------------------------------------------------------------
signal clk : std_logic;
begin
   -- CLK ----------------------------------------------------------------------
--   IBUFGDS_CLK : IBUFGDS                 
--     generic map (
--       IOSTANDARD => "LVDS_25_DCI")
--     port map (
--       O => clk,--CLK,
--       I => CKFPL,  
--       IB => CKFNL -- Diff_n clock buffer input (connect to top-level port)
--     );
  Inst_clocking : clocking port map(
    CLKIN_IN        => CKFPL,
    CLKDV_OUT       => ck50,            --50MHz clock
    CLKFX_OUT       => ck300,           --300MHz clock
    CLKIN_IBUFG_OUT => open,
    CLK0_OUT        => ck100,           --100MHz clock
    LOCKED_OUT      => to_led6);
  ulg_1 : ulogic port map (
    RESET    => reset,
    CK50     => CK50,
    CK300    => CK300,
    CK100    => CK100,
    LEMIN    => LEMIN,
    LEMOU    => LEMOU,
    TIN      => TIN,
    EN       => EN,
    ECO      => ECO,
    ECL      => ECL,
    IOO      => IOO,
    FLED_T   => fled_t,
    U_AD_REG => u_ad_reg,
    U_DAT_IN => u_dat_in,
    U_DATA_O => u_data_o,
    OECSR    => oecsr,
    CKCSR    => ckcsr,
    HPV      => HPV,
    HPW      => HPW
    );
  vme_1 : vmelogic port map (
    ASIS   => asis,
    DSR    => dsr,
    AD     => ad,
    AD_REG => ad_reg,
    WRI    => WRI,
    AMI    => AMI,
    CKCSR  => ckcsr,
    OECSR  => oecsr,
    CON    => CON,
    HPLB   => hplb,
    CK50   => ck50);
---------------------------------------------------------------------------------------------
--...............................RESET signal............................................
  reset <= PRES or res(1);  -- or not SRESI;  -- PRES active high from power IC,
			-- SRESI active low from VME
---------------------------------PANEL LED---------------------------------------------------
  process (ck50)
  begin
    if rising_edge(ck50) then
      FLED(6)          <= not to_led6;  --led on if pll is working                      
      FLED(5 downto 1) <= fled_t(5 downto 1);  --leds on if inputs enabled
    end if;
  end process;
--...............................  signals to/from CPLD  .......................................
  mres <= '1';
--...............................  display  .......................................
  process (ck50)
  begin
    if (ck50'event and ck50 = '1') then
      count <= count + 1;
    end if;
  end process;
  process (count(4))
  begin
    if rising_edge(count(4)) then
      WRDIS <= count(5);
      if count(6) = '0' then
        AI  <= "01";
        DI  <= CONV_STD_LOGIC_VECTOR(51, 7);  -- 33h "3" ascii
      else
        AI  <= "10";
        DI  <= CONV_STD_LOGIC_VECTOR(51, 7);  -- 32h "2" ascii
      end if;
    end if;
  end process;										
--............................. VME Signals ............................................
  BERRO  <= '1';                        -- H means inactive
  IACKOU <= IACKII;                     -- interrupt acknowledge chain
--              SRESI                   -- system reset
  process(ck50, asi, ds0i, ds1i)
  begin
    if (ck50'event and ck50 = '1') then
      asis <= not asi;
      dsr  <= not ds0i and not ds1i;    -- synchronized DS input from VME
    end if;
  end process;
--------------------------- VME address buffer control signals  -------------------------------
  CAIV     <= '1';                      -- clock for address register internal<-VME, disabled
  OAIV     <= '1';                      -- OE for address register internal<-VME, disabled
  u_ad_reg <= ad_reg(21 downto 2);
  u_dat_in <= ad;
----------------------- DATA MULTIPLEXER for OUTPUT to VME  -------------------------------------------
  process(ck50)
  begin
    if (ck50'event and ck50 = '1') then
      if (oecsr = '1') then
        din <= u_data_o;                -- data to VME over AD bus 
--                      elsif   (dis_out(1)='1')        then            din     <=      dadis;  -- display data over AD bus                      not necessary with vulom3       /*/*/*/*/*/                                                                                             
      else
        din <= (others => '0');
      end if;
    end if;
  end process;
  enable    <= oecsr;  --or dis_out(1);  -- address and data bus output                                                                                  not necessary with vulom3       /*/*/*/*/*/
  AD <= din when enable = '1' else (others => 'Z');
----------------------------------- end of VME -----------------------------------------------				
-------------------------------------------------------------------------------
-- * UNUSED @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Unused Signals @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
---------------------------------------------------------------------------------
  IRBLO <= '1';
  SCS   <= '1';
  SOE   <= '0';
  SWE   <= '0';
  SAD   <= (others => '0');
-- con(15 downto 7) <= b"000000000";
end rtl;
