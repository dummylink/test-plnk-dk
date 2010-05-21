/**
********************************************************************************
\file		StateMachine.c

\brief		state machine engine

\author		Josef Baumgartner

\date		22.03.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This module contains the state machine engine used to implement state machines.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "StateMachine.h"

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/**
*******************************************************************************
* \brief	get the active transitions
*
* sm_getActiveTransition() checks all transitions for the state. If the event
* of a transition returns true. The transition is returned.
*
* \param	pStateMachine_p	pointer to used state machine
* \param	pState_p		pointer to state which has to be checked
*
* \retval	pointer to the active transition or NULL if no transition is active
******************************************************************************/
static tTransition* sm_getActiveTransition(tStateMachine *pStateMachine_p,
		                                    tState *pState_p)
{
	register int i = 0;
	tTransition	*pTransition;

	for (i = 0; i < pState_p->m_bUsedTransitions; i++)
	{
		pTransition = pStateMachine_p->m_pTransitions + pState_p->m_abTransition[i];
		if (pTransition->m_pfnEvent())
		{
			return pTransition;
		}
	}
	return NULL;
}

/**
********************************************************************************
\brief	activate state machine

sm_activate() is used to activate the state machine. The state machine enters
the init state and executes the entry action of the init state if available.

\param	pStateMachine_p			pointer to state machine being activated
*******************************************************************************/
static void sm_activate(tStateMachine *pStateMachine_p)
{
	tState			*pCurrentState;

	pStateMachine_p->m_bCurrentState = pStateMachine_p->m_bInitState;

	if (pStateMachine_p->m_pfnOnStateChange != NULL)
	{
		pStateMachine_p->m_pfnOnStateChange(STATE_INITIAL, pStateMachine_p->m_bCurrentState);
	}

	pCurrentState = pStateMachine_p->m_pStates + pStateMachine_p->m_bCurrentState;
	/* if there is an entry action, call it */
	if (pCurrentState->m_pfnEntryAction != NULL)
	{
		pCurrentState->m_pfnEntryAction();
	}
}

/******************************************************************************/
/* functions */

/**
*******************************************************************************
* \brief	add a transition
*
* sm_addTransition() adds a transition to a state.
*
* \param	pStateMachine_p		pointer to used state machine
* \param	bState_p			state to add transition to
* \param	bTargetState_p		target state of transition
* \param	pfnEvent_p			pointer to function which checks event for
* 								this transition
* \param	pfnAction_p			pointer to function which contains an action
* 								to be performed for this transition
*
* \retval	OK, if transition was added or ERROR if there is no more space for
*           this transition.
******************************************************************************/
int sm_addTransition(tStateMachine *pStateMachine_p, BYTE bState_p, BYTE bTargetState_p,
		             tpfnEvent pfnEvent_p, tpfnAction pfnAction_p)
{
	tState			*pState;
	tTransition		*pTransition;

	pState = pStateMachine_p->m_pStates + bState_p;

	if ((pStateMachine_p->m_bUsedTransitions >= pStateMachine_p->m_bMaxTransitions) ||
		(pState->m_bUsedTransitions >= MAX_TRANSITIONS_PER_STATE))
		return ERROR;

	/* get pointer to next free transition */
	pTransition = pStateMachine_p->m_pTransitions + pStateMachine_p->m_bUsedTransitions;

	/* get pointer to state */
	pState = pStateMachine_p->m_pStates + bState_p;

	/* initialize transition */
	pTransition->m_pfnEvent = pfnEvent_p;
	pTransition->m_pfnAction = pfnAction_p;
	pTransition->m_bTargetState = bTargetState_p;

	/* add transition to state */
	pState->m_abTransition[pState->m_bUsedTransitions] = pStateMachine_p->m_bUsedTransitions;

	/* increase used transition counter for state and state machine */
	pState->m_bUsedTransitions ++;
	pStateMachine_p->m_bUsedTransitions ++;

	return OK;
}

/**
*******************************************************************************
* \brief	add an action to a state
*
* sm_addAction() adds an action to a state.
*
* \param	pStateMachine_p		pointer to used state machine
* \param	bState_p			state to add action to
* \param	pfnEntryAction_p	pointer to function which contains entry action
* \param	pfnDoAction_p		pointer to function which contains do action
* \param	pfnExitAction_p		pointer to function which contains exit action
*
* \retval	OK, if transition was added or ERROR if there is no more space for
*           this transition.
******************************************************************************/
int sm_addAction(tStateMachine* pStateMachine_p, BYTE bState_p, tpfnAction pfnEntryAction_p,
		         tpfnAction pfnDoAction_p, tpfnAction pfnExitAction_p)
{
	tState			*pState;

	if (bState_p >= pStateMachine_p->m_bNumStates)
		return ERROR;

	/* get pointer to state */
	pState = pStateMachine_p->m_pStates + bState_p;

	/* initialize transition */
	pState->m_pfnEntryAction = pfnEntryAction_p;
	pState->m_pfnDoAction = pfnDoAction_p;
	pState->m_pfnExitAction = pfnExitAction_p;

	return OK;
}

