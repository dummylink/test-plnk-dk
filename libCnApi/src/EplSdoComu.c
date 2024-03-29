/****************************************************************************

  (c) SYSTEC electronic GmbH, D-07973 Greiz, August-Bebel-Str. 29
      www.systec-electronic.com

  Project:      openPOWERLINK

  Description:  source file for SDO Command Layer module

  License:

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.

    3. Neither the name of SYSTEC electronic GmbH nor the names of its
       contributors may be used to endorse or promote products derived
       from this software without prior written permission. For written
       permission, please contact info@systec-electronic.com.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.

    Severability Clause:

        If a provision of this License is or becomes illegal, invalid or
        unenforceable in any jurisdiction, that shall not affect:
        1. the validity or enforceability in that jurisdiction of any other
           provision of this License; or
        2. the validity or enforceability in other jurisdictions of that or
           any other provision of this License.

  -------------------------------------------------------------------------

                $RCSfile$

                $Author$

                $Revision$  $Date$

                $State$

                Build Environment:
                    GCC V3.4

  -------------------------------------------------------------------------

  Revision History:

  2006/06/26 k.t.:   start of the implementation

****************************************************************************/
#include "cnApiGlobal.h"
#include "cnApiDebug.h"
#include "EplErrDef.h"
#include "user/EplSdoComu.h"

#if ((((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) == 0) &&\
     (((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) == 0)   )

    #error 'ERROR: At least SDO Server or SDO Client should be activate!'

#endif

#if (((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) != 0)
    #if (((EPL_MODULE_INTEGRATION) & (EPL_MODULE_OBDU)) == 0) && (EPL_OBD_USE_KERNEL == FALSE)

    #error 'ERROR: SDO Server needs OBDu module!'

    #endif

#endif

#ifdef EPL_MODULE_API_PDI
//#include "cnApiAsync.h"
#endif

//---------------------------------------------------------------------------
// module global vars
//---------------------------------------------------------------------------
static tEplSdoComInstance SdoComInstance_g;
//---------------------------------------------------------------------------
// local function prototypes
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoComReceiveCb (tEplSdoSeqConHdl    SdoSeqConHdl_p,
                                    tEplAsySdoCom*      pAsySdoCom_p,
                                    unsigned int        uiDataSize_p);


tEplKernel PUBLIC EplSdoComConCb (tEplSdoSeqConHdl    SdoSeqConHdl_p,
                                    tEplAsySdoConState  AsySdoConState_p);

static tEplKernel EplSdoComSearchConIntern(tEplSdoSeqConHdl    SdoSeqConHdl_p,
                                         tEplSdoComConEvent SdoComConEvent_p,
                                         tEplAsySdoCom*     pAsySdoCom_p);

#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) != 0)
static tEplKernel EplSdoComServerInitReadByIndex(tEplSdoComCon*     pSdoComCon_p,
                                         tEplAsySdoCom*     pAsySdoCom_p);

static tEplKernel EplSdoComServerInitWriteByIndex(tEplSdoComCon*     pSdoComCon_p,
                                         tEplAsySdoCom*     pAsySdoCom_p);

static tEplKernel EplSdoComServerSendFrameIntern(tEplSdoComCon*     pSdoComCon_p,
                                           unsigned int       uiIndex_p,
                                           unsigned int       uiSubIndex_p,
                                           tEplSdoComSendType SendType_p);

static tEplKernel EplSdoComServerCbExpeditedWriteFinished(tEplObdParam* pObdParam_p);
#endif

#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)

static tEplKernel EplSdoComClientSend(tEplSdoComCon* pSdoComCon_p);

static tEplKernel EplSdoComClientProcessFrame(tEplSdoComConHdl   SdoComCon_p,
                                              tEplAsySdoCom*     pAsySdoCom_p);

static tEplKernel EplSdoComClientSendAbort(tEplSdoComCon* pSdoComCon_p,
                                           DWORD          dwAbortCode_p);

static tEplKernel EplSdoComTransferFinished(tEplSdoComConHdl   SdoComCon_p,
                                            tEplSdoComCon*     pSdoComCon_p,
                                            tEplSdoComConState SdoComConState_p);
#endif



/***************************************************************************/
/*                                                                         */
/*                                                                         */
/*          C L A S S  <SDO Command Layer>                                 */
/*                                                                         */
/*                                                                         */
/***************************************************************************/
//
// Description: SDO Command layer Modul
//
//
/***************************************************************************/

//=========================================================================//
//                                                                         //
//          P U B L I C   F U N C T I O N S                                //
//                                                                         //
//=========================================================================//

//---------------------------------------------------------------------------
//
// Function:    EplSdoComInit
//
// Description: Init first instance of the module
//
//
//
// Parameters:
//
//
// Returns:     tEplKernel  = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoComInit(void)
{
tEplKernel  Ret;


    Ret = EplSdoComAddInstance();

return Ret;

}

//---------------------------------------------------------------------------
//
// Function:    EplSdoComAddInstance
//
// Description: Init additional instance of the module
//
//
//
// Parameters:
//
//
// Returns:     tEplKernel  = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoComAddInstance(void)
{
tEplKernel Ret;

    Ret = kEplSuccessful;

    // init controll structure
    EPL_MEMSET(&SdoComInstance_g, 0x00, sizeof(SdoComInstance_g));

    // init instance of lower layer
    Ret = EplSdoAsySeqAddInstance(EplSdoComReceiveCb, EplSdoComConCb);
    if(Ret != kEplSuccessful)
    {
        goto Exit;
    }

#if defined(WIN32) || defined(_WIN32)
    // create critical section for process function
    SdoComInstance_g.m_pCriticalSection = &SdoComInstance_g.m_CriticalSection;
    InitializeCriticalSection(SdoComInstance_g.m_pCriticalSection);
#endif

Exit:
    return Ret;
}

//---------------------------------------------------------------------------
//
// Function:    EplSdoComDelInstance
//
// Description: delete instance of the module
//
//
//
// Parameters:
//
//
// Returns:     tEplKernel  = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoComDelInstance(void)
{
tEplKernel  Ret;

    Ret = kEplSuccessful;


#if defined(WIN32) || defined(_WIN32)
    // delete critical section for process function
    DeleteCriticalSection(SdoComInstance_g.m_pCriticalSection);
#endif

    Ret = EplSdoAsySeqDelInstance();
    if(Ret != kEplSuccessful)
    {
        goto Exit;
    }


Exit:
    return Ret;
}

//---------------------------------------------------------------------------
//
// Function:    EplSdoComDefineCon
//
// Description: function defines a SDO connection to another node
//              -> init lower layer and returns a handle for the connection.
//              Two client connections to the same node via the same protocol
//              are not allowed. If this function detects such a situation
//              it will return kEplSdoComHandleExists and the handle of
//              the existing connection in pSdoComConHdl_p.
//              Using of existing server connections is possible.
//
// Parameters:  pSdoComConHdl_p     = IN: pointer to the buffer of the handle OUT: number of handle
//              uiTargetNodeId_p    = NodeId of the targetnode
//              ProtType_p          = type of protocol to use for connection
//
//
// Returns:     tEplKernel  = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
tEplKernel PUBLIC EplSdoComDefineCon(tEplSdoComConHdl*  pSdoComConHdl_p,
                                      unsigned int      uiTargetNodeId_p,
                                      tEplSdoType       ProtType_p)
{
tEplKernel      Ret;
unsigned int    uiCount;
unsigned int    uiFreeHdl;
tEplSdoComCon*  pSdoComCon;

    // check Parameter
    ASSERT(pSdoComConHdl_p != NULL);

    // check NodeId
    if((uiTargetNodeId_p == EPL_C_ADR_INVALID)
        ||(uiTargetNodeId_p >= EPL_C_ADR_BROADCAST))
    {
        Ret = kEplInvalidNodeId;

    }

    // search free control structure
    pSdoComCon = &SdoComInstance_g.m_SdoComCon[0];
    uiCount = 0;
    uiFreeHdl = EPL_MAX_SDO_COM_CON;
    while (uiCount < EPL_MAX_SDO_COM_CON)
    {
        if (pSdoComCon->m_SdoSeqConHdl == 0)
        {   // free entry
            uiFreeHdl = uiCount;
        }
        else if ((pSdoComCon->m_uiNodeId == uiTargetNodeId_p)
            && (pSdoComCon->m_SdoProtType == ProtType_p))
        {   // existing client connection with same node ID and same protocol type
            *pSdoComConHdl_p = uiCount;
            Ret = kEplSdoComHandleExists;
            goto Exit;
        }
        uiCount++;
        pSdoComCon++;
    }

    if (uiFreeHdl == EPL_MAX_SDO_COM_CON)
    {
        Ret = kEplSdoComNoFreeHandle;
        goto Exit;
    }

    pSdoComCon = &SdoComInstance_g.m_SdoComCon[uiFreeHdl];
    // save handle for application
    *pSdoComConHdl_p = uiFreeHdl;
    // save parameters
    pSdoComCon->m_SdoProtType = ProtType_p;
    pSdoComCon->m_uiNodeId = uiTargetNodeId_p;

    // set Transaction Id
    pSdoComCon->m_bTransactionId = 0;

    // check protocol
    switch(ProtType_p)
    {
        // udp
        case kEplSdoTypeUdp:
        {
            // call connection int function of lower layer
            Ret = EplSdoAsySeqInitCon(&pSdoComCon->m_SdoSeqConHdl,
                          pSdoComCon->m_uiNodeId,
                          kEplSdoTypeUdp);
            if(Ret != kEplSuccessful)
            {
                goto Exit;
            }
            break;
        }

        // Asend
        case kEplSdoTypeAsnd:
        {
            // call connection int function of lower layer
            Ret = EplSdoAsySeqInitCon(&pSdoComCon->m_SdoSeqConHdl,
                          pSdoComCon->m_uiNodeId,
                          kEplSdoTypeAsnd);
            if(Ret != kEplSuccessful)
            {
                goto Exit;
            }
            break;
        }

#ifdef EPL_MODULE_API_PDI
        case kEplSdoTypeApiPdi:
        {
            break;
        }
#endif // EPL_MODULE_API_PDI

        // Pdo -> not supported
        case kEplSdoTypePdo:
        default:
        {
            Ret = kEplSdoComUnsupportedProt;
            goto Exit;
        }
    }// end of switch(m_ProtType_p)

    // call process function
    Ret = EplSdoComProcessIntern(uiFreeHdl,
                                    kEplSdoComConEventInitCon,
                                    NULL);

Exit:
    return Ret;
}
#endif
//---------------------------------------------------------------------------
//
// Function:    EplSdoComInitTransferByIndex
//
// Description: function init SDO Transfer for a defined connection
//
//
//
// Parameters:  SdoComTransParam_p    = Structure with parameters for connection
//
//
// Returns:     tEplKernel  = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
tEplKernel PUBLIC EplSdoComInitTransferByIndex(tEplSdoComTransParamByIndex* pSdoComTransParam_p)
{
tEplKernel      Ret;
tEplSdoComCon*  pSdoComCon;

    // check parameter
    if ((pSdoComTransParam_p->m_uiSubindex >= 0xFF)
        || (pSdoComTransParam_p->m_uiIndex == 0)
        || (pSdoComTransParam_p->m_uiIndex > 0xFFFF)
        || (pSdoComTransParam_p->m_pData == NULL)
        || (pSdoComTransParam_p->m_uiDataSize == 0))
    {
        Ret = kEplSdoComInvalidParam;
        goto Exit;
    }

    if(pSdoComTransParam_p->m_SdoComConHdl >= EPL_MAX_SDO_COM_CON)
    {
        Ret = kEplSdoComInvalidHandle;
        goto Exit;
    }

    // get pointer to control structure of connection
    pSdoComCon = &SdoComInstance_g.m_SdoComCon[pSdoComTransParam_p->m_SdoComConHdl];

//dont check sequenc layer connection in case of PDI forwarding (only command layer is used)
#ifndef EPL_MODULE_API_PDI
    // check if handle ok
    if(pSdoComCon->m_SdoSeqConHdl == 0)
    {
        Ret = kEplSdoComInvalidHandle;
        goto Exit;
    }
#endif // EPL_MODULE_API_PDI

    // check if command layer is idle
    if ((pSdoComCon->m_uiTransferredByte + pSdoComCon->m_uiTransSize) > 0)
    {   // handle is not idle
        Ret = kEplSdoComHandleBusy;
        goto Exit;
    }

    // save parameter
    // callback function for end of transfer
    pSdoComCon->m_pfnTransferFinished = pSdoComTransParam_p->m_pfnSdoFinishedCb;
    pSdoComCon->m_pUserArg = pSdoComTransParam_p->m_pUserArg;

    // set type of SDO command
    if (pSdoComTransParam_p->m_SdoAccessType == kEplSdoAccessTypeRead)
    {
        pSdoComCon->m_SdoServiceType = kEplSdoServiceReadByIndex;
    }
    else
    {
        pSdoComCon->m_SdoServiceType = kEplSdoServiceWriteByIndex;

    }
    // save pointer to data
    pSdoComCon->m_pData = pSdoComTransParam_p->m_pData;
    // maximal bytes to transfer
    pSdoComCon->m_uiTransSize = pSdoComTransParam_p->m_uiDataSize;
    // bytes already transfered
    pSdoComCon->m_uiTransferredByte = 0;

    // reset parts of control structure
    pSdoComCon->m_dwLastAbortCode = 0;
    pSdoComCon->m_SdoTransType = kEplSdoTransAuto;
    // save timeout
    //pSdoComCon->m_uiTimeout = SdoComTransParam_p.m_uiTimeout;

    // save index and subindex
    pSdoComCon->m_uiTargetIndex = pSdoComTransParam_p->m_uiIndex;
    pSdoComCon->m_uiTargetSubIndex = pSdoComTransParam_p->m_uiSubindex;

    // call process function
#ifndef EPL_MODULE_API_PDI
    Ret = EplSdoComProcessIntern(pSdoComTransParam_p->m_SdoComConHdl,
                                    kEplSdoComConEventSendFirst,    // event to start transfer
                                    NULL);
#else
    // do not wait for lower layer connection, send command frame immediately
    Ret = EplSdoComProcessIntern(pSdoComTransParam_p->m_SdoComConHdl,
                                    kEplSdoComConEventConEstablished, // event to start transfer immediately
                                    NULL);
#endif //EPL_MODULE_API_PDI
Exit:
    return Ret;

}
#endif

