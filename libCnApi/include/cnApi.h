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
#include "cnApiCfg.h"
#include "system.h"


/******************************************************************************/
/* defines */

/* CN API definitions */

/* from PCP system.h */
#define TPDO_CHANNELS_MAX       POWERLINK_0_PDI_PCP_PDITPDOS ///< Max Number of TxPDO's of this CN
#define RPDO_CHANNELS_MAX		POWERLINK_0_PDI_PCP_PDIRPDOS ///< Max Number of RxPDO's of this CN
#define MAX_NUM_LINKED_OBJ_AP   0//not yet used

#ifndef POWERLINK_0_PDI_PCP_PDITPDOS
#error "cnApiCfg.h has not been generated correctly!"
#endif /* ndef POWERLINK_0_PDI_PCP_PDITPDOS */

#define	PCP_MAGIC					0x50435000		///< magic number identifies valid PCP memory
#define SYNC_IRQ_ACK                0               ///< Sync IRQ Bit shift (for AP only)

/* Control Register Offsets, used for SPI */
#ifdef CN_API_USING_SPI
 #define PCP_CTRLREG_START_ADR               0x00
 #define PCP_CTRLREG_MAGIC_OFFSET            offsetof(tPcpCtrlReg, m_dwMagic)        //0x00
 #define PCP_CTRLREG_SYNMD_OFFSET            offsetof(tPcpCtrlReg, m_bSyncMode)      //0x04
 #define PCP_CTRLREG_ERROR_OFFSET            offsetof(tPcpCtrlReg, m_bError)         //0x05
 #define PCP_CTRLREG_CMD_OFFSET              offsetof(tPcpCtrlReg, m_bCommand)       //0x06
 #define PCP_CTRLREG_STATE_OFFSET            offsetof(tPcpCtrlReg, m_bState)         //0x07
 #define PCP_CTRLREG_MAXCYCT_OFFSET          offsetof(tPcpCtrlReg, m_wMaxCycleTime)  //0x08
 #define PCP_CTRLREG_MINCYCT_OFFSET          offsetof(tPcpCtrlReg, m_wMinCycleTime)  //0x0A
 #define PCP_CTRLREG_CYCCRCT_OFFSET          offsetof(tPcpCtrlReg, m_wCycleCorrect)  //0x0C
 #define PCP_CTRLREG_CYCERR_OFFSET           offsetof(tPcpCtrlReg, m_bCycleError)    //0x0E
 #define PCP_CTRLREG_MAXCYCNUM_OFFSET        offsetof(tPcpCtrlReg, m_bMaxCylceNum)   //0x0F
 #define PCP_CTRLREG_SYNCIR_CYCTIME_OFFSET   offsetof(tPcpCtrlReg, m_dwSyncIntCycTime)//0x10
 #define PCP_CTRLREG_RESERVED1_OFFSET        offsetof(tPcpCtrlReg, m_dwReserved1)    //0x14
 #define PCP_CTRLREG_TPDO0_BUFSIZE_OFFSET    offsetof(tPcpCtrlReg, m_wTxPdo0BufSize) //0x18
 #define PCP_CTRLREG_TPDO0_OFST_OFFSET       pCtrlReg_g->m_wTxPdo0BufAoffs           //0x1A
 #define PCP_CTRLREG_RPDO0_BUFSIZE_OFFSET    offsetof(tPcpCtrlReg, m_wRxPdo0BufSize) //0x1C
 #define PCP_CTRLREG_RPDO0_OFST_OFFSET       pCtrlReg_g->m_wRxPdo0BufAoffs           //0x1E
 #define PCP_CTRLREG_RPDO1_BUFSIZE_OFFSET    offsetof(tPcpCtrlReg, m_wRxPdo1BufSize) //0x20
 #define PCP_CTRLREG_RPDO1_OFST_OFFSET       pCtrlReg_g->m_wRxPdo1BufAoffs           //0x22
 #define PCP_CTRLREG_RPDO2_BUFSIZE_OFFSET    offsetof(tPcpCtrlReg, m_wRxPdo2BufSize) //0x24
 #define PCP_CTRLREG_RPDO2_OFST_OFFSET       pCtrlReg_g->m_wRxPdo2BufAoffs           //0x26

 #define PCP_CTRLREG_TX_ASYNC_BUFSIZE_OFFSET offsetof(tPcpCtrlReg, m_wTxAsyncBufSize) //0x30
 #define PCP_CTRLREG_TX_ASYNC_OFST_OFFSET    pCtrlReg_g->m_wTxAsyncBufAoffs           //0x32
 #define PCP_CTRLREG_RX_ASYNC_BUFSIZE_OFFSET offsetof(tPcpCtrlReg, m_wRxAsyncBufSize) //0x34
 #define PCP_CTRLREG_RX_ASYNC_OFST_OFFSET    pCtrlReg_g->m_wRxAsyncBufAoffs           //0x36
 #define PCP_CTRLREG_RPDO0ACK_OFFSET         offsetof(tPcpCtrlReg, m_bRxPdo0Ack)      //0x38
 #define PCP_CTRLREG_RPDO1ACK_OFFSET         offsetof(tPcpCtrlReg, m_bRxPdo1Ack)      //0x39
 #define PCP_CTRLREG_RPDO2ACK_OFFSET         offsetof(tPcpCtrlReg, m_bRxPdo2Ack)      //0x3A
 #define PCP_CTRLREG_TPDOACK_OFFSET          offsetof(tPcpCtrlReg, m_bTxPdo0Ack)      //0x3B
 #define PCP_CTRLREG_SYNCIRQCTRL_OFFSET      offsetof(tPcpCtrlReg, m_bSyncIrqControl) //0x3C
 #define PCP_CTRLREG_SPAN                    sizeof(tPcpCtrlReg)
