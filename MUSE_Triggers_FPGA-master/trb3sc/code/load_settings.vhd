library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;

entity load_settings is
  generic(
    HEADER_PAGE_ADDR    : std_logic_vector(15 downto 0) := x"7000";
    
    -- = floor(256/6), because 256 bytes per page, 6 bytes per register
    REGISTERS_PER_PAGE  : integer := 42
  );
  port(
    CLK        : in std_logic;
    RST        : in std_logic;
    
   -- the bus handler signals 
    BUS_RX           : in  CTRLBUS_RX;
    BUS_TX           : out CTRLBUS_TX;
    
    IS_ACTIVE        : out std_logic;
    
    BUS_MASTER_TX    : out CTRLBUS_RX;
    BUS_MASTER_RX    : in  CTRLBUS_TX;
    
    SPI_MOSI         : out  std_logic;
    SPI_MISO         : in   std_logic;
    SPI_SCK          : out  std_logic;
    SPI_NCS          : out  std_logic
    
    );
end entity;



architecture load_settings_arch of load_settings is



-- -- local register addresses

constant ADDR_TAKE_SPI              : std_logic_vector( 7 downto 0) := x"00";
constant ADDR_NCS                   : std_logic_vector( 7 downto 0) := x"02";
constant ADDR_DATA_IN               : std_logic_vector( 7 downto 0) := x"03";
constant ADDR_DATA_OUT              : std_logic_vector( 7 downto 0) := x"04";
constant ADDR_TRANSMISSION_COUNTER  : std_logic_vector( 7 downto 0) := x"05";

constant ADDR_PAGE_SELECT           : std_logic_vector( 7 downto 0) := x"06"; 
constant ADDR_PAGE_POS              : std_logic_vector( 7 downto 0) := x"07"; 
constant ADDR_POP_PAGE_DATA         : std_logic_vector( 7 downto 0) := x"08";
constant ADDR_POP_PAGE_NOBYTES      : std_logic_vector( 7 downto 0) := x"09";
constant ADDR_FEEDBACK              : std_logic_vector( 7 downto 0) := x"0A";
constant ADDR_PARSE_TRIGGER         : std_logic_vector( 7 downto 0) := x"0B";
constant ADDR_SC_WRITE_ERRORS       : std_logic_vector( 7 downto 0) := x"0C";

-- -- spi related signals

signal take_spi          : std_logic := '0';
signal spi_ncs_latch     : std_logic := '1';
signal spi_ready, spi_trigger : std_logic;

signal spi_data_in   : std_logic_vector(7 downto 0);
signal spi_data_out  : std_logic_vector(7 downto 0);

-- signal loopback : std_logic;

signal transmission_counter : std_logic_vector(15 downto 0) := x"0000";

-- page ram handling

signal ram_wr               : std_logic;
signal ram_addr             : std_logic_vector(7 downto 0);
signal ram_dout             : std_logic_vector(7 downto 0);
signal ram_din              : std_logic_vector(7 downto 0);

signal ram_waddr, ram_raddr : std_logic_vector(7 downto 0);
signal select_write_ram     : std_logic := '0';

signal page_number          : std_logic_vector(15 downto 0);

-- signals for READ_PAGE_TO_RAM process

type   read_page_state_t is (IDLE,SEND_CMD,SEND_A0,SEND_A1,SEND_A2,READ_DATA,WAIT_FOR_SPI_READY,STORE_DATA);
signal read_page_state,next_read_page_state : read_page_state_t := IDLE;
signal trigger_read_page : std_logic;
signal read_page_ready   : std_logic;
signal ram_wr_pointer    : std_logic_vector (7 downto 0);

-- signal read_page_init_counter : std_logic_vector (8 downto 0) := (others => '0');

