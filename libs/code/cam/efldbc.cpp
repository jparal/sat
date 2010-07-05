/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   efldbc.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"

template<class B, class T, int D>
void CAMCode<B,T,D>::EfieldBC ()
{
  _E.Sync ();

  for (int i=0; i<D; ++i)
  {
    if (_layop.IsOpen (i) && _layop.GetDecomp ().IsLeftBnd (i))
      _E(0) = _E0;

    if (_layop.IsOpen (i) && _layop.GetDecomp ().IsRightBnd (i))
      _E(_E.Size(1)-1) = _E0;
  }

  static_cast<B*>(this)->EfieldAdd ();
}
