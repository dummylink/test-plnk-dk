/**
********************************************************************************
\file		DigitalIoMain.c

\brief		main module of digital I/O user interface

\author		Josef Baumgartner

\date		06.04.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "Epl.h"

#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include <sys/alt_cache.h>

#include "omethlib.h"

/******************************************************************************/
/* defines */
//#define SET_NODE_ID_PER_SW 			//NodeID will be overwritten with SW define

#ifndef SET_NODE_ID_PER_SW
#ifndef NODE_SWITCH_PIO_BASE
    #error No Node ID module present in SOPC. Node ID can only be set by SW!
#endif
#endif

#define NODEID      0x05 // should be NOT 0xF0 (=MN) in case of CN
#define CYCLE_LEN   1000 // [us]
#define MAC_ADDR	0x00, 0x12, 0x34, 0x56, 0x78, 0x9A
#define IP_ADDR     0xc0a86401  // 192.168.100.1 // don't care the last byte!
#define SUBNET_MASK 0xFFFFFF00  // 255.255.255.0

#define LATCHED_IOPORT_BASE (void*) POWERLINK_0_SMP_BASE
#define LATCHED_IOPORT_CFG	(void*) (LATCHED_IOPORT_BASE + 4)


// This function is the entry point for your object dictionary. It is defined
// in OBJDICT.C by define EPL_OBD_INIT_RAM_NAME. Use this function name to define
// this function prototype here. If you want to use more than one Epl
// instances then the function name of each object dictionary has to differ.

tEplKernel PUBLIC  EplObdInitRam (tEplObdInitParam MEM* pInitParam_p);
tEplKernel PUBLIC AppCbSync(void);
tEplKernel PUBLIC AppCbEvent(
    tEplApiEventType        EventType_p,   // IN: event type (enum)
    tEplApiEventArg*        pEventArg_p,   // IN: event argument (union)
    void GENERIC*           pUserArg_p);

BYTE		portIsOutput[4];
BYTE		digitalIn[4];
BYTE		digitalOut[4];

static BOOL     fShutdown_l = FALSE;

/******************************************************************************/
/* forward declarations */
int openPowerlink(void);
void InitPortConfiguration (char *p_portIsOutput);
WORD GetNodeId (void);

/**
********************************************************************************
\brief	main function of digital I/O interface

*******************************************************************************/
int main (void)
{
    int iCnt=0;

    alt_icache_flush_all();
    alt_dcache_flush_all();

    PRINTF("Digital I/O interface is running...\n");
    PRINTF("starting openPowerlink...\n\n");

    while (1) {
        if (openPowerlink() != 0) {
        	PRINTF("openPowerlink was shut down because of an error\n");
            break;
        } else {
        	PRINTF("openPowerlink was shut down, restart...\n\n");
        }
        /* wait some time until we restart the stack */
        for (iCnt=0; iCnt<1000000; iCnt++);
    }

    PRINTF1("shut down NIOS II...\n%c", 4);

    return 0;
}

