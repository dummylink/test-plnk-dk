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
#include "cnApiPdiSpi.h"
#include "cnApiEvent.h"

#include <string.h>
#include <unistd.h>
#include <malloc.h>

/******************************************************************************/
/* defines */
/* equals number of mapped objects, if memory-chaining is not applied */
#define	PDO_COPY_TBL_ELEMENTS	MAX_MAPPABLE_OBJECTS  ///< max copy table elements per PDO

/******************************************************************************/
/* typedefs */
typedef struct sPdoCopyTblEntry {
    BYTE *  pAdrs_m;        ///< source or target pointer
    WORD    size_m;         ///< data size
    WORD    wPdoOfst;       ///< PDO buffer offset
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

static  WORD                wPdoMappingVersion_l = 0xfe; ///< LinkPdosReq command mapping version
static  WORD                wCntMappedNotLinkedObj_l;    ///< counter of mapped but not linked objects
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
\return FALSE if error occurred, else TRUE
*******************************************************************************/
static BOOL CnApi_setupCopyTable (tPdoDescHeader        *pPdoDesc_p,
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
	BOOL fRet = TRUE;

	PdoDir = (tPdoDir) bDirection_p;

    if(wDescrEntries_p > PDO_COPY_TBL_ELEMENTS)
    {
        DEBUG_TRACE3(DEBUG_LVL_ERROR, "Error in %s:"
                     "\nCopy table size of PDO Buffer %d too small"
                     " for count of descriptor elements (%d)!\n"
                     "Skipping copy table setup!\n", __func__, wPdoBufNum_p, wDescrEntries_p);
        fRet = FALSE;
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
        fRet = FALSE;
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
	    fRet = CnApi_getObjectParam(pDescEntry->m_wPdoIndex, pDescEntry->m_bPdoSubIndex, &wObjSize, &pObjAdrs);
		if (fRet == FALSE                ||
		    wObjSize != pDescEntry->m_wSize)
		{
		    /* skip this copy table element */
		    DEBUG_TRACE2(DEBUG_LVL_ERROR,"Couldn't find descriptor object 0x%04x/0x%02x"
		            " in local object table!\n", pDescEntry->m_wPdoIndex,
                                                 pDescEntry->m_bPdoSubIndex);
			pCopyTbl->aEntry_m[wTblNum].pAdrs_m = 0;
			pCopyTbl->aEntry_m[wTblNum].size_m = 0;
			wCntMappedNotLinkedObj_l++;
		}
		else
		{   /* assign copy table element values */
		    pCopyTbl->aEntry_m[wTblNum].pAdrs_m = pObjAdrs;
		    pCopyTbl->aEntry_m[wTblNum].size_m = pDescEntry->m_wSize;
		    pCopyTbl->aEntry_m[wTblNum].wPdoOfst = pDescEntry->m_wOffset;
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
    fRet = TRUE; // everything is fine if we reach this point

exit:
	return fRet;
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
    aTPdosPdi_l[0].pAck_m = (BYTE*) (&pCtrlReg_g->m_wTxPdo0Ack);
    #ifdef CN_API_USING_SPI
    aTPdosPdi_l[0].dwSpiBufOffs_m = PCP_CTRLREG_TPDO0_OFST_OFFSET;
    aTPdosPdi_l[0].wSpiAckOffs_m = PCP_CTRLREG_TPDO_0_ACK_OFFSET;
    #endif /* CN_API_USING_SPI */
#endif /* TPDO_CHANNELS_MAX >= 1 */

    /** group RPDO PDI channels address, size and acknowledge settings */
#if (RPDO_CHANNELS_MAX >= 1)
    aRPdosPdi_l[0].pAdrs_m = (BYTE*) (pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wRxPdo0BufAoffs);
    aRPdosPdi_l[0].wSize_m = pCtrlReg_g->m_wRxPdo0BufSize;
    aRPdosPdi_l[0].pAck_m = (BYTE*) (&pCtrlReg_g->m_wRxPdo0Ack);
    #ifdef CN_API_USING_SPI
    aRPdosPdi_l[0].dwSpiBufOffs_m = PCP_CTRLREG_RPDO0_OFST_OFFSET;
    aRPdosPdi_l[0].wSpiAckOffs_m = PCP_CTRLREG_RPDO_0_ACK_OFFSET;
    #endif /* CN_API_USING_SPI */
#endif /* RPDO_CHANNELS_MAX >= 1 */

#if (RPDO_CHANNELS_MAX >= 2)
    aRPdosPdi_l[1].pAdrs_m = (BYTE*) (pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wRxPdo1BufAoffs);
    aRPdosPdi_l[1].wSize_m = pCtrlReg_g->m_wRxPdo1BufSize;
    aRPdosPdi_l[1].pAck_m = (BYTE*) (&pCtrlReg_g->m_wRxPdo1Ack);
    #ifdef CN_API_USING_SPI
    aRPdosPdi_l[1].dwSpiBufOffs_m = PCP_CTRLREG_RPDO1_OFST_OFFSET;
    aRPdosPdi_l[1].wSpiAckOffs_m = PCP_CTRLREG_RPDO_1_ACK_OFFSET;
    #endif /* CN_API_USING_SPI */
#endif /* RPDO_CHANNELS_MAX >= 2 */

#if (RPDO_CHANNELS_MAX >= 3)
    aRPdosPdi_l[2].pAdrs_m = (BYTE*) (pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wRxPdo2BufAoffs);
    aRPdosPdi_l[2].wSize_m = pCtrlReg_g->m_wRxPdo2BufSize;
    aRPdosPdi_l[2].pAck_m = (BYTE*) (&pCtrlReg_g->m_wRxPdo2Ack);
    #ifdef CN_API_USING_SPI
    aRPdosPdi_l[2].dwSpiBufOffs_m = PCP_CTRLREG_RPDO2_OFST_OFFSET;
    aRPdosPdi_l[2].wSpiAckOffs_m = PCP_CTRLREG_RPDO_2_ACK_OFFSET;
    #endif /* CN_API_USING_SPI */
#endif /* RPDO_CHANNELS_MAX >= 3 */


for (wCnt = 0; wCnt < TPDO_CHANNELS_MAX; ++wCnt)
{
    if ((aTPdosPdi_l[wCnt].pAdrs_m == NULL) ||
        (aTPdosPdi_l[wCnt].wSize_m == 0)    ||
        (aTPdosPdi_l[wCnt].pAck_m ==  NULL)   )
    {
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "\nError in %s: initializing TPDO %d failed!\n\n", __func__, wCnt);
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

    return OK;
exit:
    return ERROR;
}

/**
********************************************************************************
\brief  handle an LinkPdosReq command from PCP
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value

This function sets up the mapping connection PCP PDI <-> local Objects
*******************************************************************************/
tPdiAsyncStatus CnApi_handleLinkPdosReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                        BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    register int        iCnt;
    WORD                wNumDescr;
    tPdoDescHeader *    pPdoDescHeader;         ///< ptr to descriptor
    tLinkPdosReq *      pLinkPdosReq = NULL;    ///< ptr to message (Rx)
    tCnApiEvent         CnApiEvent;             ///< forwarded to application
    BOOL fRet = TRUE;                           ///< temporary return value
    tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;

    DEBUG_FUNC;

    /* check message descriptor */
    if (pMsgDescr_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* verify all buffer pointers we intend to use */
    if (pRxMsgBuffer_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* assign buffer payload addresses */
    pLinkPdosReq = (tLinkPdosReq *) pRxMsgBuffer_p;    // Rx buffer

    /* handle Rx Message */
    /* get numbers of descriptors in this message */
    wNumDescr = pLinkPdosReq->m_bDescrCnt;

    /* get pointer to  first descriptor */
    pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pLinkPdosReq + sizeof(tLinkPdosReq));

    /* check if mapping version has changed */
    if(pLinkPdosReq->m_bDescrVers == wPdoMappingVersion_l)
    {/* no mapping necessary */
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Descriptor Version %d still valid. \n", wPdoMappingVersion_l);
        goto exit;
    }
    else
    {/* new mapping */
        wCntMappedNotLinkedObj_l = 0; // reset counter

        wPdoMappingVersion_l = pLinkPdosReq->m_bDescrVers;
        DEBUG_TRACE2(DEBUG_LVL_CNAPI_INFO, "New Descriptor Version: %d. Contains %d PDO descriptors.\n",
                     wPdoMappingVersion_l, wNumDescr);

        /* read all descriptors and setup the corresponding copy tables */
        for (iCnt = 0; iCnt < wNumDescr; ++iCnt)
        {
            fRet = CnApi_readPdoDesc(pPdoDescHeader);
            if (fRet != TRUE)
            {
                Ret = kPdiAsyncStatusInvalidOperation;
                goto exit;
            }

            /* get pointer to next descriptor */
            pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pPdoDescHeader + sizeof(tPdoDescHeader) +
                             (pPdoDescHeader->m_bEntryCnt * sizeof(tPdoDescEntry)));
        }
    }

exit:
    /* post event to user to provide the descriptor message for further use */
    CnApiEvent.Typ_m = kCnApiEventAsyncComm;
    CnApiEvent.Arg_m.AsyncComm_m.Typ_m = kCnApiEventTypeAsyncCommIntMsgRxLinkPdosReq;
    CnApiEvent.Arg_m.AsyncComm_m.Arg_m.LinkPdosReq_m.pMsg_m = pLinkPdosReq;
    CnApiEvent.Arg_m.AsyncComm_m.Arg_m.LinkPdosReq_m.wObjNotLinked_m = wCntMappedNotLinkedObj_l;

    if (Ret == kPdiAsyncStatusSuccessful)
    {
        CnApiEvent.Arg_m.AsyncComm_m.Arg_m.LinkPdosReq_m.fSuccess_m = TRUE;
        /* assign call back */
        pMsgDescr_p->pfnTransferFinished_m = CnApi_pfnCbLinkPdosReqFinished;
    }
    else // error
    {
        CnApiEvent.Arg_m.AsyncComm_m.Arg_m.LinkPdosReq_m.fSuccess_m = FALSE;
        pMsgDescr_p->pfnTransferFinished_m = NULL;
    }

    CnApi_AppCbEvent(CnApiEvent.Typ_m, &CnApiEvent.Arg_m, NULL);

    return Ret;
}


/**
 ********************************************************************************
 \brief call back function, invoked if handleLinkPdosReq has finished
 \param  pMsgDescr_p         pointer to asynchronous message descriptor
 \return Ret                 tPdiAsyncStatus value

 This function triggers an CMD_READY_TO_OPERATE which will be sent to the PCP

 *******************************************************************************/
tPdiAsyncStatus CnApi_pfnCbLinkPdosReqFinished (struct sPdiAsyncMsgDescr * pMsgDescr_p)
{
    /* trigger AP state machine change */
    CnApi_enterApStateReadyToOperate();

    return kPdiAsyncStatusSuccessful;
}


/**
********************************************************************************
\brief	read PDO descriptor

\param  pPdoDescHeader_p    pointer to Pdo descriptor
\return FALSE if error occurred, else TRUE

CnApi_readPdoDesc() checks if the mapping changed. If it changed the
PDO descriptor is read and the copy table is updated.
*******************************************************************************/
BOOL CnApi_readPdoDesc(tPdoDescHeader * pPdoDescHeader_p)
{
    WORD wNumDescrEntries;
    WORD wPdoBufNum;
    tPdoDir bPdoDir;
    BOOL fRet = TRUE;

    wNumDescrEntries = pPdoDescHeader_p->m_bEntryCnt;
    bPdoDir = pPdoDescHeader_p->m_bPdoDir;
    wPdoBufNum = pPdoDescHeader_p->m_bBufferNum;

    fRet = CnApi_setupCopyTable(pPdoDescHeader_p,
                               wNumDescrEntries,
                               bPdoDir,
                               wPdoBufNum);
    return fRet;
}

/**
********************************************************************************
\brief	write to DPRAM Buffer acknowledge register

CnApi_ackPdoBuffer() writes a random 32bit value
to a defined buffer control register.
*******************************************************************************/
inline void CnApi_ackPdoBuffer(BYTE* pAckReg_p)
{
    const BYTE bAckValue = 0xff;

#ifdef CN_API_USING_SPI
    DEBUG_TRACE1(DEBUG_LVL_CNAPI_SPI,"Ack Offs: %d\n", (WORD) *pAckReg_p);
    /* update PCP register */
    CnApi_Spi_write(*pAckReg_p, // this is an offset in case of serial interface
                    sizeof(bAckValue),
                    (BYTE*) &bAckValue);
#else
    *pAckReg_p = bAckValue; ///> write random byte value
#endif /* CN_API_USING_SPI */
}

/**
********************************************************************************
\brief	receive PDO data

CnApi_receivePdo() receives PDO data from the PCP.
*******************************************************************************/
void CnApi_receivePdo(void)
{
    tPdoCopyTblEntry    *pCopyTblEntry;    ///< pointer to table entry
    WORD                wEntryCnt;         ///< number of copy table entries
    register int        iCntin;            ///< inner loop counter
    register int        iCntout;           ///< outer loop counter

#ifdef CN_API_USING_SPI
    DWORD               dwPdiBufOffs;

    /* copy all RPDOs from PDI buffer to local variable */
    for (iCntout = 0; iCntout < RPDO_CHANNELS_MAX; ++iCntout)
    {
        pCopyTblEntry = &(aRxPdoCopyTbl_l[iCntout].aEntry_m[0]);
        wEntryCnt = aRxPdoCopyTbl_l[iCntout].bNumOfEntries_m;
        dwPdiBufOffs = aRPdosPdi_l[iCntout].dwSpiBufOffs_m;

        if(wEntryCnt == 0) break; // no data to be copied
        DEBUG_TRACE2(DEBUG_LVL_CNAPI_SPI,"Offs: 0x%04x RPDO: %d\n", dwPdiBufOffs, iCntout);

        /* prepare PDO buffer for read access */
        CnApi_ackPdoBuffer((BYTE*) &aRPdosPdi_l[iCntout].wSpiAckOffs_m);

        for (iCntin = 0; iCntin < wEntryCnt; iCntin++)
        {   /* get Pdo data from PDI */
            CnApi_Spi_read(dwPdiBufOffs + pCopyTblEntry->wPdoOfst,
                           pCopyTblEntry->size_m,
                           (BYTE*) pCopyTblEntry->pAdrs_m);
            pCopyTblEntry++;
        }
    }
#else
    BYTE                *pPdoPdiData;      // pointer to Pdo buffer

    /* copy all RPDOs from PDI buffer to local variable */
    for (iCntout = 0; iCntout < RPDO_CHANNELS_MAX; ++iCntout)
    {
        pCopyTblEntry = &(aRxPdoCopyTbl_l[iCntout].aEntry_m[0]);
        wEntryCnt = aRxPdoCopyTbl_l[iCntout].bNumOfEntries_m;
        pPdoPdiData = aRPdosPdi_l[iCntout].pAdrs_m;

        /* prepare PDO buffer for read access */
        CnApi_ackPdoBuffer(aRPdosPdi_l[iCntout].pAck_m);

        for (iCntin = 0; iCntin < wEntryCnt; iCntin++)
        {
            memcpy (pCopyTblEntry->pAdrs_m,
                    pPdoPdiData + pCopyTblEntry->wPdoOfst,
                    pCopyTblEntry->size_m);
            pCopyTblEntry++;
        }
    }
#endif /* CN_API_USING_SPI */

}

/**
********************************************************************************
\brief	transmit PDO data

CnApi_transmitPdo() transmits PDO data to the PCP.
*******************************************************************************/
void CnApi_transmitPdo(void)
{
    tPdoCopyTblEntry    *pCopyTblEntry;    ///< pointer to table entry
    WORD                wEntryCnt;         ///< number of copy table entries
    register int        iCntin;            ///< inner loop counter
    register int        iCntout;           ///< outer loop counter

#ifdef CN_API_USING_SPI
    DWORD               dwPdiBufOffs;

    /* copy all TPdos from local variable to PDI buffer */
    for (iCntout = 0; iCntout < TPDO_CHANNELS_MAX; ++iCntout)
    {
        pCopyTblEntry = &(aTxPdoCopyTbl_l[iCntout].aEntry_m[0]);
        wEntryCnt = aTxPdoCopyTbl_l[iCntout].bNumOfEntries_m;
        dwPdiBufOffs = aTPdosPdi_l[iCntout].dwSpiBufOffs_m;

        if(wEntryCnt == 0) break; ///< no data to be copied
        DEBUG_TRACE2(DEBUG_LVL_CNAPI_SPI,"Offs: 0x%04x TPDO: %d\n", dwPdiBufOffs, iCntout);

        for (iCntin = 0; iCntin < wEntryCnt; iCntin++)
        {   /* write Pdo data to PDI */
            CnApi_Spi_write(dwPdiBufOffs + pCopyTblEntry->wPdoOfst,
                            pCopyTblEntry->size_m,
                            (BYTE*) pCopyTblEntry->pAdrs_m);
            dwPdiBufOffs += pCopyTblEntry->size_m;
            pCopyTblEntry++;
        }

        /* prepare PDO buffer for read access */
        CnApi_ackPdoBuffer((BYTE*) &aTPdosPdi_l[iCntout].wSpiAckOffs_m);
    }
#else
    BYTE                *pPdoPdiData;      ///< pointer to Pdo buffer

    /* copy all TPdos from local variable to PDI buffer */
    for (iCntout = 0; iCntout < TPDO_CHANNELS_MAX; ++iCntout)
    {
        pCopyTblEntry = &(aTxPdoCopyTbl_l[iCntout].aEntry_m[0]);
        wEntryCnt = aTxPdoCopyTbl_l[iCntout].bNumOfEntries_m;
        pPdoPdiData = aTPdosPdi_l[iCntout].pAdrs_m;

        for (iCntin = 0; iCntin < wEntryCnt; iCntin++)
        {
            memcpy (pPdoPdiData + pCopyTblEntry->wPdoOfst,
                    pCopyTblEntry->pAdrs_m,
                    pCopyTblEntry->size_m);
            pCopyTblEntry++;
        }

        /* prepare PDO buffer for next write access */
        CnApi_ackPdoBuffer(aTPdosPdi_l[iCntout].pAck_m);
    }
#endif /* CN_API_USING_SPI */
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

