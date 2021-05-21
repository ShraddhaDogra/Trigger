/****************************************************************************
 **
 **  Name:  LatticeMico32CFI.h
 **
 **  Description:
 **     General purpose FLASH device component data structures.
 **     FLASH programming function call table information.
 **     Error code definitions.
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
#ifndef LATTICEMICO32CFI_H_
#define LATTICEMICO32CFI_H_

/****************************
 *                          *
 *       INCLUDE FILES      *
 *                          *
 ****************************/

#include "CFIRoutines.h"
#include "CFIInfo_t.h"
#include "DDStructs.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

   /****************************
    *                          *
    *      DEFINITIONS         *
    *                          *
    ****************************/

#ifndef CFIFlashDevCtx_t_DEFINED
   typedef struct st_CFIFlashDevCtx_t{
      const char * name;
      unsigned int base;
      unsigned int byteSize;
      unsigned int end;
      void       * cfgFnTbl;
      CFIInfo_t    CFIInfo;
      void       * prev;
      void       * next;
   }CFIFlashDevCtx_t;
#endif

   /* ERROR RETURNS */
#define MICOCFIFLASH_ERR_INVALID_ARGUMENT                (0x81)
#define MICOFLASH_ERR_UNIDENTIFIED_CFG                   (0x82)
#define MICOFLASH_ERR_UNDEFINED_FUNCTION                 (0x83)
#define MICOFLASH_ERR_ERASED                             (0x84)
#define MICOFLASH_ERR_ERASE_FAIL                         (0x85)
#define MICOFLASH_ERR_OFFSET_ALIGN                       (0x86)
#define MICOFLASH_ERR_DATA_MULTIPLE                      (0x87)
#define MICOFLASH_ERR_OFFSET_OUT_OF_RANGE                (0x88)
#define MICOFLASH_ERR_WRITE                              (0x89)
#define MICOFLASH_ERR_ERASE_SECTOR                       (0x90)

/****************************
 *                          *
 *    EXTERNAL VARIABLES    *
 *                          *
 ****************************/

/****************************
 *                          *
 *  FUNCTION PROTOTYPES     *
 *                          *
 ****************************/

   /**********************************************
    * flash configuration-specific information   *
    * Used by CFI routines for cfi read/writes,  *
    * these routines modify the generic r/w req  *
    * for the specific board-layout.             *
    * -------------------------------------------*/
   typedef struct st_FlashCfgFnTbl {
      void         (*Init)        (CFIFlashDevCtx_t *);
      unsigned int (*ProgramData) (CFIFlashDevCtx_t *, unsigned int ByteOffset, unsigned char *, unsigned int);
      unsigned int (*SectorInfo)  (CFIFlashDevCtx_t *, unsigned int ByteOffset, unsigned int *SAddr, unsigned int *ByteLen);
      unsigned int (*WriteData)   (CFIFlashDevCtx_t *, unsigned int ByteOffset, unsigned char *, unsigned int);
      unsigned int (*WriteData8)  (CFIFlashDevCtx_t *, unsigned int ByteOffset, unsigned char);
      unsigned int (*WriteData16) (CFIFlashDevCtx_t *, unsigned int ByteOffset, unsigned short int);
      unsigned int (*WriteData32) (CFIFlashDevCtx_t *, unsigned int ByteOffset, unsigned int);
      unsigned int (*EraseChip)   (CFIFlashDevCtx_t *);
      unsigned int (*EraseSector) (CFIFlashDevCtx_t *, unsigned int ByteOffset);
      unsigned int (*Reset)       (CFIFlashDevCtx_t *);
   }FlashCfgFnTbl_t;


/****************************************************************************
**
**  LatticeMico32InitCFIFlashDriver
**
**  Description: Initializes the device pointed to by the "ctx" var
**
**    Inputs:
**       ctx:  FLASH memory context pointer
**
**    Outputs:
**       None:
** 
**    Return values:
**       None:
** 
*****************************************************************************/
   void LatticeMico32InitCFIFlashDriver(CFIFlashDevCtx_t *ctx);