//---------------------------------------------------------------------------
//
// Function:    EplSdoComUndefineCon
//
// Description: function undefine a SDO connection
//
//
//
// Parameters:  SdoComConHdl_p    = handle for the connection
//
//
// Returns:     tEplKernel  = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
tEplKernel PUBLIC EplSdoComUndefineCon(tEplSdoComConHdl  SdoComConHdl_p)
{
tEplKernel          Ret;
tEplSdoComCon*      pSdoComCon;

    Ret = kEplSuccessful;

    if(SdoComConHdl_p >= EPL_MAX_SDO_COM_CON)
    {
        Ret = kEplSdoComInvalidHandle;
        goto Exit;
    }

    // get pointer to control structure
    pSdoComCon = &SdoComInstance_g.m_SdoComCon[SdoComConHdl_p];

    // $$$ d.k. abort a running transfer before closing the sequence layer

    if(((pSdoComCon->m_SdoSeqConHdl & ~EPL_SDO_SEQ_HANDLE_MASK)  != EPL_SDO_SEQ_INVALID_HDL)
        && (pSdoComCon->m_SdoSeqConHdl != 0))
    {
        // close connection in lower layer
        switch(pSdoComCon->m_SdoProtType)
        {
            case kEplSdoTypeAsnd:
            case kEplSdoTypeUdp:
            {
                Ret = EplSdoAsySeqDelCon(pSdoComCon->m_SdoSeqConHdl);
                break;
            }

#ifdef EPL_MODULE_API_PDI
            case kEplSdoTypeApiPdi:
            {
                break;
            }
#endif // EPL_MODULE_API_PDI

            case kEplSdoTypePdo:
            case kEplSdoTypeAuto:
            default:
            {
                Ret = kEplSdoComUnsupportedProt;
                goto Exit;
            }

        }// end of switch(pSdoComCon->m_SdoProtType)
    }


    // clean controll structure
    EPL_MEMSET(pSdoComCon, 0x00, sizeof(tEplSdoComCon));
Exit:
    return Ret;
}
#endif
//---------------------------------------------------------------------------
//
// Function:    EplSdoComGetState
//
// Description: function returns the state fo the connection
//
//
//
// Parameters:  SdoComConHdl_p    = handle for the connection
//              pSdoComFinished_p = pointer to structur for sdo state
//
//
// Returns:     tEplKernel  = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
tEplKernel PUBLIC EplSdoComGetState(tEplSdoComConHdl    SdoComConHdl_p,
                                    tEplSdoComFinished* pSdoComFinished_p)
{
tEplKernel          Ret;
tEplSdoComCon*      pSdoComCon;

    Ret = kEplSuccessful;

    if(SdoComConHdl_p >= EPL_MAX_SDO_COM_CON)
    {
        Ret = kEplSdoComInvalidHandle;
        goto Exit;
    }

    // get pointer to control structure
    pSdoComCon = &SdoComInstance_g.m_SdoComCon[SdoComConHdl_p];

    // check if handle ok
    if(pSdoComCon->m_SdoSeqConHdl == 0)
    {
        Ret = kEplSdoComInvalidHandle;
        goto Exit;
    }

    pSdoComFinished_p->m_pUserArg = pSdoComCon->m_pUserArg;
    pSdoComFinished_p->m_uiNodeId = pSdoComCon->m_uiNodeId;
    pSdoComFinished_p->m_uiTargetIndex = pSdoComCon->m_uiTargetIndex;
    pSdoComFinished_p->m_uiTargetSubIndex = pSdoComCon->m_uiTargetSubIndex;
    pSdoComFinished_p->m_uiTransferredByte = pSdoComCon->m_uiTransferredByte;
    pSdoComFinished_p->m_dwAbortCode = pSdoComCon->m_dwLastAbortCode;
    pSdoComFinished_p->m_SdoComConHdl = SdoComConHdl_p;
    if (pSdoComCon->m_SdoServiceType == kEplSdoServiceWriteByIndex)
    {
        pSdoComFinished_p->m_SdoAccessType = kEplSdoAccessTypeWrite;
    }
    else
    {
        pSdoComFinished_p->m_SdoAccessType = kEplSdoAccessTypeRead;
    }

    if(pSdoComCon->m_dwLastAbortCode != 0)
    {   // sdo abort
        pSdoComFinished_p->m_SdoComConState = kEplSdoComTransferRxAborted;

        // delete abort code
        pSdoComCon->m_dwLastAbortCode = 0;

    }
    else if((pSdoComCon->m_SdoSeqConHdl & ~EPL_SDO_SEQ_HANDLE_MASK)== EPL_SDO_SEQ_INVALID_HDL)
    {   // check state
        pSdoComFinished_p->m_SdoComConState = kEplSdoComTransferLowerLayerAbort;
    }
    else if(pSdoComCon->m_SdoComState == kEplSdoComStateClientWaitInit)
    {
        // finished
        pSdoComFinished_p->m_SdoComConState = kEplSdoComTransferNotActive;
    }
    else if(pSdoComCon->m_uiTransSize == 0)
    {   // finished
        pSdoComFinished_p->m_SdoComConState = kEplSdoComTransferFinished;
    }

Exit:
    return Ret;

}
#endif


//---------------------------------------------------------------------------
//
// Function:    EplSdoComGetNodeId
//
// Description: returns the remote node-ID which corresponds to the specified handle
//
// Parameters:  SdoComConHdl_p    = handle for the connection
//
// Returns:     tEplKernel  = errorcode
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
unsigned int PUBLIC EplSdoComGetNodeId(tEplSdoComConHdl  SdoComConHdl_p)
{
unsigned int    uiNodeId = EPL_C_ADR_INVALID;
tEplSdoComCon*  pSdoComCon;

    if(SdoComConHdl_p >= EPL_MAX_SDO_COM_CON)
    {
        goto Exit;
    }

    // get pointer to control structure
    pSdoComCon = &SdoComInstance_g.m_SdoComCon[SdoComConHdl_p];

    // check if handle ok
    if(pSdoComCon->m_SdoSeqConHdl == 0)
    {
        goto Exit;
    }

    uiNodeId = pSdoComCon->m_uiNodeId;

Exit:
    return uiNodeId;
}
#endif

//---------------------------------------------------------------------------
//
// Function:    EplSdoComSdoAbort
//
// Description: function abort a sdo transfer
//
//
//
// Parameters:  SdoComConHdl_p    = handle for the connection
//              dwAbortCode_p     = abort code
//
//
// Returns:     tEplKernel  = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
tEplKernel PUBLIC EplSdoComSdoAbort(tEplSdoComConHdl SdoComConHdl_p,
                                    DWORD            dwAbortCode_p)
{
tEplKernel  Ret;
tEplSdoComCon*      pSdoComCon;


    if(SdoComConHdl_p >= EPL_MAX_SDO_COM_CON)
    {
        Ret = kEplSdoComInvalidHandle;
        goto Exit;
    }

    // get pointer to control structure of connection
    pSdoComCon = &SdoComInstance_g.m_SdoComCon[SdoComConHdl_p];

    // check if handle ok
    if(pSdoComCon->m_SdoSeqConHdl == 0)
    {
        Ret = kEplSdoComInvalidHandle;
        goto Exit;
    }

    // save pointer to abort code
    pSdoComCon->m_pData = (BYTE*)&dwAbortCode_p;

    Ret = EplSdoComProcessIntern(SdoComConHdl_p,
                                kEplSdoComConEventAbort,
                                (tEplAsySdoCom*)NULL);

Exit:
    return Ret;
}
#endif

//=========================================================================//
//                                                                         //
//          P R I V A T E   F U N C T I O N S                              //
//                                                                         //
//=========================================================================//

//---------------------------------------------------------------------------
//
// Function:        EplSdoComReceiveCb
//
// Description:     callback function for SDO Sequence Layer
//                  -> indicates new data
//
//
//
// Parameters:      SdoSeqConHdl_p = Handle for connection
//                  pAsySdoCom_p   = pointer to data
//                  uiDataSize_p   = size of data ($$$ not used yet, but it should)
//
//
// Returns:
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoComReceiveCb (tEplSdoSeqConHdl    SdoSeqConHdl_p,
                                    tEplAsySdoCom*      pAsySdoCom_p,
                                    unsigned int        uiDataSize_p)
{
tEplKernel       Ret;

//    UNUSED_PARAMETER(uiDataSize_p);

    // search connection internally
    Ret = EplSdoComSearchConIntern(SdoSeqConHdl_p,
                                   kEplSdoComConEventRec,
                                   pAsySdoCom_p);

    EPL_DBGLVL_SDO_TRACE3("EplSdoComReceiveCb SdoSeqConHdl: 0x%X, First Byte of pAsySdoCom_p: 0x%02X, uiDataSize_p: 0x%04X\n", SdoSeqConHdl_p, (WORD)pAsySdoCom_p->m_le_abCommandData[0], uiDataSize_p);

    return Ret;
}

//---------------------------------------------------------------------------
//
// Function:        EplSdoComConCb
//
// Description:     callback function called by SDO Sequence Layer to inform
//                  command layer about state change of connection
//
//
//
// Parameters:      SdoSeqConHdl_p      = Handle of the connection
//                  AsySdoConState_p    = Event of the connection
//
//
// Returns:         tEplKernel  = Errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoComConCb (tEplSdoSeqConHdl    SdoSeqConHdl_p,
                                    tEplAsySdoConState  AsySdoConState_p)
{
tEplKernel          Ret;
tEplSdoComConEvent  SdoComConEvent = kEplSdoComConEventSendFirst;

    Ret = kEplSuccessful;

    // check state
    switch(AsySdoConState_p)
    {
        case kAsySdoConStateConnected:
        {
            EPL_DBGLVL_SDO_TRACE0("Connection established\n");
            SdoComConEvent = kEplSdoComConEventConEstablished;
            // start transmission if needed
            break;
        }

        case kAsySdoConStateInitError:
        {
            EPL_DBGLVL_SDO_TRACE0("Error during initialisation\n");
            SdoComConEvent = kEplSdoComConEventInitError;
            // inform app about error and close sequence layer handle
            break;
        }

        case kAsySdoConStateConClosed:
        {
            EPL_DBGLVL_SDO_TRACE0("Connection closed\n");
            SdoComConEvent = kEplSdoComConEventConClosed;
            // close sequence layer handle
            break;
        }

        case kAsySdoConStateAckReceived:
        {
            EPL_DBGLVL_SDO_TRACE0("Acknowlage received\n");
            SdoComConEvent = kEplSdoComConEventAckReceived;
            // continue transmission
            break;
        }

        case kAsySdoConStateFrameSended:
        {
            EPL_DBGLVL_SDO_TRACE0("One Frame sent\n");
            SdoComConEvent = kEplSdoComConEventFrameSended;
            // to continue transmission
            break;

        }

        case kAsySdoConStateTimeout:
        {
            EPL_DBGLVL_SDO_TRACE0("Timeout\n");
            SdoComConEvent = kEplSdoComConEventTimeout;
            // close sequence layer handle
            break;

        }

        case kAsySdoConStateTransferAbort:
        {
            EPL_DBGLVL_SDO_TRACE0("Transfer aborted\n");
            SdoComConEvent = kEplSdoComConEventTransferAbort;
            // inform higher layer if necessary,
            // but do not close sequence layer handle
            break;
        }

    }// end of switch(AsySdoConState_p)

    Ret = EplSdoComSearchConIntern(SdoSeqConHdl_p,
                                   SdoComConEvent,
                                   (tEplAsySdoCom*)NULL);

    return Ret;
}

