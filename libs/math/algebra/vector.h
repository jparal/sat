/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   vector.h
 * @brief  Implementation of tiny vector.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-01-23, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_VECTOR_H__
#define __SAT_VECTOR_H__

#include "base/common/string.h"
#include "base/common/meta.h"

#include "newdisable.h"
#include <ostream>
#include "newenable.h"

template<class T> class MpiOStream;
template<class T> class MpiIStream;

/// Small value to compare Vector to be zero.
#define SMALL_EPS 0.0001

/// @addtogroup math_alg
/// @{

/**
 * Tiny Vector implementation.
 *
 * @todo Try to write template spcialization of Vector<T,3> and check for
 *       speed gain.
 * @todo Move friend function into cpp file if possible
 * @todo Many of the functions can be written by meta-programming
 *
 * @revision{1.0}
 * @reventry{2008/08, @jparal}
 * @revmessg{added operator<< for class ostream}
 * @reventry{2009/03, @jparal}
 * @revmessg{Avoid many problems by removing second template type from all
 *          calling except of constructor and Set function. This leads to much
 *          cleaner type resolution by compiler in the expression and I guess
 *          it could avoid troubles in the future.}
 */
template <class T, int D = 3>
class Vector
{
public:
  typedef Vector<T,D> TVector;

  /// @name Constructors
  /// @{

  /// Create an @b uninitialized vector.
  Vector () {}

  /// Create Vector where all components are initialized to one number.
  Vector (T v);

  /// Create Vector and initialize
  Vector (T v0, T v1);

  /// Create Vector and initialize
  Vector (T v0, T v1, T v2);

  /// Create Vector and initialize
  Vector (T v0, T v1, T v2, T v3);

  /// Create Vector and initialize
  Vector (T v0, T v1, T v2, T v3, T v4, T v5, T v6, T v7);

  /// Construct Vector from any Vector of the same dimension.
  template<class T2>
  Vector (Vector<T2,D> const &v);

  /// @}

  /// @name Operators
  /// @{

  /// Returns component of Vector
  T operator[] (size_t n) const;

  /// Returns reference to vector component
  T& operator[] (size_t n);

  /// Add a vector to this one
  TVector& operator+= (const Vector<T,D> &v);

  /// Add a constant to this vector
  TVector& operator+= (const T &val);

  /// Subtract Vector from this one
  TVector& operator-= (const Vector<T,D> &v);

  /// Subtract a constant from this vector
  TVector& operator-= (const T &val);

  /// Multiply vector by constant
  TVector& operator*= (T v);

  /// Divide vector by constant
  TVector& operator/= (T v);

  /// Unary perator +
  TVector operator+ () const;
  /// Unary perator -
  TVector operator- () const;

  /// Operator assign
  TVector& operator= (const Vector<T,D> v)
  {
    for (int i=0; i<D; ++i) _d[i] = (T)v._d[i];
    return *this;
  }

  /// Add two vectors
  friend TVector operator+ (const TVector &v1, const Vector<T, D> &v2)
  {
    TVector retval;
    for (int i=0; i<D; ++i) retval._d[i] = v1._d[i] + (T)(v2._d[i]);
    return retval;
  }

  /// Subtract two vectors
  friend TVector operator- (const TVector &v1, const Vector<T, D> &v2)
  {
    TVector retval;
    for (int i=0; i<D; ++i) retval._d[i] = v1._d[i] - (T)(v2._d[i]);
    return retval;
  }

  /// Dot product of two vectors
  friend T operator* (const TVector &v1, const Vector<T, D> &v2)
  {
    return MetaLoops<D>::Dot (v1._d, (T*)v2._d);
    // T retval = v1._d[0] * (T)(v2._d[0]);
    // for (int i=1; i<D; ++i) retval += v1._d[i] * (T)(v2._d[i]);
    // return retval;
  }

  /// Cross product of two vectors (speciealized only for D = 3)
  friend TVector operator% (const TVector &v1, const Vector<T, D> &v2)
  {
    SAT_CASSERT (D == 3);
    return TVector (v1._d[1] * v2._d[2] - v1._d[2] * v2._d[1],
                    v1._d[2] * v2._d[0] - v1._d[0] * v2._d[2],
                    v1._d[0] * v2._d[1] - v1._d[1] * v2._d[0]);
  }

  /// Multiply vector by constant
  friend TVector operator* (const TVector &v1, T v2)
  {
    TVector retval;
    for (int i=0; i<D; ++i) retval._d[i] = v1._d[i] * (T)(v2);
    return retval;
  }

  /// Multiply vector by constant
  friend TVector operator* (T v2, const TVector &v1)
  {
    TVector retval;
    for (int i=0; i<D; ++i) retval._d[i] = v1._d[i] * (T)(v2);
    return retval;
  }

  /// Divide vector by constant
  friend TVector operator/ (const TVector &v1, T v2)
  {
    TVector retval;
    for (int i=0; i<D; ++i) retval._d[i] = v1._d[i] / (T)(v2);
    return retval;
  }

