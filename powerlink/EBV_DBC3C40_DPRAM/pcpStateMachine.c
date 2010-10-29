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
static tTransition 			aPcpTransitions_l[MAX_TRANSITIONS_PER_STATE * kNumPcpStates];
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
\brief	check for application processor event
*******************************************************************************/
static BOOL checkApCommand(BYTE cmd_p)
{
	if (getCommandFromAp() == cmd_p)
	{
		if (cmd_p != kApCmdReboot) ///< reset AP command will take place in state 'kPcpStateBooted'
		{
		pCtrlReg_g->m_bCommand = kApCmdNone;	///< reset AP command
		}

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
	while(!checkApCommand(kApCmdReboot)) 	///< AP has to start bootup procedure
	{
		asm("NOP;");
	}

	pCtrlReg_g->m_bCommand = kApCmdNone;	///< reset AP command

	IOWR_ALTERA_AVALON_PIO_DATA(STATUS_LED_PIO_BASE, 0xef); ///< set "bootup LED"

	///< if this is not the first boot: shutdown POWERLINK first
	if(bPLisInitalized == TRUE)
	{
		EplNmtuNmtEvent(kEplNmtEventSwitchOff); ///< shutdown and cleanup POWERLINK
	    bPLisInitalized = FALSE;
	}
	storePcpState(kPcpStateBooted);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPcpStateBooted)
{
	int iStatus = kEplSuccessful;

	Gi_pollAsync();
	if (checkApCommand(kApCmdInit))
	{
		DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "%s: get ApCmdInit\n", __func__);
		if(bPLisInitalized == FALSE) ///< POWERLINK is not initialized yet
		{
			iStatus = initPowerlink(&initParm_g);
		}
		if (iStatus == kEplSuccessful)
		{
			fEvent = TRUE;
		}
	}
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateBooted,kPcpStateInit,1)
{
	return checkEvent(); 					///< Transition, if event occured
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
    if(checkPowerlinkEvent(kPowerlinkEventEnterPreOperational1) && checkEvent())
    {
        return TRUE;
    }
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateInit,kPcpStateBooted,1)
{
	return checkApCommand(kApCmdReboot);
}

/*============================================================================*/
/* State: PRE_OPERATIONAL1 */
/*============================================================================*/
FUNC_ENTRYACT(kPcpStatePreop1)
{
	IOWR_ALTERA_AVALON_PIO_DATA(STATUS_LED_PIO_BASE, 0xff); ///< reset "bootup LED"
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
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStatePreop1,kPcpStateBooted,1)
{
	return checkApCommand(kApCmdReboot);
}

/*============================================================================*/
/* State: PRE_OPERATIONAL2 */
/*============================================================================*/
FUNC_ENTRYACT(kPcpStatePreop2)
{
    /* setup PDO descriptors */
    Gi_setupPdoDesc(kCnApiDirReceive);
    Gi_setupPdoDesc(kCnApiDirTransmit);
    Gi_calcSyncIntPeriod();

	storePcpState(kPcpStatePreop2);
	EplNmtuNmtEvent(kEplNmtEventEnterReadyToOperate);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPcpStatePreop2)
{

}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStatePreop2,kPcpStateReadyToOperate,1)
{
    if(checkPowerlinkEvent(kPowerlinkEventkEnterReadyToOperate) &&
       checkApCommand(kApCmdReadyToOperate))
	{
        return TRUE;
	}
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStatePreop2,kPcpStatePreop1,1)
{
	return checkPowerlinkEvent(kPowerlinkEventEnterPreOperational1);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStatePreop2,kPcpStateBooted,1)
{
	return checkApCommand(kApCmdReboot);
}

/*============================================================================*/
/* State: READY_TO_OPERATE */
/*============================================================================*/
FUNC_ENTRYACT(kPcpStateReadyToOperate)
{
	storePcpState(kPcpStateReadyToOperate);
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
	return checkPowerlinkEvent(kPowerlinkEventEnterPreOperational1);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateReadyToOperate,kPcpStateBooted,1)
{
	return checkApCommand(kApCmdReboot);
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
FUNC_EVT(kPcpStateOperational,kPcpStatePreop1,1)
{
	return checkPowerlinkEvent(kPowerlinkEventEnterPreOperational1);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateOperational,kPcpStateBooted,1)
{
	return checkApCommand(kApCmdReboot);
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

	DEBUG_TRACE2 (DEBUG_LVL_CNAPI_INFO, "\nSTATE: %s->%s\n", strStateNames_l[currentIdx], strStateNames_l[targetIdx]);
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
			0, kPcpStateBooted, stateChange);

	/***** build up states ******/
	/* state: BOOTED */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateBooted, kPcpStateInit, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStateBooted);

	/* state: INIT */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateInit, kPcpStatePreop1, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateInit, kPcpStateBooted, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStateInit);

	/* state: PREOP */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStatePreop1, kPcpStatePreop2, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStatePreop1, kPcpStateBooted, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStatePreop1);

	/* state: WAIT_READY_TO_OPERATE */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStatePreop2, kPcpStateReadyToOperate, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStatePreop2, kPcpStatePreop1, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStatePreop2, kPcpStateBooted, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStatePreop2);

	/* state: READY_TO_OPERATE */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateReadyToOperate, kPcpStateOperational, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateReadyToOperate, kPcpStatePreop1, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateReadyToOperate, kPcpStateBooted, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStateReadyToOperate);

	/* state: OPERATIONAL */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateOperational, kPcpStatePreop1, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateOperational, kPcpStateBooted, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateOperational, STATE_FINAL, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStateOperational);
}

/**
********************************************************************************
\brief	activate state machine
*******************************************************************************/
void resetStateMachine(void)
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

