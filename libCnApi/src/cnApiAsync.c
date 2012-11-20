/**
********************************************************************************
\file       cnApiAsync.c

\brief      CN API asynchronous transfer functions

This module contains functions for the asynchronous transfer in the CN API
library.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include <cnApi.h>
#include <string.h>
#include <stateMachine.h>

#include "cnApiIntern.h"
#include "cnApiAsync.h"
#include "cnApiAsyncSm.h"
#include "cnApiPdo.h"
#include "cnApiAmi.h"

#if VETH_DRV_ENABLE != FALSE
#include "cnApiAsyncVethIntern.h"
#endif

#include "user/EplSdoComu.h"

#ifdef CN_API_USING_SPI
  #include "cnApiPdiSpiIntern.h"
#endif

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* global variables */
tPcpPdiAsyncMsgBufDescr aPcpPdiAsyncTxMsgBuffer_g[ASYNC_PDI_CHANNELS];
tPcpPdiAsyncMsgBufDescr aPcpPdiAsyncRxMsgBuffer_g[ASYNC_PDI_CHANNELS];


/******************************************************************************/
/* local variables */
static BYTE bReqId_l = 0;            ///< asynchronous msg counter
#ifdef CN_API_USING_SPI
static tAsyncMsg LclCpyAsyncMsgHeader_l[4]; ///< local copy of asynchronous PDI message header
#endif

static tPcpCtrlReg *     pCtrlReg_l = NULL;
static tPcpInitParam *   pInitPcpParam_l = NULL;
static BYTE *            pDpramBase_l = NULL;

/******************************************************************************/
/* function declarations */


/******************************************************************************/
/* private functions */
static tPdiAsyncStatus CnApiAsync_initInternalMsgs(void);
static tPdiAsyncStatus CnApi_doInitPcpReq(tPdiAsyncMsgDescr * pMsgDescr_p,
                                           BYTE* pTxMsgBuffer_p,
                                           BYTE* pRxMsgBuffer_p,
                                           DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus CnApiAsync_doObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p,
                                                BYTE * pMsgBuffer_p,
                                                BYTE * pRespMsgBuffer_p,
                                                DWORD dwMaxTxBufSize_p);

