/******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is          
* subject to the License Agreement located at the end of this file below.     
*/

/**
********************************************************************************

\file       pcpEvent.h

\brief      header file for pcpEvent module

\author     hoggerm

\date       26.08.2011

\since      26.08.2011

*******************************************************************************/
/* includes */
#include "cnApiGlobal.h"
#include "cnApi.h"
#include "cnApiIntern.h"

/******************************************************************************/
/* defines */
#define FIFO_SIZE   16

/******************************************************************************/
/* typedefs */
enum eFifoDelete {
    kPcpEventFifoEmpty = 0,
    kPcpEventFifoFull,
    kPcpEventFifoInserted
};

enum eFifoInsert {
    kPcpEventFifoPosted = 0,
    kPcpEventFifoBusy
};

typedef struct sFifoBuffer {
    WORD       wEventType_m;          ///< type of event (e.g. state change, error, ...)
    WORD       wEventArg_m;           ///< event argument, if applicable (e.g. error code, state, ...)
    WORD       wEventAck_m;           ///< acknowledge for events and asynchronous IR signal
} tFifoBuffer;


/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */
void Gi_pcpEventFifoInit(void);
void Gi_pcpEventPost(WORD wEventType_p, WORD wArg_p);
inline UCHAR Gi_pcpEventFifoProcess(tPcpCtrlReg* volatile pCtrlReg_g);

/******************************************************************************/
/* functions */

#ifndef PCPEVENT_H_
#define PCPEVENT_H_


#endif /* PCPEVENT_H_ */

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

