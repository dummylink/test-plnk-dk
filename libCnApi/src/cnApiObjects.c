/**
********************************************************************************
\file       cnApiObjects.c

\brief      CN API object functions

This module implements the object access functions of the CN API library.

Copyright � 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include <cnApi.h>
#include <malloc.h>

#include "cnApiIntern.h"
#include "cnApiObjectIntern.h"

#include "kernel/EplObdk.h"
#include "EplObd.h"


/******************************************************************************/
/* defines */
// restriction to support only expedited transfers (SDO ReadByIndex)
#define SDO_SEGMENT_TX_LIMIT    256  ///< maximum SDO segment size

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
static tObjTbl      *pObjTbl_l;
static DWORD        dwNumVarLinks_l; ///< Number local link assignments
static DWORD        dwMaxLinkEntries_l;
static DWORD        dwSelectObj_l;

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */
static void CnApi_resetLinkCounter(void);
static tCnApiObdDefAcc pfnDefaultObdAccess_l = NULL;

static tEplKernel EplCbDefaultObdAccess(tEplObdParam * pObdParam_p);
static tEplObdParam EplObdParam_l;

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief    initialize objects module

Initialize the libCnApi internal objects. (This function calls a malloc)

\param  dwMaxLinks_p            maximum number of linkable objects
\param  pfnDefaultObdAccess_p   callback for the default obd access

\return int
\retval OK                  if init succeeds
\retval ERROR               when out of memory
*******************************************************************************/
int CnApi_initObjects(DWORD dwMaxLinks_p, tCnApiObdDefAcc pfnDefaultObdAccess_p)
{
    int Ret = OK;
    tEplKernel EplRet = kEplSuccessful;

    /* when valid make default object access callback global */
    if(pfnDefaultObdAccess_p != NULL)
    {
        pfnDefaultObdAccess_l = pfnDefaultObdAccess_p;
    }
    else
    {
        Ret = ERROR;
        goto exit;
    }

    /* assign callback for all objects which don't exist in local OBD */
    EplRet = EplObdSetDefaultObdCallback(&EplCbDefaultObdAccess);
    if (EplRet != kEplSuccessful)
    {
        Ret = ERROR;
        goto exit;
    }


    /* allocate memory for object table */
    if ((pObjTbl_l = CNAPI_MALLOC (sizeof(tObjTbl) * dwMaxLinks_p)) == NULL)
    {
        Ret = ERROR;
        goto exit;
    }

    dwMaxLinkEntries_l = dwMaxLinks_p;
    CnApi_resetLinkCounter();

exit:
    return Ret;
}

/**
********************************************************************************
\brief    cleanup objects module
*******************************************************************************/
void CnApi_cleanupObjects(void)
{
    CNAPI_FREE (pObjTbl_l);
}

/**
********************************************************************************
\brief  reset the counter of CnApi_linkObject() commands
*******************************************************************************/
static void CnApi_resetLinkCounter(void)
{
    dwNumVarLinks_l = 0;
}

/**
********************************************************************************
\brief    add object

CnApi_linkObject() indirectly connects local variables to object numbers by
writing the linking information into a table. When the PDO mapping information
is received, a copy table will be set up which defines the connection from a
PDO buffer to the local user variable.
The data type of linked local variable must match with data type of POWERLINK
object ! Number of linked objects must match NUM_OBJECTS !
Application Example:   CnApi_linkObject(0x6000, 1, 1, &digitalIn[0]);

\param      wIndex_p            index of object in the object dictionary
\param      bSubIndex_p         subindex of object in the object dictionary
\param      wSize_p             data size of linked object
\param      pAdrs_p             pointer to object data


\return     tCnApiStatus
\retval     kCnApiStatusOk                    on success
\retval     kCnApiStatusObjectLinkFailed      when the linking of the object has
                                              failed

*******************************************************************************/
tCnApiStatus CnApi_linkObject(WORD wIndex_p, BYTE bSubIndex_p, WORD wSize_p, BYTE * pAdrs_p)
{
    tCnApiStatus Ret = kCnApiStatusOk;
    tObjTbl        *pTbl;

    pTbl = pObjTbl_l + dwNumVarLinks_l;

    if (dwNumVarLinks_l < dwMaxLinkEntries_l)
    {
        pTbl->m_wIndex = wIndex_p;
        pTbl->m_bSubIndex = bSubIndex_p;
        pTbl->m_wSize = wSize_p;
        pTbl->m_pData = pAdrs_p;
        dwNumVarLinks_l ++;
        goto Exit;
    }
    else
    {
        DEBUG_TRACE2(DEBUG_LVL_CNAPI_ERR, "\nERROR:"
        " Too many Object-Links! Failed at %lu th usage of %s()!\n"
        "Please adapt NUM_OBJECTS!\n\n", dwNumVarLinks_l + 1, __func__);
        Ret = kCnApiStatusObjectLinkFailed;
    }

Exit:
    return Ret;
}

