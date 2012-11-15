/**
********************************************************************************
\file           firmware.h

\brief          Header file contains definitions for firmware update function

This header file contains definitions for the firmware update functions.

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

#ifndef FIRMWARE_H_
#define FIRMWARE_H_

/******************************************************************************/
/* includes */
#include "global.h"

/******************************************************************************/
/* defines */
#define         FW_HEADER_MAGIC         0x4657          ///< magic "FW"
#define         FW_HEADER_VERSION       0x0100          ///< version 1.0

#define         IIB_MAGIC               0x49494200      ///< IIB
#define         IIB_MAGIC_V2            0x49494202      ///< IIB version 2

/******************************************************************************/
/* type definitions */

/**
* tFwHeader defines the header of a firmware file
*/
typedef struct {
    UINT16      m_magic;                ///< magic number ("FW")
    UINT16      m_version;              ///< header version number
    UINT32      m_deviceId;             ///< device Id
    UINT32      m_hwRevision;           ///< hardware revision
    UINT32      m_applicationSwDate;    ///< application software date
    UINT32      m_applicationSwTime;    ///< application software time
    UINT32      m_fpgaConfigVersion;    ///< version of fpga configuration
    UINT32      m_fpgaConfigSize;       ///< size of fpga configuration
    UINT32      m_fpgaConfigCrc;        ///< CRC32 checksum of fpga configuration
    UINT32      m_pcpSwVersion;         ///< version of PCP software
    UINT32      m_pcpSwSize;            ///< size of PCP software
    UINT32      m_pcpSwCrc;             ///< CRC32 checkusm of PCP software
    UINT32      m_apSwVersion;          ///< version of AP software
    UINT32      m_apSwSize;             ///< size of AP software
    UINT32      m_apSwCrc;              ///< CRC32 checksum of AP software
    UINT32      m_reserved;             ///< reserved
    UINT32      m_headerCrc;            ///< CRC32 checksum of firmware header
} tFwHeader;

/**
 * tIib defines the image information block
 */
typedef struct {
    UINT32      m_magic;                ///< magic number and version "IIBx"
    UINT32      m_applicationSwDate;    ///< application software date
    UINT32      m_applicationSwTime;    ///< application software time
    UINT32      m_fpgaConfigVersion;    ///< version of fpga configuration
    UINT32      m_fpgaConfigAdrs;       ///< address of fpga configuration
    UINT32      m_fpgaConfigSize;       ///< size of fpga configuration
    UINT32      m_fpgaConfigCrc;        ///< CRC32 checksum of fpga configuration
    UINT32      m_pcpSwVersion;         ///< version of PCP software
    UINT32      m_pcpSwAdrs;            ///< address of PCP software
    UINT32      m_pcpSwSize;            ///< size of PCP software
    UINT32      m_pcpSwCrc;             ///< CRC32 checkusm of PCP software
    UINT32      m_apSwVersion;          ///< version of AP software
    UINT32      m_apSwAdrs;             ///< address of AP software
    UINT32      m_apSwSize;             ///< size of AP software
    UINT32      m_apSwCrc;              ///< CRC32 checksum of AP software
    UINT8       m_reserved[64];         ///< reserved for future use
    UINT32      m_iibCrc;               ///< checksum of IIB
} tIib;

typedef enum eFirmwareRetVal {
  kFwRetSuccessful,
  kFwRetInvalidIib,
  kFwRetInvalidIibMagic,
  kFwRetInvalidIibCrc,
  kFwRetInvalidIibPcpFpgaCrc,
  kFwRetInvalidIibPcpSwCrc,
  kFwRetInvalidIibApCrc,
  kFwRetInvalidBlockCrc,
  kFwRetFlashAccessError,
  kFwRetGeneralError,
} tFwRet;

#endif /* FIRMWARE_H_ */

/* END-OF-FILE */
