/**
********************************************************************************
\file		GenericIfAsync.c

\brief		Asynchronous functions of generic interface

\author		Josef Baumgartner

\date		26.04.2010

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "global.h"
#include "Debug.h"

#include "cnApi.h"
#include "cnApiAsync.h"
#include "pcp.h"

#include "Epl.h"
#include "kernel/EplObdk.h"

#include <unistd.h> // for usleep()

#include <string.h>

/******************************************************************************/
/* defines */
#define OBJ_CRT_LNKS_BLKS       OBJ_CREATE_LINKS_REQ_MAX_SEQ+1

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */
tPcpPdiAsyncMsgBufDescr aPcpPdiAsyncTxMsgBuffer_g[PDI_ASYNC_CHANNELS_MAX];
tPcpPdiAsyncMsgBufDescr aPcpPdiAsyncRxMsgBuffer_g[PDI_ASYNC_CHANNELS_MAX];

/******************************************************************************/
/* global variables */

/* local variables */
static  BYTE *  pObjData[OBJ_CRT_LNKS_BLKS] = {NULL};
static  BYTE    bReqSeqnc_l = 0;      ///< sequence counter of split message
static  BYTE    bDescrVers_l = 0;     ///< descriptor version of LinkPdosReq
static  BYTE    bReqId_l = 0;         ///< asynchronous msg counter
/* variable indicates if AP objects have been linked successfully,
 * an error happened or no linking happened yet
 */
static tPdiAsyncStatus ApLinkingStatus_l = kPdiAsyncStatusInvalidState;

/******************************************************************************/
/* function declarations */

static tPdiAsyncStatus cnApiAsync_handleInitPcpReq(struct sPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                    BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus cnApiAsync_handleCreateObjLinksReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                           BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p          );
static tPdiAsyncStatus cnApiAsync_handleObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                     BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p          );
static tPdiAsyncStatus cnApiAsync_handleObjAccResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                     BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p          );
static tPdiAsyncStatus cnApiAsync_handleLinkPdosResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                             BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus cnApiAsync_doObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                     BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p          );
static tPdiAsyncStatus cnApiAsync_doObjAccResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                     BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p          );
static tPdiAsyncStatus cnApiAsync_doLinkPdosReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                 BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p          );


