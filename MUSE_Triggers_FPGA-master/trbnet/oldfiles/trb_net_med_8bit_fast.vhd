--This entity provides data transfer of 55Bit in 4 16Bit packets via a 16Bit Bus
--with 8Bit data width plus 4 control Bits. 
--data is repacked to have 8 spare Bits in the end of each word instead on the 
--beginning. These Bits may be used for data integrity check later.
--The remaining four Bits on the LVDS cable are free to use at moment but should
--be reserved.

-------------------------------------------------
--format on LVDS: 0-7  Data
--                8-10 free
--                11   "handshake"
--                12   first packet indicator
--                13   transmission clock
--                14   carrier
--                15   parity(0-7)
-------------------------------------------------

-- "handshake": if this is low, you can not send, if it goes down during a transfer, 
-- then probably some data is lost

--Please check the timing report for setup/hold-errors on the receiving ports
--In case of an error, adjust the PHASE_SHIFT of the DCM. A change of one unit 
--results in a shift of (CLK_PERIOD/256)
--If the timing seems to be correct but the trbnet trb_net doesn't react, try 
--shifting the clock by 180 degrees.

--Version with spare bits at end, using 18_to16 was 1.8
-- 
-- Constraints for timing on hadcom dev board:
-- NET "LVDS_IN<13>" TNM_NET = LVDS_IN_CLK_GRP;
-- TIMESPEC "TS_LVDS_IN" = PERIOD LVDS_IN_CLK_GRP 10 ns HIGH 50 %;
-- INST "LVDS_IN<*>" TNM = "IN_DDR";
-- INST "LVDS_OUT<*>" TNM = "OUT_DDR";
-- INST lvds1/buf_MED_IN_fal* TNM = "falling_reg";
-- TIMEGRP "OUT_DDR" OFFSET = OUT 8 ns AFTER "CLK_IN";
-- TIMEGRP "IN_DDR" OFFSET = IN -2 ns VALID 1 BEFORE "LVDS_IN<13>";
-- TIMEGRP "IN_DDR" OFFSET = IN -7 ns VALID 1 BEFORE "LVDS_IN<13>" TIMEGRP "falling_reg";


--Constraints for timing on acromag:
-- #Constraints for LVDS 
-- NET "IO59_29P" TNM_NET = LVDS_IN_CLK_GRP;
-- TIMESPEC "TS_LVDS_IN" = PERIOD LVDS_IN_CLK_GRP 10 ns HIGH 50 %;
-- 
-- INST "io*_*p" TNM = "IN_DDR";
-- INST "io*_*n" TNM = "OUT_DDR";
-- INST trbnetendpoint1/lvds1/buf_MED_IN_fal* TNM = "falling_reg";
-- 
-- TIMEGRP "IN_DDR" OFFSET = IN -2 ns VALID 1 ns BEFORE "IO59_29P";
-- TIMEGRP "IN_DDR" OFFSET = IN -7 ns VALID 1 ns BEFORE "IO59_29P" TIMEGRP "falling_reg";
-- TIMEGRP "OUT_DDR" OFFSET = OUT 6.7 ns AFTER "FPGA_CLK";




LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use UNISIM.VComponents.all;
library work;
use work.trb_net_std.all;

