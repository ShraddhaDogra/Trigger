#ifndef LATTICEMICO32_CFIINFO_T_H_
#define LATTICEMICO32_CFIINFO_T_H_

#include "CFIRoutines.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/*
 * * * * * * * * * * * * * * * * * * * * * * * *
 *                                             *
 * CFI Information Table                       *
 *                                             *
 * * * * * * * * * * * * * * * * * * * * * * * *
 */
typedef struct st_CFIInfo{
	FlashBoardCfgInfo_t boardCfg;
	FlashProgramInfo_t  progInfo;
	FlashGeometry_t     geometry;
}CFIInfo_t;


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /*LATTICEMICO32_CFIINFO_T_H_ */



