/******************************************************************************
* Copyright � 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1                           
* All rights reserved. All use of this software and documentation is          
* subject to the License Agreement located at the end of this file below.     
*/

/**
********************************************************************************

\file       cnApiEvent.h

\brief      header file for PCP PDI (CN) event handling

\author     hoggerm

\date       29.04.2011

\since      29.04.2011

*******************************************************************************/
#ifndef CNAPIEVENT_H_
#define CNAPIEVENT_H_
/******************************************************************************/
/* includes */

/* lends from openPOWERLINK stack */
#include "cnApi.h"
#include "EplNmt.h"         // for tEplNmtState
#include "EplErrDef.h"      // for tEplKernel
#include "Epl.h"            // for tEplApiEventLed
//#include "EplObd.h"         // for tEplObdCbParam
#include "EplDef.h"         // Powerlink error codes

/******************************************************************************/
/* defines */

// 0x9xxx PCP errors
#define PCP_IF_COMMUNICATION_ERROR      0x9100
#define PCP_IF_INVALID_STATE_CHANGE     0x9200
#define PCP_IF_CONFIGURATION_ERROR      0x9300

/******************************************************************************/
/* typedefs */

/* PCP forwarded events */
typedef enum ePcpPdiEventGeneric {
    kPcpGenEventSyncCycleCalcSuccessful,         ///< synchronization interrupt cycle time calculation was successful
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
    WORD                     wVal_m;                ///< general value with max size of this union
    tPcpPdiEventGeneric      Gen_m;                 ///< argument of kPcpPdiEventGeneric
    tPcpPdiEventGenericError GenErr_m;              ///< argument of kPcpPdiEventGenericError
    tPcpStates               NewPcpState_m;         ///< argument of kPcpPdiEventPcpStateChange
//    tEplNmtState             NewNmtState_m;         ///< argument of kPcpPdiEventNmtStateChange
    tEplKernel               PcpStackError_m;       ///< argument of kPcpPdiEventCriticalStackError
    WORD                     wErrorHistoryCode_m;   ///< argument of kPcpPdiEventHistoryEntry
} tPcpPdiEventArg;

typedef struct {
    tPcpPdiEventType Typ_m;
    tPcpPdiEventArg  Arg_m;
} tPcpPdiEvent;


/* CN API events */
typedef enum eCnApiEventErrorType{
    kCnApiEventErrorFromPcp,  ///< error source is PCP PDI
    kCnApiEventErrorLcl,      ///< error source is local function
} tCnApiEventErrorType;

typedef union {
tPcpPdiEvent PcpError_m;
//tCnApiRetCode cnApiError_m; //TODO: define general Ret Code
} tCnApiEventErrorArg;

typedef struct sCnApiEventError{
    tCnApiEventErrorType ErrTyp_m;
    tCnApiEventErrorArg  ErrArg_m; //TODO: delete
} tCnApiEventError;

typedef enum eCnApiEventTypeAsyncComm{
    kCnApiEventTypeAsyncCommExtChanFinished,     ///< asynchronous communication with PCP has finished and external channel is now available again
    kCnApiEventTypeAsyncCommExtChanMsgPresent,   ///< message from PCP is present in external channel
    kCnApiEventTypeAsyncCommExtChanBusy,         ///< access to external channel has been denied because it is in use
} tCnApiEventTypeAsyncComm;

typedef struct sCnApiEventArgAsyncComm{
// TODO
} tCnApiEventArgAsyncComm;

typedef struct sCnApiEventAsyncComm {
    tCnApiEventTypeAsyncComm Typ_m;
    tCnApiEventArgAsyncComm  Arg_m;
} tCnApiEventAsyncComm;

/**
 * \brief enumeration with valid CnApi events
 */
typedef enum eCnApiEventType {
    kCnApiEventUserDef,           ///< user defined event
    kCnApiEventPcp,               ///< generic event from PCP (all events except errors)
    kCnApiEventApStateChange,     ///< AP state machine changed
    kCnApiEventError,             ///< general CnApi error
//    kCnApiEventHistoryEntry,    ///< local CnApi error history entry
    kCnApiEventSdo,               ///< not used
    kCnApiEventObdAccess,         ///< not used
    kCnApiEventAsyncComm,      ///< asynchronous communication AP <-> PCP event
} tCnApiEventType;

/**
 * \brief union of valid CnApi event arguments
 */
typedef union {
    void *                   pUserArg_m;          ///< argument of kCnApiEventUserDef
    tApStates                NewApState_m;        ///< argument of kCnApiEventApStateChange
    tPcpPdiEventGeneric      PcpEventGen_m;       ///< argument of kCnApiEventPcp
    tCnApiEventError         CnApiError_m;        ///< argument of kCnApiEventError
//    tEplSdoComFinished       Sdo_m;               ///< argument of kCnApiEventSdo
//    tEplObdCbParam           ObdCbParam_m;        ///< argument of kCnApiEventObdAccess
// tCnApiEventAsyncPcpComm     AsyncPcpComm_m;      ///< argument of kCnApiEventAsyncCommPcp
} tCnApiEventArg;

typedef struct {
    tCnApiEventType Typ_m;
    tCnApiEventArg  Arg_m;
} tCnApiEvent;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */
// OUT
extern void CnApi_enableAsyncEventIRQ(void);
extern void CnApi_disableAsyncEventIRQ(void);
extern void CnApi_pollAsyncEvent(void);

// IN from main.c
extern void CnApi_AppCbEvent(tCnApiEventType EventType_p, tCnApiEventArg EventArg_p, void * pUserArg_p);

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */



#endif /* CNAPIEVENT_H_ */

/*******************************************************************************
*
* License Agreement
*
* Copyright � 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1  
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
