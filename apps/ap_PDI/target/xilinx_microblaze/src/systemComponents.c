/**
********************************************************************************
\file       xilinx_microblaze/src/systemComponents.c

\brief      Header file which contains processor specific definitions
            (Microblaze version)

This module contains of platform specific definitions.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

/*******************************************************************************/
/* includes */
#include "systemComponents.h"

#include "xgpio_l.h"
#include "mb_interface.h"
#include "xintc_l.h"

#ifdef CN_API_USING_SPI
#include "xspi.h"
#endif // CN_API_USING_SPI

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
#ifdef CN_API_USING_SPI
XSpi pSpiMaster;
#endif // CN_API_USING_SPI

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  init the peripherals of the AP

This function init's the peripherals of the AP like cache and the interrupt
controller.
*******************************************************************************/
void SysComp_initPeripheral(void)
{
    #if XPAR_MICROBLAZE_USE_ICACHE
        microblaze_invalidate_icache();
        microblaze_enable_icache();
    #endif

    #if XPAR_MICROBLAZE_USE_DCACHE
        microblaze_invalidate_dcache();
        microblaze_enable_dcache();
    #endif



#ifdef CN_API_USING_SPI
    XSpi_Initialize(&pSpiMaster, XPAR_SPI_MASTER_DEVICE_ID);
    XSpi_SetOptions(&pSpiMaster, XSP_MASTER_OPTION | XSP_CLK_ACTIVE_LOW_OPTION | XSP_CLK_PHASE_1_OPTION);

    //Start SPI controller
    XSpi_Start(&pSpiMaster);

    //global disable SPI interrupt
    XSpi_IntrGlobalDisable(&pSpiMaster);
    //select slave 0x01
    XSpi_SetSlaveSelect(&pSpiMaster,0x01);

#endif

    //disable all interrupts
    SysComp_disableSyncInterrupt();
    SysComp_disableAsyncInterrupt();

    //disable interrupt master
    XIntc_MasterDisable(XPAR_AP_INTC_BASEADDR);

    //enable interrupts on microblaze
    microblaze_enable_interrupts();
}

/**
********************************************************************************
\brief enables the microblaze interrupts

This function enables the microblaze interrupts
*******************************************************************************/
inline void SysComp_enableInterrupts(void)
{
    XIntc_MasterEnable(XPAR_AP_INTC_BASEADDR);     // enable interrupt master
}

/**
********************************************************************************
\brief disables the microblaze interrupts

This function disables the microblaze interrupts
*******************************************************************************/
inline void SysComp_disableInterrupts(void)
{
    XIntc_MasterDisable(XPAR_AP_INTC_BASEADDR);     // disable interrupt master
}


/**
********************************************************************************
\brief  initialize synchronous interrupt

SysComp_initSyncInterrupt() initializes the synchronous interrupt. The timing parameters
will be initialized, the interrupt handler will be connected and the interrupt
will be enabled.

\param  callbackFunc             The callback of the sync interrupt

\return    int
\retval OK                       on success
\retval ERROR                    if interrupt couldn't be connected
*******************************************************************************/
int SysComp_initSyncInterrupt(void (*callbackFunc)(void*))
{
    DWORD curIntEn = Xil_In32(XPAR_AP_INTC_BASEADDR+XIN_IER_OFFSET);

    //register sync irq handler
    XIntc_RegisterHandler(XPAR_AP_INTC_BASEADDR, SYNC_IRQ_NUM,
            (XInterruptHandler)callbackFunc, 0);

    //enable the sync interrupt
    XIntc_EnableIntr(XPAR_AP_INTC_BASEADDR, SYNC_IRQ_NUM_MASK | curIntEn);

    SysComp_enableInterrupts();

    return OK;
}

/**
********************************************************************************
\brief  Enable synchronous interrupt

SysComp_enableSyncInterrupt() enables the synchronous interrupt.
*******************************************************************************/
inline void SysComp_enableSyncInterrupt(void)
{
    DWORD curIntEn = Xil_In32(XPAR_AP_INTC_BASEADDR+XIN_IER_OFFSET);

    //enable the sync interrupt
    XIntc_EnableIntr(XPAR_AP_INTC_BASEADDR, SYNC_IRQ_NUM_MASK | curIntEn);
}

/**
********************************************************************************
\brief  Disable synchronous interrupt

SysComp_disableSyncInterrupt() disable the synchronous interrupt.
*******************************************************************************/
inline void SysComp_disableSyncInterrupt(void)
{
    DWORD curIntEn = Xil_In32(XPAR_AP_INTC_BASEADDR+XIN_IER_OFFSET);

    //disable the sync interrupt
    XIntc_DisableIntr(XPAR_AP_INTC_BASEADDR, SYNC_IRQ_NUM_MASK | curIntEn);
}

