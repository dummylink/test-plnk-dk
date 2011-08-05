/**
********************************************************************************
\file		pcpEventFifo.h

\brief		fifo for the event buffer

\author		mairt

\date		03.08.2011

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

*******************************************************************************/

#ifndef PCPEVENTFIFO_H_
#define PCPEVENTFIFO_H_

/******************************************************************************/
/* includes */
#include "cnApiGlobal.h"
#include "cnApi.h"
#include "cnApiIntern.h"

/******************************************************************************/
/* defines */
#define FIFO_SIZE	16

#define EVENT_FIFO_EMPTY		0
#define EVENT_FIFO_FULL			1
#define EVENT_FIFO_INSERTED		2

#define EVENT_FIFO_POSTED		0
#define EVENT_FIFO_BUSY			1

typedef struct {
	WORD       m_wEventType;          ///< type of event (e.g. state change, error, ...)
	WORD       m_wEventArg;           ///< event argument, if applicable (e.g. error code, state, ...)
	WORD       m_wEventAck;           ///< acknowledge for events and asynchronous IR signal
}	typ_fifo_buffer;

void pcp_EventFifoInit(void);
UCHAR pcp_EventFifoInsert(WORD wEventType_p, WORD wArg_p);
inline UCHAR pcp_EventFifoProcess(tPcpCtrlReg* volatile pCtrlReg_g);
void pcp_EventFifoFlush(void);

#endif /* PCPEVENTFIFO_H_ */
/* END-OF-FILE */
/******************************************************************************/

