/*******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       pcpSync.c

\brief      Module for writing the Time information into the PDI

\author     mairt

\date       09.01.2012

\since      09.01.2012

This module sets the RelativeTime and Nettime fields inside the pdi if they are provided
by the powerlink master

*******************************************************************************/

#include "pcpSync.h"
#include "pcpEvent.h"

#include "kernel/EplTimerSynck.h"
#include "Epl.h"

#include "systemComponents.h"


/******************************************************************************/
/* typedefs */
typedef enum ePcpRelativeTimeState
{
    kPcpRelativeTimeStateWaitFirstValidRelativeTime = 0x01, ///< no valid RelativeTime received yet
    kPcpRelativeTimeStateActiv = 0x02,                      ///< RelativeTime is running
    kPcpRelativeTimeStateInvalid = 0x03,                    ///< invalid state

} tPcpRelativeTimeState;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
tPcpRelativeTimeState PcpRelativeTimeState_l = kPcpRelativeTimeStateWaitFirstValidRelativeTime;   ///< state variable of the RelativeTime state machine
QWORD qwRelativeTime_g = 0;        ///< local relative time counter
WORD wSyncIntCycle_g = 0;


/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief    inits the timesync field
*******************************************************************************/
void Gi_initSync(void)
{
    Gi_disableSyncInt();

    /* init the nettime fields */
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwNetTimeSec, 0x00);
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwNetTimeNanoSec, 0x00);

    /* init the relativetime fields */
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwRelativeTimeLow, 0x00);
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwRelativeTimeHigh, 0x00);
}

/**
********************************************************************************
\brief    reset the relative time state machine to the init state
*******************************************************************************/
void Gi_resetTimeValues(void)
{
    PcpRelativeTimeState_l = kPcpRelativeTimeStateWaitFirstValidRelativeTime;
    qwRelativeTime_g = 0;

    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwRelativeTimeLow, 0x00);
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwRelativeTimeHigh, 0x00);

    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwNetTimeSec, 0x00);
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwNetTimeNanoSec, 0x00);
}

/**
********************************************************************************
\brief    writes the current relativetime into the pdi
*******************************************************************************/
tEplKernel Gi_setRelativeTime(QWORD qwRelativeTime_p, BOOL fTimeValid_p, BOOL fCnIsOperational_p)
{
    tEplKernel  EplRet = kEplSuccessful;

    DWORD dwCycleTime = AmiGetDwordFromLe((BYTE*)&(pCtrlReg_g->m_dwSyncIntCycTime));

    if(dwCycleTime == 0)
    {
        EplRet = kEplInvalidParam;
        goto Exit;
    }

    switch(PcpRelativeTimeState_l)
    {
        case kPcpRelativeTimeStateWaitFirstValidRelativeTime:
        {
            if(fCnIsOperational_p != FALSE)
            {
                if(fTimeValid_p != FALSE)
                {
                    qwRelativeTime_g = qwRelativeTime_p;          ///< read the value once and activate relative time
                    qwRelativeTime_g += dwCycleTime;               ///< increment it once to be up to date
                    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwRelativeTimeLow, (DWORD)qwRelativeTime_g);
                    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwRelativeTimeHigh, (DWORD)(qwRelativeTime_g>>32));
                    PcpRelativeTimeState_l = kPcpRelativeTimeStateActiv;
                } else {
                    /* CN is operational but RelativeTime is still not Valid! (We now start counting without an offset) */
                    qwRelativeTime_g += dwCycleTime;
                    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwRelativeTimeLow, (DWORD)qwRelativeTime_g);
                    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwRelativeTimeHigh, (DWORD)(qwRelativeTime_g>>32));
                    PcpRelativeTimeState_l = kPcpRelativeTimeStateActiv;
                }
            } else {
                /* increment local RelativeTime and wait for an arriving time val from the soc */
                qwRelativeTime_g += dwCycleTime;
            }
           break;
        }
        case kPcpRelativeTimeStateActiv:
        {
            qwRelativeTime_g += dwCycleTime;
            AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwRelativeTimeLow, (DWORD)qwRelativeTime_g);
            AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwRelativeTimeHigh, (DWORD)(qwRelativeTime_g>>32));
           break;
        }
        case kPcpRelativeTimeStateInvalid:
        {
            EplRet = kEplInvalidParam;
            goto Exit;
           break;
        }
        default:
            break;
    }

Exit:
    return EplRet;
}

/**
********************************************************************************
\brief    writes the current nettime into the pdi
*******************************************************************************/
inline void Gi_setNetTime(DWORD dwNetTimeSeconds_p, DWORD dwNetTimeNanoSeconds_p)
{
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwNetTimeSec, dwNetTimeSeconds_p);
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwNetTimeNanoSec, dwNetTimeNanoSeconds_p);
}

