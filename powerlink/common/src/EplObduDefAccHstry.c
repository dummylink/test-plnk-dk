/*******************************************************************************
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is          
* subject to the License Agreement located at the end of this file below.     
*/

/**
********************************************************************************

\file       EplObduDefAccHstry.c

\brief      Default object dictionary access history module

\date       13.11.2012

This module provides a possibility to store calls to non-existing objects in the
local object dictionary and process them later on.

*******************************************************************************/
/* includes */
#include <EplObduDefAccHstry.h>
#include <EplObduDefAcc.h>
#include <EplSdo.h>
#include <user/EplSdoAsySequ.h>
#ifdef EPL_MODULE_API_PDI
    #include <pcpObjects.h>
#endif // EPL_MODULE_API_PDI
#include <fwUpdate.h>
#include <Epl.h>


/******************************************************************************/
/* defines */
#define OBD_DEFAULT_ACC_HISTORY_ACK_FINISHED_THLD 3           ///< count of history entries, where 0BD accesses will still be acknowledged
#define OBD_DEFAULT_ACC_HISTORY_SIZE              20          ///< maximum possible history elements
/******************************************************************************/
/* typedefs */
typedef void (*tpfnAbort) (void*);

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

// segmented object access management
static tObdAccHstryEntry aObdDefAccHdl_l[OBD_DEFAULT_ACC_HISTORY_SIZE];
// available elements
static BYTE bDefObdAccHistoryEmptyCnt_g = OBD_DEFAULT_ACC_HISTORY_SIZE;
// counter of subsequent accesses to an object
static WORD wObdAccHistorySeqCnt_g = OBD_DEFAULT_ACC_INVALID;
//counter of default OBD access elements for external communication connection
static WORD wObdAccHistoryComConCnt_g = OBD_DEFAULT_ACC_INVALID;

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/**
********************************************************************************
\brief  check if OBD access history is already in use

\retval TRUE   history is in use
\retval FALSE  history is available
*******************************************************************************/
static BOOL EplAppDefObdAccAdoptedHstryCeckOccupied(void)
{
    if (bDefObdAccHistoryEmptyCnt_g < OBD_DEFAULT_ACC_HISTORY_SIZE)
    {
       return TRUE;
    }
    else
    {
        return FALSE;
    }
}

/**
 ********************************************************************************
 \brief triggers processing the next segment of an specific OBD access

 This function will trigger processing the next segment of an specific OBD access
 if it is an segmented (non-expedited) transfer. The index and subindex of
 pObdParam_p as well as the transfer size will be considered.

 \param pObdParam_p  pointer to OBD access handle ()

 \return tEplKernel value
 *******************************************************************************/
static tEplKernel EplAppDefObdAccAdoptedHstrySetupNextIfSegmented(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;
    tObdAccHstryEntry * pFoundHdl;

    // check if segmented write history is empty enough to disable flow control
    if (bDefObdAccHistoryEmptyCnt_g >=
        OBD_DEFAULT_ACC_HISTORY_SIZE - OBD_DEFAULT_ACC_HISTORY_ACK_FINISHED_THLD)
    {
        // do ordinary SDO sequence processing / reset flow control manipulation
        EplSdoAsySeqAppFlowControl(0, FALSE);
    }

    Ret = EplAppDefObdAccAdoptedHstryGetStatusEntry(
            pObdParam_p->m_uiIndex,
            pObdParam_p->m_uiSubIndex,
            kEplObdDefAccHdlWaitProcessingQueue,
            TRUE,
            &pFoundHdl);

    if (Ret == kEplSuccessful)
    {
        // it is assumed that kEplObdDefAccHdlWaitProcessingQueue signals
        // segmented transfer - otherwise the status would be
        // kEplObdDefAccHdlWaitProcessingInit for expedited SDO transfers
        DEBUG_TRACE0(DEBUG_LVL_14, "<--- Segment finished!\n\n");

        // handle found
        DEBUG_TRACE2(DEBUG_LVL_14, "%s() RePost Event: Hdl:%d\n",
                __func__, pFoundHdl->m_wComConIdx);
        Ret = EplApiPostUserEvent((void*) pFoundHdl);
        if (Ret != kEplSuccessful)
        {
            DEBUG_TRACE1 (DEBUG_LVL_ERROR, "%s() Post user event failed!\n",
                                  __func__);
            return Ret;
        }
    }
    else
    {
        DEBUG_TRACE1(DEBUG_LVL_14, "%s() Nothing to post!\n", __func__);
        Ret = kEplSuccessful; // nothing to post, thats fine
    }

    return Ret;
}

