LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;

entity trb_net_med_8bit_slow is
  generic(
    TRANSMISSION_CLOCK_DIVIDER: integer range 2 to 62 := 2   --even values only!
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    -- Internal direction port (MII)
    INT_DATAREADY_OUT : out STD_LOGIC;
    INT_DATA_OUT      : out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
    INT_PACKET_NUM_OUT: out STD_LOGIC_VECTOR (c_NUM_WIDTH-1  downto 0);
    INT_READ_IN       : in  STD_LOGIC;
    INT_DATAREADY_IN  : in  STD_LOGIC;
    INT_DATA_IN       : in  STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
    INT_PACKET_NUM_IN : in  STD_LOGIC_VECTOR (c_NUM_WIDTH-1  downto 0);
    INT_READ_OUT      : out STD_LOGIC;
    --  Media direction port
    MED_DATA_OUT      : out STD_LOGIC_VECTOR (15 downto 0);
    MED_DATA_IN       : in  STD_LOGIC_VECTOR (15 downto 0);
    -- Status and control port
    STAT: out STD_LOGIC_VECTOR (31 downto 0);
              --STAT(5 downto 2): Debug bits in

    CTRL: in  STD_LOGIC_VECTOR (31 downto 0);
    STAT_OP : out std_logic_vector(15 downto 0);
    CTRL_OP : in  std_logic_vector(15 downto 0)
    );
end entity trb_net_med_8bit_slow;

architecture trb_net_med_8bit_slow_arch of trb_net_med_8bit_slow is

  signal buf_INT_DATA_IN, next_buf_INT_DATA_IN   :std_logic_vector(7 downto 0);

  signal next_INT_DATA_OUT, buf_INT_DATA_OUT:    std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal next_INT_PACKET_NUM_OUT, buf_INT_PACKET_NUM_OUT:    std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal next_INT_DATAREADY_OUT, buf_INT_DATAREADY_OUT:  std_logic;
  signal buf_INT_READ_OUT: std_logic;
  signal reg_MED_FIRST_PACKET_IN : std_logic;
  signal next_buf_MED_DATA_OUT, buf_MED_DATA_OUT: std_logic_vector(7 downto 0);
  signal buf_MED_TRANSMISSION_CLK_OUT: std_logic;
  signal buf_MED_CARRIER_OUT, next_MED_CARRIER_OUT:          STD_LOGIC;
  signal buf_MED_PARITY_OUT, next_MED_PARITY_OUT:           STD_LOGIC;
  signal buf_MED_FIRST_PACKET_OUT, next_MED_FIRST_PACKET_OUT : std_logic;
  signal my_error :  std_logic_vector(2 downto 0);
  signal fatal_error, media_not_connected : std_logic;
  signal next_media_not_connected : std_logic;
  signal transmission_clk_Counter : std_logic_vector(4 downto 0);
  signal next_transmission_clk_Counter : std_logic_vector(4 downto 0);
  signal next_TRANSMISSION_CLK: std_logic;
  signal buf_STAT : std_logic_vector(31 downto 0);

  signal last_TRCLK, this_TRCLK: std_logic;
  signal CLK_counter,next_CLK_counter: std_logic_vector(7 downto 0);

  signal last_MED_TRANSMISSION_CLK_IN : std_logic;
  signal last_MED_FIRST_PACKET_IN : std_logic;
  signal reg_MED_DATA_IN : std_logic_vector(11 downto 0);
  signal reg_MED_TRANSMISSION_CLK_IN, reg_MED_CARRIER_IN : std_logic;
  signal reg_MED_PARITY_IN : std_logic;
  signal recv_counter : std_logic_vector(3 downto 0);
  signal transmission_running, next_transmission_running : std_logic;
  signal buf_MED_DATA_IN, next_buf_MED_DATA_IN : std_logic_vector(7 downto 0);

  signal led_counter : std_logic_vector(18 downto 0);
  signal send_resync_counter : std_logic_vector(11 downto 0);
  signal send_resync         : std_logic;
  signal rx_led, tx_led, link_led : std_logic;
  signal trbnet_reset : std_logic;