--Entity decalaration for clock generator
entity trb_net_med_8bit_fast is
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    -- 1st part: from the medium to the internal logic (trbnet)
    INT_DATAREADY_OUT: out STD_LOGIC;
    INT_DATA_OUT:      out STD_LOGIC_VECTOR (15 downto 0); -- Data word
    INT_PACKET_NR_OUT: out STD_LOGIC_VECTOR (1 downto 0);
    INT_READ_IN:       in  STD_LOGIC; 
    INT_ERROR_OUT:     out STD_LOGIC_VECTOR (2 downto 0);  -- Status bits
    
    -- 2nd part: from the internal logic (trbnet) to the medium
    INT_DATAREADY_IN:  in  STD_LOGIC; -- Data word is offered for the Media 
    INT_DATA_IN:       in  STD_LOGIC_VECTOR (15 downto 0); -- Data word
    INT_PACKET_NR_IN:  in  STD_LOGIC_VECTOR (1 downto 0);
    INT_READ_OUT:      out STD_LOGIC; -- offered word is read
    INT_ERROR_IN:      in  STD_LOGIC_VECTOR (2 downto 0);  -- Status bits

    --  Media direction port
    -- in this case for the cable => 32 lines in total
    MED_DATA_OUT:             out STD_LOGIC_VECTOR (12 downto 0); -- Data word 
    MED_TRANSMISSION_CLK_OUT: out STD_LOGIC;
    MED_CARRIER_OUT:          out STD_LOGIC;
    MED_PARITY_OUT:           out STD_LOGIC;
    MED_DATA_IN:              in  STD_LOGIC_VECTOR (12 downto 0); -- Data word
    MED_TRANSMISSION_CLK_IN:  in  STD_LOGIC;
    MED_CARRIER_IN:           in  STD_LOGIC;
    MED_PARITY_IN:            in  STD_LOGIC;

    -- Status and control port => this never can hurt

    STAT:      out STD_LOGIC_VECTOR(31 downto 0);
                     --31-16 show the current lvds data output (two times eight bit)
    CTRL:      in  STD_LOGIC_VECTOR (31 downto 0)   
    );
end entity;

architecture trb_net_med_8bit_fast_arch of trb_net_med_8bit_fast is

component dualdatarate_flipflop
  generic(
    WIDTH : integer := 1
    );
  port(
    C0 : in std_logic;
    C1 : in std_logic;
    CE : in std_logic;
    CLR : in std_logic;
    D0 : in std_logic_vector(WIDTH-1 downto 0);
    D1 : in std_logic_vector(WIDTH-1 downto 0);
    PRE : in std_logic;
    Q : out std_logic_vector(WIDTH-1 downto 0)
    );
end component;


component trb_net_fifo_16bit_bram_dualport 
   port (read_clock_in:   IN  std_logic;
         write_clock_in:  IN  std_logic;
         read_enable_in:  IN  std_logic;
         write_enable_in: IN  std_logic;
         fifo_gsr_in:     IN  std_logic; --reset
         write_data_in:   IN  std_logic_vector(17 downto 0);
         read_data_out:   OUT std_logic_vector(17 downto 0);
         full_out:        OUT std_logic;
         empty_out:       OUT std_logic;
         fifostatus_out:  OUT std_logic_vector(3 downto 0)
         );
end component trb_net_fifo_16bit_bram_dualport;


  component trb_net_sbuf
    generic (DATA_WIDTH : integer := 16;
            VERSION: integer := 0);
    port(
      --  Misc
      CLK    : in std_logic;      
      RESET  : in std_logic;    
      CLK_EN : in std_logic;
      --  port to combinatorial logic
      COMB_DATAREADY_IN:  in  STD_LOGIC;  --comb logic provides data word
      COMB_next_READ_OUT: out STD_LOGIC;  --sbuf can read in NEXT cycle
      COMB_READ_IN:       in  STD_LOGIC;  --comb logic IS reading
      COMB_DATA_IN:       in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
      -- Port to synchronous output.
      SYN_DATAREADY_OUT:  out STD_LOGIC; 
      SYN_DATA_OUT:       out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
      SYN_READ_IN:        in  STD_LOGIC; 
      -- Status and control port
      STAT_BUFFER:        out STD_LOGIC
      );
  end component;
  
  component FDDRCPE
    port (
      Q : out STD_ULOGIC;
      C0 : in STD_ULOGIC;
      C1 : in STD_ULOGIC;
      CE : in STD_ULOGIC;
      CLR : in STD_ULOGIC;
      D0 : in STD_ULOGIC;
      D1 : in STD_ULOGIC;
      PRE : in STD_ULOGIC);
  end component;  

