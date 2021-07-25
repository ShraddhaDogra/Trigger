LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
library work;
use work.trb_net_std.all;

entity trb_net16_obuf_nodata is
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    --  Media direction port
    MED_DATAREADY_OUT  : out std_logic;
    MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1  downto 0);
    MED_READ_IN        : in  std_logic;
    --STAT
    STAT_BUFFER       : out std_logic_vector (31 downto 0);
    CTRL_BUFFER       : in  std_logic_vector (31 downto 0);
    STAT_DEBUG        : out std_logic_vector (31 downto 0)
    );
end entity;



architecture trb_net16_obuf_nodata_arch of trb_net16_obuf_nodata is

  signal SEND_BUFFER_SIZE_IN : std_logic_vector(3 downto 0);
  signal SEND_ACK_IN         : std_logic;
--  signal transfer_counter    : std_logic_vector(c_NUM_WIDTH-1  downto 0);

  signal buf_MED_DATAREADY_OUT                         : std_logic;
  signal buf_MED_DATA_OUT                              : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal buf_MED_PACKET_NUM_OUT                        : std_logic_vector(c_NUM_WIDTH-1 downto 0);
  signal reg_SEND_ACK_IN_2                             : std_logic;
  signal reg_SEND_ACK_IN                               : std_logic;

  attribute syn_keep : boolean;
  attribute syn_keep of buf_MED_DATAREADY_OUT : signal is true;
  attribute syn_sharing : string;
  attribute syn_sharing of trb_net16_obuf_nodata_arch : architecture is "off";

  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  --attribute HGROUP of trb_net16_obuf_nodata_arch : architecture  is "OBUF_group";

begin
  SEND_BUFFER_SIZE_IN       <= CTRL_BUFFER(3 downto 0);
  SEND_ACK_IN               <= CTRL_BUFFER(8);


  MED_DATAREADY_OUT <= buf_MED_DATAREADY_OUT;
  MED_PACKET_NUM_OUT <= buf_MED_PACKET_NUM_OUT;
  MED_DATA_OUT <= buf_MED_DATA_OUT;

  process(CLK)
    variable transfer_counter : std_logic_vector(2 downto 0);
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          buf_MED_DATAREADY_OUT <= '0';
          reg_SEND_ACK_IN_2 <= '0';
          reg_SEND_ACK_IN <= '0';
          buf_MED_PACKET_NUM_OUT <= c_H0;
          transfer_counter := c_H0;
        elsif CLK_EN = '1' then



          if MED_READ_IN = '1' and reg_SEND_ACK_IN = '1' then
            if transfer_counter = c_max_word_number then
              transfer_counter := "000";
            else
              transfer_counter := transfer_counter + 1;
            end if;
          end if;

          buf_MED_DATA_OUT <= (others => '0');
          if transfer_counter = c_F1 then
            buf_MED_DATA_OUT(3 downto 0) <= SEND_BUFFER_SIZE_IN;
          elsif transfer_counter = c_H0 then
            buf_MED_DATA_OUT(2 downto 0) <= TYPE_ACK;
          end if;

          buf_MED_DATAREADY_OUT <= '0';
          if (SEND_ACK_IN or reg_SEND_ACK_IN or reg_SEND_ACK_IN_2) = '1' then
            buf_MED_DATAREADY_OUT <= '1';
          end if;

--           if transfer_counter = c_F3 and MED_READ_IN = '1' then
--             reg_SEND_ACK_IN <= '0';
--           end if;
          if buf_MED_PACKET_NUM_OUT = c_F3 and MED_READ_IN = '1' then
            transfer_counter := c_H0;
            buf_MED_DATA_OUT(2 downto 0) <= TYPE_ACK;
            buf_MED_DATAREADY_OUT <= SEND_ACK_IN or reg_SEND_ACK_IN_2;
          end if;

          buf_MED_PACKET_NUM_OUT <= transfer_counter;

          if buf_MED_PACKET_NUM_OUT = c_F3 and MED_READ_IN = '1' then
            reg_SEND_ACK_IN   <= reg_SEND_ACK_IN_2 or SEND_ACK_IN;
            reg_SEND_ACK_IN_2 <= reg_SEND_ACK_IN_2 and SEND_ACK_IN;
          else
            reg_SEND_ACK_IN   <= reg_SEND_ACK_IN or SEND_ACK_IN or reg_SEND_ACK_IN_2;
            reg_SEND_ACK_IN_2 <= (reg_SEND_ACK_IN_2 or SEND_ACK_IN) and reg_SEND_ACK_IN;
          end if;
        end if;
      end if;
    end process;

--     send_ACK     <= SEND_ACK_IN or reg_SEND_ACK_IN or reg_SEND_ACK_IN_2;
--     next_SEND_ACK_IN_2 <= (reg_SEND_ACK_IN_2 or SEND_ACK_IN) and reg_SEND_ACK_IN;


  STAT_BUFFER <= (others => '0');

  STAT_DEBUG(0) <= SEND_ACK_IN;
  STAT_DEBUG(1) <= reg_SEND_ACK_IN;
  STAT_DEBUG(2) <= buf_MED_DATAREADY_OUT;
  STAT_DEBUG(5 downto 3) <= buf_MED_PACKET_NUM_OUT;
  STAT_DEBUG(6) <= MED_READ_IN;
  STAT_DEBUG(31 downto 7) <= (others => '0');

end architecture;
