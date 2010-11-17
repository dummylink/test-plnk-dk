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
#include "cnApiDebug.h"

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

#ifndef CN_API_USING_SPI
    #define PDI_DPRAM_BASE_AP POWERLINK_0_BASE                      ///< from system.h
#else
    #define PDI_DPRAM_BASE_AP 0x00                                  ///< no base address necessary
#endif


#define NUM_INPUT_OBJS      4                                   ///< number of used input objects
#define NUM_OUTPUT_OBJS     12                                   ///< number of used output objects
#define NUM_OBJECTS         (NUM_INPUT_OBJS + NUM_OUTPUT_OBJS)  ///< number of objects to be linked to the object dictionary

#define MAC_ADDR	0x00, 0x12, 0x34, 0x56, 0x78, 0x9A			///< the MAC address to use for the CN
#define IP_ADDR     0xc0a86401  								///< 192.168.100.1 // don't care the last byte!
#define SUBNET_MASK 0xFFFFFF00  								///< netmask 255.255.255.0

/*----------------------------------------------------------------------------*/
/* some options */
#define DEFAULT_NODEID      0x01 ///< default node ID to use, should be NOT 0xF0 (=MN) if this is a CN
/* If you don't intend to connect node Id switches to the PCP, this value might set != 0x00 */

// #define USE_POLLING_MODE ///< or IR synchronization mode by commenting this define

/******************************************************************************/
/* global variables */
WORD			nodeId;											///< The node ID, which can overwrite the node switches if != 0x00
BYTE 			abMacAddr_g[] = { MAC_ADDR };					///< The MAC address to be used
BYTE			digitalIn[NUM_INPUT_OBJS];						///< The values of the digital input pins of the board will be stored here
BYTE			digitalOut[NUM_OUTPUT_OBJS];					///< The values of the digital output pins of the board will be stored here

/******************************************************************************/
/* forward declarations */
void setPowerlinkInitValues(tCnApiInitParm *pInitParm_p, BYTE bNodeId_p, BYTE *pMac_p);
void workInputOutput(void);
int initInterrupt(int irq, WORD wMinCycleTime_p, WORD wMaxCycleTime_p, BYTE bMaxCycleNum);

#ifdef CN_API_USING_SPI
int CnApi_CbSpiMasterTx(unsigned char *pTxBuf_p, int iBytes_p);
int CnApi_CbSpiMasterRx(unsigned char *pRxBuf_p, int iBytes_p);
#endif

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

    IOWR_ALTERA_AVALON_PIO_DATA(OUTPORT_AP_BASE, 0xabffff); ///< set hex digits on Mercury-Board to indicate AP presence
    usleep(1000000);		                                ///< wait 1 s, so you can see the LEDs

    TRACE("Initialize CN API functions...\n");

    nodeId = DEFAULT_NODEID;    ///< in case you dont want to use Node Id switches, use a diffenrent value then 0x00
    setPowerlinkInitValues(&initParm, nodeId, (BYTE *)abMacAddr_g);				///< initialize POWERLINK parameters

    status = CnApi_init((BYTE *)PDI_DPRAM_BASE_AP, &initParm);                  ///< initialize and start the CN API
    if (status < 0)
    {
        TRACE1("CN API library could not be initialized (%d)\n", status);
		return -1;
    }

    /* initialize and link objects to object dictionary */

    /* initialize CN API object module */
    if (CnApi_initObjects(NUM_OBJECTS) < 0)
    {
        TRACE("CN API library initObjects failed\n");
    	return -1;
    }

    /* connect local variables to object IDs
     * - Linked Objects have do be indicated in the XDD file !
     * - datatype of variables must match with datatype of POWERLINK object dictionary !
     * - Number of linked objects must match NUM_OBJECTS !
     */
	///< CnApi_linkObject(Index, SubIndex, size in bytes, ptr) 
    CnApi_linkObject(0x6000, 1, 1, &digitalIn[0]);
    CnApi_linkObject(0x6000, 2, 1, &digitalIn[1]);
    CnApi_linkObject(0x6000, 3, 1, &digitalIn[2]);
    CnApi_linkObject(0x6000, 4, 1, &digitalIn[3]);
    CnApi_linkObject(0x6200, 1, 1, &digitalOut[0]);
    CnApi_linkObject(0x6200, 2, 1, &digitalOut[1]);
    CnApi_linkObject(0x6200, 3, 1, &digitalOut[2]);
    CnApi_linkObject(0x6200, 4, 1, &digitalOut[3]);
    CnApi_linkObject(0x6300, 1, 1, &digitalOut[4]);
    CnApi_linkObject(0x6300, 2, 1, &digitalOut[5]);
    CnApi_linkObject(0x6300, 3, 1, &digitalOut[6]);
    CnApi_linkObject(0x6300, 4, 1, &digitalOut[7]);
    CnApi_linkObject(0x6400, 1, 1, &digitalOut[8]);
    CnApi_linkObject(0x6400, 2, 1, &digitalOut[9]);
    CnApi_linkObject(0x6400, 3, 1, &digitalOut[10]);
    CnApi_linkObject(0x6400, 4, 1, &digitalOut[11]);


#ifdef USE_POLLING_MODE
    CnApi_disableSyncInt();
#else
    /* initialize PCP interrupt handler, minCycle = 2000 us, maxCycle = 65535 us (max. val. for DWORD), maxCycleNum = 10 */
    initInterrupt(POWERLINK_0_IRQ, 1000, 65535, 10);
