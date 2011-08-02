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
#include "EplSdoComu.h"

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

#include "EplSdo.h"
#include "EplAmi.h"
#include "EplObd.h"
//#include "EplObdk.h"
//#include "EplNmtk.h"
//#include "EplDllk.h"
//#include "EplDllkCal.h"
//#include "EplPdokCal.h"
//#include "EplDlluCal.h"
//#include "EplDllu.h"
#include "EplNmtCnu.h"
#include "EplSdoComu.h"
#include "EplTimeru.h"

//---------------------------------------------------------------------------
// defines
//---------------------------------------------------------------------------
#define OBD_DEFAULT_SEG_WRITE_HISTORY_ACK_FINISHED_THLD 2
#define OBD_DEFAULT_SEG_WRITE_SIZE 20

//---------------------------------------------------------------------------
// module global vars
//---------------------------------------------------------------------------
tPcpCtrlReg		* volatile pCtrlReg_g;               ///< ptr. to PCP control register
tCnApiInitParm 	initParm_g;                ///< Powerlink initialization parameter
BOOL 			fPLisInitalized_g = FALSE; ///< Powerlink initialization after boot-up flag
int				iSyncIntCycle_g;           ///< IR synchronization factor (multiple cycle time)

static BOOL     fShutdown_l = FALSE;       ///< Powerlink shutdown flag
static tDefObdAccHdl aObdDefAccHdl_l[OBD_DEFAULT_SEG_WRITE_SIZE]; ///< segmented object access management

/* counter of currently empty OBD segmented write history elements for default OBD access */
BYTE bObdSegWriteAccHistoryEmptyCnt_g = OBD_DEFAULT_SEG_WRITE_SIZE;
BYTE bObdSegWriteAccHistoryFinishedCnt_g = 0;

tEplObdParam * ApiPdiComInstance_g = NULL;
/******************************************************************************/
// TEST SDO TRANSFER TO AP
// flag
static BOOL    fSdoSuccessful_l;

// strints to print out states of sdo transfer
static char aszSdoStates_l[6][40]={"Connection not active\n",
                                "Transfer running\n",
                                "TX Abort\n",
                                "RX Abort\n",
                                "Sdo Tranfer finished\n",
                                "Sdo Transfer aborted by lower layer\n"};

static tEplSdoComConHdl          SdoComConHdl_l = 0;
static unsigned int              uiBuffer_l;


/******************************************************************************/
// This function is the entry point for your object dictionary. It is defined
// in OBJDICT.C by define EPL_OBD_INIT_RAM_NAME. Use this function name to define
// this function prototype here. If you want to use more than one Epl
// instances then the function name of each object dictionary has to differ.
tEplKernel PUBLIC  EplObdInitRam (tEplObdInitParam MEM* pInitParam_p);
tEplKernel PUBLIC AppCbSync(void);
tEplKernel PUBLIC AppCbEvent(
    tEplApiEventType        EventType_p,
    tEplApiEventArg*        pEventArg_p,
    void GENERIC*           pUserArg_p);
static tEplKernel  EplAppCbDefaultObdAccess(tEplObdParam MEM* pObdParam_p);
static tEplKernel EplAppDefObdAccSaveHdl(tEplObdParam *  pObdParam_p);
static tEplKernel EplAppDefObdAccGetStatusDependantHdl(
        tEplObdParam * pObdAccParam_p,
        WORD wIndex_p,
        WORD wSubIndex_p,
        tDefObdAccHdl **  ppDefObdAccHdl_p,
        tEplObdDefAccStatus ReqStatus_p);
static tEplKernel EplAppDefObdAccCountHdlStatus(
        WORD wIndex_p,
        WORD wSubIndex_p,
        WORD *  pwCntRet_p,
        tEplObdDefAccStatus ReqStatus_p);
static tEplKernel EplAppDefObdAccWriteObdSegmented(tDefObdAccHdl *  pDefObdAccHdl_p);
static tEplKernel EplAppCbSdoConnectionSourcePdiFinished(tEplSdoComFinished*  pSdoComFinished_p);

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
    EplApiInitParam.m_pfnDefaultObdCallback = EplAppCbDefaultObdAccess; // called if objects do not exist in local OBD
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

                    //TEST of AP SDO TRANSFERS
                    /******************************************************************************/
#if 0//#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
                    tEplSdoComTransParamByIndex TransParamByIndex;


                    // init command layer connection
                    EplRet = EplSdoComDefineCon(&SdoComConHdl_l,
                                                0x01,  // target node id -> take any valid powerlink node id. e.g. 0x01!
                                                kEplSdoTypeApiPdi);
                    if(EplRet != kEplSuccessful)
                    {
                        printf("Define of SDO via UDP Connection failed: 0x%03X\n", EplRet);
                    }

                    // read object 0x1000
                    TransParamByIndex.m_pData = &uiBuffer_l; // provide data buffer to SDO Client
                    TransParamByIndex.m_SdoAccessType = kEplSdoAccessTypeRead;
                    TransParamByIndex.m_SdoComConHdl = SdoComConHdl_l; // EplSdoComDefineCon returned this handle
                    TransParamByIndex.m_uiDataSize = sizeof(uiBuffer_l);
                    TransParamByIndex.m_uiIndex = 0x6500;
                    TransParamByIndex.m_uiSubindex = 0x01;
                    TransParamByIndex.m_uiTimeout = 0;
                    TransParamByIndex.m_pfnSdoFinishedCb = EplAppCbSdoConnectionSourcePdiFinished;
                    TransParamByIndex.m_pUserArg = TransParamByIndex.m_pData;

                    EplRet = EplSdoComInitTransferByIndex(&TransParamByIndex);
                    if (EplRet != kEplSuccessful)
                    {
                        printf("Error = 0x%04X in function EplSdoComInitTransferByIndex\n", EplRet);
                    }
                    else
                    {   // wait for end of transfer
                        printf("Read of object 0x1000 started\n");
                    }
