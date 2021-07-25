#include "iobufcx.h"
#include "iobufc2.h"
#include "iofifo.h"

int acktest(void) {

    IOBUFCX buf;

    for (int i=0; i<10; i++) {
        
	//TESTBENCH
	if (i==0) {
	    //write a word into buf   
	    buf.WRITE=1;
	    buf.SIGIN.set(0x01000000u); // empty header
	}
	else if (i==1) { 
	    buf.WRITE=1;
	    buf.SIGIN.set(0x04000000u); // data word
	}
	else if (i==2) { 
	    buf.WRITE=1;
	    //buf.SIGIN.set(0x02000000u); // term word
	    buf.SIGIN.set(0x03000000u); // EOB word
	} 
	else buf.WRITE=0; 

	if (i==2) 
	    buf.READ_IN_INT=1;
	else if (i==4) 
	    buf.READ_IN_INT=1;
	else buf.READ_IN_INT=0;

	if (i==7)
	    buf.READ=1;
	else
	    buf.READ=0;
	

	for (int l=0;l<100;l++) buf.Logic();

	//
	cout << "SIGOUT " << std::hex << buf.SIGOUT.get_value(0,27) << endl;

	buf.myibuf.Dump();
	//buf.myobuf.Dump();
	//asign CLK
	buf.NextCLK();
	cout << "next CLK" << endl;
    }


}

void connect(IOBUFCX * a, IOBUFCX * b) {
    //cross-connect 2 buffers
    //this is what the OSI_LINK_LAYER should do
    
    b->SIGIN = a->SIGOUT;
    a->SIGIN = b->SIGOUT;
    
    a->READ = a->DATAREADY;
    b->READ = b->DATAREADY;
    
    b->WRITE = a->DATAREADY;
    a->WRITE = b->DATAREADY;

}


void connect2(IOBUFCX * a1, IOBUFCX * a2, IOBUFC2 * b) {
    //cross-connect 2 buffers to 1 fan-in
    //this is what the OSI_LINK_LAYER should do
    
    b->SIGIN_PORT1 = a1->SIGOUT;
    a1->SIGIN = b->SIGOUT_PORT1;
    b->SIGIN_PORT2 = a2->SIGOUT;
    a2->SIGIN = b->SIGOUT_PORT2;
    
    b->READ_PORT1 = b->DATAREADY_PORT1;
    b->READ_PORT2 = b->DATAREADY_PORT2;
    a1->READ = a1->DATAREADY;
    a2->READ = a2->DATAREADY;
    
    b->WRITE_PORT1 = a1->DATAREADY;
    b->WRITE_PORT2 = a2->DATAREADY;
    a1->WRITE = b->DATAREADY_PORT1;
    a2->WRITE = b->DATAREADY_PORT2;

}


int iofifotest(void) {

    IOFIFO send,end;

    for (int i=0; i<20; i++) {
        
	//TESTBENCH
	if (i==0) {
	    //write a word into send   
	    send.WRITE=1;
	    send.SIGIN.set(0x00adfaceu); 
	}
	else if (i==1) { 
	    send.WRITE=1;
	    send.SIGIN.set(0x00345678u); // data word
	}
	else if (i==2) { 
	    send.WRITE=1;
	    send.SIGIN.set(0x01212u); // data word
	} 
	else if (i==5) { 
	    send.WRITE=1;
	    send.SIGIN.set(0x02000000u); // data word
	} else {
	    send.WRITE=0;
	}
	
	//HEADER activate
	if (i==3) {
	    send.WRITE_SENDER_HEADER=1;
	    send.SENDER_HEADER.set(0x01000000u); 
	} else send.WRITE_SENDER_HEADER=0;

	//ENDPOINT
	end.WRITE=0;
	//end.READ=0;
	end.WRITE_SENDER_HEADER=0;

	//LOGIC
	for (int l=0;l<100;l++) {
	    //simulate READER
	    if (end.DATAREADY) end.READ=1;
	    else end.READ=0;
	    send.Logic();
	    end.Logic();
	    connect(&send.iobuffer, &end.iobuffer);	    
	}

	//
	if (send.iobuffer.DATAREADY)
	    cout << "DOWN MEDIA SIGOUT " << std::hex << send.iobuffer.SIGOUT.get_value(0,27) << endl;
	else cout << "NO DOWN MEDIA DATA" << endl;

	if (end.iobuffer.DATAREADY)
	    cout << "UP MEDIA SIGOUT " << std::hex << end.iobuffer.SIGOUT.get_value(0,27) << endl;
	else cout << "NO UP MEDIA DATA" << endl;

	//cout << "OBUF: ";send.iobuffer.myobuf.Dump();
	//cout << "IOFIFO: ";send.Dump();

	//cout << "END:OBUF: ";end.iobuffer.myobuf.Dump();

	//buf.myobuf.Dump();
	//asign CLK
	send.NextCLK();
	end.NextCLK();
	cout << "--------------------" << endl;
    }


}









