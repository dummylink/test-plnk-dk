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
#include "pcpAsync.h"
#include "pcpAsyncSm.h"
#include "global.h"

#include "fpgaCfg.h"
#include "fwUpdate.h"

#ifdef __NIOS2__
#include <unistd.h>
#elif defined(__MICROBLAZE__)
#include "xilinx_usleep.h"
#endif

#include "systemComponents.h"

/******************************************************************************/

#include "Epl.h"
#include "EplPdou.h"
#include "EplSdoComu.h"

#include "EplSdo.h"
#include "EplAmi.h"
#include "EplObd.h"
#include "EplTimeru.h"

//---------------------------------------------------------------------------
// defines
//---------------------------------------------------------------------------
#define OBD_DEFAULT_SEG_WRITE_HISTORY_ACK_FINISHED_THLD 3           ///< count of history entries, where 0BD accesses will still be acknowledged
#define OBD_DEFAULT_SEG_WRITE_HISTORY_SIZE              20          ///< maximum possible history elements
#define OBD_DEFAULT_SEG_WRITE_ACC_CNT_INVALID           0xFFFFUL

//---------------------------------------------------------------------------
// module global vars
//---------------------------------------------------------------------------
volatile tPcpCtrlReg *         pCtrlReg_g;     ///< ptr. to PCP control register
tCnApiInitParm     initParm_g = {{0}};        ///< Powerlink initialization parameter
BOOL               fPLisInitalized_g = FALSE; ///< Powerlink initialization after boot-up flag
BOOL               fIsUserImage_g;            ///< if set user image is booted
UINT32             uiFpgaConfigVersion_g = 0; ///< version of currently used FPGA configuration
BOOL               fOperational = FALSE;

static BOOL     fShutdown_l = FALSE;          ///< Powerlink shutdown flag
static tDefObdAccHdl aObdDefAccHdl_l[OBD_DEFAULT_SEG_WRITE_HISTORY_SIZE]; ///< segmented object access management

/* counter of currently empty OBD segmented write history elements for default OBD access */
BYTE bObdSegWriteAccHistoryEmptyCnt_g = OBD_DEFAULT_SEG_WRITE_HISTORY_SIZE;
/* counter of subsequent accesses to an object */
WORD wObdSegWriteAccHistorySeqCnt_g = OBD_DEFAULT_SEG_WRITE_ACC_CNT_INVALID;

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
extern void Gi_pcpEventPost(WORD wEventType_p, WORD wArg_p);

/******************************************************************************/
/* forward declarations */
#if EPL_DLL_SOCTIME_FORWARD == TRUE
    tEplKernel PUBLIC AppCbSync(tEplSocTimeStamp SocTimeStamp_p) INTERNAL_RAM_SIZE_MEDIUM;
#else
    tEplKernel PUBLIC AppCbSync(void);
#endif

tEplKernel PUBLIC AppCbEvent(tEplApiEventType EventType_p,
                             tEplApiEventArg* pEventArg_p,
                             void GENERIC*pUserArg_p);
static int EplAppHandleUserEvent(tEplApiEventArg* pEventArg_p);
static tEplKernel  EplAppCbDefaultObdAccess(tEplObdCbParam MEM* pObdParam_p);
static tEplKernel EplAppDefObdAccSaveHdl(tEplObdParam *  pObdParam_p,
                    tDefObdAccHdl **ppDefHdl_p);
static tEplKernel EplAppDefObdAccGetStatusObdHdl(WORD wIndex_p, WORD wSubIndex_p,
                    tEplObdDefAccStatus ReqStatus_p, BOOL fSearchOldest_p,
                    tDefObdAccHdl **ppDefObdAccHdl_p);
static tEplKernel EplAppDefObdAccGetObdHdl(tEplObdParam * pObdAccParam_p,
                    tDefObdAccHdl **ppDefObdAccHdl_p);
static tEplKernel EplAppDefObdAccWriteObdSegmented(tDefObdAccHdl *pDefObdAccHdl_p,
                    void * pfnSegmentFinishedCb_p, void * pfnSegmentAbortCb_p);
static tEplKernel Gi_forwardObdAccessToPdi(tEplObdParam * pObdParam_p);

#ifdef CONFIG_IIB_IS_PRESENT
static tFwRet getImageApplicationSwDateTime(UINT32 *pUiApplicationSwDate_p,
                                  UINT32 *pUiApplicationSwTime_p);
static tFwRet getImageSwVersions(UINT32 *pUiFpgaConfigVersion_p, UINT32 *pUiPcpSwVersion_p,
                       UINT32 *pUiApSwVersion_p);
#endif // CONFIG_IIB_IS_PRESENT
static void rebootCN(void);

int EplAppDefObdAccWriteSegmentedFinishCb(void * pHandle);
int EplAppDefObdAccWriteSegmentedAbortCb(void * pHandle);

static WORD getPcpState(void);

static void processPowerlink(void);

