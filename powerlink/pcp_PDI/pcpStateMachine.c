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
#include "cnApiEvent.h"
#include "pcp.h"

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


char	*strPcpStateNames_l[] = { "INITIAL", "FINAL", "BOOTED", "INIT", "PREOP", "READY_TO_OPERATE", "OPERATIONAL"};


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
        if (cmd_p == kApCmdReset) // reset AP command will take place in state 'kPcpStateBooted'
        {
            fEvent = FALSE;
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "INFO: get kApCmdReset\n");
        }

        AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wCommand, kApCmdNone);    ///< reset AP command

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
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wCommand, kApCmdNone);     // reset AP command
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_dwSyncIntCycTime, 0x00);

    Gi_controlLED(kEplLedTypeTestAll, TRUE); // set "bootup indicator LEDs"
    Gi_controlLED(kEplLedTypeTestAll, FALSE); // reset "bootup LED" //TODO: status/error LED does not work without this test

	///< if this is not the first boot: shutdown POWERLINK first
	if(fPLisInitalized_g == TRUE)
	{
		EplNmtuNmtEvent(kEplNmtEventSwitchOff); // shutdown and cleanup POWERLINK
	}

	storePcpState(kPcpStateBooted);
	Gi_pcpEventPost(kPcpPdiEventPcpStateChange, kPcpStateBooted);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPcpStateBooted)
{
    storePcpState(kPcpStateBooted);

    if (checkApCommand(kApCmdInit))
    {
        // kApCmdInit will be received as soon as AP got the InitPcpResponse message
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "INFO: get ApCmdInit\n");
        fEvent = TRUE;
    }
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateBooted,kPcpStateInit,1)
{
    return checkEvent();        // Transition, if event occured
}

/*============================================================================*/
/* State: INIT */
/*============================================================================*/
FUNC_ENTRYACT(kPcpStateInit)
{
    int iStatus = kEplSuccessful;

    DEBUG_TRACE0(DEBUG_LVL_28, "init POWERLINK Stack...\n");
    if(fPLisInitalized_g == FALSE) // POWERLINK is not initialized yet
    {
        iStatus = initPowerlink(&initParm_g);
        if (iStatus == kEplSuccessful)
        {
            DEBUG_TRACE0(DEBUG_LVL_28, "...ok!\n\n");
        }
        else
        {
            DEBUG_TRACE1(DEBUG_LVL_28, "... error! Ret: 0x%X\n\n", iStatus);
            // TODO: Do error handling. Introduce "STOPPED" or "ERROR" state.
            return;
        }
    }
    else
    {
        // powerlink should not be initialized again, because this
        // would disable the hub functionality for some time!
        DEBUG_TRACE0(DEBUG_LVL_28, "... skipped (already initialized)!\n\n");

        // simply proceed as usual, because this happens at reset
    }

    storePcpState(kPcpStateInit);
    Gi_pcpEventPost(kPcpPdiEventPcpStateChange, kPcpStateInit);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPcpStateInit)
{
    int iStatus;

    if (checkApCommand(kApCmdPreop))
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "INFO: get ApCmdPreop\n");
        iStatus = startPowerlink();
        if (iStatus == kEplSuccessful)
        {
            fEvent = TRUE;
        }
    }
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateInit,kPcpStatePreOp,1)
{
    if(checkPowerlinkEvent(kPowerlinkEventEnterPreOp) && checkEvent())
    {
        return TRUE;
    }
    return FALSE;
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateInit,kPcpStateBooted,1)
{
    if(checkApCommand(kApCmdReset)            ||
       checkPowerlinkEvent(kPowerlinkEventReset))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

/*============================================================================*/
/* State: PRE_OPERATIONAL*/
/*============================================================================*/
FUNC_ENTRYACT(kPcpStatePreOp)
{
    storePcpState(kPcpStatePreOp);
    Gi_pcpEventPost(kPcpPdiEventPcpStateChange, kPcpStatePreOp);
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPcpStatePreOp)
{

}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStatePreOp,kPcpStateReadyToOperate,1)
{
    BOOL fRet = FALSE;

    if(checkApCommand(kApCmdReadyToOperate))
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "INFO: get ApCmdReadyToOperate\n");
        if (CnApiAsync_checkApLinkingStatus() == kPdiAsyncStatusSuccessful)
        { // state change allowed

            // clear transition flag if it is set to kPowerlinkEventEnterPreOp
            // to prevent side effects, because this flag is not checked for this
            // transition and we are already in kPcpStatePreOp
            checkPowerlinkEvent(kPowerlinkEventEnterPreOp);

            fRet = TRUE;
            goto Exit;
        }
        else
        {
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: ReadyToOp blocked!");
        }
    }
    else
    {
        fRet = FALSE;
        goto Exit;
    }
