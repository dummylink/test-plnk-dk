/**
********************************************************************************
\file       cnApiTypEvent.h

\brief      Global header file for PCP PDI (CN) and libCnApi (event module)

This header provides data structures for the PCP and AP processors event module.
It defines message formats and common types.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef _CNAPITYPEVENT_H_
#define _CNAPITYPEVENT_H_

/******************************************************************************/
/* includes */
#include "cnApiGlobal.h"
#include "cnApiTyp.h"

/******************************************************************************/
/* defines */

/* defines for EVENT_ACK */
#define EVT_GENERIC     0
#define EVT_PHY0_LINK   6
#define EVT_PHY1_LINK   7

/******************************************************************************/
/* typedefs */

/* PCP forwarded events */
typedef enum ePcpPdiEventGeneric {
    kPcpGenEventSyncCycleCalcSuccessful   = 0x00,    ///< synchronization interrupt cycle time calculation was successful
    kPcpGenEventNodeIdConfigured          = 0x01,    ///< POWERLINK Node Id has been configured
    kPcpGenEventResetNodeRequest          = 0x02,    ///< PCP requests AP to do a complete node reboot (e.g. after finished firmware transfer)
    kPcpGenEventResetCommunication        = 0x03,    ///< PCP requests AP to reset its asynchronous communication
    kPcpGenEventResetCommunicationDone    = 0x04,    ///< asynchronous communication reset has finished at PCP side
    kPcpGenEventNmtEnableReadyToOperate   = 0x05,    ///< PCP received NMT_ReadyToOperate command
    kPcpGenEventDefaultGatewayUpdate      = 0x06,    ///< On this event the default gateway is up to date
} tPcpPdiEventGeneric;

/**
 * \brief enumeration with valid PcpPdi events
 */
typedef enum ePcpPdiEventGenericError {
    kPcpGenErrInitFailed            = 0x00,    ///< initialization error of PCP
    kPcpGenErrSyncCycleCalcError    = 0x01,    ///< synchronization interrupt cycle time calculation error
    kPcpGenErrAsyncComTimeout       = 0x02,    ///< asynchronous communication timed out
    kPcpGenErrAsyncComMtuExceeded   = 0x03,    ///< asynchronous MTU exceeded
    kPcpGenErrAsyncComRxFailed      = 0x04,    ///< asynchronous RX at PCP failed
    kPcpGenErrAsyncIntChanComError  = 0x05,    ///< asynchronous communication failed
    kPcpGenErrPhy0LinkLoss          = 0x06,    ///< PHY 0 lost its link
    kPcpGenErrPhy1LinkLoss          = 0x07,    ///< PHY 1 lost its link
    kPcpGenErrEventBuffOverflow     = 0x08,    ///< PCP event buffer overflow -> AP handles events to slow!
} tPcpPdiEventGenericError;

/**
 * \brief enum of valid PcpPdi event types
 */
typedef enum ePcpPdiEventType {
    kPcpPdiNoEvent                  = 0x00,       ///< no event set
    kPcpPdiEventGeneric             = 0x01,       ///< general PCP event
    kPcpPdiEventGenericError        = 0x02,       ///< general PCP error
    kPcpPdiEventPcpStateChange      = 0x03,       ///< PCP state machine change
    kPcpPdiEventCriticalStackError  = 0x04,       ///< PCP forwarded POWERLINK Stack Error
    kPcpPdiEventStackWarning        = 0x05,       ///< PCP forwarded POWERLINK Stack Warning
    kPcpPdiEventHistoryEntry        = 0x06,       ///< PCP forwarded POWERLINK history entry
} tPcpPdiEventType;

/**
 * \brief union of valid PcpPdi event arguments
 */
typedef union {
    DWORD                    m_wVal;                ///< general value with max size of this union
    tPcpPdiEventGeneric      m_Gen;                 ///< argument of kPcpPdiEventGeneric
    tPcpPdiEventGenericError m_GenErr;              ///< argument of kPcpPdiEventGenericError
    tPcpStates               m_NewPcpState;         ///< argument of kPcpPdiEventPcpStateChange
    DWORD                    m_dwPcpStackError;       ///< argument of kPcpPdiEventCriticalStackError
    DWORD                    m_dwErrorHistoryCode;   ///< argument of kPcpPdiEventHistoryEntry
} tPcpPdiEventArg;

typedef struct {
    tPcpPdiEventType m_Typ;
    tPcpPdiEventArg  m_Arg;
} tPcpPdiEvent;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */


#endif /* _CNAPITYPEVENT_H_ */

/*******************************************************************************
*
* License Agreement
*
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
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

