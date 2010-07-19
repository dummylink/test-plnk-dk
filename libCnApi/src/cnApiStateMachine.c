/**
********************************************************************************
\file		CnApiStateMachine.c

\brief		AP state machine module of CN API library

\author		Josef Baumgartner

\date		22.03.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This module contains the AP state machine implementationa of the openPOWERLINK
CN API library. The state machine implements the main state machine of an
application processor (AP).
*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApi.h"
#include "cnApiIntern.h"
#include "stateMachine.h"

#include <string.h>

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
static tStateMachine		apStateMachine;
static tState				apStates[kNumApState];
static tTransition 			apTransitions[kNumApTransitions];

static BOOL					fErrorEvent;


char	*strStateNames_l[] = { "INITIAL", "FINAL", "BOOTED", "WAIT_INIT", "INIT", "PREOP1",
		                       "PREOP2", "READY_TO_OPERATE", "OPERATIONAL", "ERROR"};

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/*============================================================================*/
/* State: BOOTED */
/*============================================================================*/
FUNC_EVT(kApStateBooted,kApStateReadyToInit, 1)
{
	/* check for PCP state: PCP_BOOTED */
	if ((CnApi_getPcpState() == kPcpStateBooted) &&
		(CnApi_getPcpMagic() == PCP_MAGIC))
		return TRUE;
	else
		return FALSE;
}
/*----------------------------------------------------------------------------*/
FUNC_ENTRYACT(kApStateBooted)
{

}
/*============================================================================*/
/* State: READY_TO_INIT */
/*============================================================================*/
FUNC_EVT(kApStateReadyToInit, kApStateInit, 1)
{
	/* check for PCP state: PCP_INIT */
	if (CnApi_getPcpState() == kPcpStateInit)
		return TRUE;
	else
		return FALSE;
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kApStateReadyToInit, kApStateError, 1)
{
	/* check for error */
	return fErrorEvent;
}
/*----------------------------------------------------------------------------*/
FUNC_ENTRYACT(kApStateReadyToInit)
{
	int		iStatus;
	DEBUG_FUNC;

	/* initialize asynchronous transfer functions */
	CnApi_initAsync((tAsyncMsg *)(pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wTxAsyncBufAdrs), pCtrlReg_g->m_wTxAsyncBufSize,
					(tAsyncMsg *)(pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wRxAsyncBufAdrs), pCtrlReg_g->m_wRxAsyncBufSize);

	/* initialize PDO transfer functions */
	CnApi_initPdo((char *)(pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_awTxPdoBufAdrs[0]), pCtrlReg_g->m_awTxPdoBufSize[0],
			      (char *)(pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_awRxPdoBufAdrs[0]), pCtrlReg_g->m_awRxPdoBufSize[0],
			      (WORD *)(pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_awTxPdoAckAdrsAp[0]), (WORD *)(pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_awRxPdoAckAdrsAp[0]),
				  (tPdoDescHeader *)(pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_awTxPdoDescAdrs[0]), pCtrlReg_g->m_wTxPdoDescSize,
			      (tPdoDescHeader *)(pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_awRxPdoDescAdrs[0]), pCtrlReg_g->m_wRxPdoDescSize);

	iStatus = CnApi_doInitPcpReq();
	DEBUG_TRACE2(DEBUG_LVL_10, "%s: status:%d\n", __func__, iStatus);
	if (iStatus == OK)
	{
		CnApi_setApCommand(kApCmdInit);
	}
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kApStateReadyToInit)
{
}

/*============================================================================*/
/* State: INIT */
/*============================================================================*/
FUNC_EVT(kApStateInit, kApStatePreop1, 1)
{
	/* check for PCP state: PCP_PREOP */
	if (CnApi_getPcpState() == kPcpStatePreop1)
	{
		CnApi_setApCommand(kApCmdNone);
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}
/*----------------------------------------------------------------------------*/
FUNC_ENTRYACT(kApStateInit)
{
	/* object creation and initialization */
	CnApi_createObjects();
	CnApi_setApCommand(kApCmdPreop);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kApStateInit)
{

}

/*============================================================================*/
/* State: PRE_OPERATIONAL1 */
/*============================================================================*/
FUNC_EVT(kApStatePreop1, kApStatePreop2, 1)
{
	/* check for PCP state: PCP_PREOP2 */
	if (CnApi_getPcpState() == kPcpStatePreop2)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}
/*----------------------------------------------------------------------------*/
FUNC_ENTRYACT(kApStatePreop1)
{

}

/*============================================================================*/
/* State: PRE_OPERATIONAL2 */
/*============================================================================*/
FUNC_EVT(kApStatePreop2, kApStateReadyToOperate, 1)
{
	/* check for PCP state: PCP_READY_TO_OPERATE */
	if (CnApi_getPcpState() == kPcpStateReadyToOperate)
	{
		CnApi_setApCommand(kApCmdNone);
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kApStatePreop2, kApStatePreop1, 1)
{
	/* check for PCP state: PCP_PREOP */
	if (CnApi_getPcpState() == kPcpStatePreop1)
		return TRUE;
	else
		return FALSE;
}
/*----------------------------------------------------------------------------*/
FUNC_ENTRYACT(kApStatePreop2)
{
	/* read PDO descriptors */
	CnApi_readPdoDesc();

	/* TODO: prepare for READY_TO_OPERATE */
	printf("***Calling Callback to prepare ready to operate!!***\n");

	CnApi_setApCommand(kApCmdReadyToOperate);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kApStatePreop2)
{
}

/*============================================================================*/
/* State: READY_TO_OPERATE */
/*============================================================================*/
FUNC_EVT(kApStateReadyToOperate, kApStateOperational, 1)
{
	/* check for PCP state: PCP_OPERATIONAL */
	if (CnApi_getPcpState() == kPcpStateOperational)
		return TRUE;
	else
		return FALSE;
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kApStateReadyToOperate, kApStatePreop1, 1)
{
	/* check for PCP state: PCP_PREOP */
	if ((CnApi_getPcpState() == kPcpStatePreop1) ||
		(CnApi_getPcpState() == kPcpStatePreop2))
		return TRUE;
	else
		return FALSE;
}
/*----------------------------------------------------------------------------*/
FUNC_ENTRYACT(kApStateReadyToOperate)
{

}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kApStateReadyToOperate)
{
}

/*============================================================================*/
/* State: OPERATIONAL */
/*============================================================================*/
FUNC_EVT(kApStateOperational, kApStateInit, 1)
{
	return FALSE;
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kApStateOperational, kApStatePreop1, 1)
{
	/* check for PCP state: PCP_PREOP */
	if (CnApi_getPcpState() == kPcpStatePreop1)
		return TRUE;
	else
		return FALSE;
}
/*----------------------------------------------------------------------------*/
FUNC_ENTRYACT(kApStateOperational)
{

}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kApStateOperational)
{
}

