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
#include "global.h"

#include "fpgaCfg.h"
#include "fwUpdate.h"

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

//---------------------------------------------------------------------------
// defines
//---------------------------------------------------------------------------
#define OBD_DEFAULT_ACC_HISTORY_ACK_FINISHED_THLD 3           ///< count of history entries, where 0BD accesses will still be acknowledged
#define OBD_DEFAULT_ACC_HISTORY_SIZE              20          ///< maximum possible history elements
#define OBD_DEFAULT_ACC_INVALID                   0xFFFFUL

//---------------------------------------------------------------------------
// module global vars
//---------------------------------------------------------------------------
volatile tPcpCtrlReg *         pCtrlReg_g;    ///< ptr. to PCP control register
tPcpInitParam       initParam_g = {{0}};        ///< Powerlink initialization parameter
BOOL               fIsUserImage_g;            ///< if set user image is booted
UINT32             uiFpgaConfigVersion_g = 0; ///< version of currently used FPGA configuration
BOOL               fOperational = FALSE;

static BOOL     fShutdown_l = FALSE;          ///< Powerlink shutdown flag
static tObdAccHstryEntry aObdDefAccHdl_l[OBD_DEFAULT_ACC_HISTORY_SIZE]; ///< segmented object access management

BYTE bDefObdAccHistoryEmptyCnt_g = OBD_DEFAULT_ACC_HISTORY_SIZE;
/* counter of subsequent accesses to an object */
WORD wObdAccHistorySeqCnt_g = OBD_DEFAULT_ACC_INVALID;
/* counter of default OBD access elements for external communication connection */
WORD wObdAccHistoryComConCnt_g = OBD_DEFAULT_ACC_INVALID;

tApiPdiComCon ApiPdiComInstance_g;

tObjTbl     *pPcpLinkedObjs_g = NULL;  ///< table of linked objects at pcp side according to AP message
DWORD       dwApObjLinkEntries_g = 0;  ///< number of linked objects at pcp side

/******************************************************************************/
// TEST SDO TRANSFER TO AP

#ifdef TEST_OBD_ADOPTABLE_FINISHED_TIMERU
tEplTimerArg    TimerArg;
tEplTimerHdl    EplTimerHdl;
#endif // TEST_OBD_ADOPTABLE_FINISHED_TIMERU

/******************************************************************************/
// This function is the entry point for your object dictionary. It is defined
// in OBJDICT.C by define EPL_OBD_INIT_RAM_NAME. Use this function name to define
// this function prototype here. If you want to use more than one Epl
// instances then the function name of each object dictionary has to differ.
tEplKernel PUBLIC  EplObdInitRam (tEplObdInitParam MEM* pInitParam_p);

/******************************************************************************/
/* forward declarations */
#if EPL_DLL_SOCTIME_FORWARD == TRUE
    tEplKernel PUBLIC AppCbSync(tEplSocTimeStamp SocTimeStamp_p) INT_RAM_MAIN_01_APP_CB_SYNC;
#else
    tEplKernel PUBLIC AppCbSync(void);
#endif

tEplKernel PUBLIC AppCbEvent(tEplApiEventType EventType_p,
                             tEplApiEventArg* pEventArg_p,
                             void GENERIC*pUserArg_p);
static int EplAppHandleUserEvent(tEplApiEventArg* pEventArg_p);

// default OBD access
static tEplKernel  EplAppCbDefaultObdAccess(tEplObdCbParam MEM* pObdParam_p);
static void EplAppCbDefaultObdAssignDatatype(tEplObdParam * pObdParam_p);
static tEplKernel EplAppCbDefaultObdInitWriteLe(tEplObdParam * pObdParam_p);
static tEplKernel EplAppCbDefaultObdPreRead(tEplObdParam * pObdParam_p);
static tEplKernel EplAppDefObdAccPreValidateObjTypeNoFixedSize(tEplObdParam * pObdParam_p);
static tEplKernel EplAppDefObdAccCheckOrigin(tEplObdParam * pObdParam_p);
static tEplKernel EplAppDefObdAccCheckObject(tEplObdParam * pObdParam_p);

// OBD access history private functions
static BOOL EplAppDefObdAccAdoptedHstryCeckOccupied(void);
static BOOL EplAppDefObdAccAdoptedHstryCeckSequenceStarted(void);
static void EplAppDefObdAccAdoptedHstryDeleteEntry(tObdAccHstryEntry *  pDefObdHdl_p);
static tEplKernel EplAppDefObdAccAdoptedHstryGetStatusEntry(
                                        WORD wIndex_p,
                                        WORD wSubIndex_p,
                                        tEplObdAccStatus ReqStatus_p,
                                        BOOL fSearchOldest_p,
                                        tObdAccHstryEntry **ppDefObdAccHdl_p);
static tEplKernel EplAppDefObdAccAdoptedHstryGetEntry(
                                      WORD wComConIdx_p,
                                      tObdAccHstryEntry **ppDefObdAccHdl_p);
static tEplKernel EplAppDefObdAccAdoptedHstryWriteSegm(
                                        tObdAccHstryEntry * pDefObdAccHdl_p,
                                        void * pfnSegmentFinishedCb_p,
                                        void * pfnSegmentAbortCb_p);
static tEplKernel EplAppDefObdAccAdoptedHstryEntryFinished(tObdAccHstryEntry * pObdAccHstEntry_p);
static WORD EplAppDefObdAccAdoptedHstryIncrCnt(WORD * pwCounter_p);

// PDI (Generic Interface)
static tEplKernel Gi_forwardObdAccHstryEntryToPdi(tObdAccHstryEntry * pDefObdHdl_p);
static void Gi_deleteObdAccHstryToPdiConnection(void);
static int Gi_init(void);
static void Gi_shutdown(void);



#ifdef CONFIG_IIB_IS_PRESENT
static tFwRet getImageApplicationSwDateTime(UINT32 *pUiApplicationSwDate_p,
                                  UINT32 *pUiApplicationSwTime_p);
static tFwRet getImageSwVersions(UINT32 *pUiFpgaConfigVersion_p, UINT32 *pUiPcpSwVersion_p,
                       UINT32 *pUiApSwVersion_p);
#endif // CONFIG_IIB_IS_PRESENT
static void rebootCN(void);

static WORD getPcpState(void);

static void processPowerlink(void);
static tEplKernel initPowerlink(tPcpInitParam *pInitParam_p);
static int startPowerlink(void);
static void switchoffPowerlink(void);
static void enterPreOpPowerlink(void);
static void enterReadyToOperatePowerlink(void);



#ifdef TEST_OBD_ADOPTABLE_FINISHED_TIMERU
static tEplKernel SetTimerEventTest(tEplObdParam * pObdParam_p);
#endif // TEST_OBD_ADOPTABLE_FINISHED_TIMERU
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
    tFwRet FwRetVal = kFwRetSuccessful;

    SysComp_initPeripheral();

    switch (FpgaCfg_handleReconfig())
    {
        case kFgpaCfgFactoryImageLoadedNoUserImagePresent:
        {
            // user image reconfiguration failed
            DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Factory image loaded.\n");
            fIsUserImage_g = FALSE;

            FwRetVal = checkFwImage(CONFIG_FACTORY_IMAGE_FLASH_ADRS,
                                    CONFIG_FACTORY_IIB_FLASH_ADRS,
                                    CONFIG_USER_IIB_VERSION);
            if(FwRetVal != kFwRetSuccessful)
            {
                // factory image was loaded, but has invalid IIB
                // checkFwImage() prints error, don't do anything
                // else here for now
                DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: checkFwImage() of factory image failed with 0x%x\n", FwRetVal);
            }
            break;
        }

        case kFpgaCfgUserImageLoadedWatchdogDisabled:
        {
            DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "User image loaded.\n");

#ifdef CONFIG_IIB_IS_PRESENT
            FwRetVal = checkFwImage(CONFIG_USER_IMAGE_FLASH_ADRS,
                                    CONFIG_USER_IIB_FLASH_ADRS,
                                    CONFIG_USER_IIB_VERSION);
            if(FwRetVal != kFwRetSuccessful)
            {
                DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: checkFwImage() of user image failed with 0x%x\n", FwRetVal);

                CNAPI_USLEEP(5000000); // wait 5 seconds

                // user image was loaded, but has invalid IIB
                // -> reset to factory image
                FpgaCfg_reloadFromFlash(CONFIG_FACTORY_IMAGE_FLASH_ADRS);
            }
#endif // CONFIG_IIB_IS_PRESENT

            fIsUserImage_g = TRUE;
            break;
        }

        case kFpgaCfgUserImageLoadedWatchdogEnabled:
        {
            DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "User image loaded.\n");

#ifdef CONFIG_IIB_IS_PRESENT
            FwRetVal = checkFwImage(CONFIG_USER_IMAGE_FLASH_ADRS,
                                    CONFIG_USER_IIB_FLASH_ADRS,
                                    CONFIG_USER_IIB_VERSION);
            if(FwRetVal != kFwRetSuccessful)
            {
                DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: checkFwImage() of user image failed with 0x%x\n", FwRetVal);

                CNAPI_USLEEP(5000000); // wait 5 seconds

                // user image was loaded, but has invalid IIB
                // -> reset to factory image
                FpgaCfg_reloadFromFlash(CONFIG_FACTORY_IMAGE_FLASH_ADRS);
            }
#endif // CONFIG_IIB_IS_PRESENT

            // watchdog timer has to be reset periodically
            //FpgaCfg_resetWatchdogTimer(); // do this periodically!
            fIsUserImage_g = TRUE;
            break;
        }

        case kFgpaCfgWrongSystemID:
        {
            DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Fatal error after booting! Reset to Factory Image!\n");
            CNAPI_USLEEP(5000000); // wait 5 seconds

            // reset to factory image
            FpgaCfg_reloadFromFlash(CONFIG_FACTORY_IMAGE_FLASH_ADRS);

            goto exit; // fatal error
            break;
        }

        default:
        {
#ifdef CONFIG_USER_IMAGE_IN_FLASH
            DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Fatal error after booting! Reset to Factory Image!\n");
            CNAPI_USLEEP(5000000); // wait 5 seconds

            // reset to factory image
            FpgaCfg_reloadFromFlash(CONFIG_FACTORY_IMAGE_FLASH_ADRS);
            goto exit; // this is fatal error only, if image was loaded from flash
#endif
            break;
        }
    }

    DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "\n\nGeneric POWERLINK CN interface - this is PCP starting in main()\n\n");

    /***** initializations *****/
    DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Initializing...\n");

    if (Gi_init() != OK)
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
    // inform AP about reset event - at this special event, do blocking wait
    // until AP has confirmed the reception.
    Gi_pcpEventPost(kPcpPdiEventGeneric, kPcpGenEventResetNodeRequest);

    // trigger FPGA reconfiguration
    // remark: if we are in user image, this command will trigger a
    //         reconfiguration of the factory image regardless of its argument!
    FpgaCfg_reloadFromFlash(CONFIG_FACTORY_IMAGE_FLASH_ADRS); // restart factory image
}

