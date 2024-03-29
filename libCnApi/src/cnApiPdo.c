/**
********************************************************************************
\file       cnApiPdo.c

\brief      CN API PDO functions

This module handles the process data object handling inside the libCnApi.

Copyright � 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include <cnApi.h>
#include <string.h>

#include "cnApiIntern.h"
#include "cnApiEventIntern.h"
#include "cnApiPdo.h"
#include "cnApiAsync.h"
#include "cnApiObjectIntern.h"

#ifdef CN_API_USING_SPI
  #include "cnApiPdiSpiIntern.h"
#endif

#include "cnApiAmi.h"



/******************************************************************************/
/* defines */
// max copy table elements per PDO
#define PDO_COPY_TBL_ELEMENTS   MAX_MAPPABLE_OBJECTS_PER_PDO_CHANNEL

/******************************************************************************/
/* typedefs */
typedef struct sPdoCopyTblEntry {
    BYTE *  pAdrs_m;        ///< source or target pointer
    WORD    size_m;         ///< data size
    WORD    wPdoOfst;       ///< PDO buffer offset
} tPdoCopyTblEntry;

typedef struct sPdoCpyTbl {
   BYTE                 bNumOfEntries_m;
   BYTE                 bMapVersion_m;      ///< MappingVersion_U8 of PDO channel
   BOOL                 fActivated_m;
   tPdoCopyTblEntry     aEntry_m[PDO_COPY_TBL_ELEMENTS];
} tPdoCopyTbl;

typedef enum eTypes {
    kCnApiTypByte = 1,
    kCnApiTypWord = 2,
    kCnApiTypInt24 = 3,
    kCnApiTypDword = 4,
    kCnApiTypInt40 = 5,
    kCnApiTypInt48 = 6,
    kCnApiTypInt56 = 7,
    kCnApiTypQWord = 8,
} tTypes;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
static tLinkPdosResp LinkPdosResp_l;           ///< Link Pdos Response message

static tTPdoBuffer aTPdosPdi_l[PCP_PDI_TPDO_CHANNELS];
static tRPdoBuffer aRPdosPdi_l[PCP_PDI_RPDO_CHANNELS];

static  WORD                wCntMappedNotLinkedObj_l;    ///< counter of mapped but not linked objects
static  tPdoCopyTbl         aTxPdoCopyTbl_l[PCP_PDI_TPDO_CHANNELS];
static  tPdoCopyTbl         aRxPdoCopyTbl_l[PCP_PDI_RPDO_CHANNELS];

// global pointer to the sync callback
static tCnApiAppCbSync      pfnAppCbSync_l = NULL;

static tCnApiCbPdoDesc        pfnPdoDescriptor_l = NULL;

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */
static inline void CopyVarConvertEndian(BYTE* pDest_p,
                                        BYTE* pSrc_p,
                                        WORD wSize_p,
                                        BYTE fDoRcv_p);
static BOOL CnApi_configurePdoChannel(tPdoDescHeader        *pPdoDesc_p,
                                  BYTE              bDescrEntries_p,
                                  BYTE              bDirection_p,
                                  BYTE                 bPdoBufNum_p,
                                  BYTE                    bMapVers_p);
static tPdiAsyncStatus CnApi_sendPdoResp(BYTE bMsgId_p,
                                         BYTE bOrigin_p,
                                         WORD wObdAccConHdl_p,
                                         DWORD dwErrorCode_p);
static void CnApi_getCurTime(tCnApiTimeStamp *TimeStamp_p);
static void CnApi_transmitPdo(void);
static void CnApi_receivePdo(void);
static inline void CnApi_ackPdoBuffer(BYTE* pAckReg_p);
static tCnApiStatus CnApi_readPdoDesc(tPdoDescHeader * pPdoDescHeader_p);

/**
********************************************************************************
\brief    CopyVarConvertEndian

Copies a data from the source to the destination field and converts the endianess
regarding the format of the input data

\param  pDest_p          Destination field for the converted data
\param  pSrc_p           Source field of the input data
\param    wSize_p          Size of the field
\param    fDoRcv_p         This flag signals if data is received or transmitted from the PDI
*******************************************************************************/

