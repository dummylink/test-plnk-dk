/**
********************************************************************************
\file       cnApiAsyncSm.c

\brief      Asynchronous PDI state machine module

This is the source file for the asynchronous communication between the
POWERLINK Communication Processor (PCP) and the Application Processor (AP)
using the Process Data Interface (PDI) as buffer. The communication is handled
with a state machine in order to avoid blocking. In this state machine,
the Tx and Rx direction towards and from the AP is handled.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApiTypAsync.h"
#include "cnApiTypAsyncSm.h"

#include "cnApiAsyncSm.h"    // external function declarations
#include "cnApiAsync.h"      // state machine constants
#include "cnApiIntern.h"

#ifdef CN_API_USING_SPI
  #include "cnApiPdiSpiIntern.h"     // serial interface
#endif

#include "EplAmi.h"

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
char * strAsyncStateNames_l[] = { "INITIAL", "FINAL", "ASYNC_WAIT",
                                  "ASYNC_TX_BUSY", "ASYNC_TX_PENDING",
                                  "ASYNC_RX_BUSY", "ASYNC_RX_PENDING",
                                  "ASYNC_STOPPED"};
/* state machine */
static tStateMachine        PdiAsyncStateMachine_l;
static tState               aPdiAsyncStates_l[kPdiNumAsyncStates];
static tTransition          aPdiAsyncTransitions_l[MAX_TRANSITIONS_PER_STATE * kPdiNumAsyncStates];
static BOOL                 fSmProcessingAllowed_l = TRUE;  ///< flag to block state machine processing
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
static BOOL                 fMsgTransferInterrupted = FALSE; ///< external message interrupted for check of internal message
static BOOL                 fCheckOnlyInternalMessages = FALSE;   ///< only check internal messages in ASYNC_WAIT
                                                                  ///< and return to originating 'pending' state of non-internal message
static BOOL                 fCheckedIfInternalMessageDue = FALSE; ///< internal messages have already been checked once

/* Asynchronous Transfers */
static tPdiAsyncMsgDescr aPdiAsyncRxMsgs[MAX_PDI_ASYNC_RX_MESSAGES] = {{0}};
static tPdiAsyncMsgDescr aPdiAsyncTxMsgs[MAX_PDI_ASYNC_TX_MESSAGES] = {{0}};
static tPdiAsyncMsgLink  aPdiAsyncMsgLinkLog_l[(MAX_PDI_ASYNC_TX_MESSAGES + MAX_PDI_ASYNC_RX_MESSAGES)] = {{0}};
static BYTE              bActivTxMsg_l = INVALID_ELEMENT; ///< indicates inactive message
static BYTE              bActivRxMsg_l = INVALID_ELEMENT; ///< indicates inactive message
static BYTE *            pLclAsyncTxMsgBuffer_l = NULL;   ///< pointer to local Tx message buffer
static tPdiAsyncStatus            ErrorHistory_l = kPdiAsyncStatusSuccessful;

static BYTE *            pLclAsyncRxMsgBuffer_l = NULL;   ///< pointer to local Rx message buffer
static DWORD             dwTimeoutWait_l = 0;             ///< timeout counter

tPdiAsyncPendingTransferContext PdiAsyncPendTrfContext_l;  ///< context of interrupted transfer

/* list of connections from original message to response message */
static BYTE                     bLinkLogCounter_l = 0;    ///< counter of current links

/******************************************************************************/
/* function declarations */
static BOOL checkEvent(BOOL * pfEvent_p);
static inline void setBuffToReadOnly(volatile tAsyncMsg * pPdiBuffer_p);
static inline void confirmFragmentReception(tAsyncMsg * pPdiBuffer_p);
static inline BOOL checkMsgDelivery(tAsyncMsg * pPdiBuffer_p);
static inline BOOL checkMsgPresence(tAsyncMsg * pPdiBuffer_p);
static tPdiAsyncStatus getArrayNumOfMsgDescr(tPdiAsyncMsgType MsgType_p,
                                             tPdiAsyncMsgDescr * paMsgDescr_p,
                                             BYTE * pbArgElement_p            );
static BOOL CnApiAsync_saveMsgContext(void);
static BOOL CnApiAsync_restoreMsgContext(void);

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
 \param pPdiBuffer_p pointer to Pdi Buffer with structure tAsyncMsg
 *******************************************************************************/