/**
********************************************************************************
\brief	main function of digital I/O interface

*******************************************************************************/
int openPowerlink(void) {
	DWORD		 				ip = IP_ADDR; // ip address

	const BYTE 				abMacAddr[] = {MAC_ADDR};
	static tEplApiInitParam EplApiInitParam; //epl init parameter
	// needed for process var
	tEplObdSize         	ObdSize;
	tEplKernel 				EplRet;
	unsigned int			uiVarEntries;

    fShutdown_l = FALSE;

    /* initialize port configuration */
    InitPortConfiguration(portIsOutput);

    /* setup the POWERLINK stack */
	
	// calc the IP address with the nodeid
	ip &= 0xFFFFFF00; //dump the last byte
	ip |= GetNodeId(); // and mask it with the node id

	// set EPL init parameters
	EplApiInitParam.m_uiSizeOfStruct = sizeof (EplApiInitParam);
	EPL_MEMCPY(EplApiInitParam.m_abMacAddress, abMacAddr, sizeof(EplApiInitParam.m_abMacAddress));
	EplApiInitParam.m_uiNodeId = GetNodeId();
	EplApiInitParam.m_dwIpAddress = ip;
	EplApiInitParam.m_uiIsochrTxMaxPayload = 256;
	EplApiInitParam.m_uiIsochrRxMaxPayload = 256;
	EplApiInitParam.m_dwPresMaxLatency = 2000;
	EplApiInitParam.m_dwAsndMaxLatency = 2000;
	EplApiInitParam.m_fAsyncOnly = FALSE;
	EplApiInitParam.m_dwFeatureFlags = -1;
	EplApiInitParam.m_dwCycleLen = CYCLE_LEN;
	EplApiInitParam.m_uiPreqActPayloadLimit = 36;
	EplApiInitParam.m_uiPresActPayloadLimit = 36;
	EplApiInitParam.m_uiMultiplCycleCnt = 0;
	EplApiInitParam.m_uiAsyncMtu = 1500;
	EplApiInitParam.m_uiPrescaler = 2;
	EplApiInitParam.m_dwLossOfFrameTolerance = 5000000;
	EplApiInitParam.m_dwAsyncSlotTimeout = 3000000;
	EplApiInitParam.m_dwWaitSocPreq = 0;
	EplApiInitParam.m_dwDeviceType = -1;
	EplApiInitParam.m_dwVendorId = -1;
	EplApiInitParam.m_dwProductCode = -1;
	EplApiInitParam.m_dwRevisionNumber = -1;
	EplApiInitParam.m_dwSerialNumber = -1;
	EplApiInitParam.m_dwSubnetMask = SUBNET_MASK;
	EplApiInitParam.m_dwDefaultGateway = 0;
	EplApiInitParam.m_pfnCbEvent = AppCbEvent;
    EplApiInitParam.m_pfnCbSync  = AppCbSync;
    EplApiInitParam.m_pfnObdInitRam = EplObdInitRam;
	
	
	PRINTF1("\nNode ID is set to: %d\n", EplApiInitParam.m_uiNodeId);
	
    /************************/
	/* initialize POWERLINK stack */
    PRINTF("init POWERLINK stack:\n");
	EplRet = EplApiInitialize(&EplApiInitParam);
	if(EplRet != kEplSuccessful) {
		PRINTF1("init POWERLINK Stack... error %X\n\n", EplRet);
		goto Exit;
    }
	PRINTF("init POWERLINK Stack...ok\n\n");

    /**********************************************************/
	/* link process variables used by CN to object dictionary */
	PRINTF("linking process vars:\n");

    ObdSize = sizeof(digitalIn[0]);
    uiVarEntries = 4;
    EplRet = EplApiLinkObject(0x6000, digitalIn, &uiVarEntries, &ObdSize, 0x01);
    if (EplRet != kEplSuccessful)
    {
        printf("linking process vars... error\n\n");
        goto ExitShutdown;
    }

    ObdSize = sizeof(digitalOut[0]);
    uiVarEntries = 4;
    EplRet = EplApiLinkObject(0x6200, digitalOut, &uiVarEntries, &ObdSize, 0x01);
    if (EplRet != kEplSuccessful)
    {
        printf("linking process vars... error\n\n");
        goto ExitShutdown;
    }

    PRINTF("linking process vars... ok\n\n");

	// start the POWERLINK stack
    PRINTF("start EPL Stack...\n");
	EplRet = EplApiExecNmtCommand(kEplNmtEventSwReset);
    if (EplRet != kEplSuccessful) {
    	PRINTF("start EPL Stack... error\n\n");
        goto ExitShutdown;
    }

    /*Start POWERLINK Stack*/
    PRINTF("start POWERLINK Stack... ok\n\n");

    PRINTF("Digital I/O interface with openPowerlink is ready!\n\n");

#ifdef STATUS_LED_PIO_BASE
    IOWR_ALTERA_AVALON_PIO_DATA(STATUS_LED_PIO_BASE, 0xFF);
#endif

    while(1)
    {
        EplApiProcess();
        if (fShutdown_l == TRUE)
            break;
    }

ExitShutdown:
	PRINTF("Shutdown EPL Stack\n");
    EplApiShutdown(); //shutdown node

Exit:
	return EplRet;
}

