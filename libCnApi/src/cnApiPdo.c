/**
********************************************************************************
\file		cnApiPdo.c

\brief		CN API PDO functions

\author		Josef Baumgartner

\date		28.04.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApi.h"
#include "cnApiIntern.h"

#include <string.h>

#include <unistd.h>

/******************************************************************************/
/* defines */
#define		PDO_COPY_TBL_SIZE		100

/******************************************************************************/
/* typedefs */
typedef struct sPdoCopyTbl {
	BYTE			*m_adrs;
	unsigned int	m_size;
} tPdoCopyTbl;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
static char 			*pTxPdoAdrs_l;
static WORD 			wTxPdoSize_l;
static char 			*pRxPdoAdrs_l;
static WORD 			wRxPdoSize_l;
static tPdoDescHeader	*pTxDescAdrs_l;
static WORD 			wTxDescSize_l;
static tPdoDescHeader	*pRxDescAdrs_l;
static WORD 			wRxDescSize_l;

static WORD				wRxPdoMappingVersion = 0xff;
static WORD				wTxPdoMappingVersion = 0xff;

static	tPdoCopyTbl		pTxPdoCopyTbl[PDO_COPY_TBL_SIZE];
static	WORD			wTxPdoCopyTblSize;
static	tPdoCopyTbl		pRxPdoCopyTbl[PDO_COPY_TBL_SIZE];
static	WORD			wRxPdoCopyTblSize;

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/**
********************************************************************************
\brief	setup copy table

Setup the PDO data copy table.

\param	bDirection_p		Copy direction (read/write) of this copy table
\param	pPdoDesc_p			Pointer to the PDO descriptor
\param	wPdoDescSize_p		The size of the PDO descriptor
*******************************************************************************/
static void CnApi_setupCopyTable (BYTE bDirection_p, tPdoDesc *pPdoDesc_p, WORD wPdoDescSize_p)
{
	WORD		size;
	tPdoDesc	*pDesc;
	tPdoCopyTbl	*pCopyTbl;
	WORD		wObjSize;
	WORD		*pNumObjs;
	char		*pObjAdrs;

	if (bDirection_p == kCnApiDirReceive)
	{
		pCopyTbl = pRxPdoCopyTbl;
		pNumObjs = &wRxPdoCopyTblSize;
	}
	else
	{
		pCopyTbl = pTxPdoCopyTbl;
		pNumObjs = &wTxPdoCopyTblSize;
	}

	size = 0;
	pDesc = pPdoDesc_p;
	*pNumObjs = 0;
	while (size < wPdoDescSize_p)
	{
		if (!CnApi_getObjectData(pDesc->m_wPdoIndex, pDesc->m_bPdoSubIndex, &wObjSize, &pObjAdrs))
		{
			printf ("Couldn't find object 0x%04x/0x%02x in object table!\n", pDesc->m_wPdoIndex, pDesc->m_bPdoSubIndex);
			pCopyTbl->m_adrs = 0;
			pCopyTbl->m_size = 0;
		}
		else
		{
			pCopyTbl->m_adrs = pObjAdrs;
			pCopyTbl->m_size = wObjSize;
		}
		size += sizeof(tPdoDesc);
		pCopyTbl++;
		pDesc++;
		(*pNumObjs)++;
	}
}

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief	initialize pdo module

CnApi_initPdo() is used to initialize the PDO module.
*******************************************************************************/
void CnApi_initPdo(char *pTxPdoAdrs_p, WORD wTxPdoSize_p,
				   char *pRxPdoAdrs_p, WORD wRxPdoSize_p,
				   tPdoDescHeader *pTxDescAdrs_p, WORD wTxDescSize_p,
				   tPdoDescHeader *pRxDescAdrs_p, WORD wRxDescSize_p)
{
	DEBUG_TRACE2 (DEBUG_LVL_CNAPI_INFO, "CnApi_initPdo: TXPDO:%08x(%04x)\n",
			                            (unsigned int)pTxPdoAdrs_p, wTxPdoSize_p);
	DEBUG_TRACE2 (DEBUG_LVL_CNAPI_INFO, "CnApi_initPdo: RXPDO:%08x(%04x)\n",
			                            (unsigned int)pRxPdoAdrs_p, wRxPdoSize_p);
	DEBUG_TRACE2 (DEBUG_LVL_CNAPI_INFO, "CnApi_initPdo: TXDESC:%08x(%04x)\n",
			                            (unsigned int)pTxDescAdrs_p, wTxDescSize_p);
	DEBUG_TRACE2 (DEBUG_LVL_CNAPI_INFO, "CnApi_initPdo: RXDESC:%08x(%04x)\n",
			                            (unsigned int)pRxDescAdrs_p, wRxDescSize_p);

	/* initialize buffers */
	pTxPdoAdrs_l = pTxPdoAdrs_p;			/* TXPDO buffer */
	wTxPdoSize_l = wTxPdoSize_p;
	pRxPdoAdrs_l = pRxPdoAdrs_p;			/* RXPDO buffer */
	wRxPdoSize_l = wRxPdoSize_p;
	pTxDescAdrs_l = pTxDescAdrs_p;			/* TXPDO descriptor */
	wTxDescSize_l = wTxDescSize_p;
	pRxDescAdrs_l = pRxDescAdrs_p;			/* RXPDO descriptor */
	wRxDescSize_l = wRxDescSize_p;
}

