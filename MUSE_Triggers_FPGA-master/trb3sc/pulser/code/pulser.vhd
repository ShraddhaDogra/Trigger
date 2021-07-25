library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
library work;
  use work.trb_net_components.all;
  use work.trb_net_std.all;
  use work.config.all;

entity pulser is
  generic(
    CHANNELNUM : integer := 30
    );
  port(
    SYSCLK      : in std_logic;
    CLK_FAST_LEFT : in std_logic;
    CLK_FAST_RIGHT : in std_logic;
    
    RESET       : in std_logic;
    
    --Slowcontrol
    BUS_RX     : in  CTRLBUS_RX;
    BUS_TX     : out CTRLBUS_TX;
    
    --AddOn Connector
    OUTP     : out std_logic_vector(16 downto 1);
    OUTP_FAN : out std_logic_vector(3 downto 0);
    OUTP_ANA : out std_logic_vector(9 downto 0);
    
    INP  : in  std_logic_vector(3 downto 0);
    
    SEL1     : out std_logic_vector(3 downto 0);
    SEL2     : out std_logic_vector(3 downto 0);
    SELO1    : out std_logic_vector(1 downto 0);
    SELO2    : out std_logic_vector(1 downto 0);

    
    TRIG     : out std_logic;
    
    LED_PULSER : out std_logic_vector(4 downto 0);
    
    DEBUG_OUT  : out std_logic_vector(31 downto 0)
    );
end entity;

--OUTP         80pin, first 16 pairs
--OUTP_FAN(0): 80pin, 17-31, odd lines
--OUTP_FAN(1): 80pin, 18-32, even lines
--OUTP_FAN(2): 34pin, odd lines
--OUTP_FAN(3): 34pin, even lines
--OUTP_ANA(0-4): Analog1 - 390,470,820,1800,6800 Ohm
--OUTP_ANA(5-9): Analog2 - 390,470,820,1800,6800 Ohm
--SEL1/2       : Analog1/2  39,56,68,82 pF

--Pulsers: 0 - 15: OUTP,  16 - 19: OUTP_FAN, 20 - 29: OUTP_ANA