/****************************************************************************
**
**  LatticeMico32CFIFlashReset
**
**  Description: Issues a flash-reset command.
**
**    Inputs:
**       ctx:  Pointer to flash-device instance-specific information
**
**    Outputs:
**       None:
** 
**    Return values:
**       0 if successful else encountered an error.                 
**       Wellknown errors:                                          
**       MICOFLASH_ERR_UNIDENTIFIED_CFG: if configuration is not    
**           supported.                                             
**       MICOFLASH_ERR_UNDEFINED_FUNCTION: operation not supported  
**           for the identified configuration.                      
**       MICOCFIFLASH_ERR_INVALID_ARGUMENT: context pointer is null.
** 
*****************************************************************************/
   unsigned int LatticeMico32CFIFlashReset(CFIFlashDevCtx_t *ctx);

/****************************************************************************
**
**  LatticeMico32CFIFlashProgramData
**
**  Description: Programs flash data (erases and then writes affected sectors)
**
**    Inputs:
**       ctx:  Pointer to flash-device instance-specific information
**       ByteOffset: linear offset within the flash memory range to
**                   program the data 
**       pData: pointer to a buffer of data
**       bytes: number of bytes to program
**
**    Outputs:
**       None:
** 
**    Return values:
**       0 if successful else encountered an error.                 
**       Wellknown errors:                                          
**       MICOFLASH_ERR_UNIDENTIFIED_CFG: if configuration is not    
**           supported.                                             
**       MICOFLASH_ERR_UNDEFINED_FUNCTION: operation not supported  
**           for the identified configuration.                      
**       MICOCFIFLASH_ERR_INVALID_ARGUMENT: context pointer is null.
** 
*****************************************************************************/
   unsigned int LatticeMico32CFIFlashProgramData(CFIFlashDevCtx_t *, 
                                                 unsigned int ByteOffset, 
                                                 unsigned char *pData, 
                                                 unsigned int bytes);

/****************************************************************************
**
**  LatticeMico32CFIFlashSectorInfo
**
**  Description: Fetches the following sector information:
**                 - starting offset of the sector        
**                 - length of the sector in bytes.
**
**    Inputs:
**       ctx:  Pointer to flash-device instance-specific information
**       ByteOffset: linear offset within the flash memory range to
**                   program the data 
**       SAddr: pointer that will conatint the starting address of the
**              sector containing the ByteOffset
**       ByteLen: pointer that will contain the length of the sector
**                (in bytes).
**
**    Outputs:
**       None:
** 
**    Return values:
**       0 if successful else encountered an error.                 
**       Wellknown errors:                                          
**       MICOFLASH_ERR_UNIDENTIFIED_CFG: if configuration is not    
**           supported.                                             
**       MICOFLASH_ERR_UNDEFINED_FUNCTION: operation not supported  
**           for the identified configuration.                      
**       MICOCFIFLASH_ERR_INVALID_ARGUMENT: context pointer is null.
** 
*****************************************************************************/
   unsigned int LatticeMico32CFIFlashSectorInfo(CFIFlashDevCtx_t *, 
                                                unsigned int ByteOffset,
                                                unsigned int *SAddr, 
                                                unsigned int *ByteLen);

/****************************************************************************
**
**  LatticeMico32CFIFlashEraseBlock
**
**  Description: Erases a block containing the supplied offset (byte-offset)
**
**    Inputs:
**       ctx:  Pointer to flash-device instance-specific information
**       ByteOffset: Offset from the base address of the FLASH.  The
**                   base address is defined inside the ctx parameter.
**
**    Outputs:
**       None:
** 
**    Return values:
**       0 if successful else encountered an error.                 
**       Wellknown errors:                                          
**       MICOFLASH_ERR_UNIDENTIFIED_CFG: if configuration is not    
**           supported.                                             
**       MICOFLASH_ERR_UNDEFINED_FUNCTION: operation not supported  
**           for the identified configuration.                      
**       MICOCFIFLASH_ERR_INVALID_ARGUMENT: context pointer is null.
** 
*****************************************************************************/
   unsigned int LatticeMico32CFIFlashEraseBlock(CFIFlashDevCtx_t *, 
                                                unsigned int ByteOffset);

