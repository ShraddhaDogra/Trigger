LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb_net16_hub_func.all;
use work.lattice_ecp2m_fifo.all;

entity trb_net16_hub_logic is
  generic (
  --media interfaces
    POINT_NUMBER        : integer range 2 to 32 := 17;
    MII_IS_UPLINK_ONLY  : hub_mii_config_t := (others => c_NO)
    );
  port (
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;
    --Internal interfaccs to IOBufs
    INIT_DATAREADY_IN     : in  std_logic_vector (POINT_NUMBER-1 downto 0);
    INIT_DATA_IN          : in  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
    INIT_PACKET_NUM_IN    : in  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
    INIT_READ_OUT         : out std_logic_vector (POINT_NUMBER-1 downto 0)              := (others => '0');
    INIT_DATAREADY_OUT    : out std_logic_vector (POINT_NUMBER-1 downto 0)              := (others => '0');
    INIT_DATA_OUT         : out std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0) := (others => '0');
    INIT_PACKET_NUM_OUT   : out std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0)  := (others => '0');
    INIT_READ_IN          : in  std_logic_vector (POINT_NUMBER-1 downto 0);
    REPLY_DATAREADY_IN    : in  std_logic_vector (POINT_NUMBER-1 downto 0);
    REPLY_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
    REPLY_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
    REPLY_READ_OUT        : out std_logic_vector (POINT_NUMBER-1 downto 0)              := (others => '0');
    REPLY_DATAREADY_OUT   : out std_logic_vector (POINT_NUMBER-1 downto 0)              := (others => '0');
    REPLY_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0) := (others => '0');
    REPLY_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0)  := (others => '0');
    REPLY_READ_IN         : in  std_logic_vector (POINT_NUMBER-1 downto 0);
    --Status ports (for debugging)
    STAT               : out std_logic_vector (15 downto 0);
    STAT_locked        : out std_logic;
    STAT_POINTS_locked : out std_logic_vector (31 downto 0);
    STAT_TIMEOUT       : out std_logic_vector (31 downto 0);
    STAT_ERRORBITS     : out std_logic_vector (31 downto 0);
    STAT_ALL_ERRORBITS : out std_logic_vector (16*32-1 downto 0);
    CTRL_TIMEOUT_TIME  : in  std_logic_vector (15 downto 0);
    CTRL_activepoints  : in  std_logic_vector (31 downto 0) := (others => '1');
    CTRL_DISABLED_PORTS: in  std_logic_vector (31 downto 0) := (others => '0');
    CTRL_TIMER_TICK    : in  std_logic_vector (1 downto 0)
    );
end entity;

architecture trb_net16_hub_logic_arch of trb_net16_hub_logic is

  attribute HGROUP : string;
  attribute syn_keep : boolean;

  attribute HGROUP of trb_net16_hub_logic_arch : architecture  is "HUBLOGIC_group";

  signal config_wait_free_init_pool : unsigned(31 downto 0) := x"00010000"; --65ms
  signal config_wait_reply          : unsigned(31 downto 0) := x"00000400"; -- 1ms

  signal reset_i                 : std_logic;
  signal timer_ms_tick           : std_logic;
  signal timer_us_tick           : std_logic;
  signal timer_us_reset          : std_logic;

  type fsm_t is (IDLE, SELECT_INIT, FORWARD_INIT, SELECT_REPLY, WAIT_FOR_SELECT, FORWARD_REPLY, REPLY_TIMEOUT, 
                 SEND_TRM, FINISHED);
  signal currentstate                    : fsm_t;
  
  signal reply_dataready_in_i            : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0');
  signal reply_data_in_i                 : std_logic_vector(16*POINT_NUMBER-1 downto 0) := (others => '0');
  signal reply_packet_num_in_i           : std_logic_vector(3*POINT_NUMBER-1 downto 0)  := (others => '0');
  signal reply_read_out_i                : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0');

  signal reply_reading_trm               : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0');
  signal reply_got_trm                   : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0');
  signal TRM_packet                      : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0');
  signal is_uplink_only                  : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0');
  
  signal init_select_enable              : std_logic;
  signal reply_select_enable             : std_logic;
  signal reply_select_input              : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0');
  signal act_init_port                   : integer range 0 to POINT_NUMBER-1;
  signal act_reply_port                  : integer range 0 to POINT_NUMBER-1;
  signal act_init_mask                   : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0');
  signal act_reply_mask                  : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0');

