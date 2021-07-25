library IEEE;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--library UNISIM;
--use UNISIM.VCOMPONENTS.all;
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.trb_net_std.all;

entity flexi_PCS_synch is
  generic (
    HOW_MANY_CHANNELS      :     positive);
  port (
    SYSTEM_CLK             : in  std_logic;
    CLK                    : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)-1 downto 0);
    RX_CLK                 : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*4-1 downto 0);
    RESET                  : in  std_logic;
    RXD                    : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
    MED_DATA_OUT           : out std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
    RX_K                   : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
    RX_RST                 : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*4-1 downto 0);
    CV                     : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
    MED_DATA_IN            : in  std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
    TXD_SYNCH              : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
    TX_K                   : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
    MED_DATAREADY_IN       : in  std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    MED_DATAREADY_OUT      : out std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    FLEXI_PCS_SYNCH_STATUS : out std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
    MED_PACKET_NUM_IN      : in  std_logic_vector(HOW_MANY_CHANNELS*c_NUM_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT     : out std_logic_vector(HOW_MANY_CHANNELS*c_NUM_WIDTH-1 downto 0);
    MED_READ_IN            : in  std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    MED_READ_OUT           : out std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    MED_ERROR_OUT          : out std_logic_vector(HOW_MANY_CHANNELS*3-1 downto 0);
    MED_STAT_OP           : out  std_logic_vector (HOW_MANY_CHANNELS*16-1 downto 0);
    MED_CTRL_OP           : in std_logic_vector (HOW_MANY_CHANNELS*16-1 downto 0)
    );
end flexi_PCS_synch;
architecture flexi_PCS_synch of flexi_PCS_synch is
  component flexi_PCS_channel_synch
    port (
      SYSTEM_CLK       : in  std_logic;
      TX_CLK           : in  std_logic;
      RX_CLK           : in  std_logic;
      RESET            : in  std_logic;
      RXD              : in  std_logic_vector(15 downto 0);
      RXD_SYNCH        : out std_logic_vector(15 downto 0);
      RX_K             : in  std_logic_vector(1 downto 0);
      RX_RST           : out std_logic;
      CV               : in  std_logic_vector(1 downto 0);
      TXD              : in  std_logic_vector(15 downto 0);
      TXD_SYNCH        : out std_logic_vector(15 downto 0);
      TX_K             : out std_logic_vector(1 downto 0);
      DATA_VALID_IN    : in  std_logic;
      DATA_VALID_OUT   : out std_logic;
      FLEXI_PCS_STATUS : out std_logic_vector(15 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_ERROR_OUT      : out std_logic_vector(2 downto 0);
      MED_READ_IN        : in std_logic
      );
  end component;
begin
  CHANNEL_GENERATE : for bit_index in 0 to HOW_MANY_CHANNELS-1 generate
  begin
    MED_READ_OUT <= (others => '1');

    SYNCH :flexi_PCS_channel_synch
      port map (
          SYSTEM_CLK       => SYSTEM_CLK,
          TX_CLK           => CLK(bit_index/4),      --4 different channles clk
          RX_CLK           => RX_CLK(bit_index),
          RESET            => RESET,
          RXD              => RXD((bit_index*16+15) downto bit_index*16),
          RXD_SYNCH        => MED_DATA_OUT((bit_index*16+15) downto bit_index*16),
          RX_K             => RX_K(bit_index*2+1 downto bit_index*2),
          RX_RST           => RX_RST(bit_index),
          CV               => CV((bit_index*2+1) downto bit_index*2),
          TXD              => MED_DATA_IN((bit_index*16+15) downto bit_index*16),
          TXD_SYNCH        => TXD_SYNCH((bit_index*16+15) downto bit_index*16),
          TX_K             => TX_K(bit_index*2+1 downto bit_index*2),
          DATA_VALID_IN    => MED_DATAREADY_IN(bit_index),
          DATA_VALID_OUT   => MED_DATAREADY_OUT(bit_index),
          FLEXI_PCS_STATUS => FLEXI_PCS_SYNCH_STATUS((bit_index*16+15) downto bit_index*16),
          MED_PACKET_NUM_OUT => MED_PACKET_NUM_OUT(((bit_index+1)*c_NUM_WIDTH-1) downto bit_index*c_NUM_WIDTH),
          MED_ERROR_OUT    => MED_ERROR_OUT((bit_index*3+2) downto bit_index*3),
          MED_READ_IN      => MED_READ_IN(bit_index)
          );
  end generate;
end flexi_PCS_synch;
