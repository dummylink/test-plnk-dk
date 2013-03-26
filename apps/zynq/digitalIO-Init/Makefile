################################################################################
# Project		: digitalIO_init (Zynq)
# Module		: build system
# Autor			: abhiramb
# Date			: 26-03-2013
# File			: Makefile
# contents		: Handles the build for digital IO setup
################################################################################
#Version		Autor		Date			Feature
#V0.1			abhiramb	23.03.2013		Makefile for digitalIO setup
################################################################################
VERSION = 0.1

include makefile.settings

##############################
#generic compiler defines

CC=arm-xilinx-eabi-gcc
SIZE=arm-xilinx-eabi-size
PROC=ARM_xilinx
CP=cp
RM=rm
SRCFILES=main.c

MODULE=digitalIO-Init
LSSCRIPT=lscript_$(MODULE).ld
CFLAGS=$(DEBUG_FLAG) -Wall -fmessage-length=0 $(PROC_FEATURES_ARM)
LDFLAGS=-Wl,-T -Wl,${LSSCRIPT} -Wl,-Map,${MODULE}.map
OBJS=$(patsubst %.c, %.o, $(SRCFILES))


##############################
#includes
INCLUDES=-I$(BSP_PATH)/$(PROCESSOR_NAME)/include

##############################
#libraries
LIBSPATH=-L${BSP_PATH}/${PROCESSOR_NAME}/lib
LIBS=-Wl,--start-group,-lxil,-lc -W1,--end-group

##############################
.PHONY: header
header:
	@echo ""
	@echo "================================================================================"
	@echo " 		$(MODULE) build system"
	@echo "================================================================================"
	@echo " 		Copyright (c) 2012 B&R"
	@echo " 		Version $(VERSION)"
	@echo "================================================================================"
	@echo "		Write 'make all' to build the example"
	@echo "		Write 'make clean' to remove all generated files"
	@echo "		Change 'makefile.setting' to configure build system"		
	@echo "================================================================================"
	


.PHONY:	all
all: header $(MODULE).elf

.PHONY: $(MODULE).elf
$(MODULE).elf: $(OBJS)
	@echo Building target: $@
	@echo Invoking: $(PROC) gcc linker
	$(CC) $(LDFLAGS) $(LIBSPATH) $(LIBS) -o $@ $<
	@echo Finished building target: $@
	@echo ' '
	
%.o: %.c
	@echo Building file: $<
	@echo Invoking: $(PROC) gcc compiler
	$(CC) -c $(INCLUDES) $(CFLAGS) $(CPPFLAGS) $<
	@echo Finished buidling $<
	@echo ' '

.PHONY: clean
clean:
	@$(RM) -rf $(MODULE).* *.o *.map