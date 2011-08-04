/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   transfrm.h
 * @brief  Transformation class
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/08, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_TRANSFRM_H__
#define __SAT_TRANSFRM_H__

/// @addtogroup math_algebra
/// @{

#include "matrix3.h"
#include "vector.h"
#include "math/misc/const.h" // M_SEPS

// class Plane3;
// class Sphere;
// class Box3;

template<class T>
class ReversibleTransform;

/**
 * A class which defines a transformation from one coordinate system to
 * another. The two coordinate systems are refered to as 'other'
 * and 'this'. The transform defines a transformation from 'other'
 * to 'this'.
 */
template<class T>
class Transform
{
protected:
  /// Transformation matrix from 'other' space to 'this' space.
  Matrix3<T> m_o2t;
  /// Location of the origin for 'this' space.
  Vector<T,3> v_o2t;

public:
  // Needed for GCC4. Otherwise emits a flood of "virtual functions but
  // non-virtual destructor" warnings.
  virtual ~Transform() {}
  /**
   * Initialize with the identity transformation.
   */
  Transform () : m_o2t (), v_o2t (0, 0, 0) {}

  /**
   * Initialize with the given transformation. The transformation
   * is given as a 3x3 matrix and a vector. The transformation
   * is defined to mean T=M*(O-V) with T the vector in 'this' space,
   * O the vector in 'other' space, M the transformation matrix and
   * V the transformation vector.
   */
  Transform (const Matrix3<T>& other2this, const Vector<T,3>& origin_pos) :
    m_o2t (other2this), v_o2t (origin_pos) {}

  /// Return a textual representation of the transform
  String Description() const;

  /**
   * Reset this transform to the identity transform.
   */
  inline void Identity ()
  {
    SetO2TTranslation (Vector<T,3> (0));
    SetO2T (Matrix3<T> ());
  }

  /**
   * Returns true if this transform is an identity transform.
   * This tests all fields so don't call this before every operation.
   */
  inline bool IsIdentity () const
  {
    if (ABS (v_o2t.x) >= M_SEPS) return false;
    if (ABS (v_o2t.y) >= M_SEPS) return false;
    if (ABS (v_o2t.z) >= M_SEPS) return false;
    if (ABS (m_o2t.m11-1) >= M_SEPS) return false;
    if (ABS (m_o2t.m12) >= M_SEPS) return false;
    if (ABS (m_o2t.m13) >= M_SEPS) return false;
    if (ABS (m_o2t.m21) >= M_SEPS) return false;
    if (ABS (m_o2t.m22-1) >= M_SEPS) return false;
    if (ABS (m_o2t.m23) >= M_SEPS) return false;
    if (ABS (m_o2t.m31) >= M_SEPS) return false;
    if (ABS (m_o2t.m32) >= M_SEPS) return false;
    if (ABS (m_o2t.m33-1) >= M_SEPS) return false;
    return true;
  }

  /**
   * Get 'other' to 'this' transformation matrix. This is the 3x3
   * matrix M from the transform equation T=M*(O-V).
   */
  inline const Matrix3<T>& GetO2T () const { return m_o2t; }

  /**
   * Get 'other' to 'this' translation. This is the vector V
   * from the transform equation T=M*(O-V). This is equivalent
   * to calling GetOrigin().
   */
  inline const Vector<T,3>& GetO2TTranslation () const { return v_o2t; }

  /**
   * Get origin of transformed coordinate system. In other words, the vector
   * that gets 0,0,0 after transforming with Other2This(). This is equivalent
   * to calling GetO2TTranslation().
   */
  inline const Vector<T,3>& GetOrigin () const { return v_o2t; }

  /**
   * Set 'other' to 'this' transformation matrix.
   * This is the 3x3 matrix M from the transform equation T=M*(O-V).
   */
  virtual void SetO2T (const Matrix3<T>& m)
  { m_o2t = m; }

  /**
   * Set 'world' to 'this' translation. This is the vector V
   * from the transform equation T=M*(O-V). This is equivalent to
   * calling SetOrigin().
   */
  virtual void SetO2TTranslation (const Vector<T,3>& v)
  { v_o2t = v; }

