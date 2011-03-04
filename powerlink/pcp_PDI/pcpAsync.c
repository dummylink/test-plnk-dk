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

/******************************************************************************/
/* global variables */

// asynchronous messages
tLinkPdosReq *pAsycMsgLinkPdoReq_g;

/* local variables */
static  tAsyncMsg * pAsyncSendBuf;
static  tAsyncMsg * pAsyncRecvBuf;
static  BYTE      * pObjData[OBJ_CRT_LNKS_BLKS] = {NULL};
static  BYTE        bReqSeqnc = 0;        ///< sequence counter of split message

/******************************************************************************/
/* function declarations */
static void handleInitPcpReq(tInitPcpReq *pInitPcpReq_p, tInitPcpResp *pInitPcpResp_p);
static void handleCreateObjLinksReq(tCreateObjLksReq *pCreateObjLinksReq_p, tCreateObjLksResp *pCreateObjLinksResp_p);

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief	initialize asynchronous functions
*******************************************************************************/
int Gi_initAsync(tAsyncMsg *pAsyncSendBuf_p, tAsyncMsg *pAsyncRecvBuf_p)
{
	pAsyncSendBuf = pAsyncSendBuf_p;
	pAsyncRecvBuf = pAsyncRecvBuf_p;

    if ((pAsyncSendBuf == NULL)              ||
        (pAsyncRecvBuf == NULL)              ||
        (pCtrlReg_g->m_wTxAsyncBufSize == 0) ||
        (pCtrlReg_g->m_wRxAsyncBufSize == 0)   )
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "\nError in %s: initializing async PCP PDI failed!\n\n", __func__);
        goto exit;
    }
    else
    {
        DEBUG_LVL_CNAPI_INFO_TRACE3("%s: Async Tx buffer adrs. %08x (size %d)\n",
                                            __func__, (unsigned int)pAsyncSendBuf, pCtrlReg_g->m_wTxAsyncBufSize);
        DEBUG_LVL_CNAPI_INFO_TRACE3("%s: Async Rx buffer adrs. %08x (size %d)\n",
                                            __func__, (unsigned int)pAsyncRecvBuf, pCtrlReg_g->m_wRxAsyncBufSize);
    }

    memset(pAsyncSendBuf, 0 ,sizeof(tAsyncMsg)); ///> reset Headers
    memset(pAsyncRecvBuf, 0 ,sizeof(tAsyncMsg));

    pAsyncSendBuf->m_header.m_bSync = kMsgBufWriteOnly; ///> free buffers
    pAsyncRecvBuf->m_header.m_bSync = kMsgBufWriteOnly;

exit:
	return 0;
}

/**
********************************************************************************
\brief	poll for asynchronous messages
*******************************************************************************/
void Gi_pollAsync(void)
{
	BYTE		bMsgType;
	int         iWait = 0;

	//DEBUG_FUNC;

	/* check if there is an asynchronous message from the AP */
	if (pAsyncSendBuf->m_header.m_bSync != kMsgBufReadOnly)
		return;                                                       ///< no message

    /* check if response buffer is free */
    if (pAsyncRecvBuf->m_header.m_bSync != kMsgBufWriteOnly)
        return;                                                       ///< buffer occupied, can not setup response

	if (pAsyncSendBuf->m_header.m_bChannel != kAsyncChannelInternal)
	{
		/* SDO channel received. Ignore!!! */
		pAsyncSendBuf->m_header.m_bSync = kMsgBufWriteOnly;
		return;                                                       ///< no  internal message
	}

	bMsgType = pAsyncSendBuf->m_chan.m_intChan.m_intHeader.m_bCmd;

	/* handle the internal channel message and set up response */
	switch (bMsgType)
	{
	case kAsyncCmdInitPcpReq:
		handleInitPcpReq(&pAsyncSendBuf->m_chan.m_intChan.m_initPcpReq, &pAsyncRecvBuf->m_chan.m_intChan.m_initPcpResp);
		break;
	case kAsyncCmdCreateObjLinksReq:
		handleCreateObjLinksReq(&pAsyncSendBuf->m_chan.m_intChan.m_createObjLinksReq, &pAsyncRecvBuf->m_chan.m_intChan.m_createObjLinksResp);
		break;
	case kAsyncCmdWriteObjReq:
		break;
	default:
		break;
	}

	pAsyncSendBuf->m_header.m_bSync = kMsgBufWriteOnly;		/* reset sync flag -> free async buffer for AP access */

	/* prepare async msg header */
	switch (bMsgType)
	{
	case kAsyncCmdInitPcpReq:
		pAsyncRecvBuf->m_header.m_wFrgmtLen = sizeof(tInitPcpResp);
		break;
	case kAsyncCmdCreateObjLinksReq:
		pAsyncRecvBuf->m_header.m_wFrgmtLen = sizeof(tCreateObjLksResp);
		break;
	case kAsyncCmdWriteObjReq:
		break;
	default:
		break;
	}
	/* set channel and sync flag */
	pAsyncRecvBuf->m_header.m_bChannel = kAsyncChannelInternal;
	pAsyncRecvBuf->m_header.m_bSync = kMsgBufReadOnly; ///< activate response

    /* wait to ensure AP response */
    while(pAsyncRecvBuf->m_header.m_bSync == kMsgBufReadOnly)
    {
       iWait++;
       if (iWait >= 100)
       {   /* can not write to buffer, it is not freed */
           DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "TIMEOUT: AP does not respond!\n");
           return;
       }
       usleep(1000);
    }
    //TODO: additional AP -> PCP IR Signal would prevent this while loop

}


