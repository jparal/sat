/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   applybc.cxx
 * @brief  Apply boundary conditions
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#include "hions.h"

template<class T>
void HeavyIonsCode<T>::ApplyBC (TParticleArray &pcles, int &bdhit, int &plhit)
{
  int bdtmp = 0, pltmp = 0;

  const T r2 = _radius * _radius;
  int npcles = (int)pcles.GetSize ();
  SAT_PRAGMA_OMP (parallel for reduction(+:bdtmp, pltmp) schedule(static))
  for (int pc=0; pc<npcles; ++pc)
  {
    TParticle &pcle = pcles.Get (pc);
    if (pcle.GetWeight () < 0.)
      continue;

    // make a copy of the position for later
    TVector xp;
    pcle.GetPosition (xp);
    for (int i=0; i<3; ++i)
    {
      // is particle out of the box in j-th dimension?
      if (xp[i] <= (T)0. || _lx[i] <= xp[i])
      {
	pcle.Weight () = -1.;
	++bdtmp;
	break;
      }
    }

    // is particle inside of the planet?
    xp -= _plpos;
    if (xp.SquaredNorm () < r2)
    {
      //      m_mercury.AddParticle (pcle);
      pcle.Weight () = -1.;
      ++pltmp;
    }
  }

  bdhit += bdtmp;
  plhit += pltmp;
}

template<class T>
void HeavyIonsCode<T>::CheckPosition (TParticleArray &pcles)
{
  const T r2 = _radius * _radius;
  int npcles = SAT_STATIC_CAST (int, pcles.GetSize ());
  SAT_PRAGMA_OMP (parallel for schedule(static))
  for (int i=0; i<npcles; ++i)
  {
    TParticle &pcle = pcles.Get (i);
    if (pcle.GetWeight () < 0.)
      continue;

    // make a copy of the position for later
    TVector xp = pcle.GetPosition ();
    for (int j=0; j<3; ++j)
    {
      // is particle out of the box in j-th dimension?
      if (xp[j] < (T)0. || _lx[j] < xp[j])
      {
	DBG_WARN ("Pcle out of box ID="<<i<<": "<<xp);
	break;
      }
    }

    // is particle inside of the planet?
    xp -= _plpos;
    if (xp.SquaredNorm () < r2)
    {
      DBG_WARN ("Pcle inside of planet ID="<<i<<": "<<xp);
    }
  }
}

#include "tmplspec.h"
