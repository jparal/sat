/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   momfirst.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::MomLast ()
{
  _dn  = T(0);
  _dna = T(0);
  _U   = T(0);
  _Ua  = T(0);

  ScaField dnsa;
  dnsa.Initialize (_meshu, _layou);
  VecField usa;
  usa.Initialize (_meshu, _layou);

  T dn;
  FldVector blk;
  for (int i=0; i<_specie.GetSize (); ++i)
  {
    TSpecie *sp = _specie.Get (i);

    CalcMom (sp, dnsa, usa);

    T dq = sp->ChargePerPcle ();
    T dm = sp->MassPerPcle ();

    DomainIterator<D> it;
    _dn.GetDomainIterator (it, false);

    do
    {
      dn = dnsa(it);
      blk = usa(it);

      _dna(it) += dq * dn;
      _Ua (it) += dq * blk;
      _dn (it) += dm * dn;
      _U  (it) += dm * blk;
    }
    while (it.Next());
  }

  MomBC (_dn, _U);
  MomBC (_dna, _Ua);
  MomNorm (_dn, _U);
}
