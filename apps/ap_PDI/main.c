/**
********************************************************************************
\file       main.c

\brief      Main module of Digital I/O CN application

\mainpage
This file contains of the application of the Digital I/O Interface which is
running on the application processor (AP).
It uses the CN API to connect to a second processor which is running the
openPOWERLINK stack (PCP).

The application demonstrates the usage of the CN API to implement an POWERLINK
CN. The application uses the CN API to transfer data to/from the PCP through
a dual ported RAM (DPRAM) area.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include <cnApi.h>
#include <string.h>

#include "systemComponents.h"



/******************************************************************************/
/* defines */

/*----------------------------------------------------------------------------*/
/* USER OPTIONS */

/* If node Id switches are connected to the PCP, this value must be 0x00! */
#define DEFAULT_NODEID      0x00    ///< default node ID to use, should be NOT 0xF0 (=MN)

//#define USE_POLLING_MODE_SYNC ///< comment this out to enable the sync event interrupt
#define USE_POLLING_MODE_ASYNC ///< comment this out to enable the async event interrupt

#if defined(CN_API_INT_AVALON) && !defined(USE_POLLING_MODE_ASYNC)
    #error "Dual-Nios design can not use 2 interrupts -> interrupt mode for events is not possible!"
#endif

#define DEMO_VENDOR_ID      0x00000000                          ///< The vendor id of this demo
#define DEMO_PRODUCT_CODE   0                                   ///< The product code of this demo
#define DEMO_REVISION       0x00010020                          ///< B & R firmware file generation tool supports only 0..999 dec.
#define DEMO_SERIAL_NUMBER  0x00000000
#define DEMO_DEVICE_NAME "POWERLINK CN DEMO"
#define MAC_ADDR    0x00, 0x12, 0x34, 0x56, 0x78, 0x9A          ///< the MAC address to use for the CN
#define IP_ADDR     0xc0a86401                                  ///< 192.168.100.1 // don't care the last byte!
#define SUBNET_MASK 0xFFFFFF00                                  ///< netmask 255.255.255.0

/*----------------------------------------------------------------------------*/

#define NUM_INPUT_OBJS      4                                   ///< number of used input objects
#define NUM_OUTPUT_OBJS     4                                   ///< number of used output objects
#define NUM_OBJECTS         (NUM_INPUT_OBJS + NUM_OUTPUT_OBJS)  ///< number of objects to be linked to the object dictionary

/******************************************************************************/
/* global variables */
static BYTE     abMacAddr_l[] = { MAC_ADDR };                   ///< The MAC address to be used
static BYTE     strDevName[] = DEMO_DEVICE_NAME;
static BYTE     strHwVersion[] = "1.00";                        ///< Version of the used hardware
static BYTE     strSwVersion[] = "EPL V2 V1.8.1 CNDK";          ///< The version of this software

static BYTE     digitalIn[NUM_INPUT_OBJS];                      ///< The values of the digital input pins of the board will be stored here
static BYTE     digitalOut[NUM_OUTPUT_OBJS];                    ///< The values of the digital output pins of the board will be stored here
static BOOL     fOperational_l = FALSE;                         ///< indicates AP Operation state

// Object access
static DWORD dwExampleData_l = 0xABCD0001;              ///< this is only an example object data
static tCnApiObdParam   ObdParam_l = {0};                 ///< OBD access handle

/******************************************************************************/
/* private functions */
static void workInputOutput(void);
static tCnApiStatus CnApi_AppCbEvent(tCnApiEventType EventType_p,
        tCnApiEventArg * pEventArg_p, void * pUserArg_p);
static tCnApiStatus CnApi_AppCbSync(tCnApiTimeStamp * pTimeStamp_p);
static void CnApi_processObjectAccess(tCnApiObdParam * pObdParam_p);

#ifndef USE_POLLING_MODE_SYNC
    #if defined(__NIOS2__) && !defined(ALT_ENHANCED_INTERRUPT_API_PRESENT)
        static void syncIntHandler(void* pArg_p, void* dwInt_p);
    #else
        static void syncIntHandler(void* pArg_p);
    #endif
