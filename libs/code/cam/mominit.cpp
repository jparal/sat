/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   mominit.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/08, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::MomInit ()
{
  _dn  = 0.;
  _dna = 0.;
  _U   = FldVector (0.);
  _Ua  = FldVector (0.);

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

    Domain<D> dom;
    _dn.GetDomain (dom);
    DomainIterator<D> it (dom);
    while (it.HasNext ())
    {
      dn = dnsa(it);
      blk = usa(it);

      _dn (it) += dq * dn;
      _U  (it) += dq * blk;
      _dna(it) += dm * dn;
      _Ua (it) += dm * blk;

      it.Next ();
    }
  }

  MomBC (_dn, _U);
  MomBC (_dna, _Ua);

  if (_momsmooth && (_time.Iter() % _momsmooth == 0))
  {
    Smooth (_dn);
    Smooth (_dna);
    Smooth (_U);
    Smooth (_Ua);
  }

  MomNorm (_dn, _U);
}
