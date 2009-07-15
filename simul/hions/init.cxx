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
#include "psd_emit.h"
#include "spec_sens.h"

template<class T>
HeavyIonsCode<T>::HeavyIonsCode () {}

template<class T>
HeavyIonsCode<T>::~HeavyIonsCode () {}

template<class T>
void HeavyIonsCode<T>::Initialize (int *pargc, char ***pargv)
{
  // Don't initialize MPI but only OpenMP
  Code::Initialize (pargc, pargv, false, true);
  SAT::EnableFPException ();
  ConfigFile &cfg = Code::GetCfgFile ();
  satversion_t ver = Code::GetCfgVersion ();
  T tphoto;
  _time.Initialize (cfg, ver);

  ConfigEntry &ehc = cfg.GetEntry ("input.hybridconv");
  _si2hyb.Initialize (ehc);

  DBG_LINE ("Unit Converter:");
  DBG_INFO ("Time [s]:       "<<_si2hyb.Time (1, true));
  DBG_INFO ("Length [km]:    "<<_si2hyb.Length (1, true)/1000);
  DBG_INFO ("Speed [km/s]:   "<<_si2hyb.Speed (1, true)/1000);
  DBG_INFO ("Accel [km/s^2]: "<<_si2hyb.Accel (1, true)/1000);

  cfg.GetValue ("simul.clean", _clean);
  cfg.GetValue ("simul.nsub", _nsub);
  cfg.GetValue ("input.fname", _stwname);
  cfg.GetValue ("input.cells", _nx);
  cfg.GetValue ("input.resol", _dx);
  //  cfg.GetValue ("input.scalef", _scalef);
  cfg.GetValue ("input.swaccel", _swaccel);
  cfg.GetValue ("input.tphoto", tphoto);
  cfg.GetValue ("input.distau", _distau);
  cfg.GetValue ("input.planet.rpos", _rx);
  cfg.GetValue ("input.planet.radius", _radius);
  _radius2 = _radius*_radius;

  for (int i=0; i<3; ++i)
  {
    _dxi[i] = (T)1./_dx[i];
    _lx[i] = _nx[i] * _dx[i];
    _plpos[i] = _lx[i] * _rx[i];
  }
  _swaccel = _si2hyb.Accel (_swaccel);

  tphoto = _si2hyb.Time(tphoto) * (_distau*_distau)/(0.386*0.386);
  _cionize = (T)1./tphoto;
  _cgrav = _si2hyb.Accel (M_PHYS_MERCURY_GRAV) * _radius2;

  // s_qms = R_M,orig / R_M,scaled
  double rmorig = _si2hyb.Length (M_PHYS_MERCURY_RADIUS*1000.);
  _scalef = rmorig / _radius;

  DBG_LINE ("Heavy Ions:");
  DBG_INFO ("sub-steps for ions:     "<<_nsub);
  DBG_INFO ("clean particle every:   "<<_clean);
  DBG_INFO ("input STW file name:    "<<_stwname);
  DBG_INFO ("number of cells:        "<<_nx);
  DBG_INFO ("resolution of STW data: "<<_dx);
  DBG_INFO ("planet relative pos:    "<<_rx);
  DBG_INFO ("planet absolute pos:    "<<_plpos);
  DBG_INFO ("planet radius [orig]:   "<< rmorig);
  DBG_INFO ("planet radius [scaled]: "<<_radius);
  DBG_INFO ("scale factor of ions:   "<<_scalef);
  DBG_INFO ("accel of solar wind:    "<<_swaccel);
  DBG_INFO ("accel of gravitation:   "<<_cgrav/_radius2);
  DBG_INFO ("ionization constant:    "<<_cionize*_time.Dt());

  DBG_LINE ("Release:");
  ConfigEntry &entry = cfg.GetEntry ("release");

  int nthread = Omp::GetNumThreads ();
  SWSSphereEmitter<T> *swsemit = new SWSSphereEmitter<T>;
  PSDSphereEmitter<T> *psdemit = new PSDSphereEmitter<T>;
  TSpecie *swsspec = new TSpecie;
  TSpecie *psdspec = new TSpecie;

  swsemit->Initialize (entry, "sws", _si2hyb, _plpos, _radius);
  psdemit->Initialize (entry, "psd", _si2hyb, _plpos, _radius);
  swsspec->Initialize (swsemit, _nx, nthread);
  psdspec->Initialize (psdemit, _nx, nthread);

  _specs.PushNew (swsspec);
  _specs.PushNew (psdspec);

  DBG_LINE ("Sensors:");
  _sensmng.Initialize (cfg);

  if (swsemit->Enabled ())
  {
    HISpecieSensor<T> *swssens = new HISpecieSensor<T>;
    swssens->Initialize (swsspec, _dx, _nx, "swsspec", cfg);
    _sensmng.AddSensor (swssens);
  }

  if (psdemit->Enabled ())
  {
    HISpecieSensor<T> *psdsens = new HISpecieSensor<T>;
    psdsens->Initialize (psdspec, _dx, _nx, "psdspec", cfg);
    _sensmng.AddSensor (psdsens);
  }

  LoadFields ();
  ResetFields ();
}

#include "tmplspec.cpp"

