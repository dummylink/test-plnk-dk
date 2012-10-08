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
#include "EplErrDef.h"      // for tEplKernel
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
    kPcpGenEventSyncCycleCalcSuccessful,         ///< synchronization interrupt cycle time calculation was successful
    kPcpGenEventNodeIdConfigured,                ///< Powerlink Node Id has been configured
    kPcpGenEventResetNodeRequest,                ///< PCP requests AP to do a complete node reboot (e.g. after finished firmware transfer)
    kPcpGenEventResetCommunication,              ///< PCP requests AP to reset its asynchronous communication
    kPcpGenEventResetCommunicationDone,          ///< asynchronous communication reset has finished at PCP side
    kPcpGenEventNmtEnableReadyToOperate,         ///< PCP received NMT_ReadyToOperate command
    kPcpGenEventUserTimer,                       ///< timer event triggered by PCP
} tPcpPdiEventGeneric;

/**
 * \brief enumeration with valid PcpPdi events
 */
typedef enum ePcpPdiEventGenericError {
    kPcpGenErrInitFailed,                 ///< initialization error of PCP
    kPcpGenErrSyncCycleCalcError,         ///< synchronization interrupt cycle time calculation error
    kPcpGenErrAsyncComTimeout,      ///< asynchronous communication timed out
    kPcpGenErrAsyncIntChanComError, ///< asynchronous communication failed
    kPcpGenErrPhy0LinkLoss,         ///< PHY 0 lost its link
    kPcpGenErrPhy1LinkLoss,         ///< PHY 0 lost its link
    kPcpGenErrEventBuffOverflow,    ///< PCP event buffer overflow -> AP handles events to slow!
} tPcpPdiEventGenericError;

/**
 * \brief enum of valid PcpPdi event types
 */
typedef enum ePcpPdiEventType {
    kPcpPdiEventGeneric,            ///< general PCP event
    kPcpPdiEventGenericError,       ///< general PCP error
    kPcpPdiEventPcpStateChange,     ///< PCP state machine change
//    kPcpPdiEventNmtStateChange,   ///< PCP forwarded openPowerlink NMT state changes
    kPcpPdiEventCriticalStackError, ///< PCP forwarded openPowerlink Stack Error
    kPcpPdiEventStackWarning,       ///< PCP forwarded openPowerlink Stack Warning
    kPcpPdiEventHistoryEntry,       ///< PCP forwarded Powerlink error history entry
} tPcpPdiEventType;

/**
 * \brief union of valid PcpPdi event arguments
 */
typedef union {
    DWORD                    wVal_m;                ///< general value with max size of this union
    tPcpPdiEventGeneric      Gen_m;                 ///< argument of kPcpPdiEventGeneric
    tPcpPdiEventGenericError GenErr_m;              ///< argument of kPcpPdiEventGenericError
    tPcpStates               NewPcpState_m;         ///< argument of kPcpPdiEventPcpStateChange
//    tEplNmtState             NewNmtState_m;         ///< argument of kPcpPdiEventNmtStateChange
    tEplKernel               PcpStackError_m;       ///< argument of kPcpPdiEventCriticalStackError
    DWORD                    wErrorHistoryCode_m;   ///< argument of kPcpPdiEventHistoryEntry
} tPcpPdiEventArg;

typedef struct {
    tPcpPdiEventType Typ_m;
    tPcpPdiEventArg  Arg_m;
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

