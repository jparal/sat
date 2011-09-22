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
  : _itout(0), _lastPrint(0) {}

void SimulTime::Initialize (double dt, double tmax,
			    iter_t itbegin, bool restart)
{
  _dt = dt;
  _tmax = tmax;
  _maxiter = (iter_t)(0.5 + tmax / dt);
  _restart = restart;

  if (restart && (itbegin > 0))
  {
    _iter = itbegin;
    _time = itbegin * dt;
  }
  else
  {
    _iter = 0;
    _time = 0.;
  }
}

void SimulTime::Initialize (ConfigEntry &cfg, satversion_t ver)
{
  double dt, max, itstart;
  bool restart;

  cfg.GetValue ("step", dt);
  cfg.GetValue ("tmax", max);

  cfg.GetValue ("itstart", itstart, 0);
  cfg.GetValue ("ncheckpt", _ncheckpt, 10);
  cfg.GetValue ("restart", restart, false);

  Initialize (dt, max, itstart, restart);
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

void SimulTime::Print ()
{
  if (Iter() == _lastPrint && Iter() != 0)
  {
    return;
  }
  else
  {
    DBG_INFO ("***** iteration = "<<
	      Iter ()<<"; time = "<<(float)Time ()<<" *****");
    _lastPrint = Iter();
  }
}

void SimulTime::Save (FILE *file) const
{
  fwrite (&_restart, sizeof(_restart), 1, file);
  fwrite (&_dt, sizeof(_dt), 1, file);
  fwrite (&_time, sizeof(_time), 1, file);
  fwrite (&_tmax, sizeof(_tmax), 1, file);
  fwrite (&_iter, sizeof(_iter), 1, file);
  fwrite (&_itout, sizeof(_itout), 1, file);
  fwrite (&_maxiter, sizeof(_maxiter), 1, file);
  fwrite (&_lastPrint, sizeof(_lastPrint), 1, file);
}

void SimulTime::Load (FILE *file)
{
  fread (&_restart, sizeof(_restart), 1, file);
  fread (&_dt, sizeof(_dt), 1, file);
  fread (&_time, sizeof(_time), 1, file);
  fread (&_tmax, sizeof(_tmax), 1, file);
  fread (&_iter, sizeof(_iter), 1, file);
  fread (&_itout, sizeof(_itout), 1, file);
  fread (&_maxiter, sizeof(_maxiter), 1, file);
  fread (&_lastPrint, sizeof(_lastPrint), 1, file);
}
