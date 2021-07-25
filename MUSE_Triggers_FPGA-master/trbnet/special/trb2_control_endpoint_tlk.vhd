LIBRARY ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;




entity trb2_control is
  port(
    VIRT_CLK    : in  std_logic;
    RESET_VIRT  : in  std_logic;
    TLK_CLK     : in  std_logic;
    TLK_ENABLE  : out std_logic;
    TLK_LCKREFN : out std_logic;
    TLK_LOOPEN  : out std_logic;
    TLK_PRBSEN  : out std_logic;
    TLK_RXD     : in  std_logic_vector(15 downto 0);
    TLK_RX_CLK  : in  std_logic;
    TLK_RX_DV   : in  std_logic;
    TLK_RX_ER   : in  std_logic;
    TLK_TXD     : out std_logic_vector(15 downto 0);
    TLK_TX_EN   : out std_logic;
    TLK_TX_ER   : out std_logic;
    SFP_LOS     : in  std_logic;
    SFP_TX_DIS  : out std_logic;
    FS_PB       : out std_logic_vector(17 downto 0);
    FS_PC       : inout std_logic_vector(17 downto 0);
    ETRAX_IRQ   : out std_logic;
    DBAD        : out std_logic;
    DGOOD       : out std_logic;
    DINT        : out std_logic;
    DWAIT       : out std_logic;
    ADO_TTL     : inout std_logic_vector(46 downto 0)
    );
end entity;


architecture trb2_control_arch of trb2_control is