signal CLK_TRANS : std_logic;
signal fifo_data_in, next_fifo_data_in : std_logic_vector(17 downto 0);
signal fifo_data_out : std_logic_vector(17 downto 0);
signal fifo_full_out, fifo_empty_out : std_logic;
signal fifo_status_out : std_logic_vector(3 downto 0);
signal fifo_write_enable, next_fifo_write_enable : std_logic;
signal fifo_read_enable, last_fifo_read_enable : std_logic;

signal buf_MED_PARITY_OUT : std_logic;
signal buf_MED_CARRIER_OUT : std_logic;
signal buf_MED_TRANSMISSION_CLK_OUT : std_logic;
signal buf_MED_TRANSMISSION_CLK_IN : std_logic;
signal buf_MED_DATA_OUT : std_logic_vector(12 downto 0);
signal buf_MED_IN_fal : std_logic_vector(15 downto 0);
signal buf_MED_IN : std_logic_vector(31 downto 0);

signal buf_INT_DATA_OUT : std_logic_vector(17 downto 0);
signal buf_INT_DATAREADY_OUT : std_logic;
signal next_int_packet_nr_out, buf_int_packet_nr_out : std_logic_vector(1 downto 0);
signal next_send_data_byte1, send_data_byte1 : std_logic_vector(7 downto 0);
signal next_send_data_byte2, send_data_byte2 : std_logic_vector(7 downto 0);
signal next_send_data_byte1_parity, send_data_byte1_parity : std_logic;
signal next_send_data_byte2_parity, send_data_byte2_parity : std_logic;
signal next_send_dataready, send_dataready : std_logic;
signal next_send_packet1, send_packet1 : std_logic;
signal fifo_data_ready : std_logic;

signal buf_int_error_out, next_INT_ERROR_OUT : std_logic_vector(2 downto 0);
signal buf_INT_READ_OUT : std_logic;
signal FB_CLK, CLK_FB_Out, CLK_RECV_Out : std_logic;
signal sbuff_status : std_logic;
signal sbuff_next_read_out : std_logic;
signal buf_comb_data_in : std_logic_vector(17 downto 0);

signal DCM_LOCKED, RESET_RECV, next_RESET_RECV : std_logic;
begin

-----------------------------------------------------------------------
-- Fifo for incoming data
-----------------------------------------------------------------------
  LVDS_FIFO1 : trb_net_fifo_16bit_bram_dualport
    port map(
      read_clock_in   => CLK,
      write_clock_in  => CLK_TRANS,
      read_enable_in  => fifo_read_enable,
      write_enable_in => fifo_write_enable,
      fifo_gsr_in     => RESET_RECV,
      write_data_in   => fifo_data_in,
      read_data_out   => fifo_data_out,
      full_out        => fifo_full_out,
      empty_out       => fifo_empty_out,
      fifostatus_out  => fifo_status_out
      );




-----------------------------------------------------------------------
-- Getting clock from LVDS
-----------------------------------------------------------------------


U_DCM_RECV: DCM
  generic map( 
      CLKIN_PERIOD => 10.00, -- 30.30ns
      STARTUP_WAIT => FALSE,
      DESKEW_ADJUST => "SOURCE_SYNCHRONOUS",
      PHASE_SHIFT => 70,
      CLKOUT_PHASE_SHIFT => "FIXED"
      )  
  port map (
      CLKIN =>    MED_TRANSMISSION_CLK_IN,
      CLKFB =>    FB_CLK,
      DSSEN =>    '0',
      PSINCDEC => '0',
      PSEN =>     '0',
      PSCLK =>    '0',
      RST =>      RESET,
      CLK0 =>     CLK_FB_Out, -- for feedback
      CLK180=>    CLK_RECV_Out,
      LOCKED =>   DCM_LOCKED
     ); 
--      
U3_BUFG: BUFG  port map (I => CLK_FB_Out,   O => FB_CLK);
--U4_BUFG: BUFG  port map (I => CLK_RECV_Out, O => CLK_TRANS);
CLK_TRANS <= FB_CLK;

