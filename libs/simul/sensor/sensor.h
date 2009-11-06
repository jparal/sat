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

/// @addtogroup simul_sensor
/// @{

/**
 * @brief Base class of all sensors
 *
 * @todo May it would be worth to change SupportPerPar into "pure" function and
 *       improve sensor hierarchy and implement as necessary.
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 * @reventry{2009/01, @jparal}
 * @revmessg{add perpendicular and parallel output support}
 * @revmessg{implement GetTag(int) function}
 */
class Sensor : public RefCount
{
public:
  /// Constructor
  Sensor ();
  /// Destructor
  virtual ~Sensor ();

  void Initialize (const char *id, ConfigFile &cfg);

  /// This function is called from Initialize() with sensor entry from
  /// configuration file in the parameter @p cfg for extra initialization.
  virtual void InitializeLocal (const ConfigEntry &cfg) {};

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

  String GetTag (const String &pre, const String &post = "") const;

  /// return TAG# where number represent the specie
  String GetTag (int i) const;

  bool Enabled () const
  { return _enabled; }

  /// Overwrite this function when you support Perpendicular/Parallel output
  virtual bool SupportPerPar () const
  { return false; }

  bool PerPar () const
  { return _perpar; }

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
  bool _perpar;
  bool _skip0; ///< Skip zero iteration output.
};

/// @}

#endif /* __SAT_SENSOR_H__ */
