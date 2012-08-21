/**
********************************************************************************
\file       cnApi.c

\brief      main module of CN API library

\author     Josef Baumgartner

\date       22.03.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This module contains the main module of the POWERLINK CN API library.
The CN API library provides an API for the interface of an application
processor (AP) to the POWERLINK communication processor (PCP).

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApi.h"
#include "cnApiIntern.h"

#include "cnApiAsync.h"
#include "cnApiPdo.h"

#ifdef __NIOS2__
#include <unistd.h>    //for usleep()
#elif defined(__MICROBLAZE__)
#include "xilinx_usleep.h"
#endif

#include "EplAmi.h"
#include "kernel/EplObdk.h"

/******************************************************************************/
/* defines */
/* wait for PCP definitions */
#define PCP_PRESENCE_RETRY_COUNT         500        ///< number of retries until abort
#define PCP_PRESENCE_RETRY_TIMEOUT_US    100000     ///< wait time in us until retry

#define SYNC_IRQ_ACK                0               ///< Sync IRQ Bit shift (for AP only)

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

volatile tPcpCtrlReg *       pCtrlReg_g;            ///< pointer to PCP control registers, Little Endian

#ifdef CN_API_USING_SPI
tPcpCtrlReg     PcpCntrlRegMirror; ///< if SPI is used, we need a local copy of the PCP Control Register
#endif

BYTE *                       pDpramBase_g;          ///< pointer to Dpram base address
tPcpInitParm *               pInitPcpParm_g;        ///< pointer to POWERLINK init parameters


/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  initialize CN API

CnApi_init() is used to initialize the user API library. The function must be
called by the application in order to use the API.

\param      tCnApiInitParm             pointer to the libCnApi initialization structure
\param      pInitParm_p                pointer to the POWERLINK initialization structure

\retval     kCnApiStatusOk      if API was successfully initialized
*******************************************************************************/
tCnApiStatus CnApi_init(tCnApiInitParm *pInitCnApiParm_p, tPcpInitParm *pInitPcpParm_p)
{
    tCnApiStatus    FncRet = kCnApiStatusOk;
    tEplKernel      EplRet = kEplSuccessful;
    BOOL            fPcpPresent = FALSE;
    int             iStatus;
    int             iCnt;
#ifdef CN_API_USING_SPI
    int iRet = OK;
#endif //CN_API_USING_SPI

    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO,"\n\nInitialize CN API functions...");

    /* initialize global pointers */
    pInitPcpParm_g = pInitPcpParm_p;    ///< make pInitParm_p global

    /* Control and Status Register is little endian */
#ifdef CN_API_USING_SPI
    pCtrlReg_g = &PcpCntrlRegMirror;         ///< if SPI is used, take local var instead of parameter
#else
    pCtrlReg_g = (tPcpCtrlReg *)pInitCnApiParm_p->m_pDpram_p;    ///< if no SPI is used, take parameter to dpram
    pDpramBase_g = pInitCnApiParm_p->m_pDpram_p;
#endif // CN_API_USING_SPI


#ifdef CN_API_USING_SPI
    /* initialize user-callback functions for SPI */
    iRet = CnApi_initSpiMaster(pInitCnApiParm_p->m_SpiMasterTxH_p, pInitCnApiParm_p->m_SpiMasterRxH_p,
            pInitCnApiParm_p->m_pfnEnableGlobalIntH_p, pInitCnApiParm_p->m_pfnDisableGlobalIntH_p);
    if( iRet != OK )
    {
        FncRet = kCnApiStatusError;
        goto exit;
    }
#endif /* CN_API_USING_SPI */

    /* check if PCP interface is present */
    for(iCnt = 0; iCnt < PCP_PRESENCE_RETRY_COUNT; iCnt++)
    {
        if(CnApi_getPcpMagic() == PCP_MAGIC)
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "\nPCP Magic value: %#08lx ..\n",
                                                CnApi_getPcpMagic());
            break;
        }
        CNAPI_USLEEP(PCP_PRESENCE_RETRY_TIMEOUT_US);
    }

    CnApi_setApCommand(kApCmdReset);

    /* check if PCP is activated */
    for(iCnt = 0; iCnt < PCP_PRESENCE_RETRY_COUNT; iCnt++)
    {
        if(CnApi_getPcpState() == kPcpStateBooted)
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "\nPCP state: %d ..",
                                                CnApi_getPcpState());
            fPcpPresent = TRUE;
            break;
        }
        CNAPI_USLEEP(PCP_PRESENCE_RETRY_TIMEOUT_US);
    }

    if(!fPcpPresent)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, ".ERROR!\n\n");

        /* PCP_PRESENCE_RETRY_COUNT exceeded */
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "TIMEOUT: PCP not responding!\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }

    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, ".OK!\n");
