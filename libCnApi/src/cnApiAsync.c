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
#ifdef CN_API_USING_SPI
    #include "cnApiPdiSpi.h"
#endif

#include <string.h>
#include <unistd.h>
#include <stddef.h>

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

static tAsyncMsg		*pAsyncTxAdrs_l;
static WORD				wAsyncTxSize_l;
static tAsyncMsg		*pAsyncRxAdrs_l;
static WORD				wAsyncRxSize_l;
static BYTE				bReqId_l = 0;		///< asynchronous msg counter
static BYTE             bReqSeqnc = 0;      ///< CreateObjLinks sequence counter of split message

#ifdef CN_API_USING_SPI
/* shadow variables - copys of DPRAM */
static tAsyncMsg            ShadAsyncTxMsg_l;
static tAsyncMsg            ShadAsyncRxMsg_l;
#endif /* CN_API_USING_SPI */

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
tAsyncSendStatus CnApi_sendAsync(BYTE bChannel_p, tAsyncIntChan *pData_p, WORD wMsgHdrLen_p,
		            char *pPayload_p, WORD wPayloadLen_p)
{
    size_t Offset;
	char  *pDest;

#ifdef CN_API_USING_SPI
    /* update local shadow AsyncTxMsg header (pAsyncTxAdrs_l points to ShadAsyncTxMsg_l) */
	Offset = offsetof(tAsyncMsg, m_header.m_bSync);
    CnApi_Spi_read(PCP_CTRLREG_TX_ASYNC_OFST_OFFSET + Offset, sizeof(pAsyncTxAdrs_l->m_header.m_bSync), (BYTE*) &ShadAsyncTxMsg_l + Offset);
#endif

    /* check if buffer is free */
	if (pAsyncTxAdrs_l->m_header.m_bSync == kMsgBufReadOnly)
		return kAsyncSendStatusBufFull;

	/* check if data length is too big */
	if (wMsgHdrLen_p > (wAsyncTxSize_l - sizeof(tAsyncMsgHeader)))
		return kAsyncSendStatusDataTooLong;

	pDest = (char *)&pAsyncTxAdrs_l->m_chan.m_intChan;
	/* copy data to msg buffer */
#ifdef CN_API_USING_SPI
	Offset = offsetof(tAsyncMsg, m_chan.m_intChan);
    CnApi_Spi_write(PCP_CTRLREG_TX_ASYNC_OFST_OFFSET + Offset, wMsgHdrLen_p, (BYTE*) pData_p);  ///< write payload to PCP DPRAM
#else
    memcpy(pDest, pData_p, wMsgHdrLen_p);
#endif


	/* check if we have to copy additional payload data */
	if (pPayload_p != NULL)
	{
#ifdef CN_API_USING_SPI
    CnApi_Spi_write(PCP_CTRLREG_TX_ASYNC_OFST_OFFSET + Offset + wMsgHdrLen_p, wPayloadLen_p, (BYTE*) pPayload_p);  ///< write payload to PCP DPRAM
#else
    memcpy(pDest + wMsgHdrLen_p, (char *)pPayload_p, wPayloadLen_p);
#endif /* CN_API_USING_SPI */
	}

	/* write message header */
	pAsyncTxAdrs_l->m_header.m_wFrgmtLen = wMsgHdrLen_p; // Todo: + wPayloadLen_p ?
	pAsyncTxAdrs_l->m_header.m_bChannel = bChannel_p;
	pAsyncTxAdrs_l->m_header.m_bSync = kMsgBufWriteOnly;

#ifdef CN_API_USING_SPI
	Offset = offsetof(tAsyncMsg, m_header);
    CnApi_Spi_write(PCP_CTRLREG_TX_ASYNC_OFST_OFFSET + Offset, sizeof(pAsyncTxAdrs_l->m_header), (BYTE*) &ShadAsyncTxMsg_l.m_header);  ///< update PCP DPRAM with local shadow data
#endif

    pAsyncTxAdrs_l->m_header.m_bSync = kMsgBufReadOnly;

#ifdef CN_API_USING_SPI
    Offset = offsetof(tAsyncMsg, m_header.m_bSync);
    CnApi_Spi_write(PCP_CTRLREG_TX_ASYNC_OFST_OFFSET + Offset, sizeof(pAsyncTxAdrs_l->m_header.m_bSync), (BYTE*) &ShadAsyncTxMsg_l.m_header.m_bSync);  ///< write SyncFlag to PCP DPRAM
#endif

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
#ifdef CN_API_USING_SPI
    size_t Offset;

    Offset = offsetof(tAsyncMsg, m_header);
    CnApi_Spi_read(PCP_CTRLREG_RX_ASYNC_OFST_OFFSET + Offset, sizeof(pAsyncRxAdrs_l->m_header), (BYTE*) &ShadAsyncRxMsg_l.m_header);
    /* update local shadow AsyncRxMsg header (pAsyncRxAdrs_l points to ShadAsyncRxMsg_l) */
#endif

	/* check if buffer contains a message for us */
	if (pAsyncRxAdrs_l->m_header.m_bSync == kMsgBufWriteOnly)
		return kAsyncSendStatusBufEmpty;

	/* check if the response buffer is big enough to store the answer */
	if (pAsyncRxAdrs_l->m_header.m_wFrgmtLen > *pLen_p)
		return kAsyncSendStatusDataTooLong;

	/* copy data from msg buffer */
#ifdef CN_API_USING_SPI
    Offset = offsetof(tAsyncMsg, m_chan.m_intChan);
    /* update local shadow AsyncRxMsg header (pAsyncRxAdrs_l points to ShadAsyncRxMsg_l) */
    CnApi_Spi_read(PCP_CTRLREG_RX_ASYNC_OFST_OFFSET + Offset, pAsyncRxAdrs_l->m_header.m_wFrgmtLen, (BYTE*) pData_p);
#else
	memcpy(pData_p, &pAsyncRxAdrs_l->m_chan.m_intChan, pAsyncRxAdrs_l->m_header.m_wFrgmtLen);
#endif /* CN_API_USING_SPI */

	/* read async message header information */
	*pChannel_p = pAsyncRxAdrs_l->m_header.m_bChannel;    ///< return info about channel type
	*pLen_p = pAsyncRxAdrs_l->m_header.m_wFrgmtLen;       ///< return info about copied data

	/* reset sync flag */
	pAsyncRxAdrs_l->m_header.m_bSync = kMsgBufWriteOnly;

#ifdef CN_API_USING_SPI
    Offset = offsetof(tAsyncMsg, m_header.m_bSync);
    CnApi_Spi_write(PCP_CTRLREG_RX_ASYNC_OFST_OFFSET + Offset, sizeof(pAsyncRxAdrs_l->m_header.m_bSync), (BYTE*) &ShadAsyncRxMsg_l.m_header.m_bSync);  ///< write SyncFlag to PCP DPRAM
#endif

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
	/* initialize asynchronous buffers */
	pAsyncTxAdrs_l = pAsyncTxAdrs_p;
	wAsyncTxSize_l = wAsyncTxSize_p;
	pAsyncRxAdrs_l = pAsyncRxAdrs_p;
	wAsyncRxSize_l = wAsyncRxSize_p;

    DEBUG_LVL_CNAPI_INFO_TRACE3("%s: Async Tx buffer adrs. %08x (size %d)\n",
                                        __func__, (unsigned int)pAsyncTxAdrs_l, wAsyncTxSize_l);
    DEBUG_LVL_CNAPI_INFO_TRACE3("%s: Async Rx buffer adrs. %08x (size %d)\n",
                                        __func__, (unsigned int)pAsyncRxAdrs_l, wAsyncRxSize_l);

#ifdef CN_API_USING_SPI
	/* check if buffer offset is valid */
    if ((pAsyncTxAdrs_l == NULL)  ||
        (pAsyncRxAdrs_l ==  NULL)   )
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "\nError in %s: initializing async PCP PDI failed!\n\n", __func__);
        goto exit;
    }

