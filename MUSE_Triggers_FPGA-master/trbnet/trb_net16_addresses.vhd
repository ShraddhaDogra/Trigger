LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
library work;
use work.trb_net_std.all;


entity trb_net16_addresses is
  generic(
    INIT_ADDRESS     : std_logic_vector(15 downto 0) := x"FFFF";
    INIT_UNIQUE_ID   : std_logic_vector(63 downto 0) := x"1000_2000_3654_4876";
    INIT_BOARD_INFO  : std_logic_vector(31 downto 0) := x"1111_2222";
    INIT_ENDPOINT_ID : std_logic_vector(15 downto 0)  := x"0001"
    );
  port(
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    API_DATA_IN         : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
    API_PACKET_NUM_IN   : in std_logic_vector(c_NUM_WIDTH-1 downto 0);
    API_DATAREADY_IN    : in  std_logic;
    API_READ_OUT        : out std_logic;
    RAM_DATA_IN         : in  std_logic_vector(15 downto 0);
    RAM_DATA_OUT        : out std_logic_vector(15 downto 0);
    RAM_ADDR_IN         : in  std_logic_vector(2 downto 0);
    RAM_WR_IN           : in  std_logic;
    API_DATA_OUT        : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
    API_PACKET_NUM_OUT  : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
    API_DATAREADY_OUT   : out std_logic;
    API_READ_IN         : in  std_logic;
    ADDRESS_REJECTED    : out std_logic;
    DONT_UNDERSTAND_OUT : out std_logic;
    API_SEND_OUT        : out std_logic;
    ADDRESS_OUT         : out std_logic_vector(15 downto 0);
    STAT_DEBUG          : out std_logic_vector(15 downto 0)
    );
end entity;

architecture trb_net16_addresses_arch of trb_net16_addresses is
  -- Placer Directives
--   attribute HGROUP : string;
  -- for whole architecture
--   attribute HGROUP of trb_net16_addresses_arch : architecture  is "RegIO_group";


  component ram_16x16_dp is
    generic(
      INIT0 : std_logic_vector(15 downto 0) := x"0000";
      INIT1 : std_logic_vector(15 downto 0) := x"0000";
      INIT2 : std_logic_vector(15 downto 0) := x"0000";
      INIT3 : std_logic_vector(15 downto 0) := x"0000";
      INIT4 : std_logic_vector(15 downto 0) := x"0000";
      INIT5 : std_logic_vector(15 downto 0) := x"0000";
      INIT6 : std_logic_vector(15 downto 0) := x"0000";
      INIT7 : std_logic_vector(15 downto 0) := x"0000";
      INIT8 : std_logic_vector(15 downto 0) := x"12A0";
      INIT9 : std_logic_vector(15 downto 0) := x"23b1";
      INITA : std_logic_vector(15 downto 0) := x"34c2";
      INITB : std_logic_vector(15 downto 0) := x"49d3";
      INITC : std_logic_vector(15 downto 0) := x"56e5";
      INITD : std_logic_vector(15 downto 0) := x"67d5";
      INITE : std_logic_vector(15 downto 0) := x"7818";
      INITF : std_logic_vector(15 downto 0) := x"8927"
      );
    port(
      CLK   : in  std_logic;
      wr1   : in  std_logic;
      a1    : in  std_logic_vector(3 downto 0);
      dout1 : out std_logic_vector(15 downto 0);
      din1  : in  std_logic_vector(15 downto 0);
      a2    : in  std_logic_vector(3 downto 0);
      dout2 : out std_logic_vector(15 downto 0)
      );
  end component;

signal ram_read_addr : std_logic_vector(3 downto 0);
signal ram_read_dout : std_logic_vector(15 downto 0);
signal matching_counter : std_logic_vector(2 downto 0);
signal ram_read_addr1 : std_logic_vector(3 downto 0);
signal ram_read_addr2 : std_logic_vector(3 downto 0);
signal last_ram_read_addr2 : std_logic_vector(3 downto 0);
signal buf_API_PACKET_NUM_OUT : std_logic_vector(c_NUM_WIDTH-1 downto 0);
signal buf_API_READ_OUT : std_logic;
signal buf_API_SEND_OUT : std_logic;
signal recv_set_address : std_logic;

