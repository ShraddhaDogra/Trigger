LIBRARY ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_signed.ALL;
USE IEEE.numeric_std.ALL;
use work.trb_net_std.all;

entity xilinx_fifo_lut IS
  generic (
    WIDTH : integer := 18;
    DEPTH : integer := 16
    );
  port (
    clk  : IN std_logic;
    sinit: IN std_logic;
    din  : IN std_logic_VECTOR(WIDTH-1 downto 0);
    wr_en: IN std_logic;
    rd_en: IN std_logic;
    dout : OUT std_logic_VECTOR(WIDTH-1 downto 0);
    full : OUT std_logic;
    empty: OUT std_logic
    );
end entity;

architecture xilinx_fifo_lut_arch OF xilinx_fifo_lut is

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

  FULL  <= current_FULL;
  EMPTY <= current_EMPTY;
  do_shift  <= do_shift_internal;
  dout <= current_DOUT;

    inst_shift_lut_x16 : for i in 0 to (WIDTH - 1) generate
      U1 :  shift_lut_x16
        generic map (
          ADDRESS_WIDTH  => DEPTH - 3
          )
        port map (
          D    => din(i),
          CE   => do_shift,
          CLK  => CLK,
          A    => current_ADDRESS_SRL(DEPTH downto 0),
          Q    => next_DOUT(i)
          );
    end generate;

  reg_counter: process(CLK)
    begin
      if rising_edge(CLK) then
        if sinit = '1' then
          current_ADDRESS_SRL <= (others => '0');
        else
          current_ADDRESS_SRL <= next_ADDRESS_SRL;
        end if;
      end if;
    end process;

--   reg_output: process(CLK)
--     begin
--       if rising_edge(CLK) then
--         if sinit = '1' then
--           current_DOUT <= (others => '0');
--         else
--           current_DOUT <= next_DOUT;
--         end if;
--       end if;
--     end process;
  current_DOUT <= next_DOUT;

  comb_counter: process(rd_en, wr_en, current_ADDRESS_SRL,
                          current_EMPTY, current_FULL)
    begin
      do_shift_internal <= wr_en and not current_FULL;
      next_ADDRESS_SRL <= current_ADDRESS_SRL;
      if wr_en = '0' and rd_en = '0' then     --nothing
        next_ADDRESS_SRL <= current_ADDRESS_SRL;
      elsif wr_en = '0' and rd_en = '1' then  --read
        if current_EMPTY = '0' then
          next_ADDRESS_SRL <= current_ADDRESS_SRL - 1;
        end if;
      elsif wr_en = '1' and rd_en = '0' then  --write
        if current_FULL = '0' then
          next_ADDRESS_SRL <= current_ADDRESS_SRL + 1;
        end if;
      elsif wr_en = '1' and rd_en = '1' then  --both
        next_ADDRESS_SRL <= current_ADDRESS_SRL;
      end if;
    end process;


  -- Comparator Block
    next_FULL <= next_ADDRESS_SRL(DEPTH+1);
  -- Empty flag is generated when reading from the last location 
    next_EMPTY <= '1' when (next_ADDRESS_SRL(DEPTH+1 downto 0) = 0) else '0';

    reg_empty: process(CLK)
    begin
      if rising_edge(CLK) then
        if sinit = '1' then
          current_EMPTY <= '1';
          current_FULL <= '0';
        else
          current_EMPTY <= next_EMPTY;
          current_FULL  <= next_FULL;
        end if;
      end if;
    end process;

end architecture;

