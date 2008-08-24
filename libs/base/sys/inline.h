/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   inline.h
 * @brief  Handling various inline levels
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007-03-05, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_INLINE_H__
#define __SAT_INLINE_H__

#include "satconfig.h"    // Flatten
#include "attributes.h"

/** @addtogroup base_sys
 *  @{
 */

/// Standard inline
#define SAT_INLINE inline

#ifdef HAVE_ATTRIBUTE_ALWAYS_INLINE
#  define SAT_INLINE_ALWAYS SAT_ATTRIBUTE(always_inline)
#else
#  define SAT_INLINE_ALWAYS inline
#endif

#ifdef HAVE_ATTRIBUTE_FLATTEN
#  define SAT_INLINE_FLATTEN SAT_ATTRIBUTE(flatten)
#else
#  define SAT_INLINE_FLATTEN inline
#endif

/**
 * \def SAT_INLINE_FLATTEN For a function marked with this attribute, every
 * call inside this function will be inlined
 *
 * \def SAT_INLINE_ALWAYS For functions declared inline, this attribute inlines
 * the function even if no optimization level was specified.
 */

/** @} */

#endif // __SAT_INLINE_H__
