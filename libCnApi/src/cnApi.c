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
#include "kernel/EplObdk.h"
#include <unistd.h> // for usleep()
#ifdef CN_API_USING_SPI
    #include "cnApiPdiSpi.h"
#endif

#ifdef AP_IS_BIG_ENDIAN
   #include "EplAmi.h"
#endif

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

tPcpCtrlReg      * volatile pCtrlReg_g;            // pointer to PCP control registers, CPU Endian
tPcpCtrlReg      * volatile pCtrlRegLE_g;          // pointer to PCP control registers, Little Endian
tCnApiInitParm   * volatile pInitParm_g;           // pointer to POWERLINK init parameters, CPU Endian
tCnApiInitParm   * volatile pInitParmLE_g;         // pointer to POWERLINK init parameters, Little Endian

#ifdef AP_IS_BIG_ENDIAN
tPcpCtrlReg          LclCtrlRegBE_g;  // local copy of PCP Control Register, Big Endian
tCnApiInitParm       LclInitParmLE_g; // local copy of Init Parameters, Little Endian
#endif // AP_IS_BIG_ENDIAN

tpfnSyncIntCb       pfnSyncIntCb = NULL;    // function pointer to sync interrupt callback
#ifdef CN_API_USING_SPI
tPcpCtrlReg     PcpCntrlRegMirror; ///< if SPI is used, we need a local copy of the PCP Control Register
#endif
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

\param      pDpram_p            pointer to the Dual Ported RAM (DPRAM) area
\param      pInitParm_p         pointer to the CN API initialization structure

