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
#include "cnApi.h"
#include "cnApiIntern.h"

#include <malloc.h>

/******************************************************************************/
/* defines */
#define		NUM_OBJ_CREATE_ENTRIES				100


/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
static tObjTbl		*pObjTbl;
static DWORD		dwNumObjs;
static DWORD		dwMaxObjs;
static DWORD		dwSelectObj;

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief	initialize objects module
*******************************************************************************/
int CnApi_initObjects(DWORD dwNumObjects_p)
{

	/* allocate memory for object table */
	if ((pObjTbl = malloc (sizeof(tObjTbl) * dwNumObjects_p)) == NULL)
	{
		return ERROR;
	}

	dwNumObjs = 0;
	dwMaxObjs = dwNumObjects_p;

	return OK;
}

/**
********************************************************************************
\brief	cleanup objects module
*******************************************************************************/
void CnApi_cleanupObjects(void)
{
	free (pObjTbl);
}

/**
********************************************************************************
\brief	add object

CnApi_linkObject() indirectly connects local variables to object numbers by writing
the linking information into a table. The table is subsequently read by the PCP
which links its PDOs to DPRAM by using a pointer.
The data type of linked local variable must match with data type of POWERLINK object !!!
Number of linked objects must match NUM_OBJECTS !!!

\param		wIndex_p			index of object in the object dictionary
\param		bSubIndex_p			subindex of object in the object dictionary
\param		wSize_p				data size of linked object
\param		pAdrs_p				pointer to object data


\return		status of write operation
    CnApi_linkObject(0x6000, 1, 1, &digitalIn[0]);
*******************************************************************************/
int CnApi_linkObject(WORD wIndex_p, BYTE bSubIndex_p, WORD wSize_p, char *pAdrs_p)
{
	tObjTbl		*pTbl;

	pTbl = pObjTbl + dwNumObjs;

	if (dwNumObjs < dwMaxObjs)
	{
		pTbl->m_wIndex = wIndex_p;
		pTbl->m_bSubIndex = bSubIndex_p;
		pTbl->m_wSize = wSize_p;
		pTbl->m_pData = pAdrs_p;
		dwNumObjs ++;
		return OK;
	}
	else
	{
		return ERROR;
	}
}

/**
********************************************************************************
\brief	setup actually mapped objects

The function CnApi_setupMappedObjects() compares the local linking table and the
descriptor table. If the entries line up equally, take the data pointer and
the respective size out of the linking table. So only currently mapped objects
at PCP side will be considered in the copy table!
*******************************************************************************/
BOOL CnApi_setupMappedObjects(WORD wIndex_p, BYTE bSubIndex_p, WORD *wSize_p, char **pAdrs_p)
{
	tObjTbl		*pTbl;
	int			i;

	for (i = 0; i < dwNumObjs; i++)
	{
		pTbl = pObjTbl + i;
		if ((pTbl->m_wIndex == wIndex_p) &&
			(pTbl->m_bSubIndex == bSubIndex_p))
		{
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
	dwSelectObj = 0;
}

/**
********************************************************************************
\brief	increment oject structure to next object, if it exists
*******************************************************************************/
int CnApi_getNextObject(tCnApiObjId *pObjId)
{
	tObjTbl		*pCurrentObj;

	if (dwSelectObj >= dwNumObjs)
		return 0;

	pCurrentObj = pObjTbl + dwSelectObj;

	pObjId->m_wIndex = pCurrentObj->m_wIndex;
	pObjId->m_bSubIndex = pCurrentObj->m_bSubIndex;
	pObjId->m_bNumEntries = 1;

	dwSelectObj++;

	return 1;
}

/**
********************************************************************************
\brief	create an object

CnApi_createObjectLinks() creates the PDO links in the openPOWERLINK stack. Precisely
it commands the PCP to link objects to the heap by creating an object link table.
This table has to be send in a buffer message to the PCP. The objects
must exist in the PCPs object dictionary to be created.
*******************************************************************************/
void CnApi_createObjectLinks(void)
{
	tCnApiObjId 		objId[NUM_OBJ_CREATE_ENTRIES];
	register int		i;
	tCnApiObjId			*pObjId;

	i = 0;
	pObjId = objId;

	CnApi_resetObjectSelector();
	while (CnApi_getNextObject(pObjId) != 0)
	{
		pObjId++;
		i++;
		if (i == NUM_OBJ_CREATE_ENTRIES)
		{
			/* no more objects do fit in the message, therefore execute create command */
			CnApi_doCreateObjLinksReq(objId, i);
			i = 0;
			pObjId = objId;
		}
	}

	if (i < NUM_OBJ_CREATE_ENTRIES)
	{
		/* there a some objects leftover to be created, let's create them now */
		CnApi_doCreateObjLinksReq(objId, i);
	}
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



/* END-OF-FILE */
/******************************************************************************/