/**
********************************************************************************
\brief    initialize openPOWERLINK stack

\param    pInitParm_p           init structure from the AP

\return   tEplKernel
\retval   kEplSuccessful        on success
*******************************************************************************/
static tEplKernel initPowerlink(tPcpInitParam *pInitParam_p)
{
    DWORD                       ip = IP_ADDR;      // ip address
    static tEplApiInitParam     EplApiInitParam;   // epl init parameter
    tEplKernel                  EplRet;
    UINT32                      uiApplicationSwDate = 0;
    UINT32                      uiApplicationSwTime = 0;

    /* check if NodeID has been set to 0x00 by AP -> use node switches */
#ifdef NODE_SWITCH_BASE
    if(pInitParam_p->m_bNodeId == 0x00)
    {   /* read port configuration input pins and overwrite parameter */
        pInitParam_p->m_bNodeId = SysComp_getNodeId();
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

#ifdef CONFIG_IIB_IS_PRESENT
    tFwRet                      FwRetVal = kFwRetSuccessful;

    /* Read application software date and time */
    FwRetVal = getImageApplicationSwDateTime(&uiApplicationSwDate, &uiApplicationSwTime);
    if (FwRetVal != kFwRetSuccessful)
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: getImageApplicationSwDateTime() failed with 0x%x\n", FwRetVal);
    }

    /* Read FPGA configuration version of current used image */
    FwRetVal = getImageSwVersions(&uiFpgaConfigVersion_g, NULL, NULL);
    if (FwRetVal != kFwRetSuccessful)
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: getImageSwVersions() failed with 0x%x\n", FwRetVal);
    }
#endif // CONFIG_IIB_IS_PRESENT

    /* setup the POWERLINK stack */
    /* calc the IP address with the nodeid */
    ip &= 0xFFFFFF00;                          ///< dump the last byte
    ip |= pInitParam_p->m_bNodeId;              ///< and mask it with the node id

    /* set EPL init parameters */
    EplApiInitParam.m_uiSizeOfStruct = sizeof (EplApiInitParam);
    EPL_MEMCPY(EplApiInitParam.m_abMacAddress, pInitParam_p->m_abMac,
               sizeof(EplApiInitParam.m_abMacAddress));
    EplApiInitParam.m_uiNodeId = pInitParam_p->m_bNodeId;
    EplApiInitParam.m_dwIpAddress = ip;
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
    EplApiInitParam.m_uiAsyncMtu = 300;
    EplApiInitParam.m_uiPrescaler = 2;
    EplApiInitParam.m_dwLossOfFrameTolerance = 5000000;
    EplApiInitParam.m_dwAsyncSlotTimeout = 3000000;
    EplApiInitParam.m_dwWaitSocPreq = 0;
    EplApiInitParam.m_dwDeviceType = pInitParam_p->m_dwDeviceType;
    EplApiInitParam.m_dwVendorId = pInitParam_p->m_dwVendorId;
    EplApiInitParam.m_dwProductCode = pInitParam_p->m_dwProductCode;
    EplApiInitParam.m_dwRevisionNumber = pInitParam_p->m_dwRevision;
    EplApiInitParam.m_dwSerialNumber = pInitParam_p->m_dwSerialNum;
    //EplApiInitParam.m_dwVerifyConfigurationDate;
    //EplApiInitParam.m_dwVerifyConfigurationTime;
    EplApiInitParam.m_dwApplicationSwDate = uiApplicationSwDate;
    EplApiInitParam.m_dwApplicationSwTime = uiApplicationSwTime;
    EplApiInitParam.m_dwSubnetMask = SUBNET_MASK;
    EplApiInitParam.m_dwDefaultGateway = 0;
    EplApiInitParam.m_pszDevName = pInitParam_p->m_strDevName;
    EplApiInitParam.m_pszHwVersion = pInitParam_p->m_strHwVersion;
    EplApiInitParam.m_pszSwVersion = pInitParam_p->m_strSwVersion;
    EplApiInitParam.m_pfnCbEvent = AppCbEvent;
    EplApiInitParam.m_pfnCbSync  = AppCbSync;
    EplApiInitParam.m_pfnCbTpdoPreCopy = Gi_preparePdiPdoReadAccess;    // PDI buffer treatment
    EplApiInitParam.m_pfnCbRpdoPostCopy = Gi_signalPdiPdoWriteAccess;   // PDI buffer treatment
    EplApiInitParam.m_pfnObdInitRam = EplObdInitRam;
    EplApiInitParam.m_pfnDefaultObdCallback = EplAppCbDefaultObdAccess; // called if objects do not exist in local OBD
    EplApiInitParam.m_pfnRebootCb = rebootCN;
    EplApiInitParam.m_pfnPdouCbConfigPdi = Gi_checkandConfigurePdoPdi;

    EplApiInitParam.m_dwSyncResLatency = EPL_C_DLL_T_IFG;

    DEBUG_TRACE1(DEBUG_LVL_09, "INFO: NODE ID is set to 0x%02x\n", EplApiInitParam.m_uiNodeId);

    /* inform AP about current node ID */
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wNodeId, EplApiInitParam.m_uiNodeId);
    Gi_pcpEventPost(kPcpPdiEventGeneric, kPcpGenEventNodeIdConfigured);

    /* initialize firmware update */
    initFirmwareUpdate(pInitParam_p->m_dwProductCode, pInitParam_p->m_dwRevision);

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
    // remark: wSyncIntCycle_g will be calculated right after EnableReadyToOperate command from MN
    ObdSize = sizeof(wSyncIntCycle_g);
    uiVarEntries = 1;
    EplRet = EplApiLinkObject(0x5020, &wSyncIntCycle_g, &uiVarEntries, &ObdSize, 0x02);
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
        /* process Powerlink and it API */
        CnApi_processAsyncStateMachine(); //TODO: Process in User-Callback Event!

        if (Gi_getPlkInitStatus())
        {
            EplApiProcess();
        }

        Gi_updateStateMachine();
        updateFirmwarePeriodic();               // periodically call firmware update state machine

        /* Check if previous event has been confirmed by AP */
        /* If not, try to post it */
        if(Gi_pcpEventFifoProcess(pCtrlReg_g) == kPcpEventFifoPosted)
        {
            DEBUG_TRACE1(DEBUG_LVL_CNAPI_EVENT_INFO,"%s: Posted event from fifo into PDI!\n", __func__);
        }

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
                        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: Posting kPdiAsyncMsgIntLinkPdosReq failed with: %d\n", PdiRet);
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
    tEplKernel      EplRet = kEplSuccessful;
    tEplObdParam *  pObdParam;
    tObdAccHstryEntry * pObdAccHistorySegm;     // handle of this segment
    tObdAccHstryEntry * pTempHdl;               // handle for temporary storage

    // assign user argument
    pObdAccHistorySegm = (tObdAccHstryEntry *) pEventArg_p->m_pUserArg;
    pObdParam = &pObdAccHistorySegm->m_ObdParam;

    DEBUG_TRACE1(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO,
                 "AppCbEvent(kEplApiEventUserDef): (EventArg %p)\n", pObdParam);

    // if we don't find the segmented obd handle the  In this case we immediately return.
    if (pObdAccHistorySegm->m_Status == kEplObdDefAccHdlEmpty)
    {   // segment was already finished or aborted
        // therefore we silently ignore it and exit
        DEBUG_TRACE2(DEBUG_LVL_ERROR,
                     "%s() ERROR: Out-dated handle received %p!\n",
                     __func__, pObdParam);
        return kEplSuccessful;
    }

    DEBUG_TRACE4(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "(0x%04X/%u Ev=%X Size=%u\n",
         pObdParam->m_uiIndex, pObdParam->m_uiSubIndex,
         pObdParam->m_ObdEvent,
         pObdParam->m_SegmentSize);

    /*printf("(0x%04X/%u Ev=%X pData=%p Off=%u Size=%u\n"
           " ObjSize=%u TransSize=%u Acc=%X Typ=%X)\n",
        pObdParam->m_uiIndex, pObdParam->m_uiSubIndex,
        pObdParam->m_ObdEvent,
        pObdParam->m_pData,
        pObdParam->m_SegmentOffset, pObdParam->m_SegmentSize,
        pObdParam->m_ObjSize, pObdParam->m_TransferSize,
        pObdParam->m_Access, pObdParam->m_Type); */

    // TODO: all indices are allowed - but different treatment necessary
    if(pObdParam->m_uiIndex != 0x1F50)
    {   // should not get any other indices
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "%s() invalid object index!\n", __func__);
        return kEplInvalidParam;
    }

    /*------------------------------------------------------------------------*/
    // check if a segment of this object is currently being processed
    EplRet = EplAppDefObdAccAdoptedHstryGetStatusEntry(pObdParam->m_uiIndex,
                                            pObdParam->m_uiSubIndex,
                                            kEplObdDefAccHdlInUse,
                                            FALSE,  // search first
                                            &pTempHdl);
    if (EplRet == kEplSuccessful)
    {   // write operation for this object is already processing
        DEBUG_TRACE3(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO,
                     "%s() Write for object %d(%d) already in progress -> exit\n",
                     __func__, pObdParam->m_uiIndex, pObdParam->m_uiSubIndex);
        // change handle status -> queue segment
        pObdAccHistorySegm->m_Status = kEplObdDefAccHdlWaitProcessingQueue;
    }
    else
    {
        switch (pObdAccHistorySegm->m_Status)
        {
            case kEplObdDefAccHdlWaitProcessingInit:
            case kEplObdDefAccHdlWaitProcessingQueue:
                // segment has not been processed yet -> do a initialize writing

                // change handle status
                pObdAccHistorySegm->m_Status = kEplObdDefAccHdlWaitProcessingQueue;

                /* search for oldest handle where m_pfnAccessFinished call is
                 * still due. As we know that we find at least our own handle,
                 * we don't have to take care of the return value! (Assuming
                 * there is no software error :) */
                EplAppDefObdAccAdoptedHstryGetStatusEntry(pObdParam->m_uiIndex,
                        pObdParam->m_uiSubIndex,
                        kEplObdDefAccHdlWaitProcessingQueue,
                        TRUE,           // find oldest
                        &pTempHdl);

                DEBUG_TRACE4(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() Check for oldest handle. EventHdl:%p Oldest:%p (Seq:%d)\n",
                             __func__, pObdParam, &pObdAccHistorySegm->m_ObdParam,
                             pObdAccHistorySegm->m_wSeqCnt);

                if (pTempHdl == pObdAccHistorySegm)
                {   // this is the oldest handle so we do the write
                    EplRet = EplAppDefObdAccAdoptedHstryWriteSegm(pObdAccHistorySegm,
                                     EplAppDefObdAccAdoptedHstryWriteSegmFinishCb,
                                     EplAppDefObdAccAdoptedHstryWriteSegmAbortCb);
                }
                else
                {
                    // it is not the oldest handle so do nothing
                    // and wait until this function is called with the oldest
                    EplRet = kEplSuccessful;
                }
                break;

            case kEplObdDefAccHdlProcessingFinished:
                // go on with acknowledging finished segments
                DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO,
                        "%s() Handle Processing finished: %d\n", __func__,
                        pObdAccHistorySegm->m_wComConIdx);
                EplRet = kEplSuccessful;
                break;

            case kEplObdDefAccHdlError:
            default:
                // all other not handled cases are not allowed -> error
                DEBUG_TRACE2(DEBUG_LVL_ERROR, "%s() ERROR: Invalid handle status %d!\n",
                        __func__, pObdAccHistorySegm->m_Status);
                // do ordinary SDO sequence processing / reset flow control manipulation
                EplSdoAsySeqAppFlowControl(0, FALSE);
                // Abort all not empty handles of segmented transfer
                EplAppDefObdAccAdoptedHstryCleanup();
                EplRet = kEplSuccessful;
                break;
        } // switch (pObdAccHistorySegm->m_Status)
    } /* else -- handle already in progress */

    return EplRet;
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
#if EPL_DLL_SOCTIME_FORWARD == TRUE
    tEplKernel PUBLIC AppCbSync(tEplSocTimeStamp SocTimeStamp_p)
