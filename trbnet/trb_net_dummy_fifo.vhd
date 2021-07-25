
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_signed.ALL;
USE ieee.std_logic_arith.ALL;
library work;
use work.trb_net_std.all;


entity trb_net_dummy_fifo is
  generic (
    WIDTH : integer := 18
    );
  port (
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    DATA_IN         : in  std_logic_vector(WIDTH - 1 downto 0);  -- Input data
    WRITE_ENABLE_IN : in  std_logic;
    DATA_OUT        : out std_logic_vector(WIDTH - 1 downto 0);  -- Output data
    READ_ENABLE_IN  : in  std_logic;
    FULL_OUT        : out std_logic;  	-- Full Flag
    EMPTY_OUT       : out std_logic
    );

end trb_net_dummy_fifo;

architecture arch_trb_net_dummy_fifo of trb_net_dummy_fifo is

  signal current_DOUT : std_logic_vector(WIDTH -1 downto 0);
  signal current_FULL, next_FULL : std_logic;
  signal current_EMPTY, next_EMPTY : std_logic;

  begin

    FULL_OUT <= current_FULL;
    EMPTY_OUT <= current_EMPTY;
    DATA_OUT <= current_DOUT;

    process(READ_ENABLE_IN, WRITE_ENABLE_IN, current_EMPTY, current_FULL)
      begin
        if WRITE_ENABLE_IN = '1' and READ_ENABLE_IN = '1' then
          next_FULL <= current_FULL;
          next_EMPTY <= current_EMPTY;
        elsif WRITE_ENABLE_IN = '1' then
          next_FULL <= '1';
          next_EMPTY <= '0';
        elsif READ_ENABLE_IN = '1' then
          next_FULL <= '0';
          next_EMPTY <= '1';
        else
          next_FULL <= current_FULL;
          next_EMPTY <= current_EMPTY;
        end if;
      end process;

    reg_empty: process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_EMPTY <= '1';
          current_FULL <= '0';
        elsif CLK_EN = '1' then
          current_EMPTY <= next_EMPTY;
          current_FULL  <= next_FULL;
        end if;
      end if;
    end process;

    process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_DOUT <= (others => '0');
        elsif WRITE_ENABLE_IN  = '1' and CLK_EN = '1' then
          current_DOUT <= DATA_IN;
        end if;
      end if;
    end process;

end arch_trb_net_dummy_fifo;