static inline void setBuffToReadOnly(volatile tAsyncMsg * pPdiBuffer_p)
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
 \brief     returns the element number of the message descriptor array for a
            certain message type
 \param     MsgType_p           type of message which will be searched
 \param     paMsgDescr_p        pointer to array of message descriptors
 \param     pbArgElement_p      in: max elements of array;
                                out: found element number of array or INVALID_ELEMENT
 \retval    kPdiAsyncStatusSuccessful       if message type found
 \retval    kPdiAsyncStatusFreeInstance     if message type was not found, but free descriptor
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
  // in this state, it is assumed that internal Tx buffer is empty.
}
/*----------------------------------------------------------------------------*/
FUNC_DOACT(kPdiAsyncStateWait)
{
    BYTE         bMsgTypeField = 0;                     // pointer to command byte field of asynchr. message
    BYTE         bCurPdiChannelNum = INVALID_ELEMENT;   // current PDI channel number
    register BYTE bCnt = 0;                             // loop counter
    BYTE         bElement = INVALID_ELEMENT;            // function argument for getArrayNumOfMsgDescr()

    /* check if waiting for Rx message is required -> transit to  ASYNC_RX_PENDING*/
    if ((fRxTriggered == TRUE) || fTxTriggered == TRUE)
    {
        goto exit; // trigger ASYNC_RX_PENDING or ASYNC_TX_BUSY
    }

    /* search for external messages */
    if (fCheckOnlyInternalMessages == FALSE)
    {
        /* check if there is an interrupted message present */
        if (PdiAsyncPendTrfContext_l.fMsgPending_m == TRUE)
        {
            if (CnApiAsync_restoreMsgContext())
            {   //TODO: Better restore, if no Internal Channel was found.
                //Otherwise the internal channel will delay until next interruption of external message.
                //-> maybe check internal messages first.
                goto exit; //TODO: does transition work this way? otherwise: implement regular transition to originating state.
            }
            else
            {
                ErrorHistory_l = kPdiAsyncStatusIllegalInstance;
                fError = TRUE;
                goto exit;
            }
        }
        else // no interrupted message -> check if external Rx message is available */
        {
            for (bCnt = 0; bCnt < ASYNC_PDI_CHANNELS; ++bCnt)
            {
#ifdef CN_API_USING_SPI
                /* read PDI buffer header to local copy */
                CnApi_Spi_read(aPcpPdiAsyncRxMsgBuffer_g[bCnt].wPdiOffset_m + PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET,
                     sizeof(((tAsyncMsg *) 0)->m_header),
                     (BYTE*) &aPcpPdiAsyncRxMsgBuffer_g[bCnt].pAdr_m->m_header);
#endif /* CN_API_USING_SPI */

                if (checkMsgPresence(aPcpPdiAsyncRxMsgBuffer_g[bCnt].pAdr_m))
                {
                    bCurPdiChannelNum = bCnt; // set current Rx PDI channel
                    break;
                }
            }
        }
    }

    /* check if internal Rx message is available */
    for (bCnt = 0; bCnt < ASYNC_PDI_CHANNELS; ++bCnt)
    {

#ifdef CN_API_USING_SPI
                /* read PDI buffer header to local copy */
                CnApi_Spi_read(aPcpPdiAsyncRxMsgBuffer_g[bCnt].wPdiOffset_m + PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET,
                     sizeof(((tAsyncMsg *) 0)->m_header),
                     (BYTE*) &aPcpPdiAsyncRxMsgBuffer_g[bCnt].pAdr_m->m_header);
#endif /* CN_API_USING_SPI */

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
    if (fCheckOnlyInternalMessages == FALSE)
    {
        for (bCnt = 0; bCnt < MAX_PDI_ASYNC_TX_MESSAGES; ++bCnt)
        {
            if ((aPdiAsyncTxMsgs[bCnt].MsgStatus_m == kPdiAsyncMsgStatusQueuing))
            {
                bActivTxMsg_l = bCnt;   // activate first found element
                break;
            }
        }
    }

    /* check if internal Tx message is due (high priority) */
    for (bCnt = 0; bCnt < MAX_PDI_ASYNC_TX_MESSAGES; ++bCnt)
    {
        if ((aPdiAsyncTxMsgs[bCnt].MsgStatus_m == kPdiAsyncMsgStatusQueuing) &&
            (aPdiAsyncTxMsgs[bCnt].Param_m.ChanType_m == kAsyncChannelInternal))
        {
            bActivTxMsg_l = bCnt;   // overwrite previous found element
            break;
        }
    }
    // end of search for available Tx message

    if (bActivTxMsg_l == INVALID_ELEMENT)
    {
        goto exit; // no message activated -> nothing to do
    }
    else // message activated
    {
        // if local buffering is used, assign buffer pointer
        if (aPdiAsyncTxMsgs[bActivTxMsg_l].TransfType_m == kPdiAsyncTrfTypeLclBuffering)
        {
            if (pLclAsyncTxMsgBuffer_l != NULL)
            {
                ErrorHistory_l = kPdiAsyncStatusNoResource;
                fError = TRUE;
                goto exit;
            }

            pLclAsyncTxMsgBuffer_l = aPdiAsyncTxMsgs[bActivTxMsg_l].MsgHdl_m.pLclBuf_m;
        }

        /*transit to ASYNC_TX_BUSY */
        fTxTriggered = TRUE;
        goto exit;
    }

exit:
    if (checkEvent(&fCheckOnlyInternalMessages))
    {
        fCheckedIfInternalMessageDue = TRUE;
    }
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
    volatile tAsyncMsg *     pUtilTxPdiBuf = NULL;   // Tx Pdi Buffer utilized by message
    tPdiAsyncMsgDescr * pMsgDescr = NULL;   // pointer to current message descriptor
    WORD          wCopyLength   = 0;        // length of data to be copied (for local buffered transfer)
    DWORD         dwMaxBufPayload = 0;      // maximum payload for message storage
    BYTE *        pCurLclMsgFrgmt = 0;      // pointer to currently handled local message fragment

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

            /* write asynchronous message payload to PDI buffer */
            MEMCPY((BYTE *)&pUtilTxPdiBuf->m_chan, pCurLclMsgFrgmt, wCopyLength);

#ifdef CN_API_USING_SPI
            /* write asynchronous message payload to PDI buffer */
            CnApi_Spi_write(pMsgDescr->pPdiBuffer_m->wPdiOffset_m + PCP_PDI_SERIAL_ASYNCMSGPAYLOAD_OFFSET,
                           wCopyLength,
                           (BYTE*) &pUtilTxPdiBuf->m_chan);
#endif /* CN_API_USING_SPI */

            /* write fragment length to PDI buffer header */
            AmiSetWordToLe((BYTE*)&pUtilTxPdiBuf->m_header.m_wFrgmtLen, wCopyLength);

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
                                                                   (BYTE *) &pUtilTxPdiBuf->m_chan,
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
            AmiSetWordToLe((BYTE*)&pUtilTxPdiBuf->m_header.m_wFrgmtLen, pMsgDescr->dwMsgSize_m); // update  PDI buffer control header

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
    AmiSetDwordToLe((BYTE*)&pUtilTxPdiBuf->m_header.m_dwStreamLen, pMsgDescr->dwMsgSize_m);

#ifdef CN_API_USING_SPI
    /* update PCP PDI buffer header  with sync flag set to 0x01*/
    CnApi_Spi_write(pMsgDescr->pPdiBuffer_m->wPdiOffset_m + PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET,
                    sizeof(tAsyncPdiBufCtrlHeader),
                    (BYTE*) &pUtilTxPdiBuf->m_header);
#endif

    setBuffToReadOnly(pUtilTxPdiBuf); // set sync flag

#ifdef CN_API_USING_SPI
    /* update sync flag of PCP PDI buffer header */
    CnApi_Spi_write(pMsgDescr->pPdiBuffer_m->wPdiOffset_m + PCP_PDI_SERIAL_ASYNC_SYNC_OFFSET,
                    sizeof(((tAsyncPdiBufCtrlHeader *) 0)->m_bSync),
                    (BYTE*) &pUtilTxPdiBuf->m_header.m_bSync);
#endif /* CN_API_USING_SPI */

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
    BYTE         bElement = INVALID_ELEMENT;            // function argument for getArrayNumOfMsgDescr()

    /* first, process internal messages */
    if (aPdiAsyncTxMsgs[bActivTxMsg_l].Param_m.ChanType_m != kAsyncChannelInternal)
    {
        if (!checkEvent(&fCheckedIfInternalMessageDue)) //not yet checked for internal messages
        {
            /* save context of the current message */
            if (CnApiAsync_saveMsgContext())
            { /* context save was successful */

                /* check if internal messages have to be processed -> goto ASYNC_WAIT state */
                fCheckOnlyInternalMessages = TRUE;
                fMsgTransferInterrupted = TRUE; // not really finished, only causes transition to ASYNC_WAIT
                //TODO: Change MsgStatus to interrupted
                goto exit;
            }
            else
            {
                /* context save was not successful -> do not check internal messages*/
                ErrorHistory_l = kPdiAsyncStatusNoResource;
                fError = TRUE;
                goto exit;
            }
        }
    }

    // check if message has been delivered
#ifdef CN_API_USING_SPI
    /* update sync flag of PCP PDI buffer header */
    CnApi_Spi_read(aPdiAsyncTxMsgs[bActivTxMsg_l].pPdiBuffer_m->wPdiOffset_m + PCP_PDI_SERIAL_ASYNC_SYNC_OFFSET,
                    sizeof(((tAsyncPdiBufCtrlHeader *) 0)->m_bSync),
                    (BYTE*) &aPdiAsyncTxMsgs[bActivTxMsg_l].pPdiBuffer_m->pAdr_m->m_header.m_bSync);
#endif /* CN_API_USING_SPI */

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
            dwTimeoutWait_l = 0; // reset to initial value

            aPdiAsyncTxMsgs[bActivTxMsg_l].dwPendTranfSize_m = 0; // finished
            fMsgTransferFinished = TRUE;

            /* call user call back, if assigned */
            if (aPdiAsyncTxMsgs[bActivTxMsg_l].pfnTransferFinished_m != NULL)
            {
                ErrorHistory_l = aPdiAsyncTxMsgs[bActivTxMsg_l].pfnTransferFinished_m(&aPdiAsyncTxMsgs[bActivTxMsg_l]);

                if (ErrorHistory_l != kPdiAsyncStatusSuccessful)
                {
                    fError = TRUE; // triggers transition
                    goto exit;
                }
            }

            /* free allocated buffers*/
            switch (aPdiAsyncTxMsgs[bActivTxMsg_l].TransfType_m)
            {
                case kPdiAsyncTrfTypeLclBuffering:
                {
                    if (pLclAsyncTxMsgBuffer_l != NULL)
                    {
                        if (pLclAsyncTxMsgBuffer_l                           !=
                            aPdiAsyncTxMsgs[bActivTxMsg_l].MsgHdl_m.pLclBuf_m  )
                        {   // those two pointers have to be equal at this point
                            ErrorHistory_l = kPdiAsyncStatusInvalidInstanceParam;
                            fError = TRUE;
                            goto exit;
                        }
                        FREE(pLclAsyncTxMsgBuffer_l);
                        pLclAsyncTxMsgBuffer_l = NULL;
                        aPdiAsyncTxMsgs[bActivTxMsg_l].MsgHdl_m.pLclBuf_m = NULL;
                    }

                    break;
                }

                case kPdiAsyncTrfTypeDirectAccess:
                default:
                    break;
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
                    aPdiAsyncTxMsgs[bActivTxMsg_l].MsgStatus_m = kPdiAsyncMsgStatusNotActive; // tag as obsolete
                    bActivTxMsg_l = INVALID_ELEMENT;

                    /* set active Rx element and trigger Rx pending */
                    bActivRxMsg_l = bElement;
                    fRxTriggered = TRUE; // set flag for state ASYNC_WAIT
                    goto exit;
                }
            }

            /* deactivate Tx message */
            aPdiAsyncTxMsgs[bActivTxMsg_l].MsgStatus_m = kPdiAsyncMsgStatusNotActive; // tag as obsolete
            bActivTxMsg_l = INVALID_ELEMENT;

            /* if Tx response was triggered by Rx message, free and deactivate also Rx message */
            if (bActivRxMsg_l != INVALID_ELEMENT)
            {
                /* free allocated buffers */
                switch (aPdiAsyncRxMsgs[bActivRxMsg_l].TransfType_m)
                {
                    case kPdiAsyncTrfTypeLclBuffering:
                    {
                        if (pLclAsyncRxMsgBuffer_l != NULL)
                        {
                            FREE(pLclAsyncRxMsgBuffer_l);
                            pLclAsyncRxMsgBuffer_l = NULL;
                            aPdiAsyncRxMsgs[bActivRxMsg_l].MsgHdl_m.pLclBuf_m = NULL;
                        }
                        break;
                    }

                    case kPdiAsyncTrfTypeDirectAccess:
                    {

                    }
                    default:
                    break;
                }
                /* deactivate Rx message */
                aPdiAsyncRxMsgs[bActivRxMsg_l].MsgStatus_m = kPdiAsyncMsgStatusNotActive; // tag as obsolete
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
{ /* message transfer completed or interrupted */
    if (checkEvent(&fMsgTransferFinished) ||
        checkEvent(&fMsgTransferInterrupted))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
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
    tAsyncMsg *   pUtilRxPdiBuf = NULL;     // Tx Pdi Buffer utilized by message
    tPdiAsyncMsgDescr * pMsgDescr = NULL;   // pointer to current message descriptor
    WORD          wCopyLength   = 0;        // length of data to be copied (for local buffered transfer)
    DWORD         dwMaxBufPayload = 0;      // maximum payload for message storage
    BYTE *        pCurLclMsgFrgmt = NULL;   // pointer to currently handled local message fragment
    BYTE *        pRespChan = NULL;         // pointer to Tx response message payload
    BYTE *        pRxChan = NULL;           // pointer to Rx message payload
    BYTE          bElement = INVALID_ELEMENT;// function argument for getArrayNumOfMsgDescr()
    DWORD         dwStreamLength;
    WORD          wFragmentLength;

    if (bActivRxMsg_l == INVALID_ELEMENT)
    {
        ErrorHistory_l = kPdiAsyncStatusIllegalInstance;
        fError = TRUE; // Rx Busy triggered, but no element assigned -> error
        goto exit;
    }

    /* initialize temporary pointers */
    pMsgDescr = &aPdiAsyncRxMsgs[bActivRxMsg_l];

    pUtilRxPdiBuf = pMsgDescr->pPdiBuffer_m->pAdr_m; //assign Pdi Rx buffer which this message wants to use

    /* verify message type */
#ifdef CN_API_USING_SPI
                /* read PDI buffer header to local copy */
                CnApi_Spi_read(pMsgDescr->pPdiBuffer_m->wPdiOffset_m + PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET,
                               sizeof(((tAsyncMsg *) 0)->m_header),
                               (BYTE*) &pUtilRxPdiBuf->m_header);
#endif /* CN_API_USING_SPI */

    dwStreamLength = AmiGetDwordFromLe((BYTE*)&(pUtilRxPdiBuf->m_header.m_dwStreamLen));

    if (pUtilRxPdiBuf->m_header.m_bMsgType != pMsgDescr->MsgType_m)
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
        if (dwStreamLength > MAX_ASYNC_STREAM_LENGTH)
        { /* data size exceeded -> reject transfer */
            ErrorHistory_l = kPdiAsyncStatusDataTooLong;
            fError = TRUE;
            goto exit;
        }

        else if (dwStreamLength > pMsgDescr->pPdiBuffer_m->wMaxPayload_m ||
                 pMsgDescr->TransfType_m == kPdiAsyncTrfTypeLclBuffering) // transfer type already fixed because it is
                                                                          // required for serial interface
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
            pLclAsyncRxMsgBuffer_l = (BYTE *) MALLOC(dwStreamLength);

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
        pMsgDescr->dwMsgSize_m = dwStreamLength;
        pMsgDescr->dwPendTranfSize_m = pMsgDescr->dwMsgSize_m;
    }/* initialization for 1st fragment finished */

    wFragmentLength = AmiGetWordFromLe((BYTE*)&(pUtilRxPdiBuf->m_header.m_wFrgmtLen));

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
            if (wFragmentLength > pMsgDescr->pPdiBuffer_m->wMaxPayload_m)
            {
                ErrorHistory_l = kPdiAsyncStatusDataTooLong;
                fError = TRUE;
                goto exit;
            }
            else
            {
                wCopyLength = wFragmentLength;
            }

            /* calculate start address of new local buffer fragment */
            pCurLclMsgFrgmt = pMsgDescr->MsgHdl_m.pLclBuf_m +
                              (pMsgDescr->dwMsgSize_m - pMsgDescr->dwPendTranfSize_m);

#ifdef CN_API_USING_SPI
         /* write asynchronous message payload to PDI buffer */
         CnApi_Spi_read(pMsgDescr->pPdiBuffer_m->wPdiOffset_m + PCP_PDI_SERIAL_ASYNCMSGPAYLOAD_OFFSET,
                        wCopyLength,
                        (BYTE*) pCurLclMsgFrgmt);
#else
            /* copy local buffer fragment into the PDI buffer */
            MEMCPY(pCurLclMsgFrgmt, &pUtilRxPdiBuf->m_chan,  wCopyLength);
#endif /* CN_API_USING_SPI */


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
                pMsgDescr->MsgStatus_m = kPdiAsyncMsgStatusTransferCompleted; // tag message payload as complete
            }

            break;
        }

        case kPdiAsyncTrfTypeDirectAccess:
        {
            pRxChan = (BYTE *) &pUtilRxPdiBuf->m_chan;
            pMsgDescr->dwPendTranfSize_m = 0;                             // indicate finished transfer
            pMsgDescr->MsgStatus_m = kPdiAsyncMsgStatusTransferCompleted; // tag message payload as complete
            break;
        }

        default:
        break;
    }

    /* Rx transfer has finished -> handle Rx message */
    if (pMsgDescr->MsgStatus_m == kPdiAsyncMsgStatusTransferCompleted)
    {
        dwTimeoutWait_l = 0; // reset to initial value

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
                    if (pLclAsyncRxMsgBuffer_l != NULL)
                    {
                        FREE(pLclAsyncRxMsgBuffer_l);
                        pLclAsyncRxMsgBuffer_l = NULL;
                        pMsgDescr->MsgHdl_m.pLclBuf_m = NULL;
                    }
                    break;
                }

                case kPdiAsyncTrfTypeDirectAccess:
                {

                }
                default:
                break;
            }

            /* deactivate Rx message */
            pMsgDescr->MsgStatus_m = kPdiAsyncMsgStatusNotActive; // tag as obsolete
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
#ifdef CN_API_USING_SPI
    /* update sync flag of PCP PDI buffer header */
    CnApi_Spi_write(aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->wPdiOffset_m + PCP_PDI_SERIAL_ASYNC_SYNC_OFFSET,
                    sizeof(((tAsyncPdiBufCtrlHeader *) 0)->m_bSync),
                    (BYTE*) &aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->pAdr_m->m_header.m_bSync);
