/*******************************************************************************
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1                           
* All rights reserved. All use of this software and documentation is          
* subject to the License Agreement located at the end of this file below.     
*/

/**
********************************************************************************

\file       pcpObjects.c

\brief      module handles object forwarding to PDI

\date       15.11.2012

*******************************************************************************/
/* includes */
#include <pcpObjects.h>
#include <EplSdo.h>
//#include <pcpPdo.h>

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
static tApiPdiComCon ApiPdiComInstance_g;        ///< PDI OBD access connection
tObjTbl     *pPcpLinkedObjs_g = NULL;  ///< table of linked objects at pcp side according to AP message
DWORD       dwApObjLinkEntries_g = 0;  ///< number of linked objects at pcp side

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/**
 ********************************************************************************
 \brief returns current OBD access forwarding communication index
 \param  pApiPdiComConInst_p  pointer to PDI communication connection instance
 \param  pwComConIdx_p        [OUT]: communication connection index
 \return BOOL
 \retval TRUE   connection found
 \retval FALSE  no connection available
 *******************************************************************************/
static BOOL Gi_getCurPdiObdAccFwdComConIntern(tApiPdiComCon * pApiPdiComConInst_p,
                                        WORD * pwComConIdx_p)
{
    tObdAccComCon * pObdAccComCon = &pApiPdiComConInst_p->m_ObdAccFwd;

    if(pObdAccComCon->m_Origin == kObdAccStorageDefObdAccHistory)
    {
        *pwComConIdx_p = pObdAccComCon->m_wComConIdx;
        return TRUE;
    }

    *pwComConIdx_p = OBD_DEFAULT_ACC_INVALID;
    return FALSE;
}

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  check if forwarding object access to PDI is possible

\param pDefObdHdl_p         default OBD access history entry
\retval kEplSuccessful      forwarding object access to PDI is possible
\retval kEplObdOutOfMemory  PDI communication channel is in use
*******************************************************************************/
tEplKernel Gi_openObdAccHstryToPdiConnection(tObdAccHstryEntry * pDefObdHdl_p)
{
    if (ApiPdiComInstance_g.m_ObdAccFwd.m_Origin != kObdAccStorageInvalid)
    {
        pDefObdHdl_p->m_ObdParam.m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
        return kEplObdOutOfMemory;
    }

    // response has to know connection to OBD access handle
    ApiPdiComInstance_g.m_ObdAccFwd.m_wComConIdx = pDefObdHdl_p->m_wComConIdx;
    ApiPdiComInstance_g.m_ObdAccFwd.m_Origin = kObdAccStorageDefObdAccHistory;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() ComConIdx: %d\n",
                 __func__, ApiPdiComInstance_g.m_ObdAccFwd.m_wComConIdx);

    return kEplSuccessful;
}

/**
 ********************************************************************************
 \brief forwards an object access to an Application Processor (AP)
 \param pDefObdHdl_p    object access handle of object to be forwarded
 \param pDefObdHdl_p    pointer to OBD access handle history
 \retval kEplSuccessful forwarding  succeeded
 \retval kEplSdoSeqConnectionBusy   forwarding aborted because no resources
                                    are available to send a message to AP
 \retval kEplInvalidOperation       general error

 This function posts an asynchronous message to the AP which contains an object
 access request. In case of an error this function modifies the abort code of
 the input parameter pObdParam_p.
 *******************************************************************************/
