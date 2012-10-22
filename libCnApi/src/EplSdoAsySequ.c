/****************************************************************************

  (c) SYSTEC electronic GmbH, D-07973 Greiz, August-Bebel-Str. 29
      www.systec-electronic.com

  Project:      openPOWERLINK

  Description:  source file for asychronous SDO Sequence Layer module

  License:

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.

    3. Neither the name of SYSTEC electronic GmbH nor the names of its
       contributors may be used to endorse or promote products derived
       from this software without prior written permission. For written
       permission, please contact info@systec-electronic.com.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.

    Severability Clause:

        If a provision of this License is or becomes illegal, invalid or
        unenforceable in any jurisdiction, that shall not affect:
        1. the validity or enforceability in that jurisdiction of any other
           provision of this License; or
        2. the validity or enforceability in other jurisdictions of that or
           any other provision of this License.

  -------------------------------------------------------------------------

                $RCSfile$

                $Author$

                $Revision$  $Date$

                $State$

                Build Environment:
                    GCC V3.4

  -------------------------------------------------------------------------

  Revision History:

  2006/06/26 k.t.:   start of the implementation

****************************************************************************/

#include "user/EplSdoAsySequ.h"
#include "cnApiAsyncSm.h"


#if ((((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDO_UDP)) == 0) &&\
     (((EPL_MODULE_INTEGRATION) & (EPL_MODULE_SDO_ASND)) == 0)   )

//    #error 'ERROR: At least UDP or Asnd module needed!'

#endif
/***************************************************************************/
/*                                                                         */
/*                                                                         */
/*          G L O B A L   D E F I N I T I O N S                            */
/*                                                                         */
/*                                                                         */
/***************************************************************************/

//---------------------------------------------------------------------------
// const defines
//---------------------------------------------------------------------------

#define EPL_SDO_HISTORY_SIZE        5

#ifndef EPL_MAX_SDO_SEQ_CON
#define EPL_MAX_SDO_SEQ_CON         5
#endif

#define EPL_SEQ_DEFAULT_TIMEOUT     5000    // in [ms] => 5 sec

#define EPL_SEQ_RETRY_COUNT         5       // => max. Timeout 30 sec

#define EPL_SEQ_NUM_THRESHOLD       100     // threshold which distinguishes between old and new sequence numbers

// define frame with size of Asnd-Header-, SDO Sequenze Header size, SDO Command header
// and Ethernet-Header size
#define EPL_SEQ_FRAME_SIZE          24
// size of the header of the asynchronus SDO Sequence layer
#define EPL_SEQ_HEADER_SIZE         4

// buffersize for one frame in history
#define EPL_SEQ_HISTROY_FRAME_SIZE  EPL_MAX_SDO_FRAME_SIZE

// mask to get scon and rcon
#define EPL_ASY_SDO_CON_MASK        0x03

//---------------------------------------------------------------------------
// local types
//---------------------------------------------------------------------------

// events for processfunction
typedef enum
{
    kAsySdoSeqEventNoEvent  =   0x00,   // no Event
    kAsySdoSeqEventInitCon  =   0x01,   // init connection
    kAsySdoSeqEventFrameRec =   0x02,   // frame received
    kAsySdoSeqEventFrameSend=   0x03,   // frame to send
    kAsySdoSeqEventTimeout  =   0x04,   // Timeout for connection
    kAsySdoSeqEventCloseCon =   0x05    // higher layer close connection

}tEplAsySdoSeqEvent;

// structure for History-Buffer
typedef struct
{
    BYTE                m_bFreeEntries;
    BYTE                m_bWrite; // index of the next free buffer entry
    BYTE                m_bAck;   // index of the next message which should become acknowledged
    BYTE                m_bRead;  // index between m_bAck and m_bWrite to the next message for retransmission
    BYTE                m_aabHistoryFrame[EPL_SDO_HISTORY_SIZE][EPL_SEQ_HISTROY_FRAME_SIZE];
    unsigned int        m_auiFrameSize[EPL_SDO_HISTORY_SIZE];

}tEplAsySdoConHistory;

// state of the statemaschine
typedef enum
{
    kEplAsySdoStateIdle         = 0x00,
    kEplAsySdoStateInit1        = 0x01,
    kEplAsySdoStateInit2        = 0x02,
    kEplAsySdoStateInit3        = 0x03,
    kEplAsySdoStateConnected    = 0x04,
    kEplAsySdoStateWaitAck      = 0x05

}tEplAsySdoState;

