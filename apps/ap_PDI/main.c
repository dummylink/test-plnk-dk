/**
********************************************************************************
\file      main.c

\brief     main module of Digital I/O CN application

\author    baumgj

\date      12.04.2010

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
#include "cnApiAsync.h"
#include "cnApiEvent.h"

#include "system.h"
#include "altera_avalon_pio_regs.h"
#ifdef CN_API_USING_SPI
#include "altera_avalon_spi.h"
#include "cnApiPdiSpi.h"
#endif
#include "alt_types.h"
#include <sys/alt_cache.h>
#include <sys/alt_irq.h>
#include <io.h>

#include <unistd.h>
#include <string.h>
#include <stdio.h>

/******************************************************************************/
/* defines */

/*----------------------------------------------------------------------------*/
/* USER OPTIONS */

/* If node Id switches are connected to the PCP, this value must be 0x00! */
#define DEFAULT_NODEID      0x01    ///< default node ID to use, should be NOT 0xF0 (=MN)

//#define USE_POLLING_MODE ///< or IR synchronization mode by commenting this define

/*----------------------------------------------------------------------------*/

#ifndef CN_API_USING_SPI
    #define PDI_DPRAM_BASE_AP POWERLINK_0_PDI_AP_BASE           ///< from system.h
#else
    #define PDI_DPRAM_BASE_AP 0x00                              ///< no base address necessary
#endif /* CN_API_USING_SPI */


#define NUM_INPUT_OBJS      4                                   ///< number of used input objects
#define NUM_OUTPUT_OBJS     4                                   ///< number of used output objects
#define NUM_OBJECTS         (NUM_INPUT_OBJS + NUM_OUTPUT_OBJS)  ///< number of objects to be linked to the object dictionary

#define MAC_ADDR    0x00, 0x12, 0x34, 0x56, 0x78, 0x9A          ///< the MAC address to use for the CN
#define IP_ADDR     0xc0a86401                                  ///< 192.168.100.1 // don't care the last byte!
#define SUBNET_MASK 0xFFFFFF00                                  ///< netmask 255.255.255.0

/******************************************************************************/
/* global variables */
static WORD     nodeId;                                         ///< The node ID, which can overwrite the node switches if != 0x00
static BYTE     abMacAddr_l[] = { MAC_ADDR };                   ///< The MAC address to be used
static BYTE     digitalIn[NUM_INPUT_OBJS];                      ///< The values of the digital input pins of the board will be stored here
static BYTE     digitalOut[NUM_OUTPUT_OBJS];                    ///< The values of the digital output pins of the board will be stored here
static BOOL     fOperational_l = FALSE;                         ///< indicates AP Operation state

/******************************************************************************/
/* forward declarations */
void setPowerlinkInitValues(tCnApiInitParm *pInitParm_p, BYTE bNodeId_p, BYTE *pMac_p);
void workInputOutput(void);
int initInterrupt(int irq, DWORD dwMinCycleTime_p, DWORD dwMaxCycleTime_p, BYTE bMaxCycleNum);

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
    tCnApiStatus        status;
    tCnApiInitParm      initParm;

    alt_icache_flush_all();
    alt_dcache_flush_all();

    IOWR_ALTERA_AVALON_PIO_DATA(OUTPORT_AP_BASE, 0xabffff); // set hex digits on Mercury-Board to indicate AP presence
    usleep(1000000);		                                // wait 1 s, so you can see the LEDs

    TRACE("\n\nInitialize CN API functions...");

    nodeId = DEFAULT_NODEID;    // in case you dont want to use Node Id switches, use a different value then 0x00
    setPowerlinkInitValues(&initParm, nodeId, (BYTE *)abMacAddr_l);             // initialize POWERLINK parameters

    status = CnApi_init((BYTE *)PDI_DPRAM_BASE_AP, &initParm);                  // initialize and start the CN API
    if (status > 0)
    {
        TRACE1("\nERROR: CN API library could not be initialized (%d)\n", status);
        return -1;
    }
    else
    {
        TRACE("\nInitialize CN API functions...successful!\n");
    }

    /* initialize and link objects to object dictionary */

    /* initialize CN API object module */
    if (CnApi_initObjects(NUM_OBJECTS) < 0)
    {
        TRACE("ERROR: CN API library initObjects failed\n");
        return -1;
    }

    /* connect local variables to object IDs
     * - Linked Objects have do be indicated in the XDD file !
     * - datatype of variables must match with datatype of POWERLINK object dictionary !
     * - Number of linked objects must match NUM_OBJECTS !
     */
    /* CnApi_linkObject(Index, SubIndex, size in bytes, ptr) */
    CnApi_linkObject(0x6000, 1, 1, &digitalIn[0]);  // TPDO 0
    CnApi_linkObject(0x6000, 2, 1, &digitalIn[1]);
    CnApi_linkObject(0x6000, 3, 1, &digitalIn[2]);
    CnApi_linkObject(0x6000, 4, 1, &digitalIn[3]);
    CnApi_linkObject(0x6200, 1, 1, &digitalOut[0]); // RPDO 0
    CnApi_linkObject(0x6200, 2, 1, &digitalOut[1]);
    CnApi_linkObject(0x6200, 3, 1, &digitalOut[2]);
    CnApi_linkObject(0x6200, 4, 1, &digitalOut[3]);

