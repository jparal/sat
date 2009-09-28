/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sensmng.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "sensmng.h"

SensorManager::SensorManager () {}

SensorManager::~SensorManager () {}

void SensorManager::Initialize (const ConfigFile &cfg)
{
  _iomng.Initialize (cfg);
}

void SensorManager::SetNextOutput (SimulTime &stime)
{
  double dt = stime.Dt ();
  int nminiter = stime.ItersLeft ();
  int it = stime.Iter ();

  for (int i=0; i<_sensors.GetSize (); ++i)
  {
    Sensor *sensor = _sensors.Get (i);
    if (!sensor->Enabled ())
      continue;

    double dtout = sensor->GetDtOut ();
    int niter = (int)(0.5 + dtout / dt);

    int tmp = niter;
    while (tmp<=it) tmp += niter;
    niter = tmp - it;

    if (niter<nminiter)
      nminiter = niter;
  }

  stime.SetMilestone (nminiter);
}

bool SensorManager::RequireSave (const char *id, const SimulTime &stime)
{
  for (int i=0; i<_sensors.GetSize (); ++i)
  {
    Sensor *sensor = _sensors.Get (i);
    if (!strcmp (sensor->GetID (), id))
      return sensor->RequireSave (stime);
  }
  return false;
}


void SensorManager::Save (const char *id, const SimulTime &stime)
{
  for (int i=0; i<_sensors.GetSize (); ++i)
  {
    Sensor *sensor = _sensors.Get (i);
    if (!strcmp (sensor->GetID (), id))
      sensor->Save (_iomng, stime);
  }
  DBG_INFO ("saving sensor: done ...");
}

void SensorManager::SaveAll (const SimulTime &stime)
{
  stime.Print ();

  for (int i=0; i<_sensors.GetSize (); ++i)
  {
    Sensor *sensor = _sensors.Get (i);
    sensor->Save (_iomng, stime);
  }
  DBG_INFO ("saving sensor: done ...");
}

void SensorManager::AddSensor (Sensor *sens)
{
  _sensors.PushNew (sens);
}
