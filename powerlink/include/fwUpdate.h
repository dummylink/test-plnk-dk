/**
********************************************************************************
\file           fwUpdate.h

\brief          Header file contains definitions for firmware update function

This header file contains definitions for the firmware update functions.

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

#ifndef FWUPDATE_H
#define FWUPDATE_H_

/******************************************************************************/
/* includes */
#include "cnApiGlobal.h"
#include "firmware.h"
#include "EplSdo.h"

/******************************************************************************/
/* defines */
#define FLASH_CTRL_NAME          EPCS_FLASH_CONTROLLER_0_NAME    //from system.h

/******************************************************************************/
/* function declarations */
#ifdef __cplusplus
extern "C" {
#endif

int initFirmwareUpdate(UINT32 deviceId_p, UINT32 hwRev_p);
tEplSdoComConState updateFirmware(UINT32 uiSegmentOff_p, UINT32 uiSegmentSize_p,
        char * pData_p, void *pfnAbortCb_p, void * pfnSegFinishCb_p, void * pHandle_p);
tEplSdoComConState updateFirmwarePeriodic(void);
tFwRet checkFwImage(UINT32 uiImgAdrs_p, UINT32 uiIibAdrs_p, UINT16 uiIibVersion_p);
tFwRet getApplicationSwDateTime(UINT32 uiIibAdrs_p, UINT32 *pUiApplicationSwDate_p,
                             UINT32 *pUiApplicationSwTime_p);
tFwRet getSwVersions(UINT32 uiIibAdrs_p, UINT32 *pUiFpgaConfigVersion_p,
                  UINT32 *pUiPcpSwVersion_p, UINT32 *pUiApSwVersion_p);

#ifdef __cplusplus
}
#endif

#endif /* FWUPDATE_H_ */