//---------------------------------------------------------------------------
//
// Function:        EplSdoComSearchConIntern
//
// Description:     search a Sdo Sequence Layer connection handle in the
//                  control structure of the Command Layer
//
// Parameters:      SdoSeqConHdl_p     = Handle to search
//                  SdoComConEvent_p = event to process
//                  pAsySdoCom_p     = pointer to received frame
//
// Returns:         tEplKernel
//
//
// State:
//
//---------------------------------------------------------------------------
static tEplKernel EplSdoComSearchConIntern(tEplSdoSeqConHdl    SdoSeqConHdl_p,
                                         tEplSdoComConEvent SdoComConEvent_p,
                                         tEplAsySdoCom*     pAsySdoCom_p)
{
tEplKernel          Ret;
tEplSdoComCon*      pSdoComCon;
tEplSdoComConHdl    HdlCount;
tEplSdoComConHdl    HdlFree;

    Ret = kEplSdoComNotResponsible;

    // get pointer to first element of the array
    pSdoComCon = &SdoComInstance_g.m_SdoComCon[0];
    HdlCount = 0;
    HdlFree = 0xFFFF;
    while (HdlCount < EPL_MAX_SDO_COM_CON)
    {
        if (pSdoComCon->m_SdoSeqConHdl == SdoSeqConHdl_p)
        {   // matching command layer handle found
            Ret = EplSdoComProcessIntern(HdlCount,
                                    SdoComConEvent_p,
                                    pAsySdoCom_p,
                                    0);
        }
        else if ((pSdoComCon->m_SdoSeqConHdl == 0)
            &&(HdlFree == 0xFFFF))
        {
            HdlFree = HdlCount;
        }

        pSdoComCon++;
        HdlCount++;
    }

    if (Ret == kEplSdoComNotResponsible)
    {   // no responsible command layer handle found
        if (HdlFree == 0xFFFF)
        {   // no free handle
            // delete connection immediately
            // 2008/04/14 m.u./d.k. This connection actually does not exist.
            //                      pSdoComCon is invalid.
            // Ret = EplSdoAsySeqDelCon(pSdoComCon->m_SdoSeqConHdl);
            Ret = kEplSdoComNoFreeHandle;
        }
        else
        {   // create new handle
            HdlCount = HdlFree;
            pSdoComCon = &SdoComInstance_g.m_SdoComCon[HdlCount];
            pSdoComCon->m_SdoSeqConHdl = SdoSeqConHdl_p;
            Ret = EplSdoComProcessIntern(HdlCount,
                                    SdoComConEvent_p,
                                    pAsySdoCom_p,
                                    0);
        }
    }

    return Ret;

}

//---------------------------------------------------------------------------
//
// Function:        EplSdoComProcessIntern
//
// Description:     search a Sdo Sequence Layer connection handle in the
//                  control structer of the Command Layer
//
//
//
// Parameters:      SdoComCon_p     = index of control structure of connection
//                  SdoComConEvent_p = event to process
//                  pAsySdoCom_p     = pointer to received frame
//
// Returns:         tEplKernel  =  errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoComProcessIntern(tEplSdoComConHdl   SdoComCon_p,
                                         tEplSdoComConEvent SdoComConEvent_p,
                                         tEplAsySdoCom*     pAsySdoCom_p,
                                         WORD wExtComConHdl_p)
{
tEplKernel          Ret;
tEplSdoComCon*      pSdoComCon;
BYTE                bFlag;

#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) != 0)
unsigned int        uiSize;
#endif

#if defined(WIN32) || defined(_WIN32)
    // enter  critical section for process function
    EnterCriticalSection(SdoComInstance_g.m_pCriticalSection);
    EPL_DBGLVL_SDO_TRACE0("\n\tEnterCiticalSection EplSdoComProcessIntern\n\n");
#endif

    Ret = kEplSuccessful;

    // get pointer to control structure
    pSdoComCon = &SdoComInstance_g.m_SdoComCon[SdoComCon_p];

    // assign external connection handle
    pSdoComCon->m_wExtComConHdl = wExtComConHdl_p;

    // process state maschine
    switch(pSdoComCon->m_SdoComState)
    {
        // idle state
        case kEplSdoComStateIdle:
        {
            // check events
            switch(SdoComConEvent_p)
            {
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
                // init con for client
                case kEplSdoComConEventInitCon:
                {

                    // call of the init function already
                    // processed in EplSdoComDefineCon()
                    // only change state to kEplSdoComStateClientWaitInit
                    pSdoComCon->m_SdoComState = kEplSdoComStateClientWaitInit;
                    break;
                }
#endif


                // int con for server
                case kEplSdoComConEventRec:
                {
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) != 0)
                    // check if init of an transfer and no SDO abort
                    if ((pAsySdoCom_p->m_le_bFlags & 0x80) == 0)
                    {   // SDO request
                        if ((pAsySdoCom_p->m_le_bFlags & 0x40) == 0)
                        {   // no SDO abort
                            // save tansaction id
                            pSdoComCon->m_bTransactionId = AmiGetByteFromLe(&pAsySdoCom_p->m_le_bTransactionId);
                            // check command
                            switch(pAsySdoCom_p->m_le_bCommandId)
                            {
                                case kEplSdoServiceNIL:
                                {   // simply acknowlegde NIL command on sequence layer

                                    Ret = EplSdoAsySeqSendData(pSdoComCon->m_SdoSeqConHdl,
                                                                            0,
                                                                            (tEplFrame*)NULL,
                                                                            pSdoComCon);

                                    break;
                                }

                                case kEplSdoServiceReadByIndex:
                                {   // read by index

                                    // search entry an start transfer
                                    EplSdoComServerInitReadByIndex(pSdoComCon,
                                                                    pAsySdoCom_p);
                                    // check next state
                                    if(pSdoComCon->m_uiTransSize == 0)
                                    {   // ready -> stay idle
                                        pSdoComCon->m_SdoComState = kEplSdoComStateIdle;
                                        // reset abort code
                                        pSdoComCon->m_dwLastAbortCode = 0;
                                    }
                                    else
                                    {   // segmented transfer
                                        pSdoComCon->m_SdoComState = kEplSdoComStateServerSegmTrans;
                                    }

                                    break;
                                }

                                case kEplSdoServiceWriteByIndex:
                                {

                                    // search entry an start write
                                    EplSdoComServerInitWriteByIndex(pSdoComCon,
                                                                    pAsySdoCom_p);
                                    // check next state
                                    if(pSdoComCon->m_uiTransSize == 0)
                                    {   // already -> stay idle
                                        pSdoComCon->m_SdoComState = kEplSdoComStateIdle;
                                        // reset abort code
                                        pSdoComCon->m_dwLastAbortCode = 0;
                                    }
                                    else
                                    {   // segmented transfer
                                        pSdoComCon->m_SdoComState = kEplSdoComStateServerSegmTrans;
                                    }

                                    break;
                                }

                                default:
                                {
                                    //  unsupported command
                                    // send abort
                                    pSdoComCon->m_dwLastAbortCode = EPL_SDOAC_UNKNOWN_COMMAND_SPECIFIER;
                                    Ret = EplSdoComServerSendFrameIntern(pSdoComCon,
                                                                0,
                                                                0,
                                                                kEplSdoComSendTypeAbort);

                                    break;
                                }


                            }// end of switch(pAsySdoCom_p->m_le_bCommandId)
                        }
                    }
                    else
                    {   // this command layer handle is not responsible
                        // (wrong direction or wrong transaction ID)
                        Ret = kEplSdoComNotResponsible;
                        break;
                    }
#endif // end of #if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) != 0)

                    break;
                }

                // connection closed
                case kEplSdoComConEventInitError:
                case kEplSdoComConEventTimeout:
                case kEplSdoComConEventConClosed:
                {
                    Ret = EplSdoAsySeqDelCon(pSdoComCon->m_SdoSeqConHdl);
                    // clean control structure
                    EPL_MEMSET(pSdoComCon, 0x00, sizeof(tEplSdoComCon));
                    break;
                }

                default:
                    // d.k. do nothing
                    break;
            }// end of switch(SdoComConEvent_p)
            break;
        }

#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) != 0)
        //----------------------------------------------------------------------
        // SDO Server part
        // segmented transfer
        case kEplSdoComStateServerSegmTrans:
        {
            // check events
            switch(SdoComConEvent_p)
            {
                // send next frame
                case kEplSdoComConEventAckReceived:
                case kEplSdoComConEventFrameSended:
                {
                    // check if it is a read
                    if ((pSdoComCon->m_SdoTransType != kEplSdoTransExpedited)
                        && (pSdoComCon->m_SdoServiceType == kEplSdoServiceReadByIndex))
                    {
                        // send next frame
                        EplSdoComServerSendFrameIntern(pSdoComCon,
                                                            0,
                                                            0,
                                                            kEplSdoComSendTypeRes);
                        // if all send -> back to idle
                        if(pSdoComCon->m_uiTransSize == 0)
                        {   // back to idle
                            pSdoComCon->m_SdoComState = kEplSdoComStateIdle;
                            // reset abort code
                            pSdoComCon->m_dwLastAbortCode = 0;
                        }

                    }
                    break;
                }

                // process next frame
                case kEplSdoComConEventRec:
                {
                    // check if the frame is a SDO response and has the right transaction ID
                    bFlag = AmiGetByteFromLe(&pAsySdoCom_p->m_le_bFlags);

                    if (((bFlag & 0x80) == 0)
                        && (AmiGetByteFromLe(&pAsySdoCom_p->m_le_bTransactionId) == pSdoComCon->m_bTransactionId))
                    {
                        // check if it is a abort
                        if ((bFlag & 0x40) != 0)
                        {   // SDO abort
                            // clear control structure
                            pSdoComCon->m_uiTransSize = 0;
                            pSdoComCon->m_uiTransferredByte = 0;
                            // change state
                            pSdoComCon->m_SdoComState = kEplSdoComStateIdle;
                            // reset abort code
                            pSdoComCon->m_dwLastAbortCode = 0;
                            // d.k.: do not execute anything further on this command
                            break;
                        }

                        // check if it is a write
                        if (pSdoComCon->m_SdoServiceType == kEplSdoServiceWriteByIndex)
                        {
                        tEplObdParam    ObdParam;
                        tEplSdoAddress  SdoAddress;

                            uiSize = AmiGetWordFromLe(&pAsySdoCom_p->m_le_wSegmentSize);

                            // $$$ check end of transfer
                            //if ((pAsySdoCom_p->m_le_bFlags & 0x30) == 0x30)

                            EPL_MEMSET(&SdoAddress, 0, sizeof (SdoAddress));
                            SdoAddress.m_SdoAddrType = kEplSdoAddrTypeNodeId;
                            SdoAddress.m_uiNodeId = pSdoComCon->m_uiNodeId;

                            EPL_MEMSET(&ObdParam, 0, sizeof (ObdParam));
                            ObdParam.m_SegmentSize = (tEplObdSize) uiSize;
                            ObdParam.m_TransferSize = (tEplObdSize) pSdoComCon->m_uiTransSize;
                            ObdParam.m_SegmentOffset = pSdoComCon->m_uiCurSegOffs;
                            ObdParam.m_uiIndex = pSdoComCon->m_uiTargetIndex;
                            ObdParam.m_uiSubIndex = pSdoComCon->m_uiTargetSubIndex;
                            ObdParam.m_pData = &pAsySdoCom_p->m_le_abCommandData[0];
                            ObdParam.m_pHandle = pSdoComCon;
                            ObdParam.m_pfnAccessFinished = EplSdoComServerCbExpeditedWriteFinished;
                            ObdParam.m_pRemoteAddress = &SdoAddress;

                            // save next offset in m_pData for later use in case of segmented transfer
                            pSdoComCon->m_uiCurSegOffs += uiSize;

                            Ret = EplObdWriteEntryFromLe(&ObdParam);
                            if (Ret == kEplObdAccessAdopted)
                            {
                                Ret = kEplSuccessful;
                                goto Exit;
                            }
                            else if (Ret != kEplSuccessful)
                            {
                                if (ObdParam.m_dwAbortCode != 0)
                                {
                                    pSdoComCon->m_dwLastAbortCode = ObdParam.m_dwAbortCode;
                                }
                                else
                                {
                                    pSdoComCon->m_dwLastAbortCode = EPL_SDOAC_GENERAL_ERROR;
                                }
                                // send abort
                                Ret = EplSdoComServerSendFrameIntern(pSdoComCon,
                                                            0,
                                                            0,
                                                            kEplSdoComSendTypeAbort);
                                goto Exit;
                            }

                            // update internal counters
                            pSdoComCon->m_uiTransferredByte += uiSize;
                            pSdoComCon->m_uiTransSize -= uiSize;

                            if (pSdoComCon->m_uiTransSize == 0)
                            {   // transfer finished
                                // send command acknowledge
                                Ret = EplSdoComServerSendFrameIntern(pSdoComCon,
                                                                0,
                                                                0,
                                                                kEplSdoComSendTypeAckRes);

                                pSdoComCon->m_SdoComState = kEplSdoComStateIdle;
                            }
                            else
                            {   // segmented transfer has not completed yet
                                // send acknowledge without any Command layer data
                                Ret = EplSdoAsySeqSendData(pSdoComCon->m_SdoSeqConHdl,
                                                                        0,
                                                                        (tEplFrame*)NULL,
                                                                        pSdoComCon);
                            }
                        }
                    }
                    else
                    {   // this command layer handle is not responsible
                        // (wrong direction or wrong transaction ID)
                        Ret = kEplSdoComNotResponsible;
                        goto Exit;
                    }
                    break;
                }

                // connection closed
                case kEplSdoComConEventInitError:
                case kEplSdoComConEventTimeout:
                case kEplSdoComConEventConClosed:
                {
                    Ret = EplSdoAsySeqDelCon(pSdoComCon->m_SdoSeqConHdl);
                    // clean control structure
                    EPL_MEMSET(pSdoComCon, 0x00, sizeof(tEplSdoComCon));
                    break;
                }

                default:
                    // d.k. do nothing
                    break;
            }// end of switch(SdoComConEvent_p)

            break;
        }
#endif // endif of #if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) != 0)


