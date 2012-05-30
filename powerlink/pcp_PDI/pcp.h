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



/******************************************************************************/
/* defines */
/* Powerlink defaults */
#define DEFAULT_CYCLE_LEN   1000    ///< [us]
#define IP_ADDR     0xc0a86401      ///< 192.168.100.1 - last byte will be nodeId
#define SUBNET_MASK 0xFFFFFF00      ///< 255.255.255.0

/******************************************************************************/
/* typedefs */

/**
 * \brief structure for object access forwarding to PDI (i.e. AP)
 */
typedef struct sApiPdiComCon {
    tEplObdParam *          apObdParam_m[1];    ///< SDO command layer connection handle number
} tApiPdiComCon;


/******************************************************************************/
/* global variables */
extern volatile tPcpCtrlReg *     pCtrlReg_g;       ///< ptr. to PCP control register
extern tCnApiInitParm  initParm_g;        ///< Powerlink initialization parameter


extern BOOL            fPLisInitalized_g; ///< Powerlink initialization after boot-up flag
extern WORD            wSyncIntCycle_g;           ///< IR synchronization factor (multiple cycle time)

// Api PDI communication instance
extern tApiPdiComCon ApiPdiComInstance_g;

/******************************************************************************/
/* function declarations */
extern BYTE getCommandFromAp(void);
extern void storePcpState(BYTE bState_p);

extern int initPowerlink(tCnApiInitParm *pInitParm_p);
extern int startPowerlink(void);


extern int Gi_createPcpObjLinksTbl(DWORD dwMaxLinks_p);
extern BOOL Gi_checkIfObjLinked(WORD wIndex_p, WORD wSubIndex_p);

extern void Gi_enableSyncInt(WORD wSyncIntCycle_p);

extern void Gi_controlLED(tCnApiLedType bType_p, BOOL bOn_p);

extern tEplKernel EplAppDefObdAccFinished(tEplObdParam ** pObdParam_p);
extern void EplAppDefObdAccCleanupHistory(void);
extern void EplAppDefObdAccCleanupAllPending(void);

extern tPdiAsyncStatus Gi_ObdAccessSrcPdiFinished (tPdiAsyncMsgDescr * pMsgDescr_p);

#endif /* GENERICIF_H_ */

/* END-OF-FILE */
/******************************************************************************/

