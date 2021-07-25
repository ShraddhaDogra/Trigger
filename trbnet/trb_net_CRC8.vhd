-------------------------------------------------------------------------------
-- Copyright (C) 2009 OutputLogic.com
-- This source file may be used and distributed without restriction
-- provided that this copyright statement is not removed from the file
-- and that any derivative work contains the original copyright notice
-- and the associated disclaimer.
--
-- THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
-- WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
-------------------------------------------------------------------------------
-- CRC module for data(7:0)
--   lfsr(7:0)=1+x^4+x^5+x^8;
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.trb_net_std.all;

entity trb_net_CRC8 is
  port(
    CLK       : in  std_logic;
    RESET     : in  std_logic;
    CLK_EN    : in  std_logic;
    DATA_IN   : in  std_logic_vector(7 downto 0);
    CRC_OUT   : out std_logic_vector(7 downto 0);
    CRC_match : out std_logic
    );
end entity;

architecture imp_crc of trb_net_CRC8 is
  signal lfsr_q: std_logic_vector (7 downto 0);
  signal lfsr_c: std_logic_vector (7 downto 0);
begin
    CRC_OUT <= lfsr_q;
    CRC_match <= not or_all(lfsr_c);

    lfsr_c(0) <= lfsr_q(0) xor lfsr_q(3) xor lfsr_q(4) xor lfsr_q(6) xor data_in(0) xor data_in(3) xor data_in(4) xor data_in(6);
    lfsr_c(1) <= lfsr_q(1) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(7) xor data_in(1) xor data_in(4) xor data_in(5) xor data_in(7);
    lfsr_c(2) <= lfsr_q(2) xor lfsr_q(5) xor lfsr_q(6) xor data_in(2) xor data_in(5) xor data_in(6);
    lfsr_c(3) <= lfsr_q(3) xor lfsr_q(6) xor lfsr_q(7) xor data_in(3) xor data_in(6) xor data_in(7);
    lfsr_c(4) <= lfsr_q(0) xor lfsr_q(3) xor lfsr_q(6) xor lfsr_q(7) xor data_in(0) xor data_in(3) xor data_in(6) xor data_in(7);
    lfsr_c(5) <= lfsr_q(0) xor lfsr_q(1) xor lfsr_q(3) xor lfsr_q(6) xor lfsr_q(7) xor data_in(0) xor data_in(1) xor data_in(3) xor data_in(6) xor data_in(7);
    lfsr_c(6) <= lfsr_q(1) xor lfsr_q(2) xor lfsr_q(4) xor lfsr_q(7) xor data_in(1) xor data_in(2) xor data_in(4) xor data_in(7);
    lfsr_c(7) <= lfsr_q(2) xor lfsr_q(3) xor lfsr_q(5) xor data_in(2) xor data_in(3) xor data_in(5);


    process (CLK) begin
      if rising_edge(CLK) then
        if (RESET = '1') then
          lfsr_q <= b"00000000";
        elsif (CLK_EN = '1') then
          lfsr_q <= lfsr_c;
        end if;
      end if;
    end process;
end architecture imp_crc;