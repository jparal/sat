/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   transfrm.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/08, @jparal}
 * @revmessg{Initial version}
 */

#include "transfrm.h"
#include "matrix3.h"

// #include "box.h"
// #include "plane3.h"
// #include "sphere.h"

template<class T>
String Transform<T>::Description() const
{
  return String().Format ("m_o2t: %s  v_o2t: %s",
    m_o2t.Description().GetData(), v_o2t.Description().GetData());
}

#ifdef _GEOM

//---------------------------------------------------------------------------
template<class T>
Transform Transform<T>::GetReflect (const Plane3<T> &pl)
{
  // Suppose that n is the plane normal in the direction of th reflection.
  // Suppose that u is the unit vector in the direction of the reflection
  // normal.  For any vector v, the component of v in the direction of
  // u is equal to (v * u) * u.  Thus, if v is reflected across a plane
  // through the origin with the given normal, the resulting vector is
  //  v' = v - 2 * [ (v * u) * u ] = v - 2 [ (v * n) * n ] / (n * n)
  //
  // x = <1,0,0>  =>  x' = <1,0,0> - 2 ( n.x * n ) / (n*n)
  // y = <0,1,0>  =>  y' = <0,1,0> - 2 ( n.y * n ) / (n*n)
  // z = <0,0,1>  =>  z' = <0,0,1> - 2 ( n.z * n ) / (n*n)
  //
  // 3x3 transformation matrix = [x' y' z']
  float i_normsq = 1 / (pl.norm * pl.norm);
  Vector<T,3> xvec = (-2 * pl.norm.x * i_normsq) * pl.norm;
  Vector<T,3> yvec = (-2 * pl.norm.y * i_normsq) * pl.norm;
  Vector<T,3> zvec = (-2 * pl.norm.z * i_normsq) * pl.norm;
  xvec.x += 1;
  yvec.y += 1;
  zvec.z += 1;

  return Transform<T> (
      Matrix3<T> (
        xvec.x,
        yvec.x,
        zvec.x,
        xvec.y,
        yvec.y,
        zvec.y,
        xvec.z,
        yvec.z,
        zvec.z),
      /* neworig = */(-2 * pl.DD * i_normsq) * pl.norm);
}

//---------------------------------------------------------------------------
template<class T>
Plane3<T> Transform<T>::Other2This (const Plane3<T> &p) const
{
  Vector<T,3> newnorm = m_o2t * p.norm;

  // let N represent norm <A,B,C>, and X represent point <x,y,z>
  //
  // Old plane equation: N*X + D = 0
  // There exists point X = <r*A,r*B,r*C> = r*N which satisfies the
  // plane equation.
  //  => r*(N*N) + D = 0
  //  => r = -D/(N*N)
  //
  // New plane equation: N'*X' + D' = 0
  // If M is the transformation matrix, and V the transformation vector,
  // N' = M*N, and X' = M*(X-V).  Assume that N' is already calculated.
  //  => N'*(M*(X-V)) + D' = 0
  //  => D' = -N'*(M*X) + N'*(M*V)
  //        = -N'*(M*(r*N)) + N'*(M*V)
  //        = -r*(N'*N') + N'*(M*V) = D*(N'*N')/(N*N) + N'*(M*V)
  // Since N' is a rotation of N, (N'*N') = (N*N), thus
  //  D' = D + N'*(M*V)
  //
  return Plane3<T> (newnorm, p.DD + newnorm * (m_o2t * v_o2t));
}

template<class T>
Plane3<T> Transform<T>::Other2ThisRelative (const Plane3<T> &p) const
{
  Vector<T,3> newnorm = m_o2t * p.norm;
  return Plane3<T> (newnorm, p.DD);
}

template<class T>
void Transform<T>::Other2This (
  const Plane3<T> &p,
  const Vector<T,3> &point,
  Plane3<T> &result) const
{
  result.norm = m_o2t * p.norm;
  result.DD = -(result.norm * point);
}

