
---------------------------------------------------------------------------
--                                                                       --
--  Module      : fifoctlr_cc_v2.vhd              Last Update: 01/07/05  --
--                                                                       --
--  Description : FifO controller top level.                             --
--                Implements a 511x36 FifO w/common read/write clocks.   --
--                                                                       --
--  The following VHDL code implements a 511x36 FifO in a Virtex2        --
--  device.  The inputs are a Clock, a Read Enable, a Write Enable,      --
--  Write Data, and a FifO_gsr signal as an initial reset.  The outputs  --
--  are Read Data, Full, Empty, and the FifOcount outputs, which         --
--  indicate how full the FifO is.                                       --
--                                                                       --
--  Designer    : Nick Camilleri                                         --
--                                                                       --
--  Company     : Xilinx, Inc.                                           --
--                                                                       --
--  Disclaimer  : THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY    --
--                WHATSOEVER AND XILINX SPECifICALLY DISCLAIMS ANY       --
--                IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR     --
--                A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.         --
--                THEY ARE ONLY INTendED TO BE USED BY XILINX            --
--                CUSTOMERS, AND WITHIN XILINX DEVICES.                  --
--                                                                       --
--                Copyright (c) 2000 Xilinx, Inc.                        --
--                All rights reserved                                    --
--                                                                       --
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.trb_net_std.all;
library unisim;
use UNISIM.VComponents.all;

entity trb_net16_bram_fifo is
   port (clock_in:        IN  std_logic;
         read_enable_in:  IN  std_logic;
         write_enable_in: IN  std_logic;
         write_data_in:   IN  std_logic_vector(17 downto 0);
         fifo_gsr_in:     IN  std_logic;
         read_data_out:   OUT std_logic_vector(17 downto 0);
         full_out:        OUT std_logic;
         empty_out:       OUT std_logic;
         fifocount_out:   OUT std_logic_vector(3 downto 0));
end trb_net16_bram_fifo;

architecture trb_net16_bram_fifo_arch of trb_net16_bram_fifo is
   signal clock:                 std_logic;
   signal read_enable:           std_logic;
   signal write_enable:          std_logic;
   signal fifo_gsr:              std_logic;
   signal read_data:             std_logic_vector(17 downto 0) := "000000000000000000";
   signal write_data:            std_logic_vector(17 downto 0);
   signal full:                  std_logic;
   signal empty:                 std_logic;
   signal read_addr:             std_logic_vector(9 downto 0) := "0000000000";
   signal write_addr:            std_logic_vector(9 downto 0) := "0000000000";
   signal fcounter:              std_logic_vector(9 downto 0) := "0000000000";
   signal read_allow:            std_logic;
   signal write_allow:           std_logic;
   signal fcnt_allow:            std_logic;
   signal fcntandout:            std_logic_vector(3 downto 0);
   signal ra_or_fcnt0:           std_logic;
   signal wa_or_fcnt0:           std_logic;
   signal emptyg:                std_logic;
   signal fullg:                 std_logic;
   signal gnd_bus:               std_logic_vector(17 downto 0);
   signal gnd:                   std_logic;
   signal pwr:                   std_logic;
   signal read_after_write:      std_logic;
   signal read_after_empty:      std_logic;

component BUFG
   port (
      I: IN std_logic;  
      O: OUT std_logic);
end component;

component RAMB16_S18_S18
   port (
      ADDRA: IN std_logic_vector(9 downto 0);
      ADDRB: IN std_logic_vector(9 downto 0);
      DIA:   IN std_logic_vector(15 downto 0);
      DIB:   IN std_logic_vector(15 downto 0);
      DIPA:  IN std_logic_vector(1 downto 0);
      DIPB:  IN std_logic_vector(1 downto 0);
      WEA:   IN std_logic;
      WEB:   IN std_logic;
      CLKA:  IN std_logic;
      CLKB:  IN std_logic;
      SSRA:  IN std_logic;
      SSRB:  IN std_logic;
      ENA:   IN std_logic;
      ENB:   IN std_logic;
      DOA:   OUT std_logic_vector(15 downto 0);
      DOB:   OUT std_logic_vector(15 downto 0);
      DOPA:  OUT std_logic_vector(1 downto 0);
      DOPB:  OUT std_logic_vector(1 downto 0));
end component;

begin
   read_enable   <= read_enable_in;
   write_enable  <= write_enable_in;
   fifo_gsr      <= fifo_gsr_in;
   write_data    <= write_data_in;
   read_data_out <= read_data;

   full_out <= full;
   gnd_bus <= "000000000000000000";
   gnd <= '0';
   pwr <= '1';
   empty_out <= (empty or read_after_write) and read_after_empty;
   clock <= clock_in;

--------------------------------------------------------------------------
--                                                                      --
-- Block RAM instantiation for FifO.  Module is 1024x18, of which one   --
-- address location is sacrificed for the overall speed of the design.  --
--                                                                      --
--------------------------------------------------------------------------