static inline void CopyVarConvertEndian(BYTE* pDest_p,
                                        BYTE* pSrc_p,
                                        WORD wSize_p,
                                        BYTE fDoRcv_p)
{

    switch (wSize_p)
    {
        case kCnApiTypByte:
        {
#ifdef CN_API_USING_SPI
            if(fDoRcv_p != FALSE)
                CnApi_Spi_readByte((DWORD)pSrc_p,pDest_p);
            else
                CnApi_Spi_writeByte((DWORD)pDest_p,*(BYTE*)pSrc_p);
#else
            AmiSetByteToLe(pDest_p, *((BYTE*)pSrc_p));
#endif
            break;
        }
        case kCnApiTypWord:
        {
#ifdef CN_API_USING_SPI
            if(fDoRcv_p != FALSE)
                CnApi_Spi_readWord((DWORD)pSrc_p,(WORD *)pDest_p,CNAPI_BIG_ENDIAN);
            else
                CnApi_Spi_writeWord((DWORD)pDest_p,*((WORD *)pSrc_p),CNAPI_BIG_ENDIAN);
#else
            AmiSetWordToLe(pDest_p, *((WORD*)pSrc_p));
#endif
            break;
        }
#ifndef CN_API_USING_SPI
        case kCnApiTypInt24:
        {
            AmiSetDword24ToLe(pDest_p, *((DWORD*)pSrc_p));
            break;
        }
#endif
        case kCnApiTypDword:
        {
#ifdef CN_API_USING_SPI
            if(fDoRcv_p != FALSE)
                CnApi_Spi_readDword((DWORD)pSrc_p,(DWORD *)pDest_p,CNAPI_BIG_ENDIAN);
            else
                CnApi_Spi_writeDword((DWORD)pDest_p,*((DWORD *)pSrc_p),CNAPI_BIG_ENDIAN);
#else
            AmiSetDwordToLe(pDest_p, *((DWORD*)pSrc_p));
#endif
            break;
        }
#ifndef CN_API_USING_SPI
        case kCnApiTypInt40:
        {
            AmiSetQword40ToLe(pDest_p, *((DWORD*)pSrc_p));
            break;
        }
        case kCnApiTypInt48:
        {
            AmiSetQword48ToLe(pDest_p, *((DWORD*)pSrc_p));
            break;
        }
        case kCnApiTypInt56:
        {
            AmiSetQword56ToLe(pDest_p, *((DWORD*)pSrc_p));
            break;
        }
#endif
        case kCnApiTypQWord:
        {
#ifdef CN_API_USING_SPI
            if(fDoRcv_p != FALSE)
                CnApi_Spi_readQword((DWORD)pSrc_p,(QWORD *)pDest_p,CNAPI_BIG_ENDIAN);
            else
                CnApi_Spi_writeQword((DWORD)pDest_p,*pSrc_p,CNAPI_BIG_ENDIAN);
#else
            AmiSetQword64ToLe(pDest_p, *((QWORD*)pSrc_p));
#endif
            break;
        }
        default:
        {
#ifdef CN_API_USING_SPI
            if(fDoRcv_p != FALSE)
                CnApi_Spi_read((DWORD)pSrc_p,wSize_p,pDest_p);
            else
                CnApi_Spi_write((DWORD)pDest_p,wSize_p,pSrc_p);
#else
            //copy them without conversion
            CNAPI_MEMCPY (pDest_p, pSrc_p, wSize_p);
#endif
            break;
        }
    }
}

