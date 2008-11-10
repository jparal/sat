/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   calce.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::CalcE (const VecField &mf, const VecField &blk,
			    const ScaField &dn, bool enpe)
{
  Domain<D> dom;

  mf.GetDomain (dom);  dom.HiAdd (-1); DomainIterator<D> itb (dom);
  blk.GetDomain (dom); dom.HiAdd (-1); DomainIterator<D> itu (dom);
  _E.GetDomain (dom);  DomainIterator<D> ite (dom);

  SAT_DBG_ASSERT (ite.Length () == itb.Length ());
  SAT_DBG_ASSERT (ite.Length () == itu.Length ());

  if (enpe)
    CalcPe (dn);

  T dnc, resist;
  PosVector pos;
  FldVector bc, uc, uxb, cb, cbxb, gpe, ef;
  while (ite.HasNext ())
  {
    // TODO: compute dnc and uc is quite a waste of time ... especially when we
    // advance field since we can compute this values (dnc, uc) only once
    // instead of nsub*2 times
    CartStencil::Average (dn,  itu, dnc);
    CartStencil::Average (blk, itu, uc);
    CartStencil::Average (mf,  itb, bc);
    CartStencil::Curl (mf, itb, cb);
    if (enpe) CartStencil::Grad (_pe, itu, gpe);

    for (int i=0; i<D; ++i) pos[i] = (itb.GetLoc ())[i];
    resist = Resist (pos);

    if (dnc < _dnmin)
    {
      _E(ite.GetLoc ()) = resist * cb;
    }
    else
    {
      uxb = uc % bc;
      cbxb = cb % bc;
      dnc = 1. / dnc;

      ef = cbxb;
      ef -= uxb;
      if (enpe)
      	ef -= gpe;

      ef *= dnc;
      cb *= resist;
      ef += cb;
      _E(ite.GetLoc ()) = ef;
    }

    itb.Next ();
    itu.Next ();
    ite.Next ();
  }

  // We better apply BC so smoothing has values from its neighbours
  EfieldBC ();

  if (_esmooth)
    Smooth (_E);

  EfieldBC ();
}
