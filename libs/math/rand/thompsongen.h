/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   thompsongen.h
 * @brief  Thompson-Sigmund energy distribution generator.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_THOMPSONGEN_H__
#define __SAT_THOMPSONGEN_H__

#include "rndgen.h"

/// @addtogroup math_rng
/// @{

/**
 * @brief Thompson-Sigmund energy distribution generator.
 * Thompson-Sigmund distribution is usually used to describe distribution of
 * energy of particles released from surface material/planet after collision
 * with energetic particle. Such particle has usually energy distribution
 * described as: \f[ f(E) = 2 E U / (E+U)^3 \f] where \e U is an binding
 * energy. We can generate such distribution by generating function:
 *
 * \f[ E = U \frac{- \xi - \sqrt{\xi}}{\xi - 1} \f]
 *
 * where \f$ \xi \f$ is an uniformly generated random number between 0 and
 * 1. But we are usually interested in velocity, defined as:
 *
 * \f[ |v| = v_{bind} \sqrt{ \frac{\xi+ \sqrt{\xi} }{1-\xi} } \f]
 *
 * where \f$ v_{bind} \f$ is characteristic binding velocity determined from
 * binding energy \f$ U = \frac{1}{2} m v_{bind}^2 \f$. For example typical
 * binding energy for processes on Mercury is 0.27 eV.
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class ThompsonRandGen : public RandomGen<T>
{
public:
  /// Constructor
  /// Initialize with default parameters: bind = 1, bulk = 0
  ThompsonRandGen ();
  /// Constructor
  ThompsonRandGen (T bind, T bulk);

  /**
   * Initialization function
   * @param bind Binding energy
   * @param bulk Bulk velocity
   */
  void Initialize (T bind, T bulk);

  /**
   * Get generated value.
   * @return generated value
   */
  T Get ();

  /// Return binding velocity
  T GetVth () const
  { return _bind; }

  /// Return mean value
  T GetBulk () const
  { return _bulk; }

private:
  T _bind;
  T _bulk;
};


/** @} */

#endif // __SAT_THOMPSONGEN_H__
