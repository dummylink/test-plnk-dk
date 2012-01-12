/**
********************************************************************************
\file		CnApiStateMachine.c

\brief		AP state machine module of CN API library

\author		Josef Baumgartner

\date		22.03.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This module contains the AP state machine implementation of the openPOWERLINK
CN API library. The state machine implements the main state machine of an
application processor (AP).
*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApi.h"
#include "cnApiIntern.h"
#include "cnApiAsync.h"
#include "stateMachine.h"
#include "cnApiPdiSpi.h"
#include "cnApiEvent.h"

#ifdef AP_IS_BIG_ENDIAN
   #include "EplAmi.h"
#endif

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
static tTransition 			apTransitions[MAX_TRANSITIONS_PER_STATE * kNumApState];

static BOOL					fErrorEvent = FALSE;
static BOOL                 fEnterReadyToOperate = FALSE;
static BOOL                 fBlockTransition_l = FALSE;


char	*strCnApiStateNames_l[] = { "INITIAL", "FINAL", "BOOTED", "WAIT_INIT", "INIT", "PREOP",
                                    "READY_TO_OPERATE", "OPERATIONAL", "ERROR"};

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
    /* send reboot cmd to PCP in order to ensure same state (Booted) */
    CnApi_setApCommand(kApCmdReset);
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
	tPdiAsyncStatus AsyncRet = kPdiAsyncStatusSuccessful;
	DEBUG_FUNC;

#ifdef CN_API_USING_SPI
	/* update control register before accessing it */
    CnApi_Spi_read(PCP_CTRLREG_START_ADR, PCP_CTRLREG_SPAN, (BYTE*) pCtrlRegLE_g);
#endif

#ifdef AP_IS_BIG_ENDIAN
    CnApi_GetCntrlRegfromLe(pCtrlReg_g, pCtrlRegLE_g);
#endif

	AsyncRet = CnApiAsync_postMsg(kPdiAsyncMsgIntInitPcpReq,
                                  NULL,
                                  NULL,
                                  CnApi_pfnCbInitPcpRespFinished);

    if (AsyncRet != kPdiAsyncStatusSuccessful)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "InitPcpReq failed!\n");
        return;
    }
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kApStateReadyToInit)
{
}

/*============================================================================*/
/* State: INIT */
/*============================================================================*/
FUNC_EVT(kApStateInit, kApStatePreOp, 1)
{
    tPcpStates ePcpStateTmp;

    /* check for PCP state: PCP_PREOP */
    ePcpStateTmp = CnApi_getPcpState();

    if ((ePcpStateTmp == kPcpStatePreOp))
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
	CnApi_createObjectLinks();
    CnApi_setApCommand(kApCmdPreop); // immediately make PCP move to PreOP

}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kApStateInit)
{

}

/*============================================================================*/
/* State: PRE_OPERATIONAL */
/*============================================================================*/
FUNC_EVT(kApStatePreOp, kApStateReadyToOperate, 1)
{
	/* check for event which triggers state change */
	if (fEnterReadyToOperate == TRUE)
	{
	    fEnterReadyToOperate = FALSE;
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}

/*----------------------------------------------------------------------------*/
FUNC_ENTRYACT(kApStatePreOp)
{

}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kApStatePreOp)
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
FUNC_EVT(kApStateReadyToOperate, kApStatePreOp, 1)
{
	/* check for PCP state: PCP_PREOP */
	if ((CnApi_getPcpState() == kPcpStatePreOp) &&
	    (fBlockTransition_l == FALSE)             )
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}

}
/*----------------------------------------------------------------------------*/
FUNC_ENTRYACT(kApStateReadyToOperate)
{
    // cause PCP to enter ReadyToOperateState
    CnApi_setApCommand(kApCmdReadyToOperate);

    // block transition back to PreOp, because PCP is still in PreOp
    // and needs time to enter ReadyToOperate
    fBlockTransition_l = TRUE;
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kApStateReadyToOperate)
{
    /* check for PCP state: PCP_PREOP */
    if (CnApi_getPcpState() == kPcpStateReadyToOperate)
    {
        fBlockTransition_l = FALSE;
    }
}

/*============================================================================*/
/* State: OPERATIONAL */
/*============================================================================*/
FUNC_EVT(kApStateOperational, kApStateInit, 1)
{
	return FALSE;
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kApStateOperational, kApStatePreOp, 1)
{
	/* check for PCP state: PCP_PREOP */
	if (CnApi_getPcpState() != kPcpStateOperational)
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
    tCnApiEventArg CnApiEventArg;

	currentIdx = current + 2;
	targetIdx = target + 2;

	TRACE2("CNAPI STATE: %s->%s\n", strCnApiStateNames_l[currentIdx], strCnApiStateNames_l[targetIdx]);

	/* inform application */
	CnApiEventArg.NewApState_m = (tApStates) target;
    CnApi_AppCbEvent(kCnApiEventApStateChange, &CnApiEventArg, NULL);
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
			0, kApStateBooted, stateChange);

	/* build up states */

	/* State: BOOTED */
	SM_ADD_TRANSITION(&apStateMachine, kApStateBooted, kApStateReadyToInit, 1);
	SM_ADD_ACTION_100(&apStateMachine, kApStateBooted);

	/* State: READY_TO_INIT */
	SM_ADD_TRANSITION(&apStateMachine, kApStateReadyToInit, kApStateInit, 1);
	SM_ADD_TRANSITION(&apStateMachine, kApStateReadyToInit, kApStateError, 1);
	SM_ADD_ACTION_110(&apStateMachine, kApStateReadyToInit);

	/* State: INIT */
	SM_ADD_TRANSITION(&apStateMachine, kApStateInit, kApStatePreOp, 1);
	SM_ADD_ACTION_110(&apStateMachine, kApStateInit);

	/* State: PRE-OPERATIONAL */
	SM_ADD_TRANSITION(&apStateMachine, kApStatePreOp, kApStateReadyToOperate, 1);
	SM_ADD_ACTION_110(&apStateMachine, kApStatePreOp);

	/* State: READY_TO_OPERATE */
	SM_ADD_TRANSITION(&apStateMachine, kApStateReadyToOperate, kApStateOperational, 1);
	SM_ADD_TRANSITION(&apStateMachine, kApStateReadyToOperate, kApStatePreOp, 1);
	SM_ADD_ACTION_110(&apStateMachine, kApStateReadyToOperate);

	/* State: OPERATIONAL */
	SM_ADD_TRANSITION(&apStateMachine, kApStateOperational, kApStateInit, 1);
	SM_ADD_TRANSITION(&apStateMachine, kApStateOperational, kApStatePreOp, 1);
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
    CnApi_initApStateMachine();

    CnApi_resetApStateMachine();
}

/**
********************************************************************************
\brief  reset state machine
*******************************************************************************/
void CnApi_resetApStateMachine(void)
{
    DEBUG_FUNC;

    fErrorEvent = FALSE;

    /* initialize state machine */
    sm_reset(&apStateMachine);
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

/**
********************************************************************************
\brief  triggers a state machine change to READY_TO_OPERATE
*******************************************************************************/
void CnApi_enterApStateReadyToOperate()
{
    fEnterReadyToOperate = TRUE;
    /* immediately update state machine */
    //TODO: trigger an "CnApi_processApStateMachine() - event";
}

/* END-OF-FILE */
/******************************************************************************/

