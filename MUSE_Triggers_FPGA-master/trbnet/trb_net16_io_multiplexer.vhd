LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;


entity trb_net16_io_multiplexer is
  generic(
    USE_INPUT_SBUF     : multiplexer_config_t := (others => c_NO)
    );
  port(
    --  Misc
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    --  Media direction port
    MED_DATAREADY_IN   : in  std_logic;
    MED_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT       : out std_logic;

    MED_DATAREADY_OUT  : out std_logic;
    MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
    MED_READ_IN        : in  std_logic;

    -- Internal direction port
    INT_DATA_OUT       : out std_logic_vector (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
    INT_PACKET_NUM_OUT : out std_logic_vector (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
    INT_DATAREADY_OUT  : out std_logic_vector (2**(c_MUX_WIDTH-1)-1 downto 0);
    INT_READ_IN        : in  std_logic_vector (2**(c_MUX_WIDTH-1)-1 downto 0);

    INT_DATAREADY_IN   : in  std_logic_vector (2**c_MUX_WIDTH-1 downto 0);
    INT_DATA_IN        : in  std_logic_vector (2**c_MUX_WIDTH*c_DATA_WIDTH-1 downto 0);
    INT_PACKET_NUM_IN  : in  std_logic_vector (2**c_MUX_WIDTH*c_NUM_WIDTH-1 downto 0);
    INT_READ_OUT       : out std_logic_vector (2**c_MUX_WIDTH-1 downto 0);

    -- Status and control port
    CTRL               : in  std_logic_vector (31 downto 0);
    STAT               : out std_logic_vector (31 downto 0)
    );
end trb_net16_io_multiplexer;



architecture trb_net16_io_multiplexer_arch of trb_net16_io_multiplexer is


  signal current_demux_READ        : std_logic_vector ((2**c_MUX_WIDTH-1)-1 downto 0);
  signal next_demux_dr             : std_logic_vector (2**(c_MUX_WIDTH-1)-1 downto 0);
  signal next_demux_dr_tmp         : std_logic_vector (2**(c_MUX_WIDTH-1)-1 downto 0);
  signal demux_dr_tmp              : std_logic_vector (2**(c_MUX_WIDTH-1)-1 downto 0);
  signal buf_INT_DATAREADY_OUT     : std_logic_vector (2**(c_MUX_WIDTH-1)-1 downto 0);
  signal buf_INT_DATA_OUT          : std_logic_vector (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
  signal buf_INT_PACKET_NUM_OUT    : std_logic_vector (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
  signal current_MED_READ_OUT      : std_logic;
  signal next_MED_READ_OUT         : std_logic;
  signal final_INT_READ_OUT        : std_logic_vector ((2**c_MUX_WIDTH)-1 downto 0);
  signal mux_read                  : std_logic;
  signal mux_enable                : std_logic;
  signal mux_next_READ             : std_logic;
  signal current_mux_buffer        : std_logic_vector (c_DATA_WIDTH+c_NUM_WIDTH-1 downto 0);
  signal endpoint_locked           : std_logic;
  signal next_endpoint_locked      : std_logic;
  signal buf_INT_READ_OUT          : std_logic_vector ((2**c_MUX_WIDTH)-1 downto 0);
  signal current_mux_packet_number : std_logic_vector (c_NUM_WIDTH-1 downto 0) := c_H0;
  signal last_mux_enable           : std_logic;
  signal arbiter_CLK_EN            : std_logic;
  signal buf_INT_DATA_IN           : std_logic_vector (2**(c_MUX_WIDTH)*c_DATA_WIDTH-1 downto 0);
  signal buf_INT_PACKET_NUM_IN     : std_logic_vector (2**(c_MUX_WIDTH)*c_NUM_WIDTH-1 downto 0);
  signal buf_INT_DATAREADY_IN      : std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
  signal sbuf_status               : std_logic;
  signal real_reading              : std_logic_vector(2**c_MUX_WIDTH -1 downto 0);

  -- Placer Directives
  attribute HGROUP : string;
  -- for whole architecture
  attribute HGROUP of trb_net16_io_multiplexer_arch : architecture  is "MUX_group";

  attribute syn_preserve : boolean;
  attribute syn_keep : boolean;
  attribute syn_preserve of buf_INT_DATA_OUT : signal is true;
  attribute syn_keep of buf_INT_DATA_OUT : signal is true;
  attribute syn_preserve of buf_INT_DATAREADY_OUT : signal is true;
  attribute syn_keep of buf_INT_DATAREADY_OUT : signal is true;
  attribute syn_preserve of buf_INT_READ_OUT  : signal is true;
  attribute syn_keep of buf_INT_READ_OUT  : signal is true;
  attribute syn_preserve of final_INT_READ_OUT  : signal is true;
  attribute syn_keep of final_INT_READ_OUT  : signal is true;
  attribute syn_preserve of mux_read  : signal is true;
  attribute syn_keep of mux_read  : signal is true;
  attribute syn_preserve of real_reading  : signal is true;
  attribute syn_keep of real_reading  : signal is true;
  attribute syn_hier : string;
  attribute syn_hier of trb_net16_io_multiplexer_arch : architecture is "flatten, firm";
  begin
-------------------------------------------------------------------------------
-- DEMUX
------------------------------------------------------------------------------


    process(CLK)
      begin
        if rising_edge(CLK) then
          buf_INT_DATA_OUT       <= MED_DATA_IN & MED_DATA_IN & MED_DATA_IN & MED_DATA_IN;
          buf_INT_PACKET_NUM_OUT <= MED_PACKET_NUM_IN & MED_PACKET_NUM_IN & MED_PACKET_NUM_IN & MED_PACKET_NUM_IN;
        end if;
    end process;

    G2: for i in 0 to 2**(c_MUX_WIDTH-1)-1 generate
      process(CLK)
        begin
          if rising_edge(CLK) then
            if RESET = '1' then
              buf_INT_DATAREADY_OUT(i) <= '0';
            else
              buf_INT_DATAREADY_OUT(i) <= next_demux_dr(i) and MED_DATAREADY_IN;
            end if;
          end if;
        end process;
    end generate;

    INT_DATA_OUT <= buf_INT_DATA_OUT;
    INT_DATAREADY_OUT <= buf_INT_DATAREADY_OUT;
    INT_PACKET_NUM_OUT <= buf_INT_PACKET_NUM_OUT;

    --current_demux_READ <= INT_READ_IN;
--    demux_next_READ <= (others => '1');
    MED_READ_OUT <= current_MED_READ_OUT;

    comb_demux : process (next_demux_dr_tmp, MED_DATAREADY_IN, current_MED_READ_OUT,
                          MED_PACKET_NUM_IN, demux_dr_tmp)
      begin
        next_demux_dr <= demux_dr_tmp; --(others => '0');
        current_demux_READ <= (others => '0');
        next_MED_READ_OUT <= '1'; --and_all(demux_next_READ or INT_READ_IN); --

        current_demux_READ <= (others => '0');
        if current_MED_READ_OUT = '1' then
          current_demux_READ <= (others => '1');
        end if;
        if current_MED_READ_OUT = '1' and MED_DATAREADY_IN = '1' then
          if MED_PACKET_NUM_IN = "100" then  --demux_dr_tmp only valid on packet 0, use saved demux_dr otherwise
            next_demux_dr <= next_demux_dr_tmp;  --enable DR on the sbufs
          else
            next_demux_dr <= demux_dr_tmp;
          end if;
        end if;
      end process;


-- define next DRx
-- the output of the pattern generator is only valid for packet number 00!


    gen_no_demux : if c_MUX_WIDTH = 1 generate
      next_demux_dr_tmp <= (others => '1');
    end generate;
    gen_demux : if c_MUX_WIDTH /= 1 generate
      next_demux_dr_tmp <= conv_std_logic_vector(2**conv_integer(MED_DATA_IN(4+c_MUX_WIDTH-2 downto 4)),2**(c_MUX_WIDTH-1));
    end generate;
    keep_valid_demux : process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            demux_dr_tmp <= (others => '0');
          elsif current_MED_READ_OUT = '1' and MED_DATAREADY_IN = '1' and MED_PACKET_NUM_IN = "100" then
            demux_dr_tmp <= next_demux_dr_tmp;
          end if;
        end if;
      end process;


    sync_demux : process(CLK)
      begin
        if rising_edge(CLK) then
          if RESET = '1' then
            current_MED_READ_OUT <= '0';
          elsif CLK_EN = '1' then
            current_MED_READ_OUT <= next_MED_READ_OUT;
          end if;
        end if;
      end process;


-------------------------------------------------------------------------------
-- MUX part with arbitration scheme
-------------------------------------------------------------------------------


  gen_sbuf : for i in 0 to 2**c_MUX_WIDTH-1 generate
    gen_normal : if USE_INPUT_SBUF(i) = c_NO generate
      INT_READ_OUT(i)                         <= buf_INT_READ_OUT(i);
      buf_INT_DATA_IN(i*16+15 downto i*16)    <= INT_DATA_IN(i*16+15 downto i*16);
      buf_INT_DATAREADY_IN(i)                 <= INT_DATAREADY_IN(i);
      buf_INT_PACKET_NUM_IN(i*3+2 downto i*3) <= INT_PACKET_NUM_IN(i*3+2 downto i*3);
    end generate;
    gen_input_sbuf : if USE_INPUT_SBUF(i) = c_YES generate
      THE_SBUF : trb_net16_sbuf
        generic map (
          VERSION => 5
          )
        port map (
          CLK                => CLK,
          RESET              => RESET,
          CLK_EN             => CLK_EN,
          COMB_DATAREADY_IN  => INT_DATAREADY_IN(i),
          COMB_next_READ_OUT => INT_READ_OUT(i),
          COMB_READ_IN       => '1',
          COMB_DATA_IN       => INT_DATA_IN(i*16+15 downto i*16),
          COMB_PACKET_NUM_IN => INT_PACKET_NUM_IN(i*3+2 downto i*3),
          SYN_DATAREADY_OUT  => buf_INT_DATAREADY_IN(i),
          SYN_DATA_OUT       => buf_INT_DATA_IN(i*16+15 downto i*16),
          SYN_PACKET_NUM_OUT => buf_INT_PACKET_NUM_IN(i*3+2 downto i*3),
          SYN_READ_IN        => buf_INT_READ_OUT(i),
          DEBUG_OUT          => open,
          STAT_BUFFER        => open
          );
    end generate;
  end generate;



ARBITER: trb_net_priority_arbiter
  generic map (
    WIDTH => 2**c_MUX_WIDTH
    )
  port map (
    CLK   => CLK,
    RESET  => RESET,
    CLK_EN  => arbiter_CLK_EN,
    INPUT_IN  =>  buf_INT_DATAREADY_IN,
    RESULT_OUT => final_INT_READ_OUT,
    ENABLE  => mux_enable,
    CTRL => CTRL(9 downto 0)
    );

  arbiter_CLK_EN <= CLK_EN and not next_endpoint_locked;

-- we have to care to read four packets from every endpoint
  process(mux_read, endpoint_locked, current_mux_packet_number)
    begin
      next_endpoint_locked <= endpoint_locked;
      if current_mux_packet_number = "011" and mux_read = '1'  then
        next_endpoint_locked <= '0';
      elsif current_mux_packet_number = "100" and mux_read = '1' then
        next_endpoint_locked <= '1';
      end if;
    end process;

  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          last_mux_enable <= '0';
        else
          last_mux_enable <= mux_enable;
        end if;
      end if;
    end process;

  process(final_INT_READ_OUT, last_mux_enable)
    begin
      if last_mux_enable = '0' then
        buf_INT_READ_OUT <= (others => '0');
      else
        buf_INT_READ_OUT <= final_INT_READ_OUT;
      end if;
    end process;


  STAT(7 downto 0)   <= buf_INT_DATAREADY_IN(7 downto 0);
  STAT(15 downto 8)  <= buf_INT_READ_OUT(7 downto 0);
  STAT(19 downto 16) <= buf_INT_DATAREADY_OUT(3 downto 0);
  STAT(20)           <= next_endpoint_locked;
  STAT(21)           <= arbiter_CLK_EN;
  STAT(24 downto 22) <= current_mux_packet_number;
  STAT(25)           <= mux_read;

  STAT(31 downto 26) <= (others => '0');


  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          endpoint_locked <= '0';
        else
          endpoint_locked <= next_endpoint_locked;
        end if;
      end if;
    end process;



  process(CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          current_mux_packet_number <= c_H0;
        elsif mux_read = '1' then
          if current_mux_packet_number = c_max_word_number then
            current_mux_packet_number <= (others => '0');
          else
            current_mux_packet_number <= current_mux_packet_number + 1;
          end if;
        end if;
      end if;
    end process;


  MUX_SBUF: trb_net16_sbuf
    generic map (
      VERSION => std_SBUF_VERSION
      )
    port map (
      CLK   => CLK,
      RESET  => RESET,
      CLK_EN => CLK_EN,
      COMB_DATAREADY_IN => mux_read,
      COMB_next_READ_OUT => mux_next_READ,
      COMB_READ_IN => '1',
      COMB_DATA_IN => current_mux_buffer(c_DATA_WIDTH-1 downto 0),
      COMB_PACKET_NUM_IN => current_mux_buffer(c_DATA_WIDTH+c_NUM_WIDTH-1 downto c_DATA_WIDTH),
      SYN_DATAREADY_OUT => MED_DATAREADY_OUT,
      SYN_DATA_OUT => MED_DATA_OUT,
      SYN_PACKET_NUM_OUT => MED_PACKET_NUM_OUT,
      SYN_READ_IN => MED_READ_IN,
      STAT_BUFFER => sbuf_status
      );


  process (buf_INT_READ_OUT, buf_INT_DATA_IN, buf_INT_PACKET_NUM_IN)
    variable var_mux_buffer : STD_LOGIC_VECTOR (c_DATA_WIDTH+c_NUM_WIDTH-1 downto 0);
    variable j : integer range 0 to c_MUX_WIDTH-1 := 0;
    variable k : integer range 0 to 2**c_MUX_WIDTH-1 := 0;
    begin
--       j := get_bit_position(buf_INT_READ_OUT);
--       var_mux_buffer(c_DATA_WIDTH-1 downto 0) := INT_DATA_IN(c_DATA_WIDTH*(j+1)-1 downto c_DATA_WIDTH*j);
--       var_mux_buffer(c_DATA_WIDTH+c_NUM_WIDTH-1 downto c_DATA_WIDTH) := INT_PACKET_NUM_IN(c_NUM_WIDTH*(j+1)-1 downto c_NUM_WIDTH*j);
--       if var_mux_buffer(c_DATA_WIDTH+c_NUM_WIDTH-1 downto c_DATA_WIDTH) = "00" then
--         var_mux_buffer(3+c_MUX_WIDTH-1 downto 3) := conv_std_logic_vector(j, c_MUX_WIDTH);
--       end if;
      k := 0;
      var_mux_buffer := (others => '0');
      for i in 0 to 2**c_MUX_WIDTH-1 loop
        for j in 0 to c_DATA_WIDTH+c_NUM_WIDTH-1 loop
          if j < c_DATA_WIDTH then
            var_mux_buffer(j) := var_mux_buffer(j) or (buf_INT_DATA_IN(c_DATA_WIDTH*i+j) and buf_INT_READ_OUT(i));
          else
            var_mux_buffer(j) := var_mux_buffer(j) or (buf_INT_PACKET_NUM_IN(c_NUM_WIDTH*i+j-c_DATA_WIDTH) and buf_INT_READ_OUT(i));
          end if;
          if buf_INT_READ_OUT(i) = '1' and buf_INT_PACKET_NUM_IN(c_NUM_WIDTH*(i+1)-1 downto c_NUM_WIDTH*i) = "100" then
            k := i;
          else
            k := k;
          end if;
        end loop;
      end loop;
      var_mux_buffer(3+c_MUX_WIDTH-1 downto 3) := var_mux_buffer(3+c_MUX_WIDTH-1 downto 3) or conv_std_logic_vector(k, c_MUX_WIDTH);
      current_mux_buffer <= var_mux_buffer;
    end process;

  mux_enable <= (mux_next_READ); -- or MED_READ_IN


  gen_mux_read : for i in 0 to 2**c_MUX_WIDTH-1 generate
    real_reading(i) <= buf_INT_READ_OUT(i) and buf_INT_DATAREADY_IN(i);
  end generate;
  mux_read <= or_all(real_reading);

end architecture;
