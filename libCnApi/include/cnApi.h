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
#include "cnApiCfg.h"
#ifndef MAKE_BUILD_PCP
#   include "cnApiGlobal.h"     // global definitions
#   include "EplErrDef.h"
#   include "EplObd.h"
#endif

#ifdef CN_API_USING_SPI
#include "cnApiPdiSpi.h"
#endif



/******************************************************************************/
/* defines */

/* CN API definitions */

// object restrictions
#define MAX_MAPPABLE_OBJECTS               250

#ifndef PCP_PDI_TPDO_CHANNELS
#error "cnApiCfg.h has not been generated correctly!"
#endif /* PCP_PDI_TPDO_CHANNELS */

/* Convert endian define to enable usage while runtime */
#ifdef AP_IS_BIG_ENDIAN
#define CNAPI_BIG_ENDIAN TRUE
#else
#define CNAPI_BIG_ENDIAN FALSE
#endif

#define	PCP_MAGIC					0x50435000		///< magic number identifies valid PCP memory
#define SYNC_IRQ_ACK                0               ///< Sync IRQ Bit shift (for AP only)

/* Control Register Offsets, used for serial interface */
#ifdef CN_API_USING_SPI
#define PCP_CTRLREG_START_ADR                   0x00
#define PCP_CTRLREG_MAGIC_OFFSET                offsetof(tPcpCtrlReg, m_dwMagic)            //0x00
#define PCP_CTRLREG_PDI_REV_OFFSET              offsetof(tPcpCtrlReg, m_wPcpPdiRev)         //0x04
// reserved                                                                                 //0x06
#define PCP_CTRLREG_FPGA_SYSID_OFFSET           offsetof(tPcpCtrlReg, m_dwFpgaSysId)        //0x08
#define PCP_CTRLREG_APP_DATE_OFFSET             offsetof(tPcpCtrlReg, m_dwAppDate)          //0x0C
#define PCP_CTRLREG_APP_TIME_OFFSET             offsetof(tPcpCtrlReg, m_dwAppTime)          //0x10
#define PCP_CTRLREG_NODE_ID_OFFSET              offsetof(tPcpCtrlReg, m_wNodeId)            //0x14
// reserved                                                                                 //0x16
#define PCP_CTRLREG_CMD_OFFSET                  offsetof(tPcpCtrlReg, m_wCommand)           //0x18
#define PCP_CTRLREG_STATE_OFFSET                offsetof(tPcpCtrlReg, m_wState)             //0x1A
#define PCP_CTRLREG_MAXCYCT_OFFSET              offsetof(tPcpCtrlReg, m_dwMaxCycleTime)     //0x1C
#define PCP_CTRLREG_MINCYCT_OFFSET              offsetof(tPcpCtrlReg, m_dwMinCycleTime)     //0x20
#define PCP_CTRLREG_CYCCAL_RESERVED_OFFSET      offsetof(tPcpCtrlReg, wCycleCalc_Reserved4) //0x26
#define PCP_CTRLREG_SYNCIR_CYCTIME_OFFSET       offsetof(tPcpCtrlReg, m_dwSyncIntCycTime)   //0x28
// reserved                                                                                 //0x2C
#define PCP_CTRLREG_EVENT_TYPE_OFFSET           offsetof(tPcpCtrlReg, m_wEventType)         //0x30
#define PCP_CTRLREG_EVENT_ARG_OFFSET            offsetof(tPcpCtrlReg, m_wEventArg)          //0x32
// reserved
// reserved
// reserved
#define PCP_CTRLREG_RELATIVE_TIME_LOW_OFFSET    offsetof(tPcpCtrlReg, m_dwRelativeTimeLow)  //0x40
#define PCP_CTRLREG_RELATIVE_TIME_HIGH_OFFSET   offsetof(tPcpCtrlReg, m_dwRelativeTimeHigh) //0x44
#define PCP_CTRLREG_NETTIME_NANOSEC_OFFSET      offsetof(tPcpCtrlReg, m_dwNetTimeNanoSec)   //0x48
#define PCP_CTRLREG_NETTIME_SEC_OFFSET          offsetof(tPcpCtrlReg, m_dwNetTimeSec)       //0x4C
#define PCP_CTRLREG_TIME_AFTER_SYNC_OFFSET      offsetof(tPcpCtrlReg, m_wTimeAfterSync)     //0x50
// reserved
#define PCP_CTRLREG_ASYNC_IRQ_CTRL_OFFSET       offsetof(tPcpCtrlReg, m_wAsyncIrqControl)   //0x52
#define PCP_CTRLREG_EVENT_ACK_OFFSET            offsetof(tPcpCtrlReg, m_wEventAck)          //0x54
#define PCP_CTRLREG_TPDO0_BUFSIZE_OFFSET        offsetof(tPcpCtrlReg, m_wTxPdo0BufSize)     //0x56
#define PCP_CTRLREG_TPDO0_OFST_OFFSET           offsetof(pCtrlReg_g->m_wTxPdo0BufAoffs)     //0x58
#define PCP_CTRLREG_RPDO0_BUFSIZE_OFFSET        offsetof(tPcpCtrlReg, m_wRxPdo0BufSize)     //0x5A
#define PCP_CTRLREG_RPDO0_OFST_OFFSET           offsetof(pCtrlReg_g->m_wRxPdo0BufAoffs)     //0x5C
#define PCP_CTRLREG_RPDO1_BUFSIZE_OFFSET        offsetof(tPcpCtrlReg, m_wRxPdo1BufSize)     //0x5E
#define PCP_CTRLREG_RPDO1_OFST_OFFSET           offsetof(pCtrlReg_g->m_wRxPdo1BufAoffs)     //0x60
#define PCP_CTRLREG_RPDO2_BUFSIZE_OFFSET        offsetof(tPcpCtrlReg, m_wRxPdo2BufSize)     //0x62
#define PCP_CTRLREG_RPDO2_OFST_OFFSET           offsetof(pCtrlReg_g->m_wRxPdo2BufAoffs)     //0x64
#define PCP_CTRLREG_TX_ASYNC_BUF0_SIZE_OFFSET   offsetof(tPcpCtrlReg, m_wTxAsyncBuf0Size)   //0x66
#define PCP_CTRLREG_TX_ASYNC_BUF0_OFST_OFFSET   offsetof(pCtrlReg_g->m_wTxAsyncBuf0Aoffs)   //0x68
#define PCP_CTRLREG_RX_ASYNC_BUF0_SIZE_OFFSET   offsetof(tPcpCtrlReg, m_wRxAsyncBuf0Size)   //0x6A
#define PCP_CTRLREG_RX_ASYNC_BUF0_OFST_OFFSET   offsetof(pCtrlReg_g->m_wRxAsyncBuf0Aoffs)   //0x6C
#define PCP_CTRLREG_TX_ASYNC_BUF1_SIZE_OFFSET   offsetof(tPcpCtrlReg, m_wTxAsyncBuf1Size)   //0x6E
#define PCP_CTRLREG_TX_ASYNC_BUF1_OFST_OFFSET   offsetof(pCtrlReg_g->m_wTxAsyncBuf1Aoffs)   //0x70
#define PCP_CTRLREG_RX_ASYNC_BUF1_SIZE_OFFSET   offsetof(tPcpCtrlReg, m_wRxAsyncBuf1Size)   //0x72
#define PCP_CTRLREG_RX_ASYNC_BUF1_OFST_OFFSET   offsetof(pCtrlReg_g->m_wRxAsyncBuf1Aoffs)   //0x74
// reserved                                                                                 //0x76
// reserved                                                                                 //0x78
// reserved                                                                                 //0x7A
// reserved                                                                                 //0x7C
#define PCP_CTRLREG_TPDO_0_ACK_OFFSET           offsetof(tPcpCtrlReg, m_wTxPdo0Ack)         //0x7E
#define PCP_CTRLREG_RPDO_0_ACK_OFFSET           offsetof(tPcpCtrlReg, m_wRxPdo0Ack)         //0x80
#define PCP_CTRLREG_RPDO_1_ACK_OFFSET           offsetof(tPcpCtrlReg, m_wRxPdo1Ack)         //0x82
#define PCP_CTRLREG_RPDO_2_ACK_OFFSET           offsetof(tPcpCtrlReg, m_wRxPdo2Ack)         //0x84
#define PCP_CTRLREG_SYNCIRQCTRL_OFFSET          offsetof(tPcpCtrlReg, m_wSyncIrqControl)    //0x86
// reserved                                                                                 //0x88
// reserved                                                                                 //0x8A
// reserved                                                                                 //0x8C
// reserved                                                                                 //0x8E
// reserved                                                                                 //0x90
#define PCP_CTRLREG_LED_CTRL_OFFSET             offsetof(tPcpCtrlReg, m_wLedControl)        //0x92
#define PCP_CTRLREG_LED_CNFG_OFFSET             offsetof(tPcpCtrlReg, m_wLedConfig)         //0x94
#define PCP_CTRLREG_SPAN                        sizeof(tPcpCtrlReg)

