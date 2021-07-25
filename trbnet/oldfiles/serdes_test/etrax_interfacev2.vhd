library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;
--library UNISIM;
--use UNISIM.VCOMPONENTS.all;

entity etrax_interfacev2 is
  generic (
    RW_SYSTEM : integer range 1 to 2:=1
    );
  port (
    CLK                     : in    std_logic;
    RESET                   : in    std_logic;
    DATA_BUS                : in    std_logic_vector(31 downto 0);
    ETRAX_DATA_BUS_B        : inout std_logic_vector(16 downto 0);
    ETRAX_DATA_BUS_B_17     : in std_logic;--_vector(16 downto 0);
    ETRAX_DATA_BUS_C        : inout    std_logic_vector(17 downto 0);
    ETRAX_DATA_BUS_E        : inout    std_logic_vector(9 downto 8);
    DATA_VALID              : in    std_logic;
    ETRAX_BUS_BUSY          : in   std_logic;
    ETRAX_IS_READY_TO_READ  : out    std_logic;
    TDC_TCK                 : out   std_logic;
    TDC_TDI                 : out   std_logic;
    TDC_TMS                 : out   std_logic;
    TDC_TRST                : out   std_logic;
    TDC_TDO                 : in    std_logic;
    TDC_RESET               : out   std_logic;
    EXTERNAL_ADDRESS        : out   std_logic_vector(31 downto 0);
    EXTERNAL_DATA_OUT       : out std_logic_vector(31 downto 0);
    EXTERNAL_DATA_IN        : in std_logic_vector(31 downto 0);
    EXTERNAL_ACK            : out   std_logic;
    EXTERNAL_VALID          : in    std_logic;
    EXTERNAL_MODE           : out   std_logic_vector(15 downto 0);
    FPGA_REGISTER_00        : in    std_logic_vector(31 downto 0);
    FPGA_REGISTER_01        : in    std_logic_vector(31 downto 0);
    FPGA_REGISTER_02        : in    std_logic_vector(31 downto 0);
    FPGA_REGISTER_03        : in    std_logic_vector(31 downto 0);
    FPGA_REGISTER_04        : in    std_logic_vector(31 downto 0);
    FPGA_REGISTER_05        : in    std_logic_vector(31 downto 0);
    FPGA_REGISTER_06        : out   std_logic_vector(31 downto 0);
    FPGA_REGISTER_07        : out   std_logic_vector(31 downto 0);
    FPGA_REGISTER_08        : in    std_logic_vector(31 downto 0);
    FPGA_REGISTER_09        : in    std_logic_vector(31 downto 0);
    FPGA_REGISTER_0A        : in    std_logic_vector(31 downto 0);
    FPGA_REGISTER_0B        : in    std_logic_vector(31 downto 0);
    FPGA_REGISTER_0C        : in    std_logic_vector(31 downto 0);
    FPGA_REGISTER_0D        : in    std_logic_vector(31 downto 0);
    FPGA_REGISTER_0E        : out    std_logic_vector(31 downto 0);
    LVL2_VALID              : in    std_logic
  --  DEBUG_REGISTER_OO       : out   std_logic_vector(31 downto 0)
    );
end etrax_interfacev2;

