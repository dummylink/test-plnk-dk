/****************************************************************************

  (c) SYSTEC electronic GmbH, D-07973 Greiz, August-Bebel-Str. 29
      www.systec-electronic.com

  Project:      openPOWERLINK

  Description:  Abstract Memory Interface for big endian machines

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

  2006-06-13  d.k.: duplicate functions for big endian and little endian

****************************************************************************/

#include "cnApiAmi.h"

//---------------------------------------------------------------------------
// typedef
//---------------------------------------------------------------------------

typedef struct
{
   WORD  m_wWord;

} twStruct;

typedef struct
{
   DWORD  m_dwDword;

} tdwStruct;

typedef struct
{
   QWORD  m_qwQword;

} tqwStruct;



//=========================================================================//
//                                                                         //
//          P U B L I C   F U N C T I O N S                                //
//                                                                         //
//=========================================================================//

//------------< write WORD in little endian >--------------------------

void AmiSetWordToLe (void* pAddr_p, WORD wWordVal_p)
{
#if defined (__MICROBLAZE__)
BYTE *dst=(BYTE*)pAddr_p, *src=(BYTE*)&wWordVal_p;

   *(dst+0) = *(src+1);
   *(dst+1) = *(src+0);
#else
twStruct *  pwStruct;
twStruct wValue;

   wValue.m_wWord   = (WORD)((wWordVal_p & 0x00FF) << 8); //LSB to MSB
   wValue.m_wWord  |= (WORD)((wWordVal_p & 0xFF00) >> 8); //MSB to LSB

   pwStruct = (twStruct *)pAddr_p;
   pwStruct->m_wWord = wValue.m_wWord;
#endif
}



//------------< write DWORD in little endian >-------------------------

void AmiSetDwordToLe (void * pAddr_p, DWORD dwDwordVal_p)
{
#if defined (__MICROBLAZE__)
BYTE *dst=(BYTE*)pAddr_p, *src=(BYTE*)&dwDwordVal_p;
    
   *(dst+0) = *(src+3);
   *(dst+1) = *(src+2);
   *(dst+2) = *(src+1);
   *(dst+3) = *(src+0);
#else
tdwStruct *  pdwStruct;
tdwStruct dwValue;


   dwValue.m_dwDword = ((dwDwordVal_p & 0x000000FF)<<24); //LSB to MSB
   dwValue.m_dwDword|= ((dwDwordVal_p & 0x0000FF00)<<8);
   dwValue.m_dwDword|= ((dwDwordVal_p & 0x00FF0000)>>8 );
   dwValue.m_dwDword|= ((dwDwordVal_p & 0xFF000000)>>24); //MSB to LSB

   pdwStruct = (tdwStruct *)pAddr_p;
   pdwStruct->m_dwDword = dwValue.m_dwDword;
#endif

}


//------------< write WORD in big endian >--------------------------

void AmiSetWordToBe (void * pAddr_p, WORD wWordVal_p)
{
#if defined (__MICROBLAZE__)
BYTE *pDst = (BYTE *) pAddr_p, *pSrc = (BYTE *)&wWordVal_p;
    
   *pDst = *pSrc;
   *(pDst+1) = *(pSrc+1);
#else
twStruct *  pwStruct;

   pwStruct = (twStruct *)pAddr_p;
   pwStruct->m_wWord = wWordVal_p;
#endif

}



//------------< write DWORD in big endian >-------------------------

void AmiSetDwordToBe (void * pAddr_p, DWORD dwDwordVal_p)
{
#if defined (__MICROBLAZE__)
BYTE *dst=(BYTE*)pAddr_p, *src=(BYTE*)&dwDwordVal_p;
    
   *(dst+0) = *(src+0);
   *(dst+1) = *(src+1);
   *(dst+2) = *(src+2);
   *(dst+3) = *(src+3);
#else
tdwStruct *  pdwStruct;

   pdwStruct = (tdwStruct *)pAddr_p;
   pdwStruct->m_dwDword = dwDwordVal_p;
#endif

}

//------------< read WORD in little endian >---------------------------

