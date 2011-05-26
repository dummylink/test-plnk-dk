/******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1                           
* All rights reserved. All use of this software and documentation is          
* subject to the License Agreement located at the end of this file below.     
*/

/**
********************************************************************************

\file       cnApiAsync.h

\brief      header file for asynchronous communication AP <-> PCP

\author     hoggerm

\date       29.03.2011

\since      29.03.2011

\version    {REVISION NUMBER}

*******************************************************************************/
#ifndef CNAPIASYNC_H_
#define CNAPIASYNC_H_
/******************************************************************************/
/* includes */
#include "cnApi.h"

/******************************************************************************/
/* defines */
#define MAX_ASYNC_STREAM_LENGTH   10240 ///< max local buffer size (maximum = max value(DWORD))

#define MAX_PDI_ASYNC_TX_MESSAGES 10    ///< max: 0xFF
#define MAX_PDI_ASYNC_RX_MESSAGES  9    ///< max: 0xFF

#define PDI_ASYNC_CHANNELS_MAX  2 //TODO: get from system.h?

#define INVALID_ELEMENT            0xFF ///< indicator for invalid array element

#define CNAPI_MALLOC(siz)             malloc(siz)
#define CNAPI_FREE(ptr)               free(ptr)
/******************************************************************************/
/* typedefs */

/* definitions for state machine */
typedef enum eAsyncTxState {
    kPdiAsyncStateWait = 0,                ///< asynchronous tx or rx service is ready to use
    kPdiAsyncTxStateBusy,                  ///< asynchronous tx is processing
    kPdiAsyncTxStatePending,               ///< asynchronous tx is waiting to be fetched
    kPdiAsyncRxStateBusy,                  ///< asynchronous rx is processing
    kPdiAsyncRxStatePending,               ///< asynchronous rx is waiting for data
    kPdiAsyncStateStopped,                 ///< asynchronous transmission error or timed out happend
    kPdiNumAsyncStates                     ///< state counter
} tAsyncState;

/**
 * \brief enumeration for asynchronous transfer status values
 */
typedef enum ePdiAsyncStatus{
    // area for generic errors 0x0000 - 0x000F
    kPdiAsyncStatusSuccessful           = 0x0000,  ///< no error/successful run
    kPdiAsyncStatusSendError            = 0x0001,
    kPdiAsyncStatusRespError            = 0x0002,
    kPdiAsyncStatusChannelError         = 0x0003,
    kPdiAsyncStatusReqIdError           = 0x0004,
    kPdiAsyncStatusTimeout              = 0x0005,
    kPdiAsyncStatusBufFull              = 0x0006,
    kPdiAsyncStatusBufEmpty             = 0x0007,
    kPdiAsyncStatusDataTooLong          = 0x0008,
    kPdiAsyncStatusIllegalInstance      = 0x000A,   ///< called Instance does not exist
    kPdiAsyncStatusInvalidInstanceParam = 0x000B,
    kPdiAsyncStatusNoFreeInstance       = 0x000C,   ///< AddInstance was called but no free instance is available
    kPdiAsyncStatusInvalidOperation     = 0x000D,   ///< operation not allowed in this situation
    kPdiAsyncStatusNoResource           = 0x000E,   ///< resource could not be created
    kPdiAsyncStatusShutdown             = 0x000F,   ///< stack is shutting down
    kPdiAsyncStatusReject               = 0x0010,   ///< reject the subsequent command
    kPdiAsyncStatusRetry                = 0x0011,   ///< retry this command
    kPdiAsyncStatusInvalidEvent         = 0x0012,   ///< invalid event was posted to process function
    kPdiAsyncStatusInvalidState         = 0x0013,   ///< message is invalid in current NmtState
    kPdiAsyncStatusInvalidMessage       = 0x0014,   ///< unexpected message received
    kPdiAsyncStatusFreeInstance         = 0x0015,   ///< free instance found
    kPdiAsyncStatusUnhandledTransfer    = 0x0016,   ///< no handle assigned to process buffer
} tPdiAsyncStatus; ///< module wide return and status codes