static tPdiAsyncStatus CnApiAsync_handleObjAccResp(tPdiAsyncMsgDescr * pMsgDescr_p,
                                                    BYTE * pRxMsgBuffer_p,
                                                    BYTE * pTxMsgBuffer_p,
                                                    DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus CnApiAsync_handleObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p,
                                                    BYTE * pRxMsgBuffer_p,
                                                    BYTE * pTxMsgBuffer_p,
                                                    DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus CnApiAsync_doObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p,
                                                BYTE * pMsgBuffer_p,
                                                BYTE * pRespMsgBuffer_p,
                                                DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus CnApiAsync_doObjAccResp(tPdiAsyncMsgDescr * pMsgDescr_p,
                                                BYTE * pMsgBuffer_p,
                                                BYTE * pRespMsgBuffer_p,
                                                DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus CnApi_handleInitPcpResp(tPdiAsyncMsgDescr * pMsgDescr_p,
                                               BYTE * pRxMsgBuffer_p,
                                               BYTE * pTxMsgBuffer_p,
                                               DWORD dwMaxTxBufSize_p);

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  activate asynchronous functions

Initially create the CnApi async module. This activates the state machine and
calls CnApiAsync_init().

\param  pCtrlReg_p          pointer to the control register
\param  pInitPcpParam_p     pointer to pcp init structure
\param  pDpramBase_p        pointer to Dpram base address

\return int
\retval OK                  on success
\retval ERROR               when create fails
*******************************************************************************/
int CnApiAsync_create(tPcpCtrlReg *pCtrlReg_p, tPcpInitParam *pInitPcpParam_p,
        BYTE * pDpramBase_p)
{
    int iRet = OK;

    if(pCtrlReg_p != NULL && pInitPcpParam_p != NULL)
    {
        pCtrlReg_l = pCtrlReg_p;
        pInitPcpParam_l = pInitPcpParam_p; // make init parameters local
        pDpramBase_l = pDpramBase_p;       // make dprambase local
    }
    else
    {
        iRet = ERROR;
        goto Exit;
    }

    CnApi_activateAsyncStateMachine();

    iRet = CnApiAsync_init();

Exit:
    return iRet;
}

/**
********************************************************************************
\brief  reset asynchronous functions

Reset the CnApi async module. This is done by disabling the module, doing
a reset and calling CnApiAsync_init() again.

\return int
\retval OK                  on success
\retval ERROR               when create fails
*******************************************************************************/
int CnApiAsync_reset(void)
{
    int iRet = OK;

    CnApi_disableAsyncSmProcessing();

    //reset the state machine
    CnApi_resetAsyncStateMachine();

    iRet = CnApiAsync_init();

    return iRet;
}

/**
********************************************************************************
\brief  initialize asynchronous functions

This function inits all asynchronous structures and sets the addresses of all
asynchronous buffers. In addition it creates all internal messages and calls
CnApiAsync_finishMsgInit() afterwards.

\return int
\retval OK                  on success
\retval ERROR               when create fails
*******************************************************************************/
int CnApiAsync_init(void)
{
    register WORD wCnt;
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;

    CNAPI_MEMSET( aPcpPdiAsyncTxMsgBuffer_g, 0x00, sizeof(tPcpPdiAsyncMsgBufDescr) * ASYNC_PDI_CHANNELS );
    CNAPI_MEMSET( aPcpPdiAsyncRxMsgBuffer_g, 0x00, sizeof(tPcpPdiAsyncMsgBufDescr) * ASYNC_PDI_CHANNELS );

#ifdef CN_API_USING_SPI
    aPcpPdiAsyncTxMsgBuffer_g[0].pAdr_m = &LclCpyAsyncMsgHeader_l[0];
    aPcpPdiAsyncRxMsgBuffer_g[0].pAdr_m = &LclCpyAsyncMsgHeader_l[1];
    aPcpPdiAsyncTxMsgBuffer_g[1].pAdr_m = &LclCpyAsyncMsgHeader_l[2];
    aPcpPdiAsyncRxMsgBuffer_g[1].pAdr_m = &LclCpyAsyncMsgHeader_l[3];

    aPcpPdiAsyncTxMsgBuffer_g[0].wPdiOffset_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wTxAsyncBuf0Aoffs));
    aPcpPdiAsyncRxMsgBuffer_g[0].wPdiOffset_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wRxAsyncBuf0Aoffs));
    aPcpPdiAsyncTxMsgBuffer_g[1].wPdiOffset_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wTxAsyncBuf1Aoffs));
    aPcpPdiAsyncRxMsgBuffer_g[1].wPdiOffset_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wRxAsyncBuf1Aoffs));
#else
    aPcpPdiAsyncTxMsgBuffer_g[0].pAdr_m = (tAsyncMsg *) (pDpramBase_l + AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wTxAsyncBuf0Aoffs)));
    aPcpPdiAsyncRxMsgBuffer_g[0].pAdr_m = (tAsyncMsg *) (pDpramBase_l + AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wRxAsyncBuf0Aoffs)));
    aPcpPdiAsyncTxMsgBuffer_g[1].pAdr_m = (tAsyncMsg *) (pDpramBase_l + AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wTxAsyncBuf1Aoffs)));
    aPcpPdiAsyncRxMsgBuffer_g[1].pAdr_m = (tAsyncMsg *) (pDpramBase_l + AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wRxAsyncBuf1Aoffs)));
