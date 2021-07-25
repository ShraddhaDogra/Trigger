vcd dumpfile vcdfile.vcd
#vcd dumpvars lvds
vcd dumpvars -m /APL1/
vcd dumpvars -m /APL2/
vcd dumpvars -m /API1/MPLEX/
vcd dumpvars -m /API2/PASSIVE_API/PASSIVE_API/
vcd dumpvars -m /API1/ACTIVE_API/ACTIVE_API/
vcd dumpvars -m /API1/IOBUF/
vcd dumpvars -m /API1/IOBUF/INITOBUF/
vcd dumpvars -m /API1/IOBUF/REPLYIBUF/
vcd dumpvars -m /API2/IOBUF/INITIBUF/
vcd dumpvars -m /API2/IOBUF/INITOBUF/
vcd dumpvars -m /API2/IOBUF/REPLYOBUF/
vcd dumpvars -m /API2/PASSIVE_API/
vcd dumpvars -m /LVDS1/
vcd dumpvars -m /LVDS2/
run 30000 ns
quit