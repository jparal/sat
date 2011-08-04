/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   matrix3.cpp
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/08, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"

//---------------------------------------------------------------------------
template<class T>
Matrix3<T>::Matrix3 (T x,T y, T z, T angle)
{
  T c = Math::Cos(angle);
  T s = Math::Sin(angle);
  T t = 1.0 - c;
  m11 = c + x * x * t;
  m22 = c + y * y * t;
  m33 = c + z * z * t;

  double tmp1 = x * y * t;
  double tmp2 = z * s;
  m21 = tmp1 + tmp2;
  m12 = tmp1 - tmp2;

  tmp1 = x * z * t;
  tmp2 = y * s;
  m31 = tmp1 - tmp2;
  m13 = tmp1 + tmp2;
  tmp1 = y * z * t;
  tmp2 = x * s;
  m32 = tmp1 + tmp2;
  m23 = tmp1 - tmp2;
}

template<class T>
String Matrix3<T>::Description () const
{
  return String().Format ("(%s), (%s), (%s)",
			  Row1().Description().GetData(),
			  Row2().Description().GetData(),
			  Row3().Description().GetData());
}

template<class T>
void Matrix3<T>::Set (const Quaternion<T> &quat)
{
  *this = quat.GetMatrix ();
}


//---------------------------------------------------------------------------

template<class T>
XRotMatrix3<T>::XRotMatrix3 (T angle)
{
  Matrix3<T>::m11 = 1;
  Matrix3<T>::m12 = 0;
  Matrix3<T>::m13 = 0;
  Matrix3<T>::m21 = 0;
  Matrix3<T>::m22 = Math::Cos (angle);
  Matrix3<T>::m23 = -Math::Sin (angle);
  Matrix3<T>::m31 = 0;
  Matrix3<T>::m32 = -Matrix3<T>::m23;
  Matrix3<T>::m33 = Matrix3<T>::m22;
}

template<class T>
YRotMatrix3<T>::YRotMatrix3 (T angle)
{
  Matrix3<T>::m11 = Math::Cos (angle);
  Matrix3<T>::m12 = 0;
  Matrix3<T>::m13 = -Math::Sin (angle);
  Matrix3<T>::m21 = 0;
  Matrix3<T>::m22 = 1;
  Matrix3<T>::m23 = 0;
  Matrix3<T>::m31 = -Matrix3<T>::m13;
  Matrix3<T>::m32 = 0;
  Matrix3<T>::m33 = Matrix3<T>::m11;
}

template<class T>
ZRotMatrix3<T>::ZRotMatrix3 (T angle)
{
  Matrix3<T>::m11 = Math::Cos (angle);
  Matrix3<T>::m12 = -Math::Sin (angle);
  Matrix3<T>::m13 = 0;
  Matrix3<T>::m21 = -Matrix3<T>::m12;
  Matrix3<T>::m22 = Matrix3<T>::m11;
  Matrix3<T>::m23 = 0;
  Matrix3<T>::m31 = 0;
  Matrix3<T>::m32 = 0;
  Matrix3<T>::m33 = 1;
}

