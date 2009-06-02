/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   iter.cxx
 * @brief  Single code interation.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#include "hions.h"

template<class T>
void HeavyIonsCode<T>::Iter ()
{
  static int plions = 0, bdions = 0, plneut = 0, bdneut = 0, cleaned = 0;
  static int ionized = 0;
  T dt = _time.Dt ();
  T subdt = dt / _nsub;

  for (int i=0; i<_specs.GetSize(); ++i)
  {
    int plionstmp=0, bdionstmp=0, plneuttmp=0;
    int bdneuttmp = 0, cleanedtmp=0, ionizedtmp = 0;
    TSpecie &sp = *_specs.Get (i);
    if (!sp.Enabled ())
      continue;

    int na = sp.GetNumArrays ();
    SAT_PRAGMA_OMP (parallel for
		    reduction(+:plionstmp,bdionstmp,plneuttmp,
			      bdneuttmp,cleanedtmp,ionizedtmp))
    for (int ia=0; ia<na; ++ia)
    {
      TParticleArray &ions = sp.GetIons (ia);
      TParticleArray &neut = sp.GetNeutrals (ia);
      TWeightField &weight = sp.GetWeightField ();

      SAT_OMP_CRITICAL
	sp.EmitPcles (ions, neut);

      CleanPcles (ions, cleanedtmp);
      CleanPcles (neut, cleanedtmp);

      for (int j=0; j<_nsub; ++j)
      {
	MoveIons (ions, sp.GetQMS(), subdt);
	ApplyBC (ions, bdionstmp, plionstmp);
      }

      Ionize (ions, neut, weight, ionizedtmp);
      MoveNeutrals (neut, dt);
      ApplyBC (neut, bdneuttmp, plneuttmp);
    }

    plions += plionstmp; bdions += bdionstmp; ionized += ionizedtmp;
    plneut += plneuttmp; bdneut += bdneuttmp; cleaned += cleanedtmp;

    sp.Update (_time.Dt ());
  }

  if (_time.Iter () % 50 == 0)
  {
    _time.Print ();
    if (cleaned > 0) DBG_INFO ("particles cleaned: "<<cleaned);
    if (ionized > 0) DBG_INFO ("particles ionized: "<<ionized);
    DBG_INFO ("ions hit planet/boundary: "<<plions<<" / "<<bdions);
    DBG_INFO ("neut hit planet/boundary: "<<plneut<<" / "<<bdneut);

    cleaned = 0; ionized = 0;
    plions = 0; bdions = 0;
    plneut = 0; bdneut = 0;

    int nions = 0, nneut = 0;
    for (int i=0; i<_specs.GetSize(); ++i)
    {
      TSpecie &sp = *_specs.Get (i);
      for (int j=0; j<sp.GetNumArrays(); ++j)
      {
	nions += sp.GetIons (j).GetSize ();
	nneut += sp.GetNeutrals (j).GetSize ();
      }
    }
    DBG_INFO ("ions + neut particles: "<<nions<<" + "<<nneut<<
	      " = "<<nions+nneut);
    SAT_CALLGRIND_DUMP_STATS
  }
}

#include "tmplspec.cpp"
