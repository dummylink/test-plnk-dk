/*******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       FpgaCfg.c

\brief      Module for Altera FPGA configuration tasks using the
            Cyclone III Remote Update Controller (SOPC) core

\author     hoggerm

\date       17.05.2011

\since      17.05.2011

*******************************************************************************/
/* includes */
#include "FpgaCfg.h"
#include "EplInc.h"
#include "cnApiGlobal.h"
#include "fwUpdate.h"
#include "altera_avalon_pio_regs.h"
#include <string.h>                      //for memcpy()

#ifdef SYSID_BASE
#include "altera_avalon_sysid.h"
#include "altera_avalon_sysid_regs.h"
#else
#warning: No SOPC module "SYSTEM-ID" present! Checking if SW fits to HW can not be performed!
#endif /* SYSID_BASE */

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */
static void FpgaCfg_disableWatchdog(void);
static void FpgaCfg_enableWatchdog(void);
static void FpgaCfg_enableEarlyCnfDoneCheck(void);
static void FpgaCfg_enableInternalOscStartUp(void);
static void FpgaCfg_setWatchdogTimer(WORD wTimeout_p);
static DWORD FpgaCfg_getWatchdogCounterSetting(void);
static DWORD FpgaCfg_getWatchdogStatus(void);
static DWORD FpgaCfg_getCurRemoteUpdateCoreState(void);
static DWORD FpgaCfg_getCurFactoryBootAdr(void);
static DWORD FpgaCfg_getPast1BootAdr(void);
static DWORD FpgaCfg_getPast2BootAdr(void);
static DWORD FpgaCfg_getPast1ReconfigTriggerCondition(void);

static BOOL FpgaCfg_checkBlockStaysInRange(
             const DWORD dwRangeStartOffs_p,
             const DWORD dwRangeEndOffs_p,
             const DWORD * pdwBlkStartOffs_p,
             const DWORD * pdwBlkSize_p);
//static BOOL FpgaCfg_getFlashSize(DWORD * pdwFlashSize_p);
static BOOL FpgaCfg_writeFlashBlockSafely(
             alt_flash_fd * pFlashInst_p,
             int iBlkDestOffset_p,
             int iBlkSize_p,
             int iDestOffset_p,
             const void * pSrc_p,
             int iWriteSize_p);
static BOOL FpgaCfg_getFlashBlockStartOffset(
             DWORD * pdwFlashOffsetDest_p,
             alt_flash_fd * pFlashInst_p,
             DWORD *        pdwBlockStartOffset_p);

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */

/******************************************************************************/
/* REMOTE UPDATE CORE FUNCTIONS                                               */
/******************************************************************************/

/**
********************************************************************************
\brief triggers reconfiguration of FPGA firmware

\param dwResetAdr_p        flash memory start address of image to be loaded

Any attempt to reconfigure from an already reconfigured application image causes
the FPGA to return to the factory image. The user image reconfiguration works
only, if the bootloader is able to read the current flash offset from remote
update core.
*******************************************************************************/
void FpgaCfg_reloadFromFlash(DWORD dwResetAdr_p)
{
    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x04, dwResetAdr_p >> 2); //set base address of image to be loaded
    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x20, 1); //trigger reconfiguration
}

/**
********************************************************************************
\brief prevents watchdog from triggering reconfiguration

This function is only reasonably executed in factory mode.
It is not possible to disable the watchdog in user mode. Only the watchdog timer
can be reset to prevent a timeout.
*******************************************************************************/
void FpgaCfg_disableWatchdog(void)
{
    //printf("Input Reg. before watchdog disable: %d\n", IORD(REMOTE_UPDATE_CORE_BASE, 0x18 | 0x03));
    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x03, 0); //disable watchdog timer
    //printf("Input Reg. after watchdog disable: %d\n", IORD(REMOTE_UPDATE_CORE_BASE, 0x18 | 0x03));
}

/**
********************************************************************************
\brief enables automatic reconfiguration in case of timeout for application image

The user watchdog timer is disabled in factory configurations and during the
configuration cycle of the application configuration. The enabling is activated
after the application configuration enters 'device user mode'. The timer counts
downwards. If it is not reset, a configuration reset will be triggered and the
factory image will be loaded. The watchdog is enabled per default in factory mode.
It is not possible to enable the watchdog in user mode.
*******************************************************************************/
void FpgaCfg_enableWatchdog(void)
{
    //printf("Input Reg. before watchdog enable: %d\n", IORD(REMOTE_UPDATE_CORE_BASE, 0x18 | 0x03));
    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x03, 1); //enable watchdog timer
    //printf("Input Reg. after watchdog enable: %d\n", IORD(REMOTE_UPDATE_CORE_BASE, 0x18 | 0x03));
}

/**
********************************************************************************
\brief enables the "early CONF_DONE" checking

This function is only reasonably executed in factory mode.
It enables the following functionality:
If an invalid configuration is detected or the CONF_DONE pin is asserted
too early, the device resets and then reconfigures the factory configuration
image.
*******************************************************************************/
void FpgaCfg_enableEarlyCnfDoneCheck(void)
{
    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x01, 1); // set 1 bit to high
}