int fan_in_test(void) {

    IOFIFO send1,send2;
    IOBUFC2 fan_in;
    
    for (int i=0; i<20; i++) {
        
	//TESTBENCH
	if (i==0) {
	    //write a word into send   
	    send1.WRITE=1;
	    send2.WRITE=1;
	    send1.SIGIN.set(0x00adfaceu); 
	    send2.SIGIN.set(0x00affeu); 
	}
	else if (i==1) { 
	    send1.WRITE=1;
	    send2.WRITE=0;
	    send1.SIGIN.set(0x00345678u); // data word
	}
	else if (i==2) { 
	    send1.WRITE=1;
	    send1.SIGIN.set(0x01212u); // data word
	} 
	else if (i==5) { 
	    send1.WRITE=1;
	    send1.SIGIN.set(0x02000000u); // data word
	} else {
	    send1.WRITE=0;
	}
	
	//HEADER activate
	if (i==3) {
	    send1.WRITE_SENDER_HEADER=1;
	    send1.SENDER_HEADER.set(0x01000000u); 
	    send2.WRITE_SENDER_HEADER=1;
	    send2.SENDER_HEADER.set(0x01000000u); 
	} else { 
	    send1.WRITE_SENDER_HEADER=0;
	    send2.WRITE_SENDER_HEADER=0;
	}

	for (int l=0;l<100;l++) {
	    //simulate READER
	    if (fan_in.DATAREADY_OUT_INT) fan_in.READ_IN_INT=1;
	    else fan_in.READ_IN_INT=0;
	    send1.Logic();
	    send2.Logic();
	    fan_in.Logic();
	    connect2(&send1.iobuffer, &send2.iobuffer, &fan_in);	    

	}

	//
	if (send1.iobuffer.DATAREADY)
	    cout << "DOWN MEDIA1 SIGOUT " << std::hex << send1.iobuffer.SIGOUT.get_value(0,27) << endl;
	else cout << "NO DOWN MEDIA1 DATA" << endl;

	if (send2.iobuffer.DATAREADY)
	    cout << "DOWN MEDIA2 SIGOUT " << std::hex << send2.iobuffer.SIGOUT.get_value(0,27) << endl;
	else cout << "NO DOWN MEDIA2 DATA" << endl;

	if (fan_in.DATAREADY_PORT1)
	    cout << "UP MEDIA1 SIGOUT " << std::hex << fan_in.SIGOUT_PORT1.get_value(0,27) << endl;
	else cout << "NO UP MEDIA1 DATA" << endl;
	
	if (fan_in.DATAREADY_PORT2)
	    cout << "UP MEDIA2 SIGOUT " << std::hex << fan_in.SIGOUT_PORT2.get_value(0,27) << endl;
	else cout << "NO UP MEDIA2 DATA" << endl;

	if (fan_in.DATAREADY_OUT_INT)
	    cout << "FAN MEDIA SIGOUT " << std::hex << fan_in.SIGOUT_INT.get_value(0,27) << endl;
	else cout << "NO FAN MEDIA DATA" << endl;

	//fan_in.Dump();
	//fan_in.myiobuf_port1.myibuf.Dump();

	send1.NextCLK();
	send2.NextCLK();
	fan_in.NextCLK();
	cout << "--------------------" << endl;
    }


}




int main(void) {

    //acktest();

    //iofifotest();
    
    fan_in_test();
}
