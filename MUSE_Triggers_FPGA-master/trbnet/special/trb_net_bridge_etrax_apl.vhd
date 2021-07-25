LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


entity trb_net_bridge_etrax_apl is
    port(
      CLK     : in std_logic;
      RESET   : in std_logic;
      CLK_EN  : in std_logic;
      APL_DATA_OUT           : out std_logic_vector (c_DATA_WIDTH*2**(c_MUX_WIDTH)-1 downto 0);
      APL_PACKET_NUM_OUT     : out std_logic_vector (c_NUM_WIDTH*2**(c_MUX_WIDTH)-1 downto 0);
      APL_DATAREADY_OUT      : out std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_READ_IN            : in  std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_SHORT_TRANSFER_OUT : out std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_DTYPE_OUT          : out std_logic_vector (4*2**(c_MUX_WIDTH)-1 downto 0);
      APL_ERROR_PATTERN_OUT  : out std_logic_vector (32*2**(c_MUX_WIDTH)-1 downto 0);
      APL_SEND_OUT           : out std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_TARGET_ADDRESS_OUT : out std_logic_vector (16*2**(c_MUX_WIDTH)-1 downto 0);
      APL_DATA_IN            : in  std_logic_vector (c_DATA_WIDTH*2**(c_MUX_WIDTH)-1 downto 0);
      APL_PACKET_NUM_IN      : in  std_logic_vector (c_NUM_WIDTH*2**(c_MUX_WIDTH)-1 downto 0);
      APL_TYP_IN             : in  std_logic_vector (3*2**(c_MUX_WIDTH)-1 downto 0);
      APL_DATAREADY_IN       : in  std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_READ_OUT           : out std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_RUN_IN             : in  std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_SEQNR_IN           : in  std_logic_vector (8*2**(c_MUX_WIDTH)-1 downto 0);
      CPU_READ               : in  STD_LOGIC;
      CPU_WRITE              : in  STD_LOGIC;
      CPU_DATA_OUT           : out STD_LOGIC_VECTOR (31 downto 0);
      CPU_DATA_IN            : in  STD_LOGIC_VECTOR (31 downto 0);
      CPU_DATAREADY_OUT      : out std_logic;
      CPU_ADDRESS            : in  STD_LOGIC_VECTOR (15 downto 0);
      STAT                   : out std_logic_vector (31 downto 0);
      CTRL                   : in  std_logic_vector (31 downto 0)
      );
end entity;

--address range is 100 to FFF
--  (c is channel number * 2 + 1 if active part)

--sending data. sending is released when 1c0 is written
--1c0 wr (3..0) Dtype (8) short transfer    sender_control     9bit used
--1c1 wr target address                     sender_target     16bit used
--1c2 wr Errorbits                          sender_error      32bit used
--1c3 w  sender data fifo                   sender_data       16bit used
--1c4 r  sender fifo status                 (9..0 datacount, 16 full, 17 empty)
--1c5 wr Extended Trigger Information       sender_trigger_information 16bit
--1cF r  status (0)transfer running         sender_status      1bit used



--received data
--2c3 r  receiver data fifo, (20..18)type  receiver_data      16bit used
--2c4 r  receiver fifo status              (9..0 datacount, 16 full, 17 empty)


--3c0  (7..0) seq_num         apis_tatus



architecture trb_net_bridge_etrax_apl_arch of trb_net_bridge_etrax_apl is
  signal fifo_net_to_pci_read    : std_logic_vector(2**c_MUX_WIDTH-1 downto 0);
  signal fifo_net_to_pci_write   : std_logic_vector(2**c_MUX_WIDTH-1 downto 0);
  signal fifo_net_to_pci_dout    : std_logic_vector(32*2**c_MUX_WIDTH-1 downto 0);
  signal fifo_net_to_pci_din     : std_logic_vector(18*2**c_MUX_WIDTH-1 downto 0);
  signal fifo_net_to_pci_valid_read : std_logic_vector((2**c_MUX_WIDTH)-1 downto 0);
  signal fifo_net_to_pci_full    : std_logic_vector((2**c_MUX_WIDTH)-1 downto 0);
  signal fifo_net_to_pci_empty   : std_logic_vector((2**c_MUX_WIDTH)-1 downto 0);
  signal fifo_pci_to_net_read    : std_logic_vector(2**c_MUX_WIDTH-1 downto 0);
  signal fifo_pci_to_net_write   : std_logic_vector(2**c_MUX_WIDTH-1 downto 0);
  signal fifo_pci_to_net_valid_read : std_logic_vector((2**c_MUX_WIDTH)-1 downto 0);
  signal fifo_pci_to_net_dout    : std_logic_vector(18*2**c_MUX_WIDTH-1 downto 0);
  signal fifo_pci_to_net_full    : std_logic_vector((2**c_MUX_WIDTH)-1 downto 0);
  signal fifo_pci_to_net_empty   : std_logic_vector((2**c_MUX_WIDTH)-1 downto 0);
  signal next_APL_SEND_OUT : std_logic_vector(2**c_MUX_WIDTH-1 downto 0);
  type data_count_t is array(0 to 2**c_MUX_WIDTH-1) of std_logic_vector(10 downto 0);
  signal fifo_pci_to_net_data_count   : data_count_t;
  signal fifo_net_to_pci_data_count   : data_count_t;
  signal sender_control : std_logic_vector(32*2**(c_MUX_WIDTH)-1 downto 0);
  signal sender_target  : std_logic_vector(32*2**(c_MUX_WIDTH)-1 downto 0);
  signal sender_error   : std_logic_vector(32*2**(c_MUX_WIDTH)-1 downto 0);
  signal sender_status  : std_logic_vector(32*2**(c_MUX_WIDTH)-1 downto 0);
  signal api_status     : std_logic_vector(32*2**(c_MUX_WIDTH)-1 downto 0);

  signal channel_address : integer range 0 to 7;