/**
 ********************************************************************************
 \brief increments a counter and omits non valid values
 \param pwCounter_p [IN]:  pointer to counter
                    [OUT]: updated counter value
 \return updated counter value
 *******************************************************************************/
static WORD EplAppDefObdAccAdoptedHstryIncrCnt(WORD * pwCounter_p)
{
    (*pwCounter_p)++;

    while((*pwCounter_p == OBD_DEFAULT_ACC_INVALID) ||
          (*pwCounter_p == 0)                         )
    {
        // omit invalid counter values
        (*pwCounter_p)++;
    }

    return *pwCounter_p;
}

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  initialize OBD access history access sequence (access to one object)
\retval kEplSuccessful      access accepted
\retval kEplObdOutOfMemory  history is occupied
*******************************************************************************/
tEplKernel EplAppDefObdAccAdoptedHstryInitSequence(void)
{
    // history has to be completely empty for new transfer
    if (EplAppDefObdAccAdoptedHstryCeckOccupied())
    {
        return kEplObdOutOfMemory;
    }
    else
    {   // reset object segment access counter
        wObdAccHistorySeqCnt_g = OBD_DEFAULT_ACC_INVALID;
        return kEplSuccessful;
    }
}

/**
********************************************************************************
\brief  check if first element of an segmented OBD accesss was stored to OBD access history

\retval TRUE   history is in use
\retval FALSE  history is available
*******************************************************************************/
BOOL EplAppDefObdAccAdoptedHstryCeckSequenceStarted(void)
{
    if (wObdAccHistorySeqCnt_g != OBD_DEFAULT_ACC_INVALID)
    {
       return TRUE;
    }
    else
    {
        return FALSE;
    }
}

