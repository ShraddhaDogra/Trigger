library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;

-- missing: end of PP/RDCMD by data_done signal.

entity spi_slim is
    generic(
      SLOW_SPI     : integer range c_NO to c_YES := c_YES
      );
    port(
      SYSCLK       : in    std_logic; -- 100MHz sysclock
      RESET        : in    std_logic; -- synchronous reset
      -- Command interface
      START_IN     : in    std_logic; -- one start pulse
      BUSY_OUT     : out   std_logic; -- SPI transactions are ongoing
      CMD_IN       : in    std_logic_vector(7 downto 0); -- SPI command byte
      ADL_IN       : in    std_logic_vector(7 downto 0); -- low address byte
      ADM_IN       : in    std_logic_vector(7 downto 0); -- mid address byte
      ADH_IN       : in    std_logic_vector(7 downto 0); -- high address byte
      MAX_IN       : in    std_logic_vector(7 downto 0); -- number of bytes to write / read (PP/RDCMD)
      TXDATA_IN    : in    std_logic_vector(7 downto 0); -- byte to be transmitted next
      TX_RD_OUT    : out   std_logic;
      RXDATA_OUT   : out   std_logic_vector(7 downto 0); -- current received byte
      RX_WR_OUT    : out   std_logic;
      TX_RX_A_OUT  : out   std_logic_vector(7 downto 0); -- memory block counter for PP/RDCMD
      -- SPI interface
      SPI_SCK_OUT  : out   std_logic;
      SPI_CS_OUT   : out   std_logic;
      SPI_SDI_IN   : in    std_logic;
      SPI_SDO_OUT  : out   std_logic;
      -- DEBUG
      CLK_EN_OUT   : out   std_logic;
      BSM_OUT      : out   std_logic_vector(7 downto 0);
      DEBUG_OUT    : out   std_logic_vector(31 downto 0)
    );
end entity;

architecture Behavioral of spi_slim is

-- new clock divider
signal div_counter     : std_logic_vector(1+SLOW_SPI downto 0);
signal div_done_x      : std_logic;
signal div_done        : std_logic; -- same as clk_en
signal clk_en          : std_logic; -- same as div_done

-- Statemachine signals
type state_t is (IDLE,CSL,TXCMD,TXADD_H,TXADD_M,TXADD_L,TXDATA,RXDATA,
                 WAIT1,WAIT2,WAIT3,WAIT4,WAIT5,WAIT6,WAIT7,WAIT8,CSH);
signal STATE, NEXT_STATE    : state_t;

signal rx_ena_x       : std_logic;
signal rx_ena         : std_logic;
signal tx_ena_x       : std_logic;
signal tx_ena         : std_logic;
signal busy_x         : std_logic;
signal busy           : std_logic;
signal spi_cs_x       : std_logic; -- SPI chip select (low active)
signal spi_cs         : std_logic;
signal spi_sck_x      : std_logic; -- SPI clock (rising edge active, from counter)
signal spi_sck        : std_logic;
signal tx_load_x      : std_logic; -- load TX shift register
signal tx_load        : std_logic;
signal tx_done_x      : std_logic; -- one memory byte sent
signal tx_done        : std_logic;
signal tx_sel_x       : std_logic_vector(2 downto 0); -- select TX content
signal tx_sel         : std_logic_vector(2 downto 0);
signal rx_store_x     : std_logic; -- store RX shift register
signal rx_store       : std_logic;
signal rx_complete    : std_logic;
signal rst_addr_x     : std_logic; -- reset address counter
signal rst_addr       : std_logic;

signal inc_addr_rx_x  : std_logic;
signal inc_addr_rx    : std_logic;
signal inc_addr_tx_x  : std_logic;
signal inc_addr_tx    : std_logic;
signal ce_addr_x      : std_logic;
signal ce_addr        : std_logic;

signal addr_ctr       : std_logic_vector(7 downto 0);
signal data_done_x    : std_logic;
signal data_done      : std_logic_vector(5 downto 0);

signal last_tx_bit_x  : std_logic;
signal last_tx_bit    : std_logic;
signal is_data_x      : std_logic;
signal is_data        : std_logic;

-- debug signals
signal bsm_x          : std_logic_vector(7 downto 0);
signal debug_x        : std_logic_vector(31 downto 0);

