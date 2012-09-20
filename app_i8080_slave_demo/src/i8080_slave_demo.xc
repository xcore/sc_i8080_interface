#include <xs1.h>
#include "i8080_slave.h"
#include "stdio.h"


i8080_handler i8080_port = {XS1_PORT_8A, XS1_PORT_4C, XS1_PORT_1A};

void buffer_thread(chanend c8080);



void main(void)
{
	chan c8080;
	unsigned char TEMP;

	par
	{
		i8080_slave(c8080, i8080_port);
		buffer_thread(c8080);
	}
}


void buffer_thread(chanend c8080)
{
	unsigned char i, buffer[100];
	for (i = 0;i<11;i++)
	{
		c8080 :> buffer[i];
	}
	for (i = 0;i<11;i++)
	{
		printf("%d",buffer[i]);
	}
}
