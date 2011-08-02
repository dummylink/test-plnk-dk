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
#include "EplErrDef.h"
#include "user/EplSdoComu.h"
#ifdef CN_API_USING_SPI
    #include "cnApiPdiSpi.h"
#endif

#ifdef AP_IS_BIG_ENDIAN
   #include "EplAmi.h"
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
static tPdiAsyncStatus CnApiAsync_doObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pMsgBuffer_p,
                                                     BYTE * pRespMsgBuffer_p, DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus CnApiAsync_handleObjAccReq(
                       tPdiAsyncMsgDescr * pMsgDescr_p,
                       BYTE * pRxMsgBuffer_p,
                       BYTE * pTxMsgBuffer_p,
                       DWORD dwMaxTxBufSize_p);

#ifdef AP_IS_BIG_ENDIAN
static inline void ConvertInitPcpRespEndian(tInitPcpResp* pDest, tInitPcpResp* pSrc) {
   pDest->m_bReqId = pSrc->m_bReqId;
   pDest->m_wStatus = AmiGetWordToLe((BYTE*)&(pSrc->m_wStatus));
}
static inline void ConvertCreateObjLksRespEndian(tCreateObjLksResp* pDest, tCreateObjLksResp* pSrc) {
   pDest->m_bErrSubindex = pSrc->m_bErrSubindex;
   pDest->m_bReqId = pSrc->m_bReqId;
   pDest->m_wErrIndex = AmiGetWordToLe((BYTE*)&(pSrc->m_wErrIndex));
   pDest->m_wStatus = AmiGetWordToLe((BYTE*)&(pSrc->m_wStatus));
}
#endif //AP_IS_BIG_ENDIAN

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
    TfrTyp = kPdiAsyncTrfTypeLclBuffering; // for large messages
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
    TfrTyp = kPdiAsyncTrfTypeLclBuffering; // has to be buffered locally if serial interface is used
#else
    TfrTyp = kPdiAsyncTrfTypeDirectAccess; // use only, if message size will not exceed the PDI buffer
#endif /* CN_API_USING_SPI */

    CnApiAsync_initMsg(kPdiAsyncMsgIntLinkPdosResp, Dir, CnApi_doLinkPdosResp, pPdiBuf,
                       kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

#ifdef CN_API_USING_SPI
    TfrTyp = kPdiAsyncTrfTypeLclBuffering; // has to be buffered locally if serial interface is used
#else
//    TfrTyp = kPdiAsyncTrfTypeLclBuffering;; // use only, if message size will not exceed the PDI buffer
#endif /* CN_API_USING_SPI */

    CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccResp, Dir, CnApiAsync_doObjAccReq, &aPcpPdiAsyncTxMsgBuffer_g[1],
                        kPdiAsyncMsgInvalid, kPdiAsyncTrfTypeLclBuffering, kAsyncChannelSdo, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    //TODO: This is blocking asynchronous traffic, because it waits for a response
    //      Issue: ReqId has to be saved somehow (= another handle history)
    CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccReq, Dir, CnApiAsync_doObjAccReq, &aPcpPdiAsyncTxMsgBuffer_g[1],
                        kPdiAsyncMsgIntObjAccResp, kPdiAsyncTrfTypeLclBuffering, kAsyncChannelSdo, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

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

    CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccResp, Dir, CnApiAsync_handleObjAccReq, &aPcpPdiAsyncRxMsgBuffer_g[1],
                        kPdiAsyncMsgInvalid, kPdiAsyncTrfTypeLclBuffering, kAsyncChannelSdo, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccReq, Dir, CnApiAsync_handleObjAccReq, &aPcpPdiAsyncRxMsgBuffer_g[1],
                        kPdiAsyncMsgInvalid, kPdiAsyncTrfTypeLclBuffering, kAsyncChannelSdo, pNmtList, wTout);

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
    memcpy (&pInitPcpReq->m_abMac, pInitParmLE_g->m_abMac, sizeof(pInitParmLE_g->m_abMac));
    pInitPcpReq->m_dwDeviceType = pInitParmLE_g->m_dwDeviceType;
    pInitPcpReq->m_dwNodeId = pInitParmLE_g->m_bNodeId;
    pInitPcpReq->m_dwRevision = pInitParmLE_g->m_dwRevision;
    pInitPcpReq->m_dwSerialNum = pInitParmLE_g->m_dwSerialNum;
    pInitPcpReq->m_dwVendorId = pInitParmLE_g->m_dwVendorId;
    pInitPcpReq->m_dwProductCode = pInitParmLE_g->m_dwProductCode;

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
#ifdef AP_IS_LITTLE_ENDIAN
        pCreateObjLksReq->m_wNumObjs = pMsgHdl->wCurObjs_m;
