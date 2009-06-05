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
  typedef Array<TParticleArray> TParticleArrayArray;

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

  TParticleArray& GetIons (int i)
  { return _ions[i]; }

  TParticleArray& GetNeutrals (int i)
  { return _neut[i]; }

  TWeightField& GetWeightField ()
  { return _weight; }

  int GetNumArrays ()
  { return _numarrays; }

  bool Initialized () const
  { return _initialized; }

  bool Enabled () const
  { return _emit->Enabled (); }

  const TSphereEmitter& GetEmitter () const
  { return *_emit; }

  /**
   * Initialize specie.
   *
   * @param emit Sphere emitter for this specie.
   * @param nc Number of cells E and B field have.
   */
  void Initialize (TSphereEmitter *emit, Vector<int,3> nc, int numarrays);

  void Update (T dt)
  { _emit->Update (dt); }

  void EmitPcles (TParticleArray &ions, TParticleArray &neut)
  { _emit->EmitPcles (ions, neut); }

private:
  TParticleArrayArray _ions, _neut; ///< Neutrals and ion particles
  TWeightField _weight;
  int _numarrays;
  T _qms, _mass;
  bool _initialized;
  Ref<TSphereEmitter> _emit;
};

/// @}

#endif /* __SAT_SPECIEHI_H__ */