/**
********************************************************************************
\brief enables the internal oscillator to be used for startup

This function is only reasonably executed in factory mode.
It ensures a functional startup clock to eliminate the hanging of
user image startup.
*******************************************************************************/
void FpgaCfg_enableInternalOscStartUp(void)
{
    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x06, 1); // set 1 bit to high
}

/**
********************************************************************************
\brief sets the watchdog timeout counter value

\param wTimeout_p    12-bit watchdog timeout counter value (0 disables watchdog)
 \val < 0x0001h                      watchdog will be disabled
 \val 0x0001h < wTimeout_p < 0xFFFh  timeout will be set
 \val > 0xFFFh                       max. val of 0xFFFh will be set

This function sets the watchdog timeout counter value. Only the upper 12 bits of
the 29-bit timer counter value matter if it is written. If iTimeout_p is set to 0,
the watchdog will be disabled. The actual timeout value depends on the frequency
of the internal remote update core clock source, which has a range between 5 and
10 Mhz (typical 6.5 Mhz).
*******************************************************************************/
void FpgaCfg_setWatchdogTimer(WORD wTimeout_p)
{

    // only enable the watchdog timer if its timeout value is greater than 0.
    if( wTimeout_p >= 1)
    {
        // set timeout value
        IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x02, wTimeout_p );
    }
    else
    {
        // disable the watchdog timer
        FpgaCfg_disableWatchdog();
    }

    // max value can be 0xFFFh
    //DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "Input reg. watchdog timeout: %#x\n", IORD(REMOTE_UPDATE_CORE_BASE, 0x18 | 0x02));

    // max value can be 0x1FFE0000h ==> apprx 53 seconds (with 10 Mhz)
    DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "Actual watchdog timeout set: %#x\n", 0x20000 * IORD(REMOTE_UPDATE_CORE_BASE, 0x18 | 0x02));
}

/**
********************************************************************************
\brief delays the reconfiguration triggering if watchdog is enabled by resetting
       the counter to its original value
*******************************************************************************/
void FpgaCfg_resetWatchdogTimer(void)
{
    register DWORD dwRegister;

    dwRegister = IORD(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x20);

    dwRegister |= (1 << RESET_TIMER);  //set RESET_TIMER bit to 1
    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x20, dwRegister); // reset timer
    dwRegister &= ~(1 << RESET_TIMER); // set RESET_TIMER bit to 0
    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x20, dwRegister); // continue counting

    //DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Watchdog timeout reset triggered!\n");
}

/**
********************************************************************************
\brief returns the current watchdog timeout counter value
\return counter value, 29 bit (valid range: 0x2000h - 0x1FFE0008h)

This function is only reasonably executed in user application mode.
It returns the counter value set by the factory image - but not the current
count.
*******************************************************************************/
DWORD FpgaCfg_getWatchdogCounterSetting(void)
{
    DWORD dwRegister;

    /* read 29 bit value */
    dwRegister = IORD(REMOTE_UPDATE_CORE_BASE,  0x08 | 0x02);
    return dwRegister;
}

/**
********************************************************************************
\brief returns the current watchdog status
\return 1 if enabled, else 0

This function is only reasonably executed in user application mode.
*******************************************************************************/
DWORD FpgaCfg_getWatchdogStatus(void)
{
    DWORD dwRegister;

    /* read 29 bit value */
    dwRegister = IORD(REMOTE_UPDATE_CORE_BASE,  0x08 | 0x03);
    return dwRegister;
}

/**
********************************************************************************
\brief returns the current state/mode of the remote update core
\return mode of the remote update core, 2 bit value
 \val = 0x00h:  factory mode
 \val = 0x01h:  application mode
 \val = 0x03h:  application mode with watchdog timer enabled
*******************************************************************************/
DWORD FpgaCfg_getCurRemoteUpdateCoreState(void)
{
    DWORD dwRegister;

    /* read 2 bit value from config/cntrl register */
    dwRegister = IORD(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x00);
    return dwRegister;
}

/**
********************************************************************************
\brief returns the current offset address of where the factory boot image is
       loaded from
\return (flash) offset address, 24 bit value
*******************************************************************************/
DWORD FpgaCfg_getCurFactoryBootAdr(void)
{
    DWORD dwRegister;

    /* read 24 bit value */
    dwRegister = IORD(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x04);
    return dwRegister;
}

/**
********************************************************************************
\brief returns the offset boot address of last state
\return (flash) offset address, 24 bit value

This function is only reasonably executed in factory mode.
It can be used to determine the boot address of a failed user image
configuration.
*******************************************************************************/
DWORD FpgaCfg_getPast1BootAdr(void)
{
    DWORD dwRegister;

    /* read 24 bit value */
    dwRegister = IORD(REMOTE_UPDATE_CORE_BASE, 0x08 | 0x04);
    return dwRegister;
}

