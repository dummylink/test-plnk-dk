/**
********************************************************************************
\file       cnApiIntern.h

\brief      Internal header file of cnApi module

This header file contains internal definitions for the CN API and is used
library wide.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPIINTERN_H_
#define CNAPIINTERN_H_

/******************************************************************************/
/* includes */
#include "cnApiTyp.h"

#include "cnApiCfg.h"

/******************************************************************************/
/* defines */
#define PCP_MAGIC                   0x50435000      ///< magic number identifies valid PCP memory

/* Convert endian define to enable usage while runtime */
#ifdef AP_IS_BIG_ENDIAN
#define CNAPI_BIG_ENDIAN TRUE
#else
#define CNAPI_BIG_ENDIAN FALSE
#endif

/******************************************************************************/
/* typedefs */

/* Control Register Offsets, used for serial interface */
#ifdef CN_API_USING_SPI
#define PCP_CTRLREG_START_ADR                   0x00
#define PCP_CTRLREG_MAGIC_OFFSET                offsetof(tPcpCtrlReg, m_dwMagic)            //0x00
#define PCP_CTRLREG_PDI_REV_OFFSET              offsetof(tPcpCtrlReg, m_wPcpPdiRev)         //0x04
// reserved                                                                                 //0x06
#define PCP_CTRLREG_PCP_SYSID_OFFSET           offsetof(tPcpCtrlReg, m_wPcpSysId)           //0x08
#define PCP_CTRLREG_APP_DATE_OFFSET             offsetof(tPcpCtrlReg, m_dwAppDate)          //0x0C
#define PCP_CTRLREG_APP_TIME_OFFSET             offsetof(tPcpCtrlReg, m_dwAppTime)          //0x10
#define PCP_CTRLREG_NODE_ID_OFFSET              offsetof(tPcpCtrlReg, m_wNodeId)            //0x14
// reserved                                                                                 //0x16
#define PCP_CTRLREG_CMD_OFFSET                  offsetof(tPcpCtrlReg, m_wCommand)           //0x18
#define PCP_CTRLREG_STATE_OFFSET                offsetof(tPcpCtrlReg, m_wState)             //0x1A
#define PCP_CTRLREG_MAXCYCT_OFFSET              offsetof(tPcpCtrlReg, m_dwMaxCycleTime)     //0x1C
#define PCP_CTRLREG_MINCYCT_OFFSET              offsetof(tPcpCtrlReg, m_dwMinCycleTime)     //0x20
#define PCP_CTRLREG_CYCCAL_RESERVED_OFFSET      offsetof(tPcpCtrlReg, wCycleCalc_Reserved4) //0x26
#define PCP_CTRLREG_SYNCIR_CYCTIME_OFFSET       offsetof(tPcpCtrlReg, m_dwSyncIntCycTime)   //0x28
// reserved                                                                                 //0x2C
#define PCP_CTRLREG_EVENT_TYPE_OFFSET           offsetof(tPcpCtrlReg, m_wEventType)         //0x30
#define PCP_CTRLREG_EVENT_ARG_OFFSET            offsetof(tPcpCtrlReg, m_wEventArg)          //0x32
// reserved
// reserved
// reserved
#define PCP_CTRLREG_RELATIVE_TIME_LOW_OFFSET    offsetof(tPcpCtrlReg, m_dwRelativeTimeLow)  //0x40
#define PCP_CTRLREG_RELATIVE_TIME_HIGH_OFFSET   offsetof(tPcpCtrlReg, m_dwRelativeTimeHigh) //0x44
#define PCP_CTRLREG_NETTIME_NANOSEC_OFFSET      offsetof(tPcpCtrlReg, m_dwNetTimeNanoSec)   //0x48
#define PCP_CTRLREG_NETTIME_SEC_OFFSET          offsetof(tPcpCtrlReg, m_dwNetTimeSec)       //0x4C
#define PCP_CTRLREG_TIME_AFTER_SYNC_OFFSET      offsetof(tPcpCtrlReg, m_wTimeAfterSync)     //0x50
// reserved
#define PCP_CTRLREG_ASYNC_IRQ_CTRL_OFFSET       offsetof(tPcpCtrlReg, m_wAsyncIrqControl)   //0x52
#define PCP_CTRLREG_EVENT_ACK_OFFSET            offsetof(tPcpCtrlReg, m_wEventAck)          //0x54
#define PCP_CTRLREG_TPDO0_BUFSIZE_OFFSET        offsetof(tPcpCtrlReg, m_wTxPdo0BufSize)     //0x56
#define PCP_CTRLREG_TPDO0_OFST_OFFSET           offsetof(pCtrlReg_g->m_wTxPdo0BufAoffs)     //0x58
#define PCP_CTRLREG_RPDO0_BUFSIZE_OFFSET        offsetof(tPcpCtrlReg, m_wRxPdo0BufSize)     //0x5A
#define PCP_CTRLREG_RPDO0_OFST_OFFSET           offsetof(pCtrlReg_g->m_wRxPdo0BufAoffs)     //0x5C
#define PCP_CTRLREG_RPDO1_BUFSIZE_OFFSET        offsetof(tPcpCtrlReg, m_wRxPdo1BufSize)     //0x5E
#define PCP_CTRLREG_RPDO1_OFST_OFFSET           offsetof(pCtrlReg_g->m_wRxPdo1BufAoffs)     //0x60
#define PCP_CTRLREG_RPDO2_BUFSIZE_OFFSET        offsetof(tPcpCtrlReg, m_wRxPdo2BufSize)     //0x62
#define PCP_CTRLREG_RPDO2_OFST_OFFSET           offsetof(pCtrlReg_g->m_wRxPdo2BufAoffs)     //0x64
#define PCP_CTRLREG_TX_ASYNC_BUF0_SIZE_OFFSET   offsetof(tPcpCtrlReg, m_wTxAsyncBuf0Size)   //0x66
#define PCP_CTRLREG_TX_ASYNC_BUF0_OFST_OFFSET   offsetof(pCtrlReg_g->m_wTxAsyncBuf0Aoffs)   //0x68
#define PCP_CTRLREG_RX_ASYNC_BUF0_SIZE_OFFSET   offsetof(tPcpCtrlReg, m_wRxAsyncBuf0Size)   //0x6A
#define PCP_CTRLREG_RX_ASYNC_BUF0_OFST_OFFSET   offsetof(pCtrlReg_g->m_wRxAsyncBuf0Aoffs)   //0x6C
#define PCP_CTRLREG_TX_ASYNC_BUF1_SIZE_OFFSET   offsetof(tPcpCtrlReg, m_wTxAsyncBuf1Size)   //0x6E
#define PCP_CTRLREG_TX_ASYNC_BUF1_OFST_OFFSET   offsetof(pCtrlReg_g->m_wTxAsyncBuf1Aoffs)   //0x70
#define PCP_CTRLREG_RX_ASYNC_BUF1_SIZE_OFFSET   offsetof(tPcpCtrlReg, m_wRxAsyncBuf1Size)   //0x72
#define PCP_CTRLREG_RX_ASYNC_BUF1_OFST_OFFSET   offsetof(pCtrlReg_g->m_wRxAsyncBuf1Aoffs)   //0x74
// reserved                                                                                 //0x76
// reserved                                                                                 //0x78
// reserved                                                                                 //0x7A
// reserved                                                                                 //0x7C
#define PCP_CTRLREG_TPDO_0_ACK_OFFSET           offsetof(tPcpCtrlReg, m_wTxPdo0Ack)         //0x7E
#define PCP_CTRLREG_RPDO_0_ACK_OFFSET           offsetof(tPcpCtrlReg, m_wRxPdo0Ack)         //0x80
#define PCP_CTRLREG_RPDO_1_ACK_OFFSET           offsetof(tPcpCtrlReg, m_wRxPdo1Ack)         //0x82
#define PCP_CTRLREG_RPDO_2_ACK_OFFSET           offsetof(tPcpCtrlReg, m_wRxPdo2Ack)         //0x84
#define PCP_CTRLREG_SYNCIRQCTRL_OFFSET          offsetof(tPcpCtrlReg, m_wSyncIrqControl)    //0x86
// reserved                                                                                 //0x88
// reserved                                                                                 //0x8A
// reserved                                                                                 //0x8C
// reserved                                                                                 //0x8E
// reserved                                                                                 //0x90
#define PCP_CTRLREG_LED_CTRL_OFFSET             offsetof(tPcpCtrlReg, m_wLedControl)        //0x92
#define PCP_CTRLREG_LED_CNFG_OFFSET             offsetof(tPcpCtrlReg, m_wLedConfig)         //0x94
#define PCP_CTRLREG_SPAN                        sizeof(tPcpCtrlReg)

