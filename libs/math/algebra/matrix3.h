/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   matrix3.h
 * @brief  Matrix 3x3 class
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/08, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_MATRIX3_H__
#define __SAT_MATRIX3_H__

/// @addtogroup math_algebra
/// @{

#include "vector.h"
#include "quaternion.h"

/**
 * A 3x3 matrix.
 */
template<class T>
class Matrix3
{
public:
  T m11, m12, m13;
  T m21, m22, m23;
  T m31, m32, m33;

public:
  /// Construct a matrix, initialized to be the identity.
  Matrix3 ()
    : m11(1), m12(0), m13(0),
      m21(0), m22(1), m23(0),
      m31(0), m32(0), m33(1)
  {}

  /// Construct a matrix and initialize it.
  Matrix3 (T am11, T am12, T am13,
           T am21, T am22, T am23,
           T am31, T am32, T am33)
    : m11(am11), m12(am12), m13(am13),
      m21(am21), m22(am22), m23(am23),
      m31(am31), m32(am32), m33(am33)
  {}

  /// Copy constructor.
  Matrix3 (Matrix3<T> const& o)
    : m11(o.m11), m12(o.m12), m13(o.m13),
      m21(o.m21), m22(o.m22), m23(o.m23),
      m31(o.m31), m32(o.m32), m33(o.m33)
  {}

  /// Construct a matrix from axis-angle specifier.
  Matrix3 (T x,T y, T z, T angle);

  /// Construct a matrix with a quaternion.
  explicit Matrix3 (const Quaternion<T> &quat)
  { Set (quat); }

  /// Return a textual representation of the matrix
  String Description() const;

  /// Get the first row of this matrix as a vector.
  inline Vector<T,3> Row1() const { return Vector<T,3> (m11, m12, m13); }
  void SetRow1 (const Vector<T,3>& r) { m11 = r[0]; m12 = r[1]; m13 = r[2]; }

  /// Get the second row of this matrix as a vector.
  inline Vector<T,3> Row2() const { return Vector<T,3> (m21, m22, m23); }
  void SetRow2 (const Vector<T,3>& r) { m21 = r[0]; m22 = r[1]; m23 = r[2]; }

  /// Get the third row of this matrix as a vector.
  inline Vector<T,3> Row3() const { return Vector<T,3> (m31, m32, m33); }
  void SetRow3 (const Vector<T,3>& r) { m31 = r[0]; m32 = r[1]; m33 = r[2]; }

  /// Get a row from this matrix as a vector.
  inline Vector<T,3> Row(size_t n) const
  {
    return !n ? Vector<T,3> (m11, m12, m13) :
      n&1 ? Vector<T,3> (m21, m22, m23) :
      Vector<T,3> (m31, m32, m33);
  }
  void SetRow (size_t n, const Vector<T,3>& r)
  {
    if (n == 0) SetRow1 (r);
    else if (n == 1) SetRow2 (r);
    else SetRow3 (r);
  }

  /// Get the first column of this matrix as a vector.
  inline Vector<T,3> Col1() const { return Vector<T,3> (m11, m21, m31); }
  void SetCol1 (const Vector<T,3>& c) { m11 = c[0]; m21 = c[1]; m31 = c[2]; }

  /// Get the second column of this matrix as a vector.
  inline Vector<T,3> Col2() const { return Vector<T,3> (m12, m22, m32); }
  void SetCol2 (const Vector<T,3>& c) { m12 = c[0]; m22 = c[1]; m32 = c[2]; }

  /// Get the third column of this matrix as a vector.
  inline Vector<T,3> Col3() const { return Vector<T,3> (m13, m23, m33); }
  void SetCol3 (const Vector<T,3>& c) { m13 = c[0]; m23 = c[1]; m33 = c[2]; }

  /// Get a column from this matrix as a vector.
  inline Vector<T,3> Col(size_t n) const
  {
    return !n ? Vector<T,3> (m11, m21, m31) :
      n&1 ? Vector<T,3> (m12, m22, m32) :
      Vector<T,3> (m13, m23, m33);
  }
  void SetCol (size_t n, const Vector<T,3>& c)
  {
    if (n == 0) SetCol1 (c);
    else if (n == 1) SetCol2 (c);
    else SetCol3 (c);
  }

  /// Set matrix values.
  inline void Set (T o11, T o12, T o13,
                   T o21, T o22, T o23,
                   T o31, T o32, T o33)
  {
    m11 = o11; m12 = o12; m13 = o13;
    m21 = o21; m22 = o22; m23 = o23;
    m31 = o31; m32 = o32; m33 = o33;
  }