/**
********************************************************************************
\brief returns the offset boot address of 2 states ago
\return (flash) offset address, 24 bit value

This function is only reasonably executed in factory mode.
It can be used to determine the boot address of a failed user image
configuration.
*******************************************************************************/
DWORD FpgaCfg_getPast2BootAdr(void)
{
    DWORD dwRegister;

    /* read 24 bit value */
    dwRegister = IORD(REMOTE_UPDATE_CORE_BASE, 0x10 | 0x04);
    return dwRegister;
}

/**
********************************************************************************
\brief returns reconfiguration source register value
\return reconfiguration source register, 5 bit value
 \val = 0x00h: configuration triggered by power-up
 \val = 0x01h: configuration triggered from logic array (of remote update core)
 \val = 0x02h: configuration triggered from watchdog timeout
 \val = 0x04h: nSTATUS asserted by external device
 \val = 0x08h: CRC error during application configuration
 \val = 0x10h: nCONFIG asserted - external configuration reset

This function reads the condition of last mode which triggered reconfiguration.
It is only reasonably executed in factory mode and can be used to determine the
cause of a failed user image configuration.
*******************************************************************************/
DWORD FpgaCfg_getPast1ReconfigTriggerCondition(void)
{
    DWORD dwRegister;

    /* read 5 bit value from previous state register 1 */
    dwRegister = IORD(REMOTE_UPDATE_CORE_BASE, 0x08 | 0x07);
    return dwRegister;
}

/**
********************************************************************************
\brief handles the FPGA reconfiguration of the factory and application image

\return tFpgaCfgRetVal

This function handles the necessary steps right after Fpga reconfiguration.
Thus is should be invoked at the beginning of SW execution.
If the factory image is loaded from nonvolatile memory, a reconfiguration will
be triggered which loads the user image. If there is no valid user image present,
the configuration will fall back to factory image once more. In this case the
user image will not be loaded - this has to be triggered manually then with the
function FpgaCfg_reloadFromFlash(), after another user image has been written.
*******************************************************************************/
tFpgaCfgRetVal FpgaCfg_handleReconfig(void)
{
    tFpgaCfgRetVal Ret = kFpgaCfgInvalidRetVal;
    BOOL fApplicationImageFailed = FALSE;
    DWORD dwTriggerCondition;

#ifdef SYSID_BASE
    DEBUG_TRACE2(DEBUG_LVL_ALWAYS, "Reconfigured with system time stamp: %ul \nand system ID: %ul\n",
                 IORD_ALTERA_AVALON_SYSID_TIMESTAMP(SYSID_BASE),
                 IORD_ALTERA_AVALON_SYSID_ID(SYSID_BASE));

    /* verify if BSP matches SOPC system ID */
    if (alt_avalon_sysid_test() != 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Bad image! FPGA configuration does not match SW!");
        Ret = kFgpaCfgWrongSystemID;
        goto exit;
    }
#endif /* SYSID_BASE */

    //DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "\nConfiguration State: %lu\n", FpgaCfg_getCurRemoteUpdateCoreState());

    switch (FpgaCfg_getCurRemoteUpdateCoreState())
    {
        case 0x00:
        {/* factory mode */

            dwTriggerCondition = FpgaCfg_getPast1ReconfigTriggerCondition();

            DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "Factory image triggered by: %#lx", dwTriggerCondition);
            if (dwTriggerCondition == 0x00)
            {
                DEBUG_TRACE0(DEBUG_LVL_ERROR, " (power up)\n");
            }
            if (dwTriggerCondition & 0x01)
            {
                DEBUG_TRACE0(DEBUG_LVL_ERROR, " (remote update core)\n");
            }
            if (dwTriggerCondition & 0x02)
            {
                DEBUG_TRACE0(DEBUG_LVL_ERROR, " (watchdog timeout)\n");
                fApplicationImageFailed = TRUE;
            }
            if (dwTriggerCondition & 0x04)
            {
                DEBUG_TRACE0(DEBUG_LVL_ERROR, " (nSTATUS assertion)\n");
                // no valid application image presen at FLASH_FPGA_USER_IMAGE_ADR
                fApplicationImageFailed = TRUE;
            }
            if (dwTriggerCondition & 0x08)
            {
                DEBUG_TRACE0(DEBUG_LVL_ERROR, " (config CRC error)\n");
                fApplicationImageFailed = TRUE;
            }
            if (dwTriggerCondition & 0x010)
            {
                DEBUG_TRACE0(DEBUG_LVL_ERROR, " (external nCONFIG reset)\n");
            }

            DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "and loaded from address: %#lx\n", FpgaCfg_getCurFactoryBootAdr());

            if (fApplicationImageFailed)
            { /* do not trigger application configuration again */
                DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "Bad application image at address: %#lx\n", FpgaCfg_getPast1BootAdr());
                Ret = kFgpaCfgFactoryImageLoadedNoUserImagePresent;
                goto exit;
            }
            else
            { /* trigger user image reconfiguration */

                // JBA insert code here!
                DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Checking user image ...\n");
                if (checkfwImage(USER_IMAGE_FLASH_ADRS, USER_IIB_FLASH_ADRS, USER_IIB_VERSION) == ERROR)
                {
                    Ret = kFgpaCfgFactoryImageLoadedNoUserImagePresent;
                    DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "... INVALID!\n");
                    break;
                }
                DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "... OK!\n");


                /* Watchdog is enabled per default in factory mode, so enabling is not necessary. */