/**
*******************************************************************************
* \brief	init the state machine
*
* sm_init() is used to initialize the state machine
*
* \param	pStateMachine_p		pointer to state machine being initialized
* \param	pStates_p			pointer to memory for states
* \param	bNumStates_p		number of states of this state machine
* \param	pTransitions_p		pointer to memory for transitions
* \param	bMaxTransitions_p	the maximum number of transitions that can be
* 								stored at p_transitions
* \param	bInitState_p		the initial state of the state machine. This
* 								state will be entered, when the state machine
* 								is activated.
******************************************************************************/
void sm_init(tStateMachine *pStateMachine_p, tState *pStates_p,
						BYTE bNumStates_p, tTransition * pTransitions_p,
		                BYTE bMaxTransitions_p, BYTE bInitState_p,
		                tpfnStateChange pfnOnStateChange_p)
{
	pStateMachine_p->m_pStates = pStates_p;
	pStateMachine_p->m_bNumStates = bNumStates_p;
	pStateMachine_p->m_pTransitions = pTransitions_p;
	pStateMachine_p->m_bMaxTransitions = bMaxTransitions_p;
	pStateMachine_p->m_bInitState = bInitState_p;
	pStateMachine_p->m_pfnOnStateChange = pfnOnStateChange_p;

	pStateMachine_p->m_bCurrentState = STATE_INITIAL;
}

/**
********************************************************************************
\brief	check if state machine is active

sm_getState() returns the current state of the state machine.

\param	pStateMachine_p			pointer to state machine being checked

\retval	state		state the state machine is in
*******************************************************************************/
int sm_getState(tStateMachine *pStateMachine_p)
{
	return pStateMachine_p->m_bCurrentState;
}

/**
********************************************************************************
\brief	reset state machine

sm_reset() resets the state machine to the initial state. The state machine
remains in this state until it will be activated by sm_activate().

\param	pStateMachine_p			pointer to state machine being activated
*******************************************************************************/
void sm_reset(tStateMachine *pStateMachine_p)
{
	pStateMachine_p->m_bCurrentState = STATE_INITIAL;
}

/**
********************************************************************************
\brief	main state machine function

sm_updateStateMachine() is the main state machine handler. On every call the
state machine is updated.

\param	pStateMachine_p		pointer to state machine being updated

\retval	TRUE				if state machine is activated
\retval	FALSE				if state machine is finished or not yet activated
*******************************************************************************/
BOOL sm_update(tStateMachine *pStateMachine_p)
{
	tState			*pTargetState, *pCurrentState;
	tTransition 	*pTransition;

	/* if state machine is in FINAL state we do nothing. The state machine
	 * first has to be reseted to start again.
	 */
	if (pStateMachine_p->m_bCurrentState == STATE_FINAL)
		return FALSE;

	/* if we are in INITIAL or FINAL state and the activate flag is set we
	 * activate the state machine and start updating it.
	 */
	if (pStateMachine_p->m_bCurrentState == STATE_INITIAL)
	{
		sm_activate(pStateMachine_p);
		return TRUE;
	}

	/* check if a transition is active */
	pCurrentState = pStateMachine_p->m_pStates + pStateMachine_p->m_bCurrentState;
	pTransition = sm_getActiveTransition(pStateMachine_p, pCurrentState);

	if (pTransition != NULL)
	{
		/* if there is a state change we call the exit action if there is one */
		if (pTransition->m_bTargetState != pStateMachine_p->m_bCurrentState)
		{
			if (pCurrentState->m_pfnExitAction != NULL)
			{
				/* there's a state change, run exit Action */
				pCurrentState->m_pfnExitAction();
			}
		}

		/* check if we entered final state */
		if (pTransition->m_bTargetState == STATE_FINAL)
		{
			pStateMachine_p->m_bCurrentState = STATE_FINAL;	/* deactivate state machine by entering final state */
			return FALSE;
		}

		/* if there is a transition action, call it */
		if (pTransition->m_pfnAction != NULL)
		{
			pTransition->m_pfnAction();
		}

		/* if there is a state change we call the entry action if there is one */
		if (pTransition->m_bTargetState != pStateMachine_p->m_bCurrentState)
		{
			if (pStateMachine_p->m_pfnOnStateChange != NULL)
			{
				pStateMachine_p->m_pfnOnStateChange(pStateMachine_p->m_bCurrentState, pTransition->m_bTargetState);
			}

			/* if there is an entry action, call it */
			pTargetState = pStateMachine_p->m_pStates + pTransition->m_bTargetState;
			if (pTargetState->m_pfnEntryAction != NULL)
			{
				pTargetState->m_pfnEntryAction();
			}
			/* store the new state */
			pCurrentState = pTargetState;
			pStateMachine_p->m_bCurrentState = pTransition->m_bTargetState;
		}
	}

	/* always call do action if there is one */
	if (pCurrentState->m_pfnDoAction != NULL)
	{
		pCurrentState->m_pfnDoAction();
	}
	return TRUE;
}


/* END-OF-FILE */
/******************************************************************************/

