/* extended epcs commands file, based on altera epcs HAL driver */


#include "alt_types.h"

#define epcs_read    0x03
#define epcs_pp      0x02
#define epcs_wren    0x06
#define epcs_wrdi    0x04
#define epcs_rdsr    0x05
#define epcs_wrsr    0x01
#define epcs_se      0xD8
#define epcs_be      0xC7
#define epcs_dp      0xB9
#define epcs_res     0xAB
#define epcs_rdid    0x9F

alt_u8 epcs_read_device_id(alt_u32 base);
alt_u8 epcs_read_electronic_signature(alt_u32 base);
alt_u8 epcs_read_status_register(alt_u32 base);
int epcs_sector_erase(alt_u32 base, alt_u32 offset);
alt_32 epcs_read_buffer(alt_u32 base, int offset, alt_u8 *dest_addr, int length);
void epcs_write_enable(alt_u32 base);
void epcs_write_status_register(alt_u32 base, alt_u8 value);
alt_32 epcs_write_buffer(alt_u32 base, int offset, const alt_u8 *src_addr, int length);



