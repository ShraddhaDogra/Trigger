LIBRARY ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net_onewire_listener is
  port(
    CLK    : in std_logic;
    CLK_EN : in std_logic;
    RESET  : in std_logic;
    MONITOR_IN : in std_logic;
    DATA_OUT : out std_logic_vector(15 downto 0);
    ADDR_OUT : out std_logic_vector(2 downto 0);
    WRITE_OUT: out std_logic;
    TEMP_OUT : out std_logic_vector(11 downto 0);
    ID_OUT   : out std_logic_vector(63 downto 0);
    STAT     : out std_logic_vector(31 downto 0)
    );
end entity;

architecture arch of trb_net_onewire_listener is

  component signal_sync is
    generic(
      WIDTH : integer := 1;     --
      DEPTH : integer := 3
      );
    port(
      RESET    : in  std_logic; --Reset is neceessary to avoid optimization to shift register
      CLK0     : in  std_logic;                          --clock for first FF
      CLK1     : in  std_logic;                          --Clock for other FF
      D_IN     : in  std_logic_vector(WIDTH-1 downto 0); --Data input
      D_OUT    : out std_logic_vector(WIDTH-1 downto 0)  --Data output
      );
  end component;

  signal buf_ADDR_OUT  : std_logic_vector(2 downto 0);
  signal buf_DATA_OUT  : std_logic_vector(15 downto 0);
  signal buf_WRITE_OUT : std_logic;
  signal buf_TEMP_OUT  : std_logic_vector(11 downto 0);

  signal reg_onewire: std_logic;
  signal onewire    : std_logic;
  signal tcounter   : unsigned(15 downto 0);  --timing of signals
  signal rcounter   : unsigned(15 downto 0);  --detection of long reset pulse
  signal bcounter   : unsigned(7 downto 0);   --bitcounter
  signal saved_onewire : std_logic_vector(7 downto 0);
  signal read_bit_enable : std_logic;
  signal read_byte  : std_logic_vector(15 downto 0);

  type state_t is (RESETTING, WAIT_AFTER_RESET, READ_COMMAND_BIT_1, READ_COMMAND_BIT_2, READ_ID_1, READ_ID_2,
                   READ_TEMP_1, READ_TEMP_2, EVAL_COMMAND, EVAL_ID, EVAL_TEMP, WAIT_FOR_RESET);
  signal state      : state_t;
  signal state_bits : std_logic_vector(3 downto 0);


  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  attribute HGROUP of arch : architecture  is "ONEWIRE_group";


