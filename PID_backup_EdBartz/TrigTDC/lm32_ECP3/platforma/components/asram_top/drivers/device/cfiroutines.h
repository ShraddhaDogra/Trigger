/****************************************************************************
 **
 **  Name:  CFIRoutines.h
 **
 **  Description:
 **     Data structures and prototypes for support routines needed to
 **     program CFI FLASH memories.
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
#ifndef CFIROUTINES_H_
#define CFIROUTINES_H_

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/****************************
 *                          *
 *       INCLUDE FILES      *
 *                          *
 ****************************/

/****************************
 *                          *
 *      DEFINITIONS         *
 *                          *
 ****************************/
   /******************************************************************************
    * Data Structures:                                                           *
    ******************************************************************************/
   /* TOTAL ERASE-REGION INFORMATION (ADJUST BASED ON SUPPORTED FLASH DEVICES) */
#ifndef LATTICEMICO32_ERASE_REGIONS_MAX
#define LATTICEMICO32_ERASE_REGIONS_MAX                         (8)
#endif

 
   /*
    * * * * * * * * * * * * * * * * * * * * * * * *
    * Flash configuration (physical) on the board *
    * Typical information for flash layout on the *
    * board:                                      *
    * - Total flash devices sharing the address   *
    *   bus when stringing multiple flash devices *
    *   together.                                 *
    * - Flash-mode (x8, x16, x32) are typical.    *
    * * * * * * * * * * * * * * * * * * * * * * * *
    */
   typedef struct st_FlashBoardCfgInfo {
      unsigned int parallels;            /* total flash devices sharing address-bus */
      unsigned int mode;                 /* 8-bit mode, 16-bit mode etc             */
   } FlashBoardCfgInfo_t;


   /*
    * * * * * * * * * * * * * * * * * * * * * * * *
    * Basic Flash Programming Information         *
    * * * * * * * * * * * * * * * * * * * * * * * *
    */
   typedef struct st_FlashProgramInfo {
      unsigned int minVccMilliVolts;
      unsigned int maxVccMilliVolts;
      unsigned int minVppSupplyMilliVolts;
      unsigned int maxVppSupplyMilliVolts;
      unsigned int maxWordWriteTOMicroSecs;
      unsigned int maxBufferWriteTOMicroSecs;
      unsigned int maxBlockEraseTOMilliSecs;
      unsigned int maxChipEraseTOMilliSecs;
   } FlashProgramInfo_t;



   /*
    * * * * * * * * * * * * * * * * * * * * * * * *
    * Basic Flash Programming Information         *
    * * * * * * * * * * * * * * * * * * * * * * * *
    */
   typedef struct st_EraseRegionInfo_t {
      unsigned int eraseBlocks;
      unsigned int blockSize;
   } EraseRegion_t;


   typedef struct st_FlashGeometry_t {
      unsigned int sizeInBytes;
      unsigned int maxBufferSizeInBytes;
      unsigned int totalEraseRegions;
      unsigned int totalEraseBlocks;
      EraseRegion_t eraseRegion[LATTICEMICO32_ERASE_REGIONS_MAX];
   } FlashGeometry_t;


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

   unsigned char CFI_READ_BYTE(unsigned char port_width, unsigned int offset);
/****************************************************************************
**
**  CFIGetDeviceGeometry
**
**  Description: Queries the FLASH for:
**                 The largest programmable block
**                 The total size of the flash
**                 The number of sectors
**
**    Inputs:
**       Base:  Base address offset of the memory
**       BoardInfo:  The number of parallel memory devices and the
**    width of the memory devices as a data struct.
** 
**    Outputs:
**       FlashGeomtery: A data structure with the info described above.
** 
**    Return values:
**       integer: 0 = Success
**                else Failure
** 
*****************************************************************************/
   unsigned int
   CFIGetDeviceGeometry(unsigned int Base, FlashBoardCfgInfo_t *BoardInfo, FlashGeometry_t *FlashGeometry);

/****************************************************************************
**
**  CFIGetPrgInfo
**
**  Description: Queries the FLASH for programming voltages, and
**               erasure timeouts.
**
**    Inputs:
**       Base:  Base address offset of the memory
**       BoardInfo:  The number of parallel memory devices and the
**    width of the memory devices as a data struct.
** 
**    Outputs:
**       FlashProgramInfo: A data structure with the info described above.
** 
**    Return values:
**       integer: 0 = Success
**                else Failure
** 
*****************************************************************************/
   unsigned int
   CFIGetPrgInfo(unsigned int Base, FlashBoardCfgInfo_t *BoardInfo, FlashProgramInfo_t *FlashProgramInfo);

/****************************************************************************
**
**  CFIGetPriVendCmdSetID
**
**  Description: Queries the FLASH for the Primary Command set
**
**    Inputs:
**       Base:  Base address offset of the memory
**       BoardInfo:  The number of parallel memory devices and the
**    width of the memory devices as a data struct.
** 
**    Outputs:
**       CmdId: The value supplied from CFI_PRIM_CMDSET_LSB
** 
**    Return values:
**       integer: 0 = Success
**                else Failure
** 
*****************************************************************************/
   unsigned int
   CFIGetPriVendCmdSetId(unsigned int Base, FlashBoardCfgInfo_t *BoardInfo, unsigned int *CmdId);

/****************************************************************************
**
**  IssueCFIQueryExit
**
**  Description: Leaves QUERY mode
**
**    Inputs:
**       Base:  Base address offset of the memory
**       BoardInfo:  The number of parallel memory devices and the
**    width of the memory devices as a data struct.
** 
**    Outputs:
**       None:
** 
**    Return values:
**       None:
** 
*****************************************************************************/
   void
   IssueCFIQueryExit(unsigned int Base, FlashBoardCfgInfo_t *BoardInfo);

/****************************************************************************
**
**  IssueCFIQueryEnter
**
**  Description: Enters QUERY mode
**
**    Inputs:
**       Base:  Base address offset of the memory
**       BoardInfo:  The number of parallel memory devices and the
**    width of the memory devices as a data struct.
** 
**    Outputs:
**       None:
** 
**    Return values:
**       None:
** 
*****************************************************************************/
   void
   IssueCFIQueryEnter(unsigned int Base, FlashBoardCfgInfo_t *BoardInfo);


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /*CFIROUTINES_H_*/

