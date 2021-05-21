
-- VHDL netlist produced by program ldbanno, Version Diamond (64-bit) 3.6.0.83.4

-- ldbanno -n VHDL -o TrigTest1_TrigTest1_mapvho.vho -w -neg -gui -msgset D:/bartz/Documents/Lattice/TrigTest/promote.xml TrigTest1_TrigTest1_map.ncd 
-- Netlist created on Wed Feb 24 13:48:17 2016
-- Netlist written on Wed Feb 24 13:48:29 2016
-- Design is for device LFE3-150EA
-- Design is for package FPBGA672
-- Design is for performance grade 8

-- entity ec3iobuf
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity ec3iobuf is
    port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);

    ATTRIBUTE Vital_Level0 OF ec3iobuf : ENTITY IS TRUE;

  end ec3iobuf;

  architecture Structure of ec3iobuf is
    component OBZPU
      port (I: in Std_logic; T: in Std_logic; O: out Std_logic);
    end component;
  begin
    INST5: OBZPU
      port map (I=>I, T=>T, O=>PAD);
  end Structure;

-- entity gnd
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity gnd is
    port (PWR0: out Std_logic);

    ATTRIBUTE Vital_Level0 OF gnd : ENTITY IS TRUE;

  end gnd;

  architecture Structure of gnd is
    component VLO
      port (Z: out Std_logic);
    end component;
  begin
    INST1: VLO
      port map (Z=>PWR0);
  end Structure;

-- entity OutpA_0_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity OutpA_0_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "OutpA_0_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_OutpA0	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDO: in Std_logic; OutpA0: out Std_logic);

    ATTRIBUTE Vital_Level0 OF OutpA_0_B : ENTITY IS TRUE;

  end OutpA_0_B;

  architecture Structure of OutpA_0_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal OutpA0_out 	: std_logic := 'X';

    signal GNDI: Std_logic;
    component ec3iobuf
      port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);
    end component;
    component gnd
      port (PWR0: out Std_logic);
    end component;
  begin
    OutpA_pad_0: ec3iobuf
      port map (I=>PADDO_ipd, T=>GNDI, PAD=>OutpA0_out);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, OutpA0_out)
    VARIABLE OutpA0_zd         	: std_logic := 'X';
    VARIABLE OutpA0_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    OutpA0_zd 	:= OutpA0_out;

    VitalPathDelay01Z (
      OutSignal => OutpA0, OutSignalName => "OutpA0", OutTemp => OutpA0_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_OutpA0,
                           PathCondition => TRUE)),
      GlitchData => OutpA0_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity ec3iobuf0001
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity ec3iobuf0001 is
    port (Z: out Std_logic; PAD: in Std_logic);

    ATTRIBUTE Vital_Level0 OF ec3iobuf0001 : ENTITY IS TRUE;

  end ec3iobuf0001;

  architecture Structure of ec3iobuf0001 is
    component IB
      port (I: in Std_logic; O: out Std_logic);
    end component;
  begin
    INST1: IB
      port map (I=>PAD, O=>Z);
  end Structure;