\retval     kCnApiStatusOk      if API was successfully initialized
*******************************************************************************/
tCnApiStatus CnApi_init(BYTE *pDpram_p, tCnApiInitParm *pInitParm_p)
{
    tCnApiStatus FncRet = kCnApiStatusOk;
    tEplKernel EplRet = kEplSuccessful;
    BOOL fPcpPresent = FALSE;
    int     iStatus;
    int iCnt;

    TRACE("\n\nInitialize CN API functions...");

    /* initialize global pointers */

    /* Control and Status Register is mirrored, Pointer shows CPU Endian Mirror */
#ifdef CN_API_USING_SPI
   int iRet = OK;

   /// if SPI is used, take local var instead of parameter
   #ifdef AP_IS_LITTLE_ENDIAN
      pCtrlReg_g = &PcpCntrlRegMirror;
      pCtrlRegLE_g = pCtrlReg_g;
   #else // AP_IS_BIG_ENDIAN
      pCtrlReg_g = &LclCtrlRegBE_g;
      pCtrlRegLE_g = &PcpCntrlRegMirror;
   #endif // AP_IS_LITTLE_ENDIAN

#else // CN_API_USING_SPI

   ///< if no SPI is used, take parameter to dpram
   #ifdef AP_IS_LITTLE_ENDIAN
      pCtrlReg_g = (tPcpCtrlReg *)pDpram_p;
      pCtrlRegLE_g = pCtrlReg_g;
   #else // AP_IS_BIG_ENDIAN
      pCtrlReg_g = &LclCtrlRegBE_g;
      pCtrlRegLE_g = (tPcpCtrlReg *)pDpram_p;
   #endif // AP_IS_LITTLE_ENDIAN

#endif // CN_API_USING_SPI

#ifdef AP_IS_LITTLE_ENDIAN
    pInitParm_g = pInitParm_p; ///< global init Param is "CPU" Endian, however
    pInitParmLE_g = pInitParm_g;
#else // AP_IS_BIG_ENDIAN
    pInitParm_g = pInitParm_p; ///< global init Param is "CPU" Endian, however
    pInitParmLE_g = &LclInitParmLE_g; ///< Little Endian Copy of Init Param
    LclInitParmLE_g = *pInitParm_g; ///< copy all Init params (bytes..)
    /// Convert the init params to little endian
    pInitParmLE_g->m_wIsoRxMaxPayload = AmiGetWordToLe((BYTE*) &pInitParm_g->m_wIsoRxMaxPayload);
    pInitParmLE_g->m_wIsoTxMaxPayload = AmiGetWordToLe((BYTE*) &pInitParm_g->m_wIsoTxMaxPayload);
    pInitParmLE_g->m_dwAsendMaxLatency = AmiGetDwordToLe((BYTE*) &pInitParm_g->m_dwAsendMaxLatency);
    pInitParmLE_g->m_dwDeviceType = AmiGetDwordToLe((BYTE*) &pInitParm_g->m_dwDeviceType);
    pInitParmLE_g->m_dwDpramBase = AmiGetDwordToLe((BYTE*) &pInitParm_g->m_dwDpramBase);
    pInitParmLE_g->m_dwFeatureFlags = AmiGetDwordToLe((BYTE*) &pInitParm_g->m_dwFeatureFlags);
    pInitParmLE_g->m_dwPresMaxLatency = AmiGetDwordToLe((BYTE*) &pInitParm_g->m_dwPresMaxLatency);
    pInitParmLE_g->m_dwProductCode = AmiGetDwordToLe((BYTE*) &pInitParm_g->m_dwProductCode);
    pInitParmLE_g->m_dwRevision = AmiGetDwordToLe((BYTE*) &pInitParm_g->m_dwRevision);
    pInitParmLE_g->m_dwSerialNum = AmiGetDwordToLe((BYTE*) &pInitParm_g->m_dwSerialNum);
    pInitParmLE_g->m_dwVendorId = AmiGetDwordToLe((BYTE*) &pInitParm_g->m_dwVendorId);
#endif // AP_IS_LITTLE_ENDIAN

#ifdef CN_API_USING_SPI
    /* initialize user-callback functions for SPI */
    iRet = CnApi_initSpiMaster(&CnApi_CbSpiMasterTx, &CnApi_CbSpiMasterRx);
    if( iRet != OK )
    {
        FncRet = kCnApiStatusError;
        goto exit;
    }
#endif /* CN_API_USING_SPI */

    /* check if PCP interface is present */
    for(iCnt = 0; iCnt < PCP_PRESENCE_TIMEOUT; iCnt++)
    {
        if(PCP_MAGIC == CnApi_getPcpMagic())
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "\nPCP Magic value: %#08lx ..", pCtrlReg_g->m_dwMagic);
            fPcpPresent = TRUE;
            break;
        }
        else
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "\nPCP Magic value: %#08lx ..", pCtrlReg_g->m_dwMagic);
        }
        CNAPI_USLEEP(1000000);
    }

    if(!fPcpPresent)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, ".ERROR!\n\n");

        /* PCP_PRESENCE_TIMEOUT exceeded */
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "TIMEOUT: No connection to PCP! Reading PDI failed!\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }
    else
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, ".OK!\n");
#ifdef CN_API_USING_SPI
        /* update PCP control register */
        CnApi_Spi_read(PCP_CTRLREG_START_ADR, PCP_CTRLREG_SPAN, (BYTE*) pCtrlRegLE_g);
#endif /* CN_API_USING_SPI */

#ifdef AP_IS_BIG_ENDIAN
        CnApi_GetCntrlRegfromLe(pCtrlReg_g, pCtrlRegLE_g);
#endif

    }

    /* verify FPGA configuration ID */
    if (!CnApi_verifyFpgaConfigId())
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

    pCtrlReg_g->m_wState = kPcpStateInvalid;      ///< set invalid PCP state

#ifdef AP_IS_BIG_ENDIAN
    pCtrlRegLE_g->m_wState   = AmiGetWordToLe((BYTE*)&pCtrlReg_g->m_wState);
    pCtrlRegLE_g->m_wCommand = AmiGetWordToLe((BYTE*)&pCtrlReg_g->m_wCommand);
#endif // AP_IS_BIG_ENDIAN

