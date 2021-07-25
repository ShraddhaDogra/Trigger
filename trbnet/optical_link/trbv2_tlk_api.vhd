library IEEE;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity trbv2_tlk_api is

  port (
    RESET               : in  std_logic;
    CLK                 : in  std_logic;
    TLK_CLK             : in  std_logic;
    TLK_ENABLE          : out std_logic;
    TLK_LCKREFN         : out std_logic;
    TLK_LOOPEN          : out std_logic;
    TLK_PRBSEN          : out std_logic;
    TLK_RXD             : in  std_logic_vector(15 downto 0);
    TLK_RX_CLK          : in  std_logic;
    TLK_RX_DV           : in  std_logic;
    TLK_RX_ER           : in  std_logic;
    TLK_TXD             : out std_logic_vector(15 downto 0);
    TLK_TX_EN           : out std_logic;
    TLK_TX_ER           : out std_logic;
    DATA_OUT            : out std_logic_vector(15 downto 0);
    DATA_IN             : in  std_logic_vector(15 downto 0);
    DATA_VALID_IN       : in  std_logic;
    DATA_VALID_OUT      : out std_logic;
    TLK_API_REGISTER_00 : out std_logic_vector(31 downto 0)
    );
end trbv2_tlk_api;
architecture trbv2_tlk_api of trbv2_tlk_api is
  component trbv2_tlk_api_fifo
    port (
      din           : IN  std_logic_VECTOR(17 downto 0);
      rd_clk        : IN  std_logic;
      rd_en         : IN  std_logic;
      rst           : IN  std_logic;
      wr_clk        : IN  std_logic;
      wr_en         : IN  std_logic;
      dout          : OUT std_logic_VECTOR(17 downto 0);
      empty         : OUT std_logic;
      full          : OUT std_logic;
      rd_data_count : OUT std_logic_VECTOR(9 downto 0);
      wr_data_count : OUT std_logic_VECTOR(9 downto 0));
  end component;
  signal fifo_din_a : std_logic_vector(17 downto 0);
  signal fifo_dout_a : std_logic_vector(17 downto 0);
  signal fifo_rst_a : std_logic;
  signal fifo_rd_en_a : std_logic;
  signal fifo_rd_data_count_a : std_logic_vector(9 downto 0);
  signal fifo_wr_data_count_a : std_logic_vector(9 downto 0);
  signal fifo_empty_a : std_logic;
  signal fifo_full_a : std_logic;
  signal fifo_din_m : std_logic_vector(17 downto 0);
  signal fifo_dout_m : std_logic_vector(17 downto 0);
  signal fifo_rst_m : std_logic;
  signal fifo_rd_en_m : std_logic;
  signal fifo_rd_data_count_m : std_logic_vector(9 downto 0);
  signal fifo_wr_data_count_m : std_logic_vector(9 downto 0);
  signal fifo_empty_m : std_logic;
  signal fifo_full_m : std_logic;
  signal  reset_fifo_counter : std_logic_vector(7 downto 0);
begin
  -----------------------------------------------------------------------------
  -- api to media
  -----------------------------------------------------------------------------
  fifo_din_a <= TLK_RX_ER & TLK_RX_DV & TLK_RXD;

  OPTICAL_TO_FIFO_TO_API: trbv2_tlk_api_fifo
    port map (
        din           => fifo_din_a,
        rd_clk        => CLK,
        rd_en         => fifo_rd_en_a ,
        rst           => fifo_rst_a ,
        wr_clk        => TLK_RX_CLK,
        wr_en         => '1',
        dout          => fifo_dout_a,
        empty         => fifo_empty_a,
        full          => fifo_full_a,
        rd_data_count => fifo_rd_data_count_a,
        wr_data_count => fifo_wr_data_count_a);
  SYNCH_DATA_OUT: process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        DATA_VALID_OUT <= '0';
        DATA_OUT <= x"0000";
      else
        DATA_VALID_OUT <=  not(fifo_dout_a(17)) and  fifo_dout_a(16);
        DATA_OUT <= fifo_dout_a(15 downto 0);
      end if;
    end if;
  end process SYNCH_DATA_OUT;

  -----------------------------------------------------------------------------
  -- media to api
  -----------------------------------------------------------------------------
  fifo_din_m <= '0' & DATA_VALID_IN & DATA_IN;

  API_TO_FIFO_TO_OPTICAL: trbv2_tlk_api_fifo
    port map (
        din           => fifo_din_m,
        rd_clk        => TLK_CLK,
        rd_en         => fifo_rd_en_m ,
        rst           => fifo_rst_m ,
        wr_clk        => CLK,
        wr_en         => '1',
        dout          => fifo_dout_m,
        empty         => fifo_empty_m,
        full          => fifo_full_m,
        rd_data_count => fifo_rd_data_count_m,
        wr_data_count => fifo_wr_data_count_m);

  TLK_TXD  <= fifo_dout_m (15 downto 0);
  TLK_TX_EN <= fifo_dout_m(16);
  TLK_TX_ER <= '0';
  TLK_LOOPEN  <= '0';
  TLK_LCKREFN <= '1';
  TLK_ENABLE  <= '1';
  TLK_PRBSEN  <= '0';

  -----------------------------------------------------------------------------
  -- all
  -----------------------------------------------------------------------------
  RESET_FIFO_COUNTER_PROC: process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' or fifo_dout_a(17) = '1' then
        reset_fifo_counter <= x"00";
      elsif reset_fifo_counter < x"f0" then
        reset_fifo_counter <= reset_fifo_counter + 1;
      end if;
    end if;
  end process RESET_FIFO_COUNTER_PROC;
  fifo_rst_m <= '1' when reset_fifo_counter < x"40" else '0';
  fifo_rst_a <= '1' when reset_fifo_counter < x"40" else '0';
  fifo_rd_en_m <= '1' when reset_fifo_counter > x"46" else '0';
  fifo_rd_en_a <= '1' when reset_fifo_counter > x"46" else '0';
end trbv2_tlk_api;
