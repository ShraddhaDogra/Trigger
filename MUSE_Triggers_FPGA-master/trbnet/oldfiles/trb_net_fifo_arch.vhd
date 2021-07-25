-- http://hades-wiki.gsi.de/cgi-bin/view/DaqSlowControl/TrbNetFifo

-- taken example from xapp256, but rewritten most of the parts
-- output fully synchonized with a "look-ahead" logic

library ieee;

use ieee.std_logic_1164.all;
USE ieee.std_logic_signed.ALL;
USE IEEE.numeric_std.ALL;
use work.trb_net_std.all;


architecture arch_trb_net_fifo of trb_net_fifo is
  component trb_net16_bram_fifo is
    port (clock_in:        IN  std_logic;
          read_enable_in:  IN  std_logic;
          write_enable_in: IN  std_logic;
          write_data_in:   IN  std_logic_vector(17 downto 0);
          fifo_gsr_in:     IN  std_logic;
          read_data_out:   OUT std_logic_vector(17 downto 0);
          full_out:        OUT std_logic;
          empty_out:       OUT std_logic;
          fifocount_out:   OUT std_logic_vector(3 downto 0));
  end component;
  
  component shift_lut_x16 
    generic (
      ADDRESS_WIDTH : integer := 0
      );
    port (
      D    : in std_logic;
      CE   : in std_logic;
      CLK  : in std_logic;
      A    : in std_logic_vector (ADDRESS_WIDTH+3 downto 0);
      Q    : out std_logic
      );
  end component;
    
  signal current_ADDRESS_SRL : std_logic_vector(DEPTH+1 downto 0);
  signal next_ADDRESS_SRL : std_logic_vector(DEPTH+1 downto 0);
  signal real_ADDRESS_SRL : std_logic_vector(DEPTH+1 downto 0);
  signal current_DOUT : std_logic_vector(WIDTH -1 downto 0);
  signal next_DOUT : std_logic_vector(WIDTH -1 downto 0);
  
  signal current_FULL, next_FULL : std_logic;
  signal current_EMPTY, next_EMPTY : std_logic;
  signal do_shift, do_shift_internal : std_logic;
  signal fifocount : std_logic_vector(3 downto 0);

begin

  gen_shiftreg : if DEPTH /= 8 or WIDTH /= 18 or FORCE_LUT = 1 generate
  
    FULL_OUT  <= current_FULL;
    EMPTY_OUT <= current_EMPTY;
    do_shift  <= do_shift_internal and CLK_EN;
  
    
  -- generate the shift registers
    
    inst_SRLC256E_MACRO : for i in 0 to (WIDTH - 1) generate
      U1 :  shift_lut_x16
        generic map (
          ADDRESS_WIDTH  => DEPTH - 3
          )
        port map (
          D    => DATA_IN(i),
          CE   => do_shift,
          CLK  => CLK,
          A    => real_ADDRESS_SRL(DEPTH downto 0),
          Q    => next_DOUT(i));
    end generate;
  
    reg_counter: process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_ADDRESS_SRL <= (others => '0');
        elsif CLK_EN = '1' then
          current_ADDRESS_SRL <= next_ADDRESS_SRL;
        else
          current_ADDRESS_SRL <= current_ADDRESS_SRL;
        end if;
      end if;
    end process;
  
  -- adress logic
    comb_counter: process(WRITE_ENABLE_IN, READ_ENABLE_IN, current_ADDRESS_SRL,
                          current_EMPTY, current_FULL)
    begin
      do_shift_internal <= WRITE_ENABLE_IN and not current_FULL;
      next_ADDRESS_SRL <= current_ADDRESS_SRL;
      real_ADDRESS_SRL <= current_ADDRESS_SRL - 1;
  
  -- no activity
      if WRITE_ENABLE_IN = '0' and READ_ENABLE_IN = '0' then
        next_ADDRESS_SRL <= current_ADDRESS_SRL;
        real_ADDRESS_SRL <= current_ADDRESS_SRL - 1;
  -- read from FIFO
      elsif WRITE_ENABLE_IN = '0' and READ_ENABLE_IN = '1' then
        if current_EMPTY = '0' then
          next_ADDRESS_SRL <= current_ADDRESS_SRL - 1;
          real_ADDRESS_SRL <= current_ADDRESS_SRL - 2;
        end if;
  -- write into FIFO
      elsif WRITE_ENABLE_IN = '1' and READ_ENABLE_IN = '0' then
        if current_FULL = '0' then
          next_ADDRESS_SRL <= current_ADDRESS_SRL + 1;
          real_ADDRESS_SRL <= current_ADDRESS_SRL - 1;
        end if;
  -- read and write can be done in all cases
      elsif WRITE_ENABLE_IN = '1' and READ_ENABLE_IN = '1' then
        next_ADDRESS_SRL <= current_ADDRESS_SRL;
        real_ADDRESS_SRL <= current_ADDRESS_SRL - 2;
      end if;
    end process;
  
  
  -- registered read from FIFO    
    reg_output: process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_DOUT <= (others => '0');
        elsif CLK_EN = '1' then
          if current_EMPTY = '1' or real_ADDRESS_SRL(DEPTH+1) = '1' then
            current_DOUT <= DATA_IN;
          else
            current_DOUT <= next_DOUT;
          end if;
        end if;
      end if;
    end process;
  
  -- Comparator Block
    next_FULL <= next_ADDRESS_SRL(DEPTH+1);
  -- Empty flag is generated when reading from the last location 
    next_EMPTY <= '1' when (next_ADDRESS_SRL(DEPTH+1 downto 0) = 0) else '0';
  
    reg_empty: process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_EMPTY <= '1';
          current_FULL <= '0';
        elsif CLK_EN = '1' then
          current_EMPTY <= next_EMPTY;
          current_FULL  <= next_FULL;
        else
          current_EMPTY <= current_EMPTY;
          current_FULL  <= current_FULL;
        end if;
      end if;
    end process;
  
    FULL_OUT <= current_FULL;
    EMPTY_OUT <= current_EMPTY;
    DATA_OUT <= current_DOUT;
  
    
    -- generate the real depth which is at least 3
    -- 0 -> 2
    -- 1 -> 4
    -- 2 -> 8
    -- 3 -> 16
    CHECK_DEPTH1:   if DEPTH>=3 generate
      DEPTH_OUT <= std_logic_vector(to_unsigned(DEPTH,8));
    end generate;
    CHECK_DEPTH2:   if DEPTH<3 generate
      DEPTH_OUT <= x"03";    
    end generate;
  end generate;



  gen_BRAM : if (DEPTH = 8 and WIDTH = 18) and FORCE_LUT = 0 generate
   bram_fifo:trb_net16_bram_fifo
    port map (
      clock_in         => CLK,
      read_enable_in   => READ_ENABLE_IN,
      write_enable_in  => WRITE_ENABLE_IN,
      write_data_in    => DATA_IN,
      fifo_gsr_in      => RESET,
      read_data_out    => DATA_OUT,
      full_out         => FULL_OUT,
      empty_out        => EMPTY_OUT,
      fifocount_out    => fifocount
      );

   DEPTH_OUT <= (others => '1');
  end generate;


end arch_trb_net_fifo;


