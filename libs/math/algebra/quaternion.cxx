/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   quaternion.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#include "quaternion.h"

template<class T>
void Quaternion<T>::SetEulerAngles (const TVector& angles)
{
  TVector halfAngles = angles / (T)2;
  const T cx = Math::Cos (halfAngles[0]);
  const T sx = Math::Sin (halfAngles[0]);
  const T cy = Math::Cos (halfAngles[1]);
  const T sy = Math::Sin (halfAngles[1]);
  const T cz = Math::Cos (halfAngles[2]);
  const T sz = Math::Sin (halfAngles[2]);

  const T cxcz = cx*cz;
  const T cxsz = cx*sz;
  const T sxcz = sx*cz;
  const T sxsz = sx*sz;

  v[0] = (cy * sxcz) - (sy * cxsz);
  v[1] = (cy * sxsz) + (sy * cxcz);
  v[2] = (cy * cxsz) - (sy * sxcz);
  w    = (cy * cxcz) + (sy * sxsz);
}

template<class T>
Vector<T,3> Quaternion<T>::GetEulerAngles () const
{
  TVector angles;
  const T case1 = M_PI / (T)2;
  const T case2 = -M_PI / (T)2;

  angles[2] = Math::ATan2 ((T)2 * (v[0]*v[1] + w*v[2]),
			  (w*w + v[0]*v[0] - v[1]*v[1] - v[2]*v[2]));
  T sine = -(T)2 * (v[0]*v[2] - w*v[1]);

  if(sine >= 1)     //cases whewe value is 1 ow -1 cause NAN
    angles[1] = case1;
  else if ( sine <= -1 )
    angles[1] = case2;
  else
    angles[1] = Math::ASin (sine);

  angles[0] = Math::ATan2 ((T)2 * (w*v[0] + v[1]*v[2]),
			   (w*w - v[0]*v[0] - v[1]*v[1] + v[2]*v[2]));

  return angles;
}

/*
template<class T>
void Quaternion<T>::SetMatrix (const Matrix3& matrix)
{
  // Ken Shoemake's article in 1987 SIGGRAPH course notes

  Matrix3 mat = Matrix3( matrix.m11, matrix.m21, matrix.m31,
			 matrix.m12, matrix.m22, matrix.m32,
			 matrix.m13, matrix.m23, matrix.m33);

  const T trace = mat.m11 + mat.m22 + mat.m33;

  if (trace >= 0.0)
  {
    // Quick-route
    T s = Math::Sqrt (trace + (T)1);
    w = 0.5 * s;
    s = 0.5 / s;
    v[0] = (mat.m32 - mat.m23) * s;
    v[1] = (mat.m13 - mat.m31) * s;
    v[2] = (mat.m21 - mat.m12) * s;
  }
  else
  {
    //Check biggest diagonal elmenet
    if (mat.m11 > mat.m22 && mat.m11 > mat.m33)
    {
      //X biggest
      T s = Math::Sqrt ((T)1 + mat.m11 - mat.m22 - mat.m33);
      v[0] = 0.5 * s;
      s = 0.5 / s;
      w = (mat.m32 - mat.m23) * s;
      v[1] = (mat.m12 + mat.m21) * s;
      v[2] = (mat.m31 + mat.m13) * s;
    }
    else if (mat.m22 > mat.m33)
    {
      //Y biggest
      T s = Math::Sqrt ((T)1 + mat.m22 - mat.m11 - mat.m33);
      v[1] = 0.5 * s;
      s = 0.5 / s;
      w = (mat.m13 - mat.m31) * s;
      v[0] = (mat.m12 + mat.m21) * s;
      v[2] = (mat.m23 + mat.m32) * s;
    }
    else
    {
      //Z biggest
      T s = Math::Sqrt ((T)1 + mat.m33 - mat.m11 - mat.m22);
      v[2] = 0.5 * s;
      s = 0.5 / s;
      w = (mat.m21 - mat.m12) * s;
      v[0] = (mat.m31 + mat.m13) * s;
      v[1] = (mat.m23 + mat.m32) * s;
    }
  }
}
#else
template<class T>
void Quaternion<T>::SetMatrix (const Matrix3& matrix)
{
  // Ken Shoemake's article in 1987 SIGGRAPH course notes
  const T trace = matrix.m11 + matrix.m22 + matrix.m33;

  if (trace >= 0.0)
  {
    // Quick-route
    T s = Math::Sqrt (trace + (T)1);
    w = 0.5 * s;
    s = 0.5 / s;
    v[0] = (matrix.m32 - matrix.m23) * s;
    v[1] = (matrix.m13 - matrix.m31) * s;
    v[2] = (matrix.m21 - matrix.m12) * s;
  }
  else
  {
    //Check biggest diagonal elmenet
    if (matrix.m11 > matrix.m22 && matrix.m11 > matrix.m33)
    {
      //X biggest
      T s = Math::Sqrt ((T)1 + matrix.m11 - matrix.m22 - matrix.m33);
      v[0] = 0.5 * s;
      s = 0.5 / s;
      w = (matrix.m32 - matrix.m23) * s;
      v[1] = (matrix.m12 + matrix.m21) * s;
      v[2] = (matrix.m31 + matrix.m13) * s;
    }
    else if (matrix.m22 > matrix.m33)
    {
      //Y biggest
      T s = Math::Sqrt ((T)1 + matrix.m22 - matrix.m11 - matrix.m33);
      v[1] = 0.5 * s;
      s = 0.5 / s;
      w = (matrix.m13 - matrix.m31) * s;
      v[0] = (matrix.m12 + matrix.m21) * s;
      v[2] = (matrix.m23 + matrix.m32) * s;
    }
    else
    {
      //Z biggest
      T s = Math::Sqrt ((T)1 + matrix.m33 - matrix.m11 - matrix.m22);
      v[2] = 0.5 * s;
      s = 0.5 / s;
      w = (matrix.m21 - matrix.m12) * s;
      v[0] = (matrix.m31 + matrix.m13) * s;
      v[1] = (matrix.m23 + matrix.m32) * s;
    }
  }
}

template<class T>
Matrix3 Quaternion<T>::GetMatrix () const
{
  const T x2 = v[0]*(T)2;
  const T y2 = v[1]*(T)2;
  const T z2 = v[2]*(T)2;

  const T xx2 = v[0]*x2;
  const T xy2 = v[1]*x2;
  const T xz2 = v[2]*x2;
  const T xw2 = w*x2;

  const T yy2 = v[1]*y2;
  const T yz2 = v[2]*y2;
  const T yw2 = w*y2;

  const T zz2 = v[2]*z2;
  const T zw2 = w*z2;


  return Matrix3 (
		  (T)1 - (yy2+zz2), xy2 - zw2,       xz2 + yw2,
		  xy2 + zw2,       (T)1 - (xx2+zz2), yz2 - xw2,
		  xz2 - yw2,       yz2 + xw2,       (T)1 - (xx2+yy2));
}
*/

