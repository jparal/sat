/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   fldsens.h
 * @brief  Field class sensor
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_FLDSENS_H__
#define __SAT_FLDSENS_H__

#include "sensor.h"
#include "satio.h"

/// @addtogroup simul_sensor
/// @{

/**
 * @brief Vector Field sensor
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int R, int D>
class VecFieldSensor : public Sensor
{
public:
  using Sensor::SaveData;

  /// Constructor
  VecFieldSensor () {};
  /// Destructor
  ~VecFieldSensor () {};

  void Initialize (ConfigFile &cfg, const char *id, Field<Vector<T,R>,D> *fld)
  {
    Sensor::Initialize (cfg, id);
    _fld = fld;
  }

  virtual void SaveData (IOManager &iomng, const SimulTime &stime)
  {
    iomng.Write (*_fld, stime, GetTag ());
  }

private:
  Field<Vector<T,R>,D> *_fld;
};

/**
 * @brief Scalar Field sensor
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D>
class ScaFieldSensor : public Sensor
{
public:
  void Initialize (ConfigFile &cfg ,const char *id, Field<T,D> *fld)
  {
    Sensor::Initialize (cfg, id);

    _fld = fld;
  }

  virtual void SaveData (IOManager &iomng, const SimulTime &stime)
  {
    iomng.Write (*_fld, stime, GetTag ());
  }

private:
  Field<T,D> *_fld;
};

/// @}

#endif /* __SAT_FLDSENS_H__ */
