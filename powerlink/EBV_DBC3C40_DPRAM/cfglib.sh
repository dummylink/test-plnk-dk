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

if [ ! -f "$OUT_FILE" ]
then   # Exit if no such file.
  echo -e "$OUT_FILE not found.\n"
  exit $E_NOSUCHFILE
fi

# Search pattern in system.h
PATTERN[0]="POWERLINK_0_PDI_PCP_CONFIG "
PATTERN[1]="POWERLINK_0_PDI_PCP_CONFIGAPENDIAN "
PATTERN[2]="POWERLINK_0_PDI_PCP_PDIRPDOS "
PATTERN[3]="POWERLINK_0_PDI_PCP_PDITPDOS "

###################################################################

echo "/* This file is used for configuration of the Cn API Library.
It is automatically build according to PCP system.h, every time
a rebuild of the PCP software is executed. */

/* Defines for CN API Library */" > $OUT_FILE


cnt=0
while [ $cnt -lt 4 ] ; do
	
pattern=${PATTERN[$cnt]}
PCPDefineValue=$(grep "$pattern" ${IN_FILE} | grep \#define | cut -d ' ' -f 3) #-d = delimiter (Space) -f= 3rd fragment is value of define
echo "$pattern= $PCPDefineValue"

case  $cnt  in
    0)
	case $PCPDefineValue in
		0) echo "#define CN_API_NOT_PRESENT" >> $OUT_FILE ;;
		1) echo "#define CN_API_USING_8BIT" >> $OUT_FILE ;;	
		2) echo "#define CN_API_USING_16BIT" >> $OUT_FILE ;;		
		3) echo "#define CN_API_USING_SPI" >> $OUT_FILE ;;	
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
		echo "#define ${PATTERN[$cnt]}$PCPDefineValue" >> $OUT_FILE 
	else
		echo "#define ${PATTERN[$cnt]}0" >> $OUT_FILE	
	fi
	;;	
    3)
	if [ "$PCPDefineValue" -gt "0" ]; then
		echo "#define ${PATTERN[$cnt]}$PCPDefineValue" >> $OUT_FILE 
	else
		echo "#define ${PATTERN[$cnt]}0" >> $OUT_FILE
	fi
	;;	
    *)echo Not a valid loop count!
	;;
esac
	
	cnt=$((cnt + 1))
	
done

echo -e "Generating cnApiCfg.h done!\n"

exit 