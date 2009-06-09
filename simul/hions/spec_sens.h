/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   spec_sens.h
 * @brief  Heavy ions specie sensor.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SPEC_SENS_H__
#define __SAT_SPEC_SENS_H__

#include "satio.h"
#include "simul/satsensor.h"

#include "speciehi.h"

/** @addtogroup simul_sensor
 *  @{
 */

/**
 * @brief Heavy ions specie sensor.
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class HISpecieSensor : public Sensor
{
public:
  using Sensor::SaveData;
  typedef HISpecie<T> TSpecie;
  typedef typename TSpecie::TParticle TParticle;
  typedef typename TSpecie::TParticleArray TParticleArray;

  void Initialize (TSpecie *spec, const Vector<T,3> &dx,
		   const Vector<int,3> &nc,
		   const char *id, ConfigFile &cfg);

  virtual void InitializeLocal (const ConfigEntry &cfg);

  virtual void SaveData (IOManager &iomng, const SimulTime &stime);

private:
  void AddDensity (const TParticleArray &pcles, Field<T,3> &dn);
  void AddEnergy (const TParticleArray &pcles, Field<T,3> &en);

  TSpecie *_spec;
  Vector<T,3> _dxi;
  Vector<T,3> _sdx; ///< sensor resolution
  Vector<int,3> _nc;
};

/** @} */

#endif /* __SAT_SPEC_SENS_H__ */
