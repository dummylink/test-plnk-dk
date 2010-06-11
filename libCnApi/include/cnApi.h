/**
********************************************************************************
\file		cnApi.h

\brief		Main header file of CN API library

\author		Josef Baumgartner

\date		22.03.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This header file contains definitions for the CN API.
*******************************************************************************/

#ifndef CNAPI_H_
#define CNAPI_H_

/******************************************************************************/
/* includes */
#include "cnApiDebug.h"
#include "cnApiGlobal.h"     // global definitions

/******************************************************************************/
/* defines */

/* some debug definitions */
#define	DEBUG_LVL_CNAPI_FUNC			DEBUG_LVL_09
#define	DEBUG_LVL_CNAPI_FUNC_TRACE0		DEBUG_LVL_09_TRACE0
#define	DEBUG_LVL_CNAPI_FUNC_TRACE1		DEBUG_LVL_09_TRACE1
#define	DEBUG_LVL_CNAPI_FUNC_TRACE2		DEBUG_LVL_09_TRACE2
#define	DEBUG_LVL_CNAPI_FUNC_TRACE3		DEBUG_LVL_09_TRACE3

#define	DEBUG_LVL_CNAPI_ERR				DEBUG_LVL_10
#define	DEBUG_LVL_CNAPI_ERR_TRACE0		DEBUG_LVL_10_TRACE0
#define	DEBUG_LVL_CNAPI_ERR_TRACE1		DEBUG_LVL_10_TRACE1
#define	DEBUG_LVL_CNAPI_ERR_TRACE2		DEBUG_LVL_10_TRACE2
#define	DEBUG_LVL_CNAPI_ERR_TRACE3		DEBUG_LVL_10_TRACE3

#define	DEBUG_LVL_CNAPI_INFO			DEBUG_LVL_11
#define	DEBUG_LVL_CNAPI_INFO_TRACE0		DEBUG_LVL_11_TRACE0
#define	DEBUG_LVL_CNAPI_INFO_TRACE1		DEBUG_LVL_11_TRACE1
#define	DEBUG_LVL_CNAPI_INFO_TRACE2		DEBUG_LVL_11_TRACE2
#define	DEBUG_LVL_CNAPI_INFO_TRACE3		DEBUG_LVL_11_TRACE3


#define	DEBUG_LVL_CNAPI_INFO			DEBUG_LVL_11


#define	DEBUG_FUNC		DEBUG_TRACE1(DEBUG_LVL_09, "%s:\n", __func__)


#define	ASYNC_BUF_SIZE			0x200				///< default size of asynchronous buffer
#define	PDO_BUF_SIZE			0x100				///< default size of PDO buffer
#define	PDO_DESC_SIZE			0x100				///< default size of PDO descriptor buffer

#define	PCP_MAGIC				0x50435000			///< magic number identifies valid PCP memory

/******************************************************************************/
/* type definitions */

/**
 * CN API status codes
 *
 * tCnApiStatus contains the status codes that could be returned by the API
 * functions.
 */
typedef enum {
	kCnApiStatusOk = 0,					///< Ok, no error!
	kCnApiStatusError,					///< error
	kCnApiStatusMsgBufFull,				///< message buffer is full
	kCnApiStatusMsgBufEmpty,			///< message buffer is empty
	kCnApiStatusDataTooLong,			///< data too long for message buffer
	kCnApiStatusObjectNotExist,			///< object does not exist
	kCnApiStatusAllocationFailed,		///< memory allocation failed
	kCnApiStatusObjectLinkFailed,		///< linking object to memory failed
	kCnApiStatusCommandNotAccepted 		///< command isn't accepted
} tCnApiStatus;


/**
 * Valid status values of the PCP error register
 *
 * tCnApiCycleStatus contains the valid status codes of the PCP error register
 */
typedef enum {
	kCnApiSyncCycleOk = 0,				///< sync interrupt cycle ok
	kCnApiSyncCycleError				///< sync interrupt cycle error
} tCnApiCycleStatus;

/**
 * \brief enumeration with valid AP commands
 */
typedef enum {
	kApCmdNone = 0,
	kApCmdInit,
	kApCmdPreop,
	kApCmdReadyToOperate,
	kApCmdReboot
} tApCmd;


