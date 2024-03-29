/**
********************************************************************************
\file       cnApiObjectIntern.h

\brief      Library internal header file of cnApi object module

This header file contains definitions for the libCnApi object handling which
are private inside the library.

Copyright � 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPIOBJECTINTERN_H_
#define CNAPIOBJECTINTERN_H_

/******************************************************************************/
/* includes */
#include <cnApiTyp.h>
#include <cnApi.h>

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */
typedef struct sCnApiObjId {
    WORD        m_wIndex;
    BYTE        m_bSubIndex;
    BYTE        m_bNumEntries;
} PACK_STRUCT tCnApiObjId;

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
int CnApi_initObjects(DWORD dwMaxLinks_p, tCnApiObdDefAcc pfnDefaultObdAccess_p);
void CnApi_cleanupObjects(void);
void CnApi_resetObjectSelector(void);
int CnApi_getNextObject(tCnApiObjId *pObjId);
int CnApi_writeObjects(WORD index, BYTE subIndex, WORD dataLen,
        BYTE* p_data, BOOL sync);
void CnApi_readObjects(WORD index, BYTE subIndex, int CN_readObjectCb);
BOOL CnApi_getObjectParam(WORD wIndex_p, BYTE bSubIndex_p,
        WORD *wSize_p, BYTE **pAdrs_p);


#endif /* CNAPIOBJECTINTERN_H_ */

/*******************************************************************************
*
* License Agreement
*
* Copyright � 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1  
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

