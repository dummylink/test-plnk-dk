/****************************************************************************

  (c) SYSTEC electronic GmbH, D-07973 Greiz, August-Bebel-Str. 29
      www.systec-electronic.com

  Project:      openPOWERLINK

  Description:  Abstract Memory Interface for ARM processors

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
                    ...

  -------------------------------------------------------------------------

  Revision History:

  r.s.: first implemetation

  2008-11-07  d.k.: duplicate functions for little endian and big endian

****************************************************************************/

#include "cnApiAmi.h"

//---------------------------------------------------------------------------
//  Typdefinitionen
//---------------------------------------------------------------------------


typedef struct
{
   DWORD  m_dwDword;

} tdwStruct;

typedef struct
{
   QWORD  m_qwQword;

} tqwStruct;

typedef union
{
    DWORD   m_dwValue;
    BYTE    m_abValue[4];

} tSplittDword;

typedef union
{
    QWORD   m_qwValue;
    BYTE    m_abValue[8];

} tSplittQword;

#define AMI_LOBYTE(val)                     (BYTE) (val      )
#define AMI_HIBYTE(val)                     (BYTE) (val >>  8)
#define AMI_LOWORD(val)                     (WORD) (val      )
#define AMI_HIWORD(val)                     (WORD) (val >> 16)

#define AMI_READ_BYTE(val,ptr)              (val) =                          *(BYTE *) (ptr)
#define AMI_READ_WORD(val,ptr)              (val) =                (WORD)  (*((BYTE *) (ptr) + 1));\
                                            (val) = ((val) << 8) | (WORD)  (*((BYTE *) (ptr) + 0));
#define AMI_READ_DWORD(val,ptr)             (val) =                (DWORD) (*((BYTE *) (ptr) + 3));\
                                            (val) = ((val) << 8) | (DWORD) (*((BYTE *) (ptr) + 2));\
                                            (val) = ((val) << 8) | (DWORD) (*((BYTE *) (ptr) + 1));\
                                            (val) = ((val) << 8) | (DWORD) (*((BYTE *) (ptr) + 0));

#define AMI_WRITE_BYTE(ptr,val)               *(BYTE *) (ptr)       =                        (val)
#define AMI_WRITE_WORD(ptr,val)             (*((BYTE *) (ptr) + 0)) =             AMI_LOBYTE (val);\
                                            (*((BYTE *) (ptr) + 1)) =             AMI_HIBYTE (val);
#define AMI_WRITE_DWORD(ptr,val)            (*((BYTE *) (ptr) + 0)) = AMI_LOBYTE (AMI_LOWORD (val));\
                                            (*((BYTE *) (ptr) + 1)) = AMI_HIBYTE (AMI_LOWORD (val));\
                                            (*((BYTE *) (ptr) + 2)) = AMI_LOBYTE (AMI_HIWORD (val));\
                                            (*((BYTE *) (ptr) + 3)) = AMI_HIBYTE (AMI_HIWORD (val));


//=========================================================================//
//                                                                         //
//          P U B L I C   F U N C T I O N S                                //
//                                                                         //
//=========================================================================//

//---------------------------------------------------------------------------
//
// Function:    AmiSetXXXToBe()
//
// Description: writes the specified value to the absolute address in
//              big endian
//
// Parameters:  pAddr_p                 = absolute address
//              xXXXVal_p               = value
//
// Returns:     (none)
//
// State:
//
//---------------------------------------------------------------------------

//------------< write BYTE in big endian >--------------------------
/*
void    AmiSetByteToBe (void * pAddr_p, BYTE bByteVal_p)
{

   *(BYTE *)pAddr_p = bByteVal_p;

}
*/



//------------< write WORD in big endian >--------------------------

void    AmiSetWordToBe (void * pAddr_p, WORD wWordVal_p)
{
    (*((BYTE *) (pAddr_p) + 0)) = AMI_HIBYTE (wWordVal_p);
    (*((BYTE *) (pAddr_p) + 1)) = AMI_LOBYTE (wWordVal_p);
}



//------------< write DWORD in big endian >-------------------------

