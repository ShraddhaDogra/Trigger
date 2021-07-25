library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
library work;
  use work.trb_net_components.all;
  use work.trb_net_std.all;
  use work.trb3_components.all;
  use work.config.all;

entity sci_reader is

  port(
    CLK         : in std_logic;
    RESET       : in std_logic;
    
    --SCI
    SCI_WRDATA  : out std_logic_vector(7 downto 0);
    SCI_RDDATA  : in  std_logic_vector(7 downto 0);
    SCI_ADDR    : out std_logic_vector(5 downto 0);
    SCI_SEL     : out std_logic_vector(4 downto 0);
    SCI_RD      : out std_logic;
    SCI_WR      : out std_logic;
    
    WA_POS_OUT  : out std_logic_vector(15 downto 0);
    
    --Slowcontrol
    BUS_RX      : in  CTRLBUS_RX;
    BUS_TX      : out CTRLBUS_TX;    
    
    MEDIA_STATUS_REG_IN : in std_logic_vector(127 downto 0);
    DEBUG_OUT   : out std_logic_vector(31 downto 0)
    );
end entity;



architecture sci_reader_arch of sci_reader is

signal sci_reg_i  : std_logic;
type sci_ctrl is (IDLE, SCTRL, SCTRL_WAIT, SCTRL_WAIT2, SCTRL_FINISH, GET_WA, GET_WA_WAIT, GET_WA_WAIT2, GET_WA_FINISH);
signal sci_state         : sci_ctrl;
signal sci_timer         : unsigned(12 downto 0) := (others => '0');
signal wa_position       : std_logic_vector(15 downto 0);

begin

-- gen_output : for i in 0 to 3 generate    
--   -- Master does not do bit-locking  
--   SYNC_WA_POSITION : process begin
--     wait until rising_edge(CLK);
--     if IS_SYNC_SLAVE(i) = 1 then
--       WA_POS_OUT(i*4+3 downto i*4) <= wa_position(i*4+3 downto i*4);
--     else
--       WA_POS_OUT(i*4+3 downto i*4) <= x"0000";
--     end if;
--   end process;
-- end generate;

WA_POS_OUT <= wa_position;

-------------------------------------------------      
-- SCI
-------------------------------------------------      
--gives access to serdes config port from slow control and reads word alignment every ~ 40 us
  BUS_TX.unknown <= '0';
  BUS_TX.rack    <= '0';
  BUS_TX.wack    <= '0';

PROC_SCI_CTRL: process 
  variable cnt : integer range 0 to 4 := 0;
begin
  wait until rising_edge(CLK);
  BUS_TX.ack <= '0';
  BUS_TX.nack <= '0';
  case sci_state is
    when IDLE =>
      SCI_SEL     <= (others => '0');
      sci_reg_i   <= '0';
      SCI_RD      <= '0';
      SCI_WR      <= '0';
      sci_timer   <= sci_timer + 1;
      if BUS_RX.read = '1' or BUS_RX.write = '1' then
        SCI_SEL(0)    <= not BUS_RX.addr(6) and not BUS_RX.addr(7) and not BUS_RX.addr(8);
        SCI_SEL(1)    <=     BUS_RX.addr(6) and not BUS_RX.addr(7) and not BUS_RX.addr(8);
        SCI_SEL(2)    <= not BUS_RX.addr(6) and     BUS_RX.addr(7) and not BUS_RX.addr(8);
        SCI_SEL(3)    <=     BUS_RX.addr(6) and     BUS_RX.addr(7) and not BUS_RX.addr(8);
        SCI_SEL(4)    <= not BUS_RX.addr(6) and not BUS_RX.addr(7) and     BUS_RX.addr(8);
        sci_reg_i     <=     BUS_RX.addr(6) and not BUS_RX.addr(7) and     BUS_RX.addr(8);
        SCI_ADDR      <= BUS_RX.addr(5 downto 0);
        SCI_WRDATA    <= BUS_RX.data(7 downto 0);
        SCI_RD        <= BUS_RX.read  and not (BUS_RX.addr(6) and not BUS_RX.addr(7) and     BUS_RX.addr(8));
        SCI_WR        <= BUS_RX.write and not (BUS_RX.addr(6) and not BUS_RX.addr(7) and     BUS_RX.addr(8));
        sci_state     <= SCTRL;
      elsif sci_timer(sci_timer'left) = '1' then
        sci_timer     <= (others => '0');
        sci_state     <= GET_WA;
      end if;      
    when SCTRL =>
      if sci_reg_i = '1' then
        BUS_TX.data   <= MEDIA_STATUS_REG_IN(32*(to_integer(unsigned(BUS_RX.addr(3 downto 0))))+31 downto 32*(to_integer(unsigned(BUS_RX.addr(3 downto 0)))));
        BUS_TX.ack    <= '1';
        SCI_WR        <= '0';
        SCI_RD        <= '0';
        sci_state     <= IDLE;
      else
        sci_state     <= SCTRL_WAIT;
      end if;
    when SCTRL_WAIT   =>
      sci_state       <= SCTRL_WAIT2;
    when SCTRL_WAIT2  =>
      sci_state       <= SCTRL_FINISH;
    when SCTRL_FINISH =>
      BUS_TX.data(7 downto 0) <= SCI_RDDATA;
      BUS_TX.ack      <= '1';
      SCI_WR          <= '0';
      SCI_RD          <= '0';
      sci_state       <= IDLE;
    
    when GET_WA =>
      if cnt = 4 then
        cnt           := 0;
        sci_state     <= IDLE;
      else
        sci_state     <= GET_WA_WAIT;
        SCI_ADDR      <= "100010";--'0' & x"22";
        SCI_SEL       <= (others => '0');
        SCI_SEL(cnt)  <= '1';
        SCI_RD        <= '1';
      end if;
    when GET_WA_WAIT  =>
      sci_state       <= GET_WA_WAIT2;
    when GET_WA_WAIT2 =>
      sci_state       <= GET_WA_FINISH;
    when GET_WA_FINISH =>
      wa_position(cnt*4+3 downto cnt*4) <= SCI_RDDATA(3 downto 0);
      sci_state       <= GET_WA;    
      cnt             := cnt + 1;
  end case;
  
  if (BUS_RX.read = '1' or BUS_RX.write = '1') and sci_state /= IDLE then
    BUS_TX.nack <= '1'; BUS_TX.ack <= '0';
  end if;
  
end process;

end architecture;