WORD AmiGetWordFromLe (void * pAddr_p)
{
#if defined (__MICROBLAZE__)
BYTE *pSrc = pAddr_p;
WORD wDst;
    
   wDst = (*(pSrc+1) << 8) | (*(pSrc+0));
    
   return wDst;
#else
twStruct *  pwStruct;
twStruct wValue;

   pwStruct = (twStruct *)pAddr_p;

   wValue.m_wWord   = (WORD)((pwStruct->m_wWord & 0x00FF) << 8); //LSB to MSB
   wValue.m_wWord  |= (WORD)((pwStruct->m_wWord & 0xFF00) >> 8); //MSB to LSB

   return ( wValue.m_wWord );
#endif
}




//------------< read DWORD in little endian >--------------------------

DWORD  AmiGetDwordFromLe (void * pAddr_p)
{
#if defined (__MICROBLAZE__)
BYTE *pbSrc = pAddr_p;
    
   return (((DWORD)pbSrc[0]) <<  0) | 
           (((DWORD)pbSrc[1]) <<  8) |
           (((DWORD)pbSrc[2]) << 16) |
           (((DWORD)pbSrc[3]) << 24);
#else
tdwStruct *  pdwStruct;
tdwStruct dwValue;

   pdwStruct = (tdwStruct *)pAddr_p;

   dwValue.m_dwDword = ((pdwStruct->m_dwDword & 0x000000FF)<<24); //LSB to MSB
   dwValue.m_dwDword|= ((pdwStruct->m_dwDword & 0x0000FF00)<<8);
   dwValue.m_dwDword|= ((pdwStruct->m_dwDword & 0x00FF0000)>>8 );
   dwValue.m_dwDword|= ((pdwStruct->m_dwDword & 0xFF000000)>>24); //MSB to LSB

   return ( dwValue.m_dwDword );
#endif

}

//------------< read WORD in big endian >---------------------------

WORD AmiGetWordFromBe (void * pAddr_p)
{
#if defined (__MICROBLAZE__)
BYTE *pbSrc = pAddr_p;
    
   return ((DWORD)(pbSrc[0]) << 8) | 
          ((DWORD)(pbSrc[1]) << 0);
#else
twStruct *  pwStruct;

   pwStruct = (twStruct *)pAddr_p;
   return ( pwStruct->m_wWord );
#endif

}




//------------< read DWORD in big endian >--------------------------

DWORD AmiGetDwordFromBe (void * pAddr_p)
{
#if defined (__MICROBLAZE__)
BYTE *pbSrc = pAddr_p;
    
   return (((DWORD)pbSrc[0]) << 24) | 
           (((DWORD)pbSrc[1]) << 16) |
           (((DWORD)pbSrc[2]) <<  8) |
           (((DWORD)pbSrc[3]) <<  0);
#else
tdwStruct *  pdwStruct;

   pdwStruct = (tdwStruct *)pAddr_p;
   return ( pdwStruct->m_dwDword );
#endif

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
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void AmiSetDword24ToLe (void * pAddr_p, DWORD dwDwordVal_p)
{

    ((BYTE *) pAddr_p)[0] = ((BYTE *) &dwDwordVal_p)[2];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &dwDwordVal_p)[1];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &dwDwordVal_p)[0];

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
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void AmiSetDword24ToBe (void * pAddr_p, DWORD dwDwordVal_p)
{

    ((BYTE *) pAddr_p)[0] = ((BYTE *) &dwDwordVal_p)[0];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &dwDwordVal_p)[1];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &dwDwordVal_p)[2];

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

