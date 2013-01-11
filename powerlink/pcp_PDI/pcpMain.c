/**
********************************************************************************
\file        pcpMain.c

\brief       main module of powerlink stack for PCP, supporting an external SW API

\author      Josef Baumgartner

\date        06.04.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

*******************************************************************************/

/******************************************************************************/
/* includes */
#include "pcp.h"
#include "pcpStateMachine.h"
#include "pcpEvent.h"
#include "pcpSync.h"
#include "pcpPdo.h"
#include "pcpAsyncSm.h"
#include <pcpObjects.h>
#include <pcpCtrlReg.h>


#ifdef VETH_DRV_EN
  #include "pcpAsyncVeth.h"
#endif //VETH_DRV_EN

#include "fpgaCfg.h"
#include "fwUpdate.h"
#include "fwBoot.h"

#include "systemComponents.h"

/******************************************************************************/

#include "Epl.h"
#include "EplPdou.h"
#include "EplSdoComu.h"
#include "EplNmt.h"
#include "user/EplNmtu.h"

#include "EplSdo.h"
#include "EplAmi.h"
#include "EplObd.h"
#include "EplTimeru.h"
#include <EplObduDefAcc.h>
#include <EplObduDefAccHstry.h>


//---------------------------------------------------------------------------
// defines
//---------------------------------------------------------------------------
/* Powerlink defaults */
#define DEFAULT_CYCLE_LEN   1000    ///< [us]

//---------------------------------------------------------------------------
// module global vars
//---------------------------------------------------------------------------
static tPcpInitParam    InitParam_l = {{0}};       ///< POWERLINK initialization parameter
static BOOL             fIsUserImage_g;            ///< if set user image is booted
static UINT32           uiFpgaConfigVersion_g = 0; ///< version of currently used FPGA configuration
static BOOL             fOperational = FALSE;      ///< POWERLINK is operational
static BOOL             fShutdown_l = FALSE;       ///< POWERLINK shutdown flag

/******************************************************************************/


/******************************************************************************/
// This function is the entry point for your object dictionary. It is defined
// in OBJDICT.C by define EPL_OBD_INIT_RAM_NAME. Use this function name to define
// this function prototype here. If you want to use more than one Epl
// instances then the function name of each object dictionary has to differ.
tEplKernel PUBLIC  EplObdInitRam (tEplObdInitParam MEM* pInitParam_p);

/******************************************************************************/
/* forward declarations */
#if EPL_DLL_SOCTIME_FORWARD != FALSE
    tEplKernel PUBLIC AppCbSync(tEplSocTimeStamp SocTimeStamp_p) INT_RAM_MAIN_01_APP_CB_SYNC;
#else
    tEplKernel PUBLIC AppCbSync(void);
#endif

tEplKernel PUBLIC AppCbEvent(tEplApiEventType EventType_p,
                             tEplApiEventArg* pEventArg_p,
                             void GENERIC*pUserArg_p);
static int EplAppHandleUserEvent(tEplApiEventArg* pEventArg_p);

static void rebootCN(void);

static void processPowerlink(void);
static tEplKernel initPowerlink(void);
static int startPowerlink(void);
static void switchoffPowerlink(void);
static void enterPreOpPowerlink(void);
static void enterReadyToOperatePowerlink(void);
static void enterOperationalPowerlink(void);
static int Gi_init(tInitStateMachine * pStateMachineInit_p, tPcpInitParam * pInitParam_p);
static void Gi_shutdown(void);

/**
********************************************************************************
\brief    get string of NMT state
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
\brief    main function of generic POWERLINK CN interface
*******************************************************************************/
int main (void)
{
    tInitStateMachine StateMachineInit = {0};

    SysComp_initPeripheral();

    fIsUserImage_g = FpgaCfg_processReconfigStatusIsUserImage(FpgaCfg_handleReconfig());

    DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "\n\nGeneric POWERLINK CN interface - this is PCP starting in main()\n\n");

    /***** initializations *****/
    DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Initializing...\n");

    // setup PCP state machine init parameters
    StateMachineInit.m_fpInitPlk = initPowerlink;
    StateMachineInit.m_fpStartPlk = startPowerlink;
    StateMachineInit.m_fpShutdownPlk = switchoffPowerlink;
    StateMachineInit.m_fpRdyToOpPlk = enterReadyToOperatePowerlink;
    StateMachineInit.m_fpPreOpPlk = enterPreOpPowerlink;
    StateMachineInit.m_fpOperationalPlk = enterOperationalPowerlink;
    if (Gi_init(&StateMachineInit, &InitParam_l) != OK)
    {
        goto exit;
    }

    DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "OK\n");

