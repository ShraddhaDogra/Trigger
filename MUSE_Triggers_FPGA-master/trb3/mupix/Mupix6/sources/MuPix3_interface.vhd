-----------------------------------------------------------------------------
-- MUPIX3 readout interface
--
-- Niklaus Berger, Heidelberg University
-- nberger@physi.uni-heidelberg.de
-- Adepted to TRBv3 Readout: Tobias Weber, University Mainz
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mupix_components.all;

use work.StdTypes.all;

entity mupix_interface is
  port (
    rst        : in  std_logic;
    clk        : in  std_logic;
    -- MUPIX IF
    mupixcontrol : out MupixReadoutCtrl;
    mupixreadout : in MupixReadoutData;
    
    -- MEMORY IF
    memdata    : out std_logic_vector(31 downto 0);
    memwren    : out std_logic;
    endofevent : out std_logic;

    --Readout Indicator
    ro_busy : out std_logic;

    --trigger
    trigger_ext : in std_logic;

    --reset signals from DAQ
    timestampreset_in    : in std_logic;
    eventcounterreset_in : in std_logic;

    --TRB SlowControl
    SLV_READ_IN          : in  std_logic;
    SLV_WRITE_IN         : in  std_logic;
    SLV_DATA_OUT         : out std_logic_vector(31 downto 0);
    SLV_DATA_IN          : in  std_logic_vector(31 downto 0);
    SLV_ADDR_IN          : in  std_logic_vector(15 downto 0);
    SLV_ACK_OUT          : out std_logic;
    SLV_NO_MORE_DATA_OUT : out std_logic;
    SLV_UNKNOWN_ADDR_OUT : out std_logic

    );
end mupix_interface;


architecture RTL of mupix_interface is
	
  type ro_state_type is (idle, loadpix, pulld, loadcol, readcol, pause);
  type hitgen_state_type is (idle, genheader, genhits, hitgeneratorwait);
  
  signal ro_state : ro_state_type := idle;
  signal hitgen_state : hitgen_state_type := idle;
  
  signal ro_delcounter              : unsigned(7 downto 0)          := (others => '0');
  signal hitgen_delcounter          : integer range 0 to 2          := 0;
  signal delaycounters1             : std_logic_vector(31 downto 0) := (others => '0');
  signal delaycounters2             : std_logic_vector(31 downto 0) := (others => '0');
  signal pauseregister              : std_logic_vector(31 downto 0) := (others => '0');
  signal pausecounter               : unsigned (31 downto 0)        := (others => '0');
  signal graycount                  : std_logic_vector(7 downto 0)  := (others => '0');
  signal hitcounter                 : unsigned(10 downto 0)         := (others => '0');
  signal maxNumberHits              : std_logic_vector(31 downto 0) := (others => '1');
  signal graycounter_clkdiv_counter : std_logic_vector(31 downto 0) := (others => '0');
  signal sensor_id                  : std_logic_vector(31 downto 0) := (others => '0');

  signal triggering            : std_logic := '0';
  signal continousread         : std_logic := '0';
  signal readnow               : std_logic := '0';
  signal reseteventcount       : std_logic := '0';
  signal generatehit           : std_logic := '0';
  signal generatehits          : std_logic := '0';
  signal generatetriggeredhits : std_logic := '0';

  signal ngeneratehits           : std_logic_vector(15 downto 0) := (others => '0');
  signal ngeneratehitscounter    : unsigned(15 downto 0)         := (others => '0');
  signal generatehitswaitcounter : unsigned(31 downto 0)         := (others => '0');

  signal gen_hit_col  : std_logic_vector(5 downto 0) := (others => '0');
  signal gen_hit_row  : std_logic_vector(5 downto 0) := (others => '0');
  
  signal testoutro : std_logic_vector (31 downto 0) := (others => '0');

  --Control Registers
  signal resetgraycounter     : std_logic                     := '0';
  signal roregwritten         : std_logic                     := '0';
  signal roregister           : std_logic_vector(31 downto 0) := (others => '0');
  signal rocontrolbits        : std_logic_vector(31 downto 0) := (others => '0');
  signal timestampcontrolbits : std_logic_vector(31 downto 0) := (others => '0');
  signal generatehitswait     : std_logic_vector(31 downto 0) := (others => '0');

  --readout signal registers
  signal priout_reg : std_logic := '0';
  signal ld_pix_i : std_logic := '0';
  signal pulldown_i : std_logic := '0';
  signal ld_col_i : std_logic := '0';
  signal rd_col_i : std_logic := '0';
  signal ld_pix_reg : std_logic := '0';
  signal pulldown_reg : std_logic := '0';
  signal ld_col_reg : std_logic := '0';
  signal rd_col_reg : std_logic := '0';
  attribute syn_preserve : boolean;
  attribute syn_keep : boolean;
  attribute syn_keep of ld_pix_reg, pulldown_reg, ld_col_reg, rd_col_reg : signal is true;
  attribute syn_preserve of ld_pix_reg, pulldown_reg, ld_col_reg, rd_col_reg : signal is true;
  
  --data multiplexing
  signal selecthitgen     : std_logic := '0';
  signal memdata_mupix_i  : std_logic_vector(31 downto 0);
  signal memwren_mupix_i  : std_logic;
  signal endofevent_mupix_i : std_logic;
  signal ro_busy_mupix_i    : std_logic;
  signal memdata_hitgen_i : std_logic_vector(31 downto 0);
  signal memwren_hitgen_i : std_logic;
  signal endofevent_hitgen_i : std_logic;
  signal ro_busy_hitgen_i    : std_logic;	
  
  --event counting
  signal eventcounter                   : unsigned(31 downto 0) := (others => '0');
  signal increase_eventcounter_mpx_i    : std_logic;
  signal increase_eventcounter_hitgen_i : std_logic;
  
  --start readouts
  type ro_ctrl_type is (idle, mupix_reading, hitgen_running);
  signal ro_ctrl_state                  : ro_ctrl_type := idle;
  signal start_mupix_ro_i               : std_logic := '0';
  signal start_hitgen_i                 : std_logic := '0';
  signal ro_busy_vec                    : std_logic_vector(1 downto 0) := (others => '0');
  