#ifdef CN_API_USING_SPI
    /* update PCP state register */
    CnApi_Spi_write(PCP_CTRLREG_STATE_OFFSET,
                    sizeof(pCtrlRegLE_g->m_wState),
                    (BYTE*) &pCtrlRegLE_g->m_wState);
    /* update PCP command register */
    CnApi_Spi_write(PCP_CTRLREG_CMD_OFFSET,
                    sizeof(pCtrlRegLE_g->m_wCommand),
                    (BYTE*) &pCtrlRegLE_g->m_wCommand);
#endif /* CN_API_USING_SPI */

    /* assign callback for all objects which don't exist in local OBD */
    EplRet = EplObdSetDefaultObdCallback(CnApi_CbDefaultObdAccess);
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
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "CnApiAsync_create() failed!\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }

    /* initialize PDO transfer functions */
    iStatus = CnApi_initPdo();
    if (iStatus != OK)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "CnApi_initPdo() failed!\n");
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

\param  dwMinCycleTime_p     minimum cycle time
\param  dwMaxCycleTime_p     maximum cycle time
\param  bMaxCycleNum_p      maximum number of POWERLINK cycles until a synchronization
                            interrupt must occur
*******************************************************************************/
void CnApi_initSyncInt(DWORD dwMinCycleTime_p, DWORD dwMaxCycleTime_p, BYTE bMaxCycleNum_p)
{
    /* initialize interrupt cycle timing registers */
    pCtrlReg_g->m_dwMinCycleTime = dwMinCycleTime_p;
    pCtrlReg_g->m_dwMaxCycleTime = dwMaxCycleTime_p;
    pCtrlReg_g->m_wMaxCycleNum = bMaxCycleNum_p;

#ifdef AP_IS_BIG_ENDIAN
    pCtrlRegLE_g->m_dwMinCycleTime = AmiGetWordToLe((BYTE*)&(pCtrlReg_g->m_dwMinCycleTime));
    pCtrlRegLE_g->m_dwMaxCycleTime = AmiGetDwordToLe((BYTE*)&(pCtrlReg_g->m_dwMaxCycleTime));
    pCtrlRegLE_g->m_wMaxCycleNum = AmiGetWordToLe((BYTE*)&(pCtrlReg_g->m_wMaxCycleNum));
#endif // AP_IS_BIG_ENDIAN

#ifdef CN_API_USING_SPI
    /* update pcp registers */
    CnApi_Spi_write(PCP_CTRLREG_MINCYCT_OFFSET,
                    sizeof(pCtrlRegLE_g->m_dwMinCycleTime),
                    (BYTE*) &pCtrlRegLE_g->m_dwMinCycleTime);
    CnApi_Spi_write(PCP_CTRLREG_MAXCYCT_OFFSET,
                    sizeof(pCtrlRegLE_g->m_dwMaxCycleTime),
                    (BYTE*) &pCtrlRegLE_g->m_dwMaxCycleTime);
    CnApi_Spi_write(PCP_CTRLREG_MAXCYCNUM_OFFSET,
                    sizeof(pCtrlRegLE_g->m_wMaxCycleNum),
                    (BYTE*) &pCtrlRegLE_g->m_wMaxCycleNum);
#endif
}

