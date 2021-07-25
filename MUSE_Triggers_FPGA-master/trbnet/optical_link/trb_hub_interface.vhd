library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;
--use work.support.all;


entity trb_hub_interface is
  port (
    CLK                : in std_logic;
    RESET              : in std_logic;
    STROBE             : in    std_logic;
    INTERNAL_DATA_IN   : in    std_logic_vector(7 downto 0);
    INTERNAL_DATA_OUT  : out   std_logic_vector(7 downto 0);
    INTERNAL_ADDRESS   : in    std_logic_vector(15 downto 0);
    INTERNAL_MODE      : in    std_logic;
    VALID_DATA_SENT    : out   std_logic;
    HUB_REGISTER_00    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_01    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_02    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_03    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_04    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_05    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_06    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_07    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_08    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_09    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_0a    : out   std_logic_vector(7 downto 0);
    HUB_REGISTER_0b    : out   std_logic_vector(7 downto 0);
    HUB_REGISTER_0c    : out   std_logic_vector(7 downto 0);
    HUB_REGISTER_0d    : out   std_logic_vector(7 downto 0);
    HUB_REGISTER_0e    : out   std_logic_vector(7 downto 0);
    HUB_REGISTER_0f    : out   std_logic_vector(7 downto 0);
    HUB_REGISTER_10    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_11    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_12    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_13    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_14    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_15    : in    std_logic_vector(7 downto 0);
    HUB_REGISTER_16    : in    std_logic_vector(7 downto 0)
    );
end trb_hub_interface;
architecture trb_hub_interface of trb_hub_interface is
  component edge_to_pulse
    port (
      clock     : in  std_logic;
      en_clk    : in  std_logic;
      signal_in : in  std_logic;
      pulse     : out std_logic);
  end component;
  signal hub_register_08_i : std_logic_vector(7 downto 0);
  signal hub_register_09_i : std_logic_vector(7 downto 0);
  signal hub_register_0a_i : std_logic_vector(7 downto 0);
  signal hub_register_0b_i : std_logic_vector(7 downto 0);
  signal hub_register_0c_i : std_logic_vector(7 downto 0);
  signal hub_register_0d_i : std_logic_vector(7 downto 0);
  signal hub_register_0e_i : std_logic_vector(7 downto 0);
  signal hub_register_0f_i : std_logic_vector(7 downto 0);
  signal saved_address : std_logic_vector(15 downto 0);
  signal saved_mod : std_logic;
  signal saved_data_in : std_logic_vector(7 downto 0);
  signal saved_data_out : std_logic_vector(7 downto 0);
  signal strobe_pulse : std_logic;
  signal data_ready : std_logic;
  type SEND_VALID is
    (IDLE ,VALID_1,VALID_2,VALID_3,VALID_4,VALID_5);
  signal VALID_current, VALID_next: SEND_VALID;
