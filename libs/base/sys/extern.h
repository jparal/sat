/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   extern.h
 * @brief  Everything related to extern keyword
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007-03-05, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_EXTERN_H__
#define __SAT_EXTERN_H__

/// @addtogroup base_sys
/// @{

/**
 * BEG_C_DECLS should be used at the beginning of your declarations, so that
 * C++ compilers don't mangle their names.  Use END_C_DECLS at the end of C
 * declarations.
 **/

#undef BEG_C_DECLS
#undef END_C_DECLS

#if !defined(__cplusplus) || !defined(c_plusplus)
#  define BEG_C_DECLS extern "C" {
#  define END_C_DECLS }
#else
#  define BEG_C_DECLS /* empty */
#  define END_C_DECLS /* empty */
#endif

/// @}

#endif /* __SAT_EXTERN_H__ */
