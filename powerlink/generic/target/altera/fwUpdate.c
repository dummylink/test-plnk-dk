/**
********************************************************************************
\file       update.c

\brief      firmware update functions

This module contains firmware update functions.
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

//#include "cnApiGlobal.h"
//#include "cnApiDebug.h"
#include "system.h"
#include <sys/alt_flash.h>
#include <alt_types.h>
#include <errno.h>
#include <string.h>

#include "../../include/firmware.h"
#include "fwUpdate.h"

/*TODO only for debugging */
#include "EplObd.h"

/******************************************************************************/
/* defines */

/* check if a flag in a variable is set */
#define FLAG_ISSET(VAR,FLAG)          ((VAR & FLAG) == FLAG)

/******************************************************************************/
/* type definitions */

/**
 *  valid result values for update function
 */
typedef enum {
    eUpdateResultAbort =        0x0001,
    eUpdateResultPending =      0x0002,
    eUpdateResultSegFinish =    0x0004,
    eUpdateResultPartFinish =   0x0008,
    eUpdateResultCRCErr =       0x0010,
    eUpdateResultEraseFinish =  0x0020
} tUpdateResult;

/**
 * states of update state machine
 */
typedef enum {
    eUpdateStateNone = 0,
    eUpdateStateStart,
    eUpdateStateFpga,
    eUpdateStatePcp,
    eUpdateStateAp,
    eUpdateStateIib
} tUpdateState;

/**
 * structure with information needed by the update state machine
 */
typedef struct {
    UINT32              m_uiDeviceId;
    UINT32              m_uiHwRev;
    UINT32              m_uiUserImageOffset;
    UINT32              m_uiSectorSize;
    char *              m_pData;
    UINT32              m_uiDataSize;
    UINT32              m_uiEraseOffset;
    UINT32              m_uiProgOffset;
    UINT32              m_uiRemainingSize;
    UINT32              m_uiCrc;
    void                (*m_pfnAbortCb)();
    void                (*m_pfnSegFinishCb)();
    void *              m_pHandle;
    UINT32              m_uiUpdateState;
    alt_flash_fd *      m_flashFd;
    UINT32              m_uiLastSegmentOffset;
} tUpdateInfo;

/******************************************************************************/
/* external variables */
tFwHeader fwHeader_g;
tUpdateInfo updateInfo_g;

/******************************************************************************/
/* function declarations */
UINT32 crc32(UINT32 uiCrc_p, const void *pBuf_p, unsigned int uiSize_p);

/******************************************************************************/
/* privat functions */

