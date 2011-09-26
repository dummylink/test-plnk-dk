/******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       FpgaCfg.h

\brief      Header file for Altera FPGA configuration module

\author     hoggerm

\date       17.05.2011

\since      17.05.2011

*******************************************************************************/
#ifndef FPGACFG_H_
#define FPGACFG_H_
/******************************************************************************/
/* includes */

#include "Debug.h"
#include "system.h"
#include <sys/alt_flash.h>
#include <sys/alt_flash_dev.h>

/******************************************************************************/
/* defines */

/************************************/
/* User adjustable defines          */
/*                                  */
#define DEFAULT_DISABLE_WATCHDOG            ///< if defined, watchdog timer will be disabled
#undef NO_FACTORY_IMG_IN_FLASH             ///< this define skips triggering
                                            ///< user image reconfiguration
// do not reset to Flash memory, if no image is stored there yet
// activate this define, if you use only JTAG programming!

#define FACTORY_IMAGE_MAX_SIZE   0x130000UL    ///< this is FPGA, SW size and image bit stream compression level dependent
#define USER_IMAGE_MAX_SIZE      0x130000UL    ///< this is FPGA, SW size and image bit stream compression level dependent
/*                                  */
/* End of user adjustable defines   */
/************************************/

#define CONFIG_STORAGE_MAX_SIZE  0x200      ///< mapping and other important objects have to fit in this section

/* Defines for flash memory sections. No overlapping allowed! */
#define FLASH_SECTION_OFFSET_FACTORY_IMAGE  0x000000UL                  ///< start of factory image; DO NOT CHANGE!
#define FLASH_SECTION_OFFSET_USER_IMAGE     \
        (FLASH_SECTION_OFFSET_FACTORY_IMAGE + FACTORY_IMAGE_MAX_SIZE)   ///< start of application image
#define FLASH_SECTION_OFFSET_CONFIG_STORAGE \
        (FLASH_SECTION_OFFSET_USER_IMAGE + USER_IMAGE_MAX_SIZE)         ///< start of POWERLINK configuration data
#define FLASH_SECTION_OFFSET_NON_PCP_SPARE  \
        (FLASH_SECTION_OFFSET_CONFIG_STORAGE + CONFIG_STORAGE_MAX_SIZE) ///< start of spare section not used by PCP

#define RESET_TIMER 1 //register bit offset
#define REMOTE_UPDATE_CORE_BASE  REMOTE_UPDATE_CYCLONEIII_0_BASE //from system.h
#define FLASH_CTRL_NAME          EPCS_FLASH_CONTROLLER_0_NAME    //from system.h
/******************************************************************************/
/* typedefs */
typedef enum eFpgaCfgRetVal {
  kFgpaCfgFactoryImageLoadedNoUserImagePresent,
  kFpgaCfgUserImageLoadedWatchdogDisabled,
  kFpgaCfgUserImageLoadedWatchdogEnabled,
  kFgpaCfgWrongSystemID, ///< stop booting -> SW does not fit to HW
  kFpgaCfgInvalidRetVal,
} tFpgaCfgRetVal;

typedef enum eFpgaCfgFlashRegionName {
  kFpgaCfgFlashRegionFactoryImage,          ///< region for factory FPGA configuration + SW
  kFpgaCfgFlashRegionUserImage,             ///< region for user FPGA configuration + SW
  kFpgaCfgFlashRegionConfigurationStorage,  ///< region for POWERLINK configuration data storage
  kFpgaCfgFlashRegionNonPcpSpare,           ///< spare region not used by PCP
} tFpgaCfgFlashRegionName;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */
extern void FpgaCfg_reloadFromFlash(DWORD dwResetAdr_p);
extern void FpgaCfg_resetWatchdogTimer(void);
extern tFpgaCfgRetVal FpgaCfg_handleReconfig(void);

extern BOOL FpgaCfg_getFlashSize(DWORD * pdwFlashSize_p);
extern BOOL FpgaCfg_writeFlashSafely(
                       const DWORD * pdwDestFlashOffset_p, //TODO: make static (put to c-file) as soon as tested
                       const DWORD * pdwSize_p,
                       const void * pDataSrc_p);
extern BOOL FpgaCfg_readFlash(const DWORD * pdwSrcFlashOffset_p,
                       DWORD * pdwSize_p,
                       void * pDest_p);
extern BOOL FpgaCfg_writeFlashUserImageRegion(tFpgaCfgFlashRegionName RegionName_p,
                       DWORD * pdwDestFlashOffset_p,
                       const BYTE * pSrc_p,
                       DWORD * pdwSize_p);


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
#endif /* FPGACFG_H_ */

/* END-OF-FILE */

