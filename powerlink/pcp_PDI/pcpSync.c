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
#include "kernel/EplTimerSynck.h"


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
    pCtrlReg_g->m_dwNetTimeSec = 0;
    pCtrlReg_g->m_dwNetTimeNanoSec = 0;

    /* init the relativetime fields */
    pCtrlReg_g->m_dwRelativeTimeLow = 0;
    pCtrlReg_g->m_dwRelativeTimeHigh = 0;
}

/**
********************************************************************************
\brief    reset the relative time state machine to the init state
*******************************************************************************/
void Gi_resetTimeValues(void)
{
    PcpRelativeTimeState_l = kPcpRelativeTimeStateWaitFirstValidRelativeTime;
    qwRelativeTime_g = 0;

    pCtrlReg_g->m_dwRelativeTimeLow = (DWORD)0;
    pCtrlReg_g->m_dwRelativeTimeHigh = (DWORD)0;

    pCtrlReg_g->m_dwNetTimeSec = (DWORD)0;
    pCtrlReg_g->m_dwNetTimeNanoSec = (DWORD)0;

}

/**
********************************************************************************
\brief    writes the current relativetime into the pdi
*******************************************************************************/
tEplKernel Gi_setRelativeTime(QWORD qwRelativeTime_p, BOOL fTimeValid_p, BOOL fCnIsOperational_p)
{
    tEplKernel  EplRet = kEplSuccessful;
    DWORD dwCycleTime = pCtrlReg_g->m_dwSyncIntCycTime;

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
                    pCtrlReg_g->m_dwRelativeTimeLow = (DWORD)qwRelativeTime_g;
                    pCtrlReg_g->m_dwRelativeTimeHigh = (DWORD)(qwRelativeTime_g>>32);
                    PcpRelativeTimeState_l = kPcpRelativeTimeStateActiv;
                } else {
                    /* CN is operational but RelativeTime is still not Valid! (We now start counting without an offset) */
                    qwRelativeTime_g += dwCycleTime;
                    pCtrlReg_g->m_dwRelativeTimeLow = (DWORD)qwRelativeTime_g;
                    pCtrlReg_g->m_dwRelativeTimeHigh = (DWORD)(qwRelativeTime_g>>32);
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
            pCtrlReg_g->m_dwRelativeTimeLow = (DWORD)qwRelativeTime_g;
            pCtrlReg_g->m_dwRelativeTimeHigh = (DWORD)(qwRelativeTime_g>>32);
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

    pCtrlReg_g->m_dwNetTimeSec = dwNetTimeSeconds_p;
    pCtrlReg_g->m_dwNetTimeNanoSec = dwNetTimeNanoSeconds_p;
}

/**
********************************************************************************
\brief    enable the synchronous PDI interrupt
*******************************************************************************/
void Gi_enableSyncInt(WORD wSyncIntCycle_p)
{

#if POWERLINK_0_MAC_CMP_TIMESYNCHW != FALSE
    // enable IRQ and set mode to "IR generation by HW"
    pCtrlReg_g->m_wSyncIrqControl = ((1 << SYNC_IRQ_ENABLE) | (1 << SYNC_IRQ_MODE));
    /* in addition also enable the hw interrupt in the EPL time sync module*/
    EplTimerSynckCompareTogPdiIntEnable(wSyncIntCycle_p);
#else
    // enable IRQ and set mode to "IR generation by SW"
    pCtrlReg_g->m_wSyncIrqControl = ((1 << SYNC_IRQ_ENABLE) & ~(1 << SYNC_IRQ_MODE));
#endif

    return;
}

/**
********************************************************************************
\brief    disable the PCP -> AP synchronization interrupt
*******************************************************************************/
void Gi_disableSyncInt(void)
{
    /* disable interrupt by writing to the SYNC_IRQ_CONTROL_REGISTER */
    pCtrlReg_g->m_wSyncIrqControl &= ~(1 << SYNC_IRQ_ENABLE); // set enable bit to low
    pCtrlReg_g->m_wSyncIrqControl &= ~(1 << SYNC_IRQ_MODE); // set mode bit to low

#if POWERLINK_0_MAC_CMP_TIMESYNCHW != FALSE
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
    /* Throw interrupt in SW by writing to the SYNC_IRQ_CONTROL_REGISTER */
    pCtrlReg_g->m_wSyncIrqControl |= (1 << SYNC_IRQ_SET); //set IRQ_SET bit to high

    return;
}

/**
********************************************************************************
\brief  read control register sync mode flags
*******************************************************************************/
BOOL Gi_checkSyncIrqRequired(void)
{
    WORD wSyncModeFlags;

    wSyncModeFlags = pCtrlReg_g->m_wSyncIrqControl;

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

    uiSize = sizeof(uiCycleTime);
    EplRet = EplApiReadLocalObject(0x1006, 0, &uiCycleTime, &uiSize);
    if (EplRet != kEplSuccessful)
    {
        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
        wSyncIntCycle_g = 0;
        return;
    }

    if ((pCtrlReg_g->m_dwMinCycleTime == 0) &&
        (pCtrlReg_g->m_dwMaxCycleTime == 0)   )
    {
        /* no need to trigger IR signal - polling mode is applied */
        wSyncIntCycle_g = 0;
        return;
    }

    iNumCycles = (pCtrlReg_g->m_dwMinCycleTime + uiCycleTime - 1) / uiCycleTime;    /* do it this way to round up integer division! */
    iSyncPeriod = iNumCycles * uiCycleTime;

    DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "calcSyncIntPeriod: tCycle=%d tMinTime=%lu --> syncPeriod=%d\n",
                   uiCycleTime, pCtrlReg_g->m_dwMinCycleTime, iSyncPeriod);

    if (iSyncPeriod > pCtrlReg_g->m_dwMaxCycleTime)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: Cycle time set by network to high for AP!\n");

        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
        wSyncIntCycle_g = 0;
        return;
    }
    if (iSyncPeriod < pCtrlReg_g->m_dwMinCycleTime)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: Cycle time set by network to low for AP!\n");

        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
        wSyncIntCycle_g = 0;
        return;
    }

    wSyncIntCycle_g = iNumCycles;
    pCtrlReg_g->m_dwSyncIntCycTime = iSyncPeriod;  ///< inform AP: write result in control register
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