void    AmiSetDwordToBe (void * pAddr_p, DWORD dwDwordVal_p)
{
    (*((BYTE *) (pAddr_p) + 0)) = AMI_HIBYTE (AMI_HIWORD (dwDwordVal_p));
    (*((BYTE *) (pAddr_p) + 1)) = AMI_LOBYTE (AMI_HIWORD (dwDwordVal_p));
    (*((BYTE *) (pAddr_p) + 2)) = AMI_HIBYTE (AMI_LOWORD (dwDwordVal_p));
    (*((BYTE *) (pAddr_p) + 3)) = AMI_LOBYTE (AMI_LOWORD (dwDwordVal_p));
}




//---------------------------------------------------------------------------
//
// Function:    AmiSetXXXToLe()
//
// Description: writes the specified value to the absolute address in
//              little endian
//
// Parameters:  pAddr_p                 = absolute address
//              xXXXVal_p               = value
//
// Returns:     (none)
//
// State:
//
//---------------------------------------------------------------------------

//------------< write BYTE in little endian >--------------------------
/*
void    AmiSetByteToLe (void * pAddr_p, BYTE bByteVal_p)
{

// Diese Funktion dient zum Schreiben eines Bytes auf der angegebenen
// absoluten Adresse. Die Funktionen der Gruppe <AmiSetxxx> werden verwendet,
// um Daten zum Austausch mit anderen Systemen im Intel-Format abzulegen.


   AMI_WRITE_BYTE (pAddr_p, bByteVal_p);

}
*/



//------------< write WORD in little endian >--------------------------

void    AmiSetWordToLe (void * pAddr_p, WORD wWordVal_p)
{
   AMI_WRITE_WORD (pAddr_p, wWordVal_p);
}




//------------< write DWORD in little endian >-------------------------

void    AmiSetDwordToLe (void * pAddr_p, DWORD dwDwordVal_p)
{
   AMI_WRITE_DWORD (pAddr_p, dwDwordVal_p);
}


//------------< read WORD in big endian >---------------------------

 WORD    AmiGetWordFromBe (void * pAddr_p)
{
WORD wValue;

    (wValue) =                   (WORD)  (*((BYTE *) (pAddr_p) + 0));
    (wValue) = ((wValue) << 8) | (WORD)  (*((BYTE *) (pAddr_p) + 1));

    return ( wValue );
}




//------------< read DWORD in big endian >--------------------------

 DWORD    AmiGetDwordFromBe (void * pAddr_p)
{
DWORD dwValue;

    (dwValue) =                    (DWORD) (*((BYTE *) (pAddr_p) + 0));\
    (dwValue) = ((dwValue) << 8) | (DWORD) (*((BYTE *) (pAddr_p) + 1));\
    (dwValue) = ((dwValue) << 8) | (DWORD) (*((BYTE *) (pAddr_p) + 2));\
    (dwValue) = ((dwValue) << 8) | (DWORD) (*((BYTE *) (pAddr_p) + 3));

    return ( dwValue );

}

//------------< read BYTE in little endian >---------------------------
/*
BYTE    AmiGetByteFromLe (void * pAddr_p)
{

// Diese Funktion dient zum Lesen eines Bytes von der angegebenen absoluten
// Adresse. Die Funktionen der Gruppe <AmiGetxxx> werden verwendet, um Daten,
// die mit einem anderen System ausgetauscht wurden und im Intel-Format abge-
// legt sind, zu lesen.


BYTE bValue;

    AMI_READ_BYTE (bValue, pAddr_p);

    return ( bValue );

}
*/



//------------< read WORD in little endian >---------------------------

 WORD    AmiGetWordFromLe (void * pAddr_p)
{

// Diese Funktion dient zum Lesen eines Words von der angegebenen absoluten
// Adresse. Die Funktionen der Gruppe <AmiGetxxx> werden verwendet, um Daten,
// die mit einem anderen System ausgetauscht wurden und im Intel-Format abge-
// legt sind, zu lesen.


WORD wValue;

    AMI_READ_WORD (wValue, pAddr_p);

    return ( wValue );

}




