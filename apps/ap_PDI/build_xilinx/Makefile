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
TOOLS_PATH=${CNDK_DIR}/tools/xilinx

BOOTLOADER_PATH=$(TOOLS_PATH)/mem_bootloader
PROM_SCRIPT_DIR=$(TOOLS_PATH)/scripts

OBJDIR=obj

##################################
#general compile defines
CC=mb-gcc
AR=mb-ar
CP=cp
RM=rm -rf
EXECUTABLE=ap_pdi
LSSCRIPT=lscript_$(BOARD_NAME)_$(BUS_INTERFACE).ld
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
CNAPILIB=${CN_API_DIR}/target/microblaze_newlib/libCnApi.a
LIBSPATH=-L${BSP_PATH}/${PROCESSOR_NAME}/lib -L${CN_API_DIR}/target/microblaze_newlib

###################################
# objects
OBJ = $(addprefix $(OBJDIR)/,$(notdir $(patsubst %.c, %.o, $(SRCFILES))))
OBJD = $(addprefix $(OBJDIR)/,$(notdir $(patsubst %.c, %.d, $(SRCFILES))))

OUTPUT_OPTION = -o $@

CFLAGS += ${INCLUDES}

.PHONY:	header clean gen_flash prog_flash

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
	@echo "Write 'make gen_flash' to generate the .mcs flash image"
	@echo "Write 'make prog_flash' to program the .mcs flash image to flash"
	@echo ""
	@echo "Change 'makefile.setting' to configure build system"		

all: builddir ${EXECUTABLE}.elf ${EXECUTABLE}.size ${EXECUTABLE}.elfcheck ${EXECUTABLE}.mem

builddir:
	$(shell mkdir $(OBJDIR))

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

${EXECUTABLE}.elf: ${OBJ} ${LSSCRIPT} ${CNAPILIB}
	@echo Building target: $@
	@echo Invoking: MicroBlaze gcc linker
	$(CC) $(LDFLAGS) ${LIBSPATH} ${OBJ} -o ${EXECUTABLE}.elf ${CNAPILIB}
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
gen_flash : builddir ${FLASH_IMAGE_NAME_DUAL}.mcs

$(BOOTLOADER_PATH)/$(BOOT_BUILD_DIR)/$(BOOTLOADER_NAME).elf : $(BOOTLOADER_PATH)/Makefile
	@echo Invoking: bootloader build system
	$(MAKE) -C $(BOOTLOADER_PATH) all APP_DIR=$(subst \,/,$(PWD)) APP_MODE=pdi PROCESSOR=ap
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
	xilperl $(BOOTLOADER_PATH)/src/pcublaze.pl $(PCUBLAZE_PARAMS) --memfile ${EXECUTABLE}.mem $(PCUBLAZE_FILES)
	@echo Finished generating: $@
	@echo ' '

prog_flash : ${FLASH_IMAGE_NAME_DUAL}.mcs
	@echo Invoking: Xilinx iMPACT
	impact -batch $(PROM_SCRIPT_DIR)/$(PROM_SCRIPT)
	@echo Finished programming: ${FLASH_IMAGE_NAME_DUAL}.mcs
	@echo ' '

clean:
	-touch $(FLASH_IMAGE_NAME)
	-touch $(EXECUTABLE)
	-${RM} -rf $(EXECUTABLE).* $(OBJ) $(OBJD) ${FLASH_IMAGE_NAME}* $(BITSTREAM).bit
	-$(MAKE) -C $(BOOTLOADER_PATH) clean APP_DIR=$(subst \,/,$(PWD))
	-@echo ' '
else
#######################################
# two processors are in one bitstream! (Disable burning to flash!)
clean:
	-touch $(FLASH_IMAGE_NAME)
	-touch $(EXECUTABLE)
	-${RM} -rf $(EXECUTABLE).* $(OBJ) $(OBJD) ${FLASH_IMAGE_NAME}* $(BITSTREAM).bit
	-@echo ' '
endif

-include $(OBJD)