begin
  INT_DATAREADY_OUT <= buf_INT_DATAREADY_OUT;
  INT_DATA_OUT <= buf_INT_DATA_OUT;
  INT_PACKET_NUM_OUT <= buf_INT_PACKET_NUM_OUT;
  INT_READ_OUT <= buf_INT_READ_OUT;
  STAT <= buf_STAT;

  buf_STAT(1 downto 0) <= (others => '0');
  buf_STAT(5 downto 2) <= MED_DATA_IN(11 downto 8);
  buf_STAT(18 downto 6)<= (others => '0');
  buf_STAT(31 downto 19) <= reg_MED_PARITY_IN & reg_MED_CARRIER_IN & reg_MED_TRANSMISSION_CLK_IN & reg_MED_FIRST_PACKET_IN & reg_MED_DATA_IN(11) & reg_MED_DATA_IN(7 downto 0);


  MED_DATA_OUT(7 downto 0) <= buf_MED_DATA_OUT;
  MED_DATA_OUT(10 downto 8) <= (others => '0');
  MED_DATA_OUT(11) <= (not reset or send_resync);
  MED_DATA_OUT(12) <= buf_MED_FIRST_PACKET_OUT;
  MED_DATA_OUT(13) <= buf_MED_TRANSMISSION_CLK_OUT;
  MED_DATA_OUT(14) <= buf_MED_CARRIER_OUT;
  MED_DATA_OUT(15) <= buf_MED_PARITY_OUT;


