/**
********************************************************************************
\file		GenericIf.h

\brief		BRIEF_DESCRIPTION_OF_FILE

\author		baumgartnerj

\date		20.04.2010

DETAILED_DESCRIPTION_OF_FILE
*******************************************************************************/

#ifndef GENERICIF_H_
#define GENERICIF_H_

/******************************************************************************/
/* includes */

#include "cnApi.h"

/******************************************************************************/
/* defines */

#include "Debug.h"

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* global variables */
extern tPcpCtrlReg	*pCtrlReg_g;
extern tCnApiInitParm initParm_g;
extern int iSyncIntCycle_g;

/******************************************************************************/
/* function declarations */
extern BYTE getCommandFromAp(void);
extern void storePcpState(BYTE bState_p);
extern BYTE getPcpState(void);
extern int initPowerlink(tCnApiInitParm *pInitParm_p);
extern int linkPowerlinkVars(void);
extern int startPowerlink(void);

extern void Gi_init(void);

extern int Gi_initAsync(tAsyncMsg *pAsyncSendBuf_p, tAsyncMsg *pAsyncRecvBuf_p);
extern void Gi_pollAsync(void);

extern int Gi_initPdo(BYTE *pTxPdoBuf_p, BYTE *pRxPdoBuf_p,
					  BYTE *pTxPdoAckAdrsPcp_p, BYTE *pRxPdoAckAdrsPcp_p,
					  tPdoDescHeader *pTxDescBuf_p, tPdoDescHeader *pRxDescBuf_p);
extern void Gi_readPdo(void);
extern void Gi_writePdo(void);
extern int Gi_setupPdoDesc(BYTE bDirection_p);

extern void Gi_initSyncInt(void);
extern void Gi_calcSyncIntPeriod(void);
extern void Gi_generateSyncInt(void);
extern void Gi_disableSyncInt(void);
extern void Gi_SetTimerSyncInt(UINT32 uiTimeValue);


extern void Gi_initDpramMutex(void);
extern BYTE Gi_getPdoWriteIndex(void);
extern void Gi_setPdoWriteIndex(void);
extern BYTE Gi_getPdoReadIndex(void);
extern void Gi_releasePdoReadIndex(void);



#endif /* GENERICIF_H_ */

/* END-OF-FILE */
/******************************************************************************/

