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
  for (int i=0; i<D; ++i)
  {
    if (_layop.IsOpen (i) && _layop.GetDecomp().IsLeftBnd (i))
    {
      dn.GetDomainAll (dom);
      dom[i] = Range (0, 1);
      dn.Set (dom, 1.);

      blk.GetDomainAll (dom);
      dom[i] = Range (0, 1);
      blk.Set (dom, _v0);
    }

    if (_layop.IsOpen (i) && _layop.GetDecomp().IsRightBnd (i))
    {
      dn.GetDomainAll (dom);
      dom[i] = Range (dn.Size(i)-2, dn.Size(i)-1);
      dn.Set (dom, 1.);

      blk.GetDomainAll (dom);
      dom[i] = Range (blk.Size(i)-2, blk.Size(i)-1);
      blk.Set (dom, _v0);
    }
  }

  static_cast<B*>(this)->MomBCAdd (dn, blk);
}