#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
        //----------------------------------------------------------------------
        // SDO Client part
        // wait for finish of establishing connection
        case kEplSdoComStateClientWaitInit:
        {

            // if connection handle is invalid reinit connection
            // d.k.: this will be done only on new events (i.e. InitTransfer)
            if((pSdoComCon->m_SdoSeqConHdl & ~EPL_SDO_SEQ_HANDLE_MASK) == EPL_SDO_SEQ_INVALID_HDL)
            {
                // check kind of connection to reinit
                // check protocol
                switch(pSdoComCon->m_SdoProtType)
                {
                    // udp
                    case kEplSdoTypeUdp:
                    {
                        // call connection int function of lower layer
                        Ret = EplSdoAsySeqInitCon(&pSdoComCon->m_SdoSeqConHdl,
                                    pSdoComCon->m_uiNodeId,
                                    kEplSdoTypeUdp);
                        if(Ret != kEplSuccessful)
                        {
                            goto Exit;
                        }
                        break;
                    }

                    // Asend -> not supported
                    case kEplSdoTypeAsnd:
                    {
                        // call connection int function of lower layer
                        Ret = EplSdoAsySeqInitCon(&pSdoComCon->m_SdoSeqConHdl,
                                    pSdoComCon->m_uiNodeId,
                                    kEplSdoTypeAsnd);
                        if(Ret != kEplSuccessful)
                        {
                            goto Exit;
                        }
                        break;
                    }

#ifdef EPL_MODULE_API_PDI
                    case kEplSdoTypeApiPdi:
                    {
                        break;
                    }
#endif // EPL_MODULE_API_PDI

                    // Pdo -> not supported
                    case kEplSdoTypePdo:
                    default:
                    {
                        Ret = kEplSdoComUnsupportedProt;
                        goto Exit;
                    }
                }// end of switch(m_ProtType_p)
                // d.k.: reset transaction ID, because new sequence layer connection was initialized
                // $$$ d.k. is this really necessary?
                //pSdoComCon->m_bTransactionId = 0;
            }

            // check events
            switch(SdoComConEvent_p)
            {
                // connection established
                case kEplSdoComConEventConEstablished:
                {
                    // send first frame if needed
                    if ((pSdoComCon->m_uiTransSize > 0)
                        && (pSdoComCon->m_uiTargetIndex != 0))
                    {   // start SDO transfer
                        // check if segemted transfer
                        if (pSdoComCon->m_SdoTransType == kEplSdoTransSegmented)
                        {
                            pSdoComCon->m_SdoComState = kEplSdoComStateClientSegmTrans;
                        }
                        else
                        {
                            pSdoComCon->m_SdoComState = kEplSdoComStateClientConnected;
                        }

                        Ret = EplSdoComClientSend(pSdoComCon);
                        if (Ret != kEplSuccessful)
                        {
                            goto Exit;
                        }

                    }
                    else
                    {
                        // goto state kEplSdoComStateClientConnected
                        pSdoComCon->m_SdoComState = kEplSdoComStateClientConnected;
                    }
                    goto Exit;
                }

                case kEplSdoComConEventSendFirst:
                {
                    // infos for transfer already saved by function EplSdoComInitTransferByIndex
                    break;
                }

                // abort to send from higher layer
                case kEplSdoComConEventAbort:
                {
                    // call callback of application
                    pSdoComCon->m_dwLastAbortCode = *((DWORD*)pSdoComCon->m_pData);
                    Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferTxAborted);

                    break;
                }

                case kEplSdoComConEventConClosed:
                case kEplSdoComConEventInitError:
                case kEplSdoComConEventTimeout:
                case kEplSdoComConEventTransferAbort:
                {
                    // close sequence layer handle
                    Ret = EplSdoAsySeqDelCon(pSdoComCon->m_SdoSeqConHdl);
                    pSdoComCon->m_SdoSeqConHdl |= EPL_SDO_SEQ_INVALID_HDL;
                    // call callback function
                    if (SdoComConEvent_p == kEplSdoComConEventTimeout)
                    {
                        pSdoComCon->m_dwLastAbortCode = EPL_SDOAC_TIME_OUT;
                    }
                    else
                    {
                        pSdoComCon->m_dwLastAbortCode = 0;
                    }
                    Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferLowerLayerAbort);
                    // d.k.: do not clean control structure
                    break;
                }

                default:
                    // d.k. do nothing
                    break;

            } // end of  switch(SdoComConEvent_p)
            break;
        }

        // connected
        case kEplSdoComStateClientConnected:
        {
            // check events
            switch(SdoComConEvent_p)
            {
                // send a frame
                case kEplSdoComConEventSendFirst:
                case kEplSdoComConEventAckReceived:
                case kEplSdoComConEventFrameSended:
                {
                    Ret = EplSdoComClientSend(pSdoComCon);
                    if(Ret != kEplSuccessful)
                    {
                        goto Exit;
                    }

                    // check if read transfer finished
                    if((pSdoComCon->m_uiTransSize == 0)
                        && (pSdoComCon->m_uiTransferredByte != 0)
                        && (pSdoComCon->m_SdoServiceType == kEplSdoServiceReadByIndex))
                    {
                        // inc transaction id
                        pSdoComCon->m_bTransactionId++;
                        // call callback of application
                        pSdoComCon->m_dwLastAbortCode = 0;
                        Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferFinished);

                        goto Exit;
                    }

                    // check if segemted transfer
                    if(pSdoComCon->m_SdoTransType == kEplSdoTransSegmented)
                    {
                        pSdoComCon->m_SdoComState = kEplSdoComStateClientSegmTrans;
                        goto Exit;
                    }
                    break;
                }

                // frame received
                case kEplSdoComConEventRec:
                {
                    // check if the frame is a SDO response and has the right transaction ID
                    bFlag = AmiGetByteFromLe(&pAsySdoCom_p->m_le_bFlags);
                    if (((bFlag & 0x80) != 0) && (AmiGetByteFromLe(&pAsySdoCom_p->m_le_bTransactionId) == pSdoComCon->m_bTransactionId))
                    {
                        // check if abort or not
                        if((bFlag & 0x40) != 0)
                        {
                            // send acknowledge without any Command layer data
                            Ret = EplSdoAsySeqSendData(pSdoComCon->m_SdoSeqConHdl,
                                                                    0,
                                                                    (tEplFrame*)NULL);
                            // inc transaction id
                            pSdoComCon->m_bTransactionId++;
                            // save abort code
                            pSdoComCon->m_dwLastAbortCode = AmiGetDwordFromLe(&pAsySdoCom_p->m_le_abCommandData[0]);
                            // call callback of application
                            Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferRxAborted);

                            goto Exit;
                        }
                        else
                        {   // normal frame received
                            // check frame
                            Ret = EplSdoComClientProcessFrame(SdoComCon_p, pAsySdoCom_p);

                            // check if transfer ready
                            if(pSdoComCon->m_uiTransSize == 0)
                            {
                                // send acknowledge without any Command layer data
                                Ret = EplSdoAsySeqSendData(pSdoComCon->m_SdoSeqConHdl,
                                                                        0,
                                                                        (tEplFrame*)NULL);
                                // inc transaction id
                                pSdoComCon->m_bTransactionId++;
                                // call callback of application
                                pSdoComCon->m_dwLastAbortCode = 0;
                                Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferFinished);

                                goto Exit;
                            }

                        }
                    }
                    else
                    {   // this command layer handle is not responsible
                        // (wrong direction or wrong transaction ID)
                        Ret = kEplSdoComNotResponsible;
                        goto Exit;
                    }
                    break;
                }

                // connection closed event go back to kEplSdoComStateClientWaitInit
                case kEplSdoComConEventConClosed:
                {   // connection closed by communication partner
                    // close sequence layer handle
                    Ret = EplSdoAsySeqDelCon(pSdoComCon->m_SdoSeqConHdl);
                    // set handle to invalid and enter kEplSdoComStateClientWaitInit
                    pSdoComCon->m_SdoSeqConHdl |= EPL_SDO_SEQ_INVALID_HDL;
                    // change state
                    pSdoComCon->m_SdoComState = kEplSdoComStateClientWaitInit;

                    // call callback of application
                    pSdoComCon->m_dwLastAbortCode = 0;
                    Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferLowerLayerAbort);

                    break;
                }

                // abort to send from higher layer
                case kEplSdoComConEventAbort:
                {
                    EplSdoComClientSendAbort(pSdoComCon,*((DWORD*)pSdoComCon->m_pData));

                    // inc transaction id
                    pSdoComCon->m_bTransactionId++;
                    // call callback of application
                    pSdoComCon->m_dwLastAbortCode = *((DWORD*)pSdoComCon->m_pData);
                    Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferTxAborted);

                    break;
                }

                case kEplSdoComConEventInitError:
                case kEplSdoComConEventTimeout:
                {
                    // close sequence layer handle
                    Ret = EplSdoAsySeqDelCon(pSdoComCon->m_SdoSeqConHdl);
                    pSdoComCon->m_SdoSeqConHdl |= EPL_SDO_SEQ_INVALID_HDL;
                    // change state
                    pSdoComCon->m_SdoComState = kEplSdoComStateClientWaitInit;
                    // call callback of application
                    pSdoComCon->m_dwLastAbortCode = EPL_SDOAC_TIME_OUT;
                    Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferLowerLayerAbort);

                    break;
                }

                case kEplSdoComConEventTransferAbort:
                {
                    // change state
                    pSdoComCon->m_SdoComState = kEplSdoComStateClientWaitInit;
                    // call callback of application
                    pSdoComCon->m_dwLastAbortCode = EPL_SDOAC_TIME_OUT;
                    Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferLowerLayerAbort);

                    break;
                }

                default:
                    // d.k. do nothing
                    break;

            } // end of switch(SdoComConEvent_p)

            break;
        }

        // process segmented transfer
        case kEplSdoComStateClientSegmTrans:
        {
            // check events
            switch(SdoComConEvent_p)
            {
                // sned a frame
                case kEplSdoComConEventSendFirst:
                case kEplSdoComConEventAckReceived:
                case kEplSdoComConEventFrameSended:
                {
                    Ret = EplSdoComClientSend(pSdoComCon);
                    if(Ret != kEplSuccessful)
                    {
                        goto Exit;
                    }

                    // check if read transfer finished
                    if((pSdoComCon->m_uiTransSize == 0)
                        && (pSdoComCon->m_SdoServiceType == kEplSdoServiceReadByIndex))
                    {
                        // inc transaction id
                        pSdoComCon->m_bTransactionId++;
                        // change state
                        pSdoComCon->m_SdoComState = kEplSdoComStateClientConnected;
                        // call callback of application
                        pSdoComCon->m_dwLastAbortCode = 0;
                        Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferFinished);

                        goto Exit;
                    }

                    break;
                }

                // frame received
                case kEplSdoComConEventRec:
                {
                    // check if the frame is a response
                    bFlag = AmiGetByteFromLe(&pAsySdoCom_p->m_le_bFlags);
                    if (((bFlag & 0x80) != 0) && (AmiGetByteFromLe(&pAsySdoCom_p->m_le_bTransactionId) == pSdoComCon->m_bTransactionId))
                    {
                        // check if abort or not
                        if((bFlag & 0x40) != 0)
                        {
                            // send acknowledge without any Command layer data
                            Ret = EplSdoAsySeqSendData(pSdoComCon->m_SdoSeqConHdl,
                                                                    0,
                                                                    (tEplFrame*)NULL);
                            // inc transaction id
                            pSdoComCon->m_bTransactionId++;
                            // change state
                            pSdoComCon->m_SdoComState = kEplSdoComStateClientConnected;
                            // save abort code
                            pSdoComCon->m_dwLastAbortCode = AmiGetDwordFromLe(&pAsySdoCom_p->m_le_abCommandData[0]);
                            // call callback of application
                            Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferRxAborted);

                            goto Exit;
                        }
                        else
                        {   // normal frame received
                            // check frame
                            Ret = EplSdoComClientProcessFrame(SdoComCon_p, pAsySdoCom_p);

                            // check if transfer ready
                            if(pSdoComCon->m_uiTransSize == 0)
                            {
                                // send acknowledge without any Command layer data
                                Ret = EplSdoAsySeqSendData(pSdoComCon->m_SdoSeqConHdl,
                                                                        0,
                                                                        (tEplFrame*)NULL);
                                // inc transaction id
                                pSdoComCon->m_bTransactionId++;
                                // change state
                                pSdoComCon->m_SdoComState = kEplSdoComStateClientConnected;
                                // call callback of application
                                pSdoComCon->m_dwLastAbortCode = 0;
                                Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferFinished);

                            }

                        }
                    }
                    break;
                }

                // connection closed event go back to kEplSdoComStateClientWaitInit
                case kEplSdoComConEventConClosed:
                {   // connection closed by communication partner
                    // close sequence layer handle
                    Ret = EplSdoAsySeqDelCon(pSdoComCon->m_SdoSeqConHdl);
                    // set handle to invalid and enter kEplSdoComStateClientWaitInit
                    pSdoComCon->m_SdoSeqConHdl |= EPL_SDO_SEQ_INVALID_HDL;
                    // change state
                    pSdoComCon->m_SdoComState = kEplSdoComStateClientWaitInit;
                    // inc transaction id
                    pSdoComCon->m_bTransactionId++;
                    // call callback of application
                    pSdoComCon->m_dwLastAbortCode = 0;
                    Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferFinished);

                    break;
                }

                // abort to send from higher layer
                case kEplSdoComConEventAbort:
                {
                    EplSdoComClientSendAbort(pSdoComCon,*((DWORD*)pSdoComCon->m_pData));

                    // inc transaction id
                    pSdoComCon->m_bTransactionId++;
                    // change state
                    pSdoComCon->m_SdoComState = kEplSdoComStateClientConnected;
                    // call callback of application
                    pSdoComCon->m_dwLastAbortCode = *((DWORD*)pSdoComCon->m_pData);
                    Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferTxAborted);

                    break;
                }

                case kEplSdoComConEventInitError:
                case kEplSdoComConEventTimeout:
                {
                    // close sequence layer handle
                    Ret = EplSdoAsySeqDelCon(pSdoComCon->m_SdoSeqConHdl);
                    pSdoComCon->m_SdoSeqConHdl |= EPL_SDO_SEQ_INVALID_HDL;
                    // change state
                    pSdoComCon->m_SdoComState = kEplSdoComStateClientWaitInit;
                    // call callback of application
                    pSdoComCon->m_dwLastAbortCode = EPL_SDOAC_TIME_OUT;
                    Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferLowerLayerAbort);

                    break;
                }

                case kEplSdoComConEventTransferAbort:
                {
                    // change state
                    pSdoComCon->m_SdoComState = kEplSdoComStateClientWaitInit;
                    // call callback of application
                    pSdoComCon->m_dwLastAbortCode = EPL_SDOAC_TIME_OUT;
                    Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferLowerLayerAbort);

                    break;
                }

                default:
                    // d.k. do nothing
                    break;

            } // end of switch(SdoComConEvent_p)

            break;
        }
