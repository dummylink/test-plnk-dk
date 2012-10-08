/**
********************************************************************************
\file       systemComponents.c

\brief      Module which contains of platform dependent functions
            (Nios II version)

This header file contains of platform specific definitions.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

/*******************************************************************************/
/* includes */
#include "systemComponents.h"

#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include <sys/alt_cache.h>
#include <sys/alt_irq.h>
#include <io.h>

#ifdef CN_API_USING_SPI
#include "altera_avalon_spi.h"
#endif // CN_API_USING_SPI

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
alt_irq_context iInterruptContext_g = 0;
BYTE bAsyncIntEnable = FALSE;
BYTE bSyncIntEnable = FALSE;

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */


/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  inits the peripherals of the AP

This function inits the peripherals of the AP like cache and the interrupt
controller.
*******************************************************************************/
void SysComp_initPeripheral(void)
{
    alt_icache_flush_all();
    alt_dcache_flush_all();

}

/**
********************************************************************************
\brief enables the microblaze interrupts

This function enables the microblaze interrupts
*******************************************************************************/
inline void SysComp_enableInterrupts(void)
{
    /* global interrupt disable is not possible with the Altera SPI driver
     * because this driver uses interrupts for send and receive. In this case
     * this interrupt would also be disabled and would results in an error.
     */
    if(bSyncIntEnable != FALSE)
        SysComp_enableSyncInterrupt();

    if(bAsyncIntEnable != FALSE)
        SysComp_enableAsyncInterrupt();
}

/**
********************************************************************************
\brief disables the microblaze interrupts

This function disables the microblaze interrupts
*******************************************************************************/
inline void SysComp_disableInterrupts(void)
{
    /* global interrupt disable is not possible with the Altera SPI driver
     * because this driver uses interrupts for send and receive. In this case
     * this interrupt would also be disabled and this results in an error.
     */
    if(bSyncIntEnable != FALSE)
    SysComp_disableSyncInterrupt();

    if(bAsyncIntEnable != FALSE)
        SysComp_disableAsyncInterrupt();
}

/**
********************************************************************************
\brief  initialize synchronous interrupt

SysComp_initSyncInterrupt() initializes the synchronous interrupt. The timing parameters
will be initialized, the interrupt handler will be connected and the interrupt
will be enabled.

\param  callback             The callback of the interrupt
\param  dwMinCycleTime_p     The minimum cycle time for the interrupt
\param  dwMaxCycleTime_p     The maximum cycle time for the interrupt
\param  bReserved_p          Reserved for future use

\return	OK, or ERROR if interrupt couldn't be connected
*******************************************************************************/
#ifndef ALT_ENHANCED_INTERRUPT_API_PRESENT
int SysComp_initSyncInterrupt(void (*callbackFunc)(void*, void*))
#else
int SysComp_initSyncInterrupt(void (*callbackFunc)(void*))
#endif
{
    /* register interrupt handler */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
    if (alt_ic_isr_register(0, SYNC_IRQ_NUM, callbackFunc, NULL, 0))
    {
        return ERROR;
    }
#else
    if (alt_irq_register(SYNC_IRQ_NUM, NULL, callbackFunc))
    {
        return ERROR;
    }
#endif

    /* enable interrupt from PCP to AP */
#ifdef CN_API_USING_SPI
    alt_ic_irq_enable(0, SYNC_IRQ_NUM);      // enable specific IRQ Number
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(SYNC_IRQ_BASE, 0x01);
#endif /* CN_API_USING_SPI */

    bSyncIntEnable = TRUE;

    return OK;
}

/**
********************************************************************************
\brief  Enable synchronous interrupt

SysComp_enableSyncInterrupt() enables the synchronous interrupt.

*******************************************************************************/
inline void SysComp_enableSyncInterrupt(void)
{
    alt_ic_irq_enable(0, SYNC_IRQ_NUM);  // enable specific IRQ Number
}