-- signals for the POP_PAGE_DATA process
signal trigger_pop_page_data : std_logic;
-- signal pop_page_word_counter : integer range 0 to 63;
signal pop_page_position, new_pop_page_position : integer range 0 to 255 := 0;
signal set_pop_page_position : std_logic := '0';
signal pop_page_noBytes              : integer range 0 to 255;
signal pop_page_noBytes_popped       : integer range 0 to 255;
signal pop_page_noBytes_pushed       : integer range 0 to 255;
signal pop_page_ram_delay            : integer range 0 to 2;
type   pop_page_state_t is (IDLE,ACTIVE);
signal pop_page_state : pop_page_state_t := IDLE;
signal pop_page_data_word  : std_logic_vector (31 downto 0);
signal pop_page_data_ready : std_logic;
-- signal pop_page_rewind     : std_logic;
signal wait_counter : unsigned(23 downto 0) := x"000001";


-- signals for the PARSE_PAGE process

signal parse_trigger : std_logic;
type   parse_state_t is (
  WAIT_FOR_COMMAND,
  START,
  READ_HEADER_PAGE,
  WAIT4PAGE,
  WAIT4RAM,
  VERIFY_START_STRING,
  GET_NO_REGISTERS,
  STORE_NO_REGISTERS,
  GET_NO_PAGES,
  STORE_NO_PAGES,
  READ_NEXT_PAGE,
  READ_SC_ADDR,
  STORE_SC_ADDR,
  READ_SC_VALUE,
  STORE_SC_VALUE,
  SEND_SC_DATA,
  WAIT4_SC_ACK,
  SUCCESS,FAIL);
signal parse_state : parse_state_t := WAIT_FOR_COMMAND;
signal next_parse_state : parse_state_t := WAIT_FOR_COMMAND;
signal parse_counter : integer range 0 to 255;

signal parse_feedback : std_logic_vector(31 downto 0) := (others=>'0');

signal registers_to_read : std_logic_vector(31 downto 0);
signal     pages_to_read : std_logic_vector(31 downto 0);

signal current_sc_addr  : std_logic_vector(15 downto 0);
signal current_sc_value : std_logic_vector(31 downto 0);

signal sc_ack_timeout   : integer range 0 to 31;
signal sc_write_errors  : std_logic_vector(31 downto 0) := (others =>'0');



type header_string_t is array(7 downto 0) of std_logic_vector(7 downto 0);
-- 53 4c 4f 57 43 54 52 4c
-- a set of ascii characters that reads "SLOWCTRL"
signal header_string : header_string_t := ( 0=>x"53", 1=>x"4c", 2=>x"4f", 3=>x"57", 4=>x"43", 5=>x"54", 6=>x"52", 7=>x"4c");

begin


THE_SPI_MASTER : entity work.spi_master_generic
  generic map(
    WORDSIZE          => 8,
    CPOL              => '0',
    CPHA              => '0',
    SPI_CLOCK_DIVIDER => 10
  )
  port map(
    MOSI => SPI_MOSI,
    MISO => SPI_MISO,
    SCK  => SPI_SCK,
    
    CLK => CLK,
    RST => RST,
    
    DATA_OUT => spi_data_out,
    DATA_IN  => spi_data_in,
    
    TRANSFER_COMPLETE => spi_ready,
    TRIGGER_TRANSFER  => spi_trigger
  );

THE_PAGE_RAM : entity work.ram
  generic map(
    depth => 8,
    width => 8
  )
  port map(
    CLK  => CLK,
    wr   => ram_wr,
    a    => ram_addr, 
    dout => ram_dout, 
    din  => ram_din
  );


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Memory Interface
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


IS_ACTIVE <= take_spi;
SPI_NCS   <= spi_ncs_latch;

-- multiplexed access to the page ram address input
ram_addr <= ram_waddr when (select_write_ram = '1') else ram_raddr;

