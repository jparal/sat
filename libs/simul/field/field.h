/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   field.h
 * @brief  Field storage class
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-03-03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_FIELD_H__
#define __SAT_FIELD_H__

#include "satmath.h"
#include "simul/misc/domain.h"
#include "mesh.h"
#include "layout.h"

/// @addtogroup simul_field
/// @{

/**
 * @brief Field storage class
 *
 * Implementation of data storage with templated on type and number of
 * dimensions.
 *
 * @revision{1.0}
 * @reventry{2008/03, @jparal}
 * @revmessg{Initial version}
 * @reventry{2008/06, @jparal}
 * @revmessg{Add a constructor with Vector}
 * @revmessg{Add sync function to synchronize boundary values across MPI
 *          patches using DomainIterator class}
 * @reventry{2008/07, @jparal}
 * @revmessg{Ooops. I totally forgot to define a copy constructor and thus when
 *          someone did copy of one Field into another it copied the pointer of
 *          _data instead of data itself.}
 * @reventry{2008/08, @jparal}
 * @revmessg{Sync function is more complex and support share/ghost cells
 *          introduced in Layout class during synchronization process.}
 * @reventry{2009/04, @jparal}
 * @revmessg{Add Initialized function which is synonym to Allocated}
 */
template<class T, int D>
class Field
{
public:
  /// @name Constructors/Destructor
  /// @{

  Field ();
  Field (int d0);
  Field (int d0, int d1);
  Field (int d0, int d1, int d2);
  Field (int d0, int d1, int d2, int d3);
  Field (int d0, int d1, int d2, int d3, int d4);
  Field (int d0, int d1, int d2, int d3, int d4, int d5);

  template<int VD>
  Field (const Vector<int,VD> &d);

  Field (const Mesh<D> &mesh, const Layout<D> &layout = Layout<D> ());

  Field (const Field<T,D> &orig);

  /// Destructor
  ~Field ();

  /// @}

  /// @name Allocate/Free
  /// @{

  void Initialize (int d0);
  void Initialize (int d0, int d1);
  void Initialize (int d0, int d1, int d2);
  void Initialize (int d0, int d1, int d2, int d3);
  void Initialize (int d0, int d1, int d2, int d3, int d4);
  void Initialize (int d0, int d1, int d2, int d3, int d4, int d5);

  template<int VD>
  void Initialize (const Vector<int,VD> &d);
  void Initialize (const Mesh<D> &mesh, const Layout<D> &layout = Layout<D> ());

  template<class T2>
  void Initialize (const Field<T2,D>& val);
  void Initialize (const Field<T,D>& val);

  /// Free allocated memory
  void Free ();

  /// For the names to be consistent, add synonym for Allocated
  bool Initialized () const
  { return Allocated (); }

  /// Are the data allocated?
  bool Allocated () const
  { return _data == NULL ? 0 : _tot * sizeof(T); }

  /// @}

  /// @name Index operators
  /// @{

  const T& operator() (int i0) const;
  const T& operator() (int i0, int i1) const;
  const T& operator() (int i0, int i1, int i2) const;
  const T& operator() (int i0, int i1, int i2, int i3) const;
  const T& operator() (int i0, int i1, int i2, int i3, int i4) const;
  const T& operator() (int i0, int i1, int i2, int i3, int i4, int i5) const;
  const T& operator() (const Vector<int,D> &ii) const;

  T& operator() (int i0);
  T& operator() (int i0, int i1);
  T& operator() (int i0, int i1, int i2);
  T& operator() (int i0, int i1, int i2, int i3);
  T& operator() (int i0, int i1, int i2, int i3, int i4);
  T& operator() (int i0, int i1, int i2, int i3, int i4, int i5);
  T& operator() (const Vector<int,D> &ii);

  /**
   * @brief Return values around the given index or position.
   *
   * @param loc location of the point of the interest.
   * @param adj returned values
   */
  template<class T2>
  void GetAdj (const Vector<T2,D> &loc, Vector<T,MetaPow<2,D>::Is> &adj) const;

  /**
   * @brief Add values around the given index or position to the values which
   *        are already stored in the field.
   *
   * @param loc location of the point of the interest.
   * @param adj values to add
   */
  template<class T2>
  void AddAdj (const Vector<T2,D> &loc, const Vector<T,MetaPow<2,D>::Is> &adj);

  /// @}

  /// @name Parallel support
  /// @{

  /**
   * @brief Synchronize ghost zones of Field class when Field is distributed
   *        over several nodes.
   * The entire synchronization process can be divided into three steps:
   * 1) Copy shared cells across the boundary into the ghost cells (note that
   *    #ghost cells >= #shared cells)
   * 2) Execute operation above the shared cell values (in the case of add,
   *    just add values from ghost zones to the outer values which are shared)
   * 3) Copy inner values which are not shared into ghost zones.
   *
   * @sa @ref fig_layout "Layout Figure"
   * @remarks Field must be initialized using Mesh and Layout.
   */
  void Sync ();

