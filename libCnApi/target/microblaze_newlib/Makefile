################################################################################
# Project		: CNDK libCnApi (Xilinx)
# Module		: build system
# Autor			: mairt
# Date			: 13.02.2012
# File			: Makefile
# contents		: Controls the build of the CNDK software (libCnApi part)
################################################################################
################################################################################
# Version		Autor		Date			Feature
# V0.1			mairt	
# V0.2			mairt		13.02.2012		Make file for microblaze based sytems
# V0.3			abhiramb	11.03.2013		ARM processor integrated for Zynq Projects
##################################
VERSION = 0.3

include makefile.settings

##################################
# Directory structure
OBJDICT_DIR=${CNDK_DIR}/objDicts/PDI
CN_API_DIR=${CNDK_DIR}/libCnApi
POWERLINK_DIR=${CNDK_DIR}/powerlink/generic/openPOWERLINK_CNDKPatched

OBJDIR=obj

##################################
#general compile defines
ifeq ($(BOARD_NAME),zynq)
	CC=arm-xilinx-eabi-gcc
	AR=arm-xilinx-eabi-ar
	SIZE=arm-xilinx-eabi-size
	PROC=ARM_xilinx
else
	CC=mb-gcc
	AR=mb-ar
	SIZE=mb-size
	PROC=MicroBlaze
endif
CP=cp
RM=rm
PERL=xilperl
LIBRARY=libCnApi.a

ARFLAGS=-src
MACROS=-D${DBG_MODE} -DDEF_DEBUG_LVL=${DEF_DEBUG_LVL}
CFLAGS=-g3 -Wall -fmessage-length=0 ${MACROS}
CPPFLAGS=-MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"
LDFLAGS=-Wl,-T -Wl,${LSSCRIPT} -Wl,-Map,${EXECUTABLE}.map
ifeq ($(BOARD_NAME),zynq)
	MACROS+= -D__arm__ 
	CFLAGS+= $(PROC_FEATURES_ARM)
	LDFLAGS+= $(PROC_FEATURES_ARM) 
else
	MACROS+= -D__MICROBLAZE__  
	CFLAGS+= $(PROC_FEATURES_MB)
	LDFLAGS+= $(PROC_FEATURES_MB)
endif

##################################
# Include directory
INCLUDES=-I${BSP_PATH}/${PROCESSOR_NAME}/include \
-I${OBJDICT_DIR} \
-I${CN_API_DIR}/inc \
-I${CN_API_DIR}/int \
-I${CN_API_DIR}/int/openPOWERLINK \
-I${CN_API_DIR}/int/openPOWERLINK/kernel \
-I${CN_API_DIR}/int/openPOWERLINK/user \
-I${CNDK_DIR}/common/inc \
-I${POWERLINK_DIR}/Target/xilinx_microblaze/no_os/gnu/generic

##################################
# Source files
SRCFILES=${CN_API_DIR}/src/cnApi.c \
${CN_API_DIR}/src/amiarm.c \
${CN_API_DIR}/src/cnApiAsync.c \
${CN_API_DIR}/src/cnApiAsyncSm.c \
${CN_API_DIR}/src/cnApiEvent.c \
${CN_API_DIR}/src/cnApiObjects.c \
${CN_API_DIR}/src/cnApiPdiSpi.c \
${CN_API_DIR}/src/cnApiPdo.c \
${CN_API_DIR}/src/cnApiStateMachine.c \
${CN_API_DIR}/src/EplObd.c \
${CN_API_DIR}/src/EplSdoAsySequ.c \
${CN_API_DIR}/src/EplSdoComu.c \
${CNDK_DIR}/common/src/stateMachine.c 

VPATH=$(sort $(patsubst " ", :, $(dir $(SRCFILES))))

###################################
# set endian according to bus interface
ifeq ($(BUS_INTERFACE),axi)
	PROC_FEATURES_MB+= -mlittle-endian
	SRCFILES+= ${POWERLINK_DIR}/EplStack/amiarm.c
else
	PROC_FEATURES_MB+= -mbig-endian
	SRCFILES+= ${POWERLINK_DIR}/EplStack/amibe.c
endif

###################################
# include SPI driver
ifeq ($(INCLUDE_SPI_DRV),yes)
	SRCFILES+= ${CN_API_DIR}/src/cnApiPdiSpi.c
endif

###################################
# Virtual Ethernet
ifeq ($(VIRT_ETH),yes)
	SRCFILES+= 	${CN_API_DIR}/cnApiAsyncVeth.c
endif

###################################
# objects
OBJ = $(addprefix $(OBJDIR)/,$(notdir $(patsubst %.c, %.o, $(SRCFILES))))
OBJD = $(addprefix $(OBJDIR)/,$(notdir $(patsubst %.c, %.d, $(SRCFILES))))

OUTPUT_OPTION = -o $@

CFLAGS += ${INCLUDES}

.PHONY:	header
header:
	@echo ""
	@echo "================================================================================"
	@echo " libCnApi - Build System (Xilinx)"
	@echo "================================================================================"
	@echo ""
	@echo " Copyright (c) 2012 B&R"
	@echo " Version $(VERSION)"
	@echo "================================================================================"
	@echo ""
	@echo "Write 'make all' to build the $(LIBRARY)"
	@echo ""
	@echo "Write 'make clean' to remove all generated files"
	@echo ""
	@echo "Change 'makefile.setting' to configure build system"	

all: builddir ${LIBRARY}

$(OBJDIR)/%.o: %.c
	@echo Building file: $<
	@echo Invoking: $(PROC)gcc compiler
	$(CC) -c ${OPT_LEVEL} $(CFLAGS) $(CPPFLAGS) $< $(OUTPUT_OPTION)
	@echo Finished building: $<
	@echo ' '

.PHONY:	builddir
builddir:
	$(shell mkdir $(OBJDIR))

# extra rule for usleep to set opt level to zero
$(OBJDIR)/xilinx_usleep.o: xilinx_usleep.c xilinx_usleep.h
	@echo Building file: $<
	@echo Invoking: $(PROC) gcc compiler
	$(CC) -c -O0 $(CFLAGS) $(CPPFLAGS) $< ${OUTPUT_OPTION}
	@echo Finished building: $<
	@echo ' '

${LIBRARY}: ${OBJ}
	@echo Building library: $@
	@echo Invoking: $(PROC) ar archiver
	-@$(RM) -rf $@
	$(AR) $(ARFLAGS) $@ $^
	@echo Finished building library: $@
	@echo ' '

.PHONY:	clean
clean:
	-$(RM) -rf $(LIBRARY) $(OBJ) $(OBJD)

-include $(OBJD)
