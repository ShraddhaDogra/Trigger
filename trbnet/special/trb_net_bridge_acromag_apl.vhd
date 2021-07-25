LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;


entity trb_net_bridge_acromag_apl is
    generic(
      CHANNELS : integer := 2**(c_MUX_WIDTH)
      );
    port(
      CLK     : in std_logic;
      CLK_TRB : in std_logic;
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
      CPU_RD                 : in  STD_LOGIC;
      CPU_WR                 : in  STD_LOGIC;
      CPU_DATA_OUT           : out STD_LOGIC_VECTOR (31 downto 0);
      CPU_DATA_IN            : in  STD_LOGIC_VECTOR (31 downto 0);
      CPU_ADDRESS            : in  STD_LOGIC_VECTOR (11 downto 0);
      CPU_INTERRUPT_OUT      : out STD_LOGIC_VECTOR ( 7 downto 0);
      STAT                   : out std_logic_vector (31 downto 0);
      CTRL                   : in  std_logic_vector (31 downto 0);
      API_STAT_IN            : in  std_logic_vector (2**c_MUX_WIDTH*32-1 downto 0);
      API_OBUF_STAT_IN       : in  std_logic_vector (2**c_MUX_WIDTH*32-1 downto 0)
      );
end entity;

--address range is 000 to FFF
--  (c is channel number * 2 + 1 if active part)

--sending data. sending is released when 1c0 is written
--1c0 wr (3..0) Dtype (8) short transfer    sender_control     9bit used
--1c1 wr target address                     sender_target     16bit used
--1c2 wr Errorbits                          sender_error      32bit used
--1c3 w  sender data fifo                   sender_data       16bit used
--1cF  r status (0)transfer running         sender_status      1bit used


--received data
--2c3  r receiver data fifo, (20..18)type  receiver_data      16bit used
--2c4  r number of received 32bit words    receiver_counter   10bit used


--3c0  (7..0) seq_num         api_status



architecture trb_net_bridge_acromag_apl_arch of trb_net_bridge_acromag_apl is
  signal fifo_net_to_pci_read    : std_logic_vector(2**c_MUX_WIDTH-1 downto 0);
  signal fifo_net_to_pci_write   : std_logic_vector(2**c_MUX_WIDTH-1 downto 0);
  signal fifo_net_to_pci_dout    : std_logic_vector(32*2**c_MUX_WIDTH-1 downto 0);
  signal fifo_net_to_pci_din     : std_logic_vector(32*2**c_MUX_WIDTH-1 downto 0);
  signal fifo_net_to_pci_valid_read : std_logic_vector((2**c_MUX_WIDTH)-1 downto 0);
  signal fifo_net_to_pci_full    : std_logic_vector((2**c_MUX_WIDTH)-1 downto 0);
  signal fifo_net_to_pci_empty   : std_logic_vector((2**c_MUX_WIDTH)-1 downto 0);
  signal fifo_pci_to_net_read    : std_logic_vector(2**c_MUX_WIDTH-1 downto 0);
  signal fifo_pci_to_net_write   : std_logic_vector(2**c_MUX_WIDTH-1 downto 0);
  signal fifo_pci_to_net_valid_read : std_logic_vector((2**c_MUX_WIDTH)-1 downto 0);
  signal fifo_pci_to_net_dout    : std_logic_vector(32*2**c_MUX_WIDTH-1 downto 0);
  signal fifo_pci_to_net_full    : std_logic_vector((2**c_MUX_WIDTH)-1 downto 0);
  signal fifo_pci_to_net_empty   : std_logic_vector((2**c_MUX_WIDTH)-1 downto 0);
  signal next_APL_SEND_OUT : std_logic_vector(2**c_MUX_WIDTH-1 downto 0);

  signal sender_control : std_logic_vector(32*CHANNELS-1 downto 0);
  signal sender_target  : std_logic_vector(32*CHANNELS-1 downto 0);
  signal sender_error   : std_logic_vector(32*CHANNELS-1 downto 0);
  signal sender_status  : std_logic_vector(32*CHANNELS-1 downto 0);
  signal receiver_counter : std_logic_vector(32*CHANNELS-1 downto 0);
  signal current_receiver_data : std_logic_vector(31 downto 0);
  signal api_status     : std_logic_vector(32*CHANNELS-1 downto 0);

  signal channel_address : integer range 0 to 7;
  signal comb_channel_address : integer range 0 to 7;
  signal last_CPU_ADDRESS : std_logic_vector(11 downto 0);

  signal reg_CPU_ADDRESS : std_logic_vector(11 downto 0);
  signal reg_CPU_DATA_IN : std_logic_vector(31 downto 0);
  signal next_CPU_DATA_OUT: std_logic_vector(31 downto 0);
  signal buf_CPU_DATA_OUT : std_logic_vector(31 downto 0);
  signal reg_CPU_RD      : std_logic;
  signal reg_CPU_WR      : std_logic;
  signal last_CLK, CLK_SLOW_EN : std_logic;
  signal last_CLK_SLOW_EN: std_logic;
  signal comb_CLK_SLOW_EN : std_logic;
  signal last2_CLK_SLOW_EN : std_logic;
  signal last_reg_CPU_ADDRESS : std_logic_vector(11 downto 0);
  signal tmp : std_logic_vector(11 downto 0);

  component trb_net_fifo_16bit_bram_dualport_fallthrough is
    port (
      rd_clk:   IN  std_logic;
      wr_clk:  IN  std_logic;
      rd_en:  IN  std_logic;
      wr_en: IN  std_logic;
      rst:     IN  std_logic;
      din:   IN  std_logic_vector(17 downto 0);
      dout:   OUT std_logic_vector(17 downto 0);
      full:        OUT std_logic;
      empty:       OUT std_logic;
      valid:  OUT std_logic
      );
  end component;

  component trb_net_fifo_16bit_bram_dualport is
    port (
      read_clock_in:   IN  std_logic;
      write_clock_in:  IN  std_logic;
      read_enable_in:  IN  std_logic;
      write_enable_in: IN  std_logic;
      fifo_gsr_in:     IN  std_logic;
      write_data_in:   IN  std_logic_vector(17 downto 0);
      read_data_out:   OUT std_logic_vector(17 downto 0);
      full_out:        OUT std_logic;
      empty_out:       OUT std_logic;
      valid_read_out:  OUT std_logic
      );
  end component;

