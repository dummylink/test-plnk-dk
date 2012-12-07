/**
********************************************************************************
\file       cnApiPdiSpi.c

\brief      Library for FPGA PDI via SPI

This module implements  the API parts of the SPI driver.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include <cnApi.h>
#include <cnApiDebug.h>
#include <string.h>              // for memcpy() memset()

#include "cnApiPdiSpiIntern.h"



#ifdef CN_API_USING_SPI


/******************************************************************************/
/* defines */

#define ADDR_WR_DOWN    1
#define ADDR_CHECK      2
#define ADDR_WR_DOWN_LO 3
#define ADDR_CHECK_LO   4


/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */
static void byteSwap(
    BYTE *pVal_p, ///< register base to be swapped
    int iSize_p ///< size of register
);

static int writeSq
(
    WORD            uwAddr_p,       ///< PDI Address to be written to
    WORD            uwSize_p,       ///< Write data size (bytes)
    BYTE            *pData_p        ///< Write data
);

static int readSq
(
    WORD            uwAddr_p,       ///< PDI Address to be read from
    WORD            uwSize_p,       ///< Read data size
    BYTE            *pData_p        ///< Read data
);

static int setPdiAddrReg
(
    WORD            uwAddr_p,   //address to be accessed at PDI
    int             fWr_p       //way of handle address change
);

static int sendTxBuffer
(
    void
);

static int recRxBuffer
(
    void
);

static int buildCmdFrame
(
    WORD            uwPayload_p,   //CMD frame address
    BYTE            *pFrame_p,  //buffer for CMD frame to be built
    BYTE            ubTyp_p     //CMD frame type
);

/* PDI SPI Driver Instance
 */
static tPdiSpiInstance PdiSpiInstance_l;

/******************************************************************************/
/* public functions */

/**
********************************************************************************
\brief  initializes the local SPI Master and the PDI SPI

CnApi_initSpiMaster() has to be called before using any other function of
this library to register the SPI Master Tx/Rx handler.
Furthermore the function sets the Address Register of the PDI SPI Slave
to a known state.

\param  pfnSpiMasterTxH_p          SPI Master Tx Handler callback
\param  pfnSpiMasterRxH_p          SPI Master Rx Handler callback
\param  pfnEnableGlobalIntH_p      SPI Master critical section enable
\param  pfnDisableGlobalIntH_p     SPI Master critical section disable

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
int CnApi_initSpiMaster
(
    tSpiMasterTxHandler     pfnSpiMasterTxH_p,
    tSpiMasterRxHandler     pfnSpiMasterRxH_p,
    tSpiMasterEnGloInt      pfnEnableGlobalIntH_p,
    tSpiMasterDisGloInt     pfnDisableGlobalIntH_p
)
{
    int     iRet = PDISPI_OK;
    int     iCnt;
    DWORD   dwCnt;
    BYTE    bPattern = 0;
    BYTE    bnegPattern = 0;
    WORD    wSpiErrors = 0;
    BOOL    fPcpSpiPresent = FALSE;

    if( (pfnSpiMasterTxH_p == 0) || (pfnSpiMasterRxH_p == 0) ||
        (pfnEnableGlobalIntH_p == NULL) || (pfnDisableGlobalIntH_p == NULL))
    {
        iRet = PDISPI_ERROR;

        goto exit;
    }

    memset(&PdiSpiInstance_l, 0, sizeof(PdiSpiInstance_l));

    PdiSpiInstance_l.m_pfnEnableGlobalIntH = pfnEnableGlobalIntH_p;
    PdiSpiInstance_l.m_pfnDisableGlobalIntH = pfnDisableGlobalIntH_p;

    PdiSpiInstance_l.m_pfnSpiMasterTxHandler = pfnSpiMasterTxH_p;
    PdiSpiInstance_l.m_pfnSpiMasterRxHandler = pfnSpiMasterRxH_p;

#ifdef DEBUG_VERIFY_SPI_HW_CONNECTION
    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "\nVerifying HW layer of SPI connection.\n");
    PDISPI_USLEEP(1000000);
    //IOWR_ALTERA_AVALON_PIO_DATA(OUTPORT_AP_BASE, 0x1); //indicate start

    /* check if SPI HW layer is working correctly */
    for(dwCnt = 0; dwCnt < SPI_L1_TESTS; dwCnt++)
    {
        PdiSpiInstance_l.m_txBuffer[0] = bPattern;
        PdiSpiInstance_l.m_toBeTx = 1;

        //send one byte
        iRet = sendTxBuffer();

        if( iRet != PDISPI_OK )
        {
            goto exit;
        }

        //receive one byte
        PdiSpiInstance_l.m_toBeRx = 1;

        iRet = recRxBuffer();

        if( iRet != PDISPI_OK )
        {
            goto exit;
        }

        bnegPattern = ~bPattern;

        //check if SPI inverts the byte (indicates SPI boot state)
        if(PdiSpiInstance_l.m_rxBuffer[0] != bnegPattern)
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "\nTx Byte: 0x%02X", PdiSpiInstance_l.m_txBuffer[0]);
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "\nRx Byte: 0x%02X", PdiSpiInstance_l.m_rxBuffer[0]);
            // Count Errors
            wSpiErrors++;
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, " ...Error!\n");

            //IOWR_ALTERA_AVALON_PIO_DATA(OUTPORT_AP_BASE, 0x7); //indicate end
        }

        bPattern++;
    }
    //end of SPI HW Test

    //IOWR_ALTERA_AVALON_PIO_DATA(OUTPORT_AP_BASE, 0x8); //indicate end
    DEBUG_TRACE2(DEBUG_LVL_CNAPI_INFO, "\nSPI Errors: %d of %d transmissions.\n", wSpiErrors, SPI_L1_TESTS);

    if (wSpiErrors > 0)
    {   //SPI HW Test failed

        //IOWR_ALTERA_AVALON_PIO_DATA(OUTPORT_AP_BASE, 0xf); //indicate error & end
        iRet = PDISPI_ERROR;
        goto exit;
    }
