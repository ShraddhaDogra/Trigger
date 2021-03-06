
                                                                                                         

--synopsys translate_off

library pcsd_work;
use pcsd_work.all;
library IEEE;
use IEEE.std_logic_1164.all;

entity PCSD is
GENERIC(
  CONFIG_FILE : String;
  QUAD_MODE : String;
  CH0_CDR_SRC   : String := "REFCLK_EXT";
  CH1_CDR_SRC   : String := "REFCLK_EXT";
  CH2_CDR_SRC   : String := "REFCLK_EXT";
  CH3_CDR_SRC   : String := "REFCLK_EXT";
  PLL_SRC   : String
--  CONFIG_FILE : String  := "serdes_sync_4_slave3.txt";
--  QUAD_MODE : String := "SINGLE";
--  CH0_CDR_SRC   : String := "REFCLK_CORE";
--  CH1_CDR_SRC   : String := "REFCLK_CORE";
--  CH2_CDR_SRC   : String := "REFCLK_CORE";
--  CH3_CDR_SRC   : String := "REFCLK_CORE";
--  PLL_SRC   : String := "REFCLK_CORE"
  );
port (
  HDINN0             : in std_logic;
  HDINN1             : in std_logic;
  HDINN2             : in std_logic;
  HDINN3             : in std_logic;
  HDINP0             : in std_logic;
  HDINP1             : in std_logic;
  HDINP2             : in std_logic;
  HDINP3             : in std_logic;
  REFCLKN             : in std_logic;
  REFCLKP             : in std_logic;
  CIN0             : in std_logic;
  CIN1             : in std_logic;
  CIN2             : in std_logic;
  CIN3             : in std_logic;
  CIN4             : in std_logic;
  CIN5             : in std_logic;
  CIN6             : in std_logic;
  CIN7             : in std_logic;
  CIN8             : in std_logic;
  CIN9             : in std_logic;
  CIN10             : in std_logic;
  CIN11             : in std_logic;
  CYAWSTN             : in std_logic;
  FF_EBRD_CLK_0             : in std_logic;
  FF_EBRD_CLK_1             : in std_logic;
  FF_EBRD_CLK_2             : in std_logic;
  FF_EBRD_CLK_3             : in std_logic;
  FF_RXI_CLK_0             : in std_logic;
  FF_RXI_CLK_1             : in std_logic;
  FF_RXI_CLK_2             : in std_logic;
  FF_RXI_CLK_3             : in std_logic;
  FF_TX_D_0_0             : in std_logic;
  FF_TX_D_0_1             : in std_logic;
  FF_TX_D_0_2             : in std_logic;
  FF_TX_D_0_3             : in std_logic;
  FF_TX_D_0_4             : in std_logic;
  FF_TX_D_0_5             : in std_logic;
  FF_TX_D_0_6             : in std_logic;
  FF_TX_D_0_7             : in std_logic;
  FF_TX_D_0_8             : in std_logic;
  FF_TX_D_0_9             : in std_logic;
  FF_TX_D_0_10             : in std_logic;
  FF_TX_D_0_11             : in std_logic;
  FF_TX_D_0_12             : in std_logic;
  FF_TX_D_0_13             : in std_logic;
  FF_TX_D_0_14             : in std_logic;
  FF_TX_D_0_15             : in std_logic;
  FF_TX_D_0_16             : in std_logic;
  FF_TX_D_0_17             : in std_logic;
  FF_TX_D_0_18             : in std_logic;
  FF_TX_D_0_19             : in std_logic;
  FF_TX_D_0_20             : in std_logic;
  FF_TX_D_0_21             : in std_logic;
  FF_TX_D_0_22             : in std_logic;
  FF_TX_D_0_23             : in std_logic;
  FF_TX_D_1_0             : in std_logic;
  FF_TX_D_1_1             : in std_logic;
  FF_TX_D_1_2             : in std_logic;
  FF_TX_D_1_3             : in std_logic;
  FF_TX_D_1_4             : in std_logic;
  FF_TX_D_1_5             : in std_logic;
  FF_TX_D_1_6             : in std_logic;
  FF_TX_D_1_7             : in std_logic;
  FF_TX_D_1_8             : in std_logic;
  FF_TX_D_1_9             : in std_logic;
  FF_TX_D_1_10             : in std_logic;
  FF_TX_D_1_11             : in std_logic;
  FF_TX_D_1_12             : in std_logic;
  FF_TX_D_1_13             : in std_logic;
  FF_TX_D_1_14             : in std_logic;
  FF_TX_D_1_15             : in std_logic;
  FF_TX_D_1_16             : in std_logic;
  FF_TX_D_1_17             : in std_logic;
  FF_TX_D_1_18             : in std_logic;
  FF_TX_D_1_19             : in std_logic;
  FF_TX_D_1_20             : in std_logic;
  FF_TX_D_1_21             : in std_logic;
  FF_TX_D_1_22             : in std_logic;
  FF_TX_D_1_23             : in std_logic;
  FF_TX_D_2_0             : in std_logic;
  FF_TX_D_2_1             : in std_logic;
  FF_TX_D_2_2             : in std_logic;
  FF_TX_D_2_3             : in std_logic;
  FF_TX_D_2_4             : in std_logic;
  FF_TX_D_2_5             : in std_logic;
  FF_TX_D_2_6             : in std_logic;
  FF_TX_D_2_7             : in std_logic;
  FF_TX_D_2_8             : in std_logic;
  FF_TX_D_2_9             : in std_logic;
  FF_TX_D_2_10             : in std_logic;
  FF_TX_D_2_11             : in std_logic;
  FF_TX_D_2_12             : in std_logic;
  FF_TX_D_2_13             : in std_logic;
  FF_TX_D_2_14             : in std_logic;
  FF_TX_D_2_15             : in std_logic;
  FF_TX_D_2_16             : in std_logic;
  FF_TX_D_2_17             : in std_logic;
  FF_TX_D_2_18             : in std_logic;
  FF_TX_D_2_19             : in std_logic;
  FF_TX_D_2_20             : in std_logic;
  FF_TX_D_2_21             : in std_logic;
  FF_TX_D_2_22             : in std_logic;
  FF_TX_D_2_23             : in std_logic;
  FF_TX_D_3_0             : in std_logic;
  FF_TX_D_3_1             : in std_logic;
  FF_TX_D_3_2             : in std_logic;
  FF_TX_D_3_3             : in std_logic;
  FF_TX_D_3_4             : in std_logic;
  FF_TX_D_3_5             : in std_logic;
  FF_TX_D_3_6             : in std_logic;
  FF_TX_D_3_7             : in std_logic;
  FF_TX_D_3_8             : in std_logic;
  FF_TX_D_3_9             : in std_logic;
  FF_TX_D_3_10             : in std_logic;
  FF_TX_D_3_11             : in std_logic;
  FF_TX_D_3_12             : in std_logic;
  FF_TX_D_3_13             : in std_logic;
  FF_TX_D_3_14             : in std_logic;
  FF_TX_D_3_15             : in std_logic;
  FF_TX_D_3_16             : in std_logic;
  FF_TX_D_3_17             : in std_logic;
  FF_TX_D_3_18             : in std_logic;
  FF_TX_D_3_19             : in std_logic;
  FF_TX_D_3_20             : in std_logic;
  FF_TX_D_3_21             : in std_logic;
  FF_TX_D_3_22             : in std_logic;
  FF_TX_D_3_23             : in std_logic;
  FF_TXI_CLK_0             : in std_logic;
  FF_TXI_CLK_1             : in std_logic;
  FF_TXI_CLK_2             : in std_logic;
  FF_TXI_CLK_3             : in std_logic;
  FFC_CK_CORE_RX_0         : in std_logic;
  FFC_CK_CORE_RX_1         : in std_logic;
  FFC_CK_CORE_RX_2         : in std_logic;
  FFC_CK_CORE_RX_3         : in std_logic;
  FFC_CK_CORE_TX           : in std_logic;
  FFC_EI_EN_0             : in std_logic;
  FFC_EI_EN_1             : in std_logic;
  FFC_EI_EN_2             : in std_logic;
  FFC_EI_EN_3             : in std_logic;
  FFC_ENABLE_CGALIGN_0             : in std_logic;
  FFC_ENABLE_CGALIGN_1             : in std_logic;
  FFC_ENABLE_CGALIGN_2             : in std_logic;
  FFC_ENABLE_CGALIGN_3             : in std_logic;
  FFC_FB_LOOPBACK_0             : in std_logic;
  FFC_FB_LOOPBACK_1             : in std_logic;
  FFC_FB_LOOPBACK_2             : in std_logic;
  FFC_FB_LOOPBACK_3             : in std_logic;
  FFC_LANE_RX_RST_0             : in std_logic;
  FFC_LANE_RX_RST_1             : in std_logic;
  FFC_LANE_RX_RST_2             : in std_logic;
  FFC_LANE_RX_RST_3             : in std_logic;
  FFC_LANE_TX_RST_0             : in std_logic;
  FFC_LANE_TX_RST_1             : in std_logic;
  FFC_LANE_TX_RST_2             : in std_logic;
  FFC_LANE_TX_RST_3             : in std_logic;
  FFC_MACRO_RST             : in std_logic;
  FFC_PCI_DET_EN_0             : in std_logic;
  FFC_PCI_DET_EN_1             : in std_logic;
  FFC_PCI_DET_EN_2             : in std_logic;
  FFC_PCI_DET_EN_3             : in std_logic;
  FFC_PCIE_CT_0             : in std_logic;
  FFC_PCIE_CT_1             : in std_logic;
  FFC_PCIE_CT_2             : in std_logic;
  FFC_PCIE_CT_3             : in std_logic;
  FFC_PFIFO_CLR_0             : in std_logic;
  FFC_PFIFO_CLR_1             : in std_logic;
  FFC_PFIFO_CLR_2             : in std_logic;
  FFC_PFIFO_CLR_3             : in std_logic;
  FFC_QUAD_RST             : in std_logic;
  FFC_RRST_0             : in std_logic;
  FFC_RRST_1             : in std_logic;
  FFC_RRST_2             : in std_logic;
  FFC_RRST_3             : in std_logic;
  FFC_RXPWDNB_0             : in std_logic;
  FFC_RXPWDNB_1             : in std_logic;
  FFC_RXPWDNB_2             : in std_logic;
  FFC_RXPWDNB_3             : in std_logic;
  FFC_SB_INV_RX_0             : in std_logic;
  FFC_SB_INV_RX_1             : in std_logic;
  FFC_SB_INV_RX_2             : in std_logic;
  FFC_SB_INV_RX_3             : in std_logic;
  FFC_SB_PFIFO_LP_0             : in std_logic;
  FFC_SB_PFIFO_LP_1             : in std_logic;
  FFC_SB_PFIFO_LP_2             : in std_logic;
  FFC_SB_PFIFO_LP_3             : in std_logic;
  FFC_SIGNAL_DETECT_0             : in std_logic;
  FFC_SIGNAL_DETECT_1             : in std_logic;
  FFC_SIGNAL_DETECT_2             : in std_logic;
  FFC_SIGNAL_DETECT_3             : in std_logic;
  FFC_SYNC_TOGGLE             : in std_logic;
  FFC_TRST             : in std_logic;
  FFC_TXPWDNB_0             : in std_logic;
  FFC_TXPWDNB_1             : in std_logic;
  FFC_TXPWDNB_2             : in std_logic;
  FFC_TXPWDNB_3             : in std_logic;
  FFC_RATE_MODE_RX_0        : in std_logic;
  FFC_RATE_MODE_RX_1        : in std_logic;
  FFC_RATE_MODE_RX_2        : in std_logic;
  FFC_RATE_MODE_RX_3        : in std_logic;
  FFC_RATE_MODE_TX_0        : in std_logic;
  FFC_RATE_MODE_TX_1        : in std_logic;
  FFC_RATE_MODE_TX_2        : in std_logic;
  FFC_RATE_MODE_TX_3        : in std_logic;
  FFC_DIV11_MODE_RX_0       : in std_logic;
  FFC_DIV11_MODE_RX_1       : in std_logic;
  FFC_DIV11_MODE_RX_2       : in std_logic;
  FFC_DIV11_MODE_RX_3       : in std_logic;
  FFC_DIV11_MODE_TX_0       : in std_logic;
  FFC_DIV11_MODE_TX_1       : in std_logic;
  FFC_DIV11_MODE_TX_2       : in std_logic;
  FFC_DIV11_MODE_TX_3       : in std_logic;
  LDR_CORE2TX_0             : in std_logic;
  LDR_CORE2TX_1             : in std_logic;
  LDR_CORE2TX_2             : in std_logic;
  LDR_CORE2TX_3             : in std_logic;
  FFC_LDR_CORE2TX_EN_0      : in std_logic;
  FFC_LDR_CORE2TX_EN_1      : in std_logic;
  FFC_LDR_CORE2TX_EN_2      : in std_logic;
  FFC_LDR_CORE2TX_EN_3      : in std_logic;
  PCIE_POWERDOWN_0_0      : in std_logic;
  PCIE_POWERDOWN_0_1      : in std_logic;
  PCIE_POWERDOWN_1_0      : in std_logic;
  PCIE_POWERDOWN_1_1      : in std_logic;
  PCIE_POWERDOWN_2_0      : in std_logic;
  PCIE_POWERDOWN_2_1      : in std_logic;
  PCIE_POWERDOWN_3_0      : in std_logic;
  PCIE_POWERDOWN_3_1      : in std_logic;
  PCIE_RXPOLARITY_0         : in std_logic;
  PCIE_RXPOLARITY_1         : in std_logic;
  PCIE_RXPOLARITY_2         : in std_logic;
  PCIE_RXPOLARITY_3         : in std_logic;
  PCIE_TXCOMPLIANCE_0       : in std_logic;
  PCIE_TXCOMPLIANCE_1       : in std_logic;
  PCIE_TXCOMPLIANCE_2       : in std_logic;
  PCIE_TXCOMPLIANCE_3       : in std_logic;
  PCIE_TXDETRX_PR2TLB_0     : in std_logic;
  PCIE_TXDETRX_PR2TLB_1     : in std_logic;
  PCIE_TXDETRX_PR2TLB_2     : in std_logic;
  PCIE_TXDETRX_PR2TLB_3     : in std_logic;
  SCIADDR0             : in std_logic;
  SCIADDR1             : in std_logic;
  SCIADDR2             : in std_logic;
  SCIADDR3             : in std_logic;
  SCIADDR4             : in std_logic;
  SCIADDR5             : in std_logic;
  SCIENAUX             : in std_logic;
  SCIENCH0             : in std_logic;
  SCIENCH1             : in std_logic;
  SCIENCH2             : in std_logic;
  SCIENCH3             : in std_logic;
  SCIRD                : in std_logic;
  SCISELAUX             : in std_logic;
  SCISELCH0             : in std_logic;
  SCISELCH1             : in std_logic;
  SCISELCH2             : in std_logic;
  SCISELCH3             : in std_logic;
  SCIWDATA0             : in std_logic;
  SCIWDATA1             : in std_logic;
  SCIWDATA2             : in std_logic;
  SCIWDATA3             : in std_logic;
  SCIWDATA4             : in std_logic;
  SCIWDATA5             : in std_logic;
  SCIWDATA6             : in std_logic;
  SCIWDATA7             : in std_logic;
  SCIWSTN               : in std_logic;
  REFCLK_FROM_NQ        : in std_logic;

  HDOUTN0             : out std_logic;
  HDOUTN1             : out std_logic;
  HDOUTN2             : out std_logic;
  HDOUTN3             : out std_logic;
  HDOUTP0             : out std_logic;
  HDOUTP1             : out std_logic;
  HDOUTP2             : out std_logic;
  HDOUTP3             : out std_logic;
  COUT0             : out std_logic;
  COUT1             : out std_logic;
  COUT2             : out std_logic;
  COUT3             : out std_logic;
  COUT4             : out std_logic;
  COUT5             : out std_logic;
  COUT6             : out std_logic;
  COUT7             : out std_logic;
  COUT8             : out std_logic;
  COUT9             : out std_logic;
  COUT10             : out std_logic;
  COUT11             : out std_logic;
  COUT12             : out std_logic;
  COUT13             : out std_logic;
  COUT14             : out std_logic;
  COUT15             : out std_logic;
  COUT16             : out std_logic;
  COUT17             : out std_logic;
  COUT18             : out std_logic;
  COUT19             : out std_logic;
  FF_RX_D_0_0             : out std_logic;
  FF_RX_D_0_1             : out std_logic;
  FF_RX_D_0_2             : out std_logic;
  FF_RX_D_0_3             : out std_logic;
  FF_RX_D_0_4             : out std_logic;
  FF_RX_D_0_5             : out std_logic;
  FF_RX_D_0_6             : out std_logic;
  FF_RX_D_0_7             : out std_logic;
  FF_RX_D_0_8             : out std_logic;
  FF_RX_D_0_9             : out std_logic;
  FF_RX_D_0_10             : out std_logic;
  FF_RX_D_0_11             : out std_logic;
  FF_RX_D_0_12             : out std_logic;
  FF_RX_D_0_13             : out std_logic;
  FF_RX_D_0_14             : out std_logic;
  FF_RX_D_0_15             : out std_logic;
  FF_RX_D_0_16             : out std_logic;
  FF_RX_D_0_17             : out std_logic;
  FF_RX_D_0_18             : out std_logic;
  FF_RX_D_0_19             : out std_logic;
  FF_RX_D_0_20             : out std_logic;
  FF_RX_D_0_21             : out std_logic;
  FF_RX_D_0_22             : out std_logic;
  FF_RX_D_0_23             : out std_logic;
  FF_RX_D_1_0             : out std_logic;
  FF_RX_D_1_1             : out std_logic;
  FF_RX_D_1_2             : out std_logic;
  FF_RX_D_1_3             : out std_logic;
  FF_RX_D_1_4             : out std_logic;
  FF_RX_D_1_5             : out std_logic;
  FF_RX_D_1_6             : out std_logic;
  FF_RX_D_1_7             : out std_logic;
  FF_RX_D_1_8             : out std_logic;
  FF_RX_D_1_9             : out std_logic;
  FF_RX_D_1_10             : out std_logic;
  FF_RX_D_1_11             : out std_logic;
  FF_RX_D_1_12             : out std_logic;
  FF_RX_D_1_13             : out std_logic;
  FF_RX_D_1_14             : out std_logic;
  FF_RX_D_1_15             : out std_logic;
  FF_RX_D_1_16             : out std_logic;
  FF_RX_D_1_17             : out std_logic;
  FF_RX_D_1_18             : out std_logic;
  FF_RX_D_1_19             : out std_logic;
  FF_RX_D_1_20             : out std_logic;
  FF_RX_D_1_21             : out std_logic;
  FF_RX_D_1_22             : out std_logic;
  FF_RX_D_1_23             : out std_logic;
  FF_RX_D_2_0             : out std_logic;
  FF_RX_D_2_1             : out std_logic;
  FF_RX_D_2_2             : out std_logic;
  FF_RX_D_2_3             : out std_logic;
  FF_RX_D_2_4             : out std_logic;
  FF_RX_D_2_5             : out std_logic;
  FF_RX_D_2_6             : out std_logic;
  FF_RX_D_2_7             : out std_logic;
  FF_RX_D_2_8             : out std_logic;
  FF_RX_D_2_9             : out std_logic;
  FF_RX_D_2_10             : out std_logic;
  FF_RX_D_2_11             : out std_logic;
  FF_RX_D_2_12             : out std_logic;
  FF_RX_D_2_13             : out std_logic;
  FF_RX_D_2_14             : out std_logic;
  FF_RX_D_2_15             : out std_logic;
  FF_RX_D_2_16             : out std_logic;
  FF_RX_D_2_17             : out std_logic;
  FF_RX_D_2_18             : out std_logic;
  FF_RX_D_2_19             : out std_logic;
  FF_RX_D_2_20             : out std_logic;
  FF_RX_D_2_21             : out std_logic;
  FF_RX_D_2_22             : out std_logic;
  FF_RX_D_2_23             : out std_logic;
  FF_RX_D_3_0             : out std_logic;
  FF_RX_D_3_1             : out std_logic;
  FF_RX_D_3_2             : out std_logic;
  FF_RX_D_3_3             : out std_logic;
  FF_RX_D_3_4             : out std_logic;
  FF_RX_D_3_5             : out std_logic;
  FF_RX_D_3_6             : out std_logic;
  FF_RX_D_3_7             : out std_logic;
  FF_RX_D_3_8             : out std_logic;
  FF_RX_D_3_9             : out std_logic;
  FF_RX_D_3_10             : out std_logic;
  FF_RX_D_3_11             : out std_logic;
  FF_RX_D_3_12             : out std_logic;
  FF_RX_D_3_13             : out std_logic;
  FF_RX_D_3_14             : out std_logic;
  FF_RX_D_3_15             : out std_logic;
  FF_RX_D_3_16             : out std_logic;
  FF_RX_D_3_17             : out std_logic;
  FF_RX_D_3_18             : out std_logic;
  FF_RX_D_3_19             : out std_logic;
  FF_RX_D_3_20             : out std_logic;
  FF_RX_D_3_21             : out std_logic;
  FF_RX_D_3_22             : out std_logic;
  FF_RX_D_3_23             : out std_logic;
  FF_RX_F_CLK_0             : out std_logic;
  FF_RX_F_CLK_1             : out std_logic;
  FF_RX_F_CLK_2             : out std_logic;
  FF_RX_F_CLK_3             : out std_logic;
  FF_RX_H_CLK_0             : out std_logic;
  FF_RX_H_CLK_1             : out std_logic;
  FF_RX_H_CLK_2             : out std_logic;
  FF_RX_H_CLK_3             : out std_logic;
  FF_TX_F_CLK_0             : out std_logic;
  FF_TX_F_CLK_1             : out std_logic;
  FF_TX_F_CLK_2             : out std_logic;
  FF_TX_F_CLK_3             : out std_logic;
  FF_TX_H_CLK_0             : out std_logic;
  FF_TX_H_CLK_1             : out std_logic;
  FF_TX_H_CLK_2             : out std_logic;
  FF_TX_H_CLK_3             : out std_logic;
  FFS_CC_OVERRUN_0             : out std_logic;
  FFS_CC_OVERRUN_1             : out std_logic;
  FFS_CC_OVERRUN_2             : out std_logic;
  FFS_CC_OVERRUN_3             : out std_logic;
  FFS_CC_UNDERRUN_0             : out std_logic;
  FFS_CC_UNDERRUN_1             : out std_logic;
  FFS_CC_UNDERRUN_2             : out std_logic;
  FFS_CC_UNDERRUN_3             : out std_logic;
  FFS_LS_SYNC_STATUS_0             : out std_logic;
  FFS_LS_SYNC_STATUS_1             : out std_logic;
  FFS_LS_SYNC_STATUS_2             : out std_logic;
  FFS_LS_SYNC_STATUS_3             : out std_logic;
  FFS_CDR_TRAIN_DONE_0             : out std_logic;
  FFS_CDR_TRAIN_DONE_1             : out std_logic;
  FFS_CDR_TRAIN_DONE_2             : out std_logic;
  FFS_CDR_TRAIN_DONE_3             : out std_logic;
  FFS_PCIE_CON_0             : out std_logic;
  FFS_PCIE_CON_1             : out std_logic;
  FFS_PCIE_CON_2             : out std_logic;
  FFS_PCIE_CON_3             : out std_logic;
  FFS_PCIE_DONE_0             : out std_logic;
  FFS_PCIE_DONE_1             : out std_logic;
  FFS_PCIE_DONE_2             : out std_logic;
  FFS_PCIE_DONE_3             : out std_logic;
  FFS_PLOL             : out std_logic;
  FFS_RLOL_0             : out std_logic;
  FFS_RLOL_1             : out std_logic;
  FFS_RLOL_2             : out std_logic;
  FFS_RLOL_3             : out std_logic;
  FFS_RLOS_HI_0             : out std_logic;
  FFS_RLOS_HI_1             : out std_logic;
  FFS_RLOS_HI_2             : out std_logic;
  FFS_RLOS_HI_3             : out std_logic;
  FFS_RLOS_LO_0             : out std_logic;
  FFS_RLOS_LO_1             : out std_logic;
  FFS_RLOS_LO_2             : out std_logic;
  FFS_RLOS_LO_3             : out std_logic;
  FFS_RXFBFIFO_ERROR_0             : out std_logic;
  FFS_RXFBFIFO_ERROR_1             : out std_logic;
  FFS_RXFBFIFO_ERROR_2             : out std_logic;
  FFS_RXFBFIFO_ERROR_3             : out std_logic;
  FFS_TXFBFIFO_ERROR_0             : out std_logic;
  FFS_TXFBFIFO_ERROR_1             : out std_logic;
  FFS_TXFBFIFO_ERROR_2             : out std_logic;
  FFS_TXFBFIFO_ERROR_3             : out std_logic;
  PCIE_PHYSTATUS_0             : out std_logic;
  PCIE_PHYSTATUS_1             : out std_logic;
  PCIE_PHYSTATUS_2             : out std_logic;
  PCIE_PHYSTATUS_3             : out std_logic;
  PCIE_RXVALID_0               : out std_logic;
  PCIE_RXVALID_1               : out std_logic;
  PCIE_RXVALID_2               : out std_logic;
  PCIE_RXVALID_3               : out std_logic;
  FFS_SKP_ADDED_0                  : out std_logic;
  FFS_SKP_ADDED_1                  : out std_logic;
  FFS_SKP_ADDED_2                  : out std_logic;
  FFS_SKP_ADDED_3                  : out std_logic;
  FFS_SKP_DELETED_0                : out std_logic;
  FFS_SKP_DELETED_1                : out std_logic;
  FFS_SKP_DELETED_2                : out std_logic;
  FFS_SKP_DELETED_3                : out std_logic;
  LDR_RX2CORE_0                    : out std_logic;
  LDR_RX2CORE_1                    : out std_logic;
  LDR_RX2CORE_2                    : out std_logic;
  LDR_RX2CORE_3                    : out std_logic;
  REFCK2CORE             : out std_logic;
  SCIINT                : out std_logic;
  SCIRDATA0             : out std_logic;
  SCIRDATA1             : out std_logic;
  SCIRDATA2             : out std_logic;
  SCIRDATA3             : out std_logic;
  SCIRDATA4             : out std_logic;
  SCIRDATA5             : out std_logic;
  SCIRDATA6             : out std_logic;
  SCIRDATA7             : out std_logic;
  REFCLK_TO_NQ          : out std_logic
);

