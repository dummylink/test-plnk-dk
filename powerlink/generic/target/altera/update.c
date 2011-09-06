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
#include "firmware.h"

/******************************************************************************/
/* type definitions */
typedef struct {
    UINT32              m_deviceId;
    UINT32              m_hwRev;
    UINT32              m_offset;
} tUpdateInfo;

/******************************************************************************/
/* external variables */
extern tFwHeader fwHeader_g;
extern tUpdateInfo updateInfo_g;

/**
********************************************************************************
\brief	get firmware header

getFwHeader() reads the firmware header checks if it is valid and copies it
to the global variable fwHeader_g for further reference.

\param  pHeader_p               Pointer to the data block containing
                                the firmware header
\param  deviceId_p              The device Id to check for
\param  hwRev_p                 The hardware revision to check for

\return		ERROR if no valid firmware header is found, OK otherwise
*******************************************************************************/
getFwHeader(tFwHeader *pHeader_p, UINT32 deviceId_p, UINT32 hwRev_p)
{
    /* check header CRC */
    if (crc32(0, pData_p, sizeof(tFwHeader) - sizeof(UINT32)) != pHeader_p->m_headerCrc)
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
    if ((pHeader_p->m_deviceId != deviceId_p) || (pHeader_p->m_hwRevision != hwRev_p))
    {
        /* firmware for another device or hardware revision */
        return ERROR;
    }

    /* save header */
    memcpy (&fwHeader_g, pData_p, sizeof(tFwHeader));

    return OK;
}

/**
********************************************************************************
\brief  program firmware data into flash
*******************************************************************************/
programFirmware()
{

}

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
    updateInfo_g.m_deviceId = deviceId_p;
    updateInfo_g.m_hwRev = hwRev_p;
    updateInfo_g.m_userImageOffset = uiUserImageOffset_p;
}

/**
********************************************************************************
\brief	update the firmware

updateFirmware() updates the firmware of the device. It will be called by the
SDO object handler for object 0x1F50.

\param		parameter			parameter_description

\return		return
\retval		return_value			return_value_description
*******************************************************************************/
int updateFirmware(UINT32 * pSegmentOff_p, UINT32 * pSegmentSize_p, char * pData_p)
{
    /* The first segment of the SDO transfer starts with the firmware header */
    if (*pSegmentOff_p == 0)
    {
        updateInfo_g.m_progOffset = 0;

        /* get firmware header and check if we receive a valid one */
        if (getFwHeader(pData_p,
                        updateInfo_g.m_deviceId,
                        updateInfo_g.m_hwRev) == ERROR)
        {
            return ERROR;
        }

        remainingSize = fwHeader_g.m_fpgaConfigSize + fwHeader_g.m_pcpSwSize;
        offset += sizeof(fwHeader);

        size = *pSegmentSize_p - sizeof(fwHeader);
    }
    else
    {
        size = *pSegmentSize_p;
    }

    if (updateI)

    if (programming)
    {

    progSize = (size <= remainingSize) ? size : remainingSize;
    if (programFirmware(pData_p, progSize, offset) < 0)
    {
        return ERROR;
    }


    /* TODO: detect last segment to do cleanups! */

}
