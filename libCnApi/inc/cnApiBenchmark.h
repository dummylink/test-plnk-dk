/**
********************************************************************************
\file       cnApiBenchmark.h

\brief      Header file for debugging. Enables setting benchmark pins

This header is used to set benchmark pins in order to enable timint
measurements on the ap processor.

Copyright � 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved. All use of this software and documentation is
subject to the License Agreement located at the end of this file below.

*******************************************************************************/

#ifndef CNAPIBENCHMARK_H_
#define CNAPIBENCHMARK_H_

/******************************************************************************/
/* includes */
#include <cnApiGlobal.h>

/******************************************************************************/
/* defines */

// set the benchmark level as needed
#define BENCHMARK_MODULES       0x00000003L


#ifdef __NIOS2__

    #include "system.h"

    #ifdef AP_BENCHMARK_PIO_BASE
        #include "altera_avalon_pio_regs.h"       // PIO access

        #if AP_BENCHMARK_PIO_BIT_MODIFYING_OUTPUT_REGISTER == 0
            #error Please enable individual bit setting/clearing of output register for benchmark_pio module in SOPC Builder
        #endif
        #define BENCHMARK_SET(x)    IOWR_ALTERA_AVALON_PIO_SET_BITS(AP_BENCHMARK_PIO_BASE, \
                                    (1 << (x)))
        #define BENCHMARK_RESET(x)  IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(AP_BENCHMARK_PIO_BASE, \
                                    (1 << (x)))
        #define BENCHMARK_TOGGLE(x) IOWR_ALTERA_AVALON_PIO_DATA(AP_BENCHMARK_PIO_BASE, \
                                    ((IORD_ALTERA_AVALON_PIO_DATA(AP_BENCHMARK_PIO_BASE)) \
                                    ^ (1 << (x))))
    #else
        #undef BENCHMARK_MODULES
        #define BENCHMARK_MODULES           0x00000000
    #endif

#elif defined(__MICROBLAZE__)

    #include "xparameters.h"

    #ifdef XPAR_AP_BENCHMARK_PIO_BASEADDR
        #include "xgpio_l.h"

        #define BENCHMARK_SET(x)    XGpio_WriteReg(XPAR_AP_BENCHMARK_PIO_BASEADDR, 0, \
                                    XGpio_ReadReg(XPAR_AP_BENCHMARK_PIO_BASEADDR, 0) | (1<<x))
        #define BENCHMARK_RESET(x)  XGpio_WriteReg(XPAR_AP_BENCHMARK_PIO_BASEADDR, 0, \
                                    XGpio_ReadReg(XPAR_AP_BENCHMARK_PIO_BASEADDR, 0) & ~(1<<x))
        #define BENCHMARK_TOGGLE(x) XGpio_WriteReg(XPAR_AP_BENCHMARK_PIO_BASEADDR, 0, \
                                    XGpio_ReadReg(XPAR_AP_BENCHMARK_PIO_BASEADDR, 0) ^ (1<<x))
    #else
        #undef BENCHMARK_MODULES
        #define BENCHMARK_MODULES           0x00000000
    #endif
#else
    // disable Benchmarking
    #undef BENCHMARK_MODULES
    #define BENCHMARK_MODULES               0x00000000
#endif

/******************************************************************************/
/* const defines */

#ifndef BENCHMARK_MODULES
#define BENCHMARK_MODULES                   0x00000000
#endif

