/*******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1                           
* All rights reserved. All use of this software and documentation is          
* subject to the License Agreement located at the end of this file below.     
*/

/**
********************************************************************************

\file       cnApiAsyncSm.c

\brief      Asynchronous PDI state machine module

\author     hoggerm

\date       28.03.2011

\since      28.03.2011

This is the source file for the asynchronous communication between the
POWERLINK Communication Processor (PCP) and the Application Processor (AP)
using the Process Data Interface (PDI) as buffer. The communication is handled
with a state machine in order to avoid blocking. In this state machine,
the Tx and Rx direction towards and from the AP is handled.

*******************************************************************************/
/* includes */
#include "cnApiAsyncSm.h"    ///< external function declarations
#include "cnApiEvent.h"
#include "pcp.h"             ///< pcp PDI

#include <malloc.h>
#include <string.h>

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

// This state names must have the same order as the related constants
// in tAsyncState! The two leading "INITIAL" and "FINAL" states are mandatory!
char * strAsyncStateNames_l[] = { "INITIAL", "FINAL", "ASYNC_WAIT",   \
                                   "ASYNC_TX_BUSY", "ASYNC_TX_PENDING", \
                                   "ASYNC_RX_BUSY", "ASYNC_RX_PENDING", \
                                   "ASYNC_STOPPED"};
/* state machine */
static tStateMachine        PdiAsyncStateMachine_l;
static tState               aPdiAsyncStates_l[kPdiNumAsyncStates];
static tTransition          aPdiAsyncTransitions_l[MAX_TRANSITIONS_PER_STATE * kPdiNumAsyncStates];
static BOOL                 fError = FALSE;                 ///< transition event
static BOOL                 fTimeout = FALSE;               ///< transition event
static BOOL                 fReset = FALSE;                 ///< transition event
static BOOL                 fRxTriggered = FALSE;           ///< transition event -> explicitly wait for special message
static BOOL                 fTxTriggered = FALSE;           ///< transition event
static BOOL                 fFrgmtAvailable = FALSE;        ///< transition event
static BOOL                 fFrgmtStored = FALSE;           ///< transition event
static BOOL                 fFrgmtDelivered = FALSE;        ///< transition event
static BOOL                 fMsgTransferFinished = FALSE;   ///< transition event
static BOOL                 fMsgTransferIncomplete = FALSE; ///< transition event
static BOOL                 fFragmentedTransfer = FALSE;    ///< indicates stream segmentation
static BOOL                 fDeactivateRxMsg = FALSE;       ///< aid flag for not setting bActivRxMsg_l
                                                            ///< immediately to INVALID_ELEMENT

/* errors */
/* Asynchronous Transfers */
static tPdiAsyncMsgDescr aPdiAsyncRxMsgs[MAX_PDI_ASYNC_RX_MESSAGES] = {{0}};
static tPdiAsyncMsgLink  aPdiAsyncMsgLinkLog_l[(MAX_PDI_ASYNC_TX_MESSAGES + MAX_PDI_ASYNC_RX_MESSAGES)] = {{0}};
static BYTE              bActivTxMsg_l = INVALID_ELEMENT; ///< indicates inactive message
static BYTE              bActivRxMsg_l = INVALID_ELEMENT; ///< indicates inactive message
static BYTE *            pLclAsyncTxMsgBuffer_l = NULL;   ///< pointer to local Tx message buffer
static tPdiAsyncStatus            ErrorHistory_l = kPdiAsyncStatusSuccessful;

static BYTE *            pLclAsyncRxMsgBuffer_l = NULL;   ///< pointer to local Rx message buffer
static DWORD             dwTimeoutWait_l = 0;             ///< timeout counter

/** list of connections from original message to response message */
static tPdiAsyncMsgDescr aPdiAsyncTxMsgs[MAX_PDI_ASYNC_TX_MESSAGES] = {{0}};
static BYTE                     bLinkLogCounter_l = 0;    ///< counter of current links

/******************************************************************************/
/* function declarations */
static BOOL checkEvent(BOOL * pfEvent_p);
static inline void setBuffToReadOnly(tAsyncMsg * pPdiBuffer_p);
static inline void confirmFragmentReception(tAsyncMsg * pPdiBuffer_p);
static inline BOOL checkMsgDelivery(tAsyncMsg * pPdiBuffer_p);
static inline BOOL checkMsgPresence(tAsyncMsg * pPdiBuffer_p);
static tPdiAsyncStatus getArrayNumOfMsgDescr(tPdiAsyncMsgType MsgType_p,
                                             tPdiAsyncMsgDescr * paMsgDescr_p,
                                             BYTE * pbArgElement_p            );
static char * getStrgCurError (tPdiAsyncStatus status);

/******************************************************************************/
/* private functions */