#endif
                    /******************************************************************************/


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
                    // clean OBD access application history buffers
                    EplRet = EplAppDefObdAccCleanupHistory(); //TODO: move to other place?
                    if (EplRet != kEplSuccessful)
                    {
                        goto Exit;
                    }

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

                    if (CnApiAsync_postMsg(kPdiAsyncMsgIntLinkPdosReq, 0,0,0) !=
                        kPdiAsyncStatusSuccessful                               )
                    {
                        EplRet = kEplReject;
                        goto Exit;
                    }

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

        case kEplApiEventUserDef:
        {   // this case is assumed to handle only default OBD accesses

        tEplObdParam *  pObdParam;
        tDefObdAccHdl * pFoundHdl;               ///< pointer to OBD access handle
//        tEplTimerArg    TimerArg;                ///< timer event posting
//        tEplTimerHdl    EplTimerHdl;             ///< timer event posting
        volatile WORD     wFinishedHistoryCnt = 0; ///< counter finished history elements

            // assign user argument
            pObdParam = (tEplObdParam *) pEventArg_p->m_pUserArg;

            printf("AppCbEvent(kEplApiEventUserDef): (EventArg %p)\n", pObdParam);

            if(pObdParam->m_uiIndex != 0x1F50)
            {   // should not get any other indices
                EplRet = kEplInvalidParam;
                goto Exit;
            }

            printf("(0x%04X/%u Ev=%X pData=%p Off=%u Size=%u\n"
                   "                         ObjSize=%u TransSize=%u Acc=%X Typ=%X)\n",
                pObdParam->m_uiIndex, pObdParam->m_uiSubIndex,
                pObdParam->m_ObdEvent,
                pObdParam->m_pData, pObdParam->m_SegmentOffset, pObdParam->m_SegmentSize,
                pObdParam->m_ObjSize, pObdParam->m_TransferSize, pObdParam->m_Access, pObdParam->m_Type);

            // check if write operation has already started for this object
            EplRet = EplAppDefObdAccGetStatusDependantHdl(
                    0,
                    pObdParam->m_uiIndex,
                    pObdParam->m_uiSubIndex,
                    &pFoundHdl,
                    kEplObdDefAccHdlInUse);

            if (EplRet == kEplSuccessful)
            {   // write operation is already processing -> exit
                printf(" Write already in progress->exit\n");

                // get segmented OBD access handle
                EplRet = EplAppDefObdAccGetStatusDependantHdl(
                        pObdParam,
                        0,
                        0,
                        &pFoundHdl,
                        0);

                if (EplRet != kEplSuccessful)
                {   // handle incorrectly assigned -> signal error

                    printf("ERROR: No handle assigned!\n");

                    pObdParam->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
                    EplRet = EplAppDefObdAccFinished(pObdParam);
                    // correct history status
                    pFoundHdl->m_Status = kEplObdDefAccHdlEmpty;
                    bObdSegWriteAccHistoryEmptyCnt_g++;

                    //TODO: Abort all not empty handles of segmented transfer

                    goto Exit;
                }

                // change handle status
                pFoundHdl->m_Status = kEplObdDefAccHdlWaitProcessingQueue;

//                TimerArg.m_EventSink = kEplEventSinkApi;
//                TimerArg.m_Arg.m_pVal = (void*) pObdParam;

                // try again later
//                EplRet = EplTimeruSetTimerMs(&EplTimerHdl,
//                                            1000000,
//                                            TimerArg);
//                if(Ret != kEplSuccessful)
//                {
//                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_DUE_LOCAL_CONTROL;
//                    EPL_FREE(pAllocObdParam);
//                    goto Exit;
//                }

//                EplRet = EplApiPostUserEvent((void*) pObdParam);
//                if (EplRet != kEplSuccessful)
//                {
//                    goto Exit;
//                }

                EplRet = kEplSuccessful;
                goto Exit;
            }

            // get segmented OBD access handle
            EplRet = EplAppDefObdAccGetStatusDependantHdl(
                    pObdParam,
                    0,
                    0,
                    &pFoundHdl,
                    0);

            if (EplRet != kEplSuccessful)
            {   // handle incorrectly assigned -> signal error

                printf("ERROR: No handle assigned!\n");

                pObdParam->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
                EplRet = EplAppDefObdAccFinished(pObdParam);
                // correct history status
                pFoundHdl->m_Status = kEplObdDefAccHdlEmpty;
                bObdSegWriteAccHistoryEmptyCnt_g++;

                //TODO: Abort all not empty handles of segmented transfer

                goto Exit;
            }

            if ((pFoundHdl->m_Status != kEplObdDefAccHdlWaitProcessingInit) &&
                (pFoundHdl->m_Status != kEplObdDefAccHdlWaitProcessingQueue)  )
            {
                printf("ERROR: Invalid handle status!\n");

                //TODO: Abort all not empty handles of segmented transfer

                EplRet = kEplInvalidParam;
                goto Exit;
            }

            // -------- do OBD write -----
            // write access might take some time ...
            // it might be interrupted by new remote OBD accesses (Rx IR)
            EplRet = EplAppDefObdAccWriteObdSegmented(pFoundHdl);

            if (EplRet != kEplSuccessful)
            {   // signal write error if write operation went wrong
                pObdParam->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
                EplRet = EplAppDefObdAccFinished(pObdParam);
                // correct history status
                pFoundHdl->m_Status = kEplObdDefAccHdlEmpty;
                bObdSegWriteAccHistoryEmptyCnt_g++;

                //TODO: Abort all not empty handles of segmented transfer

                goto Exit;
            }

            // count all finished handles
            EplRet = EplAppDefObdAccCountHdlStatus(
                    0,
                    0,
                    &wFinishedHistoryCnt,
                    kEplObdDefAccHdlProcessingFinished);
            if (EplRet != kEplSuccessful)
            {
                goto Exit;
            }

            // check if segmented write history is full (flow control for SDO)
            if ((OBD_DEFAULT_SEG_WRITE_SIZE - bObdSegWriteAccHistoryEmptyCnt_g <=    //occupied elements
                 OBD_DEFAULT_SEG_WRITE_HISTORY_ACK_FINISHED_THLD)                 ||
                (OBD_DEFAULT_SEG_WRITE_SIZE - bObdSegWriteAccHistoryEmptyCnt_g ==    // occupied elements
                 wFinishedHistoryCnt)                                               )// should all be finished
            {   // call m_pfnAccessFinished - this will set the handle status to "empty"

                // acknowledge all finished segments of this index
                EplRet = kEplSuccessful;
                while (EplRet == kEplSuccessful)
                {
                    //search for handle where m_pfnAccessFinished call is still due
                    EplRet = EplAppDefObdAccGetStatusDependantHdl(
                            0,
                            pObdParam->m_uiIndex,
                            pObdParam->m_uiSubIndex,
                            &pFoundHdl,
                            kEplObdDefAccHdlProcessingFinished);

                    if (EplRet == kEplSuccessful)
                    {   // signal "OBD access finished" to originator

                        // this triggers an Ack of the last received SDO sequence in case of remote access
                        EplRet = EplAppDefObdAccFinished(pFoundHdl->m_pObdParam);

                        // correct history status
                        pFoundHdl->m_Status = kEplObdDefAccHdlEmpty;
                        bObdSegWriteAccHistoryEmptyCnt_g++;

                        goto Exit;
                    }
                }
            }
            else
            {   // go on processing the history without calling m_pfnAccessFinished

                EplRet = EplAppDefObdAccGetStatusDependantHdl(
                        0,
                        pObdParam->m_uiIndex,
                        pObdParam->m_uiSubIndex,
                        &pFoundHdl,
                        kEplObdDefAccHdlWaitProcessingQueue);

                if (EplRet == kEplSuccessful)
                {   // handle found

                    EplRet = EplApiPostUserEvent((void*) pFoundHdl->m_pObdParam);
                    if (EplRet != kEplSuccessful)
                    {
                        goto Exit;
                    }
                }

                EplRet = kEplSuccessful; // nothing to post, thats fine
                goto Exit;
            }

            EplRet = kEplSuccessful;
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
 \brief cleans the default OBD access history buffers

 This function clears errors from the segmented access history buffer which is
 used for default OBD accesses.
 *******************************************************************************/
tEplKernel EplAppDefObdAccCleanupHistory(void)
{
tEplKernel EplRet = kEplSuccessful;
tDefObdAccHdl * pObdDefAccHdl = NULL;
BYTE bArrayNum;                 ///< loop counter and array element

    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_SEG_WRITE_SIZE; bArrayNum++, pObdDefAccHdl++)
    {
        switch (pObdDefAccHdl->m_Status)
        {
            case kEplObdDefAccHdlEmpty:
            {
                continue; // go to next loop iteration
            }

            default:
            {
                // signal write error if write operation went wrong
                pObdDefAccHdl->m_pObdParam->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
                break;
            }
        }

        // free all buffers used for segmented transfer // TODO: free data already done in finished function...
//        if (pObdDefAccHdl->m_pObdParam->m_pData != NULL)
//        {
//            EPL_FREE(pObdDefAccHdl->m_pObdParam->m_pData);
//            pObdDefAccHdl->m_pObdParam->m_pData = NULL;
//        }

        if (pObdDefAccHdl->m_pObdParam != NULL)
        {
            // signal "OBD access finished" to originator
            // this triggers an Ack of the last received SDO sequence in case of remote access
            EplRet = EplAppDefObdAccFinished(pObdDefAccHdl->m_pObdParam);
            if (EplRet != kEplSuccessful)
            {
                goto Exit;
            }
        }

        // correct history status
        pObdDefAccHdl->m_Status = kEplObdDefAccHdlEmpty;
        bObdSegWriteAccHistoryEmptyCnt_g++;
    }

Exit:
    return EplRet;
}

