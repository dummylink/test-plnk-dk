/**
********************************************************************************
\file       cnApiAsyncVeth.h

\brief      API header for Virtual Ethernet frame handling

This module posts Virtual Ethernet frames from the stack the asynchronous state
machine and receives frames from the asynchronous state machine.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPIVETH_H_
#define CNAPIVETH_H_

#include "cnApiCfg.h"
#include "cnApiTypAsync.h"

/******************************************************************************/
/* includes */

#if VETH_DRV_ENABLE != FALSE

/******************************************************************************/
/* defines */
#if VETH_DRV_ENABLE != FALSE
  #define CNAPI_VETH_SEND_TEST      ///< enable virtual ethernet test environment
  //#define CNAPI_VETH_ENABLE_STATS   ///< enable virtual ethernet statistics
#endif

/******************************************************************************/
/* typedefs */
typedef enum
{
    kCnApiVethTxTimeout          = 0x00,     ///< transmit had a timeout
    kCnApiVethTxSuccessfull      = 0x01,     ///< transmission successful

} tCnApiVethTxStatus;

typedef tCnApiStatus (* tPdiAsyncVethRxCb) (BYTE *pData_p, WORD wDataSize);
typedef tCnApiStatus (* tPdiAsyncVethTxFinCb) (tCnApiVethTxStatus eVethTxStatus_p);

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

#endif //VETH_DRV_ENABLE != FALSE

#endif /* CNAPIVETH_H_ */

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

