/**
********************************************************************************
\file       cnApiObd.h

\brief      header file of cnApi object dictionary module

\author     mairt

\date       08.10.2012

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This header file contains public defines for object dictionary access on the
AP processor.
*******************************************************************************/

#ifndef CNAPIOBD_H_
#define CNAPIOBD_H_

/******************************************************************************/
/* includes */
#include "global.h"

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

typedef enum
{
    kEplSdoAddrTypeNodeId   =   0x00,
    kEplSdoAddrTypeIp       =   0x01,

} tEplSdoAddrType;

typedef struct
{
    tEplSdoAddrType m_SdoAddrType;
    unsigned int    m_uiNodeId;     // Node-ID of the remote side
} tEplSdoAddress;


typedef enum
{
//                                                                                                      m_pArg points to
//                                                                                                    ---------------------
    kEplObdEvCheckExist            = 0x06,    // checking if object does exist (reading and writing)    NULL
    kEplObdEvPreRead               = 0x00,    // before reading an object                               source data buffer in OD
    kEplObdEvPostRead              = 0x01,    // after reading an object                                destination data buffer from caller
    kEplObdEvPostReadLe            = 0x08,    // after reading an object                                destination data buffer from caller in little endian
    kEplObdEvWrStringDomain        = 0x07,    // event for changing string/domain data pointer or size  struct tEplObdVStringDomain in RAM
    kEplObdEvInitWrite             = 0x05,    // initializes writing an object (checking object size)   size of object in OD (tEplObdSize)
    kEplObdEvInitWriteLe           = 0x04,    // initializes writing an object (checking object size)   size of object in OD (tEplObdSize)
    kEplObdEvPreWrite              = 0x02,    // before writing an object                               source data buffer from caller
    kEplObdEvPostWrite             = 0x03,    // after writing an object                                destination data buffer in OD
//    kEplObdEvAbortSdo              = 0x05     // after an abort of an SDO transfer

} tEplObdEvent;

typedef unsigned int tEplObdSize; // For all objects as objects size are used an unsigned int.

// types of objects in object dictionary
// DS-301 defines these types as WORD
typedef enum
{
// types which are always supported
    kEplObdTypBool         = 0x0001,

    kEplObdTypInt8         = 0x0002,
    kEplObdTypInt16        = 0x0003,
    kEplObdTypInt32        = 0x0004,
    kEplObdTypUInt8        = 0x0005,
    kEplObdTypUInt16       = 0x0006,
    kEplObdTypUInt32       = 0x0007,
    kEplObdTypReal32       = 0x0008,
    kEplObdTypVString      = 0x0009,
    kEplObdTypOString      = 0x000A,
    kEplObdTypDomain       = 0x000F,

    kEplObdTypInt24        = 0x0010,
    kEplObdTypUInt24       = 0x0016,

    kEplObdTypReal64       = 0x0011,
    kEplObdTypInt40        = 0x0012,
    kEplObdTypInt48        = 0x0013,
    kEplObdTypInt56        = 0x0014,
    kEplObdTypInt64        = 0x0015,
    kEplObdTypUInt40       = 0x0018,
    kEplObdTypUInt48       = 0x0019,
    kEplObdTypUInt56       = 0x001A,
    kEplObdTypUInt64       = 0x001B,
    kEplObdTypTimeOfDay    = 0x000C,
    kEplObdTypTimeDiff     = 0x000D

} tEplObdType;

// access types for objects
// must be a difine because bit-flags
typedef unsigned int tEplObdAccess;

struct _tEplObdParam;

typedef struct _tEplObdParam tEplObdParam;

typedef tEplKernel (PUBLIC ROM* tEplObdCbAccessFinished) (/*EPL_MCO_DECL_INSTANCE_HDL_*/
    tEplObdParam MEM* pParam_p);

struct _tEplObdParam
{
    tEplObdEvent    m_ObdEvent;
    unsigned int    m_uiIndex;
    unsigned int    m_uiSubIndex;
    void *          m_pArg;             // obsolete
    DWORD           m_dwAbortCode;
    tEplSdoAddress* m_pRemoteAddress;   // pointer to caller identification
    void *          m_pData;
    tEplObdSize     m_TransferSize;     // transfer size from SDO or local app
    tEplObdSize     m_ObjSize;          // current object size from OD
    tEplObdSize     m_SegmentSize;
    tEplObdSize     m_SegmentOffset;

    tEplObdType     m_Type;
    tEplObdAccess   m_Access;

    void *          m_pHandle;
    tEplObdCbAccessFinished m_pfnAccessFinished;

};

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