#endif // endo of #if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)

    }// end of switch(pSdoComCon->m_SdoComState)



//#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
Exit:
//#endif

#if defined(WIN32) || defined(_WIN32)
    // leave critical section for process function
    EPL_DBGLVL_SDO_TRACE0("\n\tLeaveCriticalSection EplSdoComProcessIntern\n\n");
    LeaveCriticalSection(SdoComInstance_g.m_pCriticalSection);

#endif

    return Ret;

}


//---------------------------------------------------------------------------
//
// Function:        EplSdoComServerInitReadByIndex
//
// Description:    function start the processing of an read by index command
//
//
//
// Parameters:      pSdoComCon_p     = pointer to control structure of connection
//                  pAsySdoCom_p     = pointer to received frame
//
// Returns:         tEplKernel  =  errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) != 0)
static tEplKernel EplSdoComServerInitReadByIndex(tEplSdoComCon*     pSdoComCon_p,
                                         tEplAsySdoCom*     pAsySdoCom_p)
{
tEplKernel      Ret;
unsigned int    uiIndex;
unsigned int    uiSubindex;

    // a init of a read could not be a segmented transfer
    // -> no variable part of header

    // get index and subindex
    uiIndex = AmiGetWordFromLe(&pAsySdoCom_p->m_le_abCommandData[0]);
    uiSubindex = AmiGetByteFromLe(&pAsySdoCom_p->m_le_abCommandData[2]);

    // save service
    pSdoComCon_p->m_SdoServiceType = kEplSdoServiceReadByIndex;

    pSdoComCon_p->m_SdoTransType = kEplSdoTransExpedited;

    pSdoComCon_p->m_uiTransSize = EPL_SDO_MAX_TX_SEGMENT_SIZE - 4;
    pSdoComCon_p->m_uiTransferredByte = 0;

    Ret = EplSdoComServerSendFrameIntern(pSdoComCon_p,
                                    uiIndex,
                                    uiSubindex,
                                    kEplSdoComSendTypeRes);
    if (Ret != kEplSuccessful)
    {
        // error -> abort
        pSdoComCon_p->m_dwLastAbortCode = EPL_SDOAC_GENERAL_ERROR;
        // send abort
        Ret = EplSdoComServerSendFrameIntern(pSdoComCon_p,
                                    uiIndex,
                                    uiSubindex,
                                    kEplSdoComSendTypeAbort);
        goto Exit;
    }

Exit:
    return Ret;
}
#endif

//---------------------------------------------------------------------------
//
// Function:    EplSdoComServerCbExpeditedReadFinished();
//
// Description: function is called by the adopter of the OD read access
//
// Parameters:  pObdParam_p     = pointer to OBD parameter structure
//
// Returns:     tEplKernel  =  errorcode
//
// State:
//
//---------------------------------------------------------------------------
#if (((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) != 0)
static tEplKernel PUBLIC EplSdoComServerCbExpeditedReadFinished(tEplObdParam* pObdParam_p)
{
tEplKernel      Ret;
tEplSdoComCon*  pSdoComCon;
BYTE            abFrame[EPL_SDO_MAX_TX_FRAME_SIZE];
tEplFrame*      pFrame;
tEplAsySdoCom*  pCommandFrame;
unsigned int    uiSizeOfFrame;
BYTE            bFlag;

    Ret = kEplSuccessful;

    pSdoComCon = pObdParam_p->m_pHandle;

    if (pObdParam_p->m_dwAbortCode != 0)
    {
        // send abort
        pSdoComCon->m_dwLastAbortCode = pObdParam_p->m_dwAbortCode;
        Ret = EplSdoComServerSendFrameIntern(pSdoComCon,
                                    pObdParam_p->m_uiIndex,
                                    pObdParam_p->m_uiSubIndex,
                                    kEplSdoComSendTypeAbort);

        pSdoComCon->m_SdoComState = kEplSdoComStateIdle;
        goto Exit;
    }

    pFrame = (tEplFrame*)&abFrame[0];

    EPL_MEMSET(&abFrame[0], 0x00, sizeof(abFrame));

    // build generic part of frame
    // get pointer to command layer part of frame
    pCommandFrame = &pFrame->m_Data.m_Asnd.m_Payload.m_SdoSequenceFrame.m_le_abSdoSeqPayload;
    AmiSetByteToLe(&pCommandFrame->m_le_bCommandId, pSdoComCon->m_SdoServiceType);
    AmiSetByteToLe(&pCommandFrame->m_le_bTransactionId, pSdoComCon->m_bTransactionId);

    // set size to header size
    uiSizeOfFrame = 8;

    // set response flag
    bFlag = AmiGetByteFromLe( &pCommandFrame->m_le_bFlags);
    bFlag |= 0x80;
    AmiSetByteToLe(&pCommandFrame->m_le_bFlags,  bFlag);

    // check type of response
    if (pSdoComCon->m_SdoTransType == kEplSdoTransExpedited)
    {   // Expedited transfer
        // copy data to frame
        EPL_MEMCPY(&pCommandFrame->m_le_abCommandData[0], pObdParam_p->m_pData, pObdParam_p->m_SegmentSize);

        // set size of frame
        pSdoComCon->m_uiTransSize = pObdParam_p->m_SegmentSize;
        AmiSetWordToLe(&pCommandFrame->m_le_wSegmentSize, (WORD) pSdoComCon->m_uiTransSize);

        // correct byte-counter
        uiSizeOfFrame += pSdoComCon->m_uiTransSize;
        pSdoComCon->m_uiTransferredByte += pSdoComCon->m_uiTransSize;
        pSdoComCon->m_uiTransSize = 0;


        // send frame
        uiSizeOfFrame += pSdoComCon->m_uiTransSize;
        Ret = EplSdoAsySeqSendData(pSdoComCon->m_SdoSeqConHdl,
                                    uiSizeOfFrame,
                                    pFrame,
                                    pSdoComCon);

        pSdoComCon->m_SdoComState = kEplSdoComStateIdle;
        pSdoComCon->m_uiTransSize = 0;
    }

Exit:
    return Ret;
}
#endif