  /**
   * Set origin of transformed coordinate system. This is equivalent
   * to calling SetO2TTranslation().
   */
  inline void SetOrigin (const Vector<T,3>& v)
  { SetO2TTranslation (v); }

  /**
   * Move the 'other' to 'this' translation by a specified amount.
   * Basically this will add 'v' to the origin or translation of this
   * transform so that the new transform looks like T=M*(O-(V+v)).
   */
  inline void Translate (const Vector<T,3>& v)
  { SetO2TTranslation (v_o2t + v); }

  /**
   * Transform vector in 'other' space v to a vector in 'this' space.
   * This is the basic transform function. This will calculate and return
   * M*(v-V).
   */
  inline Vector<T,3> Other2This (const Vector<T,3>& v) const
  { return m_o2t * (v - v_o2t); }

  /**
   * Convert vector v in 'other' space to a vector in 'this' space.
   * Use the origin of 'other' space. This will calculate and return
   * M*v (so the translation or V of this transform is ignored).
   */
  inline Vector<T,3> Other2ThisRelative (const Vector<T,3>& v) const
  { return m_o2t * v; }

#ifdef _GEOM
  /**
   * Convert a plane in 'other' space to 'this' space. If 'p' is expressed
   * as (N,D) (with N a vector for the A,B,C components of 'p') then this will
   * return a new plane which looks like (M*N,D+(M*N)*(M*V)).
   */
  Plane3<T> Other2This (const Plane3<T>& p) const;

  /**
   * Convert a plane in 'other' space to 'this' space.
   * This version ignores translation. If 'p' is expressed as (N,D) (with
   * N a vector for the A,B,C components of 'p') then this will return a new
   * plane which looks like (M*N,D).
   */
  Plane3<T> Other2ThisRelative (const Plane3<T>& p) const;

  /**
   * Convert a plane in 'other' space to 'this' space. This is an optimized
   * version for which a point on the new plane is known (point). The result
   * is stored in 'result'. If 'p' is expressed as (N,D) (with N a vector
   * for the A,B,C components of 'p') then this will return a new plane
   * in 'result' which looks like (M*N,-(M*N)*point).
   */
  void Other2This (const Plane3<T>& p, const Vector<T,3>& point,
                   Plane3<T>& result) const;

  /**
   * Convert a sphere in 'other' space to 'this' space.
   */
  Sphere<T> Other2This (const Sphere<T>& s) const;

  /**
   * Convert a box in 'other' space to 'this' space.
   */
  Box3<T> Other2This (const Box3<T>& box) const;

  /**
   * Return a transform that represents a mirroring across a plane.
   * This function will return a Transform which represents a reflection
   * across the plane pl.
   */
  static Transform GetReflect (const Plane3<T>& pl);

  /**
   * Apply a transformation to a Plane. This corresponds exactly
   * to calling t.Other2This(p).
   */
  friend Plane3<T> operator* (const Plane3<T>& p,
                              const Transform& t);

  /**
   * Apply a transformation to a Plane. This corresponds exactly
   * to calling t.Other2This(p).
   */
  friend Plane3<T> operator* (const Transform& t,
                              const Plane3<T>& p);

  /**
   * Apply a transformation to a Plane. This corresponds exactly
   * to calling p = t.Other2This(p).
   */
  friend Plane3<T>& operator*= (Plane3<T>& p,
                                const Transform& t);

  /**
   * Apply a transformation to a sphere. This corresponds exactly
   * to calling t.Other2This(p).
   */
  friend Sphere<T> operator* (const Sphere<T>& p,
                              const Transform& t);

  /**
   * Apply a transformation to a sphere. This corresponds exactly
   * to calling t.Other2This(p).
   */
  friend Sphere<T> operator* (const Transform& t,
                              const Sphere<T>& p);

  /**
   * Apply a transformation to a sphere. This corresponds exactly
   * to calling p = t.Other2This(p).
   */
  friend Sphere<T>& operator*= (Sphere<T>& p,
                                const Transform& t);

