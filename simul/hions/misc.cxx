/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   misc.cxx
 * @brief  Misc functions
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#include "hions.h"

template<class T>
void HeavyIonsCode<T>::CalcAccel (const TVector &pos, TVector &force) const
{
  T r = pos.Distance (_plpos);
  force = _plpos - pos;
  force *= _cgrav/(r*r*r);
  force[0] += _swaccel;
}

template<class T>
void HeavyIonsCode<T>::ResetFields ()
{
  Vector<T,3> pos;
  T dx = _dx.Norm ();
  T radius2 = (_radius+dx)*(_radius+dx);

  for (int i=0; i<_B.GetSize (0); ++i)
    for (int j=0; j<_B.GetSize (1); ++j)
      for (int k=0; k<_B.GetSize (2); ++k)
      {
	pos[0] = _plpos[0] - (T)i*_dx[0];
	pos[1] = _plpos[1] - (T)j*_dx[1];
	pos[2] = _plpos[2] - (T)k*_dx[2];

	// are we inside of the planet?
	if (pos.Norm2 () < radius2)
	{
	  _B(i,j,k) = 0.;
	  _E(i,j,k) = 0.;
	}
      }
}

#include "tmplspec.cpp"
