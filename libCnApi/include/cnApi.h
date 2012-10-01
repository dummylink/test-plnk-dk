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
#include "cnApiGlobal.h"
#include "cnApiDebug.h"

#include "cnApiEvent.h"     ///< public defines for the event module

#include "EplErrDef.h"
#include "EplObd.h"
#include "EplSdoAc.h"

#ifdef CN_API_USING_SPI
  #include "cnApiPdiSpi.h"
#endif


/******************************************************************************/
/* defines */
#ifndef PCP_PDI_TPDO_CHANNELS
#error "cnApiCfg.h has not been generated correctly!"
#endif /* PCP_PDI_TPDO_CHANNELS */

/* Convert endian define to enable usage while runtime */
#ifdef AP_IS_BIG_ENDIAN
#define CNAPI_BIG_ENDIAN TRUE
#else
#define CNAPI_BIG_ENDIAN FALSE
#endif

/******************************************************************************/
/* type definitions */
typedef void (* tCnApiAppCbSync) ( void );
typedef tEplKernel (* tCnApiObdDefAcc) (tEplObdParam * pObdParam_p);



/**
 * \brief structure for libCnApi initialization parameters
 */
typedef struct sCnApiInitParm {
    BYTE *                  m_pDpram_p;
    tCnApiAppCbSync         m_pfnAppCbSync;
    tCnApiAppCbEvent        m_pfnAppCbEvent;
    tCnApiObdDefAcc         m_pfnDefaultObdAccess_p;
#ifdef CN_API_USING_SPI
    tSpiMasterTxHandler     m_SpiMasterTxH_p;
    tSpiMasterRxHandler     m_SpiMasterRxH_p;
    void *                  m_pfnEnableGlobalIntH_p;
    void *                  m_pfnDisableGlobalIntH_p;
#endif //CN_API_USING_SPI
} tCnApiInitParm;

/******************************************************************************/

/******************************************************************************/
/* global variables */
extern tPcpInitParm *               pInitPcpParm_g;        ///< pointer to POWERLINK init parameters
extern BYTE *                       pDpramBase_g;          ///< pointer to Dpram base address

/******************************************************************************/
/* function declarations */
extern tCnApiStatus CnApi_init(tCnApiInitParm *pInitCnApiParm_p, tPcpInitParm *pInitPcpParm_p);
extern void CnApi_exit(void);
extern WORD CnApi_getNodeId(void);

/* functions for AP state machine */
extern void CnApi_activateApStateMachine(void);
extern void CnApi_resetApStateMachine(void);
extern BOOL CnApi_processApStateMachine(void);
extern void CnApi_enterApStateReadyToOperate();

/* functions for object access */
extern int CnApi_initObjects(DWORD dwMaxLinks_p);
extern int CnApi_linkObject(WORD wIndex_p, BYTE bSubIndex_p, WORD wSize_p, BYTE * pAdrs_p);
extern void CnApi_cleanupObjects(void);
extern tEplKernel CnApi_DefObdAccFinished(tEplObdParam * pObdParam_p);

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
extern DWORD CnApi_getSyncIntPeriod(void);

/* functions for PDO transfer*/
extern void CnApi_processPdo(void);
extern tPdiAsyncStatus CnApi_sendPdoResp(BYTE bMsgId_p, BYTE bOrigin_p,
        DWORD dwErrorCode_p);

/* functions for async state machine */
extern BOOL CnApi_processAsyncStateMachine(void);

/* functions for the LED module */
extern tCnApiStatus CnApi_setLed(tCnApiLedType bLed_p, BOOL bOn_p);


#endif /* CNAPI_H_ */
