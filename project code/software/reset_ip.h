/*
 * reset_ip.h
 *
 *  Created on: Apr 11, 2024
=====================================================================================
=                                                                                   =
=   Author: Hoang Van Quyen - UET - VNU                                             =
=                                                                                   =
=====================================================================================
 */
#include <xil_types.h>
#include "xparameters.h"
#ifndef SRC_RESET_IP_H_
#define SRC_RESET_IP_H_

void enable_reset() {
	Xil_Out32(XPAR_SOFTMAX_IP_RESET_0_S_AXI_BASEADDR, 0x00);
}

void disable_reset() {
	Xil_Out32(XPAR_SOFTMAX_IP_RESET_0_S_AXI_BASEADDR, 0xff);
}

#endif /* SRC_RESET_IP_H_ */
