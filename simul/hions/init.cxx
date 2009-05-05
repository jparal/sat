/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   init.cxx
 * @brief  Heavy ions initialization.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#include "hions.h"
#include "sws_emit.h"

template<class T>
HeavyIonsCode<T>::HeavyIonsCode ()
{
}

template<class T>
HeavyIonsCode<T>::~HeavyIonsCode ()
{
}

template<class T>
void HeavyIonsCode<T>::Initialize (int *pargc, char ***pargv)
{
  // Don't initialize MPI but only OpenMP
  Code::Initialize (pargc, pargv, false, true);
  ConfigFile &cfg = Code::GetCfgFile ();
  satversion_t ver = Code::GetCfgVersion ();

  _time.Initialize (cfg, ver);
  cfg.GetValue ("simul.clean", _clean);

  cfg.GetValue ("input.fname", _stwname);
  cfg.GetValue ("input.cells", _nx);
  cfg.GetValue ("input.resol", _dx);
  cfg.GetValue ("input.scalef", _scalef);
  cfg.GetValue ("input.swaccel", _swaccel);
  cfg.GetValue ("input.cgrav", _cgrav);
  cfg.GetValue ("input.planet.rpos", _rx);
  cfg.GetValue ("input.planet.radius", _radius);

  for (int i=0; i<3; ++i)
  {
    _dxi[i] = (T)1./_dx[i];
    _lx[i] = _nx[i] * _dx[i];
    _plpos[i] = _lx[i] * _rx[i];
  }

  DBG_LINE ("Heavy Ions:");
  DBG_INFO ("clean particle every:   "<<_clean);
  DBG_INFO ("input STW file name:    "<<_stwname);
  DBG_INFO ("number of cells:        "<<_nx);
  DBG_INFO ("resolution of STW data: "<<_dx);
  DBG_INFO ("scale factor of ions:   "<<_scalef);
  DBG_INFO ("planet relative pos:    "<<_rx);
  DBG_INFO ("planet absolute pos:    "<<_plpos);
  DBG_INFO ("planet radius:          "<<_radius);
  DBG_INFO ("SW acceleration:        "<<_swaccel);
  DBG_INFO ("gravitation constant:   "<<_cgrav);

  DBG_LINE ("Release:");
  ConfigEntry &entry = cfg.GetEntry ("release");

  SWSSphereEmitter<T> *swsemit = new SWSSphereEmitter<T>;
  swsemit->Initialize (entry, "sws", _plpos, _radius);
  TSpecie *swssp = new TSpecie;
  swssp->Initialize (swsemit);
  _specs.PushNew (swssp);

  DBG_LINE ("Sensors:");
  _sensmng.Initialize (cfg);

  LoadFields ();
  ResetFields ();
}

#include "tmplspec.h"

