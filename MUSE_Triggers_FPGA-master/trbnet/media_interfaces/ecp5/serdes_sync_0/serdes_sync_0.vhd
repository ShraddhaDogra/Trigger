
--
-- Verific VHDL Description of module DCUA
--

-- DCUA is a black-box. Cannot print a valid VHDL entity description for it

--
-- Verific VHDL Description of module serdes_sync_0sll_core
--

-- serdes_sync_0sll_core is a black-box. Cannot print a valid VHDL entity description for it

--
-- Verific VHDL Description of module serdes_sync_0
--

library ieee ;
use ieee.std_logic_1164.all ;

library ecp5um ;
use ecp5um.components.all ;

entity serdes_sync_0 is
    port (hdoutp: out std_logic;
        hdoutn: out std_logic;
        hdinp: in std_logic;
        hdinn: in std_logic;
        rxrefclk: in std_logic;
        rx_pclk: out std_logic;
        tx_pclk: out std_logic;
        txdata: in std_logic_vector(7 downto 0);
        tx_k: in std_logic_vector(0 downto 0);
        tx_force_disp: in std_logic_vector(0 downto 0);
        tx_disp_sel: in std_logic_vector(0 downto 0);
        rxdata: out std_logic_vector(7 downto 0);
        rx_k: out std_logic_vector(0 downto 0);
        rx_disp_err: out std_logic_vector(0 downto 0);
        rx_cv_err: out std_logic_vector(0 downto 0);
        tx_idle_c: in std_logic;
        signal_detect_c: in std_logic;
        rx_los_low_s: out std_logic;
        lsm_status_s: out std_logic;
        rx_cdr_lol_s: out std_logic;
        tx_pcs_rst_c: in std_logic;
        rx_pcs_rst_c: in std_logic;
        rx_serdes_rst_c: in std_logic;
        tx_pwrup_c: in std_logic;
        rx_pwrup_c: in std_logic;
        sci_wrdata: in std_logic_vector(7 downto 0);
        sci_addr: in std_logic_vector(5 downto 0);
        sci_rddata: out std_logic_vector(7 downto 0);
        sci_en_dual: in std_logic;
        sci_sel_dual: in std_logic;
        sci_en: in std_logic;
        sci_sel: in std_logic;
        sci_rd: in std_logic;
        sci_wrn: in std_logic;
        sci_int: out std_logic;
        cyawstn: in std_logic;
        rst_dual_c: in std_logic;
        serdes_rst_dual_c: in std_logic;
        serdes_pdb: in std_logic;
        tx_serdes_rst_c: in std_logic;
        pll_refclki: in std_logic;
        sli_rst: in std_logic;
        pll_lol: out std_logic
    );
    
end entity serdes_sync_0;