end PCSD;

architecture PCSD_arch of PCSD is


component PCSD_sim
GENERIC(
  CONFIG_FILE : String;
  QUAD_MODE : String;
  CH0_CDR_SRC   : String;
  CH1_CDR_SRC   : String;
  CH2_CDR_SRC   : String;
  CH3_CDR_SRC   : String;
  PLL_SRC   : String
  );
port (
  HDINN0             : in std_logic;
  HDINN1             : in std_logic;
  HDINN2             : in std_logic;
  HDINN3             : in std_logic;
  HDINP0             : in std_logic;
  HDINP1             : in std_logic;
  HDINP2             : in std_logic;
  HDINP3             : in std_logic;
  REFCLKN             : in std_logic;
  REFCLKP             : in std_logic;
  CIN0             : in std_logic;
  CIN1             : in std_logic;
  CIN2             : in std_logic;
  CIN3             : in std_logic;
  CIN4             : in std_logic;
  CIN5             : in std_logic;
  CIN6             : in std_logic;
  CIN7             : in std_logic;
  CIN8             : in std_logic;
  CIN9             : in std_logic;
  CIN10             : in std_logic;
  CIN11             : in std_logic;
  CYAWSTN             : in std_logic;
  FF_EBRD_CLK_0             : in std_logic;
  FF_EBRD_CLK_1             : in std_logic;
  FF_EBRD_CLK_2             : in std_logic;
  FF_EBRD_CLK_3             : in std_logic;
  FF_RXI_CLK_0             : in std_logic;
  FF_RXI_CLK_1             : in std_logic;
  FF_RXI_CLK_2             : in std_logic;
  FF_RXI_CLK_3             : in std_logic;
  FF_TX_D_0_0             : in std_logic;
  FF_TX_D_0_1             : in std_logic;
  FF_TX_D_0_2             : in std_logic;
  FF_TX_D_0_3             : in std_logic;
  FF_TX_D_0_4             : in std_logic;
  FF_TX_D_0_5             : in std_logic;
  FF_TX_D_0_6             : in std_logic;
  FF_TX_D_0_7             : in std_logic;
  FF_TX_D_0_8             : in std_logic;
  FF_TX_D_0_9             : in std_logic;
  FF_TX_D_0_10             : in std_logic;
  FF_TX_D_0_11             : in std_logic;
  FF_TX_D_0_12             : in std_logic;
  FF_TX_D_0_13             : in std_logic;
  FF_TX_D_0_14             : in std_logic;
  FF_TX_D_0_15             : in std_logic;
  FF_TX_D_0_16             : in std_logic;
  FF_TX_D_0_17             : in std_logic;
  FF_TX_D_0_18             : in std_logic;
  FF_TX_D_0_19             : in std_logic;
  FF_TX_D_0_20             : in std_logic;
  FF_TX_D_0_21             : in std_logic;
  FF_TX_D_0_22             : in std_logic;
  FF_TX_D_0_23             : in std_logic;
  FF_TX_D_1_0             : in std_logic;
  FF_TX_D_1_1             : in std_logic;
  FF_TX_D_1_2             : in std_logic;
  FF_TX_D_1_3             : in std_logic;
  FF_TX_D_1_4             : in std_logic;
  FF_TX_D_1_5             : in std_logic;
  FF_TX_D_1_6             : in std_logic;
  FF_TX_D_1_7             : in std_logic;
  FF_TX_D_1_8             : in std_logic;
  FF_TX_D_1_9             : in std_logic;
  FF_TX_D_1_10             : in std_logic;
  FF_TX_D_1_11             : in std_logic;
  FF_TX_D_1_12             : in std_logic;
  FF_TX_D_1_13             : in std_logic;
  FF_TX_D_1_14             : in std_logic;
  FF_TX_D_1_15             : in std_logic;
  FF_TX_D_1_16             : in std_logic;
  FF_TX_D_1_17             : in std_logic;
  FF_TX_D_1_18             : in std_logic;
  FF_TX_D_1_19             : in std_logic;
  FF_TX_D_1_20             : in std_logic;
  FF_TX_D_1_21             : in std_logic;
  FF_TX_D_1_22             : in std_logic;
  FF_TX_D_1_23             : in std_logic;
  FF_TX_D_2_0             : in std_logic;
  FF_TX_D_2_1             : in std_logic;
  FF_TX_D_2_2             : in std_logic;
  FF_TX_D_2_3             : in std_logic;
  FF_TX_D_2_4             : in std_logic;
  FF_TX_D_2_5             : in std_logic;
  FF_TX_D_2_6             : in std_logic;
  FF_TX_D_2_7             : in std_logic;
  FF_TX_D_2_8             : in std_logic;
  FF_TX_D_2_9             : in std_logic;
  FF_TX_D_2_10             : in std_logic;
  FF_TX_D_2_11             : in std_logic;
  FF_TX_D_2_12             : in std_logic;
  FF_TX_D_2_13             : in std_logic;
  FF_TX_D_2_14             : in std_logic;
  FF_TX_D_2_15             : in std_logic;
  FF_TX_D_2_16             : in std_logic;
  FF_TX_D_2_17             : in std_logic;
  FF_TX_D_2_18             : in std_logic;
  FF_TX_D_2_19             : in std_logic;
  FF_TX_D_2_20             : in std_logic;
  FF_TX_D_2_21             : in std_logic;
  FF_TX_D_2_22             : in std_logic;
  FF_TX_D_2_23             : in std_logic;
  FF_TX_D_3_0             : in std_logic;
  FF_TX_D_3_1             : in std_logic;
  FF_TX_D_3_2             : in std_logic;
  FF_TX_D_3_3             : in std_logic;
  FF_TX_D_3_4             : in std_logic;
  FF_TX_D_3_5             : in std_logic;
  FF_TX_D_3_6             : in std_logic;
  FF_TX_D_3_7             : in std_logic;
  FF_TX_D_3_8             : in std_logic;
  FF_TX_D_3_9             : in std_logic;
  FF_TX_D_3_10             : in std_logic;
  FF_TX_D_3_11             : in std_logic;
  FF_TX_D_3_12             : in std_logic;
  FF_TX_D_3_13             : in std_logic;
  FF_TX_D_3_14             : in std_logic;
  FF_TX_D_3_15             : in std_logic;
  FF_TX_D_3_16             : in std_logic;
  FF_TX_D_3_17             : in std_logic;
  FF_TX_D_3_18             : in std_logic;
  FF_TX_D_3_19             : in std_logic;
  FF_TX_D_3_20             : in std_logic;
  FF_TX_D_3_21             : in std_logic;
  FF_TX_D_3_22             : in std_logic;
  FF_TX_D_3_23             : in std_logic;
  FF_TXI_CLK_0             : in std_logic;
  FF_TXI_CLK_1             : in std_logic;
  FF_TXI_CLK_2             : in std_logic;
  FF_TXI_CLK_3             : in std_logic;
  FFC_CK_CORE_RX_0         : in std_logic;
  FFC_CK_CORE_RX_1         : in std_logic;
  FFC_CK_CORE_RX_2         : in std_logic;
  FFC_CK_CORE_RX_3         : in std_logic;
  FFC_CK_CORE_TX           : in std_logic;
  FFC_EI_EN_0             : in std_logic;
  FFC_EI_EN_1             : in std_logic;
  FFC_EI_EN_2             : in std_logic;
  FFC_EI_EN_3             : in std_logic;
  FFC_ENABLE_CGALIGN_0             : in std_logic;
  FFC_ENABLE_CGALIGN_1             : in std_logic;
  FFC_ENABLE_CGALIGN_2             : in std_logic;
  FFC_ENABLE_CGALIGN_3             : in std_logic;
  FFC_FB_LOOPBACK_0             : in std_logic;
  FFC_FB_LOOPBACK_1             : in std_logic;
  FFC_FB_LOOPBACK_2             : in std_logic;
  FFC_FB_LOOPBACK_3             : in std_logic;
  FFC_LANE_RX_RST_0             : in std_logic;
  FFC_LANE_RX_RST_1             : in std_logic;
  FFC_LANE_RX_RST_2             : in std_logic;
  FFC_LANE_RX_RST_3             : in std_logic;
  FFC_LANE_TX_RST_0             : in std_logic;
  FFC_LANE_TX_RST_1             : in std_logic;
  FFC_LANE_TX_RST_2             : in std_logic;
  FFC_LANE_TX_RST_3             : in std_logic;
  FFC_MACRO_RST             : in std_logic;
  FFC_PCI_DET_EN_0             : in std_logic;
  FFC_PCI_DET_EN_1             : in std_logic;
  FFC_PCI_DET_EN_2             : in std_logic;
  FFC_PCI_DET_EN_3             : in std_logic;
  FFC_PCIE_CT_0             : in std_logic;
  FFC_PCIE_CT_1             : in std_logic;
  FFC_PCIE_CT_2             : in std_logic;
  FFC_PCIE_CT_3             : in std_logic;
  FFC_PFIFO_CLR_0             : in std_logic;
  FFC_PFIFO_CLR_1             : in std_logic;
  FFC_PFIFO_CLR_2             : in std_logic;
  FFC_PFIFO_CLR_3             : in std_logic;
  FFC_QUAD_RST             : in std_logic;
  FFC_RRST_0             : in std_logic;
  FFC_RRST_1             : in std_logic;
  FFC_RRST_2             : in std_logic;
  FFC_RRST_3             : in std_logic;
  FFC_RXPWDNB_0             : in std_logic;
  FFC_RXPWDNB_1             : in std_logic;
  FFC_RXPWDNB_2             : in std_logic;
  FFC_RXPWDNB_3             : in std_logic;
  FFC_SB_INV_RX_0             : in std_logic;
  FFC_SB_INV_RX_1             : in std_logic;
  FFC_SB_INV_RX_2             : in std_logic;
  FFC_SB_INV_RX_3             : in std_logic;
  FFC_SB_PFIFO_LP_0             : in std_logic;
  FFC_SB_PFIFO_LP_1             : in std_logic;
  FFC_SB_PFIFO_LP_2             : in std_logic;
  FFC_SB_PFIFO_LP_3             : in std_logic;
  FFC_SIGNAL_DETECT_0             : in std_logic;
  FFC_SIGNAL_DETECT_1             : in std_logic;
  FFC_SIGNAL_DETECT_2             : in std_logic;
  FFC_SIGNAL_DETECT_3             : in std_logic;
  FFC_SYNC_TOGGLE             : in std_logic;
  FFC_TRST             : in std_logic;
  FFC_TXPWDNB_0             : in std_logic;
  FFC_TXPWDNB_1             : in std_logic;
  FFC_TXPWDNB_2             : in std_logic;
  FFC_TXPWDNB_3             : in std_logic;
  FFC_RATE_MODE_RX_0        : in std_logic;
  FFC_RATE_MODE_RX_1        : in std_logic;
  FFC_RATE_MODE_RX_2        : in std_logic;
  FFC_RATE_MODE_RX_3        : in std_logic;
  FFC_RATE_MODE_TX_0        : in std_logic;
  FFC_RATE_MODE_TX_1        : in std_logic;
  FFC_RATE_MODE_TX_2        : in std_logic;
  FFC_RATE_MODE_TX_3        : in std_logic;
  FFC_DIV11_MODE_RX_0       : in std_logic;
  FFC_DIV11_MODE_RX_1       : in std_logic;
  FFC_DIV11_MODE_RX_2       : in std_logic;
  FFC_DIV11_MODE_RX_3       : in std_logic;
  FFC_DIV11_MODE_TX_0       : in std_logic;
  FFC_DIV11_MODE_TX_1       : in std_logic;
  FFC_DIV11_MODE_TX_2       : in std_logic;
  FFC_DIV11_MODE_TX_3       : in std_logic;
  LDR_CORE2TX_0             : in std_logic;
  LDR_CORE2TX_1             : in std_logic;
  LDR_CORE2TX_2             : in std_logic;
  LDR_CORE2TX_3             : in std_logic;
  FFC_LDR_CORE2TX_EN_0      : in std_logic;
  FFC_LDR_CORE2TX_EN_1      : in std_logic;
  FFC_LDR_CORE2TX_EN_2      : in std_logic;
  FFC_LDR_CORE2TX_EN_3      : in std_logic;
  PCIE_POWERDOWN_0_0      : in std_logic;
  PCIE_POWERDOWN_0_1      : in std_logic;
  PCIE_POWERDOWN_1_0      : in std_logic;
  PCIE_POWERDOWN_1_1      : in std_logic;
  PCIE_POWERDOWN_2_0      : in std_logic;
  PCIE_POWERDOWN_2_1      : in std_logic;
  PCIE_POWERDOWN_3_0      : in std_logic;
  PCIE_POWERDOWN_3_1      : in std_logic;
  PCIE_RXPOLARITY_0         : in std_logic;
  PCIE_RXPOLARITY_1         : in std_logic;
  PCIE_RXPOLARITY_2         : in std_logic;
  PCIE_RXPOLARITY_3         : in std_logic;
  PCIE_TXCOMPLIANCE_0       : in std_logic;
  PCIE_TXCOMPLIANCE_1       : in std_logic;
  PCIE_TXCOMPLIANCE_2       : in std_logic;
  PCIE_TXCOMPLIANCE_3       : in std_logic;
  PCIE_TXDETRX_PR2TLB_0     : in std_logic;
  PCIE_TXDETRX_PR2TLB_1     : in std_logic;
  PCIE_TXDETRX_PR2TLB_2     : in std_logic;
  PCIE_TXDETRX_PR2TLB_3     : in std_logic;
  SCIADDR0             : in std_logic;
  SCIADDR1             : in std_logic;
  SCIADDR2             : in std_logic;
  SCIADDR3             : in std_logic;
  SCIADDR4             : in std_logic;
  SCIADDR5             : in std_logic;
  SCIENAUX             : in std_logic;
  SCIENCH0             : in std_logic;
  SCIENCH1             : in std_logic;
  SCIENCH2             : in std_logic;
  SCIENCH3             : in std_logic;
  SCIRD                : in std_logic;
  SCISELAUX             : in std_logic;
  SCISELCH0             : in std_logic;
  SCISELCH1             : in std_logic;
  SCISELCH2             : in std_logic;
  SCISELCH3             : in std_logic;
  SCIWDATA0             : in std_logic;
  SCIWDATA1             : in std_logic;
  SCIWDATA2             : in std_logic;
  SCIWDATA3             : in std_logic;
  SCIWDATA4             : in std_logic;
  SCIWDATA5             : in std_logic;
  SCIWDATA6             : in std_logic;
  SCIWDATA7             : in std_logic;
  SCIWSTN               : in std_logic;
  REFCLK_FROM_NQ        : in std_logic;

  HDOUTN0             : out std_logic;
  HDOUTN1             : out std_logic;
  HDOUTN2             : out std_logic;
  HDOUTN3             : out std_logic;
  HDOUTP0             : out std_logic;
  HDOUTP1             : out std_logic;
  HDOUTP2             : out std_logic;
  HDOUTP3             : out std_logic;
  COUT0             : out std_logic;
  COUT1             : out std_logic;
  COUT2             : out std_logic;
  COUT3             : out std_logic;
  COUT4             : out std_logic;
  COUT5             : out std_logic;
  COUT6             : out std_logic;
  COUT7             : out std_logic;
  COUT8             : out std_logic;
  COUT9             : out std_logic;
  COUT10             : out std_logic;
  COUT11             : out std_logic;
  COUT12             : out std_logic;
  COUT13             : out std_logic;
  COUT14             : out std_logic;
  COUT15             : out std_logic;
  COUT16             : out std_logic;
  COUT17             : out std_logic;
  COUT18             : out std_logic;
  COUT19             : out std_logic;
  FF_RX_D_0_0             : out std_logic;
  FF_RX_D_0_1             : out std_logic;
  FF_RX_D_0_2             : out std_logic;
  FF_RX_D_0_3             : out std_logic;
  FF_RX_D_0_4             : out std_logic;
  FF_RX_D_0_5             : out std_logic;
  FF_RX_D_0_6             : out std_logic;
  FF_RX_D_0_7             : out std_logic;
  FF_RX_D_0_8             : out std_logic;
  FF_RX_D_0_9             : out std_logic;
  FF_RX_D_0_10             : out std_logic;
  FF_RX_D_0_11             : out std_logic;
  FF_RX_D_0_12             : out std_logic;
  FF_RX_D_0_13             : out std_logic;
  FF_RX_D_0_14             : out std_logic;
  FF_RX_D_0_15             : out std_logic;
  FF_RX_D_0_16             : out std_logic;
  FF_RX_D_0_17             : out std_logic;
  FF_RX_D_0_18             : out std_logic;
  FF_RX_D_0_19             : out std_logic;
  FF_RX_D_0_20             : out std_logic;
  FF_RX_D_0_21             : out std_logic;
  FF_RX_D_0_22             : out std_logic;
  FF_RX_D_0_23             : out std_logic;
  FF_RX_D_1_0             : out std_logic;
  FF_RX_D_1_1             : out std_logic;
  FF_RX_D_1_2             : out std_logic;
  FF_RX_D_1_3             : out std_logic;
  FF_RX_D_1_4             : out std_logic;
  FF_RX_D_1_5             : out std_logic;
  FF_RX_D_1_6             : out std_logic;
  FF_RX_D_1_7             : out std_logic;
  FF_RX_D_1_8             : out std_logic;
  FF_RX_D_1_9             : out std_logic;
  FF_RX_D_1_10             : out std_logic;
  FF_RX_D_1_11             : out std_logic;
  FF_RX_D_1_12             : out std_logic;
  FF_RX_D_1_13             : out std_logic;
  FF_RX_D_1_14             : out std_logic;
  FF_RX_D_1_15             : out std_logic;
  FF_RX_D_1_16             : out std_logic;
  FF_RX_D_1_17             : out std_logic;
  FF_RX_D_1_18             : out std_logic;
  FF_RX_D_1_19             : out std_logic;
  FF_RX_D_1_20             : out std_logic;
  FF_RX_D_1_21             : out std_logic;
  FF_RX_D_1_22             : out std_logic;
  FF_RX_D_1_23             : out std_logic;
  FF_RX_D_2_0             : out std_logic;
  FF_RX_D_2_1             : out std_logic;
  FF_RX_D_2_2             : out std_logic;
  FF_RX_D_2_3             : out std_logic;
  FF_RX_D_2_4             : out std_logic;
  FF_RX_D_2_5             : out std_logic;
  FF_RX_D_2_6             : out std_logic;
  FF_RX_D_2_7             : out std_logic;
  FF_RX_D_2_8             : out std_logic;
  FF_RX_D_2_9             : out std_logic;
  FF_RX_D_2_10             : out std_logic;
  FF_RX_D_2_11             : out std_logic;
  FF_RX_D_2_12             : out std_logic;
  FF_RX_D_2_13             : out std_logic;
  FF_RX_D_2_14             : out std_logic;
  FF_RX_D_2_15             : out std_logic;
  FF_RX_D_2_16             : out std_logic;
  FF_RX_D_2_17             : out std_logic;
  FF_RX_D_2_18             : out std_logic;
  FF_RX_D_2_19             : out std_logic;
  FF_RX_D_2_20             : out std_logic;
  FF_RX_D_2_21             : out std_logic;
  FF_RX_D_2_22             : out std_logic;
  FF_RX_D_2_23             : out std_logic;
  FF_RX_D_3_0             : out std_logic;
  FF_RX_D_3_1             : out std_logic;
  FF_RX_D_3_2             : out std_logic;
  FF_RX_D_3_3             : out std_logic;
  FF_RX_D_3_4             : out std_logic;
  FF_RX_D_3_5             : out std_logic;
  FF_RX_D_3_6             : out std_logic;
  FF_RX_D_3_7             : out std_logic;
  FF_RX_D_3_8             : out std_logic;
  FF_RX_D_3_9             : out std_logic;
  FF_RX_D_3_10             : out std_logic;
  FF_RX_D_3_11             : out std_logic;
  FF_RX_D_3_12             : out std_logic;
  FF_RX_D_3_13             : out std_logic;
  FF_RX_D_3_14             : out std_logic;
  FF_RX_D_3_15             : out std_logic;
  FF_RX_D_3_16             : out std_logic;
  FF_RX_D_3_17             : out std_logic;
  FF_RX_D_3_18             : out std_logic;
  FF_RX_D_3_19             : out std_logic;
  FF_RX_D_3_20             : out std_logic;
  FF_RX_D_3_21             : out std_logic;
  FF_RX_D_3_22             : out std_logic;
  FF_RX_D_3_23             : out std_logic;
  FF_RX_F_CLK_0             : out std_logic;
  FF_RX_F_CLK_1             : out std_logic;
  FF_RX_F_CLK_2             : out std_logic;
  FF_RX_F_CLK_3             : out std_logic;
  FF_RX_H_CLK_0             : out std_logic;
  FF_RX_H_CLK_1             : out std_logic;
  FF_RX_H_CLK_2             : out std_logic;
  FF_RX_H_CLK_3             : out std_logic;
  FF_TX_F_CLK_0             : out std_logic;
  FF_TX_F_CLK_1             : out std_logic;
  FF_TX_F_CLK_2             : out std_logic;
  FF_TX_F_CLK_3             : out std_logic;
  FF_TX_H_CLK_0             : out std_logic;
  FF_TX_H_CLK_1             : out std_logic;
  FF_TX_H_CLK_2             : out std_logic;
  FF_TX_H_CLK_3             : out std_logic;
  FFS_CC_OVERRUN_0             : out std_logic;
  FFS_CC_OVERRUN_1             : out std_logic;
  FFS_CC_OVERRUN_2             : out std_logic;
  FFS_CC_OVERRUN_3             : out std_logic;
  FFS_CC_UNDERRUN_0             : out std_logic;
  FFS_CC_UNDERRUN_1             : out std_logic;
  FFS_CC_UNDERRUN_2             : out std_logic;
  FFS_CC_UNDERRUN_3             : out std_logic;
  FFS_LS_SYNC_STATUS_0             : out std_logic;
  FFS_LS_SYNC_STATUS_1             : out std_logic;
  FFS_LS_SYNC_STATUS_2             : out std_logic;
  FFS_LS_SYNC_STATUS_3             : out std_logic;
  FFS_CDR_TRAIN_DONE_0             : out std_logic;
  FFS_CDR_TRAIN_DONE_1             : out std_logic;
  FFS_CDR_TRAIN_DONE_2             : out std_logic;
  FFS_CDR_TRAIN_DONE_3             : out std_logic;
  FFS_PCIE_CON_0             : out std_logic;
  FFS_PCIE_CON_1             : out std_logic;
  FFS_PCIE_CON_2             : out std_logic;
  FFS_PCIE_CON_3             : out std_logic;
  FFS_PCIE_DONE_0             : out std_logic;
  FFS_PCIE_DONE_1             : out std_logic;
  FFS_PCIE_DONE_2             : out std_logic;
  FFS_PCIE_DONE_3             : out std_logic;
  FFS_PLOL             : out std_logic;
  FFS_RLOL_0             : out std_logic;
  FFS_RLOL_1             : out std_logic;
  FFS_RLOL_2             : out std_logic;
  FFS_RLOL_3             : out std_logic;
  FFS_RLOS_HI_0             : out std_logic;
  FFS_RLOS_HI_1             : out std_logic;
  FFS_RLOS_HI_2             : out std_logic;
  FFS_RLOS_HI_3             : out std_logic;
  FFS_RLOS_LO_0             : out std_logic;
  FFS_RLOS_LO_1             : out std_logic;
  FFS_RLOS_LO_2             : out std_logic;
  FFS_RLOS_LO_3             : out std_logic;
  FFS_RXFBFIFO_ERROR_0             : out std_logic;
  FFS_RXFBFIFO_ERROR_1             : out std_logic;
  FFS_RXFBFIFO_ERROR_2             : out std_logic;
  FFS_RXFBFIFO_ERROR_3             : out std_logic;
  FFS_TXFBFIFO_ERROR_0             : out std_logic;
  FFS_TXFBFIFO_ERROR_1             : out std_logic;
  FFS_TXFBFIFO_ERROR_2             : out std_logic;
  FFS_TXFBFIFO_ERROR_3             : out std_logic;
  PCIE_PHYSTATUS_0             : out std_logic;
  PCIE_PHYSTATUS_1             : out std_logic;
  PCIE_PHYSTATUS_2             : out std_logic;
  PCIE_PHYSTATUS_3             : out std_logic;
  PCIE_RXVALID_0               : out std_logic;
  PCIE_RXVALID_1               : out std_logic;
  PCIE_RXVALID_2               : out std_logic;
  PCIE_RXVALID_3               : out std_logic;
  FFS_SKP_ADDED_0                  : out std_logic;
  FFS_SKP_ADDED_1                  : out std_logic;
  FFS_SKP_ADDED_2                  : out std_logic;
  FFS_SKP_ADDED_3                  : out std_logic;
  FFS_SKP_DELETED_0                : out std_logic;
  FFS_SKP_DELETED_1                : out std_logic;
  FFS_SKP_DELETED_2                : out std_logic;
  FFS_SKP_DELETED_3                : out std_logic;
  LDR_RX2CORE_0                    : out std_logic;
  LDR_RX2CORE_1                    : out std_logic;
  LDR_RX2CORE_2                    : out std_logic;
  LDR_RX2CORE_3                    : out std_logic;
  REFCK2CORE             : out std_logic;
  SCIINT                : out std_logic;
  SCIRDATA0             : out std_logic;
  SCIRDATA1             : out std_logic;
  SCIRDATA2             : out std_logic;
  SCIRDATA3             : out std_logic;
  SCIRDATA4             : out std_logic;
  SCIRDATA5             : out std_logic;
  SCIRDATA6             : out std_logic;
  SCIRDATA7             : out std_logic;
  REFCLK_TO_NQ          : out std_logic
);
end component;