--  signal comb_channel_address : integer range 0 to 7;
--  signal last_CPU_ADDRESS : std_logic_vector(15 downto 0);

  signal reg_CPU_ADDRESS : std_logic_vector(15 downto 0);
  signal reg_CPU_DATA_IN : std_logic_vector(31 downto 0);
  signal next_CPU_DATA_OUT: std_logic_vector(31 downto 0);
  signal buf_CPU_DATA_OUT : std_logic_vector(31 downto 0);
  signal reg_CPU_READ      : std_logic;
  signal reg_CPU_WRITE      : std_logic;

  signal last_fifo_read : std_logic;
  signal buf_CPU_DATAREADY_OUT : std_logic;
  signal b_CPU_DATAREADY_OUT : std_logic;



begin

  CPU_DATAREADY_OUT <= b_CPU_DATAREADY_OUT;

  STAT(9 downto 0)   <= reg_CPU_ADDRESS(9 downto 0);
  STAT(10) <= CPU_READ;
  STAT(11) <= CPU_WRITE;
  STAT(12) <= b_CPU_DATAREADY_OUT;
  STAT(13) <= fifo_net_to_pci_read(1);
  STAT(15 downto 14) <= reg_CPU_DATA_IN(1 downto 0);
  STAT(16) <= fifo_pci_to_net_read(1);
  STAT(17) <= fifo_pci_to_net_valid_read(1);
  STAT(18) <= fifo_pci_to_net_empty(1);
  STAT(19) <= fifo_pci_to_net_write(1);
  STAT(20) <= APL_READ_IN(1);
  STAT(21) <= fifo_pci_to_net_full(1);
  STAT(22) <= RESET;
  STAT(23) <= '0';
  STAT(24) <= fifo_net_to_pci_empty(1);
  STAT(25) <= fifo_net_to_pci_read(1);
  STAT(26) <= fifo_net_to_pci_write(1);
  STAT(31 downto 27) <= (others => '0');

--------------------------------
-- r/w registers
--------------------------------
  channel_address <= conv_integer(reg_CPU_ADDRESS(6 downto 4));
