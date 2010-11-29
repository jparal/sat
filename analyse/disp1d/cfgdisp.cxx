/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cfgdisp.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/08, @jparal}
 * @revmessg{Initial version}
 */

#include "cfgdisp.h"

double
ConfigDisp::GetKSample (int i) const
{
  SAT_ASSERT (0 <= i && i < KSamp ());
  double ds = (KMax() - KMin()) / double(KSamp()-1);
  return ds * double(i) + KMin ();
}

void
ConfigDisp::Initialize (int argc, char **argv)
{
  _cfgname = argv[0];
  _cfgname.ReplaceAll ("sat-", "");
  _cfgname += ".sin";

  if (argc > 1) _cfgname = argv[1];

  ConfigFile cfgfile;
  try
  {
    cfgfile.ReadFile (CfgName ());
    cfgfile.SetAutoConvert ();
  }
  catch (ParseException &ex)
  {
    SAT_ABBORT (CfgName() <<"(" << ex.GetLine() << "): Parsing error: " <<
		ex.GetError() << endl);
  }
  catch (FileIOException &ex)
  {
    SAT_ABBORT ("Parsing file: '"<< CfgName() <<"'");
  }

  ConfigEntry &cfg = cfgfile.GetEntry ("disp");

  cfg.GetValue ("prjname", _prjname);
  cfg.GetValue ("units", _units);
  cfg.GetValue ("rwpewce", _rwpewce);
  cfg.GetValue ("rmpme", _rmpme, M_PHYS_MP/M_PHYS_ME);
  _vac = -1.;
  if (cfg.Exists ("vac"))
    cfg.GetValue ("vac", _vac);
  // cfg.GetValue ("nterms", _nterms, IVector3(0));
  cfg.GetValue ("kvec", _kvec);
  cfg.GetValue ("ksamp", _ksamp);
  cfg.GetValue ("theta", _theta);
  cfg.GetValue ("tsamp", _tsamp);
  cfg.GetValue ("omega", _omega);
  cfg.GetValue ("gamma", _gamma);
  cfg.GetValue ("error", _error);

  cfg.GetValue ("nsp", _nsp);
  for (int sp=0; sp<_nsp; ++sp)
  {
    _mass.Push (cfgfile.GetEntry ("disp.mass")[sp]);
    _charge.Push (cfgfile.GetEntry ("disp.charge")[sp]);
    _rdn.Push (cfgfile.GetEntry ("disp.rdn")[sp]);
    _beta.Push (cfgfile.GetEntry ("disp.beta")[sp]);
    _ani.Push (cfgfile.GetEntry ("disp.ani")[sp]);
    _vpar.Push (cfgfile.GetEntry ("disp.v0par")[sp]);
    _vper.Push (cfgfile.GetEntry ("disp.v0per")[sp]);
  }

  // Health checks:

  double rhoc = 0.;
  for (int sp=0; sp<_nsp; ++sp)
    rhoc += _rdn[sp] * _charge[sp];

  SAT_ASSERT_MSG( Math::Abs( rhoc<M_MEPS ), "Plasma is not charge neutral.");
  SAT_ASSERT_MSG(_units == 0, "Wrong units.");
}

double
ConfigDisp::Mass (int sp) const
{
  if (_mass[sp] == 0)
    return double(1./Rmpme());
  else
    return double(_mass[sp]);
}

double
ConfigDisp::TotalMassDn () const
{
  double totmdn = 0.;
  for (int sp=1; sp<_nsp; ++sp)
    totmdn += MassDn (sp);
}

double
ConfigDisp::VthPar (int sp) const
{
  return Math::Sqrt (Beta(sp) / (2.* MassDn (sp)));
}

double
ConfigDisp::VthPer (int sp) const
{
  return Math::Sqrt (Ani(sp)) * VthPar (sp);
}

double
ConfigDisp::PlasmaFreq (int sp) const
{
  double sqr = Math::Sqrt (Density(sp) * Rmpme() / Mass(sp));
  return Rwpewce() * ChargeAbs(sp) * sqr;
}

double
ConfigDisp::CycloFreq (int sp) const
{
  return Charge(sp) / Mass(sp);
}

complex<double>
ConfigDisp::Zeta (int sp, int n, double k, complex<double> w) const
{
  complex<double> kuj = k * V0Par (sp);
  complex<double> nom = w + double(n) * CycloFreq(sp) - kuj;
  complex<double> den = M_SQRT2 * k * VthPar(sp);
  return nom/den;
}
