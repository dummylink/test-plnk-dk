/**
********************************************************************************
\file		main.c

\brief		main module of Digital I/O CN application

\author		Josef Baumgartner

\date		12.04.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

\mainpage
This application contains the implementation of the Digital I/O Interface on a NIOSII
processor (AP) which uses the CN API to connect to a second NIOSII processor which
is running the openPOWERLINK stack (PCP).

The application demonstrates the usage of the CN API to implement an POWERLINK
CN. The application uses the CN API to transfer data to/from the PCP through
a dual ported RAM (DPRAM) area.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "cnApiGlobal.h"     // global definitions
#include "cnApi.h"

#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include <sys/alt_cache.h>
#include <sys/alt_irq.h>

#include <unistd.h>
#include <string.h>
#include <stdio.h>

/******************************************************************************/
/* defines */


#define MAC_ADDR	0x00, 0x12, 0x34, 0x56, 0x78, 0x9A			///< the MAC address to use for the CN
#define IP_ADDR     0xc0a86401  								///< 192.168.100.1 // don't care the last byte!
#define SUBNET_MASK 0xFFFFFF00  								///< netmask 255.255.255.0

/*----------------------------------------------------------------------------*/
/* some options */

/* reading of node id pins could be disabled if no node switch is connected.
 * DEFAULT_NODEID will be used instead of contents of node switch.
 */
#undef	INCLUDE_NODE_ID_READ

/*
 * reading of port configuration pins could be disabled if nothing is connected.
 * DEFAULT_PORTCONF will be used instead of contents of port configuration pins.
 */
#undef	INCLUDE_PORTCONF_READ
#define DEFAULT_NODEID      0x01 								///< default node ID to use, should be NOT 0xF0 (=MN) in case of CN
#define	DEFAULT_PORTCONF	0x0B								///< default port pin configuration to use


#define	NUM_INPUT_OBJS		4									///< number of used input objects
#define	NUM_OUTPUT_OBJS		4									///< number of used output objects
#define	NUM_OBJECTS			(NUM_INPUT_OBJS + NUM_OUTPUT_OBJS)	///< number of objects to be linked to the object dictionary

/******************************************************************************/
/* global variables */
BYTE			portIsOutput[4];								///< Variable to store the port configuration
WORD			nodeId;											///< The node ID to be used by the application
BYTE 			abMacAddr_g[] = { MAC_ADDR };					///< The MAC address to be used
BYTE			digitalIn[NUM_INPUT_OBJS];						///< The values of the digital input pins of the board will be stored here
BYTE			digitalOut[NUM_OUTPUT_OBJS];					///< The values of the digital output pins of the board will be stored here

/******************************************************************************/
/* forward declarations */
void initPortConfiguration (char *p_portIsOutput);
WORD getNodeId (void);
void setPowerlinkInitValues(tCnApiInitParm *pInitParm_p, BYTE bNodeId_p, BYTE *pMac_p);
void workInputOutput(void);
int initInterrupt(int irq, WORD wMinCycleTime_p, WORD wMaxCycleTime_p, BYTE bMaxCycleNum);

