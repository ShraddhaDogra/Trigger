#ifndef BASIC
#define BASIC


#include <iostream>
#include <math.h>

using namespace std;

#define in int
#define out int
#define state int

#define in_vector STD_LOGIC_ARRAY
#define out_vector STD_LOGIC_ARRAY

#define in_vector28 vector28 
#define out_vector28 vector28 

#define in_vector8 vector8 
#define out_vector8 vector8 

#define NOCHANGEMODE 0

#define FREEMODE 1
//FREEMODE means that all data are put to output

#define KEEPMODE 2
//means that EMPTY is hidden - do not use this port for a while

#define ACKMODE 3
//means that EMPTY should be anded - please wait until we are complete

#define TRANSFERMODE 4
//port is during transfer

#define TERMMODE 5

#define WAITINGMODE 6

#define ERRORMODE   7

#define OBUF_FREEMODE         1
#define OBUF_CLEARMODE        2
#define OBUF_WAITINGMODE      3


#define STATUSBITS    24,26
#define HEADER_INIT_HEADER 0x1
#define HEADER_INIT_TERM   0x2
#define HEADER_BUF    0x3
#define HEADER_DATA   0x4
#define HEADER_ACK    0x5
#define HEADER_REPLY_HEADER 0x6
#define HEADER_REPLY_TERM   0x7





//
// logic array
//

class STD_LOGIC_ARRAY {
 public:
    STD_LOGIC_ARRAY(int mysize);

    STD_LOGIC_ARRAY();

    unsigned int get_value(int a, int b);
    void set(unsigned int bla);

    void operator=(const STD_LOGIC_ARRAY & other);
    
    int operator()(int ar) const;

    int & operator()(int ar);


 protected:
    
    int * cont;
    int size;
};

class vector28 : public STD_LOGIC_ARRAY {
 public:
    vector28();
};

class vector8 : public STD_LOGIC_ARRAY {
 public:
    vector8();
};

//
// The classical flip-flop
//

class FLIPFLOP {
public:
    FLIPFLOP();
    in SIGIN;
    out SIGOUT;
    void RESET(void); 
    void NextCLK(void);
};

//
// 28 Bit register
//
class REG28 {
public:
    REG28();
    in_vector28 SIGIN;
    in WRITE;
    out_vector28 SIGOUT;
    void RESET(void);
    void NextCLK(void);
    void Logic(void){};
};

//
// 8- Bit counter
//
class COUNTER8 {
public:
    COUNTER8();
    out_vector8 SIGOUT;
    void RESET(void);
    void NextCLK(void);
    void Logic(void){};
 private:
    unsigned int counter;
};

//
// 28 bit wide fifo
// depth can be choosen in the constructor
// = would be "generic" in vhdl
//
// BUGBUG fifo full missing
// This would be an error condition
//

class FIFO28 {
public:
    FIFO28(int mydepth);
    void RESET();
    
    in WRITE,READ;
    out EMPTY;
    in_vector28 SIGIN;
    out_vector28 SIGOUT;
    
    void Logic(void);
    
    void NextCLK(void);

 private:
    unsigned int counter, depth;
    unsigned int pointer_write,pointer_read;
    REG28 * regarray;
};



#endif
