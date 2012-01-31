# file: Makfile
#
# Makefile for building the flash boot copiers
# dvb 2004
#
# Cleaned up, added pattern rules, jrk, 2009
#
# ex:set noexpandtab:

.NOTPARALLEL:
SHELL := /bin/bash

S = @
E = @echo

# EPCS & CFI intermediate object files are separated,
# because common code (in boot_loader.S) is pre-processed
# differently for CFI & EPCS flash. This enables the clean
# use of pattern rules to build the intermediates.
#
# The executables are all uniquely named, though, so these
# can all reside in the traditional $(OBJ)
OBJ = ./obj
OBJ_EPCS = ./obj_epcs

ifeq ("$(S)","@")
 DASH_S = -s
endif


# |
# | The code is fully relocatable. However! You may
# | wish to compile an elf for faux-debugging that
# | claims to be at a particular location (like where
# | your flash or epcs device is). To do this,
# | type "make CODE_BASE=0x<epcs_base>". The assignment
# | here uses it appropriately. dvb2004
# |

ifneq ("$(CODE_BASE)","")
 CODE_BASE_OPT = -Ttext=$(CODE_BASE)
endif

ifneq ("$(EPCS_REGS_BASE)","")
 EPCS_REGS_BASE_OPT = -DEPCS_REGS_BASE=$(EPCS_REGS_BASE)
endif

ifneq ("$(EPCS_SIMULATION_TEST)","")
 EPCS_SIMULATION_TEST_OPT = -DEPCS_SIMULATION_TEST
endif

ifneq ("$(EPCS_SIMULATION_TEST_FLASH_BASE)","")
 EPCS_SIMULATION_TEST_FLASH_BASE_OPT = -DEPCS_SIMULATION_TEST_FLASH_BASE=$(EPCS_SIMULATION_TEST_FLASH_BASE)
 CODE_BASE_OPT += -Tdata=$(EPCS_SIMULATION_TEST_FLASH_BASE)
endif

ifneq ("$(REMOTE_UPDATE_BASE)","")
 REMOTE_UPDATE_BASE_OPT = -DREMOTE_UPDATE_BASE=$(REMOTE_UPDATE_BASE)
else
 REMOTE_UPDATE_BASE_OPT = 
endif

ifneq ("$(USER_IMAGE_BOOT_BASE)","")
 USER_IMAGE_BOOT_BASE_OPT = -DUSER_IMAGE_BOOT_BASE=$(USER_IMAGE_BOOT_BASE)
else
 USER_IMAGE_BOOT_BASE_OPT =
endif

ifneq ("$(MEM_SET_ZERO_BASE)","")
 MEM_SET_ZERO_BASE_OPT = -DMEM_SET_ZERO_BASE=$(MEM_SET_ZERO_BASE) -DMEM_SET_ZERO_ENABLE
ifneq ("$(MEM_SET_ZERO_SPAN)","")
 MEM_SET_ZERO_SPAN_OPT = -DMEM_SET_ZERO_SPAN=$(MEM_SET_ZERO_SPAN)
else
 MEM_SET_ZERO_SPAN_OPT =
endif 
else
 MEM_SET_ZERO_BASE_OPT =
 MEM_SET_ZERO_SPAN_OPT =
endif

EPCS_OPTS = -DEPCS \
            $(EPCS_REGS_BASE_OPT) \
            $(EPCS_SIMULATION_TEST_OPT) \
            $(EPCS_SIMULATION_TEST_FLASH_BASE_OPT) \
            $(REMOTE_UPDATE_BASE_OPT) \
            $(USER_IMAGE_BOOT_BASE_OPT) \
            $(MEM_SET_ZERO_BASE_OPT) \
            $(MEM_SET_ZERO_SPAN_OPT)

SRECS = \
	boot_loader_cfi.srec \
	boot_loader_epcs.srec \
	boot_loader_epcs_sii_siii_ciii.srec \
	boot_loader_cfi_be.srec \
	boot_loader_epcs_be.srec \
	boot_loader_epcs_sii_siii_ciii_be.srec

