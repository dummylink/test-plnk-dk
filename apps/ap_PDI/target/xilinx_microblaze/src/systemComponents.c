/*******************************************************************************
* Copyright � 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       systemComponents.c

\brief      Module which contains of processor specific functions
            (microblaze version)

\author     mairt

\date       14.02.2012

\since      14.02.2012

*******************************************************************************/
/* includes */
#include "systemComponents.h"

#include "xgpio_l.h"
#include "mb_interface.h"
#include "xintc_l.h"

#ifdef CN_API_USING_SPI
#include "xspi.h"
#endif // CN_API_USING_SPI

//#include "cnApiEvent.h"

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
#ifdef CN_API_USING_SPI
XSpi pSpiMaster;
#endif // CN_API_USING_SPI

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  inits the peripherals of the AP

This function inits the peripherals of the AP like cache and the interrupt
controller.
*******************************************************************************/
void SysComp_initPeripheral(void)
{
    #if XPAR_MICROBLAZE_USE_ICACHE
        microblaze_invalidate_icache();
        microblaze_enable_icache();
    #endif

    #if XPAR_MICROBLAZE_USE_DCACHE
        microblaze_invalidate_dcache();
        microblaze_enable_dcache();
    #endif



#ifdef CN_API_USING_SPI
    XSpi_Initialize(&pSpiMaster, XPAR_SPI_MASTER_DEVICE_ID);
    XSpi_SetOptions(&pSpiMaster, XSP_MASTER_OPTION | XSP_CLK_ACTIVE_LOW_OPTION | XSP_CLK_PHASE_1_OPTION);

    //Start SPI controller
    XSpi_Start(&pSpiMaster);

    //global disable SPI interrupt
    XSpi_IntrGlobalDisable(&pSpiMaster);
    //select slave 0x01
    XSpi_SetSlaveSelect(&pSpiMaster,0x01);

#endif

    //enable interrupts on microblaze
    microblaze_enable_interrupts();
    //enable interrupt master
    XIntc_MasterEnable(XPAR_AP_INTC_BASEADDR);
}

/**
********************************************************************************
\brief enables the microblaze interrupts

This function enables the microblaze interrupts
*******************************************************************************/
inline void SysComp_enableInterrupts()
{
    XIntc_MasterEnable(XPAR_AP_INTC_BASEADDR);     ///<enable interrupt master
}

/**
********************************************************************************
\brief disables the microblaze interrupts

This function disables the microblaze interrupts
*******************************************************************************/
inline void SysComp_disableInterrupts(void)
{
    XIntc_MasterDisable(XPAR_AP_INTC_BASEADDR);     ///<disable interrupt master
}


/**
********************************************************************************
\brief  initialize synchronous interrupt

SysComp_initSyncInterrupt() initializes the synchronous interrupt. The timing parameters
will be initialized, the interrupt handler will be connected and the interrupt
will be enabled.

\param  callback             The callback of the interrupt
\param  dwMinCycleTime_p     The minimum cycle time for the interrupt
\param  dwMaxCycleTime_p     The maximum cycle time for the interrupt
\param  bReserved_p          Reserved for future use

\return	OK, or ERROR if interrupt couldn't be connected
*******************************************************************************/
int SysComp_initSyncInterrupt(void (*callbackFunc)(void*))
{
    DWORD curIntEn = Xil_In32(XPAR_AP_INTC_BASEADDR+XIN_IER_OFFSET);

    //register sync irq handler
    XIntc_RegisterHandler(XPAR_AP_INTC_BASEADDR, SYNC_IRQ_NUM,
            (XInterruptHandler)callbackFunc, 0);

    //enable the sync interrupt
    XIntc_EnableIntr(XPAR_AP_INTC_BASEADDR, SYNC_IRQ_NUM_MASK | curIntEn);

    return OK;
}

/**
********************************************************************************
\brief  Enable synchronous interrupt

SysComp_enableSyncInterrupt() enables the synchronous interrupt.

*******************************************************************************/
inline void SysComp_enableSyncInterrupt(void)
{
    DWORD curIntEn = Xil_In32(XPAR_AP_INTC_BASEADDR+XIN_IER_OFFSET);

    //enable the sync interrupt
    XIntc_EnableIntr(XPAR_AP_INTC_BASEADDR, SYNC_IRQ_NUM_MASK | curIntEn);
}