//---------------------------------------------------------------------------
//
// Function:        EplSdoComServerSendFrameIntern();
//
// Description:    function creats and send a frame for server
//
//
//
// Parameters:      pSdoComCon_p     = pointer to control structure of connection
//                  uiIndex_p        = index to send if expedited transfer else 0
//                  uiSubIndex_p     = subindex to send if expedited transfer else 0
//                  SendType_p       = to of frame to send
//
// Returns:         tEplKernel  =  errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) != 0)
static tEplKernel PUBLIC EplSdoComServerSendFrameIntern(tEplSdoComCon*     pSdoComCon_p,
                                           unsigned int       uiIndex_p,
                                           unsigned int       uiSubIndex_p,
                                           tEplSdoComSendType SendType_p)
{
tEplKernel      Ret;
BYTE            abFrame[EPL_SDO_MAX_TX_FRAME_SIZE];
tEplFrame*      pFrame;
tEplAsySdoCom*  pCommandFrame;
unsigned int    uiSizeOfFrame;
BYTE            bFlag;

    Ret = kEplSuccessful;

    pFrame = (tEplFrame*)&abFrame[0];

    EPL_MEMSET(&abFrame[0], 0x00, sizeof(abFrame));

    // build generic part of frame
    // get pointer to command layerpart of frame
    pCommandFrame = &pFrame->m_Data.m_Asnd.m_Payload.m_SdoSequenceFrame.m_le_abSdoSeqPayload;
    AmiSetByteToLe(&pCommandFrame->m_le_bCommandId, pSdoComCon_p->m_SdoServiceType);
    AmiSetByteToLe(&pCommandFrame->m_le_bTransactionId, pSdoComCon_p->m_bTransactionId);

    // set size to header size
    uiSizeOfFrame = 8;

    // check SendType
    switch(SendType_p)
    {
        // requestframe to send
        case kEplSdoComSendTypeReq:
        {
            // nothing to do for server
            //-> error
            Ret = kEplSdoComInvalidSendType;
            break;
        }

        // response without data to send
        case kEplSdoComSendTypeAckRes:
        {
            // set response flag
            AmiSetByteToLe(&pCommandFrame->m_le_bFlags,  0x80);

            // send frame
            Ret = EplSdoAsySeqSendData(pSdoComCon_p->m_SdoSeqConHdl,
                                            uiSizeOfFrame,
                                            pFrame,
                                            pSdoComCon_p);

            break;
        }

        // responseframe to send
        case kEplSdoComSendTypeRes:
        {
            // set response flag
            bFlag = AmiGetByteFromLe( &pCommandFrame->m_le_bFlags);
            bFlag |= 0x80;
            AmiSetByteToLe(&pCommandFrame->m_le_bFlags,  bFlag);

            // check type of response
            if (pSdoComCon_p->m_SdoTransType == kEplSdoTransExpedited)
            {   // Expedited transfer
            tEplObdParam    ObdParam;
            tEplSdoAddress  SdoAddress;

                // read object from OD with destination buffer points to frame

                EPL_MEMSET(&SdoAddress, 0, sizeof (SdoAddress));
                SdoAddress.m_SdoAddrType = kEplSdoAddrTypeNodeId;
                SdoAddress.m_uiNodeId = pSdoComCon_p->m_uiNodeId;

                EPL_MEMSET(&ObdParam, 0, sizeof (ObdParam));
                ObdParam.m_SegmentSize = (tEplObdSize) pSdoComCon_p->m_uiTransSize;
                ObdParam.m_TransferSize = 0;
                ObdParam.m_uiIndex = uiIndex_p;
                ObdParam.m_uiSubIndex = uiSubIndex_p;
                ObdParam.m_pData = &pCommandFrame->m_le_abCommandData[0];
                ObdParam.m_pHandle = pSdoComCon_p;
                ObdParam.m_pfnAccessFinished = EplSdoComServerCbExpeditedReadFinished;
                ObdParam.m_pRemoteAddress = &SdoAddress;

                Ret = EplObdReadEntryToLe(&ObdParam);
                if (Ret == kEplObdAccessAdopted)
                {
                    Ret = kEplSuccessful;
                    // send acknowledge without any Command layer data

                    // NO Sequence Layer present -> dont sent ack!
//                    Ret = EplSdoAsySeqSendData(pSdoComCon_p->m_SdoSeqConHdl,
//                                                            0,
//                                                            (tEplFrame*)NULL);
                    goto Exit;
                }
                else if (Ret != kEplSuccessful)
                {
                    // send abort
                    pSdoComCon_p->m_dwLastAbortCode = ObdParam.m_dwAbortCode;
                    Ret = EplSdoComServerSendFrameIntern(pSdoComCon_p,
                                                uiIndex_p,
                                                uiSubIndex_p,
                                                kEplSdoComSendTypeAbort);
                    goto Exit;
                }

                if (ObdParam.m_SegmentSize < ObdParam.m_TransferSize)
                {   // the transfer is in fact a segmented transfer

                    //Currently, segmented read is not supported!
                    Ret = kEplSdoComUnsupportedProt;
                    goto Exit;
                  /*
                    pSdoComCon_p->m_SdoTransType = kEplSdoTransSegmented;
                    pSdoComCon_p->m_pData = EplObduGetObjectDataPtr(uiIndex_p, uiSubIndex_p);

                    pSdoComCon_p->m_uiTransSize = ObdParam.m_TransferSize;

                    // set init flag
                    bFlag = AmiGetByteFromLe( &pCommandFrame->m_le_bFlags);
                    bFlag |= 0x10;
                    AmiSetByteToLe(&pCommandFrame->m_le_bFlags,  bFlag);
                    // init data size in variable header, which includes itself
                    AmiSetDwordToLe(&pCommandFrame->m_le_abCommandData[0],
                                    pSdoComCon_p->m_uiTransSize + 4);

                    // correct byte-counter
                    pSdoComCon_p->m_uiTransSize -= ObdParam.m_SegmentSize;
                    pSdoComCon_p->m_uiTransferredByte += ObdParam.m_SegmentSize;

                    // move data pointer
                    pSdoComCon_p->m_pData += ObdParam.m_SegmentSize;

                    // set segment size
                    AmiSetWordToLe(&pCommandFrame->m_le_wSegmentSize, (WORD) (ObdParam.m_SegmentSize + 4));

                    // send frame
                    uiSizeOfFrame += ObdParam.m_SegmentSize + 4;

                    */
                }
                else
                {
                    pSdoComCon_p->m_uiTransSize = ObdParam.m_SegmentSize;

                    // set size of frame
                    AmiSetWordToLe(&pCommandFrame->m_le_wSegmentSize, (WORD) pSdoComCon_p->m_uiTransSize);

                    // correct byte-counter
                    uiSizeOfFrame += pSdoComCon_p->m_uiTransSize;
                    pSdoComCon_p->m_uiTransferredByte += pSdoComCon_p->m_uiTransSize;
                    pSdoComCon_p->m_uiTransSize = 0;

                    // send frame
                    uiSizeOfFrame += pSdoComCon_p->m_uiTransSize;
                }

                Ret = EplSdoAsySeqSendData(pSdoComCon_p->m_SdoSeqConHdl,
                                            uiSizeOfFrame,
                                            pFrame,
                                            pSdoComCon_p);

            }
            else if (pSdoComCon_p->m_SdoTransType == kEplSdoTransSegmented)
            {   // segmented transfer
                // distinguish between init, segment and complete
                if(pSdoComCon_p->m_uiTransferredByte == 0)
                {   // init
                    // set init flag
                    bFlag = AmiGetByteFromLe( &pCommandFrame->m_le_bFlags);
                    bFlag |= 0x10;
                    AmiSetByteToLe(&pCommandFrame->m_le_bFlags,  bFlag);
                    // init data size in variable header, which includes itself
                    AmiSetDwordToLe(&pCommandFrame->m_le_abCommandData[0], pSdoComCon_p->m_uiTransSize + 4);
                    // copy data in frame
                    EPL_MEMCPY(&pCommandFrame->m_le_abCommandData[4],pSdoComCon_p->m_pData, (EPL_SDO_MAX_TX_SEGMENT_SIZE-4));

                    // correct byte-counter
                    pSdoComCon_p->m_uiTransSize -= (EPL_SDO_MAX_TX_SEGMENT_SIZE-4);
                    pSdoComCon_p->m_uiTransferredByte += (EPL_SDO_MAX_TX_SEGMENT_SIZE-4);
                    // move data pointer
                    pSdoComCon_p->m_pData +=(EPL_SDO_MAX_TX_SEGMENT_SIZE-4);

                    // set segment size
                    AmiSetWordToLe(&pCommandFrame->m_le_wSegmentSize, EPL_SDO_MAX_TX_SEGMENT_SIZE);

                    // send frame
                    uiSizeOfFrame += EPL_SDO_MAX_TX_SEGMENT_SIZE;
                    Ret = EplSdoAsySeqSendData(pSdoComCon_p->m_SdoSeqConHdl,
                                                uiSizeOfFrame,
                                                pFrame,
                                                pSdoComCon_p);

                }
                else if((pSdoComCon_p->m_uiTransferredByte > 0)
                    &&(pSdoComCon_p->m_uiTransSize > EPL_SDO_MAX_TX_SEGMENT_SIZE))
                {   // segment
                    // set segment flag
                    bFlag = AmiGetByteFromLe( &pCommandFrame->m_le_bFlags);
                    bFlag |= 0x20;
                    AmiSetByteToLe(&pCommandFrame->m_le_bFlags,  bFlag);

                    // copy data in frame
                    EPL_MEMCPY(&pCommandFrame->m_le_abCommandData[0],pSdoComCon_p->m_pData, EPL_SDO_MAX_TX_SEGMENT_SIZE);

                    // correct byte-counter
                    pSdoComCon_p->m_uiTransSize -= EPL_SDO_MAX_TX_SEGMENT_SIZE;
                    pSdoComCon_p->m_uiTransferredByte += EPL_SDO_MAX_TX_SEGMENT_SIZE;
                    // move data pointer
                    pSdoComCon_p->m_pData +=EPL_SDO_MAX_TX_SEGMENT_SIZE;

                    // set segment size
                    AmiSetWordToLe(&pCommandFrame->m_le_wSegmentSize,EPL_SDO_MAX_TX_SEGMENT_SIZE);

                    // send frame
                    uiSizeOfFrame += EPL_SDO_MAX_TX_SEGMENT_SIZE;
                    Ret = EplSdoAsySeqSendData(pSdoComCon_p->m_SdoSeqConHdl,
                                                uiSizeOfFrame,
                                                pFrame,
                                                pSdoComCon_p);
                }
                else
                {
                    if((pSdoComCon_p->m_uiTransSize == 0)
                        && (pSdoComCon_p->m_SdoServiceType != kEplSdoServiceWriteByIndex))
                    {
                        goto Exit;
                    }
                    // complete
                    // set segment complete flag
                    bFlag = AmiGetByteFromLe( &pCommandFrame->m_le_bFlags);
                    bFlag |= 0x30;
                    AmiSetByteToLe(&pCommandFrame->m_le_bFlags,  bFlag);

                    // copy data in frame
                    EPL_MEMCPY(&pCommandFrame->m_le_abCommandData[0],pSdoComCon_p->m_pData, pSdoComCon_p->m_uiTransSize);

                    // correct byte-counter
                    pSdoComCon_p->m_uiTransferredByte += pSdoComCon_p->m_uiTransSize;


                    // move data pointer
                    pSdoComCon_p->m_pData +=pSdoComCon_p->m_uiTransSize;

                    // set segment size
                    AmiSetWordToLe(&pCommandFrame->m_le_wSegmentSize, (WORD) pSdoComCon_p->m_uiTransSize);

                    // send frame
                    uiSizeOfFrame += pSdoComCon_p->m_uiTransSize;
                    pSdoComCon_p->m_uiTransSize = 0;
                    Ret = EplSdoAsySeqSendData(pSdoComCon_p->m_SdoSeqConHdl,
                                                uiSizeOfFrame,
                                                pFrame,
                                                pSdoComCon_p);
                }

            }
            break;
        }
        // abort to send
        case kEplSdoComSendTypeAbort:
        {
            // set response and abort flag
            bFlag = AmiGetByteFromLe( &pCommandFrame->m_le_bFlags);
            bFlag |= 0xC0;
            AmiSetByteToLe(&pCommandFrame->m_le_bFlags,  bFlag);

            // copy abortcode to frame
            AmiSetDwordToLe(&pCommandFrame->m_le_abCommandData[0], pSdoComCon_p->m_dwLastAbortCode);

            // set size of segment
            AmiSetWordToLe(&pCommandFrame->m_le_wSegmentSize, sizeof(DWORD));

            // update counter
            pSdoComCon_p->m_uiTransferredByte = sizeof(DWORD);
            pSdoComCon_p->m_uiTransSize = 0;

            // calc framesize
            uiSizeOfFrame += sizeof(DWORD);
            Ret = EplSdoAsySeqSendData(pSdoComCon_p->m_SdoSeqConHdl,
                                                uiSizeOfFrame,
                                                pFrame,
                                                pSdoComCon_p);
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO,"ERROR: SDO Aborted!\n");

            break;
        }
    } // end of switch(SendType_p)

Exit:
    return Ret;
}
#endif

//---------------------------------------------------------------------------
//
// Function:    EplSdoComServerCbExpeditedWriteFinished();
//
// Description: function is called by the adopter of the OD write access
//
// Parameters:  pObdParam_p     = pointer to OBD parameter structure
//
// Returns:     tEplKernel  =  errorcode
//
// State:
//
//---------------------------------------------------------------------------
#if (((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) != 0)
static tEplKernel EplSdoComServerCbExpeditedWriteFinished(tEplObdParam* pObdParam_p)
{
tEplKernel      Ret;
tEplSdoComCon*  pSdoComCon;

    Ret = kEplSuccessful;

    pSdoComCon = pObdParam_p->m_pHandle;

    if (pObdParam_p->m_dwAbortCode != 0)
    {
        // send abort
        pSdoComCon->m_dwLastAbortCode = pObdParam_p->m_dwAbortCode;
        Ret = EplSdoComServerSendFrameIntern(pSdoComCon,
                                    pObdParam_p->m_uiIndex,
                                    pObdParam_p->m_uiSubIndex,
                                    kEplSdoComSendTypeAbort);

        pSdoComCon->m_SdoComState = kEplSdoComStateIdle;
    }
    else
    {

        // update internal counters
        pSdoComCon->m_uiTransferredByte = pObdParam_p->m_SegmentSize;
        pSdoComCon->m_uiTransSize -= pObdParam_p->m_SegmentSize;

        if (pSdoComCon->m_uiTransSize == 0)
        {   // transfer finished
            // send command acknowledge
            Ret = EplSdoComServerSendFrameIntern(pSdoComCon,
                                            0,
                                            0,
                                            kEplSdoComSendTypeAckRes);

            pSdoComCon->m_SdoComState = kEplSdoComStateIdle;
        }
        else
        {   // segmented transfer has not completed yet
            // send acknowledge without any Command layer data
            Ret = EplSdoAsySeqSendData(pSdoComCon->m_SdoSeqConHdl,
                                                    0,
                                                    (tEplFrame*)NULL,
                                                    pSdoComCon);
        }
    }

//Exit:
    //DEBUG_TRACE2(DEBUG_LVL_CNAPI_INFO,"Abort code: 0x%08x Ret: 0x%04x\n", pObdParam_p->m_dwAbortCode, Ret);
    return Ret;
}
#endif


//---------------------------------------------------------------------------
//
// Function:        EplSdoComServerInitWriteByIndex
//
// Description:    function start the processing of an write by index command
//
//
//
// Parameters:      pSdoComCon_p     = pointer to control structure of connection
//                  pAsySdoCom_p     = pointer to received frame
//
// Returns:         tEplKernel  =  errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOS)) != 0)
static tEplKernel EplSdoComServerInitWriteByIndex(tEplSdoComCon*     pSdoComCon_p,
                                         tEplAsySdoCom*     pAsySdoCom_p)
{
tEplKernel  Ret = kEplSuccessful;
unsigned int    uiSegmentSize;
BYTE*           pbSrcData;
tEplObdParam    ObdParam;
tEplSdoAddress  SdoAddress;

    // a init of a write
    // -> variable part of header possible

    // check if expedited or segmented transfer
    if ((pAsySdoCom_p->m_le_bFlags & 0x30) == 0x10)
    {   // initiate segmented transfer
        pSdoComCon_p->m_SdoTransType = kEplSdoTransSegmented;
        // get index and subindex
        pSdoComCon_p->m_uiTargetIndex = AmiGetWordFromLe(&pAsySdoCom_p->m_le_abCommandData[4]);
        pSdoComCon_p->m_uiTargetSubIndex = AmiGetByteFromLe(&pAsySdoCom_p->m_le_abCommandData[6]);
        // get source-pointer for copy
        pbSrcData = &pAsySdoCom_p->m_le_abCommandData[8];
        // save size
        pSdoComCon_p->m_uiTransSize = AmiGetDwordFromLe(&pAsySdoCom_p->m_le_abCommandData[0]);
        // subtract header
        pSdoComCon_p->m_uiTransSize -= 8;

        uiSegmentSize = AmiGetWordFromLe(&pAsySdoCom_p->m_le_wSegmentSize);
        // eleminate header (variable part/data size (4) + Command header/Index+sub-index (4))
        uiSegmentSize -= 8;
    }
    else if ((pAsySdoCom_p->m_le_bFlags & 0x30) == 0x00)
    {   // expedited transfer
        pSdoComCon_p->m_SdoTransType = kEplSdoTransExpedited;
        // get index and subindex
        pSdoComCon_p->m_uiTargetIndex = AmiGetWordFromLe(&pAsySdoCom_p->m_le_abCommandData[0]);
        pSdoComCon_p->m_uiTargetSubIndex = AmiGetByteFromLe(&pAsySdoCom_p->m_le_abCommandData[2]);
        // get source-pointer for copy
        pbSrcData = &pAsySdoCom_p->m_le_abCommandData[4];
        // save size
        pSdoComCon_p->m_uiTransSize = AmiGetWordFromLe(&pAsySdoCom_p->m_le_wSegmentSize);
        // subtract header
        pSdoComCon_p->m_uiTransSize -= 4;

        uiSegmentSize = pSdoComCon_p->m_uiTransSize;
    }
    else
    {
        // just ignore any other transfer type
        goto Exit;
    }

    // save service
    pSdoComCon_p->m_SdoServiceType = kEplSdoServiceWriteByIndex;

    pSdoComCon_p->m_uiTransferredByte = 0;
    pSdoComCon_p->m_uiCurSegOffs = 0;

    EPL_MEMSET(&SdoAddress, 0, sizeof (SdoAddress));
    SdoAddress.m_SdoAddrType = kEplSdoAddrTypeNodeId;
    SdoAddress.m_uiNodeId = pSdoComCon_p->m_uiNodeId;

    EPL_MEMSET(&ObdParam, 0, sizeof (ObdParam));
    ObdParam.m_SegmentSize = (tEplObdSize) uiSegmentSize;
    ObdParam.m_TransferSize = (tEplObdSize) pSdoComCon_p->m_uiTransSize;
    ObdParam.m_uiIndex = pSdoComCon_p->m_uiTargetIndex;
    ObdParam.m_uiSubIndex = pSdoComCon_p->m_uiTargetSubIndex;
    ObdParam.m_pData = pbSrcData;
    ObdParam.m_pHandle = pSdoComCon_p;
    ObdParam.m_pfnAccessFinished = EplSdoComServerCbExpeditedWriteFinished;
    ObdParam.m_pRemoteAddress = &SdoAddress;

    Ret = EplObdWriteEntryFromLe(&ObdParam);
    if (Ret == kEplObdAccessAdopted)
    {
        Ret = kEplSuccessful;
        if (pSdoComCon_p->m_SdoTransType == kEplSdoTransExpedited)
        {
            // send sequence layer acknowledge, because of expedited transfer
            Ret = EplSdoAsySeqSendData(pSdoComCon_p->m_SdoSeqConHdl,
                                                    0,
                                                    (tEplFrame*)NULL,
                                                    pSdoComCon_p);
        }
        goto Exit;
    }
    else if (Ret != kEplSuccessful)
    {
        if (ObdParam.m_dwAbortCode != 0)
        {
            pSdoComCon_p->m_dwLastAbortCode = ObdParam.m_dwAbortCode;
        }
        else
        {
            pSdoComCon_p->m_dwLastAbortCode = EPL_SDOAC_GENERAL_ERROR;
        }
        // send abort
        goto Abort;
    }

    // update internal counters
    pSdoComCon_p->m_uiTransferredByte = uiSegmentSize;
    pSdoComCon_p->m_uiTransSize -= uiSegmentSize;

    if (pSdoComCon_p->m_SdoTransType == kEplSdoTransExpedited)
    {   // expedited transfer
        // send command acknowledge
        Ret = EplSdoComServerSendFrameIntern(pSdoComCon_p,
                                        0,
                                        0,
                                        kEplSdoComSendTypeAckRes);
    }
    else
    {   // segmented transfer
        // send acknowledge without any Command layer data
        Ret = EplSdoAsySeqSendData(pSdoComCon_p->m_SdoSeqConHdl,
                                                0,
                                                (tEplFrame*)NULL,
                                                pSdoComCon_p);
    }

    goto Exit;

Abort:
    if (pSdoComCon_p->m_dwLastAbortCode != 0)
    {
        // send abort
        Ret = EplSdoComServerSendFrameIntern(pSdoComCon_p,
                                    pSdoComCon_p->m_uiTargetIndex,
                                    pSdoComCon_p->m_uiTargetSubIndex,
                                    kEplSdoComSendTypeAbort);

        // reset abort code
        pSdoComCon_p->m_dwLastAbortCode = 0;
        pSdoComCon_p->m_uiTransSize = 0;
        goto Exit;
    }

Exit:
    return Ret;
}
#endif