begin

  STAT(11) <= reg_CPU_WR;
  STAT(10) <= reg_CPU_RD;

  STAT(9 downto 0) <= reg_CPU_ADDRESS(9 downto 0);
  STAT(15 downto 14) <= reg_CPU_DATA_IN(1 downto 0);


--------------------------------
-- r/w registers
--------------------------------
  channel_address <= conv_integer(reg_CPU_ADDRESS(6 downto 4));
  comb_channel_address <= conv_integer(CPU_ADDRESS(6 downto 4));

  read_regs : process(sender_control, sender_target, sender_error, sender_status,
          receiver_counter, reg_CPU_ADDRESS, reg_CPU_RD, reg_CPU_WR, api_status,
          buf_CPU_DATA_OUT, reg_CPU_DATA_IN, channel_address,current_receiver_data)
    begin
      next_CPU_DATA_OUT <= (others => '0');
     -- if reg_CPU_RD = '1' then
        case reg_CPU_ADDRESS(11 downto 8) & reg_CPU_ADDRESS(3 downto 0) is
                           --middle nibble is dont care
          when x"10" =>
            next_CPU_DATA_OUT <= sender_control(channel_address*32+31 downto channel_address*32);
          when x"11" =>
            next_CPU_DATA_OUT <= sender_target(channel_address*32+31 downto channel_address*32);
          when x"12" =>
            next_CPU_DATA_OUT <= sender_error(channel_address*32+31 downto channel_address*32);
          when x"1F" =>
            next_CPU_DATA_OUT <= sender_status(channel_address*32+31 downto channel_address*32);
          when x"20" =>
            next_CPU_DATA_OUT <= API_STAT_IN(channel_address*32+31 downto channel_address*32);
          when x"24" =>
            next_CPU_DATA_OUT <= receiver_counter(channel_address*32+31 downto channel_address*32);
          when x"30" =>
            next_CPU_DATA_OUT <= api_status(channel_address*32+31 downto channel_address*32);
          when x"31" =>
            next_CPU_DATA_OUT <=  API_OBUF_STAT_IN(channel_address*32+31 downto channel_address*32);
          when others         =>
            next_CPU_DATA_OUT <= CTRL;
        end case;
  --    end if;
    end process;


  write_regs : process(CLK_TRB)
    begin
      if rising_edge(CLK_TRB) then
        if RESET = '1' then
          sender_control <= (others => '0');
          sender_target  <= (others => '0');
          sender_error   <= (others => '0');
        else
          if reg_CPU_WR = '1' then
            case reg_CPU_ADDRESS(11 downto 8) & reg_CPU_ADDRESS(3 downto 0) is
                            --middle nibble is dont care
              when x"10" =>
                sender_control(channel_address*32+8 downto channel_address*32) <= reg_CPU_DATA_IN(8 downto 0);
              when x"11" =>
                sender_target(channel_address*32+15 downto channel_address*32) <= reg_CPU_DATA_IN(15 downto 0);
              when x"12" =>
                sender_error(channel_address*32+31 downto channel_address*32) <= reg_CPU_DATA_IN;
              when others =>
            end case;
          end if;
        end if;
      end if;
    end process;

