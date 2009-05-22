/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   psd.h
 * @brief  Photon-stimulated desorption (PSD) distribution function.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_RAND_PSD_H__
#define __SAT_RAND_PSD_H__

#include "arms.h"

/// @addtogroup math_rand
/// @{

/**
 * @brief Photon-stimulated desorption (PSD) distribution function.
 * Generate PSD distribution [Johnson at al. 2002] defined as follows
 * @f[ f (E) = x(1+x) \frac{E U^x}{(E + U)^{2+x}} @f]
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */
class PSDRandGen : public ARMSRandGen
{
public:
  typedef ARMSRandGen TBase;

  /// Constructor
  PSDRandGen ();

  /// Evaluate DF at the point @p x.
  virtual double EvalDF (double x);

  /**
   * @brief Initialize PSD distribution function.
   *
   * @param bind Binding energy of particle (0.043 - 0.065)
   * @param xpar Parameter x  of the distribution function (0.7)
   */
  void Initialize (double bind, double xpar);

  /// Return binding energy
  double GetBindEnergy ()const
  { return _u; }

  /// Return x parameter.
  double GetXParam ()const
  { return _xpar; }

private:
  double _u;  ///< Binding energy of particle
  double _xpar; ///< Transmitted energy from the collision
  double _2pxp;
  double _cnorm; ///< Normalization constant
  bool _initialized;
};

/// @}

#endif /* __SAT_RAND_PSD_H__ */