/**
********************************************************************************
\brief  configure PDO channel

Setup the data copy table for TPDO or RPDO according to the descriptor.
The PDO channel (copying) will be activated or deactivated according to
bDescrEntries_p.
The descriptor is compared with the local object link table.
Not stated objects in local table will be ignored.

\param  pPdoDesc_p          pointer to PDO descriptor
\param  bDescrEntries_p     Number of entries of the PDO descriptor
                              0: deactivate
                             >0: activate
\param    bDirection_p        Copy direction (read/write) of this copy table
\param    bPdoBufNum_p        PDO buffer number of one direction
\param  bMapVers_p          mapping version of PDO channel (MappingVersion_U8)
\return FALSE if error occurred, else TRUE
*******************************************************************************/
static BOOL CnApi_configurePdoChannel(tPdoDescHeader        *pPdoDesc_p,
                                  BYTE              bDescrEntries_p,
                                  BYTE              bDirection_p,
                                  BYTE                 bPdoBufNum_p,
                                  BYTE                    bMapVers_p)
{
    int iCnt = 0;
    WORD   wTblNum = 0;
    tPdoDescEntry    *pDescEntry;
    tPdoCopyTbl   *pCopyTbl;
    BYTE    *pbCpyTblEntries;
    tPdoDir PdoDir;
    WORD    wObjSize;
    BYTE    *pObjAdrs;
    BOOL fRet = TRUE;

    PdoDir = (tPdoDir) bDirection_p;

    if(bDescrEntries_p > PDO_COPY_TBL_ELEMENTS)
    {
        DEBUG_TRACE3(DEBUG_LVL_CNAPI_ERR, "Error in %s:"
                     "\nCopy table size of PDO Buffer %d too small"
                     " for count of descriptor elements (%d)!\n"
                     "Skipping copy table setup!\n", __func__, bPdoBufNum_p, bDescrEntries_p);
        fRet = FALSE;
        goto exit;
    }


    /* select copy table */
    if (PdoDir == TPdo)
    {
        pCopyTbl = &aTxPdoCopyTbl_l[bPdoBufNum_p];
        pbCpyTblEntries = &aTxPdoCopyTbl_l[bPdoBufNum_p].bNumOfEntries_m;
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_PDO_INFO, "Setup copy table for TPDO %d :\n", bPdoBufNum_p);
    }
    else if(PdoDir == RPdo)
    {
        pCopyTbl = &aRxPdoCopyTbl_l[bPdoBufNum_p];
        pbCpyTblEntries = &aRxPdoCopyTbl_l[bPdoBufNum_p].bNumOfEntries_m;
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_PDO_INFO, "Setup copy table for RPDO %d :\n", bPdoBufNum_p);
    }
    else
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "\nError in %s:"
                     "\nDescriptor has no valid direction! Skipping copy table for this PDO.\n", __func__);
        fRet = FALSE;
        goto exit;
    }

    if (0 == bDescrEntries_p)
    {   //deactivate PDO channel
        pCopyTbl->fActivated_m = FALSE;
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_PDO_INFO, "MapVers:%d , PDO deactivated.\n", pCopyTbl->bMapVersion_m);
        goto exit;
    }

    /* prepare loop */
    *pbCpyTblEntries = 0;
    pDescEntry = (tPdoDescEntry*) ((BYTE*) pPdoDesc_p + sizeof(tPdoDescHeader)); // first element

    /* check if indices exist locally and setup copy table */
    while(iCnt < bDescrEntries_p)
    {
#ifdef AP_IS_BIG_ENDIAN
      pDescEntry->m_wPdoIndex = AmiGetWordFromLe((BYTE*)&(pDescEntry->m_wPdoIndex));
      pDescEntry->m_wOffset = AmiGetWordFromLe((BYTE*)&(pDescEntry->m_wOffset));
      pDescEntry->m_wSize = AmiGetWordFromLe((BYTE*)&(pDescEntry->m_wSize));
#endif

        /* if object line up matches then acquire data pointer and size information from the linking table */
        fRet = CnApi_getObjectParam(pDescEntry->m_wPdoIndex, pDescEntry->m_bPdoSubIndex, &wObjSize, &pObjAdrs);
        if (fRet == FALSE                ||
            wObjSize != pDescEntry->m_wSize)
        {
            /* skip this copy table element */
            DEBUG_TRACE2(DEBUG_LVL_CNAPI_ERR,"Couldn't find descriptor object 0x%04x/0x%02x"
                    " in local object table!\n", pDescEntry->m_wPdoIndex,
                                                 pDescEntry->m_bPdoSubIndex);
            pCopyTbl->aEntry_m[wTblNum].pAdrs_m = 0;
            pCopyTbl->aEntry_m[wTblNum].size_m = 0;
            wCntMappedNotLinkedObj_l++;
        }
        else
        {   /* assign copy table element values */
            pCopyTbl->aEntry_m[wTblNum].pAdrs_m = (BYTE*)pObjAdrs;
            pCopyTbl->aEntry_m[wTblNum].size_m = pDescEntry->m_wSize;
            pCopyTbl->aEntry_m[wTblNum].wPdoOfst = pDescEntry->m_wOffset;
            wTblNum++;
            (*pbCpyTblEntries)++;

            DEBUG_TRACE3(DEBUG_LVL_CNAPI_PDO_INFO,"0x%04x/0x%02x"
                        " size %d \n", pDescEntry->m_wPdoIndex, pDescEntry->m_bPdoSubIndex, wObjSize);
        }

        /* prepare next loop */
        pDescEntry++;
        iCnt++;
    }

    //activate PDO channel
    pCopyTbl->fActivated_m = TRUE;

    // update mapping version
    pCopyTbl->bMapVersion_m = bMapVers_p;

    DEBUG_TRACE1(DEBUG_LVL_CNAPI_PDO_INFO, "MapVers:%d , PDO activated.\n", pCopyTbl->bMapVersion_m);

    fRet = TRUE;
exit:
    return fRet;
}

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief    initialize pdo module

\param    pCtrlReg_p         pointer to the control register
\param    pfnAppCbSync_p     function pointer to AppCbSync callback function
\param    pDpramBase_p       pointer to Dpram base address
\param    pfnPdoDescriptor_p function pointer to the pdo descriptor callback

\return     int
\retval     OK                 on success
\retval     ERROR              in case of an error