/******************************************************************************/
/* private functions */
static tPdiAsyncStatus CnApiAsync_initInternalMsgs(void);

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief	initialize asynchronous functions
*******************************************************************************/
int CnApiAsync_init(void)
{
    register WORD wCnt;
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;

    /* Attention: control register is seen for AP point of view -> PCP Tx is AP Rx and vice versa! */
    aPcpPdiAsyncTxMsgBuffer_g[0].pAdr_m = (tAsyncMsg *) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wRxAsyncBuf0Aoffs);
    aPcpPdiAsyncTxMsgBuffer_g[0].wMaxPayload_m = pCtrlReg_g->m_wRxAsyncBuf0Size - sizeof(tAsyncPdiBufCtrlHeader);
    aPcpPdiAsyncRxMsgBuffer_g[0].pAdr_m = (tAsyncMsg *) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wTxAsyncBuf0Aoffs);
    aPcpPdiAsyncRxMsgBuffer_g[0].wMaxPayload_m = pCtrlReg_g->m_wTxAsyncBuf0Size - sizeof(tAsyncPdiBufCtrlHeader);

    aPcpPdiAsyncTxMsgBuffer_g[1].pAdr_m = (tAsyncMsg *) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wRxAsyncBuf1Aoffs);
    aPcpPdiAsyncTxMsgBuffer_g[1].wMaxPayload_m = pCtrlReg_g->m_wRxAsyncBuf1Size - sizeof(tAsyncPdiBufCtrlHeader);
    aPcpPdiAsyncRxMsgBuffer_g[1].pAdr_m = (tAsyncMsg *) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wTxAsyncBuf1Aoffs);
    aPcpPdiAsyncRxMsgBuffer_g[1].wMaxPayload_m = pCtrlReg_g->m_wTxAsyncBuf1Size - sizeof(tAsyncPdiBufCtrlHeader);

    for (wCnt = 0; wCnt < PDI_ASYNC_CHANNELS_MAX; ++wCnt)
    {
        if ((aPcpPdiAsyncTxMsgBuffer_g[wCnt].pAdr_m == NULL)                                        ||
            (aPcpPdiAsyncTxMsgBuffer_g[wCnt].wMaxPayload_m + sizeof(tAsyncPdiBufCtrlHeader) == 0)   ||
            (aPcpPdiAsyncRxMsgBuffer_g[wCnt].pAdr_m == NULL)                                        ||
            (aPcpPdiAsyncRxMsgBuffer_g[wCnt].wMaxPayload_m + sizeof(tAsyncPdiBufCtrlHeader)== 0)      )
        {
            DEBUG_TRACE2(DEBUG_LVL_09, "\nError in %s: initializing Async PDI Buffer %d failed!\n", __func__, wCnt);
            goto exit;
        }
        else
        {
            DEBUG_TRACE4(DEBUG_LVL_11, "%s: TX Async Buffer %d: adrs. %08x (max payload %d)\n",
                         __func__, wCnt,(unsigned int)aPcpPdiAsyncTxMsgBuffer_g[wCnt].pAdr_m,
                         aPcpPdiAsyncTxMsgBuffer_g[wCnt].wMaxPayload_m);
            DEBUG_TRACE4(DEBUG_LVL_11, "%s: RX Async Buffer %d: adrs. %08x (max payload %d)\n",
                         __func__, wCnt,(unsigned int)aPcpPdiAsyncRxMsgBuffer_g[wCnt].pAdr_m,
                         aPcpPdiAsyncRxMsgBuffer_g[wCnt].wMaxPayload_m);
            /* reset headers */
            memset(aPcpPdiAsyncTxMsgBuffer_g[wCnt].pAdr_m, 0 ,sizeof(tAsyncMsg));
            memset(aPcpPdiAsyncRxMsgBuffer_g[wCnt].pAdr_m, 0 ,sizeof(tAsyncMsg));

            /* free buffers */
            aPcpPdiAsyncTxMsgBuffer_g[wCnt].pAdr_m->m_header.m_bSync = kMsgBufWriteOnly;
            aPcpPdiAsyncRxMsgBuffer_g[wCnt].pAdr_m->m_header.m_bSync = kMsgBufWriteOnly;
        }
    }

    Ret = CnApiAsync_initInternalMsgs();
    if (Ret != kPdiAsyncStatusSuccessful)
    {
        goto exit;
    }

    Ret = CnApiAsync_finishMsgInit();
    if (Ret != kPdiAsyncStatusSuccessful)
    {
        goto exit;
    }

    return OK;
exit:
    return ERROR;
}


