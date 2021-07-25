library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity spi_master is
  port(
    CLK_IN          : in   std_logic;
    RESET_IN        : in   std_logic;
    -- Slave bus
    BUS_READ_IN     : in   std_logic;
    BUS_WRITE_IN    : in   std_logic;
    BUS_BUSY_OUT    : out  std_logic;
    BUS_ACK_OUT     : out  std_logic;
    BUS_ADDR_IN     : in   std_logic_vector(0 downto 0);
    BUS_DATA_IN     : in   std_logic_vector(31 downto 0);
    BUS_DATA_OUT    : out  std_logic_vector(31 downto 0);
    -- SPI connections
    SPI_CS_OUT      : out  std_logic;
    SPI_SDI_IN      : in   std_logic;
    SPI_SDO_OUT     : out  std_logic;
    SPI_SCK_OUT     : out  std_logic;
    -- BRAM for read/write data
    BRAM_A_OUT      : out  std_logic_vector(7 downto 0);
    BRAM_WR_D_IN    : in   std_logic_vector(7 downto 0);
    BRAM_RD_D_OUT   : out  std_logic_vector(7 downto 0);
    BRAM_WE_OUT     : out  std_logic;
    -- Status lines
    STAT            : out  std_logic_vector(31 downto 0) -- DEBUG
  );
end entity;

architecture Behavioral of spi_master is
  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  attribute HGROUP of Behavioral : architecture  is "SPI_group";

-- Signals
    type STATES is (SLEEP,DONE);--RD_BSY,WR_BSY,RD_RDY,WR_RDY,RD_ACK,WR_ACK
    signal CURRENT_STATE, NEXT_STATE: STATES;

    signal status_data      : std_logic_vector(31 downto 0);
    signal spi_busy         : std_logic;

    signal reg_ctrl_data    : std_logic_vector(31 downto 0); -- CMD, ADH, ADM, ADL
    signal reg_status_data  : std_logic_vector(31 downto 0); -- MAX

    signal reg_bus_data_out : std_logic_vector(31 downto 0); -- readback

    signal spi_bsm          : std_logic_vector(7 downto 0);
	  signal spi_debug		    : std_logic_vector(31 downto 0);

    signal spi_start_x      : std_logic;
    signal spi_start        : std_logic;

    -- State machine signals
    signal bus_busy_x       : std_logic;
    signal bus_busy         : std_logic;
    signal bus_ack_x        : std_logic;
    signal bus_ack          : std_logic;
    signal store_wr_x       : std_logic;
    signal store_wr         : std_logic;
    signal store_rd_x       : std_logic;
    signal store_rd         : std_logic;

    signal reset_i          : std_logic;

  attribute syn_preserve : boolean;
  attribute syn_keep : boolean;
  attribute syn_preserve of reset_i : signal is true;
  attribute syn_keep of reset_i : signal is true;

begin

process(clk_in)
  begin
    if rising_edge(clk_in) then
      reset_i <= reset_in;
    end if;
  end process;

---------------------------------------------------------
-- SPI master                                          --
---------------------------------------------------------

THE_SPI_SLIM: spi_slim
port map(
  SYSCLK        => clk_in,
  RESET         => reset_i,
  -- Command interface
  START_IN      => spi_start, -- not really nice, but should work
  BUSY_OUT      => spi_busy,
  CMD_IN        => reg_ctrl_data(31 downto 24),
  ADH_IN        => reg_ctrl_data(23 downto 16),
  ADM_IN        => reg_ctrl_data(15 downto 8),
  ADL_IN        => reg_ctrl_data(7 downto 0),
  MAX_IN        => reg_status_data(31 downto 24),
  TXDATA_IN     => bram_wr_d_in,
  TX_RD_OUT     => open, -- not needed
  RXDATA_OUT    => bram_rd_d_out,
  RX_WR_OUT     => bram_we_out,
  TX_RX_A_OUT   => bram_a_out,
  -- SPI interface
  SPI_SCK_OUT   => spi_sck_out,
  SPI_CS_OUT    => spi_cs_out,
  SPI_SDI_IN    => spi_sdi_in,
  SPI_SDO_OUT   => spi_sdo_out,
  -- DEBUG
  CLK_EN_OUT    => open, -- not needed
  BSM_OUT       => spi_bsm,
  DEBUG_OUT     => spi_debug --open -- BUG
);

---------------------------------------------------------
-- Statemachine                                        --
---------------------------------------------------------
STATE_MEM: process( clk_in )
begin
  if( rising_edge(clk_in) ) then
    if( reset_i = '1' ) then
      CURRENT_STATE <= SLEEP;
      bus_busy      <= '0';
      bus_ack       <= '0';
      store_wr      <= '0';
      store_rd      <= '0';
    else
      CURRENT_STATE <= NEXT_STATE;
      bus_busy      <= bus_busy_x;
      bus_ack       <= bus_ack_x;
      store_wr      <= store_wr_x;
      store_rd      <= store_rd_x;
    end if;
  end if;
end process STATE_MEM;

