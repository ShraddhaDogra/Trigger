#---------------------------------------------------------
# Identify source-paths for this device's driver-sources,
# compiled when building the library
#---------------------------------------------------------
LIBRARY_C_SRCS	+= LatticeMico32CFI.c \
                   AmdSCS_1_8_8.c \
                   AmdSCS_2_8_8.c \
                   AmdSCS_4_8_8.c \
                   AmdSCS_1_16_16.c \
                   AmdSCS_2_16_16.c \
                   CFICfgIdentifier.c \
                   CFIRoutines.c \
                   LatticeMico32CFICfgTbl.c


LIBRARY_ASM_SRCS += 

#LIBRARY_INCLUDE_PATH += ../..
#INCLUDE_PATH += ..