#else // AP_IS_BIG_ENDIAN
        pCreateObjLksReq->m_wNumObjs = AmiGetWordToLe(&pMsgHdl->wCurObjs_m);
#endif // AP_IS_LITTLE_ENDIAN
        pCreateObjLksReq->m_bReqId = ++bReqId_l; 
        goto exit;
    }
    /* build up CreateObjReq */
    pDest = (char *) (pCreateObjLksReq + 1); // payload destination address of this message
    pData = (char *) pMsgHdl->pObj_m;        // payload source address
    dwDataLenght = pMsgHdl->wCurObjs_m * sizeof(tCnApiObjId); //payload lenght

    DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Creating %d objects\n", pMsgHdl->wCurObjs_m);

#ifdef AP_IS_LITTLE_ENDIAN
    memcpy(pDest, pData, dwDataLenght); // copy payload
#else // AP_IS_BIG_ENDIAN
    // copy payload, but convert Endian
    {
       tCnApiObjId* ptSrc = (tCnApiObjId*)pData;
       tCnApiObjId* ptDest = (tCnApiObjId*)pDest;
       tCnApiObjId* ptEnd = ptSrc + pMsgHdl->wCurObjs_m;
       for (;ptSrc != ptEnd; ptSrc++, ptDest++) {
          ptDest->m_wIndex = AmiGetWordToLe((BYTE*)&(ptSrc->m_wIndex));
          ptDest->m_bSubIndex = ptSrc->m_bSubIndex;
          ptDest->m_bNumEntries = ptSrc->m_bNumEntries;
       }
    }
#endif // AP_IS_LITTLE_ENDIAN
    /* setup message header */
#ifdef AP_IS_LITTLE_ENDIAN
    pCreateObjLksReq->m_wNumObjs = pMsgHdl->wCurObjs_m;
#else // AP_IS_BIG_ENDIAN
    pCreateObjLksReq->m_wNumObjs = AmiGetWordToLe(&pMsgHdl->wCurObjs_m);
#endif // AP_IS_LITTLE_ENDIAN
    pCreateObjLksReq->m_bReqId = ++bReqId_l;

    /* update size values of message descriptors */
    pMsgDescr_p->dwMsgSize_m = sizeof(tCreateObjLksReq) + dwDataLenght; // sent size

exit:
    return Ret;
}


/**
********************************************************************************
\brief  create an object access request message
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
static tPdiAsyncStatus CnApiAsync_doObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pMsgBuffer_p,
                                                     BYTE * pRespMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tObjAccMsg *            pObjAccReqDst = NULL;
    tObjAccSdoComCon *     pSdoComConInArg = NULL; //input argument
    tPdiAsyncStatus         Ret = kPdiAsyncStatusSuccessful;

    DEBUG_FUNC;

    if (pMsgDescr_p == NULL                  || // message descriptor
        pMsgDescr_p->pUserHdl_m == NULL      || // input argument
        //pMsgDescr_p->pRespMsgDescr_m == NULL || // response message assignment
        pMsgBuffer_p == NULL                 ) // verify all buffer pointers we intend to use)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    // assign input argument
    pSdoComConInArg = (tObjAccSdoComCon *) pMsgDescr_p->pUserHdl_m;

    /* update size values of message descriptors */
    pMsgDescr_p->dwMsgSize_m = offsetof(tObjAccMsg ,m_SdoCmdFrame) + pSdoComConInArg->m_uiSizeOfFrame;

    /* check if expected Tx message size exceeds the buffer */
    if (pMsgDescr_p->dwMsgSize_m > dwMaxTxBufSize_p)
    {
        /* reject transfer, because direct access can not be processed */
        Ret = kPdiAsyncStatusDataTooLong;
        goto exit;
    }

    if ( pSdoComConInArg->m_uiSizeOfFrame == 0)
    {
        // no data containment - this should be an sequence layer ack frame
        // -> dont send it since we only use command layer!
        goto exit;
    }

    // assign buffer payload addresses
    pObjAccReqDst = (tObjAccMsg *) pMsgBuffer_p;   // Tx buffer

    /* setup message */
    /*----------------------------------------------------------------------------*/
    // TODO: convert to local endian to LE
    memcpy(&pObjAccReqDst->m_SdoCmdFrame, pSdoComConInArg->m_pSdoCmdFrame, pSdoComConInArg->m_uiSizeOfFrame);

    pObjAccReqDst->m_bReqId =  bReqId_l;//TODO: dont use this Id, only rely on m_wHdlCom
    pObjAccReqDst->m_wHdlCom = pSdoComConInArg->m_wSdoSeqConHdl;
    /*----------------------------------------------------------------------------*/

