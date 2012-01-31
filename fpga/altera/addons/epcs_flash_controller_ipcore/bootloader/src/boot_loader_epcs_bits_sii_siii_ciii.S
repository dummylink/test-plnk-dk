// file: boot_loader_epcs_bits_sii_siii_ciii.S
// asmsyntax=nios2
//
// Copyright 2009 Altera Corporation, San Jose, California, USA.
// All rights reserved.
//
// Refactored by jrk, 2006.01.26
// - Cyclone III/Stratix II GX added 2007.08.15
//
// - FPGA device-family-specific code moved to separate sources.
//
// - This file contains EPCS boot routines specific to the Stratix II, II GX, 
//   III, IV, IV GX, Arria GX, Arria II GX, and x II, and Cyclone III device 
//   families only; support for other device families is provided in separate 
//   sources, so that separate (and thus small) boot loader executables will 
//   be built.
//
// Refactored by dyum, 2008.03.06
// Adding Stratix III support
//
// Updated by dyum, 2008.03.25
// Adding ArriaGX support
//
// Updated by jkempa 2009.08.14:
// Adding Stratix IV & Arria II GX support
//
// 2011-01-18	Zelenka Joerg (B&R)
//  Added remote update (factory and user image) support
// 2011-12-21	Zelenka Joerg (B&R)
//	Bugfix, bootaddr not available in user mode

#include "boot_loader.h"

    .global sub_find_payload_epcs

// |
// | Let the code begin
// |

    .text

// |
// | Find_Payload for EPCS (Arria GX/Stratix II/Stratix III/Cyclone III 
// | edition):
// |
// | The process:
// |  0) Open the remote update core if present and get the boot
// |     image base address. If not remote update core is present
// |     the image base address is zero (REMOTE_UPDATE_BASE not
// |     defined).
// |
// |  1) Open the EPCS at zero (where device-config lives)
// |
// |  2) We see a byte other than 0xFF, prior to where non-0xFF FPGA
// |     configuration data is expected (byte[32]), in which case we're
// |     not looking at a device configuration. Instead we assume we must
// |     be looking at a boot loader record. Skip the whole "length
// |     of the configuration" calculation, and start loading.
// |
// |  3) If a boot loader record isn't found, we assume* that we're examining
// |     an FPGA bitstream targeting a Stratix II/III/IV/IV GX, Arria GX, 
// |     Arria II GX, or Cyclone III device. Extract the precise FPGA 
// |     configuration length. Close/re-open the EPCS device after the 
// |     FPGA configuration before returning to load software.
// |     
// |     * One exception is if the extracted length is all "1" -- in this 
// |       case we can safely assume that we're reading erased flash, and not
// |       FPGA bitstream. Instead of jumping to a high address, the boot 
// |       loader will hang.
// | 
// | A note about nomenclature in this code's documentation: data[N] refers to
// | Nth unit of data, assuming that you start counting at zero.
// |

sub_find_payload_epcs:
    // Fix-up and save return-address
    addi    r_findp_return_address, return_address_less_4, 4

  //
  // Compute the address of the EPCS control/status register block.
  //
  // This is 1024 bytes from the very *start* of this program, for this
  // edition of the boot loader. On Cyclone I/II its 512 bytes. 
  //
  // | dvb adds: Since the code must be aligned on a 1024-byte
  // | boundary, we simply take our current address, and round up
  // | to the next 1024-byte boundary.
  //
  // | for debugging purposes, you may define EPCS_REGS_BASE
  // | to be the epcs registers base. Otherwise, it is presumed
  // | to be the first 1024-byte-boundary after this very code/
  //
    nextpc  r_findp_temp

#ifdef EPCS_REGS_BASE
    movhi   r_epcs_base_address, %hi(EPCS_REGS_BASE)
    addi    r_epcs_base_address, r_epcs_base_address, %lo(EPCS_REGS_BASE)
#else
    ori     r_epcs_base_address, r_findp_temp, 1023
    addi    r_epcs_base_address, r_epcs_base_address, 1
#endif

//vvvv added by Zelenka Joerg (B&R) 2011-01-18
#ifdef REMOTE_UPDATE_BASE
    //
    // 0) Open Remote Update Core to get image address
    //
    movhi   r_remote_base_address, %hi(REMOTE_UPDATE_BASE)
    addi    r_remote_base_address, r_remote_base_address, %lo(REMOTE_UPDATE_BASE)

    // obtain current mode (factory or user?) (read_source = 0b00 and param = 0b000)
    ldwio   r_image_base, (0x00*4)(r_remote_base_address)
    andi    r_image_base, r_image_base, 1

    beq     r_image_base, r_zero, load_factory_image
load_user_image:
    // so, we are in user mode => use the defined boot address
    movhi   r_image_base, %hi(USER_IMAGE_BOOT_BASE)
    addi    r_image_base, r_image_base, %lo(USER_IMAGE_BOOT_BASE)
    br      set_flash_pointer
#endif

load_factory_image:
    mov     r_image_base, r_zero
set_flash_pointer:
//^^^^ added by Zelenka Joerg (B&R) 2011-01-18

    //
    // 1) Open EPCS-device at flash-offset.
    //
    mov     r_flash_ptr, r_image_base //added by Zelenka Joerg (B&R) 2011-01-18
    nextpc  return_address_less_4
    br      sub_epcs_open_address

    //
    // 2) Attempt to find software boot record
    //

    // Search until we expect configuration data to start
    movi    r_findp_count, 32

    // What we'll accept until we see the pattern
    movi    r_findp_temp, 0xFF

