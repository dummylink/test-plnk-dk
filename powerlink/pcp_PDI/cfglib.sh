#!/bin/bash
# cfglib.sh: Add text at beginning of file.
#
# This script reads the PCP system.h file
# and sets certain defines in CnApi.h according to it.

# User definitions
IN_FILE=./bsp/system.h
OUT_FILE=../../libCnApi/include/cnApiCfg.h

#Error definitions
E_NOSUCHFILE=85

echo -e "\nGenerating cnApiCfg.h..."

if [ ! -f "$IN_FILE" ]
then   # Exit if no such file.
  echo -e "$IN_FILE not found.\n"
  exit $E_NOSUCHFILE
fi

# delete old output-file, if present
if [ -f "$OUT_FILE" ]
then   # Exit if no such file.
  rm $OUT_FILE
  echo -e "Deleted old $OUT_FILE.\n"
fi

# Search pattern in system.h
PATTERN[0]="POWERLINK_0_PDI_PCP_CONFIG"
PATTERN[1]="POWERLINK_0_PDI_PCP_CONFIGAPENDIAN"
PATTERN[2]="POWERLINK_0_PDI_PCP_PDIRPDOS"
PATTERN[3]="POWERLINK_0_PDI_PCP_PDITPDOS"
PATTERN[4]="POWERLINK_0_PDI_PCP_FPGAREV"
PATTERN[5]="SYSID_ID"
PATTERN[6]="POWERLINK_0_MAC_CMP_TIMESYNCHW"
PATTERN[7]="POWERLINK_0_PDI_PCP_ASYNCBUFCOUNT"

###################################################################

echo "/* This file is used for configuration of the Cn API Library.
It is automatically build according to PCP system.h, every time
a rebuild of the PCP software is executed. */

#ifndef _CNAPICFG_H_
#define _CNAPICFG_H_

/* Defines for CN API Library */" > $OUT_FILE

# pattern search - loop
cnt=0
while [ $cnt -lt 8 ] ; do

pattern=${PATTERN[$cnt]}

#check if pattern can be found in the file
match_count=$(grep -w -c "$pattern" ${IN_FILE})

if [ "$match_count" != "1" ]; then
    echo "match_count = ${match_count}"
	echo "File ${IN_FILE} does not or to often contain pattern ${PATTERN[$cnt]}"
    exit 1
fi

# get define value
PCPDefineValue=$(grep -w "$pattern" ${IN_FILE} | grep \#define | grep -v //\# | awk '{split($0,a," "); print a[3]}')
echo "Pattern taken from ${IN_FILE}: $pattern= $PCPDefineValue"

# pattern treatment
case  $cnt  in
    0)
	case $PCPDefineValue in
		0) echo "#define CN_API_NOT_PRESENT" >> $OUT_FILE ;;
		1) echo "#define CN_API_USING_8BIT" >> $OUT_FILE ;;
		2) echo "#define CN_API_USING_16BIT" >> $OUT_FILE ;;
		3) echo "#define CN_API_USING_SPI" >> $OUT_FILE ;;
		4) echo "#define CN_API_INT_AVALON" >> $OUT_FILE ;;
		*) echo "//INVALID_VALUE" >> $OUT_FILE ;;
	esac
	;;
    1)
	case $PCPDefineValue in
		0) echo "#define AP_IS_LITTLE_ENDIAN" >> $OUT_FILE ;;
		1) echo "#define AP_IS_BIG_ENDIAN" >> $OUT_FILE ;;
		*) echo "//INVALID_VALUE" >> $OUT_FILE ;;
	esac
	;;
    2)
	if [ "$PCPDefineValue" -gt "0" ]; then
		echo "#define PCP_PDI_RPDO_CHANNELS $PCPDefineValue" >> $OUT_FILE
	else
		echo "#define PCP_PDI_RPDO_CHANNELS 0" >> $OUT_FILE
	fi
	;;
    3)
	if [ "$PCPDefineValue" -gt "0" ]; then
		echo "#define PCP_PDI_TPDO_CHANNELS $PCPDefineValue" >> $OUT_FILE
	else
		echo "#define PCP_PDI_TPDO_CHANNELS 0" >> $OUT_FILE
	fi
	;;
    4)
	if [ "$PCPDefineValue" -gt "0" ]; then
		echo "#define PCP_PDI_REVISION $PCPDefineValue" >> $OUT_FILE
	else
		echo "#define PCP_PDI_REVISION //INVALID" >> $OUT_FILE
	fi
	;;
	5)
	if [ "$PCPDefineValue" ]; then
		echo "#define PCP_FPGA_SYSID_ID $PCPDefineValue" >> $OUT_FILE
	else
		echo "#define PCP_FPGA_SYSID_ID //INVALID" >> $OUT_FILE
	fi
	;;
	6)
	if [ "$PCPDefineValue" ]; then
		echo "#define PCP_FPGA_TIMESYNCHW $PCPDefineValue" >> $OUT_FILE
	else
		echo "#define PCP_FPGA_TIMESYNCHW 0" >> $OUT_FILE
	fi
	;;
	7)
	if [ "$PCPDefineValue" ]; then
		echo "#define PCP_PDI_ASYNC_BUF_MAX $PCPDefineValue" >> $OUT_FILE
	else
		echo "#define PCP_PDI_ASYNC_BUF_MAX //INVALID" >> $OUT_FILE
	fi
	;;
    *)echo Not a valid loop count!
	;;
esac

	cnt=$((cnt + 1))

done

echo "
#endif /* _CNAPICFG_H_ */

/* END-OF-FILE */" >> $OUT_FILE

# verify output-file generation
if [ ! -f "$OUT_FILE" ]
then   # Exit if no such file.
  echo -e "$OUT_FILE not found.\n"
  exit $E_NOSUCHFILE
fi

echo -e "Generating cnApiCfg.h done!\n"

exit