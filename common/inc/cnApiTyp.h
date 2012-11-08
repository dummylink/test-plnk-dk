/**
********************************************************************************
\file       cnApiTyp.h

\brief      Global header file for PCP PDI and libCnApi

This header provides data structures for the PCP and AP processors. It defines
message formats and common types.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPITYP_H_
#define CNAPITYP_H_

/******************************************************************************/
/* includes */
#include "cnApiGlobal.h"
#include "cnApiDebug.h"

/******************************************************************************/
/* defines */

/* CN Api initialization */
#define CN_API_INIT_PARAM_STRNG_SIZE 33

/* indicator for invalid array element */
#define INVALID_ELEMENT            0xFF

/* defines for LED_CNTRL */
/* bit pattern has to be set in LED_CNFG to enable LED forcing by SW
for AP and PCP. AP forcing overwrites any other LED signal value settings. */
#define LED_STATUS      0
#define LED_ERROR       1
#define LED_PHY0_LINK   2
#define LED_PHY0_ACT    3
#define LED_PHY1_LINK   4
#define LED_PHY1_ACT    5
#define LED_OPTION_0    6
#define LED_OPTION_1    7

/* SYNC_IRQ_CTRL for AP and PCP */
#define SYNC_IRQ_REQ      15        ///< AP sets desired synchronization mode (IR = 1, polling=0),
                                    ///< PCP reads the mode (PCP RO register)

/******************************************************************************/
/* typedefs */

/**
 * CN API LED module
 *
 * tCnApiLedType contains the states of the LED module
 */
typedef enum
{
    kCnApiLedTypeStatus      = 0x00,
    kCnApiLedTypeError       = 0x01,
    kCnApiLedTypePhy0Link    = 0x02,
    kCnApiLedTypePhy0Active  = 0x03,
    kCnApiLedTypePhy1Link    = 0x04,
    kCnApiLedTypePhy1Active  = 0x05,
    kCnApiLedTypeOpt0        = 0x06,
    kCnApiLedTypeOpt1        = 0x07,
    kCnApiLedInit         = 0x08,

} tCnApiLedType;

/**
 * CN API status codes
 *
 * tCnApiStatus contains the status codes that could be returned by the API
 * functions.
 */
typedef enum eCnApiStatus{
    kCnApiStatusOk = 0,                 ///< Ok, no error!
    kCnApiStatusError,                  ///< error
    kCnApiStatusInvalidParameter,       ///< invalid or missing parameter
    kCnApiStatusMsgBufFull,             ///< message buffer is full
    kCnApiStatusMsgBufEmpty,            ///< message buffer is empty
    kCnApiStatusDataTooLong,            ///< data too long for message buffer
    kCnApiStatusObjectNotExist,         ///< object does not exist
    kCnApiStatusAllocationFailed,       ///< memory allocation failed
    kCnApiStatusObjectLinkFailed,       ///< linking object to memory failed
    kCnApiStatusCommandNotAccepted,     ///< command isn't accepted
    kCnApiStatusNoMsg,                  ///< no message avaiable to transfer
    kCnApiStatusBusy                    ///< api us currently busy
} tCnApiStatus;


/* definitions for PCP state machine, transitions and states */
typedef enum ePcpStates { //TODO: define state "none?" - adapt docu for correct values!
    kPcpStateBooted = 0x00,
    kPcpStateInit = 0x01,
    kPcpStatePreOp = 0x02,
    kPcpStateReadyToOperate = 0x03,
    kPcpStateOperational = 0x04,
    kNumPcpStates = 0x05,
    kPcpStateInvalid = 0xEE,
} tPcpStates;

/**
 * \brief enumeration with valid AP commands
 */
typedef enum eApCmd{
    kApCmdNone = -1,
    kApCmdInit = 0,
    kApCmdPreop = 1,
    kApCmdReadyToOperate = 2,
    kApCmdReset = 3
} tApCmd;

typedef struct sObjTbl {
    WORD        m_wIndex;
    BYTE        m_bSubIndex;
    BYTE        m_bPad;
    WORD        m_wSize;
    BYTE        *m_pData;
} tObjTbl;

/**
 * \brief structure for POWERLINK initialization parameters
 */
typedef struct sPcpInitParm {
    BYTE            m_abMac[6];
    BYTE            m_bNodeId;
    WORD            m_wMtu;
    DWORD           m_dwIpAddress;
    DWORD           m_dwSubNetMask;
    DWORD           m_dwDefaultGateway;
    DWORD           m_dwRevision;
    DWORD           m_dwSerialNum;
    DWORD           m_dwVendorId;
    DWORD           m_dwProductCode;
    DWORD           m_dwDeviceType;
    BYTE            m_strDevName[CN_API_INIT_PARAM_STRNG_SIZE];
    BYTE            m_strHwVersion[CN_API_INIT_PARAM_STRNG_SIZE];
    BYTE            m_strSwVersion[CN_API_INIT_PARAM_STRNG_SIZE];
    BYTE            m_strHostname[CN_API_INIT_PARAM_STRNG_SIZE];
} tPcpInitParam;

