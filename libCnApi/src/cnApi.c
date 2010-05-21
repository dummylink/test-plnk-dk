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

BYTE 				*pDpram_g;				// pointer to DPRAM
tPcpCtrlReg			*pCtrlReg_g;			// pointer to PCP control registers
tCnApiInitParm		*pInitParm_g;			// pointer to POWERLINK init parameters
tpfnSyncIntCb		pfnSyncIntCb = NULL;	// function pointer to sync interrupt callback
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
	/* initialize pointers */
	pDpram_g = pDpram_p;
	pCtrlReg_g = (tPcpCtrlReg *)pDpram_p;
	pInitParm_g = pInitParm_p;

	/* allocate memory */
	/* TODO if necessary! */

	/* initialize state machine */
	CnApi_initApStateMachine();

	return kCnApiStatusOk;
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
}

/**
********************************************************************************
\brief	enable sync interrupt

CnApi_enableSyncInt() enables the synchronization interrupt at the PCP.
*******************************************************************************/
void CnApi_enableSyncInt(void)
{
    /* enable interrupt from PCP */
    pCtrlReg_g->m_bIntCtrl |= CNAPI_INT_CTRL_EN;
}

/**
********************************************************************************
\brief	disable sync interrupt

CnApi_disableSyncInt() disables the synchronization interrupt at the PCP.
*******************************************************************************/
void CnApi_disableSyncInt(void)
{
    /* enable interrupt from PCP */
    pCtrlReg_g->m_bIntCtrl &= ~CNAPI_INT_CTRL_EN;
}

/**
********************************************************************************
\brief	get PCP state

CnApi_getPcpState() reads the state of the PCP and returns it.

\retval	pcpState		state of PCP
*******************************************************************************/
BYTE CnApi_getPcpState(void)
{
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
	return pCtrlReg_g->m_dwMagic;
}

/**
********************************************************************************
\brief	set the AP's command
*******************************************************************************/
void CnApi_setApCommand(BYTE bCmd_p)
{
	pCtrlReg_g->m_bCommand = bCmd_p;
}




/* END-OF-FILE */
/******************************************************************************/

