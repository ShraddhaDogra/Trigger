#ifndef LATTICEMICO32CFICFGTBL_H_
#define LATTICEMICO32CFICFGTBL_H_

#include "LatticeMico32CFI.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */


   /*
    * Flash configuration table
    */
   typedef struct st_FlashConfiguration{
      /* Vendor Command-Set Id */
      unsigned int              VendorCSId;
      /* Board configuration information */
      const FlashBoardCfgInfo_t *boardInfo;
      /* Configuration specific function table */
      const FlashCfgFnTbl_t     *cfgFnTbl;
   } FlashConfiguration_st;


   void LatticeMico32InitializeFlashCfgTable(void);
   unsigned int LatticeMico32RegisterFlashCfg(FlashConfiguration_st *pCfg);
   unsigned int LatticeMico32GetTotalFlashCfgs( void );
   FlashConfiguration_st *const LatticeMico32GetFlashCfg( unsigned int index );


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /*LATTICEMICO32CFICFGTBL_H_*/
