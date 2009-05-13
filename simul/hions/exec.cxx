/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   exec.cxx
 * @brief  Main loop of heavy ions app.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#include "hions.h"

template<class T>
void HeavyIonsCode<T>::Exec ()
{
  do
  {
    CalcOutput ();
    _sensmng.SaveAll (_time);
    _sensmng.SetNextOutput (_time);

    while (_time.Next ())
      Iter ();
  }
  while (_time.Iter () < _time.ItersMax ());

  _sensmng.SaveAll (_time);
  _sensmng.SetNextOutput (_time);
}

#include "tmplspec.cpp"
