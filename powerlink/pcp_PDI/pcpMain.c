/**
********************************************************************************
\file		pcpMain.c

\brief		main module of powerlink stack for PCP, supporting an external SW API

\author		Josef Baumgartner

\date		06.04.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "Epl.h"
#include "Debug.h"
#include "EplPdou.h"

#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include <sys/alt_cache.h>

#include <unistd.h>

#include "pcp.h"
#include "pcpStateMachine.h"
#include "FpgaCfg.h"

#include "cnApiIntern.h"
#include "cnApiEvent.h"

/******************************************************************************/

// This function is the entry point for your object dictionary. It is defined
// in OBJDICT.C by define EPL_OBD_INIT_RAM_NAME. Use this function name to define
// this function prototype here. If you want to use more than one Epl
// instances then the function name of each object dictionary has to differ.



tEplKernel PUBLIC  EplObdInitRam (tEplObdInitParam MEM* pInitParam_p);
tEplKernel PUBLIC AppCbSync(void);
tEplKernel PUBLIC AppCbEvent(
    tEplApiEventType        EventType_p,   ///< IN: event type (enum)
    tEplApiEventArg*        pEventArg_p,   ///< IN: event argument (union)
    void GENERIC*           pUserArg_p);

tPcpCtrlReg		*pCtrlReg_g;               ///< ptr. to PCP control register
tCnApiInitParm 	initParm_g;                ///< Powerlink initialization parameter
BOOL 			fPLisInitalized_g = FALSE; ///< Powerlink initialization after boot-up flag
int				iSyncIntCycle_g;           ///< IR synchronization factor (multiple cycle time)

static BOOL     fShutdown_l = FALSE;       ///< Powerlink shutdown flag

/******************************************************************************/
/* forward declarations */
int openPowerlink(void);
void processPowerlink(void);
extern void Gi_throwPdiEvent(WORD wEventType_p, WORD wArg_p);

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
    int iRet= OK;
    tPdiAsyncStatus AsyncRet = kPdiAsyncStatusSuccessful;

	/* flush all caches */
    alt_icache_flush_all();
    alt_dcache_flush_all();

    switch (FpgaCfg_handleReconfig())
    {
        case kFgpaCfgFactoryImageLoadedNoUserImagePresent:
        {
            // user image reconfiguration failed
            DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Factory image loaded.\n");
            DEBUG_TRACE0(DEBUG_LVL_ERROR, "Last user image timed out or failed!\n");
            break;
        }
        case kFpgaCfgUserImageLoadedWatchdogDisabled:
        {
            DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "User image loaded.\n");
            break;
        }
        case kFpgaCfgUserImageLoadedWatchdogEnabled:
        {
            DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "User image loaded.\n");
            // watchdog timer has to be reset periodically
            FpgaCfg_resetWatchdogTimer(); // do this periodically!
            break;
        }
        case kFgpaCfgWrongSystemID:
        {
            DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Fatal error after booting! Shutdown!\n");
            goto exit; // fatal error
            break;
        }
    
        default:
        {
#ifndef NO_FACTORY_IMG_IN_FLASH
            DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Fatal error after booting! Shutdown!\n");
            goto exit; // this is fatal error only, if image was loaded from flash
#endif
        break;
        }
    }    
    
    DEBUG_TRACE0(DEBUG_LVL_09, "\n\nGeneric POWERLINK CN interface - this is PCP starting in main()\n\n");

    /***** initializations *****/
    DEBUG_TRACE0(DEBUG_LVL_09, "Initializing...\n");

    initStateMachine();
    Gi_init();
    iRet = CnApiAsync_init();
    if (iRet != OK )
    {
        Gi_throwPdiEvent(0, 0);
        DEBUG_TRACE0(DEBUG_LVL_09, "CnApiAsync_init() FAILED!\n");
        //TODO: set error flag at Cntrl Reg
        goto exit;
    }

    AsyncRet = CnApiAsync_finishMsgInit();
    if (AsyncRet != kPdiAsyncStatusSuccessful)
    {
        Gi_throwPdiEvent(kPcpPdiEventGenericError, kPcpGenErrInitFailed);
        DEBUG_TRACE0(DEBUG_LVL_09, "cnApiAsync_finishMsgInit() FAILED!\n");
        goto exit;
    }

    iRet = Gi_initPdo();
    if (iRet != OK )
    {
        Gi_throwPdiEvent(kPcpPdiEventGenericError, kPcpGenErrInitFailed);
        DEBUG_TRACE0(DEBUG_LVL_09, "Gi_initPdo() FAILED!\n");
        //TODO: set error flag at Cntrl Reg
        goto exit;
    }

     DEBUG_TRACE0(DEBUG_LVL_09, "OK\n");

