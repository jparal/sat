/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   ionize.cxx
 * @brief  Ionize particles
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#include "hions.h"

template<class T>
void HeavyIonsCode<T>::Ionize (TSpecie &sp, int &ionized)
{
  T wght, wnew, dw, ionize = _time.Dt() * _cionize;
  const T r2 = _radius * _radius;
  Vector<int,3> ip;

  TParticleArray &ions = sp.GetIons ();
  TParticleArray &neut = sp.GetNeutrals ();
  TWeightField &weight = sp.GetWeightField ();

  int ionizedtmp = 0;
  int npcles = (int)neut.GetSize ();
  SAT_PRAGMA_OMP (parallel for reduction(+:ionizedtmp) private(wnew,wght,dw,ip)
		  schedule(static))
  for (int pc=0; pc<npcles; ++pc)
  {
    TParticle &pcle = neut.Get (pc);
    if (pcle.GetWeight() < 0.)
      continue;

    const Vector<T,3> &xp = pcle.GetPosition ();
    const T yr = xp[1] - _plpos[1];
    const T zr = xp[2] - _plpos[2];
    if ((_plpos[0] < xp[0]) && (yr*yr+zr*zr < r2))
      continue; // Particle is hidden behind the planet

    wght = pcle.GetWeight();
    dw = wght * ionize;
    wght -= dw;

    for (int i=0; i<3; ++i) ip[i] = (int)Math::Floor (xp[i] *_dxi[i]);
    wnew = weight(ip) + dw;

    // Emit new ion with the same velocity and position as neutral.  This
    // should provide the same random velocity distribution as neutrals have at
    // this location.
    if (wnew > (T)1.01)
    {
      pcle.Weight() = (T)1.;
      SAT_PRAGMA_OMP (critical)
	ions.Push (pcle);

      ++ionizedtmp;
      wnew -= (T)1.;
    }

    // Turn off this neutral particle (it is already tired)
    if (wnew < 0.01)
      wght = -1.;

    weight(ip) = wnew;
    pcle.Weight() = wght;
  }

  ionized += ionizedtmp;
}

#include "tmplspec.cpp"
