/*******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
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
#include "xilinx_irq.h"

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

DWORD bEplStatusLeds = 0;

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  This function inits the processor peripheral

It flushes the cache and sets the powerlink status leds to zero
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

    #ifdef XPAR_LEDS_OUTPUT_BASEADDR
        XGpio_WriteReg(XPAR_LEDS_OUTPUT_BASEADDR, XGPIO_TRI_OFFSET, 0);
    #endif

    #ifdef XPAR_POWERLINK_LED_BASEADDR
        XGpio_WriteReg(XPAR_POWERLINK_LED_BASEADDR, XGPIO_TRI_OFFSET, 0);
    #endif

    initInterrupts();
}

/**
********************************************************************************
\brief  This function enables the processor interrupt controller

This function calles the interrupt enable routine in the target directory
of the stack.
*******************************************************************************/
void SysComp_enableInterrupts(void)
{
    enableInterrupts();
}

/**
********************************************************************************
\brief  This function frees the processor peripheral

It flushes the cache and sets the powerlink status leds to zero
*******************************************************************************/
void SysComp_freeProcessorCache(void)
{
    #if XPAR_MICROBLAZE_USE_DCACHE
        microblaze_invalidate_dcache();
        microblaze_disable_dcache();
    #endif

    #if XPAR_MICROBLAZE_USE_ICACHE
        microblaze_invalidate_icache();
        microblaze_disable_icache();
    #endif
}


/**
********************************************************************************
\brief  Reads the node ID from the available peripheral

This function reads the node id from the given board peripheral. If the board
is not supporting node switches zero is returned.

\return  nodeId       the given node id
*******************************************************************************/
BYTE SysComp_getNodeId(void)
{
    BYTE nodeId = 0;

    /* read dip switches for node id */
#ifdef NODE_SWITCH_BASE
    nodeId = XGpio_ReadReg(NODE_SWITCH_BASE, 0);
#endif

    return nodeId;
}

/**
********************************************************************************
\brief  sets the powerlink status leds to the given peripheral

This function simply sets the current powerlink status to the given
peripheral.

\param  bBitNum_p       powerlink status (1: state; 2: error)
*******************************************************************************/
void SysComp_setPowerlinkStatus(BYTE bBitNum_p)
{
    bEplStatusLeds |= bBitNum_p;

    #ifdef STATUS_LEDS_BASE
        XGpio_WriteReg(STATUS_LEDS_BASE, XGPIO_DATA_OFFSET, bEplStatusLeds);
    #endif
}

/**
********************************************************************************
\brief  resets the powerlink status leds to the given peripheral

This function function simply resets the current powerlink status to the given
peripheral.

\param  bBitNum_p       powerlink status (1: state; 2: error)
*******************************************************************************/
void SysComp_resetPowerlinkStatus(BYTE bBitNum_p)
{
    bEplStatusLeds &= ~bBitNum_p;

    #ifdef STATUS_LEDS_BASE
        XGpio_WriteReg(STATUS_LEDS_BASE, XGPIO_DATA_OFFSET, bEplStatusLeds);
    #endif
}