-----------------------------------------------------------------------
-- Preparing incoming data for fifo
-----------------------------------------------------------------------
  
  recv : process(buf_MED_IN)
    begin
      next_fifo_data_in(7 downto 0) <=  buf_MED_IN(7 downto 0);
      next_fifo_data_in(15 downto 8) <= buf_MED_IN(23 downto 16);
      next_fifo_data_in(17) <= ((buf_MED_IN(15) xnor xor_all(buf_MED_IN(7 downto 0))) or not buf_MED_IN(14)) and
                               ((buf_MED_IN(31) xnor xor_all(buf_MED_IN(23 downto 16))) or not buf_MED_IN(30));
                                                                   --parity check
      next_fifo_data_in(16) <= buf_MED_IN(12);  --first packet
      next_fifo_write_enable <= buf_MED_IN(14); --carrier
    end process;


  recv_reg : process(CLK_TRANS, RESET_RECV)
    begin
      if RESET_RECV = '1' then
        fifo_write_enable <= '0';
        fifo_data_in(15 downto 0) <= (others => '0');
        fifo_data_in(17) <= '0';
      elsif rising_edge(CLK_TRANS) then
        fifo_write_enable <= next_fifo_write_enable;
        fifo_data_in <= next_fifo_data_in;
      else
        fifo_write_enable <= fifo_write_enable;
        fifo_data_in <= fifo_data_in;
      end if;
    end process;

-----------------------------------------------------------------------
-- Reading data from LVDS
-----------------------------------------------------------------------


  lvds_reg_rising : process(CLK_TRANS, RESET_RECV)
    begin
      if RESET_RECV = '1' then
        buf_MED_IN(31 downto 0) <= (others => '0');
      elsif rising_edge(CLK_TRANS) then
        buf_MED_IN(14) <= MED_CARRIER_IN;
        buf_MED_IN(15) <= MED_PARITY_IN;
        buf_MED_IN(13) <= '0';
        buf_MED_IN(12 downto 0) <= MED_DATA_IN;
        buf_MED_IN(31 downto 16) <= buf_MED_IN_fal;
      else
        buf_MED_IN <= buf_MED_IN;
      end if;
   end process;

  lvds_reg_falling : process(CLK_TRANS, RESET_RECV)
    begin
      if RESET_RECV = '1' then
        buf_MED_IN_fal(15 downto 0) <= (others => '0');
      elsif falling_edge(CLK_TRANS) and MED_CARRIER_IN = '1' then
        buf_MED_IN_fal(14) <= MED_CARRIER_IN;
        buf_MED_IN_fal(15) <= MED_PARITY_IN;
        buf_MED_IN_fal(13) <= '1';
        buf_MED_IN_fal(12 downto 0) <= MED_DATA_IN;
      else
        buf_MED_IN_fal <= buf_MED_IN_fal;
      end if;
   end process; 

-----------------------------------------------------------------------
-- Reading data from fifo, offering to INT
-----------------------------------------------------------------------
  
  process(sbuff_next_read_out, fifo_empty_out, last_fifo_read_enable,
          fifo_data_out, buf_int_packet_nr_out, DCM_LOCKED)
    begin
      fifo_read_enable <= sbuff_next_read_out and not fifo_empty_out;
      next_int_error_out <= ERROR_OK;
    
      if last_fifo_read_enable = '1' and fifo_data_out(16) = '1' then
        next_int_packet_nr_out <= "00";
      elsif last_fifo_read_enable = '1' then
        next_int_packet_nr_out <= buf_int_packet_nr_out + 1;
      else
        next_int_packet_nr_out <= buf_int_packet_nr_out;
      end if;    
    
      if last_fifo_read_enable = '1' then
        --next_int_data_out <= fifo_data_out(15 downto 0);
        --next_int_dataready_out <= '1';
        
        if fifo_data_out(17) = '0' then
          next_int_error_out <= ERROR_FATAL;
        else
          next_int_error_out <= ERROR_OK;
        end if;
        if fifo_data_out(16) = '1' and buf_int_packet_nr_out /= "11" then
          next_int_error_out <= ERROR_ENCOD;
        end if;
      end if;
      if DCM_LOCKED = '0' then     --without a locked clock -> no transmission possible
        next_int_error_out <= ERROR_NC;
      end if;
    end process;

  process(CLK,RESET_RECV)
    begin
      if rising_edge(CLK) then
        if RESET_RECV = '1' then
          last_fifo_read_enable <= '0';
          buf_int_error_out <= ERROR_NC;
          buf_int_packet_nr_out <= "00";
        else
          last_fifo_read_enable <= fifo_read_enable;
          buf_int_error_out <= next_int_error_out;
          buf_int_packet_nr_out <= next_int_packet_nr_out;
        end if;
      end if;
    end process;

