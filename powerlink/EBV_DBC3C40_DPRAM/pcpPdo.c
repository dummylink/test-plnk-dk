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
/* equals number of mapped objects, if memory-chaining is not applied */
#define		PDO_COPY_TBL_ELEMENTS		100

/******************************************************************************/
/* typedefs */
typedef struct sPdoCopyTblEntry {
    BYTE            *pAdrs_m;
    WORD            size_m;
} tPdoCopyTblEntry;

typedef struct sPdoCpyTbl {
   BYTE                 bNumOfEntries_m;
   tPdoCopyTblEntry     aEntry_m[PDO_COPY_TBL_ELEMENTS];
} tPdoCopyTbl;


/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
static tTPdoBuffer aTPdosPdi_l[TPDO_CHANNELS_MAX];
static tRPdoBuffer aRPdosPdi_l[RPDO_CHANNELS_MAX];

//TODO:DELETE tLinkPdosReq*		pTxDescBuf_g; //TODO: delete; currently used for LinkPdosReq in pcpMain.c
//TODO:DELETE static	tPdoDescHeader*		pRxDescBuf_l; //TODO: delete

static	tPdoCopyTbl			aTxPdoCopyTbl_l[TPDO_CHANNELS_MAX];
static	tPdoCopyTbl	        aRxPdoCopyTbl_l[RPDO_CHANNELS_MAX];

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

This function reads the control register information related to PDO PDI
and stores it into variables for this module. Also initial values are assigned.

\return OK (always)
*******************************************************************************/
int Gi_initPdo(void)
{
    register WORD wCnt;

    /** group TPDO PDI channels address, size and acknowledge settings */
#if (TPDO_CHANNELS_MAX >= 1)
    aTPdosPdi_l[0].pAdrs_m = (BYTE*) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wTxPdo0BufAoffs);
    aTPdosPdi_l[0].wSize_m = pCtrlReg_g->m_wTxPdo0BufSize;
    aTPdosPdi_l[0].pAck_m = (BYTE*) (&pCtrlReg_g->m_bTxPdo0Ack);
#endif /* TPDO_CHANNELS_MAX >= 1 */

    /** group RPDO PDI channels address, size and acknowledge settings */
#if (RPDO_CHANNELS_MAX >= 1)
    aRPdosPdi_l[0].pAdrs_m = (BYTE*) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wRxPdo0BufAoffs);
    aRPdosPdi_l[0].wSize_m = pCtrlReg_g->m_wRxPdo0BufSize;
    aRPdosPdi_l[0].pAck_m = (BYTE*) (&pCtrlReg_g->m_bRxPdo0Ack);
#endif /* RPDO_CHANNELS_MAX >= 1 */

#if (RPDO_CHANNELS_MAX >= 2)
    aRPdosPdi_l[1].pAdrs_m = (BYTE*) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wRxPdo1BufAoffs);
    aRPdosPdi_l[1].wSize_m = pCtrlReg_g->m_wRxPdo1BufSize;
    aRPdosPdi_l[1].pAck_m = (BYTE*) (&pCtrlReg_g->m_bRxPdo1Ack);
#endif /* RPDO_CHANNELS_MAX >= 2 */

#if (RPDO_CHANNELS_MAX >= 3)
    aRPdosPdi_l[2].pAdrs_m = (BYTE*) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wRxPdo2BufAoffs);
    aRPdosPdi_l[2].wSize_m = pCtrlReg_g->m_wRxPdo2BufSize;
    aRPdosPdi_l[2].pAck_m = (BYTE*) (&pCtrlReg_g->m_bRxPdo2Ack);
#endif /* RPDO_CHANNELS_MAX >= 3 */

for (wCnt = 0; wCnt < TPDO_CHANNELS_MAX; ++wCnt)
{
    if ((aTPdosPdi_l[wCnt].pAdrs_m == NULL) ||
        (aTPdosPdi_l[wCnt].wSize_m == 0)    ||
        (aTPdosPdi_l[wCnt].pAck_m ==  NULL)   )
    {
        DEBUG_TRACE2(DEBUG_LVL_09, "\nError in %s: initializing TPDO %d failed!\n", __func__, wCnt);
        goto exit;
    }
    else
    {
        DEBUG_TRACE4(DEBUG_LVL_11, "%s: TXPDO %d: adrs. %08x (size %d)\n",
                                            __func__, wCnt,(unsigned int)aTPdosPdi_l[wCnt].pAdrs_m, aTPdosPdi_l[wCnt].wSize_m);
    }
}
for (wCnt = 0; wCnt < RPDO_CHANNELS_MAX; ++wCnt)
{
    if ((aRPdosPdi_l[wCnt].pAdrs_m == NULL) ||
        (aRPdosPdi_l[wCnt].wSize_m == 0)    ||
        (aRPdosPdi_l[wCnt].pAck_m == NULL)   )
    {
        DEBUG_TRACE2(DEBUG_LVL_09, "\nError in %s: initializing RPDO %d failed!\n", __func__, wCnt);
        goto exit;
    }
    else
    {
        DEBUG_TRACE4(DEBUG_LVL_11, "%s: RXPDO %d: adrs. %08x (size %d)\n",
                                            __func__, wCnt, (unsigned int)aRPdosPdi_l[wCnt].pAdrs_m, aRPdosPdi_l[wCnt].wSize_m);
    }
}
    //TODO: this is direct link to buffer, change to local message buffer
    pAsycMsgLinkPdoReq_g = (tLinkPdosReq*) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wRxAsyncBufAoffs);

    /** initialize PDO PDI descriptor address */
