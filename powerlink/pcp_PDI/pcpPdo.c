/**
********************************************************************************
\file		GenericIfPdo.c

\brief		PDO functions of generic interface

\author		Josef Baumgartner

\date		26.04.2010

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApi.h"
#include "cnApiIntern.h"
#include "pcp.h"

#include "EplInc.h"
#include "EplObd.h"
#include "user/EplObdu.h"
#include "Epl.h"

#include <string.h>

/******************************************************************************/
/* defines */
/* equals number of mapped objects, if memory-chaining is not applied */
#define	PDO_COPY_TBL_ELEMENTS	MAX_MAPPABLE_OBJECTS   ///< max copy table elements per PDO
//TODO: this is a restriction to be indicated in xdd! (max nr. of mappable objects)
#define PCP_PDO_MAPPING_SIZE_SUM_MAX    100     ///< max sum of mappable bytes (for 400µs cycle time)

#define BYTE_SIZE_SHIFT 3 ///< used for bit shift operation to convert bit value to byte value
/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
tObjTbl     *pPcpLinkedObjs_g = NULL;  ///< table of linked objects at pcp side according to AP message
DWORD       dwApObjLinkEntries_g = 0;  ///< number of linked objects at pcp side
DWORD       dwSumMappingSize_g = 0;    ///< counter of overall mapped bytes

/* local variables */
static tTPdoBuffer aTPdosPdi_l[TPDO_CHANNELS_MAX];
static tRPdoBuffer aRPdosPdi_l[RPDO_CHANNELS_MAX];

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */


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

/**
********************************************************************************
\brief	initialize asynchronous functions

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
    aTPdosPdi_l[0].pAdrs_m = (BYTE*) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wTxPdo0BufAoffs);
    aTPdosPdi_l[0].wSize_m = pCtrlReg_g->m_wTxPdo0BufSize;
    aTPdosPdi_l[0].pAck_m = (BYTE*) (&pCtrlReg_g->m_wTxPdo0Ack);
#endif /* TPDO_CHANNELS_MAX >= 1 */

    /** group RPDO PDI channels address, size and acknowledge settings */
#if (RPDO_CHANNELS_MAX >= 1)
    aRPdosPdi_l[0].pAdrs_m = (BYTE*) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wRxPdo0BufAoffs);
    aRPdosPdi_l[0].wSize_m = pCtrlReg_g->m_wRxPdo0BufSize;
    aRPdosPdi_l[0].pAck_m = (BYTE*) (&pCtrlReg_g->m_wRxPdo0Ack);
#endif /* RPDO_CHANNELS_MAX >= 1 */

#if (RPDO_CHANNELS_MAX >= 2)
    aRPdosPdi_l[1].pAdrs_m = (BYTE*) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wRxPdo1BufAoffs);
    aRPdosPdi_l[1].wSize_m = pCtrlReg_g->m_wRxPdo1BufSize;
    aRPdosPdi_l[1].pAck_m = (BYTE*) (&pCtrlReg_g->m_wRxPdo1Ack);
#endif /* RPDO_CHANNELS_MAX >= 2 */

#if (RPDO_CHANNELS_MAX >= 3)
    aRPdosPdi_l[2].pAdrs_m = (BYTE*) (PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wRxPdo2BufAoffs);
    aRPdosPdi_l[2].wSize_m = pCtrlReg_g->m_wRxPdo2BufSize;
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
\brief	write to DPRAM Buffer acknowledge register

CnApi_ackPdoBuffer() writes a random 32bit value
to a defined buffer control register.
*******************************************************************************/
inline void CnApi_ackPdoBuffer(BYTE* pAckReg_p)
{
    *pAckReg_p = 0xab; ///> write random byte value
}

/**
********************************************************************************
\brief  update PDI TPDO triple buffers

This function switches all PDI PDO triple buffers to the last updated block.
It has to be executed before each read access to the TPDO triple buffers.
*******************************************************************************/
void Gi_preparePdiPdoReadAccess(void)
{
	register int        iCntout;           ///< loop counter

    // acknowledge all RPDO PDI buffer right before read access
    for (iCntout = 0; iCntout < TPDO_CHANNELS_MAX; ++iCntout)
    {
        // switch triple buffer to last updated block
        CnApi_ackPdoBuffer(aTPdosPdi_l[iCntout].pAck_m);
    }
}

