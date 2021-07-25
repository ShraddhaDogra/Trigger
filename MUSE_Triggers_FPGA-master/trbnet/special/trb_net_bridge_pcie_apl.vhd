library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


entity trb_net_bridge_pcie_apl is
    generic(
      USE_CHANNELS : channel_config_t := (c_YES,c_YES,c_NO,c_YES)
      );
    port(
      CLK     : in std_logic;
      RESET   : in std_logic;
      CLK_EN  : in std_logic;

      --TrbNet connect
      APL_DATA_OUT           : out std_logic_vector (16*3-1 downto 0);
      APL_PACKET_NUM_OUT     : out std_logic_vector (3*3-1 downto 0);
      APL_DATAREADY_OUT      : out std_logic_vector (3-1 downto 0);
      APL_READ_IN            : in  std_logic_vector (3-1 downto 0);
      APL_SHORT_TRANSFER_OUT : out std_logic_vector (3-1 downto 0);
      APL_DTYPE_OUT          : out std_logic_vector (4*3-1 downto 0);
      APL_ERROR_PATTERN_OUT  : out std_logic_vector (32*3-1 downto 0);
      APL_SEND_OUT           : out std_logic_vector (3-1 downto 0);
      APL_TARGET_ADDRESS_OUT : out std_logic_vector (16*3-1 downto 0);
      APL_DATA_IN            : in  std_logic_vector (16*3-1 downto 0);
      APL_PACKET_NUM_IN      : in  std_logic_vector (3*3-1 downto 0);
      APL_TYP_IN             : in  std_logic_vector (3*3-1 downto 0);
      APL_DATAREADY_IN       : in  std_logic_vector (3-1 downto 0);
      APL_READ_OUT           : out std_logic_vector (3-1 downto 0);
      APL_RUN_IN             : in  std_logic_vector (3-1 downto 0);
      APL_SEQNR_IN           : in  std_logic_vector (8*3-1 downto 0);
      APL_FIFO_COUNT_IN      : in  std_logic_vector (11*3-1 downto 0);

      --Internal Data Bus
      BUS_ADDR_IN            : in  std_logic_vector(31 downto 0);
      BUS_WDAT_IN            : in  std_logic_vector(31 downto 0);
      BUS_RDAT_OUT           : out std_logic_vector(31 downto 0);
      BUS_SEL_IN             : in  std_logic_vector(3 downto 0);
      BUS_WE_IN              : in  std_logic;
      BUS_CYC_IN             : in  std_logic;
      BUS_STB_IN             : in  std_logic;
      BUS_LOCK_IN            : in  std_logic;
      BUS_ACK_OUT            : out std_logic;

      EXT_TRIGGER_INFO       : out std_logic_vector(15 downto 0);
      SEND_RESET_OUT         : out std_logic;
      --DMA interface

      --Debug
      STAT                   : out std_logic_vector (31 downto 0);
      CTRL                   : in  std_logic_vector (31 downto 0)
      );
end entity;



--700 - 71F DMA configuration



architecture trb_net_bridge_pcie_apl_arch of trb_net_bridge_pcie_apl is
  signal fifo_net_to_pci_read    : std_logic_vector(3 downto 0);
  signal fifo_net_to_pci_dout    : std_logic_vector(32*4-1 downto 0);
  signal fifo_net_to_pci_valid_read : std_logic_vector(3 downto 0);
  signal fifo_net_to_pci_empty   : std_logic_vector(3 downto 0);
  signal next_APL_SEND_OUT : std_logic_vector(2 downto 0);
  signal sender_control : std_logic_vector(32*4-1 downto 0);
  signal sender_target  : std_logic_vector(32*4-1 downto 0);
  signal sender_error   : std_logic_vector(32*4-1 downto 0);
  signal sender_status  : std_logic_vector(32*4-1 downto 0);
  signal api_status     : std_logic_vector(32*4-1 downto 0);

  signal channel_address : integer range 0 to 3;

  signal bus_ack_i        : std_logic := '0';
  signal bus_data_i       : std_logic_vector(31 downto 0) := (others => '0');
  signal bus_rdat_i       : std_logic_vector(31 downto 0) := (others => '0');
  signal bus_read_i       : std_logic := '0';
  signal bus_write_i      : std_logic := '0';
  signal bus_stb_rising   : std_logic := '0';
  signal bus_stb_last     : std_logic := '0';
  signal bus_write_last   : std_logic := '0';
  signal bus_read_last    : std_logic := '0';

  signal send_reset_counter : unsigned(10 downto 0);