#endif //USE_POLLING_MODE_SYNC

#ifndef USE_POLLING_MODE_ASYNC
    #if defined(__NIOS2__) && !defined(ALT_ENHANCED_INTERRUPT_API_PRESENT)
        static void asyncIntHandler(void* pArg_p, void* dwInt_p);
    #else
        static void asyncIntHandler(void* pArg_p);
    #endif
#endif //USE_POLLING_MODE_ASYNC

#ifdef CN_API_USING_SPI
static int CnApi_CbSpiMasterTx(unsigned char *pTxBuf_p, int iBytes_p);
static int CnApi_CbSpiMasterRx(unsigned char *pRxBuf_p, int iBytes_p);

static void enableGlobalInterrupts(void);
static void disableGlobalInterrupts(void);
#endif

static tCnApiObdStatus CnApi_CbDefaultObdAccess(tCnApiObdParam *  pObdParam_p);
tCnApiStatus CnApi_CbPdoDescListings(tCnApiPdoDesc * pPdoDesc_p,
        tCnApiSdoAbortCode * tPdoRespAbortCode_p);

#if VETH_DRV_ENABLE != FALSE
  static tCnApiStatus CnApi_AppCbVethRx(BYTE *pData_p, WORD wDataSize);
  static tCnApiStatus CnApi_AppCbVethTxFinished(tCnApiVethTxStatus eVethTxStatus_p);
#endif

/**
********************************************************************************
\brief    entry function of CN API example

main() implements the main program function of the CN API example.
First all initialization is done, then the program runs in a loop where the
APs state machine will be updated and input/output ports will be processed.

\return int

*******************************************************************************/
int main (void)
{
    tCnApiStatus        status;

    tCnApiInitParam      InitCnApiParam = {0};
    tPcpInitParam        InitPcpParam = {{0}};

    SysComp_initPeripheral();

    SysComp_writeOutputPort(0xabffff); // set hex digits on Mercury-Board to indicate AP presence

    CNAPI_USLEEP(1000000);                                // wait 1 s, so you can see the LEDs

    /* Set initial POWERLINK parameters for the PCP */
    InitPcpParam.m_bNodeId = DEFAULT_NODEID;       // in case you dont want to use Node Id switches, use a different value then 0x00
    CNAPI_MEMCPY(InitPcpParam.m_abMac, abMacAddr_l, sizeof(InitPcpParam.m_abMac));
    InitPcpParam.m_dwDeviceType = -1;
    InitPcpParam.m_dwVendorId = DEMO_VENDOR_ID;
    InitPcpParam.m_dwProductCode = DEMO_PRODUCT_CODE;
    InitPcpParam.m_dwRevision = DEMO_REVISION;
    InitPcpParam.m_dwSerialNum = DEMO_SERIAL_NUMBER;
    CNAPI_MEMCPY(InitPcpParam.m_strDevName, strDevName, sizeof(InitPcpParam.m_strDevName));
    CNAPI_MEMCPY(InitPcpParam.m_strHwVersion, strHwVersion, sizeof(InitPcpParam.m_strHwVersion));
    CNAPI_MEMCPY(InitPcpParam.m_strSwVersion, strSwVersion, sizeof(InitPcpParam.m_strSwVersion));


    /* Set initial libCnApi parameters */
    InitCnApiParam.m_wNumObjects = NUM_OBJECTS;
    InitCnApiParam.m_pDpram = (BYTE *)PDI_DPRAM_BASE_AP;
    InitCnApiParam.m_pfnAppCbSync = CnApi_AppCbSync;
    InitCnApiParam.m_pfnAppCbEvent = CnApi_AppCbEvent;
    InitCnApiParam.m_pfnDefaultObdAccess = CnApi_CbDefaultObdAccess;
    InitCnApiParam.m_pfnPdoDescriptor = NULL; /* Note: Define CnApi_CbPdoDescListings as
                                                       a callback if you want to access
                                                       the PDO descriptor message in the
                                                       application! */
#ifdef CN_API_USING_SPI
    InitCnApiParam.m_SpiMasterTxH = CnApi_CbSpiMasterTx;
    InitCnApiParam.m_SpiMasterRxH = CnApi_CbSpiMasterRx;
    InitCnApiParam.m_pfnEnableGlobalIntH = enableGlobalInterrupts;
    InitCnApiParam.m_pfnDisableGlobalIntH = disableGlobalInterrupts;
#endif
#if VETH_DRV_ENABLE != FALSE
    InitCnApiParam.m_pfnVethRx = CnApi_AppCbVethRx;
    InitCnApiParam.m_pfnVethTxFinished = CnApi_AppCbVethTxFinished;
#endif

    status = CnApi_init(&InitCnApiParam, &InitPcpParam);   // initialize and start the CN API
    if (status > 0)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR,"\nERROR: CN API library could not be initialized (%d)\n", status);
        return ERROR;
    }
    else
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO,"\nInitialize CN API functions...successful!\n");
    }

    /* link objects to local object dictionary */

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