architecture etrax_interfacev2 of etrax_interfacev2 is

  component edge_to_pulse
    port (
      clock     : in  std_logic;
      en_clk    : in  std_logic;
      signal_in : in  std_logic;
      pulse     : out std_logic);
  end component;
  
  signal etrax_trigger_pulse : std_logic;
  signal rw_operation_finished_pulse : std_logic;
  signal saved_rw_mode : std_logic_vector(15 downto 0);
  signal saved_address : std_logic_vector (31 downto 0);
  signal saved_data : std_logic_vector(31 downto 0);
  signal saved_data_fpga : std_logic_vector(31 downto 0);
  
  signal fpga_register_00_i : std_logic_vector(31 downto 0);
  signal fpga_register_01_i : std_logic_vector(31 downto 0);
  signal fpga_register_02_i : std_logic_vector(31 downto 0);
  signal fpga_register_03_i : std_logic_vector(31 downto 0);
  signal fpga_register_04_i : std_logic_vector(31 downto 0);
  signal fpga_register_05_i : std_logic_vector(31 downto 0);
  signal fpga_register_06_i : std_logic_vector(31 downto 0);
  signal fpga_register_07_i : std_logic_vector(31 downto 0);
  signal fpga_register_08_i : std_logic_vector(31 downto 0);
  signal fpga_register_09_i : std_logic_vector(31 downto 0);
  signal fpga_register_0A_i : std_logic_vector(31 downto 0);
  signal fpga_register_0B_i : std_logic_vector(31 downto 0);
  signal fpga_register_0C_i : std_logic_vector(31 downto 0);
  signal fpga_register_0D_i : std_logic_vector(31 downto 0);
  signal fpga_register_0E_i : std_logic_vector(31 downto 0);
  signal saved_external_data : std_logic_vector(31 downto 0);
  signal etrax_is_ready_to_read_i : std_logic;
  signal lvl2_not_valid_pulse : std_logic;
  signal counter_for_pulses : std_logic_vector(2 downto 0);
  signal internal_reset_i : std_logic := '0';

  signal data_from_etrax : std_logic_vector(80 downto 0);
  signal etrax_std_data_counter : std_logic_vector(7 downto 0):=x"00";
  signal enable_transmition : std_logic :='1';
  signal etrax_strobe : std_logic;
  signal data_to_etrax : std_logic_vector(31 downto 0);
  signal reset_counter : std_logic_vector(15 downto 0) := x"0000";
  signal external_reset_counter : std_logic_vector(31 downto 0);
  signal en_trigg_to_etrax  : std_logic;
  signal busy_dma_counter : std_logic_vector(3 downto 0);
  signal busy_dma : std_logic;
  signal etrax_busy_end_pulse : std_logic;
  signal not_etrax_busy : std_logic;
  signal data_valid_synch : std_logic;
  signal send_data : std_logic;
  signal data_bus_reg : std_logic_vector(31 downto 0);
  constant INTERFACE_FOR_TRANSFER : integer := 2;   --1 DMA, 2 no DMA
  signal readout_lvl2_fifo_to_long :std_logic;
  signal readout_lvl2_fifo_to_long_synch :std_logic;
  signal readout_lvl2_fifo :std_logic;
  signal etrax_busy_start : std_logic;
  signal data_valid_start_pulse : std_logic;
  signal data_valid_end_pulse : std_logic;
  signal data_valid_not : std_logic;
  signal etrax_busy_end : std_logic;
  signal write_to_dma : std_logic;
  signal write_to_dma_synch : std_logic;
  signal word16_counter : std_logic_vector(7 downto 0);
  signal write_to_dma_synch_synch : std_logic;