static int Gi_init(void);
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

                usleep(5000000); // wait 5 seconds

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

                usleep(5000000); // wait 5 seconds

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
            usleep(5000000); // wait 5 seconds

            // reset to factory image
            FpgaCfg_reloadFromFlash(CONFIG_FACTORY_IMAGE_FLASH_ADRS);

            goto exit; // fatal error
            break;
        }

        default:
        {
#ifdef CONFIG_USER_IMAGE_IN_FLASH
            DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "Fatal error after booting! Reset to Factory Image!\n");
            usleep(5000000); // wait 5 seconds

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
*******************************************************************************/
int initPowerlink(tCnApiInitParm *pInitParm_p)
{
    DWORD                       ip = IP_ADDR;      ///< ip address
    static tEplApiInitParam     EplApiInitParam;   ///< epl init parameter
    tEplKernel                  EplRet;
    UINT32                      uiApplicationSwDate = 0;
    UINT32                      uiApplicationSwTime = 0;

    /* check if NodeID has been set to 0x00 by AP -> use node switches */
#ifdef NODE_SWITCH_BASE
    if(pInitParm_p->m_bNodeId == 0x00)
    {   /* read port configuration input pins and overwrite parameter */
        pInitParm_p->m_bNodeId = SysComp_getNodeId();
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
    ip |= pInitParm_p->m_bNodeId;              ///< and mask it with the node id

    /* set EPL init parameters */
    EplApiInitParam.m_uiSizeOfStruct = sizeof (EplApiInitParam);
    EPL_MEMCPY(EplApiInitParam.m_abMacAddress, pInitParm_p->m_abMac,
               sizeof(EplApiInitParam.m_abMacAddress));
    EplApiInitParam.m_uiNodeId = pInitParm_p->m_bNodeId;
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
    EplApiInitParam.m_dwDeviceType = pInitParm_p->m_dwDeviceType;
    EplApiInitParam.m_dwVendorId = pInitParm_p->m_dwVendorId;
    EplApiInitParam.m_dwProductCode = pInitParm_p->m_dwProductCode;
    EplApiInitParam.m_dwRevisionNumber = pInitParm_p->m_dwRevision;
    EplApiInitParam.m_dwSerialNumber = pInitParm_p->m_dwSerialNum;
    //EplApiInitParam.m_dwVerifyConfigurationDate;
    //EplApiInitParam.m_dwVerifyConfigurationTime;
    EplApiInitParam.m_dwApplicationSwDate = uiApplicationSwDate;
    EplApiInitParam.m_dwApplicationSwTime = uiApplicationSwTime;
    EplApiInitParam.m_dwSubnetMask = SUBNET_MASK;
    EplApiInitParam.m_dwDefaultGateway = 0;
    EplApiInitParam.m_pszDevName = pInitParm_p->m_strDevName;
    EplApiInitParam.m_pszHwVersion = pInitParm_p->m_strHwVersion;
    EplApiInitParam.m_pszSwVersion = pInitParm_p->m_strSwVersion;
    EplApiInitParam.m_pfnCbEvent = AppCbEvent;
    EplApiInitParam.m_pfnCbSync  = AppCbSync;
    EplApiInitParam.m_pfnCbTpdoPreCopy = Gi_preparePdiPdoReadAccess;    // PDI buffer treatment
    EplApiInitParam.m_pfnCbRpdoPostCopy = Gi_signalPdiPdoWriteAccess;   // PDI buffer treatment
    EplApiInitParam.m_pfnObdInitRam = EplObdInitRam;
    EplApiInitParam.m_pfnDefaultObdCallback = EplAppCbDefaultObdAccess; // called if objects do not exist in local OBD
    EplApiInitParam.m_pfnRebootCb = rebootCN;

    EplApiInitParam.m_dwSyncResLatency = EPL_C_DLL_T_IFG;

    DEBUG_TRACE1(DEBUG_LVL_09, "INFO: NODE ID is set to 0x%02x\n", EplApiInitParam.m_uiNodeId);

    /* inform AP about current node ID */
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wNodeId, EplApiInitParam.m_uiNodeId);
    Gi_pcpEventPost(kPcpPdiEventGeneric, kPcpGenEventNodeIdConfigured);

    /* initialize firmware update */
    initFirmwareUpdate(pInitParm_p->m_dwProductCode, pInitParm_p->m_dwRevision);

    /* initialize POWERLINK stack */
    DEBUG_TRACE0(DEBUG_LVL_28, "init POWERLINK stack API...\n");
    EplRet = EplApiInitialize(&EplApiInitParam);
    if(EplRet != kEplSuccessful)
    {
        goto Exit;
    }
    else
    {
        fPLisInitalized_g = TRUE;
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
*******************************************************************************/
int startPowerlink(void)
{
    tEplKernel                 EplRet;

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
\brief    process POWERLINK
*******************************************************************************/
static void processPowerlink(void)
{
	SysComp_enableInterrupts();

    while (stateMachineIsRunning())
    {
        /* process Powerlink and it API */
        CnApi_processAsyncStateMachine(); //TODO: Process in User-Callback Event!

        if (fPLisInitalized_g)
        {
            EplApiProcess();
        }

        updateStateMachine();
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
\brief    event callback function called by EPL API layer

AppCbEvent() is the event callback function called by EPL API layer within
the user part (low priority).


\param    EventType_p             event type (IN)
\param    pEventArg_p             pointer to union, which describes the event in
                                detail (IN)
\param    pUserArg_p              user specific argument

\return error code (tEplKernel)
\retval    kEplSuccessful        no error
\retval    kEplReject             reject further processing
\retval    otherwise             post error event to API layer
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
                    setPowerlinkEvent(kPowerlinkEventShutdown);
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
                    setPowerlinkEvent(kPowerlinkEventEnterPreOp);

                    break;
                }

                case kEplNmtCsPreOperational2:
                {

                    setPowerlinkEvent(kPowerlinkEventEnterPreOp);

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
                        setPowerlinkEvent(kPowerlinkEventEnterPreOp);
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

                    // clean all default OBD accesses
                    EplAppDefObdAccCleanupAllPending();

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
                        setPowerlinkEvent(kPowerlinkEventEnterPreOp);
                    }

                    break;
                }

                case kEplNmtCsNotActive:                        ///< indicated only by Led, AP is not informed
                    break;

                case kEplNmtCsOperational:
                    fOperational = TRUE;

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
                    PdiRet = CnApiAsync_postMsg(kPdiAsyncMsgIntLinkPdosReq, 0,0,0);
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
    tDefObdAccHdl * pSegmentHdl;        ///< handle of this segment
    tDefObdAccHdl * pTempHdl;           ///< handle for temporary storage
    //        tEplTimerArg    TimerArg;                ///< timer event posting
    //        tEplTimerHdl    EplTimerHdl;             ///< timer event posting

    // assign user argument
    pObdParam = (tEplObdParam *) pEventArg_p->m_pUserArg;

    DEBUG_TRACE1(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO,
                 "AppCbEvent(kEplApiEventUserDef): (EventArg %p)\n", pObdParam);

    // get segmented OBD access handle

    // if we don't find the segmented obd handle the segment was
    // already finished/aborted. In this case we immediately return.
    EplRet = EplAppDefObdAccGetObdHdl(pObdParam, &pSegmentHdl);
    if (EplRet != kEplSuccessful)
    {   // handle incorrectly assigned. Therefore we abort the segment!
        DEBUG_TRACE2(DEBUG_LVL_ERROR,
                     "%s() ERROR: No segmented access handle assigned for handle %p!\n",
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

    if(pObdParam->m_uiIndex != 0x1F50)
    {   // should not get any other indices
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "%s() invalid object index!\n", __func__);
        return kEplInvalidParam;
    }

    /*------------------------------------------------------------------------*/
    // check if write operation has already started for this object
    EplRet = EplAppDefObdAccGetStatusObdHdl(pObdParam->m_uiIndex,
                                            pObdParam->m_uiSubIndex,
                                            kEplObdDefAccHdlInUse,
                                            FALSE,  // search first
                                            &pTempHdl);
    if (EplRet == kEplSuccessful)
    {   // write operation for this object is already processing
        DEBUG_TRACE3(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO,
                     "%s() Write for object %d(%d) already in progress -> exit\n",
                     __func__, pObdParam->m_uiIndex, pObdParam->m_uiSubIndex);
        // change handle status
        pSegmentHdl->m_Status = kEplObdDefAccHdlWaitProcessingQueue;
    }
    else
    {
        switch (pSegmentHdl->m_Status)
        {
            case kEplObdDefAccHdlWaitProcessingInit:
            case kEplObdDefAccHdlWaitProcessingQueue:
                // segment has not been processed yet -> do a initialize writing

                // change handle status
                pSegmentHdl->m_Status = kEplObdDefAccHdlWaitProcessingQueue;

                /* search for oldest handle where m_pfnAccessFinished call is
                 * still due. As we know that we find at least our own handle,
                 * we don't have to take care of the return value! (Assuming
                 * there is no software error :) */
                EplAppDefObdAccGetStatusObdHdl(pObdParam->m_uiIndex,
                        pObdParam->m_uiSubIndex,
                        kEplObdDefAccHdlWaitProcessingQueue,
                        TRUE,           // find oldest
                        &pTempHdl);

                DEBUG_TRACE4(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() Check for oldest handle. EventHdl:%p Oldest:%p (Seq:%d)\n",
                             __func__, pObdParam, pSegmentHdl->m_pObdParam,
                             pSegmentHdl->m_wSeqCnt);

                if (pTempHdl->m_pObdParam == pObdParam)
                {   // this is the oldest handle so we do the write
                    EplRet = EplAppDefObdAccWriteObdSegmented(pSegmentHdl,
                                     EplAppDefObdAccWriteSegmentedFinishCb,
                                     EplAppDefObdAccWriteSegmentedAbortCb);
                }
                else
                {
                    // it is not the oldest handle so we do nothing
                    EplRet = kEplSuccessful;
                }
                break;

            case kEplObdDefAccHdlProcessingFinished:
                // go on with acknowledging finished segments
                DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO,
                        "%s() Handle Processing finished 0x%p\n", __func__,
                        pSegmentHdl->m_pObdParam);
                EplRet = kEplSuccessful;
                break;

            case kEplObdDefAccHdlError:
            default:
                // all other not handled cases are not allowed -> error
                DEBUG_TRACE2(DEBUG_LVL_ERROR, "%s() ERROR: Invalid handle status %d!\n",
                        __func__, pSegmentHdl->m_Status);
                // do ordinary SDO sequence processing / reset flow control manipulation
                EplSdoAsySeqAppFlowControl(0, FALSE);
                // Abort all not empty handles of segmented transfer
                EplAppDefObdAccCleanupHistory();
                EplRet = kEplSuccessful;
                break;
        } // switch (pSegmentHdl->m_Status)
    } /* else -- handle already in progress */

    return EplRet;
}

/**
 ********************************************************************************
 \brief deletes all pending default OBD accesses

 This function clears all allocated memory used for default OBD accesses and
 resets the OBD default access instance
 *******************************************************************************/
void EplAppDefObdAccCleanupAllPending(void)
{
    // clean domain OBD access history buffers
    EplAppDefObdAccCleanupHistory(); // ignore return value

    // clean forwarded OBD accesses
    if (ApiPdiComInstance_g.apObdParam_m[0] != 0)
    {
        //TODO: for loop to reset array
        EPL_FREE(ApiPdiComInstance_g.apObdParam_m[0]);
        ApiPdiComInstance_g.apObdParam_m[0]= NULL;
    }

    // TODO: reset PDI communication
    //memset(&ApiPdiComInstance_g, 0x00, sizeof(ApiPdiComInstance_g));
}

/**
 ********************************************************************************
 \brief cleans the default OBD access history buffers

 This function clears errors from the segmented access history buffer which is
 used for default OBD accesses.
 *******************************************************************************/
void EplAppDefObdAccCleanupHistory(void)
{
    tDefObdAccHdl * pObdDefAccHdl = NULL;
    BYTE            bArrayNum;                 ///< loop counter and array element

    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_SEG_WRITE_HISTORY_SIZE; bArrayNum++, pObdDefAccHdl++)
    {
        if (pObdDefAccHdl->m_Status == kEplObdDefAccHdlEmpty)
        {
            continue;
        }

        DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() Cleanup handle %p\n", __func__, pObdDefAccHdl->m_pObdParam);
        pObdDefAccHdl->m_pObdParam->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;

        // Ignore return value
        EplAppDefObdAccFinished(&pObdDefAccHdl->m_pObdParam);

        // reset history status and access counter
        pObdDefAccHdl->m_Status = kEplObdDefAccHdlEmpty;
        pObdDefAccHdl->m_wSeqCnt = OBD_DEFAULT_SEG_WRITE_ACC_CNT_INVALID;

        bObdSegWriteAccHistoryEmptyCnt_g++;
    }
    wObdSegWriteAccHistorySeqCnt_g = OBD_DEFAULT_SEG_WRITE_ACC_CNT_INVALID;
}

/**
 ********************************************************************************
 \brief signals an OBD default access as finished

 \param pObdParam_p     pointer to OBD access struct pointer

 \return tEplKernel value
 *******************************************************************************/
tEplKernel EplAppDefObdAccFinished(tEplObdParam ** pObdParam_p)
{
tEplKernel EplRet = kEplSuccessful;
tEplObdParam * pObdParam = NULL;

    pObdParam = *pObdParam_p;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "INFO: %s(%p) called\n", __func__, pObdParam);

    if (pObdParam_p == NULL                   ||
        pObdParam == NULL                     ||
        pObdParam->m_pfnAccessFinished == NULL  )
    {
        EplRet = kEplInvalidParam;
        goto Exit;
    }

    // check if it was a segmented write SDO transfer (domain object write access)
    if ((pObdParam->m_ObdEvent == kEplObdEvPreRead)            &&
        (//(pObdParam->m_SegmentSize != pObdParam->m_ObjSize) || //TODO: implement object size in Async message
         (pObdParam->m_SegmentOffset != 0)                    )  )
    {
        //segmented read access not allowed!
        pObdParam->m_dwAbortCode = EPL_SDOAC_UNSUPPORTED_ACCESS;
    }

    // call callback function which was assigned by caller
    EplRet = pObdParam->m_pfnAccessFinished(pObdParam);

    if ((pObdParam->m_uiIndex < 0x2000)               && //TODO: handle all segemented write transfers
        (pObdParam->m_Type == kEplObdTypDomain)         &&
        (pObdParam->m_ObdEvent == kEplObdEvInitWriteLe)   )
    {   // free allocated memory for segmented write transfer history

        if (pObdParam->m_pData != NULL)
        {
            EPL_FREE(pObdParam->m_pData);
            pObdParam->m_pData = NULL;
        }
        else
        {   //allocation expected, but not present!
            EplRet = kEplInvalidParam;
        }
    }

    EplRet = EplObduDelete0bdAccHdl(pObdParam_p);

Exit:
    if (EplRet != kEplSuccessful)
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: %s failed!\n", __func__);
    }
    return EplRet;

}

