/**
********************************************************************************
\file           mkfirmware.h

\brief          Main header file of firmware creation tool

\author         Josef Baumgartner

\date           22.08.2011

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This header file contains definitions for the firmware creation and update
functions.
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
