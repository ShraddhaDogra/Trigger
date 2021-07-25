LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb_net16_hub_func.all;

use work.trb_net_gbe_components.all;

--********
-- Response Constructor which forwards received frame back ceating a loopback 
--

entity trb_net16_gbe_response_constructor_Forward is
port (
	CLK			: in	std_logic;  -- system clock
	RESET			: in	std_logic;
	
-- INTERFACE	
	MY_MAC_IN                     : in  std_logic_vector(47 downto 0);
	MY_IP_IN                      : in  std_logic_vector(31 downto 0);
	PS_DATA_IN		: in	std_logic_vector(8 downto 0);
	PS_WR_EN_IN		: in	std_logic;
	PS_ACTIVATE_IN		: in	std_logic;
	PS_RESPONSE_READY_OUT	: out	std_logic;
	PS_BUSY_OUT		: out	std_logic;
	PS_SELECTED_IN		: in	std_logic;
	PS_SRC_MAC_ADDRESS_IN	: in	std_logic_vector(47 downto 0);
	PS_DEST_MAC_ADDRESS_IN  : in	std_logic_vector(47 downto 0);
	PS_SRC_IP_ADDRESS_IN	: in	std_logic_vector(31 downto 0);
	PS_DEST_IP_ADDRESS_IN	: in	std_logic_vector(31 downto 0);
	PS_SRC_UDP_PORT_IN	: in	std_logic_vector(15 downto 0);
	PS_DEST_UDP_PORT_IN	: in	std_logic_vector(15 downto 0);
	
	TC_RD_EN_IN		: in	std_logic;
	TC_DATA_OUT		: out	std_logic_vector(8 downto 0);
	TC_FRAME_SIZE_OUT	: out	std_logic_vector(15 downto 0);
	TC_FRAME_TYPE_OUT	: out	std_logic_vector(15 downto 0);
	TC_IP_PROTOCOL_OUT	: out	std_logic_vector(7 downto 0);
	TC_IDENT_OUT		: out	std_logic_vector(15 downto 0);
	TC_DEST_MAC_OUT		: out	std_logic_vector(47 downto 0);
	TC_DEST_IP_OUT		: out	std_logic_vector(31 downto 0);
	TC_DEST_UDP_OUT		: out	std_logic_vector(15 downto 0);
	TC_SRC_MAC_OUT		: out	std_logic_vector(47 downto 0);
	TC_SRC_IP_OUT		: out	std_logic_vector(31 downto 0);
	TC_SRC_UDP_OUT		: out	std_logic_vector(15 downto 0);
		
	RECEIVED_FRAMES_OUT	: out	std_logic_vector(15 downto 0);
	SENT_FRAMES_OUT		: out	std_logic_vector(15 downto 0);
-- END OF INTERFACE

	FWD_DST_MAC_IN		: in	std_logic_vector(47 downto 0);
	FWD_DST_IP_IN		: in	std_logic_vector(31 downto 0);
	FWD_DST_UDP_IN		: in	std_logic_vector(15 downto 0);
	FWD_DATA_IN		: in	std_logic_vector(7 downto 0);
	FWD_DATA_VALID_IN	: in	std_logic;
	FWD_SOP_IN		: in	std_logic;
	FWD_EOP_IN		: in	std_logic;
	FWD_READY_OUT		: out	std_logic;
	FWD_FULL_OUT		: out	std_logic;

-- debug
	DEBUG_OUT		: out	std_logic_vector(31 downto 0)
);
end trb_net16_gbe_response_constructor_Forward;


architecture trb_net16_gbe_response_constructor_Forward of trb_net16_gbe_response_constructor_Forward is

--attribute HGROUP : string;
--attribute HGROUP of trb_net16_gbe_response_constructor_Forward : architecture is "GBE_MAIN_group";

attribute syn_encoding	: string;

type dissect_states is (IDLE, SAVE, WAIT_FOR_LOAD, LOAD, CLEANUP);
signal dissect_current_state, dissect_next_state : dissect_states;
attribute syn_encoding of dissect_current_state: signal is "safe,gray";

signal ff_wr_en                 : std_logic;
signal ff_rd_en                 : std_logic;
signal resp_bytes_ctr           : std_logic_vector(15 downto 0);
signal ff_empty                 : std_logic;
signal ff_full                  : std_logic;
signal ff_q                     : std_logic_vector(8 downto 0);
signal ff_rd_lock               : std_logic;

signal state                    : std_logic_vector(3 downto 0);
signal rec_frames               : std_logic_vector(15 downto 0);
signal sent_frames              : std_logic_vector(15 downto 0);

signal local_eop : std_logic;

begin

DISSECT_MACHINE_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') then
			dissect_current_state <= IDLE;
		else
			dissect_current_state <= dissect_next_state;
		end if;
	end if;
end process DISSECT_MACHINE_PROC;