/**
* \brief PCP control registers
*
* tPcpCtrlReg defines the PCP control registers.
*/
typedef struct sPcpControlReg {
    volatile DWORD      m_dwMagic;             ///< magic number indicating correct PCP PDI memory start address
    volatile WORD       m_wPcpPdiRev;          ///< revision of PCP PDI (control and status register)
    volatile WORD       m_wPcpSysId;           ///< system ID of PCP design, value is user defined
    volatile DWORD      Reserved1;
    volatile DWORD      m_dwAppDate;           ///< Powerlink application date
    volatile DWORD      m_dwAppTime;           ///< Powerlink application time
    volatile WORD       m_wNodeId;             ///< Powerlink node ID; can by read by AP at related event
    volatile WORD       Reserved2;
    volatile WORD       m_wCommand;            ///< AP issues commands to this register
    volatile WORD       m_wState;              ///< state of the PCP
    volatile DWORD      m_dwMaxCycleTime;      ///< upper limit of synchronous-IR cycle time the AP wants to process
    volatile DWORD      m_dwMinCycleTime;      ///< lower limit of synchronous-IR cycle time the AP can process
    volatile WORD       Reserved3;             ///< correction factor(-- currently not used --)
    volatile WORD       wCycleCalc_Reserved4;  ///< multiple of Powerlink cyle time for synchronous-IR
    volatile DWORD      m_dwSyncIntCycTime;    ///< cycle time of synchronous-IR issued to the AP for PDO processing
    volatile DWORD      Reserved5;
    volatile WORD       m_wEventType;          ///< type of event (e.g. state change, error, ...)
    volatile WORD       m_wEventArg;           ///< event argument, if applicable (e.g. error code, state, ...)
    volatile DWORD      m_dwDefaultGateway;    ///< The default gateway of the CN (valid on CMD ready to operate)
    volatile DWORD      Reserved7;
    volatile DWORD      Reserved8;
    volatile DWORD      m_dwRelativeTimeLow;   ///< low dword of SoC relative time
    volatile DWORD      m_dwRelativeTimeHigh;  ///< high dword of SoC relative time
    volatile DWORD      m_dwNetTimeNanoSec;    ///< low dword of SoC nettime
    volatile DWORD      m_dwNetTimeSec;        ///< high dword of SoC nettime
    volatile WORD       m_wTimeAfterSync;      ///< time elapsed after the last synchronisation interrupt
    volatile WORD       Reserved9;
    volatile WORD       m_wAsyncIrqControl;    ///< asynchronous IRQ control register, contains IR acknowledge (at AP side)
    volatile WORD       m_wEventAck;           ///< acknowledge for events and asynchronous IR signal
    volatile WORD       m_wTxPdo0BufSize;      ///< buffer size for TPDO communication AP -> PCP
    volatile WORD       m_wTxPdo0BufAoffs;     ///< buffer address for TPDO communication AP -> PCP
    volatile WORD       m_wRxPdo0BufSize;      ///< buffer size for RPDO communication PCP -> AP
    volatile WORD       m_wRxPdo0BufAoffs;     ///< buffer address for RPDO communication PCP -> AP
    volatile WORD       m_wRxPdo1BufSize;      ///< buffer size for RPDO communication PCP -> AP
    volatile WORD       m_wRxPdo1BufAoffs;     ///< buffer address for RPDO communication PCP -> AP
    volatile WORD       m_wRxPdo2BufSize;      ///< buffer size for RPDO communication PCP -> AP
    volatile WORD       m_wRxPdo2BufAoffs;     ///< buffer address for RPDO communication PCP -> AP
    volatile WORD       m_wTxAsyncBuf0Size;    ///< buffer size for asynchronous communication AP -> PCP
    volatile WORD       m_wTxAsyncBuf0Aoffs;   ///< buffer address for asynchronous communication AP -> PCP
    volatile WORD       m_wRxAsyncBuf0Size;    ///< buffer size for asynchronous communication PCP -> AP
    volatile WORD       m_wRxAsyncBuf0Aoffs;   ///< buffer address for asynchronous communication PCP -> AP
    volatile WORD       m_wTxAsyncBuf1Size;    ///< buffer size for asynchronous communication AP -> PCP
    volatile WORD       m_wTxAsyncBuf1Aoffs;   ///< buffer address for asynchronous communication AP -> PCP
    volatile WORD       m_wRxAsyncBuf1Size;    ///< buffer size for asynchronous communication PCP -> AP
    volatile WORD       m_wRxAsyncBuf1Aoffs;   ///< buffer address for asynchronous communication PCP -> AP
    volatile WORD       Reserved10;
    volatile WORD       Reserved11;
    volatile WORD       Reserved12;
    volatile WORD       Reserved13;
    volatile WORD       m_wTxPdo0Ack;          ///< address acknowledge register of TPDO buffer nr. 0
    volatile WORD       m_wRxPdo0Ack;          ///< address acknowledge register of RPDO buffer nr. 0
    volatile WORD       m_wRxPdo1Ack;          ///< address acknowledge register of RPDO buffer nr. 1
    volatile WORD       m_wRxPdo2Ack;          ///< address acknowledge register of RPDO buffer nr. 2
    volatile WORD       m_wSyncIrqControl;     ///< PDO synchronization IRQ control register, contains snyc. IR acknowledge (at AP side)
    volatile WORD       Reserved14;
    volatile DWORD      Reserved15;
    volatile DWORD      Reserved16;
    volatile WORD       m_wLedControl;         ///< Powerlink IP-core Led output control register
    volatile WORD       m_wLedConfig;          ///< Powerlink IP-core Led output configuration register
} PACK_STRUCT tPcpCtrlReg;

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */


#endif /* CNAPITYP_H_ */

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

