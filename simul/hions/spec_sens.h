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

  void Initialize (TSpecie *spec, const Vector<T,3> &dxi,
		   const Vector<int,3> &nc,
		   const char *id, ConfigFile &cfg);

  virtual void SaveData (IOManager &iomng, const SimulTime &stime);

private:
  void CalcDensity (const TParticleArray &pcles, Field<T,3>& dn);

  Field<T,3> _dn;
  TSpecie *_spec;
  Vector<T,3> _dxi;
  Vector<int,3> _nc;
};

/** @} */

#endif /* __SAT_SPEC_SENS_H__ */
