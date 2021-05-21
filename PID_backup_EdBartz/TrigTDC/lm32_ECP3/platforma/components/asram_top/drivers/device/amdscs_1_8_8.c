/****************************************************************************
**
**  Name:  AmdSCS_1_8_8.c
**
**  Description:
**     Performs all of the erase and programming functions for a
**     SPANSION CFI FLASH in a 1 x 8-bit configuration
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

#include "CFIFlashConfigurations.h"
#include "CFIRoutines.h"
#include "LatticeMico32CFI.h"
#include "LatticeMico32CFICfgTbl.h"
#include "LatticeMico32.h"
#include "MicoUtils.h"
#include "CFICfgIdentifier.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/****************************
 *                          *
 *     LOCAL DEFINITIONS    *
 *                          *
 ****************************/

   static FlashBoardCfgInfo_t AmdSCS_1_8_8Info;
   static FlashCfgFnTbl_t AmdSCS_1_8_8FnTbl;
   FlashConfiguration_st AmdSCS_1_8_8;

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

   static void AmdSCS_1_8_8_Init(CFIFlashDevCtx_t *ctx);
   static unsigned int AmdSCS_1_8_8_Reset(CFIFlashDevCtx_t *ctx);
   static unsigned int AmdSCS_1_8_8_ProgramData(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset, unsigned char *Data, unsigned int Bytes);
   static unsigned int AmdSCS_1_8_8_SectorInfo(CFIFlashDevCtx_t *, unsigned int ByteOffset, unsigned int *SAddr, unsigned int *ByteLen);
   static unsigned int AmdSCS_1_8_8_EraseRegion(CFIFlashDevCtx_t *ctx);
   static unsigned int AmdSCS_1_8_8_EraseSector(CFIFlashDevCtx_t *ctx, unsigned int Offset);
   static unsigned int AmdSCS_1_8_8_Write8(CFIFlashDevCtx_t *ctx, unsigned int Offset, unsigned char ucData);
   static unsigned int AmdSCS_1_8_8_WriteData(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset, unsigned char *data, unsigned int Bytes);

#ifdef __cplusplus
}
#endif /* __cplusplus */



/*
 * MAIN CONFIGURATION-REGISTRATION FUNCTION
 */
unsigned int Register_AmdSCS_1_8_8_Configuration(void) {

   /*
    *----------------------------------------------
    * Define flash-configuration information
    *----------------------------------------------
    */
   AmdSCS_1_8_8Info.parallels = 1;
   AmdSCS_1_8_8Info.mode = 8;

   /*
    *----------------------------------------------
    * Setup function pointer table
    *----------------------------------------------
    */
   AmdSCS_1_8_8FnTbl.Init          = AmdSCS_1_8_8_Init;
   AmdSCS_1_8_8FnTbl.WriteData     = AmdSCS_1_8_8_WriteData;
   AmdSCS_1_8_8FnTbl.WriteData8    = AmdSCS_1_8_8_Write8;
   AmdSCS_1_8_8FnTbl.WriteData16   = 0;
   AmdSCS_1_8_8FnTbl.WriteData32   = 0;
   AmdSCS_1_8_8FnTbl.EraseChip     = AmdSCS_1_8_8_EraseRegion;
   AmdSCS_1_8_8FnTbl.EraseSector   = AmdSCS_1_8_8_EraseSector;
   AmdSCS_1_8_8FnTbl.Reset         = AmdSCS_1_8_8_Reset;
   AmdSCS_1_8_8FnTbl.ProgramData   = AmdSCS_1_8_8_ProgramData;
   AmdSCS_1_8_8FnTbl.SectorInfo    = AmdSCS_1_8_8_SectorInfo;


   /*
    *----------------------------------------------
    * setup configuration table pointers
    *----------------------------------------------
    */
   AmdSCS_1_8_8.VendorCSId =  0x2;       /* AMD/Fujitsu Standard Command Set */
   AmdSCS_1_8_8.boardInfo  =  &AmdSCS_1_8_8Info;
   AmdSCS_1_8_8.cfgFnTbl   =  &AmdSCS_1_8_8FnTbl;

   return(0);
}


/*
 * Resets Flash
 */
