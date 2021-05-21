/****************************************************************************
**
**  Name:  CFIFlashConfigurations.h
**
**  Description:
**     Defines all of the intialization functions and external data
**     structures required to program SPANSION FLASH memory devices in
**     various memory configurations.
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
#ifndef CFIFLASHCONFIGURATIONS_H
#define CFIFLASHCONFIGURATIONS_H

#ifdef __cplusplus
extern "C"
{
#endif

/****************************
 *                          *
 *       INCLUDE FILES      *
 *                          *
 ****************************/
#include "LatticeMico32CFICfgTbl.h"

/****************************
 *                          *
 *      DEFINITIONS         *
 *                          *
 ****************************/
#define MACRONIX_FIXUP_VAL (0x100000 * 16) // 16Mb

// Constants for detecting the geometry of the FLASH PROM

#define CFI_1_8_QRY_Q               (0x5100)
#define CFI_1_8_QRY_R               (0x5200)
#define CFI_1_8_QRY_Y               (0x5900)


#define CFI_2_8_QRY_Q               (0x5151)
#define CFI_2_8_QRY_R               (0x5252)
#define CFI_2_8_QRY_Y               (0x5959)


#define CFI_4_8_QRY_Q               (0x51515151)
#define CFI_4_8_QRY_R               (0x52525252)
#define CFI_4_8_QRY_Y               (0x59595959)

#ifdef LM32_BIG_ENDIAN_CONNECTION

#define CFI_1_16_QRY_Q              (0x5100)
#define CFI_1_16_QRY_R              (0x5200)
#define CFI_1_16_QRY_Y              (0x5900)

#define CFI_2_16_QRY_Q              (0x51005100)
#define CFI_2_16_QRY_R              (0x52005200)
#define CFI_2_16_QRY_Y              (0x59005900)

#else

#define CFI_1_16_QRY_Q              (0x0051)
#define CFI_1_16_QRY_R              (0x0052)
#define CFI_1_16_QRY_Y              (0x0059)

#define CFI_2_16_QRY_Q              (0x00510051)
#define CFI_2_16_QRY_R              (0x00520052)
#define CFI_2_16_QRY_Y              (0x00590059)

#endif

// 1x8x8 CFI Command definitions
#define CFI_1_8_10     (0x10)
#define CFI_1_8_30     (0x30)
#define CFI_1_8_55     (0x55)
#define CFI_1_8_80     (0x80)
#define CFI_1_8_90     (0x90)
#define CFI_1_8_ENABLE (0x98)
#define CFI_1_8_A0     (0xa0)
#define CFI_1_8_AA     (0xaa)
#define CFI_1_8_EXIT   (0xf0)
#define CFI_1_8_FF     (0xff)
#define CFI_1_8_MASK   (0xff)
#define CFI_1_8_ERASED (0xff)
#define CFI_1_8_MXID   (0xc2)
#define CFI_1_8_MXDEV  (0x7e)

// 2x8x8 CFI Command definitions
#define CFI_2_8_10     ((unsigned short)0x1010)
#define CFI_2_8_30     ((unsigned short)0x3030)
#define CFI_2_8_55     ((unsigned short)0x5555)
#define CFI_2_8_80     ((unsigned short)0x8080)
#define CFI_2_8_90     ((unsigned short)0x9090)
#define CFI_2_8_ENABLE ((unsigned short)0x9898)
#define CFI_2_8_A0     ((unsigned short)0xa0a0)
#define CFI_2_8_AA     ((unsigned short)0xaaaa)
#define CFI_2_8_EXIT   ((unsigned short)0xf0f0)
#define CFI_2_8_FF     ((unsigned short)0xffff)
#define CFI_2_8_MASK   ((unsigned short)0xffff)
#define CFI_2_8_ERASED ((unsigned short)0xffff)
#define CFI_2_8_MXID   ((unsigned short)0xc2c2)
#define CFI_2_8_MXDEV  ((unsigned short)0x7e7e)

// 4x8x8 CFI Command definitions
#define CFI_4_8_10     (0x10101010)
#define CFI_4_8_30     (0x30303030)
#define CFI_4_8_55     (0x55555555)
#define CFI_4_8_80     (0x80808080)
#define CFI_4_8_90     (0x90909090)
#define CFI_4_8_ENABLE (0x98989898)
#define CFI_4_8_A0     (0xa0a0a0a0)
#define CFI_4_8_AA     (0xaaaaaaaa)
#define CFI_4_8_EXIT   (0xf0f0f0f0)
#define CFI_4_8_FF     (0xffffffff)
#define CFI_4_8_MASK   (0xffffffff)
#define CFI_4_8_ERASED (0xffffffff)
#define CFI_4_8_MXID   (0xc2c2c2c2)
#define CFI_4_8_MXDEV  (0x7e7e7e7e)

#ifdef LM32_BIG_ENDIAN_CONNECTION

// 1x16x16 CFI BE Command definitions
#define CFI_1_16_10     (0x1000)
#define CFI_1_16_30     (0x3000)
#define CFI_1_16_55     (0x5500)
#define CFI_1_16_80     (0x8000)
#define CFI_1_16_90     (0x9000)
#define CFI_1_16_ENABLE (0x9800)
#define CFI_1_16_A0     (0xa000)
#define CFI_1_16_AA     (0xaa00)
#define CFI_1_16_EXIT   (0xf0f0)
#define CFI_1_16_FF     (0xff00)
#define CFI_1_16_MASK   (0xff00)
#define CFI_1_16_ERASED (0xffff)
#define CFI_1_16_MXID   (0xc200)
#define CFI_1_16_MXDEV  (0x7e00)

