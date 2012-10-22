/**
********************************************************************************
\file		GenericIfPdo.c

\brief		PDO functions of generic interface

\author		Josef Baumgartner

\date		26.04.2010

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApiTypPdo.h"
#include "cnApiTypAsync.h"

#include "pcp.h"
#include "pcpPdo.h"
#include "pcpAsyncSm.h"

#ifdef __NIOS2__
#include <string.h>
#elif defined(__MICROBLAZE__)
#include <string.h>
#endif

#include "systemComponents.h"

#include "EplInc.h"
#include "EplObd.h"
#include "user/EplObdu.h"
#include "Epl.h"
#include "EplPdou.h"

/******************************************************************************/
/* defines */
//TODO: this is a restriction to be indicated in xdd! (max nr. of mappable objects)
#define PCP_PDO_MAPPING_SIZE_SUM_MAX    100     ///< max sum of mappable bytes (for 400µs cycle time)

#define BYTE_SIZE_SHIFT 3 ///< used for bit shift operation to convert bit value to byte value
/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */


/******************************************************************************/
/* local variables */
static tTPdoBuffer aTPdosPdi_l[TPDO_CHANNELS_MAX];
static tRPdoBuffer aRPdosPdi_l[RPDO_CHANNELS_MAX];

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */
static void SizeAlignPdiOffset(BYTE **ppbAddress_p,int iSize_p, unsigned int* puiOffset_p);
static void DecodeObjectMapping(
        QWORD qwObjectMapping_p,
        unsigned int* puiIndex_p,
        unsigned int* puiSubIndex_p,
        unsigned int* puiOffset_p,
        unsigned int* puiSize_p);
static inline void CnApi_ackPdoBuffer(BYTE* pAckReg_p);
static WORD Gi_getPdiMappedBytesSum(void);

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  initialize asynchronous functions

This function reads the control register information related to PDO PDI
and stores it into variables for this module. Also initial values are assigned.

\return OK (always)
*******************************************************************************/
int Gi_initPdo(void)
{
    register WORD wCnt;
    int iRet;

    /** group TPDO PDI channels address, size and acknowledge settings */
#if (TPDO_CHANNELS_MAX >= 1)
    aTPdosPdi_l[0].pAdrs_m = (BYTE*) (PDI_DPRAM_BASE_PCP + AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wTxPdo0BufAoffs)));
    aTPdosPdi_l[0].wSize_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wTxPdo0BufSize));
    aTPdosPdi_l[0].pAck_m = (BYTE*) (&pCtrlReg_g->m_wTxPdo0Ack);
#endif /* TPDO_CHANNELS_MAX >= 1 */

    /** group RPDO PDI channels address, size and acknowledge settings */
#if (RPDO_CHANNELS_MAX >= 1)
    aRPdosPdi_l[0].pAdrs_m = (BYTE*) (PDI_DPRAM_BASE_PCP + AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wRxPdo0BufAoffs)));
    aRPdosPdi_l[0].wSize_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wRxPdo0BufSize));
    aRPdosPdi_l[0].pAck_m = (BYTE*) (&pCtrlReg_g->m_wRxPdo0Ack);
#endif /* RPDO_CHANNELS_MAX >= 1 */

#if (RPDO_CHANNELS_MAX >= 2)
    aRPdosPdi_l[1].pAdrs_m = (BYTE*) (PDI_DPRAM_BASE_PCP + AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wRxPdo1BufAoffs)));
    aRPdosPdi_l[1].wSize_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wRxPdo1BufSize));
    aRPdosPdi_l[1].pAck_m = (BYTE*) (&pCtrlReg_g->m_wRxPdo1Ack);
#endif /* RPDO_CHANNELS_MAX >= 2 */

#if (RPDO_CHANNELS_MAX >= 3)
    aRPdosPdi_l[2].pAdrs_m = (BYTE*) (PDI_DPRAM_BASE_PCP + AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wRxPdo2BufAoffs)));
    aRPdosPdi_l[2].wSize_m = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wRxPdo2BufSize));
    aRPdosPdi_l[2].pAck_m = (BYTE*) (&pCtrlReg_g->m_wRxPdo2Ack);