// other offset defines used only by serial interface
#define PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET    offsetof(tAsyncMsg, m_header)
#define PCP_PDI_SERIAL_ASYNCMSGPAYLOAD_OFFSET   offsetof(tAsyncMsg, m_chan)
#define PCP_PDI_SERIAL_ASYNC_SYNC_OFFSET  PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET + offsetof(tAsyncPdiBufCtrlHeader, m_bSync)
#define PCP_PDI_SERIAL_ASYNC_CHAN_OFFSET  PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET + offsetof(tAsyncPdiBufCtrlHeader, m_bChannel)
#define PCP_PDI_SERIAL_ASYNC_MSGT_OFFSET  PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET + offsetof(tAsyncPdiBufCtrlHeader, m_bMsgType)
#define PCP_PDI_SERIAL_ASYNC_FRMT_OFFSET  PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET + offsetof(tAsyncPdiBufCtrlHeader, m_wFrgmtLen)
#define PCP_PDI_SERIAL_ASYNC_STRM_OFFSET  PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET + offsetof(tAsyncPdiBufCtrlHeader, m_dwStreamLen)
#endif /* CN_API_USING_SPI */

/* Timer definitions */
#define PCP_PRESENCE_TIMEOUT 5

/* CN Api initialization */
#define CN_API_INIT_PARAM_STRNG_SIZE 33
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
} tCnApiCycleStatus;

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
} tCnApiObjCreateObjLinksHdl;