/**
********************************************************************************
\brief	read PDO descriptor

CnApi_readPdoDesc() checks if the mapping changed. If it changed the
PDO descriptor is read and the copy table is updated.
*******************************************************************************/
void CnApi_readPdoDesc(void)
{
	/* check if mapping changed */
	if (pRxDescAdrs_l->m_wPdoDescVers != wRxPdoMappingVersion)
	{
		wRxPdoMappingVersion = pRxDescAdrs_l->m_wPdoDescVers;		// save new mapping version

		CnApi_setupCopyTable(kCnApiDirReceive, (tPdoDesc *)(pRxDescAdrs_l + 1), pRxDescAdrs_l->m_wPdoDescSize);
	}

	/* check if mapping changed */
	if (pTxDescAdrs_l->m_wPdoDescVers != wTxPdoMappingVersion)
	{
		wTxPdoMappingVersion = pTxDescAdrs_l->m_wPdoDescVers;		// save new mapping version

		CnApi_setupCopyTable(kCnApiDirTransmit, (tPdoDesc *)(pTxDescAdrs_l + 1), pTxDescAdrs_l->m_wPdoDescSize);
	}
}

/**
********************************************************************************
\brief	receive PDO data

CnApi_receivePdo() receives PDO data from the PCP.
*******************************************************************************/
void CnApi_receivePdo(void)
{
	BYTE			*pPdoData;
	tPdoCopyTbl		*pCopyTbl;
	register int 	i;
	char			bReadIndex;

	if ((bReadIndex = CnApi_getPdoReadIndex()) < 0)
	{
		return;		// no data, leave
	}

	pPdoData = pRxPdoAdrs_l + (wRxPdoSize_l * bReadIndex);
	pCopyTbl = pRxPdoCopyTbl;

	for (i = 0; i < wRxPdoCopyTblSize; i++)
	{
		memcpy (pCopyTbl->m_adrs, pPdoData, pCopyTbl->m_size);
		pPdoData += pCopyTbl->m_size;
		pCopyTbl ++;
	}

	CnApi_releasePdoReadIndex();
}

/**
********************************************************************************
\brief	transmit PDO data

CnApi_transmitPdo() transmits PDO data to the PCP.
*******************************************************************************/
void CnApi_transmitPdo(void)
{
	BYTE			*pPdoData;
	tPdoCopyTbl		*pCopyTbl;
	register int 	i;
	BYTE			bWriteIndex;

	/* check if buffer is ready for next data */
	bWriteIndex = CnApi_getPdoWriteIndex();

	pPdoData = pTxPdoAdrs_l + (wTxPdoSize_l * bWriteIndex);
	pCopyTbl = pTxPdoCopyTbl;

	for (i = 0; i < wTxPdoCopyTblSize; i++)
	{
		memcpy (pPdoData, pCopyTbl->m_adrs, pCopyTbl->m_size);
		pPdoData += pCopyTbl->m_size;
		pCopyTbl ++;
	}

	CnApi_releasePdoWriteIndex();
}

/**
********************************************************************************
\brief	transfer PDO data

CnApi_transferPdo() transfers PDO data. It receives RX data from the PCP and
sends TX data to the PCP.
*******************************************************************************/
void CnApi_transferPdo(void)
{
	CnApi_transmitPdo();
	CnApi_receivePdo();
}


/* END-OF-FILE */
/******************************************************************************/

