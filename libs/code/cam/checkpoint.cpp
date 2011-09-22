/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   checkpoint.cpp
 * @author @jparal
 *
 * @revision{1.2}
 * @reventry{2011/09, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"

template<class B, class T, int D>
void CAMCode<B,T,D>::CheckPointSave ()
{
  static int checked = 0;

  if (_time.NCheckPoint () < 1) return;
  if (checked % _time.NCheckPoint () != 0 || checked == 0)
  {
    checked++;
    return;
  }
  checked++;

  DBG_INFO ("Checkpointing .. Save");

  char fname[64];
  snprintf (fname, 64, "checkpoint_%d_%d.dat", _time.Iter (), Mpi::Rank ());
  FILE *file = fopen (fname, "w");

  _itertime.Save (file);
  _time.Save (file);
  for (int i=0; i<_specie.GetSize (); ++i)
  {
    TSpecie *sp = _specie.Get (i);
    sp->Save (file);
  }
  _B.Save (file);
  _Bh.Save (file);
  _E.Save (file);
  _pe.Save (file);
  _dn.Save (file);
  _dna.Save (file);
  _dnf.Save (file);
  _U.Save (file);
  _Ua.Save (file);
  _Uf.Save (file);

  fclose (file);
  DBG_INFO ("Checkpointing .. done");
}

template<class B, class T, int D>
void CAMCode<B,T,D>::CheckPointLoad ()
{
  DBG_INFO ("Checkpointing .. Load");

  char fname[64];
  snprintf (fname, 64, "checkpoint_%d_%d.dat", _time.Iter (), Mpi::Rank ());
  FILE *file = NULL;
  file = fopen (fname, "r");
  SAT_ASSERT_MSG (file != NULL, "Checkpointing files doesn't exist!!");

  _itertime.Load (file);
  _time.Load (file);
  for (int i=0; i<_specie.GetSize (); ++i)
  {
    TSpecie *sp = _specie.Get (i);
    sp->Load (file);
  }
  _B.Load (file);
  _Bh.Load (file);
  _E.Load (file);
  _pe.Load (file);
  _dn.Load (file);
  _dna.Load (file);
  _dnf.Load (file);
  _U.Load (file);
  _Ua.Load (file);
  _Uf.Load (file);

  fclose (file);

  DBG_INFO ("Checkpointing .. done");
}
