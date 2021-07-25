#ifndef IOBUFC2_H
#define IOBUFC2_H



#include "basic.h"
#include "iobufcx.h"


#define IOBUF2_FREEMODE   1
#define IOBUF2_LOCKEDMODE 2

//
// output buffer for ONE channel and TWO ports
//

class IOBUFC2 {
 public:
    IOBUFC2() {RESET();};
    void RESET() {
	read_pointer =0;
	mystate = IOBUF2_FREEMODE;
    };

    void Logic(void);
    
    in_vector28 SIGIN_INT;  //internal data
    out_vector28 SIGOUT_INT;

    //declarations for PORT1
    in_vector28 SIGIN_PORT1;
    out_vector28 SIGOUT_PORT1;
    in WRITE_PORT1;               //media is putting data into IBUF
    out READ_PORT1;               //media is reading data
    out DATAREADY_PORT1;          //media knows that I have somthing to offer
   

    //declarations for PORT2
    in_vector28 SIGIN_PORT2;
    out_vector28 SIGOUT_PORT2;
    in WRITE_PORT2;               //media is putting data into IBUF
    out READ_PORT2;               //media is reading data
    out DATAREADY_PORT2;          //media knows that I have somthing to offer


    //this looks like a normal iobufcx
    in READ_IN_INT;         //Internal logic can read buffer
    out READ_OUT_INT;       //IOBUF is activating internal logic
    out DATAREADY_OUT_INT;  //means that data can be transferred
    in  DATAREADY_IN_INT;   //from other IBUF (stream partner)

    in RESENDHEADER_IN_INT; //in-streaming have to resend header
    out RESENDHEADER_OUT_INT; //internal logic has to resend header

    

    void NextCLK(void);
    
    void Dump(void);
    
    IOBUFCX myiobuf_port1, myiobuf_port2;
    
 private:
    unsigned int read_pointer, next_read_pointer;
    unsigned int mystate, nextstate;
};

#endif
