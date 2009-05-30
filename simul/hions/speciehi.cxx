/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   speciehi.cxx
 * @brief  Specie for heavy ions app.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */

#include "speciehi.h"

template <class T>
void HISpecie<T>::Initialize (TSphereEmitter *emit, Vector<int,3> nc,
			      int numarrays)
{
  _initialized = true;
  _numarrays = numarrays;
  _emit.AttachNew (emit);
  // @@@TODO
  _mass = 29.999;
  _qms = 1./_mass;

  _ions.SetSize (_numarrays);
  _neut.SetSize (_numarrays);

  _weight.Initialize (nc);
  _weight = (T)0.;
}

template class HISpecie<float>;
//template class HISpecie<double>;
