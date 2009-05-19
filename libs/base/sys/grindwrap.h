/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   grindwrap.h
 * @brief  Wrap macros around valgrind tools.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_BASE_SYS_GRINDWRAP_H__
#define __SAT_BASE_SYS_GRINDWRAP_H__

#include "satconfig.h"

/// @addtogroup base_sys
/// @{

#if defined(HAVE_VALGRIND_CALLGRIND_H) && defined(SAT_DEBUG_VALGRIND)
#  include <valgrind/callgrind.h>

#  define SAT_CALLGRIND_DUMP_STATS CALLGRIND_DUMP_STATS
#  define SAT_CALLGRIND_START_INSTRUMENTATION CALLGRIND_START_INSTRUMENTATION
#  define SAT_CALLGRIND_STOP_INSTRUMENTATION CALLGRIND_STOP_INSTRUMENTATION
#else
#  define SAT_CALLGRIND_DUMP_STATS
#  define SAT_CALLGRIND_START_INSTRUMENTATION
#  define SAT_CALLGRIND_STOP_INSTRUMENTATION
#endif

/// @}

#endif /* __SAT_BASE_SYS_GRINDWRAP_H__ */
