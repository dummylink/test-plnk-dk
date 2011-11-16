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
#include "cnApiEvent.h"

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
tFifoBuffer a_Fifo_g[FIFO_SIZE];  ///FIFO buffer
UCHAR ucReadPos_g, ucWritePos_g;  ///read and write pos
UCHAR ucElementCount_g;

/******************************************************************************/
/* function declarations */
static inline void pcp_EventFifoFlush(void);
static UCHAR pcp_EventFifoInsert(WORD wEventType_p, WORD wArg_p);

/******************************************************************************/
/* private functions */

/**
 ********************************************************************************
 \brief insert new event into the fifo
 \param wEventType_p    event type (e.g. state change, error, ...)
 \param wArg_p          event argument (e.g. NmtState, error code ...)

 This function inserts a new event into the fifo and returns FIFO_FULL or
 FIFO_EMPTY if the state of the fifo is like that. If it is possible to proccess
 an event FIFO_PROCESS is returned
 *******************************************************************************/
static UCHAR pcp_EventFifoInsert(WORD wEventType_p, WORD wArg_p)
{
    ///element to process in fifo?
    if((ucWritePos_g != ucReadPos_g) || ucElementCount_g == 0)
    {
        a_Fifo_g[ucWritePos_g].wEventType_m = wEventType_p;
        a_Fifo_g[ucWritePos_g].wEventArg_m = wArg_p;

        ///modify write pointer
        ucWritePos_g = (ucWritePos_g + 1) % FIFO_SIZE;

        ucElementCount_g++;

        return kPcpEventFifoInserted;
    } else
        return kPcpEventFifoFull;
}

/**
 ********************************************************************************
 \brief erases all elements inside the fifo
 *******************************************************************************/
static inline void pcp_EventFifoFlush(void)
{
    ucReadPos_g = 0;
    ucWritePos_g = 0;
    ucElementCount_g = 0;
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
    UCHAR ucRet;

    wEventAck = pCtrlReg_g->m_wEventAck;

    /* check if previous event has been confirmed by AP */
    if ((wEventAck & (1 << EVT_GENERIC)) == 0)
    { //confirmed -> set event

        pCtrlReg_g->m_wEventType = wEventType_p;
        pCtrlReg_g->m_wEventArg = wArg_p;

        /* set GE bit to signal event to AP; If desired by AP,
         *  an IR signal will be asserted in addition */
        pCtrlReg_g->m_wEventAck = (1 << EVT_GENERIC);

        // special treatment for reset event
        if ((wEventType_p == kPcpPdiEventGeneric)   &&
            (   (wArg_p == kPcpGenEventResetNodeRequest)
             || (wArg_p == kPcpGenEventResetCommunication)))
        {
            // PCP signals AP to reset
            while((pCtrlReg_g->m_wEventAck & (1 << EVT_GENERIC)) != 0)
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

            while((pCtrlReg_g->m_wEventAck & (1 << EVT_GENERIC)) != 0)
            {
                // Wait until AP has acknowledged the previous event!
                asm("NOP;");
            }

            // immediately set the reset event as next event
            pCtrlReg_g->m_wEventType = wEventType_p;
            pCtrlReg_g->m_wEventArg = wArg_p;

            /* set GE bit to signal event to AP; If desired by AP,
             *  an IR signal will be asserted in addition */
            pCtrlReg_g->m_wEventAck = (1 << EVT_GENERIC);

            while((pCtrlReg_g->m_wEventAck & (1 << EVT_GENERIC)) != 0)
            {
                // Wait until AP has acknowledged the reset event!
                asm("NOP;");
            }
        }

        // event posting to fifo buffer required
        if((ucRet = pcp_EventFifoInsert(wEventType_p, wArg_p)) == kPcpEventFifoFull)
        {
            // set the buffer overflow event into memory
            pCtrlReg_g->m_wEventType = kPcpPdiEventGenericError;
            pCtrlReg_g->m_wEventArg = kPcpGenErrEventBuffOverflow;

            pCtrlReg_g->m_wEventAck = (1 << EVT_GENERIC);

            pcp_EventFifoFlush();

            DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO,"%s: AP too slow (FIFO overflow)!\n", __func__);
        }
        else if (ucRet == kPcpEventFifoInserted)
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO,"%s: Posted element into fifo!\n", __func__);
        }
    }
}

/**
 ********************************************************************************
 \brief If the event memory is empty and fifo is not, write new event into memory!
 \param the control register
 *******************************************************************************/
inline UCHAR Gi_pcpEventFifoProcess(tPcpCtrlReg* volatile pCtrlReg_g)
{

    WORD wEventAck = pCtrlReg_g->m_wEventAck;


    ///check event FIFO bit
    if (((wEventAck & (1 << EVT_GENERIC)) == 0) && (ucReadPos_g != ucWritePos_g))
    {
        ///Post event from fifo into memory
        pCtrlReg_g->m_wEventType = a_Fifo_g[ucReadPos_g].wEventType_m;
        pCtrlReg_g->m_wEventArg = a_Fifo_g[ucReadPos_g].wEventArg_m;

        /* set GE bit to signal event to AP; If desired by AP,
         *  an IR signal will be asserted in addition */
        pCtrlReg_g->m_wEventAck = (1 << EVT_GENERIC);

        ///modify read pointer
        ucReadPos_g = (ucReadPos_g + 1) % FIFO_SIZE;

        ucElementCount_g--;

        //printf("%d %d %d\n",element_count,write_pos, read_pos);
        return kPcpEventFifoPosted;
    }

    return kPcpEventFifoBusy;
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
