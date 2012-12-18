/*******************************************************************************
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       main.c

\brief      main module of digital I/O user interface

\date       14.11.2012

*******************************************************************************/
/* includes */
#include "Epl.h"

#include "fpgaCfg.h"
#include "omethlib.h"
#include "fwUpdate.h"
#include "fwBoot.h"

#include "EplSdo.h"
#include "EplAmi.h"
#include "EplObd.h"
#include "user/EplSdoAsySequ.h"
#include <EplObduDefAcc.h>
#include <EplObduDefAccHstry.h>

#ifdef __NIOS2__
#include <unistd.h>
#elif defined(__MICROBLAZE__)
#include "xilinx_usleep.h"
#endif

#include "systemComponents.h"

#ifdef LCD_BASE
#include "Cmp_Lcd.h"
#endif

#ifdef VETH_DRV_EN
#include "VirtualEthernetApi.h"
#endif

/******************************************************************************/
/* defines */
#define NODEID      0x01 // should be NOT 0xF0 (=MN) in case of CN

#define CYCLE_LEN   1000 // [us]
#define MAC_ADDR    0x00, 0x12, 0x34, 0x56, 0x78, 0x9A
#define IP_ADDR     0xc0a86401  // 192.168.100.1 // don't care the last byte!
#define SUBNET_MASK 0xFFFFFF00  // 255.255.255.0

#define USLEEP(x) usleep(x)
/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
BYTE        portIsOutput[4];
BYTE        digitalIn[4];
BYTE        digitalOut[4];

static BOOL     fShutdown_l = FALSE;
BOOL            fIsUserImage_g;            ///< if set user image is booted
UINT32          uiFpgaConfigVersion_g = 0; ///< version of currently used FPGA configuration

/******************************************************************************/
/* functions declarations */

// This function is the entry point for your object dictionary. It is defined
// in OBJDICT.C by define EPL_OBD_INIT_RAM_NAME. Use this function name to define
// this function prototype here. If you want to use more than one Epl
// instances then the function name of each object dictionary has to differ.
tEplKernel PUBLIC  EplObdInitRam (tEplObdInitParam MEM* pInitParam_p);
//TODO: test what happens if this declaration is deleted

static int openPowerlink(BYTE bNodeId_p);
static tEplKernel AppCbEvent(tEplApiEventType EventType_p,
                             tEplApiEventArg* pEventArg_p,
                             void * pUserArg_p);
static int EplAppHandleUserEvent(tEplApiEventArg* pEventArg_p);
static tEplKernel AppCbSync(void) INT_RAM_MAIN_01_APP_CB_SYNC;
static void InitPortConfiguration (BYTE *p_portIsOutput);
static void rebootCN(void);

#if defined(VETH_DRV_EN) && defined(EPL_VETH_SEND_TEST)
static tEplKernel VethExampleTransferProcess(void);
#endif

/******************************************************************************/
/* private functions */

/**
********************************************************************************
\brief    main function of digital I/O interface
*******************************************************************************/
int main (void)
{
    BYTE    bNodeId;

    SysComp_initPeripheral();

    fIsUserImage_g = FpgaCfg_processReconfigStatusIsUserImage(FpgaCfg_handleReconfig());

#ifdef LCD_BASE
    SysComp_LcdTest();
#endif

    PRINTF0("\n\nDigital I/O interface is running...\n");
    PRINTF0("starting openPowerlink...\n\n");

    if((bNodeId = SysComp_getNodeId()) == 0)
    {
        bNodeId = NODEID;
    }

#ifdef LCD_BASE
    SysComp_LcdPrintNodeInfo(fIsUserImage_g, bNodeId);
#endif

    while (1) {
        if (openPowerlink(bNodeId) != 0) {
            PRINTF0("openPowerlink was shut down because of an error\n");
            break;
        } else {
            PRINTF0("openPowerlink was shut down, restart...\n\n");
        }
        /* wait some time until we restart the stack */
        USLEEP(1000000);
    }

    PRINTF1("shut down processor...\n%c", 4);

    SysComp_freeProcessorCache();

    return 0;
}

