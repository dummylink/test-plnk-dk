/*******************************************************************************
* Copyright � 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       fpgaCfg.c

\brief      Module for Altera FPGA configuration tasks using the
            Cyclone III Remote Update Controller (SOPC) core

\author     hoggerm

\date       17.05.2011

\since      17.05.2011

*******************************************************************************/
/* includes */
#include "fpgaCfg.h"
#include "EplInc.h"
#include "global.h"
#include "fwUpdate.h"
//#include "altera_avalon_pio_regs.h"	//TODO
#include <string.h>                      //for memcpy()

//#ifdef SYSID_BASE
//#include "altera_avalon_sysid.h"
//#include "altera_avalon_sysid_regs.h"
//#else
//#warning: No SOPC module "SYSTEM-ID" present! Checking if SW fits to HW can not be performed!
//#endif /* SYSID_BASE */

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
void FpgaCfg_disableWatchdog(void);
void FpgaCfg_enableWatchdog(void);
void FpgaCfg_enableEarlyCnfDoneCheck(void);
void FpgaCfg_enableInternalOscStartUp(void);
void FpgaCfg_setWatchdogTimer(WORD wTimeout_p);
DWORD FpgaCfg_getWatchdogCounterSetting(void);
DWORD FpgaCfg_getWatchdogStatus(void);
DWORD FpgaCfg_getCurRemoteUpdateCoreState(void);
DWORD FpgaCfg_getCurFactoryBootAdr(void);
DWORD FpgaCfg_getPast1BootAdr(void);
DWORD FpgaCfg_getPast2BootAdr(void);
DWORD FpgaCfg_getPast1ReconfigTriggerCondition(void);

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
    if(dwResetAdr_p == CONFIG_FACTORY_IMAGE_FLASH_ADRS)
    {
        // If reset to factoy image is required, this workaround is
        // needed to fall back into factory mode image again.
        // Otherwise the remote update core state will tell
        // that is has the user image even is loaded from
        // CONFIG_FACTORY_IMAGE_FLASH_ADRS, because it can not
        // distinguish its mode according to the reset address.
        FpgaCfg_enableWatchdog();

        //set lowest possible timeout and expect an immediate reconfiguration
        FpgaCfg_setWatchdogTimer(1);
    }

    //set base address of image to be loaded
//    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x04, dwResetAdr_p >> 2);	//TODO
    //trigger reconfiguration
//    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x20, 1);
}

/********************************************************************************
\brief resets the processor

This function sets the status and interrupt enable register to zero. Then
it resets the processor.
*******************************************************************************/
void FpgaCfg_resetProcessor(void)
{
//    NIOS2_WRITE_STATUS(0);	//TODO
//    NIOS2_WRITE_IENABLE(0);
//    ((void (*) (void)) NIOS2_RESET_ADDR) ();
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
    /*printf("Input Reg. before watchdog disable: %d\n",
             IORD(REMOTE_UPDATE_CORE_BASE, 0x18 | 0x03));*/
//    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x03, 0); //disable watchdog timer    //TODO
    /*printf("Input Reg. after watchdog disable: %d\n",
             IORD(REMOTE_UPDATE_CORE_BASE, 0x18 | 0x03));*/
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
    /*printf("Input Reg. before watchdog enable: %d\n",
             IORD(REMOTE_UPDATE_CORE_BASE, 0x18 | 0x03)); */
//    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x03, 1); //enable watchdog timer    //TODO
    /*printf("Input Reg. after watchdog enable: %d\n",
             IORD(REMOTE_UPDATE_CORE_BASE, 0x18 | 0x03)); */
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
//    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x01, 1); // set 1 bit to high    //TODO
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
//    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x06, 1); // set 1 bit to high    //TODO
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

//    // only enable the watchdog timer if its timeout value is greater than 0.
//    if( wTimeout_p >= 1)
//    {
//        // set timeout value
//        IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x02, wTimeout_p );
//    }
//    else
//    {
//        // disable the watchdog timer
//        FpgaCfg_disableWatchdog();
//    }
//
//    // max value can be 0xFFFh
//    DEBUG_TRACE1(DEBUG_LVL_15, "Input reg. watchdog timeout: 0x%x\n",
//            IORD(REMOTE_UPDATE_CORE_BASE, 0x18 | 0x02));
//
//    // max value can be 0x1FFE0000h ==> apprx 53 seconds (with 10 Mhz)
//    DEBUG_TRACE1(DEBUG_LVL_15, "Actual watchdog timeout set: 0x%x\n",
//                 0x20000 * IORD(REMOTE_UPDATE_CORE_BASE, 0x18 | 0x02));
}