/**
********************************************************************************
\brief  initialize asynchronous messages using the internal channel
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
tPdiAsyncStatus CnApiAsync_initInternalMsgs(void)
{
    tPcpPdiAsyncDir Dir;
    tPcpPdiAsyncMsgBufDescr * pPdiBuf = NULL;
    tPdiAsyncTransferType TfrTyp;
    tAsyncChannel ChanType_p;
    tPcpStates * pNmtList = NULL;
    WORD wTout = 0;
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;

    /* Rx messages */
    Dir = kCnApiDirReceive; // transfer type doesn't matter -> chosen according to Rx messsage size
    TfrTyp = kPdiAsyncTrfTypeAutoDecision;
    pPdiBuf = &aPcpPdiAsyncRxMsgBuffer_g[0];
    ChanType_p = kAsyncChannelInternal;
    pNmtList = NULL;
    wTout = 100;

    Ret = CnApiAsync_initMsg(kPdiAsyncMsgIntInitPcpReq, Dir, cnApiAsync_handleInitPcpReq, pPdiBuf,
                              kPdiAsyncMsgIntInitPcpResp, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntCreateObjLinksReq, Dir, cnApiAsync_handleCreateObjLinksReq, pPdiBuf,
                        kPdiAsyncMsgIntCreateObjLinksResp, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccReq, Dir, cnApiAsync_handleObjAccReq, pPdiBuf,
                        kPdiAsyncMsgIntObjAccResp, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    //TODO: make handle: cnApiAsync_initMsg(kPdiAsyncMsgIntReadObjAccResp, Dir, ...);
    //if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntLinkPdosResp, Dir, cnApiAsync_handleLinkPdosResp, pPdiBuf,
                       kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    /* Tx messages */
    Dir = kCnApiDirTransmit;
    TfrTyp = kPdiAsyncTrfTypeLclBuffering;
    pPdiBuf = &aPcpPdiAsyncTxMsgBuffer_g[0];

    CnApiAsync_initMsg(kPdiAsyncMsgIntInitPcpResp, Dir, NULL, pPdiBuf,
                        kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntCreateObjLinksResp, Dir, NULL, pPdiBuf,
                        kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccResp, Dir, NULL, pPdiBuf,
                       kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    TfrTyp = kPdiAsyncTrfTypeLclBuffering;
    CnApiAsync_initMsg(kPdiAsyncMsgIntLinkPdosReq, Dir, cnApiAsync_doLinkPdosReq, pPdiBuf,
                        kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

exit:
    return Ret;
}

/**
********************************************************************************
\brief	handle an initPcpReq and set up response
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
tPdiAsyncStatus cnApiAsync_handleInitPcpReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                             BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
	tCnApiInitParm *	pInitParm = &initParm_g;
	tInitPcpReq *       pInitPcpReq = NULL;        ///< pointer to request message (Rx)
	tInitPcpResp *      pInitPcpResp = NULL;       ///< pointer to response message (Tx)
	tPdiAsyncStatus    Ret = kPdiAsyncStatusSuccessful;

	DEBUG_FUNC;

    /* check message descriptor */
    if (pMsgDescr_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }
    /* check response message assignment */
    if (pMsgDescr_p->pRespMsgDescr_m == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* verify all buffer pointers we intend to use */
    if ((pRxMsgBuffer_p == NULL) || (pTxMsgBuffer_p == NULL))
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* check if expected Tx message size exceeds the buffer */
    if ( sizeof(tInitPcpResp) > dwMaxTxBufSize_p)
    {
        /* reject transfer, because direct access can not be processed */
        Ret = kPdiAsyncStatusDataTooLong;
        goto exit;
    }

    /* assign buffer payload addresses */
    pInitPcpReq = (tInitPcpReq *)pRxMsgBuffer_p;       // Rx buffer
    pInitPcpResp = (tInitPcpResp *) pTxMsgBuffer_p;    // Tx buffer

     /* handle Rx Message */
	/* store data from InitPcpReq */
	memcpy (pInitParm->m_abMac, pInitPcpReq->m_abMac,
			sizeof(pInitPcpReq->m_abMac));
	pInitParm->m_dwDeviceType = pInitPcpReq->m_dwDeviceType;
	pInitParm->m_bNodeId = pInitPcpReq->m_dwNodeId;
	pInitParm->m_dwRevision = pInitPcpReq->m_dwRevision;
	pInitParm->m_dwSerialNum = pInitPcpReq->m_dwSerialNum;
	pInitParm->m_dwVendorId = pInitPcpReq->m_dwVendorId;
	pInitParm->m_dwProductCode = pInitPcpReq->m_dwProductCode;

	/* setup response */
	pInitPcpResp->m_bReqId = pInitPcpReq->m_bReqId;
	pInitPcpResp->m_wStatus = kCnApiStatusOk;

    /* update size values of message descriptors */
    pMsgDescr_p->pRespMsgDescr_m->dwMsgSize_m = sizeof(tInitPcpResp); // sent size

exit:
    return Ret;
}

/**
********************************************************************************
\brief	handle an createObjLinksReq
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value

This function allocates memory and links objects to HEAP.
Furthermore it sets up a response.
*******************************************************************************/
tPdiAsyncStatus cnApiAsync_handleCreateObjLinksReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                        BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
	register int 	i;
	WORD			wNumObjs;
	tCnApiObjId *	pObjId;
	int				iSize, iEntrySize;
	unsigned int	uiVarEntries;
	tEplKernel		EplRet;
	char *          pData;
	unsigned int	uiSubindex;
	tObjTbl *       pObjLinksTable;
	tCreateObjLksReq * pCreateObjLinksReq = NULL;       ///< pointer to request message (Rx)
	tCreateObjLksResp * pCreateObjLinksResp = NULL;     ///< pointer to response message (Tx)
	tPdiAsyncStatus    Ret = kPdiAsyncStatusSuccessful;

	DEBUG_FUNC;

	/* check message descriptor */
	if (pMsgDescr_p == NULL)
	{
	    Ret = kPdiAsyncStatusInvalidInstanceParam;
	    goto exit;
	}
	/* check response message assignment */
	if (pMsgDescr_p->pRespMsgDescr_m == NULL)
	{
	    Ret = kPdiAsyncStatusInvalidInstanceParam;
	    goto exit;
	}

    /* verify all buffer pointers we intend to use */
    if ((pRxMsgBuffer_p == NULL) || (pTxMsgBuffer_p == NULL))
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

	/* check if expected Tx message size exceeds the buffer */
	if ( sizeof(tCreateObjLksResp) > dwMaxTxBufSize_p)
	{
	    /* reject transfer, because direct access can not be processed */
	    Ret = kPdiAsyncStatusDataTooLong;
	    goto exit;
	}

	/* assign buffer payload addresses */
	pCreateObjLinksReq = (tCreateObjLksReq *) pRxMsgBuffer_p;       // Rx buffer
	pCreateObjLinksResp = (tCreateObjLksResp *) pTxMsgBuffer_p;      // Tx buffer

    /* handle Rx Message */
	/*----------------------------------------------------------------------------*/
	wNumObjs = pCreateObjLinksReq->m_wNumObjs;
	pObjId = (tCnApiObjId *)(pCreateObjLinksReq + 1);
	pObjLinksTable = pPcpLinkedObjs_g + dwApObjLinkEntries_g;

	pCreateObjLinksResp->m_wStatus = kCnApiStatusOk;

	/* check if objects are existing and count data size for HEAP allocation */
	iSize = 0;
	for (i = 0; i < wNumObjs; i++, pObjId++)
	{
		if (pObjId->m_bSubIndex == 0) ///< indicator of subindex chain msg -> check whole index
		{
			/* get size of objects for the whole subindex chain */
			for (uiSubindex = 1; uiSubindex <= pObjId->m_bNumEntries; uiSubindex++)
			{//TODO: does it make sense to start with Subindex 0 for DomainObject or Arrayobject e.g?
				// read local entry size (defined in objdict.h)
				iEntrySize = EplObdGetDataSize(pObjId->m_wIndex, uiSubindex);
				if (iEntrySize == 0x00)
				{
					// invalid entry size (maybe object doesn't exist or entry of type DOMAIN is empty)
				    /* prepare response msg */
				    /*----------------------------------------------------------------------------*/
					pCreateObjLinksResp->m_wStatus = kCnApiStatusObjectNotExist;
					pCreateObjLinksResp->m_wErrIndex = pObjId->m_wIndex;
					pCreateObjLinksResp->m_bErrSubindex = pObjId->m_bSubIndex;
					/*----------------------------------------------------------------------------*/

		            DEBUG_TRACE3(DEBUG_LVL_CNAPI_ERR, "ERROR in %s: 0x%04x/0x%02x does not exist or has invalid size!\n"
		                         "No Objects will be linked!\n", __func__, pObjId->m_wIndex, pObjId->m_bSubIndex);
		            wNumObjs = 0; ///< skip object linking
		            Ret = kPdiAsyncStatusInvalidOperation;
		            break;
				}
				iSize += iEntrySize;
			}
		}
		else ///< regular single subindex (no subindex chain msg)
		{
			if ((iEntrySize = EplObdGetDataSize(pObjId->m_wIndex, pObjId->m_bSubIndex)) == 0)
			{
				// invalid entry size (maybe object doesn't exist or entry of type DOMAIN is empty)
			    /* prepare response msg */
			    /*----------------------------------------------------------------------------*/
				pCreateObjLinksResp->m_wStatus = kCnApiStatusObjectNotExist;
				pCreateObjLinksResp->m_wErrIndex = pObjId->m_wIndex;
				pCreateObjLinksResp->m_bErrSubindex = pObjId->m_bSubIndex;
				/*----------------------------------------------------------------------------*/
				DEBUG_TRACE3(DEBUG_LVL_CNAPI_ERR, "ERROR in %s: 0x%04x/0x%02x does not exist or has invalid size!\n"
                             "No Objects will be linked!\n", __func__, pObjId->m_wIndex, pObjId->m_bSubIndex);
				wNumObjs = 0; ///< skip object linking
				Ret = kPdiAsyncStatusInvalidOperation;
				break;
			}
			iSize += iEntrySize;
		}
	}

	/* all objects exist -> link them to HEAP */
	if (pCreateObjLinksResp->m_wStatus == kCnApiStatusOk)
	{
	    if (pCreateObjLinksReq->m_bReqId == FST_OBJ_CRT_INDICATOR)
	    {// asynchronous message counter 2 indicates a AP restart (workaround)
	        bReqSeqnc_l = 0;
	        dwApObjLinkEntries_g = 0;
	    }

	    DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO ,"Sequence: %d \n", bReqSeqnc_l);
	    if (bReqSeqnc_l > OBJ_CREATE_LINKS_REQ_MAX_SEQ)
	    {
	        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: Invalid sequence %d!\n", bReqSeqnc_l);
	        Ret = kPdiAsyncStatusInvalidMessage;
	        goto exit;
	    }

		/* allocate memory in HEAP */
	    if (pObjData[bReqSeqnc_l] != NULL)
	    {
	        free(pObjData[bReqSeqnc_l]); ///< memory has been allocated before! overwrite it...
	    }
		if ((pObjData[bReqSeqnc_l] = malloc(iSize)) == NULL)
		{
		    /* prepare response msg */
			/*----------------------------------------------------------------------------*/
			pCreateObjLinksResp->m_wStatus = kCnApiStatusAllocationFailed;
			/*----------------------------------------------------------------------------*/
			DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Couldn't allocate memory for objects!\n");
			Ret = kPdiAsyncStatusNoResource;
		}

		else
		{
			/* link objects to allocated HEAP memory */
			pObjId = (tCnApiObjId *)(pCreateObjLinksReq + 1);
			pData = pObjData[bReqSeqnc_l];

            for (i = 0; i < wNumObjs; i++, pObjId++)
			{

                if (dwApObjLinkEntries_g > MAX_NUM_LINKED_OBJ_PCP)
                {
                  DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "Object link table (size %d) exceeded! Linking stopped!\n", MAX_NUM_LINKED_OBJ_PCP);
                  Ret = kPdiAsyncStatusNoResource;
                  goto exit;
                }

				uiVarEntries = pObjId->m_bNumEntries;
				iSize = 0;

				DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "Linking variable: 0x%04x/0x%02x to 0x%08x\n", pObjId->m_wIndex, pObjId->m_bSubIndex, (unsigned int)pData);

				EplRet = EplApiLinkObject(pObjId->m_wIndex, pData, &uiVarEntries, &iSize, pObjId->m_bSubIndex);
				if (EplRet != kEplSuccessful)
				{
				    /* prepare response msg */
					/*----------------------------------------------------------------------------*/
					pCreateObjLinksResp->m_wStatus = kCnApiStatusObjectNotExist;
					pCreateObjLinksResp->m_wErrIndex = pObjId->m_wIndex;
					pCreateObjLinksResp->m_bErrSubindex = pObjId->m_bSubIndex;
					/*----------------------------------------------------------------------------*/
					DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "linking process vars... error\n\n");
					Ret = kPdiAsyncStatusInvalidOperation;
					break;
				}

				/* add entry to table of linked objects */
				pObjLinksTable->m_wIndex = pObjId->m_wIndex;
				pObjLinksTable->m_bSubIndex = pObjId->m_bSubIndex;
				pObjLinksTable->m_pData = pData;
				pObjLinksTable->m_wSize = (WORD) iSize;

				/* prepare next iteration*/
				dwApObjLinkEntries_g++;
				pObjLinksTable++;

				pData += iSize;
			}
		}
	}
	bReqSeqnc_l++;

	/* setup response msg header */
	/*----------------------------------------------------------------------------*/
	pCreateObjLinksResp->m_bReqId = pCreateObjLinksReq->m_bReqId;
	/*----------------------------------------------------------------------------*/

	/* update size values of message descriptors */
	pMsgDescr_p->pRespMsgDescr_m->dwMsgSize_m = sizeof(tCreateObjLksResp);     // sent size

