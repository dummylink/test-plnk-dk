/*******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       pcpTime.c

\brief      Module for writing the Time information into the PDI

\author     mairt

\date       09.01.2012

\since      09.01.2012

This module sets the RelativeTime and Nettime fields inside the pdi if they are provided
by the powerlink master

*******************************************************************************/

#include "pcpTimeSync.h"
#include "kernel/EplTimerSynck.h"


/******************************************************************************/
/* typedefs */
typedef enum ePcpRelativeTimeState
{
    kPcpRelativeTimeStateInit = 0x00,                       ///< init state
    kPcpRelativeTimeStateWaitFirstValidRelativeTime = 0x01, ///< no valid RelativeTime received yet
    kPcpRelativeTimeStateActiv = 0x02,                      ///< RelativeTime is running
    kPcpRelativeTimeStateInvalid = 0x03,                    ///< invalid state

} tPcpRelativeTimeState;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
tPcpRelativeTimeState PcpRelativeTimeState_l = kPcpRelativeTimeStateInit;   ///< state variable of the RelativeTime state machine
QWORD qwRelativeTime_g = 0;        ///< local relative time counter

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief    inits the timesync field
*******************************************************************************/
void pcp_initTimeSync(void)
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
\brief    writes the current relativetime into the pdi
*******************************************************************************/
tEplKernel pcp_setRelativeTime(QWORD qwRelativeTime_p, BOOL fTimeValid_p )
{
    tEplKernel  EplRet = kEplSuccessful;
    DWORD wCycleTime = pCtrlReg_g->m_dwSyncIntCycTime;

    if(wCycleTime == 0)
    {
        EplRet = kEplInvalidParam;
        goto Exit;
    }

    switch(PcpRelativeTimeState_l)
    {
        case kPcpRelativeTimeStateInit:
        {
            if(fTimeValid_p == TRUE)
            {
                qwRelativeTime_g = qwRelativeTime_p;          ///< read the value once and activate relative time
                PcpRelativeTimeState_l = kPcpRelativeTimeStateActiv;
            } else {
                qwRelativeTime_g += wCycleTime;        ///< increment the relative time and enter the wait state
                PcpRelativeTimeState_l = kPcpRelativeTimeStateWaitFirstValidRelativeTime;
            }
           break;
        }
        case kPcpRelativeTimeStateWaitFirstValidRelativeTime:
        {
            if(fTimeValid_p == TRUE)
            {
                qwRelativeTime_g = qwRelativeTime_p;          ///< read the value once and activate relative time
                PcpRelativeTimeState_l = kPcpRelativeTimeStateActiv;
            } else {

                if(qwRelativeTime_g >= MAX_WAIT_TIME)
                {
                    /* timeout happened! Init relative time and activate the counter without a remote value */
                    qwRelativeTime_g = 0;
                    PcpRelativeTimeState_l = kPcpRelativeTimeStateActiv;
                } else {
                    /* increment local relative time and wait for an arriving time val from the soc */
                    qwRelativeTime_g += wCycleTime;
                }
            }


           break;
        }
        case kPcpRelativeTimeStateActiv:
        {
            qwRelativeTime_g += wCycleTime;
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
inline void pcp_setNetTime(DWORD dwNetTimeSeconds_p, DWORD dwNetTimeNanoSeconds_p)
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

#if POWERLINK_0_MAC_CMP_CMPTIMERCNT == 2
    // enable IRQ and set mode to "IR generation by HW"
    pCtrlReg_g->m_wSyncIrqControl = ((1 << SYNC_IRQ_ENABLE) | (1 << SYNC_IRQ_MODE));
    /* in addition also enable the hw interrupt in the EPL time sync module*/
    EplTimerSynckToggleIntEnable(wSyncIntCycle_p);
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

#if POWERLINK_0_MAC_CMP_CMPTIMERCNT == 2
    /* in addition also disable the hw interrupt in the EPL time sync module*/
    EplTimerSynckToggleIntDisable();
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
DWORD Gi_calcSyncIntPeriod(void)
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
        return 0;
    }

    if (pCtrlReg_g->m_dwMinCycleTime == 0 &&
        pCtrlReg_g->m_dwMaxCycleTime == 0 &&
        pCtrlReg_g->m_wMaxCycleNum == 0)
    {
        /* no need to trigger IR signal - polling mode is applied */
        return 0;
    }

    iNumCycles = (pCtrlReg_g->m_dwMinCycleTime + uiCycleTime - 1) / uiCycleTime;    /* do it this way to round up integer division! */
    iSyncPeriod = iNumCycles * uiCycleTime;

    DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "calcSyncIntPeriod: tCycle=%d tMinTime=%lu --> syncPeriod=%d\n",
                   uiCycleTime, pCtrlReg_g->m_dwMinCycleTime, iSyncPeriod);

    if (iNumCycles > pCtrlReg_g->m_wMaxCycleNum)
    {
        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
        return 0;
    }

    if (iSyncPeriod > pCtrlReg_g->m_dwMaxCycleTime)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: Cycle time set by network to high for AP!\n");

        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
        return 0;
    }
    if (iSyncPeriod < pCtrlReg_g->m_dwMinCycleTime)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: Cycle time set by network to low for AP!\n");

        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
        return 0;
    }

    pCtrlReg_g->m_dwSyncIntCycTime = iSyncPeriod;  ///< inform AP: write result in control register
    Gi_pcpEventPost(kPcpPdiEventGeneric, kPcpGenEventSyncCycleCalcSuccessful);

    return iNumCycles;
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
