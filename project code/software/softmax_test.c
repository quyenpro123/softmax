/*
 * softmax_test.c
 *
 *  Created on: Apr 11, 2024
=====================================================================================
=                                                                                   =
=   Author: Hoang Van Quyen - UET - VNU                                             =
=                                                                                   =
=====================================================================================
 */
#include "xaxidma.h"
#include "stdio.h"
#include "xparameters.h"
#include "time.h"
#include "reset_ip.h"
#include "xil_io.h"
#include "xil_cache.h"

u32 checkHalted(u32 baseAddress,u32 offset);

int main(){
	u32 n = 5;
	float a[] = {-1.760, -2.377, 3.336, -3.179, -0.851};
	u32 b[n];
    u32 status;

    enable_reset();
    sleep(1);
    disable_reset();

	XAxiDma_Config *myDmaConfig;
	XAxiDma myDma;

	myDmaConfig = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
	status = XAxiDma_CfgInitialize(&myDma, myDmaConfig);
	if(status != XST_SUCCESS){
		print("DMA initialization failed\n");
		return -1;
	}
	print("DMA initialization success..\n");
	status = checkHalted(XPAR_AXI_DMA_0_BASEADDR, 0x4);
	xil_printf("Status before data transfer %0x\n", status);

	Xil_DCacheFlushRange((u32) a, n * sizeof(float));
	Xil_DCacheInvalidateRange((u32) a, n * sizeof(float));


	status = XAxiDma_SimpleTransfer(&myDma, (u32) b, n * sizeof(u32), XAXIDMA_DEVICE_TO_DMA);
	status = XAxiDma_SimpleTransfer(&myDma, (u32) a, n * sizeof(float), XAXIDMA_DMA_TO_DEVICE);//typecasting in C/C++
	if(status != XST_SUCCESS){
		print("DMA initialization failed\n");
		return -1;
	}
    status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
    while(status != 1){
    	status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
    }
    status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x34);
    while(status != 1){
    	status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x34);
    }
    sleep(1);
    Xil_DCacheFlushRange((u32) b, n * sizeof(u32));
    Xil_DCacheInvalidateRange((u32) b, n * sizeof(u32));
	print("DMA transfer success..\n");
	for(int i = 0 ; i < n ; i++)
		xil_printf("%0x\n",b[i]);
}


u32 checkHalted(u32 baseAddress, u32 offset){
	u32 status;
	status = (XAxiDma_ReadReg(baseAddress, offset)) & XAXIDMA_HALTED_MASK;
	return status;
}
