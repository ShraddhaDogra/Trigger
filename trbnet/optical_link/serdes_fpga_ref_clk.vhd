

-- channel_0 is in "8b10b" mode
-- channel_1 is in "8b10b" mode
-- channel_2 is in "8b10b" mode
-- channel_3 is in "8b10b" mode

--synopsys translate_off

library pcsa_mti_work;
use pcsa_mti_work.all;
library IEEE;
use IEEE.std_logic_1164.all;

entity PCSA is
GENERIC(
  CONFIG_FILE : String  := "serdes_fpga_ref_clk.txt"
  );
port (
  HDINP0            : in std_logic;
  HDINN0            : in std_logic;
  HDINP1            : in std_logic;
  HDINN1            : in std_logic;
  HDINP2            : in std_logic;
  HDINN2            : in std_logic;
  HDINP3            : in std_logic;
  HDINN3            : in std_logic;
  HDOUTP0           : out std_logic;
  HDOUTN0           : out std_logic;
  HDOUTP1           : out std_logic;
  HDOUTN1           : out std_logic;
  HDOUTP2           : out std_logic;
  HDOUTN2           : out std_logic;
  HDOUTP3           : out std_logic;
  HDOUTN3           : out std_logic;
  REFCLKP           : in std_logic;
  REFCLKN           : in std_logic;
  RXREFCLKP         : in std_logic;
  RXREFCLKN         : in std_logic;
  FFC_QUAD_RST      : in std_logic;
  FFC_MACRO_RST     : in std_logic;

  FFC_LANE_TX_RST0  : in std_logic;
  FFC_LANE_TX_RST1  : in std_logic;
  FFC_LANE_TX_RST2  : in std_logic;
  FFC_LANE_TX_RST3  : in std_logic;

  FFC_LANE_RX_RST0  : in std_logic;
  FFC_LANE_RX_RST1  : in std_logic;
  FFC_LANE_RX_RST2  : in std_logic;
  FFC_LANE_RX_RST3  : in std_logic;

  FFC_PCIE_EI_EN_0  : in std_logic;
  FFC_PCIE_EI_EN_1  : in std_logic;
  FFC_PCIE_EI_EN_2  : in std_logic;
  FFC_PCIE_EI_EN_3  : in std_logic;

  FFC_PCIE_CT_0     : in std_logic;
  FFC_PCIE_CT_1     : in std_logic;
  FFC_PCIE_CT_2     : in std_logic;
  FFC_PCIE_CT_3     : in std_logic;

  FFS_PCIE_CON_0    : out std_logic;
  FFS_PCIE_CON_1    : out std_logic;
  FFS_PCIE_CON_2    : out std_logic;
  FFS_PCIE_CON_3    : out std_logic;

  FFS_PCIE_DONE_0   : out std_logic;
  FFS_PCIE_DONE_1   : out std_logic;
  FFS_PCIE_DONE_2   : out std_logic;
  FFS_PCIE_DONE_3   : out std_logic;

  FFC_PCIE_TX_0     : in std_logic;
  FFC_PCIE_TX_1     : in std_logic;
  FFC_PCIE_TX_2     : in std_logic;
  FFC_PCIE_TX_3     : in std_logic;

  FFC_PCIE_RX_0     : in std_logic;
  FFC_PCIE_RX_1     : in std_logic;
  FFC_PCIE_RX_2     : in std_logic;
  FFC_PCIE_RX_3     : in std_logic;

  FFC_SD_0          : in std_logic;
  FFC_SD_1          : in std_logic;
  FFC_SD_2          : in std_logic;
  FFC_SD_3          : in std_logic;

  FFC_EN_CGA_0      : in std_logic;
  FFC_EN_CGA_1      : in std_logic;
  FFC_EN_CGA_2      : in std_logic;
  FFC_EN_CGA_3      : in std_logic;

  FFC_ALIGN_EN_0    : in std_logic;
  FFC_ALIGN_EN_1    : in std_logic;
  FFC_ALIGN_EN_2    : in std_logic;
  FFC_ALIGN_EN_3    : in std_logic;

  FFC_AB_RESET      : in std_logic;
  FFC_CD_RESET      : in std_logic;

  FFS_LS_STATUS_0   : out std_logic;
  FFS_LS_STATUS_1   : out std_logic;
  FFS_LS_STATUS_2   : out std_logic;
  FFS_LS_STATUS_3   : out std_logic;

  FFS_AB_STATUS     : out std_logic;
  FFS_CD_STATUS     : out std_logic;

  FFS_AB_ALIGNED    : out std_logic;
  FFS_CD_ALIGNED    : out std_logic;

  FFS_RLOS_LO0      : out std_logic;
  FFS_RLOS_LO1      : out std_logic;
  FFS_RLOS_LO2      : out std_logic;
  FFS_RLOS_LO3      : out std_logic;

  FFS_AB_FAILED     : out std_logic;
  FFS_CD_FAILED     : out std_logic;

  FFC_FB_LB_0       : in std_logic;
  FFC_FB_LB_1       : in std_logic;
  FFC_FB_LB_2       : in std_logic;
  FFC_FB_LB_3       : in std_logic;

  FFC_SB_INV_RX_0   : in std_logic;
  FFC_SB_INV_RX_1   : in std_logic;
  FFC_SB_INV_RX_2   : in std_logic;
  FFC_SB_INV_RX_3   : in std_logic;

  FFS_CC_ORUN_0     : out std_logic;
  FFS_CC_ORUN_1     : out std_logic;
  FFS_CC_ORUN_2     : out std_logic;
  FFS_CC_ORUN_3     : out std_logic;

  FFS_CC_URUN_0     : out std_logic;
  FFS_CC_URUN_1     : out std_logic;
  FFS_CC_URUN_2     : out std_logic;
  FFS_CC_URUN_3     : out std_logic;

  FFC_CK_CORE_TX    : in std_logic;
  FFC_CK_CORE_RX    : in std_logic;
  RDATAO_7          : out std_logic;
  RDATAO_6          : out std_logic;
  RDATAO_5          : out std_logic;
  RDATAO_4          : out std_logic;
  RDATAO_3          : out std_logic;
  RDATAO_2          : out std_logic;
  RDATAO_1          : out std_logic;
  RDATAO_0          : out std_logic;
  INTO              : out std_logic;

  ADDRI_7           : in std_logic;
  ADDRI_6           : in std_logic;
  ADDRI_5           : in std_logic;
  ADDRI_4           : in std_logic;
  ADDRI_3           : in std_logic;
  ADDRI_2           : in std_logic;
  ADDRI_1           : in std_logic;
  ADDRI_0           : in std_logic;
  WDATAI_7          : in std_logic;
  WDATAI_6          : in std_logic;
  WDATAI_5          : in std_logic;
  WDATAI_4          : in std_logic;
  WDATAI_3          : in std_logic;
  WDATAI_2          : in std_logic;
  WDATAI_1          : in std_logic;
  WDATAI_0          : in std_logic;
  RDI               : in std_logic;
  WSTBI             : in std_logic;

  CS_CHIF_0         : in std_logic;
  CS_CHIF_1         : in std_logic;
  CS_CHIF_2         : in std_logic;
  CS_CHIF_3         : in std_logic;
  CS_QIF            : in std_logic;

  QUAD_ID_1         : in std_logic;
  QUAD_ID_0         : in std_logic;

  FF_SYSCLK_P1      : out std_logic;

  FF_SYSCLK0        : out std_logic;
  FF_SYSCLK1        : out std_logic;
  FF_SYSCLK2        : out std_logic;
  FF_SYSCLK3        : out std_logic;

  FF_RXCLK_P1       : out std_logic;
  FF_RXCLK_P2       : out std_logic;

  FF_RXCLK0         : out std_logic;
  FF_RXCLK1         : out std_logic;
  FF_RXCLK2         : out std_logic;
  FF_RXCLK3         : out std_logic;

  QUAD_CLK          : out std_logic;

  GRP_CLK_P1_3      : in std_logic;
  GRP_CLK_P1_2      : in std_logic;
  GRP_CLK_P1_1      : in std_logic;
  GRP_CLK_P1_0      : in std_logic;

  GRP_CLK_P2_3      : in std_logic;
  GRP_CLK_P2_2      : in std_logic;
  GRP_CLK_P2_1      : in std_logic;
  GRP_CLK_P2_0      : in std_logic;

  GRP_START_3      : in std_logic;
  GRP_START_2      : in std_logic;
  GRP_START_1      : in std_logic;
  GRP_START_0      : in std_logic;

  GRP_DONE_3      : in std_logic;
  GRP_DONE_2      : in std_logic;
  GRP_DONE_1      : in std_logic;
  GRP_DONE_0      : in std_logic;

  GRP_DESKEW_ERROR_3      : in std_logic;
  GRP_DESKEW_ERROR_2      : in std_logic;
  GRP_DESKEW_ERROR_1      : in std_logic;
  GRP_DESKEW_ERROR_0      : in std_logic;

  IQA_START_LS      : out std_logic;
  IQA_DONE_LS       : out std_logic;
  IQA_AND_FP1_LS    : out std_logic;
  IQA_AND_FP0_LS    : out std_logic;
  IQA_OR_FP1_LS     : out std_logic;
  IQA_OR_FP0_LS     : out std_logic;
  IQA_RST_N         : out std_logic;

  FF_TCLK0          : in std_logic;
  FF_TCLK1          : in std_logic;
  FF_TCLK2          : in std_logic;
  FF_TCLK3          : in std_logic;

  FF_RCLK0          : in std_logic;
  FF_RCLK1          : in std_logic;
  FF_RCLK2          : in std_logic;
  FF_RCLK3          : in std_logic;
  TCK_FMACP         : in std_logic;

  FF_TXD_0_23       : in std_logic;
  FF_TXD_0_22       : in std_logic;
  FF_TXD_0_21       : in std_logic;
  FF_TXD_0_20       : in std_logic;
  FF_TXD_0_19       : in std_logic;
  FF_TXD_0_18       : in std_logic;
  FF_TXD_0_17       : in std_logic;
  FF_TXD_0_16       : in std_logic;
  FF_TXD_0_15       : in std_logic;
  FF_TXD_0_14       : in std_logic;
  FF_TXD_0_13       : in std_logic;
  FF_TXD_0_12       : in std_logic;
  FF_TXD_0_11       : in std_logic;
  FF_TXD_0_10       : in std_logic;
  FF_TXD_0_9       : in std_logic;
  FF_TXD_0_8       : in std_logic;
  FF_TXD_0_7       : in std_logic;
  FF_TXD_0_6       : in std_logic;
  FF_TXD_0_5       : in std_logic;
  FF_TXD_0_4       : in std_logic;
  FF_TXD_0_3       : in std_logic;
  FF_TXD_0_2       : in std_logic;
  FF_TXD_0_1       : in std_logic;
  FF_TXD_0_0       : in std_logic;
  FB_RXD_0_23       : out std_logic;
  FB_RXD_0_22       : out std_logic;
  FB_RXD_0_21       : out std_logic;
  FB_RXD_0_20       : out std_logic;
  FB_RXD_0_19       : out std_logic;
  FB_RXD_0_18       : out std_logic;
  FB_RXD_0_17       : out std_logic;
  FB_RXD_0_16       : out std_logic;
  FB_RXD_0_15       : out std_logic;
  FB_RXD_0_14       : out std_logic;
  FB_RXD_0_13       : out std_logic;
  FB_RXD_0_12       : out std_logic;
  FB_RXD_0_11       : out std_logic;
  FB_RXD_0_10       : out std_logic;
  FB_RXD_0_9       : out std_logic;
  FB_RXD_0_8       : out std_logic;
  FB_RXD_0_7       : out std_logic;
  FB_RXD_0_6       : out std_logic;
  FB_RXD_0_5       : out std_logic;
  FB_RXD_0_4       : out std_logic;
  FB_RXD_0_3       : out std_logic;
  FB_RXD_0_2       : out std_logic;
  FB_RXD_0_1       : out std_logic;
  FB_RXD_0_0       : out std_logic;
  FF_TXD_1_23       : in std_logic;
  FF_TXD_1_22       : in std_logic;
  FF_TXD_1_21       : in std_logic;
  FF_TXD_1_20       : in std_logic;
  FF_TXD_1_19       : in std_logic;
  FF_TXD_1_18       : in std_logic;
  FF_TXD_1_17       : in std_logic;
  FF_TXD_1_16       : in std_logic;
  FF_TXD_1_15       : in std_logic;
  FF_TXD_1_14       : in std_logic;
  FF_TXD_1_13       : in std_logic;
  FF_TXD_1_12       : in std_logic;
  FF_TXD_1_11       : in std_logic;
  FF_TXD_1_10       : in std_logic;
  FF_TXD_1_9       : in std_logic;
  FF_TXD_1_8       : in std_logic;
  FF_TXD_1_7       : in std_logic;
  FF_TXD_1_6       : in std_logic;
  FF_TXD_1_5       : in std_logic;
  FF_TXD_1_4       : in std_logic;
  FF_TXD_1_3       : in std_logic;
  FF_TXD_1_2       : in std_logic;
  FF_TXD_1_1       : in std_logic;
  FF_TXD_1_0       : in std_logic;
  FB_RXD_1_23       : out std_logic;
  FB_RXD_1_22       : out std_logic;
  FB_RXD_1_21       : out std_logic;
  FB_RXD_1_20       : out std_logic;
  FB_RXD_1_19       : out std_logic;
  FB_RXD_1_18       : out std_logic;
  FB_RXD_1_17       : out std_logic;
  FB_RXD_1_16       : out std_logic;
  FB_RXD_1_15       : out std_logic;
  FB_RXD_1_14       : out std_logic;
  FB_RXD_1_13       : out std_logic;
  FB_RXD_1_12       : out std_logic;
  FB_RXD_1_11       : out std_logic;
  FB_RXD_1_10       : out std_logic;
  FB_RXD_1_9       : out std_logic;
  FB_RXD_1_8       : out std_logic;
  FB_RXD_1_7       : out std_logic;
  FB_RXD_1_6       : out std_logic;
  FB_RXD_1_5       : out std_logic;
  FB_RXD_1_4       : out std_logic;
  FB_RXD_1_3       : out std_logic;
  FB_RXD_1_2       : out std_logic;
  FB_RXD_1_1       : out std_logic;
  FB_RXD_1_0       : out std_logic;
  FF_TXD_2_23       : in std_logic;
  FF_TXD_2_22       : in std_logic;
  FF_TXD_2_21       : in std_logic;
  FF_TXD_2_20       : in std_logic;
  FF_TXD_2_19       : in std_logic;
  FF_TXD_2_18       : in std_logic;
  FF_TXD_2_17       : in std_logic;
  FF_TXD_2_16       : in std_logic;
  FF_TXD_2_15       : in std_logic;
  FF_TXD_2_14       : in std_logic;
  FF_TXD_2_13       : in std_logic;
  FF_TXD_2_12       : in std_logic;
  FF_TXD_2_11       : in std_logic;
  FF_TXD_2_10       : in std_logic;
  FF_TXD_2_9       : in std_logic;
  FF_TXD_2_8       : in std_logic;
  FF_TXD_2_7       : in std_logic;
  FF_TXD_2_6       : in std_logic;
  FF_TXD_2_5       : in std_logic;
  FF_TXD_2_4       : in std_logic;
  FF_TXD_2_3       : in std_logic;
  FF_TXD_2_2       : in std_logic;
  FF_TXD_2_1       : in std_logic;
  FF_TXD_2_0       : in std_logic;
  FB_RXD_2_23       : out std_logic;
  FB_RXD_2_22       : out std_logic;
  FB_RXD_2_21       : out std_logic;
  FB_RXD_2_20       : out std_logic;
  FB_RXD_2_19       : out std_logic;
  FB_RXD_2_18       : out std_logic;
  FB_RXD_2_17       : out std_logic;
  FB_RXD_2_16       : out std_logic;
  FB_RXD_2_15       : out std_logic;
  FB_RXD_2_14       : out std_logic;
  FB_RXD_2_13       : out std_logic;
  FB_RXD_2_12       : out std_logic;
  FB_RXD_2_11       : out std_logic;
  FB_RXD_2_10       : out std_logic;
  FB_RXD_2_9       : out std_logic;
  FB_RXD_2_8       : out std_logic;
  FB_RXD_2_7       : out std_logic;
  FB_RXD_2_6       : out std_logic;
  FB_RXD_2_5       : out std_logic;
  FB_RXD_2_4       : out std_logic;
  FB_RXD_2_3       : out std_logic;
  FB_RXD_2_2       : out std_logic;
  FB_RXD_2_1       : out std_logic;
  FB_RXD_2_0       : out std_logic;
  FF_TXD_3_23       : in std_logic;
  FF_TXD_3_22       : in std_logic;
  FF_TXD_3_21       : in std_logic;
  FF_TXD_3_20       : in std_logic;
  FF_TXD_3_19       : in std_logic;
  FF_TXD_3_18       : in std_logic;
  FF_TXD_3_17       : in std_logic;
  FF_TXD_3_16       : in std_logic;
  FF_TXD_3_15       : in std_logic;
  FF_TXD_3_14       : in std_logic;
  FF_TXD_3_13       : in std_logic;
  FF_TXD_3_12       : in std_logic;
  FF_TXD_3_11       : in std_logic;
  FF_TXD_3_10       : in std_logic;
  FF_TXD_3_9       : in std_logic;
  FF_TXD_3_8       : in std_logic;
  FF_TXD_3_7       : in std_logic;
  FF_TXD_3_6       : in std_logic;
  FF_TXD_3_5       : in std_logic;
  FF_TXD_3_4       : in std_logic;
  FF_TXD_3_3       : in std_logic;
  FF_TXD_3_2       : in std_logic;
  FF_TXD_3_1       : in std_logic;
  FF_TXD_3_0       : in std_logic;
  FB_RXD_3_23       : out std_logic;
  FB_RXD_3_22       : out std_logic;
  FB_RXD_3_21       : out std_logic;
  FB_RXD_3_20       : out std_logic;
  FB_RXD_3_19       : out std_logic;
  FB_RXD_3_18       : out std_logic;
  FB_RXD_3_17       : out std_logic;
  FB_RXD_3_16       : out std_logic;
  FB_RXD_3_15       : out std_logic;
  FB_RXD_3_14       : out std_logic;
  FB_RXD_3_13       : out std_logic;
  FB_RXD_3_12       : out std_logic;
  FB_RXD_3_11       : out std_logic;
  FB_RXD_3_10       : out std_logic;
  FB_RXD_3_9       : out std_logic;
  FB_RXD_3_8       : out std_logic;
  FB_RXD_3_7       : out std_logic;
  FB_RXD_3_6       : out std_logic;
  FB_RXD_3_5       : out std_logic;
  FB_RXD_3_4       : out std_logic;
  FB_RXD_3_3       : out std_logic;
  FB_RXD_3_2       : out std_logic;
  FB_RXD_3_1       : out std_logic;
  FB_RXD_3_0       : out std_logic;
  TCK_FMAC         : out std_logic;
  BS4PAD_0         : out std_logic;
  BS4PAD_1         : out std_logic;
  BS4PAD_2         : out std_logic;
  BS4PAD_3         : out std_logic;
  COUT_21          : out std_logic;
  COUT_20          : out std_logic;
  COUT_19          : out std_logic;
  COUT_18          : out std_logic;
  COUT_17          : out std_logic;
  COUT_16          : out std_logic;
  COUT_15          : out std_logic;
  COUT_14          : out std_logic;
  COUT_13          : out std_logic;
  COUT_12          : out std_logic;
  COUT_11          : out std_logic;
  COUT_10          : out std_logic;
  COUT_9           : out std_logic;
  COUT_8           : out std_logic;
  COUT_7           : out std_logic;
  COUT_6           : out std_logic;
  COUT_5           : out std_logic;
  COUT_4           : out std_logic;
  COUT_3           : out std_logic;
  COUT_2           : out std_logic;
  COUT_1           : out std_logic;
  COUT_0           : out std_logic;
  CIN_12          : in std_logic;
  CIN_11          : in std_logic;
  CIN_10          : in std_logic;
  CIN_9           : in std_logic;
  CIN_8           : in std_logic;
  CIN_7           : in std_logic;
  CIN_6           : in std_logic;
  CIN_5           : in std_logic;
  CIN_4           : in std_logic;
  CIN_3           : in std_logic;
  CIN_2           : in std_logic;
  CIN_1           : in std_logic;
  CIN_0           : in std_logic;
  TESTCLK_MACO     : in std_logic
);

