/**
********************************************************************************
\file       update.c

\brief      firmware update functions

\author     Josef Baumgartner

\date       06.09.2011

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This module contains firmware update functions.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApiGlobal.h"
#include "system.h"
#include "firmware.h"
#include <sys/alt_flash.h>
#include <alt_types.h>
#include <errno.h>

/******************************************************************************/
/* defines */

#define USER_IMAGE_OFFSET       0x000D0000
#define USER_IIB_OFFSET         0x001E0000

/* check if a flag in a variable is set */
#define FLAG_ISSET(VAR,FLAG)          ((VAR & FLAG) == FLAG)

/******************************************************************************/
/* type definitions */
typedef enum {
   eUpdateResultAbort = 0x0001,
   eUpdateResultPending = 0x0002,
   eUpdateResultSegFinish = 0x0004,
   eUpdateResultPartFinish = 0x0008,
   eUpdateResultCRCErr = 0x0010,
   eUpdateResultEraseFinish = 0x0020
} tUpdateResult;

typedef enum {
    eUpdateStateNone = 0,
    eUpdateStateStart,
    eUpdateStateFpga,
    eUpdateStatePcp,
    eUpdateStateAp,
    eUpdateStateIib
} tUpdateState;

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
    void *              m_pfnAbortCb;
    void *              m_pfnSegFinishCb;
    UINT32              m_uiUpdateState;
    alt_flash_fd *      m_flashFd;
} tUpdateInfo;

/******************************************************************************/
/* external variables */
extern tFwHeader fwHeader_g;
extern tUpdateInfo updateInfo_g;

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
    /* check header CRC */
    if (crc32(0, pHeader_p, sizeof(tFwHeader) - sizeof(UINT32)) !=
              pHeader_p->m_headerCrc)
    {
        /* wrong CRC */
        return ERROR;
    }

    /* check header version and magic */
    if ((pHeader_p->m_magic != FW_HEADER_MAGIC) ||
        (pHeader_p->m_version != FW_HEADER_VERSION))
    {
        /* invalid firmware format */
        return ERROR;
    }

    /* check device ID and hardware revision */
    if ((pHeader_p->m_deviceId != deviceId_p) ||
        (pHeader_p->m_hwRevision != hwRev_p))
    {
        /* firmware for another device or hardware revision */
        return ERROR;
    }

    /* save header */
    memcpy (&fwHeader_g, pHeader_p, sizeof(tFwHeader));

    return OK;
}

/**
********************************************************************************
\brief  abort update
*******************************************************************************/
static void abortUpdate(void)
{
    /* call abort callback function */
    updateInfo_g.m_pfnAbortCb();

    /* close the flash device */
    alt_flash_close_dev(updateInfo_g.m_flashFd);

    /* reset state */
    updateInfo_g.m_uiUpdateState = eUpdateStateNone;
}

/**
********************************************************************************
\brief  program flash and calculate CRC
*******************************************************************************/
static void programFlashCrc(char * pData_p, UINT32 uiDataSize_p,
                            UINT32 uiProgOffset_p, UINT32 * pCrc_p)
{
    UINT32      crc;

    /* calculate CRC of block */
    crc = crc32(*pCrc_p, pData_p, uiDataSize_p);

    /* write data to flash */
    alt_write_flash(updateInfo_g.m_flashFd, uiProgOffset_p, pData_p,
                    uiDataSize_p);

    *pCrc_p = crc;
}

