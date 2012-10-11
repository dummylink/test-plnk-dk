/**
********************************************************************************
\file       cnApiTypAsyncSm.h

\brief      Global header file for PCP PDI (CN) and libCnApi (AsyncSm module)

This header provides data structures for the PCP and AP processors async state
machine module. It defines message formats and common types.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPITYPASYNCSM_H_
#define CNAPITYPASYNCSM_H_

/******************************************************************************/
/* includes */
#include "cnApiTyp.h"

/******************************************************************************/
/* defines */
#define MAX_PDI_ASYNC_TX_MESSAGES 10    ///< max: 0xFF
#define MAX_PDI_ASYNC_RX_MESSAGES  9    ///< max: 0xFF

#define MAX_ASYNC_STREAM_LENGTH   10240 ///< max local buffer size (maximum = max value(DWORD))

#define PCP_ASYNCSM_TIMEOUT_FACTOR 1000

/******************************************************************************/
/* typedefs */

/* definitions for the state machine */
typedef enum eAsyncTxState {
    kPdiAsyncStateWait = 0,                ///< asynchronous tx or rx service is ready to use
    kPdiAsyncTxStateBusy,                  ///< asynchronous tx is processing
    kPdiAsyncTxStatePending,               ///< asynchronous tx is waiting to be fetched
    kPdiAsyncRxStateBusy,                  ///< asynchronous rx is processing
    kPdiAsyncRxStatePending,               ///< asynchronous rx is waiting for data
    kPdiAsyncStateStopped,                 ///< asynchronous transmission error or timed out happend
    kPdiNumAsyncStates                     ///< state counter
} tAsyncState;

typedef struct sPdiAsyncPendingTransferContext {
    BOOL fMsgPending_m;            ///< flag indicates a pending message
    BYTE bState_m;                 ///< state of state machine
    BOOL fError_m;                 ///< transition event
    BOOL fTimeout_m;               ///< transition event
    BOOL fReset_m;                 ///< transition event
    BOOL fRxTriggered_m;           ///< transition event -> explicitly wait for special message
    BOOL fTxTriggered_m;           ///< transition event
    BOOL fFrgmtAvailable_m;        ///< transition event
    BOOL fFrgmtStored_m;           ///< transition event
    BOOL fFrgmtDelivered_m;        ///< transition event
    BOOL fMsgTransferFinished_m;   ///< transition event
    BOOL fMsgTransferIncomplete_m; ///< transition event
    BOOL fFragmentedTransfer_m;    ///< flag indicates fragmented transfer
    BOOL fDeactivateRxMsg_m;       ///< aid flag for not setting bActivRxMsg_l
                                   ///< immediately to INVALID_ELEMENT
    BYTE              bActivTxMsg_m; ///< indicates inactive message
    BYTE              bActivRxMsg_m; ///< indicates inactive message
    BYTE *            pLclAsyncTxMsgBuffer_m;   ///< pointer to local Tx message buffer
    tPdiAsyncStatus   ErrorHistory_m;
    BYTE *            pLclAsyncRxMsgBuffer_m;   ///< pointer to local Rx message buffer
    DWORD             dwTimeoutWait_m;          ///< timeout counter
} tPdiAsyncPendingTransferContext;

typedef struct sPdiAsyncMsgLink {
    tPdiAsyncMsgType    MsgType_m;           ///< type of origin message
    tPdiAsyncMsgType    RespMsgType_m;       ///< type of response message
    tPcpPdiAsyncDir     Direction_m;         ///< direction of origin message
} tPdiAsyncMsgLink;

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


#endif /* CNAPITYPASYNCSM_H_ */

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

