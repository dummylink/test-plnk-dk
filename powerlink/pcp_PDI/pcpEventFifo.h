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

enum eFifoDelete {
    kPcpEventFifoEmpty = 0,
    kPcpEventFifoFull,
    kPcpEventFifoInserted
};

enum eFifoInsert {
    kPcpEventFifoPosted = 0,
    kPcpEventFifoBusy
};

typedef struct {
	WORD       wEventType_m;          ///< type of event (e.g. state change, error, ...)
	WORD       wEventArg_m;           ///< event argument, if applicable (e.g. error code, state, ...)
	WORD       wEventAck_m;           ///< acknowledge for events and asynchronous IR signal
}	tFifoBuffer;

void pcp_EventFifoInit(void);
UCHAR pcp_EventFifoInsert(WORD wEventType_p, WORD wArg_p);
inline UCHAR pcp_EventFifoProcess(tPcpCtrlReg* volatile pCtrlReg_g);
void pcp_EventFifoFlush(void);

#endif /* PCPEVENTFIFO_H_ */
/* END-OF-FILE */
/******************************************************************************/

