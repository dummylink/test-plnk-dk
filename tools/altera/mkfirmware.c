/**
********************************************************************************
\file        mkfirmware.c

\brief       Firmware file creation tool

This file contains the sources for the firmware creation tool mkfirmware.
The tool concatenates the binary files of the FPGA configuration the PCP
software and the AP software if available. Additionally it creates the firmware
header and stores it at the beginning of the firmware file.

Additionally the tool can analyze an existing firmware file and print
the information.

********************************************************************************

License Agreement

Copyright (C) 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
All rights reserved.

Redistribution and use in source and binary forms,
with or without modification,
are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer
    in the documentation and/or other materials provided with the
    distribution.
  * Neither the name of the B&R nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*******************************************************************************/

/******************************************************************************/
/* includes */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <getopt.h>

#define _XOPEN_SOURCE   // needed for strptime
#include <time.h>
#include <sys/time.h>

#include <arpa/inet.h>  // used for byte ordering conversion functions

#include "global.h"
#include "firmware.h"
#include "mkfirmware.h"

/******************************************************************************/
/* defines */
#define VERSION         "0.1"             ///< program version

/* some defines to check command line options */
#define OPTION_FPGA     0x0001
#define OPTION_PCPSW    0x0002
#define OPTION_APSW     0x0004
#define OPTION_FPGAVERS 0x0008
#define OPTION_PCPVERS  0x0010
#define OPTION_APVERS   0x0020
#define OPTION_OUTPUT   0x0040
#define OPTION_DEVICE   0x0080
#define OPTION_HWREV    0x0100
#define OPTION_INFO     0x0200

/******************************************************************************/
/* global variables */
tOptions        options_g;

/**
********************************************************************************
* \brief       show command usage
*
* usage() prints help about the usage of the trace tool.
*******************************************************************************/
void usage(void)
{
    printf("\nopenPOWERLINK Slave Development Toolkit: mkfirmware Version %s\n\n", VERSION);
    printf("mkfirmware creates a valid firmware file. It concatenates a FPGA\n");
    printf("configuration, a PCP software, an AP software and prepends a\n");
    printf("firmware file header.\n\n");
    printf("Usage:\n");
    printf("mkfirmware [-o|--output <firmware>\n"
           "           -f|--fpgacfg <fpgaconfig> --fpgavers <fpga_verssion>\n"
           "           -p|--pcpsw <pcpsw> --pcpvers <pcpsw_version>\n"
           "           -a|--apsw <apsw> --apvers <apsw_version>\n"
           "           -d|--device <deviceId> -r|--hwrev <hwRevision>\n"
           "           [--appswdate <appsw_date>] [--appswtime <appsw_time>]\n");
    printf("mkfirmware -i|--info <firmware>\n");
    printf("mkfirmware -h|--help\n\n");
    printf("Available options:\n");
    printf(" -h                         Print this help\n");
    printf(" -i|--info <firmware>       Print information on this firmware\n");
    printf(" -f|--fpgacfg <fpgaconfig>  FPGA configuration file to insert in firmware\n"
           " --fpgavers <fpga_version>  Version number of FPGA configuration\n"
           " -p|--pcpsw <pcpsw>         PCP software to insert in firmware\n"
           " --pcpvers <pcpsw_version>  Version number of PCP software\n"
           " -a|--apsw <apsw>           AP software to insert in firmware\n"
           " --apvers <apsw_version>    Version number of AP software\n"
           " -o|--output <firmware>     Firmware file to create\n"
           " -d|--device <deviceId>     Device Id of device this firmware is used for\n"
           "                            Specified as 5-digit decimal value\n"
           " -r|--hwrev <hwReveision>   Hardware revision of device this firmware is used for\n"
           "                            Specified as 2-digit decimal value\n"
           " --appswdate <appswdate>    Application software date (days since 01.01.1984)\n"
           " --appswtime <appswtime>    Application software time (milliseconds since midnight)\n"
           "                            and time fields. If no date is specified\n"
           "                            the current system date is used!\n");
    printf ("\n");
}

