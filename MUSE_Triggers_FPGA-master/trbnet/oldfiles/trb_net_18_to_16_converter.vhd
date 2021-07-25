
-----------------------------------
--D18 data structure
--   XXXXXXXX0+++++++  00
--   1+++++++2+++++++  01
--   3+++++++4+++++++  10
--   5+++++++6+++++++  11
------------------------------------
--X unused, / error+parity, + data
------------------------------------



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.trb_net_std.all;

--Entity decalaration for clock generator
entity trb_net_18_to_16_converter is
  generic ( VERSION : integer := 0);  --Version of included sbufs
  port(
    --  Misc
    CLK    : in std_logic;      
    RESET  : in std_logic;    
    CLK_EN : in std_logic;
    
    D18_DATAREADY_IN:  in STD_LOGIC;
    D18_PACKET_NUM_IN: in STD_LOGIC_VECTOR(1 downto 0);
    D18_DATA_IN:       in STD_LOGIC_VECTOR (15 downto 0); -- Data word
    D18_READ_OUT:      out STD_LOGIC; 
    
    D16_DATAREADY_OUT:  out STD_LOGIC;
    D16_DATA_OUT:       out STD_LOGIC_VECTOR (15 downto 0); -- Data word
    D16_READ_IN:        in STD_LOGIC; 
    D16_PACKET_NUM_OUT: out STD_LOGIC_VECTOR(1 downto 0);
   
    D18_DATAREADY_OUT:  out STD_LOGIC;
    D18_PACKET_NUM_OUT: out STD_LOGIC_VECTOR(1 downto 0);
    D18_DATA_OUT:       out STD_LOGIC_VECTOR (15 downto 0); -- Data word
    D18_READ_IN:        in STD_LOGIC; 
    
    D16_DATAREADY_IN:  in STD_LOGIC;
    D16_DATA_IN:       in STD_LOGIC_VECTOR (15 downto 0); -- Data word
    D16_READ_OUT:      out STD_LOGIC;   
    D16_PACKET_NUM_IN: in STD_LOGIC_VECTOR(1 downto 0)
   );
end entity;
    
architecture trb_net_18_to_16_converter_arch of trb_net_18_to_16_converter is
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
      -- the COMB_next_READ_OUT should be connected via comb. logic to a register
      -- to provide COMB_READ_IN (feedback path with 1 cycle delay)
      -- The "REAL" READ_OUT can be constructed in the comb via COMB_next_READ_
      -- OUT and the READ_IN: If one of these is ='1', no problem to read in next
      -- step.
      COMB_DATA_IN:       in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
      -- Port to synchronous output.
      SYN_DATAREADY_OUT:  out STD_LOGIC; 
      SYN_DATA_OUT:       out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0); -- Data word
      SYN_READ_IN:        in  STD_LOGIC; 
      -- Status and control port
      STAT_BUFFER:        out STD_LOGIC
      );
  end component;

signal dbuf18_comb_dataready_in : std_logic;
signal dbuf18_next_read_out     : std_logic;
signal dbuf18_comb_read_in      : std_logic;
signal dbuf18_comb_data_in, buf_D16_DATA_OUT     : std_logic_vector(17 downto 0);
signal dbuf18_status            : std_logic_vector(31 downto 0);
signal buffer_dbuf18_comb_data_in      : std_logic_vector(7 downto 0);
signal next_buffer_dbuf18_comb_data_in : std_logic_vector(7 downto 0);
signal next_buf_D18_READ_OUT, buf_D18_READ_OUT   : std_logic;
signal D18_PACKET4, last_D18_PACKET4   : std_logic;


signal dbuf16_comb_dataready_in : std_logic;
signal dbuf16_next_read_out     : std_logic;
signal dbuf16_comb_read_in      : std_logic;
signal dbuf16_comb_data_in, buf_D18_data_out     : std_logic_vector(17 downto 0);
signal dbuf16_status            : std_logic_vector(31 downto 0);
signal buffer_dbuf16_comb_data_in      : std_logic_vector(7 downto 0);
signal next_buffer_dbuf16_comb_data_in : std_logic_vector(7 downto 0);
signal next_buf_D16_READ_OUT, buf_D16_READ_OUT   : std_logic;
signal D16_packet, next_D16_packet     : std_logic_vector(1 downto 0);
signal last_dbuf18_next_read_out : std_logic;


