library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


entity tb is

end entity;


architecture tb_arch of tb is
  constant NUMBER_OF_ADC         : integer := 1;

  signal clk                     : std_logic                        := '1';
  signal reset                   : std_logic                        := '1';

  signal med_data_in             : std_logic_vector (16-1 downto 0) := (others => '0');
  signal med_packet_num_in       : std_logic_vector (3-1  downto 0) := (others => '0');
  signal med_dataready_in        : std_logic                        := '0';
  signal med_read_in             : std_logic                        := '0';
  signal med_data_out            : std_logic_vector (16-1 downto 0) := (others => '0');
  signal med_packet_num_out      : std_logic_vector (3-1  downto 0) := (others => '0');
  signal med_dataready_out       : std_logic                        := '0';
  signal med_read_out            : std_logic                        := '0';
  signal med_stat_op             : std_logic_vector (16-1 downto 0) := (others => '0');
  signal med_ctrl_op             : std_logic_vector (16-1 downto 0) := (others => '0');
  signal med_stat_debug          : std_logic_vector (64-1 downto 0) := (others => '0');


  --endpoint LVL1 trigger
  signal trg_type                : std_logic_vector (3  downto 0)   := (others => '0');
  signal trg_valid_timing        : std_logic                        := '0';
  signal trg_valid_notiming      : std_logic                        := '0';
  signal trg_invalid             : std_logic                        := '0';
  signal trg_data_valid          : std_logic                        := '0';
  signal trg_number              : std_logic_vector (15 downto 0)   := (others => '0');
  signal trg_code                : std_logic_vector (7  downto 0)   := (others => '0');
  signal trg_information         : std_logic_vector (23 downto 0)   := (others => '0');
  signal trg_error_pattern       : std_logic_vector (31 downto 0)   := (others => '0');
  signal trg_release             : std_logic                        := '0';
  signal trg_int_trg_number      : std_logic_vector (15 downto 0)   := (others => '0');

  --FEE
  signal fee_trg_release         : std_logic_vector (NUMBER_OF_ADC-1 downto 0)     := (others => '0');
  signal fee_trg_statusbits      : std_logic_vector (NUMBER_OF_ADC*32-1 downto 0)  := (others => '0');
  signal fee_data                : std_logic_vector (NUMBER_OF_ADC*32-1 downto 0)  := (others => '0');
  signal fee_data_write          : std_logic_vector (NUMBER_OF_ADC-1 downto 0)     := (others => '0');
  signal fee_data_finished       : std_logic_vector (NUMBER_OF_ADC-1 downto 0)     := (others => '0');
  signal fee_data_almost_full    : std_logic_vector (NUMBER_OF_ADC-1 downto 0)     := (others => '0');

  signal timing_trg              : std_logic                        := '0';

  signal timer                   : unsigned(31 downto 0)            := (others => '0');
  signal event                   : unsigned(15 downto 0)            := (others => '0');
  signal eventvec                : std_logic_vector(15 downto 0)    := (others => '0');
  signal readoutevent            : unsigned(15 downto 0)            := (others => '0');