/**
********************************************************************************
\brief       parse command line

parseCmdLine() parses the command line for valid options.

\param  iArgc_p         number of arguments
\param  caArgv_p        pointer to argument strings
\param  pOptions_p      pointer to options structure
*******************************************************************************/
int parseCmdLine(int iArgc_p, char* caArgv_p[], tOptions *pOpts_p)
{
    int         opt;
    UINT32      optcheck = 0;
    int         index = 0;

    static struct option long_options[] = {
                {"help",      no_argument,       0,  'h' },
                {"output",    required_argument, 0,  'o' },
                {"pcpsw",     required_argument, 0,  'p' },
                {"pcpvers",   required_argument, 0,   3  },
                {"fpgacfg",   required_argument, 0,  'f' },
                {"fpgavers",  required_argument, 0,   2  },
                {"apsw",      required_argument, 0,  'a' },
                {"apvers",    required_argument, 0,   4  },
                {"device",    required_argument, 0,  'd' },
                {"hwrev",     required_argument, 0,  'r' },
                {"info",      required_argument, 0,  'i' },
                {"appswdate", required_argument, 0,   0  },
                {"appswtime", required_argument, 0,   1  },
                {0,           0,                 0,   0  }
            };

    /* check if command line options are specified */
    if (iArgc_p <= 1)
        return ERROR;

    while ((opt = getopt_long(iArgc_p, caArgv_p, "hf:p:a:o:i:d:r:",
                              long_options, &index)) != -1)
    {
        switch (opt)
        {
        case 0: // application software date
            pOpts_p->m_applicationSwDate = strtoul(optarg, NULL, 10);
            if (strspn(optarg,"0123456789") != strlen(optarg))
            {
                printf ("Invalid application software date (no number)!\n");
                return ERROR;
            }
            break;

        case 1: // application software time
            pOpts_p->m_applicationSwTime = strtoul(optarg, NULL, 10);
            if ((pOpts_p->m_applicationSwTime > (24 * 60 * 60 * 1000)) ||
                (strspn(optarg,"0123456789") != strlen(optarg)))
            {
                printf ("Invalid application software time (no number or too big)!\n");
                return ERROR;
            }
            break;

        case 2: // fpga configuration version number
            pOpts_p->m_fpgaConfigVersion = strtoul(optarg, NULL, 10);
            if ((pOpts_p->m_fpgaConfigVersion> 99999) ||
                (strspn(optarg,"0123456789") != strlen(optarg)))
            {
                printf ("Invalid fpga configuration version (1..99999)!\n");
                return ERROR;
            }
            optcheck |= OPTION_FPGAVERS;
            break;

        case 3: // PCP software version number
            pOpts_p->m_pcpSwVersion = strtoul(optarg, NULL, 10);
            if ((pOpts_p->m_pcpSwVersion > 99999) ||
                (strspn(optarg,"0123456789") != strlen(optarg)))
            {
                printf ("Invalid PCP software version (1..99999)!\n");
                return ERROR;
            }
            optcheck |= OPTION_PCPVERS;
            break;

        case 4: // AP software version number
            pOpts_p->m_apSwVersion = strtoul(optarg, NULL, 10);
            if ((pOpts_p->m_apSwVersion > 99999) ||
                (strspn(optarg,"0123456789") != strlen(optarg)))
            {
                printf ("Invalid AP software version (1..99999)!\n");
                return ERROR;
            }
            optcheck |= OPTION_APVERS;
            break;

        case 'h':
            return ERROR;
            break;
        case 'f':
            strncpy(pOpts_p->m_fpgaCfgName, optarg, MAX_NAME_LEN);
            optcheck |= OPTION_FPGA;
            break;

        case 'p':
            strncpy(pOpts_p->m_pcpSwName, optarg, MAX_NAME_LEN);
            optcheck |= OPTION_PCPSW;
            break;

        case 'a':
            strncpy(pOpts_p->m_apSwName, optarg, MAX_NAME_LEN);
            optcheck |= OPTION_APSW;
            break;

        case 'o':
            strncpy(pOpts_p->m_outFileName, optarg, MAX_NAME_LEN);
            optcheck |= OPTION_OUTPUT;
            break;

        case 'd':
            pOpts_p->m_deviceId = strtoul(optarg, NULL, 10);
            if ((pOpts_p->m_deviceId > 99999) ||
                (strspn(optarg,"0123456789") != strlen(optarg)))
            {
                printf ("Invalid device ID (0..99999)!\n");
                return ERROR;
            }
            optcheck |= OPTION_DEVICE;
            break;

        case 'r':
            pOpts_p->m_hwRevision = strtoul(optarg, NULL, 10);
            if ((pOpts_p->m_hwRevision > 99) ||
                (strspn(optarg,"0123456789") != strlen(optarg)))
            {
                printf ("Invalid hardware revision (0..99)!\n");
                return ERROR;
            }
            optcheck |= OPTION_HWREV;
            break;

        case 'i':
            strncpy(pOpts_p->m_outFileName, optarg, MAX_NAME_LEN);
            pOpts_p->m_fPrintInfo = TRUE;
            optcheck |= OPTION_INFO;
            break;

        default: /* '?' */
            return ERROR;
        }
    }

    /* check for valid option combinations */
    if (
        (optcheck != OPTION_INFO) &&
        (optcheck != (OPTION_OUTPUT | OPTION_FPGA | OPTION_PCPSW | OPTION_DEVICE |
                      OPTION_HWREV | OPTION_FPGAVERS | OPTION_PCPVERS)) &&
        (optcheck != (OPTION_OUTPUT | OPTION_FPGA | OPTION_PCPSW | OPTION_APSW | OPTION_DEVICE |
                      OPTION_HWREV | OPTION_FPGAVERS | OPTION_PCPVERS | OPTION_APVERS))
       )
    {
        printf ("--- Wrong options! ---\n");
        return ERROR;
    }

    return OK;
}

