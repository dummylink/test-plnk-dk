/**
********************************************************************************
\file       cnApi.c

\brief      Main module of CN API library

This module contains the main module of the POWERLINK CN API library.
The CN API library provides an API for the interface of an application
processor (AP) to the POWERLINK communication processor (PCP).

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include <cnApi.h>

#include "cnApiIntern.h"
#include "cnApiEventIntern.h"
#include "cnApiAsync.h"
#include "cnApiPdo.h"
#include "cnApiObjectIntern.h"

#if VETH_DRV_ENABLE != FALSE
  #include "cnApiAsyncVethIntern.h"
#endif

#ifdef CN_API_USING_SPI
  #include "cnApiPdiSpiIntern.h"
#endif

#include "cnApiAmi.h"

/******************************************************************************/
/* defines */
/* wait for PCP definitions */
#define PCP_PRESENCE_RETRY_COUNT         20        ///< number of retries until abort
#define PCP_PRESENCE_RETRY_TIMEOUT_US    5000000     ///< wait time in us until retry

#define PCP_PRESENCE_RESET_TIMEOUT_US    500000     ///< time for the PCP to do the reset (us)

#define SYNC_IRQ_ACK                0               ///< Sync IRQ Bit shift (for AP only)

#define PCP_CONV_INVALID                 5

#define CONV_STATE(state)       (state > kPcpStateOperational) ? PCP_CONV_INVALID : state

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

static tPcpCtrlReg *       pCtrlReg_l;      ///< pointer to PCP control registers (little endian)

#ifdef CN_API_USING_SPI
static tPcpCtrlReg     PcpCntrlRegMirror_l; ///< if SPI is used, we need a local copy of the PCP Control Register
#endif

static char *strPcpStates[] = {          ///< strings of PCP states
        "kPcpStateBooted",
        "kPcpStateInit",
        "kPcpStatePreOp",
        "kPcpStateReadyToOperate",
        "kPcpStateOperational",
        "kPcpStateInvalid"
    };

/******************************************************************************/
/* function declarations */
static BOOL CnApi_checkPcpPresent(void);

/******************************************************************************/
/* private functions */

/**
********************************************************************************
\brief  checks if the PCP interface is present and ready

Checks if the PCP is present by reading the magic value. If the magic word
is available it checks if the PCP is in init state.

\return BOOL
\retval TRUE             PCP is here and ready
\retval FALSE            unable to reach PCP
*******************************************************************************/
static BOOL CnApi_checkPcpPresent(void)
{
    int iCnt;
    BOOL fPcpMagicOk = FALSE;
    BOOL fPcpStateOk = FALSE;

    /* check if PCP interface is present */
    for(iCnt = 0; iCnt < PCP_PRESENCE_RETRY_COUNT; iCnt++)
    {
        if(CnApi_getPcpMagic() == PCP_MAGIC)
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "PCP Magic value: %#08lx ... OK!\n",
                                                CnApi_getPcpMagic());
            fPcpMagicOk = TRUE;
            break;
        }
        else
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "PCP Magic value: %#08lx ... ERROR! => Retry!\n",
                                                CnApi_getPcpMagic());
        }
        CNAPI_USLEEP(PCP_PRESENCE_RETRY_TIMEOUT_US);
    }

    if(fPcpMagicOk)
    {
        CnApi_setApCommand(kApCmdReset);
        CNAPI_USLEEP(PCP_PRESENCE_RESET_TIMEOUT_US);

        /* check if PCP is activated */
        for(iCnt = 0; iCnt < PCP_PRESENCE_RETRY_COUNT; iCnt++)
        {
            if(CnApi_getPcpState() == kPcpStateBooted)
            {
                DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "PCP state: %s ... OK!\n",
                        strPcpStates[CONV_STATE(CnApi_getPcpState())]);
                fPcpStateOk = TRUE;
                break;
            }
            else
            {
                DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "PCP state: %s ... ERROR! => Retry!\n",
                        strPcpStates[CONV_STATE(CnApi_getPcpState())]);
            }
            CNAPI_USLEEP(PCP_PRESENCE_RETRY_TIMEOUT_US);
        }
    }

    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "\n");

    return fPcpStateOk;
}