#endif /* CN_API_USING_SPI */

    aPcpPdiAsyncTxMsgBuffer_g[0].wMaxPayload_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wTxAsyncBuf0Size)) - sizeof(tAsyncPdiBufCtrlHeader);
    aPcpPdiAsyncRxMsgBuffer_g[0].wMaxPayload_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wRxAsyncBuf0Size)) - sizeof(tAsyncPdiBufCtrlHeader);
    aPcpPdiAsyncTxMsgBuffer_g[1].wMaxPayload_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wTxAsyncBuf1Size)) - sizeof(tAsyncPdiBufCtrlHeader);
    aPcpPdiAsyncRxMsgBuffer_g[1].wMaxPayload_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_l->m_wRxAsyncBuf1Size)) - sizeof(tAsyncPdiBufCtrlHeader);

    for (wCnt = 0; wCnt < ASYNC_PDI_CHANNELS; ++wCnt)
    {
        if ((aPcpPdiAsyncTxMsgBuffer_g[wCnt].pAdr_m == NULL)                                        ||
            (aPcpPdiAsyncTxMsgBuffer_g[wCnt].wMaxPayload_m + sizeof(tAsyncPdiBufCtrlHeader) == 0)   ||
            (aPcpPdiAsyncRxMsgBuffer_g[wCnt].pAdr_m == NULL)                                        ||
            (aPcpPdiAsyncRxMsgBuffer_g[wCnt].wMaxPayload_m + sizeof(tAsyncPdiBufCtrlHeader)== 0)      )
        {
            DEBUG_TRACE2(DEBUG_LVL_CNAPI_ERR, "\nError in %s: initializing Async PDI Buffer %d failed!\n", __func__, wCnt);
            goto exit;
        }
        else
        {
            DEBUG_TRACE4(DEBUG_LVL_CNAPI_INFO, "%s: TX Async Buffer %d: adrs. %08x (max payload %d)\n",
                         __func__, wCnt,(unsigned int)aPcpPdiAsyncTxMsgBuffer_g[wCnt].pAdr_m,
                         aPcpPdiAsyncTxMsgBuffer_g[wCnt].wMaxPayload_m);
            DEBUG_TRACE4(DEBUG_LVL_CNAPI_INFO, "%s: RX Async Buffer %d: adrs. %08x (max payload %d)\n",
                         __func__, wCnt,(unsigned int)aPcpPdiAsyncRxMsgBuffer_g[wCnt].pAdr_m,
                         aPcpPdiAsyncRxMsgBuffer_g[wCnt].wMaxPayload_m);

            /* reset of headers and buffer payload happens at PCP side, so its not needed here */
        }
    }

    bReqId_l = 0;           // reset asynchronous sequence number

    Ret = CnApiAsync_initInternalMsgs();
    if (Ret != kPdiAsyncStatusSuccessful)
    {
        goto exit;
    }

#if VETH_DRV_ENABLE != FALSE
    Ret = CnApi_initVethMessages();
    if (Ret != kPdiAsyncStatusSuccessful)
    {
        goto exit;
    }
#endif

    Ret = CnApiAsync_finishMsgInit();
    if (Ret != kPdiAsyncStatusSuccessful)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "CnApiAsync_finishMsgInit() failed!\n");
        Ret = kCnApiStatusError;
        goto exit;
    }

    return OK;
exit:
    return ERROR;
}

/**
 ********************************************************************************
 \brief call back function, invoked if InitPcpResp has finished

 This function triggers an CMD_INIT which will be sent to the PCP

 \param  pMsgDescr_p         pointer to asynchronous message descriptor


 \return tPdiAsyncStatus
 \retval kPdiAsyncStatusSuccessful           on success
 *******************************************************************************/
tPdiAsyncStatus CnApi_pfnCbInitPcpRespFinished (struct sPdiAsyncMsgDescr * pMsgDescr_p)
{
        CnApi_setApCommand(kApCmdInit);

        return kPdiAsyncStatusSuccessful;
}