/**
********************************************************************************
\brief	get firmware header

getFwHeader() reads the firmware header checks if it is valid and copies it
to the global variable fwHeader_g for further reference.

\param  pHeader_p               Pointer to the data block containing
                                the firmware header
\param  deviceId_p              The device Id to check for
\param  hwRev_p                 The hardware revision to check for

\return ERROR if no valid firmware header is found, OK otherwise
*******************************************************************************/
static int getFwHeader(tFwHeader *pHeader_p, UINT32 deviceId_p, UINT32 hwRev_p)
{
    UINT32      uiCrc;

    /* check header CRC */
    uiCrc = crc32(0, pHeader_p, sizeof(tFwHeader) - sizeof(UINT32));

    if (uiCrc != AmiGetDwordFromBe(&pHeader_p->m_headerCrc))
    {
        /* wrong CRC */
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "Header CRC is %08x, should be %08x\n",
                     uiCrc, (UINT32)AmiGetDwordFromBe(&pHeader_p->m_headerCrc));
        return ERROR;
    }

    /* check header version and magic */
    if ((AmiGetWordFromBe(&pHeader_p->m_magic) != FW_HEADER_MAGIC) ||
        (AmiGetWordFromBe(&pHeader_p->m_version) != FW_HEADER_VERSION))
    {
        /* invalid firmware format */
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "Invalid Magic/Version is %04x %04x\n",
                     AmiGetWordFromBe(&pHeader_p->m_magic),
                     AmiGetWordFromBe(&pHeader_p->m_version));
        return ERROR;
    }

    /* check device ID and hardware revision */
    if ((AmiGetDwordFromBe(&pHeader_p->m_deviceId) != deviceId_p) ||
        (AmiGetDwordFromBe(&pHeader_p->m_hwRevision) != hwRev_p))
    {
        /* firmware for another device or hardware revision */
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "Invalid Device HWRev is %08x %08x\n",
                     (UINT32)AmiGetDwordFromBe(&pHeader_p->m_deviceId),
                     (UINT32)AmiGetDwordFromBe(&pHeader_p->m_hwRevision));
        return ERROR;
    }

    /* save header */
    fwHeader_g.m_magic = AmiGetWordFromBe(&pHeader_p->m_magic);
    fwHeader_g.m_version = AmiGetWordFromBe(&pHeader_p->m_version);
    fwHeader_g.m_deviceId = AmiGetDwordFromBe(&pHeader_p->m_deviceId);
    fwHeader_g.m_hwRevision = AmiGetDwordFromBe(&pHeader_p->m_hwRevision);
    fwHeader_g.m_applicationSwDate = AmiGetDwordFromBe(&pHeader_p->m_applicationSwDate);
    fwHeader_g.m_applicationSwTime = AmiGetDwordFromBe(&pHeader_p->m_applicationSwTime);
    fwHeader_g.m_fpgaConfigVersion = AmiGetDwordFromBe(&pHeader_p->m_fpgaConfigVersion);
    fwHeader_g.m_fpgaConfigSize = AmiGetDwordFromBe(&pHeader_p->m_fpgaConfigSize);
    fwHeader_g.m_fpgaConfigCrc = AmiGetDwordFromBe(&pHeader_p->m_fpgaConfigCrc);
    fwHeader_g.m_pcpSwVersion = AmiGetDwordFromBe(&pHeader_p->m_pcpSwVersion);
    fwHeader_g.m_pcpSwSize = AmiGetDwordFromBe(&pHeader_p->m_pcpSwSize);
    fwHeader_g.m_pcpSwCrc = AmiGetDwordFromBe(&pHeader_p->m_pcpSwCrc);
    fwHeader_g.m_apSwVersion = AmiGetDwordFromBe(&pHeader_p->m_apSwVersion);
    fwHeader_g.m_apSwSize = AmiGetDwordFromBe(&pHeader_p->m_apSwSize);
    fwHeader_g.m_apSwCrc = AmiGetDwordFromBe(&pHeader_p->m_apSwCrc);
    fwHeader_g.m_headerCrc = AmiGetDwordFromBe(&pHeader_p->m_headerCrc);

    DEBUG_TRACE0(DEBUG_LVL_15, "fwHeader:\n");
    DEBUG_TRACE1(DEBUG_LVL_15, "Device ID:             %d\n", fwHeader_g.m_deviceId);
    DEBUG_TRACE1(DEBUG_LVL_15, "Hardware Revision:     %d\n", fwHeader_g.m_hwRevision);
    DEBUG_TRACE1(DEBUG_LVL_15, "FPGA Config Size:      %d\n", fwHeader_g.m_fpgaConfigSize);
    DEBUG_TRACE1(DEBUG_LVL_15, "PCP SW Size:           %d\n", fwHeader_g.m_pcpSwSize);
    DEBUG_TRACE1(DEBUG_LVL_15, "AP SW Size:            %d\n", fwHeader_g.m_apSwSize);

    return OK;
}

/**
********************************************************************************
\brief  abort update

abortUpdate() will be called to abort the update. It calls the abort callback
function, closes the flash device and resets the state machine to the
default state.
*******************************************************************************/
static void abortUpdate(void)
{
    /* call abort callback function */
    updateInfo_g.m_pfnAbortCb(updateInfo_g.m_pHandle);

    /* close the flash device */
    alt_flash_close_dev(updateInfo_g.m_flashFd);

    /* reset state */
    updateInfo_g.m_uiUpdateState = eUpdateStateNone;
}

