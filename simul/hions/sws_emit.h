/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sws_emit.h
 * @brief  Solar Wind Sputtering (SWS) emitter.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SWS_EMIT_H__
#define __SAT_SWS_EMIT_H__

#include "emitter.h"
#include "math/satrand.h"

/// @addtogroup hions
/// @{

/**
 * @brief Solar Wind Sputtering (SWS) emitter.
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class SWSSphereEmitter : public SphereEmitter<T>
{
public:
  typedef SphereEmitter<T> TBase;
  typedef typename TBase::TParticle TParticle;
  typedef typename TBase::TParticleArray TParticleArray;

  /// Constructor
  SWSSphereEmitter () {};
  /// Destructor
  virtual ~SWSSphereEmitter () {};

  virtual void InitializeLocal (ConfigEntry &cfg, Field<T,2> &src);

  virtual T GenVelocity (const Vector<T,3> &sphl, T &angle)
  { return Math::Sqrt (_2mass * (T)_sigdf.Get ()); }

private:
  T _ebind;
  T _etrans;
  String _mapfname;

  SigmundRandGen _sigdf;
  T _2mass; ///< 2 / mass
};

/// @}

#endif /* __SAT_SWS_EMIT_H__ */
