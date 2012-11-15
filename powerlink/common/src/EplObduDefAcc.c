/*******************************************************************************
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is          
* subject to the License Agreement located at the end of this file below.     
*/

/**
********************************************************************************

\file       EplObduDefAcc.c

\brief      Default object dictionary access module

\date       13.11.2012

This module is responsible for calls to non-existing objects in the
local object dictionary.

*******************************************************************************/
/* includes */
#include <Epl.h>
#include <EplObduDefAcc.h>
#include <EplObduDefAccHstry.h>
#include <EplSdo.h>
#ifdef EPL_MODULE_API_PDI
    #include <pcpPdi.h>
#endif // EPL_MODULE_API_PDI

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */
static void EplAppCbDefaultObdAssignDatatype(tEplObdParam * pObdParam_p);
static tEplKernel EplAppCbDefaultObdInitWriteLe(tEplObdParam * pObdParam_p);
static tEplKernel EplAppCbDefaultObdPreRead(tEplObdParam * pObdParam_p);
static tEplKernel EplAppDefObdAccCheckObjectCheckExist(tEplObdParam * pObdParam_p);
static tEplKernel EplAppDefObdAccCheckObjectWriteLe(tEplObdParam * pObdParam_p);
static tEplKernel EplAppDefObdAccCheckObjectPreRead(tEplObdParam * pObdParam_p);
static tEplKernel EplAppDefObdAccCheckObject(tEplObdParam * pObdParam_p);
static tEplKernel EplAppDefObdAccCheckOrigin(tEplObdParam * pObdParam_p);
static tEplKernel EplAppDefObdAccCheckTranferSegmentedCanBeStored(tEplObdParam * pObdParam_p);
/**
********************************************************************************
\brief  assign data type in a obd access handle

\param  pObdParam_p     Pointer to obd access handle
*******************************************************************************/
static void EplAppCbDefaultObdAssignDatatype(tEplObdParam * pObdParam_p)
{
    // assign data type

    // check object size and type
    switch (pObdParam_p->m_uiIndex)
    {
//        case 0x1010:
//        case 0x1011:
//            pObdParam_p->m_Type = kEplObdTypUInt32;
//            pObdParam_p->m_ObjSize = 4;
//            break;

        case 0x1F50:
            pObdParam_p->m_Type = kEplObdTypDomain;
            //TODO Debug: check maximum segment offset
            break;

        default:
            if(pObdParam_p->m_uiIndex >= 0x2000)
            {  // all application specific objects will be verified at AP side
                break;
            }

            break;
    } /* switch (pObdParam_p->m_uiIndex) */
}