//TODO:DELETE	pTxDescBuf_g = (BYTE*) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wTxPdoDescAdrs);	/* TXPDO descriptor address offset */
//TODO:DELETE	pRxDescBuf_l = (BYTE*) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wRxPdoDescAdrs);   /* RXPDO descriptor address offset */

#ifdef USE_THIS //TODO:DELETE
	pTxDescBuf_g->m_wPdoDescSize = 0;
	pTxDescBuf_g->m_wPdoDescVers = 0;/*Descriptor Buffer not in use TODO: delete completely*/
	pRxDescBuf_l->m_wPdoDescSize = 0;
	pRxDescBuf_l->m_wPdoDescVers = 0;
#endif /* USE_THIS */

	return OK;
exit:
    return ERROR;
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

This function reads all TPDOs to from PDI buffer. Therefore it uses a copy table
for each PDO.
*******************************************************************************/
void Gi_readPdo(void)
{
	BYTE				*pPdoPdiData;      ///< pointer to Pdo buffer
    tPdoCopyTblEntry    *pCopyTblEntry;    ///< pointer to table entry
    WORD                wEntryCnt;         ///< number of copy table entries
	register int		iCntin;            ///< inner loop counter
	register int        iCntout;           ///< outer loop counter

    /* copy all TPDOs to PDI buffer */
	for (iCntout = 0; iCntout < TPDO_CHANNELS_MAX; ++iCntout)
	{
	    pCopyTblEntry = &(aTxPdoCopyTbl_l[iCntout].aEntry_m[0]);
	    wEntryCnt = aTxPdoCopyTbl_l[iCntout].bNumOfEntries_m;
	    pPdoPdiData = aTPdosPdi_l[iCntout].pAdrs_m;

	    /* prepare PDO buffer for read access */
	    CnApi_ackPdoBuffer(aTPdosPdi_l[iCntout].pAck_m);

	    for (iCntin = 0; iCntin < wEntryCnt; iCntin++)
	    {
	        memcpy (pCopyTblEntry->pAdrs_m, pPdoPdiData, pCopyTblEntry->size_m);
	        pPdoPdiData += pCopyTblEntry->size_m;
	        pCopyTblEntry++;
	    }
	}
}

/**
********************************************************************************
\brief	write PDO data to DPRAM

This function writes all RPDOs to PDI buffer. Therefore it uses a copy table
for each PDO.
*******************************************************************************/
void Gi_writePdo(void)
{
    BYTE                *pPdoPdiData;      ///< pointer to Pdo buffer
    tPdoCopyTblEntry    *pCopyTblEntry;    ///< pointer to table entry
    WORD                wEntryCnt;         ///< number of copy table entries
    register int        iCntin;            ///< inner loop counter
    register int        iCntout;           ///< outer loop counter

    /* copy all RPDOs to PDI buffer */
    for (iCntout = 0; iCntout < RPDO_CHANNELS_MAX; ++iCntout)
    {
        pCopyTblEntry = &(aRxPdoCopyTbl_l[iCntout].aEntry_m[0]);
        wEntryCnt = aRxPdoCopyTbl_l[iCntout].bNumOfEntries_m;
        pPdoPdiData = aRPdosPdi_l[iCntout].pAdrs_m;

        for (iCntin = 0; iCntin < wEntryCnt; iCntin++)
        {
            memcpy (pPdoPdiData, pCopyTblEntry->pAdrs_m, pCopyTblEntry->size_m);
            pPdoPdiData += pCopyTblEntry->size_m;
            pCopyTblEntry++;
        }

        /* prepare PDO buffer for next write access */
        CnApi_ackPdoBuffer(aRPdosPdi_l[iCntout].pAck_m);
    }
}