template<class T>
Quaternion<T> Quaternion<T>::NLerp (const TQuaternion& q2, T t) const
{
  return (*this + t * (q2 - (*this))).Unit ();
}

template<class T>
Quaternion<T> Quaternion<T>::SLerp (const TQuaternion& q2, T t) const
{
  T omega, cosom, invsinom, scale0, scale1;

  TQuaternion quato(q2);

  // decide if one of the quaternions is backwards
  T a = (*this-q2).SquaredNorm ();
  T b = (*this+q2).SquaredNorm ();
  if (a > b)
  {
    quato = -q2;
  }

  // Calculate dot between quats
  cosom = Dot (quato);

  // Make sure the two quaternions are not exactly opposite? (within a little
  // slop).
  if (cosom > -0.9998)
  {
    // Are they more than a little bit different?  Avoid a divided by zero
    // and lerp if not.
    if (cosom < 0.9998)
    {
      // Yes, do a slerp
      omega = Math::ACos (cosom);
      invsinom = (T)1 / Math::Sin (omega);
      scale0 = Math::Sin (((T)1 - t) * omega) * invsinom;
      scale1 = Math::Sin (t * omega) * invsinom;
    }
    else
    {
      // Not a very big difference, do a lerp
      scale0 = (T)1 - t;
      scale1 = t;
    }

    return TQuaternion (
      scale0 * v[0] + scale1 * quato.v[0],
      scale0 * v[1] + scale1 * quato.v[1],
      scale0 * v[2] + scale1 * quato.v[2],
      scale0 * w + scale1 * quato.w);
  }

  // The quaternions are nearly opposite so to avoid a divided by zero error
  // Calculate a perpendicular quaternion and slerp that direction
  scale0 = Math::Sin (((T)1 - t) * M_PI);
  scale1 = Math::Sin (t * M_PI);
  return TQuaternion (scale0 * v[0] + scale1 * -quato.v[1],
		      scale0 * v[1] + scale1 *  quato.v[0],
		      scale0 * v[2] + scale1 * -quato.w,
		      scale0 * w    + scale1 *  quato.v[2]);
}

template<class T>
Quaternion<T> Quaternion<T>::Log () const
{
  // q = w + v, w is T, v is complex vector

  // let u be v / |v|
  // log(q) = 1/2*log(|q|) + u*atan(|v|/ w)
  T vNorm = v.Norm ();
  T qSqNorm = SquaredNorm ();

  T vCoeff;
  if (vNorm > 0.0)
    vCoeff = Math::ATan2 (vNorm, w) / vNorm;
  else
    vCoeff = 0;

  return TQuaternion (v * vCoeff, 0.5 * Math::Log (qSqNorm));
}

template<class T>
Quaternion<T> Quaternion<T>::Exp () const
{
  // q = w + v, w is T, v is complex vector

  // let u be v / |v|
  // exp(q) = exp(w) * (cos(|v|), u*sin(|v|))

  T vNorm = v.Norm ();
  T expW = Math::Exp (w);

  T vCoeff;
  if (vNorm > 0.0)
    vCoeff = expW * Math::Sin (vNorm) / vNorm;
  else
    vCoeff = 0;

  return TQuaternion (v * vCoeff, expW * Math::Cos (vNorm));
}

template<class T>
Quaternion<T> Quaternion<T>::Squad (const TQuaternion& t1,
				    const TQuaternion& t2,
				    const TQuaternion& q, T t) const
{
  return SLerp (q, t).SLerp (t1.SLerp (t2, t), (T)2*t * ((T)1 - t));
}

template class Quaternion<float>;
template class Quaternion<double>;