/**
********************************************************************************
\brief  Disable synchronous interrupt

SysComp_disableSyncInterrupt() disable the synchronous interrupt.

*******************************************************************************/
inline void SysComp_disableSyncInterrupt(void)
{
    DWORD curIntEn = Xil_In32(XPAR_AP_INTC_BASEADDR+XIN_IER_OFFSET);

    //disable the sync interrupt
    XIntc_DisableIntr(XPAR_AP_INTC_BASEADDR, SYNC_IRQ_NUM_MASK | curIntEn);
}

/**
********************************************************************************
\brief  initialize asynchronous interrupt

SysComp_initAsyncInterrupt() initializes the asynchronous interrupt. The interrupt handler
will be connected and the interrupt will be enabled.

\param  callback             The callback of the interrupt

\return OK, or ERROR if interrupt couldn't be connected
*******************************************************************************/
int SysComp_initAsyncInterrupt(void (*callbackFunc)(void*))
{
    DWORD curIntEn = Xil_In32(XPAR_AP_INTC_BASEADDR+XIN_IER_OFFSET);

    //register async irq handler
    XIntc_RegisterHandler(XPAR_AP_INTC_BASEADDR, ASYNC_IRQ_NUM,
            (XInterruptHandler)callbackFunc, 0);

    //enable the async interrupt
    XIntc_EnableIntr(XPAR_AP_INTC_BASEADDR, ASYNC_IRQ_NUM_MASK | curIntEn);

    return OK;
}

/**
********************************************************************************
\brief  Enable synchronous interrupt

SysComp_enableSyncInterrupt() enables the synchronous interrupt.

*******************************************************************************/
inline void SysComp_enableAsyncInterrupt(void)
{
    DWORD curIntEn = Xil_In32(XPAR_AP_INTC_BASEADDR+XIN_IER_OFFSET);

    //enable the async interrupt
    XIntc_EnableIntr(XPAR_AP_INTC_BASEADDR, ASYNC_IRQ_NUM_MASK | curIntEn);
}

/**
********************************************************************************
\brief  Disable synchronous interrupt

SysComp_disableSyncInterrupt() disable the synchronous interrupt.

*******************************************************************************/
inline void SysComp_disableAsyncInterrupt(void)
{
    DWORD curIntEn = Xil_In32(XPAR_AP_INTC_BASEADDR+XIN_IER_OFFSET);

    //disable the sync interrupt
    XIntc_DisableIntr(XPAR_AP_INTC_BASEADDR, ASYNC_IRQ_NUM_MASK | curIntEn);
}

#ifdef CN_API_USING_SPI
/**
********************************************************************************
\brief  Execute SPI command

SysComp_SPICommand() sends an SPI command to the SPI master by using the
alt_avalon_spi_command function

\param  pTxBuf_p             A pointer to the buffer to send
\param  pRxBuf_p             A pointer to the buffer where the data should be stored
\param  iBytes_p             The number of bytes to send or receive

*******************************************************************************/
int SysComp_SPICommand(unsigned char *pTxBuf_p, unsigned char *pRxBuf_p, int iBytes_p)
{

    if(pTxBuf_p != NULL)
    {
        //do send
        if(XSpi_Transfer(&pSpiMaster, pTxBuf_p, NULL, iBytes_p) != XST_SUCCESS)
        {
            return ERROR;
        }
    } else {
        //do receive
        memset(pRxBuf_p,0,iBytes_p);
        if(XSpi_Transfer(&pSpiMaster, pRxBuf_p, pRxBuf_p, iBytes_p) != XST_SUCCESS)
        {
            return ERROR;
        }
    }

    return OK;
}
#endif //CN_API_USING_SPI

/**
********************************************************************************
\brief  write a value to the output port

This function writes a value to the output port of the AP

\param  bValue_p       the value to write
*******************************************************************************/
void SysComp_writeOutputPort(DWORD dwValue_p)
{
    #ifdef OUTPORT_AP_BASE_ADDRESS
        XGpio_WriteReg(OUTPORT_AP_BASE_ADDRESS, XGPIO_DATA_OFFSET, dwValue_p);
    #endif
}

/**
********************************************************************************
\brief  read a value from the input port

This function reads a value from the input port of the AP

\return  bValue_p       the read value
*******************************************************************************/
DWORD SysComp_readInputPort(void)
{
	DWORD dwValue = 0;

    #ifdef INPORT_AP_BASE_ADDRESS
        dwValue = XGpio_ReadReg(INPORT_AP_BASE_ADDRESS, XGPIO_DATA_OFFSET);
    #endif

    return dwValue;
}