/**
********************************************************************************
\brief	setup PDO descriptor

Gi_setupPdoDesc() reads the object mapping from the object dictionary and stores
the information in the PDO descriptor of the LinkPdoReq meassage so that the
AP could read it. The calling function needs to know the current payload offset
(starting with 0) in order to store subsequent descriptors of the same
LinkPdoReq meassage. Therefore the parameter pCurrentDescrOffset_p is used.

Additionally a copy table will be created for every PDO. This table is used
by the PCP for copying all objects contained in the mapping.

\param	bDirection_p		       direction of PDO transfer to setup the descriptor
\param  pCurrentDescrOffset_p      pointer to the current LinkPdoReq payload offset
\param  pLinkPdoReq_p              pointer to the LinkPdoReq message.

\return Ok, or ERROR if an error occured.
*******************************************************************************/
int Gi_setupPdoDesc(BYTE bDirection_p,  WORD *pCurrentDescrOffset_p, tLinkPdosReq *pLinkPdoReq_p)
{
	tEplKernel          Ret = kEplSuccessful;
	unsigned int        uiCommParamIndex;
	unsigned int        uiMappParamIndex;
	unsigned int		uiPdoChannelCount = 0;

	unsigned int		uiIndex;
	WORD		        wPdoDescSize;
	unsigned int		uiMapIndex;
	unsigned int		uiMapSubIndex;
	unsigned int		uiMapObj;
	unsigned int		uiCommObj;
	unsigned int		uiMaxPdoChannels;

	tEplObdSize         ObdSize;
	BYTE                bNodeId;
	QWORD               qwObjectMapping;
	BYTE                bMappSubindex;
	BYTE                bObdSubIdxCount = 0;
	BYTE                bAddedDecrEntries;          ///> added descriptor entry counter

	tPdoDescEntry	    *pPdoDescEntry;             ///< ptr to descriptor payload = object entries
	tPdoDescHeader		*pPdoDescHeader = NULL;     ///< ptr to descriptor header
	tPdoDir              PdoDir;
	BYTE                 bApiBufferNum = 0;
	tPdoCopyTbl			*pCopyTbl = NULL;
	tPdoCopyTblEntry     *pCopyTblEntry;

	/* initialize variables according to PDO direction */
	if (bDirection_p == kCnApiDirReceive)
	{
	    PdoDir = RPdo;
		pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pLinkPdoReq_p + sizeof(tLinkPdosReq) + *pCurrentDescrOffset_p);       // ptr to first descriptor sink address
		uiCommObj = EPL_PDOU_OBD_IDX_RX_COMM_PARAM;       // 1400 start (node ID object)
		uiMapObj = EPL_PDOU_OBD_IDX_RX_MAPP_PARAM;        // 1600 start (object + size)
		pCopyTbl = &aRxPdoCopyTbl_l[0];                   // ptr CopyTable sink address
		uiMaxPdoChannels = RPDO_CHANNELS_MAX;             // Max RPDOs
	}
	else if(bDirection_p == kCnApiDirTransmit)
	{
	    PdoDir = TPdo;
	    pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pLinkPdoReq_p + sizeof(tLinkPdosReq) + *pCurrentDescrOffset_p);       // ptr to first descriptor sink address
		uiCommObj = EPL_PDOU_OBD_IDX_TX_COMM_PARAM;
		uiMapObj = EPL_PDOU_OBD_IDX_TX_MAPP_PARAM;
		pCopyTbl = &aTxPdoCopyTbl_l[0];
		uiMaxPdoChannels = TPDO_CHANNELS_MAX;
	}
	else
	{
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Direction not specified!\n");
        goto exit;
    }

	/* count PDO channels according to assigned NodeIDs */
	for (uiCommParamIndex = uiCommObj; uiCommParamIndex < uiCommObj + uiMaxPdoChannels; uiCommParamIndex++)
	{
		ObdSize = sizeof (bNodeId);
		// read node ID from OD
		Ret = EplObduReadEntry(uiCommParamIndex, 0x01, &bNodeId, &ObdSize); ///< read 14XX or 18XX
		if ((Ret == kEplObdIndexNotExist)
			|| (Ret == kEplObdSubindexNotExist)
			|| (Ret == kEplObdIllegalPart))
		{   // PDO does not exist
			continue;
		}
		else if (Ret != kEplSuccessful)
		{   // other fatal error occured
			goto exit;
		}
		uiPdoChannelCount++;  ///< increment PDO counter for every assigned Node ID
	}

	/* setup descriptors and copy tables of all existing PDO channels for the specified direction */
	for (uiIndex = 0; uiIndex < uiPdoChannelCount; uiIndex++)
	{
		uiMappParamIndex = uiMapObj + uiIndex;

        /* prepare PDO descriptor for this PDO channel */
		pPdoDescHeader->m_bPdoDir = (BYTE) PdoDir;
		pPdoDescHeader->m_bBufferNum = bApiBufferNum;
        pPdoDescEntry =  (tPdoDescEntry*) ((BYTE*) pPdoDescHeader + sizeof(tPdoDescHeader)); ///< ptr to first entry
        wPdoDescSize = 0;
        bAddedDecrEntries = 0;

        /* prepare copy table for this PDO channel */
        pCopyTblEntry = &(pCopyTbl->aEntry_m[0]);
        pCopyTbl->bNumOfEntries_m = 0;

		/* read number of mapped objects of 18XX or 1AXX */
        ObdSize = sizeof (bObdSubIdxCount);
		Ret = EplObduReadEntry(uiMappParamIndex, 0x00, &bObdSubIdxCount, &ObdSize);
		if (Ret != kEplSuccessful)
		{
		    DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "OBD could not be read!\n");
			goto exit;
		}

        if (PDO_COPY_TBL_ELEMENTS < bObdSubIdxCount)
        {
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Objects do not fit in copy table!\n");
            goto exit;
        }

		/* setup descriptor and copy table of this PDO channel */
		for (bMappSubindex = 1; bMappSubindex <= bObdSubIdxCount; bMappSubindex++)
		{

		    /* check object mapping by reading the sub-indices */
			ObdSize = sizeof (qwObjectMapping); 		// QWORD
			Ret = EplObduReadEntry(uiMappParamIndex, bMappSubindex, &qwObjectMapping, &ObdSize);
			if (Ret != kEplSuccessful)
			{   // other fatal error occured
				goto exit;
			}

			DecodeObjectMapping(qwObjectMapping, &uiMapIndex, &uiMapSubIndex);

			/* add object to PDO descriptor */
	        if(uiMapIndex == 0x0000)
	        {
	                DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Index 0x0000 invalid. Skipped!\n");
	        }
			else
			{
	             /* add object to copy table */
			    if (EplObdGetDataSize(uiMapIndex, uiMapSubIndex) == 0) // size is 0
			    {
	                DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Size 0 invalid. Skipped!\n");
			    }
			    else
			    {
			        pCopyTblEntry->pAdrs_m = EplObdGetObjectDataPtr(uiMapIndex, uiMapSubIndex);  ///< linked address
                    pCopyTblEntry->size_m = EplObdGetDataSize(uiMapIndex, uiMapSubIndex);        ///< linked size

                    pPdoDescEntry->m_wPdoIndex = uiMapIndex;               ///< write descriptor entry
                    pPdoDescEntry->m_bPdoSubIndex = uiMapSubIndex;         ///< write descriptor entry


                    DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "%04x/%02x size %d\n", uiMapIndex, (BYTE)uiMapSubIndex, pCopyTblEntry->size_m); //TODO: delete

                    pCopyTblEntry++;                ///< prepare ptr for next element
	                pCopyTbl->bNumOfEntries_m++;    ///< increment entry counter
	                pPdoDescEntry++;                ///< prepare for next PDO descriptor entry
	                bAddedDecrEntries++;            ///< count actually added entries
			    }
			}

		}
		pPdoDescHeader->m_bEntryCnt = bAddedDecrEntries;      ///< number of entries of this PDO descriptor
		pLinkPdoReq_p->m_bDescrCnt++;                         ///< update descriptor counter of LinkPdoReq message

        DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "setup PDO desc: DIR:%d BufferNum:%d numObjs:%d\n", bDirection_p, pPdoDescHeader->m_bBufferNum, pPdoDescHeader->m_bEntryCnt);

		/* prepare for next PDO */
		wPdoDescSize = sizeof(tPdoDescHeader) + (bAddedDecrEntries * sizeof(tPdoDescEntry));
		pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) (pPdoDescHeader) + wPdoDescSize); ///< increment PDO descriptor count of Link PDO Request
		*pCurrentDescrOffset_p += wPdoDescSize;
		bApiBufferNum++;   ///< increment DPRAM PDO buffer number of this direction
		pCopyTbl++;        ///< choose copy table of next PDO
	}

	return OK;

exit:
	DEBUG_TRACE0 (DEBUG_LVL_CNAPI_ERR, "Error setup PDO descriptor!\n");
	pPdoDescHeader->m_bEntryCnt = 0;
	pCopyTbl->bNumOfEntries_m = 0;

	return ERROR;
}

/* END-OF-FILE */
/******************************************************************************/

