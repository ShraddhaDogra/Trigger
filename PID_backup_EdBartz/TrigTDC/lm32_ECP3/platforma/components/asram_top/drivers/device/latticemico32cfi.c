/****************************************************************************
 **
 **  Name:  LatticeMico32CFI.c
 **
 **  Description:
 **     Performs all of the erase/program/verify functions using
 **     general purpose functions that call the architecture specific
 **     functions via the run-time initialized call table.
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

#include "CFICfgIdentifier.h"
#include "LatticeMico32CFI.h"
#include "LatticeMico32CFICfgTbl.h"
#include "LatticeMico32.h"
#include "MicoCFIFlashService.h"

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


/* 
 * This function is responsible for attempting to 
 * initialize the flash-device's parameters.
 * Reason for seperating this portion from the 
 * flash-device initialization routine is, it gets
 * called only if the application's attempting ot use
 * the flash-device for write/erase functionality.
 * OTherwise, for read-purposes, the CFI functions 
 * don't get pulled-in and therefore reduces penalty
 * on code-size.
 */
static void LatticeMico32InitCFIParams(CFIFlashDevCtx_t *ctx)
{
   int loopVar, numConfigurations;
   unsigned int CmdSetId;
   FlashConfiguration_st *pFlashCfg;

   /*********************************************************
    * IF CONFIGURATION-TABLE POINTER IS NOT NULL,
    * ASSUME THE TABLE IS INITIALIZED:
    * NOTE: THIS WAS SET TO ZERO AS PART OF THE FLASH-DEVICE
    * INIITIALIZATION
    *********************************************************/
   if(ctx->cfgFnTbl != 0){
      return;
   }
   /*
    * Identify CFI Flash Configuration
    */
   if(CFIIdentifyConfiguration(ctx->base, &(ctx->CFIInfo.boardCfg)) != 0){
      /* Not a supported CFI configuration */
      ctx->cfgFnTbl = 0;
      return;
   }

   /* retrieve other CFI information */
   if(CFIGetPrgInfo(ctx->base, &(ctx->CFIInfo.boardCfg), &(ctx->CFIInfo.progInfo)) != 0){
      /* failed to get programming information */
      ctx->cfgFnTbl = 0;
      return;
   }

   if(CFIGetDeviceGeometry(ctx->base, &(ctx->CFIInfo.boardCfg), &(ctx->CFIInfo.geometry)) != 0){
      ctx->cfgFnTbl = 0;
      return;
   }


   /*
    * Fetch CommandSet Id
    */
   if(CFIGetPriVendCmdSetId(ctx->base, &(ctx->CFIInfo.boardCfg), &CmdSetId)!= 0){
      ctx->cfgFnTbl = 0;
      return;
   }

   /*
    * Identify supported flash-function routines table
    */
   LatticeMico32InitializeFlashCfgTable();
   numConfigurations = LatticeMico32GetTotalFlashCfgs();
   for(loopVar = 0; loopVar < numConfigurations; loopVar++){
      pFlashCfg = LatticeMico32GetFlashCfg(loopVar);
      if(pFlashCfg && pFlashCfg->boardInfo){
         if(
            (pFlashCfg->VendorCSId == CmdSetId) &&
            (pFlashCfg->boardInfo->mode == ctx->CFIInfo.boardCfg.mode) &&
            (pFlashCfg->boardInfo->parallels == ctx->CFIInfo.boardCfg.parallels))
            {
               ctx->cfgFnTbl = (void *)(pFlashCfg->cfgFnTbl);

               /* if an init routine exists, allow the configuration to init for this context */
               if(pFlashCfg->cfgFnTbl->Init){
                  pFlashCfg->cfgFnTbl->Init(ctx);
               }
               return;
            }
      }
   } 
}

/*
*************************************************************
* CFI Flash device-driver initialization:                   *
* - initialize default values                               *
* - identify configuration for the flash-region             *
* - register as available flash-region                      *
*************************************************************
*/
void LatticeMico32InitCFIFlashDriver(CFIFlashDevCtx_t *ctx)
{

   if(ctx == 0)
      return;

   /* compute end address (base + size) */
   ctx->end = ctx->base + ctx->byteSize;


/*
*****************************************************************
*
* Register this flash-region as an available flash-region
*
*****************************************************************
*/
   /* register this timer for lookup service */
   ctx->lookupReg.name = ctx->name;
   ctx->lookupReg.deviceType = "CFIFlashDevice";
   ctx->lookupReg.priv = ctx;
   MicoRegisterDevice( &(ctx->lookupReg) );


/*
***********************************************
*
* Reset configuration-table pointer
*
***********************************************
*/
   ctx->cfgFnTbl = 0;

   return;
}

