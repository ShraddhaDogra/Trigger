LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;


entity trb_net_counter_tester is
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    --  Media direction port
    MED_DATAREADY_IN:  in  STD_LOGIC; 
    MED_DATA_IN:       in  STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN:  in  STD_LOGIC_VECTOR (1 downto 0);
    MED_READ_OUT:      out STD_LOGIC;

    MED_DATAREADY_OUT: out STD_LOGIC; 
    MED_DATA_OUT:      out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT: out STD_LOGIC_VECTOR (1 downto 0);
    MED_READ_IN:       in  STD_LOGIC;

    MED_ERROR_IN : in std_logic_vector(2 downto 0);
    STAT: out std_logic_vector(63 downto 0)
    );
end entity;


architecture trb_net_counter_tester_arch of trb_net_counter_tester is
  signal recv_counter  : std_logic_vector(17 downto 0);
  signal trans_counter : std_logic_vector(17 downto 0);
  signal buf_MED_DATAREADY_OUT      : std_logic;
  signal recv_counter_mismatch      : std_logic;
  signal next_recv_counter_mismatch : std_logic;
  signal t : std_logic;
  signal cn : std_logic_vector(7 downto 0);

begin

  MED_DATAREADY_OUT  <= buf_MED_DATAREADY_OUT;
  MED_DATA_OUT       <= trans_counter(17 downto 2);
  MED_PACKET_NUM_OUT <= trans_counter(1 downto 0);
  MED_READ_OUT       <= '1';

  STAT(17 downto 0)  <= MED_DATA_IN & MED_PACKET_NUM_IN;
  STAT(24)           <= recv_counter_mismatch;
  STAT(49 downto 32) <= recv_counter;

  --buf_MED_DATAREADY_OUT <= '1' when  MED_ERROR_IN = ERROR_OK else '0';

  process(MED_ERROR_IN, t)
    begin
      buf_MED_DATAREADY_OUT <= '0';
      if MED_ERROR_IN = ERROR_OK then
        buf_MED_DATAREADY_OUT <= '1';
      end if;
      if t = '1' then
        buf_MED_DATAREADY_OUT <= '0';
      end if;
    end process;

  --generate some spare cycles too preserve from buffer overflows
  t <= (cn(3) and cn(7) and not cn(5)) or
       (not cn(3) and cn(7) and cn(5)) or
       (cn(3) and not cn(7) and cn(5));

  next_recv_counter_mismatch <= '1' when (recv_counter /= (MED_DATA_IN & MED_PACKET_NUM_IN)) or recv_counter_mismatch = '1' else '0';

  cn_counter : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          cn <= (others => '0');
        else
          cn <= cn + 1;
        end if;
      end if;
    end process;

  R_MISMATCH : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          recv_counter_mismatch <= '0';
        elsif MED_DATAREADY_IN = '1' then
          recv_counter_mismatch <= next_recv_counter_mismatch;
        end if;
      end if;
    end process;

  R_COUNTER : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          recv_counter <= (others => '0');
        elsif MED_DATAREADY_IN = '1' then
          recv_counter <= recv_counter + 1;
        end if;
      end if;
    end process;

  S_COUNTER : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          trans_counter <= (others => '0');
        elsif buf_MED_DATAREADY_OUT = '1' and MED_READ_IN = '1' then
          trans_counter <= trans_counter + 1;
        end if;
      end if;
    end process;

end architecture;