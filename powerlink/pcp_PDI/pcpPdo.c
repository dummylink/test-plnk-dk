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
typedef struct sPdoCopyTblEntry {
    BYTE            *pAdrs_m;
    WORD            size_m;
} tPdoCopyTblEntry;

typedef struct sPdoCpyTbl {
   BYTE                 bNumOfEntries_m;
   tPdoCopyTblEntry     aEntry_m[PDO_COPY_TBL_ELEMENTS];
} tPdoCopyTbl;


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
static	tPdoCopyTbl			aTxPdoCopyTbl_l[TPDO_CHANNELS_MAX];
static	tPdoCopyTbl	        aRxPdoCopyTbl_l[RPDO_CHANNELS_MAX];

/* mapped objects are linked to this memory */
static BYTE abMappedObjects_l[PCP_PDO_MAPPING_SIZE_SUM_MAX]; //TODO: directly link to DPRAM; additional system.h restriction for each PDO channel

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */

/**
********************************************************************************
	\brief	comparison function used by qsort
 * This function will be used by qsort() to compare two elements of an array
*******************************************************************************/
int SortCopyTblEntry(const void *pCpyTblEntry, const void *pCpyTblNxtEntry)
{
	int iRet = 0;

	if (((tPdoCopyTblEntry *) pCpyTblEntry)->pAdrs_m > ((tPdoCopyTblEntry *) pCpyTblNxtEntry)->pAdrs_m)
	{
		//Address of pCpyTblEntry is greater than pCpyTblNxtEntry return positive no
		iRet = 1;
	}
	else if (((tPdoCopyTblEntry *) pCpyTblEntry)->pAdrs_m == ((tPdoCopyTblEntry *) pCpyTblNxtEntry)->pAdrs_m)
	{
		//Address of pCpyTblEntry is equal to pCpyTblNxtEntry return zero
		iRet = 0;
	}
	else
	{
		//Address of pCpyTblEntry is less than pCpyTblNxtEntry return negative no
		iRet = -1;
	}
	return iRet;
}

/**
********************************************************************************
	\brief	Prints the address and size of copy table entry
 * This function prints the address and size of all the copy table entry 
 * specified by the number of entries
*******************************************************************************/
void PrintCpyTbl(tPdoCopyTbl *pCpyTbl)
{
	int iLoop;

	for (iLoop = 0; iLoop < pCpyTbl->bNumOfEntries_m; iLoop++)
	{
		DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "pCpyTbl->aEntry_m[%d]=%p size_m=%d\n", iLoop, (void *)pCpyTbl->aEntry_m[iLoop].pAdrs_m , pCpyTbl->aEntry_m[iLoop].size_m);
	}
}

