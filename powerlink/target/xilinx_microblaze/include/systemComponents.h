/**
********************************************************************************
\file           systemComponents.h

\brief          Header file which contains processor specific definitions (xilinx version)

This header file contains processor specific definitions.

********************************************************************************

License Agreement

Copyright (C) 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved.

Redistribution and use in source and binary forms,
with or without modification,
are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer
    in the documentation and/or other materials provided with the
    distribution.
  * Neither the name of the B&R nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*******************************************************************************/

#ifndef SYSTEMCOMPONENTS_H_
#define SYSTEMCOMPONENTS_H_

/******************************************************************************/
/* includes */
#include "global.h"
#include "xparameters.h"

/******************************************************************************/
/* defines */

#if defined(POWERLINK_USES_PLB_BUS)

    #ifdef XPAR_PLB_POWERLINK_0_SMP_PCP_BASEADDR
    #define LATCHED_IOPORT_BASE   (void*) XPAR_PLB_POWERLINK_0_SMP_PCP_BASEADDR
    #define LATCHED_IOPORT_CFG    (void*) (LATCHED_IOPORT_BASE + 4)
    #endif //XPAR_PLB_POWERLINK_0_SMP_PCP_BASEADDR

    #ifdef XPAR_PLB_POWERLINK_0_PDI_PCP_BASEADDR
    #define PDI_DPRAM_BASE_PCP    XPAR_PLB_POWERLINK_0_PDI_PCP_BASEADDR
    #endif //XPAR_PLB_POWERLINK_0_PDI_PCP_BASEADDR

    #if defined(XPAR_PLB_POWERLINK_0_TPDO_BUF_SIZE) && defined(XPAR_PLB_POWERLINK_0_RPDO_0_BUF_SIZE)
    #define PDI_TPDO_BUF_SIZE       XPAR_PLB_POWERLINK_0_TPDO_BUF_SIZE
    #define PDI_RPDO_BUF_SIZE       XPAR_PLB_POWERLINK_0_RPDO_0_BUF_SIZE
    #define PDI_TPDO_MAX_PAYLOAD   (XPAR_PLB_POWERLINK_0_TPDO_BUF_SIZE - 0)    // TPDO PDI buffer does not have any header
    #define PDI_RPDO_MAX_PAYLOAD   (XPAR_PLB_POWERLINK_0_RPDO_0_BUF_SIZE - 16) // withdraw RPDO PDI buffer header (16 bytes)
    #endif //XPAR_PLB_POWERLINK_0_TPDO_BUF_SIZE && XPAR_PLB_POWERLINK_0_RPDO_0_BUF_SIZE

    #if defined(XPAR_PLB_POWERLINK_0_NUM_TPDO) && defined(XPAR_PLB_POWERLINK_0_NUM_RPDO)
    #define TPDO_CHANNELS_MAX     XPAR_PLB_POWERLINK_0_NUM_TPDO ///< Max Number of TxPDO's of this CN
    #define RPDO_CHANNELS_MAX     XPAR_PLB_POWERLINK_0_NUM_RPDO ///< Max Number of RxPDO's of this CN
    #endif //XPAR_PLB_POWERLINK_0_NUM_TPDO && XPAR_PLB_POWERLINK_0_NUM_RPDO


    #if (XPAR_PLB_POWERLINK_0_PDI_GEN_TIME_SYNC != FALSE)
    #define TIMESYNC_HW
    #endif //XPAR_PLB_POWERLINK_0_PDI_GEN_TIME_SYNC

    #ifdef XPAR_PLB_POWERLINK_0_PDI_ASYNC_BUF_COUNT
    #define ASYNC_PDI_CHANNELS XPAR_PLB_POWERLINK_0_PDI_ASYNC_BUF_COUNT
    #endif //XPAR_PLB_POWERLINK_0_PDI_ASYNC_BUF_COUNT

