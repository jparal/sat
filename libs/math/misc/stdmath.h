/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   stdmath.h
 * @brief  Standart math functions.
 * @author @jparal
 *
 * \todo It is possible to implement long double version of functions.
 *
 * @revision{1.0}
 * @reventry{2007/08, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_STDMATH_H__
#define __SAT_STDMATH_H__

#include <math.h>

/** @addtogroup math_misc
 *  @{
 */

/// Standard mathematical functions
struct Math
{
  /// Absolute value
  template <class T> static T Abs (T v);
  /// Ceil
  template <class T> static T Ceil (T v);
  /// Floor
  template <class T> static T Floor (T v);
  /// Sqrt
  template <class T> static T Sqrt (T v);
  /// Log
  template <class T> static T Log (T v);
  /// Pow
  template <class T> static T Pow (T v1, T v2);
  /// Sin
  template <class T> static T Sin (T v);
  /// Cos
  template <class T> static T Cos (T v);
  /// Tan
  template <class T> static T Tan (T v);
  /// ArcSin
  template <class T> static T ASin (T v);
  /// ArcCos
  template <class T> static T ACos (T v);
  /// ArcTan
  template <class T> static T ATan (T v);
};

/** @} */

#include "stdmath.cpp"

#endif /* __SAT_STDMATH_H__ */