end PCSA;

architecture PCSA_arch of PCSA is

component PCSA_sim
GENERIC(
  CONFIG_FILE : String
  );
port (
  HDINP0            : in std_logic;
  HDINN0            : in std_logic;
  HDINP1            : in std_logic;
  HDINN1            : in std_logic;
  HDINP2            : in std_logic;
  HDINN2            : in std_logic;
  HDINP3            : in std_logic;
  HDINN3            : in std_logic;
  HDOUTP0           : out std_logic;
  HDOUTN0           : out std_logic;
  HDOUTP1           : out std_logic;
  HDOUTN1           : out std_logic;
  HDOUTP2           : out std_logic;
  HDOUTN2           : out std_logic;
  HDOUTP3           : out std_logic;
  HDOUTN3           : out std_logic;
  REFCLKP           : in std_logic;
  REFCLKN           : in std_logic;
  RXREFCLKP         : in std_logic;
  RXREFCLKN         : in std_logic;
  FFC_QUAD_RST      : in std_logic;
  FFC_MACRO_RST     : in std_logic;

  FFC_LANE_TX_RST0  : in std_logic;
  FFC_LANE_TX_RST1  : in std_logic;
  FFC_LANE_TX_RST2  : in std_logic;
  FFC_LANE_TX_RST3  : in std_logic;

  FFC_LANE_RX_RST0  : in std_logic;
  FFC_LANE_RX_RST1  : in std_logic;
  FFC_LANE_RX_RST2  : in std_logic;
  FFC_LANE_RX_RST3  : in std_logic;

  FFC_PCIE_EI_EN_0  : in std_logic;
  FFC_PCIE_EI_EN_1  : in std_logic;
  FFC_PCIE_EI_EN_2  : in std_logic;
  FFC_PCIE_EI_EN_3  : in std_logic;

  FFC_PCIE_CT_0     : in std_logic;
  FFC_PCIE_CT_1     : in std_logic;
  FFC_PCIE_CT_2     : in std_logic;
  FFC_PCIE_CT_3     : in std_logic;

  FFS_PCIE_CON_0    : out std_logic;
  FFS_PCIE_CON_1    : out std_logic;
  FFS_PCIE_CON_2    : out std_logic;
  FFS_PCIE_CON_3    : out std_logic;

  FFS_PCIE_DONE_0   : out std_logic;
  FFS_PCIE_DONE_1   : out std_logic;
  FFS_PCIE_DONE_2   : out std_logic;
  FFS_PCIE_DONE_3   : out std_logic;

  FFC_PCIE_TX_0     : in std_logic;
  FFC_PCIE_TX_1     : in std_logic;
  FFC_PCIE_TX_2     : in std_logic;
  FFC_PCIE_TX_3     : in std_logic;

  FFC_PCIE_RX_0     : in std_logic;
  FFC_PCIE_RX_1     : in std_logic;
  FFC_PCIE_RX_2     : in std_logic;
  FFC_PCIE_RX_3     : in std_logic;

  FFC_SD_0          : in std_logic;
  FFC_SD_1          : in std_logic;
  FFC_SD_2          : in std_logic;
  FFC_SD_3          : in std_logic;

  FFC_EN_CGA_0      : in std_logic;
  FFC_EN_CGA_1      : in std_logic;
  FFC_EN_CGA_2      : in std_logic;
  FFC_EN_CGA_3      : in std_logic;

  FFC_ALIGN_EN_0    : in std_logic;
  FFC_ALIGN_EN_1    : in std_logic;
  FFC_ALIGN_EN_2    : in std_logic;
  FFC_ALIGN_EN_3    : in std_logic;

  FFC_AB_RESET      : in std_logic;
  FFC_CD_RESET      : in std_logic;

  FFS_LS_STATUS_0   : out std_logic;
  FFS_LS_STATUS_1   : out std_logic;
  FFS_LS_STATUS_2   : out std_logic;
  FFS_LS_STATUS_3   : out std_logic;

  FFS_AB_STATUS     : out std_logic;
  FFS_CD_STATUS     : out std_logic;

  FFS_AB_ALIGNED    : out std_logic;
  FFS_CD_ALIGNED    : out std_logic;

  FFS_AB_FAILED     : out std_logic;
  FFS_CD_FAILED     : out std_logic;

  FFS_RLOS_LO0      : out std_logic;
  FFS_RLOS_LO1      : out std_logic;
  FFS_RLOS_LO2      : out std_logic;
  FFS_RLOS_LO3      : out std_logic;

  FFC_FB_LB_0       : in std_logic;
  FFC_FB_LB_1       : in std_logic;
  FFC_FB_LB_2       : in std_logic;
  FFC_FB_LB_3       : in std_logic;

  FFC_SB_INV_RX_0   : in std_logic;
  FFC_SB_INV_RX_1   : in std_logic;
  FFC_SB_INV_RX_2   : in std_logic;
  FFC_SB_INV_RX_3   : in std_logic;

  FFS_CC_ORUN_0     : out std_logic;
  FFS_CC_ORUN_1     : out std_logic;
  FFS_CC_ORUN_2     : out std_logic;
  FFS_CC_ORUN_3     : out std_logic;

  FFS_CC_URUN_0     : out std_logic;
  FFS_CC_URUN_1     : out std_logic;
  FFS_CC_URUN_2     : out std_logic;
  FFS_CC_URUN_3     : out std_logic;

  FFC_CK_CORE_TX    : in std_logic;
  FFC_CK_CORE_RX    : in std_logic;
  RDATAO_7          : out std_logic;
  RDATAO_6          : out std_logic;
  RDATAO_5          : out std_logic;
  RDATAO_4          : out std_logic;
  RDATAO_3          : out std_logic;
  RDATAO_2          : out std_logic;
  RDATAO_1          : out std_logic;
  RDATAO_0          : out std_logic;
  INTO              : out std_logic;

  ADDRI_7           : in std_logic;
  ADDRI_6           : in std_logic;
  ADDRI_5           : in std_logic;
  ADDRI_4           : in std_logic;
  ADDRI_3           : in std_logic;
  ADDRI_2           : in std_logic;
  ADDRI_1           : in std_logic;
  ADDRI_0           : in std_logic;
  WDATAI_7          : in std_logic;
  WDATAI_6          : in std_logic;
  WDATAI_5          : in std_logic;
  WDATAI_4          : in std_logic;
  WDATAI_3          : in std_logic;
  WDATAI_2          : in std_logic;
  WDATAI_1          : in std_logic;
  WDATAI_0          : in std_logic;
  RDI               : in std_logic;
  WSTBI             : in std_logic;

  CS_CHIF_0         : in std_logic;
  CS_CHIF_1         : in std_logic;
  CS_CHIF_2         : in std_logic;
  CS_CHIF_3         : in std_logic;
  CS_QIF            : in std_logic;

  QUAD_ID_1         : in std_logic;
  QUAD_ID_0         : in std_logic;

  FF_SYSCLK_P1      : out std_logic;

  FF_SYSCLK0        : out std_logic;
  FF_SYSCLK1        : out std_logic;
  FF_SYSCLK2        : out std_logic;
  FF_SYSCLK3        : out std_logic;

  FF_RXCLK_P1       : out std_logic;
  FF_RXCLK_P2       : out std_logic;

  FF_RXCLK0         : out std_logic;
  FF_RXCLK1         : out std_logic;
  FF_RXCLK2         : out std_logic;
  FF_RXCLK3         : out std_logic;

  QUAD_CLK          : out std_logic;

  GRP_CLK_P1_3      : in std_logic;
  GRP_CLK_P1_2      : in std_logic;
  GRP_CLK_P1_1      : in std_logic;
  GRP_CLK_P1_0      : in std_logic;

  GRP_CLK_P2_3      : in std_logic;
  GRP_CLK_P2_2      : in std_logic;
  GRP_CLK_P2_1      : in std_logic;
  GRP_CLK_P2_0      : in std_logic;

  GRP_START_3      : in std_logic;
  GRP_START_2      : in std_logic;
  GRP_START_1      : in std_logic;
  GRP_START_0      : in std_logic;

  GRP_DONE_3      : in std_logic;
  GRP_DONE_2      : in std_logic;
  GRP_DONE_1      : in std_logic;
  GRP_DONE_0      : in std_logic;

  GRP_DESKEW_ERROR_3      : in std_logic;
  GRP_DESKEW_ERROR_2      : in std_logic;
  GRP_DESKEW_ERROR_1      : in std_logic;
  GRP_DESKEW_ERROR_0      : in std_logic;

  IQA_START_LS      : out std_logic;
  IQA_DONE_LS       : out std_logic;
  IQA_AND_FP1_LS    : out std_logic;
  IQA_AND_FP0_LS    : out std_logic;
  IQA_OR_FP1_LS     : out std_logic;
  IQA_OR_FP0_LS     : out std_logic;
  IQA_RST_N         : out std_logic;

  FF_TCLK0          : in std_logic;
  FF_TCLK1          : in std_logic;
  FF_TCLK2          : in std_logic;
  FF_TCLK3          : in std_logic;

  FF_RCLK0          : in std_logic;
  FF_RCLK1          : in std_logic;
  FF_RCLK2          : in std_logic;
  FF_RCLK3          : in std_logic;
  TCK_FMACP         : in std_logic;

  FF_TXD_0_23       : in std_logic;
  FF_TXD_0_22       : in std_logic;
  FF_TXD_0_21       : in std_logic;
  FF_TXD_0_20       : in std_logic;
  FF_TXD_0_19       : in std_logic;
  FF_TXD_0_18       : in std_logic;
  FF_TXD_0_17       : in std_logic;
  FF_TXD_0_16       : in std_logic;
  FF_TXD_0_15       : in std_logic;
  FF_TXD_0_14       : in std_logic;
  FF_TXD_0_13       : in std_logic;
  FF_TXD_0_12       : in std_logic;
  FF_TXD_0_11       : in std_logic;
  FF_TXD_0_10       : in std_logic;
  FF_TXD_0_9       : in std_logic;
  FF_TXD_0_8       : in std_logic;
  FF_TXD_0_7       : in std_logic;
  FF_TXD_0_6       : in std_logic;
  FF_TXD_0_5       : in std_logic;
  FF_TXD_0_4       : in std_logic;
  FF_TXD_0_3       : in std_logic;
  FF_TXD_0_2       : in std_logic;
  FF_TXD_0_1       : in std_logic;
  FF_TXD_0_0       : in std_logic;
  FB_RXD_0_23       : out std_logic;
  FB_RXD_0_22       : out std_logic;
  FB_RXD_0_21       : out std_logic;
  FB_RXD_0_20       : out std_logic;
  FB_RXD_0_19       : out std_logic;
  FB_RXD_0_18       : out std_logic;
  FB_RXD_0_17       : out std_logic;
  FB_RXD_0_16       : out std_logic;
  FB_RXD_0_15       : out std_logic;
  FB_RXD_0_14       : out std_logic;
  FB_RXD_0_13       : out std_logic;
  FB_RXD_0_12       : out std_logic;
  FB_RXD_0_11       : out std_logic;
  FB_RXD_0_10       : out std_logic;
  FB_RXD_0_9       : out std_logic;
  FB_RXD_0_8       : out std_logic;
  FB_RXD_0_7       : out std_logic;
  FB_RXD_0_6       : out std_logic;
  FB_RXD_0_5       : out std_logic;
  FB_RXD_0_4       : out std_logic;
  FB_RXD_0_3       : out std_logic;
  FB_RXD_0_2       : out std_logic;
  FB_RXD_0_1       : out std_logic;
  FB_RXD_0_0       : out std_logic;
  FF_TXD_1_23       : in std_logic;
  FF_TXD_1_22       : in std_logic;
  FF_TXD_1_21       : in std_logic;
  FF_TXD_1_20       : in std_logic;
  FF_TXD_1_19       : in std_logic;
  FF_TXD_1_18       : in std_logic;
  FF_TXD_1_17       : in std_logic;
  FF_TXD_1_16       : in std_logic;
  FF_TXD_1_15       : in std_logic;
  FF_TXD_1_14       : in std_logic;
  FF_TXD_1_13       : in std_logic;
  FF_TXD_1_12       : in std_logic;
  FF_TXD_1_11       : in std_logic;
  FF_TXD_1_10       : in std_logic;
  FF_TXD_1_9       : in std_logic;
  FF_TXD_1_8       : in std_logic;
  FF_TXD_1_7       : in std_logic;
  FF_TXD_1_6       : in std_logic;
  FF_TXD_1_5       : in std_logic;
  FF_TXD_1_4       : in std_logic;
  FF_TXD_1_3       : in std_logic;
  FF_TXD_1_2       : in std_logic;
  FF_TXD_1_1       : in std_logic;
  FF_TXD_1_0       : in std_logic;
  FB_RXD_1_23       : out std_logic;
  FB_RXD_1_22       : out std_logic;
  FB_RXD_1_21       : out std_logic;
  FB_RXD_1_20       : out std_logic;
  FB_RXD_1_19       : out std_logic;
  FB_RXD_1_18       : out std_logic;
  FB_RXD_1_17       : out std_logic;
  FB_RXD_1_16       : out std_logic;
  FB_RXD_1_15       : out std_logic;
  FB_RXD_1_14       : out std_logic;
  FB_RXD_1_13       : out std_logic;
  FB_RXD_1_12       : out std_logic;
  FB_RXD_1_11       : out std_logic;
  FB_RXD_1_10       : out std_logic;
  FB_RXD_1_9       : out std_logic;
  FB_RXD_1_8       : out std_logic;
  FB_RXD_1_7       : out std_logic;
  FB_RXD_1_6       : out std_logic;
  FB_RXD_1_5       : out std_logic;
  FB_RXD_1_4       : out std_logic;
  FB_RXD_1_3       : out std_logic;
  FB_RXD_1_2       : out std_logic;
  FB_RXD_1_1       : out std_logic;
  FB_RXD_1_0       : out std_logic;
  FF_TXD_2_23       : in std_logic;
  FF_TXD_2_22       : in std_logic;
  FF_TXD_2_21       : in std_logic;
  FF_TXD_2_20       : in std_logic;
  FF_TXD_2_19       : in std_logic;
  FF_TXD_2_18       : in std_logic;
  FF_TXD_2_17       : in std_logic;
  FF_TXD_2_16       : in std_logic;
  FF_TXD_2_15       : in std_logic;
  FF_TXD_2_14       : in std_logic;
  FF_TXD_2_13       : in std_logic;
  FF_TXD_2_12       : in std_logic;
  FF_TXD_2_11       : in std_logic;
  FF_TXD_2_10       : in std_logic;
  FF_TXD_2_9       : in std_logic;
  FF_TXD_2_8       : in std_logic;
  FF_TXD_2_7       : in std_logic;
  FF_TXD_2_6       : in std_logic;
  FF_TXD_2_5       : in std_logic;
  FF_TXD_2_4       : in std_logic;
  FF_TXD_2_3       : in std_logic;
  FF_TXD_2_2       : in std_logic;
  FF_TXD_2_1       : in std_logic;
  FF_TXD_2_0       : in std_logic;
  FB_RXD_2_23       : out std_logic;
  FB_RXD_2_22       : out std_logic;
  FB_RXD_2_21       : out std_logic;
  FB_RXD_2_20       : out std_logic;
  FB_RXD_2_19       : out std_logic;
  FB_RXD_2_18       : out std_logic;
  FB_RXD_2_17       : out std_logic;
  FB_RXD_2_16       : out std_logic;
  FB_RXD_2_15       : out std_logic;
  FB_RXD_2_14       : out std_logic;
  FB_RXD_2_13       : out std_logic;
  FB_RXD_2_12       : out std_logic;
  FB_RXD_2_11       : out std_logic;
  FB_RXD_2_10       : out std_logic;
  FB_RXD_2_9       : out std_logic;
  FB_RXD_2_8       : out std_logic;
  FB_RXD_2_7       : out std_logic;
  FB_RXD_2_6       : out std_logic;
  FB_RXD_2_5       : out std_logic;
  FB_RXD_2_4       : out std_logic;
  FB_RXD_2_3       : out std_logic;
  FB_RXD_2_2       : out std_logic;
  FB_RXD_2_1       : out std_logic;
  FB_RXD_2_0       : out std_logic;
  FF_TXD_3_23       : in std_logic;
  FF_TXD_3_22       : in std_logic;
  FF_TXD_3_21       : in std_logic;
  FF_TXD_3_20       : in std_logic;
  FF_TXD_3_19       : in std_logic;
  FF_TXD_3_18       : in std_logic;
  FF_TXD_3_17       : in std_logic;
  FF_TXD_3_16       : in std_logic;
  FF_TXD_3_15       : in std_logic;
  FF_TXD_3_14       : in std_logic;
  FF_TXD_3_13       : in std_logic;
  FF_TXD_3_12       : in std_logic;
  FF_TXD_3_11       : in std_logic;
  FF_TXD_3_10       : in std_logic;
  FF_TXD_3_9       : in std_logic;
  FF_TXD_3_8       : in std_logic;
  FF_TXD_3_7       : in std_logic;
  FF_TXD_3_6       : in std_logic;
  FF_TXD_3_5       : in std_logic;
  FF_TXD_3_4       : in std_logic;
  FF_TXD_3_3       : in std_logic;
  FF_TXD_3_2       : in std_logic;
  FF_TXD_3_1       : in std_logic;
  FF_TXD_3_0       : in std_logic;
  FB_RXD_3_23       : out std_logic;
  FB_RXD_3_22       : out std_logic;
  FB_RXD_3_21       : out std_logic;
  FB_RXD_3_20       : out std_logic;
  FB_RXD_3_19       : out std_logic;
  FB_RXD_3_18       : out std_logic;
  FB_RXD_3_17       : out std_logic;
  FB_RXD_3_16       : out std_logic;
  FB_RXD_3_15       : out std_logic;
  FB_RXD_3_14       : out std_logic;
  FB_RXD_3_13       : out std_logic;
  FB_RXD_3_12       : out std_logic;
  FB_RXD_3_11       : out std_logic;
  FB_RXD_3_10       : out std_logic;
  FB_RXD_3_9       : out std_logic;
  FB_RXD_3_8       : out std_logic;
  FB_RXD_3_7       : out std_logic;
  FB_RXD_3_6       : out std_logic;
  FB_RXD_3_5       : out std_logic;
  FB_RXD_3_4       : out std_logic;
  FB_RXD_3_3       : out std_logic;
  FB_RXD_3_2       : out std_logic;
  FB_RXD_3_1       : out std_logic;
  FB_RXD_3_0       : out std_logic;
  TCK_FMAC         : out std_logic;
  BS4PAD_0         : out std_logic;
  BS4PAD_1         : out std_logic;
  BS4PAD_2         : out std_logic;
  BS4PAD_3         : out std_logic;
  COUT_21          : out std_logic;
  COUT_20          : out std_logic;
  COUT_19          : out std_logic;
  COUT_18          : out std_logic;
  COUT_17          : out std_logic;
  COUT_16          : out std_logic;
  COUT_15          : out std_logic;
  COUT_14          : out std_logic;
  COUT_13          : out std_logic;
  COUT_12          : out std_logic;
  COUT_11          : out std_logic;
  COUT_10          : out std_logic;
  COUT_9           : out std_logic;
  COUT_8           : out std_logic;
  COUT_7           : out std_logic;
  COUT_6           : out std_logic;
  COUT_5           : out std_logic;
  COUT_4           : out std_logic;
  COUT_3           : out std_logic;
  COUT_2           : out std_logic;
  COUT_1           : out std_logic;
  COUT_0           : out std_logic;
  CIN_12          : in std_logic;
  CIN_11          : in std_logic;
  CIN_10          : in std_logic;
  CIN_9           : in std_logic;
  CIN_8           : in std_logic;
  CIN_7           : in std_logic;
  CIN_6           : in std_logic;
  CIN_5           : in std_logic;
  CIN_4           : in std_logic;
  CIN_3           : in std_logic;
  CIN_2           : in std_logic;
  CIN_1           : in std_logic;
  CIN_0           : in std_logic;
  TESTCLK_MACO     : in std_logic
);
end component;

