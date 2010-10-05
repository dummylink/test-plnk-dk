<?xml version="1.0" encoding="UTF-8" ?>
<!--
*******************************************************************************
 EPSG - Ethernet POWERLINK Standardization Group
 Working Group Tools - Subgroup of Technical Working Group
*******************************************************************************

 Ethernet POWERLINK XML device description

*******************************************************************************

 File:        00000000_openPOWERLINK_digitalio_CN_3r1tpdo.xdd


*******************************************************************************

 File naming:
 use the form "12345678_MyName.xdd"
               |        |
               |        +_________ unique device MyName within your organization
               +__________________ vendor ID in 8 digit hex

 For more details see:
 [] Ethernet POWERLINK V2.0, XML Device Description, EPSG Draft Standard 1311,
    Version 1.0.0, (c) EPSG (Ethernet POWERLINK Standardisation Group) 2007
 [] Ethernet POWERLINK V2.0, Communication Profile Specification, Draft Standard,
    Version 1.0.0, (c) EPSG (Ethernet POWERLINK Standardisation Group) 2006

*******************************************************************************
-->

<ISO15745ProfileContainer  xmlns="http://www.ethernet-powerlink.org"
                           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                           xsi:schemaLocation="http://www.ethernet-powerlink.org Powerlink_Main.xsd">
  <ISO15745Profile>
    <ProfileHeader>
      <ProfileIdentification>openPOWERLINK_digitalio_CN_3r1tpdo</ProfileIdentification>
      <ProfileRevision>1</ProfileRevision>
      <ProfileName>openPOWERLINK_digitalio_CN_3r1tpdo</ProfileName>

      <ProfileSource/>
      <ProfileClassID>Device</ProfileClassID>
      <ISO15745Reference>
        <ISO15745Part>4</ISO15745Part>
        <ISO15745Edition>1</ISO15745Edition>
        <ProfileTechnology>Powerlink</ProfileTechnology>
      </ISO15745Reference>
    </ProfileHeader>

    <ProfileBody
      xsi:type="ProfileBody_Device_Powerlink"
      fileName="00000000_openPOWERLINK_digitalio_CN_3r1tpdo.xdd"
      fileCreator="SYSTEC electronic GmbH"
      fileCreationDate="2010-04-06"
      fileCreationTime="11:29:00+01:00"
      fileModificationDate="2010-07-28"
      fileModificationTime="11:29:00+01:00"
      fileModifiedBy="Michael Hogger"
      fileVersion="00.01"
      supportedLanguages="en">

      <DeviceIdentity>

        <vendorName>Bernecker_Rainer</vendorName>
        <vendorID>0x00000000</vendorID>
        <productName>openPOWERLINK_digitalio_CN_3r1tpdo</productName>

      </DeviceIdentity>

      <DeviceFunction>

      <capabilities>
          <characteristicsList>

            <characteristic>

              <characteristicName>
                <label lang="en">Test Mappings</label>
              </characteristicName>

              <characteristicContent>
                <label lang="en">3 RPDOs</label>
              </characteristicContent>

              <characteristicContent>
                <label lang="en">1 PDO</label>
              </characteristicContent>
            </characteristic>

            <characteristic>
              <characteristicName>
                <label lang="en">Transfer rate</label>
              </characteristicName>
              <characteristicContent>
                <label lang="en">100 MBit/s</label>
              </characteristicContent>
            </characteristic>

            </characteristicsList>

        </capabilities>

      </DeviceFunction>

    </ProfileBody>
  </ISO15745Profile>
  <ISO15745Profile>
    <ProfileHeader>

      <ProfileIdentification>openPOWERLINK_digitalio_CN_3r1tpdo</ProfileIdentification>
      <ProfileRevision>1</ProfileRevision>
      <ProfileName>openPOWERLINK_digitalio_CN_3r1tpdo</ProfileName>
      <ProfileSource/>
      <ProfileClassID>Device</ProfileClassID>
      <ISO15745Reference>
        <ISO15745Part>4</ISO15745Part>
        <ISO15745Edition>1</ISO15745Edition>
        <ProfileTechnology>Powerlink</ProfileTechnology>
      </ISO15745Reference>
    </ProfileHeader>

    <ProfileBody
      xsi:type="ProfileBody_CommunicationNetwork_Powerlink"
      fileName="00000000_openPOWERLINK_digitalio_CN_3r1tpdo.xdd"
      fileCreator="SYSTEC electronic GmbH"
      fileCreationDate="2010-04-06"
      fileCreationTime="11:29:00+01:00"
      fileModificationDate="2010-07-28"
      fileModificationTime="11:29:00+01:00"
      fileModifiedBy="Michael Hogger"
      fileVersion="00.01"
      supportedLanguages="en">

      <ApplicationLayers>

        <identity>
          <vendorID>0x00000000</vendorID>
          <productID>1083</productID>
          <!--
          <version versionType="HW">1</version>
          <version versionType="FW">1</version>
          <version versionType="SW">1</version>
          -->
        </identity>

        <DataTypeList>
          <defType dataType="0001"><Boolean/></defType>
          <defType dataType="0002"><Integer8/></defType>
          <defType dataType="0003"><Integer16/></defType>
          <defType dataType="0004"><Integer32/></defType>
          <defType dataType="0005"><Unsigned8/></defType>
          <defType dataType="0006"><Unsigned16/></defType>
          <defType dataType="0007"><Unsigned32/></defType>
          <defType dataType="0008"><Real32/></defType>
          <defType dataType="0009"><Visible_String/></defType>
          <defType dataType="0010"><Integer24/></defType>
          <defType dataType="0011"><Real64/></defType>
          <defType dataType="0012"><Integer40/></defType>
          <defType dataType="0013"><Integer48/></defType>
          <defType dataType="0014"><Integer56/></defType>
          <defType dataType="0015"><Integer64/></defType>
          <defType dataType="000A"><Octet_String/></defType>
          <defType dataType="000B"><Unicode_String/></defType>
          <defType dataType="000C"><Time_of_Day/></defType>
          <defType dataType="000D"><Time_Diff/></defType>
          <defType dataType="000F"><Domain/></defType>
          <defType dataType="0016"><Unsigned24/></defType>
          <defType dataType="0018"><Unsigned40/></defType>
          <defType dataType="0019"><Unsigned48/></defType>
          <defType dataType="001A"><Unsigned56/></defType>
          <defType dataType="001B"><Unsigned64/></defType>
          <defType dataType="0401"><MAC_ADDRESS/></defType>
          <defType dataType="0402"><IP_ADDRESS/></defType>
          <defType dataType="0403"><NETTIME/></defType>
        </DataTypeList>

        <!-- The <ObjectList> elements describes the object dictionary of a device -->
        <ObjectList>

          <!-- Attributes of <Object> and <SubObject>

              index: "ABCD" - index as four hex digits

              subIndex: "12" - sub index as two hex digits

              name:   name as string without white spaces

              objectType: POWERLINK object type
                     "7" - VAR
                     "8" - ARRAY
                     "9" - RECORD

              dataType: POWERLINK data type, see <DataTypeList>

              accessType:
                     "const" – read only access; the value is not changing
                     "ro"    – read only access
                     "wo"    – write only access
                     "rw"    – both read and write access

              defaultValue: objects default value
                     "1234"   - decimal
                     "0xABCD" - hexadecimal

              PDOmapping:
                     "no"       - not mapable
                     "default"  - mapped by default
                     "optional" - optionally mapped
                     "TPDO"     - may be mapped into TPDO only
                     "RPDO"     - may be mapped into RPDO only
          -->

          <Object index="6000" name="Digital Input 8 Bit" objectType="8">
            <SubObject subIndex="00" name="Number of elements" objectType="7" dataType="0005" accessType="ro" defaultValue="4" PDOmapping="no" />
            <SubObject subIndex="01" name="Byte 1" objectType="7" dataType="0005" accessType="ro" PDOmapping="TPDO" />
            <SubObject subIndex="02" name="Byte 2" objectType="7" dataType="0005" accessType="ro" PDOmapping="TPDO" />
            <SubObject subIndex="03" name="Byte 3" objectType="7" dataType="0005" accessType="ro" PDOmapping="TPDO" />
            <SubObject subIndex="04" name="Byte 4" objectType="7" dataType="0005" accessType="ro" PDOmapping="TPDO" />
          </Object>
          <Object index="6200" name="Digital Output 8 Bit" objectType="8">
            <SubObject subIndex="00" name="Number of elements" objectType="7" dataType="0005" accessType="ro" defaultValue="4" PDOmapping="no" />
            <SubObject subIndex="01" name="Byte 1" objectType="7" dataType="0005" accessType="rw" defaultValue="0x0" PDOmapping="RPDO" />
            <SubObject subIndex="02" name="Byte 2" objectType="7" dataType="0005" accessType="rw" defaultValue="0x0" PDOmapping="RPDO" />
            <SubObject subIndex="03" name="Byte 3" objectType="7" dataType="0005" accessType="rw" defaultValue="0x0" PDOmapping="RPDO" />
            <SubObject subIndex="04" name="Byte 4" objectType="7" dataType="0005" accessType="rw" defaultValue="0x0" PDOmapping="RPDO" />
          </Object>

          <!-- the following object dictionary entries are mandatory and have to be defined in the XDD file -->
          <Object index="1000" name="NMT_DeviceType_U32" objectType="7" dataType="0007" accessType="const" PDOmapping="no" defaultValue="0x000F0191"/>
          <Object index="1001" name="ERR_ErrorRegister_U8" objectType="7" dataType="0005" accessType="ro" PDOmapping="optional" defaultValue="0"/>
          <Object index="1006" name="NMT_CycleLen_U32" objectType="7" dataType="0007" accessType="rw" PDOmapping="no" defaultValue="0"/>
          <Object index="1008" name="NMT_ManufactDevName_VS" objectType="7" dataType="0009" accessType="const"/>
          <Object index="1009" name="NMT_ManufactHwVers_VS" objectType="7" dataType="0009" accessType="const"/>
          <Object index="100A" name="NMT_ManufactSwVers_VS" objectType="7" dataType="0009" accessType="const"/>
          <Object index="1018" name="NMT_IdentityObject_REC" objectType="9">
            <SubObject subIndex="00" name="NumberOfEntries" objectType="7" dataType="0005" accessType="const" PDOmapping="no" defaultValue="4"/>
            <SubObject subIndex="01" name="VendorId_U32" objectType="7" dataType="0007" accessType="const" PDOmapping="no" defaultValue="0x00"/>
            <SubObject subIndex="02" name="ProductCode_U32" objectType="7" dataType="0007" accessType="const" PDOmapping="no" defaultValue="0x1083"/>
            <SubObject subIndex="03" name="RevisionNo_U32" objectType="7" dataType="0007" accessType="const" PDOmapping="no" defaultValue="0x00010005"/>
            <SubObject subIndex="04" name="SerialNo_U32" objectType="7" dataType="0007" accessType="const"/>
          </Object>
          <Object index="1020" name="CFM_VerifyConfiguration_REC" objectType="9">
            <SubObject subIndex="00" name="NumberOfEntries" objectType="7" dataType="0005" accessType="const" defaultValue="2"/>
            <SubObject subIndex="01" name="ConfDate_U32" objectType="7" dataType="0007" accessType="rw" defaultValue="0"/>
            <SubObject subIndex="02" name="ConfTime_U32" objectType="7" dataType="0007" accessType="rw" defaultValue="0"/>
          </Object>
          <Object index="1030" name="NMT_InterfaceGroup_0h_REC" objectType="9">
            <SubObject subIndex="00" name="NumberOfEntries" objectType="7" dataType="0005" accessType="const" PDOmapping="no" defaultValue="9"/>
            <SubObject subIndex="01" name="InterfaceIndex_U16" objectType="7" dataType="0006" accessType="ro" PDOmapping="no" defaultValue="1"/>
            <SubObject subIndex="02" name="InterfaceDescription_VSTR" objectType="7" dataType="0009" accessType="const" PDOmapping="no" defaultValue="Interface 1"/>
            <SubObject subIndex="03" name="InterfaceType_U8" objectType="7" dataType="0005" accessType="const" PDOmapping="no" defaultValue="6"/>
            <SubObject subIndex="04" name="InterfaceMtu_U16" objectType="7" dataType="0006" accessType="const" PDOmapping="no" defaultValue="1500"/>
            <SubObject subIndex="05" name="InterfacePhysAddress_OSTR" objectType="7" dataType="000A" accessType="const" PDOmapping="no" />
            <SubObject subIndex="06" name="InterfaceName_VSTR" objectType="7" dataType="0009" accessType="ro" PDOmapping="no" defaultValue="Interface 1"/>
            <SubObject subIndex="07" name="InterfaceOperStatus_U8" objectType="7" dataType="0005" accessType="ro" PDOmapping="no" defaultValue="1"/>
            <SubObject subIndex="08" name="InterfaceAdminState_U8" objectType="7" dataType="0005" accessType="rw" PDOmapping="no" defaultValue="1"/>
            <SubObject subIndex="09" name="Valid_BOOL" objectType="7" dataType="0001" accessType="rw" PDOmapping="no" defaultValue="true"/>
          </Object>

		      <Object index="1300" name="SDO_SequLayerTimeout_U32" objectType="7" PDOmapping="no" accessType="rw" dataType="0007" defaultValue="5000" />

          <Object index="1400" name="PDO_RxCommParam_0h_REC" objectType="9">
            <SubObject subIndex="00" name="NumberOfEntries" objectType="7" dataType="0005" accessType="const" defaultValue="0x02" PDOmapping="no" />
            <SubObject subIndex="01" name="NodeID_U8" objectType="7" dataType="0005" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="02" name="MappingVersion_U8" objectType="7" dataType="0005" accessType="rw" defaultValue="0x0" PDOmapping="no" />
          </Object>
          <Object index="1600" name="PDO_RxMappParam_0h_AU64" objectType="8">
            <SubObject subIndex="00" name="NumberOfEntries" objectType="7" dataType="0005" accessType="rw" defaultValue="0x04" PDOmapping="no" />
            <SubObject subIndex="01" name="ObjectMapping 1" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" actualValue="0x0008000000016200" PDOmapping="no" />
            <SubObject subIndex="02" name="ObjectMapping 2" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" actualValue="0x0008000800026200" PDOmapping="no" />
            <SubObject subIndex="03" name="ObjectMapping 3" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" actualValue="0x0008001000036200" PDOmapping="no" />
            <SubObject subIndex="04" name="ObjectMapping 4" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" actualValue="0x0008001800046200" PDOmapping="no" />
            <SubObject subIndex="05" name="ObjectMapping 5" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="06" name="ObjectMapping 6" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="07" name="ObjectMapping 7" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="08" name="ObjectMapping 8" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="09" name="ObjectMapping 9" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="0A" name="ObjectMapping 10" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="0B" name="ObjectMapping 11" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="0C" name="ObjectMapping 12" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="0D" name="ObjectMapping 13" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="0E" name="ObjectMapping 14" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="0F" name="ObjectMapping 15" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="10" name="ObjectMapping 16" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="11" name="ObjectMapping 17" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="12" name="ObjectMapping 18" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="13" name="ObjectMapping 19" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="14" name="ObjectMapping 20" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="15" name="ObjectMapping 21" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="16" name="ObjectMapping 22" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="17" name="ObjectMapping 23" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="18" name="ObjectMapping 24" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="19" name="ObjectMapping 25" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
          </Object>
          <Object index="1800" name="PDO_TxCommParam_0h_REC" objectType="9">
            <SubObject subIndex="00" name="NumberOfEntries" objectType="7" dataType="0005" accessType="const" defaultValue="0x02" PDOmapping="no" />
            <SubObject subIndex="01" name="NodeID_U8" objectType="7" dataType="0005" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="02" name="MappingVersion_U8" objectType="7" dataType="0005" accessType="rw" defaultValue="0x0" PDOmapping="no" />
          </Object>
          <Object index="1A00" name="PDO_TxMappParam_0h_AU64" objectType="8">
            <SubObject subIndex="00" name="NumberOfEntries" objectType="7" dataType="0005" accessType="rw" defaultValue="0x1A" actualValue="0x04" PDOmapping="no" />
            <SubObject subIndex="01" name="ObjectMapping 1" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" actualValue="0x0008000000016000" PDOmapping="no" />
            <SubObject subIndex="02" name="ObjectMapping 2" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" actualValue="0x0008000800026000" PDOmapping="no" />
            <SubObject subIndex="03" name="ObjectMapping 3" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" actualValue="0x0008001000036000" PDOmapping="no" />
            <SubObject subIndex="04" name="ObjectMapping 4" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" actualValue="0x0008001800046000" PDOmapping="no" />
            <SubObject subIndex="05" name="ObjectMapping 5" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="06" name="ObjectMapping 6" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="07" name="ObjectMapping 7" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="08" name="ObjectMapping 8" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="09" name="ObjectMapping 9" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="0A" name="ObjectMapping 10" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="0B" name="ObjectMapping 11" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="0C" name="ObjectMapping 12" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="0D" name="ObjectMapping 13" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="0E" name="ObjectMapping 14" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="0F" name="ObjectMapping 15" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="10" name="ObjectMapping 16" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="11" name="ObjectMapping 17" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="12" name="ObjectMapping 18" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="13" name="ObjectMapping 19" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="14" name="ObjectMapping 20" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="15" name="ObjectMapping 21" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="16" name="ObjectMapping 22" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="17" name="ObjectMapping 23" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="18" name="ObjectMapping 24" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="19" name="ObjectMapping 25" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
            <SubObject subIndex="1A" name="ObjectMapping 26" objectType="7" dataType="001B" accessType="rw" defaultValue="0x0" PDOmapping="no" />
          </Object>
          <Object index="1C0B" name="DLL_CNLossSoC_REC" objectType="9">
            <SubObject subIndex="00" name="NumberOfEntries" objectType="7" dataType="0005" accessType="const" PDOmapping="no" defaultValue="3"/>
            <SubObject subIndex="01" name="CumulativeCnt_U32" objectType="7" dataType="0007" accessType="rw" PDOmapping="no" />
            <SubObject subIndex="02" name="ThresholdCnt_U32" objectType="7" dataType="0007" accessType="ro" PDOmapping="no" />
            <SubObject subIndex="03" name="Threshold_U32" objectType="7" dataType="0007" accessType="rw" PDOmapping="no" defaultValue="1"/>
          </Object>
          <Object index="1C0D" name="DLL_CNLossPReq_REC" objectType="9">
            <SubObject subIndex="00" name="NumberOfEntries" objectType="7" dataType="0005" accessType="const" PDOmapping="no" defaultValue="3"/>
            <SubObject subIndex="01" name="CumulativeCnt_U32" objectType="7" dataType="0007" accessType="rw" PDOmapping="no" />
            <SubObject subIndex="02" name="ThresholdCnt_U32" objectType="7" dataType="0007" accessType="ro" PDOmapping="no" />
            <SubObject subIndex="03" name="Threshold_U32" objectType="7" dataType="0007" accessType="rw" PDOmapping="no" defaultValue="1"/>
          </Object>
          <Object index="1C0F" name="DLL_CNCRCError_REC" objectType="9">
            <SubObject subIndex="00" name="NumberOfEntries" objectType="7" dataType="0005" accessType="const" PDOmapping="no" defaultValue="3"/>
            <SubObject subIndex="01" name="CumulativeCnt_U32" objectType="7" dataType="0007" accessType="rw" PDOmapping="no"/>
            <SubObject subIndex="02" name="ThresholdCnt_U32" objectType="7" dataType="0007" accessType="ro" PDOmapping="no"/>
            <SubObject subIndex="03" name="Threshold_U32" objectType="7" dataType="0007" accessType="rw" PDOmapping="no" defaultValue="1"/>
          </Object>
          <Object index="1C14" name="DLL_CNLossOfSocTolerance_U32" objectType="7" dataType="0007" accessType="rw" defaultValue="300000"/>
          <Object dataType="0007" index="1F81" name="NMT_NodeAssignment_AU32" objectType="8" subNumber="255">
            <SubObject accessType="rw" dataType="0005" defaultValue="254" highLimit="254" lowLimit="254" name="NumberOfEntries" objectType="7" subIndex="00"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment01" objectType="7" subIndex="01"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment02" objectType="7" subIndex="02"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment03" objectType="7" subIndex="03"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="1" name="CNAssignment04" objectType="7" subIndex="04"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment05" objectType="7" subIndex="05"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment06" objectType="7" subIndex="06"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment07" objectType="7" subIndex="07"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment08" objectType="7" subIndex="08"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment09" objectType="7" subIndex="09"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment0A" objectType="7" subIndex="0A"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment0B" objectType="7" subIndex="0B"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment0C" objectType="7" subIndex="0C"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment0D" objectType="7" subIndex="0D"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment0E" objectType="7" subIndex="0E"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment0F" objectType="7" subIndex="0F"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment10" objectType="7" subIndex="10"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment11" objectType="7" subIndex="11"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment12" objectType="7" subIndex="12"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment13" objectType="7" subIndex="13"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment14" objectType="7" subIndex="14"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment15" objectType="7" subIndex="15"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment16" objectType="7" subIndex="16"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment17" objectType="7" subIndex="17"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment18" objectType="7" subIndex="18"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment19" objectType="7" subIndex="19"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment1A" objectType="7" subIndex="1A"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment1B" objectType="7" subIndex="1B"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment1C" objectType="7" subIndex="1C"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment1D" objectType="7" subIndex="1D"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment1E" objectType="7" subIndex="1E"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment1F" objectType="7" subIndex="1F"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment20" objectType="7" subIndex="20"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment21" objectType="7" subIndex="21"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment22" objectType="7" subIndex="22"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment23" objectType="7" subIndex="23"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment24" objectType="7" subIndex="24"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment25" objectType="7" subIndex="25"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment26" objectType="7" subIndex="26"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment27" objectType="7" subIndex="27"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment28" objectType="7" subIndex="28"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment29" objectType="7" subIndex="29"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment2A" objectType="7" subIndex="2A"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment2B" objectType="7" subIndex="2B"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment2C" objectType="7" subIndex="2C"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment2D" objectType="7" subIndex="2D"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment2E" objectType="7" subIndex="2E"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment2F" objectType="7" subIndex="2F"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment30" objectType="7" subIndex="30"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment31" objectType="7" subIndex="31"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment32" objectType="7" subIndex="32"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment33" objectType="7" subIndex="33"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment34" objectType="7" subIndex="34"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment35" objectType="7" subIndex="35"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment36" objectType="7" subIndex="36"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment37" objectType="7" subIndex="37"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment38" objectType="7" subIndex="38"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment39" objectType="7" subIndex="39"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment3A" objectType="7" subIndex="3A"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment3B" objectType="7" subIndex="3B"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment3C" objectType="7" subIndex="3C"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment3D" objectType="7" subIndex="3D"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment3E" objectType="7" subIndex="3E"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment3F" objectType="7" subIndex="3F"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment40" objectType="7" subIndex="40"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment41" objectType="7" subIndex="41"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment42" objectType="7" subIndex="42"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment43" objectType="7" subIndex="43"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment44" objectType="7" subIndex="44"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment45" objectType="7" subIndex="45"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment46" objectType="7" subIndex="46"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment47" objectType="7" subIndex="47"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment48" objectType="7" subIndex="48"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment49" objectType="7" subIndex="49"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment4A" objectType="7" subIndex="4A"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment4B" objectType="7" subIndex="4B"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment4C" objectType="7" subIndex="4C"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment4D" objectType="7" subIndex="4D"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment4E" objectType="7" subIndex="4E"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment4F" objectType="7" subIndex="4F"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment50" objectType="7" subIndex="50"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment51" objectType="7" subIndex="51"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment52" objectType="7" subIndex="52"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment53" objectType="7" subIndex="53"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment54" objectType="7" subIndex="54"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment55" objectType="7" subIndex="55"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment56" objectType="7" subIndex="56"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment57" objectType="7" subIndex="57"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment58" objectType="7" subIndex="58"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment59" objectType="7" subIndex="59"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment5A" objectType="7" subIndex="5A"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment5B" objectType="7" subIndex="5B"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment5C" objectType="7" subIndex="5C"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment5D" objectType="7" subIndex="5D"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment5E" objectType="7" subIndex="5E"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment5F" objectType="7" subIndex="5F"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment60" objectType="7" subIndex="60"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment61" objectType="7" subIndex="61"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment62" objectType="7" subIndex="62"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment63" objectType="7" subIndex="63"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment64" objectType="7" subIndex="64"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment65" objectType="7" subIndex="65"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment66" objectType="7" subIndex="66"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment67" objectType="7" subIndex="67"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment68" objectType="7" subIndex="68"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment69" objectType="7" subIndex="69"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment6A" objectType="7" subIndex="6A"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment6B" objectType="7" subIndex="6B"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment6C" objectType="7" subIndex="6C"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment6D" objectType="7" subIndex="6D"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment6E" objectType="7" subIndex="6E"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment6F" objectType="7" subIndex="6F"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment70" objectType="7" subIndex="70"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment71" objectType="7" subIndex="71"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment72" objectType="7" subIndex="72"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment73" objectType="7" subIndex="73"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment74" objectType="7" subIndex="74"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment75" objectType="7" subIndex="75"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment76" objectType="7" subIndex="76"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment77" objectType="7" subIndex="77"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment78" objectType="7" subIndex="78"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment79" objectType="7" subIndex="79"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment7A" objectType="7" subIndex="7A"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment7B" objectType="7" subIndex="7B"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment7C" objectType="7" subIndex="7C"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment7D" objectType="7" subIndex="7D"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment7E" objectType="7" subIndex="7E"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment7F" objectType="7" subIndex="7F"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment80" objectType="7" subIndex="80"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment81" objectType="7" subIndex="81"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment82" objectType="7" subIndex="82"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment83" objectType="7" subIndex="83"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment84" objectType="7" subIndex="84"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment85" objectType="7" subIndex="85"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment86" objectType="7" subIndex="86"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment87" objectType="7" subIndex="87"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment88" objectType="7" subIndex="88"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment89" objectType="7" subIndex="89"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment8A" objectType="7" subIndex="8A"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment8B" objectType="7" subIndex="8B"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment8C" objectType="7" subIndex="8C"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment8D" objectType="7" subIndex="8D"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment8E" objectType="7" subIndex="8E"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment8F" objectType="7" subIndex="8F"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment90" objectType="7" subIndex="90"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment91" objectType="7" subIndex="91"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment92" objectType="7" subIndex="92"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment93" objectType="7" subIndex="93"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment94" objectType="7" subIndex="94"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment95" objectType="7" subIndex="95"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment96" objectType="7" subIndex="96"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment97" objectType="7" subIndex="97"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment98" objectType="7" subIndex="98"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment99" objectType="7" subIndex="99"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment9A" objectType="7" subIndex="9A"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment9B" objectType="7" subIndex="9B"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment9C" objectType="7" subIndex="9C"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment9D" objectType="7" subIndex="9D"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment9E" objectType="7" subIndex="9E"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignment9F" objectType="7" subIndex="9F"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentA0" objectType="7" subIndex="A0"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentA1" objectType="7" subIndex="A1"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentA2" objectType="7" subIndex="A2"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentA3" objectType="7" subIndex="A3"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentA4" objectType="7" subIndex="A4"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentA5" objectType="7" subIndex="A5"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentA6" objectType="7" subIndex="A6"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentA7" objectType="7" subIndex="A7"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentA8" objectType="7" subIndex="A8"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentA9" objectType="7" subIndex="A9"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentAA" objectType="7" subIndex="AA"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentAB" objectType="7" subIndex="AB"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentAC" objectType="7" subIndex="AC"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentAD" objectType="7" subIndex="AD"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentAE" objectType="7" subIndex="AE"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentAF" objectType="7" subIndex="AF"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentB0" objectType="7" subIndex="B0"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentB1" objectType="7" subIndex="B1"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentB2" objectType="7" subIndex="B2"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentB3" objectType="7" subIndex="B3"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentB4" objectType="7" subIndex="B4"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentB5" objectType="7" subIndex="B5"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentB6" objectType="7" subIndex="B6"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentB7" objectType="7" subIndex="B7"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentB8" objectType="7" subIndex="B8"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentB9" objectType="7" subIndex="B9"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentBA" objectType="7" subIndex="BA"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentBB" objectType="7" subIndex="BB"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentBC" objectType="7" subIndex="BC"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentBD" objectType="7" subIndex="BD"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentBE" objectType="7" subIndex="BE"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentBF" objectType="7" subIndex="BF"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentC0" objectType="7" subIndex="C0"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentC1" objectType="7" subIndex="C1"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentC2" objectType="7" subIndex="C2"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentC3" objectType="7" subIndex="C3"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentC4" objectType="7" subIndex="C4"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentC5" objectType="7" subIndex="C5"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentC6" objectType="7" subIndex="C6"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentC7" objectType="7" subIndex="C7"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentC8" objectType="7" subIndex="C8"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentC9" objectType="7" subIndex="C9"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentCA" objectType="7" subIndex="CA"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentCB" objectType="7" subIndex="CB"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentCC" objectType="7" subIndex="CC"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentCD" objectType="7" subIndex="CD"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentCE" objectType="7" subIndex="CE"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentCF" objectType="7" subIndex="CF"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentD0" objectType="7" subIndex="D0"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentD1" objectType="7" subIndex="D1"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentD2" objectType="7" subIndex="D2"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentD3" objectType="7" subIndex="D3"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentD4" objectType="7" subIndex="D4"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentD5" objectType="7" subIndex="D5"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentD6" objectType="7" subIndex="D6"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentD7" objectType="7" subIndex="D7"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentD8" objectType="7" subIndex="D8"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentD9" objectType="7" subIndex="D9"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentDA" objectType="7" subIndex="DA"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentDB" objectType="7" subIndex="DB"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentDC" objectType="7" subIndex="DC"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentDD" objectType="7" subIndex="DD"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentDE" objectType="7" subIndex="DE"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentDF" objectType="7" subIndex="DF"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentE0" objectType="7" subIndex="E0"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentE1" objectType="7" subIndex="E1"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentE2" objectType="7" subIndex="E2"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentE3" objectType="7" subIndex="E3"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentE4" objectType="7" subIndex="E4"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentE5" objectType="7" subIndex="E5"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentE6" objectType="7" subIndex="E6"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentE7" objectType="7" subIndex="E7"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentE8" objectType="7" subIndex="E8"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentE9" objectType="7" subIndex="E9"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentEA" objectType="7" subIndex="EA"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentEB" objectType="7" subIndex="EB"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentEC" objectType="7" subIndex="EC"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentED" objectType="7" subIndex="ED"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentEE" objectType="7" subIndex="EE"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentEF" objectType="7" subIndex="EF"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="1" name="CNAssignmentF0" objectType="7" subIndex="F0"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentF1" objectType="7" subIndex="F1"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentF2" objectType="7" subIndex="F2"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentF3" objectType="7" subIndex="F3"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentF4" objectType="7" subIndex="F4"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentF5" objectType="7" subIndex="F5"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentF6" objectType="7" subIndex="F6"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentF7" objectType="7" subIndex="F7"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentF8" objectType="7" subIndex="F8"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentF9" objectType="7" subIndex="F9"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentFA" objectType="7" subIndex="FA"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentFB" objectType="7" subIndex="FB"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentFC" objectType="7" subIndex="FC"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentFD" objectType="7" subIndex="FD"/>
            <SubObject accessType="rw" dataType="0007" defaultValue="0" name="CNAssignmentFE" objectType="7" subIndex="FE"/>
          </Object>
          <Object index="1F82" name="NMT_FeatureFlags_U32" objectType="7" dataType="0007" accessType="const" PDOmapping="no" defaultValue="0x245"/>
          <Object index="1F83" name="NMT_EPLVersion_U8" objectType="7" dataType="0005" accessType="const" PDOmapping="no" defaultValue="0x20"/>
          <Object index="1F8C" name="NMT_CurrNMTState_U8" objectType="7" dataType="0005" PDOmapping="optional" accessType="ro"/>
          <Object dataType="0006" index="1F8D" name="NMT_PResPayloadLimitList_AU16" objectType="8" subNumber="255">
            <SubObject accessType="rw" dataType="0005" defaultValue="254" highLimit="254" lowLimit="254" name="NumberOfEntries" objectType="7" subIndex="00"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload01" objectType="7" subIndex="01"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload02" objectType="7" subIndex="02"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload03" objectType="7" subIndex="03"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="36" name="PResPayload04" objectType="7" subIndex="04"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload05" objectType="7" subIndex="05"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload06" objectType="7" subIndex="06"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload07" objectType="7" subIndex="07"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload08" objectType="7" subIndex="08"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload09" objectType="7" subIndex="09"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload0A" objectType="7" subIndex="0A"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload0B" objectType="7" subIndex="0B"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload0C" objectType="7" subIndex="0C"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload0D" objectType="7" subIndex="0D"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload0E" objectType="7" subIndex="0E"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload0F" objectType="7" subIndex="0F"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload10" objectType="7" subIndex="10"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload11" objectType="7" subIndex="11"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload12" objectType="7" subIndex="12"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload13" objectType="7" subIndex="13"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload14" objectType="7" subIndex="14"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload15" objectType="7" subIndex="15"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload16" objectType="7" subIndex="16"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload17" objectType="7" subIndex="17"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload18" objectType="7" subIndex="18"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload19" objectType="7" subIndex="19"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload1A" objectType="7" subIndex="1A"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload1B" objectType="7" subIndex="1B"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload1C" objectType="7" subIndex="1C"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload1D" objectType="7" subIndex="1D"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload1E" objectType="7" subIndex="1E"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload1F" objectType="7" subIndex="1F"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload20" objectType="7" subIndex="20"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload21" objectType="7" subIndex="21"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload22" objectType="7" subIndex="22"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload23" objectType="7" subIndex="23"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload24" objectType="7" subIndex="24"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload25" objectType="7" subIndex="25"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload26" objectType="7" subIndex="26"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload27" objectType="7" subIndex="27"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload28" objectType="7" subIndex="28"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload29" objectType="7" subIndex="29"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload2A" objectType="7" subIndex="2A"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload2B" objectType="7" subIndex="2B"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload2C" objectType="7" subIndex="2C"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload2D" objectType="7" subIndex="2D"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload2E" objectType="7" subIndex="2E"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload2F" objectType="7" subIndex="2F"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload30" objectType="7" subIndex="30"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload31" objectType="7" subIndex="31"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload32" objectType="7" subIndex="32"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload33" objectType="7" subIndex="33"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload34" objectType="7" subIndex="34"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload35" objectType="7" subIndex="35"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload36" objectType="7" subIndex="36"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload37" objectType="7" subIndex="37"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload38" objectType="7" subIndex="38"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload39" objectType="7" subIndex="39"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload3A" objectType="7" subIndex="3A"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload3B" objectType="7" subIndex="3B"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload3C" objectType="7" subIndex="3C"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload3D" objectType="7" subIndex="3D"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload3E" objectType="7" subIndex="3E"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload3F" objectType="7" subIndex="3F"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload40" objectType="7" subIndex="40"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload41" objectType="7" subIndex="41"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload42" objectType="7" subIndex="42"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload43" objectType="7" subIndex="43"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload44" objectType="7" subIndex="44"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload45" objectType="7" subIndex="45"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload46" objectType="7" subIndex="46"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload47" objectType="7" subIndex="47"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload48" objectType="7" subIndex="48"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload49" objectType="7" subIndex="49"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload4A" objectType="7" subIndex="4A"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload4B" objectType="7" subIndex="4B"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload4C" objectType="7" subIndex="4C"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload4D" objectType="7" subIndex="4D"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload4E" objectType="7" subIndex="4E"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload4F" objectType="7" subIndex="4F"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload50" objectType="7" subIndex="50"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload51" objectType="7" subIndex="51"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload52" objectType="7" subIndex="52"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload53" objectType="7" subIndex="53"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload54" objectType="7" subIndex="54"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload55" objectType="7" subIndex="55"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload56" objectType="7" subIndex="56"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload57" objectType="7" subIndex="57"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload58" objectType="7" subIndex="58"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload59" objectType="7" subIndex="59"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload5A" objectType="7" subIndex="5A"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload5B" objectType="7" subIndex="5B"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload5C" objectType="7" subIndex="5C"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload5D" objectType="7" subIndex="5D"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload5E" objectType="7" subIndex="5E"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload5F" objectType="7" subIndex="5F"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload60" objectType="7" subIndex="60"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload61" objectType="7" subIndex="61"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload62" objectType="7" subIndex="62"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload63" objectType="7" subIndex="63"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload64" objectType="7" subIndex="64"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload65" objectType="7" subIndex="65"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload66" objectType="7" subIndex="66"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload67" objectType="7" subIndex="67"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload68" objectType="7" subIndex="68"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload69" objectType="7" subIndex="69"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload6A" objectType="7" subIndex="6A"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload6B" objectType="7" subIndex="6B"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload6C" objectType="7" subIndex="6C"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload6D" objectType="7" subIndex="6D"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload6E" objectType="7" subIndex="6E"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload6F" objectType="7" subIndex="6F"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload70" objectType="7" subIndex="70"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload71" objectType="7" subIndex="71"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload72" objectType="7" subIndex="72"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload73" objectType="7" subIndex="73"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload74" objectType="7" subIndex="74"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload75" objectType="7" subIndex="75"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload76" objectType="7" subIndex="76"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload77" objectType="7" subIndex="77"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload78" objectType="7" subIndex="78"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload79" objectType="7" subIndex="79"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload7A" objectType="7" subIndex="7A"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload7B" objectType="7" subIndex="7B"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload7C" objectType="7" subIndex="7C"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload7D" objectType="7" subIndex="7D"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload7E" objectType="7" subIndex="7E"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload7F" objectType="7" subIndex="7F"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload80" objectType="7" subIndex="80"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload81" objectType="7" subIndex="81"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload82" objectType="7" subIndex="82"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload83" objectType="7" subIndex="83"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload84" objectType="7" subIndex="84"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload85" objectType="7" subIndex="85"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload86" objectType="7" subIndex="86"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload87" objectType="7" subIndex="87"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload88" objectType="7" subIndex="88"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload89" objectType="7" subIndex="89"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload8A" objectType="7" subIndex="8A"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload8B" objectType="7" subIndex="8B"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload8C" objectType="7" subIndex="8C"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload8D" objectType="7" subIndex="8D"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload8E" objectType="7" subIndex="8E"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload8F" objectType="7" subIndex="8F"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload90" objectType="7" subIndex="90"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload91" objectType="7" subIndex="91"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload92" objectType="7" subIndex="92"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload93" objectType="7" subIndex="93"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload94" objectType="7" subIndex="94"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload95" objectType="7" subIndex="95"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload96" objectType="7" subIndex="96"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload97" objectType="7" subIndex="97"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload98" objectType="7" subIndex="98"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload99" objectType="7" subIndex="99"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload9A" objectType="7" subIndex="9A"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload9B" objectType="7" subIndex="9B"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload9C" objectType="7" subIndex="9C"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload9D" objectType="7" subIndex="9D"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload9E" objectType="7" subIndex="9E"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayload9F" objectType="7" subIndex="9F"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadA0" objectType="7" subIndex="A0"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadA1" objectType="7" subIndex="A1"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadA2" objectType="7" subIndex="A2"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadA3" objectType="7" subIndex="A3"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadA4" objectType="7" subIndex="A4"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadA5" objectType="7" subIndex="A5"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadA6" objectType="7" subIndex="A6"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadA7" objectType="7" subIndex="A7"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadA8" objectType="7" subIndex="A8"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadA9" objectType="7" subIndex="A9"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadAA" objectType="7" subIndex="AA"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadAB" objectType="7" subIndex="AB"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadAC" objectType="7" subIndex="AC"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadAD" objectType="7" subIndex="AD"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadAE" objectType="7" subIndex="AE"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadAF" objectType="7" subIndex="AF"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadB0" objectType="7" subIndex="B0"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadB1" objectType="7" subIndex="B1"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadB2" objectType="7" subIndex="B2"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadB3" objectType="7" subIndex="B3"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadB4" objectType="7" subIndex="B4"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadB5" objectType="7" subIndex="B5"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadB6" objectType="7" subIndex="B6"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadB7" objectType="7" subIndex="B7"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadB8" objectType="7" subIndex="B8"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadB9" objectType="7" subIndex="B9"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadBA" objectType="7" subIndex="BA"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadBB" objectType="7" subIndex="BB"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadBC" objectType="7" subIndex="BC"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadBD" objectType="7" subIndex="BD"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadBE" objectType="7" subIndex="BE"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadBF" objectType="7" subIndex="BF"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadC0" objectType="7" subIndex="C0"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadC1" objectType="7" subIndex="C1"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadC2" objectType="7" subIndex="C2"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadC3" objectType="7" subIndex="C3"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadC4" objectType="7" subIndex="C4"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadC5" objectType="7" subIndex="C5"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadC6" objectType="7" subIndex="C6"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadC7" objectType="7" subIndex="C7"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadC8" objectType="7" subIndex="C8"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadC9" objectType="7" subIndex="C9"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadCA" objectType="7" subIndex="CA"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadCB" objectType="7" subIndex="CB"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadCC" objectType="7" subIndex="CC"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadCD" objectType="7" subIndex="CD"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadCE" objectType="7" subIndex="CE"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadCF" objectType="7" subIndex="CF"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadD0" objectType="7" subIndex="D0"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadD1" objectType="7" subIndex="D1"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadD2" objectType="7" subIndex="D2"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadD3" objectType="7" subIndex="D3"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadD4" objectType="7" subIndex="D4"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadD5" objectType="7" subIndex="D5"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadD6" objectType="7" subIndex="D6"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadD7" objectType="7" subIndex="D7"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadD8" objectType="7" subIndex="D8"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadD9" objectType="7" subIndex="D9"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadDA" objectType="7" subIndex="DA"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadDB" objectType="7" subIndex="DB"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadDC" objectType="7" subIndex="DC"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadDD" objectType="7" subIndex="DD"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadDE" objectType="7" subIndex="DE"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadDF" objectType="7" subIndex="DF"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadE0" objectType="7" subIndex="E0"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadE1" objectType="7" subIndex="E1"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadE2" objectType="7" subIndex="E2"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadE3" objectType="7" subIndex="E3"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadE4" objectType="7" subIndex="E4"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadE5" objectType="7" subIndex="E5"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadE6" objectType="7" subIndex="E6"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadE7" objectType="7" subIndex="E7"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadE8" objectType="7" subIndex="E8"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadE9" objectType="7" subIndex="E9"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadEA" objectType="7" subIndex="EA"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadEB" objectType="7" subIndex="EB"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadEC" objectType="7" subIndex="EC"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadED" objectType="7" subIndex="ED"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadEE" objectType="7" subIndex="EE"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadEF" objectType="7" subIndex="EF"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="36" name="PResPayloadF0" objectType="7" subIndex="F0"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadF1" objectType="7" subIndex="F1"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadF2" objectType="7" subIndex="F2"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadF3" objectType="7" subIndex="F3"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadF4" objectType="7" subIndex="F4"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadF5" objectType="7" subIndex="F5"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadF6" objectType="7" subIndex="F6"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadF7" objectType="7" subIndex="F7"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadF8" objectType="7" subIndex="F8"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadF9" objectType="7" subIndex="F9"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadFA" objectType="7" subIndex="FA"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadFB" objectType="7" subIndex="FB"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadFC" objectType="7" subIndex="FC"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadFD" objectType="7" subIndex="FD"/>
            <SubObject accessType="rw" dataType="0006" defaultValue="0" name="PResPayloadFE" objectType="7" subIndex="FE"/>
          </Object>

          <Object index="1F93" name="NMT_EPLNodeID_REC" objectType="9">
            <SubObject subIndex="00" name="NumberOfEntries" objectType="7" dataType="0005" accessType="const" PDOmapping="no" defaultValue="2"/>
            <SubObject subIndex="01" name="NodeID_U8" objectType="7" dataType="0005" accessType="ro" PDOmapping="no"/>
            <SubObject subIndex="02" name="NodeIDByHW_BOOL" objectType="7" dataType="0001" accessType="ro" PDOmapping="no"/>
          </Object>
          <Object index="1F98" name="NMT_CycleTiming_REC" objectType="9">
            <SubObject subIndex="00" name="NumberOfEntries" objectType="7" dataType="0005" accessType="const" PDOmapping="no" defaultValue="8"/>
            <SubObject subIndex="01" name="IsochrTxMaxPayload_U16" objectType="7" dataType="0006" accessType="const" PDOmapping="no" defaultValue="256"/>
            <SubObject subIndex="02" name="IsochrRxMaxPayload_U16" objectType="7" dataType="0006" accessType="const" PDOmapping="no" defaultValue="256"/>
            <SubObject subIndex="03" name="PResMaxLatency_U32" objectType="7" dataType="0007" accessType="const" PDOmapping="no" defaultValue="2000"/>
            <SubObject subIndex="04" name="PReqActPayloadLimit_U16" objectType="7" dataType="0006" accessType="rw" PDOmapping="no" defaultValue="36"/>
            <SubObject subIndex="05" name="PResActPayloadLimit_U16" objectType="7" dataType="0006" accessType="rw" PDOmapping="no" defaultValue="36"/>
            <SubObject subIndex="06" name="ASndMaxLatency_U32" objectType="7" dataType="0007" accessType="const" PDOmapping="no" defaultValue="2000"/>
            <SubObject subIndex="07" name="MultiplCycleCnt_U8" objectType="7" dataType="0005" accessType="rw" PDOmapping="no" defaultValue="0"/>
            <SubObject subIndex="08" name="AsyncMTUSize_U16" objectType="7" dataType="0006" accessType="rw" PDOmapping="no" defaultValue="1500"/>
          </Object>
          <Object index="1F99" name="NMT_CNBasicEthernetTimeout_U32" objectType="7" dataType="0007" accessType="rw" PDOmapping="no" defaultValue="5000000"/>
          <Object index="1F9E" name="NMT_ResetCmd_U8" objectType="7" dataType="0005" accessType="rw" PDOmapping="no" defaultValue="255"/>
        </ObjectList>

      </ApplicationLayers>
      <TransportLayers>
      </TransportLayers>
      <NetworkManagement>

        <!-- todo:
             fill out the attributes of <GeneralFeatures> and <CNFeatures>

             DLLFeatureMN:              "false", XDD file is for a controlled node, leave this attribute unchanged
             NMTBootTimeNotActive:      device boot time (power on to NMT_MS_NOT_ACTIVE) in microseconds
             NMTCycleTimeMin:           minimum supported EPL cycle time in microseconds
             NMTCycleTimeMax:           maximum supported EPL cycle time in microseconds
             NMTErrorEntries:           maximum number of error entries (Status and History Entries) in the StatusResponse frame
             NWLIPSupport:              Ability of the node cummunicate via IP (true/false)
             SDOServer:                 device implements an SDO server
             SDOMaxConnections:         max. number of SDO connections
             SDOMaxParallelConnections: max. number of SDO connections between an SDO client/server pair

             DLLCNFeatureMultiplex: node’s ability to perform control of multiplexed isochronous communication
             NMTCNSoC2PReq:         controlled node SoC handling maximum time in nanoseconds, a subsequent PReq won’t be handled before SoC handling was finished

           REMARK:
             This features have to be defined to form a valid XDD file
             Currently (December 2007) Features are ignored by the B&R Automation Studio XDD import feature
        -->
        <GeneralFeatures
          DLLFeatureMN="false"
          NMTBootTimeNotActive="3000000"
          NMTCycleTimeMax="60000"
          NMTCycleTimeMin="400"
          NMTErrorEntries="2"
          NWLIPSupport="false"
          SDOServer="true"
          SDOMaxConnections="2"
          SDOMaxParallelConnections="2"
          SDOCmdWriteAllByIndex="false"
          SDOCmdReadAllByIndex="false"
          SDOCmdWriteByName="false"
          SDOCmdReadByName="false"
          SDOCmdWriteMultParam="false"
          NMTFlushArpEntry="false"
          NMTNetHostNameSet="false"
          PDORPDOChannels="3"
          PDORPDOChannelObjects="25"
          PDORPDOOverallObjects="25"
          PDOSelfReceipt="false"
          PDOTPDOChannelObjects="26"
          PDOTPDOOverallObjects="26"
        />
        <CNFeatures
          DLLCNFeatureMultiplex="true"
          DLLCNPResChaining="true"
          NMTCNSoC2PReq="0"
        />

        <Diagnostic>
        </Diagnostic>
      </NetworkManagement>
    </ProfileBody>
  </ISO15745Profile>
</ISO15745ProfileContainer>
