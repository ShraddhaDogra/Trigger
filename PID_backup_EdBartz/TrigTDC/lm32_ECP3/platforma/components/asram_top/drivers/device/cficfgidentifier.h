/****************************************************************************
 **
 **  Name:  CFICfgIdentifier.h
 **
 **  Description: Defines data structures and constants for indexing
 **               into key CFI addresses.
 **     
 **  $Revision: $
 **
 ** Disclaimer:
 **
 **   This source code is intended as a design reference which
 **   illustrates how these types of functions can be implemented.  It
 **   is the user's responsibility to verify their design for
 **   consistency and functionality through the use of formal
 **   verification methods.  Lattice Semiconductor provides no warranty
 **   regarding the use or functionality of this code.
 **
 ** --------------------------------------------------------------------
 **
 **                     Lattice Semiconductor Corporation
 **                     5555 NE Moore Court
 **                     Hillsboro, OR 97214
 **                     U.S.A
 **
 **                     TEL: 1-800-Lattice (USA and Canada)
 **                          (503)268-8001 (other locations)
 **
 **                     web:   http://www.latticesemi.com
 **                     email: techsupport@latticesemi.com
 **
 ** --------------------------------------------------------------------
 **
 *****************************************************************************/

#ifndef CFICFGIDENTIFIER_H
#define CFICFGIDENTIFIER_H

