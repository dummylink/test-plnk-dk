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


/******************************************************************************/
/* defines */

#define INIT_PCP_REQ_STRNG_SIZE (CN_API_INIT_PARAM_STRNG_SIZE - 1)

/******************************************************************************/
/* typedefs */

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
    kPdiAsyncMsgInvalid                 = 0x00,
    kPdiAsyncMsgIntInitPcpReq           = 0x01, ///< internal AP <-> PCP communication messages
    kPdiAsyncMsgIntInitPcpResp          = 0x02,
    kPdiAsyncMsgIntCreateObjLinksReq    = 0x03,
    kPdiAsyncMsgIntCreateObjLinksResp   = 0x04,
    kPdiAsyncMsgIntLinkPdosReq          = 0x05,
    kPdiAsyncMsgIntLinkPdosResp         = 0x06,
    kPdiAsyncMsgIntObjAccReq            = 0x07,
    kPdiAsyncMsgIntObjAccResp           = 0x08,
    kPdiAsyncMsgExtTxSdoWriteByIndex    = 0x09, ///< external messages from network
    kPdiAsyncMsgExtRxSdoWriteByIndex    = 0x0A,
    kPdiAsyncMsgExtTxSdoReadByIndex     = 0x0B,
    kPdiAsyncMsgExtRxSdoReadByIndex     = 0x0C,
    kPdiAsyncMsgExtTxFirmwareStream     = 0x0D,
    kPdiAsyncMsgExtRxFirmwareStream     = 0x0E,
    kPdiAsyncMsgExtTxDataTransfer       = 0x0F,
    kPdiAsyncMsgExtRxDataTransfer       = 0x10,
    kPdiAsyncMsgExtTxIPPacket           = 0x11,
    kPdiAsyncMsgExtRxIPPacket           = 0x12,
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
    kPdiAsyncStatusOutOfSync            = 0x0009,   ///< sender and receiver are not synchronized
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
    kPdiAsyncStatusFreeError            = 0x0017,   ///< unable to free the buffer
    kPdiAsyncStatusMtuExceeded          = 0x0018,   ///< maximum MTU exceeded
} tPdiAsyncStatus; ///< module wide return and status codes

/**
 * \brief constants for asynchronous transfer channels
 */
typedef enum eAsyncChannel {
    kAsyncChannelInternal = 0x01,
    kAsyncChannelExternal = 0x02
} tAsyncChannel;

/**
 * \brief constants for asynchronous transfer direction
 */
typedef enum ePcpPdiAsyncDir {
    kCnApiDirReceive     = 0x00,
    kCnApiDirTransmit    = 0x01,
    kCnApiDirNone        = 0x02,
} tPcpPdiAsyncDir;

/**
 * \brief constants for LinkPdosReq message originator
 */
typedef enum eLnkPdoMsgOrig {
    kAsyncLnkPdoMsgOrigObdAccess = 0x01,
    kAsyncLnkPdoMsgOrigNmtCmd    = 0x08
} tLnkPdoMsgOrig;

/******************************************************************************/
/* structs */

/**
 * \brief structure for InitPcpReq command
 */
typedef struct sInitPcpReq {
    volatile BYTE                    m_bReqId;
    volatile BYTE                    m_bNodeId;
    volatile BYTE                    m_abMac[6];
    volatile WORD                    m_wMtu;
    volatile WORD                    m_wPad;
    volatile DWORD                   m_dwIpAddress;
    volatile DWORD                   m_dwSubNetMask;
    volatile BYTE                    m_strDevName[INIT_PCP_REQ_STRNG_SIZE];   // NMT_ManufactDevName_VS (0x1008/0 PCP local OD)
    volatile BYTE                    m_strHwVersion[INIT_PCP_REQ_STRNG_SIZE]; // NMT_ManufactHwVers_VS  (0x1009/0 PCP local OD)
    volatile BYTE                    m_strSwVersion[INIT_PCP_REQ_STRNG_SIZE]; // NMT_ManufactSwVers_VS  (0x100A/0 PCP local OD)
    volatile BYTE                    m_strHostname[INIT_PCP_REQ_STRNG_SIZE]; // NMT_HostName_VS  (0x1F9A/0 PCP local OD)
    volatile DWORD                   m_dwRevision;       // NMT_IdentityObject_REC.RevisionNo_U32
    volatile DWORD                   m_dwSerialNum;      // NMT_IdentityObject_REC.SerialNo_U32
    volatile DWORD                   m_dwVendorId;       // NMT_IdentityObject_REC.VendorId_U32
    volatile DWORD                   m_dwProductCode;    // NMT_IdentityObject_REC.ProductCode_U32
    volatile DWORD                   m_dwDeviceType;     // NMT_DeviceType_U32
} PACK_STRUCT tInitPcpReq;