/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  initialize CN API

CnApi_init() is used to initialize the user API library. The function must be
called by the application in order to use the API.

\param      pInitCnApiParam_p          pointer to the libCnApi initialization structure
\param      pInitPcpParam_p             pointer to the POWERLINK initialization structure

\return     tCnApiStatus
\retval     kCnApiStatusOk             if API was successfully initialized
\retval     kCnApiStatusError          in case of an init error
*******************************************************************************/
tCnApiStatus CnApi_init(tCnApiInitParam *pInitCnApiParam_p, tPcpInitParam *pInitPcpParam_p)
{
    tCnApiStatus    FncRet = kCnApiStatusOk;
    BOOL            fPcpPresent = FALSE;
    int             iStatus;
#ifdef CN_API_USING_SPI
    int iRet = OK;
#endif //CN_API_USING_SPI

    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO,"\n\nInitialize CN API functions...\n");

    /* Control and Status Register is little endian */
#ifdef CN_API_USING_SPI
    pCtrlReg_l = &PcpCntrlRegMirror_l;         //< if SPI is used, take local var instead of parameter
#else
    pCtrlReg_l = (tPcpCtrlReg *)pInitCnApiParam_p->m_pDpram;    //< if no SPI is used, take parameter to dpram
#endif // CN_API_USING_SPI

#ifdef CN_API_USING_SPI
    /* initialize user-callback functions for SPI */
    iRet = CnApi_initSpiMaster(pInitCnApiParm_p->m_SpiMasterTxH, pInitCnApiParm_p->m_SpiMasterRxH,
            pInitCnApiParm_p->m_pfnEnableGlobalIntH, pInitCnApiParm_p->m_pfnDisableGlobalIntH);
    if( iRet != OK )
    {
        FncRet = kCnApiStatusError;
        goto exit;
    }
