/**
********************************************************************************
\file		CnApiObjects.c

\brief		CN API object functions

\author		Josef Baumgartner

\date		05.05.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This module implements the object access functions of the CN API library.
*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApiObject.h"

#include "cnApi.h"
#include "cnApiIntern.h"

#include <malloc.h>
#include <string.h>

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
static tObjTbl		*pObjTbl_l;
static DWORD		dwNumVarLinks_l; ///< Number local link assignments
static DWORD		dwMaxLinkEntries_l;
static DWORD		dwSelectObj_l;

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */
static void CnApi_resetLinkCounter(void);

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief	initialize objects module
*******************************************************************************/
int CnApi_initObjects(DWORD dwMaxLinks_p)
{

	/* allocate memory for object table */
	if ((pObjTbl_l = CNAPI_MALLOC (sizeof(tObjTbl) * dwMaxLinks_p)) == NULL)
	{
		return ERROR;
	}

	dwMaxLinkEntries_l = dwMaxLinks_p;
	CnApi_resetLinkCounter();

	return OK;
}

/**
********************************************************************************
\brief	cleanup objects module
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
\brief	add object

CnApi_linkObject() indirectly connects local variables to object numbers by writing
the linking information into a table. The table is subsequently read by the PCP
which links its PDOs to DPRAM by using a pointer.
The data type of linked local variable must match with data type of POWERLINK object !!!
Number of linked objects must match NUM_OBJECTS !!!
Application Example:   CnApi_linkObject(0x6000, 1, 1, &digitalIn[0]);

\param		wIndex_p			index of object in the object dictionary
\param		bSubIndex_p			subindex of object in the object dictionary
\param		wSize_p				data size of linked object
\param		pAdrs_p				pointer to object data


\return		status of write operation

*******************************************************************************/
int CnApi_linkObject(WORD wIndex_p, BYTE bSubIndex_p, WORD wSize_p, BYTE * pAdrs_p)
{
	tObjTbl		*pTbl;

	pTbl = pObjTbl_l + dwNumVarLinks_l;

	if (dwNumVarLinks_l < dwMaxLinkEntries_l)
	{
		pTbl->m_wIndex = wIndex_p;
		pTbl->m_bSubIndex = bSubIndex_p;
		pTbl->m_wSize = wSize_p;
		pTbl->m_pData = pAdrs_p;
		dwNumVarLinks_l ++;
		return OK;
	}
	else
	{
	    DEBUG_TRACE2(DEBUG_LVL_CNAPI_ERR, "\nERROR:"
        " Too many Object-Links! Failed at %lu th usage of %s()!\n"
	    "Please adapt NUM_OBJECTS!\n\n", dwNumVarLinks_l + 1, __func__);
		return ERROR;
	}
}

/**
********************************************************************************
\brief	setup actually mapped objects
\param wIndex_p     requested index
\param bSubIndex_p  requested subindex
\param wSize_p      OUT: size of object
\param pAdrs_p      OUT: pointer to object

The function CnApi_getObjectParam() compares the local linking table and the
descriptor table. If the object entry is found, the data pointer and
the respective size of the local object linking table will be returned.
So only currently mapped objects at PCP side will be considered in the copy table!
*******************************************************************************/
BOOL CnApi_getObjectParam(WORD wIndex_p, BYTE bSubIndex_p, WORD *wSize_p, BYTE **pAdrs_p)
{
	tObjTbl		*pTbl;
	int			i;

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
\brief	reset the object selector
*******************************************************************************/
void CnApi_resetObjectSelector(void)
{
	dwSelectObj_l = 0;
}


/**
********************************************************************************
\brief	increment oject structure to next object, if it exists
*******************************************************************************/
int CnApi_getNextObject(tCnApiObjId *pObjId)
{
	tObjTbl		*pCurrentObj;

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
\brief	write an object

CnApi_writeObjects() writes a object in the openPOWERLINK stack. The object must
exist in the object dictionary and must already be created by
CnApi_createObjectLinks(). The object will be identified with its \p index and
\p subIndex. \p dataLen must contain the size of the object data. A pointer to
the object data must be provided in \p p_data.

The synchronization flag is used to determine if the write data should be
queued or immediately written to the PCP. If \p sync is TRUE all queued
write data will be written to the PCP.

\param		index				index of object in the object dictionary
\param		subIndex			sub-index of object in the object dictionary
\param		dataLen				length of object data
\param		p_data				pointer to object data
\param		sync				synchronization flag. If FALSE, write request
								will be queued. If TRUE, write request will be
								transfered to the PCP.
\param		errCode				must contain a pointer where the function should
								store an error code if execution fails

\return		status of write operation
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
\brief	read an object

CnApi_readObjects() reads an object in the openPOWERLINK stack. The object must
exist in the object directory and must already be created by
CnApi_createObjectLinks().

\param		index				index of object in the object dictionary
\param		subIndex			sub-index of object in the object dictionary
\param		CN_readObjectCb		pointer to readObject callback function

\return		return
\retval		return_value		return_value_description
*******************************************************************************/
void CnApi_readObjects(WORD index, BYTE subIndex, int CN_readObjectCb)
{
    /* Add the object to the read queue */

    /* as soon as the object read is finished
     * the callback function shall be called.
     */

}

/**
 ********************************************************************************
 \brief signals an OBD default access as finished
 \param pObdParam_p
 \return tEplKernel value

 This function has to be called after an OBD access has been finished to
 inform the caller about this event.
 *******************************************************************************/
tEplKernel CnApi_DefObdAccFinished(tEplObdParam * pObdParam_p)
{
tEplKernel EplRet = kEplSuccessful;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "INFO: %s(%p) called\n", __func__, pObdParam_p);

    if (pObdParam_p->m_uiIndex == 0                      ||
        pObdParam_p->m_pfnAccessFinished == NULL  )
    {
        EplRet = kEplInvalidParam;
        goto Exit;
    }

    if ((pObdParam_p->m_ObdEvent == kEplObdEvPreRead)            &&
        ((pObdParam_p->m_SegmentSize != pObdParam_p->m_ObjSize) ||
         (pObdParam_p->m_SegmentOffset != 0)                    )  )
    {
        //segmented read access not allowed!
        pObdParam_p->m_dwAbortCode = EPL_SDOAC_UNSUPPORTED_ACCESS;
    }

    // call callback function which was assigned by caller
    EplRet = pObdParam_p->m_pfnAccessFinished(pObdParam_p);

    CNAPI_MEMSET(pObdParam_p, 0 , sizeof(tEplObdParam));

Exit:
    if (EplRet != kEplSuccessful)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: %s failed!\n", __func__);
    }
    return EplRet;

}

/* END-OF-FILE */
/******************************************************************************/