#ifdef USE_POLLING_MODE_SYNC
    CnApi_initSyncInt(0, 0, 0); ///< tell PCP that we want polling mode
    CnApi_disableSyncInt();
#else
    /* initialize PCP interrupt handler*/
    if(SysComp_initSyncInterrupt(syncIntHandler) != OK)    //< local AP IRQ is enabled here
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR: Unable to init the synchronous interrupt!\n");
        return ERROR;
    }

    CnApi_initSyncInt(400, 100000, 0);
    CnApi_disableSyncInt();    //< interrupt will be enabled when CN is operational
#endif /* USE_POLLING_MODE_SYNC */

#ifdef USE_POLLING_MODE_ASYNC
    CnApi_disableAsyncEventIRQ();
#else
    /* initialize Async interrupt handler */
    if(SysComp_initAsyncInterrupt(asyncIntHandler) != OK)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR: Unable to init the asynchronous interrupt!\n");
        return ERROR;
    }

    /* now enable the async interrupt in the pdi */
    CnApi_enableAsyncEventIRQ();
#endif /* USE_POLLING_MODE_ASYNC */

    /* Start periodic main loop */
    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO,"API example is running...\n");

    /* main program loop */
    while (1)
    {
        /* Instead of this while loop, you can use your own (nonblocking) tasks ! */

        /*--- TASK 1: START ---*/
        CnApi_processApStateMachine();     // The AP state machine must be periodically updated

        CnApi_processAsyncStateMachine();

        CnApi_processObjectAccess(&ObdParam_l);
        /*--- TASK 1: END   ---*/

#ifdef USE_POLLING_MODE_SYNC
        /*--- TASK 2: START ---*/
        if (fOperational_l != FALSE)
        {
            CnApi_checkPdo();
        }
        /*--- TASK 2: END   ---*/
#endif /* USE_POLLING_MODE_SYNC */

#ifdef USE_POLLING_MODE_ASYNC
        CnApi_processAsyncEvent();            // check if PCP event occurred
#endif /* USE_POLLING_MODE_ASYNC */

#ifdef CNAPI_VETH_SEND_TEST
        status = CnApi_SendTestVEth();
        if(status == kCnApiStatusMsgBufFull)
        {
            // message buffer full (do nothing!)
        }
        else if (status != kCnApiStatusOk)
        {
            DEBUG_TRACE1(DEBUG_LVL_ERROR, "ERROR: CnApi_sendVeth failed with 0x%02X\n", status);
        }
#endif
    }

    DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO,"shut down application...\n");
    CnApi_disableSyncInt();
    CnApi_disableAsyncEventIRQ();
    CnApi_exit();

    return 0;
}

/**
********************************************************************************
\brief    read inputs and write outputs

workInputOutput() reads the input ports and writes the output ports. It must
be periodically called in the main loop.
*******************************************************************************/
static void workInputOutput(void)
{
    register BYTE iCnt;
    DWORD dwOutPort = 0;
    BYTE cInPort;

    cInPort = SysComp_readInputPort(); ///> Digital IN: read push- and joystick buttons
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

    SysComp_writeOutputPort(dwOutPort);
}

