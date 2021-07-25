library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;

entity trb_net16_regio_bus_handler_record is
  generic(
    PORT_NUMBER : integer range 1 to c_BUS_HANDLER_MAX_PORTS := 3;
    PORT_ADDRESSES : c_BUS_HANDLER_ADDR_t := (others => (others => '0'));
    PORT_ADDR_MASK : c_BUS_HANDLER_WIDTH_t := (others => 0);
    PORT_MASK_ENABLE : integer range 0 to 1 := 0
    );
  port(
    CLK                   : in  std_logic;
    RESET                 : in  std_logic;
    
    REGIO_RX              : in  CTRLBUS_RX;
    REGIO_TX              : out CTRLBUS_TX;

    BUS_RX                : out ctrlbus_rx_array_t(0 to PORT_NUMBER-1);
    BUS_TX                : in  ctrlbus_tx_array_t(0 to PORT_NUMBER-1);
    
    STAT_DEBUG            : out std_logic_vector(31 downto 0)
    );
end entity;


--   type CTRLBUS_TX is record
--     data       : std_logic_vector(31 downto 0);
--     ack        : std_logic;
--     wack,rack  : std_logic; --for the old-fashioned guys
--     unknown    : std_logic;
--     nack       : std_logic;
--   end record;
-- 
--   type CTRLBUS_RX is record
--     data       : std_logic_vector(31 downto 0);
--     addr       : std_logic_vector(15 downto 0);
--     write      : std_logic;
--     read       : std_logic;
--     timeout    : std_logic;
--   end record;

architecture regio_bus_handler_arch of trb_net16_regio_bus_handler_record is

  attribute syn_hier : string;
  attribute syn_hier of regio_bus_handler_arch : architecture is "hard";

  signal port_select_int      : integer range 0 to PORT_NUMBER; --c_BUS_HANDLER_MAX_PORTS;
  signal next_port_select_int : integer range 0 to PORT_NUMBER; --c_BUS_HANDLER_MAX_PORTS;

  signal buf_BUS_READ_OUT         : std_logic_vector(PORT_NUMBER downto 0) := (others => '0');
  signal buf_BUS_WRITE_OUT        : std_logic_vector(PORT_NUMBER downto 0) := (others => '0');
  signal buf_BUS_DATA_OUT         : std_logic_vector(31 downto 0) := x"00000000";
  signal buf_BUS_ADDR_OUT         : std_logic_vector(15 downto 0) := x"0000";

  signal buf_BUS_DATA_IN              : std_logic_vector(32*PORT_NUMBER+31 downto 0);
  signal buf_BUS_DATAREADY_IN         : std_logic_vector(PORT_NUMBER downto 0);
  signal buf_BUS_WRITE_ACK_IN         : std_logic_vector(PORT_NUMBER downto 0);
  signal buf_BUS_NO_MORE_DATA_IN      : std_logic_vector(PORT_NUMBER downto 0);
  signal buf_BUS_UNKNOWN_ADDR_IN      : std_logic_vector(PORT_NUMBER downto 0);
  
  attribute syn_preserve : boolean;
  attribute syn_keep : boolean;
  attribute syn_preserve of buf_BUS_ADDR_OUT : signal is true;
  attribute syn_keep of buf_BUS_ADDR_OUT : signal is true;
  attribute syn_preserve of buf_BUS_DATA_OUT : signal is true;
  attribute syn_keep of buf_BUS_DATA_OUT : signal is true;
  
begin

---------------------------------------------------------------------
--Decode Addresses
---------------------------------------------------------------------

  proc_port_select : process(REGIO_RX.addr)
    begin
      next_port_select_int <= PORT_NUMBER;
      gen_port_select : for i in 0 to PORT_NUMBER-1 loop
        if (PORT_ADDR_MASK(i) = 16 or
            (REGIO_RX.addr(15 downto PORT_ADDR_MASK(i)) = PORT_ADDRESSES(i)(15 downto PORT_ADDR_MASK(i)))) then
          next_port_select_int <= i;
        end if;
      end loop;
    end process;

---------------------------------------------------------------------
--Generate R/W strobes
---------------------------------------------------------------------

  proc_rw_signals : process(CLK)
    begin
      if rising_edge(CLK) then