/**
********************************************************************************
\brief  initialize asynchronous interrupt

SysComp_initAsyncInterrupt() initializes the asynchronous interrupt. The interrupt handler
will be connected and the interrupt will be enabled.

\param  callbackFunc             The callback of the async interrupt

\return int
\retval OK                       on success
\retval ERROR                    if interrupt couldn't be connected
*******************************************************************************/
int SysComp_initAsyncInterrupt(void (*callbackFunc)(void*))
{
    DWORD curIntEn = Xil_In32(XPAR_AP_INTC_BASEADDR+XIN_IER_OFFSET);

    //register async irq handler
    XIntc_RegisterHandler(XPAR_AP_INTC_BASEADDR, ASYNC_IRQ_NUM,
            (XInterruptHandler)callbackFunc, 0);

    //enable the async interrupt
    XIntc_EnableIntr(XPAR_AP_INTC_BASEADDR, ASYNC_IRQ_NUM_MASK | curIntEn);

    SysComp_enableInterrupts();

    return OK;
}

/**
********************************************************************************
\brief  Enable synchronous interrupt

SysComp_enableSyncInterrupt() enables the synchronous interrupt.
*******************************************************************************/
inline void SysComp_enableAsyncInterrupt(void)
{
    DWORD curIntEn = Xil_In32(XPAR_AP_INTC_BASEADDR+XIN_IER_OFFSET);

    //enable the async interrupt
    XIntc_EnableIntr(XPAR_AP_INTC_BASEADDR, ASYNC_IRQ_NUM_MASK | curIntEn);
}

/**
********************************************************************************
\brief  Disable synchronous interrupt

SysComp_disableSyncInterrupt() disable the synchronous interrupt.
*******************************************************************************/
inline void SysComp_disableAsyncInterrupt(void)
{
    DWORD curIntEn = Xil_In32(XPAR_AP_INTC_BASEADDR+XIN_IER_OFFSET);

    //disable the sync interrupt
    XIntc_DisableIntr(XPAR_AP_INTC_BASEADDR, ASYNC_IRQ_NUM_MASK | curIntEn);
}

#ifdef CN_API_USING_SPI
/**
********************************************************************************
\brief  Execute SPI command

SysComp_SPICommand() sends an SPI command to the SPI master by using the
alt_avalon_spi_command function

\param  pTxBuf_p             A pointer to the buffer to send
\param  pRxBuf_p             A pointer to the buffer where the data should be stored
\param  iBytes_p             The number of bytes to send or receive

\return int
\retval OK                       on success
\retval ERROR                    in case of an error
*******************************************************************************/
int SysComp_SPICommand(unsigned char *pTxBuf_p, unsigned char *pRxBuf_p, int iBytes_p)
{

    if(pTxBuf_p != NULL)
    {
        //do send
        if(XSpi_Transfer(&pSpiMaster, pTxBuf_p, NULL, iBytes_p) != XST_SUCCESS)
        {
            return ERROR;
        }
    } else {
        //do receive
        memset(pRxBuf_p,0,iBytes_p);
        if(XSpi_Transfer(&pSpiMaster, pRxBuf_p, pRxBuf_p, iBytes_p) != XST_SUCCESS)
        {
            return ERROR;
        }
    }

    return OK;
}
#endif //CN_API_USING_SPI

/**
********************************************************************************
\brief  write a value to the output port

This function writes a value to the output port of the AP

\param  dwValue_p       the value to write
*******************************************************************************/
void SysComp_writeOutputPort(DWORD dwValue_p)
{
    #ifdef OUTPORT_AP_BASE_ADDRESS
        XGpio_WriteReg(OUTPORT_AP_BASE_ADDRESS, XGPIO_DATA_OFFSET, dwValue_p);
    #endif
}

/**
********************************************************************************
\brief  read a value from the input port

This function reads a value from the input port of the AP

\return  DWORD
\retval  dwValue              the value of the input port
*******************************************************************************/
DWORD SysComp_readInputPort(void)
{
    DWORD dwValue = 0;

    #ifdef INPORT_AP_BASE_ADDRESS
        dwValue = XGpio_ReadReg(INPORT_AP_BASE_ADDRESS, XGPIO_DATA_OFFSET);
    #endif

    return dwValue;
}

/*******************************************************************************
*
* License Agreement
*
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved.
*
* Redistribution and use in source and binary forms,
* with or without modification,
* are permitted provided that the following conditions are met:
*
*   * Redistributions of source code must retain the above copyright notice,
*     this list of conditions and the following disclaimer.
*   * Redistributions in binary form must reproduce the above copyright notice,
*     this list of conditions and the following disclaimer
*     in the documentation and/or other materials provided with the
*     distribution.
*   * Neither the name of the B&R nor the names of its contributors
*     may be used to endorse or promote products derived from this software
*     without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
* A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
* THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
*******************************************************************************/
/* END-OF-FILE */