CnApi_initPdo() is used to initialize the PDO module.
*******************************************************************************/
int CnApi_initPdo(tPcpCtrlReg *pCtrlReg_p,
        tCnApiAppCbSync pfnAppCbSync_p,
        BYTE * pDpramBase_p,
        tCnApiCbPdoDesc pfnPdoDescriptor_p)
{
    register WORD wCnt;

    if(pfnAppCbSync_p != NULL)
    {
        pfnAppCbSync_l = pfnAppCbSync_p;
    } else {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "Error in %s: AppCbSync callback is not initialised\n", __func__);
        goto exit;
    }

    // ingnore if pdo descritptor callback is null and make it local
    pfnPdoDescriptor_l = pfnPdoDescriptor_p;

    /* group TPDO PDI channels address, size and acknowledge settings */
#if (PCP_PDI_TPDO_CHANNELS >= 1)
    aTPdosPdi_l[0].pAdrs_m = (BYTE*) (pDpramBase_p + AmiGetWordFromLe((BYTE*)&(pCtrlReg_p->m_wTxPdo0BufAoffs)));
    aTPdosPdi_l[0].wSize_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_p->m_wTxPdo0BufSize));
    aTPdosPdi_l[0].pAck_m = (BYTE*) (&pCtrlReg_p->m_wTxPdo0Ack);

    #ifdef CN_API_USING_SPI
    aTPdosPdi_l[0].dwSpiBufOffs_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_p->m_wTxPdo0BufAoffs));
    aTPdosPdi_l[0].wSpiAckOffs_m = PCP_CTRLREG_TPDO_0_ACK_OFFSET;
    #endif /* CN_API_USING_SPI */
#endif /* TPDO_CHANNELS_MAX >= 1 */

    /* group RPDO PDI channels address, size and acknowledge settings */
#if (PCP_PDI_RPDO_CHANNELS >= 1)
    aRPdosPdi_l[0].pAdrs_m = (BYTE*) (pDpramBase_p + AmiGetWordFromLe((BYTE*)&(pCtrlReg_p->m_wRxPdo0BufAoffs)));
    aRPdosPdi_l[0].wSize_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_p->m_wRxPdo0BufSize));
    aRPdosPdi_l[0].pAck_m = (BYTE*) (&pCtrlReg_p->m_wRxPdo0Ack);

    #ifdef CN_API_USING_SPI
    aRPdosPdi_l[0].dwSpiBufOffs_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_p->m_wRxPdo0BufAoffs));
    aRPdosPdi_l[0].wSpiAckOffs_m = PCP_CTRLREG_RPDO_0_ACK_OFFSET;
    #endif /* CN_API_USING_SPI */
#endif /* RPDO_CHANNELS_MAX >= 1 */

#if (PCP_PDI_RPDO_CHANNELS >= 2)
    aRPdosPdi_l[1].pAdrs_m = (BYTE*) (pDpramBase_p + AmiGetWordFromLe((BYTE*)&(pCtrlReg_p->m_wRxPdo1BufAoffs)));
    aRPdosPdi_l[1].wSize_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_p->m_wRxPdo1BufSize));
    aRPdosPdi_l[1].pAck_m = (BYTE*) (&pCtrlReg_p->m_wRxPdo1Ack);

    #ifdef CN_API_USING_SPI
    aRPdosPdi_l[1].dwSpiBufOffs_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_p->m_wRxPdo1BufAoffs));
    aRPdosPdi_l[1].wSpiAckOffs_m = PCP_CTRLREG_RPDO_1_ACK_OFFSET;
    #endif /* CN_API_USING_SPI */
#endif /* RPDO_CHANNELS_MAX >= 2 */

#if (PCP_PDI_RPDO_CHANNELS >= 3)
    aRPdosPdi_l[2].pAdrs_m = (BYTE*) (pDpramBase_p + AmiGetWordFromLe((BYTE*)&(pCtrlReg_p->m_wRxPdo2BufAoffs)));
    aRPdosPdi_l[2].wSize_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_p->m_wRxPdo2BufSize));
    aRPdosPdi_l[2].pAck_m = (BYTE*) (&pCtrlReg_p->m_wRxPdo2Ack);

    #ifdef CN_API_USING_SPI
    aRPdosPdi_l[2].dwSpiBufOffs_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_p->m_wRxPdo2BufAoffs));
    aRPdosPdi_l[2].wSpiAckOffs_m = PCP_CTRLREG_RPDO_2_ACK_OFFSET;
    #endif /* CN_API_USING_SPI */
#endif /* RPDO_CHANNELS_MAX >= 3 */


