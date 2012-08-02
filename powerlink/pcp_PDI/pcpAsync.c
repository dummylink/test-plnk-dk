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

#include "pcpAsync.h"
#include "pcpAsyncSm.h"
#include "pcpEvent.h"
#include "pcpPdo.h"
#include "pcp.h"

#include "Epl.h"
#include "kernel/EplObdk.h"
#include "EplSdoComu.h"

#include <string.h>

#include "systemComponents.h"

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

/* local variables */
static  BYTE    bLinkPdosReqMsgCnt_l = 0;     ///< descriptor version of LinkPdosReq
static  BYTE    bReqId_l = 0;         ///< asynchronous msg counter
/* variable indicates if AP objects have been linked successfully,
 * an error happened or no linking happened yet
 */
static tPdiAsyncStatus ApLinkingStatus_l = kPdiAsyncStatusInvalidState;

/******************************************************************************/
/* private functions */

static tPdiAsyncStatus cnApiAsync_handleInitPcpReq(struct sPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                    BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus cnApiAsync_handleObjAccResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                     BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p          );
static tPdiAsyncStatus cnApiAsync_handleLinkPdosResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                             BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus cnApiAsync_doObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pMsgBuffer_p,
                                                     BYTE * pRespMsgBuffer_p, DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus cnApiAsync_doLinkPdosReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                                 BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p          );

static tPdiAsyncStatus CnApiAsync_initInternalMsgs(void);

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief activate asynchronous functions
*******************************************************************************/
int CnApiAsync_create(void)
{
    int iRet;

    CnApi_activateAsyncStateMachine();

    iRet = CnApiAsync_init();
    if (iRet != OK )
    {
        DEBUG_TRACE0(DEBUG_LVL_09, "CnApiAsync_init() FAILED!\n");
        goto exit;
    }

    return OK;
exit:
    return ERROR;
}