/**
********************************************************************************
\brief    sync event callback function called by event module

AppCbSync() implements the event callback function called by event module
within kernel part (high priority). This function sets the outputs, reads the
inputs and runs the control loop.

\return    error code (tEplKernel)

\retval    kEplSuccessful            no error
\retval    otherwise                post error event to API layer
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

                EplRet = Gi_setRelativeTime(SocTimeStamp_p.m_qwRelTime,SocTimeStamp_p.m_fSocRelTimeValid, fOperational);

            #else
                /* Sync interrupt is generated in SW */
                Gi_generateSyncInt();
            #endif  //TIMESYNC_HW
#else
            #ifdef TIMESYNC_HW
                /* Sync interrupt is generated in HW */
                EplRet = Gi_setRelativeTime(0,FALSE, fOperational);
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
    // pCtrlReg_g->m_dwMagic and pCtrlReg_g->m_wPcpPdiRev are set by the Powerlink IP-core.
    // The FPGA internal memory initialization sets the following values:
    // pCtrlReg_g->m_wState: 0x00EE
    // pCtrlReg_g->m_wCommand: 0xFFFF
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwAppDate, uiApplicationSwDate);
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwAppTime, uiApplicationSwTime);
    AmiSetDwordToLe((BYTE*)&pCtrlReg_g->m_dwFpgaSysId, FPGA_SYSTEM_ID);    // FPGA system ID from system.h
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventType, 0x00);                // invalid event TODO: structure
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wEventArg, 0x00);                 // invalid event argument TODO: structure
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wState, kPcpStateInvalid);        // set invalid PCP state

    // init time sync module
    Gi_initSync();

    // start PCP API state machine
    activateStateMachine();

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

    // init event fifo queue
    Gi_pcpEventFifoInit();

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
\brief  assign data type in a obd access handle