begin

  
-------------------------------------------------------------------------------
-- transmition for reading, writing fpga registers, dsp, sdram , addon . . . 
-------------------------------------------------------------------------------

  TRB_SYSTEM                      : if RW_SYSTEM = 1 generate
    ETRAX_DATA_BUS_C(17) <= 'Z';
    STROBE_PULSER                 : edge_to_pulse
      port map (
        clock                                            => CLK,
        en_clk                                           => '1',
        signal_in                                        => ETRAX_DATA_BUS_C(17),
        pulse                                            => etrax_strobe);

    SAVE_ETRAX_DATA               : process (CLK, RESET)
      variable etrax_data_counter : integer := 0;
    begin
      if rising_edge(CLK)then
        if RESET = '1' or (etrax_std_data_counter = 81 and saved_rw_mode(15) = '0') or (etrax_std_data_counter = 114 and saved_rw_mode(15) = '1') then
          etrax_data_counter                := 0;
          data_from_etrax                     <= (others => '0');
          ETRAX_DATA_BUS_C(16)                <= 'Z';
          enable_transmition                  <= '1';
          etrax_std_data_counter              <= x"00";
        elsif etrax_strobe = '1' and etrax_std_data_counter < 81 then  -- and etrax_data_counter < 81 and etrax_data_counter > 0 then
          data_from_etrax(etrax_data_counter) <= ETRAX_DATA_BUS_C(16);
          etrax_data_counter                := etrax_data_counter + 1;
          ETRAX_DATA_BUS_C(16)                <= 'Z';
          enable_transmition                  <= '0';
          etrax_std_data_counter              <= etrax_std_data_counter + 1;
        elsif etrax_std_data_counter = 81 and saved_rw_mode(15) = '1' then
          data_from_etrax                     <= data_from_etrax;
          ETRAX_DATA_BUS_C(16)                <= data_to_etrax(0);
          etrax_data_counter                := etrax_data_counter + 1;
          etrax_std_data_counter              <= etrax_std_data_counter + 1;
          enable_transmition                  <= '0';
        elsif etrax_strobe = '1' and etrax_std_data_counter > 81 and saved_rw_mode(15) = '1' then
          data_from_etrax                     <= data_from_etrax;
          ETRAX_DATA_BUS_C(16)                <= data_to_etrax((etrax_data_counter-81) mod 32);
          etrax_data_counter                := etrax_data_counter + 1;
          etrax_std_data_counter              <= etrax_std_data_counter + 1;
          enable_transmition                  <= '0';
        end if;
      end if;
    end process SAVE_ETRAX_DATA;
  end generate TRB_SYSTEM;
  -- we should add one state to wait for the data from external device (valid
  -- pulse- > one long puls on the data bus !)
  ADDON_SYSTEM : if RW_SYSTEM = 2 generate
    ETRAX_DATA_BUS_E(8) <= 'Z';
    STROBE_PULSER                 : edge_to_pulse
      port map (
        clock                                            => CLK,
        en_clk                                           => '1',
        signal_in                                        => ETRAX_DATA_BUS_E(9),--
        pulse                                            => etrax_strobe);

    SAVE_ETRAX_DATA               : process (CLK, RESET)
      variable etrax_data_counter : integer := 0;
    begin
      if rising_edge(CLK)then
        if RESET = '1' or (etrax_std_data_counter = 81 and saved_rw_mode(15) = '0') or (etrax_std_data_counter = 114 and saved_rw_mode(15) = '1') then
          etrax_data_counter                := 0;
          data_from_etrax                     <= (others => '0');
          ETRAX_DATA_BUS_E(8)                <= 'Z';
          enable_transmition                  <= '1';
          etrax_std_data_counter              <= x"00";
        elsif etrax_strobe = '1' and etrax_std_data_counter < 81 then  -- and etrax_data_counter < 81 and etrax_data_counter > 0 then
          data_from_etrax(etrax_data_counter) <= ETRAX_DATA_BUS_E(8);
          etrax_data_counter                := etrax_data_counter + 1;
          ETRAX_DATA_BUS_E(8)                <= 'Z';
          enable_transmition                  <= '0';
          etrax_std_data_counter              <= etrax_std_data_counter + 1;
        elsif etrax_std_data_counter = 81 and saved_rw_mode(15) = '1' then
          data_from_etrax                     <= data_from_etrax;
          ETRAX_DATA_BUS_E(8)                <= data_to_etrax(0);
          etrax_data_counter                := etrax_data_counter + 1;
          etrax_std_data_counter              <= etrax_std_data_counter + 1;
          enable_transmition                  <= '0';
        elsif etrax_strobe = '1' and etrax_std_data_counter > 81 and saved_rw_mode(15) = '1' then
          data_from_etrax                     <= data_from_etrax;
          ETRAX_DATA_BUS_E(8)                <= data_to_etrax( (etrax_data_counter-81) mod 32);
          etrax_data_counter                := etrax_data_counter + 1;
          etrax_std_data_counter              <= etrax_std_data_counter + 1;
          enable_transmition                  <= '0';
        end if;
      end if;
    end process SAVE_ETRAX_DATA;
  end generate ADDON_SYSTEM;

  data_to_etrax <= saved_data_fpga when saved_rw_mode(7 downto 0) = x"00" else saved_external_data;
  RW_FINISHED_PULSER       : edge_to_pulse
    port map (
      clock     => CLK,
      en_clk    => '1',
      signal_in => EXTERNAL_VALID,
      pulse     => rw_operation_finished_pulse);
  --for reading only 1us for responce for any external device !!! - ask RADEK
  --abut timing
  REGISTER_ETRAX_BUS: process (CLK, RESET)
  begin 
    if rising_edge(CLK) then 
      if rw_operation_finished_pulse = '1' then
        saved_external_data <= EXTERNAL_DATA_IN;
      else
        saved_external_data <= saved_external_data;
      end if;
    end if;
  end process REGISTER_ETRAX_BUS;
  EXTERNAL_ADDRESS <= saved_address;
  EXTERNAL_MODE    <= saved_rw_mode(15 downto 0);
  EXTERNAL_DATA_OUT <= saved_data;
  EXTERNAL_ACK <= '1' when etrax_std_data_counter = 80 else '0';

  CLOCK_SAVED_DATA: process (CLK, RESET)
  begin  
    if rising_edge(CLK) then 
      if RESET = '1' then
        saved_rw_mode <= (others => '0');
        saved_address <= (others => '0');
        saved_data <= (others => '0');
      else
        saved_rw_mode <= data_from_etrax(15 downto 0);
        saved_address <= data_from_etrax(47 downto 16);
        saved_data <= data_from_etrax(79 downto 48);
      end if;
    end if;
  end process CLOCK_SAVED_DATA;

  REGISTERS: process (CLK)
  begin  
    if rising_edge(CLK) then  