/**
********************************************************************************
\brief    print firmware header info

printFwInfo() analyzes the firmware header and prints out the contained
information.

\param        pHeader_p       pointer to firmware header
*******************************************************************************/
void printFwInfo(tFwHeader *pHeader_p)
{
    printf ("Firmware Header Version: %d.%d\n",
            ((ntohs(pHeader_p->m_version) >> 8) & 0xff),
            (ntohs(pHeader_p->m_version) & 0xff));
    printf ("Device ID:               %d\n", (UINT32)ntohl(pHeader_p->m_deviceId));
    printf ("Hardware Revision:       %d\n", (UINT32)ntohl(pHeader_p->m_hwRevision));
    printf ("Application SW Date:     %d\n", (UINT32)ntohl(pHeader_p->m_applicationSwDate));
    printf ("Application SW Time:     %d\n", (UINT32)ntohl(pHeader_p->m_applicationSwTime));
    printf ("Header CRC:              0x%08x\n", (UINT32)ntohl(pHeader_p->m_headerCrc));

    printf ("-------------------------------------------------\n");
    printf ("FPGA configuration:\n");
    printf ("Version:                 %d\n", (UINT32)ntohl(pHeader_p->m_fpgaConfigVersion));
    printf ("Size:                    %d\n", (UINT32)ntohl(pHeader_p->m_fpgaConfigSize));
    printf ("CRC:                     0x%08x\n", (UINT32)ntohl(pHeader_p->m_fpgaConfigCrc));
    printf ("-------------------------------------------------\n");
    printf ("PCP software:\n");
    printf ("Version:                 %d\n", (UINT32)ntohl(pHeader_p->m_pcpSwVersion));
    printf ("Size:                    %d\n", (UINT32)ntohl(pHeader_p->m_pcpSwSize));
    printf ("CRC:                     0x%08x\n", (UINT32)ntohl(pHeader_p->m_pcpSwCrc));

    if (pHeader_p->m_apSwSize > 0)
    {
        printf ("-------------------------------------------------\n");
        printf ("AP software:\n");
        printf ("Version:                 %d\n", (UINT32)ntohl(pHeader_p->m_apSwVersion));
        printf ("Size:                    %d\n", (UINT32)ntohl(pHeader_p->m_apSwSize));
        printf ("CRC:                     0x%08x\n", (UINT32)ntohl(pHeader_p->m_apSwCrc));
    }
    printf ("\n");
}

