#include <xs1.h>
#include "i8080_master.h"


/******************************************************************
*                                                                 *
*     i8080.data_port		4321                                  *
*     						||||                                  *
*                           |||+---A0                             *
*                           ||+----WR                             *
*                           |+-----RD                             *
*    						+------CS                             *
*    						                                      *
*    					                                          *
******************************************************************/


#define	WAITING			0b1110
#define CS_A0_0			0b0110
#define CS_WR_A0_0		0b0100		//Write data and display parameters
#define	CS_RD_A0_0		0b0010		//Read status
#define CS_A0_1			0b0111
#define CS_WR_A0_1		0b0101		//Write command
#define	CS_RD_A0_1		0b0011		//Read display data and cursor address





void i8080_init(i8080_handler &i8080_port)
{
	i8080_port.data_port <: 0xff;
	i8080_port.control_port <: WAITING;
	i8080_port.reset <: 1;
}

unsigned char i8080_write_data(	char data_buffer[],
								unsigned int n,
								i8080_handler &i8080_port)
{
	unsigned short i, temp;
	unsigned time;
	timer t;
	if(peek(i8080_port.control_port)!=WAITING)
	{
		return 0;
	}
	else
	{
		for(i=0;i<n;i++)
		{
			/*pull down A0 and CS*/
			i8080_port.control_port <: CS_A0_0;
			/*Start write strobe after address setup time*/
			t:> time;
			t when timerafter(time+T_AW8) :> void;
			i8080_port.control_port <: CS_WR_A0_0;
			i8080_port.data_port <: data_buffer[i];
			t:> time;
			t when timerafter(time+T_DS8) :> void;
			i8080_port.control_port <: CS_A0_0;
			t:> time;
			t when timerafter(time+T_DH8) :> void;
			i8080_port.control_port <: WAITING;
		}
	}
}

unsigned char i8080_write_command(	unsigned char command,
							i8080_handler &i8080_port)
{
	unsigned time, temp;
	timer t;
	if(peek(i8080_port.control_port)!=WAITING)
	{
		return 0;
	}
	else
	{
		/*pull down CS*/
		i8080_port.control_port <: CS_A0_1;
		/*Start write strobe after address setup time*/
		t:> time;
		t when timerafter(time+T_AW8) :> void;
		i8080_port.control_port <: CS_WR_A0_1;
		i8080_port.data_port <: command;
		t:> time;
		t when timerafter(time+T_DS8) :> void;
		i8080_port.control_port <: CS_A0_1;
		t:> time;
		t when timerafter(time+T_DH8) :> void;
		i8080_port.control_port <: WAITING;
	}
}

unsigned char i8080_read_status_flag(i8080_handler &i8080_port)
{
	unsigned time, temp;
	timer t;
	if(peek(i8080_port.control_port)!=WAITING)
	{
		return 0;
	}
	else
	{
		/*pull down CS*/
		i8080_port.control_port <: CS_A0_1;
		/*Start write strobe after address setup time*/
		t:> time;
		t when timerafter(time+T_AW8) :> void;
		/*Change direction of data bus*/
		i8080_port.data_port :> void;
		i8080_port.control_port <: CS_RD_A0_1;
		t:> time;
		t when timerafter(time+T_ACC8) :> void;
		/*Read from data port*/
		i8080_port.data_port :> temp;
		i8080_port.control_port <: CS_A0_1;
		t:> time;
		t when timerafter(time+T_OH8) :> void;
		i8080_port.data_port <:0xFF;
		i8080_port.control_port <: WAITING;
		return temp;
	}
}