begin

  -----------------------------------------------------------------------------
  --SLV Bus Handler
  --x0500: Readoutregister
  --x0501: Readout Controlbits (manual readout)
  --x0502: Timestamp Controlbits
  --x0503: Hit Generator
  --x0504: Delay Counters 1
  --x0505: EventCounter
  --x0506: Pause Register
  --x0507: Delay Counters 2
  --x0508: Divider for graycounter clock
  --x0510: testoutro
  --x0511: Sensor-ID
  --x0512: maximal frame size
  -----------------------------------------------------------------------------
  SLV_HANDLER : process(clk)
  begin  -- process SLV_HANDLER
    if rising_edge(clk) then
      SLV_DATA_OUT         <= (others => '0');
      SLV_UNKNOWN_ADDR_OUT <= '0';
      SLV_NO_MORE_DATA_OUT <= '0';
      SLV_ACK_OUT          <= '0';
      roregwritten         <= '0';

      if SLV_READ_IN = '1' then
        case SLV_ADDR_IN is
          when x"0500" =>
            SLV_DATA_OUT <= roregister;
            SLV_ACK_OUT  <= '1';
          when x"0501" =>
            SLV_DATA_OUT <= rocontrolbits;
            SLV_ACK_OUT  <= '1';
          when x"0502" =>
            SLV_DATA_OUT <= timestampcontrolbits;
            SLV_ACK_OUT  <= '1';
          when x"0503" =>
            SLV_DATA_OUT <= generatehitswait;
            SLV_ACK_OUT  <= '1';
          when x"0504" =>
            SLV_DATA_OUT <= delaycounters1;
            SLV_ACK_OUT  <= '1';
          when x"0505" =>
            SLV_DATA_OUT <= std_logic_vector(eventcounter);
            SLV_ACK_OUT  <= '1';
          when x"0506" =>
            SLV_DATA_OUT <= pauseregister;
            SLV_ACK_OUT  <= '1';
          when x"0507" =>
            SLV_DATA_OUT <= delaycounters2;
            SLV_ACK_OUT  <= '1';
          when x"0508" =>
            SLV_DATA_OUT <= graycounter_clkdiv_counter;
            SLV_ACK_OUT  <= '1';
          when x"0510" =>
            SLV_DATA_OUT <= testoutro;
            SLV_ACK_OUT  <= '1';
          when x"0511" =>
            SLV_DATA_OUT <= sensor_id;
            SLV_ACK_OUT  <= '1';
          when x"0512" =>
            SLV_DATA_OUT <= maxNumberHits;
            SLV_ACK_OUT  <= '1';
          when x"0513" =>
            SLV_DATA_OUT(0) <= ro_busy_hitgen_i or ro_busy_mupix_i;
            SLV_ACK_OUT <= '1';
          when others =>
            SLV_UNKNOWN_ADDR_OUT <= '1';
        end case;
      end if;

      if SLV_WRITE_IN = '1' then
        case SLV_ADDR_IN is
          when x"0500" =>
            roregister   <= SLV_DATA_IN;
            roregwritten <= '1';        --trigger the readout
            SLV_ACK_OUT  <= '1';
          when x"0501" =>
            rocontrolbits <= SLV_DATA_IN;
            SLV_ACK_OUT   <= '1';
          when x"0502" =>
            timestampcontrolbits <= SLV_DATA_IN;
            SLV_ACK_OUT          <= '1';
          when x"0503" =>
            generatehitswait <= SLV_DATA_IN;
            SLV_ACK_OUT      <= '1';
          when x"0504" =>
            delaycounters1 <= SLV_DATA_IN;
            SLV_ACK_OUT    <= '1';
          when x"0506" =>
            pauseregister <= SLV_DATA_IN;
            SLV_ACK_OUT   <= '1';
          when x"0507" =>
            delaycounters2 <= SLV_DATA_IN;
            SLV_ACK_OUT    <= '1';
          when x"0508" =>
            graycounter_clkdiv_counter <= SLV_DATA_IN;
            SLV_ACK_OUT                <= '1';
          when x"0511" =>
            sensor_id   <= SLV_DATA_IN;
            SLV_ACK_OUT <= '1';
          when x"0512" =>
            maxNumberHits <= SLV_DATA_IN;
            SLV_ACK_OUT   <= '1';
          when others =>
            SLV_UNKNOWN_ADDR_OUT <= '1';
        end case;
      end if;
    end if;
  end process SLV_HANDLER;

  -----------------------------------------------------------------------------
  --Readout Control
  -----------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if(rst = '1') then
        triggering            <= '0';
        continousread         <= '0';
        readnow               <= '0';
        reseteventcount       <= '0';
        generatehit           <= '0';
        generatehits          <= '0';
        generatetriggeredhits <= '0';
        ngeneratehits         <= (others => '0');
      else
        triggering    <= roregister(0);
        continousread <= roregister(1);
        if(roregister(2) = '1' and roregwritten = '1') then
          readnow <= '1';
        else
          readnow <= '0';
        end if;
        if((roregister(4) = '1' and roregwritten = '1') or eventcounterreset_in = '1') then
          reseteventcount <= '1';
        else
          reseteventcount <= '0';
        end if;
        if(roregister(5) = '1' and roregwritten = '1') then
          generatehit <= '1';
        else
          generatehit <= '0';
        end if;
        generatehits          <= roregister(6);
        generatetriggeredhits <= roregister(8);
        ngeneratehits         <= roregister(31 downto 16);
      end if;
    end if;
  end process;

   readout_ctrl : process (clk) is
   begin
   	if rising_edge(clk) then
   		if rst = '1' then
   			ro_ctrl_state <= idle;
   			start_mupix_ro_i <= '0';
   			start_hitgen_i   <= '0';
   			ro_busy_vec      <= (others => '0');
   		else
   			start_mupix_ro_i <= '0';
   			start_hitgen_i   <= '0';
   			selecthitgen     <= '0';
   			ro_busy_vec      <= ro_busy_vec(0) & (ro_busy_mupix_i or ro_busy_hitgen_i);
   			case ro_ctrl_state is 
   				when idle =>
   					if(continousread = '1' or readnow = '1' or 
   						(triggering = '1' and trigger_ext = '1' and generatetriggeredhits = '0')) then
   						start_mupix_ro_i <= '1';
   						ro_ctrl_state <= mupix_reading;
   					elsif((generatetriggeredhits = '1' and trigger_ext = '1') or 
   						(generatehit = '1' or generatehits = '1')) then
   						start_hitgen_i <= '1';
   						selecthitgen   <= '1';
   						ro_ctrl_state <= hitgen_running;
   					else
   						ro_ctrl_state <= idle;
   				    end if;
   				when mupix_reading =>
   					if ro_busy_vec = "10" then
   						ro_ctrl_state <= idle;
   					else
   						ro_ctrl_state <= mupix_reading;
   					end if;
   				when hitgen_running =>
   					if ro_busy_vec = "10" then
   						ro_ctrl_state <= idle;
   					else
   						selecthitgen   <= '1';
   						ro_ctrl_state <= hitgen_running;
   				    end if;
   			end case;
   		end if;
   	end if;
   end process readout_ctrl;
   

  -----------------------------------------------------------------------------
  --MuPix 3/4/6 Readout Statemachine
  -----------------------------------------------------------------------------
  ro_statemachine : process(clk)
  begin
    if rising_edge(clk) then
      if(rst = '1') then
        ro_state        <= idle;
        ld_pix_i    <= '0';
        ld_col_i    <= '0';
        rd_col_i    <= '0';
        pulldown_i <= '0';
        ro_busy_mupix_i  <= '0';
        endofevent_mupix_i  <= '0';
      else
      	testoutro(0)     <= mupixreadout.priout;
      	testoutro(5 downto 1) <= (others => '0');
        memwren_mupix_i  <= '0';
        memdata_mupix_i  <= (others => '0');
        endofevent_mupix_i <= '0';
        ro_busy_mupix_i   <= '0';
        increase_eventcounter_mpx_i <= '0';
        ld_pix_i         <= '0';
        pulldown_i       <= '0';
        ld_col_i         <= '0';
        rd_col_i         <= '0';
        case ro_state is
          when pause =>
          	pausecounter <= pausecounter + 1;
          	ro_busy_mupix_i   <= '1';
            if(std_logic_vector(pausecounter) = pauseregister) then
              ro_state        <= idle;
              pausecounter <= (others => '0');
            end if;
          
          when idle =>
            testoutro(1) <= '1';
            ro_delcounter <= (others => '0');
            hitcounter   <= (others => '0');
            if(start_mupix_ro_i = '1') then
              ro_state        <= loadpix;
              ro_busy_mupix_i   <= '1';
              ld_pix_i   <= '1';
              ro_delcounter   <= unsigned(delaycounters1(7 downto 0));
              increase_eventcounter_mpx_i <= '1';
            else
              ro_state <= idle;
            end if;
            
          when loadpix =>
            ro_busy_mupix_i  <= '1';
            testoutro(2) <= '1';
            --data output
            case ro_delcounter(7 downto 0) is
              when "00000010" =>
                memdata_mupix_i <= sensor_id;
                memwren_mupix_i <= '1';
              when "00000001" =>
                memdata_mupix_i <= x"FABEABBA";
                memwren_mupix_i <= '1';
              when "00000000" =>
                memdata_mupix_i <= std_logic_vector(eventcounter);
                memwren_mupix_i <= '1';
              when others =>
                memdata_mupix_i <= (others => '0');
                memwren_mupix_i <= '0';
            end case;
            --state machine
            if(ro_delcounter = "00000000") then
              ro_state      <= pulld;
              pulldown_i   <= '1';
              ro_delcounter <= unsigned(delaycounters1(15 downto 8));
            else
              pulldown_i   <= '0';
              ro_delcounter   <= ro_delcounter - 1;
              ro_state        <= loadpix;
            end if;
          when pulld =>
            ro_busy_mupix_i  <= '1';
            testoutro(3)  <= '1';
            ro_delcounter <= ro_delcounter - 1;
            ro_state      <= pulld;
            if(ro_delcounter = "00000000") then
              ro_state      <= loadcol;
              ld_col_i  <= '1';
              ro_delcounter <= unsigned(delaycounters1(23 downto 16));
            end if;
          when loadcol =>
            ro_busy_mupix_i  <= '1';
            testoutro(4) <= '1';
            ro_delcounter <= ro_delcounter - 1;
            ro_state      <= loadcol;
            if(ro_delcounter = "00000000") then
              if  mupixreadout.priout = '1' then
                ro_state      <= readcol;
                rd_col_i <= '1';
                ro_delcounter <= unsigned(delaycounters1(31 downto 24));
              else
                memwren_mupix_i    <= '1';
                memdata_mupix_i    <= x"BEEFBEEF";
                endofevent_mupix_i <= '1';
                ro_state      <= pause;
              end if;
            end if;
          when readcol =>
            ro_busy_mupix_i  <= '1';
            testoutro(5) <= '1';
            ro_delcounter <= ro_delcounter - 1;
            ro_state      <= readcol;
            --issue read signal
            if(ro_delcounter > unsigned(delaycounters1(31 downto 24)) - unsigned(delaycounters2(15 downto 8))) then
              rd_col_i <= '1';
            end if;
            --sample priout
            if (std_logic_vector(ro_delcounter) = delaycounters2(23 downto 16)) then
              priout_reg <=  mupixreadout.priout;
            end if;
            --write hit information
            if(std_logic_vector(ro_delcounter) = delaycounters2(31 downto 24)) then
              memdata_mupix_i <= x"F0F" &  mupixreadout.hit_col &  mupixreadout.hit_row &  mupixreadout.hit_time;  
              memwren_mupix_i <= '1';
              hitcounter <= hitcounter + 1;
              ro_state      <= readcol;
            elsif(ro_delcounter = "00000000") then
              if(hitcounter = unsigned(maxNumberHits(10 downto 0))) then
                -- maximal number of hits reaced
                -- force end of event 
                memwren_mupix_i    <= '1';
                memdata_mupix_i    <= x"BEEFBEEF";    --0xBEEFBEEF
                endofevent_mupix_i <= '1';
                ro_state      <= pause;
              else
                if ( mupixreadout.priout = '1' or (delaycounters2(23 downto 16) /= "00000000" and priout_reg = '1')) then
                  ro_state      <= readcol;
                  rd_col_i <= '1';
                  ro_delcounter <= unsigned(delaycounters1(31 downto 24));
                else
                  ro_state        <= pulld;
                  pulldown_i <= '1';
                  ro_delcounter   <= unsigned(delaycounters2(7 downto 0));  
                end if;
              end if;
            end if;            
        end case;
      end if;
    end if;
  end process;

  hitgen_statemachine : process (clk) is
  begin
  	if rising_edge(clk) then
  		if rst = '1' then
  		  hitgen_state <= idle;
     	else
     		memdata_hitgen_i <= (others => '0');
     		memwren_hitgen_i <= '0';
     		endofevent_hitgen_i <= '0';
     		ro_busy_hitgen_i    <= '0';
     		increase_eventcounter_hitgen_i <= '0';
     		testoutro(7 downto 6) <= (others => '0');
  		  case hitgen_state is 
  		  	when idle =>
			  hitgen_delcounter <= 0;  		  	
  		  	  if(start_hitgen_i = '1') then
                hitgen_state     <= genheader;
                increase_eventcounter_hitgen_i <= '1';
                ro_busy_hitgen_i    <= '1';
              else
            	hitgen_state <= idle;
              end if;
            
  		  	when genheader =>
  		  		testoutro(6)        <= '1';
            	hitgen_state        <= genheader;
            	hitgen_delcounter   <= hitgen_delcounter + 1;
            	ro_busy_hitgen_i    <= '1';
            	case hitgen_delcounter is
            		when 0 => --write event header
              			memdata_hitgen_i                 <= sensor_id;
              			memwren_hitgen_i                 <= '1';
              			ngeneratehitscounter    <= unsigned(ngeneratehits);
              			generatehitswaitcounter <= unsigned(generatehitswait);
              			gen_hit_col             <= (others => '0');
              			gen_hit_row             <= (others => '0');
              		when 1 =>
             		 	memdata_hitgen_i    <= x"FABEABBA";  
              		 	memwren_hitgen_i    <= '1';
              		when 2 =>
              			memdata_hitgen_i    <= std_logic_vector(eventcounter);
              			memwren_hitgen_i    <= '1';
              			hitgen_state        <= genhits;
             		end case;
             
              when genhits => --write event data
              	testoutro(7)        <= '1';
              	ro_busy_hitgen_i    <= '1';
              	if ngeneratehitscounter > "0000000000000000" then
               		ngeneratehitscounter <= ngeneratehitscounter - 1;
               		gen_hit_col          <= std_logic_vector(unsigned(gen_hit_col) + 5);
               		gen_hit_row          <= std_logic_vector(unsigned(gen_hit_row) + 7);
                	memdata_hitgen_i    <= x"F0F" & "0" & gen_hit_col(4 downto 0) & gen_hit_row & graycount;  
                	memwren_hitgen_i    <= '1';
                	if(gen_hit_row > "100000") then
                    	gen_hit_row <= "000000";
               		end if;
                else
                	if generatehits = '0' then
                 		hitgen_state      <= idle;
                  	  	-- end of event
                  		memwren_hitgen_i    <= '1';
                  	  	memdata_hitgen_i    <= x"BEEFBEEF";  
                   	  	endofevent_hitgen_i <= '1';
                	else
                  		hitgen_state      <= hitgeneratorwait;
                  		-- end of event
                  		memwren_hitgen_i    <= '1';
                  		memdata_hitgen_i    <= x"BEEFBEEF";  
                  		endofevent_hitgen_i <= '1';
                	end if;
           		end if;
            	
  		  	when hitgeneratorwait =>
  		  		hitgen_state            <= hitgeneratorwait;
            	testoutro(8)            <= '1';
            	generatehitswaitcounter <= generatehitswaitcounter - 1;
            	ro_busy_hitgen_i    <= '1';
            	if(to_integer(generatehitswaitcounter) = 0)then
              		hitgen_state        <= genheader;
              		hitgen_delcounter   <= 2;
             	 	increase_eventcounter_hitgen_i <= '1';
            	end if;
  		  end case;	
  		end if;
  	end if;
  end process hitgen_statemachine;
  
  --increment event counter
  event_counter : process (clk) is
  begin
  	if rising_edge(clk) then
  		if rst = '1' then
  			eventcounter <= (others => '0');
  		else
  			if reseteventcount = '1' then
  				eventcounter <= (others => '0');
  			end if;
  			if increase_eventcounter_hitgen_i = '1' or increase_eventcounter_mpx_i = '1' then
  				eventcounter <= eventcounter + 1;
  			end if;
  		end if;
  	end if;
  end process event_counter;
  
  --data multiplexing
  data_mux : with selecthitgen select
  	memdata <=
  		memdata_hitgen_i when '1',
  		memdata_mupix_i when others;
  
  wren_mux : with selecthitgen select
  	memwren <=
  		memwren_hitgen_i when '1',
  		memwren_mupix_i when others;
  
  endofevent <= endofevent_hitgen_i or endofevent_mupix_i;
  ro_busy    <= ro_busy_mupix_i or ro_busy_hitgen_i;
  
  --timestamp generation
  tsgen : process(clk)
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				mupixcontrol.timestamps <= (others => '0');
			else
				if (timestampcontrolbits(8) = '1') then
					mupixcontrol.timestamps <= graycount;
				else
					mupixcontrol.timestamps <= timestampcontrolbits(7 downto 0);
				end if;
			end if;
		end if;
	end process;

  resetgraycounter <= timestampreset_in or timestampcontrolbits(9);

  grcount : Graycounter
    generic map(
      COUNTWIDTH => 8
      )
    port map(
      clk            => clk,
      reset          => resetgraycounter,
      clk_divcounter => graycounter_clkdiv_counter(7 downto 0),
      counter        => graycount
      );

  output_pipeline : process (clk) is
  begin
  	if rising_edge(clk) then
  		if rst = '1' then
  			ld_pix_reg <= '0';
  			pulldown_reg <= '0';
  			ld_col_reg <= '0';
  			rd_col_reg <= '0';
  		else
  			ld_pix_reg <= ld_pix_i;
  			pulldown_reg <= pulldown_i;
  			ld_col_reg <= ld_col_i;
  			rd_col_reg <= rd_col_i;
  		end if;
  	end if;
  end process output_pipeline;
  

  mupixcontrol.ldpix <= ld_pix_reg;
  mupixcontrol.pulldown <= pulldown_reg;
  mupixcontrol.ldcol <= ld_col_reg;
  mupixcontrol.rdcol <= rd_col_reg;
  
end RTL;
