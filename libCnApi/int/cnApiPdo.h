/**
********************************************************************************
\file       cnApiPdo.h

\brief      Header file with definitions for CN API PDO module

This module handles the process data object handling inside the libCnApi.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPIPDO_H_
#define CNAPIPDO_H_

/******************************************************************************/
/* includes */
#include <cnApiTyp.h>
#include <cnApiTypPdoChan.h>
#include <cnApiTypPdoMap.h>

#include "cnApiAsyncSm.h"


/******************************************************************************/
/* defines */
// this restriction is related to the count of sub-indices of a mapping object
#define MAX_MAPPABLE_OBJECTS_PER_PDO_CHANNEL     254    ///< object restrictions

/******************************************************************************/
/* typedefs */

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

int CnApi_initPdo(tPcpCtrlReg *pCtrlReg_p,
        tCnApiAppCbSync pfnAppCbSync_p,
        BYTE * pDpramBase_p,
        tCnApiCbPdoDesc pfnPdoDescriptor_p);

tPdiAsyncStatus CnApi_doLinkPdosResp(
                       tPdiAsyncMsgDescr * pMsgDescr_p,
                       BYTE* pTxMsgBuffer_p,
                       BYTE* pRxMsgBuffer_p,
                       DWORD dwMaxTxBufSize_p);
tPdiAsyncStatus CnApi_handleLinkPdosReq(
                       tPdiAsyncMsgDescr * pMsgDescr_p,
                       BYTE * pRxMsgBuffer_p,
                       BYTE * pTxMsgBuffer_p,
                       DWORD dwMaxTxBufSize_p);

tPdiAsyncStatus CnApi_pfnCbLinkPdosRespFinished (struct sPdiAsyncMsgDescr * pMsgDescr_p);

#endif /* CNAPIPDO_H_ */

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
