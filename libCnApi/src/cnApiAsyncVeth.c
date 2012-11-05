/*******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       cnApiAsyncVeth.c

\brief      Module for Virtual Ethernet frame handling

\author     mairt

\date       31.05.2012

\since      31.05.2012

This module posts Virtual Ethernet frames from the application to the asynchronous
state machine and receives frames from there.

*******************************************************************************/

#include "cnApiCfg.h"

#if VETH_DRV_ENABLE != FALSE

/******************************************************************************/
/* includes */
#include "cnApiAsyncVethIntern.h"

#include "cnApiAsyncSm.h"

/******************************************************************************/
/* defines */
#define VETH_ASYNC_TIMEOUT  10          ///< async timeout until retransmission

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* structures */
#ifdef CNAPI_VETH_ENABLE_STATS
typedef struct _tVEthStatistics
{
    DWORD                  m_dwMsgPosted;   ///< Number of posted messages
    DWORD                  m_dwMsgsent;     ///< Number of successfully sent messages
    DWORD                  m_dwMsgrcv;      ///< Number of received messages
} tVEthStatistics;
#endif //CNAPI_VETH_ENABLE_STATS

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* local variables */
static tPdiAsyncVethRxCb pfnCbVethRx_l = NULL;
static tPdiAsyncVethTxFinCb pfnCbVethTxFin_l = NULL;

static BYTE fInitDone_l = FALSE;

#ifdef CNAPI_VETH_ENABLE_STATS
static tVEthStatistics VethStatistics_l = { 0 };
#endif //CNAPI_VETH_ENABLE_STATS

#ifdef CNAPI_VETH_SEND_TEST
//Data from veth pinging 192.168.100.240
/*
 * Frame 22 (42 bytes on wire, 42 bytes captured)
Ethernet II, Src: Compex_61:e1:5e (00:80:48:61:e1:5e), Dst: Broadcast (ff:ff:ff:ff:ff:ff)
    Destination: Broadcast (ff:ff:ff:ff:ff:ff)
    Source: Compex_61:e1:5e (00:80:48:61:e1:5e)
    Type: ARP (0x0806)
Address Resolution Protocol (request)
    Hardware type: Ethernet (0x0001)
    Protocol type: IP (0x0800)
    Hardware size: 6
    Protocol size: 4
    Opcode: request (0x0001)
    Sender MAC address: Compex_61:e1:5e (00:80:48:61:e1:5e)
    Sender IP address: 192.168.100.240 (192.168.100.240)
    Target MAC address: 00:00:00_00:00:00 (00:00:00:00:00:00)
    Target IP address: 192.168.100.1 (192.168.100.1)
*/
static BYTE abNonEplData[200] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0x0, 0x80, 0x48, 0x61, 0xe1, 0x5e,
        0x8, 0x6,
        0x0, 0x1,
        0x8, 0x0,
        0x6,
        0x4,
        0x0, 0x1,
        0x0, 0x12, 0x34, 0x56, 0x78, 0x9a,
        0xc0, 0xa8, 0x64, 0xf0,
        0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
        0xc0, 0xa8, 0x64, 0x1 };
#endif //CNAPI_VETH_SEND_TEST

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* functions */