  /**
   * Apply a transformation to a box. This corresponds exactly
   * to calling t.Other2This(p).
   */
  friend Box3<T> operator* (const Box3<T>& p,
                            const Transform& t);

  /**
   * Apply a transformation to a box. This corresponds exactly
   * to calling t.Other2This(p).
   */
  friend Box3<T> operator* (const Transform& t,
                            const Box3<T>& p);

  /**
   * Apply a transformation to a box. This corresponds exactly
   * to calling p = t.Other2This(p).
   */
  friend Box3<T>& operator*= (Box3<T>& p,
                              const Transform& t);

#endif // _GEOM

  /**
   * Apply a transformation to a 3D vector. This corresponds exactly
   * to calling t.Other2This (v).
   */
  template<class TT>
  friend Vector<TT,3> operator* (const Vector<TT,3>& v,
                                 const Transform<TT>& t);

  /**
   * Apply a transformation to a 3D vector. This corresponds exactly
   * to calling t.Other2This (v).
   */
  template<class TT>
  friend Vector<TT,3> operator* (const Transform<TT>& t,
                                 const Vector<TT,3>& v);

  /**
   * Apply a transformation to a 3D vector. This corresponds exactly
   * to calling v = t.Other2This(v).
   */
  template<class TT>
  friend Vector<TT,3>& operator*= (Vector<TT,3>& v,
                                   const Transform<TT>& t);

  /**
   * Multiply a matrix with the transformation matrix. This will calculate
   * and return m*M.
   */
  template<class TT>
  friend Matrix3<TT> operator* (const Matrix3<TT>& m,
                                const Transform<TT>& t);

  /**
   * Multiply a matrix with the transformation matrix. This will calculate
   * and return M*m.
   */
  template<class TT>
  friend Matrix3<TT> operator* (const Transform<TT>& t,
                                const Matrix3<TT>& m);

  /**
   * Multiply a matrix with the transformation matrix.
   * This corresponds exactly to m*=M.
   */
  template<class TT>
  friend Matrix3<TT>& operator*= (Matrix3<TT>& m,
                                  const Transform<TT>& t);

  /**
   * Combine two transforms, rightmost first. Given the following
   * definitions:
   * - 't1' expressed as T=t1.M*(O-t1.V)
   * - 't2' expressed as T=t2.M*(O-t2.V)
   * - t2.Minv is the inverse of t2.M
   *
   * Then this will return a new transform
   * T=(t1.M*t2.M)*(O-(t2.V+t2.Minv*t1.V)).
   */
  template<class TT>
  friend Transform<TT> operator* (const Transform<TT>& t1,
                                  const ReversibleTransform<TT>& t2);

  /**
   * Get the front vector in 'other' space. This is basically equivalent
   * to doing: tr.This2OtherRelative (Vector<T,3> (0, 0, 1)) but it is
   * more efficient.
   */
  Vector<T,3> GetFront () const
  {
    return Vector<T,3> (m_o2t.m31, m_o2t.m32, m_o2t.m33);
  }
  void SetFront (const Vector<T,3>& v)
  {
    m_o2t.m31 = v.x;
    m_o2t.m32 = v.y;
    m_o2t.m33 = v.z;
  }

  /**
   * Get the up vector in 'other' space. This is basically equivalent
   * to doing: tr.This2OtherRelative (Vector<T,3> (0, 1, 0)) but it is
   * more efficient.
   */
  Vector<T,3> GetUp () const
  {
    return Vector<T,3> (m_o2t.m21, m_o2t.m22, m_o2t.m23);
  }
  void SetUp (const Vector<T,3>& v)
  {
    m_o2t.m21 = v.x;
    m_o2t.m22 = v.y;
    m_o2t.m23 = v.z;
  }

  /**
   * Get the right vector in 'other' space. This is basically equivalent
   * to doing: tr.This2OtherRelative (Vector<T,3> (1, 0, 0)) but it is
   * more efficient.
   */
  Vector<T,3> GetRight () const
  {
    return Vector<T,3> (m_o2t.m11, m_o2t.m12, m_o2t.m13);
  }
  void SetRight (const Vector<T,3>& v)
  {
    m_o2t.m11 = v.x;
    m_o2t.m12 = v.y;
    m_o2t.m13 = v.z;
  }
};

