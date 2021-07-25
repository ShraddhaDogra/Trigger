#!/bin/bash

export DAQOPSERVER=jspc29:82

trbcmd reset
trbcmd w 0xf3cb 0xa001 0x409c      #40000
### jspc57
#trbcmd w 0xf3cb 0xa000 0x6700a8c0  #IP address reversed bytes! 192.168.0.103
#trbcmd w 0xf3cb 0xa002 0xC8F45FBC  #jspc57 MAC BC:5F:F4:C8:5D:53
#trbcmd w 0xf3cb 0xa003 0x0000535D
### end of jspc57
### jspc62
trbcmd w 0xf3cb 0xa000 0x1200a8c0   #reversed bytes! 192.168.0.18
trbcmd w 0xf3cb 0xa002 0xcaeb1734  #jspc62 MAC 34:17:eb:ca:bc:b9
trbcmd w 0xf3cb 0xa003 0x0000b9bc
### end of jspc57

trbcmd w 0xf3cb 0xa004 1000

trbcmd w 0xf3cb 0xa005 1
