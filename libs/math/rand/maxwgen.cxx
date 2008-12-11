/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   maxwgen.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "maxwgen.h"
#include "math/misc/stdmath.h"
#include "base/common/const.h"

template<class T>
T MaxwellRandGen<T>::Get ()
{
  if (_stat++ % 2 == 0)
  {
    _r1 = _vth * Math::Sqrt (- 2. * Math::Log (1. - 0.99999 * _gen.Get ()));
    _r2 = M_2PI * _gen.Get ();
    return _r1 * Math::Sin (_r2);
  }
  else
  {
    return _r1 * Math::Cos (_r2);
  }
}

template class MaxwellRandGen<float>;
template class MaxwellRandGen<double>;
