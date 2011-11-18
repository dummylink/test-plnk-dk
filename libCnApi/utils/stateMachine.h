/**
********************************************************************************
\file		StateMachine.h

\brief		header file of state machine engine

\author		Josef Baumgartner

\date		22.03.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

*******************************************************************************/

#ifndef STATEMACHINE_H_
#define STATEMACHINE_H_

/******************************************************************************/
/* includes */
#include "cnApiGlobal.h"

/******************************************************************************/
/* defines */
#define	MAX_TRANSITIONS_PER_STATE				4		///< maximum number of transitions per state
#define	STATE_INITIAL							0xFE	///< predefined initial state
#define	STATE_FINAL								0xFF	///< predefined final state

/* some time-saving macros for action and transition creation */
#define	FUNC_EVT(STATE1,STATE2,NUM)				static BOOL eventFunc_##STATE1##_##STATE2##_##NUM (void)
#define	FUNC_TRANSACT(STATE1,STATE2,NUM)		static void transActionFunc_##STATE1##_##STATE2##_##NUM (void)
#define	FUNC_ENTRYACT(STATE) 					static void entryActionFunc_##STATE (void)
#define	FUNC_DOACT(STATE)						static void doActionFunc_##STATE (void)
#define	FUNC_EXITACT(STATE)						static void exitActionFunc_##STATE (void)

#define	SM_ADD_TRANSITION(MACHINE, STATE1, STATE2, NUM) \
	sm_addTransition(MACHINE, STATE1, STATE2, eventFunc_##STATE1##_##STATE2##_##NUM, NULL)

#define	SM_ADD_TRANSITION_ACTION(MACHINE, STATE1,STATE2,NUM) \
	sm_addTransition(MACHINE, STATE1, STATE2, eventFunc_##STATE1##_##STATE2##_##NUM, transActionFunc_##STATE1##_##STATE2##_##NUM)

#define	SM_ADD_ACTION_001(MACHINE,STATE) \
	sm_addAction(MACHINE, STATE, NULL, NULL, exitActionFunc_##STATE)

#define	SM_ADD_ACTION_010(MACHINE,STATE) \
	sm_addAction(MACHINE, STATE, NULL, doActionFunc_##STATE, NULL)

#define	SM_ADD_ACTION_011(MACHINE,STATE) \
	sm_addAction(MACHINE, STATE, NULL, doActionFunc_##STATE, exitActionFunc_##STATE)

#define	SM_ADD_ACTION_100(MACHINE,STATE) \
	sm_addAction(MACHINE, STATE, entryActionFunc_##STATE, NULL, NULL)

#define	SM_ADD_ACTION_101(MACHINE,STATE) \
	sm_addAction(MACHINE, STATE, entryActionFunc_##STATE, NULL, exitActionFunc_##STATE)

#define	SM_ADD_ACTION_110(MACHINE,STATE) \
	sm_addAction(MACHINE, STATE, entryActionFunc_##STATE, doActionFunc_##STATE, NULL)

#define	SM_ADD_ACTION_111(MACHINE,STATE) \
	sm_addAction(MACHINE, STATE, entryActionFunc_##STATE, doActionFunc_##STATE, exitActionFunc_##STATE)


/******************************************************************************/
/* type definitions */
typedef	void (*tpfnAction) (void);			///< type definition of function pointer to action functions
typedef	BOOL (*tpfnEvent) (void);			///< type definition of function pointer to event functions
typedef	void (*tpfnStateChange) (BYTE bCurrentState_p, BYTE bTargetState_p); ///< type definition of function pointer for state change function

/**
* \brief structure for states
*
* STATE_T defines the structure for a state in the state machine.
*/
typedef struct sState {
	BYTE			m_bUsedTransitions;		///< a counter which contains the initialized transitions of the state
	BYTE			m_abTransition[MAX_TRANSITIONS_PER_STATE];	///< the array with indexes to the transitions of this state
	tpfnAction		m_pfnEntryAction;			///< pointer to the entry action of this state
	tpfnAction		m_pfnDoAction;				///< pointer to the do action of this state
	tpfnAction		m_pfnExitAction;				///< pointer to the exit action of this state
} tState;

/**
* \brief structure for state transitions
*
* TRANSITION_T defines the structure for a state transition.
*/
typedef struct sTransition {
	BYTE			m_bTargetState;			///< the target state the transition points to
	tpfnEvent		m_pfnEvent;				///< the event which triggers the transition
	tpfnAction		m_pfnAction;				///< an action to be perfomed when the transition is active
} tTransition;

/**
* \brief structure for state machine
*
* tStateMachine defines the structure for a state machine.
*/
typedef struct sStateMachine {
	BYTE			m_bInitState;				///< the initial state of this state machine
	BYTE			m_bCurrentState;			///< the current state of the state machine
	BOOL			m_fResetInProgress;			///< state machine reset is in progress

	tTransition		*m_pTransitions;			///< pointer to the array of transitions
	BYTE			m_bMaxTransitions;			///< maximum number of transition entries
	BYTE			m_bUsedTransitions;

	tState			*m_pStates;					///< pointer to the array of states
	BYTE			m_bNumStates;				///< number of states for this state machine
	tpfnStateChange	m_pfnOnStateChange;			///< function to be called on each state change
} tStateMachine;


/******************************************************************************/
/* function declarations */
extern int sm_addTransition(tStateMachine * pStateMachine_p, BYTE bState_p,
		                    BYTE bTargetState_p, tpfnEvent pfnEvent_p, tpfnAction pfnAction_p);

extern int sm_addAction(tStateMachine * pStateMachine_p, BYTE bState_p,
		                tpfnAction pfnEntryAction_p, tpfnAction pfnDoAction_p, tpfnAction pfnExitAction_p);

extern BOOL sm_update(tStateMachine *pStateMachine_p);

extern void sm_init(tStateMachine *pStateMachine_p, tState * pStates_p,
						BYTE bNumStates, tTransition * pTranistions_p,
		                BYTE bMaxTransitions_p, BYTE bInitState_p, tpfnStateChange pfnOnStateChange_p);
extern void sm_reset(tStateMachine *pStateMachine_p);
extern int sm_getState(tStateMachine *pStateMachine_p);

#endif /* STATEMACHINE_H_ */
