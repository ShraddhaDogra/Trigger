library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.trb_net_std.all;

entity LUT is
    port (
        CLK            : in  std_logic;
        DIN_in         : in  std_logic_vector(31 downto 0);
        DIN_in_b_r     : in  std_logic;
        DIN_in_data_w  : in  std_logic;
        DIN_in_data_f  : in  std_logic;
        Delta          : in  std_logic_vector( 9 downto 0):="0110110100";
        min_in         : in  std_logic_vector( 9 downto 0);
        max_in         : in  std_logic_vector( 9 downto 0);
        do_cal_in      : in  std_logic;
        min_out        : out std_logic_vector( 9 downto 0);
        max_out        : out std_logic_vector( 9 downto 0);
        DIN_out        : out std_logic_vector(31 downto 0);
        DIN_out_b_r    : out std_logic;
        DIN_out_data_w : out std_logic;
        DIN_out_data_f : out std_logic;
        slope          : out std_logic_vector(11 downto 0);
        do_cal_out     : out std_logic;
        factor         : out std_logic_vector( 9 downto 0);
        overshoot      : out std_logic := '0';
        undershoot     : out std_logic := '0'
    );
end entity;

architecture lut of LUT is
    subtype lutin is std_logic_vector (11 downto 0);
    subtype lutout is std_logic_vector (11 downto 0);
    type lut is array (natural range 436 to 563) of lutout;

    constant LUTslope:   lut := (
            "100100101101", "100100100111", "100100100010", "100100011101", 
            "100100010111", "100100010010", "100100001101", "100100001000", 
            "100100000010", "100011111101", "100011111000", "100011110011", 
            "100011101110", "100011101001", "100011100100", "100011011111", 
            "100011011001", "100011010100", "100011010000", "100011001011", 
            "100011000110", "100011000001", "100010111100", "100010110111", 
            "100010110010", "100010101101", "100010101000", "100010100100", 
            "100010011111", "100010011010", "100010010101", "100010010001", 
            "100010001100", "100010000111", "100010000011", "100001111110", 
            "100001111001", "100001110101", "100001110000", "100001101100", 
            "100001100111", "100001100011", "100001011110", "100001011010", 
            "100001010101", "100001010001", "100001001100", "100001001000", 
            "100001000100", "100000111111", "100000111011", "100000110111", 
            "100000110010", "100000101110", "100000101010", "100000100110", 
            "100000100001", "100000011101", "100000011001", "100000010101", 
            "100000010001", "100000001100", "100000001000", "100000000100", 
            "100000000000", "011111111100", "011111111000", "011111110100", 
            "011111110000", "011111101100", "011111101000", "011111100100", 
            "011111100000", "011111011100", "011111011000", "011111010100", 
            "011111010000", "011111001100", "011111001000", "011111000100", 
            "011111000000", "011110111101", "011110111001", "011110110101", 
            "011110110001", "011110101101", "011110101010", "011110100110", 
            "011110100010", "011110011110", "011110011011", "011110010111", 
            "011110010011", "011110010000", "011110001100", "011110001000", 
            "011110000101", "011110000001", "011101111110", "011101111010", 
            "011101110110", "011101110011", "011101101111", "011101101100", 
            "011101101000", "011101100101", "011101100001", "011101011110", 
            "011101011010", "011101010111", "011101010011", "011101010000", 
            "011101001101", "011101001001", "011101000110", "011101000010", 
            "011100111111", "011100111100", "011100111000", "011100110101", 
            "011100110010", "011100101110", "011100101011", "011100101000", 
            "011100100101", "011100100001", "011100011110", "011100011011"
        );
        
    signal DIN_in_i 	: std_logic_vector(31 downto 0) := (others => '0');
    signal DIN_out_i 	: std_logic_vector(31 downto 0) := (others => '0');
    signal do_cal_out_i : std_logic := '0';
    
begin

  proc_slope : process (CLK)
  begin
    if rising_edge(CLK) then
       if do_cal_in = '1' then
         slope      <= LUTslope( TO_INTEGER ( unsigned(Delta)));
       end if;
       min_out      <= min_in;
       max_out      <= max_in;
       do_cal_out_i <= do_cal_in;
    end if;
  end process;
  
  proc_factor : process (CLK)
  begin
    if rising_edge(CLK) then
    --keep values in definition area of linear part
       if (unsigned(DIN_in(21 downto 12)) < unsigned(min_in) ) then
          factor     <= (others => '0');
          undershoot <= '1'; -- value is out of calibration range
          overshoot  <= '0';
       elsif (unsigned(DIN_in(21 downto 12)) > unsigned(max_in) ) then
          factor     <= (others => '0');
          overshoot  <= '1'; -- value is out of calibration range
          undershoot <= '0';
       else
          factor     <= std_logic_vector(unsigned(DIN_in(21 downto 12)) - unsigned(min_in));
          undershoot <= '0';
          overshoot  <= '0';
       end if;

    DIN_out	    <= DIN_in;
    DIN_out_b_r	    <= DIN_in_b_r;
    DIN_out_data_w  <= DIN_in_data_w;
    DIN_out_data_f  <= DIN_in_data_f;
    end if;
  end process; 
  
  do_cal_out <= do_cal_out_i;

end architecture;