#ifdef __cplusplus
extern "C"
{
#endif

   /****************************
    *                          *
    *       INCLUDE FILES      *
    *                          *
    ****************************/
#include "CFIRoutines.h"

   /****************************
    *                          *
    *      DEFINITIONS         *
    *                          *
    ****************************/

   //#define CFI_READ_BYTE(x) (*(unsigned char *) (x))

   typedef struct DWORD_ALIGNED_CFI_FLASH {
      volatile unsigned int base;
      volatile unsigned int base1;
      unsigned int dummy[14];
      volatile unsigned int const_QRY_Q;
      volatile unsigned int const_QRY_R;
      volatile unsigned int const_QRY_Y;
      volatile unsigned int primCmdSet_LSB;
      volatile unsigned int primCmdSet_MSB;
      volatile unsigned int primAddrTbl_LSB;
      volatile unsigned int primAddrTbl_MSB;
      volatile unsigned int altCmdSet_LSB;
      volatile unsigned int altCmdSet_MSB;
      volatile unsigned int altAddrTbl_LSB;
      volatile unsigned int altAddrTbl_MSB;
      volatile unsigned int MinVCC;
      volatile unsigned int MaxVCC;
      volatile unsigned int MinVPP;
      volatile unsigned int MaxVPP;
      volatile unsigned int typWordTimeout;
      volatile unsigned int typBufferTimeout;
      volatile unsigned int typBlockEraseTimeout;
      volatile unsigned int typChipEraseTimeout;
      volatile unsigned int maxWordTimeout;
      volatile unsigned int maxBufferTimeout;
      volatile unsigned int maxBlockEraseTimeout;
      volatile unsigned int maxChipEraseTimeout;
      volatile unsigned int deviceSize;

      volatile unsigned int flashDeviceIntfc_LSB;
      volatile unsigned int flashDeviceIntfc_MSB;
      volatile unsigned int maxNumMultiByte_LSB;
      volatile unsigned int maxNumMultiByte_MSB;
      volatile unsigned int numEraseBlockRegions;
      volatile unsigned int eraseBlockRegion1_1;
      volatile unsigned int eraseBlockRegion1_2;
      volatile unsigned int eraseBlockRegion1_3;
      volatile unsigned int eraseBlockRegion1_4;
      volatile unsigned int eraseBlockRegion2_1;
      volatile unsigned int eraseBlockRegion2_2;
      volatile unsigned int eraseBlockRegion2_3;
      volatile unsigned int eraseBlockRegion2_4;
      volatile unsigned int eraseBlockRegion3_1;
      volatile unsigned int eraseBlockRegion3_2;
      volatile unsigned int eraseBlockRegion3_3;
      volatile unsigned int eraseBlockRegion3_4;
      volatile unsigned int eraseBlockRegion4_1;
      volatile unsigned int eraseBlockRegion4_2;
      volatile unsigned int eraseBlockRegion4_3;
      volatile unsigned int eraseBlockRegion4_4;
      unsigned int dummy2[3];  // 0x3d, 3e, 3f
      volatile unsigned int const_PRI_P;
      volatile unsigned int const_PRI_R;
      volatile unsigned int const_PRI_I;
      volatile unsigned int majorVer;
      volatile unsigned int minorVer;
      volatile unsigned int addrSensitiveUnlock;
      volatile unsigned int eraseSuspend;
      volatile unsigned int sectorProtect;
      volatile unsigned int sectorTempUnprotect;
      volatile unsigned int sectorProtScheme;
      volatile unsigned int simulOperation;
      volatile unsigned int burstModeType;
      volatile unsigned int pageModeType;
      volatile unsigned int accSupplyMin;
      volatile unsigned int accSupplyMax;
      volatile unsigned int wpProtection;
      volatile unsigned int programSuspend;
      unsigned int dummy3[4];  // 0x51, 52, 53, 54
      volatile unsigned int enableCFIQuery;
      volatile unsigned int dummy4[0x254];
      volatile unsigned int Addr2AA;
      volatile unsigned int dummy5[0x2aa];
      volatile unsigned int Addr555;
   } t_DWORD_ALIGNED_CFI_FLASH, *pt_DWORD_ALIGNED_CFI_FLASH;

   typedef struct WORD_ALIGNED_CFI_FLASH {
      unsigned short base;
      unsigned short base1;
      unsigned short dummy[14];
      volatile unsigned short const_QRY_Q;
      volatile unsigned short const_QRY_R;
      volatile unsigned short const_QRY_Y;
      volatile unsigned short primCmdSet_LSB;
      volatile unsigned short primCmdSet_MSB;
      volatile unsigned short primAddrTbl_LSB;
      volatile unsigned short primAddrTbl_MSB;
      volatile unsigned short altCmdSet_LSB;
      volatile unsigned short altCmdSet_MSB;
      volatile unsigned short altAddrTbl_LSB;
      volatile unsigned short altAddrTbl_MSB;
      volatile unsigned short MinVCC;
      volatile unsigned short MaxVCC;
      volatile unsigned short MinVPP;
      volatile unsigned short MaxVPP;
      volatile unsigned short typWordTimeout;
      volatile unsigned short typBufferTimeout;
      volatile unsigned short typBlockEraseTimeout;
      volatile unsigned short typChipEraseTimeout;
      volatile unsigned short maxWordTimeout;
      volatile unsigned short maxBufferTimeout;
      volatile unsigned short maxBlockEraseTimeout;
      volatile unsigned short maxChipEraseTimeout;
      volatile unsigned short deviceSize;

      volatile unsigned short flashDeviceIntfc_LSB;
      volatile unsigned short flashDeviceIntfc_MSB;
      volatile unsigned short maxNumMultiByte_LSB;
      volatile unsigned short maxNumMultiByte_MSB;
      volatile unsigned short numEraseBlockRegions;
      volatile unsigned short eraseBlockRegion1_1;
      volatile unsigned short eraseBlockRegion1_2;
      volatile unsigned short eraseBlockRegion1_3;
      volatile unsigned short eraseBlockRegion1_4;
      volatile unsigned short eraseBlockRegion2_1;
      volatile unsigned short eraseBlockRegion2_2;
      volatile unsigned short eraseBlockRegion2_3;
      volatile unsigned short eraseBlockRegion2_4;
      volatile unsigned short eraseBlockRegion3_1;
      volatile unsigned short eraseBlockRegion3_2;
      volatile unsigned short eraseBlockRegion3_3;
      volatile unsigned short eraseBlockRegion3_4;
      volatile unsigned short eraseBlockRegion4_1;
      volatile unsigned short eraseBlockRegion4_2;
      volatile unsigned short eraseBlockRegion4_3;
      volatile unsigned short eraseBlockRegion4_4;
      unsigned short dummy2[3];  // 0x3d, 3e, 3f
      volatile unsigned short const_PRI_P;
      volatile unsigned short const_PRI_R;
      volatile unsigned short const_PRI_I;
      volatile unsigned short majorVer;
      volatile unsigned short minorVer;
      volatile unsigned short addrSensitiveUnlock;
      volatile unsigned short eraseSuspend;
      volatile unsigned short sectorProtect;
      volatile unsigned short sectorTempUnprotect;
      volatile unsigned short sectorProtScheme;
      volatile unsigned short simulOperation;
      volatile unsigned short burstModeType;
      volatile unsigned short pageModeType;
      volatile unsigned short accSupplyMin;
      volatile unsigned short accSupplyMax;
      volatile unsigned short wpProtection;
      volatile unsigned short programSuspend;
      unsigned short dummy3[4];  // 0x51, 52, 53, 54
      volatile unsigned short enableCFIQuery; // 0x55
      volatile unsigned short dummy4[0x254];
      volatile unsigned short Addr2AA;
      volatile unsigned short dummy5[0x2aa];
      volatile unsigned short Addr555;

   } t_WORD_ALIGNED_CFI_FLASH, *pt_WORD_ALIGNED_CFI_FLASH;


   // The byte aligned structure needs to be padded to be word aligned
   // because the SPANSION memory ignores A(-1) for the purposes of
   // issueing CFI commands.  
   typedef struct BYTE_ALIGNED_CFI_FLASH {
      volatile unsigned char base;
      volatile unsigned char base_p1;
      volatile unsigned char base1;
      volatile unsigned char base1_p1;
      volatile unsigned char base2;
      volatile unsigned char base2_p1;
      volatile unsigned char base3;
      volatile unsigned char base3_p1;
      unsigned short dummy[12];
      volatile unsigned char const_QRY_Q;
      volatile unsigned char const_QRY_Q_p1;
      volatile unsigned char const_QRY_R;
      volatile unsigned char const_QRY_R_p1;
      volatile unsigned char const_QRY_Y;
      volatile unsigned char const_QRY_Y_p1;
      volatile unsigned char primCmdSet_LSB;
      volatile unsigned char primCmdSet_LSB_p1;
      volatile unsigned char primCmdSet_MSB;
      volatile unsigned char primCmdSet_MSB_p1;
      volatile unsigned char primAddrTbl_LSB;
      volatile unsigned char primAddrTbl_LSB_p1;
      volatile unsigned char primAddrTbl_MSB;
      volatile unsigned char primAddrTbl_MSB_p1;
      volatile unsigned char altCmdSet_LSB;
      volatile unsigned char altCmdSet_LSB_p1;
      volatile unsigned char altCmdSet_MSB;
      volatile unsigned char altCmdSet_MSB_p1;
      volatile unsigned char altAddrTbl_LSB;
      volatile unsigned char altAddrTbl_LSB_p1;
      volatile unsigned char altAddrTbl_MSB;
      volatile unsigned char altAddrTbl_MSB_p1;
      volatile unsigned char MinVCC;
      volatile unsigned char MinVCC_p1;
      volatile unsigned char MaxVCC;
      volatile unsigned char MaxVCC_p1;
      volatile unsigned char MinVPP;
      volatile unsigned char MinVPP_p1;
      volatile unsigned char MaxVPP;
      volatile unsigned char MaxVPP_p1;
      volatile unsigned char typWordTimeout;
      volatile unsigned char typWordTimeout_p1;
      volatile unsigned char typBufferTimeout;
      volatile unsigned char typBufferTimeout_p1;
      volatile unsigned char typBlockEraseTimeout;
      volatile unsigned char typBlockEraseTimeout_p1;
      volatile unsigned char typChipEraseTimeout;
      volatile unsigned char typChipEraseTimeout_p1;
      volatile unsigned char maxWordTimeout;
      volatile unsigned char maxWordTimeout_p1;
      volatile unsigned char maxBufferTimeout;
      volatile unsigned char maxBufferTimeout_p1;
      volatile unsigned char maxBlockEraseTimeout;
      volatile unsigned char maxBlockEraseTimeout_p1;
      volatile unsigned char maxChipEraseTimeout;
      volatile unsigned char maxChipEraseTimeout_p1;
      volatile unsigned char deviceSize;
      volatile unsigned char deviceSize_p1;

      volatile unsigned char flashDeviceIntfc_LSB;
      volatile unsigned char flashDeviceIntfc_LSB_p1;
      volatile unsigned char flashDeviceIntfc_MSB;
      volatile unsigned char flashDeviceIntfc_MSB_p1;
      volatile unsigned char maxNumMultiByte_LSB;
      volatile unsigned char maxNumMultiByte_LSB_p1;
      volatile unsigned char maxNumMultiByte_MSB;
      volatile unsigned char maxNumMultiByte_MSB_p1;
      volatile unsigned char numEraseBlockRegions;
      volatile unsigned char numEraseBlockRegions_p1;
      volatile unsigned char eraseBlockRegion1_1;
      volatile unsigned char eraseBlockRegion1_1_p1;
      volatile unsigned char eraseBlockRegion1_2;
      volatile unsigned char eraseBlockRegion1_2_p1;
      volatile unsigned char eraseBlockRegion1_3;
      volatile unsigned char eraseBlockRegion1_3_p1;
      volatile unsigned char eraseBlockRegion1_4;
      volatile unsigned char eraseBlockRegion1_4_p1;
      volatile unsigned char eraseBlockRegion2_1;
      volatile unsigned char eraseBlockRegion2_1_p1;
      volatile unsigned char eraseBlockRegion2_2;
      volatile unsigned char eraseBlockRegion2_2_p1;
      volatile unsigned char eraseBlockRegion2_3;
      volatile unsigned char eraseBlockRegion2_3_p1;
      volatile unsigned char eraseBlockRegion2_4;
      volatile unsigned char eraseBlockRegion2_4_p1;
      volatile unsigned char eraseBlockRegion3_1;
      volatile unsigned char eraseBlockRegion3_1_p1;
      volatile unsigned char eraseBlockRegion3_2;
      volatile unsigned char eraseBlockRegion3_2_p1;
      volatile unsigned char eraseBlockRegion3_3;
      volatile unsigned char eraseBlockRegion3_3_p1;
      volatile unsigned char eraseBlockRegion3_4;
      volatile unsigned char eraseBlockRegion3_4_p1;
      volatile unsigned char eraseBlockRegion4_1;
      volatile unsigned char eraseBlockRegion4_1_p1;
      volatile unsigned char eraseBlockRegion4_2;
      volatile unsigned char eraseBlockRegion4_2_p1;
      volatile unsigned char eraseBlockRegion4_3;
      volatile unsigned char eraseBlockRegion4_3_p1;
      volatile unsigned char eraseBlockRegion4_4;
      volatile unsigned char eraseBlockRegion4_4_p1;
      unsigned short dummy2[3];  // 0x3d, 3e, 3f
      volatile unsigned char const_PRI_P;
      volatile unsigned char const_PRI_P_p1;
      volatile unsigned char const_PRI_R;
      volatile unsigned char const_PRI_R_p1;
      volatile unsigned char const_PRI_I;
      volatile unsigned char const_PRI_I_p1;
      volatile unsigned char majorVer;
      volatile unsigned char majorVer_p1;
      volatile unsigned char minorVer;
      volatile unsigned char minorVer_p1;
      volatile unsigned char addrSensitiveUnlock;
      volatile unsigned char addrSensitiveUnlock_p1;
      volatile unsigned char eraseSuspend;
      volatile unsigned char eraseSuspend_p1;
      volatile unsigned char sectorProtect;
      volatile unsigned char sectorProtect_p1;
      volatile unsigned char sectorTempUnprotect;
      volatile unsigned char sectorTempUnprotect_p1;
      volatile unsigned char sectorProtScheme;
      volatile unsigned char sectorProtScheme_p1;
      volatile unsigned char simulOperation;
      volatile unsigned char simulOperation_p1;
      volatile unsigned char burstModeType;
      volatile unsigned char burstModeType_p1;
      volatile unsigned char pageModeType;
      volatile unsigned char pageModeType_p1;
      volatile unsigned char accSupplyMin;
      volatile unsigned char accSupplyMin_p1;
      volatile unsigned char accSupplyMax;
      volatile unsigned char accSupplyMax_p1;
      volatile unsigned char wpProtection;
      volatile unsigned char wpProtection_p1;
      volatile unsigned char programSuspend;
      volatile unsigned char programSuspend_p1;
      unsigned short dummy3[4];  // 0x51, 52, 53, 54
      volatile unsigned char enableCFIQuery;
      volatile unsigned char enableCFIQuery_p1;
      volatile unsigned short dummy4[0x254];
      volatile unsigned char Addr2AA;
      volatile unsigned char Addr2AA_p1;
      volatile unsigned short dummy5[0x2aa];
      volatile unsigned char Addr555;
      volatile unsigned char Addr555_p1;
   } t_BYTE_ALIGNED_CFI_FLASH, *pt_BYTE_ALIGNED_CFI_FLASH;


   // Constants used to index into CFI data fields.
#define CFI_PRIM_CMDSET_LSB         (0x13)
#define CFI_PRIM_CMDSET_MSB         (0x14)

#define CFI_MIN_VCC                 (0x1b)
#define CFI_MAX_VCC                 (0x1c)
#define CFI_MIN_VPP                 (0x1d)
#define CFI_MAX_VPP                 (0x1e)
#define CFI_TYP_WORD_TIMEOUT        (0x1f)
#define CFI_TYP_BUFFER_TIMEOUT      (0x20)
#define CFI_TYP_BLOCK_ERASE_TIMEOUT (0x21)
#define CFI_TYP_CHIP_ERASE_TIMEOUT  (0x22)
#define CFI_MAX_WORD_TIMEOUT        (0x23)
#define CFI_MAX_BUFFER_TIMEOUT      (0x24)
#define CFI_MAX_BLOCK_ERASE_TIMEOUT (0x25)
#define CFI_MAX_CHIP_ERASE_TIMEOUT  (0x26)
#define CFI_DEVICE_SIZE             (0x27)

#define CFI_FLASH_DEVICE_INTFC_LSB  (0x28)
#define CFI_FLASH_DEVICE_INTFC_MSB  (0x29)
#define CFI_MAX_NUM_MULTIBYTE_LSB   (0x2a)
#define CFI_MAX_NUM_MULTIBYTE_MSB   (0x2b)
#define CFI_NUM_ERASE_BLOCK_REGIONS (0x2c)
#define CFI_ERASE_BLOCK_REGION1_1   (0x2d)
#define CFI_ERASE_BLOCK_REGION1_2   (0x2e)
#define CFI_ERASE_BLOCK_REGION1_3   (0x2f)
#define CFI_ERASE_BLOCK_REGION1_4   (0x30)
#define CFI_ERASE_BLOCK_REGION2_1   (0x31)
#define CFI_ERASE_BLOCK_REGION2_2   (0x32)
#define CFI_ERASE_BLOCK_REGION2_3   (0x33)
#define CFI_ERASE_BLOCK_REGION2_4   (0x34)
#define CFI_ERASE_BLOCK_REGION3_1   (0x35)
#define CFI_ERASE_BLOCK_REGION3_2   (0x36)
#define CFI_ERASE_BLOCK_REGION3_3   (0x37)
#define CFI_ERASE_BLOCK_REGION3_4   (0x38)
#define CFI_ERASE_BLOCK_REGION4_1   (0x39)
#define CFI_ERASE_BLOCK_REGION4_2   (0x3a)
#define CFI_ERASE_BLOCK_REGION4_3   (0x3b)
#define CFI_ERASE_BLOCK_REGION4_4   (0x3c)

#define CFI_CONST_PRI_P             (0x40)
#define CFI_CONST_PRI_R             (0x41)
#define CFI_CONST_PRI_I             (0x42)
#define CFI_MAJOR_VER               (0x43)
#define CFI_MINOR_VER               (0x44)
#define CFI_ADDR_SENSITIVE_UNLOCK   (0x45)
#define CFI_ERASE_SUSPEND           (0x46)
#define CFI_SECTOR_PROTECT          (0x47)
#define CFI_SECTOR_TEMP_UNPROTECT   (0x48)
#define CFI_SECTOR_PROT_SCHEME      (0x49)
#define CFI_SIMUL_OPERATION         (0x4a)
#define CFI_BURST_MODE_TYPE         (0x4b)
#define CFI_PAGE_MODE_TYPE          (0x4c)
#define CFI_ACC_SUPPLY_MIN          (0x4d)
#define CFI_ACC_SUPPLY_MAX          (0x4e)
#define CFI_WP_PROTECTION           (0x4f)
#define CFI_PROGRAM_SUSPEND         (0x50)

   /****************************
    *                          *
    *  FUNCTION PROTOTYPES     *
    *                          *
    ****************************/

/****************************************************************************
**
**  CFIIdentifyConfiguration
**
**  Description: Determines how the FLASH memory is physically connected
**               to the LM32.
**
**    Inputs:
**       Base:  Offset to the flash memory device
** 
**    Outputs:
**       BoardInfo: The number of parallel flash proms and their 
**                  data width (8, 16)
** 
**    Return values:
**       0 on success
** 
*****************************************************************************/
   unsigned int CFIIdentifyConfiguration(unsigned int Base, FlashBoardCfgInfo_t *BoardInfo);

/****************************************************************************
**
**  GetCFICfgAddressMultiplier
**
**  Description: Returns a constant used to multiply to the constants
**               defined in CFICfgIdentifier.h.  These consants act as
**               indexes to the useful data values provided by the
**               FLASH memory when it is in query mode.
**
**    Inputs:
**       BoardInfo:  The number of parallel memory devices and the
**    width of the memory devices as a data struct.
** 
**    Outputs:
**       none:
** 
**    Return values:
**       integer: The byte width of the flash memmory.  Note 1x8-bit
**    configurations return 2 as all of the address indexing is done
**    on word boundaries.
** 
*****************************************************************************/
   unsigned int GetCFICfgAddressMultiplier(FlashBoardCfgInfo_t *BoardInfo);
   unsigned int GetCFICfgFlashBusWidth(FlashBoardCfgInfo_t *BoardInfo);


/****************************************************************************
**
**  ValidateCFIBoardCfg
**
**  Description: A simple-minded routine that checks to make sure the
**               configuration found by the detection function is valid.
**
**    Inputs:
**       BoardInfo:  The number of parallel memory devices and the
**    width of the memory devices as a data struct.
** 
**    Outputs:
**       none:
** 
**    Return values:
**       integer: 0 = Success
**                else Failure
** 
*****************************************************************************/
   unsigned int ValidateCFIBoardCfg(FlashBoardCfgInfo_t *BoardInfo);

#ifdef __cplusplus
}
#endif

#endif /* CFICfgIndentifier.h */
/********************************* E O F *************************************/