--  comb_channel_address <= conv_integer(CPU_ADDRESS(6 downto 4));

  read_regs : process(sender_control, sender_target, sender_error, sender_status, fifo_net_to_pci_data_count,
          fifo_pci_to_net_data_count, reg_CPU_ADDRESS, reg_CPU_READ, reg_CPU_WRITE, api_status,
          fifo_net_to_pci_full, fifo_net_to_pci_empty, fifo_pci_to_net_full, fifo_pci_to_net_empty,
          buf_CPU_DATA_OUT, reg_CPU_DATA_IN, channel_address, CTRL)
		variable tmp : std_logic_vector(7 downto 0);
    begin
      next_CPU_DATA_OUT <= (others => '0');
			tmp := reg_CPU_ADDRESS(11 downto 8) & reg_CPU_ADDRESS(3 downto 0);
     -- if reg_CPU_RD = '1' then
        case tmp is
                           --middle nibble is dont care
          when x"10" =>
            next_CPU_DATA_OUT <= sender_control(channel_address*32+31 downto channel_address*32);
          when x"11" =>
            next_CPU_DATA_OUT <= sender_target(channel_address*32+31 downto channel_address*32);
          when x"12" =>
            next_CPU_DATA_OUT <= sender_error(channel_address*32+31 downto channel_address*32);
          when x"14" =>
            next_CPU_DATA_OUT <= x"000" & "00" & fifo_pci_to_net_empty(channel_address) & fifo_pci_to_net_full(channel_address)
                                  & "000000" & fifo_pci_to_net_data_count(channel_address)(9 downto 0);
          when x"1F" =>
            next_CPU_DATA_OUT <= sender_status(channel_address*32+31 downto channel_address*32);
          when x"24" =>
            next_CPU_DATA_OUT <= x"000" & "00" & fifo_net_to_pci_empty(channel_address) & fifo_net_to_pci_full(channel_address)
                                  & "00000" & fifo_net_to_pci_data_count(channel_address)(10 downto 0);
          when x"30" =>
            next_CPU_DATA_OUT <= api_status(channel_address*32+31 downto channel_address*32);
          when others         =>
            next_CPU_DATA_OUT <= x"10000000"; --"1000000000000000000" & CTRL(31 downto 19);
        end case;
  --    end if;
    end process;


  write_regs : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          sender_control <= (others => '0');
          sender_target  <= (others => '0');
          sender_error   <= (others => '0');
        else
          if reg_CPU_WRITE = '1' and reg_CPU_ADDRESS(11 downto 8) = x"1" then
            case reg_CPU_ADDRESS(3 downto 0) is
                            --middle nibble is dont care
              when x"0" =>
                sender_control(channel_address*32+8 downto channel_address*32) <= reg_CPU_DATA_IN(8 downto 0);
              when x"1" =>
                sender_target(channel_address*32+15 downto channel_address*32) <= reg_CPU_DATA_IN(15 downto 0);
              when x"2" =>
                sender_error(channel_address*32+31 downto channel_address*32) <= reg_CPU_DATA_IN;
              when others => null;
            end case;
          end if;
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

  gen_api_connect : for i in 0 to 2**(c_MUX_WIDTH)-1 generate


    api_status(i*32+7 downto i*32)       <= APL_SEQNR_IN(i*8+7 downto i*8);
    api_status(i*32+31 downto i*32+8)    <= (others => '0');
    sender_status(i*32)                  <= APL_RUN_IN(i);
    sender_status(i*32+31 downto i*32+1) <= (others => '0');


  --connection to API
    next_APL_SEND_OUT(i) <= '1' when reg_CPU_ADDRESS(11 downto 8) = "0001"
                            and reg_CPU_ADDRESS(7 downto 4)  = i
                            and reg_CPU_ADDRESS(3 downto 0)  = "0000"
                            and reg_CPU_WRITE = '1' else '0';

    APL_DATAREADY_OUT(i)                        <= fifo_pci_to_net_valid_read(i);
    APL_DATA_OUT((i+1)*16-1 downto i*16)        <= fifo_pci_to_net_dout(i*18+c_DATA_WIDTH-1 downto i*18);
    APL_PACKET_NUM_OUT((i)*3+1 downto i*3)      <= fifo_pci_to_net_dout(i*18+c_DATA_WIDTH+1 downto i*18+c_DATA_WIDTH);
    APL_PACKET_NUM_OUT(i*3+2)                   <= '0';
    APL_SHORT_TRANSFER_OUT(i)                   <= sender_control(i*32+8);
    APL_ERROR_PATTERN_OUT(i*32+31 downto i*32)  <= sender_error(i*32+31 downto i*32);
    APL_TARGET_ADDRESS_OUT(i*16+15 downto i*16) <= sender_target(i*32+15 downto i*32);
    APL_DTYPE_OUT(i*4+3 downto i*4)             <= sender_control(i*32+3 downto i*32);
    fifo_pci_to_net_read(i) <= APL_READ_IN(i);   --NOT CORRECT - last packet may be lost, but transfer size is limited anyhow


  --connection from API
    fifo_net_to_pci_dout(i*32+31 downto i*32+25) <= (others => '0');
    fifo_net_to_pci_dout(i*32+23 downto i*32+18) <= (others => '0');
    fifo_net_to_pci_dout(i*32+24) <= fifo_net_to_pci_valid_read(i);

    fifo_net_to_pci_din(18*i+c_DATA_WIDTH-1 downto 18*i) <= APL_DATA_IN(c_DATA_WIDTH*(i+1)-1 downto c_DATA_WIDTH*i);
    fifo_net_to_pci_din(18*i+c_DATA_WIDTH)               <= APL_PACKET_NUM_IN(c_NUM_WIDTH*i);
    fifo_net_to_pci_din(18*i+c_DATA_WIDTH+1)             <= APL_PACKET_NUM_IN(c_NUM_WIDTH*i+2);
    fifo_net_to_pci_write(i)                             <= APL_DATAREADY_IN(i) and not fifo_net_to_pci_full(i);
    APL_READ_OUT(i)                                      <= not fifo_net_to_pci_full(i);

  end generate;