/**
********************************************************************************
\brief  Disable synchronous interrupt

SysComp_disableSyncInterrupt() disable the synchronous interrupt.

*******************************************************************************/
inline void SysComp_disableSyncInterrupt(void)
{
    alt_ic_irq_disable(0, SYNC_IRQ_NUM);  // disable specific IRQ Number
}


/**
********************************************************************************
\brief  initialize asynchronous interrupt

SysComp_initAsyncInterrupt() initializes the asynchronous interrupt. The interrupt handler
will be connected and the interrupt will be enabled.

\param  callback             The callback of the interrupt

\return OK, or ERROR if interrupt couldn't be connected
*******************************************************************************/
#ifndef ALT_ENHANCED_INTERRUPT_API_PRESENT
int SysComp_initAsyncInterrupt(void (*callbackFunc)(void*, void*))
#else
int SysComp_initAsyncInterrupt(void (*callbackFunc)(void*))
#endif
{
    /* register interrupt handler */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
    if (alt_ic_isr_register(0, ASYNC_IRQ_NUM, callbackFunc, NULL, 0))
    {
        return ERROR;
    }
#else
    if (alt_irq_register(ASYNC_IRQ_NUM, NULL, callbackFunc))
    {
        return ERROR;
    }
#endif

    /* enable interrupt from PCP to AP */
#ifdef CN_API_USING_SPI
    alt_ic_irq_enable(0, ASYNC_IRQ_NUM);      // enable specific IRQ Number
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(ASYNC_IRQ_BASE, 0x01);
#endif /* CN_API_USING_SPI */

    bAsyncIntEnable = TRUE;

    return OK;
}

/**
********************************************************************************
\brief  Enable synchronous interrupt

SysComp_enableSyncInterrupt() enables the synchronous interrupt.

*******************************************************************************/
inline void SysComp_enableAsyncInterrupt(void)
{
    alt_ic_irq_enable(0, ASYNC_IRQ_NUM);  // enable specific IRQ Number
}

/**
********************************************************************************
\brief  Disable synchronous interrupt

SysComp_disableSyncInterrupt() disable the synchronous interrupt.

*******************************************************************************/
inline void SysComp_disableAsyncInterrupt(void)
{
    alt_ic_irq_disable(0, ASYNC_IRQ_NUM);  // disable specific IRQ Number
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

*******************************************************************************/
int SysComp_SPICommand(unsigned char *pTxBuf_p, unsigned char *pRxBuf_p, int iBytes_p)
{
    if(pTxBuf_p != NULL)
    {
        //do write
        alt_avalon_spi_command(
            SPI_MASTER_BASE, 0, //core base, spi slave
            iBytes_p, pTxBuf_p, //write bytes, addr of write data
            0, NULL,            //read bytes, addr of read data
            0);                 //flags (don't care)
    } else {
        //do read
        alt_avalon_spi_command(
            SPI_MASTER_BASE, 0, //core base, spi slave
            0, NULL,            //write bytes, addr of write data
            iBytes_p, pRxBuf_p, //read bytes, addr of read data
            0);                 //flags (don't care)
    }

    return OK;
}
#endif //CN_API_USING_SPI

/**
********************************************************************************
\brief  write a value to the output port

This function writes a value to the output port of the AP

\param  bValue_p       the value to write
*******************************************************************************/
void SysComp_writeOutputPort(DWORD dwValue_p)
{
    #ifdef OUTPORT_AP_BASE_ADDRESS
        IOWR_ALTERA_AVALON_PIO_DATA(OUTPORT_AP_BASE_ADDRESS, dwValue_p);
    #endif
}

/**
********************************************************************************
\brief  read a value from the input port

This function reads a value from the input port of the AP

\return  bValue_p       the read value
*******************************************************************************/
DWORD SysComp_readInputPort(void)
{
	DWORD dwValue = 0;

    #ifdef INPORT_AP_BASE_ADDRESS
        dwValue = IORD_ALTERA_AVALON_PIO_DATA(INPORT_AP_BASE_ADDRESS);
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