tEplKernel Gi_forwardObdAccHstryEntryToPdi(tObdAccHstryEntry * pDefObdHdl_p)
{
    tPdiAsyncStatus PdiRet = kPdiAsyncStatusSuccessful;
    tEplKernel Ret = kEplSuccessful;
    tObjAccSdoComCon PdiObjAccCon;
    WORD             wComConIdx = 0;

    if (pDefObdHdl_p == NULL)
    {
        Ret = kEplInvalidParam;
        goto Exit;
    }

    Ret = Gi_openObdAccHstryToPdiConnection(pDefObdHdl_p);
    if (Ret != kEplSuccessful)
    {
        goto Exit;
    }

    if(Gi_getCurPdiObdAccFwdComConIntern(&ApiPdiComInstance_g, &wComConIdx) != FALSE)
    {   // PDI connection established

        PdiObjAccCon.m_wObdAccConNum = wComConIdx; // forward OBD access connection number to PDI
        // assign SDO command frame and convert from epl to cnapi structure
        PdiObjAccCon.m_pSdoCmdFrame = (tCnApiAsySdoCom *)pDefObdHdl_p->m_ObdParam.m_pRemoteAddress->m_le_pSdoCmdFrame;
        PdiObjAccCon.m_uiSizeOfFrame = offsetof(tEplAsySdoCom , m_le_abCommandData) +
        AmiGetWordFromLe(&pDefObdHdl_p->m_ObdParam.m_pRemoteAddress->m_le_pSdoCmdFrame->m_le_wSegmentSize);

        // Note: since PdiObjAccCon is a local variable, the call-back function
        //       has to be executed in a sub function call immediately.
        //       Therefore it can not be a "direct-access" transfer!
        PdiRet = CnApiAsync_postMsg(
                        kPdiAsyncMsgIntObjAccReq,
                        (BYTE *) &PdiObjAccCon,
                        Gi_ObdAccFwdPdiTxFinishedErrCb,
                        NULL,
                        NULL,
                        0);

        if (PdiRet == kPdiAsyncStatusRetry)
        {
            Ret = kEplSdoSeqConnectionBusy;
            pDefObdHdl_p->m_ObdParam.m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_DUE_LOCAL_CONTROL;
            goto Exit;
        }
        else if (PdiRet != kPdiAsyncStatusSuccessful)
        {
            DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: CnApiAsync_postMsg() retval 0x%x\n", PdiRet);
            pDefObdHdl_p->m_ObdParam.m_dwAbortCode = EPL_SDOAC_GENERAL_ERROR;
            Ret = kEplInvalidOperation;
            goto Exit;
        }
    }
    else
    {   // no PDI connection found
        Ret = kEplInvalidParam;
        goto Exit;
    }

Exit:
    return Ret;
}

/**
********************************************************************************
\brief  delete OBD access history to PDI connection
*******************************************************************************/
void Gi_deleteObdAccHstryToPdiConnection(void)
{
    ApiPdiComInstance_g.m_ObdAccFwd.m_wComConIdx = OBD_DEFAULT_ACC_INVALID;
    ApiPdiComInstance_g.m_ObdAccFwd.m_Origin = kObdAccStorageInvalid;
}

/**
********************************************************************************
\brief  check if forwarding object access to PDI is possible

\param wComConIdx_p             OBD access history connection Index
\param dwAbortCode_p            SDO abort code
\param wReadObjRespSegmSize_p   read access response data size (0 if not used)
\param pReadObjRespData_p       read access response data address (NULL if not used)

\return tEplKernel
\retval kEplSuccessful                      closed and finished connection
\retval kEplObdVarEntryNotExist             OBD history entry not found
*******************************************************************************/
tEplKernel Gi_closeObdAccHstryToPdiConnection(
                                                WORD wComConIdx_p,
                                                DWORD dwAbortCode_p,
                                                WORD  wReadObjRespSegmSize_p,
                                                void* pReadObjRespData_p)
{
    tEplKernel Ret = kEplSuccessful;
    tObdAccHstryEntry * pObdAccHstEntry = NULL;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() ComConIdx: %d\n",
                 __func__, ApiPdiComInstance_g.m_ObdAccFwd.m_wComConIdx);

    Ret = EplAppDefObdAccAdoptedHstryGetEntry(wComConIdx_p,
                                              &pObdAccHstEntry);
    if (Ret == kEplObdVarEntryNotExist)
    {
        // history entry could not be found,
        // it was deleted due to an error or reset -> stop further processing
        goto exit;
    }
    else if(Ret != kEplSuccessful)
    {
        goto exit;
    }
    else
    {
        if (pObdAccHstEntry->m_ObdParam.m_dwAbortCode == 0)
        {
            if(dwAbortCode_p != 0)
            {   // Only overwrite abort code if it wasn't assigned ealier by another module
                pObdAccHstEntry->m_ObdParam.m_dwAbortCode = dwAbortCode_p;
            }
            else
            {   // all abort codes are 0
                if(pObdAccHstEntry->m_ObdParam.m_ObdEvent == kEplObdEvPreRead)
                {
                    // assign data information needed by object read response
                    pObdAccHstEntry->m_ObdParam.m_SegmentSize = wReadObjRespSegmSize_p;
                    pObdAccHstEntry->m_ObdParam.m_pData = pReadObjRespData_p;
                }
            }
        }

        Gi_deleteObdAccHstryToPdiConnection();

        Ret = EplAppDefObdAccAdoptedHstryEntryFinished(pObdAccHstEntry);
        if (Ret != kEplSuccessful)
        {
            goto exit;
        }
    }

