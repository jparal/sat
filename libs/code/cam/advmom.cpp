/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   advmom.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/08, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::AdvMom ()
{
  CalcE (_B, _Ua, _dnf, true);

  T ni, dth = T(.5) * _time.Dt ();
  FldVector ui, uf, bi, ei;

  DomainIterator<D> itu, itb, ite;
  _dn.GetDomainIterator (itu, false);
  _B.GetDomainIterator (itb, false);
  _E.GetDomainIteratorAll (ite, true);

  do
  {
    ni = _dn(itu);
    ui = _U (itu);
    uf = _Uf(itu);
    bi = _B (itb);
    CartStencil::Average (_E, ite, ei);

    _U(itu) = uf + dth * (ni*ei + ui % bi);
  }
  while (itu.Next() && itb.Next() && ite.Next());
}
