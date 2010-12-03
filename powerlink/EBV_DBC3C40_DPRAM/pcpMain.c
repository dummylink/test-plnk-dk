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

#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include <sys/alt_cache.h>

#include <unistd.h>

#include "pcp.h"
#include "cnApi.h"
#include "cnApiIntern.h"
#include "pcpStateMachine.h"

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

BOOL            fIrqSyncMode_g = FALSE;    ///< synchronization mode flag
static BOOL     fShutdown_l = FALSE;       ///< Powerlink shutdown flag

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
    int iRet= OK;

	/* flush all caches */
    alt_icache_flush_all();
    alt_dcache_flush_all();

    DEBUG_TRACE0(DEBUG_LVL_09, "\n\nGeneric POWERLINK CN interface - this is PCP starting in main()\n\n");

    /***** initializations *****/
    DEBUG_TRACE0(DEBUG_LVL_09, "Initializing...\n");

    initStateMachine();
    Gi_init();
    Gi_initAsync((tAsyncMsg *)(PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wTxAsyncBufAoffs),
    		     (tAsyncMsg *)(PDI_DPRAM_BASE_PCP + pCtrlReg_g->m_wRxAsyncBufAoffs));
    iRet = Gi_initPdo();
    if (iRet != OK )
    {
        DEBUG_TRACE0(DEBUG_LVL_09, "Gi_initPdo() FAILED!\n");
        //TODO: set error flag at Cntrl Reg
        goto exit;
    }

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
    	//usleep(100);		                   ///< wait 100 us//TODO: use this value ?
    }

    DEBUG_TRACE0(DEBUG_LVL_09, "shut down POWERLINK CN interface ...\n");

    Gi_shutdown();

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
	EplApiInitParam.m_uiIsochrTxMaxPayload = pInitParm_p->m_wIsoTxMaxPayload; // TODO: use system.h define?
	EplApiInitParam.m_uiIsochrRxMaxPayload = pInitParm_p->m_wIsoRxMaxPayload; // TODO: use system.h define?
	EplApiInitParam.m_dwPresMaxLatency = pInitParm_p->m_dwPresMaxLatency;
	EplApiInitParam.m_dwAsndMaxLatency = pInitParm_p->m_dwAsendMaxLatency;
	EplApiInitParam.m_fAsyncOnly = FALSE;
	EplApiInitParam.m_dwFeatureFlags = pInitParm_p->m_dwFeatureFlags;
	EplApiInitParam.m_dwCycleLen = DEFAULT_CYCLE_LEN;
	EplApiInitParam.m_uiPreqActPayloadLimit = 36;                              //TODO: use system.h define?
	EplApiInitParam.m_uiPresActPayloadLimit = 36;                              //TODO: use system.he define?
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
    while(1)
    {
        EplApiProcess();
        if (fShutdown_l == TRUE)
            break;
    }

    DEBUG_TRACE0(DEBUG_LVL_28, "Shutdown EPL Stack\n");
    EplApiShutdown();                           ///<shutdown node
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
    WORD wCurDescrPayloadOffset = 0; ///< TODO: put this var to Async or pdo module
    tLinkPdosReq *pLinkPdosReq; //TODO: Replace with local message buffer (queue)

    /* check if NMT_GS_OFF is reached */
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

                case kEplNmtCsPreOperational1:
                {
                    setPowerlinkEvent(kPowerlinkEventEnterPreOperational1);
                    break;
                }

                case kEplNmtCsPreOperational2:
                {
                	setPowerlinkEvent(kPowerlinkEventEnterPreop2);
               		EplRet = kEplReject;
                	break;
                }

                case kEplNmtCsReadyToOperate:
                {
                    setPowerlinkEvent(kPowerlinkEventkEnterReadyToOperate);
                	break;
                }
                case kEplNmtGsResetConfiguration:
                {
                    /* Prepare PDO descriptor message for AP */
                    //TODO: use local message structure for this message (not directly in Async Buffer)
                    pLinkPdosReq = pAsycMsgLinkPdoReq_g;
                    pLinkPdosReq->m_bDescrCnt = 0; ///< reset descriptor counter //TODO: do this in initialization

                    Gi_setupPdoDesc(kCnApiDirReceive, &wCurDescrPayloadOffset, pLinkPdosReq);
                    Gi_setupPdoDesc(kCnApiDirTransmit, &wCurDescrPayloadOffset, pLinkPdosReq);

                    pLinkPdosReq->m_bDescrVers++; ///< increase descriptor version number
                    pLinkPdosReq->m_bCmd = kAsyncCmdLinkPdosReq;

                    DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Descriptor Version: %d\n", pLinkPdosReq->m_bDescrVers);

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

    if ((pCtrlReg_g->m_bSyncMode & CNAPI_SYNC_MODE_IR_EN) &&
        (iSyncIntCycle_g != 0)                            &&
        (getPcpState()== kPcpStateOperational)               )
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
    pCtrlReg_g->m_bError = 0x00;	                   ///< no error
    pCtrlReg_g->m_bState = 0xff; 	                   ///< set invalid PCP state
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
\brief	initialize sync interrupt
*******************************************************************************/
void Gi_initSyncInt(void)
{
	// enable IRQ and set mode to "IR generation by SW"
    pCtrlReg_g->m_bSyncIrqControl = (1 << SYNC_IRQ_ENABLE); // & (0 << SYNC_IRQ_MODE);
}

/**
********************************************************************************
\brief  read control register sync mode flags
*******************************************************************************/
void Gi_getSyncIntModeFlags(void)
{
    BYTE bSyncModeFlags;

    bSyncModeFlags = pCtrlReg_g->m_bSyncMode;

    if(bSyncModeFlags &= CNAPI_SYNC_MODE_IR_EN)
    {
        fIrqSyncMode_g = TRUE;  ///< Sync IR is enabled
    }
    else
    {
        fIrqSyncMode_g = FALSE; ///< Sync IR is disabled -> AP applies polling
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
		pCtrlReg_g->m_bCycleError = kCnApiSyncCycleError;
		iSyncIntCycle_g = 0;
		return;
	}

	iNumCycles = (pCtrlReg_g->m_wMinCycleTime + uiCycleTime - 1) / uiCycleTime;	/* do it this way to round up integer division! */
	iSyncPeriod = iNumCycles * uiCycleTime;

	DEBUG_TRACE3(DEBUG_LVL_CNAPI_INFO, "calcSyncIntPeriod: tCycle=%d tMinTime=%d --> syncPeriod=%d\n",
			       uiCycleTime, pCtrlReg_g->m_wMinCycleTime, iSyncPeriod);

	if (iNumCycles > pCtrlReg_g->m_bMaxCylceNum)
	{
		pCtrlReg_g->m_bCycleError = kCnApiSyncCycleError;
		iSyncIntCycle_g = 0;
		return;
	}

	if (iSyncPeriod > pCtrlReg_g->m_wMaxCycleTime)
	{
	    DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: Cycle time set by network to high for AP!\n");

		pCtrlReg_g->m_bCycleError = kCnApiSyncCycleError;
		iSyncIntCycle_g = 0;
		return;
	}
    if (iSyncPeriod < pCtrlReg_g->m_wMinCycleTime)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR, "ERROR: Cycle time set by network to low for AP!\n");

        pCtrlReg_g->m_bCycleError = kCnApiSyncCycleError;
        iSyncIntCycle_g = 0;
        return;
    }

	pCtrlReg_g->m_bCycleError = kCnApiSyncCycleOk;
	iSyncIntCycle_g = iNumCycles;
	pCtrlReg_g->m_dwSyncIntCycTime = iSyncPeriod;  ///< inform AP: write result in control register

	return;
}