\param  pObdParam_p     Pointer to obd access handle
*******************************************************************************/
static void EplAppCbDefaultObdAssignDatatype(tEplObdParam *pObdParam_p)
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
            //TODO: check maximum segment offset
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
static tEplKernel EplAppCbDefaultObdInitWriteLe(tEplObdParam *pObdParam_p)
{
    tEplObdParam *   pAllocObdParam = NULL; ///< pointer to allocated memory of OBD access handle
    BYTE *           pAllocDataBuf;         ///< pointer to object data buffer
    tEplKernel       Ret = kEplSuccessful;
    tDefObdAccHdl *  pDefObdHdl;

    // do not return kEplSuccessful in this case,
    // only error or kEplObdAccessAdopted is allowed!

    // verify caller - if it is local, then write access to read only object is fine
    if (pObdParam_p->m_pRemoteAddress != NULL)
    {   // remote access via SDO
        // if it is a read only object -> refuse SDO access
        if (pObdParam_p->m_Access == kEplObdAccR)
        {
            Ret = kEplObdWriteViolation;
            pObdParam_p->m_dwAbortCode = EPL_SDOAC_WRITE_TO_READ_ONLY_OBJ;
            goto Exit;
        }
    }

    // Note SDO: Only a "history segment block" can be delayed, but not single segments!
    //           Client will send Ack Request after sending a history block, so we don't need to
    //           send an Ack immediately after first received frame.

    // verify if caller has assigned a callback function
    if (pObdParam_p->m_pfnAccessFinished == NULL)
    {
        if (pObdParam_p->m_pRemoteAddress != NULL)
        {   // remote access via SDO
            pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
            Ret = kEplObdAccessViolation;
        }
        else
        {
            // ignore all other originators than SDO (for now)
            // workaround: do not return error because EplApiLinkObject() calls this function,
            // but object access is not really necessary

            /* TODO jba: if we exit here we return successfull which shouldn't be according to
               comment at beginning of function */
        }
        goto Exit;
    }

    // different pre-access verification for all write objects (previous to handle storing)
    switch (pObdParam_p->m_uiIndex)
    {
        //case 0x1010:
        //case 0x1011:
        //    break;

        default:
            if(pObdParam_p->m_uiIndex >= 0x2000)
            {   // check if forwarding object access request to AP is possible

                // check if empty ApiPdi connection handles are available
                if (ApiPdiComInstance_g.apObdParam_m[0] != NULL)
                {
                    Ret = kEplObdOutOfMemory;
                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
                    goto Exit;
                }
                break;
            }
            else
            {   // all remaining local PCP objects

                // TODO: introduce counter to recognize memory leaks / to much allocated memory
                // or use static storage

                // forward "pAllocObdParam" which has to be returned in callback,
                // so callback can access the Obd-access handle and SDO communication handle
                if (pObdParam_p->m_Type == kEplObdTypDomain)
                {
                    // if it is an initial segment, check if this object is already accessed
                    if (pObdParam_p->m_SegmentOffset == 0)
                    {   // inital segment

                        // history has to be completely empty for new segmented write transfer
                        // only one segmented transfer at once is allowed!
                        if (bObdSegWriteAccHistoryEmptyCnt_g < OBD_DEFAULT_SEG_WRITE_HISTORY_SIZE)
                        {
                            Ret = kEplObdOutOfMemory;
                            pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
                            goto Exit;
                        }

                        // reset object segment access counter
                        wObdSegWriteAccHistorySeqCnt_g = OBD_DEFAULT_SEG_WRITE_ACC_CNT_INVALID;
                    }
                    else
                    {
                        // Don't accept following segments if transfer is not started or aborted
                        if (wObdSegWriteAccHistorySeqCnt_g == OBD_DEFAULT_SEG_WRITE_ACC_CNT_INVALID)
                        {
                            Ret = kEplObdOutOfMemory;
                            pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
                            goto Exit;
                        }
                    }
                }
                else
                {   // non domain object
                    // should be handled in the switch-cases above, not in the default case
                }

                break;
            } // else -> all remaining objects
    } // end of switch (pObdParam_p->m_uiIndex)

    // allocate memory for handle
    pAllocObdParam = EPL_MALLOC(sizeof (*pAllocObdParam));
    if (pAllocObdParam == NULL)
    {
        Ret = kEplObdOutOfMemory;
        pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
        goto Exit;
    }

    EPL_MEMCPY(pAllocObdParam, pObdParam_p, sizeof (*pAllocObdParam));

    // different treatment for all write objects (after handle storing)
    switch (pObdParam_p->m_uiIndex)
    {
        //case 0x1010:
        //case 0x1011:
        //    break;

        default:
        {
            if(pObdParam_p->m_uiIndex >= 0x2000)
            { // forward object access request to AP

                // save handle for callback function
                ApiPdiComInstance_g.apObdParam_m[0] = pAllocObdParam; //TODO: handle index, not a single pointer variable

                DEBUG_TRACE1(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "pApiPdiComInstance_g: %p\n", ApiPdiComInstance_g.apObdParam_m[0]);

                // forward SDO transfers of application specific objects to AP
                if (pObdParam_p->m_pRemoteAddress != NULL)
                {   // remote access via SDO

                    Ret = Gi_forwardObdAccessToPdi(pObdParam_p);
                    if (Ret != kEplSuccessful)
                    {
                        goto Exit;
                    }

#ifdef TEST_OBD_ADOPTABLE_FINISHED_TIMERU
                    // timer event for triggering answer at AP
                    TimerArg.m_EventSink = kEplEventSinkApi;
                    TimerArg.m_Arg.m_pVal = pAllocObdParam;

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
                        EPL_FREE(pAllocObdParam);
                        goto Exit;
                    }
#endif // TEST_OBD_ADOPTABLE_FINISHED_TIMERU
                } // end if (pObdParam_p->m_pRemoteAddress != NULL)
                break;
            }
            else
            {   // all remaining local PCP objects
                if (pObdParam_p->m_Type == kEplObdTypDomain)
                {
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
                    Ret = EplAppDefObdAccSaveHdl(pAllocObdParam, &pDefObdHdl);
                    DEBUG_TRACE1(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "New SDO History Empty Cnt: %d\n", bObdSegWriteAccHistoryEmptyCnt_g);
                    if (Ret != kEplSuccessful)
                    {
                        EPL_FREE(pAllocObdParam);
                        goto Exit;
                    }
                    // trigger write operation (in AppEventCb)
                    Ret = EplApiPostUserEvent((void*) pAllocObdParam);
                    if (Ret != kEplSuccessful)
                    {
                        goto Exit;
                    }
                }
                else
                {   // non domain objects
                    // should be handled in the switch-cases above, not in the default case
                }
            }
            break;
        }
    } /* switch (pObdParam_p->m_uiIndex) */

    // test output //TODO: delete
    //            EplAppDumpData(pObdParam_p->m_pData, pObdParam_p->m_SegmentSize);

    // adopt write access
    Ret = kEplObdAccessAdopted;
    DEBUG_TRACE0(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, " Adopted\n");

