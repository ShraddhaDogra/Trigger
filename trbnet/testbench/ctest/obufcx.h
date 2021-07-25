#ifndef OBUFCX_H
#define OBUFCX_H


#include "basic.h"

//
// output buffer for ONE channel and ONE port
//


class OBUFCX {
 public:
    OBUFCX() {RESET();};
    void RESET() {
	mystate=OBUF_FREEMODE;
	READ=DATAREADY=READ_OUT=CLEAR_OUT=0;
    };

    void Logic(void);
    
    in IBUF_STATEIN;  //I have to know what my partner is doing
    in_vector28 SIGIN;
    out_vector28 SIGOUT;
    in READ;
    out DATAREADY; //means that data can be transferred
    in  DATAREADY_IN;   //from other IBUF (stream partner)
    out READ_OUT;  //read from other IBUF (stream partner)
    out CLEAR_OUT;     //clear my direct partner
    out FREE_FOR_TRANSFER;

    void NextCLK(void);
    
    void Dump(void);
    
 private:
    state mystate, nextstate;
};

#endif