/**
********************************************************************************
\brief  program flash and calculate CRC

programFlashCrc() programs a data block into flash and calculates the CRC
checksum of the programmed block.

\param  flashFd_p               flash memory device descriptor
\param  pData_p                 pointer to data block
\param  uiDataSize_p            size of the data block
\param  uiProgOffset_p          address in flash memory to program the block to
\param  pCrc_p                  pointer to store the calculated checksum
*******************************************************************************/
static void programFlashCrc(alt_flash_fd * flashFd_p, char * pData_p,
                            UINT32 uiDataSize_p, UINT32 uiProgOffset_p,
                            UINT32 * pCrc_p)
{
    UINT32      crc;

    /* calculate CRC of block */
    crc = crc32(*pCrc_p, pData_p, uiDataSize_p);

    /* write data to flash */
    alt_write_flash(flashFd_p, uiProgOffset_p, pData_p, uiDataSize_p);

    *pCrc_p = crc;
}

/**
********************************************************************************
\brief  erase flash

eraseFlash() erases a flash memory block. The block to be specified must be
sector aligned!

\param  flashFd_p               flash memory device descriptor
\param  pSector_p               start address of erase block
\param  uiSize_p                size of the erase block

\return forwards return value delivered by alt_erase_flash_block()
*******************************************************************************/
static int eraseFlash(alt_flash_fd * flashFd_p, UINT32 uiSector_p, UINT32 uiSize_p)
{
    int         iRet;

    //printf ("erase at: %08x\n", uiSector_p);
    //return 0;

    iRet = alt_erase_flash_block(flashFd_p, uiSector_p, uiSize_p);

    return iRet;
}

