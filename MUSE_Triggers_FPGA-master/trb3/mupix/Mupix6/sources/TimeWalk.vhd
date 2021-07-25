-----------------------------------------------------------
--Measurement of Time-Walk (latency vs.  energy deposition)
--T. Weber, Mainz University
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


entity TimeWalk is
  port (
    clk                  : in  std_logic;
    reset                : in  std_logic;
    hitbus               : in  std_logic;
    hitbus_timeout       : in  std_logic_vector(15 downto 0);
    szintillator_trigger : in  std_logic;
    readyToWrite         : in  std_logic;
    measurementFinished  : out std_logic;
    measurementData      : out std_logic_vector(31 downto 0));
end entity TimeWalk;

architecture TimeWalk_Arch of TimeWalk is

  signal latencycounter            : unsigned(11 downto 0)        := (others => '0');
  signal hitbuscounter             : unsigned(11 downto 0)        := (others => '0');
  signal hitbus_delayed            : std_logic := '0';
  signal hitbus_edge               : std_logic_vector(1 downto 0) := (others => '0');
  signal szintillator_trigger_edge : std_logic_vector(1 downto 0) := (others => '0');
  signal szintillator_trigger_buffer : std_logic := '0';
  type TimeWalk_fsm_type is (idle, waitforhitbus, measurehitbus, measurement_done);
  signal timewalk_fsm              : TimeWalk_fsm_type            := idle;

  component SignalDelay is
    generic (
      Width : integer;
      Delay : integer);
    port (
      clk_in   : in  std_logic;
      write_en_in : in std_logic;
      delay_in : in  std_logic_vector(Delay - 1 downto 0);
      sig_in   : in  std_logic_vector(Width - 1 downto 0);
      sig_out  : out std_logic_vector(Width - 1 downto 0));
  end component SignalDelay;
  
begin  -- architecture TimeWalk_Arch

  SignalDelay_1: entity work.SignalDelay
    generic map (
      Width => 1,
      Delay => 5)
    port map (
      clk_in   => clk,
      write_en_in => '1',
      delay_in => std_logic_vector(to_unsigned(16, 5)),
      sig_in(0)   => hitbus,
      sig_out(0)  => hitbus_delayed);
  
  -- purpose: synchronize signals and edge detection
  signal_synchro: process (clk) is
  begin  -- process clk
    if rising_edge(clk) then
      if reset = '1' then
        hitbus_edge <= (others => '0');
        szintillator_trigger_edge <= (others => '0');
      else
        hitbus_edge                  <= hitbus_edge(0) & hitbus_delayed;
         szintillator_trigger_buffer <= szintillator_trigger;
        szintillator_trigger_edge    <= szintillator_trigger_edge(0) & szintillator_trigger_buffer;  
      end if;
    end if;
  end process signal_synchro;

  TimeWalk_Measurement : process (clk) is
  begin  -- process TimeWalk_Measurement
    if rising_edge(clk) then
      if reset = '1' then
        timewalk_fsm <= idle;
      else
         measurementFinished  <= '0';
         measurementData      <= (others => '0');
         case timewalk_fsm is
            when idle =>
             latencycounter <= (others => '0');
             hitbuscounter  <= (others => '0');
             if szintillator_trigger_edge = "01" then
                timewalk_fsm   <= waitforhitbus;
             else
              timewalk_fsm   <= idle;
             end if;
           when waitforhitbus =>
             latencycounter <= latencycounter + 1;
             if hitbus_edge = "01" then
              timewalk_fsm  <= measurehitbus;
             elsif latencycounter = unsigned(hitbus_timeout) or latencycounter = to_unsigned(4095, 12) then
              timewalk_fsm <= idle;
             else
              timewalk_fsm <= waitforhitbus;
             end if;
           when measurehitbus =>
              hitbuscounter <= hitbuscounter + 1;
              if hitbus_edge = "10" or hitbuscounter = to_unsigned(4095, 12) then
                timewalk_fsm <= measurement_done;
              else
                timewalk_fsm  <= measurehitbus;
              end if;
           when measurement_done =>
              timewalk_fsm <= idle;
              if readyToWrite = '1' then
                measurementData        <= std_logic_vector("0000" & latencycounter & "0000" & hitbuscounter);
                measurementFinished    <= '1';
              end if;
           end case;
       end if;
    end if;
  end process TimeWalk_Measurement;

end architecture TimeWalk_Arch;
