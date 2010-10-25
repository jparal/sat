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

#include "math/func/stdmath.h"

template <class T, int D> inline
Vector<T,D>::Vector (T v)
{
  for (int i=0; i<D; ++i) _d[i] = v;
}

template <class T, int D> inline
Vector<T,D>::Vector (T v0, T v1)
{
  SAT_CASSERT (D == 2);
  _d[0] = v0; _d[1] = v1;
}

template <class T, int D> inline
Vector<T,D>::Vector (T v0, T v1, T v2)
{
  SAT_CASSERT (D == 3);
  _d[0] = v0; _d[1] = v1; _d[2] = v2;
}

template <class T, int D> inline
Vector<T,D>::Vector (T v0, T v1, T v2, T v3)
{
  SAT_CASSERT (D == 4);
  _d[0] = v0; _d[1] = v1; _d[2] = v2; _d[3] = v3;
}

template <class T, int D> inline
Vector<T,D>::Vector (T v0, T v1, T v2, T v3,
		     T v4, T v5, T v6, T v7)
{
  SAT_CASSERT (D == 8);
  _d[0] = v0; _d[1] = v1; _d[2] = v2; _d[3] = v3;
  _d[4] = v4; _d[5] = v5; _d[6] = v6; _d[7] = v7;
}

template <class T, int D>
template<class T2> inline
Vector<T,D>::Vector (Vector<T2,D> const &v)
{
  for (int i=0; i<D; ++i) _d[i] = v._d[i];
}

template <class T, int D> inline
T Vector<T,D>::operator[] (size_t n) const
{ return _d[n]; }

template <class T, int D> inline
T& Vector<T,D>::operator[] (size_t n)
{ return _d[n]; }

template <class T, int D> inline
Vector<T,D>& Vector<T,D>::operator+= (const Vector<T,D> &v)
{
  for (int i=0; i<D; ++i) _d[i] += v._d[i];
  return *this;
}

template <class T, int D> inline
Vector<T,D>& Vector<T,D>::operator+= (const T &val)
{
  for (int i=0; i<D; ++i) _d[i] += val;
  return *this;
}

template <class T, int D> inline
Vector<T,D>& Vector<T,D>::operator-= (const Vector<T,D> &v)
{
  for (int i=0; i<D; ++i) _d[i] -= v._d[i];
  return *this;
}

template <class T, int D> inline
Vector<T,D>& Vector<T,D>::operator-= (const T &val)
{
  for (int i=0; i<D; ++i) _d[i] -= val;
  return *this;
}

template <class T, int D> inline
Vector<T,D>& Vector<T,D>::operator*= (const Vector<T,D> &v)
{
  for (int i=0; i<D; ++i) _d[i] *= v._d[i];
  return *this;
}

template <class T, int D> inline
Vector<T,D>& Vector<T,D>::operator*= (T v)
{
  for (int i=0; i<D; ++i) _d[i] *= v;
  return *this;
}

template <class T, int D> inline
Vector<T,D>& Vector<T,D>::operator/= (const Vector<T,D> &v)
{
  for (int i=0; i<D; ++i) _d[i] /= v._d[i];
  return *this;
}

template <class T, int D> inline
Vector<T,D>& Vector<T,D>::operator/= (T v)
{
  for (int i=0; i<D; ++i) _d[i] /= v;
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

template <class T, int D> inline
void Vector<T,D>::Set (T v0)
{
  for (int i=0; i<D; ++i) _d[i] = v0;
}

template <class T, int D> inline
void Vector<T,D>::Set (T v0, T v1)
{
  SAT_CASSERT (D == 2);
  _d[0] = v0; _d[1] = v1;
}

template <class T, int D> inline
void Vector<T,D>::Set (T v0, T v1, T v2)
{
  SAT_CASSERT (D == 3);
  _d[0] = v0; _d[1] = v1; _d[2] = v2;
}

template <class T, int D> inline
void Vector<T,D>::Set (T v0, T v1, T v2, T v3)
{
  SAT_CASSERT (D == 4);
  _d[0] = v0; _d[1] = v1; _d[2] = v2; _d[3] = v3;
}

template <class T, int D>
template<class T2> inline
void Vector<T,D>::Set (const Vector<T2,D> &v)
{
  for (int i=0; i<D; ++i) _d[i] = v._d[i];
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
void Vector<T,D>::Normalize (const T mag)
{
  T len = _d[0] * _d[0];
  for (int i=1; i<D; ++i) len += _d[i] * _d[i];
  if (len < SMALL_EPS) return;
  *this /= Math::Sqrt (len) / mag;
}

template <class T, int D> inline
T Vector<T,D>::Mult () const
{
  T mult = _d[0];
  for (int i=1; i<D; ++i) mult *= _d[i];
  return mult;
}

template <class T, int D> inline
T Vector<T,D>::Sum () const
{
  T sum = _d[0];
  for (int i=1; i<D; ++i) sum += _d[i];
  return sum;
}

template <class T, int D> inline
T Vector<T,D>::Norm () const
{
  T len = _d[0] * _d[0];
  for (int i=1; i<D; ++i) len += _d[i] * _d[i];
  return Math::Sqrt (len);
}

template <class T, int D> inline
T Vector<T,D>::Norm2 () const
{
  T len = _d[0] * _d[0];
  for (int i=1; i<D; ++i) len += _d[i] * _d[i];
  return len;
}

template <class T, int D> inline
T Vector<T,D>::SquaredNorm () const
{
  T len = _d[0] * _d[0];
  for (int i=1; i<D; ++i) len += _d[i] * _d[i];
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

template <class T, int D> inline
T Vector<T,D>::SquaredDistance (const TVector &v) const
{
  T tmp = _d[0] - v._d[0];
  T retval = tmp * tmp;
  for (int i=1; i<D; ++i)
  {
    tmp = _d[i] - v._d[i];
    retval += tmp * tmp;
  }
  return retval;
}

template <class T, int D> inline
T Vector<T,D>::Distance2 (const TVector &v) const
{
  return SquaredDistance (v);
}

template <class T, int D> inline
T Vector<T,D>::Distance (const TVector &v) const
{
  return Math::Sqrt (SquaredDistance (v));
}