#define BENCHMARK_MOD_01                    0x00000001
#define BENCHMARK_MOD_02                    0x00000002
#define BENCHMARK_MOD_03                    0x00000004
#define BENCHMARK_MOD_04                    0x00000008
#define BENCHMARK_MOD_05                    0x00000010
#define BENCHMARK_MOD_06                    0x00000020
#define BENCHMARK_MOD_07                    0x00000040
#define BENCHMARK_MOD_08                    0x00000080
#define BENCHMARK_MOD_09                    0x00000100
#define BENCHMARK_MOD_10                    0x00000200
#define BENCHMARK_MOD_11                    0x00000400
#define BENCHMARK_MOD_12                    0x00000800
#define BENCHMARK_MOD_13                    0x00001000
#define BENCHMARK_MOD_14                    0x00002000
#define BENCHMARK_MOD_15                    0x00004000
#define BENCHMARK_MOD_16                    0x00008000
#define BENCHMARK_MOD_17                    0x00010000
#define BENCHMARK_MOD_18                    0x00020000
#define BENCHMARK_MOD_19                    0x00040000
#define BENCHMARK_MOD_20                    0x00080000
#define BENCHMARK_MOD_21                    0x00100000
#define BENCHMARK_MOD_22                    0x00200000
#define BENCHMARK_MOD_23                    0x00400000
#define BENCHMARK_MOD_24                    0x00800000
#define BENCHMARK_MOD_25                    0x01000000
#define BENCHMARK_MOD_26                    0x02000000
#define BENCHMARK_MOD_27                    0x04000000
#define BENCHMARK_MOD_28                    0x08000000
#define BENCHMARK_MOD_29                    0x10000000
#define BENCHMARK_MOD_30                    0x20000000
#define BENCHMARK_MOD_31                    0x40000000
#define BENCHMARK_MOD_32                    0x80000000


#if (BENCHMARK_MODULES & BENCHMARK_MOD_01)
    #define BENCHMARK_MOD_01_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_01_RESET(x)       BENCHMARK_RESET(x)
    #define BENCHMARK_MOD_01_TOGGLE(x)      BENCHMARK_TOGGLE(x)
#else
    #define BENCHMARK_MOD_01_SET(x)
    #define BENCHMARK_MOD_01_RESET(x)
    #define BENCHMARK_MOD_01_TOGGLE(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_02)
    #define BENCHMARK_MOD_02_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_02_RESET(x)       BENCHMARK_RESET(x)
    #define BENCHMARK_MOD_02_TOGGLE(x)      BENCHMARK_TOGGLE(x)
#else
    #define BENCHMARK_MOD_02_SET(x)
    #define BENCHMARK_MOD_02_RESET(x)
    #define BENCHMARK_MOD_02_TOGGLE(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_03)
    #define BENCHMARK_MOD_03_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_03_RESET(x)       BENCHMARK_RESET(x)
    #define BENCHMARK_MOD_03_TOGGLE(x)      BENCHMARK_TOGGLE(x)
#else
    #define BENCHMARK_MOD_03_SET(x)
    #define BENCHMARK_MOD_03_RESET(x)
    #define BENCHMARK_MOD_03_TOGGLE(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_04)
    #define BENCHMARK_MOD_04_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_04_RESET(x)       BENCHMARK_RESET(x)
    #define BENCHMARK_MOD_04_TOGGLE(x)      BENCHMARK_TOGGLE(x)
#else
    #define BENCHMARK_MOD_04_SET(x)
    #define BENCHMARK_MOD_04_RESET(x)
    #define BENCHMARK_MOD_04_TOGGLE(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_05)
    #define BENCHMARK_MOD_05_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_05_RESET(x)       BENCHMARK_RESET(x)
    #define BENCHMARK_MOD_05_TOGGLE(x)      BENCHMARK_TOGGLE(x)
#else
    #define BENCHMARK_MOD_05_SET(x)
    #define BENCHMARK_MOD_05_RESET(x)
    #define BENCHMARK_MOD_05_TOGGLE(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_06)
    #define BENCHMARK_MOD_06_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_06_RESET(x)       BENCHMARK_RESET(x)
    #define BENCHMARK_MOD_06_TOGGLE(x)      BENCHMARK_TOGGLE(x)
#else
    #define BENCHMARK_MOD_06_SET(x)
    #define BENCHMARK_MOD_06_RESET(x)
    #define BENCHMARK_MOD_06_TOGGLE(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_07)
    #define BENCHMARK_MOD_07_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_07_RESET(x)       BENCHMARK_RESET(x)
    #define BENCHMARK_MOD_07_TOGGLE(x)      BENCHMARK_TOGGLE(x)
#else
    #define BENCHMARK_MOD_07_SET(x)
    #define BENCHMARK_MOD_07_RESET(x)
    #define BENCHMARK_MOD_07_TOGGLE(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_08)
    #define BENCHMARK_MOD_08_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_08_RESET(x)       BENCHMARK_RESET(x)
    #define BENCHMARK_MOD_08_TOGGLE(x)      BENCHMARK_TOGGLE(x)
