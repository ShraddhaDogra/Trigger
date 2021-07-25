------------------------------------------------------------
--!@brief Small implementation of a FIFO using shift register
--!this implementation does not support seperate input and output clock
--!and should be replaced with a FIFO from the manufacturer IP for production
--!systems
--!@author Tobias Weber
--!@date March 2017
------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity tiny_fifo is
  generic(
    fifo_depth : integer := 4; --! number words = fifo_depth**2
    fifo_width : integer := 32); --! fifo data width
  port(
    clk_in : in std_logic;--! clock input
    --fifo input channel
    fifo_data_in   : in  std_logic_vector(fifo_width - 1 downto 0); --! fifo data input
    fifo_valid_in  : in  std_logic; --! fifo input data is valid
    fifo_ready_out : out std_logic; --! fifo is ready to accept data

    --fifo output channel
    fifo_data_out  : out std_logic_vector(fifo_width - 1 downto 0); --! fifo data output
    fifo_valid_out : out std_logic; --! fifo output data is valid
    fifo_ready_in  : in  std_logic); --! fifo reader is ready for new word (pushes new word to fifo output0
end entity;

architecture behavior of tiny_fifo is

  type memory_type is array((2**fifo_depth - 1) downto 0) of std_logic_vector(fifo_width - 1 downto 0);
  signal fifo_memory     : memory_type                      := (others => (others => '0'));
  signal fifo_index      : signed (fifo_depth downto 0) := to_signed(-1, fifo_depth + 1);
  signal fifo_full       : std_logic;
  signal fifo_empty      : std_logic;
  signal fifo_in_enable  : boolean;
  signal fifo_out_enable : boolean;
 
begin

  fifo_full  <= '1' when (fifo_index = 2**fifo_depth - 1) else '0';
  fifo_empty <= '1' when (fifo_index = -1) else '0';

  fifo_ready_out <= '1' when (fifo_full = '0')  else '0';
  fifo_valid_out <= '1' when (fifo_empty = '0') else '0';

  fifo_in_enable  <= (fifo_valid_in = '1') and (fifo_full = '0');
  fifo_out_enable <= (fifo_ready_in = '1') and (fifo_empty = '0');

  fifo_data_out <= fifo_memory(to_integer(unsigned(fifo_index(fifo_depth - 1 downto 0))));

  fifo_proc : process(clk_in)
  begin
    if rising_edge(clk_in) then
      if fifo_in_enable then
        fifo_memory((2**fifo_depth - 1) downto 1) <= fifo_memory((2**fifo_depth - 2) downto 0);
        fifo_memory(0)                            <= fifo_data_in;
        if not fifo_out_enable then
          fifo_index <= fifo_index + 1;
        end if;
      elsif fifo_out_enable then
        fifo_index <= fifo_index - 1;
      end if;
    end if;
  end process fifo_proc;

end architecture;
