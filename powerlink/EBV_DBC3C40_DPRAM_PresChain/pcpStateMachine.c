/**
********************************************************************************
\file		PcpStateMachine.c

\brief		Pcp state machine implementation of generic interface

\author		Josef Baumgartner

\date		12.04.2010

ApStateMachine.c contains the implementation of the PCP state machine of the
POWERLINK CN generic interface.
*******************************************************************************/

/******************************************************************************/
/* includes */
#include "Epl.h"

#include "pcpStateMachine.h"
#include "stateMachine.h"
#include "cnApi.h"
#include "pcp.h"

#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
static tStateMachine		pcpStateMachine_l;
static tState				aPcpStates_l[kNumPcpStates];
static tTransition 			aPcpTransitions_l[kNumPcpTransitions];
static BOOL					fEvent = FALSE;
static tPowerlinkEvent		powerlinkEvent;


char	*strStateNames_l[] = { "INITIAL", "FINAL", "BOOTED", "INIT", "PREOP1", "PREOP2", "READY_TO_OPERATE", "OPERATIONAL"};


/******************************************************************************/
/* function declarations */
static BOOL checkPowerlinkEvent(tPowerlinkEvent event_p);
static BOOL checkApCommand(BYTE cmd_p);
static BOOL checkEvent(void);

/******************************************************************************/
/* private functions */