//------------< read DWORD in little endian >--------------------------

 DWORD    AmiGetDwordFromLe (void * pAddr_p)
{

// Diese Funktion dient zum Lesen eines Dwords von der angegebenen absoluten
// Adresse. Die Funktionen der Gruppe <AmiGetxxx> werden verwendet, um Daten,
// die mit einem anderen System ausgetauscht wurden und im Intel-Format abge-
// legt sind, zu lesen.


DWORD dwValue;

    AMI_READ_DWORD (dwValue, pAddr_p);

    return ( dwValue );

}


//---------------------------------------------------------------------------
//
// Function:    AmiSetDword24ToBe()
//
// Description: sets a 24 bit value to a buffer in big endian
//
// Parameters:  pAddr_p         = pointer to destination buffer
//              dwDwordVal_p    = value to set
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetDword24ToBe (void * pAddr_p, DWORD dwDwordVal_p)
{
tSplittDword dwValue;

    dwValue.m_dwValue = dwDwordVal_p;

    ((BYTE *) pAddr_p)[0] = dwValue.m_abValue[0];
    ((BYTE *) pAddr_p)[1] = dwValue.m_abValue[1];
    ((BYTE *) pAddr_p)[2] = dwValue.m_abValue[2];

}


//---------------------------------------------------------------------------
//
// Function:    AmiSetDword24ToLe()
//
// Description: sets a 24 bit value to a buffer in little endian
//
// Parameters:  pAddr_p         = pointer to destination buffer
//              dwDwordVal_p    = value to set
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetDword24ToLe (void * pAddr_p, DWORD dwDwordVal_p)
{

    ((BYTE *) pAddr_p)[0] = ((BYTE *) &dwDwordVal_p)[0];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &dwDwordVal_p)[1];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &dwDwordVal_p)[2];

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetDword24()
//
// Description: reads a 24 bit value from a buffer
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:      DWORD           = read value
//
// State:       not tested
//
//---------------------------------------------------------------------------

 DWORD  AmiGetDword24FromBe (void * pAddr_p)
{

tdwStruct      dwStruct;

    dwStruct.m_dwDword  = AmiGetDwordFromBe (pAddr_p);
    dwStruct.m_dwDword >>= 8;

    return ( dwStruct.m_dwDword );

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetDword24FromLe()
//
// Description: reads a 24 bit value from a buffer in little endian
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:      DWORD           = read value
//
// State:       not tested
//
//---------------------------------------------------------------------------

 DWORD  AmiGetDword24FromLe (void * pAddr_p)
{

tdwStruct      dwStruct;

    dwStruct.m_dwDword  = AmiGetDwordFromLe (pAddr_p);
    dwStruct.m_dwDword &= 0x00FFFFFF;

    return ( dwStruct.m_dwDword );

}

//#ifdef USE_VAR64

//---------------------------------------------------------------------------
//
// Function:    AmiSetQword64ToBe()
//
// Description: sets a 64 bit value to a buffer in big endian
//
// Parameters:  pAddr_p         = pointer to destination buffer
//              qwQwordVal_p    = quadruple word value
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword64ToBe (void * pAddr_p, QWORD qwQwordVal_p)
{

    ((BYTE *) pAddr_p)[0] = ((BYTE *) &qwQwordVal_p)[7];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &qwQwordVal_p)[6];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &qwQwordVal_p)[5];
    ((BYTE *) pAddr_p)[3] = ((BYTE *) &qwQwordVal_p)[4];
    ((BYTE *) pAddr_p)[4] = ((BYTE *) &qwQwordVal_p)[3];
    ((BYTE *) pAddr_p)[5] = ((BYTE *) &qwQwordVal_p)[2];
    ((BYTE *) pAddr_p)[6] = ((BYTE *) &qwQwordVal_p)[1];
    ((BYTE *) pAddr_p)[7] = ((BYTE *) &qwQwordVal_p)[0];

}