begin

PCSD_sim_inst : PCSD_sim
generic map (
  CONFIG_FILE => CONFIG_FILE,
  QUAD_MODE => QUAD_MODE,
  CH0_CDR_SRC => CH0_CDR_SRC,
  CH1_CDR_SRC => CH1_CDR_SRC,
  CH2_CDR_SRC => CH2_CDR_SRC,
  CH3_CDR_SRC => CH3_CDR_SRC,
  PLL_SRC => PLL_SRC
  )
port map (
   HDINN0 => HDINN0,
   HDINN1 => HDINN1,
   HDINN2 => HDINN2,
   HDINN3 => HDINN3,
   HDINP0 => HDINP0,
   HDINP1 => HDINP1,
   HDINP2 => HDINP2,
   HDINP3 => HDINP3,
   REFCLKN => REFCLKN,
   REFCLKP => REFCLKP,
   CIN11 => CIN11,
   CIN10 => CIN10,
   CIN9 => CIN9,
   CIN8 => CIN8,
   CIN7 => CIN7,
   CIN6 => CIN6,
   CIN5 => CIN5,
   CIN4 => CIN4,
   CIN3 => CIN3,
   CIN2 => CIN2,
   CIN1 => CIN1,
   CIN0 => CIN0,
   CYAWSTN => CYAWSTN,
   FF_EBRD_CLK_3 => FF_EBRD_CLK_3,
   FF_EBRD_CLK_2 => FF_EBRD_CLK_2,
   FF_EBRD_CLK_1 => FF_EBRD_CLK_1,
   FF_EBRD_CLK_0 => FF_EBRD_CLK_0,
   FF_RXI_CLK_3 => FF_RXI_CLK_3,
   FF_RXI_CLK_2 => FF_RXI_CLK_2,
   FF_RXI_CLK_1 => FF_RXI_CLK_1,
   FF_RXI_CLK_0 => FF_RXI_CLK_0,
   FF_TX_D_0_0 => FF_TX_D_0_0,
   FF_TX_D_0_1 => FF_TX_D_0_1,
   FF_TX_D_0_2 => FF_TX_D_0_2,
   FF_TX_D_0_3 => FF_TX_D_0_3,
   FF_TX_D_0_4 => FF_TX_D_0_4,
   FF_TX_D_0_5 => FF_TX_D_0_5,
   FF_TX_D_0_6 => FF_TX_D_0_6,
   FF_TX_D_0_7 => FF_TX_D_0_7,
   FF_TX_D_0_8 => FF_TX_D_0_8,
   FF_TX_D_0_9 => FF_TX_D_0_9,
   FF_TX_D_0_10 => FF_TX_D_0_10,
   FF_TX_D_0_11 => FF_TX_D_0_11,
   FF_TX_D_0_12 => FF_TX_D_0_12,
   FF_TX_D_0_13 => FF_TX_D_0_13,
   FF_TX_D_0_14 => FF_TX_D_0_14,
   FF_TX_D_0_15 => FF_TX_D_0_15,
   FF_TX_D_0_16 => FF_TX_D_0_16,
   FF_TX_D_0_17 => FF_TX_D_0_17,
   FF_TX_D_0_18 => FF_TX_D_0_18,
   FF_TX_D_0_19 => FF_TX_D_0_19,
   FF_TX_D_0_20 => FF_TX_D_0_20,
   FF_TX_D_0_21 => FF_TX_D_0_21,
   FF_TX_D_0_22 => FF_TX_D_0_22,
   FF_TX_D_0_23 => FF_TX_D_0_23,
   FF_TX_D_1_0 => FF_TX_D_1_0,
   FF_TX_D_1_1 => FF_TX_D_1_1,
   FF_TX_D_1_2 => FF_TX_D_1_2,
   FF_TX_D_1_3 => FF_TX_D_1_3,
   FF_TX_D_1_4 => FF_TX_D_1_4,
   FF_TX_D_1_5 => FF_TX_D_1_5,
   FF_TX_D_1_6 => FF_TX_D_1_6,
   FF_TX_D_1_7 => FF_TX_D_1_7,
   FF_TX_D_1_8 => FF_TX_D_1_8,
   FF_TX_D_1_9 => FF_TX_D_1_9,
   FF_TX_D_1_10 => FF_TX_D_1_10,
   FF_TX_D_1_11 => FF_TX_D_1_11,
   FF_TX_D_1_12 => FF_TX_D_1_12,
   FF_TX_D_1_13 => FF_TX_D_1_13,
   FF_TX_D_1_14 => FF_TX_D_1_14,
   FF_TX_D_1_15 => FF_TX_D_1_15,
   FF_TX_D_1_16 => FF_TX_D_1_16,
   FF_TX_D_1_17 => FF_TX_D_1_17,
   FF_TX_D_1_18 => FF_TX_D_1_18,
   FF_TX_D_1_19 => FF_TX_D_1_19,
   FF_TX_D_1_20 => FF_TX_D_1_20,
   FF_TX_D_1_21 => FF_TX_D_1_21,
   FF_TX_D_1_22 => FF_TX_D_1_22,
   FF_TX_D_1_23 => FF_TX_D_1_23,
   FF_TX_D_2_0 => FF_TX_D_2_0,
   FF_TX_D_2_1 => FF_TX_D_2_1,
   FF_TX_D_2_2 => FF_TX_D_2_2,
   FF_TX_D_2_3 => FF_TX_D_2_3,
   FF_TX_D_2_4 => FF_TX_D_2_4,
   FF_TX_D_2_5 => FF_TX_D_2_5,
   FF_TX_D_2_6 => FF_TX_D_2_6,
   FF_TX_D_2_7 => FF_TX_D_2_7,
   FF_TX_D_2_8 => FF_TX_D_2_8,
   FF_TX_D_2_9 => FF_TX_D_2_9,
   FF_TX_D_2_10 => FF_TX_D_2_10,
   FF_TX_D_2_11 => FF_TX_D_2_11,
   FF_TX_D_2_12 => FF_TX_D_2_12,
   FF_TX_D_2_13 => FF_TX_D_2_13,
   FF_TX_D_2_14 => FF_TX_D_2_14,
   FF_TX_D_2_15 => FF_TX_D_2_15,
   FF_TX_D_2_16 => FF_TX_D_2_16,
   FF_TX_D_2_17 => FF_TX_D_2_17,
   FF_TX_D_2_18 => FF_TX_D_2_18,
   FF_TX_D_2_19 => FF_TX_D_2_19,
   FF_TX_D_2_20 => FF_TX_D_2_20,
   FF_TX_D_2_21 => FF_TX_D_2_21,
   FF_TX_D_2_22 => FF_TX_D_2_22,
   FF_TX_D_2_23 => FF_TX_D_2_23,
   FF_TX_D_3_0 => FF_TX_D_3_0,
   FF_TX_D_3_1 => FF_TX_D_3_1,
   FF_TX_D_3_2 => FF_TX_D_3_2,
   FF_TX_D_3_3 => FF_TX_D_3_3,
   FF_TX_D_3_4 => FF_TX_D_3_4,
   FF_TX_D_3_5 => FF_TX_D_3_5,
   FF_TX_D_3_6 => FF_TX_D_3_6,
   FF_TX_D_3_7 => FF_TX_D_3_7,
   FF_TX_D_3_8 => FF_TX_D_3_8,
   FF_TX_D_3_9 => FF_TX_D_3_9,
   FF_TX_D_3_10 => FF_TX_D_3_10,
   FF_TX_D_3_11 => FF_TX_D_3_11,
   FF_TX_D_3_12 => FF_TX_D_3_12,
   FF_TX_D_3_13 => FF_TX_D_3_13,
   FF_TX_D_3_14 => FF_TX_D_3_14,
   FF_TX_D_3_15 => FF_TX_D_3_15,
   FF_TX_D_3_16 => FF_TX_D_3_16,
   FF_TX_D_3_17 => FF_TX_D_3_17,
   FF_TX_D_3_18 => FF_TX_D_3_18,
   FF_TX_D_3_19 => FF_TX_D_3_19,
   FF_TX_D_3_20 => FF_TX_D_3_20,
   FF_TX_D_3_21 => FF_TX_D_3_21,
   FF_TX_D_3_22 => FF_TX_D_3_22,
   FF_TX_D_3_23 => FF_TX_D_3_23,
   FF_TXI_CLK_0 => FF_TXI_CLK_0,
   FF_TXI_CLK_1 => FF_TXI_CLK_1,
   FF_TXI_CLK_2 => FF_TXI_CLK_2,
   FF_TXI_CLK_3 => FF_TXI_CLK_3,
   FFC_CK_CORE_RX_0 => FFC_CK_CORE_RX_0,
   FFC_CK_CORE_RX_1 => FFC_CK_CORE_RX_1,
   FFC_CK_CORE_RX_2 => FFC_CK_CORE_RX_2,
   FFC_CK_CORE_RX_3 => FFC_CK_CORE_RX_3,
   FFC_CK_CORE_TX => FFC_CK_CORE_TX,
   FFC_EI_EN_0 => FFC_EI_EN_0,
   FFC_EI_EN_1 => FFC_EI_EN_1,
   FFC_EI_EN_2 => FFC_EI_EN_2,
   FFC_EI_EN_3 => FFC_EI_EN_3,
   FFC_ENABLE_CGALIGN_0 => FFC_ENABLE_CGALIGN_0,
   FFC_ENABLE_CGALIGN_1 => FFC_ENABLE_CGALIGN_1,
   FFC_ENABLE_CGALIGN_2 => FFC_ENABLE_CGALIGN_2,
   FFC_ENABLE_CGALIGN_3 => FFC_ENABLE_CGALIGN_3,
   FFC_FB_LOOPBACK_0 => FFC_FB_LOOPBACK_0,
   FFC_FB_LOOPBACK_1 => FFC_FB_LOOPBACK_1,
   FFC_FB_LOOPBACK_2 => FFC_FB_LOOPBACK_2,
   FFC_FB_LOOPBACK_3 => FFC_FB_LOOPBACK_3,
   FFC_LANE_RX_RST_0 => FFC_LANE_RX_RST_0,
   FFC_LANE_RX_RST_1 => FFC_LANE_RX_RST_1,
   FFC_LANE_RX_RST_2 => FFC_LANE_RX_RST_2,
   FFC_LANE_RX_RST_3 => FFC_LANE_RX_RST_3,
   FFC_LANE_TX_RST_0 => FFC_LANE_TX_RST_0,
   FFC_LANE_TX_RST_1 => FFC_LANE_TX_RST_1,
   FFC_LANE_TX_RST_2 => FFC_LANE_TX_RST_2,
   FFC_LANE_TX_RST_3 => FFC_LANE_TX_RST_3,
   FFC_MACRO_RST => FFC_MACRO_RST,
   FFC_PCI_DET_EN_0 => FFC_PCI_DET_EN_0,
   FFC_PCI_DET_EN_1 => FFC_PCI_DET_EN_1,
   FFC_PCI_DET_EN_2 => FFC_PCI_DET_EN_2,
   FFC_PCI_DET_EN_3 => FFC_PCI_DET_EN_3,
   FFC_PCIE_CT_0 => FFC_PCIE_CT_0,
   FFC_PCIE_CT_1 => FFC_PCIE_CT_1,
   FFC_PCIE_CT_2 => FFC_PCIE_CT_2,
   FFC_PCIE_CT_3 => FFC_PCIE_CT_3,
   FFC_PFIFO_CLR_0 => FFC_PFIFO_CLR_0,
   FFC_PFIFO_CLR_1 => FFC_PFIFO_CLR_1,
   FFC_PFIFO_CLR_2 => FFC_PFIFO_CLR_2,
   FFC_PFIFO_CLR_3 => FFC_PFIFO_CLR_3,
   FFC_QUAD_RST => FFC_QUAD_RST,
   FFC_RRST_0 => FFC_RRST_0,
   FFC_RRST_1 => FFC_RRST_1,
   FFC_RRST_2 => FFC_RRST_2,
   FFC_RRST_3 => FFC_RRST_3,
   FFC_RXPWDNB_0 => FFC_RXPWDNB_0,
   FFC_RXPWDNB_1 => FFC_RXPWDNB_1,
   FFC_RXPWDNB_2 => FFC_RXPWDNB_2,
   FFC_RXPWDNB_3 => FFC_RXPWDNB_3,
   FFC_SB_INV_RX_0 => FFC_SB_INV_RX_0,
   FFC_SB_INV_RX_1 => FFC_SB_INV_RX_1,
   FFC_SB_INV_RX_2 => FFC_SB_INV_RX_2,
   FFC_SB_INV_RX_3 => FFC_SB_INV_RX_3,
   FFC_SB_PFIFO_LP_0 => FFC_SB_PFIFO_LP_0,
   FFC_SB_PFIFO_LP_1 => FFC_SB_PFIFO_LP_1,
   FFC_SB_PFIFO_LP_2 => FFC_SB_PFIFO_LP_2,
   FFC_SB_PFIFO_LP_3 => FFC_SB_PFIFO_LP_3,
   FFC_SIGNAL_DETECT_0 => FFC_SIGNAL_DETECT_0,
   FFC_SIGNAL_DETECT_1 => FFC_SIGNAL_DETECT_1,
   FFC_SIGNAL_DETECT_2 => FFC_SIGNAL_DETECT_2,
   FFC_SIGNAL_DETECT_3 => FFC_SIGNAL_DETECT_3,
   FFC_SYNC_TOGGLE => FFC_SYNC_TOGGLE,
   FFC_TRST => FFC_TRST,
   FFC_TXPWDNB_0 => FFC_TXPWDNB_0,
   FFC_TXPWDNB_1 => FFC_TXPWDNB_1,
   FFC_TXPWDNB_2 => FFC_TXPWDNB_2,
   FFC_TXPWDNB_3 => FFC_TXPWDNB_3,
   FFC_RATE_MODE_RX_0 => FFC_RATE_MODE_RX_0,
   FFC_RATE_MODE_RX_1 => FFC_RATE_MODE_RX_1,
   FFC_RATE_MODE_RX_2 => FFC_RATE_MODE_RX_2,
   FFC_RATE_MODE_RX_3 => FFC_RATE_MODE_RX_3,
   FFC_RATE_MODE_TX_0 => FFC_RATE_MODE_TX_0,
   FFC_RATE_MODE_TX_1 => FFC_RATE_MODE_TX_1,
   FFC_RATE_MODE_TX_2 => FFC_RATE_MODE_TX_2,
   FFC_RATE_MODE_TX_3 => FFC_RATE_MODE_TX_3,
   FFC_DIV11_MODE_RX_0 => FFC_DIV11_MODE_RX_0,
   FFC_DIV11_MODE_RX_1 => FFC_DIV11_MODE_RX_1,
   FFC_DIV11_MODE_RX_2 => FFC_DIV11_MODE_RX_2,
   FFC_DIV11_MODE_RX_3 => FFC_DIV11_MODE_RX_3,
   FFC_DIV11_MODE_TX_0 => FFC_DIV11_MODE_TX_0,
   FFC_DIV11_MODE_TX_1 => FFC_DIV11_MODE_TX_1,
   FFC_DIV11_MODE_TX_2 => FFC_DIV11_MODE_TX_2,
   FFC_DIV11_MODE_TX_3 => FFC_DIV11_MODE_TX_3,
   LDR_CORE2TX_0 => LDR_CORE2TX_0,
   LDR_CORE2TX_1 => LDR_CORE2TX_1,
   LDR_CORE2TX_2 => LDR_CORE2TX_2,
   LDR_CORE2TX_3 => LDR_CORE2TX_3,
   FFC_LDR_CORE2TX_EN_0 => FFC_LDR_CORE2TX_EN_0,
   FFC_LDR_CORE2TX_EN_1 => FFC_LDR_CORE2TX_EN_1,
   FFC_LDR_CORE2TX_EN_2 => FFC_LDR_CORE2TX_EN_2,
   FFC_LDR_CORE2TX_EN_3 => FFC_LDR_CORE2TX_EN_3,
   PCIE_POWERDOWN_0_0 => PCIE_POWERDOWN_0_0,
   PCIE_POWERDOWN_0_1 => PCIE_POWERDOWN_0_1,
   PCIE_POWERDOWN_1_0 => PCIE_POWERDOWN_1_0,
   PCIE_POWERDOWN_1_1 => PCIE_POWERDOWN_1_1,
   PCIE_POWERDOWN_2_0 => PCIE_POWERDOWN_2_0,
   PCIE_POWERDOWN_2_1 => PCIE_POWERDOWN_2_1,
   PCIE_POWERDOWN_3_0 => PCIE_POWERDOWN_3_0,
   PCIE_POWERDOWN_3_1 => PCIE_POWERDOWN_3_1,
   PCIE_RXPOLARITY_0 => PCIE_RXPOLARITY_0,
   PCIE_RXPOLARITY_1 => PCIE_RXPOLARITY_1,
   PCIE_RXPOLARITY_2 => PCIE_RXPOLARITY_2,
   PCIE_RXPOLARITY_3 => PCIE_RXPOLARITY_3,
   PCIE_TXCOMPLIANCE_0 => PCIE_TXCOMPLIANCE_0,
   PCIE_TXCOMPLIANCE_1 => PCIE_TXCOMPLIANCE_1,
   PCIE_TXCOMPLIANCE_2 => PCIE_TXCOMPLIANCE_2,
   PCIE_TXCOMPLIANCE_3 => PCIE_TXCOMPLIANCE_3,
   PCIE_TXDETRX_PR2TLB_0 => PCIE_TXDETRX_PR2TLB_0,
   PCIE_TXDETRX_PR2TLB_1 => PCIE_TXDETRX_PR2TLB_1,
   PCIE_TXDETRX_PR2TLB_2 => PCIE_TXDETRX_PR2TLB_2,
   PCIE_TXDETRX_PR2TLB_3 => PCIE_TXDETRX_PR2TLB_3,
   SCIADDR0 => SCIADDR0,
   SCIADDR1 => SCIADDR1,
   SCIADDR2 => SCIADDR2,
   SCIADDR3 => SCIADDR3,
   SCIADDR4 => SCIADDR4,
   SCIADDR5 => SCIADDR5,
   SCIENAUX => SCIENAUX,
   SCIENCH0 => SCIENCH0,
   SCIENCH1 => SCIENCH1,
   SCIENCH2 => SCIENCH2,
   SCIENCH3 => SCIENCH3,
   SCIRD => SCIRD,
   SCISELAUX => SCISELAUX,
   SCISELCH0 => SCISELCH0,
   SCISELCH1 => SCISELCH1,
   SCISELCH2 => SCISELCH2,
   SCISELCH3 => SCISELCH3,
   SCIWDATA0 => SCIWDATA0,
   SCIWDATA1 => SCIWDATA1,
   SCIWDATA2 => SCIWDATA2,
   SCIWDATA3 => SCIWDATA3,
   SCIWDATA4 => SCIWDATA4,
   SCIWDATA5 => SCIWDATA5,
   SCIWDATA6 => SCIWDATA6,
   SCIWDATA7 => SCIWDATA7,
   SCIWSTN => SCIWSTN,
   HDOUTN0 => HDOUTN0,
   HDOUTN1 => HDOUTN1,
   HDOUTN2 => HDOUTN2,
   HDOUTN3 => HDOUTN3,
   HDOUTP0 => HDOUTP0,
   HDOUTP1 => HDOUTP1,
   HDOUTP2 => HDOUTP2,
   HDOUTP3 => HDOUTP3,
   COUT19 => COUT19,
   COUT18 => COUT18,
   COUT17 => COUT17,
   COUT16 => COUT16,
   COUT15 => COUT15,
   COUT14 => COUT14,
   COUT13 => COUT13,
   COUT12 => COUT12,
   COUT11 => COUT11,
   COUT10 => COUT10,
   COUT9 => COUT9,
   COUT8 => COUT8,
   COUT7 => COUT7,
   COUT6 => COUT6,
   COUT5 => COUT5,
   COUT4 => COUT4,
   COUT3 => COUT3,
   COUT2 => COUT2,
   COUT1 => COUT1,
   COUT0 => COUT0,
   FF_RX_D_0_0 => FF_RX_D_0_0,
   FF_RX_D_0_1 => FF_RX_D_0_1,
   FF_RX_D_0_2 => FF_RX_D_0_2,
   FF_RX_D_0_3 => FF_RX_D_0_3,
   FF_RX_D_0_4 => FF_RX_D_0_4,
   FF_RX_D_0_5 => FF_RX_D_0_5,
   FF_RX_D_0_6 => FF_RX_D_0_6,
   FF_RX_D_0_7 => FF_RX_D_0_7,
   FF_RX_D_0_8 => FF_RX_D_0_8,
   FF_RX_D_0_9 => FF_RX_D_0_9,
   FF_RX_D_0_10 => FF_RX_D_0_10,
   FF_RX_D_0_11 => FF_RX_D_0_11,
   FF_RX_D_0_12 => FF_RX_D_0_12,
   FF_RX_D_0_13 => FF_RX_D_0_13,
   FF_RX_D_0_14 => FF_RX_D_0_14,
   FF_RX_D_0_15 => FF_RX_D_0_15,
   FF_RX_D_0_16 => FF_RX_D_0_16,
   FF_RX_D_0_17 => FF_RX_D_0_17,
   FF_RX_D_0_18 => FF_RX_D_0_18,
   FF_RX_D_0_19 => FF_RX_D_0_19,
   FF_RX_D_0_20 => FF_RX_D_0_20,
   FF_RX_D_0_21 => FF_RX_D_0_21,
   FF_RX_D_0_22 => FF_RX_D_0_22,
   FF_RX_D_0_23 => FF_RX_D_0_23,
   FF_RX_D_1_0 => FF_RX_D_1_0,
   FF_RX_D_1_1 => FF_RX_D_1_1,
   FF_RX_D_1_2 => FF_RX_D_1_2,
   FF_RX_D_1_3 => FF_RX_D_1_3,
   FF_RX_D_1_4 => FF_RX_D_1_4,
   FF_RX_D_1_5 => FF_RX_D_1_5,
   FF_RX_D_1_6 => FF_RX_D_1_6,
   FF_RX_D_1_7 => FF_RX_D_1_7,
   FF_RX_D_1_8 => FF_RX_D_1_8,
   FF_RX_D_1_9 => FF_RX_D_1_9,
   FF_RX_D_1_10 => FF_RX_D_1_10,
   FF_RX_D_1_11 => FF_RX_D_1_11,
   FF_RX_D_1_12 => FF_RX_D_1_12,
   FF_RX_D_1_13 => FF_RX_D_1_13,
   FF_RX_D_1_14 => FF_RX_D_1_14,
   FF_RX_D_1_15 => FF_RX_D_1_15,
   FF_RX_D_1_16 => FF_RX_D_1_16,
   FF_RX_D_1_17 => FF_RX_D_1_17,
   FF_RX_D_1_18 => FF_RX_D_1_18,
   FF_RX_D_1_19 => FF_RX_D_1_19,
   FF_RX_D_1_20 => FF_RX_D_1_20,
   FF_RX_D_1_21 => FF_RX_D_1_21,
   FF_RX_D_1_22 => FF_RX_D_1_22,
   FF_RX_D_1_23 => FF_RX_D_1_23,
   FF_RX_D_2_0 => FF_RX_D_2_0,
   FF_RX_D_2_1 => FF_RX_D_2_1,
   FF_RX_D_2_2 => FF_RX_D_2_2,
   FF_RX_D_2_3 => FF_RX_D_2_3,
   FF_RX_D_2_4 => FF_RX_D_2_4,
   FF_RX_D_2_5 => FF_RX_D_2_5,
   FF_RX_D_2_6 => FF_RX_D_2_6,
   FF_RX_D_2_7 => FF_RX_D_2_7,
   FF_RX_D_2_8 => FF_RX_D_2_8,
   FF_RX_D_2_9 => FF_RX_D_2_9,
   FF_RX_D_2_10 => FF_RX_D_2_10,
   FF_RX_D_2_11 => FF_RX_D_2_11,
   FF_RX_D_2_12 => FF_RX_D_2_12,
   FF_RX_D_2_13 => FF_RX_D_2_13,
   FF_RX_D_2_14 => FF_RX_D_2_14,
   FF_RX_D_2_15 => FF_RX_D_2_15,
   FF_RX_D_2_16 => FF_RX_D_2_16,
   FF_RX_D_2_17 => FF_RX_D_2_17,
   FF_RX_D_2_18 => FF_RX_D_2_18,
   FF_RX_D_2_19 => FF_RX_D_2_19,
   FF_RX_D_2_20 => FF_RX_D_2_20,
   FF_RX_D_2_21 => FF_RX_D_2_21,
   FF_RX_D_2_22 => FF_RX_D_2_22,
   FF_RX_D_2_23 => FF_RX_D_2_23,
   FF_RX_D_3_0 => FF_RX_D_3_0,
   FF_RX_D_3_1 => FF_RX_D_3_1,
   FF_RX_D_3_2 => FF_RX_D_3_2,
   FF_RX_D_3_3 => FF_RX_D_3_3,
   FF_RX_D_3_4 => FF_RX_D_3_4,
   FF_RX_D_3_5 => FF_RX_D_3_5,
   FF_RX_D_3_6 => FF_RX_D_3_6,
   FF_RX_D_3_7 => FF_RX_D_3_7,
   FF_RX_D_3_8 => FF_RX_D_3_8,
   FF_RX_D_3_9 => FF_RX_D_3_9,
   FF_RX_D_3_10 => FF_RX_D_3_10,
   FF_RX_D_3_11 => FF_RX_D_3_11,
   FF_RX_D_3_12 => FF_RX_D_3_12,
   FF_RX_D_3_13 => FF_RX_D_3_13,
   FF_RX_D_3_14 => FF_RX_D_3_14,
   FF_RX_D_3_15 => FF_RX_D_3_15,
   FF_RX_D_3_16 => FF_RX_D_3_16,
   FF_RX_D_3_17 => FF_RX_D_3_17,
   FF_RX_D_3_18 => FF_RX_D_3_18,
   FF_RX_D_3_19 => FF_RX_D_3_19,
   FF_RX_D_3_20 => FF_RX_D_3_20,
   FF_RX_D_3_21 => FF_RX_D_3_21,
   FF_RX_D_3_22 => FF_RX_D_3_22,
   FF_RX_D_3_23 => FF_RX_D_3_23,
   FF_RX_F_CLK_0 => FF_RX_F_CLK_0,
   FF_RX_F_CLK_1 => FF_RX_F_CLK_1,
   FF_RX_F_CLK_2 => FF_RX_F_CLK_2,
   FF_RX_F_CLK_3 => FF_RX_F_CLK_3,
   FF_RX_H_CLK_0 => FF_RX_H_CLK_0,
   FF_RX_H_CLK_1 => FF_RX_H_CLK_1,
   FF_RX_H_CLK_2 => FF_RX_H_CLK_2,
   FF_RX_H_CLK_3 => FF_RX_H_CLK_3,
   FF_TX_F_CLK_0 => FF_TX_F_CLK_0,
   FF_TX_F_CLK_1 => FF_TX_F_CLK_1,
   FF_TX_F_CLK_2 => FF_TX_F_CLK_2,
   FF_TX_F_CLK_3 => FF_TX_F_CLK_3,
   FF_TX_H_CLK_0 => FF_TX_H_CLK_0,
   FF_TX_H_CLK_1 => FF_TX_H_CLK_1,
   FF_TX_H_CLK_2 => FF_TX_H_CLK_2,
   FF_TX_H_CLK_3 => FF_TX_H_CLK_3,
   FFS_CC_OVERRUN_0 => FFS_CC_OVERRUN_0,
   FFS_CC_OVERRUN_1 => FFS_CC_OVERRUN_1,
   FFS_CC_OVERRUN_2 => FFS_CC_OVERRUN_2,
   FFS_CC_OVERRUN_3 => FFS_CC_OVERRUN_3,
   FFS_CC_UNDERRUN_0 => FFS_CC_UNDERRUN_0,
   FFS_CC_UNDERRUN_1 => FFS_CC_UNDERRUN_1,
   FFS_CC_UNDERRUN_2 => FFS_CC_UNDERRUN_2,
   FFS_CC_UNDERRUN_3 => FFS_CC_UNDERRUN_3,
   FFS_LS_SYNC_STATUS_0 => FFS_LS_SYNC_STATUS_0,
   FFS_LS_SYNC_STATUS_1 => FFS_LS_SYNC_STATUS_1,
   FFS_LS_SYNC_STATUS_2 => FFS_LS_SYNC_STATUS_2,
   FFS_LS_SYNC_STATUS_3 => FFS_LS_SYNC_STATUS_3,
   FFS_CDR_TRAIN_DONE_0 => FFS_CDR_TRAIN_DONE_0,
   FFS_CDR_TRAIN_DONE_1 => FFS_CDR_TRAIN_DONE_1,
   FFS_CDR_TRAIN_DONE_2 => FFS_CDR_TRAIN_DONE_2,
   FFS_CDR_TRAIN_DONE_3 => FFS_CDR_TRAIN_DONE_3,
   FFS_PCIE_CON_0 => FFS_PCIE_CON_0,
   FFS_PCIE_CON_1 => FFS_PCIE_CON_1,
   FFS_PCIE_CON_2 => FFS_PCIE_CON_2,
   FFS_PCIE_CON_3 => FFS_PCIE_CON_3,
   FFS_PCIE_DONE_0 => FFS_PCIE_DONE_0,
   FFS_PCIE_DONE_1 => FFS_PCIE_DONE_1,
   FFS_PCIE_DONE_2 => FFS_PCIE_DONE_2,
   FFS_PCIE_DONE_3 => FFS_PCIE_DONE_3,
   FFS_PLOL => FFS_PLOL,
   FFS_RLOL_0 => FFS_RLOL_0,
   FFS_RLOL_1 => FFS_RLOL_1,
   FFS_RLOL_2 => FFS_RLOL_2,
   FFS_RLOL_3 => FFS_RLOL_3,
   FFS_RLOS_HI_0 => FFS_RLOS_HI_0,
   FFS_RLOS_HI_1 => FFS_RLOS_HI_1,
   FFS_RLOS_HI_2 => FFS_RLOS_HI_2,
   FFS_RLOS_HI_3 => FFS_RLOS_HI_3,
   FFS_RLOS_LO_0 => FFS_RLOS_LO_0,
   FFS_RLOS_LO_1 => FFS_RLOS_LO_1,
   FFS_RLOS_LO_2 => FFS_RLOS_LO_2,
   FFS_RLOS_LO_3 => FFS_RLOS_LO_3,
   FFS_RXFBFIFO_ERROR_0 => FFS_RXFBFIFO_ERROR_0,
   FFS_RXFBFIFO_ERROR_1 => FFS_RXFBFIFO_ERROR_1,
   FFS_RXFBFIFO_ERROR_2 => FFS_RXFBFIFO_ERROR_2,
   FFS_RXFBFIFO_ERROR_3 => FFS_RXFBFIFO_ERROR_3,
   FFS_TXFBFIFO_ERROR_0 => FFS_TXFBFIFO_ERROR_0,
   FFS_TXFBFIFO_ERROR_1 => FFS_TXFBFIFO_ERROR_1,
   FFS_TXFBFIFO_ERROR_2 => FFS_TXFBFIFO_ERROR_2,
   FFS_TXFBFIFO_ERROR_3 => FFS_TXFBFIFO_ERROR_3,
   PCIE_PHYSTATUS_0 => PCIE_PHYSTATUS_0,
   PCIE_PHYSTATUS_1 => PCIE_PHYSTATUS_1,
   PCIE_PHYSTATUS_2 => PCIE_PHYSTATUS_2,
   PCIE_PHYSTATUS_3 => PCIE_PHYSTATUS_3,
   PCIE_RXVALID_0 => PCIE_RXVALID_0,
   PCIE_RXVALID_1 => PCIE_RXVALID_1,
   PCIE_RXVALID_2 => PCIE_RXVALID_2,
   PCIE_RXVALID_3 => PCIE_RXVALID_3,
   FFS_SKP_ADDED_0 => FFS_SKP_ADDED_0,
   FFS_SKP_ADDED_1 => FFS_SKP_ADDED_1,
   FFS_SKP_ADDED_2 => FFS_SKP_ADDED_2,
   FFS_SKP_ADDED_3 => FFS_SKP_ADDED_3,
   FFS_SKP_DELETED_0 => FFS_SKP_DELETED_0,
   FFS_SKP_DELETED_1 => FFS_SKP_DELETED_1,
   FFS_SKP_DELETED_2 => FFS_SKP_DELETED_2,
   FFS_SKP_DELETED_3 => FFS_SKP_DELETED_3,
   LDR_RX2CORE_0 => LDR_RX2CORE_0,
   LDR_RX2CORE_1 => LDR_RX2CORE_1,
   LDR_RX2CORE_2 => LDR_RX2CORE_2,
   LDR_RX2CORE_3 => LDR_RX2CORE_3,
   REFCK2CORE => REFCK2CORE,
   SCIINT => SCIINT,
   SCIRDATA0 => SCIRDATA0,
   SCIRDATA1 => SCIRDATA1,
   SCIRDATA2 => SCIRDATA2,
   SCIRDATA3 => SCIRDATA3,
   SCIRDATA4 => SCIRDATA4,
   SCIRDATA5 => SCIRDATA5,
   SCIRDATA6 => SCIRDATA6,
   SCIRDATA7 => SCIRDATA7,
   REFCLK_FROM_NQ => REFCLK_FROM_NQ,
   REFCLK_TO_NQ => REFCLK_TO_NQ
   );