#endif /* CN_API_USING_SPI */

    /* Check if PCP interface is ready */
    fPcpPresent = CnApi_checkPcpPresent();
    if(!fPcpPresent)
    {
        /* PCP_PRESENCE_RETRY_COUNT exceeded */
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "TIMEOUT: PCP not responding!\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }

#ifdef CN_API_USING_SPI
    /* update PCP control register */
    CnApi_Spi_read(PCP_CTRLREG_START_ADR, PCP_CTRLREG_SPAN, (BYTE*) pCtrlReg_l);
#endif /* CN_API_USING_SPI */


    /* verify FPGA configuration ID */
    if (!CnApi_verifyPcpSystemId())
    {
        /* this compilation does not match the accessed PCP FPGA configuration */
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: FPGA Configuration ID doesn't match!\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }

    /* verify PDI revision */
    if (!CnApi_verifyPcpPdiRevision())
    {
        /* this compilation does not match the accessed PCP PDI */
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: PCP PDI Revision doesn't match!\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }

#if VETH_DRV_ENABLE != FALSE
    /* init virtual ethernet driver */
    if (CnApi_initVeth(pInitCnApiParam_p->m_pfnVethRx,
            pInitCnApiParam_p->m_pfnVethTxFinished) == ERROR )
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR: CN API library init "
                "VirtualEthernet driver failed\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }

#endif //VETH_DRV_ENABLE

    /* init cnApi async event module */
    FncRet = CnApi_initAsyncEvent(pInitCnApiParam_p->m_pfnAppCbEvent);
    if (FncRet != kCnApiStatusOk)
    {
        FncRet = kCnApiStatusError;
        goto exit;
    }

    /* initialize state machine */
    CnApi_activateApStateMachine();

    /* initialize asynchronous transfer functions */
    iStatus = CnApiAsync_create(pCtrlReg_l, pInitPcpParam_p,
            pInitCnApiParam_p->m_pDpram);
    if (iStatus != OK)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "CnApiAsync_create() failed!\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }

    /* initialize PDO transfer functions */
    iStatus = CnApi_initPdo(pCtrlReg_l, pInitCnApiParam_p->m_pfnAppCbSync,
            pInitCnApiParam_p->m_pDpram,
            pInitCnApiParam_p->m_pfnPdoDescriptor);
    if (iStatus != OK)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "CnApi_initPdo() failed!\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }

    /* initialize CN API object module */
    iStatus = CnApi_initObjects(pInitCnApiParam_p->m_wNumObjects,
            pInitCnApiParam_p->m_pfnDefaultObdAccess);
    if (iStatus != OK)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"CnApi_initObjects() failed! Unable to"
                "allocate object dictionary!\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }

    // set the default gateway
    CnApi_setDefaultGateway(pInitPcpParam_p->m_dwDefaultGateway);

exit:
    return FncRet;
}

/**
********************************************************************************
\brief  exit CN API

CnApi_exit() is used to de-initialize and do all necessary cleanups for the
API library.
*******************************************************************************/
void CnApi_exit(void)
{
    /* free memory */
    CnApi_cleanupObjects();
}

/**
********************************************************************************
\brief  initialize sync interrupt timing

CnApi_initSyncInt() is used to initialize the synchronization interrupt used by
the PCP to inform the AP that process data must be transfered. The cycle timing
of the synchronization will be calculated depending on the given parameters.

\param  dwMinCycleTime_p    minimum powerlink cycle time
\param  dwMaxCycleTime_p    maximum powerlink cycle time
\param  bReserved_p         reserved for future use
*******************************************************************************/
void CnApi_initSyncInt(DWORD dwMinCycleTime_p, DWORD dwMaxCycleTime_p, BYTE bReserved_p)
{
    /* initialize interrupt cycle timing registers */
    AmiSetDwordToLe((BYTE*)&pCtrlReg_l->m_dwMinCycleTime, dwMinCycleTime_p);
    AmiSetDwordToLe((BYTE*)&pCtrlReg_l->m_dwMaxCycleTime, dwMaxCycleTime_p);
    AmiSetWordToLe((BYTE*)&pCtrlReg_l->wCycleCalc_Reserved4, bReserved_p);


#ifdef CN_API_USING_SPI
    /* update pcp registers */
    CnApi_Spi_write(PCP_CTRLREG_MINCYCT_OFFSET,
                    sizeof(pCtrlReg_l->m_dwMinCycleTime),
                    (BYTE*) &pCtrlReg_l->m_dwMinCycleTime);
    CnApi_Spi_write(PCP_CTRLREG_MAXCYCT_OFFSET,
                    sizeof(pCtrlReg_l->m_dwMaxCycleTime),
                    (BYTE*) &pCtrlReg_l->m_dwMaxCycleTime);
    CnApi_Spi_write(PCP_CTRLREG_CYCCAL_RESERVED_OFFSET,
                    sizeof(pCtrlReg_l->wCycleCalc_Reserved4),
                    (BYTE*) &pCtrlReg_l->wCycleCalc_Reserved4);
#endif
}

/**
********************************************************************************
\brief  enable sync interrupt

CnApi_enableSyncInt() enables the synchronization interrupt at the PCP.
*******************************************************************************/
void CnApi_enableSyncInt(void)
{
    WORD wSyncIrqControl;

#ifdef CN_API_USING_SPI
    /* update local register copy */
    CnApi_Spi_read(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlReg_l->m_wSyncIrqControl),
                   (BYTE*) &pCtrlReg_l->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */

    wSyncIrqControl = AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wSyncIrqControl));

    wSyncIrqControl |= (1 << SYNC_IRQ_REQ);

    AmiSetWordToLe((BYTE*)&pCtrlReg_l->m_wSyncIrqControl, wSyncIrqControl);

#ifdef CN_API_USING_SPI
    /* update PCP PDI register */
    CnApi_Spi_write(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlReg_l->m_wSyncIrqControl),
                   (BYTE*) &pCtrlReg_l->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
\brief  disable sync interrupt

CnApi_disableSyncInt() disables the synchronization interrupt at the PCP.
*******************************************************************************/
void CnApi_disableSyncInt(void)
{
    WORD wSyncIrqControl;

#ifdef CN_API_USING_SPI
    /* update local register copy */
    CnApi_Spi_read(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlReg_l->m_wSyncIrqControl),
                   (BYTE*) &pCtrlReg_l->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */

    /* disable interrupt from PCP */
    wSyncIrqControl = AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wSyncIrqControl));

    wSyncIrqControl &= ~(1 << SYNC_IRQ_REQ);

    AmiSetWordToLe((BYTE*)&pCtrlReg_l->m_wSyncIrqControl, wSyncIrqControl);

