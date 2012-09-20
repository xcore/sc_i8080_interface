#include <xs1.h>
#include "i8080_slave.h"

#define i8080_A0				(1 << 0)
#define i8080_WR				(1 << 1)
#define i8080_RD				(1 << 2)
#define i8080_CS				(1 << 3)



#define i8080_WRITE_DATA	i8080_RD
#define i8080_WRITE_COMMAND	0b101		//i8080_RD|i8080_A0
#define i8080_READ_STATUS	i8080_WR




void i8080_slave(	chanend c8080,
					i8080_handler &i8080_port)
{
	unsigned char control_signal, temp;
	unsigned status = 0;
	while(1)
	{
		select
		{
			case i8080_port.control_port when pinsneq(0xf) :> control_signal:
			{
				if(~(control_signal&i8080_CS))
				{
					switch (control_signal)
					{
						case i8080_WRITE_DATA:
							i8080_port.data_port :> temp;
							c8080 <: temp;
							break;
						case i8080_WRITE_COMMAND:
							i8080_port.data_port :>temp;
							c8080 <: temp;
							break;
						case i8080_READ_STATUS:
							i8080_port.data_port <: status++; //call the status function here
							i8080_port.control_port when pinsneq(0xf) :> void;
							i8080_port.data_port :> void;
							break;
						default:
							break;
					}

				}
				break;
			}
			case i8080_port.reset when pinseq(0):> void:
				// call reset function here.
				break;
		}
	}
}