typedef enum ePdiAsyncTransferType{
    kPdiAsyncTrfTypeDirectAccess = 0x01, ///< direct access to Pdi buffer (Pdi buffer size is sufficient)
    kPdiAsyncTrfTypeLclBuffering,        ///< direct access to Pdi buffer (Pdi buffer size is sufficient)
    kPdiAsyncTrfTypeAutoDecision,        ///< transfer type will be chosen automatically (only works for Rx)
} tPdiAsyncTransferType;

/**
 * \brief constants for asynchronous transfer channels
 */
typedef enum eAsyncChannel {
    kAsyncChannelInternal = 0x01,
    kAsyncChannelSdo = 0x02
} tAsyncChannel;

/**
 * \brief enumeration for asynchronous commands
 */ //TODO: needed?
//typedef enum eAsyncCmd {
//
//} tAsyncCmd;

typedef enum ePdiAsyncMsgType {
    kPdiAsyncMsgInvalid         = 0x00,
    kPdiAsyncMsgIntInitPcpReq   = 0x01, ///< internal AP <-> PCP communication messages
    kPdiAsyncMsgIntCreateObjLinksReq,
    kPdiAsyncMsgIntWriteObjReq,
    kPdiAsyncMsgIntReadObjReq,
    kPdiAsyncMsgIntInitPcpResp,
    kPdiAsyncMsgIntCreateObjLinksResp,
    kPdiAsyncMsgIntLinkPdosReq,
    kPdiAsyncMsgIntWriteObjResp,
    kPdiAsyncMsgIntReadObjResp,
    kPdiAsyncMsgExtTxSdoWriteByIndex,     ///< external messages from network
    kPdiAsyncMsgExtRxSdoWriteByIndex,
    kPdiAsyncMsgExtTxSdoReadByIndex,
    kPdiAsyncMsgExtRxSdoReadByIndex,
    kPdiAsyncMsgExtTxFirmwareStream,
    kPdiAsyncMsgExtRxFirmwareStream,
    kPdiAsyncMsgExtTxDataTransfer,
    kPdiAsyncMsgExtRxDataTransfer,
    kPdiAsyncMsgExtTxIPPacket,
    kPdiAsyncMsgExtRxIPPacket,
} tPdiAsyncMsgType;

/**
 * \brief structure for InitPcpReq command
 */
typedef struct sInitPcpReq {
//    BYTE                    m_bCmd; //TODO: deprecated; shifted to bMsgType_m of tAsyncPdiBufCtrlHeader
    BYTE                    m_bReqId;
    BYTE                    m_bPad;
    BYTE                    m_abMac[6];
    DWORD                   m_dwRevision;
    DWORD                   m_dwSerialNum;
    DWORD                   m_dwVendorId;
    DWORD                   m_dwProductCode;
    DWORD                   m_dwDeviceType;
    DWORD                   m_dwFeatureFlags;
    DWORD                   m_dwNodeId;
    WORD                    m_wIsoTxMaxPayload;
    WORD                    m_wIsoRxMaxPayload;
    DWORD                   m_dwPresMaxLatency;
    DWORD                   m_dwAsendMaxLatency;
} PACK_STRUCT tInitPcpReq;

/**
 * \brief structure for InitPcpResp command
 */
typedef struct sInitPcpResp {
//    BYTE                    m_bCmd; //TODO: deprecated; shifted to bMsgType_m of tAsyncPdiBufCtrlHeader
    BYTE                    m_bReqId;
    BYTE                    m_bPad;
    WORD                    m_wStatus;
} PACK_STRUCT tInitPcpResp;

/**
 * \brief structure for CreateObjReq command
 */
typedef struct sCreateObjReq {
//    BYTE                    m_bCmd;//TODO: deprecated; shifted to bMsgType_m of tAsyncPdiBufCtrlHeader
    BYTE                    m_bReqId;
    BYTE                    m_bPad;
    WORD                    m_wNumObjs;
} PACK_STRUCT tCreateObjLksReq;

/**
 * \brief structure for CreateObjResp command
 */
typedef struct sCreateObjResp {
//    BYTE                    m_bCmd;//TODO: deprecated; shifted to bMsgType_m of tAsyncPdiBufCtrlHeader
    BYTE                    m_bReqId;
    BYTE                    m_bPad;
    WORD                    m_wStatus;
    WORD                    m_wErrIndex;
    BYTE                    m_bErrSubindex;
} PACK_STRUCT tCreateObjLksResp;

