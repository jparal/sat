/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   utils.h
 * @brief  Heavy ions utility functions.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_UTILS_H__
#define __SAT_UTILS_H__

/// @addtogroup hions
/// @{

/**
 * @brief Heavy ions utility functions.
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */
struct HIUtils
{
  /**
   * @brief Load STW vector file into a Field class.
   * Specifically, load a file given by parameter @p path into the vector
   * component @p idx of the vector Field. Variable @p path should be full path
   * to the file including the suffix.
   *
   * @param fld field class reference
   * @param idx index of the vector from the range [0,2]
   * @param path path to the STW file (including gz suffix)
   */
  template<class T>
  static void Load (Field<T,3> &fld, int idx, const char* path);

  /// Scalar version of 2D Field
  template<class T>
  static void Load (Field<T,2> &fld, const char* path);
};

#include "utils.cpp"

/// @}

#endif /* __SAT_UTILS_H__ */
