/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   maskbc.cpp
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/08, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"

template<class B, class T, int D>
T CAMCode<B,T,D>::MaskBC (const DomainIterator<D> &it) const
{
  PosVector xp = it.GetPosition ();

  T ee, mask = T(1);
  for (int i=0; i<D; ++i)
  {
    if (!_layop.IsOpen (i) || _bcleni[i] < T(0))
      continue;

    // left & right boundaries
    ee = xp[i] * _bcleni[i];
    if (ee < T(10))
      mask *= T(1) - Math::Exp (-ee*ee);

    ee = (_domsize[i] - xp[i]) * _bcleni[i];
    if (ee < T(10))
      mask *= T(1) - Math::Exp (-ee*ee);
  }

  return mask;
}