/**
 ********************************************************************************
 \brief signals an OBD default access as finished
 \param pObdParam_p
 \return tEplKernel value
 *******************************************************************************/
tEplKernel EplAppDefObdAccFinished(tEplObdParam * pObdParam_p)
{
tEplKernel EplRet = kEplSuccessful;

    printf("INFO: %s(%p) called\n", __func__, pObdParam_p);

    if (pObdParam_p == NULL                     ||
        pObdParam_p->m_pfnAccessFinished == NULL  )
    {
        EplRet = kEplInvalidParam;
        goto Exit;
    }

    // check if it was a segmented write SDO transfer (domain object write access)
    if ((pObdParam_p->m_ObdEvent == kEplObdEvPreRead)          &&
        (pObdParam_p->m_SegmentSize != pObdParam_p->m_ObjSize) ||
        (pObdParam_p->m_SegmentOffset != 0)                      )
    {
        //segmented read access not allowed!
        pObdParam_p->m_dwAbortCode = EPL_SDOAC_UNSUPPORTED_ACCESS;
    }

    // call callback function which was assigned by caller
    EplRet = pObdParam_p->m_pfnAccessFinished(pObdParam_p);

    if ((pObdParam_p->m_Type == kEplObdTypDomain)         &&
        (pObdParam_p->m_ObdEvent == kEplObdEvInitWriteLe) &&
        (pObdParam_p->m_uiIndex == 0x1F50)                  )
    {   // free allocated memory for segmented write transfer history

        if (pObdParam_p->m_pData != NULL)
        {
            EPL_FREE(pObdParam_p->m_pData);
            pObdParam_p->m_pData = NULL;
        }
        else
        {   //allocation expected, but not present!
            EplRet = kEplInvalidParam;
        }
    }

    // free handle storage
    EPL_FREE(pObdParam_p);
    pObdParam_p = NULL;

Exit:
    if (EplRet != kEplSuccessful)
    {
        printf("ERROR: %s failed!\n", __func__);
    }
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
    tEplKernel  EplRet = kEplSuccessful;
    static  unsigned int iCycleCnt = 0;

    /* check if interrupts are enabled */
    if ((iSyncIntCycle_g != 0)) //TODO: enable PDI IRs in Operational, and disable for any other state
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
        EPL_FREE(pPcpLinkedObjs_g);
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
    EPL_FREE(pPcpLinkedObjs_g);

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

/**
 ********************************************************************************
 \brief called if object index does not exits in OBD
 \param pObdParam_p   OBD access structure
 \return    tEplKernel value

 This default OBD access callback function shall be invoked if an index is not
 present in the local OBD. If a subindex is not present, this function shall not
 be called. If the access to the desired object can not be handled immediately,
 kEplObdAccessAdopted has to be returned.
 *******************************************************************************/
static tEplKernel  EplAppCbDefaultObdAccess(tEplObdParam MEM* pObdParam_p)
{
#ifdef TEST_OBD_ADOPTABLE_FINISHED_TIMERU
tEplTimerArg    TimerArg;
tEplTimerHdl    EplTimerHdl;
#endif // TEST_OBD_ADOPTABLE_FINISHED_TIMERU

tEplObdParam *   pAllocObdParam = NULL; ///< pointer to allocated memory of OBD access handle
BYTE *           pAllocDataBuf;         ///< pointer to object data buffer
tEplKernel       Ret = kEplSuccessful;

    if (pObdParam_p == NULL)
    {
        Ret = kEplInvalidParam;
    }

    if (pObdParam_p->m_pRemoteAddress != NULL)
    {   // remote access via SDO
        //printf("Remote OBD access from %d\n", pObdParam_p->m_pRemoteAddress->m_uiNodeId);
    }

    // TODO: forward all application objects to AP (>=0x2000)
    // return error for all non existing objects
    switch (pObdParam_p->m_uiIndex)
    {
        case 0x1010:
        {
            switch (pObdParam_p->m_uiSubIndex)
            {
                case 0x01:
                {
                    break;
                }

                default:
                {
                    // printf("Sub-index does not exist!\n");
                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_SUB_INDEX_NOT_EXIST;
                    Ret = kEplObdSubindexNotExist;
                    goto Exit;
                }
            }

            break;
        }

//        case 0x1011:
//        {
//            switch (pObdParam_p->m_uiSubIndex)
//            {
//                case 0x01:
//                {
//                    break;
//                }
//
//                default:
//                {
//                    // printf("Sub-index does not exist!\n");
//                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_SUB_INDEX_NOT_EXIST;
//                    Ret = kEplObdSubindexNotExist;
//                    goto Exit;
//                }
//            }
//
//            break;
//        }

        case 0x1F50:
        {
            switch (pObdParam_p->m_uiSubIndex)
            {
                case 0x01:
                case 0x02:
                {
                    break;
                }

                default:
                {
                    // printf("Sub-index does not exist!\n");
                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_SUB_INDEX_NOT_EXIST;
                    Ret = kEplObdSubindexNotExist;
                    goto Exit;
                }
            }

            break;
        }

        case 0x6500:
        {
            switch (pObdParam_p->m_uiSubIndex)
            {
                case 0x01:
                {
                    break;
                }

                default:
                {
                    // printf("Sub-index does not exist!\n");
                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_SUB_INDEX_NOT_EXIST;
                    Ret = kEplObdSubindexNotExist;
                    goto Exit;
                }
            }

            break;
        }

        default:
        {
            // printf("Object does not exist!\n");
            pObdParam_p->m_dwAbortCode = EPL_SDOAC_OBJECT_NOT_EXIST;
            Ret = kEplObdIndexNotExist;
            goto Exit;
        }
        break;
    }

    printf("EplAppCbDefaultObdAccess(0x%04X/%u Ev=%X pData=%p Off=%u Size=%u"
           " ObjSize=%u TransSize=%u Acc=%X Typ=%X)\n",
        pObdParam_p->m_uiIndex, pObdParam_p->m_uiSubIndex,
        pObdParam_p->m_ObdEvent,
        pObdParam_p->m_pData, pObdParam_p->m_SegmentOffset, pObdParam_p->m_SegmentSize,
        pObdParam_p->m_ObjSize, pObdParam_p->m_TransferSize, pObdParam_p->m_Access, pObdParam_p->m_Type);

    switch (pObdParam_p->m_ObdEvent)
    {
        case kEplObdEvCheckExist:
        {
            // Do not return "kEplObdAccessAdopted" - not allowed in this case!

            // assign data type
            //TODO: check maximum segment offset
            //TODO: check object size
            switch (pObdParam_p->m_uiIndex)
            {
                case 0x1010:
                //case 0x1011:
                case 0x6500: //TODO: delete this test object
                {
                    pObdParam_p->m_Type = kEplObdTypUInt32;

                    break;
                }

                case 0x1F50:
                {
                    pObdParam_p->m_Type = kEplObdTypDomain;

                    break;
                }

                default:
                break;
            }

            goto Exit;
        } // end case kEplObdEvCheckExist

        case kEplObdEvInitWriteLe:
        { // do not return kEplSuccessful in this case,
          // only error or kEplObdAccessAdopted is allowed!

          // TODO: Systec Doku: "The pointer m_pData is only valid within the function call.
          // The caller of m_pfnAccessFinished has to provide an own
          // buffer." -> Do I really need to allocate a buffer for Default OBD (write) access ?

          // TODO: block all transfers of same index/subindex which are already processing

            if (pObdParam_p->m_pRemoteAddress != NULL)
            {   // remote access via SDO

                // TODO: if it is a read only object -> refuse SDO access
                //Ret = kEplObdWriteViolation;
                //ObdParam_p->m_dwAbortCode = EPL_SDOAC_WRITE_TO_READ_ONLY_OBJ;
                //goto Exit;
                //TODO: else

            }
            else
            {   // caller is local -> write access to read only object is fine

                //TODO: callback function for local access has to be assigned by caller
            }

            // TODO:
            // Question: Sequence Layer Ack will be sent after first received "init" segment?
            // A: no, Client will send Ack Request after sending history block
            // Note: Only a "history segment block" can be delayed, but not single segments!

            if (pObdParam_p->m_pfnAccessFinished == NULL)
            {
                pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
                Ret = kEplObdAccessViolation;
                goto Exit;
            }

            // check if empty handles are available
            if (ApiPdiComInstance_g != NULL)
            {
                Ret = kEplObdOutOfMemory;
                pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
                goto Exit;
            }

            // allocate memory for handle
            // TODO: introduce counter to recognize memory leaks / to much allocated memory
            // or use static storage
            pAllocObdParam = EPL_MALLOC(sizeof (*pAllocObdParam));
            if (pAllocObdParam == NULL)
            {
                Ret = kEplObdOutOfMemory;
                pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
                goto Exit;
            }

            EPL_MEMCPY(pAllocObdParam, pObdParam_p, sizeof (*pAllocObdParam));

            // save handle for callback function
            ApiPdiComInstance_g = pAllocObdParam;

            // forward "pAllocObdParam" which has to be returned in callback,
            // so callback can access the Obd-access handle and SDO communication handle
            if (pObdParam_p->m_Type == kEplObdTypDomain)
            {
                // if it is an initial segment, check if this object is already accessed;
                // m_pHandle is assumed to be an SDO handle //TODO: extend this function for other callers than SDO

                if (pObdParam_p->m_SegmentOffset == 0)
                {   // inital segment

                    // history has to be completely empty for new segmented write transfer
                    // only one segmented transfer at once is allowed!
                    if (bObdSegWriteAccHistoryEmptyCnt_g < OBD_DEFAULT_SEG_WRITE_SIZE)
                    {
                        Ret = kEplObdOutOfMemory;
                        pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
                        EPL_FREE(pAllocObdParam);
                        goto Exit;
                    }

                    // Cleanup history TODO: put to more senseful places
                    Ret = EplAppDefObdAccCleanupHistory();
                    if (Ret != kEplSuccessful)
                    {
                        goto Exit;
                    }
                }

                // save object data
                pAllocDataBuf = EPL_MALLOC(pObdParam_p->m_SegmentSize);
                if (pAllocDataBuf == NULL)
                {
                    Ret = kEplObdOutOfMemory;
                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
                    EPL_FREE(pAllocObdParam);
                    goto Exit;
                }

                EPL_MEMCPY(pAllocDataBuf, pObdParam_p->m_pData, pObdParam_p->m_SegmentSize);
                pAllocObdParam->m_pData = (void*) pAllocDataBuf;

                // save OBD access handle for Domain objects (segmented access)
                printf("SDO History Empty Cnt: %d\n", bObdSegWriteAccHistoryEmptyCnt_g);
                Ret = EplAppDefObdAccSaveHdl(pAllocObdParam);
                printf("SDO History Empty Cnt: %d\n", bObdSegWriteAccHistoryEmptyCnt_g);
                if (Ret != kEplSuccessful)
                {
                    EPL_FREE(pAllocObdParam);
                    goto Exit;
                }

                // trigger write to all domain objects (using segmented transfers)
                switch (pObdParam_p->m_uiIndex)
                {
                    case 0x1F50:
                    {
                        // trigger write operation (in AppEventCb)
                        Ret = EplApiPostUserEvent((void*) pAllocObdParam);
                        if (Ret != kEplSuccessful)
                        {
                            goto Exit;
                        }

                        break;
                    }

                    default:
                    {
                        pObdParam_p->m_dwAbortCode = EPL_SDOAC_OBJECT_NOT_EXIST;
                        Ret = kEplObdIndexNotExist;
                        goto Exit;
                    }
                    break;
                }
            }
            else // non domain objects
            {

#ifdef TEST_OBD_ADOPTABLE_FINISHED_TIMERU
            EplAppDumpData(pObdParam_p->m_pData, pObdParam_p->m_SegmentSize);
#endif // TEST_OBD_ADOPTABLE_FINISHED_TIMERU

            // forward SDO transfers of application specific objects to AP
            if (pObdParam_p->m_pRemoteAddress != NULL)
            {   // remote access via SDO

                //if (pObdParam_p->m_uiIndex >= 0x2000)
                if(1)
                {
                    tPdiAsyncStatus PdiRet = kPdiAsyncStatusSuccessful;
                    tObjAccSdoComCon PdiObjAccCon;

                    PdiObjAccCon.m_wSdoSeqConHdl = 0xFF;///< SDO command layer connection handle number
                    PdiObjAccCon.m_pSdoCmdFrame = pObdParam_p->m_pRemoteAddress->m_le_pSdoCmdFrame; ///< assign to SDO command frame
                    PdiObjAccCon.m_uiSizeOfFrame = offsetof(tEplAsySdoComFrm , m_le_abCommandData) + pObdParam_p->m_pRemoteAddress->m_le_pSdoCmdFrame->m_le_wSegmentSize;  ///< size of SDO command frame

                    PdiRet = CnApiAsync_postMsg(
                                    kPdiAsyncMsgIntObjAccReq,
                                    (BYTE *) &PdiObjAccCon,
                                    0,
                                    0);

                    if (PdiRet == kPdiAsyncStatusRetry)
                    {
                        Ret = kEplSdoSeqConnectionBusy;
                        pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_DUE_LOCAL_CONTROL;
                        goto Exit;
                    }
                    else if (PdiRet != kPdiAsyncStatusSuccessful)
                    {
                        pObdParam_p->m_dwAbortCode = EPL_SDOAC_GENERAL_ERROR;
                        Ret = kEplInvalidOperation;
                        goto Exit;
                    }
                }
            } // end if (pObdParam_p->m_pRemoteAddress != NULL)

#if 0
//#ifdef TEST_OBD_ADOPTABLE_FINISHED_TIMERU
            TimerArg.m_EventSink = kEplEventSinkApi;
            TimerArg.m_Arg.m_pVal = pAllocObdParam;

            Ret = EplTimeruSetTimerMs(&EplTimerHdl,
                                        6000, //Timer availability is very fragile -> do other tests
                                        TimerArg);
            if(Ret != kEplSuccessful)
            {
                pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_DUE_LOCAL_CONTROL;
                EPL_FREE(pAllocObdParam);
                goto Exit;
            }
#endif // TEST_OBD_ADOPTABLE_FINISHED_TIMERU

                // TODO: send message to AP
                // or TODO: search for valid handle and write to target

                // AP returns answer (including address) -> call EplAppCbObdAdoptedAccessFinished:

                // Note: pObdParam_p->m_pHandle is SDO connection handle and has to be returned in pfnAccessFinished to SDO command layer;
            }

            // adopt write access
            Ret = kEplObdAccessAdopted;
            printf(" Adopted\n");
            goto Exit;

        }   // end case kEplObdEvInitWriteLe

        case kEplObdEvPreRead:
        { // do not return kEplSuccessful in this case,
          // only error or kEplObdAccessAdopted or kEplObdSegmentReturned is allowed!

            // Note: kEplObdAccessAdopted can only be returned for expedited (non-fragmented) reads!
            // Adopted access is not yet implemented for segmented kEplObdEvPreRead.
            // Thus, kEplObdSegmentReturned has to be returned in this case! This requires immediate access to
            // the read source data right from this function.

            //TODO: send expedited SDO request to AP + forward handle

            //TODO: set type of transfer according to object size - see EplSdoComServerInitReadByIndex()

            //TODO: block all transfers of same index/subindex which are already processing

            if (pObdParam_p->m_pfnAccessFinished == NULL)
            {
                pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
                Ret = kEplObdAccessViolation;
                goto Exit;
            }

            // check if empty handles are available
            if (ApiPdiComInstance_g != NULL)
            {
                Ret = kEplObdOutOfMemory;
                pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
                goto Exit;
            }

            // allocate memory for handle
            // TODO: introduce counter to recognize memory leaks / to much allocated memory
            // or use static storage
            pAllocObdParam = EPL_MALLOC(sizeof (*pAllocObdParam));
            if (pAllocObdParam == NULL)
            {
                Ret = kEplObdOutOfMemory;
                pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
                goto Exit;
            }

            EPL_MEMCPY(pAllocObdParam, pObdParam_p, sizeof (*pAllocObdParam));

            // save handle for callback function
            ApiPdiComInstance_g = pAllocObdParam;

#ifdef TEST_OBD_ADOPTABLE_FINISHED_TIMERU
            TimerArg.m_EventSink = kEplEventSinkApi;
            TimerArg.m_Arg.m_pVal = pAllocObdParam;

            Ret = EplTimeruSetTimerMs(&EplTimerHdl,
                                        4000, //Timer availability is very fragile -> do other tests
                                        TimerArg);
            if(Ret != kEplSuccessful)
            {
                pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_DUE_LOCAL_CONTROL;
                EPL_FREE(pAllocObdParam);
                goto Exit;
            }
#endif // TEST_OBD_ADOPTABLE_FINISHED_TIMERU

            // adopt read access
            Ret = kEplObdAccessAdopted;
            printf("  Adopted\n");
            goto Exit;

        }   // end case kEplObdEvPreRead

        default:
        break;
    }

Exit:
    return Ret;
}


/**
 ********************************************************************************
 \brief searches for free storage of OBD access handle and saves it

 \param pObdParam_p pointer to OBD handle
 \retval kEplSuccessful if element was successfully assigned
 \retval kEplObdOutOfMemory if no free element is left
 \retval kEplApiInvalidParam if wrong parameter passed to this function
 *******************************************************************************/
static tEplKernel EplAppDefObdAccSaveHdl(tEplObdParam *  pObdParam_p)
{
tEplKernel Ret = kEplSuccessful;
tDefObdAccHdl * pObdDefAccHdl = NULL;
BYTE bArrayNum;                 ///< loop counter and array element

    // check for wrong parameter values
    if (pObdParam_p == NULL)
    {
        Ret = kEplApiInvalidParam;
        goto Exit;
    }

    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_SEG_WRITE_SIZE; bArrayNum++, pObdDefAccHdl++)
    {
        if (pObdDefAccHdl->m_Status == kEplObdDefAccHdlEmpty)
        {
            // free storage found -> assign OBD access handle
            pObdDefAccHdl->m_pObdParam = pObdParam_p;
            pObdDefAccHdl->m_Status = kEplObdDefAccHdlWaitProcessingInit;
            bObdSegWriteAccHistoryEmptyCnt_g--;

            goto Exit;
        }
    }

    // no free storage found if we reach here
    Ret = kEplObdOutOfMemory;
    pObdDefAccHdl->m_pObdParam->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;

Exit:
    return Ret;
}


