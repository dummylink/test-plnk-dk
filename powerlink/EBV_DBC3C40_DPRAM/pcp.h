/**
********************************************************************************
\file		pcp.h

\brief		header file of Powerlink Communication Processor application

\author		baumgartnerj

\date		20.04.2010

DETAILED_DESCRIPTION_OF_FILE
*******************************************************************************/

#ifndef GENERICIF_H_
#define GENERICIF_H_

/******************************************************************************/
/* includes */
#include "system.h"
#include "cnApi.h"
#include "Debug.h"

/******************************************************************************/
/* defines */
/* defines */
#define PDI_DPRAM_BASE_PCP      POWERLINK_0_PDI_PCP_BASE  //from system.h

/* Powerlink defaults */
#define DEFAULT_CYCLE_LEN   1000    ///< [us]
#define IP_ADDR     0xc0a86401      ///< 192.168.100.1 - last byte will be nodeId
#define SUBNET_MASK 0xFFFFFF00      ///< 255.255.255.0

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* global variables */
extern tPcpCtrlReg     *pCtrlReg_g;       ///< ptr. to PCP control register
extern tCnApiInitParm  initParm_g;        ///< Powerlink initialization parameter
extern BOOL            fPLisInitalized_g; ///< Powerlink initialization after boot-up flag
extern int             iSyncIntCycle_g;   ///< IR synchronization factor (multiple cycle time)
extern BOOL            fIrqSyncMode_g;    ///< synchronization mode flag

extern tLinkPdosReq *pAsycMsgLinkPdoReq_g; ///< Asynchronous PDI Message

//TODO:DELETE extern tLinkPdosReq     *pTxDescBuf_g; //TODO: delete as soon as tunnel through Async Channel

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

extern int Gi_initPdo(void);
extern void Gi_readPdo(void);
extern void Gi_writePdo(void);
extern int Gi_setupPdoDesc(BYTE bDirection_p,  WORD *pCurrentDescrOffset_p, tLinkPdosReq *pLinkPdoReq_p);

extern void Gi_initSyncInt(void);
extern void Gi_getSyncIntModeFlags(void);
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

