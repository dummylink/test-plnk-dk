/**
********************************************************************************
\file       systemComponents.h

\brief      Header file which contains processor specific definitions
            (Microblaze version)

This header file contains of platform specific definitions.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef SYSTEMCOMPONENTS_H_
#define SYSTEMCOMPONENTS_H_

/******************************************************************************/
/* includes */
#include "xparameters.h"

#include "cnApiGlobal.h"
#include "cnApiCfg.h"

#include <string.h>
#include <stdio.h>

/******************************************************************************/
/* defines */
#if XPAR_MICROBLAZE_ENDIANNESS == 0           /* MICROBLAZE is big endian (PLB bus) */
#ifdef CN_API_USING_SPI
    #define PDI_DPRAM_BASE_AP    0x00                       ///< no base address necessary
#elif defined(CN_API_USING_16BIT) || defined(CN_API_USING_8BIT)
    #ifdef XPAR_XPS_MCH_EMC_0_MEM0_BASEADDR
      #define PDI_DPRAM_BASE_AP    XPAR_XPS_MCH_EMC_0_MEM0_BASEADDR
    #elif defined(XPAR_XPS_EPC_0_PRH0_BASEADDR)
      #define PDI_DPRAM_BASE_AP    XPAR_XPS_EPC_0_PRH0_BASEADDR
    #endif
#else
    #define PDI_DPRAM_BASE_AP    XPAR_PLB_POWERLINK_0_PDI_AP_BASEADDR           ///< from xparameters.h
#endif

#if defined(CN_API_USING_16BIT) || defined(CN_API_USING_8BIT)
  #ifdef XPAR_AP_INTC_SYSTEM_PLB_POWERLINK_0_AP_SYNCIRQ_PIN_INTR
   #define SYNC_IRQ_NUM XPAR_AP_INTC_SYSTEM_PLB_POWERLINK_0_AP_SYNCIRQ_PIN_INTR
   #define SYNC_IRQ_NUM_MASK XPAR_SYSTEM_PLB_POWERLINK_0_AP_SYNCIRQ_PIN_MASK
  #endif //XPAR_AP_INTC_PLB_POWERLINK_0_AP_SYNCIRQ_INTR
#else
  #ifdef XPAR_AP_INTC_PLB_POWERLINK_0_AP_SYNCIRQ_INTR
   #define SYNC_IRQ_NUM XPAR_AP_INTC_PLB_POWERLINK_0_AP_SYNCIRQ_INTR
   #define SYNC_IRQ_NUM_MASK XPAR_PLB_POWERLINK_0_AP_SYNCIRQ_MASK
  #endif //XPAR_AP_INTC_PLB_POWERLINK_0_AP_SYNCIRQ_INTR
#endif

#if defined(CN_API_USING_16BIT) || defined(CN_API_USING_8BIT)
  #ifdef XPAR_AP_INTC_SYSTEM_PLB_POWERLINK_0_AP_ASYNCIRQ_PIN_INTR
   #define ASYNC_IRQ_NUM XPAR_AP_INTC_SYSTEM_PLB_POWERLINK_0_AP_ASYNCIRQ_PIN_INTR
   #define ASYNC_IRQ_NUM_MASK XPAR_SYSTEM_PLB_POWERLINK_0_AP_ASYNCIRQ_PIN_MASK
  #endif //XPAR_AP_INTC_PLB_POWERLINK_0_AP_ASYNCIRQ_INTR
#else
  #ifdef XPAR_AP_INTC_PLB_POWERLINK_0_AP_ASYNCIRQ_INTR
   #define ASYNC_IRQ_NUM XPAR_AP_INTC_PLB_POWERLINK_0_AP_ASYNCIRQ_INTR
   #define ASYNC_IRQ_NUM_MASK XPAR_PLB_POWERLINK_0_AP_ASYNCIRQ_MASK
  #endif //XPAR_AP_INTC_PLB_POWERLINK_0_AP_ASYNCIRQ_INTR
#endif

#elif XPAR_MICROBLAZE_ENDIANNESS == 1           /* MICROBLAZE is little endian (AXI bus) */
#ifdef CN_API_USING_SPI
    #define PDI_DPRAM_BASE_AP    0x00                       ///< no base address necessary
#elif defined(CN_API_USING_16BIT) || defined(CN_API_USING_8BIT)
    #define PDI_DPRAM_BASE_AP    XPAR_AXI_EMC_0_S_AXI_MEM0_BASEADDR