#ifdef DEFAULT_DISABLE_WATCHDOG
                FpgaCfg_disableWatchdog();
#else
                FpgaCfg_setWatchdogTimer(0xfff); // max value is 0xfff -> apprx. 53 seconds
#endif /* DEFAULT_DISABLE_WATCHDOG */

                /* set special bits - recommended by Altera */
                FpgaCfg_enableEarlyCnfDoneCheck();
                FpgaCfg_enableInternalOscStartUp();

#ifndef NO_FACTORY_IMG_IN_FLASH
                //usleep(1000*10000); //activate this line for debugging
                /* trigger reconfiguration of application image */
                FpgaCfg_reloadFromFlash(USER_IMAGE_FLASH_ADRS);
#endif /* not NO_FACTORY_IMG_IN_FLASH */
            }
            break;
        }

        case 0x01:
        { /* application mode - watchdog disabled */
            Ret = kFpgaCfgUserImageLoadedWatchdogDisabled;
            break;
        }
        case 0x03:
        { /* application mode - watchdog enabled -> application needs to reset timer periodically */
            DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "Watchdog timeout set to: %#lx\n", FpgaCfg_getWatchdogCounterSetting());
            Ret = kFpgaCfgUserImageLoadedWatchdogEnabled;
            break;
        }
        default:
        break;
    }

exit:
    return Ret;
}

/******************************************************************************/
/* FPGA FLASH PROGRAMMING FUNCTIONS                                           */
/******************************************************************************/

/**
 ********************************************************************************
 \brief reads data from flash memory
 \param pdwSrcFlashOffset_p  pointer to flash source destination offset
 \param pdwSize_p            pointer to size of source data
 \param pDest_p              pointer to destination
 \return TRUE if successful, FALSE if not
 *******************************************************************************/
BOOL FpgaCfg_readFlash(const DWORD * pdwSrcFlashOffset_p,
                       DWORD * pdwSize_p,
                       void * pDest_p)
{
    alt_flash_fd *  pFlashInst = NULL;  ///< pointer to structure for flash device handling
    flash_region* aFlashRegions;        ///< flash regions array
    WORD wNumOfRegions;                 ///< number of flash regions
    BYTE bRegElmt = 0;                  ///< element of flash regions array
    DWORD dwBlockSize = 0;              ///< block size (fixed for each region)
    DWORD dwFlashSize = 0;              ///< size of whole flash memory
    BOOL fRet = TRUE;                   ///< return value
    int iRet;                           ///< captures bsp flash function return values

    /* get pointer to flash instance structure */
    pFlashInst = alt_flash_open_dev(FLASH_CTRL_NAME);
    if (pFlashInst == NULL)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: Could not open Flash device!\n");
        fRet = FALSE;
        goto exit;
    }

    /* get some flash information */
    iRet = alt_get_flash_info(pFlashInst, &aFlashRegions, (int*) &wNumOfRegions);
    if (iRet != 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: alt_get_flash_info() failed! \n");
        fRet = FALSE;
        goto exit;
    }

    if (wNumOfRegions == 1 )
    { /* it is an EPCS device (with only one region)*/

        /* assign the first (and only) regions block size */
        bRegElmt = 0;
        dwBlockSize = aFlashRegions[bRegElmt].block_size;
        dwFlashSize = aFlashRegions[bRegElmt].region_size;

        //printf( "\nReading from flash %s.\n"
        //      "Flash size is %ld (%#08lx)\n", FLASH_CTRL_NAME, dwFlashSize, dwFlashSize);
    }
    else
    { /* other devices currently not handled */
        //for dwFlashSize, regions have to be summed up in case of other device
        {
            DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: %s failed!\n", __func__);
            fRet = FALSE;
            goto exit;
        }
    }

    /* check for useless values */
    if (dwBlockSize == 0                              ||
        aFlashRegions[bRegElmt].number_of_blocks == 0 ||
        dwFlashSize == 0                              ||
        pdwSize_p == NULL                             ||
        *pdwSize_p == 0                               ||
        pDest_p == NULL                               ||
        (dwFlashSize - 1) < *pdwSrcFlashOffset_p + *pdwSize_p) //flash size exceeded
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: %s failed!", __func__);
        fRet = FALSE;
        goto exit;
    }

    iRet = alt_read_flash(pFlashInst,
                          (int) *pdwSrcFlashOffset_p,
                          pDest_p,
                          (int) *pdwSize_p);
    if (iRet != 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: alt_read_flash() failed! \n");
        fRet = FALSE;
        goto exit;
    }

    DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "INFO: Read %lu bytes from flash\n", *pdwSize_p);

    alt_flash_close_dev(pFlashInst);

exit:
    return fRet;
}

