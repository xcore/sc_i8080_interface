/*
 * 8080_master.h
 *
 *  Created on: Aug 8, 2012
 *      Author: Siva
 */

#ifndef i8080_MASTER_H_
#define i8080_MASTER_H_

#include <xs1.h>


typedef struct p_i8080
{
	port data_port;
	out port control_port;
	out port reset;
} i8080_handler;

void i8080_init(i8080_handler &i8080_port);

void i8080_write_data(	char data_buffer[],
						unsigned int n,
						i8080_handler &i8080_port);

void i8080_write_command(	unsigned char command,
							i8080_handler &i8080_port);


unsigned char i8080_read_status_flag(i8080_handler &i8080_port);

unsigned char i8080_read_status_flag(i8080_handler &i8080_port);



#endif /* 8080_MASTER_H_ */
