-------------------------------------------------------------------------------
-- Title         : trb_reply
-- Project       : HADES trigger new net 
-------------------------------------------------------------------------------
-- File          : trb_reply.vhd
-- Author        : Tiago Perez (tiago.perez@uni-giessen.de)
-- Created       : 2007/02/26 T. Perez
-- Last modified : 
-------------------------------------------------------------------------------
-- Description   : Black box. Reply the TRB comm protocol
-------------------------------------------------------------------------------
-- Modification history :
-- 2007/01/12 : created
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity trb_reply is
  port (
    SEND_OUT : in  std_logic;
    READ_OUT : in  std_logic;
    RUN_IN   : out std_logic;
    SEQNR_IN : out std_logic_vector(7 downto 0)
    );
end trb_reply;

architecture behavioral of trb_reply is

  signal SEQNR : std_logic_vector(7 downto 0) := (others => '0');
begin  -- behavioral
--  purpose: simulate TRB
--  type : combinational
--  inputs :
--  outputs:
 TRB_SIM: process
 begin                                -- process TRB_SIM
     wait until SEND_OUT = '1';   -- rise
     wait until SEND_OUT = '0';   -- fall
     wait for 1 ns;
     RUN_IN <= '1';
     wait until READ_OUT ='1';
     wait until READ_OUT ='0';
     wait for 3 ns;
     RUN_IN <= '0';
     SEQNR <= SEQNR + 1;
 end process TRB_SIM;
 SEQNR_IN <= SEQNR;
  

end behavioral;