#ifdef CN_API_USING_SPI
    /* update PCP PDI register */
    CnApi_Spi_write(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlReg_l->m_wSyncIrqControl),
                   (BYTE*) &pCtrlReg_l->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
\brief  acknowledges synchronous IRQ form PCP

Acknowledge the synchronous interrupt after the execution of it is finished.
*******************************************************************************/
void CnApi_ackSyncIrq(void)
{
    WORD wSyncIrqControl;

#ifdef CN_API_USING_SPI
    /* update local register copy */
    CnApi_Spi_read(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlReg_l->m_wSyncIrqControl),
                   (BYTE*) &pCtrlReg_l->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */


    wSyncIrqControl = AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wSyncIrqControl));

    /* acknowledge interrupt by writing to the SYNC_IRQ_CONTROL_REGISTER*/
    wSyncIrqControl |= (1 << SYNC_IRQ_ACK);

    AmiSetWordToLe((BYTE*)&pCtrlReg_l->m_wSyncIrqControl, wSyncIrqControl);

#ifdef CN_API_USING_SPI
    /* update PCP PDI register */
    CnApi_Spi_write(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlReg_l->m_wSyncIrqControl),
                   (BYTE*) &pCtrlReg_l->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
\brief  get PCP state

CnApi_getSyncIntPeriod() reads time of the periodic synchronization interrupt

\return DWORD
\retval dwSyncIntCycTime      synchronization interrupt time of PCP
*******************************************************************************/
DWORD CnApi_getSyncIntPeriod(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_SYNCIR_CYCTIME_OFFSET,
                   sizeof(pCtrlReg_l->m_dwSyncIntCycTime),
                   (BYTE*) &pCtrlReg_l->m_dwSyncIntCycTime);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*) &(pCtrlReg_l->m_dwSyncIntCycTime));
}

/**
********************************************************************************
\brief  get PCP state

CnApi_getPcpState() reads the state of the PCP and returns it.

\return BYTE
\retval m_wState        state of PCP
*******************************************************************************/
BYTE CnApi_getPcpState(void)
{
#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_STATE_OFFSET,
                   sizeof(pCtrlReg_l->m_wState),
                   (BYTE*) &pCtrlReg_l->m_wState);
#endif /* CN_API_USING_SPI */

    return AmiGetWordFromLe((BYTE*) &(pCtrlReg_l->m_wState));
}

/**
********************************************************************************
\brief  get PCP magic number

CnApi_getPcpMagic() reads the magic number stored in the PCP DPRAM area.

\return DWORD
\retval m_dwMagic        magic word of PCP
*******************************************************************************/
DWORD CnApi_getPcpMagic(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_MAGIC_OFFSET,
                   sizeof(pCtrlReg_l->m_dwMagic),
                   (BYTE*) &pCtrlReg_l->m_dwMagic);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*) &(pCtrlReg_l->m_dwMagic));
}

/**
********************************************************************************
\brief  get RelativeTime low

CnApi_getRelativeTimeLow() reads the RelativeTime low dword stored in the PCP DPRAM area.

\return DWORD
\retval pcpRelativeTimeLow        RelativeTime low of PCP
*******************************************************************************/
DWORD CnApi_getRelativeTimeLow(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_RELATIVE_TIME_LOW_OFFSET,
                   sizeof(pCtrlReg_l->m_dwRelativeTimeLow),
                   (BYTE*) &pCtrlReg_l->m_dwRelativeTimeLow);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*) &(pCtrlReg_l->m_dwRelativeTimeLow));
}

