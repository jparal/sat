/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   utils.h
 * @brief  Utility function which dont fit anywhere else.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_BASE_COMMON_UTILS_H__
#define __SAT_BASE_COMMON_UTILS_H__

/// @addtogroup base_common
/// @{

/**
 * Finds the smallest number that is a power of two and is larger or
 * equal to n.
 */
static inline int FindNearestPowerOf2 (int n)
{
  int v=n;

  v--;
  v |= v >> 1;
  v |= v >> 2;
  v |= v >> 4;
  v |= v >> 8;
  v |= v >> 16;
  v++;

  return v;
}

/// @}

#endif /* __SAT_BASE_COMMON_UTILS_H__ */