--     if RESET = '1' or (ETRAX_DATA_BUS_C(16)='1' and ETRAX_DATA_BUS_C(17)='1') then
         fpga_register_01_i <= FPGA_REGISTER_01;
         fpga_register_02_i <= FPGA_REGISTER_02;
         fpga_register_03_i <= FPGA_REGISTER_03;
         fpga_register_04_i <= FPGA_REGISTER_04;
         fpga_register_05_i <= FPGA_REGISTER_05;
         FPGA_REGISTER_06   <= fpga_register_06_i;  --this used for TDCjtag enable(0)
         FPGA_REGISTER_07   <= fpga_register_07_i;
         fpga_register_08_i <= FPGA_REGISTER_08;
         fpga_register_09_i <= FPGA_REGISTER_09;
         fpga_register_0A_i <= FPGA_REGISTER_0A;
         fpga_register_0B_i <= FPGA_REGISTER_0B;
         fpga_register_0c_i <= FPGA_REGISTER_0C;
         fpga_register_0d_i <= FPGA_REGISTER_0D;
         FPGA_REGISTER_0E   <= fpga_register_0e_i;
     end if;
   end process REGISTERS;
  
   DATA_SOURCE_SELECT : process (CLK,RESET,saved_rw_mode,saved_address)
   begin
     if rising_edge(CLK) then
      if RESET = '1' then--(ETRAX_DATA_BUS_C(16) = '1' and ETRAX_DATA_BUS_C(17) = '1') then
         fpga_register_06_i                          <= x"00000000";
         fpga_register_07_i                          <= x"00000000";
         fpga_register_0e_i                          <= x"00000000";
      else
        case saved_rw_mode(7 downto 0) is
          when "00000000"        =>
            if saved_rw_mode(15) = '1' then
              case saved_address(31 downto 0) is
                when x"00000000" => saved_data_fpga <= fpga_register_00_i;
                when x"00000001" => saved_data_fpga <= fpga_register_01_i;
                when x"00000002" => saved_data_fpga <= fpga_register_02_i;
                when x"00000003" => saved_data_fpga <= fpga_register_03_i;
                when x"00000004" => saved_data_fpga <= fpga_register_04_i;
                when x"00000005" => saved_data_fpga <= fpga_register_05_i;
                when x"00000006" => saved_data_fpga <= fpga_register_06_i;
                when x"00000007" => saved_data_fpga <= fpga_register_07_i;
                when x"00000008" => saved_data_fpga <= fpga_register_08_i;
                when x"00000009" => saved_data_fpga <= fpga_register_09_i;
                when x"0000000A" => saved_data_fpga <= fpga_register_0A_i;
                when x"0000000B" => saved_data_fpga <= fpga_register_0B_i;
                when x"0000000C" => saved_data_fpga <= fpga_register_0C_i;
                when x"0000000D" => saved_data_fpga <= fpga_register_0D_i;
                when x"0000000E" => saved_data_fpga <= fpga_register_0E_i;
                when others      => saved_data_fpga <= x"deadface";
              end case;
            elsif saved_rw_mode(15) = '0' and etrax_std_data_counter = 80 then
              case saved_address(31 downto 0) is
                when x"00000006" => fpga_register_06_i <= saved_data;
                when x"00000007" => fpga_register_07_i <= saved_data;
                when x"0000000e" => fpga_register_0e_i <= saved_data;                                    
                when others      => null;
              end case;
            end if;
          when "00000001"        =>     --DSP write read
            saved_data_fpga                            <= saved_external_data;
          when x"02"        =>          --sdram
            saved_data_fpga                            <= saved_external_data;
          when x"03"        =>          --ADDON board write read
            saved_data_fpga                            <= saved_external_data;
          when others            =>     
            saved_data_fpga                            <= x"deadface";
        end case;
      end if;
    end if;
  end process DATA_SOURCE_SELECT;
  
