library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.math_real.all;

library work;

entity error_generator is
port(
	RXCLK_IN             : in  std_logic;
	RESET_IN             : in  std_logic;

	RX1_DATA_IN          : in  std_logic_vector(7 downto 0);
	RX1_DATA_OUT         : out std_logic_vector(7 downto 0);

	RX2_DATA_IN          : in  std_logic_vector(7 downto 0);
	RX2_DATA_OUT         : out std_logic_vector(7 downto 0);

	RX1_K_IN             : in  std_logic;
	RX1_K_OUT            : out std_logic;

	RX2_K_IN             : in  std_logic;
	RX2_K_OUT            : out std_logic;

	RX1_CV_IN            : in  std_logic;
	RX1_CV_OUT           : out std_logic;

	RX2_CV_IN            : in  std_logic;
	RX2_CV_OUT           : out std_logic
  );
end entity;

architecture arch of error_generator is

  signal buf_RX1_DATA_OUT : std_logic_vector(7 downto 0);
  signal buf_RX1_K_OUT    : std_logic;
  signal buf_RX1_CV_OUT   : std_logic;

  signal error_count_data : unsigned(31 downto 0) := (others => '0');
  signal error_count_cv   : unsigned(31 downto 0) := (others => '0');
  signal doing_cv         : std_logic;

begin

CV1_PROC : process
variable seed1    : positive;
variable seed2    : positive := 1;
variable rand     : real;
variable int_rand : integer;
begin

	wait until rising_edge(RXCLK_IN);

	UNIFORM(seed1, seed2, rand);
	int_rand := INTEGER(TRUNC(rand * 1000000.0));
  doing_cv <= '0';
	if( (int_rand MOD 1000) = 0 ) then
	  doing_cv <= '1';
    buf_RX1_CV_OUT <= RX1_CV_IN;
    wait until rising_edge(RXCLK_IN);
    doing_cv <= '0';
    error_count_cv <= error_count_cv + to_unsigned(1,1);
		buf_RX1_CV_OUT <= not RX1_CV_IN;


		assert false report "RX1_CV" severity note;
		wait for 40 ns;
		buf_RX1_CV_OUT <= RX1_CV_IN;
	else
		buf_RX1_CV_OUT <= RX1_CV_IN;
	end if;

-- 	wait for 400 ns;

end process;

-- CV2_PROC : process
-- variable seed1    : positive;
-- variable seed2    : positive := 2;
-- variable rand     : real;
-- variable int_rand : integer;
-- begin
--
-- 	wait until rising_edge(RXCLK_IN);
--
-- 	UNIFORM(seed1, seed2, rand);
-- 	int_rand := INTEGER(TRUNC(rand * 2**20));
--
-- 	if( (int_rand MOD 500) = 0 ) then
-- 		RX2_CV_OUT <= not RX2_CV_IN;
-- 		assert false report "RX2_CV" severity note;
-- 		wait for 40 ns;
-- 		RX2_CV_OUT <= RX2_CV_IN;
-- 	else
-- 		RX2_CV_OUT <= RX2_CV_IN;
-- 	end if;

-- 	wait for 400 ns;

-- end process;

RD1_DATA_proc : process
variable seed1    : positive;
variable seed2    : positive := 3;
variable rand     : real;
variable int_rand : integer;
begin

	wait until rising_edge(RXCLK_IN);

	UNIFORM(seed1, seed2, rand);
	int_rand := INTEGER(TRUNC(rand * 1000000.0));
	if( doing_cv = '1' or (int_rand MOD 1000) = 0 ) then
    error_count_data <= error_count_data + to_unsigned(1,1);
		UNIFORM(seed1, seed2, rand);
		int_rand := INTEGER(TRUNC(rand * 256.0));

    buf_RX1_DATA_OUT <= RX1_DATA_IN;
		buf_RX1_DATA_OUT(int_rand mod 8) <= not RX1_DATA_IN(int_rand mod 8);
    if doing_cv = '1' then
      buf_RX1_DATA_OUT <= x"EE";
    end if;

		assert doing_cv = '1' report "RX1_DATA" severity note;

		wait for 39 ns;
		buf_RX1_DATA_OUT <= RX1_DATA_IN;
	else
		buf_RX1_DATA_OUT <= RX1_DATA_IN;
	end if;


end process;
process
  begin
    wait until rising_edge(RXCLK_IN);
--     buf_RX1_DATA_OUT <= RX1_DATA_IN;
--     buf_RX1_K_OUT    <= RX1_K_IN;
  end process;

RX1_DATA_OUT <= transport buf_RX1_DATA_OUT after 200 ns;
RX1_K_OUT    <= transport buf_RX1_K_OUT after 200 ns;
RX1_CV_OUT   <= transport buf_RX1_CV_OUT after 200 ns;


-- RD2_DATA_proc : process
-- variable seed1    : positive;
-- variable seed2    : positive := 4;
-- variable rand     : real;
-- variable int_rand : integer;
-- begin
--
-- 	wait until rising_edge(RXCLK_IN);
--
-- 	UNIFORM(seed1, seed2, rand);
-- 	int_rand := INTEGER(TRUNC(rand * 256.0));
--
-- 	if( (int_rand MOD 40) = 0 ) then
--
-- 		UNIFORM(seed1, seed2, rand);
-- 		int_rand := INTEGER(TRUNC(rand * 256.0));
--
-- 		RX2_DATA_OUT(int_rand mod 8) <= not RX2_DATA_IN(int_rand mod 8);
--
-- 		assert false report "RX2_DATA" severity note;
--
-- 		wait for 40 ns;
-- 		RX2_DATA_OUT <= RX2_DATA_IN;
-- 	else
-- 		RX2_DATA_OUT <= RX2_DATA_IN;
-- 	end if;
--
-- 	wait for 400 ns;
--
-- end process;

RX2_DATA_OUT <= RX2_DATA_IN;
RX2_CV_OUT   <= RX2_CV_IN;
RX2_K_OUT    <= RX2_K_IN;

K1_PROC : process
variable seed1    : positive;
variable seed2    : positive := 5;
variable rand     : real;
variable int_rand : integer;
begin

	wait until rising_edge(RXCLK_IN);

	UNIFORM(seed1, seed2, rand);
	int_rand := INTEGER(TRUNC(rand * 1000000.0));

	if( doing_cv = '1' or (int_rand MOD 1000) = 0 ) then
		buf_RX1_K_OUT <= not RX1_K_IN or doing_cv;
		assert doing_cv = '1' report "RX1_K" severity note;
		wait for 39 ns;
		buf_RX1_K_OUT <= RX1_K_IN;
	else
		buf_RX1_K_OUT <= RX1_K_IN;
	end if;


end process;

-- K2_PROC : process
-- variable seed1    : positive;
-- variable seed2    : positive := 6;
-- variable rand     : real;
-- variable int_rand : integer;
-- begin
--
-- 	wait until rising_edge(RXCLK_IN);
--
-- 	UNIFORM(seed1, seed2, rand);
-- 	int_rand := INTEGER(TRUNC(rand * 2**20));
--
-- 	if( (int_rand MOD 10000) = 0 ) then
-- 		RX2_K_OUT <= not RX2_K_IN;
-- 		assert false report "RX2_K" severity note;
-- 		wait for 39 ns;
-- 		RX2_K_OUT <= RX2_K_IN;
-- 	else
-- 		RX2_K_OUT <= RX2_K_IN;
-- 	end if;
--
-- -- 	wait for 400 ns;
--
-- end process;

end architecture;