// connection control structure
typedef struct
{
    tEplSdoConHdl           m_ConHandle;
    tEplAsySdoState         m_SdoState;
    BYTE                    m_bRecSeqNum;   // name from view of the communication partner
    BYTE                    m_bSendSeqNum;  // name from view of the communication partner
    tEplAsySdoConHistory    m_SdoConHistory;
//    tEplTimerHdl            m_EplTimerHdl;
    unsigned int            m_uiRetryCount; // retry counter
    unsigned int            m_uiUseCount;   // one sequence layer connection may be used by
                                            // multiple command layer connections

}tEplAsySdoSeqCon;

// instance structure
typedef struct
{
    tEplAsySdoSeqCon    m_AsySdoConnection[EPL_MAX_SDO_SEQ_CON];
    tEplSdoComReceiveCb m_fpSdoComReceiveCb;
    tEplSdoComConCb     m_fpSdoComConCb;

#if defined(WIN32) || defined(_WIN32)
    LPCRITICAL_SECTION  m_pCriticalSection;
    CRITICAL_SECTION    m_CriticalSection;

    LPCRITICAL_SECTION  m_pCriticalSectionReceive;
    CRITICAL_SECTION    m_CriticalSectionReceive;
#endif

}tEplAsySdoSequInstance;

//---------------------------------------------------------------------------
// module global vars
//---------------------------------------------------------------------------

//static tEplAsySdoSequInstance   AsySdoSequInstance_g;

//---------------------------------------------------------------------------
// local function prototypes
//---------------------------------------------------------------------------

//static tEplKernel EplSdoAsySeqProcess(unsigned int  uiHandle_p,
//                                         unsigned int       uiDataSize_p,
//                                         tEplFrame*         pData_p,
//                                         tEplAsySdoSeq*     pRecFrame_p,
//                                         tEplAsySdoSeqEvent Event_p);
//
//static tEplKernel EplSdoAsySeqSendIntern(tEplAsySdoSeqCon*  pAsySdoSeqCon_p,
//                                         unsigned int       uiDataSize_p,
//                                         tEplFrame*         pData_p,
//                                         BOOL               fFrameInHistory);
//
//static tEplKernel EplSdoAsySeqSendLowerLayer(tEplAsySdoSeqCon*  pAsySdoSeqCon_p,
//                                         unsigned int       uiDataSize_p,
//                                         tEplFrame*         pEplFrame_p);
//
//tEplKernel PUBLIC EplSdoAsyReceiveCb (tEplSdoConHdl       ConHdl_p,
//                                        tEplAsySdoSeq*      pSdoSeqData_p,
//                                        unsigned int        uiDataSize_p);

//static tEplKernel EplSdoAsyInitHistory(tEplAsySdoSeqCon*  pAsySdoSeqCon_p);

//static tEplKernel EplSdoAsyAddFrameToHistory(tEplAsySdoSeqCon*  pAsySdoSeqCon_p,
//                                        tEplFrame*      pFrame_p,
//                                        unsigned int    uiSize_p);

//static tEplKernel EplSdoAsyAckFrameToHistory(tEplAsySdoSeqCon*  pAsySdoSeqCon_p,
//                                        BYTE   bRecSeqNumber_p);

//static tEplKernel EplSdoAsyReadFromHistory(tEplAsySdoSeqCon*  pAsySdoSeqCon_p,
//                                           tEplFrame**      ppFrame_p,
//                                           unsigned int*    puiSize_p,
//                                           BOOL             fInitRead);

//static unsigned int EplSdoAsyGetFreeEntriesFromHistory(tEplAsySdoSeqCon*  pAsySdoSeqCon_p);

//static tEplKernel EplSdoAsySeqSetTimer(tEplAsySdoSeqCon* pAsySdoSeqCon_p,
//                                        unsigned long    ulTimeout);

/***************************************************************************/
/*                                                                         */
/*                                                                         */
/*          C L A S S  <EPL asychronus SDO Sequence layer>                 */
/*                                                                         */
/*                                                                         */
/***************************************************************************/
//
// Description: this module contains the asynchronus SDO Sequence Layer for
//              the EPL SDO service
//
//
/***************************************************************************/