DISSECT_MACHINE : process(dissect_current_state, FWD_SOP_IN, FWD_EOP_IN, ff_q, ff_rd_lock, PS_SELECTED_IN)
begin
	case dissect_current_state is
	
		when IDLE =>
			state <= x"1";
			if (FWD_SOP_IN = '1') then
				dissect_next_state <= SAVE;
			else
				dissect_next_state <= IDLE;
			end if;
		
		when SAVE =>
			state <= x"2";
			if (FWD_EOP_IN = '1') then
				dissect_next_state <= WAIT_FOR_LOAD;
			else
				dissect_next_state <= SAVE;
			end if;
			
		when WAIT_FOR_LOAD =>
			state <= x"3";
			if (PS_SELECTED_IN = '0') then
				dissect_next_state <= LOAD;
			else
				dissect_next_state <= WAIT_FOR_LOAD;
			end if;
		
		when LOAD =>
			state <= x"4";
			if (ff_q(8) = '1') and (ff_rd_lock = '0') then
				dissect_next_state <= CLEANUP;
			else
				dissect_next_state <= LOAD;
			end if;
		
		when CLEANUP =>
			state <= x"5";
			dissect_next_state <= IDLE;
	
	end case;
end process DISSECT_MACHINE;

--PS_BUSY_OUT <= '1' when ff_wr_en = '1' else '0';
PS_BUSY_OUT <= '0' when dissect_current_state = IDLE else '1';

--ff_wr_en <= '1' when (PS_WR_EN_IN = '1' and PS_ACTIVATE_IN = '1') else '0';
ff_wr_en <= '1' when (FWD_DATA_VALID_IN = '1') else '0';

local_eop <= '1' when (dissect_current_state = SAVE and FWD_EOP_IN = '1' and FWD_DATA_VALID_IN = '1') else '0';

FF_RD_LOCK_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') then
			ff_rd_lock <= '1';
		elsif (dissect_current_state = LOAD and ff_rd_en = '1') then
			ff_rd_lock <= '0';
		else 
			ff_rd_lock <= '1';
		end if;
	end if;
end process FF_RD_LOCK_PROC;

FRAME_FIFO: fifo_4096x9
port map( 
	Data(7 downto 0)                => FWD_DATA_IN,
	Data(8) => local_eop,
	WrClock             => CLK,
	RdClock             => CLK,
	WrEn                => ff_wr_en,
	RdEn                => ff_rd_en,
	Reset               => RESET,
	RPReset             => RESET,
	Q                   => ff_q,
	Empty               => ff_empty,
	Full                => ff_full
);

ff_rd_en <= '1' when (TC_RD_EN_IN = '1' and PS_SELECTED_IN = '1') else '0';

TC_DATA_OUT <= ff_q;

PS_RESPONSE_READY_OUT <= '1' when (dissect_current_state = LOAD) else '0';

TC_FRAME_SIZE_OUT <= resp_bytes_ctr + x"1";

TC_FRAME_TYPE_OUT <= x"0008";
TC_DEST_MAC_OUT   <= FWD_DST_MAC_IN;
TC_DEST_IP_OUT    <= FWD_DST_IP_IN;
TC_DEST_UDP_OUT   <= FWD_DST_UDP_IN;
TC_SRC_MAC_OUT    <= MY_MAC_IN;
TC_SRC_IP_OUT     <= MY_IP_IN;
TC_SRC_UDP_OUT    <= FWD_DST_UDP_IN;
TC_IP_PROTOCOL_OUT <= x"11";
TC_IDENT_OUT       <= x"6" & sent_frames(11 downto 0);

RESP_BYTES_CTR_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') or (dissect_current_state = IDLE) then
			resp_bytes_ctr <= (others => '0');
		elsif (dissect_current_state = SAVE and FWD_DATA_VALID_IN = '1') then
			resp_bytes_ctr <= resp_bytes_ctr + x"1";
		end if;

		FWD_FULL_OUT <= ff_full;

		if (dissect_current_state = IDLE) then
			FWD_READY_OUT <= '1';
		else
			FWD_READY_OUT <= '0';
		end if;

	end if;
end process RESP_BYTES_CTR_PROC;

REC_FRAMES_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') then
			rec_frames <= (others => '0');
		elsif (dissect_current_state = IDLE and PS_WR_EN_IN = '1' and PS_ACTIVATE_IN = '1') then
			rec_frames <= rec_frames + x"1";
		end if;
	end if;
end process REC_FRAMES_PROC;

SENT_FRAMES_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') then
			sent_frames <= (others => '0');
		elsif (dissect_current_state = WAIT_FOR_LOAD and PS_SELECTED_IN = '0') then
			sent_frames <= sent_frames + x"1";
		end if;
	end if;
end process SENT_FRAMES_PROC;

RECEIVED_FRAMES_OUT <= rec_frames;
SENT_FRAMES_OUT     <= sent_frames;

-- **** debug
DEBUG_OUT(3 downto 0)   <= state;
DEBUG_OUT(4)            <= ff_empty;
DEBUG_OUT(7 downto 5)   <= "000";
DEBUG_OUT(8)            <= ff_full;
DEBUG_OUT(11 downto 9)  <= "000";
DEBUG_OUT(31 downto 12) <= (others => '0');
-- ****

end trb_net16_gbe_response_constructor_Forward;