begin


  STAT(9 downto 0)   <= BUS_ADDR_IN(9 downto 0);
  STAT(10) <= bus_read_i;
  STAT(11) <= bus_write_i;
  STAT(12) <= bus_ack_i;
  STAT(13) <= fifo_net_to_pci_read(1);
  STAT(15 downto 14) <= BUS_WDAT_IN(1 downto 0);
  STAT(16) <= '0'; --fifo_pci_to_net_read(1);
  STAT(17) <= '0'; --fifo_pci_to_net_valid_read(1);
  STAT(18) <= '0'; --fifo_pci_to_net_empty(1);
  STAT(19) <= '0'; --fifo_pci_to_net_write(1);
  STAT(20) <= APL_READ_IN(1);
  STAT(21) <= '0'; --fifo_pci_to_net_full(1);
  STAT(22) <= RESET;
  STAT(23) <= '0';
  STAT(24) <= fifo_net_to_pci_empty(1);
  STAT(25) <= fifo_net_to_pci_read(1);
  STAT(26) <= '0'; --fifo_net_to_pci_write(1);
  STAT(31 downto 27) <= (others => '0');

--------------------------------
-- r/w registers
--------------------------------

  process(CLK)
    begin
      if rising_edge(CLK) then
        bus_stb_last   <= BUS_STB_IN;
        bus_read_last  <= bus_read_i;
        bus_write_last <= bus_write_i;
      end if;
    end process;

  bus_stb_rising <= BUS_STB_IN and not bus_stb_last;
  bus_read_i     <= not BUS_WE_IN and bus_stb_rising;
  bus_write_i    <= BUS_WE_IN and bus_stb_rising;

  channel_address <= to_integer(unsigned(BUS_ADDR_IN(6 downto 5)));

  read_regs : process(sender_control, sender_target, sender_error, sender_status, APL_FIFO_COUNT_IN,
          BUS_ADDR_IN, api_status, fifo_net_to_pci_empty, bus_data_i, channel_address, fifo_net_to_pci_dout)
		variable tmp : std_logic_vector(7 downto 0);
    begin
      bus_data_i <= (others => '0');
			tmp := BUS_ADDR_IN(11 downto 8) & BUS_ADDR_IN(3 downto 0);
        case tmp is
                           --middle nibble is dont care
          when x"10" =>
            bus_data_i <= sender_control(channel_address*32+31 downto channel_address*32);
--           when x"11" =>
--             bus_data_i <= sender_target(channel_address*32+31 downto channel_address*32);
          when x"12" =>
            bus_data_i <= sender_error(channel_address*32+31 downto channel_address*32);
--           when x"14" =>
--             bus_data_i <= x"000" & "00" & fifo_pci_to_net_empty(channel_address) & fifo_pci_to_net_full(channel_address)
--                                   & "000000" & fifo_pci_to_net_data_count(channel_address)(9 downto 0);
          when x"1F" =>
            bus_data_i <= sender_status(channel_address*32+31 downto channel_address*32);
          when x"23" =>
            bus_data_i <= fifo_net_to_pci_dout(channel_address*32+31 downto channel_address*32);
          when x"24" =>
            bus_data_i <= x"000" & "00" & fifo_net_to_pci_empty(channel_address) & '0'
                                  & "00000" & APL_FIFO_COUNT_IN(11*channel_address+10 downto 11*channel_address);
          when x"30" =>--     fifo_pci_to_net_read(i) <= APL_READ_IN(i);   --NOT CORRECT - last packet may be lost, but transfer size is limited anyhow

            bus_data_i <= api_status(channel_address*32+31 downto channel_address*32);
          when others         =>
            bus_data_i <= x"10000000"; --"1000000000000000000" & CTRL(31 downto 19);
        end case;
    end process;


  write_regs : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          sender_control <= (others => '0');
          sender_target  <= (others => '0');
          sender_error   <= (others => '0');
        else
          if bus_write_i = '1' and BUS_ADDR_IN(11 downto 8) = x"1" and USE_CHANNELS(channel_address) = c_YES then
            case BUS_ADDR_IN(3 downto 0) is
                            --middle nibble is dont care
              when x"0" =>
                sender_control(channel_address*32+31 downto channel_address*32) <= BUS_WDAT_IN(31 downto 0);
              when x"1" =>
                sender_target(channel_address*32+15 downto channel_address*32) <= BUS_WDAT_IN(15 downto 0);
              when x"2" =>
                sender_error(channel_address*32+31 downto channel_address*32) <= BUS_WDAT_IN(31 downto 0);
              when others => null;
            end case;
          end if;
        end if;
      end if;
    end process;


  proc_save_trigger_info : process(CLK)
    begin
      if rising_edge(CLK) then
        if BUS_ADDR_IN = x"00000115" and bus_write_i = '1' then
          EXT_TRIGGER_INFO <= BUS_WDAT_IN(15 downto 0);
        end if;
      end if;
    end process;


