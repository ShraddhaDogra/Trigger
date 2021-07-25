library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity spi_databus_memory is
  port(
    CLK_IN        : in   std_logic;
    RESET_IN      : in   std_logic;
    -- Slave bus
    BUS_ADDR_IN   : in   std_logic_vector(5 downto 0);
    BUS_READ_IN   : in   std_logic;
    BUS_WRITE_IN  : in   std_logic;
    BUS_ACK_OUT   : out  std_logic;
    BUS_DATA_IN   : in   std_logic_vector(31 downto 0);
    BUS_DATA_OUT  : out  std_logic_vector(31 downto 0);
    -- state machine connections
    BRAM_ADDR_IN  : in   std_logic_vector(7 downto 0);
    BRAM_WR_D_OUT : out  std_logic_vector(7 downto 0);
    BRAM_RD_D_IN  : in   std_logic_vector(7 downto 0);
    BRAM_WE_IN    : in   std_logic;
    -- Status lines
    STAT          : out  std_logic_vector(63 downto 0) -- DEBUG
  );
end entity;

architecture Behavioral of spi_databus_memory is
  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  attribute HGROUP of Behavioral : architecture  is "SPI_group";
-- Signals
  type STATES is (SLEEP,RD_RDY,WR_RDY,RD_ACK,WR_ACK,DONE);
  signal CURRENT_STATE, NEXT_STATE: STATES;

  -- slave bus signals
  signal bus_ack_x        : std_logic;
  signal bus_ack          : std_logic;
  signal store_wr_x       : std_logic;
  signal store_wr         : std_logic;
  signal store_rd_x       : std_logic;
  signal store_rd         : std_logic;
  signal buf_bus_data_out : std_logic_vector(31 downto 0);

begin

---------------------------------------------------------
-- Debugging                                           --
---------------------------------------------------------
stat(63 downto 0)  <= (others => '0');

---------------------------------------------------------
-- Statemachine                                        --
---------------------------------------------------------
  STATE_MEM: process( clk_in)
    begin
      if( rising_edge(clk_in) ) then
        if( reset_in = '1' ) then
          CURRENT_STATE <= SLEEP;
          BUS_ack       <= '0';
          store_wr      <= '0';
          store_rd      <= '0';
        else
          CURRENT_STATE <= NEXT_STATE;
          BUS_ack       <= BUS_ack_x;
          store_wr      <= store_wr_x;
          store_rd      <= store_rd_x;
        end if;
      end if;
    end process STATE_MEM;

-- Transition matrix
  TRANSFORM: process(CURRENT_STATE, BUS_read_in, BUS_write_in )
    begin
      NEXT_STATE <= SLEEP;
      BUS_ack_x  <= '0';
      store_wr_x <= '0';
      store_rd_x <= '0';
      case CURRENT_STATE is
        when SLEEP    =>
          if   ( (BUS_read_in = '1') ) then
            NEXT_STATE <= RD_RDY;
            store_rd_x <= '1';
          elsif( (BUS_write_in = '1') ) then
            NEXT_STATE <= WR_RDY;
            store_wr_x <= '1';
          else
            NEXT_STATE <= SLEEP;
          end if;

        when RD_RDY    =>
          NEXT_STATE <= RD_ACK;

        when WR_RDY    =>
          NEXT_STATE <= WR_ACK;

        when RD_ACK    =>
          if( BUS_read_in = '0' ) then
            NEXT_STATE <= DONE;
            BUS_ack_x  <= '1';
          else
            NEXT_STATE <= RD_ACK;
            BUS_ack_x  <= '1';
          end if;

        when WR_ACK    =>
          if( BUS_write_in = '0' ) then
            NEXT_STATE <= DONE;
            BUS_ack_x  <= '1';
          else
            NEXT_STATE <= WR_ACK;
            BUS_ack_x  <= '1';
          end if;

        when DONE    =>
          NEXT_STATE <= SLEEP;

        when others    =>
          NEXT_STATE <= SLEEP;
  end case;
end process TRANSFORM;


---------------------------------------------------------
-- data handling                                       --
---------------------------------------------------------

THE_BUS_SPI_DPRAM: spi_dpram_32_to_8
  port map(
      DATAINA  => BUS_data_in,
      ADDRESSA  => BUS_addr_in,
      CLOCKA  => clk_in,
      CLOCKENA  => '1',
      WRA    => store_wr,
      RESETA  => reset_in,
      QA    => buf_BUS_data_out,
      -- B side is state machine
      DATAINB  => bram_rd_d_in,
      ADDRESSB  => bram_addr_in,
      CLOCKB  => clk_in,
      CLOCKENB  => '1',
      WRB    => bram_we_in,
      RESETB  => reset_in,
      QB    => bram_wr_d_out
    );

-- output signals
BUS_data_out <= buf_BUS_data_out;
BUS_ack_out  <= BUS_ack;

end Behavioral;
