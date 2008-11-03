/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   simtime.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/02, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "simtime.h"
#include "satbase.h"

SimulTime::SimulTime ()
{
  _itout = 0;
}

void SimulTime::Initialize (double dt, double tmax, bool restart, double tbeg)
{
  _dt = dt;
  _tmax = tmax;
  _maxiter = (iter_t)(0.5 + tmax / dt);
  _restart = restart;

  if (restart && (tbeg > 0.))
  {
    _iter = (iter_t)(0.5 + tbeg / dt);
    _time = tbeg;
  }
  else
  {
    _iter = 0;
    _time = 0.;
  }
}

void SimulTime::Initialize (ConfigEntry &cfg, satversion_t ver)
{
  double dt, max, start;
  bool restart;

  cfg.GetValue ("step", dt);
  cfg.GetValue ("max", max);

  cfg.GetValue ("start", start, 0.);
  cfg.GetValue ("restart", restart, false);

  Initialize (dt, max, restart, start);
}

void SimulTime::Initialize (ConfigFile &cfg, satversion_t ver)
{
  const char *ename = "simul";

  SAT_ASSERT_MSG (cfg.Exists (ename), "Configure entry doesn't exists: simul");

  ConfigEntry &entry = cfg.GetEntry (ename);
  Initialize (entry, ver);
}

bool SimulTime::HasNext () const
{
  int maxiter;
  if (_itout > 0)
    maxiter = _itout;
  else
    maxiter = _maxiter;

  if (_iter>=maxiter)
    return false;

  return true;
}

bool SimulTime::Next ()
{
  bool hasnext = HasNext ();

  if (hasnext)
  {
    ++_iter;
    _time = (double)_iter * _dt;
  }

  return hasnext;
}

void SimulTime::SetMilestone (iter_t niter)
{
  _itout = _iter + niter;
}

void SimulTime::IterStr (char *buff, int size, bool fill) const
{
  if (!fill)
  {
    snprintf (buff,size,"%d", _iter);
    return;
  }

  int places = 0;
  int tmp = _maxiter;
  while (tmp>0) { tmp /= 10; ++places; }
  snprintf (buff,size,"%0*d", places, _iter);
}
