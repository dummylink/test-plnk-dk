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
#include "cnApi.h"
#include "cnApiAsync.h"
#include "cnApiEvent.h"
#include "EplSdoAc.h"
#include "EplObd.h"

#ifdef __NIOS2__
#include <unistd.h>
#elif defined(__MICROBLAZE__)
#include "xilinx_usleep.h"
#endif

#include "systemComponents.h"

/******************************************************************************/
/* defines */

/*----------------------------------------------------------------------------*/
/* USER OPTIONS */

/* If node Id switches are connected to the PCP, this value must be 0x00! */
#define DEFAULT_NODEID      0x00    // default node ID to use, should be NOT 0xF0 (=MN)

//#define USE_POLLING_MODE_SYNC // comment this out to enable the sync event interrupt
#define USE_POLLING_MODE_ASYNC // comment this out to enable the async event interrupt

#if defined(CN_API_INT_AVALON) && !defined(USE_POLLING_MODE_ASYNC)
    #error "Dual-Nios design can not use 2 interrupts -> interrupt mode for events is not possible!"
#endif

#define DEMO_VENDOR_ID      0x00000000
#define DEMO_PRODUCT_CODE   0
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
static WORD     nodeId;                                         ///< The node ID, which can overwrite the node switches if != 0x00
static BYTE     abMacAddr_l[] = { MAC_ADDR };                   ///< The MAC address to be used
static BYTE   strDevName[] = DEMO_DEVICE_NAME;
static BYTE   strHwVersion[] = "1.00";
static BYTE   strSwVersion[] = "EPL V2 V1.8.1 CNDK";

static BYTE     digitalIn[NUM_INPUT_OBJS];                      ///< The values of the digital input pins of the board will be stored here
static BYTE     digitalOut[NUM_OUTPUT_OBJS];                    ///< The values of the digital output pins of the board will be stored here
static BOOL     fOperational_l = FALSE;                         ///< indicates AP Operation state

// Object access
static DWORD dwExampleData = 0xABCD0001;             ///< this is only an example object data
static tEplObdParam *   pAllocObdParam_l = NULL; ///< pointer to allocated memory of OBD access handle

/******************************************************************************/
/* forward declarations */
void setPowerlinkInitValues(tCnApiInitParm *pInitParm_p,
                            BYTE bNodeId_p,
                            BYTE * pMac_p,
                            BYTE * pstrDevName_p,
                            BYTE * pstrHwVersion_p,
                            BYTE * pstrSwVersion_p);
void workInputOutput(void);

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
int CnApi_CbSpiMasterTx(unsigned char *pTxBuf_p, int iBytes_p);
int CnApi_CbSpiMasterRx(unsigned char *pRxBuf_p, int iBytes_p);

void enableGlobalInterrupts(void);
void disableGlobalInterrupts(void);
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

    tCnApiInitParm      initParm = {{0}};

    SysComp_initPeripheral();

    SysComp_writeOutputPort(0xabffff); // set hex digits on Mercury-Board to indicate AP presence

    CNAPI_USLEEP(1000000);                                // wait 1 s, so you can see the LEDs

    nodeId = DEFAULT_NODEID;    // in case you dont want to use Node Id switches, use a different value then 0x00
    setPowerlinkInitValues(&initParm,
                           nodeId,
                           (BYTE *)abMacAddr_l,
                           strDevName,
                           strHwVersion,
                           strSwVersion);             // initialize POWERLINK parameters
#ifdef CN_API_USING_SPI
    status = CnApi_init((BYTE *)PDI_DPRAM_BASE_AP, &initParm, &CnApi_CbSpiMasterTx, &CnApi_CbSpiMasterRx,    // initialize and start the CN API with SPI
            enableGlobalInterrupts, disableGlobalInterrupts);
#else
    status = CnApi_init((BYTE *)PDI_DPRAM_BASE_AP, &initParm);   // initialize and start the CN API
