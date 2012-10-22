/**
********************************************************************************
\file       cnApiEventIntern.h

\brief      Library internal header file for PCP PDI (CN) event handling

This file provides the private interface for the event handling module in the
libCnApi libarary.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPIEVENTINTERN_H_
#define CNAPIEVENTINTERN_H_

/******************************************************************************/
/* includes */
#include <cnApiTypEvent.h>

/******************************************************************************/
/* defines */
#define ASYNC_IRQ_PEND  0
#define ASYNC_IRQ_EN   15

// 0x9xxx PCP errors
#define PCP_IF_COMMUNICATION_ERROR      0x9100
#define PCP_IF_INVALID_STATE_CHANGE     0x9200
#define PCP_IF_CONFIGURATION_ERROR      0x9300

/******************************************************************************/
/* typedefs */
typedef struct {
    tCnApiEventType Typ_m;
    tCnApiEventArg  Arg_m;
} tCnApiEvent;

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
tCnApiStatus CnApi_initAsyncEvent(tCnApiAppCbEvent pfnAppCbEvent_p);
tCnApiStatus CnApi_callEventCallback(tCnApiEventType EventType_p,
        tCnApiEventArg * pEventArg_p, void * pUserArg_p);


#endif /* CNAPIEVENTINTERN_H_ */

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