/**
********************************************************************************
\brief  program firmware data into flash

programFirmware() is called to program the firmware data into flash memory.

\retval eUpdateResultPending
\retval eUpdateResultAbort
\retval eUpdateResultSegFinish
\retval eUpdateResultPartFinish
*******************************************************************************/
static int programFirmware(void)
{
    int         iRet;
    int         iResult = eUpdateResultPending;
    int         size;

    /* check if data is available */
    if (updateInfo_g.m_uiDataSize == 0)
    {
        return eUpdateResultPending;
    }

    /* If we are on a sector boundary we have to erase the sector first */
    if (updateInfo_g.m_uiEraseOffset == updateInfo_g.m_uiProgOffset)
    {
        iRet = eraseFlash(updateInfo_g.m_flashFd,
                          updateInfo_g.m_uiEraseOffset,
                          updateInfo_g.m_uiSectorSize);

        switch (iRet)
        {
        case -EAGAIN:
            /* erase not finished, return pending */
            return eUpdateResultPending;
            break;

        case 0:
            /* sector was successfully erased, increase erase Offset */
            updateInfo_g.m_uiEraseOffset += updateInfo_g.m_uiSectorSize;
            break;

        case -EIO:
        default:
            /* error occured, return abort */
            DEBUG_TRACE0(DEBUG_LVL_15, "Abort\n");
            return eUpdateResultAbort;
            break;
        }
    }

    /* check if the segment contains data of the next image part */
    if (updateInfo_g.m_uiRemainingSize > updateInfo_g.m_uiDataSize)
    {
        /* segment contains only data of the current image part */

        /* check if the segment crosses the next sector boundary*/
        if (updateInfo_g.m_uiProgOffset + updateInfo_g.m_uiDataSize <=
            updateInfo_g.m_uiEraseOffset)
        {
            /* All data is located in the same sector and could be
             * immediately programmed */
            programFlashCrc(updateInfo_g.m_flashFd,
                            updateInfo_g.m_pData, updateInfo_g.m_uiDataSize,
                            updateInfo_g.m_uiProgOffset, &updateInfo_g.m_uiCrc);
            DEBUG_TRACE2(DEBUG_LVL_15, "%s Programmed all %d Bytes\n",
                         __func__, updateInfo_g.m_uiDataSize);

            updateInfo_g.m_uiProgOffset += updateInfo_g.m_uiDataSize;
            updateInfo_g.m_uiRemainingSize -= updateInfo_g.m_uiDataSize;
            updateInfo_g.m_uiDataSize = 0; // all data of segment is programmed

            /* check if next segment will start on a sector boundary so we
             * can start the erase cycle immediately */
            if (updateInfo_g.m_uiEraseOffset == updateInfo_g.m_uiProgOffset)
            {
                iRet = eraseFlash(updateInfo_g.m_flashFd,
                                  updateInfo_g.m_uiEraseOffset,
                                  updateInfo_g.m_uiSectorSize);
                if (iRet == -EIO)
                {
                    DEBUG_TRACE0(DEBUG_LVL_15, "Abort\n");
                    iResult = eUpdateResultAbort;
                }
                else
                {
                    if (iRet == 0)
                    {
                        DEBUG_TRACE0(DEBUG_LVL_15, "Erased Sector!\n");
                        /* sector was successfully erased, increas erase Offset */
                        updateInfo_g.m_uiEraseOffset += updateInfo_g.m_uiSectorSize;
                    }
                    DEBUG_TRACE0(DEBUG_LVL_15, "Segment finished!\n");
                    iResult = eUpdateResultSegFinish;
                }
            }
            else
            {
                iResult = eUpdateResultSegFinish;
            }
        }
        else
        {
            /* Data crosses a sector boundary. Only data in this sector
             * can be programmed. Then an erase of the next sector is
             * initiated */

            size = updateInfo_g.m_uiEraseOffset - updateInfo_g.m_uiProgOffset;

            programFlashCrc(updateInfo_g.m_flashFd,
                            updateInfo_g.m_pData, size,
                            updateInfo_g.m_uiProgOffset, &updateInfo_g.m_uiCrc);
            DEBUG_TRACE2(DEBUG_LVL_15, "%s Programmed %d Bytes up to sector boundary\n",
                         __func__, size);

            updateInfo_g.m_uiProgOffset += size;
            updateInfo_g.m_uiRemainingSize -= size;
            updateInfo_g.m_uiDataSize -= size;
            updateInfo_g.m_pData += size;

            iRet = eraseFlash(updateInfo_g.m_flashFd,
                              updateInfo_g.m_uiEraseOffset,
                              updateInfo_g.m_uiSectorSize);
            if (iRet == -EIO)
            {
                DEBUG_TRACE0(DEBUG_LVL_15, "Abort!\n");
                iResult = eUpdateResultAbort;
            }
            else
            {
                if (iRet == 0)
                {
                    DEBUG_TRACE0(DEBUG_LVL_15, "Erase Sector!\n");
                    /* sector was successfully erased, increase erase Offset */
                    updateInfo_g.m_uiEraseOffset += updateInfo_g.m_uiSectorSize;
                }
                iResult = eUpdateResultPending;
            }
        }
    }
    else
    {
        /* Segment crosses an firmware image part boundary
         * Only program data of current image part. */

        /* check if the segment crosses the next sector boundary*/
        if (updateInfo_g.m_uiProgOffset + updateInfo_g.m_uiDataSize <=
            updateInfo_g.m_uiEraseOffset)
        {
            /* All data of the image part is located in the same sector and
             * could be immediately programmed, so this image part is finished. */
            size = updateInfo_g.m_uiRemainingSize;

            programFlashCrc(updateInfo_g.m_flashFd,
                            updateInfo_g.m_pData, size,
                            updateInfo_g.m_uiProgOffset,&updateInfo_g.m_uiCrc);
            DEBUG_TRACE2(DEBUG_LVL_15, "%s Programmed %d Bytes up to part boundary\n",
                         __func__, size);

            updateInfo_g.m_uiProgOffset += size;
            updateInfo_g.m_uiRemainingSize -= size;
            updateInfo_g.m_uiDataSize -= size;
            updateInfo_g.m_pData += size;

            /* We don't erase the next sector even if we are on a sector
             * boundary because we don't know if the next image part is
             * also stored in flash or somewhere else! If it is located
             * also in this flash it will be automatically be erased on
             * the next call. */
            if (updateInfo_g.m_uiDataSize == 0)
            {
                DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Segment/Part finished!\n");
                /* Segment finished and image part finished */
                iResult = eUpdateResultPartFinish | eUpdateResultSegFinish;
            }
            else
            {
                /* Image part finished, but segment contains data of next
                 * part. */
                DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Part finished!\n");
                iResult = eUpdateResultPartFinish;
            }
        }
        else
        {
            /* Data crosses a sector boundary. Only data in this sector
             * can be programmed. Then an erase of the next sector is
             * initiated */
            size = updateInfo_g.m_uiEraseOffset - updateInfo_g.m_uiProgOffset;

            programFlashCrc(updateInfo_g.m_flashFd,
                            updateInfo_g.m_pData, size,
                            updateInfo_g.m_uiProgOffset, &updateInfo_g.m_uiCrc);
            DEBUG_TRACE2(DEBUG_LVL_15, "%s Programmed %d Bytes up to segment boundary\n",
                         __func__, size);

            updateInfo_g.m_uiProgOffset += size;
            updateInfo_g.m_uiRemainingSize -= size;
            updateInfo_g.m_uiDataSize -= size;
            updateInfo_g.m_pData += size;

            iRet = eraseFlash(updateInfo_g.m_flashFd,
                                                 updateInfo_g.m_uiEraseOffset,
                                                 updateInfo_g.m_uiSectorSize);
            if (iRet == -EIO)
            {
                DEBUG_TRACE0(DEBUG_LVL_15, "Abort\n");
                iResult = eUpdateResultAbort;
            }
            else
            {
                if (iRet == 0)
                {
                    DEBUG_TRACE0(DEBUG_LVL_15, "Erased Flash Sector!\n");
                    /* sector was successfully erased, increas erase Offset */
                    updateInfo_g.m_uiEraseOffset += updateInfo_g.m_uiSectorSize;
                }
                iResult = eUpdateResultPending;
            }
        }
    }

    return iResult;
}


