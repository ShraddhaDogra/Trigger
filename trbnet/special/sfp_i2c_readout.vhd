library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


entity sfp_i2c_readout is
  generic(
    SFP_NUMBER : integer := 6
    );
  port(
    CLOCK     : in  std_logic;
    RESET     : in  std_logic;
    
    BUS_DATA_IN   : in  std_logic_vector(31 downto 0);
    BUS_DATA_OUT  : out std_logic_vector(31 downto 0);
    BUS_ADDR_IN   : in  std_logic_vector(7 downto 0);
    BUS_WRITE_IN  : in  std_logic;
    BUS_READ_IN   : in  std_logic;
    BUS_ACK_OUT   : out std_logic;
    BUS_NACK_OUT  : out std_logic;
    
    SDA           : inout std_logic_vector(SFP_NUMBER-1 downto 0);
    SCL           : out std_logic_vector(SFP_NUMBER-1 downto 0)
    );
end entity;

architecture sfp_i2c_readout_arch of sfp_i2c_readout is

---------------------------------------------------------------
-- SFP_ADDRESS values:                                        |
--------------------------------------------------------------|
-- x"60" => Internally measured module temperature            |
-- x"62" => Voltage                                           |
-- x"64" => TX current                                        |
-- x"66" => Measured TX optical output power                  |
-- x"68" => Measured RX optical input power                   |
---------------------------------------------------------------


signal start_i   : std_logic;
signal data_i    : std_logic_vector(15 downto 0);
signal done_i    : std_logic;
signal address_i : std_logic_vector(7 downto 0);

signal sfp_i     : integer range 0 to 15;
signal reg_i     : std_logic_vector(7 downto 0);
signal override_i: std_logic;
signal override_addr : std_logic_vector(7 downto 0);
signal debug_i   : std_logic_vector(31 downto 0);
signal devaddress_i : std_logic_vector(7 downto 0);

type ram_t is array(0 to 255) of std_logic_vector(15 downto 0);
signal ram : ram_t;

type state_t is (IDLE, START_SFP, START_REG, GET_DATA,NEXT_REG);
signal state : state_t;

begin

  debug_i(15 downto 12) <= std_logic_vector(to_unsigned(sfp_i,4));
  debug_i(23 downto 16) <= reg_i;
  debug_i(31 downto 24) <= data_i(7 downto 0);
  
  THE_I2C_CONTROLLER : Sfp_Interface
    port map(
      CLK_IN  => CLOCK,
      RST_IN  => RESET,
      START_PULSE => start_i,
      DATA_OUT => data_i,
      DEVICE_ADDRESS => devaddress_i,
      READ_DONE => done_i,
      SFP_ADDRESS => address_i,
      SCL(SFP_NUMBER-1 downto 0) => SCL,
      SDA(SFP_NUMBER-1 downto 0) => SDA,
      DEBUG(7 downto 0) => debug_i(7 downto 0)
      );



  devaddress_i(7 downto 4) <= x"0";
  devaddress_i(3 downto 0) <= std_logic_vector(to_unsigned(sfp_i,4));

  proc_i2c_ctrl : process begin
    wait until rising_edge(CLOCK);
    address_i <= reg_i;
    start_i   <= '0';
    case state is
      when IDLE =>
        reg_i <= x"60";
        sfp_i <= 0;
        state <= START_REG;
        debug_i(11 downto 8) <= x"1";
        
      when START_REG =>
        debug_i(11 downto 8) <= x"2";
        if debug_i(7 downto 0) = x"01" then
          state   <= GET_DATA;
          start_i <= '1';
        end if;
        
      when GET_DATA =>
        debug_i(11 downto 8) <= x"3";
        if done_i = '1' then
          state <= NEXT_REG;
          if override_i = '0' then
            ram(sfp_i*16+to_integer(unsigned(reg_i(3 downto 1)))) <= data_i;
          else
            ram(sfp_i*16+15) <= data_i;
          end if;
        end if;
        
      when NEXT_REG =>
        debug_i(11 downto 8) <= x"4";
        if override_i = '1' then
          reg_i <= override_addr;
        elsif reg_i >= x"68" then
          reg_i <= x"60";
        else
          reg_i <= std_logic_vector(unsigned(reg_i) + 2);
        end if;
        if override_i = '1' or reg_i = x"68" then
          if sfp_i = SFP_NUMBER -1 then
            sfp_i <= 0;
          else
            sfp_i <= sfp_i + 1;
          end if;
        end if;
        state <= START_REG;
    end case;
    if RESET = '1' then
      state <= IDLE;
    end if;
  end process;
  
  
  proc_sctrl : process begin
    wait until rising_edge(CLOCK);
    BUS_ACK_OUT  <= '0';
    BUS_NACK_OUT <= '0';
    BUS_DATA_OUT <= x"EE000000";
    if BUS_READ_IN = '1' then
      if BUS_ADDR_IN = x"FF" then
        BUS_ACK_OUT <= '1';
        BUS_DATA_OUT <= debug_i;
      else
        BUS_ACK_OUT <= '1';
        BUS_DATA_OUT(31 downto 16) <= x"0000";
        BUS_DATA_OUT(15 downto 0)  <= ram(to_integer(unsigned(BUS_ADDR_IN)));
      end if;
    elsif BUS_WRITE_IN = '1' then
      if BUS_ADDR_IN = x"FF" then
        BUS_ACK_OUT  <= '1';
        override_i    <= BUS_DATA_IN(8);
        override_addr <= BUS_DATA_IN(7 downto 0);
      else
        BUS_NACK_OUT <= '1';
      end if;
    end if;
  end process;

end architecture;