/**
 ********************************************************************************
 \brief write to a certain flash region
 \param RegionName_p            name of the destination region
 \param pdwDestFlashOffset_p    pointer to flash write destination offset
 \param pSrc_p                  pointer to source data
 \param pdwSize_p               pointer to size of source data
 \return TRUE if successful, FALSE if not

 This function ensures that the borders for desired write section won't be
 exceeded in order to protect other regions from being overwritten.
 *******************************************************************************/
BOOL FpgaCfg_writeFlashUserImageRegion(tFpgaCfgFlashRegionName RegionName_p,
                                       DWORD * pdwDestFlashOffset_p,
                                       const BYTE * pSrc_p,
                                       DWORD * pdwSize_p)
{
    BOOL fRet = TRUE;                   ///< return value
    DWORD   dwFlashSizeOffs = 0;        ///< flash memory size

    /*
     * the desired write block has to stay in the desired
     * region, otherwise it would result in an error.
     */

    /* protect other sections from being overwritten */
    switch (RegionName_p)
    {
        case kFpgaCfgFlashRegionFactoryImage:
        {
             fRet = FALSE; // writing to this section is not allowed!
             break;
        }
        case kFpgaCfgFlashRegionUserImage:
        {
            fRet = FpgaCfg_checkBlockStaysInRange(
                        FLASH_SECTION_OFFSET_USER_IMAGE,
                        FLASH_SECTION_OFFSET_CONFIG_STORAGE,
                        pdwDestFlashOffset_p,
                        pdwSize_p);
            if (fRet == FALSE)
            {
                goto exit;
            }
            break;
        }
        case kFpgaCfgFlashRegionConfigurationStorage:
        {
            fRet = FpgaCfg_checkBlockStaysInRange(
                        FLASH_SECTION_OFFSET_CONFIG_STORAGE,
                        FLASH_SECTION_OFFSET_NON_PCP_SPARE,
                        pdwDestFlashOffset_p,
                        pdwSize_p);
            if (fRet == FALSE)
            {
                goto exit;
            }
            break;
        }
        case kFpgaCfgFlashRegionNonPcpSpare:
        {
            fRet = FpgaCfg_getFlashSize(&dwFlashSizeOffs);
            if (fRet == FALSE)
            {
                goto exit;
            }

            fRet = FpgaCfg_checkBlockStaysInRange(
                        FLASH_SECTION_OFFSET_NON_PCP_SPARE,
                        dwFlashSizeOffs,
                        pdwDestFlashOffset_p,
                        pdwSize_p);
            if (fRet == FALSE)
            {
                goto exit;
            }
            break;
        }

        default:
        {
            /* function was called with invalid parameter */
            fRet = FALSE;
            goto exit;
        }
    }

exit:
    return fRet;
}

/**
 ********************************************************************************
 \brief checks if a memory block exceeds a specified memory range
 \param dwRangeStartOffs_p   start of allowed range (offset)
 \param dwRangeEndOffs_p     end of allowed range (offset)
 \param pdwBlkStartOffs_p    pointer to start of block (offset)
 \param pdwBlkSize_p         pointer to size of block
 \return TRUE if block is in range, FALSE if not or in case of an error

This function verifies if a memory block (with start offset dwBlkStartOffs_p and
size dwBlkSize_p) stays within an allowed range (*pdwRangeStartOffs_p to
*pdwRangeEndOffs_p).
 *******************************************************************************/
BOOL FpgaCfg_checkBlockStaysInRange(
             const DWORD dwRangeStartOffs_p,
             const DWORD dwRangeEndOffs_p,
             const DWORD * pdwBlkStartOffs_p,
             const DWORD * pdwBlkSize_p)
{
    BOOL fRet = TRUE;  ///< return value

    /* check for useless values */
    if (pdwBlkStartOffs_p == NULL              ||
        pdwBlkSize_p == NULL                   ||
        dwRangeStartOffs_p > dwRangeEndOffs_p) // start is higher than end -> error
    {

        fRet = FALSE;
        goto exit;
    }

    if (*pdwBlkStartOffs_p < dwRangeStartOffs_p            ||
        (*pdwBlkStartOffs_p + *pdwBlkSize_p) > dwRangeEndOffs_p)
    { /* block exceed the specified range */
        fRet = FALSE;
        goto exit;
    }

    /* block stays within specified range if this line is reached */

exit:
    return fRet;
}

/**
 ********************************************************************************
 \brief read the flash size
 \param pdwFlashSize_p OUT: pointer to size of flash
 \return TRUE if successful, FALSE if flash size is invalid

This function will write the size of the flash memory (flash name defined in
"FLASH_CTRL_NAME") to the parameter pdwFlashSize_p.
If the flash memory instance can not be found or has invalid values an error will
be returned.
 *******************************************************************************/