/**
********************************************************************************
\brief  initialize asynchronous functions
*******************************************************************************/
int CnApiAsync_init(void)
{
    register WORD wCnt;
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;

    CNAPI_MEMSET( aPcpPdiAsyncTxMsgBuffer_g, 0x00, sizeof(tPcpPdiAsyncMsgBufDescr) * PDI_ASYNC_CHANNELS_MAX );
    CNAPI_MEMSET( aPcpPdiAsyncRxMsgBuffer_g, 0x00, sizeof(tPcpPdiAsyncMsgBufDescr) * PDI_ASYNC_CHANNELS_MAX );

    /* Attention: control register is seen for AP point of view -> PCP Tx is AP Rx and vice versa! */
    aPcpPdiAsyncTxMsgBuffer_g[0].pAdr_m = (tAsyncMsg *) (PDI_DPRAM_BASE_PCP + AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wRxAsyncBuf0Aoffs)));
    aPcpPdiAsyncTxMsgBuffer_g[0].wMaxPayload_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wRxAsyncBuf0Size)) - sizeof(tAsyncPdiBufCtrlHeader);
    aPcpPdiAsyncRxMsgBuffer_g[0].pAdr_m = (tAsyncMsg *) (PDI_DPRAM_BASE_PCP + AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wTxAsyncBuf0Aoffs)));
    aPcpPdiAsyncRxMsgBuffer_g[0].wMaxPayload_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wTxAsyncBuf0Size)) - sizeof(tAsyncPdiBufCtrlHeader);

    aPcpPdiAsyncTxMsgBuffer_g[1].pAdr_m = (tAsyncMsg *) (PDI_DPRAM_BASE_PCP + AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wRxAsyncBuf1Aoffs)));
    aPcpPdiAsyncTxMsgBuffer_g[1].wMaxPayload_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wRxAsyncBuf1Size)) - sizeof(tAsyncPdiBufCtrlHeader);
    aPcpPdiAsyncRxMsgBuffer_g[1].pAdr_m = (tAsyncMsg *) (PDI_DPRAM_BASE_PCP + AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wTxAsyncBuf1Aoffs)));
    aPcpPdiAsyncRxMsgBuffer_g[1].wMaxPayload_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wTxAsyncBuf1Size)) - sizeof(tAsyncPdiBufCtrlHeader);

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

            /* reset headers and buffer payload */
            memset(aPcpPdiAsyncTxMsgBuffer_g[wCnt].pAdr_m,
                   0x00,
                   aPcpPdiAsyncTxMsgBuffer_g[wCnt].wMaxPayload_m + sizeof(tAsyncPdiBufCtrlHeader));

            memset(aPcpPdiAsyncRxMsgBuffer_g[wCnt].pAdr_m,
                   0x00,
                   aPcpPdiAsyncRxMsgBuffer_g[wCnt].wMaxPayload_m + sizeof(tAsyncPdiBufCtrlHeader));

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
\brief  reset asynchronous functions
*******************************************************************************/
int CnApiAsync_reset(void)
{
    int iRet;

    CnApi_disableAsyncSmProcessing();

    // signal reset to AP
    Gi_pcpEventPost(kPcpPdiEventGeneric, kPcpGenEventResetCommunication);

    //reset the state machine
    CnApi_resetAsyncStateMachine();

    iRet = CnApiAsync_init();
    if (iRet != OK )
    {
        DEBUG_TRACE0(DEBUG_LVL_09, "CnApiAsync_init() FAILED!\n");
        goto exit;
    }

    CnApi_enableAsyncSmProcessing();

    // signal reset to AP
    Gi_pcpEventPost(kPcpPdiEventGeneric, kPcpGenEventResetCommunicationDone);

    return OK;
exit:
    return ERROR;
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

    // reset initialized messages counter
    CnApiAsync_resetMsgLogCounter();

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

    CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccResp, Dir, cnApiAsync_handleObjAccResp, &aPcpPdiAsyncRxMsgBuffer_g[1],
                        kPdiAsyncMsgInvalid, TfrTyp, kAsyncChannelSdo, pNmtList, 0);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccReq, Dir, cnApiAsync_handleObjAccResp, &aPcpPdiAsyncRxMsgBuffer_g[1],
                        kPdiAsyncMsgInvalid, TfrTyp, kAsyncChannelSdo, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntLinkPdosResp, Dir, cnApiAsync_handleLinkPdosResp, pPdiBuf,
                       kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    /* Tx messages */
    Dir = kCnApiDirTransmit;
    TfrTyp = kPdiAsyncTrfTypeLclBuffering;
    pPdiBuf = &aPcpPdiAsyncTxMsgBuffer_g[0];

    //pfnCbMsgHdl_p set to NULL means that message will be set up in corresponding request handle
    CnApiAsync_initMsg(kPdiAsyncMsgIntInitPcpResp, Dir, NULL, pPdiBuf,
                        kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntCreateObjLinksResp, Dir, NULL, pPdiBuf,
                        kPdiAsyncMsgInvalid, TfrTyp, ChanType_p, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccResp, Dir, cnApiAsync_doObjAccReq, &aPcpPdiAsyncTxMsgBuffer_g[1],
                        kPdiAsyncMsgInvalid, kPdiAsyncTrfTypeLclBuffering, kAsyncChannelSdo, pNmtList, wTout);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    //TODO: This is blocking asynchronous traffic, because it waits for a response
    //      Issue: ReqId has to be saved somehow (= another handle history)
    CnApiAsync_initMsg(kPdiAsyncMsgIntObjAccReq, Dir, cnApiAsync_doObjAccReq, &aPcpPdiAsyncTxMsgBuffer_g[1],
                        kPdiAsyncMsgIntObjAccResp, kPdiAsyncTrfTypeLclBuffering, kAsyncChannelSdo, pNmtList, 0);

    if (Ret != kPdiAsyncStatusSuccessful)  goto exit;

    TfrTyp = kPdiAsyncTrfTypeLclBuffering;
    CnApiAsync_initMsg(kPdiAsyncMsgIntLinkPdosReq, Dir, cnApiAsync_doLinkPdosReq, pPdiBuf,
                       kPdiAsyncMsgIntLinkPdosResp, TfrTyp, ChanType_p, pNmtList, 0);

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
static tPdiAsyncStatus cnApiAsync_handleInitPcpReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                             BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tPcpInitParm *      pInitParm = &initParm_g;
	tInitPcpReq *       pInitPcpReq = NULL;        ///< pointer to request message (Rx)
	tInitPcpResp *      pInitPcpResp = NULL;       ///< pointer to response message (Tx)
	tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;

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
    EPL_MEMCPY(pInitParm->m_abMac, pInitPcpReq->m_abMac,
               sizeof(pInitPcpReq->m_abMac)             );


	pInitParm->m_dwDeviceType = AmiGetDwordFromLe((BYTE*)&(pInitPcpReq->m_dwDeviceType));
	pInitParm->m_bNodeId = AmiGetDwordFromLe((BYTE*)&(pInitPcpReq->m_dwNodeId));
	pInitParm->m_dwRevision = AmiGetDwordFromLe((BYTE*)&(pInitPcpReq->m_dwRevision));
	pInitParm->m_dwSerialNum = AmiGetDwordFromLe((BYTE*)&(pInitPcpReq->m_dwSerialNum));
	pInitParm->m_dwVendorId = AmiGetDwordFromLe((BYTE*)&(pInitPcpReq->m_dwVendorId));
	pInitParm->m_dwProductCode = AmiGetDwordFromLe((BYTE*)&(pInitPcpReq->m_dwProductCode));
	EPL_MEMCPY (pInitParm->m_strDevName, pInitPcpReq->m_strDevName,
	            sizeof(pInitPcpReq->m_strDevName));
	EPL_MEMCPY (pInitParm->m_strHwVersion, pInitPcpReq->m_strHwVersion,
	            sizeof(pInitPcpReq->m_strHwVersion));
	EPL_MEMCPY (pInitParm->m_strSwVersion, pInitPcpReq->m_strSwVersion,
	            sizeof(pInitPcpReq->m_strSwVersion));

	/* setup response */
	pInitPcpResp->m_bReqId = pInitPcpReq->m_bReqId;
	pInitPcpResp->m_bStatus = kCnApiStatusOk;

    /* update size values of message descriptors */
    pMsgDescr_p->pRespMsgDescr_m->dwMsgSize_m = sizeof(tInitPcpResp); // sent size

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
static tPdiAsyncStatus cnApiAsync_handleObjAccResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pRxMsgBuffer_p,
                                  BYTE * pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p        )
{
    tObjAccMsg *    pObjAccReq = NULL;
    tPdiAsyncStatus    Ret = kPdiAsyncStatusSuccessful;
    tEplKernel EplRet;

    DEBUG_FUNC;

    if (pMsgDescr_p == NULL                  ||  // message descriptor
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
    pObjAccReq->m_wHdlCom = AmiGetWordFromLe(&pObjAccReq->m_wHdlCom);

    if ((pObjAccReq->m_SdoCmdFrame.m_le_bFlags & 0x40) != 0)
    {
        // SDO abort received
        ApiPdiComInstance_g.apObdParam_m[0]->m_dwAbortCode = AmiGetDwordFromLe(&pObjAccReq->m_SdoCmdFrame.m_le_abCommandData[0]);
    }
    else
    {
        // only expedited transfer are currently supported
        ApiPdiComInstance_g.apObdParam_m[0]->m_SegmentSize = AmiGetWordFromLe(&pObjAccReq->m_SdoCmdFrame.m_le_wSegmentSize);
        ApiPdiComInstance_g.apObdParam_m[0]->m_pData = &pObjAccReq->m_SdoCmdFrame.m_le_abCommandData[0];
    }

    // TODO: search handle index

    EplRet = EplAppDefObdAccFinished(&ApiPdiComInstance_g.apObdParam_m[0]);
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


/**
********************************************************************************
\brief  handle an Link PDOs Response message
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space
\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
static tPdiAsyncStatus cnApiAsync_handleLinkPdosResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                             BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tLinkPdosResp *    pLinkPdosResp = NULL;       ///< pointer to response message (Tx)
    DWORD              dwAbortCode = 0;
    tPdiAsyncStatus    Ret = kPdiAsyncStatusSuccessful;
    tEplKernel EplRet;

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

    // get originator handle
    pLinkPdosResp->m_wCommHdl = AmiGetWordFromLe(&pLinkPdosResp->m_wCommHdl);

    /* store data from pLinkPdosResp */
    if (pLinkPdosResp->m_bMsgId != bLinkPdosReqMsgCnt_l)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Wrong descriptor version returned: %d\n", pLinkPdosResp->m_bMsgId);
        Ret = kPdiAsyncStatusReqIdError;
        goto exit;
    }

    // get (SDO) error code
    dwAbortCode = AmiGetDwordFromLe(&pLinkPdosResp->m_dwErrCode);

    if (dwAbortCode != 0)
    {   // mapping is invalid or linking at AP failed
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: AP object linking failed!\n");

        if(pLinkPdosResp->m_bOrigin == kAsyncLnkPdoMsgOrigNmtCmd)
        {
            // do not proceed to ReadyToOperate state
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Bootup will not proceed!\n");
            ApLinkingStatus_l = kPdiAsyncStatusRespError;
        }
    }
    else
    {
        if(pLinkPdosResp->m_bOrigin == kAsyncLnkPdoMsgOrigNmtCmd)
        {
            // proceed to ReadyToOperate state
            ApLinkingStatus_l = kPdiAsyncStatusSuccessful;
        }
    }

    if(pLinkPdosResp->m_bOrigin == kAsyncLnkPdoMsgOrigObdAccess)
    {   // forward SDO abort code to originator

        // TODO: search handle index  ApiPdiComInstance_g.apObdParam_m[index] with pLinkPdosResp->m_wCommHdl
        if(ApiPdiComInstance_g.apObdParam_m[0]->m_dwAbortCode != 0)
        {   // Only overwrite abort code if it wasn't assigned ealier by another module.
            ApiPdiComInstance_g.apObdParam_m[0]->m_dwAbortCode = dwAbortCode;
        }

        EplRet = EplAppDefObdAccFinished(&ApiPdiComInstance_g.apObdParam_m[0]);
        if (EplRet != kEplSuccessful)
        {
            Ret = kPdiAsyncStatusInvalidOperation;
            goto exit;
        }
    }

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
static tPdiAsyncStatus cnApiAsync_doLinkPdosReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pTxMsgBuffer_p,
                                       BYTE* pRxMsgBuffer_p, DWORD dwMaxTxBufSize_p        )
{

    tLinkPdosReq *      pLinkPdosReq = NULL;
    tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;
    BOOL fRet = TRUE;                                       ///< temporary return value
    WORD wCurDescrPayloadOffset = 0;
    tLinkPdosReqComCon *  pLinkPdosReqComCon;

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
    if ( sizeof(tLinkPdosReq) > dwMaxTxBufSize_p)
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

    if (pMsgDescr_p->pUserHdl_m != NULL)
    {   // object access was the origin

        /* assign user handle */
        pLinkPdosReqComCon = (tLinkPdosReqComCon *) pMsgDescr_p->pUserHdl_m;

        fRet = Gi_setupPdoDesc(pLinkPdosReqComCon,
                               kCnApiDirNone,
                               &wCurDescrPayloadOffset,
                               pLinkPdosReq,
                               dwMaxTxBufSize_p - sizeof(tLinkPdosReq));
        if (fRet != TRUE)
        {
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR!\n");
            Ret = kPdiAsyncStatusInvalidOperation;
            goto exit;
        }

        pLinkPdosReq->m_bOrigin = kAsyncLnkPdoMsgOrigObdAccess;
        // TODO: Assign pLinkPdosReq->m_wCommHdl;
    }
    else
    {   // NmtEnableReadyToOperate command was the origin

        fRet = Gi_setupPdoDesc(NULL,
                               kCnApiDirReceive,
                               &wCurDescrPayloadOffset,
                               pLinkPdosReq,
                               dwMaxTxBufSize_p - sizeof(tLinkPdosReq));
        if (fRet != TRUE)
        {
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR!\n");
            Ret = kPdiAsyncStatusInvalidOperation;
            goto exit;
        }

        fRet = Gi_setupPdoDesc(NULL,
                               kCnApiDirTransmit,
                               &wCurDescrPayloadOffset,
                               pLinkPdosReq,
                               dwMaxTxBufSize_p - sizeof(tLinkPdosReq));
        if (fRet != TRUE)
        {
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR!\n");
            Ret = kPdiAsyncStatusInvalidOperation;
            goto exit;
        }

        pLinkPdosReq->m_bOrigin = kAsyncLnkPdoMsgOrigNmtCmd;

        // reset AP status linking status, because we want the AP to do a new linking now
        ApLinkingStatus_l = kPdiAsyncStatusInvalidState;
    }

    bLinkPdosReqMsgCnt_l++;                     ///< increase message ID
    pLinkPdosReq->m_bMsgId = bLinkPdosReqMsgCnt_l;

    /* update size values of message descriptors */
    pMsgDescr_p->dwMsgSize_m = wCurDescrPayloadOffset + sizeof(tLinkPdosReq);     // sent size

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_ASYNC_INFO, "MsgId: %d, MsgSize: %ld.\n", pLinkPdosReq->m_bMsgId, pMsgDescr_p->dwMsgSize_m);
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
static tPdiAsyncStatus cnApiAsync_doObjAccReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE * pMsgBuffer_p,
                                                     BYTE * pRespMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tObjAccMsg *            pObjAccReqDst = NULL;
    tObjAccSdoComCon *     pSdoComConInArg = NULL; //input argument
    tPdiAsyncStatus         Ret = kPdiAsyncStatusSuccessful;

    DEBUG_FUNC;

    if (pMsgDescr_p == NULL                  || // message descriptor
        pMsgDescr_p->pUserHdl_m == NULL      || // input argument
        pMsgDescr_p->pRespMsgDescr_m == NULL || // response message assignment
        pMsgBuffer_p == NULL                 )  // verify all buffer pointers we intend to use)
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

    // assign buffer payload addresses
    pObjAccReqDst = (tObjAccMsg *) pMsgBuffer_p;   // Tx buffer

    /* setup message */
    /*----------------------------------------------------------------------------*/
    memcpy(&pObjAccReqDst->m_SdoCmdFrame, pSdoComConInArg->m_pSdoCmdFrame, pSdoComConInArg->m_uiSizeOfFrame);

    pObjAccReqDst->m_bReqId =  bReqId_l;//TODO: dont use this Id, only rely on m_wHdlCom
    AmiSetWordToLe(&pObjAccReqDst->m_wHdlCom, pSdoComConInArg->m_wSdoSeqConHdl);
    /*----------------------------------------------------------------------------*/

exit:
    return Ret;
}

/* END-OF-FILE */
/******************************************************************************/

