/**
********************************************************************************
\file       cnApiGlobal.h

\brief      Global definitions for libCnApi library

This header file contains global definitions used in the POWERLINK CN
Development Framework for the AP library. It defines datatypes and common used
structures.

This file has to be included before other include files.

Copyright © 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef _CNAPI_GLOBAL_H_
#define _CNAPI_GLOBAL_H_


/******************************************************************************/
/* defines */

/******************************************************************************/
/* data types */
#ifndef CHAR
	#define CHAR char
#endif

#ifndef INT8
	#define INT8 char
#endif

#ifndef UCHAR
	#define UCHAR unsigned char
#endif

#ifndef UINT8
	#define UINT8 unsigned char
#endif

#ifndef SHORT
	#define SHORT short int
#endif

#ifndef INT16
	#define INT16 short int
#endif

#ifndef USHORT
	#define USHORT unsigned short int
#endif

#ifndef UINT16
	#define UINT16 unsigned short int
#endif

#ifndef INT
	#define INT int
#endif

#ifndef INT32
	#define INT32 int
#endif

#ifndef UINT
	#define UINT unsigned int
#endif

#ifndef UINT32
	#define UINT32 unsigned int
#endif

#ifndef LONG
	#define LONG long int
#endif

#ifndef ULONG
	#define ULONG unsigned long int
#endif

#ifndef BYTE
	#define BYTE unsigned char
#endif

#ifndef WORD
	#define WORD unsigned short int
#endif

#ifndef DWORD
	#define DWORD unsigned long int
#endif

#ifndef	QWORD
	#define QWORD long long int
#endif

#ifndef BOOL
	#define BOOL unsigned char
#endif

#ifndef NULL
	#define NULL ((void *) 0)
#endif

/******************************************************************************/
/* Boolean values */
#ifndef TRUE
	#define TRUE  0xFF
#endif

#ifndef FALSE
	#define FALSE 0x00
#endif

/******************************************************************************/
/* error values */
#ifndef	ERROR
	#define	ERROR	-1
#endif

#ifndef OK
	#define	OK		0
#endif

/******************************************************************************/
/* byte-align structures */
#ifdef _MSC_VER
#    pragma pack( push, packing )
#    pragma pack( 1 )
#    define PACK_STRUCT
#elif defined( __GNUC__ )
#   define PACK_STRUCT            __attribute__((packed))
#   if defined( __CR16C__ )
#       define CNAPI_USLEEP(x)               GS_DelayTask(x/1000)
#       define CNAPI_MALLOC(siz)             GS_Malloc(siz)
#       define CNAPI_FREE(ptr)               GS_Free(ptr)
#       define CNAPI_MEMSET(ptr, bVal, bCnt) UC_SetMem(ptr, bVal, bCnt)
#       define CNAPI_MEMCPY(ptr, bVal, bSize) GS_Memcpy(ptr, bVal, bSize)
#   else
#       define CNAPI_USLEEP(x)               usleep(x)
#       define CNAPI_MALLOC(siz)             malloc(siz)
#       define CNAPI_FREE(ptr)               free(ptr)
#       define CNAPI_MEMSET(ptr, bVal, bCnt) memset(ptr, bVal, bCnt)
#       define CNAPI_MEMCPY(ptr, bVal, bSize) memcpy(ptr, bVal, bSize)
#   endif
#else
#    error you must 16bit-align these structures with the appropriate compiler directives
#endif

#endif  // _CNAPI_GLOBAL_H_

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