Exit:
    return Ret;
}

/**
********************************************************************************
\brief  pre-read checking for default object callback function

\param      pObdParam_p     pointer to object handle

\return     kEplObdAccessAdopted or kEplObdSegmentReturned
*******************************************************************************/
static tEplKernel EplAppCbDefaultObdPreRead(tEplObdParam *pObdParam_p)
{
    tEplObdParam *   pAllocObdParam = NULL; ///< pointer to allocated memory of OBD access handle
    tEplKernel       Ret = kEplSuccessful;

    // do not return kEplSuccessful in this case,
    // only error or kEplObdAccessAdopted or kEplObdSegmentReturned is allowed!

    // Note: kEplObdAccessAdopted can only be returned for expedited (non-fragmented) reads!
    // Adopted access is not yet implemented for segmented kEplObdEvPreRead.
    // Thus, kEplObdSegmentReturned has to be returned in this case! This requires immediate access to
    // the read source data right from this function.

    //TODO: block all transfers of same index/subindex which are already processing

    // verify if caller has assigned a callback function
    if (pObdParam_p->m_pfnAccessFinished == NULL)
    {
        if (pObdParam_p->m_pRemoteAddress != NULL)
        {   // remote access via SDO
            pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
            Ret = kEplObdAccessViolation;
        }
        else
        {
            // ignore all other originators than SDO (for now)
            // workaround: do not return error because EplApiLinkObject() calls this function,
            // but object access is not really necessary

            /* TODO jba: if we exit here we return successfull which shouldn't be according to
               comment at beginning of function */
        }
        goto Exit;
    }

    // different pre-access verification for all read objects (previous to handle storing)
    switch (pObdParam_p->m_uiIndex)
    {
        //case 0x1010:
        //case 0x1011:
        //    break;

        case 0x1F50:
            break;

        default:
            if(pObdParam_p->m_uiIndex >= 0x2000)
            {   // check if forwarding object access request to AP is possible

                // check if empty ApiPdi connection handles are available
                if (ApiPdiComInstance_g.apObdParam_m[0] != NULL)
                {
                    Ret = kEplObdOutOfMemory;
                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
                    goto Exit;
                }
                break;
            }
            else
            {   // local objects at PCP
                // should be handled in the switch-cases above, not in the default case
            }

            break;
    }

    // allocate memory for handle
    pAllocObdParam = EPL_MALLOC(sizeof (*pAllocObdParam));
    if (pAllocObdParam == NULL)
    {
        Ret = kEplObdOutOfMemory;
        pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
        goto Exit;
    }

    EPL_MEMCPY(pAllocObdParam, pObdParam_p, sizeof (*pAllocObdParam));

    // different treatment for all read objects (after handle storing)
    switch (pObdParam_p->m_uiIndex)
    {
        //case 0x1010:
        //case 0x1011:
        //    break;

        case 0x1F50:
            break;

        default:
            if(pObdParam_p->m_uiIndex >= 0x2000)
            { // forward object access request to AP

                // save handle for callback function
                ApiPdiComInstance_g.apObdParam_m[0] = pAllocObdParam; //TODO: handle index, not a single pointer variable

                DEBUG_TRACE1(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "pApiPdiComInstance_g: %p\n",
                             ApiPdiComInstance_g.apObdParam_m[0]);

                // forward SDO transfers of application specific objects to AP
                if (pObdParam_p->m_pRemoteAddress != NULL)
                {   // remote access via SDO

                    Ret = Gi_forwardObdAccessToPdi(pObdParam_p);
                    if (Ret != kEplSuccessful)
                    {
                        goto Exit;
                    }

#ifdef TEST_OBD_ADOPTABLE_FINISHED_TIMERU
                    // timer event for triggering answer at AP
                    TimerArg.m_EventSink = kEplEventSinkApi;
                    TimerArg.m_Arg.m_pVal = pAllocObdParam;

                    if(EplTimerHdl == 0)
                    {   // create new timer
                        Ret = EplTimeruSetTimerMs(&EplTimerHdl,
                                                    100,
                                                    TimerArg);
                    }
                    else
                    {   // modify exisiting timer
                        Ret = EplTimeruModifyTimerMs(&EplTimerHdl,
                                                    100,
                                                    TimerArg);
                    }
                    if(Ret != kEplSuccessful)
                    {
                        pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_DUE_LOCAL_CONTROL;
                        EPL_FREE(pAllocObdParam);
                        goto Exit;
                    }
#endif // TEST_OBD_ADOPTABLE_FINISHED_TIMERU

                } // end if (pObdParam_p->m_pRemoteAddress != NULL)
                break;
            }
            else
            {   // local objects at PCP
                // should be handled in the switch-cases above, not in the default case
            }
            break;
    }

    // adopt read access
    Ret = kEplObdAccessAdopted;
    DEBUG_TRACE0(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "  Adopted\n");

Exit:
    return Ret;
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

    if (pObdParam_p->m_pRemoteAddress != NULL)
    {   // remote access via SDO
        // DEBUG_TRACE1(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "Remote OBD access from %d\n", pObdParam_p->m_pRemoteAddress->m_uiNodeId);
    }

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
    } /* switch (pObdParam_p->m_uiIndex) */

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
\brief searches for free storage of OBD access handle and saves it