#endif /* RPDO_CHANNELS_MAX >= 3 */

for (wCnt = 0; wCnt < TPDO_CHANNELS_MAX; ++wCnt)
{
    if ((aTPdosPdi_l[wCnt].pAdrs_m == NULL) ||
        (aTPdosPdi_l[wCnt].wSize_m == 0)    ||
        (aTPdosPdi_l[wCnt].pAck_m ==  NULL)   )
    {
        DEBUG_TRACE2(DEBUG_LVL_09, "\nError in %s: initializing TPDO %d failed!\n", __func__, wCnt);
        goto exit;
    }
    else
    {
        DEBUG_TRACE4(DEBUG_LVL_11, "%s: TXPDO %d: adrs. %08x (size %d)\n",
                                            __func__, wCnt,(unsigned int)aTPdosPdi_l[wCnt].pAdrs_m, aTPdosPdi_l[wCnt].wSize_m);
    }
}
for (wCnt = 0; wCnt < RPDO_CHANNELS_MAX; ++wCnt)
{
    if ((aRPdosPdi_l[wCnt].pAdrs_m == NULL) ||
        (aRPdosPdi_l[wCnt].wSize_m == 0)    ||
        (aRPdosPdi_l[wCnt].pAck_m == NULL)   )
    {
        DEBUG_TRACE2(DEBUG_LVL_09, "\nError in %s: initializing RPDO %d failed!\n", __func__, wCnt);
        goto exit;
    }
    else
    {
        DEBUG_TRACE4(DEBUG_LVL_11, "%s: RXPDO %d: adrs. %08x (size %d)\n",
                                            __func__, wCnt, (unsigned int)aRPdosPdi_l[wCnt].pAdrs_m, aRPdosPdi_l[wCnt].wSize_m);
    }
}
    /* allocate memory for PCP object-links table */
	iRet = Gi_createPcpObjLinksTbl((DWORD) MAX_NUM_LINKED_OBJ_PCP);
    if(iRet != OK)
    {
        goto exit;
    }

	return OK;
exit:
    return ERROR;
}

/**
********************************************************************************
\brief  update PDI TPDO triple buffers
\param bTpdoNum  RPDO PDI buffer number

This function switches all PDI PDO triple buffers to the last updated block.
It has to be executed before each read access to the TPDO triple buffers.
*******************************************************************************/
void Gi_preparePdiPdoReadAccess(BYTE bTpdoNum)
{

    // acknowledge the TPDO PDI buffer right before read access
    if (bTpdoNum < TPDO_CHANNELS_MAX)
    {
        // switch triple buffer to last updated block
        CnApi_ackPdoBuffer(aTPdosPdi_l[bTpdoNum].pAck_m);
    }
}

/**
********************************************************************************
\brief  update PDI RPDO triple buffers
\param bRpdoNum  RPDO PDI buffer number

This function switches all PDI PDO triple buffers to the updated block. It has
to be executed after each write access to the RPDO triple buffers.
*******************************************************************************/
void Gi_signalPdiPdoWriteAccess(BYTE bRpdoNum)
{
    // acknowledge the RPDO PDI buffer right before read access
    if (bRpdoNum < RPDO_CHANNELS_MAX)
    {
        CnApi_ackPdoBuffer(aRPdosPdi_l[bRpdoNum].pAck_m);
    }
}

