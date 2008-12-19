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

  T dth = (T)0.5 * _time.Dt ();
  T ni;
  FldVector ui, uf, bi, ei;

  Domain<D> dom;
  _dn.GetDomain (dom);
  DomainIterator<D> itu (dom);
  _B.GetDomain (dom);
  DomainIterator<D> itb (dom);
  _E.GetDomainAll (dom);
  dom.HiAdd (-1);
  DomainIterator<D> ite (dom);
  while (itu.HasNext ())
  {
    ni = _dn(itu.GetLoc ());
    ui = _U (itu.GetLoc ());
    uf = _Uf(itu.GetLoc ());
    CartStencil::Average (_E, ite, ei);

    _U(itu.GetLoc ()) = uf + dth * (ni*ei + ui % bi);

    itu.Next ();
    itb.Next ();
    ite.Next ();
  }

  if (_momsmooth && (_time.Iter() % _momsmooth == 0))
  {
    Smooth (_dn);
    Smooth (_U);
  }
}
