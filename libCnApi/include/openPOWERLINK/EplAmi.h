#ifndef _AMIBE_H_
#define _AMIBE_H_

#include "cnApiGlobal.h"
#define INLINE_FUNCTION
#define PUBLIC extern
#define FAR

INLINE_FUNCTION void  PUBLIC  AmiSetWordToLe  (void FAR* pAddr_p, WORD wWordVal_p);
INLINE_FUNCTION void  PUBLIC  AmiSetDwordToLe (void FAR* pAddr_p, DWORD dwDwordVal_p);
INLINE_FUNCTION void  PUBLIC  AmiSetWordToBe  (void FAR* pAddr_p, WORD wWordVal_p);
INLINE_FUNCTION void  PUBLIC  AmiSetDwordToBe (void FAR* pAddr_p, DWORD dwDwordVal_p);

INLINE_FUNCTION WORD  PUBLIC  AmiGetWordFromLe  (void FAR* pAddr_p);
INLINE_FUNCTION DWORD PUBLIC  AmiGetDwordFromLe (void FAR* pAddr_p);
INLINE_FUNCTION WORD  PUBLIC  AmiGetWordFromBe  (void FAR* pAddr_p);
INLINE_FUNCTION DWORD PUBLIC  AmiGetDwordFromBe (void FAR* pAddr_p);

#ifdef _TIME_OF_DAY_DEFINED_
INLINE_FUNCTION void PUBLIC AmiSetTimeOfDay (void FAR* pAddr_p, tTimeOfDay FAR* pTimeOfDay_p);
INLINE_FUNCTION void PUBLIC AmiGetTimeOfDay (void FAR* pAddr_p, tTimeOfDay FAR* pTimeOfDay_p)
#endif // _TIME_OF_DAY_DEFINED_

#define AmiGetWordToLe  AmiGetWordFromLe
#define AmiGetDwordToLe AmiGetDwordFromLe
#define AmiGetWordToBe  AmiGetWordFromBe
#define AmiGetDwordToBe AmiGetDwordFromBe

#endif //_AMIBE_H_



