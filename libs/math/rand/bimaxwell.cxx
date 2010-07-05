/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   bimaxwell.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/06, @jparal}
 * @revmessg{Initial version}
 */

#include "bimaxwell.h"
#include "base/common/debug.h"

template<class T>
void BiMaxwellRandGen<T>::Initialize (const Vector<T,3> &b, T vper, T vpar)
{
  _b = b;
  _b.Normalize();

  T bb = Math::Sqrt( b[1]*b[1] + b[2]*b[2] );
  if (bb > 0.05)
  {
    _v1[0] = 0.;
    _v1[1] =  _b[2] / bb;
    _v1[2] = -_b[1] / bb;
  }
  else
  {
    bb = Math::Sqrt( b[0]*b[0] + b[1]*b[1] );
    _v1[0] =  _b[1] / bb;
    _v1[1] = -_b[0] / bb;
    _v1[2] = 0.;
  }
  _v2 = _b % _v1;

  _maxwpa.Initialize( vpar );
  _maxwpe.Initialize( vper );
}

template<class T>
Vector<T,3> BiMaxwellRandGen<T>::Get()
{
  T vper1 = _maxwpe.Get();
  T vper2 = _maxwpe.Get();
  T vpar  = _maxwpa.Get();

  Vector<T,3> vel = _b * vpar + _v1 * vper1 + _v2 * vper2;
  return vel;
}

template<class T>
void BiMaxwellRandGen<T>::Print() const
{
  DBG_INFO("Bi-Maxwell (b;v1;v2): "<<_b <<" ; "<<_v1<<" ; "<<_v2);
  DBG_INFO("  ThermalVel (per,par): "<<_maxwpe.GetVth() <<
	   ","<< _maxwpe.GetVth());
}

template class BiMaxwellRandGen<float>;
template class BiMaxwellRandGen<double>;