/**
 ********************************************************************************
 \brief searches for a segmented OBD access handle

 \param wIndex_p        index of searched element
 \param wSubIndex_p     subindex of searched element
 \param pwCntRet_p      OUT: count of found elements with status ReqStatus_p
 \param ReqStatus_p     requested status of handle
 \retval kEplSuccessful      if element was found
 \retval kEplApiInvalidParam if wrong parameter passed to this function

 This function counts the segmented OBD access elements which have the specified
 index and subindex and additionally equal the given status. If index and subindex
 are set to 0, all elements of a certain status will be counted.
 *******************************************************************************/
static tEplKernel EplAppDefObdAccCountHdlStatus(
        WORD wIndex_p,
        WORD wSubIndex_p,
        WORD * pwCntRet_p,
        tEplObdDefAccStatus ReqStatus_p)
{
tEplKernel Ret = kEplSuccessful;
volatile tDefObdAccHdl * pObdDefAccHdl = NULL;
volatile BOOL fCountAllMatchingStatus = FALSE;
volatile BYTE bArrayNum;                             ///< loop counter and array element

    pObdDefAccHdl = (tDefObdAccHdl *) aObdDefAccHdl_l;

    if (pwCntRet_p == NULL)
    {
        Ret = kEplInvalidParam;
        goto Exit;
    }

    //*pwCntRet_p = 0; //initialize counter

    if ((wIndex_p == 0)   &&
        (wSubIndex_p == 0)  )
    {   // count all elements which match the status
        fCountAllMatchingStatus = TRUE;
    }

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_SEG_WRITE_SIZE; )
    {
        // check for wrong parameter values
        if (fCountAllMatchingStatus == TRUE)
        {   // count all elements which match the status

            if (pObdDefAccHdl->m_Status == ReqStatus_p)
            {
                *pwCntRet_p = (WORD) *pwCntRet_p + 1; //nios2-gcc3 can only compile it this way
            }
        }
        else
        {   // count only elements which match index, subindex and status

            if ((pObdDefAccHdl->m_Status == ReqStatus_p)               &&
                (pObdDefAccHdl->m_pObdParam->m_uiIndex == wIndex_p)    &&
                (pObdDefAccHdl->m_pObdParam->m_uiSubIndex == wSubIndex_p))
            {
                *pwCntRet_p = (WORD) *pwCntRet_p + 1; //nios2-gcc3 can only compile it this way
            }
        }

        // prepare next iteration
        bArrayNum++;
        pObdDefAccHdl++;
    }

