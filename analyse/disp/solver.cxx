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
#include <iomanip>
#include <stdio.h>
#include <gsl/gsl_errno.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_multiroots.h>

int Solver::DispRelation (const gsl_vector *x, void *params, gsl_vector *f)
{
  struct SolverParams *p = (struct SolverParams *) params;
  const ConfigDisp &cfg = *(p->cfg);
  complex<double> wpewce = cfg.Rwpewce ();
  complex<double> kvec (p->kvec, 0.);
  complex<double> kwp;

  // do we have v_A / c = W_p / w_p
  if (cfg.HaveVac ())
    kwp = kvec / cfg.Vac ();
  else
    kwp = kvec * wpewce * Math::Sqrt (cfg.Rmpme());

  complex<double> w (gsl_vector_get(x, 0), gsl_vector_get(x, 1));

  complex<double> retval = w*w - kwp*kwp;
  for (int sp=0; sp<cfg.Nspecie(); ++sp)
  {
    complex<double> wp = cfg.PlasmaFreq (sp);
    complex<double> vth = cfg.VthPar (sp);
    complex<double> ani = 0.5 * (1. - cfg.Ani (sp));
    complex<double> zeta1, zeta0 = cfg.Zeta (sp, 0, real(kvec), w);

    if (p->lpol)
      zeta1 = cfg.Zeta (sp, -1, real(kvec), w);
    else
      zeta1 = cfg.Zeta (sp, +1, real(kvec), w);

    retval += wp*wp * (zeta0 * Math::FncZ(zeta1) + ani * Math::FncDZ (zeta1));
  }

  gsl_vector_set (f, 0, real(retval));
  gsl_vector_set (f, 1, imag(retval));

  return GSL_SUCCESS;
}

int Solver::Solve (SolverParams *params, complex<double> &root)
{
  const gsl_multiroot_fsolver_type *T;
  gsl_multiroot_fsolver *s;

  const size_t n = 2;
  gsl_multiroot_function f = {&DispRelation, n, params};

  gsl_vector *x = gsl_vector_alloc (n);
  gsl_vector_set (x, 0, params->rew);
  gsl_vector_set (x, 1, params->imw);

  T = gsl_multiroot_fsolver_hybrids;
  //T = gsl_multiroot_fsolver_hybrid;
  //T = gsl_multiroot_fsolver_dnewton;
  //T = gsl_multiroot_fsolver_broyden;
  s = gsl_multiroot_fsolver_alloc (T, 2);
  gsl_multiroot_fsolver_set (s, &f, x);

  int status, iter = 0, max_iter = 1000;
  do
  {
    iter++;
    status = gsl_multiroot_fsolver_iterate (s);

    if (status)   /* check if solver is stuck */
      break;

    status = gsl_multiroot_test_residual (s->f, 1e-7);
  }
  while (status == GSL_CONTINUE && iter < max_iter);

  if (status != GSL_SUCCESS)
    printf ("status = %s\n", gsl_strerror (status));

  real(root) = gsl_vector_get (s->x, 0);
  imag(root) = gsl_vector_get (s->x, 1);
  params->rew = real(root);
  params->imw = imag(root);

  gsl_multiroot_fsolver_free (s);
  gsl_vector_free (x);

  return 0;
}

void Solver::SolveAll ()
{
  struct SolverParams params;
  params.cfg = &(_cfg);

  int nk = _cfg.KSamp ();
  complex<double> wp, wm;
  Array<double> awp, awm, ayp, aym, ak;

  params.rew = 0.5 * (_cfg.OmegaMin() + _cfg.OmegaMax());
  params.imw = 0.5 * (_cfg.GammaMin() + _cfg.GammaMax());
  params.lpol = true;
  for (int ik=0; ik<nk; ++ik)
  {
    params.kvec = _cfg.GetKSample (ik);
    Solve (&params, wm);
    ak.Push (params.kvec);
    awm.Push (real(wm));
    aym.Push (imag(wm));
  }

  params.rew = 0.5 * (_cfg.OmegaMin() + _cfg.OmegaMax());
  params.imw = 0.5 * (_cfg.GammaMin() + _cfg.GammaMax());
  params.lpol = false;
  for (int ik=0; ik<nk; ++ik)
  {
    params.kvec = _cfg.GetKSample (ik);
    Solve (&params, wp);
    awp.Push (real(wp));
    ayp.Push (imag(wp));
  }

  HDF5File file (_cfg.OutName ());
  file.Write (ak, "k");
  file.Write (awp, "wp");
  file.Write (ayp, "yp");
  file.Write (awm, "wm");
  file.Write (aym, "ym");
}

void Solver::Print ()
{
  double vac;
  if (_cfg.HaveVac())
    vac = _cfg.Vac();
  else
    vac = 1./(_cfg.Rwpewce () * Math::Sqrt (_cfg.Rmpme()));

  DBG_INFO ("v_A/c = W_p/w_p = " <<  vac);

  for (int sp=0; sp<_cfg.Nspecie(); ++sp)
  {
    DBG_INFO ("=========== Specie: "<< sp <<" ===========");
    DBG_INFO ("Mass (m_p):           " << _cfg.Mass (sp));
    DBG_INFO ("Charge (e):           " << _cfg.Charge (sp));
    DBG_INFO ("Relative density:     " << _cfg.Density (sp));
    DBG_INFO ("Plasma Frequency:     " << _cfg.PlasmaFreq (sp));
    DBG_INFO ("Cyclotron Frequency:  " << _cfg.CycloFreq (sp));
    DBG_INFO ("Parallel beta:        " << _cfg.Beta (sp));
    DBG_INFO ("Anisotropy (per/par): " << _cfg.Ani (sp));
    DBG_INFO ("vth par/per:          "
	      << _cfg.VthPar (sp) << "/" << _cfg.VthPer (sp));
    DBG_INFO ("v0 par/per:           "
	      << _cfg.V0Par (sp) << "/" << _cfg.V0Per (sp));
  }
}