/* erase block identified by byte-offset */
unsigned int LatticeMico32CFIFlashEraseBlock(CFIFlashDevCtx_t *ctx , unsigned int ByteOffset)
{
   FlashCfgFnTbl_t *pFnTbl;

   /* check parameters before invoking function */
   if(ctx == 0)
      return(MICOCFIFLASH_ERR_INVALID_ARGUMENT);

   /* initialize flash-device's CFI parameters */
   LatticeMico32InitCFIParams(ctx);

   if(ctx->cfgFnTbl ==  0)
      return(MICOFLASH_ERR_UNIDENTIFIED_CFG);

   pFnTbl = (FlashCfgFnTbl_t *)ctx->cfgFnTbl;

   if(pFnTbl->EraseSector == 0)
      return(MICOFLASH_ERR_UNDEFINED_FUNCTION);

   /* erase a block identified by byteoffset */
   return(pFnTbl->EraseSector(ctx, ByteOffset));
}

/* Invoke chip-reset function */
unsigned int LatticeMico32CFIFlashReset(CFIFlashDevCtx_t *ctx)
{
   FlashCfgFnTbl_t *pFnTbl;

   /* check parameters before invoking reset function */
   if(ctx == 0)
      return(MICOCFIFLASH_ERR_INVALID_ARGUMENT);

   /* initialize flash-device's CFI parameters */
   LatticeMico32InitCFIParams(ctx);

   if(ctx->cfgFnTbl ==  0)
      return(MICOFLASH_ERR_UNIDENTIFIED_CFG);

   pFnTbl = (FlashCfgFnTbl_t *)ctx->cfgFnTbl;

   if(pFnTbl->Reset == 0)
      return(MICOFLASH_ERR_UNDEFINED_FUNCTION);

   return(pFnTbl->Reset(ctx));
}

/* Invoke erase-chip function */
unsigned int LatticeMico32CFIFlashEraseDevice(CFIFlashDevCtx_t *ctx)
{
   FlashCfgFnTbl_t *pFnTbl;

   /* check parameters */
   if(ctx == 0)
      return(MICOCFIFLASH_ERR_INVALID_ARGUMENT);

   /* initialize flash-device's CFI parameters */
   LatticeMico32InitCFIParams(ctx);

   /* make sure region's identified and its table is populated */
   if(ctx->cfgFnTbl ==  0)
      return(MICOFLASH_ERR_UNIDENTIFIED_CFG);

   pFnTbl = (FlashCfgFnTbl_t *)ctx->cfgFnTbl;

   /* make sure the flash erase-region function is defined for this configuration */
   if(pFnTbl->EraseChip == 0)
      return(MICOFLASH_ERR_UNDEFINED_FUNCTION);

   return(pFnTbl->EraseChip(ctx));
}

/* write 32-bits to an offset within the flash */
unsigned int
LatticeMico32CFIFlashWrite32(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset, unsigned int Data)
{
   FlashCfgFnTbl_t *pFnTbl;

   /* check parameters */
   if(ctx == 0)
      return(MICOCFIFLASH_ERR_INVALID_ARGUMENT);

   /* initialize flash-device's CFI parameters */
   LatticeMico32InitCFIParams(ctx);

   /* make sure region's identified and its table is populated */
   if(ctx->cfgFnTbl == 0)
      return(MICOFLASH_ERR_UNIDENTIFIED_CFG);

   pFnTbl = (FlashCfgFnTbl_t *)ctx->cfgFnTbl;

   /* make sure the flash-program (32-bits) function is defined for this configuration */
   if(pFnTbl->WriteData32 == 0)
      return(MICOFLASH_ERR_UNDEFINED_FUNCTION);

   return(pFnTbl->WriteData32(ctx, ByteOffset, Data));
}

/* write 16-bits to an offset within the flash region */
unsigned int
LatticeMico32CFIFlashWrite16(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset, unsigned short int Data)
{
   FlashCfgFnTbl_t *pFnTbl;

   /* check parameters */
   if(ctx == 0)
      return(MICOCFIFLASH_ERR_INVALID_ARGUMENT);

   /* initialize flash-device's CFI parameters */
   LatticeMico32InitCFIParams(ctx);

   /* make sure region's identified and its table is populated */
   if(ctx->cfgFnTbl == 0)
      return(MICOFLASH_ERR_UNIDENTIFIED_CFG);

   pFnTbl = (FlashCfgFnTbl_t *)ctx->cfgFnTbl;

   /* make sure the flash-program function is defined for this configuration */
   if(pFnTbl->WriteData16 == 0)
      return(MICOFLASH_ERR_UNDEFINED_FUNCTION);

   return(pFnTbl->WriteData16(ctx, ByteOffset, Data));
}

