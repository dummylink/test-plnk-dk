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

/******************************************************************************/
/* function declarations */
#ifdef __cplusplus
extern "C" {
#endif

int initFirmwareUpdate(UINT32 deviceId_p, UINT32 hwRev_p);
int updateFirmware(UINT32 * pSegmentOff_p, UINT32 * pSegmentSize_p, char * pData_p,
        void *pfnAbortCb_p, void * pfnSegFinishCb_p);
void updateFirmwarePeriodic(void);


#ifdef __cplusplus
}
#endif

#endif /* FWUPDATE_H_ */