/**
********************************************************************************
\brief  check for event
*******************************************************************************/
static BOOL checkEvent(BOOL * pfEvent_p)
{
    if (*pfEvent_p)
    {
        *pfEvent_p = FALSE;
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

/**
 ********************************************************************************
 \brief set the synchronization bit for an asynchronous PDI Tx (lock the buffer)
 \param	pPdiBuffer_p pointer to Pdi Buffer with structure tAsyncMsg
 *******************************************************************************/
static inline void setBuffToReadOnly(tAsyncMsg * pPdiBuffer_p)
{
    pPdiBuffer_p->m_header.m_bSync = kMsgBufReadOnly;
}

/**
 ********************************************************************************
 \brief set the synchronization bit for an asynchronous PDI Rx buffer (unlock the buffer)
 \param pPdiBuffer_p pointer to Pdi Buffer with structure tAsyncMsg
 *******************************************************************************/
static inline void confirmFragmentReception(tAsyncMsg * pPdiBuffer_p)
{
    pPdiBuffer_p->m_header.m_bSync = kMsgBufWriteOnly;
}

/**
 ********************************************************************************
 \brief Check the synchronization bit of an asynchronous PDI Tx buffer.
        If it has been freed, TRUE will be returned
 \param pPdiBuffer_p    pointer to Tx PDI Buffer with structure tAsyncMsg
 *******************************************************************************/
static inline BOOL checkMsgDelivery(tAsyncMsg * pPdiBuffer_p)
{
    if (pPdiBuffer_p->m_header.m_bSync == kMsgBufWriteOnly)
    {
        return TRUE; // message has been delivered
    }
    else
    {
        return FALSE; // message not yet delivered
    }
}

/**
 ********************************************************************************
 \brief Check the synchronization bit of an asynchronous PDI Rx buffer.
        If a Rx message is available, TRUE will be returned
 \param pPdiBuffer_p    pointer to Rx PDI Buffer with structure tAsyncMsg
 *******************************************************************************/
static inline BOOL checkMsgPresence(tAsyncMsg * pPdiBuffer_p)
{
    if (pPdiBuffer_p->m_header.m_bSync == kMsgBufReadOnly)
    {
        return TRUE; // message available
    }
    else
    {
        return FALSE; // no message present in Rx PDI buffer
    }
}

/**
 ********************************************************************************
 \brief	    returns the element number of the message descriptor array for a
            certain message type
 \param     MsgType_p           type of message which will be searched
 \param	    paMsgDescr_p		pointer to array of message descriptors
 \param     pbArgElement_p      in: max elements of array;
                                out: found element number of array or INVALID_ELEMENT
 \retval	kPdiAsyncStatusSuccessful	    if message type found
 \retval	kPdiAsyncStatusFreeInstance		if message type was not found, but free descriptor
 \retval    kPdiAsyncStatusNoFreeInstance   if no free descriptor found

The function will return the found array element number of the specified message type,
or if the message type has not been assigned yet, the number of a free message descriptor.
If there is no free element the argument INVALID_ELEMENT is returned.
 *******************************************************************************/
static tPdiAsyncStatus getArrayNumOfMsgDescr(tPdiAsyncMsgType MsgType_p,
                                             tPdiAsyncMsgDescr * paMsgDescr_p,
                                             BYTE * pbArgElement_p            )
{
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;
    BYTE bMaxArrayNum = 0;
    tPdiAsyncMsgDescr * pMsgDescr = NULL;
    BYTE bArrayNum;                 ///< loop counter and array element


    bMaxArrayNum = *pbArgElement_p - 1; // max array elements -1 = max array number
    pMsgDescr = paMsgDescr_p;

    for (bArrayNum = 0; bArrayNum < bMaxArrayNum; bArrayNum++, pMsgDescr++)
    {
        if (pMsgDescr->MsgType_m == MsgType_p)
        {
            /* message type found */
            *pbArgElement_p = bArrayNum;
            goto exit;
        }
    }

    pMsgDescr = paMsgDescr_p;
    /* message type not found -> search for free message descriptor */
    for (bArrayNum = 0; bArrayNum < bMaxArrayNum; bArrayNum++, pMsgDescr++)
    {
        if (pMsgDescr->MsgType_m == kPdiAsyncMsgInvalid)
        {
            /* free element found */
            *pbArgElement_p = bArrayNum;
            Ret = kPdiAsyncStatusFreeInstance;
            goto exit;
        }
    }

    /* no free element found */
    Ret = kPdiAsyncStatusNoFreeInstance;
    *pbArgElement_p = INVALID_ELEMENT;

exit:
    return Ret;
}

/**
********************************************************************************
\brief  get string of current PDI asynchronous module status
*******************************************************************************/
static char * getStrgCurError (tPdiAsyncStatus status)
{
    switch (status)
    {
        case kPdiAsyncStatusSuccessful           : return "PdiAsyncStatusSuccessful";
        case kPdiAsyncStatusSendError            : return "PdiAsyncStatusSendError";
        case kPdiAsyncStatusRespError            : return "PdiAsyncStatusRespError";
        case kPdiAsyncStatusChannelError         : return "PdiAsyncStatusChannelError";
        case kPdiAsyncStatusReqIdError           : return "PdiAsyncStatusReqIdError";
        case kPdiAsyncStatusTimeout              : return "PdiAsyncStatusTimeout";
        case kPdiAsyncStatusBufFull              : return "PdiAsyncStatusBufFull";
        case kPdiAsyncStatusBufEmpty             : return "PdiAsyncStatusBufEmpty";
        case kPdiAsyncStatusDataTooLong          : return "PdiAsyncStatusDataTooLong";
        case kPdiAsyncStatusIllegalInstance      : return "PdiAsyncStatusIllegalInstance";
        case kPdiAsyncStatusInvalidInstanceParam : return "PdiAsyncStatusInvalidInstanceParam ";
        case kPdiAsyncStatusNoFreeInstance       : return "PdiAsyncStatusNoFreeInstance";
        case kPdiAsyncStatusInvalidOperation     : return "PdiAsyncStatusInvalidOperation";
        case kPdiAsyncStatusNoResource           : return "PdiAsyncStatusNoResource";
        case kPdiAsyncStatusShutdown             : return "PdiAsyncStatusShutdown";
        case kPdiAsyncStatusReject               : return "PdiAsyncStatusReject";
        case kPdiAsyncStatusRetry                : return "PdiAsyncStatusRetry";
        case kPdiAsyncStatusInvalidEvent         : return "PdiAsyncStatusInvalidEvent";
        case kPdiAsyncStatusInvalidState         : return "PdiAsyncStatusInvalidState";
        case kPdiAsyncStatusInvalidMessage       : return "PdiAsyncStatusInvalidMessage";
        case kPdiAsyncStatusFreeInstance         : return "PdiAsyncStatusFreeInstance";
        case kPdiAsyncStatusUnhandledTransfer    : return "PdiAsyncStatusUnhandledTransfer";
        default:                                  return "--";
    }
}

/*******************************************************************************
 State machine functions

 The following section contains the event and action functions for the
 state machine.
*******************************************************************************/
//Explanation:
// STATE: use tAsyncState constants. NUM: =1 if this transition exists only once
// FUNC_ENTRYACT(STATE)              --> execute only at state entrance
// FUNC_DOACT(STATE)                 --> execute always when state is processed
// FUNC_EVT(STATE1,STATE2,NUM)       --> if return value is TRUE, do transition
// FUNC_TRANSACT(STATE1,STATE2,NUM)  --> execute something within this transition
// FUNC_EXITACT(STATE)               --> execute only at state exit
/*============================================================================*/
/* State: ASYNC_WAIT */
/*============================================================================*/
FUNC_ENTRYACT(kPdiAsyncStateWait)
{
  // in this state, it is assumed that Tx buffer is empty.
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPdiAsyncStateWait)
{
    BYTE         bMsgTypeField = 0;                     ///< pointer to command byte field of asynchr. message
    BYTE         bCurPdiChannelNum = INVALID_ELEMENT;   ///< current PDI channel number
    register BYTE bCnt = 0;                             ///< loop counter
    BYTE         bElement = INVALID_ELEMENT;            ///< function argument for getArrayNumOfMsgDescr()

    /* check if waiting for Rx message is required -> transit to  ASYNC_RX_PENDING*/
    if ((fRxTriggered == TRUE) || fTxTriggered == TRUE)
    {
        goto exit; // trigger ASYNC_RX_PENDING or ASYNC_TX_BUSY
    }

    /* check if external Rx message is available */
    for (bCnt = 0; bCnt < PDI_ASYNC_CHANNELS_MAX; ++bCnt)
    {
        if (checkMsgPresence(aPcpPdiAsyncRxMsgBuffer_g[bCnt].pAdr_m))
        {
            bCurPdiChannelNum = bCnt; // set current Rx PDI channel
            break;
        }
    }

    /* check if internal Rx message is available */
    for (bCnt = 0; bCnt < PDI_ASYNC_CHANNELS_MAX; ++bCnt)
    {
        if (checkMsgPresence(aPcpPdiAsyncRxMsgBuffer_g[bCnt].pAdr_m) &&
            aPcpPdiAsyncRxMsgBuffer_g[bCnt].pAdr_m->m_header.m_bChannel == kAsyncChannelInternal)
        {
            bCurPdiChannelNum = bCnt; // overwrite previous found element
            break;
        }
    }

    /* if Rx message is available -> transit to ASYNC_RX_BUSY */
    if (bCurPdiChannelNum != INVALID_ELEMENT)
    {
        /* get message type and assign descriptor */
        bMsgTypeField = aPcpPdiAsyncRxMsgBuffer_g[bCurPdiChannelNum].pAdr_m->m_header.m_bMsgType;

        bElement = MAX_PDI_ASYNC_RX_MESSAGES;
        ErrorHistory_l = getArrayNumOfMsgDescr(bMsgTypeField, aPdiAsyncRxMsgs, &bElement);
        if (ErrorHistory_l != kPdiAsyncStatusSuccessful)
        {/* descriptor not found */
            fError = TRUE; // trigger transition
            goto exit;
        }
        else
        {/* descriptor found */
            bActivRxMsg_l = bElement; // set active Rx element
        }

        /* verify Rx channel */
        if (aPcpPdiAsyncRxMsgBuffer_g[bCurPdiChannelNum].pAdr_m != aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->pAdr_m)
        {
            ErrorHistory_l = kPdiAsyncStatusChannelError;
            fError = TRUE; // message was received in wrong buffer!
            goto exit;
        }

        fFrgmtAvailable = TRUE; // trigger transition
        goto exit;
    }


    /* if Tx message is available -> transit to ASYNC_TX_BUSY */

    /* check if external Tx message is due (low priority) */
    for (bCnt = 0; bCnt < MAX_PDI_ASYNC_TX_MESSAGES; ++bCnt)
    {
        if ((aPdiAsyncTxMsgs[bCnt].fMsgValid_m == TRUE))
        {
            bActivTxMsg_l = bCnt;   // activate first found element
            break;
        }
    }

    /* check if internal Tx message is due (high priority) */
    for (bCnt = 0; bCnt < MAX_PDI_ASYNC_TX_MESSAGES; ++bCnt)
    {
        if ((aPdiAsyncTxMsgs[bCnt].fMsgValid_m == TRUE) &&
            (aPdiAsyncTxMsgs[bCnt].Param_m.ChanType_m == kAsyncChannelInternal))
        {
            bActivTxMsg_l = bCnt;   // overwrite previous found element
            break;
        }
    }
    if (bActivTxMsg_l == INVALID_ELEMENT)
    {
        goto exit; // no message activated -> nothing to do
    }
    else // message activated
    {
        /*transit to ASYNC_TX_BUSY */
        fTxTriggered = TRUE;
        goto exit;
    }

exit:
     return;

}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncStateWait, kPdiAsyncRxStateBusy, 1)
{
    return checkEvent(&fFrgmtAvailable);  //Rx message is present -> transit
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncStateWait, kPdiAsyncTxStateBusy, 1)
{
    return checkEvent(&fTxTriggered); //Tx message will be sent -> transit
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncStateWait, kPdiAsyncRxStatePending, 1)
{
    return checkEvent(&fRxTriggered);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncStateWait, kPdiAsyncStateStopped, 1)
{   /* error happened (e.g. timeout) -> state ASYNC_STOPPED */
    return checkEvent(&fError);
}

/*============================================================================*/
/* State: ASYNC_TX_BUSY */
/*============================================================================*/
FUNC_ENTRYACT(kPdiAsyncTxStateBusy)
{
    tAsyncMsg *     pUtilTxPdiBuf = NULL;   ///< Tx Pdi Buffer utilized by message
    tPdiAsyncMsgDescr * pMsgDescr = NULL;   ///< pointer to current message descriptor
    WORD          wCopyLength   = 0;        ///< length of data to be copied (for local buffered transfer)
    DWORD         dwMaxBufPayload = 0;      ///< maximum payload for message storage
    BYTE*         pCurLclMsgFrgmt = 0;      ///< pointer to currently handled local message fragment

    if (bActivTxMsg_l == INVALID_ELEMENT)
    {
        ErrorHistory_l = kPdiAsyncStatusIllegalInstance;
        fError = TRUE; // Tx triggered, but no element assigned -> error
        goto exit;
    }

    pMsgDescr = &aPdiAsyncTxMsgs[bActivTxMsg_l];

    /* 1st fragment -> initialize message descriptor values */
    if (pMsgDescr->dwPendTranfSize_m == 0)
    {
        /* check if message transfer exceeds maximum stream size */
        if (pMsgDescr->dwMsgSize_m > MAX_ASYNC_STREAM_LENGTH)
        {
            /* reject transfer */
            ErrorHistory_l = kPdiAsyncStatusDataTooLong;
            fError = TRUE;
            goto exit;
        }
        else
        {
            /* set pending payload length */
            pMsgDescr->dwPendTranfSize_m = pMsgDescr->dwMsgSize_m;
        }
    }

    pUtilTxPdiBuf = pMsgDescr->pPdiBuffer_m->pAdr_m; //assign Pdi Tx buffer which this message wants to use

    //TODO: check if this message is allowed in the current NmtState

    /* different handling of Pdi Buffer access */
    switch (pMsgDescr->TransfType_m)
    {

        case kPdiAsyncTrfTypeLclBuffering:
        {/* local buffered transfer */

            if (pMsgDescr->MsgHdl_m.pLclBuf_m == NULL )
            {
                ErrorHistory_l = kPdiAsyncStatusInvalidInstanceParam;
                fError = TRUE; // triggers transition
                goto exit;
            }

            /* check if message transfer needs to be fragmented */
            if (pMsgDescr->dwPendTranfSize_m > pMsgDescr->pPdiBuffer_m->wMaxPayload_m)
            {
                /* use whole buffer size and indicate fragmentation */
                wCopyLength = pMsgDescr->pPdiBuffer_m->wMaxPayload_m;
                fFragmentedTransfer = TRUE;
            }
            else
            {
                /* remaining size fits in buffer (= last fragment) */
                wCopyLength = pMsgDescr->dwPendTranfSize_m;
            }

            /* calculate start address of new local buffer fragment */
            pCurLclMsgFrgmt = pMsgDescr->MsgHdl_m.pLclBuf_m +
                              (pMsgDescr->dwMsgSize_m - pMsgDescr->dwPendTranfSize_m);

            /* copy local buffer fragment into the PDI buffer */
            memcpy(&pMsgDescr->pPdiBuffer_m->pAdr_m->m_chan, pCurLclMsgFrgmt, wCopyLength);

            pUtilTxPdiBuf->m_header.m_wFrgmtLen = wCopyLength;  // update  PDI buffer control header

            break;
        }

        case kPdiAsyncTrfTypeDirectAccess:
        {/* direct buffer access */

            /* invoke call-back function which fills PDI buffer Tx once. */
            if (pMsgDescr->MsgHdl_m.pfnCbMsgHdl_m != NULL) //otherwise buffer has already been set up by Rx handle
            {
                /* setup message buffer directly */
                dwMaxBufPayload = pMsgDescr->pPdiBuffer_m->wMaxPayload_m;

                // Check within call-back function if expected message size exceeds the PDI buffer!
                // Also, call-back function has to write the written message size 'dwMsgSize_m' to the Tx descriptor.
                ErrorHistory_l = pMsgDescr->MsgHdl_m.pfnCbMsgHdl_m(pMsgDescr,
                                                                   (BYTE *) &pMsgDescr->pPdiBuffer_m->pAdr_m->m_chan,
                                                                   (BYTE *) &pMsgDescr->pRespMsgDescr_m->pPdiBuffer_m->pAdr_m->m_chan,
                                                                   dwMaxBufPayload);
                if (ErrorHistory_l != kPdiAsyncStatusSuccessful)
                {
                    fError = TRUE; // triggers transition
                    goto exit;
                }

                if (pMsgDescr->dwMsgSize_m > dwMaxBufPayload)
                {
                    ErrorHistory_l = kPdiAsyncStatusDataTooLong; // to much data written to buffer!
                    fError = TRUE; // triggers transition
                    goto exit;
                }
            }

            /* setup the buffer header with the actual written size, which the call-back function has updated */
            pUtilTxPdiBuf->m_header.m_wFrgmtLen = pMsgDescr->dwMsgSize_m; // update  PDI buffer control header

            break;
        }

        default:
        {
            break;
        }
    }

    // Note: Buffer is assumed to be available since this state was entered. No sync check necessary.
    /* setup PDI buffer control header */
    pUtilTxPdiBuf->m_header.m_bChannel =  pMsgDescr->Param_m.ChanType_m;
    pUtilTxPdiBuf->m_header.m_bMsgType = pMsgDescr->MsgType_m;
    pUtilTxPdiBuf->m_header.m_dwStreamLen = pMsgDescr->dwMsgSize_m;
    setBuffToReadOnly(pUtilTxPdiBuf); // set sync flag

    fFrgmtStored = TRUE; // transit to ASYNC_TX_PENDING;

exit:
    return;
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPdiAsyncTxStateBusy)
{

}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncTxStateBusy, kPdiAsyncTxStatePending, 1)
{
    return checkEvent(&fFrgmtStored);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncTxStateBusy, kPdiAsyncStateStopped, 1)
{ /* error happened -> state ASYNC_STOPPED */
    return checkEvent(&fError);
}
/*============================================================================*/
/* State: ASYNC_TX_PENDING */
/*============================================================================*/
FUNC_ENTRYACT(kPdiAsyncTxStatePending)
{
    if ((aPdiAsyncTxMsgs[bActivTxMsg_l].Param_m.wTimeout_m > 0) && (dwTimeoutWait_l == 0))
    { /* set timeout value for this message for the fist time */
        dwTimeoutWait_l = aPdiAsyncTxMsgs[bActivTxMsg_l].Param_m.wTimeout_m * PCP_ASYNCSM_TIMEOUT_FACTOR;
    }
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPdiAsyncTxStatePending)
{
    BYTE         bElement = INVALID_ELEMENT;            ///< function argument for getArrayNumOfMsgDescr()

    // check if message has been delivered
    if (checkMsgDelivery(aPdiAsyncTxMsgs[bActivTxMsg_l].pPdiBuffer_m->pAdr_m))
    {
        /* message has been delivered */
        if (checkEvent(&fFragmentedTransfer))
        {
            /* calculate new pending payload */
            aPdiAsyncTxMsgs[bActivTxMsg_l].dwPendTranfSize_m -= aPdiAsyncTxMsgs[bActivTxMsg_l].pPdiBuffer_m->wMaxPayload_m;
            fFrgmtDelivered = TRUE;
            goto exit;
        }
        else /* it was the last segment */
        {
            aPdiAsyncTxMsgs[bActivTxMsg_l].dwPendTranfSize_m = 0; // finished
            fMsgTransferFinished = TRUE;

            /* call user call back, if assigend */
            if (aPdiAsyncTxMsgs[bActivTxMsg_l].pfnTransferFinished_m != NULL)
            {
                ErrorHistory_l = aPdiAsyncTxMsgs[bActivTxMsg_l].pfnTransferFinished_m(&aPdiAsyncTxMsgs[bActivTxMsg_l]);

                if (ErrorHistory_l != kPdiAsyncStatusSuccessful)
                {
                    fError = TRUE; // triggers transition
                    goto exit;
                }
            }

            if (aPdiAsyncTxMsgs[bActivTxMsg_l].pRespMsgDescr_m != NULL )
            {/* if response is expected, force Rx Pending */
                bElement = MAX_PDI_ASYNC_RX_MESSAGES;
                ErrorHistory_l = getArrayNumOfMsgDescr(aPdiAsyncTxMsgs[bActivTxMsg_l].pRespMsgDescr_m->MsgType_m,
                                                       aPdiAsyncRxMsgs, &bElement);
                if (ErrorHistory_l != kPdiAsyncStatusSuccessful)
                {
                    fError = TRUE; // triggers transition
                    goto exit;
                }
                else
                {
                    /* deactivate Tx message */
                    aPdiAsyncTxMsgs[bActivTxMsg_l].fMsgValid_m = FALSE; // tag as obsolete
                    bActivTxMsg_l = INVALID_ELEMENT;

                    /* set active Rx element and trigger Rx pending */
                    bActivRxMsg_l = bElement;
                    fRxTriggered = TRUE; // set flag for state ASYNC_WAIT
                    goto exit;
                }
            }

            /* free allocated buffers*/
            switch (aPdiAsyncTxMsgs[bActivTxMsg_l].TransfType_m)
            {
                case kPdiAsyncTrfTypeLclBuffering:
                {
                    CNAPI_FREE(pLclAsyncTxMsgBuffer_l);

                    break;
                }

                case kPdiAsyncTrfTypeDirectAccess:
                default:
                    break;
            }

            /* deactivate Tx message */
            aPdiAsyncTxMsgs[bActivTxMsg_l].fMsgValid_m = FALSE; // tag as obsolete
            bActivTxMsg_l = INVALID_ELEMENT;

            /* if Tx response was triggered by Rx message, free and deactivate also Rx message */
            if (bActivRxMsg_l != INVALID_ELEMENT)
            {
                /* free allocated buffers */
                switch (aPdiAsyncRxMsgs[bActivRxMsg_l].TransfType_m)
                {
                    case kPdiAsyncTrfTypeLclBuffering:
                    {
                        CNAPI_FREE(pLclAsyncRxMsgBuffer_l);

                        break;
                    }

                    case kPdiAsyncTrfTypeDirectAccess:
                    {

                    }
                    default:
                    break;
                }
                /* deactivate Rx message */
                aPdiAsyncRxMsgs[bActivRxMsg_l].fMsgValid_m = FALSE; // tag as obsolete
                bActivRxMsg_l = INVALID_ELEMENT;
            }

            goto exit;
        }
    }
    else // message has not been delivered
    {
        /* check timeout only if value is assigned */
        if (aPdiAsyncTxMsgs[bActivTxMsg_l].Param_m.wTimeout_m != 0)
        {
            /* delivery pending -> check again or issue timeout */
            dwTimeoutWait_l--;
            if (dwTimeoutWait_l == 0)
            {
               ErrorHistory_l = kPdiAsyncStatusTimeout;
               fError = TRUE;
               goto exit;
            }
        }
    }

exit:
    return;
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncTxStatePending, kPdiAsyncStateWait, 1)
{ /* message transfer completed */
    return checkEvent(&fMsgTransferFinished);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncTxStatePending, kPdiAsyncTxStateBusy, 1)
{ /* message transfer still incomplete */
    return checkEvent(&fFrgmtDelivered);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncTxStatePending, kPdiAsyncStateStopped, 1)
{ /* error happened (e.g. timeout) -> state ASYNC_STOPPED */
    return checkEvent(&fError);
}
/*============================================================================*/
/* State: ASYNC_RX_BUSY */
/*============================================================================*/
FUNC_ENTRYACT(kPdiAsyncRxStateBusy)
{
    tAsyncMsg *   pUtilRxPdiBuf = NULL;     ///< Tx Pdi Buffer utilized by message
    tPdiAsyncMsgDescr * pMsgDescr = NULL;   ///< pointer to current message descriptor
    WORD          wCopyLength   = 0;        ///< length of data to be copied (for local buffered transfer)
    DWORD         dwMaxBufPayload = 0;      ///< maximum payload for message storage
    BYTE *        pCurLclMsgFrgmt = NULL;   ///< pointer to currently handled local message fragment
    BYTE *        pRespChan = NULL;         ///< pointer to Tx response message payload
    BYTE *        pRxChan = NULL;           ///< pointer to Rx message payload
    BYTE          bElement = INVALID_ELEMENT;///< function argument for getArrayNumOfMsgDescr()


    if (bActivRxMsg_l == INVALID_ELEMENT)
    {
        ErrorHistory_l = kPdiAsyncStatusIllegalInstance;
        fError = TRUE; // Rx Busy triggered, but no element assigned -> error
        goto exit;
    }

    /* initialize temporary pointers */
    pMsgDescr = &aPdiAsyncRxMsgs[bActivRxMsg_l];
    pUtilRxPdiBuf = pMsgDescr->pPdiBuffer_m->pAdr_m;

    /* verify message type */
    if (pMsgDescr->pPdiBuffer_m->pAdr_m->m_header.m_bMsgType != pMsgDescr->MsgType_m)
    {
        ErrorHistory_l = kPdiAsyncStatusInvalidMessage;
        fError = TRUE;
        goto exit;
    }

    //TODO: check if this message is allowed in the current NmtState

    /* initialization for 1st fragment */
    if (pMsgDescr->dwPendTranfSize_m == 0) //indicates 1st fragment
    {
        /* choose transfer type according to message size */
        if (pMsgDescr->pPdiBuffer_m->pAdr_m->m_header.m_dwStreamLen > MAX_ASYNC_STREAM_LENGTH)
        { /* data size exceeded -> reject transfer */
            ErrorHistory_l = kPdiAsyncStatusDataTooLong;
            fError = TRUE;
            goto exit;
        }
        else if (pMsgDescr->pPdiBuffer_m->pAdr_m->m_header.m_dwStreamLen > pMsgDescr->pPdiBuffer_m->wMaxPayload_m)
        { /* message fits in local buffer */
            pMsgDescr->TransfType_m = kPdiAsyncTrfTypeLclBuffering;

            /* allocate memory for local storage */
            //TODO: Multiple access to this function have to be restricted to 2 (for each channel and lcl buffering) (+ memory space restriction and multiple message activation)
            if (pLclAsyncRxMsgBuffer_l != NULL)
            {
                /* memory already allocated !*/
                ErrorHistory_l = kPdiAsyncStatusNoResource;
                fError = TRUE;
                goto exit;
            }

            /* allocate data block for Rx message payload */
            pLclAsyncRxMsgBuffer_l = (BYTE *) CNAPI_MALLOC(pMsgDescr->pPdiBuffer_m->pAdr_m->m_header.m_dwStreamLen);

            if (pLclAsyncRxMsgBuffer_l == NULL)
            {
                ErrorHistory_l = kPdiAsyncStatusNoResource;
                fError = TRUE;
                goto exit;
            }
            else
            {
                pMsgDescr->MsgHdl_m.pLclBuf_m = pLclAsyncRxMsgBuffer_l;
            }
        }
        else
        { /* message fits PDI buffer */
            pMsgDescr->TransfType_m = kPdiAsyncTrfTypeDirectAccess;
        }

        /* initialize message header values */
        pMsgDescr->dwMsgSize_m = pMsgDescr->pPdiBuffer_m->pAdr_m->m_header.m_dwStreamLen;
        pMsgDescr->dwPendTranfSize_m = pMsgDescr->dwMsgSize_m;
    }/* initialization for 1st fragment finished */

    /* process Rx message */
    switch (pMsgDescr->TransfType_m)
    {
        case kPdiAsyncTrfTypeLclBuffering:
        {
            if (pMsgDescr->MsgHdl_m.pLclBuf_m == NULL )
            {
                ErrorHistory_l = kPdiAsyncStatusInvalidInstanceParam;
                fError = TRUE; // triggers transition
                goto exit;
            }

            /* check inconsistent message header values */
            if (pUtilRxPdiBuf->m_header.m_wFrgmtLen > pMsgDescr->pPdiBuffer_m->wMaxPayload_m)
            {
                ErrorHistory_l = kPdiAsyncStatusDataTooLong;
                fError = TRUE;
                goto exit;
            }
            else
            {
                wCopyLength = pUtilRxPdiBuf->m_header.m_wFrgmtLen;
            }

            /* calculate start address of new local buffer fragment */
            pCurLclMsgFrgmt = pMsgDescr->MsgHdl_m.pLclBuf_m +
                              (pMsgDescr->dwMsgSize_m - pMsgDescr->dwPendTranfSize_m);

            /* copy local buffer fragment into the PDI buffer */
            memcpy(pCurLclMsgFrgmt, &pMsgDescr->pPdiBuffer_m->pAdr_m->m_chan,  wCopyLength);

            /* calculate new pending payload */
            pMsgDescr->dwPendTranfSize_m -= wCopyLength;

            if (pMsgDescr->dwPendTranfSize_m > pMsgDescr->dwMsgSize_m)
            {
                ErrorHistory_l = kPdiAsyncStatusDataTooLong;
                fError = TRUE;
                goto exit;
            }
            else if (pMsgDescr->dwPendTranfSize_m > 0)
            {
                /* wait for next fragment */
                fMsgTransferIncomplete = TRUE; // trigger transition to ASYNC_RX_PENDING
                goto exit;
            }
            else // pMsgDescr->dwPendTranfSize_m == 0
            {/* transfer has finished  */
                pRxChan = pMsgDescr->MsgHdl_m.pLclBuf_m;
                pMsgDescr->fMsgValid_m = TRUE; // tag message payload as complete
            }

            break;
        }

        case kPdiAsyncTrfTypeDirectAccess:
        {
            pRxChan = (BYTE *) &pMsgDescr->pPdiBuffer_m->pAdr_m->m_chan;
            pMsgDescr->fMsgValid_m = TRUE; // tag message payload as complete
            break;
        }

        default:
        break;
    }

    /* Rx transfer has finished -> handle Rx message */
    if (pMsgDescr->fMsgValid_m)
    {
        if (pMsgDescr->MsgHdl_m.pfnCbMsgHdl_m != NULL)
        {/* prepare Rx call back */

            /* handle an optional Tx response */
            if (pMsgDescr->pRespMsgDescr_m != NULL)
            {

                if (pMsgDescr->pRespMsgDescr_m->MsgHdl_m.pfnCbMsgHdl_m != NULL)
                {/* call-back for Tx buffer filling is already assigned -> Tx Buffer access not allowed in Rx call back! */
                    dwMaxBufPayload = 0;
                    pRespChan = NULL;
                    // Note: not a good idea to access Rx buffer from response Tx handle, because it blocks Rx finishing.
                    //       -> set up response buffer in Rx handle

                    /* setting up a Rx-handle buffer in Tx call-back function is not allowed */
                    ErrorHistory_l = kPdiAsyncStatusInvalidOperation;
                    fError = TRUE;
                    goto exit;
                }
                else /* Rx call-back is allowed to fill the Tx Buffer*/
                {
                    switch (pMsgDescr->pRespMsgDescr_m->TransfType_m)
                    {
                        case kPdiAsyncTrfTypeLclBuffering:
                        {
                            //no call-back assigned, so this will only allocate the Tx buffer
                            CnApiAsync_postMsg(pMsgDescr->pRespMsgDescr_m->MsgType_m, 0, 0 ,0); // message is set to valid

                            dwMaxBufPayload = MAX_ASYNC_STREAM_LENGTH;
                            pRespChan = pMsgDescr->pRespMsgDescr_m->MsgHdl_m.pLclBuf_m;
                            break;
                        }

                        case kPdiAsyncTrfTypeDirectAccess:
                        {
                            dwMaxBufPayload = pMsgDescr->pRespMsgDescr_m->pPdiBuffer_m->wMaxPayload_m;
                            pRespChan = (BYTE *) &pMsgDescr->pRespMsgDescr_m->pPdiBuffer_m->pAdr_m->m_chan;
                            break;
                        }

                        default:
                        break;
                    }
                }
            }
            else /* Rx message has no Tx response -> no Tx buffer access needed*/
            {
                dwMaxBufPayload = 0;
                pRespChan = NULL;
            }

            /* invoke call-back function which reads the PDI Rx buffer once and optionally fills the Tx buffer */
            // Check within call-back function if expected message size exceeds the Tx PDI buffer!
            // Also, call-back function has to write the written message size 'dwMsgSize_m' to the Tx descriptor.
            ErrorHistory_l = pMsgDescr->MsgHdl_m.pfnCbMsgHdl_m(pMsgDescr, pRxChan, pRespChan, dwMaxBufPayload);
            if (ErrorHistory_l != kPdiAsyncStatusSuccessful)
            {
                fError = TRUE; // triggers transition
                goto exit;
            }
        }
        else /* handling has to take place in Tx handle */
        {
            if ((pMsgDescr->pRespMsgDescr_m->MsgHdl_m.pfnCbMsgHdl_m == NULL))
            {/* no Tx handle*/
                ErrorHistory_l = kPdiAsyncStatusUnhandledTransfer;
                fError = TRUE;
                goto exit;
            }
            else /* response Tx handle assigned */
            {
                // Note: not a good idea to access Rx buffer from response Tx handle, because it blocks Rx finishing.
                //       -> better set up response buffer in Rx handle

                /* setting up a Rx buffer in Tx call-back function is not allowed */
                ErrorHistory_l = kPdiAsyncStatusInvalidOperation;
                fError = TRUE;
                goto exit;
            }
        }

        /* call user call back, if assigend */
        if (pMsgDescr->pfnTransferFinished_m != NULL)
        {
            ErrorHistory_l = pMsgDescr->pfnTransferFinished_m(pMsgDescr);

            if (ErrorHistory_l != kPdiAsyncStatusSuccessful)
            {
                fError = TRUE; // triggers transition
                goto exit;
            }
        }

        /* force ASYNC_TX_BUSY if Tx response is assigned */
        if (pMsgDescr->pRespMsgDescr_m != NULL ) // Tx response assigned -> free Rx message in ASYNC_TX_PENDING
        {
            bElement = MAX_PDI_ASYNC_TX_MESSAGES;
            ErrorHistory_l = getArrayNumOfMsgDescr(pMsgDescr->pRespMsgDescr_m->MsgType_m,
                                                   aPdiAsyncTxMsgs, &bElement);
            if (ErrorHistory_l != kPdiAsyncStatusSuccessful)
            {
                fError = TRUE; // triggers transition
                goto exit;
            }
            else
            {/* set active Tx element and trigger Tx busy */
                bActivTxMsg_l = bElement;
                fTxTriggered = TRUE; // set flag for state ASYNC_WAIT
                fMsgTransferFinished = TRUE; // transit to ASYNC_WAIT
                goto exit;
            }
        }
        else // no Tx response assigned -> free Rx message now
        {
            /* free allocated buffers */
            switch (pMsgDescr->TransfType_m)
            {
                case kPdiAsyncTrfTypeLclBuffering:
                {
                    CNAPI_FREE(pLclAsyncRxMsgBuffer_l);

                    break;
                }

                case kPdiAsyncTrfTypeDirectAccess:
                {

                }
                default:
                break;
            }

            /* deactivate Rx message */
            pMsgDescr->fMsgValid_m = FALSE; // tag as obsolete
            fDeactivateRxMsg = TRUE; // set bActivRxMsg_l to INVALID_ELEMENT at transition
        }

        fMsgTransferFinished = TRUE;
        goto exit;
    }

exit:
    return;
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPdiAsyncRxStateBusy)
{
// do this if you add code here!: if (fError == TRUE)
//    {
//        goto exit;
//    }
//
//    ... code ...
//
//exit:
//    return;
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncRxStateBusy, kPdiAsyncStateWait, 1)
{
    if (checkEvent(&fMsgTransferFinished))
    {
        confirmFragmentReception(aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->pAdr_m);
        if (checkEvent(&fDeactivateRxMsg))
        {
            bActivRxMsg_l = INVALID_ELEMENT;
        }
        return TRUE; // do transition
    }
    else
    {
        return FALSE; // do not transit
    }
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncRxStateBusy, kPdiAsyncRxStatePending, 1)
{
    if (checkEvent(&fMsgTransferIncomplete))
    {
        confirmFragmentReception(aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->pAdr_m);
        return TRUE; // do transition
    }
    else
    {
        return FALSE; // do not transit
    }
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncRxStateBusy, kPdiAsyncStateStopped, 1)
{ /* error happened -> state ASYNC_STOPPED */
    return checkEvent(&fError);
}
/*============================================================================*/
/* State: ASYNC_RX_PENDING */
/*============================================================================*/
FUNC_ENTRYACT(kPdiAsyncRxStatePending)
{
    if (bActivRxMsg_l == INVALID_ELEMENT)
    {
        ErrorHistory_l = kPdiAsyncStatusIllegalInstance;
        fError = TRUE; // Rx triggered, but no element assigned -> error
        goto exit;
    }

    if ((aPdiAsyncRxMsgs[bActivRxMsg_l].Param_m.wTimeout_m > 0) && (dwTimeoutWait_l == 0))
    { /* set timeout value for this message for the fist time */
        dwTimeoutWait_l = aPdiAsyncRxMsgs[bActivRxMsg_l].Param_m.wTimeout_m * PCP_ASYNCSM_TIMEOUT_FACTOR;
    }

exit:
    return;
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPdiAsyncRxStatePending)
{
    if (fError == TRUE)
    {
        goto exit;
    }

    /* check if fragment is present */
    if (checkMsgPresence(aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->pAdr_m))
    {/* fragment is available in Rx buffer */

        if (aPdiAsyncRxMsgs[bActivRxMsg_l].MsgType_m !=
            aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->pAdr_m->m_header.m_bMsgType)
        {
            ErrorHistory_l = kPdiAsyncStatusInvalidMessage;
            fError = TRUE;
        }
        else // expected message fragment received
        {
            fFrgmtAvailable = TRUE; // trigger transition
        }
        goto exit;
    }
    else // no fragment present in Rx buffer
    {
        /* check timeout only if value is assigned */
        if (aPdiAsyncRxMsgs[bActivRxMsg_l].Param_m.wTimeout_m != 0)
        {
            /* reception pending -> check again or issue timeout */
            dwTimeoutWait_l--;
            if (dwTimeoutWait_l == 0)
            {
               ErrorHistory_l = kPdiAsyncStatusTimeout;
               fError = TRUE;
               goto exit;
            }
        }
    }

exit:
    return;
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncRxStatePending, kPdiAsyncRxStateBusy, 1)
{
    return checkEvent(&fFrgmtAvailable);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncRxStatePending, kPdiAsyncStateStopped, 1)
{ /* error happened (e.g. timeout) -> state ASYNC_STOPPED */
    return checkEvent(&fError);
}
/*============================================================================*/
/* State: ASYNC_STOPPED */
/*============================================================================*/
FUNC_ENTRYACT(kPdiAsyncStateStopped)
{
    /* handle errors */

    /* deactivate active messages */
    if (bActivTxMsg_l != INVALID_ELEMENT)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ASYNC_INFO, "Tx message type: %d\n",
                     aPdiAsyncTxMsgs[bActivTxMsg_l].MsgType_m);

        if (aPdiAsyncTxMsgs[bActivTxMsg_l].Param_m.ChanType_m == kAsyncChannelInternal)
        {
            if (ErrorHistory_l != kPdiAsyncStatusTimeout)
            { /* timeout error has extra treatment - don't handle it here */
                Gi_throwPdiEvent(kPcpPdiEventGenericError, kPcpGenErrAsyncIntChanComError);
            }
        }
        /* set invalid */
        aPdiAsyncTxMsgs[bActivTxMsg_l].fMsgValid_m = FALSE;
        bActivTxMsg_l = INVALID_ELEMENT;
    }

    if (bActivRxMsg_l != INVALID_ELEMENT)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ASYNC_INFO, "Rx message type: %d\n",
                     aPdiAsyncRxMsgs[bActivRxMsg_l].MsgType_m);

        confirmFragmentReception(aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->pAdr_m);

        if (aPdiAsyncTxMsgs[bActivTxMsg_l].Param_m.ChanType_m == kAsyncChannelInternal)
        {
            if (ErrorHistory_l != kPdiAsyncStatusTimeout)
            { /* timeout error has extra treatment - don't handle it here */
                Gi_throwPdiEvent(kPcpPdiEventGenericError, kPcpGenErrAsyncIntChanComError);
            }
        }

        /* set invalid */
        aPdiAsyncRxMsgs[bActivRxMsg_l].fMsgValid_m = FALSE;
        bActivRxMsg_l = INVALID_ELEMENT;
    }

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_ERR, "%s status: %s\n",
                                __func__, getStrgCurError(ErrorHistory_l));

    /* free buffers */
    if (pLclAsyncTxMsgBuffer_l != NULL)
    {
        CNAPI_FREE(pLclAsyncTxMsgBuffer_l);
    }

    if (pLclAsyncRxMsgBuffer_l != NULL)
    {
        CNAPI_FREE(pLclAsyncRxMsgBuffer_l);
    }

    /* timeout handling */
    if (ErrorHistory_l == kPdiAsyncStatusTimeout)
    { /* reset timeout counter */
        dwTimeoutWait_l = 0;

        Gi_throwPdiEvent(kPcpPdiEventGenericError, kPcpGenErrAsyncComTimeout);
    }

    /* reset the error, because we have already handled it */
    ErrorHistory_l = kPdiAsyncStatusSuccessful;
    fReset = TRUE; //Transit to ASYNC_WAIT
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPdiAsyncStateStopped)
{

}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncStateStopped, kPdiAsyncStateWait, 1)
{
    return checkEvent(&fReset);
}
/*----------------------------------------------------------------------------*/
FUNC_EVT(kPdiAsyncStateStopped, STATE_FINAL, 1)
{
    return FALSE; // do never enter final
}

