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
#include "cnApiAsync.h"
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
tPcpPdiAsyncMsgBufDescr aPcpPdiAsyncTxMsgBuffer_g[PDI_ASYNC_CHANNELS_MAX];
tPcpPdiAsyncMsgBufDescr aPcpPdiAsyncRxMsgBuffer_g[PDI_ASYNC_CHANNELS_MAX];


/******************************************************************************/
/* global variables */
static BYTE				bReqId_l = 0;		///< asynchronous msg counter
#ifdef CN_API_USING_SPI
static tAsyncMsg LclCpyAsyncMsgHeader_l[4]; ///< local copy of asynchronous PDI message header
#endif

/******************************************************************************/
/* function declarations */


/******************************************************************************/
/* private functions */
static tPdiAsyncStatus CnApiAsync_initInternalMsgs(void);

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  initialize asynchronous functions
*******************************************************************************/
int CnApiAsync_init(void)
{
    register WORD wCnt;
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;

#ifdef CN_API_USING_SPI
    aPcpPdiAsyncTxMsgBuffer_g[0].pAdr_m = &LclCpyAsyncMsgHeader_l[0];
    aPcpPdiAsyncRxMsgBuffer_g[0].pAdr_m = &LclCpyAsyncMsgHeader_l[1];
    aPcpPdiAsyncTxMsgBuffer_g[1].pAdr_m = &LclCpyAsyncMsgHeader_l[2];
    aPcpPdiAsyncRxMsgBuffer_g[1].pAdr_m = &LclCpyAsyncMsgHeader_l[3];

    aPcpPdiAsyncTxMsgBuffer_g[0].wPdiOffset_m = PCP_CTRLREG_TX_ASYNC_BUF0_OFST_OFFSET;
    aPcpPdiAsyncRxMsgBuffer_g[0].wPdiOffset_m = PCP_CTRLREG_RX_ASYNC_BUF0_OFST_OFFSET;
    aPcpPdiAsyncTxMsgBuffer_g[1].wPdiOffset_m = PCP_CTRLREG_TX_ASYNC_BUF1_OFST_OFFSET;
    aPcpPdiAsyncRxMsgBuffer_g[1].wPdiOffset_m = PCP_CTRLREG_RX_ASYNC_BUF1_OFST_OFFSET;
#else
    aPcpPdiAsyncTxMsgBuffer_g[0].pAdr_m = (tAsyncMsg *) (pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wTxAsyncBuf0Aoffs);
    aPcpPdiAsyncRxMsgBuffer_g[0].pAdr_m = (tAsyncMsg *) (pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wRxAsyncBuf0Aoffs);
    aPcpPdiAsyncTxMsgBuffer_g[1].pAdr_m = (tAsyncMsg *) (pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wTxAsyncBuf1Aoffs);
    aPcpPdiAsyncRxMsgBuffer_g[1].pAdr_m = (tAsyncMsg *) (pInitParm_g->m_dwDpramBase + pCtrlReg_g->m_wRxAsyncBuf1Aoffs);
#endif /* CN_API_USING_SPI */

    aPcpPdiAsyncTxMsgBuffer_g[0].wMaxPayload_m = pCtrlReg_g->m_wTxAsyncBuf0Size - sizeof(tAsyncPdiBufCtrlHeader);
    aPcpPdiAsyncRxMsgBuffer_g[0].wMaxPayload_m = pCtrlReg_g->m_wRxAsyncBuf0Size - sizeof(tAsyncPdiBufCtrlHeader);
    aPcpPdiAsyncTxMsgBuffer_g[1].wMaxPayload_m = pCtrlReg_g->m_wTxAsyncBuf1Size - sizeof(tAsyncPdiBufCtrlHeader);
    aPcpPdiAsyncRxMsgBuffer_g[1].wMaxPayload_m = pCtrlReg_g->m_wRxAsyncBuf1Size - sizeof(tAsyncPdiBufCtrlHeader);

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

    bReqId_l = 0;  ///< reset asynchronous sequence number

    Ret = CnApiAsync_initInternalMsgs();
    if (Ret != kPdiAsyncStatusSuccessful)
    {
        goto exit;
    }

    CnApiAsync_finishMsgInit();
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
static tPdiAsyncStatus CnApiAsync_initInternalMsgs(void)
{
    tPcpPdiAsyncDir Dir;
    tPcpPdiAsyncMsgBufDescr * pPdiBuf = NULL;
    tPdiAsyncTransferType TfrTyp;
    tAsyncChannel ChanType_p;
    tPcpStates * pNmtList = NULL;
    WORD wTout = 0;
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;

    /* Tx messages */
    Dir = kCnApiDirTransmit;
    pPdiBuf = &aPcpPdiAsyncTxMsgBuffer_g[0];

#ifdef CN_API_USING_SPI
    TfrTyp = kPdiAsyncTrfTypeLclBuffering; // has to be buffered locally if serial interface is used
#else
    TfrTyp = kPdiAsyncTrfTypeDirectAccess; // use only, if message size will not exceed the PDI buffer
#endif /* CN_API_USING_SPI */

    ChanType_p = kAsyncChannelInternal;
    pNmtList = NULL;
    wTout = 100;

    Ret = CnApiAsync_initMsg(kPdiAsyncMsgIntInitPcpReq, Dir, CnApi_doInitPcpReq, pPdiBuf,
                              kPdiAsyncMsgIntInitPcpResp, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    TfrTyp = kPdiAsyncTrfTypeLclBuffering;

    CnApiAsync_initMsg(kPdiAsyncMsgIntCreateObjLinksReq, Dir, CnApi_doCreateObjLinksReq, pPdiBuf,
                        kPdiAsyncMsgIntCreateObjLinksResp, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

#ifdef CN_API_USING_SPI
#else
    TfrTyp = kPdiAsyncTrfTypeDirectAccess; // use only, if message size will not exceed the PDI buffer
#endif /* CN_API_USING_SPI */


    CnApiAsync_initMsg(kPdiAsyncMsgIntWriteObjReq, Dir, CnApi_doWriteObjReq, pPdiBuf,
                        kPdiAsyncMsgIntWriteObjResp, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    //TODO: cnApiAsync_initMsg(kPdiAsyncMsgIntReadObjReq, Dir, ...);
    //if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    /* Rx messages */
    Dir = kCnApiDirReceive;
#ifdef CN_API_USING_SPI
    TfrTyp = kPdiAsyncTrfTypeLclBuffering; // has to be buffered locally if serial interface is used
#else
    TfrTyp = kPdiAsyncTrfTypeAutoDecision;; // transfer type doesn't matter -> chosen according to Rx messsage size
#endif /* CN_API_USING_SPI */

    pPdiBuf = &aPcpPdiAsyncRxMsgBuffer_g[0];

    CnApiAsync_initMsg(kPdiAsyncMsgIntInitPcpResp, Dir, CnApi_handleInitPcpResp, pPdiBuf,
                        kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntCreateObjLinksResp, Dir, CnApi_handleCreateObjLinksResp, pPdiBuf,
                        kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntWriteObjResp, Dir, CnApi_handleWriteObjResp, pPdiBuf,
                        kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntLinkPdosReq, Dir, CnApi_handleLinkPdosReq , pPdiBuf,
                        kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

exit:
    return Ret;
}

/**
********************************************************************************
\brief  setup an InitPcpReq command
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value

CnApi_doInitPcpReq() executes an initPcp command. The initialization parameters
stored in pInitParm_g will be copied to the initPcpReq message and transfered
to the PCP. Afterwards the function polls for a valid initPcpResp message from
the PCP.
*******************************************************************************/
tPdiAsyncStatus CnApi_doInitPcpReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pTxMsgBuffer_p,
                                   BYTE* pRxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tInitPcpReq *      pInitPcpReq = NULL;        ///< pointer to message (Tx)
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
    if (pTxMsgBuffer_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* check if expected Tx message size exceeds the buffer */
    if ( sizeof(tInitPcpReq) > dwMaxTxBufSize_p)
    {
        /* reject transfer, because direct access can not be processed */
        Ret = kPdiAsyncStatusDataTooLong;
        goto exit;
    }

    /* assign buffer payload addresses */
    pInitPcpReq = (tInitPcpReq *) pTxMsgBuffer_p;    // Tx buffer

    /* handle Tx Message */
    /* build up InitPcpReq */
    memset (pInitPcpReq, 0x00, sizeof(pInitPcpReq));
    memcpy (&pInitPcpReq->m_abMac, pInitParm_g->m_abMac, sizeof(pInitParm_g->m_abMac));
    pInitPcpReq->m_dwDeviceType = pInitParm_g->m_dwDeviceType;
    pInitPcpReq->m_dwFeatureFlags = pInitParm_g->m_dwFeatureFlags;
    pInitPcpReq->m_dwNodeId = pInitParm_g->m_bNodeId;
    pInitPcpReq->m_dwRevision = pInitParm_g->m_dwRevision;
    pInitPcpReq->m_dwSerialNum = pInitParm_g->m_dwSerialNum;
    pInitPcpReq->m_dwVendorId = pInitParm_g->m_dwVendorId;
    pInitPcpReq->m_dwProductCode = pInitParm_g->m_dwProductCode;
    pInitPcpReq->m_dwAsendMaxLatency = pInitParm_g->m_dwAsendMaxLatency;
    pInitPcpReq->m_dwPresMaxLatency = pInitParm_g->m_dwPresMaxLatency;
    pInitPcpReq->m_wIsoRxMaxPayload = pInitParm_g->m_wIsoRxMaxPayload;
    pInitPcpReq->m_wIsoTxMaxPayload = pInitParm_g->m_wIsoTxMaxPayload;

    pInitPcpReq->m_bReqId = ++bReqId_l;

    /* update size values of message descriptors */
    pMsgDescr_p->dwMsgSize_m = sizeof(tInitPcpReq); // sent size

exit:
    return Ret;
}

/**
********************************************************************************
\brief  setup a CreateObjLinksReq command
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value

CnApi_doCreateObjLinksReq() executes a createObjectLinks Request command.
*******************************************************************************/
tPdiAsyncStatus CnApi_doCreateObjLinksReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pTxMsgBuffer_p,
                                   BYTE* pRxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tCreateObjLksReq *  pCreateObjLksReq = NULL;        ///< pointer to message (Tx)
    tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;
    tCnApiObjCreateObjLinksHdl * pMsgHdl;
    char *              pDest;
    char *              pData;
    DWORD               dwDataLenght;
    WORD                wMaxObjs;

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
    if (pTxMsgBuffer_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* verify message handle presence */
    if (pMsgDescr_p->pUserHdl_m == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* check if object list pointer is assigned */
    if (pMsgHdl->pObj_m == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* check if expected Tx message size exceeds the buffer */
    if ( sizeof(tCreateObjLksReq) > dwMaxTxBufSize_p)
    {
        /* reject transfer, because direct access can not be processed */
        Ret = kPdiAsyncStatusDataTooLong;
        goto exit;
    }

    /* check if local buffer is assigned (only this transfer method is allowed for now) */
    if (pMsgDescr_p->MsgHdl_m.pLclBuf_m == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* assign same handle to response message */
    pMsgDescr_p->pRespMsgDescr_m->pUserHdl_m = pMsgDescr_p->pUserHdl_m;

    switch (pMsgDescr_p->TransfType_m)
    {
        case kPdiAsyncTrfTypeDirectAccess:
        {
            /* assign buffer payload addresses */
             pCreateObjLksReq = (tCreateObjLksReq *) pTxMsgBuffer_p;    // Tx buffer
             break;
        }

        case kPdiAsyncTrfTypeLclBuffering:
        {
            pCreateObjLksReq = (tCreateObjLksReq *) pMsgDescr_p->MsgHdl_m.pLclBuf_m; // Tx buffer
            break;
        }

        default:
        {
            Ret = kPdiAsyncStatusInvalidInstanceParam;
            goto exit;
        }

    }

    /* handle Tx Message */
    /* build up CreateObjLksReq */
    pMsgHdl = (tCnApiObjCreateObjLinksHdl *) pMsgDescr_p->pUserHdl_m;

    /* calculate maximum number of objects which can be created in one createObjLinksReq Call */
    wMaxObjs = (dwMaxTxBufSize_p - sizeof(pCreateObjLksReq)) / sizeof(tCnApiObjId);

    if (pMsgHdl->wCurObjs_m == 0)// indicates first call of this function
    {
        pMsgHdl->wCurObjs_m = (pMsgHdl->wNumCreateObjs_m > wMaxObjs) ? wMaxObjs : pMsgHdl->wNumCreateObjs_m; //cap count of objects to be sent
    }
    else // there are objects left to be created  from last call
    {
        pMsgHdl->wCurObjs_m = (pMsgHdl->wCurObjs_m > wMaxObjs) ? wMaxObjs : pMsgHdl->wCurObjs_m; //cap count of objects to be sent
    }

    if (pMsgHdl->wCurObjs_m <= 0)
    {
        // no objects to be created -> exit;
        
        /* setup message header */
        pCreateObjLksReq->m_wNumObjs = pMsgHdl->wCurObjs_m;
        pCreateObjLksReq->m_bReqId = ++bReqId_l; 
        goto exit;
    }

    /* build up CreateObjReq */
    pDest = (char *) (pCreateObjLksReq + 1); // payload destination address of this message
    pData = (char *) pMsgHdl->pObj_m;        // payload source address
    dwDataLenght = pMsgHdl->wCurObjs_m * sizeof(tCnApiObjId); //payload lenght

    DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Creating %d objects\n", pMsgHdl->wCurObjs_m);

    memcpy(pDest, pData, dwDataLenght); // copy payload

    /* setup message header */
    pCreateObjLksReq->m_wNumObjs = pMsgHdl->wCurObjs_m;
    pCreateObjLksReq->m_bReqId = ++bReqId_l;

    /* update size values of message descriptors */
    pMsgDescr_p->dwMsgSize_m = sizeof(tCreateObjLksReq) + dwDataLenght; // sent size

exit:
    return Ret;
}

/**
********************************************************************************
\brief  setup an doWriteObjReq command
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value

This function executes an doWriteObjReq command.
*******************************************************************************/
tPdiAsyncStatus CnApi_doWriteObjReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pTxMsgBuffer_p,
                                   BYTE* pRxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tWriteObjReq *     pWriteObjReq = NULL;        ///< pointer to message (Tx)
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
    if (pTxMsgBuffer_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* check if expected Tx message size exceeds the buffer */
    if ( sizeof(tWriteObjReq) > dwMaxTxBufSize_p)
    {
        /* reject transfer, because direct access can not be processed */
        Ret = kPdiAsyncStatusDataTooLong;
        goto exit;
    }

    /* assign buffer payload addresses */
    pWriteObjReq = (tWriteObjReq *) pTxMsgBuffer_p;    // Tx buffer

    /* handle Tx Message */
    /* build up WriteObjReq */

    //TODO

    pWriteObjReq->m_bReqId = ++bReqId_l;

    /* update size values of message descriptors */
    pMsgDescr_p->dwMsgSize_m = sizeof(tWriteObjReq); // sent size

exit:
    return Ret;
}

/**
********************************************************************************
\brief  handle an initPcpResp
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
tPdiAsyncStatus CnApi_handleInitPcpResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                        BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tInitPcpResp *     pInitPcpResp = NULL;       ///< pointer to response message (Rx)
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
    pInitPcpResp = (tInitPcpResp *) pRxMsgBuffer_p;    // Rx buffer

    /* handle Rx Message */
    DEBUG_TRACE0(DEBUG_LVL_10, "InitPcpResponse received.\n");
    if (pInitPcpResp->m_bReqId != bReqId_l)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Unexpected Request ID!\n");
        Ret = kPdiAsyncStatusRespError;
        goto exit;
    }

    DEBUG_TRACE1(DEBUG_LVL_10, "initPcpResp: status = %d\n", pInitPcpResp->m_wStatus);
    if (pInitPcpResp->m_wStatus == kCnApiStatusOk)
    {
        goto exit;
    }
    else
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "PCP returned error while doing initPcpReq!\n");
        Ret = kPdiAsyncStatusRespError;
        goto exit;
    }


exit:
    return Ret;
}

/**
********************************************************************************
\brief  handle an CreateObjLinksResp
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
tPdiAsyncStatus CnApi_handleCreateObjLinksResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                        BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tCreateObjLksResp * pCreateObjLksResp = NULL;       ///< pointer to response message (Rx)
    tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;
    tCnApiObjCreateObjLinksHdl * pMsgHdl;

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
    pCreateObjLksResp = (tCreateObjLksResp *) pRxMsgBuffer_p;    // Rx buffer

    /* handle Rx Message */
    if (pCreateObjLksResp->m_bReqId != bReqId_l)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Unexpected Request ID!\n");
        Ret = kPdiAsyncStatusRespError;
        goto exit;
    }

    /* verify message handle presence */
    if (pMsgDescr_p->pUserHdl_m == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    DEBUG_TRACE1(DEBUG_LVL_10, "createObjLinksResp: status = %d\n", pCreateObjLksResp->m_wStatus);
    if (pCreateObjLksResp->m_wStatus == kCnApiStatusOk)
    {
        pMsgHdl = (tCnApiObjCreateObjLinksHdl *) pMsgDescr_p->pUserHdl_m;

        pMsgHdl->pObj_m = pMsgHdl->pObj_m + pMsgHdl->wCurObjs_m; // prepare object list pointer for next sending
        pMsgHdl->wReqObjs_m += pMsgHdl->wCurObjs_m;              // count finished requests
        pMsgHdl->wCurObjs_m = pMsgHdl->wNumCreateObjs_m - pMsgHdl->wReqObjs_m; //set new number of objects to be created
    }
    else
    { /* handle link error */
        DEBUG_TRACE3(DEBUG_LVL_CNAPI_ERR, "ERROR in %s: 0x%04x/0x%02x does not exist or has invalid size!\n"
                     "NO OBJECTS WILL BE LINKED!\n\n", __func__, pCreateObjLksResp->m_wErrIndex, pCreateObjLksResp->m_bErrSubindex);
        Ret = kPdiAsyncStatusRespError;
        goto exit;
    }

    exit:
        return Ret;
}

/**
 ********************************************************************************
 \brief call back function, invoked if InitPcpResp has finished
 \param  pMsgDescr_p         pointer to asynchronous message descriptor
 \return Ret                 tPdiAsyncStatus value

 This function triggers an CMD_INIT which will be sent to the PCP

 *******************************************************************************/
tPdiAsyncStatus CnApi_pfnCbInitPcpRespFinished (struct sPdiAsyncMsgDescr * pMsgDescr_p)
{
        CnApi_setApCommand(kApCmdInit);

        return kPdiAsyncStatusSuccessful;
}

/**
 ********************************************************************************
 \brief	call back function, invoked if CreateObjectLinksResponse has finished
 \param  pMsgDescr_p         pointer to asynchronous message descriptor
 \return Ret                 tPdiAsyncStatus value

 This function triggers an subsequent call of CnApi_doCreateObjLinksReq()
 if not all objects contained in aObjLinkTbl_l (cnApiObjects.c) have been created.

 *******************************************************************************/
tPdiAsyncStatus CnApi_pfnCbCreateObjLinksRespFinished (struct sPdiAsyncMsgDescr * pMsgDescr_p)
{
    tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;
    tCnApiObjCreateObjLinksHdl * pMsgHdl;

    pMsgHdl = (tCnApiObjCreateObjLinksHdl *) pMsgDescr_p->pUserHdl_m;

    if (pMsgHdl->wCurObjs_m > 0)
    {/* create remaining objects */
       Ret = CnApiAsync_postMsg(kPdiAsyncMsgIntCreateObjLinksReq,
                                (BYTE *) pMsgHdl,
                                NULL,
                                CnApi_pfnCbCreateObjLinksRespFinished);
       if (Ret != kPdiAsyncStatusSuccessful)
       {
           goto exit;
       }

    }
    else
    {/* no more objects to be created at PCP side -> issue CMD_PREOP to PCP */
        CnApi_setApCommand(kApCmdPreop);
        goto exit;
    }

    exit:
        return Ret;
}



/**
********************************************************************************
\brief  handle an WriteObjResp
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
tPdiAsyncStatus CnApi_handleWriteObjResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                        BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tWriteObjResp *    pWriteObjResp = NULL;       ///< pointer to response message (Rx)
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
    pWriteObjResp = (tWriteObjResp *) pRxMsgBuffer_p;    // Rx buffer

    /* handle Rx Message */
    // TODO


    exit:
        return Ret;
}


/* END-OF-FILE */
/******************************************************************************/