// 2x16x16 CFI BE Command definitions
#define CFI_2_16_10     (0x10001000)
#define CFI_2_16_30     (0x30003000)
#define CFI_2_16_55     (0x55005500)
#define CFI_2_16_80     (0x80008000)
#define CFI_2_16_90     (0x90009000)
#define CFI_2_16_ENABLE (0x98009800)
#define CFI_2_16_A0     (0xa000a000)
#define CFI_2_16_AA     (0xaa00aa00)
#define CFI_2_16_EXIT   (0xf0f0f0f0)
#define CFI_2_16_FF     (0xff00ff00)
#define CFI_2_16_MASK   (0xff00ff00)
#define CFI_2_16_ERASED (0xffffffff)
#define CFI_2_16_MXID   (0xc200c200)
#define CFI_2_16_MXDEV  (0x7e007e00)

#else

// 1x16x16 CFI LE Command definitions
#define CFI_1_16_10     (0x0010)
#define CFI_1_16_30     (0x0030)
#define CFI_1_16_55     (0x0055)
#define CFI_1_16_80     (0x0080)
#define CFI_1_16_90     (0x0090)
#define CFI_1_16_ENABLE (0x0098)
#define CFI_1_16_A0     (0x00a0)
#define CFI_1_16_AA     (0x00aa)
#define CFI_1_16_EXIT   (0xf0f0)
#define CFI_1_16_FF     (0x00ff)
#define CFI_1_16_MASK   (0x00ff)
#define CFI_1_16_ERASED (0xffff)
#define CFI_1_16_MXID   (0x00c2)
#define CFI_1_16_MXDEV  (0x007e)

// 2x16x16 CFI LE Command definitions
#define CFI_2_16_10     (0x00100010)
#define CFI_2_16_30     (0x00300030)
#define CFI_2_16_55     (0x00550055)
#define CFI_2_16_80     (0x00800080)
#define CFI_2_16_90     (0x00900090)
#define CFI_2_16_ENABLE (0x00980098)
#define CFI_2_16_A0     (0x00a000a0)
#define CFI_2_16_AA     (0x00aa00aa)
#define CFI_2_16_EXIT   (0xf0f0f0f0)
#define CFI_2_16_FF     (0x00ff00ff)
#define CFI_2_16_MASK   (0x00ff00ff)
#define CFI_2_16_ERASED (0xffffffff)
#define CFI_2_16_MXID   (0x00c200c2)
#define CFI_2_16_MXDEV  (0x007e007e)

#endif

/****************************
 *                          *
 *    EXTERNAL VARIABLES    *
 *                          *
 ****************************/

   extern FlashConfiguration_st AmdSCS_1_8_8;
   extern FlashConfiguration_st AmdSCS_2_8_8;
   extern FlashConfiguration_st AmdSCS_4_8_8;
   extern FlashConfiguration_st AmdSCS_1_16_16;
   extern FlashConfiguration_st AmdSCS_2_16_16;

/****************************
 *                          *
 *  FUNCTION PROTOTYPES     *
 *                          *
 ****************************/

/****************************************************************************
**
**  Register_AmdSCS_2_16_16_Configuration
**
**  Description: Initializes the function call table for a 2 x 16-bit
**               AMD FLASH memory
**
**    Inputs:
**       none:
** 
**    Outputs:
**       none:
** 
**    Return values:
**       0: Success
** 
*****************************************************************************/
   unsigned int Register_AmdSCS_2_16_16_Configuration(void);

/****************************************************************************
**
**  Register_AmdSCS_1_16_16_Configuration
**
**  Description: Initializes the function call table for a 1 x 16-bit
**               AMD FLASH memory
**
**    Inputs:
**       none:
** 
**    Outputs:
**       none:
** 
**    Return values:
**       0: Success
** 
*****************************************************************************/
   unsigned int Register_AmdSCS_1_16_16_Configuration(void);

/****************************************************************************
**
**  Register_AmdSCS_2_8_8_Configuration
**
**  Description: Initializes the function call table for a 2 x 8-bit
**               AMD FLASH memory
**
**    Inputs:
**       none:
** 
**    Outputs:
**       none:
** 
**    Return values:
**       0: Success
** 
*****************************************************************************/
   unsigned int Register_AmdSCS_2_8_8_Configuration(void);

/****************************************************************************
**
**  Register_AmdSCS_1_8_8_Configuration
**
**  Description: Initializes the function call table for a 1 x 8-bit
**               AMD FLASH memory
**
**    Inputs:
**       none:
** 
**    Outputs:
**       none:
** 
**    Return values:
**       0: Success
** 
*****************************************************************************/
   unsigned int Register_AmdSCS_1_8_8_Configuration(void);

/****************************************************************************
**
**  Register_AmdSCS_4_8_8_Configuration
**
**  Description: Initializes the function call table for a 1 x 8-bit
**               AMD FLASH memory
**
**    Inputs:
**       none:
** 
**    Outputs:
**       none:
** 
**    Return values:
**       0: Success
** 
*****************************************************************************/
   unsigned int Register_AmdSCS_4_8_8_Configuration(void);

#ifdef __cplusplus
}
#endif


#endif /* CFIFLASHCONFIGURATIONS_H */

/********************************* E O F *************************************/
