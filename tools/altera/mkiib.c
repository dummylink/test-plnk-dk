/**
********************************************************************************
\file        mkiib.c

\brief       Image Information Block creation tool

\author      Josef Baumgartner

\date        22.08.2011

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This file contains the sources for the Image Information Block (IIB) creation tool.
The tool generates a binary file containing the IIB.
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

#include "cnApiGlobal.h"
#include "firmware.h"
#include "mkiib.h"

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
    printf("\nopenPOWERLINK Slave Development Toolkit: mkiib Version %s\n\n", VERSION);
    printf("mkiib creates a binary file containing an Image Information Block (IIB).");
    printf("Usage:\n");
    printf("mkiib     [-o|--output <iib>\n"
           "           -f|--fpgacfg <fpgaconfig> --fpgavers <fpga_verssion>\n"
           "           -p|--pcpsw <pcpsw> --pcpvers <pcpsw_version>\n"
           "           -a|--apsw <apsw> --apvers <apsw_version>\n"
           "           [--appswdate <appsw_date>] [--appswtime <appsw_time>]\n");
    printf("mkiib      -i|--info <iib>\n");
    printf("mkiib      -h|--help\n\n");
    printf("Available options:\n");
    printf(" -h                         Print this help\n");
    printf(" -i|--info <iib>            Print information on this IIB file\n");
    printf(" -f|--fpgacfg <fpgaconfig>  FPGA configuration file to insert in firmware\n"
           " --fpgavers <fpga_version>  Version number of FPGA configuration\n"
           " -p|--pcpsw <pcpsw>         PCP software to insert in firmware\n"
           " --pcpvers <pcpsw_version>  Version number of PCP software\n"
           " -a|--apsw <apsw>           AP software to insert in firmware\n"
           " --apvers <apsw_version>    Version number of AP software\n"
           " -o|--output <iib>          IIB file to create\n"
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
                {"info",      required_argument, 0,  'i' },
                {"appswdate", required_argument, 0,   0  },
                {"appswtime", required_argument, 0,   1  },
                {0,           0,                 0,   0  }
            };

    /* check if command line options are specified */
    if (iArgc_p <= 1)
        return ERROR;

    while ((opt = getopt_long(iArgc_p, caArgv_p, "hf:p:a:o:i:",
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
        (optcheck != (OPTION_OUTPUT | OPTION_FPGA | OPTION_PCPSW |
                      OPTION_FPGAVERS | OPTION_PCPVERS)) &&
        (optcheck != (OPTION_OUTPUT | OPTION_FPGA | OPTION_PCPSW | OPTION_APSW |
                      OPTION_FPGAVERS | OPTION_PCPVERS | OPTION_APVERS))
       )
    {
        printf ("--- Wrong options! %08x ---\n", optcheck);
        return ERROR;
    }

    return OK;
}

/**
********************************************************************************
\brief    print IIB info

printIibInfo() analyzes the IIB file and prints out the contained
information.

\param        pHeader_p       pointer to firmware header
*******************************************************************************/
void printIibInfo(tIib *pHeader_p)
{
    int         version = ntohl(pHeader_p->m_magic) & 0xff;

    if ((version != 1) && (version != 2))
    {
        printf ("Invalid IIB Version %d!\n", version);
        return;
    }

    printf ("Image Information Block Version: %d\n", version);

    printf ("Application SW Date:     %d\n", (UINT32)ntohl(pHeader_p->m_applicationSwDate));
    printf ("Application SW Time:     %d\n", (UINT32)ntohl(pHeader_p->m_applicationSwTime));
    printf ("IIB CRC:                 0x%08x\n", (UINT32)ntohl(pHeader_p->m_iibCrc));

    printf ("-------------------------------------------------\n");
    printf ("FPGA configuration:\n");
    printf ("Adrs/Offset:             %d\n", (UINT32)ntohl(pHeader_p->m_fpgaConfigAdrs));
    printf ("Version:                 %d\n", (UINT32)ntohl(pHeader_p->m_fpgaConfigVersion));
    printf ("Size:                    %d\n", (UINT32)ntohl(pHeader_p->m_fpgaConfigSize));
    printf ("CRC:                     0x%08x\n", (UINT32)ntohl(pHeader_p->m_fpgaConfigCrc));
    printf ("-------------------------------------------------\n");
    printf ("PCP software:\n");
    printf ("Adrs/Offset:             %d\n", (UINT32)ntohl(pHeader_p->m_pcpSwAdrs));
    printf ("Version:                 %d\n", (UINT32)ntohl(pHeader_p->m_pcpSwVersion));
    printf ("Size:                    %d\n", (UINT32)ntohl(pHeader_p->m_pcpSwSize));
    printf ("CRC:                     0x%08x\n", (UINT32)ntohl(pHeader_p->m_pcpSwCrc));

    /* IIB version 2 contains AP information */
    if (version == 2)
    {
        printf ("-------------------------------------------------\n");
        printf ("AP software:\n");
        printf ("Adrs/Offset:             %d\n", (UINT32)ntohl(pHeader_p->m_apSwAdrs));
        printf ("Version:                 %d\n", (UINT32)ntohl(pHeader_p->m_apSwVersion));
        printf ("Size:                    %d\n", (UINT32)ntohl(pHeader_p->m_apSwSize));
        printf ("CRC:                     0x%08x\n", (UINT32)ntohl(pHeader_p->m_apSwCrc));
    }
    printf ("\n");
}

/**
********************************************************************************
\brief  calculate checksum of firmware file part

calcImageCrc() calculates the CRC32 checksum of a firmware file part.

\param inputFd_p    file descriptor of binary file which is copied into the
                    firmware file
\param uiCrc_p      pointer to store the calculated CRC32 checksum
\param size_p       pointer to store the size of the binary file

\retval OK          if file was successfully copied
\retval ERROR       if an error occured while copying
*******************************************************************************/
int calcImageCrc (int inputFd_p, UINT32 *uiCrc_p, UINT32 *size_p)
{
#define BUF_SIZE        512

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
         }
         size += len;
     } while (len > 0);

     *uiCrc_p = crc;
     *size_p = size;

    return OK;
}