template<class T>
Sphere<T> Transform<T>::Other2This (const Sphere<T> &s) const
{
  Sphere<T> news;
  news.SetCenter (Other2This (s.GetCenter ()));

  // @@@ It would be nice if we could quickly detect if a given
  // transformation is orthonormal. In that case we don't need to transform
  // the radius.
  // To transform the radius we transform a vector with the radius

  // relative to the transform.
  Vector<T,3> v_radius (s.GetRadius ());
  v_radius = Other2ThisRelative (v_radius);

  float radius = (float)fabs (v_radius.x);
  if (radius < (float)fabs (v_radius.y)) radius = (float)fabs (v_radius.y);
  if (radius < (float)fabs (v_radius.z)) radius = (float)fabs (v_radius.z);
  news.SetRadius (radius);
  return news;
}

template<class T>
csBox3 Transform<T>::Other2This (const csBox3& box) const
{
  if (m_o2t.IsIdentity())
  {
    csBox3 newBox (box);
    newBox.SetCenter (Other2This (box.GetCenter()));
    return newBox;
  }
  else
  {  
    const Vector<T,3> minA = box.Min ();
    const Vector<T,3> maxA = box.Max ();

    Vector<T,3> minB (-m_o2t*v_o2t);
    Vector<T,3> maxB (minB);

    for (size_t i = 0; i < 3; ++i)
    {
      const Vector<T,3> row = m_o2t.Row (i);
      for (size_t j = 0; j < 3; ++j)
      {
        float a = row[j] * minA[j];
        float b = row[j] * maxA[j];
        if (a < b)
        {
          minB[i] += a;
          maxB[i] += b;
        }
        else
        {
          minB[i] += b;
          maxB[i] += a;
        }
      }
    }

    return csBox3 (minB, maxB);
  }
}

#endif // _GEOM

template<class T>
Vector<T,3> operator * (const Vector<T,3> &v, const Transform<T> &t)
{
  return t.Other2This (v);
}

template<class T>
Vector<T,3> operator * (const Transform<T> &t, const Vector<T,3> &v)
{
  return t.Other2This (v);
}

template<class T>
Vector<T,3> &operator*= (Vector<T,3> &v, const Transform<T> &t)
{
  v = t.Other2This (v);
  return v;
}

#ifdef _GEOM

template<class T>
Plane3<T> operator * (const Plane3<T> &p, const Transform<T> &t)
{
  return t.Other2This (p);
}

template<class T>
Plane3<T> operator * (const Transform<T> &t, const Plane3<T> &p)
{
  return t.Other2This (p);
}

template<class T>
Plane3<T> &operator*= (Plane3<T> &p, const Transform<T> &t)
{
  p.norm = t.m_o2t * p.norm;
  p.DD += p.norm * (t.m_o2t * t.v_o2t);
  return p;
}

template<class T>
Sphere<T> operator * (const Sphere<T> &p, const Transform<T> &t)
{
  return t.Other2This (p);
}

template<class T>
Sphere<T> operator * (const Transform<T> &t, const Sphere<T> &p)
{
  return t.Other2This (p);
}

template<class T>
Sphere<T> &operator*= (Sphere<T> &p, const Transform<T> &t)
{
  p.SetCenter (t.Other2This (p.GetCenter ()));

  // @@@ It would be nice if we could quickly detect if a given
  // transformation is orthonormal. In that case we don't need to transform
  // the radius.
  // To transform the radius we transform a vector with the radius
  // relative to the transform.
  Vector<T,3> v_radius (p.GetRadius ());
  v_radius = t.Other2ThisRelative (v_radius);

  float radius = (float)fabs (v_radius.x);
  if (radius < (float)fabs (v_radius.y)) radius = (float)fabs (v_radius.y);
  if (radius < (float)fabs (v_radius.z)) radius = (float)fabs (v_radius.z);
  p.SetRadius (radius);
  return p;
}

template<class T>
csBox3 operator * (const csBox3 &p, const Transform<T> &t)
{
  return t.Other2This (p);
}

template<class T>
csBox3 operator * (const Transform<T> &t, const csBox3 &p)
{
  return t.Other2This (p);
}

template<class T>
csBox3 &operator*= (csBox3 &p, const Transform<T> &t)
{
  p = t.Other2This(p);
  return p;
}

#endif // _GEOM

template<class T>
Matrix3<T> operator * (const Matrix3<T> &m, const Transform<T> &t)
{
  return m * t.m_o2t;
}

