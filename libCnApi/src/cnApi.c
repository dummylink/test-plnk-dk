/**
********************************************************************************
\file		cnApi.c

\brief		main module of CN API library

\author		Josef Baumgartner

\date		22.03.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This module contains the main module of the POWERLINK CN API library.
The CN API library provides an API for the interface of an application
processor (AP) to the POWERLINK communication processor (PCP).

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApi.h"
#include "cnApiIntern.h"

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

tPcpCtrlReg			*pCtrlReg_g;			// pointer to PCP control registers
tCnApiInitParm		*pInitParm_g;			// pointer to POWERLINK init parameters
tpfnSyncIntCb		pfnSyncIntCb = NULL;	// function pointer to sync interrupt callback
#ifdef CN_API_USING_SPI
tPcpCtrlReg     sPcPCntrlReg; ///< if SPI is used, we need a local copy of the PCP Control Register
#endif
/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief	initialize CN API

CnApi_init() is used to initialize the user API library. The function must be
called by the application in order to use the API.

\param		pDpram_p			pointer to the Dual Ported RAM (DPRAM) area
\param		pInitParm_p			pointer to the CN API initialization structure

\retval		kCnApiStatusOk		if API was successfully initialized
*******************************************************************************/
tCnApiStatus CnApi_init(BYTE *pDpram_p, tCnApiInitParm *pInitParm_p)
{
#ifdef CN_API_USING_SPI
    iRet = PDISPI_OK;
#endif
    /* initialize pointers */
#ifdef CN_API_USING_SPI
    pCtrlReg_g = &sPcPCntrlReg; ///< if SPI is used, take local var instead of parameter
#else
	pCtrlReg_g = (tPcpCtrlReg *)pDpram_p; ///< if no SPI is used, take parameter
#endif
	pInitParm_g = pInitParm_p;

	/* allocate memory */
	/* TODO if necessary! */

    pCtrlReg_g->m_bState = 0xff; 							                ///< set invalid PCP state
    pCtrlReg_g->m_bCommand = kApCmdReboot;                                  ///< send reboot cmd to PCP

#ifdef CN_API_USING_SPI
    CnApi_Spi_writeByte(PCP_CTRLREG_STATE_OFFSET, pCtrlReg_g->m_bState);    ///< update pcp register
    CnApi_Spi_writeByte(PCP_CTRLREG_CMD_OFFSET, pCtrlReg_g->m_bCommand);    ///< update pcp register

    /* initialize callback functions (implemented by user) for SPI */
    iRet = CnApi_initSpiMaster(&CnApi_CbSpiMasterTx, &CnApi_CbSpiMasterRx);
    if( iRet != PDISPI_OK )
    {
        printError(iRet, 0x01);
        goto exit;
    }
#endif

	/* initialize state machine */
	CnApi_initApStateMachine();

	return kCnApiStatusOk;

	exit:
	return kCnApiStatusError;
}

/**
********************************************************************************
\brief	exit CN API

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
\brief	initialize sync interrupt timing

CnApi_initSyncInt() is used to initialize the synchronization interrupt used by
the PCP to inform the AP that process data must be transfered. The cycle timing
of the synchronization will be calculated depending on the given parameters.

\param	wMinCycleTime_p		minimum cycle time
\param	wMaxCycleTime_p		maximum cycle time
\param	bMaxCycleNum_p		maximum number of POWERLINK cycles until a synchronization
							interrupt must occur
*******************************************************************************/
void CnApi_initSyncInt(WORD wMinCycleTime_p, WORD wMaxCycleTime_p, BYTE bMaxCycleNum_p)
{
	/* initialize interrupt cycle timing registers */
	pCtrlReg_g->m_wMinCycleTime = wMinCycleTime_p;
	pCtrlReg_g->m_wMaxCycleTime = wMaxCycleTime_p;
	pCtrlReg_g->m_bMaxCylceNum = bMaxCycleNum_p;

#ifdef CN_API_USING_SPI
    CnApi_Spi_write(PCP_CTRLREG_MINCYCT_OFFSET, sizeof(pCtrlReg_g->m_wMinCycleTime), &pCtrlReg_g->m_wMinCycleTime); ///< update pcp register
    CnApi_Spi_write(PCP_CTRLREG_MAXCYCT_OFFSET, sizeof(pCtrlReg_g->m_wMaxCycleTime), &pCtrlReg_g->m_wMaxCycleTime); ///< update pcp register
    CnApi_Spi_write(PCP_CTRLREG_MAXCYCNUM_OFFSET, sizeof(pCtrlReg_g->m_bMaxCylceNum), &pCtrlReg_g->m_bMaxCylceNum); ///< update pcp register
#endif
}

/**
********************************************************************************
\brief	enable sync interrupt

CnApi_enableSyncInt() enables the synchronization interrupt at the PCP.
*******************************************************************************/
void CnApi_enableSyncInt(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_readByte(PCP_CTRLREG_SYNMD_OFFSET, pCtrlReg_g->m_bSyncMode); ///< update struct member, we do logic operation on it
#endif

    /* enable interrupt from PCP */
    pCtrlReg_g->m_bSyncMode |= CNAPI_INT_CTRL_EN;

#ifdef CN_API_USING_SPI
    CnApi_Spi_writeByte(PCP_CTRLREG_SYNMD_OFFSET, pCtrlReg_g->m_bSyncMode); ///< update pcp register
#endif
}

/**
********************************************************************************
\brief	disable sync interrupt

CnApi_disableSyncInt() disables the synchronization interrupt at the PCP.
*******************************************************************************/
void CnApi_disableSyncInt(void)
{
    /* enable interrupt from PCP */
#ifdef CN_API_USING_SPI
    CnApi_Spi_readByte(PCP_CTRLREG_SYNMD_OFFSET, pCtrlReg_g->m_bSyncMode); ///< update struct member, we do logic operation on it
#endif

    pCtrlReg_g->m_bSyncMode &= ~CNAPI_INT_CTRL_EN;

#ifdef CN_API_USING_SPI
    CnApi_Spi_writeByte(PCP_CTRLREG_SYNMD_OFFSET, pCtrlReg_g->m_bSyncMode); ///< update pcp register
#endif
}

/**
********************************************************************************
\brief	get PCP state

CnApi_getPcpState() reads the state of the PCP and returns it.

\retval	pcpState		state of PCP
*******************************************************************************/
BYTE CnApi_getPcpState(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_readByte(PCP_CTRLREG_STATE_OFFSET, &pCtrlReg_g->m_bState);    ///< update struct element
#endif

	return pCtrlReg_g->m_bState;
}

/**
********************************************************************************
\brief	get PCP magic number

CnApi_getPcpMagic() reads the magic number stored in the PCP DPRAM area.

\retval	pcpMagic		magic number of PCP
*******************************************************************************/
DWORD CnApi_getPcpMagic(void)
{
#ifdef CN_API_USING_SPI
    CnApi_Spi_read(PCP_CTRLREG_MAGIC_OFFSET, sizeof(pCtrlReg_g->m_dwMagic), &pCtrlReg_g->m_dwMagic); ///< update struct element
#endif

	return pCtrlReg_g->m_dwMagic;
}

/**
********************************************************************************
\brief	set the AP's command
*******************************************************************************/
void CnApi_setApCommand(BYTE bCmd_p)
{
	pCtrlReg_g->m_bCommand = bCmd_p;

#ifdef CN_API_USING_SPI
    CnApi_Spi_writeByte(PCP_CTRLREG_CMD_OFFSET, pCtrlReg_g->m_bCommand);    ///< update pcp register
#endif
}




/* END-OF-FILE */
/******************************************************************************/