DWORD AmiGetDword24FromLe (void * pAddr_p)
{

tdwStruct      dwStruct;

    dwStruct.m_dwDword  = AmiGetDwordFromLe (pAddr_p) & 0x00FFFFFF;

    return ( dwStruct.m_dwDword );

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetDword24FromBe()
//
// Description: reads a 24 bit value from a buffer in big endian
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:      DWORD           = read value
//
// State:       not tested
//
//---------------------------------------------------------------------------

DWORD AmiGetDword24FromBe (void * pAddr_p)
{

tdwStruct      dwStruct;

    dwStruct.m_dwDword  = AmiGetDwordFromBe (pAddr_p);
    dwStruct.m_dwDword >>= 8;

    return ( dwStruct.m_dwDword );

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
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void AmiSetQword64ToLe (void * pAddr_p, QWORD qwQwordVal_p)
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
// Function:    AmiSetQword64ToBe()
//
// Description: sets a 64 bit value to a buffer in big endian
//
// Parameters:  pAddr_p         = pointer to destination buffer
//              qwQwordVal_p    = quadruple word value
//
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void AmiSetQword64ToBe (void * pAddr_p, QWORD qwQwordVal_p)
{
#if defined (__MICROBLAZE__)
BYTE *dst=(BYTE*)pAddr_p, *src=(BYTE*)&qwQwordVal_p;
    
    *(dst+0) = *(src+0);
    *(dst+1) = *(src+1);
    *(dst+2) = *(src+2);
    *(dst+3) = *(src+3);
    *(dst+4) = *(src+4);
    *(dst+5) = *(src+5);
    *(dst+6) = *(src+6);
    *(dst+7) = *(src+7);
#else
QWORD * pqwDst;

    pqwDst  = (QWORD *) pAddr_p;
    *pqwDst = qwQwordVal_p;
#endif

}


//---------------------------------------------------------------------------
//
// Function:    AmiGetQword64FromLe()
//
// Description: reads a 64 bit value from a buffer in little endian
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

QWORD AmiGetQword64FromLe (void * pAddr_p)
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
// Function:    AmiGetQword64FromBe()
//
// Description: reads a 64 bit value from a buffer in big endian
//
// Parameters:  pAddr_p         = pointer to source buffer
//
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

QWORD AmiGetQword64FromBe (void * pAddr_p)
{
#if defined (__MICROBLAZE__)
tqwStruct      qwStruct;

    ((BYTE *) &qwStruct.m_qwQword)[0] = ((BYTE *) pAddr_p)[0];
    ((BYTE *) &qwStruct.m_qwQword)[1] = ((BYTE *) pAddr_p)[1];
    ((BYTE *) &qwStruct.m_qwQword)[2] = ((BYTE *) pAddr_p)[2];
    ((BYTE *) &qwStruct.m_qwQword)[3] = ((BYTE *) pAddr_p)[3];
    ((BYTE *) &qwStruct.m_qwQword)[4] = ((BYTE *) pAddr_p)[4];
    ((BYTE *) &qwStruct.m_qwQword)[5] = ((BYTE *) pAddr_p)[5];
    ((BYTE *) &qwStruct.m_qwQword)[6] = ((BYTE *) pAddr_p)[6];
    ((BYTE *) &qwStruct.m_qwQword)[7] = ((BYTE *) pAddr_p)[7];

    return ( qwStruct.m_qwQword );
#else
tqwStruct * pqwStruct;
tqwStruct      qwStruct;

    pqwStruct = (tqwStruct *) pAddr_p;
    qwStruct.m_qwQword = pqwStruct->m_qwQword;

    return ( qwStruct.m_qwQword );
#endif
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
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void AmiSetQword40ToLe (void * pAddr_p, QWORD qwQwordVal_p)
{
    ((BYTE *) pAddr_p)[0] = ((BYTE *) &qwQwordVal_p)[7];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &qwQwordVal_p)[6];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &qwQwordVal_p)[5];
    ((BYTE *) pAddr_p)[3] = ((BYTE *) &qwQwordVal_p)[4];
    ((BYTE *) pAddr_p)[4] = ((BYTE *) &qwQwordVal_p)[3];
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
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword40ToBe (void * pAddr_p, QWORD qwQwordVal_p)
{
    ((BYTE *) pAddr_p)[0] = ((BYTE *) &qwQwordVal_p)[3];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &qwQwordVal_p)[4];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &qwQwordVal_p)[5];
    ((BYTE *) pAddr_p)[3] = ((BYTE *) &qwQwordVal_p)[6];
    ((BYTE *) pAddr_p)[4] = ((BYTE *) &qwQwordVal_p)[7];
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
tqwStruct      qwStruct;

    qwStruct.m_qwQword  = AmiGetQword64FromLe (pAddr_p);
    qwStruct.m_qwQword &= 0x000000FFFFFFFFFFLL;

    return ( qwStruct.m_qwQword );
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
#if defined (__MICROBLAZE__)
    qwStruct.m_qwQword &= 0x000000FFFFFFFFFFLL;
#endif
    return ( qwStruct.m_qwQword );
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
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword48ToLe (void * pAddr_p, QWORD qwQwordVal_p)
{
    ((BYTE *) pAddr_p)[0] = ((BYTE *) &qwQwordVal_p)[7];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &qwQwordVal_p)[6];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &qwQwordVal_p)[5];
    ((BYTE *) pAddr_p)[3] = ((BYTE *) &qwQwordVal_p)[4];
    ((BYTE *) pAddr_p)[4] = ((BYTE *) &qwQwordVal_p)[3];
    ((BYTE *) pAddr_p)[5] = ((BYTE *) &qwQwordVal_p)[2];
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
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword48ToBe (void * pAddr_p, QWORD qwQwordVal_p)
{
    ((BYTE *) pAddr_p)[0] = ((BYTE *) &qwQwordVal_p)[2];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &qwQwordVal_p)[3];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &qwQwordVal_p)[4];
    ((BYTE *) pAddr_p)[3] = ((BYTE *) &qwQwordVal_p)[5];
    ((BYTE *) pAddr_p)[4] = ((BYTE *) &qwQwordVal_p)[6];
    ((BYTE *) pAddr_p)[5] = ((BYTE *) &qwQwordVal_p)[7];
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
tqwStruct      qwStruct;

    qwStruct.m_qwQword  = AmiGetQword64FromLe (pAddr_p);
    qwStruct.m_qwQword &= 0x0000FFFFFFFFFFFFLL;

    return ( qwStruct.m_qwQword );
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
#if defined (__MICROBLAZE__)
    qwStruct.m_qwQword &= 0x0000FFFFFFFFFFFFLL;
