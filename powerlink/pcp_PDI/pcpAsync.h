/******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       pcpAsync.h

\brief      header file for pcpAsync module

\author     hoggerm

\date       26.08.2011

\since      26.08.2011

*******************************************************************************/
#ifndef _PCPASYNC_H_
#define _PCPASYNC_H_

/******************************************************************************/
/* includes */
#include "cnApiTypAsync.h"

/******************************************************************************/
/* defines */

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
int CnApiAsync_create(void);
int CnApiAsync_init(void);
int CnApiAsync_reset(void);

tPdiAsyncStatus CnApiAsync_checkApLinkingStatus(void);


/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */



#endif /* _PCPASYNC_H_ */
