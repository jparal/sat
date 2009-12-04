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

  complex<double> dxx, dxy, dxz, dyx, dyy, dyz, dzx, dzy, dzz;
  complex<double> w (gsl_vector_get(x, 0), gsl_vector_get(x, 1));
  complex<double> w2 = w*w;
  double kpar = p->kpar;
  double kper = p->kper;
  double kvec = Math::Sqrt (kpar*kpar + kper*kper);
  double cva2;

  // do we have v_A / c = W_p / w_p
  if (cfg.HaveVac ())
    cva2 = 1. / cfg.Vac();
  else
    cva2 = cfg.Rwpewce() * Math::Sqrt(cfg.Rmpme());

  cva2 = cva2*cva2;

  dxx = w2 - kvec*kvec * cva2;
  dxy = 0.;
  dxz = 0.;

  dyx = 0.;
  dyy = w2 - kpar*kpar * cva2;
  dyz =      kpar*kper * cva2;

  dzx = 0.;
  dzy =      kpar*kper * cva2;
  dzz = w2 - kper*kper * cva2;

  for (int sp=0; sp<cfg.Nspecie(); ++sp)
  {
    dxx += GetSxx (sp, params, w);
    dxy += GetSxy (sp, params, w);
    dxz += GetSxz (sp, params, w);

    dyx -= GetSxy (sp, params, w);
    dyy += GetSyy (sp, params, w);
    dyz += GetSyz (sp, params, w);

    dzx -= GetSxz (sp, params, w);
    dzy += GetSyz (sp, params, w);
    dzz += GetSzz (sp, params, w);
  }

  complex<double> retval;
  retval = dxx*dyy*dzz + dxz*dyx*dzy + dxy*dyz*dzx
    - dxz*dyy*dzx - dxy*dyx*dzz - dxx*dyz*dzy;

  gsl_vector_set (f, 0, real(retval));
  gsl_vector_set (f, 1, imag(retval));

  return GSL_SUCCESS;
}

int print_state (int iter, gsl_multiroot_fsolver * s)
{
  printf ("i=%3d: x=(%.3e %.3e) dx=(%.3e, %.3e)"
          " fx=(%.3e %.3e)\n", iter,
          gsl_vector_get (s->x, 0),
          gsl_vector_get (s->x, 1),
          gsl_vector_get (s->dx, 0),
          gsl_vector_get (s->dx, 1),
          gsl_vector_get (s->f, 0),
          gsl_vector_get (s->f, 1));
}

int Solver::Solve (SolverParams *params, complex<double> &root)
{
  const gsl_multiroot_fsolver_type *T;
  gsl_multiroot_fsolver *s;

  const size_t n = 2;
  gsl_multiroot_function f = {&DispRelation, n, params};

  gsl_vector *dx, *x = gsl_vector_alloc (n);
  gsl_vector_set (x, 0, params->rew);
  gsl_vector_set (x, 1, params->imw);

  //T = gsl_multiroot_fsolver_hybrids;
  //T = gsl_multiroot_fsolver_hybrid;
  T = gsl_multiroot_fsolver_dnewton;
  //T = gsl_multiroot_fsolver_broyden;
  s = gsl_multiroot_fsolver_alloc (T, 2);
  gsl_multiroot_fsolver_set (s, &f, x);

  int status, iter = 0, max_iter = 50;
  do
  {
    iter++;
    status = gsl_multiroot_fsolver_iterate (s);
    dx = gsl_multiroot_fsolver_dx (s);

    //print_state (iter, s);

    if (status)   /* check if solver is stuck */
      break;

    status = gsl_multiroot_test_residual (s->dx, 1e-6);
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
  int nt = _cfg.ThetaSamp ();
  complex<double> w;
  Array<double> atht, akvec;
  Field<double,2> frew (nk, nt);
  Field<double,2> fimw (nk, nt);

  double tht;
  for (int it=0; it<nt; ++it)
  {
    tht = _cfg.GetThetaSample (it);
    atht.Push (_cfg.GetThetaSample(it));

    params.rew = 0.5 * (_cfg.OmegaMin() + _cfg.OmegaMax());
    params.imw = 0.5 * (_cfg.GammaMin() + _cfg.GammaMax());
    for (int ik=0; ik<nk; ++ik)
    {
      params.kpar = _cfg.GetKSamplePar (ik, tht);
      params.kper = _cfg.GetKSamplePer (ik, tht);
      Solve (&params, w);

      DBG_INFO ("tht, kpar, kper = "<<tht<<", "<<
		params.kpar<<", "<<params.kper);

      if (it == 0)
	akvec.Push (_cfg.GetKSample(ik));
      frew(it,ik) = real(w);
      fimw(it,ik) = imag(w);
    }
  }

  HDF5File file (_cfg.OutName(), IOFile::suff);
  file.Write (akvec, "kvec");
  file.Write (atht, "tht");
  file.Write (frew, "rew");
  file.Write (fimw, "imy");
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
    DBG_INFO ("Temperature per/par:  "
              << _cfg.VthPer (sp) * _cfg.VthPer (sp) << "/"
              << _cfg.VthPar (sp) * _cfg.VthPar (sp));
    DBG_INFO ("vth per/par:          "
              << _cfg.VthPer (sp) << "/" << _cfg.VthPar (sp));
    DBG_INFO ("v0 per/par:           "
              << _cfg.V0Per (sp) << "/" << _cfg.V0Par (sp));
  }
}
