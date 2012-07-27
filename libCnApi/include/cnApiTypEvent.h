/******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       cnApiTypEvent.h

\brief      global header file for PCP PDI (CN) and libCnApi (event module)

\author     hoggerm

\date       29.04.2011

\since      29.04.2011

*******************************************************************************/
#ifndef _CNAPITYPEVENT_H_
#define _CNAPITYPEVENT_H_

/******************************************************************************/
/* includes */
#include "EplErrDef.h"      // for tEplKernel

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