static unsigned int AmdSCS_1_8_8_Reset(CFIFlashDevCtx_t *ctx) {

   pt_BYTE_ALIGNED_CFI_FLASH pt_CFIFlashDev = (pt_BYTE_ALIGNED_CFI_FLASH)ctx->base;
   pt_CFIFlashDev->base = CFI_1_8_FF;
   return(0);
}


/*
 * Erases entire flash-region
 */
static unsigned int
AmdSCS_1_8_8_EraseRegion(CFIFlashDevCtx_t *ctx) {

   /* 
    * NOTE: we will not use toggle-bit check as in a multitasking situation,
    * it is possible that this code may not get a chance to run.  Unless
    * interrupts are disabled and this code is the only one active, don't
    * use toggle-bit algorithm.
    * We assume writes to flash are working fine.
    */
   pt_BYTE_ALIGNED_CFI_FLASH pBA_FlashDev = (pt_BYTE_ALIGNED_CFI_FLASH)ctx->base;
   unsigned int TO;

   /* sequence an erase-chip */
   pBA_FlashDev->Addr555 = CFI_1_8_AA;
   pBA_FlashDev->Addr2AA = CFI_1_8_55;
   pBA_FlashDev->Addr555 = CFI_1_8_80;
   pBA_FlashDev->Addr555 = CFI_1_8_AA;
   pBA_FlashDev->Addr2AA = CFI_1_8_55;
   pBA_FlashDev->Addr555 = CFI_1_8_10;

   /* wait for chip-erase to complete */
   TO = 0;
   do{
      /* flush datacache */
      MicoFlushDataCache();

      /* see if the chip's erased successfully */
      if(pBA_FlashDev->base == CFI_1_8_ERASED)
         return(0);

      /*
       * Not yet, wait for a second to elapse (since chip-erase timeouts
       * are specified in terms of seconds
       */
      MicoSleepMilliSecs(ctx->CFIInfo.progInfo.maxBlockEraseTOMilliSecs);
      TO += ctx->CFIInfo.progInfo.maxBlockEraseTOMilliSecs;
      if(TO >= (ctx->CFIInfo.progInfo.maxBlockEraseTOMilliSecs * ctx->CFIInfo.geometry.totalEraseBlocks)) {
         /* failed to erase chip within the specified timeout */
         AmdSCS_1_8_8_Reset(ctx);
         return(MICOFLASH_ERR_ERASE_FAIL);
      }

   }while(1);

   return(0);
}


/*
 * Erase a sector
 */
static unsigned int
AmdSCS_1_8_8_EraseSector(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset) {

   unsigned int maxTOMilliSecs;
   pt_BYTE_ALIGNED_CFI_FLASH pBA_FlashDev = (pt_BYTE_ALIGNED_CFI_FLASH)ctx->base;
   unsigned char *writePtr = (unsigned char *)(ctx->base + ByteOffset);

   /* make sure byte-offset is within the region's range */
   if(ByteOffset >= (ctx->end - ctx->base))
      return(MICOFLASH_ERR_OFFSET_OUT_OF_RANGE);

   /* issue a sector-erase command */
   pBA_FlashDev->Addr555 = CFI_1_8_AA;
   pBA_FlashDev->Addr2AA = CFI_1_8_55;
   pBA_FlashDev->Addr555 = CFI_1_8_80;
   pBA_FlashDev->Addr555 = CFI_1_8_AA;
   pBA_FlashDev->Addr2AA = CFI_1_8_55;

   *writePtr = CFI_1_8_30;

   maxTOMilliSecs = ctx->CFIInfo.progInfo.maxBlockEraseTOMilliSecs;
   if(maxTOMilliSecs == 0)
      maxTOMilliSecs = 1;

   /* Monitor progress */
   do{
      /* wait for a millisecond */
      MicoSleepMilliSecs(1);
      maxTOMilliSecs--;

      /* check status */
      MicoFlushDataCache();
      if(*writePtr  == CFI_1_8_ERASED)
         return(0);

   }while(maxTOMilliSecs > 0);

   return(MICOFLASH_ERR_ERASE_SECTOR);
}


/*
 * writes a block of data; offset must start at a dword boundary and
 * number of bytes to write must be a multiple of 4
 */