exit:
    return Ret;
}

/**
********************************************************************************
\brief  create an object access response message
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
//static tPdiAsyncStatus cnApiAsync_doObjAccResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
//                                                     BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
//{
//    //TODO: exact same functionality like cnApiAsync_doObjAccReq (only different naming)!
//}


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

#ifdef AP_IS_BIG_ENDIAN
    tInitPcpResp InitPcpRespBE; ///< copy of InitPcpResponse in big endian byte order
#endif // AP_IS_BIG_ENDIAN

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

#ifdef AP_IS_LITTLE_ENDIAN
    /* assign buffer payload addresses */
    pInitPcpResp = (tInitPcpResp *) pRxMsgBuffer_p;    // Rx buffer
#else // AP_IS_BIG_ENDIAN
    pInitPcpResp = &InitPcpRespBE;
    ConvertInitPcpRespEndian(pInitPcpResp, (tInitPcpResp *) pRxMsgBuffer_p);
#endif // AP_IS_LITTLE_ENDIAN

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

#ifdef AP_IS_BIG_ENDIAN
    tCreateObjLksResp CreateObjLksRespBE; ///< copy of CreateObjLinksResponse message
                                          ///< in big endian byte order
#endif // AP_IS_BIG_ENDIAN

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
#ifdef AP_IS_LITTLE_ENDIAN
    pCreateObjLksResp = (tCreateObjLksResp *) pRxMsgBuffer_p;    // Rx buffer
#else // AP_IS_BIG_ENDIAN
    pCreateObjLksResp = &CreateObjLksRespBE;
    ConvertCreateObjLksRespEndian(pCreateObjLksResp, (tCreateObjLksResp *) pRxMsgBuffer_p);
#endif //AP_IS_LITTLE_ENDIAN

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
\brief  handle an object access request message
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
static tPdiAsyncStatus CnApiAsync_handleObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                  BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p        )
{
    tObjAccMsg *    pObjAccReq = NULL;
    tPdiAsyncStatus    Ret = kPdiAsyncStatusSuccessful;
    tEplKernel EplRet = kEplSuccessful;

    DEBUG_FUNC;

    if (pMsgDescr_p == NULL                  || // message descriptor
        pRxMsgBuffer_p == NULL                 ) // verify all buffer pointers we intend to use)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    // assign buffer payload addresses
    pObjAccReq = (tObjAccMsg *) pRxMsgBuffer_p;      // Rx buffer

    // process the message
    /*----------------------------------------------------------------------------*/
    // forward to SDO command layer //TODO: Req->Server, Resp->Client: Issue?
    // TODO: convert to local endian from LE

    printf("(ReqId: %d Hdl:%d SdoCmdSegSize: %d)\n",
            pObjAccReq->m_bReqId, pObjAccReq->m_wHdlCom,
            pObjAccReq->m_SdoCmdFrame.m_le_wSegmentSize);

    // TODO: better search for free handle?
//    tEplKernel EplSdoComSearchConIntern(tEplSdoSeqConHdl    SdoSeqConHdl_p,
//                                             tEplSdoComConEvent SdoComConEvent_p,
//                                             tEplAsySdoCom*     pAsySdoCom_p);

    EplRet = EplSdoComProcessIntern(0,
                                    kEplSdoComConEventRec,
                                    &pObjAccReq->m_SdoCmdFrame);
    if (EplRet != kEplSuccessful)
    {
        Ret = kPdiAsyncStatusInvalidOperation;
        goto exit;
    }
    /*----------------------------------------------------------------------------*/

exit:
    return Ret;
}


/**
********************************************************************************
\brief  handle an object access response message
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
//static tPdiAsyncStatus cnApiAsync_handleObjAccResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
//                                                     BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
//{
//    //TODO: exact same functionality like cnApiAsync_handleObjAccReq (only different naming)!
//}


/* END-OF-FILE */
/******************************************************************************/