--LED & Stat_OP
  STAT_OP(2 downto 0) <= my_error;
  STAT_OP(8 downto 3) <= (others => '0');
  STAT_OP(9)  <= link_led;
  STAT_OP(10) <= rx_led;
  STAT_OP(11) <= tx_led;
  STAT_OP(12) <= '0';
  STAT_OP(13) <= not reg_MED_DATA_IN(11) and not last_MED_TRANSMISSION_CLK_IN and reg_MED_TRANSMISSION_CLK_IN and reg_MED_CARRIER_IN;
  STAT_OP(14) <= (not reg_MED_DATA_IN(11)  and reg_MED_CARRIER_IN) or media_not_connected;
  STAT_OP(15) <= (not reg_MED_DATA_IN(11) and not last_MED_TRANSMISSION_CLK_IN and reg_MED_TRANSMISSION_CLK_IN  and reg_MED_CARRIER_IN) or media_not_connected;

  link_led <= reg_MED_DATA_IN(11);

  process(CLK)
    begin
      if rising_edge(CLK) then
        if reset = '1' then
          led_counter <= (others => '0');
          rx_led <= '0';
          tx_led <= '0';
        else
          if led_counter(18) = '1' then
            led_counter <= (others => '0');
          else
            led_counter <= led_counter + 1;
          end if;
          if reg_MED_CARRIER_IN = '1' then
            rx_led <= '1';
          elsif led_counter(18) = '1' then
            rx_led <= '0';
          end if;
          if next_MED_CARRIER_OUT = '1' then
            tx_led <= '1';
          elsif led_counter(18) = '1' then
            tx_led <= '0';
          end if;
        end if;
      end if;
    end process;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          send_resync <= '0';
          send_resync_counter <= (others => '0');
        else
          if not (send_resync_counter = 0) then
            send_resync_counter <= send_resync_counter + 1;
          end if;
          if CTRL_OP(15) = '1' and send_resync_counter(11 downto 4) = 0 then
            send_resync <= '1';
            send_resync_counter <= send_resync_counter + 1;
          end if;
          if send_resync_counter = x"00F" then
            send_resync <= '0';
          end if;
        end if;
      end if;
    end process;

  --TODO:
  --------------------------------
  fatal_error <= '0';

  --My error bits
  --------------------------------
  reg_my_error:  process(CLK,RESET)
    begin
      if rising_edge(CLK) then
        if RESET = '1' or media_not_connected = '1' or MED_DATA_IN(11) = '0' then
          my_error <= ERROR_NC;
        elsif fatal_error = '1' or (INT_READ_IN = '0' and buf_INT_DATAREADY_OUT = '1') then
          my_error <= ERROR_FATAL;
        else
          my_error <= ERROR_OK;
        end if;
      end if;
    end process;


  --Transmission clock generator
  --------------------------------
  trans_clk_counter: process (transmission_clk_Counter, buf_MED_TRANSMISSION_CLK_OUT)
    begin
      if transmission_clk_Counter = (TRANSMISSION_CLOCK_DIVIDER/2) - 1 then
        next_transmission_clk_Counter <= (others => '0');
        next_TRANSMISSION_CLK <= not buf_MED_TRANSMISSION_CLK_OUT;
       else
        next_transmission_clk_Counter <= transmission_clk_Counter + 1;
        next_TRANSMISSION_CLK <= buf_MED_TRANSMISSION_CLK_OUT;
      end if;
    end process;


  trans_clk_counter_reg: process (CLK,RESET)
    begin
      if RESET = '1' then
        transmission_clk_Counter <= (others => '0');
        buf_MED_TRANSMISSION_CLK_OUT <= '0';
      elsif rising_edge(CLK) then
        transmission_clk_Counter <= next_transmission_clk_Counter;
        buf_MED_TRANSMISSION_CLK_OUT <= next_TRANSMISSION_CLK;
      else
        transmission_clk_Counter <= transmission_clk_Counter;
        buf_MED_TRANSMISSION_CLK_OUT <= buf_MED_TRANSMISSION_CLK_OUT;
      end if;
    end process;



  --Transmission Clock detection
  --------------------------------
  trans_clk_reg: process (RESET,CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1'  then
          last_TRCLK <= '0';
          this_TRCLK <= '0';
          CLK_counter <= (others => '0');
          media_not_connected <= '0';
        else
          last_TRCLK <= this_TRCLK;
          this_TRCLK <= reg_MED_TRANSMISSION_CLK_IN;
          CLK_counter <= next_CLK_counter;
          media_not_connected <= next_media_not_connected;
        end if;
      end if;
    end process;



  transCLK_counter: process (this_TRCLK, last_TRCLK, CLK_counter,
                             buf_MED_DATA_OUT, buf_MED_CARRIER_OUT,
                             buf_MED_PARITY_OUT)
    begin
      next_media_not_connected <= '0';
      if RESET = '1' then
        next_CLK_counter <= x"1F";
      elsif last_TRCLK = '0' and this_TRCLK = '1' then
        next_CLK_counter <= (others => '0');
      elsif CLK_counter = 31 then
        next_media_not_connected <= '1';
        next_CLK_counter <= CLK_counter;
      else
        next_CLK_counter <= CLK_counter + 1;
      end if;
    end process;




  --INT to MED direction
  --------------------------------
  INT2MED_fsm: process(buf_MED_DATA_OUT, buf_MED_CARRIER_OUT, buf_MED_PARITY_OUT, buf_INT_DATA_IN,
                       transmission_running, buf_MED_FIRST_PACKET_OUT, next_TRANSMISSION_CLK,
                       buf_MED_TRANSMISSION_CLK_OUT, INT_DATAREADY_IN, INT_DATA_IN,
                       buf_INT_READ_OUT, INT_PACKET_NUM_IN)
  begin
      next_buf_MED_DATA_OUT <= buf_MED_DATA_OUT;
      next_MED_CARRIER_OUT <= buf_MED_CARRIER_OUT;
      next_MED_PARITY_OUT <= buf_MED_PARITY_OUT;
      next_buf_INT_DATA_IN <= buf_INT_DATA_IN;
      next_transmission_running <= transmission_running;
      next_MED_FIRST_PACKET_OUT <= buf_MED_FIRST_PACKET_OUT;
      buf_INT_READ_OUT <= '0';
      if next_TRANSMISSION_CLK = '0' and buf_MED_TRANSMISSION_CLK_OUT = '1' and transmission_running = '0' then
        next_MED_CARRIER_OUT <= '0';
      end if;
      if(INT_DATAREADY_IN = '1' and transmission_running = '0') then
        if next_TRANSMISSION_CLK = '0' and buf_MED_TRANSMISSION_CLK_OUT = '1' then
          next_buf_MED_DATA_OUT <= INT_DATA_IN(15 downto 8);
          next_buf_INT_DATA_IN  <= INT_DATA_IN(7 downto 0);
          next_MED_CARRIER_OUT <= '1';
          next_MED_PARITY_OUT <= xor_all(INT_DATA_IN(15 downto 8));
          next_transmission_running <= '1';
          buf_INT_READ_OUT <= '1';
          if INT_PACKET_NUM_IN = c_H0 then
            next_MED_FIRST_PACKET_OUT <= '1';
          else
            next_MED_FIRST_PACKET_OUT <= '0';
          end if;
        end if;
      elsif transmission_running = '1' then
        if next_TRANSMISSION_CLK = '0' and buf_MED_TRANSMISSION_CLK_OUT = '1' then
          next_buf_MED_DATA_OUT <= buf_INT_DATA_IN;
          next_MED_PARITY_OUT <= xor_all(buf_INT_DATA_IN);
          next_transmission_running <= '0';
        end if;
      end if;
      if send_resync = '1' then
        next_MED_CARRIER_OUT <= '1';
      end if;
  end process;


  INT2MED_fsm_reg: process(CLK,RESET)
    begin
      if rising_edge(CLK) then
        if RESET='1' then
          buf_MED_DATA_OUT <= (others => '0');
          buf_INT_DATA_IN <= (others => '0');
          buf_MED_CARRIER_OUT <= '0';
          buf_MED_PARITY_OUT <= '0';
          buf_MED_FIRST_PACKET_OUT <= '0';
          transmission_running <= '0';
        else
          buf_INT_DATA_IN  <= next_buf_INT_DATA_IN;
          buf_MED_DATA_OUT <= next_buf_MED_DATA_OUT;
          buf_MED_FIRST_PACKET_OUT <= next_MED_FIRST_PACKET_OUT;
          buf_MED_CARRIER_OUT <= next_MED_CARRIER_OUT;
          buf_MED_PARITY_OUT <= next_MED_PARITY_OUT;
          transmission_running <= next_transmission_running;
        end if;
      end if;
    end process;















  --MED to INT direction
  --------------------------------
    process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            recv_counter <= "0111";
          elsif reg_MED_CARRIER_IN = '1' and last_MED_TRANSMISSION_CLK_IN = '0' and reg_MED_TRANSMISSION_CLK_IN = '1' then
            if recv_counter = "1001" then
              recv_counter <= "0000";
            else
              recv_counter <= recv_counter + 1;
            end if;
            last_MED_FIRST_PACKET_IN <= reg_MED_FIRST_PACKET_IN;
            if reg_MED_FIRST_PACKET_IN = '1' and last_MED_FIRST_PACKET_IN = '0' then
              recv_counter <= "1000";
            end if;
          end if;
        end if;
      end process;



  MED2INT_fsm: process(buf_INT_DATA_OUT, buf_INT_DATAREADY_OUT, buf_MED_DATA_IN, last_MED_TRANSMISSION_CLK_IN,
                       reg_MED_TRANSMISSION_CLK_IN, reg_MED_DATA_IN, recv_counter, INT_READ_IN, reg_MED_CARRIER_IN,
                       buf_INT_PACKET_NUM_OUT, reg_MED_FIRST_PACKET_IN, last_MED_FIRST_PACKET_IN)
    begin
      next_INT_DATA_OUT <= buf_INT_DATA_OUT;
      next_INT_DATAREADY_OUT <= '0'; --buf_INT_DATAREADY_OUT;
      next_buf_MED_DATA_IN <= buf_MED_DATA_IN;
      next_INT_PACKET_NUM_OUT <= buf_INT_PACKET_NUM_OUT;

--       if buf_INT_DATAREADY_OUT = '1' and INT_READ_IN = '1' then
--         next_INT_DATAREADY_OUT <= '0';
--       end if;

      if reg_MED_CARRIER_IN = '1' and last_MED_TRANSMISSION_CLK_IN = '0' and reg_MED_TRANSMISSION_CLK_IN = '1' then
        if recv_counter(0) = '1' or (reg_MED_FIRST_PACKET_IN = '1' and last_MED_FIRST_PACKET_IN = '0') then
          next_buf_MED_DATA_IN <= reg_MED_DATA_IN(7 downto 0);
        else
          next_INT_DATA_OUT(7 downto 0)  <= reg_MED_DATA_IN(7 downto 0);
          next_INT_DATA_OUT(15 downto 8) <= buf_MED_DATA_IN;
          next_INT_PACKET_NUM_OUT        <= recv_counter(3 downto 1);
          next_INT_DATAREADY_OUT         <= '1';
        end if;
      end if;
    end process;


  MED2INT_fsm_reg: process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET='1' then
          buf_INT_DATAREADY_OUT <= '0';
          last_MED_TRANSMISSION_CLK_IN <= '1';
        else
          buf_INT_DATA_OUT <= next_INT_DATA_OUT;
          buf_INT_DATAREADY_OUT <= next_INT_DATAREADY_OUT;
          last_MED_TRANSMISSION_CLK_IN <= reg_MED_TRANSMISSION_CLK_IN;
          buf_MED_DATA_IN <= next_buf_MED_DATA_IN;
          buf_INT_PACKET_NUM_OUT <= next_INT_PACKET_NUM_OUT;
        end if;
      end if;
    end process;

  LVDS_IN_reg: process(CLK)
    begin
      if rising_edge(CLK) then
        reg_MED_TRANSMISSION_CLK_IN <= MED_DATA_IN(13);
        reg_MED_CARRIER_IN <= MED_DATA_IN(14);
        reg_MED_PARITY_IN <= MED_DATA_IN(15);
        reg_MED_DATA_IN <= MED_DATA_IN(11 downto 0);
        reg_MED_FIRST_PACKET_IN <= MED_DATA_IN(12);
      end if;
    end process;

end architecture;