/**
********************************************************************************
\brief	setup PDO descriptor

Gi_setupPdoDesc() reads the object mapping from the object dictionary and stores
the information in the PDO descriptor of the LinkPdoReq meassage so that the
AP could read it. The calling function needs to know the current payload offset
(starting with 0) in order to store subsequent descriptors of the same
LinkPdoReq meassage. Therefore the parameter pCurrentDescrOffset_p is used.

Additionally a copy table will be created for every PDO. This table is used
by the PCP for copying all objects contained in the mapping.

\param  LinkPdosReqComCon_p        connection handle of mapping object access
\param  bDirection_p               Direction of PDO transfer to setup the descriptor
                                   of all PDOs of this direction. If "kCnApiDirNone",
                                   PDO direction will be derived from mapping parameter index
                                   (member of LinkPdosReqComCon_p).
\param  pCurrentDescrOffset_p      pointer to the current LinkPdoReq payload offset
\param  pLinkPdoReq_p              pointer to the LinkPdoReq message
\param  wMaxStoreSpace             maximum LinkPdoReq payload offset this function can attach

\return TRUE if successful or FALSE if an error occured.
*******************************************************************************/
BOOL Gi_setupPdoDesc(tLinkPdosReqComCon * pLinkPdosReqComCon_p,
                     BYTE bDirection_p,
                     WORD *pCurrentDescrOffset_p,
                     tLinkPdosReq *pLinkPdoReq_p,
                     WORD wMaxStoreSpace)
{
	tEplKernel          Ret = kEplSuccessful;
	unsigned int        uiCommParamIndex;
	unsigned int        uiMappParamIndex;
	unsigned int		uiPdoChannelCount = 0;

	unsigned int		uiIndexAdd;
	WORD		        wPdoDescSize;
	unsigned int		uiMapIndex;
	unsigned int		uiMapSubIndex;
    unsigned int        uiMapOffset;
    unsigned int        uiMapSize;
	unsigned int		uiMapObj;
	unsigned int		uiCommObj;
	BYTE                bMaxPdoChannels;
	BYTE                bPdiPdoBufNr;
	BYTE                bMappingVersion;
	unsigned int        uiOffsetCnt = 0;
	WORD                wPdiMapSizeSumTmp = 0;
    WORD                wLinkPdoMsgPaylForecast = 0; ///< message payload size before actual write

	/* linking function temporary variables */
    BYTE *  pData = NULL;
    unsigned int iSize;

	tEplObdSize         ObdSize;
	BYTE                bNodeId;
	QWORD               qwObjectMapping;
	BYTE                bMappSubindex;
	BYTE                bObdSubIdxCount = 0;
	BYTE                bAddedDecrEntries;          ///< added descriptor entry counter

	tPdoDescEntry	    *pPdoDescEntry;             ///< ptr to descriptor payload = object entries
	tPdoDescHeader		*pPdoDescHeader = NULL;     ///< ptr to descriptor header
	tPdoDir              PdoDir;
	BOOL fRet = TRUE;                               ///< return

    /* initialize variables according to PDO direction */
    if (bDirection_p == kCnApiDirNone)
    {
        /* derive direction from pLinkPdosReqComCon_p */

        if (pLinkPdosReqComCon_p == NULL)
        {
            fRet = FALSE;
            goto exit;
        }

        PdoDir = pLinkPdosReqComCon_p->m_bPdoDir ;
        pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pLinkPdoReq_p + sizeof(tLinkPdosReq) + *pCurrentDescrOffset_p);       // ptr to first descriptor sink address
        uiMapObj = pLinkPdosReqComCon_p->m_wMapIndex ;
        // convert mapping index to related communication index
        uiCommObj = ~EPL_PDOU_OBD_IDX_MAPP_PARAM & pLinkPdosReqComCon_p->m_wMapIndex;
        if (PdoDir == TPdo)
        {
            bMaxPdoChannels = TPDO_CHANNELS_MAX;
        }
        else
        {
            bMaxPdoChannels = RPDO_CHANNELS_MAX;
        }
    }
	else if (bDirection_p == kCnApiDirReceive)
	{
	    PdoDir = RPdo;
		pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pLinkPdoReq_p + sizeof(tLinkPdosReq) + *pCurrentDescrOffset_p);       // ptr to first descriptor sink address
		uiCommObj = EPL_PDOU_OBD_IDX_RX_COMM_PARAM;       // 0x1400 start (node ID object info)
		uiMapObj = EPL_PDOU_OBD_IDX_RX_MAPP_PARAM;        // 0x1600 start (object + size + offset info)
		bMaxPdoChannels = RPDO_CHANNELS_MAX;
	}
	else if (bDirection_p == kCnApiDirTransmit)
	{
	    PdoDir = TPdo;
	    pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pLinkPdoReq_p + sizeof(tLinkPdosReq) + *pCurrentDescrOffset_p);       // ptr to first descriptor sink address
		uiCommObj = EPL_PDOU_OBD_IDX_TX_COMM_PARAM;       // 0x1800 start (node ID object info)
		uiMapObj = EPL_PDOU_OBD_IDX_TX_MAPP_PARAM;        // 0x1A00 start (object + size + offset info)
		bMaxPdoChannels = TPDO_CHANNELS_MAX;
	}
	else
    {   // invalid parameter
        fRet = FALSE;
        goto exit;
    }

    if (bDirection_p != kCnApiDirNone)
    {   // setup all channels of the specified direction

        /* count PDO channels according to assigned NodeIDs */
        for (uiCommParamIndex = uiCommObj; uiCommParamIndex < uiCommObj + bMaxPdoChannels; uiCommParamIndex++)
        {
            ObdSize = sizeof (bNodeId);
            // read node ID from OD
            Ret = EplObduReadEntry(uiCommParamIndex, 0x01, &bNodeId, &ObdSize); // read 14XX or 18XX
            if ((Ret == kEplObdIndexNotExist)
                || (Ret == kEplObdSubindexNotExist)
                || (Ret == kEplObdIllegalPart))
            {   // PDO Number does not exist
                break; //stop counting at first missing communication parameter index
            }
            else if (Ret != kEplSuccessful)
            {   // other fatal error occured
                fRet = FALSE;
                goto exit;
            }
            uiPdoChannelCount++;  ///< increment PDO counter for every assigned Node ID
        }
    }
    else
    {   // setup only one channel
        uiPdoChannelCount = 1;
    }

	/* setup descriptors and copy tables of all counted PDO channels for the specified direction */
	for (uiIndexAdd = 0; uiIndexAdd < uiPdoChannelCount; uiIndexAdd++)
	{
		uiMappParamIndex = uiMapObj + uiIndexAdd;
        // convert mapping index to related communication index
        uiCommParamIndex = ~EPL_PDOU_OBD_IDX_MAPP_PARAM & uiMappParamIndex;
        bPdiPdoBufNr = uiMappParamIndex & EPL_PDOU_PDO_ID_MASK;

        // verify if next descriptor fits in remaining message buffer space
        wLinkPdoMsgPaylForecast = (*pCurrentDescrOffset_p + sizeof(tPdoDescHeader));
        if ( wLinkPdoMsgPaylForecast >= wMaxStoreSpace )
        {
            // not enough space left for this descriptor (-header)
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: async message buffer exceeded (with %ld)!\n", wLinkPdoMsgPaylForecast + sizeof(tLinkPdosReq));
            fRet = FALSE;
            goto exit;
        }

        // read PDO mapping version
        ObdSize = sizeof (bMappingVersion);
        Ret = EplObdReadEntry(uiCommParamIndex, 0x02, &bMappingVersion, &ObdSize);
        if (Ret != kEplSuccessful)
        {   // other fatal error occured
            goto exit;
        }

        /* prepare PDO descriptor for this PDO channel */
		pPdoDescHeader->m_bPdoDir = (BYTE) PdoDir;
		pPdoDescHeader->m_bBufferNum = bPdiPdoBufNr;
        pPdoDescHeader->m_bMapVersion = bMappingVersion;
        if (pPdoDescHeader->m_bBufferNum > bMaxPdoChannels)
        {   // PDI PDO buffer count exceeded
            fRet = FALSE;
            goto exit;
        }

        pPdoDescEntry =  (tPdoDescEntry*) ((BYTE*) pPdoDescHeader + sizeof(tPdoDescHeader)); ///< ptr to first entry
        wPdoDescSize = 0;
        bAddedDecrEntries = 0;

        /* get number of mapped objects of 16XX or 1AXX */
        if (bDirection_p == kCnApiDirNone)
        {   // this function is called within an OBD access -> derive from pLinkPdosReqComCon_p
            bObdSubIdxCount = pLinkPdosReqComCon_p->m_bMapObjCnt;
        }
        else
        {   // this function is called when mapping configuration is already done
            ObdSize = sizeof (bObdSubIdxCount);
            Ret = EplObdReadEntry(uiMappParamIndex, 0x00, &bObdSubIdxCount, &ObdSize);
            if (Ret != kEplSuccessful)
            {
                DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "OBD could not be read!\n");
                 fRet = FALSE;
                goto exit;
            }
        }

        uiOffsetCnt = 0;    // reset PDO offset counter for each PDO

        // reset mapping sum counter of this PDI PDO buffer
        if (PdoDir == TPdo)
        {
            aTPdosPdi_l[bPdiPdoBufNr].wMappedBytes_m = 0;
        }
        else if (PdoDir == RPdo)
        {
            aRPdosPdi_l[bPdiPdoBufNr].wMappedBytes_m = 0;
        }
        else
        { // should not occur -> error
            fRet = FALSE;
            goto exit;
        }

        // get all currently PDI mapped bytes
        wPdiMapSizeSumTmp = Gi_getPdiMappedBytesSum();

		/* setup descriptor and copy table of this PDO channel
		 * according to mapping object pattern (of each subindex)
		 */
		for (bMappSubindex = 1; bMappSubindex <= bObdSubIdxCount; bMappSubindex++)
		{
		    /* check object mapping by reading the sub-indices */
			ObdSize = sizeof (qwObjectMapping); 		// QWORD
			Ret = EplObduReadEntry(uiMappParamIndex, bMappSubindex, &qwObjectMapping, &ObdSize);
			if (Ret != kEplSuccessful)
			{   // other fatal error occured
			    fRet = FALSE;
				goto exit;
			}

			DecodeObjectMapping(
			        qwObjectMapping,
			        &uiMapIndex,
			        &uiMapSubIndex,
			        &uiMapOffset,
			        &uiMapSize);

			/* add object to PDO descriptor */
	        if(uiMapIndex == 0x0000)
	        {
	                DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Index 0x0000 invalid. Skipped!\n");
	        }
			else
			{
			    // get mapped object size
			    ObdSize = EplObdGetDataSize(uiMapIndex, uiMapSubIndex);

                //DEBUG_TRACE2(DEBUG_LVL_CNAPI_INFO,"MapSize: %d MapOffset: %d\n", uiMapSize, uiMapOffset);
			    if (ObdSize == 0         ||
			        ObdSize != uiMapSize   )
			    {
                    DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Invalid object size. Skipped!\n");
                }
                else
                {
                    /* first, link object according to mapping */

                    iSize = uiMapSize;

                    if (PdoDir == TPdo)
                    { // link directly to TPDO buffer
                        // INFO: the buffer number bPdiPdoBufNr is derived from the channel index (1AXX)
                        pData = aTPdosPdi_l[bPdiPdoBufNr].pAdrs_m + uiOffsetCnt;

                        SizeAlignPdiOffset(&pData, iSize, &uiOffsetCnt);

                        /* verify if this PDO fits into the buffer and max mappable bytes are not exceeded */
                        if (((uiOffsetCnt + uiMapSize) > aTPdosPdi_l[bPdiPdoBufNr].wSize_m)             ||
                            ((wPdiMapSizeSumTmp + aTPdosPdi_l[bPdiPdoBufNr].wMappedBytes_m + uiMapSize)
                             > PCP_PDO_MAPPING_SIZE_SUM_MAX                                            )  )
                        {
                            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Max mappable data exceeded!\n");
                            fRet = FALSE;
                            goto exit;
                        }

                        /* directly link to DPRAM TPDO buffer */
                        Ret = EplApiLinkPdiMappObject(uiMapIndex,
                                                      pData,
                                                      NULL,
                                                      &iSize,
                                                      uiMapSubIndex);
                        if (Ret != kEplSuccessful)
                        {
                            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: linking to PDI failed!\n");
                            fRet = FALSE;
                            goto exit;
                        }

                        // update mapping size counter of this PDI PDO buffer
                        aTPdosPdi_l[bPdiPdoBufNr].wMappedBytes_m += uiMapSize; // count mapped bytes
                    }
                    else if (PdoDir == RPdo)
                    { // link directly to RPDO buffer
                        // INFO: the buffer number bPdiPdoBufNr is derived from the channel index (16XX)
                        pData = aRPdosPdi_l[bPdiPdoBufNr].pAdrs_m + uiOffsetCnt;

                        SizeAlignPdiOffset(&pData, iSize, &uiOffsetCnt);

                        /* verify if this PDO fits into the buffer and max mappable bytes are not exceeded */
                        if (((uiOffsetCnt + uiMapSize) > aRPdosPdi_l[bPdiPdoBufNr].wSize_m)             ||
                            ((wPdiMapSizeSumTmp + aRPdosPdi_l[bPdiPdoBufNr].wMappedBytes_m + uiMapSize)
                             > PCP_PDO_MAPPING_SIZE_SUM_MAX                                            )  )
                        {
                            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Max mappable data exceeded!\n");
                            fRet = FALSE;
                            goto exit;
                        }

                        /* directly link to DPRAM RPDO buffer */
                        Ret = EplApiLinkPdiMappObject(uiMapIndex,
                                                      NULL,
                                                      pData,
                                                      &iSize,
                                                      uiMapSubIndex);
                        if (Ret != kEplSuccessful)
                        {
                            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: linking to PDI failed!\n");
                            fRet = FALSE;
                            goto exit;
                        }

                        // update mapping size counter of this PDI PDO buffer
                        aRPdosPdi_l[bPdiPdoBufNr].wMappedBytes_m += uiMapSize; // count mapped bytes
                    }
                    else
                    { // should not occur -> error
                        fRet = FALSE;
                        goto exit;
                    }

                    // verify if next entry fits in remaining message buffer space
                    wLinkPdoMsgPaylForecast = *pCurrentDescrOffset_p + sizeof(tPdoDescHeader) + (bAddedDecrEntries + 1) * sizeof(tPdoDescEntry);
                    if ( wLinkPdoMsgPaylForecast > wMaxStoreSpace )
                    {
                        // not enough space left for this descriptor entry
                        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: async message buffer exceeded (with %ld)!\n", wLinkPdoMsgPaylForecast + sizeof(tLinkPdosReq));
                        fRet = FALSE;
                        goto exit;
                    }

                    /* now setup PDO buffer descriptor message */

		            // write descriptor entry
                    AmiSetWordToLe((BYTE*)&pPdoDescEntry->m_wPdoIndex, uiMapIndex);
                    pPdoDescEntry->m_bPdoSubIndex = uiMapSubIndex;
                    AmiSetWordToLe((BYTE*)&pPdoDescEntry->m_wOffset, uiOffsetCnt); //TODO: delete this line for real PDO frame
                    AmiSetWordToLe((BYTE*)&pPdoDescEntry->m_wSize, uiMapSize);

			        DEBUG_TRACE4(DEBUG_LVL_CNAPI_PDO_INFO, "0x%04x/0x%02x size: %d linkadr: %p",
			                uiMapIndex,
			                (BYTE)uiMapSubIndex,
			                uiMapSize,
			                pData);
	                DEBUG_TRACE1(DEBUG_LVL_CNAPI_PDO_INFO, " offset: 0x%04x\n", uiOffsetCnt); //TODO: comment this line and add \n to last printf

			        pPdoDescEntry++;                 // prepare for next PDO descriptor entry
			        bAddedDecrEntries++;             // count added entries
			        uiOffsetCnt += uiMapSize; // TODO: delete this variable (and line) for real PDO frame
			    }
			}
		}

		pPdoDescHeader->m_bEntryCnt = bAddedDecrEntries;      // number of entries of this PDO descriptor
		pLinkPdoReq_p->m_bDescrCnt++;                         // update descriptor counter of LinkPdoReq message

        DEBUG_TRACE4(DEBUG_LVL_CNAPI_PDO_INFO, "Setup PDO Descriptor %d finished: DIR:%d BufferNum:%d numObjs:%d "
                ,pLinkPdoReq_p->m_bDescrCnt, PdoDir, pPdoDescHeader->m_bBufferNum, bAddedDecrEntries);
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_PDO_INFO, "MapVers:%d\n", pPdoDescHeader->m_bMapVersion);

		/* prepare for next PDO */
		wPdoDescSize = sizeof(tPdoDescHeader) + (bAddedDecrEntries * sizeof(tPdoDescEntry));
		pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) (pPdoDescHeader) + wPdoDescSize); // increment PDO descriptor count of Link PDO Request
		*pCurrentDescrOffset_p += wPdoDescSize;
	}