#ifdef STATUS_LEDS_BASE
    SysComp_setPowerlinkStatus(0xff);
#endif

    processPowerlink();

    return OK;
exit:
    return ERROR;
}

/**
********************************************************************************
\brief    reboot the CN

This function reboots the CN. It checks if the FPGA configuration of the running
firmware and the user image is different. If it is the same version it only
performs a PCP software reset. If it is differnt it triggers a complete
FPGA reconfiguration.
*******************************************************************************/
void rebootCN(void)
{
    BOOL fIsUserImage = TRUE;
    BOOL fIibReadable = FALSE;
    tfwBootInfo fwBootIibInfo = {0};

    /* read FPGA configuration version of user image */
    fIibReadable = fwBoot_tryGetIibInfo(fIsUserImage, &fwBootIibInfo);

    // inform AP about reset event - at this special event, do blocking wait
    // until AP has confirmed the reception.
    Gi_pcpEventPost(kPcpPdiEventGeneric, kPcpGenEventResetNodeRequest);

    /* if the FPGA configuration version changed since boot-up, we have to do
     * a complete FPGA reconfiguration. */
    if ((fwBootIibInfo.uiFpgaConfigVersion != uiFpgaConfigVersion_g)
         && fIibReadable                                            )
    {
        DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "FPGA Configuration of CN ...\n");
        //USLEEP(4000000);

        // trigger FPGA reconfiguration
        // remark: if we are in user image, this command will trigger a
        //         reconfiguration of the factory image regardless of its argument!
        FpgaCfg_reloadFromFlash(CONFIG_FACTORY_IMAGE_FLASH_ADRS); // restart factory image
    }
    else
    {   // only reload the PCP software
        // NOTE: SW has to match FPGA configuration, thus a software only
        // update is not useful and does not need to be handled at the moment.
        //USLEEP(4000000);
    }
}