/* write 8-bits to an offset within the flash region */
unsigned int
LatticeMico32CFIFlashWrite8(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset, unsigned char Data)
{
   FlashCfgFnTbl_t *pFnTbl;

   /* check parameters */
   if(ctx == 0)
      return(MICOCFIFLASH_ERR_INVALID_ARGUMENT);

   /* initialize flash-device's CFI parameters */
   LatticeMico32InitCFIParams(ctx);

   /* make sure region's identified and its table is populated */
   if(ctx->cfgFnTbl == 0)
      return(MICOFLASH_ERR_UNIDENTIFIED_CFG);

   pFnTbl = (FlashCfgFnTbl_t *)ctx->cfgFnTbl;

   /* make sure the flash-program function is defined for this configuration */
   if(pFnTbl->WriteData8 == 0)
      return(MICOFLASH_ERR_UNDEFINED_FUNCTION);

   return(pFnTbl->WriteData8(ctx, ByteOffset, Data));
}

/* write a block of data within the flash-region */
unsigned int
LatticeMico32CFIFlashWrite(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset, unsigned char *Data, unsigned int Bytes)
{
   FlashCfgFnTbl_t *pFnTbl;

   /* check parameters */
   if((ctx == 0) || (Data == 0) || (Bytes == 0))
      return(MICOCFIFLASH_ERR_INVALID_ARGUMENT);

   /* initialize flash-device's CFI parameters */
   LatticeMico32InitCFIParams(ctx);

   /* make sure region's identified and its table is populated */
   if(ctx->cfgFnTbl == 0)
      return(MICOFLASH_ERR_UNIDENTIFIED_CFG);

   pFnTbl = (FlashCfgFnTbl_t *)ctx->cfgFnTbl;

   /* make sure the flash-program function is defined for this configuration */
   if(pFnTbl->WriteData == 0)
      return(MICOFLASH_ERR_UNDEFINED_FUNCTION);

   return(pFnTbl->WriteData(ctx, ByteOffset, Data, Bytes));
}

/* Program a block of data (erase/write) within the flash-region */
unsigned int LatticeMico32CFIFlashProgramData(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset, unsigned char *Data, unsigned int Bytes)
{
   FlashCfgFnTbl_t *pFnTbl;

   /* check parameters */
   if((ctx == 0) || (Data == 0) || (Bytes == 0))
      return(MICOCFIFLASH_ERR_INVALID_ARGUMENT);

   /* initialize flash-device's CFI parameters */
   LatticeMico32InitCFIParams(ctx);

   /* make sure region's identified and its table is populated */
   if(ctx->cfgFnTbl == 0)
      return(MICOFLASH_ERR_UNIDENTIFIED_CFG);

   pFnTbl = (FlashCfgFnTbl_t *)ctx->cfgFnTbl;

   /* make sure the flash-program function is defined for this configuration */
   if(pFnTbl->ProgramData == 0)
      return(MICOFLASH_ERR_UNDEFINED_FUNCTION);

   return(pFnTbl->ProgramData(ctx, ByteOffset, Data, Bytes));
}

/* obtain flash-sector information that contains the desired offset */
unsigned int LatticeMico32CFIFlashSectorInfo(CFIFlashDevCtx_t *ctx, unsigned int ByteOffset, unsigned int *pSAddr, unsigned int *pByteLen)
{
   FlashCfgFnTbl_t *pFnTbl;

   if((ctx == 0) || (pSAddr == 0) || (pByteLen == 0))
      return(MICOCFIFLASH_ERR_INVALID_ARGUMENT);

   /* initialize flash-device's CFI parameters */
   LatticeMico32InitCFIParams(ctx);

   /* make sure region's identified and its table is populated */
   if(ctx->cfgFnTbl == 0)
      return(MICOFLASH_ERR_UNIDENTIFIED_CFG);

   pFnTbl = (FlashCfgFnTbl_t *)ctx->cfgFnTbl;

   /* make sure the flash-program function is defined for this configuration */
   if(pFnTbl->SectorInfo == 0)
      return(MICOFLASH_ERR_UNDEFINED_FUNCTION);

   return(pFnTbl->SectorInfo(ctx, ByteOffset, pSAddr, pByteLen));
}

/********************************* E O F *************************************/
