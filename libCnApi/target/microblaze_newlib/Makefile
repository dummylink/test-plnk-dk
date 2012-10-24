################################################################################
# Project		: CNDK libCnApi (Xilinx)
# Module		: build system
# Autor			: mairt
# Date			: 13.02.2012
# File			: Makefile
# contents		: Controls the build of the CNDK software (libCnApi part)
################################################################################

VERSION = 0.2

include makefile.settings

##################################
# Directory structure
OBJDICT_DIR=${CNDK_DIR}/objDicts/PDI
CN_API_DIR=${CNDK_DIR}/libCnApi
POWERLINK_DIR=${CNDK_DIR}/powerlink/generic/openPOWERLINK_CNDKPatched

OBJDIR=obj

##################################
#general compile defines
CC=mb-gcc
AR=mb-ar
CP=cp
RM=rm
PERL=xilperl
LIBRARY=libCnApi.a

ARFLAGS=-src
MACROS=-D__MICROBLAZE__ -D${DBG_MODE} -DDEF_DEBUG_LVL=${DEF_DEBUG_LVL}
CFLAGS=-g3 -Wall -fmessage-length=0 $(PROC_FEATURES) ${MACROS}
CPPFLAGS=-MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"
LDFLAGS=-Wl,-T -Wl,${LSSCRIPT} $(PROC_FEATURES) -Wl,-Map,${EXECUTABLE}.map

##################################
# Include directory
INCLUDES=-I${APP_DIR}\
-I${BSP_PATH}/${PROCESSOR_NAME}/include \
-I${OBJDICT_DIR} \
-I${BSP_PATH}/${PROCESSOR_NAME}/include \
-I${CN_API_DIR}/include \
-I${CN_API_DIR}/include/public \
-I${CN_API_DIR}/include/openPOWERLINK \
-I${CN_API_DIR}/include/openPOWERLINK/kernel \
-I${CN_API_DIR}/include/openPOWERLINK/user \
-I${CN_API_DIR}/utils \
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
${CN_API_DIR}/utils/stateMachine.c 

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
	@echo Invoking: MicroBlaze gcc compiler
	$(CC) -c ${OPT_LEVEL} $(CFLAGS) $(CPPFLAGS) $< $(OUTPUT_OPTION)
	@echo Finished building: $<
	@echo ' '

.PHONY:	builddir
builddir:
	$(shell mkdir $(OBJDIR))

# extra rule for usleep to set opt level to zero
$(OBJDIR)/xilinx_usleep.o: xilinx_usleep.c xilinx_usleep.h
	@echo Building file: $<
	@echo Invoking: MicroBlaze gcc compiler
	$(CC) -c -O0 $(CFLAGS) $(CPPFLAGS) $< ${OUTPUT_OPTION}
	@echo Finished building: $<
	@echo ' '

${LIBRARY}: ${OBJ}
	@echo Building library: $@
	@echo Invoking: MicroBlaze ar archiver
	-@$(RM) -rf $@
	$(AR) $(ARFLAGS) $@ $^
	@echo Finished building library: $@
	@echo ' '

.PHONY:	clean
clean:
	-$(RM) -rf $(LIBRARY) $(OBJ) $(OBJD)

-include $(OBJD)