#endif /* DEBUG_VERIFY_SPI_HW_CONNECTION */

    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, "\nStarting SPI connection..");

    /* check if PCP SPI slave is present */
    for(iCnt = 0; iCnt < PCP_SPI_PRESENCE_TIMEOUT; iCnt++)
    {
        //send out wake up frame to enter idle surely!
        PdiSpiInstance_l.m_txBuffer[0] = PDISPI_WAKEUP;
        PdiSpiInstance_l.m_txBuffer[1] = PDISPI_WAKEUP1;
        PdiSpiInstance_l.m_txBuffer[2] = PDISPI_WAKEUP2;
        PdiSpiInstance_l.m_txBuffer[3] = PDISPI_WAKEUP3;
        PdiSpiInstance_l.m_toBeTx = 4;

        //send byte in Tx buffer
        iRet = sendTxBuffer();

        if( iRet != PDISPI_OK )
        {
            goto exit;
        }

        //receive one byte
        PdiSpiInstance_l.m_toBeRx = 1;

        iRet = recRxBuffer();

        if( iRet != PDISPI_OK )
        {
            goto exit;
        }

        if(PdiSpiInstance_l.m_rxBuffer[0] == PDISPI_WAKEUP3)
        {
            //received last wake up pattern without inversion
            //=> pcpSpi has already woken up
            fPcpSpiPresent = TRUE;
            break;
        }

        //invert received packet
        PdiSpiInstance_l.m_rxBuffer[0] = ~PdiSpiInstance_l.m_rxBuffer[0];

        if(PdiSpiInstance_l.m_rxBuffer[0] == PDISPI_WAKEUP3)
        {
            //received last wake up pattern with inversion
            //=> wake up was successful
            fPcpSpiPresent = TRUE;
            break;
        }

        PDISPI_USLEEP(10000);
    }

    if(!fPcpSpiPresent)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, ".ERROR!\n\n");

        /* PCP_SPI_PRESENCE_TIMEOUT exceeded */
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "TIMEOUT: No connection to PCP! SPI initialization failed!\n");
        iRet = PDISPI_ERROR;
        goto exit;
    }
    else
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO, ".OK!\n");
    }

    //send out some idle frames
    PdiSpiInstance_l.m_toBeTx = PDISPI_MAX_TX;
    memset(&PdiSpiInstance_l.m_txBuffer, PDISPI_CMD_IDLE, PDISPI_MAX_TX);

    iRet = sendTxBuffer();

    if( iRet != PDISPI_OK )
    {
        goto exit;
    }

    //set address register in PDI to zero
    iRet = setPdiAddrReg(0, ADDR_WR_DOWN_LO);

    if( iRet != PDISPI_OK )
    {
        goto exit;
    }

    iRet = sendTxBuffer();

