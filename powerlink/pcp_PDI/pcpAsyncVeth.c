/**
********************************************************************************
\file       pcpAsyncVeth.c

\brief      Module for Virtual Ethernet frame handling

This module contains of the virtual ethernet frame handling on the POWERLINK
processor PCP. It receives frames from the AP and posts them to the stack. In
addition it receives frames from the stack and forwards them to the PDI.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#include "systemComponents.h"
#include "pcpAsyncVeth.h"

#ifdef VETH_DRV_EN

/******************************************************************************/
/* includes */
#include "pcpAsyncSm.h"
#include "pcp.h"
#include "pcpEvent.h"

#include "VirtualEthernetApi.h"

/******************************************************************************/
/* defines */
#define VETH_ASYNC_TIMEOUT  10          ///< async timeout until retransmission

/******************************************************************************/
/* typedefs */

typedef enum eVethTransmitState
{
    kVethError                 = 0x00,     ///< error happened (TODO: handle error?)
    kVethCheckForFrame         = 0x01,     ///< check for a new frame from stack
    kVethPostFrame             = 0x02,     ///< try to post frame to async state machine
    kVethWaitForTransmit       = 0x03,     ///< wait for async state machine to transfer finished

} tVethTransmitState;

/******************************************************************************/
/* structures */
typedef struct sVethDataTransfer {
    BYTE *                  m_pBuffer;          ///< pointer to data buffer
    unsigned int            m_uiSizeOfFrame;    ///< size of frame
} tVethDataTransfer;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
static tVethDataTransfer PdiVethTransfer_l;
static tVethTransmitState VethTransmitState_l = kVethCheckForFrame;
static BYTE fVethEnabled_l = FALSE;

/******************************************************************************/
/* function declarations */
static tPdiAsyncStatus CnApiAsyncVeth_handleDataTransfer(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                             BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p);
static tPdiAsyncStatus CnApiAsyncVeth_doDataTransfer(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pTxMsgBuffer_p,
                                       BYTE* pRxMsgBuffer_p, DWORD dwMaxTxBufSize_p        );
static tPdiAsyncStatus CnApiAsyncVeth_TxFinished (tPdiAsyncMsgDescr * pMsgDescr_p);

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  Init the Veth module

Init the RX and TX message types

\return tCnApiStatus
\retval kCnApiStatusOk             on successful init
\retval kCnApiStatusError          when the init failed
*******************************************************************************/
tCnApiStatus Gi_initVethMessages(void)
{
    tCnApiStatus iRet = kCnApiStatusOk;
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;

    /* init Veth Rx message */
    Ret = CnApiAsync_initMsg(kPdiAsyncMsgExtTxDataTransfer, kCnApiDirReceive, CnApiAsyncVeth_handleDataTransfer,
            &aPcpPdiAsyncRxMsgBuffer_g[1], kPdiAsyncMsgInvalid, kPdiAsyncTrfTypeAutoDecision,
            kAsyncChannelExternal, NULL, VETH_ASYNC_TIMEOUT);
    if (Ret != kPdiAsyncStatusSuccessful)
    {
        iRet = kCnApiStatusError;
        goto Exit;
    }

    /* init Veth Tx message */
    Ret = CnApiAsync_initMsg(kPdiAsyncMsgExtRxDataTransfer, kCnApiDirTransmit, CnApiAsyncVeth_doDataTransfer,
            &aPcpPdiAsyncTxMsgBuffer_g[1], kPdiAsyncMsgInvalid, kPdiAsyncTrfTypeUserBuffering,
            kAsyncChannelExternal, NULL, VETH_ASYNC_TIMEOUT);
    if (Ret != kPdiAsyncStatusSuccessful)
    {
        iRet = kCnApiStatusError;
        goto Exit;
    }

Exit:
    return iRet;
}

/**
********************************************************************************
\brief  Enable Veth frame transmission

Enable the Virtual Ethernet frame forwarding to the openPOWERLINK stack

*******************************************************************************/
void Gi_enableVeth(void)
{
    fVethEnabled_l = TRUE;
}

/**
********************************************************************************
\brief  Disable Veth frame transmission

Disable the Virtual Ethernet frame forwarding to the openPOWERLINK stack

*******************************************************************************/
void Gi_disableVeth(void)
{
    fVethEnabled_l = FALSE;
}

/**
********************************************************************************
\brief  Reset Veth module

Resets the internal Virtual Ethernet receive state machine
*******************************************************************************/
void Gi_resetVeth(void)
{
    VethTransmitState_l = kVethCheckForFrame;
}

