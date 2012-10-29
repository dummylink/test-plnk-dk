/**
********************************************************************************
\file       cnApiStateMachine.c

\brief      AP state machine module of CN API library

This module contains the AP state machine implementation of the openPOWERLINK
CN API library. The state machine implements the main state machine of an
application processor (AP).

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include <cnApi.h>
#include <stateMachine.h>

#include "cnApiIntern.h"
#include "cnApiEventIntern.h"
#include "cnApiAsyncSm.h"



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
static void CnApi_initApStateMachine(void);

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

    AsyncRet = CnApiAsync_postMsg(kPdiAsyncMsgIntInitPcpReq,
                                  NULL,
                                  NULL,
                                  CnApi_pfnCbInitPcpRespFinished,
                                  NULL,
                                  0);

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
	if (fEnterReadyToOperate != FALSE)
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
    tCnApiStatus Ret = kCnApiStatusOk;
	BYTE	currentIdx, targetIdx;
    tCnApiEventArg CnApiEventArg;

	currentIdx = current + 2;
	targetIdx = target + 2;

	DEBUG_TRACE2(DEBUG_LVL_CNAPI_INFO,"CNAPI STATE: %s->%s\n", strCnApiStateNames_l[currentIdx],
	        strCnApiStateNames_l[targetIdx]);

	/* inform application */
	CnApiEventArg.m_NewApState = (tApStates) target;

	Ret = CnApi_callEventCallback(kCnApiEventApStateChange, &CnApiEventArg, NULL);
    if(Ret != kCnApiStatusOk)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "%s: Error while posting a state change!\n", __func__);
    }

}

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief	initialize AP state machine
*******************************************************************************/
void CnApi_initApStateMachine(void)
{
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

/*******************************************************************************
*
* License Agreement
*
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved.
*
* Redistribution and use in source and binary forms,
* with or without modification,
* are permitted provided that the following conditions are met:
*
*   * Redistributions of source code must retain the above copyright notice,
*     this list of conditions and the following disclaimer.
*   * Redistributions in binary form must reproduce the above copyright notice,
*     this list of conditions and the following disclaimer
*     in the documentation and/or other materials provided with the
*     distribution.
*   * Neither the name of the B&R nor the names of its contributors
*     may be used to endorse or promote products derived from this software
*     without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
* A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
* THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
*******************************************************************************/
/* END-OF-FILE */