/**
********************************************************************************
\brief  setup and process openPOWERLINK
*******************************************************************************/
static int openPowerlink(BYTE bNodeId_p)
{
    DWORD                       ip = IP_ADDR; // ip address

    const BYTE                  abMacAddr[] = {MAC_ADDR};
    static tEplApiInitParam     EplApiInitParam;
    tEplObdSize                 ObdSize;
    tEplKernel                  EplRet;
    unsigned int                uiVarEntries;
    tfwBootInfo fwBootIibInfo = {0};

    fShutdown_l = FALSE;

    /* initialize port configuration */
    InitPortConfiguration(portIsOutput);

    if(fwBoot_tryGetIibInfo(fIsUserImage_g, &fwBootIibInfo))
    {
        uiFpgaConfigVersion_g = fwBootIibInfo.uiFpgaConfigVersion;
    }

    /* setup the POWERLINK stack */

    // calc the IP address with the nodeid
    ip &= 0xFFFFFF00; //dump the last byte
    ip |= bNodeId_p; // and mask it with the node id

    // set EPL init parameters
    EplApiInitParam.m_uiSizeOfStruct = sizeof (EplApiInitParam);
    EPL_MEMCPY(EplApiInitParam.m_abMacAddress, abMacAddr, sizeof(EplApiInitParam.m_abMacAddress));
    EplApiInitParam.m_uiNodeId = bNodeId_p;
    EplApiInitParam.m_dwIpAddress = ip;
    EplApiInitParam.m_uiIsochrTxMaxPayload = CONFIG_ISOCHR_TX_MAX_PAYLOAD;
    EplApiInitParam.m_uiIsochrRxMaxPayload = CONFIG_ISOCHR_RX_MAX_PAYLOAD;
    EplApiInitParam.m_dwPresMaxLatency = 2000;
    EplApiInitParam.m_dwAsndMaxLatency = 2000;
    EplApiInitParam.m_fAsyncOnly = FALSE;
    EplApiInitParam.m_dwFeatureFlags = -1;
    EplApiInitParam.m_dwCycleLen = CYCLE_LEN;
    EplApiInitParam.m_uiPreqActPayloadLimit = 36;
    EplApiInitParam.m_uiPresActPayloadLimit = 36;
    EplApiInitParam.m_uiMultiplCycleCnt = 0;
    EplApiInitParam.m_uiAsyncMtu = 300;
    EplApiInitParam.m_uiPrescaler = 2;
    EplApiInitParam.m_dwLossOfFrameTolerance = 5000000;
    EplApiInitParam.m_dwAsyncSlotTimeout = 3000000;
    EplApiInitParam.m_dwWaitSocPreq = 0;
    EplApiInitParam.m_dwDeviceType = -1;
    EplApiInitParam.m_dwVendorId = CONFIG_IDENT_VENDOR_ID;
    EplApiInitParam.m_dwProductCode = CONFIG_IDENT_PRODUCT_CODE;
    EplApiInitParam.m_dwRevisionNumber = CONFIG_IDENT_REVISION;
    EplApiInitParam.m_dwSerialNumber = CONFIG_IDENT_SERIAL_NUMBER;
    EplApiInitParam.m_dwApplicationSwDate = fwBootIibInfo.uiApplicationSwDate;
    EplApiInitParam.m_dwApplicationSwTime = fwBootIibInfo.uiApplicationSwTime;
    EplApiInitParam.m_dwSubnetMask = SUBNET_MASK;
    EplApiInitParam.m_dwDefaultGateway = 0;
    EplApiInitParam.m_pfnCbEvent = AppCbEvent;
    EplApiInitParam.m_pfnCbSync  = AppCbSync;
    EplApiInitParam.m_pfnObdInitRam = EplObdInitRam;
    EplApiInitParam.m_pfnDefaultObdCallback = EplAppCbDefaultObdAccess; // called if objects do not exist in local OBD
    EplApiInitParam.m_pfnRebootCb = rebootCN;

    PRINTF1("\nNode ID is set to: %d\n", EplApiInitParam.m_uiNodeId);

    /* initialize firmware update */
    initFirmwareUpdate(CONFIG_IDENT_PRODUCT_CODE, CONFIG_IDENT_REVISION);

    /************************/
    /* initialize POWERLINK stack */
    PRINTF0("init POWERLINK stack:\n");
    EplRet = EplApiInitialize(&EplApiInitParam);
    if(EplRet != kEplSuccessful) {
        PRINTF1("init POWERLINK Stack... error %X\n\n", EplRet);
        goto Exit;
    }
    PRINTF0("init POWERLINK Stack...ok\n\n");

    /**********************************************************/
    /* link process variables used by CN to object dictionary */
    PRINTF0("linking process vars:\n");

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

    PRINTF0("linking process vars... ok\n\n");

    // start the POWERLINK stack
    EplRet = EplApiExecNmtCommand(kEplNmtEventSwReset);
    if (EplRet != kEplSuccessful) {
        goto ExitShutdown;
    }

    /*Start POWERLINK Stack*/
    PRINTF0("start POWERLINK Stack... ok\n\n");

    PRINTF0("Digital I/O interface with openPowerlink is ready!\n\n");

#ifdef STATUS_LEDS_BASE
    SysComp_setPowerlinkStatus(0xff);
#endif

    SysComp_enableInterrupts();

    while(1)
    {
        EplApiProcess();
        updateFirmwarePeriodic();               // periodically call firmware update state machine

#if defined(VETH_DRV_EN) && defined(EPL_VETH_SEND_TEST)
        EplRet = VethExampleTransferProcess();
        if (EplRet != kEplSuccessful)
        {
            break;
        }
#endif

        if (fShutdown_l == TRUE)
            break;
    }

ExitShutdown:
    PRINTF0("Shutdown EPL Stack\n");
    EplApiShutdown(); //shutdown node

Exit:
    return EplRet;
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
static tEplKernel AppCbEvent(tEplApiEventType EventType_p,
                             tEplApiEventArg* pEventArg_p,
                             void * pUserArg_p)
{
    tEplKernel          EplRet = kEplSuccessful;
    BYTE                bPwlState;

    // check if NMT_GS_OFF is reached
    switch (EventType_p)
    {
        case kEplApiEventNmtStateChange:
        {
#ifdef LCD_BASE
            SysComp_LcdPrintState(pEventArg_p->m_NmtStateChange.m_NewNmtState);
#endif

#ifdef LATCHED_IOPORT_CFG
            if (pEventArg_p->m_NmtStateChange.m_NewNmtState != kEplNmtCsOperational)
            {
                bPwlState = 0x0;
                memcpy(LATCHED_IOPORT_CFG+3,(BYTE *)&bPwlState,1);    ///< Set PortIO operational pin to low
            } else {
                /* reached operational state */
                bPwlState = 0x80;
                memcpy(LATCHED_IOPORT_CFG+3,(BYTE *)&bPwlState,1);    ///< Set PortIO operational pin to high
            }
#endif //LATCHED_IOPORT_CFG

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

                    PRINTF3("%s(0x%X) originating event = 0x%X\n",
                            __func__,
                            pEventArg_p->m_NmtStateChange.m_NewNmtState,
                            pEventArg_p->m_NmtStateChange.m_NmtEvent);

                    // reset flow control manipulation
                    EplSdoAsySeqAppFlowControl(FALSE, FALSE);

                    // clean all default OBD accesses
                    EplAppDefObdAccAdoptedHstryCleanup();

                    EplRet = EplApiWriteLocalObject(0x1F81, bNodeId, &dwNodeAssignment, sizeof (dwNodeAssignment));
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
        {
            // set error LED
#ifdef STATUS_LEDS_BASE
            SysComp_setPowerlinkStatus(0x2);
#endif
            // fall through
        }
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
#ifdef STATUS_LEDS_BASE
            switch (pEventArg_p->m_Led.m_LedType)
            {
                case kEplLedTypeStatus:
                {
                    if (pEventArg_p->m_Led.m_fOn != FALSE)
                    {
                        SysComp_resetPowerlinkStatus(0x1);
                    }
                    else
                    {
                        SysComp_setPowerlinkStatus(0x1);
                    }
                    break;
                }
                case kEplLedTypeError:
                {
                    if (pEventArg_p->m_Led.m_fOn != FALSE)
                    {
                        SysComp_resetPowerlinkStatus(0x2);
                    }
                    else
                    {
                        SysComp_setPowerlinkStatus(0x2);
                    }
                    break;
                }
                default:
                    break;
            }
#endif
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

\retval    kEplSuccessful            no error
\retval    otherwise                post error event to API layer
*******************************************************************************/
static tEplKernel AppCbSync(void)
{
    tEplKernel         EplRet = kEplSuccessful;
    register int    iCnt;
    DWORD            ports; //<<< 4 byte input or output ports
    DWORD*            ulDigInputs = LATCHED_IOPORT_BASE;
    DWORD*            ulDigOutputs = LATCHED_IOPORT_BASE;

    /* read digital input ports */
    ports = AmiGetDwordFromLe((BYTE*) ulDigInputs);;

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
    AmiSetDwordToLe((BYTE*)ulDigOutputs, ports);

    return EplRet;
}

/**
********************************************************************************
\brief    init port configuration

InitPortConfiguration() reads the port configuration inputs. The port
configuration inputs are connected to general purpose I/O pins IO3V3[16..12].
The read port configuration if stored at the port configuration outputs to
set up the input/output selection logic.

\param    portIsOutput        pointer to array where output flags are stored
*******************************************************************************/
static void InitPortConfiguration (BYTE *p_portIsOutput)
{
    register int    iCnt;
    volatile BYTE    portconf;
    unsigned int    direction = 0;

    /* read port configuration input pins */
    memcpy((BYTE *) &portconf, LATCHED_IOPORT_CFG, 1);
    portconf = (~portconf) & 0x0f;

    PRINTF1("\nPort configuration register value = 0x%1X\n", portconf);

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
\brief    reboot the CN

This function reboots the CN. It checks if the FPGA configuration of the running
firmware and the user image is different. If it is the same version it only
performs a PCP software reset. If it is differnt it triggers a complete
FPGA reconfiguration.
*******************************************************************************/
static void rebootCN(void)
{
    BOOL fIsUserImage = TRUE;
    tfwBootInfo fwBootIibInfo = {0};

    /* read FPGA configuration version of user image */
    fwBoot_tryGetIibInfo(fIsUserImage, &fwBootIibInfo);

    /* if the FPGA configuration version changed since boot-up, we have to do
     * a complete FPGA reconfiguration. */
    if (fwBootIibInfo.uiFpgaConfigVersion != uiFpgaConfigVersion_g)
    {
        DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "FPGA Configuration of CN ...\n");
        //USLEEP(4000000);

        // trigger FPGA reconfiguration
        // remark: if we are in user image, this command will trigger a
        //         reconfiguration of the factory image regardless of its argument!
        FpgaCfg_reloadFromFlash(CONFIG_FACTORY_IMAGE_FLASH_ADRS); // restart factory image
    }
    else
    {   // only reset the PCP software

        // TODO: verify user image if only PCP SW was updated (at bootup or now?)!

        DEBUG_TRACE0(DEBUG_LVL_ALWAYS, "PCP Software Reset of CN ...\n");
        //USLEEP(4000000);

        FpgaCfg_resetProcessor();
    }

}

#if defined(VETH_DRV_EN) && defined(EPL_VETH_SEND_TEST)
/**
********************************************************************************
\brief    Do an example virtual ethernet transfer

This function calls the VEthApiSendTest function which sends a ARP request
to the master. The master replys with an ARP response which is received by the
VEthApiCheckAndForwardRxFrame function.

\return tEplKernel
\retval kEplSuccessful     on success
\retval other              send or receive error
*******************************************************************************/
static tEplKernel VethExampleTransferProcess(void)
{
    tEplKernel EplRet = kEplSuccessful;
    BYTE *          pbRxBuffer = NULL;
    WORD            bRxBufferSize = 0;

    /* send test ARP frame to the network */
    EplRet = VEthApiSendTest();
    switch(EplRet)
    {
       case kEplInvalidParam:
           PRINTF1("%s(Err/Warn): Virtual Ethernet maximum MTU size exceeded! "
                   "Frame discarded!\n", __func__);
           EplRet = kEplSuccessful;
           break;
       case kEplDllAsyncTxBufferFull:
           // discard frame (set stats?)
           EplRet = kEplSuccessful;
           break;
       case kEplInvalidOperation:
           // try to send in invalid state! (frame discarded!)
           EplRet = kEplSuccessful;
           break;
       case kEplSuccessful:
           // send successful (set stats?)
           break;
       default:
           PRINTF1("%s(Err/Warn): Virtual Ethernet unknown error/warning!\n",
                   __func__);
           goto Exit;
    }

    /* call Veth receive frame function */
    EplRet = VEthApiCheckAndForwardRxFrame(&pbRxBuffer, &bRxBufferSize);
    if(EplRet == kEplSuccessful)
    {
        EplRet = VEthApiReleaseRxFrame();
        if(EplRet != kEplSuccessful)
        {
            PRINTF1("%s(Err/Warn): Error while freeing the Veth Rx buffer\n",
                    __func__);
            goto Exit;
        }
    } else {
        // no frame available (kEplReject)
        EplRet = kEplSuccessful;
    }

Exit:
    return EplRet;
}
#endif //defined(VETH_DRV_EN) && defined(EPL_VETH_SEND_TEST)


/******************************************************************************/
/* functions */


/*******************************************************************************
*
* License Agreement
*
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
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
