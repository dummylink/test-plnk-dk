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
#include "cnApiDebug.h"

#include <string.h>

#include <unistd.h>

/******************************************************************************/
/* defines */
#define		PDO_COPY_TBL_SIZE		100  //TODO: delete / replace define

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
static BYTE* 			pTxPdoAdrs_l;
static WORD 			wTxPdoSize_l;
static BYTE* 			pRxPdoAdrs_l;
static WORD 			wRxPdoSize_l;
static BYTE*			pRxPdoAckAdrsAp_l;
static BYTE*			pTxPdoAckAdrsAp_l;
static tPdoDescHeader*	pTxDescAdrs_l;
static WORD 			wTxDescSize_l;
static tPdoDescHeader*	pRxDescAdrs_l;
static WORD 			wRxDescSize_l;

static WORD				wRxPdoMappingVersion_l = 0xff;
static WORD				wTxPdoMappingVersion_l = 0xff;

static	tPdoCopyTbl		pTxPdoCopyTbl_l[PDO_COPY_TBL_SIZE];
static	WORD			wTxPdoCopyTblSize_l;
static	tPdoCopyTbl		pRxPdoCopyTbl_l[PDO_COPY_TBL_SIZE];
static	WORD			wRxPdoCopyTblSize_l;

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
		pCopyTbl = pRxPdoCopyTbl_l;
		pNumObjs = &wRxPdoCopyTblSize_l;
	}
	else
	{
		pCopyTbl = pTxPdoCopyTbl_l;
		pNumObjs = &wTxPdoCopyTblSize_l;
	}

	size = 0;
	pDesc = pPdoDesc_p;
	*pNumObjs = 0;
	while (size < wPdoDescSize_p)
	{
		/* if object line up matches then acquire data pointer and size information from the linking table */
		if (!CnApi_getObjectData(pDesc->m_wPdoIndex, pDesc->m_bPdoSubIndex, &wObjSize, &pObjAdrs))
		{
		    TRACE2("Couldn't find object 0x%04x/0x%02x in object table!\n", pDesc->m_wPdoIndex, pDesc->m_bPdoSubIndex);
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
void CnApi_initPdo(BYTE *pTxPdoAdrs_p, WORD wTxPdoSize_p,
				   BYTE *pRxPdoAdrs_p, WORD wRxPdoSize_p,
				   BYTE *pTxPdoAckAdrsAp_p, BYTE *pRxPdoAckAdrsAp_p,
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
	pTxPdoAdrs_l = pTxPdoAdrs_p;			/* TXPDO buffer address offset */
	wTxPdoSize_l = wTxPdoSize_p;
	pRxPdoAdrs_l = pRxPdoAdrs_p;			/* RXPDO buffer address offset */
	wRxPdoSize_l = wRxPdoSize_p;
	pTxPdoAckAdrsAp_l = pTxPdoAckAdrsAp_p; 	/* TXPDO buffer acknowledge address */
	pRxPdoAckAdrsAp_l = pRxPdoAckAdrsAp_p; 	/* RXPDO buffer acknowledge address */
	pTxDescAdrs_l = pTxDescAdrs_p;			/* TXPDO descriptor address offset */
	wTxDescSize_l = wTxDescSize_p;
	pRxDescAdrs_l = pRxDescAdrs_p;			/* RXPDO descriptor address offset */
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
	if (pRxDescAdrs_l->m_wPdoDescVers != wRxPdoMappingVersion_l)
	{
		wRxPdoMappingVersion_l = pRxDescAdrs_l->m_wPdoDescVers;		// save new mapping version

		CnApi_setupCopyTable(kCnApiDirReceive, (tPdoDesc *)(pRxDescAdrs_l + 1), pRxDescAdrs_l->m_wPdoDescSize);
	}

	/* check if mapping changed */
	if (pTxDescAdrs_l->m_wPdoDescVers != wTxPdoMappingVersion_l)
	{
		wTxPdoMappingVersion_l = pTxDescAdrs_l->m_wPdoDescVers;		// save new mapping version

		CnApi_setupCopyTable(kCnApiDirTransmit, (tPdoDesc *)(pTxDescAdrs_l + 1), pTxDescAdrs_l->m_wPdoDescSize);
	}
}

/**
********************************************************************************
\brief	write to DPRAM Buffer acknowledge register

CnApi_ackPdoBuffer() writes a random 32bit value
to a defined buffer control register.
*******************************************************************************/
inline void CnApi_ackPdoBuffer(BYTE* pAckReg_p)
{
    *pAckReg_p = 0xff; ///> write random byte value
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

	pPdoData = pRxPdoAdrs_l;
	pCopyTbl = pRxPdoCopyTbl_l;

	/* prepare PDO buffer for read access */
	CnApi_ackPdoBuffer(pRxPdoAckAdrsAp_l);

	for (i = 0; i < wRxPdoCopyTblSize_l; i++)
	{
		memcpy (pCopyTbl->m_adrs, pPdoData, pCopyTbl->m_size);
		pPdoData += pCopyTbl->m_size;
		pCopyTbl ++;
	}
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

	pPdoData = pTxPdoAdrs_l;
	pCopyTbl = pTxPdoCopyTbl_l;

	for (i = 0; i < wTxPdoCopyTblSize_l; i++)
	{
		memcpy (pPdoData, pCopyTbl->m_adrs, pCopyTbl->m_size);
		pPdoData += pCopyTbl->m_size;
		pCopyTbl ++;
	}

	/* prepare PDO buffer for next write access */
	CnApi_ackPdoBuffer(pTxPdoAckAdrsAp_l);
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