/**
********************************************************************************
\brief  writes data to an OBD entry from a source with little endian byteorder

\param  pObdParam_p     pointer to object handle

\return kEplObdAccessAdopted or error code
*******************************************************************************/
static tEplKernel EplAppCbDefaultObdInitWriteLe(tEplObdParam * pObdParam_p)
{
    tEplKernel       Ret = kEplSuccessful;
    tObdAccHstryEntry *  pDefObdHdl = NULL;

    // do not return kEplSuccessful in this case,
    // only error or kEplObdAccessAdopted is allowed! //TODO: Why?

    // Note SDO: Only a "history segment block" can be delayed, but not single segments!
    //           Client will send Ack Request after sending a history block, so we don't need to
    //           send an Ack immediately after first received frame.

    Ret = EplAppDefObdAccCheckOrigin(pObdParam_p);
    if (Ret != kEplSuccessful)
    {
        if (Ret == kEplReject)
        {
            // all internal originators (other than SDO)
            // workaround: do not forward error because EplApiLinkObject() causes kEplReject
            Ret = kEplSuccessful;

            /* TODO Debug: if we exit here we return successful which shouldn't be according to
               comment at beginning of function. Anyhow, this does not harm here.
               Check if kEplReject can be returned directly. */
        }
        goto Exit;
    }

    Ret = EplAppDefObdAccCheckObject(pObdParam_p);
    if (Ret != kEplSuccessful)
    {
        if (Ret == kEplReject)
        {
            Ret = kEplSuccessful;
        }
        goto Exit;
    }

    // handle non-adopted access here if applicable

    // adopt OBD access
    // Note: Non-adopted object access should not reach here

    Ret = EplAppDefObdAccCheckTranferSegmentedCanBeStored(pObdParam_p);
#ifdef EPL_MODULE_API_PDI
    // all object which reach here and are not blocked in advance
    // will be forwarded to PDI
    if (Ret == kEplInvalidParam)
    {   // expedited object access - directly forward to PDI

        Ret = EplAppDefObdAccAdoptedHstryInitSequence();
        if (Ret != kEplSuccessful)
        {
            pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
            goto Exit;
        }

        Ret = EplAppDefObdAccAdoptedHstrySaveHdl(pObdParam_p, &pDefObdHdl);
        if (Ret != kEplSuccessful)
        {
            goto Exit;
        }

        Ret = Gi_forwardObdAccHstryEntryToPdi(pDefObdHdl);
        if (Ret != kEplSuccessful)
        {
            goto Exit;
        }

    }
#endif // EPL_MODULE_API_PDI
    if (Ret == kEplSuccessful)
    {   // segmented object access - needs to be buffered

        Ret = EplAppDefObdAccAdoptedHstrySaveHdl(pObdParam_p, &pDefObdHdl);
        if (Ret != kEplSuccessful)
        {
            goto Exit;
        }

        // trigger write operation (in AppEventCb)
        Ret = EplApiPostUserEvent((void*) pDefObdHdl);
        if (Ret != kEplSuccessful)
        {
            goto Exit;
        }
    }
    else
    {   // error
        goto Exit;
    }

    // adopt write access
    Ret = kEplObdAccessAdopted;
    DEBUG_TRACE0(DEBUG_LVL_14, " Adopted\n");

Exit:
    if ((Ret != kEplObdAccessAdopted) &&
        (pDefObdHdl != NULL)            )
    {
        // OBD handle was saved -> delete it
        EplAppDefObdAccAdoptedHstryDeleteEntry(pDefObdHdl);
    }

    return Ret;
}

/**
********************************************************************************
\brief  pre-read checking for default object callback function

\param      pObdParam_p     pointer to object handle

\return     kEplObdAccessAdopted or kEplObdSegmentReturned
*******************************************************************************/
static tEplKernel EplAppCbDefaultObdPreRead(tEplObdParam * pObdParam_p)
{
    tEplKernel       Ret = kEplSuccessful;
    tObdAccHstryEntry *  pDefObdHdl = NULL;

    // do not return kEplSuccessful in this case,
    // only error or kEplObdAccessAdopted or kEplObdSegmentReturned is allowed! //TODO: Why?

    // Note: kEplObdAccessAdopted can only be returned for expedited (non-fragmented) reads!
    // Adopted access is not yet implemented for segmented kEplObdEvPreRead.
    // Thus, kEplObdSegmentReturned has to be returned in this case! This requires immediate access to
    // the read source data right from this function.

    Ret = EplAppDefObdAccCheckOrigin(pObdParam_p);
    if (Ret != kEplSuccessful)
    {
        if (Ret == kEplReject)
        {
            // all internal originators (other than SDO)
            // workaround: do not forward error because EplApiLinkObject() causes kEplReject
            Ret = kEplSuccessful;

            /* TODO Debug: if we exit here we return successful which shouldn't be according to
               comment at beginning of function. Anyhow, this does not harm here.
               Check if kEplReject can be returned directly. */
        }
        goto Exit;
    }

    Ret = EplAppDefObdAccCheckObject(pObdParam_p);
    if (Ret != kEplSuccessful)
    {
        if (Ret == kEplReject)
        {
            Ret = kEplSuccessful;
        }
        goto Exit;
    }

    // handle non-adopted access here if applicable

    // adopt OBD access
    // Note: Non-adopted object access should not reach here

#ifdef EPL_MODULE_API_PDI
    // all object which reach here and are not blocked in advance
    // will be forwarded to PDI
    Ret = EplAppDefObdAccAdoptedHstryInitSequence();
    if (Ret != kEplSuccessful)
    {
        pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
        goto Exit;
    }

    Ret = EplAppDefObdAccAdoptedHstrySaveHdl(pObdParam_p, &pDefObdHdl);
    if (Ret != kEplSuccessful)
    {
        goto Exit;
    }

    Ret = Gi_forwardObdAccHstryEntryToPdi(pDefObdHdl);
    if (Ret != kEplSuccessful)
    {
        goto Exit;
    }
#else
    // TODO: implement some mechanism to process adopted read for single processor design
    Ret = kEplApiInvalidParam; // OBD access should be blocked before and therefore not reach here
    goto Exit;
#endif // EPL_MODULE_API_PDI

    // adopt read access
    Ret = kEplObdAccessAdopted;
    DEBUG_TRACE0(DEBUG_LVL_14, "  Adopted\n");

Exit:
    if ((Ret != kEplObdAccessAdopted) &&
        (pDefObdHdl != NULL)            )
    {
        // OBD handle was saved -> delete it
        EplAppDefObdAccAdoptedHstryDeleteEntry(pDefObdHdl);
    }

    return Ret;
}