/**
********************************************************************************
\brief searches for free storage of OBD access handle and saves it to
       the default OBD access history

\param pObdParam_p  [IN]:  pointer to OBD handle
\param ppDefHdl_p   [OUT]: info where the OBD handle was stored

\retval kEplSuccessful          element was successfully assigned
\retval kEplObdOutOfMemory      no free element is left
\retval kEplApiInvalidParam     wrong parameter passed to this function
*******************************************************************************/
tEplKernel EplAppDefObdAccAdoptedHstrySaveHdl(tEplObdParam * pObdParam_p,
                                              tObdAccHstryEntry **ppDefHdl_p)
{
    tObdAccHstryEntry * pObdDefAccHdl = NULL;
    BYTE bArrayNum;                     // loop counter and array element

    // check for wrong parameter values
    if (pObdParam_p == NULL)
    {
        return kEplApiInvalidParam;
    }

    // assign default OBD access handle instance
    //TODO: maybe do this in an init function (also OBD_DEFAULT_ACC_HISTORY_SIZE etc.)
    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_ACC_HISTORY_SIZE; bArrayNum++, pObdDefAccHdl++)
    {
        if (pObdDefAccHdl->m_Status == kEplObdDefAccHdlEmpty)
        {
            // free storage found -> save OBD access handle
            EPL_MEMCPY(&pObdDefAccHdl->m_ObdParam, pObdParam_p, sizeof(pObdDefAccHdl->m_ObdParam));

            // save only write data from origin since there is no 'read data' yet
            if (pObdParam_p->m_ObdEvent == kEplObdEvInitWriteLe)
            {
                if(EplAppDefObdAccCeckTranferIsSegmented(pObdParam_p) != FALSE)
                {
                    // save also object data
                    EPL_MEMCPY(&pObdDefAccHdl->m_aObdData, pObdParam_p->m_pData, pObdParam_p->m_SegmentSize);
                    pObdDefAccHdl->m_ObdParam.m_pData = &pObdDefAccHdl->m_aObdData;

                    //TODO: this can only handle local object accesses.
                    //      Currently the SDO command layer is forwarded to the PDI, but this data is not saved at the moment and
                    //      it gets invalid after "event-posting" - other than with immediately posting to PDI.
                    //      If a segmented access should be forwarded to PDI, the SDO command frame can not be stored at the same time
                    //      with the object data (=double storing) => Dont use command layer for PDI data transfer if segmented access
                    //                                                should be forwarded!
                }
                else
                {
                    pObdDefAccHdl->m_ObdParam.m_pData = NULL;
                }
            }

            // update status
            pObdDefAccHdl->m_Status = kEplObdDefAccHdlWaitProcessingInit;
            pObdDefAccHdl->m_wSeqCnt = EplAppDefObdAccAdoptedHstryIncrCnt(&wObdAccHistorySeqCnt_g);
            pObdDefAccHdl->m_wComConIdx = EplAppDefObdAccAdoptedHstryIncrCnt(&wObdAccHistoryComConCnt_g);
            bDefObdAccHistoryEmptyCnt_g--;

            // inform caller about location
            *ppDefHdl_p = pObdDefAccHdl;

            // check if history is full (flow control for SDO)
            if ( bDefObdAccHistoryEmptyCnt_g <
                (OBD_DEFAULT_ACC_HISTORY_SIZE - OBD_DEFAULT_ACC_HISTORY_ACK_FINISHED_THLD))
            {
                // prevent SDO from ack the last received frame
                EplSdoAsySeqAppFlowControl(TRUE, TRUE);
            }
            return kEplSuccessful;
        }
    }

    // no free storage found if we reach here
    pObdDefAccHdl->m_ObdParam.m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
    return kEplObdOutOfMemory;
}

/**
********************************************************************************
\brief deletes an OBD access history element

\param pDefObdHdl_p        OBD access history element which should be deleted
*******************************************************************************/
void EplAppDefObdAccAdoptedHstryDeleteEntry(tObdAccHstryEntry *  pDefObdHdl_p)
{
    // reset status
    pDefObdHdl_p->m_Status = kEplObdDefAccHdlEmpty;
    pDefObdHdl_p->m_wSeqCnt = OBD_DEFAULT_ACC_INVALID;
    pDefObdHdl_p->m_wComConIdx = OBD_DEFAULT_ACC_INVALID;

    // delete OBD access handle
    EPL_MEMSET(&pDefObdHdl_p->m_ObdParam, 0x00, sizeof(pDefObdHdl_p->m_ObdParam));

    //note: Data (m_aObdData) will no be reset since it is
    //      too time consuming. It should only be interpreted if
    //      'pDefObdHdl_p->m_ObdParam.m_aObdData' is != NULL.

    // update history status
    bDefObdAccHistoryEmptyCnt_g++;
    DEBUG_TRACE1(DEBUG_LVL_14, "New SDO History Empty Cnt: %d\n",
                 bDefObdAccHistoryEmptyCnt_g);
    return;
}

/**
********************************************************************************
 \brief searches for an adopted OBD access history entry

This function searches for an adopted default OBD access history entry.
The one which contains searched communication index will be returned in a
parameter.

\param wComConIdx_p   communication connection index to be search for
\param ppDefHdl_p     [OUT]: info where the OBD handle was stored

\retval kEplSuccessful              element was found
\retval kEplObdVarEntryNotExist     no element was found
\retval kEplApiInvalidParam         wrong parameter passed to this function
*******************************************************************************/
tEplKernel EplAppDefObdAccAdoptedHstryGetEntry(WORD wComConIdx_p,
                                  tObdAccHstryEntry **ppDefObdAccHdl_p)
{
    tEplKernel      Ret;
    tObdAccHstryEntry * pObdAccHstEntry = NULL;
    BYTE            bArrayNum;          // loop counter and array element

    // check for wrong parameter values
    if (ppDefObdAccHdl_p == NULL)
    {
        return kEplApiInvalidParam;
    }

    Ret = kEplObdVarEntryNotExist;
    *ppDefObdAccHdl_p = NULL;
    pObdAccHstEntry = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_ACC_HISTORY_SIZE;
         bArrayNum++, pObdAccHstEntry++)
    {
        if (wComConIdx_p == pObdAccHstEntry->m_wComConIdx)
        {
            // assigned found handle
             *ppDefObdAccHdl_p = pObdAccHstEntry;
             Ret = kEplSuccessful;
             break;
        }
    }

    if (Ret != kEplSuccessful)
    {
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "%s: CCIdx %d not found!\n",
                     __func__, wComConIdx_p);
    }

    return Ret;
}