#else
    tEplKernel PUBLIC AppCbSync(void)
#endif
{
    tEplKernel  EplRet = kEplSuccessful;
    static  unsigned int iCycleCnt = 0;

    /* check if interrupts are enabled */
    if ((wSyncIntCycle_g != 0))
    {
        /* NMT_READY_TO_OPERATE is already processed */
        if (++iCycleCnt == wSyncIntCycle_g)
        {
            iCycleCnt = 0;  ///< reset cycle counter
#if EPL_DLL_SOCTIME_FORWARD == TRUE
            #ifdef TIMESYNC_HW
                /* Sync interrupt is generated in HW */
                if(SocTimeStamp_p.m_fSocRelTimeValid != FALSE)
                    Gi_setNetTime(SocTimeStamp_p.m_netTime.m_dwSec,SocTimeStamp_p.m_netTime.m_dwNanoSec);

                EplRet = Gi_setRelativeTime((DWORD)SocTimeStamp_p.m_qwRelTime, (DWORD)(SocTimeStamp_p.m_qwRelTime>>32),
                        SocTimeStamp_p.m_fSocRelTimeValid, fOperational);

            #else
                /* Sync interrupt is generated in SW */
                Gi_generateSyncInt();
            #endif  //TIMESYNC_HW
#else
            #ifdef TIMESYNC_HW
                /* Sync interrupt is generated in HW */
                EplRet = Gi_setRelativeTime(0, 0, FALSE, fOperational);
            #else
                /* Sync interrupt is generated in SW */
                Gi_generateSyncInt();
            #endif  //TIMESYNC_HW
#endif  //EPL_DLL_SOCTIME_FORWARD
        }
    }

    return EplRet;
}


/**
********************************************************************************
\brief    get command from AP

getCommandFromAp() gets the command from the application processor(AP).

\return        command from AP
*******************************************************************************/
BYTE getCommandFromAp(void)
{
    return AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wCommand));
}

/**
********************************************************************************
\brief    store the state the PCP is in
*******************************************************************************/
void storePcpState(BYTE bState_p)
{
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wState, bState_p);
}

/**
********************************************************************************
\brief    get the state of the PCP state machine
*******************************************************************************/
static WORD getPcpState(void)
{
    return AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wState));
}

/**
********************************************************************************
\brief  create table of objects to be linked at PCP side according to AP message

\param dwMaxLinks_p     Number of objects to be linked.

\return OK or ERROR
*******************************************************************************/
int Gi_createPcpObjLinksTbl(DWORD dwMaxLinks_p)
{
    if (pPcpLinkedObjs_g != NULL) // table has already been created
    {
        EPL_FREE(pPcpLinkedObjs_g);
    }
    /* allocate memory for object table */
    pPcpLinkedObjs_g = EPL_MALLOC (sizeof(tObjTbl) * dwMaxLinks_p);
    if (pPcpLinkedObjs_g == NULL)
    {
        return ERROR;
    }
    dwApObjLinkEntries_g = 0; // reset entry counter

    return OK;
}

/**
********************************************************************************
\brief    basic initializations
*******************************************************************************/
static int Gi_init(void)
{
    int         iRet= OK;
    UINT32      uiApplicationSwDate = 0;
    UINT32      uiApplicationSwTime = 0;
    tInitStateMachine StateMachineInit;

#ifdef CONFIG_IIB_IS_PRESENT
    tFwRet      FwRetVal = kFwRetSuccessful;

    FwRetVal = getImageApplicationSwDateTime(&uiApplicationSwDate, &uiApplicationSwTime);
    if (FwRetVal != kFwRetSuccessful)
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: getImageApplicationSwDateTime() failed with 0x%x\n", FwRetVal);
    }
#endif // CONFIG_IIB_IS_PRESENT

    /* Setup PCP Control Register in DPRAM */
    pCtrlReg_g = (tPcpCtrlReg *)PDI_DPRAM_BASE_PCP;     // set address of control register - equals DPRAM base address

    // Note:
    // pCtrlReg_g members m_dwMagic, m_wPcpPdiRev and m_wPcpSysId are set by the Powerlink IP-core.
    // The FPGA internal memory initialization sets the following values:
    // pCtrlReg_g->m_wState: 0x00EE
    // pCtrlReg_g->m_wCommand: 0xFFFF
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwAppDate, uiApplicationSwDate);
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwAppTime, uiApplicationSwTime);
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

    // setup state machine init parameters
    StateMachineInit.m_fpInitPlk = initPowerlink;
    StateMachineInit.m_fpStartPlk = startPowerlink;
    StateMachineInit.m_fpShutdownPlk = switchoffPowerlink;
    StateMachineInit.m_fpRdyToOpPlk = enterReadyToOperatePowerlink;
    StateMachineInit.m_fpPreOpPlk = enterPreOpPowerlink;

    // start PCP API state machine and move to PCP_BOOTED state
    if(Gi_initStateMachine(&StateMachineInit) == FALSE)
    {
        Gi_pcpEventPost(kPcpPdiEventGenericError, kPcpGenErrInitFailed);
        DEBUG_TRACE0(DEBUG_LVL_09, "Gi_initStateMachine() FAILED!\n");
        goto exit;
    }

    // init asynchronous PCP <-> AP communication
    iRet = CnApiAsync_create();

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
static void Gi_shutdown(void)
{
    /* free object link table */
    EPL_FREE(pPcpLinkedObjs_g);

    //TODO: free other things
}

/**
********************************************************************************
\brief    control LED outputs of POWERLINK IP core
*******************************************************************************/
void Gi_controlLED(tCnApiLedType bType_p, BOOL bOn_p)
{
    WORD        wRegisterBitNum;
    WORD        wLedControl;

    switch (bType_p)
        {
        case kCnApiLedTypeStatus:
            wRegisterBitNum = LED_STATUS;
            break;
        case kCnApiLedTypeError:
            wRegisterBitNum = LED_ERROR;
            break;
        case kCnApiLedInit:
            /* This case if for initing the LEDs */
            /* enable forcing for all LEDs */
            AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wLedConfig, 0xffff);
            if (bOn_p)  //activate LED output
            {
                AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wLedControl, 0xffff);  // switch on all LEDs
            }
            else       // deactive LED output
            {
                AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wLedControl, 0x0000); // switch off all LEDs

                /* disable forcing all LEDs except status and error LED (default register value) */
                AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wLedConfig, 0x0003);
            }
            goto exit;
        default:
            goto exit;
        }

    wLedControl = AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wLedControl));

    if (bOn_p)  //activate LED output
    {
        wLedControl |= (1 << wRegisterBitNum);
    }
    else        // deactive LED output
    {
        wLedControl &= ~(1 << wRegisterBitNum);
    }

    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wLedControl, wLedControl);

exit:
    return;
}

/**
********************************************************************************
\brief  check if forwarding object access to PDI is possible

\param pDefObdHdl_p         default OBD access history entry
\retval kEplSuccessful      forwarding object access to PDI is possible
\retval kEplObdOutOfMemory  PDI communication channel is in use
*******************************************************************************/
tEplKernel Gi_openObdAccHstryToPdiConnection(tObdAccHstryEntry * pDefObdHdl_p)
{
    if (ApiPdiComInstance_g.m_ObdAccFwd.m_Origin != kObdAccStorageInvalid)
    {
        pDefObdHdl_p->m_ObdParam.m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
        return kEplObdOutOfMemory;
    }

    // response has to know connection to OBD access handle
    ApiPdiComInstance_g.m_ObdAccFwd.m_wComConIdx = pDefObdHdl_p->m_wComConIdx;
    ApiPdiComInstance_g.m_ObdAccFwd.m_Origin = kObdAccStorageDefObdAccHistory;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() ComConIdx: %d\n",
                 __func__, ApiPdiComInstance_g.m_ObdAccFwd.m_wComConIdx);

    return kEplSuccessful;
}

