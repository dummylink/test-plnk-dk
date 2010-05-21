/**
********************************************************************************
\file		GenericIfPdo.c

\brief		PDO functions of generic interface

\author		Josef Baumgartner

\date		26.04.2010

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApi.h"
#include "cnApiIntern.h"
#include "pcp.h"

#include "EplInc.h"
#include "EplObd.h"
#include "user/EplObdu.h"

#include <string.h>

#include <altera_avalon_mutex.h>

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
static	char *				pTxPdoBuf;
static	char *				pRxPdoBuf;
static	tPdoDescHeader *	pTxDescBuf;
static	tPdoDescHeader *	pRxDescBuf;

static	tPdoCopyTbl			pTxPdoCopyTbl[PDO_COPY_TBL_SIZE];
static	WORD				wTxPdoCopyTblSize;
static	tPdoCopyTbl			pRxPdoCopyTbl[PDO_COPY_TBL_SIZE];
static	WORD				wRxPdoCopyTblSize;

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief	decode object mapping
*******************************************************************************/
static void DecodeObjectMapping(QWORD qwObjectMapping_p, unsigned int* puiIndex_p,
                                    unsigned int* puiSubIndex_p)
{
    *puiIndex_p = (unsigned int)
                    (qwObjectMapping_p & 0x000000000000FFFFLL);

    *puiSubIndex_p = (unsigned int)
                    ((qwObjectMapping_p & 0x0000000000FF0000LL) >> 16);
}

/**
********************************************************************************
\brief	initialize asynchronous functions
*******************************************************************************/
int Gi_initPdo(char *pTxPdoBuf_p, char *pRxPdoBuf_p, tPdoDescHeader *pTxDescBuf_p, tPdoDescHeader *pRxDescBuf_p)
{
	pRxPdoBuf = pRxPdoBuf_p;
	pTxPdoBuf = pTxPdoBuf_p;

	pRxDescBuf = pRxDescBuf_p;
	pTxDescBuf = pTxDescBuf_p;

	pRxDescBuf->m_wPdoDescSize = 0;
	pRxDescBuf->m_wPdoDescVers = 0;

	pTxDescBuf->m_wPdoDescSize = 0;
	pTxDescBuf->m_wPdoDescVers = 0;

	return 0;
}

/**
********************************************************************************
\brief	read PDO data from DPRAM
*******************************************************************************/
void Gi_readPdo(void)
{
	BYTE				*pPdoData;
	tPdoCopyTbl			*pCopyTbl;
	int					i;
	char				bReadIndex;

	if ((bReadIndex = CnApi_getPdoReadIndex()) < 0)
		return;

	pCopyTbl = pTxPdoCopyTbl;
	pPdoData = pTxPdoBuf + (pCtrlReg_g->m_wTxPdoBufSize * bReadIndex);

	for (i = 0; i < wTxPdoCopyTblSize; i++)
	{
		memcpy (pCopyTbl->m_adrs, pPdoData, pCopyTbl->m_size);
		pPdoData += pCopyTbl->m_size;
		pCopyTbl ++;
	}

	CnApi_releasePdoReadIndex();
}

/**
********************************************************************************
\brief	write PDO data to DPRAM
*******************************************************************************/
void Gi_writePdo(void)
{
	BYTE				*pPdoData;
	tPdoCopyTbl			*pCopyTbl;
	int					i;
	BYTE				bWriteIndex;

	bWriteIndex = CnApi_getPdoWriteIndex();

	pPdoData = pRxPdoBuf + (pCtrlReg_g->m_wRxPdoBufSize * bWriteIndex);
	pCopyTbl = pRxPdoCopyTbl;

	for (i = 0; i < wRxPdoCopyTblSize; i++)
	{
		memcpy (pPdoData, pCopyTbl->m_adrs, pCopyTbl->m_size);
		pPdoData += pCopyTbl->m_size;
		pCopyTbl ++;
	}

	CnApi_releasePdoWriteIndex();
}

