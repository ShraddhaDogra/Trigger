-- ***********************************************************************************
-- ***********************************************************************************
--
--   MONITOR config file
--   -------------------
--
--   This file sets up the monitoring system
--
--
--
--
--
--
-- ***********************************************************************************
-- ***********************************************************************************


library ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;



package monitor_config is


constant FIFO_NUM : integer range 2 to 30 := 16;    -- How many FIFOs do we need?
constant FIFO_BUS : integer range 16 to 32 := 32;   -- Width of the widest FIFO (the effective port width, hence the bus)

constant REG_NUM  : integer range 2 to 40 := 4;     -- Amount of simple Register cells
constant REG_BUS  : integer range 2 to 32 := 32;    -- The width of the biggest Register, hence the reg bus

constant EXT_BUS  : integer range 32 to 32 := 32;   -- The extrenal bus width to which the monitor will be connected
constant ARCH     : string(1 to 8) := "_virtex4";


type fifo_generic is record
	fifo_type : string(1 to 12);          -- The FIFO cell identifier, e.g. "32x512" or "8x16"
  f_low     : integer range 0 to 255;   -- from 10 ns to 2560 ns, the automatic strobe signal
  f_high    : integer range 0 to 30;    -- 10*2**2**f_high ns if this is set, f_low is ignored
	timer     : integer range 0 to 2;     -- timer input port
	t_res     : integer range 0 to 31;    -- from which bit on the timer will be taken
	t_size    : integer range 0 to 32;    -- size of the timestamp in the package
	d_size    : integer range 0 to 32;    -- size of data in the package
	i_size    : integer range 0 to 32;    -- size of additional information from the external port in the package
	ref       : integer range 0 to 65535; -- the global monitoring signal reference
end record;

type fifo_generics is array(0 to 29) of fifo_generic;



type reg_generic is record
    id     : integer range 0 to 39;
    width  : integer range 1 to 32;
end record;

type reg_generics is array(0 to 39) of reg_generic;




type cfg_generic is record
		id   : integer range 0 to 29;
    init : std_logic_vector(7 downto 0);
end record;

type cfg_generics is array(0 to 29) of cfg_generic;



--  FIFO cells implemented for the VIRTEX4
--
--
--    32x512  : virtex4_fifo_32x512
--    16x1024 : virtex4_fifo_16x1024
--
--



constant fifo_16x1024  : string := "fifo_16x1024";
constant fifo_32x512   : string := "fifo_32x512 ";



constant fifos : fifo_generics :=
  (
                                 --      type          f_low    f_high   timer  t_res   t_size  d_size   i_size  ref

                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,   0   ),

                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,   1   ),

                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,   2   ),

                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,   3   ),

                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,   4   ),

                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,   5   ),

                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,   6   ),

                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,   7   ),

                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,   8   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,   9   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,  10   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,  11   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,  12   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,  13   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,  14   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   16  ,   16   ,   0   ,  15   ),
                                  
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   ),
                                  (    fifo_32x512   ,   0   ,   0   ,   0   ,   0   ,   0   ,   32   ,   0   ,   2   )



  );



                                 --     SIZE                                                      SIZE

constant reg0:  reg_generic  := ( 0  ,   32   );         constant reg20:  reg_generic  := ( 20 ,   32   );
constant reg1:  reg_generic  := ( 1  ,   32   );         constant reg21:  reg_generic  := ( 21 ,   32   );
constant reg2:  reg_generic  := ( 2  ,   32   );         constant reg22:  reg_generic  := ( 22 ,   32   );
constant reg3:  reg_generic  := ( 3  ,   32   );         constant reg23:  reg_generic  := ( 23 ,   32   );
constant reg4:  reg_generic  := ( 4  ,   32   );         constant reg24:  reg_generic  := ( 24 ,   32   );
constant reg5:  reg_generic  := ( 5  ,   32   );         constant reg25:  reg_generic  := ( 25 ,   32   );
constant reg6:  reg_generic  := ( 6  ,   32   );         constant reg26:  reg_generic  := ( 26 ,   32   );
constant reg7:  reg_generic  := ( 7  ,   32   );         constant reg27:  reg_generic  := ( 27 ,   32   );
constant reg8:  reg_generic  := ( 8  ,   32   );         constant reg28:  reg_generic  := ( 28 ,   32   );
constant reg9:  reg_generic  := ( 9  ,   32   );         constant reg29:  reg_generic  := ( 29 ,   32   );
constant reg10: reg_generic  := ( 10 ,   32   );         constant reg30:  reg_generic  := ( 30 ,   32   );
constant reg11: reg_generic  := ( 11 ,   32   );         constant reg31:  reg_generic  := ( 31 ,   32   );
constant reg12: reg_generic  := ( 12 ,   32   );         constant reg32:  reg_generic  := ( 32 ,   32   );
constant reg13: reg_generic  := ( 13 ,   32   );         constant reg33:  reg_generic  := ( 33 ,   32   );
constant reg14: reg_generic  := ( 14 ,   32   );         constant reg34:  reg_generic  := ( 34 ,   32   );
constant reg15: reg_generic  := ( 15 ,   32   );         constant reg35:  reg_generic  := ( 35 ,   32   );
constant reg16: reg_generic  := ( 16 ,   32   );         constant reg36:  reg_generic  := ( 36 ,   32   );
constant reg17: reg_generic  := ( 17 ,   32   );         constant reg37:  reg_generic  := ( 37 ,   32   );
constant reg18: reg_generic  := ( 18 ,   32   );         constant reg38:  reg_generic  := ( 38 ,   32   );
constant reg19: reg_generic  := ( 19 ,   32   );         constant reg39:  reg_generic  := ( 39 ,   32   );





