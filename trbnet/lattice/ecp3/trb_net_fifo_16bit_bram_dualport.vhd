library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.trb_net_std.all;

entity trb_net_fifo_16bit_bram_dualport is
   generic(
     USE_STATUS_FLAGS : integer  := c_YES
     );
   port (
     read_clock_in:   IN  std_logic;
     write_clock_in:  IN  std_logic;
     read_enable_in:  IN  std_logic;
     write_enable_in: IN  std_logic;
     fifo_gsr_in:     IN  std_logic;
     write_data_in:   IN  std_logic_vector(17 downto 0);
     read_data_out:   OUT std_logic_vector(17 downto 0);
     full_out:        OUT std_logic;
     empty_out:       OUT std_logic;
     fifostatus_out:  OUT std_logic_vector(3 downto 0);
     valid_read_out:  OUT std_logic;
     almost_empty_out:OUT std_logic;
     almost_full_out :OUT std_logic
    );
end entity trb_net_fifo_16bit_bram_dualport;

architecture trb_net_fifo_16bit_bram_dualport_arch of trb_net_fifo_16bit_bram_dualport is

  component lattice_ecp3_fifo_16bit_dualport
      port (Data: in  std_logic_vector(17 downto 0);
          WrClock: in  std_logic; RdClock: in  std_logic;
          WrEn: in  std_logic; RdEn: in  std_logic; Reset: in  std_logic;
          RPReset: in  std_logic; Q: out  std_logic_vector(17 downto 0);
          Empty: out  std_logic; Full: out  std_logic; AlmostFull: out  std_logic);
  end component;

  signal buf_empty_out, buf_full_out : std_logic;

BEGIN
  FIFO_DP_BRAM : lattice_ecp3_fifo_16bit_dualport
    port map (
      Data => write_data_in,
      WrClock => write_clock_in,
      RdClock => read_clock_in,
      WrEn => write_enable_in,
      RdEn => read_enable_in,
      Reset => fifo_gsr_in,
      RPReset => '0',
      Q => read_data_out,
      Empty => buf_empty_out,
      Full => buf_full_out,
      AlmostFull => almost_full_out 
      );
empty_out <= buf_empty_out;
full_out  <= buf_full_out;
almost_empty_out <= buf_empty_out;
fifostatus_out <= (others => '0');
valid_read_out <= '0';
end architecture trb_net_fifo_16bit_bram_dualport_arch;