/**
********************************************************************************
\brief  calculate checksum of firmware file part

checkFileCrc() reads a part of a firmware file, calculates the CRC32 checksum
and compares it to the expected checksum which was stored in the firmware
header.

\param fd_p             file descriptor of opened firmware file
\param len_p            length of firmware part to check
\param expectedCrc_p    the expected CRC checksum of the firmware part

\retval 0           If CRC comparison was ok
\retval -1          If an error occured while reading the file
\retval -2          If the calculated CRC does not match the expected CRC
*******************************************************************************/
int checkFileCrc(int fd_p, size_t len_p, UINT32 expectedCrc_p)
{
#define BUF_SIZE        512

    UINT8               buf[BUF_SIZE];
    size_t              readLen;
    UINT32              crc;

    crc = 0;
    while (len_p > 0)
    {
        if (len_p > BUF_SIZE)
            readLen = BUF_SIZE;
        else
            readLen = len_p;

        if (read(fd_p, buf, readLen) != readLen)
        {
            return -1;
        }
        crc = crc32(crc, buf, readLen);
        len_p -= readLen;
    }

    if (crc != expectedCrc_p)
    {
        return -2;
    }
    else
    {
        return 0;
    }
}

/**
********************************************************************************
\brief  copy binary and calculate CRC

copyImageCrc() copies a binary file into the firmware file and calculates the
CRC32 checksum.

\param fwFd_p       file descriptor of firmware file
\param inputFd_p    file descriptor of binary file which is copied into the
                    firmware file
\param uiCrc_p      pointer to store the calculated CRC32 checksum
\param size_p       pointer to store the size of the binary file

\retval OK          if file was successfully copied
\retval ERROR       if an error occured while copying
*******************************************************************************/
int copyImageCrc (int fwFd_p, int inputFd_p, UINT32 *uiCrc_p, UINT32 *size_p)
{

    int         len = 0;
    int         size = 0;
    UINT32      crc = 0;
    char        buf[BUF_SIZE];

    crc = 0;
    do {
         if ((len =  read(inputFd_p, buf, BUF_SIZE)) < 0)
         {
             return ERROR;
         }

         if (len > 0)
         {
             crc = crc32(crc, buf, len);

             if (write (fwFd_p, buf, len) != len)
             {
                 return ERROR;
             }
         }
         size += len;
     } while (len > 0);

     *uiCrc_p = crc;
     *size_p = size;

    return OK;
}