--------------------------------
-- connection to API
--------------------------------

  gen_api_connect : for i in 0 to CHANNELS-1 generate
    APL_DTYPE_OUT(i*4+3 downto i*4) <= sender_control(i*32+3 downto i*32);
    api_status(i*32+7 downto i*32)  <= APL_SEQNR_IN(i*8+7 downto i*8);
    sender_status(i*32)       <= APL_RUN_IN(i);
    --api_status(i*32+10 downto i*32+8) <= APL_TYP_IN;
    next_APL_SEND_OUT(i)      <= '1' when reg_CPU_ADDRESS(11 downto 8) = "0001"
                                  and reg_CPU_ADDRESS(7 downto 4)  = i
                                  and reg_CPU_ADDRESS(3 downto 0)  = "0000"
                                  and reg_CPU_WR = '1' else '0';
    APL_DATAREADY_OUT(i)      <= fifo_pci_to_net_valid_read(i);
    fifo_pci_to_net_read(i)   <= APL_READ_IN(i);   --NOT CORRECT - last packet may be lost
    APL_SHORT_TRANSFER_OUT(i) <= sender_control(i*32+8);
    APL_ERROR_PATTERN_OUT(i*32+31 downto i*32)  <= sender_error(i*32+31 downto i*32);
    APL_TARGET_ADDRESS_OUT(i*16+15 downto i*16) <= sender_target(i*32+15 downto i*32);
    APL_READ_OUT(i)           <= not fifo_net_to_pci_full(i);
    fifo_net_to_pci_write(i)  <= APL_DATAREADY_IN(i);
  end generate;

  process(CLK_TRB)
    begin
      if rising_edge(CLK_TRB) then
        APL_SEND_OUT <= next_APL_SEND_OUT;
      end if;
    end process;

--------------------------------
-- fifo as bridge to pci
--------------------------------

  gen_incoming_fifos : for i in 0 to CHANNELS-1 generate

    fifo_net_to_pci_dout(i*32+31 downto i*32+25) <= (others => '0');
    fifo_net_to_pci_dout(i*32+23 downto i*32+18) <= (others => '0');
    fifo_net_to_pci_dout(i*32+24) <= fifo_net_to_pci_valid_read(i);
    fifo_net_to_pci_din(32*i+c_DATA_WIDTH+c_NUM_WIDTH-1 downto 32*i) <= APL_PACKET_NUM_IN(c_NUM_WIDTH*i+2) & APL_PACKET_NUM_IN(c_NUM_WIDTH*i) & APL_DATA_IN(c_DATA_WIDTH*(i+1)-1 downto c_DATA_WIDTH*i);
    APL_DATA_OUT((i+1)*c_DATA_WIDTH-1 downto i*c_DATA_WIDTH) <= fifo_pci_to_net_dout(i*32+c_DATA_WIDTH-1 downto i*32);
    APL_PACKET_NUM_OUT((i)*3+1 downto i*3) <= fifo_pci_to_net_dout(i*32+c_DATA_WIDTH+1 downto i*32+c_DATA_WIDTH);
    APL_PACKET_NUM_OUT(i*3+2) <= '0';

    STAT(24) <= fifo_net_to_pci_empty(1);
    STAT(25) <= fifo_net_to_pci_read(1);
    STAT(26) <= fifo_net_to_pci_write(1);

    FIFO_NET_TO_PCI: trb_net_fifo_16bit_bram_dualport
      port map(
        read_clock_in   => CLK,
        write_clock_in  => CLK_TRB,
        read_enable_in  => fifo_net_to_pci_read(i),
        write_enable_in => fifo_net_to_pci_write(i),
        fifo_gsr_in     => RESET,
        write_data_in   => fifo_net_to_pci_din(32*i+17 downto 32*i),
        read_data_out   => fifo_net_to_pci_dout(32*i+17 downto 32*i),
        full_out        => fifo_net_to_pci_full(i),
        empty_out       => fifo_net_to_pci_empty(i),
        valid_read_out  => fifo_net_to_pci_valid_read(i)
        );
    FIFO_PCI_TO_NET: trb_net_fifo_16bit_bram_dualport
      port map(
        read_clock_in   => CLK_TRB,
        write_clock_in  => CLK,
        read_enable_in  => fifo_pci_to_net_read(i),
        write_enable_in => fifo_pci_to_net_write(i),
        fifo_gsr_in     => RESET,
        write_data_in   => reg_CPU_DATA_IN(17 downto 0),
        read_data_out   => fifo_pci_to_net_dout(32*i+17 downto 32*i),
        full_out        => fifo_pci_to_net_full(i),
        empty_out       => fifo_pci_to_net_empty(i),
        valid_read_out  => fifo_pci_to_net_valid_read(i)
        );
  end generate;