for (wCnt = 0; wCnt < PCP_PDI_TPDO_CHANNELS; ++wCnt)
{
    if ((aTPdosPdi_l[wCnt].pAdrs_m == NULL) ||
        (aTPdosPdi_l[wCnt].wSize_m == 0)    ||
        (aTPdosPdi_l[wCnt].pAck_m ==  NULL)   )
    {
        DEBUG_TRACE2(DEBUG_LVL_CNAPI_ERR, "\nError in %s: initializing TPDO %d failed!\n\n", __func__, wCnt);
        goto exit;
    }
    else
    {
        DEBUG_TRACE4(DEBUG_LVL_CNAPI_INFO,"%s: TXPDO %d: adrs. %08x (size %d)\n",
                                            __func__, wCnt,(unsigned int)aTPdosPdi_l[wCnt].pAdrs_m, aTPdosPdi_l[wCnt].wSize_m);
    }
}
for (wCnt = 0; wCnt < PCP_PDI_RPDO_CHANNELS; ++wCnt)
{
    if ((aRPdosPdi_l[wCnt].pAdrs_m == NULL) ||
        (aRPdosPdi_l[wCnt].wSize_m == 0)    ||
        (aRPdosPdi_l[wCnt].pAck_m ==  NULL)   )
    {
        DEBUG_TRACE2(DEBUG_LVL_CNAPI_ERR, "\n\nError in %s: initializing RPDO %d failed!\n\n", __func__, wCnt);
        goto exit;
    }
    else
    {
        DEBUG_TRACE4(DEBUG_LVL_CNAPI_INFO, "%s: RXPDO %d: adrs. %08x (size %d)\n",
                     __func__, wCnt, (unsigned int)aRPdosPdi_l[wCnt].pAdrs_m,
                     aRPdosPdi_l[wCnt].wSize_m);
    }
}

    return OK;
exit:
    return ERROR;
}

/**
********************************************************************************
\brief  handle an LinkPdosReq command from PCP
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space

\return tPdiAsyncStatus
\retval kPdiAsyncStatusSuccessful             on success
\retval kPdiAsyncStatusInvalidInstanceParam   on invalid parameters
\retval kPdiAsyncStatusInvalidOperation       when CnApi_readPdoDesc() fails

This function sets up the mapping connection PCP PDI <-> local Objects
*******************************************************************************/
tPdiAsyncStatus CnApi_handleLinkPdosReq(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pRxMsgBuffer_p,
                                        BYTE* pTxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    register int        iCnt;
    WORD                wNumDescr;
    tPdoDescHeader *    pPdoDescHeader;         //< ptr to descriptor
    tLinkPdosReq *      pLinkPdosReq = NULL;    //< ptr to message (Rx)
    tCnApiStatus        fRet = kCnApiStatusOk;
    WORD                wCommHdl = 0;
    tCnApiSdoAbortCode  PdoRespAbortCode = kCnApiSdoacSuccessful;
    tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;

    DEBUG_FUNC;

    /* check message descriptor */
    if (pMsgDescr_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* verify all buffer pointers we intend to use */
    if (pRxMsgBuffer_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* assign buffer payload addresses */
    pLinkPdosReq = (tLinkPdosReq *) pRxMsgBuffer_p;    // Rx buffer

    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "INFO: LinkPdosReq received.\n");

    /* handle Rx Message */
    /* get numbers of descriptors in this message */
    wNumDescr = pLinkPdosReq->m_bDescrCnt;
    wCommHdl = AmiGetWordFromLe((BYTE *)&pLinkPdosReq->m_wCommHdl);


    /* get pointer to  first descriptor */
    pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pLinkPdosReq + sizeof(tLinkPdosReq));

    // reset unlinked objects counter
    wCntMappedNotLinkedObj_l = 0;

    /* read all descriptors and setup the corresponding copy tables */
    for (iCnt = 0; iCnt < wNumDescr; ++iCnt)
    {
        if(pfnPdoDescriptor_l != NULL)
        {   // provide the PDO descriptor via the callback to the user
            fRet = pfnPdoDescriptor_l((tCnApiPdoDesc *)pPdoDescHeader, &PdoRespAbortCode);
            if (fRet != kCnApiStatusOk)
            {
                Ret = kPdiAsyncStatusInvalidOperation;
                goto exit;
            }
        }
        else
        {
            fRet = CnApi_readPdoDesc(pPdoDescHeader);
            if (fRet != kCnApiStatusOk)
            {
                Ret = kPdiAsyncStatusInvalidOperation;
                goto exit;
            }
        }

        /* get pointer to next descriptor */
        pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pPdoDescHeader + sizeof(tPdoDescHeader) +
                         (pPdoDescHeader->m_bEntryCnt * sizeof(tPdoDescEntry)));
    }

    if(wCntMappedNotLinkedObj_l != 0 && pfnPdoDescriptor_l == NULL)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Warning: %d objects are mapped but not linked!\n",
                wCntMappedNotLinkedObj_l);
    }