Exit:
    return Ret;
}


/**
 ********************************************************************************
 \brief searches for a segmented OBD access handle

 \param pObdAccParam_p  pointer of object dictionary access to be searched for;
                        If pObdAccParam_p != 0, index, subindex and status
                        wont't be considered in the search;
 \param wIndex_p        index of searched element
 \param wSubIndex_p     subindex of searched element
 \param ppObdParam_p    IN:  caller provides  target pointer address
                        OUT: address of found element or NULL
 \param ReqStatus_p     requested status of handle
 \retval kEplSuccessful             if element was found
 \retval kEplObdVarEntryNotExist    if no element was found
 \retval kEplApiInvalidParam        if wrong parameter passed to this function

 This function searches for a segmented OBD access handle. Either an index,
 subindex and status will be searched, or a OBD access handle pointer - depending
 on the value of pObdAccParam_p. If pObdAccParam_p = 0, the first case will be
 applied, else the second case.
 *******************************************************************************/
static tEplKernel EplAppDefObdAccGetStatusDependantHdl(
        tEplObdParam * pObdAccParam_p,
        WORD wIndex_p,
        WORD wSubIndex_p,
        tDefObdAccHdl **  ppDefObdAccHdl_p,
        tEplObdDefAccStatus ReqStatus_p)
{
tEplKernel Ret = kEplSuccessful;
tDefObdAccHdl * pObdDefAccHdl = NULL;
BYTE bArrayNum;                 ///< loop counter and array element

    // check for wrong parameter values
    if (ppDefObdAccHdl_p == NULL)
    {
        Ret = kEplApiInvalidParam;
        goto Exit;
    }

    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_SEG_WRITE_SIZE; bArrayNum++, pObdDefAccHdl++)
    {
        if (pObdAccParam_p == 0)
        {
            if (wIndex_p == pObdDefAccHdl->m_pObdParam->m_uiIndex        &&
                wSubIndex_p == pObdDefAccHdl->m_pObdParam->m_uiSubIndex  &&
                pObdDefAccHdl->m_Status == ReqStatus_p)
            {
                // handle ready for processing found
                *ppDefObdAccHdl_p = pObdDefAccHdl;
                goto Exit;
            }
        }
        else
        {
            if (pObdAccParam_p == pObdDefAccHdl->m_pObdParam)
            {
                // assigned handle found
                 *ppDefObdAccHdl_p = pObdDefAccHdl;
                 goto Exit;
            }
        }

    }

    // no handle found
    *ppDefObdAccHdl_p = NULL;
    Ret = kEplObdVarEntryNotExist;