--Init Pool
  signal init_pool_reading               : std_logic;
  signal init_pool_free                  : std_logic;
  signal init_pool_dataready_in          : std_logic;
  signal init_pool_data_in               : std_logic_vector(15 downto 0)                := (others => '0');
  signal init_pool_packet_num_in         : std_logic_vector(2 downto 0)                 := (others => '0');
  signal init_selected_dataready         : std_logic;
  signal init_selected_data              : std_logic_vector(15 downto 0)                := (others => '0');
  signal init_selected_packet_num        : std_logic_vector(2 downto 0)                 := (others => '0');
  signal init_current_type               : std_logic_vector(2 downto 0)                 := (others => '0');
  signal init_pool_data_out              : std_logic_vector(15 downto 0)                := (others => '0');
  signal init_pool_packet_num_out        : std_logic_vector(2 downto 0)                 := (others => '0');  
  signal init_pool_read_out              : std_logic;
  signal init_pool_dataready_out         : std_logic;
  signal init_read_out_i                 : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0'); 
  signal init_has_read_from_pool         : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0'); 
  signal init_pool_full                  : std_logic;
  signal init_pool_empty                 : std_logic;

  
--Reply Pool
  signal reply_selected_dataready        : std_logic;
  signal reply_selected_read             : std_logic;
  signal reply_selected_data             : std_logic_vector(15 downto 0)                := (others => '0');
  signal reply_selected_packet_num       : std_logic_vector(2 downto 0)                 := (others => '0');
  signal reply_pool_reading              : std_logic;
  signal reply_pool_free                 : std_logic;
  signal reply_pool_dataready_in         : std_logic;
  signal reply_pool_data_in              : std_logic_vector(15 downto 0)                := (others => '0');
  signal reply_pool_packet_num_in        : std_logic_vector(2 downto 0)                 := (others => '0');
  signal reply_pool_data_out             : std_logic_vector(15 downto 0)                := (others => '0');
  signal reply_pool_packet_num_out       : std_logic_vector(2 downto 0)                 := (others => '0');  
  signal reply_pool_read_out             : std_logic;
  signal reply_pool_dataready_out        : std_logic;  
  signal reply_pool_full                 : std_logic;
  signal reply_pool_empty                : std_logic;
  
--Control Signals 
  signal real_active_points              : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0'); 
  signal timer_us                        : unsigned(31 downto 0)                        := (others => '0'); 
  signal timeout_found                   : std_logic                                    := '0';
  
--Reply Pool output
  signal reply_mux_read_out_i            : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0');
  signal reply_open                      : std_logic;

  signal reading_trmF1                   : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0'); 
  signal reading_trmF2                   : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0'); 
  signal reading_trmF3                   : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0'); 
  signal REPLY_combined_trm_F1           : std_logic_vector(15 downto 0);
  signal REPLY_combined_trm_F2           : std_logic_vector(15 downto 0);
  signal REPLY_combined_trm_F3           : std_logic_vector(15 downto 0);
  signal send_trm_cnt                    : integer;

  type   arr4_t                          is array (0 to POINT_NUMBER-1) of unsigned(3 downto 0);
  signal timeout_cntr                    : arr4_t;
  signal timeout_disabled                : std_logic;
  signal timeout_ports                   : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0');
  signal timeout_ports_disable           : std_logic_vector(POINT_NUMBER-1 downto 0)    := (others => '0');
  attribute syn_keep of reset_i : signal is true;  
  
begin