-- POP_PAGE_DATA : process begin
-- -- read 32 bit from the page, to send it over trb_net
--   wait until rising_edge(CLK);
--   
--   pop_page_data_ready <= '0';
--   
--   case pop_page_state is
--     when IDLE =>
--       ram_raddr <= x"00";
--       pop_page_byte_counter <= 0;
--       
--       if pop_page_rewind = '1' then
--         pop_page_word_counter <= 0;
--       end if;
--       
--       if trigger_pop_page_data = '1' then
--         pop_page_state <= READ_BYTE;
--       end if;
--       
--     when READ_BYTE =>
--       ram_raddr <= std_logic_vector(to_unsigned(pop_page_byte_counter + pop_page_word_counter*4,8));
--       pop_page_state <= WAIT4RAM;
--     when WAIT4RAM =>
--       pop_page_state <= PUSH_BYTE;
--     when PUSH_BYTE =>
--       pop_page_data_word( (pop_page_byte_counter*8 + 7) downto (pop_page_byte_counter*8) ) <= ram_dout;
--       if pop_page_byte_counter < 3 then
--         pop_page_state <= READ_BYTE;
--         pop_page_byte_counter <= pop_page_byte_counter +1;
--       else -- pushed last byte
--         pop_page_state <= IDLE;
--         pop_page_word_counter <= pop_page_word_counter +1;
--         pop_page_data_ready <= '1';
--       end if;
--   end case;
--   
--   if RST = '1' then
--     pop_page_state <= IDLE;
--   end if;
-- end process;

POP_PAGE_DATA : process begin
  -- read n byte from the ram to a 32 bit output register "pop_page_data_word", new bytes get shifted in from the right
  wait until rising_edge(CLK);
  pop_page_data_ready <= '0';
  
  case pop_page_state is
    when IDLE =>
      
      pop_page_ram_delay <= 0;
      
      if set_pop_page_position = '1' then
        pop_page_position <= new_pop_page_position;
      end if;
      
      if trigger_pop_page_data = '1' then
        pop_page_state <= ACTIVE;
        pop_page_noBytes_popped  <= 0;
        pop_page_noBytes_pushed  <= 0;
        pop_page_data_word <= (others => '0'); -- reset output register
      end if;
      
    when ACTIVE =>
      
      ram_raddr <= std_logic_vector(to_unsigned(pop_page_position,8)); -- give address to ram
      
      if pop_page_noBytes_popped < pop_page_noBytes  then
        pop_page_position <= pop_page_position +1; -- increment ram pointer
        pop_page_noBytes_popped <= pop_page_noBytes_popped +1;
      end if;
      
      -- set first addr when ram_delay = 0, do nothing when ram_delay = 1, use ram_dout when ram_delay = 2
      if pop_page_ram_delay < 2 then
        pop_page_ram_delay <= pop_page_ram_delay +1;
      else -- now ram is ready
        -- shift old content to the left
        pop_page_data_word(31 downto 8) <= pop_page_data_word(23 downto 0);
        -- shift in new byte from the ram
        pop_page_data_word(7 downto 0) <= ram_dout;
        pop_page_noBytes_pushed <= pop_page_noBytes_pushed +1;
        
        if pop_page_noBytes_pushed = (pop_page_noBytes -1) then -- this is the last byte we want
          pop_page_state <= IDLE;
          pop_page_data_ready <= '1';
        end if;
      end if;
  end case;
  
  if RST = '1' then
    pop_page_state <= IDLE;
  end if;
end process;



