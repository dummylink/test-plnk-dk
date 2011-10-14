/**
********************************************************************************
\file       boot.c

\brief      firmware boot functions

This module contains all functions implementing the firmware boot process.

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

/******************************************************************************/
/* includes */
#include "EplInc.h"
#include "system.h"
#include "firmware.h"
#include "fwUpdate.h"

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
\brief  read image information block from flash

getIib() reads an image information block (IIB) from flash.

\param  pIib_p          pointer to store IIB
\param  uiIibAdrs       flash address of IIB

\return OK or ERROR if flash could not be read
*******************************************************************************/
static int getIib(tIib *pIib_p, UINT32 uiIibAdrs)
{
    alt_flash_fd *  pFlashInst = NULL;
    int iRet = OK;

    /* get pointer to flash instance structure */
    if ((pFlashInst = alt_flash_open_dev(FLASH_CTRL_NAME)) == NULL)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: Could not open Flash device!\n");
        iRet = ERROR;
        goto exit;
    }

    if (alt_read_flash(pFlashInst, uiIibAdrs, pIib_p, sizeof(tIib)) != 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: alt_read_flash() failed! \n");
        iRet = ERROR;
        goto exit;
    }

    alt_flash_close_dev(pFlashInst);

exit:
    return iRet;
}


/**
********************************************************************************
\brief  check CRC of block in flash

checkFlashCrc() checks the CRC of a data block in flash.

\param  uiFlashAdrs_p           flash address of data block
\param  uiSize_p                size of data block
\param  uiCrc_p                 CRC32 checksum of block

\return Returns OK if checksum could successfully verified or ERROR otherwise.
*******************************************************************************/
static int checkFlashCrc(UINT32 uiFlashAdrs_p, UINT32 uiSize_p, UINT32 uiCrc_p)
{
#define CRC_CALC_BUF_SIZE       256
    UINT32              uiCrc = 0;
    alt_flash_fd *      pFlashInst = NULL;
    int                 iRet = OK;
    char                buf[CRC_CALC_BUF_SIZE];
    UINT32              uiSize;

    DEBUG_TRACE3(DEBUG_LVL_ERROR, "Check Flash at:%08x size:%d CRC:%08x\n",
            uiFlashAdrs_p, uiSize_p, uiCrc_p);

    /* get pointer to flash instance structure */
    if ((pFlashInst = alt_flash_open_dev(FLASH_CTRL_NAME)) == NULL)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: Could not open Flash device!\n");
        iRet = ERROR;
        goto exit;
    }

    do {
        uiSize = uiSize_p > CRC_CALC_BUF_SIZE ? CRC_CALC_BUF_SIZE : uiSize_p;
        uiSize_p -= uiSize;

        if (alt_read_flash(pFlashInst, uiFlashAdrs_p, buf, uiSize) != 0)
        {
            DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: alt_read_flash() failed! \n");
            iRet = ERROR;
            alt_flash_close_dev(pFlashInst);
            goto exit;
        }


        /* check IIB crc */
        uiCrc = crc32(uiCrc, buf, uiSize);

        uiFlashAdrs_p += uiSize;

    } while(uiSize_p > 0);

    alt_flash_close_dev(pFlashInst);

    if (uiCrc != uiCrc_p)
    {
        iRet = ERROR;
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "Wrong CRC is %08x should be %08x\n", uiCrc, uiCrc_p);
    }

exit:
    return iRet;
}

