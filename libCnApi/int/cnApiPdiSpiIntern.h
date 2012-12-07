/**
********************************************************************************
\file       cnApiPdiSpiIntern.h

\brief      Private header file of CN API SPI library

This header file contains the private parts of the SPI driver.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef _CNAPI_PDI_SPI_INTERN_H_
#define _CNAPI_PDI_SPI_INTERN_H_

/******************************************************************************/
/* includes */
#include <cnApiGlobal.h>
#include <cnApiDebug.h>
#include <cnApi.h>
#include <cnApiPdiSpi.h>

#ifdef CN_API_USING_SPI

/******************************************************************************/
/* defines */

//errors
#define PDISPI_OK                       (0)
#define PDISPI_ERROR                    (-1)

//timeouts
#define PCP_SPI_PRESENCE_TIMEOUT        50

//test mudules
#define DEBUG_VERIFY_SPI_HW_CONNECTION

#ifdef DEBUG_VERIFY_SPI_HW_CONNECTION
#define SPI_L1_TESTS                    (256 * 10 )         ///< SPI HW test with pattern 0x00 - 0xff (10 times)
#endif

//general define
#define PDISPI_MAX_SQ                   (32)                ///< max number of bytes in sequence (WRSQ/RDSQ)
#define PDISPI_MAX_TX                   (PDISPI_MAX_SQ + 4) ///< necessary tx buffers (HIG/MID/LOWADDR + WRSQ + DATA)
#define PDISPI_MAX_RX                   (PDISPI_MAX_SQ)     ///< necessary rx buffers (only DATA)
#define PDISPI_THRSHLD_SIZE             (3)                 ///< 3 bytes are transfered by sequence (WRSQ/RDSQ) approach

#define PDISPI_MAX_SIZE                 32768                   ///< max Nr. of bytes able to address (2^15)
#define PDISPI_MAX_ADR_OFFSET           (PDISPI_MAX_SIZE - 1)   ///< highest possible address of PDI SPI

//WAKEUP
#define PDISPI_WAKEUP                    0x03U
#define PDISPI_WAKEUP1                    0x0AU
#define PDISPI_WAKEUP2                    0x0CU
#define PDISPI_WAKEUP3                    0x0FU

//CMD Frame:
// CMD(2..0) | DATA(4..0)
#define PDISPI_CMD_OFFSET               (5)
#define PDISPI_CMD_HIGHADDR             (0x4) << PDISPI_CMD_OFFSET //0b100
#define PDISPI_CMD_MIDADDR              (0x5) << PDISPI_CMD_OFFSET //0b101
#define PDISPI_CMD_WR                   (0x6) << PDISPI_CMD_OFFSET //0b110
#define PDISPI_CMD_RD                   (0x7) << PDISPI_CMD_OFFSET //0b111
#define PDISPI_CMD_WRSQ                 (0x1) << PDISPI_CMD_OFFSET //0b001
#define PDISPI_CMD_RDSQ                 (0x2) << PDISPI_CMD_OFFSET //0b010
#define PDISPI_CMD_LOWADDR              (0x3) << PDISPI_CMD_OFFSET //0b011
#define PDISPI_CMD_IDLE                 (0x0) << PDISPI_CMD_OFFSET //0b000

//ADDR pattern
#define PDISPI_ADDR_HIGHADDR_OFFSET     (10)
#define PDISPI_ADDR_MIDADDR_OFFSET      (5)
#define PDISPI_ADDR_LOWADDR_OFFSET      (0)
#define PDISPI_ADDR_ADDR_OFFSET         (0)
#define PDISPI_ADDR_MASK                (0x1F)
#define PDISPI_ADDR_HIGHADDR_MASK       PDISPI_ADDR_MASK << PDISPI_ADDR_HIGHADDR_OFFSET
#define PDISPI_ADDR_MIDADDR_MASK        PDISPI_ADDR_MASK << PDISPI_ADDR_MIDADDR_OFFSET
#define PDISPI_ADDR_LOWADDR_MASK        PDISPI_ADDR_MASK << PDISPI_ADDR_LOWADDR_OFFSET
#define PDISPI_ADDR_ADDR_MASK           PDISPI_ADDR_MASK << PDISPI_ADDR_ADDR_OFFSET

//function definitions
#define PDISPI_USLEEP(x)                usleep(x)

/******************************************************************************/
/* typedefs */
typedef struct _tPdiSpiInstance
{
    tSpiMasterTxHandler     m_pfnSpiMasterTxHandler;    ///< Tx Handler of the SPI Master Component
    tSpiMasterRxHandler     m_pfnSpiMasterRxHandler;    ///< Rx Handler of the SPI Master Component

    tSpiMasterEnGloInt      m_pfnEnableGlobalIntH;    ///< function pointer to global interrupt enable callback
    tSpiMasterDisGloInt     m_pfnDisableGlobalIntH;    ///< function pointer to global interrupt disable callback

    WORD                    m_addrReg;    ///< Local copy of the Address Register of the PDI SPI Slave


    BYTE                    m_txBuffer[PDISPI_MAX_TX];    ///< Tx Buffer
    int                     m_toBeTx;

    BYTE                    m_rxBuffer[PDISPI_MAX_RX];    ///< Rx Buffer
    int                     m_toBeRx;
} tPdiSpiInstance;

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
int CnApi_initSpiMaster
(
    tSpiMasterTxHandler     pfnSpiMasterTxH_p,
    tSpiMasterRxHandler     pfnSpiMasterRxH_p,
    tSpiMasterEnGloInt      pfnEnableGlobalIntH_p,
    tSpiMasterDisGloInt     pfnDisableGlobalIntH_p
);

int CnApi_Spi_writeByte
(
    WORD    uwAddr_p,
    BYTE  ubData_p
);

int CnApi_Spi_readByte
(
    WORD    uwAddr_p,
    BYTE  *pData_p
);

int CnApi_Spi_writeWord
(
    WORD    uwAddr_p,
    WORD    wData_p,
    BYTE    ubBigEndian_p
);

int CnApi_Spi_readWord
(
    WORD    uwAddr_p,
    WORD    *pData_p,
    BYTE    ubBigEndian_p
);

int CnApi_Spi_writeDword
(
    WORD    uwAddr_p,
    DWORD   dwData_p,
    BYTE    ubBigEndian_p
);

int CnApi_Spi_readDword
(
    WORD    uwAddr_p,
    DWORD   *pData_p,
    BYTE    ubBigEndian_p
);

int CnApi_Spi_writeQword
(
    WORD    uwAddr_p,
    QWORD   qwData_p,
    BYTE    ubBigEndian_p
);

int CnApi_Spi_readQword
(
    WORD    uwAddr_p,
    QWORD   *pData_p,
    BYTE    ubBigEndian_p
);

int CnApi_Spi_read
(
   WORD    wPcpAddr_p,
   WORD    wSize_p,
   BYTE    *pApTgtVar_p
);

int CnApi_Spi_write
(
   WORD    wPcpAddr_p,
   WORD    wSize_p,
   BYTE    *pApSrcVar_p
);

#endif //CN_API_USING_SPI

#endif /* _CNAPI_PDI_SPI_INTERN_H_ */

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


