/**
********************************************************************************
\file       cnApiEvent.h

\brief      Header file for PCP PDI (CN) event handling

This file provides the public interface for the event handling module in the
libCnApi library.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPIEVENT_H_
#define CNAPIEVENT_H_

/******************************************************************************/
/* includes */
#include <cnApiTypEvent.h>

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

typedef enum eCnApiEventErrorType{
    kCnApiEventErrorFromPcp     = 0x00,    ///< error source is PCP PDI
    kCnApiEventErrorLcl         = 0x01,    ///< error source is local function
} tCnApiEventErrorType;

typedef union {
    tPcpPdiEvent m_PcpError;
    /* insert libCnApi error if needed */
} tCnApiEventErrorArg;

/**
 * \brief Error argument for both PCP and libCnApi
 */
typedef struct sCnApiEventError{
    tCnApiEventErrorType m_ErrTyp;
    tCnApiEventErrorArg  m_ErrArg;
} tCnApiEventError;

/**
 * \brief definitions for AP state machine, transitions and states
 */
typedef enum eApStates{
    kApStateBooted           = 0x00,
    kApStateReadyToInit      = 0x01,
    kApStateInit             = 0x02,
    kApStatePreOp            = 0x03,
    kApStateReadyToOperate   = 0x04,
    kApStateOperational      = 0x05,
    kApStateError            = 0x06,
    kNumApState              = 0x07
} tApStates;

/**
 * \brief enum of valid CnApi event types
 */
typedef enum eCnApiEventType {
    kCnApiEventUserDef          = 0x00,    ///< user defined event
    kCnApiEventPcp              = 0x01,    ///< generic event from PCP (all events except errors)
    kCnApiEventApStateChange    = 0x02,    ///< AP state machine changed
    kCnApiEventError            = 0x03,    ///< general CnApi error
    kCnApiEventSdo              = 0x04,    ///< not used
    kCnApiEventObdAccess        = 0x05,    ///< not used
} tCnApiEventType;

/**
 * \brief union of valid CnApi event arguments
 */
typedef union {
    void *                   m_pUserArg;          ///< argument of kCnApiEventUserDef
    tPcpPdiEventGeneric      m_PcpEventGen;       ///< argument of kCnApiEventPcp
    tApStates                m_NewApState;        ///< argument of kCnApiEventApStateChange
    tCnApiEventError         m_CnApiError;        ///< argument of kCnApiEventError
} tCnApiEventArg;

typedef tCnApiStatus (* tCnApiAppCbEvent) (tCnApiEventType EventType_p,
        tCnApiEventArg * pEventArg_p, void * pUserArg_p);

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

extern void CnApi_enableAsyncEventIRQ(void);
extern void CnApi_disableAsyncEventIRQ(void);
extern void CnApi_processAsyncEvent(void);


#endif /* CNAPIEVENT_H_ */

/*******************************************************************************
*
* License Agreement
*
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
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

