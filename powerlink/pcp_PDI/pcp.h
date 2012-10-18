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
#include "cnApiTyp.h"
#include "pcpAsync.h"

#include "Debug.h"
#include "EplErrDef.h"
#include "EplObd.h"

#ifdef EPL_MODULE_API_PDI
/******************************************************************************/
/* defines */
/* Powerlink defaults */
#define DEFAULT_CYCLE_LEN   1000    ///< [us]
#define IP_ADDR     0xc0a86401      ///< 192.168.100.1 - last byte will be nodeId
#define SUBNET_MASK 0xFFFFFF00      ///< 255.255.255.0

/******************************************************************************/
/* typedefs */

/**
 * \brief enum of object access storage locations
 */
typedef enum eObdAccStorage {
    kObdAccStorageInvalid,          ///< invalid location
    kObdAccStorageDefObdAccHistory, ///< default OBD access history
} tObdAccStorage;

/**
 * \brief structure for object access forwarding to PDI (i.e. AP)
 */
typedef struct sObdAccComCon {
    WORD            m_wComConIdx; ///< communication connection index of lower layer
    tObdAccStorage  m_Origin;   ///< OBD handle storage location
} tObdAccComCon;

/**
 * \brief PDI communication connection structure
 */
typedef struct sApiPdiComCon {
    tObdAccComCon  m_ObdAccFwd;  ///< object access forwarding connection
} tApiPdiComCon;


/******************************************************************************/
/* global variables */
extern volatile tPcpCtrlReg *     pCtrlReg_g;       ///< ptr. to PCP control register
extern tPcpInitParam  initParam_g;        ///< Powerlink initialization parameter


extern WORD            wSyncIntCycle_g;           ///< IR synchronization factor (multiple cycle time)

// Api PDI communication instance
extern tApiPdiComCon ApiPdiComInstance_g;

/******************************************************************************/
/* function declarations */
extern BYTE getCommandFromAp(void);
extern void storePcpState(BYTE bState_p);


extern int Gi_createPcpObjLinksTbl(DWORD dwMaxLinks_p);
extern BOOL Gi_checkIfObjLinked(WORD wIndex_p, WORD wSubIndex_p);

extern void Gi_enableSyncInt(WORD wSyncIntCycle_p);

extern void Gi_controlLED(tCnApiLedType bType_p, BOOL bOn_p);

// OBD access history public functions
extern tEplKernel EplAppDefObdAccAdoptedHstryInitSequence(void);
extern tEplKernel EplAppDefObdAccAdoptedHstrySaveHdl(tEplObdParam * pObdParam_p,
                                                     tObdAccHstryEntry **ppDefHdl_p);
extern int EplAppDefObdAccAdoptedHstryWriteSegmAbortCb(tObdAccHstryEntry * pDefObdHdl_p);
extern int EplAppDefObdAccAdoptedHstryWriteSegmFinishCb(tObdAccHstryEntry * pDefObdHdl_p);
extern void EplAppDefObdAccAdoptedHstryCleanup(void);

extern tPdiAsyncStatus Gi_ObdAccFwdPdiTxFinishedErrCb(tPdiAsyncMsgDescr * pMsgDescr_p);
extern tEplKernel Gi_openObdAccHstryToPdiConnection(tObdAccHstryEntry * pDefObdHdl_p);
extern tEplKernel Gi_closeObdAccHstryToPdiConnection(WORD wComConIdx_p,
                                              DWORD dwAbortCode_p,
                                              WORD  wReadObjRespSegmSize_p,
                                              void* pReadObjRespData_p);
extern tPdiAsyncStatus Gi_ObdAccFwdPdiTxFinishedErrCb(tPdiAsyncMsgDescr * pMsgDescr_p);
extern tEplKernel Gi_checkandConfigurePdoPdi(unsigned int uiMappParamIndex_p,
                                                 BYTE bMappObjectCount_p,
                                                 tEplObdAccess AccessType_p,
                                                 tEplObdCbParam* pParam_p);
extern BOOL Gi_getCurPdiObdAccFwdComCon(tApiPdiComCon * pApiPdiComConInst_p,
                                        WORD * pwComConIdx_p);

#endif // EPL_MODULE_API_PDI

#endif /* GENERICIF_H_ */

/* END-OF-FILE */
/******************************************************************************/

