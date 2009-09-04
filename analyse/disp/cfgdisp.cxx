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

double ConfigDisp::GetKSample (int i) const
{
  SAT_ASSERT (0 <= i && i <= KSamp ());
  double ds = (KMax() - KMin()) / double(KSamp());
  return ds * double(i) + KMin ();
}

void ConfigDisp::Initialize (int argc, char **argv)
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
  cfg.GetValue ("rmemp", _rmemp, M_PHYS_ME/M_PHYS_MP);
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
}

double ConfigDisp::VthPar (int sp) const
{
  if (sp == 0)
    return Math::Sqrt (Beta(sp) / (2.));
  else
    return Math::Sqrt (Beta(sp) / (2.* RelDn(sp) * Mass(sp)));
}

double ConfigDisp::VthPer (int sp) const
{
  double rvth = Math::Sqrt (Ani (sp));
  return rvth * VthPar (sp);
}

double ConfigDisp::PlasmaFreq (int sp) const
{
  if (sp == 0)
    return Rwpewce() /_rmemp;
  else
    return 1.;
}

double ConfigDisp::CycloFreq (int sp) const
{
  if (sp == 0)
    return 1./_rmemp;
  else
    return double(Charge(sp)) / double(Mass(sp));
}
