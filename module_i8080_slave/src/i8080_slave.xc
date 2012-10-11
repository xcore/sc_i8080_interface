#include <xs1.h>
#include "i8080_slave.h"


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
#define CS_WR_A0_0		0b0100
#define	CS_RD_A0_0		0b0010
#define CS_A0_1			0b0111
#define CS_WR_A0_1		0b0101
#define	CS_RD_A0_1		0b0011


#define i8080_COMMAND_MASK		0X100

enum i8080_STATES
{
	wait,
	chip_selected,
	write_data_setup,
	write_data_hold,
	read_output_disable,
	read_access,
};


unsigned char i8080_slave(	chanend c8080,
							i8080_handler &i8080_port)
{
	unsigned char control_signal, temp, i = 0, state = wait;
	unsigned status = 0;
	unsigned buffer[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};


	/*Wait till the waiting state is reached*/
	i8080_port.control_port when pinseq(WAITING):> control_signal;

	while(1)
	{
		select
		{
			case i8080_port.control_port when pinsneq(control_signal) :> control_signal:
			{
				switch (state)
				{
#pragma fallthrough
				case wait:
				{
					if((control_signal ==  CS_A0_0)||
					   (control_signal ==  CS_A0_1))
					{
						state = chip_selected;
						break;
					}
					else
					{
						return 0;
					}
				}
#pragma fallthrough
				case chip_selected:
				{
					if((control_signal == CS_WR_A0_0)||
					   (control_signal == CS_WR_A0_1))
					{
						state = write_data_setup;
						break;
					}
					else if (control_signal == CS_RD_A0_1) //Data read
					{
						state = read_access;
						i8080_port.data_port <: 0x67; //Insert data or function call
						state = read_output_disable;
						break;
					}
					else if(control_signal == CS_RD_A0_0)
					{
						state = read_access;
						i8080_port.data_port <: 0x78; //Insert status or function call
						state = read_output_disable;
						break;
					}
					else
					{
						return 0;
					}
				}
#pragma fallthrough
				case write_data_setup:
				{
					if(control_signal == CS_A0_1)
					{
						state = write_data_hold;
						i8080_port.data_port :> temp;
						buffer[i++] = temp|i8080_COMMAND_MASK;
						//c8080 <: temp|i8080_COMMAND_MASK;
						break;
					}
					else if (control_signal == CS_A0_0)
					{
						state = write_data_hold;
						i8080_port.data_port :> temp;
						buffer[i++] = temp;
						//c8080 <: temp;
						break;
					}
					else
					{
						return 0;
					}

				}
#pragma fallthrough
				case write_data_hold:
				{
					if(control_signal == WAITING)
					{
						state = wait;
						break;
					}
					else
					{
						return 0;
					}
				}
#pragma fallthrough
				case read_access:
				{
					if(control_signal == WAITING)
					{
						state = wait;
						i8080_port.data_port :> void;
						break;
					}
					else
					{
						return 0;
					}
				}
				}
				break;
			}
//			case i8080_port.reset when pinseq(0):> temp:
//				// call reset function here.
//				break;
		}
	}
}
