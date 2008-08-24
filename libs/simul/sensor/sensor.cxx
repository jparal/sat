/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sensor.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "sensor.h"

#define SENS_ENTRY_SIZE 64

Sensor::Sensor ()
{
  _enabled = false;
  _dtout = 1.;
}

Sensor::~Sensor ()
{}

void
Sensor::Initialize (const char *id, ConfigFile &cfg)
{
  _id = id;
  char sensentry[SENS_ENTRY_SIZE];
  snprintf (sensentry, SENS_ENTRY_SIZE, "output.sensors.%s", id);

  // Enable/Disable
  if (!cfg.Exists (sensentry))
  {
    _enabled = false;
    DBG_WARN ("sensor disabled: "<<_id);
    return;
  }
  else
  {
    _enabled = true;
  }

  ConfigEntry &ent = cfg.GetEntry (sensentry);
  // ent.GetValue ("enable", _enabled, true);
  // Read global value of dtout first
  cfg.GetValue ("output.dtout", _dtout, 1.0);
  if (ent.Exists ("dtout"))
    ent.GetValue ("dtout", _dtout, _dtout);
  ent.GetValue ("tag", _tag, id);

  DBG_INFO ("sensor ("<<_id<<"): dtout "<<_dtout<<" ; tag "<<_tag);
}

bool Sensor::RequireSave (const SimulTime &stime)
{
  int niter = (int)(0.5 + GetDtOut () / stime.Dt ());
  return (stime.Iter () % niter == 0);
}

void Sensor::Save (IOManager &iomng, const SimulTime &stime)
{
  if (RequireSave (stime) && _enabled)
  {
    DBG_INFO ("saving sensor: "<<_id);
    SaveData (iomng, stime);
  }
}
