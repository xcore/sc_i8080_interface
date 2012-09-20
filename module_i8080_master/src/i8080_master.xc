#include <xs1.h>
#include "i8080_master.h"


#define i8080_A0				(1 << 0)
#define i8080_WR				(1 << 1)
#define i8080_RD				(1 << 2)
#define i8080_CS				(1 << 3)





void i8080_init(i8080_handler &i8080_port)
{
	i8080_port.data_port <: 0xff;
	i8080_port.control_port <: 0xf;
	i8080_port.reset <: 1;
}

void i8080_write_data(	char data_buffer[],
						unsigned int n,
						i8080_handler &i8080_port)
{
	unsigned short i, temp;
	unsigned time;
	timer t;
	for(i=0;i<n;i++)
	{
		temp = peek(i8080_port.control_port)&~(i8080_A0|i8080_CS);
		i8080_port.control_port <: temp;
		temp &=~i8080_WR;
		i8080_port.control_port <: (temp);
		i8080_port.data_port <: data_buffer[i];
		t:> time;
		t when timerafter(time+22) :> void; //minimum strobe time
		temp = peek(i8080_port.control_port);
		i8080_port.control_port <: 0xf;
		t:> time;
		t when timerafter(time+5) :> void; //minimum strobe time
	}
}

void i8080_write_command(	unsigned char command,
							i8080_handler &i8080_port)
{
	unsigned time, temp;
	timer t;
	temp = peek(i8080_port.control_port)&~i8080_CS;
	i8080_port.control_port <: temp;
	i8080_port.control_port <: temp &~i8080_WR;
	i8080_port.data_port <: command;
	t:> time;
	t when timerafter(time+22) :> void;
	temp = peek(i8080_port.control_port);
	i8080_port.control_port <: temp|(i8080_A0|i8080_WR|i8080_CS);
	t:> time;
	t when timerafter(time+5) :> void; //time between 2 strobes
}

unsigned char i8080_read_status_flag(i8080_handler &i8080_port)
{
	unsigned time, temp;
	timer t;
	i8080_port.data_port :> void;
	temp = peek(i8080_port.control_port)& ~i8080_CS;
	i8080_port.control_port <: temp;
	i8080_port.control_port <: temp& ~i8080_RD;

	t:> time;
	t when timerafter(time+12) :> void; //RD access time
	i8080_port.data_port :> temp;

	i8080_port.control_port <: 0xf;
	t:> time;
	t when timerafter(time+5) :> void; //time between 2 strobes
	return temp;
}



