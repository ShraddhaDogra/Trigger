#include "iofifo.h"

// WRITE data to network
// way1.) write the header first, then the data
// way2.) write first the data, data transfer is locked until you write the header
// after transfer, write a TERM header to the header register
// TODO: IDLE mode...



void IOFIFO::Logic(void){

    //header control
    reg_sender_header.SIGIN = SENDER_HEADER;
    reg_sender_header.WRITE = WRITE_SENDER_HEADER;

    //input fifo -> decouples writing from network transfer
    buffer->SIGIN = SIGIN;
    buffer->WRITE = WRITE;
        
    //output device
    SIGOUT = iobuffer.SIGOUT_INT;
    iobuffer.READ_IN_INT = READ;
    DATAREADY = iobuffer.DATAREADY_OUT_INT;

    if (mystate == IOFIFO_FREEMODE) {  //nothing happened so far...
	iobuffer.SIGIN_INT = SIGIN;
	iobuffer.DATAREADY_IN_INT = 0;
	buffer->READ = 0;
	if (reg_sender_header.SIGOUT.get_value(STATUSBITS) == HEADER_HEADER) {
	    nextstate = IOFIFO_SENDHEADER;
	} else
	    nextstate = IOFIFO_FREEMODE;	
    } // end FREEMODE
    else if (mystate == IOFIFO_SENDHEADER) {
	iobuffer.SIGIN_INT = reg_sender_header.SIGOUT;
	iobuffer.DATAREADY_IN_INT = 1;
	buffer->READ = 0;
	if (iobuffer.READ_OUT_INT)  //yes, buffer reads my header
	    nextstate = IOFIFO_SENDMODE;
	else
	    nextstate = IOFIFO_SENDHEADER;
    } // end SENDHEADER
    else if (mystate == IOFIFO_SENDMODE) {
	if (iobuffer.RESENDHEADER_OUT_INT) {
	    iobuffer.SIGIN_INT = reg_sender_header.SIGOUT;
	    iobuffer.DATAREADY_IN_INT = 1;
	    buffer->READ = 0;
	} else {
	    iobuffer.SIGIN_INT = buffer->SIGOUT;
	    if (reg_sender_header.SIGOUT.get_value(STATUSBITS) == HEADER_HEADER) {
		iobuffer.DATAREADY_IN_INT = (!buffer->EMPTY);
		nextstate = IOFIFO_SENDMODE;
	    }
	    else {
		iobuffer.DATAREADY_IN_INT = 0;
		nextstate = IOFIFO_FREEMODE;
	    }
	    buffer->READ = iobuffer.READ_OUT_INT;
	}
    }

    buffer->Logic();
    iobuffer.Logic();
    reg_sender_header.Logic();

}


void IOFIFO::NextCLK(void){
    mystate = nextstate;
    buffer->NextCLK();
    iobuffer.NextCLK();
    reg_sender_header.NextCLK();
}

void IOFIFO::Dump(void){
    cout << "ST:" << mystate << " BUFREAD " << buffer->READ << " HH " << reg_sender_header.SIGOUT.get_value(STATUSBITS) << " HW " << reg_sender_header.WRITE << " IOB_DR " << iobuffer.DATAREADY_IN_INT << " IOB_RSH " <<iobuffer.RESENDHEADER_OUT_INT << endl;
}
