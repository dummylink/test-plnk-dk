/**
********************************************************************************
\file		cnApiAsync.c

\brief		CN API asynchronous transfer functions

\author		Josef Baumgartner

\date		20.04.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This module contains functions for the asynchronous transfer in the CN API library.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApi.h"
#include "cnApiIntern.h"
#include "stateMachine.h"

#include <string.h>
#include <unistd.h>

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
// asynchronous messages
tLinkPdosReq *pAsycMsgLinkPdoReqAp_g;

static tAsyncMsg			*pAsyncTxAdrs_l;
static WORD					wAsyncTxSize_l;

static tAsyncMsg			*pAsyncRxAdrs_l;
static WORD					wAsyncRxSize_l;

static BYTE					bReqId_l;						///< saved request Id of request

/******************************************************************************/
/* function declarations */


/******************************************************************************/
/* private functions */

/**
********************************************************************************
\brief	send an asynchronous message

CnApi_sendAsync() is used to send an asynchronous message through the
asynchronous transmit buffer.

\param		bChannel_p				channel of asynchronous message
\param		pData_p					pointer to message which should be sent
\param		wLen_p					length of message which should be sent
\param		pPayload_p				pointer to additional payload data in message.
									If pointer is NULL nothing will be copied.
\param		wPayloadLen_p			length of additional payload data in message

\return		function returns status code
\retval		kCnApiStatusMsgBufFull		if message buffer is already filled with data
\retval		kCnApiStatusDataTooLong		if data is to long for message buffer
\retval		kCnApiStatusOk				if data was successfully written to the message buffer
*******************************************************************************/
tAsyncSendStatus CnApi_sendAsync(BYTE bChannel_p, tAsyncIntChan *pData_p, WORD wLen_p,
		            char *pPayload_p, WORD wPayloadLen_p)
{
	char  *pDest;

	/* check if buffer is free */
	if (pAsyncTxAdrs_l->m_header.m_bSync == kMsgBufReadOnly)
		return kAsyncSendStatusBufFull;

	/* check if data length is too big */
	if (wLen_p > (wAsyncTxSize_l - sizeof(tAsyncMsgHeader)))
		return kAsyncSendStatusDataTooLong;

	pDest = (char *)&pAsyncTxAdrs_l->m_chan.m_intChan;
	/* copy data to msg buffer */
	memcpy(pDest, pData_p, wLen_p);

	/* check if we have to copy additional payload data */
	if (pPayload_p != NULL)
	{
		memcpy(pDest + wLen_p, (char *)pPayload_p, wPayloadLen_p);
	}

	/* write message header */
	pAsyncTxAdrs_l->m_header.m_wFrgmtLen = wLen_p;
	pAsyncTxAdrs_l->m_header.m_bChannel = bChannel_p;
	pAsyncTxAdrs_l->m_header.m_bSync = kMsgBufReadOnly;

	return kAsyncSendStatusOk;
}

/**
********************************************************************************
\brief	receive an asynchronous message

CnApi_receiveAsync() is used to receive an asynchronous message through the
asynchronous RX buffer.

\param		pChannel_p				pointer to store channel of received message
\param		pData_p					pointer to store received data
\param		pLen_p					pointer to the maximum length of the local receive buffer.
                                    After copying the data, CnApi_receiveAsync() stores the
                                    length of the copied data in this location.

\return		function returns status code
\retval		kCnApiStatusMsgBufEmpty		if message buffer is still empty
\retval		kCnApiStatusDataTooLong		if data is to long for message buffer
\retval		kCnApiStatusOk				if data was successfully read from the message buffer
*******************************************************************************/
tAsyncSendStatus CnApi_receiveAsync(BYTE *pChannel_p, tAsyncIntChan *pData_p, WORD *pLen_p)
{
	/* check if buffer contains a message for us */
	if (pAsyncRxAdrs_l->m_header.m_bSync == kMsgBufWriteOnly)
		return kAsyncSendStatusBufEmpty;

	/* check if the response buffer is big enough to store the answer */
	if (pAsyncRxAdrs_l->m_header.m_wFrgmtLen > *pLen_p)
		return kAsyncSendStatusDataTooLong;

	/* copy data from msg buffer */
	memcpy(pData_p, &pAsyncRxAdrs_l->m_chan.m_intChan, pAsyncRxAdrs_l->m_header.m_wFrgmtLen);

	/* read async message header information */
	*pChannel_p = pAsyncRxAdrs_l->m_header.m_bChannel;   ///< return info about channel type
	*pLen_p = pAsyncRxAdrs_l->m_header.m_wFrgmtLen;       ///< return info about copied data

	/* reset sync flag */
	pAsyncRxAdrs_l->m_header.m_bSync = kMsgBufWriteOnly;

	return kAsyncSendStatusOk;
}

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief	initialize asynchronous transfer module

