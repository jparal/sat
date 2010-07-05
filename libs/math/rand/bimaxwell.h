/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   bimaxwell.h
 * @brief  Bi-Maxwellian velocity generator
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_BIMAXWELL_H__
#define __SAT_BIMAXWELL_H__

#include "math/algebra/vector.h"
#include "math/rand/maxwell.h"

/// @addtogroup simul_pcle
/// @{

/**
 * @brief Bi-Maxwellian velocity generator
 *
 * @revision{1.1}
 * @reventry{2010/06, @jparal}
 * @revmessg{Initial version}
 */
template <class T>
class BiMaxwellRandGen
{
public:
  /// Constructor
  BiMaxwellRandGen () {};
  BiMaxwellRandGen (const Vector<T,3> &b, T vper, T vpar)
  { Initialize (b, vper, vpar); }

  void Initialize (const Vector<T,3> &b, T vper, T vpar);

  Vector<T,3> Get ();
  void Print() const;

private:
  MaxwellRandGen<T> _maxwpe,_maxwpa;
  Vector<T,3> _b,_v1,_v2;
};

/// @}

#endif /* __SAT_BIMAXWELL_H__ */