exit:
    if (fRet != TRUE)
    {
        pPdoDescHeader->m_bEntryCnt = 0;
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: %s failed!\n", __func__);
    }

    return fRet;
}

/**
********************************************************************************
\brief  configure the Process Data Interface (PDI) PDO channels
\param uiMappParamIndex_p   PDO channel mapping index
\param bMappObjectCount_p   number of objects
                            0: deactivate channel
                            > 0: activate channel
\param AccessType_p         access type to mapped object:
                            write = RPDO and read = TPDO
\param pParam_p             OBD parameter
\return                     tEplKernel value (error code)

This function configures the Process Data Interface (PDI)
of the specified PDO channel.
A subfunction links mapped PDO data to the PDI.
*******************************************************************************/
tEplKernel Gi_checkandConfigurePdoPdi(unsigned int uiMappParamIndex_p,
                                                 BYTE bMappObjectCount_p,
                                                 tEplObdAccess AccessType_p,
                                                 tEplObdCbParam* pParam_p)
{
unsigned int    uiCommParamIndex;
tLinkPdosReqComCon  LinkPdosReqComCon;
tPdiAsyncStatus PdiRet = kPdiAsyncStatusSuccessful;
tEplKernel      Ret = kEplSuccessful;
WORD                wComConIdx;
tObdAccHstryEntry * pObdAccHstEntry = NULL;

    // --- configure this channel ---

    // save OBD access handle for AP response callback function
    Ret = EplAppDefObdAccAdoptedHstryInitSequence();
    if (Ret != kEplSuccessful)
    {
        pParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
        goto Exit;
    }

    Ret = EplAppDefObdAccAdoptedHstrySaveHdl(pParam_p, &pObdAccHstEntry);
    if (Ret != kEplSuccessful)
    {
        goto Exit;
    }

    Ret = Gi_openObdAccHstryToPdiConnection(pObdAccHstEntry);
    if (Ret != kEplSuccessful)
    {
        goto Exit;
    }

    if(Gi_getCurPdiObdAccFwdComCon(&ApiPdiComInstance_g, &wComConIdx) == TRUE)
    {   // PDI connection established

        // convert mapping index to related communication index
        uiCommParamIndex = ~EPL_PDOU_OBD_IDX_MAPP_PARAM & uiMappParamIndex_p;

        LinkPdosReqComCon.m_wMapIndex = uiMappParamIndex_p;
        LinkPdosReqComCon.m_bMapObjCnt = bMappObjectCount_p;
        if (AccessType_p == kEplObdAccWrite)
        {
            LinkPdosReqComCon.m_bPdoDir = RPdo;
        }
        else
        {
            LinkPdosReqComCon.m_bPdoDir = TPdo;
        }

        LinkPdosReqComCon.m_wComConHdl = wComConIdx;

        /* prepare PDO mapping */
        /* setup PDO <-> DPRAM copy table */
        // Gi_ObdAccessSrcPdiFinished callback is assigned for transfer error case
        // Note: since LinkPdosReqComCon is a local variable, the call-back function
        //       has to be executed in a sub function call immediately.
        //       Therefore it can not be a "direct-access" transfer!
        PdiRet = CnApiAsync_postMsg(kPdiAsyncMsgIntLinkPdosReq,
                                    (BYTE *) &LinkPdosReqComCon,
                                    Gi_ObdAccFwdPdiTxFinishedErrCb,
                                    NULL,
                                    NULL,
                                    0);
        if (PdiRet != kPdiAsyncStatusSuccessful)
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: Posting kPdiAsyncMsgIntLinkPdosReq failed with: %d\n", PdiRet);
            pParam_p->m_dwAbortCode = EPL_SDOAC_GENERAL_ERROR;
            Ret = kEplReject;
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

/******************************************************************************/
/* private functions */


/**
********************************************************************************
\brief  write to DPRAM Buffer acknowledge register

CnApi_ackPdoBuffer() writes a random 32bit value
to a defined buffer control register.
*******************************************************************************/
static inline void CnApi_ackPdoBuffer(BYTE* pAckReg_p)
{
    *pAckReg_p = 0xab; ///> write random byte value
}

/**
********************************************************************************
\brief  decode object mapping
\param qwObjectMapping_p    mapping pattern
\param puiIndex_p           OUT: index of mapped object
\param puiSubIndex_p        OUT: subindex of mapped object
\param puiOffset_p          OUT: data offset in frame
\param puiSize_p            OUT: data size in frame
*******************************************************************************/
static void DecodeObjectMapping(
        QWORD qwObjectMapping_p,
        unsigned int* puiIndex_p,
        unsigned int* puiSubIndex_p,
        unsigned int* puiOffset_p,
        unsigned int* puiSize_p)
{
    *puiIndex_p = (unsigned int)
                    (qwObjectMapping_p & 0x000000000000FFFFLL);
    *puiSubIndex_p = (unsigned int)
                    ((qwObjectMapping_p & 0x0000000000FF0000LL) >> 16);

    /* get bit values -> convert to byte values */
    *puiOffset_p = (unsigned int)
                    ((qwObjectMapping_p & 0x0000FFFF00000000LL) >> (32 + BYTE_SIZE_SHIFT));
    *puiSize_p = (unsigned int)
                    ((qwObjectMapping_p & 0xFFFF000000000000LL) >> (48 + BYTE_SIZE_SHIFT));
}

/********************************************************************************
\brief generates a padding when data is not word/dword aligned
\param bAddress_p       IN: desired object address
                        OUT: corrected object address
\param iSize_p          IN: size of the object
\param puiOffset_p      IN: desired object offset
                        OUT: corrected object offset
*******************************************************************************/
static void SizeAlignPdiOffset(BYTE **ppbAddress_p,int iSize_p, unsigned int* puiOffset_p)
{
    DWORD dwPadding, dwOfstCorrection;

    if(iSize_p == 3)
    {
        iSize_p = 4;    //when variable is three bytes long reserve a whole word
    }

    if((iSize_p > 4) && (iSize_p <8))
    {
        iSize_p = 8;    //when variable is longer than a word reserve a whole dword
    }

    //correct PDI address
    dwPadding = (DWORD)*ppbAddress_p;
    dwPadding += (iSize_p - 1);
    dwPadding &=  ~(iSize_p -1);
    dwOfstCorrection = dwPadding - (DWORD)*ppbAddress_p;
    *ppbAddress_p = (BYTE *)dwPadding;

    //correct PDI offset
    *puiOffset_p += dwOfstCorrection;
}

/**
********************************************************************************
\brief  get count of PDI mapped bytes

\return count of mapped bytes in total

This function counts the sum of all currently to PDI mapped bytes.
*******************************************************************************/
static WORD Gi_getPdiMappedBytesSum(void)
{
BYTE wLpCnt;
WORD wSumMapBytes = 0;

    for (wLpCnt = 0; wLpCnt < TPDO_CHANNELS_MAX; wLpCnt++)
    {
        wSumMapBytes += aTPdosPdi_l[wLpCnt].wMappedBytes_m;
    }

    for (wLpCnt = 0; wLpCnt < RPDO_CHANNELS_MAX; wLpCnt++)
    {
        wSumMapBytes += aRPdosPdi_l[wLpCnt].wMappedBytes_m;
    }

    return wSumMapBytes;
}


/* END-OF-FILE */
/******************************************************************************/