--0x000 - 0x00f  Pulser enable
--0x010 - 0x01f  Pulser invert
--0x040 - 0x041  Analog configuration (Bit0-4: SEL, Bit 8-9 SELO
--0x0f0           Pulser control strobe


--0x100 - 0x1ff  pulser period, 5 ns
--0x200 - 0x2ff  pulse length,  1.25 ns (only multiples of 5ns supported)
--0x300 - 0x3ff  pulser offset, 5 ns


architecture pulser_arch of pulser is
constant channel_num : integer := 48;
constant channel_reg_num : integer := 64;

signal clk_slow_left, clk_slow_right : std_logic;

type arr_32unsigned_t is array(0 to channel_num-1) of unsigned(31 downto 0);
type arr_1920slv_t is array(0 to 19) of std_logic_vector(15 downto 0);

signal period : arr_32unsigned_t;
signal length : arr_32unsigned_t;
signal offset : arr_32unsigned_t;
signal use_add: arr_1920slv_t;

signal ana1_in_select,  ana2_in_select : std_logic_vector(3 downto 0);
signal ana1_out_select, ana2_out_select: std_logic_vector(1 downto 0);
signal control_strobes : std_logic_vector(31 downto 0);
signal pulser_enable   : std_logic_vector(channel_reg_num-1 downto 0);
signal pulser_invert   : std_logic_vector(channel_reg_num-1 downto 0);
signal pulser_reset    : std_logic;
signal next_pulser_reset : std_logic;

-- type pulse_ddr_t  is array(0 to 31) of std_logic_vector(3 downto 0);
-- signal pulse    : pulse_ddr_t;
type d_t is array(0 to 3) of std_logic_vector(channel_num-1 downto 0);
type dleft_t is array(0 to 3) of std_logic_vector(19 downto 0);
type dright_t is array(0 to 3) of std_logic_vector(9 downto 0);
type dadd_t is array(0 to 3) of std_logic_vector(7 downto 0);
signal data_all   : d_t;
signal data_left  : dleft_t;
signal data_right : dright_t;
signal data_add   : dadd_t;

begin




multi_ch_pulser_left : for n in 0 to 19 generate
  pulser : entity work.single_channel_pulser
    port map (
      CLK         => clk_slow_left,
      RESET       => pulser_reset,
      FREQUENCY   => period(n)(23 downto 0),
      PULSE_WIDTH => length(n)(23 downto 0),
      OFFSET      => offset(n)(23 downto 0),
      ENABLE      => pulser_enable(n),
      PULSE(0)    => data_all(0)(n),
      PULSE(1)    => data_all(1)(n),
      PULSE(2)    => data_all(2)(n),
      PULSE(3)    => data_all(3)(n)
      );
end generate;


multi_ch_pulser_right : for n in 0 to 9 generate
  pulser : entity work.single_channel_pulser
    port map (
      CLK         => clk_slow_right,
      RESET       => pulser_reset,
      FREQUENCY   => period(n+20)(23 downto 0),
      PULSE_WIDTH => length(n+20)(23 downto 0),
      OFFSET      => offset(n+20)(23 downto 0),
      ENABLE      => pulser_enable(n+20),
      PULSE(0)    => data_all(0)(n+20),
      PULSE(1)    => data_all(1)(n+20),
      PULSE(2)    => data_all(2)(n+20),
      PULSE(3)    => data_all(3)(n+20)
      );
end generate;

multi_ch_pulser_addleft : for n in 0 to 7 generate
  pulser : entity work.single_channel_pulser
    port map (
      CLK         => clk_slow_left,
      RESET       => pulser_reset,
      FREQUENCY   => period(n+32)(23 downto 0),
      PULSE_WIDTH => length(n+32)(23 downto 0),
      OFFSET      => offset(n+32)(23 downto 0),
      ENABLE      => pulser_enable(n+32),
      PULSE(0)    => data_all(0)(n+32),
      PULSE(1)    => data_all(1)(n+32),
      PULSE(2)    => data_all(2)(n+32),
      PULSE(3)    => data_all(3)(n+32)
      );
end generate;

gen_left : for i in 0 to 19 generate
  process begin
    wait until rising_edge(clk_slow_left);
    data_left(0)(i) <= (data_all(0)(i) or or_all(data_add(0)(7 downto 0) and use_add(i)(7 downto 0))) xor pulser_invert(i);
    data_left(1)(i) <= (data_all(1)(i) or or_all(data_add(1)(7 downto 0) and use_add(i)(7 downto 0))) xor pulser_invert(i);
    data_left(2)(i) <= (data_all(2)(i) or or_all(data_add(2)(7 downto 0) and use_add(i)(7 downto 0))) xor pulser_invert(i);
    data_left(3)(i) <= (data_all(3)(i) or or_all(data_add(3)(7 downto 0) and use_add(i)(7 downto 0))) xor pulser_invert(i);
  end process;  
end generate;  

gen_right : for i in 20 to 29 generate
  data_right(0)(i-20) <= data_all(0)(i) xor pulser_invert(i) when rising_edge(clk_slow_right);
  data_right(1)(i-20) <= data_all(1)(i) xor pulser_invert(i) when rising_edge(clk_slow_right);
  data_right(2)(i-20) <= data_all(2)(i) xor pulser_invert(i) when rising_edge(clk_slow_right);
  data_right(3)(i-20) <= data_all(3)(i) xor pulser_invert(i) when rising_edge(clk_slow_right);
end generate;

data_add(0) <= data_all(0)(39 downto 32) when rising_edge(clk_slow_left); 
data_add(1) <= data_all(1)(39 downto 32) when rising_edge(clk_slow_left); 
data_add(2) <= data_all(2)(39 downto 32) when rising_edge(clk_slow_left); 
data_add(3) <= data_all(3)(39 downto 32) when rising_edge(clk_slow_left); 



THE_LEFT_DDR : entity work.ddr_20
  port map(
    clk => CLK_FAST_LEFT,
    pll_lock  => open,
    pll_reset => '0',
    reset => '0',
    sclk  => clk_slow_left,
    da0   => data_left(0),
    da1   => data_left(2),
    db0   => data_left(1),
    db1   => data_left(3),
    q(15 downto 0)  => OUTP(16 downto 1),
    q(19 downto 16) => OUTP_FAN(3 downto 0)
    );


THE_RIGHT_DDR : entity work.ddr_10
  port map(
    clk => CLK_FAST_RIGHT,
    pll_lock  => open,
    pll_reset => '0',
    reset => '0',
    sclk  => clk_slow_right,
    da0   => data_right(0),
    da1   => data_right(2),
    db0   => data_right(1),
    db1   => data_right(3),
    q     => OUTP_ANA
    );




-------------------------------------------------      
-- Control Bus
-------------------------------------------------  


  proc_ctrlbus : process 
      variable channel : integer range 0 to 255;
    begin
    wait until rising_edge(SYSCLK);
    BUS_TX.ack <= '0'; BUS_TX.nack <= '0'; BUS_TX.unknown <= '0';
    control_strobes   <= (others => '0');
    next_pulser_reset <= '0';
    pulser_reset      <= RESET or next_pulser_reset;
    channel := to_integer(unsigned(BUS_RX.addr(7 downto 0)));
    
    if BUS_RX.read = '1' then
      BUS_TX.ack <= '1';
      if    BUS_RX.addr(11 downto 8) = x"1" and channel < channel_num then
        BUS_TX.data <= std_logic_vector(period(channel));
      elsif BUS_RX.addr(11 downto 8) = x"2" and channel < channel_num then
        BUS_TX.data <= std_logic_vector(length(channel));
      elsif BUS_RX.addr(11 downto 8) = x"3" and channel < channel_num then
        BUS_TX.data <= std_logic_vector(offset(channel));
      elsif BUS_RX.addr(11 downto 8) = x"4" and channel < 20 then
        BUS_TX.data <= x"0000" & std_logic_vector(use_add(channel));
      elsif BUS_RX.addr(11 downto 0) = x"000" then
        BUS_TX.data             <= pulser_enable(31 downto 0);
      elsif BUS_RX.addr(11 downto 0) = x"001" then
        BUS_TX.data             <= pulser_enable(63 downto 32);
      elsif BUS_RX.addr(11 downto 0) = x"010" then
        BUS_TX.data             <= pulser_invert(31 downto 0);
      elsif BUS_RX.addr(11 downto 0) = x"011" then
        BUS_TX.data             <= pulser_invert(63 downto 32);
      elsif BUS_RX.addr(11 downto 0) = x"040" then
        BUS_TX.data(3 downto 0) <= ana1_in_select;
        BUS_TX.data(9 downto 8) <= ana1_out_select;
      elsif BUS_RX.addr(11 downto 0) = x"041" then
        BUS_TX.data(3 downto 0) <= ana2_in_select;
        BUS_TX.data(9 downto 8) <= ana2_out_select;
      else
        BUS_TX.ack <= '0';
        BUS_TX.unknown <= '1';
      end if;
    
    elsif BUS_RX.write = '1' then
      BUS_TX.ack <= '1';
      if    BUS_RX.addr(11 downto 8) = x"1" and channel < channel_num then
        period(channel) <= unsigned(BUS_RX.data);
        next_pulser_reset <= '1';
      elsif BUS_RX.addr(11 downto 8) = x"2" and channel < channel_num then
        length(channel) <= unsigned(BUS_RX.data);
        next_pulser_reset <= '1';
      elsif BUS_RX.addr(11 downto 8) = x"3" and channel < channel_num then
        offset(channel) <= unsigned(BUS_RX.data);
        next_pulser_reset <= '1';
      elsif BUS_RX.addr(11 downto 8) = x"4" and channel < 20 then
        use_add(channel) <= BUS_RX.data(15 downto 0);
      elsif BUS_RX.addr(11 downto 0) = x"000" then  
        pulser_enable(31 downto 0) <= BUS_RX.data;
      elsif BUS_RX.addr(11 downto 0) = x"001" then  
        pulser_enable(63 downto 32) <= BUS_RX.data;
      elsif BUS_RX.addr(11 downto 0) = x"010" then  
        pulser_invert(31 downto 0) <= BUS_RX.data;
      elsif BUS_RX.addr(11 downto 0) = x"011" then  
        pulser_invert(63 downto 32) <= BUS_RX.data;
      elsif BUS_RX.addr(11 downto 0) = x"0f0" then  
        control_strobes <= BUS_RX.data;
        pulser_reset <= BUS_RX.data(0);
      elsif BUS_RX.addr(11 downto 0) = x"040" then
        ana1_in_select  <= BUS_RX.data(3 downto 0);
        ana1_out_select <= BUS_RX.data(9 downto 8);
      elsif BUS_RX.addr(11 downto 0) = x"041" then
        ana2_in_select  <= BUS_RX.data(3 downto 0);
        ana2_out_select <= BUS_RX.data(9 downto 8);
      else
        BUS_TX.ack <= '0';
        BUS_TX.unknown <= '1';
      end if;
    end if;
    
  end process;

  
-------------------------------------------------      
-- Control Lines
-------------------------------------------------    
gen_c_shape : for i in 0 to 3 generate  
  SEL1(i) <= '0' when ana1_in_select(i) = '1' else 'Z';
  SEL2(i) <= '0' when ana2_in_select(i) = '1' else 'Z';
end generate;    
  
gen_c_outputs : for i in 0 to 1 generate  
  SELO1(i) <= '0' when ana1_out_select(i) = '1' else 'Z';
  SELO2(i) <= '0' when ana2_out_select(i) = '1' else 'Z';
end generate;  
  
  
-------------------------------------------------      
-- LED
-------------------------------------------------  
  --all LED are inverted  D2-D6
  LED_PULSER(0) <= '0';  --next to 34-pin
  LED_PULSER(1) <= '0';  --next to KEL-80
  LED_PULSER(2) <= '0';  --Analog 1
  LED_PULSER(3) <= '0';  --Analog 2
  LED_PULSER(4) <= '1';  --SPI active



end architecture;