Exit:
    return Ret;
}


/**
 ********************************************************************************
 \brief write to an object which does not exist in the local object dictionary
        by using segmented access (to domain object)

 \param pDefObdAccHdl_p pointer to default OBD access for segmented access
 \retval tEplKernel value
 *******************************************************************************/
static tEplKernel EplAppDefObdAccWriteObdSegmented(tDefObdAccHdl *  pDefObdAccHdl_p)
{
tEplKernel Ret = kEplSuccessful;
BOOL fRet = TRUE;

    if (pDefObdAccHdl_p == NULL)
    {
        Ret = kEplApiInvalidParam;
        goto Exit;
    }

    pDefObdAccHdl_p->m_Status = kEplObdDefAccHdlInUse;

    switch (pDefObdAccHdl_p->m_pObdParam->m_uiIndex)
    {
        case 0x1F50:
        {
            switch (pDefObdAccHdl_p->m_pObdParam->m_uiSubIndex)
            {
                case 0x01:
                {
                    //TODO: use correct function for this object
                    fRet = FpgaCfg_writeFlashSafely(
                           &pDefObdAccHdl_p->m_pObdParam->m_SegmentOffset,
                           &pDefObdAccHdl_p->m_pObdParam->m_SegmentSize,
                           (void*) pDefObdAccHdl_p->m_pObdParam->m_pData);

//                    usleep(1000000); //TODO: delete this test delay
//                    fRet = TRUE;    //TODO: delete this line

                    if (fRet != TRUE)
                    {   //write operation went wrong
                        Ret = kEplObdAccessViolation;
                        goto Exit;
                    }
                }
                case 0x02:
                {
                    //TODO: use correct function for this object
                    break;
                }

                default:
                {
                    Ret = kEplObdSubindexNotExist;
                    goto Exit;
                }
            }

            break;
        }

        default:
        break;
    }

    // mark handle as processed
    pDefObdAccHdl_p->m_Status = kEplObdDefAccHdlProcessingFinished;

Exit:
    if (Ret != kEplSuccessful)
    {   // overwrite handle status
        pDefObdAccHdl_p->m_Status = kEplObdDefAccHdlError;
    }

    return Ret;
}