#ifdef USE_POLLING_MODE
    CnApi_disableSyncInt();
    CnApi_disableAsyncEventIRQ();
#else
    /* initialize PCP interrupt handler, minCycle = 1000 us, maxCycle = 100000 us , maxCycleNum = 10 */
    #ifdef CN_API_USING_SPI
    initInterrupt(SYNC_IRQ_FROM_PCP_IRQ, 1000, 100000, 10);  ///< local AP IRQ is enabled here
    #else
    initInterrupt(POWERLINK_0_PDI_AP_IRQ, 1000, 100000, 10);
    #endif /* CN_API_USING_SPI */
#endif /* USE_POLLING_MODE */

    /* Start periodic main loop */
    TRACE("API example is running...\n");
	CnApi_activateApStateMachine();
	CnApi_activateAsyncStateMachine();

	/* main program loop */
	/* TODO: implement exit of application! */
    while (1)
    {
        /* Instead of this while loop, you can use your own (nonblocking) tasks ! */

        /*--- TASK 1: START ---*/
        CnApi_processApStateMachine();     // The AP state machine must be periodically updated
        //TODO: Implement Cbfunc "OperationalSyncCb"in statemachine?
        workInputOutput();                 // update the PCB's inputs and outputs
        /*--- TASK 1: END   ---*/

        CnApi_processAsyncStateMachine();


#ifdef USE_POLLING_MODE
        /*--- TASK 2: START ---*/
        if (fOperational_l == TRUE)
        {
            CnApi_transferPdo();           // update linked variables
        }
        /*--- TASK 2: END   ---*/

        CnApi_pollAsyncEvent();            // check if PCP event occurred
#endif /* USE_POLLING_MODE */

        //TODO: Do this in AsycIRQHandler
        CnApi_pollAsyncEvent();            // check if PCP event occurred
    }

    TRACE("shut down application...\n");
    CnApi_disableSyncInt();
    CnApi_disableAsyncEventIRQ();
    CnApi_cleanupObjects();
    CnApi_exit();

    return 0;
}

/**
********************************************************************************
\brief	initialize POWERLINK parameters

setPowerlinkInitValues() sets up the initialization values for the
openPOWERLINK stack.

\param	pInitParm_p         pointer to initialization parameter structure
\param	bNodeId_p           node ID to use for CN
\param	pMac_p              pointer to MAC address
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

    pInitParm_p->m_dwDpramBase = PDI_DPRAM_BASE_AP;     //address of DPRAM area
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
            dwOutPort = (dwOutPort & ~(0xff << (iCnt * 8))) | (digitalOut[0] << (iCnt * 8)); // [7] 6300/04 or [0]6200/01
        }
        else if (iCnt == 1) //second 8 bit of DigOut
        {
            dwOutPort = (dwOutPort & ~(0xff << (iCnt * 8))) | (digitalOut[1] << (iCnt * 8)); // [11]6400/04 or [1]6200/02
        }
        else if (iCnt == 2)  //third 8 bit of DigOut
        {
        	/* configured as input -> store in TPDO mapped variable */
            dwOutPort = (dwOutPort & ~(0xff << (iCnt * 8))) | (digitalOut[3] << (iCnt * 8)); //Hex digits at [3]6200/04
        }
    }

    IOWR_ALTERA_AVALON_PIO_DATA(OUTPORT_AP_BASE, dwOutPort);
}