/**
********************************************************************************
\brief  state change hook - print message at every change
*******************************************************************************/
static void stateChange(BYTE current, BYTE target)
{
    BYTE    currentIdx, targetIdx;

    currentIdx = current + 2;
    targetIdx = target + 2;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_ASYNC_INFO, "\nASYCN STATE: %s->%s\n", strAsyncStateNames_l[currentIdx], strAsyncStateNames_l[targetIdx]);
}

/******************************************************************************/
/* public functions */

/**
 ********************************************************************************
 \brief	initializes an asynchronous PDI message descriptor
 \param	MsgType_p		    type of message
 \param pfnCbMsgHdl_p       pointer to message handle call-back function
 \param pPdiBuffer_p        pointer to one-way PDI buffer
 \param pResponseMsgDescr_p optional response message; set to NULL if not used
 \param TransferType_p      local buffering (for large messages) or direct PDI buffer access
 \param ChanType_p          channel type (internal or external)
 \param paValidNmtList_p    list of NmtStates the massage can be processed in
 \param wTimeout_p         AP <-> PCP timeout communication value for this message
                            (0 means wait forever)

 \return	tPdiAsyncStatus value

This function initializes the message descriptor for a certain asynchronous
PDI message. If a response message descriptor will be assigned, the state machine
will wait for the response immediately after the Tx transfer has been finished or
trigger a Tx transfer if an Rx message has been processed, depending on this message type.

 *******************************************************************************/
