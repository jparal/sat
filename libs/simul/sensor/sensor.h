/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sensor.h
 * @brief  Base class of all sensors
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SENSOR_H__
#define __SAT_SENSOR_H__

#include "satbase.h"
#include "io/misc/iomanager.h"
#include "simul/misc/simtime.h"

/** @addtogroup simul_sensor
 *  @{
 */

/**
 * @brief Base class of all sensors
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
class Sensor : public RefCount
{
public:
  /// Constructor
  Sensor ();
  /// Destructor
  virtual ~Sensor ();

  void Initialize (const char *id, ConfigFile &cfg);

  bool RequireSave (const SimulTime &stime);

  /// Check whether we need to save and call SaveData ()
  void Save (IOManager &iomng, const SimulTime &stime);

  /// Actual function saving the data (overloaded by all sensors)
  virtual void SaveData (IOManager &iomng, const SimulTime &stime) {};

  const char* GetEntryID () const
  { return _eid.GetData (); }

  const char* GetID () const
  { return _id.GetData (); }

  const char* GetTag () const
  { return _tag.GetData (); }

  bool Enabled () const
  { return _enabled; }

  double GetDtOut () const
  { return _dtout; }

  void SetDtOut (double dtout)
  { _dtout = dtout; }

private:
  String _id;
  String _tag;
  String _eid; ///< ConfigEntry ID
  double _dtout;
  bool _enabled;
};

/** @} */

#endif /* __SAT_SENSOR_H__ */