BOOL FpgaCfg_getFlashSize(DWORD * pdwFlashSize_p)
{
    alt_flash_fd *  pFlashInst = NULL;  ///< pointer to structure for flash device handling
    flash_region* aFlashRegions;        ///< flash regions array
    WORD wNumOfRegions;                 ///< number of flash regions
    BYTE bRegElmt = 0;                  ///< element of flash regions array
    DWORD dwBlockSize = 0;              ///< block size (fixed for each region)
    BOOL fRet = TRUE;                   ///< return value
    int iRet;                           ///< captures bsp flash function return values

    if (pdwFlashSize_p == NULL)
    {
        fRet = FALSE;
        goto exit;
    }

    /* get pointer to flash instance structure */
    pFlashInst = alt_flash_open_dev(FLASH_CTRL_NAME);
    if (pFlashInst == NULL)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: Could not open Flash device!\n");
        fRet = FALSE;
        goto exit;
    }

    /* get some flash information */
    iRet = alt_get_flash_info(pFlashInst, &aFlashRegions, (int*) &wNumOfRegions);
    if (iRet != 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: alt_get_flash_info() failed! \n");
        fRet = FALSE;
        goto exit;
    }

    if (wNumOfRegions == 1 )
    { /* it is an EPCS device (with only one region)*/

        /* assign the first (and only) regions block size */
        dwBlockSize = aFlashRegions[bRegElmt].block_size;       // only for tracing
        *pdwFlashSize_p = aFlashRegions[bRegElmt].region_size;  //return flash size

        /* printf("\nWriting to flash %s.\n"
               "Block size:  %ld bytes.\n"
               "Block count: %d \n"
               "Flash size:  %ld (%#08lx)\n",
               FLASH_CTRL_NAME,
               dwBlockSize,
               aFlashRegions[bRegElmt].number_of_blocks,
               dwFlashSize,
               dwFlashSize); */
    }
    else
    { /* other devices currently not handled */
        //for dwFlashSize, regions have to be summed up in case of other device
        {
            DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: %s failed!\n", __func__);
            fRet = FALSE;
            goto exit;
        }
    }

    alt_flash_close_dev(pFlashInst);

exit:
    return fRet;
}

/**
 ********************************************************************************
 \brief writes to flash memory without corrupting non-written data
 \param pdwDestFlashOffset_p pointer to flash write destination offset
 \param pdwSize_p            pointer to size of source data
 \param pDataSrc_p           pointer to source data
 \return TRUE if successful, FALSE if not

 This function writes any size and value to flash memory without corrupting other
 data. If the source data size exceeds the flash size, it will result in an error.
 *******************************************************************************/
BOOL FpgaCfg_writeFlashSafely(const DWORD * pdwDestFlashOffset_p,
                              const DWORD * pdwSize_p,
                              const void * pDataSrc_p)
{
    alt_flash_fd *  pFlashInst = NULL;  ///< pointer to structure for flash device handling
    flash_region* aFlashRegions;        ///< flash regions array
    WORD wNumOfRegions;                 ///< number of flash regions
    BYTE bRegElmt = 0;                  ///< element of flash regions array
    WORD wBlockCnt = 0;                 ///< block counter
    DWORD dwBlockSize = 0;              ///< block size (fixed for each region)
    DWORD dwFlashSize = 0;              ///< size of whole flash memory
    DWORD dwDestOffset = 0;             ///< flash offset to be written to
    DWORD dwBlkDestOffset = 0;          ///< flash block start offset write destination
    const void * pSrc;                  ///< temporary data source pointer
    DWORD dwWriteSize = 0;              ///< data size to be written
    DWORD dwWrittenDataSize = 0;        ///< cumulating counter of already written data size
    DWORD dwFirstFlashBlkOfst = 0;      ///< first flash block offset of destination write block
    BOOL fRet = TRUE;                   ///< return value
    int iRet;                           ///< captures bsp flash function return values

    /* get pointer to flash instance structure */
    pFlashInst = alt_flash_open_dev(FLASH_CTRL_NAME);
    if (pFlashInst == NULL)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: Could not open Flash device!\n");
        fRet = FALSE;
        goto exit;
    }

    /* get some flash information */
    iRet = alt_get_flash_info(pFlashInst, &aFlashRegions, (int*) &wNumOfRegions);
    if (iRet != 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: alt_get_flash_info() failed! \n");
        fRet = FALSE;
        goto exit;
    }

    if (wNumOfRegions == 1 )
    { /* it is an EPCS device (with only one region)*/

        /* assign the first (and only) regions block size */
        bRegElmt = 0;
        dwBlockSize = aFlashRegions[bRegElmt].block_size;
        dwFlashSize = aFlashRegions[bRegElmt].region_size;

        /* printf("\nWriting to flash %s.\n"
               "Block size:  %ld bytes.\n"
               "Block count: %d \n"
               "Flash size:  %ld (%#08lx)\n",
               FLASH_CTRL_NAME,
               dwBlockSize,
               aFlashRegions[bRegElmt].number_of_blocks,
               dwFlashSize,
               dwFlashSize); */
    }
    else
    { /* other devices currently not handled */
        //for dwFlashSize, regions have to be summed up in case of other device
        {
            DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: %s failed!\n", __func__);
            fRet = FALSE;
            goto exit;
        }
    }

    /* check for useless values */
    if (dwBlockSize == 0                              ||
        aFlashRegions[bRegElmt].number_of_blocks == 0 ||
        dwFlashSize == 0                              ||
        pdwSize_p == NULL                             ||
        *pdwSize_p == 0                               ||
        pDataSrc_p == NULL                            ||
        (dwFlashSize - 1) < *pdwDestFlashOffset_p + *pdwSize_p) //flash size exceeded
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: %s failed!\n", __func__);
        fRet = FALSE;
        goto exit;
    }

    /* get flash block offsets for verification if write operation spans
     * more than one flash block
     */
    dwDestOffset = *pdwDestFlashOffset_p;
    fRet = FpgaCfg_getFlashBlockStartOffset(&dwDestOffset,
                                            pFlashInst,
                                            &dwFirstFlashBlkOfst);
    if (fRet != TRUE)
    {
        goto exit;
    }

    /* prepare write to first flash block */
    dwBlkDestOffset = dwFirstFlashBlkOfst;
    dwDestOffset = *pdwDestFlashOffset_p;
    pSrc = pDataSrc_p;

    /* write data to subsequent flash blocks */
    while ((*pdwSize_p - dwWrittenDataSize) > 0)
    {
        if (dwDestOffset + *pdwSize_p - dwWrittenDataSize > dwBlkDestOffset + aFlashRegions[bRegElmt].block_size)
        { /* write data spans into next block -> fill only one block up to it's end */
            dwWriteSize = dwBlkDestOffset + aFlashRegions[bRegElmt].block_size - dwDestOffset;
        }
        else
        { /* all write data fits into this block -> remaining size */
            dwWriteSize = *pdwSize_p - dwWrittenDataSize;
        }

        fRet = FpgaCfg_writeFlashBlockSafely(pFlashInst,
                                             (int) dwBlkDestOffset,
                                             aFlashRegions[bRegElmt].block_size,
                                             (int) dwDestOffset,
                                             pSrc,
                                             (int) dwWriteSize);
        if (fRet != TRUE)
        {
            DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: FpgaCfg_writeFlashBlockSafely() failed! \n");
            goto exit;
        }

        /* prepare write to next flash block */
        dwWrittenDataSize += dwWriteSize; // memorize how much data has already been written
        dwBlkDestOffset += aFlashRegions[bRegElmt].block_size;
        dwDestOffset += dwWriteSize;
        pSrc += dwWriteSize;

        wBlockCnt++;                     // count written blocks
    }

    DEBUG_TRACE3(DEBUG_LVL_ALWAYS, "INFO: Wrote %lu bytes of %lu to flash using %d blocks\n", dwWrittenDataSize, *pdwSize_p, wBlockCnt);

    alt_flash_close_dev(pFlashInst);