/**
*******************************************************************************
\brief       check firmware file

checkFirmware() checks a firmware file for validity and prints out firmware
information.

\return        OK if successfull, ERROR otherwise
******************************************************************************/
int checkFirmware(void)
{
    tFwHeader           fwHeader;
    int                 fd;
    int                 iResult;
    UINT32              crc;

    printf ("Checking firmware file: %s ...\n\n", options_g.m_outFileName);

    /* open firmware file */
    if ((fd = open(options_g.m_outFileName, O_RDONLY)) == -1)
    {
        printf ("Couldn't open firmware file (%s)\n", strerror(errno));
        return ERROR;
    }

    /* read header */
    if (read (fd, &fwHeader, sizeof(fwHeader)) != sizeof(fwHeader))
    {
        printf ("Couldn't read firmware header!\n");
        close(fd);
        return ERROR;
    }

    /* check header CRC */
    if ((crc = crc32(0, &fwHeader, sizeof(fwHeader) - sizeof(DWORD))) != ntohl(fwHeader.m_headerCrc))
    {
        printf ("Invalid firmware header checksum! (%08x : %08x)\n", crc, (UINT32)ntohl(fwHeader.m_headerCrc));
        close (fd);
        return ERROR;
    }

    /* check fpga Configuration CRC */
    iResult = checkFileCrc(fd, ntohl(fwHeader.m_fpgaConfigSize), ntohl(fwHeader.m_fpgaConfigCrc));
    if (iResult == -1)
    {
        printf ("Error reading FPGA configuration in firmware file!\n");
        goto errorExit;
    }

    if (iResult == -2)
    {
        printf ("Invalid checksum of FPGA configuration!\n");
        goto errorExit;
    }

    /* check PCP software CRC */
    iResult = checkFileCrc(fd, ntohl(fwHeader.m_pcpSwSize), ntohl(fwHeader.m_pcpSwCrc));
    if (iResult == -1)
    {
        printf ("Error reading PCP software in firmware file!\n");
        goto errorExit;
    }

    if (iResult == -2)
    {
        printf ("Invalid checksum of PCP software!\n");
        goto errorExit;
    }

    /* check AP software CRC */
    if (fwHeader.m_apSwSize != 0)
    {
        iResult = checkFileCrc(fd, ntohl(fwHeader.m_apSwSize), ntohl(fwHeader.m_apSwCrc));
        if (iResult == -1)
        {
            printf ("Error reading AP software in firmware file!\n");
            goto errorExit;
        }

        if (iResult == -2)
        {
            printf ("Invalid checksum of AP software!\n");
            goto errorExit;
        }
    }

    printFwInfo(&fwHeader);

    close (fd);
    return OK;

errorExit:
    close (fd);
    return ERROR;

}