/**
********************************************************************************
\brief  check if forwarding object access to PDI is possible

\param wComConIdx_p             OBD access history connection Index
\param dwAbortCode_p            SDO abort code
\param wReadObjRespSegmSize_p   read access response data size (0 if not used)
\param pReadObjRespData_p       read access response data address (NULL if not used)

\return tEplKernel
\retval kEplSuccessful                      closed and finished connection
\retval kEplObdVarEntryNotExist             OBD history entry not found
*******************************************************************************/
tEplKernel Gi_closeObdAccHstryToPdiConnection(
                                                WORD wComConIdx_p,
                                                DWORD dwAbortCode_p,
                                                WORD  wReadObjRespSegmSize_p,
                                                void* pReadObjRespData_p)
{
    tEplKernel Ret = kEplSuccessful;
    tObdAccHstryEntry * pObdAccHstEntry = NULL;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() ComConIdx: %d\n",
                 __func__, ApiPdiComInstance_g.m_ObdAccFwd.m_wComConIdx);

    Ret = EplAppDefObdAccAdoptedHstryGetEntry(wComConIdx_p,
                                              &pObdAccHstEntry);
    if (Ret == kEplObdVarEntryNotExist)
    {
        // history entry could not be found,
        // it was deleted due to an error or reset -> stop further processing
        goto exit;
    }
    else if(Ret != kEplSuccessful)
    {
        goto exit;
    }
    else
    {
        if (pObdAccHstEntry->m_ObdParam.m_dwAbortCode == 0)
        {
            if(dwAbortCode_p != 0)
            {   // Only overwrite abort code if it wasn't assigned ealier by another module
                pObdAccHstEntry->m_ObdParam.m_dwAbortCode = dwAbortCode_p;
            }
            else
            {   // all abort codes are 0
                if(pObdAccHstEntry->m_ObdParam.m_ObdEvent == kEplObdEvPreRead)
                {
                    // assign data information needed by object read response
                    pObdAccHstEntry->m_ObdParam.m_SegmentSize = wReadObjRespSegmSize_p;
                    pObdAccHstEntry->m_ObdParam.m_pData = pReadObjRespData_p;
                }
            }
        }

        Gi_deleteObdAccHstryToPdiConnection();

        Ret = EplAppDefObdAccAdoptedHstryEntryFinished(pObdAccHstEntry);
        if (Ret != kEplSuccessful)
        {
            goto exit;
        }
    }

exit:
    return Ret;
}

/**
********************************************************************************
\brief  delete OBD access history to PDI connection
*******************************************************************************/
static void Gi_deleteObdAccHstryToPdiConnection(void)
{
    ApiPdiComInstance_g.m_ObdAccFwd.m_wComConIdx = OBD_DEFAULT_ACC_INVALID;
    ApiPdiComInstance_g.m_ObdAccFwd.m_Origin = kObdAccStorageInvalid;
}

/**
 ********************************************************************************
 \brief forwards an object access to an Application Processor (AP)
 \param pDefObdHdl_p    object access handle of object to be forwarded
 \param pDefObdHdl_p    pointer to OBD access handle history
 \retval kEplSuccessful forwarding  succeeded
 \retval kEplSdoSeqConnectionBusy   forwarding aborted because no resources
                                    are available to send a message to AP
 \retval kEplInvalidOperation       general error

 This function posts an asynchronous message to the AP which contains an object
 access request. In case of an error this function modifies the abort code of
 the input parameter pObdParam_p.
 *******************************************************************************/
static tEplKernel Gi_forwardObdAccHstryEntryToPdi(tObdAccHstryEntry * pDefObdHdl_p)
{
    tPdiAsyncStatus PdiRet = kPdiAsyncStatusSuccessful;
    tEplKernel Ret = kEplSuccessful;
    tObjAccSdoComCon PdiObjAccCon;
    WORD             wComConIdx = 0;

    if (pDefObdHdl_p == NULL)
    {
        Ret = kEplInvalidParam;
        goto Exit;
    }

    Ret = Gi_openObdAccHstryToPdiConnection(pDefObdHdl_p);
    if (Ret != kEplSuccessful)
    {
        goto Exit;
    }

    if(Gi_getCurPdiObdAccFwdComCon(&ApiPdiComInstance_g, &wComConIdx) == TRUE)
    {   // PDI connection established

        PdiObjAccCon.m_wObdAccConNum = wComConIdx; // forward OBD access connection number to PDI
        // assign SDO command frame and convert from epl to cnapi structure
        PdiObjAccCon.m_pSdoCmdFrame = (tCnApiAsySdoCom *)pDefObdHdl_p->m_ObdParam.m_pRemoteAddress->m_le_pSdoCmdFrame;
        PdiObjAccCon.m_uiSizeOfFrame = offsetof(tEplAsySdoCom , m_le_abCommandData) +
        AmiGetWordFromLe(&pDefObdHdl_p->m_ObdParam.m_pRemoteAddress->m_le_pSdoCmdFrame->m_le_wSegmentSize);

        // Note: since PdiObjAccCon is a local variable, the call-back function
        //       has to be executed in a sub function call  call immediately.
        //       Therefore it can not be a "direct-access" transfer!
        PdiRet = CnApiAsync_postMsg(
                        kPdiAsyncMsgIntObjAccReq,
                        (BYTE *) &PdiObjAccCon,
                        Gi_ObdAccFwdPdiTxFinishedErrCb,
                        NULL,
                        NULL,
                        0);

        if (PdiRet == kPdiAsyncStatusRetry)
        {
            Ret = kEplSdoSeqConnectionBusy;
            pDefObdHdl_p->m_ObdParam.m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_DUE_LOCAL_CONTROL;
            goto Exit;
        }
        else if (PdiRet != kPdiAsyncStatusSuccessful)
        {
            DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: CnApiAsync_postMsg() retval 0x%x\n", PdiRet);
            pDefObdHdl_p->m_ObdParam.m_dwAbortCode = EPL_SDOAC_GENERAL_ERROR;
            Ret = kEplInvalidOperation;
            goto Exit;
        }
    }
    else
    {   // no PDI connection found
        Ret = kEplInvalidParam;
        goto Exit;
    }

Exit:
    return Ret;
}

/**
 ********************************************************************************
 \brief call back function, invoked after message transfer has finished
 \param  pMsgDescr_p         pointer to asynchronous message descriptor
 \return Ret                 tPdiAsyncStatus value

 This function will be called if an OBD access forwarded to PDI has finished.
 It signals that the transfer finished to the originator in case of an
 error. This is the only functionality, the real OBD access finished function
 will be triggered by a return message from PDI (sent by AP).
 *******************************************************************************/
tPdiAsyncStatus Gi_ObdAccFwdPdiTxFinishedErrCb(tPdiAsyncMsgDescr * pMsgDescr_p)
{
tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;
tEplKernel          EplRet;
WORD                wComConIdx;

    DEBUG_FUNC;

    if (pMsgDescr_p == NULL)  // message descriptor invalid
    {
        Ret = kPdiAsyncStatusInvalidInstanceParam;
        goto exit;
    }

    // error handling
    if ((pMsgDescr_p->MsgStatus_m == kPdiAsyncMsgStatusError) &&
        (pMsgDescr_p->Error_m != kPdiAsyncStatusSuccessful)     )
    {
        if(Gi_getCurPdiObdAccFwdComCon(&ApiPdiComInstance_g, &wComConIdx) == TRUE)
        {
            EplRet = Gi_closeObdAccHstryToPdiConnection(wComConIdx,
                                                        EPL_SDOAC_DATA_NOT_TRANSF_DUE_LOCAL_CONTROL,
                                                        0,
                                                        NULL);
            if (EplRet != kEplSuccessful)
            {
                Ret = kPdiAsyncStatusInvalidOperation;
                goto exit;
            }
        }
        else
        {
            // seems like PDI connection was deleted already -> error
            Ret = kPdiAsyncStatusInvalidOperation;
            goto exit;
        }
    }

exit:
    return Ret;
}

/**
 ********************************************************************************
 \brief returns current OBD access forwarding communication index
 \param  pApiPdiComConInst_p  pointer to PDI communication connection instance
 \param  pwComConIdx_p        [OUT]: communication connection index
 \return BOOL
 \retval TRUE   connection found
 \retval FALSE  no connection available
 *******************************************************************************/
BOOL Gi_getCurPdiObdAccFwdComCon(tApiPdiComCon * pApiPdiComConInst_p,
                                        WORD * pwComConIdx_p)
{
    tObdAccComCon * pObdAccComCon = &pApiPdiComConInst_p->m_ObdAccFwd;

    if(pObdAccComCon->m_Origin == kObdAccStorageDefObdAccHistory)
    {
        *pwComConIdx_p = pObdAccComCon->m_wComConIdx;
        return TRUE;
    }

    *pwComConIdx_p = OBD_DEFAULT_ACC_INVALID;
    return FALSE;
}

