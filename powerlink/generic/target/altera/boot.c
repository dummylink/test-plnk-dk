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

\param  uiIibAdrs       flash address of IIB
\param  pIib_p          pointer to store IIB
\param  pUiCrc_p        pointer to store calculated IIB checksum (platform byte order)

\return OK or ERROR if flash could not be read
*******************************************************************************/
static tFwRet getIib(UINT32 uiIibAdrs, tIib *pIib_p, UINT32 *pUiCrc_p)
{
    alt_flash_fd *  pFlashInst = NULL;
    tFwRet Ret = kFwRetSuccessful;
    tIib    iibBigEndian;

    /* get pointer to flash instance structure */
    if ((pFlashInst = alt_flash_open_dev(FLASH_CTRL_NAME)) == NULL)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: Could not open Flash device!\n");
        Ret = kFwRetFlashAccessError;
        goto exit;
    }

    if (alt_read_flash(pFlashInst, uiIibAdrs, &iibBigEndian, sizeof(tIib)) != 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: alt_read_flash() failed! \n");
        Ret = kFwRetFlashAccessError;
        goto exit;
    }

    alt_flash_close_dev(pFlashInst);

    /* calculate checksum of IIB */
    /* don not consider CRC value itself */
    *pUiCrc_p = crc32(0, &iibBigEndian, sizeof(tIib) - sizeof(UINT32));

    pIib_p->m_magic = iibBigEndian.m_magic; // this is as string, so don't consider endian
    pIib_p->m_applicationSwDate = AmiGetDwordFromBe(&iibBigEndian.m_applicationSwDate);
    pIib_p->m_applicationSwTime = AmiGetDwordFromBe(&iibBigEndian.m_applicationSwTime);
    pIib_p->m_fpgaConfigCrc = AmiGetDwordFromBe(&iibBigEndian.m_fpgaConfigCrc);
    pIib_p->m_fpgaConfigSize = AmiGetDwordFromBe(&iibBigEndian.m_fpgaConfigSize);
    pIib_p->m_fpgaConfigAdrs = AmiGetDwordFromBe(&iibBigEndian.m_fpgaConfigAdrs);
    pIib_p->m_fpgaConfigVersion = AmiGetDwordFromBe(&iibBigEndian.m_fpgaConfigVersion);

    pIib_p->m_pcpSwCrc = AmiGetDwordFromBe(&iibBigEndian.m_pcpSwCrc);
    pIib_p->m_pcpSwSize = AmiGetDwordFromBe(&iibBigEndian.m_pcpSwSize);
    pIib_p->m_pcpSwAdrs = AmiGetDwordFromBe(&iibBigEndian.m_pcpSwAdrs);
    pIib_p->m_pcpSwVersion = AmiGetDwordFromBe(&iibBigEndian.m_pcpSwVersion);

    if (pIib_p->m_magic == IIB_MAGIC_V2)
    {
        pIib_p->m_apSwCrc = AmiGetDwordFromBe(&iibBigEndian.m_apSwCrc);
        pIib_p->m_apSwSize = AmiGetDwordFromBe(&iibBigEndian.m_apSwSize);
        pIib_p->m_apSwSize = AmiGetDwordFromBe(&iibBigEndian.m_apSwSize);
        pIib_p->m_apSwAdrs = AmiGetDwordFromBe(&iibBigEndian.m_apSwAdrs);
        pIib_p->m_apSwVersion = AmiGetDwordFromBe(&iibBigEndian.m_apSwVersion);
    }

    pIib_p->m_iibCrc = AmiGetDwordFromBe(&iibBigEndian.m_iibCrc);

