/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   stdfuncs.h
 * @brief  Standart functions and wrappers if doesnt exist
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_STDFUNCS_H__
#define __SAT_STDFUNCS_H__

#include "platform.h"
#include "stdhdrs.h"

/** @addtogroup base_sys
 *  @{
 */

/**
 * A null use of a variable, use to avoid GNU compiler
 * warnings about unused variables.
 */
#define NULL_USE(variable) do { \
       if(0) {char *temp = (char *)&variable; temp++;} \
    } while (0)


/**\def SAT_ALLOCA(type, var, size)
 * Dynamic stack memory allocation.
 * \param type Type of the array elements.
 * \param var Name of the array to be allocated.
 * \param size Number of elements to be allocated.
 */
#if defined(PLATFORM_COMPILER_GNU) && !defined(__STRICT_ANSI__)
// In GCC we are able to declare stack vars of dynamic size directly
#  define SAT_ALLOCA(type, var, size) type var [size]
#else
#  define SAT_ALLOCA(type, var, size)				\
     type *var = (type *)alloca ((size) * sizeof (type))
#endif

/** @} */

#endif /* __SAT_STDFUNCS_H__ */
