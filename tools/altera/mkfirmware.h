/**
********************************************************************************
\file           mkfirmware.h

\brief          Main header file of firmware creation tool

This header file contains definitions for the firmware creation and update
functions.

********************************************************************************

License Agreement

Copyright (C) 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved.

Redistribution and use in source and binary forms,
with or without modification,
are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer
    in the documentation and/or other materials provided with the
    distribution.
  * Neither the name of the B&R nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*******************************************************************************/

#ifndef MKFIRMWARE_H_
#define MKFIRMWARE_H_

/******************************************************************************/
/* includes */

/******************************************************************************/
/* defines */
#define MAX_NAME_LEN          256       ///< length of filename strings

/******************************************************************************/
/* type definitions */

/**
* tOptions defines a type for storing all command line options
*/
typedef struct {
    char        m_fpgaCfgName[MAX_NAME_LEN];
    char        m_pcpSwName[MAX_NAME_LEN];
    char        m_apSwName[MAX_NAME_LEN];
    char        m_outFileName[MAX_NAME_LEN];
    UINT32      m_deviceId;
    UINT32      m_hwRevision;
    BOOL        m_fPrintInfo;
    UINT32      m_applicationSwDate;
    UINT32      m_applicationSwTime;
    UINT32      m_fpgaConfigVersion;
    UINT32      m_pcpSwVersion;
    UINT32      m_apSwVersion;
} tOptions;

/******************************************************************************/
/* function declarations */
extern UINT32 crc32(UINT32 uiCrc_p, const void *pBuf_p, unsigned int uiSize_p);

#endif /* MKFIRMWARE_H_ */

/* END-OF-FILE */