begin

 UUT : trb_net16_endpoint_hades_full_handler
  generic map(
    DATA_INTERFACE_NUMBER        => NUMBER_OF_ADC,
    DATA_BUFFER_DEPTH            => 13,
    DATA_BUFFER_WIDTH            => 32,
    DATA_BUFFER_FULL_THRESH      => 2**13-1024,
    TRG_RELEASE_AFTER_DATA       => c_YES,
    HEADER_BUFFER_DEPTH          => 9,
    HEADER_BUFFER_FULL_THRESH    => 2**8
    )

  port map(
    --  Misc
    CLK                          => clk,
    RESET                        => reset,
    CLK_EN                       => '1',

    --  Media direction port
    MED_DATAREADY_OUT            => med_dataready_out,
    MED_DATA_OUT                 => med_data_out,
    MED_PACKET_NUM_OUT           => med_packet_num_out,
    MED_READ_IN                  => med_read_in,
    MED_DATAREADY_IN             => med_dataready_in,
    MED_DATA_IN                  => med_data_in,
    MED_PACKET_NUM_IN            => med_packet_num_in,
    MED_READ_OUT                 => med_read_out,
    MED_STAT_OP_IN               => med_stat_op,
    MED_CTRL_OP_OUT              => med_ctrl_op,

    --Timing trigger in
    TRG_TIMING_TRG_RECEIVED_IN   => timing_trg,
    --LVL1 trigger to FEE
    LVL1_TRG_DATA_VALID_OUT      => trg_data_valid,
    LVL1_VALID_TIMING_TRG_OUT    => trg_valid_timing,
    LVL1_VALID_NOTIMING_TRG_OUT  => trg_valid_notiming,
    LVL1_INVALID_TRG_OUT         => trg_invalid,

    LVL1_TRG_TYPE_OUT            => trg_type,
    LVL1_TRG_NUMBER_OUT          => trg_number,
    LVL1_TRG_CODE_OUT            => trg_code,
    LVL1_TRG_INFORMATION_OUT     => trg_information,
    LVL1_INT_TRG_NUMBER_OUT      => trg_int_trg_number,

    --Response from FEE
    FEE_TRG_RELEASE_IN           => fee_trg_release,
    FEE_TRG_STATUSBITS_IN        => fee_trg_statusbits,
    FEE_DATA_IN                  => fee_data,
    FEE_DATA_WRITE_IN            => fee_data_write,
    FEE_DATA_FINISHED_IN         => fee_data_finished,
    FEE_DATA_ALMOST_FULL_OUT     => fee_data_almost_full,

    --Slow Control Port
    --common registers
    REGIO_COMMON_STAT_REG_IN     => (others => '0'),
    REGIO_COMMON_CTRL_REG_OUT    => open,
    REGIO_COMMON_STAT_STROBE_OUT => open,
    REGIO_COMMON_CTRL_STROBE_OUT => open,
    --user defined registers
    REGIO_STAT_REG_IN            => (others => '0'),
    REGIO_CTRL_REG_OUT           => open,
    REGIO_STAT_STROBE_OUT        => open,
    REGIO_CTRL_STROBE_OUT        => open,
    --internal data port
    BUS_ADDR_OUT                 => open,
    BUS_DATA_OUT                 => open,
    BUS_READ_ENABLE_OUT          => open,
    BUS_WRITE_ENABLE_OUT         => open,
    BUS_TIMEOUT_OUT              => open,
    BUS_DATA_IN                  => (others => '0'),
    BUS_DATAREADY_IN             => '0',
    BUS_WRITE_ACK_IN             => '0',
    BUS_NO_MORE_DATA_IN          => '0',
    BUS_UNKNOWN_ADDR_IN          => '1',
    --Onewire
    ONEWIRE_INOUT                => open,
    ONEWIRE_MONITOR_IN           => '0',
    ONEWIRE_MONITOR_OUT          => open,
    --Config endpoint id, if not statically assigned
    REGIO_VAR_ENDPOINT_ID        => (others => '0'),

    --Timing registers
    TIME_GLOBAL_OUT              => open,
    TIME_LOCAL_OUT               => open,
    TIME_SINCE_LAST_TRG_OUT      => open,
    TIME_TICKS_OUT               => open,

    --Debugging & Status information
    STAT_DEBUG_IPU               => open,
    STAT_DEBUG_1                 => open,
    STAT_DEBUG_2                 => open,
    STAT_DEBUG_DATA_HANDLER_OUT  => open,
    STAT_DEBUG_IPU_HANDLER_OUT   => open,
    CTRL_MPLEX                   => (others => '0'),
    IOBUF_CTRL_GEN               => (others => '0'),
    STAT_ONEWIRE                 => open,
    STAT_ADDR_DEBUG              => open
    );