typedef struct sLinkPdosReq {
//    BYTE                    m_bCmd;//TODO: deprecated; shifted to bMsgType_m of tAsyncPdiBufCtrlHeader
//    BYTE                    m_reserved;
    BYTE                    m_bDescrCnt;
    BYTE                    m_bDescrVers;
} PACK_STRUCT tLinkPdosReq; //TODO: use async buffers!

/**
 * \brief structure for WriteObjReq command
 */
typedef struct sWriteObjReq {
//    BYTE                    m_bCmd;//TODO: deprecated; shifted to bMsgType_m of tAsyncPdiBufCtrlHeader
    BYTE                    m_bReqId;
    BYTE                    m_bPad;
    WORD                    m_wNumObjs;
} PACK_STRUCT tWriteObjReq;

/**
 * \brief structure for WriteObjResp command
 */

typedef struct sWriteObjResp {
//    BYTE                    m_bCmd;//TODO: deprecated; shifted to bMsgType_m of tAsyncPdiBufCtrlHeader
    BYTE                    m_bReqId;
    BYTE                    m_bPad;
    WORD                    m_wStatus;
    WORD                    m_wErrIndex;
    BYTE                    m_bErrSubindex;
} PACK_STRUCT tWriteObjResp;

/**
 * \brief structure for internal channel header
 */
typedef struct sAsyncIntHeader {
//    BYTE                    m_bCmd;//TODO: deprecated; shifted to bMsgType_m of tAsyncPdiBufCtrlHeader
    BYTE                    m_bReqId;
    BYTE                    m_bPad;
} PACK_STRUCT tAsyncIntHeader;

/**
 * \brief Structure definition for asynchronous transfer buffer header
 */
typedef struct sAsyncMsgHeader {
    BYTE                    m_bSync;
    BYTE                    m_bChannel;
    BYTE                    m_bMsgType;
    BYTE                    m_bPad;
    WORD                    m_wFrgmtLen;
    DWORD                   m_dwStreamLen;
} PACK_STRUCT tAsyncPdiBufCtrlHeader;

typedef struct sAsyncMsg {
    tAsyncPdiBufCtrlHeader  m_header;
    tAsyncChannel           m_chan;
} PACK_STRUCT tAsyncMsg;

/**
 * \brief descriptor of asynchronous message buffer
 */
typedef struct sPcpPdiAsyncBufDescr {
  tAsyncMsg *  pAdr_m;
  WORD         wPdiOffset_m;  ///< DPRAM offset (used for serial interface)
  WORD         wMaxPayload_m;
} tPcpPdiAsyncMsgBufDescr;

/**
 * \brief constants for asynchronous transfer direction
 */
typedef enum ePcpPdiAsyncDir {
    kCnApiDirReceive,
    kCnApiDirTransmit
} tPcpPdiAsyncDir;

/**
 * \brief constants for SYN flags
 */
typedef enum eSynFlag {
    kMsgBufWriteOnly = 0x01,
    kMsgBufReadOnly = 0x80
} tSynFlag;


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

typedef struct sPdiAsyncParam {
    tAsyncChannel   ChanType_m;                 ///< type of channel the message belongs to
    tPcpStates      aNmtList_m[kNumPcpStates];  ///< valid NmtStates for this message
    //not used: tPdiAsMsgPrio   Prio_m;         ///< message priority
    WORD           wTimeout_m;                  ///< timeout value of message delivery or reception (if set to 0, wait forever)
} tPdiAsyncMsgParam;