// TODO: not used, do we need it?
typedef struct sCnApiReadQueue{
	int					m_iNumElements;
	tCnApiObjId 		*pObjectId;
} tCnApiReadQueue;

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
	WORD		m_wIndex;
	BYTE		m_bSubIndex;
	BYTE        m_bPad;
	WORD		m_wSize;
	BYTE		*m_pData;
} tObjTbl;

typedef enum ePdoDir {
   TPdo = 0x01, ///< Transmit PDO
   RPdo = 0x80  ///< Receive PDO
} tPdoDir;

typedef struct sPdoDescHeader {
    BYTE       m_bEntryCnt;
	BYTE       m_bPdoDir;
	BYTE       m_bBufferNum;
	BYTE       m_bMapVersion;      ///< MappingVersion_U8 of PDO channel
} PACK_STRUCT tPdoDescHeader;

typedef struct sPdoDesc {
	WORD	m_wPdoIndex;
	BYTE	m_bPdoSubIndex;
	BYTE    m_bPad;
	WORD    m_wOffset;
	WORD    m_wSize;
} PACK_STRUCT tPdoDescEntry;

#define EPL_PDOU_OBD_IDX_RX_COMM_PARAM  0x1400
#define EPL_PDOU_OBD_IDX_RX_MAPP_PARAM  0x1600
#define EPL_PDOU_OBD_IDX_TX_COMM_PARAM  0x1800
#define EPL_PDOU_OBD_IDX_TX_MAPP_PARAM  0x1A00
#define EPL_PDOU_OBD_IDX_MAPP_PARAM     0x0200
#define EPL_PDOU_OBD_IDX_MASK           0xFF00
#define EPL_PDOU_PDO_ID_MASK            0x00FF

