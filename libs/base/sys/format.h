/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   format.h
 * @brief  Format attribute for printf,...
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007-03-05, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_FORMAT_H__
#define __SAT_FORMAT_H__

#include "satconfig.h"

/** @addtogroup base_sys
 *  @{
 */

// gcc can perform usefull checking for printf/scanf format strings, just add
// this define at the end of the function declaration
// #if __GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ > 4)
#ifdef HAVE_ATTRIBUTE_FORMAT
#  define SAT_FORMAT_PRINTF(format_idx, arg_idx) \
     __attribute__((format (__printf__, format_idx, arg_idx)))
#  define SAT_FORMAT_SCANF(format_idx, arg_idx) \
     __attribute__((format (__scanf__, format_idx, arg_idx)))
// Unfortunately, gcc doesn't support format argument checking for wide strings
#  define SAT_FORMAT_WPRINTF(format_idx, arg_idx) \
     /*__attribute__((format (__wprintf__, format_idx, arg_idx)))*/
#  define SAT_FORMAT_WSCANF(format_idx, arg_idx) \
     /*__attribute__((format (__wscanf__, format_idx, arg_idx)))*/
#else
#  define SAT_FORMAT_PRINTF(format_idx, arg_idx)
#  define SAT_FORMAT_SCANF(format_idx, arg_idx)
#  define SAT_FORMAT_WPRINTF(format_idx, arg_idx)
#  define SAT_FORMAT_WSCANF(format_idx, arg_idx)
#endif


/** @} */

#endif // __SAT_FORMAT_H__
