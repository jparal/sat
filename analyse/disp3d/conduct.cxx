/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   conduct.cxx
 * @brief  Conductivity tensor elements.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/12, @jparal}
 * @revmessg{Initial version}
 */

#include "solver.h"
#include <gsl/gsl_sf_bessel.h>

/// TODO
#define nmax 1000

dcomplex Solver::GetSxx (int sp, void *params, dcomplex w)
{
  struct SolverParams *p = (struct SolverParams *)params;
  const ConfigDisp &cfg = *(p->cfg);
  double kpar = p->kpar;
  double kper = p->kper;

  dcomplex wp2 = cfg.PlasmaFreq2 (sp);
  double lambda = cfg.Lambda (sp, kper);
  double lambdai = 1./lambda;
  dcomplex zetap, zetam;
  dcomplex fnczp, fnczm, fndzp, fndzm;

  double Inm1 = gsl_sf_bessel_I0_scaled (lambda);
  double Inp0 = gsl_sf_bessel_I1_scaled (lambda);
  double Inp1;

  dcomplex zeta0 = cfg.Zeta(sp, 0, kpar, kper, w);
  dcomplex fncz0 = Math::FncZ (zeta0);
  dcomplex fndz0 = -2. * (1. + zeta0 * fncz0);
  dcomplex termn, term0 = 2. * lambda * (Inm1-Inp0);

  double dn;
  dcomplex sumfncz = 0., sumfndz = 0.;
  for (int n=1; n<nmax; ++n)
  {
    dn = double(n);
    Inm1 = gsl_sf_bessel_In_scaled (n-1, lambda);
    Inp0 = gsl_sf_bessel_In_scaled (n  , lambda);
    Inp1 = gsl_sf_bessel_In_scaled (n+1, lambda);

    zetap = cfg.Zeta (sp, +n, kpar, kper, w);
    zetam = cfg.Zeta (sp, -n, kpar, kper, w);
    fnczp = Math::FncZ (zetap);
    fnczm = Math::FncZ (zetam);
    fndzp = -2. * (1. + zetap * fnczp);
    fndzm = -2. * (1. + zetam * fnczm);

    termn = lambda * (2.*Inp0-Inp1-Inm1) + dn*dn*lambdai * Inp0;
    sumfncz += termn * (fnczp+fnczm);
    sumfndz += termn * (fndzp+fndzm);

    if (Inp1 < 1.e-200) break;
  }

  dcomplex ani = 0.5 * (cfg.Ani(sp) - 1.);

  return wp2 * (zeta0*(term0*fncz0 + sumfncz) - ani*(term0*fndz0 + sumfndz));
}

dcomplex Solver::GetSxy (int sp, void *params, dcomplex w)
{
  struct SolverParams *p = (struct SolverParams *)params;
  const ConfigDisp &cfg = *(p->cfg);
  double kpar = p->kpar;
  double kper = p->kper;

  dcomplex wp2 = cfg.PlasmaFreq2 (sp);
  double lambda = cfg.Lambda (sp, kper);
  double lambdai = 1./lambda;
  dcomplex zetap, zetam;
  dcomplex fnczp, fnczm, fndzp, fndzm;

  double Inm1 = gsl_sf_bessel_I0_scaled (lambda);
  double Inp0 = gsl_sf_bessel_I1_scaled (lambda);
  double Inp1;

  dcomplex zeta0 = cfg.Zeta(sp, 0, kpar, kper, w);
  dcomplex termn;

  double dn;
  dcomplex sumfncz = 0., sumfndz = 0.;
  for (int n=1; n<nmax; ++n)
  {
    dn = double(n);
    Inm1 = gsl_sf_bessel_In_scaled (n-1, lambda);
    Inp0 = gsl_sf_bessel_In_scaled (n  , lambda);
    Inp1 = gsl_sf_bessel_In_scaled (n+1, lambda);

    zetap = cfg.Zeta (sp, +n, kpar, kper, w);
    zetam = cfg.Zeta (sp, -n, kpar, kper, w);
    fnczp = Math::FncZ (zetap);
    fnczm = Math::FncZ (zetam);
    fndzp = -2. * (1. + zetap * fnczp);
    fndzm = -2. * (1. + zetam * fnczm);

    termn = dn * (Inp0 - 0.5*(Inp1+Inm1));
    sumfncz += termn * (fnczp-fnczm);
    sumfndz += termn * (fndzp-fndzm);

    if (Inp1 < 1.e-200) break;
  }

  dcomplex ani = 0.5 * (cfg.Ani(sp) - 1.);
  dcomplex imag (0., 1.);

  return imag * wp2 * (zeta0*sumfncz - ani*sumfndz);
}