-------------------------------------------------------------------------------
-- data transmitio fpga -> etrax
-------------------------------------------------------------------------------
--DMA
  DMA_INTERFACE: if INTERFACE_FOR_TRANSFER=1 generate

    REG_DATA_TO_ETRAXa:process (CLK, RESET)
    begin  
      if rising_edge(CLK) then
        if RESET = '1' then       
          data_bus_reg <= (others => '0');
          write_to_dma_synch <= '0';
          write_to_dma_synch_synch <= '0';
        else
          data_bus_reg <= DATA_BUS;
          write_to_dma_synch <= readout_lvl2_fifo;--write_to_dma;
          write_to_dma_synch_synch <= write_to_dma_synch;
        end if;
      end if;
    end process REG_DATA_TO_ETRAXa;
    ETRAX_DATA_BUS_B(7 downto 0) <= data_bus_reg(31 downto 24); 
--    ETRAX_DATA_BUS_B(6 downto 0) <= data_bus_reg(30 downto 24);  --!!!test
    ETRAX_DATA_BUS_B(15 downto 8) <= data_bus_reg(23 downto 16);
    ETRAX_DATA_BUS_C(15 downto 8) <= data_bus_reg(15 downto 8);
    ETRAX_DATA_BUS_C(7 downto 4) <= data_bus_reg(7 downto 4);


--    ETRAX_DATA_BUS_B(7) <= ETRAX_DATA_BUS_B_17;  --for test

    TDC_TMS                        <= ETRAX_DATA_BUS_C(1) when fpga_register_06_i(0) = '1'  else '1';
    TDC_TCK                        <= ETRAX_DATA_BUS_C(2) when fpga_register_06_i(0) = '1'  else '1';
    TDC_TDI                        <= ETRAX_DATA_BUS_C(3) when fpga_register_06_i(0) = '1'  else '1';
    ETRAX_DATA_BUS_C(0)            <= TDC_TDO when fpga_register_06_i(0) = '1' else data_bus_reg(0);
    ETRAX_DATA_BUS_C(1)            <= 'Z' when fpga_register_06_i(0) = '1' else data_bus_reg(1);
    ETRAX_DATA_BUS_C(2)            <= 'Z' when fpga_register_06_i(0) = '1' else data_bus_reg(2);
    ETRAX_DATA_BUS_C(3)            <= 'Z' when fpga_register_06_i(0) = '1' else data_bus_reg(3);
    
    START_READOUT      : edge_to_pulse
      port map (
        clock     => CLK,
        en_clk    => '1',
        signal_in => DATA_VALID,
        pulse     => data_valid_start_pulse);
    data_valid_not <= not DATA_VALID;
    
    END_READOUT      : edge_to_pulse
      port map (
        clock     => CLK,
        en_clk    => '1',
        signal_in => data_valid_not,
        pulse     => data_valid_end_pulse);

    ETRAX_BUSY_START_PULSER     : edge_to_pulse
      port map (
        clock     => CLK,
        en_clk    => '1',
        signal_in => ETRAX_DATA_BUS_B_17,
        pulse     => etrax_busy_start);

    not_etrax_busy <= not ETRAX_DATA_BUS_B_17;
    
    ETRAX_BUSY_END_PULSER     : edge_to_pulse
      port map (
        clock     => CLK,
        en_clk    => '1',
        signal_in => not_etrax_busy,
        pulse     => etrax_busy_end);

    COUNTER_FOR_READOUT: process (CLK, RESET)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then 
          word16_counter <= x"FF";
        elsif (data_valid_start_pulse = '1') or (etrax_busy_end = '1' and DATA_VALID = '1') then
          word16_counter <= x"00";
        elsif word16_counter < x"1e" then
          word16_counter <= word16_counter + 1;
        else
          word16_counter <= word16_counter;
        end if;
      end if;
    end process COUNTER_FOR_READOUT;
    
    READOUT_LVL2_FIFO_PROC: process (CLK, RESET)
    begin
      if rising_edge(CLK) then
        if RESET = '1' or data_valid_end_pulse = '1' or word16_counter = x"1e" then 
          readout_lvl2_fifo <= '0';
        elsif word16_counter < x"1e" then
          readout_lvl2_fifo <= word16_counter(0);
        end if;
      end if;
    end process READOUT_LVL2_FIFO_PROC;

    WRITE_TO_ETRAX_DMA: process (CLK, RESET)
    begin
      if rising_edge(CLK) then
        if RESET = '1' or word16_counter = x"1e" then 
          write_to_dma <= '0';
        elsif word16_counter = x"00" then
          write_to_dma <= '1';
        end if;
      end if;
    end process WRITE_TO_ETRAX_DMA;
    
    etrax_is_ready_to_read_i <= (data_valid_start_pulse or readout_lvl2_fifo) and DATA_VALID;
    ETRAX_IS_READY_TO_READ <= readout_lvl2_fifo;
    ETRAX_DATA_BUS_B(16) <= write_to_dma_synch_synch;--(not CLK) and (write_to_dma_synch_synch);

  end generate DMA_INTERFACE;

  
