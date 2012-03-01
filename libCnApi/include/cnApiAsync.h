/******************************************************************************
* Copyright � 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1                           
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
#ifdef MAKE_BUILD_PCP
    #include "Epl.h"
#endif
    #include "EplFrame.h"


/******************************************************************************/
/* defines */
#define MAX_ASYNC_STREAM_LENGTH   10240 ///< max local buffer size (maximum = max value(DWORD))

#define MAX_PDI_ASYNC_TX_MESSAGES 10    ///< max: 0xFF
#define MAX_PDI_ASYNC_RX_MESSAGES  9    ///< max: 0xFF

#define PDI_ASYNC_CHANNELS_MAX  2 //TODO: get from system.h?

#define INVALID_ELEMENT            0xFF ///< indicator for invalid array element

#define INIT_PCP_REQ_STRNG_SIZE (CN_API_INIT_PARAM_STRNG_SIZE - 1)

// renaming of functions which have exactly the same functionality
//#define cnApiAsync_doObjAccResp     cnApiAsync_doObjAccReq
//#define cnApiAsync_handleObjAccResp cnApiAsync_handleObjAccReq
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
 * \brief structure for asynchronous message types
 */
typedef enum ePdiAsyncMsgType {
    kPdiAsyncMsgInvalid         = 0x00,
    kPdiAsyncMsgIntInitPcpReq   = 0x01, ///< internal AP <-> PCP communication messages
    kPdiAsyncMsgIntInitPcpResp,
    kPdiAsyncMsgIntCreateObjLinksReq,
    kPdiAsyncMsgIntCreateObjLinksResp,
    kPdiAsyncMsgIntLinkPdosReq,
    kPdiAsyncMsgIntLinkPdosResp,
    kPdiAsyncMsgIntObjAccReq,
    kPdiAsyncMsgIntObjAccResp,
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
    BYTE                    m_bReqId;
    BYTE                    m_bPad;
    BYTE                    m_abMac[6];
    BYTE                    m_strDevName[INIT_PCP_REQ_STRNG_SIZE];   // NMT_ManufactDevName_VS (0x1008/0 PCP local OD)
    BYTE                    m_strHwVersion[INIT_PCP_REQ_STRNG_SIZE]; // NMT_ManufactHwVers_VS  (0x1009/0 PCP local OD)
    BYTE                    m_strSwVersion[INIT_PCP_REQ_STRNG_SIZE]; // NMT_ManufactSwVers_VS  (0x100A/0 PCP local OD)
    DWORD                   m_dwRevision;       // NMT_IdentityObject_REC.RevisionNo_U32
    DWORD                   m_dwSerialNum;      // NMT_IdentityObject_REC.SerialNo_U32
    DWORD                   m_dwVendorId;       // NMT_IdentityObject_REC.VendorId_U32
    DWORD                   m_dwProductCode;    // NMT_IdentityObject_REC.ProductCode_U32
    DWORD                   m_dwDeviceType;     // NMT_DeviceType_U32
    DWORD                   m_dwNodeId;

} PACK_STRUCT tInitPcpReq;

/**
 * \brief structure for InitPcpResp command
 */
typedef struct sInitPcpResp {
    BYTE                    m_bReqId;
    BYTE                    m_bPad;
    WORD                    m_wStatus;
} PACK_STRUCT tInitPcpResp;

/**
 * \brief structure for LinkPdosReq command
 */
typedef struct sLinkPdosReq {
    BYTE                    m_bDescrCnt;
    BYTE                    m_bDescrVers;
} PACK_STRUCT tLinkPdosReq; //TODO: use async buffers!

/**
 * \brief structure for CreateObjResp command
 */
typedef struct sLinkPdosResp {
    BYTE                    m_bDescrVers;
    BYTE                    m_bPad;
    WORD                    m_wStatus;
//    WORD                    m_wErrIndex;
//    BYTE                    m_bErrSubindex;
} PACK_STRUCT tLinkPdosResp;

/**
 * \brief structure connects object access messages and SDO command layer
 */
typedef struct sObjAccSdoComCon {
    WORD                    m_wSdoSeqConHdl;    ///< SDO command layer connection handle number
    tEplAsySdoCom *         m_pSdoCmdFrame;     ///< pointer to SDO command frame
    unsigned int            m_uiSizeOfFrame;    ///< size of SDO command frame
    void *                  m_pUserArg;         ///< general purpose argument
} tObjAccSdoComCon;

/**
 * \brief structure for ObjAccReq command
 */
typedef struct sObjAccReq {
    BYTE                    m_bReqId;
    BYTE                    m_bPad;
    WORD                    m_wHdlCom;      ///< connection handle of originator module
    tEplAsySdoCom           m_SdoCmdFrame;
} PACK_STRUCT tObjAccMsg;

/**
 * \brief structure for internal channel header
 */
typedef struct sAsyncIntHeader {
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
    WORD                    m_wReserved;
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

typedef enum ePdiAsyncMsgStatus {
    kPdiAsyncMsgStatusNotActive             = 0x00,
    kPdiAsyncMsgStatusQueuing               = 0x01,
    kPdiAsyncMsgStatusProcessing            = 0x02,
    kPdiAsyncMsgStatusTransferCompleted     = 0x03,
    kPdiAsyncMsgStatusInterrupted           = 0x04,
    kPdiAsyncMsgStatusError                 = 0x05,
} tPdiAsyncMsgStatus;

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
extern tLinkPdosResp LinkPdosResp_g;        ///< Link Pdos Response message

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */
int CnApiAsync_init(void);

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */
extern int CnApiAsync_create(void);
extern int CnApiAsync_reset(void);
extern tPdiAsyncStatus CnApiAsync_initMsg(tPdiAsyncMsgType MsgType_p, tPcpPdiAsyncDir Direction_p, const tPdiAsyncBufHdlCb  pfnCbMsgHdl_p,
                                           const tPcpPdiAsyncMsgBufDescr * pPdiBuffer_p, tPdiAsyncMsgType RespMsgType_p,
                                           tPdiAsyncTransferType TransferType_p, tAsyncChannel ChanType_p,
                                           const tPcpStates * paValidNmtList_p, WORD wTimeout_p);

extern void CnApiAsync_resetMsgLogCounter(void);

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
extern void CnApi_enableAsyncSmProcessing(void);
extern void CnApi_disableAsyncSmProcessing(void);

/* functions for asynchronous transfers */
extern tPdiAsyncStatus CnApi_doInitPcpReq(
                       tPdiAsyncMsgDescr * pMsgDescr_p,
                       BYTE * pTxMsgBuffer_p,
                       BYTE * pRxMsgBuffer_p,
                       DWORD dwMaxTxBufSize_p);
extern tPdiAsyncStatus CnApi_doLinkPdosResp(
                       tPdiAsyncMsgDescr * pMsgDescr_p,
                       BYTE* pTxMsgBuffer_p,
                       BYTE* pRxMsgBuffer_p,
                       DWORD dwMaxTxBufSize_p);
extern tPdiAsyncStatus CnApi_handleInitPcpResp(
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
extern tPdiAsyncStatus CnApi_pfnCbLinkPdosRespFinished (struct sPdiAsyncMsgDescr * pMsgDescr_p);


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
#endif /* CNAPIASYNC_H_ */
/* END-OF-FILE */