buf_comb_data_in(15 downto 0)  <= fifo_data_out(15 downto 0);
buf_comb_data_in(17 downto 16) <= next_int_packet_nr_out;


  SBUF_fifo_to_int : trb_net_sbuf
    generic map(DATA_WIDTH => 18, VERSION => 0)
    port map   (
        CLK    => CLK,
        RESET  => RESET_RECV,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN  => last_fifo_read_enable,
        COMB_next_READ_OUT => sbuff_next_read_out,
        COMB_READ_IN       => '1',
        COMB_DATA_IN       => buf_comb_data_in,
        -- Port to synchronous output.
        SYN_DATAREADY_OUT  => buf_INT_DATAREADY_OUT,
        SYN_DATA_OUT       => buf_INT_DATA_OUT,
        SYN_READ_IN        => INT_READ_IN,
        -- Status and control port
        STAT_BUFFER        => sbuff_status
        );


INT_DATA_OUT <= buf_int_data_out(15 downto 0);
INT_DATAREADY_OUT <= buf_INT_DATAREADY_OUT;
INT_PACKET_NR_OUT <= buf_int_data_out(17 downto 16);
INT_ERROR_OUT <= buf_int_error_out;


-----------------------------------------------------------------------
-- Sending data
-----------------------------------------------------------------------

buf_INT_READ_OUT <= not RESET_RECV;
INT_READ_OUT <= buf_INT_READ_OUT;
--RESET_RECV <= RESET or not DCM_LOCKED or not MED_DATA_IN(11);

  process(RESET,DCM_LOCKED,MED_DATA_IN(11))
  begin
    if DCM_LOCKED = '0' or not MED_DATA_IN(11) = '1' then
      next_RESET_RECV <= '1';
    else
      next_RESET_RECV <= '0';
    end if;
  end process;

  process(CLK)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        RESET_RECV <= '1';
      else
        RESET_RECV <= next_RESET_RECV;
      end if;
    end if;
  end process;


  process(INT_DATAREADY_IN, INT_DATA_IN,  INT_PACKET_NR_IN, buf_INT_READ_OUT, 
          send_data_byte1, send_data_byte2, send_packet1)
    begin

      next_send_dataready <= '0';
      next_send_data_byte1 <= (others => '0'); --send_data_byte1;
      next_send_data_byte2 <= (others => '0'); --send_data_byte2;
      next_send_data_byte1_parity <= '0'; --send_data_byte1_parity;
      next_send_data_byte2_parity <= '0'; --send_data_byte2_parity;
      next_send_packet1 <= '0';
      if INT_DATAREADY_IN = '1' and buf_INT_READ_OUT = '1' then
        if INT_PACKET_NR_IN = "00" and send_packet1 = '0' then
          next_send_packet1 <= '1';
        else
          next_send_packet1 <= '0';
        end if;
        next_send_data_byte1 <= INT_DATA_IN(15 downto 8);
        next_send_data_byte2 <= INT_DATA_IN(7 downto 0);
        next_send_dataready <= '1';
        next_send_data_byte2_parity <= xor_all(INT_DATA_IN(7 downto 0));
        next_send_data_byte1_parity <= xor_all(INT_DATA_IN(15 downto 8));
      end if;
    end process;

  process(CLK, RESET_RECV)
    begin
      if rising_edge(CLK) then
        if RESET_RECV = '1' then
          send_data_byte1 <= (others => '0');
          send_data_byte2 <= (others => '0');
          send_data_byte1_parity <= '0';
          send_data_byte2_parity <= '0';
          send_dataready <= '0';
          send_packet1 <= '0';
        else
          send_data_byte1 <= next_send_data_byte1 after 1 ns;
          send_data_byte2 <= next_send_data_byte2 after 1 ns;
          send_data_byte1_parity <= next_send_data_byte1_parity after 1 ns;
          send_data_byte2_parity <= next_send_data_byte2_parity after 1 ns;
          send_dataready <= next_send_dataready after 1 ns;
          send_packet1 <= next_send_packet1 after 1 ns;
        end if;
      end if;
    end process;

