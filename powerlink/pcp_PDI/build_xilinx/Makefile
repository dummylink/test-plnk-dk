################################################################################
# Project		: CNDK PCP PDI (Xilinx)
# Module		: build system
# Autor			: mairt
# Date			: 13.02.2012
# File			: Makefile
# contents		: Controls the build of the CNDK software (PCP Processor)
################################################################################

VERSION = 0.1

include makefile.settings

POWERLINK_DIR=${CNDK_DIR}/powerlink/generic/openPOWERLINK_CNDKPatched
APP_DIR=${CNDK_DIR}/powerlink/pcp_PDI
OBJDICT_DIR=${CNDK_DIR}/objDicts/PDI
EDRV_DIR=${CNDK_DIR}/powerlink/generic/POWERLINK_IP_Edrv
CNDK_TARGET_DIR=${CNDK_DIR}/powerlink/generic/target/xilinx_microblaze
CN_API_DIR=${CNDK_DIR}/libCnApi

OBJDIR=obj

##################################
#general compile defines
CC=mb-gcc
AR=mb-ar
CP=cp
RM=rm -rf
EXECUTABLE=pcp_pdi.elf
LSSCRIPT=lscript_$(BOARD_NAME)_$(BUS_INTERFACE).ld
MACROS=-DMAKE_BUILD_PCP -D${DBG_MODE} -DDEF_DEBUG_LVL=${DEF_DEBUG_LVL}
CFLAGS=-g3 -Wall -fmessage-length=0 $(PROC_FEATURES) ${MACROS}
CPPFLAGS=-MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"
LDFLAGS=-Wl,-T -Wl,${LSSCRIPT} $(PROC_FEATURES) -Wl,-Map,${EXECUTABLE}.map


##################################
# Include directory

INCLUDES=-I${APP_DIR}\
-I${EDRV_DIR}/openmac/include \
-I${POWERLINK_DIR}/Include \
-I${POWERLINK_DIR}/Include/user \
-I${POWERLINK_DIR}/Include/kernel \
-I${POWERLINK_DIR}/SharedBuff \
-I${POWERLINK_DIR}/ObjDicts \
-I${POWERLINK_DIR}/Target/xilinx_microblaze/no_os/gnu/generic \
-I${OBJDICT_DIR} \
-I${BSP_PATH}/${PROCESSOR_NAME}/include \
-I${CNDK_TARGET_DIR}/include \
-I${CN_API_DIR}/include \
-I${CN_API_DIR}/utils

##################################
# Source files
SRCFILES=${APP_DIR}/pcpMain.c \
${APP_DIR}/pcpEvent.c \
${APP_DIR}/pcpStateMachine.c \
${APP_DIR}/pcpPdo.c \
${APP_DIR}/pcpAsync.c \
${APP_DIR}/pcpAsyncSm.c \
${APP_DIR}/pcpSync.c \
${OBJDICT_DIR}/Objdict.c \
${EDRV_DIR}/openmac/source/EdrvOpenMac.c \
${EDRV_DIR}/openmac/source/EplTimerSynck_OpenMac.c \
${EDRV_DIR}/openmac/source/EplTgtTimeStamp_OpenMac.c \
${EDRV_DIR}/openmac/source/omethlib.c \
${EDRV_DIR}/openmac/source/omethlibint.c \
${POWERLINK_DIR}/EplStack/EplDllk.c \
${POWERLINK_DIR}/EplStack/EplDllkCal.c \
${POWERLINK_DIR}/EplStack/EplDlluCal.c \
${POWERLINK_DIR}/EplStack/EplLedu.c \
${POWERLINK_DIR}/EplStack/EplEventk.c \
${POWERLINK_DIR}/EplStack/EplEventu.c \
${POWERLINK_DIR}/EplStack/EplNmtk.c \
${POWERLINK_DIR}/EplStack/EplNmtu.c \
${POWERLINK_DIR}/EplStack/EplNmtCnu.c \
${POWERLINK_DIR}/EplStack/EplPdok.c \
${POWERLINK_DIR}/EplStack/EplPdokCal.c \
${POWERLINK_DIR}/EplStack/EplPdou.c \
${POWERLINK_DIR}/EplStack/EplPdouCal.c \
${POWERLINK_DIR}/EplStack/EplObd.c \
${POWERLINK_DIR}/EplStack/EplSdoComu.c \
${POWERLINK_DIR}/EplStack/EplSdoAsySequ.c \
${POWERLINK_DIR}/EplStack/EplSdoAsndu.c \
${POWERLINK_DIR}/EplStack/EplTimeruGeneric.c \
${POWERLINK_DIR}/EplStack/EplErrorHandlerk.c \
${POWERLINK_DIR}/EplStack/EplApiGeneric.c \
${POWERLINK_DIR}/Target/xilinx_microblaze/no_os/gnu/generic/ShbTarget_Microblaze.c \
${POWERLINK_DIR}/Target/xilinx_microblaze/no_os/gnu/generic/xilinx_irq.c \
${POWERLINK_DIR}/Target/xilinx_microblaze/no_os/gnu/generic/xilinx_usleep.c \
${POWERLINK_DIR}/SharedBuff/SharedBuff.c \
${POWERLINK_DIR}/SharedBuff/ShbIpc-NoOS.c \
${CN_API_DIR}/utils/stateMachine.c \
${CNDK_TARGET_DIR}/src/fpgaCfg.c \
${CNDK_TARGET_DIR}/src/fwUpdate.c \
${CNDK_TARGET_DIR}/src/boot.c \
${CNDK_TARGET_DIR}/src/systemComponents.c