static tPdiAsyncStatus CnApiAsyncVeth_handleDataTransfer(tPdiAsyncMsgDescr * pMsgDescr_p,
        BYTE* pRxMsgBuffer_p, BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus CnApiAsyncVeth_doDataTransfer(tPdiAsyncMsgDescr * pMsgDescr_p,
        BYTE* pTxMsgBuffer_p, BYTE* pRxMsgBuffer_p, DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus CnApiAsyncVeth_TxFinished (tPdiAsyncMsgDescr * pMsgDescr_p);

/**
********************************************************************************
\brief  Init the Veth module

Register the receive and optional transmit finished callback.

\param  pfnCbVethRx_p           callback for receive frames
\param  pfnCbVethTxFin_p        transmit finished callback

\return tCnApiStatus            kCnApiStatusOk
*******************************************************************************/
tCnApiStatus CnApi_initVeth(tPdiAsyncVethRxCb  pfnCbVethRx_p,
        tPdiAsyncVethTxFinCb pfnCbVethTxFin_p)
{
    tCnApiStatus iRet = kCnApiStatusOk;

    // make RX callback global
    if(pfnCbVethRx_p != NULL)
    {
        pfnCbVethRx_l = pfnCbVethRx_p;
    } else {
        iRet = ERROR;
        goto Exit;
    }

    // make TX finished callback global if available
    if(pfnCbVethTxFin_p != NULL)
    {
        pfnCbVethTxFin_l = pfnCbVethTxFin_p;
    }

    fInitDone_l = TRUE;

Exit:
    return iRet;
}

/**
********************************************************************************
\brief  Init the Veth async messages

Register Veth async receive and transmit messages. (Needs to be done before the
call of finishedInternalMessages function)

\return tCnApiStatus            kCnApiStatusOk
*******************************************************************************/
tCnApiStatus CnApi_initVethMessages(void)
{
    tCnApiStatus iRet = kCnApiStatusOk;
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;

    // check if the init function was called before
    if(fInitDone_l == FALSE)
    {
        iRet = kCnApiStatusError;
        goto Exit;
    }

    /* init Veth Rx message */
    Ret = CnApiAsync_initMsg(kPdiAsyncMsgExtRxDataTransfer, kCnApiDirReceive,
            CnApiAsyncVeth_handleDataTransfer, &aPcpPdiAsyncRxMsgBuffer_g[1], kPdiAsyncMsgInvalid,
            kPdiAsyncTrfTypeAutoDecision, kAsyncChannelExternal, NULL, VETH_ASYNC_TIMEOUT);
    if (Ret != kPdiAsyncStatusSuccessful)
    {
        iRet = kCnApiStatusError;
        goto Exit;
    }

    /* init Veth Tx message */
    Ret = CnApiAsync_initMsg(kPdiAsyncMsgExtTxDataTransfer, kCnApiDirTransmit,
            CnApiAsyncVeth_doDataTransfer, &aPcpPdiAsyncTxMsgBuffer_g[1], kPdiAsyncMsgInvalid,
            kPdiAsyncTrfTypeUserBuffering, kAsyncChannelExternal, NULL, VETH_ASYNC_TIMEOUT);
    if (Ret != kPdiAsyncStatusSuccessful)
    {
        iRet = kCnApiStatusError;
        goto Exit;
    }

Exit:
    return iRet;

}


#ifdef CNAPI_VETH_SEND_TEST
/**
********************************************************************************
\brief  transmit a test Veth frame

Receive handler for Veth frames. Transfers the newly arrived message to the
application.

\param  pData_p          data to be transfered
\param  wDataSize        size of the package

\return CnApiRet                tCnApiStatus
\retval kCnApiStatusOk          everything ok
\retval kCnApiStatusMsgBufFull  no free buffer available
*******************************************************************************/
tCnApiStatus CnApi_SendTestVEth(void)
{
    tCnApiStatus  Ret = kCnApiStatusOk;

    WORD wSize = sizeof(abNonEplData);

    //transmit test frame
    Ret = CnApi_sendVeth(abNonEplData, wSize);

    return Ret;
}
#endif //CNAPI_VETH_SEND_TEST


/**
********************************************************************************
\brief  transmit a Veth message

Receive handler for Veth frames. Transfers the newly arrived message to the
application.

\param  pData_p          data to be transfered
\param  wDataSize        size of the package

\return CnApiRet                tCnApiStatus
\retval kCnApiStatusOk          everything ok
\retval kCnApiStatusMsgBufFull  no free buffer available
*******************************************************************************/
tCnApiStatus CnApi_sendVeth(BYTE *pData_p, WORD wDataSize)
{
    tCnApiStatus CnApiRet = kCnApiStatusOk;
    tPdiAsyncStatus PdiRet = kPdiAsyncStatusSuccessful;

    PdiRet = CnApiAsync_postMsg(
                        kPdiAsyncMsgExtTxDataTransfer,
                        NULL,
                        CnApiAsyncVeth_TxFinished,
                        NULL,
                        pData_p,
                        wDataSize);

    if (PdiRet == kPdiAsyncStatusRetry)
    {
        CnApiRet = kCnApiStatusMsgBufFull;
        goto Exit;
    }
    else if (PdiRet != kPdiAsyncStatusSuccessful)
    {
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "ERROR: (%s) CnApiAsync_postMsg() "
                "retval 0x%x\n", __func__, PdiRet);

        CnApiRet = kCnApiStatusError;
        goto Exit;
    }

    DEBUG_LVL_CNAPI_VETH_INFO_TRACE1("VETHINFO: (%s) Frame received from "
            "application and posted!\n", __func__);

#ifdef CNAPI_VETH_ENABLE_STATS
        VethStatistics_l.m_dwMsgPosted++;
#endif //CNAPI_VETH_ENABLE_STATS

Exit:
    return CnApiRet;
}

/******************************************************************************/
/* private functions */

/**
********************************************************************************
\brief  handle an Veth RX message

Receive handler for Veth frames. Transfers the newly arrived message to the
application.

\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pMsgBuffer_p        pointer to Rx message buffer (payload)
\param  pRespMsgBuffer_p    pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space

\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
static tPdiAsyncStatus CnApiAsyncVeth_handleDataTransfer(tPdiAsyncMsgDescr * pMsgDescr_p,
        BYTE* pMsgBuffer_p, BYTE* pRespMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tCnApiStatus       Ret = kCnApiStatusOk;
    tPdiAsyncStatus    cnApiRet = kPdiAsyncStatusSuccessful;

    /* check message descriptor */
    if ( pMsgDescr_p == NULL ||
         pMsgBuffer_p == NULL )
    {
        cnApiRet = kPdiAsyncStatusInvalidInstanceParam;
        goto Exit;
    }

    DEBUG_LVL_CNAPI_VETH_INFO_TRACE1("VETHINFO: (%s) Frame received "
            "from PDI!\n", __func__);

#ifdef CNAPI_VETH_ENABLE_STATS
        VethStatistics_l.m_dwMsgrcv++;
#endif //CNAPI_VETH_ENABLE_STATS

    /* transfer this newly arrived message to the application */
    Ret = pfnCbVethRx_l(pMsgBuffer_p, pMsgDescr_p->dwMsgSize_m);
    if (Ret != kCnApiStatusOk)
    {
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "ERROR: (%s) Receive callback "
                "returned: 0x%02X\n", __func__ , Ret);
        cnApiRet = kPdiAsyncStatusSendError;
        goto Exit;
    }