/**
********************************************************************************
\brief called if object index does not exits in OBD

This default OBD access callback function shall be invoked if an index is not
present in the local OBD. If a subindex is not present, this function shall not
be called. If the access to the desired object can not be handled immediately,
kEplObdAccessAdopted has to be returned.

\param pObdParam_p   OBD access structure

\return    tEplKernel value
*******************************************************************************/
static tEplKernel  EplAppCbDefaultObdAccess(tEplObdCbParam MEM* pObdParam_p)
{
    tEplKernel       Ret = kEplSuccessful;

    if (pObdParam_p == NULL)
    {
        return kEplInvalidParam;
    }

    Ret = EplAppDefObdAccCheckObject(pObdParam_p);
    if (Ret != kEplSuccessful)
    {
        if (Ret == kEplReject)
        {
            Ret = kEplSuccessful;
        }
        goto Exit;
    }

    DEBUG_TRACE4(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "EplAppCbDefaultObdAccess(0x%04X/%u Ev=%X Size=%u\n",
            pObdParam_p->m_uiIndex, pObdParam_p->m_uiSubIndex,
            pObdParam_p->m_ObdEvent,
            pObdParam_p->m_SegmentSize);

//    printf("EplAppCbDefaultObdAccess(0x%04X/%u Ev=%X pData=%p Off=%u Size=%u"
//           " ObjSize=%u TransSize=%u Acc=%X Typ=%X)\n",
//        pObdParam_p->m_uiIndex, pObdParam_p->m_uiSubIndex,
//        pObdParam_p->m_ObdEvent,
//        pObdParam_p->m_pData, pObdParam_p->m_SegmentOffset, pObdParam_p->m_SegmentSize,
//        pObdParam_p->m_ObjSize, pObdParam_p->m_TransferSize, pObdParam_p->m_Access, pObdParam_p->m_Type);

    switch (pObdParam_p->m_ObdEvent)
    {
        case kEplObdEvCheckExist:
            EplAppCbDefaultObdAssignDatatype(pObdParam_p);
            break;

        case kEplObdEvInitWriteLe:
            Ret = EplAppCbDefaultObdInitWriteLe(pObdParam_p);
            break;

        case kEplObdEvPreRead:
            Ret = EplAppCbDefaultObdPreRead(pObdParam_p);
            break;

        default:
            break;
    }

Exit:
    return Ret;
}

/**
********************************************************************************
\brief  assign data type in a obd access handle

\param  pObdParam_p     Pointer to obd access handle
*******************************************************************************/
static void EplAppCbDefaultObdAssignDatatype(tEplObdParam * pObdParam_p)
{
    // assign data type

    // check object size and type
    switch (pObdParam_p->m_uiIndex)
    {
//        case 0x1010:
//        case 0x1011:
//            pObdParam_p->m_Type = kEplObdTypUInt32;
//            pObdParam_p->m_ObjSize = 4;
//            break;

        case 0x1F50:
            pObdParam_p->m_Type = kEplObdTypDomain;
            //TODO Debug: check maximum segment offset
            break;

        default:
            if(pObdParam_p->m_uiIndex >= 0x2000)
            {  // all application specific objects will be verified at AP side
                break;
            }

            break;
    } /* switch (pObdParam_p->m_uiIndex) */
}

/**
********************************************************************************
\brief  writes data to an OBD entry from a source with little endian byteorder

\param  pObdParam_p     pointer to object handle

\return kEplObdAccessAdopted or error code
*******************************************************************************/
static tEplKernel EplAppCbDefaultObdInitWriteLe(tEplObdParam * pObdParam_p)
{
    tEplKernel       Ret = kEplSuccessful;
    tObdAccHstryEntry *  pDefObdHdl = NULL;

    // do not return kEplSuccessful in this case,
    // only error or kEplObdAccessAdopted is allowed! //TODO: Why?

    // Note SDO: Only a "history segment block" can be delayed, but not single segments!
    //           Client will send Ack Request after sending a history block, so we don't need to
    //           send an Ack immediately after first received frame.

    Ret = EplAppDefObdAccCheckOrigin(pObdParam_p);
    if (Ret != kEplSuccessful)
    {
        if (Ret == kEplReject)
        {
            // all internal originators (other than SDO)
            // workaround: do not forward error because EplApiLinkObject() causes kEplReject
            Ret = kEplSuccessful;

            /* TODO Debug: if we exit here we return successful which shouldn't be according to
               comment at beginning of function. Anyhow, this does not harm here.
               Check if kEplReject can be returned directly. */
        }
        goto Exit;
    }

    Ret = EplAppDefObdAccCheckObject(pObdParam_p);
    if (Ret != kEplSuccessful)
    {
        if (Ret == kEplReject)
        {
            Ret = kEplSuccessful;
        }
        goto Exit;
    }

    // handle non-adopted access here if applicable

    // adopt OBD access
    // Note: Non-adopted object access should not reach here

    // all object which reach here and are not blocked in advance
    // will be forwarded to PDI
    Ret = EplAppDefObdAccPreValidateObjTypeNoFixedSize(pObdParam_p);
    if (Ret == kEplInvalidParam)
    {   // expedited object access - directly forward to PDI

        Ret = EplAppDefObdAccAdoptedHstryInitSequence();
        if (Ret != kEplSuccessful)
        {
            pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
            goto Exit;
        }

        Ret = EplAppDefObdAccAdoptedHstrySaveHdl(pObdParam_p, &pDefObdHdl);
        if (Ret != kEplSuccessful)
        {
            goto Exit;
        }

        Ret = Gi_forwardObdAccHstryEntryToPdi(pDefObdHdl);
        if (Ret != kEplSuccessful)
        {
            goto Exit;
        }
#ifdef TEST_OBD_ADOPTABLE_FINISHED_TIMERU
        Ret = SetTimerEventTest(&pDefObdHdl->m_ObdParam);
        if (Ret != kEplSuccessful)
        {
            goto Exit;
        }
#endif // TEST_OBD_ADOPTABLE_FINISHED_TIMERU
    }
    else if (Ret == kEplSuccessful)
    {   // segmented object access - needs to be buffered

        Ret = EplAppDefObdAccAdoptedHstrySaveHdl(pObdParam_p, &pDefObdHdl);
        if (Ret != kEplSuccessful)
        {
            goto Exit;
        }

        // trigger write operation (in AppEventCb)
        Ret = EplApiPostUserEvent((void*) pDefObdHdl);
        if (Ret != kEplSuccessful)
        {
            goto Exit;
        }
    }
    else
    {   // error
        goto Exit;
    }

    // adopt write access
    Ret = kEplObdAccessAdopted;
    DEBUG_TRACE0(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, " Adopted\n");

Exit:
    if ((Ret != kEplObdAccessAdopted) &&
        (pDefObdHdl != NULL)            )
    {
        // OBD handle was saved -> delete it
        EplAppDefObdAccAdoptedHstryDeleteEntry(pDefObdHdl);
    }

    return Ret;
}

/**
********************************************************************************
\brief  pre-read checking for default object callback function

\param      pObdParam_p     pointer to object handle

\return     kEplObdAccessAdopted or kEplObdSegmentReturned
*******************************************************************************/
static tEplKernel EplAppCbDefaultObdPreRead(tEplObdParam * pObdParam_p)
{
    tEplKernel       Ret = kEplSuccessful;
    tObdAccHstryEntry *  pDefObdHdl = NULL;

    // do not return kEplSuccessful in this case,
    // only error or kEplObdAccessAdopted or kEplObdSegmentReturned is allowed! //TODO: Why?

    // Note: kEplObdAccessAdopted can only be returned for expedited (non-fragmented) reads!
    // Adopted access is not yet implemented for segmented kEplObdEvPreRead.
    // Thus, kEplObdSegmentReturned has to be returned in this case! This requires immediate access to
    // the read source data right from this function.

    Ret = EplAppDefObdAccCheckOrigin(pObdParam_p);
    if (Ret != kEplSuccessful)
    {
        if (Ret == kEplReject)
        {
            // all internal originators (other than SDO)
            // workaround: do not forward error because EplApiLinkObject() causes kEplReject
            Ret = kEplSuccessful;

            /* TODO Debug: if we exit here we return successful which shouldn't be according to
               comment at beginning of function. Anyhow, this does not harm here.
               Check if kEplReject can be returned directly. */
        }
        goto Exit;
    }

    Ret = EplAppDefObdAccCheckObject(pObdParam_p);
    if (Ret != kEplSuccessful)
    {
        if (Ret == kEplReject)
        {
            Ret = kEplSuccessful;
        }
        goto Exit;
    }

    // handle non-adopted access here if applicable

    // adopt OBD access
    // Note: Non-adopted object access should not reach here

    // all object which reach here and are not blocked in advance
    // will be forwarded to PDI
    Ret = EplAppDefObdAccAdoptedHstryInitSequence();
    if (Ret != kEplSuccessful)
    {
        pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
        goto Exit;
    }

    Ret = EplAppDefObdAccAdoptedHstrySaveHdl(pObdParam_p, &pDefObdHdl);
    if (Ret != kEplSuccessful)
    {
        goto Exit;
    }

    Ret = Gi_forwardObdAccHstryEntryToPdi(pDefObdHdl);
    if (Ret != kEplSuccessful)
    {
        goto Exit;
    }

#ifdef TEST_OBD_ADOPTABLE_FINISHED_TIMERU
    Ret = SetTimerEventTest(&pDefObdHdl->m_ObdParam);
    if (Ret != kEplSuccessful)
    {
        goto Exit;
    }
#endif // TEST_OBD_ADOPTABLE_FINISHED_TIMERU

    // adopt read access
    Ret = kEplObdAccessAdopted;
    DEBUG_TRACE0(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "  Adopted\n");

Exit:
    if ((Ret != kEplObdAccessAdopted) &&
        (pDefObdHdl != NULL)            )
    {
        // OBD handle was saved -> delete it
        EplAppDefObdAccAdoptedHstryDeleteEntry(pDefObdHdl);
    }

    return Ret;
}

