/*
 * Copyright (c) 2009 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

/*
 * helloworld.c: simple test application
 */

#include "xil_io.h"

#define SLCR_LOCK	0xF8000004 /**< SLCR Write Protection Lock */
#define SLCR_UNLOCK	0xF8000008 /**< SLCR Write Protection Unlock */
#define SLCR_LOCK_VAL	0x767B
#define SLCR_UNLOCK_VAL	0xDF0D

#define AFI_WRCHAN_CTRL0 0xF8008014
#define AFI_RDCHAN_CTRL0 0xF8008000
#define AFI_WRCHAN_CTRL1 0xF8009014
#define AFI_RDCHAN_CTRL1 0xF8009000
#define AFI_WRCHAN_CTRL2 0xF800A014
#define AFI_RDCHAN_CTRL2 0xF800A000
#define AFI_WRCHAN_CTRL3 0xF800B014
#define AFI_RDCHAN_CTRL3 0xF800B000

int main()
{
	Xil_DCacheDisable();

	//take mb out of reset
	Xil_Out32(SLCR_UNLOCK, SLCR_UNLOCK_VAL);
    Xil_Out32(0xf8000240,0);
    Xil_Out32(SLCR_LOCK, SLCR_LOCK_VAL);

	xil_printf( "AFI_WRCHAN_CTRL0 0x%x \n\r",Xil_In32(AFI_WRCHAN_CTRL0) );
	xil_printf( "AFI_RDCHAN_CTRL0 0x%x \n\r",Xil_In32(AFI_RDCHAN_CTRL0) );
	xil_printf( "AFI_WRCHAN_CTRL1 0x%x \n\r",Xil_In32(AFI_WRCHAN_CTRL1) );
	xil_printf( "AFI_RDCHAN_CTRL1 0x%x \n\r",Xil_In32(AFI_RDCHAN_CTRL1) );
	xil_printf( "AFI_WRCHAN_CTRL2 0x%x \n\r",Xil_In32(AFI_WRCHAN_CTRL2) );
	xil_printf( "AFI_RDCHAN_CTRL2 0x%x \n\r",Xil_In32(AFI_RDCHAN_CTRL2) );
	xil_printf( "AFI_WRCHAN_CTRL3 0x%x \n\r",Xil_In32(AFI_WRCHAN_CTRL3) );
	xil_printf( "AFI_RDCHAN_CTRL3 0x%x \n\r",Xil_In32(AFI_RDCHAN_CTRL3) );

    while(1);
    
    return 0;
}