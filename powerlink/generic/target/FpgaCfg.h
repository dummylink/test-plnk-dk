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
#include "global.h"
#include "debug.h"
#include "system.h"

/******************************************************************************/
/* defines */
#define FLASH_FPGA_USER_IMAGE_ADR 0x130000    ///< user defined application image
                                              ///< start address in flash
#define FLASH_FPGA_FACTORY_IMAGE_ADR 0x000000 ///< fixed facory image address

#define RESET_TIMER 1 //register bit offset
#define REMOTE_UPDATE_CORE_BASE  REMOTE_UPDATE_CYCLONEIII_0_BASE
/******************************************************************************/
/* typedefs */
typedef enum eFpgaCfgRetVal {
  kFgpaCfgFactoryImageLoadedNoUserImagePresent,
  kFpgaCfgUserImageLoadedWatchdogDisabled,
  kFpgaCfgUserImageLoadedWatchdogEnabled,
  kFpgaCfgInvalidRetVal,
} tFpgaCfgRetVal;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */
extern void FpgaCfg_reloadFromFlash(DWORD dwResetAdr_p);
extern void FpgaCfg_resetWatchdogTimer(void);
extern tFpgaCfgRetVal FpgaCfg_handleReconfig(void);

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