/**
********************************************************************************
\brief	generate the PCP -> AP synchronization interrupt
*******************************************************************************/
void Gi_generateSyncInt(void)
{
	/* Throw interrupt by writing to the SYNC_IRQ_CONTROL_REGISTER */
    pCtrlReg_g->m_bSyncIrqControl |= (1 << SYNC_IRQ_SET); //set `set` bit to high
	return;
}

/**
********************************************************************************
\brief	disable the PCP -> AP synchronization interrupt
*******************************************************************************/
void Gi_disableSyncInt(void)
{
	/* disable interrupt by writing to the SYNC_IRQ_CONTROL_REGISTER */
    pCtrlReg_g->m_bSyncIrqControl &= !(1 << SYNC_IRQ_ENABLE); // set enable bit to low
	return;
}

/**
********************************************************************************
\brief	set the PCP -> AP synchronization interrupt timer value for delay mode
*******************************************************************************/
void Gi_SetTimerSyncInt(UINT32 uiTimeValue)
{
	/* set timer value by writing to the SYNC_IRQ_TIMER_VALUE_REGISTER */
    pCtrlReg_g->m_dwPcpIrqTimerValue = uiTimeValue;
	pCtrlReg_g->m_bSyncIrqControl |= (1 << SYNC_IRQ_MODE); ///< set mode bit to high -> HW assertion
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