  /// Divide element-wise vector by vector
  friend TVector operator/ (const TVector &v1, const Vector<T, D> &v2)
  {
    TVector retval;
    for (int i=0; i<D; ++i) retval._d[i] = v1._d[i] / T(v2._d[i]);
    return retval;
  }

  /// Compare two vectors
  friend bool operator== (const TVector &v1, const Vector<T, D> &v2)
  {
    bool retval = v1._d[0] == (T)(v2._d[0]);
    for (int i=1; i<D; ++i) retval = retval && (v1._d[i] == T(v2._d[i]));
    return retval;
  }

  /// Compare two vectors
  friend bool operator!= (const TVector &v1, const Vector<T, D> &v2)
  {
    bool retval = v1._d[0] != (T)(v2._d[0]);
    for (int i=1; i<D; ++i) retval = retval || (v1._d[i] != (T)(v2._d[i]));
    return retval;
  }

  /// Compare two vectors
  friend bool operator< (const TVector &v1, const Vector<T, D> &v2)
  {
    bool retval = v1._d[0] < (T)(v2._d[0]);
    for (int i=1; i<D; ++i) retval = retval && (v1._d[i] < (T)(v2._d[i]));
    return retval;
  }

  /// Compare two vectors
  friend bool operator> (const TVector &v1, const Vector<T, D> &v2)
  {
    bool retval = v1._d[0] > (T)(v2._d[0]);
    for (int i=1; i<D; ++i) retval = retval && (v1._d[i] > (T)(v2._d[i]));
    return retval;
  }

  /// Compare two vectors
  friend bool operator<= (const TVector &v1, const Vector<T, D> &v2)
  {
    bool retval = v1._d[0] <= (T)(v2._d[0]);
    for (int i=1; i<D; ++i) retval = retval && (v1._d[i] <= (T)(v2._d[i]));
    return retval;
  }

  /// Compare two vectors
  friend bool operator>= (const TVector &v1, const Vector<T, D> &v2)
  {
    bool retval = v1._d[0] >= (T)(v2._d[0]);
    for (int i=1; i<D; ++i) retval = retval && (v1._d[i] >= (T)(v2._d[i]));
    return retval;
  }

  /// Project right vector into the left one
  friend TVector operator<< (const TVector &v1, const Vector<T, D> &v2)
  {
    return v1*(MetaLoops<D>::Dot (v1._d, (T*)v2._d))/v1.Norm2 ();
  }

  /// Project left vector into the right one
  friend TVector operator>> (const TVector &v1, const Vector<T, D> &v2)
  {
    return v2*(MetaLoops<D>::Dot (v1._d, (T*)v2._d))/v2.Norm2 ();
  }

  /// @}

  /// Set the Vector to specified values
  void Set (T v0);
  void Set (T v0, T v1);
  void Set (T v0, T v1, T v2);
  void Set (T v0, T v1, T v2, T v3);
  template <class T2>
  void Set (const Vector<T2,D> &v);

  /// Return raw data pointer
  T* GetData ()
  { return _d; }

  /// Return text represenattion of the vector (i.e. "1,2,3")
  String Description () const;

  /// Synonym for Description() function. Return text represenattion of the
  /// vector (i.e. "1,2,3")
  String Desc () const
  { return Description (); }

  /// Set the magnitude of the Vector to 1
  void Normalize (const T mag = T(1));

  /// Multiply all values
  T Mult () const;

  /// Sum all values
  T Sum () const;

  /// Return magnitude of the Vector
  T Norm () const;

  /// Return squared magnitude of the Vector
  T Norm2 () const;

  /// Return magnitude of the Vector
  T Abs () const
  { return Norm (); }

  /// Return squared magnitude of the Vector
  T SquaredNorm () const;

  /// Return unit vector of this vector. If you want to change this vector \see
  /// Normalize
  TVector Unit () const;

  /// Is the size less then @p eps?
  bool IsZero (float eps = SMALL_EPS) const;

  /// Distance of two vectors squared
  T SquaredDistance (const TVector &v) const;

  /// Distance of two vectors squared (synonym for SquaredDistance() )
  T Distance2 (const TVector &v) const;

  /// Distance between two vectors
  T Distance (const TVector &v) const;

  friend std::ostream& operator<< (std::ostream &os, const TVector &v)
  {
    os << v._d[0];
    for (int i=1; i<D; ++i) os << "," << v._d[i];
    return os;
  }

  friend MpiOStream<T>& operator<< (MpiOStream<T> &os, const TVector &v)
  { for (int i=0; i<D; ++i) os << v._d[i]; return os; }

  friend MpiIStream<T>& operator>> (MpiIStream<T> &is, const TVector &v)
  { for (int i=0; i<D; ++i) is >> v._d[i]; return is; }

public:
  /// Vector components
  T _d[D];
};

/// @}

#include "vector.cpp"

#endif /* __SAT_VECTOR_H__ */
