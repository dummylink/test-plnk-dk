//-----------------------------------------------------------------
//  OD for a Digital I/O CN with 3 RPDO and 1 TPDO mappings
//-----------------------------------------------------------------

#define EPL_OBD_DEFINE_MACRO
    #include "EplObdMacro.h"
#undef EPL_OBD_DEFINE_MACRO

EPL_OBD_BEGIN ()

    EPL_OBD_BEGIN_PART_GENERIC ()

        #include "Generic/objdict_1000-13ff.h"


        // Object 1400h: PDO_RxCommParam_00h_REC
        EPL_OBD_BEGIN_INDEX_RAM(0x1400, 0x03, EplPdouCbObdAccess)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1400, 0x00, kEplObdTypUInt8, kEplObdAccConst, tEplObdUnsigned8, NumberOfEntries, 0x02)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1400, 0x01, kEplObdTypUInt8, kEplObdAccRW, tEplObdUnsigned8, NodeID_U8, 0x00) // Preq from MN
            EPL_OBD_SUBINDEX_RAM_VAR(0x1400, 0x02, kEplObdTypUInt8, kEplObdAccRW, tEplObdUnsigned8, MappingVersion_U8, 0x00)
        EPL_OBD_END_INDEX(0x1400)

        // Object 1401h: PDO_RxCommParam_01h_REC
        EPL_OBD_BEGIN_INDEX_RAM(0x1401, 0x03, EplPdouCbObdAccess)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1401, 0x00, kEplObdTypUInt8, kEplObdAccConst, tEplObdUnsigned8, NumberOfEntries, 0x02)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1401, 0x01, kEplObdTypUInt8, kEplObdAccRW, tEplObdUnsigned8, NodeID_U8, 0xF0) // MN Pres
            EPL_OBD_SUBINDEX_RAM_VAR(0x1401, 0x02, kEplObdTypUInt8, kEplObdAccRW, tEplObdUnsigned8, MappingVersion_U8, 0x00)
        EPL_OBD_END_INDEX(0x1401)

        // Object 1402h: PDO_RxCommParam_02h_REC
        EPL_OBD_BEGIN_INDEX_RAM(0x1402, 0x03, EplPdouCbObdAccess)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1402, 0x00, kEplObdTypUInt8, kEplObdAccConst, tEplObdUnsigned8, NumberOfEntries, 0x02)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1402, 0x01, kEplObdTypUInt8, kEplObdAccRW, tEplObdUnsigned8, NodeID_U8, 0x04) // Pres CN 4
            EPL_OBD_SUBINDEX_RAM_VAR(0x1402, 0x02, kEplObdTypUInt8, kEplObdAccRW, tEplObdUnsigned8, MappingVersion_U8, 0x00)
        EPL_OBD_END_INDEX(0x1402)


        // Object 1600h: PDO_RxMappParam_00h_AU64
        EPL_OBD_BEGIN_INDEX_RAM(0x1600, 0x1A, EplPdouCbObdAccess)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x00, kEplObdTypUInt8, kEplObdAccRW, tEplObdUnsigned8, NumberOfEntries, 0x00)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x01, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x02, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x03, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x04, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x05, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x06, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x07, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x08, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x09, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x0A, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x0B, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x0C, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x0D, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x0E, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x0F, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x10, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x11, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x12, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x13, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x14, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x15, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x16, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x17, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x18, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1600, 0x19, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
        EPL_OBD_END_INDEX(0x1600)

        // Object 1601h: PDO_RxMappParam_01h_AU64
        EPL_OBD_BEGIN_INDEX_RAM(0x1601, 0x1A, EplPdouCbObdAccess)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x00, kEplObdTypUInt8, kEplObdAccRW, tEplObdUnsigned8, NumberOfEntries, 0x0)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x01, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x02, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x03, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x04, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x05, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x06, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x07, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x08, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x09, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x0A, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x0B, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x0C, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x0D, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x0E, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x0F, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x10, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x11, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x12, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x13, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x14, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x15, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x16, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x17, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x18, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1601, 0x19, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
        EPL_OBD_END_INDEX(0x1601)

        // Object 1602h: PDO_RxMappParam_02h_AU64
        EPL_OBD_BEGIN_INDEX_RAM(0x1602, 0x1A, EplPdouCbObdAccess)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x00, kEplObdTypUInt8, kEplObdAccRW, tEplObdUnsigned8, NumberOfEntries, 0x00)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x01, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x02, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x03, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x04, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x05, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x06, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x07, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x08, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x09, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x0A, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x0B, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x0C, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x0D, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x0E, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x0F, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x10, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x11, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x12, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x13, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x14, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x15, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x16, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x17, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x18, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1602, 0x19, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
        EPL_OBD_END_INDEX(0x1602)


        // Object 1800h: PDO_TxCommParam_00h_REC
        EPL_OBD_BEGIN_INDEX_RAM(0x1800, 0x03, EplPdouCbObdAccess)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1800, 0x00, kEplObdTypUInt8, kEplObdAccConst, tEplObdUnsigned8, NumberOfEntries, 0x02)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1800, 0x01, kEplObdTypUInt8, kEplObdAccRW, tEplObdUnsigned8, NodeID_U8, 0x00)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1800, 0x02, kEplObdTypUInt8, kEplObdAccRW, tEplObdUnsigned8, MappingVersion_U8, 0x00)
        EPL_OBD_END_INDEX(0x1800)


        // Object 1A00h: PDO_TxMappParam_00h_AU64
        EPL_OBD_BEGIN_INDEX_RAM(0x1A00, 0x1B, EplPdouCbObdAccess)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x00, kEplObdTypUInt8, kEplObdAccRW, tEplObdUnsigned8, NumberOfEntries, 0x0)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x01, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x02, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x03, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x04, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x05, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x06, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x07, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x08, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x09, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x0A, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x0B, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x0C, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x0D, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x0E, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x0F, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x10, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x11, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x12, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x13, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x14, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x15, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x16, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x17, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x18, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x19, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x1A00, 0x1A, kEplObdTypUInt64, kEplObdAccRW, tEplObdUnsigned64, ObjectMapping, 0x00LL)
        EPL_OBD_END_INDEX(0x1A00)


        #include "Generic/objdict_1b00-1fff.h"

    EPL_OBD_END_PART ()

