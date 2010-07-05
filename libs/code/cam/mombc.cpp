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
  dn.Sync ();
  blk.Sync ();

  for (int i=0; i<D; ++i)
  {
    if (_layop.IsOpen (i) && _layop.GetDecomp ().IsLeftBnd (i))
    {
      //      dn(1) *= 2.;
      dn(1) = 1.;
      dn(0) = dn(1);

      //      blk(1) *= 2.;
      blk(1) = _v0;
      blk(0) = blk(1);
    }

    if (_layop.IsOpen (i) && _layop.GetDecomp ().IsRightBnd (i))
    {
      //      dn(dn.Size(1)-2) *= 2.;
      dn(dn.Size(1)-2) = 1.;
      dn(dn.Size(1)-1) = dn(dn.Size(1)-2);

      //      blk(blk.Size(1)-2) *= 2.;
      blk(blk.Size(1)-2) = _v0;
      blk(blk.Size(1)-1) = blk(blk.Size(1)-2);
    }
  }

  static_cast<B*>(this)->MomBCAdd (dn, blk);
}