/**
********************************************************************************
\brief  enable sync interrupt

CnApi_enableSyncInt() enables the synchronization interrupt at the PCP.
*******************************************************************************/
void CnApi_enableSyncInt(void)
{
#ifdef CN_API_USING_SPI
    /* update local register copy */
    CnApi_Spi_read(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlRegLE_g->m_wSyncIrqControl),
                   (BYTE*) &pCtrlRegLE_g->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */

#ifdef AP_IS_BIG_ENDIAN
    pCtrlReg_g->m_wSyncIrqControl = AmiGetWordFromLe((BYTE*)&(pCtrlRegLE_g->m_wSyncIrqControl));
#endif // AP_IS_BIG_ENDIAN

    /* enable interrupt from PCP */
    pCtrlReg_g->m_wSyncIrqControl |= (1 << SYNC_IRQ_REQ);

#ifdef AP_IS_BIG_ENDIAN
    pCtrlRegLE_g->m_wSyncIrqControl = AmiGetWordToLe((BYTE*)&(pCtrlReg_g->m_wSyncIrqControl));
#endif // AP_IS_BIG_ENDIAN

#ifdef CN_API_USING_SPI
    /* update PCP PDI register */
    CnApi_Spi_write(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlRegLE_g->m_wSyncIrqControl),
                   (BYTE*) &pCtrlRegLE_g->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
\brief  disable sync interrupt

CnApi_disableSyncInt() disables the synchronization interrupt at the PCP.
*******************************************************************************/
void CnApi_disableSyncInt(void)
{
#ifdef CN_API_USING_SPI
    /* update local register copy */
    CnApi_Spi_read(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlRegLE_g->m_wSyncIrqControl),
                   (BYTE*) &pCtrlRegLE_g->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */

#ifdef AP_IS_BIG_ENDIAN
    pCtrlReg_g->m_wSyncIrqControl = AmiGetWordFromLe((BYTE*)&(pCtrlRegLE_g->m_wSyncIrqControl));
#endif // AP_IS_BIG_ENDIAN

    /* disable interrupt from PCP */
    pCtrlReg_g->m_wSyncIrqControl &= ~(1 << SYNC_IRQ_REQ);

#ifdef AP_IS_BIG_ENDIAN
    pCtrlRegLE_g->m_wSyncIrqControl = AmiGetWordToLe((BYTE*)&(pCtrlReg_g->m_wSyncIrqControl));
#endif // AP_IS_BIG_ENDIAN

#ifdef CN_API_USING_SPI
    /* update PCP PDI register */
    CnApi_Spi_write(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlRegLE_g->m_wSyncIrqControl),
                   (BYTE*) &pCtrlRegLE_g->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
\brief  acknowledges synchronous IRQ form PCP
*******************************************************************************/
void CnApi_ackSyncIrq(void)
{
#ifdef CN_API_USING_SPI
    /* update local register copy */
    CnApi_Spi_read(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlRegLE_g->m_wSyncIrqControl),
                   (BYTE*) &pCtrlRegLE_g->m_wSyncIrqControl);
#endif /* CN_API_USING_SPI */

#ifdef AP_IS_BIG_ENDIAN
    pCtrlReg_g->m_wSyncIrqControl = AmiGetWordFromLe((BYTE*)&(pCtrlRegLE_g->m_wSyncIrqControl));
#endif // AP_IS_BIG_ENDIAN

    /* acknowledge interrupt by writing to the SYNC_IRQ_CONTROL_REGISTER*/
    pCtrlReg_g->m_wSyncIrqControl |= (1 << SYNC_IRQ_ACK);

#ifdef AP_IS_BIG_ENDIAN
    pCtrlRegLE_g->m_wSyncIrqControl = AmiGetWordToLe((BYTE*)&(pCtrlReg_g->m_wSyncIrqControl));
#endif // AP_IS_BIG_ENDIAN

#ifdef CN_API_USING_SPI
    /* update PCP PDI register */
    CnApi_Spi_write(PCP_CTRLREG_SYNCIRQCTRL_OFFSET,
                   sizeof(pCtrlRegLE_g->m_wSyncIrqControl),
                   (BYTE*) &pCtrlRegLE_g->m_wSyncIrqControl);
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
                   sizeof(pCtrlRegLE_g->m_dwSyncIntCycTime),
                   (BYTE*) &pCtrlRegLE_g->m_dwSyncIntCycTime);
#endif /* CN_API_USING_SPI */

#ifdef AP_IS_BIG_ENDIAN
    pCtrlReg_g->m_dwSyncIntCycTime = AmiGetWordFromLe((BYTE*) &(pCtrlRegLE_g->m_dwSyncIntCycTime));
#endif // AP_IS_BIG_ENDIAN

    return pCtrlReg_g->m_dwSyncIntCycTime;
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
                   sizeof(pCtrlRegLE_g->m_wState),
                   (BYTE*) &pCtrlRegLE_g->m_wState);