begin

-----------------------------------------------------------
--Direction 18 to 16
-----------------------------------------------------------



next_buf_D18_READ_OUT <= dbuf18_next_read_out;--and not D18_PACKET4;
D18_READ_OUT <= buf_D18_READ_OUT;
  
  D18to16 : process(buffer_dbuf18_comb_data_in, dbuf18_comb_data_in, last_D18_PACKET4,
                   buf_D18_READ_OUT, D18_DATAREADY_IN, D18_PACKET_NUM_IN, D18_DATA_IN,
                   last_dbuf18_next_read_out)
    variable newdata : std_logic;
    begin
      dbuf18_comb_dataready_in <= '0';
      next_buffer_dbuf18_comb_data_in <= buffer_dbuf18_comb_data_in;
      dbuf18_comb_data_in <= dbuf18_comb_data_in;
      D18_PACKET4 <= '0';


      if buf_D18_READ_OUT = '1' and D18_DATAREADY_IN = '1' then
        newdata := '1';
      else
        newdata := '0';
      end if;


      if ((D18_PACKET_NUM_IN /= "00" and newdata = '1') or last_D18_PACKET4 = '1') then
        dbuf18_comb_dataready_in <= '1';
      end if;


      if newdata = '1' and D18_PACKET_NUM_IN /= "00" then
        dbuf18_comb_data_in(7 downto 0) <= D18_DATA_IN(15 downto 8);
      else
        dbuf18_comb_data_in(7 downto 0) <= D18_DATA_IN(15 downto 8);--(others => '0');
      end if;

      if newdata = '1' or last_D18_PACKET4 = '1' then
        dbuf18_comb_data_in(15 downto 8)  <= buffer_dbuf18_comb_data_in(7 downto 0);
        if last_D18_PACKET4 = '0' then
          dbuf18_comb_data_in(17 downto 16) <= D18_PACKET_NUM_IN - 1;
        else
          dbuf18_comb_data_in(17 downto 16) <= "11";
        end if;
      else
        dbuf18_comb_data_in(15 downto 8)  <= (others => '0');
        dbuf18_comb_data_in(17 downto 16) <= "00";
      end if;


      if (D18_PACKET_NUM_IN = "11" and newdata = '1') or (last_D18_PACKET4 = '1' and last_dbuf18_next_read_out = '0') then
        D18_PACKET4 <= '1';
      end if;      

      if newdata = '1' then
        next_buffer_dbuf18_comb_data_in <= D18_DATA_IN(7 downto 0);
      end if;


    end process;
  
  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          buffer_dbuf18_comb_data_in <= (others => '0');
          last_D18_PACKET4 <= '0';
          buf_D18_READ_OUT <= '0';
          last_dbuf18_next_read_out <= '0';
        else
          buffer_dbuf18_comb_data_in <= next_buffer_dbuf18_comb_data_in;
          last_D18_PACKET4 <= D18_PACKET4;
          buf_D18_READ_OUT <= next_buf_D18_READ_OUT;
          last_dbuf18_next_read_out <= dbuf18_next_read_out;
        end if;
      end if;
    end process; 


  DBUF18 : trb_net_sbuf          --dbuf from 18Bit to 16Bit
    generic map(DATA_WIDTH => 18, VERSION => VERSION)
    port map   (
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN  => dbuf18_comb_dataready_in,
        COMB_next_READ_OUT => dbuf18_next_read_out,
        COMB_READ_IN       => last_dbuf18_next_read_out,
        COMB_DATA_IN       => dbuf18_comb_data_in,
        -- Port to synchronous output.
        SYN_DATAREADY_OUT  => D16_DATAREADY_OUT,
        SYN_DATA_OUT       => buf_D16_DATA_OUT,
        SYN_READ_IN        => D16_READ_IN,
        -- Status and control port
        STAT_BUFFER        => dbuf18_status(0)
        );

