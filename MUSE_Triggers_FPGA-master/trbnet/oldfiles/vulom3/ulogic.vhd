--------------------------------------------------------------------------------
-- Company:  GSI
-- Engineer: Davide Leoni
--
-- Create Date:    5/4/07
-- Design Name:    vulom3
-- Module Name:    ulogic - Behavioral
-- Project Name:  triggerbox 
-- Target Device:  XC4VLX25-10SF363
-- Tool versions:  
-- Description: VME address encoder and decoder, I/O ECL configuration
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity ulogic is port (
  RESET    : in    std_logic;
  CK50     : in    std_logic;
  CK300    : in    std_logic;
  CK100    : in    std_logic;
  LEMOU    : out   std_logic_vector(2 downto 1);  -- 
  LEMIN    : in    std_logic_vector(2 downto 1);  --
  TIN      : out   std_logic_vector(16 downto 1);
  EN       : out   std_logic_vector(4 downto 1);
  ECO      : out   std_logic_vector(16 downto 1);
  ECL      : in    std_logic_vector(16 downto 1);
  IOO      : in    std_logic_vector(16 downto 1);
  FLED_T   : out   std_logic_vector(6 downto 1);
------------------------------ VME interface  -------------------------------------
  U_AD_REG : in    std_logic_vector(21 downto 2);
  U_DAT_IN : in    std_logic_vector(31 downto 0);
  U_DATA_O : out   std_logic_vector(31 downto 0);
  OECSR    : in    std_logic;
  CKCSR    : in    std_logic;
  HPV      : inout std_logic_vector(15 downto 0);
  HPW      : inout std_logic_vector(15 downto 0)
  );