/**
********************************************************************************
\brief    initialize openPOWERLINK stack

This function is called by the PCP state machine when the init state is
reached! It initializes the openPOWERLINK stack.

\return   tEplKernel
\retval   kEplSuccessful        on success
*******************************************************************************/
static tEplKernel initPowerlink(void)
{
    static tEplApiInitParam     EplApiInitParam;   // epl init parameter
    tEplKernel                  EplRet;
    tfwBootInfo fwBootIibInfo = {0};

#ifdef CONFIG_USE_SDC_OBJECTS
    WORD wSyncIntCycle;
#endif  //CONFIG_USE_SDC_OBJECTS

    /* check if NodeID has been set to 0x00 by AP -> use node switches */
#ifdef NODE_SWITCH_BASE
    if(InitParam_l.m_bNodeId == 0x00)
    {   /* read port configuration input pins and overwrite parameter */
        InitParam_l.m_bNodeId = SysComp_getNodeId();
    }
#else
    if(pInitParm_p->m_bNodeId == 0x00)
    {
        /* There is no node switch pio and AP wants hardware support so gen error */
        EplRet = kEplNoResource;
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: There are no hardware node switch modules present on the PCP!\n");
        goto Exit;
    }
#endif /* SET_NODE_ID_BY_HW */

    if(fwBoot_tryGetIibInfo(fIsUserImage_g, &fwBootIibInfo) != FALSE)
    {
        uiFpgaConfigVersion_g = fwBootIibInfo.uiFpgaConfigVersion;
    }

    /* setup the POWERLINK stack */
    /* calc the IP address with the nodeid */
    InitParam_l.m_dwIpAddress &= 0xFFFFFF00;                          ///< dump the last byte
    InitParam_l.m_dwIpAddress |= InitParam_l.m_bNodeId;              ///< and mask it with the node id

    /* set EPL init parameters */
    EplApiInitParam.m_uiSizeOfStruct = sizeof (EplApiInitParam);
    EPL_MEMCPY(EplApiInitParam.m_abMacAddress, InitParam_l.m_abMac,
               sizeof(EplApiInitParam.m_abMacAddress));
    EplApiInitParam.m_uiNodeId = InitParam_l.m_bNodeId;
    EplApiInitParam.m_dwIpAddress = InitParam_l.m_dwIpAddress;
    EplApiInitParam.m_uiIsochrTxMaxPayload = CONFIG_ISOCHR_TX_MAX_PAYLOAD;
    EplApiInitParam.m_uiIsochrRxMaxPayload = CONFIG_ISOCHR_RX_MAX_PAYLOAD;
    EplApiInitParam.m_dwPresMaxLatency = 2000; // ns
    EplApiInitParam.m_dwAsndMaxLatency = 2000; // ns
    EplApiInitParam.m_fAsyncOnly = FALSE;
    EplApiInitParam.m_dwFeatureFlags = -1;       // depends on openPOWERLINK module integration
    EplApiInitParam.m_dwCycleLen = DEFAULT_CYCLE_LEN;
    EplApiInitParam.m_uiPreqActPayloadLimit = 36;
    EplApiInitParam.m_uiPresActPayloadLimit = 36;
    EplApiInitParam.m_uiMultiplCycleCnt = 0;
    EplApiInitParam.m_uiAsyncMtu = InitParam_l.m_wMtu;
    EplApiInitParam.m_uiPrescaler = 2;
    EplApiInitParam.m_dwLossOfFrameTolerance = 5000000;
    EplApiInitParam.m_dwAsyncSlotTimeout = 3000000;
    EplApiInitParam.m_dwWaitSocPreq = 0;
    EplApiInitParam.m_dwDeviceType = InitParam_l.m_dwDeviceType;
    EplApiInitParam.m_dwVendorId = InitParam_l.m_dwVendorId;
    EplApiInitParam.m_dwProductCode = InitParam_l.m_dwProductCode;
    EplApiInitParam.m_dwRevisionNumber = InitParam_l.m_dwRevision;
    EplApiInitParam.m_dwSerialNumber = InitParam_l.m_dwSerialNum;
    //EplApiInitParam.m_dwVerifyConfigurationDate;
    //EplApiInitParam.m_dwVerifyConfigurationTime;
    EplApiInitParam.m_dwApplicationSwDate = fwBootIibInfo.uiApplicationSwDate;
    EplApiInitParam.m_dwApplicationSwTime = fwBootIibInfo.uiApplicationSwTime;
    EplApiInitParam.m_dwSubnetMask = InitParam_l.m_dwSubNetMask;
    EplApiInitParam.m_dwDefaultGateway = InitParam_l.m_dwDefaultGateway;
    EplApiInitParam.m_pszDevName = InitParam_l.m_strDevName;
    EplApiInitParam.m_pszHwVersion = InitParam_l.m_strHwVersion;
    EplApiInitParam.m_pszSwVersion = InitParam_l.m_strSwVersion;
    EplApiInitParam.m_pfnCbEvent = AppCbEvent;
    EplApiInitParam.m_pfnCbSync  = AppCbSync;
    EplApiInitParam.m_pfnCbTpdoPreCopy = Gi_preparePdiPdoReadAccess;    // PDI buffer treatment
    EplApiInitParam.m_pfnCbRpdoPostCopy = Gi_signalPdiPdoWriteAccess;   // PDI buffer treatment
    EplApiInitParam.m_pfnObdInitRam = EplObdInitRam;
    EplApiInitParam.m_pfnDefaultObdCallback = EplAppCbDefaultObdAccess; // called if objects do not exist in local OBD
    EplApiInitParam.m_pfnRebootCb = rebootCN;
    EplApiInitParam.m_pfnPdouCbConfigPdi = Gi_checkandConfigurePdoPdi;
    EPL_MEMCPY(EplApiInitParam.m_sHostname, InitParam_l.m_strHostname,
               sizeof(EplApiInitParam.m_sHostname));

    EplApiInitParam.m_dwSyncResLatency = EPL_C_DLL_T_IFG;

    DEBUG_TRACE1(DEBUG_LVL_09, "INFO: NODE ID is set to 0x%02x\n", EplApiInitParam.m_uiNodeId);
    pcpPdi_setNodeIdInfo(EplApiInitParam.m_uiNodeId);

    /* initialize firmware update */
    initFirmwareUpdate(InitParam_l.m_dwProductCode, InitParam_l.m_dwRevision);

    /* initialize POWERLINK stack */
    DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "init POWERLINK stack API...\n");
    EplRet = EplApiInitialize(&EplApiInitParam);
    if(EplRet != kEplSuccessful)
    {
        goto Exit;
    }

    // link object variables used by CN to object dictionary (if needed)