dcomplex Solver::GetSxz (int sp, void *params, dcomplex w)
{
  struct SolverParams *p = (struct SolverParams *)params;
  const ConfigDisp &cfg = *(p->cfg);
  double kpar = p->kpar;
  double kper = p->kper;

  dcomplex wp2 = cfg.PlasmaFreq2 (sp);
  double lambda = cfg.Lambda (sp, kper);
  double lambdai = 1./lambda;
  dcomplex zetap, zetam;
  dcomplex fnczp, fnczm, fndzp, fndzm;

  double Inm1 = gsl_sf_bessel_I0_scaled (lambda);
  double Inp0 = gsl_sf_bessel_I1_scaled (lambda);
  double Inp1;

  dcomplex zeta0 = cfg.Zeta(sp, 0, kpar, kper, w);
  dcomplex fncz0 = Math::FncZ (zeta0);
  dcomplex fndz0 = -2. * (1. + zeta0 * fncz0);
  dcomplex termn, term0 = fndz0 * (Inm1 - Inp0);

  double dn;
  dcomplex sumfncz = 0., sumfndz = 0.;
  for (int n=1; n<nmax; ++n)
  {
    dn = double(n);
    Inm1 = gsl_sf_bessel_In_scaled (n-1, lambda);
    Inp0 = gsl_sf_bessel_In_scaled (n  , lambda);
    Inp1 = gsl_sf_bessel_In_scaled (n+1, lambda);

    zetap = cfg.Zeta (sp, +n, kpar, kper, w);
    zetam = cfg.Zeta (sp, -n, kpar, kper, w);
    fnczp = Math::FncZ (zetap);
    fnczm = Math::FncZ (zetam);
    fndzp = -2. * (1. + zetap * fnczp);
    fndzm = -2. * (1. + zetam * fnczm);

    termn = Inp0 - 0.5*(Inp1+Inm1);
    sumfncz += termn * (fndzp + fndzm);
    sumfndz += termn * (zetap*fndzp + zetam*fndzm);

    if (Inp1 < 1.e-200) break;
  }

  dcomplex ani = cfg.Ani(sp) - 1.;
  dcomplex alpha = Math::Abs(kpar)*kper*cfg.VthPar(sp) /
    (M_SQRT2 * kpar * cfg.CycloFreq(sp));
  dcomplex imag (0., 1.);

  return imag * wp2 * alpha * (zeta0*(term0 + sumfncz) +
			       ani*(term0*zeta0 + sumfndz));
}

dcomplex Solver::GetSyy (int sp, void *params, dcomplex w)
{
  struct SolverParams *p = (struct SolverParams *)params;
  const ConfigDisp &cfg = *(p->cfg);
  double kpar = p->kpar;
  double kper = p->kper;

  dcomplex wp2 = cfg.PlasmaFreq2 (sp);
  double lambda = cfg.Lambda (sp, kper);
  double lambdai = 1./lambda;
  dcomplex zetap, zetam;
  dcomplex fnczp, fnczm, fndzp, fndzm;

  double Inm1 = gsl_sf_bessel_I0_scaled (lambda);
  double Inp0 = gsl_sf_bessel_I1_scaled (lambda);
  double Inp1;

  dcomplex zeta0 = cfg.Zeta(sp, 0, kpar, kper, w);
  dcomplex termn;

  double dn;
  dcomplex sumfncz = 0., sumfndz = 0.;
  for (int n=1; n<nmax; ++n)
  {
    dn = double(n);
    Inm1 = gsl_sf_bessel_In_scaled (n-1, lambda);
    Inp0 = gsl_sf_bessel_In_scaled (n  , lambda);
    Inp1 = gsl_sf_bessel_In_scaled (n+1, lambda);

    zetap = cfg.Zeta (sp, +n, kpar, kper, w);
    zetam = cfg.Zeta (sp, -n, kpar, kper, w);
    fnczp = Math::FncZ (zetap);
    fnczm = Math::FncZ (zetam);
    fndzp = -2. * (1. + zetap * fnczp);
    fndzm = -2. * (1. + zetam * fnczm);

    termn = dn*dn * Inp0;
    sumfncz += termn * (fnczp+fnczm);
    sumfndz += termn * (fndzp+fndzm);

    if (Inp1 < 1.e-200) break;
  }

  dcomplex ani = 0.5 * (cfg.Ani(sp) - 1.);

  return wp2 * lambdai * (zeta0*sumfncz - ani*sumfndz);
}

