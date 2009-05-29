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
  T subdt = _time.Dt() / _nsub;

  for (int i=0; i<_specs.GetSize(); ++i)
  {
    TSpecie &sp = *_specs.Get (i);
    sp.Update (_time.Dt ());

    if (_time.Iter () % _clean == 0)
    {
      SAT_PRAGMA_OMP (parallel sections)
      {
      	SAT_PRAGMA_OMP (section) CleanPcles (sp.GetIons (), cleaned);
      	SAT_PRAGMA_OMP (section) CleanPcles (sp.GetNeutrals (), cleaned);
      }
    }

    for (int j=0; j<_nsub; ++j)
    {
      MoveIons (sp, subdt);
      ApplyBC (sp.GetIons (), bdions, plions);
    }

    Ionize (sp, ionized);
    MoveNeutrals (sp);
    ApplyBC (sp.GetNeutrals (), bdneut, plneut);
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
      nions += sp.GetIons ().GetSize ();
      nneut += sp.GetNeutrals ().GetSize ();
    }
    DBG_INFO ("ions + neut particles: "<<nions<<" + "<<nneut<<
	      " = "<<nions+nneut);
    SAT_CALLGRIND_DUMP_STATS
  }
}

#include "tmplspec.cpp"