template<class T>
Matrix3<T> operator * (const Transform<T> &t, const Matrix3<T> &m)
{
  return t.m_o2t * m;
}

template<class T>
Matrix3<T> &operator*= (Matrix3<T> &m, const Transform<T> &t)
{
  return m *= t.m_o2t;
}

//---------------------------------------------------------------------------
#ifdef _GEOM

template<class T>
Plane3<T> ReversibleTransform<T>::This2Other (const Plane3<T> &p) const
{
  Vector<T,3> newnorm = m_t2o * p.norm;
  return Plane3<T> (newnorm, p.DD - p.norm * (m_o2t * v_o2t));
}

template<class T>
void ReversibleTransform<T>::This2Other (
  const Plane3<T> &p,
  const Vector<T,3> &point,
  Plane3<T> &result) const
{
  result.norm = m_t2o * p.norm;
  result.DD = -(result.norm * point);
}

template<class T>
Plane3<T> ReversibleTransform<T>::This2OtherRelative (const Plane3<T> &p) const
{
  Vector<T,3> newnorm = m_t2o * p.norm;
  return Plane3<T> (newnorm, p.DD);
}

template<class T>
Sphere<T> ReversibleTransform<T>::This2Other (const Sphere<T> &s) const
{
  Sphere<T> news;
  news.SetCenter (This2Other (s.GetCenter ()));

  // @@@ It would be nice if we could quickly detect if a given
  // transformation is orthonormal. In that case we don't need to transform
  // the radius.
  // To transform the radius we transform a vector with the radius
  // relative to the transform.
  Vector<T,3> v_radius (s.GetRadius ());
  v_radius = This2OtherRelative (v_radius);

  float radius = (float)fabs (v_radius.x);
  if (radius < (float)fabs (v_radius.y)) radius = (float)fabs (v_radius.y);
  if (radius < (float)fabs (v_radius.z)) radius = (float)fabs (v_radius.z);
  news.SetRadius (radius);
  return news;
}

template<class T>
csBox3 ReversibleTransform<T>::This2Other (const csBox3 &box) const
{
  if (m_t2o.IsIdentity())
  {
    csBox3 newBox (box);
    newBox.SetCenter (This2Other (box.GetCenter()));
    return newBox;
  }
  else
  {
    const Vector<T,3> minA = box.Min ();
    const Vector<T,3> maxA = box.Max ();

    Vector<T,3> minB (v_o2t);
    Vector<T,3> maxB (v_o2t);

    for (size_t i = 0; i < 3; ++i)
    {
      const Vector<T,3> row = m_t2o.Row (i);
      for (size_t j = 0; j < 3; ++j)
      {
        float a = row[j] * minA[j];
        float b = row[j] * maxA[j];
        if (a < b)
        {
          minB[i] += a;
          maxB[i] += b;
        }
        else
        {
          minB[i] += b;
          maxB[i] += a;
        }
      }
    }

    return csBox3 (minB, maxB);
  }
}

#endif // _GEOM

template<class T>
Vector<T,3> operator/ (const Vector<T,3> &v, const ReversibleTransform<T> &t)
{
  return t.This2Other (v);
}

template<class T>
Vector<T,3> &operator/= (Vector<T,3> &v, const ReversibleTransform<T> &t)
{
  v = t.This2Other (v);
  return v;
}

#ifdef _GEOM

template<class T>
Plane3<T> operator/ (const Plane3<T> &p, const ReversibleTransform<T> &t)
{
  return t.This2Other (p);
}

template<class T>
Sphere<T> operator/ (const Sphere<T> &p, const ReversibleTransform<T> &t)
{
  return t.This2Other (p);
}

template<class T>
csBox3 operator/ (const csBox3 &p, const ReversibleTransform<T> &t)
{
  return t.This2Other (p);
}

template<class T>
Plane3<T> &operator/= (Plane3<T> &p, const ReversibleTransform<T> &t)
{
  p.DD -= p.norm * (t.m_o2t * t.v_o2t);
  p.norm = t.m_t2o * p.norm;
  return p;
}

#endif // _GEOM

template<class T>
Transform<T> operator * (
  const Transform<T> &t1,
  const ReversibleTransform<T> &t2)
{
  return Transform<T> (t1.m_o2t * t2.m_o2t, t2.v_o2t + t2.m_t2o * t1.v_o2t);
}