void CnApi_AppCbEvent(tCnApiEventType EventType_p, tCnApiEventArg EventArg_p, void * pUserArg_p)
{

    switch (EventType_p)
    {
            case kCnApiEventUserDef:
            case kCnApiEventApStateChange:
            {
                DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO,"New AP State: %d\n", EventArg_p.NewApState_m);

                fOperational_l = FALSE;

#ifndef USE_POLLING_MODE
                CnApi_disableSyncInt();    // disable synchronous IR signal of PCP
                // Note: this is not really necessary, because this IR will only be triggered
                // in PCP's OPERATIONAL state, but it disables the IRQs in any case.
#endif /* USE_POLLING_MODE */

                switch (EventArg_p.NewApState_m)
                {

                    case kApStateBooted:
                    case kApStateReadyToInit:
                    case kApStateInit:
                    case kApStatePreop1:
                    case kApStatePreop2:
                        break;

                    case kApStateReadyToOperate:
                    {
                        /* Do some preparation before READY_TO_OPERATE state is entered */

                        // Note: The application should not take longer for this preparation than
                        // the timeout value of the Powerlink MN "MNTimeoutPreOp2_U32".
                        // Otherwise the CN will not boot!
                        break;
                    }

                    case kApStateOperational:
                    {
                        fOperational_l = TRUE;

#ifndef USE_POLLING_MODE
                        CnApi_enableSyncInt();    // enable synchronous IR signal of PCP
#endif
                        break;
                    }
                    case kApStateError:
                    break;
                    default:
                    break;
                }


                break;
            }
            case kCnApiEventPcp:
            {
                switch (EventArg_p.PcpEventGen_m)
                {
                    case kPcpGenEventSyncCycleCalcSuccessful:
                    {
                        TRACE1("\nINFO: Synchronization IR Period is %lu us.\n", CnApi_getSyncIntPeriod());
                        break;
                    }
                    default:
                    break;
                }

                break;
            }
            case kCnApiEventError:
            {
                switch (EventArg_p.CnApiError_m.ErrTyp_m)
                {
                    case kCnApiEventErrorFromPcp:
                    {
                        switch (EventArg_p.CnApiError_m.ErrArg_m.PcpError_m.Typ_m)
                        {
                            case kPcpPdiEventGenericError:
                            {
                                switch (EventArg_p.CnApiError_m.ErrArg_m.PcpError_m.Arg_m.GenErr_m)
                                {
                                    case kPcpGenErrInitFailed:
                                    case kPcpGenErrSyncCycleCalcError:
                                    {
                                        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR: PCP Init failed!");
                                        break;
                                    }
                                    case kPcpGenErrAsyncComTimeout:
                                    case kPcpGenErrAsyncIntChanComError:
                                    {
                                        DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO,"Asynchronous communication error at PCP!");
                                        break;
                                    }
                                    case kPcpGenErrPhy0LinkLoss:
                                    case kPcpGenErrPhy1LinkLoss:
                                    {
                                        DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO,"Phy link lost!\n");
                                        // This might not be an issue as long as you have two phys.
                                        // Only the connection to MN might be critical.
                                        // If this link is lost -> PCP state change to PreOP1
                                        // Link loss at initialization of PCP is furthermore normal!

                                        break;
                                    }

                                    case kPcpGenErrEventBuffOverflow:
                                    {
                                        // AP is too slow (or PCP buffer is too small)!
                                        // -> AP will lose latest events from PCP
                                    }
                                    default:
                                    break;
                                }

                                break;
                            }

                            case kPcpPdiEventCriticalStackError:
                            case kPcpPdiEventStackWarning:
                            {
                                // PCP will stop processing or restart
                                break;
                            }

                            case kPcpPdiEventHistoryEntry:
                            {
                                // PCP will change state, stop processing or restart
                                DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO,"Error history entry code: %#04x\n",
                                EventArg_p.CnApiError_m.ErrArg_m.PcpError_m.Arg_m.wErrorHistoryCode_m);
                                break;
                            }

                            default:
                            break;
                        }

                        break;
                    }

                    case kCnApiEventErrorLcl:
                    default:
                    break;
                }

                break;
            }
            case kCnApiEventSdo:
            case kCnApiEventObdAccess:
            default:
            break;
    }
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
#ifdef CN_API_USING_SPI
    //TODO: ifdef not Avalon IF
    alt_ic_irq_disable(0, SYNC_IRQ_FROM_PCP_IRQ);  // disable specific IRQ Number