exit:
    if (Ret != kPdiAsyncStatusSuccessful)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR: Mapping or linking failed!\n");
        PdoRespAbortCode = kCnApiSdoacGeneralError;
    }

    Ret = CnApi_sendPdoResp(pLinkPdosReq->m_bMsgId,
            pLinkPdosReq->m_bOrigin,
            wCommHdl,
            PdoRespAbortCode);
    if(Ret != kPdiAsyncStatusSuccessful)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR: Unable to post Pdo response message!\n");
    }

    return Ret;
}


/**
********************************************************************************
\brief  setup an Link PDOs response command
\param  pMsgDescr_p         pointer to asynchronous message descriptor
\param  pTxMsgBuffer_p      pointer to Tx message buffer (payload)
\param  pRxMsgBuffer_p      pointer to Rx message buffer (payload)
\param  dwMaxTxBufSize_p    maximum Tx message storage space

\return tPdiAsyncStatus
\retval kPdiAsyncStatusSuccessful             on success
\retval kPdiAsyncStatusInvalidInstanceParam   on invalid parameters
\retval kPdiAsyncStatusDataTooLong            when posted message is to long

CnApi_doLinkPdosResp() executes an LinkPdosResp command. The parameters
stored in pInitParm_g will be copied to the LinkPdosResp message and transfered
to the PCP.
*******************************************************************************/
tPdiAsyncStatus CnApi_doLinkPdosResp(tPdiAsyncMsgDescr * pMsgDescr_p, BYTE* pTxMsgBuffer_p,
                                     BYTE* pRxMsgBuffer_p, DWORD dwMaxTxBufSize_p)
{
    tLinkPdosResp *    pLinkPdosResp = NULL;        //< pointer to message (Tx)
    tPdiAsyncStatus    Ret = kPdiAsyncStatusSuccessful;

    DEBUG_FUNC;

    /* check message descriptor */
    if (pMsgDescr_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* verify all buffer pointers we intend to use */
    if (pTxMsgBuffer_p == NULL)
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    /* check if expected Tx message size exceeds the buffer */
    if ( sizeof(tLinkPdosResp) > dwMaxTxBufSize_p)
    {
        /* reject transfer, because direct access can not be processed */
        Ret = kPdiAsyncStatusDataTooLong;
        goto exit;
    }

    /* assign buffer payload addresses */
    pLinkPdosResp = (tLinkPdosResp *) pTxMsgBuffer_p;    // Tx buffer

    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "INFO: LinkPdosResp done.\n");

    /* handle Tx Message */
    /* build up InitPcpReq */
    pLinkPdosResp->m_bMsgId = LinkPdosResp_l.m_bMsgId;
    pLinkPdosResp->m_bOrigin = LinkPdosResp_l.m_bOrigin;
    AmiSetWordToLe((BYTE *)&pLinkPdosResp->m_wCommHdl, LinkPdosResp_l.m_wCommHdl);
    AmiSetDwordToLe((BYTE *)&pLinkPdosResp->m_dwErrCode, LinkPdosResp_l.m_dwErrCode);

    /* update size values of message descriptors */
    pMsgDescr_p->dwMsgSize_m = sizeof(tLinkPdosResp); // sent size

exit:
    if ((LinkPdosResp_l.m_bOrigin == kAsyncLnkPdoMsgOrigNmtCmd) &&
        (Ret == kPdiAsyncStatusSuccessful)                      &&
        (LinkPdosResp_l.m_dwErrCode == 0)                         )
    { /* assign call back - move to ReadyToOperate state */
        pMsgDescr_p->pfnTransferFinished_m = CnApi_pfnCbLinkPdosRespFinished;
    }
    else
    { // error -> don not move to ReadyToOperate state
        pMsgDescr_p->pfnTransferFinished_m = NULL;
    }

    return Ret;
}


/**
 ********************************************************************************
 \brief call back function, invoked if handleLinkPdosReq has finished
 \param  pMsgDescr_p         pointer to asynchronous message descriptor

 \return tPdiAsyncStatus
 \retval kPdiAsyncStatusSuccessful    on success

 This function triggers an CMD_READY_TO_OPERATE which will be sent to the PCP

 *******************************************************************************/
tPdiAsyncStatus CnApi_pfnCbLinkPdosRespFinished (struct sPdiAsyncMsgDescr * pMsgDescr_p)
{
    /* trigger AP state machine change */
    CnApi_enterApStateReadyToOperate();

    return kPdiAsyncStatusSuccessful;
}

