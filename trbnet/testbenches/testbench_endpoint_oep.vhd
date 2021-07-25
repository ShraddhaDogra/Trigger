library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.mdc_oepb_pack.all;


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
  signal readoutevent            : unsigned(15 downto 0)            := (others => '0');


  signal TAD            : std_logic_vector(8 downto 0) := (others => 'Z');
  signal TAOD           : std_logic := 'Z';
  signal TDST           : std_logic := 'Z';
  signal RDYI           : std_logic;
  signal GDE            : std_logic;
  signal TRDYO          : std_logic;
  signal MODD           : std_logic;
  signal RES            : std_logic;
  signal TOK            : std_logic;
  signal WRM            : std_logic;
  signal TRSV           : std_logic;

  signal COM_STOP_P     : std_logic := '0';
  signal CMS            : std_logic;
  signal fee_trg_release_i     : std_logic;
  signal fee_trg_statusbits_i  : std_logic_vector(31 downto 0);

  signal common_ctrl_reg       : std_logic_vector(95 downto 0);
  signal ctrl_reg              : std_logic_vector(63 downto 0);
  signal token_back_i          : std_logic;


begin

  ctrl_reg       <= x"0000000000000010";

  TRSV             <= '0';


 UUT : trb_net16_endpoint_hades_full_handler
  generic map(
    DATA_INTERFACE_NUMBER        => NUMBER_OF_ADC,
    DATA_BUFFER_DEPTH            => 9,
    DATA_BUFFER_WIDTH            => 32,
    DATA_BUFFER_FULL_THRESH      => 2**8,
    TRG_RELEASE_AFTER_DATA       => c_YES,
    TIMING_TRIGGER_RAW           => c_YES,
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


  THE_MDC_CONTROL : mdc_control
    port map(
      CLK                        => CLK,
      RESET                      => reset,

      A_ADD                      => TAD,
      A_AOD                      => TAOD,
      A_DST                      => TDST,
      A_RDM                      => RDYI,
      A_GDE                      => GDE,
      A_RDO                      => TRDYO,
      A_MOD                      => MODD,
      A_RES                      => RES,
      A_TOK                      => TOK,
      A_WRM                      => WRM,
      A_RESERVE                  => TRSV,

      TRIGGER_IN                 => COM_STOP_P,
      TRIGGER_OUT                => CMS,
      TRIGGER_MONITOR_OUT        => timing_trg,

      LVL1_TRG_DATA_VALID_IN     => trg_data_valid,
      LVL1_VALID_TIMING_TRG_IN   => trg_valid_timing,
      LVL1_VALID_NOTIMING_TRG_IN => trg_valid_notiming,
      LVL1_INVALID_TRG_IN        => trg_invalid,
      LVL1_TRG_TYPE_IN           => trg_type,
      LVL1_TRG_NUMBER_IN         => trg_number,
      LVL1_TRG_INFORMATION_IN    => trg_information,
      LVL1_INT_TRG_NUMBER_IN     => trg_int_trg_number,
      LVL1_RELEASE_OUT           => fee_trg_release(0),
      LVL1_STATUSBITS_OUT        => fee_trg_statusbits(31 downto 0),

      FEE_DATA_OUT               => fee_data(31 downto 0),
      FEE_DATA_WRITE_OUT         => fee_data_write(0),
      FEE_DATA_FINISHED_OUT      => fee_data_finished(0),

      RAM_ADDRESS_IN             => (others => '0'),
      RAM_DATA_IN                => (others => '0'),
      RAM_DATA_OUT               => open,
      RAM_READ_ENABLE_IN         => '0',
      RAM_WRITE_ENABLE_IN        => '0',
      RAM_READY_OUT              => open,

      STAT_ADDRESS_IN            => (others => '0'),
      STAT_DATA_OUT              => open,
      STAT_READ_ENABLE_IN        => '0',
      STAT_READY_OUT             => open,

      RB_DATA_OUT                => open,
      RB_READ_ENABLE_IN          => '0',
      RB_READY_OUT               => open,
      RB_EMPTY_OUT               => open,

      COMMON_STAT_REG_OUT        => open,
      COMMON_CTRL_REG_IN         => common_ctrl_reg,
      CTRL_REG_IN                => ctrl_reg,

      DEBUG_OUT                  => open
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


--Begrun trigger
  process
    begin
      common_ctrl_reg     <= (95 => '1', others => '0');
      wait for 200 ns;
      wait until rising_edge(CLK);
      common_ctrl_reg(22) <= '1';
      wait until rising_edge(CLK);
      common_ctrl_reg(22) <= '0';
      wait;
    end process;

--Token Back
  process
    begin
      TRDYO  <= '0';
      wait for 500 us;
      TRDYO  <= '1';
      wait for 50 ns;
      TRDYO  <= '0';
      wait for 340 us;
      TRDYO  <= '1';
      wait for 50 ns;
      TRDYO  <= '0';
      wait for 2500 us;
      for i in 0 to 100 loop
        wait until token_back_i = '1';
        TRDYO  <= '1';
        wait for 50 ns;
        TRDYO  <= '0';
      end loop;
      wait;
    end process;

-- Data I/O
  process
    begin
      TAD  <= (others => 'Z');
      TAOD <= 'Z';
      TDST <= 'Z';
      token_back_i <= '0';
      wait for 3000 us;
      wait for 1 ns;
      for j in 0 to 300 loop
        wait until RDYI = '1';
        wait for 200 ns;
        for i in 0 to 30 loop
          TAD  <= std_logic_vector(to_unsigned(i*2,9));
          TAOD <= '0';
          TDST <= '0';
          wait for 10 ns;
          TDST <= '1';
          wait for 40 ns;
          TDST <= '0';
          wait for 20 ns;
          TAD  <= std_logic_vector(to_unsigned(i*2+1,9));
          TAOD <= '1';
          TDST <= '0';
          wait for 10 ns;
          TDST <= '1';
          wait for 40 ns;
          TDST <= '0';
          wait for 20 ns;
        end loop;
        token_back_i <= '1';
        wait for 30 ns;
        token_back_i <= '0';
        TAD  <= (others => 'Z');
        TAOD <= 'Z';
        TDST <= 'Z';
      end loop;
      wait;
    end process;



proc_media_interface : process
  begin
    med_stat_op <= (others => '0');
    event       <= x"FFFF";
    readoutevent<= x"0000";
wait for 4 ms;
    wait for 59 ns;
    med_read_in <= '1';
-- first timing trigger



    while 1 = 1 loop

     --send timing trigger
      if timer = 20 or timer = 7000 or timer = 14000 then
        COM_STOP_P        <= '1';
        event             <= event + to_unsigned(1,1);
        wait for 50 ns;
        COM_STOP_P        <= '0';
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
      if (timer >= 70 and timer < 75) or
         (timer >= 7070 and timer < 7075) or
         (timer >= 19070 and timer < 19075)  then
        wait until falling_edge(clk);
        med_data_in       <= x"0003";
        med_packet_num_in <= c_H0;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"0000";
        med_packet_num_in <= c_F0;
        med_dataready_in  <= '1';
        wait until falling_edge(clk);
        med_data_in       <= x"10CD";
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
      if (timer >= 320 and timer < 325) or
         (timer >= 7520 and timer < 7525)  then
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


-- 
-- proc_write_data_1 : process
--   begin
--     while 1 = 1 loop
--       wait until rising_edge(trg_valid_timing);
--       wait for 100 ns;
--       wait until falling_edge(clk);
--       fee_data(31 downto 0) <= x"11110001";
--       fee_data_write(0)     <= '1';
--       wait until falling_edge(clk);
--       fee_data_write(0)     <= '0';
--       wait until falling_edge(clk);
--       fee_data(31 downto 0) <= x"22220002";
--       fee_data_write(0)     <= '1';
--       if event /= 0 then
--         wait until falling_edge(clk);
--         fee_data(31 downto 0) <= x"33330003";
--         fee_data_write(0)     <= '1';
--       end if;
--       wait until falling_edge(clk);
--       fee_data_write(0)     <= '0';
--       wait until falling_edge(clk);
--       fee_trg_release(0)    <= '1';
--       wait until falling_edge(clk);
--       fee_trg_release(0)    <= '0';
--       fee_data_finished(0)  <= '1';
--       wait until falling_edge(clk);
--       fee_data_finished(0)  <= '0';
--     end loop;
--   end process;
-- 
-- 
-- proc_write_data_2 : process
--   begin
--     while 1 = 1 loop
--       wait until rising_edge(trg_valid_timing);
--       wait for 700 ns;
--       wait until falling_edge(clk);
--       fee_data(63 downto 32) <= x"11110001";
--       fee_data_write(1)     <= '1';
--       wait until falling_edge(clk);
--       fee_data_write(1)     <= '0';
--       wait until falling_edge(clk);
--       fee_data(63 downto 32) <= x"22220002";
--       fee_data_write(1)     <= '1';
--       wait until falling_edge(clk);
--       fee_data(63 downto 32) <= x"33330003";
--       fee_data_write(1)     <= '1';
--       wait until falling_edge(clk);
--       fee_data(63 downto 32) <= x"44440004";
--       fee_data_write(1)     <= '1';
--       wait until falling_edge(clk);
--       fee_data_write(1)     <= '0';
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



proc_timer : process(CLK)
  begin
    if rising_edge(CLK) then
      timer <= timer + to_unsigned(1,1);
      if timer = to_unsigned(400000,32) then
        timer <= to_unsigned(0,32);
      end if;
    end if;
  end process;


end architecture;