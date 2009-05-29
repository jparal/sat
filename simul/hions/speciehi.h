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
  typedef typename HIParticle<T>::TParticle TParticle;
  typedef typename HIParticle<T>::TParticleArray TParticleArray;

  typedef SphereEmitter<T> TSphereEmitter;
  typedef Field<double,3> TWeightField;

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

  TWeightField& GetWeightField ()
  { return _weight; }

  bool Initialized () const
  { return _initialized; }

  /**
   * Initialize specie.
   *
   * @param emit Sphere emitter for this specie.
   * @param nc Number of cells E and B field have.
   */
  void Initialize (TSphereEmitter *emit, Vector<int,3> nc)
  {
    _initialized = true;
    _emit.AttachNew (emit);
    _weight.Initialize (nc);
    _weight = (T)0.;
    // @@@TODO
    _mass = 29.999;
    _qms = 1./_mass;
  }

  void Update (T dt)
  { _emit->Update (dt, _ions, _neut); }

private:
  TParticleArray _ions, _neut; ///< Neutrals and ion particles
  TWeightField _weight;
  T _qms, _mass;
  bool _initialized;
  Ref<TSphereEmitter> _emit;
};

/// @}

#endif /* __SAT_SPECIEHI_H__ */