--------------------------------
-- connection to API
--------------------------------


  process(CLK)
    begin
      if rising_edge(CLK) then
        APL_SEND_OUT <= next_APL_SEND_OUT;
      end if;
    end process;


  api_status(0*32+7 downto 0*32)      <= APL_SEQNR_IN(0*8+7 downto 0*8);
  api_status(1*32+7 downto 1*32)      <= APL_SEQNR_IN(1*8+7 downto 1*8);
  api_status(2*32+7 downto 2*32)      <= (others => '0');
  api_status(3*32+7 downto 3*32)      <= APL_SEQNR_IN(2*8+7 downto 2*8);
  api_status(0*32+31 downto 0*32+8)   <= (others => '0');
  api_status(1*32+31 downto 1*32+8)   <= (others => '0');
  api_status(2*32+31 downto 2*32+8)   <= (others => '0');
  api_status(3*32+31 downto 3*32+8)   <= (others => '0');
  sender_status(0*32)                 <= APL_RUN_IN(0);
  sender_status(1*32)                 <= APL_RUN_IN(1);
  sender_status(2*32)                 <= '0';
  sender_status(3*32)                 <= APL_RUN_IN(2);
  sender_status(0*32+31 downto 0*32+1)<= (others => '0');
  sender_status(1*32+31 downto 1*32+1)<= (others => '0');
  sender_status(2*32+31 downto 2*32+1)<= (others => '0');
  sender_status(3*32+31 downto 3*32+1)<= (others => '0');

  next_APL_SEND_OUT(0) <= '1' when BUS_ADDR_IN(11 downto 8) = x"1"
                            and BUS_ADDR_IN(6 downto 5)  = "00"
                            and BUS_ADDR_IN(3 downto 0)  = x"0"
                            and bus_write_last = '1' else '0';
  next_APL_SEND_OUT(1) <= '1' when BUS_ADDR_IN(11 downto 8) = x"1"
                            and BUS_ADDR_IN(6 downto 5)  = "01"
                            and BUS_ADDR_IN(3 downto 0)  = x"0"
                            and bus_write_last = '1' else '0';
  next_APL_SEND_OUT(2) <= '1' when BUS_ADDR_IN(11 downto 8) = x"1"
                            and BUS_ADDR_IN(6 downto 5)  = "11"
                            and BUS_ADDR_IN(3 downto 0)  = x"0"
                            and bus_write_last = '1' else '0';

  APL_DATAREADY_OUT(0) <= '1' when BUS_ADDR_IN(11 downto 8) = x"1"
                            and BUS_ADDR_IN(6 downto 5)  = "00"
                            and BUS_ADDR_IN(3 downto 0)  = x"3"
                            and bus_write_i = '1' else '0';
  APL_DATAREADY_OUT(1) <= '1' when BUS_ADDR_IN(11 downto 8) = x"1"
                            and BUS_ADDR_IN(6 downto 5)  = "01"
                            and BUS_ADDR_IN(3 downto 0)  = x"3"
                            and bus_write_i = '1' else '0';
  APL_DATAREADY_OUT(2) <= '1' when BUS_ADDR_IN(11 downto 8) = x"1"
                            and BUS_ADDR_IN(6 downto 5)  = "11"
                            and BUS_ADDR_IN(3 downto 0)  = x"3"
                            and bus_write_i = '1' else '0';

  APL_DATA_OUT           <= BUS_WDAT_IN(15 downto 0) & BUS_WDAT_IN(15 downto 0) & BUS_WDAT_IN(15 downto 0);
  APL_PACKET_NUM_OUT     <= '0' & BUS_WDAT_IN(17 downto 16) & '0' & BUS_WDAT_IN(17 downto 16) & '0' & BUS_WDAT_IN(17 downto 16);
  APL_SHORT_TRANSFER_OUT <= sender_control(96+8) & sender_control(32+8) & sender_control(8);
  APL_ERROR_PATTERN_OUT  <= sender_error(127 downto 96) & sender_error(63 downto 32) & sender_error(31 downto 0);