exit:
    return Ret;
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
static tFwRet checkFlashCrc(UINT32 uiFlashAdrs_p, UINT32 uiSize_p, UINT32 uiCrc_p)
{
#define CRC_CALC_BUF_SIZE       256
    UINT32              uiCrc = 0;
    alt_flash_fd *      pFlashInst = NULL;
    tFwRet              Ret = kFwRetSuccessful;
    char                buf[CRC_CALC_BUF_SIZE];
    UINT32              uiSize;

    DEBUG_TRACE3(DEBUG_LVL_ALWAYS, "Check Flash at:0x%08x size:%d CRC:0x%08x\n",
            uiFlashAdrs_p, uiSize_p, uiCrc_p);

    /* get pointer to flash instance structure */
    if ((pFlashInst = alt_flash_open_dev(FLASH_CTRL_NAME)) == NULL)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: Could not open Flash device!\n");
        Ret = kFwRetFlashAccessError;
        goto exit;
    }

    do {
        uiSize = uiSize_p > CRC_CALC_BUF_SIZE ? CRC_CALC_BUF_SIZE : uiSize_p;
        uiSize_p -= uiSize;

        if (alt_read_flash(pFlashInst, uiFlashAdrs_p, buf, uiSize) != 0)
        {
            DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: alt_read_flash() failed! \n");
            Ret = kFwRetFlashAccessError;
            alt_flash_close_dev(pFlashInst);
            goto exit;
        }


        /* check crc of the block */
        uiCrc = crc32(uiCrc, buf, uiSize);

        uiFlashAdrs_p += uiSize;

    } while(uiSize_p > 0);

    alt_flash_close_dev(pFlashInst);

    if (uiCrc != uiCrc_p)
    {
        Ret = kFwRetInvalidBlockCrc;
        DEBUG_TRACE3(DEBUG_LVL_ERROR, "Wrong CRC at 0x%08x is 0x%08x should be 0x%08x\n", uiFlashAdrs_p, uiCrc, uiCrc_p);
    }

exit:
    return Ret;
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
tFwRet checkFwImage(UINT32 uiImgAdrs_p, UINT32 uiIibAdrs_p, UINT16 uiIibVersion_p)
{
    UINT32              uiCrc;
    tIib                iib;
    tFwRet Ret = kFwRetSuccessful;

    /* read IIB from flash */
    Ret = getIib(uiIibAdrs_p, &iib, &uiCrc);
    if (Ret != kFwRetSuccessful)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "Invalid IIB\n");
        return Ret;
    }

    /* check IIB magic */
    if (iib.m_magic != (IIB_MAGIC | uiIibVersion_p))
    {
        DEBUG_TRACE3(DEBUG_LVL_ERROR, "Invalid IIB magic at 0x%08x. Is: 0x%08x Expected: 0x%08x\n",
                     uiIibAdrs_p, iib.m_magic, (IIB_MAGIC | uiIibVersion_p));

        return kFwRetInvalidIibMagic;

    }
    else
    {
        DEBUG_TRACE1(DEBUG_LVL_15, "IIB magic 0x%08x OK!\n",
                     iib.m_magic);
    }

    /* check IIB crc */
    if (iib.m_iibCrc != uiCrc)
    {
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "Invalid IIB CRC is 0x%08x : should be 0x%08x\n",
                     uiCrc, iib.m_iibCrc);
        return kFwRetInvalidIibCrc;
    }
    DEBUG_TRACE1(DEBUG_LVL_15, "IIB CRC 0x%08x OK!\n", uiCrc);

#if 0
    /* we don't check the FPGA configuration to save time. If the FPGA
     * tries to reconfigure from user image and user image is invalid it
     * automatically falls back to factory image!
     */

    /* check CRC of FPGA configuration */
    if (checkFlashCrc (iib.m_fpgaConfigAdrs,
                       iib.m_fpgaConfigSize,
                       iib.m_fpgaConfigCrc) == ERROR)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "Invalid FPGA configuration!\n");
        return kFwRetInvalidIibPcpFpgaCrc;
    }
