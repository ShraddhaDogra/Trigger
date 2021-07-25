LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

entity ram_16x16_dp is
  generic(
    INIT0 : std_logic_vector(15 downto 0) := x"0000";
    INIT1 : std_logic_vector(15 downto 0) := x"0000";
    INIT2 : std_logic_vector(15 downto 0) := x"0000";
    INIT3 : std_logic_vector(15 downto 0) := x"0000";
    INIT4 : std_logic_vector(15 downto 0) := x"0000";
    INIT5 : std_logic_vector(15 downto 0) := x"0000";
    INIT6 : std_logic_vector(15 downto 0) := x"0000";
    INIT7 : std_logic_vector(15 downto 0) := x"0000";
    INIT8 : std_logic_vector(15 downto 0) := x"12A0";
    INIT9 : std_logic_vector(15 downto 0) := x"23b1";
    INITA : std_logic_vector(15 downto 0) := x"34c2";
    INITB : std_logic_vector(15 downto 0) := x"49d3";
    INITC : std_logic_vector(15 downto 0) := x"56e5";
    INITD : std_logic_vector(15 downto 0) := x"67d5";
    INITE : std_logic_vector(15 downto 0) := x"7818";
    INITF : std_logic_vector(15 downto 0) := x"8927"
    );
  port(
    CLK   : in  std_logic;
    wr1   : in  std_logic;
    a1    : in  std_logic_vector(3 downto 0);
    dout1 : out std_logic_vector(15 downto 0);
    din1  : in  std_logic_vector(15 downto 0);
    a2    : in  std_logic_vector(3 downto 0);
    dout2 : out std_logic_vector(15 downto 0)
    );
end entity;

architecture ram_16x16_dp_arch of ram_16x16_dp is
  type ram_t is array(0 to 15) of std_logic_vector(15 downto 0);
  SIGNAL ram : ram_t := (INIT0, INIT1, INIT2, INIT3, INIT4, INIT5, INIT6, INIT7,
                         INIT8, INIT9, INITA, INITB, INITC, INITD, INITE, INITF);
  attribute syn_ramstyle : string;
--   attribute syn_ramstyle of ram : signal is "block_ram";
begin
  process(CLK)
    begin
      if rising_edge(CLK) then
        dout1 <= ram(conv_integer(a1));
        dout2 <= ram(conv_integer(a2));
        if wr1 = '1' then
          ram((conv_integer(a1))) <= din1;
          dout1 <= din1;
        end if;
      end if;
  end process;

end architecture;