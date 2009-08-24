/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   faddeeva.h
 * @brief  Faddeeva error function
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/08, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_FADDEEVA_H__
#define __SAT_FADDEEVA_H__

#include <complex>

/// @addtogroup math_func
/// @{

namespace Math
{
  /**
   * Faddeeva function.
   * @f[
   * w(\zeta) = e^{-\zeta^2} [1+ erf(\imath \zeta)]
   * @f]
   */
  std::complex<double> Faddeeva (const std::complex<double>& z);
};

/// @}

#endif /* __SAT_FADDEEVA_H__ */