/**
 ********************************************************************************
 \brief application event handling of POWERLINK Slave API
 \param EventType_p     type of CnApi event
 \param pEventArg_p     pointer to argument of CnApi event which matches the event type
 \param pUserArg_p      pointer to user argument

 \return tCnApiStatus
 \retval kCnApiStatusOk     on success

 This function is the access point for all application related events which will
 happen in the POWERLINK Slave API. Every time an event occurs this function
 will be called.

 *******************************************************************************/
static tCnApiStatus CnApi_AppCbEvent(tCnApiEventType EventType_p, tCnApiEventArg * pEventArg_p, void * pUserArg_p)
{
    tCnApiStatus Ret = kCnApiStatusOk;

    switch (EventType_p)
    {
            case kCnApiEventUserDef:
            case kCnApiEventApStateChange:
            {
                //DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO,"New AP State: %d\n", pEventArg_p->m_NewApState);

                fOperational_l = FALSE;

#ifndef USE_POLLING_MODE_SYNC
                CnApi_disableSyncInt();    // disable synchronous IR signal of PCP
                // Note: this is not really necessary, because this IR will only be triggered
                // in PCP's OPERATIONAL state, but it disables the IRQs in any case.
#endif /* USE_POLLING_MODE_SYNC */

                switch (pEventArg_p->m_NewApState)
                {

                    case kApStateBooted:
                    case kApStateReadyToInit:
                    case kApStateInit:
                    case kApStatePreOp:
                        break;

                    case kApStateReadyToOperate:
                    {
                        /* Do some preparation before READY_TO_OPERATE state is entered */

                        // Note: The application should not take longer for this preparation than
                        // the timeout value of the Powerlink MN "MNTimeoutPreOp2_U32".
                        // Otherwise the CN will constantly reboot (= not finish booting)!
                        break;
                    }

                    case kApStateOperational:
                    {
                        fOperational_l = TRUE;

#ifndef USE_POLLING_MODE_SYNC
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
                switch (pEventArg_p->m_PcpEventGen)
                {
                    case kPcpGenEventSyncCycleCalcSuccessful:
                    {
                        DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO,"INFO: Synchronization IR Period is %lu us.\n",
                                CnApi_getSyncIntPeriod());
                        break;
                    }

                    case kPcpGenEventNodeIdConfigured:
                    {
                        DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO,"INFO: NODE ID is set to 0x%02x\n",
                                CnApi_getNodeId());
                        break;
                    }

                    case kPcpGenEventResetNodeRequest:
                    {
                        // do reconfiguration of this node here
                        break;
                    }

                    case kPcpGenEventResetCommunication:
                    {
                        // do application specific asynchronous communication reset here
                        break;
                    }

                    case kPcpGenEventNmtEnableReadyToOperate:
                    {
                        // Info: Nmt command from MN
                        break;
                    }

                    case kPcpGenEventUserTimer:
                    {
                        // only for testing purposes
                        break;
                    }

                    default:
                    break;
                }

                break;
            }
            case kCnApiEventError:
            {
                switch (pEventArg_p->m_CnApiError.m_ErrTyp)
                {
                    case kCnApiEventErrorFromPcp:
                    {
                        switch (pEventArg_p->m_CnApiError.m_ErrArg.m_PcpError.m_Typ)
                        {
                            case kPcpPdiEventGenericError:
                            {
                                switch (pEventArg_p->m_CnApiError.m_ErrArg.m_PcpError.m_Arg.m_GenErr)
                                {
                                    case kPcpGenErrInitFailed:
                                    case kPcpGenErrSyncCycleCalcError:
                                    {
                                        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR,"ERROR: (%s) PCP "
                                                "initialization failed!\n", __func__);
                                        break;
                                    }
                                    case kPcpGenErrAsyncComMtuExceeded:
                                    {
                                        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR,"ERROR: (%s) Max "
                                                "asynchronous MTU exceeded!\n",__func__);
                                        break;
                                    }
                                    case kPcpGenErrAsyncComTxBufferFull:
                                    {
                                        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR,"ERROR: (%s) Asynchronous "
                                                "Tx buffer full!\n",__func__);
                                        break;
                                    }
                                    case kPcpGenErrAsyncComTimeout:
                                    case kPcpGenErrAsyncIntChanComError:
                                    {
                                        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR,"ERROR: (%s) Asynchronous "
                                                "communication failed at PCP!\n",__func__);
                                        break;
                                    }
                                    case kPcpGenErrPhy0LinkLoss:
                                    case kPcpGenErrPhy1LinkLoss:
                                    {
                                        DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO,"INFO: Phy link lost!\n");
                                        // This might not be an issue as long as you have two phys.
                                        // Only the connection to MN might be critical.
                                        // If this link is lost -> PCP state change to PreOP1
                                        // Link loss at initialization of PCP is furthermore normal!

                                        break;
                                    }

                                    case kPcpGenErrEventBuffOverflow:
                                    {
                                        // AP is too slow (or PCP event buffer is too small)!
                                        // -> AP will lose latest events from PCP
                                        break;
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
                                DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR,"PCP software error: %#04lx\n",
                                pEventArg_p->m_CnApiError.m_ErrArg.m_PcpError.m_Arg.m_dwPcpStackError);
                                break;
                            }

                            case kPcpPdiEventHistoryEntry:
                            {
                                // PCP will change state, stop processing or restart
                                DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR,"Error history entry code: %#04lx\n",
                                pEventArg_p->m_CnApiError.m_ErrArg.m_PcpError.m_Arg.m_dwErrorHistoryCode);
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

    return Ret;
}

/**
 ********************************************************************************
 \brief application synchronization to POWERLINK cycle

 \param pTimeStamp_p             Time information of the current sync interrupt.
                                 It consists of the Nettime, RelativeTime
                                 and additional the time elapsed after the
                                 synchronous interrupt line went high.

 \return tCnApiStatus
 \retval kCnApiStatusOk          on success

 This function is used to do application specific synchronization.
 It will be called every time after the PDO-mapped data which were linked with
 CnApi_linkObject()have been updated locally.

 *******************************************************************************/
static tCnApiStatus CnApi_AppCbSync( tCnApiTimeStamp * pTimeStamp_p )
{
    tCnApiStatus Ret = kCnApiStatusOk;

    // Note: This is your place to do local synchronization. Synchronize
    //       your local clock here by using the provided timestamp.

    workInputOutput();                 // update the PCB's inputs and outputs

    return Ret;
}

/**
********************************************************************************
\brief    synchronous interrupt handler

syncIntHandler() implements the synchronous data interrupt. The PCP asserts
the interrupt when periodic data is ready to transfer.
*******************************************************************************/
#ifndef USE_POLLING_MODE_SYNC
#if defined(__NIOS2__) && !defined(ALT_ENHANCED_INTERRUPT_API_PRESENT)
static void syncIntHandler(void* pArg_p, void* dwInt_p)
#else
static void syncIntHandler(void* pArg_p)
#endif
{
    BENCHMARK_MOD_01_SET(0);

    /* Call CN API check PDO function! (transfer PDO's and call sync callback) */
    CnApi_processPdo();

    CnApi_ackSyncIrq();                // acknowledge IR from PCP

    BENCHMARK_MOD_01_RESET(0);
}
#endif /* USE_POLLING_MODE_SYNC */


/**
********************************************************************************
\brief  asynchronous interrupt handler

asyncIntHandler() implements the asynchronous data interrupt. The PCP asserts
the interrupt when an event is ready to transfer.
*******************************************************************************/
#ifndef USE_POLLING_MODE_ASYNC
#if defined(__NIOS2__) && !defined(ALT_ENHANCED_INTERRUPT_API_PRESENT)
static void asyncIntHandler(void* pArg_p, void* dwInt_p)
#else
static void asyncIntHandler(void* pArg_p)
#endif
{
    BENCHMARK_MOD_01_SET(1);

    CnApi_processAsyncEvent();            // check if PCP event occurred (event will be acknowledged inside this function)

    BENCHMARK_MOD_01_RESET(1);
}
#endif /* USE_POLLING_MODE_ASYNC */

#ifdef CN_API_USING_SPI
/**
********************************************************************************
\brief  SPI master tx

CnApi_CbSpiMasterTx() is the callback function for sending an TX frame
to the SPI slave

\param  pTxBuf_p             A pointer to the buffer to send
\param  iBytes_p             The number of bytes to send

\return OK, or ERROR if the frame could not be sent
*******************************************************************************/

static int CnApi_CbSpiMasterTx(unsigned char *pTxBuf_p, int iBytes_p)
{
    if(SysComp_SPICommand(pTxBuf_p,NULL,iBytes_p) != OK)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR: SPI Tx failed!");
        return ERROR;
    }

    return OK;
}