tPdiAsyncStatus CnApiAsync_initMsg(tPdiAsyncMsgType MsgType_p, tPcpPdiAsyncDir Direction_p, const tPdiAsyncBufHdlCb  pfnCbMsgHdl_p,
                                const tPcpPdiAsyncMsgBufDescr * pPdiBuffer_p, tPdiAsyncMsgType RespMsgType_p,
                                tPdiAsyncTransferType TransferType_p, tAsyncChannel ChanType_p,
                                const tPcpStates * paValidNmtList_p, WORD wTimeout_p)
{
    tPdiAsyncMsgDescr * pMsgDescr = NULL;
    BYTE bElement = INVALID_ELEMENT;
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;

    /* verify parameters */
    if (pPdiBuffer_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }
//    if (paValidNmtList_p == NULL) //TODO: implement valid NMT States
//    {
//        Ret = kPdiAsyncStatusInvalidInstanceParam;
//        goto exit;
//    }
    if (MsgType_p == kPdiAsyncMsgInvalid)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;;
        goto exit;
    }

    /* choose message descriptor */
    switch (Direction_p)
    {
        /* Tx messages at PCP */
        case kCnApiDirTransmit:
        {
            /* assing values to Tx Msg Descriptor */

            /* check if this type has already been assigned */
            bElement = MAX_PDI_ASYNC_TX_MESSAGES;
            Ret = getArrayNumOfMsgDescr(MsgType_p, aPdiAsyncTxMsgs, &bElement);

            switch (Ret)
            {
                case kPdiAsyncStatusSuccessful:     // message already assigned -> overwrite values
                case kPdiAsyncStatusFreeInstance:   // free message descriptor found
                {
                    pMsgDescr = &aPdiAsyncTxMsgs[bElement];
                    break;
                }

                case kPdiAsyncStatusNoFreeInstance: // message type not yet assigned and no free descriptor found
                default:
                {
                    goto exit;
                }
            }

            break;
        }

        /* Rx messages at PCP */
        case kCnApiDirReceive:
        {
            /* check if this type has already been assigned */
            bElement = MAX_PDI_ASYNC_RX_MESSAGES;
            Ret = getArrayNumOfMsgDescr(MsgType_p, aPdiAsyncRxMsgs, &bElement);

            switch (Ret)
            {
                case kPdiAsyncStatusSuccessful:     // message already assigned -> overwrite values
                case kPdiAsyncStatusFreeInstance:   // free message descriptor found
                {
                    pMsgDescr = &aPdiAsyncRxMsgs[bElement];
                    break;
                }

                case kPdiAsyncStatusNoFreeInstance: // message type not yet assigned and no free descriptor found
                default:
                {
                    goto exit;
                }
            }

            break;
        }

        default:
        break;
    }

    /* log response message - pointers have to be assigned as soon as all messages are initialized */
    if (RespMsgType_p != kPdiAsyncMsgInvalid)
    {
        aPdiAsyncMsgLinkLog_l[bLinkLogCounter_l].MsgType_m = MsgType_p;
        aPdiAsyncMsgLinkLog_l[bLinkLogCounter_l].RespMsgType_m = RespMsgType_p;
        aPdiAsyncMsgLinkLog_l[bLinkLogCounter_l].Direction_m = Direction_p;
        bLinkLogCounter_l++;
    }

    /* assign values to descriptor*/
    pMsgDescr->MsgType_m = MsgType_p;
    pMsgDescr->MsgHdl_m.pfnCbMsgHdl_m = pfnCbMsgHdl_p;
    pMsgDescr->pPdiBuffer_m = (tPcpPdiAsyncMsgBufDescr *) pPdiBuffer_p;
    pMsgDescr->TransfType_m = TransferType_p;
    pMsgDescr->Param_m.ChanType_m = ChanType_p;
    memcpy(&pMsgDescr->Param_m.aNmtList_m, paValidNmtList_p, sizeof(pMsgDescr->Param_m.aNmtList_m));
    pMsgDescr->Param_m.wTimeout_m = wTimeout_p;

    Ret = kPdiAsyncStatusSuccessful;

