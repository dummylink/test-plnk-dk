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
#include <unistd.h> // for usleep()
#ifdef CN_API_USING_SPI
    #include "cnApiPdiSpi.h"
#endif

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

tPcpCtrlReg         *pCtrlReg_g;            // pointer to PCP control registers
tCnApiInitParm      *pInitParm_g;           // pointer to POWERLINK init parameters
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
    BOOL fPcpPresent = FALSE;
    int iCnt;

    /* initialize pointers */
#ifdef CN_API_USING_SPI
    int iRet = OK;
    pCtrlReg_g = &PcpCntrlRegMirror; ///< if SPI is used, take local var instead of parameter
#else
    pCtrlReg_g = (tPcpCtrlReg *)pDpram_p; ///< if no SPI is used, take parameter
#endif

    pInitParm_g = pInitParm_p;

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
#ifdef CN_API_USING_SPI
        CnApi_Spi_read(PCP_CTRLREG_MAGIC_OFFSET, sizeof(pCtrlReg_g->m_dwMagic), (BYTE*) &pCtrlReg_g->m_dwMagic);
#endif
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "\nPCP Magic value: %#08lx ..", pCtrlReg_g->m_dwMagic);
        if(PCP_MAGIC == pCtrlReg_g->m_dwMagic)
        {
            fPcpPresent = TRUE;
            break;
        }

        usleep(1000000);
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
        CnApi_Spi_read(PCP_CTRLREG_START_ADR, PCP_CTRLREG_SPAN, (BYTE*) pCtrlReg_g);
#endif /* CN_API_USING_SPI */
    }

    /* verify PDI revision */
    if (!CnApi_verifyPcpPdiRevision())
    {
        /* this compilation does not match the accessed PCP PDI */
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: PCP PDI Revision doesn't match!\n");
        FncRet = kCnApiStatusError;
        goto exit;
    }

    pCtrlReg_g->m_wState = 0xff;                                            ///< set invalid PCP state
    pCtrlReg_g->m_wCommand = kApCmdReset;                                  ///< send reboot cmd to PCP
    //pCtrlReg_g->m_dwSyncIntCycTime = 0x0000;

#ifdef CN_API_USING_SPI
    CnApi_Spi_writeByte(PCP_CTRLREG_STATE_OFFSET, pCtrlReg_g->m_wState);    ///< update pcp register
    CnApi_Spi_writeByte(PCP_CTRLREG_CMD_OFFSET, pCtrlReg_g->m_wCommand);    ///< update pcp register
    //CnApi_Spi_write(PCP_CTRLREG_SYNCIR_CYCTIME_OFFSET, sizeof(pCtrlReg_g->m_dwSyncIntCycTime), (BYTE*) &pCtrlReg_g->m_dwSyncIntCycTime);    ///< update pcp register
#endif /* CN_API_USING_SPI */

    /* initialize state machine */
    CnApi_initApStateMachine();

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

#ifdef CN_API_USING_SPI
    CnApi_Spi_write(PCP_CTRLREG_MINCYCT_OFFSET, sizeof(pCtrlReg_g->m_dwMinCycleTime), (BYTE*) &pCtrlReg_g->m_dwMinCycleTime); ///< update pcp register
    CnApi_Spi_write(PCP_CTRLREG_MAXCYCT_OFFSET, sizeof(pCtrlReg_g->m_dwMaxCycleTime), (BYTE*) &pCtrlReg_g->m_dwMaxCycleTime); ///< update pcp register
    CnApi_Spi_write(PCP_CTRLREG_MAXCYCNUM_OFFSET, sizeof(pCtrlReg_g->m_wMaxCycleNum), (BYTE*) &pCtrlReg_g->m_wMaxCycleNum); ///< update pcp register
#endif
}