#endif /* CN_API_USING_SPI */

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
#ifdef CN_API_USING_SPI
    /* update sync flag of PCP PDI buffer header */
    CnApi_Spi_write(aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->wPdiOffset_m + PCP_PDI_SERIAL_ASYNC_SYNC_OFFSET,
                    sizeof(((tAsyncPdiBufCtrlHeader *) 0)->m_bSync),
                    (BYTE*) &aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->pAdr_m->m_header.m_bSync);
#endif /* CN_API_USING_SPI */

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

    /* first, process internal messages */
    if (aPdiAsyncRxMsgs[bActivRxMsg_l].Param_m.ChanType_m != kAsyncChannelInternal)
    {
        if (!checkEvent(&fCheckedIfInternalMessageDue)) //not yet checked for internal messages
        {
            /* save context of the current message */
            if (CnApiAsync_saveMsgContext())
            { /* context save was successful */

                /* check if internal messages have to be processed -> goto ASYNC_WAIT state */
                fCheckOnlyInternalMessages = TRUE;
                fMsgTransferInterrupted = TRUE; //causes transition to ASYNC_WAIT
                goto exit;
            }
            else
            {
                /* context save was not successful -> do not check internal messages*/
                ErrorHistory_l = kPdiAsyncStatusNoResource;
                fError = TRUE;
                goto exit;
            }
        }
    }

