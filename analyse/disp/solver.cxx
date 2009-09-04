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

#include <stdio.h>
#include <gsl/gsl_errno.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_roots.h>

complex<double> Solver::CompZ (const ConfigDisp& cfg, int sp, int n, int sample,
			       complex<double> w)
{
  double kz = cfg.GetKSample (sample);
  double v0 = cfg.V0Par(sp);
  double vl = cfg.VthPar (sp);
  double wc = cfg.CycloFreq (sp);
  complex<double> zeta = (w + n * wc - kz * v0) / (kz * vl);
  complex<double> retval = 1. - (kz * v0 / w) * Math::FncZ (zeta);
  retval += (kz * vl)/(2. * w) * (1. - cfg.Ani(sp))* Math::FncDZ (zeta);

  return retval;
}

double Solver::DispRelation (double x, void *params)
{
  struct SolverParams *p = (struct SolverParams *) params;
  const ConfigDisp &cfg = *(p->cfg);
  bool cmpreal = p->real;
  int ksamp = p->ksamp;

  const double w = x;

  complex<double> retval = 1.;
  for (int sp=0; sp<cfg.Nspecie(); ++sp)
  {
    double wp = cfg.PlasmaFreq (sp);
    double kz = cfg.GetKSample (ksamp);
    double vl = M_SQRT2 * cfg.VthPar (sp);
    double tmp = wp*wp / (w*kz*vl);
    int ep = cfg.Charge(sp) / Math::Abs (cfg.Charge(sp));
    int epp = (1+ep)/2;
    int epm = (1-ep)/2;
    retval += tmp * (double(epp)*CompZ(cfg,sp, 1,ksamp,w) +
		     double(epm)*CompZ(cfg,sp,-1,ksamp,w));
    DBG_INFO ("Value(1): "<<wp<<" "<<kz<<" "<<vl<<" "<<tmp<<" "<<epp);
    DBG_INFO ("retval: "<<retval);
  }

  if (cmpreal)
    return real(retval);
  else
    return imag(retval);
}

int Solver::Solve ()
{
  int status;
  int iter = 0, max_iter = 100;
  const gsl_root_fsolver_type *T;
  gsl_root_fsolver *s;
  double x_lo = cfg.GammaMin (), x_hi = cfg.GammaMax ();
  double r = 0, r_expected = (x_hi + x_lo)/2.;
  gsl_function F;
  struct SolverParams params;
  params.cfg = &(cfg);
  params.real = false;
  params.ksamp = 0;

  F.function = &DispRelation;
  F.params = &params;

  T = gsl_root_fsolver_brent;
  s = gsl_root_fsolver_alloc (T);
  gsl_root_fsolver_set (s, &F, x_lo, x_hi);

  printf ("%5s [%9s, %9s] %9s %10s %9s\n", "iter", "lower", "upper", "root",
	  "err", "err(est)");

  do
  {
    iter++;
    status = gsl_root_fsolver_iterate (s);
    r = gsl_root_fsolver_root (s);
    x_lo = gsl_root_fsolver_x_lower (s);
    x_hi = gsl_root_fsolver_x_upper (s);
    status = gsl_root_test_interval (x_lo, x_hi, 0, 0.001);

    if (status == GSL_SUCCESS) printf ("Converged:\n");

    printf ("%5d [%.7f, %.7f] %.7f %+.7f %.7f\n", iter, x_lo, x_hi,
	    r, r - r_expected, x_hi - x_lo);
  }
  while (status == GSL_CONTINUE && iter < max_iter);

  gsl_root_fsolver_free (s);

  return status;
}