D16_DATA_OUT       <= buf_D16_DATA_OUT(15 downto 0);
D16_PACKET_NUM_OUT <= buf_D16_DATA_OUT(17 downto 16);




-----------------------------------------------------------
--Direction 16 to 18
-----------------------------------------------------------

next_buf_D16_READ_OUT <= dbuf16_next_read_out;
D16_READ_OUT <= buf_D16_READ_OUT;
dbuf16_comb_data_in(15 downto 8) <= (others => '0');
  D16to18 : process(buffer_dbuf16_comb_data_in, dbuf16_comb_data_in,
                   buf_D16_READ_OUT, D16_DATAREADY_IN, D16_DATA_IN, D16_PACKET_NUM_IN)
    variable newdata : std_logic;
    begin

      if buf_D16_READ_OUT = '1' and D16_DATAREADY_IN = '1' then
        newdata := '1';
      else
        newdata := '0';
      end if;

      dbuf16_comb_dataready_in <= newdata;
      --next_buffer_dbuf16_comb_data_in <= buffer_dbuf16_comb_data_in;
      --dbuf16_comb_data_in <= dbuf16_comb_data_in;

      dbuf16_comb_data_in(17 downto 16) <= D16_PACKET_NUM_IN;

      if newdata = '1' then
        dbuf16_comb_data_in(7 downto 0) <= D16_DATA_IN(15 downto 8);
      else
        dbuf16_comb_data_in(7 downto 0) <= (others => '0');
      end if;

      if newdata = '1' then
        if D16_PACKET_NUM_IN = "11" then
          next_buffer_dbuf16_comb_data_in <= (others => '0');
        else
          next_buffer_dbuf16_comb_data_in <= D16_DATA_IN(7 downto 0);
        end if;
      else
        next_buffer_dbuf16_comb_data_in <= buffer_dbuf16_comb_data_in;
      end if;
    end process;
  
  process(CLK, RESET)
    begin
      if RESET = '1' then
        buffer_dbuf16_comb_data_in <= (others => '0');
        --D16_packet <= "00";
        buf_D16_READ_OUT <= '0';
      elsif rising_edge(CLK) then
        buffer_dbuf16_comb_data_in <= next_buffer_dbuf16_comb_data_in;
        --D16_packet <= next_D16_packet;
        buf_D16_READ_OUT <= next_buf_D16_READ_OUT;
      else
        buffer_dbuf16_comb_data_in <= buffer_dbuf16_comb_data_in;
        --D16_packet <= D16_packet;
        buf_D16_READ_OUT <= buf_D16_READ_OUT;
      end if;
    end process; 


  DBUF16 : trb_net_sbuf          --dbuf from 16Bit to 18Bit
    generic map(DATA_WIDTH => 18, VERSION => VERSION)
    port map   (
        CLK    => CLK,
        RESET  => RESET,
        CLK_EN => CLK_EN,
        COMB_DATAREADY_IN  => dbuf16_comb_dataready_in,
        COMB_next_READ_OUT => dbuf16_next_read_out,
        COMB_READ_IN       => dbuf16_comb_read_in,
        COMB_DATA_IN       => dbuf16_comb_data_in,
        -- Port to synchronous output.
        SYN_DATAREADY_OUT  => D18_DATAREADY_OUT,
        SYN_DATA_OUT       => buf_D18_data_out,
        SYN_READ_IN        => D18_READ_IN,
        -- Status and control port
        STAT_BUFFER        => dbuf16_status(0)
        );

D18_DATA_OUT       <= buf_D18_data_out(15 downto 0);
D18_PACKET_NUM_OUT <= buf_D18_data_out(17 downto 16);

  dbuf16_read_in_gen : process(CLK, RESET)
    begin
      if RESET = '1' then
        dbuf16_comb_read_in <= '0';
      elsif rising_edge(CLK) then
        dbuf16_comb_read_in <= dbuf16_next_read_out;
      else
        dbuf16_comb_read_in <= dbuf16_comb_read_in;
      end if;
    end process;

end architecture;