//---------------------------------------------------------------------------
//
// Function:        EplSdoComClientSend
//
// Description:    function starts an sdo transfer an send all further frames
//
//
//
// Parameters:      pSdoComCon_p     = pointer to control structure of connection
//
// Returns:         tEplKernel  =  errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
static tEplKernel EplSdoComClientSend(tEplSdoComCon* pSdoComCon_p)
{
tEplKernel      Ret;
BYTE            abFrame[EPL_SDO_MAX_TX_FRAME_SIZE];
tEplFrame*      pFrame;
tEplAsySdoCom*  pCommandFrame;
unsigned int    uiSizeOfFrame;
BYTE            bFlags;
BYTE*           pbPayload;

    Ret = kEplSuccessful;

    pFrame = (tEplFrame*)&abFrame[0];

    EPL_MEMSET(&abFrame[0], 0x00, sizeof(abFrame));

    // build generic part of frame
    // get pointer to command layerpart of frame
    pCommandFrame = &pFrame->m_Data.m_Asnd.m_Payload.m_SdoSequenceFrame.m_le_abSdoSeqPayload;
    AmiSetByteToLe( &pCommandFrame->m_le_bCommandId, pSdoComCon_p->m_SdoServiceType);
    AmiSetByteToLe( &pCommandFrame->m_le_bTransactionId, pSdoComCon_p->m_bTransactionId);

    // set size constant part of header
    uiSizeOfFrame = 8;

    // check if first frame to send -> command header needed
    if (pSdoComCon_p->m_uiTransSize > 0)
    {
        if (pSdoComCon_p->m_uiTransferredByte == 0)
        {   // start SDO transfer
            // check if segmented or expedited transfer
            // only for write commands
            switch(pSdoComCon_p->m_SdoServiceType)
            {
                case kEplSdoServiceReadByIndex:
                {   // first frame of read access always expedited
                    pSdoComCon_p->m_SdoTransType = kEplSdoTransExpedited;
                    pbPayload = &pCommandFrame->m_le_abCommandData[0];
                    // fill rest of header
                    AmiSetWordToLe( &pCommandFrame->m_le_wSegmentSize, 4);

                    // create command header
                    AmiSetWordToLe(pbPayload, (WORD)pSdoComCon_p->m_uiTargetIndex);
                    pbPayload += 2;
                    AmiSetByteToLe(pbPayload, (BYTE)pSdoComCon_p->m_uiTargetSubIndex);
                    // calc size
                    uiSizeOfFrame += 4;

                    // set pSdoComCon_p->m_uiTransferredByte to one
                    pSdoComCon_p->m_uiTransferredByte = 1;
                    break;
                }

                case kEplSdoServiceWriteByIndex:
                {
                    if(pSdoComCon_p->m_uiTransSize > (EPL_SDO_MAX_TX_SEGMENT_SIZE - 4))
                    {   // segmented transfer
                        // -> variable part of header needed
                        // save that transfer is segmented
                        pSdoComCon_p->m_SdoTransType = kEplSdoTransSegmented;
                        // fill variable part of header
                        // set data size which includes the header
                        AmiSetDwordToLe( &pCommandFrame->m_le_abCommandData[0], pSdoComCon_p->m_uiTransSize + 8);
                        // set pointer to real payload
                        pbPayload = &pCommandFrame->m_le_abCommandData[4];
                        // fill rest of header
                        AmiSetWordToLe( &pCommandFrame->m_le_wSegmentSize, EPL_SDO_MAX_TX_SEGMENT_SIZE);
                        bFlags = 0x10;
                        AmiSetByteToLe( &pCommandFrame->m_le_bFlags, bFlags);
                        // create command header
                        AmiSetWordToLe(pbPayload, (WORD) pSdoComCon_p->m_uiTargetIndex);
                        pbPayload += 2;
                        AmiSetByteToLe(pbPayload, (BYTE)pSdoComCon_p->m_uiTargetSubIndex);
                        // on byte for reserved
                        pbPayload += 2;
                        // calc size
                        uiSizeOfFrame += EPL_SDO_MAX_TX_SEGMENT_SIZE;

                        // copy payload
                        EPL_MEMCPY( pbPayload,pSdoComCon_p->m_pData,  (EPL_SDO_MAX_TX_SEGMENT_SIZE - 8));
                        pSdoComCon_p->m_pData += (EPL_SDO_MAX_TX_SEGMENT_SIZE - 8);
                        // correct intern counter
                        pSdoComCon_p->m_uiTransSize -= (EPL_SDO_MAX_TX_SEGMENT_SIZE - 8);
                        pSdoComCon_p->m_uiTransferredByte = (EPL_SDO_MAX_TX_SEGMENT_SIZE - 8);

                    }
                    else
                    {   // expedited trandsfer
                        // save that transfer is expedited
                        pSdoComCon_p->m_SdoTransType = kEplSdoTransExpedited;
                        pbPayload = &pCommandFrame->m_le_abCommandData[0];

                        // create command header
                        AmiSetWordToLe(pbPayload, (WORD) pSdoComCon_p->m_uiTargetIndex);
                        pbPayload += 2;
                        AmiSetByteToLe(pbPayload, (BYTE)pSdoComCon_p->m_uiTargetSubIndex);
                        // + 2 -> one byte for subindex and one byte reserved
                        pbPayload += 2;
                        // copy data
                        EPL_MEMCPY( pbPayload,pSdoComCon_p->m_pData,  pSdoComCon_p->m_uiTransSize);
                        // calc size
                        uiSizeOfFrame += (4 + pSdoComCon_p->m_uiTransSize);
                        // fill rest of header
                        AmiSetWordToLe( &pCommandFrame->m_le_wSegmentSize, (WORD) (4 + pSdoComCon_p->m_uiTransSize));

                        pSdoComCon_p->m_uiTransferredByte = pSdoComCon_p->m_uiTransSize;
                        pSdoComCon_p->m_uiTransSize = 0;
                    }
                    break;
                }

                case kEplSdoServiceNIL:
                default:
                    // invalid service requested
                    Ret = kEplSdoComInvalidServiceType;
                    goto Exit;
            } // end of switch(pSdoComCon_p->m_SdoServiceType)
        }
        else // (pSdoComCon_p->m_uiTransferredByte > 0)
        {   // continue SDO transfer
            switch(pSdoComCon_p->m_SdoServiceType)
            {
                // for expedited read is nothing to do
                // -> server sends data

                case kEplSdoServiceWriteByIndex:
                {   // send next frame
                    if(pSdoComCon_p->m_SdoTransType == kEplSdoTransSegmented)
                    {
                        if(pSdoComCon_p->m_uiTransSize > EPL_SDO_MAX_TX_SEGMENT_SIZE)
                        {   // next segment
                            pbPayload = &pCommandFrame->m_le_abCommandData[0];
                            // fill rest of header
                            AmiSetWordToLe( &pCommandFrame->m_le_wSegmentSize, EPL_SDO_MAX_TX_SEGMENT_SIZE);
                            bFlags = 0x20;
                            AmiSetByteToLe( &pCommandFrame->m_le_bFlags, bFlags);
                            // copy data
                            EPL_MEMCPY( pbPayload,pSdoComCon_p->m_pData,  EPL_SDO_MAX_TX_SEGMENT_SIZE);
                            pSdoComCon_p->m_pData += EPL_SDO_MAX_TX_SEGMENT_SIZE;
                            // correct intern counter
                            pSdoComCon_p->m_uiTransSize -= EPL_SDO_MAX_TX_SEGMENT_SIZE;
                            pSdoComCon_p->m_uiTransferredByte += EPL_SDO_MAX_TX_SEGMENT_SIZE;
                            // calc size
                            uiSizeOfFrame += EPL_SDO_MAX_TX_SEGMENT_SIZE;


                        }
                        else
                        {   // end of transfer
                            pbPayload = &pCommandFrame->m_le_abCommandData[0];
                            // fill rest of header
                            AmiSetWordToLe( &pCommandFrame->m_le_wSegmentSize, (WORD) pSdoComCon_p->m_uiTransSize);
                            bFlags = 0x30;
                            AmiSetByteToLe( &pCommandFrame->m_le_bFlags, bFlags);
                            // copy data
                            EPL_MEMCPY( pbPayload,pSdoComCon_p->m_pData,  pSdoComCon_p->m_uiTransSize);
                            pSdoComCon_p->m_pData += pSdoComCon_p->m_uiTransSize;
                            // calc size
                            uiSizeOfFrame += pSdoComCon_p->m_uiTransSize;
                            // correct intern counter
                            pSdoComCon_p->m_uiTransSize = 0;
                            pSdoComCon_p->m_uiTransferredByte += pSdoComCon_p->m_uiTransSize;

                        }
                    }
                    else
                    {
                        goto Exit;
                    }
                    break;
                }
                default:
                {
                    goto Exit;
                }
            } // end of switch(pSdoComCon_p->m_SdoServiceType)
        }
    }
    else
    {
        goto Exit;
    }


    // call send function of lower layer
    switch(pSdoComCon_p->m_SdoProtType)
    {
        case kEplSdoTypeAsnd:
        case kEplSdoTypeUdp:
        {
            Ret = EplSdoAsySeqSendData(pSdoComCon_p->m_SdoSeqConHdl,
                                        uiSizeOfFrame,
                                        pFrame);
            break;
        }

#ifdef EPL_MODULE_API_PDI
        case kEplSdoTypeApiPdi:
        {
            tPdiAsyncStatus PdiRet = kPdiAsyncStatusSuccessful;
            tObjAccSdoComCon PdiObjAccCon;

            PdiObjAccCon.m_wObdAccConNum = pSdoComCon_p->m_SdoSeqConHdl;///< SDO command layer connection handle number
            PdiObjAccCon.m_pSdoCmdFrame = (tEplAsySdoCom *) pCommandFrame;     ///< pointer to SDO command frame
            PdiObjAccCon.m_uiSizeOfFrame = uiSizeOfFrame;                 ///< size of SDO command frame

            PdiRet = CnApiAsync_postMsg(
                            kPdiAsyncMsgIntObjAccReq,
                            (BYTE *) &PdiObjAccCon,
                            NULL,
                            NULL,
                            NULL,
                            0);

            if (PdiRet == kPdiAsyncStatusRetry)
            {
                Ret = kEplSdoSeqConnectionBusy;
            }
            else if (PdiRet != kPdiAsyncStatusSuccessful)
            {
                Ret = kEplInvalidOperation;
            }

            break;
        }
#endif // EPL_MODULE_API_PDI

        default:
        {
            Ret = kEplSdoComUnsupportedProt;
        }
    } // end of switch(pSdoComCon_p->m_SdoProtType)


Exit:
    return Ret;

}
#endif
//---------------------------------------------------------------------------
//
// Function:        EplSdoComClientProcessFrame
//
// Description:    function process a received frame
//
//
//
// Parameters:      SdoComCon_p      = connection handle
//                  pAsySdoCom_p     = pointer to frame to process
//
// Returns:         tEplKernel  =  errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
static tEplKernel EplSdoComClientProcessFrame(tEplSdoComConHdl   SdoComCon_p,
                                              tEplAsySdoCom*     pAsySdoCom_p)
{
tEplKernel          Ret;
BYTE                bBuffer;
unsigned int        uiBuffer;
unsigned int        uiDataSize;
unsigned long       ulBuffer;
tEplSdoComCon*      pSdoComCon;


    Ret = kEplSuccessful;

    // get pointer to control structure
    pSdoComCon = &SdoComInstance_g.m_SdoComCon[SdoComCon_p];

    // check if transaction Id fit
    bBuffer = AmiGetByteFromLe(&pAsySdoCom_p->m_le_bTransactionId);
    if(pSdoComCon->m_bTransactionId != bBuffer)
    {
        // incorrect transaction id

        // if running transfer
        if((pSdoComCon->m_uiTransferredByte != 0)
            && (pSdoComCon->m_uiTransSize !=0))
        {
            pSdoComCon->m_dwLastAbortCode = EPL_SDOAC_GENERAL_ERROR;
            // -> send abort
            EplSdoComClientSendAbort(pSdoComCon, pSdoComCon->m_dwLastAbortCode);
            // call callback of application
            Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferTxAborted);
        }

    }
    else
    {   // check if correct command
        bBuffer = AmiGetByteFromLe(&pAsySdoCom_p->m_le_bCommandId);
        if(pSdoComCon->m_SdoServiceType != bBuffer)
        {
            // incorrect command
            // if running transfer
            if((pSdoComCon->m_uiTransferredByte != 0)
                && (pSdoComCon->m_uiTransSize !=0))
            {
                pSdoComCon->m_dwLastAbortCode = EPL_SDOAC_GENERAL_ERROR;
                // -> send abort
                EplSdoComClientSendAbort(pSdoComCon, pSdoComCon->m_dwLastAbortCode);
                // call callback of application
                Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferTxAborted);
            }

        }
        else
        {   // switch on command
            switch(pSdoComCon->m_SdoServiceType)
            {
                case kEplSdoServiceWriteByIndex:
                {   // check if confirmation from server
                    // nothing more to do
                    break;
                }

                case kEplSdoServiceReadByIndex:
                {   // check if it is an segmented or an expedited transfer
                    bBuffer = AmiGetByteFromLe(&pAsySdoCom_p->m_le_bFlags);
                    // mask uninteressting bits
                    bBuffer &= 0x30;
                    switch (bBuffer)
                    {
                        // expedited transfer
                        case 0x00:
                        {
                            // check size of buffer
                            uiBuffer = AmiGetWordFromLe(&pAsySdoCom_p->m_le_wSegmentSize);
                            if (uiBuffer > pSdoComCon->m_uiTransSize)
                            {   // buffer provided by the application is too small
                                // copy only a part
                                uiDataSize = pSdoComCon->m_uiTransSize;
                            }
                            else
                            {   // buffer fits
                                uiDataSize = uiBuffer;
                            }

                            // copy data
                            EPL_MEMCPY(pSdoComCon->m_pData, &pAsySdoCom_p->m_le_abCommandData[0], uiDataSize);

                            // correct counter
                            pSdoComCon->m_uiTransSize = 0;
                            pSdoComCon->m_uiTransferredByte = uiDataSize;
                            break;
                        }

                        // start of a segmented transfer
                        case 0x10:
                        {   // get total size of transfer including the header
                            ulBuffer = AmiGetDwordFromLe(&pAsySdoCom_p->m_le_abCommandData[0]);
                            // subtract size of variable header from data size
                            ulBuffer -= 4;
                            if (ulBuffer <= pSdoComCon->m_uiTransSize)
                            {   // buffer fits
                                pSdoComCon->m_uiTransSize = (unsigned int)ulBuffer;
                            }
                            else
                            {   // buffer too small
                                // send abort
                                pSdoComCon->m_dwLastAbortCode = EPL_SDOAC_DATA_TYPE_LENGTH_TOO_HIGH;
                                // -> send abort
                                EplSdoComClientSendAbort(pSdoComCon, pSdoComCon->m_dwLastAbortCode);
                                // call callback of application
                                Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferTxAborted);
                                goto Exit;
                            }

                            // get segment size
                            // check size of buffer
                            uiBuffer = AmiGetWordFromLe(&pAsySdoCom_p->m_le_wSegmentSize);
                            // subtract size of variable header from segment size
                            uiBuffer -= 4;
                            // copy data
                            EPL_MEMCPY(pSdoComCon->m_pData, &pAsySdoCom_p->m_le_abCommandData[4], uiBuffer);

                            // correct counter an pointer
                            pSdoComCon->m_pData += uiBuffer;
                            pSdoComCon->m_uiTransferredByte = uiBuffer;
                            pSdoComCon->m_uiTransSize -= uiBuffer;

                            break;
                        }

                        // segment
                        case 0x20:
                        {
                            // get segment size
                            // check size of buffer
                            uiBuffer = AmiGetWordFromLe(&pAsySdoCom_p->m_le_wSegmentSize);
                            // check if data to copy fit to buffer
                            if (uiBuffer > pSdoComCon->m_uiTransSize)
                            {   // segment too large
                                // send abort
                                pSdoComCon->m_dwLastAbortCode = EPL_SDOAC_INVALID_BLOCK_SIZE;
                                // -> send abort
                                EplSdoComClientSendAbort(pSdoComCon, pSdoComCon->m_dwLastAbortCode);
                                // call callback of application
                                Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferTxAborted);
                                goto Exit;
                            }
                            // copy data
                            EPL_MEMCPY(pSdoComCon->m_pData, &pAsySdoCom_p->m_le_abCommandData[0], uiBuffer);

                            // correct counter an pointer
                            pSdoComCon->m_pData += uiBuffer;
                            pSdoComCon->m_uiTransferredByte += uiBuffer;
                            pSdoComCon->m_uiTransSize -= uiBuffer;
                            break;
                        }

                        // last segment
                        case 0x30:
                        {
                            // get segment size
                            // check size of buffer
                            uiBuffer = AmiGetWordFromLe(&pAsySdoCom_p->m_le_wSegmentSize);
                            // check if data to copy fit to buffer
                            if(uiBuffer > pSdoComCon->m_uiTransSize)
                            {   // segment too large
                                // send abort
                                pSdoComCon->m_dwLastAbortCode = EPL_SDOAC_INVALID_BLOCK_SIZE;
                                // -> send abort
                                EplSdoComClientSendAbort(pSdoComCon, pSdoComCon->m_dwLastAbortCode);
                                // call callback of application
                                Ret = EplSdoComTransferFinished(SdoComCon_p, pSdoComCon, kEplSdoComTransferTxAborted);
                                goto Exit;
                            }
                            // copy data
                            EPL_MEMCPY(pSdoComCon->m_pData, &pAsySdoCom_p->m_le_abCommandData[0], uiBuffer);

                            // correct counter an pointer
                            pSdoComCon->m_pData += uiBuffer;
                            pSdoComCon->m_uiTransferredByte += uiBuffer;
                            pSdoComCon->m_uiTransSize  = 0;

                            break;
                        }
                    }// end of switch(bBuffer & 0x30)

                    break;
                }

                case kEplSdoServiceNIL:
                default:
                    // invalid service requested
                    // $$$ d.k. What should we do?
                    break;
            }// end of switch(pSdoComCon->m_SdoServiceType)
        }
    }

