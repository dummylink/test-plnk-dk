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

    # delete post-checkout script
    rm -rf $1/post-checkout

    echo "Cleanup openPOWERLINK_CNDKPatched directory..."
    rm -rf  $1/powerlink/generic/openPOWERLINK_CNDKPatched/Examples
    rm -rf  $1/powerlink/generic/openPOWERLINK_CNDKPatched/Edrv

    if [ "$2" = "altera" ]
    then
        #cleanup for xilinx
        echo "Cleanup '.' directory..."
        rm -rf $1/tools/altera $1/release.sh
        rm -rf $1/powerlink/generic/nios2-flash-override.txt
        rm -rf $1/project.config

        rm -rf $1/alt_*.txt
        mv $1/xil_readme.txt $1/readme.txt
        mv $1/xil_revision.txt $1/revision.txt

        # cleanup ap_PDI program
        echo "Cleanup $1/apps/ap_PDI/ program..."
        cp -rf $1/apps/ap_PDI/xilinx/* $1/apps/ap_PDI/
        cp -rf $1/apps/ap_PDI/xilinx/.??* $1/apps/ap_PDI/
        rm -rf $1/apps/ap_PDI/xilinx/ $1/apps/ap_PDI/altera/
        rm -rf $1/apps/ap_PDI/target/altera_nios/

        # cleanup pcp_PDI program
        echo "Cleanup $1/powerlink/pcp_PDI/ program..."
        cp -rf $1/powerlink/pcp_PDI/xilinx/* $1/powerlink/pcp_PDI/
        cp -rf $1/powerlink/pcp_PDI/xilinx/.??* $1/powerlink/pcp_PDI/
        rm -rf $1/powerlink/pcp_PDI/xilinx/ $1/powerlink/pcp_PDI/altera/

        # cleanup pcp_DirectIO program
        echo "Cleanup $1/powerlink/pcp_DirectIO/ program..."
        cp -rf $1/powerlink/pcp_DirectIO/xilinx/* $1/powerlink/pcp_DirectIO/
        cp -rf $1/powerlink/pcp_DirectIO/xilinx/.??* $1/powerlink/pcp_DirectIO/
        rm -rf $1/powerlink/pcp_DirectIO/xilinx/ $1/powerlink/pcp_DirectIO/altera/

        # cleanup powerlink folder
        echo "Cleanup $1/powerlink/ folder..."
        rm -rf $1/powerlink/target/altera_nios/
        
        # cleanup library folder
        echo "Cleanup $1/libCnApi/ program..."
        cp -rf $1/libCnApi/target/microblaze_newlib/.??* $1/libCnApi/
        rm -rf $1/libCnApi/target/nios2_newlib
        

    else
        #cleanup for altera
        echo "Cleanup '.' directory..."
        rm -rf $1/tools/xilinx $1/release.sh
        rm -rf $1/xil_*.txt
        mv $1/alt_readme.txt $1/readme.txt
        mv $1/alt_revision.txt $1/revision.txt
        mv $1/alt_update.txt $1/update.txt

        # cleanup ap_PDI program
        echo "Cleanup $1/apps/ap_PDI/ program..."
        cp -rf $1/apps/ap_PDI/altera/* $1/apps/ap_PDI/
        cp -rf $1/apps/ap_PDI/altera/.??* $1/apps/ap_PDI/
        rm -rf $1/apps/ap_PDI/altera/ $1/apps/ap_PDI/xilinx/
        rm -rf $1/apps/ap_PDI/target/xilinx_microblaze/

        # cleanup pcp_PDI program
        echo "Cleanup $1/powerlink/pcp_PDI/ program..."
        cp -rf $1/powerlink/pcp_PDI/altera/* $1/powerlink/pcp_PDI/
        cp -rf $1/powerlink/pcp_PDI/altera/.??* $1/powerlink/pcp_PDI/
        rm -rf $1/powerlink/pcp_PDI/altera/ $1/powerlink/pcp_PDI/xilinx/

        # cleanup pcp_DirectIO program
        echo "Cleanup $1/powerlink/pcp_DirectIO/ program..."
        cp -rf $1/powerlink/pcp_DirectIO/altera/* $1/powerlink/pcp_DirectIO/
        cp -rf $1/powerlink/pcp_DirectIO/altera/.??* $1/powerlink/pcp_DirectIO/
        rm -rf $1/powerlink/pcp_DirectIO/altera/ $1/powerlink/pcp_DirectIO/xilinx/
        
        # cleanup powerlink folder
        echo "Cleanup $1/powerlink/ folder..."
        rm -rf $1/powerlink/target/xilinx_microblaze/

        # cleanup library folder
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

