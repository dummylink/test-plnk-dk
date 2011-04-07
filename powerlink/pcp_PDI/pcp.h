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
#define PDI_DPRAM_BASE_PCP      POWERLINK_0_PDI_PCP_BASE  //from system.h
#define MAX_NUM_LINKED_OBJ_PCP  500 //TODO: system.h

#ifdef NODE_SWITCH_PIO_BASE
    #define SET_NODE_ID_BY_HW
#else
    #warning No Node ID module present in SOPC. NodeID can only be set by SW (AP)!
#endif

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

extern tObjTbl     *pPcpLinkedObjs_g;     ///< table of linked objects at pcp side according to AP message
extern DWORD       dwApObjLinkEntries_g;  ///< number of linked objects at pcp side

extern tLinkPdosReq *pAsycMsgLinkPdoReq_g; ///< Asynchronous PDI Message

/******************************************************************************/
/* function declarations */
extern BYTE getCommandFromAp(void);
extern void storePcpState(BYTE bState_p);
extern BYTE getPcpState(void);
extern int initPowerlink(tCnApiInitParm *pInitParm_p);
extern int linkPowerlinkVars(void);
extern int startPowerlink(void);

extern void Gi_init(void);
void Gi_shutdown(void);

extern int Gi_initAsync(tAsyncMsg *pAsyncSendBuf_p, tAsyncMsg *pAsyncRecvBuf_p);
extern void Gi_pollAsync(void);

extern int Gi_initPdo(void);
extern int Gi_createPcpObjLinksTbl(DWORD dwMaxLinks_p);
extern BOOL Gi_checkIfObjLinked(WORD wIndex_p, WORD wSubIndex_p);
extern void Gi_readPdo(void);
extern void Gi_writePdo(void);
extern int Gi_setupPdoDesc(BYTE bDirection_p,  WORD *pCurrentDescrOffset_p, tLinkPdosReq *pLinkPdoReq_p);

extern void Gi_initSyncInt(void);
extern void Gi_getSyncIntModeFlags(void);
extern void Gi_calcSyncIntPeriod(void);
extern void Gi_generateSyncInt(void);
extern void Gi_disableSyncInt(void);
extern void Gi_SetTimerSyncInt(UINT32 uiTimeValue);

extern void Gi_throwAsyncEvent(WORD wEventType_p, WORD wArg_p);

extern void Gi_controlLED(BYTE bType_p, BOOL bOn_p);

#endif /* GENERICIF_H_ */

/* END-OF-FILE */
/******************************************************************************/