architecture v1 of serdes_sync_0 is 
    component serdes_sync_0sll_core is
        generic (PPROTOCOL: string := "G8B10B";
            PLOL_SETTING: integer := 1;
            PDYN_RATE_CTRL: string := "DISABLED";
            PDIFF_VAL_LOCK: integer := 19;
            PDIFF_VAL_UNLOCK: integer := 131;
            PPCLK_TC: integer := 65536;
            PDIFF_DIV11_VAL_LOCK: integer := 0;
            PDIFF_DIV11_VAL_UNLOCK: integer := 0;
            PPCLK_DIV11_TC: integer := 0);
        port (sli_rst: in std_logic;   -- /d/jspc29/lattice/diamond/3.7_x64/ispfpga/sa5p00/data/sll_core_template.v(73)
            sli_refclk: in std_logic;   -- /d/jspc29/lattice/diamond/3.7_x64/ispfpga/sa5p00/data/sll_core_template.v(74)
            sli_pclk: in std_logic;   -- /d/jspc29/lattice/diamond/3.7_x64/ispfpga/sa5p00/data/sll_core_template.v(75)
            sli_div2_rate: in std_logic;   -- /d/jspc29/lattice/diamond/3.7_x64/ispfpga/sa5p00/data/sll_core_template.v(76)
            sli_div11_rate: in std_logic;   -- /d/jspc29/lattice/diamond/3.7_x64/ispfpga/sa5p00/data/sll_core_template.v(77)
            sli_gear_mode: in std_logic;   -- /d/jspc29/lattice/diamond/3.7_x64/ispfpga/sa5p00/data/sll_core_template.v(78)
            slo_plol: out std_logic   -- /d/jspc29/lattice/diamond/3.7_x64/ispfpga/sa5p00/data/sll_core_template.v(81)
        );
        
    end component serdes_sync_0sll_core; -- syn_black_box=1    -- /d/jspc29/lattice/diamond/3.7_x64/ispfpga/sa5p00/data/sll_core_template.v(57)
    signal n48,n47,n1,n2,n3,n4,rx_pclk_c,tx_pclk_c,n5,n6,n7,n8,n9,
        n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,n21,n22,n23,
        n24,n25,n26,n27,n28,n29,n30,n31,n32,n33,n34,n35,n36,n37,
        n38,n39,n40,n41,n42,n43,n44,n45,n46,n49,n106,n105,n50,n51,
        n52,n53,n54,n55,n56,n57,n58,n59,n60,n61,n62,n63,n64,n65,
        n66,n67,n68,n69,n70,n71,n72,n73,n74,n75,n76,n77,n78,n79,
        n80,n81,n82,n83,n84,n85,n86,n87,n88,n89,n90,n91,n92,n93,
        n94,n95,n96,n97,n98,n99,n100,n101,n102,n103,n104,\_Z\,n108,
        n107,gnd,pwr : std_logic; 
    attribute LOC : string;
    attribute LOC of DCU0_inst : label is "DCU0";
    attribute CHAN : string;
    attribute CHAN of DCU0_inst : label is "CH0";
