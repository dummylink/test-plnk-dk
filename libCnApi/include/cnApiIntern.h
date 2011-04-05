/**
********************************************************************************
\file		cnApiIntern.h

\brief		header file with internal definitions for CN API library

\author		Josef Baumgartner

\date		22.03.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This header file contains internal definitions for the CN API.
*******************************************************************************/

#ifndef CNAPIINTERN_H_
#define CNAPIINTERN_H_

/******************************************************************************/
/* includes */
#include "cnApiDebug.h"
#include "cnApiGlobal.h"            ///< global definitions

/******************************************************************************/
/* defines */
#define	MAX_ASYNC_TIMEOUT	500	    ///< timeout counter for asynchronous transfers


/* defines for SYNC_IRQ_CTRL for AP only */
#define SYNC_IRQ_ACK    0
/* defines for SYNC_IRQ_CTRL for AP and PCP */
#define SYNC_IRQ_SYNC_MODE      15  ///< AP sets desired synchronization mode (IR = 1, polling=0),
                                    ///< PCP reads the mode (PCP RO register)
/* defines for SYNC_IRQ_CTRL for PCP only */
#define SYNC_IRQ_SET    0       ///< assert IR signal
#define SYNC_IRQ_MODE   6       ///< mode: SW set (0) or HW triggered (1)
#define SYNC_IRQ_ENABLE 7       ///< IR signal enable

/* defines for ASYNC_IRQ_CTRL for AP only */
#define ASYNC_IRQ_EN    15

/* defines for EVENT_ACK */
#define EVT_GENERIC     0
#define EVT_PHY0_LINK   6
#define EVT_PHY1_LINK   7

/* defines for LED_CNTRL */
#define LED_STATUS      0
#define LED_ERROR       1
#define LED_PHY0_LINK   2
#define LED_PHY0_ACT    3
#define LED_PHY1_LINK   4
#define LED_PHY1_ACT    5
#define LED_OPTION_0    6
#define LED_OPTION_1    7

/* defines for LED_CNFG */
#define LED_FORCE_EN0       ///< Bit pattern has to be set to enable LED forcing by SW


/******************************************************************************/
/* function declarations */
extern BYTE CnApi_getPcpState(void);
extern DWORD CnApi_getPcpMagic(void);
extern void CnApi_setApCommand(BYTE bCmd_p);
extern void CnApi_initApStateMachine(void);

/* functions for object access */
extern BOOL CnApi_setupMappedObjects(WORD wIndex_p, BYTE bSubIndex_p, WORD *wSize_p, char **pAdrs_p);
extern void CnApi_resetObjectSelector(void);
extern void CnApi_resetLinkCounter(void);
extern int CnApi_getNextObject(tCnApiObjId *pObjId);
extern void CnApi_createObjectLinks(void);
extern int CnApi_writeObjects(WORD index, BYTE subIndex, WORD dataLen, BYTE* p_data, BOOL sync);

/* functions for asynchronous transfers */
extern void CnApi_initAsync(tAsyncMsg *pAsyncTxAdrs_p, WORD wAsyncTxSize_p,
					 tAsyncMsg *pAsyncRxAdrs_p, WORD wAsyncRxSize_p);
extern BYTE CnApi_checkAsyncSyncFlag(BYTE bDirection_p);
extern tAsyncSendStatus CnApi_sendAsync(BYTE bChannel_p, tAsyncIntChan *pData_p, WORD wLen_p,
		            char *pPayload_p, WORD wPayloadLen_p);
extern tAsyncSendStatus CnApi_receiveAsync(BYTE *pChannel_p, tAsyncIntChan *pData_p, WORD *pLen_p);
extern void CnApi_setupAsyncCall(BYTE bCmd_p, tAsyncIntChan *pInitPcpReq_p, WORD wReqLen_p,
					tAsyncIntChan *pInitPcpResp_p, WORD *pRespLen_p);
extern int CnApi_processAsyncCall(void);
extern int CnApi_doInitPcpReq(void);
extern int CnApi_doCreateObjLinksReq(tCnApiObjId *pObjList_p, WORD wNumObjs_p);

/* functions for interrupt synchronization */
extern DWORD CnApi_getSyncIntPeriod(void);

/* functions for PDO transfers */
extern int CnApi_initPdo(void);
void CnApi_readPdoDesc(tPdoDescHeader *pPdoDescHeader_p);

#endif /* CNAPIINTERN_H_ */
