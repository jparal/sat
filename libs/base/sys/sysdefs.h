/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sysdefs.h
 * @brief  Common system macros and definitions.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SYSDEFS_H__
#define __SAT_SYSDEFS_H__

#include "satconfig.h"
#include "platform.h"
#include "porttypes.h"
#include "stdhdrs.h"

/** @addtogroup base_sys
 *  @{
 */

/// splitting and reassembling 64-bit quantities
#define SAT_MAKEWORD(hi,lo)					\
  ((((uint64_t)(hi)) << 32) | (((uint64_t)(lo)) & 0xFFFFFFFF))
/// splitting and reassembling 64-bit quantities
#define SAT_HIWORD(arg)				\
  ((uint32_t)(((uint64_t)(arg)) >> 32))
/// splitting and reassembling 64-bit quantities
#define SAT_LOWORD(arg)				\
  ((uint32_t)((uint64_t)(arg)))

#if defined(PLATFORM_COMPILER_SGI_CXX)
 /* despite the docs, not supported in MIPSPro C++ */
#  define SAT_PRAGMA(x)
#elif PLATFORM_COMPILER_SGI && _SGI_COMPILER_VERSION < 742
 /* bug: broken in older versions (740 fails, 742 works) */
#  define SAT_PRAGMA(x)
#elif PLATFORM_COMPILER_COMPAQ_C && __DECC_VER < 60590207
 /* not supported in older versions (60490014) */
#  define SAT_PRAGMA(x)
#elif PLATFORM_COMPILER_SUN_C && __SUNPRO_C < 0x570
 /* not supported in older versions (550 fails, 570 works) */
#  define SAT_PRAGMA(x)
#else
#  define SAT_PRAGMA(x) _Pragma ( #x )
#endif

/** @} */

#endif /* __SAT_SYSDEFS_H__ */
