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
  static int plions = 0, bdions = 0, plneut = 0, bdneut = 0;

  for (int i=0; i<_specs.GetSize(); ++i)
  {
    TSpecie &sp = *_specs.Get (i);
    sp.Update (_time.Dt ());

    MoveIons (sp);
    MoveNeutrals (sp);

    ApplyBC (sp.GetIons (), plions, bdions);
    ApplyBC (sp.GetNeutrals (), plneut, bdneut);

    Ionize (sp);
  }

  if (_time.Iter () % 20 == 0)
  {
    _time.Print ();
    DBG_INFO ("ions hit planet/boundary: "<<plions<<" / "<<bdions);
    DBG_INFO ("neut hit planet/boundary: "<<plneut<<" / "<<bdneut);
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
  }
}

#include "tmplspec.cpp"