signal start          : std_logic; -- buffered start_in signal, as we have a clocked down state machine
signal cmd_int        : std_logic_vector(7 downto 0); -- internal command and address bytes
signal adh_int        : std_logic_vector(7 downto 0); -- internal command and address bytes
signal adm_int        : std_logic_vector(7 downto 0); -- internal command and address bytes
signal adl_int        : std_logic_vector(7 downto 0); -- internal command and address bytes
signal max_int        : std_logic_vector(7 downto 0);

-- transmitter
signal tx_sreg        : std_logic_vector(7 downto 0);
signal tx_reg_comb    : std_logic_vector(7 downto 0); -- multiplexer
signal tx_bit_cnt     : std_logic_vector(3 downto 0);

-- receiver
signal rx_sreg        : std_logic_vector(7 downto 0);
signal rx_bit_cnt_clr : std_logic;
signal rx_bit_cnt     : std_logic_vector(3 downto 0);

-- registers
signal rx_data            : std_logic_vector(7 downto 0);

-- FLASH commands
-- single byte commands
constant NOP    : std_logic_vector(7 downto 0) := x"FF";  -- no cmd to execute
constant WREN   : std_logic_vector(7 downto 0) := x"06";  -- write enable        -- OK -- CMD
constant WRDI   : std_logic_vector(7 downto 0) := x"04";  -- write disable        -- OK -- CMD
constant ERASE  : std_logic_vector(7 downto 0) := x"C7";  -- chip erase            -- OK -- CMD
constant DPD    : std_logic_vector(7 downto 0) := x"b9";  -- deep powerdown     -- OK -- CMD
constant RDPD   : std_logic_vector(7 downto 0) := x"ab";  -- resume powerdown   -- OK -- CMD

constant RDID   : std_logic_vector(7 downto 0) := x"9f";  -- read signature        -- OK -- CMD + readbyte(n)
constant RDSR   : std_logic_vector(7 downto 0) := x"05";  -- read status reg    -- OK -- CMD + readbyte(n)

constant WRSR   : std_logic_vector(7 downto 0) := x"01";  -- write stat. reg    -- OK -- CMD + writebyte(1)

constant SE64   : std_logic_vector(7 downto 0) := x"d8";  -- sector erase 64kB    -- OK -- CMD + ADH + ADM + ADL
constant SE32   : std_logic_vector(7 downto 0) := x"52";  -- sector erase 32kB    -- OK -- CMD + ADH + ADM + ADL
constant SE4    : std_logic_vector(7 downto 0) := x"20";  -- sector erase 32kB    -- OK -- CMD + ADH + ADM + ADL
constant SECP   : std_logic_vector(7 downto 0) := x"36";  -- sector protect        -- OK -- CMD + ADH + ADM + ADL
constant SECU   : std_logic_vector(7 downto 0) := x"39";  -- sector unprotect    -- OK -- CMD + ADH + ADM + ADL

constant RDCMD  : std_logic_vector(7 downto 0) := x"03";  -- read data            -- OK -- CMD + ADH + ADM + ADL + readbyte(n)
constant RDSPR  : std_logic_vector(7 downto 0) := x"3c";  -- read sect. prot.    --    -- CMD + ADH + ADM + ADL + readbye(n)
constant PP     : std_logic_vector(7 downto 0) := x"02";  -- page program        -- OK -- CMD + ADH + ADM + ADL + writebyte(n)


begin

-----------------------------------------------------------
-- Debug signals
-----------------------------------------------------------
debug_x(31 downto 24) <= bsm_x; --(others => '0');
debug_x(23 downto 20) <= tx_bit_cnt; --(others => '0');
debug_x(19 downto 16) <= rx_bit_cnt; --(others => '0');
debug_x(15)           <= busy;
debug_x(14)           <= start;
debug_x(13)           <= inc_addr_tx;
debug_x(12)           <= inc_addr_rx;
debug_x(11)           <= last_tx_bit;
debug_x(10)           <= rx_store;
debug_x(9)            <= rst_addr;
debug_x(8)            <= rx_ena;
debug_x(7)            <= data_done(0);
debug_x(6)            <= tx_done;
debug_x(5)            <= tx_load;
debug_x(4)            <= tx_ena;
debug_x(3)            <= is_data;
debug_x(2 downto 0)   <= tx_sel;


