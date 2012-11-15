/******************************************************************************
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is          
* subject to the License Agreement located at the end of this file below.     
*/

/**
********************************************************************************

\file       EplObduDefAccHstry.h

\brief      Default object dictionary access history module header file

\date       13.11.2012

*******************************************************************************/
#ifndef _EPLOBDUDEFACCHSTRY_H_
#define _EPLOBDUDEFACCHSTRY_H_
/******************************************************************************/
/* includes */
#include <EplErrDef.h>
#include <EplObd.h>

/******************************************************************************/
/* defines */
#define OBD_DEFAULT_ACC_INVALID                   0xFFFFUL

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */
tEplKernel EplAppDefObdAccAdoptedHstryInitSequence(void);
BOOL EplAppDefObdAccAdoptedHstryCeckSequenceStarted(void);
tEplKernel EplAppDefObdAccAdoptedHstrySaveHdl(tEplObdParam * pObdParam_p,
                                              tObdAccHstryEntry **ppDefHdl_p);
void EplAppDefObdAccAdoptedHstryDeleteEntry(tObdAccHstryEntry *  pDefObdHdl_p);
tEplKernel EplAppDefObdAccAdoptedHstryGetEntry(WORD wComConIdx_p,
                                  tObdAccHstryEntry **ppDefObdAccHdl_p);
tEplKernel EplAppDefObdAccAdoptedHstryGetStatusEntry(
                                        WORD wIndex_p,
                                        WORD wSubIndex_p,
                                        tEplObdAccStatus ReqStatus_p,
                                        BOOL fSearchOldest_p,
                                        tObdAccHstryEntry **ppDefObdAccHdl_p);
tEplKernel EplAppDefObdAccAdoptedHstryWriteSegm(
                                        tObdAccHstryEntry * pDefObdAccHdl_p,
                                        void * pfnSegmentFinishedCb_p,
                                        void * pfnSegmentAbortCb_p);
tEplKernel EplAppDefObdAccAdoptedHstryEntryFinished(tObdAccHstryEntry * pObdAccHstEntry_p);
tEplKernel EplAppDefObdAccAdoptedHstryProcessWrite(tObdAccHstryEntry * pObdAccHstEntry_p);
int EplAppDefObdAccAdoptedHstryWriteSegmAbortCb(tObdAccHstryEntry * pDefObdHdl_p);
void EplAppDefObdAccAdoptedHstryCleanup(void);



#endif /* _EPLOBDUDEFACCHSTRY_H_ */

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