/**
********************************************************************************
\brief  check if 'kEplObdEvCheckExist' object access should be processed further

 This function is sub-function of EplAppDefObdAccCheckObject.
 It can only be called when pObdParam_p->m_ObdEvent equals kEplObdEvCheckExist,
 otherwise it has an invalid result.

\param  pObdParam_p     pointer to object handle

\retval kEplSuccessful    continue processing
\retval kEplReject        stop processing this object further and exit
                          (tell caller object exists)
\retval kEplObdIndexNotExist    object index does not exist
\retval kEplObdSubindexNotExist object subindex does not exist
\retval kEplInvalidParam        wrong usage of this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccCheckObjectCheckExist(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;

    // kEplObdEvCheckExist is called in advance of a write or read access

    // return error for all non existing objects
    switch (pObdParam_p->m_uiIndex)
    {

//        case 0x1010:
//            switch (pObdParam_p->m_uiSubIndex)
//            {
//                case 0x01:
//                    break;
//                default:
//                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_SUB_INDEX_NOT_EXIST;
//                    Ret = kEplObdSubindexNotExist;
//                    goto Exit;
//            }
//            break;

//        case 0x1011:
//            switch (pObdParam_p->m_uiSubIndex)
//            {
//                case 0x01:
//                    break;
//
//                default:
//                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_SUB_INDEX_NOT_EXIST;
//                    Ret = kEplObdSubindexNotExist;
//                    goto Exit;
//            }
//            break;

        case 0x1F50:
            switch (pObdParam_p->m_uiSubIndex)
            {
                case 0x01:
                    break;
                default:
                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_SUB_INDEX_NOT_EXIST;
                    Ret = kEplObdSubindexNotExist;
                    goto Exit;
            }
            break;

#ifdef CONFIG_USE_SDC_OBJECTS
        case 0x5020:
            switch (pObdParam_p->m_uiSubIndex)
            {
                // those SDC objects exist locally
                case 0x00:
                case 0x02:
                    // exit immediately and do not adopt the OBD access
                    return Ret;
                default:
                    break;
            }
            // do not break here, because default case should forward all
            // remaining sub-indices

#endif // CONFIG_USE_SDC_OBJECTS

        default:
        {
            // Tell calling function that all objects
            // >= 0x2000 exist per default.
            // The actual verification will take place
            // with the write or read access.

            if(pObdParam_p->m_uiIndex < 0x2000)
            {   // remaining PCP objects do not exist
                pObdParam_p->m_dwAbortCode = EPL_SDOAC_OBJECT_NOT_EXIST;
                Ret = kEplObdIndexNotExist;
                goto Exit;
            }
            break;
        }
    } /* switch (pObdParam_p->m_uiIndex) */


Exit:
    return Ret;
}

/**
********************************************************************************
\brief  check if 'kEplObdEvInitWriteLe' object access should be processed further

 This function is sub-function of EplAppDefObdAccCheckObject.
 It can only be called when pObdParam_p->m_ObdEvent equals kEplObdEvInitWriteLe,
 otherwise it has an invalid result.

\param  pObdParam_p     pointer to object handle

\retval kEplSuccessful    continue processing
\retval kEplReject        stop processing this object further and exit
                          (tell caller object exists)
\retval kEplObdIndexNotExist    object index does not exist
\retval kEplObdSubindexNotExist object subindex does not exist
\retval kEplInvalidParam        wrong usage of this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccCheckObjectWriteLe(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;

    // return error for all non existing objects
    switch (pObdParam_p->m_uiIndex)
    {
        default:
            break;
    }

    return Ret;
}

/**
********************************************************************************
\brief  check if 'kEplObdEvPreRead' object access should be processed further

 This function is sub-function of EplAppDefObdAccCheckObject.
 It can only be called when pObdParam_p->m_ObdEvent equals kEplObdEvPreRead,
 otherwise it has an invalid result.

\param  pObdParam_p     pointer to object handle

\retval kEplSuccessful    continue processing
\retval kEplReject        stop processing this object further and exit
                          (tell caller object exists)
\retval kEplObdIndexNotExist    object index does not exist
\retval kEplObdSubindexNotExist object subindex does not exist
\retval kEplInvalidParam        wrong usage of this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccCheckObjectPreRead(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;

    switch (pObdParam_p->m_uiIndex)
    {
        case 0x1F50:
        {   // signal 'stop further processing'
            Ret = kEplReject;
            break;
        }

        default:
            break;
    }

    return Ret;
}

/**
********************************************************************************
\brief  check if object should be processed further

\param  pObdParam_p     pointer to object handle

\retval kEplSuccessful    continue processing
\retval kEplReject        stop processing this object further and exit
                          (tell caller object exists)
\retval kEplObdIndexNotExist    object index does not exist
\retval kEplObdSubindexNotExist object subindex does not exist
\retval kEplInvalidParam        wrong usage of this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccCheckObject(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;

    switch (pObdParam_p->m_ObdEvent)
    {
        case kEplObdEvCheckExist:
        {
            Ret = EplAppDefObdAccCheckObjectCheckExist(pObdParam_p);
            break;
        }
        case kEplObdEvInitWriteLe:
        {
            Ret = EplAppDefObdAccCheckObjectWriteLe(pObdParam_p);
            break;
        }
        case kEplObdEvPreRead:
        {
            Ret = EplAppDefObdAccCheckObjectPreRead(pObdParam_p);
            break;
        }
        case kEplObdEvPostRead:
        {
            // This event happens only if default OBD access is
            // called when accessing a mapping object and validates
            // the to be linked application objects.
            // -> If objects exist will be decided later,
            //    therefore return successful.
            break;
        }

        default:
        {
            Ret = kEplInvalidParam;
            break;
        }
    } // end of switch (pObdParam_p->m_ObdEvent)

    return Ret;
}

/**
********************************************************************************
\brief  check caller and validate its parameters

\param  pObdParam_p     pointer to object handle

\retval kEplSuccessful          valid parameters
\retval kEplObdAccessViolation  invalid parameters from remote originator
\retval kEplObdWriteViolation   remote write access to read only object
\retval kEplReject              originator is internal
*******************************************************************************/
static tEplKernel EplAppDefObdAccCheckOrigin(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;

    // if it is a remote write access (via SDO)
    // to a read only object -> refuse access
    if ((pObdParam_p->m_pRemoteAddress != NULL)           &&
        (pObdParam_p->m_ObdEvent == kEplObdEvInitWriteLe) &&
        (pObdParam_p->m_Access == kEplObdAccR)              )
    {
        Ret = kEplObdWriteViolation;
        pObdParam_p->m_dwAbortCode = EPL_SDOAC_WRITE_TO_READ_ONLY_OBJ;
        goto Exit;
    }

    if (pObdParam_p->m_pRemoteAddress != NULL)
    {   // remote access via SDO

        if (pObdParam_p->m_pfnAccessFinished == NULL)
        {
            // verify if caller has assigned a callback function
            pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
            Ret = kEplObdAccessViolation;
            goto Exit;
        }
    }
    else
    {   // ignore all internal originators than SDO
        Ret = kEplReject;
        goto Exit;
    }

Exit:
    return Ret;
}