#elif defined(POWERLINK_USES_AXI_BUS)

    #ifdef XPAR_AXI_POWERLINK_0_S_AXI_SMP_PCP_BASEADDR
    #define LATCHED_IOPORT_BASE   (void*) XPAR_AXI_POWERLINK_0_S_AXI_SMP_PCP_BASEADDR
    #define LATCHED_IOPORT_CFG    (void*) (LATCHED_IOPORT_BASE + 4)
    #endif //XPAR_AXI_POWERLINK_0_S_AXI_SMP_PCP_BASEADDR

    #ifdef XPAR_AXI_POWERLINK_0_S_AXI_PDI_PCP_BASEADDR
    #define PDI_DPRAM_BASE_PCP    XPAR_AXI_POWERLINK_0_S_AXI_PDI_PCP_BASEADDR
    #endif //XPAR_AXI_POWERLINK_0_S_AXI_PDI_PCP_BASEADDR

    #if defined(XPAR_AXI_POWERLINK_0_TPDO_BUF_SIZE) && defined(XPAR_AXI_POWERLINK_0_RPDO_0_BUF_SIZE)
    #define PDI_TPDO_BUF_SIZE       XPAR_AXI_POWERLINK_0_TPDO_BUF_SIZE
    #define PDI_RPDO_BUF_SIZE       XPAR_AXI_POWERLINK_0_RPDO_0_BUF_SIZE
    #define PDI_TPDO_MAX_PAYLOAD   (XPAR_AXI_POWERLINK_0_TPDO_BUF_SIZE - 0)    // TPDO PDI buffer does not have any header
    #define PDI_RPDO_MAX_PAYLOAD   (XPAR_AXI_POWERLINK_0_RPDO_0_BUF_SIZE - 16) // withdraw RPDO PDI buffer header (16 bytes)
    #endif //XPAR_AXI_POWERLINK_0_TPDO_BUF_SIZE && XPAR_AXI_POWERLINK_0_RPDO_0_BUF_SIZE

    #if defined(XPAR_AXI_POWERLINK_0_NUM_TPDO) && defined(XPAR_AXI_POWERLINK_0_NUM_RPDO)
    #define TPDO_CHANNELS_MAX     XPAR_AXI_POWERLINK_0_NUM_TPDO ///< Max Number of TxPDO's of this CN
    #define RPDO_CHANNELS_MAX     XPAR_AXI_POWERLINK_0_NUM_RPDO ///< Max Number of RxPDO's of this CN
    #endif //XPAR_AXI_POWERLINK_0_NUM_TPDO && XPAR_AXI_POWERLINK_0_NUM_RPDO

    #if (XPAR_AXI_POWERLINK_0_PDI_GEN_TIME_SYNC != FALSE)
    #define TIMESYNC_HW
    #endif //XPAR_AXI_POWERLINK_0_PDI_GEN_TIME_SYNC

    #ifdef XPAR_AXI_POWERLINK_0_PDI_ASYNC_BUF_COUNT
    #define ASYNC_PDI_CHANNELS XPAR_AXI_POWERLINK_0_PDI_ASYNC_BUF_COUNT
    #endif //XPAR_AXI_POWERLINK_0_PDI_ASYNC_BUF_COUNT
#else
    #error "The used bus system is unknown! (Should be PLB or AXI)"
#endif


#ifdef XPAR_POWERLINK_LED_BASEADDR
#define STATUS_LEDS_BASE XPAR_POWERLINK_LED_BASEADDR
#endif

#ifdef XPAR_NODE_SWITCHES_BASEADDR
#define NODE_SWITCH_BASE XPAR_NODE_SWITCHES_BASEADDR
#endif //XPAR_NODE_SWITCHES_BASEADDR

#ifndef NODE_SWITCH_BASE
 #warning No Node ID module present in XPS. Node ID can only be set by SW!
#endif //NODE_SWITCH_BASE

#define MAX_NUM_LINKED_OBJ_PCP  500

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */
void SysComp_initPeripheral(void);
void SysComp_freeProcessorCache(void);
void SysComp_enableInterrupts(void);

BYTE SysComp_getNodeId(void);
void SysComp_setPowerlinkStatus(BYTE bBitNum_p);
void SysComp_resetPowerlinkStatus(BYTE bBitNum_p);

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
#endif /* SYSTEMCOMPONENTS_H_ */
/* END-OF-FILE */
