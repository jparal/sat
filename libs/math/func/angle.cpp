/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   angle.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/02, @jparal}
 * @revmessg{Initial version}
 */

#include "angle.h"
#include "math/misc/const.h"

namespace Math
{

template <class T> static T Deg2Rad (T v)
{
  return v*M_PI/180.;
}

template <class T> static T Rad2Deg (T v)
{
  return v*180./M_PI;
}

}; // namespace Math
