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

/*
 * T_AW8
 * Address setup time
 *
 * Time between A0, CS going down and WR/RD going down.
 */
#define T_AW8	100

/*
 * T_DS8
 * Data setup time
 *
 * Time between writing of data and WR going up.
 */
#define T_DS8	100

/*
 * T_DH8
 * Data hold time
 *
 * Time between WR going up and A0/CS going up
 */
#define T_DH8	100

/*
 * T_WAIT
 * Waiting time between transmission of two read/write
 *
 * Should be determined by the time taken by the slave.
 */
#define T_WAIT	100

/*
 * T_ACC8
 * RD Access time
 *
 * Time between RD going down and data is sampled.
 * Value must be determined by time taken by the slave.
 */
#define T_ACC8	100

/*
 * T_OH8
 * Output disable time
 *
 * Time between RD going up and data line direction is changed.
 */
#define T_OH8	100


void i8080_init(i8080_handler &i8080_port);

unsigned char i8080_write_data(	char data_buffer[],
								unsigned int n,
								i8080_handler &i8080_port);

unsigned char i8080_write_command(	unsigned char command,
							i8080_handler &i8080_port);


unsigned char i8080_read_status_flag(i8080_handler &i8080_port);

unsigned char i8080_read_status_flag(i8080_handler &i8080_port);



#endif /* 8080_MASTER_H_ */