//=========================================================================//
//                                                                         //
//          P U B L I C   F U N C T I O N S                                //
//                                                                         //
//=========================================================================//

//---------------------------------------------------------------------------
//
// Function:    EplSdoAsySeqInit
//
// Description: init first instance
//
//
//
// Parameters:  fpSdoComCb_p    = callback function to inform Command layer
//                                about new frames
//              fpSdoComConCb_p = callback function to inform command layer
//                                about connection state
//
//
// Returns:     tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoAsySeqInit(tEplSdoComReceiveCb fpSdoComCb_p,
                                   tEplSdoComConCb fpSdoComConCb_p)
{
    tEplKernel      Ret = kEplSuccessful;

        return Ret;

}

//---------------------------------------------------------------------------
//
// Function:    EplSdoAsySeqAddInstance
//
// Description: init following instances
//
//
//
// Parameters:  fpSdoComCb_p    = callback function to inform Command layer
//                                about new frames
//              fpSdoComConCb_p = callback function to inform command layer
//                                about connection state
//
// Returns:     tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoAsySeqAddInstance (tEplSdoComReceiveCb fpSdoComCb_p,
                                   tEplSdoComConCb fpSdoComConCb_p)
{
    tEplKernel      Ret = kEplSuccessful;

        return Ret;

}

//---------------------------------------------------------------------------
//
// Function:    EplSdoAsySeqDelInstance
//
// Description: delete instances
//
//
//
// Parameters:
//
//
// Returns:     tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoAsySeqDelInstance()
{
    tEplKernel      Ret = kEplSuccessful;

        return Ret;
}

//---------------------------------------------------------------------------
//
// Function:    EplSdoAsySeqInitCon
//
// Description: start initialization of a sequence layer connection.
//              It tries to reuse an existing connection to the same node.
//
//
// Parameters:  pSdoSeqConHdl_p = pointer to the variable for the connection handle
//              uiNodeId_p      = Node Id of the target
//              SdoType          = Type of the SDO connection
//
//
// Returns:     tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoAsySeqInitCon(tEplSdoSeqConHdl* pSdoSeqConHdl_p,
                                unsigned int uiNodeId_p,
                                tEplSdoType   SdoType)
{
    tEplKernel      Ret = kEplSuccessful;

        return Ret;
}


//---------------------------------------------------------------------------
//
// Function:    EplSdoAsySeqSendData
//
// Description: send sata unsing a established connection
//
//
//
// Parameters:  pSdoSeqConHdl_p = connection handle
//              uiDataSize_p    = Size of Frame to send
//                                  -> wihtout SDO sequence layer header, Asnd header
//                                     and ethernetnet
//                                  ==> SDO Sequence layer payload
//              SdoType          = Type of the SDO connection
//
//
// Returns:     tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoAsySeqSendData(tEplSdoSeqConHdl SdoSeqConHdl_p,
                                 unsigned int    uiDataSize_p,
                                 tEplFrame*      pabData_p,
                                 void *          pUserArg_p)
{
    tEplKernel      Ret = kEplSuccessful;
    tPdiAsyncStatus PdiRet = kPdiAsyncStatusSuccessful;
    tObjAccSdoComCon PdiObjAccCon;

    if (uiDataSize_p == 0)
    {
        // this is a sequence layer acknowledge -> ignore it, because we only use command layer!
        goto exit;
    }

    // set pointer to SDO command frame
    PdiObjAccCon.m_pSdoCmdFrame =
    (tEplAsySdoCom *) &pabData_p->m_Data.m_Asnd.m_Payload.m_SdoSequenceFrame.m_le_abSdoSeqPayload;
    PdiObjAccCon.m_uiSizeOfFrame = uiDataSize_p;        // size of SDO command frame
    // set SDO cmd layer handle
    PdiObjAccCon.m_pUserArg = pUserArg_p;               // forward general purpose user argument

    PdiRet = CnApiAsync_postMsg(
                    kPdiAsyncMsgIntObjAccResp,
                    (BYTE *) &PdiObjAccCon,
                    NULL,
                    NULL,
                    NULL,
                    0);

    if (PdiRet == kPdiAsyncStatusRetry)
    {
        Ret = kEplSdoSeqConnectionBusy;
    }
    else if (PdiRet != kPdiAsyncStatusSuccessful)
    {
        Ret = kEplInvalidOperation;
    }

exit:
        return Ret;
}