begin

PCSA_sim_inst : PCSA_sim 
generic map (
  CONFIG_FILE => CONFIG_FILE)
port map (
  HDINP0 => HDINP0,
  HDINN0 => HDINN0,
  HDINP1 => HDINP1,
  HDINN1 => HDINN1,
  HDINP2 => HDINP2,
  HDINN2 => HDINN2,
  HDINP3 => HDINP3,
  HDINN3 => HDINN3,
  HDOUTP0 => HDOUTP0,
  HDOUTN0 => HDOUTN0,
  HDOUTP1 => HDOUTP1,
  HDOUTN1 => HDOUTN1,
  HDOUTP2 => HDOUTP2,
  HDOUTN2 => HDOUTN2,
  HDOUTP3 => HDOUTP3,
  HDOUTN3 => HDOUTN3,
  REFCLKP => REFCLKP,
  REFCLKN => REFCLKN,
  RXREFCLKP => RXREFCLKP,
  RXREFCLKN => RXREFCLKN,
  FFC_QUAD_RST => FFC_QUAD_RST,
  FFC_MACRO_RST => FFC_MACRO_RST,
  FFC_LANE_TX_RST0 => FFC_LANE_TX_RST0,
  FFC_LANE_TX_RST1 => FFC_LANE_TX_RST1,
  FFC_LANE_TX_RST2 => FFC_LANE_TX_RST2,
  FFC_LANE_TX_RST3 => FFC_LANE_TX_RST3,
  FFC_LANE_RX_RST0 => FFC_LANE_RX_RST0,
  FFC_LANE_RX_RST1 => FFC_LANE_RX_RST1,
  FFC_LANE_RX_RST2 => FFC_LANE_RX_RST2,
  FFC_LANE_RX_RST3 => FFC_LANE_RX_RST3,
  FFC_PCIE_EI_EN_0 => FFC_PCIE_EI_EN_0,
  FFC_PCIE_EI_EN_1 => FFC_PCIE_EI_EN_1,
  FFC_PCIE_EI_EN_2 => FFC_PCIE_EI_EN_2,
  FFC_PCIE_EI_EN_3 => FFC_PCIE_EI_EN_3,
  FFC_PCIE_CT_0 => FFC_PCIE_CT_0,
  FFC_PCIE_CT_1 => FFC_PCIE_CT_1,
  FFC_PCIE_CT_2 => FFC_PCIE_CT_2,
  FFC_PCIE_CT_3 => FFC_PCIE_CT_3,
  FFS_PCIE_CON_0 => FFS_PCIE_CON_0,
  FFS_PCIE_CON_1 => FFS_PCIE_CON_1,
  FFS_PCIE_CON_2 => FFS_PCIE_CON_2,
  FFS_PCIE_CON_3 => FFS_PCIE_CON_3,
  FFS_PCIE_DONE_0 => FFS_PCIE_DONE_0,
  FFS_PCIE_DONE_1 => FFS_PCIE_DONE_1,
  FFS_PCIE_DONE_2 => FFS_PCIE_DONE_2,
  FFS_PCIE_DONE_3 => FFS_PCIE_DONE_3,
  FFC_PCIE_TX_0 => FFC_PCIE_TX_0,
  FFC_PCIE_TX_1 => FFC_PCIE_TX_1,
  FFC_PCIE_TX_2 => FFC_PCIE_TX_2,
  FFC_PCIE_TX_3 => FFC_PCIE_TX_3,
  FFC_PCIE_RX_0 => FFC_PCIE_RX_0,
  FFC_PCIE_RX_1 => FFC_PCIE_RX_1,
  FFC_PCIE_RX_2 => FFC_PCIE_RX_2,
  FFC_PCIE_RX_3 => FFC_PCIE_RX_3,
  FFC_SD_0 => FFC_SD_0,
  FFC_SD_1 => FFC_SD_1,
  FFC_SD_2 => FFC_SD_2,
  FFC_SD_3 => FFC_SD_3,
  FFC_EN_CGA_0 => FFC_EN_CGA_0,
  FFC_EN_CGA_1 => FFC_EN_CGA_1,
  FFC_EN_CGA_2 => FFC_EN_CGA_2,
  FFC_EN_CGA_3 => FFC_EN_CGA_3,
  FFC_ALIGN_EN_0 => FFC_ALIGN_EN_0,
  FFC_ALIGN_EN_1 => FFC_ALIGN_EN_1,
  FFC_ALIGN_EN_2 => FFC_ALIGN_EN_2,
  FFC_ALIGN_EN_3 => FFC_ALIGN_EN_3,
  FFC_AB_RESET => FFC_AB_RESET,
  FFC_CD_RESET => FFC_CD_RESET,
  FFS_LS_STATUS_0 => FFS_LS_STATUS_0,
  FFS_LS_STATUS_1 => FFS_LS_STATUS_1,
  FFS_LS_STATUS_2 => FFS_LS_STATUS_2,
  FFS_LS_STATUS_3 => FFS_LS_STATUS_3,
  FFS_AB_STATUS => FFS_AB_STATUS,
  FFS_CD_STATUS => FFS_CD_STATUS,
  FFS_AB_ALIGNED => FFS_AB_ALIGNED,
  FFS_CD_ALIGNED => FFS_CD_ALIGNED,
  FFS_AB_FAILED => FFS_AB_FAILED,
  FFS_CD_FAILED => FFS_CD_FAILED,
  FFS_RLOS_LO0 => FFS_RLOS_LO0,
  FFS_RLOS_LO1 => FFS_RLOS_LO1,
  FFS_RLOS_LO2 => FFS_RLOS_LO2,
  FFS_RLOS_LO3 => FFS_RLOS_LO3,
  FFC_FB_LB_0 => FFC_FB_LB_0,
  FFC_FB_LB_1 => FFC_FB_LB_1,
  FFC_FB_LB_2 => FFC_FB_LB_2,
  FFC_FB_LB_3 => FFC_FB_LB_3,
  FFC_SB_INV_RX_0 => FFC_SB_INV_RX_0,
  FFC_SB_INV_RX_1 => FFC_SB_INV_RX_1,
  FFC_SB_INV_RX_2 => FFC_SB_INV_RX_2,
  FFC_SB_INV_RX_3 => FFC_SB_INV_RX_3,
  FFS_CC_ORUN_0 => FFS_CC_ORUN_0,
  FFS_CC_ORUN_1 => FFS_CC_ORUN_1,
  FFS_CC_ORUN_2 => FFS_CC_ORUN_2,
  FFS_CC_ORUN_3 => FFS_CC_ORUN_3,
  FFS_CC_URUN_0 => FFS_CC_URUN_0,
  FFS_CC_URUN_1 => FFS_CC_URUN_1,
  FFS_CC_URUN_2 => FFS_CC_URUN_2,
  FFS_CC_URUN_3 => FFS_CC_URUN_3,
  FFC_CK_CORE_TX => FFC_CK_CORE_TX,
  FFC_CK_CORE_RX => FFC_CK_CORE_RX,
  BS4PAD_0 => BS4PAD_0,
  BS4PAD_1 => BS4PAD_1,
  BS4PAD_2 => BS4PAD_2,
  BS4PAD_3 => BS4PAD_3,
  RDATAO_7 => RDATAO_7,
  RDATAO_6 => RDATAO_6,
  RDATAO_5 => RDATAO_5,
  RDATAO_4 => RDATAO_4,
  RDATAO_3 => RDATAO_3,
  RDATAO_2 => RDATAO_2,
  RDATAO_1 => RDATAO_1,
  RDATAO_0 => RDATAO_0,
  INTO => INTO,
  ADDRI_7 => ADDRI_7,
  ADDRI_6 => ADDRI_6,
  ADDRI_5 => ADDRI_5,
  ADDRI_4 => ADDRI_4,
  ADDRI_3 => ADDRI_3,
  ADDRI_2 => ADDRI_2,
  ADDRI_1 => ADDRI_1,
  ADDRI_0 => ADDRI_0,
  WDATAI_7 => WDATAI_7,
  WDATAI_6 => WDATAI_6,
  WDATAI_5 => WDATAI_5,
  WDATAI_4 => WDATAI_4,
  WDATAI_3 => WDATAI_3,
  WDATAI_2 => WDATAI_2,
  WDATAI_1 => WDATAI_1,
  WDATAI_0 => WDATAI_0,
  RDI => RDI,
  WSTBI => WSTBI,
  CS_CHIF_0 => CS_CHIF_0,
  CS_CHIF_1 => CS_CHIF_1,
  CS_CHIF_2 => CS_CHIF_2,
  CS_CHIF_3 => CS_CHIF_3,
  CS_QIF => CS_QIF,
  QUAD_ID_1 => QUAD_ID_1,
  QUAD_ID_0 => QUAD_ID_0,
  FF_SYSCLK_P1 => FF_SYSCLK_P1,
  FF_SYSCLK0 => FF_SYSCLK0,
  FF_SYSCLK1 => FF_SYSCLK1,
  FF_SYSCLK2 => FF_SYSCLK2,
  FF_SYSCLK3 => FF_SYSCLK3,
  FF_RXCLK_P1 => FF_RXCLK_P1,
  FF_RXCLK_P2 => FF_RXCLK_P2,
  FF_RXCLK0 => FF_RXCLK0,
  FF_RXCLK1 => FF_RXCLK1,
  FF_RXCLK2 => FF_RXCLK2,
  FF_RXCLK3 => FF_RXCLK3,
  QUAD_CLK => QUAD_CLK,
  GRP_CLK_P1_3 => GRP_CLK_P1_3,
  GRP_CLK_P1_2 => GRP_CLK_P1_2,
  GRP_CLK_P1_1 => GRP_CLK_P1_1,
  GRP_CLK_P1_0 => GRP_CLK_P1_0,
  GRP_CLK_P2_3 => GRP_CLK_P2_3,
  GRP_CLK_P2_2 => GRP_CLK_P2_2,
  GRP_CLK_P2_1 => GRP_CLK_P2_1,
  GRP_CLK_P2_0 => GRP_CLK_P2_0,
  GRP_START_3 => GRP_START_3,
  GRP_START_2 => GRP_START_2,
  GRP_START_1 => GRP_START_1,
  GRP_START_0 => GRP_START_0,
  GRP_DONE_3 => GRP_DONE_3,
  GRP_DONE_2 => GRP_DONE_2,
  GRP_DONE_1 => GRP_DONE_1,
  GRP_DONE_0 => GRP_DONE_0,
  GRP_DESKEW_ERROR_3 => GRP_DESKEW_ERROR_3,
  GRP_DESKEW_ERROR_2 => GRP_DESKEW_ERROR_2,
  GRP_DESKEW_ERROR_1 => GRP_DESKEW_ERROR_1,
  GRP_DESKEW_ERROR_0 => GRP_DESKEW_ERROR_0,
  IQA_START_LS => IQA_START_LS,
  IQA_DONE_LS => IQA_DONE_LS,
  IQA_AND_FP1_LS => IQA_AND_FP1_LS,
  IQA_AND_FP0_LS => IQA_AND_FP0_LS,
  IQA_OR_FP1_LS => IQA_OR_FP1_LS,
  IQA_OR_FP0_LS => IQA_OR_FP0_LS,
  IQA_RST_N => IQA_RST_N,
  FF_TCLK0 => FF_TCLK0,
  FF_TCLK1 => FF_TCLK1,
  FF_TCLK2 => FF_TCLK2,
  FF_TCLK3 => FF_TCLK3,
  FF_RCLK0 => FF_RCLK0,
  FF_RCLK1 => FF_RCLK1,
  FF_RCLK2 => FF_RCLK2,
  FF_RCLK3 => FF_RCLK3,
  TCK_FMACP => TCK_FMACP,
  FF_TXD_0_23 => FF_TXD_0_23,
  FF_TXD_0_22 => FF_TXD_0_22,
  FF_TXD_0_21 => FF_TXD_0_21,
  FF_TXD_0_20 => FF_TXD_0_20,
  FF_TXD_0_19 => FF_TXD_0_19,
  FF_TXD_0_18 => FF_TXD_0_18,
  FF_TXD_0_17 => FF_TXD_0_17,
  FF_TXD_0_16 => FF_TXD_0_16,
  FF_TXD_0_15 => FF_TXD_0_15,
  FF_TXD_0_14 => FF_TXD_0_14,
  FF_TXD_0_13 => FF_TXD_0_13,
  FF_TXD_0_12 => FF_TXD_0_12,
  FF_TXD_0_11 => FF_TXD_0_11,
  FF_TXD_0_10 => FF_TXD_0_10,
  FF_TXD_0_9 => FF_TXD_0_9,
  FF_TXD_0_8 => FF_TXD_0_8,
  FF_TXD_0_7 => FF_TXD_0_7,
  FF_TXD_0_6 => FF_TXD_0_6,
  FF_TXD_0_5 => FF_TXD_0_5,
  FF_TXD_0_4 => FF_TXD_0_4,
  FF_TXD_0_3 => FF_TXD_0_3,
  FF_TXD_0_2 => FF_TXD_0_2,
  FF_TXD_0_1 => FF_TXD_0_1,
  FF_TXD_0_0 => FF_TXD_0_0,
  FB_RXD_0_23 => FB_RXD_0_23,
  FB_RXD_0_22 => FB_RXD_0_22,
  FB_RXD_0_21 => FB_RXD_0_21,
  FB_RXD_0_20 => FB_RXD_0_20,
  FB_RXD_0_19 => FB_RXD_0_19,
  FB_RXD_0_18 => FB_RXD_0_18,
  FB_RXD_0_17 => FB_RXD_0_17,
  FB_RXD_0_16 => FB_RXD_0_16,
  FB_RXD_0_15 => FB_RXD_0_15,
  FB_RXD_0_14 => FB_RXD_0_14,
  FB_RXD_0_13 => FB_RXD_0_13,
  FB_RXD_0_12 => FB_RXD_0_12,
  FB_RXD_0_11 => FB_RXD_0_11,
  FB_RXD_0_10 => FB_RXD_0_10,
  FB_RXD_0_9 => FB_RXD_0_9,
  FB_RXD_0_8 => FB_RXD_0_8,
  FB_RXD_0_7 => FB_RXD_0_7,
  FB_RXD_0_6 => FB_RXD_0_6,
  FB_RXD_0_5 => FB_RXD_0_5,
  FB_RXD_0_4 => FB_RXD_0_4,
  FB_RXD_0_3 => FB_RXD_0_3,
  FB_RXD_0_2 => FB_RXD_0_2,
  FB_RXD_0_1 => FB_RXD_0_1,
  FB_RXD_0_0 => FB_RXD_0_0,
  FF_TXD_1_23 => FF_TXD_1_23,
  FF_TXD_1_22 => FF_TXD_1_22,
  FF_TXD_1_21 => FF_TXD_1_21,
  FF_TXD_1_20 => FF_TXD_1_20,
  FF_TXD_1_19 => FF_TXD_1_19,
  FF_TXD_1_18 => FF_TXD_1_18,
  FF_TXD_1_17 => FF_TXD_1_17,
  FF_TXD_1_16 => FF_TXD_1_16,
  FF_TXD_1_15 => FF_TXD_1_15,
  FF_TXD_1_14 => FF_TXD_1_14,
  FF_TXD_1_13 => FF_TXD_1_13,
  FF_TXD_1_12 => FF_TXD_1_12,
  FF_TXD_1_11 => FF_TXD_1_11,
  FF_TXD_1_10 => FF_TXD_1_10,
  FF_TXD_1_9 => FF_TXD_1_9,
  FF_TXD_1_8 => FF_TXD_1_8,
  FF_TXD_1_7 => FF_TXD_1_7,
  FF_TXD_1_6 => FF_TXD_1_6,
  FF_TXD_1_5 => FF_TXD_1_5,
  FF_TXD_1_4 => FF_TXD_1_4,
  FF_TXD_1_3 => FF_TXD_1_3,
  FF_TXD_1_2 => FF_TXD_1_2,
  FF_TXD_1_1 => FF_TXD_1_1,
  FF_TXD_1_0 => FF_TXD_1_0,
  FB_RXD_1_23 => FB_RXD_1_23,
  FB_RXD_1_22 => FB_RXD_1_22,
  FB_RXD_1_21 => FB_RXD_1_21,
  FB_RXD_1_20 => FB_RXD_1_20,
  FB_RXD_1_19 => FB_RXD_1_19,
  FB_RXD_1_18 => FB_RXD_1_18,
  FB_RXD_1_17 => FB_RXD_1_17,
  FB_RXD_1_16 => FB_RXD_1_16,
  FB_RXD_1_15 => FB_RXD_1_15,
  FB_RXD_1_14 => FB_RXD_1_14,
  FB_RXD_1_13 => FB_RXD_1_13,
  FB_RXD_1_12 => FB_RXD_1_12,
  FB_RXD_1_11 => FB_RXD_1_11,
  FB_RXD_1_10 => FB_RXD_1_10,
  FB_RXD_1_9 => FB_RXD_1_9,
  FB_RXD_1_8 => FB_RXD_1_8,
  FB_RXD_1_7 => FB_RXD_1_7,
  FB_RXD_1_6 => FB_RXD_1_6,
  FB_RXD_1_5 => FB_RXD_1_5,
  FB_RXD_1_4 => FB_RXD_1_4,
  FB_RXD_1_3 => FB_RXD_1_3,
  FB_RXD_1_2 => FB_RXD_1_2,
  FB_RXD_1_1 => FB_RXD_1_1,
  FB_RXD_1_0 => FB_RXD_1_0,
  FF_TXD_2_23 => FF_TXD_2_23,
  FF_TXD_2_22 => FF_TXD_2_22,
  FF_TXD_2_21 => FF_TXD_2_21,
  FF_TXD_2_20 => FF_TXD_2_20,
  FF_TXD_2_19 => FF_TXD_2_19,
  FF_TXD_2_18 => FF_TXD_2_18,
  FF_TXD_2_17 => FF_TXD_2_17,
  FF_TXD_2_16 => FF_TXD_2_16,
  FF_TXD_2_15 => FF_TXD_2_15,
  FF_TXD_2_14 => FF_TXD_2_14,
  FF_TXD_2_13 => FF_TXD_2_13,
  FF_TXD_2_12 => FF_TXD_2_12,
  FF_TXD_2_11 => FF_TXD_2_11,
  FF_TXD_2_10 => FF_TXD_2_10,
  FF_TXD_2_9 => FF_TXD_2_9,
  FF_TXD_2_8 => FF_TXD_2_8,
  FF_TXD_2_7 => FF_TXD_2_7,
  FF_TXD_2_6 => FF_TXD_2_6,
  FF_TXD_2_5 => FF_TXD_2_5,
  FF_TXD_2_4 => FF_TXD_2_4,
  FF_TXD_2_3 => FF_TXD_2_3,
  FF_TXD_2_2 => FF_TXD_2_2,
  FF_TXD_2_1 => FF_TXD_2_1,
  FF_TXD_2_0 => FF_TXD_2_0,
  FB_RXD_2_23 => FB_RXD_2_23,
  FB_RXD_2_22 => FB_RXD_2_22,
  FB_RXD_2_21 => FB_RXD_2_21,
  FB_RXD_2_20 => FB_RXD_2_20,
  FB_RXD_2_19 => FB_RXD_2_19,
  FB_RXD_2_18 => FB_RXD_2_18,
  FB_RXD_2_17 => FB_RXD_2_17,
  FB_RXD_2_16 => FB_RXD_2_16,
  FB_RXD_2_15 => FB_RXD_2_15,
  FB_RXD_2_14 => FB_RXD_2_14,
  FB_RXD_2_13 => FB_RXD_2_13,
  FB_RXD_2_12 => FB_RXD_2_12,
  FB_RXD_2_11 => FB_RXD_2_11,
  FB_RXD_2_10 => FB_RXD_2_10,
  FB_RXD_2_9 => FB_RXD_2_9,
  FB_RXD_2_8 => FB_RXD_2_8,
  FB_RXD_2_7 => FB_RXD_2_7,
  FB_RXD_2_6 => FB_RXD_2_6,
  FB_RXD_2_5 => FB_RXD_2_5,
  FB_RXD_2_4 => FB_RXD_2_4,
  FB_RXD_2_3 => FB_RXD_2_3,
  FB_RXD_2_2 => FB_RXD_2_2,
  FB_RXD_2_1 => FB_RXD_2_1,
  FB_RXD_2_0 => FB_RXD_2_0,
  FF_TXD_3_23 => FF_TXD_3_23,
  FF_TXD_3_22 => FF_TXD_3_22,
  FF_TXD_3_21 => FF_TXD_3_21,
  FF_TXD_3_20 => FF_TXD_3_20,
  FF_TXD_3_19 => FF_TXD_3_19,
  FF_TXD_3_18 => FF_TXD_3_18,
  FF_TXD_3_17 => FF_TXD_3_17,
  FF_TXD_3_16 => FF_TXD_3_16,
  FF_TXD_3_15 => FF_TXD_3_15,
  FF_TXD_3_14 => FF_TXD_3_14,
  FF_TXD_3_13 => FF_TXD_3_13,
  FF_TXD_3_12 => FF_TXD_3_12,
  FF_TXD_3_11 => FF_TXD_3_11,
  FF_TXD_3_10 => FF_TXD_3_10,
  FF_TXD_3_9 => FF_TXD_3_9,
  FF_TXD_3_8 => FF_TXD_3_8,
  FF_TXD_3_7 => FF_TXD_3_7,
  FF_TXD_3_6 => FF_TXD_3_6,
  FF_TXD_3_5 => FF_TXD_3_5,
  FF_TXD_3_4 => FF_TXD_3_4,
  FF_TXD_3_3 => FF_TXD_3_3,
  FF_TXD_3_2 => FF_TXD_3_2,
  FF_TXD_3_1 => FF_TXD_3_1,
  FF_TXD_3_0 => FF_TXD_3_0,
  FB_RXD_3_23 => FB_RXD_3_23,
  FB_RXD_3_22 => FB_RXD_3_22,
  FB_RXD_3_21 => FB_RXD_3_21,
  FB_RXD_3_20 => FB_RXD_3_20,
  FB_RXD_3_19 => FB_RXD_3_19,
  FB_RXD_3_18 => FB_RXD_3_18,
  FB_RXD_3_17 => FB_RXD_3_17,
  FB_RXD_3_16 => FB_RXD_3_16,
  FB_RXD_3_15 => FB_RXD_3_15,
  FB_RXD_3_14 => FB_RXD_3_14,
  FB_RXD_3_13 => FB_RXD_3_13,
  FB_RXD_3_12 => FB_RXD_3_12,
  FB_RXD_3_11 => FB_RXD_3_11,
  FB_RXD_3_10 => FB_RXD_3_10,
  FB_RXD_3_9 => FB_RXD_3_9,
  FB_RXD_3_8 => FB_RXD_3_8,
  FB_RXD_3_7 => FB_RXD_3_7,
  FB_RXD_3_6 => FB_RXD_3_6,
  FB_RXD_3_5 => FB_RXD_3_5,
  FB_RXD_3_4 => FB_RXD_3_4,
  FB_RXD_3_3 => FB_RXD_3_3,
  FB_RXD_3_2 => FB_RXD_3_2,
  FB_RXD_3_1 => FB_RXD_3_1,
  FB_RXD_3_0 => FB_RXD_3_0,
  TCK_FMAC => TCK_FMAC,
  COUT_21 => COUT_21,
  COUT_20 => COUT_20,
  COUT_19 => COUT_19,
  COUT_18 => COUT_18,
  COUT_17 => COUT_17,
  COUT_16 => COUT_16,
  COUT_15 => COUT_15,
  COUT_14 => COUT_14,
  COUT_13 => COUT_13,
  COUT_12 => COUT_12,
  COUT_11 => COUT_11,
  COUT_10 => COUT_10,
  COUT_9 => COUT_9,
  COUT_8 => COUT_8,
  COUT_7 => COUT_7,
  COUT_6 => COUT_6,
  COUT_5 => COUT_5,
  COUT_4 => COUT_4,
  COUT_3 => COUT_3,
  COUT_2 => COUT_2,
  COUT_1 => COUT_1,
  COUT_0 => COUT_0,
  CIN_12 => CIN_12,
  CIN_11 => CIN_11,
  CIN_10 => CIN_10,
  CIN_9 => CIN_9,
  CIN_8 => CIN_8,
  CIN_7 => CIN_7,
  CIN_6 => CIN_6,
  CIN_5 => CIN_5,
  CIN_4 => CIN_4,
  CIN_3 => CIN_3,
  CIN_2 => CIN_2,
  CIN_1 => CIN_1,
  CIN_0 => CIN_0,
  TESTCLK_MACO => TESTCLK_MACO
);