exit:
    Ret = kPdiAsyncStatusSuccessful; // Response message has to be delivered -> fake everything is ok
    return Ret;
}

/**
********************************************************************************
\brief  handle an object request message
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
tPdiAsyncStatus cnApiAsync_handleObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                  BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p        )
{

    tObjAccMsg *    pObjAccReq = NULL;
    tObjAccMsg *    pObjAccResp = NULL;
    tPdiAsyncStatus    Ret = kPdiAsyncStatusSuccessful;

    DEBUG_FUNC;

    /* check message descriptor */
    if (pMsgDescr_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }
    /* check response message assignment */
    if (pMsgDescr_p->pRespMsgDescr_m == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* verify all buffer pointers we intend to use */
    if ((pRxMsgBuffer_p == NULL) || (pTxMsgBuffer_p == NULL))
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* check if expected Tx message size exceeds the buffer */
    if ( sizeof(tObjAccMsg) > dwMaxTxBufSize_p)
    {
        /* reject transfer, because direct access can not be processed */
        Ret = kPdiAsyncStatusDataTooLong;
        goto exit;
    }

    /* assign buffer payload addresses */
    pObjAccReq = (tObjAccMsg *) pRxMsgBuffer_p;      // Rx buffer
    pObjAccResp = (tObjAccMsg *) pTxMsgBuffer_p;     // Tx buffer

    /* setup response */
    /*----------------------------------------------------------------------------*/
    // TODO: actual function
    /*----------------------------------------------------------------------------*/

    /* update size values of message descriptors */
    pMsgDescr_p->pRespMsgDescr_m->dwMsgSize_m = sizeof(tObjAccMsg);     // sent size

exit:
    return Ret;
}