/**
 * A class which defines a reversible transformation from one coordinate
 * system to another by maintaining an inverse transformation matrix.
 * This version is similar to Transform (in fact, it is a sub-class)
 * but it is more efficient if you plan to do inverse transformations
 * often.
 * \remarks Despite that the superclass Transform transforms from 'other'
 *   to 'this' space, commonly ReversibleTransform<T> instances are named like
 *   'this2other' - e.g. 'object2world' where 'this' space is object space and
 *   'other' space is world space.
 */
template<class T>
class ReversibleTransform : public Transform<T>
{
protected:
  /// Inverse transformation matrix ('this' to 'other' space).
  Matrix3<T> m_t2o;

  /**
   * Initialize transform with both transform matrix and inverse transform.
   */
  ReversibleTransform<T> (const Matrix3<T>& o2t, const Matrix3<T>& t2o,
                          const Vector<T,3>& pos)
  : Transform<T> (o2t,pos), m_t2o (t2o) {}

private:
  bool LookAtGeneric (const Vector<T,3> &v, const Vector<T,3> &upNeg,
                      Vector<T,3>& w1, Vector<T,3>& w2, Vector<T,3>& w3);

public:
  /**
   * Initialize with the identity transformation.
   */
  ReversibleTransform () : Transform<T> (), m_t2o () {}

  /**
   * Initialize with the given transformation. The transformation
   * is given as a 3x3 matrix and a vector. The transformation
   * is defined to mean T=M*(O-V) with T the vector in 'this' space,
   * O the vector in 'other' space, M the transformation matrix and
   * V the transformation vector.
   */
  ReversibleTransform (const Matrix3<T>& o2t, const Vector<T,3>& pos) :
    Transform<T> (o2t,pos) { m_t2o = Transform<T>::m_o2t.GetInverse (); }

  /**
   * Initialize with the given transformation.
   */
  ReversibleTransform (const Transform<T>& t) :
    Transform<T> (t) { m_t2o = Transform<T>::m_o2t.GetInverse (); }

  /**
   * Initialize with the given transformation.
   */
  ReversibleTransform (const ReversibleTransform<T>& t) :
    Transform<T> (t) { m_t2o = t.m_t2o; }

  /**
   * Get 'this' to 'other' transformation matrix. This corresponds
   * to the inverse of M.
   */
  inline const Matrix3<T>& GetT2O () const { return m_t2o; }

  /**
   * Get 'this' to 'other' translation. This will calculate
   * and return -(M*V).
   */
  inline Vector<T,3> GetT2OTranslation () const
  { return -Transform<T>::m_o2t*Transform<T>::v_o2t; }

  /**
   * Get the inverse of this transform.
   */
  ReversibleTransform<T> GetInverse () const
  { return ReversibleTransform<T> (m_t2o, Transform<T>::m_o2t, -Transform<T>::m_o2t*Transform<T>::v_o2t); }

  /**
   * Set 'other' to 'this' transformation matrix.
   * This is the 3x3 matrix M from the transform equation T=M*(O-V).
   */
  virtual void SetO2T (const Matrix3<T>& m)
  { Transform<T>::m_o2t = m;  m_t2o = Transform<T>::m_o2t.GetInverse (); }

  /**
   * Set 'this' to 'other' transformation matrix.
   * This is equivalent to SetO2T() except that you can now give the
   * inverse matrix.
   */
  virtual void SetT2O (const Matrix3<T>& m)
  { m_t2o = m;  Transform<T>::m_o2t = m_t2o.GetInverse (); }

  /**
   * Convert vector v in 'this' space to 'other' space.
   * This is the basic inverse transform operation and it corresponds
   * with the calculation of V+Minv*v (with Minv the inverse of M).
   */
  inline Vector<T,3> This2Other (const Vector<T,3>& v) const
  { return Transform<T>::v_o2t + m_t2o * v; }