template<class T>
ReversibleTransform<T> &operator/= (
  ReversibleTransform<T> &t1,
  const ReversibleTransform<T> &t2)
{
  t1.v_o2t = t2.m_o2t * (t1.v_o2t - t2.v_o2t);
  t1.m_o2t *= t2.m_t2o;
  t1.m_t2o = t2.m_o2t * t1.m_t2o;
  return t1;
}

template<class T>
ReversibleTransform<T> operator/ (
  const ReversibleTransform<T> &t1,
  const ReversibleTransform<T> &t2)
{
  return ReversibleTransform<T> (
      t1.m_o2t * t2.m_t2o,
      t2.m_o2t * t1.m_t2o,
      t2.m_o2t * (t1.v_o2t - t2.v_o2t));
}

template<class T>
void ReversibleTransform<T>::RotateOther (const Vector<T,3> &v, float angle)
{
  Vector<T,3> u = v;
  float ca, sa, omcaux, omcauy, omcauz, uxsa, uysa, uzsa;
  u = Vector<T,3>::Unit (u);
  ca = (float)cos (angle);
  sa = (float)sin (angle);
  omcaux = (1 - ca) * u.x;
  omcauy = (1 - ca) * u.y;
  omcauz = (1 - ca) * u.z;
  uxsa = u.x * sa;
  uysa = u.y * sa;
  uzsa = u.z * sa;

  SetT2O (
    Matrix3<T> (
        u.x * omcaux + ca,
        u.y * omcaux - uzsa,
        u.z * omcaux + uysa,
        u.x * omcauy + uzsa,
        u.y * omcauy + ca,
        u.z * omcauy - uxsa,
        u.x * omcauz - uysa,
        u.y * omcauz + uxsa,
        u.z * omcauz + ca) * GetT2O ());
}

template<class T>
void ReversibleTransform<T>::RotateThis (const Vector<T,3> &v, float angle)
{
  Vector<T,3> u = v;
  float ca, sa, omcaux, omcauy, omcauz, uxsa, uysa, uzsa;
  u = Vector<T,3>::Unit (u);
  ca = (float)cos (angle);
  sa = (float)sin (angle);
  omcaux = (1 - ca) * u.x;
  omcauy = (1 - ca) * u.y;
  omcauz = (1 - ca) * u.z;
  uxsa = u.x * sa;
  uysa = u.y * sa;
  uzsa = u.z * sa;

  SetT2O (
    GetT2O () * Matrix3<T> (
        u.x * omcaux + ca,
        u.y * omcaux - uzsa,
        u.z * omcaux + uysa,
        u.x * omcauy + uzsa,
        u.y * omcauy + ca,
        u.z * omcauy - uxsa,
        u.x * omcauz - uysa,
        u.y * omcauz + uxsa,
        u.z * omcauz + ca));
}

template<class T>
bool ReversibleTransform<T>::LookAtGeneric (
  const Vector<T,3> &v,
  const Vector<T,3> &upNeg,
  Vector<T,3>& w1,
  Vector<T,3>& w2,
  Vector<T,3>& w3)
{
  Vector<T,3> up = -upNeg;
  w3 = v;

  float sqr;
  sqr = v * v;
  if (sqr > M_SEPS)
  {
    w3 *= 1./Math::Sqrt (sqr);
    w1 = w3 % up;
    sqr = w1 * w1;
    if (sqr < M_SEPS)
    {
      w1 = w3 % Vector<T,3> (0, 0, -1);
      sqr = w1 * w1;
      if (sqr < M_SEPS)
      {
        w1 = w3 % Vector<T,3> (0, -1, 0);
        sqr = w1 * w1;
      }
    }

    w1 *= 1./Math::Sqrt (sqr);
    w2 = w3 % w1;
    return true;
  }
  return false;
}

template<class T>
bool ReversibleTransform<T>::LookAt (
  const Vector<T,3> &v,
  const Vector<T,3> &upNeg)
{
  if (!LookAtZUpY (v, upNeg))
  {
    SetT2O (Matrix3<T> ());
    return false;
  }
  return true;
}

