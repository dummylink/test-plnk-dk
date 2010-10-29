/**
********************************************************************************
\file		GenericIfAsync.c

\brief		Asynchronous functions of generic interface

\author		Josef Baumgartner

\date		26.04.2010

*******************************************************************************/

/******************************************************************************/
/* includes */

/******************************************************************************/
/* defines */
#include "global.h"
#include "Debug.h"

#include "cnApi.h"
#include "pcp.h"

#include "Epl.h"
#include "kernel/EplObdk.h"

#include <string.h>

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
static	tAsyncMsg *	pAsyncSendBuf;
static	tAsyncMsg *	pAsyncRecvBuf;
char   *pObjData   = NULL;

/******************************************************************************/
/* function declarations */
static void handleInitPcpReq(tInitPcpReq *pInitPcpReq_p, tInitPcpResp *pInitPcpResp_p);
static void handleCreateObjReq(tCreateObjReq *pCreateObjReq_p, tCreateObjResp *pCreateObjResp_p);

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
	return 0;
}

/**
********************************************************************************
\brief	poll for asynchronous messages
*******************************************************************************/
void Gi_pollAsync(void)
{
	BYTE		bMsgType;

	//DEBUG_FUNC;

	/* check if there is an asynchronous message from the AP */
	if (pAsyncSendBuf->m_header.m_bSync != kMsgBufFull)
		return;

	if (pAsyncSendBuf->m_header.m_bChannel != kAsyncChannelInternal)
	{
		/* SDO channel received. Ignore!!! */
		pAsyncSendBuf->m_header.m_bSync = kMsgBufEmpty;
		return;
	}

	bMsgType = pAsyncSendBuf->m_chan.m_intChan.m_intHeader.m_bCmd;

	/* handle the internal channel message */
	switch (bMsgType)
	{
	case kAsyncCmdInitPcpReq:
		handleInitPcpReq(&pAsyncSendBuf->m_chan.m_intChan.m_initPcpReq, &pAsyncRecvBuf->m_chan.m_intChan.m_initPcpResp);
		break;
	case kAsyncCmdCreateObjReq:
		handleCreateObjReq(&pAsyncSendBuf->m_chan.m_intChan.m_createObjReq, &pAsyncRecvBuf->m_chan.m_intChan.m_createObjResp);
		break;
	case kAsyncCmdWriteObjReq:
		break;
	default:
		break;
	}

	pAsyncSendBuf->m_header.m_bSync = kMsgBufEmpty;		/* reset sync flag */

	/* wait for free buffer */
	while (pAsyncRecvBuf->m_header.m_bSync == kMsgBufFull);

	switch (bMsgType)
	{
	case kAsyncCmdInitPcpReq:
		pAsyncRecvBuf->m_header.m_wDataLen = sizeof(tInitPcpResp);
		break;
	case kAsyncCmdCreateObjReq:
		pAsyncRecvBuf->m_header.m_wDataLen = sizeof(tCreateObjResp);
		break;
	case kAsyncCmdWriteObjReq:
		break;
	default:
		break;
	}
	/* set internal channel and synchronise flag */
	pAsyncRecvBuf->m_header.m_bChannel = kAsyncChannelInternal;
	pAsyncRecvBuf->m_header.m_bSync = kMsgBufFull;

}


/**
********************************************************************************
\brief	handle an initPcpReq
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
\brief	handle an createObjReq
*******************************************************************************/
void handleCreateObjReq(tCreateObjReq *pCreateObjReq_p, tCreateObjResp *pCreateObjResp_p)
{
	register int 	i;
	WORD			wNumObjs;
	tCnApiObjId		*pObjId;
	int				iSize, iEntrySize;
	unsigned int	uiVarEntries;
	tEplKernel		EplRet;
	char            *pData;
	unsigned int	uiSubindex;

	DEBUG_FUNC;

	wNumObjs = pCreateObjReq_p->m_wNumObjs;
	pObjId = (tCnApiObjId *)(pCreateObjReq_p + 1);

	pCreateObjResp_p->m_wStatus = kCnApiStatusOk;

	/* count data size and check if objects are existing */
	iSize = 0;
	for (i = 0; i < wNumObjs; i++, pObjId++)
	{
		if (pObjId->m_bSubIndex == 0)
		{
			/* get size of object */
			for (uiSubindex = 0; uiSubindex <= pObjId->m_bNumEntries; uiSubindex++)
			{
				// read entry size
				iEntrySize = EplObdGetDataSize(pObjId->m_wIndex, uiSubindex);
				if (iEntrySize == 0x00)
				{
					// invalid entry size (maybe object doesn't exist or entry of type DOMAIN is empty)
					pCreateObjResp_p->m_wStatus = kCnApiStatusObjectNotExist;
					pCreateObjResp_p->m_wErrIndex = pObjId->m_wIndex;
					pCreateObjResp_p->m_bErrSubindex = pObjId->m_bSubIndex;
					break;
				}
				iSize += iEntrySize;
			}
		}
		else
		{
			if ((iEntrySize = EplObdGetDataSize(pObjId->m_wIndex, pObjId->m_bSubIndex)) == 0)
			{
				// invalid entry size (maybe object doesn't exist or entry of type DOMAIN is empty)
				pCreateObjResp_p->m_wStatus = kCnApiStatusObjectNotExist;
				pCreateObjResp_p->m_wErrIndex = pObjId->m_wIndex;
				pCreateObjResp_p->m_bErrSubindex = pObjId->m_bSubIndex;
				break;
			}
			iSize += iEntrySize;
		}
	}

	if (pCreateObjResp_p->m_wStatus == kCnApiStatusOk)
	{
		/* allocate memory */
	    if (pObjData != NULL)
	    {
	        free(pObjData); ///< memory has been allocated before! overwrite it...
	    }
		if ((pObjData = malloc(iSize)) == NULL)
		{
			DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Couldn't allocate memory for objects!\n");
			pCreateObjResp_p->m_wStatus = kCnApiStatusAllocationFailed;
		}
		else
		{
			/* link objects to allocated memory */
			pObjId = (tCnApiObjId *)(pCreateObjReq_p + 1);
			pData = pObjData;
			for (i = 0; i < wNumObjs; i++, pObjId++)
			{
				uiVarEntries = pObjId->m_bNumEntries;
				iSize = 0;
				DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "Linking variable: 0x%04x/0x%02x to 0x%08x\n", pObjId->m_wIndex, pObjId->m_bSubIndex, (unsigned int)pData);
				EplRet = EplApiLinkObject(pObjId->m_wIndex, pData, &uiVarEntries, &iSize, pObjId->m_bSubIndex);
				if (EplRet != kEplSuccessful)
				{
					DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "linking process vars... error\n\n");
					pCreateObjResp_p->m_wStatus = kCnApiStatusObjectNotExist;
					pCreateObjResp_p->m_wErrIndex = pObjId->m_wIndex;
					pCreateObjResp_p->m_bErrSubindex = pObjId->m_bSubIndex;
					break;
				}
				pData += iSize;
			}
		}
	}

	/* setup response */
	pCreateObjResp_p->m_bCmd = kAsyncCmdCreateObjResp;
	pCreateObjResp_p->m_bReqId = pCreateObjReq_p->m_bReqId;
	return;
}

/**
********************************************************************************
\brief	handle an writeObjReq
*******************************************************************************/
void handleWriteObjReq(tAsyncIntChan *pCreateObjReq_p, tAsyncIntChan *pCreateObjResp_p)
{
	DEBUG_FUNC;

	/* setup response */

}





/* END-OF-FILE */
/******************************************************************************/

