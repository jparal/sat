/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   angle.h
 * @brief  Angle conversion functions.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/02, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_ANGLE_H__
#define __SAT_ANGLE_H__

/// @addtogroup math_func
/// @{

namespace Math
{

/// Degree to radian conversion
template <class T> static T Deg2Rad (T v);
/// Radian to degree conversion
template <class T> static T Rad2Deg (T v);

}; // namespace Math

#include "angle.cpp"

/// @}

#endif /* __SAT_ANGLE_H__ */