--   APL_TARGET_ADDRESS_OUT <= sender_control(127 downto 112) & sender_control(63 downto 48) & sender_control(31 downto 16);
  APL_TARGET_ADDRESS_OUT <= sender_target(111 downto 96) & sender_target(47 downto 32) & sender_target(15 downto 0);
  APL_DTYPE_OUT          <= sender_control(99 downto 96) & sender_control(35 downto 32) & sender_control(3 downto 0);

  APL_READ_OUT           <= fifo_net_to_pci_read(3) & fifo_net_to_pci_read(1) & fifo_net_to_pci_read(0);
  fifo_net_to_pci_empty  <= not (APL_DATAREADY_IN(2) & '0' & APL_DATAREADY_IN(1) & APL_DATAREADY_IN(0));
  fifo_net_to_pci_dout(31 downto 0)   <= "0000000" & fifo_net_to_pci_valid_read(0) & "000000"
                                        & APL_PACKET_NUM_IN(2) & APL_PACKET_NUM_IN(0) & APL_DATA_IN(15 downto 0);
  fifo_net_to_pci_dout(63 downto 32)  <= "0000000" & fifo_net_to_pci_valid_read(1) & "000000"
                                        & APL_PACKET_NUM_IN(5) & APL_PACKET_NUM_IN(3) & APL_DATA_IN(31 downto 16);
  fifo_net_to_pci_dout(95 downto 64)  <= (others => '0');
  fifo_net_to_pci_dout(127 downto 96) <= "0000000" & fifo_net_to_pci_valid_read(3) & "000000"
                                        & APL_PACKET_NUM_IN(8) & APL_PACKET_NUM_IN(6) & APL_DATA_IN(47 downto 32);



  proc_fifo_readwrite : process(BUS_ADDR_IN, bus_read_i, channel_address, APL_DATAREADY_IN, fifo_net_to_pci_read)
    begin
      fifo_net_to_pci_valid_read(0) <= fifo_net_to_pci_read(0) and APL_DATAREADY_IN(0);
      fifo_net_to_pci_valid_read(1) <= fifo_net_to_pci_read(1) and APL_DATAREADY_IN(1);
      fifo_net_to_pci_valid_read(3) <= fifo_net_to_pci_read(3) and APL_DATAREADY_IN(2);
      fifo_net_to_pci_read <= (others => '0');
      if BUS_ADDR_IN(11 downto 8) & BUS_ADDR_IN(3 downto 0) = x"23" then
        fifo_net_to_pci_read(channel_address) <= bus_read_i;
      end if;
    end process;


  bus_rdat_i   <= bus_data_i(31 downto 0);
  bus_ack_i    <= (bus_read_i or bus_write_i);

  proc_register_cpu_output : process(CLK)
    begin
      if rising_edge(CLK) then
        BUS_RDAT_OUT <= bus_rdat_i;
        BUS_ACK_OUT  <= bus_ack_i;
      end if;
    end process;

--------------------------------
-- network reset
--------------------------------
  SEND_RESET_OUT <= not send_reset_counter(10);

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          send_reset_counter <= (others => '1');
        elsif BUS_ADDR_IN = x"00000010" and bus_write_i = '1' and BUS_WDAT_IN(15) = '1'  then
          send_reset_counter <= (others => '0');
        elsif send_reset_counter(10) = '0' then
          send_reset_counter <= send_reset_counter + to_unsigned(1,1);
        end if;
      end if;
    end process;


end architecture;