fp_look_for_software_boot_record:
    nextpc  return_address_less_4
    br      sub_read_byte_from_flash_epcs

    // Did we see something other than an 0xFF?
    bne     r_read_byte_return_value, r_findp_temp, fp_short_circuit

    // Update the loop counter, and loop
    subi    r_findp_count, r_findp_count, 1
    bne     r_findp_count, r_zero, fp_look_for_software_boot_record

    // 
    // 3) If we arrive at this point we have assume that there is valid-looking
    // configuration data. Extract its length. If the extracted length is all 
    // "1", assume that we're looking at erased flash. In this case, we have
    // no other recourse than to hang.
    //
    // The configuration bitstream length is encoded in a particular bit of a 
    // run of bytes. Total length field is 32 bits, which goes from CB Option 
    // bits 86..55 corresponding to bit[3] of  byte[39] to byte[33] (for the most 
    // significant 7 bits) followed by the range of bits made up of bit[2] of 
    // bytes[72..48]. 
    // 
    // The note about EPCS bit reversal still applies (so we're really looking 
    // at bits[4] and [5], respectively.
    //

    // First, loop through bits in bytes [48..72] - LSB of the length first
    // Number of bytes we'll traverse to get the length
    movi    r_findp_count, 25

    // Clear the register we'll construct the length into
    movi    r_findp_temp, 0

    // Close & re-open EPCS where we will start extracting the length
    movi    r_flash_ptr, 48
    add     r_flash_ptr, r_flash_ptr, r_image_base //added by Zelenka Joerg (B&R) 2011-01-18

    nextpc  return_address_less_4
    br      sub_epcs_close
    nextpc  return_address_less_4
    br      sub_epcs_open_address

fp_assemble_configuration_length:
    // Read sequential byte from EPCS
    nextpc  return_address_less_4
    br      sub_read_byte_from_flash_epcs

    // Mask off all but bit[5] as described above
    andi    r_read_byte_return_value, r_read_byte_return_value, 0x20

    // Shift to the MSB position of the value we're constructing
    // (which happens to be 26 bits left of the bit we're working with)
    // (the data we're after is being read LSB first)... this may
    // seem backwards (it is), but the sub_read_byte_from_flash_epcs
    // routine auto increments the EPCS addres for us; thus the cleanest
    // implementation is to load data from sequential addresses, LSB first.
    slli    r_read_byte_return_value, r_read_byte_return_value, 26

    // Shift result register & capture new data into bit[31]
    srli    r_findp_temp, r_findp_temp, 0x1
    or      r_findp_temp, r_findp_temp, r_read_byte_return_value

    // Update loop counter & loop
    subi    r_findp_count, r_findp_count, 1
    bne     r_findp_count, r_zero, fp_assemble_configuration_length

    // We've assembled 25 bits of the length; 7 to go. 
    // We're gonna look at bit[3] of byte[33..39].

    // Number of bytes we'll traverse to get the length
    movi    r_findp_count, 7

    // Close & re-open EPCS at byte 33
    movi    r_flash_ptr, 33
    add     r_flash_ptr, r_flash_ptr, r_image_base //added by Zelenka Joerg (B&R) 2011-01-18
    nextpc  return_address_less_4
    br      sub_epcs_close
    nextpc  return_address_less_4
    br      sub_epcs_open_address

fp_assemble_configuration_length_top_bits:
    // Read sequential bytes from EPCS
    nextpc  return_address_less_4
    br      sub_read_byte_from_flash_epcs

    // Mask off all but bit[4] as described above
    andi    r_read_byte_return_value, r_read_byte_return_value, 0x10
    
    // Shift to the MSB position of the value we're constructing as before
    slli    r_read_byte_return_value, r_read_byte_return_value, 27

    // Shift result register & capture new data into bit[31]
    srli    r_findp_temp, r_findp_temp, 0x1
    or      r_findp_temp, r_findp_temp, r_read_byte_return_value

    // Update loop counter & loop
    subi    r_findp_count, r_findp_count, 1
    bne     r_findp_count, r_zero, fp_assemble_configuration_length_top_bits

    // Put extracted length in the flash pointer
    mov     r_flash_ptr, r_findp_temp
    
    // Sanity check: Did we extract a length that appears to be erased
    // flash? 
    subi     r_findp_temp, r_zero, 1
    beq      r_flash_ptr, r_findp_temp, sub_epcs_hang_forever
    
    //
    // Finally, it turns out the length was given in BITS.  Round-up
    // to the next byte, and convert to bytes
    //
    addi    r_flash_ptr, r_flash_ptr, 7      // r_flash_ptr += 7
    srli    r_flash_ptr, r_flash_ptr, 3      // r_flash_ptr /= 8;
    
    //and add image base
    add     r_flash_ptr, r_flash_ptr, r_image_base //added by Zelenka Joerg (B&R) 2011-01-18

fp_short_circuit:
    // Close the EPCS device
    nextpc  return_address_less_4
    br      sub_epcs_close

    // Open it up again (at r_flash_ptr)
    nextpc  return_address_less_4
    br      sub_epcs_open_address

    // Return; EPCS is now ready for boot-loading business
    jmp     r_findp_return_address

// end of file