-----------------------------------------------------------
--
-----------------------------------------------------------

-----------------------------------------------------------
-- SPI clock generator
-----------------------------------------------------------
THE_CLOCK_DIVIDER: process(sysclk)
begin
    if( rising_edge(sysclk) ) then
        if( reset = '1' ) then
            div_counter <= (others => '0');
            div_done    <= '0';
            spi_sck     <= spi_sck_x;--'0';
        else
            div_counter <= div_counter + 1;
            div_done    <= div_done_x;
            spi_sck     <= spi_sck_x;
        end if;
    end if;
end process THE_CLOCK_DIVIDER;

div_done_x <= '1' when ( or_all(div_counter) = '0' ) else '0';

spi_sck_x  <= '1' when ( ((div_counter(1+SLOW_SPI downto 0+SLOW_SPI) = b"11") or (div_counter(1+SLOW_SPI downto 0+SLOW_SPI) = b"00")) and
                         ((tx_ena = '1') or (rx_ena = '1')) ) else '0';

clk_en <= div_done;

-----------------------------------------------------------
-- start signal and local register sets for CMD and ADR
-----------------------------------------------------------
THE_START_PROC: process(sysclk)
begin
    if( rising_edge(sysclk) ) then
        if   ( reset = '1' ) then
            start   <= '0';
            cmd_int <= (others => '0');
            adh_int <= (others => '0');
            adm_int <= (others => '0');
            adl_int <= (others => '0');
            max_int <= (others => '0');
        elsif( (start_in = '1') and (busy = '0') ) then
            start <= '1';
            cmd_int <= cmd_in;
            adh_int <= adh_in;
            adm_int <= adm_in;
            adl_int <= adl_in;
            max_int <= max_in;
        elsif( busy = '1' ) then
            start <= '0';
        end if;
    end if;
end process THE_START_PROC;

-----------------------------------------------------------
-- statemachine: clocked process
-----------------------------------------------------------
THE_STATEMACHINE: process( sysclk )
begin
    if( rising_edge(sysclk) ) then
        if   ( reset = '1' ) then
            STATE      <= IDLE;
            rx_ena     <= '0';
            tx_ena     <= '0';
            busy       <= '0';
            spi_cs     <= spi_cs_x;--'1';
            tx_load    <= '0';
            tx_sel     <= "000";
            rx_store   <= '0';
            rst_addr   <= '0';
            tx_done    <= '0';
            is_data    <= '0';
        elsif( clk_en = '1' ) then
            STATE    <= NEXT_STATE;
            rx_ena   <= rx_ena_x;
            tx_ena   <= tx_ena_x;
            busy     <= busy_x;
            spi_cs   <= spi_cs_x;
            tx_load  <= tx_load_x;
            tx_sel   <= tx_sel_x;
            rx_store <= rx_store_x;
            rst_addr <= rst_addr_x;
            tx_done  <= tx_done_x;
            is_data  <= is_data_x;
        end if;
    end if;
end process THE_STATEMACHINE;