exit:
    return Ret;
}

/**
 ********************************************************************************
 \brief call back function, invoked after message transfer has finished
 \param  pMsgDescr_p         pointer to asynchronous message descriptor
 \return Ret                 tPdiAsyncStatus value

 This function will be called if an OBD access forwarded to PDI has finished.
 It signals that the transfer finished to the originator in case of an
 error. This is the only functionality, the real OBD access finished function
 will be triggered by a return message from PDI (sent by AP).
 *******************************************************************************/
tPdiAsyncStatus Gi_ObdAccFwdPdiTxFinishedErrCb(tPdiAsyncMsgDescr * pMsgDescr_p)
{
tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;
tEplKernel          EplRet;
WORD                wComConIdx;

    DEBUG_FUNC;

    if (pMsgDescr_p == NULL)  // message descriptor invalid
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    // error handling
    if ((pMsgDescr_p->MsgStatus_m == kPdiAsyncMsgStatusError) &&
        (pMsgDescr_p->Error_m != kPdiAsyncStatusSuccessful)     )
    {
        if(Gi_getCurPdiObdAccFwdComConIntern(&ApiPdiComInstance_g, &wComConIdx) != FALSE)
        {
            EplRet = Gi_closeObdAccHstryToPdiConnection(wComConIdx,
                                                        EPL_SDOAC_DATA_NOT_TRANSF_DUE_LOCAL_CONTROL,
                                                        0,
                                                        NULL);
            if (EplRet != kEplSuccessful)
            {
                Ret = kPdiAsyncStatusInvalidOperation;
                goto exit;
            }
        }
        else
        {
            // seems like PDI connection was deleted already -> error
            Ret = kPdiAsyncStatusInvalidOperation;
            goto exit;
        }
    }

exit:
    return Ret;
}

/**
 ********************************************************************************
 \brief returns current OBD access forwarding communication index
 \param  pwComConIdx_p        [OUT]: communication connection index
 \return BOOL
 \retval TRUE   connection found
 \retval FALSE  no connection available
 *******************************************************************************/
BOOL Gi_getCurPdiObdAccFwdComCon(WORD * pwComConIdx_p)
{
    return Gi_getCurPdiObdAccFwdComConIntern(&ApiPdiComInstance_g, pwComConIdx_p);
}

/**
********************************************************************************
\brief  create table of cyclic objects to be linked at PCP side according to
        AP message

\param dwMaxLinks_p     Number of objects to be linked.

\return OK or ERROR
*******************************************************************************/
int Gi_createPcpObjLinksTbl(DWORD dwMaxLinks_p)
{
    if (pPcpLinkedObjs_g != NULL) // table has already been created
    {
        EPL_FREE(pPcpLinkedObjs_g);
    }
    /* allocate memory for object table */
    pPcpLinkedObjs_g = EPL_MALLOC (sizeof(tObjTbl) * dwMaxLinks_p);
    if (pPcpLinkedObjs_g == NULL)
    {
        return ERROR;
    }
    dwApObjLinkEntries_g = 0; // reset entry counter

    return OK;
}

/**
********************************************************************************
\brief  delete table of linked cyclic objects
*******************************************************************************/
void Gi_deletePcpObjLinksTbl(void)
{
    /* free object link table */
    EPL_FREE(pPcpLinkedObjs_g);
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
