--Adds up a given number of words, distributed over several clock cycles,



LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;


entity wide_adder is
  generic(
--    FIXED_SETUP : integer := c_YES;  --18 inputs, 16 WIDTH, 3 clock cycles
    WIDTH : integer := 16;
    WORDS : integer := 16;
    PARALLEL_ADDERS : integer := 1 ;
    PSEUDO_WORDS : integer := 16 --the smallest multiple of PARALLEL_ADDERS, greater or equal than WORDS
    );
   port(
    CLK    : in std_logic;
    CLK_EN : in std_logic;
    RESET  : in std_logic;
    INPUT_IN     : in  std_logic_vector(WIDTH*WORDS-1 downto 0);
    START_IN     : in  std_logic;
    VAL_ENABLE_IN: in  std_logic_vector(WORDS-1 downto 0);
    RESULT_OUT   : out std_logic_vector(WIDTH-1 downto 0);
    OVERFLOW_OUT : out std_logic;
    READY_OUT    : out std_logic
    );
end entity;

architecture wide_adder_arch of wide_adder is
  signal state : integer range 0 to WORDS/(PARALLEL_ADDERS)+2;
  signal state_word : integer range 0 to PSEUDO_WORDS;
  signal result : std_logic_vector(WIDTH-1 downto 0);
  signal ready  : std_logic;
  signal overflow : std_logic;
  signal last_START_IN : std_logic;

  signal tmp_state  : std_logic_vector(3 downto 0);
  signal tmp_result : std_logic_vector(WIDTH-1 downto 0);
  signal tmp_section: std_logic_vector(WIDTH*(PARALLEL_ADDERS)-1 downto 0);

  signal pseudo_VAL_ENABLE_IN : std_logic_vector(PSEUDO_WORDS-1 downto 0);
  signal pseudo_INPUT_IN : std_logic_vector(16*PSEUDO_WORDS-1 downto 0);

  type tmp1_t is array(0 to 8) of integer range 0 to 2**16-1;
--  type tmp11_t is array(0 to 11) of integer range 0 to 2**16-1;

begin

--pad inputs to adder WIDTH
  pseudo_VAL_ENABLE_IN(WORDS-1 downto 0) <= VAL_ENABLE_IN(WORDS-1 downto 0);

  pseudo_INPUT_IN(WIDTH*WORDS-1 downto 0) <= INPUT_IN(WIDTH*WORDS-1 downto 0);

  gen_padding : if (WORDS/PARALLEL_ADDERS)*PARALLEL_ADDERS /= WORDS generate
    pseudo_VAL_ENABLE_IN(pseudo_VAL_ENABLE_IN'left downto WORDS) <= (others => '0');
    pseudo_INPUT_IN(pseudo_INPUT_IN'left downto WIDTH*WORDS) <= (others => '0');
  end generate;


  proc_result : process(CLK)
    variable erg : integer range 0 to 2**(WIDTH+1)*PARALLEL_ADDERS-1;
    constant num : integer := PARALLEL_ADDERS;
    variable section : std_logic_vector(WIDTH*(PARALLEL_ADDERS)-1 downto 0);
    variable var_result : std_logic_vector(WIDTH+log2(PARALLEL_ADDERS)-1 downto 0);
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          state <= 0;
          overflow <= '0';
          ready <= '0';
          last_START_IN <= '0';
        elsif CLK_EN = '1' then
          last_START_IN <= START_IN;
          if START_IN = '1' then
            state    <= 0;
            result   <= (others => '0');
            ready    <= '0';
            overflow <= '0';
          end if;
          if (state*num) < WORDS then
            section := pseudo_INPUT_IN(state*num*WIDTH+WIDTH*(PARALLEL_ADDERS)-1 downto state*num*WIDTH);
            gen_mux0 : for j in 0 to PARALLEL_ADDERS-1 loop --word number
              if pseudo_VAL_ENABLE_IN(state*num+j) = '0' then
                section((j)*WIDTH+WIDTH-1 downto (j)*WIDTH) := (others => '0');
              end if;
            end loop;
            tmp_section <= section;
            erg := to_integer(unsigned(result));
            if PARALLEL_ADDERS = 3 then
              erg := ( to_integer(unsigned(result)) +
                      to_integer(unsigned(section((0)*WIDTH+WIDTH-1 downto (0)*WIDTH)))) +
                     (to_integer(unsigned(section((1)*WIDTH+WIDTH-1 downto (1)*WIDTH))) +
                       to_integer(unsigned(section((2)*WIDTH+WIDTH-1 downto (2)*WIDTH))));
            elsif PARALLEL_ADDERS = 4 then
              erg :=((to_integer(unsigned(section((0)*WIDTH+WIDTH-1 downto (0)*WIDTH))) +
                      to_integer(unsigned(section((1)*WIDTH+WIDTH-1 downto (1)*WIDTH)))) +
                     (to_integer(unsigned(section((2)*WIDTH+WIDTH-1 downto (2)*WIDTH))) +
                      to_integer(unsigned(section((3)*WIDTH+WIDTH-1 downto (3)*WIDTH))))) +
                      to_integer(unsigned(result));
            else
              gen_adders_simple : for i in 0 to PARALLEL_ADDERS-1 loop
                  erg := erg + to_integer(unsigned(section((i)*WIDTH+WIDTH-1 downto (i)*WIDTH)));
              end loop;
            end if;
            var_result := std_logic_vector(to_unsigned(erg,WIDTH+log2(PARALLEL_ADDERS)));
            result <= var_result(WIDTH-1 downto 0);
            if state /= 0 or last_START_IN = '1' then
              state  <= state + 1;
            end if;
            if (state*num >= WORDS - num) then
              ready <= '1';
            end if;
            if or_all(var_result(var_result'left downto WIDTH)) = '1'  then
              overflow <= '1';
            end if;
          end if;
        end if;
      end if;
    end process;

--Debug Signals
  tmp_state  <= std_logic_vector(to_unsigned(state,4));
  tmp_result <= result;

--Outputs
  OVERFLOW_OUT <= overflow;
  RESULT_OUT   <= tmp_result(WIDTH-1 downto 0);
  READY_OUT    <= ready;

end architecture;