\param pObdParam_p     pointer to OBD handle
\param ppDefHdl_p      pointer to store pointer of segmented transfer handle

\retval kEplSuccessful if element was successfully assigned
\retval kEplObdOutOfMemory if no free element is left
\retval kEplApiInvalidParam if wrong parameter passed to this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccSaveHdl(tEplObdParam * pObdParam_p, tDefObdAccHdl **ppDefHdl_p)
{
    tDefObdAccHdl * pObdDefAccHdl = NULL;
    BYTE bArrayNum;                 ///< loop counter and array element

    // check for wrong parameter values
    if (pObdParam_p == NULL)
    {
        return kEplApiInvalidParam;
    }

    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_SEG_WRITE_HISTORY_SIZE; bArrayNum++, pObdDefAccHdl++)
    {
        if (pObdDefAccHdl->m_Status == kEplObdDefAccHdlEmpty)
        {
            *ppDefHdl_p = pObdDefAccHdl;

            // free storage found -> assign OBD access handle
            pObdDefAccHdl->m_pObdParam = pObdParam_p;
            pObdDefAccHdl->m_Status = kEplObdDefAccHdlWaitProcessingInit;
            pObdDefAccHdl->m_wSeqCnt = ++wObdSegWriteAccHistorySeqCnt_g;
            bObdSegWriteAccHistoryEmptyCnt_g--;

            // check if segmented write history is full (flow control for SDO)
            if (bObdSegWriteAccHistoryEmptyCnt_g < OBD_DEFAULT_SEG_WRITE_HISTORY_SIZE - OBD_DEFAULT_SEG_WRITE_HISTORY_ACK_FINISHED_THLD)
            {
                // prevent SDO from ack the last received frame
                EplSdoAsySeqAppFlowControl(TRUE, TRUE);
            }
            return kEplSuccessful;
        }
    }

    // no free storage found if we reach here
    pObdDefAccHdl->m_pObdParam->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
    return kEplObdOutOfMemory;
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

