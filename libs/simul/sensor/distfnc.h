/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   distfnc.h
 * @brief  Particle distribution function sensor.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/08, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_DISTFNC_H__
#define __SAT_DISTFNC_H__

#include "sensor.h"
#include "simul/pcle/camspecie.h"

/// @addtogroup simul_sensor
/// @{

/**
 * @brief Particle distribution function sensor.
 *
 * @revision{1.0}
 * @reventry{2008/08, @jparal}
 * @revmessg{Initial version}
 */
template <class T, int D>
class DistFncSensor : public Sensor
{
public:
  typedef Field<Vector<T,3>,D> TVecField;
  typedef CamSpecie<T,D> TSpecie;
  typedef typename TSpecie::TParticle TParticle;
  typedef RefArray<TSpecie> TSpecieRefArray;

  void Initialize (TSpecieRefArray *sparr, TVecField *bfld,
		   const char *id, ConfigFile &cfg);

  virtual void SaveData (IOManager &iomng, const SimulTime &stime);

private:
  TSpecieRefArray *_species;
  Vector<int,3> _bins;
  Vector<float,3> _vmin, _vmax;
  bool _perpar;
  TVecField *_bfld;
};

/// @}

#endif /* __SAT_DISTFNC_H__ */