proc_clk : process
  begin
    wait for 5 ns;
    clk <= not clk;
  end process;

proc_reset : process
  begin
    reset <= '1';
    wait for 55 ns;
    reset <= '0';
    wait;
  end process;

eventvec <= std_logic_vector(event);

proc_media_interface : process
  begin
    med_stat_op <= (others => '0');
    event       <= x"FFFF";
    readoutevent<= x"0000";
    wait for 59 ns;
    med_read_in <= '1';
-- first timing trigger



    while 1 = 1 loop

     --send timing trigger
      if timer = 20 or timer = 100 then
        timing_trg        <= '1';
        event             <= event + to_unsigned(1,1);
        wait for 50 ns;
        timing_trg        <= '0';
      end if;

    --ack in IPU channel
      if (med_data_out = x"001A" or med_data_out = x"001B") and med_dataready_out = '1' and med_packet_num_out = c_H0  then
        med_data_in       <= x"001D";
        med_packet_num_in <= c_H0;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0000";
        med_packet_num_in <= c_F0;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0006";
        med_packet_num_in <= c_F1;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0000";
        med_packet_num_in <= c_F2;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0000";
        med_packet_num_in <= c_F3;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_dataready_in  <= '0';
      end if;

     --ack in lvl1 channel
      if (med_data_out = x"000A" or med_data_out = x"000B") and med_dataready_out = '1' and med_packet_num_out = c_H0 then
        med_data_in       <= x"000D";
        med_packet_num_in <= c_H0;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0000";
        med_packet_num_in <= c_F0;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0006";
        med_packet_num_in <= c_F1;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0000";
        med_packet_num_in <= c_F2;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0000";
        med_packet_num_in <= c_F3;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_dataready_in  <= '0';
      end if;

     -- lvl1 trigger
      if (timer >= 50 and timer < 55) or
         (timer >= 130 and timer < 135)  then
        wait until falling_edge(clk);
        med_data_in       <= x"0003";
        med_packet_num_in <= c_H0;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0000";
        med_packet_num_in <= c_F0;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"10CD";  -- or x"0"&"000"&eventvec(0)&x"00"
        med_packet_num_in <= c_F1;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= std_logic_vector(event);
        med_packet_num_in <= c_F2;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0001";
        med_packet_num_in <= c_F3;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_dataready_in  <= '0';
      end if;


     --ipu trigger
      if (timer >= 110 and timer < 115) or
         (timer >= 200 and timer < 205)  then
        med_data_in       <= x"0013";
        med_packet_num_in <= c_H0;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0000";
        med_packet_num_in <= c_F0;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"00CD";
        med_packet_num_in <= c_F1;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= std_logic_vector(readoutevent);
        med_packet_num_in <= c_F2;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0001";
        med_packet_num_in <= c_F3;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_dataready_in  <= '0';
        readoutevent      <= readoutevent + to_unsigned(1,1);
      end if;


      wait until falling_edge(clk);
    end loop;

    wait;
  end process;



proc_write_data_1 : process
  begin
    while 1 = 1 loop
      wait until rising_edge(trg_valid_timing);
      wait for 50 ns;
      wait until falling_edge(clk);
      fee_data(31 downto 0) <= x"11110001";
      fee_data_write(0)     <= '1';
      wait until falling_edge(clk);
      fee_data(31 downto 0) <= x"11110002";
      fee_data_write(0)     <= '1';
      wait until falling_edge(clk);
      fee_data(31 downto 0) <= x"11110003";
      fee_data_write(0)     <= '1';
      wait until falling_edge(clk);
      fee_data(31 downto 0) <= x"11110004";
      fee_data_write(0)     <= '1';
      wait until falling_edge(clk);
      fee_data_write(0)     <= '0';
      wait until falling_edge(clk);
      fee_data_write(0)     <= '0';
      wait until falling_edge(clk);
      fee_trg_release(0)    <= '1';
      wait until falling_edge(clk);
      fee_trg_release(0)    <= '0';
      fee_data_finished(0)  <= '1';
      wait until falling_edge(clk);
      fee_data_finished(0)  <= '0';
    end loop;
  end process;

