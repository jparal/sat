/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   mombc.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::MomBC (ScaField &dn, VecField &blk)
{
  Domain<D> dom;

  // Left boundary
  for (int i=0; i<D; ++i)
  {
    if (!_layop.IsOpen (i) || !_layop.GetDecomp().IsLeftBnd (i))
      continue;

    dn.GetDomainAll (dom);
    dom[i] = Range (0, 1);
    DnBC (dn, dom);

    blk.GetDomainAll (dom);
    dom[i] = Range (0, 1);
    BulkBC (blk, dom);
  }


  // Right boundary
  for (int i=0; i<D; ++i)
  {
    if (!_layop.IsOpen (i) || !_layop.GetDecomp().IsRightBnd (i))
      continue;

    dn.GetDomainAll (dom);
    dom[i] = Range (dn.Size(i)-2, dn.Size(i)-1);
    DnBC (dn, dom);

    blk.GetDomainAll (dom);
    dom[i] = Range (blk.Size(i)-2, blk.Size(i)-1);
    BulkBC (blk, dom);
  }

  static_cast<B*>(this)->MomBCAdd (dn, blk);
}

template<class B, class T, int D>
void CAMCode<B,T,D>::DnBC (ScaField &dn, Domain<D> &dom)
{
  PosVector xp;
  DomainIterator<D> it;
  dn.GetDomainIteratorAll (it, false);
  it.SetDomain (dom);

  do
  {
    xp = it.GetPosition ();
    T dntmp = 0;

    for (int i=0; i<_specie.GetSize (); ++i)
    {
      TSpecie *sp = _specie.Get (i);
      dntmp += static_cast<B*>(this)->DnBCAdd (sp, xp);
    }
    dn(it) = dntmp;
  }
  while (it.Next());
}

template<class B, class T, int D>
void CAMCode<B,T,D>::BulkBC (VecField &blk, Domain<D> &dom)
{
  PosVector xp;
  DomainIterator<D> it;
  blk.GetDomainIteratorAll (it, false);
  it.SetDomain (dom);

  do
  {
    xp = it.GetPosition ();
    VelVector blktmp = 0;

    for (int i=0; i<_specie.GetSize (); ++i)
    {
      TSpecie *sp = _specie.Get (i);
      blktmp += static_cast<B*>(this)->BulkBCAdd (sp, xp);
    }
    blk(it) = blktmp;
  }
  while (it.Next());
}