  /// @}

  /// @name Assign operators
  /// @{

  template<class T2>
  void operator= (const T2& val);

  template<class T2>
  void operator+= (const T2& val);

  template<class T2>
  void operator-= (const T2& val);

  template<class T2>
  void operator*= (const T2& val);

  template<class T2>
  void operator/= (const T2& val);

  template<class T2>
  void operator/= (const Field<T2,D>& val);

  template<class T2>
  void operator= (const Field<T2,D>& val);

  void operator= (const Field<T,D>& val);

  template<class T2>
  void operator+= (const Field<T2,D>& val);

  template<class T2>
  void Set (const Domain<D> &dom, const T2 &val);

  /// @}

  /// Return rank of the Field.
  int Rank () const { return D; }
  /// Return length in a specified dimension.
  int Size (int dim) const { return _len[dim]; }
  /// Return length in a specified dimension.
  int GetSize (int dim) const { return _len[dim]; }
  /// Return vector with length in each dimension.
  const Vector<int,D>& GetDims () const { return _len; }
  /// Return vector with length in each dimension.
  const Vector<int,D>& GetSize () const { return _len; }

  /// Return sum of all elements.
  T Sum ();
  /// Return maximal value (works only for types with defined comparison
  /// operator.
  T Max ();
  /// Return minimal value (works only for types with defined comparison
  /// operator.
  T Min ();
  /// Scale all values so that maximal value is equal to (T)1.
  void Scale (const T &scale = 1.);
  /// Return average value.
  T Average ();

  /// Return Domain including ghost zones.
  void GetDomainAll (Domain<D> &dom) const;
  /// Return Domain including ghost zones.
  Domain<D> GetDomainAll () const;
  /// Return Domain excluding ghost zones.
  void GetDomain (Domain<D> &dom) const;
  /// Return Domain excluding ghost zones.
  Domain<D> GetDomain () const;

  /// Return DomainIterator including ghost zones. If parameter omitLast is
  /// true then returned domain iterator excludes most right values from all
  /// dimensions.  This is necessary when calculating average.
  void GetDomainIteratorAll (DomainIterator<D> &iter, bool omitLast) const;
  /// Return DomainIterator excluding ghost zones. If parameter omitLast is
  /// true then returned domain iterator excludes most right values from all
  /// dimensions.  This is necessary when calculating average.
  void GetDomainIterator (DomainIterator<D> &iter, bool omitLast) const;

  /// Do we have grid information available?
  bool HaveGrid () const { return _havegrid; }
  /// Return Mesh object of this Field.
  const Mesh<D>& GetMesh () const { return _mesh; }
  /// Return Layout object of this Field.
  const Layout<D>& GetLayout () const { return _layout; }

  void Save (FILE *file)
  {
    size_t size = GetSize ().Mult ();
    fwrite (&size, sizeof(size), 1, file);
    fwrite (_data, sizeof (T), size, file);
  }

  void Load (FILE *file)
  {
    size_t size;
    fread (&size, sizeof(size), 1, file);
    fread (_data, sizeof(T), size, file);
  }

private:
  /// Allocate new memory (assume that _len is all set already
  void Alloc (int dim);
  /// Compute strides and _tot (assume that _len is all set already
  void UpdateStride ();

  void InitIterator (DomainIterator<D> &iter,
		     Domain<D> &dom, bool omitLast) const;

  template<class T2>
  void UpdateMeta (const Field<T2,D>& val);

  /// dim is a dimension; right is direction and shared is whether we are
  /// communicating ghost zones or shared values into the ghost zones
  void LocalSendRecv (int dim, bool right, bool shared);
  void Recv (int dim, bool right, bool shared);
  void Send (int dim, bool right, bool shared);

  void SyncValues (bool shared);

  void UpdateShared ();
  void UpdateSharedDir (int dim, bool right);

  T *_data;                     /**< Actual data */
  Vector<int,D> _len;           /**< Length of each dimension */
  int _tot;                     /**< Total number of elements */
  int _str[D];                  /**< Stride */

  bool _havegrid; ///< Have Mesh && Layout
  Mesh<D> _mesh;
  Layout<D> _layout;
};

// basic stuff
#include "field.cpp"
// operators
#include "idxop.cpp"
#include "assignop.cpp"
// misc
#include "privutil.cpp"
#include "syncfld.cpp"
#include "updateshare.cpp"

/// @}

#endif /* __SAT_FIELD_H__ */