#ifdef CN_API_USING_SPI
                /* read PDI buffer header to local copy */
                CnApi_Spi_read(aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->wPdiOffset_m + PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET,
                               sizeof(((tAsyncMsg *) 0)->m_header),
                               (BYTE*) &aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->pAdr_m->m_header);
#endif /* CN_API_USING_SPI */

    /* check if fragment is present */
    if (checkMsgPresence(aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->pAdr_m))
    { /* fragment is available in Rx buffer */

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
FUNC_EVT(kPdiAsyncRxStatePending, kPdiAsyncStateWait, 1)
{ /* message transfer interrupted */
    return checkEvent(&fMsgTransferInterrupted);
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

    /* timeout handling */
    dwTimeoutWait_l = 0;  // reset timeout counter

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_ERR, "%s errorcode: 0x%04x\n",
                                __func__, ErrorHistory_l);

    /* deactivate active messages */
    if (bActivTxMsg_l != INVALID_ELEMENT)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ASYNC_INFO, "Tx message type: %d\n",
                     aPdiAsyncTxMsgs[bActivTxMsg_l].MsgType_m);

        /* inform callback about error */
        aPdiAsyncTxMsgs[bActivTxMsg_l].MsgStatus_m = kPdiAsyncMsgStatusError;
        aPdiAsyncTxMsgs[bActivTxMsg_l].Error_m = ErrorHistory_l; // inform callback about error //TODO: assign error where it happens

        /* call user defined "transfer finished" callback */
        if (aPdiAsyncTxMsgs[bActivTxMsg_l].pfnTransferFinished_m != NULL)
        {
            ErrorHistory_l = aPdiAsyncTxMsgs[bActivTxMsg_l].pfnTransferFinished_m(&aPdiAsyncTxMsgs[bActivTxMsg_l]);
            if (ErrorHistory_l != kPdiAsyncStatusSuccessful)
            {
                DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR in async user callback!\n");
            }
        }

        /* reset message status */
        aPdiAsyncTxMsgs[bActivTxMsg_l].MsgStatus_m = kPdiAsyncMsgStatusNotActive;
        aPdiAsyncTxMsgs[bActivTxMsg_l].Error_m = kPdiAsyncStatusSuccessful;

        if (aPdiAsyncTxMsgs[bActivTxMsg_l].MsgHdl_m.pLclBuf_m == pLclAsyncTxMsgBuffer_l)
        {   // prevent free operation from executing a second time with pLclAsyncTxMsgBuffer_l
            pLclAsyncTxMsgBuffer_l = NULL;
        }

        if (aPdiAsyncTxMsgs[bActivTxMsg_l].MsgHdl_m.pLclBuf_m != NULL)
        {
            FREE(aPdiAsyncTxMsgs[bActivTxMsg_l].MsgHdl_m.pLclBuf_m);
            aPdiAsyncTxMsgs[bActivTxMsg_l].MsgHdl_m.pLclBuf_m = NULL;
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR -> FreeTxBuffer..\n");
        }

        bActivTxMsg_l = INVALID_ELEMENT;
    }

    if (bActivRxMsg_l != INVALID_ELEMENT)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ASYNC_INFO, "Rx message type: %d\n",
                     aPdiAsyncRxMsgs[bActivRxMsg_l].MsgType_m);

        confirmFragmentReception(aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->pAdr_m);
