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

typedef tEplKernel (* tInitPowerlink) ( tPcpInitParam *pInitParam_p );
typedef int (* tStartPowerlink) ( void );
typedef void (* tShutdownPowerlink) ( void );
typedef void (* tRdyToOpPowerlink) ( void );
typedef void (* tOperationalPowerlink) ( void );
typedef void (* tPreOpPowerlink) ( void );

typedef enum ePowerlinkEvent {
	kPowerlinkEventNone,
	kPowerlinkEventEnterPreOp,
	kPowerlinkEventkEnterReadyToOperate,
	kPowerlinkEventReset,
	kPowerlinkEventEnterOperational,
	kPowerlinkEventShutdown
} tPowerlinkEvent;

/**
 * init structure for the PCP state machine module
 */
typedef struct sInitStateMachine {
    tInitPowerlink        m_fpInitPlk;
    tStartPowerlink       m_fpStartPlk;
    tShutdownPowerlink    m_fpShutdownPlk;
    tRdyToOpPowerlink     m_fpRdyToOpPlk;
    tOperationalPowerlink m_fpOperationalPlk;
    tPreOpPowerlink       m_fpPreOpPlk;
} tInitStateMachine;



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
BOOL Gi_initStateMachine( tInitStateMachine *InitParams_p);
void Gi_resetStateMachine(void);
BOOL Gi_updateStateMachine(void);
BOOL Gi_stateMachineIsRunning(void);
void Gi_setPowerlinkEvent(tPowerlinkEvent event_p);
BOOL Gi_getPlkInitStatus(void);

#endif /* PCPSTATEMACHINE_H_ */
/* END-OF-FILE */
/******************************************************************************/

