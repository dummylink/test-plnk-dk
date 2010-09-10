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
static	BYTE*				pTxPdoBuf_l;
static	BYTE*				pRxPdoBuf_l;
static  BYTE*				pTxPdoAckAdrsPcp_l; //TODO: naming: no PCP!
static  BYTE*				pRxPdoAckAdrsPcp_l;

static	tPdoDescHeader*		pTxDescBuf_l;
static	tPdoDescHeader*		pRxDescBuf_l;

static	tPdoCopyTbl			pTxPdoCopyTbl_l[PDO_COPY_TBL_SIZE];
static	WORD				wTxPdoCopyTblSize_l;
static	tPdoCopyTbl			pRxPdoCopyTbl_l[PDO_COPY_TBL_SIZE];
static	WORD				wRxPdoCopyTblSize_l;

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
int Gi_initPdo(BYTE *pTxPdoBuf_p, BYTE *pRxPdoBuf_p,
		BYTE *pTxPdoAckAdrsPcp_p, BYTE *pRxPdoAckAdrsPcp_p,
		tPdoDescHeader *pTxDescBuf_p, tPdoDescHeader *pRxDescBuf_p)
{
	/* initialize buffers */
	pTxPdoBuf_l = pTxPdoBuf_p;			/* TXPDO buffer address offset */
	pRxPdoBuf_l = pRxPdoBuf_p;			/* RXPDO buffer address offset */

	pTxPdoAckAdrsPcp_l = pTxPdoAckAdrsPcp_p; /* TXPDO buffer acknowledge address offset */
	pRxPdoAckAdrsPcp_l = pRxPdoAckAdrsPcp_p; /* RXPDO buffer acknowledge address offset */

	pTxDescBuf_l = pTxDescBuf_p;			/* TXPDO descriptor address offset */
	pRxDescBuf_l = pRxDescBuf_p;			/* RXPDO descriptor address offset */

	pTxDescBuf_l->m_wPdoDescSize = 0;
	pTxDescBuf_l->m_wPdoDescVers = 0;
	pRxDescBuf_l->m_wPdoDescSize = 0;
	pRxDescBuf_l->m_wPdoDescVers = 0;

	return 0;
}

/**
********************************************************************************
\brief	write to DPRAM Buffer acknowledge register

CnApi_ackPdoBuffer() writes a random 32bit value
to a defined buffer control register.
*******************************************************************************/
inline void CnApi_ackPdoBuffer(BYTE* pAckReg_p)
{
    *pAckReg_p = 0xab; ///> write random byte value
}

/**
********************************************************************************
\brief	read PDO data from DPRAM
*******************************************************************************/
void Gi_readPdo(void)
{
	BYTE				*pPdoData;
	tPdoCopyTbl			*pCopyTbl;
	register int		i;

	pCopyTbl = pTxPdoCopyTbl_l;
	pPdoData = pTxPdoBuf_l;

	/* prepare PDO buffer for read access */
	CnApi_ackPdoBuffer(pTxPdoAckAdrsPcp_l);

	for (i = 0; i < wTxPdoCopyTblSize_l; i++)
	{
		memcpy (pCopyTbl->m_adrs, pPdoData, pCopyTbl->m_size);
		pPdoData += pCopyTbl->m_size;
		pCopyTbl ++;
	}
}

/**
********************************************************************************
\brief	write PDO data to DPRAM
*******************************************************************************/
void Gi_writePdo(void)
{
	BYTE				*pPdoData;
	tPdoCopyTbl			*pCopyTbl;
	register int		i;

	pPdoData = pRxPdoBuf_l;
	pCopyTbl = pRxPdoCopyTbl_l;

	for (i = 0; i < wRxPdoCopyTblSize_l; i++)
	{
		memcpy (pPdoData, pCopyTbl->m_adrs, pCopyTbl->m_size);
		pPdoData += pCopyTbl->m_size;
		pCopyTbl ++;
	}

	/* prepare PDO buffer for next write access */
	CnApi_ackPdoBuffer(pRxPdoAckAdrsPcp_l);
}

/**
********************************************************************************
\brief	setup PDO descriptor

Gi_setupPdoDesc() reads the object mapping from the object dictionary and stores
the information in the PDO descriptor buffer so that the AP could read it.

Additionally a copy table will be created. This table is used by the PCP for
copying all objects contained in the mapping.

\param	bDirection_p		direction of PDO transfer to setup the descriptor

\return Ok, or ERROR if an error occured.
*******************************************************************************/
int Gi_setupPdoDesc(BYTE bDirection_p)
{
	tEplKernel          Ret = kEplSuccessful;
	unsigned int        uiCommParamIndex;
	unsigned int        uiMappParamIndex;
	unsigned int		uiPdoChannelCount;

	unsigned int		uiIndex;
	unsigned int		pdoDescSize;
	unsigned int		uiMapIndex;
	unsigned int		uiMapSubIndex;
	unsigned int		uiMapObj;
	unsigned int		uiCommObj;
	unsigned int		uiMaxPdoChannels;

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
		pPdoDescHeader = pRxDescBuf_l;
		pPdoDesc = (tPdoDesc *)(pRxDescBuf_l + 1);
		uiCommObj = EPL_PDOU_OBD_IDX_RX_COMM_PARAM;
		uiMapObj = EPL_PDOU_OBD_IDX_RX_MAPP_PARAM;
		pCopyTbl = pRxPdoCopyTbl_l;
		pCopyTblSize = &wRxPdoCopyTblSize_l;
		uiMaxPdoChannels = RPDO_CHANNELS_MAX;
	}
	else
	{
		pPdoDescHeader = pTxDescBuf_l;
		pPdoDesc = (tPdoDesc *)(pTxDescBuf_l + 1);
		uiCommObj = EPL_PDOU_OBD_IDX_TX_COMM_PARAM;
		uiMapObj = EPL_PDOU_OBD_IDX_TX_MAPP_PARAM;
		pCopyTbl = pTxPdoCopyTbl_l;
		pCopyTblSize = &wTxPdoCopyTblSize_l;
		uiMaxPdoChannels = TPDO_CHANNELS_MAX;
	}


	uiPdoChannelCount = 0;
	for (uiCommParamIndex = uiCommObj; uiCommParamIndex < uiCommObj + uiMaxPdoChannels; uiCommParamIndex++)
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
		uiPdoChannelCount++;
	}

	pdoDescSize = 0;
	*pCopyTblSize = 0;

	for (uiIndex = 0; uiIndex < uiPdoChannelCount; uiIndex++)
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

