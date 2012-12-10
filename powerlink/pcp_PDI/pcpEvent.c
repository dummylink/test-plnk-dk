/*******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       pcpEvent.c

\brief      Module for posting events to fifo buffer and PDI

\author     mairt

\date       03.08.2011

\since      03.08.2011

This module buffers events posted by Gi_pcpEventPost() in case they are not
received i.e. acknowledged by the receiver in time. If the fifo buffer gets full,
the last event stored will be the event kPcpPdiEventGenericError with argument
kPcpGenErrEventBuffOverflow. This way the receiver recognizes an buffer overflow.
If an event needs to be buffered, it need to be signaled to the PDI later.
There for the fifo buffer needs to be processed as often as desired by calling
Gi_pcpEventFifoProcess().

*******************************************************************************/
/* includes */
#include "pcpEvent.h"

#include "pcp.h"

#include "EplInc.h"    ///< for ami functions

/******************************************************************************/
/* defines */
#define FIFO_SIZE   16
#define FIFO_EMPTY  0

/******************************************************************************/
/* typedefs */
typedef enum ePcpEventFifoStatus {
    kPcpEventFifoEmpty     = 0x00,
    kPcpEventFifoFull      = 0x01,
    kPcpEventFifoInserted  = 0x02,
} tPcpEventFifoStatus;

typedef enum eFifoInsert {
    kPcpEventFifoPosted    = 0x00,
    kPcpEventFifoBusy      = 0x01,
} tPcpEventFifoInsert;

typedef struct sFifoBuffer {
    WORD       wEventType_m;          ///< type of event (e.g. state change, error, ...)
    WORD       wEventArg_m;           ///< event argument, if applicable (e.g. error code, state, ...)
    WORD       wEventAck_m;           ///< acknowledge for events and asynchronous IR signal
} tFifoBuffer;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
static tFifoBuffer aFifo_l[FIFO_SIZE];  ///< FIFO buffer
static BYTE bReadPos_l = 0;            ///< event FIFO read position
static BYTE bWritePos_l = 0;           ///< event FIFO write position
static BYTE bElementCount_l = 0;

/******************************************************************************/
/* function declarations */
static tPcpEventFifoStatus pcp_EventFifoInsert(WORD wEventType_p, WORD wArg_p);
static tPcpEventFifoInsert pcp_EventFifoProcess(void);
static void pcp_EventFifoFlush(void);

/******************************************************************************/
/* private functions */

/**
 ********************************************************************************
 \brief insert new event into the fifo
 \param wEventType_p    event type (e.g. state change, error, ...)
 \param wArg_p          event argument (e.g. NmtState, error code ...)

 \return tPcpEventFifoStatus
 \retval kPcpEventFifoInserted   element posted to the FIFO
 \retval kPcpEventFifoFull       Event FIFO is full

 This function inserts a new event into the FIFO and returns kPcpEventFifoFull or
 FIFO_EMPTY if the state of the FIFO is like that. If it is possible to post an
 event kPcpEventFifoInserted is returned.
 *******************************************************************************/
static tPcpEventFifoStatus pcp_EventFifoInsert(WORD wEventType_p, WORD wArg_p)
{

    ///element to process in fifo?
    if((bWritePos_l != bReadPos_l) || bElementCount_l == FIFO_EMPTY)
    {
        aFifo_l[bWritePos_l].wEventType_m = wEventType_p;
        aFifo_l[bWritePos_l].wEventArg_m = wArg_p;

        ///modify write pointer
        bWritePos_l = (bWritePos_l + 1) % FIFO_SIZE;

        bElementCount_l++;

        return kPcpEventFifoInserted;
    } else
        return kPcpEventFifoFull;
}

/**
 ********************************************************************************
 \brief If the event memory is empty and FIFO is not, write new event into memory!

Call this function in the continuous loop in order to process pending events.

 \return tPcpEventFifoInsert
 \retval kPcpEventFifoPosted        Posted element to FIFO
 \retval kPcpEventFifoBusy          FIFO currently busy
 *******************************************************************************/
static tPcpEventFifoInsert pcp_EventFifoProcess(void)
{
    tPcpEventFifoInsert Ret = kPcpEventFifoBusy;

    WORD wEventAck = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wEventAck));


    ///check event FIFO bit
    if (((wEventAck & (1 << EVT_GENERIC)) == 0) && (bReadPos_l != bWritePos_l))
    {
        ///Post event from fifo into memory
        AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventType, aFifo_l[bReadPos_l].wEventType_m);
        AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventArg, aFifo_l[bReadPos_l].wEventArg_m);

        /* set GE bit to signal event to AP; If desired by AP,
         *  an IR signal will be asserted in addition */
        AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventAck, (1 << EVT_GENERIC));

        ///modify read pointer
        bReadPos_l = (bReadPos_l + 1) % FIFO_SIZE;

        bElementCount_l--;

        //printf("%d %d %d\n",element_count,write_pos, read_pos);
        Ret = kPcpEventFifoPosted;
    }

    return Ret;
}