//---------------------------------------------------------------------------
//
// Function:    EplSdoAsySeqProcessEvent
//
// Description: function processes extern events
//              -> later needed for timeout controll with timer-module
//
//
//
// Parameters:  pEvent_p = pointer to event
//
//
// Returns:     tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoAsySeqProcessEvent(tEplEvent* pEvent_p)
{
    tEplKernel      Ret = kEplSuccessful;

        return Ret;

}

//---------------------------------------------------------------------------
//
// Function:    EplSdoAsySeqDelCon
//
// Description: del and close one connection
//
//
//
// Parameters:  SdoSeqConHdl_p = handle of connection
//
//
// Returns:     tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoAsySeqDelCon(tEplSdoSeqConHdl SdoSeqConHdl_p)
{
    tEplKernel      Ret = kEplSuccessful;

        return Ret;

}

//=========================================================================//
//                                                                         //
//          P R I V A T E   F U N C T I O N S                              //
//                                                                         //
//=========================================================================//

//---------------------------------------------------------------------------
//
// Function:    EplEplSdoAsySeqProcess
//
// Description: intern function to process the asynchronus SDO Sequence Layer
//              state maschine
//
//
//
// Parameters:  uiHandle_p      = index of the control structure of the connection
//              uiDataSize_p    = size of data frame to process (can be 0)
//                                  -> without size of sequence header and Asnd header!!!
//
//              pData_p         = pointer to frame to send (can be NULL)
//              pRecFrame_p     = pointer to received frame (can be NULL)
//              Event_p         = Event to process
//
//
//
// Returns:     tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
//static tEplKernel EplSdoAsySeqProcess(unsigned int  uiHandle_p,
//                                         unsigned int       uiDataSize_p,
//                                         tEplFrame*         pData_p,
//                                         tEplAsySdoSeq*     pRecFrame_p,
//                                         tEplAsySdoSeqEvent Event_p)
//
//{
//    tEplKernel      Ret = kEplSuccessful;
//
//        return Ret;
//
//}

//---------------------------------------------------------------------------
//
// Function:    EplSdoAsySeqSendIntern
//
// Description: intern function to create and send a frame
//              -> if uiDataSize_p == 0 create a frame with infos from
//                 pAsySdoSeqCon_p
//
//
//
// Parameters:  pAsySdoSeqCon_p = pointer to control structure of the connection
//              uiDataSize_p    = size of data frame to process (can be 0)
//                                  -> without size of sequence header and Asnd header!!!
//              pData_p         = pointer to frame to process (can be NULL)
//              fFrameInHistory = if TRUE frame is saved to history else not
//
//
//
// Returns:     tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
//static tEplKernel EplSdoAsySeqSendIntern(tEplAsySdoSeqCon*  pAsySdoSeqCon_p,
//                                         unsigned int       uiDataSize_p,
//                                         tEplFrame*         pData_p,
//                                         BOOL               fFrameInHistory_p)
//{
//    tEplKernel      Ret = kEplSuccessful;
//
//        return Ret;
//}

//---------------------------------------------------------------------------
//
// Function:    EplSdoAsySeqSendLowerLayer
//
// Description: intern function to send a previously created frame to lower layer
//
// Parameters:  pAsySdoSeqCon_p = pointer to control structure of the connection
//              uiDataSize_p    = size of data frame to process (can be 0)
//                                  -> without size of Asnd header!!!
//              pData_p         = pointer to frame to process (can be NULL)
//
// Returns:     tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
//static tEplKernel EplSdoAsySeqSendLowerLayer(tEplAsySdoSeqCon*  pAsySdoSeqCon_p,
//                                         unsigned int       uiDataSize_p,
//                                         tEplFrame*         pEplFrame_p)
//{
//    tEplKernel      Ret = kEplSuccessful;
//
//        return Ret;
//}

//---------------------------------------------------------------------------
//
// Function:        EplSdoAsyReceiveCb
//
// Description:     callback-function for received frames from lower layer
//
//
//
// Parameters:      ConHdl_p        = handle of the connection
//                  pSdoSeqData_p   = pointer to frame
//                  uiDataSize_p    = size of frame
//
//
// Returns:         tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
tEplKernel PUBLIC EplSdoAsyReceiveCb (
                tEplSdoConHdl       ConHdl_p,
                tEplAsySdoSeq*      pSdoSeqData_p,
                unsigned int        uiDataSize_p)
{
    tEplKernel      Ret = kEplSuccessful;

        return Ret;
}