typedef struct sPdiAsyncMsgDescr {
    tPdiAsyncMsgType        MsgType_m;           ///< type of the message
    BOOL                    fMsgValid_m;         ///< flag indicating a valid (= "completed transfer" for Rx "to be processed" for Tx) message payload
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


typedef struct sPdiAsyncMsgLink {
    tPdiAsyncMsgType    MsgType_m;           ///< type of origin message
    tPdiAsyncMsgType    RespMsgType_m;       ///< type of response message
    tPcpPdiAsyncDir     Direction_m;         ///< direction of origin message
} tPdiAsyncMsgLink;

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

/******************************************************************************/
/* external variable declarations */
extern tPcpPdiAsyncMsgBufDescr aPcpPdiAsyncTxMsgBuffer_g[];
extern tPcpPdiAsyncMsgBufDescr aPcpPdiAsyncRxMsgBuffer_g[];

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */
extern int CnApiAsync_init(void);
extern tPdiAsyncStatus CnApiAsync_initMsg(tPdiAsyncMsgType MsgType_p, tPcpPdiAsyncDir Direction_p, const tPdiAsyncBufHdlCb  pfnCbMsgHdl_p,
                                           const tPcpPdiAsyncMsgBufDescr * pPdiBuffer_p, tPdiAsyncMsgType RespMsgType_p,
                                           tPdiAsyncTransferType TransferType_p, tAsyncChannel ChanType_p,
                                           const tPcpStates * paValidNmtList_p, WORD wTimeout_p);

extern tPdiAsyncStatus CnApiAsync_finishMsgInit(void);
extern tPdiAsyncStatus CnApiAsync_postMsg(
                       tPdiAsyncMsgType MsgType_p,
                       BYTE * pUserHandle_p,
                       tPdiAsyncCbTransferFinished pfnCbOrigMsg_p,
                       tPdiAsyncCbTransferFinished pfnCbRespMsg_p);

extern void CnApi_activateAsyncStateMachine(void);
extern void CnApi_resetAsyncStateMachine(void);
extern BOOL CnApi_processAsyncStateMachine(void);
extern BOOL CnApi_checkAsyncStateMachineRunning(void);

/* functions for asynchronous transfers */
extern tPdiAsyncStatus CnApi_doInitPcpReq(
                       tPdiAsyncMsgDescr * pMsgDescr_p,
                       BYTE * pTxMsgBuffer_p,
                       BYTE * pRxMsgBuffer_p,
                       DWORD dwMaxTxBufSize_p);
extern tPdiAsyncStatus CnApi_doCreateObjLinksReq(
                       tPdiAsyncMsgDescr * pMsgDescr_p,
                       BYTE * pTxMsgBuffer_p,
                       BYTE * pRxMsgBuffer_p,
                       DWORD dwMaxTxBufSize_p);
extern tPdiAsyncStatus CnApi_doWriteObjReq(
                       tPdiAsyncMsgDescr * pMsgDescr_p,
                       BYTE * pTxMsgBuffer_p,
                       BYTE * pRxMsgBuffer_p,
                       DWORD dwMaxTxBufSize_p);
extern tPdiAsyncStatus CnApi_handleInitPcpResp(
                       tPdiAsyncMsgDescr * pMsgDescr_p,
                       BYTE * pRxMsgBuffer_p,
                       BYTE * pTxMsgBuffer_p,
                       DWORD dwMaxTxBufSize_p);
extern tPdiAsyncStatus CnApi_handleCreateObjLinksResp(
                       tPdiAsyncMsgDescr * pMsgDescr_p,
                       BYTE * pRxMsgBuffer_p,
                       BYTE * pTxMsgBuffer_p,
                       DWORD dwMaxTxBufSize_p);
extern tPdiAsyncStatus CnApi_pfnCbCreateObjLinksRespFinished (struct sPdiAsyncMsgDescr * pMsgDescr_p);
extern tPdiAsyncStatus CnApi_handleWriteObjResp(
                       tPdiAsyncMsgDescr * pMsgDescr_p,
                       BYTE * pRxMsgBuffer_p,
                       BYTE * pTxMsgBuffer_p,
                       DWORD dwMaxTxBufSize_p);
extern tPdiAsyncStatus CnApi_pfnCbInitPcpRespFinished (struct sPdiAsyncMsgDescr * pMsgDescr_p);
extern tPdiAsyncStatus CnApi_handleLinkPdosReq(
                       tPdiAsyncMsgDescr * pMsgDescr_p,
                       BYTE * pRxMsgBuffer_p,
                       BYTE * pTxMsgBuffer_p,
                       DWORD dwMaxTxBufSize_p);
extern tPdiAsyncStatus CnApi_pfnCbLinkPdosReqFinished (struct sPdiAsyncMsgDescr * pMsgDescr_p);


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
#endif /* CNAPIASYNC_H_ */
/* END-OF-FILE */