/*============================================================================*/
/* State: ERROR */
/*============================================================================*/
/*----------------------------------------------------------------------------*/
FUNC_ENTRYACT(kApStateError)
{

}

/**
********************************************************************************
\brief	state change hookup
*******************************************************************************/
static void stateChange(BYTE current, BYTE target)
{
	BYTE	currentIdx, targetIdx;

	currentIdx = current + 2;
	targetIdx = target + 2;

	printf ("STATE: %s->%s\n", strStateNames_l[currentIdx], strStateNames_l[targetIdx]);
}

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief	initialize AP state machine
*******************************************************************************/
void CnApi_initApStateMachine(void)
{
	DEBUG_TRACE1(DEBUG_LVL_09, "%s:\n", __func__);

	/* initialize state machine */
	sm_init(&apStateMachine, apStates, kNumApState, apTransitions,
			kNumApTransitions, kApStateBooted, stateChange);

	/* build up states */

	/* State: BOOTED */
	SM_ADD_TRANSITION(&apStateMachine, kApStateBooted, kApStateReadyToInit, 1);
	SM_ADD_ACTION_100(&apStateMachine, kApStateBooted);

	/* State: READY_TO_INIT */
	SM_ADD_TRANSITION(&apStateMachine, kApStateReadyToInit, kApStateInit, 1);
	SM_ADD_TRANSITION(&apStateMachine, kApStateReadyToInit, kApStateError, 1);
	SM_ADD_ACTION_110(&apStateMachine, kApStateReadyToInit);

	/* State: INIT */
	SM_ADD_TRANSITION(&apStateMachine, kApStateInit, kApStatePreop1, 1);
	SM_ADD_ACTION_110(&apStateMachine, kApStateInit);

	/* State: PREOP1 */
	SM_ADD_TRANSITION(&apStateMachine, kApStatePreop1, kApStatePreop2, 1);
	SM_ADD_ACTION_100(&apStateMachine, kApStatePreop1);

	/* State: PREOP2 */
	SM_ADD_TRANSITION(&apStateMachine, kApStatePreop2, kApStateReadyToOperate, 1);
	SM_ADD_TRANSITION(&apStateMachine, kApStatePreop2, kApStatePreop1, 1);
	SM_ADD_ACTION_110(&apStateMachine, kApStatePreop2);

	/* State: READY_TO_OPERATE */
	SM_ADD_TRANSITION(&apStateMachine, kApStateReadyToOperate, kApStateOperational, 1);
	SM_ADD_TRANSITION(&apStateMachine, kApStateReadyToOperate, kApStatePreop1, 1);
	SM_ADD_ACTION_110(&apStateMachine, kApStateReadyToOperate);

	/* State: OPERATIONAL */
	SM_ADD_TRANSITION(&apStateMachine, kApStateOperational, kApStateInit, 1);
	SM_ADD_TRANSITION(&apStateMachine, kApStateOperational, kApStatePreop1, 1);
	SM_ADD_ACTION_110(&apStateMachine, kApStateOperational);

	/* State: ERROR */
	SM_ADD_ACTION_100(&apStateMachine, kApStateError);
}

/**
********************************************************************************
\brief	start CN state machine
*******************************************************************************/
void CnApi_activateApStateMachine(void)
{
	sm_reset(&apStateMachine);
	fErrorEvent = FALSE;
}

/**
********************************************************************************
\brief	CN API process state machine

CnApi_process() updates the state machine. It has be called periodically.

\return	returns TRUE if state machine is active and FALS if is inactive or ended
*******************************************************************************/
BOOL CnApi_processApStateMachine(void)
{
	return sm_update(&apStateMachine);
}

/* END-OF-FILE */
/******************************************************************************/

