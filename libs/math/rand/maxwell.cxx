/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   maxwell.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "maxwell.h"
#include "math/satmisc.h"
#include "math/satfunc.h"

template<class T>
void MaxwellRandGen<T>::Initialize (T vth)
{ _vth = vth; _stat = 0; }

template<class T>
T MaxwellRandGen<T>::Get ()
{
  if (_stat++ % 2 == 0)
  {
    _r1 = Math::Ln (1. - 0.99999 * RandomGen<T>::Get ());
    _r1 = _vth * Math::Sqrt ((T)-2 * _r1);
    _r2 = M_2PI * RandomGen<T>::Get ();
    return _r1 * Math::Sin (_r2);
  }
  else
  {
    return _r1 * Math::Cos (_r2);
  }
}

template class MaxwellRandGen<float>;
template class MaxwellRandGen<double>;