/**
********************************************************************************
\brief searches for a segmented OBD access handle with a specific status

This function searches for a segmented OBD access handle. it searches for index,
subindex and status. If fSearchOldestEntry is TRUE the oldest entry in history
is searched.

\param wIndex_p             index of searched element
\param wSubIndex_p          subindex of searched element
\param ReqStatus_p          requested status of handle
\param fSearchOldestEntry   if TRUE, the oldest object access will be returned
\param ppObdParam_p         IN:  caller provides  target pointer address
                            OUT: address of found element or NULL

\retval kEplSuccessful              element was found
\retval kEplObdVarEntryNotExist     no element was found
\retval kEplApiInvalidParam         wrong parameter passed to this function
*******************************************************************************/
tEplKernel EplAppDefObdAccAdoptedHstryGetStatusEntry(
                                        WORD wIndex_p,
                                        WORD wSubIndex_p,
                                        tEplObdAccStatus ReqStatus_p,
                                        BOOL fSearchOldest_p,
                                        tObdAccHstryEntry **ppDefObdAccHdl_p)
{
    tEplKernel      Ret;
    tObdAccHstryEntry * pObdDefAccHdl = NULL;
    BYTE            bArrayNum;          // loop counter and array element

    // check for wrong parameter values
    if (ppDefObdAccHdl_p == NULL)
    {
        return kEplApiInvalidParam;
    }

    Ret = kEplObdVarEntryNotExist;
    *ppDefObdAccHdl_p = NULL;
    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_ACC_HISTORY_SIZE;
         bArrayNum++, pObdDefAccHdl++)
    {

        // search for index, subindex and status
        if ((pObdDefAccHdl->m_ObdParam.m_uiIndex == wIndex_p)        &&
            (pObdDefAccHdl->m_ObdParam.m_uiSubIndex == wSubIndex_p) &&
            (pObdDefAccHdl->m_wSeqCnt != OBD_DEFAULT_ACC_INVALID) &&
            (pObdDefAccHdl->m_Status == ReqStatus_p))
        {
            /* handle found */
            /* check if we have already found another handle */
            if (*ppDefObdAccHdl_p == NULL)
            {
                /* It is the first found handle, therefore save it */
                *ppDefObdAccHdl_p = pObdDefAccHdl;
                Ret = kEplSuccessful;
                if (!fSearchOldest_p)
                {
                    break;
                }
            }
            else
            {
                /* we found a handle but it is not the first one. We compare the
                 * sequence counter and if it is older we store it. */
                if ((*ppDefObdAccHdl_p)->m_wSeqCnt > pObdDefAccHdl->m_wSeqCnt)
                {
                    *ppDefObdAccHdl_p = pObdDefAccHdl;
                }
            }
        }
    }
    return Ret;
}

