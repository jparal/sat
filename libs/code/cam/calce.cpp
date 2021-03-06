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
void CAMCode<B,T,D>::CalcE (const VecField &b, const VecField &u,
			    const ScaField &dn)
{
  DomainIterator<D> itb, itu, ite;
  b.GetDomainIterator (itb, true);
  u.GetDomainIterator (itu, true);
  _E.GetDomainIterator (ite, false);

  CalcPe (dn);

  T dnc, resist, mask;
  PosVector pos;
  FldVector bc, uc, uxb, cb, gpe, elapl, enew, efld, efsrc;
  efsrc = T(0);

  do
  {
    if_pf (static_cast<B*>(this)->EcalcAdd (ite))
      continue;

    mask = MaskBC (ite);
    if (_time.Iter () > 0)
      mask *= static_cast<B*>(this)->EmaskAdd (ite);

    // TODO: compute dnc and uc is quite a waste of time ... especially when we
    // advance field since we can compute this values (dnc, uc) only once
    // instead of nsub*2 times
    CartStencil::Average (dn, itu, dnc);
    CartStencil::Average (u, itu, uc);
    CartStencil::Average (b,  itb, bc);
    CartStencil::Curl (b, itb, cb);
    // CartStencil::Lapl (_E, ite, elapl);
    // elapl *= _viscos * mask;
    resist = Resist (ite);

    CartStencil::Grad (_pe, itu, gpe);

    if (dnc < _dnmin)
    {
      enew = resist * cb;
      //      enew += elapl;
    }
    else
    {
      uxb = uc % bc;

      enew = cb % bc;
      enew -= uxb;
      enew -= gpe;
      enew /= dnc;

      cb *= resist;
      enew += cb;
      //      enew += elapl;
    }

    efld = _E(ite);
    efld += (enew - efld) * mask;

    if (static_cast<B*>(this)->EcalcSrc (ite, efsrc))
      efld += efsrc;

    _E(ite) = efld;

    static_cast<B*>(this)->EcalcBC (ite);
  }
  while (itb.Next () && itu.Next() && ite.Next());

  // We better apply BC so smoothing has values from its neighbors
  EfieldBC ();

  if (_esmooth && (_time.Iter() % _esmooth == 0))
    Smooth (_E);

  EfieldBC ();
}