/**
********************************************************************************
\brief  get RelativeTime high

CnApi_getRelativeTimeHigh() reads the RelativeTime high dword stored in the PCP DPRAM area.

\return DWORD
\retval pcpRelativeTimeHigh        RelativeTime high of PCP
*******************************************************************************/
DWORD CnApi_getRelativeTimeHigh(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_RELATIVE_TIME_HIGH_OFFSET,
                   sizeof(pCtrlReg_l->m_dwRelativeTimeHigh),
                   (BYTE*) &pCtrlReg_l->m_dwRelativeTimeHigh);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*) &(pCtrlReg_l->m_dwRelativeTimeHigh));
}

/**
********************************************************************************
\brief  get Nettime seconds

CnApi_getNetTimeSeconds() reads the NetTime seconds stored in the PCP DPRAM area.
The Nettime value is always from the last round!

\return DWORD
\retval pcpNetTimeSeconds        NetTime seconds of PCP
*******************************************************************************/
DWORD CnApi_getNetTimeSeconds(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_NETTIME_SEC_OFFSET,
                   sizeof(pCtrlReg_l->m_dwNetTimeSec),
                   (BYTE*) &pCtrlReg_l->m_dwNetTimeSec);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*) &(pCtrlReg_l->m_dwNetTimeSec));
}

/**
********************************************************************************
\brief  get Nettime nano seconds

CnApi_getNetTimeNanoSeconds() reads the NetTime nano seconds stored in the PCP DPRAM area.
The Nettime value is always from the last round!

\return DWORD
\retval pcpNetTimeNanoSeconds        NetTime nano seconds of PCP
*******************************************************************************/
DWORD CnApi_getNetTimeNanoSeconds(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_NETTIME_NANOSEC_OFFSET,
                   sizeof(pCtrlReg_l->m_dwNetTimeNanoSec),
                   (BYTE*) &pCtrlReg_l->m_dwNetTimeNanoSec);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*) &(pCtrlReg_l->m_dwNetTimeNanoSec));
}

/**
********************************************************************************
\brief  get time after sync

CnApi_getTimeAfterSync() reads the Time After Sync stored in the PCP DPRAM area.

\return WORD
\retval pcpTimeAfterSync        Time after sync of PCP
*******************************************************************************/
WORD CnApi_getTimeAfterSync(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_TIME_AFTER_SYNC_OFFSET,
                   sizeof(pCtrlReg_l->m_wTimeAfterSync),
                   (BYTE*) &pCtrlReg_l->m_wTimeAfterSync);
#endif /* CN_API_USING_SPI */

    return AmiGetWordFromLe((BYTE*) &(pCtrlReg_l->m_wTimeAfterSync));
}

