/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   rangegen.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#include "rangegen.h"

template<class T>
void RangeRandGen<T>::Initialize (T min, T max)
{ _min = min; _max = max; _diff = max-min; }

template<class T>
void RangeRandGen<T>::Seed (uint32_t seed)
{ _gen.Initialize (seed); }

template<class T>
T RangeRandGen<T>::Get ()
{ return _min + _diff * _gen.Get (); }

template class RangeRandGen<float>;
template class RangeRandGen<double>;