exit:
    return fRet;
}

/**
 ********************************************************************************
 \brief writes to a single flash block without corrupting other data
 \param pFlashInst_p      flash instance structure
 \param iBlkDestOffset_p  flash block start offset of write destination
 \param iBlkSize_p        flash block size
 \param iDestOffset_p     flash write destination offset
 \param pSrc_p            pointer to source data
 \param iWriteSize_p      size of source data
 \return TRUE if successful, FALSE if not

 This function writes to a single flash block. Only the intended data will be
 overwritten, all other data will be conserved by temporarily buffering the
 flash data block into an local buffer. With this mode, also NAND-Flashes can
 be written randomly without data corruption.
 This function does not check if it gets useful parameters i.e. it expects
 correct block start and destination data flash offsets. The destination data
 offset iDestOffset_p must be in range of the flash block with start offset
 iBlkDestOffset_p. The flash block size iBlkSize_p has to describe the flash
 block with start offset iBlkDestOffset_p correctly.
 Also, the sources data size iWriteSize_p should not exceed the block size
 iBlkSize_p.
 *******************************************************************************/
BOOL FpgaCfg_writeFlashBlockSafely(alt_flash_fd *pFlashInst_p,
                                   int iBlkDestOffset_p,
                                   int iBlkSize_p,
                                   int iDestOffset_p,
                                   const void * pSrc_p,
                                   int iWriteSize_p)
{
    BYTE *  pBlockShadowCopy = NULL;    ///< local copy of flash block
    BOOL fRet = TRUE;                   ///< return value
    int iRet;                           ///< captures bsp flash function return values

    /* check for useless values */
    if (pFlashInst_p == NULL   ||
        pSrc_p == NULL         ||
        iBlkSize_p == 0        ||
        iWriteSize_p == 0      ||
        iWriteSize_p > iBlkSize_p) //block size exceeded
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: %s failed!", __func__);
        fRet = FALSE;
        goto exit;
    }

    /* save whole block before it will be erased */
    pBlockShadowCopy = malloc(iBlkSize_p);
    if (pBlockShadowCopy == NULL)
    {
        fRet = FALSE;
        goto exit;
    }

    iRet = alt_read_flash(pFlashInst_p,
                          iBlkDestOffset_p,
                          pBlockShadowCopy,
                          iBlkSize_p);
    if (iRet != 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: alt_read_flash() failed! \n");
        fRet = FALSE;
        goto exit;
    }

    /* now lets write the source data to the local shadow block */
    memcpy(pBlockShadowCopy + (iDestOffset_p - iBlkDestOffset_p),
            pSrc_p,
            iWriteSize_p);

    /* erase whole block before we can do a write */
    iRet = alt_erase_flash_block(pFlashInst_p,
                                 iBlkDestOffset_p,
                                 iBlkSize_p);
    if (iRet != 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: alt_erase_flash_block() failed! \n");
        fRet = FALSE;
        goto exit;
    }

    /* write whole local shadow block to flash */
    iRet = alt_write_flash_block (pFlashInst_p,
                                  iBlkDestOffset_p,
                                  iBlkDestOffset_p,
                                  pBlockShadowCopy,
                                  iBlkSize_p);
    if (iRet != 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: alt_write_flash_block() failed! \n");
        fRet = FALSE;
        goto exit;
    }

    DEBUG_TRACE2(DEBUG_LVL_ALWAYS,"INFO: Write to DestOffset: %#08x (Block Base: %#08x)\n", iDestOffset_p, iBlkDestOffset_p);

