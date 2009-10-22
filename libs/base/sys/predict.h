/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   predict.h
 * @brief  Macros for conditions prediction
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007-03-05, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_PREDICT_H__
#define __SAT_PREDICT_H__

#include "satconfig.h"
#include "platform.h"

/// @addtogroup base_sys
/// @{

#ifdef PREDICT_TRUE
#  undef PREDICT_TRUE
#endif
#ifdef PREDICT_FALSE
#  undef PREDICT_FALSE
#endif

#if defined(__GNUC__) && defined(HAVE_BUILTIN_EXPECT)
/* cast to uintptr_t avoids warnings on some compilers about passing
 * non-integer arguments to __builtin_expect(), and we don't use (int) because
 * on some systems this is smaller than (void*) and causes other warnings
 */
#  define PREDICT_TRUE(exp)  __builtin_expect( ((uintptr_t)(exp)), 1 )
#  define PREDICT_FALSE(exp) __builtin_expect( ((uintptr_t)(exp)), 0 )
#elif defined(PLATFORM_COMPILER_XLC) && __xlC__ > 0x0600 && defined(_ARCH_PWR5)
/* usually helps on Power5, usually hurts on Power3, mixed on other PPCs */
#  if 1 /* execution_frequency pragma only takes effect when it occurs within a block statement */
#    define PREDICT_TRUE(exp)  ((exp) && ({; _Pragma("execution_frequency(very_high)"); 1; }))
#    define PREDICT_FALSE(exp) ((exp) && ({; _Pragma("execution_frequency(very_low)"); 1; }))
#  else
/* experimentally determined that pragma is sometimes(?) ignored unless it is
 * preceded by a non-trivial statement - unfortunately the dummy statement can
 * also hurt performance */
static __inline sat_xlc_pragma_dummy() {}
#    define PREDICT_TRUE(exp)  ((exp) && ({ sat_xlc_pragma_dummy(); _Pragma("execution_frequency(very_high)"); 1; }))
#    define PREDICT_FALSE(exp) ((exp) && ({ sat_xlc_pragma_dummy(); _Pragma("execution_frequency(very_low)"); 1; }))
#  endif
#else
#  define PREDICT_TRUE(exp)  (exp)
#  define PREDICT_FALSE(exp) (exp)
#endif


/* if with branch prediction */
#ifdef if_pf
#  undef if_pf
#endif
#ifdef if_pt
#  undef if_pt
#endif

#if PLATFORM_COMPILER_MTA
  /* MTA's pragma mechanism is buggy, so allow it to be selectively disabled */
#  define SAT_MTA_PRAGMA_EXPECT_ENABLED(x) _Pragma(x)
#  define SAT_MTA_PRAGMA_EXPECT_DISABLED(x)
#  define SAT_MTA_PRAGMA_EXPECT_OVERRIDE SAT_MTA_PRAGMA_EXPECT_ENABLED
#  define if_pf(cond) SAT_MTA_PRAGMA_EXPECT_OVERRIDE("mta expect false") if (cond)
#  define if_pt(cond) SAT_MTA_PRAGMA_EXPECT_OVERRIDE("mta expect true")  if (cond)
#elif defined(PLATFORM_COMPILER_SGI) && _SGI_COMPILER_VERSION >= 720 && _MIPS_SIM != _ABIO32
  /* MIPSPro has a predict-false, but unfortunately no predict-true */
#  define if_pf(cond) if (cond) _Pragma("mips_frequency_hint NEVER")
#  define if_pt(cond) if (PREDICT_TRUE(cond))
#else
#  define if_pf(cond) if (PREDICT_FALSE(cond))
#  define if_pt(cond) if (PREDICT_TRUE(cond))
#endif

/**
 * @def if_pt if statement with branch prediction to by
 *  TRUE.  \sa \ref Prefetch \sa \ref BranchPrediction
 *
 * @def if_pf if statement with branch prediction to by
 * FALSE.  \sa \ref Prefetch \sa \ref BranchPrediction
 */

/**
 * @page BranchPrediction Branch prediction
 * Macros #if_pf and #if_pt return the value of the expression given, but pass
 * on a hint that you expect the value to be true or false.  Use them to wrap
 * the conditional expression in an if stmt when you have strong reason to
 * believe the branch will frequently go in one direction and the branch is a
 * bottleneck
 */

/// @}

#endif /* __SAT_PREDICT_H__ */