--write/read flags for fifo

  process(CPU_ADDRESS, CPU_RD, CPU_WR, comb_channel_address,reg_CPU_ADDRESS, channel_address)
    begin
      fifo_net_to_pci_read <= (others => '0');
      fifo_pci_to_net_write <= (others => '0');  --using now registered address
      if reg_CPU_ADDRESS(11 downto 8) & reg_CPU_ADDRESS(3 downto 0) = "00100011" then
        fifo_net_to_pci_read(channel_address) <= CPU_RD;
      end if;
      if reg_CPU_ADDRESS(11 downto 8) & reg_CPU_ADDRESS(3 downto 0) = "00010011" then
        fifo_pci_to_net_write(channel_address) <= CPU_WR;
      end if;
    end process;

--------------------------------
-- synchronize to slow PCI clock
--------------------------------

  register_slow_output : process(CLK_TRB)
    begin
      if rising_edge(CLK_TRB) then
        if last_CLK_SLOW_EN = '1' then
          buf_CPU_DATA_OUT <= next_CPU_DATA_OUT;
        end if;
      end if;
    end process;

  process(CPU_ADDRESS, buf_CPU_DATA_OUT, fifo_net_to_pci_dout,reg_CPU_ADDRESS)
    begin
        last_CPU_ADDRESS <= CPU_ADDRESS;
        if reg_CPU_ADDRESS(11 downto 8) & reg_CPU_ADDRESS(3 downto 0) = x"23" then
          CPU_DATA_OUT <= fifo_net_to_pci_dout((conv_integer(reg_CPU_ADDRESS(6 downto 4))+1)*32-1 downto conv_integer(reg_CPU_ADDRESS(6 downto 4))*32);
        else
          CPU_DATA_OUT <= buf_CPU_DATA_OUT;
        end if;
    end process;

  register_slow_dat_addr_input : process(CLK_TRB)
    begin
      if rising_edge(CLK_TRB) then
        reg_CPU_RD <= '0';
        reg_CPU_WR <= '0';
        if CLK_SLOW_EN = '1' then
          reg_CPU_ADDRESS <= CPU_ADDRESS;
          reg_CPU_DATA_IN <= CPU_DATA_IN;
          reg_CPU_RD <= CPU_RD;
          reg_CPU_WR <= CPU_WR;
        end if;
      end if;
    end process;

comb_CLK_SLOW_EN <= CLK and not last_CLK;
  generate_slow_clk_en : process(CLK_TRB)
    begin
      if rising_edge(CLK_TRB) then
          last_CLK <= CLK;
          CLK_SLOW_EN <= CLK and not last_CLK;
          last_CLK_SLOW_EN <= CLK_SLOW_EN;
          last2_CLK_SLOW_EN <= last_CLK_SLOW_EN;
      end if;
    end process;
end architecture;