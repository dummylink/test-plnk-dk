/**
********************************************************************************
\file       cnApiAsyncSm.h

\brief      Asynchronous PDI state machine header

This is the header file for the asynchronous communication between the
POWERLINK Communication Processor (PCP) and the Application Processor (AP)
using the Process Data Interface (PDI) as buffer.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef PCPPDIASYNCSM_H_
#define PCPPDIASYNCSM_H_

/******************************************************************************/
/* includes */
#include <cnApiAsync.h>
#include <stateMachine.h>

/******************************************************************************/
/* defines */
#define USLEEP(x)                   CNAPI_USLEEP(x)
#define MALLOC(siz)                 CNAPI_MALLOC(siz)
#define FREE(ptr)                   CNAPI_FREE(ptr)
#define MEMSET(ptr, bVal, bCnt)     CNAPI_MEMSET(ptr, bVal, bCnt)
#define MEMCPY(dst,src,siz)         memcpy(dst,src,siz)

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* global functions */
tPdiAsyncStatus CnApiAsync_finishMsgInit(void);
tPdiAsyncStatus CnApiAsync_initMsg(tPdiAsyncMsgType MsgType_p, tPcpPdiAsyncDir Direction_p, const tPdiAsyncBufHdlCb  pfnCbMsgHdl_p,
                                           const tPcpPdiAsyncMsgBufDescr * pPdiBuffer_p, tPdiAsyncMsgType RespMsgType_p,
                                           tPdiAsyncTransferType TransferType_p, tAsyncChannel ChanType_p,
                                           const tPcpStates * paValidNmtList_p, WORD wTimeout_p);

void CnApiAsync_resetMsgLogCounter(void);

tPdiAsyncStatus CnApiAsync_postMsg(
                        tPdiAsyncMsgType MsgType_p,
                        BYTE * pUserHandle_p,
                        tPdiAsyncCbTransferFinished pfnCbOrigMsg_p,
                        tPdiAsyncCbTransferFinished pfnCbRespMsg_p,
                        BYTE * pUserBuffer_p,
                        DWORD dwUserBufSize_p);

void CnApi_activateAsyncStateMachine(void);
void CnApi_resetAsyncStateMachine(void);
BOOL CnApi_processAsyncStateMachine(void);
BOOL CnApi_checkAsyncStateMachineRunning(void);
void CnApi_enableAsyncSmProcessing(void);
void CnApi_disableAsyncSmProcessing(void);

/******************************************************************************/
/* private functions */


#endif /* PCPPDIASYNCSM_H_ */

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