READ_PAGE_TO_RAM : process begin
-- read a complete page from flash and store it in the page ram
  wait until rising_edge(CLK);
  
  spi_trigger <= '0';
  ram_wr <= '0';
  read_page_ready <= '0';
  select_write_ram <= '0'; -- free access to ram_addr again
  
  case read_page_state is
  
    when IDLE =>
      spi_ncs_latch <= '1';
      if trigger_read_page = '1' then
        read_page_state <= SEND_CMD;
        spi_ncs_latch <= '0';
      end if;
      
    when WAIT_FOR_SPI_READY =>
      if spi_ready = '1' then
        read_page_state <= next_read_page_state;
      end if;
    
    when SEND_CMD  =>
      spi_data_in   <= x"03"; -- the read command for the flash
      spi_trigger   <= '1';
      read_page_state      <= WAIT_FOR_SPI_READY;
      next_read_page_state <= SEND_A0;
      
    when SEND_A0   =>
      spi_data_in   <= page_number(15 downto 8);
      spi_trigger   <= '1';
      read_page_state      <= WAIT_FOR_SPI_READY;
      next_read_page_state <= SEND_A1;
      
    when SEND_A1   =>
      spi_data_in   <= page_number(7 downto 0);
      spi_trigger   <= '1';
      read_page_state      <= WAIT_FOR_SPI_READY;
      next_read_page_state <= SEND_A2;
      
    when SEND_A2   =>
      spi_data_in   <= x"00";
      spi_trigger   <= '1';
      read_page_state      <= WAIT_FOR_SPI_READY;
      next_read_page_state <= READ_DATA;
      ram_wr_pointer       <= x"00"; -- go to beginning of ram
      
    when READ_DATA =>
      spi_data_in   <= x"00";
      spi_trigger   <= '1';
      read_page_state      <= WAIT_FOR_SPI_READY;
      next_read_page_state <= STORE_DATA;
      
    when STORE_DATA =>
      select_write_ram <= '1'; -- take exclusive access to ram_addr
      ram_wr  <= '1';
      ram_din <= spi_data_out;
      ram_waddr <= ram_wr_pointer;
      -- increment ram address
      if unsigned(ram_wr_pointer) < 255 then
        ram_wr_pointer <= std_logic_vector(unsigned(ram_wr_pointer)+1);
        read_page_state <= READ_DATA;
      else -- we just read in the last byte
        read_page_ready  <= '1';
        read_page_state  <= IDLE;
      end if;
      
  
  end case;
  
  if RST = '1' then
    read_page_state <= IDLE;
  end if;
  
  
--   -- init ram with bogus data
--   
--   if unsigned(read_page_init_counter) < 256 then
--     select_write_ram <= '1';
--     read_page_init_counter <= std_logic_vector(unsigned(read_page_init_counter)+1);
--     ram_wr <= '1';
--     ram_waddr <= read_page_init_counter(7 downto 0);
--     ram_din   <= read_page_init_counter(7 downto 0);
--   end if;
  
  

end process;