--         if RESET = '1' then
--           buf_BUS_READ_OUT  <= (others => '0');
--           buf_BUS_WRITE_OUT <= (others => '0');
--           port_select_int <= PORT_NUMBER;
--         else
          buf_BUS_READ_OUT  <= (others => '0');
          buf_BUS_WRITE_OUT <= (others => '0');
          if REGIO_RX.write = '1' or REGIO_RX.read = '1' then
            buf_BUS_DATA_OUT  <= REGIO_RX.data;
            buf_BUS_ADDR_OUT  <= REGIO_RX.addr;
            port_select_int   <= next_port_select_int;
          end if;
          if REGIO_RX.read = '1' then
            buf_BUS_READ_OUT(next_port_select_int) <= '1';
          end if;
          if REGIO_RX.write = '1' then
            buf_BUS_WRITE_OUT(next_port_select_int) <= '1';
          end if;
          if (buf_BUS_DATAREADY_IN(port_select_int) or 
              buf_BUS_WRITE_ACK_IN(port_select_int) or
              buf_BUS_UNKNOWN_ADDR_IN(port_select_int) or
              buf_BUS_NO_MORE_DATA_IN(port_select_int)) = '1' then
            port_select_int <= PORT_NUMBER;
          end if;  
        end if;
--       end if;
    end process;

---------------------------------------------------------------------
--Map Data Outputs
---------------------------------------------------------------------

  gen_outputs  : for i in 0 to PORT_NUMBER-1 generate
    BUS_RX(i).read    <= buf_BUS_READ_OUT(i);
    BUS_RX(i).write   <= buf_BUS_WRITE_OUT(i);
    BUS_RX(i).data    <= buf_BUS_DATA_OUT;
    BUS_RX(i).timeout <= REGIO_RX.timeout;
    port_mask_disabled : if PORT_MASK_ENABLE = 0 generate
      BUS_RX(i).addr  <= buf_BUS_ADDR_OUT;
    end generate;   
    port_mask_enabled : if PORT_MASK_ENABLE = 1 generate
      BUS_RX(i).addr(PORT_ADDR_MASK(i)-1 downto 0)  <= buf_BUS_ADDR_OUT(PORT_ADDR_MASK(i)-1 downto 0);
      BUS_RX(i).addr(15 downto PORT_ADDR_MASK(i))   <= (others => '0');
    end generate;
  end generate;

---------------------------------------------------------------------
--Pack Data Inputs and Dummy Input
---------------------------------------------------------------------

  gen_inputs  : for i in 0 to PORT_NUMBER-1 generate
    buf_BUS_DATA_IN(i*32+31 downto i*32) <= BUS_TX(i).data;
    buf_BUS_DATAREADY_IN(i)              <= BUS_TX(i).ack or BUS_TX(i).rack;
    buf_BUS_WRITE_ACK_IN(i)              <= BUS_TX(i).ack or BUS_TX(i).wack;
    buf_BUS_NO_MORE_DATA_IN(i)           <= BUS_TX(i).nack;
    buf_BUS_UNKNOWN_ADDR_IN(i)           <= BUS_TX(i).unknown; 
  end generate;

  buf_BUS_DATA_IN(PORT_NUMBER*32+31 downto PORT_NUMBER*32) <= (others => '0');
  buf_BUS_DATAREADY_IN(PORT_NUMBER) <= '0';
  buf_BUS_WRITE_ACK_IN(PORT_NUMBER) <= '0';
  buf_BUS_NO_MORE_DATA_IN(PORT_NUMBER) <= '0';
  buf_BUS_UNKNOWN_ADDR_IN(PORT_NUMBER) <= buf_BUS_READ_OUT(PORT_NUMBER) or buf_BUS_WRITE_OUT(PORT_NUMBER);


---------------------------------------------------------------------
--Multiplex Data Output
---------------------------------------------------------------------

  proc_reg_output_signals : process(CLK)
    begin
      if rising_edge(CLK) then
        REGIO_TX.data         <= buf_BUS_DATA_IN(port_select_int*32+31 downto port_select_int*32);
        REGIO_TX.ack          <= buf_BUS_DATAREADY_IN(port_select_int) or buf_BUS_WRITE_ACK_IN(port_select_int);
        REGIO_TX.nack         <= buf_BUS_NO_MORE_DATA_IN(port_select_int);
        REGIO_TX.unknown      <= buf_BUS_UNKNOWN_ADDR_IN(port_select_int);
      end if;
    end process;

---------------------------------------------------------------------
--Debugging
---------------------------------------------------------------------
  STAT_DEBUG <= (others => '0');

end architecture;