  /**
   * Convert vector v in 'this' space to a vector in 'other' space,
   * relative to local origin. This calculates and returns
   * Minv*v (with Minv the inverse of M).
   */
  inline Vector<T,3> This2OtherRelative (const Vector<T,3>& v) const
  { return m_t2o * v; }

#ifdef _GEOM

  /**
   * Convert a plane in 'this' space to 'other' space. If 'p' is expressed
   * as (N,D) (with N a vector for the A,B,C components of 'p') then this will
   * return a new plane which looks like (Minv*N,D-N*(M*V)) (with Minv
   * the inverse of M).
   */
  Plane3<T> This2Other (const Plane3<T>& p) const;

  /**
   * Convert a plane in 'this' space to 'other' space.
   * This version ignores translation. If 'p' is expressed as (N,D) (with
   * N a vector for the A,B,C components of 'p') then this will return a new
   * plane which looks like (Minv*N,D) (with Minv the inverse of M).
   */
  Plane3<T> This2OtherRelative (const Plane3<T>& p) const;

  /**
   * Convert a plane in 'this' space to 'other' space. This is an optimized
   * version for which a point on the new plane is known (point). The result
   * is stored in 'result'. If 'p' is expressed as (N,D) (with N a vector
   * for the A,B,C components of 'p') then this will return a new
   * plane which looks like (Minv*N,-(Minv*N)*point) (with Minv the inverse
   * of M).
   */
  void This2Other (const Plane3<T>& p, const Vector<T,3>& point,
                   Plane3<T>& result) const;

  /**
   * Convert a sphere in 'this' space to 'other' space.
   */
  Sphere<T> This2Other (const Sphere<T>& s) const;

  /**
   * Converts a box in 'this' space to 'other' space.
   */
  Box3<T> This2Other (const Box3<T>& box) const;

#endif // _GEOM

  /**
   * Rotate the transform by the angle (radians) around the given vector,
   * in other coordinates. Note: this function rotates the transform, not
   * the coordinate system.
   */
  void RotateOther (const Vector<T,3>& v, float angle);

  /**
   * Rotate the transform by the angle (radians) around the given vector,
   * in these coordinates. Note: this function rotates the transform,
   * not the coordinate system.
   */
  void RotateThis (const Vector<T,3>& v, float angle);

  /**
   * Use the given transformation matrix, in other space,
   * to reorient the transformation. Note: this function rotates the
   * transformation, not the coordinate system. This basically
   * calculates Minv=m*Minv (with Minv the inverse of M). M will be
   * calculated accordingly.
   */
  void RotateOther (const Matrix3<T>& m) { SetT2O (m * m_t2o); }

  /**
   * Use the given transformation matrix, in this space,
   * to reorient the transformation. Note: this function rotates the
   * transformation, not the coordinate system. This basically
   * calculates Minv=Minv*m (with Minv the inverse of M). M will be
   * calculated accordingly.
   */
  void RotateThis (const Matrix3<T>& m) { SetT2O (m_t2o * m); }

  /**
   * Let this transform look at the given (x,y,z) point, using up as
   * the up-vector. 'v' should be given relative to the position
   * of the origin of this transform. For example, if the transform is
   * located at pos=(3,1,9) and you want it to look at location
   * loc=(10,2,8) while keeping the orientation so that the up-vector is
   * upwards then you can use: LookAt (loc-pos, Vector<T,3> (0, 1, 0)).
   *
   * Returns false if the lookat couldn't be calculated for some reason.
   * In that case the transform will be reset to identity.
   *
   * This function is equivalent to LookAtZUpY() except that the latter
   * will not modify the transform if the lookat calculation fails.
   */
  bool LookAt (const Vector<T,3>& v, const Vector<T,3>& up);

