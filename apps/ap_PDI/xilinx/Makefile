################################################################################
# Project		: CNDK Ap PDI (Xilinx)
# Module		: build system
# Autor			: mairt
# Date			: 13.02.2012
# File			: Makefile
# contents		: Controls the build of the CNDK software (AP Processor)
################################################################################

VERSION = 0.2

include makefile.settings

##################################
# Directory structure
POWERLINK_DIR=${CNDK_DIR}/powerlink/generic/openPOWERLINK_CNDKPatched
APP_DIR=${CNDK_DIR}/apps/ap_PDI
OBJDICT_DIR=${CNDK_DIR}/objDicts/PDI
LIBCNAPI_DIR=${CNDK_DIR}/libCnApi
LIBCNAPI_BUILD_DIR=${LIBCNAPI_DIR}/target/microblaze_newlib
TOOLS_PATH=${CNDK_DIR}/tools/xilinx

BOOTLOADER_PATH=$(TOOLS_PATH)/mem_bootloader
SCRIPT_DIR=$(TOOLS_PATH)/scripts

OBJDIR=obj

##################################
#translate dual_processor variable
ifeq ($(DUAL_PROCESSOR),yes)
DESIGN=dual
else
DESIGN=single
endif

##################################
#general compile defines
CC=mb-gcc
AR=mb-ar
CP=cp
RM=rm
PERL=xilperl
EXECUTABLE=ap_pdi
LIBCNAPI_NAME=CnApi

LSSCRIPT=lscript_$(BOARD_NAME)_$(BUS_INTERFACE)_$(DESIGN).ld
MACROS=-D${DBG_MODE} -DDEF_DEBUG_LVL=${DEF_DEBUG_LVL}
CFLAGS=-g3 -Wall -fmessage-length=0 $(PROC_FEATURES) ${MACROS}
CPPFLAGS=-MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"
LDFLAGS=-Wl,-T -Wl,${LSSCRIPT} $(PROC_FEATURES) -Wl,-Map,${EXECUTABLE}.map

# Flash defines
FLASH_IMAGE_NAME= flash_image
BOOTLOADER_NAME= mem_bootloader
BOOT_BUILD_DIR= build
OBJCPYFLAGS=-O srec
BITSTREAM= download

##################################
# Include directory
INCLUDES=-I${APP_DIR}\
-I${OBJDICT_DIR} \
-I${BSP_PATH}/${PROCESSOR_NAME}/include \
-I${LIBCNAPI_DIR}/inc \
-I${CNDK_DIR}/common/inc \
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
# set flash image parameters
ifeq ($(BOARD_NAME),s6plkeb)
	FLASH_IMAGE_NAME_DUAL= flash_image
	PROM_SCRIPT= program_prom_s6plkeb.cmd
	PROMGEN_FLAGS= -w -p mcs -c FF
	PROMGEN_TYPE= -s 8192 -u 0000
	PROMGEN_PREFIX= -spi
	PCUBLAZE_PARAMS= --format mcs --swap off
	PCUBLAZE_FILES= --promfile ${FLASH_IMAGE_NAME_DUAL}.mcs --outfile ${FLASH_IMAGE_NAME_DUAL}.mcs
endif

###################################
# libraries
LIBSPATH=-L${BSP_PATH}/${PROCESSOR_NAME}/lib -L${LIBCNAPI_BUILD_DIR}

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
	@echo " AP PDI - Build System (Xilinx)"
	@echo "================================================================================"
	@echo ""
	@echo " Copyright (c) 2012 B&R"
	@echo " Version $(VERSION)"
	@echo "================================================================================"
	@echo ""
	@echo "Write 'make all' to build the AP PDI example"
	@echo "Write 'make gen_flash' to generate the .mcs flash image"
	@echo "Write 'make prog_flash' to program the .mcs flash image to flash"
	@echo ""
	@echo "Write 'make clean' to remove all generated files"
	@echo ""
	@echo "Change 'makefile.setting' to configure build system"		

all: buildapp

.PHONY: buildapp
buildapp: libcnapi builddir ${EXECUTABLE}.elf ${EXECUTABLE}.size ${EXECUTABLE}.elfcheck ${EXECUTABLE}.mem

.PHONY:	builddir
builddir:
	$(shell mkdir $(OBJDIR))

# rule for building the libCnApi
.PHONY:	libcnapi
libcnapi :
	@$(MAKE) -C $(LIBCNAPI_BUILD_DIR) all BSP_PATH=../$(BSP_PATH) BUS_INTERFACE=$(BUS_INTERFACE) \
	OPT_LEVEL=$(OPT_LEVEL) DBG_MODE=$(DBG_MODE) DEF_DEBUG_LVL=$(DEF_DEBUG_LVL) \
	PROCESSOR_NAME=$(PROCESSOR_NAME)

$(OBJDIR)/%.o: %.c
	@echo Building file: $<
	@echo Invoking: MicroBlaze gcc compiler
	$(CC) -c ${OPT_LEVEL} $(CFLAGS) $(CPPFLAGS) $< $(OUTPUT_OPTION)
	@echo Finished building: $<
	@echo ' '

# extra rule for usleep to set opt level to zero
$(OBJDIR)/xilinx_usleep.o: xilinx_usleep.c xilinx_usleep.h
	@echo Building file: $<
	@echo Invoking: MicroBlaze gcc compiler
	$(CC) -c -O0 $(CFLAGS) $(CPPFLAGS) $< ${OUTPUT_OPTION}
	@echo Finished building: $<
	@echo ' '

