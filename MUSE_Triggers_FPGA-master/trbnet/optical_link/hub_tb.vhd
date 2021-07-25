library IEEE;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity hub_tb is

  port (
    LVDS_CLK_200P : in    std_logic;
    LVDS_CLK_200N : in    std_logic;
    SERDES_200N   : in    std_logic;
    SERDES_200P   : in    std_logic;
    ADO_TTL       : inout std_logic_vector(46 downto 0);
    DBAD          : out   std_logic;
    DGOOD         : out   std_logic;
    DINT          : out   std_logic;
    DWAIT         : out   std_logic;
    LOK           : out   std_logic_vector(16 downto 1);
    RT            : out   std_logic_vector(16 downto 1);
    TX_DIS        : out   std_logic_vector(16 downto 1);
    IPLL          : out   std_logic;
    OPLL          : out   std_logic;
    SFP_INP_N     : in    std_logic_vector(15 downto 0);
    SFP_INP_P     : in    std_logic_vector(15 downto 0);
    SFP_OUT_N     : out   std_logic_vector(15 downto 0);
    SFP_OUT_P     : out   std_logic_vector(15 downto 0);
    AAAAAAAA      : in    std_logic);
end hub_tb;

architecture hub_tb of hub_tb is

signal LVDS_CLK_200P_i : std_logic;
signal LVDS_CLK_200N_i : std_logic;
signal SERDES_200N_i   : std_logic;
signal SERDES_200P_i   : std_logic;
signal ADO_TTL_i       : std_logic_vector(46 downto 0);
signal DBAD_i          : std_logic;
signal DGOOD_i         : std_logic;
signal DINT_i          : std_logic;
signal DWAIT_i         : std_logic;
signal LOK_i           : std_logic_vector(16 downto 1);
signal RT_i            : std_logic_vector(16 downto 1);
signal TX_DIS_i        : std_logic_vector(16 downto 1);
signal IPLL_i          : std_logic;
signal OPLL_i          : std_logic;
signal SFP_INP_N_i     : std_logic_vector(15 downto 0);
signal SFP_INP_P_i     : std_logic_vector(15 downto 0);
signal SFP_OUT_N_i     : std_logic_vector(15 downto 0);
signal SFP_OUT_P_i     : std_logic_vector(15 downto 0);

component hub
  port (
    LVDS_CLK_200P : in    std_logic;
--     LVDS_CLK_200N : in    std_logic;
--     SERDES_200N   : in    std_logic;
--     SERDES_200P   : in    std_logic;
    ADO_TTL       : inout std_logic_vector(46 downto 0);
    DBAD          : out   std_logic;
    DGOOD         : out   std_logic;
    DINT          : out   std_logic;
    DWAIT         : out   std_logic;
    LOK           : out   std_logic_vector(16 downto 1);
    RT            : out   std_logic_vector(16 downto 1);
    TX_DIS        : out   std_logic_vector(16 downto 1);
    IPLL          : out   std_logic;
    OPLL          : out   std_logic;
    SFP_INP_N     : in    std_logic_vector(15 downto 0);
    SFP_INP_P     : in    std_logic_vector(15 downto 0);
    SFP_OUT_N     : out   std_logic_vector(15 downto 0);
    SFP_OUT_P     : out   std_logic_vector(15 downto 0);
    FS_PE_11  : inout std_logic;
    ---------------------------------------------------------------------------
    -- sim
    ---------------------------------------------------------------------------
    OPT_DATA_IN : in std_logic_vector(16*HOW_MANY_CHANNELS-1 downto 0);
    OPT_DATA_OUT : out std_logic_vector(16*HOW_MANY_CHANNELS-1 downto 0);
    OPT_DATA_VALID_IN : in std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    OPT_DATA_VALID_OUT : out std_logic_vector(HOW_MANY_CHANNELS-1 downto 0)


    );
end component;


begin  -- of hub_tb
  HUB_SIM: hub
    port map (
        LVDS_CLK_200P => LVDS_CLK_200P_i,
        ADO_TTL       => ADO_TTL_i,
        DBAD          => DBAD_i,
        DGOOD         => DGOOD_i,
        DINT          => DINT_i,
        DWAIT         => DWAIT_i,
        LOK           => LOK_i,
        RT            => RT_i,
        TX_DIS        => TX_DIS_i,
        IPLL          => IPLL_i,
        OPLL          => OPLL_i,
        SFP_INP_N     => SFP_INP_N_i,
        SFP_INP_P     => SFP_INP_P_i,
        SFP_OUT_N     => SFP_OUT_N_i,
        SFP_OUT_P     => SFP_OUT_P_i
        FS_PE_11  =>
        OPT_DATA_IN =>
        OPT_DATA_OUT =>
        OPT_DATA_VALID_IN =>
        OPT_DATA_VALID_OUT =>

       clock_gclk : process
         begin
           SERDES_200P_i <= '0';
           SERDES_200N_i <= '1';
         wait for 5 ns;
           SERDES_200P_i <= '1';
           SERDES_200N_i <= '0';
         wait for 5 ns;
       end process;
end hub_tb;