/**
********************************************************************************
	\brief	Optimize copy table entries
 * This function optimizes the entries of the Copytable
 * It checks whether the pAdrs_m in the copy table are memory chained or not
 * If the address are memory chained it reduces the num entries and increases
 * the size of chainable entries i.e. it merges single entries to memory blocks.
 
\param  pPdoCpyTbl_p    pointer to a copy table refering to one certain PDO
*******************************************************************************/
void OptimizeCpyTbl(tPdoCopyTbl *pPdoCpyTbl_p )
{
	tPdoCopyTblEntry  *pCpyTblEntry; //structure pointers
	tPdoCopyTblEntry  *pTempCpyTblEntry;
	BYTE bCpyTblEntries; 
	register int iLoop1; // loop count
	register int iLoop2;  //internal loop counter
	
	pCpyTblEntry    = &(pPdoCpyTbl_p->aEntry_m[0]); // starting value of the table's address 

	bCpyTblEntries    = pPdoCpyTbl_p->bNumOfEntries_m; // number of entries

	/*sort the list */
	qsort(pPdoCpyTbl_p->aEntry_m, pPdoCpyTbl_p->bNumOfEntries_m, sizeof(tPdoCopyTblEntry), SortCopyTblEntry);

	/* optimizing the copy table */
	pCpyTblEntry = &(pPdoCpyTbl_p->aEntry_m[0]);
	for (iLoop1 = 0; iLoop1 < bCpyTblEntries; iLoop1 ++ )
 	{
		pTempCpyTblEntry = 1 + pCpyTblEntry; //Next entry of the table assigned to a temporary variable

		/*searching the add+size entry match with other entries in the table*/
		for (iLoop2 = iLoop1 + 1; iLoop2 < bCpyTblEntries ; iLoop2 ++ )
	 	{  

			/* condition checks the add+size match with the other entries,
			 * if found,size of the next is added to the first element, found entry is deleted, entries reduced.
			 */
			if ((pCpyTblEntry->pAdrs_m + pCpyTblEntry->size_m) == pTempCpyTblEntry->pAdrs_m )
			{
		
				pCpyTblEntry->size_m += pTempCpyTblEntry->size_m ; //size of the found element is added to the
				                                                   //first element's size
				bCpyTblEntries--; // reduce the number of entries of the table

				/* Delete the matched element and move up all entries below the matched element */
				memcpy(pTempCpyTblEntry, 1 + pTempCpyTblEntry, (bCpyTblEntries - iLoop2) * sizeof(tPdoCopyTblEntry));
				/* clear the element at the end of the array, since all the elements are moved up in array */
				memset(((bCpyTblEntries - iLoop2) + pTempCpyTblEntry), 0, sizeof(tPdoCopyTblEntry));
				iLoop2--;
			}
			else
			{
				pTempCpyTblEntry = 1 + pTempCpyTblEntry; // update the starting value again				
			}	

		}
		pCpyTblEntry = 1 + pCpyTblEntry; // if the first entry doesnt match, the next entry is checked again
 	}
	pPdoCpyTbl_p->bNumOfEntries_m = bCpyTblEntries; //the number of entries assigned back to the structure element
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
\brief	read PDO data from DPRAM

This function reads all TPDOs to from PDI buffer. Therefore it uses a copy table
for each PDO.
*******************************************************************************/
void Gi_readPdo(void)
{
	BYTE				*pPdoPdiData;      ///< pointer to Pdo buffer
    tPdoCopyTblEntry    *pCopyTblEntry;    ///< pointer to table entry
    WORD                wEntryCnt;         ///< number of copy table entries
	register int		iCntin;            ///< inner loop counter
	register int        iCntout;           ///< outer loop counter

    /* copy all TPDOs to PDI buffer */
	for (iCntout = 0; iCntout < TPDO_CHANNELS_MAX; ++iCntout)
	{
	    pCopyTblEntry = &(aTxPdoCopyTbl_l[iCntout].aEntry_m[0]);
	    wEntryCnt = aTxPdoCopyTbl_l[iCntout].bNumOfEntries_m;
	    pPdoPdiData = aTPdosPdi_l[iCntout].pAdrs_m;

	    /* prepare PDO buffer for read access */
	    CnApi_ackPdoBuffer(aTPdosPdi_l[iCntout].pAck_m);

	    for (iCntin = 0; iCntin < wEntryCnt; iCntin++)
	    {
	        memcpy (pCopyTblEntry->pAdrs_m, pPdoPdiData, pCopyTblEntry->size_m);
	        pPdoPdiData += pCopyTblEntry->size_m;
	        pCopyTblEntry++;
	    }
	}
}

/**
********************************************************************************
\brief	write PDO data to DPRAM

This function writes all RPDOs to PDI buffer. Therefore it uses a copy table
for each PDO.
*******************************************************************************/
void Gi_writePdo(void)
{
    BYTE                *pPdoPdiData;      ///< pointer to Pdo buffer
    tPdoCopyTblEntry    *pCopyTblEntry;    ///< pointer to table entry
    WORD                wEntryCnt;         ///< number of copy table entries
    register int        iCntin;            ///< inner loop counter
    register int        iCntout;           ///< outer loop counter

    /* copy all RPDOs to PDI buffer */
    for (iCntout = 0; iCntout < RPDO_CHANNELS_MAX; ++iCntout)
    {
        pCopyTblEntry = &(aRxPdoCopyTbl_l[iCntout].aEntry_m[0]);
        wEntryCnt = aRxPdoCopyTbl_l[iCntout].bNumOfEntries_m;
        pPdoPdiData = aRPdosPdi_l[iCntout].pAdrs_m;

        for (iCntin = 0; iCntin < wEntryCnt; iCntin++)
        {
            memcpy (pPdoPdiData, pCopyTblEntry->pAdrs_m, pCopyTblEntry->size_m);
            pPdoPdiData += pCopyTblEntry->size_m;
            pCopyTblEntry++;
        }

        /* prepare PDO buffer for next write access */
        CnApi_ackPdoBuffer(aRPdosPdi_l[iCntout].pAck_m);
    }
}

/**
********************************************************************************
\brief  check if object is already linked

This function searches the specified index and sub-index in
the table of linked objects (according to AP command)
and returns true, if it is found.

\param  dwMapIndex         object index
\param  dwMapSubIndex      object sub-index

\return TRUE if object is linked or FALSE if not linked.
*******************************************************************************/
BOOL Gi_checkIfObjLinked(WORD wIndex_p, WORD wSubIndex_p)
{
    DWORD dwCnt;
    tObjTbl *pObjTbl;

    pObjTbl = pPcpLinkedObjs_g;

    /* search the object links table for the given object */
    for (dwCnt = 0; dwCnt < dwApObjLinkEntries_g; ++dwCnt)
    {
       if (pObjTbl->m_wIndex ==  wIndex_p &&
           pObjTbl->m_bSubIndex == (BYTE) wSubIndex_p)
       {
           return TRUE; // entry found
       }
       else
       {
           pObjTbl++; // switch to next entry
       }
    }
    return FALSE;
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

\return Ok, or ERROR if an error occured.
*******************************************************************************/
int Gi_setupPdoDesc(BYTE bDirection_p,  WORD *pCurrentDescrOffset_p, tLinkPdosReq *pLinkPdoReq_p)
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
    unsigned int uiVarEntries = 0;
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
	tPdoCopyTbl			*pCopyTbl = NULL;
	tPdoCopyTblEntry    *pCopyTblEntry;

	/* initialize variables according to PDO direction */
	if (bDirection_p == kCnApiDirReceive)
	{
	    PdoDir = RPdo;
		pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pLinkPdoReq_p + sizeof(tLinkPdosReq) + *pCurrentDescrOffset_p);       // ptr to first descriptor sink address
		uiCommObj = EPL_PDOU_OBD_IDX_RX_COMM_PARAM;       // 1400 start (node ID object info)
		uiMapObj = EPL_PDOU_OBD_IDX_RX_MAPP_PARAM;        // 1600 start (object + size + offset info)
		pCopyTbl = &aRxPdoCopyTbl_l[0];                   // ptr CopyTable sink address
		uiMaxPdoChannels = RPDO_CHANNELS_MAX;             // Max RPDOs
	}
	else if(bDirection_p == kCnApiDirTransmit)
	{
	    PdoDir = TPdo;
	    pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) pLinkPdoReq_p + sizeof(tLinkPdosReq) + *pCurrentDescrOffset_p);       // ptr to first descriptor sink address
		uiCommObj = EPL_PDOU_OBD_IDX_TX_COMM_PARAM;
		uiMapObj = EPL_PDOU_OBD_IDX_TX_MAPP_PARAM;
		pCopyTbl = &aTxPdoCopyTbl_l[0];
		uiMaxPdoChannels = TPDO_CHANNELS_MAX;
	}
	else
	{
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Direction not specified!\n");
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

        /* prepare copy table for this PDO channel */
        pCopyTblEntry = &(pCopyTbl->aEntry_m[0]);
        pCopyTbl->bNumOfEntries_m = 0;

		/* read number of mapped objects of 18XX or 1AXX */
        ObdSize = sizeof (bObdSubIdxCount);
		Ret = EplObduReadEntry(uiMappParamIndex, 0x00, &bObdSubIdxCount, &ObdSize);
		if (Ret != kEplSuccessful)
		{
		    DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "OBD could not be read!\n");
			goto exit;
		}

        if (PDO_COPY_TBL_ELEMENTS < bObdSubIdxCount)
        {
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Objects do not fit in copy table!\n");
            goto exit;
        }

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
			    /* check if object has been linked before by AP command */
			    //if (!Gi_checkIfObjLinked((WORD) uiMapIndex, (WORD) uiMapSubIndex))
			    //{
                //    continue; // goto next sub index of for loop, because only linked objects should be copied!
                //} //TODO: delete this block, because we care about the linking only at AP side.
			        //      Instead, check if object is mappable!

			    /* add object to copy table */
			    pCopyTblEntry->size_m = EplObdGetDataSize(uiMapIndex, uiMapSubIndex);
                //DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO,"TblSize: %d MapSize: %d MapOffset: %d\n",pCopyTblEntry->size_m, uiMapSize, uiMapOffset);
			    if (pCopyTblEntry->size_m == 0      ||
			        pCopyTblEntry->size_m != uiMapSize)
			    {
                    DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Invalid object size. Skipped!\n");
                    //TODO: Forward Error To AP.
                }
                else if ((dwSumMappingSize_g + uiMapSize) > PCP_PDO_MAPPING_SIZE_SUM_MAX)
                {
                    DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "Max mappable data exceeded!\n");
                    goto exit;
                }
			    else
			    {
			        /* first, link object according to mappig */
	                pData = &abMappedObjects_l[dwSumMappingSize_g];
	                uiVarEntries = 1;
	                iSize = uiMapSize;
	                Ret = EplApiLinkObject(uiMapIndex, pData, &uiVarEntries, &iSize, uiMapSubIndex);
	                if (Ret != kEplSuccessful)
	                {
	                    DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "linking process vars... error\n\n");
	                    goto exit;
	                }

                    /* now setup copy table and PDO buffer descriptor message */
			        pTempAdrs = EplObdGetObjectDataPtr(uiMapIndex, uiMapSubIndex);
			        if(pTempAdrs == NULL)
			        {
			            DEBUG_TRACE2(DEBUG_LVL_CNAPI_INFO, "%04x/%02x not linked (only mapped). Skipped.\n", uiMapIndex, (BYTE)uiMapSubIndex);
			        }
			        else
			        {
			            pCopyTblEntry->pAdrs_m = pTempAdrs;                                      ///< linked address
			            //pCopyTblEntry->size_m is already assigned in if statement above        ///< linked size

			            // write descriptor entry
			            pPdoDescEntry->m_wPdoIndex = uiMapIndex;
			            pPdoDescEntry->m_bPdoSubIndex = uiMapSubIndex;
			            // pPdoDescEntry->m_wOffset = uiMapOffset; //TODO: use this line for real PDO frame
			            pPdoDescEntry->m_wOffset = uiOffsetCnt; //TODO: delete this line for real PDO frame
			            pPdoDescEntry->m_wSize = uiMapSize;

			            DEBUG_TRACE4(DEBUG_LVL_CNAPI_INFO, "%04x/%02x size: %d linkadr: %p",
			                    uiMapIndex,
			                    (BYTE)uiMapSubIndex,
			                    pCopyTblEntry->size_m,
			                    pCopyTblEntry->pAdrs_m);
	                    DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, " offset: %04x\n", pPdoDescEntry->m_wOffset); //TODO: comment this line and add \n to last printf

			            pCopyTblEntry++;                 ///< prepare ptr for next element
			            pCopyTbl->bNumOfEntries_m++;     ///< increment entry counter
			            pPdoDescEntry++;                 ///< prepare for next PDO descriptor entry
			            bAddedDecrEntries++;             ///< count added entries
			            dwSumMappingSize_g += uiMapSize; ///< count bytes of mapped size
			            uiOffsetCnt += uiMapSize; ///< TODO: delete this variable (and line) for real PDO frame
			        }
			    }
			}

		}
		pPdoDescHeader->m_bEntryCnt = bAddedDecrEntries;      ///< number of entries of this PDO descriptor
		pLinkPdoReq_p->m_bDescrCnt++;                         ///< update descriptor counter of LinkPdoReq message

        DEBUG_TRACE4(DEBUG_LVL_CNAPI_INFO, "setup PDO Descriptor %d : DIR:%d BufferNum:%d numObjs:%d\n"
                ,pLinkPdoReq_p->m_bDescrCnt, bDirection_p, pPdoDescHeader->m_bBufferNum, pPdoDescHeader->m_bEntryCnt);

		// Uncomment the next 2 lines to reactivate the copy table optimization. Temporary disabled for worst-case measurements.
		// OptimizeCpyTbl (pCopyTbl); //Optimize copy table entries
		// DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Num Entries After Optimization: %d\n", pCopyTbl->bNumOfEntries_m);

		/* prepare for next PDO */
		wPdoDescSize = sizeof(tPdoDescHeader) + (bAddedDecrEntries * sizeof(tPdoDescEntry));
		pPdoDescHeader = (tPdoDescHeader*) ((BYTE*) (pPdoDescHeader) + wPdoDescSize); ///< increment PDO descriptor count of Link PDO Request
		*pCurrentDescrOffset_p += wPdoDescSize;
		bApiBufferNum++;   ///< increment DPRAM PDO buffer number of this direction
		pCopyTbl++;        ///< choose copy table of next PDO
	}

	return OK;

exit:
	DEBUG_TRACE0 (DEBUG_LVL_CNAPI_ERR, "Error setup PDO descriptor!\n");
	pPdoDescHeader->m_bEntryCnt = 0;
	pCopyTbl->bNumOfEntries_m = 0;

	return ERROR;
}

/* END-OF-FILE */
/******************************************************************************/