typedef	void (*tpfnPdoDescCb) (BYTE *pPdoDesc_p, BYTE bDescrEntries_p); ///< type definition for PDO descriptor callback function
typedef	void (*tpfnPdoCopyCb) (BYTE *pPdoData_p); 						///< type definition for PDO copy callback function

typedef int (*tpfnSpiMasterTxCb) (unsigned char *pTxBuf_p, int iBytes_p);
typedef int (*tpfnSpiMasterRxCb) (unsigned char *pTxBuf_p, int iBytes_p);

/******************************************************************************/

/**
 * \brief structure for POWERLINK initialization parameters
 */
typedef struct sCnApiInitParm {
	BYTE			m_abMac[6];
    BYTE            m_bPad;
	BYTE			m_bNodeId;
	DWORD			m_dwRevision;
	DWORD			m_dwSerialNum;
	DWORD			m_dwVendorId;
	DWORD			m_dwProductCode;
	DWORD			m_dwDeviceType;
	BYTE            m_strDevName[CN_API_INIT_PARAM_STRNG_SIZE];
	BYTE            m_strHwVersion[CN_API_INIT_PARAM_STRNG_SIZE];
	BYTE            m_strSwVersion[CN_API_INIT_PARAM_STRNG_SIZE];
} tCnApiInitParm;

/* definitions for AP state machine, transitions and states */
typedef enum eApStates{
	kApStateBooted = 0,
	kApStateReadyToInit,
	kApStateInit,
	kApStatePreOp,
	kApStateReadyToOperate,
	kApStateOperational,
	kApStateError,
	kNumApState
} tApStates;

/* definitions for PCP state machine, transitions and states */
typedef enum ePcpStates { //TODO: define state "none?" - adapt docu for correct values!
	kPcpStateBooted = 0x00,
	kPcpStateInit = 0x01,
	kPcpStatePreOp = 0x02,
	kPcpStateReadyToOperate = 0x03,
	kPcpStateOperational = 0x04,
	kNumPcpStates = 0x05,
	kPcpStateInvalid = 0xEE,
} tPcpStates;

/******************************************************************************/

