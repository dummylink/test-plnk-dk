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
/* equals number of mapped objects, if memory-chaining is not applied */
#define		PDO_COPY_TBL_ELEMENTS		100  //TODO: delete / replace define

/******************************************************************************/
/* typedefs */
typedef struct sPdoCopyTblEntry {
    BYTE            *pAdrs_m;
    WORD             size_m;
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

static  WORD                wPdoMappingVersion_l = 0xff; ///< LinkPdosReq command mapping version
static  tPdoCopyTbl         aTxPdoCopyTbl_l[TPDO_CHANNELS_MAX];
static  tPdoCopyTbl         aRxPdoCopyTbl_l[RPDO_CHANNELS_MAX];

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/**
********************************************************************************
\brief	setup copy table

Setup the data copy table for TPDO or RPDO according to the descriptor.
The descriptor is compared with the local object link table.
Not stated objects in local table will be ignored.

\param  pPdoDesc_p          pointer to PDO descriptor
\param  wDescrEntries_p     Number of entries of the PDO descriptor
\param	bDirection_p		Copy direction (read/write) of this copy table
\param	wPdoBufNum_p	    PDO buffer number of one direction

*******************************************************************************/
static void CnApi_setupCopyTable (tPdoDescHeader        *pPdoDesc_p,
                                  WORD              wDescrEntries_p,
                                  BYTE              bDirection_p,
                                  WORD                 wPdoBufNum_p)
{
    int iCnt = 0;
	WORD   wTblNum = 0;
	tPdoDescEntry	*pDescEntry;
	tPdoCopyTbl   *pCopyTbl;
	BYTE    *pbCpyTblEntries;
	tPdoDir PdoDir;
	WORD	wObjSize;
	char	*pObjAdrs;

	PdoDir = (tPdoDir) bDirection_p;

    if(wDescrEntries_p > PDO_COPY_TBL_ELEMENTS)
    {
        DEBUG_TRACE3(DEBUG_LVL_ERROR, "Error in %s:"
                     "\nCopy table size of PDO Buffer %d too small"
                     " for count of descriptor elements (%d)!\n"
                     "Skipping copy table setup!\n", __func__, wPdoBufNum_p, wDescrEntries_p);
        goto exit;
    }


	/* select copy table */
	if (PdoDir == TPdo)
	{
		pCopyTbl = &aTxPdoCopyTbl_l[wPdoBufNum_p];
		pbCpyTblEntries = &aTxPdoCopyTbl_l[wPdoBufNum_p].bNumOfEntries_m;
	    DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Setup copy table for TPDO %d :\n", wPdoBufNum_p);
	}
	else if(PdoDir == RPdo)
	{
		pCopyTbl = &aRxPdoCopyTbl_l[wPdoBufNum_p];
		pbCpyTblEntries = &aRxPdoCopyTbl_l[wPdoBufNum_p].bNumOfEntries_m;
		DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Setup copy table for RPDO %d :\n", wPdoBufNum_p);
	}
	else
	{
	    DEBUG_TRACE1(DEBUG_LVL_ERROR, "\nError in %s:"
                     "\nDescriptor has no valid direction! Skipping copy table for this PDO.\n", __func__);
	    goto exit;
    }
    if(wDescrEntries_p == 0)
    {
        DEBUG_TRACE2(DEBUG_LVL_CNAPI_INFO, "%s INFO:"
                         "\nNo Objects mapped for PDO Buffer %d -> Skipping copy table setup.\n", __func__, wPdoBufNum_p);
         goto exit;
    }

	/* prepare loop */
	*pbCpyTblEntries = 0;
	pDescEntry = (tPdoDescEntry*) ((BYTE*) pPdoDesc_p + sizeof(tPdoDescHeader)); ///< first element

	/* check if indices exist locally and setup copy table */
	while(iCnt < wDescrEntries_p)
	{
		/* if object line up matches then acquire data pointer and size information from the linking table */
		if (!CnApi_setupMappedObjects(pDescEntry->m_wPdoIndex, pDescEntry->m_bPdoSubIndex, &wObjSize, &pObjAdrs))
		{
		    /* skip this copy table element */
		    DEBUG_TRACE2(DEBUG_LVL_ERROR,"Couldn't find descriptor object 0x%04x/0x%02x"
		            " in local object table!\n", pDescEntry->m_wPdoIndex,
                                                 pDescEntry->m_bPdoSubIndex);
			pCopyTbl->aEntry_m[wTblNum].pAdrs_m = 0;
			pCopyTbl->aEntry_m[wTblNum].size_m = 0;
		}
		else
		{   /* assing copy table element values */
		    pCopyTbl->aEntry_m[wTblNum].pAdrs_m = pObjAdrs;
		    pCopyTbl->aEntry_m[wTblNum].size_m = wObjSize;
		    wTblNum++;
		    (*pbCpyTblEntries)++;

	        DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO,"0x%04x/0x%02x"
	                    " size %d \n", pDescEntry->m_wPdoIndex, pDescEntry->m_bPdoSubIndex, wObjSize);
		}

		/* prepare next loop */
		pDescEntry++;
	    iCnt++;
	}
    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "OK\n");
    return;