/**
********************************************************************************
\brief	setup PDO descriptor
*******************************************************************************/
int Gi_setupPdoDesc(BYTE bDirection_p)
{
	tEplKernel          Ret = kEplSuccessful;
	unsigned int        uiCommParamIndex;
	unsigned int        uiMappParamIndex;
	unsigned int		uiRxPdoChannelCount;

	unsigned int		uiIndex;
	unsigned int		pdoDescSize;
	unsigned int		uiMapIndex;
	unsigned int		uiMapSubIndex;
	unsigned int		uiMapObj;
	unsigned int		uiCommObj;

	tEplObdSize         ObdSize;
	BYTE                bNodeId;
	QWORD               qwObjectMapping;
	BYTE                bMappSubindex;
	BYTE                bMappObjectCount;

	tPdoDesc			*pPdoDesc;
	tPdoDescHeader		*pPdoDescHeader;
	tPdoCopyTbl			*pCopyTbl;
	WORD				*pCopyTblSize;


	if (bDirection_p == kCnApiDirReceive)
	{
		pPdoDescHeader = pRxDescBuf;
		pPdoDesc = (tPdoDesc *)(pRxDescBuf + 1);
		uiCommObj = EPL_PDOU_OBD_IDX_RX_COMM_PARAM;
		uiMapObj = EPL_PDOU_OBD_IDX_RX_MAPP_PARAM;
		pCopyTbl = pRxPdoCopyTbl;
		pCopyTblSize = &wRxPdoCopyTblSize;
	}
	else
	{
		pPdoDescHeader = pTxDescBuf;
		pPdoDesc = (tPdoDesc *)(pTxDescBuf + 1);
		uiCommObj = EPL_PDOU_OBD_IDX_TX_COMM_PARAM;
		uiMapObj = EPL_PDOU_OBD_IDX_TX_MAPP_PARAM;
		pCopyTbl = pTxPdoCopyTbl;
		pCopyTblSize = &wTxPdoCopyTblSize;
	}

#define	MAX_PDO		10

	uiRxPdoChannelCount = 0;
	for (uiCommParamIndex = uiCommObj; uiCommParamIndex < uiCommObj + MAX_PDO; uiCommParamIndex++)
	{
		ObdSize = sizeof (bNodeId);
		// read node ID from OD
		Ret = EplObduReadEntry(uiCommParamIndex, 0x01, &bNodeId, &ObdSize);
		if ((Ret == kEplObdIndexNotExist)
			|| (Ret == kEplObdSubindexNotExist)
			|| (Ret == kEplObdIllegalPart))
		{   // PDO does not exist
			continue;
		}
		else if (Ret != kEplSuccessful)
		{   // other fatal error occured
			goto Exit;
		}
		uiRxPdoChannelCount++;
	}

	pdoDescSize = 0;
	*pCopyTblSize = 0;

	for (uiIndex = 0; uiIndex < uiRxPdoChannelCount; uiIndex++)
	{
		uiMappParamIndex = uiMapObj + uiIndex;

		ObdSize = sizeof (bMappObjectCount);
		// read mapping object count from OD
		Ret = EplObduReadEntry(uiMappParamIndex, 0x00, &bMappObjectCount, &ObdSize);
		if (Ret != kEplSuccessful)
		{
			goto Exit;
		}

		// check all objectmappings
		for (bMappSubindex = 1; bMappSubindex <= bMappObjectCount; bMappSubindex++)
		{
			// read object mapping from OD
			ObdSize = sizeof (qwObjectMapping); 		// QWORD
			Ret = EplObduReadEntry(uiMappParamIndex, bMappSubindex, &qwObjectMapping, &ObdSize);
			if (Ret != kEplSuccessful)
			{   // other fatal error occured
				goto Exit;
			}

			// decode object mapping
			DecodeObjectMapping(qwObjectMapping, &uiMapIndex, &uiMapSubIndex);

			pPdoDesc->m_wPdoIndex = uiMapIndex;
			pPdoDesc->m_bPdoSubIndex = (BYTE)uiMapSubIndex;

			pCopyTbl->m_adrs = EplObdGetObjectDataPtr(uiMapIndex, uiMapSubIndex);
			pCopyTbl->m_size = EplObdGetDataSize(uiMapIndex, uiMapSubIndex);
			pCopyTbl++;
			(*pCopyTblSize) ++;

			pPdoDesc++;
		}
		pdoDescSize += bMappObjectCount;
	}

	pPdoDescHeader->m_wPdoDescSize = pdoDescSize * sizeof(tPdoDesc);		/* store size of pdo descriptor */
	pPdoDescHeader->m_wPdoDescVers++;										/* increase descriptor version number */

	DEBUG_TRACE2 (DEBUG_LVL_CNAPI_INFO, "setup PDO desc: DIR:%d numObjs:%d\n", bDirection_p, pdoDescSize);
	return OK;

Exit:
	DEBUG_TRACE0 (DEBUG_LVL_CNAPI_ERR, "Error setup PDO descriptor!\n");
	pPdoDescHeader->m_wPdoDescSize = 0;
	pPdoDescHeader->m_wPdoDescVers = 0;
	*pCopyTblSize = 0;

	return ERROR;
}

/* END-OF-FILE */
/******************************************************************************/

