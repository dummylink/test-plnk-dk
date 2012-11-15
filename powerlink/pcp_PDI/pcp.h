/**
********************************************************************************
\file		pcp.h

\brief		header file of Powerlink Communication Processor application

\author		baumgartnerj

\date		20.04.2010

DETAILED_DESCRIPTION_OF_FILE
*******************************************************************************/

#ifndef GENERICIF_H_
#define GENERICIF_H_

/******************************************************************************/
/* includes */
#include "cnApiTyp.h"
#include "pcpAsync.h"

#include "Debug.h"
#include "EplErrDef.h"
#include "EplObd.h"

#ifdef EPL_MODULE_API_PDI
/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* global variables */
extern volatile tPcpCtrlReg *     pCtrlReg_g;       ///< ptr. to PCP control register

/******************************************************************************/
/* function declarations */

#endif // EPL_MODULE_API_PDI

#endif /* GENERICIF_H_ */

/* END-OF-FILE */
/******************************************************************************/

