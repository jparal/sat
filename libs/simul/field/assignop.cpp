/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   assignop.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-03-04, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"

template<class T, int D>
template<class T2>
void Field<T,D>::operator= (const T2& val)
{
  for (int i=0; i<_tot; ++i) _data[i] = val;
}

template<class T, int D>
template<class T2>
void Field<T,D>::operator+= (const T2& val)
{
  for (int i=0; i<_tot; ++i) _data[i] += val;
}

template<class T, int D>
template<class T2>
void Field<T,D>::operator-= (const T2& val)
{
  for (int i=0; i<_tot; ++i) _data[i] -= val;
}

template<class T, int D>
template<class T2>
void Field<T,D>::operator*= (const T2& val)
{
  for (int i=0; i<_tot; ++i) _data[i] *= val;
}

template<class T, int D>
template<class T2>
void Field<T,D>::operator/= (const T2& val)
{
  for (int i=0; i<_tot; ++i) _data[i] /= val;
}

template<class T, int D>
template<class T2>
void Field<T,D>::operator/= (const Field<T2,D>& val)
{
  SAT_DBG_ASSERT (GetDims () == val.GetDims ());

  T2 *pdata = val._data;
  T tmp;
  for (int i=0; i<_tot; ++i)
  {
    tmp = (T)pdata[i];
    if (tmp > (T)0.0001)
      _data[i] /= tmp;
    else
      _data[i] = (T)0.;
  }
}

template<class T, int D>
template<class T2>
void Field<T,D>::operator= (const Field<T2,D>& val)
{
  UpdateMeta (val);
  T2 *pdata = val._data;
  for (int i=0; i<_tot; ++i) _data[i] = (T)pdata[i];
}

template<class T, int D>
void Field<T,D>::operator= (const Field<T,D>& val)
{
  UpdateMeta (val);
  memcpy (_data, val._data, _tot * sizeof(T));
}

template<class T, int D>
template<class T2>
void Field<T,D>::operator+= (const Field<T2,D>& val)
{
  SAT_DBG_ASSERT (GetDims () == val.GetDims ());

  T2 *pdata = val._data;
  for (int i=0; i<_tot; ++i) _data[i] += pdata[i];
}
