/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   rectdfcell.cpp
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/02, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"
#include "simul/field/cartstencil.h"

template<class T, int D>
void RectDistFunction<T,D>::Initialize (const Vector<int,D> &ncell,
					const Vector<T,D> &vmin,
					const Vector<T,D> &vmax)
{
  _vmin = vmin;
  _vmax = vmax;

  _dvxi = ncell;
  _dvxi -= 1;
  _dvxi /= vmax - vmin;

  _df.Initialize (ncell);

  Reset ();
}

template<class T, int D>
void RectDistFunction<T,D>::Reset ()
{
  _df = T(0);
}

template<class T, int D>
bool RectDistFunction<T,D>::Update (const Vector<T,D> &vel)
{
  for (int i=0; i<D; ++i)
    if (vel[i] < _vmin[i] || _vmax[i] < vel[i])
      return false;

  Vector<T,D> nvel = vel;
  nvel -= _vmin;
  nvel *= _dvxi;
  CartStencil::BilinearWeightAdd (_df, nvel, T(1));

  return true;
}