/**
* \brief PCP control registers
*
* tPcpCtrlReg defines the PCP control registers.
*/
struct sPcpControlReg {
    volatile DWORD      m_dwMagic;             ///< magic number indicating correct PCP PDI memory start address
    volatile WORD       m_wPcpPdiRev;          ///< revision of PCP PDI (control and status register)
    volatile WORD       wReserved1;            ///< not available (fixed)
    volatile DWORD      m_dwFpgaSysId;         ///< system ID of FPGA (SOPC)design, value is user defined
    volatile DWORD      m_dwAppDate;           ///< (Powerlink application date
    volatile DWORD      m_dwAppTime;           ///< Powerlink application time
    volatile WORD       m_wNodeId;             ///< Powerlink node ID; can by read by AP at related event
    volatile WORD       wReserved2;
    volatile WORD       m_wCommand;            ///< AP issues commands to this register
    volatile WORD       m_wState;              ///< state of the PCP
    volatile DWORD      m_dwMaxCycleTime;      ///< upper limit of synchronous-IR cycle time the AP wants to process
    volatile DWORD      m_dwMinCycleTime;      ///< lower limit of synchronous-IR cycle time the AP can process
    volatile WORD       wReserved3;            ///< correction factor(-- currently not used --)
    volatile WORD       wCycleCalc_Reserved4;  ///< multiple of Powerlink cyle time for synchronous-IR
    volatile DWORD      m_dwSyncIntCycTime;    ///< cycle time of synchronous-IR issued to the AP for PDO processing
    volatile DWORD      dwReserved5;
    volatile WORD       m_wEventType;          ///< type of event (e.g. state change, error, ...)
    volatile WORD       m_wEventArg;           ///< event argument, if applicable (e.g. error code, state, ...)
    volatile DWORD      dwReserved6;
    volatile DWORD      dwReserved7;
    volatile DWORD      dwReserved8;
    volatile DWORD      m_dwRelativeTimeLow;   ///< low dword of SoC relative time
    volatile DWORD      m_dwRelativeTimeHigh;  ///< high dword of SoC relative time
    volatile DWORD      m_dwNetTimeNanoSec;    ///< low dword of SoC nettime
    volatile DWORD      m_dwNetTimeSec;        ///< high dword of SoC nettime
    volatile WORD       m_wTimeAfterSync;      ///< time elapsed after the last synchronisation interrupt
    volatile WORD       wReserved9;
    volatile WORD       m_wAsyncIrqControl;    ///< asynchronous IRQ control register, contains IR acknowledge (at AP side)
    volatile WORD       m_wEventAck;           ///< acknowledge for events and asynchronous IR signal
    volatile WORD       m_wTxPdo0BufSize;      ///< buffer size for TPDO communication AP -> PCP
    volatile WORD       m_wTxPdo0BufAoffs;     ///< buffer address for TPDO communication AP -> PCP
    volatile WORD       m_wRxPdo0BufSize;      ///< buffer size for RPDO communication PCP -> AP
    volatile WORD       m_wRxPdo0BufAoffs;     ///< buffer address for RPDO communication PCP -> AP
    volatile WORD       m_wRxPdo1BufSize;      ///< buffer size for RPDO communication PCP -> AP
    volatile WORD       m_wRxPdo1BufAoffs;     ///< buffer address for RPDO communication PCP -> AP
    volatile WORD       m_wRxPdo2BufSize;      ///< buffer size for RPDO communication PCP -> AP
    volatile WORD       m_wRxPdo2BufAoffs;     ///< buffer address for RPDO communication PCP -> AP
    volatile WORD       m_wTxAsyncBuf0Size;    ///< buffer size for asynchronous communication AP -> PCP
    volatile WORD       m_wTxAsyncBuf0Aoffs;   ///< buffer address for asynchronous communication AP -> PCP
    volatile WORD       m_wRxAsyncBuf0Size;    ///< buffer size for asynchronous communication PCP -> AP
    volatile WORD       m_wRxAsyncBuf0Aoffs;   ///< buffer address for asynchronous communication PCP -> AP
    volatile WORD       m_wTxAsyncBuf1Size;    ///< buffer size for asynchronous communication AP -> PCP
    volatile WORD       m_wTxAsyncBuf1Aoffs;   ///< buffer address for asynchronous communication AP -> PCP
    volatile WORD       m_wRxAsyncBuf1Size;    ///< buffer size for asynchronous communication PCP -> AP
    volatile WORD       m_wRxAsyncBuf1Aoffs;   ///< buffer address for asynchronous communication PCP -> AP
    volatile WORD       wReserved10;
    volatile WORD       wReserved11;
    volatile WORD       wReserved12;
    volatile WORD       wReserved13;
    volatile WORD       m_wTxPdo0Ack;          ///< address acknowledge register of TPDO buffer nr. 0
    volatile WORD       m_wRxPdo0Ack;          ///< address acknowledge register of RPDO buffer nr. 0
    volatile WORD       m_wRxPdo1Ack;          ///< address acknowledge register of RPDO buffer nr. 1
    volatile WORD       m_wRxPdo2Ack;          ///< address acknowledge register of RPDO buffer nr. 2
    volatile WORD       m_wSyncIrqControl;     ///< PDO synchronization IRQ control register, contains snyc. IR acknowledge (at AP side)
    volatile WORD       wReserved14;
    volatile DWORD      dwReserved15;
    volatile DWORD      dwReserved16;
    volatile WORD       m_wLedControl;         ///< Powerlink IP-core Led output control register
    volatile WORD       m_wLedConfig;          ///< Powerlink IP-core Led output configuration register
} PACK_STRUCT;