/**
********************************************************************************
\brief  SPI master rx

CnApi_CbSpiMasterRx() is the callback function for receiving an RX frame
from the SPI slave

\param  pRxBuf_p             A pointer to the buffer where the data should be stored
\param  iBytes_p             The number of bytes to receive

\return OK, or ERROR if the frame could not be received
*******************************************************************************/
static int CnApi_CbSpiMasterRx(unsigned char *pRxBuf_p, int iBytes_p)
{
    if(SysComp_SPICommand(NULL,pRxBuf_p,iBytes_p) != OK)
    {
        DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR: SPI Rx failed!");
        return ERROR;
    }

    return OK;
}

/**
********************************************************************************
\brief  SPI callback for interrupt enable

enableGlobalInterrupts() is the callback function for enabling the global interrupts
of the system
*******************************************************************************/
static void enableGlobalInterrupts(void)
{
    SysComp_enableInterrupts();

    BENCHMARK_MOD_02_RESET(2);
}

/**
********************************************************************************
\brief  SPI callback for interrupt disable

disableGlobalInterrupts() is the callback function for disabling the global interrupts
of the system
*******************************************************************************/
static void disableGlobalInterrupts(void)
{
    SysComp_disableInterrupts();

    BENCHMARK_MOD_02_SET(2);
}
#endif /* CN_API_USING_SPI */

