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
#include <cnApiEvent.h>

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
static tCnApiStatus (*pfnAppCbEvent_l)(tCnApiEventType EventType_p,
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
 \brief checks if asynchronous event occurred and calls event callback

 Check if an asynchronous event is pending. When an event is pending it is
 processed and in case of a user event forwarded to the application.

*******************************************************************************/
void CnApi_processAsyncEvent(void)
{
    tCnApiStatus Ret = kCnApiStatusOk;
    WORD wCtrlRegField;

    /* check if IRQ-bit is set */
    wCtrlRegField = CnApi_getAsyncIrqControl();

    if (wCtrlRegField & (1 << ASYNC_IRQ_PEND))
    {
        /* event is pending -> check it */
        Ret = CnApi_getAsyncIRQEvent();
        if(Ret != kCnApiStatusOk)
        {
            //TODO: Implement proper error handling here! Set action on error! (reboot?)
            DEBUG_TRACE2(DEBUG_LVL_CNAPI_ERR, "%s: Error while processing an async "
                    "event! Errorcode: 0x%x\n", __func__, Ret);
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
        Ret = pfnAppCbEvent_l(EventType_p, pEventArg_p, pUserArg_p);
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

        Event.m_Typ = kPcpPdiEventGenericError;
        Event.m_Arg.m_GenErr = kPcpGenErrPhy0LinkLoss;

        Ret = CnApi_processPcpEvent(Event.m_Typ, Event.m_Arg);
    }

    if (wCtrlRegField & (1 << EVT_PHY1_LINK))
    {
        /* PHY 1 link failed -> forward event */
        //TODO: create event queue -> for now: direct call

        Event.m_Typ = kPcpPdiEventGenericError;
        Event.m_Arg.m_GenErr = kPcpGenErrPhy1LinkLoss;

        Ret = CnApi_processPcpEvent(Event.m_Typ, Event.m_Arg);
    }

    if (wCtrlRegField & (1 << EVT_GENERIC))
    {
        /* generic event -> forward event */
        //TODO: create event queue -> for now: direct call

        Event.m_Typ = CnApi_getEventTyp();
        Event.m_Arg.m_wVal = CnApi_getEventArg();

        Ret = CnApi_processPcpEvent(Event.m_Typ, Event.m_Arg);
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

    Event.m_Typ = wEventType_p;
    Event.m_Arg = wEventArg_p;

    switch (wEventType_p)
    {
        case kPcpPdiEventGeneric:
        {
            CnApiEvent.m_Typ = kCnApiEventPcp;
            CnApiEvent.m_Arg.m_PcpEventGen = Event.m_Arg.m_Gen;
            fInformApplication = TRUE;

            switch (wEventArg_p.m_GenErr)
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
            CnApiEvent.m_Typ = kCnApiEventError;
            CnApiEvent.m_Arg.m_CnApiError.m_ErrTyp = kCnApiEventErrorFromPcp;
            CnApiEvent.m_Arg.m_CnApiError.m_ErrArg.m_PcpError.m_Typ = Event.m_Typ;
            CnApiEvent.m_Arg.m_CnApiError.m_ErrArg.m_PcpError.m_Arg = Event.m_Arg;
            fInformApplication = TRUE;

            switch (wEventArg_p.m_GenErr)
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
            Event.m_Arg.m_NewPcpState = CnApi_getPcpState();

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
            CnApiEvent.m_Typ = kCnApiEventError;
            CnApiEvent.m_Arg.m_CnApiError.m_ErrTyp = kCnApiEventErrorFromPcp;
            CnApiEvent.m_Arg.m_CnApiError.m_ErrArg.m_PcpError.m_Typ = Event.m_Typ;
            CnApiEvent.m_Arg.m_CnApiError.m_ErrArg.m_PcpError.m_Arg = Event.m_Arg;
            fInformApplication = TRUE;

            break;
        }
        default:
        break;
    }

    if (fInformApplication == TRUE )
    {    /* inform application */
        Ret = CnApi_callEventCallback(CnApiEvent.m_Typ,
                &CnApiEvent.m_Arg, NULL);
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
