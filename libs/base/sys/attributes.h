/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   attributes.h
 * @brief  Attributes macros which doesnt fit somewhere else.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 * @reventry{2008/01, @jparal}
 * @revmessg{Add SAT_ATTR_DEPRECATED_MSG attribute}
 */

#include "satconfig.h"

#ifndef __SAT_ATTRIBUTES_H__
#define __SAT_ATTRIBUTES_H__

#include "platform.h"

/// @addtogroup base_sys
/// @{

/* special GCC features */
#if defined(PLATFORM_COMPILER_PGI) && defined(__attribute__)
/* bug: undo a stupid, gcc-centric definition from Linux sys/cdefs.h */
#  undef __attribute__ 
// #  define SAT_ATTRIBUTE(att)
#endif

#if !defined(HAVE_ATTRIBUTE)
  /* disable all attributes */
#  undef __attribute__
#  define __attribute__(flags)
#  define SAT_ATTRIBUTE(att)
#else
#  define SAT_ATTRIBUTE(att) __attribute__((att))
#endif

#ifdef HAVE_ATTRIBUTE_DEPRECATED
#  define SAT_ATTR_DEPRECATED SAT_ATTRIBUTE(__deprecated__)
#else
#  define SAT_ATTR_DEPRECATED
#endif

#ifdef HAVE_ATTRIBUTE_DEPRECATED_MSG
#  define SAT_ATTR_DEPRECATED_MSG(msg) SAT_ATTRIBUTE(__deprecated__(msg))
#else
#  define SAT_ATTR_DEPRECATED_MSG(msg) SAT_ATTR_DEPRECATED
#endif

#ifdef HAVE_ATTRIBUTE_NORETURN
#  define SAT_ATTR_NORETURN SAT_ATTRIBUTE(__noreturn__)
#else
#  define SAT_ATTR_NORETURN
#endif

#ifdef HAVE_ATTRIBUTE_WARN_UNUSED_RESULT
#  define SAT_ATTR_WARNUNUSED SAT_ATTRIBUTE(__warn_unused_result__)
#else
#  define SAT_ATTR_WARNUNUSED
#endif

#ifdef HAVE_ATTRIBUTE_MALLOC
#  define SAT_ATTR_MALLOC SAT_ATTRIBUTE(__malloc__) SAT_WARNUNUSED
#else
#  define SAT_ATTR_MALLOC
#endif

#ifdef HAVE_ATTRIBUTE_PURE
#  define SAT_ATTR_PURE SAT_ATTRIBUTE(__pure__)
#else
#  define SAT_ATTR_PURE
#endif

/**
 * \def SAT_ATTR_ATTRIBUTE Attribute macro
 *
 * \def SAT_ATTR_DEPRECATED The deprecated attribute results in a warning if
 * the function is used anywhere in the source file.
 *
 * \def SAT_ATTR_DEPRECATED_MSG The same attribute as SAT_ATTR_DEPRECATED but
 * accept argument with message.
 *
 * \def SAT_ATTR_NORETURN The noreturn keyword tells the compiler to assume
 * that function cannot return
 *
 * \def SAT_ATTR_NORETURN The @c warn_unused_result attribute causes a warning
 * to be emitted if a caller of the function with this attribute does not use
 * its return value. This is useful for functions where not checking the result
 * is either a security problem or always a bug, such as @c realloc.
 *
 * \def SAT_ATTR_MALLOC The @c malloc attribute is used to tell the compiler
 * that a function may be treated as if any non-@c NULL pointer it returns
 * cannot alias any other pointer valid when the function returns. This will
 * often improve optimization. Standard functions with this property
 * include @c malloc and @c calloc. @c realloc -like functions have this
 * property as long as the old pointer is never referred to (including
 * comparing it to the new pointer) after the function returns a non-@c NULL
 * value.
 *
 * \def SAT_ATTR_PURE Many functions have no effects except the return value
 * and their return value depends only on the parameters and/or global
 * variables. Such a function can be subject to common subexpression
 * elimination and loop optimization just as an arithmetic operator would
 * be. These functions should be declared with the attribute @c pure.
 */

/// @}

#endif /* __SAT_ATTRIBUTES_H__ */