end PCSA_arch;

--synopsys translate_on

--synopsys translate_off
library SC;
use SC.components.all;
--synopsys translate_on

library IEEE, STD;
use IEEE.std_logic_1164.all;
use STD.TEXTIO.all;


entity serdes_fpga_ref_clk is
   GENERIC (USER_CONFIG_FILE    :  String := "serdes_fpga_ref_clk.txt");
 port (
-- serdes clk pins --
  rxrefclk, refclk : in std_logic;
  rxa_pclk, rxb_pclk : out std_logic;
  hdinp_0, hdinn_0 : in std_logic;
  hdoutp_0, hdoutn_0 : out std_logic;
  tclk_0, rclk_0 : in std_logic;
  tx_rst_0, rx_rst_0 : in std_logic;
  ref_0_sclk, rx_0_sclk : out std_logic;
  txd_0 : in std_logic_vector (15 downto 0);
  tx_k_0, tx_force_disp_0, tx_disp_sel_0 : in std_logic_vector (1 downto 0);
  rxd_0 : out std_logic_vector (15 downto 0);
  rx_k_0, rx_disp_err_detect_0, rx_cv_detect_0 : out std_logic_vector (1 downto 0);
  tx_crc_init_0 : in std_logic_vector (1 downto 0);
  rx_crc_eop_0 : out std_logic_vector (1 downto 0);
  word_align_en_0, mca_align_en_0, felb_0 : in std_logic;
  lsm_en_0  : in std_logic;
  lsm_status_0  : out std_logic;

  hdinp_1, hdinn_1 : in std_logic;
  hdoutp_1, hdoutn_1 : out std_logic;
  tclk_1, rclk_1 : in std_logic;
  tx_rst_1, rx_rst_1 : in std_logic;
  ref_1_sclk, rx_1_sclk : out std_logic;
  txd_1 : in std_logic_vector (15 downto 0);
  tx_k_1, tx_force_disp_1, tx_disp_sel_1 : in std_logic_vector (1 downto 0);
  rxd_1 : out std_logic_vector (15 downto 0);
  rx_k_1, rx_disp_err_detect_1, rx_cv_detect_1 : out std_logic_vector (1 downto 0);
  tx_crc_init_1 : in std_logic_vector (1 downto 0);
  rx_crc_eop_1 : out std_logic_vector (1 downto 0);
  word_align_en_1, mca_align_en_1, felb_1 : in std_logic;
  lsm_en_1  : in std_logic;
  lsm_status_1  : out std_logic;

  hdinp_2, hdinn_2 : in std_logic;
  hdoutp_2, hdoutn_2 : out std_logic;
  tclk_2, rclk_2 : in std_logic;
  tx_rst_2, rx_rst_2 : in std_logic;
  ref_2_sclk, rx_2_sclk : out std_logic;
  txd_2 : in std_logic_vector (15 downto 0);
  tx_k_2, tx_force_disp_2, tx_disp_sel_2 : in std_logic_vector (1 downto 0);
  rxd_2 : out std_logic_vector (15 downto 0);
  rx_k_2, rx_disp_err_detect_2, rx_cv_detect_2 : out std_logic_vector (1 downto 0);
  tx_crc_init_2 : in std_logic_vector (1 downto 0);
  rx_crc_eop_2 : out std_logic_vector (1 downto 0);
  word_align_en_2, mca_align_en_2, felb_2 : in std_logic;
  lsm_en_2  : in std_logic;
  lsm_status_2  : out std_logic;

  hdinp_3, hdinn_3 : in std_logic;
  hdoutp_3, hdoutn_3 : out std_logic;
  tclk_3, rclk_3 : in std_logic;
  tx_rst_3, rx_rst_3 : in std_logic;
  ref_3_sclk, rx_3_sclk : out std_logic;
  txd_3 : in std_logic_vector (15 downto 0);
  tx_k_3, tx_force_disp_3, tx_disp_sel_3 : in std_logic_vector (1 downto 0);
  rxd_3 : out std_logic_vector (15 downto 0);
  rx_k_3, rx_disp_err_detect_3, rx_cv_detect_3 : out std_logic_vector (1 downto 0);
  tx_crc_init_3 : in std_logic_vector (1 downto 0);
  rx_crc_eop_3 : out std_logic_vector (1 downto 0);
  word_align_en_3, mca_align_en_3, felb_3 : in std_logic;
  lsm_en_3  : in std_logic;
  lsm_status_3  : out std_logic;
  mca_resync_01 : in std_logic;
  mca_aligned_01, mca_inskew_01, mca_outskew_01 : out std_logic;
  mca_resync_23 : in std_logic;
  mca_aligned_23, mca_inskew_23, mca_outskew_23 : out std_logic;
  quad_rst, serdes_rst : in std_logic;
  ref_pclk : out std_logic);

