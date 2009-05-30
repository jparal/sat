/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   emitter.h
 * @brief  Base class for particle spherical emitters.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_EMITTER_H__
#define __SAT_EMITTER_H__

#include "satbase.h"
#include "satsimul.h"
#include "pclehi.h"

/// @addtogroup hions
/// @{

/**
 * @brief Base class for particle spherical emitters.
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class SphereEmitter : public RefCount
{
public:
  typedef typename HIParticle<T>::TParticle TParticle;
  typedef typename HIParticle<T>::TParticleArray TParticleArray;

  /// Constructor
  SphereEmitter ();
  /// Destructor
  virtual ~SphereEmitter ();

  /// @brief Local initialization of the emitter called from Initialize()
  ///        function.
  /// Override this function if you need a local initialization of the emitter.
  virtual void InitializeLocal (ConfigEntry &cfg,
				const SIHybridUnitsConvert<T> &si2hyb,
				Field<T,2> &src) {}

  /// Return velocity of the newly generated particle at position @p sphl in
  /// spherical coordinates. You can but don't have to change the @p angle
  /// between normal to the surface and the initial velocity when released.
  virtual T GenVelocity (const Vector<T,3> &sphl, T &angle) = 0;

  void Initialize (ConfigEntry &cfg, String tag,
		   const SIHybridUnitsConvert<T> &si2hyb,
		   const Vector<T,3> &pos, T radius);

  bool Enabled () const
  { return _enabled; }

  const String& GetTag () const
  { return _tag; }

  void Update (T dt);
  void EmitPcles (TParticleArray &ions, TParticleArray &neut);

  /// @brief Convert spherical coordinates into global Cartesian.
  /// Parameter @p sph has three components (phi,tht,radius)
  void Sph2CartGlobal (const Vector<T,3> &sphl, Vector<T,3> &cart) const;

  /// @brief Convert spherical coordinates into local Cartesian.
  /// Parameter @p sph has three components (phi,tht,radius)
  void Sph2CartLocal (const Vector<T,3> &sphl, Vector<T,3> &cart) const;

private:
  SIHybridUnitsConvert<T> _si2hyb;
  Field<T,2> _src;   ///< distribution of flux on the surface of sphere
  Field<T,2> _rmsrc; ///< remaining flux (reset by Update to _src)
  String _tag;       ///< tag of the emitter
  bool _enabled;     ///< is emitter enabled
  T _npcles;
  Vector<T,3> _pos;  ///< Position of the sphere in the space.
  T _radius;

  T _ionsratio;
  RandomGen<T> _unirng;     ///< uniform random generator [0,1] for ions/neut ratio
  CosRandGen<T> _vthtrng;   ///< Angle tht of initial velocity [cos(tht) distribution]
};

/// @}

#endif /* __SAT_EMITTER_H__ */
