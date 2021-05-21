/****************************************************************************
**
**  Name:  CFIRoutines.c
**
**  Description:
**     Performs all of the erase and programming functions for a
**     SPANSION CFI FLASH in a 1 x 16-bit configuration
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

/****************************
 *                          *
 *       INCLUDE FILES      *
 *                          *
 ****************************/

#include "CFIRoutines.h"
#include "LatticeMico32.h"
#include "CFICfgIdentifier.h"
#include "CFIFlashConfigurations.h"

/****************************
 *                          *
 *     LOCAL DEFINITIONS    *
 *                          *
 ****************************/

/****************************
 *                          *
 *    EXTERNAL VARIABLES    *
 *                          *
 ****************************/

/****************************
 *                          *
 *     LOCAL PROTOTYPES     *
 *                          *
 ****************************/

/****************************
 *                          *
 *      EXECUTABLE CODE     *
 *                          *
 ****************************/

unsigned char CFI_READ_BYTE(unsigned char port_width, unsigned int offset) {
   unsigned int maskValue = ~(port_width-1);
   unsigned char *ucPtr = (unsigned char *)(offset & maskValue);
   unsigned char index = offset & (~maskValue);

   //MicoFlushDataCache();
#ifndef LM32_BIG_ENDIAN_CONNECTION
   return(ucPtr[(port_width-1)-index]);
#else
   return(*ucPtr);
#endif

}

/*
 * Issue a CFI Query Entry
 */
void IssueCFIQueryEnter(unsigned int Base, FlashBoardCfgInfo_t *BoardInfo)
{
   pt_DWORD_ALIGNED_CFI_FLASH pDW_CFIFlashDev = (pt_DWORD_ALIGNED_CFI_FLASH) Base;
   pt_WORD_ALIGNED_CFI_FLASH pW_CFIFlashDev = (pt_WORD_ALIGNED_CFI_FLASH) Base;
   if(BoardInfo->mode == 8){
      if(BoardInfo->parallels == 1) {
         pW_CFIFlashDev->enableCFIQuery = CFI_1_8_ENABLE;
      } else if(BoardInfo->parallels == 2){
         pW_CFIFlashDev->enableCFIQuery = CFI_2_8_ENABLE;
      } else if (BoardInfo->parallels == 4) {
         pDW_CFIFlashDev->enableCFIQuery = CFI_4_8_ENABLE;
      }
   } else if(BoardInfo->mode == 16){
      if(BoardInfo->parallels == 1){
         pW_CFIFlashDev->enableCFIQuery = CFI_1_16_ENABLE;
      }else if(BoardInfo->parallels == 2){
         pDW_CFIFlashDev->enableCFIQuery = CFI_2_16_ENABLE;
      }
   }
   return;
}


/*
 * Issue a CFI Query Exit
 */
void IssueCFIQueryExit(unsigned int Base, FlashBoardCfgInfo_t *BoardInfo)
{
   pt_DWORD_ALIGNED_CFI_FLASH pDW_CFIFlashDev = (pt_DWORD_ALIGNED_CFI_FLASH) Base;
   pt_WORD_ALIGNED_CFI_FLASH pW_CFIFlashDev = (pt_WORD_ALIGNED_CFI_FLASH) Base;
   if(BoardInfo->mode == 8){
      if(BoardInfo->parallels == 1) {
         pW_CFIFlashDev->enableCFIQuery = 0xf0;
      } else if(BoardInfo->parallels == 2){
         pW_CFIFlashDev->enableCFIQuery = 0xf0f0;
      } else if (BoardInfo->parallels == 4) {
         pDW_CFIFlashDev->enableCFIQuery = 0xf0f0f0f0;
      }
   } else if(BoardInfo->mode == 16){
      if(BoardInfo->parallels == 1){
         pW_CFIFlashDev->enableCFIQuery = 0xff00;
      }else if(BoardInfo->parallels == 2){
         pDW_CFIFlashDev->enableCFIQuery = 0xff00ff00;
      }
   }
   return;
}



/*
 ********************************************************
 * This function retrieves Primary Vendor Command Set ID
 * TODO: OPTIMIZE THE IMPLEMENTATION HERE!!
 ********************************************************
 */
unsigned int CFIGetPriVendCmdSetId(unsigned int Base, FlashBoardCfgInfo_t *BoardInfo, unsigned int *CmdId)
{
   unsigned int AddressMultiplier, busWidth;

	if(CmdId == 0)
		return(1);


	/* validate board-configuration */
	if(ValidateCFIBoardCfg(BoardInfo)!= 0)
		return(2);

	/* obtain address multiplier */
	AddressMultiplier = GetCFICfgAddressMultiplier(BoardInfo);
	if(AddressMultiplier == 0)
		return(3);
        busWidth = GetCFICfgFlashBusWidth(BoardInfo);

	/* Issue a CFI Query */
	IssueCFIQueryEnter(Base, BoardInfo);

	/* flush data-cache */
	MicoFlushDataCache();

	*CmdId = CFI_READ_BYTE(busWidth, 
                               (Base + (CFI_PRIM_CMDSET_LSB*AddressMultiplier)));

	/* Issue a CFI Query exit*/
	IssueCFIQueryExit(Base, BoardInfo);

	return(0);
}


