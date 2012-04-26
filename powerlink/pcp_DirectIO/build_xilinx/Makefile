################################################################################
# Project		: CNDK DirectIO (Xilinx)
# Module		: build system
# Autor			: mairt
# Date			: 13.02.2012
# File			: Makefile
# contents		: Controls the build of the CNDK software
################################################################################

VERSION = 0.1

include makefile.settings

POWERLINK_DIR=${CNDK_DIR}/powerlink/generic/openPOWERLINK_CNDKPatched
APP_DIR=${CNDK_DIR}/powerlink/pcp_DirectIO
OBJDICT_DIR=${CNDK_DIR}/objDicts/Direct_IO
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
EXECUTABLE=directIO.elf
LSSCRIPT=lscript_$(BOARD_NAME)_$(BUS_INTERFACE).ld
MACROS=-DMAKE_BUILD_PCP -D${DBG_MODE} -DDEF_DEBUG_LVL=${DEF_DEBUG_LVL}
CFLAGS=-g3 -Wall -fmessage-length=0 $(PROC_FEATURES)  ${MACROS}
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
-I${CN_API_DIR}/include

##################################
# Source files
SRCFILES=${APP_DIR}/main.c \
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
${CNDK_TARGET_DIR}/src/fpgaCfg.c \
${CNDK_TARGET_DIR}/src/fwUpdate.c \
${CNDK_TARGET_DIR}/src/boot.c \
${CNDK_TARGET_DIR}/src/systemComponents.c

VPATH=$(sort $(patsubst " ", :, $(dir $(SRCFILES))))

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

.PHONY:	header clean

header:
	@echo
	@echo "================================================================================"
	@echo " Direct IO - Build System (Xilinx)"
	@echo "================================================================================"
	@echo
	@echo " Copyright (c) 2012 B&R"
	@echo " Version $(VERSION)"
	@echo "================================================================================"
	@echo
	@echo "Write 'make all' to build the Direct I/O example"

all: builddir ${EXECUTABLE} ${EXECUTABLE}.size ${EXECUTABLE}.elfcheck

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
	$(CC) -c -O0 $(CFLAGS) $(CPPFLAGS) $< ${OUTPUT_OPTION}
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

clean:
	-${RM} $(EXECUTABLE) ${EXECUTABLE}.size ${EXECUTABLE}.elfcheck ${EXECUTABLE}.map $(OBJ) $(OBJD)

-include $(OBJD)
