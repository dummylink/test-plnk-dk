// file: boot_loader.h
// asmsyntax=nios2
//
// Copyright 2003-2004 Altera Corporation, San Jose, California, USA.
// All rights reserved.
//
// Register definitions for the boot loader code

// Symbolic definitions for how registers are used in this program
// program

// 2011-01-18	Zelenka Joerg (B&R)
//  Added remote update (factory and user image) support

// 2011-12-06	Zelenka Joerg (B&R)
//	Added memory set to initialize any memory to zeros

// 2011-12-21	Zelenka Joerg (B&R)
//  Added define for image boot address

//If no remote update controller is present in your sopc,
// undefine REMOTE_UPDATE_BASE. This will load the factory image only (as desired).
#ifndef REMOTE_UPDATE_BASE
#define REMOTE_UPDATE_BASE          0x800 //added by Zelenka Joerg (B&R) 2011-01-18
#endif
#ifndef USER_IMAGE_BOOT_BASE
#define USER_IMAGE_BOOT_BASE        0x20000 //added by Zelenka Joerg (B&R) 2011-12-21
#endif

#ifndef MEM_SET_ZERO_ENABLE
//undefine the following line to disable memory set at bootloader start
#define MEM_SET_ZERO_ENABLE
#define MEM_SET_ZERO_BASE           0x200000 //set here the base address of your memory to be set to zero
#define MEM_SET_ZERO_SPAN           1048576 //set here the span of your memory to be set to zero
#endif // ndef MEM_SET_ZERO_ENABLE

#define r_zero                      r0
#define r_asm_tmp                   r1

#define r_flash_ptr                 r2
#define r_data_size                 r3
#define r_dest                      r4

#define r_halt_record               r5

#define r_read_int_return_value     r6
#define r_riff_count                r7
#define r_riff_return_address       r8
#define rf_temp                     r9

#define r_read_byte_return_value    r10

#define r_epcs_tx_value             r11

#define r_eopen_eclose_tmp          r12

#define r_findp_return_address      r13
#define r_findp_temp                r14
#define r_findp_pattern             r15
#define r_findp_count               r16

#define r_revbyte_mask              r17

#define r_epcs_base_address         r18

#define r_flush_counter             r19

#define r_trie_count                r20

#define r_remote_base_address       r21 //added by Zelenka Joerg (B&R) 2011-01-18
#define r_image_base                r22 //added by Zelenka Joerg (B&R) 2011-01-18

#define r_mem_pointer               r21 //added by Zelenka Joerg (B&R) 2011-12-06
#define r_mem_high_address          r22 //added by Zelenka Joerg (B&R) 2011-12-06

#define return_address_less_4       r23


// end of file