/**
********************************************************************************
\brief  Forward the standard gateway to the PDI

Read the standard gateway from the Veth stack module and write it into the PDI.
*******************************************************************************/
void Gi_updateDefaultGateway(void)
{
    DWORD dwDefaultGateway = 0;

    dwDefaultGateway = VEthApiGetDefaultGateway();

    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwDefaultGateway, dwDefaultGateway);

    Gi_pcpEventPost(kPcpPdiEventGeneric, kPcpGenEventDefaultGatewayUpdate);
}

/**
********************************************************************************
\brief  process the Veth frames waiting

Check for new messages inside the stack and post them to the PDI

\return      tCnApiStatus
\retval      kCnApiStatusOk             on success
\retval      kCnApiStatusNoMsg          no message available
\retval      kCnApiStatusMsgBufFull     target buffer full
\retval      kCnApiStatusBusy           veth is currently waiting for transfer
\retval      kCnApiStatusError          error happened
*******************************************************************************/
tCnApiStatus Gi_processVeth(void)
{
    tEplKernel EplRet = kEplSuccessful;
    tPdiAsyncStatus PdiRet = kPdiAsyncStatusSuccessful;
    tCnApiStatus CnApiRet = kCnApiStatusOk;
    BYTE *pbRxBuffer    = NULL;    ///< pointer to the RX message buffer
    WORD bRxBufferSize = 0;       ///< size of the RX message


    switch(VethTransmitState_l)
    {
        case kVethCheckForFrame:
        {
            EplRet = VEthApiCheckAndForwardRxFrame(&pbRxBuffer, &bRxBufferSize);
            if(EplRet == kEplSuccessful)
            {
                // Frame received! (remember it for later posting)
                PdiVethTransfer_l.m_pBuffer = pbRxBuffer; ///< assign to Veth buffer
                PdiVethTransfer_l.m_uiSizeOfFrame = bRxBufferSize;

                VethTransmitState_l = kVethPostFrame;
                //fall through and post message
            } else {
                // no frame available (kCnApiStatusNoMsg)
                CnApiRet = kCnApiStatusNoMsg;
                break;
            }
        }
        case kVethPostFrame:
        {
            // try to post frame to async state machine
            PdiRet = CnApiAsync_postMsg(
                            kPdiAsyncMsgExtRxDataTransfer,
                            NULL,
                            CnApiAsyncVeth_TxFinished,
                            NULL,
                            PdiVethTransfer_l.m_pBuffer,
                            PdiVethTransfer_l.m_uiSizeOfFrame);
            if (PdiRet == kPdiAsyncStatusSuccessful)
            {
                DEBUG_LVL_CNAPI_VETH_INFO_TRACE1("VETHINFO: (%s) Frame received from "
                        "stack and posted!\n", __func__);
                VethTransmitState_l = kVethWaitForTransmit;
                CnApiRet = kCnApiStatusOk;
            }
            else if (PdiRet == kPdiAsyncStatusRetry)
            {
                CnApiRet = kCnApiStatusMsgBufFull;
            }
            else if (PdiRet != kPdiAsyncStatusSuccessful)
            {
                DEBUG_TRACE2(DEBUG_LVL_ERROR, "ERROR: (%s) Async module returned 0x%x! "
                        "Deactivate Veth frame forwarding!\n", __func__, PdiRet);
                VethTransmitState_l = kVethError;
                CnApiRet = kCnApiStatusError;
            }
            break;
        }
        case kVethWaitForTransmit:
        {
            // do nothing and wait for transfer finished callback
            CnApiRet = kCnApiStatusBusy;
            break;
        }
        case kVethError:
        {
            // always post error (module deactivated)
            CnApiRet = kCnApiStatusError;
            break;
        }
    }

    return CnApiRet;
}

/******************************************************************************/
/* private functions */

