.SUFFIXES: .cc

OBJS            = ibufcx.o obufcx.o iobufcx.o iobufc2.o iofifo.o hubtest.o basic.o

CXX           = g++
CXXFLAGS      = -g -O3 -Wall -fPIC
LD            = g++
LDFLAGS       = 
LIBS          = -lm -ldl -rdynamic

all: hubtest

hubtest: $(OBJS) Makefile  hubtest.o
	$(LD) $(LDFLAGS) $(OBJS) $(LIBS) -o hubtest

.cc.o:
	@echo compiling $<
	$(CXX) $(CXXFLAGS) -c $<


clean:
	@rm -f $(OBJS) hubtest *.o

