/****************************************************************************
**
**  Name:  CFICfgIdentifier.c
**
**  Description:
**     The functions in this module attempt to automatically detect
**     how the CFI proms are connected to the processor.  Once the
**     connection method has been determined other routines provide
**     the configuration data on-demand.
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


/*
 * Validates supported board-configurations
 */
unsigned int ValidateCFIBoardCfg(FlashBoardCfgInfo_t *BoardInfo)
{
   if(BoardInfo == 0)
      return(1);

   if((BoardInfo->mode != 8) &&
      (BoardInfo->mode != 16)) {
      return(1);
   }
	
   if((BoardInfo->parallels != 1) &&
      (BoardInfo->parallels != 2) &&
      (BoardInfo->parallels != 4)) {
      return(2);
   }
   return(0);
}


/*
 * Generates mulitplier for supported board-configurations
 */
unsigned int GetCFICfgAddressMultiplier(FlashBoardCfgInfo_t *BoardInfo)
{
   if(BoardInfo == 0)
      return(0);

   switch(BoardInfo->parallels)
      {
      case 1:
         // no this is not an error, the address indexes to a
         // single 8-bit flash are all managed on a word aligned
         // basis.  The same value needs to be returned for 1x16.
         return(2);
         break;
      case 2:
         if(BoardInfo->mode == 8)
            return(4);  // yes 4.  A1 controls physical A0, so the
                        // multiplication scale needs to be 2x larger.
         if(BoardInfo->mode == 16)
            return(4);
         break;
      case 4:
         // 4 x 8bit memories
         return(4);
      default:
         return(0);
         break;
      }
   return(0);
}

unsigned int GetCFICfgFlashBusWidth(FlashBoardCfgInfo_t *BoardInfo)
{
   if(BoardInfo == 0)
      return(0);

   switch(BoardInfo->parallels)
      {
      case 1:
         if (BoardInfo->mode == 8)
            return(1);
         if (BoardInfo->mode == 16)
            return(2);
         break;
      case 2:
         if(BoardInfo->mode == 8)
            return(2);
         if(BoardInfo->mode == 16)
            return(4);
         break;
      case 4:
         if (BoardInfo->mode == 8)
            return(4);
      default:
         return(0);
         break;
      }
   return(0);
}


/*
 * this function uses basic heuristics to determine if there are flash-devices in
 * parallel and what mode they're operating in.
 */