//---------------------------------------------------------------------------
//
// Function:    AmiSetQword64ToLe()
//
// Description: sets a 64 bit value to a buffer in little endian
//
// Parameters:  pAddr_p         = pointer to destination buffer
//              qwQwordVal_p    = quadruple word value
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword64ToLe (void * pAddr_p, QWORD qwQwordVal_p)
{
tSplittQword    qwValue;

    qwValue.m_qwValue = qwQwordVal_p;

    ((BYTE*) pAddr_p)[0] = qwValue.m_abValue[0];
    ((BYTE*) pAddr_p)[1] = qwValue.m_abValue[1];
    ((BYTE*) pAddr_p)[2] = qwValue.m_abValue[2];
    ((BYTE*) pAddr_p)[3] = qwValue.m_abValue[3];
    ((BYTE*) pAddr_p)[4] = qwValue.m_abValue[4];
    ((BYTE*) pAddr_p)[5] = qwValue.m_abValue[5];
    ((BYTE*) pAddr_p)[6] = qwValue.m_abValue[6];
    ((BYTE*) pAddr_p)[7] = qwValue.m_abValue[7];

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetQword64FromBe()
//
// Description: reads a 64 bit value from a buffer in big endian
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

QWORD  AmiGetQword64FromBe (void * pAddr_p)
{

tqwStruct      qwStruct;

    ((BYTE *) &qwStruct.m_qwQword)[0] = ((BYTE *) pAddr_p)[7];
    ((BYTE *) &qwStruct.m_qwQword)[1] = ((BYTE *) pAddr_p)[6];
    ((BYTE *) &qwStruct.m_qwQword)[2] = ((BYTE *) pAddr_p)[5];
    ((BYTE *) &qwStruct.m_qwQword)[3] = ((BYTE *) pAddr_p)[4];
    ((BYTE *) &qwStruct.m_qwQword)[4] = ((BYTE *) pAddr_p)[3];
    ((BYTE *) &qwStruct.m_qwQword)[5] = ((BYTE *) pAddr_p)[2];
    ((BYTE *) &qwStruct.m_qwQword)[6] = ((BYTE *) pAddr_p)[1];
    ((BYTE *) &qwStruct.m_qwQword)[7] = ((BYTE *) pAddr_p)[0];

    return ( qwStruct.m_qwQword );

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetQword64FromLe()
//
// Description: reads a 64 bit value from a buffer in little endian
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

QWORD  AmiGetQword64FromLe (void * pAddr_p)
{
tSplittQword    qwValue;

    qwValue.m_abValue[0] = ((BYTE*) pAddr_p)[0];
    qwValue.m_abValue[1] = ((BYTE*) pAddr_p)[1];
    qwValue.m_abValue[2] = ((BYTE*) pAddr_p)[2];
    qwValue.m_abValue[3] = ((BYTE*) pAddr_p)[3];
    qwValue.m_abValue[4] = ((BYTE*) pAddr_p)[4];
    qwValue.m_abValue[5] = ((BYTE*) pAddr_p)[5];
    qwValue.m_abValue[6] = ((BYTE*) pAddr_p)[6];
    qwValue.m_abValue[7] = ((BYTE*) pAddr_p)[7];

    return (QWORD) qwValue.m_qwValue;
}


//---------------------------------------------------------------------------
//
// Function:    AmiSetQword40ToBe()
//
// Description: sets a 40 bit value to a buffer in big endian
//
// Parameters:  pAddr_p         = pointer to destination buffer
//              qwQwordVal_p    = quadruple word value
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword40ToBe (void * pAddr_p, QWORD qwQwordVal_p)
{

    ((BYTE *) pAddr_p)[0] = ((BYTE *) &qwQwordVal_p)[4];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &qwQwordVal_p)[3];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &qwQwordVal_p)[2];
    ((BYTE *) pAddr_p)[3] = ((BYTE *) &qwQwordVal_p)[1];
    ((BYTE *) pAddr_p)[4] = ((BYTE *) &qwQwordVal_p)[0];

}


