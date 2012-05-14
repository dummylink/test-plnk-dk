################################################################################
# Project		: CNDK Ap PDI (Xilinx)
# Module		: build system
# Autor			: mairt
# Date			: 13.02.2012
# File			: Makefile
# contents		: Controls the build of the CNDK software (AP Processor)
################################################################################

VERSION = 0.1

include makefile.settings

POWERLINK_DIR=${CNDK_DIR}/powerlink/generic/openPOWERLINK_CNDKPatched
APP_DIR=${CNDK_DIR}/apps/ap_PDI
OBJDICT_DIR=${CNDK_DIR}/objDicts/PDI
CN_API_DIR=${CNDK_DIR}/libCnApi

OBJDIR=obj

##################################
#general compile defines
CC=mb-gcc
AR=mb-ar
CP=cp
RM=rm -rf
EXECUTABLE=ap_pdi.elf
LSSCRIPT=lscript_$(BOARD_NAME)_$(BUS_INTERFACE).ld
MACROS=-D${DBG_MODE} -DDEF_DEBUG_LVL=${DEF_DEBUG_LVL}
CFLAGS=-g3 -Wall -fmessage-length=0 $(PROC_FEATURES) ${MACROS}
CPPFLAGS=-MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"
LDFLAGS=-Wl,-T -Wl,${LSSCRIPT} $(PROC_FEATURES) -Wl,-Map,${EXECUTABLE}.map

##################################
# Include directory
INCLUDES=-I${APP_DIR}\
-I${OBJDICT_DIR} \
-I${BSP_PATH}/${PROCESSOR_NAME}/include \
-I${CN_API_DIR}/include \
-I${CN_API_DIR}/include/openPOWERLINK \
-I${CN_API_DIR}/include/openPOWERLINK/kernel \
-I${CN_API_DIR}/include/openPOWERLINK/user \
-I${CN_API_DIR}/utils \
-I${POWERLINK_DIR}/Target/xilinx_microblaze/no_os/gnu/generic \
-I${APP_DIR}/target/xilinx_microblaze/include 

##################################
# Source files
SRCFILES=${APP_DIR}/main.c \
${APP_DIR}/target/xilinx_microblaze/src/systemComponents.c \
${POWERLINK_DIR}/Target/xilinx_microblaze/no_os/gnu/generic/xilinx_usleep.c

VPATH=$(sort $(patsubst " ", :, $(dir $(SRCFILES))))

###################################
# set endian according to bus interface
ifeq ($(BUS_INTERFACE),axi)
	PROC_FEATURES+= -mlittle-endian
else
	PROC_FEATURES+= -mbig-endian
endif

###################################
# libraries
CNAPILIB=${CN_API_DIR}/target/microblaze_newlib/libCnApi.a
LIBSPATH=-L${BSP_PATH}/${PROCESSOR_NAME}/lib -L${CN_API_DIR}/target/microblaze_newlib

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
	@echo " AP PDI - Build System (Xilinx)"
	@echo "================================================================================"
	@echo
	@echo " Copyright (c) 2012 B&R"
	@echo " Version $(VERSION)"
	@echo "================================================================================"
	@echo
	@echo "Write 'make all' to build the AP PDI example"
	@echo "Change 'makefile.setting' to configure build system"		

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

${EXECUTABLE}: ${OBJ} ${LSSCRIPT} ${CNAPILIB}
	@echo Building target: $@
	@echo Invoking: MicroBlaze gcc linker
	$(CC) $(LDFLAGS) ${LIBSPATH} ${OBJ} -o ${EXECUTABLE} ${CNAPILIB}
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
	-$(RM) $(EXECUTABLE) ${EXECUTABLE}.size ${EXECUTABLE}.elfcheck ${EXECUTABLE}.map $(OBJ) $(OBJD)
	
-include $(OBJD)