/**
********************************************************************************
\brief	event callback function called by EPL API layer

AppCbEvent() is the event callback function called by EPL API layer within
the user part (low priority).


\param	EventType_p     		event type (IN)
\param	pEventArg_p     		pointer to union, which describes the event in
                                detail (IN)
\param	pUserArg_p      		user specific argument

\return error code (tEplKernel)
\retval	kEplSuccessful		no error
\retval	kEplReject 			reject further processing
\retval	otherwise 			post error event to API layer
*******************************************************************************/
tEplKernel PUBLIC AppCbEvent(tEplApiEventType EventType_p,
		                     tEplApiEventArg* pEventArg_p, void GENERIC* pUserArg_p)
{
	tEplKernel          EplRet = kEplSuccessful;

    // check if NMT_GS_OFF is reached
    switch (EventType_p)
    {
        case kEplApiEventNmtStateChange:
        {
            switch (pEventArg_p->m_NmtStateChange.m_NewNmtState)
            {
                case kEplNmtGsOff:
                {   // NMT state machine was shut down,
                    // because of critical EPL stack error
                    // -> also shut down EplApiProcess() and main()
                    EplRet = kEplShutdown;
                    fShutdown_l = TRUE;

                    PRINTF2("%s(kEplNmtGsOff) originating event = 0x%X\n", __func__, pEventArg_p->m_NmtStateChange.m_NmtEvent);
                    break;
                }

                case kEplNmtGsInitialising:
                case kEplNmtGsResetApplication:
                case kEplNmtGsResetConfiguration:
                case kEplNmtCsPreOperational1:
                case kEplNmtCsBasicEthernet:
                case kEplNmtMsBasicEthernet:
                {
                    PRINTF3("%s(0x%X) originating event = 0x%X\n",
                            __func__,
                            pEventArg_p->m_NmtStateChange.m_NewNmtState,
                            pEventArg_p->m_NmtStateChange.m_NmtEvent);
                    break;
                }

                case kEplNmtGsResetCommunication:
                {
                BYTE    bNodeId = 0xF0;
                DWORD   dwNodeAssignment = EPL_NODEASSIGN_NODE_EXISTS;
                WORD    wPresPayloadLimit = 256;

                    PRINTF3("%s(0x%X) originating event = 0x%X\n",
                            __func__,
                            pEventArg_p->m_NmtStateChange.m_NewNmtState,
                            pEventArg_p->m_NmtStateChange.m_NmtEvent);

                    EplRet = EplApiWriteLocalObject(0x1F81, bNodeId, &dwNodeAssignment, sizeof (dwNodeAssignment));
                    if (EplRet != kEplSuccessful)
                    {
                        goto Exit;
                    }

                    bNodeId = 0x04;
                    EplRet = EplApiWriteLocalObject(0x1F81, bNodeId, &dwNodeAssignment, sizeof (dwNodeAssignment));
                    if (EplRet != kEplSuccessful)
                    {
                        goto Exit;
                    }

                    EplRet = EplApiWriteLocalObject(0x1F8D, bNodeId, &wPresPayloadLimit, sizeof (wPresPayloadLimit));
                    if (EplRet != kEplSuccessful)
                    {
                        goto Exit;
                    }

                    break;
                }

                case kEplNmtMsNotActive:
                    break;
                case kEplNmtCsNotActive:
                    break;
                    break;

                case kEplNmtCsOperational:
                    break;
                case kEplNmtMsOperational:
                    break;

                default:
                {
                    break;
                }
            }

            break;
        }

        case kEplApiEventCriticalError:
        case kEplApiEventWarning:
        {   // error or warning occured within the stack or the application
            // on error the API layer stops the NMT state machine
            PRINTF3("%s(Err/Warn): Source=%02X EplError=0x%03X",
                    __func__,
                    pEventArg_p->m_InternalError.m_EventSource,
                    pEventArg_p->m_InternalError.m_EplError);
            // check additional argument
            switch (pEventArg_p->m_InternalError.m_EventSource)
            {
                case kEplEventSourceEventk:
                case kEplEventSourceEventu:
                {   // error occured within event processing
                    // either in kernel or in user part
                    PRINTF1(" OrgSource=%02X\n", pEventArg_p->m_InternalError.m_Arg.m_EventSource);
                    break;
                }

                case kEplEventSourceDllk:
                {   // error occured within the data link layer (e.g. interrupt processing)
                    // the DWORD argument contains the DLL state and the NMT event
                    PRINTF1(" val=%lX\n", pEventArg_p->m_InternalError.m_Arg.m_dwArg);
                    break;
                }

                default:
                {
                    PRINTF0("\n");
                    break;
                }
            }
            break;
        }

        case kEplApiEventLed:
        {   // status or error LED shall be changed

            switch (pEventArg_p->m_Led.m_LedType)
            {
#ifdef STATUS_LED_PIO_BASE
                case kEplLedTypeStatus:
                {
                    if (pEventArg_p->m_Led.m_fOn != FALSE)
                    {
                    	IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(STATUS_LED_PIO_BASE, 1);
                    }
                    else
                    {
                    	IOWR_ALTERA_AVALON_PIO_SET_BITS(STATUS_LED_PIO_BASE, 1);
                    }
                    break;

                }
#endif

#ifdef STATUS_LED_PIO_BASE
                case kEplLedTypeError:
                {
                    if (pEventArg_p->m_Led.m_fOn != FALSE)
                    {
                    	IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(STATUS_LED_PIO_BASE, 2);
                    }
                    else
                    {
                    	IOWR_ALTERA_AVALON_PIO_SET_BITS(STATUS_LED_PIO_BASE, 2);
                    }
                    break;
                }
#endif
                default:
                    break;
            }
            break;
        }

        default:
            break;
    }

Exit:
    return EplRet;
}