/**
********************************************************************************
\brief  start state

updateStateStart() implements the state where firmware programming is started.
*******************************************************************************/
static void updateStateStart(void)
{
    int iRet;
    static int lock = FALSE;

    /* todo jba only for debugging, remove later */
    if (lock == FALSE)
    {
        lock = TRUE;
        printf ("updateStateStart!\n");
    }

    iRet = eraseFlash(updateInfo_g.m_flashFd, CONFIG_USER_IIB_FLASH_ADRS,
                                 updateInfo_g.m_uiSectorSize);

    if (iRet == -EIO)
    {
        DEBUG_TRACE1(DEBUG_LVL_15, "%s Abort\n", __func__);
        abortUpdate();
        lock = FALSE;
    }

    if (iRet == 0)
    {
        DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "%s: IIB erased!\n", __func__);
        updateInfo_g.m_uiProgOffset = updateInfo_g.m_uiUserImageOffset;
        /* FPGA configuration must always start on a sector boundary */
        updateInfo_g.m_uiEraseOffset = updateInfo_g.m_uiProgOffset;
        updateInfo_g.m_uiRemainingSize = fwHeader_g.m_fpgaConfigSize;
        updateInfo_g.m_uiCrc = 0;
        updateInfo_g.m_uiUpdateState = eUpdateStateFpga;
        lock = FALSE;
    }
}

/**
********************************************************************************
\brief  fpga update state

updateStateFpga() implements the state where the FPGA configuration is
programmed.
*******************************************************************************/
static void updateStateFpga(void)
{
    int         iRet;

    iRet = programFirmware();

    if (FLAG_ISSET(iRet, eUpdateResultAbort))
    {
        abortUpdate();
        return;
    }

    if (FLAG_ISSET(iRet, eUpdateResultPartFinish))
    {
        DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "%s: FPGA programming ready!\n", __func__);

        /* FPGA part of image finished, check CRC */
        if (updateInfo_g.m_uiCrc == fwHeader_g.m_fpgaConfigCrc)
        {
            /* CRC is right, we could continue with the PCP software */
            updateInfo_g.m_uiProgOffset = updateInfo_g.m_uiUserImageOffset
                                          + fwHeader_g.m_fpgaConfigSize;
            /* roundup erase offset to next sector start */
            updateInfo_g.m_uiEraseOffset = (updateInfo_g.m_uiProgOffset +
                    updateInfo_g.m_uiSectorSize - 1) &
                    ~(updateInfo_g.m_uiSectorSize - 1);
            updateInfo_g.m_uiRemainingSize = fwHeader_g.m_pcpSwSize;
            updateInfo_g.m_uiCrc = 0;
            updateInfo_g.m_uiUpdateState = eUpdateStatePcp;

            /* notify SDO stack if segment is finished */
            if (FLAG_ISSET(iRet, eUpdateResultSegFinish))
            {
                updateInfo_g.m_pfnSegFinishCb(updateInfo_g.m_pHandle);
            }
        }
        else
        {
            /* abort due to wrong CRC */
            DEBUG_TRACE3(DEBUG_LVL_ERROR, "%s(): Wrong FPGA CRC is %08x, should be %08x\n",
                         __func__, updateInfo_g.m_uiCrc, fwHeader_g.m_fpgaConfigCrc);
            abortUpdate();
        }
    }
    else
    {
        /* notify SDO stack that segment is finished */
        if (FLAG_ISSET(iRet, eUpdateResultSegFinish))
        {
            updateInfo_g.m_pfnSegFinishCb(updateInfo_g.m_pHandle);
        }
    }
}