end PCSD_arch;

--synopsys translate_on




--synopsys translate_off
library ECP3;
use ECP3.components.all;
--synopsys translate_on


library IEEE, STD;
use IEEE.std_logic_1164.all;
use STD.TEXTIO.all;

entity serdes_sync_4_slave3 is
   GENERIC (USER_CONFIG_FILE    :  String := "serdes_sync_4_slave3.txt");
 port (
------------------
-- CH0 --
    hdinp_ch0, hdinn_ch0    :   in std_logic;
    hdoutp_ch0, hdoutn_ch0   :   out std_logic;
    sci_sel_ch0    :   in std_logic;
    rxiclk_ch0    :   in std_logic;
    txiclk_ch0    :   in std_logic;
    rx_full_clk_ch0   :   out std_logic;
    rx_half_clk_ch0   :   out std_logic;
    tx_full_clk_ch0   :   out std_logic;
    tx_half_clk_ch0   :   out std_logic;
    fpga_rxrefclk_ch0    :   in std_logic;
    txdata_ch0    :   in std_logic_vector (7 downto 0);
    tx_k_ch0    :   in std_logic;
    tx_force_disp_ch0    :   in std_logic;
    tx_disp_sel_ch0    :   in std_logic;
    rxdata_ch0   :   out std_logic_vector (7 downto 0);
    rx_k_ch0   :   out std_logic;
    rx_disp_err_ch0   :   out std_logic;
    rx_cv_err_ch0   :   out std_logic;
    rx_serdes_rst_ch0_c    :   in std_logic;
    sb_felb_ch0_c    :   in std_logic;
    sb_felb_rst_ch0_c    :   in std_logic;
    tx_pcs_rst_ch0_c    :   in std_logic;
    tx_pwrup_ch0_c    :   in std_logic;
    rx_pcs_rst_ch0_c    :   in std_logic;
    rx_pwrup_ch0_c    :   in std_logic;
    rx_los_low_ch0_s   :   out std_logic;
    lsm_status_ch0_s   :   out std_logic;
    rx_cdr_lol_ch0_s   :   out std_logic;
    tx_div2_mode_ch0_c   : in std_logic;
    rx_div2_mode_ch0_c   : in std_logic;
-- CH1 --
    hdinp_ch1, hdinn_ch1    :   in std_logic;
    hdoutp_ch1, hdoutn_ch1   :   out std_logic;
    sci_sel_ch1    :   in std_logic;
    rxiclk_ch1    :   in std_logic;
    txiclk_ch1    :   in std_logic;
    rx_full_clk_ch1   :   out std_logic;
    rx_half_clk_ch1   :   out std_logic;
    tx_full_clk_ch1   :   out std_logic;
    tx_half_clk_ch1   :   out std_logic;
    fpga_rxrefclk_ch1    :   in std_logic;
    txdata_ch1    :   in std_logic_vector (7 downto 0);
    tx_k_ch1    :   in std_logic;
    tx_force_disp_ch1    :   in std_logic;
    tx_disp_sel_ch1    :   in std_logic;
    rxdata_ch1   :   out std_logic_vector (7 downto 0);
    rx_k_ch1   :   out std_logic;
    rx_disp_err_ch1   :   out std_logic;
    rx_cv_err_ch1   :   out std_logic;
    rx_serdes_rst_ch1_c    :   in std_logic;
    sb_felb_ch1_c    :   in std_logic;
    sb_felb_rst_ch1_c    :   in std_logic;
    tx_pcs_rst_ch1_c    :   in std_logic;
    tx_pwrup_ch1_c    :   in std_logic;
    rx_pcs_rst_ch1_c    :   in std_logic;
    rx_pwrup_ch1_c    :   in std_logic;
    rx_los_low_ch1_s   :   out std_logic;
    lsm_status_ch1_s   :   out std_logic;
    rx_cdr_lol_ch1_s   :   out std_logic;
    tx_div2_mode_ch1_c   : in std_logic;
    rx_div2_mode_ch1_c   : in std_logic;
-- CH2 --
    hdinp_ch2, hdinn_ch2    :   in std_logic;
    hdoutp_ch2, hdoutn_ch2   :   out std_logic;
    sci_sel_ch2    :   in std_logic;
    rxiclk_ch2    :   in std_logic;
    txiclk_ch2    :   in std_logic;
    rx_full_clk_ch2   :   out std_logic;
    rx_half_clk_ch2   :   out std_logic;
    tx_full_clk_ch2   :   out std_logic;
    tx_half_clk_ch2   :   out std_logic;
    fpga_rxrefclk_ch2    :   in std_logic;
    txdata_ch2    :   in std_logic_vector (7 downto 0);
    tx_k_ch2    :   in std_logic;
    tx_force_disp_ch2    :   in std_logic;
    tx_disp_sel_ch2    :   in std_logic;
    rxdata_ch2   :   out std_logic_vector (7 downto 0);
    rx_k_ch2   :   out std_logic;
    rx_disp_err_ch2   :   out std_logic;
    rx_cv_err_ch2   :   out std_logic;
    rx_serdes_rst_ch2_c    :   in std_logic;
    sb_felb_ch2_c    :   in std_logic;
    sb_felb_rst_ch2_c    :   in std_logic;
    tx_pcs_rst_ch2_c    :   in std_logic;
    tx_pwrup_ch2_c    :   in std_logic;
    rx_pcs_rst_ch2_c    :   in std_logic;
    rx_pwrup_ch2_c    :   in std_logic;
    rx_los_low_ch2_s   :   out std_logic;
    lsm_status_ch2_s   :   out std_logic;
    rx_cdr_lol_ch2_s   :   out std_logic;
    tx_div2_mode_ch2_c   : in std_logic;
    rx_div2_mode_ch2_c   : in std_logic;
-- CH3 --
    hdinp_ch3, hdinn_ch3    :   in std_logic;
    hdoutp_ch3, hdoutn_ch3   :   out std_logic;
    sci_sel_ch3    :   in std_logic;
    txiclk_ch3    :   in std_logic;
    rx_full_clk_ch3   :   out std_logic;
    rx_half_clk_ch3   :   out std_logic;
    tx_full_clk_ch3   :   out std_logic;
    tx_half_clk_ch3   :   out std_logic;
    fpga_rxrefclk_ch3    :   in std_logic;
    txdata_ch3    :   in std_logic_vector (7 downto 0);
    tx_k_ch3    :   in std_logic;
    tx_force_disp_ch3    :   in std_logic;
    tx_disp_sel_ch3    :   in std_logic;
    rxdata_ch3   :   out std_logic_vector (7 downto 0);
    rx_k_ch3   :   out std_logic;
    rx_disp_err_ch3   :   out std_logic;
    rx_cv_err_ch3   :   out std_logic;
    rx_serdes_rst_ch3_c    :   in std_logic;
    sb_felb_ch3_c    :   in std_logic;
    sb_felb_rst_ch3_c    :   in std_logic;
    tx_pcs_rst_ch3_c    :   in std_logic;
    tx_pwrup_ch3_c    :   in std_logic;
    rx_pcs_rst_ch3_c    :   in std_logic;
    rx_pwrup_ch3_c    :   in std_logic;
    rx_los_low_ch3_s   :   out std_logic;
    lsm_status_ch3_s   :   out std_logic;
    rx_cdr_lol_ch3_s   :   out std_logic;
    tx_div2_mode_ch3_c   : in std_logic;
    rx_div2_mode_ch3_c   : in std_logic;
---- Miscillaneous ports
    sci_wrdata    :   in std_logic_vector (7 downto 0);
    sci_addr    :   in std_logic_vector (5 downto 0);
    sci_rddata   :   out std_logic_vector (7 downto 0);
    sci_sel_quad    :   in std_logic;
    sci_rd    :   in std_logic;
    sci_wrn    :   in std_logic;
    fpga_txrefclk  :   in std_logic;
    tx_serdes_rst_c    :   in std_logic;
    tx_pll_lol_qd_s   :   out std_logic;
    tx_sync_qd_c    :   in std_logic;
    rst_qd_c    :   in std_logic;
    serdes_rst_qd_c    :   in std_logic);

