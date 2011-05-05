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

/* asynchronous communication AP <-> PCP */
/* ObjLinking via asyncr. channel */
#define OBJ_CREATE_LINKS_REQ_MAX_ENTRIES   100 ///< Max entries for CreatObjLinks command - has to fit in message buffer!
#define OBJ_CREATE_LINKS_REQ_MAX_SEQ       9   ///< Max sequence nr. for CreatObjLinks command
#define FST_OBJ_CRT_INDICATOR              2   ///< Asychr. msg counter indicating AP reset and start of CreatObjLinksReq

// object restrictions
#define MAX_LINKABLE_OBJCS (OBJ_CREATE_LINKS_REQ_MAX_ENTRIES * (OBJ_CREATE_LINKS_REQ_MAX_SEQ +1))
#define MAX_MAPPABLE_OBJECTS               250

#ifndef POWERLINK_0_PDI_PCP_PDITPDOS
#error "cnApiCfg.h has not been generated correctly!"
#endif /* ndef POWERLINK_0_PDI_PCP_PDITPDOS */

#define	PCP_MAGIC					0x50435000		///< magic number identifies valid PCP memory
#define SYNC_IRQ_ACK                0               ///< Sync IRQ Bit shift (for AP only)

/* Control Register Offsets, used for SPI */
#ifdef CN_API_USING_SPI
#error: SPI is not yet updated to new version! //TODO: UPDATE!
 #define PCP_CTRLREG_START_ADR               0x00
 #define PCP_CTRLREG_MAGIC_OFFSET            offsetof(tPcpCtrlReg, m_dwMagic)        //0x00
 #define PCP_CTRLREG_SYNMD_OFFSET            offsetof(tPcpCtrlReg, m_bSyncMode)      //0x04
 #define PCP_CTRLREG_ERROR_OFFSET            offsetof(tPcpCtrlReg, m_bError)         //0x05
 #define PCP_CTRLREG_CMD_OFFSET              offsetof(tPcpCtrlReg, m_wCommand)       //0x06
 #define PCP_CTRLREG_STATE_OFFSET            offsetof(tPcpCtrlReg, m_wState)         //0x07
 #define PCP_CTRLREG_MAXCYCT_OFFSET          offsetof(tPcpCtrlReg, m_dwMaxCycleTime) //0x08
 #define PCP_CTRLREG_MINCYCT_OFFSET          offsetof(tPcpCtrlReg, m_dwMinCycleTime) //0x0A
 #define PCP_CTRLREG_CYCCRCT_OFFSET          offsetof(tPcpCtrlReg, m_wCycleCorrect)  //0x0C
 #define PCP_CTRLREG_CYCERR_OFFSET           offsetof(tPcpCtrlReg, m_bCycleError)    //0x0E
 #define PCP_CTRLREG_MAXCYCNUM_OFFSET        offsetof(tPcpCtrlReg, m_wMaxCycleNum)   //0x0F
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
typedef enum eCnApiStatus{
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

//TODO: delete next struct and do error handling in a different way
/**
 * Valid status values of the PCP error register
 *
 * tCnApiCycleStatus contains the valid status codes of the PCP error register
 */
typedef enum {
	kCnApiSyncCycleOk = 0,				///< sync interrupt cycle ok
	kCnApiSyncCycleError				///< sync interrupt cycle error
} PACK_STRUCT tCnApiCycleStatus;

/**
 * \brief enumeration with valid AP commands
 */
typedef enum eApCmd{
	kApCmdNone = -1,
	kApCmdInit = 0,
	kApCmdPreop = 1,
	kApCmdReadyToOperate = 2,
	kApCmdReset = 3
} tApCmd;


typedef struct sCnApiObjId {
	WORD		m_wIndex;
	BYTE		m_bSubIndex;
	BYTE		m_bNumEntries;
} PACK_STRUCT tCnApiObjId;

typedef struct sCnApiObjCreateObjLinksHdl {
    WORD                wNumCreateObjs_m; ///< number of objects to be created
    WORD                wCurObjs_m; ///< current number of objects to be created
    WORD                wReqObjs_m; ///< already created (=linked) objects
    tCnApiObjId *       pObj_m;     ///< pointer to current object entry
} PACK_STRUCT tCnApiObjCreateObjLinksHdl;


// TODO: not used, do we need it?
typedef struct sCnApiReadQueue{
	int					m_iNumElements;
	tCnApiObjId 		*pObjectId;
} PACK_STRUCT tCnApiReadQueue;

//TODO: needed?
typedef enum eProcType {
	kProcTypeAp,
	kProcTypePcp
} tProcType;


/******************************************************************************/
typedef enum ePcpPdiLedType {
//    kEplLedTypeStatus   = 0x00, //already defined in openPOWERLINK stack
//    kEplLedTypeError    = 0x01, //already defined in openPOWERLINK stack
    kEplLedTypeTestAll  = 0x02,
} tPcpPdiLedType;

/******************************************************************************/
/* definitions for PDO transfer functions */

typedef struct sObjTbl {
	WORD			m_wIndex;
	BYTE			m_bSubIndex;
	WORD			m_wSize;
	char			*m_pData;
} PACK_STRUCT tObjTbl;

typedef enum ePdoDir {
   TPdo = 0x01, ///< Transmit PDO
   RPdo = 0x80  ///< Receive PDO
} tPdoDir;

typedef struct sPdoDescHeader {
	WORD	   m_bEntryCnt;
	BYTE       m_bPdoDir;
	BYTE       m_bBufferNum;
} PACK_STRUCT tPdoDescHeader;

typedef struct sPdoDesc {
	WORD	m_wPdoIndex;
	BYTE	m_bPdoSubIndex;
	BYTE	m_bReserved;    // NumObjChain not used
} PACK_STRUCT tPdoDescEntry;

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
} PACK_STRUCT tCnApiInitParm;

