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
			    const ScaField &dn, bool enpe)
{
  Domain<D> dom;

  DomainIterator<D> itb, itu, ite;
  b.GetDomainIterator (itb, true);
  u.GetDomainIterator (itu, true);
  _E.GetDomainIterator (ite, false);

  if (enpe)
    CalcPe (dn);

  T dnc, resist, emask;
  PosVector pos;
  FldVector bc, uc, uxb, cb, gpe, elapl, enew, efld;
  do
  {
    if_pf (static_cast<B*>(this)->EcalcAdd (ite))
      continue;

    if (_time.Iter () > 0)
      emask = static_cast<B*>(this)->EmaskAdd (ite);
    else
      emask = T(1);

    // TODO: compute dnc and uc is quite a waste of time ... especially when we
    // advance field since we can compute this values (dnc, uc) only once
    // instead of nsub*2 times
    CartStencil::Average (dn, itu, dnc);
    CartStencil::Average (u, itu, uc);
    CartStencil::Average (b,  itb, bc);
    CartStencil::Curl (b, itb, cb);
    CartStencil::Lapl (_E, ite, elapl);
    elapl *= _viscos * emask;
    resist = Resist (ite);

    if (enpe)
      CartStencil::Grad (_pe, itu, gpe);

    if (dnc < _dnmin)
    {
      enew = resist * cb;
      enew += elapl;
    }
    else
    {
      uxb = uc % bc;

      enew = cb % bc;
      enew -= uxb;
      if (enpe) enew -= gpe;
      enew /= dnc;

      cb *= resist;
      enew += cb;
      enew += elapl;
    }

    efld = _E(ite);
    efld += (enew - efld) * emask;

    _E(ite) = efld;
  }
  while (itb.Next () && itu.Next() && ite.Next());

  // We better apply BC so smoothing has values from its neighbors
  EfieldBC ();

  if (_esmooth && (_time.Iter() % _esmooth == 0))
    Smooth (_E);

  EfieldBC ();
}