--              Init value: - , - , - , automatic , pause , diff , ringbuffer , reset

constant cfg0   : cfg_generic := ( 0  ,   "00010100"   );
constant cfg1   : cfg_generic := ( 1  ,   "00010100"   );
constant cfg2   : cfg_generic := ( 2  ,   "00010100"   );
constant cfg3   : cfg_generic := ( 3  ,   "00010100"   );
constant cfg4   : cfg_generic := ( 4  ,   "00010100"   );
constant cfg5   : cfg_generic := ( 5  ,   "00010100"   );
constant cfg6   : cfg_generic := ( 6  ,   "00010100"   );
constant cfg7   : cfg_generic := ( 7  ,   "00010100"   );
constant cfg8   : cfg_generic := ( 8  ,   "00010100"   );
constant cfg9   : cfg_generic := ( 9  ,   "00010100"   );
constant cfg10  : cfg_generic := ( 10 ,   "00010100"   );
constant cfg11  : cfg_generic := ( 11 ,   "00010100"   );
constant cfg12  : cfg_generic := ( 12 ,   "00010100"   );
constant cfg13  : cfg_generic := ( 13 ,   "00010100"   );
constant cfg14  : cfg_generic := ( 14 ,   "00010100"   );
constant cfg15  : cfg_generic := ( 15 ,   "00010100"   );
constant cfg16  : cfg_generic := ( 16 ,   "00000000"   );
constant cfg17  : cfg_generic := ( 17 ,   "00000000"   );
constant cfg18  : cfg_generic := ( 18 ,   "00000000"   );
constant cfg19  : cfg_generic := ( 19 ,   "00000000"   );
constant cfg20  : cfg_generic := ( 20 ,   "00000000"   );
constant cfg21  : cfg_generic := ( 21 ,   "00000000"   );
constant cfg22  : cfg_generic := ( 22 ,   "00000000"   );
constant cfg23  : cfg_generic := ( 23 ,   "00000000"   );
constant cfg24  : cfg_generic := ( 24 ,   "00000000"   );
constant cfg25  : cfg_generic := ( 25 ,   "00000000"   );
constant cfg26  : cfg_generic := ( 26 ,   "00000000"   );
constant cfg27  : cfg_generic := ( 27 ,   "00000000"   );
constant cfg28  : cfg_generic := ( 28 ,   "00000000"   );
constant cfg29  : cfg_generic := ( 29 ,   "00000000"   );











constant regs : reg_generics :=
	(
		reg0, reg1, reg2, reg3,	reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14,
		reg15, reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23,	reg24, reg25, reg26, reg27,
		reg28, reg29, reg30, reg31, reg32, reg33,  reg34, reg35, reg36, reg37, reg38, reg39
	);



constant cfgs : cfg_generics :=
	(
	  cfg0, cfg1, cfg2, cfg3, cfg4, cfg5, cfg6, cfg7, cfg8, cfg9, cfg10, cfg11, cfg12, cfg13, cfg14,
	  cfg15, cfg16, cfg17, cfg18, cfg19, cfg20, cfg21, cfg22, cfg23, cfg24, cfg25, cfg26, cfg27,
	  cfg28, cfg29
	);




function Log2_monitor( input:integer ) return integer;



end package monitor_config;






package body monitor_config is


  function Log2_monitor( input:integer ) return integer is
    variable temp,log:integer;
  begin
    temp:=input;
    log:=0;
    while (temp /= 0) loop
      temp:=temp/2;
      log:=log+1;
    end loop;
    return log;
  end function Log2_monitor;



end package body monitor_config;