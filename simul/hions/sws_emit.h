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

  virtual void InitializeLocal (ConfigEntry &cfg,
				const SIHybridUnitsConvert<T> &si2hyb,
				Field<T,2> &src);

  virtual T GenVelocity (const Vector<T,3> &sphl, T &angle)
  { return _si2hyb.Speed (Math::Sqrt (_conv * _sigdf.Get())); }

private:
  T _ebind;
  T _etrans;
  String _mapfname;
  SIHybridUnitsConvert<T> _si2hyb;
  SigmundRandGen _sigdf;

  /**
   * This constant holds all constants from the expression:
   * _conv = 2 * M_PHYS_E / mass in m_i units * M_PHYS_MI
   */
  T _conv;
};

/// @}

#endif /* __SAT_SWS_EMIT_H__ */