ALL_TARGS = \
	$(SRECS) \
	$(OBJ)/boot_loader_cfi.elf \
	$(OBJ)/boot_loader_cfi.objdump \
	$(OBJ)/boot_loader_cfi.nm \
	$(OBJ)/boot_loader_epcs.elf \
	$(OBJ)/boot_loader_epcs.objdump \
	$(OBJ)/boot_loader_epcs.nm \
	$(OBJ)/boot_loader_epcs_sii_siii_ciii.elf \
	$(OBJ)/boot_loader_epcs_sii_siii_ciii.objdump \
	$(OBJ)/boot_loader_epcs_sii_siii_ciii.nm \
	$(OBJ)/boot_loader_cfi_be.elf \
	$(OBJ)/boot_loader_cfi_be.objdump \
	$(OBJ)/boot_loader_cfi_be.nm \
	$(OBJ)/boot_loader_epcs_be.elf \
	$(OBJ)/boot_loader_epcs_be.objdump \
	$(OBJ)/boot_loader_epcs_be.nm \
	$(OBJ)/boot_loader_epcs_sii_siii_ciii_be.elf \
	$(OBJ)/boot_loader_epcs_sii_siii_ciii_be.objdump \
	$(OBJ)/boot_loader_epcs_sii_siii_ciii_be.nm

.PHONY: all
all : $(OBJ)
	$(S)$(MAKE) $(DASH_S) S=$(S) xall

.PHONY: xall
xall : $(ALL_TARGS)
	$(E) "Try \"make clean all S=\" to see more detailed spew."
	$(E) Done