//---------------------------------------------------------------------------
//
// Function:        EplSdoAsyInitHistory
//
// Description:     init function for history buffer
//
//
//
// Parameters:
//
//
// Returns:         tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
//static tEplKernel EplSdoAsyInitHistory(tEplAsySdoSeqCon*  pAsySdoSeqCon_p)
//{
//    tEplKernel      Ret = kEplSuccessful;
//
//        return Ret;
//}


//---------------------------------------------------------------------------
//
// Function:        EplSdoAsyAddFrameToHistory
//
// Description:     function to add a frame to the history buffer
//
//
//
// Parameters:      pAsySdoSeqCon_p = pointer to control structure of this connection
//                  pFrame_p        = pointer to frame
//                  uiSize_p        = size of the frame
//                                     -> without size of the ethernet header
//                                        and the asnd header
//
// Returns:         tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
//static tEplKernel EplSdoAsyAddFrameToHistory(tEplAsySdoSeqCon*  pAsySdoSeqCon_p,
//                                        tEplFrame*      pFrame_p,
//                                        unsigned int    uiSize_p)
//{
//    tEplKernel      Ret = kEplSuccessful;
//
//        return Ret;
//}


//---------------------------------------------------------------------------
//
// Function:        EplSdoAsyAckFrameToHistory
//
// Description:     function to delete acknowledged frames fron history buffer
//
//
//
// Parameters:      pAsySdoSeqCon_p = pointer to control structure of this connection
//                  bRecSeqNumber_p = receive sequence number of the received frame
//
//
// Returns:         tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
//static tEplKernel EplSdoAsyAckFrameToHistory(tEplAsySdoSeqCon*  pAsySdoSeqCon_p,
//                                        BYTE   bRecSeqNumber_p)
//{
//    tEplKernel      Ret = kEplSuccessful;
//
//        return Ret;
//}

//---------------------------------------------------------------------------
//
// Function:        EplSdoAsyReadFromHistory
//
// Description:     function to one frame from history
//
//
//
// Parameters:      pAsySdoSeqCon_p = pointer to control structure of this connection
//                  ppFrame_p       = pointer to pointer to the buffer of the stored frame
//                  puiSize_p       = OUT: size of the frame
//                  fInitRead       = bool which indicate a start of retransmission
//                                      -> return last not acknowledged message if TRUE
//
//
// Returns:         tEplKernel = errorcode
//
//
// State:
//
//---------------------------------------------------------------------------
//static tEplKernel EplSdoAsyReadFromHistory(tEplAsySdoSeqCon*  pAsySdoSeqCon_p,
//                                           tEplFrame**      ppFrame_p,
//                                           unsigned int*    puiSize_p,
//                                           BOOL             fInitRead_p)
//{
//    tEplKernel      Ret = kEplSuccessful;
//
//        return Ret;
//
//}

//---------------------------------------------------------------------------
//
// Function:        EplSdoAsyGetFreeEntriesFromHistory
//
// Description:     function returns the number of free histroy entries
//
//
//
// Parameters:      pAsySdoSeqCon_p = pointer to control structure of this connection
//
//
// Returns:         unsigned int    = number of free entries
//
//
// State:
//
//---------------------------------------------------------------------------
//static unsigned int EplSdoAsyGetFreeEntriesFromHistory(tEplAsySdoSeqCon*  pAsySdoSeqCon_p)
//{
//    return 0;
//}

//---------------------------------------------------------------------------
//
// Function:        EplSdoAsySeqSetTimer
//
// Description:     function sets or modify timer in timermosule
//
//
//
// Parameters:      pAsySdoSeqCon_p = pointer to control structure of this connection
//                  ulTimeout       = timeout in ms
//
//
// Returns:         unsigned int    = number of free entries
//
//
// State:
//
//---------------------------------------------------------------------------
//static tEplKernel EplSdoAsySeqSetTimer(tEplAsySdoSeqCon* pAsySdoSeqCon_p,
//                                        unsigned long    ulTimeout)
//{
//tEplKernel      Ret = kEplSuccessful;
//
//    return Ret;
//}

// EOF

