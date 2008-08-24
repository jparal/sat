/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cast.h
 * @brief  Macros for variable casting
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CAST_H__
#define __SAT_CAST_H__

#include "satconfig.h"

/** @addtogroup base_sys
 *  @{
 */

#if !defined(HAVE_STATIC_CAST)			\
 || !defined(HAVE_DYNAMIC_CAST) 		\
 || !defined(HAVE_REINTERPRET_CAST)		\
 || !defined(HAVE_CONST_CAST)

# define SAT_USE_OLD_STYLE_CASTS

#endif

// Platforms with compilers which only understand old-style C++ casting syntax
// should define SAT_USE_OLD_STYLE_CASTS.
#if defined(SAT_USE_OLD_STYLE_CASTS)
  #define SAT_CAST(C,T,V) ((T)(V))
#else
  #define SAT_CAST(C,T,V) (C<T>(V))
#endif

#define SAT_STATIC_CAST(T,V)      SAT_CAST(static_cast,T,V)
#define SAT_DYNAMIC_CAST(T,V)     SAT_CAST(dynamic_cast,T,V)
#define SAT_REINTERPRET_CAST(T,V) SAT_CAST(reinterpret_cast,T,V)
#define SAT_CONST_CAST(T,V)       SAT_CAST(const_cast,T,V)

/**
 * @def SAT_STATIC_CAST static cast
 * @def SAT_DYNAMIC_CAST dynamic cast
 * @def SAT_REINTERPRET_CAST reinterpret cast
 * @def SAT_CONST_CAST constant cast
 */

/** @} */

#endif /* __SAT_CAST_H__ */