  /// Set matrix values.
  inline void Set (Matrix3<T> const &o)
  {
    m11 = o.m11; m12 = o.m12; m13 = o.m13;
    m21 = o.m21; m22 = o.m22; m23 = o.m23;
    m31 = o.m31; m32 = o.m32; m33 = o.m33;
  }

  /// Initialize matrix with a quaternion.
  void Set (const Quaternion<T>&);

  /// Assign another matrix to this one.
  inline Matrix3<T>& operator= (const Matrix3<T>& o)
  { Set(o); return *this; }

  /// Add another matrix to this matrix.
  inline Matrix3<T>& operator+= (const Matrix3<T>& m)
  {
    m11 += m.m11; m12 += m.m12; m13 += m.m13;
    m21 += m.m21; m22 += m.m22; m23 += m.m23;
    m31 += m.m31; m32 += m.m32; m33 += m.m33;
    return *this;
  }

  /// Subtract another matrix from this matrix.
  inline Matrix3<T>& operator-= (const Matrix3<T>& m)
  {
    m11 -= m.m11; m12 -= m.m12; m13 -= m.m13;
    m21 -= m.m21; m22 -= m.m22; m23 -= m.m23;
    m31 -= m.m31; m32 -= m.m32; m33 -= m.m33;
    return *this;
  }

  /// Multiply another matrix with this matrix.
  inline Matrix3<T>& operator*= (const Matrix3<T>& m)
  {
    T old_m11 = m11;
    m11 = m11 * m.m11 + m12 * m.m21 + m13 * m.m31;

    T old_m12 = m12;
    m12 = old_m11 * m.m12 + m12 * m.m22 + m13 * m.m32;
    m13 = old_m11 * m.m13 + old_m12 * m.m23 + m13 * m.m33;

    T old_m21 = m21;
    m21 = m21 * m.m11 + m22 * m.m21 + m23 * m.m31;

    T old_m22 = m22;
    m22 = old_m21 * m.m12 + m22 * m.m22 + m23 * m.m32;
    m23 = old_m21 * m.m13 + old_m22 * m.m23 + m23 * m.m33;

    T old_m31 = m31;
    m31 = m31 * m.m11 + m32 * m.m21 + m33 * m.m31;

    T old_m32 = m32;
    m32 = old_m31 * m.m12 + m32 * m.m22 + m33 * m.m32;
    m33 = old_m31 * m.m13 + old_m32 * m.m23 + m33 * m.m33;
    return *this;
  }

  /// Multiply this matrix with a scalar.
  inline Matrix3<T>& operator*= (T s)
  {
    m11 *= s; m12 *= s; m13 *= s;
    m21 *= s; m22 *= s; m23 *= s;
    m31 *= s; m32 *= s; m33 *= s;
    return *this;
  }

  /// Divide this matrix by a scalar.
  inline Matrix3<T>& operator/= (T s)
  {
    s = 1.0f/s;
    m11 *= s; m12 *= s; m13 *= s;
    m21 *= s; m22 *= s; m23 *= s;
    m31 *= s; m32 *= s; m33 *= s;
    return *this;
  }

  /// Unary + operator.
  inline Matrix3<T> operator+ () const
  { return *this; }

  /// Unary - operator.
  inline Matrix3<T> operator- () const
  {
    return Matrix3<T>(-m11,-m12,-m13,
                      -m21,-m22,-m23,
                      -m31,-m32,-m33);
  }

  /// Transpose this matrix.
  inline void Transpose ()
  {
    T swap;
    swap = m12; m12 = m21; m21 = swap;
    swap = m13; m13 = m31; m31 = swap;
    swap = m23; m23 = m32; m32 = swap;
  }

  /// Return the transpose of this matrix.
  Matrix3<T> GetTranspose () const
  {
    return Matrix3<T> (m11, m21, m31,
                       m12, m22, m32,
                       m13, m23, m33);
  }

  /// Return the inverse of this matrix.
  inline Matrix3<T> GetInverse () const
  {
    Matrix3<T> C((m22*m33 - m23*m32), -(m12*m33 - m13*m32),  (m12*m23 - m13*m22),
                 -(m21*m33 - m23*m31),  (m11*m33 - m13*m31), -(m11*m23 - m13*m21),
                 (m21*m32 - m22*m31), -(m11*m32 - m12*m31),  (m11*m22 - m12*m21));
    T s = (T)1./(m11*C.m11 + m12*C.m21 + m13*C.m31);
    C *= s;
    return C;
  }

  /// Invert this matrix.
  inline void Invert()
  { *this = GetInverse (); }