static unsigned int
AmdSCS_1_8_8_WriteData(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset, 
                         unsigned char *data, unsigned int Bytes) {

   unsigned char *pucData;
   unsigned int loopVar;
   unsigned int endOffset = ByteOffset + Bytes;

   /* make sure last data-chunk is within the region's range */
   if((ByteOffset + Bytes) >= (ctx->end))
      return(MICOFLASH_ERR_OFFSET_OUT_OF_RANGE);

   /* we're all okay to perform writes : use the 16-bit write function
      to accomplish this */
   pucData = data;
   for(loopVar = ByteOffset; loopVar < endOffset; loopVar++) {
      if(AmdSCS_1_8_8_Write8(ctx, loopVar, *pucData)!= 0)
         return(MICOFLASH_ERR_WRITE);
      pucData++;
   }

   return(0);
}


/*
 * Program a word of data
 */
static unsigned int
AmdSCS_1_8_8_Write8(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset, 
                       unsigned char ucData) {

   pt_BYTE_ALIGNED_CFI_FLASH pBA_FlashDev = (pt_BYTE_ALIGNED_CFI_FLASH)ctx->base;
   unsigned char *writePtr = (unsigned char *)(ctx->base + ByteOffset);

   /*
    * Fetch maximum timeout for writing a word of data; if none is
    * provided, default to 1 millisecond
    */

   unsigned int maxTOMicroSecs = ctx->CFIInfo.progInfo.maxWordWriteTOMicroSecs;
   if(maxTOMicroSecs == 0)
      maxTOMicroSecs = 1000;

   /*
    * write program-sequence
    */
   pBA_FlashDev->Addr555 = CFI_1_8_AA;
   pBA_FlashDev->Addr2AA = CFI_1_8_55;
   pBA_FlashDev->Addr555 = CFI_1_8_A0;

   /*
    * we're ready for writing
    */
   *writePtr = ucData;

   /*
    * Do a status-check to determine completion: keep it simple
    */
   if(maxTOMicroSecs < 10)
      maxTOMicroSecs = 10;
   do{
      MicoFlushDataCache();
      if(*writePtr == ucData)
         return(0);
      MicoSleepMicroSecs(10);
      maxTOMicroSecs -= 10;
   }while(maxTOMicroSecs > 10);

   /*
    * Issue a reset if required
    */
   AmdSCS_1_8_8_Reset(ctx);
   return(MICOFLASH_ERR_WRITE);
}


/* Program a chunk of data */
static unsigned int 
AmdSCS_1_8_8_ProgramData(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset, 
                           unsigned char *Data, unsigned int Bytes) {

   unsigned int sAddr;
   unsigned int byteLen;
   unsigned int retVal;

   /* make sure last data-chunk is within the region's range */
   if((ByteOffset + Bytes) >= (ctx->end))
      return(MICOFLASH_ERR_OFFSET_OUT_OF_RANGE);

   /* start erasing sectors that are gonna be written */
   sAddr = ByteOffset;
   do{
      retVal = AmdSCS_1_8_8_SectorInfo(ctx, sAddr, &sAddr, &byteLen);
      if(retVal != 0)
         return(retVal);
      AmdSCS_1_8_8_EraseSector(ctx, sAddr);
      sAddr += byteLen;
      if(sAddr >= ByteOffset + Bytes)
         break;
   }while(1);

   /* program data from the desired offset */
   retVal = AmdSCS_1_8_8_WriteData(ctx, ByteOffset, Data, Bytes);

   return(retVal);
}


/* Fetch Sector Info */
static unsigned int 
AmdSCS_1_8_8_SectorInfo(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset, 
                          unsigned int *pSAddr, unsigned int *pByteLen) {

   int temp;
   int loopVar1,loopVar2;
   unsigned int eAddr = 0;
   unsigned int sAddr = 0;

   /* fetch information */
   for(loopVar1 = 0; loopVar1 < ctx->CFIInfo.geometry.totalEraseRegions; loopVar1++) {
      for(loopVar2 = 0; loopVar2 < ctx->CFIInfo.geometry.eraseRegion[loopVar1].eraseBlocks; loopVar2++) {
         temp = (ctx->CFIInfo.geometry.eraseRegion[loopVar1].blockSize);
         eAddr += temp;
         if(ByteOffset < eAddr) {
            *pSAddr = sAddr;
            *pByteLen = temp;
            return(0);
         }
         sAddr += temp;
      }
   }

   return(MICOFLASH_ERR_OFFSET_OUT_OF_RANGE);
}