/**
********************************************************************************
\brief     write to domain object which is not in object dictionary

This function writes to an object which does not exist in the local object
dictionary by using segmented access (to domain object)

\param  pDefObdAccHdl_p             pointer to default OBD access for segmented
                                    access
\param  pfnSegmentFinishedCb_p      pointer to finished callback function
\param  pfnSegmentAbortCb_p         pointer to abort callback function

\retval tEplKernel value
*******************************************************************************/
tEplKernel EplAppDefObdAccAdoptedHstryWriteSegm(
                                        tObdAccHstryEntry * pDefObdAccHdl_p,
                                        void * pfnSegmentFinishedCb_p,
                                        void * pfnSegmentAbortCb_p)
{
    tEplKernel Ret = kEplSuccessful;
    tEplSdoComConState FwRet = 0;

    if ((pDefObdAccHdl_p == NULL)                                       ||
        (pDefObdAccHdl_p->m_ObdParam.m_ObdEvent != kEplObdEvInitWriteLe)  )
    {
        return kEplApiInvalidParam;
    }

    pDefObdAccHdl_p->m_Status = kEplObdDefAccHdlProcessing;

    switch (pDefObdAccHdl_p->m_ObdParam.m_uiIndex)
    {
        case 0x1F50:
            switch (pDefObdAccHdl_p->m_ObdParam.m_uiSubIndex)
            {
                case 0x01:
                    FwRet = updateFirmware(
                              pDefObdAccHdl_p->m_ObdParam.m_SegmentOffset,
                              pDefObdAccHdl_p->m_ObdParam.m_SegmentSize,
                              (void*) pDefObdAccHdl_p->m_ObdParam.m_pData,
                              pfnSegmentAbortCb_p, pfnSegmentFinishedCb_p,
                              (void *)pDefObdAccHdl_p);

                    // TODO: forward AP firmware file part to PDI (in backround loop)

                    if (FwRet != kEplSdoComTransferFinished)
                    {
                        if (FwRet == kEplSdoComTransferRunning)
                        {
                            EplSdoAsySeqAppFlowControl(TRUE, TRUE);
                        }
                        else
                        {
                            //update operation went wrong
                            Ret = kEplObdAccessViolation;
                        }
                    }
                    break;

                default:
                    Ret = kEplObdSubindexNotExist;
                    break;
            }
            break;

        default:
#ifdef EPL_MODULE_API_PDI
            // abort transfer because segmented access forwarding is not supported
            ((tpfnAbort) pfnSegmentAbortCb_p)(pDefObdAccHdl_p);

            //TODO: uncomment the following line and delete the obove line
            //      to enable forwarding of segmented write transfer.
            //Ret = Gi_forwardObdAccHstryEntryToPdi(pDefObdAccHdl_p);
#else
            Ret = kEplObdIndexNotExist;
#endif // EPL_MODULE_API_PDI
            break;
    }

    return Ret;
}

/**
 ********************************************************************************
 \brief signals an OBD default access as finished

 This function calls the call-back function assigned by the originator of the
 OBD access and deletes the history entry from the OBD access history.
 The OBD access handle which is returned to the originators call-back function
 is expected to be fully ready for the 'OBD-access-finished' function call.

 \param pObdAccHstEntry_p  pointer to history entry (contains OBD access handle)

 \return tEplKernel value
 *******************************************************************************/
tEplKernel EplAppDefObdAccAdoptedHstryEntryFinished(tObdAccHstryEntry * pObdAccHstEntry_p)
{
tEplKernel Ret = kEplSuccessful;
tEplObdParam * pObdParam = &pObdAccHstEntry_p->m_ObdParam;
tEplObdParam SavedObdParam;

    DEBUG_TRACE2(DEBUG_LVL_14, "INFO: %s(%d) called\n",
            __func__, pObdAccHstEntry_p->m_wComConIdx);

    if ((pObdAccHstEntry_p == NULL)                                 ||
        (pObdAccHstEntry_p->m_ObdParam.m_pfnAccessFinished) == NULL   )
    {
        Ret = kEplInvalidParam;
        goto Exit;
    }

    // check if it was a segmented write SDO transfer (domain object write access)
    if ((pObdParam->m_ObdEvent == kEplObdEvPreRead)            &&
        (//(pObdParam->m_SegmentSize != pObdParam->m_ObjSize) ||
         //TODO: implement object size in Async message for segmented access
         (pObdParam->m_SegmentOffset != 0)                    )  )
    {
        //segmented read access not allowed!
        pObdParam->m_dwAbortCode = EPL_SDOAC_UNSUPPORTED_ACCESS;
    }

    // save OBD indices for segmented transfer
    EPL_MEMCPY(&SavedObdParam, &pObdAccHstEntry_p->m_ObdParam, sizeof(SavedObdParam));

    // call callback function which was assigned by originator
    Ret = pObdParam->m_pfnAccessFinished(pObdParam);

    if ((Ret == kEplSuccessful)        &&
        (SavedObdParam.m_dwAbortCode == 0)  )
    {
        Ret = EplAppDefObdAccAdoptedHstrySetupNextIfSegmented(&SavedObdParam);
    }

    EplAppDefObdAccAdoptedHstryDeleteEntry(pObdAccHstEntry_p);

Exit:
    if (Ret != kEplSuccessful)
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: %s failed!\n", __func__);
    }
    return Ret;
}