Exit:
    return fRet;
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStatePreOp,kPcpStateBooted,1)
{
    if(checkApCommand(kApCmdReset)            ||
       checkPowerlinkEvent(kPowerlinkEventReset))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

/*============================================================================*/
/* State: READY_TO_OPERATE */
/*============================================================================*/
FUNC_ENTRYACT(kPcpStateReadyToOperate)
{
    EplNmtuNmtEvent(kEplNmtEventEnterReadyToOperate); // trigger NMT state change
	storePcpState(kPcpStateReadyToOperate);
	Gi_pcpEventPost(kPcpPdiEventPcpStateChange, kPcpStateReadyToOperate);
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
FUNC_EVT(kPcpStateReadyToOperate,kPcpStatePreOp,1)
{
	return checkPowerlinkEvent(kPowerlinkEventEnterPreOp);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateReadyToOperate,kPcpStateBooted,1)
{
    if(checkApCommand(kApCmdReset)            ||
       checkPowerlinkEvent(kPowerlinkEventReset))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

/*============================================================================*/
/* State: Operational */
/*============================================================================*/
FUNC_ENTRYACT(kPcpStateOperational)
{
	storePcpState(kPcpStateOperational);
	Gi_pcpEventPost(kPcpPdiEventPcpStateChange, kPcpStateOperational);

    /* enable the synchronization interrupt */
    if(wSyncIntCycle_g != 0)   // true if Sync IR is required by AP
    {
        Gi_enableSyncInt(wSyncIntCycle_g);    // enable IR trigger possibility
    }
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPcpStateOperational)
{
    if(checkApCommand(kApCmdPreop))
    {
        // fall back to PreOp state
        EplNmtuNmtEvent(kEplNmtEventEnterPreOperational2);
    }
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateOperational,kPcpStatePreOp,1)
{
    if(checkPowerlinkEvent(kPowerlinkEventEnterPreOp))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPcpStateOperational,kPcpStateBooted,1)
{
    if(checkApCommand(kApCmdReset)            ||
       checkPowerlinkEvent(kPowerlinkEventReset))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
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

	DEBUG_TRACE2 (DEBUG_LVL_CNAPI_INFO, "\nPCP STATE: %s->%s\n", strPcpStateNames_l[currentIdx], strPcpStateNames_l[targetIdx]);
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
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateInit, kPcpStatePreOp, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateInit, kPcpStateBooted, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStateInit);

	/* state: PREOP */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStatePreOp, kPcpStateReadyToOperate, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStatePreOp, kPcpStateBooted, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStatePreOp);

	/* state: READY_TO_OPERATE */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateReadyToOperate, kPcpStateOperational, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateReadyToOperate, kPcpStatePreOp, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateReadyToOperate, kPcpStateBooted, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStateReadyToOperate);

	/* state: OPERATIONAL */
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateOperational, kPcpStatePreOp, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateOperational, kPcpStateBooted, 1);
	SM_ADD_TRANSITION(&pcpStateMachine_l, kPcpStateOperational, STATE_FINAL, 1);
	SM_ADD_ACTION_110(&pcpStateMachine_l, kPcpStateOperational);
}

/**
********************************************************************************
\brief  start state machine
*******************************************************************************/
void activateStateMachine(void)
{
    initStateMachine();

    resetStateMachine();
}

/**
********************************************************************************
\brief  reset state machine
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