/**
********************************************************************************
\brief  check if 'kEplObdEvCheckExist' object access should be processed further

 This function is sub-function of EplAppDefObdAccCheckObject.
 It can only be called when pObdParam_p->m_ObdEvent equals kEplObdEvCheckExist,
 otherwise it has an invalid result.

\param  pObdParam_p     pointer to object handle

\retval kEplSuccessful    continue processing
\retval kEplReject        stop processing this object further and exit
                          (tell caller object exists)
\retval kEplObdIndexNotExist    object index does not exist
\retval kEplObdSubindexNotExist object subindex does not exist
\retval kEplInvalidParam        wrong usage of this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccCheckObjectCheckExist(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;

    // kEplObdEvCheckExist is called in advance of a write or read access

    // return error for all non existing objects
    switch (pObdParam_p->m_uiIndex)
    {

//        case 0x1010:
//            switch (pObdParam_p->m_uiSubIndex)
//            {
//                case 0x01:
//                    break;
//                default:
//                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_SUB_INDEX_NOT_EXIST;
//                    Ret = kEplObdSubindexNotExist;
//                    goto Exit;
//            }
//            break;

//        case 0x1011:
//            switch (pObdParam_p->m_uiSubIndex)
//            {
//                case 0x01:
//                    break;
//
//                default:
//                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_SUB_INDEX_NOT_EXIST;
//                    Ret = kEplObdSubindexNotExist;
//                    goto Exit;
//            }
//            break;

        case 0x1F50:
            switch (pObdParam_p->m_uiSubIndex)
            {
                case 0x01:
                    break;
                default:
                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_SUB_INDEX_NOT_EXIST;
                    Ret = kEplObdSubindexNotExist;
                    goto Exit;
            }
            break;

#ifdef CONFIG_USE_SDC_OBJECTS
        case 0x5020:
            switch (pObdParam_p->m_uiSubIndex)
            {
                // those SDC objects exist locally
                case 0x00:
                case 0x02:
                    // exit immediately and do not adopt the OBD access
                    return Ret;
                default:
                    break;
            }
            // do not break here, because default case should forward all
            // remaining sub-indices

#endif // CONFIG_USE_SDC_OBJECTS

        default:
        {
#ifdef EPL_MODULE_API_PDI
            // Tell calling function that all objects
            // >= 0x2000 exist per default.
            // The actual verification will take place
            // with the write or read access.
            if(pObdParam_p->m_uiIndex >= 0x2000)
            {
                break;
            }
#endif // EPL_MODULE_API_PDI

            // remaining PCP objects do not exist
            pObdParam_p->m_dwAbortCode = EPL_SDOAC_OBJECT_NOT_EXIST;
            Ret = kEplObdIndexNotExist;
            goto Exit;

            break;
        }
    } /* switch (pObdParam_p->m_uiIndex) */


Exit:
    return Ret;
}