/**
********************************************************************************
\brief  initialize asynchronous messages using the internal channel

\return tPdiAsyncStatus
\retval kPdiAsyncStatusSuccessful                on success
\retval kPdiAsyncStatusInvalidInstanceParam      in case of a failed init
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

    // reset initialized messages counter
    CnApiAsync_resetMsgLogCounter();

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

#ifdef CN_API_USING_SPI
    TfrTyp = kPdiAsyncTrfTypeLclBuffering; // has to be buffered locally if serial interface is used
#else
    TfrTyp = kPdiAsyncTrfTypeDirectAccess; // use only, if message size will not exceed the PDI buffer
#endif /* CN_API_USING_SPI */

    Ret = CnApiAsync_initMsg(kPdiAsyncMsgIntLinkPdosResp, Dir, CnApi_doLinkPdosResp, pPdiBuf,
                       kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

#ifdef CN_API_USING_SPI
    TfrTyp = kPdiAsyncTrfTypeLclBuffering; // has to be buffered locally if serial interface is used
#else
//    TfrTyp = kPdiAsyncTrfTypeLclBuffering;; // use only, if message size will not exceed the PDI buffer
#endif /* CN_API_USING_SPI */

    Ret = CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccResp, Dir, CnApiAsync_doObjAccResp, &aPcpPdiAsyncTxMsgBuffer_g[1],
                        kPdiAsyncMsgInvalid, kPdiAsyncTrfTypeLclBuffering, kAsyncChannelExternal, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    Ret = CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccReq, Dir, CnApiAsync_doObjAccReq, &aPcpPdiAsyncTxMsgBuffer_g[1],
                        kPdiAsyncMsgInvalid, kPdiAsyncTrfTypeLclBuffering, kAsyncChannelExternal, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    /* Rx messages */
    Dir = kCnApiDirReceive;
#ifdef CN_API_USING_SPI
    TfrTyp = kPdiAsyncTrfTypeLclBuffering; // has to be buffered locally if serial interface is used
#else
    TfrTyp = kPdiAsyncTrfTypeAutoDecision;; // transfer type doesn't matter -> chosen according to Rx messsage size
#endif /* CN_API_USING_SPI */

    pPdiBuf = &aPcpPdiAsyncRxMsgBuffer_g[0];

    Ret = CnApiAsync_initMsg(kPdiAsyncMsgIntInitPcpResp, Dir, CnApi_handleInitPcpResp, pPdiBuf,
                        kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    Ret = CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccResp, Dir, CnApiAsync_handleObjAccResp, &aPcpPdiAsyncRxMsgBuffer_g[1],
                        kPdiAsyncMsgInvalid, kPdiAsyncTrfTypeLclBuffering, kAsyncChannelExternal, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    Ret = CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccReq, Dir, CnApiAsync_handleObjAccReq, &aPcpPdiAsyncRxMsgBuffer_g[1],
                        kPdiAsyncMsgInvalid, kPdiAsyncTrfTypeLclBuffering, kAsyncChannelExternal, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    Ret = CnApiAsync_initMsg(kPdiAsyncMsgIntLinkPdosReq, Dir, CnApi_handleLinkPdosReq , pPdiBuf,
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

\return tPdiAsyncStatus
\retval kPdiAsyncStatusSuccessful                on success
\retval kPdiAsyncStatusInvalidInstanceParam      in case of a failed init
\retval kPdiAsyncStatusDataTooLong               when the message size is exceeded

CnApi_doInitPcpReq() executes an initPcp command. The initialization parameters
stored in pInitParm_g will be copied to the initPcpReq message and transfered
to the PCP. Afterwards the function polls for a valid initPcpResp message from
the PCP.
*******************************************************************************/
static tPdiAsyncStatus CnApi_doInitPcpReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pTxMsgBuffer_p,
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
    CNAPI_MEMSET(pInitPcpReq, 0x00, sizeof(pInitPcpReq));
    CNAPI_MEMCPY ((BYTE *)pInitPcpReq->m_abMac, &pInitPcpParam_l->m_abMac, sizeof(pInitPcpParam_l->m_abMac));
    AmiSetDwordToLe((BYTE*)&pInitPcpReq->m_dwIpAddress, pInitPcpParam_l->m_dwIpAddress);
    AmiSetDwordToLe((BYTE*)&pInitPcpReq->m_dwSubNetMask, pInitPcpParam_l->m_dwSubNetMask);
    AmiSetWordToLe((BYTE*)&pInitPcpReq->m_wMtu, pInitPcpParam_l->m_wMtu);
    AmiSetDwordToLe((BYTE*)&pInitPcpReq->m_dwDeviceType, pInitPcpParam_l->m_dwDeviceType);
    AmiSetDwordToLe((BYTE*)&pInitPcpReq->m_dwNodeId, (DWORD)pInitPcpParam_l->m_bNodeId);
    AmiSetDwordToLe((BYTE*)&pInitPcpReq->m_dwRevision, pInitPcpParam_l->m_dwRevision);
    AmiSetDwordToLe((BYTE*)&pInitPcpReq->m_dwSerialNum, pInitPcpParam_l->m_dwSerialNum);
    AmiSetDwordToLe((BYTE*)&pInitPcpReq->m_dwVendorId, pInitPcpParam_l->m_dwVendorId);
    AmiSetDwordToLe((BYTE*)&pInitPcpReq->m_dwProductCode, pInitPcpParam_l->m_dwProductCode);
    CNAPI_MEMCPY((BYTE *)pInitPcpReq->m_strDevName, &pInitPcpParam_l->m_strDevName, sizeof(pInitPcpReq->m_strDevName));
    CNAPI_MEMCPY((BYTE *)pInitPcpReq->m_strHwVersion, &pInitPcpParam_l->m_strHwVersion, sizeof(pInitPcpReq->m_strHwVersion));
    CNAPI_MEMCPY((BYTE *)pInitPcpReq->m_strSwVersion, &pInitPcpParam_l->m_strSwVersion, sizeof(pInitPcpReq->m_strSwVersion));
    CNAPI_MEMCPY((BYTE *)pInitPcpReq->m_strHostname, &pInitPcpParam_l->m_strHostname, sizeof(pInitPcpReq->m_strHostname));

    pInitPcpReq->m_bReqId = ++bReqId_l;

    /* update size values of message descriptors */
    pMsgDescr_p->dwMsgSize_m = sizeof(tInitPcpReq); // sent size

    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "INFO: InitPcpReq posted.\n");

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

\return tPdiAsyncStatus
\retval kPdiAsyncStatusSuccessful                on success
\retval kPdiAsyncStatusInvalidInstanceParam      in case of a failed init
\retval kPdiAsyncStatusDataTooLong               when the message size is exceeded

*******************************************************************************/
static tPdiAsyncStatus CnApiAsync_doObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pMsgBuffer_p,
                                                     BYTE * pRespMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tObjAccMsg *           pObjAccReqDst = NULL;
    tObjAccSdoComCon *     pSdoComConInArg = NULL; //input argument
    tPdiAsyncStatus        Ret = kPdiAsyncStatusSuccessful;
    tEplSdoComCon*         pSdoComCon;

    DEBUG_FUNC;

    if (pMsgDescr_p == NULL                  || // message descriptor
        pMsgDescr_p->pUserHdl_m == NULL      || // input argument
        pMsgBuffer_p == NULL                 ) // verify all buffer pointers we intend to use)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    // assign input arguments
    pSdoComConInArg = (tObjAccSdoComCon *) pMsgDescr_p->pUserHdl_m;

    if (pSdoComConInArg->m_pUserArg == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }
    pSdoComCon = (tEplSdoComCon *) pSdoComConInArg->m_pUserArg;

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
        // -> don't send it since we only use command layer!
        goto exit;
    }

    // assign buffer payload addresses
    pObjAccReqDst = (tObjAccMsg *) pMsgBuffer_p;   // Tx buffer

    /* setup message */
    /*----------------------------------------------------------------------------*/
    CNAPI_MEMCPY(&pObjAccReqDst->m_SdoCmdFrame, pSdoComConInArg->m_pSdoCmdFrame, pSdoComConInArg->m_uiSizeOfFrame);

    // overwrite segment size - because this SDO command layer frame is misused as an customized acknowledge message
    AmiSetWordToLe((BYTE *)&pObjAccReqDst->m_SdoCmdFrame.m_le_wSegmentSize, pSdoComCon->m_uiTransferredByte);

    pObjAccReqDst->m_bReqId =  bReqId_l; // this Id is only for information purposes
    AmiSetWordToLe(&pObjAccReqDst->m_wComConHdl, pSdoComCon->m_wExtComConHdl);
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
static tPdiAsyncStatus CnApiAsync_doObjAccResp(tPdiAsyncMsgDescr * pMsgDescr_p,
                                              BYTE * pMsgBuffer_p,
                                              BYTE * pRespMsgBuffer_p,
                                              DWORD dwMaxTxBufSize_p)
{
    // exact same functionality like CnApiAsync_doObjAccReq (only different naming)
    return CnApiAsync_doObjAccReq(pMsgDescr_p,
                                  pMsgBuffer_p,
                                  pRespMsgBuffer_p,
                                  dwMaxTxBufSize_p);
}


/**
********************************************************************************
\brief  handle an initPcpResp

\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space

\return tPdiAsyncStatus
\retval kPdiAsyncStatusSuccessful                on success
\retval kPdiAsyncStatusInvalidInstanceParam      in case of a failed init
\retval kPdiAsyncStatusRespError                 when response msg fails

*******************************************************************************/
static tPdiAsyncStatus CnApi_handleInitPcpResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
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
    if (pInitPcpResp->m_bReqId != bReqId_l)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: (%s) Unexpected Request ID!\n"
                ,__func__);
        Ret = kPdiAsyncStatusRespError;
        goto exit;
    }

    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "INFO: InitPcpResp received.\n");
    if (pInitPcpResp->m_bStatus == kCnApiStatusOk)
    {
        goto exit;
    }
    else
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: (%s) PCP returned an error while "
                "doing InitPcpReq!\n",__func__);
        Ret = kPdiAsyncStatusRespError;
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