component trb_net_bridge_etrax_endpoint is
  generic(
    USE_CHANNELS : channel_config_t := (c_YES,c_YES,c_NO,c_YES);
    AUTO_ANSWER_INCOMING_REQUESTS : channel_config_t := (c_YES,c_YES,c_YES,c_YES)
    );
  port(
    RESET :   in std_logic;
    CLK:      in std_logic;

    CPU_READ:       in STD_LOGIC;   -- Read strobe
    CPU_WRITE:       in STD_LOGIC;   -- Write strobe
    CPU_DATA_OUT: out STD_LOGIC_VECTOR (31 downto 0) ; -- I/O Bus
    CPU_DATA_IN : in  STD_LOGIC_VECTOR (31 downto 0) ; -- I/O Bus
    CPU_DATAREADY_OUT : out std_logic;
    CPU_ADDRESS:  in STD_LOGIC_VECTOR (15 downto 0);  -- Adress lines for the given space

    MED_DATAREADY_IN   : in  STD_LOGIC;
    MED_DATA_IN        : in  STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN  : in  STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT       : out STD_LOGIC;

    MED_DATAREADY_OUT  : out STD_LOGIC;
    MED_DATA_OUT       : out STD_LOGIC_VECTOR (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out STD_LOGIC_VECTOR (c_NUM_WIDTH-1 downto 0);
    MED_READ_IN        : in  STD_LOGIC;

    MED_ERROR_IN       : in std_logic_vector(2 downto 0);
    STAT               : out std_logic_vector(31 downto 0);
    STAT_ENDP          : out std_logic_vector(31 downto 0);
    STAT_API1          : out std_logic_vector(31 downto 0)
    );
end component;


  signal CLK    : std_logic;
  signal RESET  : std_logic;
  signal CLK_EN : std_logic;
  signal counter: std_logic_vector(15 downto 0);

  signal TLK_STAT : std_logic_vector(63 downto 0);
  signal TLK_STAT_MONITOR : std_logic_vector(100 downto 0);

  signal MED_DATAREADY_IN, MED_DATAREADY_OUT  : std_logic;
  signal MED_DATA_IN, MED_DATA_OUT            : std_logic_vector(c_DATA_WIDTH-1 downto 0);
  signal MED_PACKET_NUM_IN, MED_PACKET_NUM_OUT: std_logic_vector(2 downto 0);
  signal MED_ERROR_IN                         : std_logic_vector(2 downto 0);
  signal MED_READ_IN, MED_READ_OUT            : std_logic;


  signal buf_ADO_TTL : std_logic_vector(46 downto 0);
  signal tmp : std_logic;
  signal API_STAT_FIFO_TO_INT : std_logic_vector(31 downto 0);
  signal RESET_CNT  : std_logic_vector(1 downto 0);

  signal TEMP_OUT : std_logic_vector(11 downto 0);

  signal etrax_state : std_logic_vector(2 downto 0);
  signal etrax_data_in, etrax_data_out : std_logic_vector(31 downto 0);
  signal etrax_read : std_logic;
  signal etrax_write : std_logic;
  signal etrax_dataready : std_logic;
  signal etrax_address : std_logic_vector(15 downto 0);
  signal STAT_REGS : std_logic_vector(63 downto 0);
  signal CTRL_REGS : std_logic_vector(31 downto 0);
  signal APL_STAT : std_logic_vector(31 downto 0);
  signal STAT_ENDP : std_logic_vector(31 downto 0);
  signal STAT_API1 : std_logic_vector(31 downto 0);
  signal MED_STAT_OP : std_logic_vector(15 downto 0);
  signal MED_CTRL_OP : std_logic_vector(15 downto 0);
  signal EI_STAT   : std_logic_vector(15 downto 0);
  signal last_CTRL_REGS : std_logic_vector(15 downto 14);

  signal send_reset_counter : std_logic_vector(11 downto 0) := x"FFF";
  signal reset_interface : std_logic;
  signal reset_interface_counter : std_logic_vector(31 downto 0);

begin
  CLK <= VIRT_CLK;

  CLK_EN <= '1';
  ETRAX_IRQ <= '1';

---------------------------------------------------------------------
--Reset
---------------------------------------------------------------------

  process(CLK)
    begin
       if rising_edge(CLK) then
         if RESET_VIRT = '0' or send_reset_counter(10 downto 0) = "01111111111" or MED_STAT_OP(13) = '1' then --added trbnet reset
           RESET <= '1';
           RESET_CNT <= "00";
         else
           RESET_CNT <= RESET_CNT + 1;
           RESET <= '1';
           if RESET_CNT = "11" then
             counter <= counter + 1;
             RESET <= '0';
             RESET_CNT <= "11";
           end if;
         end if;
       end if;
    end process;


---------------------------------------------------------------------
--LED outputs
---------------------------------------------------------------------
  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          tmp <= '0';
        else
          tmp <= (not TLK_STAT(7)) or tmp;
        end if;
      end if;
    end process;

    DGOOD       <= not MED_STAT_OP(9);

    DBAD        <= not (TLK_STAT(36)); -- no error, but not ERROR_OK
    DINT        <= not (tmp ); --RX_ER and RX_DV;
    DWAIT       <= not (MED_STAT_OP(10) or MED_STAT_OP(11));

---------------------------------------------------------------------
--Media Interface: Optical Link
---------------------------------------------------------------------

  THE_TLK : trb_net16_med_tlk
    port map(
      RESET               => RESET,
      CLK                 => CLK,
      TLK_CLK             => TLK_CLK,
      TLK_ENABLE          => TLK_ENABLE,
      TLK_LCKREFN         => TLK_LCKREFN,
      TLK_LOOPEN          => TLK_LOOPEN,
      TLK_PRBSEN          => TLK_PRBSEN,
      TLK_RXD             => TLK_RXD,
      TLK_RX_CLK          => TLK_RX_CLK,
      TLK_RX_DV           => TLK_RX_DV,
      TLK_RX_ER           => TLK_RX_ER,
      TLK_TXD             => TLK_TXD,
      TLK_TX_EN           => TLK_TX_EN,
      TLK_TX_ER           => TLK_TX_ER,
      SFP_LOS             => SFP_LOS,
      SFP_TX_DIS          => SFP_TX_DIS,
      MED_DATAREADY_IN    => MED_DATAREADY_OUT,
      MED_READ_IN         => MED_READ_OUT,
      MED_DATA_IN         => MED_DATA_OUT,
      MED_PACKET_NUM_IN   => MED_PACKET_NUM_OUT,
      MED_DATAREADY_OUT   => MED_DATAREADY_IN,
      MED_READ_OUT        => MED_READ_IN,
      MED_DATA_OUT        => MED_DATA_IN,
      MED_PACKET_NUM_OUT  => MED_PACKET_NUM_IN,
      STAT                => TLK_STAT,
      STAT_MONITOR        => TLK_STAT_MONITOR,
      STAT_OP             => MED_STAT_OP,
      CTRL_OP             => MED_CTRL_OP
      );

  MED_CTRL_OP  <= (15 => not send_reset_counter(10), others => '0');
  MED_ERROR_IN <= MED_STAT_OP(2 downto 0);

  process(CLK)
    begin
      if rising_edge(CLK) then
        last_CTRL_REGS(15 downto 14) <= CTRL_REGS(15 downto 14);
        if RESET = '1' then
          send_reset_counter <= (others => '1');
        elsif CTRL_REGS(15) = '1' and last_CTRL_REGS(15) = '0' then
          send_reset_counter <= (others => '0');
        elsif send_reset_counter(10) = '0' then
          send_reset_counter <= send_reset_counter + 1;
        end if;
      end if;
    end process;


  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' or MED_ERROR_IN /= ERROR_OK then
          reset_interface <= '1';
          reset_interface_counter <= (others => '0');
        elsif reset_interface_counter = x"00FFFFFF" then
          reset_interface <= '0';
        else
          reset_interface_counter <= reset_interface_counter + 1;
        end if;
      end if;
    end process;

---------------------------------------------------------------------
--The Endpoint generating the connection to etrax-read/write/able registers
---------------------------------------------------------------------

  the_bridge: trb_net_bridge_etrax_endpoint
    generic map(
      USE_CHANNELS => (c_YES, c_YES, c_NO, c_YES),
      AUTO_ANSWER_INCOMING_REQUESTS => (c_NO,c_NO,c_NO,c_NO)
      )
    port map(
      RESET   => RESET,
      CLK     => CLK,

      CPU_READ         => etrax_read,
      CPU_WRITE        => etrax_write,
      CPU_DATA_OUT     => etrax_data_out,
      CPU_DATA_IN      => etrax_data_in,
      CPU_DATAREADY_OUT=> etrax_dataready,
      CPU_ADDRESS      => etrax_address,

      MED_DATAREADY_IN => MED_DATAREADY_IN,
      MED_DATA_IN      => MED_DATA_IN,
      MED_PACKET_NUM_IN=> MED_PACKET_NUM_IN,
      MED_READ_OUT     => MED_READ_OUT,

      MED_DATAREADY_OUT  => MED_DATAREADY_OUT,
      MED_DATA_OUT       => MED_DATA_OUT,
      MED_PACKET_NUM_OUT => MED_PACKET_NUM_OUT,
      MED_READ_IN        => MED_READ_IN,

      MED_ERROR_IN       => MED_ERROR_IN,
      STAT               => APL_STAT,
      STAT_ENDP          => STAT_ENDP,
      STAT_API1          => STAT_API1
      );


---------------------------------------------------------------------
--Interface to Etrax (trbcmd-compatible)
---------------------------------------------------------------------
   THE_ETRAX_INTERFACE_LOGIC : etrax_interface
     generic map(
       STATUS_REGISTERS => 2,
       CONTROL_REGISTERS => 1
       )
     port map (
       CLK                     => CLK,
       RESET                   => reset_interface,
       ETRAX_DATA_BUS_B        => FS_PB,
       ETRAX_DATA_BUS_C        => FS_PC,
       ETRAX_BUS_BUSY          => etrax_state(0),
       INTERNAL_DATA_OUT       => etrax_data_in,
       INTERNAL_DATA_IN        => etrax_data_out,
       INTERNAL_READ_OUT       => etrax_read,
       INTERNAL_WRITE_OUT      => etrax_write,
       INTERNAL_DATAREADY_IN   => etrax_dataready,
       INTERNAL_ADDRESS_OUT    => etrax_address,
       FPGA_REGISTER_IN        => STAT_REGS,
       FPGA_REGISTER_OUT       => CTRL_REGS,
       EXTERNAL_RESET          => etrax_state(2),
       STAT                    => EI_STAT
       );



---------------------------------------------------------------------
--Debugging Outputs
---------------------------------------------------------------------
  STAT_REGS(63 downto 0) <= APL_STAT & STAT_ENDP;

  buf_ADO_TTL(14 downto 0) <= EI_STAT(14 downto 0);
  --STAT_API1(14 downto 0); --TLK_STAT(15 downto 14) & "0" & TLK_STAT(27 downto 16);
--   buf_ADO_TTL(0) <= etrax_read;
--   buf_ADO_TTL(6 downto 1)   <= EI_STAT(5 downto 0);
--   buf_ADO_TTL(14 downto 7)  <= (others => 'Z');
  buf_ADO_TTL(46 downto 16) <= (others => 'Z');

  PROC_LA_CLK : process(CLK)
    begin
      if rising_edge(CLK) then
        buf_ADO_TTL(15) <= not buf_ADO_TTL(15);
      end if;
    end process;

-- D2D3: 31 downto 16
-- A0A1: 46 downto 32

 ADO_TTL(46 downto 0) <= (others => 'Z'); --buf_ADO_TTL(46 downto 0);

end architecture;
