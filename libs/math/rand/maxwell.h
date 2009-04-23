/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   maxwell.h
 * @brief  Maxwell random number generator.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_RAND_MAXWELL_H__
#define __SAT_RAND_MAXWELL_H__

#include "rndgen.h"

/** @addtogroup math_rand
 *  @{
 */

/**
 * @brief Maxwell random number generator.
 * Generator is using polar Box-Muller method (@e wikipedia):
 *
 * Suppose @f$ U_1 @f$ and @f$ U_2 @f$ are independent random variables that
 * are uniform distribution (continuous) in (0,1]. Let
 *
 * @f[ Z_0 = u + v_{th} \sqrt{-2 \ln U_1} \cos(2 \pi U_2) @f]
 * and
 * @f[ Z_1 = u + v_{th} \sqrt{-2 \ln U_1} \sin(2 \pi U_2) @f]
 *
 * Then @f$ Z_0 @f$ and @f$ Z_1 @f$ are statistically independent random
 * variables with a normal distribution of standard deviation @f$ v_{th} @f$
 * and values are shifted by bulk velocity @f$ u @f$.
 *
 * The derivation Sheldon Ross, ''A First Course in Probability'', (2002),
 * p.279-81 is based on the fact that, in a two-dimensional Cartesian system
 * where X and Y coordinates are described by two independent and normally
 * distributed random variables, the random variables for
 * @f$ R^2 @f$ and @f$ \Theta @f$ (shown above) in the corresponding
 * polar coordinates are also independent and can be expressed as
 *
 * @f[ R^2 = -2\cdot\ln U_1 @f]
 * and
 * @f[ \Theta = 2\pi U_2 @f]
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class MaxwellRandGen : public RandomGen<T>
{
public:
  /// Constructor
  MaxwellRandGen ()
  { Initialize (1.); }

  MaxwellRandGen (T vth)
  { Initialize (vth); }

  /**
   * Initialization function (default normal distribution)
   * @param vth thermal velocity
   */
  void Initialize (T vth);

  /**
   * Get generated value.
   * @return generated value
   */
  T Get ();

  /// Return variance
  T ThermalVel () const
  { return _vth; }

  /// Return thermal velocity
  T GetVth () const
  { return _vth; }

private:
  T _vth;
  T _r1;
  T _r2;
  int _stat;
};

/** @} */

#endif /* __SAT_RAND_MAXWELL_H__ */