template<class T>
bool ReversibleTransform<T>::LookAtZUpY (
  const Vector<T,3> &v,
  const Vector<T,3> &upNeg)
{
  Matrix3<T> m;  /* initialized to be the identity matrix */
  Vector<T,3> w1, w2, w3;
  if (!LookAtGeneric (v, upNeg, w1, w2, w3))
    return false;

  m.m11 = w1.x;
  m.m12 = w2.x;
  m.m13 = w3.x;
  m.m21 = w1.y;
  m.m22 = w2.y;
  m.m23 = w3.y;
  m.m31 = w1.z;
  m.m32 = w2.z;
  m.m33 = w3.z;

  SetT2O (m);
  return true;
}

template<class T>
bool ReversibleTransform<T>::LookAtZUpX (
  const Vector<T,3> &v,
  const Vector<T,3> &upNeg)
{
  Matrix3<T> m;  /* initialized to be the identity matrix */
  Vector<T,3> w1, w2, w3;
  if (!LookAtGeneric (v, upNeg, w2, w1, w3))
    return false;

  m.m11 = w1.x;
  m.m12 = w2.x;
  m.m13 = w3.x;
  m.m21 = w1.y;
  m.m22 = w2.y;
  m.m23 = w3.y;
  m.m31 = w1.z;
  m.m32 = w2.z;
  m.m33 = w3.z;

  SetT2O (m);
  return true;
}

template<class T>
bool ReversibleTransform<T>::LookAtXUpZ (
  const Vector<T,3> &v,
  const Vector<T,3> &upNeg)
{
  Matrix3<T> m;  /* initialized to be the identity matrix */
  Vector<T,3> w1, w2, w3;
  if (!LookAtGeneric (v, upNeg, w2, w3, w1))
    return false;

  m.m11 = w1.x;
  m.m12 = w2.x;
  m.m13 = w3.x;
  m.m21 = w1.y;
  m.m22 = w2.y;
  m.m23 = w3.y;
  m.m31 = w1.z;
  m.m32 = w2.z;
  m.m33 = w3.z;

  SetT2O (m);
  return true;
}

template<class T>
bool ReversibleTransform<T>::LookAtXUpY (
  const Vector<T,3> &v,
  const Vector<T,3> &upNeg)
{
  Matrix3<T> m;  /* initialized to be the identity matrix */
  Vector<T,3> w1, w2, w3;
  if (!LookAtGeneric (v, upNeg, w3, w2, w1))
    return false;

  m.m11 = w1.x;
  m.m12 = w2.x;
  m.m13 = w3.x;
  m.m21 = w1.y;
  m.m22 = w2.y;
  m.m23 = w3.y;
  m.m31 = w1.z;
  m.m32 = w2.z;
  m.m33 = w3.z;

  SetT2O (m);
  return true;
}

template<class T>
bool ReversibleTransform<T>::LookAtYUpX (
  const Vector<T,3> &v,
  const Vector<T,3> &upNeg)
{
  Matrix3<T> m;  /* initialized to be the identity matrix */
  Vector<T,3> w1, w2, w3;
  if (!LookAtGeneric (v, upNeg, w3, w1, w2))
    return false;

  m.m11 = w1.x;
  m.m12 = w2.x;
  m.m13 = w3.x;
  m.m21 = w1.y;
  m.m22 = w2.y;
  m.m23 = w3.y;
  m.m31 = w1.z;
  m.m32 = w2.z;
  m.m33 = w3.z;

  SetT2O (m);
  return true;
}

template<class T>
bool ReversibleTransform<T>::LookAtYUpZ (
  const Vector<T,3> &v,
  const Vector<T,3> &upNeg)
{
  Matrix3<T> m;  /* initialized to be the identity matrix */
  Vector<T,3> w1, w2, w3;
  if (!LookAtGeneric (v, upNeg, w2, w1, w3))
    return false;

  m.m11 = w1.x;
  m.m12 = w2.x;
  m.m13 = w3.x;
  m.m21 = w1.y;
  m.m22 = w2.y;
  m.m23 = w3.y;
  m.m31 = w1.z;
  m.m32 = w2.z;
  m.m33 = w3.z;

  SetT2O (m);
  return true;
}

//---------------------------------------------------------------------------
