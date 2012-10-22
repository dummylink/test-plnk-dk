/**
********************************************************************************
\file       cnApiTypAsync.h

\brief      Global header file for PCP PDI (CN) and libCnApi (Async module)

This header provides data structures for the PCP and AP processors async module.
It defines message formats and common types.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPITYPASYNC_H_
#define CNAPITYPASYNC_H_

/******************************************************************************/
/* includes */
#include "cnApiTyp.h"

#include "EplInc.h"
#include "EplFrame.h"     ///< for SDO frame layout type


/******************************************************************************/
/* defines */

#define INIT_PCP_REQ_STRNG_SIZE (CN_API_INIT_PARAM_STRNG_SIZE - 1)

/******************************************************************************/
/* typedefs */

/**
 * \brief constants for SYN flags
 */
typedef enum eSynFlag {
    kMsgBufWriteOnly = 0x01,
    kMsgBufReadOnly = 0x80
} tSynFlag;

/**
 * \brief constants for LinkPdosReq message originator
 */
typedef enum eLnkPdoMsgOrig {
    kAsyncLnkPdoMsgOrigObdAccess = 0x01,
    kAsyncLnkPdoMsgOrigNmtCmd    = 0x08
} tLnkPdoMsgOrig;

typedef enum ePdiAsyncTransferType{
    kPdiAsyncTrfTypeDirectAccess = 0x01, ///< direct access to Pdi buffer (Pdi buffer size is sufficient)
    kPdiAsyncTrfTypeLclBuffering,        ///< segmented access to Pdi buffer (Pdi buffer size is to small)
    kPdiAsyncTrfTypeUserBuffering,       ///< user provides buffer (valid through whole transfer time)
    kPdiAsyncTrfTypeAutoDecision,        ///< transfer type will be chosen automatically (only works for Rx)
} tPdiAsyncTransferType;

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

typedef enum ePdiAsyncMsgStatus {
    kPdiAsyncMsgStatusNotActive             = 0x00,
    kPdiAsyncMsgStatusQueuing               = 0x01,
    kPdiAsyncMsgStatusProcessing            = 0x02,
    kPdiAsyncMsgStatusTransferCompleted     = 0x03,
    kPdiAsyncMsgStatusInterrupted           = 0x04,
    kPdiAsyncMsgStatusError                 = 0x05,
} tPdiAsyncMsgStatus;

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
    kPdiAsyncStatusRetry                = 0x0011,   ///< retry this command (flow control)
    kPdiAsyncStatusInvalidEvent         = 0x0012,   ///< invalid event was posted to process function
    kPdiAsyncStatusInvalidState         = 0x0013,   ///< message is invalid in current NmtState
    kPdiAsyncStatusInvalidMessage       = 0x0014,   ///< unexpected message received
    kPdiAsyncStatusFreeInstance         = 0x0015,   ///< free instance found
    kPdiAsyncStatusUnhandledTransfer    = 0x0016,   ///< no handle assigned to process buffer
} tPdiAsyncStatus; ///< module wide return and status codes

/**
 * \brief constants for asynchronous transfer channels
 */
typedef enum eAsyncChannel {
    kAsyncChannelInternal = 0x01,
    kAsyncChannelSdo = 0x02
} tAsyncChannel;

/**
 * \brief constants for asynchronous transfer direction
 */
typedef enum ePcpPdiAsyncDir {
    kCnApiDirReceive,
    kCnApiDirTransmit,
    kCnApiDirNone,
} tPcpPdiAsyncDir;

/******************************************************************************/
/* structs */

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
    BYTE                    m_bPad1;
    BYTE                    m_bStatus;
    BYTE                    m_bPad2;
} PACK_STRUCT tInitPcpResp;

/**
 * \brief structure for LinkPdosReq command
 */
typedef struct sLinkPdosReq {
    BYTE                    m_bMsgId;
    BYTE                    m_bOrigin;      ///< message originator, type: tLnkPdoMsgOrig
    WORD                    m_wCommHdl;     ///< connection handle of originator module
    BYTE                    m_bDescrCnt;
    BYTE                    m_Pad1;
//  WORD                    m_Pad2;
} PACK_STRUCT tLinkPdosReq;

/**
 * \brief structure for CreateObjResp command
 */
typedef struct sLinkPdosResp {
    BYTE                    m_bMsgId;
    BYTE                    m_bOrigin;      ///< message originator, type: tLnkPdoMsgOrig
    WORD                    m_wCommHdl;     ///< connection handle of originator module
    DWORD                   m_dwErrCode;    ///< 0 = OK, else SDO abort code
} PACK_STRUCT tLinkPdosResp;


/**
 * \brief structure connects LinkPdosReq message and OBD mapping handle
 */
typedef struct sLinkPdosReqComCon {
    WORD       m_wMapIndex;
    BYTE       m_bPdoDir;                   ///< value type: tPdoDir
    BYTE       m_bMapObjCnt;
    BYTE       m_bBufferNum;
    BYTE       m_bMapVersion;
    WORD       m_wComConHdl;                ///< PDI connection handle
} tLinkPdosReqComCon;

/**
 * \brief structure connects object access messages and SDO command layer
 */
typedef struct sObjAccSdoComCon {
    WORD                    m_wObdAccConNum;    ///< OBD access communication connection
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
    WORD                    m_wComConHdl;      ///< connection handle of originator module
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
    volatile BYTE                    m_bSync;
    volatile BYTE                    m_bChannel;
    volatile BYTE                    m_bMsgType;
    volatile BYTE                    m_bPad;
    volatile WORD                    m_wFrgmtLen;
    volatile WORD                    wReserved;
    volatile DWORD                   m_dwStreamLen;
} PACK_STRUCT tAsyncPdiBufCtrlHeader;

typedef struct sAsyncMsg {
    tAsyncPdiBufCtrlHeader  m_header;
    tAsyncChannel           m_chan;
} PACK_STRUCT tAsyncMsg;

typedef struct sPdiAsyncParam {
    tAsyncChannel   ChanType_m;                 ///< type of channel the message belongs to
    tPcpStates      aNmtList_m[kNumPcpStates];  ///< valid NmtStates for this message
    //not used: tPdiAsMsgPrio   Prio_m;         ///< message priority
    WORD           wTimeout_m;                  ///< timeout value of message delivery or reception (if set to 0, wait forever)
} tPdiAsyncMsgParam;

/**
 * \brief descriptor of asynchronous message buffer
 */
typedef struct sPcpPdiAsyncBufDescr {
  tAsyncMsg *  pAdr_m;
  WORD         wPdiOffset_m;  ///< DPRAM offset (used for serial interface)
  WORD         wMaxPayload_m;
} tPcpPdiAsyncMsgBufDescr;

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

#endif /* CNAPITYPASYNC_H_ */

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

