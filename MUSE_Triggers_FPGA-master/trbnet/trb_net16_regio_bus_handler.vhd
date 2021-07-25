LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

entity trb_net16_regio_bus_handler is
  generic(
    PORT_NUMBER : integer range 1 to c_BUS_HANDLER_MAX_PORTS := 3;
    PORT_ADDRESSES : c_BUS_HANDLER_ADDR_t := (others => (others => '0'));
    PORT_ADDR_MASK : c_BUS_HANDLER_WIDTH_t := (others => 0);
    PORT_MASK_ENABLE : integer range 0 to 1 := 0
    );
  port(
    CLK                   : in  std_logic;
    RESET                 : in  std_logic;
    DAT_ADDR_IN           : in  std_logic_vector(15 downto 0); -- address bus
    DAT_DATA_IN           : in  std_logic_vector(31 downto 0); -- data from TRB endpoint
    DAT_DATA_OUT          : out std_logic_vector(31 downto 0); -- data to TRB endpoint
    DAT_READ_ENABLE_IN    : in  std_logic; -- read pulse
    DAT_WRITE_ENABLE_IN   : in  std_logic; -- write pulse
    DAT_TIMEOUT_IN        : in  std_logic; -- access timed out
    DAT_DATAREADY_OUT     : out std_logic; -- your data, master, as requested
    DAT_WRITE_ACK_OUT     : out std_logic; -- data accepted
    DAT_NO_MORE_DATA_OUT  : out std_logic; -- don't disturb me now
    DAT_UNKNOWN_ADDR_OUT  : out std_logic; -- noone here to answer your request

    BUS_ADDR_OUT          : out std_logic_vector(PORT_NUMBER*16-1 downto 0);
    BUS_DATA_OUT          : out std_logic_vector(PORT_NUMBER*32-1 downto 0);
    BUS_READ_ENABLE_OUT   : out std_logic_vector(PORT_NUMBER-1 downto 0);
    BUS_WRITE_ENABLE_OUT  : out std_logic_vector(PORT_NUMBER-1 downto 0);
    BUS_TIMEOUT_OUT       : out std_logic_vector(PORT_NUMBER-1 downto 0);

    BUS_DATA_IN           : in  std_logic_vector(32*PORT_NUMBER-1 downto 0);
    BUS_DATAREADY_IN      : in  std_logic_vector(PORT_NUMBER-1 downto 0);
    BUS_WRITE_ACK_IN      : in  std_logic_vector(PORT_NUMBER-1 downto 0);
    BUS_NO_MORE_DATA_IN   : in  std_logic_vector(PORT_NUMBER-1 downto 0);
    BUS_UNKNOWN_ADDR_IN   : in  std_logic_vector(PORT_NUMBER-1 downto 0);

    STAT_DEBUG            : out std_logic_vector(31 downto 0)
    );
end entity;



architecture regio_bus_handler_arch of trb_net16_regio_bus_handler is
  -- Placer Directives
--   attribute HGROUP : string;
  -- for whole architecture
--   attribute HGROUP of regio_bus_handler_arch : architecture  is "Bus_handler_group";

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

  proc_port_select : process(DAT_ADDR_IN)
    begin
      next_port_select_int <= PORT_NUMBER;
      gen_port_select : for i in 0 to PORT_NUMBER-1 loop
        if (PORT_ADDR_MASK(i) = 16 or
            (DAT_ADDR_IN(15 downto PORT_ADDR_MASK(i)) = PORT_ADDRESSES(i)(15 downto PORT_ADDR_MASK(i)))) then
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
        if RESET = '1' then
          buf_BUS_READ_OUT  <= (others => '0');
          buf_BUS_WRITE_OUT <= (others => '0');
          port_select_int <= PORT_NUMBER;
        else
          buf_BUS_READ_OUT  <= (others => '0');
          buf_BUS_WRITE_OUT <= (others => '0');
          if DAT_WRITE_ENABLE_IN = '1' or DAT_READ_ENABLE_IN = '1' then
            buf_BUS_DATA_OUT  <= DAT_DATA_IN;
            buf_BUS_ADDR_OUT  <= DAT_ADDR_IN;
            port_select_int   <= next_port_select_int;
          end if;
          if DAT_READ_ENABLE_IN = '1' then
            buf_BUS_READ_OUT(next_port_select_int) <= '1';
          end if;
          if DAT_WRITE_ENABLE_IN = '1' then
            buf_BUS_WRITE_OUT(next_port_select_int) <= '1';
          end if;
        end if;
      end if;
    end process;

---------------------------------------------------------------------
--Map Data Outputs
---------------------------------------------------------------------

  BUS_READ_ENABLE_OUT <= buf_BUS_READ_OUT(PORT_NUMBER-1 downto 0);
  BUS_WRITE_ENABLE_OUT<= buf_BUS_WRITE_OUT(PORT_NUMBER-1 downto 0);
  gen_bus_outputs : for i in 0 to PORT_NUMBER-1 generate
    BUS_DATA_OUT(i*32+31 downto i*32)  <= buf_BUS_DATA_OUT;
    port_mask_disabled : if PORT_MASK_ENABLE = 0 generate
      BUS_ADDR_OUT(i*16+15 downto i*16)  <= buf_BUS_ADDR_OUT;
    end generate;
     port_mask_enabled : if PORT_MASK_ENABLE = 1 generate
       BUS_ADDR_OUT(i*16+15 downto i*16+PORT_ADDR_MASK(i)) <= (others => '0');
       BUS_ADDR_OUT(i*16+PORT_ADDR_MASK(i)-1 downto i*16)
         <= buf_BUS_ADDR_OUT(PORT_ADDR_MASK(i)-1 downto 0);
     end generate;
    BUS_TIMEOUT_OUT(i)                 <= DAT_TIMEOUT_IN;
  end generate;

---------------------------------------------------------------------
--Pack Data Inputs and Dummy Input
---------------------------------------------------------------------

  buf_BUS_DATA_IN(PORT_NUMBER*32-1 downto 0) <= BUS_DATA_IN;
  buf_BUS_DATAREADY_IN(PORT_NUMBER-1 downto 0) <= BUS_DATAREADY_IN;
  buf_BUS_WRITE_ACK_IN(PORT_NUMBER-1 downto 0) <= BUS_WRITE_ACK_IN;
  buf_BUS_NO_MORE_DATA_IN(PORT_NUMBER-1 downto 0) <= BUS_NO_MORE_DATA_IN;
  buf_BUS_UNKNOWN_ADDR_IN(PORT_NUMBER-1 downto 0) <= BUS_UNKNOWN_ADDR_IN;
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
        DAT_DATA_OUT          <= buf_BUS_DATA_IN(port_select_int*32+31 downto port_select_int*32);
        DAT_DATAREADY_OUT     <= buf_BUS_DATAREADY_IN(port_select_int);
        DAT_WRITE_ACK_OUT     <= buf_BUS_WRITE_ACK_IN(port_select_int);
        DAT_NO_MORE_DATA_OUT  <= buf_BUS_NO_MORE_DATA_IN(port_select_int);
        DAT_UNKNOWN_ADDR_OUT  <= buf_BUS_UNKNOWN_ADDR_IN(port_select_int);
      end if;
    end process;

---------------------------------------------------------------------
--Debugging
---------------------------------------------------------------------
  STAT_DEBUG <= (others => '0');

end architecture;
