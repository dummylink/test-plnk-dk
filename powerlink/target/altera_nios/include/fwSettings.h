/******************************************************************************
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is          
* subject to the License Agreement located at the end of this file below.     
*/

/**
********************************************************************************

\file       fwSettings.h

\brief      User firmware settings

\author     hoggerm

\date       03.08.2012

\since      03.08.2012

This header file contains user specific definitions for FPGA image and
SW storage in non-volatile memory. The start address of each firmware
image block is determined by the size of the previous blocks and the
section granularity of the non-volatile memory.
Additionally, default POWERLINK identification parameters are set, which
apply only if not PDI is present. If a PDI is present, the identification
parameters are set (overwritten) by the application processor.
*******************************************************************************/
#ifndef FWSETTINGS_H_
#define FWSETTINGS_H_
/* includes */

/******************************************************************************/
/* defines */

// =========================================================================
// defines for flash update function
// =========================================================================
// IIB is stored in flash
//#define CONFIG_IIB_IS_PRESENT                               // mandatory for FW-update
// flash address of factory IIB
#define CONFIG_FACTORY_IIB_FLASH_ADRS          0x00400000   // mandatory for FW-update
// flash address of user IIB
#define CONFIG_USER_IIB_FLASH_ADRS             0x00410000   // mandatory for FW-update
// flash address of user image
#define CONFIG_USER_IMAGE_FLASH_ADRS           0x00200000   // mandatory for FW-update
// used IIB version
// 1 = only PCP system
// 2 = AP software also present
#define CONFIG_USER_IIB_VERSION                2            // mandatory for FW-update

// =========================================================================
// defines for FPGA reconfiguration
// =========================================================================
// if defined, watchdog timer will be disabled (default)
#define CONFIG_DISABLE_WATCHDOG
// enable user image reconfiguration
//#define CONFIG_USER_IMAGE_IN_FLASH                          // mandatory for FW-update

// =========================================================================
// defines for POWERLINK device identification and configuration
// =========================================================================
// identification parameters, only relevant if PDI is not present
#define CONFIG_IDENT_PRODUCT_CODE           0
// B & R firmware file generation tool supports only 0..999 dec.
#define CONFIG_IDENT_REVISION               0x10020
#define CONFIG_IDENT_VENDOR_ID              0
#define CONFIG_IDENT_SERIAL_NUMBER          0
#define CONFIG_IDENT_DEVICE_NAME            "POWERLINK CN DEMO"

#endif /* FWSETTINGS_H_ */

/*******************************************************************************
*
* License Agreement
*
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1  
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