/**
********************************************************************************
\brief  check firmware image

checkfwImage() checks if a valid firmware image is located in the flash memory.
It checks for a valid image information block (IIB) and verifies the checksum
of all image parts described in the IIB. The application software date/time
will be saved if pUiApplicationSwDate_p/pUiApplicationSwTime_p is not NULL.

\param  uiImgAdrs_p             flash address of firmware image
\param  uiIibAdrs_p             flash address of IIB
\param  uiIibVersion_p          version of IIB

\return OK, or ERROR if no valid IIB was found
*******************************************************************************/
int checkFwImage(UINT32 uiImgAdrs_p, UINT32 uiIibAdrs_p, UINT16 uiIibVersion_p)
{
    UINT32              uiCrc;
    tIib                iib;

    /* read IIB from flash */
    if (getIib(&iib, uiIibAdrs_p) < 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "Invalid IIB\n");
        return ERROR;
    }

    /* check IIB magic */
    if (AmiGetDwordFromBe(&iib.m_magic) != (IIB_MAGIC | uiIibVersion_p))
    {
        /* todo create individual error codes! */
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "Invalid IIB magic at %08x : %08x\n",
                     uiIibAdrs_p, AmiGetDwordFromBe(&iib.m_magic));

        return ERROR;

    }

    /* check IIB crc */
    uiCrc = crc32(0, &iib, sizeof(tIib) - sizeof(UINT32));
    if (uiCrc != AmiGetDwordFromBe(&iib.m_iibCrc))
    {
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "Invalid IIB CRC is %08x : should be %08x\n",
                     uiCrc, AmiGetDwordFromBe(&iib.m_iibCrc));
        return ERROR;
    }

#if 0
    /* we don't check the FPGA configuration to save time. If the FPGA
     * tries to reconfigure from user image and user image is invalid it
     * automatically falls back to factory image!
     */

    /* check CRC of FPGA configuration */
    if (checkFlashCrc (AmiGetDwordFromBe(&iib.m_fpgaConfigAdrs),
                       AmiGetDwordFromBe(&iib.m_fpgaConfigSize),
                       AmiGetDwordFromBe(&iib.m_fpgaConfigCrc)) == ERROR)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "Invalid FPGA configuration!\n");
        return ERROR;
    }
#endif

    /* check CRC of PCP software */
    if (checkFlashCrc (AmiGetDwordFromBe(&iib.m_pcpSwAdrs),
                       AmiGetDwordFromBe(&iib.m_pcpSwSize),
                       AmiGetDwordFromBe(&iib.m_pcpSwCrc)) == ERROR)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "Invalid PCP software!\n");
        return ERROR;
    }

    /* IIB version 2 contains an AP software also */
    if (uiIibVersion_p == 2)
    {
        /* check CRC of AP software */
        if (checkFlashCrc (AmiGetDwordFromBe(&iib.m_apSwAdrs),
                           AmiGetDwordFromBe(&iib.m_apSwSize),
                           AmiGetDwordFromBe(&iib.m_apSwCrc)) == ERROR)
        {
            DEBUG_TRACE0(DEBUG_LVL_ERROR, "Invalid AP software!\n");
            return ERROR;
        }
    }

    return OK;
}

/**
********************************************************************************
\brief  get application software date and time

getApplicationSwDateTime() reads the application software date and time from
the IIB and stores it at the specified locations.

\param  uiIibAdrs_p             flash address of IIB
\param  pUiApplicationSwDate_p  pointer to store application software date
\param  pUiApplicationSwTime_p  pointer to store application software time

\return OK, or ERROR if no valid IIB was found
*******************************************************************************/
int getApplicationSwDateTime(UINT32 uiIibAdrs_p, UINT32 *pUiApplicationSwDate_p,
                             UINT32 *pUiApplicationSwTime_p)
{
    UINT32              uiCrc;
    tIib                iib;

    /* read IIB from flash */
    if (getIib(&iib, uiIibAdrs_p) < 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "Invalid IIB\n");
        return ERROR;
    }

    /* check IIB magic */
    if ((AmiGetDwordFromBe(&iib.m_magic) & 0xFFFFFF00) != IIB_MAGIC)
    {
        /* todo create individual error codes! */
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "Invalid IIB magic at %08x : %08x\n",
                     uiIibAdrs_p, AmiGetDwordFromBe(&iib.m_magic));

        return ERROR;
    }

    /* check IIB crc */
    uiCrc = crc32(0, &iib, sizeof(tIib) - sizeof(UINT32));
    if (uiCrc != AmiGetDwordFromBe(&iib.m_iibCrc))
    {
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "Invalid IIB CRC is %08x : should be %08x\n",
                     uiCrc, AmiGetDwordFromBe(&iib.m_iibCrc));
        return ERROR;
    }

    /* store application software date and time */
    *pUiApplicationSwDate_p = AmiGetDwordFromBe(&iib.m_applicationSwDate);
    *pUiApplicationSwTime_p = AmiGetDwordFromBe(&iib.m_applicationSwTime);

    return OK;
}

/* END-OF-FILE */
