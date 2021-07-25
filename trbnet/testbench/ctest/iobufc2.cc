#include "iobufc2.h"


void IOBUFC2::Logic(void){

    //trivial connections
    myiobuf_port1.SIGIN_INT = SIGIN_INT;
    myiobuf_port2.SIGIN_INT = SIGIN_INT;
    myiobuf_port1.SIGIN = SIGIN_PORT1;
    myiobuf_port2.SIGIN = SIGIN_PORT2;
    SIGOUT_PORT1 = myiobuf_port1.SIGOUT;
    SIGOUT_PORT2 = myiobuf_port2.SIGOUT;

    //forward read request to the correct IOBUF
    if (read_pointer == 0) {
	SIGOUT_INT = myiobuf_port1.SIGOUT_INT;
	myiobuf_port1.READ_IN_INT = READ_IN_INT;
	myiobuf_port2.READ_IN_INT = 0;
	DATAREADY_OUT_INT = myiobuf_port1.DATAREADY_OUT_INT;
    } else if (read_pointer == 1) {
	SIGOUT_INT = myiobuf_port2.SIGOUT_INT;
	myiobuf_port1.READ_IN_INT = 0;
	myiobuf_port2.READ_IN_INT = READ_IN_INT;
	DATAREADY_OUT_INT = myiobuf_port2.DATAREADY_OUT_INT;
    } 

    if (myiobuf_port1.FREE_FOR_OUT_TRANSFER 
	&& myiobuf_port2.FREE_FOR_OUT_TRANSFER) {
	myiobuf_port1.DATAREADY_IN_INT = 1;
	myiobuf_port2.DATAREADY_IN_INT = 1;
    } //all 2 obufs are ready
    else {
	myiobuf_port1.DATAREADY_IN_INT = 0;
	myiobuf_port2.DATAREADY_IN_INT = 0;
    }
    DATAREADY_PORT1 = myiobuf_port1.DATAREADY;
    DATAREADY_PORT2 = myiobuf_port2.DATAREADY;
    
    myiobuf_port1.READ = READ_PORT1;
    myiobuf_port2.READ = READ_PORT2;
    
    myiobuf_port1.WRITE = WRITE_PORT1;
    myiobuf_port2.WRITE = WRITE_PORT2;

    myiobuf_port1.RESENDHEADER_IN_INT = RESENDHEADER_IN_INT;
    myiobuf_port2.RESENDHEADER_IN_INT = RESENDHEADER_IN_INT;

    //if one of the output ports has to take a new header
    //just do it for both
    if (myiobuf_port1.RESENDHEADER_OUT_INT || myiobuf_port2.RESENDHEADER_OUT_INT)
	RESENDHEADER_OUT_INT = 1;
    else
	RESENDHEADER_OUT_INT = 0;

    //the state machine to control the input
    if (mystate==IOBUF2_FREEMODE) { //no preferred input
	if (myiobuf_port1.DATAREADY_OUT_INT) {
	    next_read_pointer = 0;
	    nextstate = IOBUF2_LOCKEDMODE;
	}
	else if (myiobuf_port2.DATAREADY_OUT_INT) {
	    next_read_pointer = 1;
	    nextstate = IOBUF2_LOCKEDMODE;
	}
	else {
	    next_read_pointer = 0;
	    nextstate = IOBUF2_FREEMODE;
	}
    } else if (mystate==IOBUF2_LOCKEDMODE) {
	//wait is IBUF is terminated...
	
    }

    myiobuf_port1.Logic();
    myiobuf_port2.Logic();

};

void IOBUFC2::NextCLK(void){
    read_pointer = next_read_pointer;
    mystate = nextstate;   
    myiobuf_port1.NextCLK();
    myiobuf_port2.NextCLK();
}


void IOBUFC2::Dump(void) {
    cout << "ST: " << mystate << " rpoint: " << read_pointer << " D_O_I1 " << myiobuf_port1.DATAREADY_OUT_INT 
	 << " D_O_I2 " << myiobuf_port2.DATAREADY_OUT_INT  << endl;
}
