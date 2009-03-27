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

/** @addtogroup math_misc
 *  @{
 */

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
 */
template <class T, int D = 3>
class Vector
{
public:
  typedef Vector<T, D> TVector;

  //@{ \brief Constructors

  /// Create an \b uninitialized vector.
  Vector () {}
  /// Create Vector where all components are initialized to one number.
  template <class T2>
  Vector (T2 v);
  /// Create Vector and initialize
  template <class T2>
  Vector (T2 v0, T2 v1);
  /// Create Vector and initialize
  template <class T2>
  Vector (T2 v0, T2 v1, T2 v2);
  /// Create Vector and initialize
  template <class T2>
  Vector (T2 v0, T2 v1, T2 v2, T2 v3);
  /// Create Vector and initialize
  template <class T2>
  Vector (T2 v0, T2 v1, T2 v2, T2 v3, T2 v4, T2 v5, T2 v6, T2 v7);

  /// Construct Vector from any Vector of the same dimension.
  template <class T2>
  Vector (Vector<T2,D> const &v);

  //@}

  //@{ @brief Operators

  /// Returns component of Vector
  T operator[] (size_t n) const;

  /// Returns reference to vector component
  T& operator[] (size_t n);

  /// Add a vector to this one
  template <class T2>
  TVector& operator+= (const Vector<T2,D> &v);

  /// Add a constant to this vector
  template <class T2>
  TVector& operator+= (const T2 &val);

  /// Subtract Vector from this one
  template <class T2>
  TVector& operator-= (const Vector<T2,D> &v);

  /// Subtract a constant from this vector
  template <class T2>
  TVector& operator-= (const T2 &val);

  /// Multiply vector by constant
  template <class T2>
  TVector& operator*= (T2 v);

  /// Divide vector by constant
  template <class T2>
  TVector& operator/= (T2 v);

  /// Unary perator +
  TVector operator+ () const;
  /// Unary perator -
  TVector operator- () const;

  /// Operator assign
  template <class T2>
  TVector& operator= (const Vector<T2,D> v)
  {
    for (int i=0; i<D; ++i) _d[i] = (T)v._d[i];
    return *this;
  }

  /// Add two vectors
  template <class T2>
  friend TVector operator+ (const TVector &v1, const Vector<T2, D> &v2)
  {
    TVector retval;
    for (int i=0; i<D; ++i) retval._d[i] = v1._d[i] + (T)(v2._d[i]);
    return retval;
  }

  /// Subtract two vectors
  template <class T2>
  friend TVector operator- (const TVector &v1, const Vector<T2, D> &v2)
  {
    TVector retval;
    for (int i=0; i<D; ++i) retval._d[i] = v1._d[i] - (T)(v2._d[i]);
    return retval;
  }

  /// Dot product of two vectors
  template <class T2>
  friend T operator* (const TVector &v1, const Vector<T2, D> &v2)
  {
    return MetaLoops<D>::Dot (v1._d, (T*)v2._d);
    // T retval = v1._d[0] * (T)(v2._d[0]);
    // for (int i=1; i<D; ++i) retval += v1._d[i] * (T)(v2._d[i]);
    // return retval;
  }

  /// Cross product of two vectors (speciealized only for D = 3)
  template <class T2>
  friend TVector operator% (const TVector &v1, const Vector<T2, D> &v2)
  {
    SAT_CASSERT (D == 3);
    return TVector (v1._d[1] * v2._d[2] - v1._d[2] * v2._d[1],
                    v1._d[2] * v2._d[0] - v1._d[0] * v2._d[2],
                    v1._d[0] * v2._d[1] - v1._d[1] * v2._d[0]);
  }

  /// Multiply vector by constant
  template <class T2>
  friend TVector operator* (const TVector &v1, T2 v2)
  {
    TVector retval;
    for (int i=0; i<D; ++i) retval._d[i] = v1._d[i] * (T)(v2);
    return retval;
  }