${EXECUTABLE}.elf: ${OBJ} ${LSSCRIPT} $(LIBCNAPI_BUILD_DIR)/lib$(LIBCNAPI_NAME).a
	@echo Building target: $@
	@echo Invoking: MicroBlaze gcc linker
	$(CC) $(LDFLAGS) ${LIBSPATH} ${OBJ} -l$(LIBCNAPI_NAME) -o ${EXECUTABLE}.elf
	@echo Finished building target: $@
	@echo ' '
	
${EXECUTABLE}.size: ${EXECUTABLE}.elf
	@echo Invoking: MicroBlaze Print Size
	mb-size ${EXECUTABLE}.elf  |tee "${EXECUTABLE}.size"
	@echo Finished building: $@
	@echo ' '

${EXECUTABLE}.elfcheck: ${EXECUTABLE}.elf
	@echo Invoking: Xilinx ELF Check
	elfcheck ${EXECUTABLE}.elf -hw ${HW_PLATFORM_PATH}/system.xml -pe ${PROCESSOR_NAME}  |tee "${EXECUTABLE}.elfcheck"
	@echo Finished building: $@
	@echo ' '

${EXECUTABLE}.mem: ${EXECUTABLE}.elf
	@echo Invoking: Data2MEM
	Data2MEM -bd ${EXECUTABLE}.elf -d -o m ${EXECUTABLE}.mem
	@echo Finished building: $@
	@echo ' '

###################################
# flash rules
ifeq ($(DUAL_PROCESSOR), no)
.PHONY: gen_flash
gen_flash : buildapp ${FLASH_IMAGE_NAME_DUAL}.mcs

$(BOOTLOADER_PATH)/$(BOOT_BUILD_DIR)/$(BOOTLOADER_NAME).elf : $(BOOTLOADER_PATH)/Makefile
	@echo Invoking: bootloader build system
	$(MAKE) -C $(BOOTLOADER_PATH) all BSP_PATH="../$(BSP_PATH)" HW_PLATFORM_PATH="../$(HW_PLATFORM_PATH)" \
	BOARD_NAME="$(BOARD_NAME)" BUS_INTERFACE="$(BUS_INTERFACE)" PROC_FEATURES="$(PROC_FEATURES)" \
	PROCESSOR_NAME="$(PROCESSOR_NAME)" APP_MODE=pdi
	@echo Finished generating: $@
	@echo ' '

$(BITSTREAM).bit : ${HW_PLATFORM_PATH}/system.bit $(BOOTLOADER_PATH)/$(BOOT_BUILD_DIR)/$(BOOTLOADER_NAME).elf
	@echo Invoking: elfcheck pcp
	elfcheck -hw ${HW_PLATFORM_PATH}/system.xml -mode bootload -mem BRAM -pe $(PROCESSOR_NAME) \
	$(BOOTLOADER_PATH)/$(BOOT_BUILD_DIR)/$(BOOTLOADER_NAME).elf
	@echo Invoking: data2mem
	data2mem -bm ${HW_PLATFORM_PATH}/system_bd.bmm -bt ${HW_PLATFORM_PATH}/system.bit \
	-bd $(BOOTLOADER_PATH)/$(BOOT_BUILD_DIR)/$(BOOTLOADER_NAME).elf tag $(PROCESSOR_NAME) -o b $(BITSTREAM).bit
	@echo Finished generating: $@
	@echo ' '

${FLASH_IMAGE_NAME_DUAL}.mcs : ${EXECUTABLE}.mem $(BITSTREAM).bit
	@echo Invoking: promgen
	promgen $(PROMGEN_FLAGS) -o ${FLASH_IMAGE_NAME}.mcs $(PROMGEN_TYPE) $(BITSTREAM).bit $(PROMGEN_PREFIX)
	@echo Invoking: pcublaze.pl
	$(PERL) $(BOOTLOADER_PATH)/src/pcublaze.pl $(PCUBLAZE_PARAMS) --memfile ${EXECUTABLE}.mem $(PCUBLAZE_FILES)
	@echo Finished generating: $@
	@echo ' '

.PHONY: prog_flash
prog_flash : gen_flash
	@echo Invoking: Xilinx iMPACT
	impact -batch $(SCRIPT_DIR)/$(PROM_SCRIPT)
	@echo Finished programming: ${FLASH_IMAGE_NAME_DUAL}.mcs
	@echo ' '

.PHONY: clean
clean:
	-@touch $(FLASH_IMAGE_NAME)
	-@touch $(EXECUTABLE)
	-${RM} -rf $(EXECUTABLE).* $(OBJ) $(OBJD) ${FLASH_IMAGE_NAME}* $(BITSTREAM).bit
	-$(MAKE) -C $(BOOTLOADER_PATH) clean
	-$(MAKE) -C $(LIBCNAPI_BUILD_DIR) clean
	-@echo ' '
else
#######################################
# two processors are in one bitstream! (Disable burning to flash!)
.PHONY: clean
clean:
	-@touch $(FLASH_IMAGE_NAME)
	-@touch $(EXECUTABLE)
	-${RM} -rf $(EXECUTABLE).* $(OBJ) $(OBJD) ${FLASH_IMAGE_NAME}* $(BITSTREAM).bit
	-$(MAKE) -C $(LIBCNAPI_BUILD_DIR) clean
	-@echo ' '
endif

-include $(OBJD)
