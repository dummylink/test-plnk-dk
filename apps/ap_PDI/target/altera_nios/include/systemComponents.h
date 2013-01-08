/**
********************************************************************************
\file       altera_nios/include/systemComponents.h

\brief      Header file which contains processor specific definitions
            (Nios II version)

This header file contains of platform specific definitions.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef SYSTEMCOMPONENTS_H_
#define SYSTEMCOMPONENTS_H_

/******************************************************************************/
/* includes */
#include "system.h"

#include "cnApiGlobal.h"
#include "cnApiCfg.h"

#include <string.h>
#include <stdio.h>

/******************************************************************************/
/* defines */

// PDI DPRAM offset
#ifdef CN_API_USING_SPI
    #define PDI_DPRAM_BASE_AP    0x00                       ///< no base address necessary
#elif defined(CN_API_USING_16BIT) || defined(CN_API_USING_8BIT)
    #define PDI_DPRAM_BASE_AP    PAR_PDI_MASTER_0_BASE      ///< base of pap master
#elif defined(CN_API_INT_AVALON)
    #define PDI_DPRAM_BASE_AP    POWERLINK_0_BASE
#else
    #error "No valid PDI interface specified in cnApiCfg.h!"
#endif /* CN_API_USING_SPI */

#ifdef OUTPORT_AP_BASE
    #define OUTPORT_AP_BASE_ADDRESS OUTPORT_AP_BASE
#endif

#ifdef INPORT_AP_BASE
    #define INPORT_AP_BASE_ADDRESS INPORT_AP_BASE
#endif

// SYNC IRQ dependencies
#if defined(CN_API_USING_SPI) || defined(CN_API_USING_16BIT) || defined(CN_API_USING_8BIT)
    #define SYNC_IRQ_NUM SYNC_IRQ_FROM_PCP_IRQ
    #define SYNC_IRQ_BASE SYNC_IRQ_FROM_PCP_BASE
#elif defined(CN_API_INT_AVALON)
    #define SYNC_IRQ_NUM    POWERLINK_0_IRQ
#else
    #error "No valid PDI interface specified in cnApiCfg.h!"
#endif

// ASYNC (event-) IRQ dependencies
#if defined(CN_API_USING_SPI) || defined(CN_API_USING_16BIT) || defined(CN_API_USING_8BIT)
    #define ASYNC_IRQ_NUM ASYNC_IRQ_FROM_PCP_IRQ
    #define ASYNC_IRQ_BASE ASYNC_IRQ_FROM_PCP_BASE
#elif defined(CN_API_INT_AVALON)
    #define ASYNC_IRQ_NUM    POWERLINK_0_IRQ
#else
    #error "No valid PDI interface specified in cnApiCfg.h!"
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

#ifndef ALT_ENHANCED_INTERRUPT_API_PRESENT
int SysComp_initSyncInterrupt(void (*callbackFunc)(void*, void*));
int SysComp_initAsyncInterrupt(void (*callbackFunc)(void*, void*));
#else
int SysComp_initSyncInterrupt(void (*callbackFunc)(void*));
int SysComp_initAsyncInterrupt(void (*callbackFunc)(void*));
#endif

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
