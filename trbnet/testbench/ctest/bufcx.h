#ifndef BUFCX
#define BUFCX


#include "basic.h"

//
// input buffer for ONE channel and ONE port
//


class IBUFCX {
public:
    IBUFCX() {RESET();};
    void RESET() {
	buffer = new FIFO28(16);
	buffer->RESET();
	WRITE=READ=DATAREADY=TERM=BUFFEREND=CLEAN=0;
	mystate=FREEMODE;
    };
    in WRITE,READ,RESENDHEADER,CLEAN;
    out DATAREADY; //means that data can be transferred
    out TERM;  //TERM header arrived
    out BUFFEREND;  //ACK cycle has to be done

    void Logic(void);
    
    in STATEIN;
    out STATEOUT;
    in_vector28 SIGIN;
    out_vector28 SIGOUT,HEADER,TERMHEADER;


    void NextCLK(void);
    
    void Dump(void);
    

    FIFO28 * buffer;
 private:

    state mystate, nextstate;
    REG28 header, headerterm;

};

#endif
