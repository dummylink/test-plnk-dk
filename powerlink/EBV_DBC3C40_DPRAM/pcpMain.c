/**
********************************************************************************
\file		GenericIfMain.c

\brief		main module of digital I/O user interface

\author		Josef Baumgartner

\date		06.04.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "Epl.h"
#include "Debug.h"

#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include <sys/alt_cache.h>

#include <unistd.h>

#include "pcp.h"
#include "cnApi.h"
#include "cnApiIntern.h"
#include "pcpStateMachine.h"

/******************************************************************************/
/* defines */
#define PDI_DPRAM_BASE_PCP				POWERLINK_0_PDI_PCP_BASE  //from system.h
#define SYNC_IRQ_CONTROL_REGISTER 		(alt_u8*) (PDI_DPRAM_BASE_PCP + SYNC_IRQ_CONROL_REG_OFFSET) 	//from cnApi.h
#define SYNC_IRQ_TIMER_VALUE_REGISTER 	(alt_u8*) (PDI_DPRAM_BASE_PCP + SYNC_IRQ_TIMER_VALUE_REG_OFFSET)//from cnApiIntern.h

#define NODEID      0x01 // should be NOT 0xF0 (=MN) in case of CN
#define CYCLE_LEN   1000 // [us]
#define MAC_ADDR	0x00, 0x12, 0x34, 0x56, 0x78, 0x9A
#define IP_ADDR     0xc0a86401  // 192.168.100.1 // don't care the last byte!
#define SUBNET_MASK 0xFFFFFF00  // 255.255.255.0


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

BYTE		digitalIn[4];
BYTE		digitalOut[4];

tPcpCtrlReg		*pCtrlReg_g;
tCnApiInitParm 	initParm_g;
int				iSyncIntCycle_g;


BYTE		baAsyncSend_g[512];
BYTE		baAsyncRecv_g[512];

static BOOL     fShutdown_l = FALSE;

/******************************************************************************/
/* forward declarations */
int openPowerlink(void);
static void setLed(BYTE bType_p, BOOL fOn_p);

/**
********************************************************************************
\brief	get string of NMT state
*******************************************************************************/
char * getNmtState (tEplNmtState state)
{
	switch (state)
	{
	case kEplNmtGsOff: return "NmtGsOff";
	case kEplNmtGsInitialising: return "NmtGsInitialising";
	case kEplNmtGsResetApplication: return "NmtGsResetApplication";
	case kEplNmtGsResetCommunication: return "NmtGsResetCommunication";
	case kEplNmtGsResetConfiguration: return "NmtGsResetConfiguration";
	case kEplNmtCsNotActive: return "NmtCsNotActive";
	case kEplNmtCsPreOperational1: return "NmtCsPreOperational1";
	case kEplNmtCsStopped: return "NmtCsStopped";
	case kEplNmtCsPreOperational2: return "NmtCsPreOperational2";
	case kEplNmtCsReadyToOperate: return "NmtCsReadyToOperate";
	case kEplNmtCsOperational: return "NmtCsOperational";
	case kEplNmtCsBasicEthernet: return "NmtCsBasicEthernet";
	case kEplNmtMsNotActive: return "NmtMsNotActive";
	case kEplNmtMsPreOperational1: return "NmtMsPreOperational1";
	case kEplNmtMsPreOperational2: return "NmtMsPreOperational2";
	case kEplNmtMsReadyToOperate: return "NmtMsReadyToOperate";
	case kEplNmtMsOperational: return "NmtMsOperational";
	case kEplNmtMsBasicEthernet: return "NmtMsBasicEthernet";
	default: return "--";
	}
}