exit:
    return Ret;
}

/**
 ********************************************************************************
 \brief assigns response message descriptors to originating message descriptors
 \return    tPdiAsyncStatus value

 This function has to be executed after the last call of cnApiAsync_initMsg().
 *******************************************************************************/
tPdiAsyncStatus CnApiAsync_finishMsgInit(void)
{
    tPdiAsyncMsgDescr * pOrigMsgDescr = NULL;
    tPdiAsyncMsgDescr * paSameDirMsgs = NULL; ///< pointer to descriptor array with same message direction
    tPcpPdiAsyncDir     OrigDirection = 0;
    BYTE bElement = INVALID_ELEMENT;
    BYTE bMsgType = kPdiAsyncMsgInvalid;
    BYTE bCnt = 0;                            ///< loop counter
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;


    for (bCnt = 0; bCnt < bLinkLogCounter_l; ++bCnt)
    { /* assign response message descriptor pointer */

        /* search origin message descripor */
        bMsgType = aPdiAsyncMsgLinkLog_l[bCnt].MsgType_m;
        OrigDirection = aPdiAsyncMsgLinkLog_l[bCnt].Direction_m;

        if (OrigDirection == kCnApiDirTransmit)
        {
            bElement = MAX_PDI_ASYNC_TX_MESSAGES;
            paSameDirMsgs = aPdiAsyncTxMsgs;
        }
        else
        {
            bElement = MAX_PDI_ASYNC_RX_MESSAGES;
            paSameDirMsgs = aPdiAsyncRxMsgs;
        }

        Ret = getArrayNumOfMsgDescr(bMsgType, paSameDirMsgs, &bElement);
        if (Ret != kPdiAsyncStatusSuccessful)
        {/* descriptor not found */
            goto exit;
        }
        else
        {/* descriptor found */
            pOrigMsgDescr = &paSameDirMsgs[bElement]; // set origin  message pointer
        }

        /* search and assign response message descriptor */
        bMsgType = aPdiAsyncMsgLinkLog_l[bCnt].RespMsgType_m;

        if (OrigDirection == kCnApiDirTransmit)
        {
            bElement = MAX_PDI_ASYNC_RX_MESSAGES;
            paSameDirMsgs = aPdiAsyncRxMsgs;
        }
        else
        {
            bElement = MAX_PDI_ASYNC_TX_MESSAGES;
            paSameDirMsgs = aPdiAsyncTxMsgs;
        }

        Ret = getArrayNumOfMsgDescr(bMsgType, paSameDirMsgs, &bElement);
        if (Ret != kPdiAsyncStatusSuccessful)
        {/* descriptor not found */
            goto exit;
        }
        else
        {/* descriptor found */
            pOrigMsgDescr->pRespMsgDescr_m = &paSameDirMsgs[bElement]; // assign response  message pointer
        }
    }

    Ret = kPdiAsyncStatusSuccessful;

exit:
    return Ret;

}