CnApi_iniAsync() initializes the asynchronous transfer functions and must be
called before transfering asynchronous data. It initializes its buffer addresses
and sizes.

\param	pAsyncTxAdrs_p			pointer to asynchronous TX buffer
\param	wAsyncTxSize_p			size of asynchronous TX buffer
\param	pAsyncRxAdrs_p			pointer to asynchronous RX buffer
\param	wAsyncRxSize_p			size of asynchronous RX buffer
*******************************************************************************/
void CnApi_initAsync(tAsyncMsg *pAsyncTxAdrs_p, WORD wAsyncTxSize_p,
					 tAsyncMsg *pAsyncRxAdrs_p, WORD wAsyncRxSize_p)
{
	DEBUG_TRACE2 (DEBUG_LVL_10, "CnApi_initAsync: TX:%08x(%04x)\n", (unsigned int)pAsyncTxAdrs_p, wAsyncTxSize_p);
	DEBUG_TRACE2 (DEBUG_LVL_10, "CnApi_initAsync: RX:%08x(%04x)\n", (unsigned int)pAsyncRxAdrs_p, wAsyncRxSize_p);

	/* initialize asynchronous buffers */
	pAsyncTxAdrs_l = pAsyncTxAdrs_p;
	wAsyncTxSize_l = wAsyncTxSize_p;
	pAsyncRxAdrs_l = pAsyncRxAdrs_p;
	wAsyncRxSize_l = wAsyncRxSize_p;

	bReqId_l = 0;
}

//tAsyncCallStatus Cn_Api_PostAsyncMsg(BYTE* pMsg_p, BOOL* fMsgPending)
//{
//    tAsyncCallStatus Ret = kAsyncCallStatusReady;
//    /* check if message is pending and has not been send before */
//    if(*fMsgPending == FALSE)
//    {
//        goto exit;                                     ///< ignore this message
//    }
//
//    /* check if buffer is occupied */
//    if(/*occupied*/)
//    {
//        *fMsgPending = TRUE;
//        Ret = kAsyncCallStatusPending;
//        goto exit;
//    }
//    /* check if message size fits in buffer */
//    if(/*msg size > buffer size*/) //TODO: auf mehrere Msgs aufsplitten, wenns nicht reinpasst
//    {
//        *fMsgPending = TRUE;
//        Ret = kAsyncCallStatusPending;
//        goto exit;
//    }
//
//
//    /* setup asynchronous message buffer */
//
//exit:
//    return Ret;
//}

/**
********************************************************************************
\brief	check asynchronous sync flag

CnApi_checkAsyncSyncFlag() is used to check the asynchronous sync flag.

\param		bDirection_p			asynchronous transfer direction to check flag for

\return		synchronization flag
*******************************************************************************/
BYTE CnApi_checkAsyncSyncFlag(BYTE bDirection_p)
{
	if (bDirection_p == kCnApiDirReceive)
		return pAsyncRxAdrs_l->m_header.m_bSync;
	else
		return pAsyncRxAdrs_l->m_header.m_bSync;
}

