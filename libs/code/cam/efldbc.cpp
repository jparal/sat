/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   efldbc.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"

template<class B, class T, int D>
void CAMCode<B,T,D>::EfieldBC ()
{
  Domain<D> dom;
  DomainIterator<D> it;

  _E.Sync ();

  for (int i=0; i<D; ++i)
  {
    if (!_layop.IsOpen (i) || !_layop.GetDecomp ().IsLeftBnd (i))
      continue;

    _E.GetDomainAll( dom );
    _E.GetDomainIteratorAll(it, false);
    dom[i] = Range( 0, 0 );
    it.SetDomain(dom);

    do
    {
      _E(it) = static_cast<B*>(this)->EcalcBCAdd(it);
    } while(it.Next());

  }

  for (int i=0; i<D; ++i)
  {
    if (!_layop.IsOpen (i) || !_layop.GetDecomp ().IsRightBnd (i))
      continue;

    _E.GetDomainAll( dom );
    _E.GetDomainIteratorAll(it, false);

    dom[i] = Range( _E.Size(i)-1, _E.Size(i)-1 );
    it.SetDomain(dom);

    do
    {
      _E(it) = static_cast<B*>(this)->EcalcBCAdd(it);
    } while(it.Next());
  }

  static_cast<B*>(this)->EfieldAdd ();
}