-----------------------------------------------------------
-- state machine transition table
-----------------------------------------------------------
THE_STATE_TRANSITIONS: process( STATE, cmd_int, start, tx_bit_cnt, rx_bit_cnt, data_done(5) )
begin
    rx_ena_x   <= '0';
    tx_ena_x   <= '0';
    busy_x     <= '1';
    spi_cs_x   <= '1';
    tx_load_x  <= '0';
    tx_sel_x   <= "000";
    rx_store_x <= '0';
    rst_addr_x <= '0';
    tx_done_x  <= '0';
    is_data_x  <= '0';
    case STATE is
        when IDLE =>
            if( start = '1' ) then
                NEXT_STATE <= CSL;
                spi_cs_x   <= '0';
                tx_load_x  <= '1';
                tx_sel_x   <= "000";
                rst_addr_x <= '1';
            else
                NEXT_STATE <= IDLE;
                busy_x     <= '0';
            end if;

        when CSL =>
            NEXT_STATE <= TXCMD;
            tx_ena_x   <= '1';
            spi_cs_x   <= '0';

        when TXCMD =>
            if( tx_bit_cnt < x"7" ) then
                NEXT_STATE <= TXCMD;
                tx_ena_x   <= '1';
                spi_cs_x   <= '0';
            else
                case cmd_int is
                    when WREN | WRDI | ERASE | DPD | RDPD
                                =>    NEXT_STATE <= CSH;
                                    spi_cs_x   <= '0';
                    when SE64 | SE32 | SE4 | PP | RDCMD | SECP | SECU | RDSPR
                                =>    NEXT_STATE <= WAIT1;
                                    spi_cs_x   <= '0';
                                    tx_load_x  <= '1';
                                    tx_sel_x   <= "001"; -- ADH
                    when WRSR    =>    NEXT_STATE <= WAIT1;
                                    spi_cs_x   <= '0';
                                    tx_load_x  <= '1';
                                    tx_sel_x   <= "100"; -- TXDATA
                                    is_data_x  <= '1';
                    when RDSR | RDID
                                =>    NEXT_STATE <= WAIT1;
                                    spi_cs_x   <= '0';
                                    tx_load_x  <= '1';
                                    tx_sel_x   <= "110"; -- "00"
                    when others    =>    NEXT_STATE <= CSH;
                                    spi_cs_x   <= '0';
                end case;
            end if;

        when WAIT1 =>
            case cmd_int is
                when SE64 | SE32 | SE4 | PP | RDCMD | SECP | SECU | RDSPR
                            =>    NEXT_STATE <= TXADD_H;
                                tx_ena_x   <= '1';
                                spi_cs_x   <= '0';
                when RDSR | RDID
                            =>    NEXT_STATE <= RXDATA;
                                rx_ena_x   <= '1';
                                spi_cs_x   <= '0';
                when WRSR    =>    NEXT_STATE <= TXDATA;
                                tx_ena_x   <= '1';
                                spi_cs_x   <= '0';
                                is_data_x  <= '1';
                when others    =>    NEXT_STATE <= CSH;
                                spi_cs_x   <= '0';
            end case;

        when TXADD_H =>
            if( tx_bit_cnt < x"7" ) then
                NEXT_STATE <= TXADD_H;
                tx_ena_x   <= '1';
                spi_cs_x   <= '0';
            else
                NEXT_STATE <= WAIT2;
                spi_cs_x   <= '0';
                tx_load_x  <= '1';
                tx_sel_x   <= "010"; -- ADM
            end if;

        when WAIT2 =>
            NEXT_STATE <= TXADD_M;
            tx_ena_x   <= '1';
            spi_cs_x   <= '0';

        when TXADD_M =>
            if( tx_bit_cnt < x"7" ) then
                NEXT_STATE <= TXADD_M;
                tx_ena_x   <= '1';
                spi_cs_x   <= '0';
            else
                NEXT_STATE <= WAIT3;
                spi_cs_x   <= '0';
                tx_load_x  <= '1';
                tx_sel_x   <= "011"; -- ADL
            end if;

        when WAIT3 =>
            NEXT_STATE <= TXADD_L;
            tx_ena_x   <= '1';
            spi_cs_x   <= '0';

        when TXADD_L =>
            if( tx_bit_cnt < x"7" ) then
                NEXT_STATE <= TXADD_L;
                tx_ena_x   <= '1';
                spi_cs_x   <= '0';
            else
                case cmd_int is
                    when PP        =>    NEXT_STATE <= WAIT6;
                                    tx_load_x  <= '1';
                                    tx_sel_x   <= "100"; -- TXDATA
                                    spi_cs_x   <= '0';
                    when SE64 | SE32 | SE4 | SECP | SECU
                                =>    NEXT_STATE <= CSH;
                                    spi_cs_x   <= '0';
                    when RDCMD | RDSPR
                                =>    NEXT_STATE <= WAIT4;
                                    spi_cs_x   <= '0';
                                    tx_load_x  <= '1';
                                    tx_sel_x   <= "110"; -- "00"
                    when others    =>    NEXT_STATE <= CSH;
                                    spi_cs_x   <= '0';
                end case;
            end if;

        when WAIT4 =>
            case cmd_int is
                when RDCMD | RDSPR
                            =>    NEXT_STATE <= RXDATA;
                                rx_ena_x   <= '1';
                                spi_cs_x   <= '0';
                when others    =>    NEXT_STATE <= CSH;
                                spi_cs_x   <= '0';
            end case;

        when RXDATA =>
            if( rx_bit_cnt < x"7" ) then
                NEXT_STATE <= RXDATA;
                rx_ena_x   <= '1';
                spi_cs_x   <= '0';
            else
                case cmd_int is
                    when RDCMD | RDSR | RDID | RDSPR
                                =>    NEXT_STATE <= WAIT7;
                                    spi_cs_x   <= '0';
                                    rx_store_x <= '1';
                    when others    =>    NEXT_STATE <= CSH;
                                    spi_cs_x   <= '0';
                                    rx_store_x <= '1';
                end case;
            end if;

        when WAIT6 =>
            case cmd_int is
                when PP        =>    if( data_done(5) = '1' ) then
                                    NEXT_STATE <= CSH;
                                    spi_cs_x   <= '0';
                                else
                                    NEXT_STATE <= TXDATA;
                                    tx_ena_x   <= '1';
                                    spi_cs_x   <= '0';
                                    is_data_x  <= '1';
                                end if;
                when others    =>    NEXT_STATE <= CSH;
                                spi_cs_x   <= '0';
            end case;

        when TXDATA =>
            if( tx_bit_cnt < x"7" ) then
                NEXT_STATE <= TXDATA;
                tx_ena_x   <= '1';
                spi_cs_x   <= '0';
            else
                case cmd_int is
                    when PP        =>    NEXT_STATE <= WAIT6;
                                    spi_cs_x   <= '0';
                                    tx_done_x  <= '1';
                                    tx_load_x  <= '1';
                                    tx_sel_x   <= "100"; -- TXDATA
                    when others    =>    NEXT_STATE <= CSH;
                                    spi_cs_x   <= '0';
                end case;
            end if;
            is_data_x  <= '1';

        when WAIT7 =>
            NEXT_STATE <= WAIT8;
            spi_cs_x   <= '0';

        when WAIT8 =>
            case cmd_int is
                when RDCMD | RDID | RDSR | RDSPR
                            =>    if( data_done(5) = '1' ) then
                                    NEXT_STATE <= CSH;
                                    spi_cs_x   <= '0';
                                else
                                    NEXT_STATE <= RXDATA;
                                    rx_ena_x   <= '1';
                                    spi_cs_x   <= '0';
                                end if;
                when others    =>    NEXT_STATE <= CSH;
                                spi_cs_x   <= '0';
        end case;

        when WAIT5 =>
            NEXT_STATE <= CSH;
            spi_cs_x   <= '0';

        when CSH =>
            NEXT_STATE <= IDLE;
            busy_x     <= '0';

    end case;