/**
********************************************************************************
\brief	execute an initPcp command

CnApi_doInitPcpReq() executes an initPcp command. The initialization parameters
stored in pInitParm_g will be copied to the initPcpReq message and transfered
to the PCP. Afterwards the function polls for a valid initPcpResp message from
the PCP.

\todo	function should be implemented as state machine to avoid polling and
		for answer and therefore blocking whole application!

\retval		ERROR		if an error occured
\retval		OK			if the call was successfully
*******************************************************************************/
int CnApi_doInitPcpReq(void)
{
	int					iStatus;
	tInitPcpReq			initPcpReq;
	tInitPcpResp		initPcpResp;
	WORD				wInitPcpRespLen;
	BOOL				fReady = FALSE;
	BYTE				bChannel;
	int					i;

	DEBUG_FUNC;

	/* build up InitPcpReq */
	memset (&initPcpReq, 0x00, sizeof(initPcpReq));
	memcpy (initPcpReq.m_abMac, pInitParm_g->m_abMac, sizeof(pInitParm_g->m_abMac));
	initPcpReq.m_dwDeviceType = pInitParm_g->m_dwDeviceType;
	initPcpReq.m_dwFeatureFlags = pInitParm_g->m_dwFeatureFlags;
	initPcpReq.m_dwNodeId = pInitParm_g->m_bNodeId;
	initPcpReq.m_dwRevision = pInitParm_g->m_dwRevision;
	initPcpReq.m_dwSerialNum = pInitParm_g->m_dwSerialNum;
	initPcpReq.m_dwVendorId = pInitParm_g->m_dwVendorId;
	initPcpReq.m_dwProductCode = pInitParm_g->m_dwProductCode;
	initPcpReq.m_dwAsendMaxLatency = pInitParm_g->m_dwAsendMaxLatency;
	initPcpReq.m_dwPresMaxLatency = pInitParm_g->m_dwPresMaxLatency;
	initPcpReq.m_wIsoRxMaxPayload = pInitParm_g->m_wIsoRxMaxPayload;
	initPcpReq.m_wIsoTxMaxPayload = pInitParm_g->m_wIsoTxMaxPayload;

	initPcpReq.m_bCmd = kAsyncCmdInitPcpReq;
	initPcpReq.m_bReqId = ++bReqId_l;

	if ((iStatus = CnApi_sendAsync(kAsyncChannelInternal, (tAsyncIntChan *)&initPcpReq,
			                      sizeof(initPcpReq), NULL, 0)) != kAsyncSendStatusOk)
	{
		return ERROR;
	}

	for (i = 0; i < MAX_ASYNC_TIMEOUT; i++)
	{
		usleep(10000);
		wInitPcpRespLen = sizeof(initPcpResp);
		iStatus = CnApi_receiveAsync(&bChannel, (tAsyncIntChan *)&initPcpResp, &wInitPcpRespLen);
		if (iStatus == kAsyncSendStatusBufEmpty)
			continue;

		if (iStatus == kAsyncSendStatusDataTooLong)
		{
			fReady = FALSE;
			break;
		}

		if (iStatus == kAsyncSendStatusOk)
		{
			fReady = TRUE;
			break;
		}
	}

	if (fReady)
	{
		DEBUG_TRACE1(DEBUG_LVL_10, "Timeout value: %d\n", i);
		if (bChannel != kAsyncChannelInternal)
		{
			return ERROR;
		}

		if (initPcpResp.m_bReqId != bReqId_l)
		{
			return ERROR;
		}

		DEBUG_TRACE1(DEBUG_LVL_10, "initPcpResp: status = %d\n", initPcpResp.m_wStatus);
		if (initPcpResp.m_wStatus == kCnApiStatusOk)
		{
			return OK;
		}
		else
		{
			return ERROR;
		}
	}
	else
	{
		return ERROR;
	}
}

/**
********************************************************************************
\brief	execute a createObj call

CnApi_doCreateObjLinksReq() executes a createObjectLinks Request command.

\todo	function should be implemented as state machine to avoid polling and
		for answer and therefore blocking whole application!

\retval		ERROR		if an error occured
\retval		OK			if the call was successfully
*******************************************************************************/
int CnApi_doCreateObjLinksReq(tCnApiObjId *pObjList_p, WORD wNumObjs_p)
{
	int					iStatus;
	tCreateObjLksReq	createObjLinksReq;                ///< local message storage
	tCreateObjLksResp	createObjLinksResp;               ///< local message storage
	WORD				wCreateObjLinksRespLen;
	BOOL				fReady = FALSE;
	BYTE				bChannel;
	int					i;
	WORD				wMaxObjs;
	WORD				wCurObjs;
	WORD				wReqObjs;
	tCnApiObjId			*pObj;

	DEBUG_FUNC;

	/* calculate maximum number of objects which can be created in one createObjLinksReq Call */
	wMaxObjs = (pCtrlReg_g->m_wTxAsyncBufSize - sizeof(createObjLinksReq)) / sizeof(tCnApiObjId);
	wCurObjs = (wNumObjs_p > wMaxObjs) ? wMaxObjs : wNumObjs_p;
	pObj = pObjList_p;
	wReqObjs = 0;

	while (wCurObjs > 0)
	{
		/* build up CreateObjReq */
		memset (&createObjLinksReq, 0x00, sizeof(createObjLinksReq));
		createObjLinksReq.m_wNumObjs = wCurObjs;

		createObjLinksReq.m_bCmd = kAsyncCmdCreateObjLinksReq;
		createObjLinksReq.m_bReqId = ++bReqId_l;
		DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Creating %d objects\n", wCurObjs);
		if ((iStatus = CnApi_sendAsync(kAsyncChannelInternal, (tAsyncIntChan *)&createObjLinksReq, sizeof(createObjLinksReq),
									   (char *)pObj, wCurObjs * sizeof(tCnApiObjId))) != kAsyncSendStatusOk)
		{
			return ERROR;
		}

		for (i = 0; i < MAX_ASYNC_TIMEOUT; i++)
		{
			usleep(10000);
			wCreateObjLinksRespLen = sizeof(createObjLinksResp);
			iStatus = CnApi_receiveAsync(&bChannel, (tAsyncIntChan *)&createObjLinksResp, &wCreateObjLinksRespLen);
			if (iStatus == kAsyncSendStatusBufEmpty)
			{
				continue;
			}

			if (iStatus == kAsyncSendStatusDataTooLong)
			{
				fReady = FALSE;
				break;
			}

			if (iStatus == kAsyncSendStatusOk)
			{
				fReady = TRUE;
				break;
			}
		}

		if (fReady)
		{
			DEBUG_TRACE1(DEBUG_LVL_10, "Timeout value: %d\n", i);
			if (bChannel != kAsyncChannelInternal)
			{
				return ERROR;
			}

			if (createObjLinksResp.m_bReqId != bReqId_l)
			{
				return ERROR;
			}

			DEBUG_TRACE1(DEBUG_LVL_10, "createObjLinksResp: status = %d\n", createObjLinksResp.m_wStatus);
			if (createObjLinksResp.m_wStatus == kCnApiStatusOk)
			{
				pObj = pObj + wCurObjs;
				wReqObjs += wCurObjs;
				wCurObjs = (wNumObjs_p - wReqObjs);
				wCurObjs = (wCurObjs > wMaxObjs) ? wMaxObjs : wCurObjs;
			}
			else
			{
				return ERROR;
			}
		}
		else
		{
			return ERROR;
		}
	}
	return OK;
}