Exit:
    return cnApiRet;
}

/**
********************************************************************************
\brief  handle an Veth TX message

Transmit handler for Veth frames. Copies the transit message into the PDI buffer

\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pMsgBuffer_p        pointer to Rx message buffer (payload)
\param  pRespMsgBuffer_p    pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space

\return Ret                 tPdiAsyncStatus value
*******************************************************************************/
static tPdiAsyncStatus CnApiAsyncVeth_doDataTransfer(tPdiAsyncMsgDescr * pMsgDescr_p,
        BYTE * pMsgBuffer_p, BYTE * pRespMsgBuffer_p, DWORD dwMaxTxBufSize_p        )
{
    tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;

    /* check message descriptor */
    if (pMsgDescr_p == NULL                  || // message descriptor
        pMsgBuffer_p == NULL                 )  // verify all buffer pointers we intend to use)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto Exit;
    }

    /* update size values of message descriptors */
    pMsgDescr_p->dwMsgSize_m = dwMaxTxBufSize_p;

    DEBUG_LVL_CNAPI_VETH_INFO_TRACE1("VETHINFO: (%s) Do transmit "
            "to PDI!\n", __func__);

Exit:
    return Ret;
}

/**
 ********************************************************************************
 \brief call back function, invoked after message transfer has finished
 \param  pMsgDescr_p         pointer to asynchronous message descriptor
 \return Ret                 tPdiAsyncStatus value

 This function is called after the Virtual Ethernet transfer is finished. It
 frees the receive buffer after the async state machine is finished.
 *******************************************************************************/
static tPdiAsyncStatus CnApiAsyncVeth_TxFinished(tPdiAsyncMsgDescr * pMsgDescr_p)
{
    tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;
    tCnApiStatus        CnApiRet = kCnApiStatusOk;

    if (pMsgDescr_p == NULL)  // message descriptor invalid
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto Exit;
    }

    // error handling
    if ((pMsgDescr_p->MsgStatus_m == kPdiAsyncMsgStatusError) &&
        (pMsgDescr_p->Error_m == kPdiAsyncStatusTimeout)     )
    {
        DEBUG_LVL_CNAPI_VETH_INFO_TRACE1("VETHINFO: (%s) Transmit to PDI timed out!\n", __func__);
        // timeout happened
        Ret = kPdiAsyncStatusSuccessful;

        /* call TX finished callback if available*/
        if(pfnCbVethTxFin_l != NULL)
        {
            CnApiRet = pfnCbVethTxFin_l(kCnApiVethTxTimeout);
        }

        goto Exit;
    }
    else if ((pMsgDescr_p->MsgStatus_m == kPdiAsyncMsgStatusError) &&
        (pMsgDescr_p->Error_m != kPdiAsyncStatusSuccessful)     )
    {
        Ret = kPdiAsyncStatusInvalidOperation;
        goto Exit;
    } else {
        DEBUG_LVL_CNAPI_VETH_INFO_TRACE1("VETHINFO: (%s) Transfer finished "
                "reported!\n", __func__);

#ifdef CNAPI_VETH_ENABLE_STATS
        VethStatistics_l.m_dwMsgsent++;
#endif //CNAPI_VETH_ENABLE_STATS

        /* call TX finished callback if available*/
        if(pfnCbVethTxFin_l != NULL)
        {
            CnApiRet = pfnCbVethTxFin_l(kCnApiVethTxSuccessfull);
        }
    }


Exit:
    if(CnApiRet != kCnApiStatusOk)
    {
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "ERROR: (%s) Veth transfer finished callback "
                "returned 0x%x\n", __func__, CnApiRet);
        Ret = kPdiAsyncStatusInvalidOperation;
    }

    return Ret;
}


#endif //VETH_DRV_EN