/**
 ********************************************************************************
 \brief processes an OBD write access

 This function processes an saved OBD write access

 \param pObdAccHstEntry_p  pointer to history entry (contains OBD access handle)

 \return tEplKernel value
 *******************************************************************************/
tEplKernel EplAppDefObdAccAdoptedHstryProcessWrite(tObdAccHstryEntry * pObdAccHstEntry_p)
{
    tEplKernel      Ret = kEplSuccessful;
    tEplObdParam *  pObdParam;
    tObdAccHstryEntry * pTempHdl; // handle for temporary storage

    pObdParam = &pObdAccHstEntry_p->m_ObdParam;

    DEBUG_TRACE1(DEBUG_LVL_14,
                 "AppCbEvent(kEplApiEventUserDef): (EventArg %p)\n", pObdParam);

    // If the segmented OBD handle can not be found in the history, it was already deleted.
    // Immediately return in this case.
    if (pObdAccHstEntry_p->m_Status == kEplObdDefAccHdlEmpty)
    {   // segment was already finished or aborted
        // therefore we silently ignore it and exit
        DEBUG_TRACE2(DEBUG_LVL_ERROR,
                     "%s() ERROR: Out-dated handle received %p!\n",
                     __func__, pObdParam);
        return kEplSuccessful;
    }

    DEBUG_TRACE4(DEBUG_LVL_14, "(0x%04X/%u Ev=%X Size=%u\n",
         pObdParam->m_uiIndex, pObdParam->m_uiSubIndex,
         pObdParam->m_ObdEvent,
         pObdParam->m_SegmentSize);

    /*printf("(0x%04X/%u Ev=%X pData=%p Off=%u Size=%u\n"
           " ObjSize=%u TransSize=%u Acc=%X Typ=%X)\n",
        pObdParam->m_uiIndex, pObdParam->m_uiSubIndex,
        pObdParam->m_ObdEvent,
        pObdParam->m_pData,
        pObdParam->m_SegmentOffset, pObdParam->m_SegmentSize,
        pObdParam->m_ObjSize, pObdParam->m_TransferSize,
        pObdParam->m_Access, pObdParam->m_Type); */

    /*------------------------------------------------------------------------*/
    // check if a segment of this object is currently being processed
    Ret = EplAppDefObdAccAdoptedHstryGetStatusEntry(pObdParam->m_uiIndex,
                                            pObdParam->m_uiSubIndex,
                                            kEplObdDefAccHdlProcessing,
                                            FALSE,  // search first
                                            &pTempHdl);
    if (Ret == kEplSuccessful)
    {   // write operation for this object is already processing
        DEBUG_TRACE3(DEBUG_LVL_14,
                     "%s() Write for object %d(%d) already in progress -> exit\n",
                     __func__, pObdParam->m_uiIndex, pObdParam->m_uiSubIndex);
        // change handle status -> queue segment
        pObdAccHstEntry_p->m_Status = kEplObdDefAccHdlWaitProcessingQueue;
    }
    else
    {
        switch (pObdAccHstEntry_p->m_Status)
        {
            case kEplObdDefAccHdlWaitProcessingInit:
            case kEplObdDefAccHdlWaitProcessingQueue:
                // segment has not been processed yet -> do a initialize writing

                // change handle status
                pObdAccHstEntry_p->m_Status = kEplObdDefAccHdlWaitProcessingQueue;

                /* search for oldest handle where m_pfnAccessFinished call is
                 * still due. As we know that we find at least our own handle,
                 * we don't have to take care of the return value! (Assuming
                 * there is no software error :) */
                EplAppDefObdAccAdoptedHstryGetStatusEntry(pObdParam->m_uiIndex,
                        pObdParam->m_uiSubIndex,
                        kEplObdDefAccHdlWaitProcessingQueue,
                        TRUE,           // find oldest
                        &pTempHdl);

                DEBUG_TRACE4(DEBUG_LVL_14, "%s() Check for oldest handle. EventHdl:%p Oldest:%p (Seq:%d)\n",
                             __func__, pObdParam, &pObdAccHstEntry_p->m_ObdParam,
                             pObdAccHstEntry_p->m_wSeqCnt);

                if (pTempHdl == pObdAccHstEntry_p)
                {   // this is the oldest handle so we do the write
                    Ret = EplAppDefObdAccAdoptedHstryWriteSegm(pObdAccHstEntry_p,
                                     EplAppDefObdAccAdoptedHstryEntryFinished,
                                     EplAppDefObdAccAdoptedHstryWriteSegmAbortCb);
                }
                else
                {
                    // it is not the oldest handle so do nothing
                    // and wait until this function is called with the oldest
                    Ret = kEplSuccessful;
                }
                break;

            case kEplObdDefAccHdlError:
            default:
                // all other not handled cases are not allowed -> error
                DEBUG_TRACE2(DEBUG_LVL_ERROR, "%s() ERROR: Invalid handle status %d!\n",
                        __func__, pObdAccHstEntry_p->m_Status);
                // do ordinary SDO sequence processing / reset flow control manipulation
                EplSdoAsySeqAppFlowControl(0, FALSE);
                // Abort all not empty handles of segmented transfer
                EplAppDefObdAccAdoptedHstryCleanup();
                Ret = kEplSuccessful;
                break;
        } // switch (pObdAccHstEntry_p->m_Status)
    } /* else -- handle already in progress */

    return Ret;
}