typedef struct sCnApiObjId {
	WORD		m_wIndex;
	BYTE		m_bSubIndex;
	BYTE		m_bNumEntries;
} tCnApiObjId;


// TODO: not used, do we need it?
typedef struct sCnApiReadQueue{
	int					m_iNumElements;
	tCnApiObjId 		*pObjectId;
} tCnApiReadQueue;

typedef enum eProcType {
	kProcTypeAp,
	kProcTypePcp
} tProcType;


/******************************************************************************/
/* definitions for asynchronous transfer functions */

/**
 * \brief constants for asynchronous transfer channels
 */
typedef enum eAsyncChannel {
	kAsyncChannelInternal = 0x00,
	kAsyncChannelSdo = 0x01
} tAsyncChannel;

/**
 * \brief enumeration for asynchronous commands
 */
typedef enum eAsyncCmd {
	kAsyncCmdInitPcpReq = 0x01,
	kAsyncCmdCreateObjReq,
	kAsyncCmdWriteObjReq,
	kAsyncCmdReadObjReq,
	kAsyncCmdInitPcpResp = 0x80,
	kAsyncCmdCreateObjResp,
	kAsyncCmdWriteObjResp,
	kAsyncCmdReadObjResp
} tAsyncCmd;

/**
 * \brief enumeration for asynchronous call status values
 */
typedef enum eAsyncCallStatus {
	kAsyncCallStatusPending = 1,			///< asynchronous call is still pending
	kAsyncCallStatusReady = 0,				///< asynchronous call was successfull
	kAsyncCallStatusSendError = -1,			///< sending request failed
	kAsyncCallStatusRespError = -2,			///< response timeout, no response from PCP
	kAsyncCallStatusChannelError = -3,		///< message received contained wrong channel
	kAsyncCallStatusReqIdError = -4,		///< message received contained wrong request Id
	kAsyncCallStatusTimeout = -5			///< asynchronous call timeout
} tAsyncCallStatus;

/**
 * \brief enumeration for asynchronous send status values
 */
typedef enum eAsyncSendStatus{
	kAsyncSendStatusOk = 0,					///< Ok, no error!
	kAsyncSendStatusBufFull = 1,			///< message buffer is full
	kAsyncSendStatusBufEmpty = 2,			///< message buffer is empty
	kAsyncSendStatusDataTooLong = -1		///< data too long for message buffer
} tAsyncSendStatus;


/**
 * \brief structure for InitPcpReq command
 */
typedef struct sInitPcpReq {
	BYTE					m_bCmd;
	BYTE					m_bReqId;
	BYTE					m_abMac[6];
	DWORD					m_dwRevision;
	DWORD					m_dwSerialNum;
	DWORD					m_dwVendorId;
	DWORD					m_dwProductCode;
	DWORD					m_dwDeviceType;
	DWORD					m_dwFeatureFlags;
	DWORD					m_dwNodeId;
	WORD					m_wIsoTxMaxPayload;
	WORD					m_wIsoRxMaxPayload;
	DWORD					m_dwPresMaxLatency;
	DWORD					m_dwAsendMaxLatency;
} tInitPcpReq;

/**
 * \brief structure for InitPcpResp command
 */
typedef struct sInitPcpResp {
	BYTE					m_bCmd;
	BYTE					m_bReqId;
	WORD					m_wStatus;
} tInitPcpResp;

/**
 * \brief structure for CreateObjReq command
 */
typedef struct sCreateObjReq {
	BYTE					m_bCmd;
	BYTE					m_bReqId;
	WORD					m_wNumObjs;
} tCreateObjReq;

/**
 * \brief structure for CreateObjResp command
 */
typedef struct sCreateObjResp {
	BYTE					m_bCmd;
	BYTE					m_bReqId;
	WORD					m_wStatus;
	WORD					m_wErrIndex;
	BYTE					m_bErrSubindex;
} tCreateObjResp;

/**
 * \brief structure for WriteObjReq command
 */
typedef struct sWriteObjReq {
	BYTE					m_bCmd;
	BYTE					m_bReqId;
	WORD					m_wNumObjs;
} tWriteObjReq;

/**
 * \brief structure for WriteObjResp command
 */
