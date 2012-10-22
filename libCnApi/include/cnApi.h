/**
********************************************************************************
\file       cnApi.h

\brief      Main header file of CN API library

This header file contains definitions for the CN API. It needs to be included
by the user and provides all needed prototypes and data structures to use
the interface of the library.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPI_H_
#define CNAPI_H_

/******************************************************************************/
/* includes */
#include <cnApiGlobal.h>
#include <cnApiDebug.h>

#include <cnApiCfg.h>
#include <cnApiBenchmark.h>
#include <cnApiEvent.h>     ///< public defines for the event module
#include <cnApiObd.h>


#include "EplErrDef.h"
#include "EplSdoAc.h"

#ifdef CN_API_USING_SPI
  #include <cnApiPdiSpi.h>
#endif


/******************************************************************************/
/* defines */
#ifndef PCP_PDI_TPDO_CHANNELS
#error "cnApiCfg.h has not been generated correctly!"
#endif /* PCP_PDI_TPDO_CHANNELS */

/******************************************************************************/
/* type definitions */
typedef struct
{
    DWORD                   m_dwSec;
    DWORD                   m_dwNanoSec;

} tCnApiNetTime;

typedef struct
{
    tCnApiNetTime           m_netTime;
    QWORD                   m_qwRelTime;
    WORD                    m_wTimeAfterSync;
} tCnApiTimeStamp;


typedef tCnApiStatus (* tCnApiAppCbSync) ( tCnApiTimeStamp * pTimeStamp_p );
typedef tEplKernel (* tCnApiObdDefAcc) (tEplObdParam * pObdParam_p);



/**
 * \brief structure for libCnApi initialization parameters
 */
typedef struct sCnApiInitParm {
    WORD                    m_wNumObjects;
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
} tCnApiInitParam;

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */
extern tCnApiStatus CnApi_init(tCnApiInitParam *pInitCnApiParam_p, tPcpInitParam *pInitPcpParam_p);
extern void CnApi_exit(void);
extern WORD CnApi_getNodeId(void);

/* functions for AP state machine */
extern void CnApi_activateApStateMachine(void);
extern void CnApi_resetApStateMachine(void);
extern BOOL CnApi_processApStateMachine(void);
extern void CnApi_enterApStateReadyToOperate();

/* functions for object access */
extern int CnApi_linkObject(WORD wIndex_p, BYTE bSubIndex_p, WORD wSize_p, BYTE * pAdrs_p);
extern tEplKernel CnApi_DefObdAccFinished(tEplObdParam * pObdParam_p);

/* functions for interrupt synchronization */
extern void CnApi_initSyncInt(DWORD dwMinCycleTime_p, DWORD dwMaxCycleTime_p, BYTE bReserved);
extern void CnApi_enableSyncInt(void);
extern void CnApi_disableSyncInt(void);
extern void CnApi_ackSyncIrq(void);
extern DWORD CnApi_getSyncIntPeriod(void);

/* functions for PDO transfer*/
extern void CnApi_processPdo(void);
extern tPdiAsyncStatus CnApi_sendPdoResp(BYTE bMsgId_p,
                                         BYTE bOrigin_p,
                                         WORD wObdAccConHdl_p,
                                         DWORD dwErrorCode_p);
/* functions for async state machine */
extern BOOL CnApi_processAsyncStateMachine(void);

/* functions for the LED module */
extern tCnApiStatus CnApi_setLed(tCnApiLedType bLed_p, BOOL bOn_p);


#endif /* CNAPI_H_ */

/*******************************************************************************
*
* License Agreement
*
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved.
*
* Redistribution and use in source and binary forms,
* with or without modification,
* are permitted provided that the following conditions are met:
*
*   * Redistributions of source code must retain the above copyright notice,
*     this list of conditions and the following disclaimer.
*   * Redistributions in binary form must reproduce the above copyright notice,
*     this list of conditions and the following disclaimer
*     in the documentation and/or other materials provided with the
*     distribution.
*   * Neither the name of the B&R nor the names of its contributors
*     may be used to endorse or promote products derived from this software
*     without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
* A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
* THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
*******************************************************************************/
/* END-OF-FILE */

