/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   plasmafnc.h
 * @brief  Plazma dispersion function.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/08, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_PLASMAFNC_H__
#define __SAT_PLASMAFNC_H__

#include <complex>

/// @addtogroup math_func
/// @{

namespace Math
{
  /**
   * Plasma dispersion function.
   * @f[
   * Z(\zeta) = \imath \sqrt{\pi} \exp^{-\zeta^2}
   * @f]
   */
  std::complex<double> FncZ (const std::complex<double>& z);
  /**
   * Derivation of plasma dispersion function.
   * @f[
   * Z^\prime(\zeta) = -2 (1+\zeta Z(\zeta))
   * @f]
   */
  std::complex<double> FncDZ (const std::complex<double>& z);
};

/// @}

#endif /* __SAT_PLASMAFNC_H__ */