/**
********************************************************************************
\brief	perform a writeObj command

CnApi_doWriteObjReq() executes a writeObj command.

\todo	function should be implemented as state machine to avoid polling and
		for answer and therefore blocking whole application!

\retval		ERROR		if an error occured
\retval		OK			if the call was successfully
*******************************************************************************/
int CnApi_doWriteObjReq(tCnApiObjId *pObjList_p, WORD wNumObjs_p)
{
	int					iStatus;
	tWriteObjReq		writeObjReq;
	tWriteObjResp		writeObjResp;
	WORD				wWriteObjRespLen;
	BOOL				fReady = FALSE;
	BYTE				bChannel;
	int					i;
	WORD				wMaxObjs;
	WORD				wCurObjs;
	WORD				wReqObjs;
	tCnApiObjId			*pObj;

	DEBUG_FUNC;

	/* calculate maximum number of objects which can be created in one createObjLinksReq Call */
	wMaxObjs = (pCtrlReg_g->m_wTxAsyncBufSize - sizeof(writeObjReq)) / sizeof(tCnApiObjId);
	wCurObjs = (wNumObjs_p > wMaxObjs) ? wMaxObjs : wNumObjs_p;
	pObj = pObjList_p;
	wReqObjs = 0;

	while (wCurObjs > 0)
	{
		/* build up CreateObjReq */
		memset (&writeObjReq, 0x00, sizeof(writeObjReq));
		writeObjReq.m_wNumObjs = wCurObjs;

		writeObjReq.m_bCmd = kAsyncCmdWriteObjReq;
		writeObjReq.m_bReqId = ++bReqId_l;
		DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Writing %d objects\n", wCurObjs);
		if ((iStatus = CnApi_sendAsync(kAsyncChannelInternal, (tAsyncIntChan *)&writeObjReq, sizeof(writeObjReq),
									   (char *)pObj, wCurObjs * sizeof(tCnApiObjId))) != kAsyncSendStatusOk)
		{
			return ERROR;
		}

		for (i = 0; i < MAX_ASYNC_TIMEOUT; i++)
		{
			usleep(10000);
			wWriteObjRespLen = sizeof(writeObjResp);
			iStatus = CnApi_receiveAsync(&bChannel, (tAsyncIntChan *)&writeObjResp, &wWriteObjRespLen);
			if (iStatus == kAsyncSendStatusBufEmpty)
			{
				continue;
			}

			if (iStatus == kAsyncSendStatusDataTooLong)
			{
				fReady = FALSE;
				break;
			}

			if (iStatus == kAsyncSendStatusOk)
			{
				fReady = TRUE;
				break;
			}
		}

		if (fReady)
		{
			DEBUG_TRACE1(DEBUG_LVL_10, "Timeout value: %d\n", i);
			if (bChannel != kAsyncChannelInternal)
			{
				return ERROR;
			}

			if (writeObjResp.m_bReqId != bReqId_l)
			{
				return ERROR;
			}

			DEBUG_TRACE1(DEBUG_LVL_10, "writeObjResp: status = %d\n", writeObjResp.m_wStatus);
			if (writeObjResp.m_wStatus == kCnApiStatusOk)
			{
				pObj = pObj + wCurObjs;
				wReqObjs += wCurObjs;
				wCurObjs = (wNumObjs_p - wReqObjs);
				wCurObjs = (wCurObjs > wMaxObjs) ? wMaxObjs : wCurObjs;
			}
			else
			{
				return ERROR;
			}
		}
		else
		{
			return ERROR;
		}
	}
	return OK;
}


/* END-OF-FILE */
/******************************************************************************/

