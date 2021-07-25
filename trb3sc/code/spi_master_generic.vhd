library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use trb_net_std.all;



entity spi_master_generic is
  generic(
    -- default settings are:
    -- wordsize 8 bits, sck idle=LO
    -- data is valid at rising edges
    WORDSIZE          : integer   := 8;
    CPOL              : std_logic := '0';
    CPHA              : std_logic := '0';
    SPI_CLOCK_DIVIDER : integer   := 5 -- 100 MHz/5 = 20 MHz
 
  );
  port(
    CLK        : in std_logic;
    RST        : in std_logic;
    
    DATA_OUT          : out  std_logic_vector(WORDSIZE-1 downto 0);
    DATA_IN           : in   std_logic_vector(WORDSIZE-1 downto 0);
    TRANSFER_COMPLETE : out std_logic;
    TRIGGER_TRANSFER  : in std_logic;
    
    MOSI       : out std_logic;
    MISO       : in  std_logic;
    SCK        : out std_logic
    
    );
end entity;



architecture spi_master_generic_arch of spi_master_generic is

signal sck_rise,sck_fall                     : std_logic;
signal sck_raw,sck_raw_buf,sck_gate          : std_logic := '0';
signal transition_strobe, sample_strobe, sample_strobe_buf  : std_logic;
signal trigger_transfer_latch                : std_logic := '0';


-- sck generation
signal bit_counter              : integer range 0 to WORDSIZE-1 := 0;
signal sck_clock_div_counter    : integer range 0 to (SPI_CLOCK_DIVIDER-1) :=0;


-- transfer state machine
type   transfer_state_t is (IDLE,TRANSFER);
signal transfer_state : transfer_state_t := IDLE;

-- internal data transmission
signal data_out_buffer   : std_logic_vector((WORDSIZE-1) downto 0);
signal data_in_buffer    : std_logic_vector((WORDSIZE-1) downto 0);
signal data_out_ready    : std_logic;



begin


----------------------------
-- SCK Generation
----------------------------

generate_sck : process begin

-- Generate a square wave with frequency CLK/SPI_CLOCK_DIVIDER
-- more precisely, generate strobes at the rising and falling
-- edges of such a square wave

  wait until rising_edge(CLK);
  
  sck_rise    <= '0';
  sck_fall    <= '0';
  sck_raw_buf <= sck_raw; -- delayed by one CLK cycle
  
  sck_clock_div_counter <= sck_clock_div_counter + 1;
  if sck_clock_div_counter >= (SPI_CLOCK_DIVIDER -1) then
    sck_clock_div_counter <= 0;
  end if;
  
  if sck_clock_div_counter = 0 then
    sck_rise <= '1';
    sck_raw  <= '1';
  end if;
  
  if sck_clock_div_counter = (SPI_CLOCK_DIVIDER/2) then
    sck_fall <= '1';
    sck_raw  <= '0';
  end if;
  
end process;

-- multiplexers to accomodate different SPI modes
transition_strobe  <= sck_rise when (CPHA = '1') else sck_fall;
sample_strobe      <= sck_fall when (CPHA = '1') else sck_rise;


transfer_state_machine : process begin
  wait until rising_edge(CLK);
  trigger_transfer_latch <= trigger_transfer_latch or TRIGGER_TRANSFER; -- latch transfer trigger
  
  case transfer_state is
    when IDLE =>
      -- start transfer at next full sck cycle
      if (transition_strobe = '1') and (trigger_transfer_latch = '1') then 
        sck_gate <= '1';
        transfer_state <= TRANSFER;
        trigger_transfer_latch <= '0'; -- clear your trigger memory
      end if;
    when TRANSFER =>
      if transition_strobe = '1' then
        if bit_counter < (WORDSIZE-1) then
          -- after processing bits 0-(WORDSIZE-2)
          bit_counter <= bit_counter + 1;
        else
          -- after last bit (WORDSIZE-1)
          bit_counter <= 0;
          sck_gate <= '0';
          transfer_state <= IDLE;
        end if;
      end if;
  end case;
  
  if RST = '1' then
    transfer_state <= IDLE;
    bit_counter <= 0 ;
    sck_gate <= '0';
  end if;

end process;


sample_and_hold_data_in : process begin
  wait until rising_edge(CLK);
  if TRIGGER_TRANSFER = '1' then
    data_in_buffer <= DATA_IN;
  end if;
end process;


rx_process : process begin
  wait until rising_edge(CLK);
  sample_strobe_buf <= sample_strobe;
  data_out_ready <= '0';
  TRANSFER_COMPLETE <= '0';
  
  if sample_strobe_buf = '1' then
    data_out_buffer( (WORDSIZE-1) - bit_counter ) <= MISO;
    if bit_counter = (WORDSIZE-1) then
      data_out_ready <= '1';
    end if;
  end if;
  
  if data_out_ready = '1' then
    DATA_OUT          <= data_out_buffer;
    TRANSFER_COMPLETE <= '1';
  end if;
  
end process;

sync_output : process begin
  wait until rising_edge(CLK);
  
  SCK  <= CPOL xor ( sck_raw_buf and sck_gate ); -- accomodate for reversed clock polarity
  MOSI <= data_in_buffer( (WORDSIZE-1) - bit_counter ) and sck_gate;

end process;
  
  
end architecture;