dcomplex Solver::GetSyz (int sp, void *params, dcomplex w)
{
  struct SolverParams *p = (struct SolverParams *)params;
  const ConfigDisp &cfg = *(p->cfg);
  double kpar = p->kpar;
  double kper = p->kper;

  dcomplex wp2 = cfg.PlasmaFreq2 (sp);
  double lambda = cfg.Lambda (sp, kper);
  double lambdai = 1./lambda;
  dcomplex zetap, zetam;
  dcomplex fnczp, fnczm, fndzp, fndzm;

  double Inm1 = gsl_sf_bessel_I0_scaled (lambda);
  double Inp0 = gsl_sf_bessel_I1_scaled (lambda);
  double Inp1;

  dcomplex zeta0 = cfg.Zeta(sp, 0, kpar, kper, w);
  dcomplex termn;

  double dn;
  dcomplex sumfncz = 0., sumfndz = 0.;
  for (int n=1; n<nmax; ++n)
  {
    dn = double(n);
    Inm1 = gsl_sf_bessel_In_scaled (n-1, lambda);
    Inp0 = gsl_sf_bessel_In_scaled (n  , lambda);
    Inp1 = gsl_sf_bessel_In_scaled (n+1, lambda);

    zetap = cfg.Zeta (sp, +n, kpar, kper, w);
    zetam = cfg.Zeta (sp, -n, kpar, kper, w);
    fnczp = Math::FncZ (zetap);
    fnczm = Math::FncZ (zetam);
    fndzp = -2. * (1. + zetap * fnczp);
    fndzm = -2. * (1. + zetam * fnczm);

    termn = dn * Inp0;
    sumfncz += termn * (fndzp-fndzm);
    sumfndz += termn * (fndzp+fndzm) * dn;

    if (Inp1 < 1.e-200) break;
  }

  dcomplex ani = 0.5 * (cfg.Ani(sp) - 1.);
  dcomplex alpha = Math::Abs(kpar)*kper*cfg.VthPar(sp) /
    (M_SQRT2 * kpar * cfg.CycloFreq(sp));
  dcomplex beta = kper / kpar;

  return wp2*lambdai * (zeta0*alpha*cfg.Ani(sp)*sumfncz + beta*ani*sumfndz);
}

dcomplex Solver::GetSzz (int sp, void *params, dcomplex w)
{
  struct SolverParams *p = (struct SolverParams *)params;
  const ConfigDisp &cfg = *(p->cfg);
  double kpar = p->kpar;
  double kper = p->kper;

  dcomplex wp2 = cfg.PlasmaFreq2 (sp);
  double lambda = cfg.Lambda (sp, kper);
  double lambdai = 1./lambda;
  dcomplex zetap, zetam;
  dcomplex fnczp, fnczm, fndzp, fndzm;

  double Inm1 = gsl_sf_bessel_I0_scaled (lambda);
  double Inp0 = gsl_sf_bessel_I1_scaled (lambda);
  double Inp1;

  dcomplex zeta0 = cfg.Zeta(sp, 0, kpar, kper, w);
  dcomplex fncz0 = Math::FncZ (zeta0);
  dcomplex fndz0 = -2. * (1. + zeta0 * fncz0);
  dcomplex termn, term0 = Inm1*zeta0*fndz0;

  double dn;
  dcomplex sumfncz = 0., sumfndz = 0.;
  for (int n=1; n<nmax; ++n)
  {
    dn = double(n);
    Inm1 = gsl_sf_bessel_In_scaled (n-1, lambda);
    Inp0 = gsl_sf_bessel_In_scaled (n  , lambda);
    Inp1 = gsl_sf_bessel_In_scaled (n+1, lambda);

    zetap = cfg.Zeta (sp, +n, kpar, kper, w);
    zetam = cfg.Zeta (sp, -n, kpar, kper, w);
    fnczp = Math::FncZ (zetap);
    fnczm = Math::FncZ (zetam);
    fndzp = -2. * (1. + zetap * fnczp);
    fndzm = -2. * (1. + zetam * fnczm);

    termn = Inp0;
    sumfncz += termn * (zetap*fndzp + zetam*fndzm);
    sumfndz += termn * (zetap*fndzp - zetam*fndzm) * dn;

    if (Inp1 < 1.e-200) break;
  }

  dcomplex ani = 1. - cfg.Ani(sp);
  dcomplex alpha = cfg.CycloFreq(sp) / (M_SQRT2*Math::Abs(kpar)*cfg.VthPar(sp));

  return -wp2 * (zeta0*(term0 + sumfncz) + ani*alpha*sumfndz);
}