/**
********************************************************************************
\brief	handle an initPcpReq and set up response
*******************************************************************************/
void handleInitPcpReq(tInitPcpReq *pInitPcpReq_p, tInitPcpResp *pInitPcpResp_p)
{
	tCnApiInitParm 		*pInitParm = &initParm_g;

	DEBUG_FUNC;

	/* store data from InitPcpReq */
	memcpy (pInitParm->m_abMac, pInitPcpReq_p->m_abMac,
			sizeof(pInitPcpReq_p->m_abMac));
	pInitParm->m_dwDeviceType = pInitPcpReq_p->m_dwDeviceType;
	pInitParm->m_dwFeatureFlags = pInitPcpReq_p->m_dwFeatureFlags;
	pInitParm->m_bNodeId = pInitPcpReq_p->m_dwNodeId;
	pInitParm->m_dwRevision = pInitPcpReq_p->m_dwRevision;
	pInitParm->m_dwSerialNum = pInitPcpReq_p->m_dwSerialNum;
	pInitParm->m_dwVendorId = pInitPcpReq_p->m_dwVendorId;
	pInitParm->m_dwProductCode = pInitPcpReq_p->m_dwProductCode;
	pInitParm->m_dwAsendMaxLatency = pInitPcpReq_p->m_dwAsendMaxLatency;
	pInitParm->m_dwPresMaxLatency = pInitPcpReq_p->m_dwPresMaxLatency;
	pInitParm->m_wIsoRxMaxPayload = pInitPcpReq_p->m_wIsoRxMaxPayload;
	pInitParm->m_wIsoTxMaxPayload = pInitPcpReq_p->m_wIsoTxMaxPayload;

	/* setup response */
	pInitPcpResp_p->m_bCmd = kAsyncCmdInitPcpResp;
	pInitPcpResp_p->m_bReqId = pInitPcpReq_p->m_bReqId;
	pInitPcpResp_p->m_wStatus = kCnApiStatusOk;
}

