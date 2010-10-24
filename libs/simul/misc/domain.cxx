/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   domain.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "domain.h"

template<int D>
int Domain<D>::Length () const
{
  int len = 1;
  for (int i=0; i<D; ++i) len *= _range[i].Length ();
  return len;
}

template<int D>
void DomainIterator<D>::Initialize (const Domain<D> &dom)
{
  Initialize ();

  for (int i=0; i<D; ++i)
    _range[i] = dom[i];

  Reset ();
}

template<int D>
void DomainIterator<D>::Initialize (const Domain<D> &dom,
				    const Vector<double,D> &origin)
{
  Initialize (dom);

  _origin = origin;
  _haveOrigin = true;
}

template<int D>
void DomainIterator<D>::Reset ()
{
  _idx = 0;
  _nidx = 1;

  for (int i=0; i<D; ++i)
  {
    _loc[i] = _range[i].Low ();
    _nidx *= _range[i].Length ();
  }
}

template<int D>
bool DomainIterator<D>::Next ()
{
  ++_idx;
  if_pt (_loc[0]++<_range[0].Hi ())
    return HasNext();

  for (int i=1; i<D; ++i)
  {
    _loc[i-1] = _range[i-1].Low ();
    if (_loc[i]++<_range[i].Hi())
      return HasNext();
  }
  return HasNext();
}

template class Domain<1>;
template class Domain<2>;
template class Domain<3>;
template class Domain<4>;
template class Domain<5>;
template class Domain<6>;

template class DomainIterator<1>;
template class DomainIterator<2>;
template class DomainIterator<3>;
template class DomainIterator<4>;
template class DomainIterator<5>;
template class DomainIterator<6>;
