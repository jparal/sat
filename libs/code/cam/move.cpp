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
  CalcE (_B, _U, _dnf);

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
    size_t npcle;

    MoveSp (sp, dnsa, usa, dnsb, usb);
    Inject (sp, dnsb, usb);

    PcleSync (sp, dnsb, usb);

    dnsa.Sync ();
    dnsb.Sync ();

    usa.Sync ();
    usb.Sync ();

    if (_momsmooth && (_time.Iter() % _momsmooth == 0))
    {
      Smooth (dnsa);
      Smooth (dnsb);

      Smooth (usa);
      Smooth (usb);
    }

    dnsa *= sq;
    dnsb *= sq;

    usa  *= sq;
    usb  *= sq;

    _dna += dnsa;
    _dnf += dnsb;

    _Ua  += usa;
    _Uf  += usb;

    dnsb *= qom;
    usb  *= qom;

    _dn += dnsb;
    _U  += usb;
  }

  _dna += _dnf;
  _dna *= 0.5;
  _Ua += _Uf;
  _Ua *= 0.5;

  /***************************************************/
  /* (a) We need to adjust moments at the borders:   */
  /*     1) between nodes - make just sum over nodes */
  /*     2) at boundaries - interpolate              */
  /* (b) Smooth if necessary                         */
  /***************************************************/
  MomBC (_dn, _U);
  MomBC (_dnf, _Uf);
  MomBC (_dna, _Ua);
}
