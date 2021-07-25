#include "ibufcx.h"


void IBUFCX::Logic(void){
    STATEOUT=mystate;     //forward internal state to outer world
    header.SIGIN = SIGIN; //input lines for the header
    SIGOUT = buffer->SIGOUT;
    buffer->SIGIN = SIGIN;

    if (WRITE == 1) { //BUGBUG check if fifo is not full
	buffer->WRITE = 1;
    } else{ //BUGBUG check if fifo is not full
	buffer->WRITE = 0;
    }
	
    if ((!(buffer->EMPTY))) { //BUFFER has data 

	//ACK is something special, it must be killed after one CLK cycle
	if (buffer->SIGOUT.get_value(STATUSBITS) == HEADER_ACK) {
	    GOT_ACK = 1;
	    buffer->READ =  1;  //clean TERM
	    header.WRITE =  0; 
	    headerterm.WRITE =  0;  //
	    DATAREADY = 0;
	    nextstate = mystate;
	}
	else { 
	    GOT_ACK = 0;
	    if (mystate==FREEMODE) {	    
		if (buffer->SIGOUT.get_value(STATUSBITS) == HEADER_HEADER) {  //word to be read is a header
		    buffer->READ =  READ;  //yes, read header
		    header.WRITE =  1;  
		    headerterm.WRITE =  0;
		    DATAREADY = 1;
		    if (READ)
			nextstate = TRANSFERMODE;
		    else
		    nextstate = FREEMODE;
		} else if (buffer->SIGOUT.get_value(STATUSBITS) == HEADER_TERM) { //TERM transfer
		    buffer->READ =  1;  //clean TERM
		    header.WRITE =  0; 
		    headerterm.WRITE =  1;  //
		    DATAREADY = 0;
		    if (READ)
			nextstate = TERMMODE;
		    else
			nextstate = FREEMODE;
		} else  { //something is wrong...first word MUST be header or TERM
		    buffer->READ =  1;  //clean wrong word
		    header.WRITE =  0; 
		    headerterm.WRITE =  0;  
		    DATAREADY = 0;
		    nextstate = ERRORMODE;
		}	    
	    } //FREEMODE
	    else if (mystate==TRANSFERMODE) {
		if (buffer->SIGOUT.get_value(STATUSBITS) == HEADER_HEADER) {  //word to be read is a header
		    buffer->READ =  READ;  //yes, read header
		    //cout << "a" << endl;
		    header.WRITE =  1;  
		    headerterm.WRITE =  0;
		    DATAREADY = 1;
		    nextstate = TRANSFERMODE;
		} else if (buffer->SIGOUT.get_value(STATUSBITS) == HEADER_TERM) { //TERM transfer
		    //cout << buffer->SIGOUT.get_value(STATUSBITS) << endl;
		buffer->READ =  1;  //clean TERM
		header.WRITE =  0; 
		headerterm.WRITE =  1;  //
		DATAREADY = 0;
		nextstate = TERMMODE;
	    } else if (buffer->SIGOUT.get_value(STATUSBITS) == HEADER_BUF) { //ask for new buffer
		buffer->READ =  1;  //clean TERM
		header.WRITE =  0; 
		headerterm.WRITE =  0;  //I do not keep BUF header?
		DATAREADY = 0;
		nextstate = WAITINGMODE;
	    } else if (buffer->SIGOUT.get_value(STATUSBITS) == HEADER_DATA) {
		buffer->READ =  READ;  
		header.WRITE =  0; 
		headerterm.WRITE =  0;  
		DATAREADY = 1;
		nextstate = TRANSFERMODE;
	    }
	}//TRANSFER
	else if ((mystate==TERMMODE) || (mystate==WAITINGMODE)) {  //after TERM, wait for CLEAR
	    buffer->READ =  0;  
	    header.WRITE =  0; 
	    headerterm.WRITE =  0;  //I do not keep BUF header?
	    DATAREADY = 0;
	    if (CLEAR)
		nextstate = FREEMODE;
	    else
		nextstate = mystate;
	}
	}// END NOACK
    } // BUFFER is not EMPTY
    else { //BUFFER IS EMPTY
	if (mystate==FREEMODE) {	    
	    buffer->READ =  0;
	    header.WRITE =  0;  
	    headerterm.WRITE =  0;
	    DATAREADY = 0;
	    nextstate = FREEMODE;
	} else if (mystate==TRANSFERMODE) {	    
	    buffer->READ =  0;
	    header.WRITE =  0;  
	    headerterm.WRITE =  0;
	    DATAREADY = 0;
	    nextstate = TRANSFERMODE;
	} else if (mystate==WAITINGMODE) {	    
	    buffer->READ =  0;
	    header.WRITE =  0;  
	    headerterm.WRITE =  0;
	    DATAREADY = 0;
	    if (CLEAR) 
		nextstate = FREEMODE;
	    else
		nextstate = WAITINGMODE;
	} else if (mystate==TERMMODE) {	    
	    buffer->READ =  0;
	    header.WRITE =  0;  
	    headerterm.WRITE =  0;
	    DATAREADY = 0;
	    if (CLEAR) 
		nextstate = FREEMODE;
	    else
		nextstate = TERMMODE;
	}
    }


    buffer->Logic();
    header.Logic();
    headerterm.Logic();
};

void IBUFCX::NextCLK(void){
    mystate = nextstate;
    buffer->NextCLK();
    header.NextCLK();
    headerterm.NextCLK();
}


void IBUFCX::Dump(void) {
    
    cout << "W=" << WRITE << " R=" << READ << " DR=" << DATAREADY << " st=" << mystate 
	 << " EMP=" <<  buffer->EMPTY
	 << " buf=" << std::hex <<  buffer->SIGOUT.get_value(0,27)
	
	 << endl;
}