end ulogic;
architecture RTL of ulogic is
signal ckcsro		: std_logic_vector (35 downto 0);	-- write clock for registers
signal oecsro		: std_logic_vector (35 downto 0);	-- read enable for registers
signal hplx			: std_logic_vector (7 downto 0);		-- data register for logic analyzer
signal INPUT_ENABLE : std_logic_vector(7 downto 1);
signal downscale_register_1, downscale_register_2, downscale_register_3,downscale_register_4, downscale_register_5, downscale_register_ts, downscale_register_vs, downscale_register_clock : std_logic_vector(3 downto 0);  --15
signal delay_register_1, delay_register_2, delay_register_3, delay_register_4, delay_register_5, delay_register_ts, delay_register_vs : std_logic_vector(3 downto 0);
signal width_register_1, width_register_2, width_register_3, width_register_4, width_register_5, width_register_ts, width_register_vs, width_output : std_logic_vector(3 downto 0);
signal 	scaler_pti1, scaler_pti2, scaler_pti3, scaler_pti4, scaler_pti5, scaler_ts, scaler_vs, scaler_mdc, scaler_tof, scaler_dead, scaler_pti1_accepted, scaler_pti2_accepted, scaler_pti3_accepted, scaler_pti4_accepted, scaler_pti5_accepted, scaler_ts_accepted, scaler_vs_accepted, scaler_mux1, scaler_mux2 : std_logic_vector(31 downto 0);	
signal scaler_reset, scaler_mdc_tof_select : std_logic_vector(7 downto 0);
signal or_on_off : std_logic_vector(7 downto 0);
signal ts_gating_disable : std_logic_vector(7 downto 1);
signal pti5_ts_alternative, delay_register_beam, width_inhibit_register_beam, width_external_register_beam : std_logic_vector(7 downto 0);
signal mux_selector_1, mux_selector_2 : std_logic_vector(3 downto 0);
signal branch_en_with_mdc_tof_width, dtu_code_select_i: std_logic_vector(4 downto 0);
--signal u_data_o_s : std_logic_vector(31 downto 0);
signal cal_trigger_disable, com_run, dtu_error : std_logic;
signal debug_1 : std_logic_vector(31 downto 0);
signal trb_busy_enable : std_logic;
component trig_box1
  port (CLK_50MHZ                    : in  std_logic;
        CLK_300MHz                   : in  std_logic;
        CLK_100MHz                   : in  std_logic;
        ECL                          : in  std_logic_vector(16 downto 1);
        ECO                          : out std_logic_vector(16 downto 1);
        IOO                          : in  std_logic_vector(16 downto 1);
        TIN                          : out std_logic_vector(16 downto 1);
        LEMIN                        : in  std_logic_vector(2 downto 1);
        LEMOU                        : out std_logic_vector(2 downto 1);
        INPUT_ENABLE                 : in  std_logic_vector(7 downto 1);
        DOWNSCALE_REGISTER_1         : in  std_logic_vector(3 downto 0);  --15
        DELAY_REGISTER_1             : in  std_logic_vector(3 downto 0);
        WIDTH_REGISTER_1             : in  std_logic_vector(3 downto 0);  --4
        DOWNSCALE_REGISTER_2         : in  std_logic_vector(3 downto 0);
        DELAY_REGISTER_2             : in  std_logic_vector(3 downto 0);
        WIDTH_REGISTER_2             : in  std_logic_vector(3 downto 0);
        DOWNSCALE_REGISTER_3         : in  std_logic_vector(3 downto 0);
        DELAY_REGISTER_3             : in  std_logic_vector(3 downto 0);
        WIDTH_REGISTER_3             : in  std_logic_vector(3 downto 0);
        DOWNSCALE_REGISTER_4         : in  std_logic_vector(3 downto 0);
        DELAY_REGISTER_4             : in  std_logic_vector(3 downto 0);
        WIDTH_REGISTER_4             : in  std_logic_vector(3 downto 0);
        DOWNSCALE_REGISTER_5         : in  std_logic_vector(3 downto 0);
        DELAY_REGISTER_5             : in  std_logic_vector(3 downto 0);
        WIDTH_REGISTER_5             : in  std_logic_vector(3 downto 0);
        DOWNSCALE_REGISTER_TS        : in  std_logic_vector(3 downto 0);
        DELAY_REGISTER_TS            : in  std_logic_vector(3 downto 0);
        WIDTH_REGISTER_TS            : in  std_logic_vector(3 downto 0);
        DOWNSCALE_REGISTER_VS        : in  std_logic_vector(3 downto 0);
        DELAY_REGISTER_VS            : in  std_logic_vector(3 downto 0);
        WIDTH_REGISTER_VS            : in  std_logic_vector(3 downto 0);
        DOWNSCALE_REGISTER_CLOCK     : in  std_logic_vector(3 downto 0);
        BRANCH_EN_with_MDC_TOF_WIDTH : in  std_logic_vector(4 downto 0);
        WIDTH_OUTPUT                 : in  std_logic_vector(3 downto 0);
        MUX_SELECTOR_1               : in  std_logic_vector(3 downto 0);
        MUX_SELECTOR_2               : in  std_logic_vector(3 downto 0);
        OR_ON_OFF                    : in  std_logic_vector(7 downto 0);
        SCALER_PTI1                  : out std_logic_vector(31 downto 0);
        SCALER_PTI2                  : out std_logic_vector(31 downto 0);
        SCALER_PTI3                  : out std_logic_vector(31 downto 0);
        SCALER_PTI4                  : out std_logic_vector(31 downto 0);
        SCALER_PTI5                  : out std_logic_vector(31 downto 0);
        SCALER_TS                    : out std_logic_vector(31 downto 0);
        SCALER_VS                    : out std_logic_vector(31 downto 0);
        SCALER_MDC_TOF_SELECT        : in  std_logic_vector(7 downto 0);
        SCALER_MDC                   : out std_logic_vector(31 downto 0);
        SCALER_TOF                   : out std_logic_vector(31 downto 0);
        SCALER_RESET                 : in  std_logic_vector(7 downto 0);
        PTI5_TS_ALTERNATIVE          : in  std_logic_vector(7 downto 0);
        DELAY_REGISTER_BEAM          : in  std_logic_vector(7 downto 0);
        WIDTH_INHIBIT_REGISTER_BEAM  : in  std_logic_vector(7 downto 0);
        WIDTH_EXTERNAL_REGISTER_BEAM : in  std_logic_vector(7 downto 0);
        SCALER_DEAD                  : out std_logic_vector(31 downto 0);
        TS_GATING_DISABLE            : in  std_logic_vector(7 downto 1);
        SCALER_PTI1_ACCEPTED         : out std_logic_vector(31 downto 0);
        SCALER_PTI2_ACCEPTED         : out std_logic_vector(31 downto 0);
        SCALER_PTI3_ACCEPTED         : out std_logic_vector(31 downto 0);
        SCALER_PTI4_ACCEPTED         : out std_logic_vector(31 downto 0);
        SCALER_PTI5_ACCEPTED         : out std_logic_vector(31 downto 0);
        SCALER_TS_ACCEPTED           : out std_logic_vector(31 downto 0);
        SCALER_VS_ACCEPTED           : out std_logic_vector(31 downto 0);
        SCALER_MUX1                  : out std_logic_vector(31 downto 0);
        SCALER_MUX2                  : out std_logic_vector(31 downto 0);
        DTU_CODE_SELECT              : in  std_logic_vector(4 downto 0);
        CAL_TRIGGER_DISABLE          : in  std_logic;
        COM_RUN                      : in  std_logic;
        DTU_ERROR                    : out std_logic;
        HPV                          : inout std_logic_vector(15 downto 0);
        HPW                          : inout std_logic_vector(15 downto 0);
        DEBUG_REG_00            : out std_logic_vector(31 downto 0);
        TRB_BUSY_ENABLE         : in std_logic
        );
