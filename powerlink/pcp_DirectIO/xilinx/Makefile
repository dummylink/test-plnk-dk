################################################################################
# Project		: CNDK DirectIO (Xilinx)
# Module		: build system
# Autor			: mairt
# Date			: 13.02.2012
# File			: Makefile
# contents		: Controls the build of the CNDK software
################################################################################

VERSION = 0.2

include makefile.settings

##################################
# Directory structure
POWERLINK_DIR=${CNDK_DIR}/powerlink/generic/openPOWERLINK_CNDKPatched
APP_DIR=${CNDK_DIR}/powerlink/pcp_DirectIO
OBJDICT_DIR=${CNDK_DIR}/objDicts/Direct_IO
EDRV_DIR=${CNDK_DIR}/powerlink/generic/POWERLINK_IP_Edrv
CNDK_TARGET_DIR=${CNDK_DIR}/powerlink/target/xilinx_microblaze
PCP_COMMON_DIR=${CNDK_DIR}/powerlink/common
CN_API_DIR=${CNDK_DIR}/libCnApi
TOOLS_PATH=${CNDK_DIR}/tools/xilinx

BOOTLOADER_PATH=$(TOOLS_PATH)/mem_bootloader
SCRIPT_DIR=$(TOOLS_PATH)/scripts

OBJDIR=obj

##################################
#general compile defines
CC=mb-gcc
AR=mb-ar
CP=cp
RM=rm
PERL=xilperl
EXECUTABLE=directIO

LSSCRIPT=lscript_$(BOARD_NAME)_$(BUS_INTERFACE).ld
MACROS=-DMAKE_BUILD_PCP -D${DBG_MODE} -DDEF_DEBUG_LVL=${DEF_DEBUG_LVL}
CFLAGS=$(DEBUG_FLAG) -Wall -fmessage-length=0 $(PROC_FEATURES)  ${MACROS}
CPPFLAGS=-MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"
LDFLAGS=-Wl,-T -Wl,${LSSCRIPT} $(PROC_FEATURES) -Wl,-Map,${EXECUTABLE}.map

##################################
# Specific for Zynq to enable prints
ifeq ($(BOARD_NAME),zynq)
	MACROS+= -D__ZYNQ__
endif

# Flash defines
FLASH_IMAGE_NAME= flash_image
BOOTLOADER_NAME= mem_bootloader
BOOT_BUILD_DIR= build
OBJCPYFLAGS=-O srec
BITSTREAM= download


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
-I${PCP_COMMON_DIR}/inc \
-I${BSP_PATH}/${PROCESSOR_NAME}/include \
-I${CNDK_TARGET_DIR}/include \

##################################
# Source files
SRCFILES=${APP_DIR}/main.c \
${OBJDICT_DIR}/Objdict.c \
${EDRV_DIR}/openmac/source/EdrvOpenMac.c \
${EDRV_DIR}/openmac/source/EplTimerSynck_OpenMac.c \
${EDRV_DIR}/openmac/source/EplTgtTimeStamp_OpenMac.c \
${EDRV_DIR}/openmac/source/omethlib_phycfg_generic.c \
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
${PCP_COMMON_DIR}/src/EplObduDefAcc.c \
${PCP_COMMON_DIR}/src/EplObduDefAccHstry.c \
${CNDK_TARGET_DIR}/src/fpgaCfg.c \
${CNDK_TARGET_DIR}/src/fwUpdate.c \
${CNDK_TARGET_DIR}/src/fwBoot.c \
${CNDK_TARGET_DIR}/src/systemComponents.c

VPATH=$(sort $(patsubst " ", :, $(dir $(SRCFILES))))

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
ifeq ($(BOARD_NAME),lx150t)
	FLASH_IMAGE_NAME_DUAL= flash_image_1
	PROM_SCRIPT= program_prom_lx150t.cmd
	PROMGEN_FLAGS= -w -p mcs -c FF
	PROMGEN_TYPE= -x xcf08p xcf32p -u 00000000
	PROMGEN_PREFIX=
	PCUBLAZE_PARAMS= --format bin
	PCUBLAZE_FILES= --outfile ${FLASH_IMAGE_NAME}_sw.bin
endif
ifeq ($(BOARD_NAME),lx9)
	FLASH_IMAGE_NAME_DUAL= flash_image
	PROM_SCRIPT= program_prom_lx9.cmd
	PROMGEN_FLAGS= -w -p mcs -c FF
	PROMGEN_TYPE= -s 16384 -u 0000
	PROMGEN_PREFIX= -spi
	PCUBLAZE_PARAMS= --format mcs --swap off
	PCUBLAZE_FILES= --promfile ${FLASH_IMAGE_NAME_DUAL}.mcs --outfile ${FLASH_IMAGE_NAME_DUAL}.mcs	
