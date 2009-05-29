/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   pclehi.h
 * @brief  Particle information for HIons
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_PCLEHI_H__
#define __SAT_PCLEHI_H__

#include "math/algebra/vector.h"

/// @addtogroup hions
/// @{

/**
 * @brief Particle information for HIons
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */
template <class T>
class HIParticle
{
public:
  typedef HIParticle<T> TParticle;
  typedef Array<TParticle,
		ArrayElementHandler<TParticle>,
		SAT::Container::ArrayAllocDefault,
		SAT::Container::ArrayCapacityExponential<1<<30> > TParticleArray;

  //// Constructor
  HIParticle ()
    : _wht(0) {}

  /// Destructor
  ~HIParticle () {};

  void SetVelocity (const Vector<T,3> &vel)
  { _vel = vel; }

  void SetPosition (const Vector<T,3> &pos)
  { _pos = pos; }

  const Vector<T,3>& GetVelocity () const
  { return _vel; }

  Vector<T,3>& GetVelocity ()
  { return _vel; }

  const Vector<T,3>& GetPosition () const
  { return _pos; }

  Vector<T,3>& GetPosition ()
  { return _pos; }

  void GetPosition (Vector<T,3> &pos)
  { pos = _pos; }

  T GetWeight () const
  { return _wht; }

  T& Weight ()
  { return _wht; }

  void SetWeight (T wht)
  { _wht = wht; }

private:
  Vector<T,3> _vel, _pos;
  T _wht; // weight
};

/// @}

#endif /* __SAT_PCLEHI_H__ */
