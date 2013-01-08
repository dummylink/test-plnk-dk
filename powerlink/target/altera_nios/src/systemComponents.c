/*******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       systemComponents.c

\brief      Module which contains of processor specific functions (nios version)

\author     mairt

\date       14.02.2012

\since      14.02.2012

*******************************************************************************/
/* includes */

#include "systemComponents.h"

#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include "nios2.h"
#include <sys/alt_cache.h>

/******************************************************************************/
/* defines */

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

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  This function inits the processor peripheral

It flushes the cache and sets the powerlink status leds to zero
*******************************************************************************/
void SysComp_initPeripheral(void)
{
    alt_icache_flush_all();
    alt_dcache_flush_all();

    SysComp_setPowerlinkStatus(0xff);
}

/**
********************************************************************************
\brief  This function flushes the processor cache

It flushes the cache and sets the powerlink status leds to zero
*******************************************************************************/
void SysComp_flushProcessorCache(void)
{
    alt_icache_flush_all();
    alt_dcache_flush_all();
}

/**
********************************************************************************
\brief  This function enables the processor interrupt controller

This function calles the interrupt enable routine in the target directory
of the stack.
*******************************************************************************/
void SysComp_enableInterrupts(void)
{
    //no interrupt enable needed on nios2 (fallthrough)
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

    /* read port configuration input pins */
#ifdef NODE_SWITCH_BASE
    nodeId = IORD_ALTERA_AVALON_PIO_DATA(NODE_SWITCH_BASE);
#endif

    return nodeId;
}

/**
********************************************************************************
\brief  sets the powerlink status leds to the given peripheral

This function function simply sets the current powerlink status to the given
peripheral.

\param  bBitNum_p       powerlink status (1: state; 2: error)
*******************************************************************************/
void SysComp_setPowerlinkStatus(BYTE bBitNum_p)
{
    #ifdef STATUS_LEDS_BASE
        IOWR_ALTERA_AVALON_PIO_SET_BITS(STATUS_LEDS_BASE, bBitNum_p);
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
    #ifdef STATUS_LEDS_BASE
    IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(STATUS_LEDS_BASE, bBitNum_p);
    #endif
}