/**
********************************************************************************
\brief delays the reconfiguration triggering if watchdog is enabled by resetting
       the counter to its original value
*******************************************************************************/
void FpgaCfg_resetWatchdogTimer(void)
{
//    register DWORD dwRegister;
//
//    dwRegister = IORD(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x20);
//
//    dwRegister |= (1 << RESET_TIMER);  //set RESET_TIMER bit to 1
//    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x20, dwRegister); // reset timer
//    dwRegister &= ~(1 << RESET_TIMER); // set RESET_TIMER bit to 0
//    IOWR(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x20, dwRegister); // continue counting
//
//    DEBUG_TRACE0(DEBUG_LVL_15, "Watchdog timeout reset triggered!\n");
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
    dwRegister = 0; //IORD(REMOTE_UPDATE_CORE_BASE,  0x08 | 0x02);
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
    dwRegister = 0;//IORD(REMOTE_UPDATE_CORE_BASE,  0x08 | 0x03);
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
    dwRegister = 0;//IORD(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x00);
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
    dwRegister = 0;//IORD(REMOTE_UPDATE_CORE_BASE, 0x00 | 0x04);
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
    dwRegister = 0;//IORD(REMOTE_UPDATE_CORE_BASE, 0x08 | 0x04);
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
    dwRegister = 0;//IORD(REMOTE_UPDATE_CORE_BASE, 0x10 | 0x04);
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
    dwRegister = 0;//IORD(REMOTE_UPDATE_CORE_BASE, 0x08 | 0x07);
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
    tFpgaCfgRetVal Ret = kFgpaCfgFactoryImageLoadedNoUserImagePresent;
//    BOOL fApplicationImageFailed = FALSE;
//    DWORD dwTriggerCondition;
//    tFwRet FwRetVal = kFwRetSuccessful;
//
//#ifdef SYSID_BASE
//    DEBUG_TRACE2(DEBUG_LVL_ALWAYS,
//                 "Reconfigured with system time stamp: %d \nand system ID: %d\n",
//                 IORD_ALTERA_AVALON_SYSID_TIMESTAMP(SYSID_BASE),
//                 IORD_ALTERA_AVALON_SYSID_ID(SYSID_BASE));
//
//    /* verify if BSP matches SOPC system ID */
//    if (alt_avalon_sysid_test() != 0)
//    {
//        DEBUG_TRACE4(DEBUG_LVL_ERROR,
//                     "System mismatch!\n"
//                     "FPGA config: (timestamp: %lu / sysID: %lu)\n"
//                     "SW:          (timestamp: %lu / sysID: %lu)\n" ,
//                     IORD_ALTERA_AVALON_SYSID_TIMESTAMP(SYSID_BASE),
//                     IORD_ALTERA_AVALON_SYSID_ID(SYSID_BASE),
//                     SYSID_TIMESTAMP,
//                     SYSID_ID);
//
//        Ret = kFgpaCfgWrongSystemID;
//        goto exit;
//    }
//#endif /* SYSID_BASE */
//
//    DEBUG_TRACE1(DEBUG_LVL_15, "\nConfiguration State: %lu\n",
//                   FpgaCfg_getCurRemoteUpdateCoreState());
//
//    switch (FpgaCfg_getCurRemoteUpdateCoreState())
//    {
//        case 0x00:
//        {/* factory mode */
//
//            dwTriggerCondition = FpgaCfg_getPast1ReconfigTriggerCondition();
//
//            DEBUG_TRACE1(DEBUG_LVL_ERROR, "Factory image triggered by: 0x%lx",
//                         dwTriggerCondition);
//            if (dwTriggerCondition == 0x00)
//            {
//                DEBUG_TRACE0(DEBUG_LVL_ERROR, " (power up)\n");
//            }
//            if (dwTriggerCondition & 0x01)
//            {
//                DEBUG_TRACE0(DEBUG_LVL_ERROR, " (remote update core)\n");
//            }
//            if (dwTriggerCondition & 0x02)
//            {
//                DEBUG_TRACE0(DEBUG_LVL_ERROR, " (watchdog timeout)\n");
//                fApplicationImageFailed = TRUE;
//            }
//            if (dwTriggerCondition & 0x04)
//            {
//                DEBUG_TRACE0(DEBUG_LVL_ERROR, " (nSTATUS assertion)\n");
//                // no valid application image presen at FLASH_FPGA_USER_IMAGE_ADR
//                fApplicationImageFailed = TRUE;
//            }
//            if (dwTriggerCondition & 0x08)
//            {
//                DEBUG_TRACE0(DEBUG_LVL_ERROR, " (config CRC error)\n");
//                fApplicationImageFailed = TRUE;
//            }
//            if (dwTriggerCondition & 0x010)
//            {
//                DEBUG_TRACE0(DEBUG_LVL_ERROR, " (external nCONFIG reset)\n");
//            }
//
//            DEBUG_TRACE1(DEBUG_LVL_ERROR, "and loaded from address: 0x%08lx\n",
//                         FpgaCfg_getCurFactoryBootAdr());
//
//            if (fApplicationImageFailed)
//            { /* do not trigger application configuration again */
//                DEBUG_TRACE1(DEBUG_LVL_ERROR,
//                             "Bad application image at address: 0x%08lx\n",
//                             FpgaCfg_getPast1BootAdr());
//
//                if (FpgaCfg_getPast1BootAdr() != CONFIG_FACTORY_IMAGE_FLASH_ADRS)
//                {
//                    // If the "application image" was not the factory image then prevent
//                    // reconfiguration to user image again.
//                    Ret = kFgpaCfgFactoryImageLoadedNoUserImagePresent;
//                    goto exit;
//                }
//
//                // It was the factory image which cause the failed application image,
//                // this is ok (used as workaround)! Go on with resetting to user image.
//            }
//
//            /* trigger user image reconfiguration */
//
//            /* Watchdog is enabled per default in factory mode, so enabling
//             * is not necessary. */
//#ifdef CONFIG_DISABLE_WATCHDOG
//            FpgaCfg_disableWatchdog();
//#else
//            FpgaCfg_setWatchdogTimer(0xfff); // max value is 0xfff -> apprx. 53 seconds
//#endif /* CONFIG_DISABLE_WATCHDOG */
//
//            /* set special bits - recommended by Altera */
//            FpgaCfg_enableEarlyCnfDoneCheck();
//            FpgaCfg_enableInternalOscStartUp();
//
//#ifdef CONFIG_USER_IMAGE_IN_FLASH
//
//            FwRetVal = checkFwImage(CONFIG_USER_IMAGE_FLASH_ADRS,
//                                    CONFIG_USER_IIB_FLASH_ADRS,
//                                    CONFIG_USER_IIB_VERSION);
//            if(FwRetVal != kFwRetSuccessful)
//            {
//                DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: checkFwImage() of user image failed with 0x%x\n", FwRetVal);
//
//                Ret = kFgpaCfgFactoryImageLoadedNoUserImagePresent;
//                break;
//            }
//            DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "User image check: OK! Reset to User Image...\n");
//
//            //usleep(1000*10000); //activate this line for debugging
//
//            /* trigger reconfiguration of user image */
//            FpgaCfg_reloadFromFlash(CONFIG_USER_IMAGE_FLASH_ADRS);
//
//            /* we never should come here because we triggered
//             * FPGA reconfiguration! */
//
//#endif /* CONFIG_USER_IMAGE_IN_FLASH */
//            break;
//        }
//
//        case 0x01:
//        { /* application mode - watchdog disabled */
//            Ret = kFpgaCfgUserImageLoadedWatchdogDisabled;
//            break;
//        }
//        case 0x03:
//        { /* application mode - watchdog enabled -> application needs to reset timer periodically */
//            DEBUG_TRACE1(DEBUG_LVL_ALWAYS, "Watchdog timeout set to: 0x%lx\n", FpgaCfg_getWatchdogCounterSetting());
//            Ret = kFpgaCfgUserImageLoadedWatchdogEnabled;
//            break;
//        }
//        default:
//        break;
//    }
//
//exit:
    return Ret;
}

/**
********************************************************************************
\brief evaluates the FPGA reconfiguration according to its status

\param ReConfStatus_p  tFpgaCfgRetVal
\retval TRUE    User image is loaded
\retval FALSE   Factory image is loaded
*******************************************************************************/
BOOL FpgaCfg_processReconfigStatusIsUserImage(tFpgaCfgRetVal ReConfStatus_p)
{
    BOOL fIsUserImage = FALSE;
//    tFwRet FwRetVal = kFwRetSuccessful;

    return fIsUserImage;
}

/*******************************************************************************
*
* License Agreement
*
* Copyright � 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
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
