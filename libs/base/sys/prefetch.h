/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   prefetch.h
 * @brief  Prefetch mechanism helper macros
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_PREFETCH_H__
#define __SAT_PREFETCH_H__

#include "platform.h"

/** @addtogroup base_sys
 *  @{
 */

// Standart __GNU__ builtin fnc
#if HAVE_BUILTIN_PREFETCH
#  define SAT_PREFETCH_RO(P)			\
  __builtin_prefetch((void *)(P),0)
#  define SAT_PREFETCH_RW(P)			\
  __builtin_prefetch((void *)(P),1)

// MipsPro: _Pragma isnt supported from 7.1 anyway ...
#elif defined(PLATFORM_COMPILER_SUN) && PLATFORM_COMPILER_VERSION_GE (7,0,0)
#  define SAT_PREFETCH_RO(P)				\
  SAT_PRAGMA (prefetch_ref = (void *)P, kind = rd)
#  define SAT_PREFETCH_RW(P)				\
  SAT_PRAGMA (prefetch_ref = (void *)P, kind = wr)

// Not implemented:
#else
#  define SAT_PREFETCH_RO(P)
#  define SAT_PREFETCH_RW(P)
#endif

/**
 * \def SAT_PREFETCH_RO(P)
 * Make prefetch from memory into cache. Parameter \e P is a valid pointer. We
 * expect that data will be only read only (this is just helper for processor
 * and compiler) \sa \ref Prefetch \sa \ref BranchPrediction
 *
 * \def SAT_PREFETCH_RW(P)
 * Make prefetch from memory into cache. Parameter \e P is a valid pointer. We
 * expect that data will be only read write (this is just helper for processor
 * and compiler) \sa \ref Prefetch \sa \ref BranchPrediction
 */

/** \page Prefetch Non-binding prefetch hints
 *
 * Macros #SAT_PREFETCH_RO and #SAT_PREFETCH_RO take a single address
 * expression and provide a hint to prefetch the corresponding memory to L1
 * cache for either reading or for writing.  These are non-binding hints and so
 * the argument need not always be a valid pointer.  For instance,
 * SAT_PREFETCH_{RO,RW}(NULL) is explicitly permitted.  The macros may expand
 * to nothing, so the argument must not have side effects.
 *
 * for MpisPro >= 7.0:
 * \code
 * pragma prefetch_ref = ref [, stride = num1 [, num2]] 
 *                           [, level = [lev1][, lev2]] 
 *                           [, kind = {rd|wr}] 
 *                           [, size = sz]
 *
 * stride ..  Prefetches every num iteration(s) of this loop. (defuault 1)
 * level  ..  1: prefetch from L2 to L1 cache; 2: prefetch from memory to L1
 *            cache (default 2)
 * kind   ..  Specifies read or write. (default write)
 \endcode

 * for GNU compilers:
 * \code
 * void __builtin_prefetch (const void *addr [,0|1] [,0|1]);
 * \endcode
 */

/** @} */

#endif /* __SAT_PREFETCH_H__ */