ddr_ff_dat : dualdatarate_flipflop
  generic map(
    WIDTH => 8
    )
  port map(
    Q   => buf_MED_DATA_OUT(7 downto 0),
    C0  => CLK,
    C1  => not CLK,
    CE  => '1',
    CLR => '0',
    D0  => send_data_byte2,
    D1  => send_data_byte1,
    PRE => '0'
    );

ddr_ff_parity : dualdatarate_flipflop
  generic map(
    WIDTH => 1
    )
  port map(
    Q(0)   => buf_MED_PARITY_OUT,
    C0  => CLK,
    C1  => not CLK,
    CE  => '1',
    CLR => '0',
    D0(0)  => send_data_byte2_parity,
    D1(0)  => send_data_byte1_parity,
    PRE => '0'
    );

ddr_ff_clk : dualdatarate_flipflop
  generic map(
    WIDTH => 1
    )
  port map(
    Q(0)   => buf_MED_TRANSMISSION_CLK_OUT,
    C0  => CLK,
    C1  => not CLK,
    CE  => '1',
    CLR => '0',
    D0(0)  => '1',
    D1(0)  => '0',
    PRE => '0'
    );

  process(CLK, RESET_RECV)
    begin
      if RESET_RECV = '1' then
        buf_MED_DATA_OUT(12) <= '0';
        buf_MED_CARRIER_OUT <= '0';
      elsif falling_edge(CLK) then
        buf_MED_DATA_OUT(12) <= send_packet1;
        buf_MED_CARRIER_OUT <= send_dataready;
      else
        buf_MED_DATA_OUT(12) <= buf_MED_DATA_OUT(12);
        buf_MED_CARRIER_OUT <= buf_MED_CARRIER_OUT;
      end if;
    end process;
    
buf_MED_DATA_OUT(11 downto 8) <= "0000";

-----------------------------------------------------------------------
-- Output generation
-----------------------------------------------------------------------
STAT(23 downto 16) <= send_data_byte1;
STAT(31 downto 24) <= send_data_byte2;
STAT(15 downto 0)  <= (others => '0');   
   
MED_PARITY_OUT <= buf_MED_PARITY_OUT;
MED_CARRIER_OUT <= buf_MED_CARRIER_OUT;
MED_TRANSMISSION_CLK_OUT <= buf_MED_TRANSMISSION_CLK_OUT;
MED_DATA_OUT(8 downto 0) <= buf_MED_DATA_OUT(8 downto 0);
MED_DATA_OUT(9) <= RESET_RECV;
MED_DATA_OUT(12) <= buf_MED_DATA_OUT(12);

--MED_DATA_OUT(8) <= '0';
--MED_DATA_OUT(12) <= buf_MED_DATA_OUT(12);
--MED_DATA_OUT(9 downto 8) <= buf_int_packet_nr_out;
--MED_DATA_OUT(11 downto 10) <= CONV_PACKET_NR_OUT;
--MED_DATA_OUT(9) <= CLK_TRANS;
--MED_DATA_OUT(8) <= buf_MED_TRANSMISSION_CLK_IN;
MED_DATA_OUT(10) <= fifo_data_in(0);
MED_DATA_OUT(11) <= (DCM_LOCKED);-- or (fifo_data_in(17) and not RESET_RECV);
-- MED_DATA_OUT(10) <= CLK_TRANS;
-- MED_DATA_OUT(11) <= fifo_write_enable;

end architecture;