begin

  STROBE_PULSER: edge_to_pulse
       port map (
           clock  => CLK,
           en_clk => '1',
           signal_in => STROBE,
           pulse  => strobe_pulse);
  SAVE_MOD_ADD_DATA : process (CLK, RESET, strobe_pulse)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        saved_address <= (others => '0');
        saved_mod     <= '0';
        saved_data_in <= (others => '0');
      elsif strobe_pulse = '1' then
        saved_address <= INTERNAL_ADDRESS;
        saved_mod     <= INTERNAL_MODE;
        saved_data_in <= INTERNAL_DATA_IN;
      end if;
    end if;
  end process SAVE_MOD_ADD_DATA;

  DATA_SOURCE_SELECT : process (CLK,RESET,saved_mod,saved_address)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
         hub_register_0a_i                          <= x"00";
         hub_register_0b_i                          <= x"00";
         hub_register_0c_i                          <= x"00";
         hub_register_0d_i                          <= x"00";
      else
        if saved_mod = '1' then
          case saved_address(15 downto 0) is
            when x"0000" => saved_data_out <= HUB_REGISTER_00;
            when x"0001" => saved_data_out <= HUB_REGISTER_01;
            when x"0002" => saved_data_out <= HUB_REGISTER_02;
            when x"0003" => saved_data_out <= HUB_REGISTER_03;
            when x"0004" => saved_data_out <= HUB_REGISTER_04;
            when x"0005" => saved_data_out <= HUB_REGISTER_05;
            when x"0006" => saved_data_out <= HUB_REGISTER_06;
            when x"0007" => saved_data_out <= HUB_REGISTER_07;
            when x"0008" => saved_data_out <= HUB_REGISTER_08;
            when x"0009" => saved_data_out <= HUB_REGISTER_09;
            when x"000a" => saved_data_out <= hub_register_0a_i;
            when x"000b" => saved_data_out <= hub_register_0b_i;
            when x"000c" => saved_data_out <= hub_register_0c_i;
            when x"000d" => saved_data_out <= hub_register_0d_i;
            when x"000e" => saved_data_out <= hub_register_0e_i;
            when x"000f" => saved_data_out <= hub_register_0f_i;
            when x"0010" => saved_data_out <= HUB_REGISTER_10;
            when x"0011" => saved_data_out <= HUB_REGISTER_11;
            when x"0012" => saved_data_out <= HUB_REGISTER_12;
            when x"0013" => saved_data_out <= HUB_REGISTER_13;
            when x"0014" => saved_data_out <= HUB_REGISTER_14;
            when x"0015" => saved_data_out <= HUB_REGISTER_15;
            when x"0016" => saved_data_out <= HUB_REGISTER_16;

            when others  => saved_data_out <= x"ff";
          end case;
        elsif saved_mod = '0' then
          case saved_address(15 downto 0) is
            when x"000a" => hub_register_0a_i <= saved_data_in;
            when x"000b" => hub_register_0b_i <= saved_data_in;
            when x"000c" => hub_register_0c_i <= saved_data_in;
            when x"000d" => hub_register_0d_i <= saved_data_in;
            when x"000e" => hub_register_0e_i <= saved_data_in;
            when x"000f" => hub_register_0f_i <= saved_data_in;
            when others      => null;
          end case;
        end if;
      end if;
    end if;
  end process DATA_SOURCE_SELECT;
  HUB_REGISTER_0a <= hub_register_0a_i;
  HUB_REGISTER_0b <= hub_register_0b_i;
  HUB_REGISTER_0c <= hub_register_0c_i;
  HUB_REGISTER_0d <= hub_register_0d_i;
  HUB_REGISTER_0e <= hub_register_0e_i;
  HUB_REGISTER_0f <= hub_register_0f_i;
  INTERNAL_DATA_OUT <= saved_data_out;
  data_ready <=  '1';
  VALID_CLOCKED  : process (CLK, RESET)
  begin
    if rising_edge(CLK)  then
      if RESET = '1' then
        VALID_current <= IDLE;
      else
        VALID_current <= VALID_next;
      end if;
    end if;
  end process VALID_CLOCKED;
    SEND_VALID_FSM: process (VALID_current,data_ready,strobe_pulse)
    begin
      case (VALID_current) is
        when IDLE =>
          VALID_DATA_SENT <= '0';
          if strobe_pulse = '1' then
            VALID_next <= VALID_1;
          else
            VALID_next <= IDLE;
          end if;
        when VALID_1 =>
          VALID_DATA_SENT <= '0';
  --      if data_ready = '1' then
            VALID_next <= VALID_2;
  --      else
  --        VALID_next <= VALID_1;
  --      end if;
        when VALID_2 =>
          VALID_DATA_SENT <= '1';
          VALID_next <= VALID_3;
        when VALID_3 =>
          VALID_DATA_SENT <= '1';
          VALID_next <= VALID_4;
        when VALID_4 =>
          VALID_DATA_SENT <= '1';
          VALID_next <= VALID_5;
        when VALID_5 =>
          VALID_DATA_SENT <= '1';
          VALID_next <= IDLE;
        when others =>
          VALID_DATA_SENT <= '0';
          VALID_next <= IDLE;
      end case;   
    end process SEND_VALID_FSM;

end trb_hub_interface;