#endif

	CnApi_transferPdo();		                   // Call CN API PDO transfer function

	CnApi_ackSyncIrq();

#ifdef CN_API_USING_SPI
    CnApi_Spi_writeByte(PCP_CTRLREG_SYNCIRQCTRL_OFFSET, pCtrlReg_g->m_wSyncIrqControl); // update pcp register
#endif

#ifdef CN_API_USING_SPI
    // Temporary Workaround:
    workInputOutput();
    //TODO: this workaround is unnecessary, but otherwise it will not work! IR blocks while() loop somehow.

    alt_ic_irq_enable(0, SYNC_IRQ_FROM_PCP_IRQ);  // enable specific IRQ Number
#endif /* CN_API_USING_SPI */
}
#endif /* USE_POLLING_MODE */
/**
********************************************************************************
\brief	initialize synchronous interrupt

initInterrupt() initializes the synchronous interrupt. The timing parameters
will be initialized, the interrupt handler will be connected and the interrupt
will be enabled.

\param	irq					Interrupt number of synchronous interrupt (from BSP)
\param	dwMinCycleTime_p		The minimum cycle time for the interrupt
\param	dwMaxCycleTime_p		The maximum cycle time for the interrupt
\param	bMaxCycleNum_p		The maximum number of POWERLINK cycles allowed between two interrupts

\return	OK, or ERROR if interrupt couldn't be connected
*******************************************************************************/
#ifndef USE_POLLING_MODE
int initInterrupt(int irq, DWORD dwMinCycleTime_p, DWORD dwMaxCycleTime_p, BYTE bMaxCycleNum_p)
{
	CnApi_initSyncInt(dwMinCycleTime_p, dwMaxCycleTime_p, bMaxCycleNum_p);
	CnApi_disableSyncInt();

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

    /* enable interrupt from PCP to AP */
    //TODO: ifdef not Avalon IF
#ifdef CN_API_USING_SPI
    alt_ic_irq_enable(0, irq);      // enable specific IRQ Number
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(SYNC_IRQ_FROM_PCP_BASE, 0x01);
    //TODO: endif not Avalon IF
#endif /* CN_API_USING_SPI */

    //CnApi_enableSyncInt();          // cause the PCP to set periodic IR's //TODO: enable in Operational
    CnApi_enableAsyncEventIRQ();    //enable asynchronous event IR's

	return OK;
}
#endif /* USE_POLLING_MODE */

#ifdef CN_API_USING_SPI
int CnApi_CbSpiMasterTx(unsigned char *pTxBuf_p, int iBytes_p)
{
    alt_avalon_spi_command(
        SPI_MASTER_BASE, 0, //core base, spi slave
        iBytes_p, pTxBuf_p, //write bytes, addr of write data
        0, NULL,            //read bytes, addr of read data
        0);                 //flags (don't care)
    return OK;
}

int CnApi_CbSpiMasterRx(unsigned char *pRxBuf_p, int iBytes_p)
{
    alt_avalon_spi_command(
        SPI_MASTER_BASE, 0, //core base, spi slave
        0, NULL,            //write bytes, addr of write data
        iBytes_p, pRxBuf_p, //read bytes, addr of read data
        0);                 //flags (don't care)
    return OK;
}
#endif /* CN_API_USING_SPI */

/* END-OF-FILE */
/******************************************************************************/