end serdes_sync_4_slave3;


architecture serdes_sync_4_slave3_arch of serdes_sync_4_slave3 is

component VLO
port (
   Z : out std_logic);
end component;

component VHI
port (
   Z : out std_logic);
end component;



component PCSD
--synopsys translate_off
GENERIC(
  CONFIG_FILE : String;
  QUAD_MODE : String;
  CH0_CDR_SRC   : String := "REFCLK_EXT";
  CH1_CDR_SRC   : String := "REFCLK_EXT";
  CH2_CDR_SRC   : String := "REFCLK_EXT";
  CH3_CDR_SRC   : String := "REFCLK_EXT";
  PLL_SRC   : String
  );
--synopsys translate_on
port (
  HDINN0             : in std_logic;
  HDINN1             : in std_logic;
  HDINN2             : in std_logic;
  HDINN3             : in std_logic;
  HDINP0             : in std_logic;
  HDINP1             : in std_logic;
  HDINP2             : in std_logic;
  HDINP3             : in std_logic;
  REFCLKN             : in std_logic;
  REFCLKP             : in std_logic;
  CIN0             : in std_logic;
  CIN1             : in std_logic;
  CIN2             : in std_logic;
  CIN3             : in std_logic;
  CIN4             : in std_logic;
  CIN5             : in std_logic;
  CIN6             : in std_logic;
  CIN7             : in std_logic;
  CIN8             : in std_logic;
  CIN9             : in std_logic;
  CIN10             : in std_logic;
  CIN11             : in std_logic;
  CYAWSTN             : in std_logic;
  FF_EBRD_CLK_0             : in std_logic;
  FF_EBRD_CLK_1             : in std_logic;
  FF_EBRD_CLK_2             : in std_logic;
  FF_EBRD_CLK_3             : in std_logic;
  FF_RXI_CLK_0             : in std_logic;
  FF_RXI_CLK_1             : in std_logic;
  FF_RXI_CLK_2             : in std_logic;
  FF_RXI_CLK_3             : in std_logic;
  FF_TX_D_0_0             : in std_logic;
  FF_TX_D_0_1             : in std_logic;
  FF_TX_D_0_2             : in std_logic;
  FF_TX_D_0_3             : in std_logic;
  FF_TX_D_0_4             : in std_logic;
  FF_TX_D_0_5             : in std_logic;
  FF_TX_D_0_6             : in std_logic;
  FF_TX_D_0_7             : in std_logic;
  FF_TX_D_0_8             : in std_logic;
  FF_TX_D_0_9             : in std_logic;
  FF_TX_D_0_10             : in std_logic;
  FF_TX_D_0_11             : in std_logic;
  FF_TX_D_0_12             : in std_logic;
  FF_TX_D_0_13             : in std_logic;
  FF_TX_D_0_14             : in std_logic;
  FF_TX_D_0_15             : in std_logic;
  FF_TX_D_0_16             : in std_logic;
  FF_TX_D_0_17             : in std_logic;
  FF_TX_D_0_18             : in std_logic;
  FF_TX_D_0_19             : in std_logic;
  FF_TX_D_0_20             : in std_logic;
  FF_TX_D_0_21             : in std_logic;
  FF_TX_D_0_22             : in std_logic;
  FF_TX_D_0_23             : in std_logic;
  FF_TX_D_1_0             : in std_logic;
  FF_TX_D_1_1             : in std_logic;
  FF_TX_D_1_2             : in std_logic;
  FF_TX_D_1_3             : in std_logic;
  FF_TX_D_1_4             : in std_logic;
  FF_TX_D_1_5             : in std_logic;
  FF_TX_D_1_6             : in std_logic;
  FF_TX_D_1_7             : in std_logic;
  FF_TX_D_1_8             : in std_logic;
  FF_TX_D_1_9             : in std_logic;
  FF_TX_D_1_10             : in std_logic;
  FF_TX_D_1_11             : in std_logic;
  FF_TX_D_1_12             : in std_logic;
  FF_TX_D_1_13             : in std_logic;
  FF_TX_D_1_14             : in std_logic;
  FF_TX_D_1_15             : in std_logic;
  FF_TX_D_1_16             : in std_logic;
  FF_TX_D_1_17             : in std_logic;
  FF_TX_D_1_18             : in std_logic;
  FF_TX_D_1_19             : in std_logic;
  FF_TX_D_1_20             : in std_logic;
  FF_TX_D_1_21             : in std_logic;
  FF_TX_D_1_22             : in std_logic;
  FF_TX_D_1_23             : in std_logic;
  FF_TX_D_2_0             : in std_logic;
  FF_TX_D_2_1             : in std_logic;
  FF_TX_D_2_2             : in std_logic;
  FF_TX_D_2_3             : in std_logic;
  FF_TX_D_2_4             : in std_logic;
  FF_TX_D_2_5             : in std_logic;
  FF_TX_D_2_6             : in std_logic;
  FF_TX_D_2_7             : in std_logic;
  FF_TX_D_2_8             : in std_logic;
  FF_TX_D_2_9             : in std_logic;
  FF_TX_D_2_10             : in std_logic;
  FF_TX_D_2_11             : in std_logic;
  FF_TX_D_2_12             : in std_logic;
  FF_TX_D_2_13             : in std_logic;
  FF_TX_D_2_14             : in std_logic;
  FF_TX_D_2_15             : in std_logic;
  FF_TX_D_2_16             : in std_logic;
  FF_TX_D_2_17             : in std_logic;
  FF_TX_D_2_18             : in std_logic;
  FF_TX_D_2_19             : in std_logic;
  FF_TX_D_2_20             : in std_logic;
  FF_TX_D_2_21             : in std_logic;
  FF_TX_D_2_22             : in std_logic;
  FF_TX_D_2_23             : in std_logic;
  FF_TX_D_3_0             : in std_logic;
  FF_TX_D_3_1             : in std_logic;
  FF_TX_D_3_2             : in std_logic;
  FF_TX_D_3_3             : in std_logic;
  FF_TX_D_3_4             : in std_logic;
  FF_TX_D_3_5             : in std_logic;
  FF_TX_D_3_6             : in std_logic;
  FF_TX_D_3_7             : in std_logic;
  FF_TX_D_3_8             : in std_logic;
  FF_TX_D_3_9             : in std_logic;
  FF_TX_D_3_10             : in std_logic;
  FF_TX_D_3_11             : in std_logic;
  FF_TX_D_3_12             : in std_logic;
  FF_TX_D_3_13             : in std_logic;
  FF_TX_D_3_14             : in std_logic;
  FF_TX_D_3_15             : in std_logic;
  FF_TX_D_3_16             : in std_logic;
  FF_TX_D_3_17             : in std_logic;
  FF_TX_D_3_18             : in std_logic;
  FF_TX_D_3_19             : in std_logic;
  FF_TX_D_3_20             : in std_logic;
  FF_TX_D_3_21             : in std_logic;
  FF_TX_D_3_22             : in std_logic;
  FF_TX_D_3_23             : in std_logic;
  FF_TXI_CLK_0             : in std_logic;
  FF_TXI_CLK_1             : in std_logic;
  FF_TXI_CLK_2             : in std_logic;
  FF_TXI_CLK_3             : in std_logic;
  FFC_CK_CORE_RX_0         : in std_logic;
  FFC_CK_CORE_RX_1         : in std_logic;
  FFC_CK_CORE_RX_2         : in std_logic;
  FFC_CK_CORE_RX_3         : in std_logic;
  FFC_CK_CORE_TX           : in std_logic;
  FFC_EI_EN_0             : in std_logic;
  FFC_EI_EN_1             : in std_logic;
  FFC_EI_EN_2             : in std_logic;
  FFC_EI_EN_3             : in std_logic;
  FFC_ENABLE_CGALIGN_0             : in std_logic;
  FFC_ENABLE_CGALIGN_1             : in std_logic;
  FFC_ENABLE_CGALIGN_2             : in std_logic;
  FFC_ENABLE_CGALIGN_3             : in std_logic;
  FFC_FB_LOOPBACK_0             : in std_logic;
  FFC_FB_LOOPBACK_1             : in std_logic;
  FFC_FB_LOOPBACK_2             : in std_logic;
  FFC_FB_LOOPBACK_3             : in std_logic;
  FFC_LANE_RX_RST_0             : in std_logic;
  FFC_LANE_RX_RST_1             : in std_logic;
  FFC_LANE_RX_RST_2             : in std_logic;
  FFC_LANE_RX_RST_3             : in std_logic;
  FFC_LANE_TX_RST_0             : in std_logic;
  FFC_LANE_TX_RST_1             : in std_logic;
  FFC_LANE_TX_RST_2             : in std_logic;
  FFC_LANE_TX_RST_3             : in std_logic;
  FFC_MACRO_RST             : in std_logic;
  FFC_PCI_DET_EN_0             : in std_logic;
  FFC_PCI_DET_EN_1             : in std_logic;
  FFC_PCI_DET_EN_2             : in std_logic;
  FFC_PCI_DET_EN_3             : in std_logic;
  FFC_PCIE_CT_0             : in std_logic;
  FFC_PCIE_CT_1             : in std_logic;
  FFC_PCIE_CT_2             : in std_logic;
  FFC_PCIE_CT_3             : in std_logic;
  FFC_PFIFO_CLR_0             : in std_logic;
  FFC_PFIFO_CLR_1             : in std_logic;
  FFC_PFIFO_CLR_2             : in std_logic;
  FFC_PFIFO_CLR_3             : in std_logic;
  FFC_QUAD_RST             : in std_logic;
  FFC_RRST_0             : in std_logic;
  FFC_RRST_1             : in std_logic;
  FFC_RRST_2             : in std_logic;
  FFC_RRST_3             : in std_logic;
  FFC_RXPWDNB_0             : in std_logic;
  FFC_RXPWDNB_1             : in std_logic;
  FFC_RXPWDNB_2             : in std_logic;
  FFC_RXPWDNB_3             : in std_logic;
  FFC_SB_INV_RX_0             : in std_logic;
  FFC_SB_INV_RX_1             : in std_logic;
  FFC_SB_INV_RX_2             : in std_logic;
  FFC_SB_INV_RX_3             : in std_logic;
  FFC_SB_PFIFO_LP_0             : in std_logic;
  FFC_SB_PFIFO_LP_1             : in std_logic;
  FFC_SB_PFIFO_LP_2             : in std_logic;
  FFC_SB_PFIFO_LP_3             : in std_logic;
  FFC_SIGNAL_DETECT_0             : in std_logic;
  FFC_SIGNAL_DETECT_1             : in std_logic;
  FFC_SIGNAL_DETECT_2             : in std_logic;
  FFC_SIGNAL_DETECT_3             : in std_logic;
  FFC_SYNC_TOGGLE             : in std_logic;
  FFC_TRST             : in std_logic;
  FFC_TXPWDNB_0             : in std_logic;
  FFC_TXPWDNB_1             : in std_logic;
  FFC_TXPWDNB_2             : in std_logic;
  FFC_TXPWDNB_3             : in std_logic;
  FFC_RATE_MODE_RX_0        : in std_logic;
  FFC_RATE_MODE_RX_1        : in std_logic;
  FFC_RATE_MODE_RX_2        : in std_logic;
  FFC_RATE_MODE_RX_3        : in std_logic;
  FFC_RATE_MODE_TX_0        : in std_logic;
  FFC_RATE_MODE_TX_1        : in std_logic;
  FFC_RATE_MODE_TX_2        : in std_logic;
  FFC_RATE_MODE_TX_3        : in std_logic;
  FFC_DIV11_MODE_RX_0       : in std_logic;
  FFC_DIV11_MODE_RX_1       : in std_logic;
  FFC_DIV11_MODE_RX_2       : in std_logic;
  FFC_DIV11_MODE_RX_3       : in std_logic;
  FFC_DIV11_MODE_TX_0       : in std_logic;
  FFC_DIV11_MODE_TX_1       : in std_logic;
  FFC_DIV11_MODE_TX_2       : in std_logic;
  FFC_DIV11_MODE_TX_3       : in std_logic;
  LDR_CORE2TX_0             : in std_logic;
  LDR_CORE2TX_1             : in std_logic;
  LDR_CORE2TX_2             : in std_logic;
  LDR_CORE2TX_3             : in std_logic;
  FFC_LDR_CORE2TX_EN_0      : in std_logic;
  FFC_LDR_CORE2TX_EN_1      : in std_logic;
  FFC_LDR_CORE2TX_EN_2      : in std_logic;
  FFC_LDR_CORE2TX_EN_3      : in std_logic;
  PCIE_POWERDOWN_0_0      : in std_logic;
  PCIE_POWERDOWN_0_1      : in std_logic;
  PCIE_POWERDOWN_1_0      : in std_logic;
  PCIE_POWERDOWN_1_1      : in std_logic;
  PCIE_POWERDOWN_2_0      : in std_logic;
  PCIE_POWERDOWN_2_1      : in std_logic;
  PCIE_POWERDOWN_3_0      : in std_logic;
  PCIE_POWERDOWN_3_1      : in std_logic;
  PCIE_RXPOLARITY_0         : in std_logic;
  PCIE_RXPOLARITY_1         : in std_logic;
  PCIE_RXPOLARITY_2         : in std_logic;
  PCIE_RXPOLARITY_3         : in std_logic;
  PCIE_TXCOMPLIANCE_0       : in std_logic;
  PCIE_TXCOMPLIANCE_1       : in std_logic;
  PCIE_TXCOMPLIANCE_2       : in std_logic;
  PCIE_TXCOMPLIANCE_3       : in std_logic;
  PCIE_TXDETRX_PR2TLB_0     : in std_logic;
  PCIE_TXDETRX_PR2TLB_1     : in std_logic;
  PCIE_TXDETRX_PR2TLB_2     : in std_logic;
  PCIE_TXDETRX_PR2TLB_3     : in std_logic;
  SCIADDR0             : in std_logic;
  SCIADDR1             : in std_logic;
  SCIADDR2             : in std_logic;
  SCIADDR3             : in std_logic;
  SCIADDR4             : in std_logic;
  SCIADDR5             : in std_logic;
  SCIENAUX             : in std_logic;
  SCIENCH0             : in std_logic;
  SCIENCH1             : in std_logic;
  SCIENCH2             : in std_logic;
  SCIENCH3             : in std_logic;
  SCIRD                : in std_logic;
  SCISELAUX             : in std_logic;
  SCISELCH0             : in std_logic;
  SCISELCH1             : in std_logic;
  SCISELCH2             : in std_logic;
  SCISELCH3             : in std_logic;
  SCIWDATA0             : in std_logic;
  SCIWDATA1             : in std_logic;
  SCIWDATA2             : in std_logic;
  SCIWDATA3             : in std_logic;
  SCIWDATA4             : in std_logic;
  SCIWDATA5             : in std_logic;
  SCIWDATA6             : in std_logic;
  SCIWDATA7             : in std_logic;
  SCIWSTN               : in std_logic;
  REFCLK_FROM_NQ        : in std_logic;
  HDOUTN0             : out std_logic;
  HDOUTN1             : out std_logic;
  HDOUTN2             : out std_logic;
  HDOUTN3             : out std_logic;
  HDOUTP0             : out std_logic;
  HDOUTP1             : out std_logic;
  HDOUTP2             : out std_logic;
  HDOUTP3             : out std_logic;
  COUT0             : out std_logic;
  COUT1             : out std_logic;
  COUT2             : out std_logic;
  COUT3             : out std_logic;
  COUT4             : out std_logic;
  COUT5             : out std_logic;
  COUT6             : out std_logic;
  COUT7             : out std_logic;
  COUT8             : out std_logic;
  COUT9             : out std_logic;
  COUT10             : out std_logic;
  COUT11             : out std_logic;
  COUT12             : out std_logic;
  COUT13             : out std_logic;
  COUT14             : out std_logic;
  COUT15             : out std_logic;
  COUT16             : out std_logic;
  COUT17             : out std_logic;
  COUT18             : out std_logic;
  COUT19             : out std_logic;
  FF_RX_D_0_0             : out std_logic;
  FF_RX_D_0_1             : out std_logic;
  FF_RX_D_0_2             : out std_logic;
  FF_RX_D_0_3             : out std_logic;
  FF_RX_D_0_4             : out std_logic;
  FF_RX_D_0_5             : out std_logic;
  FF_RX_D_0_6             : out std_logic;
  FF_RX_D_0_7             : out std_logic;
  FF_RX_D_0_8             : out std_logic;
  FF_RX_D_0_9             : out std_logic;
  FF_RX_D_0_10             : out std_logic;
  FF_RX_D_0_11             : out std_logic;
  FF_RX_D_0_12             : out std_logic;
  FF_RX_D_0_13             : out std_logic;
  FF_RX_D_0_14             : out std_logic;
  FF_RX_D_0_15             : out std_logic;
  FF_RX_D_0_16             : out std_logic;
  FF_RX_D_0_17             : out std_logic;
  FF_RX_D_0_18             : out std_logic;
  FF_RX_D_0_19             : out std_logic;
  FF_RX_D_0_20             : out std_logic;
  FF_RX_D_0_21             : out std_logic;
  FF_RX_D_0_22             : out std_logic;
  FF_RX_D_0_23             : out std_logic;
  FF_RX_D_1_0             : out std_logic;
  FF_RX_D_1_1             : out std_logic;
  FF_RX_D_1_2             : out std_logic;
  FF_RX_D_1_3             : out std_logic;
  FF_RX_D_1_4             : out std_logic;
  FF_RX_D_1_5             : out std_logic;
  FF_RX_D_1_6             : out std_logic;
  FF_RX_D_1_7             : out std_logic;
  FF_RX_D_1_8             : out std_logic;
  FF_RX_D_1_9             : out std_logic;
  FF_RX_D_1_10             : out std_logic;
  FF_RX_D_1_11             : out std_logic;
  FF_RX_D_1_12             : out std_logic;
  FF_RX_D_1_13             : out std_logic;
  FF_RX_D_1_14             : out std_logic;
  FF_RX_D_1_15             : out std_logic;
  FF_RX_D_1_16             : out std_logic;
  FF_RX_D_1_17             : out std_logic;
  FF_RX_D_1_18             : out std_logic;
  FF_RX_D_1_19             : out std_logic;
  FF_RX_D_1_20             : out std_logic;
  FF_RX_D_1_21             : out std_logic;
  FF_RX_D_1_22             : out std_logic;
  FF_RX_D_1_23             : out std_logic;
  FF_RX_D_2_0             : out std_logic;
  FF_RX_D_2_1             : out std_logic;
  FF_RX_D_2_2             : out std_logic;
  FF_RX_D_2_3             : out std_logic;
  FF_RX_D_2_4             : out std_logic;
  FF_RX_D_2_5             : out std_logic;
  FF_RX_D_2_6             : out std_logic;
  FF_RX_D_2_7             : out std_logic;
  FF_RX_D_2_8             : out std_logic;
  FF_RX_D_2_9             : out std_logic;
  FF_RX_D_2_10             : out std_logic;
  FF_RX_D_2_11             : out std_logic;
  FF_RX_D_2_12             : out std_logic;
  FF_RX_D_2_13             : out std_logic;
  FF_RX_D_2_14             : out std_logic;
  FF_RX_D_2_15             : out std_logic;
  FF_RX_D_2_16             : out std_logic;
  FF_RX_D_2_17             : out std_logic;
  FF_RX_D_2_18             : out std_logic;
  FF_RX_D_2_19             : out std_logic;
  FF_RX_D_2_20             : out std_logic;
  FF_RX_D_2_21             : out std_logic;
  FF_RX_D_2_22             : out std_logic;
  FF_RX_D_2_23             : out std_logic;
  FF_RX_D_3_0             : out std_logic;
  FF_RX_D_3_1             : out std_logic;
  FF_RX_D_3_2             : out std_logic;
  FF_RX_D_3_3             : out std_logic;
  FF_RX_D_3_4             : out std_logic;
  FF_RX_D_3_5             : out std_logic;
  FF_RX_D_3_6             : out std_logic;
  FF_RX_D_3_7             : out std_logic;
  FF_RX_D_3_8             : out std_logic;
  FF_RX_D_3_9             : out std_logic;
  FF_RX_D_3_10             : out std_logic;
  FF_RX_D_3_11             : out std_logic;
  FF_RX_D_3_12             : out std_logic;
  FF_RX_D_3_13             : out std_logic;
  FF_RX_D_3_14             : out std_logic;
  FF_RX_D_3_15             : out std_logic;
  FF_RX_D_3_16             : out std_logic;
  FF_RX_D_3_17             : out std_logic;
  FF_RX_D_3_18             : out std_logic;
  FF_RX_D_3_19             : out std_logic;
  FF_RX_D_3_20             : out std_logic;
  FF_RX_D_3_21             : out std_logic;
  FF_RX_D_3_22             : out std_logic;
  FF_RX_D_3_23             : out std_logic;
  FF_RX_F_CLK_0             : out std_logic;
  FF_RX_F_CLK_1             : out std_logic;
  FF_RX_F_CLK_2             : out std_logic;
  FF_RX_F_CLK_3             : out std_logic;
  FF_RX_H_CLK_0             : out std_logic;
  FF_RX_H_CLK_1             : out std_logic;
  FF_RX_H_CLK_2             : out std_logic;
  FF_RX_H_CLK_3             : out std_logic;
  FF_TX_F_CLK_0             : out std_logic;
  FF_TX_F_CLK_1             : out std_logic;
  FF_TX_F_CLK_2             : out std_logic;
  FF_TX_F_CLK_3             : out std_logic;
  FF_TX_H_CLK_0             : out std_logic;
  FF_TX_H_CLK_1             : out std_logic;
  FF_TX_H_CLK_2             : out std_logic;
  FF_TX_H_CLK_3             : out std_logic;
  FFS_CC_OVERRUN_0             : out std_logic;
  FFS_CC_OVERRUN_1             : out std_logic;
  FFS_CC_OVERRUN_2             : out std_logic;
  FFS_CC_OVERRUN_3             : out std_logic;
  FFS_CC_UNDERRUN_0             : out std_logic;
  FFS_CC_UNDERRUN_1             : out std_logic;
  FFS_CC_UNDERRUN_2             : out std_logic;
  FFS_CC_UNDERRUN_3             : out std_logic;
  FFS_LS_SYNC_STATUS_0             : out std_logic;
  FFS_LS_SYNC_STATUS_1             : out std_logic;
  FFS_LS_SYNC_STATUS_2             : out std_logic;
  FFS_LS_SYNC_STATUS_3             : out std_logic;
  FFS_CDR_TRAIN_DONE_0             : out std_logic;
  FFS_CDR_TRAIN_DONE_1             : out std_logic;
  FFS_CDR_TRAIN_DONE_2             : out std_logic;
  FFS_CDR_TRAIN_DONE_3             : out std_logic;
  FFS_PCIE_CON_0             : out std_logic;
  FFS_PCIE_CON_1             : out std_logic;
  FFS_PCIE_CON_2             : out std_logic;
  FFS_PCIE_CON_3             : out std_logic;
  FFS_PCIE_DONE_0             : out std_logic;
  FFS_PCIE_DONE_1             : out std_logic;
  FFS_PCIE_DONE_2             : out std_logic;
  FFS_PCIE_DONE_3             : out std_logic;
  FFS_PLOL             : out std_logic;
  FFS_RLOL_0             : out std_logic;
  FFS_RLOL_1             : out std_logic;
  FFS_RLOL_2             : out std_logic;
  FFS_RLOL_3             : out std_logic;
  FFS_RLOS_HI_0             : out std_logic;
  FFS_RLOS_HI_1             : out std_logic;
  FFS_RLOS_HI_2             : out std_logic;
  FFS_RLOS_HI_3             : out std_logic;
  FFS_RLOS_LO_0             : out std_logic;
  FFS_RLOS_LO_1             : out std_logic;
  FFS_RLOS_LO_2             : out std_logic;
  FFS_RLOS_LO_3             : out std_logic;
  FFS_RXFBFIFO_ERROR_0             : out std_logic;
  FFS_RXFBFIFO_ERROR_1             : out std_logic;
  FFS_RXFBFIFO_ERROR_2             : out std_logic;
  FFS_RXFBFIFO_ERROR_3             : out std_logic;
  FFS_TXFBFIFO_ERROR_0             : out std_logic;
  FFS_TXFBFIFO_ERROR_1             : out std_logic;
  FFS_TXFBFIFO_ERROR_2             : out std_logic;
  FFS_TXFBFIFO_ERROR_3             : out std_logic;
  PCIE_PHYSTATUS_0             : out std_logic;
  PCIE_PHYSTATUS_1             : out std_logic;
  PCIE_PHYSTATUS_2             : out std_logic;
  PCIE_PHYSTATUS_3             : out std_logic;
  PCIE_RXVALID_0               : out std_logic;
  PCIE_RXVALID_1               : out std_logic;
  PCIE_RXVALID_2               : out std_logic;
  PCIE_RXVALID_3               : out std_logic;
  FFS_SKP_ADDED_0                  : out std_logic;
  FFS_SKP_ADDED_1                  : out std_logic;
  FFS_SKP_ADDED_2                  : out std_logic;
  FFS_SKP_ADDED_3                  : out std_logic;
  FFS_SKP_DELETED_0                : out std_logic;
  FFS_SKP_DELETED_1                : out std_logic;
  FFS_SKP_DELETED_2                : out std_logic;
  FFS_SKP_DELETED_3                : out std_logic;
  LDR_RX2CORE_0                    : out std_logic;
  LDR_RX2CORE_1                    : out std_logic;
  LDR_RX2CORE_2                    : out std_logic;
  LDR_RX2CORE_3                    : out std_logic;
  REFCK2CORE             : out std_logic;
  SCIINT                : out std_logic;
  SCIRDATA0             : out std_logic;
  SCIRDATA1             : out std_logic;
  SCIRDATA2             : out std_logic;
  SCIRDATA3             : out std_logic;
  SCIRDATA4             : out std_logic;
  SCIRDATA5             : out std_logic;
  SCIRDATA6             : out std_logic;
  SCIRDATA7             : out std_logic;
  REFCLK_TO_NQ          : out std_logic
);
end component;
   attribute CONFIG_FILE: string;
   attribute CONFIG_FILE of PCSD_INST : label is USER_CONFIG_FILE;
   attribute QUAD_MODE: string;
   attribute QUAD_MODE of PCSD_INST : label is "SINGLE";
   attribute PLL_SRC: string;
   attribute PLL_SRC of PCSD_INST : label is "REFCLK_CORE";
   attribute CH0_CDR_SRC: string;
   attribute CH0_CDR_SRC of PCSD_INST : label is "REFCLK_CORE";
   attribute CH1_CDR_SRC: string;
   attribute CH1_CDR_SRC of PCSD_INST : label is "REFCLK_CORE";
   attribute CH2_CDR_SRC: string;
   attribute CH2_CDR_SRC of PCSD_INST : label is "REFCLK_CORE";
   attribute CH3_CDR_SRC: string;
   attribute CH3_CDR_SRC of PCSD_INST : label is "REFCLK_CORE";
   attribute FREQUENCY_PIN_FF_RX_F_CLK_0: string;
   attribute FREQUENCY_PIN_FF_RX_F_CLK_0 of PCSD_INST : label is "200";
   attribute FREQUENCY_PIN_FF_RX_F_CLK_1: string;
   attribute FREQUENCY_PIN_FF_RX_F_CLK_1 of PCSD_INST : label is "200";
   attribute FREQUENCY_PIN_FF_RX_F_CLK_2: string;
   attribute FREQUENCY_PIN_FF_RX_F_CLK_2 of PCSD_INST : label is "200";
   attribute FREQUENCY_PIN_FF_RX_F_CLK_3: string;
   attribute FREQUENCY_PIN_FF_RX_F_CLK_3 of PCSD_INST : label is "200";
   attribute FREQUENCY_PIN_FF_RX_H_CLK_0: string;
   attribute FREQUENCY_PIN_FF_RX_H_CLK_0 of PCSD_INST : label is "100";
   attribute FREQUENCY_PIN_FF_RX_H_CLK_1: string;
   attribute FREQUENCY_PIN_FF_RX_H_CLK_1 of PCSD_INST : label is "100";
   attribute FREQUENCY_PIN_FF_RX_H_CLK_2: string;
   attribute FREQUENCY_PIN_FF_RX_H_CLK_2 of PCSD_INST : label is "100";
   attribute FREQUENCY_PIN_FF_RX_H_CLK_3: string;
   attribute FREQUENCY_PIN_FF_RX_H_CLK_3 of PCSD_INST : label is "100";
   attribute FREQUENCY_PIN_FF_TX_F_CLK_0: string;
   attribute FREQUENCY_PIN_FF_TX_F_CLK_0 of PCSD_INST : label is "200";
   attribute FREQUENCY_PIN_FF_TX_F_CLK_1: string;
   attribute FREQUENCY_PIN_FF_TX_F_CLK_1 of PCSD_INST : label is "200";
   attribute FREQUENCY_PIN_FF_TX_F_CLK_2: string;
   attribute FREQUENCY_PIN_FF_TX_F_CLK_2 of PCSD_INST : label is "200";
   attribute FREQUENCY_PIN_FF_TX_F_CLK_3: string;
   attribute FREQUENCY_PIN_FF_TX_F_CLK_3 of PCSD_INST : label is "200";
   attribute FREQUENCY_PIN_FF_TX_H_CLK_0: string;
   attribute FREQUENCY_PIN_FF_TX_H_CLK_0 of PCSD_INST : label is "100";
   attribute FREQUENCY_PIN_FF_TX_H_CLK_1: string;
   attribute FREQUENCY_PIN_FF_TX_H_CLK_1 of PCSD_INST : label is "100";
   attribute FREQUENCY_PIN_FF_TX_H_CLK_2: string;
   attribute FREQUENCY_PIN_FF_TX_H_CLK_2 of PCSD_INST : label is "100";
   attribute FREQUENCY_PIN_FF_TX_H_CLK_3: string;
   attribute FREQUENCY_PIN_FF_TX_H_CLK_3 of PCSD_INST : label is "100";
   attribute black_box_pad_pin: string;
   attribute black_box_pad_pin of PCSD : component is "HDINP0, HDINN0, HDINP1, HDINN1, HDINP2, HDINN2, HDINP3, HDINN3, HDOUTP0, HDOUTN0, HDOUTP1, HDOUTN1, HDOUTP2, HDOUTN2, HDOUTP3, HDOUTN3, REFCLKP, REFCLKN";