/**
********************************************************************************
\brief	handle an createObjLinksReq

This function allocates memory and links objects to HEAP.
Furthermore it sets up a response.
*******************************************************************************/
void handleCreateObjLinksReq(tCreateObjLksReq *pCreateObjLinksReq_p, tCreateObjLksResp *pCreateObjLinksResp_p)
{
	register int 	i;
	WORD			wNumObjs;
	tCnApiObjId		*pObjId;
	int				iSize, iEntrySize;
	unsigned int	uiVarEntries;
	tEplKernel		EplRet;
	char            *pData;
	unsigned int	uiSubindex;
	tObjTbl         *pObjLinksTable;

	DEBUG_FUNC;

	wNumObjs = pCreateObjLinksReq_p->m_wNumObjs;
	pObjId = (tCnApiObjId *)(pCreateObjLinksReq_p + 1);
	pObjLinksTable = pPcpLinkedObjs_g + dwApObjLinkEntries_g;

	pCreateObjLinksResp_p->m_wStatus = kCnApiStatusOk;

	/* check if objects are existing and count data size for HEAP allocation */
	iSize = 0;
	for (i = 0; i < wNumObjs; i++, pObjId++)
	{
		if (pObjId->m_bSubIndex == 0) ///< indicator of subindex chain msg -> check whole index
		{
			/* get size of objects for the whole subindex chain */
			for (uiSubindex = 1; uiSubindex <= pObjId->m_bNumEntries; uiSubindex++) //TODO: does it make sense to start with Subindex 0 for DomainObject or Arrayobject e.g?
			{
				// read local entry size (defined in objdict.h)
				iEntrySize = EplObdGetDataSize(pObjId->m_wIndex, uiSubindex);
				if (iEntrySize == 0x00)
				{
					// invalid entry size (maybe object doesn't exist or entry of type DOMAIN is empty)
				    /* prepare response msg */
					pCreateObjLinksResp_p->m_wStatus = kCnApiStatusObjectNotExist;
					pCreateObjLinksResp_p->m_wErrIndex = pObjId->m_wIndex;
					pCreateObjLinksResp_p->m_bErrSubindex = pObjId->m_bSubIndex;

		            DEBUG_TRACE3(DEBUG_LVL_CNAPI_ERR, "ERROR in %s: 0x%04x/0x%02x does not exist or has invalid size!\n"
		                         "No Objects will be linked!\n", __func__, pObjId->m_wIndex, pObjId->m_bSubIndex);
		            wNumObjs = 0; ///< skip object linking
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
				pCreateObjLinksResp_p->m_wStatus = kCnApiStatusObjectNotExist;
				pCreateObjLinksResp_p->m_wErrIndex = pObjId->m_wIndex;
				pCreateObjLinksResp_p->m_bErrSubindex = pObjId->m_bSubIndex;
				DEBUG_TRACE3(DEBUG_LVL_CNAPI_ERR, "ERROR in %s: 0x%04x/0x%02x does not exist or has invalid size!\n"
                             "No Objects will be linked!\n", __func__, pObjId->m_wIndex, pObjId->m_bSubIndex);
				wNumObjs = 0; ///< skip object linking
				break;
			}
			iSize += iEntrySize;
		}
	}

	/* all objects exist -> link them to HEAP */
	if (pCreateObjLinksResp_p->m_wStatus == kCnApiStatusOk)
	{
	    if (pCreateObjLinksReq_p->m_bReqId == FST_OBJ_CRT_INDICATOR)
	    {// asynchronous message counter 2 indicates a AP restart (workaround)
	        bReqSeqnc = 0;
	    }

	    DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO ,"Sequence: %d \n", bReqSeqnc);
	    if (bReqSeqnc > OBJ_CREATE_LINKS_REQ_MAX_SEQ)
	    {
	        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: Invalid sequence %d!\n", bReqSeqnc);
	        goto exit;
	    }

		/* allocate memory in HEAP */
	    if (pObjData[bReqSeqnc] != NULL)
	    {
	        free(pObjData[bReqSeqnc]); ///< memory has been allocated before! overwrite it...
	    }
		if ((pObjData[bReqSeqnc] = malloc(iSize)) == NULL)
		{
		    /* prepare response msg */
			DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Couldn't allocate memory for objects!\n");
			pCreateObjLinksResp_p->m_wStatus = kCnApiStatusAllocationFailed;
		}
		else
		{
			/* link objects to allocated HEAP memory */
			pObjId = (tCnApiObjId *)(pCreateObjLinksReq_p + 1);
			pData = pObjData[bReqSeqnc];

            for (i = 0; i < wNumObjs; i++, pObjId++)
			{

                if (dwApObjLinkEntries_g > MAX_NUM_LINKED_OBJ_PCP)
                {
                  DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "Object link table (size %d) exceeded! Linking stopped!\n", MAX_NUM_LINKED_OBJ_PCP);
                  goto exit;
                }

				uiVarEntries = pObjId->m_bNumEntries;
				iSize = 0;

				DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "Linking variable: 0x%04x/0x%02x to 0x%08x\n", pObjId->m_wIndex, pObjId->m_bSubIndex, (unsigned int)pData);

				EplRet = EplApiLinkObject(pObjId->m_wIndex, pData, &uiVarEntries, &iSize, pObjId->m_bSubIndex);
				if (EplRet != kEplSuccessful)
				{
				    /* prepare response msg */
					DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "linking process vars... error\n\n");
					pCreateObjLinksResp_p->m_wStatus = kCnApiStatusObjectNotExist;
					pCreateObjLinksResp_p->m_wErrIndex = pObjId->m_wIndex;
					pCreateObjLinksResp_p->m_bErrSubindex = pObjId->m_bSubIndex;
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
	bReqSeqnc++;

	/* setup response msg header */
	pCreateObjLinksResp_p->m_bCmd = kAsyncCmdCreateObjLinksResp;
	pCreateObjLinksResp_p->m_bReqId = pCreateObjLinksReq_p->m_bReqId;

exit:
    return;
}

/**
********************************************************************************
\brief	handle an writeObjReq
*******************************************************************************/
void handleWriteObjReq(tAsyncIntChan *pCreateObjLinksReq_p, tAsyncIntChan *pCreateObjLinksResp_p)
{
	DEBUG_FUNC;

	/* setup response */

}





/* END-OF-FILE */
/******************************************************************************/