/*
    EPL_OBD_BEGIN_PART_MANUFACTURER ()

        // output (to network) variables
        EPL_OBD_RAM_INDEX_RAM_VARARRAY (0x2000, 17, NULL, kEplObdTypUInt8, kEplObdAccVPR, tEplObdUnsigned8, Sendbx, 0x00)
        EPL_OBD_RAM_INDEX_RAM_VARARRAY (0x2001, 8, NULL, kEplObdTypUInt32, kEplObdAccVPR, tEplObdUnsigned32, Senddwx, 0x00)
        
        EPL_OBD_BEGIN_INDEX_RAM(0x2100, 0x01, NULL)
            EPL_OBD_SUBINDEX_RAM_DOMAIN(0x2100,0x00,kEplObdAccRW,TEST_DOMAIN)
        EPL_OBD_END_INDEX(0x2100)

        // input (from network) variables
        EPL_OBD_RAM_INDEX_RAM_VARARRAY (0x2200, 15, NULL, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, Receivebx, 0x00)
        EPL_OBD_RAM_INDEX_RAM_VARARRAY (0x2201, 8, NULL, kEplObdTypUInt32, kEplObdAccVPRW, tEplObdUnsigned32, Receivedwx, 0x00)

    EPL_OBD_END_PART ()
*/

    EPL_OBD_BEGIN_PART_DEVICE ()

        // Read input 8-bit
        EPL_OBD_BEGIN_INDEX_RAM(0x6000, 0x05, NULL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x6000, 0x00, kEplObdTypUInt8, kEplObdAccConst, tEplObdUnsigned8, number_of_entries, 0x4)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6000, 0x01, kEplObdTypUInt8, kEplObdAccVPR, tEplObdUnsigned8, digitalIn1, 0x0)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6000, 0x02, kEplObdTypUInt8, kEplObdAccVPR, tEplObdUnsigned8, digitalIn2, 0x0)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6000, 0x03, kEplObdTypUInt8, kEplObdAccVPR, tEplObdUnsigned8, digitalIn3, 0x0)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6000, 0x04, kEplObdTypUInt8, kEplObdAccVPR, tEplObdUnsigned8, digitalIn4, 0x0)
        EPL_OBD_END_INDEX(0x6000)

        // Write output 8-bit
        EPL_OBD_BEGIN_INDEX_RAM(0x6200, 0x05, NULL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x6200, 0x00, kEplObdTypUInt8, kEplObdAccConst, tEplObdUnsigned8, number_of_entries, 0x4)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6200, 0x01, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, digitalOut1, 0x0)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6200, 0x02, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, digitalOut2, 0x0)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6200, 0x03, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, digitalOut3, 0x0)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6200, 0x04, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, digitalOut4, 0x0)
        EPL_OBD_END_INDEX(0x6200)

		 // Write output 8-bit
        EPL_OBD_BEGIN_INDEX_RAM(0x6300, 0x05, NULL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x6300, 0x00, kEplObdTypUInt8, kEplObdAccConst, tEplObdUnsigned8, number_of_entries, 0x4)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6300, 0x01, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, digitalOut1, 0x0)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6300, 0x02, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, digitalOut2, 0x0)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6300, 0x03, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, digitalOut3, 0x0)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6300, 0x04, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, digitalOut4, 0x0)
        EPL_OBD_END_INDEX(0x6300)

		 // Write output 8-bit
        EPL_OBD_BEGIN_INDEX_RAM(0x6400, 0x05, NULL)
            EPL_OBD_SUBINDEX_RAM_VAR(0x6400, 0x00, kEplObdTypUInt8, kEplObdAccConst, tEplObdUnsigned8, number_of_entries, 0x4)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6400, 0x01, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, digitalOut1, 0x0)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6400, 0x02, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, digitalOut2, 0x0)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6400, 0x03, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, digitalOut3, 0x0)
            EPL_OBD_SUBINDEX_RAM_USERDEF(0x6400, 0x04, kEplObdTypUInt8, kEplObdAccVPRW, tEplObdUnsigned8, digitalOut4, 0x0)
        EPL_OBD_END_INDEX(0x6400)

    EPL_OBD_END_PART ()

EPL_OBD_END ()


#define EPL_OBD_UNDEFINE_MACRO
    #include "EplObdMacro.h"
#undef EPL_OBD_UNDEFINE_MACRO

