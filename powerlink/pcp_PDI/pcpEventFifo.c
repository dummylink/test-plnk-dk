/**
********************************************************************************
\file		pcpEventFifo.c

\brief		fifo for the event buffer

\author		mairt

\date		03.08.2011

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

*******************************************************************************/

#include "pcpEventFifo.h"

tFifoBuffer a_Fifo_g[FIFO_SIZE];  ///FIFO buffer
UCHAR ucReadPos_g, ucWritePos_g;  ///read and write pos
UCHAR ucElementCount_g;

/**
 ********************************************************************************
 \brief	inits the event fifo
 *******************************************************************************/
void pcp_EventFifoInit(void)
{
	ucReadPos_g = 0;
	ucWritePos_g = 0;
	ucElementCount_g = 0;
}

/**
 ********************************************************************************
 \brief	insert new event into the fifo
 \param	wEventType_p    event type (e.g. state change, error, ...)
 \param wArg_p          event argument (e.g. NmtState, error code ...)

 This function inserts a new event into the fifo and returns FIFO_FULL or
 FIFO_EMPTY if the state of the fifo is like that. If it is possible to proccess
 an event FIFO_PROCESS is returned
 *******************************************************************************/
UCHAR pcp_EventFifoInsert(WORD wEventType_p, WORD wArg_p)
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
 * \brief If the event memory is empty and fifo is not, write new event into memory!
 * \param the control register
 */
inline UCHAR pcp_EventFifoProcess(tPcpCtrlReg* volatile pCtrlReg_g)
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

        ///printf("%d %d %d\n",element_count,write_pos, read_pos);
        return kPcpEventFifoPosted;
	}

    return kPcpEventFifoBusy;
}

/**
 * \brief erases all elements inside the fifo
*/
void pcp_EventFifoFlush(void)
{
    ucReadPos_g = 0;
    ucWritePos_g = 0;
    ucElementCount_g = 0;
}
