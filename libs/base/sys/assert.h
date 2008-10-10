/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   assert.h
 * @brief  Assert macros to have the live easier
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007-03-05, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_ASSERT_H__
#define __SAT_ASSERT_H__

#include "platform.h"

/** @addtogroup base_sys
 *  @{
 */

#if !defined (SAT_DEBUG_BREAK)
#  if defined (PLATFORM_OS_MSWINDOWS)
#    define SAT_DEBUG_BREAK ::DebugBreak()
#  elif defined (PLATFORM_ARCH_X86)
#    if defined (PLATFORM_COMPILER_GNU)
#      define SAT_DEBUG_BREAK asm ("int $3")
#    else
#      define SAT_DEBUG_BREAK { static int x = 0; x /= x; }
#    endif
#  else
#    define SAT_DEBUG_BREAK { static int x = 0; x /= x; }
#  endif
#endif
#if !defined (SAT_ASSERT_MSG)
    namespace SAT
    {
      namespace Debug
      {
	extern void AssertMessage (const char* expr,
	  const char* filename, int line, const char* msg = 0);
      } // namespace Debug
    } // namespace SAT
#  define SAT_ASSERT_MSG(x,msg)					 \
      if (!(x)) SAT::Debug::AssertMessage (#x, __FILE__, __LINE__, msg);
#endif
#if !defined (SAT_ASSERT)
#  define SAT_ASSERT(x)	SAT_ASSERT_MSG(x, 0)
#endif

#ifdef SAT_DEBUG
#  define SAT_DBG_ASSERT(exp) SAT_ASSERT(exp)
#  define SAT_DBG_ASSERT_MSG(exp,msg) SAT_ASSERT_MSG(exp,msg)
#else
#  define SAT_DBG_ASSERT(exp)
#  define SAT_DBG_ASSERT_MSG(exp,msg)
#endif

// #if PLATFORM_COMPILER_GNU && PLATFORM_COMPILER_VERSION_GE(4,3,0)
// Note: require -std=c++0x flag to g++
// #  define SAT_CASSERT_MSG(expr, msg) static_assert (expr, msg)
// #else // PLATFORM_COMPILER_GNU && PLATFORM_COMPILER_VERSION_GE(4,3,0)
namespace SAT
{
  namespace Debug {
    template<int> struct CompileTimeError;
    template<> struct CompileTimeError<true> {};
  }
}
#define SAT_CASSERT_MSG(expr, msg)					\
  { SAT::Debug::CompileTimeError<((expr) != 0)> ERROR_##msg; (void)ERROR_##msg; }
// #endif // PLATFORM_COMPILER_GNU && PLATFORM_COMPILER_VERSION_GE(4,3,0)

#define SAT_CASSERT(expr) SAT_CASSERT_MSG(expr,Unknown)

/**\def SAT_SAFE_CHECK(exp)
 * Same as SAT_ASSERT but is compiled even in optimize version
 * \def SAT_SAFE_CHECK_MSG(exp,msg)
 * Same as SAT_ASSERT_MSG but is compiled even in optimize version
 *
 * \def SAT_SASSERT(expr)
 * Assert checking in compile time (static assert)
 * \def SAT_SASSERT_MSG(expr,msg)
 * Assert checking in compile time with message. 'msg' is a C++ identifier
 * that does not need to be defined and is a C-like identificator.
 *
 * \def SAT_DEBUG_BREAK
 * Stops program execution and break into debugger, if present - otherwise,
 * probably just throws an exception/signal (ie crashes).
 * \def SAT_ASSERT(expr)
 * Assertion. If \a expr is false, a message containing the failing expression
 * as well as a call stack is printed to <tt>stderr</tt> and a debug break is
 * performed
 * \remarks Breaking execution can be avoided at runtime by setting the
 *   environment variable <tt>"SAT_ASSERT_IGNORE"</tt> to a value other than 0.
 * \def SAT_ASSERT_MSG(msg, expr)
 * Same as #SAT_ASSERT(expr), but additionally prints \a msg to <tt>stderr</tt>.
 */

/** @} */

#endif /* __SAT_ASSERT_H__ */
