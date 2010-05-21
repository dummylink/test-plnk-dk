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
#include "cnApiGlobal.h"     // global definitions

/******************************************************************************/
/* defines */
#define	MAX_ASYNC_TIMEOUT	500			///< timeout counter for asynchronous transfers

/* interrupt control register definitions */
#define	CNAPI_INT_CTRL_EN	0x80
#define	CNAPI_INT_CTRL_POL	0x20

/******************************************************************************/
/* function declarations */
extern BYTE CnApi_getPcpState(void);
extern DWORD CnApi_getPcpMagic(void);
extern void CnApi_setApCommand(BYTE bCmd_p);
extern void CnApi_initApStateMachine(void);

/* functions for object access */
extern BOOL CnApi_getObjectData(WORD wIndex_p, BYTE bSubIndex_p, WORD *wSize_p, char **pAdrs_p);
extern void CnApi_resetObjectSelector(void);
extern int CnApi_getNextObject(tCnApiObjId *pObjId);
extern void CnApi_createObjects(void);
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
extern int CnApi_doCreateObjReq(tCnApiObjId *pObjList_p, WORD wNumObjs_p);

/* functions for PDO transfers */
extern void CnApi_initPdo(char *pTxPdoAdrs_p, WORD wTxPdoSize_p,
				   char *pRxPdoAdrs_p, WORD wRxPdoSize_p,
				   tPdoDescHeader *pTxDescAdrs_p, WORD wTxDescSize_p,
				   tPdoDescHeader *pRxDescAdrs_p, WORD wRxDescSize_p);
extern void CnApi_readPdoDesc(void);

/* functions for periodic buffer synchronization */
extern int CnApi_initPdoSync(tPdoSync *pPdoWriteSync_p, tPdoSync *pPdoReadSync_p);
extern char CnApi_getPdoWriteIndex(void);
extern void CnApi_releasePdoWriteIndex(void);
extern char CnApi_getPdoReadIndex(void);
extern void CnApi_releasePdoReadIndex(void);

#endif /* CNAPIINTERN_H_ */
