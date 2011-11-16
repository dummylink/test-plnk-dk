/**
********************************************************************************
\file		PcpStateMachine.h

\brief		BRIEF_DESCRIPTION_OF_FILE

\author		baumgartnerj

\date		12.04.2010

DETAILED_DESCRIPTION_OF_FILE
*******************************************************************************/

#ifndef PCPSTATEMACHINE_H_
#define PCPSTATEMACHINE_H_

/******************************************************************************/
/* includes */
#include "stateMachine.h"

#include "EplNmt.h"
#include "user/EplNmtu.h"

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

typedef enum ePowerlinkEvent {
	kPowerlinkEventNone,
	kPowerlinkEventEnterPreOperational1,
	kPowerlinkEventEnterPreop2,
	kPowerlinkEventkEnterReadyToOperate,
	kPowerlinkEventReset,
	kPowerlinkEventEnterOperational,
	kPowerlinkEventShutdown
} tPowerlinkEvent;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */
extern void initStateMachine(void);
extern void activateStateMachine(void);
extern void resetStateMachine(void);
extern BOOL updateStateMachine(void);
extern BOOL stateMachineIsRunning(void);
extern void	setPowerlinkEvent(tPowerlinkEvent event_p);

#endif /* PCPSTATEMACHINE_H_ */
/* END-OF-FILE */
/******************************************************************************/