static tEplKernel EplAppCbSdoConnectionSourcePdiFinished(tEplSdoComFinished*  pSdoComFinished_p)
{
tEplKernel Ret;

    Ret = kEplSuccessful;

    if (pSdoComFinished_p->m_SdoAccessType == kEplSdoAccessTypeRead)
    {
        printf("SDO read of object ");
    }
    else
    {
        printf("SDO write of object ");
    }
    printf("0x%04X/0x%02X finished %u bytes transferred\n(Abortcode: 0x%04x Handle: 0x%x State: %s)\n",
        pSdoComFinished_p->m_uiTargetIndex,
        pSdoComFinished_p->m_uiTargetSubIndex,
        pSdoComFinished_p->m_uiTransferredByte,
        pSdoComFinished_p->m_dwAbortCode,
        pSdoComFinished_p->m_SdoComConHdl,
        aszSdoStates_l[pSdoComFinished_p->m_SdoComConState]);

    switch (pSdoComFinished_p->m_uiTransferredByte)
    {
        case 0:
            printf("no Bytes transfered\n");
            break;

        case 1:
            printf("BYTE: 0x%02X\n", (WORD)AmiGetByteFromLe(pSdoComFinished_p->m_pUserArg));
            break;

        case 2:
            printf("WORD: 0x%04X\n", AmiGetWordFromLe(pSdoComFinished_p->m_pUserArg));
            break;

        case 3:
            printf("3 BYTEs: 0x%06X\n", AmiGetDword24FromLe(pSdoComFinished_p->m_pUserArg));
            break;

        case 4:
            printf("DWORD: 0x%08X\n", AmiGetDwordFromLe(pSdoComFinished_p->m_pUserArg));
            break;

        default:
            EplAppDumpData(pSdoComFinished_p->m_pUserArg, min (pSdoComFinished_p->m_uiTransferredByte, 256));
            break;
    }

    if((pSdoComFinished_p->m_dwAbortCode != 0)
        ||(pSdoComFinished_p->m_SdoComConState != kEplSdoComTransferFinished))
    {
        fSdoSuccessful_l = FALSE;
    }
    else
    {
        fSdoSuccessful_l = TRUE;
    }

    // close connection
    Ret = EplSdoComUndefineCon(SdoComConHdl_l); //TODO: Do this in Cb function??
    if(Ret != kEplSuccessful)
    {
        printf("Close of SDO via UDP Connection failed: 0x%03X\n", Ret);
    }

    // set event
    // SetEvent(SdoReadyHdl_l);


return Ret;

}