#endif
    return ( qwStruct.m_qwQword );
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
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword56ToLe (void * pAddr_p, QWORD qwQwordVal_p)
{
    ((BYTE *) pAddr_p)[0] = ((BYTE *) &qwQwordVal_p)[7];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &qwQwordVal_p)[6];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &qwQwordVal_p)[5];
    ((BYTE *) pAddr_p)[3] = ((BYTE *) &qwQwordVal_p)[4];
    ((BYTE *) pAddr_p)[4] = ((BYTE *) &qwQwordVal_p)[3];
    ((BYTE *) pAddr_p)[5] = ((BYTE *) &qwQwordVal_p)[2];
    ((BYTE *) pAddr_p)[6] = ((BYTE *) &qwQwordVal_p)[1];
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
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void  AmiSetQword56ToBe (void * pAddr_p, QWORD qwQwordVal_p)
{
    ((BYTE *) pAddr_p)[0] = ((BYTE *) &qwQwordVal_p)[1];
    ((BYTE *) pAddr_p)[1] = ((BYTE *) &qwQwordVal_p)[2];
    ((BYTE *) pAddr_p)[2] = ((BYTE *) &qwQwordVal_p)[3];
    ((BYTE *) pAddr_p)[3] = ((BYTE *) &qwQwordVal_p)[4];
    ((BYTE *) pAddr_p)[4] = ((BYTE *) &qwQwordVal_p)[5];
    ((BYTE *) pAddr_p)[5] = ((BYTE *) &qwQwordVal_p)[6];
    ((BYTE *) pAddr_p)[6] = ((BYTE *) &qwQwordVal_p)[7];
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

QWORD  AmiGetQword56FromLe(void * pAddr_p)
{
tqwStruct      qwStruct;

    qwStruct.m_qwQword  = AmiGetQword64FromLe (pAddr_p);
    qwStruct.m_qwQword &= 0x00FFFFFFFFFFFFFFLL;

    return ( qwStruct.m_qwQword );
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

QWORD AmiGetQword56FromBe(void * pAddr_p)
{
tqwStruct      qwStruct;

    qwStruct.m_qwQword  = AmiGetQword64FromBe (pAddr_p);
    qwStruct.m_qwQword >>= 8;
#if defined (__MICROBLAZE__)
    qwStruct.m_qwQword &= 0x00FFFFFFFFFFFFFFLL;
#endif

    return ( qwStruct.m_qwQword );
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
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void AmiSetTimeOfDay(void * pAddr_p, tTimeOfDay * pTimeOfDay_p)
{
    AmiSetDwordToLe(((BYTE *) pAddr_p),     pTimeOfDay_p->m_dwMs & 0x0FFFFFFF);
    AmiSetWordToLe(((BYTE *) pAddr_p) + 4, pTimeOfDay_p->m_wDays);
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
// Return:      void
//
// State:       not tested
//
//---------------------------------------------------------------------------

void AmiGetTimeOfDay (void * pAddr_p, tTimeOfDay * pTimeOfDay_p)
{
    pTimeOfDay_p->m_dwMs  = AmiGetDwordFromLe (((BYTE *) pAddr_p)) & 0x0FFFFFFF;
    pTimeOfDay_p->m_wDays = AmiGetWordFromLe  (((BYTE *) pAddr_p) + 4);
}


// EOF