#ifdef CN_API_USING_SPI
    /* update sync flag of PCP PDI buffer header */
    CnApi_Spi_write(aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->wPdiOffset_m + PCP_PDI_SERIAL_ASYNC_SYNC_OFFSET,
                    sizeof(((tAsyncPdiBufCtrlHeader *) 0)->m_bSync),
                    (BYTE*) &aPdiAsyncRxMsgs[bActivRxMsg_l].pPdiBuffer_m->pAdr_m->m_header.m_bSync);
#endif /* CN_API_USING_SPI */

        /* inform callback about error */
        aPdiAsyncRxMsgs[bActivRxMsg_l].MsgStatus_m = kPdiAsyncMsgStatusError;
        aPdiAsyncRxMsgs[bActivRxMsg_l].Error_m = ErrorHistory_l; // inform callback about error //TODO: assign error where it happens

        /* call user defined "transfer finished" callback */
        if (aPdiAsyncRxMsgs[bActivRxMsg_l].pfnTransferFinished_m != NULL)
        {
            ErrorHistory_l = aPdiAsyncRxMsgs[bActivRxMsg_l].pfnTransferFinished_m(&aPdiAsyncRxMsgs[bActivRxMsg_l]);
            if (ErrorHistory_l != kPdiAsyncStatusSuccessful)
            {
                DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR in async user callback!\n");
            }
        }

        /* reset message status */
        aPdiAsyncRxMsgs[bActivRxMsg_l].MsgStatus_m = kPdiAsyncMsgStatusNotActive;
        aPdiAsyncRxMsgs[bActivRxMsg_l].Error_m = kPdiAsyncStatusSuccessful;

        if (aPdiAsyncRxMsgs[bActivRxMsg_l].MsgHdl_m.pLclBuf_m == pLclAsyncRxMsgBuffer_l)
        {   // prevent free operation from executing a second time with pLclAsyncRxMsgBuffer_l
            pLclAsyncRxMsgBuffer_l = NULL;
        }

        if (aPdiAsyncRxMsgs[bActivRxMsg_l].MsgHdl_m.pLclBuf_m != NULL)
        {
            FREE(aPdiAsyncRxMsgs[bActivRxMsg_l].MsgHdl_m.pLclBuf_m);
            aPdiAsyncRxMsgs[bActivRxMsg_l].MsgHdl_m.pLclBuf_m = NULL;
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR -> FreeRxBuffer..\n");
        }

        bActivRxMsg_l = INVALID_ELEMENT;
    }

    /* free buffers */
    if (pLclAsyncTxMsgBuffer_l != NULL)
    {
        FREE(pLclAsyncTxMsgBuffer_l);
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR -> FreeTxBuffer..\n");
        pLclAsyncTxMsgBuffer_l = NULL;
    }

    if (pLclAsyncRxMsgBuffer_l != NULL)
    {
        FREE(pLclAsyncRxMsgBuffer_l);
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR -> FreeRxBuffer..\n");
        pLclAsyncRxMsgBuffer_l = NULL;
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
 \brief initializes an asynchronous PDI message descriptor

 \param MsgType_p           type of message
 \param Direction_p         direction of the message (send or receive)
 \param pfnCbMsgHdl_p       pointer to message handle call-back function
 \param pPdiBuffer_p        pointer to one-way PDI buffer
 \param RespMsgType_p       optional response message; set to NULL if not used
 \param TransferType_p      local buffering (for large messages) or direct PDI buffer access
 \param ChanType_p          channel type (internal or external)
 \param paValidNmtList_p    list of NmtStates the massage can be processed in
 \param wTimeout_p         AP <-> PCP timeout communication value for this message
                            (0 means wait forever)

 \return tPdiAsyncStatus
 \retval kPdiAsyncStatusSuccessful              on success
 \retval kPdiAsyncStatusInvalidInstanceParam    invalid init parameters

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
    MEMCPY(&pMsgDescr->Param_m.aNmtList_m, paValidNmtList_p, sizeof(pMsgDescr->Param_m.aNmtList_m));
    pMsgDescr->Param_m.wTimeout_m = wTimeout_p;

    Ret = kPdiAsyncStatusSuccessful;

exit:
    return Ret;
}