typedef struct sWriteObjResp {
	BYTE					m_bCmd;
	BYTE					m_bReqId;
	WORD					m_wStatus;
	WORD					m_wErrIndex;
	BYTE					m_bErrSubindex;
} tWriteObjResp;

/**
 * \brief structure for internal channel header
 */
typedef struct sAsyncIntHeader {
	BYTE					m_bCmd;
	BYTE					m_bReqId;
} tAsyncIntHeader;

/**
 * \brief structure for internal channel
 */
typedef union uAsyncIntChan {
	tAsyncIntHeader			m_intHeader;
	tInitPcpReq				m_initPcpReq;
	tInitPcpResp			m_initPcpResp;
	tCreateObjReq			m_createObjReq;
	tCreateObjResp			m_createObjResp;
	tWriteObjReq			m_writeObjReq;
	tWriteObjResp			m_writeObjResp;
} tAsyncIntChan;

typedef union uAsyncData {
	tAsyncIntChan			m_intChan;
} tAsyncChan;

/**
 * \brief Structure definition for asynchronous transfer buffer header
 */
typedef struct sAsyncMsgHeader {
	BYTE					m_bSync;
	BYTE					m_bChannel;
	WORD					m_wDataLen;
} tAsyncMsgHeader;

typedef struct sAsyncMsg {
	tAsyncMsgHeader			m_header;
	tAsyncChan				m_chan;
} tAsyncMsg;

/**
 * \brief constants for asynchronous transfer direction
 */
typedef enum eAsyncDir {
	kCnApiDirReceive,
	kCnApiDirTransmit
} tCnApiDir;

/**
 * \brief constants for SYN flags
 */
typedef enum eSynFlag {
	kMsgBufEmpty = 0x00,
	kMsgBufFull = 0x01
} tSynFlag;

/******************************************************************************/
/* definitions for PDO transfer functions */

typedef struct sObjTbl {
	WORD			m_wIndex;
	BYTE			m_bSubIndex;
	WORD			m_wSize;
	char			*m_pData;
} tObjTbl;

typedef struct sPdoDescHeader {
	WORD	m_wPdoDescVers;
	WORD	m_wPdoDescSize;
} tPdoDescHeader;

typedef struct sPdoDesc {
	WORD	m_wPdoIndex;
	BYTE	m_bPdoSubIndex;
	BYTE	m_reserved;
} tPdoDesc;

typedef struct sPdoSync {
	BYTE	m_bPdoWriteIndex;
	BYTE	m_bPdoReadIndex;
} tPdoSync;

#define EPL_PDOU_OBD_IDX_RX_COMM_PARAM  0x1400
#define EPL_PDOU_OBD_IDX_RX_MAPP_PARAM  0x1600
#define EPL_PDOU_OBD_IDX_TX_COMM_PARAM  0x1800
#define EPL_PDOU_OBD_IDX_TX_MAPP_PARAM  0x1A00

typedef	void (*tpfnPdoDescCb) (BYTE *pPdoDesc_p, WORD wPdoDescSize_p); 	///< type definition for PDO descriptor callback function
typedef	void (*tpfnPdoCopyCb) (BYTE *pPdoData_p); 						///< type definition for PDO copy callback function
typedef void (*tpfnSyncIntCb) (void);									///< type definition for Sync interrupt callback function

/******************************************************************************/

/**
 * \brief structure for POWERLINK initialization parameters
 */
typedef struct sCnApiInitParm {
	BYTE			m_abMac[6];
	BYTE			m_bNodeId;
	DWORD			m_dwRevision;
	DWORD			m_dwSerialNum;
	DWORD			m_dwVendorId;
	DWORD			m_dwProductCode;
	DWORD			m_dwDeviceType;
	DWORD			m_dwFeatureFlags;
	WORD			m_wIsoTxMaxPayload;
	WORD			m_wIsoRxMaxPayload;
	DWORD			m_dwPresMaxLatency;
	DWORD			m_dwAsendMaxLatency;
	DWORD			m_dwDpramBase;
} tCnApiInitParm;

/* definitions for AP state machine, transitions and states */
typedef enum {
	kApStateBooted = 0,
	kApStateReadyToInit,
	kApStateInit,
	kApStatePreop1,
	kApStatePreop2,
	kApStateReadyToOperate,
	kApStateOperational,
	kApStateError,
	kNumApState
} tApStates;