----------------------------------
--Sync input Signals
----------------------------------

  reset_i       <= RESET              when rising_edge(CLK);
  timer_us_tick <= CTRL_TIMER_TICK(0) when rising_edge(CLK);
  timer_ms_tick <= CTRL_TIMER_TICK(1) when rising_edge(CLK);

  
  PROC_TIMER : process begin wait until rising_edge(CLK);
    if timer_us_reset = '1' then
      timer_us      <= (others => '0');
    elsif timer_us_tick = '1' then
      timer_us      <= timer_us + 1;
    end if;
  end process;
  
  config_wait_free_init_pool  <= x"00" & unsigned(CTRL_TIMEOUT_TIME) & x"00"; --mult. by 256/1024, e.q. 1/4 of given value
  config_wait_reply           <= x"00" & "00"  & unsigned(CTRL_TIMEOUT_TIME) & "000000"; --mult. by 64/1024, e.q. 1/16 of given value
  timeout_disabled            <= not or_all(CTRL_TIMEOUT_TIME);
 
 
  gen_uplink_mask : for i in 0 to POINT_NUMBER-1 generate
    is_uplink_only(i) <= '1' when MII_IS_UPLINK_ONLY(i) = c_YES else '0';
  end generate;
 
----------------------------------
--connect init input signals
----------------------------------  

  --choose from all init dataready the selected one
  init_selected_dataready    <= INIT_DATAREADY_IN(act_init_port);
  init_selected_data         <= INIT_DATA_IN(16*act_init_port+15 downto 16*act_init_port);
  init_selected_packet_num   <= INIT_PACKET_NUM_IN(3*act_init_port+2 downto 3*act_init_port);
  
  --only reading from active init port if pool reads
  INIT_READ_OUT              <= act_init_mask when init_pool_free = '1' and currentstate = FORWARD_INIT else (others => '0');
  
  THE_INIT_SELECT : priority_arbiter
    generic map(
      INPUT_WIDTH => POINT_NUMBER
      )
    port map(
      CLK         => CLK,
      ENABLE      => init_select_enable,
      INPUT       => INIT_DATAREADY_IN,
      OUTPUT_VEC  => act_init_mask,
      OUTPUT_NUM  => act_init_port
      );

      
  reply_select_input <= REPLY_DATAREADY_IN and not reply_reading_trm and not TRM_packet and not reply_got_trm;
  
  THE_REPLY_SELECT : priority_arbiter
    generic map(
      INPUT_WIDTH => POINT_NUMBER
      )
    port map(
      CLK         => CLK,
      ENABLE      => reply_select_enable,
      INPUT       => reply_select_input,
      OUTPUT_VEC  => act_reply_mask,
      OUTPUT_NUM  => act_reply_port
      );      
  
----------------------------------
--connect reply signals
----------------------------------

  --choose from all reply data the selected one
  reply_selected_read         <= reply_mux_read_out_i(act_reply_port);
  reply_selected_dataready    <= REPLY_DATAREADY_IN(act_reply_port);
  reply_selected_data         <= REPLY_DATA_IN(16*act_reply_port+15 downto 16*act_reply_port);
  reply_selected_packet_num   <= REPLY_PACKET_NUM_IN(3*act_reply_port+2 downto 3*act_reply_port);

  -- Reply read out
  -- as long as there is no data available or if mux really reads or if reading TRM
  reply_read_out_i <=  reply_mux_read_out_i or reply_reading_trm; --not reply_dataready_in_i or
  REPLY_READ_OUT <= reply_read_out_i;

   
  gen_reply_con : for i in 0 to POINT_NUMBER-1 generate
    reply_dataready_in_i(i)                  <= REPLY_DATAREADY_IN(i);
    reply_data_in_i(i*16+15 downto i*16)     <= REPLY_DATA_IN(i*16+15 downto i*16);
    reply_packet_num_in_i(i*3+2 downto i*3)  <= REPLY_PACKET_NUM_IN(i*3+2 downto i*3);
  
    TRM_packet(i) <= '1' when REPLY_DATA_IN(i*16+2 downto i*16) = TYPE_TRM and REPLY_PACKET_NUM_IN(i*3+2 downto i*3) = c_H0 else '0';
  end generate;

  
