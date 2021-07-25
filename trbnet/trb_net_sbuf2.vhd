LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net_sbuf2 is
  generic (
    DATA_WIDTH : integer := 18
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    COMB_DATAREADY_IN  : in  STD_LOGIC;
    COMB_next_READ_OUT : out STD_LOGIC;
    COMB_READ_IN       : in  STD_LOGIC;
    COMB_DATA_IN       : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);

    SYN_DATAREADY_OUT  : out STD_LOGIC;
    SYN_DATA_OUT       : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
    SYN_READ_IN        : in  STD_LOGIC;
    STAT_BUFFER        : out STD_LOGIC
    );
end trb_net_sbuf2;

architecture trb_net_sbuf_arch of trb_net_sbuf2 is

  component fifo_sbuf is
    port (
      Data       : in  std_logic_vector(18 downto 0);
      Clock      : in  std_logic;
      WrEn       : in  std_logic;
      RdEn       : in  std_logic;
      Reset      : in  std_logic;
      Q          : out std_logic_vector(18 downto 0);
      Empty      : out std_logic;
      Full       : out std_logic;
      AlmostFull : out std_logic
      );
  end component;

  signal fifo_data_in  : std_logic_vector(18 downto 0);
  signal fifo_data_out : std_logic_vector(18 downto 0);
  signal reg_fifo_data_out : std_logic_vector(18 downto 0);
  signal fifo_wr_en    : std_logic;
  signal fifo_rd_en    : std_logic;
  signal fifo_empty    : std_logic;
  signal fifo_full     : std_logic;
  signal fifo_almost_full : std_logic;
  signal fifo_read_before    : std_logic;
  signal next_last_fifo_read : std_logic;
  signal last_fifo_read      : std_logic;


begin


--write to fifo if fifo is not full and data is available
  PROC_REG_INPUT : process(CLK)
    begin
      if rising_edge(CLK) then
        fifo_data_in  <= COMB_DATA_IN;
        fifo_wr_en    <= COMB_DATAREADY_IN and COMB_READ_IN and not fifo_full;
      end if;
    end process;


  COMB_next_READ_OUT  <= not fifo_almost_full;

--connect to outputs
  SYN_DATAREADY_OUT <= fifo_read_before;
  SYN_DATA_OUT      <= reg_fifo_data_out;
  STAT_BUFFER       <= fifo_full;


--fifo read signal
  fifo_rd_en <= SYN_READ_IN or (not next_last_fifo_read and not fifo_read_before);

--the fifo
  THE_BUFFER : fifo_sbuf
    port map(
      Data       => fifo_data_in,
      Clock      => CLK,
      WrEn       => fifo_wr_en,
      RdEn       => fifo_rd_en,
      Reset      => RESET,
      Q          => fifo_data_out,
      Empty      => fifo_empty,
      Full       => fifo_full,
      AlmostFull => fifo_almost_full
      );


-- is data on output valid?
  PROC_DETECT_VALID_READS : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          fifo_read_before <= '0';
        elsif CLK_EN = '1' then
          if next_last_fifo_read = '1' then
            fifo_read_before <= '1';
          elsif SYN_READ_IN = '1' then
            fifo_read_before <= '0';
          end if;
        end if;
      end if;
    end process;

-- keep track of fifo read operations
  PROC_LAST_FIFO_READ : process(CLK)
    begin
      if rising_edge(CLK) then
        next_last_fifo_read <= fifo_rd_en and not fifo_empty;
        last_fifo_read <= next_last_fifo_read and not RESET;
      end if;
    end process;


--register on fifo outputs
  PROC_SYNC_FIFO_OUTPUTS : process(CLK)
    begin
      if rising_edge(CLK) then
        if next_last_fifo_read = '1' then
          reg_fifo_data_out <= fifo_data_out;
        end if;
      end if;
    end process;


end architecture;