  /// Compute the determinant of this matrix.
  T Determinant () const
  {
    return m11 * (m22 * m33 - m23 * m32)
      - m12 * (m21 * m33 - m23 * m31)
      + m13 * (m21 * m32 - m22 * m31);
  }

  /// Set this matrix to the identity matrix.
  inline void Identity ()
  {
    m11 = m22 = m33 = 1.0;
    m12 = m13 = m21 = m23 = m31 = m32 = 0.0;
  }

  /// Check if the matrix is identity
  inline bool IsIdentity () const
  {
    return (m11 == 1.0) && (m12 == 0.0) && (m13 == 0.0) &&
      (m21 == 0.0) && (m22 == 1.0) && (m23 == 0.0) &&
      (m31 == 0.0) && (m32 == 0.0) && (m33 == 1.0);
  }

  /// Add two matricies.
  inline friend Matrix3<T> operator+ (const Matrix3<T>& m1,
                                      const Matrix3<T>& m2)
  {
    return Matrix3<T> (m1.m11 + m2.m11, m1.m12 + m2.m12, m1.m13 + m2.m13,
                       m1.m21 + m2.m21, m1.m22 + m2.m22, m1.m23 + m2.m23,
                       m1.m31 + m2.m31, m1.m32 + m2.m32, m1.m33 + m2.m33);
  }

  /// Subtract two matricies.
  inline friend Matrix3<T> operator- (const Matrix3<T>& m1,
                                      const Matrix3<T>& m2)
  {
    return Matrix3<T> (m1.m11 - m2.m11, m1.m12 - m2.m12, m1.m13 - m2.m13,
                       m1.m21 - m2.m21, m1.m22 - m2.m22, m1.m23 - m2.m23,
                       m1.m31 - m2.m31, m1.m32 - m2.m32, m1.m33 - m2.m33);
  }

  /// Multiply two matricies.
  inline friend Matrix3<T> operator* (const Matrix3<T>& m1,
                                      const Matrix3<T>& m2)
  {
    return Matrix3<T> (m1.m11 * m2.m11 + m1.m12 * m2.m21 + m1.m13 * m2.m31,
                       m1.m11 * m2.m12 + m1.m12 * m2.m22 + m1.m13 * m2.m32,
                       m1.m11 * m2.m13 + m1.m12 * m2.m23 + m1.m13 * m2.m33,
                       m1.m21 * m2.m11 + m1.m22 * m2.m21 + m1.m23 * m2.m31,
                       m1.m21 * m2.m12 + m1.m22 * m2.m22 + m1.m23 * m2.m32,
                       m1.m21 * m2.m13 + m1.m22 * m2.m23 + m1.m23 * m2.m33,
                       m1.m31 * m2.m11 + m1.m32 * m2.m21 + m1.m33 * m2.m31,
                       m1.m31 * m2.m12 + m1.m32 * m2.m22 + m1.m33 * m2.m32,
                       m1.m31 * m2.m13 + m1.m32 * m2.m23 + m1.m33 * m2.m33);
  }

  /// Multiply a vector by a matrix (transform it).
  inline friend Vector<T,3> operator* (const Matrix3<T>& m,
				       const Vector<T,3>& v)
  {
    return Vector<T,3> (m.m11*v[0] + m.m12*v[1] + m.m13*v[2],
			m.m21*v[0] + m.m22*v[1] + m.m23*v[2],
			m.m31*v[0] + m.m32*v[1] + m.m33*v[2]);
  }

  /// Multiply a matrix and a scalar.
  inline friend Matrix3<T> operator* (const Matrix3<T>& m, T f)
  {
    return Matrix3<T> (
                       m.m11 * f, m.m12 * f, m.m13 * f,
                       m.m21 * f, m.m22 * f, m.m23 * f,
                       m.m31 * f, m.m32 * f, m.m33 * f);
  }

  /// Multiply a matrix and a scalar.
  inline friend Matrix3<T> operator* (T f, const Matrix3<T>& m)
  {
    return Matrix3<T> (
                       m.m11 * f, m.m12 * f, m.m13 * f,
                       m.m21 * f, m.m22 * f, m.m23 * f,
                       m.m31 * f, m.m32 * f, m.m33 * f);
  }

  /// Divide a matrix by a scalar.
  inline friend Matrix3<T> operator/ (const Matrix3<T>& m, T f)
  {
    T inv_f = 1 / f;
    return Matrix3<T> (
                       m.m11 * inv_f, m.m12 * inv_f, m.m13 * inv_f,
                       m.m21 * inv_f, m.m22 * inv_f, m.m23 * inv_f,
                       m.m31 * inv_f, m.m32 * inv_f, m.m33 * inv_f);
  }