/**
 ********************************************************************************
 \brief erases all elements inside the fifo
 *******************************************************************************/
static void pcp_EventFifoFlush(void)
{
    bReadPos_l = 0;
    bWritePos_l = 0;
    bElementCount_l = 0;
}

/******************************************************************************/
/* functions */

/**
 ********************************************************************************
 \brief inits the event fifo
 *******************************************************************************/
void Gi_pcpEventFifoInit(void)
{
    pcp_EventFifoFlush();
}

/**
 ********************************************************************************
 \brief set event and related argument in PCP control register to inform AP
 \param wEventType_p    event type (e.g. state change, error, ...)
 \param wArg_p          event argument (e.g. NmtState, error code ...)

 This function fills the event related PCP PDI register with an AP known value,
 and informs the AP this way about occurred events. The AP has to acknowledge
 an event after reading out the registers.
 According to the Asynchronous IRQ configuration register, the PCP might assert
 an IR signal in case of an event.
 *******************************************************************************/
void Gi_pcpEventPost(WORD wEventType_p, WORD wArg_p)
{
    WORD wEventAck;
    tPcpEventFifoStatus ucRet;

    wEventAck = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wEventAck));

    /* check if previous event has been confirmed by AP */
    if ((wEventAck & (1 << EVT_GENERIC)) == 0)
    { //confirmed -> set event
        AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventType, wEventType_p);
        AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventArg, wArg_p);

        /* set GE bit to signal event to AP; If desired by AP,
         *  an IR signal will be asserted in addition */
        AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventAck, (1 << EVT_GENERIC));

        // special treatment for reset event
        if ((wEventType_p == kPcpPdiEventGeneric)   &&
            (   (wArg_p == kPcpGenEventResetNodeRequest)
             || (wArg_p == kPcpGenEventResetCommunication)))
        {
            // PCP signals AP to reset
            while((AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wEventAck)) & (1 << EVT_GENERIC)) != 0)
            {
                // Wait until AP has acknowledged this event!
                asm("NOP;");
            }
        }
    }
    else // not confirmed -> do not overwrite
    {
        // special treatment for reset event
        if ((wEventType_p == kPcpPdiEventGeneric)   &&
            (   (wArg_p == kPcpGenEventResetNodeRequest)
             || (wArg_p == kPcpGenEventResetCommunication)))
        {
            // PCP signals AP to reset

            while((AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wEventAck)) & (1 << EVT_GENERIC)) != 0)
            {
                // Wait until AP has acknowledged the previous event!
                asm("NOP;");
            }

            // immediately set the reset event as next event
            AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventType, wEventType_p);
            AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventArg, wArg_p);

            /* set GE bit to signal event to AP; If desired by AP,
             *  an IR signal will be asserted in addition */
            AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventAck, (1 << EVT_GENERIC));

            while((AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wEventAck)) & (1 << EVT_GENERIC)) != 0)
            {
                // Wait until AP has acknowledged the reset event!
                asm("NOP;");
            }
        }

        // event posting to fifo buffer required
        if((ucRet = pcp_EventFifoInsert(wEventType_p, wArg_p)) == kPcpEventFifoFull)
        {
            // set the buffer overflow event into memory
            AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventType, kPcpPdiEventGenericError);
            AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventArg, kPcpGenErrEventBuffOverflow);

            AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventAck, (1 << EVT_GENERIC));

            pcp_EventFifoFlush();

            DEBUG_TRACE1(DEBUG_LVL_CNAPI_EVENT_INFO,"%s: AP too slow (FIFO overflow)!\n", __func__);
        }
        else if (ucRet == kPcpEventFifoInserted)
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_EVENT_INFO,"%s: Posted element into fifo!\n", __func__);
        }
    }
}

/**
********************************************************************************
\brief    post pending events to PDI
*******************************************************************************/
void Gi_processEvents(void)
{
    /* Check if previous event has been confirmed by AP */
    /* If not, try to post it */
    if(pcp_EventFifoProcess() == kPcpEventFifoPosted)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_EVENT_INFO,"%s: Posted event from fifo into PDI!\n", __func__);
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