\return tPdiAsyncStatus
\retval kPdiAsyncStatusSuccessful                on success
\retval kPdiAsyncStatusInvalidInstanceParam      in case of a failed init
\retval kPdiAsyncStatusInvalidOperation          when internal processing fails

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
    // forward to SDO command layer

//    printf("(ReqId: %d Hdl:%d SdoCmdSegSize: %d)\n",
//            pObjAccReq->m_bReqId, pObjAccReq->m_wHdlCom,
//            pObjAccReq->m_SdoCmdFrame.m_le_wSegmentSize);

    // TODO: better search for free handle?
//    tEplKernel EplSdoComSearchConIntern(tEplSdoSeqConHdl    SdoSeqConHdl_p,
//                                             tEplSdoComConEvent SdoComConEvent_p,
//                                             tEplAsySdoCom*     pAsySdoCom_p);

    EplRet = EplSdoComProcessIntern(0,
                                    kEplSdoComConEventRec,
                                    (tEplAsySdoCom *)&pObjAccReq->m_SdoCmdFrame,    // convert to epl structure
                                    AmiGetWordFromLe(&pObjAccReq->m_wComConHdl));
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
static tPdiAsyncStatus CnApiAsync_handleObjAccResp(tPdiAsyncMsgDescr * pMsgDescr_p,
                                                   BYTE * pRxMsgBuffer_p,
                                                   BYTE * pTxMsgBuffer_p,
                                                   DWORD dwMaxTxBufSize_p)
{
    // exact same functionality like CnApiAsync_handleObjAccReq (only different naming)
     return CnApiAsync_handleObjAccReq(pMsgDescr_p,
                                        pRxMsgBuffer_p,
                                        pTxMsgBuffer_p,
                                        dwMaxTxBufSize_p);
}


/*******************************************************************************
*
* License Agreement
*
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved.
*
* Redistribution and use in source and binary forms,
* with or without modification,
* are permitted provided that the following conditions are met:
*
*   * Redistributions of source code must retain the above copyright notice,
*     this list of conditions and the following disclaimer.
*   * Redistributions in binary form must reproduce the above copyright notice,
*     this list of conditions and the following disclaimer
*     in the documentation and/or other materials provided with the
*     distribution.
*   * Neither the name of the B&R nor the names of its contributors
*     may be used to endorse or promote products derived from this software
*     without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
* A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
* THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
*******************************************************************************/
/* END-OF-FILE */