#endif /* CN_API_USING_SPI */

#ifdef AP_IS_BIG_ENDIAN
    pCtrlReg_g->m_wState = AmiGetWordFromLe((BYTE*) &(pCtrlRegLE_g->m_wState));
#endif // AP_IS_BIG_ENDIAN

    return pCtrlReg_g->m_wState;
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
                   sizeof(pCtrlRegLE_g->m_dwMagic),
                   (BYTE*) &pCtrlRegLE_g->m_dwMagic);
#endif /* CN_API_USING_SPI */

#ifdef AP_IS_BIG_ENDIAN
    pCtrlReg_g->m_dwMagic = AmiGetDwordFromLe((BYTE*) &(pCtrlRegLE_g->m_dwMagic));
#endif // AP_IS_BIG_ENDIAN

    return pCtrlReg_g->m_dwMagic;
}

/**
********************************************************************************
\brief  set the AP's command
*******************************************************************************/
void CnApi_setApCommand(BYTE bCmd_p)
{
    pCtrlReg_g->m_wCommand = bCmd_p;

#ifdef AP_IS_BIG_ENDIAN
    pCtrlRegLE_g->m_wCommand = AmiGetWordToLe((BYTE*)&(pCtrlReg_g->m_wCommand));
#endif // AP_IS_BIG_ENDIAN

#ifdef CN_API_USING_SPI
    CnApi_Spi_write(PCP_CTRLREG_CMD_OFFSET,
                    sizeof(pCtrlRegLE_g->m_wCommand),
                    (BYTE*) &pCtrlRegLE_g->m_wCommand);    ///< update pcp register
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
                   sizeof(pCtrlRegLE_g->m_wPcpPdiRev),
                   (BYTE*) &pCtrlRegLE_g->m_wPcpPdiRev);
#endif /* CN_API_USING_SPI */

#ifdef AP_IS_BIG_ENDIAN
    pCtrlReg_g->m_wPcpPdiRev = AmiGetWordFromLe((BYTE*) &(pCtrlRegLE_g->m_wPcpPdiRev));
#endif // AP_IS_BIG_ENDIAN

    /* verify if this compilation of CnApi library matches
     * the current PCP PDI revision
     */
    if (PCP_PDI_REVISION != pCtrlReg_g->m_wPcpPdiRev)
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
BOOL CnApi_verifyFpgaConfigId(void)
{
#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_FPGA_SYSID_OFFSET,
                   sizeof(pCtrlRegLE_g->m_dwFpgaSysId),
                   (BYTE*) &pCtrlRegLE_g->m_dwFpgaSysId);
#endif /* CN_API_USING_SPI */

#ifdef AP_IS_BIG_ENDIAN
    pCtrlReg_g->m_dwFpgaSysId = AmiGetDwordFromLe((BYTE*) &(pCtrlRegLE_g->m_dwFpgaSysId));
#endif // AP_IS_BIG_ENDIAN

    /* verify if this compilation of CnApi library matches the current FPGA config */
    if (PCP_FPGA_SYSID_ID != pCtrlReg_g->m_dwFpgaSysId)
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
                   sizeof(pCtrlRegLE_g->m_wNodeId),
                   (BYTE*) &pCtrlRegLE_g->m_wNodeId);
#endif /* CN_API_USING_SPI */

#ifdef AP_IS_BIG_ENDIAN
    pCtrlReg_g->m_wNodeId = AmiGetDwordFromLe((BYTE*) &(pCtrlRegLE_g->m_wNodeId));
#endif // AP_IS_BIG_ENDIAN


    return pCtrlReg_g->m_wNodeId;
}

#ifdef AP_IS_BIG_ENDIAN
/**
 ********************************************************************************
 \brief copy control register values from little endian byte order to platform
        byte order
 \param pDest_p     platform byte order destination address
 \param pSrcLE_p    little endian byte order source address

 *******************************************************************************/
