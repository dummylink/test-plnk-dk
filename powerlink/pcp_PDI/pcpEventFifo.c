/**
********************************************************************************
\file		pcpEventFifo.c

\brief		fifo for the event buffer

\author		mairt

\date		03.08.2011

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

*******************************************************************************/

#include "pcpEventFifo.h"

typ_fifo_buffer fifo[FIFO_SIZE];	//FIFO buffer
UCHAR read_pos, write_pos; // read and write pointer
UCHAR element_count;

/**
 ********************************************************************************
 \brief	inits the event fifo
 *******************************************************************************/
void pcp_EventFifoInit(void)
{
	read_pos = 0;
	write_pos = 0;
	element_count = 0;
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
	//printf("Fifo insert!\n");
	//element to process in fifo?
	if((write_pos != read_pos) || element_count == 0)
	{
		fifo[write_pos].m_wEventType = wEventType_p;
		fifo[write_pos].m_wEventArg = wArg_p;

		//modify write pointer
		write_pos = (write_pos + 1) % FIFO_SIZE;

		element_count++;

		//printf("%d %d %d\n",element_count,write_pos, read_pos);

		return EVENT_FIFO_INSERTED;
	} else //if((write_pos == read_pos) && (element_count != 0))
	{
		//printf("FIFO full!\n");
		return EVENT_FIFO_FULL;
	}


}

/**
 * \brief If the event memory is empty and fifo is not, write new event into memory!
 * \param the control register
 */
inline UCHAR pcp_EventFifoProcess(tPcpCtrlReg* volatile pCtrlReg_g)
{

	WORD wEventAck = pCtrlReg_g->m_wEventAck;


	//check event FIFO bit
	if (((wEventAck & (1 << EVT_GENERIC)) == 0) && (read_pos != write_pos))
	{
		//Post event from fifo into memory
        pCtrlReg_g->m_wEventType = fifo[read_pos].m_wEventType;
        pCtrlReg_g->m_wEventArg = fifo[read_pos].m_wEventArg;

        /* set GE bit to signal event to AP; If desired by AP,
         *  an IR signal will be asserted in addition */
        pCtrlReg_g->m_wEventAck = (1 << EVT_GENERIC);

        //modify read pointer
        read_pos = (read_pos + 1) % FIFO_SIZE;

        element_count--;

        //printf("%d %d %d\n",element_count,write_pos, read_pos);
        return EVENT_FIFO_POSTED;

	}

	return EVENT_FIFO_BUSY;
}

/**
 * \brief erases all elements inside the fifo
*/
void pcp_EventFifoFlush(void)
{
	read_pos = 0;
	write_pos = 0;
	element_count = 0;
}