#ifdef CN_API_USING_SPI
    /* update PCP control register */
    CnApi_Spi_read(PCP_CTRLREG_START_ADR, PCP_CTRLREG_SPAN, (BYTE*) pCtrlReg_g);
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

    /* assign callback for all objects which don't exist in local OBD */
    EplRet = EplObdSetDefaultObdCallback(pInitCnApiParm_p->m_pfnDefaultObdAccess_p);
    if (EplRet != kEplSuccessful)
    {
        FncRet = kCnApiStatusError;
        goto exit;
    }

    /* init cnApi async event module */
    EplRet = CnApi_initAsyncEvent(pInitCnApiParm_p->m_pfnAppCbEvent);
    if (EplRet != kEplSuccessful)
    {
        FncRet = kCnApiStatusError;
        goto exit;
    }

    /* initialize state machine */
    CnApi_activateApStateMachine();

    /* initialize asynchronous transfer functions */
    iStatus = CnApiAsync_create();
    if (iStatus != OK)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "CnApiAsync_create() failed!\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }

    /* initialize PDO transfer functions */
    iStatus = CnApi_initPdo(pInitCnApiParm_p->m_pfnAppCbSync);
    if (iStatus != OK)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "CnApi_initPdo() failed!\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }

exit:
    return FncRet;
}

/**
********************************************************************************
\brief  exit CN API

CnApi_exit() is used to deinitialize and do all necessary cleanups for the
API library.
*******************************************************************************/
void CnApi_exit(void)
{
    /* free memory */
    /* TODO if necessary! */
}

/**
********************************************************************************
\brief  initialize sync interrupt timing

CnApi_initSyncInt() is used to initialize the synchronization interrupt used by
the PCP to inform the AP that process data must be transfered. The cycle timing
of the synchronization will be calculated depending on the given parameters.

\param  dwMinCycleTime_p    minimum cycle time
\param  dwMaxCycleTime_p    maximum cycle time
\param  bReserved_p         reserved for future use
*******************************************************************************/
void CnApi_initSyncInt(DWORD dwMinCycleTime_p, DWORD dwMaxCycleTime_p, BYTE bReserved_p)
{
    /* initialize interrupt cycle timing registers */
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwMinCycleTime, dwMinCycleTime_p);
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwMaxCycleTime, dwMaxCycleTime_p);
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->wCycleCalc_Reserved4, bReserved_p);


#ifdef CN_API_USING_SPI
    /* update pcp registers */
    CnApi_Spi_write(PCP_CTRLREG_MINCYCT_OFFSET,
                    sizeof(pCtrlReg_g->m_dwMinCycleTime),
                    (BYTE*) &pCtrlReg_g->m_dwMinCycleTime);
    CnApi_Spi_write(PCP_CTRLREG_MAXCYCT_OFFSET,
                    sizeof(pCtrlReg_g->m_dwMaxCycleTime),
                    (BYTE*) &pCtrlReg_g->m_dwMaxCycleTime);
    CnApi_Spi_write(PCP_CTRLREG_CYCCAL_RESERVED_OFFSET,
                    sizeof(pCtrlReg_g->wCycleCalc_Reserved4),
                    (BYTE*) &pCtrlReg_g->wCycleCalc_Reserved4);
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
                   sizeof(pCtrlReg_g->m_wSyncIrqControl),
                   (BYTE*) &pCtrlReg_g->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */

    wSyncIrqControl = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wSyncIrqControl));

    wSyncIrqControl |= (1 << SYNC_IRQ_REQ);

    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wSyncIrqControl, wSyncIrqControl);

#ifdef CN_API_USING_SPI
    /* update PCP PDI register */
    CnApi_Spi_write(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlReg_g->m_wSyncIrqControl),
                   (BYTE*) &pCtrlReg_g->m_wSyncIrqControl);
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
                   sizeof(pCtrlReg_g->m_wSyncIrqControl),
                   (BYTE*) &pCtrlReg_g->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */

    /* disable interrupt from PCP */
    wSyncIrqControl = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wSyncIrqControl));

    wSyncIrqControl &= ~(1 << SYNC_IRQ_REQ);

    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wSyncIrqControl, wSyncIrqControl);

#ifdef CN_API_USING_SPI
    /* update PCP PDI register */
    CnApi_Spi_write(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlReg_g->m_wSyncIrqControl),
                   (BYTE*) &pCtrlReg_g->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