/**
*******************************************************************************
\brief       create firmware file

createFirmware() creates the firmware file.

\return        OK if successfull created, ERROR otherwise
******************************************************************************/
int createFirmware(void)
{
    tFwHeader           fwHeader;
    int                 fwFd;
    int                 inputFd;
    UINT32              crc;
    UINT32              size;
    struct tm           tmTime;
    time_t              tim;
    struct timeval      now;

    printf ("Creating firmware file: %s ...\n\n", options_g.m_outFileName);

    /* initialize header */
    memset (&fwHeader, 0x00, sizeof(tFwHeader));
    fwHeader.m_magic = htons(FW_HEADER_MAGIC);
    fwHeader.m_version = htons(FW_HEADER_VERSION);
    fwHeader.m_deviceId = htonl(options_g.m_deviceId);
    fwHeader.m_hwRevision = htonl(options_g.m_hwRevision);

    /* check if application software date and time is specified or if current
     * system time should be used.
     */
    if (options_g.m_applicationSwDate == 0)
    {
        /* get current time */
        gettimeofday(&now, NULL);

        /* calculate days from 01.01.1984 */
        memset(&tmTime, 0, sizeof(struct tm));
        tmTime.tm_mday = 1;
        tmTime.tm_mon = 0;
        tmTime.tm_year = 84;
        tim = mktime (&tmTime);

        fwHeader.m_applicationSwDate = htonl((now.tv_sec - tim) / (60 * 60 * 24));

        /* calculate milliseconds since midnight */
        localtime_r(&now.tv_sec, &tmTime);
        tmTime.tm_hour = 0;
        tmTime.tm_min = 0;
        tmTime.tm_sec = 0;
        tim = mktime (&tmTime);

        fwHeader.m_applicationSwTime = htonl(((now.tv_sec - tim) * 1000) + (now.tv_usec / 1000));
    }
    else
    {
        fwHeader.m_applicationSwDate = htonl(options_g.m_applicationSwDate);
        fwHeader.m_applicationSwTime = htonl(options_g.m_applicationSwTime);
    }

    /*------------------------------------------------------------------------*/
    /* create firmware file */
    if ((fwFd = open(options_g.m_outFileName, O_RDWR | O_CREAT | O_TRUNC,
                     S_IRWXU | S_IRGRP | S_IROTH)) == -1)
    {
        printf ("Couldn't create firmware image file (%s)\n", strerror(errno));
        return ERROR;
    }

    /* position to start of fpga configuration */
    lseek(fwFd, sizeof(fwHeader), SEEK_SET);

    /*------------------------------------------------------------------------*/
    /* copy fpga configuration */
    if ((inputFd = open(options_g.m_fpgaCfgName, O_RDONLY)) == -1)
    {
        printf ("Couldn't open fpga configuration (%s)\n", strerror(errno));
        close (fwFd);
        return ERROR;
    }

    if (copyImageCrc (fwFd, inputFd, &crc, &size) < 0)
    {
        printf ("Error copying fpga configuration into firmware file!\n");
        close (fwFd);
        close (inputFd);
        return ERROR;
    }

    fwHeader.m_fpgaConfigCrc = htonl(crc);
    fwHeader.m_fpgaConfigSize = htonl(size);
    fwHeader.m_fpgaConfigVersion = htonl(options_g.m_fpgaConfigVersion);
    close (inputFd);

    /*------------------------------------------------------------------------*/
    /* copy PCP software */
    if ((inputFd = open(options_g.m_pcpSwName, O_RDONLY)) == -1)
    {
        printf ("Couldn't open PCP software (%s)\n", strerror(errno));
        close (fwFd);
        return ERROR;
    }

    if (copyImageCrc (fwFd, inputFd, &crc, &size) < 0)
    {
        printf ("Error copying PCP software into firmware file!\n");
        close (fwFd);
        close (inputFd);
        return ERROR;
    }
    fwHeader.m_pcpSwCrc = htonl(crc);
    fwHeader.m_pcpSwSize = htonl(size);
    fwHeader.m_pcpSwVersion = htonl(options_g.m_pcpSwVersion);
    close (inputFd);

    /*------------------------------------------------------------------------*/
    /* copy AP software */
    if (options_g.m_apSwName[0] != '\0')
    {
        if ((inputFd = open(options_g.m_apSwName, O_RDONLY)) == -1)
        {
            printf ("Couldn't open AP software (%s)\n", strerror(errno));
            close (fwFd);
            return ERROR;
        }

        if (copyImageCrc (fwFd, inputFd, &crc, &size) < 0)
        {
            printf ("Error copying AP software  into firmware file!\n");
            close (fwFd);
            close (inputFd);
            return ERROR;
        }
        fwHeader.m_apSwCrc = htonl(crc);
        fwHeader.m_apSwSize = htonl(size);
        fwHeader.m_apSwVersion = htonl(options_g.m_apSwVersion);
        close (inputFd);
    }
    else
    {
        fwHeader.m_apSwCrc = 0;
        fwHeader.m_apSwSize = 0;
        fwHeader.m_apSwVersion = 0;
    }

    /* calculate checkum of header */
    fwHeader.m_headerCrc = htonl(crc32(0, &fwHeader, sizeof(fwHeader) -  sizeof(DWORD)));
    lseek (fwFd, 0, SEEK_SET);
    if (write (fwFd, &fwHeader, sizeof(fwHeader)) != sizeof(fwHeader))
    {
        printf ("Error writing header of firmware file!\n");
        close (fwFd);
        return ERROR;
    }

    close (fwFd);

    printFwInfo(&fwHeader);

    return OK;
}

/**
 *******************************************************************************
 * \brief       main function
 *
 * main() implements the main function of the mkfirmware tool.
 *
 * \param  argc        number of command line arguments
 * \param  argv        pointer to array with argument strings
 ******************************************************************************/
int main(int argc, char* argv[])
{
  int                    iResult;

    /* parse command line for options */
    memset(&options_g, 0x00, sizeof(tOptions));
    if (parseCmdLine(argc, argv, &options_g) == ERROR)
    {
        usage(); // print command usage
        return -1;
    }

    if (options_g.m_fPrintInfo)
    {
      iResult = checkFirmware();
    }
    else
    {
      iResult = createFirmware();
    }

    return iResult;
}

/* END-OF-FILE */
