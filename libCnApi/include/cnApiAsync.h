/**
********************************************************************************
\file       cnApiAsync.h

\brief      Header file for asynchronous communication AP <-> PCP

This header files uses the asynchronous state machine to send and receive
messages from the PCP to the AP processor.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPIASYNC_H_
#define CNAPIASYNC_H_

/******************************************************************************/
/* includes */
#include "cnApi.h"
#include "cnApiTypAsync.h"

#include "Epl.h"


/******************************************************************************/
/* defines */
#define MAX_ASYNC_TIMEOUT   500     ///< timeout counter for asynchronous transfers
#define ASYNC_PDI_CHANNELS  PCP_PDI_ASYNC_BUF_MAX  ///< from cnApiCfg.h


/******************************************************************************/
/* typedefs */

struct sPdiAsyncMsgDescr;

/**
********************************************************************************
 \brief typedef for call back function which fill and processes a buffer
 \param  pMsgDescr_p         pointer to asynchronous message descriptor
 \param  pMsgBuffer_p        pointer to asynchronous message buffer (payload)
 \param  pRespMsgBuffer_p    pointer to optional response Tx or Rx message buffer (payload)
 \param  dwMaxTxBufSize_p    maximum Tx message storage space
 \return Ret                 tPdiAsyncStatus value
 \retval kPdiAsyncStatusDataTooLong     Tx message exceeds buffer size
 \retval kPdiAsyncStatusInvalidInstanceParam    wrong parameter

 This call-back function has to check pRespMsgBuffer_p (== NULL ?) if a response message
 is assigned to the actual message. Is also has to check if the Tx Buffer storage is sufficient.
 If one check fails, an appropriate error shall be returned.
 In general the function read and/or fills an asynchronous buffer.
 This can be a local buffer or a PDI buffer, depending on the set transfer mode (local buffered
 or direct PDI access).
 If a Tx descriptor will be used, function needs to
 - check if expected Tx size execeeds dwMaxTxBufSize_p
 - write the actual written Tx size to dwMsgSize_m of the Tx message descriptor
 - return an appropriate value in case of an error

********************************************************************************/
typedef tPdiAsyncStatus (* tPdiAsyncBufHdlCb) (struct sPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pMsgBuffer_p,
                                               BYTE * pRespMsgBuffer_p, DWORD dwMaxTxBufSize_p);

/**
 ********************************************************************************
 \brief call back function, invoked after message transfer has finished
 \param  pMsgDescr_p         pointer to asynchronous message descriptor
 \return Ret                 tPdiAsyncStatus value
 *******************************************************************************/
typedef tPdiAsyncStatus (* tPdiAsyncCbTransferFinished) (struct sPdiAsyncMsgDescr * pMsgDescr_p);


typedef struct sPdiAsyncMsgHdl {
    BYTE*                 pLclBuf_m;        ///< pointer to msg if local msg buffering is used
    tPdiAsyncBufHdlCb     pfnCbMsgHdl_m;    ///< or callback function for handling buffer (local or direct)
} tPdiAsyncMsgHdl;

typedef struct sPdiAsyncMsgDescr {
    tPdiAsyncMsgType        MsgType_m;           ///< type of the message
    tPdiAsyncMsgStatus      MsgStatus_m;         ///< status of message transfer
    tPdiAsyncStatus         Error_m;             ///< in case of an error the error code will be stored here
    DWORD                   dwMsgSize_m;         ///< size of message payload
    DWORD                   dwPendTranfSize_m;   ///< size of data which has not been transfered yet
    tPdiAsyncMsgHdl         MsgHdl_m;            ///< message handler
    tPdiAsyncCbTransferFinished pfnTransferFinished_m; ///< user call back function, invoked when transfer has finished
    BYTE *                  pUserHdl_m;          ///< optional user handle
    tPcpPdiAsyncMsgBufDescr * pPdiBuffer_m;      ///< pointer to utilized PDI asynchronous one-way buffer
    struct sPdiAsyncMsgDescr * pRespMsgDescr_m;  ///< pointer to descriptor of response message
    tPdiAsyncTransferType   TransfType_m;        ///< TRUE = Buffered transfer, FALSE = Direct access
    tPdiAsyncMsgParam       Param_m;             ///< message parameter
} tPdiAsyncMsgDescr;



/******************************************************************************/
/* external variable declarations */
extern tPcpPdiAsyncMsgBufDescr aPcpPdiAsyncTxMsgBuffer_g[];
extern tPcpPdiAsyncMsgBufDescr aPcpPdiAsyncRxMsgBuffer_g[];

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */
int CnApiAsync_init(void);
int CnApiAsync_create(tPcpInitParam *pInitPcpParam_p, BYTE * pDpramBase_p);
int CnApiAsync_reset(void);

/* functions for asynchronous transfers */
tPdiAsyncStatus CnApi_pfnCbInitPcpRespFinished (struct sPdiAsyncMsgDescr * pMsgDescr_p);

/******************************************************************************/
/* private functions */


#endif /* CNAPIASYNC_H_ */

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

