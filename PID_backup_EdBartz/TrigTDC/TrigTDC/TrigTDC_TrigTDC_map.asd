[ActiveSupport MAP]
Device = LFE3-150EA;
Package = FPBGA672;
Performance = 8;
LUTS_avail = 149040;
LUTS_used = 11405;
FF_avail = 112160;
FF_used = 18431;
INPUT_LVCMOS25 = 3;
INPUT_LVDS25 = 48;
OUTPUT_LVCMOS25 = 24;
OUTPUT_LVDS25 = 11;
IO_avail = 380;
IO_used = 145;
Serdes_avail = 2;
Serdes_used = 0;
PLL_avail = 10;
PLL_used = 3;
EBR_avail = 372;
EBR_used = 1;
;
; start of DSP statistics
MULT18X18C = 0;
MULT9X9C = 0;
ALU54A = 0;
ALU24A = 0;
DSP_MULT_avail = 640;
DSP_MULT_used = 0;
DSP_ALU_avail = 320;
DSP_ALU_used = 0;
; end of DSP statistics
;
; Begin EBR Section
Instance_Name = TDC/ts/rfif/pdp_ram_0_0_0;
Type = DP16KC;
Width_B = 16;
Depth_A = 32;
Depth_B = 32;
REGMODE_A = NOREG;
REGMODE_B = NOREG;
WRITEMODE_A = NORMAL;
WRITEMODE_B = NORMAL;
GSR = DISABLED;
MEM_LPC_FILE = readoutfifo.lpc;
; End EBR Section
; Begin PLL Section
Instance_Name = TDC/CG/P2Clk/PLLInst_0;
Type = EHXPLLF;
Output_Clock(P)_Actual_Frequency = 25.0000;
CLKOP_BYPASS = DISABLED;
CLKOS_BYPASS = DISABLED;
CLKOK_BYPASS = DISABLED;
CLKOK_Input = CLKOP;
FB_MODE = CLKOP;
CLKI_Divider = 2;
CLKFB_Divider = 1;
CLKOP_Divider = 32;
CLKOK_Divider = 2;
Phase_Duty_Control = DYNAMIC;
CLKOS_Phase_Shift_(degree) = 0.0;
CLKOS_Duty_Cycle = 8;
CLKOS_Delay_Adjust_Power_Down = DISABLED;
CLKOS_Delay_Adjust_Static_Delay_(ps) = 0;
CLKOP_Duty_Trim_Polarity = RISING;
CLKOP_Duty_Trim_Polarity_Delay_(ps) = 0;
CLKOS_Duty_Trim_Polarity = RISING;
CLKOS_Duty_Trim_Polarity_Delay_(ps) = 0;
Instance_Name = TDC/CG/P1Clk/PLLInst_0;
Type = EHXPLLF;
Output_Clock(P)_Actual_Frequency = 200.0000;
CLKOP_BYPASS = DISABLED;
CLKOS_BYPASS = DISABLED;
CLKOK_BYPASS = DISABLED;
CLKOK_Input = CLKOP;
FB_MODE = CLKOP;
CLKI_Divider = 1;
CLKFB_Divider = 4;
CLKOP_Divider = 4;
CLKOK_Divider = 2;
Phase_Duty_Control = DYNAMIC;
CLKOS_Phase_Shift_(degree) = 0.0;
CLKOS_Duty_Cycle = 8;
CLKOS_Delay_Adjust_Power_Down = DISABLED;
CLKOS_Delay_Adjust_Static_Delay_(ps) = 0;
CLKOP_Duty_Trim_Polarity = RISING;
CLKOP_Duty_Trim_Polarity_Delay_(ps) = 0;
CLKOS_Duty_Trim_Polarity = RISING;
CLKOS_Duty_Trim_Polarity_Delay_(ps) = 0;
Instance_Name = TDC/CG/PClk/PLLInst_0;
Type = EHXPLLF;
Output_Clock(P)_Actual_Frequency = 50.0000;
CLKOP_BYPASS = DISABLED;
CLKOS_BYPASS = DISABLED;
CLKOK_BYPASS = DISABLED;
CLKOK_Input = CLKOP;
FB_MODE = CLKOP;
CLKI_Divider = 1;
CLKFB_Divider = 1;
CLKOP_Divider = 16;
CLKOK_Divider = 2;
Phase_Duty_Control = DYNAMIC;
CLKOS_Phase_Shift_(degree) = 0.0;
CLKOS_Duty_Cycle = 8;
CLKOS_Delay_Adjust_Power_Down = DISABLED;
CLKOS_Delay_Adjust_Static_Delay_(ps) = 0;
CLKOP_Duty_Trim_Polarity = RISING;
CLKOP_Duty_Trim_Polarity_Delay_(ps) = 0;
CLKOS_Duty_Trim_Polarity = RISING;
CLKOS_Duty_Trim_Polarity_Delay_(ps) = 0;
; End PLL Section