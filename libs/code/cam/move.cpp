/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   move.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::Move ()
{
  CalcE (_B, _U, _dnf, true);

  _dn  = 0.; _U  = 0.;
  _dna = 0.; _Ua = 0.;
  _dnf = 0.; _Uf = 0.;

  ScaField dnsa; dnsa.Initialize (_meshu, _layou);
  ScaField dnsb; dnsb.Initialize (_meshu, _layou);
  VecField usa; usa.Initialize (_meshu, _layou);
  VecField usb; usb.Initialize (_meshu, _layou);

  /****************************/
  /* Perform for all species: */
  /****************************/
  for (int i=0; i<_specie.GetSize (); ++i)
  {
    TSpecie *sp = _specie.Get (i);
    T sq = sp->ChargePerPcle ();
    T sm = sp->MassPerPcle ();
    T qom = sq / sm;

    MoveSp (sp, dnsa, usa, dnsb, usb);
    Inject (sp, dnsb, usb);
    PcleSync (sp, dnsb, usb);

    dnsa *= sq;
    usa  *= sq;

    dnsb *= sq;
    usb  *= sq;

    _dn += dnsa;
    _U  += usa;

    _dna += dnsb;
    _Ua  += usb;

    dnsb *= qom;
    usb  *= qom;

    _dnf += dnsb;
    _Uf  += usb;
  }

  _dna += _dnf; _dna *= 0.5;
  _Ua += _Uf; _Ua *= 0.5;

  /***************************************************/
  /* (a) We need to adjust moments at the borders:   */
  /*     1) between nodes - make just sum over nodes */
  /*     2) at boundaries - interpolate              */
  /* (b) Smooth if necessary                         */
  /***************************************************/
  MomBC (_dn, _U);
  MomBC (_dnf, _Uf);
  MomBC (_dna, _Ua);

  if (_momsmooth && (_time.Iter() % _momsmooth == 0))
  {
    Smooth (_dna, false);
    Smooth (_dnf, false);
    Smooth (_Ua, false);
  }
}