/**
********************************************************************************
\brief	main function of CN API Example

main() implements the main program function of the CN API example.
First all initialization is done, then the program runs in a loop where the
APs state machine will be updated and input/output ports will be processed.
*******************************************************************************/
int main (void)
{
    tCnApiStatus		status;
    tCnApiInitParm		initParm;

    alt_icache_flush_all();
    alt_dcache_flush_all();

    /* initializing */
    initPortConfiguration(portIsOutput);
    nodeId = getNodeId();

    printf("Initialize CN API functions...\n");
    setPowerlinkInitValues(&initParm, nodeId, (BYTE *)abMacAddr_g);				// initialize POWERLINK parameters

    if ((status = CnApi_init((BYTE *)DPRAM_BASE, &initParm)) < 0)		// initialize and start the CN API
    {
    	printf ("CN API library could not be initialized (%d)\n", status);
		return -1;
    }

    /* initialize and link objects to object dictionary */

    /* initialize CN API object module */
    if (CnApi_initObjects(NUM_OBJECTS) < 0)
    {
    	printf ("CN API library initObjects failed\n");
    	return -1;
    }

    /* connect local variables to object IDs
     * datatype of variables must match with datatype of POWERLINK object dictionary!!!
     * Number of linked objects must match NUM_OBJECTS!!!
     */
    CnApi_linkObject(0x6000, 1, 1, &digitalIn[0]);
    CnApi_linkObject(0x6000, 2, 1, &digitalIn[1]);
    CnApi_linkObject(0x6000, 3, 1, &digitalIn[2]);
    CnApi_linkObject(0x6000, 4, 1, &digitalIn[3]);
    CnApi_linkObject(0x6200, 1, 1, &digitalOut[0]);
    CnApi_linkObject(0x6200, 2, 1, &digitalOut[1]);
    CnApi_linkObject(0x6200, 3, 1, &digitalOut[2]);
    CnApi_linkObject(0x6200, 4, 1, &digitalOut[3]);

    /* initialize PCP interrupt handler, minCycle = 2000 us, maxCycle = 4000 us, maxCycleNum = 10 */
    initInterrupt(SYNC_IRQ_IRQ, 2000, 4000, 10);

    /* Start periodic main loop */
    printf("API example is running...\n");
	CnApi_activateApStateMachine();

	/* main program loop */
	/* TODO: implement exit of application! */
    while (1)
    {
    	/* The AP state machine must be periodically updated, let's do it ... */
    	CnApi_processApStateMachine();

    	/* read inputs and outpus */
    	workInputOutput();

    	/* wait until next period */
    	usleep(1000);		/* wait 1 ms */
    }

    printf("shut down application...\n");
    CnApi_disableSyncInt();
    CnApi_cleanupObjects();
    CnApi_exit();

    return 0;
}

/**
********************************************************************************
\brief	initialize POWERLINK parameters

setPowerlinkInitValues() sets up the initialization values for the
openPOWERLINK stack.

\param	pInitParm_p			pointer to initialization parameter structure
\param	bNodeId_p			node ID to use for CN
\param	pMac_p				pointer to MAC address
*******************************************************************************/
void setPowerlinkInitValues(tCnApiInitParm *pInitParm_p, BYTE bNodeId_p, BYTE *pMac_p)
{
	pInitParm_p->m_bNodeId = bNodeId_p;
	memcpy(pInitParm_p->m_abMac, pMac_p, sizeof(pInitParm_p->m_abMac));
	pInitParm_p->m_dwDeviceType = -1;
	pInitParm_p->m_dwVendorId = -1;
	pInitParm_p->m_dwProductCode = -1;
	pInitParm_p->m_dwRevision = -1;
	pInitParm_p->m_dwSerialNum = -1;
	pInitParm_p->m_dwFeatureFlags = -1;
	pInitParm_p->m_wIsoTxMaxPayload = 256;
	pInitParm_p->m_wIsoRxMaxPayload = 256;
	pInitParm_p->m_dwPresMaxLatency = 2000;
	pInitParm_p->m_dwAsendMaxLatency= 2000;

	pInitParm_p->m_dwDpramBase = DPRAM_BASE;		//address of DPRAM area
}

/**
********************************************************************************
\brief	init port configuration

initPortConfiguration() reads the port configuration inputs. The port
configuration inputs are connected to general purpose I/O pins IO3V3[16..12].
The read port configuration if stored at the port configuration outputs to
set up the input/output selection logic.

\param	pPortIsOutput_p		pointer to array where output flags are stored
*******************************************************************************/
void initPortConfiguration (char *pPortIsOutput_p)
{
	register int			i;
	volatile unsigned char	portconf;
	unsigned int			direction = 0;

#ifdef	INCLUDE_PORTCONF_READ
	/* read port configuration input pins */
	portconf = IORD_ALTERA_AVALON_PIO_DATA(PORTCONF_PIO_BASE);
#else
	portconf = DEFAULT_PORTCONF;
#endif

	for (i = 0; i <= 3; i++)
	{
		if (portconf & (1 << i))
		{
			direction |= 0xff << (i * 8);
			pPortIsOutput_p[i] = TRUE;
		}
		else
		{
			direction &= ~(0xff << (i * 8));
			pPortIsOutput_p[i] = FALSE;
		}
	}

	/* setup input / output selection logic by setting up portconf output pins */
	IOWR_ALTERA_AVALON_PIO_DATA(PORTCONF_PIO_BASE, portconf);
	/* set PIO direction for I/Os */
	IOWR_ALTERA_AVALON_PIO_DIRECTION(DIGIO_PIO_BASE, direction);
}