/* switch pointer to local copy instead of direct DPRAM access */
	pAsyncTxAdrs_l = &ShadAsyncTxMsg_l;
	pAsyncRxAdrs_l = &ShadAsyncRxMsg_l;
#endif /* CN_API_USING_SPI */

    if ((pAsyncTxAdrs_l == NULL)  ||
        (wAsyncTxSize_l == 0)     ||
        (pAsyncRxAdrs_l ==  NULL) ||
        (wAsyncRxSize_l == 0)       )
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "\nError in %s: initializing async PCP PDI failed!\n\n", __func__);
        goto exit;
    }
    else
    {

    }

	bReqId_l = 0;  ///< reset asynchronous sequence number

exit:
    return;
}

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
		{
			continue; /* run into timeout */
		}
		if(iStatus == kAsyncSendStatusDataTooLong)
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
		DEBUG_TRACE1(DEBUG_LVL_10, "InitPcpResponse received. Timeout value: %d\n", i);
		if (bChannel != kAsyncChannelInternal)
		{
	        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Wrong channel type receiced!\n");
			return ERROR;
		}

		if (initPcpResp.m_bReqId != bReqId_l)
		{
	        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Unexpected initPcpReq ID!\n");
			return ERROR;
		}

		DEBUG_TRACE1(DEBUG_LVL_10, "initPcpResp: status = %d\n", initPcpResp.m_wStatus);
		if (initPcpResp.m_wStatus == kCnApiStatusOk)
		{
			return OK;
		}
		else
		{
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "PCP returned error while doing initPcpReq!\n");
			return ERROR;
		}
	}
	else
	{
	    /* MAX_ASYNC_TIMEOUT exceeded */
	    DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "TIMEOUT: PCP does not respond!\n");
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
	tCreateObjLksReq	createObjLinksReq;            ///< local message storage
	tCreateObjLksResp	createObjLinksResp;           ///< local message storage
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
	wMaxObjs = (pCtrlReg_g->m_wTxAsyncBuf0Size - sizeof(createObjLinksReq)) / sizeof(tCnApiObjId);
	wCurObjs = (wNumObjs_p > wMaxObjs) ? wMaxObjs : wNumObjs_p;
	pObj = pObjList_p;
	wReqObjs = 0;

	while (wCurObjs > 0)
	{
	    // check if PCP restriction is not exceeded
        if (OBJ_CREATE_LINKS_REQ_MAX_SEQ < bReqSeqnc)
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: Linkable objects limited to %d! Linking stopped!\n", MAX_LINKABLE_OBJCS);
            return ERROR;
        }

		/* build up CreateObjReq */
		memset (&createObjLinksReq, 0x00, sizeof(createObjLinksReq));
		createObjLinksReq.m_wNumObjs = wCurObjs;
		createObjLinksReq.m_bCmd = kAsyncCmdCreateObjLinksReq;
		createObjLinksReq.m_bReqId = ++bReqId_l;
		bReqSeqnc++;

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
                DEBUG_TRACE3(DEBUG_LVL_CNAPI_ERR, "ERROR in %s: 0x%04x/0x%02x does not exist or has invalid size!\n"
                             "NO OBJECTS WILL BE LINKED!\n\n", __func__, createObjLinksResp.m_wErrIndex, createObjLinksResp.m_bErrSubindex);
                pObjList_p->m_bNumEntries = 0; ///< reset counter, so copy table won't be set up
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
	wMaxObjs = (pCtrlReg_g->m_wTxAsyncBuf0Size - sizeof(writeObjReq)) / sizeof(tCnApiObjId);
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
	             DEBUG_TRACE3(DEBUG_LVL_CNAPI_ERR, "ERROR in %s: 0x%04x/0x%02x does not exist or has invalid size!\n"
	                          , __func__, writeObjResp.m_wErrIndex, writeObjResp.m_bErrSubindex);
	             pObjList_p->m_bNumEntries = 0; ///< reset counter, so copy table won't be set up
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