-- entity INP_0_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_0_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_0_B";

      tipd_INP0  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP0_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP0 	: VitalDelayType := 0 ns;
      tpw_INP0_posedge	: VitalDelayType := 0 ns;
      tpw_INP0_negedge	: VitalDelayType := 0 ns;
      tpd_INP0_INP0	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns));

    port (PADDI: out Std_logic; INP0: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_0_B : ENTITY IS TRUE;

  end INP_0_B;

  architecture Structure of INP_0_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP0_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_0: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP0_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP0_ipd, INP0, tipd_INP0);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP0_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP0_INP0          	: x01 := '0';
    VARIABLE periodcheckinfo_INP0	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP0_ipd,
        TestSignalName => "INP0",
        Period => tperiod_INP0,
        PulseWidthHigh => tpw_INP0_posedge,
        PulseWidthLow => tpw_INP0_negedge,
        PeriodData => periodcheckinfo_INP0,
        Violation => tviol_INP0_INP0,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP0_ipd'last_event,
                           PathDelay => tpd_INP0_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity OutpD_2_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity OutpD_2_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "OutpD_2_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_OutpD2	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDO: in Std_logic; OutpD2: out Std_logic);

    ATTRIBUTE Vital_Level0 OF OutpD_2_B : ENTITY IS TRUE;

  end OutpD_2_B;

  architecture Structure of OutpD_2_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal OutpD2_out 	: std_logic := 'X';

    signal GNDI: Std_logic;
    component ec3iobuf
      port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);
    end component;
    component gnd
      port (PWR0: out Std_logic);
    end component;
  begin
    OutpD_pad_2: ec3iobuf
      port map (I=>PADDO_ipd, T=>GNDI, PAD=>OutpD2_out);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, OutpD2_out)
    VARIABLE OutpD2_zd         	: std_logic := 'X';
    VARIABLE OutpD2_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    OutpD2_zd 	:= OutpD2_out;

    VitalPathDelay01Z (
      OutSignal => OutpD2, OutSignalName => "OutpD2", OutTemp => OutpD2_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_OutpD2,
                           PathCondition => TRUE)),
      GlitchData => OutpD2_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity OutpD_1_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity OutpD_1_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "OutpD_1_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_OutpD1	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDO: in Std_logic; OutpD1: out Std_logic);

    ATTRIBUTE Vital_Level0 OF OutpD_1_B : ENTITY IS TRUE;

  end OutpD_1_B;

  architecture Structure of OutpD_1_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal OutpD1_out 	: std_logic := 'X';

    signal GNDI: Std_logic;
    component ec3iobuf
      port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);
    end component;
    component gnd
      port (PWR0: out Std_logic);
    end component;
  begin
    OutpD_pad_1: ec3iobuf
      port map (I=>PADDO_ipd, T=>GNDI, PAD=>OutpD1_out);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, OutpD1_out)
    VARIABLE OutpD1_zd         	: std_logic := 'X';
    VARIABLE OutpD1_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    OutpD1_zd 	:= OutpD1_out;

    VitalPathDelay01Z (
      OutSignal => OutpD1, OutSignalName => "OutpD1", OutTemp => OutpD1_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_OutpD1,
                           PathCondition => TRUE)),
      GlitchData => OutpD1_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity OutpD_0_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity OutpD_0_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "OutpD_0_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_OutpD0	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDO: in Std_logic; OutpD0: out Std_logic);

    ATTRIBUTE Vital_Level0 OF OutpD_0_B : ENTITY IS TRUE;

  end OutpD_0_B;

  architecture Structure of OutpD_0_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal OutpD0_out 	: std_logic := 'X';

    signal GNDI: Std_logic;
    component ec3iobuf
      port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);
    end component;
    component gnd
      port (PWR0: out Std_logic);
    end component;
  begin
    OutpD_pad_0: ec3iobuf
      port map (I=>PADDO_ipd, T=>GNDI, PAD=>OutpD0_out);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, OutpD0_out)
    VARIABLE OutpD0_zd         	: std_logic := 'X';
    VARIABLE OutpD0_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    OutpD0_zd 	:= OutpD0_out;

    VitalPathDelay01Z (
      OutSignal => OutpD0, OutSignalName => "OutpD0", OutTemp => OutpD0_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_OutpD0,
                           PathCondition => TRUE)),
      GlitchData => OutpD0_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity OutpC_2_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity OutpC_2_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "OutpC_2_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_OutpC2	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDO: in Std_logic; OutpC2: out Std_logic);

    ATTRIBUTE Vital_Level0 OF OutpC_2_B : ENTITY IS TRUE;

  end OutpC_2_B;

  architecture Structure of OutpC_2_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal OutpC2_out 	: std_logic := 'X';

    signal GNDI: Std_logic;
    component ec3iobuf
      port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);
    end component;
    component gnd
      port (PWR0: out Std_logic);
    end component;
  begin
    OutpC_pad_2: ec3iobuf
      port map (I=>PADDO_ipd, T=>GNDI, PAD=>OutpC2_out);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, OutpC2_out)
    VARIABLE OutpC2_zd         	: std_logic := 'X';
    VARIABLE OutpC2_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    OutpC2_zd 	:= OutpC2_out;

    VitalPathDelay01Z (
      OutSignal => OutpC2, OutSignalName => "OutpC2", OutTemp => OutpC2_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_OutpC2,
                           PathCondition => TRUE)),
      GlitchData => OutpC2_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity OutpC_1_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity OutpC_1_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "OutpC_1_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_OutpC1	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDO: in Std_logic; OutpC1: out Std_logic);

    ATTRIBUTE Vital_Level0 OF OutpC_1_B : ENTITY IS TRUE;

  end OutpC_1_B;

  architecture Structure of OutpC_1_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal OutpC1_out 	: std_logic := 'X';

    signal GNDI: Std_logic;
    component ec3iobuf
      port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);
    end component;
    component gnd
      port (PWR0: out Std_logic);
    end component;
  begin
    OutpC_pad_1: ec3iobuf
      port map (I=>PADDO_ipd, T=>GNDI, PAD=>OutpC1_out);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, OutpC1_out)
    VARIABLE OutpC1_zd         	: std_logic := 'X';
    VARIABLE OutpC1_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    OutpC1_zd 	:= OutpC1_out;

    VitalPathDelay01Z (
      OutSignal => OutpC1, OutSignalName => "OutpC1", OutTemp => OutpC1_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_OutpC1,
                           PathCondition => TRUE)),
      GlitchData => OutpC1_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity OutpC_0_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity OutpC_0_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "OutpC_0_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_OutpC0	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDO: in Std_logic; OutpC0: out Std_logic);

    ATTRIBUTE Vital_Level0 OF OutpC_0_B : ENTITY IS TRUE;

  end OutpC_0_B;

  architecture Structure of OutpC_0_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal OutpC0_out 	: std_logic := 'X';

    signal GNDI: Std_logic;
    component ec3iobuf
      port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);
    end component;
    component gnd
      port (PWR0: out Std_logic);
    end component;
  begin
    OutpC_pad_0: ec3iobuf
      port map (I=>PADDO_ipd, T=>GNDI, PAD=>OutpC0_out);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, OutpC0_out)
    VARIABLE OutpC0_zd         	: std_logic := 'X';
    VARIABLE OutpC0_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    OutpC0_zd 	:= OutpC0_out;

    VitalPathDelay01Z (
      OutSignal => OutpC0, OutSignalName => "OutpC0", OutTemp => OutpC0_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_OutpC0,
                           PathCondition => TRUE)),
      GlitchData => OutpC0_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity OutpB_2_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity OutpB_2_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "OutpB_2_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_OutpB2	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDO: in Std_logic; OutpB2: out Std_logic);

    ATTRIBUTE Vital_Level0 OF OutpB_2_B : ENTITY IS TRUE;

  end OutpB_2_B;

  architecture Structure of OutpB_2_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal OutpB2_out 	: std_logic := 'X';

    signal GNDI: Std_logic;
    component ec3iobuf
      port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);
    end component;
    component gnd
      port (PWR0: out Std_logic);
    end component;
  begin
    OutpB_pad_2: ec3iobuf
      port map (I=>PADDO_ipd, T=>GNDI, PAD=>OutpB2_out);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, OutpB2_out)
    VARIABLE OutpB2_zd         	: std_logic := 'X';
    VARIABLE OutpB2_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    OutpB2_zd 	:= OutpB2_out;

    VitalPathDelay01Z (
      OutSignal => OutpB2, OutSignalName => "OutpB2", OutTemp => OutpB2_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_OutpB2,
                           PathCondition => TRUE)),
      GlitchData => OutpB2_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity OutpB_1_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity OutpB_1_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "OutpB_1_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_OutpB1	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDO: in Std_logic; OutpB1: out Std_logic);

    ATTRIBUTE Vital_Level0 OF OutpB_1_B : ENTITY IS TRUE;

  end OutpB_1_B;

  architecture Structure of OutpB_1_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal OutpB1_out 	: std_logic := 'X';

    signal GNDI: Std_logic;
    component ec3iobuf
      port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);
    end component;
    component gnd
      port (PWR0: out Std_logic);
    end component;
  begin
    OutpB_pad_1: ec3iobuf
      port map (I=>PADDO_ipd, T=>GNDI, PAD=>OutpB1_out);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, OutpB1_out)
    VARIABLE OutpB1_zd         	: std_logic := 'X';
    VARIABLE OutpB1_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    OutpB1_zd 	:= OutpB1_out;

    VitalPathDelay01Z (
      OutSignal => OutpB1, OutSignalName => "OutpB1", OutTemp => OutpB1_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_OutpB1,
                           PathCondition => TRUE)),
      GlitchData => OutpB1_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity OutpB_0_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity OutpB_0_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "OutpB_0_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_OutpB0	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDO: in Std_logic; OutpB0: out Std_logic);

    ATTRIBUTE Vital_Level0 OF OutpB_0_B : ENTITY IS TRUE;

  end OutpB_0_B;

  architecture Structure of OutpB_0_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal OutpB0_out 	: std_logic := 'X';

    signal GNDI: Std_logic;
    component ec3iobuf
      port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);
    end component;
    component gnd
      port (PWR0: out Std_logic);
    end component;
  begin
    OutpB_pad_0: ec3iobuf
      port map (I=>PADDO_ipd, T=>GNDI, PAD=>OutpB0_out);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, OutpB0_out)
    VARIABLE OutpB0_zd         	: std_logic := 'X';
    VARIABLE OutpB0_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    OutpB0_zd 	:= OutpB0_out;

    VitalPathDelay01Z (
      OutSignal => OutpB0, OutSignalName => "OutpB0", OutTemp => OutpB0_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_OutpB0,
                           PathCondition => TRUE)),
      GlitchData => OutpB0_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity OutpA_2_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity OutpA_2_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "OutpA_2_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_OutpA2	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDO: in Std_logic; OutpA2: out Std_logic);

    ATTRIBUTE Vital_Level0 OF OutpA_2_B : ENTITY IS TRUE;

  end OutpA_2_B;

  architecture Structure of OutpA_2_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal OutpA2_out 	: std_logic := 'X';

    signal GNDI: Std_logic;
    component ec3iobuf
      port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);
    end component;
    component gnd
      port (PWR0: out Std_logic);
    end component;
  begin
    OutpA_pad_2: ec3iobuf
      port map (I=>PADDO_ipd, T=>GNDI, PAD=>OutpA2_out);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, OutpA2_out)
    VARIABLE OutpA2_zd         	: std_logic := 'X';
    VARIABLE OutpA2_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    OutpA2_zd 	:= OutpA2_out;

    VitalPathDelay01Z (
      OutSignal => OutpA2, OutSignalName => "OutpA2", OutTemp => OutpA2_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_OutpA2,
                           PathCondition => TRUE)),
      GlitchData => OutpA2_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity OutpA_1_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity OutpA_1_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "OutpA_1_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_OutpA1	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDO: in Std_logic; OutpA1: out Std_logic);

    ATTRIBUTE Vital_Level0 OF OutpA_1_B : ENTITY IS TRUE;

  end OutpA_1_B;

  architecture Structure of OutpA_1_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal OutpA1_out 	: std_logic := 'X';

    signal GNDI: Std_logic;
    component ec3iobuf
      port (I: in Std_logic; T: in Std_logic; PAD: out Std_logic);
    end component;
    component gnd
      port (PWR0: out Std_logic);
    end component;
  begin
    OutpA_pad_1: ec3iobuf
      port map (I=>PADDO_ipd, T=>GNDI, PAD=>OutpA1_out);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, OutpA1_out)
    VARIABLE OutpA1_zd         	: std_logic := 'X';
    VARIABLE OutpA1_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    OutpA1_zd 	:= OutpA1_out;

    VitalPathDelay01Z (
      OutSignal => OutpA1, OutSignalName => "OutpA1", OutTemp => OutpA1_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_OutpA1,
                           PathCondition => TRUE)),
      GlitchData => OutpA1_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity ec3iobuf0002
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity ec3iobuf0002 is
    port (Z: out Std_logic; PAD: in Std_logic);

    ATTRIBUTE Vital_Level0 OF ec3iobuf0002 : ENTITY IS TRUE;

  end ec3iobuf0002;

  architecture Structure of ec3iobuf0002 is
    component IBPU
      port (I: in Std_logic; O: out Std_logic);
    end component;
  begin
    INST1: IBPU
      port map (I=>PAD, O=>Z);
  end Structure;

