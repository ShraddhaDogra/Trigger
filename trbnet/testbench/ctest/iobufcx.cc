#include "iobufcx.h"


void IOBUFCX::Logic(void){

    //connect ibuf to obuf direct partner
    myobuf.IBUF_STATEIN = myibuf.STATEOUT;
    myibuf.CLEAR = myobuf.CLEAR_OUT;

    //connect obuf to streaming partner
    myobuf.SIGIN = SIGIN_INT;
    myobuf.DATAREADY_IN = DATAREADY_IN_INT;
    READ_OUT_INT = myobuf.READ_OUT;
    myibuf.READ  = READ_IN_INT;
    myibuf.RESENDHEADER = RESENDHEADER_IN_INT;
    DATAREADY_OUT_INT = myibuf.DATAREADY;
    SIGOUT_INT = myibuf.SIGOUT;
    FREE_FOR_OUT_TRANSFER = myobuf.FREE_FOR_TRANSFER;
    
    //connect to media

    myibuf.SIGIN = SIGIN;
    myibuf.WRITE = WRITE;

    if (READ)
	next_word_counter = word_counter +1;

    if (word_counter == 0) {
	if (block_counter < MAX_BLOCKS) {
	    //resend header
	    RESENDHEADER_OUT_INT = 1;
	    SIGOUT = myobuf.SIGOUT;
	    DATAREADY = myobuf.DATAREADY;	//forward the DATAREADY from the input
	    myobuf.READ = READ;    	
	    next_block_counter = block_counter;
	    if (READ)
		next_word_counter = word_counter +1;
	    else
		next_word_counter = word_counter;
	} else { //transfer continued
	    if (myibuf.GOT_ACK) {
		RESENDHEADER_OUT_INT = 1;
		SIGOUT = myobuf.SIGOUT;
		DATAREADY = 0;
		myobuf.READ = 0;
		next_block_counter = block_counter - 1;
		next_word_counter = 0;
	    } else { //transfer stalled
		RESENDHEADER_OUT_INT = 1;
		SIGOUT = myobuf.SIGOUT;
		DATAREADY = 0;
		myobuf.READ = 0;
		next_block_counter = block_counter;
		next_word_counter = word_counter;
	    }
	}
    } else if (word_counter == (MAX_WORD-1)) {
	// send EOB
	RESENDHEADER_OUT_INT = 0;
	SIGOUT.set(HEADER_BUF << 24);
	DATAREADY = 1;	//so I have DATAREADY 
	myobuf.READ = 0;    	
	if (READ) {
	    next_word_counter = 0;
	    if (!myibuf.GOT_ACK) //async ACK
		next_block_counter = block_counter + 1;
	    else
		next_block_counter = block_counter;
	}
	else {
	    next_word_counter = word_counter;
	    next_block_counter = block_counter;
	}
    } else {
	RESENDHEADER_OUT_INT = 0; 
	SIGOUT = myobuf.SIGOUT;
	DATAREADY = myobuf.DATAREADY;	
	myobuf.READ = READ;    
	next_block_counter = block_counter;
	if (READ)
	    next_word_counter = word_counter + 1;
	else
	    next_word_counter = word_counter;
    }

    myibuf.Logic();
    myobuf.Logic();
    
};

void IOBUFCX::NextCLK(void){
    word_counter = next_word_counter;
    block_counter = next_block_counter;
    myibuf.NextCLK();
    myobuf.NextCLK();
}


void IOBUFCX::Dump(void) {

}
