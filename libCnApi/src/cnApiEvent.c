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
#include "cnApiEventIntern.h"
#include "cnApiIntern.h"

#include "cnApiAsyncSm.h"

#ifdef CN_API_USING_SPI
  #include "cnApiPdiSpiIntern.h"
#endif //CN_API_USING_SPI

#include "EplAmi.h"


/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
void (*pfnAppCbEvent_g)(tCnApiEventType EventType_p,
        tCnApiEventArg * pEventArg_p, void * pUserArg_p) = NULL;

/******************************************************************************/
/* function declarations */
static void CnApi_ackAsyncIRQEvent(const WORD * pAckBits_p);
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
*******************************************************************************/
tCnApiStatus CnApi_initAsyncEvent(tCnApiAppCbEvent pfnAppCbEvent_p)
{
    tCnApiStatus Ret = kCnApiStatusOk;

    /* set application event callback */
    if (pfnAppCbEvent_p != NULL)
    {
        pfnAppCbEvent_g = pfnAppCbEvent_p;  ///< make callback global
    } else {
        Ret = kCnApiStatusInvalidParameter;
    }

    return Ret;
}

/**
********************************************************************************
 \brief activates the PCP IRQ for event signaling
*******************************************************************************/
void CnApi_enableAsyncEventIRQ(void)
{
    WORD wAsyncIrqControl;

#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_ASYNC_IRQ_CTRL_OFFSET,
                   sizeof(pCtrlReg_g->m_wAsyncIrqControl),
                   (BYTE*) &pCtrlReg_g->m_wAsyncIrqControl);
#endif /* CN_API_USING_SPI */

    wAsyncIrqControl = AmiGetWordFromLe((BYTE*)&pCtrlReg_g->m_wAsyncIrqControl);

    wAsyncIrqControl |= (1 << ASYNC_IRQ_EN);

    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wAsyncIrqControl, wAsyncIrqControl);

#ifdef CN_API_USING_SPI
    /* update PCP register */
    CnApi_Spi_write(PCP_CTRLREG_ASYNC_IRQ_CTRL_OFFSET,
                   sizeof(pCtrlReg_g->m_wAsyncIrqControl),
                   (BYTE*) &pCtrlReg_g->m_wAsyncIrqControl);
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
 \brief disables the PCP IRQ for event signaling
*******************************************************************************/
void CnApi_disableAsyncEventIRQ(void)
{
    WORD wAsyncIrqControl;

#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_ASYNC_IRQ_CTRL_OFFSET,
                   sizeof(pCtrlReg_g->m_wAsyncIrqControl),
                   (BYTE*) &pCtrlReg_g->m_wAsyncIrqControl);
#endif /* CN_API_USING_SPI */

    wAsyncIrqControl = AmiGetWordFromLe((BYTE*)&pCtrlReg_g->m_wAsyncIrqControl);

    wAsyncIrqControl &= ~(1 << ASYNC_IRQ_EN);

    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wAsyncIrqControl, wAsyncIrqControl);


#ifdef CN_API_USING_SPI
    /* update PCP register */
    CnApi_Spi_write(PCP_CTRLREG_ASYNC_IRQ_CTRL_OFFSET,
                   sizeof(pCtrlReg_g->m_wAsyncIrqControl),
                   (BYTE*) &pCtrlReg_g->m_wAsyncIrqControl);
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
 \brief acknowledges asynchronous events and IR signal
 \param pAckBits_p  pointer to 16 bit field, whereas a '1' indicates a
                    pending event which should be acknowledged
*******************************************************************************/
void CnApi_ackAsyncIRQEvent(const WORD * pAckBits_p)
{
    /* reset asserted IR signal and acknowledge events */
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventAck, *pAckBits_p);

#ifdef CN_API_USING_SPI
    /* update PCP register */
    CnApi_Spi_write(PCP_CTRLREG_EVENT_ACK_OFFSET,
                   sizeof(pCtrlReg_g->m_wEventAck),
                   (BYTE*) &pCtrlReg_g->m_wEventAck);
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
 \brief checks if asynchronous event occurred and simulates IRQ
*******************************************************************************/
void CnApi_checkAsyncEvent(void)
{
    tCnApiStatus Ret = kCnApiStatusOk;
    /* check if IRQ-bit is set */
    WORD wCtrlRegField;

#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_ASYNC_IRQ_CTRL_OFFSET,
                   sizeof(pCtrlReg_g->m_wAsyncIrqControl),
                   (BYTE*) &pCtrlReg_g->m_wAsyncIrqControl);
#endif /* CN_API_USING_SPI */

    wCtrlRegField = AmiGetWordFromLe((BYTE*)&pCtrlReg_g->m_wAsyncIrqControl);

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
 \brief checks which event has been signaled by AP,
        then forwards and acknowledges it
*******************************************************************************/
static tCnApiStatus CnApi_getAsyncIRQEvent(void)
{
    tCnApiStatus Ret = kCnApiStatusOk;
    /* check if IRQ-bit is set */
    WORD wCtrlRegField;
    tPcpPdiEvent Event;

#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_EVENT_ACK_OFFSET,
                   sizeof(pCtrlReg_g->m_wEventAck),
                   (BYTE*) &pCtrlReg_g->m_wEventAck);
#endif /* CN_API_USING_SPI */

    wCtrlRegField = AmiGetWordFromLe((BYTE*)&pCtrlReg_g->m_wEventAck);


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

#ifdef CN_API_USING_SPI
    /* update local PDI register copy */
    CnApi_Spi_read(PCP_CTRLREG_EVENT_TYPE_OFFSET,
                   sizeof(pCtrlReg_g->m_wEventType),
                   (BYTE*) &pCtrlReg_g->m_wEventType);
    CnApi_Spi_read(PCP_CTRLREG_EVENT_ARG_OFFSET,
                   sizeof(pCtrlReg_g->m_wEventArg),
                   (BYTE*) &pCtrlReg_g->m_wEventArg);
#endif /* CN_API_USING_SPI */

        Event.Typ_m = AmiGetWordFromLe((BYTE*)&pCtrlReg_g->m_wEventType);
        Event.Arg_m.wVal_m = AmiGetWordFromLe((BYTE*)&pCtrlReg_g->m_wEventArg);

        Ret = CnApi_processPcpEvent(Event.Typ_m, Event.Arg_m);
    }

    /* if no event -> don't care and exit */

    /* acknowledge all signaled events */
    CnApi_ackAsyncIRQEvent(&wCtrlRegField);

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
        if(pfnAppCbEvent_g != NULL)
        {
            pfnAppCbEvent_g(CnApiEvent.Typ_m, &CnApiEvent.Arg_m, NULL);
        } else {
            Ret = kCnApiStatusInvalidParameter;
            goto Exit;
        }
    }

Exit:
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
