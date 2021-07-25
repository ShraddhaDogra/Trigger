#ntrace select -o on -m / -l this
#ntrace select -o on -m /UUT/ -l  this
ntrace select -o on -m /APL1/ -l  this
#ntrace select -o on -m /API1/ -l  this
ntrace start
run 1000 ns
quit