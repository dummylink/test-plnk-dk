/*******************************************************************************
* Copyright © 2012 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       pcpCtrlReg.c

\brief      Powerlink Communication Processor low level interface module

\date       13.11.2012

This module extends the openPOWERLINK API with a Process Data Interface (PDI).
It is responsible for the low level accesses to the control/status register.
The PDI can be accessed by an Application Processor (AP) using a parallel or
serial low level (hardware) data interface.

*******************************************************************************/
/* includes */
#include <pcpCtrlReg.h>
#include <pcpEvent.h>

/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */
volatile tPcpCtrlReg *         pCtrlReg_g;    ///< ptr. to PCP control register

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */

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
WORD getPcpState(void)
{
    return AmiGetWordFromLe((BYTE*)&(pCtrlReg_g->m_wState));
}

/**
********************************************************************************
\brief  inform AP about current Node ID setting
\param  wNodeId     current Node ID of PCP
*******************************************************************************/
void pcpPdi_setNodeIdInfo(WORD wNodeId)
{
    AmiSetWordToLe((BYTE*)&pCtrlReg_g->m_wNodeId, wNodeId);
    Gi_pcpEventPost(kPcpPdiEventGeneric, kPcpGenEventNodeIdConfigured);
}

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
