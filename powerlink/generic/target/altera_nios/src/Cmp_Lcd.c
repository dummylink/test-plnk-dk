/*******************************************************************************
* Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
* All rights reserved. All use of this software and documentation is
* subject to the License Agreement located at the end of this file below.
*/

/**
********************************************************************************

\file       Cmp_Lcd.c

\brief      Non generic Lcd print functions

\author     mairt

\date       19.03.2012

\since      19.03.2012

*******************************************************************************/
/* includes */
#include "Cmp_Lcd.h"

#include "lcd.h"



/******************************************************************************/
/* defines */

/******************************************************************************/
/* typedefs */

/******************************************************************************/
/* external variable declarations */

/******************************************************************************/
/* global variables */

static char aStrNmtState_l[10][17] = {"INVALID         ",
                                     "OFF             ",
                                     "INITIALISATION  ",
                                     "NOT ACTIVE      ",
                                     "BASIC ETHERNET  ",
                                     "PRE_OP1         ",
                                     "PRE_OP2         ",
                                     "READY_TO_OP     ",
                                     "OPERATIONAL     ",
                                     "STOPPED         " };

/******************************************************************************/
/* function declarations */

/******************************************************************************/
/* private functions */

/******************************************************************************/
/* functions */

/**
********************************************************************************
\brief  Init the LCD display
*******************************************************************************/
void SysComp_LcdInit(void)
{
    LCD_Init();
}

/**
********************************************************************************
\brief  Clear the LCD display
*******************************************************************************/
void SysComp_LcdClear(void)
{
    LCD_Clear();
}

/**
********************************************************************************
\brief  writes Text to LCD display
\param  The text to be written
*******************************************************************************/
void SysComp_LcdSetText(char* Text)
{
    LCD_Show_Text(Text);
}

/**
********************************************************************************
\brief  Test the LCD display
*******************************************************************************/
void SysComp_LcdTest(void)
{
  char Text1[16] = "POWERLINK SLAVE";
  char Text2[16] = "-- by B & R -- ";
  //  Initial LCD
  LCD_Init();
  //  Show Text to LCD
  LCD_Show_Text(Text1);
  //  Change Line2
  LCD_Line2();
  //  Show Text to LCD
  LCD_Show_Text(Text2);
}

/**
********************************************************************************
\brief  writes NMT state to LCD display
\param  NmtState_p  IN: current state machine value
*******************************************************************************/
void SysComp_LcdPrintState(tEplNmtState NmtState_p)
{
    LCD_Line2();
    switch (NmtState_p)
    {
        case kEplNmtGsOff               : LCD_Show_Text(aStrNmtState_l[1]); break;
        case kEplNmtGsInitialising      : LCD_Show_Text(aStrNmtState_l[2]); break;
        case kEplNmtGsResetApplication  : LCD_Show_Text(aStrNmtState_l[2]); break;
        case kEplNmtGsResetCommunication: LCD_Show_Text(aStrNmtState_l[2]); break;
        case kEplNmtGsResetConfiguration: LCD_Show_Text(aStrNmtState_l[2]); break;
        case kEplNmtCsNotActive         : LCD_Show_Text(aStrNmtState_l[3]); break;
        case kEplNmtCsPreOperational1   : LCD_Show_Text(aStrNmtState_l[5]); break;
        case kEplNmtCsStopped           : LCD_Show_Text(aStrNmtState_l[9]); break;
        case kEplNmtCsPreOperational2   : LCD_Show_Text(aStrNmtState_l[6]); break;
        case kEplNmtCsReadyToOperate    : LCD_Show_Text(aStrNmtState_l[7]); break;
        case kEplNmtCsOperational       : LCD_Show_Text(aStrNmtState_l[8]); break;
        case kEplNmtCsBasicEthernet     : LCD_Show_Text(aStrNmtState_l[4]); break;
        default:
        LCD_Show_Text(aStrNmtState_l[0]);
        break;
    }

}

/**
********************************************************************************
\brief    print node info on LCD

This function writes the node id to the LCD display and signals if this image
is the factory oder user image.

\param    fIsUser_p     is this image the user image?
\param    nodeID        the node ID which was read
*******************************************************************************/
void SysComp_LcdPrintNodeInfo (BOOL fIsUser_p, WORD wNodeId_p)
{
    char TextNodeID[17];

    if (fIsUser_p)
    {
        sprintf(TextNodeID, "User/ID:0x%02X", wNodeId_p);
    }
    else
    {
        sprintf(TextNodeID, "Factory/ID:0x%02X", wNodeId_p);
    }

    LCD_Clear();
    LCD_Show_Text(TextNodeID);

}
