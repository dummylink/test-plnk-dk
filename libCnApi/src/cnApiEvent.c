/**
********************************************************************************
\file       cnApiEvent.c

\brief      Event handling of the PCP PDI (CN) API

This module contains functions for the asynchronous event handling in the CN API
library.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApiEvent.h"
#include "cnApiEventIntern.h"
#include "cnApiIntern.h"

#include "cnApiAsyncSm.h"


/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* local variables */
static void (*pfnAppCbEvent_l)(tCnApiEventType EventType_p,
        tCnApiEventArg * pEventArg_p, void * pUserArg_p) = NULL;

/******************************************************************************/
/* function declarations */
static tCnApiStatus CnApi_getAsyncIRQEvent(void);
static tCnApiStatus CnApi_processPcpEvent(tPcpPdiEventType wEventType_p,
        tPcpPdiEventArg wEventArg_p);


/******************************************************************************/
/* private functions */


/******************************************************************************/
/* functions */

/**
********************************************************************************
 \brief init the async event module

 \param pfnAppCbEvent_p        Callback in case of an event

 \return tCnApiStatus
 \retval kCnApiStatusOk                   on success
 \retval kCnApiStatusInvalidParameter     when the registration of the callback
                                          failed.
*******************************************************************************/
tCnApiStatus CnApi_initAsyncEvent(tCnApiAppCbEvent pfnAppCbEvent_p)
{
    tCnApiStatus Ret = kCnApiStatusOk;

    /* set application event callback */
    if (pfnAppCbEvent_p != NULL)
    {
        pfnAppCbEvent_l = pfnAppCbEvent_p;  //< make callback global
    } else {
        Ret = kCnApiStatusInvalidParameter;
    }

    return Ret;
}

/**
********************************************************************************
 \brief activates the PCP IRQ for event signaling

 Activate the asynchronous event interrupt. With this interrupt fast reaction
 on events is possible.
*******************************************************************************/
void CnApi_enableAsyncEventIRQ(void)
{
    WORD wAsyncIrqControl;

    wAsyncIrqControl = CnApi_getAsyncIrqControl();

    wAsyncIrqControl |= (1 << ASYNC_IRQ_EN);

    CnApi_setAsyncIrqControl(wAsyncIrqControl);
}

/**
********************************************************************************
 \brief disables the PCP IRQ for event signaling

Deactivate the asynchronous event interrupt. With this interrupt fast reaction
on events is possible.
*******************************************************************************/
void CnApi_disableAsyncEventIRQ(void)
{
    WORD wAsyncIrqControl;

    wAsyncIrqControl = CnApi_getAsyncIrqControl();

    wAsyncIrqControl &= ~(1 << ASYNC_IRQ_EN);

    CnApi_setAsyncIrqControl(wAsyncIrqControl);
}

/**
********************************************************************************
 \brief checks if asynchronous event occurred and simulates IRQ

 Check if an asynchronous event is pending. Needed when the events are polled
 and no interrupt is used.
*******************************************************************************/
void CnApi_checkAsyncEvent(void)
{
    tCnApiStatus Ret = kCnApiStatusOk;
    /* check if IRQ-bit is set */
    WORD wCtrlRegField;

    wCtrlRegField = CnApi_getAsyncIrqControl();

    if (wCtrlRegField & (1 << ASYNC_IRQ_PEND))
    {
        /* event is pending -> check it */
        Ret = CnApi_getAsyncIRQEvent();
        if(Ret != kCnApiStatusOk)
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "%s: Error while processing an async event!\n", __func__);
        }
    }
}

/**
********************************************************************************
 \brief Calls the event callback function which informs the user application

 \param EventType_p     type of CnApi event
 \param pEventArg_p     pointer to argument of CnApi event which matches the event type
 \param pUserArg_p      pointer to user argument

 \return                tCnApiStatus
 \retval                kCnApiStatusOk                  if successful
 \retval                kCnApiStatusInvalidParameter    when not initialized
*******************************************************************************/
tCnApiStatus CnApi_callEventCallback(tCnApiEventType EventType_p,
        tCnApiEventArg * pEventArg_p, void * pUserArg_p)
{
    tCnApiStatus Ret = kCnApiStatusOk;

    if(pfnAppCbEvent_l != NULL)
    {
        pfnAppCbEvent_l(EventType_p, pEventArg_p, pUserArg_p);
    } else {
        Ret = kCnApiStatusInvalidParameter;
    }

    return Ret;
}