/* definitions for AP state machine, transitions and states */
typedef enum eApStates{
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
typedef enum ePcpStates { //TODO: define state "none?" - adapt docu for correct values!
	kPcpStateBooted = 0x00,
	kPcpStateInit = 0x01,
	kPcpStatePreop1 = 0x02,
	kPcpStatePreop2 = 0x03,
	kPcpStateReadyToOperate = 0x04,
	kPcpStateOperational = 0x05,
	kNumPcpStates = 0x06,
	kPcpStateInvalid = 0x07,
} tPcpStates;

/******************************************************************************/

/**
* \brief PCP control registers
*
* tPcpCtrlReg defines the PCP control registers.
*/
struct sPcpControlReg {
	volatile DWORD			m_dwMagic;             ///< magic number indicating correct PCP PDI memory start address
	volatile WORD           m_wPcpPdiRev;          ///< Revision of PCP PDI (control and status register)
	volatile WORD           wReserved1;
    volatile WORD           wReserved2;
    volatile WORD           wReserved3;
	volatile WORD			m_wCommand;            ///< AP issues commands to this register
	volatile WORD			m_wState;              ///< state of the PCP
	volatile DWORD			m_dwMaxCycleTime;      ///< upper limit of synchronous-IR cycle time the AP wants to process
	volatile DWORD			m_dwMinCycleTime;      ///< lower limit of synchronous-IR cycle time the AP can process
	volatile WORD			m_wCycleCorrect;       ///< correction factor
	volatile WORD			m_wMaxCycleNum;        ///< multiple of Powerlink cyle time for synchronous-IR
    volatile DWORD          m_dwSyncIntCycTime;    ///< cycle time of synchronous-IR issued to the AP for PDO processing
    volatile WORD           m_wEventType;          ///< type of event (e.g. state change, error, ...)
    volatile WORD           m_wEventArg;           ///< event argument, if applicable (e.g. error code, state, ...)
    volatile WORD           m_wAsyncIrqControl;    ///< asynchronous IRQ control register, contains IR acknowledge (at AP side)
    volatile WORD           m_wEventAck;           ///< acknowledge for events and asynchronous IR signal
	volatile WORD			m_wTxPdo0BufSize;      ///< buffer size for TPDO communication AP -> PCP
	volatile WORD			m_wTxPdo0BufAoffs;     ///< buffer address for TPDO communication AP -> PCP
	volatile WORD			m_wRxPdo0BufSize;      ///< buffer size for RPDO communication PCP -> AP
	volatile WORD			m_wRxPdo0BufAoffs;     ///< buffer address for RPDO communication PCP -> AP
	volatile WORD			m_wRxPdo1BufSize;      ///< buffer size for RPDO communication PCP -> AP
	volatile WORD			m_wRxPdo1BufAoffs;     ///< buffer address for RPDO communication PCP -> AP
	volatile WORD			m_wRxPdo2BufSize;      ///< buffer size for RPDO communication PCP -> AP
    volatile WORD           m_wRxPdo2BufAoffs;	   ///< buffer address for RPDO communication PCP -> AP
    volatile WORD           m_wTxAsyncBuf0Size;    ///< buffer size for asynchronous communication AP -> PCP
    volatile WORD           m_wTxAsyncBuf0Aoffs;   ///< buffer address for asynchronous communication AP -> PCP
    volatile WORD           m_wRxAsyncBuf0Size;    ///< buffer size for asynchronous communication PCP -> AP
    volatile WORD           m_wRxAsyncBuf0Aoffs;   ///< buffer address for asynchronous communication PCP -> AP
    volatile WORD           m_wTxAsyncBuf1Size;    ///< buffer size for asynchronous communication AP -> PCP
    volatile WORD           m_wTxAsyncBuf1Aoffs;   ///< buffer address for asynchronous communication AP -> PCP
    volatile WORD           m_wRxAsyncBuf1Size;    ///< buffer size for asynchronous communication PCP -> AP
    volatile WORD           m_wRxAsyncBuf1Aoffs;   ///< buffer address for asynchronous communication PCP -> AP
    volatile WORD           wReserved4;
    volatile WORD           wReserved5;
    volatile WORD           wReserved6;
    volatile WORD           wReserved7;
    volatile WORD           m_wTxPdo0Ack;          ///< address acknowledge register of TPDO buffer nr. 0
	volatile WORD			m_wRxPdo0Ack;          ///< address acknowledge register of RPDO buffer nr. 0
	volatile WORD			m_wRxPdo1Ack;          ///< address acknowledge register of RPDO buffer nr. 1
	volatile WORD			m_wRxPdo2Ack;          ///< address acknowledge register of RPDO buffer nr. 2
	volatile WORD			m_wSyncIrqControl;	   ///< PDO synchronization IRQ control register, contains snyc. IR acknowledge (at AP side)
    volatile WORD           wReserved8;
    volatile DWORD          dwRerserved9;
    volatile DWORD          dwRerserved10;
    volatile WORD           m_wLedControl;         ///< Powerlink IP-core Led output control register
    volatile WORD           m_wLedConfig;          ///< Powerlink IP-core Led output configuration register
} PACK_STRUCT;

typedef struct sPcpControlReg tPcpCtrlReg;

typedef struct sTPdoBuffer { ///< used to group buffer structure infos from control register
    BYTE    *pAdrs_m;
    WORD    wSize_m;
    BYTE    *pAck_m;
#ifdef CN_API_USING_SPI
    DWORD   dwSpiBufOffs_m;
    WORD    wSpiAckOffs_m;
#endif /* CN_API_USING_SPI */
} PACK_STRUCT tTPdoBuffer;

typedef struct sRPdoBuffer { ///< used to group buffer structure infos from control register
    BYTE    *pAdrs_m;
    WORD    wSize_m;
    BYTE    *pAck_m;
    DWORD   dwSpiBufOffs_m;
    WORD    wSpiAckOffs_m;
} PACK_STRUCT tRPdoBuffer;

/******************************************************************************/
/* global variables */
extern tCnApiInitParm *     pInitParm_g;    // pointer to POWERLINK init parameters
extern tPcpCtrlReg *        pCtrlReg_g;		// pointer to PCP control registers

/******************************************************************************/
/* function declarations */
extern tCnApiStatus CnApi_init(BYTE *pDpram_p, tCnApiInitParm *pInitParm_p);
extern void CnApi_exit(void);
extern void CnApi_activateApStateMachine(void);
extern BOOL CnApi_processApStateMachine(void);
extern void CnApi_enterApStateReadyToOperate();
extern void CnApi_initSyncInt(DWORD dwMinCycleTime_p, DWORD dwMaxCycleTime_p, BYTE bMaxCycleNum);
extern void CnApi_enableSyncInt(void);
extern void CnApi_disableSyncInt(void);
extern void CnApi_ackSyncIrq(void);
extern int CnApi_initObjects(DWORD dwMaxLinks_p);
extern int CnApi_linkObject(WORD wIndex_p, BYTE bSubIndex_p, WORD wSize_p, char *pAdrs_p);
extern void CnApi_cleanupObjects(void);
extern void CnApi_transferPdo(void);

/* functions for interrupt synchronization */
extern DWORD CnApi_getSyncIntPeriod(void);

extern int CnApi_CbSpiMasterTx(unsigned char *pTxBuf_p, int iBytes_p); //SPI Master Tx Handler
extern int CnApi_CbSpiMasterRx(unsigned char *pRxBuf_p, int iBytes_p); //SPI MASTER Rx Handler

#endif /* CNAPI_H_ */
