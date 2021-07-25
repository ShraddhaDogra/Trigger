library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.trb_net_std.all;


entity tb is
end entity;


architecture tba of tb is
  
component input_to_trigger_logic_record
  generic(
    INPUTS      : integer range 1 to 96 := 24;
    OUTPUTS     : integer range 1 to 8  := 4
    );
  port(
    CLK        : in std_logic;
    
    INPUT      : in  std_logic_vector(INPUTS-1 downto 0);
    OUTPUT     : out std_logic_vector(OUTPUTS-1 downto 0);

    BUS_RX     : in  CTRLBUS_RX;
    BUS_TX     : out CTRLBUS_TX
    );
end component;


  
  signal input: std_logic_vector(95 downto 0) := (others => '0');
  signal clock: std_logic := '1';
  
  
  signal bus_rx : CTRLBUS_RX;
  signal bus_tx : CTRLBUS_TX;
  
  
begin
  
  clock <= not clock after 5 ns;
  
  process begin
    wait for 1000 ns;
    wait for 52 ns;
    input(0) <= '1';
    wait for 1 ns;
    input(0) <= '0';
    wait;
  end process;

  
  process begin
    wait for 1000 ns;
    wait for 54 ns;
    input(1) <= '1';
    wait for 1 ns;
    input(1) <= '0';
    wait;
  end process;  

  process begin
    wait for 1000 ns;
    wait for 61 ns;
    input(2) <= '1';
    wait for 1 ns;
    input(2) <= '0';
    wait;
  end process;   
  
  
  process begin
  wait for 10 ns;
  bus_rx.data <= x"0000ffff";
  bus_rx.addr <= x"0000";
  bus_rx.write <= '1'; wait for 10 ns; bus_rx.write <= '0'; wait for 20 ns;

  bus_rx.data <= x"00020000";
  bus_rx.addr <= x"0032";
  bus_rx.write <= '1'; wait for 10 ns; bus_rx.write <= '0'; wait for 20 ns;  
  
  bus_rx.data <= x"00000001";
  bus_rx.addr <= x"0028";
  bus_rx.write <= '1'; wait for 10 ns; bus_rx.write <= '0'; wait for 20 ns;  
  
  bus_rx.data <= x"00000002";
  bus_rx.addr <= x"002c";
  bus_rx.write <= '1'; wait for 10 ns; bus_rx.write <= '0'; wait for 20 ns;  
    
  end process;
  
  
  U: input_to_trigger_logic_record
    generic map(
      INPUTS => 96,
      OUTPUTS => 3
    )
    port map(
      CLK => clock,
      INPUT => input,
      OUTPUT => open,
      BUS_RX => bus_rx,
      BUS_TX => bus_tx
    );
  
  
end architecture;