vcd dumpfile vcdfile.vcd
vcd dumpvars -m /APL1/
vcd dumpvars -m /API1/ACTIVE_API/
vcd dumpvars -m /API1/ACTIVE_API/INIT_SBUF/
vcd dumpvars -m /API1/ACTIVE_API/FIFO_TO_INT/
vcd dumpvars -m /API1/IOBUF/
vcd dumpvars -m /API1/IOBUF/INITOBUF/
vcd dumpvars -m /API1/IOBUF/REPLYIBUF/
vcd dumpvars -m /API2/IOBUF/INITIBUF/
vcd dumpvars -m /API2/IOBUF/INITOBUF/
vcd dumpvars -m /API2/ACTIVE_API/
run 5000 ns
quit