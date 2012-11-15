/**
********************************************************************************
\file       cnApiObject.h

\brief      Header file of cnApi object dictionary module

This header file contains public defines for object dictionary access on the
AP processor.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPIOBD_H_
#define CNAPIOBD_H_

/******************************************************************************/
/* includes */
#include <cnApiGlobal.h>

#include "cnApiSdo.h"

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

typedef enum
{
    kCnApiObdStatusOk             = 0x0000,       // no error/successful run
    kCnApiObdInvalidParam         = 0x000D,       // invalid parameter specified
    kCnApiObdIllegalPart          = 0x0030,       // unknown OD part
    kCnApiObdIndexNotExist        = 0x0031,       // object index does not exist in OD
    kCnApiObdSubindexNotExist     = 0x0032,       // subindex does not exist in object index
    kCnApiObdReadViolation        = 0x0033,       // read access to a write-only object
    kCnApiObdWriteViolation       = 0x0034,       // write access to a read-only object
    kCnApiObdAccessViolation      = 0x0035,       // access not allowed
    kCnApiObdUnknownObjectType    = 0x0036,       // object type not defined/known
    kCnApiObdVarEntryNotExist     = 0x0037,       // object does not contain VarEntry structure
    kCnApiObdValueTooLow          = 0x0038,       // value to write to an object is too low
    kCnApiObdValueTooHigh         = 0x0039,       // value to write to an object is too high
    kCnApiObdValueLengthError     = 0x003A,       // value to write is too long or too short
    kCnApiObdErrnoSet             = 0x003B,       // file I/O error occurred and errno is set
    kCnApiObdInvalidDcf           = 0x003C,       // device configuration file (CDC) is not valid
    kCnApiObdOutOfMemory          = 0x003D,       // out of memory
    kCnApiObdNoConfigData         = 0x003E,       // no configuration data present (CDC is empty)
    kCnApiObdAccessAdopted        = 0x003F,       // OD access adopted

} tCnApiObdStatus;

typedef enum
{
    kCnApiObdEvCheckExist            = 0x06,    // checking if object does exist (reading and writing)
    kCnApiObdEvPreRead               = 0x00,    // before reading an object
    kCnApiObdEvPostRead              = 0x01,    // after reading an object
    kCnApiObdEvPostReadLe            = 0x08,    // after reading an object
    kCnApiObdEvWrStringDomain        = 0x07,    // event for changing string/domain data pointer or size
    kCnApiObdEvInitWrite             = 0x05,    // initializes writing an object (checking object size)
    kCnApiObdEvInitWriteLe           = 0x04,    // initializes writing an object (checking object size)
    kCnApiObdEvPreWrite              = 0x02,    // before writing an object
    kCnApiObdEvPostWrite             = 0x03,    // after writing an object
} tCnApiObdEvent;

typedef unsigned int tCnApiObdSize; // For all objects as objects size are used an unsigned int.


typedef struct sCnApiObdParam
{
    tCnApiObdEvent      m_ObdEvent;
    unsigned int        m_uiIndex;
    unsigned int        m_uiSubIndex;
    tCnApiSdoAbortCode  m_AbortCode;
    void *              m_pData;
    tCnApiObdSize       m_TransferSize;     // transfer size from SDO or local app
    tCnApiObdSize       m_ObjSize;          // current object size from OD
    tCnApiObdSize       m_SegmentSize;
    tCnApiObdSize       m_SegmentOffset;
} tCnApiObdParam;

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


#endif /* CNAPIOBJECT_H_ */

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