/*
 *****************************************************
 *
 * This function fetches CFI programming information
 * TODO: OPTIMIZE THE IMPLEMENTATION HERE!!
 *
 *****************************************************
 */
unsigned int CFIGetPrgInfo(unsigned int Base, FlashBoardCfgInfo_t *BoardInfo, FlashProgramInfo_t *FlashProgramInfo)
{
	unsigned int AddressMultiplier, busWidth;
	unsigned int cValue;
	unsigned int iValue;
	unsigned int iTemp;

	if(FlashProgramInfo == 0)
		return(1);

	/*
	 * Initialize return-parameters
	 */
	FlashProgramInfo->minVccMilliVolts = 0;
	FlashProgramInfo->maxVccMilliVolts = 0;
	FlashProgramInfo->minVppSupplyMilliVolts = 0;
	FlashProgramInfo->maxVppSupplyMilliVolts = 0;
	FlashProgramInfo->maxWordWriteTOMicroSecs = 0;
	FlashProgramInfo->maxBufferWriteTOMicroSecs = 0;
	FlashProgramInfo->maxBlockEraseTOMilliSecs = 0;
	FlashProgramInfo->maxChipEraseTOMilliSecs = 0;


	/* validate board-configuration */
	if(ValidateCFIBoardCfg(BoardInfo)!= 0)
		return(2);


	/* obtain address multiplier */
	AddressMultiplier = GetCFICfgAddressMultiplier(BoardInfo);
	if(AddressMultiplier == 0)
		return(3);
        busWidth = GetCFICfgFlashBusWidth(BoardInfo);

	/* Issue a CFI Query */
	IssueCFIQueryEnter(Base, BoardInfo);


	/* flush data-cache */
	MicoFlushDataCache();


	/*
	 * Read min Vcc voltage (milliVolts)
	 */
	cValue = CFI_READ_BYTE(busWidth,Base + (CFI_MIN_VCC * AddressMultiplier));
	iValue = (cValue & 0x0f)*100;
	iTemp = ((cValue >> 4)&0x0f)*1000;
	FlashProgramInfo->minVccMilliVolts = (iValue + iTemp);


	/*
	 * Read max Vcc Logic Supply voltage (millvolts)
	 */
	cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_MAX_VCC * AddressMultiplier)));
	iValue = (cValue & 0x0f)*100;
	iTemp = ((cValue >> 4)&0x0f)*1000;
	FlashProgramInfo->maxVccMilliVolts = (iValue + iTemp);


	/*
	 * Read min Vpp Program/Erase voltage (millvolts)
	 */
	cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_MIN_VPP * AddressMultiplier)));
	iValue = (cValue & 0x0f)*100;
	iTemp = ((cValue >> 4)&0x0f)*1000;
	FlashProgramInfo->minVppSupplyMilliVolts = (iValue + iTemp);


	/*
	 * Read min Vpp Program/Erase voltage (millvolts)
	 */
	cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_MAX_VPP * AddressMultiplier)));
	iValue = (cValue & 0x0f)*100;
	iTemp = ((cValue >> 4)&0x0f)*1000;
	FlashProgramInfo->maxVppSupplyMilliVolts = (iValue + iTemp);


	/*
	 * Calculate maximum timeout for byte/word write (microseconds)
	 */
	cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_TYP_WORD_TIMEOUT * AddressMultiplier)));
	iTemp = (1 << cValue);
	cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_MAX_WORD_TIMEOUT * AddressMultiplier)));
	iValue = (1 << cValue)*iTemp;
	FlashProgramInfo->maxWordWriteTOMicroSecs = iValue;


	/*
	 * Calculate maximum timeout for a buffer-write (microseconds)
	 */
	cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_TYP_BUFFER_TIMEOUT * AddressMultiplier)));
	if(cValue)
		iTemp = (1 << cValue);
	else
		iTemp = 0;
	cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_MAX_BUFFER_TIMEOUT * AddressMultiplier)));
	iValue = (1 << cValue)*iTemp;
	FlashProgramInfo->maxBufferWriteTOMicroSecs = iValue;	


	/*
	 * Calculate maximum timeout for a block-erase
	 */
	cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_TYP_BLOCK_ERASE_TIMEOUT * AddressMultiplier)));
	iTemp = (1 << cValue);
	cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_MAX_BLOCK_ERASE_TIMEOUT * AddressMultiplier)));
	iValue = (1 << cValue)*iTemp;
	FlashProgramInfo->maxBlockEraseTOMilliSecs = iValue;


	/*
	 * Calculate maximum timeout for a chip-erase 
	 */
	cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_TYP_CHIP_ERASE_TIMEOUT * AddressMultiplier)));
	if(cValue)
		iTemp = (1 << cValue);
	else
		iTemp = 0;
	cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_MAX_CHIP_ERASE_TIMEOUT * AddressMultiplier)));
	iValue = (1 << cValue)*iTemp;
	FlashProgramInfo->maxChipEraseTOMilliSecs = iValue;


	/* Issue a CFI Query exit*/
	IssueCFIQueryExit(Base, BoardInfo);

	return(0);

}