static void AmdSCS_1_8_8_Init(CFIFlashDevCtx_t *ctx) {

   pt_BYTE_ALIGNED_CFI_FLASH pBA_FlashDev = (pt_BYTE_ALIGNED_CFI_FLASH)ctx->base;
   unsigned char ucBoot;
   //unsigned short usValue;
   int loopVar1, loopVar2;
   EraseRegion_t tempER;
        
   /* interrogate CFI-PRI table to figure out if the device is a
      top-boot/bottom-boot device */
   IssueCFIQueryEnter(ctx->base, &(ctx->CFIInfo.boardCfg));

   MicoFlushDataCache();
   ucBoot = CFI_READ_BYTE(1,(ctx->base + 
                             (CFI_WP_PROTECTION*sizeof(unsigned short))));

   /* exit CFI Query mode */
   IssueCFIQueryExit(ctx->base, &(ctx->CFIInfo.boardCfg));


   /* Query manufacturer ID: */
   pBA_FlashDev->Addr555 = CFI_1_8_AA;
   pBA_FlashDev->Addr2AA = CFI_1_8_55;
   pBA_FlashDev->Addr555 = CFI_1_8_90;
   /* flush data-cache */
   MicoFlushDataCache();

   /* 
    * If manufacturer is Macronix, the CFI table isn't correct for
    * MX29LV128M B/T; the CFI table indicates there are two erase regions
    * but returns wrong information indicating there's only one erase-region
    */
   if(pBA_FlashDev->base == CFI_1_8_MXID) {
      /* IF IT's A MX29LV128M DEVICE, USE PRE-DETERMINED DATA */
      if(pBA_FlashDev->base1 == CFI_1_8_MXDEV) {
         /* yup, it's MX29LV128M device, exit automatic mode */  
         AmdSCS_1_8_8_Reset(ctx);

         /* modify information returned by CFI Query as it is incorrect */
         ctx->CFIInfo.geometry.sizeInBytes = MACRONIX_FIXUP_VAL;

         /* check if it's an H/L part or a B/T part */
         if((ucBoot == 2) || (ucBoot == 3)) {
            /* indicate there are two erase regions */
            ctx->CFIInfo.geometry.totalEraseRegions = 2;
            ctx->CFIInfo.geometry.totalEraseBlocks = (255+8);

            /* it's a B/T part */
            if(ucBoot == 2) {
               /* it's a bottom-boot device */
               ctx->CFIInfo.geometry.eraseRegion[0].eraseBlocks = 8;
               ctx->CFIInfo.geometry.eraseRegion[0].blockSize   = 8192;
               ctx->CFIInfo.geometry.eraseRegion[1].eraseBlocks = 255;
               ctx->CFIInfo.geometry.eraseRegion[1].blockSize   = 65536;
            }else{
               /* it's a top-boot device */
               ctx->CFIInfo.geometry.eraseRegion[0].eraseBlocks = 255;
               ctx->CFIInfo.geometry.eraseRegion[0].blockSize = 65536;
               ctx->CFIInfo.geometry.eraseRegion[1].eraseBlocks = 8;
               ctx->CFIInfo.geometry.eraseRegion[1].blockSize = 8192;

            }
         }else{
            /* it's an H/L part, all sectors are uniform of
               64kbytes/sector/device */
            ctx->CFIInfo.geometry.totalEraseRegions = 1;
            ctx->CFIInfo.geometry.eraseRegion[0].eraseBlocks = 256;
            ctx->CFIInfo.geometry.eraseRegion[0].blockSize = 65536;
         }

         return;
      }
   }

   /* exit automatic mode */       
   AmdSCS_1_8_8_Reset(ctx);


   /* based on whether it's a top/bottom boot, rearrange sectors for
      AMD-class devices */
   if(ucBoot == 3) {
      /* it's a top-boot device */
      for(loopVar1 = 0, loopVar2 = ctx->CFIInfo.geometry.totalEraseRegions - 1; 
          loopVar1 < loopVar2;
          loopVar1++, loopVar2--) {
         tempER = ctx->CFIInfo.geometry.eraseRegion[loopVar2];
         ctx->CFIInfo.geometry.eraseRegion[loopVar2] = ctx->CFIInfo.geometry.eraseRegion[loopVar1];
         ctx->CFIInfo.geometry.eraseRegion[loopVar1] = tempER;
      }
   }

   return;
}

/********************************* E O F *************************************/