#endif /* CN_API_USING_SPI */

/* Timer definitions */
#define PCP_PRESENCE_TIMEOUT 50

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
	kApCmdNone = -1,
	kApCmdInit = 0,
	kApCmdPreop = 1,
	kApCmdReadyToOperate = 2,
	kApCmdReboot = 3
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


typedef enum eAsyncTxState {
    kAsyncTxStateReady,             ///< asynchronous tx service is ready to use
    kAsyncTxStateBusy,              ///< asynchronous tx is processing
    kAsyncTxStatePending,           ///< asynchronous tx is waiting to be fetched
    kAsyncTxStateStopped            ///< asynchronous transmission has not been fetched in time
} tAsyncTxState;

typedef enum eAsyncRxState {
    kAsyncRxStateReady,             ///< asynchronous rx service is ready to use
    kAsyncRxStateBusy,              ///< asynchronous rx is processing
    kAsyncRxStatePending,           ///< asynchronous rx is waiting for data
    kAsyncRxStateStopped            ///< no tx data could be fetched in time
} tAsyncRxState;

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
	kAsyncCmdCreateObjLinksReq,
	kAsyncCmdWriteObjReq,
	kAsyncCmdReadObjReq,
	kAsyncCmdInitPcpResp = 0x80,
	kAsyncCmdCreateObjLinksResp,
	kAsyncCmdLinkPdosReq,
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
} tCreateObjLksReq;

/**
 * \brief structure for CreateObjResp command
 */
typedef struct sCreateObjResp {
	BYTE					m_bCmd;
	BYTE					m_bReqId;
	WORD					m_wStatus;
	WORD					m_wErrIndex;
	BYTE					m_bErrSubindex;
} tCreateObjLksResp;

typedef struct sLinkPdosReq {
    BYTE                    m_bCmd;
    BYTE                    m_reserved;
    BYTE                    m_bDescrCnt;
    BYTE                    m_bDescrVers;
} tLinkPdosReq;

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
	tCreateObjLksReq		m_createObjLinksReq;
	tCreateObjLksResp		m_createObjLinksResp;
	tLinkPdosReq            m_linkPdosReq;
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
	WORD					m_wFrgmtLen;
	DWORD                   m_dwStreamLen;
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
	kMsgBufWriteOnly = 0x00,
	kMsgBufReadOnly = 0x01
} tSynFlag;

/******************************************************************************/
/* definitions for PDO transfer functions */

typedef struct sObjTbl {
	WORD			m_wIndex;
	BYTE			m_bSubIndex;
	WORD			m_wSize;
	char			*m_pData;
} tObjTbl;

typedef enum ePdoDir {
   TPdo = 0x01, ///< Transmit PDO
   RPdo = 0x80  ///< Receive PDO
} tPdoDir;

typedef struct sPdoDescHeader {
	WORD	   m_bEntryCnt;
	BYTE       m_bPdoDir;
	BYTE       m_bBufferNum;
} tPdoDescHeader;

typedef struct sPdoDesc {
	WORD	m_wPdoIndex;
	BYTE	m_bPdoSubIndex;
	BYTE	m_bReserved;    // NumObjChain not used
} tPdoDescEntry;

#define EPL_PDOU_OBD_IDX_RX_COMM_PARAM  0x1400
#define EPL_PDOU_OBD_IDX_RX_MAPP_PARAM  0x1600
#define EPL_PDOU_OBD_IDX_TX_COMM_PARAM  0x1800
#define EPL_PDOU_OBD_IDX_TX_MAPP_PARAM  0x1A00

typedef	void (*tpfnPdoDescCb) (BYTE *pPdoDesc_p, WORD wDescrEntries_p); ///< type definition for PDO descriptor callback function
typedef	void (*tpfnPdoCopyCb) (BYTE *pPdoData_p); 						///< type definition for PDO copy callback function
typedef void (*tpfnSyncIntCb) (void);									///< type definition for Sync interrupt callback function
typedef int (*tpfnSpiMasterTxCb) (unsigned char *pTxBuf_p, int iBytes_p);
typedef int (*tpfnSpiMasterRxCb) (unsigned char *pTxBuf_p, int iBytes_p);

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

/* definitions for PCP state machine, transitions and states */
typedef enum { //TODO: define state "none?" - adapt docu for correct values!
	kPcpStateBooted = 0,
	kPcpStateInit,
	kPcpStatePreop1,
	kPcpStatePreop2,
	kPcpStateReadyToOperate,
	kPcpStateOperational,
	kNumPcpStates
} tPcpStates;