begin
    rx_pclk <= rx_pclk_c;
    tx_pclk <= tx_pclk_c;
    DCU0_inst: component DCUA generic map (D_MACROPDB=>"0b1",D_IB_PWDNB=>"0b1",
        D_XGE_MODE=>"0b0",D_LOW_MARK=>"0d4",D_HIGH_MARK=>"0d12",D_BUS8BIT_SEL=>"0b0",
        D_CDR_LOL_SET=>"0b11",D_TXPLL_PWDNB=>"0b1",D_BITCLK_LOCAL_EN=>"0b1",
        D_BITCLK_ND_EN=>"0b0",D_BITCLK_FROM_ND_EN=>"0b0",D_SYNC_LOCAL_EN=>"0b1",
        D_SYNC_ND_EN=>"0b0",CH0_UC_MODE=>"0b1",CH0_PCIE_MODE=>"0b0",CH0_RIO_MODE=>"0b0",
        CH0_WA_MODE=>"0b0",CH0_INVERT_RX=>"0b0",CH0_INVERT_TX=>"0b0",CH0_PRBS_SELECTION=>"0b0",
        CH0_GE_AN_ENABLE=>"0b0",CH0_PRBS_LOCK=>"0b0",CH0_PRBS_ENABLE=>"0b0",
        CH0_ENABLE_CG_ALIGN=>"0b1",CH0_TX_GEAR_MODE=>"0b0",CH0_RX_GEAR_MODE=>"0b0",
        CH0_PCS_DET_TIME_SEL=>"0b00",CH0_PCIE_EI_EN=>"0b0",CH0_TX_GEAR_BYPASS=>"0b0",
        CH0_ENC_BYPASS=>"0b0",CH0_SB_BYPASS=>"0b0",CH0_RX_SB_BYPASS=>"0b0",
        CH0_WA_BYPASS=>"0b0",CH0_DEC_BYPASS=>"0b0",CH0_CTC_BYPASS=>"0b1",
        CH0_RX_GEAR_BYPASS=>"0b0",CH0_LSM_DISABLE=>"0b0",CH0_MATCH_2_ENABLE=>"0b0",
        CH0_MATCH_4_ENABLE=>"0b1",CH0_MIN_IPG_CNT=>"0b11",CH0_CC_MATCH_1=>"0x1BC",
        CH0_CC_MATCH_2=>"0x11C",CH0_CC_MATCH_3=>"0x11C",CH0_CC_MATCH_4=>"0x11C",
        CH0_UDF_COMMA_MASK=>"0x0ff",CH0_UDF_COMMA_A=>"0x083",CH0_UDF_COMMA_B=>"0x07C",
        CH0_RX_DCO_CK_DIV=>"0b000",CH0_RCV_DCC_EN=>"0b0",CH0_TPWDNB=>"0b1",
        CH0_RATE_MODE_TX=>"0b0",CH0_RTERM_TX=>"0d19",CH0_TX_CM_SEL=>"0b00",
        CH0_TDRV_PRE_EN=>"0b0",CH0_TDRV_SLICE0_SEL=>"0b00",CH0_TDRV_SLICE1_SEL=>"0b00",
        CH0_TDRV_SLICE2_SEL=>"0b01",CH0_TDRV_SLICE3_SEL=>"0b01",CH0_TDRV_SLICE4_SEL=>"0b01",
        CH0_TDRV_SLICE5_SEL=>"0b00",CH0_TDRV_SLICE0_CUR=>"0b000",CH0_TDRV_SLICE1_CUR=>"0b000",
        CH0_TDRV_SLICE2_CUR=>"0b11",CH0_TDRV_SLICE3_CUR=>"0b11",CH0_TDRV_SLICE4_CUR=>"0b01",
        CH0_TDRV_SLICE5_CUR=>"0b00",CH0_TDRV_DAT_SEL=>"0b00",CH0_TX_DIV11_SEL=>"0b0",
        CH0_RPWDNB=>"0b1",CH0_RATE_MODE_RX=>"0b0",CH0_RX_DIV11_SEL=>"0b0",
        CH0_SEL_SD_RX_CLK=>"0b1",CH0_FF_RX_H_CLK_EN=>"0b0",CH0_FF_RX_F_CLK_DIS=>"0b0",
        CH0_FF_TX_H_CLK_EN=>"0b0",CH0_FF_TX_F_CLK_DIS=>"0b0",CH0_TDRV_POST_EN=>"0b0",
        CH0_TX_POST_SIGN=>"0b0",CH0_TX_PRE_SIGN=>"0b0",CH0_REQ_LVL_SET=>"0b00",
        CH0_REQ_EN=>"0b1",CH0_RTERM_RX=>"0d22",CH0_RXTERM_CM=>"0b11",CH0_PDEN_SEL=>"0b0",
        CH0_RXIN_CM=>"0b11",CH0_LEQ_OFFSET_SEL=>"0b0",CH0_LEQ_OFFSET_TRIM=>"0b000",
        CH0_RLOS_SEL=>"0b0",CH0_RX_LOS_LVL=>"0b100",CH0_RX_LOS_CEQ=>"0b11",
        CH0_RX_LOS_HYST_EN=>"0b0",CH0_RX_LOS_EN=>"0b1",CH0_LDR_RX2CORE_SEL=>"0b0",
        CH0_LDR_CORE2TX_SEL=>"0b0",D_TX_MAX_RATE=>"2",CH0_CDR_MAX_RATE=>"2",
        CH0_TXAMPLITUDE=>"0d800",CH0_TXDEPRE=>"DISABLED",CH0_TXDEPOST=>"DISABLED",
        CH0_PROTOCOL=>"G8B10B",D_ISETLOS=>"0d0",D_SETIRPOLY_AUX=>"0b10",D_SETICONST_AUX=>"0b01",
        D_SETIRPOLY_CH=>"0b10",D_SETICONST_CH=>"0b10",D_REQ_ISET=>"0b001",
        D_PD_ISET=>"0b00",D_DCO_CALIB_TIME_SEL=>"0b00",CH0_CDR_CNT4SEL=>"0b00",
        CH0_CDR_CNT8SEL=>"0b00",CH0_DCOATDCFG=>"0b00",CH0_DCOATDDLY=>"0b00",
        CH0_DCOBYPSATD=>"0b1",CH0_DCOCALDIV=>"0b000",CH0_DCOCTLGI=>"0b011",
        CH0_DCODISBDAVOID=>"0b0",CH0_DCOFLTDAC=>"0b00",CH0_DCOFTNRG=>"0b001",
        CH0_DCOIOSTUNE=>"0b010",CH0_DCOITUNE=>"0b00",CH0_DCOITUNE4LSB=>"0b010",
        CH0_DCOIUPDNX2=>"0b1",CH0_DCONUOFLSB=>"0b100",CH0_DCOSCALEI=>"0b01",
        CH0_DCOSTARTVAL=>"0b010",CH0_DCOSTEP=>"0b11",CH0_BAND_THRESHOLD=>"0d0",
        CH0_AUTO_FACQ_EN=>"0b1",CH0_AUTO_CALIB_EN=>"0b1",CH0_CALIB_CK_MODE=>"0b0",
        CH0_REG_BAND_OFFSET=>"0d0",CH0_REG_BAND_SEL=>"0d0",CH0_REG_IDAC_SEL=>"0d0",
        CH0_REG_IDAC_EN=>"0b0",D_CMUSETISCL4VCO=>"0b000",D_CMUSETI4VCO=>"0b00",
        D_CMUSETINITVCT=>"0b00",D_CMUSETZGM=>"0b000",D_CMUSETP2AGM=>"0b000",
        D_CMUSETP1GM=>"0b000",D_CMUSETI4CPZ=>"0d3",D_CMUSETI4CPP=>"0d3",D_CMUSETICP4Z=>"0b101",
        D_CMUSETICP4P=>"0b01",D_CMUSETBIASI=>"0b00",D_SETPLLRC=>"0d1",CH0_RX_RATE_SEL=>"0d10",
        D_REFCK_MODE=>"0b001",D_TX_VCO_CK_DIV=>"0b000",D_PLL_LOL_SET=>"0b01",
        D_RG_EN=>"0b1",D_RG_SET=>"0b00")
     port map (CH0_HDINP=>hdinp,CH1_HDINP=>n106,CH0_HDINN=>hdinn,CH1_HDINN=>n106,
    D_TXBIT_CLKP_FROM_ND=>n47,D_TXBIT_CLKN_FROM_ND=>n47,D_SYNC_ND=>n47,D_TXPLL_LOL_FROM_ND=>n47,
    CH0_RX_REFCLK=>rxrefclk,CH1_RX_REFCLK=>n106,CH0_FF_RXI_CLK=>rx_pclk_c,
    CH1_FF_RXI_CLK=>n105,CH0_FF_TXI_CLK=>tx_pclk_c,CH1_FF_TXI_CLK=>n105,CH0_FF_EBRD_CLK=>n48,
    CH1_FF_EBRD_CLK=>n105,CH0_FF_TX_D_0=>txdata(0),CH1_FF_TX_D_0=>n106,CH0_FF_TX_D_1=>txdata(1),
    CH1_FF_TX_D_1=>n106,CH0_FF_TX_D_2=>txdata(2),CH1_FF_TX_D_2=>n106,CH0_FF_TX_D_3=>txdata(3),
    CH1_FF_TX_D_3=>n106,CH0_FF_TX_D_4=>txdata(4),CH1_FF_TX_D_4=>n106,CH0_FF_TX_D_5=>txdata(5),
    CH1_FF_TX_D_5=>n106,CH0_FF_TX_D_6=>txdata(6),CH1_FF_TX_D_6=>n106,CH0_FF_TX_D_7=>txdata(7),
    CH1_FF_TX_D_7=>n106,CH0_FF_TX_D_8=>tx_k(0),CH1_FF_TX_D_8=>n106,CH0_FF_TX_D_9=>tx_force_disp(0),
    CH1_FF_TX_D_9=>n106,CH0_FF_TX_D_10=>tx_disp_sel(0),CH1_FF_TX_D_10=>n106,
    CH0_FF_TX_D_11=>n47,CH1_FF_TX_D_11=>n106,CH0_FF_TX_D_12=>n106,CH1_FF_TX_D_12=>n106,
    CH0_FF_TX_D_13=>n106,CH1_FF_TX_D_13=>n106,CH0_FF_TX_D_14=>n106,CH1_FF_TX_D_14=>n106,
    CH0_FF_TX_D_15=>n106,CH1_FF_TX_D_15=>n106,CH0_FF_TX_D_16=>n106,CH1_FF_TX_D_16=>n106,
    CH0_FF_TX_D_17=>n106,CH1_FF_TX_D_17=>n106,CH0_FF_TX_D_18=>n106,CH1_FF_TX_D_18=>n106,
    CH0_FF_TX_D_19=>n106,CH1_FF_TX_D_19=>n106,CH0_FF_TX_D_20=>n106,CH1_FF_TX_D_20=>n106,
    CH0_FF_TX_D_21=>n106,CH1_FF_TX_D_21=>n106,CH0_FF_TX_D_22=>n106,CH1_FF_TX_D_22=>n106,
    CH0_FF_TX_D_23=>n47,CH1_FF_TX_D_23=>n106,CH0_FFC_EI_EN=>tx_idle_c,CH1_FFC_EI_EN=>n106,
    CH0_FFC_PCIE_DET_EN=>n47,CH1_FFC_PCIE_DET_EN=>n106,CH0_FFC_PCIE_CT=>n47,
    CH1_FFC_PCIE_CT=>n106,CH0_FFC_SB_INV_RX=>n106,CH1_FFC_SB_INV_RX=>n106,
    CH0_FFC_ENABLE_CGALIGN=>n106,CH1_FFC_ENABLE_CGALIGN=>n106,CH0_FFC_SIGNAL_DETECT=>signal_detect_c,
    CH1_FFC_SIGNAL_DETECT=>n106,CH0_FFC_FB_LOOPBACK=>n47,CH1_FFC_FB_LOOPBACK=>n106,
    CH0_FFC_SB_PFIFO_LP=>n47,CH1_FFC_SB_PFIFO_LP=>n106,CH0_FFC_PFIFO_CLR=>n47,
    CH1_FFC_PFIFO_CLR=>n106,CH0_FFC_RATE_MODE_RX=>n106,CH1_FFC_RATE_MODE_RX=>n106,
    CH0_FFC_RATE_MODE_TX=>n106,CH1_FFC_RATE_MODE_TX=>n106,CH0_FFC_DIV11_MODE_RX=>n47,
    CH1_FFC_DIV11_MODE_RX=>n106,CH0_FFC_DIV11_MODE_TX=>n47,CH1_FFC_DIV11_MODE_TX=>n106,
    CH0_FFC_RX_GEAR_MODE=>n47,CH1_FFC_RX_GEAR_MODE=>n106,CH0_FFC_TX_GEAR_MODE=>n47,
    CH1_FFC_TX_GEAR_MODE=>n106,CH0_FFC_LDR_CORE2TX_EN=>n106,CH1_FFC_LDR_CORE2TX_EN=>n106,
    CH0_FFC_LANE_TX_RST=>tx_pcs_rst_c,CH1_FFC_LANE_TX_RST=>n106,CH0_FFC_LANE_RX_RST=>rx_pcs_rst_c,
    CH1_FFC_LANE_RX_RST=>n106,CH0_FFC_RRST=>rx_serdes_rst_c,CH1_FFC_RRST=>n106,
    CH0_FFC_TXPWDNB=>tx_pwrup_c,CH1_FFC_TXPWDNB=>n106,CH0_FFC_RXPWDNB=>rx_pwrup_c,
    CH1_FFC_RXPWDNB=>n106,CH0_LDR_CORE2TX=>n106,CH1_LDR_CORE2TX=>n106,D_SCIWDATA0=>sci_wrdata(0),
    D_SCIWDATA1=>sci_wrdata(1),D_SCIWDATA2=>sci_wrdata(2),D_SCIWDATA3=>sci_wrdata(3),
    D_SCIWDATA4=>sci_wrdata(4),D_SCIWDATA5=>sci_wrdata(5),D_SCIWDATA6=>sci_wrdata(6),
    D_SCIWDATA7=>sci_wrdata(7),D_SCIADDR0=>sci_addr(0),D_SCIADDR1=>sci_addr(1),
    D_SCIADDR2=>sci_addr(2),D_SCIADDR3=>sci_addr(3),D_SCIADDR4=>sci_addr(4),
    D_SCIADDR5=>sci_addr(5),D_SCIENAUX=>sci_en_dual,D_SCISELAUX=>sci_sel_dual,
    CH0_SCIEN=>sci_en,CH1_SCIEN=>n106,CH0_SCISEL=>sci_sel,CH1_SCISEL=>n106,
    D_SCIRD=>sci_rd,D_SCIWSTN=>sci_wrn,D_CYAWSTN=>cyawstn,D_FFC_SYNC_TOGGLE=>n106,
    D_FFC_DUAL_RST=>rst_dual_c,D_FFC_MACRO_RST=>serdes_rst_dual_c,D_FFC_MACROPDB=>serdes_pdb,
    D_FFC_TRST=>tx_serdes_rst_c,CH0_FFC_CDR_EN_BITSLIP=>n47,CH1_FFC_CDR_EN_BITSLIP=>n106,
    D_SCAN_ENABLE=>n47,D_SCAN_IN_0=>n47,D_SCAN_IN_1=>n47,D_SCAN_IN_2=>n47,
    D_SCAN_IN_3=>n47,D_SCAN_IN_4=>n47,D_SCAN_IN_5=>n47,D_SCAN_IN_6=>n47,
    D_SCAN_IN_7=>n47,D_SCAN_MODE=>n47,D_SCAN_RESET=>n47,D_CIN0=>n47,D_CIN1=>n47,
    D_CIN2=>n47,D_CIN3=>n47,D_CIN4=>n47,D_CIN5=>n47,D_CIN6=>n47,D_CIN7=>n47,
    D_CIN8=>n47,D_CIN9=>n47,D_CIN10=>n47,D_CIN11=>n47,CH0_HDOUTP=>hdoutp,
    CH1_HDOUTP=>n50,CH0_HDOUTN=>hdoutn,CH1_HDOUTN=>n51,D_TXBIT_CLKP_TO_ND=>n1,
    D_TXBIT_CLKN_TO_ND=>n2,D_SYNC_PULSE2ND=>n3,D_TXPLL_LOL_TO_ND=>n4,CH0_FF_RX_F_CLK=>n5,
    CH1_FF_RX_F_CLK=>n52,CH0_FF_RX_H_CLK=>n6,CH1_FF_RX_H_CLK=>n53,CH0_FF_TX_F_CLK=>n7,
    CH1_FF_TX_F_CLK=>n54,CH0_FF_TX_H_CLK=>n8,CH1_FF_TX_H_CLK=>n55,CH0_FF_RX_PCLK=>rx_pclk_c,
    CH1_FF_RX_PCLK=>n56,CH0_FF_TX_PCLK=>tx_pclk_c,CH1_FF_TX_PCLK=>n57,CH0_FF_RX_D_0=>rxdata(0),
    CH1_FF_RX_D_0=>n58,CH0_FF_RX_D_1=>rxdata(1),CH1_FF_RX_D_1=>n59,CH0_FF_RX_D_2=>rxdata(2),
    CH1_FF_RX_D_2=>n60,CH0_FF_RX_D_3=>rxdata(3),CH1_FF_RX_D_3=>n61,CH0_FF_RX_D_4=>rxdata(4),
    CH1_FF_RX_D_4=>n62,CH0_FF_RX_D_5=>rxdata(5),CH1_FF_RX_D_5=>n63,CH0_FF_RX_D_6=>rxdata(6),
    CH1_FF_RX_D_6=>n64,CH0_FF_RX_D_7=>rxdata(7),CH1_FF_RX_D_7=>n65,CH0_FF_RX_D_8=>rx_k(0),
    CH1_FF_RX_D_8=>n66,CH0_FF_RX_D_9=>rx_disp_err(0),CH1_FF_RX_D_9=>n67,CH0_FF_RX_D_10=>rx_cv_err(0),
    CH1_FF_RX_D_10=>n68,CH0_FF_RX_D_11=>n9,CH1_FF_RX_D_11=>n69,CH0_FF_RX_D_12=>n70,
    CH1_FF_RX_D_12=>n71,CH0_FF_RX_D_13=>n72,CH1_FF_RX_D_13=>n73,CH0_FF_RX_D_14=>n74,
    CH1_FF_RX_D_14=>n75,CH0_FF_RX_D_15=>n76,CH1_FF_RX_D_15=>n77,CH0_FF_RX_D_16=>n78,
    CH1_FF_RX_D_16=>n79,CH0_FF_RX_D_17=>n80,CH1_FF_RX_D_17=>n81,CH0_FF_RX_D_18=>n82,
    CH1_FF_RX_D_18=>n83,CH0_FF_RX_D_19=>n84,CH1_FF_RX_D_19=>n85,CH0_FF_RX_D_20=>n86,
    CH1_FF_RX_D_20=>n87,CH0_FF_RX_D_21=>n88,CH1_FF_RX_D_21=>n89,CH0_FF_RX_D_22=>n90,
    CH1_FF_RX_D_22=>n91,CH0_FF_RX_D_23=>n10,CH1_FF_RX_D_23=>n92,CH0_FFS_PCIE_DONE=>n11,
    CH1_FFS_PCIE_DONE=>n93,CH0_FFS_PCIE_CON=>n12,CH1_FFS_PCIE_CON=>n94,CH0_FFS_RLOS=>rx_los_low_s,
    CH1_FFS_RLOS=>n95,CH0_FFS_LS_SYNC_STATUS=>lsm_status_s,CH1_FFS_LS_SYNC_STATUS=>n96,
    CH0_FFS_CC_UNDERRUN=>n13,CH1_FFS_CC_UNDERRUN=>n97,CH0_FFS_CC_OVERRUN=>n14,
    CH1_FFS_CC_OVERRUN=>n98,CH0_FFS_RXFBFIFO_ERROR=>n15,CH1_FFS_RXFBFIFO_ERROR=>n99,
    CH0_FFS_TXFBFIFO_ERROR=>n16,CH1_FFS_TXFBFIFO_ERROR=>n100,CH0_FFS_RLOL=>rx_cdr_lol_s,
    CH1_FFS_RLOL=>n101,CH0_FFS_SKP_ADDED=>n17,CH1_FFS_SKP_ADDED=>n102,CH0_FFS_SKP_DELETED=>n18,
    CH1_FFS_SKP_DELETED=>n103,CH0_LDR_RX2CORE=>n104,CH1_LDR_RX2CORE=>\_Z\,
    D_SCIRDATA0=>sci_rddata(0),D_SCIRDATA1=>sci_rddata(1),D_SCIRDATA2=>sci_rddata(2),
    D_SCIRDATA3=>sci_rddata(3),D_SCIRDATA4=>sci_rddata(4),D_SCIRDATA5=>sci_rddata(5),
    D_SCIRDATA6=>sci_rddata(6),D_SCIRDATA7=>sci_rddata(7),D_SCIINT=>sci_int,
    D_SCAN_OUT_0=>n19,D_SCAN_OUT_1=>n20,D_SCAN_OUT_2=>n21,D_SCAN_OUT_3=>n22,
    D_SCAN_OUT_4=>n23,D_SCAN_OUT_5=>n24,D_SCAN_OUT_6=>n25,D_SCAN_OUT_7=>n26,
    D_COUT0=>n27,D_COUT1=>n28,D_COUT2=>n29,D_COUT3=>n30,D_COUT4=>n31,D_COUT5=>n32,
    D_COUT6=>n33,D_COUT7=>n34,D_COUT8=>n35,D_COUT9=>n36,D_COUT10=>n37,D_COUT11=>n38,
    D_COUT12=>n39,D_COUT13=>n40,D_COUT14=>n41,D_COUT15=>n42,D_COUT16=>n43,
    D_COUT17=>n44,D_COUT18=>n45,D_COUT19=>n46,D_REFCLKI=>pll_refclki,D_FFS_PLOL=>n49);
    n48 <= '1' ;
    n47 <= '0' ;
    n1 <= 'Z' ;
    n2 <= 'Z' ;
    n3 <= 'Z' ;
    n4 <= 'Z' ;
    n5 <= 'Z' ;
    n6 <= 'Z' ;
    n7 <= 'Z' ;
    n8 <= 'Z' ;
    n9 <= 'Z' ;
    n10 <= 'Z' ;
    n11 <= 'Z' ;
    n12 <= 'Z' ;
    n13 <= 'Z' ;
    n14 <= 'Z' ;
    n15 <= 'Z' ;
    n16 <= 'Z' ;
    n17 <= 'Z' ;
    n18 <= 'Z' ;
    n19 <= 'Z' ;
    n20 <= 'Z' ;
    n21 <= 'Z' ;
    n22 <= 'Z' ;
    n23 <= 'Z' ;
    n24 <= 'Z' ;
    n25 <= 'Z' ;
    n26 <= 'Z' ;
    n27 <= 'Z' ;
    n28 <= 'Z' ;
    n29 <= 'Z' ;
    n30 <= 'Z' ;
    n31 <= 'Z' ;
    n32 <= 'Z' ;
    n33 <= 'Z' ;
    n34 <= 'Z' ;
    n35 <= 'Z' ;
    n36 <= 'Z' ;
    n37 <= 'Z' ;
    n38 <= 'Z' ;
    n39 <= 'Z' ;
    n40 <= 'Z' ;
    n41 <= 'Z' ;
    n42 <= 'Z' ;
    n43 <= 'Z' ;
    n44 <= 'Z' ;
    n45 <= 'Z' ;
    n46 <= 'Z' ;
    n49 <= 'Z' ;
    n106 <= '0' ;
    n105 <= '1' ;
    n50 <= 'Z' ;
    n51 <= 'Z' ;
    n52 <= 'Z' ;
    n53 <= 'Z' ;
    n54 <= 'Z' ;
    n55 <= 'Z' ;
    n56 <= 'Z' ;
    n57 <= 'Z' ;
    n58 <= 'Z' ;
    n59 <= 'Z' ;
    n60 <= 'Z' ;
    n61 <= 'Z' ;
    n62 <= 'Z' ;
    n63 <= 'Z' ;
    n64 <= 'Z' ;
    n65 <= 'Z' ;
    n66 <= 'Z' ;
    n67 <= 'Z' ;
    n68 <= 'Z' ;
    n69 <= 'Z' ;
    n70 <= 'Z' ;
    n71 <= 'Z' ;
    n72 <= 'Z' ;
    n73 <= 'Z' ;
    n74 <= 'Z' ;
    n75 <= 'Z' ;
    n76 <= 'Z' ;
    n77 <= 'Z' ;
    n78 <= 'Z' ;
    n79 <= 'Z' ;
    n80 <= 'Z' ;
    n81 <= 'Z' ;
    n82 <= 'Z' ;
    n83 <= 'Z' ;
    n84 <= 'Z' ;
    n85 <= 'Z' ;
    n86 <= 'Z' ;
    n87 <= 'Z' ;
    n88 <= 'Z' ;
    n89 <= 'Z' ;
    n90 <= 'Z' ;
    n91 <= 'Z' ;
    n92 <= 'Z' ;
    n93 <= 'Z' ;
    n94 <= 'Z' ;
    n95 <= 'Z' ;
    n96 <= 'Z' ;
    n97 <= 'Z' ;
    n98 <= 'Z' ;
    n99 <= 'Z' ;
    n100 <= 'Z' ;
    n101 <= 'Z' ;
    n102 <= 'Z' ;
    n103 <= 'Z' ;
    n104 <= 'Z' ;
    \_Z\ <= 'Z' ;
    sll_inst: component serdes_sync_0sll_core port map (sli_rst=>sli_rst,sli_refclk=>pll_refclki,
            sli_pclk=>tx_pclk_c,sli_div2_rate=>gnd,sli_div11_rate=>gnd,sli_gear_mode=>gnd,
            slo_plol=>pll_lol);
    n108 <= '1' ;
    n107 <= '0' ;
    gnd <= '0' ;
    pwr <= '1' ;
    
end architecture v1;