/**
********************************************************************************
\brief  check for new PDO data and receive transmit them

CnApi_checkPdo() transfers PDO data. It receives RX data from the PCP and
sends TX data to the PCP. After the RX transfer is finished the sync callback is
executed.
*******************************************************************************/
void CnApi_processPdo(void)
{
    tCnApiStatus Ret = kCnApiStatusOk;
    tCnApiTimeStamp TimeStamp = {{0}};

    CnApi_receivePdo();

    if(pfnAppCbSync_l != NULL)
    {
        CnApi_getCurTime(&TimeStamp);
        /* call AppCbSync callback function */
        Ret = pfnAppCbSync_l(&TimeStamp);
        if(Ret != kCnApiStatusOk)
        {
            //TODO: Implement proper error handling here! Set action on error! (reboot?)
            DEBUG_TRACE2(DEBUG_LVL_CNAPI_ERR, "ERROR: (%s) Error while processing the sync"
                    "callback! Errorcode: 0x%x\n", __func__, Ret);
        }
    }
    else
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: (%s) Sync callback called without"
                "initialization.", __func__);
    }

    CnApi_transmitPdo();
}

/**
********************************************************************************
\brief  read PDO descriptor

\param  pPdoDescHeader_p    pointer to Pdo descriptor

\return BOOL
\retval FALSE               if error occurred
\retval TRUE                on success

CnApi_readPdoDesc() checks if the mapping changed. If it changed the
PDO descriptor is read and the copy table is updated.
*******************************************************************************/
static tCnApiStatus CnApi_readPdoDesc(tPdoDescHeader * pPdoDescHeader_p)
{
    tCnApiStatus fRet = kCnApiStatusOk;
    BOOL         Ret;

    Ret = CnApi_configurePdoChannel(pPdoDescHeader_p,
                        pPdoDescHeader_p->m_bEntryCnt,
                        pPdoDescHeader_p->m_bPdoDir,
                        pPdoDescHeader_p->m_bBufferNum,
                        pPdoDescHeader_p->m_bMapVersion);
    if(Ret == FALSE)
    {
        fRet = kCnApiStatusInvalidParameter;
    }

    return fRet;
}

/**
********************************************************************************
\brief  Send a PDO response message to the pcp

\param  bMsgId_p         Id of the pdo response message
\param  bOrigin_p        origin of the pdo response message
\param  wObdAccConHdl_p  connection handle of PCP OBD access
\param  dwErrorCode_p    error code

\return tPdiAsyncStatus
\retval kPdiAsyncStatusSuccessful   when successful

CnApi_sendPdoResp() posts a pdo response message to the asychronous state
machine.
*******************************************************************************/
static tPdiAsyncStatus CnApi_sendPdoResp(BYTE bMsgId_p,
                                  BYTE bOrigin_p,
                                  WORD wObdAccConHdl_p,
                                  DWORD dwErrorCode_p)
{
    tPdiAsyncStatus Ret = kPdiAsyncStatusSuccessful;

    LinkPdosResp_l.m_dwErrCode = dwErrorCode_p;

    /* return LinkPdosReq fields in LinkPdosResp message */
    LinkPdosResp_l.m_bMsgId = bMsgId_p;
    LinkPdosResp_l.m_bOrigin = bOrigin_p;
    LinkPdosResp_l.m_wCommHdl = wObdAccConHdl_p;

    /* send LinkPdosResp message to PCP */
    Ret = CnApiAsync_postMsg(kPdiAsyncMsgIntLinkPdosResp,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                0);

    return Ret;
}

/**
********************************************************************************
\brief  get current time values of this cycle

\param  pTimeStamp_p     the empty structure to be filled with new time
                         values.

CnApi_getCurTime() returns a structure to the current time values
*******************************************************************************/
static void CnApi_getCurTime(tCnApiTimeStamp *pTimeStamp_p)
{
    pTimeStamp_p->m_netTime.m_dwSec = CnApi_getNetTimeSeconds();
    pTimeStamp_p->m_netTime.m_dwNanoSec = CnApi_getNetTimeNanoSeconds();
    pTimeStamp_p->m_qwRelTime = (QWORD)(((QWORD)CnApi_getRelativeTimeHigh() << 32) |
            ((DWORD)CnApi_getRelativeTimeLow()));
    pTimeStamp_p->m_wTimeAfterSync = CnApi_getTimeAfterSync();
}


