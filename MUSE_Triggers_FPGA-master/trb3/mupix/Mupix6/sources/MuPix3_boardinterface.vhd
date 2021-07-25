----------------------------------------------------------------------------
-- synchronize signals from mupix board
-- Invert logic levels of some signals from the mupix sensorboard
-- depending if inverters are present on the sensor board
-- Tobias Weber, Mainz Univerity
-----------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.mupix_components.all;
use work.StdTypes.all;

entity board_interface is
  port(
    clk_in               : in  std_logic;
    fast_clk_in          : in  std_logic;
    reset                : in  std_logic;
    -- signals from mupix
    mupixreadout         : in MupixReadoutData;
    sout_c_from_mupix    : in std_logic;
    sout_d_from_mupix    : in std_logic;
    hbus_from_mupix      : in std_logic;
    fpga_aux_from_board  : in std_logic_vector(5 downto 0);
    --synced (and inverted) signals
    mupixreadout_sync         : out MupixReadoutData;
    sout_c_from_mupix_sync    : out std_logic;
    sout_d_from_mupix_sync    : out std_logic;
    hbus_from_mupix_sync      : out std_logic;
    hbus_from_mupix_fast_sync : out std_logic;
    fpga_aux_from_board_sync  : out std_logic_vector(4 downto 0);
    szintilator_sync         : out std_logic;
    szintilator_fast_sync    : out std_logic;
    --Trb Slv-Bus
    SLV_READ_IN                : in  std_logic;
    SLV_WRITE_IN               : in  std_logic;
    SLV_DATA_OUT               : out std_logic_vector(31 downto 0);
    SLV_DATA_IN                : in  std_logic_vector(31 downto 0);
    SLV_ADDR_IN                : in  std_logic_vector(15 downto 0);
    SLV_ACK_OUT                : out std_logic;
    SLV_NO_MORE_DATA_OUT       : out std_logic;
    SLV_UNKNOWN_ADDR_OUT       : out std_logic);          
end entity board_interface;



architecture rtl of board_interface is

  signal invert_signals_int : std_logic := '0';
  signal szintilator_sync_buf : std_logic := '0';
  signal hitbus_buf : std_logic := '0';
  
begin

-- fast synchronize for hitbus and szintilator
   fast_sync : process(fast_clk_in) is
	begin                               -- process fast_sync
		if rising_edge(fast_clk_in) then
			if reset = '1' then
				hitbus_buf           <= '0';
				szintilator_sync_buf <= '0';
			else
				hitbus_buf            <= hbus_from_mupix;
				szintilator_sync_buf  <= fpga_aux_from_board(0);
				szintilator_fast_sync <= szintilator_sync_buf;
				if invert_signals_int = '1' then
					hbus_from_mupix_fast_sync <= hitbus_buf;
				else
					hbus_from_mupix_fast_sync <= not hitbus_buf;
				end if;
			end if;
		end if;
	end process fast_sync;

-- Synchronize input signals
	process(clk_in)
	begin
		if rising_edge(clk_in) then
			if reset = '1' then
				fpga_aux_from_board_sync <= (others => '0');
				szintilator_sync         <= '0';
				hbus_from_mupix_sync     <= '0';
				sout_c_from_mupix_sync   <= '0';
				sout_d_from_mupix_sync   <= '0';
				mupixreadout_sync.hit_time <= (others => '0');
				mupixreadout_sync.hit_row <= (others => '0');
				mupixreadout_sync.hit_col <= (others => '0');
				mupixreadout_sync.priout <= '0';
			else
				fpga_aux_from_board_sync <= fpga_aux_from_board(5 downto 1);
				szintilator_sync         <= fpga_aux_from_board(0);
				if invert_signals_int = '1' then
					mupixreadout_sync.hit_time <= not mupixreadout.hit_time;
					mupixreadout_sync.hit_row  <= not mupixreadout.hit_row;
					mupixreadout_sync.hit_col  <= not mupixreadout.hit_col;
					mupixreadout_sync.priout   <= mupixreadout.priout; --is inverted on the chip
					sout_c_from_mupix_sync     <= not sout_c_from_mupix;
					sout_d_from_mupix_sync     <= not sout_d_from_mupix;
					hbus_from_mupix_sync       <= hbus_from_mupix;
				else
					mupixreadout_sync.hit_time <= mupixreadout.hit_time;
					mupixreadout_sync.hit_row  <= mupixreadout.hit_row;
					mupixreadout_sync.hit_col  <= mupixreadout.hit_col;
					mupixreadout_sync.priout   <= not mupixreadout.priout; --is inverted on the chip
					sout_c_from_mupix_sync     <= sout_c_from_mupix;
					sout_d_from_mupix_sync     <= sout_d_from_mupix;
					hbus_from_mupix_sync       <= not hbus_from_mupix;
				end if;
			end if;
		end if;
	end process;

   slv_bus_handler : process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      slv_data_out         <= (others => '0');
      slv_ack_out          <= '0';
      slv_no_more_data_out <= '0';
      slv_unknown_addr_out <= '0';
      
      if slv_write_in = '1' then
       case SLV_ADDR_IN is
         when x"0200" =>
            invert_signals_int <= SLV_DATA_IN(0);
            slv_ack_out <= '1';
         when others =>
           slv_unknown_addr_out <= '1';
       end case;
      elsif slv_read_in = '1' then
        case slv_addr_in is
          when x"0200" =>
            slv_data_out(0) <= invert_signals_int;
            slv_ack_out  <= '1';
          when others =>
            slv_unknown_addr_out <= '1';
        end case;

      end if;
    end if;
  end process slv_bus_handler;
  
end architecture rtl;