/**
 ********************************************************************************
 \brief	triggers the sending of an asynchronous message through the PDI
 \param MsgType_p       type of message
 \param pUserHandle_p   optional general purpose user handle
 \param pfnCbOrigMsg_p  call back function which will be invoked if transfer
                        of Tx message has finished
 \param pfnCbRespMsg_p  call back function which will be invoked if transfer
                        of Rx response message (if assigned) has finished

 \retval	kPdiAsyncStatusSuccessful		if message sending has been triggered
 \retval	kPdiAsyncStatusNoResource		if message does not exist or no memory available

 This function activates the message descriptor of a certain message.
 The PdiAsync state machine will recognize the activation and handle the
 message transfer either segmented or via direct buffer setup.
 *******************************************************************************/
tPdiAsyncStatus CnApiAsync_postMsg(
                tPdiAsyncMsgType MsgType_p,
                BYTE * pUserHandle_p,
                tPdiAsyncCbTransferFinished pfnCbOrigMsg_p,
                tPdiAsyncCbTransferFinished pfnCbRespMsg_p)
{
    tPdiAsyncMsgDescr * pMsgDescr = NULL;
    BYTE bElement = INVALID_ELEMENT;
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;

    /* search for message type */
    bElement = MAX_PDI_ASYNC_TX_MESSAGES;
    Ret = getArrayNumOfMsgDescr(MsgType_p, aPdiAsyncTxMsgs, &bElement);

    switch (Ret)
    {
        case kPdiAsyncStatusSuccessful:     // message found
        {
            pMsgDescr = &aPdiAsyncTxMsgs[bElement];
            break;
        }

        default:                            // no message of this type assigned
        {
            Ret = kPdiAsyncStatusNoResource;
            goto exit;
        }
    }

    /* verify if message is currently in use */
    if (pMsgDescr->fMsgValid_m == TRUE)
    { /* message has been sent before and is not finished yet */
        Ret = kPdiAsyncStatusReject;
        goto exit;
    }

    /* verify descriptor members */
    if (pMsgDescr->pPdiBuffer_m == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* assign user handle */
    if (pUserHandle_p != NULL)
    { // Note: if needed, handle also has to be forwared to response message by the user
        pMsgDescr->pUserHdl_m = pUserHandle_p;
    }

    /* assign "transfer-finished" call back functions */
    if (pfnCbOrigMsg_p != NULL)
    {
        pMsgDescr->pfnTransferFinished_m = pfnCbOrigMsg_p;
    }
    if (pfnCbRespMsg_p != NULL &&
        pMsgDescr->pRespMsgDescr_m != NULL)
    {
            pMsgDescr->pRespMsgDescr_m->pfnTransferFinished_m = pfnCbRespMsg_p;
    }

    /* handle the message according to the transfer type */
    switch (pMsgDescr->TransfType_m)
    {
        case kPdiAsyncTrfTypeDirectAccess:
        {
            /*
             * invoke call back function in ASYNC_TX_BUSY state to fill the PDI Buffer directly
             */
            break;
        }

        case kPdiAsyncTrfTypeLclBuffering:
        {
            //TODO: Multiple access to this function have to be restricted to 2 (for each channel and lcl buffering) (+ memory space restriction and multiple message activation)
            if (pLclAsyncTxMsgBuffer_l != NULL)
            {
                /* memory already allocated !*/
                ErrorHistory_l = kPdiAsyncStatusNoResource;
                fError = TRUE;
                goto exit;
            }

            pLclAsyncTxMsgBuffer_l = CNAPI_MALLOC(MAX_ASYNC_STREAM_LENGTH);
            if (pLclAsyncTxMsgBuffer_l == NULL)
            {
                Ret = kPdiAsyncStatusNoResource;
                goto exit;
            }
            else
            {
                pMsgDescr->MsgHdl_m.pLclBuf_m = pLclAsyncTxMsgBuffer_l;
            }

            /* invoke call back function to fill the local buffer */
            /* and skip this step, if no call back is assigned    */
            if (pMsgDescr->MsgHdl_m.pfnCbMsgHdl_m != NULL)
            {
                // call back function has to update the actual used buffer size to 'dwMsgSize_m'
                // and check if Tx buffer storage is sufficient in advance.
                Ret = pMsgDescr->MsgHdl_m.pfnCbMsgHdl_m(pMsgDescr, (BYTE*) pMsgDescr->MsgHdl_m.pLclBuf_m,
                                                        NULL , MAX_ASYNC_STREAM_LENGTH);
                // pRespMsgBuffer_p is not assigned (NULL) because the Rx handle can only be triggered
                // by the state machine. (Tx handle can be triggered by this function and the state machine)
                if (Ret != kPdiAsyncStatusSuccessful)
                {
                    goto exit;
                }

                if (pMsgDescr->dwMsgSize_m > MAX_ASYNC_STREAM_LENGTH)
                {
                    Ret = kPdiAsyncStatusDataTooLong; // to much data written to buffer!
                    goto exit;
                }

                /* setup the buffer header with the actual written size, which the call-back function has updated */
                //TODO: reallocation to "pMsgDescr->dwMsgSize_m" ?
            }
            break;
        }
    }

    /* activate message */
    pMsgDescr->fMsgValid_m = TRUE;

    Ret = kPdiAsyncStatusSuccessful;

exit:
    return Ret;
}

/**
********************************************************************************
\brief  initialize state machine
******************************************************************************/
void CnApi_activateAsyncStateMachine(void)
{
    DEBUG_FUNC;

    /* initialize state machine */
    sm_init(&PdiAsyncStateMachine_l, aPdiAsyncStates_l, kPdiNumAsyncStates, aPdiAsyncTransitions_l,
            0, kPdiAsyncStateWait, stateChange); // 0 = not in use, solved directly in stateMachine.c

    /***** build up states ******/
//Explanation:
// SM_ADD_TRANSITION            --> EVT function is expected. Transition if event occured
// SM_ADD_TRANSITION_ACTION     --> TRANSACT and EVT function expected. Transition if event occured,
//                                  TRANSACT is executed within state change

// SM_ADD_ACTION_100            --> ENTRYACT is expected
// SM_ADD_ACTION_010            --> DOACT function is expected
// SM_ADD_ACTION_001            --> EXITACT function is expected
//         e.g. _110:           --> ENTRYACT and DOACT is expected... (usually needed for every state)


    /* state: ASYNC_WAIT */
    //                 StateMachineInstace     from state          to state             cnt of this very transition
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncStateWait, kPdiAsyncRxStateBusy, 1);        //Transition event1
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncStateWait, kPdiAsyncTxStateBusy, 1);        //Transition event2
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncStateWait, kPdiAsyncRxStatePending, 1);     //Transition event3
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncStateWait, kPdiAsyncStateStopped, 1);       //Transition event4
    SM_ADD_ACTION_110(&PdiAsyncStateMachine_l, kPdiAsyncStateWait);                                 //ENTRY and DOACT

    /* state: ASYNC_TX_BUSY */
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncTxStateBusy, kPdiAsyncTxStatePending, 1);   //Transition event1
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncTxStateBusy, kPdiAsyncStateStopped, 1);     //Transition event2
    SM_ADD_ACTION_110(&PdiAsyncStateMachine_l, kPdiAsyncTxStateBusy);                               //ENTRY and DOACT

    /* state: ASYNC_TX_PENDING */
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncTxStatePending, kPdiAsyncStateWait, 1);     //Transition event1
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncTxStatePending, kPdiAsyncTxStateBusy, 1);   //Transition event2
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncTxStatePending, kPdiAsyncStateStopped, 1);  //Transition event3
    SM_ADD_ACTION_110(&PdiAsyncStateMachine_l, kPdiAsyncTxStatePending);                            //ENTRY and DOACT

    /* state: ASYNC_RX_BUSY */
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncRxStateBusy, kPdiAsyncStateWait, 1);        //Transition event1
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncRxStateBusy, kPdiAsyncRxStatePending, 1);   //Transition event2
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncRxStateBusy, kPdiAsyncStateStopped, 1);     //Transition event3
    SM_ADD_ACTION_110(&PdiAsyncStateMachine_l, kPdiAsyncRxStateBusy);                               //ENTRY and DOACT

    /* state: ASYNC_RX_PENDING */
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncRxStatePending, kPdiAsyncRxStateBusy, 1);   //Transition event1
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncRxStatePending, kPdiAsyncStateStopped, 1);  //Transition event2
    SM_ADD_ACTION_110(&PdiAsyncStateMachine_l, kPdiAsyncRxStatePending);                            //ENTRY and DOACT

    /* state: ASYNC_STOPPED */
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncStateStopped, kPdiAsyncStateWait, 1);       //Transition event1
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncStateStopped, STATE_FINAL, 1);              //Transition event2
    SM_ADD_ACTION_110(&PdiAsyncStateMachine_l, kPdiAsyncStateStopped);                              //ENTRY and DOACT
}