/**
********************************************************************************
\brief  set the AP's command

Write a command to the AP command register

\param bCmd_p                 command written to AP command register
*******************************************************************************/
void CnApi_setApCommand(BYTE bCmd_p)
{
    AmiSetWordToLe((BYTE*)&pCtrlReg_l->m_wCommand, bCmd_p);

#ifdef CN_API_USING_SPI
    CnApi_Spi_write(PCP_CTRLREG_CMD_OFFSET,
                    sizeof(pCtrlReg_l->m_wCommand),
                    (BYTE*) &pCtrlReg_l->m_wCommand);    //< update pcp register
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
\brief  verifies the PCP PDI revision

This function verifies if the PCP PDI revision matches to the one provided
in the POWERLINK ipcore.

\return BOOL
\retval FALSE          if revision number differs
\retval TRUE           if it equals
*******************************************************************************/
BOOL CnApi_verifyPcpPdiRevision(void)
{
#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_PDI_REV_OFFSET,
                   sizeof(pCtrlReg_l->m_wPcpPdiRev),
                   (BYTE*) &pCtrlReg_l->m_wPcpPdiRev);
#endif /* CN_API_USING_SPI */

    /* verify if this compilation of CnApi library matches
     * the current PCP PDI revision
     */
    if (PCP_PDI_REVISION != AmiGetWordFromLe((BYTE*) &(pCtrlReg_l->m_wPcpPdiRev)))
    {
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}

/**
********************************************************************************
\brief  verifies the PCP FPGA's SYSTEM ID (user defined in SOPC Builder / XPS)

Reads the PCP system id from the PDI and compares the value to the one in the
cnApiCfg.h

\return BOOL
\retval FALSE    if SYSTEM ID of this library build is not based on the current
                 FPGA build SYSTEM ID
\retval TRUE     if it matches
*******************************************************************************/
BOOL CnApi_verifyPcpSystemId(void)
{
#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_PCP_SYSID_OFFSET,
                   sizeof(pCtrlReg_l->m_wPcpSysId),
                   (BYTE*) &pCtrlReg_l->m_wPcpSysId);
#endif /* CN_API_USING_SPI */

    /* verify if this compilation of CnApi library matches the current FPGA config */
    if (PCP_SYSTEM_ID != AmiGetWordFromLe((BYTE*) &(pCtrlReg_l->m_wPcpSysId)))
    {
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}

/**
********************************************************************************
\brief  get Powerlink Node Id

This function reads the current Powerlink Node ID setting of the PCP
and returns it. This function will only return a valid value if it is executed
after PCP has reached state PCP_INIT (or in case of an related event).
Range of a valid Powerlink Slave Node ID: [0x01h .. 0xEFh]

\return WORD
\retval m_wNodeId        Powerlink Node ID
*******************************************************************************/
WORD CnApi_getNodeId(void)
{
#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_NODE_ID_OFFSET,
                   sizeof(pCtrlReg_l->m_wNodeId),
                   (BYTE*) &pCtrlReg_l->m_wNodeId);
#endif /* CN_API_USING_SPI */


    return AmiGetWordFromLe((BYTE*) &(pCtrlReg_l->m_wNodeId));
}

/**
********************************************************************************
\brief  set POWERLINK LEDs

Sets the LED according to bLed_p to the value bOn_p

\param bLed_p        Type of Led to set
\param bOn_p         (TRUE = On, FALSE = Off)

\return tCnApiStatus
\retval kCnApiStatusOk        when command succeeds
\retval kCnApiStatusError     when the LED is not existing
*******************************************************************************/
tCnApiStatus CnApi_setLed(tCnApiLedType bLed_p, BOOL bOn_p)
{
    tCnApiStatus FncRet = kCnApiStatusOk;
    WORD wLedCnf, wLedCntrl, wRegisterBitNum = 0;

    switch(bLed_p)
    {
        case kCnApiLedTypeStatus:
            wRegisterBitNum = kCnApiLedTypeStatus;
            break;
        case kCnApiLedTypeError:
            wRegisterBitNum = kCnApiLedTypeError;
            break;
        case kCnApiLedTypePhy0Link:
            wRegisterBitNum = kCnApiLedTypePhy0Link;
            break;
        case kCnApiLedTypePhy0Active:
            wRegisterBitNum = kCnApiLedTypePhy0Active;
            break;
        case kCnApiLedTypePhy1Link:
            wRegisterBitNum = kCnApiLedTypePhy1Link;
            break;
        case kCnApiLedTypePhy1Active:
            wRegisterBitNum = kCnApiLedTypePhy1Active;
            break;
        case kCnApiLedTypeOpt0:
            wRegisterBitNum = kCnApiLedTypeOpt0;
            break;
        case kCnApiLedTypeOpt1:
            wRegisterBitNum = kCnApiLedTypeOpt1;
            break;
        case kCnApiLedInit:
            FncRet = kCnApiStatusError;
            goto Exit;
        break;
    }

#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_LED_CTRL_OFFSET,
                   sizeof(pCtrlReg_l->m_wLedControl),
                   (BYTE*) &pCtrlReg_l->m_wLedControl);

    CnApi_Spi_read(PCP_CTRLREG_LED_CNFG_OFFSET,
                   sizeof(pCtrlReg_l->m_wLedConfig),
                   (BYTE*) &pCtrlReg_l->m_wLedConfig);
