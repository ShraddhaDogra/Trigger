#ifndef IOFIFO_H
#define IOFIFO_H

#define IOFIFO_FREEMODE 1
#define IOFIFO_SENDHEADER 2 
#define IOFIFO_SENDMODE 3

#include "iobufcx.h"

class IOFIFO {
 public:
    IOFIFO() {
	buffer = new FIFO28(16);
	RESET();
    };
    void RESET() {
	mystate = IOFIFO_FREEMODE;
	reg_sender_header.WRITE = 1;
	reg_sender_header.SIGIN.set(0xfffffff);
	reg_sender_header.NextCLK();
	reg_sender_header.WRITE = 0;
	
    };
    
    in_vector28 SENDER_HEADER;
    in WRITE_SENDER_HEADER;
    in_vector28 SIGIN;   //write data from host
    in WRITE;            //write data from host
    out FULL;            //fifo full (not yet implemented)

    out_vector28 SIGOUT; //data from network
    in READ;             //read data from host
    out DATAREADY;       //data can be read
    
    //now some lines for the media
    

    void Logic(void);

    void NextCLK(void);
    
    void Dump(void);

    IOBUFCX iobuffer;
    FIFO28 * buffer;  //in principle 24 Bit would be enough....
    REG28 reg_sender_header;;

 private:
    state mystate, nextstate;

};


#endif
