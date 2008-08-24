/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   macros.h
 * @brief  Quick math macros
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_BASE_COMMON_MACROS_H__
#define __SAT_BASE_COMMON_MACROS_H__

/** @addtogroup base_common
 *  @{
 */

#ifndef MIN
#  define MIN(a,b) ((a)<(b)?(a):(b))
#endif

#ifndef MAX
#  define MAX(a,b) ((a)>(b)?(a):(b))
#endif

#ifndef ABS
#  define ABS(x) ((x)<0?-(x):(x))
#endif

#ifndef SIGN
#  define SIGN(x) ((x) < 0 ? -1 : ((x) > 0 ? 1 : 0))
#endif

/**
 * @def MIN Gives minimal of two values
 * @def MAX Gives maximal of two values
 * @def ABS Gives absolute value
 * @def SIGN Gives 1 for positive value or 0 for negative one
 */

/** @} */

#endif /* __SAT_BASE_COMMON_MACROS_H__ */