begin


  THE_INPUT_SYNC : signal_sync
    generic map(
      DEPTH => 2,
      WIDTH => 1
      )
    port map(
      RESET    => RESET,
      D_IN(0)  => MONITOR_IN,
      CLK0     => CLK,
      CLK1     => CLK,
      D_OUT(0) => reg_onewire
      );


  PROC_CLEAN_ONEWIRE : process(CLK, CLK_EN)
    begin
      if rising_edge(CLK) and CLK_EN = '1' then
        saved_onewire <= reg_onewire & saved_onewire(7 downto 1);
        if or_all(saved_onewire) = '0' then
          onewire <= '0';
        elsif and_all(saved_onewire) = '1' then
          onewire <= '1';
        end if;
      end if;
    end process;

  PROC_SHIFT_BYTES : process(CLK, CLK_EN)
    begin
      if rising_edge(CLK) and CLK_EN = '1' then
        if read_bit_enable = '1' then
          read_byte <= onewire & read_byte(15 downto 1);
        end if;
      end if;
    end process;


  PROC_FSM : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          state <= RESETTING;
          buf_TEMP_OUT <= (others => '0');
          buf_WRITE_OUT <= '0';
        elsif CLK_EN = '1' then
          read_bit_enable <= '0';
          buf_WRITE_OUT   <= '0';

          case state is
            --detect reset pulse > 320us
            when RESETTING =>
              if onewire = '1' then
                state <= WAIT_AFTER_RESET;
                tcounter <= (others => '0');
              end if;

            --assume presence pulse is ok
            when WAIT_AFTER_RESET =>
              if tcounter(12) = '0'  then
                if onewire = '0' then
                  tcounter <= tcounter + "1";
                else
                  tcounter <= (others => '0');
                end if;
              elsif onewire = '1' then
                state    <= READ_COMMAND_BIT_1;
                tcounter <= (others => '0');
                bcounter <= (others => '0');
              end if;

            --wait for 0.64us 0, then wait for 12.80us
            when READ_COMMAND_BIT_1 | READ_ID_1 | READ_TEMP_1 =>
              tcounter <= tcounter + "1";
              if tcounter < 64 and onewire = '1' then
                tcounter <= (others => '0');
              elsif tcounter >= 1280 then
                read_bit_enable <= '1';
                case state is
                  when READ_COMMAND_BIT_1 => state <= READ_COMMAND_BIT_2;
                  when READ_ID_1          => state <= READ_ID_2;
                  when READ_TEMP_1        => state <= READ_TEMP_2;
                  when others             => state <= WAIT_FOR_RESET;  --haha
                end case;
                tcounter        <= (others => '0');
              end if;

            --wait until onewire is high, then go back or evaluate byte
            when READ_COMMAND_BIT_2 | READ_ID_2 | READ_TEMP_2 =>
              if onewire = '1' then
                tcounter <= (others => '0');
                bcounter <= bcounter + "1";
                case state is
                  when READ_COMMAND_BIT_2 =>
                    if bcounter(2 downto 0) = "111" then
                      state <= EVAL_COMMAND;
                    else
                      state <= READ_COMMAND_BIT_1;
                    end if;
                  when READ_ID_2 =>
                    if bcounter(3 downto 0) = x"F" then
                      state <= EVAL_ID;
                    else
                      state <= READ_ID_1;
                    end if;
                  when READ_TEMP_2 =>
                    if bcounter = x"0B" then
                      state <= EVAL_TEMP;
                    else
                      state <= READ_TEMP_1;
                    end if;
                  when others =>
                    state <= WAIT_FOR_RESET;  --haha
                end case;
              end if;

            --interprete the received command
            when EVAL_COMMAND =>
              bcounter <= (others => '0');
              tcounter <= (others => '0');
              case read_byte(15 downto 8) is
                when x"33" =>  --read rom
                  state <= READ_ID_1;
                when x"CC" =>  --skip rom
                  state <= READ_COMMAND_BIT_1;
                when x"44" =>  --conv temp
                  state <= WAIT_FOR_RESET;
                when x"BE" =>  --read temp
                  state <= READ_TEMP_1;
                when others => --ignore
                  state <= WAIT_FOR_RESET;
              end case;

            --output received temperature
            when EVAL_TEMP =>
              bcounter <= (others => '0');
              tcounter <= (others => '0');
              buf_TEMP_OUT <= read_byte(15 downto 4);
              state    <= WAIT_FOR_RESET;

            --write ID to RAM
            when EVAL_ID =>
              buf_DATA_OUT  <= read_byte;
              buf_WRITE_OUT <= '1';
              buf_ADDR_OUT  <= '0' & std_logic_vector(bcounter(5 downto 4)-"1");
              if bcounter(5 downto 4) = "00" then
                state <= WAIT_FOR_RESET;
              else
                state <= READ_ID_1;
              end if;

            --waiting for reset covered by reset detection below
            when WAIT_FOR_RESET => null;
            when others         => state <= WAIT_FOR_RESET;

          end case;

          --detect reset signal
          if onewire = '0' then
            rcounter <= rcounter + "1";
            if rcounter(15) = '1' then
              state <= RESETTING;
              rcounter <= (others => '0');
            end if;
          else
            rcounter <= (others => '0');
          end if;

        end if;
      end if;
    end process;

  DATA_OUT  <= buf_DATA_OUT;
  ADDR_OUT  <= buf_ADDR_OUT;
  WRITE_OUT <= buf_WRITE_OUT;
  TEMP_OUT  <= buf_TEMP_OUT;


  PROC_STORE_ID : process begin
    wait until rising_edge(CLK);
    if buf_WRITE_OUT = '1' then
      case buf_ADDR_OUT is
        when "000" => ID_OUT(15 downto  0) <= buf_DATA_OUT;
        when "001" => ID_OUT(31 downto 16) <= buf_DATA_OUT;
        when "010" => ID_OUT(47 downto 32) <= buf_DATA_OUT;
        when "011" => ID_OUT(63 downto 48) <= buf_DATA_OUT;
        when others => null;
      end case;
    end if;
  end process;

  state_bits <= "0000" when state = WAIT_FOR_RESET else
                "0001" when state = RESETTING else
                "0010" when state = WAIT_AFTER_RESET else
                "0011" when state = READ_COMMAND_BIT_1 else
                "0100" when state = READ_COMMAND_BIT_2 else
                "0101" when state = READ_ID_1 else
                "0110" when state = READ_ID_2 else
                "0111" when state = READ_TEMP_1 else
                "1000" when state = READ_TEMP_2 else
                "1001" when state = EVAL_COMMAND else
                "1010" when state = EVAL_ID else
                "1011" when state = EVAL_TEMP else
                "1100" when state = WAIT_FOR_RESET else
                "1111";

  STAT(0)            <= onewire;
  STAT(4 downto 1)   <= state_bits;
  STAT(12 downto 5)  <= std_logic_vector(bcounter);
  STAT(15 downto 13) <= buf_ADDR_OUT;
  STAT(31 downto 16) <= std_logic_vector(tcounter);


end architecture;