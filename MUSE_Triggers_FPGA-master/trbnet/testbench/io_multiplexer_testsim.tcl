vcd dumpfile vcdfile.vcd
vcd dumpvars -m /UUT/
vcd dumpvars -m /UUT/DEFDR/
vcd dumpvars -m /UUT/ARBITER/
vcd dumpvars -m /UUT/G2/
run 1000 ns
quit