/**
********************************************************************************
\brief    setup actually mapped objects
\param wIndex_p     requested index
\param bSubIndex_p  requested subindex
\param wSize_p      OUT: size of object
\param pAdrs_p      OUT: pointer to object

\return BOOL
\retval TRUE        when object is found
\retval FALSE       if not found

The function CnApi_getObjectParam() compares the local linking table and the
descriptor table. If the object entry is found, the data pointer and
the respective size of the local object linking table will be returned.
So only currently mapped objects at PCP side will be considered in the copy table!
*******************************************************************************/
BOOL CnApi_getObjectParam(WORD wIndex_p, BYTE bSubIndex_p, WORD *wSize_p, BYTE **pAdrs_p)
{
    tObjTbl        *pTbl;
    int            i;

    for (i = 0; i < dwNumVarLinks_l; i++)
    {
        pTbl = pObjTbl_l + i;
        if ((pTbl->m_wIndex == wIndex_p) &&
            (pTbl->m_bSubIndex == bSubIndex_p))
        {
            /* indices match found so return data and size of this object */
            *pAdrs_p = pTbl->m_pData;
            *wSize_p = pTbl->m_wSize;
            return TRUE;
        }
    }

    return FALSE;
}

/**
********************************************************************************
\brief    reset the object selector
*******************************************************************************/
void CnApi_resetObjectSelector(void)
{
    dwSelectObj_l = 0;
}


/**
********************************************************************************
\brief    increment oject structure to next object, if it exists

\param  pObjId         the id of the object

\return int
*******************************************************************************/
int CnApi_getNextObject(tCnApiObjId *pObjId)
{
    tObjTbl        *pCurrentObj;

    if (dwSelectObj_l >= dwNumVarLinks_l)
        return 0;

    pCurrentObj = pObjTbl_l + dwSelectObj_l;

    pObjId->m_wIndex = pCurrentObj->m_wIndex;
    pObjId->m_bSubIndex = pCurrentObj->m_bSubIndex;
    pObjId->m_bNumEntries = 1; //TODO: for now fixed to one (no arrays).

    dwSelectObj_l++;

    return 1;
}


/**
********************************************************************************
\brief    write an object

CnApi_writeObjects() writes a object in the openPOWERLINK stack. The object must
exist in the object dictionary and must already be created by
CnApi_createObjectLinks(). The object will be identified with its \p index and
\p subIndex. \p dataLen must contain the size of the object data. A pointer to
the object data must be provided in \p p_data.

The synchronization flag is used to determine if the write data should be
queued or immediately written to the PCP. If \p sync is TRUE all queued
write data will be written to the PCP.

\param        index                index of object in the object dictionary
\param        subIndex            sub-index of object in the object dictionary
\param        dataLen                length of object data
\param        p_data                pointer to object data
\param        sync                synchronization flag. If FALSE, write request
                                will be queued. If TRUE, write request will be
                                transfered to the PCP.

\return        int
*******************************************************************************/
int CnApi_writeObjects(WORD index, BYTE subIndex, WORD dataLen,
                       BYTE* p_data, BOOL sync)
{

    /* Add the object to the write queue */

    /* if synchronize flag was set we write the object queue to the DPRAM
     * and notify the PCP.
     */


    return 0;
}

/**
********************************************************************************
\brief    read an object

CnApi_readObjects() reads an object in the openPOWERLINK stack. The object must
exist in the object directory and must already be created by
CnApi_createObjectLinks().

\param        index                index of object in the object dictionary
\param        subIndex            sub-index of object in the object dictionary
\param        CN_readObjectCb        pointer to readObject callback function

\return        return
\retval        return_value        return_value_description
*******************************************************************************/
void CnApi_readObjects(WORD index, BYTE subIndex, int CN_readObjectCb)
{
    /* Add the object to the read queue */

    /* as soon as the object read is finished
     * the callback function shall be called.
     */

}