exit:
    //*pbCpyTblEntries = 0;
	return;
}

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief	initialize pdo module

CnApi_initPdo() is used to initialize the PDO module.
*******************************************************************************/
int CnApi_initPdo(void)
{
    register WORD wCnt;

    /** group TPDO PDI channels address, size and acknowledge settings */
#if (TPDO_CHANNELS_MAX >= 1)
    aTPdosPdi_l[0].pAdrs_m = (BYTE*) (pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wTxPdo0BufAoffs);
    aTPdosPdi_l[0].wSize_m = pCtrlReg_g->m_wTxPdo0BufSize;
    aTPdosPdi_l[0].pAck_m = (BYTE*) (&pCtrlReg_g->m_bTxPdo0Ack);
#endif /* TPDO_CHANNELS_MAX >= 1 */

    /** group RPDO PDI channels address, size and acknowledge settings */
#if (RPDO_CHANNELS_MAX >= 1)
    aRPdosPdi_l[0].pAdrs_m = (BYTE*) (pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wRxPdo0BufAoffs);
    aRPdosPdi_l[0].wSize_m = pCtrlReg_g->m_wRxPdo0BufSize;
    aRPdosPdi_l[0].pAck_m = (BYTE*) (&pCtrlReg_g->m_bRxPdo0Ack);
#endif /* RPDO_CHANNELS_MAX >= 1 */

#if (RPDO_CHANNELS_MAX >= 2)
    aRPdosPdi_l[1].pAdrs_m = (BYTE*) (pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wRxPdo1BufAoffs);
    aRPdosPdi_l[1].wSize_m = pCtrlReg_g->m_wRxPdo1BufSize;
    aRPdosPdi_l[1].pAck_m = (BYTE*) (&pCtrlReg_g->m_bRxPdo1Ack);
#endif /* RPDO_CHANNELS_MAX >= 2 */

#if (RPDO_CHANNELS_MAX >= 3)
    aRPdosPdi_l[2].pAdrs_m = (BYTE*) (pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wRxPdo2BufAoffs);
    aRPdosPdi_l[2].wSize_m = pCtrlReg_g->m_wRxPdo2BufSize;
    aRPdosPdi_l[2].pAck_m = (BYTE*) (&pCtrlReg_g->m_bRxPdo2Ack);
#endif /* RPDO_CHANNELS_MAX >= 3 */

for (wCnt = 0; wCnt < TPDO_CHANNELS_MAX; ++wCnt)
{
    if ((aTPdosPdi_l[wCnt].pAdrs_m == NULL) ||
        (aTPdosPdi_l[wCnt].wSize_m == 0)    ||
        (aTPdosPdi_l[wCnt].pAck_m ==  NULL)   )
    {
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "\n\nError in %s: initializing TPDO %d failed!\n\n", __func__, wCnt);
        goto exit;
    }
    else
    {
        DEBUG_LVL_CNAPI_INFO_TRACE4("%s: TXPDO %d: adrs. %08x (size %d)\n",
                                            __func__, wCnt,(unsigned int)aTPdosPdi_l[wCnt].pAdrs_m, aTPdosPdi_l[wCnt].wSize_m);
    }
}
for (wCnt = 0; wCnt < RPDO_CHANNELS_MAX; ++wCnt)
{
    if ((aRPdosPdi_l[wCnt].pAdrs_m == NULL) ||
        (aRPdosPdi_l[wCnt].wSize_m == 0)    ||
        (aRPdosPdi_l[wCnt].pAck_m ==  NULL)   )
    {
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "\n\nError in %s: initializing RPDO %d failed!\n\n", __func__, wCnt);
        goto exit;
    }
    else
    {
        DEBUG_TRACE4(DEBUG_LVL_CNAPI_INFO, "%s: RXPDO %d: adrs. %08x (size %d)\n",
                     __func__, wCnt, (unsigned int)aRPdosPdi_l[wCnt].pAdrs_m,
                     aRPdosPdi_l[wCnt].wSize_m);
    }
}

//TODO: this is direct link to buffer, change to local message buffer
    pAsycMsgLinkPdoReqAp_g = (BYTE*) (pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wRxAsyncBufAoffs);

    return OK;
exit:
    return ERROR;
}