#if VETH_DRV_ENABLE != FALSE
/**
********************************************************************************
\brief  Virtual Ethernet callback for a received frame

\param pData_p          pointer to the data structure
\param wDataSize        size of the received buffer

\return tCnApiStatus
\retval kCnApiStatusOk                    on success
\retval other                             on other error

returns the received frame for further processing
*******************************************************************************/
static tCnApiStatus CnApi_AppCbVethRx(BYTE *pData_p, WORD wDataSize)
{
    tCnApiStatus iRet = kCnApiStatusOk;

    DEBUG_LVL_CNAPI_VETH_INFO_TRACE1("VETHINFO: (%s) Successfully received a "
            "virtual ethernet frame!\n", __func__);

    return iRet;
}

/**
********************************************************************************
\brief  Virtual Ethernet callback for transmit finished

\param eVethTxStatus_p                    status of transfer (success or timeout)

\return tCnApiStatus
\retval kCnApiStatusOk                    on success
\retval other                             on other error

Signals if a Tx frame is posted in the stack internal buffer on PCP
*******************************************************************************/
static tCnApiStatus CnApi_AppCbVethTxFinished(tCnApiVethTxStatus eVethTxStatus_p)
{
    tCnApiStatus iRet = kCnApiStatusOk;

    DEBUG_LVL_CNAPI_VETH_INFO_TRACE1("VETHINFO: (%s) Transfer finished callback"
            " called!\n", __func__);

    return iRet;
}
#endif


/**
 ********************************************************************************
 \brief called if object index does not exits in OBD

 \param pObdParam_p   OBD access structure

 \return tCnApiObdStatus
 \retval kCnApiObdStatusOk          on success
 \retval kCnApiObdInvalidParam      when object instance is invalid
 \retval kCnApiObdSubindexNotExist  when the subindex is invalid

 This default OBD access callback function will be invoked if an index is not
 present in the local OBD. If a subindex is not present, this function shall not
 be called. If the access to the desired object can not be handled immediately,
 kCnApiObdAccessAdopted has to be returned.
 *******************************************************************************/
