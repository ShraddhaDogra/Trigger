LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;

entity sram_is61 is
  port(
    CLK    : in  std_logic;
    RESET  : in  std_logic;
    CLK_EN : in  std_logic;

    RAM_CLK   : out   std_logic;
    RAM_DATA  : inout std_logic_vector(17 downto 0);
    RAM_ADDR  : out   std_logic_vector(19 downto 0);
    RAM_ADVN  : out   std_logic;
    RAM_ADSCN : out   std_logic;
    RAM_ADSPN : out   std_logic;
    RAM_GWN   : out   std_logic;
    RAM_CEN   : out   std_logic;
    RAM_OEN   : out   std_logic;

    INT_DATA_IN        : in  std_logic_vector(17 downto 0);
    INT_ADDR_IN        : in  std_logic_vector(19 downto 0);
    INT_DATA_OUT       : out std_logic_vector(17 downto 0);
    INT_WRITE_EN       : in  std_logic;
    INT_BURST_WRITE_EN : in  std_logic;
    INT_READ_EN        : in  std_logic;
    INT_BURST_READ_EN  : in  std_logic;
    INT_BUSY_OUT       : out std_logic;
    INT_VALID_OUT      : out std_logic;

    STAT_DEBUG         : out std_logic_vector(31 downto 0);
    );
end entity;

-- write_en is always followed by two or more clock cycles busy time
-- up to four burst_write might come in subsequent clock cycles, then several cycles busy followe
-- if burst_write goes low after the first, 2nd or 3rd clock cycle, the burst cycle is finished.
-- start of a burst cycle is always with lower two address bits = 0.
-- address is read only once during burst cycle

-- pulse on read_en will give one data word from ram, thus one valid
-- pulse on burst_read_en will read four words from ram, thus four consecutive valids
-- user must be able to read offered data, no waitstates are possible

-- after falling edge of busy signal the next access can be started immediately



architecture sram_is61_arch of sram_is61 is

component ddr_off
    port (Clk: in  std_logic; Data: in  std_logic_vector(1 downto 0);
        Q: out  std_logic_vector(0 downto 0));
end component;



  type state_t is (IDLE, );
  signal current_state : state_t;
  signal next_state    : state_t;

  signal next_oe       : std_logic;  -- output enable
  signal next_ce       : std_logic;  -- chip enable
  signal next_gw       : std_logic;  -- write enable
  signal next_adsp     : std_logic;  -- address register enable
  signal next_adsc     : std_logic;  -- address register enable
  signal next_adv      : std_logic;  -- address advance

  signal reg_oen       : std_logic;
  signal reg_cen       : std_logic;
  signal reg_gwn       : std_logic;
  signal reg_adspn     : std_logic;
  signal reg_adscn     : std_logic;
  signal reg_advn      : std_logic;
  signal ram_clock     : std_logic;
  signal next_ram_data   : std_logic_vector(17 downto 0);
  signal reg_ram_data    : std_logic_vector(17 downto 0);
  signal reg_ram_data_in : std_logic_vector(17 dowtno 0);

  signal last_oe       : std_logic;
  signal current_oe    : std_logic;

begin

RAM_CEN   <= reg_cen;
RAM_OEN   <= reg_oen;
RAM_GWN   <= reg_gwn;
RAM_ADSPN <= reg_adspn;
RAM_ADSCN <= reg_adscn;
RAM_ADVN  <= reg_advn;
RAM_CLK   <= ram_clock;

  THE_RAM_CLOCK : ddr_off
    port map (
      Clk              => CLK,
      Data(1 downto 0) => "01",
      Q(0)             => ram_clock
      );


  THE_DATA_OUTPUT_PROC : process(last_oe, reg_ram_data)
    begin
      if last_oe = '1' then
        RAM_DATA <= (others => 'Z');
      else
        RAM_DATA <= reg_ram_data;
      end if;
    end process;


  THE_DATA_INPUT_SYNC : process(CLK)
    begin
      if rising_edge(CLK) then
        reg_ram_data_in <= RAM_DATA;
      end if;
    end process;


  THE_OUTPUT_SYNC : process(CLK)
    begin
      if rising_edge(CLK) then
        reg_oen   <= not next_oe;
        reg_cen   <= not next_ce;
        reg_gwn   <= not next_gw;
        reg_adspn <= not next_adsp;
        reg_adscn <= not next_adsc;
        reg_advn  <= not next_adv;
      end if;
    end process;



  THE_FSM_SYNC : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_state <= IDLE;
        else
          current_state <= next_state;
          current_oe    <= next_oe;
          last_oe       <= current_oe;
        end if;
      end if;
    end process;

  THE_MAIN_FSM : process(current_state)
    begin
      next_state <= current_state;
      next_oe    <= '0';
      next_ce    <= not RESET;
      next_gw    <= '0';
      next_adsp  <= '0';
      next_adsc  <= '0';
      next_adv   <= '0';
      next_ram_data <= reg_ram_data;

      case current_state is
        when IDLE =>
      end case;
    end process;





end architecture;