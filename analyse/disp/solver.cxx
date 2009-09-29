/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   solver.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/08, @jparal}
 * @revmessg{Initial version}
 */

#include "solver.h"
#include "satmath.h"
#include "satio.h"

#include <stdio.h>
#include <gsl/gsl_errno.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_roots.h>

double Solver::DispRelation (double x, void *params)
{
  struct SolverParams *p = (struct SolverParams *) params;
  const ConfigDisp &cfg = *(p->cfg);
  double wpewce = cfg.Rwpewce ();
  double k = cfg.GetKSample (p->ksamp);
  double kwc = k / (wpewce * Math::Sqrt(cfg.Rmpme ()));
  kwc = k;
  bool lpol = p->lpol;

  complex<double> w;
  if (p->real)
    real(w) = x;
  else
    imag(w) = x;

  complex<double> retval = w*w - kwc*kwc;
  for (int sp=0; sp<cfg.Nspecie(); ++sp)
  {
    double wp = cfg.PlasmaFreq (sp);
    double vth = cfg.VthPar (sp);
    double ani = (1. - cfg.Ani (sp))/2.;
    complex<double> zeta1, zeta0 = cfg.Zeta (sp, 0, k, w);

    if (lpol)
      zeta1 = cfg.Zeta (sp, -1, k, w);
    else
      zeta1 = cfg.Zeta (sp, +1, k, w);

    retval += wp*wp * (zeta0 * Math::FncZ(zeta1) + ani * Math::FncDZ (zeta1));
  }

  if (p->real)
    return real(retval);
  else
    return imag(retval);
}

void Solver::SolveAll ()
{
  struct SolverParams params;
  params.cfg = &(cfg);

  printf ("%5s %9s, %9s %9s\n", "iter", "k", "omega", "gamma");

  double wp, wm, yp, ym;
  Array<double> awp, awm, ayp, aym, ak;

  for (int ik=0; ik<cfg.KSamp (); ++ik)
  {
    params.ksamp = ik;

    params.real = true; params.lpol = true;   Solve (&params, wp);
    params.real = true; params.lpol = false;  Solve (&params, wm);
    params.real = false; params.lpol = true;  Solve (&params, yp);
    params.real = false; params.lpol = false; Solve (&params, ym);

    ak.Push (cfg.GetKSample (ik));
    awp.Push (wp);
    awm.Push (wm);
    ayp.Push (yp);
    aym.Push (ym);

    printf ("%5d %.9f, %.9f %.9f\n", ik, cfg.GetKSample(ik), wp, yp);
  }

  HDF5File file;
  file.Write (ak, "k", cfg.OutName ());
  file.Write (awp, "wp", cfg.OutName (), true);
  file.Write (awm, "wm", cfg.OutName (), true);
  file.Write (ayp, "yp", cfg.OutName (), true);
  file.Write (aym, "ym", cfg.OutName (), true);
}

int Solver::Solve (SolverParams *params, double &root)
{
  int status;
  int iter = 0, max_iter = 100;
  const gsl_root_fsolver_type *T;
  gsl_root_fsolver *s;
  double x_lo, x_hi;
  double r = 0, r_expected;
  gsl_function F;

  if (params->real)
  {
    x_lo = cfg.OmegaMin ();
    x_hi = cfg.OmegaMax ();
  }
  else
  {
    x_lo = cfg.GammaMin ();
    x_hi = cfg.GammaMax ();
  }

  // DBG_INFO ("Min/Max: "<< x_lo << "/" <<x_hi);

  r_expected = (x_hi + x_lo)/2.;
  F.function = &DispRelation;
  F.params = params;

  T = gsl_root_fsolver_brent;
  s = gsl_root_fsolver_alloc (T);
  gsl_root_fsolver_set (s, &F, x_lo, x_hi);

  // printf ("%5s [%9s, %9s] %9s %10s %9s\n", "iter", "lower", "upper", "root",
  // 	  "err", "err(est)");

  do
  {
    iter++;
    status = gsl_root_fsolver_iterate (s);
    r = gsl_root_fsolver_root (s);
    x_lo = gsl_root_fsolver_x_lower (s);
    x_hi = gsl_root_fsolver_x_upper (s);
    status = gsl_root_test_interval (x_lo, x_hi, 0, 0.001);

    //    if (status == GSL_SUCCESS) printf ("Converged:\n");

    // printf ("%5d [%.7f, %.7f] %.7f %+.7f %.7f\n", iter, x_lo, x_hi,
    // 	    r, r - r_expected, x_hi - x_lo);
  }
  while (status == GSL_CONTINUE && iter < max_iter);

  gsl_root_fsolver_free (s);

  root = r;
  return status;
}

void Solver::Print ()
{
  for (int sp=0; sp<cfg.Nspecie(); ++sp)
  {
    complex<double> zeta0 = cfg.Zeta (sp, 0, cfg.KSamp()/2, .1);
    complex<double> zeta1 = cfg.Zeta (sp,+1, cfg.KSamp()/2, .1);
    DBG_INFO ("===== Specie: "<< sp <<" =======");
    DBG_INFO ("Plasma Frequency:    " << cfg.PlasmaFreq (sp));
    DBG_INFO ("Cyclotron Frequency: " << cfg.CycloFreq (sp));
    DBG_INFO ("vth parallel:        " << cfg.VthPar (sp));
    DBG_INFO ("vth perpendicular:   " << cfg.VthPer (sp));
    DBG_INFO ("Zeta(0,w=.1):        " << zeta0);
    DBG_INFO ("Zeta(1,w=.1):        " << zeta1);
    DBG_INFO ("Z (Zeta(0,w=.1)):    " << Math::FncZ (zeta0));
    DBG_INFO ("Z'(Zeta(0,w=.1)):    " << Math::FncDZ (zeta0));
    DBG_INFO ("Z (Zeta(1,w=.1)):    " << Math::FncZ (zeta1));
    DBG_INFO ("Z'(Zeta(1,w=.1)):    " << Math::FncDZ (zeta1));
  }
}
