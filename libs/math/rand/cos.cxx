/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cos.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */

#include "cos.h"
#include "math/func/stdmath.h"

template<class T>
void CosRandGen<T>::Initialize ()
{}

template<class T>
T CosRandGen<T>::Get ()
{
  return Math::ASin ((T)2. * RandomGen<T>::Get () - (T)1.);
}

template class CosRandGen<float>;
template class CosRandGen<double>;