exit:
    return iRet;
}

/**
********************************************************************************
\brief  write byte to the CN PDI via SPI

CnApi_Spi_writeByte() writes one byte to the POWERLINK CN PDI via SPI.
This byte will be written to PDI address.

\param  uwAddr_p     PDI address to be written to
\param  ubData_p     Write data

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
int CnApi_Spi_writeByte
(
    WORD          uwAddr_p,
    BYTE           ubData_p
)
{
    int             iRet = PDISPI_OK;
    BYTE            ubTxData;

    PdiSpiInstance_l.m_pfnDisableGlobalIntH();

    //check the pdi's address register for the following cmd
    iRet = setPdiAddrReg(uwAddr_p, ADDR_CHECK);
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }

    buildCmdFrame(uwAddr_p, &ubTxData, PDISPI_CMD_WR);

    //store CMD to Tx Buffer
    if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
    {   //buffer full
        iRet = PDISPI_ERROR;
        goto exit;
    }
    PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;

    //store Data to Tx Buffer
    if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
    {   //buffer full
        iRet = PDISPI_ERROR;
        goto exit;
    }
    PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubData_p;

    //send bytes in Tx buffer
    iRet = sendTxBuffer();

    PdiSpiInstance_l.m_addrReg++;

    PdiSpiInstance_l.m_pfnEnableGlobalIntH();

exit:
    return iRet;
}

/**
********************************************************************************
\brief  read one byte from the CN PDI via SPI

CnApi_Spi_readByte() reads one byte from the POWERLINK CN PDI via SPI.
This data will be read from PDI address and stored to a local address.

\param  uwAddr_p     PDI address to be read from
\param  pData_p      Read data

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
int CnApi_Spi_readByte
(
    WORD          uwAddr_p,
    BYTE           *pData_p
)
{
    int             iRet = PDISPI_OK;
    BYTE            ubTxData;

    PdiSpiInstance_l.m_pfnDisableGlobalIntH();

    //check the pdi's address register for the following cmd
    iRet = setPdiAddrReg(uwAddr_p, ADDR_CHECK);
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }

    buildCmdFrame(uwAddr_p, &ubTxData, PDISPI_CMD_RD);

    //store CMD to Tx Buffer
    if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
    {   //buffer full
        iRet = PDISPI_ERROR;
        goto exit;
    }
    PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;

    //send bytes in Tx buffer
    iRet = sendTxBuffer();
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }

    //receive byte
    if( PdiSpiInstance_l.m_toBeRx >= PDISPI_MAX_RX )
    {   //buffer full
        iRet = PDISPI_ERROR;
        goto exit;
    }
    PdiSpiInstance_l.m_toBeRx = 1; //receive one byte
    iRet = recRxBuffer();
    if ( iRet != PDISPI_OK )
    {
        goto exit;
    }

    //received byte is stored in driver instance
    *pData_p = PdiSpiInstance_l.m_rxBuffer[0];

    PdiSpiInstance_l.m_addrReg++;

    PdiSpiInstance_l.m_pfnEnableGlobalIntH();

exit:
    return iRet;
}

static void byteSwap(BYTE *pVal_p, int iSize_p)
{
    int i;
    BYTE bVal;
    BYTE *pValLow = pVal_p;
    BYTE *pValHigh = pVal_p + iSize_p-1;

    for(i=0; i<iSize_p/2; i++)
    {
        bVal = *pValLow; //tmp store of low byte
        *pValLow = *pValHigh; //store high in low byte
        *pValHigh = bVal; //store tmp stor of low in high byte

        pValLow++; //increment low byte pointer
        pValHigh--; //decrement high byte pointer
    }
}

/**
********************************************************************************
\brief  write one word from the CN PDI via SPI

CnApi_Spi_writeWord() writes one word to the POWERLINK CN PDI via SPI.
This byte will be written to PDI address.

\param  uwAddr_p      PDI address to be written to
\param  wData_p       Write data
\param  ubBigEndian_p Endianess of the word to be read

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
int CnApi_Spi_writeWord(WORD uwAddr_p, WORD wData_p, BYTE ubBigEndian_p)
{
    int iRet = PDISPI_OK;

    if(ubBigEndian_p != FALSE)
    {
        byteSwap((BYTE*)&wData_p, sizeof(WORD));
    }

    iRet = CnApi_Spi_write(uwAddr_p, sizeof(WORD), (BYTE*)&wData_p);

    return iRet;
}

/**
********************************************************************************
\brief  read one word from the CN PDI via SPI

CnApi_Spi_readByte() reads one word from the POWERLINK CN PDI via SPI.
This data will be read from PDI address and stored to a local address.

\param  uwAddr_p      PDI address to be read from
\param  pData_p       Read data
\param  ubBigEndian_p Endianess the data should be read

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
int CnApi_Spi_readWord(WORD uwAddr_p, WORD *pData_p, BYTE ubBigEndian_p)
{
    int iRet = PDISPI_OK;

    iRet = CnApi_Spi_read(uwAddr_p, sizeof(WORD), (BYTE*)pData_p);

    if(ubBigEndian_p != FALSE)
    {
        byteSwap((BYTE*)pData_p, sizeof(WORD));
    }

    return iRet;
}

/**
********************************************************************************
\brief  write one double word from the CN PDI via SPI

CnApi_Spi_writeDword() writes one double word to the POWERLINK CN PDI via SPI.
This byte will be written to PDI address.

\param  uwAddr_p       PDI address to be written to
\param  dwData_p       Write data
\param  ubBigEndian_p  Endianess of the word to be read

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
int CnApi_Spi_writeDword(WORD uwAddr_p, DWORD dwData_p, BYTE ubBigEndian_p)
{
    int iRet = PDISPI_OK;

    if(ubBigEndian_p != FALSE)
    {
        byteSwap((BYTE*)&dwData_p, sizeof(DWORD));
    }

    iRet = CnApi_Spi_write(uwAddr_p, sizeof(DWORD), (BYTE*)&dwData_p);

    return iRet;
}

/**
********************************************************************************
\brief  read one double word from the CN PDI via SPI

CnApi_Spi_readByte() reads one double word from the POWERLINK CN PDI via SPI.
This data will be read from PDI address and stored to a local address.

\param  uwAddr_p      PDI address to be read from
\param  pData_p       Read data
\param  ubBigEndian_p Endianess the data should be read

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
int CnApi_Spi_readDword(WORD uwAddr_p, DWORD *pData_p, BYTE ubBigEndian_p)
{
    int iRet = PDISPI_OK;

    iRet = CnApi_Spi_read(uwAddr_p, sizeof(DWORD), (BYTE*)pData_p);

    if(ubBigEndian_p != FALSE)
    {
        byteSwap((BYTE*)pData_p, sizeof(DWORD));
    }

    return iRet;
}

/**
********************************************************************************
\brief  write one quad word from the CN PDI via SPI

CnApi_Spi_writeDword() writes one quad word to the POWERLINK CN PDI via SPI.
This byte will be written to PDI address.

\param  uwAddr_p       PDI address to be written to
\param  qwData_p       Write data
\param  ubBigEndian_p  Endianess of the word to be read

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
int CnApi_Spi_writeQword(WORD uwAddr_p, QWORD qwData_p, BYTE ubBigEndian_p)
{
    int iRet = PDISPI_OK;

    if(ubBigEndian_p != FALSE)
    {
        byteSwap((BYTE*)&qwData_p, sizeof(QWORD));
    }

    iRet = CnApi_Spi_write(uwAddr_p, sizeof(QWORD), (BYTE*)&qwData_p);

    return iRet;
}

/**
********************************************************************************
\brief  read one quad word from the CN PDI via SPI

CnApi_Spi_readByte() reads one quad word from the POWERLINK CN PDI via SPI.
This data will be read from PDI address and stored to a local address.

\param  uwAddr_p      PDI address to be read from
\param  pData_p       Read data
\param  ubBigEndian_p Endianess the data should be read

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
int CnApi_Spi_readQword(WORD uwAddr_p, QWORD *pData_p, BYTE ubBigEndian_p)
{
    int iRet = PDISPI_OK;

    iRet = CnApi_Spi_read(uwAddr_p, sizeof(QWORD), (BYTE*)pData_p);

    if(ubBigEndian_p != FALSE)
    {
        byteSwap((BYTE*)pData_p, sizeof(QWORD));
    }

    return iRet;
}

/**
********************************************************************************
\brief  write data to the CN PDI via SPI

CnCnApi_Spi_writerites a certain amount of data to the POWERLINK CN PDI
via SPI. This data will be read from a local address and stored to a PDI address.

\param  wPcpAddr_p     PDI Address to be written to
\param  wSize_p        Size of transmitted data in Bytes
\param  pApSrcVar_p   (Byte-) Pointer to local source address

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
int CnApi_Spi_write
(
    WORD   wPcpAddr_p,
    WORD   wSize_p,
    BYTE*  pApSrcVar_p
)
{
    int iRet = PDISPI_OK;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_SPI, "SPI write: %d byte, address: 0x%x\n", wSize_p, wPcpAddr_p);

    /* Depending on data size, choose different SPI processing*/
    if((wSize_p > PDISPI_MAX_SIZE) || wSize_p == 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: SPI PDI data size invalid!");
        iRet = PDISPI_ERROR;
        goto exit;
    }
    else if(wSize_p > PDISPI_THRSHLD_SIZE) /* use automatic address increment */
    {

        iRet = writeSq(wPcpAddr_p, wSize_p, pApSrcVar_p);
        if( iRet != PDISPI_OK )
        {
            iRet = PDISPI_ERROR;
            goto exit;
        }

    }
    else /* transfer single bytes - in this case, better use CnApi_Spi_writeByte directly! */
    {
        for(; 0 < wSize_p; wSize_p--)
         {
          iRet = CnApi_Spi_writeByte(wPcpAddr_p++, (BYTE) *(pApSrcVar_p++));
             if( iRet != PDISPI_OK )
             {
                 iRet = PDISPI_ERROR;
                 goto exit;
             }
         }
    }

    exit:
        return iRet;
}

