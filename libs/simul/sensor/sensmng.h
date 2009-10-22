/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sensmng.h
 * @brief  Sensor manager
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SENSMNG_H__
#define __SAT_SENSMNG_H__

#include "satbase.h"
#include "io/misc/iomanager.h"
#include "simul/misc/simtime.h"
#include "sensor.h"

/// @addtogroup simul_sensor
/// @{

/**
 * @brief Sensor manager
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
class SensorManager
{
public:
  /// Constructor
  SensorManager ();
  /// Destructor
  ~SensorManager ();

  void Initialize (const ConfigFile &cfg);

  /**
   * Modify SimulTime to set the next output time
   *
   * @param stime Current simulation time
   */
  void SetNextOutput (SimulTime &stime);

  bool RequireSave (const char *id, const SimulTime &stime);

  /**
   * Add sensor (or register) into the internal list of all sensors.
   *
   * @param sens pointer to the sensor
   */
  void AddSensor (Sensor *sens);

  /**
   * Tell SensorManager he can save the sensor.
   * @note It is not necessary that sensor will be saved. This can happen when
   *       another sensor requested simulation to save its output.
   *
   * @param id Unique identifier which is defined in configure
   *           file (i.e. mgfield, elfield, ...)
   * @param stime Current simulation time
   */
  void Save (const char* id, const SimulTime &stime);

  void SaveAll (const SimulTime &stime);

private:
  RefArray<Sensor> _sensors;
  IOManager _iomng;
  int _version;
};

/// @}

#endif /* __SAT_SENSMNG_H__ */