static tCnApiObdStatus CnApi_CbDefaultObdAccess(tCnApiObdParam *  pObdParam_p)
{
    tCnApiObdStatus       Ret = kCnApiObdStatusOk;

    if (pObdParam_p == NULL)
    {
        Ret = kCnApiObdInvalidParam;
        goto Exit;
    }

    DEBUG_TRACE4(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO,"CnApi_CbDefaultObdAccess(0x%04X/%u Ev=%X pData=%p ",
        pObdParam_p->m_uiIndex, pObdParam_p->m_uiSubIndex,
        pObdParam_p->m_ObdEvent,
        pObdParam_p->m_pData);
    DEBUG_TRACE4(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO,"Off=%u Size=%u ObjSize=%u TransSize=%u)\n",
        pObdParam_p->m_SegmentOffset, pObdParam_p->m_SegmentSize,
        pObdParam_p->m_ObjSize, pObdParam_p->m_TransferSize);

    // return error for all non existing objects
    // if not known yet, this can also be done by setting m_dwAbortCode appropriately
    // before the call of CnApi_DefObdAccFinished().
    switch (pObdParam_p->m_uiIndex)
    {
//        case 0x6500:
//        {   // example: checking an existing object
//            switch (pObdParam_p->m_uiSubIndex)
//            {
//                case 0x01:
//                {
//                    break;
//                }
//
//                default:
//                {
//                    pObdParam_p->m_dwAbortCode = kCnApiSdoacSubIndexNotExist;
//                    Ret = kCnApiObdSubindexNotExist;
//                    goto Exit;
//                }
//            }
//
//            break;
//        }

        default:
        {
            if(pObdParam_p->m_uiIndex < 0x2000)
            { // not an application specific object

                pObdParam_p->m_dwAbortCode = kCnApiSdoacObjectNotExist;
                Ret = kCnApiObdIndexNotExist;
                goto Exit;

                break;
            }

        }
        break;
    }

    switch (pObdParam_p->m_ObdEvent)
    {
        case kCnApiObdEvCheckExist:
        {
            // Do not return "kCnApiObdAccessAdopted" - not allowed in this case!

            goto Exit;
        } // end case kCnApiObdEvCheckExist

        case kCnApiObdEvInitWriteLe:
        case kCnApiObdEvPreRead:
        { // do not return kCnApiObdStatusOk in this case,
          // only error or kCnApiObdAccessAdopted is allowed!

            // save handle
            CNAPI_MEMCPY(&ObdParam_l, pObdParam_p, sizeof (tCnApiObdParam));

            // NOTE: before exiting this function, initiate custom object transfer HERE
            // - if if fails, return kCnApiInvalidOperation
            // Note: this function will not be called again before CnApi_DefObdAccFinished() has
            // been invoked i.e. more than one object access at the same time will not happen.


            // adopt OBD access
            // If the transfer has finished, invoke callback function with pointer to saved handle
            // e.g.: CnApi_DefObdAccFinished(ObdParam_l);
            // after appropriate values have been assigned to ObdParam_l.
            // Refer to CnApi_processObjectAccess() for an example function
            Ret = kCnApiObdAccessAdopted;
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_DEFAULT_OBD_ACC_INFO," Adopted\n");
            goto Exit;

        }   // end case kCnApiObdEvPreRead

        default:
        break;
    }

Exit:
    return Ret;
}


/**
 ********************************************************************************
 \brief handle an asynchronous object access
 \param pObdParam_p           Obd object handle from default object access
                              callback

 This function needs to be called periodically. The implementation is an example
 how to process and asynchronous object access e.g. from an SDO transfer. It needs
 to be adapted by the user.
 *******************************************************************************/
