/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   quaternion.h
 * @brief  Representation of a quaternion.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_QUATERNION_H__
#define __SAT_QUATERNION_H__

#include "vector.h"
#include "math/func/stdmath.h"

/// @addtogroup math_alg
/// @{

/**
 * @brief Representation of a quaternion.
 * A SE3 rotation represented as a normalized quaternion.
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */
template <class T>
class Quaternion
{
public:
  typedef Vector<T,3> TVector;
  typedef Quaternion<T> TQuaternion;

  /// @name Constructors
  /// @{

  /// Initialize with identity
  Quaternion ()
    : v ((T)0), w ((T)1) {}

  /// Initialize with given values. Does not normalize
  Quaternion (T x, T y, T z, T w)
    : v (x, y, z), w (w) {}

  /// Construct from a vector and given w value
  Quaternion (const TVector& v, T w)
    : v (v), w (w) {}

  /// Copy-constructor
  Quaternion (const TQuaternion& q)
    : v (q.v), w (q.w) {}

  /// @}

  /// Set quaternion to identity rotation
  inline void SetIdentity ()
  { v.Set ((T)0); w = (T)1; }

  /// Add two quaternions
  inline friend TQuaternion operator+ (const TQuaternion& q1,
    const TQuaternion& q2)
  {
    return TQuaternion (q1.v+q2.v, q1.w+q2.w);
  }

  /// Add quaternion to this one
  inline TQuaternion& operator+= (const TQuaternion& q)
  {
    v += q.v; w += q.w;
    return *this;
  }

  /// Subtract two quaternions
  inline friend TQuaternion operator- (const TQuaternion& q1,
    const TQuaternion& q2)
  {
    return TQuaternion (q1.v-q2.v, q1.w-q2.w);
  }

  /// Subtract quaternion from this one
  inline TQuaternion& operator-= (const TQuaternion& q)
  {
    v -= q.v; w -= q.w;
    return *this;
  }

  /// Get the negative quaternion (unary minus)
  inline friend TQuaternion operator- (const TQuaternion& q)
  {
    return TQuaternion (-q.v, -q.w);
  }

  /// Multiply two quaternions, Grassmann product
  inline friend TQuaternion operator* (const TQuaternion& q1,
    const TQuaternion& q2)
  {
    return TQuaternion (q1.v*q2.w + q1.w*q2.v + q1.v%q2.v,
      q1.w*q2.w - q1.v*q2.v);
  }

  /// Multiply this quaternion by another
  inline TQuaternion& operator*= (const TQuaternion& q)
  {
    TVector newV = v*q.w + w*q.v + v%q.v;
    w = w*q.w - v*q.v;
    v = newV;
    return *this;
  }

  /// Multiply by scalar
  inline friend TQuaternion operator* (const TQuaternion q, T f)
  {
    return TQuaternion (q.v*f, q.w*f);
  }

  /// Multiply by scalar
  inline friend TQuaternion operator* (T f, const TQuaternion q)
  {
    return TQuaternion (q.v*f, q.w*f);
  }

  /// Divide by scalar
  inline friend TQuaternion operator/ (const TQuaternion q, T f)
  {
    T invF = 1.0/f;
    return TQuaternion (q.v*invF, q.w*invF);
  }

  /// Divide by scalar
  inline friend TQuaternion operator/ (T f, const TQuaternion q)
  {
    T invF = 1.0/f;
    return TQuaternion (q.v*invF, q.w*invF);
  }

  /// Get the conjugate quaternion
  inline TQuaternion GetConjugate () const
  {
    return TQuaternion (-v, w);
  }

  /// Set this quaternion to its own conjugate
  inline void Conjugate ()
  {
    v = -v;
  }

  /// Return euclidian inner-product (dot)
  inline T Dot (const TQuaternion& q) const
  {
    return v*q.v + w*q.w;
  }

  /// Get the squared norm of this quaternion (equals dot with itself)
  inline T SquaredNorm () const
  {
    return Dot (*this);
  }

  /// Get the norm of this quaternion
  inline T Norm () const
  {
    return Math::Sqrt (SquaredNorm ());
  }

  /**
   * Return a unit-lenght version of this quaternion (also called sgn)
   * Attempting to normalize a zero-length quaternion will result in a divide by
   * zero error.  This is as it should be... fix the calling code.
   */
  inline TQuaternion Unit () const
  {
    return (*this) / Norm ();
  }

  /**
   * Rotate vector by quaternion.
   */
  inline TVector Rotate (const TVector& src) const
  {
    TQuaternion p (src, 0);
    TQuaternion q = *this * p;
    q *= GetConjugate ();
    return q.v;
  }

  /**
   * Set a quaternion using axis-angle representation
   * \param axis
   * Rotation axis. Should be normalized before calling this function.
   * \param angle
   * Angle to rotate about axis (in radians)
   */
  inline void SetAxisAngle (const TVector& axis, T angle)
  {
    v = axis * Math::Sin (angle / (T)2);
    w = Math::Cos (angle / (T)2);
  }

  /**
   * Get a quaternion as axis-angle representation
   * \param axis
   * Rotation axis.
   * \param angle
   * Angle to rotate about axis (in radians)
   */
  inline void GetAxisAngle (TVector& axis, T& angle) const
  {
    angle = 2.0 * Math::ACos (w);
    if (v.SquaredNorm () != 0)
      axis = v.Unit ();
    else
      axis.Set (1.0, 0.0, 0.0);
  }

  /// Set quaternion using Euler angles X, Y, Z, expressed in radians
  void SetEulerAngles (const TVector& angles);

  /// Get quaternion as three Euler angles X, Y, Z, expressed in radians
  TVector GetEulerAngles () const;

  /// Set quaternion using 3x3 rotation matrix
  // void SetMatrix (const Matrix3& matrix);

  /// Get quaternion as a 3x3 rotation matrix
  // Matrix3 GetMatrix () const;

  /**
   * Interpolate this quaternion with another using normalized linear
   * interpolation (nlerp) using given interpolation factor.
   */
  TQuaternion NLerp (const TQuaternion& q2, T t) const;

  /**
   * Interpolate this quaternion with another using spherical linear
   * interpolation (slerp) using given interpolation factor.
   */
  TQuaternion SLerp (const TQuaternion& q2, T t) const;

  /// Get quaternion log
  TQuaternion Ln () const
  { return Log (); }

  /// Get quaternion log
  TQuaternion Log () const;

  /// Get quaternion exp
  TQuaternion Exp () const;

  /**
   * Interpolate this quaternion with another (q) using cubic linear
   * interpolation (squad) using given interpolation factor (t)
   * and tangents (t1 and t2)
   */
  TQuaternion Squad (const TQuaternion & t1, const TQuaternion & t2,
    const TQuaternion & q, T t) const;

private:
  // Data
  TVector v;
  T w;
};

/// @}

#endif /* __SAT_QUATERNION_H__ */