/**
********************************************************************************
\brief	read inputs and write outputs

workInputOutput() reads the input ports and writes the output ports. It must
be periodically called in the main loop.
*******************************************************************************/
void workInputOutput(void)
{
    register int	i;
    unsigned int	ports;

    ports = IORD_ALTERA_AVALON_PIO_DATA(DIGIO_PIO_BASE);

    for (i = 0; i <= 3; i++)
    {
        if (portIsOutput[i])
        {
        	ports = (ports & ~(0xFF << (i * 8))) | (digitalOut[i] << (i * 8));
        }
        else
        {
        	digitalIn[i] = (ports >> (i * 8)) & 0xff;
        }
    }
    IOWR_ALTERA_AVALON_PIO_DATA(DIGIO_PIO_BASE, ports);
}

/**
********************************************************************************
\brief	get node ID

getNodeId() reads the node switches connected to the node switch inputs and
returns the node ID.

\retval	nodeID		the node ID which was read
*******************************************************************************/
WORD getNodeId (void)
{
	WORD 	nodeId;

#ifdef	INCLUDE_NODE_ID_READ
	/* read port configuration input pins */
	nodeId = IORD_ALTERA_AVALON_PIO_DATA(NODE_SWITCH_PIO_BASE);
#else
	nodeId = DEFAULT_NODEID;
#endif

	return nodeId;
}

/**
********************************************************************************
\brief	synchronous interrupt handler

syncIntHandler() implements the synchronous data interrupt. The PCP asserts
the interrupt when periodic data is ready to transfer.

See the Altera NIOSII Reference manual for further details of interrupt
handlers.
*******************************************************************************/
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void syncIntHandler (void* pArg_p)
#else
static void syncIntHandler (void* pArg_p, alt_u32 dwInt_p)
#endif
{
	/* acknowledge interrupt by writing to the edge capture register*/
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(SYNC_IRQ_BASE, 0);

	CnApi_transferPdo();		// Call CN API PDO transfer function
}

/**
********************************************************************************
\brief	initialize synchronous interrupt

initInterrupt() initializes the synchronous interrupt. The timing parameters
will be initialized, the interrupt handler will be connected and the interrupt
will be enabled.

\param	irq					Interrupt number of synchronous interrupt (from BSP)
\param	wMinCycleTime_p		The minimum cycle time for the interrupt
\param	wMaxCycleTime_p		The maximum cycle time for the interrupt
\param	bMaxCycleNum_p		The maximum number of POWERLINK cycles allowed between two interrupts

\return	OK, or ERROR if interrupt couldn't be connected
*******************************************************************************/
int initInterrupt(int irq, WORD wMinCycleTime_p, WORD wMaxCycleTime_p, BYTE bMaxCycleNum_p)
{
	CnApi_initSyncInt(wMinCycleTime_p, wMaxCycleTime_p, bMaxCycleNum_p);

	/* register interrupt handler */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
	if (alt_ic_isr_register(0, irq, syncIntHandler, NULL, 0))
	{
		return ERROR;
	}
 #else
    if (alt_irq_register(irq, NULL, CnApi_syncIntHandler))
    {
        return ERROR;
    }
#endif

	/* enable interrupts */
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(SYNC_IRQ_BASE, 1);

    /* enable interrupt from PCP */
    CnApi_enableSyncInt();

	return OK;
}
