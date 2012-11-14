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

/**
 * \brief enum of object access storage locations
 */
typedef enum eObdAccStorage {
    kObdAccStorageInvalid,          ///< invalid location
    kObdAccStorageDefObdAccHistory, ///< default OBD access history
} tObdAccStorage;

/**
 * \brief structure for object access forwarding to PDI (i.e. AP)
 */
typedef struct sObdAccComCon {
    WORD            m_wComConIdx; ///< communication connection index of lower layer
    tObdAccStorage  m_Origin;   ///< OBD handle storage location
} tObdAccComCon;

/**
 * \brief PDI communication connection structure
 */
typedef struct sApiPdiComCon {
    tObdAccComCon  m_ObdAccFwd;  ///< object access forwarding connection
} tApiPdiComCon;


/******************************************************************************/
/* global variables */
extern volatile tPcpCtrlReg *     pCtrlReg_g;       ///< ptr. to PCP control register

/******************************************************************************/
/* function declarations */

#endif // EPL_MODULE_API_PDI

#endif /* GENERICIF_H_ */

/* END-OF-FILE */
/******************************************************************************/

