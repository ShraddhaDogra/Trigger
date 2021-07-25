[ActiveSupport MAP]
Device = LCMXO2-4000HC;
Package = FTBGA256;
Performance = 6;
LUTS_avail = 4320;
LUTS_used = 2133;
FF_avail = 4527;
FF_used = 1657;
INPUT_LVDS25 = 19;
OUTPUT_LVCMOS33 = 40;
OUTPUT_LVDS25 = 18;
BIDI_LVCMOS33 = 1;
IO_avail = 207;
IO_used = 115;
EBR_avail = 10;
EBR_used = 1;
; Begin EBR Section
Instance_Name = THE_FLASH_RAM/flashram_0_0_0_0;
Type = DP8KC;
Width_A = 8;
Width_B = 8;
Depth_A = 16;
Depth_B = 16;
REGMODE_A = NOREG;
REGMODE_B = NOREG;
RESETMODE = ASYNC;
ASYNC_RESET_RELEASE = SYNC;
WRITEMODE_A = NORMAL;
WRITEMODE_B = NORMAL;
GSR = DISABLED;
MEM_INIT_FILE = INIT_ALL_0s;
MEM_LPC_FILE = flashram.lpc;
; End EBR Section
; Begin PLL Section
Instance_Name = THE_PLL/PLLInst_0;
Type = EHXPLLJ;
CLKOP_Post_Divider_A_Input = DIVA;
CLKOS_Post_Divider_B_Input = REFCLK;
CLKOS2_Post_Divider_C_Input = DIVC;
CLKOS3_Post_Divider_D_Input = DIVD;
Pre_Divider_A_Input = VCO_PHASE;
Pre_Divider_B_Input = VCO_PHASE;
Pre_Divider_C_Input = VCO_PHASE;
Pre_Divider_D_Input = VCO_PHASE;
VCO_Bypass_A_Input = REFCLK;
VCO_Bypass_B_Input = VCO_PHASE;
VCO_Bypass_C_Input = VCO_PHASE;
VCO_Bypass_D_Input = VCO_PHASE;
FB_MODE = INT_OP;
CLKI_Divider = 1;
CLKFB_Divider = 1;
CLKOP_Divider = 5;
CLKOS_Divider = 1;
CLKOS2_Divider = 1;
CLKOS3_Divider = 1;
Fractional_N_Divider = 0;
CLKOP_Desired_Phase_Shift(degree) = 0;
CLKOP_Trim_Option_Rising/Falling = FALLING;
CLKOP_Trim_Option_Delay = 0;
CLKOS_Desired_Phase_Shift(degree) = 0;
CLKOS_Trim_Option_Rising/Falling = FALLING;
CLKOS_Trim_Option_Delay = 0;
CLKOS2_Desired_Phase_Shift(degree) = 0;
CLKOS3_Desired_Phase_Shift(degree) = 0;
; End PLL Section
;
; start of EFB statistics
I2C = 0;
SPI = 0;
TimerCounter = 0;
UFM = 1;
PLL = 0;
; end of EFB statistics
;