-- NO DMA
  WITHOUT_DMA_ETRAX_INTERFACE: if INTERFACE_FOR_TRANSFER = 2 generate
    
    ETRAX_READY_PULSE      : edge_to_pulse
      port map (
      clock     => CLK,
      en_clk    => '1',              
      signal_in => ETRAX_DATA_BUS_B_17,
      pulse     => etrax_is_ready_to_read_i);

  MAKE_PULSES: process (CLK, RESET)
  begin  
    if rising_edge(CLK) then 
      if RESET = '1'  then 
        counter_for_pulses <= "000";
      else
        counter_for_pulses <= counter_for_pulses + 1; 
      end if;
    end if;
  end process make_pulses;
     
  LVL2_NOT_VALID_READY_PULSE      : edge_to_pulse
    port map (
      clock     => CLK,
      en_clk    => '1',
      signal_in => counter_for_pulses(2),
      pulse     => lvl2_not_valid_pulse);

  ETRAX_IS_READY_TO_READ <= DATA_VALID and ((etrax_is_ready_to_read_i and (not LVL2_VALID)) or (lvl2_not_valid_pulse  and LVL2_VALID));  

  TDC_TMS                       <= ETRAX_DATA_BUS_C(1) when fpga_register_06_i(0) = '1' else '1';
  TDC_TCK                       <= ETRAX_DATA_BUS_C(2) when fpga_register_06_i(0) = '1' else '1';
  TDC_TDI                       <= ETRAX_DATA_BUS_C(3) when fpga_register_06_i(0) = '1' else '1';
  ETRAX_DATA_BUS_C(0)           <= TDC_TDO             when fpga_register_06_i(0) = '1' else DATA_BUS(16);
  ETRAX_DATA_BUS_C(1)           <= 'Z'                 when fpga_register_06_i(0) = '1' else DATA_BUS(17);
  ETRAX_DATA_BUS_C(2)           <= 'Z'                 when fpga_register_06_i(0) = '1' else DATA_BUS(18);
  ETRAX_DATA_BUS_C(3)           <= 'Z'                 when fpga_register_06_i(0) = '1' else DATA_BUS(19);
  ETRAX_DATA_BUS_C(15 downto 4) <= DATA_BUS(31 downto 20);
  ETRAX_DATA_BUS_B(15 downto 0) <= DATA_BUS(15 downto 0);
  ETRAX_DATA_BUS_B(16)          <= DATA_VALID and (not LVL2_VALID);
  

  REG_DATA_TO_ETRAX: process (CLK, RESET)
  begin  
    if rising_edge(CLK) then
      if RESET = '1' then       
        data_bus_reg <= (others => '0');
      else
        data_bus_reg <= DATA_BUS;
      end if;
    end if;
  end process REG_DATA_TO_ETRAX;
end generate WITHOUT_DMA_ETRAX_INTERFACE;

end etrax_interfacev2;