/**
********************************************************************************
\brief	sync event callback function called by event module

AppCbSync() implements the event callback function called by event module
within kernel part (high priority). This function sets the outputs, reads the
inputs and runs the control loop.

\return	error code (tEplKernel)

\retval	kEplSuccessful			no error
\retval	otherwise				post error event to API layer
*******************************************************************************/
tEplKernel PUBLIC AppCbSync(void)
{
	tEplKernel 		EplRet = kEplSuccessful;
    register int	iCnt;
    DWORD			ports; //<<< 4 byte input or output ports
    DWORD*			ulDigInputs = LATCHED_IOPORT_BASE;
    DWORD*			ulDigOutputs = LATCHED_IOPORT_BASE;

    /* read digital input ports */
    ports = *ulDigInputs; 
	
    for (iCnt = 0; iCnt <= 3; iCnt++)
    {
	
        if (portIsOutput[iCnt])
        {
        	/* configured as output -> overwrite invalid input values with RPDO mapped variables */
        	ports = (ports & ~(0xff << (iCnt * 8))) | (digitalOut[iCnt] << (iCnt * 8));
        }
        else
        {
        	/* configured as input -> store in TPDO mapped variable */
        	digitalIn[iCnt] = (ports >> (iCnt * 8)) & 0xff;
        }
    }

    /* write digital output ports */
    *ulDigOutputs = ports;

    return EplRet;
}

/**
********************************************************************************
\brief	init port configuration

InitPortConfiguration() reads the port configuration inputs. The port
configuration inputs are connected to general purpose I/O pins IO3V3[16..12].
The read port configuration if stored at the port configuration outputs to
set up the input/output selection logic.

\param	portIsOutput		pointer to array where output flags are stored
*******************************************************************************/
void InitPortConfiguration (char *p_portIsOutput)
{
	register int	iCnt;
	volatile BYTE	portconf;
	unsigned int	direction = 0;

	/* read port configuration input pins */
	memcpy((BYTE *) &portconf, LATCHED_IOPORT_CFG, 1);
	portconf = ~portconf;

	PRINTF1("\nPort configuration register value (only last digit matters) = %X \n", portconf);

	for (iCnt = 0; iCnt <= 3; iCnt++)
	{
		if (portconf & (1 << iCnt))
		{
			direction |= 0xff << (iCnt * 8);
			p_portIsOutput[iCnt] = TRUE;
		}
		else
		{
			direction &= ~(0xff << (iCnt * 8));
			p_portIsOutput[iCnt] = FALSE;
		}
	}
}

/**
********************************************************************************
\brief	get node ID

GetNodeId() reads the node switches connected to the node switch inputs and
returns the node ID.

\retval	nodeID		the node ID which was read
*******************************************************************************/
WORD GetNodeId (void)
{
	WORD 	nodeId;

	/* read port configuration input pins */
	nodeId = IORD_ALTERA_AVALON_PIO_DATA(NODE_SWITCH_PIO_BASE);
	#ifdef SET_NODE_ID_PER_SW
		nodeId = NODEID;  ///< Fixed for debugging as long as no node switches are connected!
	#endif

	return nodeId;
}