PARSE : process begin
  wait until rising_edge(CLK);
  
  trigger_read_page <= '0';
  trigger_pop_page_data <= '0';
  set_pop_page_position <= '0';
  
  BUS_MASTER_TX.data    <= (others => '0');
  BUS_MASTER_TX.addr    <= (others => '0');
  BUS_MASTER_TX.write   <=            '0' ;
  BUS_MASTER_TX.read    <=            '0' ;
  BUS_MASTER_TX.timeout <=            '0' ;
   
  case parse_state is
  
    when WAIT_FOR_COMMAND =>
      take_spi <= '0';
      if parse_trigger = '1' then
        parse_state <= START;
      end if;
      
    when START =>
      parse_state <= READ_HEADER_PAGE;
      take_spi <= '1';
      sc_write_errors <= (others => '0');
    
    when READ_HEADER_PAGE =>
      page_number <= HEADER_PAGE_ADDR;
      trigger_read_page <= '1';
      parse_state <= WAIT4PAGE;
      parse_counter <= 0;
      next_parse_state <= VERIFY_START_STRING;

    when WAIT4PAGE =>
      if read_page_ready = '1' then
        parse_state <= next_parse_state;
      end if;

    when VERIFY_START_STRING =>
      parse_state <= WAIT4RAM;
      next_parse_state <= VERIFY_START_STRING;
      
     
     
      if parse_counter = 0 then
        pop_page_noBytes <= 1;
        new_pop_page_position <= 0;
        set_pop_page_position <= '1';
      else
        if parse_counter = 8 then
          -- so far everything has evaluated fine
          parse_state <= GET_NO_REGISTERS;
        end if;
        -- if one of the characters is not there, goto FAIL
        if not(pop_page_data_word(7 downto 0) = header_string(parse_counter-1)) then
          parse_state <= FAIL;
        end if;
      end if;
      
      if parse_counter < 8 then
        trigger_pop_page_data <= '1';
        parse_counter <= parse_counter +1;
      end if;
      
    when WAIT4RAM =>
      if pop_page_data_ready = '1' then
        parse_state <= next_parse_state;
      end if;
      
    when GET_NO_REGISTERS =>
      pop_page_noBytes <= 4;
      trigger_pop_page_data <= '1';
      
      next_parse_state <= STORE_NO_REGISTERS;
      parse_state <= WAIT4RAM;
    
    when STORE_NO_REGISTERS =>
      registers_to_read <= pop_page_data_word;
      parse_state <= GET_NO_PAGES;
    
    when GET_NO_PAGES =>
      trigger_pop_page_data <= '1';
      
      next_parse_state <= STORE_NO_PAGES;
      parse_state <= WAIT4RAM;
      
    when STORE_NO_PAGES =>
      pages_to_read <= pop_page_data_word;
      parse_state <= READ_NEXT_PAGE;
      
      
    when READ_NEXT_PAGE =>
    
      if unsigned(pages_to_read) > 0 then
        page_number <= std_logic_vector(unsigned(page_number)+1);
        trigger_read_page <= '1';
        parse_state <= WAIT4PAGE;
        parse_counter <= 0;
        
        -- reset page read position
        new_pop_page_position <= 0;
        set_pop_page_position <= '1';
        pages_to_read <= std_logic_vector(unsigned(pages_to_read)-1);
        
        next_parse_state <= READ_SC_ADDR;
      else
        parse_state <= SUCCESS;
      end if;
      
    when READ_SC_ADDR =>
      pop_page_noBytes <= 2;
      trigger_pop_page_data <= '1';
      next_parse_state <= STORE_SC_ADDR;
      parse_state <= WAIT4RAM;
      
    when STORE_SC_ADDR =>
      current_sc_addr <= pop_page_data_word(15 downto 0);
      parse_state <= READ_SC_VALUE;
      
    when READ_SC_VALUE =>
      pop_page_noBytes <= 4;
      trigger_pop_page_data <= '1';
      next_parse_state <= STORE_SC_VALUE;
      parse_state <= WAIT4RAM;
      
    when STORE_SC_VALUE =>
      current_sc_value <= pop_page_data_word;
      parse_state <= SEND_SC_DATA;
      registers_to_read <= std_logic_vector(unsigned(registers_to_read)-1);
      
    when SEND_SC_DATA =>
      BUS_MASTER_TX.data    <= current_sc_value;
      BUS_MASTER_TX.addr    <= current_sc_addr;
      BUS_MASTER_TX.write   <= '1';
      parse_state <= WAIT4_SC_ACK;
      sc_ack_timeout <= 31;
      
    when WAIT4_SC_ACK =>
      if sc_ack_timeout = 0 
        or BUS_MASTER_RX.ack     = '1'   
        or BUS_MASTER_RX.wack    = '1'   
        or BUS_MASTER_RX.rack    = '1' 
        or BUS_MASTER_RX.nack    = '1' 
        or BUS_MASTER_RX.unknown = '1' then
        
        -- timeout or error
        if sc_ack_timeout = 0 
          or BUS_MASTER_RX.rack    = '1'
          or BUS_MASTER_RX.nack    = '1'
          or BUS_MASTER_RX.unknown = '1' then
          sc_write_errors <= std_logic_vector(unsigned(sc_write_errors)+1);
        end if;
      
        parse_counter <= parse_counter +1;
        parse_state   <= READ_SC_ADDR;
        
        if parse_counter >= (REGISTERS_PER_PAGE -1) then
          if unsigned(pages_to_read) > 0 then
            parse_state <= READ_NEXT_PAGE;
          else
            parse_state <= SUCCESS;
          end if;
        end if;
        
        if unsigned(registers_to_read) = 0 then
          parse_state <= SUCCESS;
        end if;
        
      else
        sc_ack_timeout <= sc_ack_timeout -1;
      end if;
      
    when SUCCESS =>
      parse_state <= WAIT_FOR_COMMAND;
      parse_feedback <= current_sc_addr & current_sc_value(15 downto 0);
    
    when FAIL => 
      parse_state <= WAIT_FOR_COMMAND;
      parse_feedback <= x"000000F0";
  
  end case;
  
  if RST = '1' then
    parse_state <= WAIT_FOR_COMMAND;
    take_spi <= '0';
    sc_write_errors <= (others => '0');
  end if;

