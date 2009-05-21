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
void HISpecieSensor<T>::Initialize (TSpecie *spec, const Vector<T,3> &dxi,
				    const Vector<int,3> &nc,
				    const char *id, ConfigFile &cfg)
{
  Sensor::Initialize (id, cfg);
  _spec = spec;
  _dxi = dxi;
  _nc = nc;
}

template<class T>
void HISpecieSensor<T>::SaveData (IOManager &iomng, const SimulTime &stime)
{
  _dn.Initialize (_nc);

  CalcDensity (_spec->GetIons (), _dn);
  iomng.Write (_dn, stime, GetTag ("Dni"));
  CalcDensity (_spec->GetNeutrals (), _dn);
  iomng.Write (_dn, stime, GetTag ("Dnn"));

  _dn.Free ();
}

template<class T>
void HISpecieSensor<T>::CalcDensity (const TParticleArray &pcles,
				     Field<T,3>& dn)
{
  dn = (T)0.;
  Vector<T,3> xt;

  int npcles = (int)pcles.GetSize ();
  //  SAT_PRAGMA_OMP (parallel for private(xt) schedule(static))
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