  /// Multiply vector by constant
  template <class T2>
  friend TVector operator* (T2 v2, const TVector &v1)
  {
    TVector retval;
    for (int i=0; i<D; ++i) retval._d[i] = v1._d[i] * (T)(v2);
    return retval;
  }

  /// Divide vector by constant
  template <class T2>
  friend TVector operator/ (const TVector &v1, T2 v2)
  {
    TVector retval;
    for (int i=0; i<D; ++i) retval._d[i] = v1._d[i] / (T)(v2);
    return retval;
  }

  /// Compare two vecors
  template <class T2>
  friend bool operator== (const TVector &v1, const Vector<T2, D> &v2)
  {
    bool retval = v1._d[0] == (T)(v2._d[0]);
    for (int i=1; i<D; ++i) retval = retval && (v1._d[i] == (T)(v2._d[i]));
    return retval;
  }

  /// Compare two vecors
  template <class T2>
  friend bool operator!= (const TVector &v1, const Vector<T2, D> &v2)
  {
    bool retval = v1._d[0] != (T)(v2._d[0]);
    for (int i=1; i<D; ++i) retval = retval || (v1._d[i] != (T)(v2._d[i]));
    return retval;
  }

  /// Compare two vecors
  template <class T2>
  friend bool operator< (const TVector &v1, const Vector<T2, D> &v2)
  {
    bool retval = v1._d[0] < (T)(v2._d[0]);
    for (int i=1; i<D; ++i) retval = retval && (v1._d[i] < (T)(v2._d[i]));
    return retval;
  }

  /// Compare two vecors
  template <class T2>
  friend bool operator> (const TVector &v1, const Vector<T2, D> &v2)
  {
    bool retval = v1._d[0] > (T)(v2._d[0]);
    for (int i=1; i<D; ++i) retval = retval && (v1._d[i] > (T)(v2._d[i]));
    return retval;
  }

  /// Compare two vecors
  template <class T2>
  friend bool operator<= (const TVector &v1, const Vector<T2, D> &v2)
  {
    bool retval = v1._d[0] <= (T)(v2._d[0]);
    for (int i=1; i<D; ++i) retval = retval && (v1._d[i] <= (T)(v2._d[i]));
    return retval;
  }

  /// Compare two vecors
  template <class T2>
  friend bool operator>= (const TVector &v1, const Vector<T2, D> &v2)
  {
    bool retval = v1._d[0] >= (T)(v2._d[0]);
    for (int i=1; i<D; ++i) retval = retval && (v1._d[i] >= (T)(v2._d[i]));
    return retval;
  }

  /// Project right vector into the left one
  template <class T2>
  friend TVector operator<< (const TVector &v1, const Vector<T2, D> &v2)
  {
    return v1*(MetaLoops<D>::Dot (v1._d, (T*)v2._d))/v1.Norm2 ();
  }

  /// Project left vector into the right one
  template <class T2>
  friend TVector operator>> (const TVector &v1, const Vector<T2, D> &v2)
  {
    return v2*(MetaLoops<D>::Dot (v1._d, (T*)v2._d))/v2.Norm2 ();
  }

  //@}

  /// Set the Vector to specified values
  template <class T2>
  void Set (T2 v0);
  template <class T2>
  void Set (T2 v0, T2 v1);
  template <class T2>
  void Set (T2 v0, T2 v1, T2 v2);
  template <class T2>
  void Set (T2 v0, T2 v1, T2 v2, T2 v3);
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
  void Normalize ();

  /// Multiply all values
  T Mult () const;

  /// Sum all values
  T Sum () const;

  /// Return magnitude of the Vector
  T Norm () const;

  /// Return squared magnitude of the Vector
  T Norm2 () const;

  /// Return squared magnitude of the Vector
  T SquaredNorm () const;

  /// Return unit vector of this vector. If you want to change this vector \see
  /// Normalize
  TVector Unit () const;

  bool IsZero (float eps = SMALL_EPS) const;

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
  ///Vector components
  T _d[D];
};

/** @} */

#include "vector.cpp"

#endif /* __SAT_VECTOR_H__ */