unsigned int CFIIdentifyConfiguration(unsigned int Base, FlashBoardCfgInfo_t *BoardInfo)
{
   pt_DWORD_ALIGNED_CFI_FLASH pDWA_CFIFlashDev=(pt_DWORD_ALIGNED_CFI_FLASH)Base;
   pt_WORD_ALIGNED_CFI_FLASH pWA_CFIFlashDev=(pt_WORD_ALIGNED_CFI_FLASH)Base;
   if(BoardInfo == 0)
      return(1);

   BoardInfo->parallels = 0;
   BoardInfo->mode = 0;

   /*
    * --------------
    *   Heuristics:
    * --------------
    * The following configurations are supported:
    * - Single 8-bit flash operating in 8-bit mode
    * - Two 8-bit flash parts operating in 8-bit mode i.e. effective bus-width is 16-bits
    * - One 16-bit flash operating in 16-bit mode
    * - Two 16-bit flash parts operating in 16-bit mode i.e. effective bus-width is 32-bits
    * - Four 8-bit flash parts building a 32-bit bus
    */


   /* Query to see if there are four 8-bit flash devices */
   pDWA_CFIFlashDev->enableCFIQuery = CFI_4_8_ENABLE;

   /* flush data-cache */
   MicoFlushDataCache();
        
   /* Read CFI Query */
   if ((pDWA_CFIFlashDev->const_QRY_Q == CFI_4_8_QRY_Q) &&
       (pDWA_CFIFlashDev->const_QRY_R == CFI_4_8_QRY_R) &&
       (pDWA_CFIFlashDev->const_QRY_Y == CFI_4_8_QRY_Y)) {
      BoardInfo->parallels = 4;
      BoardInfo->mode = 8;
      /* exit CFI Query mode */
      pDWA_CFIFlashDev->enableCFIQuery = CFI_4_8_EXIT;
      return(0);
   }
   // disable previous query mode just in case 
   pDWA_CFIFlashDev->enableCFIQuery = CFI_4_8_EXIT;

   /* Query to see if there are two 16-bit flash devices operating in 16-bit mode */
   pDWA_CFIFlashDev->enableCFIQuery = CFI_2_16_ENABLE;

   /* flush data-cache */
   MicoFlushDataCache();
        
   /* Read CFI Query */
   if ((pDWA_CFIFlashDev->const_QRY_Q == CFI_2_16_QRY_Q) &&
       (pDWA_CFIFlashDev->const_QRY_R == CFI_2_16_QRY_R) &&
       (pDWA_CFIFlashDev->const_QRY_Y == CFI_2_16_QRY_Y)) {
      BoardInfo->parallels = 2;
      BoardInfo->mode = 16;
      /* exit CFI Query mode */
      pDWA_CFIFlashDev->enableCFIQuery = CFI_2_16_EXIT;
      return(0);
   }
   // disable previous query mode just in case
   pDWA_CFIFlashDev->enableCFIQuery = CFI_4_8_EXIT;

   // Query to see if this is a 1 x 16-bit memory
   pWA_CFIFlashDev->enableCFIQuery = CFI_1_16_ENABLE;
   /* flush data-cache */
   MicoFlushDataCache();
   if ((pWA_CFIFlashDev->const_QRY_Q == CFI_1_16_QRY_Q) &&
       (pWA_CFIFlashDev->const_QRY_R == CFI_1_16_QRY_R) &&
       (pWA_CFIFlashDev->const_QRY_Y == CFI_1_16_QRY_Y)) {
      BoardInfo->parallels = 1;
      BoardInfo->mode = 16;
      pWA_CFIFlashDev->enableCFIQuery = CFI_1_16_EXIT;
      return(0);
   }
   // disable previous query mode just in case
   pWA_CFIFlashDev->enableCFIQuery = CFI_1_16_EXIT;

   // Query to see if this is a 1 x 8 bit memory.
   pWA_CFIFlashDev->enableCFIQuery = CFI_1_8_ENABLE;
   MicoFlushDataCache();
   if ((pWA_CFIFlashDev->const_QRY_Q == CFI_1_8_QRY_Q) &&
       (pWA_CFIFlashDev->const_QRY_R == CFI_1_8_QRY_R) &&
       (pWA_CFIFlashDev->const_QRY_Y == CFI_1_8_QRY_Y)) {
      BoardInfo->parallels = 1;
      BoardInfo->mode = 8;
      pWA_CFIFlashDev->enableCFIQuery = CFI_1_8_EXIT;
      return(0);
   }
              
   // disable previous query mode just in case
   pWA_CFIFlashDev->enableCFIQuery = CFI_1_8_EXIT;

   // Note: This also tests true for 1x8, so this has to happen
   // AFTER the 1x8 test has taken place.
   pWA_CFIFlashDev->enableCFIQuery = CFI_2_8_ENABLE;
   MicoFlushDataCache();
   // check the remaining elements
   if ((pWA_CFIFlashDev->const_QRY_Q == CFI_2_8_QRY_Q) &&
       (pWA_CFIFlashDev->const_QRY_R == CFI_2_8_QRY_R) &&
       (pWA_CFIFlashDev->const_QRY_Y == CFI_2_8_QRY_Y)) {
      BoardInfo->parallels = 2;
      BoardInfo->mode = 8;
      pDWA_CFIFlashDev->enableCFIQuery = CFI_2_8_EXIT;
      return(0);
   }

   // disable previous query mode just in case
   pDWA_CFIFlashDev->enableCFIQuery = CFI_2_8_EXIT;

   /* end of supported configurations */
   return(2);
}

/********************************* E O F *************************************/
