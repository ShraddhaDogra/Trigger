library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;


entity etrax_interface is
  generic(
    STATUS_REGISTERS  : integer := 4;
    CONTROL_REGISTERS : integer := 4
    );
  port (
    CLK                     : in    std_logic;
    RESET                   : in    std_logic;
    --Connection to Etrax
    ETRAX_DATA_BUS_B        : out std_logic_vector(17 downto 0);
    ETRAX_DATA_BUS_C        : in  std_logic_vector(17 downto 0);
    ETRAX_BUS_BUSY          : out std_logic;
    --Connection to internal FPGA logic (all addresses above 0x100)
    INTERNAL_DATA_OUT       : out std_logic_vector(31 downto 0);
    INTERNAL_DATA_IN        : in  std_logic_vector(31 downto 0);
    INTERNAL_READ_OUT       : out std_logic;
    INTERNAL_WRITE_OUT      : out std_logic;
    INTERNAL_DATAREADY_IN   : in  std_logic;
    INTERNAL_ADDRESS_OUT    : out std_logic_vector(15 downto 0);
    --Easy-to-use status and control registers (Addresses 0-15 (stat) and 16-31 (ctrl)
    FPGA_REGISTER_IN        : in    std_logic_vector(STATUS_REGISTERS*32-1 downto 0);
    FPGA_REGISTER_OUT       : out   std_logic_vector(CONTROL_REGISTERS*32-1 downto 0);
    --Reset FPGA via Etrax
    EXTERNAL_RESET          : out   std_logic;
    STAT                    : out   std_logic_vector(15 downto 0)
    );
end etrax_interface;
architecture etrax_interface of etrax_interface is

  component signal_sync is
    generic(
      WIDTH : integer := 2;
      DEPTH : integer := 1
      );
    port(
      RESET    : in  std_logic;
      CLK0     : in  std_logic;
      CLK1     : in  std_logic;
      D_IN     : in  std_logic_vector(WIDTH-1 downto 0);
      D_OUT    : out std_logic_vector(WIDTH-1 downto 0)
      );
  end component;

  type ETRAX_RW_STATE_MACHINE is (IDLE, SAVE_DATA_1 ,SAVE_DATA_2 , SEND_DATA_1, SEND_DATA_2, WAIT_FOR_DATA,  SEND_EXTERNAL_TRIGGER );  --SEND_VALID
  signal ETRAX_RW_STATE_currentstate,ETRAX_RW_STATE_nextstate  : ETRAX_RW_STATE_MACHINE;

  signal etrax_trigger_pulse : std_logic;
  signal saved_address : std_logic_vector (15 downto 0);
  signal saved_data : std_logic_vector(31 downto 0);
  signal saved_data_fpga : std_logic_vector(31 downto 0);

  signal read_cycle : std_logic;
  signal write_cycle : std_logic;

  signal etrax_is_ready_to_read_i : std_logic;
  signal internal_reset_i : std_logic;
  signal communication_state : std_logic_vector(3 downto 0);
  signal buf_FPGA_REGISTER_OUT : std_logic_vector(CONTROL_REGISTERS*32-1 downto 0);
  signal last_BUSC : std_logic_vector(17 downto 16);
  signal reg_BUSC  : std_logic_vector(17 downto 0);

  signal delayed_internal_reset_i : std_logic;

begin

  STAT(3 downto 0) <= communication_state;
  STAT(4) <= read_cycle;
  STAT(5) <= write_cycle;
  STAT(6) <= reg_BUSC(16);
  STAT(7) <= etrax_trigger_pulse;
  STAT(8) <= reg_BUSC(17);

  MAKE_RESET: process (CLK)
  begin
    if rising_edge(CLK) then
      if (ETRAX_DATA_BUS_C(16)='1' and ETRAX_DATA_BUS_C(17)='1') or RESET = '1' then
        internal_reset_i <= '1';
      else
        internal_reset_i <= '0';
      end if;
    end if;
  end process MAKE_RESET;

  BUSC_SYNC : signal_sync
    generic map(
      WIDTH => 18,
      DEPTH => 1
      )
    port map(
      RESET => RESET,
      CLK0 => CLK,
      CLK1 => CLK,
      D_IN => ETRAX_DATA_BUS_C,
      D_OUT => reg_BUSC
      );

  THE_RESET_DELAY : signal_sync
    generic map(
      WIDTH => 1,
      DEPTH => 4
      )
    port map(
      RESET => '0',
      CLK0 => CLK,
      CLK1 => CLK,
      D_IN(0) => internal_reset_i,
      D_OUT(0) => delayed_internal_reset_i
      );

  process(CLK)
    begin
      if rising_edge(CLK) then
        last_BUSC <= reg_BUSC(17 downto 16);
      end if;
    end process;

  etrax_trigger_pulse <= (last_BUSC(16) xor reg_BUSC(16)) and not delayed_internal_reset_i;

  EXTERNAL_RESET <= internal_reset_i or delayed_internal_reset_i;
  ETRAX_BUS_BUSY <= '0' when ETRAX_RW_STATE_currentstate = IDLE else '1';

  read_cycle  <= saved_address(15);
  write_cycle <= not saved_address(15);

  ETRAX_FPGA_COMUNICATION_CLOCK : process (CLK)
  begin
    if rising_edge(CLK) then
      if delayed_internal_reset_i = '1' then
        ETRAX_RW_STATE_currentstate <= IDLE;
      else
        ETRAX_RW_STATE_currentstate <= ETRAX_RW_STATE_nextstate;
      end if;
    end if;
  end process;

  ETRAX_FPGA_COMUNICATION: process (ETRAX_RW_STATE_currentstate,etrax_trigger_pulse, --saved_rw_mode(15)
                  read_cycle, write_cycle, INTERNAL_DATAREADY_IN, saved_address)
  begin
    communication_state <= x"1";
    ETRAX_RW_STATE_nextstate <= ETRAX_RW_STATE_currentstate;
    case ETRAX_RW_STATE_currentstate is
      when IDLE         =>
        communication_state <= x"1";
        if etrax_trigger_pulse = '1' then
          ETRAX_RW_STATE_nextstate <= SAVE_DATA_1;
        end if;

      when SAVE_DATA_1     =>
        communication_state <= x"2";
        if read_cycle = '1' then
          ETRAX_RW_STATE_nextstate <= SEND_EXTERNAL_TRIGGER;
        elsif etrax_trigger_pulse = '1' then
          ETRAX_RW_STATE_nextstate   <= SAVE_DATA_2;
        end if;

      when SAVE_DATA_2     =>
        communication_state <= x"3";
        if etrax_trigger_pulse = '1' then
          ETRAX_RW_STATE_nextstate   <= SEND_EXTERNAL_TRIGGER;
        end if;

      when SEND_EXTERNAL_TRIGGER =>
        communication_state <= x"4";
        if read_cycle = '1' and (INTERNAL_DATAREADY_IN = '1' or saved_address(14 downto 5) = 0) then
          ETRAX_RW_STATE_nextstate     <= SEND_DATA_1;
        elsif write_cycle = '1' then
          ETRAX_RW_STATE_nextstate     <= IDLE;
        else
          ETRAX_RW_STATE_nextstate     <= WAIT_FOR_DATA;
        end if;

      when WAIT_FOR_DATA =>
        communication_state <= x"5";
        if INTERNAL_DATAREADY_IN = '1' then
          ETRAX_RW_STATE_nextstate     <= SEND_DATA_1;
        end if;

      when SEND_DATA_1     =>
        communication_state <= x"6";
        if etrax_trigger_pulse = '1' then
          ETRAX_RW_STATE_nextstate   <= SEND_DATA_2;
        end if;

      when SEND_DATA_2 =>
        communication_state <= x"7";
        if etrax_trigger_pulse = '1' then
          ETRAX_RW_STATE_nextstate   <= IDLE;
        end if;
    end case;
  end process ETRAX_FPGA_COMUNICATION;

  REGISTER_ETRAX_BUS: process (CLK)
  begin
    if rising_edge(CLK) then
      if delayed_internal_reset_i = '1' then
        saved_address <= (others => '0');
        saved_data <= (others => '0');
      elsif ETRAX_RW_STATE_currentstate = IDLE  and etrax_trigger_pulse = '1' then
        saved_address(15 downto 0) <= reg_BUSC(15 downto 0);
      elsif ETRAX_RW_STATE_currentstate = SAVE_DATA_1  and etrax_trigger_pulse = '1' then
        saved_data(31 downto 16) <= reg_BUSC(15 downto 0);
      elsif ETRAX_RW_STATE_currentstate = SAVE_DATA_2  and etrax_trigger_pulse = '1' then
        saved_data(15 downto 0) <= reg_BUSC(15 downto 0);
      end if;
    end if;
  end process REGISTER_ETRAX_BUS;


  INTERNAL_ADDRESS_OUT <= '0' & saved_address(14 downto 0);
  INTERNAL_DATA_OUT    <= saved_data;

  INTERNAL_WRITE_OUT <= '1' when write_cycle = '1' and saved_address(14 downto 5) /= 0
                              and ETRAX_RW_STATE_currentstate = SEND_EXTERNAL_TRIGGER
                            else '0';
  INTERNAL_READ_OUT  <= '1' when read_cycle = '1' and saved_address(14 downto 5) /= 0
                              and ETRAX_RW_STATE_currentstate = SAVE_DATA_1
                            else '0';

  FPGA_REGISTER_OUT <= buf_FPGA_REGISTER_OUT;

  ETRAX_DATA_BUS_CHOOSE : process (CLK)
    begin
      if rising_edge(CLK) then
        if delayed_internal_reset_i = '1' then
          ETRAX_DATA_BUS_B(16 downto 0) <= "0"& x"0000";
        elsif ETRAX_RW_STATE_currentstate = SEND_DATA_1 then
          ETRAX_DATA_BUS_B(15 downto 0) <= saved_data_fpga(31 downto 16);
          ETRAX_DATA_BUS_B(16) <= '1';
        elsif ETRAX_RW_STATE_currentstate = SEND_DATA_2 then
          ETRAX_DATA_BUS_B(15 downto 0) <=  saved_data_fpga(15 downto 0);
          ETRAX_DATA_BUS_B(16) <= '1';
        else
          ETRAX_DATA_BUS_B(16 downto 0) <=  "0"& x"0000";
        end if;
      end if;
    end process ETRAX_DATA_BUS_CHOOSE;

   ETRAX_DATA_BUS_B(17) <= '1';

  DATA_SOURCE_SELECT : process (CLK)
    variable stat_num : integer range 0 to STATUS_REGISTERS-1;
    variable ctrl_num : integer range 0 to CONTROL_REGISTERS-1;
    begin
      if rising_edge(CLK) then
        stat_num := conv_integer(saved_address(3 downto 0));
        ctrl_num := conv_integer(saved_address(3 downto 0));
        if read_cycle = '1' then
          if saved_address(14 downto 5) = 0 then
            if saved_address(4) = '0'   then  --status regs
              saved_data_fpga <= FPGA_REGISTER_IN((stat_num)*32+31 downto stat_num*32);
            elsif saved_address(4) = '1' then
              saved_data_fpga <= buf_FPGA_REGISTER_OUT((ctrl_num)*32+31 downto (ctrl_num)*32);
            else
              saved_data_fpga <= (others => '0');
            end if;
          elsif INTERNAL_DATAREADY_IN = '1' then
            saved_data_fpga <= INTERNAL_DATA_IN;
          end if;
        elsif write_cycle = '1' and ETRAX_RW_STATE_currentstate = SEND_EXTERNAL_TRIGGER then
          if saved_address(4) = '1' and saved_address(14 downto 5) = 0 then
            buf_FPGA_REGISTER_OUT((ctrl_num+1)*32-1 downto (ctrl_num)*32) <= saved_data;
          end if;
        end if;

      end if;
    end process DATA_SOURCE_SELECT;
end architecture;
