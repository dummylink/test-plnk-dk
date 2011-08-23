################################################################################
# Makefile for creating openPOWERLINK Slave Development Toolkit altera tools
################################################################################
CC=gcc

INCLUDES=-I ../../powerlink/include -I ../../libCnApi/include

#CFLAGS=-O0 -g -Wall $(INCLUDES)
CFLAGS=-O2 -Wall $(INCLUDES)

# mkfirmware
MKFIRMWARE_OBJS=mkfirmware.o crc32.o  


all:	mkfirmware

mkfirmware: $(MKFIRMWARE_OBJS)
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS) $(LIBS)


# cleanup
.PHONY: clean
clean:
	rm -f $(MKFIRMWARE_OBJS) mkfirmware mkfirmware.exe