/**
********************************************************************************
\file		CnApiPdoSync.c

\brief		CN API PDO synchronisation functions

\author		Josef Baumgartner

\date		07.05.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

The following module contains functions which control the PDO buffer
synchronisation.

The PDO buffer synchronisation is based on synchronisation registers which could
be locked. For each direction a read and a write index register is used to select
the currently used buffers.

If ALTERA_MUTEX_SYNC is defined the PDO buffer synchronisation locking is based
on the altera hardware mutex IP core.
*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApi.h"
#include "cnApiIntern.h"

#ifdef	ALTERA_MUTEX_SYNC
#include <altera_avalon_mutex.h>
#endif

/******************************************************************************/
/* defines */
#ifdef	ALTERA_MUTEX_SYNC
#define	DPRAM_MUTEX_DEV		"/dev/dpram_mutex"
#endif

/******************************************************************************/
/* global variables */
static tPdoSync 		*pPdoWriteSync_l;
static tPdoSync 		*pPdoReadSync_l;

#ifdef	ALTERA_MUTEX_SYNC
static BYTE				bufAllocTab_l[4][4] = { { 1, 2, 1, 1 },
											    { 2, 0, 3, 2 },
											    { 1, 3, 0, 1 },
											    { 1, 2, 1, 0 } };
static BYTE				bWriteIndex_l;
static alt_mutex_dev *	mutex_l;
#endif

#ifdef	DEBUG
DWORD 					adwWrBufUsed_g[3];
#endif

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief	initialize PDO synchronisation module

CnApi_initPdoSync() initializes the PDO synchronisation module.

\param	pPdoWriteSync_p			Pointer to the PDO Write synchronisation registers
\param	pPdoReadSync_p			Pointer to the PDO Read synchronisation registers

\return	OK if module was successfully initialized. ERROR if initialization failed.
*******************************************************************************/
int CnApi_initPdoSync(tPdoSync *pPdoWriteSync_p, tPdoSync *pPdoReadSync_p)
{
#ifdef	ALTERA_MUTEX_SYNC
	if ((mutex_l = altera_avalon_mutex_open(DPRAM_MUTEX_DEV)) == NULL)
	{
		DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Error geting DPRAM mutex!\n");
		return ERROR;
	}
#endif

	pPdoWriteSync_l = pPdoWriteSync_p;
	pPdoReadSync_l = pPdoReadSync_p;

	return OK;
}

/**
********************************************************************************
\brief	get buffer index for PDO write

CnApi_getPdoWriteIndex() is used to get the write buffer index for the next write.
The function searches a free write buffer and returns the index of this buffer.
The application can write to this buffer and must release it with CnApi_releasePdoWriteIndex()
when ready.

\retval	index		Index of the write buffer which can be used for the next write.
*******************************************************************************/
char CnApi_getPdoWriteIndex(void)
{
#ifdef	ALTERA_MUTEX_SYNC
	/* get mutex */
	altera_avalon_mutex_lock(mutex_l, 1);

	bWriteIndex_l =
	bufAllocTab_l[pPdoWriteSync_l->m_bPdoWriteIndex][pPdoWriteSync_l->m_bPdoReadIndex];

	/* release mutex */
	altera_avalon_mutex_unlock(mutex_l);

	return (bWriteIndex_l - 1);
#else
	// TODO implement depending on hardware implementation of triple buffer allocation
	return 0;
#endif
}

/**
********************************************************************************
\brief	release buffer index for PDO write

CnApi_releasePdoWriteIndex() releases the currently used write buffer and set
it valid so that it can be read by a consumer.
*******************************************************************************/
void CnApi_releasePdoWriteIndex(void)
{
#ifdef	ALTERA_MUTEX_SYNC
	/* get mutex */
	altera_avalon_mutex_lock(mutex_l, 1);

	pPdoWriteSync_l->m_bPdoWriteIndex = bWriteIndex_l;
#ifdef	DEBUG
	adwWrBufUsed_g[bWriteIndex_l - 1] ++;
#endif

	/* release mutex */
	altera_avalon_mutex_unlock(mutex_l);
#else
	// TODO implement depending on hardware implementation of triple buffer allocation
#endif
}

/**
********************************************************************************
\brief	get buffer index for PDO read

CnApi_getPdoReadIndex() searches for the last written buffer and returns its
index so that it can be read. Additionally the buffer will be locked until it
will be released by the reader by calling CnApi_rleasePdoReadIndex().

\retval	index		Index of the read buffer which could be read.
*******************************************************************************/
char CnApi_getPdoReadIndex(void)
{
#ifdef	ALTERA_MUTEX_SYNC
	/* get mutex */
	altera_avalon_mutex_lock(mutex_l, 1);

	pPdoReadSync_l->m_bPdoReadIndex = pPdoReadSync_l->m_bPdoWriteIndex;
	pPdoReadSync_l->m_bPdoWriteIndex = 0;

	/* release mutex */
	altera_avalon_mutex_unlock(mutex_l);

	return (pPdoReadSync_l->m_bPdoReadIndex - 1);
#else
	// TODO implement depending on hardware implementation of triple buffer allocation
	return 0;
#endif
}

/**
********************************************************************************
\brief	release buffer index for PDO read

CnApi_releasePdoReadIndex() releases the currently used read buffer so that it
can be written by the producer.
*******************************************************************************/
void CnApi_releasePdoReadIndex(void)
{
#ifdef	ALTERA_MUTEX_SYNC
	/* get mutex */
	altera_avalon_mutex_lock(mutex_l, 1);

	pPdoReadSync_l->m_bPdoReadIndex = 0;

	/* release mutex */
	altera_avalon_mutex_unlock(mutex_l);
#else
	// TODO implement depending on hardware implementation of triple buffer allocation
#endif
}

/* END-OF-FILE */
/******************************************************************************/