#endif

    /* check CRC of PCP software */
    DEBUG_TRACE3(DEBUG_LVL_15, "Check PCP SW, Adrs:0x%08x, Size:0x%08x, CRC:0x%08x\n",
                 iib.m_pcpSwAdrs, iib.m_pcpSwSize, iib.m_pcpSwCrc);
    if (checkFlashCrc (iib.m_pcpSwAdrs,
                       iib.m_pcpSwSize,
                       iib.m_pcpSwCrc) == ERROR)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "Invalid PCP software!\n");
        return kFwRetInvalidIibPcpSwCrc;
    }

    /* IIB version 2 contains an AP software also */
    if (uiIibVersion_p == 2)
    {
        /* check CRC of AP software */
        if (checkFlashCrc (iib.m_apSwAdrs,
                           iib.m_apSwSize,
                           iib.m_apSwCrc) == ERROR)
        {
            DEBUG_TRACE0(DEBUG_LVL_ERROR, "Invalid AP software!\n");
            return kFwRetInvalidIibApCrc;
        }
    }

    return kFwRetSuccessful;
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
tFwRet getApplicationSwDateTime(UINT32 uiIibAdrs_p, UINT32 *pUiApplicationSwDate_p,
                             UINT32 *pUiApplicationSwTime_p)
{
    UINT32              uiCrc;
    tIib                iib;
    tFwRet Ret = kFwRetSuccessful;

    /* read IIB from flash */
    Ret = getIib(uiIibAdrs_p, &iib, &uiCrc);
    if (Ret != kFwRetSuccessful)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "Invalid IIB\n");
        return Ret;
    }

    /* check IIB magic */
    if ((iib.m_magic & 0xFFFFFF00) != IIB_MAGIC)
    {
        return kFwRetInvalidIibMagic;
    }

    /* check IIB crc */
    if (uiCrc != iib.m_iibCrc)
    {
        return kFwRetInvalidIibCrc;
    }

    /* store application software date and time */
    *pUiApplicationSwDate_p = iib.m_applicationSwDate;
    *pUiApplicationSwTime_p = iib.m_applicationSwTime;

    return kFwRetSuccessful;
}

/**
********************************************************************************
\brief  get software versions

This function reads the software version stored in the IIB. It stores the
version at the specified pointer if it is not NULL. The AP software version
is only stored if the IIB version is 2 otherwise a 0 is returned.

\param  uiIibAdrs_p             flash address of IIB
\param  pUiFpgaConfigVersion_p  pointer to store FPGA configuration version
\param  pUiPcpSwVersion_p       pointer to store PCP software version
\param  pUiapSwVersion_p        pointer to store AP software version

\return OK, or ERROR if no valid IIB was found
*******************************************************************************/
tFwRet getSwVersions(UINT32 uiIibAdrs_p, UINT32 *pUiFpgaConfigVersion_p,
                  UINT32 *pUiPcpSwVersion_p, UINT32 *pUiApSwVersion_p)
{
    UINT32              uiCrc;
    tIib                iib;
    tFwRet Ret = kFwRetSuccessful;

    /* read IIB from flash */
    Ret = getIib(uiIibAdrs_p, &iib, &uiCrc);
    if (Ret != kFwRetSuccessful)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "Invalid IIB\n");
        return Ret;
    }

    /* check IIB magic */
    if ((iib.m_magic & 0xFFFFFF00) != IIB_MAGIC)
    {
        return kFwRetInvalidIibMagic;
    }

    /* check IIB crc */
    if (uiCrc != iib.m_iibCrc)
    {
        return kFwRetInvalidIibCrc;
    }

    /* store application software date and time */
    if (pUiFpgaConfigVersion_p != NULL)
    {
        *pUiFpgaConfigVersion_p = iib.m_fpgaConfigVersion;
    }

    if (pUiPcpSwVersion_p != NULL)
    {
        *pUiPcpSwVersion_p = iib.m_pcpSwVersion;
    }

    if (iib.m_magic & 0xff == 2)
    {

        if (pUiApSwVersion_p != NULL)
        {

            *pUiApSwVersion_p = iib.m_apSwVersion;
        }
        else
        {
            *pUiApSwVersion_p = 0;
        }
    }

    return kFwRetSuccessful;
}

/* END-OF-FILE */
