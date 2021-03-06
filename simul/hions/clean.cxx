/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   clean.cxx
 * @brief  Clean particles with weight less then 0.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */

#include "hions.h"

template<class T>
void HeavyIonsCode<T>::CleanPcles (TParticleArray &pcles, int &cleaned)
{
  if (_clean < 1 || _time.Iter () % _clean != 0)
    return;

  int cleanedtmp = 0;
  int npcles = (int)pcles.GetSize ();
  for (int pc=0; pc<npcles; ++pc)
  {
    TParticle &pcle = pcles.Get (pc);
    if (pcle.GetWeight () > 0.)
      continue;

    pcles.DeleteIndexFast (pc);
    --npcles;
    ++cleanedtmp;
  }

  cleaned += cleanedtmp;
}

#include "tmplspec.cpp"