exit:
    free(pBlockShadowCopy);

    return fRet;
}

/**
 ********************************************************************************
 \brief returns the block start address of a block the argument points to
 \param dwFlashOffsetDest_p     IN:  flash offset (pointing to required block offset)
 \param pFlashInst_p            IN:  instance of flash structure
 \param pdwBlockStartOffset_p   OUT: offset of block start where dwFlashOffsetDest_p
                                     points to
 \return TRUE if successful, FALSE if not

This function also checks if the argument dwFlashOffsetDest_p is located within
the flash memory borders. If this is not the case, ERROR will be returned.
 *******************************************************************************/
BOOL FpgaCfg_getFlashBlockStartOffset(DWORD * pdwFlashOffsetDest_p,
                             alt_flash_fd * pFlashInst_p, //TODO not working somehow
                             DWORD *        pdwBlockStartOffset_p)
{
    flash_region* aFlashRegions;        ///< flash regions array
    WORD wNumOfRegions;                 ///< number of flash regions
    BYTE bRegElmt = 0;                  ///< element of flash regions array
    WORD wBlockCnt = 1;                 ///< block counter
    DWORD dwBlockSize = 0;              ///< block size (fixed for each region)
    DWORD dwFlashSize = 0;              ///< size of whole flash memory
    int iRet = 0;                       ///< return value of internal used functions
    BOOL fRet = TRUE;                   ///< return value of this function
    DWORD dwBlockStartOffsetRet = 0;    ///< return value of block start offset

    iRet = alt_get_flash_info(pFlashInst_p, &aFlashRegions, (int*) &wNumOfRegions);
    if (iRet != 0       ||
        wNumOfRegions == 0)
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR,"ERROR: %s failed!", __func__);
        fRet = FALSE;
        goto exit;
    }

    if (wNumOfRegions == 1 )
    { /* it is an EPCS device (with only one region)*/

        /* assign the first (and only) regions block size */
        bRegElmt = 0;
        dwBlockSize = aFlashRegions[bRegElmt].block_size;

        dwFlashSize = aFlashRegions[bRegElmt].region_size;
    }
    else
    { /* other devices currently not handled */
        //for dwFlashSize, regions have to be summed up in case of other device
        {
            DEBUG_TRACE1(DEBUG_LVL_ERROR,"ERROR: %s failed!", __func__);
            fRet = FALSE;
            goto exit;
        }
    }

    /* check for useless values */
    if (dwBlockSize == 0                              ||
        aFlashRegions[bRegElmt].number_of_blocks == 0 ||
        dwFlashSize == 0                              ||
        (dwFlashSize - 1) < *pdwFlashOffsetDest_p) //flash size exceeded
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR,"ERROR: %s failed3!", __func__);
        fRet = FALSE;
        goto exit;
    }

    /* determine the flash blocks start address of the destination offset */
    for(wBlockCnt = 0; wBlockCnt < aFlashRegions[bRegElmt].number_of_blocks; wBlockCnt++)
    {
        dwBlockStartOffsetRet = aFlashRegions[bRegElmt].offset + dwBlockSize * (wBlockCnt+1);

        if (dwBlockStartOffsetRet > *pdwFlashOffsetDest_p)
        { /* we are one block above the found result -> set correct value and exit loop */
            dwBlockStartOffsetRet = aFlashRegions[bRegElmt].offset + dwBlockSize * wBlockCnt;
            break;
        }
    }

    /* assign return value */
    *pdwBlockStartOffset_p = dwBlockStartOffsetRet;

exit:
    return fRet;
}


/*******************************************************************************
*
* License Agreement
*
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved.
*
* Redistribution and use in source and binary forms,
* with or without modification,
* are permitted provided that the following conditions are met:
*
*   * Redistributions of source code must retain the above copyright notice,
*     this list of conditions and the following disclaimer.
*   * Redistributions in binary form must reproduce the above copyright notice,
*     this list of conditions and the following disclaimer
*     in the documentation and/or other materials provided with the
*     distribution.
*   * Neither the name of the B&R nor the names of its contributors
*     may be used to endorse or promote products derived from this software
*     without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
* A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
* THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
*******************************************************************************/
/* END-OF-FILE */