/**
********************************************************************************
\brief  enable sync interrupt

CnApi_enableSyncInt() enables the synchronization interrupt at the PCP.
*******************************************************************************/
void CnApi_enableSyncInt(void)
{

    pCtrlReg_g->m_wSyncIrqControl = (1 << SYNC_IRQ_ACK); ///< acknowledge interrupt, in case it is present

#ifdef CN_API_USING_SPI
    CnApi_Spi_writeByte(PCP_CTRLREG_SYNCIRQCTRL_OFFSET, pCtrlReg_g->m_wSyncIrqControl); ///< update pcp register
#endif

#ifdef CN_API_USING_SPI
    CnApi_Spi_readByte((WORD) PCP_CTRLREG_SYNMD_OFFSET, (BYTE*) &pCtrlReg_g->m_wSyncIrqControl); ///< update struct member
#endif

    /* enable interrupt from PCP */
    pCtrlReg_g->m_wSyncIrqControl |= (1 << SYNC_IRQ_SYNC_MODE);

#ifdef CN_API_USING_SPI
    CnApi_Spi_writeByte(PCP_CTRLREG_SYNMD_OFFSET, pCtrlReg_g->m_wSyncIrqControl); ///< update pcp register
#endif
}

/**
********************************************************************************
\brief  disable sync interrupt

CnApi_disableSyncInt() disables the synchronization interrupt at the PCP.
*******************************************************************************/
void CnApi_disableSyncInt(void)
{
    static WORD test = 0;
    /* enable interrupt from PCP */
#ifdef CN_API_USING_SPI
    CnApi_Spi_readByte(PCP_CTRLREG_SYNMD_OFFSET, (BYTE*) &pCtrlReg_g->m_wSyncIrqControl); ///< update struct member, we do logic operation on it
#endif

    test &= ~(1 << SYNC_IRQ_SYNC_MODE);
    pCtrlReg_g->m_wSyncIrqControl &= ~(1 << SYNC_IRQ_SYNC_MODE);

#ifdef CN_API_USING_SPI
    CnApi_Spi_writeByte(PCP_CTRLREG_SYNMD_OFFSET, pCtrlReg_g->m_wSyncIrqControl); ///< update pcp register
#endif
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
    CnApi_Spi_read(PCP_CTRLREG_SYNCIR_CYCTIME_OFFSET, sizeof(pCtrlReg_g->m_dwSyncIntCycTime), (BYTE*) &pCtrlReg_g->m_dwSyncIntCycTime); ///< update struct element
#endif

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
    CnApi_Spi_readByte(PCP_CTRLREG_STATE_OFFSET, (BYTE*) &pCtrlReg_g->m_wState);    ///< update struct element
#endif

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
    CnApi_Spi_read(PCP_CTRLREG_MAGIC_OFFSET, sizeof(pCtrlReg_g->m_dwMagic), (BYTE*) &pCtrlReg_g->m_dwMagic); ///< update struct element
#endif

    return pCtrlReg_g->m_dwMagic;
}

/**
********************************************************************************
\brief  set the AP's command
*******************************************************************************/
void CnApi_setApCommand(BYTE bCmd_p)
{
    pCtrlReg_g->m_wCommand = bCmd_p;

#ifdef CN_API_USING_SPI
    CnApi_Spi_writeByte(PCP_CTRLREG_CMD_OFFSET, pCtrlReg_g->m_wCommand);    ///< update pcp register
#endif
}

/**
********************************************************************************
\brief  verifies the PCP PDI revision
\retval FALSE if revision number differs, TRUE if it equals
*******************************************************************************/
BOOL CnApi_verifyPcpPdiRevision(void)
{
//#ifdef CN_API_USING_SPI
//    CnApi_Spi_read(PCP_CTRLREG_STATE_OFFSET, (BYTE*) &pCtrlReg_g->m_wPcpPdiRev);    ///< update struct element
//#endif

    /* verify if this compilation of CnApi library matches the current PCP PDI */
    if (PCP_PDI_REVISION != pCtrlReg_g->m_wPcpPdiRev)
    {
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}


/* END-OF-FILE */
/******************************************************************************/

