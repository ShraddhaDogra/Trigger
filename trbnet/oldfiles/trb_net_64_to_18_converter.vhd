--this is a converter from 64/55 Bit to 18 Bit format.
--It's just a quick hack and should not be used in the final network
--for example, no packet number check is implemented and one cycle is wasted


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.trb_net_std.all;

--Entity decalaration for clock generator
entity trb_net_64_to_18_converter is
  port(
    --  Misc
    CLK    : in std_logic;      
    RESET  : in std_logic;    
    CLK_EN : in std_logic;

    D55_DATA_IN        : in std_logic_vector(50 downto 0);
    D55_DATAREADY_IN   : in std_logic;
    D55_READ_OUT       : out std_logic;

    D18_DATA_OUT       : out std_logic_vector(15 downto 0);
    D18_PACKET_NUM_OUT : out std_logic_vector(1 downto 0);
    D18_DATAREADY_OUT  : out std_logic;
    D18_READ_IN        : in std_logic;

    D55_DATA_OUT       : out std_logic_vector(50 downto 0);
    D55_DATAREADY_OUT  : out std_logic;
    D55_READ_IN        : in std_logic;

    D18_DATA_IN       : in std_logic_vector(15 downto 0);
    D18_PACKET_NUM_IN : in std_logic_vector(1 downto 0);
    D18_DATAREADY_IN  : in std_logic;
    D18_READ_OUT      : out std_logic
   );
end entity;


architecture trb_net_64_to_18_converter_arch of trb_net_64_to_18_converter is



type CONV_STATE is (IDLE, FIRST, SECOND, THIRD, LAST);
signal D55to18_state, next_D55to18_state : CONV_STATE;
signal D18to55_state, next_D18to55_state : CONV_STATE;

signal next_D55_READ_OUT, buf_D55_READ_OUT : std_logic;
signal next_D18_DATAREADY_OUT, buf_D18_DATAREADY_OUT : std_logic;
signal next_D18_PACKET_NUM_OUT, buf_D18_PACKET_NUM_OUT : std_logic_vector(1 downto 0);
signal next_D18_DATA_OUT, buf_D18_DATA_OUT : std_logic_vector(15 downto 0);


signal next_D18_READ_OUT, buf_D18_READ_OUT : std_logic;
signal next_D55_DATAREADY_OUT, buf_D55_DATAREADY_OUT : std_logic;
signal next_dataread55, dataread55 : std_logic;
                                                  --data from 55 read and waiting to be written

signal next_buf_D55_DATA_IN, buf_D55_DATA_IN : std_logic_vector(50 downto 0);
signal next_D55_DATA_OUT, buf_D55_DATA_OUT : std_logic_vector(50 downto 0);
                                                  --databuffer for both directions
begin
-----------------------------------------------------------
--Direction 18 to 55
-----------------------------------------------------------

  D18to55_fsm : process(D55_READ_IN, buf_D55_DATAREADY_OUT, buf_D18_READ_OUT, D18_DATAREADY_IN,
                        D18to55_state, buf_D55_DATA_OUT, D18_DATA_IN)
    variable dataisread18, dataisread55 : std_logic;
    begin
      next_D55_DATA_OUT <= buf_D55_DATA_OUT;
      next_D18to55_state <= D18to55_state;
      next_D18_READ_OUT <= '1';
      next_D55_DATAREADY_OUT <= '0';

      dataisread55 := D55_READ_IN AND buf_D55_DATAREADY_OUT;
      dataisread18 := buf_D18_READ_OUT AND D18_DATAREADY_IN;


      case D18to55_state is
        when IDLE =>
          if(dataisread18 = '1') then
            next_D55_DATA_OUT(50 downto 48) <= D18_DATA_IN(2 downto 0);
            next_D18to55_state <= FIRST;
          end if;
        when FIRST =>
          if(dataisread18 = '1') then
            next_D55_DATA_OUT(47 downto 32) <= D18_DATA_IN;
            next_D18to55_state <= SECOND;
          end if;
        when SECOND =>
          if(dataisread18 = '1') then
            next_D55_DATA_OUT(31 downto 16) <= D18_DATA_IN;
            next_D18to55_state <= THIRD;
          end if;
        when THIRD =>
          if(dataisread18 = '1') then
            next_D55_DATA_OUT(15 downto 0) <= D18_DATA_IN;
            next_D55_DATAREADY_OUT <= '1';
            next_D18to55_state <= LAST;
            next_D18_READ_OUT <= '0';
          end if;
        when LAST =>
          if(dataisread55 = '1') then
            next_D55_DATA_OUT <= (others => '0');
            next_D55_DATAREADY_OUT <= '0';
            next_D18to55_state <= IDLE;
          else
            next_D18_READ_OUT <= '0';
            next_D55_DATAREADY_OUT <= '1';
          end if;
      end case;
    end process;
    
  D18to55_fsm_reg : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          buf_D55_DATA_OUT      <= (others => '0');
          D18to55_state         <= IDLE;
          buf_D55_DATAREADY_OUT <= '0';
          buf_D18_READ_OUT      <= '0';
        else
          buf_D55_DATA_OUT      <= next_D55_DATA_OUT;
          D18to55_state         <= next_D18to55_state;
          buf_D55_DATAREADY_OUT <= next_D55_DATAREADY_OUT;
          buf_D18_READ_OUT      <= next_D18_READ_OUT;
        end if;
      end if;
    end process;
    
