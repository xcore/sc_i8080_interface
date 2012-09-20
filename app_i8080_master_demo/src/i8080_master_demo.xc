#include <xs1.h>
#include "i8080_master.h"



i8080_handler i8080_port = {XS1_PORT_8A, XS1_PORT_4C, XS1_PORT_1A};

void main(void)
{
	unsigned char data_to_send[] = {1,2,3,4,5,6,7,8,9,10};
	i8080_init(i8080_port);
	while (1)
	{
		i8080_write_command(0x10, i8080_port);
		i8080_write_data(data_to_send,10, i8080_port);
		while(1);
	}
}