/**
********************************************************************************
\brief  handle an Veth RX message

Receive handler for Veth frames. Transfers the newly arrived message to the
stack.

\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pMsgBuffer_p        pointer to Rx message buffer (payload)
\param  pRespMsgBuffer_p    pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space

\return tPdiAsyncStatus
\retval kPdiAsyncStatusSuccessful            on success
\retval kPdiAsyncStatusInvalidInstanceParam  when input parameters are invalid
\retval kPdiAsyncStatusMtuExceeded           if the received message's MTU is too
                                             high
\retval kPdiAsyncStatusRetry                 when the internal stack buffer is
                                             full
\retval kPdiAsyncStatusSendError             on other error
*******************************************************************************/
static tPdiAsyncStatus CnApiAsyncVeth_handleDataTransfer(tPdiAsyncMsgDescr * pMsgDescr_p,
        BYTE* pMsgBuffer_p, BYTE* pRespMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tEplKernel         Ret = kEplSuccessful;
    tPdiAsyncStatus    cnApiRet = kPdiAsyncStatusSuccessful;

    /* check message descriptor */
    if (pMsgDescr_p == NULL ||
        pMsgBuffer_p == NULL )
    {
        cnApiRet = kPdiAsyncStatusInvalidInstanceParam;
        goto Exit;
    }

    // only forward frames when stack state is > NMT_CS_NOT_ACTIVE
    if(fVethEnabled_l != FALSE)
    {
        /* transmit this newly arrived message and pass to stack */
        Ret = VEthApiXmit(pMsgBuffer_p, pMsgDescr_p->dwMsgSize_m);
        switch(Ret)
        {
            case kEplSuccessful:
            {
                DEBUG_LVL_CNAPI_VETH_INFO_TRACE1("VETHINFO: (%s) Frame received from PDI "
                        "and transmitted to stack!\n", __func__);
                cnApiRet = kPdiAsyncStatusSuccessful;
                goto Exit;
            }
            case kEplInvalidParam:
            {   /* max MTU exceeded (report to AP) */
                cnApiRet = kPdiAsyncStatusMtuExceeded;
                goto Exit;
            }
            case kEplDllAsyncTxBufferFull:
            {
                /* stack buffer is full try to post the message later */
                cnApiRet = kPdiAsyncStatusRetry;
                goto Exit;
            }
            default:
            {
                DEBUG_TRACE1(DEBUG_LVL_ERROR, "Error: EplDllkCalAsyncSend returned 0x%02X\n", Ret);
                cnApiRet = kPdiAsyncStatusSendError;
                goto Exit;
            }
        }
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

\return tPdiAsyncStatus
\retval kPdiAsyncStatusSuccessful            on success
\retval kPdiAsyncStatusInvalidInstanceParam  when input parameters are invalid
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

    DEBUG_LVL_CNAPI_VETH_INFO_TRACE1("VETHINFO: (%s) Do transmit to PDI!\n", __func__);

Exit:
    return Ret;
}

/**
 ********************************************************************************
 \brief call back function, invoked after message transfer has finished
 \param  pMsgDescr_p         pointer to asynchronous message descriptor

 \return tPdiAsyncStatus
 \retval kPdiAsyncStatusSuccessful              on success
 \retval kPdiAsyncStatusInvalidOperation        on error
 \retval kPdiAsyncStatusInvalidInstanceParam    if message desc is null
 \retval kPdiAsyncStatusFreeError               when message buffer free fails


 This function is called after the Virtual Ethernet transfer is finished. It
 frees the receive buffer after the async state machine is finished.
 *******************************************************************************/
static tPdiAsyncStatus CnApiAsyncVeth_TxFinished (tPdiAsyncMsgDescr * pMsgDescr_p)
{
    tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;
    tEplKernel          EplRet = kEplSuccessful;

    if (pMsgDescr_p == NULL)  // message descriptor invalid
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto Exit;
    }

    if ((pMsgDescr_p->MsgStatus_m == kPdiAsyncMsgStatusTransferCompleted) &&
        (pMsgDescr_p->Error_m == kPdiAsyncStatusSuccessful)     )
    {
        DEBUG_LVL_CNAPI_VETH_INFO_TRACE1("VETHINFO: (%s) Transmit to PDI finished!\n", __func__);

        /* free Veth buffer */
        EplRet = VEthApiReleaseRxFrame();
        if(EplRet == kEplSuccessful)
        {
            // Transfer finished (send next!)
            VethTransmitState_l = kVethCheckForFrame;
        } else {
            DEBUG_TRACE0(DEBUG_LVL_ERROR, "Error while freeing the Veth Rx buffer\n");
            Ret = kPdiAsyncStatusFreeError;
            goto Exit;
        }
    }
    else if ((pMsgDescr_p->MsgStatus_m == kPdiAsyncMsgStatusError) &&
        (pMsgDescr_p->Error_m == kPdiAsyncStatusTimeout)     )
    {
        DEBUG_LVL_CNAPI_VETH_INFO_TRACE1("VETHINFO: (%s) Transmit to PDI timed out!\n", __func__);
        // timeout happened (retransmit frame!)
        Ret = kPdiAsyncStatusSuccessful;
        VethTransmitState_l = kVethCheckForFrame;

        goto Exit;
    }
    else
    {
        // other error happened (report back!)
        Ret = kPdiAsyncStatusInvalidOperation;

        goto Exit;
    }


Exit:
    return Ret;
}

#endif //VETH_DRV_EN

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