.PHONY: clean
clean :
	$(E) Cleaning up
	$(S)rm -vf $(ALL_TARGS)
	$(S)rm -vf $(OBJ)/*.s
	$(S)rm -vf $(OBJ_EPCS)/*.s

.PHONY: install
install : $(SRECS)
ifneq ("$(DEST_PATH)","")
	$(E) Copying $(SRECS)
	$(E) To $(DEST_PATH)
	$(S)cp -f $(SRECS) $(DEST_PATH)
endif

$(OBJ) :
	$(E) Creating $@
	$(S)mkdir -p $@
        
$(OBJ_EPCS) :
	$(E) Creating $@
	$(S)mkdir -p $@

########################
# CFI Flash boot loader
#######################
BOOT_LOADER_CFI_OBJS = \
	$(OBJ)/boot_loader.s \
	$(OBJ)/boot_loader_cfi_bits.s 

$(OBJ)/%.s : %.S $(OBJ)
	$(E) Pre-processing $<
	$(S)nios2-elf-cpp $< -o $@ $(CODE_BASE_OPT)

$(OBJ)/boot_loader_cfi.elf : \
	$(BOOT_LOADER_CFI_OBJS) 
	$(E) Compiling to $@ 
	$(S)nios2-elf-gcc -nostdlib \
		$(BOOT_LOADER_CFI_OBJS) \
		$(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

$(OBJ)/boot_loader_cfi_be.elf : \
	$(BOOT_LOADER_CFI_OBJS) 
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -EB -nostdlib \
		$(BOOT_LOADER_CFI_OBJS) \
		$(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

###################################################
# EPCS Flash boot loader: Cyclone I & Cyclone II
###################################################
$(OBJ_EPCS)/%.s : %.S $(OBJ_EPCS)
	$(E) Pre-processing $<
	$(S)nios2-elf-cpp $< -o $@ $(CODE_BASE_OPT) $(EPCS_OPTS)

BOOT_LOADER_EPCS_CYCLONEI_CYCLONEII_OBJS = \
	$(OBJ_EPCS)/boot_loader.s \
	$(OBJ_EPCS)/boot_loader_epcs_bits.s \
	$(OBJ_EPCS)/boot_loader_epcs_bits_cyclone.s 

# EPCS testing may provide an additional source file for a flash image
ifneq ("$(EPCS_SIMULATION_TEST_FLASH_IMAGE)","")
BOOT_LOADER_EPCS_CYCLONEI_CYCLONEII_OBJS += $(OBJ_EPCS)/$(EPCS_SIMULATION_TEST_FLASH_IMAGE)
endif

$(OBJ)/boot_loader_epcs.elf : \
	$(BOOT_LOADER_EPCS_CYCLONEI_CYCLONEII_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -nostdlib \
		$(BOOT_LOADER_EPCS_CYCLONEI_CYCLONEII_OBJS) \
		$(EPCS_OPTS) $(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

$(OBJ)/boot_loader_epcs_be.elf : \
	$(BOOT_LOADER_EPCS_CYCLONEI_CYCLONEII_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -EB -nostdlib \
		$(BOOT_LOADER_EPCS_CYCLONEI_CYCLONEII_OBJS) \
		$(EPCS_OPTS) $(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

###################################################
# EPCS for Cyclone III, Sratix II-IV, Arria I-II
###################################################             

# Note: pattern rule for EPCS objects was created above
BOOT_LOADER_EPCS_SII_SIII_CIII_OBJS = \
	$(OBJ_EPCS)/boot_loader.s \
	$(OBJ_EPCS)/boot_loader_epcs_bits.s \
	$(OBJ_EPCS)/boot_loader_epcs_bits_sii_siii_ciii.s 

# EPCS testing may provide an additional source file for a flash image
ifneq ("$(EPCS_SIMULATION_TEST_FLASH_IMAGE)","")
BOOT_LOADER_EPCS_SII_SIII_CIII_OBJS += $(OBJ_EPCS)/$(EPCS_SIMULATION_TEST_FLASH_IMAGE)
endif

$(OBJ)/boot_loader_epcs_sii_siii_ciii.elf : \
	$(BOOT_LOADER_EPCS_SII_SIII_CIII_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -nostdlib \
		$(BOOT_LOADER_EPCS_SII_SIII_CIII_OBJS) \
		$(EPCS_OPTS) $(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

$(OBJ)/boot_loader_epcs_sii_siii_ciii_be.elf : \
	$(BOOT_LOADER_EPCS_SII_SIII_CIII_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -EB -nostdlib \
		$(BOOT_LOADER_EPCS_SII_SIII_CIII_OBJS) \
		$(EPCS_OPTS) $(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

###################################################
# Utility & executable file pattern rules
################################################### 
$(OBJ)/%.objdump : $(OBJ)/%.elf $(OBJ)
	$(E) Objdumping $<
	$(S)nios2-elf-objdump -D --source $< > $@

$(OBJ)/%.nm : $(OBJ)/%.elf $(OBJ)
	$(E) Nm-ing $<
	$(S)nios2-elf-nm $< | sort > $@

%.srec : $(OBJ)/%.elf $(OBJ)
	$(E) Creating SREC file $@
	$(S)nios2-elf-objcopy --output-target=srec $< $@

# Print input options
	$(E) Build options: $(EPCS_OPTS)	

.PHONY: help
help :
	@echo .
	@echo . Here is a typical run-from-RAM command
	@echo . make CODE_BASE=0x0000 EPCS_REGS_BASE=0x0400 
	@echo .      REMOTE_UPDATE_BASE=0x800 USER_IMAGE_BOOT_BASE=0x1D0000
	@echo .      MEM_SET_ZERO_BASE=0x200000 MEM_SET_ZERO_SPAN=1048576 MEM_SET_ZERO_ENABLE
	@echo .      clean all
	@echo .
	@echo . "Argument               Description"
	@echo .
	@echo . "CODE_BASE              System address of bootloader storage"
	@echo . "EPCS_REGS_BASE         Start address of EPCS logics"
	@echo . "REMOTE_UPDATE_BASE     System address of remote update core"
	@echo . "                       (for checking its state/mode)"
	@echo . "USER_IMAGE_BOOT_BASE   EPCS flash offset of user image"
	@echo . "MEM_SET_ZERO_BASE      System start address of 0-initialized random memory (e.g. SRAM)"
	@echo . "                       Only enabled, if this define is used"	
	@echo . "MEM_SET_ZERO_SPAN      Span of 0-initialized memory"
	@echo .



# end of file