/**
********************************************************************************
\brief    receive PDO data

CnApi_receivePdo() receives PDO data from the PCP.
*******************************************************************************/
static void CnApi_receivePdo(void)
{
    tPdoCopyTblEntry    *pCopyTblEntry;    ///< pointer to table entry
    WORD                wEntryCnt;         ///< number of copy table entries
    register int        iCntin;            ///< inner loop counter
    register int        iCntout;           ///< outer loop counter
    BYTE                *pPdoPdiData;      // pointer to Pdo buffer
    BYTE                fDoRcv = TRUE;

#ifdef CN_API_USING_SPI
    BYTE                bAckOffset;
#endif

    /* copy all RPDOs from PDI buffer to local variable */
    for (iCntout = 0; iCntout < PCP_PDI_RPDO_CHANNELS; ++iCntout)
    {
        wEntryCnt = aRxPdoCopyTbl_l[iCntout].bNumOfEntries_m;

        if((aRxPdoCopyTbl_l[iCntout].fActivated_m == FALSE) ||
           (wEntryCnt == 0)                                   )
        {  // skip PDO channel update
            continue;
        }

        pCopyTblEntry = &(aRxPdoCopyTbl_l[iCntout].aEntry_m[0]);
        pPdoPdiData = aRPdosPdi_l[iCntout].pAdrs_m;

#ifdef CN_API_USING_SPI
        /* prepare PDO buffer for read access */
        bAckOffset = (BYTE) aRPdosPdi_l[iCntout].wSpiAckOffs_m;
        CnApi_ackPdoBuffer((BYTE*) &bAckOffset);
#else
        /* prepare PDO buffer for read access */
        CnApi_ackPdoBuffer(aRPdosPdi_l[iCntout].pAck_m);
#endif

        for (iCntin = 0; iCntin < wEntryCnt; iCntin++)
        {   /* get Pdo data from PDI */
            CopyVarConvertEndian(pCopyTblEntry->pAdrs_m,
                                 pPdoPdiData + pCopyTblEntry->wPdoOfst,
                                 pCopyTblEntry->size_m,
                                 fDoRcv);
            pCopyTblEntry++;
        }
    }
}

/**
********************************************************************************
\brief    transmit PDO data

CnApi_transmitPdo() transmits PDO data to the PCP.
*******************************************************************************/
static void CnApi_transmitPdo(void)
{
    tPdoCopyTblEntry    *pCopyTblEntry;    ///< pointer to table entry
    WORD                wEntryCnt;         ///< number of copy table entries
    register int        iCntin;            ///< inner loop counter
    register int        iCntout;           ///< outer loop counter
    BYTE                *pPdoPdiData;      ///< pointer to Pdo buffer
    BYTE                fDoRcv = FALSE;

#ifdef CN_API_USING_SPI
    BYTE                bAckOffset;
#endif


    /* copy all TPdos from local variable to PDI buffer */
    for (iCntout = 0; iCntout < PCP_PDI_TPDO_CHANNELS; ++iCntout)
    {
        wEntryCnt = aTxPdoCopyTbl_l[iCntout].bNumOfEntries_m;

        if((aTxPdoCopyTbl_l[iCntout].fActivated_m == FALSE) ||
           (wEntryCnt == 0)                                   )
        {  // skip PDO channel update
            continue;
        }

        pCopyTblEntry = &(aTxPdoCopyTbl_l[iCntout].aEntry_m[0]);
        pPdoPdiData = aTPdosPdi_l[iCntout].pAdrs_m;

        for (iCntin = 0; iCntin < wEntryCnt; iCntin++)
        {   /* write Pdo data to PDI */
            CopyVarConvertEndian(pPdoPdiData + pCopyTblEntry->wPdoOfst,
                                 pCopyTblEntry->pAdrs_m,
                                 pCopyTblEntry->size_m,
                                 fDoRcv);
            pCopyTblEntry++;
        }

        /* prepare PDO buffer for next write access */
#ifdef CN_API_USING_SPI
        bAckOffset = (BYTE)aTPdosPdi_l[iCntout].wSpiAckOffs_m;
        CnApi_ackPdoBuffer((BYTE*) &bAckOffset);
#else
        CnApi_ackPdoBuffer(aTPdosPdi_l[iCntout].pAck_m);
#endif
    }
}

/**
********************************************************************************
\brief  write to DPRAM Buffer acknowledge register

CnApi_ackPdoBuffer() writes a random 32bit value
to a defined buffer control register.
*******************************************************************************/
static inline void CnApi_ackPdoBuffer(BYTE* pAckReg_p)
{
    const BYTE bAckValue = 0xff;

#ifdef CN_API_USING_SPI
    DEBUG_TRACE1(DEBUG_LVL_CNAPI_SPI,"Ack Offs: %d\n", (WORD) *pAckReg_p);
    /* update PCP register */
    CnApi_Spi_write(*pAckReg_p, // this is an offset in case of serial interface
                    sizeof(bAckValue),
                    (BYTE*) &bAckValue);
#else
    *pAckReg_p = bAckValue; ///> write random byte value
#endif /* CN_API_USING_SPI */
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


