#ifndef IOBUFCX_H
#define IOBUFCX_H



#include "basic.h"
#include "ibufcx.h"
#include "obufcx.h"

//
// output buffer for ONE channel and ONE port
//

//hardcoded, later to be made with LSYNC
#define MAX_WORD   32
#define MAX_BLOCKS 2

class IOBUFCX {
 public:
    IOBUFCX() {RESET();};
    void RESET() {
	word_counter =0;
	block_counter=0;
    };

    void Logic(void);
    
    in_vector28 SIGIN_INT;  //internal data
    out_vector28 SIGOUT_INT;

    in_vector28 SIGIN;
    out_vector28 SIGOUT;

    in READ_IN_INT;         //Internal logic can read buffer
    out READ_OUT_INT;       //IOBUF is activating internal logic
    out DATAREADY_OUT_INT;  //means that data can be transferred
    in  DATAREADY_IN_INT;   //from other IBUF (stream partner)

    in RESENDHEADER_IN_INT; //in-streaming have to resend header
    out RESENDHEADER_OUT_INT; //internal logic has to resend header

    in WRITE;               //media is putting data into IBUF
    out READ;               //media is reading data
    out DATAREADY;          //media knows that I have somthing to offer
    
    out FREE_FOR_OUT_TRANSFER;  //OBUF is transparent, and has no internal data

    void NextCLK(void);
    
    void Dump(void);
    
    IBUFCX myibuf;
    OBUFCX myobuf;


 private:
    unsigned int next_word_counter, word_counter;
    unsigned int block_counter, next_block_counter;

};

#endif