static tEplKernel EplCbDefaultObdAccess(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;
    tCnApiObdStatus CnApiObdRet = kCnApiObdStatusOk;
    tCnApiObdParam CnApiObdParam = { 0 };

    switch (pObdParam_p->m_ObdEvent)
    {
        case kCnApiObdEvInitWriteLe:
        case kCnApiObdEvPreRead:
        {
            if (pObdParam_p->m_pfnAccessFinished == NULL)
            {
                pObdParam_p->m_dwAbortCode = kCnApiSdoacDataNotTransfOrStored;
                Ret = kEplObdAccessViolation;
                goto exit;
            }
            break;
        }
        default:
        {
            break;
        }
    }

    // convert epl object parameters to cnapi object parameters
    CnApiObdParam.m_ObdEvent = pObdParam_p->m_ObdEvent;
    CnApiObdParam.m_uiIndex = pObdParam_p->m_uiIndex;
    CnApiObdParam.m_uiSubIndex = pObdParam_p->m_uiSubIndex;
    CnApiObdParam.m_AbortCode = (tCnApiSdoAbortCode)pObdParam_p->m_dwAbortCode;
    CnApiObdParam.m_pData = pObdParam_p->m_pData;
    CnApiObdParam.m_TransferSize = pObdParam_p->m_TransferSize;
    CnApiObdParam.m_ObjSize = pObdParam_p->m_ObjSize;
    CnApiObdParam.m_SegmentSize = pObdParam_p->m_SegmentSize;
    CnApiObdParam.m_SegmentOffset = pObdParam_p->m_SegmentOffset;


    // save pObdParam_p for epl finished callback
    CNAPI_MEMCPY(&EplObdParam_l, pObdParam_p, sizeof(tEplObdParam));

    // call user callback
    if(pfnDefaultObdAccess_l != NULL)
    {
        CnApiObdRet = pfnDefaultObdAccess_l(&CnApiObdParam);

        // convert cnapi return value to epl return value
        Ret = (tEplKernel)CnApiObdRet;
    }
    else
    {
        Ret = kEplInvalidOperation;
        goto exit;
    }
exit:
    return Ret;
}

/**
 ********************************************************************************
 \brief signals an OBD default access as finished
 \param pObdParam_p            the object access handle

 \return tCnApiStatus
 \retval kCnApiStatusOk                 on success
 \retval kCnApiStatusInvalidParameter   when pObdParam_p is invalid
 \retval kCnApiStatusError              when object access finished forwarding
                                        failed!

 This function has to be called after an OBD access has been finished to
 inform the caller about this event.
 *******************************************************************************/
tCnApiStatus CnApi_DefObdAccFinished(tCnApiObdParam * pObdParam_p)
{
    tCnApiStatus CnApiRet = kCnApiStatusOk;
    tEplKernel EplRet = kEplSuccessful;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "INFO: %s(%p) called\n", __func__, pObdParam_p);

    if (pObdParam_p->m_uiIndex == 0 )
    {
        CnApiRet = kCnApiStatusInvalidParameter;
        goto Exit;
    }

    if ((pObdParam_p->m_ObdEvent == kEplObdEvPreRead)            &&
        ((pObdParam_p->m_SegmentSize != pObdParam_p->m_ObjSize) ||
         (pObdParam_p->m_SegmentOffset != 0)                    )  )
    {
        //segmented read access not allowed!
        pObdParam_p->m_AbortCode = kCnApiSdoacUnsupportedAccess;
    }

    // only expedited reads are supported - check segment limit
    if ((pObdParam_p->m_ObdEvent == kEplObdEvPreRead)      &&
        (pObdParam_p->m_SegmentSize > SDO_SEGMENT_TX_LIMIT)   )
    {
        pObdParam_p->m_AbortCode = kCnApiSdoacDataTypeLengthTooHigh;
        CnApiRet = kCnApiStatusDataTooLong;
    }

    // convert cnapi object parameters to epl object parameters
    EplObdParam_l.m_ObdEvent = pObdParam_p->m_ObdEvent;
    EplObdParam_l.m_uiIndex = pObdParam_p->m_uiIndex;
    EplObdParam_l.m_uiSubIndex = pObdParam_p->m_uiSubIndex;
    EplObdParam_l.m_dwAbortCode = (DWORD)pObdParam_p->m_AbortCode;
    EplObdParam_l.m_pData = pObdParam_p->m_pData;
    EplObdParam_l.m_TransferSize = pObdParam_p->m_TransferSize;
    EplObdParam_l.m_ObjSize = pObdParam_p->m_ObjSize;
    EplObdParam_l.m_SegmentSize = pObdParam_p->m_SegmentSize;
    EplObdParam_l.m_SegmentOffset = pObdParam_p->m_SegmentOffset;

    // call callback function which was assigned by caller
    EplRet = EplObdParam_l.m_pfnAccessFinished(&EplObdParam_l);
    if (EplRet != kEplSuccessful)
    {   // convert error from epl to cnapi return
        CnApiRet = kCnApiStatusError;
    }

Exit:
    return CnApiRet;

}

/*******************************************************************************
*
* License Agreement
*
* Copyright � 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
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