//---------------------------------------------------------------------------
//
// Function:    AmiSetQword40ToLe()
//
// Description: sets a 40 bit value to a buffer in little endian
//
// Parameters:  pAddr_p         = pointer to destination buffer
//              qwQwordVal_p    = quadruple word value
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword40ToLe (void * pAddr_p, QWORD qwQwordVal_p)
{
tSplittQword qwValue;

    qwValue.m_qwValue = qwQwordVal_p;

    ((BYTE*) pAddr_p)[0] = qwValue.m_abValue[0];
    ((BYTE*) pAddr_p)[1] = qwValue.m_abValue[1];
    ((BYTE*) pAddr_p)[2] = qwValue.m_abValue[2];
    ((BYTE*) pAddr_p)[3] = qwValue.m_abValue[3];
    ((BYTE*) pAddr_p)[4] = qwValue.m_abValue[4];

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetQword40FromBe()
//
// Description: reads a 40 bit value from a buffer in big endian
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:      QWORD
//
// State:       not tested
//
//---------------------------------------------------------------------------

QWORD  AmiGetQword40FromBe (void * pAddr_p)
{

tqwStruct      qwStruct;

    qwStruct.m_qwQword  = AmiGetQword64FromBe (pAddr_p);
    qwStruct.m_qwQword >>= 24;

    return ( qwStruct.m_qwQword );

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetQword40FromLe()
//
// Description: reads a 40 bit value from a buffer in little endian
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:      QWORD
//
// State:       not tested
//
//---------------------------------------------------------------------------

QWORD  AmiGetQword40FromLe (void * pAddr_p)
{

QWORD      qwValue;

    qwValue  = AmiGetQword64FromLe (pAddr_p);
    qwValue &= 0x000000FFFFFFFFFFLL;

    return ( qwValue );

}


//---------------------------------------------------------------------------
//
// Function:    AmiSetQword48ToBe()
//
// Description: sets a 48 bit value to a buffer in big endian
//
// Parameters:  pAddr_p         = pointer to destination buffer
//              qwQwordVal_p    = quadruple word value
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword48ToBe (void * pAddr_p, QWORD qwQwordVal_p)
{

    ((BYTE *) pAddr_p)[0] = ((BYTE *) &qwQwordVal_p)[5];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &qwQwordVal_p)[4];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &qwQwordVal_p)[3];
    ((BYTE *) pAddr_p)[3] = ((BYTE *) &qwQwordVal_p)[2];
    ((BYTE *) pAddr_p)[4] = ((BYTE *) &qwQwordVal_p)[1];
    ((BYTE *) pAddr_p)[5] = ((BYTE *) &qwQwordVal_p)[0];

}


//---------------------------------------------------------------------------
//
// Function:    AmiSetQword48ToLe()
//
// Description: sets a 48 bit value to a buffer in little endian
//
// Parameters:  pAddr_p         = pointer to destination buffer
//              qwQwordVal_p    = quadruple word value
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword48ToLe (void * pAddr_p, QWORD qwQwordVal_p)
{
tSplittQword qwValue;

    qwValue.m_qwValue = qwQwordVal_p;

    ((BYTE*) pAddr_p)[0] = qwValue.m_abValue[0];
    ((BYTE*) pAddr_p)[1] = qwValue.m_abValue[1];
    ((BYTE*) pAddr_p)[2] = qwValue.m_abValue[2];
    ((BYTE*) pAddr_p)[3] = qwValue.m_abValue[3];
    ((BYTE*) pAddr_p)[4] = qwValue.m_abValue[4];
    ((BYTE*) pAddr_p)[5] = qwValue.m_abValue[5];

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetQword48FromBe()
//
// Description: reads a 48 bit value from a buffer in big endian
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:      QWORD
//
// State:       not tested
//
//---------------------------------------------------------------------------

QWORD  AmiGetQword48FromBe (void * pAddr_p)
{

tqwStruct      qwStruct;

    qwStruct.m_qwQword  = AmiGetQword64FromBe (pAddr_p);
    qwStruct.m_qwQword >>= 16;

    return ( qwStruct.m_qwQword );

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetQword48FromLe()
//
// Description: reads a 48 bit value from a buffer in little endian
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:      QWORD
//
// State:       not tested
//
//---------------------------------------------------------------------------

QWORD  AmiGetQword48FromLe (void * pAddr_p)
{

QWORD      qwValue;

    qwValue  = AmiGetQword64FromLe (pAddr_p);
    qwValue &= 0x0000FFFFFFFFFFFFLL;

    return ( qwValue );

}


//---------------------------------------------------------------------------
//
// Function:    AmiSetQword56ToBe()
//
// Description: sets a 56 bit value to a buffer in big endian
//
// Parameters:  pAddr_p         = pointer to destination buffer
//              qwQwordVal_p    = quadruple word value
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword56ToBe (void * pAddr_p, QWORD qwQwordVal_p)
{

    ((BYTE *) pAddr_p)[0] = ((BYTE *) &qwQwordVal_p)[6];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &qwQwordVal_p)[5];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &qwQwordVal_p)[4];
    ((BYTE *) pAddr_p)[3] = ((BYTE *) &qwQwordVal_p)[3];
    ((BYTE *) pAddr_p)[4] = ((BYTE *) &qwQwordVal_p)[2];
    ((BYTE *) pAddr_p)[5] = ((BYTE *) &qwQwordVal_p)[1];
    ((BYTE *) pAddr_p)[6] = ((BYTE *) &qwQwordVal_p)[0];

}