/**
********************************************************************************
\brief  activate state machine
*******************************************************************************/
void CnApi_resetAsyncStateMachine(void)
{
    DEBUG_FUNC;

    fError = FALSE;                 ///< transition event
    fTimeout = FALSE;               ///< transition event
    fReset = FALSE;                 ///< transition event
    fRxTriggered = FALSE;           ///< transition event -> explicitly wait for special message
    fTxTriggered = FALSE;           ///< transition event
    fFrgmtAvailable = FALSE;        ///< transition event
    fFrgmtStored = FALSE;           ///< transition event
    fFrgmtDelivered = FALSE;        ///< transition event
    fMsgTransferFinished = FALSE;   ///< transition event
    fMsgTransferIncomplete = FALSE; ///< transition event
    fFragmentedTransfer = FALSE;    ///< indicates stream segmentation

    ErrorHistory_l = kPdiAsyncStatusSuccessful;

    bActivTxMsg_l = INVALID_ELEMENT; ///< indicates inactive message
    bActivRxMsg_l = INVALID_ELEMENT; ///< indicates inactive message
    pLclAsyncTxMsgBuffer_l = NULL;   ///< pointer to local Tx message buffer
    pLclAsyncRxMsgBuffer_l = NULL;   ///< pointer to local Rx message buffer
    dwTimeoutWait_l = 0;              ///< timeout counter

    /* initialize state machine */
    sm_reset(&PdiAsyncStateMachine_l);
}

/**
********************************************************************************
\brief  update state machine
*******************************************************************************/
BOOL CnApi_processAsyncStateMachine(void)
{
    return sm_update(&PdiAsyncStateMachine_l);
}

/**
********************************************************************************
\brief  check if state machine is running
*******************************************************************************/
BOOL CnApi_checkAsyncStateMachineRunning(void)
{
    if (sm_getState(&PdiAsyncStateMachine_l) != STATE_FINAL)
        return TRUE;
    else
        return FALSE;
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