/**
********************************************************************************
 \brief checks which event has been signaled by AP,
        then forwards and acknowledges it
*******************************************************************************/
static tCnApiStatus CnApi_getAsyncIRQEvent(void)
{
    tCnApiStatus Ret = kCnApiStatusOk;
    /* check if IRQ-bit is set */
    WORD wCtrlRegField;
    tPcpPdiEvent Event;

    wCtrlRegField = CnApi_getAsyncAckReg();

    if (wCtrlRegField & (1 << EVT_PHY0_LINK))
    {
        /* PHY 0 link failed -> forward event */
        //TODO: create event queue -> for now: direct call

        Event.Typ_m = kPcpPdiEventGenericError;
        Event.Arg_m.GenErr_m = kPcpGenErrPhy0LinkLoss;

        Ret = CnApi_processPcpEvent(Event.Typ_m, Event.Arg_m);
    }

    if (wCtrlRegField & (1 << EVT_PHY1_LINK))
    {
        /* PHY 1 link failed -> forward event */
        //TODO: create event queue -> for now: direct call

        Event.Typ_m = kPcpPdiEventGenericError;
        Event.Arg_m.GenErr_m = kPcpGenErrPhy1LinkLoss;

        Ret = CnApi_processPcpEvent(Event.Typ_m, Event.Arg_m);
    }

    if (wCtrlRegField & (1 << EVT_GENERIC))
    {
        /* generic event -> forward event */
        //TODO: create event queue -> for now: direct call

        Event.Typ_m = CnApi_getEventTyp();
        Event.Arg_m.wVal_m = CnApi_getEventArg();

        Ret = CnApi_processPcpEvent(Event.Typ_m, Event.Arg_m);
    }

    /* if no event -> don't care and exit */

    /* acknowledge all signaled events */
    CnApi_ackAsyncIRQEvent(wCtrlRegField);

    return Ret;
}

/**
 ********************************************************************************
 \brief processes an PCP event which was signaled in PDI
 \param wEventType_p    wEventType_p    type of PCP event
 \param wEventType_p    wEventArg_p     argument which matches event type

 This function processes PCP events. If an event is also intended also for the
 application, it will be forwarded.
 *******************************************************************************/
static tCnApiStatus CnApi_processPcpEvent(tPcpPdiEventType wEventType_p, tPcpPdiEventArg wEventArg_p)
{
    tCnApiStatus Ret = kCnApiStatusOk;
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

            switch (wEventArg_p.GenErr_m)
            {
                case kPcpGenEventResetCommunication:
                {
                    int iRet;

                    // reset asynchronous PCP <-> AP communication
                    iRet = CnApiAsync_reset();
                    if (iRet != OK )
                    {
                        DEBUG_TRACE0(DEBUG_LVL_ERROR, "CnApiAsync_reset() FAILED!\n");
                    }

                    break;
                }

                case kPcpGenEventResetCommunicationDone:
                {
                    CnApi_enableAsyncSmProcessing();
                    break;
                }

                case kPcpGenEventSyncCycleCalcSuccessful:
                case kPcpGenEventNodeIdConfigured:
                case kPcpGenEventResetNodeRequest:
                case kPcpGenEventUserTimer:
                default:
                break;
            }
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

            /* update AP state machine */
            //CnApi_processApStateMachine();
            // issue: there is no event buffer at PCP, if AP is to slow it will not recognize the change
            // -> additionally update state machine periodically in extra task for now.
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

    if (fInformApplication == TRUE )
    {    /* inform application */
        Ret = CnApi_callEventCallback(CnApiEvent.Typ_m,
                &CnApiEvent.Arg_m, NULL);
    }

    return Ret;

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
