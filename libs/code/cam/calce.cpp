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
  FldVector bc, uc, uxb, curlb, curlbxb, gradpe, tmp;
  while (ite.HasNext ())
  {
    // TODO: compute dnc and uc is quite a waste of time ... especially when we
    // advance field since we can compute this values (dnc, uc) only once
    // instead of nsub*2 times
    CartStencil::Average (dn,  itu, dnc);
    CartStencil::Average (blk, itu, uc);
    CartStencil::Average (mf,  itb, bc);

    if (enpe)
      CartStencil::Grad (_pe, itu, gradpe);

    CartStencil::Curl (mf, itb, curlb);

    for (int i=0; i<D; ++i) pos[i] = (itb.GetLoc ())[i];
    resist = Resist (pos);

    if (dnc < _dnmin)
    {
      _E(ite.GetLoc ()) = resist * curlb;
    }
    else
    {
      uxb = uc % bc;
      curlbxb = curlb % bc;
      dnc = 1. / dnc;

      tmp = curlbxb;
      tmp -= uxb;
      if (enpe)
	tmp -= gradpe;

      _E(ite.GetLoc ()) = dnc * tmp + curlb * resist;
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
