/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   hybridconv.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */

#include "hybridconv.h"

template <class T>
void SIHybridUnitsConvert<T>::Initialize (T b0, T n0)
{
  T time = 10.4375/b0;
  T length = 229.625e3/Math::Sqrt(n0);
  SetTime (time, true);
  SetLength (length, true);
}

template <class T>
void SIHybridUnitsConvert<T>::Initialize (const ConfigEntry &cfg)
{
  T b0, n0;
  b0 = cfg["b0"];
  n0 = cfg["n0"];
  Initialize (b0, n0);
}

template class SIHybridUnitsConvert<float>;
template class SIHybridUnitsConvert<double>;