/**
 * \brief structure for InitPcpResp command
 */
typedef struct sInitPcpResp {
    volatile BYTE                    m_bReqId;
    volatile BYTE                    m_bPad1;
    volatile BYTE                    m_bStatus;
    volatile BYTE                    m_bPad2;
} PACK_STRUCT tInitPcpResp;

/**
 * \brief structure for LinkPdosReq command
 */
typedef struct sLinkPdosReq {
    volatile BYTE                    m_bMsgId;
    volatile BYTE                    m_bOrigin;      ///< message originator, type: tLnkPdoMsgOrig
    volatile WORD                    m_wCommHdl;     ///< connection handle of originator module
    volatile BYTE                    m_bDescrCnt;
    volatile BYTE                    m_bPad1;
    volatile WORD                    m_wPad2;
} PACK_STRUCT tLinkPdosReq;

/**
 * \brief structure for CreateObjResp command
 */
typedef struct sLinkPdosResp {
    volatile BYTE                    m_bMsgId;
    volatile BYTE                    m_bOrigin;      ///< message originator, type: tLnkPdoMsgOrig
    volatile WORD                    m_wCommHdl;     ///< connection handle of originator module
    volatile DWORD                   m_dwErrCode;    ///< 0 = OK, else SDO abort code
} PACK_STRUCT tLinkPdosResp;

/**
 * \brief SDO command frame layout
 */
typedef struct sCnApiAsySdoCom {
    volatile BYTE                    m_le_bReserved;
    volatile BYTE                    m_le_bTransactionId;
    volatile BYTE                    m_le_bFlags;
    volatile BYTE                    m_le_bCommandId;
    volatile WORD                    m_le_wSegmentSize;
    volatile WORD                    m_le_wReserved;
    volatile BYTE                    m_le_abCommandData[8];  // just reserve a minimum number of bytes as a placeholder
}PACK_STRUCT tCnApiAsySdoCom;

/**
 * \brief structure connects object access messages and SDO command layer
 */
typedef struct sObjAccSdoComCon {
    WORD                    m_wObdAccConNum;    ///< OBD access communication connection
    tCnApiAsySdoCom *       m_pSdoCmdFrame;     ///< pointer to SDO command frame
    unsigned int            m_uiSizeOfFrame;    ///< size of SDO command frame
    void *                  m_pUserArg;         ///< general purpose argument
} tObjAccSdoComCon;

/**
 * \brief structure for ObjAccReq command
 */
typedef struct sObjAccReq {
    volatile BYTE               m_bReqId;
    volatile BYTE               m_bPad;
    volatile WORD               m_wComConHdl;      ///< connection handle of originator module
    volatile tCnApiAsySdoCom    m_SdoCmdFrame;
} PACK_STRUCT tObjAccMsg;

/**
 * \brief Structure definition for asynchronous transfer buffer header
 */
typedef struct sAsyncMsgHeader {
    volatile BYTE           m_bSync;
    volatile BYTE           m_bChannel;
    volatile BYTE           m_bMsgType;
    volatile BYTE           m_bPad;
    volatile WORD           m_wFrgmtLen;
    volatile WORD           wReserved;
    volatile DWORD          m_dwStreamLen;
} PACK_STRUCT tAsyncPdiBufCtrlHeader;

typedef struct sAsyncMsg {
    tAsyncPdiBufCtrlHeader  m_header;
    tAsyncChannel           m_chan;
} PACK_STRUCT tAsyncMsg;

typedef struct sPdiAsyncParam {
    tAsyncChannel   ChanType_m;                 ///< type of channel the message belongs to
    tPcpStates      aNmtList_m[kNumPcpStates];  ///< valid NmtStates for this message
    WORD            wTimeout_m;                 ///< timeout value of message delivery or reception (if set to 0, wait forever)
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