#ifdef STATUS_LED_PIO_BASE
    IOWR_ALTERA_AVALON_PIO_DATA(STATUS_LED_PIO_BASE, 0xFF);
#endif

    processPowerlink();

    return OK;
exit:
    return ERROR;
}

/**
********************************************************************************
\brief	initialize openPOWERLINK stack
*******************************************************************************/
int initPowerlink(tCnApiInitParm *pInitParm_p)
{
	DWORD		 			ip = IP_ADDR;      ///< ip address
	static tEplApiInitParam EplApiInitParam;   ///< epl init parameter
	tEplKernel 				EplRet;

	DEBUG_FUNC;

	/* check if NodeID has been set to 0x00 by AP -> use node switches */
#ifdef SET_NODE_ID_BY_HW
	if(pInitParm_p->m_bNodeId == 0x00)
	{   /* read port configuration input pins and overwrite parameter */
	    pInitParm_p->m_bNodeId = IORD_ALTERA_AVALON_PIO_DATA(NODE_SWITCH_PIO_BASE);
	}
#endif /* SET_NODE_ID_BY_HW */

    /* setup the POWERLINK stack */
	/* calc the IP address with the nodeid */
	ip &= 0xFFFFFF00;                          ///< dump the last byte
	ip |= pInitParm_p->m_bNodeId;              ///< and mask it with the node id

	/* set EPL init parameters */
	EplApiInitParam.m_uiSizeOfStruct = sizeof (EplApiInitParam);
	EPL_MEMCPY(EplApiInitParam.m_abMacAddress, pInitParm_p->m_abMac, sizeof(EplApiInitParam.m_abMacAddress));
	EplApiInitParam.m_uiNodeId = pInitParm_p->m_bNodeId;
	EplApiInitParam.m_dwIpAddress = ip;
	EplApiInitParam.m_uiIsochrTxMaxPayload = 256; // TODO: use system.h define?
	EplApiInitParam.m_uiIsochrRxMaxPayload = 256; // TODO: use system.h define?
	EplApiInitParam.m_dwPresMaxLatency = 2000; // ns
	EplApiInitParam.m_dwAsndMaxLatency = 2000; // ns
	EplApiInitParam.m_fAsyncOnly = FALSE;
	EplApiInitParam.m_dwFeatureFlags = -1;                  // depends on openPOWERLINK module integration
	EplApiInitParam.m_dwCycleLen = DEFAULT_CYCLE_LEN;
	EplApiInitParam.m_uiPreqActPayloadLimit = 36;                              //TODO: use system.h define?
	EplApiInitParam.m_uiPresActPayloadLimit = 36;                              //TODO: use system.h define?
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

	DEBUG_TRACE1(DEBUG_LVL_09, "INFO: NODE ID is set to 0x%02x\n", EplApiInitParam.m_uiNodeId);

	/* inform AP about current node ID */
	pCtrlReg_g->m_wNodeId = EplApiInitParam.m_uiNodeId;
	Gi_throwPdiEvent(kPcpPdiEventGeneric, kPcpGenEventNodeIdConfigured);

	/* initialize POWERLINK stack */
	DEBUG_TRACE0(DEBUG_LVL_28, "init POWERLINK stack:\n");
	EplRet = EplApiInitialize(&EplApiInitParam);
	if(EplRet != kEplSuccessful)
	{
        DEBUG_TRACE1(DEBUG_LVL_28, "init POWERLINK Stack... error %X\n\n", EplRet);
    }
	else
	{
		DEBUG_TRACE0(DEBUG_LVL_28, "init POWERLINK Stack...ok\n\n");
		fPLisInitalized_g = TRUE;
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
    /***** Starting state machines *****/
    resetStateMachine();
    CnApi_activateAsyncStateMachine();

    while (stateMachineIsRunning())
    {
        /* process Powerlink and it API */
        CnApi_processAsyncStateMachine(); //TODO: Process in User-Callback Event!
        EplApiProcess();
        updateStateMachine();

        if (fShutdown_l == TRUE)
            break;
    }

    /* error occurred -> shutdown */
    DEBUG_TRACE0(DEBUG_LVL_28, "Shutdown EPL Stack\n");
    EplApiShutdown();                           ///<shutdown node

    DEBUG_TRACE0(DEBUG_LVL_09, "shut down POWERLINK CN interface ...\n");
    Gi_shutdown();

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

    /* check if NMT_GS_OFF is reached */
    switch (EventType_p)
    {

        case kEplApiEventNmtStateChange:
        {
            DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "%s(%s) originating event = 0x%X\n",
                                        __func__,
                                        getNmtState(pEventArg_p->m_NmtStateChange.m_NewNmtState),
                                        pEventArg_p->m_NmtStateChange.m_NmtEvent);

            //Gi_throwPdiEvent(kPcpPdiEventNmtStateChange, pEventArg_p->m_NmtStateChange.m_NewNmtState);

            if (pEventArg_p->m_NmtStateChange.m_NewNmtState != kEplNmtCsOperational)
            {
                Gi_disableSyncInt();
            }

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

                case kEplNmtCsPreOperational1:
                {
                    setPowerlinkEvent(kPowerlinkEventEnterPreOperational1);

                    break;
                }

                case kEplNmtCsPreOperational2:
                {
                    setPowerlinkEvent(kPowerlinkEventEnterPreop2);

                    EplRet = kEplReject; // prevent automatic change to kEplNmtCsReadyToOperate
                    break;
                }

                case kEplNmtCsReadyToOperate:
                {
                    break;
                }
                case kEplNmtGsResetConfiguration:
                {
                    break;
                }
                case kEplNmtGsInitialising:
                case kEplNmtGsResetApplication:
                case kEplNmtCsBasicEthernet:                        ///< this state is only indicated  by Led
                {
                    setPowerlinkEvent(kPowerlinkEventReset);        ///< fall back to PCP_PREOP1 (API-STATE)
                    break;
                }

                case kEplNmtGsResetCommunication:
                {
                    BYTE    bNodeId = 0xF0;
                    DWORD   dwNodeAssignment = EPL_NODEASSIGN_NODE_EXISTS;
                    WORD    wPresPayloadLimit = 256;

                    setPowerlinkEvent(kPowerlinkEventReset);        ///< fall back to PCP_PREOP1 (API-STATE)

                    EplRet = EplApiWriteLocalObject(0x1F81, bNodeId, &dwNodeAssignment, sizeof (dwNodeAssignment));
                    if (EplRet != kEplSuccessful)
                    {
                        goto Exit;
                    }

                    bNodeId = 0x06; //CN 6 is present in network
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
                    bNodeId = 0x7; //CN 7 is present in network
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

                case kEplNmtCsNotActive:                        ///< indicated only by Led, AP is not informed
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

            Gi_throwPdiEvent(kPcpPdiEventCriticalStackError, pEventArg_p->m_InternalError.m_EplError);

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

            //Gi_throwPdiEvent(kPcpPdiEventStackLed, pEventArg_p->m_Led.m_LedType);

        	switch (pEventArg_p->m_Led.m_LedType)
            {
                case kEplLedTypeStatus:
                	Gi_controlLED(kEplLedTypeStatus, pEventArg_p->m_Led.m_fOn);
                    break;
                case kEplLedTypeError:
                    Gi_controlLED(kEplLedTypeError, pEventArg_p->m_Led.m_fOn);
                    break;
                default:
                    break;
            }
            break;
        }

        case kEplApiEventHistoryEntry:
        {
            Gi_throwPdiEvent(kPcpPdiEventHistoryEntry, pEventArg_p->m_ErrHistoryEntry.m_wErrorCode);
            break;
        }

        case kEplApiEventBoot:
        {
            switch (pEventArg_p->m_Boot.m_BootEvent)
            {
                /*MN sent NMT command EnableReadyToOperate */
                case kEplNmtBootEventEnableReadyToOp:
                {
                    /* setup the synchronization interrupt time period */
                    Gi_calcSyncIntPeriod();   // calculate multiple of cycles

                    /* prepare PDO mapping */

                    /* setup PDO <-> DPRAM copy table */
                    CnApiAsync_postMsg(kPdiAsyncMsgIntLinkPdosReq, 0,0,0);

                    /* setup frame <-> PDO copy table - needs already linked objects! */
                    EplRet = EplPdouSetupAllPdoInternalCpyTable();
                    if (EplRet != kEplSuccessful)
                    {
                        goto Exit;
                    }

                    break;
                }

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
    if ((iSyncIntCycle_g != 0)) //TODO: enable PDI IRs in Operational, and disable for any other state
    {
		if ((iCycleCnt++ % iSyncIntCycle_g) == 0)
		{
			Gi_generateSyncInt();// TODO: To avoid jitter, synchronize on openMAC Sync interrupt instead of IR throwing by SW
		}
    }

    /* process Async DPRAM buffer */



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
	return pCtrlReg_g->m_wCommand;
}

/**
********************************************************************************
\brief	store the state the PCP is in
*******************************************************************************/
void storePcpState(BYTE bState_p)
{
	pCtrlReg_g->m_wState = bState_p;
}

/**
********************************************************************************
\brief	get the state of the PCP state machine
*******************************************************************************/
BYTE getPcpState(void)
{
	return pCtrlReg_g->m_wState;
}

/**
********************************************************************************
\brief  create table of objects to be linked at PCP side according to AP message

\param dwMaxLinks_p     Number of objects to be linked.
\param pObjLinksTable_p Returned pointer to object table. NULL if error occured.

\return OK or ERROR
*******************************************************************************/
int Gi_createPcpObjLinksTbl(DWORD dwMaxLinks_p)
{
    if (pPcpLinkedObjs_g != NULL) // table has already been created
    {
        free(pPcpLinkedObjs_g);
    }
    /* allocate memory for object table */
    if ((pPcpLinkedObjs_g = malloc (sizeof(tObjTbl) * dwMaxLinks_p)) == NULL)
    {
        return ERROR;
    }
    dwApObjLinkEntries_g = 0; // reset entry counter

    return OK;
}

/**
********************************************************************************
\brief	basic initializations
*******************************************************************************/

void Gi_init(void)
{
	/* Setup PCP Control Register in DPRAM */

    pCtrlReg_g = (tPcpCtrlReg *)PDI_DPRAM_BASE_PCP;	   ///< set address of control register - equals DPRAM base address

    pCtrlReg_g->m_dwMagic = PCP_MAGIC;                 ///< unique identifier

    pCtrlReg_g->m_dwFpgaSysId = SYSID_ID;              // FPGA system ID from system.h
    pCtrlReg_g->m_wEventType = 0x00;                   ///< invalid event TODO: structure
    pCtrlReg_g->m_wEventArg = 0x00;                    ///< invalid event argument TODO: structure
    pCtrlReg_g->m_wState = kPcpStateInvalid;           ///< set invalid PCP state

    Gi_disableSyncInt();
}

/**
********************************************************************************
\brief  cleanup and exit generic interface
*******************************************************************************/

void Gi_shutdown(void)
{
    /* free object link table */
    free(pPcpLinkedObjs_g);

    //TODO: free other things
}

/**
********************************************************************************
\brief	enable the synchronous PDI interrupt
*******************************************************************************/
void Gi_enableSyncInt(void)
{

    //TODO: set HW triggered, if timer is present (system.h define)

	// enable IRQ and set mode to "IR generation by SW"
    pCtrlReg_g->m_wSyncIrqControl = ((1 << SYNC_IRQ_ENABLE) & ~(1 << SYNC_IRQ_MODE));
}

/**
********************************************************************************
\brief  read control register sync mode flags
*******************************************************************************/
BOOL Gi_checkSyncIrqRequired(void)
{
    WORD wSyncModeFlags;

    wSyncModeFlags = pCtrlReg_g->m_wSyncIrqControl;

    if(wSyncModeFlags &= (1 << SYNC_IRQ_REQ))
    {
        return TRUE;  ///< Sync IR is required
    }
    else
    {
        return FALSE; ///< Sync IR is not required -> AP applies polling
    }
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
	    Gi_throwPdiEvent(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
		iSyncIntCycle_g = 0;
		return;
	}

	if (pCtrlReg_g->m_dwMinCycleTime == 0 &&
	    pCtrlReg_g->m_dwMaxCycleTime == 0 &&
	    pCtrlReg_g->m_wMaxCycleNum == 0)
    {
	    /* no need to trigger IR signal - polling mode is applied */
	    iSyncIntCycle_g = 0;
        return;
    }

	iNumCycles = (pCtrlReg_g->m_dwMinCycleTime + uiCycleTime - 1) / uiCycleTime;	/* do it this way to round up integer division! */
	iSyncPeriod = iNumCycles * uiCycleTime;

	DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "calcSyncIntPeriod: tCycle=%d tMinTime=%lu --> syncPeriod=%d\n",
			       uiCycleTime, pCtrlReg_g->m_dwMinCycleTime, iSyncPeriod);

	if (iNumCycles > pCtrlReg_g->m_wMaxCycleNum)
	{
	    Gi_throwPdiEvent(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
		iSyncIntCycle_g = 0;
		return;
	}

	if (iSyncPeriod > pCtrlReg_g->m_dwMaxCycleTime)
	{
	    DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: Cycle time set by network to high for AP!\n");

	    Gi_throwPdiEvent(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
		iSyncIntCycle_g = 0;
		return;
	}
    if (iSyncPeriod < pCtrlReg_g->m_dwMinCycleTime)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: Cycle time set by network to low for AP!\n");

        Gi_throwPdiEvent(kPcpPdiEventGenericError, kPcpGenErrSyncCycleCalcError);
        iSyncIntCycle_g = 0;
        return;
    }

	iSyncIntCycle_g = iNumCycles;
	pCtrlReg_g->m_dwSyncIntCycTime = iSyncPeriod;  ///< inform AP: write result in control register
    Gi_throwPdiEvent(kPcpPdiEventGeneric, kPcpGenEventSyncCycleCalcSuccessful);

	return;
}

/**
********************************************************************************
\brief	generate the PCP -> AP synchronization interrupt
*******************************************************************************/
void Gi_generateSyncInt(void)
{
	/* Throw interrupt by writing to the SYNC_IRQ_CONTROL_REGISTER */
    pCtrlReg_g->m_wSyncIrqControl |= (1 << SYNC_IRQ_SET); //set IRQ_SET bit to high
	return;
}

/**
********************************************************************************
\brief	disable the PCP -> AP synchronization interrupt
*******************************************************************************/
void Gi_disableSyncInt(void)
{
	/* disable interrupt by writing to the SYNC_IRQ_CONTROL_REGISTER */
    pCtrlReg_g->m_wSyncIrqControl &= ~(1 << SYNC_IRQ_ENABLE); // set enable bit to low
	return;
}

/**
********************************************************************************
\brief	set the PCP -> AP synchronization interrupt timer value for delay mode
*******************************************************************************/
void Gi_SetTimerSyncInt(UINT32 uiTimeValue)
{
	/* set timer value by writing to the SYNC_IRQ_TIMER_VALUE_REGISTER */
    // pCtrlReg_g->m_dwPcpIrqTimerValue = uiTimeValue; TODO: This is not in PDI, but in openMAC (2nd timer)! Check doku.
	pCtrlReg_g->m_wSyncIrqControl |= (1 << SYNC_IRQ_MODE); ///< set mode bit to high -> HW assertion
	return;
}

/**
 ********************************************************************************
 \brief	set event and related argument in PCP control register to inform AP
 \param	wEventType_p    event type (e.g. state change, error, ...)
 \param wArg_p          event argument (e.g. NmtState, error code ...)

 This function fills the event related PCP PDI register with an AP known value,
 and informs the AP this way about occurred events. The AP has to acknowledge
 an event after reading out the registers.
 According to the Asynchronous IRQ configuration register, the PCP might assert
 an IR signal in case of an event.
 *******************************************************************************/
void Gi_throwPdiEvent(WORD wEventType_p, WORD wArg_p)
{
    WORD wEventAck;

    wEventAck = pCtrlReg_g->m_wEventAck;

    /* check if previous event has been confirmed by AP */
    if ((wEventAck & (1 << EVT_GENERIC)) == 0)
    { //confirmed -> set event

        pCtrlReg_g->m_wEventType = wEventType_p;
        pCtrlReg_g->m_wEventArg = wArg_p;

        /* set GE bit to signal event to AP; If desired by AP,
         *  an IR signal will be asserted in addition */
        pCtrlReg_g->m_wEventAck = (1 << EVT_GENERIC);
    }
    else // not confirmed -> do not overwrite
    {
       //TODO: store in event history
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO,"%s: AP too slow!\n", __func__);
    }
}

/**
********************************************************************************
\brief	control LED outputs of POWERLINK IP core
*******************************************************************************/
void Gi_controlLED(BYTE bType_p, BOOL bOn_p)
{
    WORD        wRegisterBitNum;

    switch (bType_p)
        {
        case kEplLedTypeStatus:
            wRegisterBitNum = LED_STATUS;
            break;
        case kEplLedTypeError:
            wRegisterBitNum = LED_ERROR;
            break;
        case kEplLedTypeTestAll:
            /* This case if for testing the LEDs */
            /* enable forcing for all LEDs */
            pCtrlReg_g->m_wLedConfig = 0xffff;
            if (bOn_p)  //activate LED output
            {
                pCtrlReg_g->m_wLedControl = 0xffff; // switch on all LEDs
            }
            else       // deactive LED output
            {
                pCtrlReg_g->m_wLedControl = 0x0000; // switch off all LEDs

                /* disable forcing all LEDs except status and error LED (default register value) */
                pCtrlReg_g->m_wLedConfig = 0x0003;
            }
            goto exit;
        default:
            goto exit;
        }

    if (bOn_p)  //activate LED output
    {
        pCtrlReg_g->m_wLedControl |= (1 << wRegisterBitNum);
    }
    else        // deactive LED output
    {
        pCtrlReg_g->m_wLedControl &= ~(1 << wRegisterBitNum);
    }

exit:
    return;
}

#ifdef STATUS_LED_PIO_BASE
#warning Deprecated! Deactivate STATUS_LED_PIO_BASE in SOPC-Builder!
#endif

/* EOF */
/*********************************************************************************/