//---------------------------------------------------------------------------
//
// Function:        EplAppDumpData
//
// Description:     function print out data in hexadecimal value
//
//
//
// Parameters:      pData_p         = pointer to data
//                  ulDataSize_p    = size of data in byte
//
//
// Returns:         void
//
//
// State:
//
//---------------------------------------------------------------------------
#if(((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDOC)) != 0)
void EplAppDumpData(void* pData_p, unsigned long ulDataSize_p)
{
unsigned long   ulCount;
unsigned long   ulOffset;
BYTE*           pbData;
char            szBuffer[17];

    if (pData_p == NULL)
    {
        printf("Null pointer!\n");
        return;
    }

    szBuffer[16] = '\0';

    pbData = (BYTE*)pData_p;

    ulCount = 0;
    ulOffset = 0;
    // printout data
    while (ulCount < ulDataSize_p)
    {
        printf(" %02X", (WORD)*pbData);
        if (isgraph(*pbData))
        {
            szBuffer[ulOffset] = *pbData;
        }
        else
        {
            szBuffer[ulOffset] = '.';
        }
        pbData++;
        ulCount++;
        ulOffset++;
        if (ulOffset == 16)
        {
            printf("  %s\n", szBuffer);
            ulOffset = 0;
        }
    }

    if (ulOffset != 0)
    {
        szBuffer[ulOffset] = '\0';
        for (; ulOffset < 16; ulOffset++)
        {
            printf("   ");
        }
        printf("  %s\n", szBuffer);
    }
    else
    {
        printf("\n");
    }
}
#endif

/* EOF */
/*********************************************************************************/
