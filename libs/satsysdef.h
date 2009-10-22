/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   satsysdef.h
 * @brief  System definitions. Include this file FIRST.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SATSYSDEF_H__
#define __SAT_SATSYSDEF_H__

#include "satconfig.h"
#include "base/sys/platform.h"
#include <stddef.h>
#include <new>

/// @addtogroup base
/// @{

/**
 * @def SAT_FUNCTION_NAME
 * Macro that resolves to a compiler-specific variable or string that contains
 * the name of the current function.
 */
#if defined(PLATFORM_COMPILER_GCC)
#  define SAT_FUNCTION_NAME		__PRETTY_FUNCTION__
#elif defined(__FUNCTION__)
#  define SAT_FUNCTION_NAME		__FUNCTION__
#else
#  define SAT_FUNCTION_NAME		"<?\?\?>"
#endif

#ifndef SAT_DEBUG
#  undef SAT_EXTENSIVE_MEMDEBUG
#  undef SAT_REF_TRACKER
#else
#  if defined(SAT_EXTENSIVE_MEMDEBUG) && defined(SAT_MEMORY_TRACKER)
#    error Do not use SAT_EXTENSIVE_MEMDEBUG and SAT_MEMORY_TRACKER together!
#  endif
#endif

// The following define should only be enabled if you have defined a special
// version of overloaded new that accepts two additional parameters: a (void*)
// pointing to the filename and an int with the line number. This is typically
// used for memory debugging.  In common/memdebug.cxx there is a memory
// debugger which can (optionally) use this feature. Note that if
// SAT_EXTENSIVE_MEMDEBUG is enabled while the memory debugger is not the
// memory debugger will still provide the needed overloaded operators so you
// can leave SAT_EXTENSIVE_MEMDEBUG on in that case and the only overhead will
// be a little more arguments to 'new'.  Do not enable SAT_EXTENSIVE_MEMDEBUG
// if your platform or your own code defines its own 'new' operator, since this
// version will interfere with your own.  SAT_MEMORY_TRACKER is treated like
// SAT_EXTENSIVE_MEMDEBUG here.
#if defined(SAT_EXTENSIVE_MEMDEBUG) || defined(SAT_MEMORY_TRACKER)

extern void operator delete (void* p);
extern void operator delete[] (void* p);

extern void* operator new (size_t s, void* filename, int line);
extern void* operator new[] (size_t s, void* filename, int line);

inline void operator delete (void* p, void*, int) { operator delete (p); }
inline void operator delete[] (void* p, void*, int) { operator delete[] (p); }

inline void* operator new (size_t s) { return operator new (s, (void*)__FILE__, 0); }
inline void* operator new[] (size_t s) { return operator new (s, (void*)__FILE__, 0); }

#  define SAT_EXTENSIVE_MEMDEBUG_NEW new ((void*)SAT_FUNCTION_NAME, __LINE__)
#  define new SAT_EXTENSIVE_MEMDEBUG_NEW
#endif

/// @}

#endif /* __SAT_SATSYSDEF_H__ */