/******************************************************************************/

/**
* \brief PCP control registers
*
* tPcpCtrlReg defines the PCP control registers.
*/

struct sPcpControlReg {
	volatile DWORD			m_dwMagic;
	volatile BYTE			m_bSyncMode;
	volatile BYTE			m_bError;
	volatile BYTE			m_bCommand;
	volatile BYTE			m_bState;
	volatile WORD			m_wMaxCycleTime;
	volatile WORD			m_wMinCycleTime;
	volatile WORD			m_wCycleCorrect;
	volatile BYTE			m_bCycleError;
	volatile BYTE			m_bMaxCylceNum;
    volatile DWORD          m_dwSyncIntCycTime;
	volatile DWORD          m_dwReserved1;
	volatile WORD			m_wTxPdo0BufSize;
	volatile WORD			m_wTxPdo0BufAoffs;
	volatile WORD			m_wRxPdo0BufSize;
	volatile WORD			m_wRxPdo0BufAoffs;
	volatile WORD			m_wRxPdo1BufSize;
	volatile WORD			m_wRxPdo1BufAoffs;
	volatile WORD			m_wRxPdo2BufSize;
	volatile WORD			m_wRxPdo2BufAoffs;
	volatile WORD			m_wTxPdoDescSize;  //deprecated
	volatile WORD			m_wTxPdoDescAdrs;  //deprecated
	volatile WORD			m_wRxPdoDescSize;  //deprecated
	volatile WORD			m_wRxPdoDescAdrs;  //deprecated
	volatile WORD			m_wTxAsyncBufSize;
	volatile WORD			m_wTxAsyncBufAoffs;
	volatile WORD			m_wRxAsyncBufSize;
	volatile WORD			m_wRxAsyncBufAoffs;
	volatile BYTE			m_bRxPdo0Ack;  ///< address acknowledge register of RPDO buffer nr. 0
	volatile BYTE			m_bRxPdo1Ack;  ///< address acknowledge register of RPDO buffer nr. 1
	volatile BYTE			m_bRxPdo2Ack;  ///< address acknowledge register of RPDO buffer nr. 2
	volatile BYTE			m_bTxPdo0Ack;  ///< address acknowledge register of TPDO buffer nr. 0
	volatile DWORD			m_dwPcpIrqTimerValue; ///< synchronization IRQ timer value, accessible only by PCP
	volatile BYTE			m_bSyncIrqControl;	  ///< synchronization IRQ control register, contains snyc. IR acknowledge (at AP side)
}__attribute__((__packed__));

typedef struct sPcpControlReg tPcpCtrlReg;

typedef struct sTPdoBuffer { ///< used to group buffer structure infos from control register
    BYTE    *pAdrs_m;
    WORD    wSize_m;
    BYTE    *pAck_m;
#ifdef CN_API_USING_SPI
    DWORD   dwSpiBufOffs_m;
    WORD    wSpiAckOffs_m;
#endif /* CN_API_USING_SPI */
} tTPdoBuffer;

typedef struct
sRPdoBuffer { ///< used to group buffer structure infos from control register
    BYTE    *pAdrs_m;
    WORD    wSize_m;
    BYTE    *pAck_m;
    DWORD   dwSpiBufOffs_m;
    WORD    wSpiAckOffs_m;
} tRPdoBuffer;

/******************************************************************************/
/* global variables */
extern tCnApiInitParm		*pInitParm_g;		// pointer to POWERLINK init parameters
extern tPcpCtrlReg			*pCtrlReg_g;		// pointer to PCP control registers

// asynchronous messages
extern tLinkPdosReq *pAsycMsgLinkPdoReqAp_g;

/******************************************************************************/
/* function declarations */
extern tCnApiStatus CnApi_init(BYTE *pDpram_p, tCnApiInitParm *pInitParm_p);
extern void CnApi_exit(void);
extern void CnApi_activateApStateMachine(void);
extern BOOL CnApi_processApStateMachine(void);
extern void CnApi_initSyncInt(WORD wMinCycleTime_p, WORD wMaxCycleTime_p, BYTE bMaxCycleNum);
extern void CnApi_enableSyncInt(void);
extern void CnApi_disableSyncInt(void);
extern int CnApi_initObjects(DWORD dwMaxLinks_p);
extern int CnApi_linkObject(WORD wIndex_p, BYTE bSubIndex_p, WORD wSize_p, char *pAdrs_p);
void CnApi_handleLinkPdosReq(tLinkPdosReq *pLinkPdosReq_p);
extern void CnApi_cleanupObjects(void);
extern void CnApi_transferPdo(void);

extern int CnApi_CbSpiMasterTx(unsigned char *pTxBuf_p, int iBytes_p); //SPI Master Tx Handler
extern int CnApi_CbSpiMasterRx(unsigned char *pRxBuf_p, int iBytes_p); //SPI MASTER Rx Handler

#endif /* CNAPI_H_ */