/**
********************************************************************************
\brief    read data from the CN PDI via SPI

CnApi_Spi_read() reads a certain amount of data from the POWERLINK CN PDI
via SPI. This data will be read from PDI address and stored to a local address.

\param    wPcpAddr_p        PDI address to be read from
\param    wSize_p           Size of transmitted data in Bytes
\param    pApTgtVar_p       (Byte-) Pointer to local target address

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
int CnApi_Spi_read
(
   WORD   wPcpAddr_p,
   WORD   wSize_p,
   BYTE*  pApTgtVar_p
)
{
    int iRet = PDISPI_OK;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_SPI, "SPI read: %d byte, address: 0x%x \n", wSize_p, wPcpAddr_p);

    /* Depending on data size, choose different SPI processing*/
    if((wSize_p > PDISPI_MAX_SIZE) || wSize_p == 0)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: SPI PDI data size invalid!");
        iRet = PDISPI_ERROR;
        goto exit;
    }
    else if(wSize_p > PDISPI_THRSHLD_SIZE) /* use automatic address increment */
    {

        iRet = readSq(wPcpAddr_p, wSize_p, pApTgtVar_p);
        if( iRet != PDISPI_OK )
        {
            iRet = PDISPI_ERROR;
            goto exit;
        }

    }
    else /* transfer single bytes - in this case, better use CnApi_Spi_readByte() directly! */
    {
        for(; 0 < wSize_p; wSize_p--)
         {
             iRet = CnApi_Spi_readByte(wPcpAddr_p++, (BYTE*) (pApTgtVar_p++));
             if( iRet != PDISPI_OK )
             {
                 iRet = PDISPI_ERROR;
                 goto exit;
             }
         }
    }

    exit:
        return iRet;
}