signal refclk_from_nq : std_logic := '0';
signal fpsc_vlo : std_logic := '0';
signal fpsc_vhi : std_logic := '1';
signal cin : std_logic_vector (11 downto 0) := "000000000000";
signal cout : std_logic_vector (19 downto 0);
signal    tx_full_clk_ch0_sig   :   std_logic;
signal    tx_full_clk_ch1_sig   :   std_logic;
signal    tx_full_clk_ch2_sig   :   std_logic;
signal    tx_full_clk_ch3_sig   :   std_logic;

signal    refclk2fpga_sig  :   std_logic;
signal    tx_pll_lol_qd_sig  :   std_logic;
signal    rx_los_low_ch0_sig  :   std_logic;
signal    rx_los_low_ch1_sig  :   std_logic;
signal    rx_los_low_ch2_sig  :   std_logic;
signal    rx_los_low_ch3_sig  :   std_logic;
signal    rx_cdr_lol_ch0_sig  :   std_logic;
signal    rx_cdr_lol_ch1_sig  :   std_logic;
signal    rx_cdr_lol_ch2_sig  :   std_logic;
signal    rx_cdr_lol_ch3_sig  :   std_logic;





begin

vlo_inst : VLO port map(Z => fpsc_vlo);
vhi_inst : VHI port map(Z => fpsc_vhi);

    rx_los_low_ch0_s <= rx_los_low_ch0_sig;
    rx_los_low_ch1_s <= rx_los_low_ch1_sig;
    rx_los_low_ch2_s <= rx_los_low_ch2_sig;
    rx_los_low_ch3_s <= rx_los_low_ch3_sig;
    rx_cdr_lol_ch0_s <= rx_cdr_lol_ch0_sig;
    rx_cdr_lol_ch1_s <= rx_cdr_lol_ch1_sig;
    rx_cdr_lol_ch2_s <= rx_cdr_lol_ch2_sig;
    rx_cdr_lol_ch3_s <= rx_cdr_lol_ch3_sig;
  tx_pll_lol_qd_s <= tx_pll_lol_qd_sig;
  tx_full_clk_ch0 <= tx_full_clk_ch0_sig;
  tx_full_clk_ch1 <= tx_full_clk_ch1_sig;
  tx_full_clk_ch2 <= tx_full_clk_ch2_sig;
  tx_full_clk_ch3 <= tx_full_clk_ch3_sig;