/**
*******************************************************************************
\brief       check Image Information Block

checkIib() checks a Iib for validity and prints out the contained information.

\return        OK if successfull, ERROR otherwise
******************************************************************************/
int checkIib(void)
{
    tIib                iib;
    int                 fd;
    UINT32              crc;

    printf ("Checking IIB file: %s ...\n\n", options_g.m_outFileName);

    /* open IIB file */
    if ((fd = open(options_g.m_outFileName, O_RDONLY)) == -1)
    {
        printf ("Couldn't open IIB file (%s)\n", strerror(errno));
        return ERROR;
    }

    /* read IIB */
    if (read (fd, &iib, sizeof(tIib)) != sizeof(tIib))
    {
        printf ("Couldn't read IIB!\n");
        close(fd);
        return ERROR;
    }

    /* check IIB CRC */
    if ((crc = crc32(0, &iib, sizeof(tIib) - sizeof(DWORD))) != ntohl(iib.m_iibCrc))
    {
        printf ("Invalid IIB checksum! (%08x : %08x)\n", crc, (UINT32)ntohl(iib.m_iibCrc));
        close (fd);
        return ERROR;
    }

    printIibInfo(&iib);

    close (fd);
    return OK;
}

/**
*******************************************************************************
\brief       create Image Information Block

createIib() creates a binary file containing an image information block.

\return        OK if successfull created, ERROR otherwise
******************************************************************************/
int createIib(void)
{
    tIib                iib;
    int                 iibFd;
    int                 inputFd;
    UINT32              crc;
    UINT32              size;
    struct tm           tmTime;
    time_t              tim;
    struct timeval      now;
    UINT32              adrs;

    printf ("Creating IIB file: %s ...\n\n", options_g.m_outFileName);

    /* initialize header */
    memset (&iib, 0x00, sizeof(tIib));
    if (options_g.m_apSwName[0] == '\0')
    {
        iib.m_magic = htonl(IIB_MAGIC | 1);
    }
    else
    {
        iib.m_magic = htonl(IIB_MAGIC | 2);
    }

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

        iib.m_applicationSwDate = htonl((now.tv_sec - tim) / (60 * 60 * 24));

        /* calculate milliseconds since midnight */
        localtime_r(&now.tv_sec, &tmTime);
        tmTime.tm_hour = 0;
        tmTime.tm_min = 0;
        tmTime.tm_sec = 0;
        tim = mktime (&tmTime);

        iib.m_applicationSwTime = htonl(((now.tv_sec - tim) * 1000) + (now.tv_usec / 1000));
    }
    else
    {
        iib.m_applicationSwDate = htonl(options_g.m_applicationSwDate);
        iib.m_applicationSwTime = htonl(options_g.m_applicationSwTime);
    }

    /*------------------------------------------------------------------------*/
    /* create IIB file */
    if ((iibFd = open(options_g.m_outFileName, O_RDWR | O_CREAT,
                     S_IRWXU | S_IRGRP | S_IROTH)) == -1)
    {
        printf ("Couldn't create IIB file (%s)\n", strerror(errno));
        return ERROR;
    }

    /*------------------------------------------------------------------------*/
    /* calculate CRC of fpga configuration */
    if ((inputFd = open(options_g.m_fpgaCfgName, O_RDONLY)) == -1)
    {
        printf ("Couldn't open fpga configuration (%s)\n", strerror(errno));
        close (iibFd);
        return ERROR;
    }

    if (calcImageCrc (inputFd, &crc, &size) < 0)
    {
        printf ("Error calculating CRC of FPGA configuration file!\n");
        close (iibFd);
        close (inputFd);
        return ERROR;
    }

    iib.m_fpgaConfigAdrs = htonl(0);
    iib.m_fpgaConfigCrc = htonl(crc);
    iib.m_fpgaConfigSize = htonl(size);
    iib.m_fpgaConfigVersion = htonl(options_g.m_fpgaConfigVersion);
    adrs = size;
    close (inputFd);

    /*------------------------------------------------------------------------*/
    /* copy PCP software */
    if ((inputFd = open(options_g.m_pcpSwName, O_RDONLY)) == -1)
    {
        printf ("Couldn't open PCP software (%s)\n", strerror(errno));
        close (iibFd);
        return ERROR;
    }

    if (calcImageCrc (inputFd, &crc, &size) < 0)
    {
        printf ("Error calculating CRC of PCP software file!\n");
        close (iibFd);
        close (inputFd);
        return ERROR;
    }
    iib.m_pcpSwAdrs = htonl(adrs);
    iib.m_pcpSwCrc = htonl(crc);
    iib.m_pcpSwSize = htonl(size);
    iib.m_pcpSwVersion = htonl(options_g.m_pcpSwVersion);
    adrs += size;
    close (inputFd);

    /*------------------------------------------------------------------------*/
    /* copy AP software */
    if (options_g.m_apSwName[0] != '\0')
    {
        if ((inputFd = open(options_g.m_apSwName, O_RDONLY)) == -1)
        {
            printf ("Couldn't open AP software (%s)\n", strerror(errno));
            close (iibFd);
            return ERROR;
        }

        if (calcImageCrc (inputFd, &crc, &size) < 0)
        {
            printf ("Error calculating CRC of AP software file!\n");
            close (iibFd);
            close (inputFd);
            return ERROR;
        }
        iib.m_apSwAdrs = htonl(adrs);
        iib.m_apSwCrc = htonl(crc);
        iib.m_apSwSize = htonl(size);
        iib.m_apSwVersion = htonl(options_g.m_apSwVersion);
        close (inputFd);
    }

    /* calculate checksum of IIB */
    iib.m_iibCrc = htonl(crc32(0, &iib, sizeof(tIib) -  sizeof(DWORD)));

    if (write (iibFd, &iib, sizeof(tIib)) != sizeof(tIib))
    {
        printf ("Error writing IIB file!\n");
        close (iibFd);
        return ERROR;
    }

    close (iibFd);

    printIibInfo(&iib);

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
      iResult = checkIib();
    }
    else
    {
      iResult = createIib();
    }

    return iResult;
}