#endif /* USE_POLLING_MODE */

    /* Start periodic main loop */
    TRACE("API example is running...\n");
	CnApi_activateApStateMachine();

	/* main program loop */
	/* TODO: implement exit of application! */
    while (1)
    {
        /* Instead of this while loop, you can use your own (nonblocking) tasks ! */

        /*--- TASK 1: START ---*/
    	CnApi_processApStateMachine();     ///< The AP state machine must be periodically updated
    	//TODO: Implement Cbfunc "OperationalSyncCb"in statemachine?
            workInputOutput();             ///< update the PCB's inputs and outputs
    	/*--- TASK 1: END   ---*/

    	/* wait until next period */
    	usleep(100);		               ///< wait 100 us to simulate a task behavior

#ifdef USE_POLLING_MODE
        /*--- TASK 2: START ---*/
    	if (CnApi_getPcpState() >= kApStateReadyToOperate) //TODO: Alternatively implement Cbfunc in statemachine
    	{
    	    CnApi_transferPdo();           ///< update linked variables
    	}
        /*--- TASK 2: END   ---*/
#endif /* USE_POLLING_MODE */

    }

    TRACE("shut down application...\n");
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

	pInitParm_p->m_dwDpramBase = PDI_DPRAM_BASE_AP;		//address of DPRAM area
}


/**
********************************************************************************
\brief	read inputs and write outputs

workInputOutput() reads the input ports and writes the output ports. It must
be periodically called in the main loop.
*******************************************************************************/
void workInputOutput(void)
{
	register BYTE iCnt;
	DWORD dwOutPort = 0;
	BYTE cInPort;
	
	///> Digital IN: read push- and joystick buttons
	cInPort = IORD_ALTERA_AVALON_PIO_DATA(INPORT_AP_BASE);
	digitalIn[0] = cInPort;    // 6000/01
	digitalIn[1] = cInPort;    // 6000/02
	digitalIn[2] = cInPort;    // 6000/03
	digitalIn[3] = cInPort;    // 6000/04

	///> Digital OUT: set Leds and hex digits on Mercury-Board
    for (iCnt = 0; iCnt <= 2; iCnt++)
    {
        if (iCnt == 0) //first 8 bit of DigOut
        {
        	/* configured as output -> overwrite invalid input values with RPDO mapped variables */
            dwOutPort = (dwOutPort & ~(0xff << (iCnt * 8))) | (digitalOut[7] << (iCnt * 8)); //6300/04
        }
        else if (iCnt == 1) //second 8 bit of DigOut
        {
            dwOutPort = (dwOutPort & ~(0xff << (iCnt * 8))) | (digitalOut[11] << (iCnt * 8)); //6400/04
        }
        else if (iCnt == 2)  //third 8 bit of DigOut
        {
        	/* configured as input -> store in TPDO mapped variable */
            dwOutPort = (dwOutPort & ~(0xff << (iCnt * 8))) | (digitalOut[3] << (iCnt * 8)); //Hex digits at 6200/04
        }
    }

    IOWR_ALTERA_AVALON_PIO_DATA(OUTPORT_AP_BASE, dwOutPort);
}

/**
********************************************************************************
\brief	synchronous interrupt handler

syncIntHandler() implements the synchronous data interrupt. The PCP asserts
the interrupt when periodic data is ready to transfer.

See the Altera NIOSII Reference manual for further details of interrupt
handlers.
*******************************************************************************/
#ifndef USE_POLLING_MODE
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void syncIntHandler(void* pArg_p)
#else
static void syncIntHandler(void* pArg_p, void* dwInt_p)
#endif
{
	/* acknowledge interrupt by writing to the SYNC_IRQ_CONTROL_REGISTER*/
	pCtrlReg_g->m_bSyncIrqControl = (1 << SYNC_IRQ_ACK);

#ifdef CN_API_USING_SPI
    CnApi_Spi_writeByte(PCP_CTRLREG_SYNCIRQCTRL_OFFSET, pCtrlReg_g->m_bSyncIrqControl); ///< update pcp register
#endif

	CnApi_transferPdo();		// Call CN API PDO transfer function
}
#endif /* USE_POLLING_MODE */
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
#ifndef USE_POLLING_MODE
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
    if (alt_irq_register(irq, NULL, syncIntHandler))
    {
        return ERROR;
    }
#endif

    /* enable interrupt of PCP */
    CnApi_enableSyncInt();
	return OK;
}
#endif /* USE_POLLING_MODE */

#ifdef CN_API_USING_SPI
int CnApi_CbSpiMasterTx(unsigned char *pTxBuf_p, int iBytes_p)
{
    alt_avalon_spi_command(
        SPI_0_BASE, 0,      //core base, spi slave
        iBytes_p, pTxBuf_p, //write bytes, addr of write data
        0, NULL,            //read bytes, addr of read data
        0);                 //flags (don't care)

    return PDISPI_OK;
}

int CnApi_CbSpiMasterRx(unsigned char *pRxBuf_p, int iBytes_p)
{
    alt_avalon_spi_command(
        SPI_0_BASE, 0,      //core base, spi slave
        0, NULL,            //write bytes, addr of write data
        iBytes_p, pRxBuf_p, //read bytes, addr of read data
        0);                 //flags (don't care)

    return PDISPI_OK;
}
#endif /* CN_API_USING_SPI */

/* END-OF-FILE */
/******************************************************************************/