/***************************************************************************************
 * LOCAL FUNCTIONS
 ***************************************************************************************/

/**
********************************************************************************
\brief  write data to the CN PDI via SPI

writeSq() writes several bytes to the POWERLINK CN PDI via SPI.
This data will be written to PDI address.

\param  uwAddr_p    PDI address to be written to
\param  uwSize_p    Write data size
\param  pData_p     Write data

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
static int writeSq
(
    WORD            uwAddr_p,
    WORD            uwSize_p,
    BYTE            *pData_p
)
{
    int             iRet = PDISPI_OK;
    BYTE            ubTxData;
    WORD            uwTxSize = 0;

    ///< as SPI is not interrupt safe disable global interrupts
    PdiSpiInstance_l.m_pfnDisableGlobalIntH();

    //check the pdi's address register for the following cmd
    iRet = setPdiAddrReg(uwAddr_p, ADDR_CHECK_LO);
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }

    do
    {
        if( uwSize_p > PDISPI_MAX_SQ )
        {
            uwTxSize = PDISPI_MAX_SQ;
            uwSize_p -= PDISPI_MAX_SQ;
        }
        else
        {
            uwTxSize = uwSize_p;
            uwSize_p = 0;
        }

        //build WRSQ command with bytes-1 as payload
        buildCmdFrame(uwTxSize-1, &ubTxData, PDISPI_CMD_WRSQ);

        //store CMD to Tx Buffer
        if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
        {   //buffer full
            iRet = PDISPI_ERROR;
            goto exit;
        }
        PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;

        //add tx data to tx buffer
        if( (PdiSpiInstance_l.m_toBeTx-1 + uwTxSize) >= PDISPI_MAX_TX )
        {   //buffer full
            iRet = PDISPI_ERROR;
            goto exit;
        }

        memcpy((BYTE*)&PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx], pData_p, uwTxSize);
        pData_p += uwTxSize; //increment to next buffer position
        PdiSpiInstance_l.m_toBeTx += uwTxSize;

        //send bytes in Tx buffer
        iRet = sendTxBuffer();
        if( iRet != PDISPI_OK )
        {
            goto exit;
        }

        PdiSpiInstance_l.m_addrReg += uwTxSize; //increment local copy too!
    }
    while( uwSize_p );

    ///< enable the interrupts again
    PdiSpiInstance_l.m_pfnEnableGlobalIntH();

exit:
    return iRet;
}

/**
********************************************************************************
\brief  read data from the CN PDI via SPI

readSq() reads several bytes from the POWERLINK CN PDI via SPI.
This data will be read from PDI address and stored to a local address.

\param  uwAddr_p     PDI address to be read from
\param uwSize_p      Read data size (in bytes)
\param  pData_p      Read data

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
static int readSq
(
    WORD            uwAddr_p,
    WORD            uwSize_p,
    BYTE            *pData_p
)
{
    int             iRet = PDISPI_OK;
    BYTE            ubTxData;
    WORD            uwRxSize = 0;

    ///< as SPI is not interrupt safe disable global interrupts
    PdiSpiInstance_l.m_pfnDisableGlobalIntH();

    //check the pdi's address register for the following cmd
    iRet = setPdiAddrReg(uwAddr_p, ADDR_CHECK_LO);
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }

    do
    {
        if( uwSize_p > PDISPI_MAX_SQ )
        {
            uwRxSize = PDISPI_MAX_SQ;
            uwSize_p -= PDISPI_MAX_SQ;
        }
        else
        {
            uwRxSize = uwSize_p;
            uwSize_p = 0;
        }

        //build RDSQ command with bytes-1 as payload
        buildCmdFrame(uwRxSize-1, &ubTxData, PDISPI_CMD_RDSQ);

        //store CMD to Tx Buffer
        if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
        {   //buffer full
            iRet = PDISPI_ERROR;
            goto exit;
        }
        PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;

        //send bytes in Tx buffer
        iRet = sendTxBuffer();
        if( iRet != PDISPI_OK )
        {
            goto exit;
        }

        //receive byte
        if( (PdiSpiInstance_l.m_toBeRx-1 + uwRxSize) >= PDISPI_MAX_RX )
        {   //buffer full
            iRet = PDISPI_ERROR;
            goto exit;
        }
        PdiSpiInstance_l.m_toBeRx += uwRxSize;
        iRet = recRxBuffer();
        if ( iRet != PDISPI_OK )
        {
            goto exit;
        }

        //received bytes are stored in driver instance
        //*pData_p = PdiSpiInstance_l.m_rxBuffer[0];
        memcpy(pData_p, (BYTE*)&PdiSpiInstance_l.m_rxBuffer[0], uwRxSize);
        pData_p += uwRxSize; //increment to next buffer position
        PdiSpiInstance_l.m_addrReg += uwRxSize; //increment local copy too!
    }
    while( uwSize_p );

    PdiSpiInstance_l.m_pfnEnableGlobalIntH();

exit:
    return iRet;
}

/**
********************************************************************************
\brief  set the PDI address register

setPdiAddrReg() sets the PDI SPI address register (local copy and
in the IP-core). If the fWr_p is set to ADDR_CHECK/ADDR_CHECK_LO the local copy
is checked with uwAddr_p first to save SPI writes. Otherwise the uwAddr_p is
written down without verification.

\param  uwAddr_p    address to be accessed at PDI
\param  fWr_p        way of handle address change

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error (e.g. full TX buffer)
*******************************************************************************/
static int setPdiAddrReg
(
    WORD            uwAddr_p,
    int             fWr_p
)
{
    int             iRet = PDISPI_OK;
    BYTE            ubTxData;

    //check high address first
    switch(fWr_p)
    {
        case ADDR_CHECK :
        case ADDR_CHECK_LO :
            //check address with local copy
            if( (uwAddr_p & PDISPI_ADDR_HIGHADDR_MASK) ==
                (PdiSpiInstance_l.m_addrReg & PDISPI_ADDR_HIGHADDR_MASK) )
            {
                //HIGHADDR is equal to local copy(HIGHADDR) => skip
                break;
            }
        case ADDR_WR_DOWN :
        case ADDR_WR_DOWN_LO :
        default :
            buildCmdFrame(uwAddr_p, &ubTxData, PDISPI_CMD_HIGHADDR);

            //store CMD to Tx Buffer
            if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
            {   //buffer full
                iRet = PDISPI_ERROR;
                goto exit;
            }
            PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;

            break;
    }

    //check mid address
    switch(fWr_p)
    {
        case ADDR_CHECK :
        case ADDR_CHECK_LO :
            //check address with local copy
            if( (uwAddr_p & PDISPI_ADDR_MIDADDR_MASK) ==
                (PdiSpiInstance_l.m_addrReg & PDISPI_ADDR_MIDADDR_MASK) )
            {
                //MIDADDR is equal to local copy(MIDADDR) => skip
                break;
            }
        case ADDR_WR_DOWN :
        case ADDR_WR_DOWN_LO :
        default :
            buildCmdFrame(uwAddr_p, &ubTxData, PDISPI_CMD_MIDADDR);

            //store CMD to Tx Buffer
            if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
            {   //buffer full
                iRet = PDISPI_ERROR;
                goto exit;
            }
            PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;
            break;
    }

    //check low address only if fWr_p is set to ???_LO
    switch(fWr_p)
    {
        case ADDR_CHECK_LO :
            //check address with local copy
            if( (uwAddr_p & PDISPI_ADDR_LOWADDR_MASK) ==
                (PdiSpiInstance_l.m_addrReg & PDISPI_ADDR_LOWADDR_MASK) )
            {
                //LOWADDR is equal to local copy(LOWADDR) => skip
                break;
            }
        case ADDR_WR_DOWN_LO :
            buildCmdFrame(uwAddr_p, &ubTxData, PDISPI_CMD_LOWADDR);

            //store CMD to Tx Buffer
            if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
            {   //buffer full
                iRet = PDISPI_ERROR;
                goto exit;
            }
            PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;
            break;
        default :
            break;
    }

    //remember the address register
    PdiSpiInstance_l.m_addrReg = uwAddr_p;

exit:
    return iRet;
}