#ifdef CONFIG_USE_SDC_OBJECTS
    // SDC object "SDC_IOPrescaler"
    // remark: wSyncIntCycle will be calculated right after EnableReadyToOperate command from MN
    wSyncIntCycle = Gi_getSyncIntCycle();

    ObdSize = sizeof(wSyncIntCycle);
    uiVarEntries = 1;
    EplRet = EplApiLinkObject(0x5020, &wSyncIntCycle, &uiVarEntries, &ObdSize, 0x02);
    if (EplRet != kEplSuccessful)
    {
        goto Exit;
    }
#endif // CONFIG_USE_SDC_OBJECTS

Exit:
    return EplRet;
}

/**
********************************************************************************
\brief    start the POWERLINK stack

\return   int
\retval   OK         on success
\retval   ERROR      when start of powerlink failed
*******************************************************************************/
static int startPowerlink(void)
{
    tEplKernel                 EplRet;

    // start the POWERLINK stack
    DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "start POWERLINK stack...\n");
    EplRet = EplApiExecNmtCommand(kEplNmtEventSwReset);
    if (EplRet != kEplSuccessful)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "... error\n\n");
        return ERROR;
    }
    else
    {
        DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "... ok!\n\n");
        return OK;
    }
}

/**
********************************************************************************
\brief    process POWERLINK
*******************************************************************************/
static void processPowerlink(void)
{
    SysComp_enableInterrupts();

    while (Gi_stateMachineIsRunning())
    {
        /* process Powerlink and its API */
        CnApi_processAsyncStateMachine(); //TODO: Process in User-Callback Event!

        if (Gi_getPlkInitStatus())
        {
            EplApiProcess();

#ifdef VETH_DRV_EN
            if(Gi_processVeth() == kCnApiStatusError)
            {
                DEBUG_TRACE1(DEBUG_LVL_ERROR,"ERROR: (%s) Unable "
                        "to post virtual ethernet message to async buffer!\n", __func__);
            }
#endif
        }

        Gi_updateStateMachine();
        updateFirmwarePeriodic();               // periodically call firmware update state machine
        Gi_processEvents();

        if (fShutdown_l != FALSE)
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
\brief    switch off POWERLINK stack
*******************************************************************************/
static void switchoffPowerlink(void)
{
    tEplKernel Ret;

    DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "SwitchOff POWERLINK stack... \n");
    // shutdown and cleanup POWERLINK
    Ret = EplNmtuNmtEvent(kEplNmtEventSwitchOff);
    if(Ret != kEplSuccessful)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "... error!\n\n");
        //TODO react on error (shutdown?)
        return;
    }

    DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "... ok!\n\n");
    return;
}

/**
********************************************************************************
\brief    POWERLINK enter pre-operational 2
*******************************************************************************/
static void enterPreOpPowerlink(void)
{
    tEplKernel Ret;

    Ret = EplNmtuNmtEvent(kEplNmtEventEnterPreOperational2); // trigger NMT state change
    if(Ret != kEplSuccessful)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: Post enter PreOp2 to stack failed!\n");
        //TODO react on error (shutdown?)
    }
}

/**
********************************************************************************
\brief    POWERLINK enter ready to operate
*******************************************************************************/
static void enterReadyToOperatePowerlink(void)
{
    tEplKernel Ret;

    Ret = EplNmtuNmtEvent(kEplNmtEventEnterReadyToOperate); // trigger NMT state change
    if(Ret != kEplSuccessful)
    {
        DEBUG_TRACE0(DEBUG_LVL_ERROR, "ERROR: Post enter ReadyToOperate "
                "to stack failed!\n");
        //TODO react on error (shutdown?)
    }
}

/**
********************************************************************************
\brief    POWERLINK enter operational
*******************************************************************************/
static void enterOperationalPowerlink(void)
{
    pcpSync_enableInterruptIfConfigured();
}

