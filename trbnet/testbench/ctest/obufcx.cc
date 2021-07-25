#include "obufcx.h"


void OBUFCX::Logic(void){
    if ((mystate==OBUF_FREEMODE) || (mystate==OBUF_WAITINGMODE)) {
	if (IBUF_STATEIN == WAITINGMODE) {
	    //partner has got EOB and we should send an ACK	    
	    SIGOUT.set(HEADER_ACK << 24);  //prepare ACK
	    if (READ) 
		nextstate = OBUF_CLEARMODE;
	    else 
		nextstate = OBUF_WAITINGMODE;
	    DATAREADY = 1;
	    READ_OUT =  0;
	    CLEAR_OUT = 0;
	    FREE_FOR_TRANSFER = 0; //block the fan-out
	}
	else {
	    //simply forward what I got
	    SIGOUT = SIGIN;
	    nextstate = OBUF_FREEMODE;
	    DATAREADY = DATAREADY_IN;
	    READ_OUT = READ;
	    CLEAR_OUT = 0;
	    FREE_FOR_TRANSFER = 1;
	}
    } else if (mystate==OBUF_CLEARMODE) {
	//simply forward what I got
	SIGOUT = SIGIN;
	nextstate = OBUF_FREEMODE;
	DATAREADY = DATAREADY_IN;
	READ_OUT = READ;
	CLEAR_OUT = 1; //In addition, clear my partner
	FREE_FOR_TRANSFER = 1;  //I'm free to transfer now
    }

};

void OBUFCX::NextCLK(void){
    mystate = nextstate;    
}


void OBUFCX::Dump(void) {
    cout << "ST: " << mystate << " R " << READ << " DR "<< DATAREADY << endl;
}