\brief  acknowledges synchronous IRQ form PCP
*******************************************************************************/
void CnApi_ackSyncIrq(void)
{
    WORD wSyncIrqControl;

#ifdef CN_API_USING_SPI
    /* update local register copy */
    CnApi_Spi_read(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlReg_g->m_wSyncIrqControl),
                   (BYTE*) &pCtrlReg_g->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */


    wSyncIrqControl = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wSyncIrqControl));

    /* acknowledge interrupt by writing to the SYNC_IRQ_CONTROL_REGISTER*/
    wSyncIrqControl |= (1 << SYNC_IRQ_ACK);

    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wSyncIrqControl, wSyncIrqControl);

#ifdef CN_API_USING_SPI
    /* update PCP PDI register */
    CnApi_Spi_write(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlReg_g->m_wSyncIrqControl),
                   (BYTE*) &pCtrlReg_g->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
\brief  get PCP state

CnApi_getSyncIntPeriod() reads time of the periodic synchronization interrupt

\retval dwSyncIntCycTime      synchronization interrupt time of PCP
*******************************************************************************/
DWORD CnApi_getSyncIntPeriod(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_SYNCIR_CYCTIME_OFFSET,
                   sizeof(pCtrlReg_g->m_dwSyncIntCycTime),
                   (BYTE*) &pCtrlReg_g->m_dwSyncIntCycTime);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*) &(pCtrlReg_g->m_dwSyncIntCycTime));
}

/**
********************************************************************************
\brief  get PCP state

CnApi_getPcpState() reads the state of the PCP and returns it.

\retval pcpState        state of PCP
*******************************************************************************/
BYTE CnApi_getPcpState(void)
{
#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_STATE_OFFSET,
                   sizeof(pCtrlReg_g->m_wState),
                   (BYTE*) &pCtrlReg_g->m_wState);
#endif /* CN_API_USING_SPI */

    return AmiGetWordFromLe((BYTE*) &(pCtrlReg_g->m_wState));
}

/**
********************************************************************************
\brief  get PCP magic number

CnApi_getPcpMagic() reads the magic number stored in the PCP DPRAM area.

\retval pcpMagic        magic number of PCP
*******************************************************************************/
DWORD CnApi_getPcpMagic(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_MAGIC_OFFSET,
                   sizeof(pCtrlReg_g->m_dwMagic),
                   (BYTE*) &pCtrlReg_g->m_dwMagic);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*) &(pCtrlReg_g->m_dwMagic));
}

/**
********************************************************************************
\brief  get RelativeTime low

CnApi_getRelativeTimeLow() reads the RelativeTime low dword stored in the PCP DPRAM area.

\retval pcpRelativeTimeLow        RelativeTime low of PCP
*******************************************************************************/
DWORD CnApi_getRelativeTimeLow(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_RELATIVE_TIME_LOW_OFFSET,
                   sizeof(pCtrlReg_g->m_dwRelativeTimeLow),
                   (BYTE*) &pCtrlReg_g->m_dwRelativeTimeLow);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*) &(pCtrlReg_g->m_dwRelativeTimeLow));
}

/**
********************************************************************************
\brief  get RelativeTime high

CnApi_getRelativeTimeHigh() reads the RelativeTime high dword stored in the PCP DPRAM area.

\retval pcpRelativeTimeHigh        RelativeTime high of PCP
*******************************************************************************/
DWORD CnApi_getRelativeTimeHigh(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_RELATIVE_TIME_HIGH_OFFSET,
                   sizeof(pCtrlReg_g->m_dwRelativeTimeHigh),
                   (BYTE*) &pCtrlReg_g->m_dwRelativeTimeHigh);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*) &(pCtrlReg_g->m_dwRelativeTimeHigh));
}

/**
********************************************************************************
\brief  get Nettime seconds

CnApi_getNetTimeSeconds() reads the NetTime seconds stored in the PCP DPRAM area.
The Nettime value is always from the last round!

\retval pcpNetTimeSeconds        NetTime seconds of PCP
*******************************************************************************/
DWORD CnApi_getNetTimeSeconds(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_NETTIME_SEC_OFFSET,
                   sizeof(pCtrlReg_g->m_dwNetTimeSec),
                   (BYTE*) &pCtrlReg_g->m_dwNetTimeSec);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*) &(pCtrlReg_g->m_dwNetTimeSec));
}

/**
********************************************************************************
\brief  get Nettime nano seconds

CnApi_getNetTimeNanoSeconds() reads the NetTime nano seconds stored in the PCP DPRAM area.
The Nettime value is always from the last round!

\retval pcpNetTimeNanoSeconds        NetTime nano seconds of PCP
*******************************************************************************/
DWORD CnApi_getNetTimeNanoSeconds(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_NETTIME_NANOSEC_OFFSET,
                   sizeof(pCtrlReg_g->m_dwNetTimeNanoSec),
                   (BYTE*) &pCtrlReg_g->m_dwNetTimeNanoSec);
#endif /* CN_API_USING_SPI */

    return AmiGetDwordFromLe((BYTE*) &(pCtrlReg_g->m_dwNetTimeNanoSec));
}

