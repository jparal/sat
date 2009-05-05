/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   speciehi.h
 * @brief  Specie for Heavy Ions application.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SPECIEHI_H__
#define __SAT_SPECIEHI_H__

#include "pclehi.h"
#include "emitter.h"

/// @addtogroup hions
/// @{

/**
 * @brief Specie for Heavy Ions application.
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */
template <class T>
class HISpecie : public RefCount
{
public:
  typedef HIParticle<T> TParticle;
  typedef Array<TParticle> TParticleArray;
  typedef SphereEmitter<T> TSphereEmitter;

  /// Constructor
  HISpecie ()
    : _initialized(false) {};

  /// Destructor
  ~HISpecie () {};

  T GetMass () const
  { return _mass; }

  T GetQMS () const
  { return _qms; }

  TParticleArray& GetIons ()
  { return _ions; }

  TParticleArray& GetNeutrals ()
  { return _neut; }

  bool Initialized () const
  { return _initialized;}

  void Initialize (TSphereEmitter *emit)
  { _emit.AttachNew (emit); }

  void Update (T dt)
  { _emit->Update (dt, _ions, _neut); }

private:
  TParticleArray _ions, _neut; ///< Neutrals and ion particles
  T _qms, _mass;
  bool _initialized;
  Ref<TSphereEmitter> _emit;
};

/// @}

#endif /* __SAT_SPECIEHI_H__ */