/**
********************************************************************************
\brief  program firmware data into flash
*******************************************************************************/
static int programFirmware(void)
{
    int         iRet;
    int         iResult;
    int         size;

    /* check if data is available */
    if (updateInfo_g.m_uiDataSize == 0)
    {
        return eUpdateResultPending;
    }

    /* If we are on a sector boundary we have to erase the sector first */
    if (updateInfo_g.m_uiEraseOffset == updateInfo_g.m_uiProgOffset)
    {
        iRet = alt_erase_flash_block(updateInfo_g.m_flashFd,
                                         updateInfo_g.m_uiEraseOffset);

        switch (iRet)
        {
        case -EAGAIN:
            /* erase not finished, return pending */
            return eUpdateResultPending;
            break;

        case 0:
            /* sector was successfully erased, increas erase Offset */
            updateInfo_g.m_uiEraseOffset += updateInfo_g.m_uiSectorSize;
            break;

        case -EIO:
        default:
            /* error occured, return abort */
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
            programFlashCrc(updateInfo_g.m_pData, updateInfo_g.m_uiDataSize,
                            updateInfo_g.m_uiProgOffset, &updateInfo_g.m_uiCrc);
            updateInfo_g.m_uiProgOffset += updateInfo_g.m_uiDataSize;
            updateInfo_g.m_uiRemainingSize -= updateInfo_g.m_uiDataSize;
            updateInfo_g.m_uiDataSize = 0; // all data of segment is programmed

            /* check if next segment will start on a sector boundary so we
             * can start the erase cycle immediately */
            if (updateInfo_g.m_uiEraseOffset == updateInfo_g.m_uiProgOffset)
            {
                iRet = alt_erase_flash_block(updateInfo_g.m_flashFd,
                                                 updateInfo_g.m_uiEraseOffset);
                if (iRet == -EIO)
                {
                    iResult = eUpdateResultAbort;
                }
                else
                {
                    if (iRet == 0)
                    {
                        /* sector was successfully erased, increas erase Offset */
                        updateInfo_g.m_uiEraseOffset += updateInfo_g.m_uiSectorSize;
                    }
                    iResult = eUpdateResultSegFinish;
                }
            }
        }
        else
        {
            /* Data crosses a sector boundary. Only data in this sector
             * can be programmed. Then an erase of the next sector is
             * initiated */
            size = updateInfo_g.m_uiEraseOffset - updateInfo_g.m_uiProgOffset;

            programFlashCrc(updateInfo_g.m_pData, size,
                            updateInfo_g.m_uiProgOffset, &updateInfo_g.m_uiCrc);
            updateInfo_g.m_uiProgOffset += size;
            updateInfo_g.m_uiRemainingSize -= size;
            updateInfo_g.m_uiDataSize -= size;
            updateInfo_g.m_pData += size;

            iRet = alt_erase_flash_block(updateInfo_g.m_flashFd,
                                                 updateInfo_g.m_uiEraseOffset);
            if (iRet == -EIO)
            {
                iResult = eUpdateResultAbort;
            }
            else
            {
                if (iRet == 0)
                {
                    /* sector was successfully erased, increas erase Offset */
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

            programFlashCrc(updateInfo_g.m_pData, size,
                            updateInfo_g.m_uiProgOffset,&updateInfo_g.m_uiCrc);
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
                /* Segment finished and image part finished */
                iResult = eUpdateResultPartFinish | eUpdateResultSegFinish;
            }
            else
            {
                /* Image part finished, but segment contains data of next
                 * part. */
                iResult = eUpdateResultPartFinish;
            }
        }
        else
        {
            /* Data crosses a sector boundary. Only data in this sector
             * can be programmed. Then an erase of the next sector is
             * initiated */
            size = updateInfo_g.m_uiEraseOffset - updateInfo_g.m_uiProgOffset;

            programFlashCrc(updateInfo_g.m_pData, size,
                            updateInfo_g.m_uiProgOffset, &updateInfo_g.m_uiCrc);
            updateInfo_g.m_uiProgOffset += size;
            updateInfo_g.m_uiRemainingSize -= size;
            updateInfo_g.m_uiDataSize -= size;
            updateInfo_g.m_pData += size;

            iRet = alt_erase_flash_block(updateInfo_g.m_flashFd,
                                                 updateInfo_g.m_uiEraseOffset);
            if (iRet == -EIO)
            {
                iResult = eUpdateResultAbort;
            }
            else
            {
                if (iRet == 0)
                {
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
*******************************************************************************/
static void updateStateStart(void)
{
    int iRet;

    iRet = alt_erase_flash_block(updateInfo_g.m_flashFd, USER_IIB_OFFSET);

    if (iRet == -EIO)
    {
        abortUpdate();
    }

    if (iRet == 0)
    {
        updateInfo_g.m_uiProgOffset = updateInfo_g.m_uiUserImageOffset;
        /* FPGA configuration must always start on a sector boundary */
        updateInfo_g.m_uiEraseOffset = updateInfo_g.m_uiProgOffset;
        updateInfo_g.m_uiRemainingSize = fwHeader_g.m_fpgaConfigSize;
        updateInfo_g.m_uiCrc = 0;
        updateInfo_g.m_uiUpdateState = eUpdateStateFpga;
    }
}

/**
********************************************************************************
\brief  fpga update state
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
        /* FPGA part of image finished, check CRC */
        if (updateInfo_g.m_uiCrc == fwHeader_g.m_fpgaConfigCrc)
        {
            /* CRC is right, we could continue with the PCP software */
            updateInfo_g.m_uiProgOffset = updateInfo_g.m_uiUserImageOffset
                                          + fwHeader_g.m_fpgaConfigSize;
            /* roundup erase offset to next sector start */
            updateInfo_g.m_uiEraseOffset = (updateInfo_g.m_uiProgOffset +
                    updateInfo_g.m_uiSectorSize - 1) &
                    (updateInfo_g.m_uiSectorSize - 1);
            updateInfo_g.m_uiRemainingSize = fwHeader_g.m_pcpSwSize;
            updateInfo_g.m_uiCrc = 0;
            updateInfo_g.m_uiUpdateState = eUpdateStatePcp;

            /* notify SDO stack if segment is finished */
            if (FLAG_ISSET(iRet, eUpdateResultSegFinish))
            {
                updateInfo_g.m_pfnSegFinishCb();
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
            updateInfo_g.m_pfnSegFinishCb();
        }
    }
}

/**
********************************************************************************
\brief  pcp software update state
*******************************************************************************/
static void updateStatePcp(void)
{
    int         iRet;

    iRet = programFirmware();

    if (FLAG_ISSET(iRet, eUpdateResultAbort))
    {
        abortUpdate();
        return;
    }

    /* check if the PCP part is finished */
    if (FLAG_ISSET(iRet, eUpdateResultPartFinish))
    {
        /* PCP software part of image finished, check CRC */
        if (updateInfo_g.m_uiCrc == fwHeader_g.m_pcpSwCrc)
        {
            /* CRC is right, we could continue with the AP software */

            /* notify SDO stack if segment is finished */
            if (FLAG_ISSET(iRet, eUpdateResultSegFinish))
            {
                updateInfo_g.m_pfnSegFinishCb();
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
                        (updateInfo_g.m_uiSectorSize - 1);
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
            updateInfo_g.m_pfnSegFinishCb();
        }
    }
}

/**
********************************************************************************
\brief  AP software update state
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
                updateInfo_g.m_pfnSegFinishCb();
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
            updateInfo_g.m_pfnSegFinishCb();
        }
    }
}

/**
********************************************************************************
\brief  IIB setup state
*******************************************************************************/
static void updateStateIib(void)
{
    int         iRet;
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
    alt_write_flash(updateInfo_g.m_flashFd, USER_IIB_OFFSET, &iib, sizeof(iib));

    /* close the flash device */
    alt_flash_close_dev(updateInfo_g.m_flashFd);
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
    updateInfo_g.m_uiUserImageOffset = USER_IMAGE_OFFSET;
}

/**
********************************************************************************
\brief	update the firmware

updateFirmware() updates the firmware of the device. It will be called by the
SDO object handler for object 0x1F50. If

\param		pSegmentOff_p			pointer to offset of the current segment
\param      pSegmentSize_p          pointer to size of current segment
\param      pData_p                 pointer to segment data
\param      pfnAbortCb_p            pointer to abort callback function
\param      pfnSegFinishCb_p        pointer to segment-finish callback function

\return		return                  ERROR if something went wrong, OK otherwise
*******************************************************************************/
int updateFirmware(UINT32 * pSegmentOff_p, UINT32 * pSegmentSize_p, char * pData_p,
        void *pfnAbortCb_p, void * pfnSegFinishCb_p)
{
    int                 iRet;
    flash_region*       aFlashRegions;  ///< flash regions array
    unsigned short      wNumOfRegions;  ///< number of flash regions

    /* The first segment of the SDO transfer starts with the firmware header */
    if (*pSegmentOff_p == 0)
    {
        updateInfo_g.m_uiProgOffset = 0;

        /* get firmware header and check if we receive a valid one */
        if (getFwHeader(pData_p,
                        updateInfo_g.m_uiDeviceId,
                        updateInfo_g.m_uiHwRev) == ERROR)
        {
            return ERROR;
        }

        /* open flash device */
        if ((updateInfo_g.m_flashFd =
                alt_flash_open_dev(EPCS_FLASH_CONTROLLER_0_NAME)) == NULL)
        {
            return ERROR;
        }
        /* get some flash information */
        if ((iRet = alt_get_flash_info(updateInfo_g.m_flashFd,
                                       &aFlashRegions,
                                       (int*) &wNumOfRegions)) != 0)
        {
            return ERROR;
        }
        updateInfo_g.m_uiSectorSize = aFlashRegions->block_size;

        updateInfo_g.m_pData = pData_p + sizeof(tFwHeader);
        updateInfo_g.m_uiDataSize = *pSegmentSize_p - sizeof(tFwHeader);
        updateInfo_g.m_uiUpdateState = UPDATE_STATE_START;
    }
    else
    {
        /* check if last segment is not yet processed */
        if (updateInfo_g.m_uiDataSize != 0)
        {
            return ERROR;
        }
        else
        {
            updateInfo_g.m_pData = pData_p;
            updateInfo_g.m_uiDataSize = *pSegmentSize_p;
        }
    }

    updateInfo_g.m_pfnAbortCb = pfnAbortCb_p;
    updateInfo_g.m_pfnSegFinishCb = pfnSegFinishCb_p;

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
    switch (updateInfo_g.m_uiUpdateState)
    {
    case eUpdateStateStart:
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
    }
}