----------------------------------
--combine error pattern
----------------------------------  
  process begin
    wait until rising_edge(CLK);
    if  currentstate = IDLE or currentstate = SELECT_INIT then
      reply_reading_trm <= (others => '0');
      reply_got_trm     <= not real_active_points or is_uplink_only;
    else
      reply_reading_trm <= reply_reading_trm or TRM_packet;
      reply_got_trm     <= reply_got_trm or reading_trmF3 or timeout_ports or CTRL_DISABLED_PORTS(POINT_NUMBER-1 downto 0) or is_uplink_only;
    end if;
  end process;

  gen_reading_trmFn : for i in 0 to POINT_NUMBER-1 generate
    reading_trmF1(i) <= '1' when REPLY_PACKET_NUM_IN(i*3+2 downto i*3) = c_F1
                                 and reply_reading_trm(i) = '1' and REPLY_DATAREADY_IN(i) = '1' else '0';
    reading_trmF2(i) <= '1' when REPLY_PACKET_NUM_IN(i*3+2 downto i*3) = c_F2
                                 and reply_reading_trm(i) = '1' and REPLY_DATAREADY_IN(i) = '1' else '0';
    reading_trmF3(i) <= '1' when REPLY_PACKET_NUM_IN(i*3+2 downto i*3) = c_F3
                                 and reply_reading_trm(i) = '1' and REPLY_DATAREADY_IN(i) = '1' else '0';
  end generate;
  
  gen_combining_trm : for j in 0 to c_DATA_WIDTH-1 generate
    process(CLK)
      variable tmpF1, tmpF2, tmpF3 : std_logic;
      begin
        if rising_edge(CLK) then
          if reset_i = '1' or currentstate = SELECT_INIT then
            reply_combined_trm_f1(j) <= '0';
            reply_combined_trm_f2(j) <= '0';
            reply_combined_trm_f3(j) <= '0';
          else
            tmpF1 := '0';
            tmpF2 := '0';
            tmpF3 := '0';
            for i in 0 to POINT_NUMBER-1 loop
              tmpF1 := tmpF1 or (REPLY_DATA_IN(i*c_DATA_WIDTH+j) and reading_trmF1(i));
              tmpF2 := tmpF2 or (REPLY_DATA_IN(i*c_DATA_WIDTH+j) and reading_trmF2(i));
              tmpF3 := tmpF3 or (REPLY_DATA_IN(i*c_DATA_WIDTH+j) and reading_trmF3(i));
            end loop;
            reply_combined_trm_f1(j) <= reply_combined_trm_f1(j) or tmpF1;
            if j = 6 then
              reply_combined_trm_f2(j) <= reply_combined_trm_f2(j) or tmpF2 or timeout_found;
            else
              reply_combined_trm_f2(j) <= reply_combined_trm_f2(j) or tmpF2;
            end if;
            reply_combined_trm_f3(j) <= reply_combined_trm_f3(j) or tmpF3;
          end if;
        end if;
      end process;
  end generate;
  
  timeout_found <= or_all(timeout_ports);
  
----------------------------------
--Controller
----------------------------------
  FSM : process begin
    wait until rising_edge(CLK);
