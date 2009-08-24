/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sphere.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#include "sphere.h"
#include "math/satmisc.h"
#include "math/satfunc.h"

template<class T>
T SphericalRandGen<T>::GetPhi ()
{
  return ((T)2 * M_PI * RandomGen<T>::Get ());
}

template<class T>
T SphericalRandGen<T>::GetTht ()
{
  return Math::ACos ((T)2 * RandomGen<T>::Get () - (T)1);
}
