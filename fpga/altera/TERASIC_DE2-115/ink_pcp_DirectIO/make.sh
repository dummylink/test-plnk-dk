#!/bin/bash
# ----- Execute this script within the Nios II Command Shell   ------
# ----- It builds all SOPC and the Quartus Projects found in   ------
# ----- PWD or a specified path.                               ------

#
# USER Options (1=true, 0=false)
#
BUILD_SOPC=1
BUILD_QUARTUS=1
# do rebuild even if system was already generated
FORCE_SOPC_REBUILD=1
FORCE_QUARTUS_REBUILD=1

#
# Resolve TOP_LEVEL_DIR, default to PWD if no path provided.
#
if [ $# -eq 0 ]; then
TOP_LEVEL_DIR=$PWD
else
TOP_LEVEL_DIR=$1
fi
echo
echo --- This is make.sh ---
echo "INFO: TOP_LEVEL_DIR is $TOP_LEVEL_DIR"
#
# Generate SOPC list...
#
SOPC_LIST=`find $TOP_LEVEL_DIR -name "*.sopc"`
#
# Generate Quartus II project list.
#
PROJ_LIST=`find $TOP_LEVEL_DIR -name "*.qpf" | sed s/\.qpf//g`
#
# Main body of the script. First "generate" all of the SOPC Builder
# systems that are found, then compile the Quartus II projects.
#
#
# Run SOPC Builder to "generate" all of the systems that were found.
#
if [ $BUILD_SOPC -eq 1 ]; then
for SOPC_FN in $SOPC_LIST
do
cd `dirname $SOPC_FN`
if [ \( ! -e `basename $SOPC_FN .sopc`.vhd -a ! -e `basename $SOPC_FN .sopc`.v \) -o $FORCE_SOPC_REBUILD -eq 1 ]; then
echo
echo "INFO: Generating $SOPC_FN SOPC Builder system."
sopc_builder --refresh
sopc_builder --generate=1 --debug_log=debug_log.txt
if [ $? -ne 4 ]; then
echo; echo
echo "ERROR: SOPC Builder generation for $SOPC_FN has failed !"
echo "ERROR: Please check the SOPC file and data " \
"in the directory `dirname $SOPC_FN` for errors."
exit 1
fi
else
echo 
echo "INFO: HDL already exists for $SOPC_FN, skipping Generation."
fi
cd $TOP_LEVEL_DIR
done
fi

#
# Now, generate all of the Quartus II projects that were found.
#
if [ $BUILD_QUARTUS -eq 1 ]; then
for PROJ in $PROJ_LIST
do
cd `dirname $PROJ`
if [ \( ! -e `basename $PROJ`.sof \) -o $FORCE_QUARTUS_REBUILD -eq 1 ]; then
echo 
echo "INFO: Compiling $PROJ Quartus II Project."
quartus_cmd `basename $PROJ`.qpf -c `basename $PROJ`.qsf
if [ $? -ne 0 ]; then
echo; echo
echo "ERROR: Quartus II compilation for $PROJ has failed !"
echo "ERROR: Please check the Quartus II project “ \
“in `dirname $PROJ` for details."
exit 1
fi
else
echo
echo "INFO: SOF already exists for $PROJ, skipping compilation."
fi
cd $TOP_LEVEL_DIR
done
fi

exit 0

