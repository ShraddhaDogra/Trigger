--
--
--		2DO:
--					FIT TO VERSION 4.0
--
--
--

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
--USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.monitor_config.all;

entity rom_32x113 is
  generic(
    INITX  : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(FIFO_NUM,8)) & std_logic_vector(to_unsigned(REG_NUM,16)) & std_logic_vector(to_unsigned(CFG_WIDTH, 8));
    INIT0  : std_logic_vector(31 downto 0) := fifo_generics(1).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(1).width,8)) & std_logic_vector(to_unsigned(fifo_generics(1).depth,16));
    INIT1  : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(1).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(1).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(1).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(1).time_size,8));
    INIT2  : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(1).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(1).event_size,8)) & "0000000000000000";
    INIT3  : std_logic_vector(31 downto 0) := cfgs(1).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT4  : std_logic_vector(31 downto 0) := fifo_generics(2).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(2).width,8)) & std_logic_vector(to_unsigned(fifo_generics(2).depth,16));
    INIT5  : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(2).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(2).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(2).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(2).time_size,8));
    INIT6  : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(2).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(2).event_size,8)) & "0000000000000000";
    INIT7  : std_logic_vector(31 downto 0) := cfgs(2).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT8  : std_logic_vector(31 downto 0) := fifo_generics(3).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(3).width,8)) & std_logic_vector(to_unsigned(fifo_generics(3).depth,16));
    INIT9  : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(3).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(3).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(3).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(3).time_size,8));
    INIT10 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(3).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(3).event_size,8)) & "0000000000000000";
		INIT11 : std_logic_vector(31 downto 0) := cfgs(3).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT12 : std_logic_vector(31 downto 0) := fifo_generics(4).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(4).width,8)) & std_logic_vector(to_unsigned(fifo_generics(4).depth,16));
    INIT13 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(4).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(4).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(4).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(4).time_size,8));
    INIT14 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(4).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(4).event_size,8)) & "0000000000000000";
    INIT15 : std_logic_vector(31 downto 0) := cfgs(4).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT16 : std_logic_vector(31 downto 0) := fifo_generics(5).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(5).width,8)) & std_logic_vector(to_unsigned(fifo_generics(5).depth,16));
    INIT17 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(5).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(5).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(5).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(5).time_size,8));
    INIT18 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(5).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(5).event_size,8)) & "0000000000000000";
    INIT19 : std_logic_vector(31 downto 0) := cfgs(5).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT20 : std_logic_vector(31 downto 0) := fifo_generics(6).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(6).width,8)) & std_logic_vector(to_unsigned(fifo_generics(6).depth,16));
    INIT21 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(6).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(6).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(6).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(6).time_size,8));
    INIT22 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(6).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(6).event_size,8)) & "0000000000000000";
    INIT23 : std_logic_vector(31 downto 0) := cfgs(6).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT24 : std_logic_vector(31 downto 0) := fifo_generics(7).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(7).width,8)) & std_logic_vector(to_unsigned(fifo_generics(7).depth,16));
    INIT25 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(7).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(7).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(7).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(7).time_size,8));
    INIT26 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(7).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(7).event_size,8)) & "0000000000000000";
    INIT27 : std_logic_vector(31 downto 0) := cfgs(7).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT28 : std_logic_vector(31 downto 0) := fifo_generics(8).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(8).width,8)) & std_logic_vector(to_unsigned(fifo_generics(8).depth,16));
    INIT29 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(8).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(8).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(8).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(8).time_size,8));
    INIT30 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(8).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(8).event_size,8)) & "0000000000000000";
    INIT31 : std_logic_vector(31 downto 0) := cfgs(8).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT32 : std_logic_vector(31 downto 0) := fifo_generics(9).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(9).width,8)) & std_logic_vector(to_unsigned(fifo_generics(9).depth,16));
    INIT33 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(9).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(9).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(9).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(9).time_size,8));
    INIT34 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(9).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(9).event_size,8)) & "0000000000000000";
    INIT35 : std_logic_vector(31 downto 0) := cfgs(9).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT36 : std_logic_vector(31 downto 0) := fifo_generics(10).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(10).width,8)) & std_logic_vector(to_unsigned(fifo_generics(10).depth,16));
    INIT37 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(10).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(10).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(10).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(10).time_size,8));
    INIT38 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(10).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(10).event_size,8)) & "0000000000000000";
    INIT39 : std_logic_vector(31 downto 0) := cfgs(10).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT40 : std_logic_vector(31 downto 0) := fifo_generics(11).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(11).width,8)) & std_logic_vector(to_unsigned(fifo_generics(11).depth,16));
    INIT41 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(11).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(11).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(11).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(11).time_size,8));
    INIT42 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(11).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(11).event_size,8)) & "0000000000000000";
		INIT43 : std_logic_vector(31 downto 0) := cfgs(11).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT44 : std_logic_vector(31 downto 0) := fifo_generics(12).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(12).width,8)) & std_logic_vector(to_unsigned(fifo_generics(12).depth,16));
    INIT45 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(12).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(12).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(12).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(12).time_size,8));
    INIT46 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(12).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(12).event_size,8)) & "0000000000000000";
    INIT47 : std_logic_vector(31 downto 0) := cfgs(12).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT48 : std_logic_vector(31 downto 0) := fifo_generics(13).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(13).width,8)) & std_logic_vector(to_unsigned(fifo_generics(13).depth,16));
    INIT49 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(13).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(13).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(13).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(13).time_size,8));
    INIT50 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(13).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(13).event_size,8)) & "0000000000000000";
    INIT51 : std_logic_vector(31 downto 0) := cfgs(13).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT52 : std_logic_vector(31 downto 0) := fifo_generics(14).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(14).width,8)) & std_logic_vector(to_unsigned(fifo_generics(14).depth,16));
    INIT53 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(14).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(14).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(14).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(14).time_size,8));
    INIT54 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(14).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(14).event_size,8)) & "0000000000000000";
    INIT55 : std_logic_vector(31 downto 0) := cfgs(14).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT56 : std_logic_vector(31 downto 0) := fifo_generics(15).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(15).width,8)) & std_logic_vector(to_unsigned(fifo_generics(15).depth,16));
    INIT57 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(15).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(15).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(15).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(15).time_size,8));
    INIT58 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(15).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(15).event_size,8)) & "0000000000000000";
    INIT59 : std_logic_vector(31 downto 0) := cfgs(15).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT60 : std_logic_vector(31 downto 0) := fifo_generics(16).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(16).width,8)) & std_logic_vector(to_unsigned(fifo_generics(16).depth,16));
    INIT61 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(16).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(16).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(16).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(16).time_size,8));
    INIT62 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(16).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(16).event_size,8)) & "0000000000000000";
    INIT63 : std_logic_vector(31 downto 0) := cfgs(16).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT64 : std_logic_vector(31 downto 0) := fifo_generics(17).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(17).width,8)) & std_logic_vector(to_unsigned(fifo_generics(17).depth,16));
    INIT65 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(17).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(17).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(17).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(17).time_size,8));
    INIT66 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(17).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(17).event_size,8)) & "0000000000000000";
    INIT67 : std_logic_vector(31 downto 0) := cfgs(17).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT68 : std_logic_vector(31 downto 0) := fifo_generics(18).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(18).width,8)) & std_logic_vector(to_unsigned(fifo_generics(18).depth,16));
    INIT69 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(18).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(18).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(18).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(18).time_size,8));
    INIT70 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(18).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(18).event_size,8)) & "0000000000000000";
    INIT71 : std_logic_vector(31 downto 0) := cfgs(18).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT72 : std_logic_vector(31 downto 0) := fifo_generics(19).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(19).width,8)) & std_logic_vector(to_unsigned(fifo_generics(19).depth,16));
    INIT73 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(19).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(19).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(19).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(19).time_size,8));
    INIT74 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(19).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(19).event_size,8)) & "0000000000000000";
		INIT75 : std_logic_vector(31 downto 0) := cfgs(19).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
    INIT76 : std_logic_vector(31 downto 0) := fifo_generics(20).monitoring_type & std_logic_vector(to_unsigned(fifo_generics(20).width,8)) & std_logic_vector(to_unsigned(fifo_generics(20).depth,16));
    INIT77 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(20).frequency,8)) & std_logic_vector(to_unsigned(fifo_generics(20).timer_type,8)) & std_logic_vector(to_unsigned(fifo_generics(20).timer_resolution,8)) & std_logic_vector(to_unsigned(fifo_generics(20).time_size,8));
    INIT78 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(fifo_generics(20).data_size,8)) & std_logic_vector(to_unsigned(fifo_generics(20).event_size,8)) & "0000000000000000";
    INIT79 : std_logic_vector(31 downto 0) := cfgs(20).init & std_logic_vector(to_unsigned(fifo_generics(1).descriptor,16));
		INIT80 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(1).width,8))  & x"0000" & "00000000";
		INIT81 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(2).width,8))  & x"0000" & "00000000";
		INIT82 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(3).width,8))  & x"0000" & "00000000";
		INIT83 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(4).width,8))  & x"0000" & "00000000";
		INIT84 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(5).width,8))  & x"0000" & "00000000";
		INIT85 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(6).width,8))  & x"0000" & "00000000";
		INIT86 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(7).width,8))  & x"0000" & "00000000";
		INIT87 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(8).width,8))  & x"0000" & "00000000";
		INIT88 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(9).width,8))  & x"0000" & "00000000";
		INIT89 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(10).width,8)) & x"0000" & "00000000";
		INIT90 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(11).width,8)) & x"0000" & "00000000";
		INIT91 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(12).width,8)) & x"0000" & "00000000";
		INIT92 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(13).width,8)) & x"0000" & "00000000";
		INIT93 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(14).width,8)) & x"0000" & "00000000";
		INIT94 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(15).width,8)) & x"0000" & "00000000";
		INIT95 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(16).width,8)) & x"0000" & "00000000";
		INIT96 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(17).width,8)) & x"0000" & "00000000";
		INIT97 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(18).width,8)) & x"0000" & "00000000";
		INIT98 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(19).width,8)) & x"0000" & "00000000";
		INIT99 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(20).width,8)) & x"0000" & "00000000";
		INIT100: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(21).width,8)) & x"0000" & "00000000";
		INIT101: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(22).width,8)) & x"0000" & "00000000";
		INIT102: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(23).width,8)) & x"0000" & "00000000";
		INIT103: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(24).width,8)) & x"0000" & "00000000";
		INIT104: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(25).width,8)) & x"0000" & "00000000";
		INIT105: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(26).width,8)) & x"0000" & "00000000";
		INIT106: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(27).width,8)) & x"0000" & "00000000";
		INIT107: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(28).width,8)) & x"0000" & "00000000";
		INIT108: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(29).width,8)) & x"0000" & "00000000";
		INIT109: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(30).width,8)) & x"0000" & "00000000";
		INIT110: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(31).width,8)) & x"0000" & "00000000";
		INIT111: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(reg_generics(32).width,8)) & x"0000" & "00000000"

	);
  port(
    CLK        : in  std_logic;
    ADDR_IN    : in  std_logic_vector(8 downto 0);
    DATA_OUT   : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rom_32x113_arch of rom_32x113 is
  type ram_t is array(0 to 112) of std_logic_vector(31 downto 0);
  SIGNAL rom : ram_t := (INITX, INIT0, INIT1, INIT2, INIT3, INIT4, INIT5, INIT6, INIT7, INIT8,
												 INIT9, INIT10, INIT11, INIT12, INIT13, INIT14, INIT15, INIT16,
												 INIT17, INIT18, INIT19, INIT20, INIT21, INIT22, INIT23, INIT24,
												 INIT25, INIT26, INIT27, INIT28, INIT29, INIT30, INIT31,
												 INIT32, INIT33, INIT34, INIT35, INIT36, INIT37, INIT38, INIT39, INIT40,
												 INIT41, INIT42, INIT43, INIT44, INIT45, INIT46, INIT47, INIT48,
												 INIT49, INIT50, INIT51, INIT52, INIT53, INIT54, INIT55, INIT56,
												 INIT57, INIT58, INIT59, INIT60, INIT61, INIT62, INIT63,
												 INIT64, INIT65, INIT66, INIT67, INIT68, INIT69, INIT70, INIT71,
												 INIT72, INIT73, INIT74, INIT75, INIT76, INIT77, INIT78, INIT79,
												 INIT80, INIT81, INIT82, INIT83, INIT84, INIT85, INIT86, INIT87,
												 INIT88, INIT89, INIT90, INIT91, INIT92, INIT93, INIT94, INIT95,
												 INIT96, INIT97, INIT98, INIT99, INIT100, INIT101, INIT102, INIT103,
												 INIT104, INIT105, INIT106, INIT107, INIT108, INIT109, INIT110, INIT111
--												 INIT112, INIT113, INIT114, INIT115, INIT116, INIT117, INIT118, INIT119,
--												 INIT120, INIT121, INIT122, INIT123, INIT124, INIT125, INIT126, INIT127,
--												 INIT128, INIT129, INIT130, INIT131, INIT132, INIT133, INIT134, INIT135,
--												 INIT136, INIT137, INIT138, INIT139, INIT140, INIT141, INIT142, INIT143
												 );

begin



  process(CLK)
  begin
    if rising_edge(CLK) then
      DATA_OUT <= rom(to_integer(unsigned(ADDR_IN)));
    end if;
  end process;

end architecture;