/**
********************************************************************************
\brief  check if it is a segmented transfer

\param  ObdType_p   OBD access parameter

\retval TRUE        segmented transfer
\retval FALSE       expedited transfer
*******************************************************************************/
BOOL EplAppDefObdAccCeckTranferIsSegmented(tEplObdParam * pObdParam_p)
{
    if (pObdParam_p->m_TransferSize > 8) //TODO: debug: check if this works for the whole segmented transfer.
    {   // transfer size exceeds 64 bits (max size of fixed data type)
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

/**
********************************************************************************
\brief  check if access to objects which do not have a fixed size is allowed

\param  pObdParam_p         OBD access parameter with non-fixed size

\retval kEplSuccessful      object access is allowed
\retval kEplObdOutOfMemory  object access is not allowed
\retval kEplInvalidParam    object has a fixed size
*******************************************************************************/
static tEplKernel EplAppDefObdAccPreValidateObjTypeNoFixedSize(tEplObdParam * pObdParam_p)
{
    tEplKernel       Ret = kEplSuccessful;

   if(EplAppDefObdAccCeckTranferIsSegmented(pObdParam_p) == TRUE)
   {
       // if it is an initial segment, check if this object is already accessed
       if (pObdParam_p->m_SegmentOffset == 0)
       {   // inital segment

           Ret = EplAppDefObdAccAdoptedHstryInitSequence();
           if (Ret != kEplSuccessful)
           {
               pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
               goto Exit;
           }
       }
       else
       {
           // block non-initial segments if initial segment processing
           // has not started yet (or processing was aborted)
           if (!EplAppDefObdAccAdoptedHstryCeckSequenceStarted())
           {
               Ret = kEplObdOutOfMemory;
               pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
               goto Exit;
           }
       }
   }
   else
   {   // fixed data size object, access is allowed
       // but this function checks only variable size objects
       Ret = kEplInvalidParam;
       goto Exit;
   }

Exit:
    return Ret;
}

/**
********************************************************************************
\brief  initialize OBD access history access sequence (access to one object)
\retval kEplSuccessful      access accepted
\retval kEplObdOutOfMemory  history is occupied
*******************************************************************************/
tEplKernel EplAppDefObdAccAdoptedHstryInitSequence(void)
{
    // history has to be completely empty for new transfer
    if (EplAppDefObdAccAdoptedHstryCeckOccupied())
    {
        return kEplObdOutOfMemory;
    }
    else
    {   // reset object segment access counter
        wObdAccHistorySeqCnt_g = OBD_DEFAULT_ACC_INVALID;
        return kEplSuccessful;
    }
}

/**
********************************************************************************
\brief  check if OBD access history is already in use

\retval TRUE   history is in use
\retval FALSE  history is available
*******************************************************************************/
static BOOL EplAppDefObdAccAdoptedHstryCeckOccupied(void)
{
    if (bDefObdAccHistoryEmptyCnt_g < OBD_DEFAULT_ACC_HISTORY_SIZE)
    {
       return TRUE;
    }
    else
    {
        return FALSE;
    }
}

/**
********************************************************************************
\brief  check if first element of an segmented OBD accesss was stored to OBD access history

\retval TRUE   history is in use
\retval FALSE  history is available
*******************************************************************************/
static BOOL EplAppDefObdAccAdoptedHstryCeckSequenceStarted(void)
{
    if (wObdAccHistorySeqCnt_g != OBD_DEFAULT_ACC_INVALID)
    {
       return TRUE;
    }
    else
    {
        return FALSE;
    }
}

/**
********************************************************************************
\brief searches for free storage of OBD access handle and saves it to
       the default OBD access history

\param pObdParam_p  [IN]:  pointer to OBD handle
\param ppDefHdl_p   [OUT]: info where the OBD handle was stored

\retval kEplSuccessful          element was successfully assigned
\retval kEplObdOutOfMemory      no free element is left
\retval kEplApiInvalidParam     wrong parameter passed to this function
*******************************************************************************/
tEplKernel EplAppDefObdAccAdoptedHstrySaveHdl(
                            tEplObdParam * pObdParam_p,
                            tObdAccHstryEntry **ppDefHdl_p)
{
    tObdAccHstryEntry * pObdDefAccHdl = NULL;
    BYTE bArrayNum;                     // loop counter and array element

    // check for wrong parameter values
    if (pObdParam_p == NULL)
    {
        return kEplApiInvalidParam;
    }

    // assign default OBD access handle instance
    //TODO: maybe do this in an init function (also OBD_DEFAULT_ACC_HISTORY_SIZE etc.)
    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_ACC_HISTORY_SIZE; bArrayNum++, pObdDefAccHdl++)
    {
        if (pObdDefAccHdl->m_Status == kEplObdDefAccHdlEmpty)
        {
            // free storage found -> save OBD access handle
            EPL_MEMCPY(&pObdDefAccHdl->m_ObdParam, pObdParam_p, sizeof(pObdDefAccHdl->m_ObdParam));

            // save only write data from origin since there is no 'read data' yet
            if (pObdParam_p->m_ObdEvent == kEplObdEvInitWriteLe)
            {
                if(EplAppDefObdAccCeckTranferIsSegmented(pObdParam_p) == TRUE)
                {
                    // save also object data
                    EPL_MEMCPY(&pObdDefAccHdl->m_aObdData, pObdParam_p->m_pData, pObdParam_p->m_SegmentSize);
                    pObdDefAccHdl->m_ObdParam.m_pData = &pObdDefAccHdl->m_aObdData;
                }
                else
                {
                    pObdDefAccHdl->m_ObdParam.m_pData = NULL;
                }
            }

            // update status
            pObdDefAccHdl->m_Status = kEplObdDefAccHdlWaitProcessingInit;
            pObdDefAccHdl->m_wSeqCnt = EplAppDefObdAccAdoptedHstryIncrCnt(&wObdAccHistorySeqCnt_g);
            pObdDefAccHdl->m_wComConIdx = EplAppDefObdAccAdoptedHstryIncrCnt(&wObdAccHistoryComConCnt_g);
            bDefObdAccHistoryEmptyCnt_g--;

            // inform caller about location
            *ppDefHdl_p = pObdDefAccHdl;

            // check if history is full (flow control for SDO)
            if ( bDefObdAccHistoryEmptyCnt_g <
                (OBD_DEFAULT_ACC_HISTORY_SIZE - OBD_DEFAULT_ACC_HISTORY_ACK_FINISHED_THLD))
            {
                // prevent SDO from ack the last received frame
                EplSdoAsySeqAppFlowControl(TRUE, TRUE);
            }
            return kEplSuccessful;
        }
    }

    // no free storage found if we reach here
    pObdDefAccHdl->m_ObdParam.m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
    return kEplObdOutOfMemory;
}

/**
********************************************************************************
\brief deletes an OBD access history element

\param pDefObdHdl_p        OBD access history element which should be deleted
*******************************************************************************/
static void EplAppDefObdAccAdoptedHstryDeleteEntry(tObdAccHstryEntry *  pDefObdHdl_p)
{
    // reset status
    pDefObdHdl_p->m_Status = kEplObdDefAccHdlEmpty;
    pDefObdHdl_p->m_wSeqCnt = OBD_DEFAULT_ACC_INVALID;
    pDefObdHdl_p->m_wComConIdx = OBD_DEFAULT_ACC_INVALID;

    // delete OBD access handle
    EPL_MEMSET(&pDefObdHdl_p->m_ObdParam, 0x00, sizeof(pDefObdHdl_p->m_ObdParam));

    //note: Data (m_aObdData) will no be reset since it is
    //      too time consuming. It should only be interpreted if
    //      'pDefObdHdl_p->m_ObdParam.m_aObdData' is != NULL.

    // update history status
    bDefObdAccHistoryEmptyCnt_g++;
    DEBUG_TRACE1(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "New SDO History Empty Cnt: %d\n",
                 bDefObdAccHistoryEmptyCnt_g);
    return;
}

/**
********************************************************************************
\brief searches for a segmented OBD access handle with a specific status

This function searches for a segmented OBD access handle. it searches for index,
subindex and status. If fSearchOldestEntry is TRUE the oldest entry in history
is searched.

\param wIndex_p             index of searched element
\param wSubIndex_p          subindex of searched element
\param ReqStatus_p          requested status of handle
\param fSearchOldestEntry   if TRUE, the oldest object access will be returned
\param ppObdParam_p         IN:  caller provides  target pointer address
                            OUT: address of found element or NULL

\retval kEplSuccessful              element was found
\retval kEplObdVarEntryNotExist     no element was found
\retval kEplApiInvalidParam         wrong parameter passed to this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccAdoptedHstryGetStatusEntry(
                                        WORD wIndex_p,
                                        WORD wSubIndex_p,
                                        tEplObdAccStatus ReqStatus_p,
                                        BOOL fSearchOldest_p,
                                        tObdAccHstryEntry **ppDefObdAccHdl_p)
{
    tEplKernel      Ret;
    tObdAccHstryEntry * pObdDefAccHdl = NULL;
    BYTE            bArrayNum;          // loop counter and array element

    // check for wrong parameter values
    if (ppDefObdAccHdl_p == NULL)
    {
        return kEplApiInvalidParam;
    }

    Ret = kEplObdVarEntryNotExist;
    *ppDefObdAccHdl_p = NULL;
    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_ACC_HISTORY_SIZE;
         bArrayNum++, pObdDefAccHdl++)
    {

        // search for index, subindex and status
        if ((pObdDefAccHdl->m_ObdParam.m_uiIndex == wIndex_p)        &&
            (pObdDefAccHdl->m_ObdParam.m_uiSubIndex == wSubIndex_p) &&
            (pObdDefAccHdl->m_wSeqCnt != OBD_DEFAULT_ACC_INVALID) &&
            (pObdDefAccHdl->m_Status == ReqStatus_p))
        {
            /* handle found */
            /* check if we have already found another handle */
            if (*ppDefObdAccHdl_p == NULL)
            {
                /* It is the first found handle, therefore save it */
                *ppDefObdAccHdl_p = pObdDefAccHdl;
                Ret = kEplSuccessful;
                if (!fSearchOldest_p)
                {
                    break;
                }
            }
            else
            {
                /* we found a handle but it is not the first one. We compare the
                 * sequence counter and if it is older we store it. */
                if ((*ppDefObdAccHdl_p)->m_wSeqCnt > pObdDefAccHdl->m_wSeqCnt)
                {
                    *ppDefObdAccHdl_p = pObdDefAccHdl;
                }
            }
        }
    }
    return Ret;
}

/**
********************************************************************************
 \brief searches for an adopted OBD access history entry

This function searches for an adopted default OBD access history entry.
The one which contains searched communication index will be returned in a
parameter.

\param wComConIdx_p   communication connection index to be search for
\param ppDefHdl_p     [OUT]: info where the OBD handle was stored

\retval kEplSuccessful              element was found
\retval kEplObdVarEntryNotExist     no element was found
\retval kEplApiInvalidParam         wrong parameter passed to this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccAdoptedHstryGetEntry(
                                      WORD wComConIdx_p,
                                      tObdAccHstryEntry **ppDefObdAccHdl_p)
{
    tEplKernel      Ret;
    tObdAccHstryEntry * pObdAccHstEntry = NULL;
    BYTE            bArrayNum;          // loop counter and array element

    // check for wrong parameter values
    if (ppDefObdAccHdl_p == NULL)
    {
        return kEplApiInvalidParam;
    }

    Ret = kEplObdVarEntryNotExist;
    *ppDefObdAccHdl_p = NULL;
    pObdAccHstEntry = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_ACC_HISTORY_SIZE;
         bArrayNum++, pObdAccHstEntry++)
    {
        if (wComConIdx_p == pObdAccHstEntry->m_wComConIdx)
        {
            // assigned found handle
             *ppDefObdAccHdl_p = pObdAccHstEntry;
             Ret = kEplSuccessful;
             break;
        }
    }

    if (Ret != kEplSuccessful)
    {
        DEBUG_TRACE2(DEBUG_LVL_ERROR, "%s: CCIdx %d not found!\n",
                     __func__, wComConIdx_p);
    }

    return Ret;
}

/**
********************************************************************************
\brief abort callback function

EplAppDefObdAccAdoptedHstryWriteSegmAbortCb() will be called if a segmented write
transfer should be aborted.

\param pDefObdHdl_p     OBD access history element which should be aborted
\returns OK, or ERROR if event posting failed
*******************************************************************************/
int EplAppDefObdAccAdoptedHstryWriteSegmAbortCb(tObdAccHstryEntry * pDefObdHdl_p)
{
    int                 iRet = OK;

    // Disable flow control
    EplSdoAsySeqAppFlowControl(0, FALSE);

    // Abort all not empty handles of segmented transfer
    EplAppDefObdAccAdoptedHstryCleanup();

    DEBUG_TRACE1 (DEBUG_LVL_15, "<--- Abort callback Handle:%d!\n\n",
            pDefObdHdl_p->m_wComConIdx);

    return iRet;
}

/**
********************************************************************************
\brief segment finished callback function

EplAppDefObdAccAdoptedHstryWriteSegmFinishCb() will be called if a segmented write
transfer is finished.

\param pDefObdHdl_p     OBD access history element which should be finished

\return OK or ERROR if something went wrong
*******************************************************************************/
int EplAppDefObdAccAdoptedHstryWriteSegmFinishCb(tObdAccHstryEntry * pDefObdHdl_p)
{
    int                 iRet = OK;
    tObdAccHstryEntry * pFoundHdl;
    tEplKernel          EplRet = kEplSuccessful;
    WORD                wIndex;
    WORD                wSubIndex;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() OBD ACC Hdl processed: %d\n",
                  __func__, pDefObdHdl_p->m_wComConIdx);

    pDefObdHdl_p->m_Status = kEplObdDefAccHdlProcessingFinished;

    wIndex = pDefObdHdl_p->m_ObdParam.m_uiIndex;
    wSubIndex = pDefObdHdl_p->m_ObdParam.m_uiSubIndex;

    // signal "OBD access finished" to originator

    // this triggers an Ack of the last received SDO sequence in case of remote access
    EplRet = EplAppDefObdAccAdoptedHstryEntryFinished(pDefObdHdl_p);
    if (EplRet != kEplSuccessful)
    {
        DEBUG_TRACE1 (DEBUG_LVL_ERROR, "%s() EplAppDefObdAccAdoptedHstryEntryFinished failed!\n",
                      __func__);
        goto Exit;
    }

    // check if segmented write history is empty enough to disable flow control
    if (bDefObdAccHistoryEmptyCnt_g >=
        OBD_DEFAULT_ACC_HISTORY_SIZE - OBD_DEFAULT_ACC_HISTORY_ACK_FINISHED_THLD)
    {
        // do ordinary SDO sequence processing / reset flow control manipulation
        EplSdoAsySeqAppFlowControl(0, FALSE);
    }

    EplRet = EplAppDefObdAccAdoptedHstryGetStatusEntry(wIndex, wSubIndex,
            kEplObdDefAccHdlWaitProcessingQueue, TRUE, &pFoundHdl);
    if (EplRet == kEplSuccessful)
    {
        // handle found
        DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() RePost Event: Hdl:%d\n",
                __func__, pFoundHdl->m_wComConIdx);
        EplRet = EplApiPostUserEvent((void*) pFoundHdl);
        if (EplRet != kEplSuccessful)
        {
            DEBUG_TRACE1 (DEBUG_LVL_ERROR, "%s() Post user event failed!\n",
                                  __func__);
            goto Exit;
        }
    }
    else
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() Nothing to post!\n", __func__);
        EplRet = kEplSuccessful; // nothing to post, thats fine
    }