/**
********************************************************************************
\brief  handle an object response message
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
static tPdiAsyncStatus cnApiAsync_handleObjAccResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                     BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    //TODO
}


/**
********************************************************************************
\brief  create an object request message
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
static tPdiAsyncStatus cnApiAsync_doObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                     BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    //TODO put to do's
}

/**
********************************************************************************
\brief  create an object response message
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
static tPdiAsyncStatus cnApiAsync_doObjAccResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                     BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    //TODO put to do's
}

/**
********************************************************************************
\brief  handle an Link PDOs Response message
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
tPdiAsyncStatus cnApiAsync_handleLinkPdosResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                             BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tLinkPdosResp *    pLinkPdosResp = NULL;       ///< pointer to response message (Tx)
    tPdiAsyncStatus    Ret = kPdiAsyncStatusSuccessful;

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
    pLinkPdosResp = (tLinkPdosResp *)pRxMsgBuffer_p;       // Rx buffer

    /* handle Rx Message */
    /* store data from pLinkPdosResp */
    if (pLinkPdosResp->m_bDescrVers != bDescrVers_l)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Wrong descriptor version returned: %d\n", pLinkPdosResp->m_bDescrVers);
        Ret = kPdiAsyncStatusReqIdError;
        goto exit;
    }

    if (pLinkPdosResp->m_wStatus != kCnApiStatusOk)
    { /* mapping is invalid or linking at AP failed */
        // do not proceed to ReadyToOperate state (per default)!
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: AP object linking failed! Bootup will not proceed!\n");
        //TODO: forward error e.g. return an SDO abort after mapping object has been written
        ApLinkingStatus_l = kPdiAsyncStatusRespError;
    }

    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "OK!\n");
    ApLinkingStatus_l = kPdiAsyncStatusSuccessful;