/**
 ********************************************************************************
 \brief assigns response message descriptors to originating message descriptors
 \return    tPdiAsyncStatus
 \retval    kPdiAsyncStatusSuccessful          on success
 \retval    kPdiAsyncStatusFreeInstance        if message descriptor is not found

 This function has to be executed after the last call of cnApiAsync_initMsg().
 *******************************************************************************/
tPdiAsyncStatus CnApiAsync_finishMsgInit(void)
{
    tPdiAsyncMsgDescr * pOrigMsgDescr = NULL;
    tPdiAsyncMsgDescr * paSameDirMsgs = NULL; // pointer to descriptor array with same message direction
    tPcpPdiAsyncDir     OrigDirection = 0;
    BYTE bElement = INVALID_ELEMENT;
    BYTE bMsgType = kPdiAsyncMsgInvalid;
    BYTE bCnt = 0;                            // loop counter
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;


    for (bCnt = 0; bCnt < bLinkLogCounter_l; ++bCnt)
    { /* assign response message descriptor pointer */

        /* search origin message descriptor */
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
 \brief triggers the sending of an asynchronous message through the PDI
 \param MsgType_p       type of message
 \param pUserHandle_p   [IN] optional general purpose user handle
                        0: no assignment
 \param pfnCbOrigMsg_p  [IN] call back function which will be invoked if transfer
                        of Tx message has finished
                        0: no assignment
 \param pfnCbRespMsg_p  [IN] call back function which will be invoked if transfer
                        of Rx response message (if assigned) has finished
                        0: no assignment

 \return    tPdiAsyncStatus
 \retval    kPdiAsyncStatusSuccessful       if message sending has been triggered
 \retval    kPdiAsyncStatusNoResource       if message does not exist or no memory available

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
    if (pMsgDescr->MsgStatus_m != kPdiAsyncMsgStatusNotActive)
    { /* message has been sent before and is not finished yet */
        Ret = kPdiAsyncStatusRetry;
        goto exit;
    }

    /* verify descriptor members */
    if (pMsgDescr->pPdiBuffer_m == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* assign user handle */
    // Note: if needed, handle also has to be forwarded to response message by the user
    pMsgDescr->pUserHdl_m = pUserHandle_p;

    /* assign "transfer-finished" call back functions */
    pMsgDescr->pfnTransferFinished_m = pfnCbOrigMsg_p;

    if (pMsgDescr->pRespMsgDescr_m != NULL)
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
            if (pMsgDescr->MsgHdl_m.pLclBuf_m != NULL)
            {
                /* memory already allocated !*/
                Ret = kPdiAsyncStatusNoResource;
                goto exit;
            }

            pMsgDescr->MsgHdl_m.pLclBuf_m = MALLOC(MAX_ASYNC_STREAM_LENGTH);
            if (pMsgDescr->MsgHdl_m.pLclBuf_m == NULL)
            {
                Ret = kPdiAsyncStatusNoResource;
                goto exit;
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
                    if (pMsgDescr->MsgHdl_m.pLclBuf_m != NULL)
                    {
                        FREE(pMsgDescr->MsgHdl_m.pLclBuf_m);
                        pMsgDescr->MsgHdl_m.pLclBuf_m = NULL;
                    }
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

        default:
            break;
    }

    /* activate message */
    pMsgDescr->MsgStatus_m = kPdiAsyncMsgStatusQueuing;

    Ret = kPdiAsyncStatusSuccessful;

exit:
    return Ret;
}

/**
 ********************************************************************************
 \brief saves the context of the current message

 \return BOOL
 \retval TRUE       if successful
 \retval FALSE      if there is already a message pending

 This function saves all global variables temporarily, so current message transfer
 can be interrupted by another message transfer. The message context can be
 restored again with CnApiAsync_restoreMsgContext(). In addition, all global
 variables are restored to their default values.
 *******************************************************************************/
BOOL CnApiAsync_saveMsgContext(void)
{
    if (PdiAsyncPendTrfContext_l.fMsgPending_m == FALSE)
    {
        PdiAsyncPendTrfContext_l.bState_m                 = PdiAsyncStateMachine_l.m_bCurrentState;
        PdiAsyncPendTrfContext_l.fError_m                 = fError;
        PdiAsyncPendTrfContext_l.fTimeout_m               = fTimeout;
        PdiAsyncPendTrfContext_l.fReset_m                 = fReset;
        PdiAsyncPendTrfContext_l.fRxTriggered_m           = fRxTriggered;
        PdiAsyncPendTrfContext_l.fTxTriggered_m           = fTxTriggered;
        PdiAsyncPendTrfContext_l.fFrgmtAvailable_m        = fFrgmtAvailable;
        PdiAsyncPendTrfContext_l.fFrgmtStored_m           = fFrgmtStored;
        PdiAsyncPendTrfContext_l.fFrgmtDelivered_m        = fFrgmtDelivered;
        PdiAsyncPendTrfContext_l.fMsgTransferFinished_m   = fMsgTransferFinished;
        PdiAsyncPendTrfContext_l.fMsgTransferIncomplete_m = fMsgTransferIncomplete;
        PdiAsyncPendTrfContext_l.fFragmentedTransfer_m    = fFragmentedTransfer;
        PdiAsyncPendTrfContext_l.fDeactivateRxMsg_m       = fDeactivateRxMsg;
        PdiAsyncPendTrfContext_l.bActivTxMsg_m            = bActivTxMsg_l;
        PdiAsyncPendTrfContext_l.bActivRxMsg_m            = bActivRxMsg_l;
        PdiAsyncPendTrfContext_l.pLclAsyncTxMsgBuffer_m   = pLclAsyncTxMsgBuffer_l;
        PdiAsyncPendTrfContext_l.ErrorHistory_m           = ErrorHistory_l;
        PdiAsyncPendTrfContext_l.pLclAsyncRxMsgBuffer_m   = pLclAsyncRxMsgBuffer_l;
        PdiAsyncPendTrfContext_l.dwTimeoutWait_m          = dwTimeoutWait_l;
        PdiAsyncPendTrfContext_l.fMsgPending_m            = TRUE;

        /* reset global variables */
        fError                                 = FALSE;
        fTimeout                               = FALSE;
        fReset                                 = FALSE;
        fRxTriggered                           = FALSE;
        fTxTriggered                           = FALSE;
        fFrgmtAvailable                        = FALSE;
        fFrgmtStored                           = FALSE;
        fFrgmtDelivered                        = FALSE;
        fMsgTransferFinished                   = FALSE;
        fMsgTransferIncomplete                 = FALSE;
        fFragmentedTransfer                    = FALSE;
        fDeactivateRxMsg                       = FALSE;
        bActivTxMsg_l                          = INVALID_ELEMENT;
        bActivRxMsg_l                          = INVALID_ELEMENT;
        pLclAsyncTxMsgBuffer_l                 = NULL;
        ErrorHistory_l                         = kPdiAsyncStatusSuccessful;
        pLclAsyncRxMsgBuffer_l                 = NULL;
        dwTimeoutWait_l                        = 0;

        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

/**
 ********************************************************************************
 \brief restores the context of a pending message

 \return BOOL
 \retval TRUE       if successful
 \retval FALSE      if no pending message present

 This function restores all global variables with the values they had before
 CnApiAsync_saveMsgContext() was executed, so a pending message transfer is
 able to continue after interruption.
 *******************************************************************************/
BOOL CnApiAsync_restoreMsgContext(void)
{
    if (PdiAsyncStateMachine_l.m_fResetInProgress == TRUE)
    {
        // state change not allowed
        return FALSE;
    }

    if (PdiAsyncPendTrfContext_l.fMsgPending_m == TRUE)
    {
        PdiAsyncStateMachine_l.m_bCurrentState = PdiAsyncPendTrfContext_l.bState_m; //TODO: is this state machine manipulation working (for DO-Action)?
        fError                                 = PdiAsyncPendTrfContext_l.fError_m;
        fTimeout                               = PdiAsyncPendTrfContext_l.fTimeout_m;
        fReset                                 = PdiAsyncPendTrfContext_l.fReset_m;
        fRxTriggered                           = PdiAsyncPendTrfContext_l.fRxTriggered_m;
        fTxTriggered                           = PdiAsyncPendTrfContext_l.fTxTriggered_m;
        fFrgmtAvailable                        = PdiAsyncPendTrfContext_l.fFrgmtAvailable_m;
        fFrgmtStored                           = PdiAsyncPendTrfContext_l.fFrgmtStored_m;
        fFrgmtDelivered                        = PdiAsyncPendTrfContext_l.fFrgmtDelivered_m;
        fMsgTransferFinished                   = PdiAsyncPendTrfContext_l.fMsgTransferFinished_m;
        fMsgTransferIncomplete                 = PdiAsyncPendTrfContext_l.fMsgTransferIncomplete_m;
        fFragmentedTransfer                    = PdiAsyncPendTrfContext_l.fFragmentedTransfer_m;
        fDeactivateRxMsg                       = PdiAsyncPendTrfContext_l.fDeactivateRxMsg_m;
        bActivTxMsg_l                          = PdiAsyncPendTrfContext_l.bActivTxMsg_m;
        bActivRxMsg_l                          = PdiAsyncPendTrfContext_l.bActivRxMsg_m;
        pLclAsyncTxMsgBuffer_l                 = PdiAsyncPendTrfContext_l.pLclAsyncTxMsgBuffer_m;
        ErrorHistory_l                         = PdiAsyncPendTrfContext_l.ErrorHistory_m;
        pLclAsyncRxMsgBuffer_l                 = PdiAsyncPendTrfContext_l.pLclAsyncRxMsgBuffer_m;
        dwTimeoutWait_l                        = PdiAsyncPendTrfContext_l.dwTimeoutWait_m;
        PdiAsyncPendTrfContext_l.fMsgPending_m = FALSE;

        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

/**
********************************************************************************
\brief  resets the log counter after a Async SM reset
*******************************************************************************/
void CnApiAsync_resetMsgLogCounter(void)
{
    bLinkLogCounter_l = 0;
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
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncRxStatePending, kPdiAsyncStateWait, 1);     //Transition event2
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncRxStatePending, kPdiAsyncStateStopped, 1);  //Transition event3
    SM_ADD_ACTION_110(&PdiAsyncStateMachine_l, kPdiAsyncRxStatePending);                            //ENTRY and DOACT

    /* state: ASYNC_STOPPED */
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncStateStopped, kPdiAsyncStateWait, 1);       //Transition event1
    SM_ADD_TRANSITION(&PdiAsyncStateMachine_l, kPdiAsyncStateStopped, STATE_FINAL, 1);              //Transition event2
    SM_ADD_ACTION_110(&PdiAsyncStateMachine_l, kPdiAsyncStateStopped);                              //ENTRY and DOACT

    CnApi_resetAsyncStateMachine();
}

/**
********************************************************************************
\brief  activate state machine
*******************************************************************************/
void CnApi_resetAsyncStateMachine(void)
{
    DEBUG_FUNC;

    fError = FALSE;                 // transition event
    fTimeout = FALSE;               // transition event
    fReset = FALSE;                 // transition event
    fRxTriggered = FALSE;           // transition event -> explicitly wait for special message
    fTxTriggered = FALSE;           // transition event
    fFrgmtAvailable = FALSE;        // transition event
    fFrgmtStored = FALSE;           // transition event
    fFrgmtDelivered = FALSE;        // transition event
    fMsgTransferFinished = FALSE;   // transition event
    fMsgTransferIncomplete = FALSE; // transition event
    fFragmentedTransfer = FALSE;    // indicates stream segmentation

    ErrorHistory_l = kPdiAsyncStatusSuccessful;

    bActivTxMsg_l = INVALID_ELEMENT; // indicates inactive message
    bActivRxMsg_l = INVALID_ELEMENT; // indicates inactive message
    pLclAsyncTxMsgBuffer_l = NULL;   // pointer to local Tx message buffer
    pLclAsyncRxMsgBuffer_l = NULL;   // pointer to local Rx message buffer
    dwTimeoutWait_l = 0;             // timeout counter

    PdiAsyncPendTrfContext_l.fMsgPending_m = FALSE;

    MEMSET( aPdiAsyncRxMsgs, 0x00, sizeof(tPdiAsyncMsgDescr) * MAX_PDI_ASYNC_RX_MESSAGES );
    MEMSET( aPdiAsyncTxMsgs, 0x00, sizeof(tPdiAsyncMsgDescr) * MAX_PDI_ASYNC_TX_MESSAGES );

    /* initialize state machine */
    sm_reset(&PdiAsyncStateMachine_l);
}

/**
 ********************************************************************************
 \brief  update state machine

 \return BOOL
 \retval TRUE       if successful
 \retval FALSE      if no message needs to be processed
*******************************************************************************/
BOOL CnApi_processAsyncStateMachine(void)
{
    if(fSmProcessingAllowed_l)
    {
        return sm_update(&PdiAsyncStateMachine_l);
    }

    return FALSE;
}

/**
********************************************************************************
\brief  check if state machine is running

 \return BOOL
 \retval TRUE       state machine is running
 \retval FALSE      state mchine is final
*******************************************************************************/
BOOL CnApi_checkAsyncStateMachineRunning(void)
{
    if (sm_getState(&PdiAsyncStateMachine_l) != STATE_FINAL)
        return TRUE;
    else
        return FALSE;
}

/**
********************************************************************************
\brief  start state machine processing again
*******************************************************************************/
void CnApi_enableAsyncSmProcessing(void)
{
    fSmProcessingAllowed_l = TRUE;
}

/**
********************************************************************************
\brief  block state machine processing
*******************************************************************************/
void CnApi_disableAsyncSmProcessing(void)
{
    fSmProcessingAllowed_l = FALSE;
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