-- pcs_quad instance
PCSD_INST : PCSD
--synopsys translate_off
  generic map (CONFIG_FILE => USER_CONFIG_FILE,
               QUAD_MODE => "SINGLE",
               CH0_CDR_SRC => "REFCLK_CORE",
               CH1_CDR_SRC => "REFCLK_CORE",
               CH2_CDR_SRC => "REFCLK_CORE",
               CH3_CDR_SRC => "REFCLK_CORE",
               PLL_SRC  => "REFCLK_CORE"
  )
--synopsys translate_on
port map  (
  REFCLKP => fpsc_vlo,
  REFCLKN => fpsc_vlo,

----- CH0 -----
  HDOUTP0 => hdoutp_ch0,
  HDOUTN0 => hdoutn_ch0,
  HDINP0 => hdinp_ch0,
  HDINN0 => hdinn_ch0,
  PCIE_TXDETRX_PR2TLB_0 => fpsc_vlo,
  PCIE_TXCOMPLIANCE_0 => fpsc_vlo,
  PCIE_RXPOLARITY_0 => fpsc_vlo,
  PCIE_POWERDOWN_0_0 => fpsc_vlo,
  PCIE_POWERDOWN_0_1 => fpsc_vlo,
  PCIE_RXVALID_0 => open,
  PCIE_PHYSTATUS_0 => open,
  SCISELCH0 => sci_sel_ch0,
  SCIENCH0 => fpsc_vhi,
  FF_RXI_CLK_0 => rxiclk_ch0,
  FF_TXI_CLK_0 => txiclk_ch0,
  FF_EBRD_CLK_0 => fpsc_vlo,
  FF_RX_F_CLK_0 => rx_full_clk_ch0,
  FF_RX_H_CLK_0 => rx_half_clk_ch0,
  FF_TX_F_CLK_0 => tx_full_clk_ch0_sig,
  FF_TX_H_CLK_0 => tx_half_clk_ch0,
  FFC_CK_CORE_RX_0 => fpga_rxrefclk_ch0,
  FF_TX_D_0_0 => txdata_ch0(0),
  FF_TX_D_0_1 => txdata_ch0(1),
  FF_TX_D_0_2 => txdata_ch0(2),
  FF_TX_D_0_3 => txdata_ch0(3),
  FF_TX_D_0_4 => txdata_ch0(4),
  FF_TX_D_0_5 => txdata_ch0(5),
  FF_TX_D_0_6 => txdata_ch0(6),
  FF_TX_D_0_7 => txdata_ch0(7),
  FF_TX_D_0_8 => tx_k_ch0,
  FF_TX_D_0_9 => tx_force_disp_ch0,
  FF_TX_D_0_10 => tx_disp_sel_ch0,
  FF_TX_D_0_11 => fpsc_vlo,
  FF_TX_D_0_12 => fpsc_vlo,
  FF_TX_D_0_13 => fpsc_vlo,
  FF_TX_D_0_14 => fpsc_vlo,
  FF_TX_D_0_15 => fpsc_vlo,
  FF_TX_D_0_16 => fpsc_vlo,
  FF_TX_D_0_17 => fpsc_vlo,
  FF_TX_D_0_18 => fpsc_vlo,
  FF_TX_D_0_19 => fpsc_vlo,
  FF_TX_D_0_20 => fpsc_vlo,
  FF_TX_D_0_21 => fpsc_vlo,
  FF_TX_D_0_22 => fpsc_vlo,
  FF_TX_D_0_23 => fpsc_vlo,
  FF_RX_D_0_0 => rxdata_ch0(0),
  FF_RX_D_0_1 => rxdata_ch0(1),
  FF_RX_D_0_2 => rxdata_ch0(2),
  FF_RX_D_0_3 => rxdata_ch0(3),
  FF_RX_D_0_4 => rxdata_ch0(4),
  FF_RX_D_0_5 => rxdata_ch0(5),
  FF_RX_D_0_6 => rxdata_ch0(6),
  FF_RX_D_0_7 => rxdata_ch0(7),
  FF_RX_D_0_8 => rx_k_ch0,
  FF_RX_D_0_9 => rx_disp_err_ch0,
  FF_RX_D_0_10 => rx_cv_err_ch0,
  FF_RX_D_0_11 => open,
  FF_RX_D_0_12 => open,
  FF_RX_D_0_13 => open,
  FF_RX_D_0_14 => open,
  FF_RX_D_0_15 => open,
  FF_RX_D_0_16 => open,
  FF_RX_D_0_17 => open,
  FF_RX_D_0_18 => open,
  FF_RX_D_0_19 => open,
  FF_RX_D_0_20 => open,
  FF_RX_D_0_21 => open,
  FF_RX_D_0_22 => open,
  FF_RX_D_0_23 => open,

  FFC_RRST_0 => rx_serdes_rst_ch0_c,
  FFC_SIGNAL_DETECT_0 => fpsc_vlo,
  FFC_SB_PFIFO_LP_0 => sb_felb_ch0_c,
  FFC_PFIFO_CLR_0 => sb_felb_rst_ch0_c,
  FFC_SB_INV_RX_0 => fpsc_vlo,
  FFC_PCIE_CT_0 => fpsc_vlo,
  FFC_PCI_DET_EN_0 => fpsc_vlo,
  FFC_FB_LOOPBACK_0 => fpsc_vlo,
  FFC_ENABLE_CGALIGN_0 => fpsc_vlo,
  FFC_EI_EN_0 => fpsc_vlo,
  FFC_LANE_TX_RST_0 => tx_pcs_rst_ch0_c,
  FFC_TXPWDNB_0 => tx_pwrup_ch0_c,
  FFC_LANE_RX_RST_0 => rx_pcs_rst_ch0_c,
  FFC_RXPWDNB_0 => rx_pwrup_ch0_c,
  FFS_RLOS_LO_0 => rx_los_low_ch0_sig,
  FFS_RLOS_HI_0 => open,
  FFS_PCIE_CON_0 => open,
  FFS_PCIE_DONE_0 => open,
  FFS_LS_SYNC_STATUS_0 => lsm_status_ch0_s,
  FFS_CC_OVERRUN_0 => open,
  FFS_CC_UNDERRUN_0 => open,
  FFS_SKP_ADDED_0 => open,
  FFS_SKP_DELETED_0 => open,
  FFS_RLOL_0 => rx_cdr_lol_ch0_sig,
  FFS_RXFBFIFO_ERROR_0 => open,
  FFS_TXFBFIFO_ERROR_0 => open,
  LDR_CORE2TX_0 => fpsc_vlo,
  FFC_LDR_CORE2TX_EN_0 => fpsc_vlo,
  LDR_RX2CORE_0 => open,
  FFS_CDR_TRAIN_DONE_0 => open,
  FFC_DIV11_MODE_TX_0 => fpsc_vlo,
  FFC_RATE_MODE_TX_0 => tx_div2_mode_ch0_c,
  FFC_DIV11_MODE_RX_0 => fpsc_vlo,
  FFC_RATE_MODE_RX_0 => rx_div2_mode_ch0_c,

----- CH1 -----
  HDOUTP1 => hdoutp_ch1,
  HDOUTN1 => hdoutn_ch1,
  HDINP1 => hdinp_ch1,
  HDINN1 => hdinn_ch1,
  PCIE_TXDETRX_PR2TLB_1 => fpsc_vlo,
  PCIE_TXCOMPLIANCE_1 => fpsc_vlo,
  PCIE_RXPOLARITY_1 => fpsc_vlo,
  PCIE_POWERDOWN_1_0 => fpsc_vlo,
  PCIE_POWERDOWN_1_1 => fpsc_vlo,
  PCIE_RXVALID_1 => open,
  PCIE_PHYSTATUS_1 => open,
  SCISELCH1 => sci_sel_ch1,
  SCIENCH1 => fpsc_vhi,
  FF_RXI_CLK_1 => rxiclk_ch1,
  FF_TXI_CLK_1 => txiclk_ch1,
  FF_EBRD_CLK_1 => fpsc_vlo,
  FF_RX_F_CLK_1 => rx_full_clk_ch1,
  FF_RX_H_CLK_1 => rx_half_clk_ch1,
  FF_TX_F_CLK_1 => tx_full_clk_ch1_sig,
  FF_TX_H_CLK_1 => tx_half_clk_ch1,
  FFC_CK_CORE_RX_1 => fpga_rxrefclk_ch1,
  FF_TX_D_1_0 => txdata_ch1(0),
  FF_TX_D_1_1 => txdata_ch1(1),
  FF_TX_D_1_2 => txdata_ch1(2),
  FF_TX_D_1_3 => txdata_ch1(3),
  FF_TX_D_1_4 => txdata_ch1(4),
  FF_TX_D_1_5 => txdata_ch1(5),
  FF_TX_D_1_6 => txdata_ch1(6),
  FF_TX_D_1_7 => txdata_ch1(7),
  FF_TX_D_1_8 => tx_k_ch1,
  FF_TX_D_1_9 => tx_force_disp_ch1,
  FF_TX_D_1_10 => tx_disp_sel_ch1,
  FF_TX_D_1_11 => fpsc_vlo,
  FF_TX_D_1_12 => fpsc_vlo,
  FF_TX_D_1_13 => fpsc_vlo,
  FF_TX_D_1_14 => fpsc_vlo,
  FF_TX_D_1_15 => fpsc_vlo,
  FF_TX_D_1_16 => fpsc_vlo,
  FF_TX_D_1_17 => fpsc_vlo,
  FF_TX_D_1_18 => fpsc_vlo,
  FF_TX_D_1_19 => fpsc_vlo,
  FF_TX_D_1_20 => fpsc_vlo,
  FF_TX_D_1_21 => fpsc_vlo,
  FF_TX_D_1_22 => fpsc_vlo,
  FF_TX_D_1_23 => fpsc_vlo,
  FF_RX_D_1_0 => rxdata_ch1(0),
  FF_RX_D_1_1 => rxdata_ch1(1),
  FF_RX_D_1_2 => rxdata_ch1(2),
  FF_RX_D_1_3 => rxdata_ch1(3),
  FF_RX_D_1_4 => rxdata_ch1(4),
  FF_RX_D_1_5 => rxdata_ch1(5),
  FF_RX_D_1_6 => rxdata_ch1(6),
  FF_RX_D_1_7 => rxdata_ch1(7),
  FF_RX_D_1_8 => rx_k_ch1,
  FF_RX_D_1_9 => rx_disp_err_ch1,
  FF_RX_D_1_10 => rx_cv_err_ch1,
  FF_RX_D_1_11 => open,
  FF_RX_D_1_12 => open,
  FF_RX_D_1_13 => open,
  FF_RX_D_1_14 => open,
  FF_RX_D_1_15 => open,
  FF_RX_D_1_16 => open,
  FF_RX_D_1_17 => open,
  FF_RX_D_1_18 => open,
  FF_RX_D_1_19 => open,
  FF_RX_D_1_20 => open,
  FF_RX_D_1_21 => open,
  FF_RX_D_1_22 => open,
  FF_RX_D_1_23 => open,

  FFC_RRST_1 => rx_serdes_rst_ch1_c,
  FFC_SIGNAL_DETECT_1 => fpsc_vlo,
  FFC_SB_PFIFO_LP_1 => sb_felb_ch1_c,
  FFC_PFIFO_CLR_1 => sb_felb_rst_ch1_c,
  FFC_SB_INV_RX_1 => fpsc_vlo,
  FFC_PCIE_CT_1 => fpsc_vlo,
  FFC_PCI_DET_EN_1 => fpsc_vlo,
  FFC_FB_LOOPBACK_1 => fpsc_vlo,
  FFC_ENABLE_CGALIGN_1 => fpsc_vlo,
  FFC_EI_EN_1 => fpsc_vlo,
  FFC_LANE_TX_RST_1 => tx_pcs_rst_ch1_c,
  FFC_TXPWDNB_1 => tx_pwrup_ch1_c,
  FFC_LANE_RX_RST_1 => rx_pcs_rst_ch1_c,
  FFC_RXPWDNB_1 => rx_pwrup_ch1_c,
  FFS_RLOS_LO_1 => rx_los_low_ch1_sig,
  FFS_RLOS_HI_1 => open,
  FFS_PCIE_CON_1 => open,
  FFS_PCIE_DONE_1 => open,
  FFS_LS_SYNC_STATUS_1 => lsm_status_ch1_s,
  FFS_CC_OVERRUN_1 => open,
  FFS_CC_UNDERRUN_1 => open,
  FFS_SKP_ADDED_1 => open,
  FFS_SKP_DELETED_1 => open,
  FFS_RLOL_1 => rx_cdr_lol_ch1_sig,
  FFS_RXFBFIFO_ERROR_1 => open,
  FFS_TXFBFIFO_ERROR_1 => open,
  LDR_CORE2TX_1 => fpsc_vlo,
  FFC_LDR_CORE2TX_EN_1 => fpsc_vlo,
  LDR_RX2CORE_1 => open,
  FFS_CDR_TRAIN_DONE_1 => open,
  FFC_DIV11_MODE_TX_1 => fpsc_vlo,
  FFC_RATE_MODE_TX_1 => tx_div2_mode_ch1_c,
  FFC_DIV11_MODE_RX_1 => fpsc_vlo,
  FFC_RATE_MODE_RX_1 => rx_div2_mode_ch1_c,

----- CH2 -----
  HDOUTP2 => hdoutp_ch2,
  HDOUTN2 => hdoutn_ch2,
  HDINP2 => hdinp_ch2,
  HDINN2 => hdinn_ch2,
  PCIE_TXDETRX_PR2TLB_2 => fpsc_vlo,
  PCIE_TXCOMPLIANCE_2 => fpsc_vlo,
  PCIE_RXPOLARITY_2 => fpsc_vlo,
  PCIE_POWERDOWN_2_0 => fpsc_vlo,
  PCIE_POWERDOWN_2_1 => fpsc_vlo,
  PCIE_RXVALID_2 => open,
  PCIE_PHYSTATUS_2 => open,
  SCISELCH2 => sci_sel_ch2,
  SCIENCH2 => fpsc_vhi,
  FF_RXI_CLK_2 => rxiclk_ch2,
  FF_TXI_CLK_2 => txiclk_ch2,
  FF_EBRD_CLK_2 => fpsc_vlo,
  FF_RX_F_CLK_2 => rx_full_clk_ch2,
  FF_RX_H_CLK_2 => rx_half_clk_ch2,
  FF_TX_F_CLK_2 => tx_full_clk_ch2_sig,
  FF_TX_H_CLK_2 => tx_half_clk_ch2,
  FFC_CK_CORE_RX_2 => fpga_rxrefclk_ch2,
  FF_TX_D_2_0 => txdata_ch2(0),
  FF_TX_D_2_1 => txdata_ch2(1),
  FF_TX_D_2_2 => txdata_ch2(2),
  FF_TX_D_2_3 => txdata_ch2(3),
  FF_TX_D_2_4 => txdata_ch2(4),
  FF_TX_D_2_5 => txdata_ch2(5),
  FF_TX_D_2_6 => txdata_ch2(6),
  FF_TX_D_2_7 => txdata_ch2(7),
  FF_TX_D_2_8 => tx_k_ch2,
  FF_TX_D_2_9 => tx_force_disp_ch2,
  FF_TX_D_2_10 => tx_disp_sel_ch2,
  FF_TX_D_2_11 => fpsc_vlo,
  FF_TX_D_2_12 => fpsc_vlo,
  FF_TX_D_2_13 => fpsc_vlo,
  FF_TX_D_2_14 => fpsc_vlo,
  FF_TX_D_2_15 => fpsc_vlo,
  FF_TX_D_2_16 => fpsc_vlo,
  FF_TX_D_2_17 => fpsc_vlo,
  FF_TX_D_2_18 => fpsc_vlo,
  FF_TX_D_2_19 => fpsc_vlo,
  FF_TX_D_2_20 => fpsc_vlo,
  FF_TX_D_2_21 => fpsc_vlo,
  FF_TX_D_2_22 => fpsc_vlo,
  FF_TX_D_2_23 => fpsc_vlo,
  FF_RX_D_2_0 => rxdata_ch2(0),
  FF_RX_D_2_1 => rxdata_ch2(1),
  FF_RX_D_2_2 => rxdata_ch2(2),
  FF_RX_D_2_3 => rxdata_ch2(3),
  FF_RX_D_2_4 => rxdata_ch2(4),
  FF_RX_D_2_5 => rxdata_ch2(5),
  FF_RX_D_2_6 => rxdata_ch2(6),
  FF_RX_D_2_7 => rxdata_ch2(7),
  FF_RX_D_2_8 => rx_k_ch2,
  FF_RX_D_2_9 => rx_disp_err_ch2,
  FF_RX_D_2_10 => rx_cv_err_ch2,
  FF_RX_D_2_11 => open,
  FF_RX_D_2_12 => open,
  FF_RX_D_2_13 => open,
  FF_RX_D_2_14 => open,
  FF_RX_D_2_15 => open,
  FF_RX_D_2_16 => open,
  FF_RX_D_2_17 => open,
  FF_RX_D_2_18 => open,
  FF_RX_D_2_19 => open,
  FF_RX_D_2_20 => open,
  FF_RX_D_2_21 => open,
  FF_RX_D_2_22 => open,
  FF_RX_D_2_23 => open,

  FFC_RRST_2 => rx_serdes_rst_ch2_c,
  FFC_SIGNAL_DETECT_2 => fpsc_vlo,
  FFC_SB_PFIFO_LP_2 => sb_felb_ch2_c,
  FFC_PFIFO_CLR_2 => sb_felb_rst_ch2_c,
  FFC_SB_INV_RX_2 => fpsc_vlo,
  FFC_PCIE_CT_2 => fpsc_vlo,
  FFC_PCI_DET_EN_2 => fpsc_vlo,
  FFC_FB_LOOPBACK_2 => fpsc_vlo,
  FFC_ENABLE_CGALIGN_2 => fpsc_vlo,
  FFC_EI_EN_2 => fpsc_vlo,
  FFC_LANE_TX_RST_2 => tx_pcs_rst_ch2_c,
  FFC_TXPWDNB_2 => tx_pwrup_ch2_c,
  FFC_LANE_RX_RST_2 => rx_pcs_rst_ch2_c,
  FFC_RXPWDNB_2 => rx_pwrup_ch2_c,
  FFS_RLOS_LO_2 => rx_los_low_ch2_sig,
  FFS_RLOS_HI_2 => open,
  FFS_PCIE_CON_2 => open,
  FFS_PCIE_DONE_2 => open,
  FFS_LS_SYNC_STATUS_2 => lsm_status_ch2_s,
  FFS_CC_OVERRUN_2 => open,
  FFS_CC_UNDERRUN_2 => open,
  FFS_SKP_ADDED_2 => open,
  FFS_SKP_DELETED_2 => open,
  FFS_RLOL_2 => rx_cdr_lol_ch2_sig,
  FFS_RXFBFIFO_ERROR_2 => open,
  FFS_TXFBFIFO_ERROR_2 => open,
  LDR_CORE2TX_2 => fpsc_vlo,
  FFC_LDR_CORE2TX_EN_2 => fpsc_vlo,
  LDR_RX2CORE_2 => open,
  FFS_CDR_TRAIN_DONE_2 => open,
  FFC_DIV11_MODE_TX_2 => fpsc_vlo,
  FFC_RATE_MODE_TX_2 => tx_div2_mode_ch2_c,
  FFC_DIV11_MODE_RX_2 => fpsc_vlo,
  FFC_RATE_MODE_RX_2 => rx_div2_mode_ch2_c,

----- CH3 -----
  HDOUTP3 => hdoutp_ch3,
  HDOUTN3 => hdoutn_ch3,
  HDINP3 => hdinp_ch3,
  HDINN3 => hdinn_ch3,
  PCIE_TXDETRX_PR2TLB_3 => fpsc_vlo,
  PCIE_TXCOMPLIANCE_3 => fpsc_vlo,
  PCIE_RXPOLARITY_3 => fpsc_vlo,
  PCIE_POWERDOWN_3_0 => fpsc_vlo,
  PCIE_POWERDOWN_3_1 => fpsc_vlo,
  PCIE_RXVALID_3 => open,
  PCIE_PHYSTATUS_3 => open,
  SCISELCH3 => sci_sel_ch3,
  SCIENCH3 => fpsc_vhi,
  FF_RXI_CLK_3 => fpsc_vlo,
  FF_TXI_CLK_3 => txiclk_ch3,
  FF_EBRD_CLK_3 => fpsc_vlo,
  FF_RX_F_CLK_3 => rx_full_clk_ch3,
  FF_RX_H_CLK_3 => rx_half_clk_ch3,
  FF_TX_F_CLK_3 => tx_full_clk_ch3_sig,
  FF_TX_H_CLK_3 => tx_half_clk_ch3,
  FFC_CK_CORE_RX_3 => fpga_rxrefclk_ch3,
  FF_TX_D_3_0 => txdata_ch3(0),
  FF_TX_D_3_1 => txdata_ch3(1),
  FF_TX_D_3_2 => txdata_ch3(2),
  FF_TX_D_3_3 => txdata_ch3(3),
  FF_TX_D_3_4 => txdata_ch3(4),
  FF_TX_D_3_5 => txdata_ch3(5),
  FF_TX_D_3_6 => txdata_ch3(6),
  FF_TX_D_3_7 => txdata_ch3(7),
  FF_TX_D_3_8 => tx_k_ch3,
  FF_TX_D_3_9 => tx_force_disp_ch3,
  FF_TX_D_3_10 => tx_disp_sel_ch3,
  FF_TX_D_3_11 => fpsc_vlo,
  FF_TX_D_3_12 => fpsc_vlo,
  FF_TX_D_3_13 => fpsc_vlo,
  FF_TX_D_3_14 => fpsc_vlo,
  FF_TX_D_3_15 => fpsc_vlo,
  FF_TX_D_3_16 => fpsc_vlo,
  FF_TX_D_3_17 => fpsc_vlo,
  FF_TX_D_3_18 => fpsc_vlo,
  FF_TX_D_3_19 => fpsc_vlo,
  FF_TX_D_3_20 => fpsc_vlo,
  FF_TX_D_3_21 => fpsc_vlo,
  FF_TX_D_3_22 => fpsc_vlo,
  FF_TX_D_3_23 => fpsc_vlo,
  FF_RX_D_3_0 => rxdata_ch3(0),
  FF_RX_D_3_1 => rxdata_ch3(1),
  FF_RX_D_3_2 => rxdata_ch3(2),
  FF_RX_D_3_3 => rxdata_ch3(3),
  FF_RX_D_3_4 => rxdata_ch3(4),
  FF_RX_D_3_5 => rxdata_ch3(5),
  FF_RX_D_3_6 => rxdata_ch3(6),
  FF_RX_D_3_7 => rxdata_ch3(7),
  FF_RX_D_3_8 => rx_k_ch3,
  FF_RX_D_3_9 => rx_disp_err_ch3,
  FF_RX_D_3_10 => rx_cv_err_ch3,
  FF_RX_D_3_11 => open,
  FF_RX_D_3_12 => open,
  FF_RX_D_3_13 => open,
  FF_RX_D_3_14 => open,
  FF_RX_D_3_15 => open,
  FF_RX_D_3_16 => open,
  FF_RX_D_3_17 => open,
  FF_RX_D_3_18 => open,
  FF_RX_D_3_19 => open,
  FF_RX_D_3_20 => open,
  FF_RX_D_3_21 => open,
  FF_RX_D_3_22 => open,
  FF_RX_D_3_23 => open,

  FFC_RRST_3 => rx_serdes_rst_ch3_c,
  FFC_SIGNAL_DETECT_3 => fpsc_vlo,
  FFC_SB_PFIFO_LP_3 => sb_felb_ch3_c,
  FFC_PFIFO_CLR_3 => sb_felb_rst_ch3_c,
  FFC_SB_INV_RX_3 => fpsc_vlo,
  FFC_PCIE_CT_3 => fpsc_vlo,
  FFC_PCI_DET_EN_3 => fpsc_vlo,
  FFC_FB_LOOPBACK_3 => fpsc_vlo,
  FFC_ENABLE_CGALIGN_3 => fpsc_vlo,
  FFC_EI_EN_3 => fpsc_vlo,
  FFC_LANE_TX_RST_3 => tx_pcs_rst_ch3_c,
  FFC_TXPWDNB_3 => tx_pwrup_ch3_c,
  FFC_LANE_RX_RST_3 => rx_pcs_rst_ch3_c,
  FFC_RXPWDNB_3 => rx_pwrup_ch3_c,
  FFS_RLOS_LO_3 => rx_los_low_ch3_sig,
  FFS_RLOS_HI_3 => open,
  FFS_PCIE_CON_3 => open,
  FFS_PCIE_DONE_3 => open,
  FFS_LS_SYNC_STATUS_3 => lsm_status_ch3_s,
  FFS_CC_OVERRUN_3 => open,
  FFS_CC_UNDERRUN_3 => open,
  FFS_SKP_ADDED_3 => open,
  FFS_SKP_DELETED_3 => open,
  FFS_RLOL_3 => rx_cdr_lol_ch3_sig,
  FFS_RXFBFIFO_ERROR_3 => open,
  FFS_TXFBFIFO_ERROR_3 => open,
  LDR_CORE2TX_3 => fpsc_vlo,
  FFC_LDR_CORE2TX_EN_3 => fpsc_vlo,
  LDR_RX2CORE_3 => open,
  FFS_CDR_TRAIN_DONE_3 => open,
  FFC_DIV11_MODE_TX_3 => fpsc_vlo,
  FFC_RATE_MODE_TX_3 => tx_div2_mode_ch3_c,
  FFC_DIV11_MODE_RX_3 => fpsc_vlo,
  FFC_RATE_MODE_RX_3 => rx_div2_mode_ch3_c,

----- Auxilliary ----
  SCIWDATA7 => sci_wrdata(7),
  SCIWDATA6 => sci_wrdata(6),
  SCIWDATA5 => sci_wrdata(5),
  SCIWDATA4 => sci_wrdata(4),
  SCIWDATA3 => sci_wrdata(3),
  SCIWDATA2 => sci_wrdata(2),
  SCIWDATA1 => sci_wrdata(1),
  SCIWDATA0 => sci_wrdata(0),
  SCIADDR5 => sci_addr(5),
  SCIADDR4 => sci_addr(4),
  SCIADDR3 => sci_addr(3),
  SCIADDR2 => sci_addr(2),
  SCIADDR1 => sci_addr(1),
  SCIADDR0 => sci_addr(0),
  SCIRDATA7 => sci_rddata(7),
  SCIRDATA6 => sci_rddata(6),
  SCIRDATA5 => sci_rddata(5),
  SCIRDATA4 => sci_rddata(4),
  SCIRDATA3 => sci_rddata(3),
  SCIRDATA2 => sci_rddata(2),
  SCIRDATA1 => sci_rddata(1),
  SCIRDATA0 => sci_rddata(0),
  SCIENAUX => fpsc_vhi,
  SCISELAUX => sci_sel_quad,
  SCIRD => sci_rd,
  SCIWSTN => sci_wrn,
  CYAWSTN => fpsc_vlo,
  SCIINT => open,
  FFC_CK_CORE_TX => fpga_txrefclk,
  FFC_MACRO_RST => serdes_rst_qd_c,
  FFC_QUAD_RST => rst_qd_c,
  FFC_TRST => tx_serdes_rst_c,
  FFS_PLOL => tx_pll_lol_qd_sig,
  FFC_SYNC_TOGGLE => tx_sync_qd_c,
  REFCK2CORE => refclk2fpga_sig,
  CIN0 => fpsc_vlo,
  CIN1 => fpsc_vlo,
  CIN2 => fpsc_vlo,
  CIN3 => fpsc_vlo,
  CIN4 => fpsc_vlo,
  CIN5 => fpsc_vlo,
  CIN6 => fpsc_vlo,
  CIN7 => fpsc_vlo,
  CIN8 => fpsc_vlo,
  CIN9 => fpsc_vlo,
  CIN10 => fpsc_vlo,
  CIN11 => fpsc_vlo,
  COUT0 => open,
  COUT1 => open,
  COUT2 => open,
  COUT3 => open,
  COUT4 => open,
  COUT5 => open,
  COUT6 => open,
  COUT7 => open,
  COUT8 => open,
  COUT9 => open,
  COUT10 => open,
  COUT11 => open,
  COUT12 => open,
  COUT13 => open,
  COUT14 => open,
  COUT15 => open,
  COUT16 => open,
  COUT17 => open,
  COUT18 => open,
  COUT19 => open,
  REFCLK_FROM_NQ => refclk_from_nq,
  REFCLK_TO_NQ => open);

                                                                                              
                                                                                              
                                                                                              
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
end serdes_sync_4_slave3_arch ;