/****************************************************************************
**
**  LatticeMico32CFIFlashEraseDevice
**
**  Description: Initializes the device pointed to by the "ctx" var
**
**    Inputs:
**       ctx:  Pointer to flash-device instance-specific information
**
**    Outputs:
**       None:
** 
**    Return values:
**       0 if successful else encountered an error.                 
**       Wellknown errors:                                          
**       MICOFLASH_ERR_UNIDENTIFIED_CFG: if configuration is not    
**           supported.                                             
**       MICOFLASH_ERR_UNDEFINED_FUNCTION: operation not supported  
**           for the identified configuration.                      
**       MICOCFIFLASH_ERR_INVALID_ARGUMENT: context pointer is null.
** 
*****************************************************************************/
   unsigned int LatticeMico32CFIFlashEraseDevice(CFIFlashDevCtx_t *ctx);

/****************************************************************************
**
**  LatticeMico32CFIFlashWriteXX
**
**  Description: Programs data to the flash device; assumes that the blocks to
**               which data's being written is already erased.
**
**    Inputs:
**       ctx:  Pointer to flash-device instance-specific information
**       ByteOffset: Offset from the base address (ctx) to write the
**                   data                                            
**
**       Data: the value to be written to the FLASH
**
**    Outputs:
**       None:
** 
**    Return values:
**       0 if successful else encountered an error.                 
**       Wellknown errors:                                          
**       MICOFLASH_ERR_UNIDENTIFIED_CFG: if configuration is not    
**           supported.                                             
**       MICOFLASH_ERR_UNDEFINED_FUNCTION: operation not supported  
**           for the identified configuration.                      
**       MICOCFIFLASH_ERR_INVALID_ARGUMENT: context pointer is null.
** 
*****************************************************************************/
   unsigned int LatticeMico32CFIFlashWrite32(CFIFlashDevCtx_t *ctx, 
                                             unsigned int ByteOffset, 
                                             unsigned int Data);
   unsigned int LatticeMico32CFIFlashWrite16(CFIFlashDevCtx_t *ctx, 
                                             unsigned int ByteOffset, 
                                             unsigned short int Data);
   unsigned int LatticeMico32CFIFlashWrite8(CFIFlashDevCtx_t *ctx, 
                                            unsigned int ByteOffset, 
                                            unsigned char Data);

/****************************************************************************
**
**  LatticeMico32CFIFlashWrite
**
**  Description: Programs a block of data with Bytes worth of bytes at the
**               provided byte offset.
**
**    Inputs:
**       ctx:  Pointer to flash-device instance-specific information
**       ByteOffset: Offset from the base address (ctx) to write the
**                   data
**       Data: Pointer to a byte aligned buffer of data
**       Bytes: Number of bytes to program
**
**    Outputs:
**       None:
** 
**    Return values:
**       0 if successful else encountered an error.                 
**       Wellknown errors:                                          
**       MICOFLASH_ERR_UNIDENTIFIED_CFG: if configuration is not    
**           supported.                                             
**       MICOFLASH_ERR_UNDEFINED_FUNCTION: operation not supported  
**           for the identified configuration.                      
**       MICOCFIFLASH_ERR_INVALID_ARGUMENT: context pointer is null.
** 
*****************************************************************************/
   unsigned int LatticeMico32CFIFlashWrite(CFIFlashDevCtx_t *ctx,
                                           unsigned int ByteOffset,
                                           unsigned char *Data,
                                           unsigned int Bytes);


#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif /*LATTICEMICO32CFI_H_*/

/********************************* E O F *************************************/
