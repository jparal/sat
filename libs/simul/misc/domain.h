/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   domain.h
 * @brief  Domain of Loc<D> specified by Range and able to iterate over
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_DOMAIN_H__
#define __SAT_DOMAIN_H__

#include "base/sys/predict.h"
#include "range.h"
#include "loc.h"

/// @addtogroup simul_misc
/// @{

template<int D>
class Domain
{
public:
  Range& operator[] (int idim)
  { return _range[idim]; }

  const Range& operator[] (int idim) const
  { return _range[idim]; }

  void HiAdd (int add)
  { for (int i=0; i<D; ++i) _range[i].Hi () += add; }

  void LoAdd (int add)
  { for (int i=0; i<D; ++i) _range[i].Hi () += add; }

  const Range& Get (int idim) const
  { return _range[idim]; }

  int Size () const
  { return Length (); }

  int Length () const;

  void Copy (const Domain<D> &from)
  {
    for (int i=0; i<D; ++i)
      _range[i] = from._range[i];
  }

  Domain () {}
  Domain (const Domain<D> &from)
  { Copy (from); }

  void operator= (const Domain<D> &from)
  { Copy (from); }

private:
  Range _range[D];
};

/**
 * @brief Domain of Loc<D> specified by Range and able to iterate over
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
template<int D>
class DomainIterator
{
public:
  /// Constructor
  DomainIterator ()
  { Initialize (); }

  DomainIterator (const Domain<D> &dom)
  { Initialize (dom); }

  DomainIterator (const Domain<D> &dom, const Vector<double,D> &origin,
		  const Vector<double,D> &dx)

  { Initialize (dom, origin, dx); }

  void Initialize ()
  { _haveOrigin = false; }

  void Initialize (const Domain<D> &dom);

  /// Origin is a position of location [0,0] in the cell units with respect to
  /// entire simulation domain (including other MPI processes)
  void Initialize (const Domain<D> &dom, const Vector<double,D> &origin,
		   const Vector<double,D> &dx);

  void Reset ();

  int Length () const
  { return _nidx; }

  const Loc<D>& GetLoc () const
  { return _loc; }

  int GetLoc (int dim) const
  { return _loc[dim]; }

  Vector<double,D> GetPosition () const
  {
    SAT_ASSERT (_haveOrigin);
    Vector<double,D> pos = _origin;
    pos += _loc;
    pos *= _dx;
    return pos;
  }

  double GetPosition (int dim) const
  {
    SAT_ASSERT (_haveOrigin);
    return (_origin[dim] + double(_loc[dim])) * _dx[dim];
  }

  bool HasNext ()
  { return _idx<_nidx; }

  /// Next element.
  bool Next ();

  /// operator Loc<D>
  operator Loc<D> () const
  { return _loc; }

  /// operator const Loc<D>&
  operator const Loc<D>& () const
  { return _loc; }

private:
  bool _haveOrigin;
  /// origin of location [0,0,0] in cell units.  This number can be non integer
  /// because of the mesh alignment
  Vector<double,D> _origin;
  Vector<double,D> _dx;
  Loc<D> _loc;
  int _idx;
  int _nidx;
  Range _range[D];
};

/// @}

#endif /* __SAT_DOMAIN_H__ */