endif


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
# Virtual Ethernet
ifeq ($(VIRT_ETH),yes)
	SRCFILES+= ${POWERLINK_DIR}/EplStack/VirtualEthernetNoOs.c
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

.PHONY:	header
header:
	@echo ""
	@echo "================================================================================"
	@echo " Direct IO - Build System (Xilinx)"
	@echo "================================================================================"
	@echo ""
	@echo " Copyright (c) 2012 B&R"
	@echo " Version $(VERSION)"
	@echo "================================================================================"
	@echo ""
	@echo "Write 'make all' to build the Direct I/O software example"
	@echo "Write 'make gen_flash' to generate the .mcs flash image"
	@echo "Write 'make prog_flash' to program the .mcs flash image to flash"
	@echo ""
	@echo "Write 'make clean' to remove all generated files"
	@echo ""
	@echo "Change 'makefile.setting' to configure the build system"

all: buildapp

.PHONY: buildapp
buildapp: builddir ${EXECUTABLE}.elf ${EXECUTABLE}.size ${EXECUTABLE}.elfcheck  ${EXECUTABLE}.mem

.PHONY: builddir
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

${EXECUTABLE}.elf: ${OBJ} ${LSSCRIPT}
	@echo Building target: $@
	@echo Invoking: MicroBlaze gcc linker
	$(CC) $(LDFLAGS) ${LIBSPATH} ${OBJ} -o ${EXECUTABLE}.elf
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

${EXECUTABLE}.srec: ${EXECUTABLE}.elf
	@echo Invoking: mb-objcopy
	mb-objcopy $(OBJCPYFLAGS) ${EXECUTABLE}.elf ${EXECUTABLE}.srec
	@echo Finished building: $@
	@echo ' '

${EXECUTABLE}.mem: ${EXECUTABLE}.elf
	@echo Invoking: Data2MEM
	data2mem -bd ${EXECUTABLE}.elf -d -o m ${EXECUTABLE}.mem
	@echo Finished building: $@
	@echo ' '

###################################
# flash rules

.PHONY: gen_flash
gen_flash : buildapp ${FLASH_IMAGE_NAME_DUAL}.mcs

$(BOOTLOADER_PATH)/$(BOOT_BUILD_DIR)/$(BOOTLOADER_NAME).elf : $(BOOTLOADER_PATH)/Makefile
	@echo Invoking: bootloader build system
	$(MAKE) -C $(BOOTLOADER_PATH) all BSP_PATH="../$(BSP_PATH)" HW_PLATFORM_PATH="../$(HW_PLATFORM_PATH)" \
	BOARD_NAME="$(BOARD_NAME)" BUS_INTERFACE="$(BUS_INTERFACE)" PROC_FEATURES="$(PROC_FEATURES)" \
	PROCESSOR_NAME="$(PROCESSOR_NAME)" APP_MODE=directIO
	@echo Finished generating: $@
	@echo ' '

$(BITSTREAM).bit : ${HW_PLATFORM_PATH}/system.bit $(BOOTLOADER_PATH)/$(BOOT_BUILD_DIR)/$(BOOTLOADER_NAME).elf
	@echo Invoking: elfcheck
	elfcheck -hw ${HW_PLATFORM_PATH}/system.xml -mode bootload -mem BRAM -pe \
	$(PROCESSOR_NAME) $(BOOTLOADER_PATH)/$(BOOT_BUILD_DIR)/$(BOOTLOADER_NAME).elf
	@echo Invoking: data2mem
	data2mem -bm ${HW_PLATFORM_PATH}/system_bd.bmm -bt ${HW_PLATFORM_PATH}/system.bit \
	-bd $(BOOTLOADER_PATH)/$(BOOT_BUILD_DIR)/$(BOOTLOADER_NAME).elf tag $(PROCESSOR_NAME) -o b $(BITSTREAM).bit
	@echo Finished generating: $@
	@echo ' '

${FLASH_IMAGE_NAME_DUAL}.mcs : ${EXECUTABLE}.mem $(BITSTREAM).bit
	@echo Invoking: promgen
	promgen $(PROMGEN_FLAGS) -o ${FLASH_IMAGE_NAME}.mcs $(PROMGEN_TYPE) download.bit $(PROMGEN_PREFIX)
	@echo Invoking: pcublaze.pl
	$(PERL) $(SCRIPT_DIR)/pcublaze.pl $(PCUBLAZE_PARAMS) --memfile ${EXECUTABLE}.mem $(PCUBLAZE_FILES)
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
	-@echo ' '

-include $(OBJD)