/**
********************************************************************************
\brief  Transmit m_toBeTx byte(s) and store it/them to m_txBuffer

sendTxBuffer() calls the SPI master TX handler. The to be sent bytes should be
stored in m_txBuffer.

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
static int sendTxBuffer
(
    void
)
{
    int             iRet = PDISPI_OK;

    //check number of toBeTx bytes
    if( PdiSpiInstance_l.m_toBeTx == 0 )
    {
        iRet = PDISPI_ERROR;
        goto exit;
    }

    //call Tx handler
    if( PdiSpiInstance_l.m_pfnSpiMasterTxHandler == 0 )
    {
        iRet = PDISPI_ERROR;
        goto exit;
    }

    iRet = PdiSpiInstance_l.m_pfnSpiMasterTxHandler(
                PdiSpiInstance_l.m_txBuffer,
                PdiSpiInstance_l.m_toBeTx);

    if( iRet != PDISPI_OK )
    {
        goto exit;
    }

    //bytes sent...
    PdiSpiInstance_l.m_toBeTx = 0;

exit:
    return iRet;
}

/**
********************************************************************************
\brief  Receive m_toBeRx byte(s) and store it/them to m_rxBuffer

recRxBuffer() calls the SPI master RX handler. The received bytes are stored
in m_rxBuffer.

\return iRet
\retval PDISPI_OK                  if transfer was successful
\retval PDISPI_ERROR               in case of an error
*******************************************************************************/
static int recRxBuffer
(
    void
)
{
    int             iRet = PDISPI_OK;

    //check number of toBeRx bytes
    if( PdiSpiInstance_l.m_toBeRx == 0 )
    {
        iRet = PDISPI_ERROR;
        goto exit;
    }

    //call Rx handler
    if( PdiSpiInstance_l.m_pfnSpiMasterRxHandler == 0 )
    {
        iRet = PDISPI_ERROR;
        goto exit;
    }

    iRet = PdiSpiInstance_l.m_pfnSpiMasterRxHandler(
                PdiSpiInstance_l.m_rxBuffer,
                PdiSpiInstance_l.m_toBeRx);

    if( iRet != PDISPI_OK )
    {
        goto exit;
    }

    //bytes received...
    PdiSpiInstance_l.m_toBeRx = 0;

exit:
    return iRet;
}