end serdes_fpga_ref_clk;

architecture serdes_fpga_ref_clk_arch of serdes_fpga_ref_clk is

component VLO
port (
   Z : out std_logic);
end component;

component VHI
port (
   Z : out std_logic);
end component;

component PCSA
--synopsys translate_off
GENERIC(
  CONFIG_FILE : String
  );
--synopsys translate_on
port (
  HDINP0            : in std_logic;
  HDINN0            : in std_logic;
  HDINP1            : in std_logic;
  HDINN1            : in std_logic;
  HDINP2            : in std_logic;
  HDINN2            : in std_logic;
  HDINP3            : in std_logic;
  HDINN3            : in std_logic;
  HDOUTP0           : out std_logic;
  HDOUTN0           : out std_logic;
  HDOUTP1           : out std_logic;
  HDOUTN1           : out std_logic;
  HDOUTP2           : out std_logic;
  HDOUTN2           : out std_logic;
  HDOUTP3           : out std_logic;
  HDOUTN3           : out std_logic;
  REFCLKP           : in std_logic;
  REFCLKN           : in std_logic;
  RXREFCLKP         : in std_logic;
  RXREFCLKN         : in std_logic;
  FFC_QUAD_RST      : in std_logic;
  FFC_MACRO_RST     : in std_logic;

  FFC_LANE_TX_RST0  : in std_logic;
  FFC_LANE_TX_RST1  : in std_logic;
  FFC_LANE_TX_RST2  : in std_logic;
  FFC_LANE_TX_RST3  : in std_logic;

  FFC_LANE_RX_RST0  : in std_logic;
  FFC_LANE_RX_RST1  : in std_logic;
  FFC_LANE_RX_RST2  : in std_logic;
  FFC_LANE_RX_RST3  : in std_logic;

  FFC_PCIE_EI_EN_0  : in std_logic;
  FFC_PCIE_EI_EN_1  : in std_logic;
  FFC_PCIE_EI_EN_2  : in std_logic;
  FFC_PCIE_EI_EN_3  : in std_logic;

  FFC_PCIE_CT_0     : in std_logic;
  FFC_PCIE_CT_1     : in std_logic;
  FFC_PCIE_CT_2     : in std_logic;
  FFC_PCIE_CT_3     : in std_logic;

  FFS_PCIE_CON_0    : out std_logic;
  FFS_PCIE_CON_1    : out std_logic;
  FFS_PCIE_CON_2    : out std_logic;
  FFS_PCIE_CON_3    : out std_logic;

  FFS_PCIE_DONE_0   : out std_logic;
  FFS_PCIE_DONE_1   : out std_logic;
  FFS_PCIE_DONE_2   : out std_logic;
  FFS_PCIE_DONE_3   : out std_logic;

  FFC_PCIE_TX_0     : in std_logic;
  FFC_PCIE_TX_1     : in std_logic;
  FFC_PCIE_TX_2     : in std_logic;
  FFC_PCIE_TX_3     : in std_logic;

  FFC_PCIE_RX_0     : in std_logic;
  FFC_PCIE_RX_1     : in std_logic;
  FFC_PCIE_RX_2     : in std_logic;
  FFC_PCIE_RX_3     : in std_logic;

  FFC_SD_0          : in std_logic;
  FFC_SD_1          : in std_logic;
  FFC_SD_2          : in std_logic;
  FFC_SD_3          : in std_logic;

  FFC_EN_CGA_0      : in std_logic;
  FFC_EN_CGA_1      : in std_logic;
  FFC_EN_CGA_2      : in std_logic;
  FFC_EN_CGA_3      : in std_logic;

  FFC_ALIGN_EN_0    : in std_logic;
  FFC_ALIGN_EN_1    : in std_logic;
  FFC_ALIGN_EN_2    : in std_logic;
  FFC_ALIGN_EN_3    : in std_logic;

  FFC_AB_RESET      : in std_logic;
  FFC_CD_RESET      : in std_logic;

  FFS_LS_STATUS_0   : out std_logic;
  FFS_LS_STATUS_1   : out std_logic;
  FFS_LS_STATUS_2   : out std_logic;
  FFS_LS_STATUS_3   : out std_logic;

  FFS_AB_STATUS     : out std_logic;
  FFS_CD_STATUS     : out std_logic;

  FFS_AB_ALIGNED    : out std_logic;
  FFS_CD_ALIGNED    : out std_logic;

  FFS_AB_FAILED     : out std_logic;
  FFS_CD_FAILED     : out std_logic;

  FFS_RLOS_LO0      : out std_logic;
  FFS_RLOS_LO1      : out std_logic;
  FFS_RLOS_LO2      : out std_logic;
  FFS_RLOS_LO3      : out std_logic;

  FFC_FB_LB_0       : in std_logic;
  FFC_FB_LB_1       : in std_logic;
  FFC_FB_LB_2       : in std_logic;
  FFC_FB_LB_3       : in std_logic;

  FFC_SB_INV_RX_0   : in std_logic;
  FFC_SB_INV_RX_1   : in std_logic;
  FFC_SB_INV_RX_2   : in std_logic;
  FFC_SB_INV_RX_3   : in std_logic;

  FFS_CC_ORUN_0     : out std_logic;
  FFS_CC_ORUN_1     : out std_logic;
  FFS_CC_ORUN_2     : out std_logic;
  FFS_CC_ORUN_3     : out std_logic;

  FFS_CC_URUN_0     : out std_logic;
  FFS_CC_URUN_1     : out std_logic;
  FFS_CC_URUN_2     : out std_logic;
  FFS_CC_URUN_3     : out std_logic;

  FFC_CK_CORE_TX    : in std_logic;
  FFC_CK_CORE_RX    : in std_logic;
  RDATAO_7          : out std_logic;
  RDATAO_6          : out std_logic;
  RDATAO_5          : out std_logic;
  RDATAO_4          : out std_logic;
  RDATAO_3          : out std_logic;
  RDATAO_2          : out std_logic;
  RDATAO_1          : out std_logic;
  RDATAO_0          : out std_logic;
  INTO              : out std_logic;

  ADDRI_7           : in std_logic;
  ADDRI_6           : in std_logic;
  ADDRI_5           : in std_logic;
  ADDRI_4           : in std_logic;
  ADDRI_3           : in std_logic;
  ADDRI_2           : in std_logic;
  ADDRI_1           : in std_logic;
  ADDRI_0           : in std_logic;
  WDATAI_7          : in std_logic;
  WDATAI_6          : in std_logic;
  WDATAI_5          : in std_logic;
  WDATAI_4          : in std_logic;
  WDATAI_3          : in std_logic;
  WDATAI_2          : in std_logic;
  WDATAI_1          : in std_logic;
  WDATAI_0          : in std_logic;
  RDI               : in std_logic;
  WSTBI             : in std_logic;

  CS_CHIF_0         : in std_logic;
  CS_CHIF_1         : in std_logic;
  CS_CHIF_2         : in std_logic;
  CS_CHIF_3         : in std_logic;
  CS_QIF            : in std_logic;

  QUAD_ID_1         : in std_logic;
  QUAD_ID_0         : in std_logic;

  FF_SYSCLK_P1      : out std_logic;

  FF_SYSCLK0        : out std_logic;
  FF_SYSCLK1        : out std_logic;
  FF_SYSCLK2        : out std_logic;
  FF_SYSCLK3        : out std_logic;

  FF_RXCLK_P1       : out std_logic;
  FF_RXCLK_P2       : out std_logic;

  FF_RXCLK0         : out std_logic;
  FF_RXCLK1         : out std_logic;
  FF_RXCLK2         : out std_logic;
  FF_RXCLK3         : out std_logic;

  QUAD_CLK          : out std_logic;

  GRP_CLK_P1_3      : in std_logic;
  GRP_CLK_P1_2      : in std_logic;
  GRP_CLK_P1_1      : in std_logic;
  GRP_CLK_P1_0      : in std_logic;

  GRP_CLK_P2_3      : in std_logic;
  GRP_CLK_P2_2      : in std_logic;
  GRP_CLK_P2_1      : in std_logic;
  GRP_CLK_P2_0      : in std_logic;

  GRP_START_3      : in std_logic;
  GRP_START_2      : in std_logic;
  GRP_START_1      : in std_logic;
  GRP_START_0      : in std_logic;

  GRP_DONE_3      : in std_logic;
  GRP_DONE_2      : in std_logic;
  GRP_DONE_1      : in std_logic;
  GRP_DONE_0      : in std_logic;

  GRP_DESKEW_ERROR_3      : in std_logic;
  GRP_DESKEW_ERROR_2      : in std_logic;
  GRP_DESKEW_ERROR_1      : in std_logic;
  GRP_DESKEW_ERROR_0      : in std_logic;

  IQA_START_LS      : out std_logic;
  IQA_DONE_LS       : out std_logic;
  IQA_AND_FP1_LS    : out std_logic;
  IQA_AND_FP0_LS    : out std_logic;
  IQA_OR_FP1_LS     : out std_logic;
  IQA_OR_FP0_LS     : out std_logic;
  IQA_RST_N         : out std_logic;

  FF_TCLK0          : in std_logic;
  FF_TCLK1          : in std_logic;
  FF_TCLK2          : in std_logic;
  FF_TCLK3          : in std_logic;

  FF_RCLK0          : in std_logic;
  FF_RCLK1          : in std_logic;
  FF_RCLK2          : in std_logic;
  FF_RCLK3          : in std_logic;
  TCK_FMACP         : in std_logic;

  FF_TXD_0_23       : in std_logic;
  FF_TXD_0_22       : in std_logic;
  FF_TXD_0_21       : in std_logic;
  FF_TXD_0_20       : in std_logic;
  FF_TXD_0_19       : in std_logic;
  FF_TXD_0_18       : in std_logic;
  FF_TXD_0_17       : in std_logic;
  FF_TXD_0_16       : in std_logic;
  FF_TXD_0_15       : in std_logic;
  FF_TXD_0_14       : in std_logic;
  FF_TXD_0_13       : in std_logic;
  FF_TXD_0_12       : in std_logic;
  FF_TXD_0_11       : in std_logic;
  FF_TXD_0_10       : in std_logic;
  FF_TXD_0_9       : in std_logic;
  FF_TXD_0_8       : in std_logic;
  FF_TXD_0_7       : in std_logic;
  FF_TXD_0_6       : in std_logic;
  FF_TXD_0_5       : in std_logic;
  FF_TXD_0_4       : in std_logic;
  FF_TXD_0_3       : in std_logic;
  FF_TXD_0_2       : in std_logic;
  FF_TXD_0_1       : in std_logic;
  FF_TXD_0_0       : in std_logic;
  FB_RXD_0_23       : out std_logic;
  FB_RXD_0_22       : out std_logic;
  FB_RXD_0_21       : out std_logic;
  FB_RXD_0_20       : out std_logic;
  FB_RXD_0_19       : out std_logic;
  FB_RXD_0_18       : out std_logic;
  FB_RXD_0_17       : out std_logic;
  FB_RXD_0_16       : out std_logic;
  FB_RXD_0_15       : out std_logic;
  FB_RXD_0_14       : out std_logic;
  FB_RXD_0_13       : out std_logic;
  FB_RXD_0_12       : out std_logic;
  FB_RXD_0_11       : out std_logic;
  FB_RXD_0_10       : out std_logic;
  FB_RXD_0_9       : out std_logic;
  FB_RXD_0_8       : out std_logic;
  FB_RXD_0_7       : out std_logic;
  FB_RXD_0_6       : out std_logic;
  FB_RXD_0_5       : out std_logic;
  FB_RXD_0_4       : out std_logic;
  FB_RXD_0_3       : out std_logic;
  FB_RXD_0_2       : out std_logic;
  FB_RXD_0_1       : out std_logic;
  FB_RXD_0_0       : out std_logic;
  FF_TXD_1_23       : in std_logic;
  FF_TXD_1_22       : in std_logic;
  FF_TXD_1_21       : in std_logic;
  FF_TXD_1_20       : in std_logic;
  FF_TXD_1_19       : in std_logic;
  FF_TXD_1_18       : in std_logic;
  FF_TXD_1_17       : in std_logic;
  FF_TXD_1_16       : in std_logic;
  FF_TXD_1_15       : in std_logic;
  FF_TXD_1_14       : in std_logic;
  FF_TXD_1_13       : in std_logic;
  FF_TXD_1_12       : in std_logic;
  FF_TXD_1_11       : in std_logic;
  FF_TXD_1_10       : in std_logic;
  FF_TXD_1_9       : in std_logic;
  FF_TXD_1_8       : in std_logic;
  FF_TXD_1_7       : in std_logic;
  FF_TXD_1_6       : in std_logic;
  FF_TXD_1_5       : in std_logic;
  FF_TXD_1_4       : in std_logic;
  FF_TXD_1_3       : in std_logic;
  FF_TXD_1_2       : in std_logic;
  FF_TXD_1_1       : in std_logic;
  FF_TXD_1_0       : in std_logic;
  FB_RXD_1_23       : out std_logic;
  FB_RXD_1_22       : out std_logic;
  FB_RXD_1_21       : out std_logic;
  FB_RXD_1_20       : out std_logic;
  FB_RXD_1_19       : out std_logic;
  FB_RXD_1_18       : out std_logic;
  FB_RXD_1_17       : out std_logic;
  FB_RXD_1_16       : out std_logic;
  FB_RXD_1_15       : out std_logic;
  FB_RXD_1_14       : out std_logic;
  FB_RXD_1_13       : out std_logic;
  FB_RXD_1_12       : out std_logic;
  FB_RXD_1_11       : out std_logic;
  FB_RXD_1_10       : out std_logic;
  FB_RXD_1_9       : out std_logic;
  FB_RXD_1_8       : out std_logic;
  FB_RXD_1_7       : out std_logic;
  FB_RXD_1_6       : out std_logic;
  FB_RXD_1_5       : out std_logic;
  FB_RXD_1_4       : out std_logic;
  FB_RXD_1_3       : out std_logic;
  FB_RXD_1_2       : out std_logic;
  FB_RXD_1_1       : out std_logic;
  FB_RXD_1_0       : out std_logic;
  FF_TXD_2_23       : in std_logic;
  FF_TXD_2_22       : in std_logic;
  FF_TXD_2_21       : in std_logic;
  FF_TXD_2_20       : in std_logic;
  FF_TXD_2_19       : in std_logic;
  FF_TXD_2_18       : in std_logic;
  FF_TXD_2_17       : in std_logic;
  FF_TXD_2_16       : in std_logic;
  FF_TXD_2_15       : in std_logic;
  FF_TXD_2_14       : in std_logic;
  FF_TXD_2_13       : in std_logic;
  FF_TXD_2_12       : in std_logic;
  FF_TXD_2_11       : in std_logic;
  FF_TXD_2_10       : in std_logic;
  FF_TXD_2_9       : in std_logic;
  FF_TXD_2_8       : in std_logic;
  FF_TXD_2_7       : in std_logic;
  FF_TXD_2_6       : in std_logic;
  FF_TXD_2_5       : in std_logic;
  FF_TXD_2_4       : in std_logic;
  FF_TXD_2_3       : in std_logic;
  FF_TXD_2_2       : in std_logic;
  FF_TXD_2_1       : in std_logic;
  FF_TXD_2_0       : in std_logic;
  FB_RXD_2_23       : out std_logic;
  FB_RXD_2_22       : out std_logic;
  FB_RXD_2_21       : out std_logic;
  FB_RXD_2_20       : out std_logic;
  FB_RXD_2_19       : out std_logic;
  FB_RXD_2_18       : out std_logic;
  FB_RXD_2_17       : out std_logic;
  FB_RXD_2_16       : out std_logic;
  FB_RXD_2_15       : out std_logic;
  FB_RXD_2_14       : out std_logic;
  FB_RXD_2_13       : out std_logic;
  FB_RXD_2_12       : out std_logic;
  FB_RXD_2_11       : out std_logic;
  FB_RXD_2_10       : out std_logic;
  FB_RXD_2_9       : out std_logic;
  FB_RXD_2_8       : out std_logic;
  FB_RXD_2_7       : out std_logic;
  FB_RXD_2_6       : out std_logic;
  FB_RXD_2_5       : out std_logic;
  FB_RXD_2_4       : out std_logic;
  FB_RXD_2_3       : out std_logic;
  FB_RXD_2_2       : out std_logic;
  FB_RXD_2_1       : out std_logic;
  FB_RXD_2_0       : out std_logic;
  FF_TXD_3_23       : in std_logic;
  FF_TXD_3_22       : in std_logic;
  FF_TXD_3_21       : in std_logic;
  FF_TXD_3_20       : in std_logic;
  FF_TXD_3_19       : in std_logic;
  FF_TXD_3_18       : in std_logic;
  FF_TXD_3_17       : in std_logic;
  FF_TXD_3_16       : in std_logic;
  FF_TXD_3_15       : in std_logic;
  FF_TXD_3_14       : in std_logic;
  FF_TXD_3_13       : in std_logic;
  FF_TXD_3_12       : in std_logic;
  FF_TXD_3_11       : in std_logic;
  FF_TXD_3_10       : in std_logic;
  FF_TXD_3_9       : in std_logic;
  FF_TXD_3_8       : in std_logic;
  FF_TXD_3_7       : in std_logic;
  FF_TXD_3_6       : in std_logic;
  FF_TXD_3_5       : in std_logic;
  FF_TXD_3_4       : in std_logic;
  FF_TXD_3_3       : in std_logic;
  FF_TXD_3_2       : in std_logic;
  FF_TXD_3_1       : in std_logic;
  FF_TXD_3_0       : in std_logic;
  FB_RXD_3_23       : out std_logic;
  FB_RXD_3_22       : out std_logic;
  FB_RXD_3_21       : out std_logic;
  FB_RXD_3_20       : out std_logic;
  FB_RXD_3_19       : out std_logic;
  FB_RXD_3_18       : out std_logic;
  FB_RXD_3_17       : out std_logic;
  FB_RXD_3_16       : out std_logic;
  FB_RXD_3_15       : out std_logic;
  FB_RXD_3_14       : out std_logic;
  FB_RXD_3_13       : out std_logic;
  FB_RXD_3_12       : out std_logic;
  FB_RXD_3_11       : out std_logic;
  FB_RXD_3_10       : out std_logic;
  FB_RXD_3_9       : out std_logic;
  FB_RXD_3_8       : out std_logic;
  FB_RXD_3_7       : out std_logic;
  FB_RXD_3_6       : out std_logic;
  FB_RXD_3_5       : out std_logic;
  FB_RXD_3_4       : out std_logic;
  FB_RXD_3_3       : out std_logic;
  FB_RXD_3_2       : out std_logic;
  FB_RXD_3_1       : out std_logic;
  FB_RXD_3_0       : out std_logic;
  TCK_FMAC         : out std_logic;
  BS4PAD_0         : out std_logic;
  BS4PAD_1         : out std_logic;
  BS4PAD_2         : out std_logic;
  BS4PAD_3         : out std_logic;
  COUT_21          : out std_logic;
  COUT_20          : out std_logic;
  COUT_19          : out std_logic;
  COUT_18          : out std_logic;
  COUT_17          : out std_logic;
  COUT_16          : out std_logic;
  COUT_15          : out std_logic;
  COUT_14          : out std_logic;
  COUT_13          : out std_logic;
  COUT_12          : out std_logic;
  COUT_11          : out std_logic;
  COUT_10          : out std_logic;
  COUT_9           : out std_logic;
  COUT_8           : out std_logic;
  COUT_7           : out std_logic;
  COUT_6           : out std_logic;
  COUT_5           : out std_logic;
  COUT_4           : out std_logic;
  COUT_3           : out std_logic;
  COUT_2           : out std_logic;
  COUT_1           : out std_logic;
  COUT_0           : out std_logic;
  CIN_12          : in std_logic;
  CIN_11          : in std_logic;
  CIN_10          : in std_logic;
  CIN_9           : in std_logic;
  CIN_8           : in std_logic;
  CIN_7           : in std_logic;
  CIN_6           : in std_logic;
  CIN_5           : in std_logic;
  CIN_4           : in std_logic;
  CIN_3           : in std_logic;
  CIN_2           : in std_logic;
  CIN_1           : in std_logic;
  CIN_0           : in std_logic;
  TESTCLK_MACO     : in std_logic
);
end component;
   attribute IS_ASB: string;
   attribute IS_ASB of PCSA_INST : label is "or5s00/data/or5s00.acd";
   attribute CONFIG_FILE: string;
   attribute CONFIG_FILE of PCSA_INST : label is USER_CONFIG_FILE;
   attribute CH0_RX_MAXRATE: string;
   attribute CH0_RX_MAXRATE of PCSA_INST : label is "RXF3";
   attribute CH1_RX_MAXRATE: string;
   attribute CH1_RX_MAXRATE of PCSA_INST : label is "RXF3";
   attribute CH2_RX_MAXRATE: string;
   attribute CH2_RX_MAXRATE of PCSA_INST : label is "RXF3";
   attribute CH3_RX_MAXRATE: string;
   attribute CH3_RX_MAXRATE of PCSA_INST : label is "RXF3";
   attribute CH0_TX_MAXRATE: string;
   attribute CH0_TX_MAXRATE of PCSA_INST : label is "TXF2";
   attribute CH1_TX_MAXRATE: string;
   attribute CH1_TX_MAXRATE of PCSA_INST : label is "TXF2";
   attribute CH2_TX_MAXRATE: string;
   attribute CH2_TX_MAXRATE of PCSA_INST : label is "TXF2";
   attribute CH3_TX_MAXRATE: string;
   attribute CH3_TX_MAXRATE of PCSA_INST : label is "TXF2";
   attribute AMP_BOOST: string;
   attribute AMP_BOOST of PCSA_INST : label is "DISABLED";
   attribute black_box_pad_pin: string;
   attribute black_box_pad_pin of PCSA : component is "HDINP0, HDINN0, HDINP1, HDINN1, HDINP2, HDINN2, HDINP3, HDINN3, HDOUTP0, HDOUTN0, HDOUTP1, HDOUTN1, HDOUTP2, HDOUTN2, HDOUTP3, HDOUTN3, REFCLKP, REFCLKN, RXREFCLKP, RXREFCLKN";

