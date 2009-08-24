/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   pcle_sens.h
 * @brief  Heavy ions particle trajectory sensor.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_PCLE_SENS_H__
#define __SAT_PCLE_SENS_H__

#include "satio.h"
#include "simul/satsensor.h"

#include "speciehi.h"

#ifdef HAVE_H5PART
#define PARALLEL_IO
#include "H5Part.h"
#undef PARALLEL_IO
#endif

/** @addtogroup simul_sensor
 *  @{
 */

/**
 * @brief Heavy ions particle trajectory sensor.
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class HIParticleSensor : public Sensor
{
public:
  using Sensor::SaveData;
  typedef HISpecie<T> TSpecie;
  typedef typename TSpecie::TParticle TParticle;
  typedef typename TSpecie::TParticleArray TParticleArray;

  ~HIParticleSensor ();

  void Initialize (TSpecie *spec, const char *id, ConfigFile &cfg);

  virtual void InitializeLocal (const ConfigEntry &cfg);

  virtual void SaveData (IOManager &iomng, const SimulTime &stime);

private:
#ifdef HAVE_H5PART
  H5PartFile *_file;
#endif // HAVE_H5PART

  TSpecie *_spec;
  int _npcle;
};

/** @} */

#endif /* __SAT_PCLE_SENS_H__ */