--------------------------------
-- fifo as bridge to pci
--------------------------------


  gen_incoming_fifos : for i in 0 to 2**(c_MUX_WIDTH)-1 generate

    FIFO_NET_TO_PCI: trb_net16_fifo
      generic map(
        USE_VENDOR_CORES => c_YES,
        USE_DATA_COUNT => c_YES,
        DEPTH => 6
        )
      port map(
        CLK   => CLK,
        RESET => RESET,
        CLK_EN => '1',
        READ_ENABLE_IN  => fifo_net_to_pci_read(i),
        WRITE_ENABLE_IN => fifo_net_to_pci_write(i),
        DATA_IN         => fifo_net_to_pci_din(18*i+15 downto 18*i),
        PACKET_NUM_IN   => fifo_net_to_pci_din(18*i+17 downto 18*i+16),
        DATA_OUT        => fifo_net_to_pci_dout(32*i+15 downto 32*i),
        PACKET_NUM_OUT  => fifo_net_to_pci_dout(32*i+17 downto 32*i+16),
        DATA_COUNT_OUT  => fifo_net_to_pci_data_count(i)(10 downto 0),
        full_out        => fifo_net_to_pci_full(i),
        empty_out       => fifo_net_to_pci_empty(i)
        );

    FIFO_PCI_TO_NET: trb_net16_fifo
      generic map(
        USE_VENDOR_CORES => c_YES,
        USE_DATA_COUNT => c_YES,
        DEPTH => 6
        )
      port map(
        CLK   => CLK,
        RESET => RESET,
        CLK_EN => '1',
        READ_ENABLE_IN  => fifo_pci_to_net_read(i),
        WRITE_ENABLE_IN => fifo_pci_to_net_write(i),
        DATA_IN         => reg_CPU_DATA_IN(15 downto 0),
        PACKET_NUM_IN   => reg_CPU_DATA_IN(17 downto 16),
        DATA_OUT        => fifo_pci_to_net_dout(18*i+15 downto 18*i),
        PACKET_NUM_OUT  => fifo_pci_to_net_dout(18*i+17 downto 18*i+16),
        DATA_COUNT_OUT  => fifo_pci_to_net_data_count(i)(10 downto 0),
        full_out        => fifo_pci_to_net_full(i),
        empty_out       => fifo_pci_to_net_empty(i)
        );

  end generate;

  proc_valid_read : process(CLK)
    begin
      if rising_edge(CLK) then
        fifo_pci_to_net_valid_read <= fifo_pci_to_net_read and not fifo_pci_to_net_empty;
        fifo_net_to_pci_valid_read <= fifo_net_to_pci_read and not fifo_net_to_pci_empty;
      end if;
    end process;

  proc_fifo_readwrite : process(reg_CPU_ADDRESS, reg_CPU_READ, reg_CPU_WRITE, channel_address)
    begin
      fifo_net_to_pci_read <= (others => '0');
      fifo_pci_to_net_write <= (others => '0');
      if reg_CPU_ADDRESS(11 downto 8) & reg_CPU_ADDRESS(3 downto 0) = x"23" then
        fifo_net_to_pci_read(channel_address) <= reg_CPU_READ;
      end if;
      if reg_CPU_ADDRESS(11 downto 8) & reg_CPU_ADDRESS(3 downto 0) = x"13" then
        fifo_pci_to_net_write(channel_address) <= reg_CPU_WRITE;
      end if;
    end process;

  proc_register_cpu_output : process(CLK)
    begin
      if rising_edge(CLK) then
        buf_CPU_DATA_OUT <= next_CPU_DATA_OUT;
        buf_CPU_DATAREADY_OUT <= reg_CPU_READ;
        last_fifo_read <= or_all(fifo_net_to_pci_read);
      end if;
    end process;

  process(CPU_ADDRESS, buf_CPU_DATA_OUT, fifo_net_to_pci_dout,reg_CPU_ADDRESS, last_fifo_read, buf_CPU_DATAREADY_OUT)
    begin
        if reg_CPU_ADDRESS(11 downto 8) & reg_CPU_ADDRESS(3 downto 0) = x"23" then
          CPU_DATA_OUT <= fifo_net_to_pci_dout((conv_integer(reg_CPU_ADDRESS(6 downto 4)))*32+31 downto conv_integer(reg_CPU_ADDRESS(6 downto 4))*32);
          b_CPU_DATAREADY_OUT <= last_fifo_read;
        else
          CPU_DATA_OUT <= buf_CPU_DATA_OUT;
          b_CPU_DATAREADY_OUT <= buf_CPU_DATAREADY_OUT;
        end if;
    end process;


  proc_reg_cpu_input : process(CLK)
    begin
      if rising_edge(CLK) then
        reg_CPU_ADDRESS <= CPU_ADDRESS;
        reg_CPU_DATA_IN <= CPU_DATA_IN;
        reg_CPU_READ <= CPU_READ;
        reg_CPU_WRITE <= CPU_WRITE;
      end if;
    end process;


end architecture;