/**
********************************************************************************
\brief  handle an LinkPdosReq command from AP

This function allocates memory and links it to the DPRAM by the given
and set up response
*******************************************************************************/
void CnApi_handleLinkPdosReq(tLinkPdosReq *pLinkPdosReq_p) //TODO: move to Async
{
    register int    iCnt;
    WORD            wNumDescr;
    tPdoDescHeader  *pPdoDescHeader; ///< ptr to descriptor

    DEBUG_FUNC;

    /** check if LinkPdosReq command is present */
    //TODO

    /* check if mapping version has changed */
    if(pLinkPdosReq_p->m_bDescrVers == wPdoMappingVersion_l)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Descriptor Version %d still valid. \n", wPdoMappingVersion_l);
        goto exit;
    }
    else
    {
        wPdoMappingVersion_l = pLinkPdosReq_p->m_bDescrVers;
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "New Descriptor Version: %d\n", wPdoMappingVersion_l);
    }

    /* get numbers of descriptors in this message */
    wNumDescr = pLinkPdosReq_p->m_bDescrCnt;
    /* get pointer to  first descriptor */

    pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pLinkPdosReq_p + sizeof(tLinkPdosReq));

   /* read all descriptors and setup the corresponding copy tables */
    for (iCnt = 0; iCnt < wNumDescr; ++iCnt)
    {
        CnApi_readPdoDesc(pPdoDescHeader);

        /* get pointer to next descriptor */
        pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pPdoDescHeader + sizeof(tPdoDescHeader) +
                         (pPdoDescHeader->m_bEntryCnt * sizeof(tPdoDescEntry)));
    }

exit:
    return;
}

/**
********************************************************************************
\brief	read PDO descriptor

CnApi_readPdoDesc() checks if the mapping changed. If it changed the
PDO descriptor is read and the copy table is updated.


*******************************************************************************/
void CnApi_readPdoDesc(tPdoDescHeader *pPdoDescHeader_p)
{
    WORD wNumDescrEntries;
    WORD wPdoBufNum;
    tPdoDir bPdoDir;

    wNumDescrEntries = pPdoDescHeader_p->m_bEntryCnt;
    bPdoDir = pPdoDescHeader_p->m_bPdoDir;
    wPdoBufNum = pPdoDescHeader_p->m_bBufferNum;

    CnApi_setupCopyTable(pPdoDescHeader_p,
                         wNumDescrEntries,
                         bPdoDir,
                         wPdoBufNum);
}

/**
********************************************************************************
\brief	write to DPRAM Buffer acknowledge register

CnApi_ackPdoBuffer() writes a random 32bit value
to a defined buffer control register.
*******************************************************************************/
inline void CnApi_ackPdoBuffer(BYTE* pAckReg_p)
{
    //TODO: SPI
    *pAckReg_p = 0xff; ///> write random byte value
}

/**
********************************************************************************
\brief	receive PDO data

CnApi_receivePdo() receives PDO data from the PCP.
*******************************************************************************/
void CnApi_receivePdo(void)
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

        /* prepare PDO buffer for read access */
        CnApi_ackPdoBuffer(aRPdosPdi_l[iCntout].pAck_m);

        for (iCntin = 0; iCntin < wEntryCnt; iCntin++)
        { //TODO: SPI
            memcpy (pCopyTblEntry->pAdrs_m, pPdoPdiData, pCopyTblEntry->size_m);
            pPdoPdiData += pCopyTblEntry->size_m;
            pCopyTblEntry++;
        }
    }
}

/**
********************************************************************************
\brief	transmit PDO data

CnApi_transmitPdo() transmits PDO data to the PCP.
*******************************************************************************/
void CnApi_transmitPdo(void)
{
    BYTE                *pPdoPdiData;      ///< pointer to Pdo buffer
    tPdoCopyTblEntry    *pCopyTblEntry;    ///< pointer to table entry
    WORD                wEntryCnt;         ///< number of copy table entries
    register int        iCntin;            ///< inner loop counter
    register int        iCntout;           ///< outer loop counter

    /* copy all TPdos to PDI buffer */
    for (iCntout = 0; iCntout < TPDO_CHANNELS_MAX; ++iCntout)
    {
        pCopyTblEntry = &(aTxPdoCopyTbl_l[iCntout].aEntry_m[0]);
        wEntryCnt = aTxPdoCopyTbl_l[iCntout].bNumOfEntries_m;
        pPdoPdiData = aTPdosPdi_l[iCntout].pAdrs_m;

        for (iCntin = 0; iCntin < wEntryCnt; iCntin++)
        {
            //TODO: SPI
            memcpy (pPdoPdiData, pCopyTblEntry->pAdrs_m, pCopyTblEntry->size_m);
            pPdoPdiData += pCopyTblEntry->size_m;
            pCopyTblEntry++;
        }

        /* prepare PDO buffer for next write access */
        CnApi_ackPdoBuffer(aTPdosPdi_l[iCntout].pAck_m);
    }
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