/*
 *************************************************
 * This function fetches CFI flash geometry
 * TODO: OPTIMIZE THE IMPLEMENTATION HERE!!
 *************************************************
 */
unsigned int CFIGetDeviceGeometry(unsigned int Base, FlashBoardCfgInfo_t *BoardInfo, FlashGeometry_t *FlashGeometry)
{
	unsigned int loopVar;
	unsigned int Offset;
	unsigned char cValue;
	unsigned int iValue;
	unsigned int TotalEraseRegions;
	unsigned int AddressMultiplier, busWidth;
	unsigned int EraseBlockSize;
	unsigned int NumEraseBlocks;
	unsigned int ChipSizeInBytes;

	if(FlashGeometry == 0)
		return(1);

	FlashGeometry->maxBufferSizeInBytes = 0;
	FlashGeometry->sizeInBytes = 0;
	FlashGeometry->totalEraseRegions = 0;

	/* validate board-configuration */
	if(ValidateCFIBoardCfg(BoardInfo)!= 0)
		return(2);


	/* obtain address multiplier */
	AddressMultiplier = GetCFICfgAddressMultiplier(BoardInfo);
	if(AddressMultiplier == 0)
		return(3);
        busWidth = GetCFICfgFlashBusWidth(BoardInfo);


	/* Issue a CFI Query */
	IssueCFIQueryEnter(Base, BoardInfo);

	/* flush data-cache */
	MicoFlushDataCache();

	/* interrogate flash-geometry for total erase block regions */
	cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_NUM_ERASE_BLOCK_REGIONS*AddressMultiplier)));
	TotalEraseRegions = cValue;


	/* verify these regions exist */
	Offset = CFI_ERASE_BLOCK_REGION1_1 * AddressMultiplier;
	EraseBlockSize = 0;
	NumEraseBlocks = 0;	
	ChipSizeInBytes = 0;
	FlashGeometry->totalEraseBlocks = 0;
	for(loopVar = 0; loopVar < TotalEraseRegions; loopVar++){

		/* Query num erase-blocks in this region */
		cValue = CFI_READ_BYTE(busWidth,Base + Offset);
		NumEraseBlocks = cValue; 
		Offset += AddressMultiplier;
		cValue = CFI_READ_BYTE(busWidth,Base + Offset);
		iValue = cValue;
		NumEraseBlocks |= (iValue << 8);
		NumEraseBlocks++;

		/* Query erase-block size */
		Offset += AddressMultiplier;
		cValue = CFI_READ_BYTE(busWidth,Base + Offset);
		EraseBlockSize = cValue;
		Offset += AddressMultiplier;
		cValue = CFI_READ_BYTE(busWidth,Base + Offset);
		iValue = cValue;
		EraseBlockSize |= (iValue << 8);
		EraseBlockSize *= 256;

		/* make sure this value is okay */
		if(EraseBlockSize == 0)
			break;

		/* store information */
		if(loopVar < LATTICEMICO32_ERASE_REGIONS_MAX){
			FlashGeometry->eraseRegion[loopVar].blockSize = EraseBlockSize;
			FlashGeometry->eraseRegion[loopVar].eraseBlocks = NumEraseBlocks;
		}

		/* update total chip-size */
		ChipSizeInBytes += (NumEraseBlocks * EraseBlockSize);
		FlashGeometry->totalEraseBlocks += NumEraseBlocks;

                // setup for the next block
		Offset += AddressMultiplier;
	}


	/* update total erase-regions */
	TotalEraseRegions = loopVar;


	/* update flash-geometry */
        cValue = CFI_READ_BYTE(busWidth,(Base + (CFI_MAX_NUM_MULTIBYTE_LSB*AddressMultiplier)));
	FlashGeometry->maxBufferSizeInBytes = (1 << cValue);
	FlashGeometry->sizeInBytes = ChipSizeInBytes;
	FlashGeometry->totalEraseRegions = TotalEraseRegions;

	/* Issue a CFI Query exit*/
	IssueCFIQueryExit(Base, BoardInfo);

	return(0);
}

/********************************* E O F *************************************/
