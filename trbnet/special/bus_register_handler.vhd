library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.trb_net_std.all;

entity bus_register_handler is
  generic (
    BUS_LENGTH : integer range 0 to 64 := 2
    );
  port (
    RESET            : in  std_logic;
    CLK              : in  std_logic;
--
    DATA_IN          : in  std_logic_vector_array_32(0 to BUS_LENGTH-1);
    READ_EN_IN       : in  std_logic;
    WRITE_EN_IN      : in  std_logic;
    ADDR_IN          : in  std_logic_vector(6 downto 0);
    DATA_OUT         : out std_logic_vector(31 downto 0);
    DATAREADY_OUT    : out std_logic;
    UNKNOWN_ADDR_OUT : out std_logic
    );
end bus_register_handler;

architecture Behavioral of bus_register_handler is

  --Output signals
  signal data_out_reg     : std_logic_vector(31 downto 0);
  signal data_ready_reg   : std_logic;
  signal unknown_addr_reg : std_logic;
  signal read_en_i        : std_logic;
  signal write_en_i       : std_logic;
  signal addr_i           : std_logic_vector(6 downto 0);
  
begin

  read_en_i  <= READ_EN_IN  when rising_edge(CLK);
  write_en_i <= WRITE_EN_IN when rising_edge(CLK);
  addr_i     <= ADDR_IN     when rising_edge(CLK);
  
  READ_WRITE_RESPONSE : process (CLK, RESET)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        data_out_reg     <= (others => '0');
        data_ready_reg   <= '0';
        unknown_addr_reg <= '0';
      elsif read_en_i = '1' then
        if to_integer(unsigned(addr_i)) >= BUS_LENGTH then  -- if bigger than 64
          data_out_reg     <= (others => '0');
          data_ready_reg   <= '0';
          unknown_addr_reg <= '1';
        else
          data_out_reg     <= DATA_IN(to_integer(unsigned(addr_i)));
          data_ready_reg   <= '1';
          unknown_addr_reg <= '0';
        end if;
      elsif write_en_i = '1' then
        data_out_reg     <= (others => '0');
        data_ready_reg   <= '0';
        unknown_addr_reg <= '1';
      else
        data_out_reg     <= (others => '0');
        data_ready_reg   <= '0';
        unknown_addr_reg <= '0';
      end if;
    end if;
  end process READ_WRITE_RESPONSE;


  DATA_OUT         <= data_out_reg;
  DATAREADY_OUT    <= data_ready_reg;
  UNKNOWN_ADDR_OUT <= unknown_addr_reg;

end Behavioral;

