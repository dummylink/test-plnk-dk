/**
********************************************************************************
\file       boot.c

\brief      firmware boot functions

\author     Josef Baumgartner

\date       06.09.2011

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This module contains all functions implementing the firmware boot process.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApiGlobal.h"
#include "system.h"
#include "../../include/firmware.h"
#include <sys/alt_flash.h>
#include <alt_types.h>
#include <errno.h>
#include <string.h>

/******************************************************************************/
/* defines */

/******************************************************************************/
/* function declarations */
UINT32 crc32(UINT32 uiCrc_p, const void *pBuf_p, unsigned int uiSize_p);

/**
********************************************************************************
\brief  check image information block

checkIib() checks if a valid image information block is located at pIib.
*******************************************************************************/
int checkIib(tIib *pIib_p, UINT8 uiVersion_p)
{
    UINT32              uiCrc;

    /* check magic and version number */
    if (pIib_p->m_magic != (IIB_MAGIC | uiVersion_p))
    {
        return ERROR;
    }

    /* check IIB crc */
    uiCrc = crc32(0, pIib_p, sizeof(tIib) - sizeof(UINT32));
    if (uiCrc != pIib_p->m_iibCrc)
    {
        return ERROR;
    }
}