Exit:
    DEBUG_TRACE0 (DEBUG_LVL_15, "<--- Segment finished callback!\n\n");
    if (EplRet != kEplSuccessful)
    {
        iRet = ERROR;
    }
    return iRet;
}

/**
********************************************************************************
\brief     write to domain object which is not in object dictionary

This function writes to an object which does not exist in the local object
dictionary by using segmented access (to domain object)

\param  pDefObdAccHdl_p             pointer to default OBD access for segmented
                                    access
\param  pfnSegmentFinishedCb_p      pointer to finished callback function
\param  pfnSegmentAbortCb_p         pointer to abort callback function

\retval tEplKernel value
*******************************************************************************/
static tEplKernel EplAppDefObdAccAdoptedHstryWriteSegm(
                                        tObdAccHstryEntry * pDefObdAccHdl_p,
                                        void * pfnSegmentFinishedCb_p,
                                        void * pfnSegmentAbortCb_p)
{
    tEplKernel Ret = kEplSuccessful;
    int iRet = OK;

    if (pDefObdAccHdl_p == NULL)
    {
        return kEplApiInvalidParam;
    }

    pDefObdAccHdl_p->m_Status = kEplObdDefAccHdlInUse;

    switch (pDefObdAccHdl_p->m_ObdParam.m_uiIndex)
    {
        case 0x1F50:
            switch (pDefObdAccHdl_p->m_ObdParam.m_uiSubIndex)
            {
                case 0x01:
                    iRet = updateFirmware(
                              pDefObdAccHdl_p->m_ObdParam.m_SegmentOffset,
                              pDefObdAccHdl_p->m_ObdParam.m_SegmentSize,
                              (void*) pDefObdAccHdl_p->m_ObdParam.m_pData,
                              pfnSegmentAbortCb_p, pfnSegmentFinishedCb_p,
                              (void *)pDefObdAccHdl_p);

                    // TODO: forward AP firmware file part to PDI (in backround loop)

                    if (iRet == kEplSdoComTransferRunning)
                    {
                        EplSdoAsySeqAppFlowControl(TRUE, TRUE);
                    }
                    if (iRet == ERROR)
                    {   //update operation went wrong
                        Ret = kEplObdAccessViolation;
                    }
                    break;

                default:
                    Ret = kEplObdSubindexNotExist;
                    break;
            }
            break;

        default:
            // TODO: forward to PDI (in backround loop)
            break;
    }

    return Ret;
}

/**
 ********************************************************************************
 \brief signals an OBD default access as finished

 This function calls the call-back function assigned by the originator of the
 OBD access and deletes the history entry from the OBD access history.
 The OBD access handle which is returned to the originators call-back function
 is expected to be fully ready for the 'OBD-access-finished' function call.

 \param pObdAccHstEntry_p  pointer to history entry (contains OBD access handle)

 \return tEplKernel value
 *******************************************************************************/
static tEplKernel EplAppDefObdAccAdoptedHstryEntryFinished(tObdAccHstryEntry * pObdAccHstEntry_p)
{
tEplKernel EplRet = kEplSuccessful;
tEplObdParam * pObdParam = &pObdAccHstEntry_p->m_ObdParam;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "INFO: %s(%d) called\n",
            __func__, pObdAccHstEntry_p->m_wComConIdx);

    if ((pObdAccHstEntry_p == NULL)                                 ||
        (pObdAccHstEntry_p->m_ObdParam.m_pfnAccessFinished) == NULL   )
    {
        EplRet = kEplInvalidParam;
        goto Exit;
    }

    // check if it was a segmented write SDO transfer (domain object write access)
    if ((pObdParam->m_ObdEvent == kEplObdEvPreRead)            &&
        (//(pObdParam->m_SegmentSize != pObdParam->m_ObjSize) ||
         //TODO: implement object size in Async message for segmented access
         (pObdParam->m_SegmentOffset != 0)                    )  )
    {
        //segmented read access not allowed!
        pObdParam->m_dwAbortCode = EPL_SDOAC_UNSUPPORTED_ACCESS;
    }

    // call callback function which was assigned by originator
    EplRet = pObdParam->m_pfnAccessFinished(pObdParam);

    EplAppDefObdAccAdoptedHstryDeleteEntry(pObdAccHstEntry_p);

Exit:
    if (EplRet != kEplSuccessful)
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: %s failed!\n", __func__);
    }
    return EplRet;
}

/**
 ********************************************************************************
 \brief cleans the default OBD access history buffers

 This function clears errors from the segmented access history buffer which is
 used for default OBD accesses.
 *******************************************************************************/
void EplAppDefObdAccAdoptedHstryCleanup(void)
{
    tObdAccHstryEntry * pObdDefAccHdl = NULL;
    BYTE            bArrayNum;              // loop counter and array element

    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_ACC_HISTORY_SIZE; bArrayNum++, pObdDefAccHdl++)
    {
        if (pObdDefAccHdl->m_Status == kEplObdDefAccHdlEmpty)
        {
            continue;
        }

        DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() Cleanup handle %p\n", __func__, &pObdDefAccHdl->m_ObdParam);
        pObdDefAccHdl->m_ObdParam.m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;

        // Ignore return value
        EplAppDefObdAccAdoptedHstryEntryFinished(pObdDefAccHdl);
    }
    wObdAccHistorySeqCnt_g = OBD_DEFAULT_ACC_INVALID;
}

/**
 ********************************************************************************
 \brief increments a counter and omits non valid values
 \param pwCounter_p [IN]:  pointer to counter
                    [OUT]: updated counter value
 \return updated counter value
 *******************************************************************************/
static WORD EplAppDefObdAccAdoptedHstryIncrCnt(WORD * pwCounter_p)
{
    (*pwCounter_p)++;

    while((*pwCounter_p == OBD_DEFAULT_ACC_INVALID) ||
          (*pwCounter_p == 0)                         )
    {
        // omit invalid counter values
        (*pwCounter_p)++;
    }

    return *pwCounter_p;
}

/**
********************************************************************************
\brief     get application software date/time of current image

This function reads the application software date and time of the currently
used firmware image.

\param  pUiApplicationSwDate_p      pointer to store application software date
\param  pUiApplicationSwTime_p      pointer to store application software time

\return OK, or ERROR if data couldn't be read
*******************************************************************************/
#ifdef CONFIG_IIB_IS_PRESENT
static tFwRet getImageApplicationSwDateTime(UINT32 *pUiApplicationSwDate_p,
                                  UINT32 *pUiApplicationSwTime_p)
{
    UINT32      uiIibAdrs;

    uiIibAdrs = fIsUserImage_g ? CONFIG_USER_IIB_FLASH_ADRS
                               : CONFIG_FACTORY_IIB_FLASH_ADRS;
    return getApplicationSwDateTime(uiIibAdrs, pUiApplicationSwDate_p,
                                    pUiApplicationSwTime_p);
}

/**
********************************************************************************
\brief     get application software date/time of current image

This function read the software versions of the currently used firmware image.
The version is store at the specific pointer if it is not NULL.

\param pUiFpgaConfigVersion_p   pointer to store FPGA configuration version
\param pUiPcpSwVersion_p        pointer to store the PCP software version
\param pUiApSwVersion_p         pointer to store the AP software version

\return OK, or ERROR if data couldn't be read
*******************************************************************************/
static tFwRet getImageSwVersions(UINT32 *pUiFpgaConfigVersion_p, UINT32 *pUiPcpSwVersion_p,
                       UINT32 *pUiApSwVersion_p)
{
    UINT32      uiIibAdrs;

    uiIibAdrs = fIsUserImage_g ? CONFIG_USER_IIB_FLASH_ADRS
                               : CONFIG_FACTORY_IIB_FLASH_ADRS;

    return getSwVersions(uiIibAdrs, pUiFpgaConfigVersion_p, pUiPcpSwVersion_p,
                         pUiApSwVersion_p);
}
#endif // CONFIG_IIB_IS_PRESENT

#ifdef TEST_OBD_ADOPTABLE_FINISHED_TIMERU
/**
********************************************************************************
\brief  set timer event which trigger some action for testing
\param  pObdParam_p  object access handle
\return tEplKernel
*******************************************************************************/
static tEplKernel SetTimerEventTest(tEplObdParam * pObdParam_p)
{
    tEplKernel Ret = kEplSuccessful;

    // timer event for triggering answer at AP
    TimerArg.m_EventSink = kEplEventSinkApi;
    TimerArg.m_Arg.m_pVal = pObdParam_p;

    if(EplTimerHdl == 0)
    {   // create new timer
        Ret = EplTimeruSetTimerMs(&EplTimerHdl, 100, TimerArg);
    }
    else
    {   // modify exisiting timer
        Ret = EplTimeruModifyTimerMs(&EplTimerHdl, 100, TimerArg);
    }

    if(Ret != kEplSuccessful)
    {
        pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_DUE_LOCAL_CONTROL;
    }

    return Ret;
}
#endif // TEST_OBD_ADOPTABLE_FINISHED_TIMERU

/* EOF */
/*********************************************************************************/