end process;


sync : process begin
  wait until rising_edge(CLK);
  BUS_TX.data <= (others => '0'); -- default 
  BUS_TX.nack <= '0';
  BUS_TX.unknown <= '0';
  BUS_TX.ack <= '0';
  
--   spi_trigger <= '0';
--   trigger_read_page <= '0';
--   trigger_pop_page_data <= '0';
--   set_pop_page_position <= '0';
  parse_trigger <= '0';
  
  if( BUS_RX.write = '1') then -- got a write command
    BUS_TX.ack <= '1';    
    
    case BUS_RX.addr(7 downto 0) is
      when ADDR_TAKE_SPI =>
--         take_spi <= BUS_RX.data(0);
      when ADDR_DATA_IN =>
--         spi_data_in <= BUS_RX.data(7 downto 0);
--         spi_trigger <= '1';
      when ADDR_NCS =>
--         spi_ncs_latch <= BUS_RX.data(0);
        
      when ADDR_PAGE_SELECT =>
--         page_number <= BUS_RX.data(15 downto 0);
--         trigger_read_page <= '1';
      when ADDR_PAGE_POS =>
--         set_pop_page_position <= '1';
--         new_pop_page_position <= to_integer(unsigned(BUS_RX.data(7 downto 0)));
      when ADDR_POP_PAGE_NOBYTES =>
--         pop_page_noBytes <= to_integer(unsigned(BUS_RX.data(7 downto 0)));
      when ADDR_PARSE_TRIGGER =>
        parse_trigger <= '1';
      when others =>
        BUS_TX.ack <= '0';
        BUS_TX.unknown <= '1';
    end case;
  end if;
  
  if( BUS_RX.read = '1') then -- got a read command
    BUS_TX.ack <= '1';
    BUS_TX.data(15 downto 0) <= (others => '0');
    case BUS_RX.addr(7 downto 0) is
      when ADDR_TAKE_SPI =>
        BUS_TX.data(0) <= take_spi;
      when ADDR_DATA_OUT =>
        BUS_TX.data(7 downto 0) <= spi_data_out;
      when ADDR_DATA_IN =>
        BUS_TX.data(7 downto 0) <= spi_data_in;
      when ADDR_TRANSMISSION_COUNTER =>
        BUS_TX.data(15 downto 0) <= transmission_counter;
      when ADDR_NCS =>
        BUS_TX.data(0) <= spi_ncs_latch;
      when ADDR_PAGE_SELECT =>
        BUS_TX.data(15 downto 0) <= page_number;
      when ADDR_POP_PAGE_NOBYTES =>
        BUS_TX.data(7 downto 0) <= std_logic_vector(to_unsigned(pop_page_noBytes,8));
      when ADDR_POP_PAGE_DATA =>
--         trigger_pop_page_data <= '1';
        BUS_TX.ack <= '0'; -- don't ack yet, wait for pop_page_data_ready
      when ADDR_FEEDBACK =>
        BUS_TX.data <= parse_feedback;
      when ADDR_SC_WRITE_ERRORS =>
        BUS_TX.data <= sc_write_errors;
      -- DEFAULT --
      when others =>
        BUS_TX.ack <= '0';
        BUS_TX.unknown <= '1';        
    end case;
  end if;
  
  if pop_page_data_ready = '1' then
    BUS_TX.data(31 downto 0) <= pop_page_data_word;
    BUS_TX.ack <= '1';
  end if;

  
  if wait_counter(wait_counter'left) = '0' and not (wait_counter = 0) then
    wait_counter <= wait_counter + 1;
  elsif wait_counter(wait_counter'left) = '1' then
    wait_counter <= (others => '0');
    parse_trigger <= '1';
  end if;
  
  
  if RST = '1' then
    transmission_counter <= (others => '0');
    wait_counter <= (0 => '1', others => '0');
  end if;

    
  
  if(spi_ready = '1') then 
    transmission_counter <= std_logic_vector(unsigned(transmission_counter) +1);
  end if;
  
  
end process;
  

end architecture;

