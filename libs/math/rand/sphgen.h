/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sphgen.h
 * @brief  Uniform distribution in spherical coordinates.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SPHGEN_H__
#define __SAT_SPHGEN_H__

#include "rndgen.h"

/// @addtogroup math_rand
/// @{

/**
 * @brief Uniform distribution in spherical coordinates.
 * Generator of uniformly distributed points on the sphere. Generator is using
 * generator functions:
 * \f[ \Theta = 2 \pi \xi_{\Theta} \f]
 * \f[ \Phi = \arccos (2 \xi_{\Phi} - 1) \f]
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class SphericalRandGen : public RandomGen<T>
{
public:
  /// Constructor
  SphericalRandGen ();
  /// Destructor
  ~SphericalRandGen ();

  T GetPhi ();
  T GetTht ();
private:
};

/// @}

#endif /* __SAT_SPHGEN_H__ */