end process THE_STATE_TRANSITIONS;

-- state machine output table
THE_STATEMACHINE_OUT: process( STATE )
begin
    -- default values
    rx_bit_cnt_clr    <= '1';

    case STATE is
        when IDLE     =>  bsm_x <= x"00";
        when CSL      =>  bsm_x <= x"09";
        when TXCMD    =>  bsm_x <= x"01";
        when TXDATA   =>  bsm_x <= x"02";
        when TXADD_H  =>  bsm_x <= x"03";
        when TXADD_M  =>  bsm_x <= x"04";
        when TXADD_L  =>  bsm_x <= x"05";
        when RXDATA   =>  bsm_x <= x"07";
        when WAIT1    =>  bsm_x <= x"10";
        when WAIT2    =>  bsm_x <= x"11";
        when WAIT3    =>  bsm_x <= x"12";
        when WAIT4    =>  bsm_x <= x"13";
        when WAIT8    =>  bsm_x <= x"17";
        when WAIT6    =>  bsm_x <= x"15";
        when WAIT5    =>  bsm_x <= x"14";
        when WAIT7    =>  bsm_x <= x"16";
        when CSH      =>  bsm_x <= x"08";
        when others   =>  bsm_x <= x"ff";
    end case;
end process THE_STATEMACHINE_OUT;

-- TX data register multiplexer
THE_TXREG_MUX: process( tx_sel, cmd_int, adh_int, adm_int, adl_int, txdata_in )
begin
    case tx_sel is
        when "000"    => tx_reg_comb <= cmd_int;
        when "001"    => tx_reg_comb <= adh_int;
        when "010"    => tx_reg_comb <= adm_int;
        when "011"    => tx_reg_comb <= adl_int;
        when "100"    => tx_reg_comb <= txdata_in;
        when "101"    => tx_reg_comb <= x"ee"; -- unused
        when "110"    => tx_reg_comb <= x"00"; -- fixed value
        when "111"    => tx_reg_comb <= x"aa"; -- fixed value
        when others   => tx_reg_comb <= x"00";
    end case;
