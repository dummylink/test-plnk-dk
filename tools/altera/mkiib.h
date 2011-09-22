/**
********************************************************************************
\file           mkiib.h

\brief          Main header file of Image Information Block creation tool

\author         Josef Baumgartner

\date           22.08.2011

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This header file contains definitions for the IIB creation tool.
*******************************************************************************/
#ifndef MKIIB_H_
#define MKIIB_H_

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

#endif /* MKIIB_H_ */
