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

  T ni, dth = (T)0.5 * _time.Dt ();
  FldVector ui, uf, bi, ei;

  Domain<D> dom;
  _dn.GetDomain (dom);
  DomainIterator<D> itu (dom);
  _B.GetDomain (dom);
  DomainIterator<D> itb (dom);
  _E.GetDomainAll (dom);
  dom.HiAdd (-1);
  DomainIterator<D> ite (dom);

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

  // if (_momsmooth && (_time.Iter() % _momsmooth == 0))
  // {
  //   /// @TODO Why smoothing when I did not advance it?
  //   // Smooth (_dn, false);
  //   Smooth (_U, false);
  // }
}