typedef enum {
	kApTransBootedReadyToInit = 0,
	kApTransReadyToInitInit,
	kApTransInitPreop1,
	kApTransPreop1Preop2,
	kApTransPreop2ReadyToOperate,
	kApTransReadyToOperateOperational,
	kApTransOperationalInit,
	kApTransReadyToInitError,
	kApTransPreop2Preop1,
	kApTransReadytoOperatePreop1,
	kApTransOperationalPreop1,
	kNumApTransitions
} tApTransitions;

/* definitions for PCP state machine, transitions and states */
typedef enum {
	kPcpStateBooted,
	kPcpStateInit,
	kPcpStatePreop1,
	kPcpStatePreop2,
	kPcpStateReadyToOperate,
	kPcpStateOperational,
	kNumPcpStates
} tPcpStates;

typedef enum {
	kPcpTransBootedInit = 0,
	kPcpTransInitPreop,
	kPcpTransPreop1Preop2,
	kPcpTransPreop2ReadyToOperate,
	kPcpTransReadyToOperateOperational,
	kPcpTransOperationalPreop1,
	kPcpTransOperationalBooted,
	kPcpTransOperationalShutdown,
	kPcpTransPreop2Preop1,
	kPcpTransReadyToOperatePreop1,
	kNumPcpTransitions
} tPcpTransitions;

/******************************************************************************/

/**
* \brief PCP control registers
*
* tPcpCtrlReg defines the PCP control registers.
*/
typedef struct sPcpControlReg {
	volatile DWORD			m_dwMagic;
	volatile BYTE			m_bState;
	volatile BYTE			m_bCommand;
	volatile BYTE			m_bError;
	volatile BYTE			m_bReserved1;
	volatile BYTE			m_bIntCtrl;
	volatile BYTE			m_bIntAck;
	volatile WORD			m_wReserved2;
	volatile WORD			m_wMinCycleTime;
	volatile WORD			m_wMaxCycleTime;
	volatile BYTE			m_bMaxCylceNum;
	volatile BYTE			m_bCycleError;
	volatile WORD			m_wCycleCorrect;
	volatile WORD			m_wTxPdoDescAdrs;
	volatile WORD			m_wTxPdoDescSize;
	volatile WORD			m_wRxPdoDescAdrs;
	volatile WORD			m_wRxPdoDescSize;
	volatile WORD			m_wTxPdoBufAdrs;
	volatile WORD			m_wTxPdoBufSize;
	volatile WORD			m_wRxPdoBufAdrs;
	volatile WORD			m_wRxPdoBufSize;
	volatile WORD			m_wTxAsyncBufAdrs;
	volatile WORD			m_wTxAsyncBufSize;
	volatile WORD			m_wRxAsyncBufAdrs;
	volatile WORD			m_wRxAsyncBufSize;
	volatile tPdoSync		m_txPdoSync;
	volatile tPdoSync		m_rxPdoSync;
} tPcpCtrlReg;

/******************************************************************************/
/* global variables */
extern tCnApiInitParm		*pInitParm_g;		// pointer to POWERLINK init parameters
extern tPcpCtrlReg			*pCtrlReg_g;		// pointer to PCP control registers

/******************************************************************************/
/* function declarations */
extern tCnApiStatus CnApi_init(BYTE *pDpram_p, tCnApiInitParm *pInitParm_p);
extern void CnApi_exit(void);
extern void CnApi_activateApStateMachine(void);
extern BOOL CnApi_processApStateMachine(void);
extern void CnApi_initSyncInt(WORD wMinCycleTime_p, WORD wMaxCycleTime_p, BYTE bMaxCycleNum);
extern void CnApi_enableSyncInt(void);
extern void CnApi_disableSyncInt(void);
extern int CnApi_initObjects(DWORD dwNumObjects_p);
extern int CnApi_linkObject(WORD wIndex_p, BYTE bSubIndex_p, WORD wSize_p, char *pAdrs_p);
extern void CnApi_cleanupObjects(void);
extern void CnApi_transferPdo(void);

#endif /* CNAPI_H_ */