bram1: RAMB16_S18_S18 port map (ADDRA => read_addr, ADDRB => write_addr,
              DIA => gnd_bus(17 downto 2), DIPA => gnd_bus(1 downto 0),
              DIB => write_data(17 downto 2), DIPB => write_data(1 downto 0),
              WEA => gnd, WEB => pwr, CLKA => clock, CLKB => clock, 
              SSRA => gnd, SSRB => gnd, ENA => read_allow, ENB => write_allow,
              DOA => read_data(17 downto 2), DOPA => read_data(1 downto 0),
              DOB => open, DOPB => open );

---------------------------------------------------------------
--                                                           --
--  Set allow flags, which control the clock enables for     --
--  read, write, and count operations.                       --
--                                                           --
---------------------------------------------------------------
 
write_allow <= write_enable AND NOT fullg;
read_allow <= (read_enable or read_after_write) AND NOT empty;-- ;
fcnt_allow <= write_allow XOR read_allow; -- and not read_after_write

proc33: process (clock)
begin
  if rising_edge(clock) then
    if (fifo_gsr = '1') then
      read_after_write <= '0';
    else
      if empty = '1' and read_after_empty='1' and write_enable = '1' then
        read_after_write <= '1';
      else
        read_after_write <= '0';
      end if;
    end if;
  end if;
end process;

process(clock)
  begin
    if rising_edge(clock) then
      if fifo_gsr = '1' or (empty = '0' and emptyg = '1') then
        read_after_empty <= empty;
      elsif read_enable_in = '1' then
        read_after_empty <= '1';
      end if;
    end if;
  end process;

---------------------------------------------------------------
--                                                           --
--  Empty flag is set on fifo_gsr (initial), or when on the  --
--  next clock cycle, Write Enable is low, and either the    --
--  FifOcount is equal to 0, or it is equal to 1 and Read    --
--  Enable is high (about to go Empty).                      --
--                                                           --
---------------------------------------------------------------

ra_or_fcnt0 <= (read_allow OR NOT fcounter(0));

emptyg <= (not or_all(fcounter(9 downto 1)) AND ra_or_fcnt0) AND NOT write_allow;

proc3: process (clock, fifo_gsr)
begin
  if rising_edge(clock) then
    if (fifo_gsr = '1') then
      empty <= '1';
    else
      empty <= emptyg;
    end if;
  end if;
end process proc3;

---------------------------------------------------------------
--                                                           --
--  Full flag is set on fifo_gsr (but it is cleared on the   --
--  first valid clock edge after fifo_gsr is removed), or    --
--  when on the next clock cycle, Read Enable is low, and    --
--  either the FifOcount is equal to 3FF (hex), or it is     --
--  equal to 3FE and the Write Enable is high (about to go   --
--  Full).                                                   --
--                                                           --
---------------------------------------------------------------

--wa_or_fcnt0 <= (write_allow OR fcounter(0));
wa_or_fcnt0 <= fcounter(0);
fullg <= (and_all(fcounter(9 downto 1)) AND wa_or_fcnt0 AND NOT read_allow);

proc4: process (clock, fifo_gsr)
begin
  if rising_edge(clock) then
    if (fifo_gsr = '1') then
      full <= '1';
    else
      full <= fullg;
    end if;
  end if;
end process proc4;

----------------------------------------------------------------
--                                                            --
--  Generation of Read and Write address pointers.  They now  --
--  use binary counters, because it is simpler in simulation, --
--  and the previous LFSR implementation wasn't in the        --
--  critical path.                                            --
--                                                            --
----------------------------------------------------------------

proc5: process (clock, fifo_gsr)
begin
  if rising_edge(clock) then
    if (fifo_gsr = '1') then
      read_addr <= (others => '0');
    elsif (read_allow = '1') then
      read_addr <= read_addr + '1';
    end if;
  end if;
end process proc5;

proc6: process (clock, fifo_gsr)
begin
  if rising_edge(clock) then
    if (fifo_gsr = '1') then
      write_addr <= "0000000000";
    elsif (write_allow = '1') then
      write_addr <= write_addr + '1';
    end if;
  end if;
end process proc6;

----------------------------------------------------------------
--                                                            --
--  Generation of FifOcount outputs.  Used to determine how   --
--  full FifO is, based on a counter that keeps track of how  --
--  many words are in the FifO.  Also used to generate Full   --
--  and Empty flags.  Only the upper four bits of the counter --
--  are sent outside the module.                              --
--                                                            --
----------------------------------------------------------------

proc7: process (clock, fifo_gsr)
begin
  if rising_edge(clock) then
    if (fifo_gsr = '1') then
      fcounter <= "0000000000";
    elsif (fcnt_allow = '1') then
      if (read_allow = '1') then -- and read_after_write = '0'
        fcounter <= fcounter - '1';
      else
        fcounter <= fcounter + '1';
      end if;
    end if;
  end if;
end process proc7;

fifocount_out <= fcounter(9 downto 6);

end architecture;