/**
********************************************************************************
\brief    event callback function called by EPL API layer

AppCbEvent() is the event callback function called by EPL API layer within
the user part (low priority).


\param    EventType_p             event type (IN)
\param    pEventArg_p             pointer to union, which describes the event in
                                detail (IN)
\param    pUserArg_p              user specific argument

\return error code (tEplKernel)
\retval    kEplSuccessful   no error
\retval    kEplReject       reject further processing
\retval    otherwise        post error event to API layer
*******************************************************************************/
tEplKernel PUBLIC AppCbEvent(tEplApiEventType EventType_p,
                             tEplApiEventArg* pEventArg_p,
                             void GENERIC* pUserArg_p)
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

            //Gi_pcpEventPost(kPcpPdiEventNmtStateChange, pEventArg_p->m_NmtStateChange.m_NewNmtState);

            if (pEventArg_p->m_NmtStateChange.m_NewNmtState != kEplNmtCsOperational)
            {
                fOperational = FALSE;
                Gi_disableSyncInt();
            }

            switch (pEventArg_p->m_NmtStateChange.m_NewNmtState)
            {
                case kEplNmtGsOff:
                {   // NMT state machine was shut down,
                    // because of critical EPL stack error
                    // -> also shut down EplApiProcess() and main()
                    Gi_setPowerlinkEvent(kPowerlinkEventShutdown);
                    EplRet = kEplShutdown;
                    break;
                }

                case kEplNmtCsPreOperational1:
                {
                    /* Reset RelativeTime state machine to init state */
                    Gi_resetTimeValues();
                }
                case kEplNmtCsStopped:
                {
                    Gi_setPowerlinkEvent(kPowerlinkEventEnterPreOp);

                    break;
                }

                case kEplNmtCsPreOperational2:
                {

                    Gi_setPowerlinkEvent(kPowerlinkEventEnterPreOp);

                    EplRet = kEplReject; // prevent automatic change to kEplNmtCsReadyToOperate
                    break;
                }

                case kEplNmtCsReadyToOperate:
                {
                    break;
                }

                case kEplNmtGsResetConfiguration:
                case kEplNmtGsInitialising:
                case kEplNmtGsResetApplication:
                {
                    // synchronize API state
                    if (getPcpState() > kPcpStatePreOp)
                    {
                        // fall back to PCP_PREOP (API-STATE)
                        Gi_setPowerlinkEvent(kPowerlinkEventEnterPreOp);
                    }
                    break;
                }

                case kEplNmtCsBasicEthernet:                        ///< this state is only indicated  by Led
                {
                    break;
                }

                case kEplNmtGsResetCommunication:
                {
                    int iRet;
                    BYTE    bNodeId = 0xF0;
                    DWORD   dwNodeAssignment = EPL_NODEASSIGN_NODE_EXISTS;

                    EplRet = EplApiWriteLocalObject(0x1F81, bNodeId, &dwNodeAssignment, sizeof (dwNodeAssignment));
                    if (EplRet != kEplSuccessful)
                    {
                        goto Exit;
                    }

                    // reset flow control manipulation
                    EplSdoAsySeqAppFlowControl(FALSE, FALSE);

                    EplAppDefObdAccAdoptedHstryCleanup();
                    Gi_deleteObdAccHstryToPdiConnection();

#ifdef VETH_DRV_EN
                    Gi_resetVeth();
#endif //VETH_DRV_EN

                    // reset asynchronous PCP <-> AP communication
                    iRet = CnApiAsync_reset();
                    if (iRet != OK )
                    {
                        DEBUG_TRACE0(DEBUG_LVL_09, "CnApiAsync_reset() FAILED!\n");
                        EplRet = kEplApiInvalidParam;
                        goto Exit;
                    }

                    // synchronize API state
                    if (getPcpState() > kPcpStatePreOp)
                    {
                        // fall back to PCP_PREOP (API-STATE)
                        Gi_setPowerlinkEvent(kPowerlinkEventEnterPreOp);
                    }

                    break;
                }

                case kEplNmtCsNotActive:                        ///< indicated only by Led, AP is not informed
                    break;

                case kEplNmtCsOperational:
                    fOperational = TRUE;

                    Gi_setPowerlinkEvent(kPowerlinkEventEnterOperational);

                    break;

                default:
                {
                    break;
                }
            }
            break;
        }

        case kEplApiEventCriticalError:
        {
            Gi_controlLED(kEplLedTypeError, TRUE);
            // fall through
        }
        case kEplApiEventWarning:
        {   // error or warning occured within the stack or the application
            // on error the API layer stops the NMT state machine
            DEBUG_TRACE3(DEBUG_LVL_CNAPI_ERR, "%s(Err/Warn): Source=%02X EplError=0x%03X",
                    __func__,
                    pEventArg_p->m_InternalError.m_EventSource,
                    pEventArg_p->m_InternalError.m_EplError);

            Gi_pcpEventPost(kPcpPdiEventCriticalStackError, pEventArg_p->m_InternalError.m_EplError);

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

            //Gi_pcpEventPost(kPcpPdiEventStackLed, pEventArg_p->m_Led.m_LedType);

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
            Gi_pcpEventPost(kPcpPdiEventHistoryEntry, pEventArg_p->m_ErrHistoryEntry.m_wErrorCode);
            break;
        }

        case kEplApiEventBoot:
        {
            switch (pEventArg_p->m_Boot.m_BootEvent)
            {
                /*MN sent NMT command EnableReadyToOperate */
                case kEplNmtBootEventEnableReadyToOp:
                {
                    tPdiAsyncStatus PdiRet = kPdiAsyncStatusSuccessful;

                    /* setup the synchronization interrupt time period */
                    Gi_calcSyncIntPeriod();   // calculate multiple of cycles
#ifdef VETH_DRV_EN
                    Gi_updateDefaultGateway();
#endif //VETH_DRV_EN

                    Gi_pcpEventPost(kPcpPdiEventGeneric, kPcpGenEventNmtEnableReadyToOperate);

                    /* prepare PDO mapping */

                    /* setup PDO <-> DPRAM copy table */
                    // this is needed for static mapping, single PDO descriptors
                    // are already sent if mapping objects are accessed dynamically
                    PdiRet = CnApiAsync_postMsg(kPdiAsyncMsgIntLinkPdosReq,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                0);
                    if (PdiRet != kPdiAsyncStatusSuccessful)
                    {
                        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: Posting kPdiAsyncMsgIntLinkPdosReq failed with: 0x%x\n", PdiRet);
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

            EplRet = EplAppHandleUserEvent(pEventArg_p);
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
\brief  handle an user event

EplAppHandleUserEvent() handles all user events.

\param  pEventArg_p         event argument, the user argument of the event
                            contains the object handle

\return Returns kEplSucessful if user event was successfully handled. Otherwise
        an error code is returned.
*******************************************************************************/
static int EplAppHandleUserEvent(tEplApiEventArg* pEventArg_p)
{
    tObdAccHstryEntry * pObdAccHistorySegm;

    pObdAccHistorySegm = (tObdAccHstryEntry *) pEventArg_p->m_pUserArg;

    return EplAppDefObdAccAdoptedHstryProcessWrite(pObdAccHistorySegm);
}

/**
********************************************************************************
\brief    sync event callback function called by event module

AppCbSync() implements the event callback function called by event module
within kernel part (high priority). This function sets the outputs, reads the
inputs and runs the control loop.

\return    error code (tEplKernel)

\retval    kEplSuccessful   no error
\retval    otherwise        post error event to API layer
*******************************************************************************/
#if EPL_DLL_SOCTIME_FORWARD != FALSE
    tEplKernel PUBLIC AppCbSync(tEplSocTimeStamp SocTimeStamp_p)
#else
    tEplKernel PUBLIC AppCbSync(void)
#endif
{
    tEplKernel      EplRet = kEplSuccessful;
    tCnApiStatus    CnApiRet = kCnApiStatusOk;
    static  unsigned int iCycleCnt = 0;
    WORD wSyncIntCycle = Gi_getSyncIntCycle();

    /* check if interrupts are enabled */
    if ((wSyncIntCycle != 0) &&
         ++iCycleCnt == wSyncIntCycle   )
    {
            iCycleCnt = 0;  ///< reset cycle counter
#if EPL_DLL_SOCTIME_FORWARD != FALSE
            #ifdef TIMESYNC_HW
                /* Sync interrupt is generated in HW */
                if(SocTimeStamp_p.m_fSocRelTimeValid != FALSE)
                    Gi_setNetTime(SocTimeStamp_p.m_netTime.m_dwSec,SocTimeStamp_p.m_netTime.m_dwNanoSec);

                CnApiRet = Gi_setRelativeTime((DWORD)SocTimeStamp_p.m_qwRelTime, (DWORD)(SocTimeStamp_p.m_qwRelTime>>32),
                        SocTimeStamp_p.m_fSocRelTimeValid, fOperational);
                if(CnApiRet != kCnApiStatusOk)
                {   //convert CnApi return value
                    EplRet = kEplInvalidOperation;
                }

            #else
                /* Sync interrupt is generated in SW */
                if (fOperational != FALSE)
                {
                    Gi_generateSyncInt();
                }
            #endif  //TIMESYNC_HW
#else
            #ifdef TIMESYNC_HW
                /* Sync interrupt is generated in HW */
                CnApiRet = Gi_setRelativeTime(0, 0, FALSE, fOperational);
                if(CnApiRet != kCnApiStatusOk)
                {   //convert CnApi return value
                    EplRet = kEplInvalidOperation;
                }
            #else
                /* Sync interrupt is generated in SW */
                if (fOperational != FALSE)
                {
                    Gi_generateSyncInt();
                }
            #endif  //TIMESYNC_HW
#endif  //EPL_DLL_SOCTIME_FORWARD
    }

    return EplRet;
}

/**
********************************************************************************
\brief    basic initializations
\param pStateMachineInit_p  [IN] callback functions for PCP state machine
\param pInitParam_p         [IN] pointer to initialization parameter
                                 which will be set later in the pcpAsync module
*******************************************************************************/
int Gi_init(tInitStateMachine * pStateMachineInit_p, tPcpInitParam * pInitParam_p)
{
    int         iRet= OK;
    tfwBootInfo fwBootIibInfo = {0};

    fwBoot_tryGetIibInfo(fIsUserImage_g, &fwBootIibInfo);

    /* Setup PCP Control Register in DPRAM */
    pCtrlReg_g = (tPcpCtrlReg *)PDI_DPRAM_BASE_PCP;     // set address of control register - equals DPRAM base address

    // Note:
    // pCtrlReg_g members m_dwMagic, m_wPcpPdiRev and m_wPcpSysId are set by the Powerlink IP-core.
    // The FPGA internal memory initialization sets the following values:
    // pCtrlReg_g->m_wState: 0x00EE
    // pCtrlReg_g->m_wCommand: 0xFFFF
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwAppDate, fwBootIibInfo.uiApplicationSwDate);
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwAppTime, fwBootIibInfo.uiApplicationSwTime);
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventType, 0x00);                // invalid event TODO: structure
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventArg, 0x00);                 // invalid event argument TODO: structure
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wState, kPcpStateInvalid);        // set invalid PCP state

    DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Wait for AP reset cmd..\n");

    /* wait for reset command from AP */
    while (getCommandFromAp() != kApCmdReset)
        ;

    // init event fifo queue
    Gi_pcpEventFifoInit();

    // init time sync module
    Gi_initSync();

    // start PCP API state machine and move to PCP_BOOTED state
    if(Gi_initStateMachine(pStateMachineInit_p) == FALSE)
    {
        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrInitFailed);
        DEBUG_TRACE0(DEBUG_LVL_09, "Gi_initStateMachine() FAILED!\n");
        goto exit;
    }

    // init asynchronous PCP <-> AP communication
    iRet = CnApiAsync_create(pInitParam_p);
    if (iRet != OK )
    {
        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrInitFailed);
        DEBUG_TRACE0(DEBUG_LVL_09, "CnApiAsync_create() FAILED!\n");
        goto exit;
    }

    // init cyclic object processing
    iRet = Gi_initPdo();
    if (iRet != OK )
    {
        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrInitFailed);
        DEBUG_TRACE0(DEBUG_LVL_09, "Gi_initPdo() FAILED!\n");
        goto exit;
    }

exit:
    return iRet;
}

/**
********************************************************************************
\brief  cleanup and exit generic interface
*******************************************************************************/
void Gi_shutdown(void)
{
    //TODO: free other things
    Gi_deletePcpObjLinksTbl();
}

/* EOF */
/*********************************************************************************/