typedef struct sPcpControlReg tPcpCtrlReg;

typedef struct sTPdoBuffer { ///< used to group buffer structure infos from control register
    BYTE    *pAdrs_m;
    WORD    wSize_m;
    BYTE    *pAck_m;
    WORD    wMappedBytes_m;  ///< only used at PCP
#ifdef CN_API_USING_SPI
    DWORD   dwSpiBufOffs_m;
    WORD    wSpiAckOffs_m;
#endif /* CN_API_USING_SPI */
} tTPdoBuffer;

typedef struct sRPdoBuffer { ///< used to group buffer structure infos from control register
    BYTE    *pAdrs_m;
    WORD    wSize_m;
    BYTE    *pAck_m;
    WORD    wMappedBytes_m;  ///< only used at PCP
#ifdef CN_API_USING_SPI
    DWORD   dwSpiBufOffs_m;
    WORD    wSpiAckOffs_m;
#endif /* CN_API_USING_SPI */
} tRPdoBuffer;

/******************************************************************************/
/* global variables */
extern volatile tPcpCtrlReg *       pCtrlReg_g;            ///< pointer to PCP control registers, Little Endian
extern tCnApiInitParm *             pInitParm_g;           ///< pointer to POWERLINK init parameters
extern BYTE *                       pDpramBase_g;          ///< pointer to Dpram base address

/******************************************************************************/
/* function declarations */
#ifdef CN_API_USING_SPI
extern tCnApiStatus CnApi_init(BYTE *pDpram_p, tCnApiInitParm *pInitParm_p,
        tSpiMasterTxHandler     SpiMasterTxH_p,
        tSpiMasterRxHandler     SpiMasterRxH_p,
        void                    *pfnEnableGlobalIntH_p,
        void                    *pfnDisableGlobalIntH_p);
#else
extern tCnApiStatus CnApi_init(BYTE *pDpram_p, tCnApiInitParm *pInitParm_p);
#endif //CN_API_USING_SPI

extern void CnApi_exit(void);
extern void CnApi_activateApStateMachine(void);
extern void CnApi_resetApStateMachine(void);
extern BOOL CnApi_processApStateMachine(void);
extern void CnApi_enterApStateReadyToOperate();
extern int CnApi_initObjects(DWORD dwMaxLinks_p);
extern int CnApi_linkObject(WORD wIndex_p, BYTE bSubIndex_p, WORD wSize_p, BYTE * pAdrs_p);
extern void CnApi_cleanupObjects(void);
extern WORD CnApi_getNodeId(void);
#ifndef MAKE_BUILD_PCP
extern tEplKernel CnApi_CbDefaultObdAccess(tEplObdParam * pObdParam_p);
extern tEplKernel CnApi_DefObdAccFinished(tEplObdParam ** pObdParam_p);
#endif

/* time functions */
extern DWORD CnApi_getRelativeTimeLow(void);
extern DWORD CnApi_getRelativeTimeHigh(void);
extern DWORD CnApi_getNetTimeSeconds(void);
extern DWORD CnApi_getNetTimeNanoSeconds(void);
extern WORD CnApi_getTimeAfterSync(void);

/* functions for interrupt synchronization */
extern void CnApi_initSyncInt(DWORD dwMinCycleTime_p, DWORD dwMaxCycleTime_p, BYTE bReserved);
extern void CnApi_enableSyncInt(void);
extern void CnApi_disableSyncInt(void);
extern void CnApi_ackSyncIrq(void);
extern void CnApi_transferPdo(void);
extern void CnApi_AppCbSync(void);
extern DWORD CnApi_getSyncIntPeriod(void);

#endif /* CNAPI_H_ */
