/*
 * i8080_slave.h
 *
 *  Created on: Sep 18, 2012
 *      Author: Siva
 */

#ifndef I8080_SLAVE_H_
#define I8080_SLAVE_H_



typedef struct p_i8080
{
	port data_port;
	in port control_port;
	in port reset;
} i8080_handler;



void i8080_slave(	chanend c8080,
					i8080_handler &i8080_port);

#endif /* I8080_SLAVE_H_ */