end component;
begin 
  trgb_1 : trig_box1 port map (
    CLK_50MHz                    => CK50,
    CLK_300MHz                   => CK300,
    CLK_100MHz                   => CK100,
    ECL                          => ECL,
    ECO                          => ECO,
    IOO                          => IOO,
    TIN                          => TIN,
    LEMIN                        => LEMIN,
    LEMOU                        => LEMOU,
    INPUT_ENABLE                 => INPUT_ENABLE,
    DOWNSCALE_REGISTER_1         => downscale_register_1,
    DELAY_REGISTER_1             => delay_register_1,
    WIDTH_REGISTER_1             => width_register_1,
    DOWNSCALE_REGISTER_2         => downscale_register_2,
    DELAY_REGISTER_2             => delay_register_2,
    WIDTH_REGISTER_2             => width_register_2,
    DOWNSCALE_REGISTER_3         => downscale_register_3,
    DELAY_REGISTER_3             => delay_register_3,
    WIDTH_REGISTER_3             => width_register_3,
    DOWNSCALE_REGISTER_4         => downscale_register_4,
    DELAY_REGISTER_4             => delay_register_4,
    WIDTH_REGISTER_4             => width_register_4,
    DOWNSCALE_REGISTER_5         => downscale_register_5,
    DELAY_REGISTER_5             => delay_register_5,
    WIDTH_REGISTER_5             => width_register_5,
    DOWNSCALE_REGISTER_TS        => downscale_register_ts,
    DELAY_REGISTER_TS            => delay_register_ts,
    WIDTH_REGISTER_TS            => width_register_ts,
    DOWNSCALE_REGISTER_VS        => downscale_register_vs,
    DELAY_REGISTER_VS            => delay_register_vs,
    WIDTH_REGISTER_VS            => width_register_vs,
    DOWNSCALE_REGISTER_CLOCK     => downscale_register_clock,
    BRANCH_EN_with_MDC_TOF_WIDTH => branch_en_with_mdc_tof_width,
    WIDTH_OUTPUT                 => width_output,
    MUX_SELECTOR_1               => mux_selector_1,
    MUX_SELECTOR_2               => mux_selector_2,
    OR_ON_OFF                    => or_on_off,
    SCALER_PTI1                  => scaler_pti1,
    SCALER_PTI2                  => scaler_pti2,
    SCALER_PTI3                  => scaler_pti3,
    SCALER_PTI4                  => scaler_pti4,
    SCALER_PTI5                  => scaler_pti5,
    SCALER_TS                    => scaler_ts,
    SCALER_VS                    => scaler_vs,
    SCALER_MDC_TOF_SELECT        => scaler_mdc_tof_select,
    SCALER_MDC                   => scaler_mdc,
    SCALER_TOF                   => scaler_tof,
    SCALER_RESET                 => scaler_reset,
    PTI5_TS_ALTERNATIVE          => pti5_ts_alternative,
    DELAY_REGISTER_BEAM          => delay_register_beam,
    WIDTH_INHIBIT_REGISTER_BEAM  => width_inhibit_register_beam,
    WIDTH_EXTERNAL_REGISTER_BEAM => width_external_register_beam,
    SCALER_DEAD                  => scaler_dead,
    TS_GATING_DISABLE            => ts_gating_disable,
    SCALER_PTI1_ACCEPTED         => scaler_pti1_accepted,
    SCALER_PTI2_ACCEPTED         => scaler_pti2_accepted,
    SCALER_PTI3_ACCEPTED         => scaler_pti3_accepted,
    SCALER_PTI4_ACCEPTED         => scaler_pti4_accepted,
    SCALER_PTI5_ACCEPTED         => scaler_pti5_accepted,
    SCALER_TS_ACCEPTED           => scaler_ts_accepted,
    SCALER_VS_ACCEPTED           => scaler_vs_accepted,
    SCALER_MUX1                  => scaler_mux1,
    SCALER_MUX2                  => scaler_mux2,
    DTU_CODE_SELECT              => dtu_code_select_i,
    CAL_TRIGGER_DISABLE          => cal_trigger_disable,
    COM_RUN                      => com_run,
    DTU_ERROR                    => dtu_error,
    HPV                          => HPV,
    HPW                          => HPW,
    DEBUG_REG_00            => debug_1,
    TRB_BUSY_ENABLE         => trb_busy_enable
    );