\retval kEplSuccessful             if element was found
\retval kEplObdVarEntryNotExist    if no element was found
\retval kEplApiInvalidParam        if wrong parameter passed to this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccGetStatusObdHdl(WORD wIndex_p,
        WORD wSubIndex_p, tEplObdDefAccStatus ReqStatus_p, BOOL fSearchOldest_p,
        tDefObdAccHdl **ppDefObdAccHdl_p)
{
    tEplKernel      Ret;
    tDefObdAccHdl * pObdDefAccHdl = NULL;
    BYTE            bArrayNum;              ///< loop counter and array element

    // check for wrong parameter values
    if (ppDefObdAccHdl_p == NULL)
    {
        return kEplApiInvalidParam;
    }

    Ret = kEplObdVarEntryNotExist;
    *ppDefObdAccHdl_p = NULL;
    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_SEG_WRITE_HISTORY_SIZE;
         bArrayNum++, pObdDefAccHdl++)
    {
        /* check for a valid handle */
        if (pObdDefAccHdl->m_pObdParam == NULL)
        {
            continue;
        }

        // search for index, subindex and status
        if ((pObdDefAccHdl->m_pObdParam->m_uiIndex == wIndex_p)        &&
            (pObdDefAccHdl->m_pObdParam->m_uiSubIndex == wSubIndex_p) &&
            (pObdDefAccHdl->m_wSeqCnt != OBD_DEFAULT_SEG_WRITE_ACC_CNT_INVALID) &&
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
 \brief searches for a segmented OBD access handle

This function searches for a segmented OBD access handle. It searches the one
which contains the specified OBD handle pObdAccParam_p.

\param pObdAccParam_p   pointer of object dictionary access to be searched for;
\param ppObdParam_p     IN:  caller provides  target pointer address
                        OUT: address of found element or NULL

\retval kEplSuccessful             if element was found
\retval kEplObdVarEntryNotExist    if no element was found
\retval kEplApiInvalidParam        if wrong parameter passed to this function
*******************************************************************************/
static tEplKernel EplAppDefObdAccGetObdHdl(tEplObdParam * pObdAccParam_p,
                                            tDefObdAccHdl **ppDefObdAccHdl_p)
{
    tEplKernel      Ret;
    tDefObdAccHdl * pObdDefAccHdl = NULL;
    BYTE            bArrayNum;                 ///< loop counter and array element

    // check for wrong parameter values
    if (ppDefObdAccHdl_p == NULL)
    {
        return kEplApiInvalidParam;
    }

    Ret = kEplObdVarEntryNotExist;
    *ppDefObdAccHdl_p = NULL;
    pObdDefAccHdl = aObdDefAccHdl_l;

    for (bArrayNum = 0; bArrayNum < OBD_DEFAULT_SEG_WRITE_HISTORY_SIZE;
         bArrayNum++, pObdDefAccHdl++)
    {
        if (pObdAccParam_p == pObdDefAccHdl->m_pObdParam)
        {
            // assigned found handle
             *ppDefObdAccHdl_p = pObdDefAccHdl;
             Ret = kEplSuccessful;
             break;
        }
    }
    return Ret;
}

/**
********************************************************************************
\brief abort callback function

EplAppDefObdAccWriteSegmentedAbortCb() will be called if a segmented write
transfer should be aborted.

\param  pHandle         pointer to default object access handle

\returns OK, or ERROR if event posting failed
*******************************************************************************/
int EplAppDefObdAccWriteSegmentedAbortCb(void * pHandle)
{
    int                 iRet = OK;
    tDefObdAccHdl *     pDefObdHdl;

    pDefObdHdl = (tDefObdAccHdl *)pHandle;

    // Disable flow control
    EplSdoAsySeqAppFlowControl(0, FALSE);

    // Abort all not empty handles of segmented transfer
    EplAppDefObdAccCleanupHistory();

    DEBUG_TRACE1 (DEBUG_LVL_15, "<--- Abort callback Handle:%p!\n\n",
            pDefObdHdl->m_pObdParam);

    return iRet;
}

/**
********************************************************************************
\brief segment finished callback function

EplAppDefObdAccWriteSegmentedFinishCb() will be called if a segmented write
transfer is finished.

\param  pHandle         pointer to OBD handle

\return OK or ERROR if something went wrong
*******************************************************************************/
int EplAppDefObdAccWriteSegmentedFinishCb(void * pHandle)
{
    int                 iRet = OK;
    tDefObdAccHdl *     pDefObdHdl = (tDefObdAccHdl *)pHandle;
    tDefObdAccHdl *     pFoundHdl;
    tEplKernel          EplRet = kEplSuccessful;
    WORD                wIndex;
    WORD                wSubIndex;

    DEBUG_TRACE3 (DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() OBD ACC Hdl:%p cnt processed: %d\n", __func__,
                 pDefObdHdl->m_pObdParam, pDefObdHdl->m_wSeqCnt);

    pDefObdHdl->m_Status = kEplObdDefAccHdlProcessingFinished;

    wIndex = pDefObdHdl->m_pObdParam->m_uiIndex;
    wSubIndex = pDefObdHdl->m_pObdParam->m_uiSubIndex;

    // signal "OBD access finished" to originator

    // this triggers an Ack of the last received SDO sequence in case of remote access
    EplRet = EplAppDefObdAccFinished(&pDefObdHdl->m_pObdParam);

    // correct history status
    pDefObdHdl->m_Status = kEplObdDefAccHdlEmpty;
    pDefObdHdl->m_wSeqCnt = OBD_DEFAULT_SEG_WRITE_ACC_CNT_INVALID;
    bObdSegWriteAccHistoryEmptyCnt_g++;
    DEBUG_TRACE1(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "New SDO History Empty Cnt: %d\n",
                 bObdSegWriteAccHistoryEmptyCnt_g);

    if (EplRet != kEplSuccessful)
    {
        DEBUG_TRACE1 (DEBUG_LVL_ERROR, "%s() EplAppDefObdAccFinished failed!\n",
                      __func__);
        goto Exit;
    }

    // check if segmented write history is empty enough to disable flow control
    if (bObdSegWriteAccHistoryEmptyCnt_g >=
        OBD_DEFAULT_SEG_WRITE_HISTORY_SIZE - OBD_DEFAULT_SEG_WRITE_HISTORY_ACK_FINISHED_THLD)
    {
        // do ordinary SDO sequence processing / reset flow control manipulation
        EplSdoAsySeqAppFlowControl(0, FALSE);
    }

    EplRet = EplAppDefObdAccGetStatusObdHdl(wIndex, wSubIndex,
            kEplObdDefAccHdlWaitProcessingQueue, TRUE, &pFoundHdl);
    if (EplRet == kEplSuccessful)
    {
        // handle found
        DEBUG_TRACE3 (DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO, "%s() RePost Event: Hdl:%p SeqNr: %d\n",
                __func__,
                pFoundHdl->m_pObdParam,
                pFoundHdl->m_wSeqCnt);
        EplRet = EplApiPostUserEvent((void*) pFoundHdl->m_pObdParam);
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
static tEplKernel EplAppDefObdAccWriteObdSegmented(tDefObdAccHdl * pDefObdAccHdl_p,
        void * pfnSegmentFinishedCb_p, void * pfnSegmentAbortCb_p)
{
    tEplKernel Ret = kEplSuccessful;
    int iRet = OK;

    if (pDefObdAccHdl_p == NULL)
    {
        return kEplApiInvalidParam;
    }

    pDefObdAccHdl_p->m_Status = kEplObdDefAccHdlInUse;

    switch (pDefObdAccHdl_p->m_pObdParam->m_uiIndex)
    {
        case 0x1F50:
            switch (pDefObdAccHdl_p->m_pObdParam->m_uiSubIndex)
            {
                case 0x01:
                    iRet = updateFirmware(
                              pDefObdAccHdl_p->m_pObdParam->m_SegmentOffset,
                              pDefObdAccHdl_p->m_pObdParam->m_SegmentSize,
                              (void*) pDefObdAccHdl_p->m_pObdParam->m_pData,
                              pfnSegmentAbortCb_p, pfnSegmentFinishedCb_p,
                              (void *)pDefObdAccHdl_p);

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
            break;
    }

    return Ret;
}

/**
 ********************************************************************************
 \brief forwards an object access to an Application Processor (AP)
 \param pObdParam_p     object access handle of object to be forwarded
 \retval kEplSuccessful forwarding  succeeded
 \retval kEplSdoSeqConnectionBusy   forwarding aborted because no resources
                                    are available to send a message to AP
 \retval kEplInvalidOperation       general error

 This function posts an asynchronous message to the AP which contains an object
 access request. In case of an error this function modifies the abort code of
 the input parameter pObdParam_p.

 *******************************************************************************/
static tEplKernel Gi_forwardObdAccessToPdi(tEplObdParam * pObdParam_p)
{
    tPdiAsyncStatus PdiRet = kPdiAsyncStatusSuccessful;
    tEplKernel Ret = kEplSuccessful;
    tObjAccSdoComCon PdiObjAccCon;

    PdiObjAccCon.m_wSdoSeqConHdl = 0xFF;///< SDO command layer connection handle number //TODO: implement handle index
    PdiObjAccCon.m_pSdoCmdFrame = pObdParam_p->m_pRemoteAddress->m_le_pSdoCmdFrame; ///< assign to SDO command frame
    PdiObjAccCon.m_uiSizeOfFrame = offsetof(tEplAsySdoCom , m_le_abCommandData) + pObdParam_p->m_pRemoteAddress->m_le_pSdoCmdFrame->m_le_wSegmentSize;  ///< size of SDO command frame

    PdiRet = CnApiAsync_postMsg(
                    kPdiAsyncMsgIntObjAccReq,
                    (BYTE *) &PdiObjAccCon,
                    Gi_ObdAccessSrcPdiFinished,
                    0);

    if (PdiRet == kPdiAsyncStatusRetry)
    {
        Ret = kEplSdoSeqConnectionBusy;
        pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_DUE_LOCAL_CONTROL;
        goto Exit;
    }
    else if (PdiRet != kPdiAsyncStatusSuccessful)
    {
        DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: CnApiAsync_postMsg() retval 0x%x\n", PdiRet);
        pObdParam_p->m_dwAbortCode = EPL_SDOAC_GENERAL_ERROR;

        Ret = kEplInvalidOperation;
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
tPdiAsyncStatus Gi_ObdAccessSrcPdiFinished (tPdiAsyncMsgDescr * pMsgDescr_p)
{
tPdiAsyncStatus     Ret = kPdiAsyncStatusSuccessful;
tEplKernel          EplRet;

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
        // if no abort code is present, assign one
        if (ApiPdiComInstance_g.apObdParam_m[0]->m_dwAbortCode == 0)
        {
            ApiPdiComInstance_g.apObdParam_m[0]->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_DUE_LOCAL_CONTROL;
        }

        // cleanup failed OBD Access    // TODO: search handle index
        EplRet = EplAppDefObdAccFinished(&ApiPdiComInstance_g.apObdParam_m[0]);
        if (EplRet != kEplSuccessful)
        {
            Ret = kPdiAsyncStatusInvalidOperation;
            goto exit;
        }
    }

exit:
    return Ret;
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

/* EOF */
/*********************************************************************************/