/**
********************************************************************************
\brief  pcp software update state

updateStatePcp() implements the state where the PCP software is
programmed.
*******************************************************************************/
static void updateStatePcp(void)
{
    int         iRet;

    iRet = programFirmware();

    if (FLAG_ISSET(iRet, eUpdateResultAbort))
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "%s() Abort\n", __func__);
        abortUpdate();
        return;
    }

    /* check if the PCP part is finished */
    if (FLAG_ISSET(iRet, eUpdateResultPartFinish))
    {
        DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "%s: PCP programming ready!\n", __func__);

        /* PCP software part of image finished, check CRC */
        if (updateInfo_g.m_uiCrc == fwHeader_g.m_pcpSwCrc)
        {
            /* CRC is right, we could continue with the AP software */

            /* notify SDO stack if segment is finished */
            if (FLAG_ISSET(iRet, eUpdateResultSegFinish))
            {
                updateInfo_g.m_pfnSegFinishCb(updateInfo_g.m_pHandle);
            }

            /* check if AP software is contained in update */
            if (fwHeader_g.m_apSwSize == 0)
            {
                /* no ap software, continue with setting up IIB */
                updateInfo_g.m_uiUpdateState = eUpdateStateIib;
            }
            else
            {
                updateInfo_g.m_uiProgOffset = updateInfo_g.m_uiUserImageOffset +
                                              fwHeader_g.m_fpgaConfigSize +
                                              fwHeader_g.m_pcpSwSize;
                /* roundup erase offset to next sector start */
                updateInfo_g.m_uiEraseOffset = (updateInfo_g.m_uiProgOffset +
                        updateInfo_g.m_uiSectorSize - 1) &
                        ~(updateInfo_g.m_uiSectorSize - 1);
                updateInfo_g.m_uiRemainingSize = fwHeader_g.m_apSwSize;
                updateInfo_g.m_uiCrc = 0;
                updateInfo_g.m_uiUpdateState = eUpdateStateAp;
            }
        }
        else
        {
            /* abort due to wrong CRC */
            abortUpdate();
        }
    }
    else
    {
        /* notify SDO stack that segment is finished */
        if (FLAG_ISSET(iRet, eUpdateResultSegFinish))
        {
            updateInfo_g.m_pfnSegFinishCb(updateInfo_g.m_pHandle);
        }
    }
}