/**
********************************************************************************
\brief  Build command frame

buildCmdFrame() builds the possible command frames in the byte pFrame_p. The
payload of the frame (e.g. address of WR cmd or span of WRSQ cmd) is taken from
uwPayload_p. ubType_p gives the command type (use defines).

\param  uwPayload_p    cmd frame payload
\param  pFrame_p    frame buffer pointer
\param  ubTyp_p     cmd frame type

\return iRet
\retval PDISPI_OK                  can be PDISPI_OK only - if ubTyp_p is
                                   unknown, idle frame is returned!
*******************************************************************************/
static int buildCmdFrame
(
    WORD            uwPayload_p,
    BYTE            *pFrame_p,
    BYTE            ubTyp_p
)
{
    int         iRet = PDISPI_OK;

    switch(ubTyp_p)
    {
        case PDISPI_CMD_HIGHADDR :
            *pFrame_p = (BYTE) ((uwPayload_p & PDISPI_ADDR_HIGHADDR_MASK) \
                                        >> PDISPI_ADDR_HIGHADDR_OFFSET \
                                        | PDISPI_CMD_HIGHADDR);
            break;
        case PDISPI_CMD_MIDADDR :
            *pFrame_p = (BYTE) ((uwPayload_p & PDISPI_ADDR_MIDADDR_MASK) \
                                        >> PDISPI_ADDR_MIDADDR_OFFSET \
                                        | PDISPI_CMD_MIDADDR);
            break;
        case PDISPI_CMD_LOWADDR :
            *pFrame_p = (BYTE) ((uwPayload_p & PDISPI_ADDR_LOWADDR_MASK) \
                                        >> PDISPI_ADDR_LOWADDR_OFFSET \
                                        | PDISPI_CMD_LOWADDR);
            break;
        case PDISPI_CMD_WR :
            *pFrame_p = (BYTE) ((uwPayload_p & PDISPI_ADDR_ADDR_MASK) \
                                        >> 0 \
                                        | PDISPI_CMD_WR);
            break;
        case PDISPI_CMD_RD :
            *pFrame_p = (BYTE) ((uwPayload_p & PDISPI_ADDR_ADDR_MASK) \
                                        >> 0 \
                                        | PDISPI_CMD_RD);
            break;
        case PDISPI_CMD_WRSQ :
            *pFrame_p = (BYTE) ((uwPayload_p & PDISPI_ADDR_ADDR_MASK) \
                                        >> 0 \
                                        | PDISPI_CMD_WRSQ);
            break;
        case PDISPI_CMD_RDSQ :
            *pFrame_p = (BYTE) ((uwPayload_p & PDISPI_ADDR_ADDR_MASK) \
                                        >> 0 \
                                        | PDISPI_CMD_RDSQ);
            break;
        case PDISPI_CMD_IDLE :
        default :
            *pFrame_p = (BYTE) (0 | PDISPI_CMD_IDLE);
            break;
    }

    return iRet;
}

#endif //#CN_API_USING_SPI

/*******************************************************************************
*
* License Agreement
*
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
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


