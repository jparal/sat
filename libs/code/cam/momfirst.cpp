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
void CAMCode<B,T,D>::MomFirst ()
{
  _dn  = 0.;
  _dnf = 0.;
  _U   = FldVector (0.);
  _Uf  = FldVector (0.);

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
    T q2m = dq*dq/dm;

    Domain<D> dom;
    _dn.GetDomain (dom);
    DomainIterator<D> it (dom);
    while (it.HasNext ())
    {
      dn = dnsa(it.GetLoc ());
      blk = usa(it.GetLoc ());

      _dn (it.GetLoc ()) += q2m * dn;
      _U  (it.GetLoc ()) += q2m * blk;

      _dnf(it.GetLoc ()) += dq * dn;
      _Uf (it.GetLoc ()) += dq * blk;

      it.Next ();
    }
  }

  MomBC (_dn, _U);
  MomBC (_dnf, _Uf);

  if (_momsmooth && (_time.Iter() % _momsmooth == 0))
    Smooth (_dnf);
}