-- entity InpDB
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity InpDB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "InpDB";

      tipd_InpDS  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_InpDS_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_InpDS 	: VitalDelayType := 0 ns;
      tpw_InpDS_posedge	: VitalDelayType := 0 ns;
      tpw_InpDS_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; InpDS: in Std_logic);

    ATTRIBUTE Vital_Level0 OF InpDB : ENTITY IS TRUE;

  end InpDB;

  architecture Structure of InpDB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal InpDS_ipd 	: std_logic := 'X';

    component ec3iobuf0002
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    InpD_pad: ec3iobuf0002
      port map (Z=>PADDI_out, PAD=>InpDS_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(InpDS_ipd, InpDS, tipd_InpDS);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, InpDS_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_InpDS_InpDS          	: x01 := '0';
    VARIABLE periodcheckinfo_InpDS	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => InpDS_ipd,
        TestSignalName => "InpDS",
        Period => tperiod_InpDS,
        PulseWidthHigh => tpw_InpDS_posedge,
        PulseWidthLow => tpw_InpDS_negedge,
        PeriodData => periodcheckinfo_InpDS,
        Violation => tviol_InpDS_InpDS,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => InpDS_ipd'last_event,
                           PathDelay => tpd_InpDS_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity InpCB
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity InpCB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "InpCB";

      tipd_InpCS  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_InpCS_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_InpCS 	: VitalDelayType := 0 ns;
      tpw_InpCS_posedge	: VitalDelayType := 0 ns;
      tpw_InpCS_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; InpCS: in Std_logic);

    ATTRIBUTE Vital_Level0 OF InpCB : ENTITY IS TRUE;

  end InpCB;

  architecture Structure of InpCB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal InpCS_ipd 	: std_logic := 'X';

    component ec3iobuf0002
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    InpC_pad: ec3iobuf0002
      port map (Z=>PADDI_out, PAD=>InpCS_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(InpCS_ipd, InpCS, tipd_InpCS);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, InpCS_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_InpCS_InpCS          	: x01 := '0';
    VARIABLE periodcheckinfo_InpCS	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => InpCS_ipd,
        TestSignalName => "InpCS",
        Period => tperiod_InpCS,
        PulseWidthHigh => tpw_InpCS_posedge,
        PulseWidthLow => tpw_InpCS_negedge,
        PeriodData => periodcheckinfo_InpCS,
        Violation => tviol_InpCS_InpCS,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => InpCS_ipd'last_event,
                           PathDelay => tpd_InpCS_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity InpBB
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity InpBB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "InpBB";

      tipd_InpBS  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_InpBS_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_InpBS 	: VitalDelayType := 0 ns;
      tpw_InpBS_posedge	: VitalDelayType := 0 ns;
      tpw_InpBS_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; InpBS: in Std_logic);

    ATTRIBUTE Vital_Level0 OF InpBB : ENTITY IS TRUE;

  end InpBB;

  architecture Structure of InpBB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal InpBS_ipd 	: std_logic := 'X';

    component ec3iobuf0002
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    InpB_pad: ec3iobuf0002
      port map (Z=>PADDI_out, PAD=>InpBS_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(InpBS_ipd, InpBS, tipd_InpBS);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, InpBS_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_InpBS_InpBS          	: x01 := '0';
    VARIABLE periodcheckinfo_InpBS	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => InpBS_ipd,
        TestSignalName => "InpBS",
        Period => tperiod_InpBS,
        PulseWidthHigh => tpw_InpBS_posedge,
        PulseWidthLow => tpw_InpBS_negedge,
        PeriodData => periodcheckinfo_InpBS,
        Violation => tviol_InpBS_InpBS,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => InpBS_ipd'last_event,
                           PathDelay => tpd_InpBS_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity InpAB
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity InpAB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "InpAB";

      tipd_InpAS  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_InpAS_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_InpAS 	: VitalDelayType := 0 ns;
      tpw_InpAS_posedge	: VitalDelayType := 0 ns;
      tpw_InpAS_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; InpAS: in Std_logic);

    ATTRIBUTE Vital_Level0 OF InpAB : ENTITY IS TRUE;

  end InpAB;

  architecture Structure of InpAB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal InpAS_ipd 	: std_logic := 'X';

    component ec3iobuf0002
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    InpA_pad: ec3iobuf0002
      port map (Z=>PADDI_out, PAD=>InpAS_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(InpAS_ipd, InpAS, tipd_InpAS);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, InpAS_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_InpAS_InpAS          	: x01 := '0';
    VARIABLE periodcheckinfo_InpAS	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => InpAS_ipd,
        TestSignalName => "InpAS",
        Period => tperiod_InpAS,
        PulseWidthHigh => tpw_InpAS_posedge,
        PulseWidthLow => tpw_InpAS_negedge,
        PeriodData => periodcheckinfo_InpAS,
        Violation => tviol_InpAS_InpAS,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => InpAS_ipd'last_event,
                           PathDelay => tpd_InpAS_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_53_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_53_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_53_B";

      tipd_INP53  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP53_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP53 	: VitalDelayType := 0 ns;
      tpw_INP53_posedge	: VitalDelayType := 0 ns;
      tpw_INP53_negedge	: VitalDelayType := 0 ns;
      tpd_INP53_INP53	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP53: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_53_B : ENTITY IS TRUE;

  end INP_53_B;

  architecture Structure of INP_53_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP53_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_53: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP53_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP53_ipd, INP53, tipd_INP53);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP53_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP53_INP53          	: x01 := '0';
    VARIABLE periodcheckinfo_INP53	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP53_ipd,
        TestSignalName => "INP53",
        Period => tperiod_INP53,
        PulseWidthHigh => tpw_INP53_posedge,
        PulseWidthLow => tpw_INP53_negedge,
        PeriodData => periodcheckinfo_INP53,
        Violation => tviol_INP53_INP53,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP53_ipd'last_event,
                           PathDelay => tpd_INP53_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_52_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_52_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_52_B";

      tipd_INP52  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP52_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP52 	: VitalDelayType := 0 ns;
      tpw_INP52_posedge	: VitalDelayType := 0 ns;
      tpw_INP52_negedge	: VitalDelayType := 0 ns;
      tpd_INP52_INP52	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP52: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_52_B : ENTITY IS TRUE;

  end INP_52_B;

  architecture Structure of INP_52_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP52_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_52: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP52_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP52_ipd, INP52, tipd_INP52);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP52_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP52_INP52          	: x01 := '0';
    VARIABLE periodcheckinfo_INP52	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP52_ipd,
        TestSignalName => "INP52",
        Period => tperiod_INP52,
        PulseWidthHigh => tpw_INP52_posedge,
        PulseWidthLow => tpw_INP52_negedge,
        PeriodData => periodcheckinfo_INP52,
        Violation => tviol_INP52_INP52,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP52_ipd'last_event,
                           PathDelay => tpd_INP52_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_51_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_51_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_51_B";

      tipd_INP51  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP51_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP51 	: VitalDelayType := 0 ns;
      tpw_INP51_posedge	: VitalDelayType := 0 ns;
      tpw_INP51_negedge	: VitalDelayType := 0 ns;
      tpd_INP51_INP51	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP51: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_51_B : ENTITY IS TRUE;

  end INP_51_B;

  architecture Structure of INP_51_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP51_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_51: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP51_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP51_ipd, INP51, tipd_INP51);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP51_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP51_INP51          	: x01 := '0';
    VARIABLE periodcheckinfo_INP51	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP51_ipd,
        TestSignalName => "INP51",
        Period => tperiod_INP51,
        PulseWidthHigh => tpw_INP51_posedge,
        PulseWidthLow => tpw_INP51_negedge,
        PeriodData => periodcheckinfo_INP51,
        Violation => tviol_INP51_INP51,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP51_ipd'last_event,
                           PathDelay => tpd_INP51_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_50_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_50_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_50_B";

      tipd_INP50  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP50_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP50 	: VitalDelayType := 0 ns;
      tpw_INP50_posedge	: VitalDelayType := 0 ns;
      tpw_INP50_negedge	: VitalDelayType := 0 ns;
      tpd_INP50_INP50	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP50: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_50_B : ENTITY IS TRUE;

  end INP_50_B;

  architecture Structure of INP_50_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP50_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_50: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP50_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP50_ipd, INP50, tipd_INP50);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP50_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP50_INP50          	: x01 := '0';
    VARIABLE periodcheckinfo_INP50	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP50_ipd,
        TestSignalName => "INP50",
        Period => tperiod_INP50,
        PulseWidthHigh => tpw_INP50_posedge,
        PulseWidthLow => tpw_INP50_negedge,
        PeriodData => periodcheckinfo_INP50,
        Violation => tviol_INP50_INP50,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP50_ipd'last_event,
                           PathDelay => tpd_INP50_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_49_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_49_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_49_B";

      tipd_INP49  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP49_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP49 	: VitalDelayType := 0 ns;
      tpw_INP49_posedge	: VitalDelayType := 0 ns;
      tpw_INP49_negedge	: VitalDelayType := 0 ns;
      tpd_INP49_INP49	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP49: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_49_B : ENTITY IS TRUE;

  end INP_49_B;

  architecture Structure of INP_49_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP49_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_49: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP49_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP49_ipd, INP49, tipd_INP49);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP49_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP49_INP49          	: x01 := '0';
    VARIABLE periodcheckinfo_INP49	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP49_ipd,
        TestSignalName => "INP49",
        Period => tperiod_INP49,
        PulseWidthHigh => tpw_INP49_posedge,
        PulseWidthLow => tpw_INP49_negedge,
        PeriodData => periodcheckinfo_INP49,
        Violation => tviol_INP49_INP49,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP49_ipd'last_event,
                           PathDelay => tpd_INP49_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_48_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_48_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_48_B";

      tipd_INP48  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP48_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP48 	: VitalDelayType := 0 ns;
      tpw_INP48_posedge	: VitalDelayType := 0 ns;
      tpw_INP48_negedge	: VitalDelayType := 0 ns;
      tpd_INP48_INP48	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP48: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_48_B : ENTITY IS TRUE;

  end INP_48_B;

  architecture Structure of INP_48_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP48_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_48: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP48_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP48_ipd, INP48, tipd_INP48);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP48_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP48_INP48          	: x01 := '0';
    VARIABLE periodcheckinfo_INP48	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP48_ipd,
        TestSignalName => "INP48",
        Period => tperiod_INP48,
        PulseWidthHigh => tpw_INP48_posedge,
        PulseWidthLow => tpw_INP48_negedge,
        PeriodData => periodcheckinfo_INP48,
        Violation => tviol_INP48_INP48,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP48_ipd'last_event,
                           PathDelay => tpd_INP48_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_36_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_36_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_36_B";

      tipd_INP36  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP36_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP36 	: VitalDelayType := 0 ns;
      tpw_INP36_posedge	: VitalDelayType := 0 ns;
      tpw_INP36_negedge	: VitalDelayType := 0 ns;
      tpd_INP36_INP36	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP36: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_36_B : ENTITY IS TRUE;

  end INP_36_B;

  architecture Structure of INP_36_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP36_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_36: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP36_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP36_ipd, INP36, tipd_INP36);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP36_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP36_INP36          	: x01 := '0';
    VARIABLE periodcheckinfo_INP36	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP36_ipd,
        TestSignalName => "INP36",
        Period => tperiod_INP36,
        PulseWidthHigh => tpw_INP36_posedge,
        PulseWidthLow => tpw_INP36_negedge,
        PeriodData => periodcheckinfo_INP36,
        Violation => tviol_INP36_INP36,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP36_ipd'last_event,
                           PathDelay => tpd_INP36_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_35_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_35_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_35_B";

      tipd_INP35  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP35_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP35 	: VitalDelayType := 0 ns;
      tpw_INP35_posedge	: VitalDelayType := 0 ns;
      tpw_INP35_negedge	: VitalDelayType := 0 ns;
      tpd_INP35_INP35	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP35: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_35_B : ENTITY IS TRUE;

  end INP_35_B;

  architecture Structure of INP_35_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP35_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_35: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP35_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP35_ipd, INP35, tipd_INP35);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP35_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP35_INP35          	: x01 := '0';
    VARIABLE periodcheckinfo_INP35	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP35_ipd,
        TestSignalName => "INP35",
        Period => tperiod_INP35,
        PulseWidthHigh => tpw_INP35_posedge,
        PulseWidthLow => tpw_INP35_negedge,
        PeriodData => periodcheckinfo_INP35,
        Violation => tviol_INP35_INP35,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP35_ipd'last_event,
                           PathDelay => tpd_INP35_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_34_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_34_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_34_B";

      tipd_INP34  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP34_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP34 	: VitalDelayType := 0 ns;
      tpw_INP34_posedge	: VitalDelayType := 0 ns;
      tpw_INP34_negedge	: VitalDelayType := 0 ns;
      tpd_INP34_INP34	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP34: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_34_B : ENTITY IS TRUE;

  end INP_34_B;

  architecture Structure of INP_34_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP34_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_34: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP34_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP34_ipd, INP34, tipd_INP34);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP34_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP34_INP34          	: x01 := '0';
    VARIABLE periodcheckinfo_INP34	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP34_ipd,
        TestSignalName => "INP34",
        Period => tperiod_INP34,
        PulseWidthHigh => tpw_INP34_posedge,
        PulseWidthLow => tpw_INP34_negedge,
        PeriodData => periodcheckinfo_INP34,
        Violation => tviol_INP34_INP34,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP34_ipd'last_event,
                           PathDelay => tpd_INP34_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_33_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_33_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_33_B";

      tipd_INP33  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP33_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP33 	: VitalDelayType := 0 ns;
      tpw_INP33_posedge	: VitalDelayType := 0 ns;
      tpw_INP33_negedge	: VitalDelayType := 0 ns;
      tpd_INP33_INP33	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP33: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_33_B : ENTITY IS TRUE;

  end INP_33_B;

  architecture Structure of INP_33_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP33_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_33: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP33_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP33_ipd, INP33, tipd_INP33);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP33_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP33_INP33          	: x01 := '0';
    VARIABLE periodcheckinfo_INP33	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP33_ipd,
        TestSignalName => "INP33",
        Period => tperiod_INP33,
        PulseWidthHigh => tpw_INP33_posedge,
        PulseWidthLow => tpw_INP33_negedge,
        PeriodData => periodcheckinfo_INP33,
        Violation => tviol_INP33_INP33,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP33_ipd'last_event,
                           PathDelay => tpd_INP33_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_32_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_32_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_32_B";

      tipd_INP32  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP32_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP32 	: VitalDelayType := 0 ns;
      tpw_INP32_posedge	: VitalDelayType := 0 ns;
      tpw_INP32_negedge	: VitalDelayType := 0 ns;
      tpd_INP32_INP32	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP32: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_32_B : ENTITY IS TRUE;

  end INP_32_B;

  architecture Structure of INP_32_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP32_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_32: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP32_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP32_ipd, INP32, tipd_INP32);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP32_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP32_INP32          	: x01 := '0';
    VARIABLE periodcheckinfo_INP32	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP32_ipd,
        TestSignalName => "INP32",
        Period => tperiod_INP32,
        PulseWidthHigh => tpw_INP32_posedge,
        PulseWidthLow => tpw_INP32_negedge,
        PeriodData => periodcheckinfo_INP32,
        Violation => tviol_INP32_INP32,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP32_ipd'last_event,
                           PathDelay => tpd_INP32_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_19_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_19_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_19_B";

      tipd_INP19  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP19_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP19 	: VitalDelayType := 0 ns;
      tpw_INP19_posedge	: VitalDelayType := 0 ns;
      tpw_INP19_negedge	: VitalDelayType := 0 ns;
      tpd_INP19_INP19	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP19: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_19_B : ENTITY IS TRUE;

  end INP_19_B;

  architecture Structure of INP_19_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP19_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_19: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP19_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP19_ipd, INP19, tipd_INP19);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP19_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP19_INP19          	: x01 := '0';
    VARIABLE periodcheckinfo_INP19	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP19_ipd,
        TestSignalName => "INP19",
        Period => tperiod_INP19,
        PulseWidthHigh => tpw_INP19_posedge,
        PulseWidthLow => tpw_INP19_negedge,
        PeriodData => periodcheckinfo_INP19,
        Violation => tviol_INP19_INP19,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP19_ipd'last_event,
                           PathDelay => tpd_INP19_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_18_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_18_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_18_B";

      tipd_INP18  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP18_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP18 	: VitalDelayType := 0 ns;
      tpw_INP18_posedge	: VitalDelayType := 0 ns;
      tpw_INP18_negedge	: VitalDelayType := 0 ns;
      tpd_INP18_INP18	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP18: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_18_B : ENTITY IS TRUE;

  end INP_18_B;

  architecture Structure of INP_18_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP18_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_18: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP18_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP18_ipd, INP18, tipd_INP18);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP18_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP18_INP18          	: x01 := '0';
    VARIABLE periodcheckinfo_INP18	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP18_ipd,
        TestSignalName => "INP18",
        Period => tperiod_INP18,
        PulseWidthHigh => tpw_INP18_posedge,
        PulseWidthLow => tpw_INP18_negedge,
        PeriodData => periodcheckinfo_INP18,
        Violation => tviol_INP18_INP18,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP18_ipd'last_event,
                           PathDelay => tpd_INP18_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_17_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_17_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_17_B";

      tipd_INP17  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP17_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP17 	: VitalDelayType := 0 ns;
      tpw_INP17_posedge	: VitalDelayType := 0 ns;
      tpw_INP17_negedge	: VitalDelayType := 0 ns;
      tpd_INP17_INP17	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP17: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_17_B : ENTITY IS TRUE;

  end INP_17_B;

  architecture Structure of INP_17_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP17_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_17: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP17_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP17_ipd, INP17, tipd_INP17);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP17_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP17_INP17          	: x01 := '0';
    VARIABLE periodcheckinfo_INP17	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP17_ipd,
        TestSignalName => "INP17",
        Period => tperiod_INP17,
        PulseWidthHigh => tpw_INP17_posedge,
        PulseWidthLow => tpw_INP17_negedge,
        PeriodData => periodcheckinfo_INP17,
        Violation => tviol_INP17_INP17,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP17_ipd'last_event,
                           PathDelay => tpd_INP17_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_16_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_16_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_16_B";

      tipd_INP16  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP16_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP16 	: VitalDelayType := 0 ns;
      tpw_INP16_posedge	: VitalDelayType := 0 ns;
      tpw_INP16_negedge	: VitalDelayType := 0 ns;
      tpd_INP16_INP16	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns)
        );

    port (PADDI: out Std_logic; INP16: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_16_B : ENTITY IS TRUE;

  end INP_16_B;

  architecture Structure of INP_16_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP16_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_16: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP16_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP16_ipd, INP16, tipd_INP16);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP16_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP16_INP16          	: x01 := '0';
    VARIABLE periodcheckinfo_INP16	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP16_ipd,
        TestSignalName => "INP16",
        Period => tperiod_INP16,
        PulseWidthHigh => tpw_INP16_posedge,
        PulseWidthLow => tpw_INP16_negedge,
        PeriodData => periodcheckinfo_INP16,
        Violation => tviol_INP16_INP16,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP16_ipd'last_event,
                           PathDelay => tpd_INP16_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_2_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_2_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_2_B";

      tipd_INP2  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP2_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP2 	: VitalDelayType := 0 ns;
      tpw_INP2_posedge	: VitalDelayType := 0 ns;
      tpw_INP2_negedge	: VitalDelayType := 0 ns;
      tpd_INP2_INP2	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns));

    port (PADDI: out Std_logic; INP2: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_2_B : ENTITY IS TRUE;

  end INP_2_B;

  architecture Structure of INP_2_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP2_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_2: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP2_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP2_ipd, INP2, tipd_INP2);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP2_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP2_INP2          	: x01 := '0';
    VARIABLE periodcheckinfo_INP2	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP2_ipd,
        TestSignalName => "INP2",
        Period => tperiod_INP2,
        PulseWidthHigh => tpw_INP2_posedge,
        PulseWidthLow => tpw_INP2_negedge,
        PeriodData => periodcheckinfo_INP2,
        Violation => tviol_INP2_INP2,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP2_ipd'last_event,
                           PathDelay => tpd_INP2_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity INP_1_B
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity INP_1_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "INP_1_B";

      tipd_INP1  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_INP1_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_INP1 	: VitalDelayType := 0 ns;
      tpw_INP1_posedge	: VitalDelayType := 0 ns;
      tpw_INP1_negedge	: VitalDelayType := 0 ns;
      tpd_INP1_INP1	 : VitalDelayType01Z := (0 ns, 0 ns, 0 ns , 0 ns, 0 ns, 0 ns));

    port (PADDI: out Std_logic; INP1: in Std_logic);

    ATTRIBUTE Vital_Level0 OF INP_1_B : ENTITY IS TRUE;

  end INP_1_B;

  architecture Structure of INP_1_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal INP1_ipd 	: std_logic := 'X';

    component ec3iobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    INP_pad_1: ec3iobuf0001
      port map (Z=>PADDI_out, PAD=>INP1_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(INP1_ipd, INP1, tipd_INP1);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, INP1_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_INP1_INP1          	: x01 := '0';
    VARIABLE periodcheckinfo_INP1	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => INP1_ipd,
        TestSignalName => "INP1",
        Period => tperiod_INP1,
        PulseWidthHigh => tpw_INP1_posedge,
        PulseWidthLow => tpw_INP1_negedge,
        PeriodData => periodcheckinfo_INP1,
        Violation => tviol_INP1_INP1,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => INP1_ipd'last_event,
                           PathDelay => tpd_INP1_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity Top
  library IEEE, vital2000, ECP3;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP3.COMPONENTS.ALL;

  entity Top is
    port (INP: in Std_logic_vector (63 downto 0); InpA: in Std_logic; 
          InpB: in Std_logic; InpC: in Std_logic; InpD: in Std_logic; 
          OutpA: out Std_logic_vector (2 downto 0); 
          OutpB: out Std_logic_vector (2 downto 0); 
          OutpC: out Std_logic_vector (2 downto 0); 
          OutpD: out Std_logic_vector (2 downto 0));



  end Top;

  architecture Structure of Top is
    signal INP_c_53: Std_logic;
    signal INP_c_52: Std_logic;
    signal INP_c_49: Std_logic;
    signal INP_c_48: Std_logic;
    signal U36_A_OUT_3: Std_logic;
    signal INP_c_51: Std_logic;
    signal INP_c_50: Std_logic;
    signal OutpD_c_0: Std_logic;
    signal INP_c_34: Std_logic;
    signal INP_c_33: Std_logic;
    signal U25_A_OUT_1: Std_logic;
    signal INP_c_36: Std_logic;
    signal INP_c_35: Std_logic;
    signal INP_c_32: Std_logic;
    signal OutpC_c_0: Std_logic;
    signal U37_A_OUT_3: Std_logic;
    signal OutpD_c_2: Std_logic;
    signal U26_A_OUT_0: Std_logic;
    signal OutpC_c_2: Std_logic;
    signal INP_c_19: Std_logic;
    signal INP_c_18: Std_logic;
    signal INP_c_17: Std_logic;
    signal INP_c_16: Std_logic;
    signal InpB_c: Std_logic;
    signal OutpB_c_0_1: Std_logic;
    signal OutpB_c_0: Std_logic;
    signal INP_c_2: Std_logic;
    signal INP_c_1: Std_logic;
    signal INP_c_0: Std_logic;
    signal InpA_c: Std_logic;
    signal OutpA_c_0_1: Std_logic;
    signal OutpA_c_0: Std_logic;
    signal InpD_c: Std_logic;
    signal OutpD_c_0_1: Std_logic;
    signal InpC_c: Std_logic;
    signal OutpC_c_0_1: Std_logic;
    signal OutpB_c_2: Std_logic;
    signal OutpA_c_2: Std_logic;
    signal VCCI: Std_logic;
    component VHI
      port (Z: out Std_logic);
    end component;
    component PUR
      port (PUR: in Std_logic);
    end component;
    component GSR
      port (GSR: in Std_logic);
    end component;
    component OutpA_0_B
      port (PADDO: in Std_logic; OutpA0: out Std_logic);
    end component;
    component INP_0_B
      port (PADDI: out Std_logic; INP0: in Std_logic);
    end component;
    component OutpD_2_B
      port (PADDO: in Std_logic; OutpD2: out Std_logic);
    end component;
    component OutpD_1_B
      port (PADDO: in Std_logic; OutpD1: out Std_logic);
    end component;
    component OutpD_0_B
      port (PADDO: in Std_logic; OutpD0: out Std_logic);
    end component;
    component OutpC_2_B
      port (PADDO: in Std_logic; OutpC2: out Std_logic);
    end component;
    component OutpC_1_B
      port (PADDO: in Std_logic; OutpC1: out Std_logic);
    end component;
    component OutpC_0_B
      port (PADDO: in Std_logic; OutpC0: out Std_logic);
    end component;
    component OutpB_2_B
      port (PADDO: in Std_logic; OutpB2: out Std_logic);
    end component;
    component OutpB_1_B
      port (PADDO: in Std_logic; OutpB1: out Std_logic);
    end component;
    component OutpB_0_B
      port (PADDO: in Std_logic; OutpB0: out Std_logic);
    end component;
    component OutpA_2_B
      port (PADDO: in Std_logic; OutpA2: out Std_logic);
    end component;
    component OutpA_1_B
      port (PADDO: in Std_logic; OutpA1: out Std_logic);
    end component;
    component InpDB
      port (PADDI: out Std_logic; InpDS: in Std_logic);
    end component;
    component InpCB
      port (PADDI: out Std_logic; InpCS: in Std_logic);
    end component;
    component InpBB
      port (PADDI: out Std_logic; InpBS: in Std_logic);
    end component;
    component InpAB
      port (PADDI: out Std_logic; InpAS: in Std_logic);
    end component;
    component INP_53_B
      port (PADDI: out Std_logic; INP53: in Std_logic);
    end component;
    component INP_52_B
      port (PADDI: out Std_logic; INP52: in Std_logic);
    end component;
    component INP_51_B
      port (PADDI: out Std_logic; INP51: in Std_logic);
    end component;
    component INP_50_B
      port (PADDI: out Std_logic; INP50: in Std_logic);
    end component;
    component INP_49_B
      port (PADDI: out Std_logic; INP49: in Std_logic);
    end component;
    component INP_48_B
      port (PADDI: out Std_logic; INP48: in Std_logic);
    end component;
    component INP_36_B
      port (PADDI: out Std_logic; INP36: in Std_logic);
    end component;
    component INP_35_B
      port (PADDI: out Std_logic; INP35: in Std_logic);
    end component;
    component INP_34_B
      port (PADDI: out Std_logic; INP34: in Std_logic);
    end component;
    component INP_33_B
      port (PADDI: out Std_logic; INP33: in Std_logic);
    end component;
    component INP_32_B
      port (PADDI: out Std_logic; INP32: in Std_logic);
    end component;
    component INP_19_B
      port (PADDI: out Std_logic; INP19: in Std_logic);
    end component;
    component INP_18_B
      port (PADDI: out Std_logic; INP18: in Std_logic);
    end component;
    component INP_17_B
      port (PADDI: out Std_logic; INP17: in Std_logic);
    end component;
    component INP_16_B
      port (PADDI: out Std_logic; INP16: in Std_logic);
    end component;
    component INP_2_B
      port (PADDI: out Std_logic; INP2: in Std_logic);
    end component;
    component INP_1_B
      port (PADDI: out Std_logic; INP1: in Std_logic);
    end component;
  begin
    U36_SLICE_0I: SLOGICB
      generic map (LUT0_INITVAL=>X"8080", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>INP_c_48, B1=>INP_c_49, 
                C1=>INP_c_52, D1=>INP_c_53, DI1=>'X', DI0=>'X', A0=>INP_c_50, 
                B0=>INP_c_51, C0=>U36_A_OUT_3, D0=>'X', M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>U36_A_OUT_3, Q1=>open, 
                OFX0=>open, F0=>OutpD_c_0, Q0=>open);
    U25_SLICE_1I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"8888")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>INP_c_33, B1=>INP_c_34, 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>INP_c_32, 
                B0=>INP_c_35, C0=>INP_c_36, D0=>U25_A_OUT_1, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>U25_A_OUT_1, Q1=>open, 
                OFX0=>open, F0=>OutpC_c_0, Q0=>open);
    U37_SLICE_2I: SLOGICB
      generic map (LUT0_INITVAL=>X"8080", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>INP_c_48, B1=>INP_c_49, 
                C1=>INP_c_52, D1=>INP_c_53, DI1=>'X', DI0=>'X', A0=>INP_c_50, 
                B0=>INP_c_51, C0=>U37_A_OUT_3, D0=>'X', M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>U37_A_OUT_3, Q1=>open, 
                OFX0=>open, F0=>OutpD_c_2, Q0=>open);
    U26_SLICE_3I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"8888")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>INP_c_32, B1=>INP_c_33, 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>INP_c_34, 
                B0=>INP_c_35, C0=>INP_c_36, D0=>U26_A_OUT_0, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>U26_A_OUT_0, Q1=>open, 
                OFX0=>open, F0=>OutpC_c_2, Q0=>open);
    SLICE_4I: SLOGICB
      generic map (LUT0_INITVAL=>X"AEAE", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>INP_c_16, B1=>INP_c_17, 
                C1=>INP_c_18, D1=>INP_c_19, DI1=>'X', DI0=>'X', A0=>OutpB_c_0, 
                B0=>OutpB_c_0_1, C0=>InpB_c, D0=>'X', M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>OutpB_c_0, Q1=>open, 
                OFX0=>open, F0=>OutpB_c_0_1, Q0=>open);
    SLICE_5I: SLOGICB
      generic map (LUT0_INITVAL=>X"AEAE", LUT1_INITVAL=>X"8080")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>INP_c_0, B1=>INP_c_1, 
                C1=>INP_c_2, D1=>'X', DI1=>'X', DI0=>'X', A0=>OutpA_c_0, 
                B0=>OutpA_c_0_1, C0=>InpA_c, D0=>'X', M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>OutpA_c_0, Q1=>open, 
                OFX0=>open, F0=>OutpA_c_0_1, Q0=>open);
    SLICE_6I: SLOGICB
      generic map (LUT0_INITVAL=>X"AEAE")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>OutpD_c_0, B0=>OutpD_c_0_1, 
                C0=>InpD_c, D0=>'X', M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>open, OFX0=>open, F0=>OutpD_c_0_1, 
                Q0=>open);
    SLICE_7I: SLOGICB
      generic map (LUT0_INITVAL=>X"AEAE")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>OutpC_c_0, B0=>OutpC_c_0_1, 
                C0=>InpC_c, D0=>'X', M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>open, OFX0=>open, F0=>OutpC_c_0_1, 
                Q0=>open);
    U15_SLICE_8I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>INP_c_16, B0=>INP_c_17, 
                C0=>INP_c_18, D0=>INP_c_19, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>OutpB_c_2, Q0=>open);
    U4_SLICE_9I: SLOGICB
      generic map (LUT0_INITVAL=>X"8080")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>INP_c_0, B0=>INP_c_1, 
                C0=>INP_c_2, D0=>'X', M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>open, OFX0=>open, F0=>OutpA_c_2, 
                Q0=>open);
    OutpA_0_I: OutpA_0_B
      port map (PADDO=>OutpA_c_0, OutpA0=>OutpA(0));
    INP_0_I: INP_0_B
      port map (PADDI=>INP_c_0, INP0=>INP(0));
    OutpD_2_I: OutpD_2_B
      port map (PADDO=>OutpD_c_2, OutpD2=>OutpD(2));
    OutpD_1_I: OutpD_1_B
      port map (PADDO=>OutpD_c_0_1, OutpD1=>OutpD(1));
    OutpD_0_I: OutpD_0_B
      port map (PADDO=>OutpD_c_0, OutpD0=>OutpD(0));
    OutpC_2_I: OutpC_2_B
      port map (PADDO=>OutpC_c_2, OutpC2=>OutpC(2));
    OutpC_1_I: OutpC_1_B
      port map (PADDO=>OutpC_c_0_1, OutpC1=>OutpC(1));
    OutpC_0_I: OutpC_0_B
      port map (PADDO=>OutpC_c_0, OutpC0=>OutpC(0));
    OutpB_2_I: OutpB_2_B
      port map (PADDO=>OutpB_c_2, OutpB2=>OutpB(2));
    OutpB_1_I: OutpB_1_B
      port map (PADDO=>OutpB_c_0_1, OutpB1=>OutpB(1));
    OutpB_0_I: OutpB_0_B
      port map (PADDO=>OutpB_c_0, OutpB0=>OutpB(0));
    OutpA_2_I: OutpA_2_B
      port map (PADDO=>OutpA_c_2, OutpA2=>OutpA(2));
    OutpA_1_I: OutpA_1_B
      port map (PADDO=>OutpA_c_0_1, OutpA1=>OutpA(1));
    InpDI: InpDB
      port map (PADDI=>InpD_c, InpDS=>InpD);
    InpCI: InpCB
      port map (PADDI=>InpC_c, InpCS=>InpC);
    InpBI: InpBB
      port map (PADDI=>InpB_c, InpBS=>InpB);
    InpAI: InpAB
      port map (PADDI=>InpA_c, InpAS=>InpA);
    INP_53_I: INP_53_B
      port map (PADDI=>INP_c_53, INP53=>INP(53));
    INP_52_I: INP_52_B
      port map (PADDI=>INP_c_52, INP52=>INP(52));
    INP_51_I: INP_51_B
      port map (PADDI=>INP_c_51, INP51=>INP(51));
    INP_50_I: INP_50_B
      port map (PADDI=>INP_c_50, INP50=>INP(50));
    INP_49_I: INP_49_B
      port map (PADDI=>INP_c_49, INP49=>INP(49));
    INP_48_I: INP_48_B
      port map (PADDI=>INP_c_48, INP48=>INP(48));
    INP_36_I: INP_36_B
      port map (PADDI=>INP_c_36, INP36=>INP(36));
    INP_35_I: INP_35_B
      port map (PADDI=>INP_c_35, INP35=>INP(35));
    INP_34_I: INP_34_B
      port map (PADDI=>INP_c_34, INP34=>INP(34));
    INP_33_I: INP_33_B
      port map (PADDI=>INP_c_33, INP33=>INP(33));
    INP_32_I: INP_32_B
      port map (PADDI=>INP_c_32, INP32=>INP(32));
    INP_19_I: INP_19_B
      port map (PADDI=>INP_c_19, INP19=>INP(19));
    INP_18_I: INP_18_B
      port map (PADDI=>INP_c_18, INP18=>INP(18));
    INP_17_I: INP_17_B
      port map (PADDI=>INP_c_17, INP17=>INP(17));
    INP_16_I: INP_16_B
      port map (PADDI=>INP_c_16, INP16=>INP(16));
    INP_2_I: INP_2_B
      port map (PADDI=>INP_c_2, INP2=>INP(2));
    INP_1_I: INP_1_B
      port map (PADDI=>INP_c_1, INP1=>INP(1));
    VHI_INST: VHI
      port map (Z=>VCCI);
    PUR_INST: PUR
      port map (PUR=>VCCI);
    GSR_INST: GSR
      port map (GSR=>VCCI);
  end Structure;



  library IEEE, vital2000, ECP3;
  configuration Structure_CON of Top is
    for Structure
    end for;
  end Structure_CON;