/**
********************************************************************************
\brief  check if 'kEplObdEvInitWriteLe' object access should be processed further

 This function is sub-function of EplAppDefObdAccCheckObject.
 It can only be called when pObdParam_p->m_ObdEvent equals kEplObdEvInitWriteLe,
 otherwise it has an invalid result.

\param  pObdParam_p     pointer to object handle

\retval kEplSuccessful    continue processing
\retval kEplReject        stop processing this object further and exit
                          (tell caller object exists)
\retval kEplObdIndexNotExist    object index does not exist
\retval kEplObdSubindexNotExist object subindex does not exist
\retval kEplInvalidParam        wrong usage of this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccCheckObjectWriteLe(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;

    // return error for all non existing objects
    switch (pObdParam_p->m_uiIndex)
    {
        default:
            break;
    }

    return Ret;
}

/**
********************************************************************************
\brief  check if 'kEplObdEvPreRead' object access should be processed further

 This function is sub-function of EplAppDefObdAccCheckObject.
 It can only be called when pObdParam_p->m_ObdEvent equals kEplObdEvPreRead,
 otherwise it has an invalid result.

\param  pObdParam_p     pointer to object handle

\retval kEplSuccessful    continue processing
\retval kEplReject        stop processing this object further and exit
                          (tell caller object exists)
\retval kEplObdIndexNotExist    object index does not exist
\retval kEplObdSubindexNotExist object subindex does not exist
\retval kEplInvalidParam        wrong usage of this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccCheckObjectPreRead(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;

    switch (pObdParam_p->m_uiIndex)
    {
        case 0x1F50:
        {   // signal 'stop further processing'
            Ret = kEplReject;
            break;
        }

        default:
            break;
    }

    return Ret;
}

/**
********************************************************************************
\brief  check if object should be processed further

\param  pObdParam_p     pointer to object handle

\retval kEplSuccessful    continue processing
\retval kEplReject        stop processing this object further and exit
                          (tell caller object exists)
\retval kEplObdIndexNotExist    object index does not exist
\retval kEplObdSubindexNotExist object subindex does not exist
\retval kEplInvalidParam        wrong usage of this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccCheckObject(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;

    switch (pObdParam_p->m_ObdEvent)
    {
        case kEplObdEvCheckExist:
        {
            Ret = EplAppDefObdAccCheckObjectCheckExist(pObdParam_p);
            break;
        }
        case kEplObdEvInitWriteLe:
        {
            Ret = EplAppDefObdAccCheckObjectWriteLe(pObdParam_p);
            break;
        }
        case kEplObdEvPreRead:
        {
            Ret = EplAppDefObdAccCheckObjectPreRead(pObdParam_p);
            break;
        }
        case kEplObdEvPostRead:
        {
            // This event happens only if default OBD access is
            // called when accessing a mapping object and validates
            // the to be linked application objects.
            // -> If objects exist will be decided later,
            //    therefore return successful.
            break;
        }

        default:
        {
            Ret = kEplInvalidParam;
            break;
        }
    } // end of switch (pObdParam_p->m_ObdEvent)

    return Ret;
}

/**
********************************************************************************
\brief  check caller and validate its parameters

\param  pObdParam_p     pointer to object handle

\retval kEplSuccessful          valid parameters
\retval kEplObdAccessViolation  invalid parameters from remote originator
\retval kEplObdWriteViolation   remote write access to read only object
\retval kEplReject              originator is internal
*******************************************************************************/
static tEplKernel EplAppDefObdAccCheckOrigin(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;

    // if it is a remote write access (via SDO)
    // to a read only object -> refuse access
    if ((pObdParam_p->m_pRemoteAddress != NULL)           &&
        (pObdParam_p->m_ObdEvent == kEplObdEvInitWriteLe) &&
        (pObdParam_p->m_Access == kEplObdAccR)              )
    {
        Ret = kEplObdWriteViolation;
        pObdParam_p->m_dwAbortCode = EPL_SDOAC_WRITE_TO_READ_ONLY_OBJ;
        goto Exit;
    }

    if (pObdParam_p->m_pRemoteAddress != NULL)
    {   // remote access via SDO

        if (pObdParam_p->m_pfnAccessFinished == NULL)
        {
            // verify if caller has assigned a callback function
            pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
            Ret = kEplObdAccessViolation;
            goto Exit;
        }
    }
    else
    {   // ignore all internal originators than SDO
        Ret = kEplReject;
        goto Exit;
    }

Exit:
    return Ret;
}

