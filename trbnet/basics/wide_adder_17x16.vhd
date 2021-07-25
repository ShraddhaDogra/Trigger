--Adds up 17 16bit words in 4 clock cycles



LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;


entity wide_adder_17x16 is
   generic(
     SIZE : integer := 16;
     WORDS: integer := 17 --fixed
     );
   port(
    CLK    : in std_logic;
    CLK_EN : in std_logic;
    RESET  : in std_logic;
    INPUT_IN     : in  std_logic_vector(SIZE*WORDS-1 downto 0);
    START_IN     : in  std_logic;
    VAL_ENABLE_IN: in  std_logic_vector(WORDS-1 downto 0);
    RESULT_OUT   : out std_logic_vector(SIZE-1 downto 0);
    OVERFLOW_OUT : out std_logic;
    READY_OUT    : out std_logic
    );
end entity;

architecture wide_adder_17x16_arch of wide_adder_17x16 is

signal overflow : std_logic;
signal ready    : std_logic;
signal result   : std_logic_vector(SIZE-1 downto 0);
signal state    : integer range 0 to 1;


begin

  process(CLK)
    variable tmp : integer range 0 to (2**SIZE+1)-1;
    variable var_storage : std_logic_vector(8*(SIZE+1)-1 downto 0);
    variable var1_storage : std_logic_vector(4*(SIZE+1)-1 downto 0);
    variable var2_storage : std_logic_vector(2*(SIZE+1)-1 downto 0);
    variable var_result : std_logic_vector(1*(SIZE+1)-1 downto 0);
    constant STOR_SIZE : integer := SIZE+1;
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          result <= (others => '0');
          state <= 0;
          ready <= '0';
          overflow <= '0';
        elsif CLK_EN = '1' then
          case state is
            when 0 =>
              ready <= '0';
              if START_IN = '1' then
                state <= 1;
                gen_1st : for i in 0 to 7 loop
                  tmp := 0;
                  if VAL_ENABLE_IN(i*2) = '1' then
                    tmp := to_integer(unsigned(INPUT_IN((i*2+1)*SIZE-1 downto i*2*SIZE)));
                  end if;
                  if VAL_ENABLE_IN(i*2+1) = '1' then
                    tmp := tmp + to_integer(unsigned(INPUT_IN((i*2+2)*SIZE-1 downto (i*2+1)*SIZE)));
                  end if;
                  var_storage((i+1)*STOR_SIZE-1 downto i*STOR_SIZE) := std_logic_vector(to_unsigned(tmp,STOR_SIZE));
                end loop;
                gen_2nd : for i in 0 to 3 loop
                  var1_storage((i+1)*STOR_SIZE-1 downto (i)*STOR_SIZE) := std_logic_vector(to_unsigned(
                        to_integer(unsigned(var_storage((i*2+1)*STOR_SIZE-1 downto i*2*STOR_SIZE))) +
                        to_integer(unsigned(var_storage((i*2+2)*STOR_SIZE-1 downto (i*2+1)*STOR_SIZE))),STOR_SIZE));
                end loop;
              overflow <= var_storage(1*STOR_SIZE-1) or var_storage(2*STOR_SIZE-1) or var_storage(3*STOR_SIZE-1)
                        or var_storage(4*STOR_SIZE-1) or var_storage(5*STOR_SIZE-1) or var_storage(6*STOR_SIZE-1)
                         or var_storage(7*STOR_SIZE-1) or var_storage(8*STOR_SIZE-1) or var1_storage(1*STOR_SIZE-1)
                          or var1_storage(2*STOR_SIZE-1) or var1_storage(3*STOR_SIZE-1) or var1_storage(4*STOR_SIZE-1);
              end if;
            when 1 =>
              state <= 0;
              gen_3rd : for i in 0 to 1 loop
                var2_storage((i+1)*STOR_SIZE-1 downto (i)*STOR_SIZE) := std_logic_vector(to_unsigned(
                      to_integer(unsigned(var1_storage((i*2+1)*STOR_SIZE-1 downto i*2*STOR_SIZE))) +
                      to_integer(unsigned(var1_storage((i*2+2)*STOR_SIZE-1 downto (i*2+1)*STOR_SIZE))),STOR_SIZE));
              end loop;
              if VAL_ENABLE_IN(16) = '0' then
                var_result := std_logic_vector(to_unsigned(
                      to_integer(unsigned(var2_storage((1)*STOR_SIZE-1 downto 0*STOR_SIZE))) +
                      to_integer(unsigned(var2_storage((2)*STOR_SIZE-1 downto 1*STOR_SIZE))),STOR_SIZE));
              else
                var_result :=  std_logic_vector(to_unsigned(
                      to_integer(unsigned(var2_storage((1)*STOR_SIZE-1 downto 0*STOR_SIZE))) +
                      to_integer(unsigned(var2_storage((2)*STOR_SIZE-1 downto 1*STOR_SIZE))) +
                      to_integer(unsigned(INPUT_IN(INPUT_IN'left downto INPUT_IN'left - SIZE+1))),STOR_SIZE));
              end if;
              result <= var_result(SIZE-1 downto 0);
              overflow <= overflow or  var2_storage(1*STOR_SIZE-1) or var2_storage(2*STOR_SIZE-1) or var_result(1*STOR_SIZE-1);
              ready <= '1';
            when others =>
              state <= 0;
          end case;
        end if;
      end if;
    end process;



  PROC_OUTPUTS : process(CLK)
    begin
      if rising_edge(CLK) then
        READY_OUT    <= ready;
        RESULT_OUT   <= result;
        OVERFLOW_OUT <= overflow;
      end if;
    end process;

end architecture;