--     reply_mux_read_out_i                 <= (others => '0');    
    reply_select_enable                  <= '0';
    init_pool_dataready_in               <= '0';
    reply_pool_dataready_in              <= '0';
    init_select_enable                   <= '0';
    timer_us_reset                       <= timeout_disabled;
    reply_open                           <= '0';
    reply_pool_data_in                   <= (others => '0');
    reply_pool_packet_num_in             <= (others => '0');
    
    case currentstate is
      when IDLE =>
        real_active_points               <=         CTRL_activepoints(POINT_NUMBER-1 downto 0) 
                                            and not timeout_ports_disable 
                                            and not CTRL_DISABLED_PORTS(POINT_NUMBER-1 downto 0);
        timer_us_reset                   <= '1';
        if or_all(INIT_DATAREADY_IN and real_active_points) = '1' then
          currentstate                   <= SELECT_INIT;
          init_select_enable             <= '1';
        end if;
        
      when SELECT_INIT =>
        timeout_ports                    <= (others => '0');
        currentstate                     <= FORWARD_INIT;
        init_current_type                <= (others => '0');
      
      when FORWARD_INIT =>
        if init_pool_free = '1' then
          if init_selected_packet_num = c_H0 then
            init_current_type            <= init_selected_data(2 downto 0);
          end if;
          timer_us_reset                 <= '1';
          init_pool_data_in              <= init_selected_data;
          init_pool_packet_num_in        <= init_selected_packet_num;
          init_pool_dataready_in         <= init_selected_dataready;
          if init_current_type = TYPE_TRM and init_selected_packet_num = c_F3 then
            currentstate                 <= SELECT_REPLY;
          end if;
        else
          if timer_us = config_wait_free_init_pool and timeout_disabled = '0' then
            timeout_ports                <= timeout_ports or (not init_has_read_from_pool);--INIT_READ_IN and not act_init_mask);
            real_active_points           <= real_active_points and init_has_read_from_pool; --(INIT_READ_IN or act_init_mask);
          end if;
        end if;

      when SELECT_REPLY =>
        init_read_out_i                  <= (others => '0');      
        reply_select_enable              <= '1';
        if or_all(REPLY_DATAREADY_IN and real_active_points and not reply_reading_trm and not TRM_packet) = '1' then
          timer_us_reset                 <= '1';
          currentstate                   <= WAIT_FOR_SELECT;
        end if;
        if timer_us = config_wait_reply and timeout_disabled = '0' then
	        timeout_ports                  <= timeout_ports or (not reply_got_trm and real_active_points and not act_init_mask); --not reply_reading_trm and
          
--TODO: add proper handling - should be ok like it is?
        end if;
        if and_all(reply_got_trm or act_init_mask) = '1' then
          currentstate <= SEND_TRM;
          send_trm_cnt <= 4;
        end if;
        
      when WAIT_FOR_SELECT =>
        currentstate <= FORWARD_REPLY;
        reply_open   <= '1';
        
      when FORWARD_REPLY =>
        reply_pool_data_in             <= reply_selected_data;
        reply_pool_packet_num_in       <= reply_selected_packet_num;

        if TRM_packet(act_reply_port) = '1' or reply_reading_trm(act_reply_port) = '1' then
          currentstate                 <= SELECT_REPLY;
          reply_pool_dataready_in      <= '0';
        elsif timer_us = config_wait_reply and timeout_disabled = '0' then   --assume alsways full packets due to error correction
          real_active_points           <= real_active_points and not act_reply_mask;
          timer_us_reset               <= '1';
          timeout_ports                <= timeout_ports or act_reply_mask;
          currentstate                 <= SELECT_REPLY;
        else
          reply_open                   <= '1';
          reply_pool_dataready_in      <= reply_selected_dataready and reply_selected_read;
        end if;
        if reply_selected_dataready = '1' then
          timer_us_reset               <= '1';
        end if;
        
      when SEND_TRM =>
        case send_trm_cnt is
          when 4 =>
            if reply_pool_free = '1' then
              send_trm_cnt <= 0;
            end if;
            reply_pool_data_in <= x"0003";
          when 0 =>
            if reply_pool_free = '1' then
              send_trm_cnt <= 1;
            end if;
            reply_pool_data_in <= x"0000";
          when 1 =>
            if reply_pool_free = '1' then
              send_trm_cnt <= 2;
            end if;
            reply_pool_data_in <= reply_combined_trm_f1;
          when 2 =>
            if reply_pool_free = '1' then
              send_trm_cnt <= 3;
            end if;
            reply_pool_data_in <= reply_combined_trm_f2;
          when 3 =>
            if reply_pool_free = '1' then
              currentstate               <= FINISHED;
            end if;
            reply_pool_data_in <= reply_combined_trm_f3;
          when others => null;
        end case;
        reply_pool_dataready_in  <= reply_pool_free;
        reply_pool_packet_num_in <= std_logic_vector(to_unsigned(send_trm_cnt,3));
        
      when FINISHED =>
        currentstate                     <= IDLE;
        
      when REPLY_TIMEOUT =>
        null;
    end case;
    if reset_i = '1' then
      currentstate <= IDLE;
    end if;
  end process;