static void CnApi_processObjectAccess(tCnApiObdParam * pObdParam_p)
{
    tCnApiStatus CnApiRet = kCnApiStatusOk;

    if (pObdParam_p->m_uiIndex == 0 )
    { // nothing to do, return
        goto Exit;
    }


    if (pObdParam_p->m_ObdEvent == kCnApiObdEvPreRead)
    {   // return data of read access

        // Example how to finish a ReadByIndex access:
        dwExampleData_l++;
        pObdParam_p->m_pData = &dwExampleData_l;
        pObdParam_p->m_ObjSize = sizeof(dwExampleData_l);
        pObdParam_p->m_SegmentSize = sizeof(dwExampleData_l);

        // if an error occured (e.g. object does not exist):
        //pObdParam_p->m_dwAbortCode = CNAPI_SDOAC_OBJECT_NOT_EXIST;

    }
    else
    { // write access

        // write to some variable

        // nothing else to do except optional error handling
        //pObdParam_p->m_dwAbortCode = CNAPI_SDOAC_OBJECT_NOT_EXIST;
    }

    CnApiRet = CnApi_DefObdAccFinished(pObdParam_p);
    if(CnApiRet != kCnApiStatusOk)
    {
        DEBUG_TRACE2(DEBUG_LVL_CNAPI_ERR, "ERROR: (%s) CnApi_DefObdAccFinished "
                "failed with 0x%x!\n", __func__, CnApiRet);
    }

    /* reset structure when object access is finished */
    CNAPI_MEMSET(pObdParam_p, 0 , sizeof(tCnApiObdParam));

Exit:
    return;
}

/**
 ********************************************************************************
 \brief Provides access to the PDO descriptors during bootup
 \param pPdoDesc_p            pointer to the PDO descriptor
 \param tPdoRespAbortCode_p   the SDO abort code in case of a mapping error

 \return tCnApiStatus
 \retval kCnApiStatusOk       on success
 \retval other error

 This function gives access to the PDO descriptor structure. It enables to
 program your own mapping behavior and the use of a custom object dictionary.
 *******************************************************************************/
tCnApiStatus CnApi_CbPdoDescListings(tCnApiPdoDesc * pPdoDesc_p,
        tCnApiSdoAbortCode * tPdoRespAbortCode_p)
{
    tCnApiStatus Ret = kCnApiStatusOk;
    WORD wCnt;
    tPdoDescEntry * pDescEntry;

    BYTE bEntryCnt = pPdoDesc_p->m_PdoDescHeader.m_bEntryCnt;


    DEBUG_TRACE4(DEBUG_LVL_CNAPI_PDO_INFO, "EntryCnt: %d, Dir: 0x%x, MapVer: %d BuffNum: %d\n",bEntryCnt,
            pPdoDesc_p->m_PdoDescHeader.m_bPdoDir,
            pPdoDesc_p->m_PdoDescHeader.m_bMapVersion,
            pPdoDesc_p->m_PdoDescHeader.m_bBufferNum);

    pDescEntry = &pPdoDesc_p->m_PdoDescData;

    for (wCnt=0; wCnt < bEntryCnt; wCnt++)
    {
        DEBUG_TRACE4(DEBUG_LVL_CNAPI_PDO_INFO, "Index: 0x%x, SubIndex: 0x%x, Size: %d Offset: 0x%x\n",
                AmiGetWordFromLe((BYTE*)&(pDescEntry->m_wPdoIndex)),
                pDescEntry->m_bPdoSubIndex,
                AmiGetWordFromLe((BYTE*)&(pDescEntry->m_wSize)),
                AmiGetWordFromLe((BYTE*)&(pDescEntry->m_wOffset)));

        pDescEntry = (tPdoDescEntry *)((BYTE*)pDescEntry + sizeof(tPdoDescEntry));
    }

    //set abort code
    *tPdoRespAbortCode_p = kCnApiSdoacNoAbort;

    return Ret;
}

/*******************************************************************************
*
* License Agreement
*
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved.
*
* Redistribution and use in source and binary forms,
* with or without modification,
* are permitted provided that the following conditions are met:
*
*   * Redistributions of source code must retain the above copyright notice,
*     this list of conditions and the following disclaimer.
*   * Redistributions in binary form must reproduce the above copyright notice,
*     this list of conditions and the following disclaimer
*     in the documentation and/or other materials provided with the
*     distribution.
*   * Neither the name of the B&R nor the names of its contributors
*     may be used to endorse or promote products derived from this software
*     without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
* A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
* THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
*******************************************************************************/
/* END-OF-FILE */