  /**
   * Let the Z vector of this transform look into a given direction
   * with the Y vector of this transform as the 'up' orientation.
   * This function will not modify the transform if it returns false.
   */
  bool LookAtZUpY (const Vector<T,3>& v, const Vector<T,3>& up);
  /**
   * Let the Z vector of this transform look into a given direction
   * with the X vector of this transform as the 'up' orientation.
   * This function will not modify the transform if it returns false.
   */
  bool LookAtZUpX (const Vector<T,3>& v, const Vector<T,3>& up);
  /**
   * Let the Y vector of this transform look into a given direction
   * with the Z vector of this transform as the 'up' orientation.
   * This function will not modify the transform if it returns false.
   */
  bool LookAtYUpZ (const Vector<T,3>& v, const Vector<T,3>& up);
  /**
   * Let the Y vector of this transform look into a given direction
   * with the X vector of this transform as the 'up' orientation.
   * This function will not modify the transform if it returns false.
   */
  bool LookAtYUpX (const Vector<T,3>& v, const Vector<T,3>& up);
  /**
   * Let the X vector of this transform look into a given direction
   * with the Z vector of this transform as the 'up' orientation.
   * This function will not modify the transform if it returns false.
   */
  bool LookAtXUpZ (const Vector<T,3>& v, const Vector<T,3>& up);
  /**
   * Let the X vector of this transform look into a given direction
   * with the Y vector of this transform as the 'up' orientation.
   * This function will not modify the transform if it returns false.
   */
  bool LookAtXUpY (const Vector<T,3>& v, const Vector<T,3>& up);

  /**
   * Reverse a transformation on a 3D vector. This corresponds exactly
   * to calling t.This2Other(v).
   */
  template<class TT>
  friend Vector<TT,3> operator/ (const Vector<TT,3>& v,
                                 const ReversibleTransform<TT>& t);

  /**
   * Reverse a transformation on a 3D vector. This corresponds exactly
   * to calling v=t.This2Other(v).
   */
  template<class TT>
  friend Vector<TT,3>& operator/= (Vector<TT,3>& v,
                                   const ReversibleTransform<TT>& t);

#ifdef _GEOM

  /**
   * Reverse a transformation on a Plane. This corresponds exactly
   * to calling t.This2Other(p).
   */
  friend Plane3<T> operator/ (const Plane3<T>& p,
                              const ReversibleTransform<T>& t);

  /**
   * Reverse a transformation on a Plane. This corresponds exactly to
   * calling p = t.This2Other(p).
   */
  friend Plane3<T>& operator/= (Plane3<T>& p,
                                const ReversibleTransform<T>& t);

  /**
   * Reverse a transformation on a sphere. This corresponds exactly to
   * calling t.This2Other(p).
   */
  friend Sphere<T> operator/ (const Sphere<T>& p,
                              const ReversibleTransform<T>& t);

  /**
   * Reverse a transformation on a box. This corresponds exactly to
   * calling t.This2Other(p).
   */
  friend Box3<T> operator/ (const Box3<T>& p,
                            const ReversibleTransform<T>& t);

#endif // _GEOM

  /**
   * Combine two transforms, rightmost first. Given the following
   * definitions:
   * - 't1' expressed as T=t1.M*(O-t1.V)
   * - 't2' expressed as T=t2.M*(O-t2.V)
   * - t1.Minv is the inverse of t1.M
   * - t2.Minv is the inverse of t2.M
   *
   * Then this will calculate a new transformation in 't1' as follows:
   * T=(t1.M*t2.M)*(O-(t2.Minv*t1.V+t2.V)).
   */
  friend ReversibleTransform<T>& operator*= (ReversibleTransform<T>& t1,
                                             const ReversibleTransform<T>& t2)
  {
    t1.v_o2t = t2.m_t2o*t1.v_o2t;
    t1.v_o2t += t2.v_o2t;
    t1.m_o2t *= t2.m_o2t;
    t1.m_t2o = t2.m_t2o * t1.m_t2o;
    return t1;
  }