  /// Check if two matricies are equal.
  inline friend bool operator== (const Matrix3<T>& m1, const Matrix3<T>& m2)
  {
    if (m1.m11 != m2.m11 || m1.m12 != m2.m12 || m1.m13 != m2.m13)
      return false;
    if (m1.m21 != m2.m21 || m1.m22 != m2.m22 || m1.m23 != m2.m23)
      return false;
    if (m1.m31 != m2.m31 || m1.m32 != m2.m32 || m1.m33 != m2.m33)
      return false;
    return true;
  }

  /// Check if two matricies are not equal.
  inline friend bool operator!= (const Matrix3<T>& m1, const Matrix3<T>& m2)
  {
    if (m1.m11 != m2.m11 || m1.m12 != m2.m12 || m1.m13 != m2.m13) return true;
    if (m1.m21 != m2.m21 || m1.m22 != m2.m22 || m1.m23 != m2.m23) return true;
    if (m1.m31 != m2.m31 || m1.m32 != m2.m32 || m1.m33 != m2.m33) return true;
    return false;
  }

  /// Test if each component of a matrix is less than a small epsilon value.
  inline friend bool operator< (const Matrix3<T>& m, T f)
  {
    return fabsf (m.m11) < f && fabsf (m.m12) < f && fabsf (m.m13) < f &&
      fabsf (m.m21) < f && fabsf (m.m22) < f && fabsf (m.m23) < f &&
      fabsf (m.m31) < f && fabsf (m.m32) < f && fabsf (m.m33) < f;
  }

  /// Test if each component of a matrix is greater than a small epsilon value.
  inline friend bool operator> (T f, const Matrix3<T>& m)
  {
    return !(m < f);
  }
};

/// An instance of Matrix3<T> that is initialized as a rotation about X
template<class T>
class XRotMatrix3 : public Matrix3<T>
{
public:
  /**
   * Return a rotation matrix around the X axis.  'angle' is given in radians.
   * Looking along the X axis with Y pointing to the right and Z pointing up a
   * rotation of PI/2 will rotate 90 degrees in anti-clockwise direction (i.e.
   * 0,1,0 -> 0,0,1).
   */
  XRotMatrix3<T> (T angle);
};

/// An instance of Matrix3 that is initialized as a rotation about Y.
template<class T>
class YRotMatrix3 : public Matrix3<T>
{
public:
  /**
   * Return a rotation matrix around the Y axis.  'angle' is given in radians.
   * Looking along the Y axis with X pointing to the right and Z pointing up a
   * rotation of PI/2 will rotate 90 degrees in anti-clockwise direction (i.e.
   * 1,0,0 -> 0,0,1).
   */
  YRotMatrix3<T> (T angle);
};

/// An instance of Matrix3 that is initialized as a rotation about Z.
template<class T>
class ZRotMatrix3 : public Matrix3<T>
{
public:
  /**
   * Return a rotation matrix around the Z axis.  'angle' is given in radians.
   * Looking along the Z axis with X pointing to the right and Y pointing up a
   * rotation of PI/2 will rotate 90 degrees in anti-clockwise direction (i.e.
   * 1,0,0 -> 0,1,0).
   */
  ZRotMatrix3<T> (T angle);
};

/// An instance of Matrix3 that is initialized to scale the X dimension.
template<class T>
class XScaleMatrix3 : public Matrix3<T>
{
public:
  /**
   * Return a matrix which scales in the X dimension.
   */
  XScaleMatrix3<T> (T scaler)
  : Matrix3<T>(scaler, 0, 0, 0, 1, 0, 0, 0, 1)
  {}
};

/// An instance of Matrix3 that is initialized to scale the Y dimension.
template<class T>
class YScaleMatrix3 : public Matrix3<T>
{
public:
  /**
   * Return a matrix which scales in the Y dimension.
   */
  YScaleMatrix3<T> (T scaler)
  : Matrix3<T>(1, 0, 0, 0, scaler, 0, 0, 0, 1)
  {}
};

/// An instance of Matrix3 that is initialized to scale the Z dimension.
template<class T>
class ZScaleMatrix3 : public Matrix3<T>
{
public:
  /**
   * Return a matrix which scales in the Z dimension.
   */
  ZScaleMatrix3<T> (T scaler)
  : Matrix3<T>(1, 0, 0, 0, 1, 0, 0, 0, scaler)
  {}
};

#include "matrix3.cpp"

/// @}

#endif /* __SAT_MATRIX3_H__ */
