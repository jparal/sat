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

  void Initialize ()
  {}

  void Initialize (const Domain<D> &dom)
  { for (int i=0; i<D; ++i) _range[i] = dom[i]; Reset (); }

  void Reset ()
  {
    _idx = 0;
    _nidx = 1;
    for (int i=0; i<D; ++i)
    {
      _loc[i] = _range[i].Low ();
      _nidx *= _range[i].Length ();
    }
  }

  int Length () const
  { return _nidx; }

  const Loc<D>& GetLoc () const
  { return _loc; }

  int GetLoc (int dim) const
  { return _loc[dim]; }

  bool HasNext ()
  { return _idx<_nidx; }

  void Next ()
  {
    ++_idx;
    if_pt (_loc[0]++<_range[0].Hi ())
      return;

    for (int i=1; i<D; ++i)
    {
      _loc[i-1] = _range[i-1].Low ();
      if (_loc[i]++<_range[i].Hi ())
	return;
    }
  }

private:
  Loc<D> _loc;
  int _idx;
  int _nidx;
  Range _range[D];
};

/// @}

#endif /* __SAT_DOMAIN_H__ */