process(reply_pool_free, reply_open,act_reply_port)
  begin
    reply_mux_read_out_i <= (others => '0');
    reply_mux_read_out_i(act_reply_port) <= reply_pool_free and reply_open;
  end process;  


----------------------------------
--SBuf for init output
----------------------------------


  INIT_POOL_SBUF : fifo_19x16
    port map(
      Data(15 downto 0)  => init_pool_data_in, 
      Data(18 downto 16) => init_pool_packet_num_in,
      Clock              => CLK, 
      WrEn               => init_pool_dataready_in,
      RdEn               => init_pool_read_out,
      Reset              => reset_i,
      Q(15 downto 0)     => init_pool_data_out,
      Q(18 downto 16)    => init_pool_packet_num_out,
      WCNT               => open, 
      Empty              => init_pool_empty,
      Full               => open,
      AlmostFull         => init_pool_full
      );

  init_pool_free          <= not init_pool_full  when rising_edge(CLK);
  init_pool_dataready_out <= (not init_pool_empty and init_pool_read_out) 
                              or (init_pool_dataready_out and not init_pool_read_out) when rising_edge(CLK);
  init_pool_read_out      <= and_all(INIT_READ_IN or init_has_read_from_pool);

  
  --Which ports have read data from pool
  gen_hasread: for i in 0 to POINT_NUMBER-1 generate
    process(CLK)
      begin
        if rising_edge(CLK) then
          if reset_i = '1' then
            init_has_read_from_pool(i) <= '0';
          elsif MII_IS_UPLINK_ONLY(i) = c_YES or real_active_points(i) = '0' or act_init_port = i then
            init_has_read_from_pool(i) <= '1';
          elsif init_pool_read_out = '1' then
            init_has_read_from_pool(i) <= '0';
          elsif (init_pool_dataready_out = '1' and INIT_READ_IN(i) = '1') then
            init_has_read_from_pool(i) <= '1';
          end if;
        end if;
      end process;
  end generate;
  
  
 
----------------------------------
--SBuf for reply output
----------------------------------


  REPLY_POOL_SBUF : fifo_19x16
    port map(
      Data(15 downto 0)  => reply_pool_data_in, 
      Data(18 downto 16) => reply_pool_packet_num_in,
      Clock              => CLK, 
      WrEn               => reply_pool_dataready_in,
      RdEn               => reply_pool_read_out,
      Reset              => reset_i,
      Q(15 downto 0)     => reply_pool_data_out,
      Q(18 downto 16)    => reply_pool_packet_num_out,
      WCNT               => open, 
      Empty              => reply_pool_empty,
      Full               => open,
      AlmostFull         => reply_pool_full
      );

  reply_pool_free          <= not reply_pool_full  when rising_edge(CLK);      
  reply_pool_dataready_out <= (not reply_pool_empty and reply_pool_read_out) 
                              or (reply_pool_dataready_out and not reply_pool_read_out) when rising_edge(CLK);

  reply_pool_read_out <= REPLY_READ_IN(act_init_port);
  
