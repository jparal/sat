/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   vector.cpp
 * @brief  Vector inline function definitions
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/01, @jparal}
 * @revmessg{Initial version}
 */

#include "math/misc/stdmath.h"

template <class T, int D>
template <class T2> inline
Vector<T,D>::Vector (T2 v)
{
  for (int i=0; i<D; ++i) _d[i] = (T)(v);
}

template <class T, int D>
template <class T2> inline
Vector<T,D>::Vector (T2 v0, T2 v1)
{
  SAT_CASSERT (D == 2);
  _d[0] = v0; _d[1] = v1;
}

template <class T, int D>
template <class T2> inline
Vector<T,D>::Vector (T2 v0, T2 v1, T2 v2)
{
  SAT_CASSERT (D == 3);
  _d[0] = v0; _d[1] = v1; _d[2] = v2;
}

template <class T, int D>
template <class T2> inline
Vector<T,D>::Vector (T2 v0, T2 v1, T2 v2, T2 v3)
{
  SAT_CASSERT (D == 4);
  _d[0] = v0; _d[1] = v1; _d[2] = v2; _d[3] = v3;
}

template <class T, int D>
template <class T2> inline
Vector<T,D>::Vector (T2 v0, T2 v1, T2 v2, T2 v3,
		     T2 v4, T2 v5, T2 v6, T2 v7)
{
  SAT_CASSERT (D == 8);
  _d[0] = v0; _d[1] = v1; _d[2] = v2; _d[3] = v3;
  _d[4] = v4; _d[5] = v5; _d[6] = v6; _d[7] = v7;
}

template <class T, int D>
template <class T2> inline
Vector<T,D>::Vector (Vector<T2,D> const &v)
{
  for (int i=0; i<D; ++i) _d[i] = (T)(v._d[i]);
}

template <class T, int D> inline
T Vector<T,D>::operator[] (size_t n) const
{ return _d[n]; }

template <class T, int D> inline
T& Vector<T,D>::operator[] (size_t n)
{ return _d[n]; }

template <class T, int D>
template <class T2> inline
Vector<T,D>& Vector<T,D>::operator+= (const Vector<T2,D> &v)
{
  for (int i=0; i<D; ++i) _d[i] += (T)(v._d[i]);
  return *this;
}

template <class T, int D>
template <class T2> inline
Vector<T,D>& Vector<T,D>::operator+= (const T2 &val)
{
  for (int i=0; i<D; ++i) _d[i] += (T)val;
  return *this;
}

template <class T, int D>
template <class T2> inline
Vector<T,D>& Vector<T,D>::operator-= (const Vector<T2,D> &v)
{
  for (int i=0; i<D; ++i) _d[i] -= (T)(v._d[i]);
  return *this;
}

template <class T, int D>
template <class T2> inline
Vector<T,D>& Vector<T,D>::operator-= (const T2 &val)
{
  for (int i=0; i<D; ++i) _d[i] -= (T)val;
  return *this;
}

template <class T, int D>
template <class T2> inline
Vector<T,D>& Vector<T,D>::operator*= (T2 v)
{
  for (int i=0; i<D; ++i) _d[i] *= (T)(v);
  return *this;
}

template <class T, int D>
template <class T2> inline
Vector<T,D>& Vector<T,D>::operator/= (T2 v)
{
  for (int i=0; i<D; ++i) _d[i] /= (T)(v);
  return *this;
}

template <class T, int D> inline
Vector<T,D> Vector<T,D>::operator+ () const
{ return *this; }

template <class T, int D> inline
Vector<T,D> Vector<T,D>::operator- () const
{
  TVector retval (*this);
  for (int i=0; i<D; ++i) retval._d[i] = -retval._d[i];
  return retval;
}

template <class T, int D>
template <class T2> inline
void Vector<T,D>::Set (T2 v0)
{
  for (int i=0; i<D; ++i) _d[i] = v0;
}

template <class T, int D>
template <class T2> inline
void Vector<T,D>::Set (T2 v0, T2 v1)
{
  SAT_CASSERT (D == 2);
  _d[0] = v0; _d[1] = v1;
}

template <class T, int D>
template <class T2> inline
void Vector<T,D>::Set (T2 v0, T2 v1, T2 v2)
{
  SAT_CASSERT (D == 3);
  _d[0] = v0; _d[1] = v1; _d[2] = v2;
}

template <class T, int D>
template <class T2> inline
void Vector<T,D>::Set (T2 v0, T2 v1, T2 v2, T2 v3)
{
  SAT_CASSERT (D == 4);
  _d[0] = v0; _d[1] = v1; _d[2] = v2; _d[3] = v3;
}

template <class T, int D>
template <class T2> inline
void Vector<T,D>::Set (const Vector<T2,D> &v)
{
  for (int i=0; i<D; ++i) _d[i] = (T)(v._d[i]);
}

template <class T, int D> inline
String Vector<T,D>::Description () const
{
  String a;
  for (int i=0; i<D-1; ++i) a << _d[i] << ",";
  a << _d[D-1];
  return a;
}

template <class T, int D> inline
void Vector<T,D>::Normalize ()
{
  T len = 0;
  for (int i=0; i<D; ++i) len += _d[i] * _d[i];
  if (len < SMALL_EPS) return;
  *this /= Math::Sqrt (len);
}

template <class T, int D> inline
T Vector<T,D>::Mult () const
{
  T mult = (T)1;
  for (int i=0; i<D; ++i) mult *= _d[i];
  return mult;
}

template <class T, int D> inline
T Vector<T,D>::Sum () const
{
  T mult = (T)0;
  for (int i=0; i<D; ++i) mult += _d[i];
  return mult;
}

template <class T, int D> inline
T Vector<T,D>::Norm () const
{
  T len = 0;
  for (int i=0; i<D; ++i) len += _d[i] * _d[i];
  return Math::Sqrt (len);
}

template <class T, int D> inline
T Vector<T,D>::Norm2 () const
{
  T len = 0;
  for (int i=0; i<D; ++i) len += _d[i] * _d[i];
  return len;
}

template <class T, int D> inline
T Vector<T,D>::SquaredNorm () const
{
  T len = 0;
  for (int i=0; i<D; ++i) len += _d[i] * _d[i];
  return len;
}

template <class T, int D> inline
Vector<T,D> Vector<T,D>::Unit () const
{ return (*this)/(this->Norm ()); }

template <class T, int D> inline
bool Vector<T,D>::IsZero (float eps) const
{
  bool retval = (_d[0] < eps);
  for (int i=1; i<D; ++i) retval = retval && (_d[i] < eps);
  return retval;
}
