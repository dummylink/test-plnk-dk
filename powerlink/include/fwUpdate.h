/**
********************************************************************************
\file           firmware.h

\brief          Header file contains definitions for firmware update function

\author         Josef Baumgartner

\date           22.08.2011

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This header file contains definitions for the firmware update functions.
*******************************************************************************/
#ifndef FWUPDATE_H
#define FWUPDATE_H_

/******************************************************************************/
/* includes */
#include "cnApiGlobal.h"
#include "firmware.h"

/******************************************************************************/
/* function declarations */
#ifdef __cplusplus
extern "C" {
#endif

int initFirmwareUpdate(UINT32 deviceId_p, UINT32 hwRev_p);
int updateFirmware(UINT32 uiSegmentOff_p, UINT32 uiSegmentSize_p, char * pData_p,
        void *pfnAbortCb_p, void * pfnSegFinishCb_p, void * pHandle_p);
void updateFirmwarePeriodic(void);
int checkIib(tIib *pIib_p, UINT8 uiVersion_p);
int checkImage(UINT32 uiOffset_p, UINT32 uiSize_p, UINT32 uiCrc_p);

#ifdef __cplusplus
}
#endif

#endif /* FWUPDATE_H_ */