/**
********************************************************************************
\brief	main function of generic POWERLINK CN interface
*******************************************************************************/
int main (void)
{

	/* flush all caches */
    alt_icache_flush_all();
    alt_dcache_flush_all();

    DEBUG_TRACE0(DEBUG_LVL_09, "\n\nGeneric POWERLINK CN interface - this is PCP starting in main()\n\n");

    /***** initializations *****/
    DEBUG_TRACE0(DEBUG_LVL_09, "Initializing...\n");

    initStateMachine();
    Gi_init();
    Gi_initAsync((tAsyncMsg *)(PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wTxAsyncBufAdrs),
    		     (tAsyncMsg *)(PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wRxAsyncBufAdrs));
    Gi_initPdo((BYTE *)(PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_awTxPdoBufAdrs[0]),
		       (BYTE *)(PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_awRxPdoBufAdrs[0]),
		       (BYTE *)(&pCtrlReg_g->m_awTxPdoAckAdrsAp[0]),
		       (BYTE *)(&pCtrlReg_g->m_awRxPdoAckAdrsAp[0]),
		       (tPdoDescHeader *)(PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_awTxPdoDescAdrs[0]),
		       (tPdoDescHeader *)(PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_awRxPdoDescAdrs[0]));

    Gi_initSyncInt();

    DEBUG_TRACE0(DEBUG_LVL_09, "OK\n");

#ifdef STATUS_LED_PIO_BASE
    IOWR_ALTERA_AVALON_PIO_DATA(STATUS_LED_PIO_BASE, 0xFF);
#endif

    /***** Starting main state machine *****/
    resetStateMachine();
    while (stateMachineIsRunning())
    {
    	EplApiProcess();
    	updateStateMachine();
    	usleep(100);		/* wait 100 us */ //TODO: delete this line
    }

    DEBUG_TRACE0(DEBUG_LVL_09, "shut down POWERLINK CN interface ...\n");

    return 0;
}

/**
********************************************************************************
\brief	initialize openPOWERLINK stack
*******************************************************************************/
int initPowerlink(tCnApiInitParm *pInitParm_p)
{
	DWORD		 			ip = IP_ADDR; // ip address
	static tEplApiInitParam EplApiInitParam; //epl init parameter
	tEplKernel 				EplRet;

	DEBUG_FUNC;

    /* setup the POWERLINK stack */
	/* calc the IP address with the nodeid */
	ip &= 0xFFFFFF00; //dump the last byte
	ip |= pInitParm_p->m_bNodeId; // and mask it with the node id

	/* set EPL init parameters */
	EplApiInitParam.m_uiSizeOfStruct = sizeof (EplApiInitParam);
	EPL_MEMCPY(EplApiInitParam.m_abMacAddress, pInitParm_p->m_abMac, sizeof(EplApiInitParam.m_abMacAddress));
	EplApiInitParam.m_uiNodeId = pInitParm_p->m_bNodeId;
	EplApiInitParam.m_dwIpAddress = ip;
	EplApiInitParam.m_uiIsochrTxMaxPayload = pInitParm_p->m_wIsoTxMaxPayload;
	EplApiInitParam.m_uiIsochrRxMaxPayload = pInitParm_p->m_wIsoRxMaxPayload;
	EplApiInitParam.m_dwPresMaxLatency = pInitParm_p->m_dwPresMaxLatency;
	EplApiInitParam.m_dwAsndMaxLatency = pInitParm_p->m_dwAsendMaxLatency;
	EplApiInitParam.m_fAsyncOnly = FALSE;
	EplApiInitParam.m_dwFeatureFlags = pInitParm_p->m_dwFeatureFlags;
	EplApiInitParam.m_dwCycleLen = CYCLE_LEN;
	EplApiInitParam.m_uiPreqActPayloadLimit = 36;
	EplApiInitParam.m_uiPresActPayloadLimit = 36;
	EplApiInitParam.m_uiMultiplCycleCnt = 0;
	EplApiInitParam.m_uiAsyncMtu = 1500;
	EplApiInitParam.m_uiPrescaler = 2;
	EplApiInitParam.m_dwLossOfFrameTolerance = 500000000;
	EplApiInitParam.m_dwAsyncSlotTimeout = 3000000;
	EplApiInitParam.m_dwWaitSocPreq = 0;
	EplApiInitParam.m_dwDeviceType = pInitParm_p->m_dwDeviceType;
	EplApiInitParam.m_dwVendorId = pInitParm_p->m_dwVendorId;
	EplApiInitParam.m_dwProductCode = pInitParm_p->m_dwProductCode;
	EplApiInitParam.m_dwRevisionNumber = pInitParm_p->m_dwRevision;
	EplApiInitParam.m_dwSerialNumber = pInitParm_p->m_dwSerialNum;
	EplApiInitParam.m_dwSubnetMask = SUBNET_MASK;
	EplApiInitParam.m_dwDefaultGateway = 0;
	EplApiInitParam.m_pfnCbEvent = AppCbEvent;
    EplApiInitParam.m_pfnCbSync  = AppCbSync;
    EplApiInitParam.m_pfnObdInitRam = EplObdInitRam;
	EplApiInitParam.m_dwSyncResLatency = EPL_C_DLL_T_IFG;

	/* initialize POWERLINK stack */
    printf("init POWERLINK stack:\n");
	EplRet = EplApiInitialize(&EplApiInitParam);
	if(EplRet != kEplSuccessful)
	{
        DEBUG_TRACE1(DEBUG_LVL_28, "init POWERLINK Stack... error %X\n\n", EplRet);
    }
	else
	{
		DEBUG_TRACE0(DEBUG_LVL_28, "init POWERLINK Stack...ok\n\n");
	}
    return EplRet;
}