#endif /* CN_API_USING_SPI */

    wLedCnf = AmiGetWordFromLe((BYTE*) &(pCtrlReg_l->m_wLedConfig));
    wLedCntrl = AmiGetWordFromLe((BYTE*) &(pCtrlReg_l->m_wLedControl));

    if (bOn_p)  //activate LED output
    {
        wLedCntrl |= (1 << wRegisterBitNum);
        wLedCnf |= (1 << wRegisterBitNum);
    }
    else        // deactive LED output
    {
        wLedCntrl &= ~(1 << wRegisterBitNum);
        wLedCnf &= ~(1 << wRegisterBitNum);
    }


    AmiSetWordToLe((BYTE*)&pCtrlReg_l->m_wLedControl, wLedCntrl);
    AmiSetWordToLe((BYTE*)&pCtrlReg_l->m_wLedConfig, wLedCnf);

#ifdef CN_API_USING_SPI
    CnApi_Spi_write(PCP_CTRLREG_LED_CTRL_OFFSET,
                    sizeof(pCtrlReg_l->m_wLedControl),
                    (BYTE*) &pCtrlReg_l->m_wLedControl);

    CnApi_Spi_write(PCP_CTRLREG_LED_CNFG_OFFSET,
                    sizeof(pCtrlReg_l->m_wLedConfig),
                    (BYTE*) &pCtrlReg_l->m_wLedConfig);
#endif /* CN_API_USING_SPI */

Exit:
    return FncRet;
}

/**
********************************************************************************
\brief  get the default gateway

This function returns the default gateway. Take care that this value can change
after the event ApCmdReadyToOperate.

\return DWORD
\retval dwDefaultGateway          the default gateway of the node
*******************************************************************************/
DWORD CnApi_getDefaultGateway(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_DEFAULT_GATEWAY_OFFSET,
                   sizeof(pCtrlReg_l->m_dwDefaultGateway),
                   (BYTE*) &pCtrlReg_l->m_dwDefaultGateway);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*)&pCtrlReg_l->m_dwDefaultGateway);
}

/******************************************************************************/
/* get/set functions library internal */

/**
********************************************************************************
\brief  set the default gateway

This function returns the default gateway. Take care that this value can change
after the event ApCmdReadyToOperate.

\param dwDefaultGateway_p            the default gateway to set
*******************************************************************************/
void CnApi_setDefaultGateway(DWORD dwDefaultGateway_p)
{
    AmiSetDwordToLe((BYTE*)&pCtrlReg_l->m_dwDefaultGateway, dwDefaultGateway_p);

#ifdef CN_API_USING_SPI
    CnApi_Spi_write(PCP_CTRLREG_DEFAULT_GATEWAY_OFFSET,
                   sizeof(pCtrlReg_l->m_dwDefaultGateway),
                   (BYTE*) &pCtrlReg_l->m_dwDefaultGateway);
#endif /* CN_API_USING_SPI */
}


/**
********************************************************************************
\brief  get event type from control register

\return WORD
\retval wEventType          the event type number
*******************************************************************************/
WORD CnApi_getEventTyp(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_EVENT_TYPE_OFFSET,
                   sizeof(pCtrlReg_l->m_wEventType),
                   (BYTE*) &pCtrlReg_l->m_wEventType);
#endif /* CN_API_USING_SPI */

    return AmiGetWordFromLe((BYTE*)&pCtrlReg_l->m_wEventType);
}

/**
********************************************************************************
\brief  set event type in control register

\param  wEventType_p        the event type to set
*******************************************************************************/
void CnApi_setEventTyp(WORD wEventType_p)
{
    AmiSetWordToLe((BYTE*)&pCtrlReg_l->m_wEventType, wEventType_p);

#ifdef CN_API_USING_SPI
    CnApi_Spi_write(PCP_CTRLREG_EVENT_TYPE_OFFSET,
                   sizeof(pCtrlReg_l->m_wEventType),
                   (BYTE*) &pCtrlReg_l->m_wEventType);
#endif /* CN_API_USING_SPI */

}