  /**
   * Combine two transforms, rightmost first. Given the following
   * definitions:
   * - 't1' expressed as T=t1.M*(O-t1.V)
   * - 't2' expressed as T=t2.M*(O-t2.V)
   * - t1.Minv is the inverse of t1.M
   * - t2.Minv is the inverse of t2.M
   *
   * Then this will calculate a new transformation in 't1' as follows:
   * T=(t1.M*t2.M)*(O-(t2.Minv*t1.V+t2.V)).
   */
  friend ReversibleTransform<T> operator* (const ReversibleTransform<T>& t1,
                                           const ReversibleTransform<T>& t2)
  {
    return ReversibleTransform<T> (t1.m_o2t*t2.m_o2t, t2.m_t2o*t1.m_t2o,
                                   t2.v_o2t + t2.m_t2o*t1.v_o2t);
  }

#if !defined(SWIG) /* Otherwise Swig 1.3.22 thinks this is multiply declared */
  /**
   * Combine two transforms, rightmost first. Given the following
   * definitions:
   * - 't1' expressed as T=t1.M*(O-t1.V)
   * - 't2' expressed as T=t2.M*(O-t2.V)
   * - t1.Minv is the inverse of t1.M
   * - t2.Minv is the inverse of t2.M
   *
   * Then this will calculate a new transformation in 't1' as follows:
   * T=(t1.M*t2.M)*(O-(t2.Minv*t1.V+t2.V)).
   */
  template<class TT>
  friend Transform<TT> operator* (const Transform<TT>& t1,
                                  const ReversibleTransform<TT>& t2);
#endif

  /**
   * Combine two transforms, reversing t2 then applying t1.
   * Given the following definitions:
   * - 't1' expressed as T=t1.M*(O-t1.V)
   * - 't2' expressed as T=t2.M*(O-t2.V)
   * - t1.Minv is the inverse of t1.M
   * - t2.Minv is the inverse of t2.M
   *
   * Then this will calculate a new transformation in 't1' as follows:
   * T=(t1.M*t2.Minv)*(O-(t2.M*(t1.V-t2.V))).
   */
  template<class TT>
  friend ReversibleTransform<TT>& operator/= (ReversibleTransform<TT>& t1,
                                              const ReversibleTransform<TT>& t2);

  /**
   * Combine two transforms, reversing t2 then applying t1.
   * Given the following definitions:
   * - 't1' expressed as T=t1.M*(O-t1.V)
   * - 't2' expressed as T=t2.M*(O-t2.V)
   * - t1.Minv is the inverse of t1.M
   * - t2.Minv is the inverse of t2.M
   *
   * Then this will calculate a new transformation in 't1' as follows:
   * T=(t1.M*t2.Minv)*(O-(t2.M*(t1.V-t2.V))).
   */
  template<class TT>
  friend ReversibleTransform<TT> operator/ (const ReversibleTransform<TT>& t1,
					    const ReversibleTransform<TT>& t2);
};

/**
 * A class which defines a reversible transformation from one coordinate
 * system to another by maintaining an inverse transformation matrix.
 * This is a variant which only works on orthonormal transformations (like
 * the camera transformation) and is consequently much more optimal.
 */
template<class T>
class OrthoTransform : public ReversibleTransform<T>
{
public:
  /**
   * Initialize with the identity transformation.
   */
  OrthoTransform () : ReversibleTransform<T> () {}

  /**
   * Initialize with the given transformation.
   */
  OrthoTransform (const Matrix3<T>& o2t, const Vector<T,3>& pos) :
    ReversibleTransform<T> (o2t, o2t.GetTranspose (), pos) { }

  /**
   * Initialize with the given transformation.
   */
  OrthoTransform (const Transform<T>& t) :
    ReversibleTransform<T> (t.GetO2T (), t.GetO2T ().GetTranspose (),
                            t.GetO2TTranslation ())
  { }

  /**
   * Set 'other' to 'this' transformation matrix.
   * This is the 3x3 matrix M from the transform equation T=M*(O-V).
   */
  virtual void SetO2T (const Matrix3<T>& m)
  {
    Transform<T>::m_o2t = m;
    ReversibleTransform<T>::m_t2o = Transform<T>::m_o2t.GetTranspose ();
  }

  /**
   * Set 'this' to 'other' transformation matrix.
   * This is equivalent to SetO2T() except that you can now give the
   * inverse matrix.
   */
  virtual void SetT2O (const Matrix3<T>& m)
  {
    ReversibleTransform<T>::m_t2o = m;
    Transform<T>::m_o2t = ReversibleTransform<T>::m_t2o.GetTranspose ();
  }
};

/// @}

#endif /* __SAT_TRANSFRM_H__ */