#else
    #define BENCHMARK_MOD_08_SET(x)
    #define BENCHMARK_MOD_08_RESET(x)
    #define BENCHMARK_MOD_08_TOGGLE(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_09)
    #define BENCHMARK_MOD_09_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_09_RESET(x)       BENCHMARK_RESET(x)
    #define BENCHMARK_MOD_09_TOGGLE(x)      BENCHMARK_TOGGLE(x)
#else
    #define BENCHMARK_MOD_09_SET(x)
    #define BENCHMARK_MOD_09_RESET(x)
    #define BENCHMARK_MOD_09_TOGGLE(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_10)
    #define BENCHMARK_MOD_10_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_10_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_10_SET(x)
    #define BENCHMARK_MOD_10_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_11)
    #define BENCHMARK_MOD_11_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_11_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_11_SET(x)
    #define BENCHMARK_MOD_11_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_12)
    #define BENCHMARK_MOD_12_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_12_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_12_SET(x)
    #define BENCHMARK_MOD_12_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_13)
    #define BENCHMARK_MOD_13_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_13_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_13_SET(x)
    #define BENCHMARK_MOD_13_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_14)
    #define BENCHMARK_MOD_14_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_14_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_14_SET(x)
    #define BENCHMARK_MOD_14_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_15)
    #define BENCHMARK_MOD_15_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_15_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_15_SET(x)
    #define BENCHMARK_MOD_15_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_16)
    #define BENCHMARK_MOD_16_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_16_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_16_SET(x)
    #define BENCHMARK_MOD_16_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_17)
    #define BENCHMARK_MOD_17_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_17_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_17_SET(x)
    #define BENCHMARK_MOD_17_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_18)
    #define BENCHMARK_MOD_18_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_18_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_18_SET(x)
    #define BENCHMARK_MOD_18_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_19)
    #define BENCHMARK_MOD_19_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_19_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_19_SET(x)
    #define BENCHMARK_MOD_19_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_20)
    #define BENCHMARK_MOD_20_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_20_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_20_SET(x)
    #define BENCHMARK_MOD_20_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_21)
    #define BENCHMARK_MOD_21_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_21_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_21_SET(x)
    #define BENCHMARK_MOD_21_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_22)
    #define BENCHMARK_MOD_22_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_22_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_22_SET(x)
    #define BENCHMARK_MOD_22_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_23)
    #define BENCHMARK_MOD_23_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_23_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_23_SET(x)
    #define BENCHMARK_MOD_23_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_24)
    #define BENCHMARK_MOD_24_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_24_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_24_SET(x)
    #define BENCHMARK_MOD_24_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_25)
    #define BENCHMARK_MOD_25_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_25_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_25_SET(x)
    #define BENCHMARK_MOD_25_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_26)
    #define BENCHMARK_MOD_26_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_26_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_26_SET(x)
    #define BENCHMARK_MOD_26_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_27)
    #define BENCHMARK_MOD_27_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_27_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_27_SET(x)
    #define BENCHMARK_MOD_27_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_28)
    #define BENCHMARK_MOD_28_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_28_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_28_SET(x)
    #define BENCHMARK_MOD_28_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_29)
    #define BENCHMARK_MOD_29_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_29_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_29_SET(x)
    #define BENCHMARK_MOD_29_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_30)
    #define BENCHMARK_MOD_30_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_30_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_30_SET(x)
    #define BENCHMARK_MOD_30_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_31)
    #define BENCHMARK_MOD_31_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_31_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_31_SET(x)
    #define BENCHMARK_MOD_31_RESET(x)
#endif

#if (BENCHMARK_MODULES & BENCHMARK_MOD_32)
    #define BENCHMARK_MOD_32_SET(x)         BENCHMARK_SET(x)
    #define BENCHMARK_MOD_32_RESET(x)       BENCHMARK_RESET(x)
#else
    #define BENCHMARK_MOD_32_SET(x)
    #define BENCHMARK_MOD_32_RESET(x)
#endif


/******************************************************************************/
/* type definitions */

/******************************************************************************/
/* global variables */

/******************************************************************************/
/* function declarations */


#endif /* CNAPIBENCHMARK_H_ */

/*******************************************************************************
*
* License Agreement
*
* Copyright � 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
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