/**
********************************************************************************
\brief  get event argument from control register

\return WORD
\retval m_wEventArg          the event argument number
*******************************************************************************/
WORD CnApi_getEventArg(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_EVENT_ARG_OFFSET,
                   sizeof(pCtrlReg_l->m_wEventArg),
                   (BYTE*) &pCtrlReg_l->m_wEventArg);
#endif /* CN_API_USING_SPI */

    return AmiGetWordFromLe((BYTE*)&pCtrlReg_l->m_wEventArg);

}

/**
********************************************************************************
\brief  set event argument in control register

\param  wEventArg_p        the event argument to set
*******************************************************************************/
void CnApi_setEventArg(WORD wEventArg_p)
{
    AmiSetWordToLe((BYTE*)&pCtrlReg_l->m_wEventArg, wEventArg_p);

#ifdef CN_API_USING_SPI
    CnApi_Spi_write(PCP_CTRLREG_EVENT_ARG_OFFSET,
                   sizeof(pCtrlReg_l->m_wEventArg),
                   (BYTE*) &pCtrlReg_l->m_wEventArg);
#endif /* CN_API_USING_SPI */

}

/**
********************************************************************************
\brief  get the async interrupt control register

\return WORD
\retval wAsyncIrqControl          the async interrupt control register
*******************************************************************************/
WORD CnApi_getAsyncIrqControl(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_ASYNC_IRQ_CTRL_OFFSET,
                   sizeof(pCtrlReg_l->m_wAsyncIrqControl),
                   (BYTE*) &pCtrlReg_l->m_wAsyncIrqControl);
#endif /* CN_API_USING_SPI */

    return AmiGetWordFromLe((BYTE*)&pCtrlReg_l->m_wAsyncIrqControl);
}

/**
********************************************************************************
\brief  set the async interrupt control register

\param  wAsyncIrqControl_p        the new irq control register
*******************************************************************************/
void CnApi_setAsyncIrqControl(WORD wAsyncIrqControl_p)
{
    AmiSetWordToLe((BYTE*)&pCtrlReg_l->m_wAsyncIrqControl, wAsyncIrqControl_p);

#ifdef CN_API_USING_SPI
    CnApi_Spi_write(PCP_CTRLREG_ASYNC_IRQ_CTRL_OFFSET,
                   sizeof(pCtrlReg_l->m_wAsyncIrqControl),
                   (BYTE*) &pCtrlReg_l->m_wAsyncIrqControl);
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
 \brief acknowledges asynchronous events and IR signal

 Acknowledge the asynchronous event after the event is handled by the
 application.

 \param wAckBits_p  16 bit field, whereas a '1' indicates a
                    pending event which should be acknowledged
*******************************************************************************/
void CnApi_ackAsyncIRQEvent(WORD wAckBits_p)
{
    /* reset asserted IR signal and acknowledge events */
    AmiSetWordToLe((BYTE*)&pCtrlReg_l->m_wEventAck, wAckBits_p);

#ifdef CN_API_USING_SPI
    /* update PCP register */
    CnApi_Spi_write(PCP_CTRLREG_EVENT_ACK_OFFSET,
                   sizeof(pCtrlReg_l->m_wEventAck),
                   (BYTE*) &pCtrlReg_l->m_wEventAck);
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
 \brief reads the async ack register

\return WORD
\retval wEventAck          the async interrupt ack register
*******************************************************************************/
WORD CnApi_getAsyncAckReg(void)
{
#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_EVENT_ACK_OFFSET,
                   sizeof(pCtrlReg_l->m_wEventAck),
                   (BYTE*) &pCtrlReg_l->m_wEventAck);
#endif /* CN_API_USING_SPI */

    return AmiGetWordFromLe((BYTE*)&pCtrlReg_l->m_wEventAck);
}

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