exit:
    return Ret;
}

/**
********************************************************************************
\brief  handle an tLinkPdosReq
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
tPdiAsyncStatus cnApiAsync_doLinkPdosReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pTxMsgBuffer_p,
                                       BYTE* pRxMsgBuffer_p, DWORD dwMaxTxBufSize_p        )
{

    tLinkPdosReq *      pLinkPdosReq = NULL;
    tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;
    BOOL fRet = TRUE;                                       ///< temporary return value
    WORD wCurDescrPayloadOffset = 0;

    DEBUG_FUNC;

    /* check message descriptor */
    if (pMsgDescr_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* verify all buffer pointers we intend to use */
    if (pTxMsgBuffer_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* check if expected Tx message size exceeds the buffer */
    if ( sizeof(tLinkPdosReq) > dwMaxTxBufSize_p) //TODO: estimated size?? max mapp objects??
    {
        /* reject transfer, because direct access can not be processed */
        Ret = kPdiAsyncStatusDataTooLong;
        goto exit;
    }

    /* assign buffer payload addresses */
    pLinkPdosReq = (tLinkPdosReq *) pTxMsgBuffer_p;      // Tx buffer

    /* setup Tx message */
    /*----------------------------------------------------------------------------*/
    /* Prepare PDO descriptor message for AP */

    pLinkPdosReq->m_bDescrCnt = 0; ///< reset descriptor counter
    dwSumMappingSize_g = 0;        ///< reset overall sum of mapping size

    fRet = Gi_setupPdoDesc(kCnApiDirReceive, &wCurDescrPayloadOffset, pLinkPdosReq);
    if (fRet != TRUE)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR!\n");
        Ret = kPdiAsyncStatusInvalidOperation;
        goto exit;
    }

    fRet = Gi_setupPdoDesc(kCnApiDirTransmit, &wCurDescrPayloadOffset, pLinkPdosReq);
    if (fRet != TRUE)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR!\n");
        Ret = kPdiAsyncStatusInvalidOperation;
        goto exit;
    }

    bDescrVers_l++;                     ///< increase descriptor version number
    pLinkPdosReq->m_bDescrVers = bDescrVers_l;

    DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Descriptor Version: %d\n", pLinkPdosReq->m_bDescrVers);
    /*----------------------------------------------------------------------------*/

    /* update size values of message descriptors */
    pMsgDescr_p->dwMsgSize_m = wCurDescrPayloadOffset + sizeof(tLinkPdosReq);     // sent size

    // reset AP status linking status, because we want the AP to do a new linking now
    ApLinkingStatus_l = kPdiAsyncStatusInvalidState;

