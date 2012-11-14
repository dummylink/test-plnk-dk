/*******************************************************************************
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       pcpPdi.c

\brief      Powerlink Communication Processor Data Interface module

\date       13.11.2012

This module extends the openPOWERLINK API with a Process Data Interface (PDI).
The PDI can be accessed by an Application Processor (AP) using a parallel or
serial low level (hardware) data interface.

*******************************************************************************/
/* includes */
#include <pcpPdi.h>
#include <pcpEvent.h>
#include <EplObdDefAccHstry.h>
#include <pcpSync.h>
#include <pcpPdo.h>
#include <pcpAsyncSm.h>

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
volatile tPcpCtrlReg *         pCtrlReg_g;    ///< ptr. to PCP control register
static tApiPdiComCon ApiPdiComInstance_g;            ///< PDI OBD access connection
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

/**
********************************************************************************
\brief    enable PDI synchronization interrupt signal if it is activated by AP
*******************************************************************************/
static void pcpPdi_enableSyncIntIfConfigured(void)
{
    /* enable the synchronization interrupt */
    if(Gi_getSyncIntCycle() != 0)   // true if Sync IR is required by AP
    {
        Gi_enableSyncInt();    // enable IR trigger possibility
    }
}

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  create table of objects to be linked at PCP side according to AP message

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
\brief    basic initializations
\param pStateMachineInit_p  [IN] callback functions for PCP state machine
\param pInitParam_p         [IN] pointer to initialization parameter
                                 which will be set later in the pcpAsync module
*******************************************************************************/
int Gi_init(tInitStateMachine * pStateMachineInit_p, tPcpInitParam * pInitParam_p)
{
    int         iRet= OK;
    UINT32      uiApplicationSwDate = 0;
    UINT32      uiApplicationSwTime = 0;

#ifdef CONFIG_IIB_IS_PRESENT
    tFwRet      FwRetVal = kFwRetSuccessful;

    FwRetVal = getImageApplicationSwDateTime(&uiApplicationSwDate, &uiApplicationSwTime);
    if (FwRetVal != kFwRetSuccessful)
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: getImageApplicationSwDateTime() failed with 0x%x\n", FwRetVal);
    }
#endif // CONFIG_IIB_IS_PRESENT

    /* Setup PCP Control Register in DPRAM */
    pCtrlReg_g = (tPcpCtrlReg *)PDI_DPRAM_BASE_PCP;     // set address of control register - equals DPRAM base address

    // Note:
    // pCtrlReg_g members m_dwMagic, m_wPcpPdiRev and m_wPcpSysId are set by the Powerlink IP-core.
    // The FPGA internal memory initialization sets the following values:
    // pCtrlReg_g->m_wState: 0x00EE
    // pCtrlReg_g->m_wCommand: 0xFFFF
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwAppDate, uiApplicationSwDate);
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwAppTime, uiApplicationSwTime);
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventType, 0x00);                // invalid event TODO: structure
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventArg, 0x00);                 // invalid event argument TODO: structure
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wState, kPcpStateInvalid);        // set invalid PCP state

    DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Wait for AP reset cmd..\n");

    /* wait for reset command from AP */
    while (getCommandFromAp() != kApCmdReset)
        ;

    // init event fifo queue
    Gi_pcpEventFifoInit();

    // init time sync module
    Gi_initSync();

    pStateMachineInit_p->m_fpOperationalPlk = pcpPdi_enableSyncIntIfConfigured;

    // start PCP API state machine and move to PCP_BOOTED state
    if(Gi_initStateMachine(pStateMachineInit_p) == FALSE)
    {
        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrInitFailed);
        DEBUG_TRACE0(DEBUG_LVL_09, "Gi_initStateMachine() FAILED!\n");
        goto exit;
    }

    // init asynchronous PCP <-> AP communication
    iRet = CnApiAsync_create(pInitParam_p);
    if (iRet != OK )
    {
        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrInitFailed);
        DEBUG_TRACE0(DEBUG_LVL_09, "CnApiAsync_create() FAILED!\n");
        goto exit;
    }

    // init cyclic object processing
    iRet = Gi_initPdo();
    if (iRet != OK )
    {
        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrInitFailed);
        DEBUG_TRACE0(DEBUG_LVL_09, "Gi_initPdo() FAILED!\n");
        goto exit;
    }

exit:
    return iRet;
}

/**
********************************************************************************
\brief  cleanup and exit generic interface
*******************************************************************************/
void Gi_shutdown(void)
{
    /* free object link table */
    EPL_FREE(pPcpLinkedObjs_g);

    //TODO: free other things
}

/**
********************************************************************************
\brief    control LED outputs of POWERLINK IP core
*******************************************************************************/
void Gi_controlLED(tCnApiLedType bType_p, BOOL bOn_p)
{
    WORD        wRegisterBitNum;
    WORD        wLedControl;

    switch (bType_p)
        {
        case kCnApiLedTypeStatus:
            wRegisterBitNum = LED_STATUS;
            break;
        case kCnApiLedTypeError:
            wRegisterBitNum = LED_ERROR;
            break;
        case kCnApiLedInit:
            /* This case if for initing the LEDs */
            /* enable forcing for all LEDs */
            AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wLedConfig, 0xffff);
            if (bOn_p)  //activate LED output
            {
                AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wLedControl, 0xffff);  // switch on all LEDs
            }
            else       // deactive LED output
            {
                AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wLedControl, 0x0000); // switch off all LEDs

                /* disable forcing all LEDs except status and error LED (default register value) */
                AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wLedConfig, 0x0003);
            }
            goto exit;
        default:
            goto exit;
        }

    wLedControl = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wLedControl));

    if (bOn_p)  //activate LED output
    {
        wLedControl |= (1 << wRegisterBitNum);
    }
    else        // deactive LED output
    {
        wLedControl &= ~(1 << wRegisterBitNum);
    }

    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wLedControl, wLedControl);

exit:
    return;
}

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
\brief    get command from AP

getCommandFromAp() gets the command from the application processor(AP).

\return        command from AP
*******************************************************************************/
BYTE getCommandFromAp(void)
{
    return AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wCommand));
}

/**
********************************************************************************
\brief    store the state the PCP is in
*******************************************************************************/
void storePcpState(BYTE bState_p)
{
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wState, bState_p);
}

/**
********************************************************************************
\brief    get the state of the PCP state machine
*******************************************************************************/
WORD getPcpState(void)
{
    return AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wState));
}

/**
********************************************************************************
\brief  inform AP about current Node ID setting
\param  wNodeId     current Node ID of PCP
*******************************************************************************/
void pcpPdi_setNodeIdInfo(WORD wNodeId)
{
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wNodeId, wNodeId);
    Gi_pcpEventPost(kPcpPdiEventGeneric, kPcpGenEventNodeIdConfigured);
}

/**
********************************************************************************
\brief    post pending events to PDI
*******************************************************************************/
void pcpPdi_processEvents(void)
{
    /* Check if previous event has been confirmed by AP */
    /* If not, try to post it */
    if(Gi_pcpEventFifoProcess(pCtrlReg_g) == kPcpEventFifoPosted)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_EVENT_INFO,"%s: Posted event from fifo into PDI!\n", __func__);
    }
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