//---------------------------------------------------------------------------
//
// Function:    AmiSetQword56ToLe()
//
// Description: sets a 56 bit value to a buffer in little endian
//
// Parameters:  pAddr_p         = pointer to destination buffer
//              qwQwordVal_p    = quadruple word value
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword56ToLe (void * pAddr_p, QWORD qwQwordVal_p)
{
tSplittQword qwValue;

    qwValue.m_qwValue = qwQwordVal_p;

    ((BYTE*) pAddr_p)[0] = qwValue.m_abValue[0];
    ((BYTE*) pAddr_p)[1] = qwValue.m_abValue[1];
    ((BYTE*) pAddr_p)[2] = qwValue.m_abValue[2];
    ((BYTE*) pAddr_p)[3] = qwValue.m_abValue[3];
    ((BYTE*) pAddr_p)[4] = qwValue.m_abValue[4];
    ((BYTE*) pAddr_p)[5] = qwValue.m_abValue[5];
    ((BYTE*) pAddr_p)[6] = qwValue.m_abValue[6];

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetQword56FromBe()
//
// Description: reads a 56 bit value from a buffer in big endian
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:      QWORD
//
// State:       not tested
//
//---------------------------------------------------------------------------

QWORD  AmiGetQword56FromBe (void * pAddr_p)
{

tqwStruct      qwStruct;

    qwStruct.m_qwQword  = AmiGetQword64FromBe (pAddr_p);
    qwStruct.m_qwQword >>= 8;

    return ( qwStruct.m_qwQword );

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetQword56FromLe()
//
// Description: reads a 56 bit value from a buffer in little endian
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:      QWORD
//
// State:       not tested
//
//---------------------------------------------------------------------------

QWORD  AmiGetQword56FromLe (void * pAddr_p)
{

QWORD      qwValue;

    qwValue  = AmiGetQword64FromLe (pAddr_p);
    qwValue &= 0x00FFFFFFFFFFFFFFLL;

    return ( qwValue );

}


//---------------------------------------------------------------------------
//
// Function:    AmiSetTimeOfDay()
//
// Description: sets a TIME_OF_DAY (CANopen) value to a buffer
//
// Parameters:  pAddr_p         = pointer to destination buffer
//              pTimeOfDay_p    = pointer to struct TIME_OF_DAY
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetTimeOfDay (void * pAddr_p, tTimeOfDay * pTimeOfDay_p)
{

    AmiSetDwordToLe (((BYTE *) pAddr_p),     pTimeOfDay_p->m_dwMs & 0x0FFFFFFF);
    AmiSetWordToLe  (((BYTE *) pAddr_p) + 4, pTimeOfDay_p->m_wDays);

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetTimeOfDay()
//
// Description: reads a TIME_OF_DAY (CANopen) value from a buffer
//
// Parameters:  pAddr_p         = pointer to source buffer
//              pTimeOfDay_p    = pointer to struct TIME_OF_DAY
//
// Return:     void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiGetTimeOfDay (void * pAddr_p, tTimeOfDay * pTimeOfDay_p)
{

    pTimeOfDay_p->m_dwMs  = AmiGetDwordFromLe (((BYTE *) pAddr_p)) & 0x0FFFFFFF;
    pTimeOfDay_p->m_wDays = AmiGetWordFromLe  (((BYTE *) pAddr_p) + 4);

}

// EOF

