#!/bin/bash
# release.sh
#
# Autor: mairt
# Date:  18.4.2012
# Desc:  Exports all necessary files in an release folder
#
# PARAMETERS: ./release.sh EXPORT_FOLDER PLATFORM
# EXAMPLE: ./release.sh alt_release altera
#          ./release.sh xil_release xilinx

# Save init parameters
PROG_NAME=$0
EXPORT_FOLDER=$1
if [ "$2" = "altera" ]
then
    PLATFORM_TO_REMOVE=xilinx
else
    PLATFORM_TO_REMOVE=altera
fi

create_rel_dir()
{
    mkdir -vp $2

    return $?
}

export_git_repo()
{
    echo "Export HEAD of git repository '$1' to folder '$2/$1'"
    BASEDIR=$PWD/$(dirname $0)
    cd $1
    git archive HEAD | tar -x -C $BASEDIR/$2/$1
    cd $BASEDIR

    return $?
}

change_platform_files()
{
    echo "Removing $2 related files..."
    echo "Delete $1/fpga/$2 folder..."
    rm -rf $1/fpga/$2

    if [ "$2" = "altera" ]
    then
        #cleanup for xilinx
        echo "Cleanup '.' directory..."
        rm -rf $1/tools $1/release.sh
        rm -rf $1/powerlink/generic/nios2-flash-override.txt
        rm -rf $1/project.config

        rm -rf $1/alt_*.txt
        mv $1/xil_readme.txt $1/readme.txt
        mv $1/xil_revision.txt $1/revision.txt

        # cleanup ap_PDI program
        echo "Cleanup $1/apps/ap_PDI/ program..."
        rm -rf $1/apps/ap_PDI/Makefile $1/apps/ap_PDI/create-this-app $1/apps/ap_PDI/bsp $1/apps/ap_PDI/*.bat $1/apps/ap_PDI/*.sh $1/apps/ap_PDI/*.elf
        mv $1/apps/ap_PDI/build_xilinx/* $1/apps/ap_PDI/
        rm -rf $1/apps/ap_PDI/build_xilinx/
        #modify makefile path
        sed -i 's/^CNDK\_DIR.*/CNDK\_DIR=\.\.\/\.\./' $1/apps/ap_PDI/makefile.settings
        sed -i 's/^CNAPILIB.*/CNAPILIB\=\$\{CN\_API\_DIR\}\/libCnApi\.a/' $1/apps/ap_PDI/Makefile
        #delete altera txt files
        rm -rf $1/apps/ap_PDI/alt_readme.txt
        mv $1/apps/ap_PDI/xil_readme.txt $1/apps/ap_PDI/readme.txt

        # cleanup pcp_PDI program
        echo "Cleanup $1/powerlink/pcp_PDI/ program..."
        rm -rf $1/powerlink/pcp_PDI/Makefile $1/powerlink/pcp_PDI/create-this-app $1/powerlink/pcp_PDI/bsp $1/powerlink/pcp_PDI/*.bat $1/powerlink/pcp_PDI/*.sh $1/powerlink/pcp_PDI/*.elf
        mv $1/powerlink/pcp_PDI/build_xilinx/* $1/powerlink/pcp_PDI/
        rm -rf $1/powerlink/pcp_PDI/build_xilinx/
        #modify makefile path
        sed -i 's/^CNDK\_DIR.*/CNDK\_DIR=\.\.\/\.\./' $1/powerlink/pcp_PDI/makefile.settings
        #delete altera txt files
        rm -rf $1/powerlink/pcp_PDI/alt_readme.txt
        mv $1/powerlink/pcp_PDI/xil_readme.txt $1/powerlink/pcp_PDI/readme.txt

        # cleanup pcp_DirectIO program
        echo "Cleanup $1/powerlink/pcp_DirectIO/ program..."
        rm -rf $1/powerlink/pcp_DirectIO/Makefile $1/powerlink/pcp_DirectIO/create-this-app $1/powerlink/pcp_DirectIO/bsp $1/powerlink/pcp_DirectIO/*.bat $1/powerlink/pcp_DirectIO/*.sh $1/powerlink/pcp_DirectIO/*.elf
        mv $1/powerlink/pcp_DirectIO/build_xilinx/* $1/powerlink/pcp_DirectIO/
        rm -rf $1/powerlink/pcp_DirectIO/build_xilinx/
        #modify makefile path
        sed -i 's/^CNDK\_DIR.*/CNDK\_DIR=\.\.\/\.\./' $1/powerlink/pcp_DirectIO/makefile.settings
        #delete altera txt files
        rm -rf $1/powerlink/pcp_DirectIO/alt_readme.txt
        mv $1/powerlink/pcp_DirectIO/xil_readme.txt $1/powerlink/pcp_DirectIO/readme.txt

        echo "Cleanup $1/libCnApi/ program..."
        rm -rf $1/libCnApi/target/nios2_newlib
        mv $1/libCnApi/target/microblaze_newlib/* $1/libCnApi
        rm -rf $1/libCnApi/target
        sed -i 's/^CNDK\_DIR.*/CNDK\_DIR=\.\./' $1/libCnApi/makefile.settings
        

    else
        #cleanup for altera
        echo "Cleanup '.' directory..."
        rm -rf $1/release.sh
        rm -rf $1/xil_*.txt
        mv $1/alt_readme.txt $1/readme.txt
        mv $1/alt_revision.txt $1/revision.txt
        mv $1/alt_update.txt $1/update.txt

        # cleanup ap_PDI program
        echo "Cleanup $1/apps/ap_PDI/ program..."
        rm -rf $1/apps/ap_PDI/build_xilinx
        #delete xilinx txt files
        rm -rf $1/apps/ap_PDI/xil_readme.txt
        mv $1/apps/ap_PDI/alt_readme.txt $1/apps/ap_PDI/readme.txt

        # cleanup pcp_PDI program
        echo "Cleanup $1/powerlink/pcp_PDI/ program..."
        rm -rf $1/powerlink/pcp_PDI/build_xilinx
        #delete xilinx txt files
        rm -rf $1/powerlink/pcp_PDI/xil_readme.txt
        mv $1/powerlink/pcp_PDI/alt_readme.txt $1/powerlink/pcp_PDI/readme.txt

        # cleanup pcp_DirectIO program
        echo "Cleanup $1/powerlink/pcp_DirectIO/ program..."
        rm -rf $1/powerlink/pcp_DirectIO/build_xilinx
        #delete xilinx txt files
        rm -rf $1/powerlink/pcp_DirectIO/xil_readme.txt
        mv $1/powerlink/pcp_DirectIO/alt_readme.txt $1/powerlink/pcp_DirectIO/readme.txt

        echo "Cleanup $1/libCnApi/ program..."
        rm -rf $1/libCnApi/target/microblaze_newlib
    fi

    return $?
}

###
# Main body of script starts here
###

echo "Release Xilinx CNDK files to folder: $EXPORT_FOLDER"
create_rel_dir $PROG_NAME $EXPORT_FOLDER
if [ $? -ne 0 ]
then
    echo "Error creating folder $EXPORT_FOLDER"
    exit $?
else
    echo "$EXPORT_FOLDER created successfully..."
fi

export_git_repo . $EXPORT_FOLDER
if [ $? -ne 0 ]
then
    echo "Error exporting git repo '.'"
    exit $?
else
    echo "Git repository '.' exported successfully..."
fi

export_git_repo powerlink/generic/openPOWERLINK_CNDKPatched $EXPORT_FOLDER
if [ $? -ne 0 ]
then
    echo "Error exporting git repo 'powerlink/generic/openPOWERLINK_CNDKPatched'"
    exit $?
else
    echo "Git repository 'powerlink/generic/openPOWERLINK_CNDKPatched' exported successfully..."
fi

change_platform_files $EXPORT_FOLDER $PLATFORM_TO_REMOVE
if [ $? -ne 0 ]
then
    echo "Error while changing $2 related files..."
    exit $?
else
    echo "Changing $2 related files successfully..."
fi

echo "End of script..."

exit 0