----------------------------------
--connect output signals
----------------------------------  
  gen_init_output : for i in 0 to POINT_NUMBER-1 generate
    INIT_DATA_OUT(16*i+15 downto 16*i)    <= init_pool_data_out;
    INIT_PACKET_NUM_OUT(3*i+2 downto 3*i) <= init_pool_packet_num_out;
    INIT_DATAREADY_OUT(i)                 <= init_pool_dataready_out and not init_has_read_from_pool(i) and real_active_points(i);
    REPLY_DATA_OUT(16*i+15 downto 16*i)   <= reply_pool_data_out;
    REPLY_PACKET_NUM_OUT(3*i+2 downto 3*i)<= reply_pool_packet_num_out;
    REPLY_DATAREADY_OUT(i)                <= reply_pool_dataready_out and act_init_mask(i);
  end generate;
  

  
  proc_timeout_cntr : process begin 
    wait until rising_edge(CLK);
    for i in 0 to POINT_NUMBER-1 loop
      timeout_ports_disable(i) <= timeout_cntr(i)(1);
      if reset_i = '1' or CTRL_activepoints(i) = '0' then
        timeout_cntr(i) <= (others => '0');
      elsif currentstate = FINISHED and timeout_ports(i) = '1' and timeout_cntr(i)(1) = '0' then
        timeout_cntr(i) <= timeout_cntr(i) + 1;
      end if;
    end loop;
  end process;
  
  
  
----------------------------------
--Status registers
----------------------------------  
  
  STAT_POINTS_locked(31 downto POINT_NUMBER)  <= (others => '0');

  proc_stat_errorbits : process begin
      wait until rising_edge(CLK);
      if currentstate /= IDLE then
        STAT_POINTS_locked(POINT_NUMBER-1 downto 0) <= not reply_got_trm and real_active_points and not act_init_mask;
      else
        STAT_POINTS_locked(POINT_NUMBER-1 downto 0) <= (others => '0');
      end if;
      
      if currentstate = IDLE  then
        STAT_ERRORBITS <= reply_combined_trm_f1 & reply_combined_trm_f2;
      end if;
    end process;

  gen_monitoring_errorbits : process(CLK)
    begin
      if rising_edge(CLK) then
        for i in 0 to POINT_NUMBER-1 loop
          if reading_trmF1(i) = '1' then
            STAT_ALL_ERRORBITS(i*32+31 downto i*32+16) <= REPLY_DATA_IN(i*16+15 downto i*16);
          elsif reading_trmF2(i) = '1' then
            STAT_ALL_ERRORBITS(i*32+15 downto i*32+0) <= REPLY_DATA_IN(i*16+15 downto i*16);
          end if;
        end loop;
      end if;
    end process;
  STAT_ALL_ERRORBITS(15*32+31 downto POINT_NUMBER*32) <= (others => '0');

  STAT_TIMEOUT(POINT_NUMBER-1 downto 0)     <= timeout_ports;
  STAT_TIMEOUT(15 downto POINT_NUMBER)      <= (others => '0');
  STAT_TIMEOUT(16+POINT_NUMBER-1 downto 16) <= timeout_ports_disable;
  STAT_TIMEOUT(31 downto 16+POINT_NUMBER)   <= (others => '0');
  
  STAT_locked        <= '0' when currentstate = IDLE else '1';
  
                 
  PROC_FSMstate : process begin
    wait until rising_edge(CLK);
      case currentstate is
        when IDLE => STAT(3 downto 0) <= x"1"; 
        when SELECT_INIT => STAT(3 downto 0) <= x"2"; 
        when FORWARD_INIT => STAT(3 downto 0) <= x"3"; 
        when SELECT_REPLY => STAT(3 downto 0) <= x"4"; 
        when WAIT_FOR_SELECT => STAT(3 downto 0) <= x"5"; 
        when FORWARD_REPLY => STAT(3 downto 0) <= x"6"; 
        when REPLY_TIMEOUT => STAT(3 downto 0) <= x"7"; 
        when SEND_TRM => STAT(3 downto 0) <= x"8"; 
        when FINISHED => STAT(3 downto 0) <= x"F"; 
      end case;
    end process;
  
  
end architecture;