TRANSFORM: process(CURRENT_STATE, bus_read_in, bus_write_in, spi_busy, bus_addr_in )
begin
  NEXT_STATE <= SLEEP;
  bus_busy_x <= '0';
  bus_ack_x  <= '0';
  store_wr_x <= '0';
  store_rd_x <= '0';
  case CURRENT_STATE is
      when SLEEP        =>
          if   ( (spi_busy = '0') and (bus_read_in = '1') ) then
              NEXT_STATE <= DONE;
              store_rd_x <= '1';
          elsif( (spi_busy = '0') and (bus_write_in = '1') ) then
              NEXT_STATE <= DONE;
              store_wr_x <= '1';
          elsif( (bus_addr_in(0) = '0') and (spi_busy = '1') and (bus_read_in = '1') ) then
              NEXT_STATE <= SLEEP; -- CMD register is busy protected
              bus_busy_x <= '1';
          elsif( (bus_addr_in(0) = '0') and (spi_busy = '1') and (bus_write_in = '1') ) then
              NEXT_STATE <= SLEEP; -- CMD register is busy protected
              bus_busy_x <= '1';
          elsif( (bus_addr_in(0) = '1') and (spi_busy = '1') and (bus_read_in = '1') ) then
              NEXT_STATE <= DONE; -- STATUS register is not
              store_rd_x <= '1';
          elsif( (bus_addr_in(0) = '1') and (spi_busy = '1') and (bus_write_in = '1') ) then
              NEXT_STATE <= DONE; -- STATUS register is not
              store_wr_x <= '1';
          else
              NEXT_STATE <= SLEEP;
          end if;
--       when RD_RDY        =>
--           NEXT_STATE <= RD_ACK;
--           bus_ack_x  <= '1';
--       when WR_RDY        =>
--           NEXT_STATE <= WR_ACK;
--           bus_ack_x  <= '1';
--       when RD_ACK        =>
--           if( bus_read_in = '0' ) then
--               NEXT_STATE <= DONE;
--           else
--               NEXT_STATE <= RD_ACK;
--               bus_ack_x  <= '1';
--           end if;
--       when WR_ACK        =>
--           if( bus_write_in = '0' ) then
--               NEXT_STATE <= DONE;
--           else
--               NEXT_STATE <= WR_ACK;
--               bus_ack_x  <= '1';
--           end if;
--       when RD_BSY        =>
--           if( bus_read_in = '0' ) then
--               NEXT_STATE <= DONE;
--           else
--               NEXT_STATE <= RD_BSY;
--               bus_busy_x <= '1';
--           end if;
--       when WR_BSY        =>
--           if( bus_write_in = '0' ) then
--               NEXT_STATE <= DONE;
--           else
--               NEXT_STATE <= WR_BSY;
--               bus_busy_x <= '1';
--           end if;
      when DONE        =>
          NEXT_STATE <= SLEEP;
          bus_ack_x  <= '1';
      when others      =>
          NEXT_STATE <= SLEEP;
  end case;
end process TRANSFORM;

---------------------------------------------------------
-- data handling                                       --
---------------------------------------------------------

-- register write
THE_WRITE_REG_PROC: process( clk_in )
  begin
      if( rising_edge(clk_in) ) then
          if   ( reset_i = '1' ) then
              reg_ctrl_data   <= (others => '0');
              reg_status_data <= (others => '0');
              spi_start       <= '0';
          elsif( (store_wr = '1') and (bus_addr_in(0) = '0') ) then
              reg_ctrl_data   <= bus_data_in;
              spi_start       <= spi_start_x;
          elsif( (store_wr = '1') and (bus_addr_in(0) = '1') ) then
              reg_status_data <= bus_data_in;
              spi_start       <= spi_start_x;
          else
          	  spi_start       <= spi_start_x;
          end if;
      end if;
  end process THE_WRITE_REG_PROC;

spi_start_x <= '1' when ( (store_wr = '1') and (bus_addr_in(0) = '0') ) else '0';

-- register read
THE_READ_REG_PROC: process( clk_in )
  begin
      if( rising_edge(clk_in) ) then
          if   ( reset_i = '1' ) then
              reg_bus_data_out <= (others => '0');
          elsif( (store_rd = '1') and (bus_addr_in(0) = '0') ) then
              reg_bus_data_out <= reg_ctrl_data;
          elsif( (store_rd = '1') and (bus_addr_in(0) = '1') ) then
              reg_bus_data_out(31 downto 24) <= reg_status_data(31 downto 24);
              reg_bus_data_out(23 downto 16) <= x"00";
              reg_bus_data_out(15 downto 8)  <= x"00";
              reg_bus_data_out(7 downto 0)   <= spi_bsm;
          end if;
      end if;
  end process THE_READ_REG_PROC;

-- debug signals
status_data(31 downto 24) <= spi_bsm;
status_data(23)           <= spi_start;
status_data(22 downto 0)  <= (others => '0');

-- output signals
bus_ack_out       <= bus_ack;
bus_busy_out      <= bus_busy;
bus_data_out      <= reg_bus_data_out;
stat(31 downto 3) <= spi_debug(31 downto 3); --status_data;
stat(2)           <= spi_start;
stat(1)           <= bus_write_in;
stat(0)           <= bus_read_in;

end Behavioral;