---------------------I/O ecl port settings and led configuration  ---------------------------------
--              tin(16 downto 9)        <=      (others => '0'); 
  EN(4 downto 1)     <= "1011";
-- en(2) <= '1';                        -- I/O channel 9 to 16 is an output if 0
--              tin(8 downto 1)         <=      (others => '0');        
--              en(1)   <=      '1';    -- I/O channel 1 to 8 is an output if 0
  FLED_T(5 downto 1) <= not INPUT_ENABLE(5 downto 1);  -- input LEDs 
------------------------------decoder for data registers  -----------------------------------------
  process(CK50)
  begin
    if rising_edge(CK50) then
      if CKCSR = '1' then               --read from VME bus
        case (U_AD_REG(17 downto 2)) is
          when x"0000" => delay_register_1             <= U_DAT_IN(3 downto 0);
          when x"0001" => delay_register_2             <= U_DAT_IN(3 downto 0);
          when x"0002" => delay_register_3             <= U_DAT_IN(3 downto 0);
          when x"0003" => delay_register_4             <= U_DAT_IN(3 downto 0);
          when x"0004" => delay_register_5             <= U_DAT_IN(3 downto 0);
          when x"0005" => delay_register_ts            <= U_DAT_IN(3 downto 0);
          when x"0006" => delay_register_vs            <= U_DAT_IN(3 downto 0);
          when x"0007" => downscale_register_1         <= U_DAT_IN(3 downto 0);
          when x"0008" => downscale_register_2         <= U_DAT_IN(3 downto 0);
          when x"0009" => downscale_register_3         <= U_DAT_IN(3 downto 0);
          when x"000a" => downscale_register_4         <= U_DAT_IN(3 downto 0);
          when x"000b" => downscale_register_5         <= U_DAT_IN(3 downto 0);
          when x"000c" => downscale_register_ts        <= U_DAT_IN(3 downto 0);
          when x"000d" => downscale_register_vs        <= U_DAT_IN(3 downto 0);
          when x"000e" => downscale_register_clock     <= U_DAT_IN(3 downto 0);
          when x"000f" => width_register_1             <= U_DAT_IN(3 downto 0);
          when x"0010" => width_register_2             <= U_DAT_IN(3 downto 0);
          when x"0011" => width_register_3             <= U_DAT_IN(3 downto 0);
          when x"0012" => width_register_4             <= U_DAT_IN(3 downto 0);
          when x"0013" => width_register_5             <= U_DAT_IN(3 downto 0);
          when x"0014" => width_register_ts            <= U_DAT_IN(3 downto 0);
          when x"0015" => width_register_vs            <= U_DAT_IN(3 downto 0);
          when x"0016" => or_on_off                    <= U_DAT_IN(7 downto 0);
          when x"0017" => mux_selector_1               <= U_DAT_IN(3 downto 0);
          when x"0018" => mux_selector_2               <= U_DAT_IN(3 downto 0);
                                        -- scalers must not be written by command
          when x"0020" => input_enable                 <= U_DAT_IN(6 downto 0);
          when x"0021" => width_output                 <= U_DAT_IN(3 downto 0);
          when x"0022" => com_run                      <= U_DAT_IN(0);
          when x"0023" => scaler_reset                 <= U_DAT_IN(7 downto 0);
          when x"0024" => branch_en_with_mdc_tof_width <= U_DAT_IN(4 downto 0);
          when x"0025" => scaler_mdc_tof_select        <= U_DAT_IN(7 downto 0);
                                        -- scalers must not be written by command
          when x"0028" => pti5_ts_alternative          <= U_DAT_IN(7 downto 0);
          when x"0029" => delay_register_beam          <= U_DAT_IN(7 downto 0);
          when x"002a" => width_inhibit_register_beam  <= U_DAT_IN(7 downto 0);
          when x"002b" => width_external_register_beam <= U_DAT_IN(7 downto 0);
          when x"002c" => ts_gating_disable            <= U_DAT_IN(6 downto 0);
                                        -- scalers must not be written by command
          when x"0037" => cal_trigger_disable          <= U_DAT_IN(0);
          when x"0038" => dtu_error                    <= U_DAT_IN(0);
          when x"0039" => dtu_code_select_i            <= U_DAT_IN(4 downto 0);
          when x"0041" => trb_busy_enable              <= U_DAT_IN(0);                
          when others  => null;
        end case;
      elsif OECSR = '1' then            --write to VME bus
        case (U_AD_REG(17 downto 2)) is
          when x"0000" => U_DATA_O <= x"0000000" & delay_register_1;
          when x"0001" => U_DATA_O <= x"0000000" & delay_register_2;
          when x"0002" => U_DATA_O <= x"0000000" & delay_register_3;
          when x"0003" => U_DATA_O <= x"0000000" & delay_register_4;
          when x"0004" => U_DATA_O <= x"0000000" & delay_register_5;
          when x"0005" => U_DATA_O <= x"0000000" & delay_register_ts;
          when x"0006" => U_DATA_O <= x"0000000" & delay_register_vs;
          when x"0007" => U_DATA_O <= x"0000000" & downscale_register_1;
          when x"0008" => U_DATA_O <= x"0000000" & downscale_register_2;
          when x"0009" => U_DATA_O <= x"0000000" & downscale_register_3;
          when x"000a" => U_DATA_O <= x"0000000" & downscale_register_4;
          when x"000b" => U_DATA_O <= x"0000000" & downscale_register_5;
          when x"000c" => U_DATA_O <= x"0000000" & downscale_register_ts;
          when x"000d" => U_DATA_O <= x"0000000" & downscale_register_vs;
          when x"000e" => U_DATA_O <= x"0000000" & downscale_register_clock;
          when x"000f" => U_DATA_O <= x"0000000" & width_register_1;
          when x"0010" => U_DATA_O <= x"0000000" & width_register_2;
          when x"0011" => U_DATA_O <= x"0000000" & width_register_3;
          when x"0012" => U_DATA_O <= x"0000000" & width_register_4;
          when x"0013" => U_DATA_O <= x"0000000" & width_register_5;
          when x"0014" => U_DATA_O <= x"0000000" & width_register_ts;
          when x"0015" => U_DATA_O <= x"0000000" & width_register_vs;
          when x"0016" => U_DATA_O <= x"000000" & or_on_off;
          when x"0017" => U_DATA_O <= x"0000000" & mux_selector_1;
          when x"0018" => U_DATA_O <= x"0000000" & mux_selector_2;
          when x"0019" => U_DATA_O <= scaler_pti1;
          when x"001a" => U_DATA_O <= scaler_pti2;
          when x"001b" => U_DATA_O <= scaler_pti3;
          when x"001c" => U_DATA_O <= scaler_pti4;
          when x"001d" => U_DATA_O <= scaler_pti5;
          when x"001e" => U_DATA_O <= scaler_ts;
          when x"001f" => U_DATA_O <= scaler_vs;
          when x"0020" => U_DATA_O <= x"000000" & '0' & input_enable;
          when x"0021" => U_DATA_O <= x"0000000" & width_output;
          when x"0022" => U_DATA_O <= x"0000000" & "000" & com_run;
          when x"0023" => U_DATA_O <= x"000000" & scaler_reset;
          when x"0024" => U_DATA_O <= x"000000" & "000" & branch_en_with_mdc_tof_width;
          when x"0025" => U_DATA_O <= x"000000" & scaler_mdc_tof_select;
          when x"0026" => U_DATA_O <= scaler_mdc;
          when x"0027" => U_DATA_O <= scaler_tof;
          when x"0028" => U_DATA_O <= x"000000" & pti5_ts_alternative;
          when x"0029" => U_DATA_O <= x"000000" & delay_register_beam;
          when x"002a" => U_DATA_O <= x"000000" & width_inhibit_register_beam;
          when x"002b" => U_DATA_O <= x"000000" & width_external_register_beam;
          when x"002c" => U_DATA_O <= x"000000" & '0' & ts_gating_disable;  --b0
          when x"002d" => U_DATA_O <= scaler_dead;
          when x"002e" => U_DATA_O <= scaler_pti1_accepted;
          when x"002f" => U_DATA_O <= scaler_pti2_accepted;
          when x"0030" => U_DATA_O <= scaler_pti3_accepted;
          when x"0031" => U_DATA_O <= scaler_pti4_accepted;
          when x"0032" => U_DATA_O <= scaler_pti5_accepted;
          when x"0033" => U_DATA_O <= scaler_ts_accepted;
          when x"0034" => U_DATA_O <= scaler_vs_accepted;
          when x"0035" => U_DATA_O <= scaler_mux1;
          when x"0036" => U_DATA_O <= scaler_mux2;
          when x"0037" => U_DATA_O <= x"0000000" & "000" & cal_trigger_disable;
          when x"0038" => U_DATA_O <= x"0000000" & "000" & dtu_error;
          when x"0039" => U_DATA_O <= x"000000" & "000" & dtu_code_select_i;
          when x"0040" => U_DATA_O <= debug_1;
          when x"0041" => U_DATA_O <= x"0000000" & "000" & trb_busy_enable;                
          when others  => null;
        end case;
      end if;
    end if;
  end process;
end rtl;
