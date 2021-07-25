library IEEE;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.trb_net_std.all;

entity flexi_PCS_synch is
  generic (
    HOW_MANY_CHANNELS : positive;
    SYSTEM            : positive
    );
  port (
    RESET              : in  std_logic;
    SYSTEM_CLK         : in  std_logic;
    TX_CLK             : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)-1 downto 0);
    RX_CLK             : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*4-1 downto 0);
    RXD                : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
    RX_K               : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
    RX_RST             : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*4-1 downto 0);
    CV                 : in  std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
    TXD                : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*64-1 downto 0);
    TX_K               : out std_logic_vector(((HOW_MANY_CHANNELS+3)/4)*8-1 downto 0);
    MEDIA_STATUS       : in  std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
    MEDIA_CONTROL      : out std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
    MED_DATAREADY_IN   : in  std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    MED_DATA_IN        : in  std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
    MED_READ_OUT       : out std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    MED_DATA_OUT       : out std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
    MED_DATAREADY_OUT  : out std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    MED_READ_IN        : in  std_logic_vector(HOW_MANY_CHANNELS-1 downto 0);
    MED_PACKET_NUM_IN  : in  std_logic_vector(HOW_MANY_CHANNELS*c_NUM_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector(HOW_MANY_CHANNELS*c_NUM_WIDTH-1 downto 0);
    MED_STAT_OP        : out std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
    MED_CTRL_OP        : in  std_logic_vector(HOW_MANY_CHANNELS*16-1 downto 0);
    LINK_DEBUG         : out std_logic_vector(HOW_MANY_CHANNELS*32-1 downto 0)
    );
end flexi_PCS_synch;

architecture flexi_PCS_synch of flexi_PCS_synch is
  
  component flexi_PCS_channel_synch
    generic (
    SYSTEM            : positive
    );
    port (
      RESET              : in  std_logic;
      SYSTEM_CLK         : in  std_logic;
      TX_CLK             : in  std_logic;
      RX_CLK             : in  std_logic;
      RXD                : in  std_logic_vector(15 downto 0);
      RX_K               : in  std_logic_vector(1 downto 0);
      RX_RST             : out std_logic;
      CV                 : in  std_logic_vector(1 downto 0);
      TXD                : out std_logic_vector(15 downto 0);
      TX_K               : out std_logic_vector(1 downto 0);
      MEDIA_STATUS       : in  std_logic_vector(15 downto 0);
      MEDIA_CONTROL      : out std_logic_vector(15 downto 0);
      MED_DATAREADY_IN   : in  std_logic;
      MED_DATA_IN        : in  std_logic_vector(15 downto 0);
      MED_READ_OUT       : out std_logic;
      MED_DATA_OUT       : out std_logic_vector(15 downto 0);
      MED_DATAREADY_OUT  : out std_logic;
      MED_READ_IN        : in  std_logic;
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_STAT_OP        : out std_logic_vector(15 downto 0);
      MED_CTRL_OP        : in  std_logic_vector(15 downto 0);
      LINK_DEBUG         : out std_logic_vector(31 downto 0)
      );
  end component;
  
begin

  CHANNEL_GENERATE : for bit_index in 0 to HOW_MANY_CHANNELS-1 generate
  begin

    CHANNEL_GENERATE: flexi_PCS_channel_synch
      generic map (
        SYSTEM            =>  SYSTEM
        )
      port map (
        RESET              => RESET,
        SYSTEM_CLK         => SYSTEM_CLK,
        TX_CLK             => TX_CLK(bit_index/4),      --4 different channles clk,
        RX_CLK             => RX_CLK(bit_index),
        RXD                => RXD((bit_index*16+15) downto bit_index*16),
        RX_K               => RX_K(bit_index*2+1 downto bit_index*2),
        RX_RST             => RX_RST(bit_index),
        CV                 => CV((bit_index*2+1) downto bit_index*2),
        TXD                => TXD((bit_index*16+15) downto bit_index*16),
        TX_K               => TX_K(bit_index*2+1 downto bit_index*2),
        MEDIA_STATUS       => MEDIA_STATUS((bit_index*16+15) downto bit_index*16),
        MEDIA_CONTROL      => MEDIA_CONTROL((bit_index*16+15) downto bit_index*16),
        MED_DATAREADY_IN   => MED_DATAREADY_IN(bit_index),
        MED_DATA_IN        => MED_DATA_IN((bit_index*16+15) downto bit_index*16),
        MED_READ_OUT       => MED_READ_OUT(bit_index),
        MED_DATA_OUT       => MED_DATA_OUT((bit_index*16+15) downto bit_index*16),
        MED_DATAREADY_OUT  => MED_DATAREADY_OUT(bit_index),
        MED_READ_IN        => MED_READ_IN(bit_index),
        MED_PACKET_NUM_IN  => MED_PACKET_NUM_IN(((bit_index+1)*c_NUM_WIDTH-1) downto bit_index*c_NUM_WIDTH),
        MED_PACKET_NUM_OUT => MED_PACKET_NUM_OUT(((bit_index+1)*c_NUM_WIDTH-1) downto bit_index*c_NUM_WIDTH),
        MED_STAT_OP        => MED_STAT_OP((bit_index*16+15) downto bit_index*16),
        MED_CTRL_OP        => MED_CTRL_OP((bit_index*16+15) downto bit_index*16),
        LINK_DEBUG         => LINK_DEBUG((bit_index*32+31) downto bit_index*32)
        );

  end generate;
  
end flexi_PCS_synch;
