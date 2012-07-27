/******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       pcpStateMachine.h

\brief      header file for the pcpStateMachine module (POWERLINK state machine)

\author     baumgartnerj

\date       29.04.2011

\since      29.04.2011

*******************************************************************************/

#ifndef PCPSTATEMACHINE_H_
#define PCPSTATEMACHINE_H_

/******************************************************************************/
/* includes */
#include "cnApiTyp.h"

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

typedef enum ePowerlinkEvent {
	kPowerlinkEventNone,
	kPowerlinkEventEnterPreOp,
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
void initStateMachine(void);
void activateStateMachine(void);
void resetStateMachine(void);
BOOL updateStateMachine(void);
BOOL stateMachineIsRunning(void);
void setPowerlinkEvent(tPowerlinkEvent event_p);

#endif /* PCPSTATEMACHINE_H_ */
/* END-OF-FILE */
/******************************************************************************/