exit:
    return Ret;
}


/**
 ********************************************************************************
 \brief returns status of AP linking procedure
 \return    tPdiAsyncStatus value
 \retval    kPdiAsyncStatusInvalidState AP has not yet processed the linking request
 \retval    kPdiAsyncStatusSuccessful   AP linking was successful
 \retval    kPdiAsyncStatusRespError    AP linking failed
 \retval    kPdiAsyncStatusInvalidState ApLinkingStatus_l has and invalid value

 This function returns the value of ApLinkingStatus_l. Every time it is executed,
 ApLinkingStatus_l will be reset to "kPdiAsyncStatusInvalidState".
 The changing of ApLinkingStatus_l will be done upon reception of
 LinkPdoResp message.
 *******************************************************************************/
tPdiAsyncStatus CnApiAsync_checkApLinkingStatus(void)
{
    tPdiAsyncStatus Ret;

    switch (ApLinkingStatus_l)
    {
        case kPdiAsyncStatusSuccessful:
        case kPdiAsyncStatusRespError:
        case kPdiAsyncStatusInvalidState:
        {
            Ret = ApLinkingStatus_l;
            // reset status
            ApLinkingStatus_l = kPdiAsyncStatusInvalidState;
            break;
        }

        default:
        {
            // invalid value is assigned
            Ret = kPdiAsyncStatusInvalidInstanceParam;
        break;
        }

    }

    return Ret;
}

/* END-OF-FILE */
/******************************************************************************/

