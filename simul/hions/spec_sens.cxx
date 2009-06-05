/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   spec_sens.cxx
 * @brief  Specie sensor.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */

#include "spec_sens.h"

template<class T>
void HISpecieSensor<T>::Initialize (TSpecie *spec, const Vector<T,3> &dx,
				    const Vector<int,3> &nc,
				    const char *id, ConfigFile &cfg)
{
  Sensor::Initialize (id, cfg);

  if (Enabled ())
  {
    _spec = spec;
    for (int i=0; i<3; ++i)
    {
      _nc[i] = nc[i] * dx[i] / _sdx[i];
      _dxi[i] = (T)1. / _sdx[i];
    }
    DBG_INFO ("  resol  : "<<_sdx);
  }
}

template<class T>
void HISpecieSensor<T>::InitializeLocal (const ConfigEntry &cfg)
{
  cfg.GetValue ("resol", _sdx);
}

template<class T>
void HISpecieSensor<T>::SaveData (IOManager &iomng, const SimulTime &stime)
{
  _dn.Initialize (_nc);

  _dn = (T)0.;
  for (int i=0; i<_spec->GetNumArrays(); ++i)
    AddDensity (_spec->GetIons (i), _dn);

  _dn *= _spec->GetEmitter().GetDnHyb2SI (stime.Dt (), _sdx);
  iomng.Write (_dn, stime, GetTag ("Dni"));

  _dn = (T)0.;
  for (int i=0; i<_spec->GetNumArrays(); ++i)
    AddDensity (_spec->GetNeutrals (i), _dn);

  _dn *= _spec->GetEmitter().GetDnHyb2SI (stime.Dt (), _sdx);
  iomng.Write (_dn, stime, GetTag ("Dnn"));

  _dn.Free ();
}

template<class T>
void HISpecieSensor<T>::AddDensity (const TParticleArray &pcles,
				    Field<T,3> &dn)
{
  Vector<T,3> xt;

  int npcles = (int)pcles.GetSize ();
  for (int pc=0; pc<npcles; ++pc)
  {
    const TParticle &pcle = pcles.Get (pc);
    if (pcle.GetWeight () < 0.)
      continue;

    const Vector<T,3> &xp = pcle.GetPosition ();
    for (int i=0; i<3; ++i) xt[i] = xp[i] * _dxi[i];
    CartStencil::BilinearWeightAdd (dn, xt, pcle.GetWeight ());
  }
}

template class HISpecieSensor<float>;
template class HISpecieSensor<double>;