// other offset defines used only by serial interface
#define PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET    offsetof(tAsyncMsg, m_header)
#define PCP_PDI_SERIAL_ASYNCMSGPAYLOAD_OFFSET   offsetof(tAsyncMsg, m_chan)
#define PCP_PDI_SERIAL_ASYNC_SYNC_OFFSET  PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET + offsetof(tAsyncPdiBufCtrlHeader, m_bSync)
#define PCP_PDI_SERIAL_ASYNC_CHAN_OFFSET  PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET + offsetof(tAsyncPdiBufCtrlHeader, m_bChannel)
#define PCP_PDI_SERIAL_ASYNC_MSGT_OFFSET  PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET + offsetof(tAsyncPdiBufCtrlHeader, m_bMsgType)
#define PCP_PDI_SERIAL_ASYNC_FRMT_OFFSET  PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET + offsetof(tAsyncPdiBufCtrlHeader, m_wFrgmtLen)
#define PCP_PDI_SERIAL_ASYNC_STRM_OFFSET  PCP_PDI_SERIAL_ASYNCMSGHEADER_OFFSET + offsetof(tAsyncPdiBufCtrlHeader, m_dwStreamLen)
#endif /* CN_API_USING_SPI */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
extern volatile tPcpCtrlReg *       pCtrlReg_g;            ///< pointer to PCP control registers, Little Endian
extern BYTE *                       pDpramBase_g;          ///< pointer to Dpram base address
extern tPcpInitParam *               pInitPcpParam_g;        ///< pointer to POWERLINK init parameters

/******************************************************************************/
/* function declarations */

BYTE CnApi_getPcpState(void);
DWORD CnApi_getPcpMagic(void);
BOOL CnApi_verifyPcpSystemId(void);
BOOL CnApi_verifyPcpPdiRevision(void);
void CnApi_setApCommand(BYTE bCmd_p);

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */


#endif /* CNAPIINTERN_H_ */

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