/**
********************************************************************************
\brief	start the POWERLINK stack
*******************************************************************************/
int startPowerlink(void)
{
	tEplKernel 				EplRet;

	// start the POWERLINK stack
    DEBUG_TRACE0(DEBUG_LVL_29, "start EPL Stack...\n");
	EplRet = EplApiExecNmtCommand(kEplNmtEventSwReset);
    if (EplRet != kEplSuccessful)
    {
        DEBUG_TRACE0(DEBUG_LVL_29, "start EPL Stack... error\n\n");
        return ERROR;
    }
    else
    {
    	DEBUG_TRACE0(DEBUG_LVL_29, "start POWERLINK Stack... ok\n\n");
    	return OK;
    }
}

/**
********************************************************************************
\brief	process POWERLINK
*******************************************************************************/
void processPowerlink(void)
{
    while(1)
    {
        EplApiProcess();
        if (fShutdown_l == TRUE)
            break;
    }

    printf("Shutdown EPL Stack\n");
    EplApiShutdown(); //shutdown node
	return;
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
        	DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "%s(%s) originating event = 0x%X\n",
        	                            __func__,
        	                            getNmtState(pEventArg_p->m_NmtStateChange.m_NewNmtState),
        	                            pEventArg_p->m_NmtStateChange.m_NmtEvent);

            switch (pEventArg_p->m_NmtStateChange.m_NewNmtState)
            {
                case kEplNmtGsOff:
                {   // NMT state machine was shut down,
                    // because of critical EPL stack error
                    // -> also shut down EplApiProcess() and main()
                	setPowerlinkEvent(kPowerlinkEventShutdown);
                    EplRet = kEplShutdown;
                    break;
                }

                case kEplNmtCsPreOperational2:
                {
                	/* setup PDO descriptors */
                	Gi_setupPdoDesc(kCnApiDirReceive);
                	Gi_setupPdoDesc(kCnApiDirTransmit);
                	Gi_calcSyncIntPeriod();

                	setPowerlinkEvent(kPowerlinkEventEnterPreop2);
               		EplRet = kEplReject;
                	break;
                }

                case kEplNmtCsReadyToOperate:
                {
                	break;
                }

                case kEplNmtGsInitialising:
                case kEplNmtGsResetConfiguration:
                case kEplNmtGsResetApplication:
                case kEplNmtCsPreOperational1:
                case kEplNmtCsBasicEthernet:
                {
                    setPowerlinkEvent(kPowerlinkEventReset);
                    break;
                }

                case kEplNmtGsResetCommunication:
                {
					BYTE    bNodeId = 0xF0;
					DWORD   dwNodeAssignment = EPL_NODEASSIGN_NODE_EXISTS;
					WORD    wPresPayloadLimit = 256;

					setPowerlinkEvent(kPowerlinkEventReset);

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

                case kEplNmtCsNotActive:
                    break;

                case kEplNmtCsOperational:
                	setPowerlinkEvent(kPowerlinkEventEnterOperational);
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
            DEBUG_TRACE3(DEBUG_LVL_CNAPI_ERR, "%s(Err/Warn): Source=%02X EplError=0x%03X",
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
                    DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, " OrgSource=%02X\n", pEventArg_p->m_InternalError.m_Arg.m_EventSource);
                    break;
                }

                case kEplEventSourceDllk:
                {   // error occured within the data link layer (e.g. interrupt processing)
                    // the DWORD argument contains the DLL state and the NMT event
                	DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, " val=%lX\n", pEventArg_p->m_InternalError.m_Arg.m_dwArg);
                    break;
                }

                default:
                {
                	DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "\n");
                    break;
                }
            }
            break;
        }

        case kEplApiEventLed:
        {   // status or error LED shall be changed

        	switch (pEventArg_p->m_Led.m_LedType)
            {
                case kEplLedTypeStatus:
                	setLed(kEplLedTypeStatus, pEventArg_p->m_Led.m_fOn);
                    break;
                case kEplLedTypeError:
                	setLed(kEplLedTypeError, pEventArg_p->m_Led.m_fOn);
                    break;
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
	static	unsigned int 	iCycleCnt = 0;

    /* read PDO data from DPRAM */
    Gi_readPdo();

    /* write PDO data to DPRAM */
    Gi_writePdo();

    /* check if interrupts are enabled */
    if ((pCtrlReg_g->m_bIntCtrl & CNAPI_INT_CTRL_EN) && (iSyncIntCycle_g != 0))
    {
		if ((iCycleCnt++ % iSyncIntCycle_g) == 0)
		{
			Gi_generateSyncInt();// TODO: To avoid jitter, synchronize on openMAC Sync interrupt instead of IR throwing by SW
		}
    }
    return EplRet;
}


/**
********************************************************************************
\brief	get command from AP

getCommandFromAp() gets the command from the application processor(AP).

\return		command from AP
*******************************************************************************/
BYTE getCommandFromAp(void)
{
	return pCtrlReg_g->m_bCommand;
}

/**
********************************************************************************
\brief	store the state the PCP is in
*******************************************************************************/
void storePcpState(BYTE bState_p)
{
	pCtrlReg_g->m_bState = bState_p;
}

/**
********************************************************************************
\brief	get the state of the PCP state machine
*******************************************************************************/
BYTE getPcpState(void)
{
	return pCtrlReg_g->m_bState;
}


/**
********************************************************************************
\brief	basic initializations
*******************************************************************************/

void Gi_init(void)
{
	/* Setup PCP Control Register in DPRAM */

    pCtrlReg_g = (tPcpCtrlReg *)PDI_DPRAM_BASE_PCP;		///< set address of control register - equals DPRAM base address
    // memset(pCtrlReg_g + 4, 0xff, 12); 						///< initialize remaining writable registers //TODO: delete this line

    pCtrlReg_g->m_dwMagic = PCP_MAGIC;
    pCtrlReg_g->m_bError = 0x00;	///< no error
    pCtrlReg_g->m_bState = 0xff; 	///< set invalid PCP state

}

/**
********************************************************************************
\brief	initialize sync interrupt
*******************************************************************************/
void Gi_initSyncInt(void)
{
	// enable IRQ and set mode to "IR generation by SW"
	*SYNC_IRQ_CONTROL_REGISTER = (1 << SYNC_IRQ_ENABLE); // & (0 << SYNC_IRQ_MODE);
}

/**
********************************************************************************
\brief	calculate sync interrupt period
*******************************************************************************/
void Gi_calcSyncIntPeriod(void)
{
	int				iNumCycles;
	int				iSyncPeriod;
	unsigned int	uiCycleTime;
	unsigned int	uiSize;
	tEplKernel 		EplRet = kEplSuccessful;

	uiSize = sizeof(uiCycleTime);
	EplRet = EplApiReadLocalObject(0x1006, 0, &uiCycleTime, &uiSize);
	if (EplRet != kEplSuccessful)
	{
		pCtrlReg_g->m_bCycleError = kCnApiSyncCycleError;
		iSyncIntCycle_g = 0;
		return;
	}

	iNumCycles = (pCtrlReg_g->m_wMinCycleTime + uiCycleTime - 1) / uiCycleTime;	/* do it this way to round up integer division! */
	iSyncPeriod = iNumCycles * uiCycleTime;

	DEBUG_TRACE3 (DEBUG_LVL_CNAPI_INFO, "calcSyncIntPeriod: tCycle=%d tMinTime=%d --> syncPeriod=%d\n",
			       uiCycleTime, pCtrlReg_g->m_wMinCycleTime, iSyncPeriod);

	if (iNumCycles > pCtrlReg_g->m_bMaxCylceNum)
	{
		pCtrlReg_g->m_bCycleError = kCnApiSyncCycleError;
		iSyncIntCycle_g = 0;
		return;
	}

	if (iSyncPeriod > pCtrlReg_g->m_wMaxCycleTime)
	{
		pCtrlReg_g->m_bCycleError = kCnApiSyncCycleError;
		iSyncIntCycle_g = 0;
		return;
	}

	pCtrlReg_g->m_bCycleError = kCnApiSyncCycleOk;
	iSyncIntCycle_g = iNumCycles;
	return;
}

/**
********************************************************************************
\brief	generate the PCP -> AP synchronization interrupt
*******************************************************************************/
void Gi_generateSyncInt(void)
{
	/* Throw interrupt by writing to the SYNC_IRQ_CONTROL_REGISTER */
	*SYNC_IRQ_CONTROL_REGISTER |= (1 << SYNC_IRQ_SET); //set `set` bit to high
	return;
}

/**
********************************************************************************
\brief	disable the PCP -> AP synchronization interrupt
*******************************************************************************/
void Gi_disableSyncInt(void)
{
	/* disable interrupt by writing to the SYNC_IRQ_CONTROL_REGISTER */
	*SYNC_IRQ_CONTROL_REGISTER &= !(1 << SYNC_IRQ_ENABLE); // set enable bit to low
	return;
}

/**
********************************************************************************
\brief	set the PCP -> AP synchronization interrupt timer value for delay mode
*******************************************************************************/
void Gi_SetTimerSyncInt(UINT32 uiTimeValue)
{
	/* set timer value by writing to the SYNC_IRQ_TIMER_VALUE_REGISTER */
	*SYNC_IRQ_TIMER_VALUE_REGISTER = uiTimeValue;
	*SYNC_IRQ_CONTROL_REGISTER |= (1 << SYNC_IRQ_MODE); // set mode bit to high
	return;
}

/**
********************************************************************************
\brief	generate sync interrupt
*******************************************************************************/
static void setLed(BYTE bType_p, BOOL fOn_p)
{
	BYTE		bitMask;

	switch (bType_p)
	{
	case kEplLedTypeStatus:
		bitMask = 1;
		break;
	case kEplLedTypeError:
		bitMask = 2;
		break;
	default:
		bitMask = 0;
		break;
	}

#ifdef STATUS_LED_PIO_BASE
	if (fOn_p)
		IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(STATUS_LED_PIO_BASE, bitMask);
	else
		IOWR_ALTERA_AVALON_PIO_SET_BITS(STATUS_LED_PIO_BASE, bitMask);
#endif
}

/* EOF */
/*********************************************************************************/