/**
********************************************************************************
\brief  check if segmented access can be stored

\param  pObdParam_p         OBD access parameter with segmentation

\retval kEplSuccessful      object access can be stored
\retval kEplObdOutOfMemory  object access can not be stored
\retval kEplInvalidParam    object access has no segmentation
*******************************************************************************/
static tEplKernel EplAppDefObdAccCheckTranferSegmentedCanBeStored(tEplObdParam * pObdParam_p)
{
    tEplKernel       Ret = kEplSuccessful;

   if(EplAppDefObdAccCeckTranferIsSegmented(pObdParam_p) != FALSE)
   {
       // if it is an initial segment, check if this object is already accessed
       if (pObdParam_p->m_SegmentOffset == 0)
       {   // inital segment

           Ret = EplAppDefObdAccAdoptedHstryInitSequence();
           if (Ret != kEplSuccessful)
           {
               pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
               goto Exit;
           }
       }
       else
       {
           // block non-initial segments if initial segment processing
           // has not started yet (or processing was aborted)
           if (!EplAppDefObdAccAdoptedHstryCeckSequenceStarted())
           {
               Ret = kEplObdOutOfMemory;
               pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
               goto Exit;
           }
       }
   }
   else
   {   // fixed data size object, access is allowed
       // but this function checks only variable size objects
       Ret = kEplInvalidParam;
       goto Exit;
   }

Exit:
    return Ret;
}

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief called if object index does not exits in OBD

This default OBD access callback function shall be invoked if an index is not
present in the local OBD. If a subindex is not present, this function shall not
be called. If the access to the desired object can not be handled immediately,
kEplObdAccessAdopted has to be returned.

\param pObdParam_p   OBD access structure

\return    tEplKernel value
*******************************************************************************/
tEplKernel  EplAppCbDefaultObdAccess(tEplObdCbParam MEM* pObdParam_p)
{
    tEplKernel       Ret = kEplSuccessful;

    if (pObdParam_p == NULL)
    {
        return kEplInvalidParam;
    }

    Ret = EplAppDefObdAccCheckObject(pObdParam_p);
    if (Ret != kEplSuccessful)
    {
        if (Ret == kEplReject)
        {
            Ret = kEplSuccessful;
        }
        goto Exit;
    }

    DEBUG_TRACE4(DEBUG_LVL_14, "EplAppCbDefaultObdAccess(0x%04X/%u Ev=%X Size=%u\n",
            pObdParam_p->m_uiIndex, pObdParam_p->m_uiSubIndex,
            pObdParam_p->m_ObdEvent,
            pObdParam_p->m_SegmentSize);

//    printf("EplAppCbDefaultObdAccess(0x%04X/%u Ev=%X pData=%p Off=%u Size=%u"
//           " ObjSize=%u TransSize=%u Acc=%X Typ=%X)\n",
//        pObdParam_p->m_uiIndex, pObdParam_p->m_uiSubIndex,
//        pObdParam_p->m_ObdEvent,
//        pObdParam_p->m_pData, pObdParam_p->m_SegmentOffset, pObdParam_p->m_SegmentSize,
//        pObdParam_p->m_ObjSize, pObdParam_p->m_TransferSize, pObdParam_p->m_Access, pObdParam_p->m_Type);

    switch (pObdParam_p->m_ObdEvent)
    {
        case kEplObdEvCheckExist:
            EplAppCbDefaultObdAssignDatatype(pObdParam_p);
            break;

        case kEplObdEvInitWriteLe:
            Ret = EplAppCbDefaultObdInitWriteLe(pObdParam_p);
            break;

        case kEplObdEvPreRead:
            Ret = EplAppCbDefaultObdPreRead(pObdParam_p);
            break;

        default:
            break;
    }

Exit:
    return Ret;
}

/**
********************************************************************************
\brief  check if it is a segmented transfer

\param  ObdType_p   OBD access parameter

\retval TRUE        segmented transfer
\retval FALSE       expedited transfer
*******************************************************************************/
BOOL EplAppDefObdAccCeckTranferIsSegmented(tEplObdParam * pObdParam_p)
{
    if ((pObdParam_p->m_pRemoteAddress->m_le_pSdoCmdFrame->m_le_bFlags & 0x30) == 0x10)
    {   // SDO frame indicates segmented transfer
        // TODO: this is a not a nice solution -> rework of SDO Cmd layer necessary
        return TRUE;
    }
    else
    {
        return FALSE;
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
