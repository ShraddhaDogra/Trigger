library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.All;

library work;
use work.trb_net_std.all;


entity timestamp_generator is
	port(
		CLK						: in std_logic;	-- system clk 100 MHz!
		RESET_IN					: in std_logic;	-- system reset
				
		TIMER_CLOCK_IN       : in std_logic; 
		TIMER_RESET_IN       : in std_logic;   
		
		--data output for read-out
		TRIGGER_IN           : in  std_logic;
      BUSRDO_RX            : in  READOUT_RX;
      BUSRDO_TX            : out READOUT_TX
		);
end entity;



architecture arch1 of timestamp_generator is

	
	type   state_readout is (RDO_IDLE, RDO_WRITE1, RDO_WRITE2, RDO_WRITE3, RDO_FINISH);
	signal rdostate : state_readout := RDO_IDLE;
	
	signal last_TRIGGER_IN     : std_logic;

	signal timestamp_counter : unsigned (47 downto 0);
	signal timer_clock_reg, timer_reset_reg : std_logic;
   signal last_timer_clock_reg, last_timer_reset_reg : std_logic;
   signal clock_tick : std_logic;
   signal finetime_counter : unsigned(23 downto 0);
	
begin


last_TRIGGER_IN <= TRIGGER_IN when rising_edge(CLK);

timer_clock_reg <= TIMER_CLOCK_IN when rising_edge(CLK);
timer_reset_reg <= TIMER_RESET_IN when rising_edge(CLK);
last_timer_clock_reg <= timer_clock_reg  when rising_edge(CLK);
last_timer_reset_reg <= timer_reset_reg  when rising_edge(CLK);

clock_tick <= not last_timer_clock_reg  and timer_clock_reg when rising_edge(CLK);

	PROC_FSM : process
	begin
		wait until rising_edge(CLK);
      if RESET_IN = '1' then
         timestamp_counter <= (others => '0');
         finetime_counter  <= (others => '0');
      else
         if last_timer_reset_reg = '0' and timer_reset_reg = '1' then
           timestamp_counter <= (others => '0');
           finetime_counter  <= (others => '0');
         elsif clock_tick = '1' then
            timestamp_counter <= timestamp_counter + 1;
            finetime_counter  <= (others => '0');
         else
            finetime_counter  <= finetime_counter + 1;
         end if;
      end if;		
	end process;
	


	PROC_RDO : process
	begin
		wait until rising_edge(CLK);
		BUSRDO_TX.data_write         <= '0';
		BUSRDO_TX.data_finished      <= '0';
		BUSRDO_TX.statusbits         <= (others => '0');
		BUSRDO_TX.data               <= x"00000000";
		case rdostate is
			when RDO_IDLE =>
				if TRIGGER_IN = '1' and last_TRIGGER_IN = '0'  then
               rdostate <= RDO_WRITE1;
				end if;
			when RDO_WRITE1 =>
            rdostate	<= RDO_WRITE2;
            BUSRDO_TX.data	<= x"75" & std_logic_vector(timestamp_counter(47 downto 24));
            BUSRDO_TX.data_write <= '1';
         when RDO_WRITE2 =>
            rdostate <= RDO_WRITE3;
            BUSRDO_TX.data <= x"75" & std_logic_vector(timestamp_counter(23 downto 0));
            BUSRDO_TX.data_write <= '1';
         when RDO_WRITE3 =>
            rdostate <= RDO_FINISH;
            BUSRDO_TX.data <= x"75" & std_logic_vector(finetime_counter);
            BUSRDO_TX.data_write <= '1';
			when RDO_FINISH =>
				BUSRDO_TX.data_finished <= '1';
				BUSRDO_TX.busy_release <= '1';
				rdostate		 <= RDO_IDLE;
		end case;
		if RESET_IN = '1' then
         rdostate <= RDO_IDLE;
		end if;
	end process;

end architecture;
