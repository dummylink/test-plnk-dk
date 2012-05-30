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
#include "cnApiCfg.h"
#include "cnApiTyp.h"

#include "cnApiEvent.h"
#include "cnApiAsyncSm.h"

#include "EplErrDef.h"
#include "EplObd.h"
#include "EplSdoAc.h"

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

/******************************************************************************/
/* type definitions */

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

typedef	void (*tpfnPdoDescCb) (BYTE *pPdoDesc_p, BYTE bDescrEntries_p); ///< type definition for PDO descriptor callback function
typedef	void (*tpfnPdoCopyCb) (BYTE *pPdoData_p); 						///< type definition for PDO copy callback function

typedef int (*tpfnSpiMasterTxCb) (unsigned char *pTxBuf_p, int iBytes_p);
typedef int (*tpfnSpiMasterRxCb) (unsigned char *pTxBuf_p, int iBytes_p);

/******************************************************************************/

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

extern tEplKernel CnApi_CbDefaultObdAccess(tEplObdParam * pObdParam_p);
extern tEplKernel CnApi_DefObdAccFinished(tEplObdParam ** pObdParam_p);

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

/* functions for async state machine */
extern BOOL CnApi_processAsyncStateMachine(void);

/* functions for async event handling */
extern void CnApi_enableAsyncEventIRQ(void);
extern void CnApi_disableAsyncEventIRQ(void);
extern void CnApi_pollAsyncEvent(void);

/* functions for the LED module */
extern tCnApiStatus CnApi_setLed(tCnApiLedType bLed_p, BOOL bOn_p);


#endif /* CNAPI_H_ */