/**
********************************************************************************
\brief abort callback function

EplAppDefObdAccAdoptedHstryWriteSegmAbortCb() will be called if a segmented write
transfer should be aborted.

\param pDefObdHdl_p     OBD access history element which should be aborted
\retval always 0
*******************************************************************************/
int EplAppDefObdAccAdoptedHstryWriteSegmAbortCb(tObdAccHstryEntry * pDefObdHdl_p)
{
    // Disable flow control
    EplSdoAsySeqAppFlowControl(0, FALSE);

    DEBUG_TRACE1 (DEBUG_LVL_14, "<--- Abort callback Handle:%d!\n\n",
            pDefObdHdl_p->m_wComConIdx);

    // Abort all not empty handles of segmented transfer
    EplAppDefObdAccAdoptedHstryCleanup();

    return 0;
}

/**
 ********************************************************************************
 \brief cleans the default OBD access history buffers

 This function clears errors from the segmented access history buffer which is
 used for default OBD accesses.
 *******************************************************************************/
void EplAppDefObdAccAdoptedHstryCleanup(void)
{
    tObdAccHstryEntry * pObdDefAccHdl = NULL;
    BYTE            bArrayNum;              // loop counter and array element

    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_ACC_HISTORY_SIZE; bArrayNum++, pObdDefAccHdl++)
    {
        if (pObdDefAccHdl->m_Status == kEplObdDefAccHdlEmpty)
        {
            continue;
        }

        DEBUG_TRACE2(DEBUG_LVL_14, "%s() Cleanup handle %p\n", __func__, &pObdDefAccHdl->m_ObdParam);
        pObdDefAccHdl->m_ObdParam.m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;

        // Ignore return value
        EplAppDefObdAccAdoptedHstryEntryFinished(pObdDefAccHdl);
    }
    wObdAccHistorySeqCnt_g = OBD_DEFAULT_ACC_INVALID;
}

/*******************************************************************************
*
* License Agreement
*
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1  
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