Exit:
    return Ret;
}
#endif

//---------------------------------------------------------------------------
//
// Function:    EplSdoComClientSendAbort
//
// Description: function send a abort message
//
//
//
// Parameters:  pSdoComCon_p     = pointer to control structure of connection
//              dwAbortCode_p    = Sdo abort code
//
// Returns:     tEplKernel  =  errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
static tEplKernel EplSdoComClientSendAbort(tEplSdoComCon* pSdoComCon_p,
                                           DWORD          dwAbortCode_p)
{
tEplKernel      Ret;
BYTE            abFrame[EPL_SDO_MAX_TX_FRAME_SIZE];
tEplFrame*      pFrame;
tEplAsySdoCom*  pCommandFrame;
unsigned int    uiSizeOfFrame;

    Ret = kEplSuccessful;

    pFrame = (tEplFrame*)&abFrame[0];

    EPL_MEMSET(&abFrame[0], 0x00, sizeof(abFrame));

    // build generic part of frame
    // get pointer to command layerpart of frame
    pCommandFrame = &pFrame->m_Data.m_Asnd.m_Payload.m_SdoSequenceFrame.m_le_abSdoSeqPayload;
    AmiSetByteToLe( &pCommandFrame->m_le_bCommandId, pSdoComCon_p->m_SdoServiceType);
    AmiSetByteToLe( &pCommandFrame->m_le_bTransactionId, pSdoComCon_p->m_bTransactionId);

    uiSizeOfFrame = 8;

    // set response and abort flag
    pCommandFrame->m_le_bFlags |= 0x40;

    // copy abortcode to frame
    AmiSetDwordToLe(&pCommandFrame->m_le_abCommandData[0], dwAbortCode_p);

    // set size of segment
    AmiSetWordToLe(&pCommandFrame->m_le_wSegmentSize, sizeof(DWORD));

    // update counter
    pSdoComCon_p->m_uiTransferredByte = sizeof(DWORD);
    pSdoComCon_p->m_uiTransSize = 0;

    // calc framesize
    uiSizeOfFrame += sizeof(DWORD);

    // save abort code
    pSdoComCon_p->m_dwLastAbortCode = dwAbortCode_p;

    // call send function of lower layer
    switch(pSdoComCon_p->m_SdoProtType)
    {
        case kEplSdoTypeAsnd:
        case kEplSdoTypeUdp:
        {
            Ret = EplSdoAsySeqSendData(pSdoComCon_p->m_SdoSeqConHdl,
                                        uiSizeOfFrame,
                                        pFrame);
            if (Ret == kEplSdoSeqConnectionBusy)
            {
                DEBUG_TRACE2(DEBUG_LVL_CNAPI_INFO,"%s tried to send abort 0x%lX while connection is already closed\n",
                    __func__, (unsigned long) dwAbortCode_p);
                Ret = kEplSuccessful;
            }
            break;
        }

#ifdef EPL_MODULE_API_PDI
        case kEplSdoTypeApiPdi:
        {
            tPdiAsyncStatus PdiRet = kPdiAsyncStatusSuccessful;
            tObjAccSdoComCon PdiObjAccCon;

            PdiObjAccCon.m_wObdAccConNum = pSdoComCon_p->m_SdoSeqConHdl;///< SDO command layer connection handle number
            PdiObjAccCon.m_pSdoCmdFrame = (tEplAsySdoCom *)pFrame;     ///< pointer to SDO command frame
            PdiObjAccCon.m_uiSizeOfFrame = uiSizeOfFrame;                 ///< size of SDO command frame

            PdiRet = CnApiAsync_postMsg(
                            kPdiAsyncMsgIntObjAccReq,
                            (BYTE *) &PdiObjAccCon,
                            NULL,
                            NULL,
                            NULL,
                            0);

            if (PdiRet == kPdiAsyncStatusRetry)
            {
                Ret = kEplSdoSeqConnectionBusy;
            }
            else if (PdiRet != kPdiAsyncStatusSuccessful)
            {
                Ret = kEplInvalidOperation;
            }

            break;
        }
#endif // EPL_MODULE_API_PDI

        default:
        {
            Ret = kEplSdoComUnsupportedProt;
        }
    } // end of switch(pSdoComCon_p->m_SdoProtType)


    return Ret;
}

//---------------------------------------------------------------------------
//
// Function:    EplSdoComTransferFinished
//
// Description: calls callback function of application if available
//              and clears entry in control structure
//
// Parameters:  pSdoComCon_p     = pointer to control structure of connection
//              SdoComConState_p = state of SDO transfer
//
// Returns:     tEplKernel  =  errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
static tEplKernel EplSdoComTransferFinished(tEplSdoComConHdl   SdoComCon_p,
                                            tEplSdoComCon*     pSdoComCon_p,
                                            tEplSdoComConState SdoComConState_p)
{
tEplKernel      Ret;

    Ret = kEplSuccessful;

    if(pSdoComCon_p->m_pfnTransferFinished != NULL)
    {
    tEplSdoFinishedCb   pfnTransferFinished;
    tEplSdoComFinished  SdoComFinished;

        SdoComFinished.m_pUserArg = pSdoComCon_p->m_pUserArg;
        SdoComFinished.m_uiNodeId = pSdoComCon_p->m_uiNodeId;
        SdoComFinished.m_uiTargetIndex = pSdoComCon_p->m_uiTargetIndex;
        SdoComFinished.m_uiTargetSubIndex = pSdoComCon_p->m_uiTargetSubIndex;
        SdoComFinished.m_uiTransferredByte = pSdoComCon_p->m_uiTransferredByte;
        SdoComFinished.m_dwAbortCode = pSdoComCon_p->m_dwLastAbortCode;
        SdoComFinished.m_SdoComConHdl = SdoComCon_p;
        SdoComFinished.m_SdoComConState = SdoComConState_p;
        if (pSdoComCon_p->m_SdoServiceType == kEplSdoServiceWriteByIndex)
        {
            SdoComFinished.m_SdoAccessType = kEplSdoAccessTypeWrite;
        }
        else
        {
            SdoComFinished.m_SdoAccessType = kEplSdoAccessTypeRead;
        }

        // reset transfer state so this handle is not busy anymore
        pSdoComCon_p->m_uiTransferredByte = 0;
        pSdoComCon_p->m_uiTransSize = 0;

        pfnTransferFinished = pSdoComCon_p->m_pfnTransferFinished;
        // delete function pointer to inform application only once for each transfer
        pSdoComCon_p->m_pfnTransferFinished = NULL;

        // call application's callback function
        pfnTransferFinished(&SdoComFinished);

    }

    return Ret;
}
#endif // (((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)

// EOF