signal next_state, state : std_logic_vector(c_NUM_WIDTH-1 downto 0);

type sending_state_t is (sending_idle, send_uid_1, send_uid_2, send_ack_address);
signal sending_state : sending_state_t;
signal sending_state_bits : std_logic_vector(1 downto 0);
signal buf_ADDRESS_OUT : std_logic_vector(15 downto 0) := INIT_ADDRESS;
signal delayed_buf_API_SEND_OUT : std_logic;

begin


  ram_read_addr <= ram_read_addr1 or ram_read_addr2;

  proc_read_id : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
--           buf_ADDRESS_OUT <= INIT_ADDRESS;
          ram_read_addr1 <= (others => '0');
          matching_counter <= (others => '0');
          recv_set_address <= '0';
          sending_state <= sending_idle;
        elsif CLK_EN = '1' then
          buf_API_READ_OUT <= '1';
          ADDRESS_REJECTED <= '0';
          DONT_UNDERSTAND_OUT <= '0';
          --recv_set_address    <= '0';

          --control sending state
          if buf_API_SEND_OUT = '0' then
            sending_state <= sending_idle;
          end if;
          if API_READ_IN = '1' and sending_state = send_uid_1 and buf_API_PACKET_NUM_OUT = c_F3 then
            sending_state <= send_uid_2;
          end if;

          --read incoming data
          if API_DATAREADY_IN = '1' and buf_API_READ_OUT = '1' then
            buf_API_READ_OUT <= '0';
            if API_PACKET_NUM_IN = c_F0  and recv_set_address = '0' then
              case API_DATA_IN is
                when READ_ID     =>
                  sending_state <= send_uid_1;
                  ram_read_addr1 <= "0000";
                when SET_ADDRESS => recv_set_address <= '1';
                when others      => DONT_UNDERSTAND_OUT <= '1';
              end case;
            end if;
            if recv_set_address = '1' then
              ram_read_addr1 <= ram_read_addr1 + 1;
              if API_DATA_IN = ram_read_dout then
                matching_counter <= matching_counter + 1;
              end if;
              if ram_read_addr1 = "0101" then
                matching_counter <= "000";
                ram_read_addr1   <= "0000";
                recv_set_address <= '0';
                if matching_counter = "101" then
                  buf_ADDRESS_OUT   <= API_DATA_IN;
                  sending_state <= send_ack_address;
                else
                  ADDRESS_REJECTED <= '1';
                end if;
              end if;
            end if;
          end if;
          if sending_state /= sending_idle then
            ram_read_addr1 <= "0000";
          end if;
        end if;
      end if;
    end process;

  proc_send_ack : process(state, API_READ_IN, ram_read_dout, last_ram_read_addr2, sending_state)
    begin
      next_state <= state;
      API_DATA_OUT <= ram_read_dout;
      ram_read_addr2 <= last_ram_read_addr2;
      if state = c_H0 then
        API_DATAREADY_OUT <= '0';
      else
        API_DATAREADY_OUT <= '1';
      end if;
      if sending_state /= sending_idle then
        buf_API_SEND_OUT <= '1';
      else
        buf_API_SEND_OUT <= '0';
      end if;
      buf_API_PACKET_NUM_OUT <= state;

      case state is
        when c_H0 =>  --idle
         if sending_state = send_ack_address then
            ram_read_addr2 <= "0101";
            next_state <= c_F0;
          elsif sending_state = send_uid_1 then
            ram_read_addr2 <= "0000";
            next_state <= c_F0;
          end if;
        when c_F0 =>
          if API_READ_IN = '1' then
            case sending_state is
              when send_uid_1       =>  ram_read_addr2 <= "0001";
              when send_uid_2       =>  ram_read_addr2 <= "0110";
              when send_ack_address =>  ram_read_addr2 <= "0110";
              when sending_idle     =>  null;
            end case;
            next_state <= c_F1;
          end if;
        when c_F1 =>
          if API_READ_IN = '1' then
            case sending_state is
              when send_uid_1       =>  ram_read_addr2 <= "0010";
              when send_uid_2       =>  ram_read_addr2 <= "0111";
              when send_ack_address =>  ram_read_addr2 <= "0111";
              when sending_idle     =>  null;
            end case;
            next_state <= c_F2;
          end if;
        when c_F2 =>
          if API_READ_IN = '1' then
            case sending_state is
              when send_uid_1       =>  ram_read_addr2 <= "0011";
              when send_uid_2       =>  ram_read_addr2 <= "1111";
              when send_ack_address =>  ram_read_addr2 <= "1111";
              when sending_idle     =>  null;
            end case;
            next_state <= c_F3;
          end if;
        when c_F3 =>
          if API_READ_IN = '1' then
            case sending_state is
              when send_uid_1       =>
                ram_read_addr2 <= "0100";
                next_state <= c_F0;
              when send_uid_2       =>
                ram_read_addr2 <= "0000";
                buf_API_SEND_OUT <= '0';
                next_state <= c_H0;
              when send_ack_address =>
                ram_read_addr2 <= "0000";
                buf_API_SEND_OUT <= '0';
                next_state <= c_H0;
              when sending_idle     =>  null;
            end case;
          end if;
        when others => null;
      end case;
    end process;

  sending_state_bits <= "00" when sending_state = send_uid_1 else
                        "01" when sending_state = send_uid_2 else
                        "10" when sending_state = send_ack_address else
                        "11" ;--when sending_state = sending_idle;


  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          state <= c_H0;
          last_ram_read_addr2 <= "0000";
          delayed_buf_API_SEND_OUT <= '0';
        elsif CLK_EN = '1' then
          state <= next_state;
          last_ram_read_addr2 <= ram_read_addr2;
          delayed_buf_API_SEND_OUT <= buf_API_SEND_OUT;
        end if;
      end if;
    end process;

  THE_STAT_RAM : ram_16x16_dp
    generic map(
      INIT0 => INIT_UNIQUE_ID(15 downto 0),
      INIT1 => INIT_UNIQUE_ID(31 downto 16),
      INIT2 => INIT_UNIQUE_ID(47 downto 32),
      INIT3 => INIT_UNIQUE_ID(63 downto 48),
      INIT4 => INIT_ENDPOINT_ID,
      INIT5 => ACK_ADDRESS,
      INIT6 => INIT_BOARD_INFO(15 downto 0),
      INIT7 => INIT_BOARD_INFO(31 downto 16),
      INIT8 => SET_ADDRESS,
      INIT9 => x"0000",
      INITA => x"0000",
      INITB => x"0000",
      INITC => x"0000",
      INITD => x"0000",
      INITE => x"0000",
      INITF => x"0000"   --F fixed to 0!
      )
    port map(
      CLK     => CLK,
      wr1     => RAM_WR_IN,
      a1(2 downto 0) => RAM_ADDR_IN,
      a1(3)   => '0',
      din1    => RAM_DATA_IN,
      dout1   => RAM_DATA_OUT,
      a2      => ram_read_addr,
      dout2   => ram_read_dout
      );

API_READ_OUT <= buf_API_READ_OUT;
API_SEND_OUT <= delayed_buf_API_SEND_OUT;
API_PACKET_NUM_OUT <= buf_API_PACKET_NUM_OUT;
ADDRESS_OUT <= buf_ADDRESS_OUT;





STAT_DEBUG(2 downto 0)   <= ram_read_addr1(2 downto 0);
STAT_DEBUG(6 downto 3)   <= ram_read_addr2;
STAT_DEBUG(7)            <= API_DATAREADY_IN;
STAT_DEBUG(9 downto 8)   <= state(1 downto 0);
STAT_DEBUG(11 downto 10) <= sending_state_bits;
STAT_DEBUG(15 downto 12) <= "0000"; --added by regio!

--   STAT_ADDR_DEBUG(12) <= buf_API_DATAREADY_OUT;  --dataready out of Regio
--   STAT_ADDR_DEBUG(13) <= ADR_REJECTED;
--   STAT_ADDR_DEBUG(14) <= ADR_SEND_OUT;
--   STAT_ADDR_DEBUG(15) <= ADR_DATAREADY_OUT;      --dataready out of addresses

end architecture;