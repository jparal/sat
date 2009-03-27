/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   thompsongen.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#include "thompsongen.h"
#include "math/satmisc.h"

template<class T>
ThompsonRandGen<T>::ThompsonRandGen ()
{ Initialize ((T)1, (T)0); }

template<class T>
ThompsonRandGen<T>::ThompsonRandGen (T bind, T bulk)
{ Initialize (bind, bulk); }

template<class T>
void ThompsonRandGen<T>::Initialize (T bind, T bulk)
{ _bind = bind; _bulk = bulk; }

template<class T>
T ThompsonRandGen<T>::Get ()
{
  T rnd = RandomGen<T>::Get ();
  return _bulk + _bind * Math::Sqrt ((rnd + Math::Sqrt(rnd) ) / ((T)1. - rnd));
}

template class ThompsonRandGen<float>;
template class ThompsonRandGen<double>;