#else
    #define PDI_DPRAM_BASE_AP    XPAR_AXI_POWERLINK_0_S_AXI_PDI_AP_BASEADDR           ///< from xparameters.h
#endif

#if defined(CN_API_USING_16BIT) || defined(CN_API_USING_8BIT)
  #ifdef XPAR_AP_INTC_SYSTEM_AXI_POWERLINK_0_AP_SYNCIRQ_PIN_INTR
   #define SYNC_IRQ_NUM XPAR_AP_INTC_SYSTEM_AXI_POWERLINK_0_AP_SYNCIRQ_PIN_INTR
   #define SYNC_IRQ_NUM_MASK XPAR_SYSTEM_AXI_POWERLINK_0_AP_SYNCIRQ_PIN_MASK
  #endif //XPAR_AP_INTC_SYSTEM_AXI_POWERLINK_0_AP_SYNCIRQ_PIN_INTR
#else
  #ifdef XPAR_AP_INTC_AXI_POWERLINK_0_AP_SYNCIRQ_INTR
   #define SYNC_IRQ_NUM XPAR_AP_INTC_AXI_POWERLINK_0_AP_SYNCIRQ_INTR
   #define SYNC_IRQ_NUM_MASK XPAR_AXI_POWERLINK_0_AP_SYNCIRQ_MASK
  #endif //XPAR_AP_INTC_AXI_POWERLINK_0_AP_SYNCIRQ_INTR
#endif

#if defined(CN_API_USING_16BIT) || defined(CN_API_USING_8BIT)
  #ifdef XPAR_AP_INTC_SYSTEM_AXI_POWERLINK_0_AP_ASYNCIRQ_PIN_INTR
   #define ASYNC_IRQ_NUM XPAR_AP_INTC_SYSTEM_AXI_POWERLINK_0_AP_ASYNCIRQ_PIN_INTR
   #define ASYNC_IRQ_NUM_MASK XPAR_SYSTEM_AXI_POWERLINK_0_AP_ASYNCIRQ_PIN_MASK
  #endif //XPAR_AP_INTC_PLB_POWERLINK_0_AP_ASYNCIRQ_INTR
#else
  #ifdef XPAR_AP_INTC_AXI_POWERLINK_0_AP_ASYNCIRQ_INTR
   #define ASYNC_IRQ_NUM XPAR_AP_INTC_AXI_POWERLINK_0_AP_ASYNCIRQ_INTR
   #define ASYNC_IRQ_NUM_MASK XPAR_AXI_POWERLINK_0_AP_ASYNCIRQ_MASK
  #endif //XPAR_AP_INTC_AXI_POWERLINK_0_AP_ASYNCIRQ_INTR
#endif
#else
    #error "The used bus system is unknown! (Should be PLB or AXI)"
#endif

#if defined(CN_API_USING_SPI) && !defined(XPAR_SPI_MASTER_DEVICE_ID)
    #error "The cnApiCfg.h configuration header uses SPI but there is no SPI IP-Core included in the system! (Please check makefile.settings)"
#endif

#ifdef XPAR_AP_OUTPUT_BASEADDR
#define OUTPORT_AP_BASE_ADDRESS XPAR_AP_OUTPUT_BASEADDR
#endif

#ifdef XPAR_AP_INPUT_BASEADDR
#define INPORT_AP_BASE_ADDRESS XPAR_AP_INPUT_BASEADDR
#endif

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */
void SysComp_initPeripheral(void);
inline void SysComp_enableInterrupts(void);
inline void SysComp_disableInterrupts(void);
void SysComp_freeProcessorCache(void);

int SysComp_initSyncInterrupt(void (*callbackFunc)(void*));
int SysComp_initAsyncInterrupt(void (*callbackFunc)(void*));

inline void SysComp_enableSyncInterrupt(void);
inline void SysComp_disableSyncInterrupt(void);

inline void SysComp_enableAsyncInterrupt(void);
inline void SysComp_disableAsyncInterrupt(void);

#ifdef CN_API_USING_SPI
int SysComp_SPICommand(unsigned char *pTxBuf_p, unsigned char *pRxBuf_p, int iBytes_p);
#endif

void SysComp_writeOutputPort(DWORD dwValue_p);
DWORD SysComp_readInputPort();

#endif /* SYSTEMCOMPONENTS_H_ */

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