/**
********************************************************************************
\brief  AP software update state

updateStateAp() implements the state where the AP software is
programmed.
*******************************************************************************/
static void updateStateAp(void)
{
    int         iRet;

    iRet = programFirmware();

    if (FLAG_ISSET(iRet, eUpdateResultAbort))
    {
        abortUpdate();
        return;
    }

    /* check if the AP part is finished */
    if (FLAG_ISSET(iRet, eUpdateResultPartFinish))
    {
        DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "%s: AP programming ready!\n", __func__);

        /* AP software part of image finished, check CRC */
        if (updateInfo_g.m_uiCrc == fwHeader_g.m_apSwCrc)
        {
            /* CRC is right, we could continue with the IIB */
            updateInfo_g.m_uiUpdateState = eUpdateStateIib;

            /* notifiy SDO stack if segment is finished
             * NOTE: should always be the case because it
             * is the last part of the update!
             */
            if (FLAG_ISSET(iRet, eUpdateResultSegFinish))
            {
                updateInfo_g.m_pfnSegFinishCb(updateInfo_g.m_pHandle);
            }
            else
            {
                /* we are finished with the AP part but there is
                 * remaining data! Abort the update! */
                abortUpdate();
            }
        }
        else
        {
            /* abort due to wrong CRC */
            abortUpdate();
        }
    }
    else
    {
        /* notify SDO stack that segment is finished */
        if (FLAG_ISSET(iRet, eUpdateResultSegFinish))
        {
            updateInfo_g.m_pfnSegFinishCb(updateInfo_g.m_pHandle);
        }
    }
}

/**
********************************************************************************
\brief  IIB setup state

updateStateIib() implements the state where the image information block is
programmed.
*******************************************************************************/
static void updateStateIib(void)
{
    tIib        iib;

    /* setup IIB */
    iib.m_magic = IIB_MAGIC_V2;
    iib.m_applicationSwDate = fwHeader_g.m_applicationSwDate;
    iib.m_applicationSwTime = fwHeader_g.m_applicationSwTime;
    iib.m_fpgaConfigCrc = fwHeader_g.m_fpgaConfigCrc;
    iib.m_fpgaConfigSize = fwHeader_g.m_fpgaConfigSize;
    iib.m_pcpSwCrc = fwHeader_g.m_pcpSwCrc;
    iib.m_pcpSwSize = fwHeader_g.m_pcpSwSize;
    iib.m_apSwCrc = fwHeader_g.m_apSwCrc;
    iib.m_apSwSize = fwHeader_g.m_apSwSize;
    memset(iib.m_reserved, 0, sizeof (iib.m_reserved));

    /* calculate CRC of IIB */
    crc32 (0, &iib, sizeof(iib) - sizeof(UINT32));

    /* program IIB into flash */
    alt_write_flash(updateInfo_g.m_flashFd, CONFIG_USER_IIB_FLASH_ADRS, &iib,
                    sizeof(iib));

    /* close the flash device */
    alt_flash_close_dev(updateInfo_g.m_flashFd);

    DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "%s: IIB programming ready!\n", __func__);

    updateInfo_g.m_uiUpdateState = eUpdateStateNone;
}

/******************************************************************************/
/* public functions */

/**
********************************************************************************
\brief	initilize firmware update function

initFirmwareUpdate() initializes all things needed for a firmware update.

\param	deviceId_p              device ID of this device
\param  hwRev_p                 hardware revision of this device

\return OK, always
*******************************************************************************/
int initFirmwareUpdate(UINT32 deviceId_p, UINT32 hwRev_p)
{
    updateInfo_g.m_uiDeviceId = deviceId_p;
    updateInfo_g.m_uiHwRev = hwRev_p;
    updateInfo_g.m_uiUserImageOffset = CONFIG_USER_IMAGE_FLASH_ADRS;
    return OK;
}