/**
********************************************************************************
\brief  update PDI RPDO triple buffers

This function switches all PDI PDO triple buffers to the updated block. It has
to be executed after each write access to the RPDO triple buffers.
*******************************************************************************/
void Gi_signalPdiPdoWriteAccess(void)
{
    register int        iCntout;           ///< loop counter

    // acknowledge all RPDO PDI buffer right after write access
    for (iCntout = 0; iCntout < RPDO_CHANNELS_MAX; ++iCntout)
    {
        // switch triple buffer to updated block
        CnApi_ackPdoBuffer(aRPdosPdi_l[iCntout].pAck_m);
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

\param	bDirection_p		       direction of PDO transfer to setup the descriptor
\param  pCurrentDescrOffset_p      pointer to the current LinkPdoReq payload offset
\param  pLinkPdoReq_p              pointer to the LinkPdoReq message.

\return TRUE if successful or FALSE if an error occured.
*******************************************************************************/
BOOL Gi_setupPdoDesc(BYTE bDirection_p,  WORD *pCurrentDescrOffset_p, tLinkPdosReq *pLinkPdoReq_p)
{
	tEplKernel          Ret = kEplSuccessful;
	unsigned int        uiCommParamIndex;
	unsigned int        uiMappParamIndex;
	unsigned int		uiPdoChannelCount = 0;

	unsigned int		uiIndex;
	WORD		        wPdoDescSize;
	unsigned int		uiMapIndex;
	unsigned int		uiMapSubIndex;
    unsigned int        uiMapOffset;
    unsigned int        uiMapSize;
	unsigned int		uiMapObj;
	unsigned int		uiCommObj;
	unsigned int		uiMaxPdoChannels;
	unsigned int        uiOffsetCnt = 0;

	/* linking function temporary variables */
    BYTE *  pData = NULL;
    int iSize;

	tEplObdSize         ObdSize;
	BYTE                bNodeId;
	QWORD               qwObjectMapping;
	BYTE                bMappSubindex;
	BYTE                *pTempAdrs;                 ///< Address of linked object
	BYTE                bObdSubIdxCount = 0;
	BYTE                bAddedDecrEntries;          ///< added descriptor entry counter

	tPdoDescEntry	    *pPdoDescEntry;             ///< ptr to descriptor payload = object entries
	tPdoDescHeader		*pPdoDescHeader = NULL;     ///< ptr to descriptor header
	tPdoDir              PdoDir;
	BYTE                 bApiBufferNum = 0;
	BOOL fRet = TRUE;                               ///< return

	/* initialize variables according to PDO direction */
	if (bDirection_p == kCnApiDirReceive)
	{
	    PdoDir = RPdo;
		pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pLinkPdoReq_p + sizeof(tLinkPdosReq) + *pCurrentDescrOffset_p);       // ptr to first descriptor sink address
		uiCommObj = EPL_PDOU_OBD_IDX_RX_COMM_PARAM;       // 1400 start (node ID object info)
		uiMapObj = EPL_PDOU_OBD_IDX_RX_MAPP_PARAM;        // 1600 start (object + size + offset info)
		uiMaxPdoChannels = RPDO_CHANNELS_MAX;             // Max RPDOs
	}
	else if(bDirection_p == kCnApiDirTransmit)
	{
	    PdoDir = TPdo;
	    pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pLinkPdoReq_p + sizeof(tLinkPdosReq) + *pCurrentDescrOffset_p);       // ptr to first descriptor sink address
		uiCommObj = EPL_PDOU_OBD_IDX_TX_COMM_PARAM;
		uiMapObj = EPL_PDOU_OBD_IDX_TX_MAPP_PARAM;
		uiMaxPdoChannels = TPDO_CHANNELS_MAX;
	}
	else
	{
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Direction not specified!\n");
        fRet = FALSE;
        goto exit;
    }

	/* count PDO channels according to assigned NodeIDs */
	for (uiCommParamIndex = uiCommObj; uiCommParamIndex < uiCommObj + uiMaxPdoChannels; uiCommParamIndex++)
	{
		ObdSize = sizeof (bNodeId);
		// read node ID from OD
		Ret = EplObduReadEntry(uiCommParamIndex, 0x01, &bNodeId, &ObdSize); ///< read 14XX or 18XX
		if ((Ret == kEplObdIndexNotExist)
			|| (Ret == kEplObdSubindexNotExist)
			|| (Ret == kEplObdIllegalPart))
		{   // PDO does not exist
			continue;
		}
		else if (Ret != kEplSuccessful)
		{   // other fatal error occured
            fRet = FALSE;
	        goto exit;
		}
		uiPdoChannelCount++;  ///< increment PDO counter for every assigned Node ID
	}

	/* setup descriptors and copy tables of all existing PDO channels for the specified direction */
	for (uiIndex = 0; uiIndex < uiPdoChannelCount; uiIndex++)
	{
		uiMappParamIndex = uiMapObj + uiIndex;

        /* prepare PDO descriptor for this PDO channel */
		pPdoDescHeader->m_bPdoDir = (BYTE) PdoDir;
		pPdoDescHeader->m_bBufferNum = bApiBufferNum;
        pPdoDescEntry =  (tPdoDescEntry*) ((BYTE*) pPdoDescHeader + sizeof(tPdoDescHeader)); ///< ptr to first entry
        wPdoDescSize = 0;
        bAddedDecrEntries = 0;

		/* read number of mapped objects of 18XX or 1AXX */
        ObdSize = sizeof (bObdSubIdxCount);
		Ret = EplObduReadEntry(uiMappParamIndex, 0x00, &bObdSubIdxCount, &ObdSize);
		if (Ret != kEplSuccessful)
		{
		    DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "OBD could not be read!\n");
            fRet = FALSE;
			goto exit;
		}

        uiOffsetCnt = 0;    //reset PDO offset counter for each PDO

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
			    /* TODO:  check if object is mappable */

                //DEBUG_TRACE2(DEBUG_LVL_CNAPI_INFO,"MapSize: %d MapOffset: %d\n", uiMapSize, uiMapOffset);
			    if (EplObdGetDataSize(uiMapIndex, uiMapSubIndex) == 0      ||
			        EplObdGetDataSize(uiMapIndex, uiMapSubIndex) != uiMapSize) //TODO: not efficient
			    {
                    DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Invalid object size. Skipped!\n");
                    //TODO: Forward Error To AP.
                }
                else
                {
                    /* first, link object according to mapping */

                    iSize = uiMapSize;

                    if (PdoDir == TPdo)
                    { // link directly to TPDO buffer
                        pData = aTPdosPdi_l[uiIndex].pAdrs_m + uiOffsetCnt;

                        /* verify if this PDO fits into the buffer */
                        if ((uiOffsetCnt + uiMapSize) > aTPdosPdi_l[uiIndex].wSize_m       ||
                            (dwSumMappingSize_g + uiMapSize) > PCP_PDO_MAPPING_SIZE_SUM_MAX)
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
                            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "linking process vars... error\n\n");
                            fRet = FALSE;
                            goto exit;
                        }
                    }
                    else if (PdoDir == RPdo)
                    { // link directly to RPDO buffer
                        pData = aRPdosPdi_l[uiIndex].pAdrs_m + uiOffsetCnt;

                        /* verify if this PDO fits into the buffer */
                        if ((uiOffsetCnt + uiMapSize) > aRPdosPdi_l[uiIndex].wSize_m       ||
                            (dwSumMappingSize_g + uiMapSize) > PCP_PDO_MAPPING_SIZE_SUM_MAX)
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
                            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "linking process vars... error\n\n");
                            fRet = FALSE;
                            goto exit;
                        }
                    }
                    else
                    { // should not occur -> error
                        fRet = FALSE;
                        goto exit;
                    }

                    /* now setup PDO buffer descriptor message */

		            // write descriptor entry
			        pPdoDescEntry->m_wPdoIndex = uiMapIndex;
			        pPdoDescEntry->m_bPdoSubIndex = uiMapSubIndex;
			        // pPdoDescEntry->m_wOffset = uiMapOffset; //TODO: use this line for real PDO frame
			        pPdoDescEntry->m_wOffset = uiOffsetCnt; //TODO: delete this line for real PDO frame
			        pPdoDescEntry->m_wSize = uiMapSize;

			        DEBUG_TRACE4(DEBUG_LVL_CNAPI_INFO, "%04x/%02x size: %d linkadr: %p",
			                uiMapIndex,
			                (BYTE)uiMapSubIndex,
			                uiMapSize,
			                pData);
	                DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, " offset: %04x\n", pPdoDescEntry->m_wOffset); //TODO: comment this line and add \n to last printf

			        pPdoDescEntry++;                 ///< prepare for next PDO descriptor entry
			        bAddedDecrEntries++;             ///< count added entries
			        dwSumMappingSize_g += uiMapSize; ///< count bytes of mapped size
			        uiOffsetCnt += uiMapSize; ///< TODO: delete this variable (and line) for real PDO frame
			    }
			}

		}
		pPdoDescHeader->m_wEntryCnt = bAddedDecrEntries;      ///< number of entries of this PDO descriptor
		pLinkPdoReq_p->m_bDescrCnt++;                         ///< update descriptor counter of LinkPdoReq message

        DEBUG_TRACE4(DEBUG_LVL_CNAPI_INFO, "Setup PDO Descriptor %d done. DIR:%d BufferNum:%d numObjs:%d\n"
                ,pLinkPdoReq_p->m_bDescrCnt, bDirection_p, pPdoDescHeader->m_bBufferNum, pPdoDescHeader->m_wEntryCnt);

		/* prepare for next PDO */
		wPdoDescSize = sizeof(tPdoDescHeader) + (bAddedDecrEntries * sizeof(tPdoDescEntry));
		pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) (pPdoDescHeader) + wPdoDescSize); ///< increment PDO descriptor count of Link PDO Request
		*pCurrentDescrOffset_p += wPdoDescSize;
		bApiBufferNum++;   ///< increment DPRAM PDO buffer number of this direction
	}

exit:
    if (fRet != TRUE)
    {
        pPdoDescHeader->m_wEntryCnt = 0;
    }

    return fRet;
}

/* END-OF-FILE */
/******************************************************************************/


