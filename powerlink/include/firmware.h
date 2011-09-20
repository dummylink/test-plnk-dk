/**
********************************************************************************
\file           firmware.h

\brief          Header file contains definitions for firmware update function

\author         Josef Baumgartner

\date           22.08.2011

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This header file contains definitions for the firmware update functions.
*******************************************************************************/
#ifndef FIRMWARE_H_
#define FIRMWARE_H_

/******************************************************************************/
/* includes */
#include "cnApiGlobal.h"

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


#endif /* FIRMWARE_H_ */
