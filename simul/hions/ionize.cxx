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
void HeavyIonsCode<T>::Ionize (TParticleArray &ions, TParticleArray &neut,
			       TWeightField &weight, int &ionized)
{
  T pwght, awght, dwght, ionize = _time.Dt() * _cionize;
  Vector<int,3> ip;

  int ionizedtmp = 0;
  int npcles = (int)neut.GetSize ();
  for (int pc=0; pc<npcles; ++pc)
  {
    TParticle &pcle = neut.Get (pc);
    pwght = pcle.GetWeight ();
    if (pwght < (T)0.)
      continue;

    const Vector<T,3> &xp = pcle.GetPosition ();
    const T yr = xp[1] - _plpos[1];
    const T zr = xp[2] - _plpos[2];
    if ((_plpos[0] < xp[0]) && (yr*yr+zr*zr < _radius2))
      continue; // Particle is hidden behind the planet

    dwght = pwght * ionize;
    pwght -= dwght;
    // Turn off this neutral particle (it is already tired ;)
    if (pwght < 0.01) pwght = -1.;

    for (int i=0; i<3; ++i) ip[i] = (int)Math::Floor (xp[i] *_dxi[i]);

    SAT_OMP_CRITICAL
    {
      awght = weight(ip) + dwght;
      // update weight of the field
      if (awght > (T)1.01)
	weight(ip) = awght - (T)1.;
      else
	weight(ip) = awght;
    }

    // Emit new ion with the same velocity and position as neutral.  This
    // should provide the same random velocity distribution as neutrals have at
    // this location.
    if (awght > (T)1.01)
    {
      pcle.Weight() = (T)1.;
      ions.Push (pcle);

      ++ionizedtmp;
    }

    // update weight of the particle
    pcle.Weight() = pwght;
  }

  ionized += ionizedtmp;
}

#include "tmplspec.cpp"