D55_DATA_OUT <= buf_D55_DATA_OUT;
D55_DATAREADY_OUT <= buf_D55_DATAREADY_OUT;
D18_READ_OUT <= buf_D18_READ_OUT;

-----------------------------------------------------------
--Direction 55 to 18
-----------------------------------------------------------
  D55to18_fsm : process(buf_D18_DATA_OUT, buf_D18_PACKET_NUM_OUT, buf_D18_DATAREADY_OUT,
                        D18_READ_IN, D55_DATA_IN, D55_DATAREADY_IN, D55to18_state, 
                        buf_D55_READ_OUT, buf_D55_DATA_IN, dataread55)
    variable dataisread18, dataisread55 : std_logic;
    begin
      next_D18_DATA_OUT <= buf_D18_DATA_OUT;
      next_D18_PACKET_NUM_OUT <= buf_D18_PACKET_NUM_OUT;
      next_D55to18_state <= D55to18_state;
      next_D55_READ_OUT <= '0';
      next_buf_D55_DATA_IN <= buf_D55_DATA_IN;

      dataisread18 := D18_READ_IN AND buf_D18_DATAREADY_OUT;
      dataisread55 := D55_DATAREADY_IN AND buf_D55_READ_OUT;
      
      if(dataisread18 = '1') then
        next_D18_DATAREADY_OUT <= '0';
      else
        next_D18_DATAREADY_OUT <= buf_D18_DATAREADY_OUT;
      end if;


      case D55to18_state is
        when IDLE =>
          if (dataisread18 = '1' OR buf_D18_DATAREADY_OUT = '0') then
            next_D55_READ_OUT <= '1';
            if dataisread55 = '1' then 
              next_buf_D55_DATA_IN(50 downto 0) <= D55_DATA_IN(50 downto 0);
              next_D55_READ_OUT <= '0';
              next_D18_DATA_OUT(2 downto 0) <= D55_DATA_IN(50 downto 48);
              next_D18_DATA_OUT(15 downto 3) <= (others => '0');
              next_D18_PACKET_NUM_OUT <= "00";
              next_D18_DATAREADY_OUT <= '1';
              next_D55to18_state <= FIRST;
            end if;
          end if;
        when FIRST =>
          if(dataisread18 = '1') then
            next_D18_DATA_OUT(15 downto 0) <= buf_D55_DATA_IN(47 downto 32);
            next_D18_DATAREADY_OUT <= '1';
            next_D18_PACKET_NUM_OUT <= "01";
            next_D55to18_state <= SECOND;
          end if;
        when SECOND =>
          if(dataisread18 = '1') then
            next_D18_DATA_OUT(15 downto 0) <= buf_D55_DATA_IN(31 downto 16);
            next_D18_DATAREADY_OUT <= '1';
            next_D18_PACKET_NUM_OUT <= "10";
            next_D55to18_state <= THIRD;
          end if;
        when THIRD =>
          if(dataisread18 = '1') then
            next_D18_DATA_OUT(15 downto 0) <= buf_D55_DATA_IN(15 downto 0);
            next_D18_DATAREADY_OUT <= '1';
            next_D18_PACKET_NUM_OUT <= "11";
            next_D55to18_state <= IDLE;
            next_D55_READ_OUT <= '1';
          end if;
        when others =>
            next_D55to18_state <= IDLE;
      end case;
    end process;

  D55to18_fsm_reg : process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          buf_D18_DATA_OUT <= (others => '0');
          buf_D55_DATA_IN <= (others => '0');
          buf_D55_READ_OUT <= '0';
          buf_D18_DATAREADY_OUT <= '0';
          buf_D18_PACKET_NUM_OUT <= "00";
          D55to18_state <= IDLE;
        else
          buf_D18_DATA_OUT <= next_D18_DATA_OUT;
          buf_D18_DATAREADY_OUT <= next_D18_DATAREADY_OUT;
          buf_D55_READ_OUT <= next_D55_READ_OUT;
          buf_D55_DATA_IN <= next_buf_D55_DATA_IN;
          buf_D18_PACKET_NUM_OUT <= next_D18_PACKET_NUM_OUT;
          D55to18_state <= next_D55to18_state;
        end if;
      end if;
    end process;

D18_DATA_OUT <= buf_D18_DATA_OUT;
D18_DATAREADY_OUT <= buf_D18_DATAREADY_OUT;
D18_PACKET_NUM_OUT <= buf_D18_PACKET_NUM_OUT;
D55_READ_OUT <= buf_D55_READ_OUT;


end architecture;