/**
********************************************************************************
\brief    enable the synchronous PDI interrupt
*******************************************************************************/
void Gi_enableSyncInt(WORD wSyncIntCycle_p)
{

#ifdef TIMESYNC_HW
    // enable IRQ and set mode to "IR generation by HW"
	AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wSyncIrqControl, ((1 << SYNC_IRQ_ENABLE) | (1 << SYNC_IRQ_MODE)));
    /* in addition also enable the hw interrupt in the EPL time sync module*/
    EplTimerSynckCompareTogPdiIntEnable(wSyncIntCycle_p);
#else
    // enable IRQ and set mode to "IR generation by SW"
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wSyncIrqControl, ((1 << SYNC_IRQ_ENABLE) & ~(1 << SYNC_IRQ_MODE)));
#endif

    return;
}

/**
********************************************************************************
\brief    disable the PCP -> AP synchronization interrupt
*******************************************************************************/
void Gi_disableSyncInt(void)
{
    WORD wSyncIrqControl = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wSyncIrqControl));

    /* disable interrupt by writing to the SYNC_IRQ_CONTROL_REGISTER */
    wSyncIrqControl &= ~(1 << SYNC_IRQ_ENABLE); // set enable bit to low
    wSyncIrqControl &= ~(1 << SYNC_IRQ_MODE); // set mode bit to low

    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wSyncIrqControl, wSyncIrqControl);

#ifdef TIMESYNC_HW
    /* in addition also disable the hw interrupt in the EPL time sync module*/
    EplTimerSynckCompareTogPdiIntDisable();
#endif

    return;
}

/**
********************************************************************************
\brief    generate the PCP -> AP synchronization interrupt
*******************************************************************************/
void Gi_generateSyncInt(void)
{
    WORD wSyncIrqControl = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wSyncIrqControl));

    /* Throw interrupt in SW by writing to the SYNC_IRQ_CONTROL_REGISTER */
    wSyncIrqControl |= (1 << SYNC_IRQ_SET); //set IRQ_SET bit to high

    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wSyncIrqControl, wSyncIrqControl);

    return;
}

/**
********************************************************************************
\brief  read control register sync mode flags
*******************************************************************************/
BOOL Gi_checkSyncIrqRequired(void)
{
    WORD wSyncModeFlags;

    wSyncModeFlags = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wSyncIrqControl));

    if(wSyncModeFlags &= (1 << SYNC_IRQ_REQ))
        return TRUE;  ///< Sync IR is required
    else
        return FALSE; ///< Sync IR is not required -> AP applies polling
}

/**
********************************************************************************
\brief    calculate sync interrupt period
*******************************************************************************/
void Gi_calcSyncIntPeriod(void)
{
    int                iNumCycles;
    int                iSyncPeriod;
    unsigned int       uiCycleTime;
    unsigned int       uiSize;
    tEplKernel         EplRet = kEplSuccessful;
    DWORD              dwMinCycleTime = AmiGetDwordFromLe((BYTE*)&(pCtrlReg_g->m_dwMinCycleTime));
    DWORD              dwMaxCycleTime = AmiGetDwordFromLe((BYTE*)&(pCtrlReg_g->m_dwMaxCycleTime));

    uiSize = sizeof(uiCycleTime);
    EplRet = EplApiReadLocalObject(0x1006, 0, &uiCycleTime, &uiSize);
    if (EplRet != kEplSuccessful)
    {
        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
        wSyncIntCycle_g = 0;
        return;
    }

    if ((dwMinCycleTime == 0) &&
        (dwMaxCycleTime == 0)   )
    {
        /* no need to trigger IR signal - polling mode is applied */
        wSyncIntCycle_g = 0;
        return;
    }

    iNumCycles = (dwMinCycleTime + uiCycleTime - 1) / uiCycleTime;    /* do it this way to round up integer division! */
    iSyncPeriod = iNumCycles * uiCycleTime;

    DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "calcSyncIntPeriod: tCycle=%d tMinTime=%lu --> syncPeriod=%d\n",
                   uiCycleTime, dwMinCycleTime, iSyncPeriod);

    if (iSyncPeriod > dwMaxCycleTime)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: Cycle time set by network to high for AP!\n");

        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
        wSyncIntCycle_g = 0;
        return;
    }
    if (iSyncPeriod < dwMinCycleTime)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: Cycle time set by network to low for AP!\n");

        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
        wSyncIntCycle_g = 0;
        return;
    }

    wSyncIntCycle_g = iNumCycles;
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwSyncIntCycTime, iSyncPeriod);   ///< inform AP: write result in control register
    Gi_pcpEventPost(kPcpPdiEventGeneric, kPcpGenEventSyncCycleCalcSuccessful);

    return;
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
