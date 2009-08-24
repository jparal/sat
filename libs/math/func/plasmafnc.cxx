/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   plasmafnc.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/08, @jparal}
 * @revmessg{Initial version}
 */

#include "plasmafnc.h"
#include "faddeeva.h"
#include "math/satmisc.h"

namespace Math
{

std::complex<double> FncZ (const std::complex<double>& z)
{
  return std::complex<double>(0,1) * M_SQRTPI * Math::Faddeeva (z);
}

std::complex<double> FncDZ (const std::complex<double>& z)
{
  return -2. * (1. + z * Math::FncZ (z));
}

}; /* namespace Math */