#endif
    if (status > 0)
    {
        TRACE1("\nERROR: CN API library could not be initialized (%d)\n", status);
        return ERROR;
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
        return ERROR;
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

#ifdef USE_POLLING_MODE_SYNC
    CnApi_initSyncInt(0, 0, 0); ///< tell PCP that we want polling mode
    CnApi_disableSyncInt();
#else
    CnApi_initSyncInt(3000, 100000, 0);
    CnApi_disableSyncInt();    ///< interrupt will be enabled when CN is operational

    /* initialize PCP interrupt handler*/
    if(SysComp_initSyncInterrupt(syncIntHandler) != OK)    ///< local AP IRQ is enabled here
    {
        TRACE("ERROR: Unable to init the synchronous interrupt!\n");
        return ERROR;
    }

#endif /* USE_POLLING_MODE_SYNC */

#ifdef USE_POLLING_MODE_ASYNC
    CnApi_disableAsyncEventIRQ();
#else
    /* initialize Async interrupt handler */
    if(SysComp_initAsyncInterrupt(asyncIntHandler) != OK)
    {
        TRACE("ERROR: Unable to init the asynchronous interrupt!\n");
        return ERROR;
    }

    /* now enable the async interrupt in the pdi */
    CnApi_enableAsyncEventIRQ();
#endif /* USE_POLLING_MODE_ASYNC */

    /* Start periodic main loop */
    TRACE("API example is running...\n");

	/* main program loop */
    while (1)
    {
        /* Instead of this while loop, you can use your own (nonblocking) tasks ! */

        /*--- TASK 1: START ---*/
        CnApi_processApStateMachine();     // The AP state machine must be periodically updated
        /*--- TASK 1: END   ---*/

        CnApi_processAsyncStateMachine();

#ifdef USE_POLLING_MODE_SYNC
        /*--- TASK 2: START ---*/
        if (fOperational_l == TRUE)
        {
            CnApi_transferPdo();           // update linked variables
            CnApi_AppCbSync();             // call application specific synchronization function
        }
        /*--- TASK 2: END   ---*/
#endif /* USE_POLLING_MODE_SYNC */

#ifdef USE_POLLING_MODE_ASYNC
        CnApi_pollAsyncEvent();            // check if PCP event occurred
#endif /* USE_POLLING_MODE_ASYNC */
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

\param  pInitParm_p         pointer to initialization parameter structure
\param  bNodeId_p           node ID to use for CN
\param  pMac_p              pointer to MAC address
\param  pstrDevName_p       pointer to string of device name (object 0x1008/0 Pcp OD)
\param  pstrHwVersion_p     pointer to string of HW version  (object 0x1009/0 Pcp OD)
\param  pstrSwVersion_p     pointer to string of SW version  (object 0x100A/0 Pcp OD)
*******************************************************************************/
void setPowerlinkInitValues(tCnApiInitParm *pInitParm_p,
                            BYTE bNodeId_p,
                            BYTE * pMac_p,
                            BYTE * pstrDevName_p,
                            BYTE * pstrHwVersion_p,
                            BYTE * pstrSwVersion_p)
{
    pInitParm_p->m_bNodeId = bNodeId_p;
    memcpy(pInitParm_p->m_abMac, pMac_p, sizeof(pInitParm_p->m_abMac));
    pInitParm_p->m_dwDeviceType = -1;
    pInitParm_p->m_dwVendorId = DEMO_VENDOR_ID;
    pInitParm_p->m_dwProductCode = DEMO_PRODUCT_CODE;
    pInitParm_p->m_dwRevision = DEMO_REVISION;
    pInitParm_p->m_dwSerialNum = DEMO_SERIAL_NUMBER;
    memcpy(pInitParm_p->m_strDevName, pstrDevName_p, sizeof(pInitParm_p->m_strDevName));
    memcpy(pInitParm_p->m_strHwVersion, pstrHwVersion_p, sizeof(pInitParm_p->m_strHwVersion));
    memcpy(pInitParm_p->m_strSwVersion, pstrSwVersion_p, sizeof(pInitParm_p->m_strSwVersion));
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

 This function is the access point for all application related events which will
 happen in the POWERLINK Slave API. Every time an event occurs this function
 will be called.

 *******************************************************************************/
void CnApi_AppCbEvent(tCnApiEventType EventType_p, tCnApiEventArg * pEventArg_p, void * pUserArg_p)
{

    switch (EventType_p)
    {
            case kCnApiEventUserDef:
            case kCnApiEventApStateChange:
            {
                DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO,"New AP State: %d\n", pEventArg_p->NewApState_m);

                fOperational_l = FALSE;

#ifndef USE_POLLING_MODE_SYNC
                CnApi_disableSyncInt();    // disable synchronous IR signal of PCP
                // Note: this is not really necessary, because this IR will only be triggered
                // in PCP's OPERATIONAL state, but it disables the IRQs in any case.
#endif /* USE_POLLING_MODE_SYNC */

                switch (pEventArg_p->NewApState_m)
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
                switch (pEventArg_p->PcpEventGen_m)
                {
                    case kPcpGenEventSyncCycleCalcSuccessful:
                    {
                        TRACE1("\nINFO: Synchronization IR Period is %lu us.\n", CnApi_getSyncIntPeriod());
                        break;
                    }

                    case kPcpGenEventNodeIdConfigured:
                    {
                        TRACE1("INFO: NODE ID is set to 0x%02x\n", CnApi_getNodeId());
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
                        //TODO: This is only a test! -> delete
                        if (pAllocObdParam_l->m_ObdEvent == kEplObdEvPreRead)
                        {   // return data of read access

                            // Example how to finish a ReadByIndex access:
                            dwExampleData++;
                            pAllocObdParam_l->m_pData = &dwExampleData;
                            pAllocObdParam_l->m_ObjSize = sizeof(dwExampleData);
                            pAllocObdParam_l->m_SegmentSize = sizeof(dwExampleData);

                            // if an error occured (e.g. object does not exist):
                            //pAllocObdParam_l->m_dwAbortCode = EPL_SDOAC_OBJECT_NOT_EXIST;

                        }
                        else
                        { // write access

                            // write to some variable

                            // nothing else to do except optional error handling
                            //pAllocObdParam_l->m_dwAbortCode = EPL_SDOAC_OBJECT_NOT_EXIST;
                        }

                        CnApi_DefObdAccFinished(&pAllocObdParam_l);
                        // end of test

                        break;
                    }

                    default:
                    break;
                }

                break;
            }
            case kCnApiEventError:
            {
                switch (pEventArg_p->CnApiError_m.ErrTyp_m)
                {
                    case kCnApiEventErrorFromPcp:
                    {
                        switch (pEventArg_p->CnApiError_m.ErrArg_m.PcpError_m.Typ_m)
                        {
                            case kPcpPdiEventGenericError:
                            {
                                switch (pEventArg_p->CnApiError_m.ErrArg_m.PcpError_m.Arg_m.GenErr_m)
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
                                        // AP is too slow (or PCP event buffer is too small)!
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
                                DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO,"Error history entry code: %#04lx\n",
                                pEventArg_p->CnApiError_m.ErrArg_m.PcpError_m.Arg_m.wErrorHistoryCode_m);
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
            case kCnApiEventAsyncComm:
            {
                switch (pEventArg_p->AsyncComm_m.Typ_m)
                {
                    case kCnApiEventTypeAsyncCommIntMsgRxLinkPdosReq:
                    {
                        /* User has access to LinkPdosReq message here and can do something
                         * useful with it, e.g. setup own copy tables
                         * The user is also responsible for sending a LinkPdosResp message
                         * indicating success or failure of mapping and linking
                         * (refer to default example below).
                         */

                        DEBUG_TRACE1(DEBUG_LVL_CNAPI_INFO, "Warning: %d objects are mapped but not linked!\n",
                                pEventArg_p->AsyncComm_m.Arg_m.LinkPdosReq_m.wObjNotLinked_m);

                        /* prepare LinkPdosResp message status*/
                        if (pEventArg_p->AsyncComm_m.Arg_m.LinkPdosReq_m.fSuccess_m == FALSE)
                        { // mapping invalid or linking failed
                            DEBUG_TRACE0(DEBUG_LVL_CNAPI_ERR,"ERROR: Mapping or linking failed!\n");

                            /* set status */
                            LinkPdosResp_g.m_dwErrCode = EPL_SDOAC_GENERAL_ERROR;
                        }
                        else // successful
                        { /* set status */
                            LinkPdosResp_g.m_dwErrCode = 0; // 0: OK
                        }

                        /* return LinkPdosReq fields in LinkPdosResp message */
                        LinkPdosResp_g.m_bMsgId = pEventArg_p->AsyncComm_m.Arg_m.LinkPdosReq_m.pMsg_m->m_bMsgId;
                        LinkPdosResp_g.m_bOrigin = pEventArg_p->AsyncComm_m.Arg_m.LinkPdosReq_m.pMsg_m->m_bOrigin;

                        /* send LinkPdosResp message to PCP */
                        CnApiAsync_postMsg(kPdiAsyncMsgIntLinkPdosResp, 0,0,0);
                    }

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
 \brief application synchronization to POWERLINK cycle

 This function is used to do application specific synchronization.
 It will be called every time after the PDO-mapped data which were linked with
 CnApi_linkObject()have been updated locally.

 *******************************************************************************/
void CnApi_AppCbSync(void)
{
    workInputOutput();                 // update the PCB's inputs and outputs
}

/**
********************************************************************************
\brief	synchronous interrupt handler

syncIntHandler() implements the synchronous data interrupt. The PCP asserts
the interrupt when periodic data is ready to transfer.

See the Altera NIOSII Reference manual for further details of interrupt
handlers.
*******************************************************************************/
#ifndef USE_POLLING_MODE_SYNC
#if defined(__NIOS2__) && !defined(ALT_ENHANCED_INTERRUPT_API_PRESENT)
static void syncIntHandler(void* pArg_p, void* dwInt_p)
#else
static void syncIntHandler(void* pArg_p)
#endif
{
    CnApi_transferPdo();               // Call CN API PDO transfer function

    CnApi_AppCbSync();                 // call application specific synchronization function

    CnApi_ackSyncIrq();                // acknowledge IR from PCP

}
#endif /* USE_POLLING_MODE_SYNC */


/**
********************************************************************************
\brief  asynchronous interrupt handler

asyncIntHandler() implements the asynchronous data interrupt. The PCP asserts
the interrupt when an event is ready to transfer.

See the Altera NIOSII Reference manual for further details of interrupt
handlers.
*******************************************************************************/
#ifndef USE_POLLING_MODE_ASYNC
#if defined(__NIOS2__) && !defined(ALT_ENHANCED_INTERRUPT_API_PRESENT)
static void asyncIntHandler(void* pArg_p, void* dwInt_p)
#else
static void asyncIntHandler(void* pArg_p)
#endif
{
    CnApi_pollAsyncEvent();            // check if PCP event occurred (event will be acknowledged inside this function)

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

int CnApi_CbSpiMasterTx(unsigned char *pTxBuf_p, int iBytes_p)
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
int CnApi_CbSpiMasterRx(unsigned char *pRxBuf_p, int iBytes_p)
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
void enableGlobalInterrupts(void)
{
    SysComp_enableInterrupts();
}

/**
********************************************************************************
\brief  SPI callback for interrupt disable

disableGlobalInterrupts() is the callback function for disabling the global interrupts
of the system
*******************************************************************************/
void disableGlobalInterrupts(void)
{
    SysComp_disableInterrupts();
}
#endif /* CN_API_USING_SPI */


/**
 ********************************************************************************
 \brief called if object index does not exits in OBD
 \param pObdParam_p   OBD access structure
 \return tEplKernel value

 This default OBD access callback function will be invoked if an index is not
 present in the local OBD. If a subindex is not present, this function shall not
 be called. If the access to the desired object can not be handled immediately,
 kEplObdAccessAdopted has to be returned.
 *******************************************************************************/
tEplKernel CnApi_CbDefaultObdAccess(tEplObdParam *  pObdParam_p)
{
tEplKernel       Ret = kEplSuccessful;

    if (pObdParam_p == NULL)
    {
        Ret = kEplInvalidParam;
    }

    printf("CnApi_CbDefaultObdAccess(0x%04X/%u Ev=%X pData=%p Off=%u Size=%u"
           " ObjSize=%u TransSize=%u Acc=%X Typ=%X)\n",
        pObdParam_p->m_uiIndex, pObdParam_p->m_uiSubIndex,
        pObdParam_p->m_ObdEvent,
        pObdParam_p->m_pData, pObdParam_p->m_SegmentOffset, pObdParam_p->m_SegmentSize,
        pObdParam_p->m_ObjSize, pObdParam_p->m_TransferSize, pObdParam_p->m_Access, pObdParam_p->m_Type);

    // return error for all non existing objects
    // if not known yet, this can also be done by settig m_dwAbortCode appropriately
    // before the call of CnApi_DefObdAccFinished().
    switch (pObdParam_p->m_uiIndex)
    {
        case 0x6500:
        {   // example: checking an existing object
            switch (pObdParam_p->m_uiSubIndex)
            {
                case 0x01:
                {
                    break;
                }

                default:
                {
                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_SUB_INDEX_NOT_EXIST;
                    Ret = kEplObdSubindexNotExist;
                    goto Exit;
                }
            }

            break;
        }

        default:
        {
            if(pObdParam_p->m_uiIndex < 0x2000)
            { // not an application specific object

                pObdParam_p->m_dwAbortCode = EPL_SDOAC_OBJECT_NOT_EXIST;
                Ret = kEplObdIndexNotExist;
                goto Exit;

                break;
            }

        }
        break;
    }

    switch (pObdParam_p->m_ObdEvent)
    {
        case kEplObdEvCheckExist:
        {
            // Do not return "kEplObdAccessAdopted" - not allowed in this case!

            // optionally assign data type, access type and object size if it is already known
            // e.g. pObdParam_p->m_Type = kEplObdTypUInt32;

            goto Exit;
        } // end case kEplObdEvCheckExist

        case kEplObdEvInitWriteLe:
        case kEplObdEvPreRead:
        { // do not return kEplSuccessful in this case,
          // only error or kEplObdAccessAdopted is allowed!

            // check if it is a segmented transfer (= domain object access)
//            if ((pObdParam_p->m_Type == kEplObdTypDomain))
//            {
//                    // currently not supported
//                    Ret = kEplInvalidParam;
//                    pObdParam_p->m_dwAbortCode = EPL_SDOAC_UNSUPPORTED_ACCESS;
//                    goto Exit;
//            }

            if (pObdParam_p->m_pfnAccessFinished == NULL)
            {
                pObdParam_p->m_dwAbortCode = EPL_SDOAC_DATA_NOT_TRANSF_OR_STORED;
                Ret = kEplObdAccessViolation;
                goto Exit;
            }

            // allocate memory for handle
            pAllocObdParam_l = CNAPI_MALLOC(sizeof (*pAllocObdParam_l));
            if (pAllocObdParam_l == NULL)
            {
                Ret = kEplObdOutOfMemory;
                pObdParam_p->m_dwAbortCode = EPL_SDOAC_OUT_OF_MEMORY;
                goto Exit;
            }

            // save handle
            EPL_MEMCPY(pAllocObdParam_l, pObdParam_p, sizeof (*pAllocObdParam_l));

            // TODO: before exiting this function, initiate custom object transfer HERE
            // - if if fails, return kEplInvalidOperation
            // Note: this function will not be called again before CnApi_DefObdAccFinished() has
            // been invoked i.e. more than one object access at the same time will not happen.


            // adopt OBD access
            // If the transfer has finished, invoke callback function with pointer to saved handle
            // e.g.: CnApi_DefObdAccFinished(pAllocObdParam_l);
            // after appropriate values have been assigned to pAllocObdParam_l.
            // Please scroll up to "case kPcpGenEventUserTimer" in AppCbEvent()for an example
            Ret = kEplObdAccessAdopted;
            DEBUG_TRACE0(DEBUG_LVL_CNAPI_INFO," Adopted\n");
            goto Exit;

        }   // end case kEplObdEvInitWriteLe

        default:
        break;
    }

Exit:
    return Ret;
}

/**
 ********************************************************************************
 \brief signals an OBD default access as finished
 \param pObdParam_p
 \return tEplKernel value

 This function has to be called after an OBD access has been finished to
 inform the caller about this event.
 *******************************************************************************/
tEplKernel CnApi_DefObdAccFinished(tEplObdParam ** pObdParam_p)
{
tEplKernel EplRet = kEplSuccessful;
tEplObdParam * pObdParam = NULL;

    pObdParam = *pObdParam_p;

    DEBUG_TRACE2(DEBUG_LVL_CNAPI_INFO, "INFO: %s(%p) called\n", __func__, pObdParam);

    if (pObdParam_p == NULL                   ||
        pObdParam == NULL                     ||
        pObdParam->m_pfnAccessFinished == NULL  )
    {
        EplRet = kEplInvalidParam;
        goto Exit;
    }

    if ((pObdParam->m_ObdEvent == kEplObdEvPreRead)            &&
        ((pObdParam->m_SegmentSize != pObdParam->m_ObjSize) ||
         (pObdParam->m_SegmentOffset != 0)                    )  )
    {
        //segmented read access not allowed!
        pObdParam->m_dwAbortCode = EPL_SDOAC_UNSUPPORTED_ACCESS;
    }

    // call callback function which was assigned by caller
    EplRet = pObdParam->m_pfnAccessFinished(pObdParam);

    CNAPI_FREE(pObdParam);
    *pObdParam_p = NULL;

Exit:
    if (EplRet != kEplSuccessful)
    {
        DEBUG_TRACE1(DEBUG_LVL_CNAPI_ERR, "ERROR: %s failed!\n", __func__);
    }
    return EplRet;

}
/* END-OF-FILE */
/******************************************************************************/
