/*******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1                           
* All rights reserved. All use of this software and documentation is          
* subject to the License Agreement located at the end of this file below.     
*/

/**
********************************************************************************

\file       cnApiEvent.c

\brief      event handling of the PCP PDI (CN) API

\author     hoggerm

\date       29.04.2011

\since      29.04.2011
*******************************************************************************/
/* includes */
#include "cnApiEvent.h"
#include "cnApiIntern.h"

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
static void CnApi_getAsyncIRQEvent(void);
static void CnApi_processPcpEvent(tPcpPdiEventType wEventType_p, tPcpPdiEventArg wEventArg_p);

/******************************************************************************/
/* private functions */


/******************************************************************************/
/* functions */

/**
********************************************************************************
 \brief activates the PCP IRQ for event signaling
*******************************************************************************/
void CnApi_enableAsyncEventIRQ(void)
{
    pCtrlReg_g->m_wAsyncIrqControl |= (1 << ASYNC_IRQ_EN);
}

/**
********************************************************************************
 \brief disables the PCP IRQ for event signaling
*******************************************************************************/
void CnApi_disableAsyncEventIRQ(void)
{
    pCtrlReg_g->m_wAsyncIrqControl &= ~(1 << ASYNC_IRQ_EN);
}

/**
********************************************************************************
 \brief checks if asynchronous event occurred and simulates IRQ
*******************************************************************************/
void CnApi_pollAsyncEvent(void)
{
    /* check if IRQ-bit is set */
    WORD wCtrlRegField;

    wCtrlRegField = pCtrlReg_g->m_wAsyncIrqControl;

    if (wCtrlRegField & (1 << ASYNC_IRQ_PEND))
    {
        /* event is pending -> check it */
        CnApi_getAsyncIRQEvent();
    }
}

/**
********************************************************************************
 \brief checks which event has been signaled by AP,
        then forwards and acknowledges it
*******************************************************************************/
void CnApi_getAsyncIRQEvent(void)
{
    /* check if IRQ-bit is set */
    WORD wCtrlRegField;
    tPcpPdiEvent Event;

    wCtrlRegField = pCtrlReg_g->m_wEventAck;


    if (wCtrlRegField & (1 << EVT_PHY0_LINK))
    {
        /* PHY 0 link failed -> forward event */
        //TODO: create event queue -> for now: direct call

        Event.Typ_m = kPcpPdiEventGenericError;
        Event.Arg_m.GenErr_m = kPcpGenErrPhy0LinkLoss;

        CnApi_processPcpEvent(Event.Typ_m, Event.Arg_m);
    }

    if (wCtrlRegField & (1 << EVT_PHY1_LINK))
    {
        /* PHY 1 link failed -> forward event */
        //TODO: create event queue -> for now: direct call

        Event.Typ_m = kPcpPdiEventGenericError;
        Event.Arg_m.GenErr_m = kPcpGenErrPhy1LinkLoss;

        CnApi_processPcpEvent(Event.Typ_m, Event.Arg_m);
    }

    if (wCtrlRegField & (1 << EVT_GENERIC))
    {
        /* generic event -> forward event */
        //TODO: create event queue -> for now: direct call

        Event.Typ_m = pCtrlReg_g->m_wEventType;
        Event.Arg_m.wVal_m = pCtrlReg_g->m_wEventArg;

        CnApi_processPcpEvent(Event.Typ_m, Event.Arg_m);
    }

    /* if no event -> don't care and exit */


    /* acknowledge all signaled events;
     * this also resets an asserted IR signal */
    pCtrlReg_g->m_wEventAck = wCtrlRegField;
}

void CnApi_processPcpEvent(tPcpPdiEventType wEventType_p, tPcpPdiEventArg wEventArg_p)
{
    tPcpPdiEvent Event;
    tCnApiEvent  CnApiEvent;            ///< forwarded to application
    BOOL fInformApplication = FALSE;

    Event.Typ_m = wEventType_p;
    Event.Arg_m = wEventArg_p;

    switch (wEventType_p)
    {
        case kPcpPdiEventGeneric:
        {
            CnApiEvent.Typ_m = kCnApiEventPcp;
            CnApiEvent.Arg_m.PcpEventGen_m = Event.Arg_m.Gen_m;
            fInformApplication = TRUE;
            break;
        }
        case kPcpPdiEventGenericError:
        {
            CnApiEvent.Typ_m = kCnApiEventError;
            CnApiEvent.Arg_m.CnApiError_m.ErrTyp_m = kCnApiEventErrorFromPcp;
            CnApiEvent.Arg_m.CnApiError_m.ErrArg_m.PcpError_m.Typ_m = Event.Typ_m;
            CnApiEvent.Arg_m.CnApiError_m.ErrArg_m.PcpError_m.Arg_m = Event.Arg_m;
            fInformApplication = TRUE;

            switch (wEventArg_p.GenErr_m)
            {
                case kPcpGenErrInitFailed:
                case kPcpGenErrSyncCycleCalcError:
                {
                   //TODO: Stop further processing
                   //DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR: PCP Init failed!");
                   break;
                }
                case kPcpGenErrAsyncComTimeout:
                case kPcpGenErrAsyncIntChanComError:
                case kPcpGenErrPhy0LinkLoss:
                case kPcpGenErrPhy1LinkLoss:
                default:
                break;
            }
            break;
        }
        case kPcpPdiEventPcpStateChange:
        {
            /* get PCP state */
            Event.Arg_m.NewPcpState_m = CnApi_getPcpState();

            /* TODO: update AP state machine */
            // CnApi_processApStateMachine();
            // issue: there is no event buffer at PCP, if AP is to slow it will not recognize the change
            // -> don't update event state machine triggered for now, but in extra task.
            break;
        }
        case kPcpPdiEventCriticalStackError:
        case kPcpPdiEventStackWarning:
        case kPcpPdiEventHistoryEntry:
        {
            CnApiEvent.Typ_m = kCnApiEventError;
            CnApiEvent.Arg_m.CnApiError_m.ErrTyp_m = kCnApiEventErrorFromPcp;
            CnApiEvent.Arg_m.CnApiError_m.ErrArg_m.PcpError_m.Typ_m = Event.Typ_m;
            CnApiEvent.Arg_m.CnApiError_m.ErrArg_m.PcpError_m.Arg_m = Event.Arg_m;
            fInformApplication = TRUE;

            break;
        }
        default:
        break;
    }

    if (fInformApplication == TRUE)
    {    /* inform application */
        CnApi_AppCbEvent(CnApiEvent.Typ_m, CnApiEvent.Arg_m, NULL);
    }

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
