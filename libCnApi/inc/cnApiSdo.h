/**
********************************************************************************
\file       cnApiSdo.h

\brief      header for the SDO module

This header declares all SDO related defines in the libCnApi. It consists of the
SDO abort codes and other stuff.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPISDO_H_
#define CNAPISDO_H_

/******************************************************************************/
/* includes */

/******************************************************************************/
/* defines */

// SDO abort codes
typedef enum eCnApiSdoAbortCode
{
    kCnApiSdoacSuccessful = 0x0,
    kCnApiSdoacTimeOut = 0x05040000L,
    kCnApiSdoacUnknownCommandSpecifier = 0x05040001L,
    kCnApiSdoacInvalidBLockSize = 0x05040002L,
    kCnApiSdoacInvalidSequenceNumber = 0x05040003L,
    kCnApiSdoacOutOfMemory = 0x05040005L,
    kCnApiSdoacUnsupportedAccess = 0x06010000L,
    kCnApiSdoacReadToWriteOnlyObj = 0x06010001L,
    kCnApiSdoacWriteToReadOnlyObj = 0x06010002L,
    kCnApiSdoacObjectNotExist = 0x06020000L,
    kCnApiSdoacObjectNotMappable = 0x06040041L,
    kCnApiSdoacPdoLengthExceeded = 0x06040042L,
    kCnApiSdoacGenParamIncompatibility = 0x06040043L,
    kCnApiSdoacInvalidHeadtbeatDec = 0x06040044L,
    kCnApiSdoacGenInternalIncompatibility = 0x06040047L,
    kCnApiSdoacAccessFailedDueHwError = 0x06060000L,
    kCnApiSdoacDataTypeLengthNotMatch = 0x06070010L,
    kCnApiSdoacDataTypeLengthTooHigh = 0x06070012L,
    kCnApiSdoacDataTypeLengthTooLow = 0x06070013L,
    kCnApiSdoacSubIndexNotExist = 0x06090011L,
    kCnApiSdoacValueRangeExceeded = 0x06090030L,
    kCnApiSdoacValueRangeTooHigh = 0x06090031L,
    kCnApiSdoacValueRangeTooLow = 0x06090032L,
    kCnApiSdoacMaxValueLessMinValue = 0x06090036L,
    kCnApiSdoacGeneralError = 0x08000000L,
    kCnApiSdoacDataNotTransfOrStored = 0x08000020L,
    kCnApiSdoacDataNotTransfDueLocalControl = 0x08000021L,
    kCnApiSdoacDataNotTransfDueDeviceState = 0x08000022L,
    kCnApiSdoacObjectDictionaryNotExist = 0x08000023L,
    kCnApiSdoacConfigDataEmpty = 0x08000024L,
} tCnApiSdoAbortCode;

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

#endif /*  CNAPISDO_H_ */

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

