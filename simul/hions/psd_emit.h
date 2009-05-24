/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   psd_emit.h
 * @brief  Photo-stimulated desorption (PSD) sphere emitter.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_PSD_EMIT_H__
#define __SAT_PSD_EMIT_H__

#include "emitter.h"
#include "math/satrand.h"

/// @addtogroup hions
/// @{

/**
 * @brief Photo-stimulated desorption (PSD) sphere emitter.
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class PSDSphereEmitter : public SphereEmitter<T>
{
public:
  typedef SphereEmitter<T> TBase;
  typedef typename TBase::TParticle TParticle;
  typedef typename TBase::TParticleArray TParticleArray;

  /// Constructor
  PSDSphereEmitter () {};
  /// Destructor
  virtual ~PSDSphereEmitter () {};

  virtual void InitializeLocal (ConfigEntry &cfg,
				const SIHybridUnitsConvert<T> &si2hyb,
				Field<T,2> &src);

  virtual T GenVelocity (const Vector<T,3> &sphl, T &angle)
  { return _si2hyb.Speed (Math::Sqrt (_conv * _psddf.Get())); }

private:
  T _ubind;
  T _xpar;

  SIHybridUnitsConvert<T> _si2hyb;
  PSDRandGen _psddf;

  /**
   * This constant holds all constants from the expression:
   * _conv = 2 * M_PHYS_E / mass in m_i units * M_PHYS_MI
   */
  T _conv;
};

/// @}

#endif /* __SAT_PSD_EMIT_H__ */