void CnApi_GetCntrlRegfromLe(tPcpCtrlReg * pDest_p, tPcpCtrlReg * pSrcLE_p)
{
        /* Read whole PCP Control Register to platform byte order */
        pDest_p->m_dwMagic           = AmiGetDwordFromLe((BYTE*)&pSrcLE_p->m_dwMagic);
        pDest_p->m_wPcpPdiRev        = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wPcpPdiRev);
        pDest_p->m_dwFpgaSysId       = AmiGetDwordFromLe((BYTE*)&pSrcLE_p->m_dwFpgaSysId);
        pDest_p->m_wNodeId           = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wNodeId);
        pDest_p->m_wCommand          = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wCommand);
        pDest_p->m_wState            = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wState);
        pDest_p->m_dwMaxCycleTime    = AmiGetDwordFromLe((BYTE*)&pSrcLE_p->m_dwMaxCycleTime);
        pDest_p->m_dwMinCycleTime    = AmiGetDwordFromLe((BYTE*)&pSrcLE_p->m_dwMinCycleTime);
        pDest_p->m_wCycleCorrect     = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wCycleCorrect);
        pDest_p->m_wMaxCycleNum      = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wMaxCycleNum);
        pDest_p->m_dwSyncIntCycTime  = AmiGetDwordFromLe((BYTE*)&pSrcLE_p->m_dwSyncIntCycTime);
        pDest_p->m_wEventType        = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wEventType);
        pDest_p->m_wEventArg         = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wEventArg);
        pDest_p->m_wAsyncIrqControl  = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wAsyncIrqControl);
        pDest_p->m_wEventAck         = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wEventAck);
        pDest_p->m_wTxPdo0BufSize    = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wTxPdo0BufSize);
        pDest_p->m_wTxPdo0BufAoffs   = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wTxPdo0BufAoffs);
        pDest_p->m_wRxPdo0BufSize    = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxPdo0BufSize);
        pDest_p->m_wRxPdo0BufAoffs   = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxPdo0BufAoffs);
        pDest_p->m_wRxPdo1BufSize    = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxPdo1BufSize);
        pDest_p->m_wRxPdo1BufAoffs   = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxPdo1BufAoffs);
        pDest_p->m_wRxPdo2BufSize    = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxPdo2BufSize);
        pDest_p->m_wRxPdo2BufAoffs   = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxPdo2BufAoffs);
        pDest_p->m_wTxAsyncBuf0Size  = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wTxAsyncBuf0Size);
        pDest_p->m_wTxAsyncBuf0Aoffs = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wTxAsyncBuf0Aoffs);
        pDest_p->m_wRxAsyncBuf0Size  = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxAsyncBuf0Size);
        pDest_p->m_wRxAsyncBuf0Aoffs = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxAsyncBuf0Aoffs);
        pDest_p->m_wTxAsyncBuf1Size  = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wTxAsyncBuf1Size);
        pDest_p->m_wTxAsyncBuf1Aoffs = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wTxAsyncBuf1Aoffs);
        pDest_p->m_wRxAsyncBuf1Size  = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxAsyncBuf1Size);
        pDest_p->m_wRxAsyncBuf1Aoffs = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxAsyncBuf1Aoffs);
        pDest_p->m_wTxPdo0Ack        = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wTxPdo0Ack);
        pDest_p->m_wRxPdo0Ack        = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxPdo0Ack);
        pDest_p->m_wRxPdo1Ack        = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxPdo1Ack);
        pDest_p->m_wRxPdo2Ack        = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wRxPdo2Ack);
        pDest_p->m_wSyncIrqControl   = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wSyncIrqControl);
        pDest_p->m_wLedControl       = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wLedControl);
        pDest_p->m_wLedConfig        = AmiGetWordFromLe((BYTE*)&pSrcLE_p->m_wLedConfig);
}
#endif //AP_IS_BIG_ENDIAN

/* END-OF-FILE */
/******************************************************************************/