end process THE_TXREG_MUX;

-- TXData shift register and bit counter
THE_TX_SHIFT_AND_BITCOUNT: process( sysclk )
begin
    if( rising_edge(sysclk) ) then
        if( reset = '1' ) then
            tx_sreg(6 downto 0) <= (others => '0');
            tx_bit_cnt   <= (others => '0');
            last_tx_bit  <= '0';
        elsif   ( (clk_en = '1' ) and (tx_load = '1') ) then
            tx_bit_cnt <= (others => '0');
            tx_sreg    <= tx_reg_comb;
        elsif( (clk_en = '1') and (tx_ena = '1') ) then
            tx_bit_cnt <= tx_bit_cnt + 1;
            tx_sreg    <= tx_sreg (6 downto 0) & '0';
        end if;
        last_tx_bit <= last_tx_bit_x;
    end if;
end process THE_TX_SHIFT_AND_BITCOUNT;

last_tx_bit_x <= '1' when ( tx_bit_cnt = x"7" ) else '0';

-- receiver shift register and bit counter
THE_RX_SHIFT_AND_BITCOUNT: process( sysclk )
begin
    if( rising_edge(sysclk) ) then
        if   ( reset = '1' ) then
            rx_bit_cnt   <= (others => '0');
            rx_sreg      <= (others => '0');
        elsif( (clk_en = '1') and (rx_ena = '1') ) then
            rx_sreg <= rx_sreg (6 downto 0) & spi_sdi_in;
            case rx_bit_cnt is
                when x"0" | x"1" | x"2" | x"3" | x"4" | x"5" | x"6" =>
                    rx_bit_cnt   <= rx_bit_cnt + 1;
                when x"7" =>
                    rx_bit_cnt   <= (others => '0');
                when others =>
                    null;
            end case;
        end if;
    end if;
end process THE_RX_SHIFT_AND_BITCOUNT;

-- the rx_data register
THE_RXDATA_REG: process( sysclk )
begin
    if( rising_edge(sysclk) ) then
        if   ( reset = '1' ) then
            rx_data     <= (others => '0');
            rx_complete <= '0';
        elsif( (clk_en = '1') and (rx_store = '1') ) then
            rx_data     <= rx_sreg;
            rx_complete <= '1';
        else
            rx_complete <= '0';
        end if;
    end if;
end process;

-- address generator for external BRAM
THE_ADDR_COUNTER: process( sysclk )
begin
    if( rising_edge(sysclk) ) then
        if   ( (reset = '1') or (rst_addr = '1') ) then
            addr_ctr    <= (others => '0');
            data_done   <= (others => '0');
            inc_addr_rx <= '0';
            inc_addr_tx <= '0';
            ce_addr     <= '0';
        elsif( ce_addr = '1' ) then
            addr_ctr <= addr_ctr + 1;
        end if;
        data_done(5 downto 1) <= data_done(4 downto 0);
        data_done(0) <= data_done_x;
        inc_addr_rx  <= inc_addr_rx_x;
        inc_addr_tx  <= inc_addr_tx_x;
        ce_addr      <= ce_addr_x;
    end if;
end process THE_ADDR_COUNTER;

inc_addr_rx_x <= '1' when ( rx_complete = '1' ) else '0';
--inc_addr_tx_x <= '1' when ( (clk_en = '1') and (tx_done = '1') ) else '0';
inc_addr_tx_x <= '1' when ( (clk_en = '1') and (last_tx_bit = '1') and (is_data = '1') ) else '0';
ce_addr_x     <= inc_addr_rx or inc_addr_tx;

data_done_x   <= '1' when ( addr_ctr = max_int ) else '0';

-- output signals
spi_cs_out   <= spi_cs;
spi_sck_out  <= spi_sck;
spi_sdo_out  <= tx_sreg(7);
busy_out     <= busy;

tx_rd_out    <= '0';
rxdata_out   <= rx_data;
rx_wr_out    <= rx_complete;
tx_rx_a_out  <= addr_ctr;

clk_en_out   <= clk_en;
bsm_out      <= bsm_x;
debug_out    <= debug_x;


end Behavioral;