/**
********************************************************************************
\brief	update the firmware

updateFirmware() updates the firmware of the device. It will be called by the
SDO object handler for object 0x1F50. If the first segment is received the
firmware header is examined and the firmware programming is set up. The
real programming will be done in updateFirmwarePeriodic() so that this function
can immediately return.

\param uiSegmentOff_p	       offset of the current segment
\param uiSegmentSize_p         size of current segment
\param pData_p                 pointer to segment data
\param pfnAbortCb_p            pointer to abort callback function
\param pfnSegFinishCb_p        pointer to segment-finish callback function
\param pHandle_p               pointer to handle for callback functions

\return		return                  ERROR if something went wrong, OK otherwise
*******************************************************************************/
int updateFirmware(UINT32 uiSegmentOff_p, UINT32 uiSegmentSize_p, char * pData_p,
        void *pfnAbortCb_p, void * pfnSegFinishCb_p, void * pHandle_p)
{
    int                 iRet;
    flash_region*       aFlashRegions;  ///< flash regions array
    unsigned short      wNumOfRegions;  ///< number of flash regions

    DEBUG_TRACE3 (DEBUG_LVL_15, "\n---> %s: segment offset: %d Handle:%p\n", __func__,
                  uiSegmentOff_p, ((tDefObdAccHdl *)pHandle_p)->m_pObdParam);

    /* The first segment of the SDO transfer starts with the firmware header */
    if (uiSegmentOff_p == 0)
    {
        updateInfo_g.m_uiProgOffset = 0;

        /* get firmware header and check if we receive a valid one */
        if (getFwHeader((tFwHeader *)pData_p,
                        updateInfo_g.m_uiDeviceId,
                        updateInfo_g.m_uiHwRev) == ERROR)
        {
            DEBUG_TRACE1(DEBUG_LVL_ERROR, "%s: Invalid firmware header!\n", __func__);
            return ERROR;
        }

        printf ("Got valid header!\n");

        /* open flash device */
        if ((updateInfo_g.m_flashFd =
                alt_flash_open_dev(FLASH_CTRL_NAME)) == NULL)
        {
            DEBUG_TRACE1(DEBUG_LVL_ERROR, "%s: Error opening flash!\n", __func__);
            return ERROR;
        }
        /* get some flash information */
        if ((iRet = alt_get_flash_info(updateInfo_g.m_flashFd,
                                       &aFlashRegions,
                                       (int*) &wNumOfRegions)) != 0)
        {
            DEBUG_TRACE1(DEBUG_LVL_ERROR, "%s: Error get flash info!\n", __func__);
            return ERROR;
        }
        updateInfo_g.m_uiSectorSize = aFlashRegions->block_size;



        updateInfo_g.m_pData = pData_p + sizeof(tFwHeader);
        updateInfo_g.m_uiDataSize = uiSegmentSize_p - sizeof(tFwHeader);
        updateInfo_g.m_uiUpdateState = eUpdateStateStart;
        updateInfo_g.m_uiLastSegmentOffset = uiSegmentOff_p;
    }
    else
    {
        printf ("Segment offset: %d Last segment: %d\n",
                uiSegmentOff_p, updateInfo_g.m_uiLastSegmentOffset);
        if (uiSegmentOff_p < updateInfo_g.m_uiLastSegmentOffset)
        {
            DEBUG_TRACE2(DEBUG_LVL_ERROR,
                         "%s: Error: Invalid segment received. Offset: %d!\n",
                         __func__, uiSegmentOff_p);
            return ERROR;
        }

        /* check if last segment is not yet processed */
        if (updateInfo_g.m_uiDataSize != 0)
        {
            DEBUG_TRACE1(DEBUG_LVL_ERROR,
                         "%s: Error got next segment before previous was ready!\n",
                         __func__);
            return ERROR;
        }
        else
        {
            updateInfo_g.m_pData = pData_p;
            updateInfo_g.m_uiDataSize = uiSegmentSize_p;
        }
    }

    updateInfo_g.m_pfnAbortCb = pfnAbortCb_p;
    updateInfo_g.m_pfnSegFinishCb = pfnSegFinishCb_p;
    updateInfo_g.m_pHandle = pHandle_p;
    updateInfo_g.m_uiLastSegmentOffset = uiSegmentOff_p;

    return OK;
}

/**
********************************************************************************
\brief  periodic worker function for firmware update

updateFirmwarePeriodic() must be periodically be called to execute the firmware
update state machine.
*******************************************************************************/
void updateFirmwarePeriodic(void)
{
    static int lock = FALSE;    /* todo only for debug */

    switch (updateInfo_g.m_uiUpdateState)
    {
    case eUpdateStateStart:
        lock = FALSE;
        updateStateStart();
        break;

    case eUpdateStateFpga:
        updateStateFpga();
        break;

    case eUpdateStatePcp:
        updateStatePcp();
        break;

    case eUpdateStateAp:
        updateStateAp();
        break;

    case eUpdateStateIib:
        updateStateIib();
        break;

    default:
        if (! lock)
        {
            printf ("*** Update State None ***\n");
            lock = TRUE;
        }
        break;
    }
}

/* END-OF-FILE */