signal fpsc_vlo : std_logic := '0';

begin

vlo_inst : VLO port map(Z => fpsc_vlo);

-- pcs_quad instance
PCSA_INST : PCSA
--synopsys translate_off
  generic map (CONFIG_FILE => USER_CONFIG_FILE)
--synopsys translate_on
port map  ( 
  REFCLKP => fpsc_vlo,
  REFCLKN => fpsc_vlo,
  RXREFCLKP => fpsc_vlo,
  RXREFCLKN => fpsc_vlo,
  FFC_CK_CORE_RX => rxrefclk,
  FFC_CK_CORE_TX => refclk,
  CS_CHIF_0 => fpsc_vlo,
  CS_CHIF_1 => fpsc_vlo,
  CS_CHIF_2 => fpsc_vlo,
  CS_CHIF_3 => fpsc_vlo,
  CS_QIF => fpsc_vlo,
  QUAD_ID_0 => fpsc_vlo,
  QUAD_ID_1 => fpsc_vlo,
  ADDRI_0 => fpsc_vlo,
  ADDRI_1 => fpsc_vlo,
  ADDRI_2 => fpsc_vlo,
  ADDRI_3 => fpsc_vlo,
  ADDRI_4 => fpsc_vlo,
  ADDRI_5 => fpsc_vlo,
  ADDRI_6 => fpsc_vlo,
  ADDRI_7 => fpsc_vlo,
  WDATAI_0 => fpsc_vlo,
  WDATAI_1 => fpsc_vlo,
  WDATAI_2 => fpsc_vlo,
  WDATAI_3 => fpsc_vlo,
  WDATAI_4 => fpsc_vlo,
  WDATAI_5 => fpsc_vlo,
  WDATAI_6 => fpsc_vlo,
  WDATAI_7 => fpsc_vlo,
  RDI => fpsc_vlo,
  WSTBI => fpsc_vlo,
  GRP_CLK_P1_0 => fpsc_vlo,
  GRP_CLK_P1_1 => fpsc_vlo,
  GRP_CLK_P1_2 => fpsc_vlo,
  GRP_CLK_P1_3 => fpsc_vlo,
  GRP_CLK_P2_0 => fpsc_vlo,
  GRP_CLK_P2_1 => fpsc_vlo,
  GRP_CLK_P2_2 => fpsc_vlo,
  GRP_CLK_P2_3 => fpsc_vlo,
  GRP_START_0 => fpsc_vlo,
  GRP_START_1 => fpsc_vlo,
  GRP_START_2 => fpsc_vlo,
  GRP_START_3 => fpsc_vlo,
  GRP_DONE_0 => fpsc_vlo,
  GRP_DONE_1 => fpsc_vlo,
  GRP_DONE_2 => fpsc_vlo,
  GRP_DONE_3 => fpsc_vlo,
  GRP_DESKEW_ERROR_0 => fpsc_vlo,
  GRP_DESKEW_ERROR_1 => fpsc_vlo,
  GRP_DESKEW_ERROR_2 => fpsc_vlo,
  GRP_DESKEW_ERROR_3 => fpsc_vlo,
-- to sysbusa
  RDATAO_0 => open,
  RDATAO_1 => open,
  RDATAO_2 => open,
  RDATAO_3 => open,
  RDATAO_4 => open,
  RDATAO_5 => open,
  RDATAO_6 => open,
  RDATAO_7 => open,
  INTO => open,
  QUAD_CLK => open,
  IQA_START_LS => open,
  IQA_DONE_LS => open,
  IQA_AND_FP1_LS => open,
  IQA_AND_FP0_LS => open,
  IQA_OR_FP1_LS => open,
  IQA_OR_FP0_LS => open,
  IQA_RST_N => open,

  FF_TXD_0_19 => txd_0(15),
  FF_TXD_0_18 => txd_0(14),
  FF_TXD_0_17 => txd_0(13),
  FF_TXD_0_16 => txd_0(12),
  FF_TXD_0_15 => txd_0(11),
  FF_TXD_0_14 => txd_0(10),
  FF_TXD_0_13 => txd_0(9),
  FF_TXD_0_12 => txd_0(8),
  FF_TXD_0_7 => txd_0(7),
  FF_TXD_0_6 => txd_0(6),
  FF_TXD_0_5 => txd_0(5),
  FF_TXD_0_4 => txd_0(4),
  FF_TXD_0_3 => txd_0(3),
  FF_TXD_0_2 => txd_0(2),
  FF_TXD_0_1 => txd_0(1),
  FF_TXD_0_0 => txd_0(0),
  FB_RXD_0_19 => rxd_0(15),
  FB_RXD_0_18 => rxd_0(14),
  FB_RXD_0_17 => rxd_0(13),
  FB_RXD_0_16 => rxd_0(12),
  FB_RXD_0_15 => rxd_0(11),
  FB_RXD_0_14 => rxd_0(10),
  FB_RXD_0_13 => rxd_0(9),
  FB_RXD_0_12 => rxd_0(8),
  FB_RXD_0_7 => rxd_0(7),
  FB_RXD_0_6 => rxd_0(6),
  FB_RXD_0_5 => rxd_0(5),
  FB_RXD_0_4 => rxd_0(4),
  FB_RXD_0_3 => rxd_0(3),
  FB_RXD_0_2 => rxd_0(2),
  FB_RXD_0_1 => rxd_0(1),
  FB_RXD_0_0 => rxd_0(0),

  FF_TXD_0_20 => tx_k_0(1),
  FF_TXD_0_8 => tx_k_0(0),
  FB_RXD_0_20 => rx_k_0(1),
  FB_RXD_0_8 => rx_k_0(0),

  FF_TXD_0_21 => tx_force_disp_0(1),
  FF_TXD_0_9 => tx_force_disp_0(0),

  FF_TXD_0_22 => tx_disp_sel_0(1),
  FF_TXD_0_10 => tx_disp_sel_0(0),

  FF_TXD_0_23 => tx_crc_init_0(1),
  FF_TXD_0_11 => tx_crc_init_0(0),

  FB_RXD_0_21 => rx_disp_err_detect_0(1),
  FB_RXD_0_9 => rx_disp_err_detect_0(0),

  FB_RXD_0_22 => rx_cv_detect_0(1),
  FB_RXD_0_10 => rx_cv_detect_0(0),

  FB_RXD_0_23 => rx_crc_eop_0(1),
  FB_RXD_0_11 => rx_crc_eop_0(0),

  FF_TXD_1_19 => txd_1(15),
  FF_TXD_1_18 => txd_1(14),
  FF_TXD_1_17 => txd_1(13),
  FF_TXD_1_16 => txd_1(12),
  FF_TXD_1_15 => txd_1(11),
  FF_TXD_1_14 => txd_1(10),
  FF_TXD_1_13 => txd_1(9),
  FF_TXD_1_12 => txd_1(8),
  FF_TXD_1_7 => txd_1(7),
  FF_TXD_1_6 => txd_1(6),
  FF_TXD_1_5 => txd_1(5),
  FF_TXD_1_4 => txd_1(4),
  FF_TXD_1_3 => txd_1(3),
  FF_TXD_1_2 => txd_1(2),
  FF_TXD_1_1 => txd_1(1),
  FF_TXD_1_0 => txd_1(0),
  FB_RXD_1_19 => rxd_1(15),
  FB_RXD_1_18 => rxd_1(14),
  FB_RXD_1_17 => rxd_1(13),
  FB_RXD_1_16 => rxd_1(12),
  FB_RXD_1_15 => rxd_1(11),
  FB_RXD_1_14 => rxd_1(10),
  FB_RXD_1_13 => rxd_1(9),
  FB_RXD_1_12 => rxd_1(8),
  FB_RXD_1_7 => rxd_1(7),
  FB_RXD_1_6 => rxd_1(6),
  FB_RXD_1_5 => rxd_1(5),
  FB_RXD_1_4 => rxd_1(4),
  FB_RXD_1_3 => rxd_1(3),
  FB_RXD_1_2 => rxd_1(2),
  FB_RXD_1_1 => rxd_1(1),
  FB_RXD_1_0 => rxd_1(0),

  FF_TXD_1_20 => tx_k_1(1),
  FF_TXD_1_8 => tx_k_1(0),
  FB_RXD_1_20 => rx_k_1(1),
  FB_RXD_1_8 => rx_k_1(0),

  FF_TXD_1_21 => tx_force_disp_1(1),
  FF_TXD_1_9 => tx_force_disp_1(0),

  FF_TXD_1_22 => tx_disp_sel_1(1),
  FF_TXD_1_10 => tx_disp_sel_1(0),
  FF_TXD_1_23 => tx_crc_init_1(1),
  FF_TXD_1_11 => tx_crc_init_1(0),

  FB_RXD_1_21 => rx_disp_err_detect_1(1),
  FB_RXD_1_9 => rx_disp_err_detect_1(0),

  FB_RXD_1_22 => rx_cv_detect_1(1),
  FB_RXD_1_10 => rx_cv_detect_1(0),

  FB_RXD_1_23 => rx_crc_eop_1(1),
  FB_RXD_1_11 => rx_crc_eop_1(0),

  FF_TXD_2_19 => txd_2(15),
  FF_TXD_2_18 => txd_2(14),
  FF_TXD_2_17 => txd_2(13),
  FF_TXD_2_16 => txd_2(12),
  FF_TXD_2_15 => txd_2(11),
  FF_TXD_2_14 => txd_2(10),
  FF_TXD_2_13 => txd_2(9),
  FF_TXD_2_12 => txd_2(8),
  FF_TXD_2_7 => txd_2(7),
  FF_TXD_2_6 => txd_2(6),
  FF_TXD_2_5 => txd_2(5),
  FF_TXD_2_4 => txd_2(4),
  FF_TXD_2_3 => txd_2(3),
  FF_TXD_2_2 => txd_2(2),
  FF_TXD_2_1 => txd_2(1),
  FF_TXD_2_0 => txd_2(0),
  FB_RXD_2_19 => rxd_2(15),
  FB_RXD_2_18 => rxd_2(14),
  FB_RXD_2_17 => rxd_2(13),
  FB_RXD_2_16 => rxd_2(12),
  FB_RXD_2_15 => rxd_2(11),
  FB_RXD_2_14 => rxd_2(10),
  FB_RXD_2_13 => rxd_2(9),
  FB_RXD_2_12 => rxd_2(8),
  FB_RXD_2_7 => rxd_2(7),
  FB_RXD_2_6 => rxd_2(6),
  FB_RXD_2_5 => rxd_2(5),
  FB_RXD_2_4 => rxd_2(4),
  FB_RXD_2_3 => rxd_2(3),
  FB_RXD_2_2 => rxd_2(2),
  FB_RXD_2_1 => rxd_2(1),
  FB_RXD_2_0 => rxd_2(0),

  FF_TXD_2_20 => tx_k_2(1),
  FF_TXD_2_8 => tx_k_2(0),
  FB_RXD_2_20 => rx_k_2(1),
  FB_RXD_2_8 => rx_k_2(0),

  FF_TXD_2_21 => tx_force_disp_2(1),
  FF_TXD_2_9 => tx_force_disp_2(0),

  FF_TXD_2_22 => tx_disp_sel_2(1),
  FF_TXD_2_10 => tx_disp_sel_2(0),
  FF_TXD_2_23 => tx_crc_init_2(1),
  FF_TXD_2_11 => tx_crc_init_2(0),

  FB_RXD_2_21 => rx_disp_err_detect_2(1),
  FB_RXD_2_9 => rx_disp_err_detect_2(0),

  FB_RXD_2_22 => rx_cv_detect_2(1),
  FB_RXD_2_10 => rx_cv_detect_2(0),

  FB_RXD_2_23 => rx_crc_eop_2(1),
  FB_RXD_2_11 => rx_crc_eop_2(0),

  FF_TXD_3_19 => txd_3(15),
  FF_TXD_3_18 => txd_3(14),
  FF_TXD_3_17 => txd_3(13),
  FF_TXD_3_16 => txd_3(12),
  FF_TXD_3_15 => txd_3(11),
  FF_TXD_3_14 => txd_3(10),
  FF_TXD_3_13 => txd_3(9),
  FF_TXD_3_12 => txd_3(8),
  FF_TXD_3_7 => txd_3(7),
  FF_TXD_3_6 => txd_3(6),
  FF_TXD_3_5 => txd_3(5),
  FF_TXD_3_4 => txd_3(4),
  FF_TXD_3_3 => txd_3(3),
  FF_TXD_3_2 => txd_3(2),
  FF_TXD_3_1 => txd_3(1),
  FF_TXD_3_0 => txd_3(0),
  FB_RXD_3_19 => rxd_3(15),
  FB_RXD_3_18 => rxd_3(14),
  FB_RXD_3_17 => rxd_3(13),
  FB_RXD_3_16 => rxd_3(12),
  FB_RXD_3_15 => rxd_3(11),
  FB_RXD_3_14 => rxd_3(10),
  FB_RXD_3_13 => rxd_3(9),
  FB_RXD_3_12 => rxd_3(8),
  FB_RXD_3_7 => rxd_3(7),
  FB_RXD_3_6 => rxd_3(6),
  FB_RXD_3_5 => rxd_3(5),
  FB_RXD_3_4 => rxd_3(4),
  FB_RXD_3_3 => rxd_3(3),
  FB_RXD_3_2 => rxd_3(2),
  FB_RXD_3_1 => rxd_3(1),
  FB_RXD_3_0 => rxd_3(0),

  FF_TXD_3_20 => tx_k_3(1),
  FF_TXD_3_8 => tx_k_3(0),
  FB_RXD_3_20 => rx_k_3(1),
  FB_RXD_3_8 => rx_k_3(0),

  FF_TXD_3_21 => tx_force_disp_3(1),
  FF_TXD_3_9 => tx_force_disp_3(0),

  FF_TXD_3_22 => tx_disp_sel_3(1),
  FF_TXD_3_10 => tx_disp_sel_3(0),
  FF_TXD_3_23 => tx_crc_init_3(1),
  FF_TXD_3_11 => tx_crc_init_3(0),

  FB_RXD_3_21 => rx_disp_err_detect_3(1),
  FB_RXD_3_9 => rx_disp_err_detect_3(0),

  FB_RXD_3_22 => rx_cv_detect_3(1),
  FB_RXD_3_10 => rx_cv_detect_3(0),

  FB_RXD_3_23 => rx_crc_eop_3(1),
  FB_RXD_3_11 => rx_crc_eop_3(0),

  HDINP0 => hdinp_0,
  HDINN0 => hdinn_0,
  HDOUTP0 => hdoutp_0,
  HDOUTN0 => hdoutn_0,
  FF_SYSCLK0 => ref_0_sclk,
  FF_RXCLK0 => rx_0_sclk,
  FFC_LANE_TX_RST0 => tx_rst_0,
  FFC_LANE_RX_RST0 => rx_rst_0,
  FF_TCLK0 => tclk_0,
  FF_RCLK0 => rclk_0,
  HDINP1 => hdinp_1,
  HDINN1 => hdinn_1,
  HDOUTP1 => hdoutp_1,
  HDOUTN1 => hdoutn_1,
  FF_SYSCLK1 => ref_1_sclk,
  FF_RXCLK1 => rx_1_sclk,
  FFC_LANE_TX_RST1 => tx_rst_1,
  FFC_LANE_RX_RST1 => rx_rst_1,
  FF_TCLK1 => tclk_1,
  FF_RCLK1 => rclk_1,
  HDINP2 => hdinp_2,
  HDINN2 => hdinn_2,
  HDOUTP2 => hdoutp_2,
  HDOUTN2 => hdoutn_2,
  FF_SYSCLK2 => ref_2_sclk,
  FF_RXCLK2 => rx_2_sclk,
  FFC_LANE_TX_RST2 => tx_rst_2,
  FFC_LANE_RX_RST2 => rx_rst_2,
  FF_TCLK2 => tclk_2,
  FF_RCLK2 => rclk_2,
  HDINP3 => hdinp_3,
  HDINN3 => hdinn_3,
  HDOUTP3 => hdoutp_3,
  HDOUTN3 => hdoutn_3,
  FF_SYSCLK3 => ref_3_sclk,
  FF_RXCLK3 => rx_3_sclk,
  FFC_LANE_TX_RST3 => tx_rst_3,
  FFC_LANE_RX_RST3 => rx_rst_3,
  FF_TCLK3 => tclk_3,
  FF_RCLK3 => rclk_3,

  FFC_PCIE_EI_EN_0 => fpsc_vlo,
  FFC_PCIE_CT_0 => fpsc_vlo,
  FFC_PCIE_TX_0 => fpsc_vlo,
  FFC_PCIE_RX_0 => fpsc_vlo,
  FFS_PCIE_CON_0 => open,
  FFS_PCIE_DONE_0 => open,
  FFC_PCIE_EI_EN_1 => fpsc_vlo,
  FFC_PCIE_CT_1 => fpsc_vlo,
  FFC_PCIE_TX_1 => fpsc_vlo,
  FFC_PCIE_RX_1 => fpsc_vlo,
  FFS_PCIE_CON_1 => open,
  FFS_PCIE_DONE_1 => open,
  FFC_PCIE_EI_EN_2 => fpsc_vlo,
  FFC_PCIE_CT_2 => fpsc_vlo,
  FFC_PCIE_TX_2 => fpsc_vlo,
  FFC_PCIE_RX_2 => fpsc_vlo,
  FFS_PCIE_CON_2 => open,
  FFS_PCIE_DONE_2 => open,
  FFC_PCIE_EI_EN_3 => fpsc_vlo,
  FFC_PCIE_CT_3 => fpsc_vlo,
  FFC_PCIE_TX_3 => fpsc_vlo,
  FFC_PCIE_RX_3 => fpsc_vlo,
  FFS_PCIE_CON_3 => open,
  FFS_PCIE_DONE_3 => open,

  FFC_SD_0 => lsm_en_0,
  FFC_SD_1 => lsm_en_1,
  FFC_SD_2 => lsm_en_2,
  FFC_SD_3 => lsm_en_3,

  FFC_EN_CGA_0 => word_align_en_0,
  FFC_EN_CGA_1 => word_align_en_1,
  FFC_EN_CGA_2 => word_align_en_2,
  FFC_EN_CGA_3 => word_align_en_3,

  FFC_ALIGN_EN_0 => mca_align_en_0,
  FFC_ALIGN_EN_1 => mca_align_en_1,
  FFC_ALIGN_EN_2 => mca_align_en_2,
  FFC_ALIGN_EN_3 => mca_align_en_3,

  FFC_FB_LB_0 => felb_0,
  FFC_FB_LB_1 => felb_1,
  FFC_FB_LB_2 => felb_2,
  FFC_FB_LB_3 => felb_3,

  FFS_LS_STATUS_0 => lsm_status_0,
  FFS_LS_STATUS_1 => lsm_status_1,
  FFS_LS_STATUS_2 => lsm_status_2,
  FFS_LS_STATUS_3 => lsm_status_3,

  FFS_CC_ORUN_0 => open,
  FFS_CC_URUN_0 => open,
  FFS_CC_ORUN_1 => open,
  FFS_CC_URUN_1 => open,
  FFS_CC_ORUN_2 => open,
  FFS_CC_URUN_2 => open,
  FFS_CC_ORUN_3 => open,
  FFS_CC_URUN_3 => open,

  FFC_AB_RESET => mca_resync_01,

  FFS_AB_STATUS => mca_aligned_01,
  FFS_AB_ALIGNED => mca_inskew_01,
  FFS_AB_FAILED => mca_outskew_01,

  FFC_CD_RESET => mca_resync_23,
  FFS_CD_STATUS => mca_aligned_23,

  FFS_CD_ALIGNED => mca_inskew_23,
  FFS_CD_FAILED => mca_outskew_23,
  BS4PAD_0 => open,
  BS4PAD_1 => open,
  BS4PAD_2 => open,
  BS4PAD_3 => open,
  FFC_SB_INV_RX_0 => fpsc_vlo,
  FFC_SB_INV_RX_1 => fpsc_vlo,
  FFC_SB_INV_RX_2 => fpsc_vlo,
  FFC_SB_INV_RX_3 => fpsc_vlo,
  TCK_FMAC => open,
  TCK_FMACP => fpsc_vlo,
  FF_SYSCLK_P1 => ref_pclk,
  FF_RXCLK_P1 => rxa_pclk,
  FF_RXCLK_P2 => rxb_pclk,
  FFC_QUAD_RST => quad_rst,
  FFS_RLOS_LO0 => open,
  FFS_RLOS_LO1 => open,
  FFS_RLOS_LO2 => open,
  FFS_RLOS_LO3 => open,
  COUT_21 => open,
  COUT_20 => open,
  COUT_19 => open,
  COUT_18 => open,
  COUT_17 => open,
  COUT_16 => open,
  COUT_15 => open,
  COUT_14 => open,
  COUT_13 => open,
  COUT_12 => open,
  COUT_11 => open,
  COUT_10 => open,
  COUT_9 => open,
  COUT_8 => open,
  COUT_7 => open,
  COUT_6 => open,
  COUT_5 => open,
  COUT_4 => open,
  COUT_3 => open,
  COUT_2 => open,
  COUT_1 => open,
  COUT_0 => open,
  CIN_12 => fpsc_vlo,
  CIN_11 => fpsc_vlo,
  CIN_10 => fpsc_vlo,
  CIN_9 => fpsc_vlo,
  CIN_8 => fpsc_vlo,
  CIN_7 => fpsc_vlo,
  CIN_6 => fpsc_vlo,
  CIN_5 => fpsc_vlo,
  CIN_4 => fpsc_vlo,
  CIN_3 => fpsc_vlo,
  CIN_2 => fpsc_vlo,
  CIN_1 => fpsc_vlo,
  CIN_0 => fpsc_vlo,
  TESTCLK_MACO => fpsc_vlo,
  FFC_MACRO_RST => serdes_rst);

--synopsys translate_off
file_read : PROCESS
VARIABLE open_status : file_open_status;
FILE config : text;
BEGIN
   file_open (open_status, config, USER_CONFIG_FILE, read_mode);
   IF (open_status = name_error) THEN
      report "Auto configuration file for PCS module not found.  PCS internal configuration registers will not be initialized correctly during simulation!"
      severity ERROR;
   END IF;
   wait;
END PROCESS;
--synopsys translate_on
  
end serdes_fpga_ref_clk_arch ;
