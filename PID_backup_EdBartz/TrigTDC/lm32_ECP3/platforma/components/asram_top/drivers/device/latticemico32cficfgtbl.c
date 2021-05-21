/****************************************************************************
**
**  Name:  LatticeMico32CFICfgTbl.c
**
**  Description:
**     Initializes the call tables and data structures needed by each
**     different memory configuration.
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

#include "LatticeMico32CFICfgTbl.h"
#include "CFIFlashConfigurations.h"

/****************************
 *                          *
 *     LOCAL DEFINITIONS    *
 *                          *
 ****************************/

/*
********************************************************************
* Table that maintains a list of all possible flash-configurations *
********************************************************************
*/
static FlashConfiguration_st *LatticeMico32FlashCfgs[] = 
   {&AmdSCS_2_16_16,
    &AmdSCS_1_16_16,
    &AmdSCS_2_8_8,
    &AmdSCS_1_8_8,
    &AmdSCS_4_8_8,
    0};

static const int TOTAL_FLASH_CONFIGURATIONS = ((sizeof(LatticeMico32FlashCfgs)/
                                                sizeof(FlashConfiguration_st *))-1);

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

void LatticeMico32InitializeFlashCfgTable(void)
{
   static int iInitialized = 0;
   if (!iInitialized) {
      Register_AmdSCS_2_16_16_Configuration();
      Register_AmdSCS_1_16_16_Configuration();
      Register_AmdSCS_1_8_8_Configuration();
      Register_AmdSCS_2_8_8_Configuration();
      Register_AmdSCS_4_8_8_Configuration();
      iInitialized = 1;
   }

   return;
}

unsigned int LatticeMico32GetTotalFlashCfgs( void )
{
   return(TOTAL_FLASH_CONFIGURATIONS);
}


FlashConfiguration_st *const LatticeMico32GetFlashCfg( unsigned int index )
{
   if(index >= TOTAL_FLASH_CONFIGURATIONS)
      return ((FlashConfiguration_st *const)0);

   return(LatticeMico32FlashCfgs[index]);
}

/********************************* E O F *************************************/