/**
********************************************************************************
\brief  get time after sync

CnApi_getTimeAfterSync() reads the Time After Sync stored in the PCP DPRAM area.

\retval pcpTimeAfterSync        Time after sync of PCP
*******************************************************************************/
WORD CnApi_getTimeAfterSync(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_TIME_AFTER_SYNC_OFFSET,
                   sizeof(pCtrlReg_g->m_wTimeAfterSync),
                   (BYTE*) &pCtrlReg_g->m_wTimeAfterSync);
#endif /* CN_API_USING_SPI */

    return AmiGetWordFromLe((BYTE*) &(pCtrlReg_g->m_wTimeAfterSync));
}

/**
********************************************************************************
\brief  set the AP's command
*******************************************************************************/
void CnApi_setApCommand(BYTE bCmd_p)
{
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wCommand, bCmd_p);

#ifdef CN_API_USING_SPI
    CnApi_Spi_write(PCP_CTRLREG_CMD_OFFSET,
                    sizeof(pCtrlReg_g->m_wCommand),
                    (BYTE*) &pCtrlReg_g->m_wCommand);    ///< update pcp register
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
\brief  verifies the PCP PDI revision
\retval FALSE if revision number differs, TRUE if it equals
*******************************************************************************/
BOOL CnApi_verifyPcpPdiRevision(void)
{
#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_PDI_REV_OFFSET,
                   sizeof(pCtrlReg_g->m_wPcpPdiRev),
                   (BYTE*) &pCtrlReg_g->m_wPcpPdiRev);
#endif /* CN_API_USING_SPI */

    /* verify if this compilation of CnApi library matches
     * the current PCP PDI revision
     */
    if (PCP_PDI_REVISION != AmiGetWordFromLe((BYTE*) &(pCtrlReg_g->m_wPcpPdiRev)))
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
\brief  verifies the PCP FPGA's SYSTEM ID (user defined in SOPC Builder)
\retval FALSE if SYSTEM ID of this library build is not based on the current
        FPGA build SYSTEM ID , TRUE if it matches
*******************************************************************************/
BOOL CnApi_verifyPcpSystemId(void)
{
#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_PCP_SYSID_OFFSET,
                   sizeof(pCtrlReg_g->m_wPcpSysId),
                   (BYTE*) &pCtrlReg_g->m_wPcpSysId);
#endif /* CN_API_USING_SPI */

    /* verify if this compilation of CnApi library matches the current FPGA config */
    if (PCP_SYSTEM_ID != AmiGetWordFromLe((BYTE*) &(pCtrlReg_g->m_wPcpSysId)))
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

\retval m_wNodeId        Powerlink Node ID
*******************************************************************************/
WORD CnApi_getNodeId(void)
{
#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_NODE_ID_OFFSET,
                   sizeof(pCtrlReg_g->m_wNodeId),
                   (BYTE*) &pCtrlReg_g->m_wNodeId);
#endif /* CN_API_USING_SPI */


    return AmiGetWordFromLe((BYTE*) &(pCtrlReg_g->m_wNodeId));
}

/**
********************************************************************************
\brief  set POWERLINK LEDs

Sets the LED according to bLed_p to the value bOn_p

\retval bLed_p        Type of Led to set
\retval bOn_p         (TRUE = On, FALSE = Off)
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
                   sizeof(pCtrlReg_g->m_wLedControl),
                   (BYTE*) &pCtrlReg_g->m_wLedControl);

    CnApi_Spi_read(PCP_CTRLREG_LED_CNFG_OFFSET,
                   sizeof(pCtrlReg_g->m_wLedConfig),
                   (BYTE*) &pCtrlReg_g->m_wLedConfig);
#endif /* CN_API_USING_SPI */

    wLedCnf = AmiGetWordFromLe((BYTE*) &(pCtrlReg_g->m_wLedConfig));
    wLedCntrl = AmiGetWordFromLe((BYTE*) &(pCtrlReg_g->m_wLedControl));

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


    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wLedControl, wLedCntrl);
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wLedConfig, wLedCnf);

#ifdef CN_API_USING_SPI
    CnApi_Spi_write(PCP_CTRLREG_LED_CTRL_OFFSET,
                    sizeof(pCtrlReg_g->m_wLedControl),
                    (BYTE*) &pCtrlReg_g->m_wLedControl);

    CnApi_Spi_write(PCP_CTRLREG_LED_CNFG_OFFSET,
                    sizeof(pCtrlReg_g->m_wLedConfig),
                    (BYTE*) &pCtrlReg_g->m_wLedConfig);
#endif /* CN_API_USING_SPI */

Exit:
    return FncRet;
}

/* END-OF-FILE */
/******************************************************************************/