--
-- proc_write_data_2 : process
--   begin
--     while 1 = 1 loop
--       wait until rising_edge(trg_valid_timing);
--       wait for 700 ns;
--       wait until falling_edge(clk);
--       wait for 200 ns;
--       wait until falling_edge(clk);
--       fee_trg_release(1)    <= '1';
--       wait until falling_edge(clk);
--       fee_trg_release(1)    <= '0';
--       fee_data_finished(1)  <= '1';
--       wait until falling_edge(clk);
--       fee_data_finished(1)  <= '0';
--     end loop;
--   end process;
--
-- proc_write_data_3 : process
--   begin
--     while 1 = 1 loop
--       wait until rising_edge(trg_valid_timing);
--       wait for 700 ns;
--       wait until falling_edge(clk);
--       wait for 200 ns;
--       wait until falling_edge(clk);
--       fee_trg_release(2)    <= '1';
--       wait until falling_edge(clk);
--       fee_trg_release(2)    <= '0';
--       fee_data_finished(2)  <= '1';
--       wait until falling_edge(clk);
--       fee_data_finished(2)  <= '0';
--     end loop;
--   end process;
--
-- proc_write_data_4 : process
--   begin
--     while 1 = 1 loop
--       wait until rising_edge(trg_valid_timing);
--       wait for 700 ns;
--       wait until falling_edge(clk);
--       fee_data(127 downto 96) <= x"44440001";
--       fee_data_write(3)     <= '1';
--       wait until falling_edge(clk);
--       fee_data_write(3)     <= '0';
--       wait for 200 ns;
--       wait until falling_edge(clk);
--       fee_trg_release(3)    <= '1';
--       wait until falling_edge(clk);
--       fee_trg_release(3)    <= '0';
--       fee_data_finished(3)  <= '1';
--       wait until falling_edge(clk);
--       fee_data_finished(3)  <= '0';
--     end loop;
--   end process;
--
-- proc_write_data_5 : process
--   begin
--     while 1 = 1 loop
--       wait until rising_edge(trg_valid_timing);
--       wait for 700 ns;
--       wait until falling_edge(clk);
--       fee_data(159 downto 128) <= x"55550001";
--       fee_data_write(4)     <= '1';
--       wait until falling_edge(clk);
--       fee_data_write(4)     <= '0';
--       wait for 200 ns;
--       wait until falling_edge(clk);
--       fee_trg_release(4)    <= '1';
--       wait until falling_edge(clk);
--       fee_trg_release(4)    <= '0';
--       fee_data_finished(4)  <= '1';
--       wait until falling_edge(clk);
--       fee_data_finished(4)  <= '0';
--     end loop;
--   end process;
--
-- proc_write_data_6 : process
--   begin
--     while 1 = 1 loop
--       wait until rising_edge(trg_valid_timing);
--       wait for 700 ns;
--       wait until falling_edge(clk);
--       fee_data(191 downto 160) <= x"66660001";
--       fee_data_write(5)     <= '1';
--       wait until falling_edge(clk);
--       fee_data_write(5)     <= '0';
--       wait for 200 ns;
--       wait until falling_edge(clk);
--       fee_trg_release(5)    <= '1';
--       wait until falling_edge(clk);
--       fee_trg_release(5)    <= '0';
--       fee_data_finished(5)  <= '1';
--       wait until falling_edge(clk);
--       fee_data_finished(5)  <= '0';
--     end loop;
--   end process;

proc_timer : process(CLK)
  begin
    if rising_edge(CLK) then
      timer <= timer + to_unsigned(1,1);
      if timer = 300 then
        timer <= to_unsigned(0,32);
      end if;
    end if;
  end process;


end architecture;