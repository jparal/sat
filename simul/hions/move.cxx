/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   move.cxx
 * @brief  Move particles due to the EM forces as well as gravitation and solar
 *         wind pressure.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#include "hions.h"

template<class T>
void HeavyIonsCode<T>::MoveNeutrals (TSpecie &sp)
{
  TVector ap;

  TParticleArray &pcles = sp.GetNeutrals ();
  T dt = _time.Dt ();

  int npcles = (int)pcles.GetSize ();
  SAT_PRAGMA_OMP (parallel for private(ap) schedule(static))
  for (int pc=0; pc<npcles; ++pc)
  {
    TParticle &pcle = pcles.Get (pc);
    if (pcle.GetWeight () < 0.)
      continue;

    TVector &xp = pcle.GetPosition ();
    TVector &vp = pcle.GetVelocity ();
    CalcAccel (xp, ap);

    // Velocity advance
    vp += dt * ap;
    // Position advance
    xp += dt * vp;
  }
}

template<class T>
void HeavyIonsCode<T>::MoveIons (TSpecie &sp, T dt)
{
  TVector vh, ep, bp, xt;
  BilinearWeightCache<T,3> cache;

  T dtf = _scalef * dt * sp.GetQMS ();
  T dth = 0.5 * dtf;

  TParticleArray &pcles = sp.GetIons ();

  int npcles = SAT_STATIC_CAST (int, pcles.GetSize ());
  SAT_PRAGMA_OMP (parallel for private(vh,ep,bp,xt,cache) schedule(static))
  for (int pc=0; pc<npcles; ++pc)
  {
    TParticle &pcle = pcles.Get (pc);
    if (pcle.GetWeight () < 0.)
      continue;

    TVector &xp = pcle.GetPosition ();
    TVector &vp = pcle.GetVelocity ();

    pcle.GetPosition (xt);
    for (int i=0; i<3; ++i) xt[i] *= _dxi[i];

    CartStencil::BilinearWeight (_B, xt, cache, bp); // store in cache
    CartStencil::BilinearWeight (_E, cache, ep);     // compute from cache

    // Velocity advance
    vh = vp;
    vh += dth * (ep + vp % bp);
    vp += dtf * (ep + vh % bp);

    // Position advance
    for (int i=0; i<3; ++i) xp[i] += dt * vp[i];
  }
}

#include "tmplspec.cpp"
