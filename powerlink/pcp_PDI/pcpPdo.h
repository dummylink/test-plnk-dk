/******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       pcpPdo.h

\brief      header file for pcpPdo module

\author     hoggerm

\date       29.04.2011

\since      29.04.2011

*******************************************************************************/

#ifndef PCPPDO_H_
#define PCPPDO_H_

/******************************************************************************/
/* includes */
#include <EplObd.h>

/******************************************************************************/
/* defines */
#define EPL_PDOU_OBD_IDX_RX_COMM_PARAM  0x1400
#define EPL_PDOU_OBD_IDX_RX_MAPP_PARAM  0x1600
#define EPL_PDOU_OBD_IDX_TX_COMM_PARAM  0x1800
#define EPL_PDOU_OBD_IDX_TX_MAPP_PARAM  0x1A00
#define EPL_PDOU_OBD_IDX_MAPP_PARAM     0x0200
#define EPL_PDOU_OBD_IDX_MASK           0xFF00
#define EPL_PDOU_PDO_ID_MASK            0x00FF

/******************************************************************************/
/* typedefs */

/**
 * \brief structure connects LinkPdosReq message and OBD mapping handle
 */
typedef struct sLinkPdosReqComCon {
    WORD       m_wMapIndex;
    BYTE       m_bPdoDir;                   ///< value type: tPdoDir
    BYTE       m_bMapObjCnt;
    BYTE       m_bBufferNum;
    BYTE       m_bMapVersion;
    WORD       m_wComConHdl;                ///< PDI connection handle
} tLinkPdosReqComCon;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */
int Gi_initPdo(void);
void Gi_preparePdiPdoReadAccess(BYTE bTpdoNum);
void Gi_signalPdiPdoWriteAccess(BYTE bRpdoNum);

BOOL Gi_setupPdoDesc(tLinkPdosReqComCon * pLinkPdosReqComCon_p,
                     BYTE bDirection_p,
                     WORD *pCurrentDescrOffset_p,
                     tLinkPdosReq *pLinkPdoReq_p,
                     WORD wMaxStoreSpace);
tEplKernel Gi_checkandConfigurePdoPdi(unsigned int uiMappParamIndex_p,
                                                 BYTE bMappObjectCount_p,
                                                 tEplObdAccess AccessType_p,
                                                 tEplObdCbParam* pParam_p);


#endif /* PCPPDO_H_ */

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