/**
********************************************************************************
\brief	check for powerlink event
*******************************************************************************/
static BOOL checkPowerlinkEvent(tPowerlinkEvent event_p)
{
	if (event_p == powerlinkEvent)
	{
		powerlinkEvent = kPowerlinkEventNone;
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

/**
********************************************************************************
\brief	check for powerlink event
*******************************************************************************/
static BOOL checkApCommand(BYTE cmd_p)
{
	if (getCommandFromAp() == cmd_p)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

/**
********************************************************************************
\brief	check for event
*******************************************************************************/
static BOOL checkEvent(void)
{
	if (fEvent)
	{
		fEvent = FALSE;
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}


/*******************************************************************************
 State machine functions

 The following section contains the event and action functions for the PCP
 state machine.
*******************************************************************************/
/*============================================================================*/
/* State: BOOTED */
/*============================================================================*/
FUNC_ENTRYACT(kPcpStateBooted)
{
	IOWR_ALTERA_AVALON_PIO_DATA(STATUS_LED_PIO_BASE, 0xfe);
	storePcpState(kPcpStateBooted);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPcpStateBooted)
{
	int iStatus;

	Gi_pollAsync();
	if (checkApCommand(kApCmdInit))
	{
		DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "%s: get ApCmdInit\n", __func__);
		iStatus = initPowerlink(&initParm_g);
		if (iStatus == kEplSuccessful)
		{
			fEvent = TRUE;
		}
	}
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateBooted,kPcpStateInit,1)
{
	return checkEvent();
}

/*============================================================================*/
/* State: INIT */
/*============================================================================*/
FUNC_ENTRYACT(kPcpStateInit)
{
	storePcpState(kPcpStateInit);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPcpStateInit)
{
	int		iStatus;

	Gi_pollAsync();
	if (checkApCommand(kApCmdPreop))
	{
		DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "%s: get ApCmdPreop\n", __func__);
		iStatus = startPowerlink();
		if (iStatus == kEplSuccessful)
		{
			fEvent = TRUE;
		}
	}
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateInit,kPcpStatePreop1,1)
{
	return checkEvent();
}

/*============================================================================*/
/* State: PRE_OPERATIONAL1 */
/*============================================================================*/
FUNC_ENTRYACT(kPcpStatePreop1)
{
	storePcpState(kPcpStatePreop1);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPcpStatePreop1)
{
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStatePreop1,kPcpStatePreop2,1)
{
	return checkPowerlinkEvent(kPowerlinkEventEnterPreop2);
}

/*============================================================================*/
/* State: PRE_OPERATIONAL2 */
/*============================================================================*/
FUNC_ENTRYACT(kPcpStatePreop2)
{
	storePcpState(kPcpStatePreop2);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPcpStatePreop2)
{

}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStatePreop2,kPcpStateReadyToOperate,1)
{
	return checkApCommand(kApCmdReadyToOperate);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStatePreop2,kPcpStatePreop1,1)
{
	return checkPowerlinkEvent(kPowerlinkEventReset);
}

/*============================================================================*/
/* State: READY_TO_OPERATE */
/*============================================================================*/
FUNC_ENTRYACT(kPcpStateReadyToOperate)
{
	storePcpState(kPcpStateReadyToOperate);
	EplNmtuNmtEvent(kEplNmtEventEnterReadyToOperate);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPcpStateReadyToOperate)
{
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateReadyToOperate,kPcpStateOperational,1)
{
	return checkPowerlinkEvent(kPowerlinkEventEnterOperational);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateReadyToOperate,kPcpStatePreop1,1)
{
	return checkPowerlinkEvent(kPowerlinkEventReset);
}

/*============================================================================*/
/* State: Operational */
/*============================================================================*/
FUNC_ENTRYACT(kPcpStateOperational)
{
	storePcpState(kPcpStateOperational);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPcpStateOperational)
{
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateOperational,kPcpStateBooted,1)
{
	return FALSE;
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateOperational,kPcpStatePreop1,1)
{
	return checkPowerlinkEvent(kPowerlinkEventReset);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateOperational,STATE_FINAL,1)
{
	return FALSE;
}

/**
********************************************************************************
\brief	state change hook
*******************************************************************************/
static void stateChange(BYTE current, BYTE target)
{
	BYTE	currentIdx, targetIdx;

	currentIdx = current + 2;
	targetIdx = target + 2;

	DEBUG_TRACE2 (DEBUG_LVL_CNAPI_INFO, "STATE: %s->%s\n", strStateNames_l[currentIdx], strStateNames_l[targetIdx]);
}

/******************************************************************************/
/* public functions */

/**
********************************************************************************
\brief	initialize state machine

detailed_function_description

\param		parameter			parameter_description

\return		return
\retval		return_value			return_value_description
*******************************************************************************/
void initStateMachine(void)
{
	DEBUG_FUNC;

	/* initialize state machine */
	sm_init(&pcpStateMachine_l, aPcpStates_l, kNumPcpStates, aPcpTransitions_l,
			kNumPcpTransitions, kPcpStateBooted, stateChange);

	/***** build up states ******/
	/* state: BOOTED */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateBooted, kPcpStateInit, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStateBooted);

	/* state: INIT */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateInit, kPcpStatePreop1, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStateInit);

	/* state: PREOP */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStatePreop1, kPcpStatePreop2, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStatePreop1);

	/* state: WAIT_READY_TO_OPERATE */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStatePreop2, kPcpStateReadyToOperate, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStatePreop2, kPcpStatePreop1, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStatePreop2);

	/* state: READY_TO_OPERATE */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateReadyToOperate, kPcpStateOperational, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateReadyToOperate, kPcpStatePreop1, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStateReadyToOperate);

	/* state: OPERATIONAL */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateOperational, kPcpStateBooted, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateOperational, kPcpStatePreop1, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateOperational, STATE_FINAL, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStateOperational);
}

/**
********************************************************************************
\brief	activate state machine
*******************************************************************************/
void activateStateMachine(void)
{
	DEBUG_FUNC;

	fEvent = FALSE;

	/* initialize state machine */
	sm_reset(&pcpStateMachine_l);
}

/**
********************************************************************************
\brief	update state machine
*******************************************************************************/
BOOL updateStateMachine(void)
{
	return sm_update(&pcpStateMachine_l);
}

/**
********************************************************************************
\brief	check if state machine is running
*******************************************************************************/
BOOL stateMachineIsRunning(void)
{
	if (sm_getState(&pcpStateMachine_l) != STATE_FINAL)
		return TRUE;
	else
		return FALSE;
}

/**
********************************************************************************
\brief	set powerlink event
*******************************************************************************/
void setPowerlinkEvent(tPowerlinkEvent event_p)
{
	powerlinkEvent = event_p;
}


/* END-OF-FILE */
/******************************************************************************/

