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
#include "EplInc.h"
#include "system.h"
#include "FpgaCfg.h"
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
\brief  read image information block from flash

checkIib() checks if a valid image information block is located at pIib.
*******************************************************************************/
int getIib(tIib *pIib_p, UINT32 uiIibAdrs)
{
    alt_flash_fd *  pFlashInst = NULL;
    int iRet = TRUE;

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

checkFlashCrc() checks the CRC of a data block in flash
*******************************************************************************/
int checkFlashCrc(UINT32 uiFlashAdrs_p, UINT32 uiSize_p, UINT32 uiCrc_p)
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
\brief  check image information block

checkIib() checks if a valid image information block is located at pIib.
*******************************************************************************/
int checkfwImage(UINT32 uiImgAdrs_p, UINT32 uiIibAdrs_p, UINT16 uiIibVersion_p)
{
    UINT32              uiCrc;
    tIib                iib;

    /* read IIB from flash */
    if (getIib(&iib, uiIibAdrs_p) < 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Invalid IIB\n");
        return ERROR;
    }

    /* check IIB magic */
    if (AmiGetDwordFromBe(&iib.m_magic) != (IIB_MAGIC | uiIibVersion_p))
    {
        /* todo jba: create individual error codes! */
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