VPATH=$(sort $(patsubst " ", :, $(dir $(SRCFILES))))

###################################
# set Optimization level makro
ifeq ($(OPT_LEVEL),-O0)
	MACROS+= -DXIL_NO_OPT_LEVEL
endif
ifeq ($(OPT_LEVEL),-O1)
	MACROS+= -DXIL_OPT_LEVEL_1
endif
ifeq ($(OPT_LEVEL),-O2)
	MACROS+= -DXIL_OPT_LEVEL_2
endif
ifeq ($(OPT_LEVEL),-O3)
	MACROS+= -DXIL_OPT_LEVEL_3
endif
ifeq ($(OPT_LEVEL),-Os)
	MACROS+= -DXIL_OPT_LEVEL_SIZE
endif

###################################
# set endian according to bus interface
ifeq ($(BUS_INTERFACE),axi)
	PROC_FEATURES+= -mlittle-endian
	SRCFILES+= ${POWERLINK_DIR}/EplStack/amiarm.c
else
	PROC_FEATURES+= -mbig-endian
	SRCFILES+= ${POWERLINK_DIR}/EplStack/amibe.c
endif

###################################
# libraries
LIBSPATH=-L${BSP_PATH}/${PROCESSOR_NAME}/lib

###################################
# objects
OBJ = $(addprefix $(OBJDIR)/,$(notdir $(patsubst %.c, %.o, $(SRCFILES))))
OBJD = $(addprefix $(OBJDIR)/,$(notdir $(patsubst %.c, %.d, $(SRCFILES))))

OUTPUT_OPTION = -o $@

CFLAGS += ${INCLUDES}

.PHONY:	header clean builddir

header:
	@echo
	@echo "================================================================================"
	@echo " PCP PDI - Build System (Xilinx)"
	@echo "================================================================================"
	@echo
	@echo " Copyright (c) 2012 B&R"
	@echo " Version $(VERSION)"
	@echo "================================================================================"
	@echo
	@echo "Write 'make all' to build the PCP PDI example"
	@echo "Change 'makefile.setting' to configure build system"	


all: builddir ${CN_API_DIR}/include/cnApiCfg.h ${EXECUTABLE} ${EXECUTABLE}.size ${EXECUTABLE}.elfcheck

$(OBJDIR)/%.o: %.c
	@echo Building file: $<
	@echo Invoking: MicroBlaze gcc compiler
	$(CC) -c ${OPT_LEVEL} $(CFLAGS) $(CPPFLAGS) $< $(OUTPUT_OPTION)
	@echo Finished building: $<
	@echo ' '

builddir:
	$(shell mkdir $(OBJDIR))

# extra rule for usleep to set opt level to zero
$(OBJDIR)/xilinx_usleep.o: xilinx_usleep.c xilinx_usleep.h
	@echo Building file: $<
	@echo Invoking: MicroBlaze gcc compiler
	$(CC) -O0 -c $(CFLAGS) $(CPPFLAGS) $< ${OUTPUT_OPTION}
	@echo Finished building: $<
	@echo ' '

${EXECUTABLE}: ${OBJ} ${LSSCRIPT}
	@echo Building target: $@
	@echo Invoking: MicroBlaze gcc linker
	$(CC) $(LDFLAGS) ${LIBSPATH} ${OBJ} -o ${EXECUTABLE}
	@echo Finished building target: $@
	@echo ' '
	
${EXECUTABLE}.size: ${EXECUTABLE}
	@echo Invoking: MicroBlaze Print Size
	mb-size ${EXECUTABLE}  |tee "${EXECUTABLE}.size"
	@echo Finished building: $@
	@echo ' '

${EXECUTABLE}.elfcheck: ${EXECUTABLE}
	@echo Invoking: Xilinx ELF Check
	elfcheck ${EXECUTABLE} -hw ${HW_PLATFORM_PATH}/system.xml -pe ${PROCESSOR_NAME}  |tee "${EXECUTABLE}.elfcheck"
	@echo Finished building: $@
	@echo ' '

#Copy cnApiCfg.h to libCnApi
${CN_API_DIR}/include/cnApiCfg.h: ${BSP_PATH}/${PROCESSOR_NAME}/include/cnApiCfg.h
	@echo Copy: cnApiCfg.h to library path:
	${CP} ${BSP_PATH}/${PROCESSOR_NAME}/include/cnApiCfg.h ${CN_API_DIR}/include/cnApiCfg.h
	@echo Finished copying
	@echo ' '

clean:
	-$(RM) $(EXECUTABLE) ${EXECUTABLE}.size ${EXECUTABLE}.elfcheck ${EXECUTABLE}.map $(OBJ) $(OBJD) ${CN_API_DIR}/include/cnApiCfg.h

-include $(OBJD)
